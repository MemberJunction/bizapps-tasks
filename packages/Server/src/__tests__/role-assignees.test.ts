import { beforeEach, describe, expect, it, vi } from 'vitest';

const ROLES_ENTITY_ID = 'A0000000-0000-0000-0000-000000000003';
const FINANCE = 'D0000000-0000-0000-0000-000000000001';
const SALES = 'D0000000-0000-0000-0000-000000000002';
const ANA = 'B0000000-0000-0000-0000-000000000001';
const BEN = 'B0000000-0000-0000-0000-000000000002';
const GONE = 'B0000000-0000-0000-0000-000000000003';

type ViewParams = { EntityName: string; ExtraFilter?: string };

const { runView } = vi.hoisted(() => ({ runView: vi.fn() }));

vi.mock('@memberjunction/core', () => ({
    Metadata: { Provider: undefined },
    RunView: class { RunView = runView; },
}));

import { IsRoleEntityID, ResolveUserIDsForRoles, RoleName } from '../role-assignees.js';
import type { IMetadataProvider, UserInfo } from '@memberjunction/core';

const provider = {
    EntityByName: (name: string) => (name === 'MJ: Roles' ? { ID: ROLES_ENTITY_ID } : undefined),
    Roles: [{ ID: FINANCE, Name: 'Finance' }],
} as unknown as IMetadataProvider;
const contextUser = { ID: 'ctx' } as UserInfo;

describe('IsRoleEntityID', () => {
    it('matches the MJ: Roles entity in any case', () => {
        expect(IsRoleEntityID(ROLES_ENTITY_ID.toLowerCase(), provider)).toBe(true);
    });

    it('rejects other entities and empty IDs', () => {
        expect(IsRoleEntityID('A0000000-0000-0000-0000-000000000001', provider)).toBe(false);
        expect(IsRoleEntityID(null, provider)).toBe(false);
        expect(IsRoleEntityID('', provider)).toBe(false);
    });

    it('is false when no provider is loaded', () => {
        expect(IsRoleEntityID(ROLES_ENTITY_ID, undefined as unknown as IMetadataProvider)).toBe(false);
    });
});

describe('RoleName', () => {
    it('reads the name from metadata', () => {
        expect(RoleName(FINANCE.toLowerCase(), provider)).toBe('Finance');
        expect(RoleName(SALES, provider)).toBeNull();
    });
});

describe('ResolveUserIDsForRoles', () => {
    beforeEach(() => {
        runView.mockReset();
        runView.mockImplementation((p: ViewParams) => {
            if (p.EntityName === 'MJ: User Roles') {
                return Promise.resolve({ Success: true, Results: [{ UserID: ANA }, { UserID: BEN }, { UserID: ANA.toLowerCase() }, { UserID: GONE }] });
            }
            return Promise.resolve({ Success: true, Results: [{ ID: ANA, IsActive: true }, { ID: BEN, IsActive: true }, { ID: GONE, IsActive: false }] });
        });
    });

    it('returns each active member once', async () => {
        expect(await ResolveUserIDsForRoles([FINANCE], contextUser)).toEqual([ANA, BEN]);
        const [rolesCall, usersCall] = runView.mock.calls.map((c) => c[0] as ViewParams);
        expect(rolesCall.ExtraFilter).toBe(`RoleID IN ('${FINANCE}')`);
        expect(usersCall.ExtraFilter).toBe(`ID IN ('${ANA}','${BEN}','${GONE}')`);
    });

    it('drops IDs that are not UUIDs before querying', async () => {
        await ResolveUserIDsForRoles([FINANCE, "x' OR 1=1 --", FINANCE.toLowerCase()], contextUser);
        expect((runView.mock.calls[0][0] as ViewParams).ExtraFilter).toBe(`RoleID IN ('${FINANCE}')`);
    });

    it('reads nothing for no valid roles', async () => {
        expect(await ResolveUserIDsForRoles(['not-a-uuid'], contextUser)).toEqual([]);
        expect(runView).not.toHaveBeenCalled();
    });

    it('returns no users for a role with no members', async () => {
        runView.mockResolvedValueOnce({ Success: true, Results: [] });
        expect(await ResolveUserIDsForRoles([SALES], contextUser)).toEqual([]);
        expect(runView).toHaveBeenCalledOnce();
    });

    it('throws when a lookup fails', async () => {
        runView.mockResolvedValueOnce({ Success: false, ErrorMessage: 'database down', Results: [] });
        await expect(ResolveUserIDsForRoles([FINANCE], contextUser)).rejects.toThrow('database down');
    });
});
