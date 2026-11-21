import { UUIDsEqual } from '@memberjunction/global';

/**
 * Helpers for classifying `MJ_BizApps_Tasks: Task Types` records, resolving
 * `ExtensionEntity` IS-A metadata, and filtering task types eligible for
 * generic task creation in Tasks menus and forms.
 */

/** Canonical Task Type code for Planning-owned Priorities. */
export const PRIORITY_TASK_TYPE_CODE = 'PRIORITY';

/** Canonical MJ Entity name of the Planning IS-A child of `MJ_BizApps_Tasks: Tasks`. */
export const PRIORITY_EXTENSION_ENTITY = 'MJ_BizApps_Planning: Priority Tasks';

/** Entity name prefix identifying entities owned by BizApps Planning. */
export const PLANNING_EXTENSION_ENTITY_PREFIX = 'MJ_BizApps_Planning:';

/** Legacy OKR task type codes superseded by BizApps Planning and generic measurable tasks. */
export const LEGACY_OKR_TASK_TYPE_CODES: ReadonlySet<string> = new Set([
    'PRIORITY_OBJECTIVE',
    'KEY_RESULT',
]);

/** Lowercase display names for legacy OKR task types. */
export const LEGACY_OKR_TASK_TYPE_NAMES: ReadonlySet<string> = new Set([
    'priority objective',
    'key result',
]);

/** All Task Type codes owned by BizApps Planning or legacy OKR workflows. */
export const PLANNING_OWNED_TASK_TYPE_CODES: ReadonlySet<string> = new Set([
    PRIORITY_TASK_TYPE_CODE,
    'PRIORITY_OBJECTIVE',
    'KEY_RESULT',
]);

/** Lowercase display names for Planning-owned or legacy OKR task types. */
export const PLANNING_OWNED_TASK_TYPE_NAMES: ReadonlySet<string> = new Set([
    'priority',
    'priority objective',
    'key result',
]);

/**
 * Structural subset of `MJ_BizApps_Tasks: Task Types` needed to evaluate
 * `ExtensionEntity` ownership and generic creation eligibility.
 */
export interface TaskTypeClassificationInput {
    Code?: string | null;
    Name?: string | null;
    ExtensionEntity?: string | null;
    IsActive?: boolean | null;
}

/** Options controlling generic task type filtering behavior. */
export interface GenericTaskTypeFilterOptions {
    /**
     * When true, any TaskType declaring a non-empty `ExtensionEntity` (even non-Planning
     * extensions such as GitHub Issues/PRs) is excluded from generic creation.
     */
    excludeAnyExtensionEntity?: boolean;
}

/** Minimal entity metadata shape for checking optional IS-A child registration. */
export interface EntityMetadataRecord {
    ID?: string;
    Name: string;
    ParentID?: string | null;
    ParentEntity?: string | null;
}

/** Minimal metadata registry shape compatible with `Metadata.Provider`. */
export interface EntityRegistryLike {
    Entities?: ReadonlyArray<EntityMetadataRecord> | null;
}

/** Normalizes a `TaskType.ExtensionEntity` string by trimming whitespace and returning `null` if blank. */
export function NormalizeTaskTypeExtensionEntity(extensionEntity: string | null | undefined): string | null {
    if (extensionEntity == null) {
        return null;
    }
    const trimmed = extensionEntity.trim();
    return trimmed.length > 0 ? trimmed : null;
}

/** Returns `true` when the TaskType declares any non-empty IS-A `ExtensionEntity`. */
export function HasTaskTypeExtensionEntity(
    taskType: Pick<TaskTypeClassificationInput, 'ExtensionEntity'> | null | undefined,
): boolean {
    return NormalizeTaskTypeExtensionEntity(taskType?.ExtensionEntity) !== null;
}

/** Returns `true` when an `ExtensionEntity` name belongs to BizApps Planning (e.g. `MJ_BizApps_Planning: Priority Tasks`). */
export function IsPlanningExtensionEntity(extensionEntity: string | null | undefined): boolean {
    const normalized = NormalizeTaskTypeExtensionEntity(extensionEntity);
    if (!normalized) {
        return false;
    }
    const lower = normalized.toLowerCase();
    return (
        lower.startsWith(PLANNING_EXTENSION_ENTITY_PREFIX.toLowerCase()) ||
        lower === PRIORITY_EXTENSION_ENTITY.toLowerCase()
    );
}

