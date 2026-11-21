import type { RunView } from '@memberjunction/core';
import {
    FilterGenericCreatableTaskTypes,
    type TaskTypeClassificationInput,
} from '@mj-biz-apps/tasks-entities';

/** Fields needed from `MJ_BizApps_Tasks: Task Types` to filter generic creatable task types. */
export const GENERIC_TASK_TYPE_FIELDS = ['ID', 'Name', 'Code', 'ExtensionEntity', 'IsActive'] as const;

export type TaskTypeLookupRow = TaskTypeClassificationInput & {
    ID: string;
    Name: string;
};

/**
 * Selects the default TaskType ID eligible for generic task creation from a candidate list.
 * Filters out Planning-owned (`PRIORITY`, `MJ_BizApps_Planning:*` `ExtensionEntity`) and
 * inactive OKR task types, preferring `GENERAL` when present.
 */
export function SelectDefaultGenericTaskTypeID(
    taskTypes: ReadonlyArray<TaskTypeClassificationInput & { ID: string }>,
): string | null {
    const creatable = FilterGenericCreatableTaskTypes(taskTypes);
    return (
        creatable.find((t) => (t.Code ?? '').trim().toUpperCase() === 'GENERAL')?.ID ??
        creatable[0]?.ID ??
        null
    );
}

/**
 * Queries active `MJ_BizApps_Tasks: Task Types` via the provided `RunView` instance
 * and returns the default generic creatable TaskType ID (preferring `GENERAL`).
 */
export async function ResolveDefaultGenericTaskTypeID(rv: RunView): Promise<string | null> {
    const res = await rv.RunView<TaskTypeLookupRow>({
        EntityName: 'MJ_BizApps_Tasks: Task Types',
        ExtraFilter: 'IsActive = 1',
        OrderBy: "CASE WHEN Code = 'GENERAL' THEN 0 ELSE 1 END, Name ASC",
        Fields: [...GENERIC_TASK_TYPE_FIELDS],
        ResultType: 'simple',
    });
    return SelectDefaultGenericTaskTypeID(res?.Results ?? []);
}
