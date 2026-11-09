/**
 * Server-side subclass of `MJ_BizApps_Tasks: Task Time Entries` (`TaskTimeEntry`).
 *
 * Enforces rules R1–R8 (§6.1) on create, update, and delete via {@link TimeEntryRefusal}:
 * - R1: Defaults `PersonID` on create to the caller's primary `Person` record.
 * - R2: Only the entry's person or a holder of `Manage Time Entries` may create, edit, or delete it.
 * - R3: The target `Task` must exist and be readable by the caller.
 * - R4: Derives `Minutes` from `[StartedAt, EndedAt]` when both are set; clears both if `Minutes` is
 *       subsequently edited by hand on a saved interval entry (§5.2).
 * - R5: Rejects `WorkDate` more than 1 day after today in the business timezone.
 * - R6: Rejects creating, moving into/out of, editing, or deleting an entry covered by a `Submitted`
 *       or `Approved` timesheet period when `LockApprovedTimeEntries` is on.
 * - R7: Automatically maintains `TimesheetID` to match the person's timesheet covering `WorkDate`.
 * - R8: Rejects editing or deleting an entry referenced by any `TaskTimeEntryLink` row.
 */
import {
    BaseEntity,
    BaseEntityResult,
    EntityDeleteOptions,
    EntitySaveOptions,
    LogError,
    Metadata,
    RunView,
    ValidationErrorInfo,
    ValidationResult,
    type IMetadataProvider,
    type UserInfo,
} from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { BusinessTimeZoneEngine, ToCalendarDay, type CalendarDay } from '@mj-biz-apps/common-entities';
import {
    DeriveIntervalMinutes,
    TasksSettings,
    TimeEntryRefusal,
    UserCanManageTimeEntries,
    type CoveringTimesheetFact,
    type TimeEntryFacts,
} from '@mj-biz-apps/tasks-core';
import { mjBizAppsTasksTaskTimeEntryEntity, type mjBizAppsTasksTimesheetEntity } from '@mj-biz-apps/tasks-entities';
import { GuidLiteral as guid, PEOPLE_ENTITY, PeopleFilterForUser, PrimaryPersonIDForUser } from './UserPeople.js';

export const TASK_TIME_ENTRY_ENTITY = 'MJ_BizApps_Tasks: Task Time Entries';
const TASK_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TIMESHEET_ENTITY = 'MJ_BizApps_Tasks: Timesheets';
const ENTRY_LINK_ENTITY = 'MJ_BizApps_Tasks: Task Time Entry Links';
const SOURCE = 'TaskTimeEntryEntityServer';

