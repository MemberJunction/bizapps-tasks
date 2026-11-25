import type {
    mjBizAppsTasksTaskDependencyEntity,
    mjBizAppsTasksTaskEntity,
} from '@mj-biz-apps/tasks-entities';

/** Minimal task summary needed by L0 workspace classification and rollup helpers. */
export interface TaskWorkspaceSummary {
    ID: string;
    Name: string;
    ParentID?: string | null;
    Status: mjBizAppsTasksTaskEntity['Status'];
    Priority?: mjBizAppsTasksTaskEntity['Priority'];
    DueAt?: Date | string | null;
    StartedAt?: Date | string | null;
    PercentComplete?: number | null;
    IsApproval?: boolean;
    HasPendingDecision?: boolean;
    PredictedSLARiskBand?: mjBizAppsTasksTaskEntity['PredictedSLARiskBand'];
    PredictedSLABreachProbability?: number | null;
    HoursEstimated?: number | null;
    HoursActual?: number | null;
    Sequence?: number | null;
}

/** Action Horizon bucket for the My Work workspace. */
export type TaskActionHorizon =
    | 'needs-decision'
    | 'focus-today'
    | 'blocked-waiting'
    | 'coming-up'
    | 'completed';

/** Non-zero urgency signal counts displayed in the whisper urgency strip. */
export interface TaskUrgencyCounts {
    Overdue: number;
    Blocked: number;
    PendingApprovals: number;
    SlaAtRisk: number;
}

/** Dependency edge used for critical-path calculation. */
export interface TaskDependencyEdge {
    TaskID: string;
    DependsOnTaskID: string;
    DependencyType: mjBizAppsTasksTaskDependencyEntity['DependencyType'];
}

/** Chronological milestone bucket for mobile Gantt replacement. */
export type MilestoneBucketKey = 'overdue' | 'this-week' | 'upcoming' | 'unscheduled' | 'completed';

export interface MilestoneBucket<T extends TaskWorkspaceSummary> {
    Key: MilestoneBucketKey;
    Label: string;
    Tasks: T[];
}

/** Child rollup counts computed per parent task ID. */
export interface TaskChildRollup {
    TotalChildren: number;
    CompletedChildren: number;
    RollupPercent: number;
}

function toDate(value: Date | string | null | undefined): Date | null {
    if (!value) return null;
    const d = value instanceof Date ? value : new Date(value);
    return Number.isNaN(d.getTime()) ? null : d;
}

function startOfLocalDay(d: Date): Date {
    return new Date(d.getFullYear(), d.getMonth(), d.getDate(), 0, 0, 0, 0);
}

/** True when a task is open/active (neither Completed nor Cancelled). */
export function IsTaskActive(status: mjBizAppsTasksTaskEntity['Status']): boolean {
    return status !== 'Completed' && status !== 'Cancelled';
}

/** True when an active task is past its DueAt timestamp. */
export function IsTaskOverdue(
    dueAt: Date | string | null | undefined,
    status: mjBizAppsTasksTaskEntity['Status'],
    now: Date = new Date(),
): boolean {
    if (!IsTaskActive(status)) return false;
    const due = toDate(dueAt);
    return due != null && due.getTime() < now.getTime();
}

/** True when an active task is flagged High or Critical SLA breach risk. */
export function IsTaskSlaAtRisk(task: Pick<TaskWorkspaceSummary, 'Status' | 'PredictedSLARiskBand' | 'PredictedSLABreachProbability'>): boolean {
    if (!IsTaskActive(task.Status)) return false;
    if (task.PredictedSLARiskBand === 'Critical' || task.PredictedSLARiskBand === 'High') {
        return true;
    }
    return task.PredictedSLABreachProbability != null && task.PredictedSLABreachProbability >= 0.65;
}

/**
 * Classifies a task into one of the five My Work Action Horizons:
 * 1. `completed` — Completed or Cancelled
 * 2. `needs-decision` — Active approval task awaiting a decision
 * 3. `blocked-waiting` — Active task in Blocked status
 * 4. `focus-today` — Overdue, due within 48h, InProgress, or Critical priority
 * 5. `coming-up` — Everything else active
 */
export function ClassifyTaskHorizon(task: TaskWorkspaceSummary, now: Date = new Date()): TaskActionHorizon {
    if (!IsTaskActive(task.Status)) {
        return 'completed';
    }
    if (task.IsApproval && task.HasPendingDecision !== false) {
        return 'needs-decision';
    }
    if (task.Status === 'Blocked') {
        return 'blocked-waiting';
    }

    const due = toDate(task.DueAt);
    const horizonCutoff = startOfLocalDay(now).getTime() + 3 * 24 * 60 * 60 * 1000; // today + next 2 days
    const isUrgentDue = due != null && due.getTime() < horizonCutoff;

    if (isUrgentDue || task.Status === 'InProgress' || task.Priority === 'Critical') {
        return 'focus-today';
    }
    return 'coming-up';
}

/**
 * Computes urgency counts across a task list for the whisper urgency bar.
 */
