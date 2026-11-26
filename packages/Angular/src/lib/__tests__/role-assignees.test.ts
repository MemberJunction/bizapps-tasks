import { describe, expect, it, vi } from 'vitest';
import type { IMetadataProvider, IRunViewProvider, RunViewParams, UserInfo } from '@memberjunction/core';
import {
    AssignedToFilter,
    BuildTaskAssignmentPredicate,
    BuildTaskIDsInFilter,
    ChunkTaskIDs,
    CurrentUserRoleIDs,
    LoadAssignedTaskIDs,
    RoleAssigneeName,
    TASK_ASSIGNMENTS_ENTITY,
} from '../role-assignees';

const ROLES_ENTITY_ID = 'A0000000-0000-0000-0000-000000000003';
const PEOPLE_ENTITY_ID = 'A0000000-0000-0000-0000-000000000001';
const FINANCE = 'D0000000-0000-0000-0000-00000000000A';

const provider = {
    EntityByName: (name: string) => (name === 'MJ: Roles' ? { ID: ROLES_ENTITY_ID } : undefined),
    Roles: [{ ID: FINANCE, Name: 'Finance' }],
} as unknown as IMetadataProvider;

describe('BuildTaskAssignmentPredicate', () => {
    it('builds direct entity-field predicate without raw vwTaskAssignments subqueries', () => {
        const pred = BuildTaskAssignmentPredicate('person-1', [FINANCE], provider);
        expect(pred).toBe(
            `AssigneeRecordID = 'person-1' OR ` +
                `(AssigneeEntityID = '${ROLES_ENTITY_ID}' AND AssigneeRecordID IN ('${FINANCE}','${FINANCE.toLowerCase()}'))`,
        );
        expect(pred).not.toContain('vwTaskAssignments');
        expect(pred).not.toContain('SELECT');
    });
});

describe('LoadAssignedTaskIDs', () => {
    it('queries MJ_BizApps_Tasks: Task Assignments via provider RunView and deduplicates TaskIDs case-insensitively', async () => {
        const runViewSpy = vi.fn().mockResolvedValue({
            Success: true,
            Results: [
                { TaskID: 'T1-UPPER' },
                { TaskID: 't1-upper' },
                { TaskID: 'T2-SECOND' },
                { TaskID: '' },
            ],
        });
        const mockProvider = {
            EntityByName: (name: string) => (name === 'MJ: Roles' ? { ID: ROLES_ENTITY_ID } : undefined),
            RunView: runViewSpy,
            RunViews: vi.fn(),
        } as unknown as IMetadataProvider & IRunViewProvider;

        const res = await LoadAssignedTaskIDs('person-1', [FINANCE], mockProvider, true);

        expect(res).toEqual({ Success: true, TaskIDs: ['T1-UPPER', 'T2-SECOND'] });
        expect(runViewSpy).toHaveBeenCalledTimes(1);
        const calledParams = runViewSpy.mock.calls[0][0] as RunViewParams;
        expect(calledParams.EntityName).toBe(TASK_ASSIGNMENTS_ENTITY);
        expect(calledParams.Fields).toEqual(['TaskID']);
        expect(calledParams.ResultType).toBe('simple');
        expect(calledParams.ExtraFilter).toContain(`AssigneeRecordID = 'person-1'`);
        expect(calledParams.ExtraFilter).toContain(`AssigneeEntityID = '${ROLES_ENTITY_ID}'`);
        expect(calledParams.ExtraFilter).not.toContain('vwTaskAssignments');
    });

    it('returns empty TaskIDs with zero queries when personID is empty', async () => {
        const runViewSpy = vi.fn();
        const mockProvider = {
            EntityByName: () => undefined,
            RunView: runViewSpy,
            RunViews: vi.fn(),
        } as unknown as IMetadataProvider & IRunViewProvider;

        const res = await LoadAssignedTaskIDs('', [FINANCE], mockProvider);
        expect(res).toEqual({ Success: true, TaskIDs: [] });
        expect(runViewSpy).not.toHaveBeenCalled();
    });

    it('surfaces server errors cleanly instead of masking them as empty', async () => {
        const runViewSpy = vi.fn().mockResolvedValue({
            Success: false,
            ErrorMessage: 'Permission denied on Task Assignments',
            Results: [],
        });
        const mockProvider = {
            EntityByName: () => undefined,
            RunView: runViewSpy,
            RunViews: vi.fn(),
        } as unknown as IMetadataProvider & IRunViewProvider;

        const res = await LoadAssignedTaskIDs('person-1', [], mockProvider);
        expect(res).toEqual({
            Success: false,
            TaskIDs: [],
            ErrorMessage: 'Permission denied on Task Assignments',
        });
    });
});

describe('ChunkTaskIDs & BuildTaskIDsInFilter', () => {
    it('returns 1 = 0 for empty IDs', () => {
        expect(ChunkTaskIDs([])).toEqual([]);
        expect(BuildTaskIDsInFilter([])).toBe('1 = 0');
    });

    it('chunks large ID lists cleanly and builds OR-joined IN clauses', () => {
        const ids = Array.from({ length: 450 }, (_, idx) => `task-${idx}`);
        const chunks = ChunkTaskIDs(ids, 400);
        expect(chunks).toHaveLength(2);
        expect(chunks[0]).toHaveLength(400);
        expect(chunks[1]).toHaveLength(50);

        const filter = BuildTaskIDsInFilter(['a', 'b', 'c'], 2);
        expect(filter).toBe(`(ID IN ('a','b') OR ID IN ('c'))`);
    });
});

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
