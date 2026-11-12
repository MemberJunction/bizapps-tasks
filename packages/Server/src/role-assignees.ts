/**
 * Role assignees (bc-aidp-next-golive#442).
 *
 * `TaskAssignment` is polymorphic: `AssigneeEntityID` names the entity and `AssigneeRecordID` the
 * record. An assignment whose entity is `MJ: Roles` assigns the task to the role itself, so every
 * active user who holds the role sees it and is notified of it. A queue shared by a team (finance
 * reviewing every won deal's order, say) needs no person picked per task, and a change of staff is
 * a change of role membership rather than of every open task.
 *
 * Membership is read when a notice is sent, never copied onto the task, so a user who joins the role
 * later still finds its open tasks.
 *
 * CONNECTS TO:
 *   READS: MJ: User Roles · MJ: Users · MJ: Roles (metadata)
 */
import { Metadata, RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import { IsValidUUID, UUIDsEqual } from '@memberjunction/global';

export const ROLES_ENTITY = 'MJ: Roles';
const USER_ROLES_ENTITY = 'MJ: User Roles';
const USERS_ENTITY = 'MJ: Users';

/** True when an assignment's AssigneeEntityID is `MJ: Roles`. */
export function IsRoleEntityID(entityID: string | null | undefined, provider: IMetadataProvider = Metadata.Provider): boolean {
    if (!entityID) return false;
    const roles = provider?.EntityByName(ROLES_ENTITY);
    return !!roles && UUIDsEqual(roles.ID, entityID);
}

/** The role's name, from metadata; null when the ID names no role. */
export function RoleName(roleID: string, provider: IMetadataProvider = Metadata.Provider): string | null {
    return provider?.Roles?.find((r) => UUIDsEqual(r.ID, roleID))?.Name ?? null;
}

/**
 * The active users who hold any of the roles, each once.
 *
 * IDs that are not UUIDs are dropped before they reach a filter.
 *
 * @throws when a lookup fails, so a caller can tell an error from a role with no members.
 */
export async function ResolveUserIDsForRoles(roleIDs: readonly string[], contextUser: UserInfo): Promise<string[]> {
    const ids = uniqueIDs(roleIDs);
    if (ids.length === 0) return [];

    const rv = new RunView();
    const memberships = await rv.RunView<{ UserID: string }>({
        EntityName: USER_ROLES_ENTITY,
        ExtraFilter: `RoleID IN (${ids.map((id) => `'${id}'`).join(',')})`,
        Fields: ['UserID'],
        ResultType: 'simple',
        BypassCache: true,
    }, contextUser);
    if (!memberships?.Success) throw new Error(memberships?.ErrorMessage ?? 'the role membership lookup returned no result');

    const userIDs = uniqueIDs((memberships.Results ?? []).map((m) => m.UserID));
    if (userIDs.length === 0) return [];

    const users = await rv.RunView<{ ID: string; IsActive: boolean }>({
        EntityName: USERS_ENTITY,
        ExtraFilter: `ID IN (${userIDs.map((id) => `'${id}'`).join(',')})`,
        Fields: ['ID', 'IsActive'],
        ResultType: 'simple',
        BypassCache: true,
    }, contextUser);
    if (!users?.Success) throw new Error(users?.ErrorMessage ?? 'the user lookup returned no result');

    // Compared in code rather than in the filter, so the boolean reads the same on every database.
    return (users.Results ?? []).filter((u) => u.IsActive === true).map((u) => u.ID);
}

/** Valid UUIDs, each once, compared case-insensitively. */
function uniqueIDs(ids: readonly (string | null | undefined)[]): string[] {
    const seen = new Map<string, string>();
    for (const id of ids) {
        if (id && IsValidUUID(id) && !seen.has(id.toLowerCase())) seen.set(id.toLowerCase(), id);
    }
    return [...seen.values()];
}
