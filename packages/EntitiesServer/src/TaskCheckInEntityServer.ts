import {
    BaseEntity,
    EntitySaveOptions,
    EntityTransactionScope,
    IEntityDataProvider,
    IMetadataProvider,
    LogError,
    Metadata,
} from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import {
    mjBizAppsTasksTaskCheckInEntity,
    mjBizAppsTasksTaskEntity,
} from '@mj-biz-apps/tasks-entities';
import { TaskService } from '@mj-biz-apps/tasks-core';
import { IsCheckInInParentTaskGraph } from './composite-graph-scope.js';

interface TransactionalEntityProvider extends IEntityDataProvider {
    SupportsEntityTransactions: true;
    BeginEntityTransaction(): Promise<EntityTransactionScope>;
}

function isTransactionalProvider(provider: IEntityDataProvider | null | undefined): provider is TransactionalEntityProvider {
    const candidate = provider as Partial<IEntityDataProvider> | null | undefined;
    return candidate?.SupportsEntityTransactions === true && typeof candidate.BeginEntityTransaction === 'function';
}

function resolveMetadataProvider(provider: IEntityDataProvider | null | undefined): IMetadataProvider {
    const candidate = provider as Partial<IMetadataProvider> | null | undefined;
    return typeof candidate?.GetEntityObject === 'function' ? (candidate as IMetadataProvider) : Metadata.Provider;
}

/**
 * Server-side subclass of {@link mjBizAppsTasksTaskCheckInEntity}.
 *
 * When a TaskCheckIn is saved (by a user or an AI agent such as Chief of Staff),
 * this server subclass:
 *   1. Captures the parent Task's prior CurrentValue into PreviousValue if omitted.
 *   2. Computes quantitative PercentComplete from BaselineValue / TargetValue / NewValue
 *      when PercentComplete is omitted on the check-in.
 *   3. Propagates HealthStatus, ConfidenceScore, CurrentValue, PercentComplete,
 *      LastCheckInAt, and NextCheckInDueAt onto the parent Task and saves it
 *      atomically inside `BeginEntityTransaction()` when saving standalone (skipping the
 *      recursive parent save when already executing inside a parent `Task.CheckIns` composite graph).
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Check Ins')
export class TaskCheckInEntityServer extends mjBizAppsTasksTaskCheckInEntity {
    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        // When saved inside a parent Task's composite `task.CheckIns` graph, TaskEntityServer
        // has already derived PreviousValue/PercentComplete and applied the latest check-in
        // onto the parent Task before writing it — persist only this check-in row without
        // triggering a redundant recursive parentTask.Save().
        if (IsCheckInInParentTaskGraph(this.TaskID, this)) {
            return super.Save(options);
        }

        const provider = this.ProviderToUse;
        const txScope = isTransactionalProvider(provider)
            ? await provider.BeginEntityTransaction()
            : null;

        try {
            const parentTask = await this.loadParentTask();

            // 1. Pre-save defaults derived from parent task
            if (parentTask) {
                if (this.PreviousValue == null && parentTask.CurrentValue != null) {
                    this.PreviousValue = parentTask.CurrentValue;
                }
                if (this.PercentComplete == null && this.NewValue != null && parentTask.TargetValue != null) {
                    const computedPct = TaskService.computeQuantitativePercentComplete(
                        parentTask.BaselineValue,
                        parentTask.TargetValue,
                        this.NewValue,
                        parentTask.MetricDirection
                    );
                    if (computedPct != null) {
                        this.PercentComplete = computedPct;
                    }
                }
            }

            // 2. Persist the TaskCheckIn record
            const saved = await super.Save(options);
            if (!saved) {
                if (txScope) {
                    await txScope.Rollback();
                }
                return false;
            }

            // 3. Roll up check-in state to the parent Task inside the same transaction
            if (parentTask) {
                if (txScope) {
                    await this.syncCheckInToParentTask(parentTask);
                } else {
                    try {
                        await this.syncCheckInToParentTask(parentTask);
                    } catch (err) {
                        const msg = err instanceof Error ? err.message : String(err);
                        LogError(`TaskCheckInEntityServer: failed to sync check-in ${this.ID} to task ${this.TaskID}: ${msg}`);
                    }
                }
            }

            if (txScope) {
                await txScope.Commit();
            }
            return true;
        } catch (err) {
            if (txScope) {
                await txScope.Rollback();
            }
            throw err;
        }
    }

    protected async loadParentTask(): Promise<mjBizAppsTasksTaskEntity | null> {
        if (!this.TaskID) {
            return null;
        }
        const md = resolveMetadataProvider(this.ProviderToUse);
        const task = await md.GetEntityObject<mjBizAppsTasksTaskEntity>(
            'MJ_BizApps_Tasks: Tasks',
            this.ContextCurrentUser
        );
        const loaded = await task.Load(this.TaskID);
        return loaded ? task : null;
    }

    protected async syncCheckInToParentTask(task: mjBizAppsTasksTaskEntity): Promise<void> {
        const checkInTime = this.CheckInAt ?? new Date();

        task.HealthStatus = this.HealthStatus;
        if (this.ConfidenceScore != null) {
            task.ConfidenceScore = this.ConfidenceScore;
        }
        if (this.NewValue != null) {
            task.CurrentValue = this.NewValue;
        }
        if (this.PercentComplete != null) {
            task.PercentComplete = this.PercentComplete;
        }
        task.LastCheckInAt = checkInTime;

        if (task.CheckInCadence) {
            const nextDue = TaskService.computeNextCheckInDueAt(checkInTime, task.CheckInCadence);
            if (nextDue) {
                task.NextCheckInDueAt = nextDue;
            }
        }

        const parentSaved = await task.Save();
        if (!parentSaved) {
            throw new Error(
                `Failed to sync check-in ${this.ID} to parent task ${this.TaskID}: ${task.LatestResult?.CompleteMessage ?? 'parent task save returned false'}`,
            );
        }
    }
}
