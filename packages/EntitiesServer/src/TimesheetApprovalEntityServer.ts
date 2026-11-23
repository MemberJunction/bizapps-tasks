import {
    BaseEntity,
    EntitySaveOptions,
    LogError,
    Metadata,
    RunView,
    ValidationErrorInfo,
    ValidationErrorType,
    ValidationResult,
} from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import {
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTimesheetApprovalEntity,
    mjBizAppsTasksTimesheetEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    GuidLiteral,
    TasksLimitsResolver,
    UserCanManageTimeEntries,
    UserCanManageTimesheets,
} from '@mj-biz-apps/tasks-core';
import { ApprovalActor, IsSystemActor } from './ApprovalActor.js';
import { PeopleForUser } from './UserPeople.js';

export const TIMESHEET_APPROVAL_ENTITY = 'MJ_BizApps_Tasks: Timesheet Approvals';

/**
 * Server-side subclass of {@link mjBizAppsTasksTimesheetApprovalEntity}.
 *
 * Ensures that a `TimesheetApproval` part can only be created or updated by:
 * - the parent timesheet's owner (during submission / withdrawal),
 * - an approver assigned to `ApprovalTaskID` (when an approval task completes), or
 * - a holder of `Manage Timesheets` / `Manage Time Entries`.
 */
@RegisterClass(BaseEntity, TIMESHEET_APPROVAL_ENTITY)
export class TimesheetApprovalEntityServer extends mjBizAppsTasksTimesheetApprovalEntity {
    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        const refusal = await this.checkAuthority();
        if (refusal) {
            this.LatestResult.Success = false;
            this.LatestResult.Errors.push(new ValidationErrorInfo(
                'TimesheetID',
                refusal,
                this.TimesheetID,
                ValidationErrorType.Failure,
            ));
            return false;
        }
        return super.Save(options);
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        const refusal = await this.checkAuthority();
        if (refusal) {
            result.Errors.push(new ValidationErrorInfo(
                'TimesheetID',
                refusal,
                this.TimesheetID,
                ValidationErrorType.Failure,
            ));
            result.Success = false;
        }
        return result;
    }

    private async checkAuthority(): Promise<string | null> {
        const user = this.ContextCurrentUser;
        if (!user) {
            return 'Cannot save a timesheet approval part without a signed-in user context.';
        }
        if (IsSystemActor(user)) {
            return null;
        }

        try {
            const [canManageTimesheets, canManageEntries] = await Promise.all([
                UserCanManageTimesheets(user, Metadata.Provider),
                UserCanManageTimeEntries(user, Metadata.Provider),
            ]);
            if (canManageTimesheets || canManageEntries) {
                return null;
            }

            const callerPersonIDs = await PeopleForUser(
                Metadata.Provider,
                this.RunViewProviderToUse,
                user,
            );
            const callerSet = new Set(callerPersonIDs.map((id) => id.toLowerCase()));

            const rv = new RunView(this.RunViewProviderToUse);
            if (this.TimesheetID) {
                const tsRes = await rv.RunView<mjBizAppsTasksTimesheetEntity>({
                    EntityName: 'MJ_BizApps_Tasks: Timesheets',
                    ExtraFilter: `ID = ${GuidLiteral(this.TimesheetID, 'TimesheetID')}`,
                    Fields: ['ID', 'PersonID'],
                    MaxRows: TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow,
                    ResultType: 'simple',
                }, user);
                if (!tsRes?.Success) {
                    return `Timesheet lookup failed: ${tsRes?.ErrorMessage ?? 'unknown error'}`;
                }
                const ownerID = tsRes.Results?.[0]?.PersonID;
                if (ownerID && callerSet.has(ownerID.toLowerCase())) {
                    return null;
                }
            }

            if (this.ApprovalTaskID) {
                const taskFilter = GuidLiteral(this.ApprovalTaskID, 'ApprovalTaskID');
                const taskRes = await rv.RunView<{ ID: string; OrganizationID?: string | null }>({
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: `ID = ${taskFilter}`,
                    Fields: ['ID', 'OrganizationID'],
                    MaxRows: TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow,
                    ResultType: 'simple',
                }, user);
                if (!taskRes?.Success) {
                    return `Approval task lookup failed: ${taskRes?.ErrorMessage ?? 'unknown error'}`;
                }
                const approvalTask = taskRes.Results?.[0];
                const actor = new ApprovalActor(user, Metadata.Provider, this.RunViewProviderToUse);
                if (approvalTask?.OrganizationID && !(await actor.BelongsToOrganization(approvalTask.OrganizationID))) {
                    return 'This timesheet approval belongs to another organization.';
                }

                const asgnRes = await rv.RunView<mjBizAppsTasksTaskAssignmentEntity>({
                    EntityName: 'MJ_BizApps_Tasks: Task Assignments',
                    ExtraFilter: `TaskID = ${taskFilter}`,
                    Fields: ['AssigneeEntityID', 'AssigneeRecordID', 'Status'],
                    ResultType: 'simple',
                }, user);
                if (!asgnRes?.Success) {
                    return `Approval task assignments lookup failed: ${asgnRes?.ErrorMessage ?? 'unknown error'}`;
                }
                const assignments = asgnRes.Results ?? [];
                for (const a of assignments) {
                    if (a.Status !== 'Pending' && a.Status !== 'InProgress') continue;
                    if (await actor.IsAssignee(a.AssigneeEntityID, a.AssigneeRecordID)) {
                        return null;
                    }
                }
            }

            return 'Only the timesheet submitter, an assigned approver, or a timesheet manager can update this approval part.';
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`TimesheetApprovalEntityServer: authority check failed: ${msg}`);
            return `Timesheet approval authority check failed: ${msg}`;
        }
    }
}
