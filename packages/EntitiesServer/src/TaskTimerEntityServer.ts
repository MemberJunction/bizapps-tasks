/**
 * Server-side subclass of `MJ_BizApps_Tasks: Task Timers` (`TaskTimer`).
 *
 * Enforces ownership rule R2 (§6.2, §7) on save and delete (discard):
 * - On create, defaults `PersonID` to the caller's primary Person and `StartedAt` to the server clock.
 * - Only the timer's person or a holder of `Manage Time Entries` may create, update, or discard it.
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
} from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { TasksSettings, UserCanManageTimeEntries } from '@mj-biz-apps/tasks-core';
import { mjBizAppsTasksTaskTimerEntity } from '@mj-biz-apps/tasks-entities';
import { PEOPLE_ENTITY, PeopleFilterForUser, PrimaryPersonIDForUser } from './UserPeople.js';

export const TASK_TIMER_ENTITY = 'MJ_BizApps_Tasks: Task Timers';
const SOURCE = 'TaskTimerEntityServer';

@RegisterClass(BaseEntity, TASK_TIMER_ENTITY)
export class TaskTimerEntityServer extends mjBizAppsTasksTaskTimerEntity {
    public override get DefaultSkipAsyncValidation(): boolean {
        return false;
    }

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        const user = this.ContextCurrentUser;
        if (!this.IsSaved && user) {
            if (!this.PersonID) {
                const personID = await PrimaryPersonIDForUser(Metadata.Provider, this.RunViewProviderToUse, user);
                if (personID) {
                    this.PersonID = personID;
                }
            }
            if (!this.StartedAt) {
                this.StartedAt = new Date();
            }
        }
        return super.Save(options);
    }

    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        try {
            const refusal = await this.checkOwnerOrManager('discard');
            if (refusal) {
                const res = new BaseEntityResult();
                res.Type = 'delete';
                res.Success = false;
                res.Message = refusal;
                this.ResultHistory.push(res);
                return false;
            }
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`${SOURCE}.Delete failed for timer ${this.ID}: ${msg}`);
            const res = new BaseEntityResult();
            res.Type = 'delete';
            res.Success = false;
            res.Message = `The timer could not be discarded (${msg}).`;
            this.ResultHistory.push(res);
            return false;
        }
        return super.Delete(options);
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        try {
            const refusal = await this.checkOwnerOrManager(this.IsSaved ? 'update' : 'start');
            if (refusal) {
                result.Success = false;
                result.Errors.push(new ValidationErrorInfo(`${SOURCE}.ValidateAsync`, refusal, null));
            }
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`${SOURCE}.ValidateAsync failed: ${msg}`);
            result.Success = false;
            result.Errors.push(new ValidationErrorInfo(`${SOURCE}.ValidateAsync`, `Timer validation failed (${msg}).`, null));
        }
        return result;
    }

    private async checkOwnerOrManager(action: 'start' | 'update' | 'discard'): Promise<string | null> {
        const provider = Metadata.Provider;
        const user = this.ContextCurrentUser;
        if (!user) {
            return 'A signed-in user is required to manage timers.';
        }

        await TasksSettings.Load(provider, user);
        if (action === 'start' && !TasksSettings.TimeTrackingEnabled(provider)) {
            return 'Time tracking is disabled for the Tasks application.';
        }

        if (!this.PersonID) {
            return "You can't start a timer: your user has no person record.";
        }

        if (UserCanManageTimeEntries(user, provider)) {
            return null;
        }

        const rv = new RunView(this.RunViewProviderToUse);
        const peopleRes = await rv.RunView<{ ID: string }>(
            {
                EntityName: PEOPLE_ENTITY,
                ExtraFilter: PeopleFilterForUser(provider, user),
                Fields: ['ID'],
                ResultType: 'simple',
                BypassCache: true,
            },
            user,
        );
        if (!peopleRes?.Success) {
            throw new Error(peopleRes?.ErrorMessage ?? 'People lookup failed');
        }
        const myPersonIds = (peopleRes.Results ?? []).map((p) => p.ID.toLowerCase());
        if (!myPersonIds.includes(this.PersonID.trim().toLowerCase())) {
            const who = this.Person?.trim() || 'the timer owner';
            return `Only ${who} or a time-entry manager can ${action} this timer.`;
        }
        return null;
    }
}
