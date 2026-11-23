import { describe, it, expect, beforeEach, vi } from 'vitest';
import type { ActionParam, ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import type { UserInfo } from '@memberjunction/core';

const {
    checkEntityAccessMock,
    maskRecordMock,
    maskRowsMock,
    resolvePersonForUserMock,
    resolveDirectReportPersonIDsMock,
    resolveUserIDForPersonMock,
    triggerWakeMock,
    getSystemUserMock,
    runViewMock,
    searchEntityMock,
    getEntityObjectMock,
    entitiesList,
} = vi.hoisted(() => ({
    checkEntityAccessMock: vi.fn(),
    maskRecordMock: vi.fn(<T extends object>(rec: T, patterns: readonly string[]): T => {
        if (!patterns?.length) return rec;
        const copy = { ...rec } as Record<string, string | number | boolean | Date | null | undefined | object>;
        for (const p of patterns) delete copy[p];
        return copy as T;
    }),
    maskRowsMock: vi.fn(<T extends object>(rows: readonly T[], patterns: readonly string[]): T[] => {
        if (!patterns?.length) return [...rows];
        return rows.map((r) => {
            const copy = { ...r } as Record<string, string | number | boolean | Date | null | undefined | object>;
            for (const p of patterns) delete copy[p];
            return copy as T;
        });
    }),
    resolvePersonForUserMock: vi.fn(),
    resolveDirectReportPersonIDsMock: vi.fn(),
    resolveUserIDForPersonMock: vi.fn(),
    triggerWakeMock: vi.fn(),
    getSystemUserMock: vi.fn(),
    runViewMock: vi.fn(),
    searchEntityMock: vi.fn(),
    getEntityObjectMock: vi.fn(),
    entitiesList: [
        { ID: 'e0000001-0000-4000-8000-000000000001', Name: 'MJ_BizApps_Common: People' },
        { ID: 'e0000002-0000-4000-8000-000000000002', Name: 'MJ: Roles' },
        { ID: 'e0000003-0000-4000-8000-000000000003', Name: 'MJ: AI Agents' },
        { ID: 'e0000004-0000-4000-8000-000000000004', Name: 'MJ_BizApps_Common: Organizations' },
        { ID: 'e0000005-0000-4000-8000-000000000005', Name: 'MJ_BizApps_Tasks: Tasks' },
    ],
}));

vi.mock('@memberjunction/actions-base', () => ({}));
vi.mock('@memberjunction/actions', () => ({ BaseAction: class {} }));
vi.mock('@memberjunction/global', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/global')>();
    return {
        ...actual,
        RegisterClass: () => () => {},
    };
});
vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    return {
        ...actual,
        LogError: vi.fn(),
        LogStatus: vi.fn(),
        Metadata: class {
            public static Provider = {
                Entities: entitiesList,
                GetEntityObject: getEntityObjectMock,
            };
            public Entities = entitiesList;
            public GetEntityObject = getEntityObjectMock;
            public SearchEntity = searchEntityMock;
        },
        RunView: class {
            public RunView = runViewMock;
        },
    };
});
vi.mock('@memberjunction/ai-core-plus', () => ({
    TypedActionPolicyGuard: {
        CheckEntityAccess: checkEntityAccessMock,
        MaskRecord: maskRecordMock,
        MaskRows: maskRowsMock,
    },
}));
vi.mock('@memberjunction/ai-agents', () => ({
    AgentWakeTriggerService: {
        Instance: {
            TriggerWakeForWorkstream: triggerWakeMock,
        },
    },
}));
vi.mock('@memberjunction/generic-database-provider', () => ({
    UserCache: {
        Instance: {
            GetSystemUser: getSystemUserMock,
        },
    },
}));
vi.mock('@mj-biz-apps/common-entities', () => ({
    ResolveUserIDForPerson: resolveUserIDForPersonMock,
}));
vi.mock('@mj-biz-apps/tasks-core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@mj-biz-apps/tasks-core')>();
    return {
        ...actual,
        WorkReportService: {
            Instance: {
                ResolvePersonForUser: resolvePersonForUserMock,
                ResolveDirectReportPersonIDs: resolveDirectReportPersonIDsMock,
            },
        },
    };
});

import {
    AddTaskUpdateAction,
    AssignTaskAction,
    CompleteTaskAction,
    CreateTaskAction,
    FindSimilarTasksAction,
    FindTasksAction,
    GetMyTasksBriefingAction,
    GetTaskAction,
    UpdateTaskAction,
} from '../custom/TaskTypedActions.js';

interface Invokable {
    InternalRunAction(params: RunActionParams): Promise<ActionResultSimple>;
}

interface MockEntity {
    ID: string;
    Name?: string;
    Description?: string | null;
    Status?: string;
    Priority?: string;
    Visibility?: string;
    PercentComplete?: number;
    DueAt?: Date | null;
    CompletedAt?: Date | null;
    CompletionNotes?: string | null;
    TypeID?: string;
    Type?: string;
    OrganizationID?: string | null;
    Organization?: string | null;
    TaskID?: string;
    PersonID?: string;
    Content?: string;
    HealthStatus?: string | null;
    ConfidenceScore?: number | null;
    Summary?: string;
    Blockers?: string | null;
    AssigneeEntityID?: string;
    AssigneeRecordID?: string;
    RoleID?: string | null;
    AssignedByPersonID?: string | null;
    ActivityType?: string;
    NewValue?: string;
    EntityID?: string;
    RecordID?: string;
    LatestResult?: { CompleteMessage?: string };
    NewRecord: ReturnType<typeof vi.fn>;
    Load: ReturnType<typeof vi.fn>;
    Save: ReturnType<typeof vi.fn>;
    Delete: ReturnType<typeof vi.fn>;
}

