import { describe, expect, it, vi } from 'vitest';
import { BaseEntity, RunView, UserInfo, type IMetadataProvider, type RunViewParams, type RunViewResult } from '@memberjunction/core';
import { type MJAIAgentUserPolicyEntity } from '@memberjunction/core-entities';
import { AgentUserPolicyEngine } from '@memberjunction/ai-core-plus';
import {
    TasksBulkUpdateServerOperation,
    TasksInstantiateTemplateServerOperation,
    TasksRunRecurringPlaybooksServerOperation,
} from '../TasksRemoteOperationsServer.js';
import { TaskEntityServer } from '../TaskEntityServer.js';

const TASK_1 = '11111111-1111-4111-8111-111111111111';
const TASK_2 = '22222222-2222-4222-8222-222222222222';
const ORG_1 = '33333333-3333-4333-8333-333333333333';
const ORG_2 = '33333333-3333-4333-8333-333333333334';
const CAT_1 = '44444444-4444-4444-8444-444444444444';
const ROLE_PRIMARY = '55555555-5555-4555-8555-555555555555';
const PERSON_ENTITY_ID = '66666666-6666-4666-8666-666666666666';
const ROLE_ENTITY_ID = '66666666-6666-4666-8666-666666666667';
const PERSON_1 = '77777777-7777-4777-8777-777777777777';
const PERSON_OLD = '88888888-8888-4888-8888-888888888888';
const MJ_ROLE_1 = '88888888-8888-4888-8888-888888888889';
const TAG_1 = '99999999-9999-4999-8999-999999999999';
const TEMPLATE_1 = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const ITEM_PARENT = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
const ITEM_CHILD = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc';
const TYPE_1 = 'dddddddd-dddd-4ddd-8ddd-dddddddddddd';
const STAGE_1 = 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee';

interface MockMetadataProviderOverrides {
    EntityByName?: (name: string) => { ID: string; Name: string } | undefined;
    GetEntityObject?: (entityName: string) => Promise<object>;
}

function makeTestProvider(overrides: MockMetadataProviderOverrides): IMetadataProvider {
    const base: IMetadataProvider = Object.create(Object.prototype);
    return Object.assign(base, overrides);
}

function makeTestUser(): UserInfo {
    return new UserInfo(makeTestProvider({}), {
        ID: 'user-1',
        Name: 'Tester',
        Email: 'tester@example.com',
    });
}

const TEST_USER = makeTestUser();

function makeRunViewResult<T extends object>(results: T[], errorMessage = ''): RunViewResult<T> {
    return {
        Success: errorMessage.length === 0,
        Results: results,
        RowCount: results.length,
        TotalRowCount: results.length,
        ExecutionTime: 0,
        ErrorMessage: errorMessage,
    };
}

function makeTestRunView(impl: (params: RunViewParams) => Promise<RunViewResult>): RunView {
    const rv = new RunView();
    vi.spyOn(rv, 'RunView').mockImplementation(impl);
    return rv;
}

interface MockTaskRecord {
    ID: string;
    Name: string;
    Description: string | null;
    Status: 'Pending' | 'Open' | 'InProgress' | 'Blocked' | 'Completed' | 'Cancelled';
    Priority: 'Low' | 'Medium' | 'High' | 'Critical';
    PercentComplete: number;
    CompletedAt: Date | null;
    DueAt: Date | null;
    StartedAt: Date | null;
    OrganizationID: string | null;
    CategoryID: string | null;
    TypeID: string | null;
    TaskTypeStatusID: string | null;
    ParentID: string | null;
    HoursEstimated: number | null;
    Sequence: number;
    Dirty: boolean;
    saved: boolean;
    LatestResult?: { CompleteMessage?: string };
    InnerLoad: (key: { KeyValuePairs: Array<{ Value: string }> }) => Promise<boolean>;
    NewRecord: () => boolean;
    Save: () => Promise<boolean>;
}

interface MockAssignmentRecord {
    ID: string;
    TaskID: string;
    AssigneeEntityID: string;
    AssigneeRecordID: string;
    RoleID: string | null;
    deleted: boolean;
    saved: boolean;
    NewRecord: () => boolean;
    Save: () => Promise<boolean>;
    Delete: () => Promise<boolean>;
}

interface MockTagLinkRecord {
    TaskID: string;
    TagID: string;
    saved: boolean;
    NewRecord: () => boolean;
    Save: () => Promise<boolean>;
}

interface MockDepRecord {
    TaskID: string;
    DependsOnTaskID: string;
    DependencyType: string;
    saved: boolean;
    NewRecord: () => boolean;
    Save: () => Promise<boolean>;
}

function makeMockTask(id: string, seed?: Partial<MockTaskRecord>): MockTaskRecord {
    const rec: MockTaskRecord = {
        ID: id,
        Name: 'Sample Task',
        Description: null,
        Status: 'Open',
        Priority: 'Medium',
        PercentComplete: 0,
        CompletedAt: null,
        DueAt: new Date('2026-11-20T12:00:00.000Z'),
        StartedAt: new Date('2026-11-18T12:00:00.000Z'),
        OrganizationID: null,
        CategoryID: null,
        TypeID: null,
        TaskTypeStatusID: null,
        ParentID: null,
        HoursEstimated: null,
        Sequence: 100,
        Dirty: false,
        saved: false,
        InnerLoad: async () => true,
        NewRecord: () => true,
        Save: async () => {
            rec.saved = true;
            rec.Dirty = false;
            return true;
        },
        ...seed,
    };
    return new Proxy(rec, {
        set(target, prop, value) {
            if (prop !== 'Dirty' && prop !== 'saved') {
                target.Dirty = true;
            }
            Reflect.set(target, prop, value);
            return true;
        },
    });
}