export function ComputeTaskUrgencyCounts(
    tasks: readonly TaskWorkspaceSummary[],
    now: Date = new Date(),
): TaskUrgencyCounts {
    let overdue = 0;
    let blocked = 0;
    let pendingApprovals = 0;
    let slaAtRisk = 0;

    for (const t of tasks) {
        if (!IsTaskActive(t.Status)) continue;
        if (IsTaskOverdue(t.DueAt, t.Status, now)) overdue++;
        if (t.Status === 'Blocked') blocked++;
        if (t.IsApproval && t.HasPendingDecision !== false) pendingApprovals++;
        if (IsTaskSlaAtRisk(t)) slaAtRisk++;
    }

    return {
        Overdue: overdue,
        Blocked: blocked,
        PendingApprovals: pendingApprovals,
        SlaAtRisk: slaAtRisk,
    };
}

/**
 * Computes direct-child completion rollup stats keyed by lower-cased parent task ID.
 */
export function ComputeChildRollups(tasks: readonly TaskWorkspaceSummary[]): Map<string, TaskChildRollup> {
    const groups = new Map<string, TaskWorkspaceSummary[]>();
    for (const t of tasks) {
        if (!t.ParentID) continue;
        const key = t.ParentID.toLowerCase();
        const list = groups.get(key) ?? [];
        list.push(t);
        groups.set(key, list);
    }

    const result = new Map<string, TaskChildRollup>();
    for (const [parentKey, kids] of groups) {
        const completed = kids.filter((k) => k.Status === 'Completed').length;
        const avgPct = Math.round(kids.reduce((sum, k) => sum + (k.PercentComplete ?? 0), 0) / kids.length);
        result.set(parentKey, {
            TotalChildren: kids.length,
            CompletedChildren: completed,
            RollupPercent: avgPct,
        });
    }
    return result;
}

/**
 * Computes the critical path across a set of tasks and dependency edges using
 * longest-duration chain traversal on the DAG (safely cycle-guarded).
 * Returns lower-cased task IDs on the critical chain (empty set if no dependencies exist).
 */
export function ComputeCriticalPathTaskIds(
    tasks: readonly TaskWorkspaceSummary[],
    edges: readonly TaskDependencyEdge[],
): Set<string> {
    if (tasks.length === 0 || edges.length === 0) {
        return new Set<string>();
    }

    const taskById = new Map<string, TaskWorkspaceSummary>();
    const durationDays = new Map<string, number>();

    for (const t of tasks) {
        const key = t.ID.toLowerCase();
        taskById.set(key, t);
        const start = toDate(t.StartedAt);
        const end = toDate(t.DueAt);
        let days = 1;
        if (start && end && end.getTime() > start.getTime()) {
            days = Math.max(1, Math.round((end.getTime() - start.getTime()) / 86400000));
        } else if (t.HoursEstimated && t.HoursEstimated > 0) {
            days = Math.max(1, Math.ceil(t.HoursEstimated / 8));
        }
        durationDays.set(key, days);
    }

    // Build adjacency list: predecessor -> successors
    const successors = new Map<string, string[]>();
    const hasEdge = new Set<string>();
    for (const e of edges) {
        const pred = e.DependsOnTaskID.toLowerCase();
        const succ = e.TaskID.toLowerCase();
        if (!taskById.has(pred) || !taskById.has(succ) || pred === succ) continue;
        const list = successors.get(pred) ?? [];
        if (!list.includes(succ)) {
            list.push(succ);
            successors.set(pred, list);
        }
        hasEdge.add(pred);
        hasEdge.add(succ);
    }

    if (hasEdge.size === 0) {
        return new Set<string>();
    }

    // Memoized longest path from node u -> { length, nextNode }
    const memo = new Map<string, { len: number; next: string | null }>();
    const visiting = new Set<string>();

    const longestFrom = (id: string): { len: number; next: string | null } => {
        const cached = memo.get(id);
        if (cached) return cached;
        if (visiting.has(id)) {
            return { len: durationDays.get(id) ?? 1, next: null };
        }
        visiting.add(id);
        const selfDur = durationDays.get(id) ?? 1;
        let bestTail = 0;
        let bestNext: string | null = null;
        for (const succ of successors.get(id) ?? []) {
            const sub = longestFrom(succ);
            if (sub.len > bestTail) {
                bestTail = sub.len;
                bestNext = succ;
            }
        }
        visiting.delete(id);
        const out = { len: selfDur + bestTail, next: bestNext };
        memo.set(id, out);
        return out;
    };

    let bestStart: string | null = null;
    let bestTotal = -1;
    for (const id of hasEdge) {
        const res = longestFrom(id);
        if (res.len > bestTotal) {
            bestTotal = res.len;
            bestStart = id;
        }
    }

    const critical = new Set<string>();
    let cur = bestStart;
    while (cur && !critical.has(cur)) {
        critical.add(cur);
        cur = memo.get(cur)?.next ?? null;
    }
    return critical;
}

/**
 * Groups tasks into chronological milestone buckets for the mobile Milestone Stack
 * (replaces desktop horizontal Gantt on small touch screens).
 */
