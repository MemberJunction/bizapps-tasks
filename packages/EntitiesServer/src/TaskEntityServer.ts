import {
    BaseEntity,
    BaseEntityEvent,
    EntitySaveOptions,
    LogError,
    LogStatus,
    Metadata,
    RunView,
} from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { ActionEngineServer } from '@memberjunction/actions';
import {
    TaskEntity,
    mjBizAppsTasksTaskActivityEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskTypeEntity,
    mjBizAppsTasksTaskTypeStatusEntity,
} from '@mj-biz-apps/tasks-entities';
import { TaskService } from '@mj-biz-apps/tasks-core';

/**
 * Action hook trigger types supported on TaskType and TaskTypeStatus.
 */
export type TaskActionHookType =
    | 'OnCreate'
    | 'OnStatusChange'
    | 'OnEnterStatus'
    | 'OnExitStatus'
    | 'OnComplete'
    | 'OnCancel'
    | 'OnReject'
    | 'OnPercentChange';

/**
 * Lifecycle snapshot captured pre-save to drive post-save audit logging and action triggers.
 */
export interface TaskLifecycleContext {
    isNew: boolean;
    statusChanged: boolean;
    typeStatusChanged: boolean;
    pctChanged: boolean;
    priorityChanged: boolean;
    dueChanged: boolean;
    oldStatus: mjBizAppsTasksTaskEntity['Status'] | null;
    newStatus: mjBizAppsTasksTaskEntity['Status'];
    oldTypeStatusID: string | null;
    newTypeStatusID: string | null;
    oldPct: number | null;
    newPct: number | null;
    oldPriority: mjBizAppsTasksTaskEntity['Priority'] | null;
    newPriority: mjBizAppsTasksTaskEntity['Priority'];
    oldDue: Date | null;
    newDue: Date | null;
    typeID: string | null;
}

/**
 * Result of an action hook invocation.
 */
export interface TaskActionHookResult {
    Invoked: boolean;
    Success?: boolean;
    Message?: string;
}

