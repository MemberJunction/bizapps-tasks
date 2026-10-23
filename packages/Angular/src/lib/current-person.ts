import { Metadata, RunView, UserInfo } from '@memberjunction/core';
import { IsValidUUID } from '@memberjunction/global';

export const PEOPLE_ENTITY = 'MJ_BizApps_Common: People';

/**
 * Finds the active People record linked to a user (the signed-in user by default).
 *
 * Task assignments, decisions and comments store a Person ID, so pages that show
 * "my" tasks must filter by this ID. The user's email or User ID never matches.
 *
 * The user's own link is read first: `LinkedEntityRecordID` when `LinkedEntityID` is People or
 * an IS-A subtype of it. A platform that binds users through a People subtype keeps that link
 * and leaves the deprecated `People.LinkedUserID` empty. Users without such a link fall back
 * to `LinkedUserID`.
 *
 * @returns the Person ID, or null when the user has no active linked Person record.
 * @throws when the lookup itself fails, so a caller can tell an error from a missing link.
 */
export async function ResolveCurrentPersonID(user: UserInfo | undefined = new Metadata().CurrentUser): Promise<string | null> {
    if (!user?.ID) return null;
    const linkedPersonID = LinkedPersonRecordID(user);
    const params = {
        EntityName: PEOPLE_ENTITY,
        ExtraFilter: `${linkedPersonID ? `ID = '${linkedPersonID}'` : `LinkedUserID = '${user.ID}'`} AND Status = 'Active'`,
        Fields: ['ID'],
        ResultType: 'simple' as const,
        MaxRows: 1,
    };
    let result: Awaited<ReturnType<RunView['RunView']>> | null = null;
    try {
        result = await new RunView().RunView<{ ID: string }>(params);
    } catch (error) {
        // The GraphQL provider sends the views asked in one tick as one batch and rejects them all when any one of them
        // names an entity the host lacks (a shell component's, on a host behind its code). The People read was not the
        // problem then: ask once more, in a batch of its own.
        if (error instanceof Error && /not found in metadata/i.test(error.message) && !error.message.includes(PEOPLE_ENTITY)) {
            await new Promise((resolve) => setTimeout(resolve, 150));
            result = await new RunView().RunView<{ ID: string }>(params);
        } else {
            throw error;
        }
    }
    if (!result?.Success) throw new Error(`Person lookup failed: ${result?.ErrorMessage ?? 'no result'}`);
    return (result.Results as Array<{ ID: string }> | undefined)?.[0]?.ID ?? null;
}

/** The Person ID the user record links to, or null when it links to no People record. */
export function LinkedPersonRecordID(user: UserInfo): string | null {
    // Typed as numbers in UserInfo; both hold UUIDs.
    const entityID = user.LinkedEntityID as unknown as string | null | undefined;
    const recordID = user.LinkedEntityRecordID as unknown as string | null | undefined;
    if (!entityID || !recordID || !IsValidUUID(recordID)) return null;
    const entity = new Metadata().EntityByID(entityID);
    if (!entity) return null;
    const isPeople = entity.Name === PEOPLE_ENTITY || entity.ParentChain.some((parent) => parent.Name === PEOPLE_ENTITY);
    return isPeople ? recordID : null;
}

/** Shown in place of a task list when the signed-in user has no active Person record. */
export const NO_PERSON_MESSAGE =
    'Your user account is not linked to an active Person record, so no assigned tasks can be shown. Ask an administrator to link one.';

/** Shown in place of a task list when looking up the signed-in user's Person record fails. */
export const PERSON_LOOKUP_FAILED_MESSAGE =
    'Your tasks could not be loaded because looking up your Person record failed. Reload the page to try again.';
