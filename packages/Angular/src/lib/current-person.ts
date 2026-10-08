import { Metadata, RunView, UserInfo } from '@memberjunction/core';

export const PEOPLE_ENTITY = 'MJ_BizApps_Common: People';

/**
 * Finds the active People record linked to a user (the signed-in user by default).
 *
 * Task assignments, decisions and comments store a Person ID, so pages that show
 * "my" tasks must filter by this ID. The user's email or User ID never matches.
 *
 * @returns the Person ID, or null when the user has no active linked Person record.
 * @throws when the lookup itself fails, so a caller can tell an error from a missing link.
 */
export async function ResolveCurrentPersonID(user: UserInfo | undefined = new Metadata().CurrentUser): Promise<string | null> {
    if (!user?.ID) return null;
    const result = await new RunView().RunView<{ ID: string }>({
        EntityName: PEOPLE_ENTITY,
        ExtraFilter: `LinkedUserID = '${user.ID}' AND Status = 'Active'`,
        Fields: ['ID'],
        ResultType: 'simple',
        MaxRows: 1,
    });
    if (!result?.Success) throw new Error(`Person lookup failed: ${result?.ErrorMessage ?? 'no result'}`);
    return result.Results?.[0]?.ID ?? null;
}

/** Shown in place of a task list when the signed-in user has no active Person record. */
export const NO_PERSON_MESSAGE =
    'Your user account is not linked to an active Person record, so no assigned tasks can be shown. Ask an administrator to link one.';

/** Shown in place of a task list when looking up the signed-in user's Person record fails. */
export const PERSON_LOOKUP_FAILED_MESSAGE =
    'Your tasks could not be loaded because looking up your Person record failed. Reload the page to try again.';
