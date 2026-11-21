import { describe, it, expect, beforeEach, vi } from 'vitest';
import type { ActionParam, ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import type { UserInfo } from '@memberjunction/core';

const {
    checkEntityAccessMock,
    resolvePersonForUserMock,
    resolveUserIDForPersonMock,
    triggerWakeMock,
    getSystemUserMock,
    runViewMock,
    getEntityObjectMock,
    aiEngineConfigMock,
    agentRunnerRunAgentMock,
    agentsList,
    entitiesList,
} = vi.hoisted(() => ({
    checkEntityAccessMock: vi.fn(),
    resolvePersonForUserMock: vi.fn(),
    resolveUserIDForPersonMock: vi.fn(),
    triggerWakeMock: vi.fn(),
    getSystemUserMock: vi.fn(),
    runViewMock: vi.fn(),
    getEntityObjectMock: vi.fn(),
    aiEngineConfigMock: vi.fn(),
    agentRunnerRunAgentMock: vi.fn(),
    agentsList: [] as Array<{ ID: string; Name: string; Status: string }>,
    entitiesList: [
        { ID: 'e0000003-0000-4000-8000-000000000003', Name: 'MJ: AI Agents' },
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
            public static Provider = { Entities: entitiesList };
            public Entities = entitiesList;
            public GetEntityObject = getEntityObjectMock;
        },
        RunView: class {
            public RunView = runViewMock;
        },
    };
});
vi.mock('@memberjunction/ai-core-plus', () => ({
    TypedActionPolicyGuard: {
        CheckEntityAccess: checkEntityAccessMock,
    },
}));
vi.mock('@memberjunction/aiengine', () => ({
    AIEngine: {
        Instance: {
            Config: aiEngineConfigMock,
            get Agents() {
                return agentsList;
            },
        },
    },
}));
vi.mock('@memberjunction/ai-agents', () => ({
    AgentRunner: class {
        public RunAgent = agentRunnerRunAgentMock;
    },
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
            },
        },
    };
});

import { ExecuteAssignedAgentAction } from '../custom/ExecuteAssignedAgentAction.js';

interface Invokable {
    InternalRunAction(params: RunActionParams): Promise<ActionResultSimple>;
}

const USER_ALICE = 'aaaa1111-1111-4111-8111-111111111111';
const USER_CREATOR = 'bbbb2222-2222-4222-8222-222222222222';
const SYSTEM_USER_ID = '99999999-9999-4999-8999-999999999999';
const PERSON_ALICE = '11111111-1111-4111-8111-111111111111';
const PERSON_CREATOR = '22222222-2222-4222-8222-222222222222';
const TASK_1 = '33333333-3333-4333-8333-333333333301';
const AGENT_1 = '44444444-4444-4444-8444-444444444401';
const AGENT_RUN_1 = '55555555-5555-4555-8555-555555555501';

function makeParams(inputs: Record<string, string | boolean | null | undefined>): ActionParam[] {
    return Object.entries(inputs).map(([Name, Value]) => ({ Name, Value, Type: 'Input' as const }));
}

function makeRunParams(params: ActionParam[]): RunActionParams {
    return {
        ContextUser: { ID: USER_ALICE, Name: 'Alice Ng', Email: 'alice@example.com' } as Partial<UserInfo> as UserInfo,
        Params: params,
    } as Partial<RunActionParams> as RunActionParams;
}

function run(action: ExecuteAssignedAgentAction, params: RunActionParams): Promise<ActionResultSimple> {
    return (action as Partial<Invokable> as Invokable).InternalRunAction(params);
}

beforeEach(() => {
    vi.clearAllMocks();
    getEntityObjectMock.mockReset();
    runViewMock.mockReset();
    agentRunnerRunAgentMock.mockReset();
    agentsList.length = 0;
    checkEntityAccessMock.mockResolvedValue({ Allowed: true, Active: true, DeniedFieldPatterns: [] });
    resolvePersonForUserMock.mockResolvedValue({ ID: PERSON_ALICE });
    getSystemUserMock.mockReturnValue({ ID: SYSTEM_USER_ID, Name: 'System', Email: 'system@mj.local' });
    triggerWakeMock.mockResolvedValue({ triggered: true, resultCode: 'WAKE_SCHEDULED' });
});

