import { RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';

/**
 * A person and their MemberJunction account (the meetings plan, § 13.2). bizapps-common has deprecated
 * `People.LinkedUserID` in favour of the user's own link (`User.LinkedEntityID` / `LinkedEntityRecordID`, which names
 * People or an IS-A subtype of it), so both directions look at the user's link first and the person's old column second.
 */
export const PEOPLE_ENTITY = 'MJ_BizApps_Common: People';
export const USERS_ENTITY = 'MJ: Users';

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function uuidOrNull(value: unknown): string | null {
    const text = value == null ? '' : String(value);
    return UUID.test(text) ? text.toUpperCase() : null;
}

/** The entity ids of People and every entity whose ParentID chain reaches it: the entities a user's link may name. */
export function peopleEntityIds(provider: IMetadataProvider): string[] {
    const people = provider.Entities.find((entity) => entity.Name === PEOPLE_ENTITY);
    if (!people) return [];
    const ids = new Set<string>([people.ID.toUpperCase()]);
    let grew = true;
    while (grew) {
        grew = false;
        for (const entity of provider.Entities) {
            const parent = entity.ParentID ? entity.ParentID.toUpperCase() : null;
            if (parent && ids.has(parent) && !ids.has(entity.ID.toUpperCase())) {
                ids.add(entity.ID.toUpperCase());
                grew = true;
            }
        }
    }
    return [...ids];
}

/** The Person a user's own record links to, when the link names People or a subtype of it; else null. */
export function personIdFromUserLink(provider: IMetadataProvider, user: UserInfo): string | null {
    const linked = user as unknown as { LinkedEntityID?: unknown; LinkedEntityRecordID?: unknown };
    const entityId = uuidOrNull(linked.LinkedEntityID);
    const recordId = uuidOrNull(linked.LinkedEntityRecordID);
    if (!entityId || !recordId) return null;
    return peopleEntityIds(provider).includes(entityId) ? recordId : null;
}

/** The Person of a user: the user's link first, then a Person whose deprecated LinkedUserID names the user. Null when neither does. */
export async function personIdForUser(provider: IMetadataProvider, user: UserInfo): Promise<string | null> {
    const linked = personIdFromUserLink(provider, user);
    if (linked) return linked;
    const rows = await RunView.FromMetadataProvider(provider).RunView<{ ID: string }>(
        { EntityName: PEOPLE_ENTITY, ExtraFilter: `LinkedUserID = '${user.ID}'`, Fields: ['ID'], ResultType: 'simple', MaxRows: 1 },
        user,
    );
    return rows.Success && rows.Results.length ? rows.Results[0].ID : null;
}

/** The MemberJunction user of a person: a user whose link names the person first, then the person's deprecated LinkedUserID. */
export async function userIdForPerson(provider: IMetadataProvider, personId: string, contextUser: UserInfo): Promise<string | null> {
    const id = uuidOrNull(personId);
    if (!id) return null;
    const entityIds = peopleEntityIds(provider);
    if (entityIds.length) {
        const users = await RunView.FromMetadataProvider(provider).RunView<{ ID: string }>(
            {
                EntityName: USERS_ENTITY,
                ExtraFilter: `LinkedEntityRecordID = '${id}' AND LinkedEntityID IN (${entityIds.map((e) => `'${e}'`).join(',')})`,
                Fields: ['ID'],
                ResultType: 'simple',
                MaxRows: 1,
            },
            contextUser,
        );
        if (users.Success && users.Results.length) return users.Results[0].ID;
    }
    const people = await RunView.FromMetadataProvider(provider).RunView<{ LinkedUserID: string | null }>(
        { EntityName: PEOPLE_ENTITY, ExtraFilter: `ID = '${id}'`, Fields: ['LinkedUserID'], ResultType: 'simple', MaxRows: 1 },
        contextUser,
    );
    return people.Success && people.Results.length ? uuidOrNull(people.Results[0].LinkedUserID) : null;
}
