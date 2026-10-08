import { describe, expect, it, vi, beforeEach } from 'vitest';
import type { UserInfo } from '@memberjunction/core';

const { runView } = vi.hoisted(() => ({ runView: vi.fn() }));

const PEOPLE_ID = 'a1a1a1a1-0000-4000-8000-000000000001';
const BC_PEOPLE_ID = 'b2b2b2b2-0000-4000-8000-000000000002';
const OTHER_ENTITY_ID = 'c3c3c3c3-0000-4000-8000-000000000003';
const PERSON_ID = 'd4d4d4d4-0000-4000-8000-000000000004';
const people = { Name: 'MJ_BizApps_Common: People', ParentChain: [] };
const entities: Record<string, unknown> = {
    [PEOPLE_ID]: people,
    [BC_PEOPLE_ID]: { Name: 'BC: People', ParentChain: [people] },
    [OTHER_ENTITY_ID]: { Name: 'Employees', ParentChain: [] },
};

vi.mock('@memberjunction/core', () => ({
    Metadata: class {
        CurrentUser = { ID: 'current-user', Email: 'current@example.com' };
        EntityByID(id: string) {
            return entities[id];
        }
    },
    RunView: class {
        RunView = runView;
    },
}));

import { ResolveCurrentPersonID, PEOPLE_ENTITY } from '../current-person';

const user = (id: string, link?: { entityID: string; recordID: string }): UserInfo =>
    ({ ID: id, Email: `${id}@example.com`, LinkedEntityID: link?.entityID, LinkedEntityRecordID: link?.recordID }) as unknown as UserInfo;

describe('ResolveCurrentPersonID', () => {
    beforeEach(() => {
        runView.mockReset();
    });

    it('returns the ID of the active Person linked to the user', async () => {
        runView.mockResolvedValue({ Success: true, Results: [{ ID: 'person-1' }] });

        await expect(ResolveCurrentPersonID(user('user-1'))).resolves.toBe('person-1');

        const [params] = runView.mock.calls[0];
        expect(params.EntityName).toBe(PEOPLE_ENTITY);
        expect(params.ExtraFilter).toBe(`LinkedUserID = 'user-1' AND Status = 'Active'`);
        expect(params.MaxRows).toBe(1);
    });

    it('uses the user record\'s link to a People subtype, as BC binds users', async () => {
        runView.mockResolvedValue({ Success: true, Results: [{ ID: PERSON_ID }] });

        await expect(ResolveCurrentPersonID(user('user-1', { entityID: BC_PEOPLE_ID, recordID: PERSON_ID }))).resolves.toBe(PERSON_ID);
        expect(runView.mock.calls[0][0].ExtraFilter).toBe(`ID = '${PERSON_ID}' AND Status = 'Active'`);
    });

    it('uses the user record\'s link to People itself', async () => {
        runView.mockResolvedValue({ Success: true, Results: [{ ID: PERSON_ID }] });

        await ResolveCurrentPersonID(user('user-1', { entityID: PEOPLE_ID, recordID: PERSON_ID }));
        expect(runView.mock.calls[0][0].ExtraFilter).toBe(`ID = '${PERSON_ID}' AND Status = 'Active'`);
    });

    it('falls back to LinkedUserID when the user links to another entity', async () => {
        runView.mockResolvedValue({ Success: true, Results: [{ ID: 'person-1' }] });

        await ResolveCurrentPersonID(user('user-1', { entityID: OTHER_ENTITY_ID, recordID: PERSON_ID }));
        expect(runView.mock.calls[0][0].ExtraFilter).toBe(`LinkedUserID = 'user-1' AND Status = 'Active'`);
    });

    it('returns null when the linked Person is not active', async () => {
        runView.mockResolvedValue({ Success: true, Results: [] });

        await expect(ResolveCurrentPersonID(user('user-1', { entityID: BC_PEOPLE_ID, recordID: PERSON_ID }))).resolves.toBeNull();
    });

    it('never uses the email address as the Person ID', async () => {
        runView.mockResolvedValue({ Success: true, Results: [{ ID: 'person-1' }] });

        const id = await ResolveCurrentPersonID(user('user-1'));

        expect(id).not.toBe('user-1@example.com');
        expect(runView.mock.calls[0][0].ExtraFilter).not.toContain('@');
    });

    it('defaults to the signed-in user', async () => {
        runView.mockResolvedValue({ Success: true, Results: [{ ID: 'person-2' }] });

        await expect(ResolveCurrentPersonID()).resolves.toBe('person-2');
        expect(runView.mock.calls[0][0].ExtraFilter).toContain(`LinkedUserID = 'current-user'`);
    });

    it('returns null when the user has no active Person record', async () => {
        runView.mockResolvedValue({ Success: true, Results: [] });

        await expect(ResolveCurrentPersonID(user('user-1'))).resolves.toBeNull();
    });

    it('throws when the lookup fails, rather than reporting no linked Person', async () => {
        runView.mockResolvedValue({ Success: false, ErrorMessage: 'boom', Results: [] });

        await expect(ResolveCurrentPersonID(user('user-1'))).rejects.toThrow('boom');
    });

    it('lets a transport error through', async () => {
        runView.mockRejectedValue(new Error('network down'));

        await expect(ResolveCurrentPersonID(user('user-1'))).rejects.toThrow('network down');
    });

    it('returns null without querying when the user has no ID', async () => {
        await expect(ResolveCurrentPersonID(user(''))).resolves.toBeNull();
        expect(runView).not.toHaveBeenCalled();
    });
});
