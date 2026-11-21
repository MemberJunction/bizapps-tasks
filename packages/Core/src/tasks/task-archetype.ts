import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';

/**
 * UI archetype resolved from a Task's `TaskType` (Code / Name / IsApproval)
 * and quantitative OKR fields. Drives progressive disclosure on the Express
 * Create Drawer and the Adaptive Spotlight Strip on the full Task Record Form.
 */
export type TaskUiArchetype =
    | 'general'
    | 'action-item'
    | 'follow-up'
    | 'deliverable'
    | 'approval'
    | 'key-result';

/** Minimal TaskType metadata used for archetype resolution. */
export interface TaskTypeArchetypeInput {
    Code?: string | null;
    Name?: string | null;
    IsApproval?: boolean | null;
}

/** Minimal Task signals used to determine archetype & spotlight visibility. */
export interface TaskSpotlightContext {
    Status: mjBizAppsTasksTaskEntity['Status'];
    DueAt?: Date | string | null;
    HoursEstimated?: number | null;
    HoursActual?: number | null;
    BaselineValue?: number | null;
    TargetValue?: number | null;
    CurrentValue?: number | null;
    HealthStatus?: mjBizAppsTasksTaskEntity['HealthStatus'];
    PredictedSLARiskBand?: mjBizAppsTasksTaskEntity['PredictedSLARiskBand'];
    PredictedSLABreachProbability?: number | null;
    BlockedReason?: string | null;
}

/**
 * Resolves the UI archetype for a TaskType (and optional Task metric fields).
 * Deterministic and case-insensitive on `Code` and `Name`.
 */
export function ResolveTaskUiArchetype(
    taskType: TaskTypeArchetypeInput | null | undefined,
    task?: Partial<TaskSpotlightContext> | null,
): TaskUiArchetype {
    if (taskType?.IsApproval) {
        return 'approval';
    }

    const code = (taskType?.Code ?? '').trim().toUpperCase();
    const name = (taskType?.Name ?? '').trim().toLowerCase();

    if (code === 'APPROVAL_REQUEST' || code === 'APPROVAL' || name.includes('approval')) {
        return 'approval';
    }
    if (
        code === 'KEY_RESULT' ||
        code === 'OKR' ||
        code === 'OBJECTIVE' ||
        name.includes('key result') ||
        name.includes('okr')
    ) {
        return 'key-result';
    }
    if (code === 'DELIVERABLE' || name.includes('deliverable') || name.includes('milestone')) {
        return 'deliverable';
    }
    if (code === 'ACTION_ITEM' || name.includes('action item')) {
        return 'action-item';
    }
    if (code === 'FOLLOW_UP' || name.includes('follow-up') || name.includes('follow up')) {
        return 'follow-up';
    }

    // Fall back to OKR archetype when quantitative metric targets are populated on a task
    if (task && (task.TargetValue != null || task.HealthStatus != null)) {
        return 'key-result';
    }

    return 'general';
}

/**
 * Determines whether the Task Form Adaptive Spotlight Strip should render.
 *
 * Golden Hybrid progressive-disclosure invariant:
 * Plain **General** tasks with no blocker, no SLA risk, and no quantitative
 * metric MUST collapse the spotlight completely (`false` → `0px` chrome).
 */
export function ShouldShowAdaptiveSpotlight(
    archetype: TaskUiArchetype,
    task: TaskSpotlightContext,
    blockingDependencyCount: number = 0,
): boolean {
    if (archetype === 'approval' || archetype === 'key-result') {
        return true;
    }

    const hasBlocker =
        task.Status === 'Blocked' ||
        Boolean(task.BlockedReason?.trim()) ||
        blockingDependencyCount > 0;
    const hasHighSlaRisk =
        task.PredictedSLARiskBand === 'Critical' ||
        task.PredictedSLARiskBand === 'High' ||
        (task.PredictedSLABreachProbability != null && task.PredictedSLABreachProbability >= 0.65);

    if (archetype === 'deliverable') {
        return hasBlocker || hasHighSlaRisk || (task.HoursEstimated != null && task.HoursEstimated > 0);
    }

    if (archetype === 'action-item' || archetype === 'follow-up') {
        const isActive = task.Status !== 'Completed' && task.Status !== 'Cancelled';
        const due = task.DueAt ? (task.DueAt instanceof Date ? task.DueAt : new Date(task.DueAt)) : null;
        const isOverdue = isActive && due != null && !Number.isNaN(due.getTime()) && due.getTime() < Date.now();
        return hasBlocker || hasHighSlaRisk || isOverdue;
    }

    // General task: only surface spotlight if actively blocked or high SLA risk — otherwise 0px calm!
    return hasBlocker || hasHighSlaRisk;
}