function makeBulkHarness(tasks: MockTaskRecord[], options?: {
    existingAssignments?: Map<string, MockAssignmentRecord[]>;
    existingTagTaskIDs?: Set<string>;
}) {
    const tasksById = new Map(tasks.map((t) => [t.ID.toLowerCase(), t]));
    const createdAssignments: MockAssignmentRecord[] = [];
    const createdTagLinks: MockTagLinkRecord[] = [];
    const existingAssignments = options?.existingAssignments ?? new Map<string, MockAssignmentRecord[]>();
    const existingTagTaskIDs = options?.existingTagTaskIDs ?? new Set<string>();

    const provider = makeTestProvider({
        EntityByName: vi.fn((name: string) => {
            if (name === 'MJ_BizApps_Common: People') return { ID: PERSON_ENTITY_ID, Name: name };
            if (name === 'MJ: Roles') return { ID: ROLE_ENTITY_ID, Name: name };
            return undefined;
        }),
        GetEntityObject: vi.fn(async (entityName: string) => {
            if (entityName === 'MJ_BizApps_Tasks: Tasks') {
                let loaded: MockTaskRecord | undefined;
                const shell = {
                    InnerLoad: async (ck: { KeyValuePairs: Array<{ Value: string }> }) => {
                        loaded = tasksById.get(String(ck.KeyValuePairs[0].Value).toLowerCase());
                        return Boolean(loaded);
                    },
                };
                return new Proxy(shell, {
                    get(_t, prop) {
                        if (prop === 'InnerLoad') return shell.InnerLoad;
                        return loaded ? Reflect.get(loaded, prop) : undefined;
                    },
                    set(_t, prop, value) {
                        if (loaded) Reflect.set(loaded, prop, value);
                        return true;
                    },
                });
            }
            if (entityName === 'MJ_BizApps_Tasks: Task Assignments') {
                const rec: MockAssignmentRecord = {
                    ID: `assign-${createdAssignments.length + 1}`,
                    TaskID: '',
                    AssigneeEntityID: '',
                    AssigneeRecordID: '',
                    RoleID: null,
                    deleted: false,
                    saved: false,
                    NewRecord: () => true,
                    Save: async () => {
                        rec.saved = true;
                        createdAssignments.push(rec);
                        return true;
                    },
                    Delete: async () => {
                        rec.deleted = true;
                        return true;
                    },
                };
                return rec;
            }
            if (entityName === 'MJ_BizApps_Tasks: Task Tag Links') {
                const rec: MockTagLinkRecord = {
                    TaskID: '',
                    TagID: '',
                    saved: false,
                    NewRecord: () => true,
                    Save: async () => {
                        rec.saved = true;
                        createdTagLinks.push(rec);
                        return true;
                    },
                };
                return rec;
            }
            throw new Error(`Unexpected entity ${entityName}`);
        }),
    });

    const runViewFn = vi.fn(async (params: RunViewParams): Promise<RunViewResult> => {
        if (params.EntityName === 'MJ_BizApps_Tasks: Task Types') {
            if (params.ExtraFilter?.toLowerCase().includes(TYPE_1.toLowerCase())) {
                return makeRunViewResult([
                    { ID: TYPE_1, Name: 'General', Code: 'GENERAL', ExtensionEntity: null, IsActive: true },
                ]);
            }
            return makeRunViewResult([]);
        }
        if (params.EntityName === 'MJ_BizApps_Tasks: Task Roles') {
            return makeRunViewResult([{ ID: ROLE_PRIMARY, Name: 'Primary' }]);
        }
        if (params.EntityName === 'MJ_BizApps_Tasks: Task Assignments') {
            for (const [tid, list] of existingAssignments.entries()) {
                if (params.ExtraFilter?.toLowerCase().includes(tid.toLowerCase())) {
                    return makeRunViewResult(list);
                }
            }
            return makeRunViewResult([]);
        }
        if (params.EntityName === 'MJ_BizApps_Tasks: Task Tag Links') {
            for (const tid of existingTagTaskIDs) {
                if (params.ExtraFilter?.toLowerCase().includes(tid.toLowerCase())) {
                    return makeRunViewResult([{ ID: 'existing-tag-link' }]);
                }
            }
            return makeRunViewResult([]);
        }
        return makeRunViewResult([]);
    });

    const runViewSpy = vi.spyOn(RunView, 'FromMetadataProvider').mockReturnValue(makeTestRunView(runViewFn));

    return { provider, runViewSpy, createdAssignments, createdTagLinks };
}