const USER_ALICE = 'aaaa1111-1111-4111-8111-111111111111';
const USER_BOB = 'bbbb2222-2222-4222-8222-222222222222';
const SYSTEM_USER_ID = '99999999-9999-4999-8999-999999999999';
const PERSON_ALICE = '11111111-1111-4111-8111-111111111111';
const PERSON_BOB = '22222222-2222-4222-8222-222222222222';
const TASK_1 = '33333333-3333-4333-8333-333333333331';
const TASK_2 = '33333333-3333-4333-8333-333333333332';
const TYPE_GENERAL = '44444444-4444-4444-8444-444444444401';
const TYPE_PRIORITY = '44444444-4444-4444-8444-444444444402';
const TYPE_APPROVAL = '44444444-4444-4444-8444-444444444403';
const AGENT_1 = '55555555-5555-4555-8555-555555555501';
const ROLE_1 = '66666666-6666-4666-8666-666666666601';
const TASK_ROLE_PRIMARY = '77777777-7777-4777-8777-777777777701';
const ORG_1 = '88888888-8888-4888-8888-888888888801';

function makeEntity(overrides: Partial<MockEntity> = {}): MockEntity {
    return {
        ID: overrides.ID ?? TASK_1,
        NewRecord: vi.fn(),
        Load: vi.fn().mockResolvedValue(true),
        Save: vi.fn().mockResolvedValue(true),
        Delete: vi.fn().mockResolvedValue(true),
        ...overrides,
    };
}

function makeParams(inputs: Record<string, string | number | boolean | null | undefined>): ActionParam[] {
    return Object.entries(inputs).map(([Name, Value]) => ({
        Name,
        Value,
        Type: 'Input' as const,
    }));
}

function makeRunParams(userId: string, params: ActionParam[]): RunActionParams {
    return {
        ContextUser: {
            ID: userId,
            Name: 'Alice Ng',
            Email: 'alice@example.com',
        } as Partial<UserInfo> as UserInfo,
        Params: params,
        Context: { AgentID: 'c0500000-0000-4000-8000-000000000001' },
    } as Partial<RunActionParams> as RunActionParams;
}

function run(action: object, params: RunActionParams): Promise<ActionResultSimple> {
    return (action as Invokable).InternalRunAction(params);
}

beforeEach(() => {
    vi.clearAllMocks();
    checkEntityAccessMock.mockResolvedValue({
        Allowed: true,
        Active: true,
        DeniedFieldPatterns: [],
    });
    resolvePersonForUserMock.mockResolvedValue({
        ID: PERSON_ALICE,
        FirstName: 'Alice',
        LastName: 'Ng',
        Email: 'alice@example.com',
        LinkedUserID: USER_ALICE,
    });
    resolveDirectReportPersonIDsMock.mockResolvedValue([]);
    getSystemUserMock.mockReturnValue({ ID: SYSTEM_USER_ID, Name: 'System', Email: 'system@mj.local' });
    triggerWakeMock.mockResolvedValue({ triggered: true, resultCode: 'WAKE_SCHEDULED' });
    searchEntityMock.mockResolvedValue([]);
});

describe('All 9 Typed Task Actions declare AuthorizesCaller = true', () => {
    it('sets static AuthorizesCaller = true on every typed task action', () => {
        expect(FindTasksAction.AuthorizesCaller).toBe(true);
        expect(GetTaskAction.AuthorizesCaller).toBe(true);
        expect(CreateTaskAction.AuthorizesCaller).toBe(true);
        expect(UpdateTaskAction.AuthorizesCaller).toBe(true);
        expect(CompleteTaskAction.AuthorizesCaller).toBe(true);
        expect(AssignTaskAction.AuthorizesCaller).toBe(true);
        expect(AddTaskUpdateAction.AuthorizesCaller).toBe(true);
        expect(FindSimilarTasksAction.AuthorizesCaller).toBe(true);
        expect(GetMyTasksBriefingAction.AuthorizesCaller).toBe(true);
    });
});