/**
 * Server-side subclass of {@link TaskEntity}.
 *
 * Holds the SERVER-ONLY task side-effects that must run exactly once and
 * authoritatively on the backend:
 *   - Dynamic TaskTypeStatus & MacroStatus synchronization
 *   - Server-authoritative activity audit logging (MJ_BizApps_Tasks: Task Activities)
 *   - Parent sub-task progress rollup
 *   - Event-driven Action & Workflow hook execution (OnCreate, OnStatusChange, OnEnterStatus, OnExitStatus, OnComplete, OnCancel, OnReject, OnPercentChange)
 *
 * Lifecycle hook dispatch lives HERE and only here — it fires on the status
 * TRANSITION captured pre-save. TaskNotificationHandler (tasks-server) must not
 * invoke these hooks again, or one transition would fire them twice and later
 * edits of a terminal task would replay them.
 *
 * Compiler/import order ensures this server subclass takes effect.
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Tasks')
export class TaskEntityServer extends TaskEntity {
    private _rollupHandlerRegistered = false;

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        this.ensureRollupHandler();

        // 1. Pre-Save Sync: Synchronize TaskTypeStatusID <-> Status and defaults
        await this.syncTaskTypeStatusPreSave();

        // 2. Snapshot dirty flags and old values BEFORE super.Save resets them
        const lifecycleContext = this.captureLifecycleContext();

        // 3. Persist record
        const result = await super.Save(options);
        if (!result) return false;

        // 4. Activity logging — server-only audit trail
        try {
            await this.logActivities(lifecycleContext);
        } catch (e) {
            const msg = e instanceof Error ? e.message : String(e);
            LogError(`TaskEntityServer: activity logging failed for task ${this.ID}: ${msg}`);
        }

        // 5. Post-Save Lifecycle Action & Workflow Dispatcher (asynchronous, non-blocking)
        this.dispatchLifecycleActionHooks(lifecycleContext).catch((err: unknown) => {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`TaskEntityServer: action hook dispatch error for task ${this.ID}: ${msg}`);
        });

        return true;
    }

    /**
     * Synchronizes TaskTypeStatusID and MacroStatus before saving.
     */
    private async syncTaskTypeStatusPreSave(): Promise<void> {
        const isNew = !this.IsSaved;
        const typeStatusField = this.Fields.find(f => f.CodeName === 'TaskTypeStatusID');
        const typeStatusDirty = typeStatusField?.Dirty ?? false;

        if (this.TaskTypeStatusID && (typeStatusDirty || isNew)) {
            const statusRecord = await this.loadTaskTypeStatus(this.TaskTypeStatusID);
            if (statusRecord) {
                this.Status = statusRecord.MacroStatus;
                if (statusRecord.IsTerminal) {
                    if (!this.CompletedAt) {
                        this.CompletedAt = new Date();
                    }
                    if (this.PercentComplete !== 100) {
                        this.PercentComplete = 100;
                    }
                }
            }
        } else if (isNew && !this.TaskTypeStatusID && this.TypeID) {
            const defaultStatus = await this.loadDefaultTaskTypeStatus(this.TypeID);
            if (defaultStatus) {
                this.TaskTypeStatusID = defaultStatus.ID;
                this.Status = defaultStatus.MacroStatus;
                if (defaultStatus.IsTerminal) {
                    if (!this.CompletedAt) {
                        this.CompletedAt = new Date();
                    }
                    if (this.PercentComplete !== 100) {
                        this.PercentComplete = 100;
                    }
                }
            }
        }
    }

    /**
     * Captures a snapshot of entity changes prior to saving.
     */
    private captureLifecycleContext(): TaskLifecycleContext {
        const statusField = this.Fields.find(f => f.CodeName === 'Status');
        const typeStatusField = this.Fields.find(f => f.CodeName === 'TaskTypeStatusID');
        const pctField = this.Fields.find(f => f.CodeName === 'PercentComplete');
        const priorityField = this.Fields.find(f => f.CodeName === 'Priority');
        const dueField = this.Fields.find(f => f.CodeName === 'DueAt');

        return {
            isNew: !this.IsSaved,
            statusChanged: statusField?.Dirty ?? false,
            typeStatusChanged: typeStatusField?.Dirty ?? false,
            pctChanged: pctField?.Dirty ?? false,
            priorityChanged: priorityField?.Dirty ?? false,
            dueChanged: dueField?.Dirty ?? false,
            oldStatus: (statusField?.OldValue as mjBizAppsTasksTaskEntity['Status']) ?? null,
            newStatus: this.Status,
            oldTypeStatusID: (typeStatusField?.OldValue as string) ?? null,
            newTypeStatusID: this.TaskTypeStatusID,
            oldPct: (pctField?.OldValue as number) ?? null,
            newPct: this.PercentComplete,
            oldPriority: (priorityField?.OldValue as mjBizAppsTasksTaskEntity['Priority']) ?? null,
            newPriority: this.Priority,
            oldDue: (dueField?.OldValue as Date) ?? null,
            newDue: this.DueAt,
            typeID: this.TypeID,
        };
    }

    /**
     * Writes server-side audit log entries for task mutations.
     */
    private async logActivities(ctx: TaskLifecycleContext): Promise<void> {
        const taskID = this.ID;

        if (ctx.isNew) {
            await this.logActivity(taskID, 'Created', `Task created: ${this.Name}`);
        }
        if (ctx.statusChanged && !ctx.isNew) {
            await this.logActivity(
                taskID,
                'StatusChange',
                `Status changed from ${ctx.oldStatus} to ${this.Status}`,
                ctx.oldStatus ?? undefined,
                this.Status
            );
        }
        if (ctx.typeStatusChanged && !ctx.isNew) {
            await this.logActivity(
                taskID,
                'StatusChange',
                `Task stage updated`,
                ctx.oldTypeStatusID ?? undefined,
                this.TaskTypeStatusID ?? undefined
            );
        }
        if (ctx.pctChanged && !ctx.isNew) {
            await this.logActivity(
                taskID,
                'PercentCompleteChanged',
                `Progress updated to ${this.PercentComplete}%`,
                String(ctx.oldPct ?? 0),
                String(this.PercentComplete ?? 0)
            );
        }
        if (ctx.priorityChanged && !ctx.isNew) {
            await this.logActivity(
                taskID,
                'PriorityChanged',
                `Priority changed from ${ctx.oldPriority} to ${this.Priority}`,
                ctx.oldPriority ?? undefined,
                this.Priority
            );
        }
        if (ctx.dueChanged && !ctx.isNew) {
            await this.logActivity(
                taskID,
                'DueDateChanged',
                `Due date changed`,
                String(ctx.oldDue ?? ''),
                String(this.DueAt ?? '')
            );
        }
        if (ctx.statusChanged && this.Status === 'Completed') {
            await this.logActivity(taskID, 'Completed', `Task completed: ${this.Name}`);
        }
    }

    private async logActivity(
        taskID: string,
        activityType: mjBizAppsTasksTaskActivityEntity['ActivityType'],
        description: string,
        previousValue?: string,
        newValue?: string,
    ): Promise<void> {
        const md = new Metadata();
        const activity = await md.GetEntityObject<mjBizAppsTasksTaskActivityEntity>(
            'MJ_BizApps_Tasks: Task Activities',
            this.ContextCurrentUser
        );
        activity.NewRecord();
        activity.TaskID = taskID;
        activity.ActivityType = activityType;
        activity.Description = description;
        if (previousValue != null) activity.PreviousValue = previousValue;
        if (newValue != null) activity.NewValue = newValue;
        await activity.Save();
    }

    /**
     * Dispatches configured lifecycle action hooks asynchronously after commit.
     */
    public async dispatchLifecycleActionHooks(ctx: TaskLifecycleContext): Promise<void> {
        if (!this.ContextCurrentUser || !ctx.typeID) {
            return;
        }

        const taskType = await this.loadTaskType(ctx.typeID);
        if (!taskType) return;

        let currentTypeStatusCode: string | null = null;
        if (this.TaskTypeStatusID) {
            const currentStatusEntity = await this.loadTaskTypeStatus(this.TaskTypeStatusID);
            currentTypeStatusCode = currentStatusEntity?.Code ?? null;
        }

        // 1. OnCreate hook
        if (ctx.isNew && taskType.OnCreateActionID) {
            await this.invokeAction(
                taskType.OnCreateActionID,
                'OnCreate',
                taskType.Code,
                currentTypeStatusCode,
                null
            );
        }

        // 2. OnStatusChange hook (macro or type status changed)
        if ((ctx.statusChanged || ctx.typeStatusChanged) && !ctx.isNew && taskType.OnStatusChangeActionID) {
            await this.invokeAction(
                taskType.OnStatusChangeActionID,
                'OnStatusChange',
                taskType.Code,
                currentTypeStatusCode,
                ctx.oldStatus
            );
        }

        // 3. OnExitStatus hook (when exiting an old TaskTypeStatus)
        if (ctx.typeStatusChanged && ctx.oldTypeStatusID) {
            const oldStatusRecord = await this.loadTaskTypeStatus(ctx.oldTypeStatusID);
            if (oldStatusRecord?.OnExitActionID) {
                await this.invokeAction(
                    oldStatusRecord.OnExitActionID,
                    'OnExitStatus',
                    taskType.Code,
                    oldStatusRecord.Code,
                    ctx.oldStatus
                );
            }
        }

        // 4. OnEnterStatus hook (when entering a new TaskTypeStatus)
        if (ctx.typeStatusChanged && ctx.newTypeStatusID) {
            const newStatusRecord = await this.loadTaskTypeStatus(ctx.newTypeStatusID);
            if (newStatusRecord?.OnEnterActionID) {
                await this.invokeAction(
                    newStatusRecord.OnEnterActionID,
                    'OnEnterStatus',
                    taskType.Code,
                    newStatusRecord.Code,
                    ctx.oldStatus
                );
            }
        }

        // 5. Specific status milestone hooks
        if (ctx.statusChanged && this.Status === 'Completed' && taskType.OnCompleteActionID) {
            await this.invokeAction(
                taskType.OnCompleteActionID,
                'OnComplete',
                taskType.Code,
                currentTypeStatusCode,
                ctx.oldStatus
            );
        }

        if (ctx.statusChanged && this.Status === 'Cancelled') {
            // A cancellation driven by a Rejected decision is a rejection and fires
            // OnReject (e.g. "return the source record to Draft"); a plain cancel
            // fires OnCancel. Never both, and Blocked never fires OnReject.
            const rejected = await this.taskHasRejectedDecision();
            if (rejected) {
                if (taskType.OnRejectActionID) {
                    await this.invokeAction(
                        taskType.OnRejectActionID,
                        'OnReject',
                        taskType.Code,
                        currentTypeStatusCode,
                        ctx.oldStatus
                    );
                }
            } else if (taskType.OnCancelActionID) {
                await this.invokeAction(
                    taskType.OnCancelActionID,
                    'OnCancel',
                    taskType.Code,
                    currentTypeStatusCode,
                    ctx.oldStatus
                );
            }
        }

        // 6. OnPercentChange hook
        if (ctx.pctChanged && !ctx.isNew && taskType.OnPercentChangeActionID) {
            await this.invokeAction(
                taskType.OnPercentChangeActionID,
                'OnPercentChange',
                taskType.Code,
                currentTypeStatusCode,
                ctx.oldStatus
            );
        }
    }

    /**
     * Executes a configured Action using ActionEngineServer with the universal task payload.
     */
    public async invokeAction(
        actionID: string,
        hookType: TaskActionHookType,
        taskTypeCode: string,
        taskTypeStatusCode: string | null,
        previousStatus: string | null
    ): Promise<TaskActionHookResult> {
        const contextUser = this.ContextCurrentUser;
        if (!contextUser) return { Invoked: false };

        const taskName = this.Name;
        try {
            await ActionEngineServer.Instance.Config(false, contextUser);
            const action = ActionEngineServer.Instance.Actions.find(a => a.ID === actionID);
            if (!action) {
                const msg = `Action ${actionID} not found for hook ${hookType}`;
                LogError(`[BizAppsTasks] ${msg}`);
                return { Invoked: false, Message: msg };
            }

            const recordBag = this.GetAll();
            const payloadObject = {
                taskID: this.ID,
                taskName: this.Name,
                taskTypeCode,
                taskTypeStatusID: this.TaskTypeStatusID,
                taskTypeStatusCode,
                status: this.Status,
                previousStatus,
                percentComplete: this.PercentComplete,
                priority: this.Priority,
                dueAt: this.DueAt,
                record: recordBag,
            };

            const result = await ActionEngineServer.Instance.RunAction({
                Action: action,
                ContextUser: contextUser,
                Params: [
                    { Name: 'TaskID', Value: this.ID, Type: 'Input' },
                    { Name: 'RecordID', Value: this.ID, Type: 'Input' },
                    { Name: 'TaskName', Value: this.Name, Type: 'Input' },
                    { Name: 'TaskTypeCode', Value: taskTypeCode, Type: 'Input' },
                    { Name: 'TaskTypeStatusID', Value: this.TaskTypeStatusID, Type: 'Input' },
                    { Name: 'TaskTypeStatusCode', Value: taskTypeStatusCode ?? '', Type: 'Input' },
                    { Name: 'Status', Value: this.Status, Type: 'Input' },
                    { Name: 'PreviousStatus', Value: previousStatus ?? '', Type: 'Input' },
                    { Name: 'PercentComplete', Value: this.PercentComplete, Type: 'Input' },
                    { Name: 'Priority', Value: this.Priority, Type: 'Input' },
                    { Name: 'DueAt', Value: this.DueAt, Type: 'Input' },
                    { Name: 'TaskRecord', Value: recordBag, Type: 'Input' },
                    { Name: 'Payload', Value: JSON.stringify(payloadObject), Type: 'Input' },
                    // Generic utility action compatibility bindings
                    { Name: 'Expression', Value: `${this.PercentComplete || 100} * 1`, Type: 'Input' },
                    { Name: 'Color', Value: '#2563eb', Type: 'Input' },
                    { Name: 'Text', Value: this.Name, Type: 'Input' },
                    { Name: 'Input', Value: this.Name, Type: 'Input' },
                ],
                Filters: [],
            });

            const success = Array.isArray(result) ? result.every(r => r.Success) : result?.Success === true;
            const message = Array.isArray(result) ? result.map(r => r.Message).filter(Boolean).join('; ') : result?.Message ?? undefined;

            if (success) {
                LogStatus(`[BizAppsTasks] Invoked ${hookType} action "${action.Name}" for task "${taskName}"`);
            } else {
                LogError(`[BizAppsTasks] ${hookType} action "${action.Name}" for task "${taskName}" failed: ${message ?? 'no message'}`);
            }
            return { Invoked: true, Success: success, Message: message };
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`[BizAppsTasks] Error invoking ${hookType} action ${actionID}: ${msg}`);
            return { Invoked: true, Success: false, Message: msg };
        }
    }

    /**
     * Returns true when this task has a TaskDecision with the 'Rejected' outcome.
     * Used to distinguish a rejection from a plain cancellation when routing the
     * OnReject vs. OnCancel hooks.
     *
     * Resolves the rejected outcome by its stable Code, then matches decisions by
     * OutcomeID — so renaming the outcome's display Name doesn't break routing.
     */
    protected async taskHasRejectedDecision(): Promise<boolean> {
        const rv = new RunView();
        const outcomeResult = await rv.RunView<{ ID: string }>({
            EntityName: 'MJ_BizApps_Tasks: Task Decision Outcomes',
            ExtraFilter: `Code = 'Rejected'`,
            Fields: ['ID'],
            ResultType: 'simple',
            MaxRows: 1,
        }, this.ContextCurrentUser);
        const rejectedOutcomeID = outcomeResult?.Results?.[0]?.ID;
        if (!rejectedOutcomeID) return false;

        const result = await rv.RunView<{ ID: string }>({
            EntityName: 'MJ_BizApps_Tasks: Task Decisions',
            ExtraFilter: `TaskID = '${this.ID}' AND OutcomeID = '${rejectedOutcomeID}'`,
            Fields: ['ID'],
            ResultType: 'simple',
            MaxRows: 1,
        }, this.ContextCurrentUser);
        return (result?.Results?.length ?? 0) > 0;
    }

    /**
     * Loads a TaskTypeStatus entity by ID.
     */
    protected async loadTaskTypeStatus(statusID: string): Promise<mjBizAppsTasksTaskTypeStatusEntity | null> {
        const md = new Metadata();
        const statusEntity = await md.GetEntityObject<mjBizAppsTasksTaskTypeStatusEntity>(
            'MJ_BizApps_Tasks: Task Type Status',
            this.ContextCurrentUser
        );
        const loaded = await statusEntity.Load(statusID);
        return loaded ? statusEntity : null;
    }

    /**
     * Loads the default TaskTypeStatus for a given TaskType.
     */
    protected async loadDefaultTaskTypeStatus(typeID: string): Promise<mjBizAppsTasksTaskTypeStatusEntity | null> {
        const rv = new RunView();
        const result = await rv.RunView<mjBizAppsTasksTaskTypeStatusEntity>({
            EntityName: 'MJ_BizApps_Tasks: Task Type Status',
            ExtraFilter: `TaskTypeID='${typeID}' AND IsDefault=1 AND IsActive=1`,
            ResultType: 'entity_object',
            MaxRows: 1,
        }, this.ContextCurrentUser);
        return result?.Results?.[0] ?? null;
    }

    /**
     * Loads a TaskType entity by ID.
     */
    protected async loadTaskType(typeID: string): Promise<mjBizAppsTasksTaskTypeEntity | null> {
        const md = new Metadata();
        const typeEntity = await md.GetEntityObject<mjBizAppsTasksTaskTypeEntity>(
            'MJ_BizApps_Tasks: Task Types',
            this.ContextCurrentUser
        );
        const loaded = await typeEntity.Load(typeID);
        return loaded ? typeEntity : null;
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

            const parentID = this.ParentID;
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
