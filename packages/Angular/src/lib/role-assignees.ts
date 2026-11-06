import { Metadata, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import { EscapeSQLString, IsValidUUID, UUIDsEqual } from '@memberjunction/global';

/**
 * Role assignees on the task pages (bc-aidp-next-golive#442).
 *
 * A Task Assignment whose AssigneeEntityID is `MJ: Roles` assigns the task to the role, so it is
 * "mine" for every user who holds the role. The pages ask for the signed-in user's roles and match
 * them alongside the user's Person.
 */
export const ROLES_ENTITY = 'MJ: Roles';

/** The MJ role IDs a user holds; the signed-in user by default. */
export function CurrentUserRoleIDs(user: UserInfo | undefined = Metadata.Provider?.CurrentUser): string[] {
    return (user?.UserRoles ?? []).map((r) => r.RoleID).filter((id) => IsValidUUID(id));
}

/**
 * A Tasks filter clause selecting tasks assigned to the person, or to any of the roles.
 *
 * Role IDs that are not UUIDs are dropped. Each role ID is matched in upper and lower case because
 * `AssigneeRecordID` is text, and the two databases write UUIDs in different cases.
 */
export function AssignedToFilter(personID: string, roleIDs: readonly string[] = [], provider: IMetadataProvider = Metadata.Provider): string {
    const view = '__mj_BizAppsTasks.vwTaskAssignments';
    const personClause = `AssigneeRecordID = '${EscapeSQLString(personID)}'`;
    const rolesEntityID = provider?.EntityByName(ROLES_ENTITY)?.ID;
    const ids = [...new Set(roleIDs.filter((id) => IsValidUUID(id)).flatMap((id) => [id.toUpperCase(), id.toLowerCase()]))];
    if (!rolesEntityID || ids.length === 0) {
        return `ID IN (SELECT TaskID FROM ${view} WHERE ${personClause})`;
    }
    const roleClause = `(AssigneeEntityID = '${rolesEntityID}' AND AssigneeRecordID IN (${ids.map((id) => `'${id}'`).join(',')}))`;
    return `ID IN (SELECT TaskID FROM ${view} WHERE ${personClause} OR ${roleClause})`;
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