describe('FindTasksAction', () => {
    it('excludes planning types by default, applies SearchEntity ranking, and masks denied fields', async () => {
        checkEntityAccessMock.mockResolvedValueOnce({
            Allowed: true,
            Active: true,
            DeniedFieldPatterns: ['BlockedReason'],
        });
        searchEntityMock.mockResolvedValueOnce([{ recordId: TASK_1, score: 0.91 }]);

        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ TaskID: TASK_1 }] }) // assignments
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    { ID: TYPE_GENERAL, Name: 'General', Code: 'GENERAL' },
                    { ID: TYPE_PRIORITY, Name: 'Priority Objective', Code: 'PRIORITY_OBJECTIVE' },
                ],
            }) // task types
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    {
                        ID: TASK_1,
                        Name: 'Send Q4 board deck',
                        Status: 'Open',
                        Priority: 'High',
                        TypeID: TYPE_GENERAL,
                        Type: 'General',
                        BlockedReason: 'Confidential blocker',
                        PercentComplete: 20,
                    },
                    {
                        ID: TASK_2,
                        Name: 'Q4 Strategic Objective',
                        Status: 'InProgress',
                        Priority: 'High',
                        TypeID: TYPE_PRIORITY,
                        Type: 'Priority Objective',
                        PercentComplete: 50,
                    },
                ],
            });

        const params = makeParams({ SearchText: 'board deck' });
        const res = await run(new FindTasksAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        const tasks = JSON.parse(String(params.find((p) => p.Name === 'Tasks')?.Value));
        expect(tasks).toHaveLength(1);
        expect(tasks[0].ID).toBe(TASK_1);
        expect(tasks[0].BlockedReason).toBeUndefined();
        // Verify SQL excluded planning type ID
        expect(runViewMock.mock.calls[2][0].ExtraFilter).toContain(`TypeID NOT IN ('${TYPE_PRIORITY}')`);
    });

    it('returns POLICY_DENIED when TypedActionPolicyGuard blocks read', async () => {
        checkEntityAccessMock.mockResolvedValueOnce({
            Allowed: false,
            Active: true,
            DeniedFieldPatterns: [],
            ResultCode: 'POLICY_DENIED',
            Message: 'AllowListOnly blocks Tasks.',
        });

        const res = await run(new FindTasksAction(), makeRunParams(USER_ALICE, makeParams({})));
        expect(res).toMatchObject({ Success: false, ResultCode: 'POLICY_DENIED' });
        expect(runViewMock).not.toHaveBeenCalled();
    });

    it('filters by canonical OrganizationID and resolves OrganizationName case-insensitively', async () => {
        // 1. By OrganizationName (prefix/exact lookup against MJ_BizApps_Common: Organizations)
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ TaskID: TASK_1 }] }) // assignments
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TYPE_GENERAL, Name: 'General', Code: 'GENERAL' }] }) // task types
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: ORG_1, Name: 'Acme Enterprise Corp' }] }) // org lookup
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    {
                        ID: TASK_1,
                        Name: 'Acme Q4 Renewal',
                        Status: 'Open',
                        Priority: 'High',
                        TypeID: TYPE_GENERAL,
                        Type: 'General',
                        OrganizationID: ORG_1,
                        Organization: 'Acme Enterprise Corp',
                        PercentComplete: 10,
                    },
                ],
            });

        const params = makeParams({ OrganizationName: 'acme enterprise' });
        const res = await run(new FindTasksAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(runViewMock.mock.calls[2][0].EntityName).toBe('MJ_BizApps_Common: Organizations');
        expect(runViewMock.mock.calls[3][0].ExtraFilter).toContain(`OrganizationID = '${ORG_1}'`);
        const tasks = JSON.parse(String(params.find((p) => p.Name === 'Tasks')?.Value));
        expect(tasks).toHaveLength(1);
        expect(tasks[0].OrganizationID).toBe(ORG_1);
        expect(tasks[0].Organization).toBe('Acme Enterprise Corp');

        // 2. Ambiguous OrganizationName returns AMBIGUOUS with Candidates
        runViewMock.mockReset();
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ TaskID: TASK_1 }] })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TYPE_GENERAL, Name: 'General', Code: 'GENERAL' }] })
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    { ID: ORG_1, Name: 'Acme Enterprise Corp' },
                    { ID: '88888888-8888-4888-8888-888888888802', Name: 'Acme Labs Inc' },
                ],
            });

        const ambigParams = makeParams({ OrganizationName: 'Acme' });
        const ambigRes = await run(new FindTasksAction(), makeRunParams(USER_ALICE, ambigParams));
        expect(ambigRes).toMatchObject({ Success: false, ResultCode: 'AMBIGUOUS' });
        const candidates = JSON.parse(String(ambigParams.find((p) => p.Name === 'Candidates')?.Value));
        expect(candidates).toHaveLength(2);
    });

    it('honors Task.Visibility in Scope = Team so User B never sees User A Private tasks while User A does', async () => {
        // Bob queries Scope = 'Team': backend returns Alice's Private task, Alice's Standard task, and Bob's own Private task
        resolvePersonForUserMock.mockResolvedValueOnce({
            ID: PERSON_BOB,
            FirstName: 'Bob',
            LastName: 'Rivera',
            Email: 'bob@example.com',
            LinkedUserID: USER_BOB,
        });
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [] }) // Bob's assignments
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TYPE_GENERAL, Name: 'General', Code: 'GENERAL' }] }) // task types
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    {
                        ID: TASK_1,
                        Name: 'Alice Confidential Compensation Review',
                        Status: 'Open',
                        Priority: 'High',
                        Visibility: 'Private',
                        TypeID: TYPE_GENERAL,
                        Type: 'General',
                        CreatedByPersonID: PERSON_ALICE,
                        PercentComplete: 0,
                    },
                    {
                        ID: TASK_2,
                        Name: 'Shared Q4 Roadmap',
                        Status: 'Open',
                        Priority: 'Medium',
                        Visibility: 'Team',
                        TypeID: TYPE_GENERAL,
                        Type: 'General',
                        CreatedByPersonID: PERSON_ALICE,
                        PercentComplete: 10,
                    },
                    {
                        ID: '33333333-3333-4333-8333-333333333333',
                        Name: 'Bob Personal 1:1 Notes',
                        Status: 'Open',
                        Priority: 'Low',
                        Visibility: 'Private',
                        TypeID: TYPE_GENERAL,
                        Type: 'General',
                        CreatedByPersonID: PERSON_BOB,
                        PercentComplete: 0,
                    },
                ],
            });

        const bobParams = makeParams({ Scope: 'Team' });
        const bobRes = await run(new FindTasksAction(), makeRunParams(USER_BOB, bobParams));

        expect(bobRes).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(runViewMock.mock.calls[2][0].ExtraFilter).toContain(`Visibility IN ('Team', 'Organization')`);
        const bobTasks = JSON.parse(String(bobParams.find((p) => p.Name === 'Tasks')?.Value));
        expect(bobTasks.map((t: { ID: string }) => t.ID)).toEqual([
            TASK_2,
            '33333333-3333-4333-8333-333333333333',
        ]);
        expect(bobTasks.some((t: { ID: string }) => t.ID === TASK_1)).toBe(false);

        // Alice queries Scope = 'Team' and DOES see her own Private task
        runViewMock.mockReset();
        resolvePersonForUserMock.mockResolvedValueOnce({
            ID: PERSON_ALICE,
            FirstName: 'Alice',
            LastName: 'Ng',
            Email: 'alice@example.com',
            LinkedUserID: USER_ALICE,
        });
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [] })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TYPE_GENERAL, Name: 'General', Code: 'GENERAL' }] })
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    {
                        ID: TASK_1,
                        Name: 'Alice Confidential Compensation Review',
                        Status: 'Open',
                        Priority: 'High',
                        Visibility: 'Private',
                        TypeID: TYPE_GENERAL,
                        Type: 'General',
                        CreatedByPersonID: PERSON_ALICE,
                        PercentComplete: 0,
                    },
                ],
            });

        const aliceParams = makeParams({ Scope: 'Team' });
        const aliceRes = await run(new FindTasksAction(), makeRunParams(USER_ALICE, aliceParams));
        expect(aliceRes).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        const aliceTasks = JSON.parse(String(aliceParams.find((p) => p.Name === 'Tasks')?.Value));
        expect(aliceTasks).toHaveLength(1);
        expect(aliceTasks[0]).toMatchObject({ ID: TASK_1, Visibility: 'Private' });
    });
});

