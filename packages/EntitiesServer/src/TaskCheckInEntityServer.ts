import {
    BaseEntity,
    EntitySaveOptions,
    LogError,
    Metadata,
} from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import {
    mjBizAppsTasksTaskCheckInEntity,
    mjBizAppsTasksTaskEntity,
} from '@mj-biz-apps/tasks-entities';
import { TaskService } from '@mj-biz-apps/tasks-core';

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
 *      (which in turn triggers parent objective rollup).
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Check Ins')
export class TaskCheckInEntityServer extends mjBizAppsTasksTaskCheckInEntity {
    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
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
            return false;
        }

        // 3. Roll up check-in state to the parent Task
        if (parentTask) {
            try {
                await this.syncCheckInToParentTask(parentTask);
            } catch (err) {
                const msg = err instanceof Error ? err.message : String(err);
                LogError(`TaskCheckInEntityServer: failed to sync check-in ${this.ID} to task ${this.TaskID}: ${msg}`);
            }
        }

        return true;
    }

    protected async loadParentTask(): Promise<mjBizAppsTasksTaskEntity | null> {
        if (!this.TaskID) {
            return null;
        }
        const md = new Metadata();
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

        await task.Save();
    }
}