/** Returns `true` when a TaskType represents a legacy OKR type (`PRIORITY_OBJECTIVE` or `KEY_RESULT`). */
export function IsLegacyOkrTaskType(
    taskType: Pick<TaskTypeClassificationInput, 'Code' | 'Name'> | null | undefined,
): boolean {
    if (!taskType) {
        return false;
    }
    const code = (taskType.Code ?? '').trim().toUpperCase();
    if (code && LEGACY_OKR_TASK_TYPE_CODES.has(code)) {
        return true;
    }
    const name = (taskType.Name ?? '').trim().toLowerCase();
    return Boolean(name && LEGACY_OKR_TASK_TYPE_NAMES.has(name));
}

/**
 * Returns `true` when a TaskType is owned by BizApps Planning (by external Planning
 * `ExtensionEntity`, `PRIORITY` code/name, or legacy OKR code/name).
 */
export function IsPlanningOwnedTaskType(
    taskType: TaskTypeClassificationInput | null | undefined,
): boolean {
    if (!taskType) {
        return false;
    }
    if (IsPlanningExtensionEntity(taskType.ExtensionEntity)) {
        return true;
    }
    const code = (taskType.Code ?? '').trim().toUpperCase();
    if (code && PLANNING_OWNED_TASK_TYPE_CODES.has(code)) {
        return true;
    }
    const name = (taskType.Name ?? '').trim().toLowerCase();
    return Boolean(name && PLANNING_OWNED_TASK_TYPE_NAMES.has(name));
}

/**
 * Predicate returning `true` when a TaskType is eligible for generic task creation
 * in BizApps Tasks menus and forms.
 *
 * Excludes:
 * - null/undefined records
 * - inactive task types (`IsActive === false`), including inactive legacy OKR types
 * - Planning-owned task types (`PRIORITY`, `PRIORITY_OBJECTIVE`, `KEY_RESULT`, or any type with an external `MJ_BizApps_Planning:*` `ExtensionEntity`)
 * - optionally, any type declaring an `ExtensionEntity` when `options.excludeAnyExtensionEntity` is `true`
 */
export function IsGenericCreatableTaskType(
    taskType: TaskTypeClassificationInput | null | undefined,
    options?: GenericTaskTypeFilterOptions,
): boolean {
    if (!taskType) {
        return false;
    }
    if (taskType.IsActive === false) {
        return false;
    }
    if (IsPlanningOwnedTaskType(taskType)) {
        return false;
    }
    if (options?.excludeAnyExtensionEntity && HasTaskTypeExtensionEntity(taskType)) {
        return false;
    }
    return true;
}

/** Filters a list of TaskTypes down to those available for generic task creation in Tasks. */
export function FilterGenericCreatableTaskTypes<T extends TaskTypeClassificationInput>(
    taskTypes: readonly T[],
    options?: GenericTaskTypeFilterOptions,
): T[] {
    return taskTypes.filter((taskType) => IsGenericCreatableTaskType(taskType, options));
}

/**
 * Checks whether the `ExtensionEntity` declared on a TaskType is present and registered
 * as an IS-A child of `MJ_BizApps_Tasks: Tasks` in the supplied metadata registry.
 *
 * Returns `false` safely without throwing in standalone Tasks deployments where the
 * optional extension Open App (such as `bizapps-planning`) is not installed.
 */
export function IsTaskTypeExtensionEntityAvailable(
    taskType: Pick<TaskTypeClassificationInput, 'ExtensionEntity'> | null | undefined,
    registry: EntityRegistryLike | null | undefined,
    parentEntityName: string = 'MJ_BizApps_Tasks: Tasks',
): boolean {
    const extName = NormalizeTaskTypeExtensionEntity(taskType?.ExtensionEntity);
    if (!extName) {
        return false;
    }
    const entities = registry?.Entities;
    if (!entities || entities.length === 0) {
        return false;
    }

    const parentEntity = entities.find(
        (e) => e.Name.trim().toLowerCase() === parentEntityName.trim().toLowerCase(),
    );
    const childEntity = entities.find(
        (e) => e.Name.trim().toLowerCase() === extName.toLowerCase(),
    );
    if (!childEntity) {
        return false;
    }

    // If parent/child linkage metadata is populated, verify IS-A parent matches Tasks.
    if (childEntity.ParentEntity) {
        return childEntity.ParentEntity.trim().toLowerCase() === parentEntityName.trim().toLowerCase();
    }
    if (childEntity.ParentID && parentEntity?.ID) {
        return UUIDsEqual(childEntity.ParentID, parentEntity.ID);
    }
    // When only entity names are present without ParentID/ParentEntity, presence in registry suffices.
    return childEntity.ParentID === undefined && childEntity.ParentEntity === undefined;
}