describe('GetTaskAction', () => {
    it('loads task + assignments + dependencies + comments + check-ins + links + sub-tasks with field masking', async () => {
        checkEntityAccessMock.mockResolvedValueOnce({
            Allowed: true,
            Active: true,
            DeniedFieldPatterns: ['Description'],
        });
        runViewMock
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    {
                        ID: TASK_1,
                        Name: 'Launch v6.3',
                        Description: 'Sensitive internal notes',
                        Status: 'InProgress',
                        Priority: 'High',
                        PercentComplete: 60,
                        Type: 'General',
                    },
                ],
            })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: 'a1', AssigneeEntity: 'MJ_BizApps_Common: People', AssigneeRecordID: PERSON_ALICE, Status: 'InProgress' }] })
            .mockResolvedValueOnce({ Success: true, Results: [] })
            .mockResolvedValueOnce({ Success: true, Results: [] })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: 'c1', Person: 'Alice Ng', Content: 'On track' }] })
            .mockResolvedValueOnce({ Success: true, Results: [] })
            .mockResolvedValueOnce({ Success: true, Results: [] })
            .mockResolvedValueOnce({ Success: true, Results: [] });

        const params = makeParams({ TaskID: TASK_1 });
        const res = await run(new GetTaskAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        const task = JSON.parse(String(params.find((p) => p.Name === 'Task')?.Value));
        expect(task.Name).toBe('Launch v6.3');
        expect(task.Description).toBeUndefined();
        expect(task.Assignments).toHaveLength(1);
        expect(task.RecentComments).toHaveLength(1);
    });
});

