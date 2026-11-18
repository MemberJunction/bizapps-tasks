import { CompositeKey, Metadata, RunView, UserInfo } from "@memberjunction/core";
import type {
    mjBizAppsTasksTaskActivityEntity,
    mjBizAppsTasksTaskEntity,
} from "@mj-biz-apps/tasks-entities";

/**
 * Projection shape returned by RunView('simple') when rolling up child tasks.
 */
export interface TaskRollupChildRow {
    ID?: string;
    PercentComplete?: number | null;
    HoursEstimated?: number | null;
    RollupWeight?: number | null;
    Status?: mjBizAppsTasksTaskEntity['Status'] | null;
    HealthStatus?: mjBizAppsTasksTaskEntity['HealthStatus'];
    ConfidenceScore?: number | null;
}

/**
 * Core task management service.
 * Handles task CRUD helpers, status transitions, OKR/priority metric calculations,
 * and sub-task progress & health rollup.
 *
 * All methods operate through the MJ entity API so that entity subclass
 * validation (status side-effects, circular-dependency checks, etc.) fires
 * automatically.
 */
export class TaskService {

    // ---------------------------------------------------------------
    // Sub-task & OKR Key Result progress rollup
    // ---------------------------------------------------------------

    /**
     * Recalculates a parent task's PercentComplete (and optional OKR HealthStatus /
     * ConfidenceScore) based on its children.
     *
     * Weighting: explicit RollupWeight (when != 1 or when HoursEstimated is absent),
     * otherwise HoursEstimated if > 0, otherwise equal weight (1).
     * Recurses up the tree so grandparent objectives also update.
     */
    async rollupParentProgress(parentTaskID: string, contextUser?: UserInfo): Promise<void> {
        const rv = new RunView();
        const children = await rv.RunView<TaskRollupChildRow>({
            EntityName: 'MJ_BizApps_Tasks: Tasks',
            ExtraFilter: `ParentID = '${parentTaskID}'`,
            ResultType: 'simple',
        }, contextUser);

        if (!children?.Results?.length) return;

        let totalWeight = 0;
        let weightedSum = 0;
        let allCompleted = true;

        let confidenceWeightSum = 0;
        let confidenceWeightedTotal = 0;
        const childHealthStatuses: NonNullable<mjBizAppsTasksTaskEntity['HealthStatus']>[] = [];

        for (const child of children.Results) {
            const pct = child.PercentComplete ?? 0;
            const weight = TaskService.resolveChildRollupWeight(child);

            weightedSum += pct * weight;
            totalWeight += weight;

            if (child.Status !== 'Completed') {
                allCompleted = false;
            }

            if (child.HealthStatus != null) {
                childHealthStatuses.push(child.HealthStatus);
            }
            if (child.ConfidenceScore != null) {
                confidenceWeightedTotal += child.ConfidenceScore * weight;
                confidenceWeightSum += weight;
            }
        }

        const newPct = totalWeight > 0 ? Math.round(weightedSum / totalWeight) : 0;
        const aggregatedHealth = TaskService.aggregateChildHealthStatus(childHealthStatuses, allCompleted);
        const aggregatedConfidence = confidenceWeightSum > 0
            ? Math.round(confidenceWeightedTotal / confidenceWeightSum)
            : null;

        // Load the parent task as a strongly-typed entity to trigger subclass validation
        const parentTask = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(
            'MJ_BizApps_Tasks: Tasks',
            contextUser
        );
        const pk = new CompositeKey([{ FieldName: 'ID', Value: parentTaskID }]);
        await parentTask.InnerLoad(pk);

        const currentPct = parentTask.PercentComplete;
        const shouldComplete = allCompleted && parentTask.Status !== 'Completed';
        const currentHealth = parentTask.HealthStatus;
        const currentConfidence = parentTask.ConfidenceScore;

        const healthChanged = aggregatedHealth != null && currentHealth !== aggregatedHealth;
        const confidenceChanged = aggregatedConfidence != null && currentConfidence !== aggregatedConfidence;

        // Only write when something actually changes — this also prevents the
        // server save-event handler from re-triggering rollup in an infinite loop.
        if (currentPct === newPct && !shouldComplete && !healthChanged && !confidenceChanged) {
            return;
        }

        parentTask.PercentComplete = newPct;
        if (shouldComplete) {
            parentTask.Status = 'Completed';
        }
        if (healthChanged) {
            parentTask.HealthStatus = aggregatedHealth;
        }
        if (confidenceChanged) {
            parentTask.ConfidenceScore = aggregatedConfidence;
        }

        await parentTask.Save();

        // Recurse up the tree
        const grandParentID = parentTask.ParentID;
        if (grandParentID) {
            await this.rollupParentProgress(grandParentID, contextUser);
        }
    }

