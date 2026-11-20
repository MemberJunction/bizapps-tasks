import { describe, expect, it, vi } from 'vitest';
import { RunView, type IMetadataProvider, type RunViewParams, type RunViewResult, type UserInfo } from '@memberjunction/core';
import {
    TasksBulkUpdateServerOperation,
    TasksInstantiateTemplateServerOperation,
} from '../TasksRemoteOperationsServer.js';

const TASK_1 = '11111111-1111-1111-1111-111111111111';
const TASK_2 = '22222222-2222-2222-2222-222222222222';
const ORG_1 = '33333333-3333-3333-3333-333333333333';
const CAT_1 = '44444444-4444-4444-4444-444444444444';
const ROLE_PRIMARY = '55555555-5555-5555-5555-555555555555';
const PERSON_ENTITY_ID = '66666666-6666-6666-6666-666666666666';
const PERSON_1 = '77777777-7777-7777-7777-777777777777';
const PERSON_OLD = '88888888-8888-8888-8888-888888888888';
const TAG_1 = '99999999-9999-9999-9999-999999999999';
const TEMPLATE_1 = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const ITEM_PARENT = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
const ITEM_CHILD = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
const TYPE_1 = 'dddddddd-dddd-dddd-dddd-dddddddddddd';

const TEST_USER = { ID: 'user-1', Name: 'Tester', Email: 'tester@example.com' } as unknown as UserInfo;

interface MockTaskRecord {
    ID: string;
    Name: string;
    Description: string | null;
    Status: 'Pending' | 'InProgress' | 'Blocked' | 'Completed' | 'Cancelled';
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
    InnerLoad: (key: { KeyValuePairs: Array<{ Value: unknown }> }) => Promise<boolean>;
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
        Status: 'Pending',
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

describe('TasksBulkUpdateServerOperation', () => {
    it('updates scalar fields, shifts DueAt & StartedAt, replaces assignees, and attaches tags in one server RPC', async () => {
        const task1 = makeMockTask(TASK_1);
        const task2 = makeMockTask(TASK_2, {
            DueAt: new Date('2026-11-25T12:00:00.000Z'),
            StartedAt: null,
        });
        const tasksById = new Map<string, MockTaskRecord>([
            [TASK_1, task1],
            [TASK_2, task2],
        ]);

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
        const createdAssignments: MockAssignmentRecord[] = [];
        const createdTagLinks: MockTagLinkRecord[] = [];

        const provider = {
            EntityByName: vi.fn((name: string) =>
                name === 'MJ_BizApps_Common: People' ? { ID: PERSON_ENTITY_ID, Name: name } : undefined,
            ),
            GetEntityObject: vi.fn(async (entityName: string) => {
                if (entityName === 'MJ_BizApps_Tasks: Tasks') {
                    let loaded: MockTaskRecord | undefined;
                    const shell = {
                        InnerLoad: async (ck: { KeyValuePairs: Array<{ Value: string }> }) => {
                            loaded = tasksById.get(ck.KeyValuePairs[0].Value);
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
                        Delete: async () => true,
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
        } as unknown as IMetadataProvider;

        const runViewFn = vi.fn(async (params: RunViewParams): Promise<RunViewResult> => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Roles') {
                return {
                    Success: true,
                    Results: [{ ID: ROLE_PRIMARY, Name: 'Primary' }],
                } as unknown as RunViewResult;
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Assignments') {
                const list = params.ExtraFilter?.includes(TASK_1) ? [oldAssignment] : [];
                return { Success: true, Results: list } as unknown as RunViewResult;
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Tag Links') {
                return { Success: true, Results: [] } as unknown as RunViewResult;
            }
            return { Success: true, Results: [] } as unknown as RunViewResult;
        });
        const runViewSpy = vi.spyOn(RunView, 'FromMetadataProvider').mockReturnValue({
            RunView: runViewFn,
        } as unknown as RunView);

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
        runViewSpy.mockRestore();

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
    });

    it('rejects empty TaskIDs and invalid ShiftDays', async () => {
        const provider = {} as unknown as IMetadataProvider;
        const op = new TasksBulkUpdateServerOperation();

        const emptyRes = await op.ExecuteServer({ TaskIDs: [] }, { provider, user: TEST_USER, emitProgress: () => {} });
        expect(emptyRes.Success).toBe(false);
        expect(emptyRes.ErrorMessage).toMatch(/at least one/i);

        const badShiftRes = await op.ExecuteServer(
            { TaskIDs: [TASK_1], DueDateMode: 'shift', ShiftDays: 1.5 },
            { provider, user: TEST_USER, emitProgress: () => {} },
        );
        expect(badShiftRes.Success).toBe(false);
        expect(badShiftRes.ErrorMessage).toMatch(/finite integer/i);
    });
});

describe('TasksInstantiateTemplateServerOperation', () => {
    it('creates parent before child, stamps OrganizationID, computes DueAt, and wires assignments + dependencies', async () => {
        const createdTasks: MockTaskRecord[] = [];
        const createdAssignments: MockAssignmentRecord[] = [];
        const createdDeps: MockDepRecord[] = [];
        let taskSeq = 0;

        const provider = {
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
                    const id = `00000000-0000-0000-0000-00000000000${++taskSeq}`;
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
        } as unknown as IMetadataProvider;

        const runViewFn = vi.fn(async (params: RunViewParams): Promise<RunViewResult> => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Template Items') {
                // Intentionally put child BEFORE parent to verify topological sort
                return {
                    Success: true,
                    Results: [
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
                    ],
                } as unknown as RunViewResult;
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Template Item Roles') {
                return {
                    Success: true,
                    Results: [{ ItemID: ITEM_CHILD, RoleID: ROLE_PRIMARY }],
                } as unknown as RunViewResult;
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Template Item Dependencies') {
                return {
                    Success: true,
                    Results: [
                        {
                            ItemID: ITEM_CHILD,
                            DependsOnItemID: ITEM_PARENT,
                            DependencyType: 'FinishToStart',
                        },
                    ],
                } as unknown as RunViewResult;
            }
            return { Success: true, Results: [] } as unknown as RunViewResult;
        });
        const runViewSpy = vi.spyOn(RunView, 'FromMetadataProvider').mockReturnValue({
            RunView: runViewFn,
        } as unknown as RunView);

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
        runViewSpy.mockRestore();

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
    });
});