describe('CreateTaskAction', () => {
    it('returns AMBIGUOUS with candidate list when multiple People match AssigneeName', async () => {
        runViewMock.mockResolvedValueOnce({
            Success: true,
            Results: [
                { ID: PERSON_ALICE, FirstName: 'Alex', LastName: 'Kim', Email: 'alex.kim@example.com' },
                { ID: PERSON_BOB, FirstName: 'Alex', LastName: 'Patel', Email: 'alex.patel@example.com' },
            ],
        });

        const params = makeParams({ Name: 'Review contract', AssigneeName: 'Alex' });
        const res = await run(new CreateTaskAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: false, ResultCode: 'AMBIGUOUS' });
        const candidates = JSON.parse(String(params.find((p) => p.Name === 'Candidates')?.Value));
        expect(candidates).toHaveLength(2);
        expect(getEntityObjectMock).not.toHaveBeenCalled();
    });

    it('reuses existing task idempotently when ClientRequestKey matches prior TaskActivity', async () => {
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ TaskID: TASK_1 }] }) // TaskActivity lookup
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: TASK_1, Name: 'Send deck', Status: 'Open', Priority: 'High', Type: 'General', PercentComplete: 0 }],
            });

        const params = makeParams({ Name: 'Send deck', ClientRequestKey: 'wake-2026-11-20-1' });
        const res = await run(new CreateTaskAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(params.find((p) => p.Name === 'TaskID')?.Value).toBe(TASK_1);
        expect(params.find((p) => p.Name === 'IdempotentHit')?.Value).toBe(true);
        expect(getEntityObjectMock).not.toHaveBeenCalled();
    });

    it('creates a task with default Standard visibility, records ClientRequestKey, and saves assignment without duplicate per-task wakes', async () => {
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [] }) // no prior ClientRequestKey
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: PERSON_BOB, FirstName: 'Bob', LastName: 'Rivera', Email: 'bob@example.com', LinkedUserID: USER_BOB }],
            }) // assignee lookup
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TYPE_GENERAL, Name: 'General', Code: 'GENERAL' }] }); // task types

        const taskEntity = makeEntity({ ID: TASK_1, Status: 'Open', Priority: 'High' });
        const actEntity = makeEntity({ ID: 'act-1' });
        const assignEntity = makeEntity({ ID: 'assign-1' });
        getEntityObjectMock
            .mockResolvedValueOnce(taskEntity)
            .mockResolvedValueOnce(actEntity)
            .mockResolvedValueOnce(assignEntity);

        const params = makeParams({
            Name: 'Prepare Q4 pricing sheet',
            Priority: 'High',
            AssigneeEmail: 'bob@example.com',
            ClientRequestKey: 'req-42',
        });
        const res = await run(new CreateTaskAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(taskEntity.Save).toHaveBeenCalledTimes(1);
        expect(taskEntity.Visibility).toBe('Team');
        expect(actEntity.NewValue).toBe('client_request_key:req-42');
        expect(assignEntity.Save).toHaveBeenCalledTimes(1);
        // Coalesced 'tasks-inbox' wake is owned by TaskAssignmentEntityServer post-commit, not duplicated here
        expect(triggerWakeMock).not.toHaveBeenCalled();
    });

    it('supports explicit Visibility = Private on CreateTaskAction and rejects invalid Visibility values', async () => {
        const badRes = await run(
            new CreateTaskAction(),
            makeRunParams(USER_ALICE, makeParams({ Name: 'Bad visibility', Visibility: 'Secret' })),
        );
        expect(badRes).toMatchObject({ Success: false, ResultCode: 'VALIDATION_ERROR' });

        runViewMock.mockResolvedValueOnce({
            Success: true,
            Results: [{ ID: TYPE_GENERAL, Name: 'General', Code: 'GENERAL' }],
        });
        const taskEntity = makeEntity({ ID: TASK_1, Status: 'Open', Priority: 'Medium' });
        getEntityObjectMock.mockResolvedValueOnce(taskEntity);

        const params = makeParams({ Name: 'Private HR review', Visibility: 'Private' });
        const res = await run(new CreateTaskAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(taskEntity.Visibility).toBe('Private');
        expect(checkEntityAccessMock).toHaveBeenCalledWith(
            expect.objectContaining({
                writeFields: expect.arrayContaining(['Visibility']),
            }),
        );
        const createdTask = JSON.parse(String(params.find((p) => p.Name === 'Task')?.Value));
        expect(createdTask.Visibility).toBe('Private');
    });

    it('resolves OrganizationName, stamps task.OrganizationID, and returns OrganizationID output param', async () => {
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: ORG_1, Name: 'Apex Cloud Systems' }] }) // org lookup
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TYPE_GENERAL, Name: 'General', Code: 'GENERAL' }] }); // task types

        const taskEntity = makeEntity({ ID: TASK_1, Status: 'Open', Priority: 'Medium' });
        getEntityObjectMock.mockResolvedValueOnce(taskEntity);

        const params = makeParams({
            Name: 'Finalize Apex monthly close checklist',
            OrganizationName: 'Apex Cloud',
        });
        const res = await run(new CreateTaskAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(checkEntityAccessMock).toHaveBeenCalledWith(
            expect.objectContaining({
                entityName: 'MJ_BizApps_Tasks: Tasks',
                operation: 'Create',
                writeFields: expect.arrayContaining(['OrganizationID']),
            }),
        );
        expect(taskEntity.OrganizationID).toBe(ORG_1);
        expect(params.find((p) => p.Name === 'OrganizationID')?.Value).toBe(ORG_1);
        const createdTask = JSON.parse(String(params.find((p) => p.Name === 'Task')?.Value));
        expect(createdTask.OrganizationID).toBe(ORG_1);
        expect(createdTask.Organization).toBe('Apex Cloud Systems');
    });

    it('rejects creating new tasks with inactive or legacy OKR task types (PRIORITY_OBJECTIVE / KEY_RESULT) and skips them for defaults', async () => {
        const TYPE_OKR_OBJ = '8D42A1B9-3E71-4C5A-9F20-1B6E8D3A9C01';
        const TYPE_OKR_KR = '8D42A1B9-3E71-4C5A-9F20-1B6E8D3A9C02';
        const TYPE_RETIRED = '44444444-4444-4444-8444-444444444499';
        const mixedTypes = [
            { ID: TYPE_OKR_OBJ, Name: 'Priority Objective', Code: 'PRIORITY_OBJECTIVE', IsActive: false },
            { ID: TYPE_OKR_KR, Name: 'Key Result', Code: 'KEY_RESULT', IsActive: false },
            { ID: TYPE_RETIRED, Name: 'Retired Custom', Code: 'RETIRED', IsActive: false },
            { ID: TYPE_GENERAL, Name: 'General', Code: 'GENERAL', IsActive: true },
        ];

        for (const requestedType of ['PRIORITY_OBJECTIVE', 'Key Result', TYPE_OKR_KR, 'RETIRED']) {
            runViewMock.mockResolvedValueOnce({ Success: true, Results: mixedTypes });
            const res = await run(
                new CreateTaskAction(),
                makeRunParams(USER_ALICE, makeParams({ Name: 'Blocked OKR task', TaskTypeName: requestedType })),
            );
            expect(res).toMatchObject({ Success: false, ResultCode: 'VALIDATION_ERROR' });
        }
        expect(getEntityObjectMock).not.toHaveBeenCalled();

        // When TaskTypeName is omitted, default resolution skips inactive/legacy OKR rows and selects GENERAL
        runViewMock.mockResolvedValueOnce({ Success: true, Results: mixedTypes });
        const taskEntity = makeEntity({ ID: TASK_1, Status: 'Open', Priority: 'Medium' });
        getEntityObjectMock.mockResolvedValueOnce(taskEntity);
        const okRes = await run(
            new CreateTaskAction(),
            makeRunParams(USER_ALICE, makeParams({ Name: 'Operational task' })),
        );
        expect(okRes).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(taskEntity.TypeID).toBe(TYPE_GENERAL);
    });

    it('preserves read access for historical PRIORITY_OBJECTIVE and KEY_RESULT tasks via FindTasksAction and GetTaskAction', async () => {
        const TYPE_OKR_KR = '8D42A1B9-3E71-4C5A-9F20-1B6E8D3A9C02';
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ TaskID: TASK_2 }] }) // assignments
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    { ID: TYPE_GENERAL, Name: 'General', Code: 'GENERAL', IsActive: true },
                    { ID: TYPE_OKR_KR, Name: 'Key Result', Code: 'KEY_RESULT', IsActive: false },
                ],
            }) // task types
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    {
                        ID: TASK_2,
                        Name: 'Historical Q3 Key Result',
                        Status: 'InProgress',
                        Priority: 'High',
                        TypeID: TYPE_OKR_KR,
                        Type: 'Key Result',
                        PercentComplete: 75,
                    },
                ],
            });

        const findParams = makeParams({ TaskType: 'KEY_RESULT', ExcludePlanningTypes: false });
        const findRes = await run(new FindTasksAction(), makeRunParams(USER_ALICE, findParams));
        expect(findRes).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        const tasks = JSON.parse(String(findParams.find((p) => p.Name === 'Tasks')?.Value));
        expect(tasks).toHaveLength(1);
        expect(tasks[0]).toMatchObject({ ID: TASK_2, Name: 'Historical Q3 Key Result', Type: 'Key Result' });

        // GetTaskAction reads a historical Key Result task by ID without error
        runViewMock.mockReset();
        runViewMock
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    {
                        ID: TASK_2,
                        Name: 'Historical Q3 Key Result',
                        Status: 'InProgress',
                        Priority: 'High',
                        PercentComplete: 75,
                        Type: 'Key Result',
                    },
                ],
            })
            .mockResolvedValueOnce({ Success: true, Results: [] })
            .mockResolvedValueOnce({ Success: true, Results: [] })
            .mockResolvedValueOnce({ Success: true, Results: [] })
            .mockResolvedValueOnce({ Success: true, Results: [] })
            .mockResolvedValueOnce({ Success: true, Results: [] })
            .mockResolvedValueOnce({ Success: true, Results: [] })
            .mockResolvedValueOnce({ Success: true, Results: [] });

        const getParams = makeParams({ TaskID: TASK_2 });
        const getRes = await run(new GetTaskAction(), makeRunParams(USER_ALICE, getParams));
        expect(getRes).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        const detail = JSON.parse(String(getParams.find((p) => p.Name === 'Task')?.Value));
        expect(detail.Type).toBe('Key Result');
    });
});

