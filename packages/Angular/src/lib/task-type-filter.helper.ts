import type { RunViewParams } from '@memberjunction/core';
import { UUIDsEqual } from '@memberjunction/global';
import {
    FilterGenericCreatableTaskTypes,
    IsGenericCreatableTaskType,
    type TaskTypeClassificationInput,
} from '@mj-biz-apps/tasks-entities';

/** Fields needed from `MJ_BizApps_Tasks: Task Types` to filter generic creatable task types. */
export const GENERIC_TASK_TYPE_FIELDS = ['ID', 'Name', 'Code', 'ExtensionEntity', 'IsActive'] as const;

export type TaskTypeLookupRow = TaskTypeClassificationInput & {
    ID: string;
    Name: string;
};

/** Minimal structural subset of `RunView` needed to query TaskType metadata without type casts. */
export interface TaskTypeRunViewLike {
    RunView<T = TaskTypeLookupRow>(params: RunViewParams): Promise<{ Success: boolean; Results: T[] } | undefined>;
}

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
 * Validates an optional requested default TaskType ID against generic creation rules
 * (`IsGenericCreatableTaskType`, matching IDs via `UUIDsEqual`), retaining valid generic
 * defaults and falling back to `SelectDefaultGenericTaskTypeID` when the requested type
 * is Planning-owned (`PRIORITY`, `MJ_BizApps_Planning:*` `ExtensionEntity`), inactive,
 * legacy OKR, or missing.
 */
export function SelectGenericQuickAddTaskTypeID(
    taskTypes: ReadonlyArray<TaskTypeClassificationInput & { ID: string }>,
    requestedTypeID?: string | null,
): string | null {
    const requested = requestedTypeID?.trim();
    if (requested) {
        const match = taskTypes.find((t) => UUIDsEqual(t.ID, requested));
        if (match && IsGenericCreatableTaskType(match)) {
            return match.ID;
        }
    }
    return SelectDefaultGenericTaskTypeID(taskTypes);
}

/**
 * Queries active `MJ_BizApps_Tasks: Task Types` via the provided `RunView` instance
 * and returns an eligible generic creatable TaskType ID.
 *
 * When `requestedTypeID` is supplied, validates it against the loaded TaskType metadata
 * before assigning/saving — retaining valid generic defaults and falling back to `GENERAL`
 * (or rejecting when no generic types are available) for Planning-owned or inactive OKR types.
 */
export async function ResolveDefaultGenericTaskTypeID(
    rv: TaskTypeRunViewLike,
    requestedTypeID?: string | null,
): Promise<string | null> {
    const res = await rv.RunView<TaskTypeLookupRow>({
        EntityName: 'MJ_BizApps_Tasks: Task Types',
        ExtraFilter: 'IsActive = 1',
        OrderBy: "CASE WHEN Code = 'GENERAL' THEN 0 ELSE 1 END, Name ASC",
        Fields: [...GENERIC_TASK_TYPE_FIELDS],
        ResultType: 'simple',
    });
    if (!res) {
        const trimmed = requestedTypeID?.trim();
        return trimmed ? trimmed : null;
    }
    if (!res.Success) {
        return null;
    }
    return SelectGenericQuickAddTaskTypeID(res.Results ?? [], requestedTypeID);
}