describe('TasksBulkUpdateServerOperation', () => {
    it('updates scalar fields, shifts DueAt & StartedAt, replaces assignees, and attaches tags in one server RPC', async () => {
        const task1 = makeMockTask(TASK_1);
        const task2 = makeMockTask(TASK_2, {
            DueAt: new Date('2026-11-25T12:00:00.000Z'),
            StartedAt: null,
        });
        const oldAssignment: MockAssignmentRecord = {
            ID: 'assign-old',
            TaskID: TASK_1,
            AssigneeEntityID: PERSON_ENTITY_ID,
            AssigneeRecordID: PERSON_OLD,
            RoleID: ROLE_PRIMARY,
            deleted: false,
            saved: true,
            NewRecord: () => true,
            Save: async () => true,
            Delete: async () => {
                oldAssignment.deleted = true;
                return true;
            },
        };
        const { provider, runViewSpy, createdAssignments, createdTagLinks } = makeBulkHarness(
            [task1, task2],
            { existingAssignments: new Map([[TASK_1, [oldAssignment]]]) },
        );

        try {
            const op = new TasksBulkUpdateServerOperation();
            const envelope = await op.ExecuteServer(
                {
                    TaskIDs: [TASK_1, TASK_2],
                    Status: 'Completed',
                    Priority: 'High',
                    DueDateMode: 'shift',
                    ShiftDays: 3,
                    OrganizationMode: 'set',
                    OrganizationID: ORG_1,
                    CategoryMode: 'set',
                    CategoryID: CAT_1,
                    AssigneeMode: 'replace',
                    AssigneeEntityName: 'MJ_BizApps_Common: People',
                    AssigneeRecordID: PERSON_1,
                    AddTagID: TAG_1,
                },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );

            expect(envelope.Success).toBe(true);
            const result = envelope.Output!;
            expect(result.TotalRequested).toBe(2);
            expect(result.UpdatedCount).toBe(2);
            expect(result.FailedCount).toBe(0);

            expect(task1.Status).toBe('Completed');
            expect(task1.PercentComplete).toBe(100);
            expect(task1.CompletedAt).toBeInstanceOf(Date);
            expect(task1.Priority).toBe('High');
            expect(task1.OrganizationID).toBe(ORG_1);
            expect(task1.CategoryID).toBe(CAT_1);
            expect(task1.DueAt?.toISOString().slice(0, 10)).toBe('2026-11-23');
            expect(task1.StartedAt?.toISOString().slice(0, 10)).toBe('2026-11-21');

            expect(task2.DueAt?.toISOString().slice(0, 10)).toBe('2026-11-28');
            expect(task2.StartedAt).toBeNull();

            expect(oldAssignment.deleted).toBe(true);
            expect(createdAssignments).toHaveLength(2);
            expect(createdAssignments.every((a) => a.AssigneeRecordID === PERSON_1 && a.RoleID === ROLE_PRIMARY)).toBe(true);
            expect(createdTagLinks).toHaveLength(2);
        } finally {
            runViewSpy.mockRestore();
        }
    });

    it('supports DueDateMode set/clear, StartDateMode set/clear, OrganizationMode clear, CategoryMode clear, TypeID, and TaskTypeStatusID', async () => {
        const task1 = makeMockTask(TASK_1, { OrganizationID: ORG_1, CategoryID: CAT_1 });
        const { provider, runViewSpy } = makeBulkHarness([task1]);

        try {
            const op = new TasksBulkUpdateServerOperation();
            const setRes = await op.ExecuteServer(
                {
                    TaskIDs: [TASK_1],
                    DueDateMode: 'set',
                    DueAt: '2026-12-15',
                    StartDateMode: 'set',
                    StartedAt: '2026-12-01',
                    TypeID: TYPE_1,
                    TaskTypeStatusID: STAGE_1,
                },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );
            expect(setRes.Success).toBe(true);
            expect(task1.DueAt?.toISOString().slice(0, 10)).toBe('2026-12-15');
            expect(task1.StartedAt?.toISOString().slice(0, 10)).toBe('2026-12-01');
            expect(task1.TypeID).toBe(TYPE_1);
            expect(task1.TaskTypeStatusID).toBe(STAGE_1);

            const clearRes = await op.ExecuteServer(
                {
                    TaskIDs: [TASK_1],
                    DueDateMode: 'clear',
                    StartDateMode: 'clear',
                    OrganizationMode: 'clear',
                    CategoryMode: 'clear',
                },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );
            expect(clearRes.Success).toBe(true);
            expect(task1.DueAt).toBeNull();
            expect(task1.StartedAt).toBeNull();
            expect(task1.OrganizationID).toBeNull();
            expect(task1.CategoryID).toBeNull();
        } finally {
            runViewSpy.mockRestore();
        }
    });

    it('rejects bulk-assigning tasks to inactive or legacy OKR TaskTypes (PRIORITY_OBJECTIVE / KEY_RESULT)', async () => {
        const task1 = makeMockTask(TASK_1);
        const { provider, runViewSpy } = makeBulkHarness([task1]);

        try {
            const op = new TasksBulkUpdateServerOperation();
            const legacyIdRes = await op.ExecuteServer(
                {
                    TaskIDs: [TASK_1],
                    TypeID: '8D42A1B9-3E71-4C5A-9F20-1B6E8D3A9C01',
                },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );
            expect(legacyIdRes.Success).toBe(false);
            expect(legacyIdRes.ErrorMessage).toMatch(/inactive legacy OKR/i);
            expect(task1.saved).toBe(false);

            // Also rejects any custom inactive TaskType returned by RunView
            const inactiveCustomId = 'dddddddd-dddd-4ddd-8ddd-dddddddd0099';
            runViewSpy.mockReturnValueOnce(
                makeTestRunView(async () =>
                    makeRunViewResult([
                        { ID: inactiveCustomId, Name: 'Retired Custom', Code: 'RETIRED', IsActive: false },
                    ]),
                ),
            );

            const inactiveRes = await op.ExecuteServer(
                {
                    TaskIDs: [TASK_1],
                    TypeID: inactiveCustomId,
                },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );
            expect(inactiveRes.Success).toBe(false);
            expect(inactiveRes.ErrorMessage).toMatch(/inactive or managed outside generic task creation/i);
            expect(task1.saved).toBe(false);

            // Fails closed when TaskType RunView fails
            const errorTypeId = 'dddddddd-dddd-4ddd-8ddd-dddddddd0088';
            runViewSpy.mockReturnValueOnce(
                makeTestRunView(async () => makeRunViewResult([], 'Database connection timeout')),
            );

            const failedLookupRes = await op.ExecuteServer(
                {
                    TaskIDs: [TASK_1],
                    TypeID: errorTypeId,
                },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );
            expect(failedLookupRes.Success).toBe(false);
            expect(failedLookupRes.ErrorMessage).toContain(`Failed to load TaskType '${errorTypeId}'`);
            expect(failedLookupRes.ErrorMessage).toContain('Database connection timeout');
            expect(task1.saved).toBe(false);

            // Fails closed when TaskType ID is not found
            const unknownTypeId = 'dddddddd-dddd-4ddd-8ddd-dddddddd0077';
            const notFoundRes = await op.ExecuteServer(
                {
                    TaskIDs: [TASK_1],
                    TypeID: unknownTypeId,
                },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );
            expect(notFoundRes.Success).toBe(false);
            expect(notFoundRes.ErrorMessage).toBe(`TaskType '${unknownTypeId}' was not found.`);
            expect(task1.saved).toBe(false);
        } finally {
            runViewSpy.mockRestore();
        }
    });

    it('supports idempotent AssigneeMode add (including MJ: Roles), AssigneeMode clear, and idempotent AddTagID', async () => {
        const task1 = makeMockTask(TASK_1);
        const existingRoleAssignment: MockAssignmentRecord = {
            ID: 'assign-role-existing',
            TaskID: TASK_1,
            AssigneeEntityID: ROLE_ENTITY_ID,
            AssigneeRecordID: MJ_ROLE_1,
            RoleID: ROLE_PRIMARY,
            deleted: false,
            saved: true,
            NewRecord: () => true,
            Save: async () => true,
            Delete: async () => {
                existingRoleAssignment.deleted = true;
                return true;
            },
        };
        const { provider, runViewSpy, createdAssignments, createdTagLinks } = makeBulkHarness([task1], {
            existingAssignments: new Map([[TASK_1, [existingRoleAssignment]]]),
            existingTagTaskIDs: new Set([TASK_1]),
        });

        try {
            const op = new TasksBulkUpdateServerOperation();
            // Adding the exact same MJ Role + already-linked Tag is a no-op (no duplicate rows)
            const addDup = await op.ExecuteServer(
                {
                    TaskIDs: [TASK_1],
                    AssigneeMode: 'add',
                    AssigneeEntityName: 'MJ: Roles',
                    AssigneeRecordID: MJ_ROLE_1,
                    AddTagID: TAG_1,
                },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );
            expect(addDup.Success).toBe(true);
            expect(createdAssignments).toHaveLength(0);
            expect(createdTagLinks).toHaveLength(0);
            expect(existingRoleAssignment.deleted).toBe(false);

            // Clear deletes all assignments without creating new ones
            const clearRes = await op.ExecuteServer(
                {
                    TaskIDs: [TASK_1],
                    AssigneeMode: 'clear',
                },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );
            expect(clearRes.Success).toBe(true);
            expect(existingRoleAssignment.deleted).toBe(true);
            expect(createdAssignments).toHaveLength(0);
        } finally {
            runViewSpy.mockRestore();
        }
    });

    it('deduplicates TaskIDs case-insensitively and reports partial failures without aborting remaining tasks', async () => {
        const task1 = makeMockTask(TASK_1);
        const missingTaskID = '99999999-9999-4999-8999-999999999900';
        const { provider, runViewSpy } = makeBulkHarness([task1]);

        try {
            const op = new TasksBulkUpdateServerOperation();
            const res = await op.ExecuteServer(
                {
                    TaskIDs: [TASK_1, TASK_1.toUpperCase(), missingTaskID],
                    Priority: 'Critical',
                },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );
            expect(res.Success).toBe(true);
            expect(res.Output?.TotalRequested).toBe(2);
            expect(res.Output?.UpdatedCount).toBe(1);
            expect(res.Output?.FailedCount).toBe(1);
            expect(res.Output?.UpdatedTaskIDs).toEqual([TASK_1]);
            expect(res.Output?.Failures).toHaveLength(1);
            expect(res.Output?.Failures[0].TaskID).toBe(missingTaskID);
            expect(task1.Priority).toBe('Critical');
        } finally {
            runViewSpy.mockRestore();
        }
    });

    it('enforces input validation guards (empty list, SQL-injection UUID, >200 cap, missing mode payloads)', async () => {
        const provider = makeTestProvider({
            EntityByName: vi.fn(() => undefined),
        });
        const op = new TasksBulkUpdateServerOperation();

        const emptyRes = await op.ExecuteServer({ TaskIDs: [] }, { provider, user: TEST_USER, emitProgress: () => {} });
        expect(emptyRes.Success).toBe(false);
        expect(emptyRes.ErrorMessage).toMatch(/at least one/i);

        const badUuidRes = await op.ExecuteServer(
            { TaskIDs: ["bad' OR 1=1 --"] },
            { provider, user: TEST_USER, emitProgress: () => {} },
        );
        expect(badUuidRes.Success).toBe(false);
        expect(badUuidRes.ErrorMessage).toMatch(/Invalid TaskID/i);

        const tooMany = Array.from({ length: 501 }, (_, i) => `11111111-1111-4111-8111-${String(i).padStart(12, '0')}`);
        const capRes = await op.ExecuteServer({ TaskIDs: tooMany }, { provider, user: TEST_USER, emitProgress: () => {} });
        expect(capRes.Success).toBe(false);
        expect(capRes.ErrorMessage).toMatch(/500/);

        const badShiftRes = await op.ExecuteServer(
            { TaskIDs: [TASK_1], DueDateMode: 'shift', ShiftDays: 1.5 },
            { provider, user: TEST_USER, emitProgress: () => {} },
        );
        expect(badShiftRes.Success).toBe(false);
        expect(badShiftRes.ErrorMessage).toMatch(/finite integer/i);

        const missingOrgRes = await op.ExecuteServer(
            { TaskIDs: [TASK_1], OrganizationMode: 'set' },
            { provider, user: TEST_USER, emitProgress: () => {} },
        );
        expect(missingOrgRes.Success).toBe(false);
        expect(missingOrgRes.ErrorMessage).toMatch(/OrganizationID is required/i);

        const unknownAssigneeEntity = await op.ExecuteServer(
            {
                TaskIDs: [TASK_1],
                AssigneeMode: 'replace',
                AssigneeEntityName: 'Nonexistent: Entity',
                AssigneeRecordID: PERSON_1,
            },
            { provider, user: TEST_USER, emitProgress: () => {} },
        );
        expect(unknownAssigneeEntity.Success).toBe(false);
        expect(unknownAssigneeEntity.ErrorMessage).toMatch(/Unknown AssigneeEntityName/i);
    });
});

