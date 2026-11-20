/**
 * Typed helpers for checking the Tasks app's MJ Authorizations (`Tasks`, `Manage Time Entries`,
 * `Manage Timesheets`) on both client and server (D15, §5.8, §10).
 *
 * Uses `AuthorizationEvaluator.UserCanExecuteWithAncestors` from `@memberjunction/core` against
 * `provider.Authorizations` so parent grants (`Tasks` root) and role-level Deny overrides are
 * evaluated consistently. Fails closed (`false`) when `user`, `provider`, or the authorization row
 * is missing.
 */
import { AuthorizationEvaluator, type IMetadataProvider, type UserInfo } from '@memberjunction/core';

/** Root authorization name for the Tasks app. */
export const TASKS_ROOT_AUTHORIZATION = 'Tasks';

/** Authorization granting permission to log, edit, or delete other people's time entries, timers, and agent runs. */
export const MANAGE_TIME_ENTRIES_AUTHORIZATION = 'Manage Time Entries';

/** Authorization granting permission to reopen approved timesheets, configure time approvers, and manage schedules. */
export const MANAGE_TIMESHEETS_AUTHORIZATION = 'Manage Timesheets';

/**
 * Checks whether `user` holds `authorizationName` (or its parent `Tasks` authorization) with no role Deny.
 */
export function UserHasTasksAuthorization(
    user: UserInfo | null | undefined,
    provider: IMetadataProvider | null | undefined,
    authorizationName: typeof MANAGE_TIME_ENTRIES_AUTHORIZATION | typeof MANAGE_TIMESHEETS_AUTHORIZATION | string,
): boolean {
    if (!user || !provider) {
        return false;
    }
    const authorizations = provider.Authorizations ?? [];
    if (authorizations.length === 0) {
        return false;
    }
    const wanted = authorizationName.trim().toLowerCase();
    const rootAuth = authorizations.find((a) => a.Name?.trim().toLowerCase() === TASKS_ROOT_AUTHORIZATION.toLowerCase());
    const grant = authorizations.find((a) => {
        const nameMatch = a.Name?.trim().toLowerCase() === wanted;
        if (!nameMatch) return false;
        if (!rootAuth || !a.ParentID) return true;
        return a.ParentID.trim().toLowerCase() === rootAuth.ID.trim().toLowerCase();
    });
    if (!grant) {
        return false;
    }
    return new AuthorizationEvaluator().UserCanExecuteWithAncestors(grant, user, authorizations);
}

/**
 * True when `user` holds `Manage Time Entries` (or the parent `Tasks` authorization).
 */
export function UserCanManageTimeEntries(
    user: UserInfo | null | undefined,
    provider: IMetadataProvider | null | undefined,
): boolean {
    return UserHasTasksAuthorization(user, provider, MANAGE_TIME_ENTRIES_AUTHORIZATION);
}

/**
 * True when `user` holds `Manage Timesheets` (or the parent `Tasks` authorization).
 */
export function UserCanManageTimesheets(
    user: UserInfo | null | undefined,
    provider: IMetadataProvider | null | undefined,
): boolean {
    return UserHasTasksAuthorization(user, provider, MANAGE_TIMESHEETS_AUTHORIZATION);
}
