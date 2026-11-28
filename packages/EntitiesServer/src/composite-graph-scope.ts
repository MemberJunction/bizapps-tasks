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
 * so entries never outlive the parent operation. Child entity server subclasses check member
 * identity (`parent.Collection.Items.includes(child)`) before consulting an in-flight parent,
 * making it impossible for an unrelated standalone child save to observe or spoof an in-flight parent.
 */
const activeTaskGraphSaves = new Map<string, Set<mjBizAppsTasksTaskCheckInEntity>>();
const activeWorkReportGraphs = new Map<string, Set<mjBizAppsTasksWorkReportEntity>>();

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
    let set = activeTaskGraphSaves.get(key);
    if (!set) {
        set = new Set();
        activeTaskGraphSaves.set(key, set);
    }
    for (const ci of checkIns) {
        set.add(ci);
    }
    return () => {
        const current = activeTaskGraphSaves.get(key);
        if (!current) return;
        for (const ci of checkIns) {
            current.delete(ci);
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
    const set = activeTaskGraphSaves.get(NormalizeUUID(taskID));
    return set ? set.has(checkIn) : false;
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
    let set = activeWorkReportGraphs.get(key);
    if (!set) {
        set = new Set();
        activeWorkReportGraphs.set(key, set);
    }
    set.add(report);
    return () => {
        const current = activeWorkReportGraphs.get(key);
        if (!current) return;
        current.delete(report);
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
    const set = activeWorkReportGraphs.get(NormalizeUUID(workReportID));
    if (!set) return null;
    for (const report of set) {
        const items = report.Items?.Items;
        if (Array.isArray(items) && items.includes(item)) {
            return report;
        }
    }
    return null;
}