export function GroupTasksIntoMilestones<T extends TaskWorkspaceSummary>(
    tasks: readonly T[],
    now: Date = new Date(),
): MilestoneBucket<T>[] {
    const overdue: T[] = [];
    const thisWeek: T[] = [];
    const upcoming: T[] = [];
    const unscheduled: T[] = [];
    const completed: T[] = [];

    const todayStart = startOfLocalDay(now).getTime();
    const weekEnd = todayStart + 7 * 24 * 60 * 60 * 1000;

    for (const t of tasks) {
        if (!IsTaskActive(t.Status)) {
            if (t.Status === 'Completed') {
                completed.push(t);
            }
            continue;
        }
        const due = toDate(t.DueAt);
        if (!due) {
            unscheduled.push(t);
        } else if (due.getTime() < now.getTime()) {
            overdue.push(t);
        } else if (due.getTime() <= weekEnd) {
            thisWeek.push(t);
        } else {
            upcoming.push(t);
        }
    }

    const byDue = (a: T, b: T): number => {
        const da = toDate(a.DueAt)?.getTime() ?? Number.MAX_SAFE_INTEGER;
        const db = toDate(b.DueAt)?.getTime() ?? Number.MAX_SAFE_INTEGER;
        return da - db;
    };

    overdue.sort(byDue);
    thisWeek.sort(byDue);
    upcoming.sort(byDue);

    const buckets: MilestoneBucket<T>[] = [
        { Key: 'overdue', Label: 'Overdue', Tasks: overdue },
        { Key: 'this-week', Label: 'This Week', Tasks: thisWeek },
        { Key: 'upcoming', Label: 'Upcoming', Tasks: upcoming },
        { Key: 'unscheduled', Label: 'Unscheduled', Tasks: unscheduled },
        { Key: 'completed', Label: 'Completed', Tasks: completed },
    ];
    return buckets.filter((b) => b.Tasks.length > 0);
}

/** Due-date filter keys shared across Tree List, Board, and Gantt views. */
export type TaskDueDateFilterKey = '' | 'overdue' | 'today' | 'week' | 'month' | 'none';

/** Minimal assignee reference used for cross-view assignee filtering. */
export interface TaskAssigneeFilterRef {
    EntityName?: string;
    RecordID: string;
}

/**
 * Evaluates whether a task matches a unified Due Date filter across List, Board, and Gantt.
 */
export function MatchesDueDateFilter(
    dueAt: Date | string | null | undefined,
    status: string,
    filter: TaskDueDateFilterKey | string | null | undefined,
    now: Date = new Date(),
): boolean {
    if (!filter) return true;
    const due = toDate(dueAt);
    if (filter === 'none') return due === null;
    if (!due) return false;

    const todayStart = startOfLocalDay(now).getTime();
    const tomorrowStart = todayStart + 24 * 60 * 60 * 1000;
    const weekEnd = todayStart + 7 * 24 * 60 * 60 * 1000;
    const monthEnd = todayStart + 30 * 24 * 60 * 60 * 1000;
    const dueMs = due.getTime();

    switch (filter) {
        case 'overdue':
            return status !== 'Completed' && status !== 'Cancelled' && dueMs < now.getTime();
        case 'today':
            return dueMs >= todayStart && dueMs < tomorrowStart;
        case 'week':
            return dueMs >= todayStart && dueMs <= weekEnd;
        case 'month':
            return dueMs >= todayStart && dueMs <= monthEnd;
        default:
            return true;
    }
}

/**
 * Evaluates whether a task's assignee list matches a unified Assignee filter:
 * - `''` / `null`: all tasks
 * - `'__unassigned__'`: tasks with 0 assignees
 * - `'__me__'`: tasks assigned to `currentPersonID` or any role in `currentRoleIDs`
 * - `'person:<id>'` or `'role:<id>'`: tasks assigned to that exact Person or MJ Role
 */
export function MatchesAssigneeFilter(
    assignees: readonly TaskAssigneeFilterRef[] | undefined,
    filter: string | null | undefined,
    currentPersonID: string | null | undefined,
    currentRoleIDs: readonly string[] = [],
): boolean {
    if (!filter) return true;
    const list = assignees ?? [];
    if (filter === '__unassigned__') {
        return list.length === 0;
    }
    if (filter === '__me__') {
        const me = currentPersonID?.toLowerCase() ?? null;
        const myRoles = new Set(currentRoleIDs.map((id) => id.toLowerCase()));
        return list.some((a) => {
            const rid = a.RecordID.toLowerCase();
            return (me !== null && rid === me) || myRoles.has(rid);
        });
    }
    if (filter.startsWith('person:')) {
        const target = filter.slice(7).toLowerCase();
        return list.some((a) => a.RecordID.toLowerCase() === target);
    }
    if (filter.startsWith('role:')) {
        const target = filter.slice(5).toLowerCase();
        return list.some((a) => a.RecordID.toLowerCase() === target);
    }
    return list.some((a) => a.RecordID.toLowerCase() === filter.toLowerCase());
}