describe('UpdateTaskAction', () => {
    it('passes explicit writeFields to TypedActionPolicyGuard and updates task + organization link', async () => {
        const taskEntity = makeEntity({
            ID: TASK_1,
            Name: 'Old Name',
            Status: 'Open',
            Priority: 'Medium',
            PercentComplete: 0,
            Type: 'General',
        });
        const linkEntity = makeEntity({ ID: 'link-1' });
        getEntityObjectMock
            .mockResolvedValueOnce(taskEntity)
            .mockResolvedValueOnce(linkEntity);
        runViewMock.mockResolvedValueOnce({ Success: true, Results: [] }); // existing org link check

        const params = makeParams({
            TaskID: TASK_1,
            Status: 'InProgress',
            PercentComplete: 50,
            OrganizationID: ORG_1,
        });
        const res = await run(new UpdateTaskAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(checkEntityAccessMock).toHaveBeenCalledWith(
            expect.objectContaining({
                entityName: 'MJ_BizApps_Tasks: Tasks',
                operation: 'Update',
                writeFields: ['Status', 'PercentComplete', 'OrganizationID'],
            }),
        );
        expect(taskEntity.Status).toBe('InProgress');
        expect(taskEntity.PercentComplete).toBe(50);
        expect(linkEntity.RecordID).toBe(ORG_1);
    });

    it('updates Visibility cleanly and validates Visibility input', async () => {
        const badRes = await run(
            new UpdateTaskAction(),
            makeRunParams(USER_ALICE, makeParams({ TaskID: TASK_1, Visibility: 'Hidden' })),
        );
        expect(badRes).toMatchObject({ Success: false, ResultCode: 'VALIDATION_ERROR' });

        const taskEntity = makeEntity({
            ID: TASK_1,
            Name: 'Sensitive Review',
            Status: 'Open',
            Priority: 'High',
            Visibility: 'Team',
            PercentComplete: 0,
            Type: 'General',
        });
        getEntityObjectMock.mockResolvedValueOnce(taskEntity);

        const params = makeParams({ TaskID: TASK_1, Visibility: 'Private' });
        const res = await run(new UpdateTaskAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(taskEntity.Visibility).toBe('Private');
        expect(checkEntityAccessMock).toHaveBeenCalledWith(
            expect.objectContaining({
                writeFields: ['Visibility'],
            }),
        );
        const updated = JSON.parse(String(params.find((p) => p.Name === 'Task')?.Value));
        expect(updated.Visibility).toBe('Private');
    });
});

describe('CompleteTaskAction', () => {
    it('returns ALREADY_COMPLETED idempotently when task is already Completed', async () => {
        const taskEntity = makeEntity({ ID: TASK_1, Name: 'Done task', Status: 'Completed' });
        getEntityObjectMock.mockResolvedValueOnce(taskEntity);

        const params = makeParams({ TaskID: TASK_1 });
        const res = await run(new CompleteTaskAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'ALREADY_COMPLETED' });
        expect(params.find((p) => p.Name === 'AlreadyCompleted')?.Value).toBe(true);
        expect(taskEntity.Save).not.toHaveBeenCalled();
    });

    it('completes task and reports newly unblocked downstream task IDs without duplicate per-task wakes', async () => {
        const taskEntity = makeEntity({ ID: TASK_1, Name: 'Approve spec', Status: 'InProgress' });
        getEntityObjectMock.mockResolvedValueOnce(taskEntity);

        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ TaskID: TASK_2, Task: 'Build implementation' }] }) // downstream deps
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TASK_2, Name: 'Build implementation', Status: 'Blocked' }] }) // open downstream tasks
            .mockResolvedValueOnce({ Success: true, Results: [{ TaskID: TASK_2, DependsOnTaskID: TASK_1 }] }); // all prereqs of TASK_2

        const params = makeParams({ TaskID: TASK_1 });
        const res = await run(new CompleteTaskAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(taskEntity.Status).toBe('Completed');
        expect(taskEntity.PercentComplete).toBe(100);
        expect(JSON.parse(String(params.find((p) => p.Name === 'UnblockedTaskIDs')?.Value))).toEqual([TASK_2]);
        // Coalesced 'tasks-inbox' wake is owned by TaskEntityServer post-commit, not duplicated here
        expect(triggerWakeMock).not.toHaveBeenCalled();
    });
});