describe('TasksInstantiateTemplateServerOperation', () => {
    it('creates parent before child, stamps OrganizationID, computes DueAt, and wires assignments + dependencies', async () => {
        const createdTasks: MockTaskRecord[] = [];
        const createdAssignments: MockAssignmentRecord[] = [];
        const createdDeps: MockDepRecord[] = [];
        let taskSeq = 0;

        const provider = makeTestProvider({
            EntityByName: vi.fn((name: string) =>
                name === 'MJ_BizApps_Common: People' ? { ID: PERSON_ENTITY_ID, Name: name } : undefined,
            ),
            GetEntityObject: vi.fn(async (entityName: string) => {
                if (entityName === 'MJ_BizApps_Tasks: Task Templates') {
                    return {
                        ID: TEMPLATE_1,
                        Name: 'Monthly Close',
                        TypeID: TYPE_1,
                        CategoryID: CAT_1,
                        OrganizationID: null,
                        InnerLoad: async () => true,
                    };
                }
                if (entityName === 'MJ_BizApps_Tasks: Tasks') {
                    const id = `00000000-0000-4000-8000-00000000000${++taskSeq}`;
                    const rec = makeMockTask(id, { DueAt: null, StartedAt: null });
                    rec.Save = async () => {
                        rec.saved = true;
                        createdTasks.push(rec);
                        return true;
                    };
                    return rec;
                }
                if (entityName === 'MJ_BizApps_Tasks: Task Assignments') {
                    const rec: MockAssignmentRecord = {
                        ID: `ta-${createdAssignments.length + 1}`,
                        TaskID: '',
                        AssigneeEntityID: '',
                        AssigneeRecordID: '',
                        RoleID: null,
                        deleted: false,
                        saved: false,
                        NewRecord: () => true,
                        Save: async () => {
                            rec.saved = true;
                            createdAssignments.push(rec);
                            return true;
                        },
                        Delete: async () => true,
                    };
                    return rec;
                }
                if (entityName === 'MJ_BizApps_Tasks: Task Dependencies') {
                    const rec: MockDepRecord = {
                        TaskID: '',
                        DependsOnTaskID: '',
                        DependencyType: 'FinishToStart',
                        saved: false,
                        NewRecord: () => true,
                        Save: async () => {
                            rec.saved = true;
                            createdDeps.push(rec);
                            return true;
                        },
                    };
                    return rec;
                }
                throw new Error(`Unexpected entity ${entityName}`);
            }),
        });

        const runViewFn = vi.fn(async (params: RunViewParams): Promise<RunViewResult> => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Template Items') {
                // Intentionally put child BEFORE parent to verify topological sort
                return makeRunViewResult([
                    {
                        ID: ITEM_CHILD,
                        Name: 'Reconcile AR',
                        Description: 'Sub-step',
                        ParentItemID: ITEM_PARENT,
                        Priority: 'High',
                        DaysFromStart: 5,
                        HoursEstimated: 2,
                        Sequence: 20,
                    },
                    {
                        ID: ITEM_PARENT,
                        Name: 'Close Package',
                        Description: 'Root',
                        ParentItemID: null,
                        Priority: 'Critical',
                        DaysFromStart: 1,
                        HoursEstimated: 4,
                        Sequence: 10,
                    },
                ]);
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Template Item Roles') {
                return makeRunViewResult([{ ItemID: ITEM_CHILD, RoleID: ROLE_PRIMARY }]);
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Template Item Dependencies') {
                return makeRunViewResult([
                    {
                        ItemID: ITEM_CHILD,
                        DependsOnItemID: ITEM_PARENT,
                        DependencyType: 'FinishToStart',
                    },
                ]);
            }
            return makeRunViewResult([]);
        });
        const runViewSpy = vi.spyOn(RunView, 'FromMetadataProvider').mockReturnValue(makeTestRunView(runViewFn));

        try {
            const op = new TasksInstantiateTemplateServerOperation();
            const envelope = await op.ExecuteServer(
                {
                    TemplateID: TEMPLATE_1,
                    StartDate: '2026-12-01',
                    OrganizationID: ORG_1,
                    RoleAssignments: [
                        {
                            RoleID: ROLE_PRIMARY,
                            EntityName: 'MJ_BizApps_Common: People',
                            RecordID: PERSON_1,
                        },
                    ],
                },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );

            expect(envelope.Success).toBe(true);
            const result = envelope.Output!;
            expect(result.CreatedCount).toBe(2);
            expect(result.OrganizationID).toBe(ORG_1);
            expect(createdTasks[0].Name).toBe('Close Package');
            expect(createdTasks[0].ParentID).toBeNull();
            expect(createdTasks[0].OrganizationID).toBe(ORG_1);
            expect(createdTasks[0].DueAt?.toISOString().slice(0, 10)).toBe('2026-12-02');

            expect(createdTasks[1].Name).toBe('Reconcile AR');
            expect(createdTasks[1].ParentID).toBe(createdTasks[0].ID);
            expect(createdTasks[1].OrganizationID).toBe(ORG_1);
            expect(createdTasks[1].DueAt?.toISOString().slice(0, 10)).toBe('2026-12-06');

            expect(createdAssignments).toHaveLength(1);
            expect(createdAssignments[0].TaskID).toBe(createdTasks[1].ID);
            expect(createdAssignments[0].AssigneeRecordID).toBe(PERSON_1);

            expect(createdDeps).toHaveLength(1);
            expect(createdDeps[0].TaskID).toBe(createdTasks[1].ID);
            expect(createdDeps[0].DependsOnTaskID).toBe(createdTasks[0].ID);
        } finally {
            runViewSpy.mockRestore();
        }
    });

    it('falls back to template OrganizationID & CategoryID when caller omits them and rejects invalid TemplateID', async () => {
        const createdTasks: MockTaskRecord[] = [];
        const provider = makeTestProvider({
            EntityByName: vi.fn(() => undefined),
            GetEntityObject: vi.fn(async (entityName: string) => {
                if (entityName === 'MJ_BizApps_Tasks: Task Templates') {
                    return {
                        ID: TEMPLATE_1,
                        Name: 'UK Statutory Close',
                        TypeID: TYPE_1,
                        CategoryID: CAT_1,
                        OrganizationID: ORG_2,
                        InnerLoad: async () => true,
                    };
                }
                const rec = makeMockTask('00000000-0000-4000-8000-000000000099', { DueAt: null, StartedAt: null });
                rec.Save = async () => {
                    createdTasks.push(rec);
                    return true;
                };
                return rec;
            }),
        });

        const runViewSpy = vi.spyOn(RunView, 'FromMetadataProvider').mockReturnValue(
            makeTestRunView(async (params: RunViewParams) => {
                if (params.EntityName === 'MJ_BizApps_Tasks: Task Template Items') {
                    return makeRunViewResult([
                        { ID: ITEM_PARENT, Name: 'File VAT Return', Description: null, ParentItemID: null, Priority: 'High', DaysFromStart: 0, HoursEstimated: 3, Sequence: 10 },
                    ]);
                }
                return makeRunViewResult([]);
            }),
        );

        try {
            const op = new TasksInstantiateTemplateServerOperation();
            const ok = await op.ExecuteServer(
                { TemplateID: TEMPLATE_1, StartDate: '2026-12-01' },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );
            expect(ok.Success).toBe(true);
            expect(ok.Output?.OrganizationID).toBe(ORG_2);
            expect(createdTasks[0].OrganizationID).toBe(ORG_2);
            expect(createdTasks[0].CategoryID).toBe(CAT_1);

            const bad = await op.ExecuteServer(
                { TemplateID: 'not-a-uuid', StartDate: '2026-12-01' },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );
            expect(bad.Success).toBe(false);
            expect(bad.ErrorMessage).toMatch(/Invalid TemplateID/i);
        } finally {
            runViewSpy.mockRestore();
        }
    });
});

