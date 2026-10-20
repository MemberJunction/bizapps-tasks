/**
 * The People a signed-in user is, shared by the server subclasses that need to know.
 *
 * A user is bound to a Person two ways: the user's own `LinkedEntityID`/`LinkedEntityRecordID` link
 * (when it points at People or an IS-A subtype of it), and any Person whose `LinkedUserID` names the
 * user. TaskEntityServer uses this to record who created a task; TaskDecisionEntityServer uses the
 * same filter to recognise the decider, so the Person stamped as a task's creator is always one the
 * decision rule will recognise as that same user.
 *
 * CONNECTS TO:
 *   READS: MJ_BizApps_Common: People
 */
import { RunView, type IMetadataProvider, type IRunViewProvider, type UserInfo } from '@memberjunction/core';
import { IsValidUUID } from '@memberjunction/global';

export const PEOPLE_ENTITY = 'MJ_BizApps_Common: People';

/** A UUID literal for a filter, or an error: every id here reaches SQL text. */
export function GuidLiteral(id: string, label: string): string {
    if (!IsValidUUID(id)) throw new Error(`${label} '${id}' is not a valid ID.`);
    return `'${id}'`;
}

/** True when the entity is People or an IS-A subtype of it. */
export function IsPeopleEntity(provider: IMetadataProvider, entityID: string): boolean {
    const entity = provider.EntityByID(entityID);
    if (!entity) return false;
    return entity.Name === PEOPLE_ENTITY || (entity.ParentChain ?? []).some((parent) => parent.Name === PEOPLE_ENTITY);
}

/** The user's own People link, when it is a valid People record; otherwise null. */
function linkedPersonID(provider: IMetadataProvider, user: UserInfo): string | null {
    // UserInfo types these as numbers; they carry GUID strings at runtime.
    const linkedEntityID = user.LinkedEntityID != null ? String(user.LinkedEntityID) : '';
    const linkedRecordID = user.LinkedEntityRecordID != null ? String(user.LinkedEntityRecordID) : '';
    return IsValidUUID(linkedEntityID) && IsValidUUID(linkedRecordID) && IsPeopleEntity(provider, linkedEntityID) ? linkedRecordID : null;
}

/** A People filter matching every Person bound to the user. */
export function PeopleFilterForUser(provider: IMetadataProvider, user: UserInfo): string {
    const clauses = [`LinkedUserID = ${GuidLiteral(user.ID, 'UserID')}`];
    const linked = linkedPersonID(provider, user);
    if (linked) clauses.push(`ID = '${linked}'`);
    return clauses.join(' OR ');
}

/**
 * The one Person to record for the user: their own People link when it resolves, else the first
 * Person linked back to them. Null when the user has no Person (a service account, say).
 *
 * @throws when the People lookup fails, so a caller recording identity can fail closed.
 */
export async function PrimaryPersonIDForUser(
    provider: IMetadataProvider,
    runViewProvider: IRunViewProvider | undefined,
    user: UserInfo,
): Promise<string | null> {
    const res = await new RunView(runViewProvider).RunView<{ ID: string }>(
        { EntityName: PEOPLE_ENTITY, ExtraFilter: PeopleFilterForUser(provider, user), Fields: ['ID'], OrderBy: 'ID', ResultType: 'simple', BypassCache: true },
        user,
    );
    if (!res?.Success) throw new Error(res?.ErrorMessage ?? 'the People lookup returned no result');
    const ids = (res.Results ?? []).map((p) => p.ID);
    const linked = linkedPersonID(provider, user);
    return ids.find((id) => !!linked && id.toLowerCase() === linked.toLowerCase()) ?? ids[0] ?? null;
}
