import { describe, it, expect, vi, beforeEach } from 'vitest';

const runViewMock = vi.fn();
vi.mock('@memberjunction/core', () => ({
    RunView: { FromMetadataProvider: () => ({ RunView: (...args: unknown[]) => runViewMock(...args) }) },
}));

import { peopleEntityIds, personIdForUser, personIdFromUserLink, userIdForPerson } from '../person-user.js';
import type { IMetadataProvider, UserInfo } from '@memberjunction/core';

const PEOPLE = 'A0000000-0000-4000-8000-00000000000A';
const STAFF = 'A0000000-0000-4000-8000-00000000000B'; // a subtype of People
const OTHER = 'A0000000-0000-4000-8000-00000000000C';
const PERSON = 'B0000000-0000-4000-8000-000000000001';
const provider = {
    Entities: [
        { ID: PEOPLE, Name: 'MJ_BizApps_Common: People', ParentID: null },
        { ID: STAFF, Name: 'Acme: Staff', ParentID: PEOPLE },
        { ID: OTHER, Name: 'MJ: Users', ParentID: null },
    ],
} as unknown as IMetadataProvider;
const userLinked = (entityId: string | null, recordId: string | null): UserInfo =>
    ({ ID: 'U1', LinkedEntityID: entityId, LinkedEntityRecordID: recordId }) as unknown as UserInfo;

beforeEach(() => runViewMock.mockReset());

describe('a person and their MemberJunction user', () => {
    it('knows People and its subtypes', () => {
        expect(peopleEntityIds(provider).sort()).toEqual([PEOPLE, STAFF].sort());
    });

    it('reads the person from the user\'s own link, to People or a subtype, and not from a link elsewhere', () => {
        expect(personIdFromUserLink(provider, userLinked(PEOPLE, PERSON))).toBe(PERSON);
        expect(personIdFromUserLink(provider, userLinked(STAFF.toLowerCase(), PERSON))).toBe(PERSON);
        expect(personIdFromUserLink(provider, userLinked(OTHER, PERSON))).toBeNull();
        expect(personIdFromUserLink(provider, userLinked(null, null))).toBeNull();
    });

    it('falls back to the deprecated LinkedUserID when the user links nothing', async () => {
        runViewMock.mockResolvedValueOnce({ Success: true, Results: [{ ID: PERSON }] });
        expect(await personIdForUser(provider, userLinked(null, null))).toBe(PERSON);
        expect(runViewMock.mock.calls[0][0]).toMatchObject({ EntityName: 'MJ_BizApps_Common: People', ExtraFilter: "LinkedUserID = 'U1'" });
        runViewMock.mockResolvedValueOnce({ Success: true, Results: [] });
        expect(await personIdForUser(provider, userLinked(null, null))).toBeNull();
    });

    it('finds the user of a person through the user link first, then the person\'s LinkedUserID', async () => {
        runViewMock.mockResolvedValueOnce({ Success: true, Results: [{ ID: 'U9' }] });
        expect(await userIdForPerson(provider, PERSON, userLinked(null, null))).toBe('U9');
        expect(runViewMock.mock.calls[0][0]).toMatchObject({ EntityName: 'MJ: Users' });
        expect(String(runViewMock.mock.calls[0][0].ExtraFilter)).toContain(`LinkedEntityRecordID = '${PERSON}'`);

        runViewMock.mockReset();
        runViewMock.mockResolvedValueOnce({ Success: true, Results: [] }).mockResolvedValueOnce({ Success: true, Results: [{ LinkedUserID: 'c0000000-0000-4000-8000-000000000001' }] });
        expect(await userIdForPerson(provider, PERSON, userLinked(null, null))).toBe('C0000000-0000-4000-8000-000000000001');
    });

    it('answers nothing for a person id that is not an id', async () => {
        expect(await userIdForPerson(provider, 'nope', userLinked(null, null))).toBeNull();
        expect(runViewMock).not.toHaveBeenCalled();
    });
});