describe('TaskEntityServer parent OrganizationID inheritance', () => {
    it('inherits parent OrganizationID on new sub-task when unset and respects explicit overrides', async () => {
        const mockRunView = vi.fn().mockResolvedValue({
            Success: true,
            Results: [{ OrganizationID: ORG_1 }],
        });
        const runViewProtoSpy = vi.spyOn(RunView.prototype, 'RunView').mockImplementation(mockRunView);

        try {
            const child = Object.create(TaskEntityServer.prototype) as TaskEntityServer & {
                inheritParentOrganizationPreSave: () => Promise<void>;
            };
            Object.defineProperty(child, 'IsSaved', { value: false, configurable: true });
            Object.defineProperty(child, 'ParentID', { value: TASK_1, configurable: true });
            let orgVal: string | null = null;
            Object.defineProperty(child, 'OrganizationID', {
                get: () => orgVal,
                set: (v: string | null) => { orgVal = v; },
                configurable: true,
            });
            Object.defineProperty(child, 'ContextCurrentUser', { value: TEST_USER, configurable: true });
            Object.defineProperty(child, 'RunViewProviderToUse', { value: undefined, configurable: true });

            // 1. Unset OrganizationID on new child -> inherits parent ORG_1
            await child.inheritParentOrganizationPreSave();
            expect(orgVal).toBe(ORG_1);
            expect(mockRunView).toHaveBeenCalledTimes(1);

            // 2. Explicit OrganizationID already set -> does NOT overwrite
            mockRunView.mockClear();
            orgVal = ORG_2;
            await child.inheritParentOrganizationPreSave();
            expect(orgVal).toBe(ORG_2);
            expect(mockRunView).not.toHaveBeenCalled();

            // 3. Already-saved task with OrganizationID intentionally cleared -> does NOT re-inherit
            Object.defineProperty(child, 'IsSaved', { value: true, configurable: true });
            orgVal = null;
            await child.inheritParentOrganizationPreSave();
            expect(orgVal).toBeNull();
            expect(mockRunView).not.toHaveBeenCalled();
            expect(typeof BaseEntity).toBe('function');
        } finally {
            runViewProtoSpy.mockRestore();
        }
    });
});

