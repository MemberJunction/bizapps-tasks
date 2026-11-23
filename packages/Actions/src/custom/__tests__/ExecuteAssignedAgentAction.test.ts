import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { RunActionParams } from '@memberjunction/actions-base';
import type { UserInfo } from '@memberjunction/core';

interface MockTaskState {
    ID: string;
    Name: string;
    Description: string;
    Status: string;
    Priority: string;
    PercentComplete: number;
    CompletionNotes: string | null;
    BlockedReason: string | null;
    CompletedAt: Date | null;
    DueAt: Date | null;
    CreatedByPersonID: string | null;
    Load: ReturnType<typeof vi.fn>;
    Save: ReturnType<typeof vi.fn>;
}

interface MockAgentRunLink {
    TaskID: string;
    AIAgentRunID: string;
    Role: string;
    Notes: string;
    NewRecord: ReturnType<typeof vi.fn>;
    Save: ReturnType<typeof vi.fn>;
}

interface MockCommentRow {
    ID: string;
    TaskID: string;
    PersonID: string;
    Content: string;
    NewRecord: ReturnType<typeof vi.fn>;
    Save: ReturnType<typeof vi.fn>;
}

const {
    USER,
    TASK_ID,
    AGENT_ID,
    AGENT_RUN_ID,
    PERSON_ID,
    AI_AGENTS_ENT_ID,
    state,
    savedAgentRuns,
    savedComments,
    runAgentMock,
    wakeMock,
} = vi.hoisted(() => {
    const user = { ID: '55555555-5555-4555-8555-555555555555', Email: 'assigner@acme.test' } as UserInfo;
    return {
        USER: user,
        TASK_ID: '11111111-1111-4111-8111-111111111111',
        AGENT_ID: '22222222-2222-4222-8222-222222222222',
        AGENT_RUN_ID: '33333333-3333-4333-8333-333333333333',
        PERSON_ID: '66666666-6666-4666-8666-666666666666',
        AI_AGENTS_ENT_ID: '44444444-4444-4444-8444-444444444444',
        state: { task: null as MockTaskState | null },
        savedAgentRuns: [] as MockAgentRunLink[],
        savedComments: [] as MockCommentRow[],
        runAgentMock: vi.fn(),
        wakeMock: vi.fn(async () => ({ Dispatched: true })),
    };
});

vi.mock('@memberjunction/global', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/global')>();
    return { ...actual, RegisterClass: () => () => {} };
});

vi.mock('@memberjunction/actions', () => ({
    BaseAction: class {},
}));

vi.mock('@memberjunction/ai-core-plus', () => ({
    AgentUserPolicyEngine: {
        Instance: {
            GetExecutingAgentID: () => null,
            GetEffectivePolicyAgentChain: () => [],
        },
    },
    TypedActionPolicyGuard: {
        CheckEntityAccess: vi.fn(async () => ({ Allowed: true })),
    },
}));

vi.mock('@memberjunction/aiengine', () => ({
    AIEngine: {
        Instance: {
            Config: vi.fn(async () => undefined),
            Agents: [{ ID: AGENT_ID, Name: 'Close Reconciliation Bot', Status: 'Active' }],
        },
    },
}));

vi.mock('@memberjunction/ai-agents', () => ({
    AgentRunner: class {
        public RunAgent(args: { agent: { ID: string }; conversationMessages: Array<{ role: string; content: string }> }) {
            return runAgentMock(args);
        }
    },
    AgentWakeTriggerService: {
        Instance: {
            TriggerWakeForWorkstream: (...args: Array<{ targetUserID: string; workstreamKey: string }>) =>
                wakeMock(...args),
        },
    },
}));

vi.mock('@memberjunction/generic-database-provider', () => ({
    UserCache: { Instance: { Users: [], GetSystemUser: () => USER } },
}));

vi.mock('@mj-biz-apps/common-entities', () => ({
    BusinessTimeZoneEngine: { Instance: {} },
    ResolveUserIDForPerson: vi.fn(async () => USER.ID),
}));

vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    const provider = {
        Entities: [{ ID: AI_AGENTS_ENT_ID, Name: 'MJ: AI Agents' }],
        EntityByName: (name: string) =>
            name === 'MJ: AI Agents' ? { ID: AI_AGENTS_ENT_ID, Name: 'MJ: AI Agents' } : undefined,
    };
    return {
        ...actual,
        LogError: vi.fn(),
        Metadata: Object.assign(
            class {
                public async GetEntityObject(entityName: string) {
                    if (entityName === 'MJ_BizApps_Tasks: Tasks') {
                        return state.task;
                    }
                    if (entityName === 'MJ_BizApps_Tasks: Task Agent Runs') {
                        const row: MockAgentRunLink = {
                            TaskID: '',
                            AIAgentRunID: '',
                            Role: '',
                            Notes: '',
                            NewRecord: vi.fn(),
                            Save: vi.fn(async () => true),
                        };
                        savedAgentRuns.push(row);
                        return row;
                    }
                    if (entityName === 'MJ_BizApps_Tasks: Task Comments') {
                        const comment: MockCommentRow = {
                            ID: '77777777-7777-4777-8777-777777777777',
                            TaskID: '',
                            PersonID: '',
                            Content: '',
                            NewRecord: vi.fn(),
                            Save: vi.fn(async () => true),
                        };
                        savedComments.push(comment);
                        return comment;
                    }
                    throw new Error(`Unexpected entity ${entityName}`);
                }
            },
            { Provider: provider },
        ),
        RunView: class {
            public async RunView(params: { EntityName: string }) {
                if (params.EntityName === 'MJ_BizApps_Common: People') {
                    return { Success: true, Results: [{ ID: PERSON_ID, LinkedUserID: USER.ID }] };
                }
                if (params.EntityName === 'MJ_BizApps_Tasks: Task Assignments') {
                    return {
                        Success: true,
                        Results: [{ AssigneeEntityID: AI_AGENTS_ENT_ID, AssigneeRecordID: AGENT_ID }],
                    };
                }
                return { Success: true, Results: [] };
            }
        },
    };
});