describe('AssignTaskAction', () => {
    it('supports assigning to an AI Agent with Role mapping and ReplaceExisting', async () => {
        const oldAssignment = makeEntity({
            ID: 'old-a1',
            AssigneeEntityID: entitiesList[0].ID,
            AssigneeRecordID: PERSON_BOB,
        });
        const newAssignment = makeEntity({ ID: 'new-a1' });
        getEntityObjectMock.mockResolvedValueOnce(newAssignment);

        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TASK_1, Name: 'Draft blog post' }] }) // task
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: AGENT_1, Name: 'Content Writer Agent' }] }) // agent lookup
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TASK_ROLE_PRIMARY, Name: 'Primary' }] }) // role lookup (Owner -> Primary)
            .mockResolvedValueOnce({ Success: true, Results: [oldAssignment] }); // existing assignments

        const params = makeParams({
            TaskID: TASK_1,
            AgentName: 'Content Writer Agent',
            Role: 'Owner',
            ReplaceExisting: true,
        });
        const res = await run(new AssignTaskAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(oldAssignment.Delete).toHaveBeenCalledTimes(1);
        expect(newAssignment.AssigneeEntityID).toBe(entitiesList[2].ID); // MJ: AI Agents
        expect(newAssignment.AssigneeRecordID).toBe(AGENT_1);
        expect(newAssignment.RoleID).toBe(TASK_ROLE_PRIMARY);
    });

    it('supports assigning to an MJ Role', async () => {
        const newAssignment = makeEntity({ ID: 'role-a1' });
        getEntityObjectMock.mockResolvedValueOnce(newAssignment);
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TASK_1, Name: 'Audit access' }] })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: ROLE_1, Name: 'Security Team' }] })
            .mockResolvedValueOnce({ Success: true, Results: [] });

        const params = makeParams({ TaskID: TASK_1, AssigneeRoleName: 'Security Team' });
        const res = await run(new AssignTaskAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(newAssignment.AssigneeEntityID).toBe(entitiesList[1].ID); // MJ: Roles
        expect(newAssignment.AssigneeRecordID).toBe(ROLE_1);
    });
});