describe('TasksRunRecurringPlaybooksServerOperation', () => {
    it('supports DryRun, launches across mirrored companies, and skips already-launched PeriodKey idempotently', async () => {
        const savedTasks: MockTaskRecord[] = [];
        let idCounter = 100;

        const provider = makeTestProvider({
            EntityByName: vi.fn(() => undefined),
            GetEntityObject: vi.fn(async (entityName: string) => {
                if (entityName === 'MJ_BizApps_Tasks: Task Templates') {
                    return {
                        ID: TEMPLATE_1,
                        Name: 'Month-End Financial Close',
                        TypeID: TYPE_1,
                        CategoryID: CAT_1,
                        OrganizationID: null,
                        InnerLoad: async () => true,
                    };
                }
                const rec = makeMockTask(`00000000-0000-4000-8000-000000000${++idCounter}`, {
                    DueAt: null,
                    StartedAt: null,
                });
                rec.InnerLoad = async (key?: { KeyValuePairs?: Array<{ Value?: string }> }) => {
                    const targetId = key?.KeyValuePairs?.[0]?.Value;
                    const found = targetId ? savedTasks.find((t) => t.ID === targetId) : undefined;
                    if (found) {
                        Object.assign(rec, { ID: found.ID, Description: found.Description, OrganizationID: found.OrganizationID });
                    }
                    return true;
                };
                rec.Save = async () => {
                    const existingIdx = savedTasks.findIndex((t) => t.ID === rec.ID);
                    if (existingIdx >= 0) savedTasks[existingIdx] = rec;
                    else savedTasks.push(rec);
                    return true;
                };
                return rec;
            }),
        });

        const runViewSpy = vi.spyOn(RunView, 'FromMetadataProvider').mockReturnValue(
            makeTestRunView(async (params: RunViewParams) => {
                if (params.EntityName === 'MJ_BizApps_Common: Organizations') {
                    return makeRunViewResult([
                        { ID: ORG_1, Name: 'Acme US Operating Co' },
                        { ID: ORG_2, Name: 'Acme UK Ltd' },
                    ]);
                }
                if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                    const filter = params.ExtraFilter ?? '';
                    // Simulate ORG_2 already having a launched close for 2026-12
                    if (filter.includes(ORG_2)) {
                        return makeRunViewResult([{ ID: TASK_2 }]);
                    }
                    return makeRunViewResult([]);
                }
                if (params.EntityName === 'MJ_BizApps_Tasks: Task Template Items') {
                    return makeRunViewResult([
                        {
                            ID: ITEM_PARENT,
                            Name: 'Reconcile Bank Accounts',
                            Description: 'Match statements to GL',
                            ParentItemID: null,
                            Priority: 'High',
                            DaysFromStart: 2,
                            HoursEstimated: 4,
                            Sequence: 10,
                        },
                    ]);
                }
                return makeRunViewResult([]);
            }),
        );

        try {
            const op = new TasksRunRecurringPlaybooksServerOperation();

            // 1. DryRun inspects both mirrored companies without creating rows
            const dry = await op.ExecuteServer(
                {
                    TemplateID: TEMPLATE_1,
                    AnchorDate: '2026-12-01',
                    PeriodKey: '2026-12',
                    AllMirroredCompanies: true,
                    DryRun: true,
                },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );
            expect(dry.Success).toBe(true);
            expect(dry.Output?.TargetOrganizations).toBe(2);
            expect(dry.Output?.SkippedCount).toBe(1);
            expect(dry.Output?.LaunchedCount).toBe(0);
            expect(dry.Output?.Results.find((r) => r.OrganizationID === ORG_1)?.Status).toBe('dry-run');
            expect(dry.Output?.Results.find((r) => r.OrganizationID === ORG_2)?.Status).toBe('skipped');
            expect(savedTasks).toHaveLength(0);

            // 2. Live run launches ORG_1 with idempotency marker and skips ORG_2
            const live = await op.ExecuteServer(
                {
                    TemplateID: TEMPLATE_1,
                    AnchorDate: '2026-12-01',
                    PeriodKey: '2026-12',
                    AllMirroredCompanies: true,
                    DryRun: false,
                },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );
            expect(live.Success).toBe(true);
            expect(live.Output?.LaunchedCount).toBe(1);
            expect(live.Output?.SkippedCount).toBe(1);
            expect(live.Output?.TotalTasksCreated).toBe(1);
            expect(savedTasks[0].OrganizationID).toBe(ORG_1);
            expect(savedTasks[0].Description).toContain('[Period:2026-12]');
            expect(savedTasks[0].Description).toContain(`[Template:${TEMPLATE_1}]`);

            // 3. Rejects missing PeriodKey
            const invalid = await op.ExecuteServer(
                {
                    TemplateID: TEMPLATE_1,
                    AnchorDate: '2026-12-01',
                    PeriodKey: '   ',
                },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );
            expect(invalid.Success).toBe(false);
            expect(invalid.ErrorMessage).toMatch(/PeriodKey/i);
        } finally {
            runViewSpy.mockRestore();
        }
    });
});

