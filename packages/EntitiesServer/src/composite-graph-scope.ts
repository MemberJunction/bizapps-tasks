import { NormalizeUUID } from '@memberjunction/global';
import type {
    mjBizAppsTasksTaskCheckInEntity,
    mjBizAppsTasksWorkReportEntity,
    mjBizAppsTasksWorkReportItemEntity,
} from '@mj-biz-apps/tasks-entities';

/**
 * In-flight parent entities currently executing a composite graph ValidateAsync() / Save().
 *
 * Scoped strictly via try/finally around the parent's own ValidateAsync() and Save() calls
 * using per-entity reference counts so re-entrant nesting (e.g., Save() invoking ValidateAsync()
 * before validating/saving child RelatedRecordCollection items) keeps the parent registered
 * until the outermost Save() exits. Child entity server subclasses check member identity
 * (`parent.Collection.Items.includes(child)`) before consulting an in-flight parent, making
 * it impossible for an unrelated standalone child save to observe or spoof an in-flight parent.
 */
const activeTaskGraphSaves = new Map<string, Map<mjBizAppsTasksTaskCheckInEntity, number>>();
const activeWorkReportGraphs = new Map<string, Map<mjBizAppsTasksWorkReportEntity, number>>();

/**
 * Registers the check-in entities participating in a parent Task's composite graph save.
 * Returns a cleanup callback that MUST be invoked in a `finally` block.
 */
export function EnterTaskCheckInGraphScope(
    taskID: string | null | undefined,
    checkIns: readonly mjBizAppsTasksTaskCheckInEntity[],
): () => void {
    if (!taskID || checkIns.length === 0) {
        return () => {};
    }
    const key = NormalizeUUID(taskID);
    let counts = activeTaskGraphSaves.get(key);
    if (!counts) {
        counts = new Map();
        activeTaskGraphSaves.set(key, counts);
    }
    for (const ci of checkIns) {
        counts.set(ci, (counts.get(ci) ?? 0) + 1);
    }
    let released = false;
    return () => {
        if (released) return;
        released = true;
        const current = activeTaskGraphSaves.get(key);
        if (!current) return;
        for (const ci of checkIns) {
            const next = (current.get(ci) ?? 0) - 1;
            if (next <= 0) {
                current.delete(ci);
            } else {
                current.set(ci, next);
            }
        }
        if (current.size === 0) {
            activeTaskGraphSaves.delete(key);
        }
    };
}

/**
 * Returns true when `checkIn` is currently being saved as part of its parent Task's
 * composite `task.Save()` graph (so TaskCheckInEntityServer must NOT issue a recursive `parentTask.Save()`).
 */
export function IsCheckInInParentTaskGraph(
    taskID: string | null | undefined,
    checkIn: mjBizAppsTasksTaskCheckInEntity,
): boolean {
    if (!taskID) return false;
    const counts = activeTaskGraphSaves.get(NormalizeUUID(taskID));
    return counts ? (counts.get(checkIn) ?? 0) > 0 : false;
}

/**
 * Registers a WorkReport currently running ValidateAsync() or Save() with its `Items` collection.
 * Returns a cleanup callback that MUST be invoked in a `finally` block.
 */
export function EnterWorkReportGraphScope(
    report: mjBizAppsTasksWorkReportEntity,
): () => void {
    const id = report.ID;
    if (!id) {
        return () => {};
    }
    const key = NormalizeUUID(id);
    let counts = activeWorkReportGraphs.get(key);
    if (!counts) {
        counts = new Map();
        activeWorkReportGraphs.set(key, counts);
    }
    counts.set(report, (counts.get(report) ?? 0) + 1);
    let released = false;
    return () => {
        if (released) return;
        released = true;
        const current = activeWorkReportGraphs.get(key);
        if (!current) return;
        const next = (current.get(report) ?? 0) - 1;
        if (next <= 0) {
            current.delete(report);
        } else {
            current.set(report, next);
        }
        if (current.size === 0) {
            activeWorkReportGraphs.delete(key);
        }
    };
}

/**
 * Finds the in-flight parent WorkReport for a WorkReportItem ONLY when that exact item instance
 * is a member of the parent's `Items` RelatedRecordCollection during the parent's composite ValidateAsync/Save.
 * Standalone saves of unrelated WorkReportItems always receive `null` and must resolve the parent from the DB.
 */
export function FindInFlightParentWorkReportForItem(
    workReportID: string | null | undefined,
    item: mjBizAppsTasksWorkReportItemEntity,
): mjBizAppsTasksWorkReportEntity | null {
    if (!workReportID) return null;
    const counts = activeWorkReportGraphs.get(NormalizeUUID(workReportID));
    if (!counts) return null;
    for (const [report, depth] of counts.entries()) {
        if (depth <= 0) continue;
        const items = report.Items?.Items;
        if (Array.isArray(items) && items.includes(item)) {
            return report;
        }
    }
    return null;
}
