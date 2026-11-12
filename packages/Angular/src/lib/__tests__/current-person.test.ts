import { describe, expect, it, vi, beforeEach } from 'vitest';
import type { UserInfo } from '@memberjunction/core';

// The resolver's own rules (the user's People link first, LinkedUserID fallback, UUID checks) are
// covered by @mj-biz-apps/common-entities' tests; these cover what this wrapper adds.
const { resolvePerson, provider, currentUser } = vi.hoisted(() => ({
    resolvePerson: vi.fn(),
    provider: { name: 'provider' },
    currentUser: { ID: 'current-user', Email: 'current@example.com' },
}));

vi.mock('@memberjunction/core', () => ({
    Metadata: class {
        static Provider = provider;
        CurrentUser = currentUser;
    },
}));
vi.mock('@mj-biz-apps/common-entities', () => ({ ResolvePersonIDForUser: resolvePerson }));

import { ResolveCurrentPersonID } from '../current-person';

const user = (id: string): UserInfo => ({ ID: id, Email: `${id}@example.com` }) as unknown as UserInfo;

describe('ResolveCurrentPersonID', () => {
    beforeEach(() => {
        resolvePerson.mockReset();
    });

    it('asks the common resolver for the user\'s active Person', async () => {
        resolvePerson.mockResolvedValue('person-1');

        await expect(ResolveCurrentPersonID(user('user-1'))).resolves.toBe('person-1');

        const [passedUser, passedProvider, , options] = resolvePerson.mock.calls[0];
        expect(passedUser.ID).toBe('user-1');
        expect(passedProvider).toBe(provider);
        expect(options).toEqual({ ActiveOnly: true });
    });

    it('defaults to the signed-in user', async () => {
        resolvePerson.mockResolvedValue('person-2');

        await expect(ResolveCurrentPersonID()).resolves.toBe('person-2');
        expect(resolvePerson.mock.calls[0][0]).toBe(currentUser);
    });

    it('returns null when the user has no active Person record', async () => {
        resolvePerson.mockResolvedValue(null);

        await expect(ResolveCurrentPersonID(user('user-1'))).resolves.toBeNull();
    });

    it('lets a failed lookup through, rather than reporting no linked Person', async () => {
        resolvePerson.mockRejectedValue(new Error('Person lookup failed: boom'));

        await expect(ResolveCurrentPersonID(user('user-1'))).rejects.toThrow('boom');
    });
});