@RegisterClass(BaseEntity, TASK_TIME_ENTRY_ENTITY)
export class TaskTimeEntryEntityServer extends mjBizAppsTasksTaskTimeEntryEntity {
    public override get DefaultSkipAsyncValidation(): boolean {
        return false;
    }

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        try {
            await this.preparePreSave();
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`${SOURCE}.Save pre-save failed: ${msg}`);
            this.recordResultError('save', msg);
            return false;
        }
        return super.Save(options);
    }

    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        try {
            const refusal = await this.checkRefusal('delete');
            if (refusal) {
                this.recordResultError('delete', refusal);
                return false;
            }
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`${SOURCE}.Delete check failed for entry ${this.ID}: ${msg}`);
            this.recordResultError('delete', `The time entry could not be deleted (${msg}).`);
            return false;
        }
        return super.Delete(options);
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        try {
            const op = this.IsSaved ? 'update' : 'create';
            const refusal = await this.checkRefusal(op);
            if (refusal) {
                result.Success = false;
                result.Errors.push(new ValidationErrorInfo(`${SOURCE}.ValidateAsync`, refusal, null));
            }
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`${SOURCE}.ValidateAsync failed for task ${this.TaskID}: ${msg}`);
            result.Success = false;
            result.Errors.push(
                new ValidationErrorInfo(`${SOURCE}.ValidateAsync`, `Time entry validation failed (${msg}).`, null),
            );
        }
        return result;
    }

    /**
     * Applies pre-save defaults and derivations (R1 default `PersonID`, R4 interval duration, R7 `TimesheetID`).
     */
    private async preparePreSave(): Promise<void> {
        const user = this.ContextCurrentUser;
        const provider = Metadata.Provider;

        // R1: Default PersonID on create to caller's primary Person
        if (!this.IsSaved && !this.PersonID && user) {
            const personID = await PrimaryPersonIDForUser(provider, this.RunViewProviderToUse, user);
            if (personID) {
                this.PersonID = personID;
            }
        }

        // R4: Interval handling — if saved and Minutes was edited by hand without touching StartedAt/EndedAt, clear both;
        // otherwise if StartedAt and EndedAt are present, derive Minutes from the interval.
        const minutesDirty = this.GetFieldByName('Minutes')?.Dirty ?? false;
        const startDirty = this.GetFieldByName('StartedAt')?.Dirty ?? false;
        const endDirty = this.GetFieldByName('EndedAt')?.Dirty ?? false;

        if (this.IsSaved && minutesDirty && !startDirty && !endDirty && (this.StartedAt != null || this.EndedAt != null)) {
            this.StartedAt = null;
            this.EndedAt = null;
        } else if (this.StartedAt != null && this.EndedAt != null) {
            const derived = DeriveIntervalMinutes(this.StartedAt, this.EndedAt);
            if (derived != null) {
                this.Minutes = derived;
            }
        }

        // R7: Sync TimesheetID to the person's timesheet covering WorkDate (unless caller is SubmitTimesheet setting it explicitly)
        const workDay = ToCalendarDay(this.WorkDate);
        if (this.PersonID && workDay && user) {
            const covering = await this.loadCoveringTimesheets(
                new RunView(this.RunViewProviderToUse),
                [this.PersonID],
                [workDay],
                user,
            );
            const match = covering.find((ts) => workDay >= ts.PeriodStart && workDay <= ts.PeriodEnd);
            this.TimesheetID = match ? match.ID : null;
        }
    }

    private async checkRefusal(operation: 'create' | 'update' | 'delete'): Promise<string | null> {
        const provider = Metadata.Provider;
        const user = this.ContextCurrentUser;
        if (!user) {
            return 'A signed-in user is required to modify time entries.';
        }

        await TasksSettings.Load(provider, user);
        const facts = await this.gatherFacts(provider, user, operation);
        return TimeEntryRefusal(facts);
    }

    private async gatherFacts(
        provider: IMetadataProvider,
        user: UserInfo,
        operation: 'create' | 'update' | 'delete',
    ): Promise<TimeEntryFacts> {
        const rv = new RunView(this.RunViewProviderToUse);
        const personFilter = PeopleFilterForUser(provider, user);
        const canManage = UserCanManageTimeEntries(user, provider);

        // Resolve caller's Person IDs
        const peopleRes = await rv.RunView<{ ID: string }>(
            {
                EntityName: PEOPLE_ENTITY,
                ExtraFilter: personFilter,
                Fields: ['ID'],
                ResultType: 'simple',
                BypassCache: true,
            },
            user,
        );
        if (!peopleRes?.Success) {
            throw new Error(peopleRes?.ErrorMessage ?? 'People lookup failed');
        }
        const callerPersonIDs = (peopleRes.Results ?? []).map((p) => p.ID);

        let entryPersonID: string | null = this.PersonID || null;
        if (operation === 'create' && !entryPersonID && callerPersonIDs.length > 0) {
            entryPersonID = callerPersonIDs[0];
        }

        const personField = this.GetFieldByName('PersonID');
        const originalPersonID =
            operation === 'update' && personField?.Dirty && personField.OldValue != null
                ? String(personField.OldValue)
                : entryPersonID;

        const workDay = ToCalendarDay(this.WorkDate);
        const workDateField = this.GetFieldByName('WorkDate');
        const originalWorkDate =
            operation === 'update' && workDateField?.Dirty && workDateField.OldValue != null
                ? ToCalendarDay(workDateField.OldValue)
                : workDay;

        // Check task readability on create or TaskID change
        let taskExists = true;
        const taskField = this.GetFieldByName('TaskID');
        if (operation !== 'delete' && (operation === 'create' || taskField?.Dirty)) {
            if (!this.TaskID) {
                taskExists = false;
            } else {
                const taskLit = guid(this.TaskID, 'TaskID');
                const taskRes = await rv.RunView<{ ID: string }>(
                    {
                        EntityName: TASK_ENTITY,
                        ExtraFilter: `ID = ${taskLit}`,
                        Fields: ['ID'],
                        MaxRows: 1,
                        ResultType: 'simple',
                        BypassCache: true,
                    },
                    user,
                );
                if (!taskRes?.Success) {
                    throw new Error(taskRes?.ErrorMessage ?? 'Task lookup failed');
                }
                taskExists = (taskRes.Results?.length ?? 0) > 0;
            }
        }

        // Load covering timesheets for R6
        const personIdsToCheck = [entryPersonID, originalPersonID].filter((id): id is string => !!id);
        const datesToCheck = [workDay, originalWorkDate].filter((d): d is CalendarDay => !!d);
        const coveringTimesheets = await this.loadCoveringTimesheets(rv, personIdsToCheck, datesToCheck, user);

        // Load TaskTimeEntryLink records on update/delete for R8
        const linkedDescriptions: string[] = [];
        if ((operation === 'update' || operation === 'delete') && this.ID) {
            const entryLit = guid(this.ID, 'TaskTimeEntryID');
            const linkRes = await rv.RunView<{ Entity: string | null; RecordID: string; Relationship: string | null }>(
                {
                    EntityName: ENTRY_LINK_ENTITY,
                    ExtraFilter: `TaskTimeEntryID = ${entryLit}`,
                    Fields: ['Entity', 'RecordID', 'Relationship'],
                    ResultType: 'simple',
                    BypassCache: true,
                },
                user,
            );
            if (!linkRes?.Success) {
                throw new Error(linkRes?.ErrorMessage ?? 'TaskTimeEntryLink lookup failed');
            }
            for (const row of linkRes.Results ?? []) {
                const entityName = row.Entity?.trim() || 'Linked record';
                linkedDescriptions.push(`${entityName} (${row.RecordID})`);
            }
        }

        let todayInZone: CalendarDay | null = null;
        try {
            await BusinessTimeZoneEngine.Instance.Config(false, user, provider);
            todayInZone = BusinessTimeZoneEngine.Instance.Today();
        } catch {
            todayInZone = ToCalendarDay(new Date());
        }

        return {
            Operation: operation,
            CallerPersonIDs: callerPersonIDs,
            CallerCanManageTimeEntries: canManage,
            EntryPersonID: entryPersonID,
            OriginalPersonID: originalPersonID,
            EntryPersonName: this.Person || null,
            TaskExists: taskExists,
            WorkDate: workDay,
            OriginalWorkDate: originalWorkDate,
            TodayInBusinessZone: todayInZone,
            Minutes: this.Minutes,
            StartedAt: this.StartedAt,
            EndedAt: this.EndedAt,
            LockApprovedTimeEntries: TasksSettings.LockApprovedTimeEntries(provider),
            CoveringTimesheets: coveringTimesheets,
            LinkedRecordDescriptions: linkedDescriptions,
        };
    }

    private async loadCoveringTimesheets(
        rv: RunView,
        personIDs: readonly string[],
        dates: readonly CalendarDay[],
        user: UserInfo,
    ): Promise<CoveringTimesheetFact[]> {
        const uniquePersons = [...new Set(personIDs.map((p) => p.trim()).filter(Boolean))];
        const uniqueDates = [...new Set(dates.filter(Boolean))];
        if (uniquePersons.length === 0 || uniqueDates.length === 0) {
            return [];
        }

        const personClause = uniquePersons.map((id) => `PersonID = ${guid(id, 'PersonID')}`).join(' OR ');
        const dateClause = uniqueDates
            .map((d) => `(PeriodStart <= '${d}' AND PeriodEnd >= '${d}')`)
            .join(' OR ');

        const res = await rv.RunView<{
            ID: string;
            PeriodStart: Date | string;
            PeriodEnd: Date | string;
            Status: mjBizAppsTasksTimesheetEntity['Status'];
        }>(
            {
                EntityName: TIMESHEET_ENTITY,
                ExtraFilter: `(${personClause}) AND (${dateClause})`,
                Fields: ['ID', 'PeriodStart', 'PeriodEnd', 'Status'],
                ResultType: 'simple',
                BypassCache: true,
            },
            user,
        );
        if (!res?.Success) {
            throw new Error(res?.ErrorMessage ?? 'Timesheet lookup failed');
        }

        const facts: CoveringTimesheetFact[] = [];
        for (const row of res.Results ?? []) {
            const start = ToCalendarDay(row.PeriodStart);
            const end = ToCalendarDay(row.PeriodEnd);
            if (start && end) {
                facts.push({
                    ID: row.ID,
                    PeriodStart: start,
                    PeriodEnd: end,
                    Status: row.Status,
                });
            }
        }
        return facts;
    }

    private recordResultError(type: 'save' | 'delete', message: string): void {
        const result = new BaseEntityResult();
        result.Type = type === 'save' ? (this.IsSaved ? 'update' : 'create') : 'delete';
        result.Success = false;
        result.Message = message;
        this.ResultHistory.push(result);
    }
}