function makeAgentPolicy(overrides: Partial<MJAIAgentUserPolicyEntity> = {}): MJAIAgentUserPolicyEntity {
    const base: Partial<MJAIAgentUserPolicyEntity> = {
        ID: 'pol-tasks-1',
        AgentID: 'c0500000-0000-4000-8000-000000000001',
        UserID: TEST_USER.ID,
        DisplayNameOverride: null,
        PreferredPersonaID: null,
        Status: 'Active',
        OnboardingStatus: 'Completed',
        CoordinationMode: 'Coordinator',
        DefaultDataAccessMode: 'UserCeiling',
        EmailChannelMode: 'DraftOnly',
        CalendarChannelMode: 'ReadOnly',
        PhoneChannelMode: 'InboundOnly',
        MessagingChannelMode: 'Enabled',
        AllowInterAgentCoordination: true,
        RequireApprovalForExternalComms: true,
        RequireApprovalForFinancials: true,
        RequireApprovalForDestructiveActions: true,
        AutoApproveAmountThreshold: null,
        EntityAccessRules: null,
        EntityAccessRulesObject: null,
        ActionPolicyRules: null,
        ActionPolicyRulesObject: null,
        InstructionsOverride: null,
        ...overrides,
    };
    return base as MJAIAgentUserPolicyEntity;
}

