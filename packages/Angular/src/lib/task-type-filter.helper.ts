import { UUIDsEqual } from '@memberjunction/global';
import {
    FilterGenericCreatableTaskTypes,
    IsGenericCreatableTaskType,
    PLANNING_OWNED_TASK_TYPE_CODES,
    type TaskTypeClassificationInput,
} from '@mj-biz-apps/tasks-entities';

/** Canonical UUIDs for Planning-owned or legacy inactive OKR task types that must never be defaulted in generic creation. */
export const BLOCKED_FALLBACK_TASK_TYPE_IDS: ReadonlySet<string> = new Set([
    '7e100001-0000-0000-0000-000000000001', // PRIORITY (Planning IS-A Priority Tasks)
    '8d42a1b9-3e71-4c5a-9f20-1b6e8d3a9c01', // PRIORITY_OBJECTIVE (Legacy inactive OKR)
    '8d42a1b9-3e71-4c5a-9f20-1b6e8d3a9c02', // KEY_RESULT (Legacy inactive OKR)
]);

const BLOCKED_FALLBACK_CODES: ReadonlySet<string> = new Set([
    ...PLANNING_OWNED_TASK_TYPE_CODES,
    'OBJECTIVE',
]);

const BLOCKED_FALLBACK_PATTERN = /(?:^|[^a-z0-9])(planning|priority|key[-_]?result|objective|okr)(?:[^a-z0-9]|$)/i;

/**
 * Returns `true` when a raw TaskType ID or code matches a known Planning-owned or
 * inactive OKR task type that must be blocked even when `RunView` metadata is unavailable.
 */
export function IsBlockedFallbackGenericTaskTypeID(requestedTypeID: string | null | undefined): boolean {
    const trimmed = requestedTypeID?.trim();
    if (!trimmed) {
        return false;
    }
    const lower = trimmed.toLowerCase();
    if (BLOCKED_FALLBACK_TASK_TYPE_IDS.has(lower)) {
        return true;
    }
    if (BLOCKED_FALLBACK_CODES.has(trimmed.toUpperCase())) {
        return true;
    }
    return BLOCKED_FALLBACK_PATTERN.test(trimmed);
}

/** Fields needed from `MJ_BizApps_Tasks: Task Types` to filter generic creatable task types. */
export const GENERIC_TASK_TYPE_FIELDS = ['ID', 'Name', 'Code', 'ExtensionEntity', 'IsActive'] as const;

export type TaskTypeLookupRow = TaskTypeClassificationInput & {
    ID: string;
    Name: string;
};

/** Minimal structural subset of `RunView` needed to query TaskType metadata without type casts. */
export interface TaskTypeRunViewLike {
    RunView(params: {
        EntityName: string;
        ExtraFilter?: string;
        OrderBy?: string;
        Fields?: string[];
        ResultType?: 'simple' | 'entity_object';
    }): Promise<{ Success: boolean; Results: TaskTypeLookupRow[] } | undefined>;
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
 *
 * When `RunView` returns `undefined` (such as in unstubbed unit-test mocks), blocks known
 * Planning-owned and inactive OKR TaskType IDs/codes (`PRIORITY`, `PRIORITY_OBJECTIVE`,
 * `OBJECTIVE`, `KEY_RESULT`, known Planning/OKR UUIDs, and `planning`/`priority`/`okr` patterns)
 * by returning `null`, while permitting non-Planning generic default IDs.
 */
export async function ResolveDefaultGenericTaskTypeID(
    rv: TaskTypeRunViewLike,
    requestedTypeID?: string | null,
): Promise<string | null> {
    const res = await rv.RunView({
        EntityName: 'MJ_BizApps_Tasks: Task Types',
        ExtraFilter: 'IsActive = 1',
        OrderBy: "CASE WHEN Code = 'GENERAL' THEN 0 ELSE 1 END, Name ASC",
        Fields: [...GENERIC_TASK_TYPE_FIELDS],
        ResultType: 'simple',
    });
    if (!res) {
        const trimmed = requestedTypeID?.trim();
        if (!trimmed || IsBlockedFallbackGenericTaskTypeID(trimmed)) {
            return null;
        }
        return trimmed;
    }
    if (!res.Success || !Array.isArray(res.Results)) {
        return null;
    }
    return SelectGenericQuickAddTaskTypeID(res.Results, requestedTypeID);
}