describe('AddTaskUpdateAction, FindSimilarTasksAction & GetMyTasksBriefingAction', () => {
    it('posts a TaskComment on AddTaskUpdateAction by default', async () => {
        const comment = makeEntity({ ID: 'cmt-1' });
        getEntityObjectMock.mockResolvedValueOnce(comment);
        runViewMock.mockResolvedValueOnce({ Success: true, Results: [{ ID: TASK_1, Name: 'Finalize contract' }] });

        const params = makeParams({ TaskID: TASK_1, Content: 'Legal approved redlines.' });
        const res = await run(new AddTaskUpdateAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(comment.PersonID).toBe(PERSON_ALICE);
        expect(comment.Content).toBe('Legal approved redlines.');
        expect(params.find((p) => p.Name === 'UpdateKind')?.Value).toBe('Comment');
    });

    it('flags HasLikelyDuplicate on FindSimilarTasksAction when a matching task exists', async () => {
        runViewMock.mockResolvedValueOnce({
            Success: true,
            Results: [
                { ID: TASK_1, Name: 'Send Q4 board deck to Amith', Description: 'Board slides', Status: 'Open', Priority: 'High' },
                { ID: TASK_2, Name: 'Renew domain registration', Description: 'DNS renewal', Status: 'Open', Priority: 'Low' },
            ],
        });

        const params = makeParams({ Text: 'Send Q4 board deck to Amith' });
        const res = await run(new FindSimilarTasksAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(params.find((p) => p.Name === 'HasLikelyDuplicate')?.Value).toBe(true);
        const matches = JSON.parse(String(params.find((p) => p.Name === 'Matches')?.Value));
        expect(matches[0].TaskID).toBe(TASK_1);
    });

    it('returns structured deterministic briefing buckets in GetMyTasksBriefingAction', async () => {
        const yesterday = new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString();
        const inTwoDays = new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString();

        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ TaskID: TASK_1 }] }) // assigned tasks
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    { ID: TYPE_GENERAL, Name: 'General', Code: 'GENERAL', IsApproval: false },
                    { ID: TYPE_APPROVAL, Name: 'Approval Request', Code: 'APPROVAL_REQUEST', IsApproval: true },
                ],
            }) // task types
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    {
                        ID: TASK_1,
                        Name: 'Approve Q4 budget',
                        Status: 'Blocked',
                        Priority: 'Critical',
                        DueAt: yesterday,
                        TypeID: TYPE_APPROVAL,
                        Type: 'Approval Request',
                        PercentComplete: 0,
                        CreatedByPersonID: PERSON_BOB,
                    },
                    {
                        ID: TASK_2,
                        Name: 'Delegated vendor check',
                        Status: 'Open',
                        Priority: 'Medium',
                        DueAt: inTwoDays,
                        TypeID: TYPE_GENERAL,
                        Type: 'General',
                        PercentComplete: 0,
                        CreatedByPersonID: PERSON_ALICE,
                    },
                ],
            }) // active tasks
            .mockResolvedValueOnce({ Success: true, Results: [{ TaskID: TASK_2 }] }) // delegated check
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    {
                        ID: 'wr-1',
                        Title: 'Daily Work Report',
                        PersonID: PERSON_ALICE,
                        Person: 'Alice Ng',
                        Status: 'Draft',
                        PeriodStart: '2026-11-20',
                        PeriodEnd: '2026-11-20',
                    },
                ],
            }); // unreviewed work reports

        const params = makeParams({ HorizonDays: 7 });
        const res = await run(new GetMyTasksBriefingAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        const briefing = JSON.parse(String(params.find((p) => p.Name === 'Briefing')?.Value));
        expect(briefing.Counts).toMatchObject({
            Overdue: 1,
            Blocked: 1,
            WaitingOnOthers: 1,
            PendingApprovals: 1,
            UnreviewedWorkReports: 1,
        });
    });

    it('scopes GetMyTasksBriefingAction by OrganizationName and returns OrganizationID/Organization on items', async () => {
        const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();

        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: ORG_1, Name: 'Acme Enterprise Corp' }] }) // org lookup
            .mockResolvedValueOnce({ Success: true, Results: [{ TaskID: TASK_1 }] }) // assigned tasks
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TYPE_GENERAL, Name: 'General', Code: 'GENERAL', IsApproval: false }] }) // task types
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    {
                        ID: TASK_1,
                        Name: 'Acme SLA Audit',
                        Status: 'Open',
                        Priority: 'High',
                        DueAt: yesterday,
                        TypeID: TYPE_GENERAL,
                        Type: 'General',
                        OrganizationID: ORG_1,
                        Organization: 'Acme Enterprise Corp',
                        PercentComplete: 25,
                        CreatedByPersonID: PERSON_ALICE,
                    },
                ],
            }) // active tasks filtered by org
            .mockResolvedValueOnce({ Success: true, Results: [] }); // unreviewed work reports

        const params = makeParams({ OrganizationName: 'Acme Enterprise Corp' });
        const res = await run(new GetMyTasksBriefingAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(runViewMock.mock.calls[3][0].ExtraFilter).toContain(`OrganizationID = '${ORG_1}'`);
        const briefing = JSON.parse(String(params.find((p) => p.Name === 'Briefing')?.Value));
        expect(briefing.OrganizationID).toBe(ORG_1);
        expect(briefing.OrganizationName).toBe('Acme Enterprise Corp');
        expect(briefing.OverdueTasks).toHaveLength(1);
        expect(briefing.OverdueTasks[0].OrganizationID).toBe(ORG_1);
        expect(briefing.OverdueTasks[0].Organization).toBe('Acme Enterprise Corp');
    });
});
