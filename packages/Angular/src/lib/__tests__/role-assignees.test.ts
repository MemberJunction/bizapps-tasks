import { describe, expect, it } from 'vitest';
import type { IMetadataProvider, UserInfo } from '@memberjunction/core';
import { AssignedToFilter, CurrentUserRoleIDs, RoleAssigneeName } from '../role-assignees';

const ROLES_ENTITY_ID = 'A0000000-0000-0000-0000-000000000003';
const PEOPLE_ENTITY_ID = 'A0000000-0000-0000-0000-000000000001';
const FINANCE = 'D0000000-0000-0000-0000-00000000000A';

const provider = {
    EntityByName: (name: string) => (name === 'MJ: Roles' ? { ID: ROLES_ENTITY_ID } : undefined),
    Roles: [{ ID: FINANCE, Name: 'Finance' }],
} as unknown as IMetadataProvider;

describe('AssignedToFilter', () => {
    it('matches only the person when there are no roles', () => {
        expect(AssignedToFilter('person-1', [], provider)).toBe(
            `ID IN (SELECT TaskID FROM __mj_BizAppsTasks.vwTaskAssignments WHERE AssigneeRecordID = 'person-1')`,
        );
    });

    it('adds the roles, in both cases, scoped to the MJ: Roles entity', () => {
        expect(AssignedToFilter('person-1', [FINANCE], provider)).toBe(
            `ID IN (SELECT TaskID FROM __mj_BizAppsTasks.vwTaskAssignments WHERE AssigneeRecordID = 'person-1' OR ` +
                `(AssigneeEntityID = '${ROLES_ENTITY_ID}' AND AssigneeRecordID IN ('${FINANCE}','${FINANCE.toLowerCase()}')))`,
        );
    });

    it('escapes the person ID and drops role IDs that are not UUIDs', () => {
        const filter = AssignedToFilter("o'brien", ["x') OR 1=1 --"], provider);
        expect(filter).toContain(`AssigneeRecordID = 'o''brien'`);
        expect(filter).not.toContain('OR 1=1');
        expect(filter).not.toContain('AssigneeEntityID');
    });

    it('matches only the person when no provider is loaded', () => {
        expect(AssignedToFilter('person-1', [FINANCE], undefined as unknown as IMetadataProvider)).not.toContain('AssigneeEntityID');
    });
});

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