    /**
     * Resolves the effective rollup weight for a child task or key result.
     */
    public static resolveChildRollupWeight(child: TaskRollupChildRow): number {
        const rollupWeight = child.RollupWeight != null ? Number(child.RollupWeight) : null;
        const hours = child.HoursEstimated != null ? Number(child.HoursEstimated) : null;

        if (rollupWeight != null && rollupWeight > 0 && (rollupWeight !== 1 || !(hours != null && hours > 0))) {
            return rollupWeight;
        }
        if (hours != null && hours > 0) {
            return hours;
        }
        return 1;
    }

    /**
     * Determines worst-case / rolled-up health status across child key results.
     */
    public static aggregateChildHealthStatus(
        statuses: NonNullable<mjBizAppsTasksTaskEntity['HealthStatus']>[],
        allCompleted: boolean
    ): mjBizAppsTasksTaskEntity['HealthStatus'] {
        if (statuses.length === 0) {
            return null;
        }
        if (allCompleted || statuses.every(s => s === 'Completed')) {
            return 'Completed';
        }
        if (statuses.includes('OffTrack')) {
            return 'OffTrack';
        }
        if (statuses.includes('AtRisk')) {
            return 'AtRisk';
        }
        if (statuses.includes('OnTrack')) {
            return 'OnTrack';
        }
        return statuses[0];
    }

    /**
     * Computes quantitative PercentComplete (0-100) from BaselineValue, TargetValue,
     * CurrentValue, and MetricDirection.
     */
    public static computeQuantitativePercentComplete(
        baselineValue: number | null | undefined,
        targetValue: number | null | undefined,
        currentValue: number | null | undefined,
        direction: mjBizAppsTasksTaskEntity['MetricDirection']
    ): number | null {
        if (targetValue == null || currentValue == null) {
            return null;
        }
        const baseline = baselineValue ?? 0;
        const effectiveDirection = direction ?? 'Increase';

        if (effectiveDirection === 'Maintain') {
            return currentValue === targetValue ? 100 : 0;
        }

        if (effectiveDirection === 'Decrease') {
            const span = baseline - targetValue;
            if (span <= 0) {
                return currentValue <= targetValue ? 100 : 0;
            }
            const progress = ((baseline - currentValue) / span) * 100;
            return Math.max(0, Math.min(100, Math.round(progress)));
        }

        // Default: 'Increase'
        const span = targetValue - baseline;
        if (span <= 0) {
            return currentValue >= targetValue ? 100 : 0;
        }
        const progress = ((currentValue - baseline) / span) * 100;
        return Math.max(0, Math.min(100, Math.round(progress)));
    }

    /**
     * Computes the next check-in due timestamp from a base check-in timestamp and cadence.
     */
    public static computeNextCheckInDueAt(
        fromDate: Date,
        cadence: mjBizAppsTasksTaskEntity['CheckInCadence']
    ): Date | null {
        if (!cadence || cadence === 'None') {
            return null;
        }
        const next = new Date(fromDate.getTime());
        switch (cadence) {
            case 'Daily':
                next.setUTCDate(next.getUTCDate() + 1);
                return next;
            case 'Weekly':
                next.setUTCDate(next.getUTCDate() + 7);
                return next;
            case 'BiWeekly':
                next.setUTCDate(next.getUTCDate() + 14);
                return next;
            case 'Monthly':
                next.setUTCMonth(next.getUTCMonth() + 1);
                return next;
            case 'Quarterly':
                next.setUTCMonth(next.getUTCMonth() + 3);
                return next;
            default:
                return null;
        }
    }

    // ---------------------------------------------------------------
    // Activity logging
    // ---------------------------------------------------------------

    /**
     * Creates a TaskActivity record for an auditable change.
     * Called from entity subclass hooks or service methods after a save.
     */
    async logActivity(params: {
        taskID: string;
        personID?: string;
        activityType: mjBizAppsTasksTaskActivityEntity['ActivityType'];
        previousValue?: string;
        newValue?: string;
        description: string;
    }, contextUser?: UserInfo): Promise<void> {
        const activity = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskActivityEntity>(
            'MJ_BizApps_Tasks: Task Activities',
            contextUser
        );
        activity.NewRecord();
        activity.TaskID = params.taskID;
        if (params.personID) activity.PersonID = params.personID;
        activity.ActivityType = params.activityType;
        if (params.previousValue) activity.PreviousValue = params.previousValue;
        if (params.newValue) activity.NewValue = params.newValue;
        activity.Description = params.description;
        await activity.Save();
    }
}
