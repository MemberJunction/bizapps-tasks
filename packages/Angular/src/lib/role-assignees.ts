import { Metadata, RunView, type IMetadataProvider, type IRunViewProvider, type UserInfo } from '@memberjunction/core';
import { EscapeSQLString, IsValidUUID, UUIDsEqual } from '@memberjunction/global';

/**
 * Role assignees on the task pages (bc-aidp-next-golive#442).
 *
 * A Task Assignment whose AssigneeEntityID is `MJ: Roles` assigns the task to the role, so it is
 * "mine" for every user who holds the role. The pages ask for the signed-in user's roles and match
 * them alongside the user's Person.
 */
export const ROLES_ENTITY = 'MJ: Roles';
export const TASK_ASSIGNMENTS_ENTITY = 'MJ_BizApps_Tasks: Task Assignments';

/** Default batch size when building `ID IN (...)` clauses for preloaded Task IDs. */
const DEFAULT_TASK_ID_BATCH = 400;

/** Result of resolving assigned Task IDs through a first-class `RunView` on Task Assignments. */
export interface LoadAssignedTaskIDsResult {
    Success: boolean;
    TaskIDs: string[];
    ErrorMessage?: string;
}

/** The MJ role IDs a user holds; the signed-in user by default. */
export function CurrentUserRoleIDs(user: UserInfo | undefined = Metadata.Provider?.CurrentUser): string[] {
    return (user?.UserRoles ?? []).map((r) => r.RoleID).filter((id) => IsValidUUID(id));
}

/**
 * Builds an entity-field `ExtraFilter` for `MJ_BizApps_Tasks: Task Assignments` matching
 * assignments to `personID` or any of `roleIDs`.
 *
 * Role IDs that are not UUIDs are dropped. Each role ID is matched in upper and lower case because
 * `AssigneeRecordID` is text, and SQL Server / PostgreSQL write UUIDs in different cases.
 */
export function BuildTaskAssignmentPredicate(
    personID: string,
    roleIDs: readonly string[] = [],
    provider: IMetadataProvider = Metadata.Provider,
): string {
    const personClause = `AssigneeRecordID = '${EscapeSQLString(personID)}'`;
    const rolesEntityID = provider?.EntityByName?.(ROLES_ENTITY)?.ID;
    const ids = [
        ...new Set(
            roleIDs
                .filter((id) => IsValidUUID(id))
                .flatMap((id) => [id.toUpperCase(), id.toLowerCase()]),
        ),
    ];
    if (!rolesEntityID || ids.length === 0) {
        return personClause;
    }
    const roleClause = `(AssigneeEntityID = '${EscapeSQLString(rolesEntityID)}' AND AssigneeRecordID IN (${ids.map((id) => `'${id}'`).join(',')}))`;
    return `${personClause} OR ${roleClause}`;
}

/**
 * Resolves the deduplicated `TaskID`s assigned to `personID` or any of `roleIDs` via a
 * first-class `RunView` on `MJ_BizApps_Tasks: Task Assignments`.
 *
 * This avoids raw SQL subqueries against `__mj_BizAppsTasks.vwTaskAssignments`, which MJServer
 * rejects when `Task Assignments` is row-level-security filtered for the current user.
 */
export async function LoadAssignedTaskIDs(
    personID: string,
    roleIDs: readonly string[] = [],
    provider?: IMetadataProvider | null,
    bypassCache = true,
): Promise<LoadAssignedTaskIDsResult> {
    if (!personID) {
        return { Success: true, TaskIDs: [] };
    }
    const effectiveProvider = provider ?? Metadata.Provider;
    const rv =
        effectiveProvider && typeof (effectiveProvider as Partial<IRunViewProvider>).RunView === 'function'
            ? RunView.FromMetadataProvider(effectiveProvider)
            : new RunView();
    const extraFilter = BuildTaskAssignmentPredicate(personID, roleIDs, effectiveProvider);
    const res = await rv.RunView<{ TaskID: string }>({
        EntityName: TASK_ASSIGNMENTS_ENTITY,
        ExtraFilter: extraFilter,
        Fields: ['TaskID'],
        ResultType: 'simple',
        BypassCache: bypassCache,
    });
    if (!res?.Success) {
        return {
            Success: false,
            TaskIDs: [],
            ErrorMessage: res?.ErrorMessage || 'Failed to load task assignments.',
        };
    }
    const seen = new Set<string>();
    const taskIds: string[] = [];
    for (const row of res.Results ?? []) {
        const id = row.TaskID?.trim();
        if (!id) continue;
        const key = id.toLowerCase();
        if (!seen.has(key)) {
            seen.add(key);
            taskIds.push(id);
        }
    }
    return { Success: true, TaskIDs: taskIds };
}

/**
 * Splits a list of Task IDs into deduplicated batches of at most `batchSize` entries.
 */
export function ChunkTaskIDs(taskIDs: readonly string[], batchSize = DEFAULT_TASK_ID_BATCH): string[][] {
    const deduped: string[] = [];
    const seen = new Set<string>();
    for (const raw of taskIDs) {
        const id = raw?.trim();
        if (!id) continue;
        const key = id.toLowerCase();
        if (!seen.has(key)) {
            seen.add(key);
            deduped.push(id);
        }
    }
    if (deduped.length === 0) return [];
    const step = Math.max(1, batchSize);
    const chunks: string[][] = [];
    for (let i = 0; i < deduped.length; i += step) {
        chunks.push(deduped.slice(i, i + step));
    }
    return chunks;
}

/**
 * Builds an RLS-safe `ID IN (...)` SQL filter for a list of Task IDs, or `'1 = 0'` when empty.
 * Large lists are split into OR-joined `ID IN (...)` groups of at most `batchSize` IDs.
 */
export function BuildTaskIDsInFilter(taskIDs: readonly string[], batchSize = DEFAULT_TASK_ID_BATCH): string {
    const chunks = ChunkTaskIDs(taskIDs, batchSize);
    if (chunks.length === 0) return '1 = 0';
    const clauses = chunks.map((chunk) => `ID IN (${chunk.map((id) => `'${EscapeSQLString(id)}'`).join(',')})`);
    return clauses.length === 1 ? clauses[0] : `(${clauses.join(' OR ')})`;
}

/**
 * A Tasks filter clause selecting tasks assigned to the person, or to any of the roles.
 *
 * @deprecated Prefer the two-step RLS-safe {@link LoadAssignedTaskIDs} + {@link BuildTaskIDsInFilter}
 * flow so `MJServer` can apply Row-Level Security on `MJ_BizApps_Tasks: Task Assignments`.
 */
export function AssignedToFilter(personID: string, roleIDs: readonly string[] = [], provider: IMetadataProvider = Metadata.Provider): string {
    const view = '__mj_BizAppsTasks.vwTaskAssignments';
    const predicate = BuildTaskAssignmentPredicate(personID, roleIDs, provider);
    return `ID IN (SELECT TaskID FROM ${view} WHERE ${predicate})`;
}

/** The role's name when the assignment is to an MJ role; otherwise null. */
export function RoleAssigneeName(
    assigneeEntityID: string | null | undefined,
    assigneeRecordID: string,
    provider: IMetadataProvider = Metadata.Provider,
): string | null {
    const rolesEntity = provider?.EntityByName(ROLES_ENTITY);
    if (!rolesEntity || !UUIDsEqual(rolesEntity.ID, assigneeEntityID)) return null;
    return provider.Roles?.find((r) => UUIDsEqual(r.ID, assigneeRecordID))?.Name ?? null;
}