describe('Tasks Remotable Operations — Agent User Policy Enforcement', () => {
    const AGENT_COS = 'c0500000-0000-4000-8000-000000000001';
    const engine = AgentUserPolicyEngine.Instance;

    it('blocks BulkUpdateTasks, InstantiateTemplate, and RunRecurringPlaybooks (live) with [POLICY_DENIED] under ReadOnly, while allowing DryRun and direct human calls', async () => {
        const task1 = makeMockTask(TASK_1);
        const { provider, runViewSpy } = makeBulkHarness([task1]);

        try {
            engine.ClearCache();
            engine.SetCachedPolicy(
                makeAgentPolicy({
                    AgentID: AGENT_COS,
                    UserID: TEST_USER.ID,
                    DefaultDataAccessMode: 'ReadOnly',
                }),
                provider,
            );

            // 1. Direct human call outside executing agent context succeeds unchanged
            const bulkOp = new TasksBulkUpdateServerOperation();
            const humanRes = await bulkOp.ExecuteServer(
                { TaskIDs: [TASK_1], Priority: 'High' },
                { provider, user: TEST_USER, emitProgress: () => {} },
            );
            expect(humanRes.Success).toBe(true);
            expect(task1.Priority).toBe('High');

            // 2. Executing agent under ReadOnly -> [POLICY_DENIED] across all 3 write ops
            await engine.RunWithExecutingAgentContext(AGENT_COS, async () => {
                const bulkBlocked = await bulkOp.ExecuteServer(
                    { TaskIDs: [TASK_1], Priority: 'Low' },
                    { provider, user: TEST_USER, emitProgress: () => {} },
                );
                expect(bulkBlocked.Success).toBe(false);
                expect(bulkBlocked.ErrorMessage).toContain('[POLICY_DENIED]');
                expect(task1.Priority).toBe('High');

                const instOp = new TasksInstantiateTemplateServerOperation();
                const instBlocked = await instOp.ExecuteServer(
                    { TemplateID: TEMPLATE_1, StartDate: '2026-12-01' },
                    { provider, user: TEST_USER, emitProgress: () => {} },
                );
                expect(instBlocked.Success).toBe(false);
                expect(instBlocked.ErrorMessage).toContain('[POLICY_DENIED]');

                const recurOp = new TasksRunRecurringPlaybooksServerOperation();
                const recurBlocked = await recurOp.ExecuteServer(
                    { TemplateID: TEMPLATE_1, AnchorDate: '2026-12-01', PeriodKey: '2026-12', DryRun: false },
                    { provider, user: TEST_USER, emitProgress: () => {} },
                );
                expect(recurBlocked.Success).toBe(false);
                expect(recurBlocked.ErrorMessage).toContain('[POLICY_DENIED]');

                // DryRun: true uses Read operation and is permitted under ReadOnly
                const dryAllowed = await recurOp.ExecuteServer(
                    { TemplateID: TEMPLATE_1, AnchorDate: '2026-12-01', PeriodKey: '2026-12', DryRun: true },
                    { provider, user: TEST_USER, emitProgress: () => {} },
                );
                expect(dryAllowed.Success).toBe(true);
                expect(dryAllowed.Output?.DryRun).toBe(true);
            });
        } finally {
            engine.ClearCache();
            runViewSpy.mockRestore();
        }
    });

    it('blocks bulk and non-DryRun rollover mutations with [APPROVAL_REQUIRED] when RequireApprovalForDestructiveActions is enabled, and succeeds when disabled', async () => {
        const task1 = makeMockTask(TASK_1);
        const { provider, runViewSpy } = makeBulkHarness([task1]);

        try {
            engine.ClearCache();
            engine.SetCachedPolicy(
                makeAgentPolicy({
                    AgentID: AGENT_COS,
                    UserID: TEST_USER.ID,
                    DefaultDataAccessMode: 'UserCeiling',
                    RequireApprovalForDestructiveActions: true,
                }),
                provider,
            );

            const bulkOp = new TasksBulkUpdateServerOperation();
            const recurOp = new TasksRunRecurringPlaybooksServerOperation();

            await engine.RunWithExecutingAgentContext(AGENT_COS, async () => {
                const bulkApproval = await bulkOp.ExecuteServer(
                    { TaskIDs: [TASK_1], Status: 'Completed' },
                    { provider, user: TEST_USER, emitProgress: () => {} },
                );
                expect(bulkApproval.Success).toBe(false);
                expect(bulkApproval.ErrorMessage).toContain('[APPROVAL_REQUIRED]');

                const recurApproval = await recurOp.ExecuteServer(
                    { TemplateID: TEMPLATE_1, AnchorDate: '2026-12-01', PeriodKey: '2026-12', DryRun: false },
                    { provider, user: TEST_USER, emitProgress: () => {} },
                );
                expect(recurApproval.Success).toBe(false);
                expect(recurApproval.ErrorMessage).toContain('[APPROVAL_REQUIRED]');
            });

            // Once RequireApprovalForDestructiveActions is false, agent bulk update succeeds cleanly
            engine.SetCachedPolicy(
                makeAgentPolicy({
                    AgentID: AGENT_COS,
                    UserID: TEST_USER.ID,
                    DefaultDataAccessMode: 'UserCeiling',
                    RequireApprovalForDestructiveActions: false,
                }),
                provider,
            );

            await engine.RunWithExecutingAgentContext(AGENT_COS, async () => {
                const bulkOk = await bulkOp.ExecuteServer(
                    { TaskIDs: [TASK_1], Priority: 'Critical' },
                    { provider, user: TEST_USER, emitProgress: () => {} },
                );
                expect(bulkOk.Success).toBe(true);
                expect(task1.Priority).toBe('Critical');
            });
        } finally {
            engine.ClearCache();
            runViewSpy.mockRestore();
        }
    });
});
