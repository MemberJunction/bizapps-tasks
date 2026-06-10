import { BaseEntity, BaseEntityEvent, EntitySaveOptions, LogError, Metadata } from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { TaskEntity } from '@mj-biz-apps/tasks-entities';
import { TaskService } from '@mj-biz-apps/tasks-core';

/**
 * Server-side subclass of {@link TaskEntity}.
 *
 * Holds the SERVER-ONLY task side-effects that must run exactly once and
 * authoritatively, and must NOT also run in the browser:
 *   - Activity logging (writes MJ_BizApps_Tasks: Task Activities audit rows)
 *   - Sub-task progress rollup (cascading read-modify-write up the parent chain)
 *
 * The client-shared {@link TaskEntity} keeps only validation + in-record field
 * side-effects. Registered at priority 2 to win over the priority-1 TaskEntity.
 *
 * Pattern mirrors SaaS's entities-server subclasses: override Save() to snapshot
 * pre-save state and write the audit log, and register a per-instance event
 * handler (once) for the cascading rollup so it fires after finalizeSave().
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Tasks', 2)
export class TaskEntityServer extends TaskEntity {
    private _rollupHandlerRegistered = false;

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        this.ensureRollupHandler();

        // Snapshot changed fields BEFORE save (super.Save resets dirty flags).
        const isNew = !this.IsSaved;
        const statusChanged = this.Fields.find(f => f.CodeName === 'Status')?.Dirty ?? false;
        const pctChanged = this.Fields.find(f => f.CodeName === 'PercentComplete')?.Dirty ?? false;
        const priorityChanged = this.Fields.find(f => f.CodeName === 'Priority')?.Dirty ?? false;
        const dueChanged = this.Fields.find(f => f.CodeName === 'DueAt')?.Dirty ?? false;
        const oldStatus = this.Fields.find(f => f.CodeName === 'Status')?.OldValue as string | null;
        const oldPct = this.Fields.find(f => f.CodeName === 'PercentComplete')?.OldValue as number | null;
        const oldPriority = this.Fields.find(f => f.CodeName === 'Priority')?.OldValue as string | null;
        const oldDue = this.Fields.find(f => f.CodeName === 'DueAt')?.OldValue;

        const result = await super.Save(options);
        if (!result) return false;

        // Activity logging — server-only audit trail. Must not fail the save, but
        // must not be silently swallowed either.
        try {
            await this.logActivities(isNew, statusChanged, pctChanged, priorityChanged, dueChanged,
                oldStatus, oldPct, oldPriority, oldDue);
        } catch (e) {
            const msg = e instanceof Error ? e.message : String(e);
            LogError(`TaskEntityServer: activity logging failed for task ${this.Get('ID')}: ${msg}`);
        }

        return true;
    }

    private async logActivities(
        isNew: boolean, statusChanged: boolean, pctChanged: boolean,
        priorityChanged: boolean, dueChanged: boolean,
        oldStatus: string | null, oldPct: number | null,
        oldPriority: string | null, oldDue: unknown,
    ): Promise<void> {
        const taskID = this.Get('ID') as string;

        if (isNew) {
            await this.logActivity(taskID, 'Created', `Task created: ${this.Get('Name')}`);
        }
        if (statusChanged && !isNew) {
            await this.logActivity(taskID, 'StatusChange',
                `Status changed from ${oldStatus} to ${this.Get('Status')}`,
                oldStatus ?? undefined, this.Get('Status') as string);
        }
        if (pctChanged && !isNew) {
            await this.logActivity(taskID, 'PercentCompleteChanged',
                `Progress updated to ${this.Get('PercentComplete')}%`,
                String(oldPct ?? 0), String(this.Get('PercentComplete')));
        }
        if (priorityChanged && !isNew) {
            await this.logActivity(taskID, 'PriorityChanged',
                `Priority changed from ${oldPriority} to ${this.Get('Priority')}`,
                oldPriority ?? undefined, this.Get('Priority') as string);
        }
        if (dueChanged && !isNew) {
            await this.logActivity(taskID, 'DueDateChanged',
                `Due date changed`, String(oldDue ?? ''), String(this.Get('DueAt') ?? ''));
        }
        if (statusChanged && this.Get('Status') === 'Completed') {
            await this.logActivity(taskID, 'Completed', `Task completed: ${this.Get('Name')}`);
        }
    }

    private async logActivity(
        taskID: string, activityType: string, description: string,
        previousValue?: string, newValue?: string,
    ): Promise<void> {
        const activity = await new Metadata().GetEntityObject('MJ_BizApps_Tasks: Task Activities', this.ContextCurrentUser);
        activity.NewRecord();
        activity.Set('TaskID', taskID);
        activity.Set('ActivityType', activityType);
        activity.Set('Description', description);
        if (previousValue) activity.Set('PreviousValue', previousValue);
        if (newValue) activity.Set('NewValue', newValue);
        await activity.Save();
    }

    /**
     * Registers a per-instance save handler that rolls up this task's parent
     * progress (server-only, idempotent, fire-and-forget). Fires after the save
     * is finalized so the ID/dirty state is settled.
     */
    private ensureRollupHandler(): void {
        if (this._rollupHandlerRegistered) {
            return;
        }
        this._rollupHandlerRegistered = true;

        this.RegisterEventHandler((event: BaseEntityEvent) => {
            if (event.type !== 'save') {
                return;
            }

            const parentID = this.Get('ParentID') as string | null;
            if (!parentID) {
                return;
            }

            // Idempotent reconcile: recomputes parent's weighted progress (and
            // auto-completes it when all children are done); no-ops when nothing
            // changed, which prevents the save it raises from looping back here.
            new TaskService()
                .rollupParentProgress(parentID, this.ContextCurrentUser)
                .catch((err: unknown) => {
                    const msg = err instanceof Error ? err.message : String(err);
                    LogError(`TaskEntityServer: parent-progress rollup failed for parent ${parentID}: ${msg}`);
                });
        });
    }
}