describe('ExecuteAssignedAgentAction', () => {
    it('declares AuthorizesCaller = true and enforces TypedActionPolicyGuard', async () => {
        expect(ExecuteAssignedAgentAction.AuthorizesCaller).toBe(true);
        checkEntityAccessMock.mockResolvedValueOnce({
            Allowed: false,
            Active: true,
            DeniedFieldPatterns: [],
            ResultCode: 'POLICY_DENIED',
            Message: 'ReadOnly policy blocks task updates.',
        });

        const res = await run(new ExecuteAssignedAgentAction(), makeRunParams(makeParams({ TaskID: TASK_1 })));
        expect(res).toMatchObject({ Success: false, ResultCode: 'POLICY_DENIED' });
    });

    it('returns NO_AGENT_ASSIGNED cleanly when task has no AI Agent assignment', async () => {
        getEntityObjectMock.mockResolvedValueOnce({
            ID: TASK_1,
            Name: 'Human task',
            Status: 'Open',
            Load: vi.fn().mockResolvedValue(true),
        });
        runViewMock.mockResolvedValueOnce({ Success: true, Results: [] });

        const res = await run(new ExecuteAssignedAgentAction(), makeRunParams(makeParams({ TaskID: TASK_1 })));
        expect(res).toMatchObject({ Success: true, ResultCode: 'NO_AGENT_ASSIGNED' });
        expect(agentRunnerRunAgentMock).not.toHaveBeenCalled();
    });

    it('executes assigned agent, links run, posts comment, updates status, and wakes assigner + cross-user creator CoS', async () => {
        agentsList.push({ ID: AGENT_1, Name: 'Research Agent', Status: 'Active' });

        const taskEntity = {
            ID: TASK_1,
            Name: 'Research competitor pricing',
            Description: 'Compare top 3 competitors.',
            Status: 'Open',
            Priority: 'High',
            PercentComplete: 0,
            CreatedByPersonID: PERSON_CREATOR,
            CompletionNotes: null as string | null,
            BlockedReason: null as string | null,
            Load: vi.fn().mockResolvedValue(true),
            Save: vi.fn().mockResolvedValue(true),
        };
        const runLinkEntity = {
            ID: 'tar-1',
            TaskID: '',
            AIAgentRunID: '',
            Role: '',
            Notes: '',
            NewRecord: vi.fn(),
            Save: vi.fn().mockResolvedValue(true),
        };
        const commentEntity = {
            ID: 'cmt-1',
            TaskID: '',
            PersonID: '',
            Content: '',
            NewRecord: vi.fn(),
            Save: vi.fn().mockResolvedValue(true),
        };

        getEntityObjectMock
            .mockResolvedValueOnce(taskEntity)
            .mockResolvedValueOnce(runLinkEntity)
            .mockResolvedValueOnce(commentEntity);
        runViewMock.mockResolvedValueOnce({ Success: true, Results: [{ AssigneeRecordID: AGENT_1 }] });
        resolveUserIDForPersonMock.mockResolvedValueOnce(USER_CREATOR);

        agentRunnerRunAgentMock.mockResolvedValueOnce({
            success: true,
            payload: { summary: 'Compiled competitor pricing comparison matrix.' },
            agentRun: { ID: AGENT_RUN_1 },
        });

        const params = makeParams({ TaskID: TASK_1 });
        const res = await run(new ExecuteAssignedAgentAction(), makeRunParams(params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(agentRunnerRunAgentMock).toHaveBeenCalledWith(
            expect.objectContaining({
                agent: expect.objectContaining({ ID: AGENT_1 }),
                contextUser: expect.objectContaining({ ID: USER_ALICE }),
            }),
        );
        expect(runLinkEntity.AIAgentRunID).toBe(AGENT_RUN_1);
        expect(commentEntity.Content).toContain('Compiled competitor pricing comparison matrix.');
        expect(taskEntity.Status).toBe('InProgress');
        expect(taskEntity.PercentComplete).toBe(90);

        // Both assigner (self) and creator (cross-user -> system user) woken on coalesced 'tasks-inbox'
        expect(triggerWakeMock).toHaveBeenCalledTimes(2);
        expect(triggerWakeMock).toHaveBeenCalledWith(
            expect.objectContaining({
                targetUserID: USER_ALICE,
                workstreamKey: 'tasks-inbox',
                contextUser: expect.objectContaining({ ID: USER_ALICE }),
            }),
        );
        expect(triggerWakeMock).toHaveBeenCalledWith(
            expect.objectContaining({
                targetUserID: USER_CREATOR,
                workstreamKey: 'tasks-inbox',
                contextUser: expect.objectContaining({ ID: SYSTEM_USER_ID }),
            }),
        );
    });

    it('dispatches non-blocking background execution when Async = true and completes artifacts + tasks-inbox wake', async () => {
        agentsList.push({ ID: AGENT_1, Name: 'Async Research Agent', Status: 'Active' });

        const taskEntity = {
            ID: TASK_1,
            Name: 'Deep market synthesis',
            Description: 'Run deep market analysis.',
            Status: 'Open',
            Priority: 'High',
            PercentComplete: 0,
            CreatedByPersonID: PERSON_CREATOR,
            CompletionNotes: null as string | null,
            BlockedReason: null as string | null,
            Load: vi.fn().mockResolvedValue(true),
            Save: vi.fn().mockResolvedValue(true),
        };
        const runLinkEntity = {
            ID: 'tar-async-1',
            TaskID: '',
            AIAgentRunID: '',
            Role: '',
            Notes: '',
            NewRecord: vi.fn(),
            Save: vi.fn().mockResolvedValue(true),
        };
        const commentEntity = {
            ID: 'cmt-async-1',
            TaskID: '',
            PersonID: '',
            Content: '',
            NewRecord: vi.fn(),
            Save: vi.fn().mockResolvedValue(true),
        };

        getEntityObjectMock
            .mockResolvedValueOnce(taskEntity)
            .mockResolvedValueOnce(runLinkEntity)
            .mockResolvedValueOnce(commentEntity);
        resolveUserIDForPersonMock.mockResolvedValueOnce(USER_CREATOR);

        let resolveAgent!: (val: {
            success: boolean;
            payload: { summary: string };
            agentRun: { ID: string };
        }) => void;
        agentRunnerRunAgentMock.mockReturnValueOnce(
            new Promise((resolve) => {
                resolveAgent = resolve;
            }),
        );

        const params = makeParams({ TaskID: TASK_1, AgentID: AGENT_1, Async: true });
        const res = await run(new ExecuteAssignedAgentAction(), makeRunParams(params));

        // Returns immediately before the agent finishes!
        expect(res).toMatchObject({ Success: true, ResultCode: 'DISPATCHED' });
        expect(params.find((p) => p.Name === 'Async')?.Value).toBe(true);
        expect(taskEntity.Status).toBe('InProgress');
        expect(triggerWakeMock).not.toHaveBeenCalled();

        // Complete the background agent run and flush pending executions deterministically
        resolveAgent({
            success: true,
            payload: { summary: 'Async market synthesis complete.' },
            agentRun: { ID: AGENT_RUN_1 },
        });
        await ExecuteAssignedAgentAction.WaitForPendingExecutions();

        expect(runLinkEntity.AIAgentRunID).toBe(AGENT_RUN_1);
        expect(commentEntity.Content).toContain('Async market synthesis complete.');
        expect(taskEntity.PercentComplete).toBe(90);
        expect(triggerWakeMock).toHaveBeenCalledWith(
            expect.objectContaining({
                targetUserID: USER_CREATOR,
                workstreamKey: 'tasks-inbox',
            }),
        );
    });

    it('marks task Blocked and returns AGENT_EXECUTION_FAILED when the assigned agent fails', async () => {
        agentsList.push({ ID: AGENT_1, Name: 'Factory Agent', Status: 'Active' });

        const taskEntity = {
            ID: TASK_1,
            Name: 'Generate release notes',
            Status: 'Open',
            Priority: 'Medium',
            PercentComplete: 0,
            CreatedByPersonID: PERSON_ALICE,
            BlockedReason: null as string | null,
            Load: vi.fn().mockResolvedValue(true),
            Save: vi.fn().mockResolvedValue(true),
        };
        const commentEntity = {
            ID: 'cmt-err',
            Content: '',
            NewRecord: vi.fn(),
            Save: vi.fn().mockResolvedValue(true),
        };

        getEntityObjectMock
            .mockResolvedValueOnce(taskEntity)
            .mockResolvedValueOnce(commentEntity);
        resolveUserIDForPersonMock.mockResolvedValueOnce(USER_ALICE);

        agentRunnerRunAgentMock.mockResolvedValueOnce({
            success: false,
            errorMessage: 'Upstream API timed out',
            agentRun: { ID: '', ErrorMessage: 'Upstream API timed out' },
        });

        const params = makeParams({ TaskID: TASK_1, AgentID: AGENT_1 });
        const res = await run(new ExecuteAssignedAgentAction(), makeRunParams(params));

        expect(res).toMatchObject({ Success: false, ResultCode: 'AGENT_EXECUTION_FAILED' });
        expect(taskEntity.Status).toBe('Blocked');
        expect(taskEntity.BlockedReason).toContain('Upstream API timed out');
        expect(commentEntity.Content).toContain('Upstream API timed out');
    });
});
