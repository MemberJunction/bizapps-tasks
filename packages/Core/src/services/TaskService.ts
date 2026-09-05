import { BaseEntity, CompositeKey, LogError, Metadata, RunView, UserInfo } from "@memberjunction/core";

/**
 * Core task management service.
 * Handles task CRUD helpers, status transitions, and sub-task progress rollup.
 *
 * All methods operate through the MJ entity API so that entity subclass
 * validation (status side-effects, circular-dependency checks, etc.) fires
 * automatically.
 */
export class TaskService {

    // ---------------------------------------------------------------
    // Sub-task progress rollup
    // ---------------------------------------------------------------

    /**
     * Recalculates a parent task's PercentComplete based on its children.
     * Weighting: by HoursEstimated if available, equal weight otherwise.
     * Recurses up the tree so grandparent tasks also update.
     *
     * Call this after saving a child task whose PercentComplete or Status changed.
     */
    async rollupParentProgress(parentTaskID: string, contextUser?: UserInfo): Promise<void> {
        const rv = new RunView();
        const children = await rv.RunView<BaseEntity>({
            EntityName: 'MJ_BizApps_Tasks: Tasks',
            ExtraFilter: `ParentID = '${parentTaskID}'`,
            ResultType: 'simple',
        }, contextUser);

        if (!children?.Results?.length) return;

        let totalWeight = 0;
        let weightedSum = 0;
        let allCompleted = true;

        for (const child of children.Results) {
            const pct = (child as any).PercentComplete as number ?? 0;
            const hours = (child as any).HoursEstimated as number | null;
            const weight = hours != null && hours > 0 ? hours : 1;

            weightedSum += pct * weight;
            totalWeight += weight;

            if ((child as any).Status !== 'Completed') {
                allCompleted = false;
            }
        }

        const newPct = totalWeight > 0 ? Math.round(weightedSum / totalWeight) : 0;

        // Load the parent task as an entity to trigger subclass validation
        const parentTask = await Metadata.Provider.GetEntityObject('MJ_BizApps_Tasks: Tasks', contextUser);
        const pk = new CompositeKey([{ FieldName: 'ID', Value: parentTaskID }]);
        await parentTask.InnerLoad(pk);

        const currentPct = parentTask.Get('PercentComplete') as number;
        const shouldComplete = allCompleted && parentTask.Get('Status') !== 'Completed';

        // Only write when something actually changes — this also prevents the
        // server save-event handler from re-triggering rollup in an infinite loop.
        if (currentPct === newPct && !shouldComplete) {
            return;
        }

        parentTask.Set('PercentComplete', newPct);
        if (shouldComplete) {
            parentTask.Set('Status', 'Completed');
        }

        const saved = await parentTask.Save();
        if (!saved) {
            LogError(`TaskService.rollupParentProgress: failed to save parent task ${parentTaskID}: ${parentTask.LatestResult?.CompleteMessage ?? 'unknown error'}`);
            return; // parent unchanged — recursing on stale data would be misleading
        }

        // Recurse up the tree
        const grandParentID = parentTask.Get('ParentID') as string | null;
        if (grandParentID) {
            await this.rollupParentProgress(grandParentID, contextUser);
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
        activityType: string;
        previousValue?: string;
        newValue?: string;
        description: string;
    }, contextUser?: UserInfo): Promise<void> {
        const activity = await Metadata.Provider.GetEntityObject('MJ_BizApps_Tasks: Task Activities', contextUser);
        activity.NewRecord();
        activity.Set('TaskID', params.taskID);
        if (params.personID) activity.Set('PersonID', params.personID);
        activity.Set('ActivityType', params.activityType);
        if (params.previousValue) activity.Set('PreviousValue', params.previousValue);
        if (params.newValue) activity.Set('NewValue', params.newValue);
        activity.Set('Description', params.description);
        const saved = await activity.Save();
        if (!saved) {
            LogError(`TaskService.logActivity: failed to save '${params.activityType}' activity for task ${params.taskID}: ${activity.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }
    }
}