import { ExecuteAssignedAgentAction } from '../ExecuteAssignedAgentAction.js';

class TestableExecuteAssignedAgentAction extends ExecuteAssignedAgentAction {
    public runTest(params: RunActionParams) {
        return this.InternalRunAction(params);
    }
}

beforeEach(() => {
    vi.clearAllMocks();
    savedAgentRuns.length = 0;
    savedComments.length = 0;
    state.task = {
        ID: TASK_ID,
        Name: 'Reconcile Q4 Cash Ledger',
        Description: 'Compare GL cash entries against bank statement',
        Status: 'Open',
        Priority: 'High',
        PercentComplete: 0,
        CompletionNotes: null,
        BlockedReason: null,
        CompletedAt: null,
        DueAt: null,
        CreatedByPersonID: PERSON_ID,
        Load: vi.fn(async () => true),
        Save: vi.fn(async () => true),
    };
});

describe('ExecuteAssignedAgentAction — AGENT_TASK End-to-End Execution & Finalization', () => {
    it('dispatches Async=true in background, transitions to InProgress (90%), links TaskAgentRun, posts TaskComment, and wakes Chief of Staff', async () => {
        runAgentMock.mockResolvedValueOnce({
            success: true,
            agentRun: { ID: AGENT_RUN_ID },
            payload: { summary: 'Reconciled 42 cash transactions with zero variance.' },
        });

        const params: RunActionParams = {
            ContextUser: USER,
            Action: { ID: 'act-exec', Name: 'Execute Assigned Agent' } as RunActionParams['Action'],
            Filters: [],
            Params: [
                { Name: 'TaskID', Type: 'Input', Value: TASK_ID },
                { Name: 'AgentID', Type: 'Input', Value: AGENT_ID },
                { Name: 'AssigneeEntityID', Type: 'Input', Value: AI_AGENTS_ENT_ID },
                { Name: 'AssigneeRecordID', Type: 'Input', Value: AGENT_ID },
                { Name: 'Async', Type: 'Input', Value: 'true' },
            ],
        };

        const dispatchRes = await new TestableExecuteAssignedAgentAction().runTest(params);
        expect(dispatchRes.Success).toBe(true);
        expect(dispatchRes.ResultCode).toBe('DISPATCHED');

        await ExecuteAssignedAgentAction.WaitForPendingExecutions();

        expect(runAgentMock).toHaveBeenCalledTimes(1);
        expect(savedAgentRuns).toHaveLength(1);
        expect(savedAgentRuns[0].TaskID).toBe(TASK_ID);
        expect(savedAgentRuns[0].AIAgentRunID).toBe(AGENT_RUN_ID);
        expect(savedAgentRuns[0].Role).toBe('Executed');

        expect(savedComments).toHaveLength(1);
        expect(savedComments[0].TaskID).toBe(TASK_ID);
        expect(savedComments[0].Content).toContain('Reconciled 42 cash transactions with zero variance.');

        expect(state.task?.Status).toBe('InProgress');
        expect(state.task?.PercentComplete).toBe(90);
        expect(wakeMock).toHaveBeenCalledTimes(1);
    });

    it('marks AGENT_TASK Blocked with error details and posts failure comment when agent run fails', async () => {
        runAgentMock.mockResolvedValueOnce({
            success: false,
            agentRun: { ID: AGENT_RUN_ID, ErrorMessage: 'Bank API credentials expired' },
            errorMessage: 'Bank API credentials expired',
        });

        const params: RunActionParams = {
            ContextUser: USER,
            Action: { ID: 'act-exec', Name: 'Execute Assigned Agent' } as RunActionParams['Action'],
            Filters: [],
            Params: [
                { Name: 'TaskID', Type: 'Input', Value: TASK_ID },
                { Name: 'AgentID', Type: 'Input', Value: AGENT_ID },
                { Name: 'Async', Type: 'Input', Value: 'true' },
            ],
        };

        const dispatchRes = await new TestableExecuteAssignedAgentAction().runTest(params);
        expect(dispatchRes.Success).toBe(true);
        expect(dispatchRes.ResultCode).toBe('DISPATCHED');

        await ExecuteAssignedAgentAction.WaitForPendingExecutions();

        expect(state.task?.Status).toBe('Blocked');
        expect(state.task?.BlockedReason).toContain('Bank API credentials expired');
        expect(savedComments).toHaveLength(1);
        expect(savedComments[0].Content).toContain('encountered an error');
        expect(wakeMock).toHaveBeenCalledTimes(1);
    });
});
