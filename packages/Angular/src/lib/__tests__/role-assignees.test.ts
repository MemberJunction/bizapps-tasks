import { describe, expect, it } from 'vitest';
import type { IMetadataProvider, UserInfo } from '@memberjunction/core';
import { CurrentUserRoleIDs, RoleAssigneeName } from '../role-assignees';

const ROLES_ENTITY_ID = 'A0000000-0000-0000-0000-000000000003';
const PEOPLE_ENTITY_ID = 'A0000000-0000-0000-0000-000000000001';
const FINANCE = 'D0000000-0000-0000-0000-00000000000A';

const provider = {
    EntityByName: (name: string) => (name === 'MJ: Roles' ? { ID: ROLES_ENTITY_ID } : undefined),
    Roles: [{ ID: FINANCE, Name: 'Finance' }],
} as unknown as IMetadataProvider;

// AssignedToFilter is tested in task-filters.test.ts, where it is defined.

describe('CurrentUserRoleIDs', () => {
    it("returns the user's role IDs", () => {
        const user = { UserRoles: [{ RoleID: FINANCE }, { RoleID: 'not-a-uuid' }] } as unknown as UserInfo;
        expect(CurrentUserRoleIDs(user)).toEqual([FINANCE]);
    });

    it('returns none without a user', () => {
        expect(CurrentUserRoleIDs(undefined)).toEqual([]);
    });
});

describe('RoleAssigneeName', () => {
    it('names a role assignee', () => {
        expect(RoleAssigneeName(ROLES_ENTITY_ID.toLowerCase(), FINANCE.toLowerCase(), provider)).toBe('Finance');
    });

    it('is null for a person assignee', () => {
        expect(RoleAssigneeName(PEOPLE_ENTITY_ID, FINANCE, provider)).toBeNull();
    });
});
