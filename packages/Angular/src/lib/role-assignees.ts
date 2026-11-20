import { Metadata, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import { IsValidUUID, UUIDsEqual } from '@memberjunction/global';
import { ROLES_ENTITY } from './task-filters.js';

export { AssignedToFilter, ROLES_ENTITY } from './task-filters.js';

/**
 * Role assignees on the task pages (bc-aidp-next-golive#442).
 *
 * A Task Assignment whose AssigneeEntityID is `MJ: Roles` assigns the task to the role, so it is
 * "mine" for every user who holds the role. The pages ask for the signed-in user's roles and match
 * them alongside the user's Person. The filter itself, `AssignedToFilter`, lives with the other
 * portable Tasks filters in task-filters.ts.
 */

/** The MJ role IDs a user holds; the signed-in user by default. */
export function CurrentUserRoleIDs(user: UserInfo | undefined = Metadata.Provider?.CurrentUser): string[] {
    return (user?.UserRoles ?? []).map((r) => r.RoleID).filter((id) => IsValidUUID(id));
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
