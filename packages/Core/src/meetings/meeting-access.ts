import type { IMetadataProvider, UserInfo } from '@memberjunction/core';
import { MEETING_ENTITY } from './entity-names.js';

export const UI_ROLE = 'UI';

/**
 * Whether the caller may change every meeting, not only their own (the meetings plan, § 3): they hold a role other than
 * UI that may update Meetings. The UI role is what every signed-in person holds; the roles above it (Developer,
 * Integration, an administrator's) are the ones that administer.
 */
export function callerAdministersMeetings(provider: IMetadataProvider, user: UserInfo): boolean {
    const meetings = provider.Entities.find((entity) => entity.Name === MEETING_ENTITY);
    if (!meetings) return false;
    const uiRoleIds = new Set(provider.Roles.filter((role) => role.Name === UI_ROLE).map((role) => role.ID.toUpperCase()));
    const updating = new Set(
        meetings.Permissions.filter((permission) => permission.CanUpdate && !uiRoleIds.has((permission.RoleID ?? '').toUpperCase())).map((permission) => (permission.RoleID ?? '').toUpperCase()),
    );
    return (user.UserRoles ?? []).some((userRole) => updating.has((userRole.RoleID ?? '').toUpperCase()));
}

/** Whether the caller is the meeting's organizer: their Person is the organizer's. */
export function callerIsOrganizer(callerPersonId: string | null, organizerPersonId: string | null | undefined): boolean {
    return !!callerPersonId && !!organizerPersonId && callerPersonId.toLowerCase() === organizerPersonId.toLowerCase();
}
