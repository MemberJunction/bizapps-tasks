import { describe, expect, it, vi, beforeEach } from 'vitest';
import type { UserInfo } from '@memberjunction/core';

const { runView } = vi.hoisted(() => ({ runView: vi.fn() }));
vi.mock('@memberjunction/core', () => ({
    Metadata: class {
        CurrentUser = { ID: 'current-user', Email: 'current@example.com' };
    },
    RunView: class {
        RunView = runView;
    },
}));

import { ResolveCurrentPersonID, PEOPLE_ENTITY } from '../current-person';

const user = (id: string): UserInfo => ({ ID: id, Email: `${id}@example.com` }) as UserInfo;

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

    it('returns null when the lookup fails', async () => {
        runView.mockResolvedValue({ Success: false, ErrorMessage: 'boom', Results: [] });

        await expect(ResolveCurrentPersonID(user('user-1'))).resolves.toBeNull();
    });

    it('returns null without querying when the user has no ID', async () => {
        await expect(ResolveCurrentPersonID(user(''))).resolves.toBeNull();
        expect(runView).not.toHaveBeenCalled();
    });
});
