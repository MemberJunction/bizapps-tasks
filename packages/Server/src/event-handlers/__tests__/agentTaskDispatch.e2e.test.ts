import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { ActionParam, RunActionParams } from '@memberjunction/actions-base';
import type { UserInfo } from '@memberjunction/core';
import type { mjBizAppsTasksTaskAssignmentEntity } from '@mj-biz-apps/tasks-entities';
import { BaseEntityEvent } from '@memberjunction/core';

const {
    TASK_ID,
    TYPE_AGENT_TASK,
    AGENT_ID,
    AI_AGENTS_ENTITY_ID,
    ASSIGN_ACTION_ID,
    USER_1,
    dispatchedRuns,
    sendNotificationMock,
} = vi.hoisted(() => ({
    TASK_ID: '11111111-1111-4111-8111-111111111111',
    TYPE_AGENT_TASK: '665697FE-9B18-4691-B40C-BE849FE60216',
    AGENT_ID: '22222222-2222-4222-8222-222222222222',
    AI_AGENTS_ENTITY_ID: '44444444-4444-4444-8444-444444444444',
    ASSIGN_ACTION_ID: '0B8057F4-5E00-45E7-929E-84A9B5007AB0',
    USER_1: { ID: '55555555-5555-4555-8555-555555555555', Email: 'assigner@acme.test', Name: 'Alice Assigner' } as UserInfo,
    dispatchedRuns: [] as RunActionParams[],
    sendNotificationMock: vi.fn(),
}));

vi.mock('@mj-biz-apps/tasks-entities', () => ({
    mjBizAppsTasksTaskEntity: class {},
}));

vi.mock('../../workflow/workflow-step-completion.js', () => ({
    SettleHumanAsksForTask: vi.fn(),
}));

vi.mock('../../role-assignees.js', () => ({
    IsRoleEntityID: () => false,
    ResolveUserIDsForRoles: vi.fn(async () => []),
    RoleName: () => null,
}));

vi.mock('@mj-biz-apps/common-entities', () => ({
    ResolveUserIDsForPeople: vi.fn(async () => new Map()),
    ResolveUserIDForPerson: vi.fn(async () => null),
}));

vi.mock('@memberjunction/global', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/global')>();
    return {
        ...actual,
        MJEventType: { ComponentEvent: 'ComponentEvent' },
        MJGlobal: {
            Instance: {
                GetGlobalObjectStore: () => ({}),
                GetEventListener: () => ({ subscribe: () => ({ unsubscribe() {} }) }),
            },
        },
    };
});

vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    const provider = {
        Entities: [{ ID: AI_AGENTS_ENTITY_ID, Name: 'MJ: AI Agents' }],
        EntityByName: (name: string) =>
            name === 'MJ: AI Agents' ? { ID: AI_AGENTS_ENTITY_ID, Name: 'MJ: AI Agents' } : undefined,
    };

    return {
        ...actual,
        BaseEntity: class {
            static BaseEventCode = 'BaseEntity';
        },
        LogError: vi.fn(),
        LogStatus: vi.fn(),
        Metadata: class {
            static Provider = provider;
        },
        RunView: class {
            public async RunView(params: { EntityName: string }) {
                if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                    return {
                        Success: true,
                        Results: [
                            {
                                ID: TASK_ID,
                                Name: 'Reconcile Q4 Cash Ledger',
                                Status: 'Open',
                                TypeID: TYPE_AGENT_TASK,
                                Priority: 'High',
                                DueAt: null,
                            },
                        ],
                    };
                }
                if (params.EntityName === 'MJ_BizApps_Tasks: Task Types') {
                    return {
                        Success: true,
                        Results: [{ ID: TYPE_AGENT_TASK, Name: 'Agent Task', OnAssignActionID: ASSIGN_ACTION_ID }],
                    };
                }
                return { Success: true, Results: [] };
            }
        },
        UserInfo: class {},
    };
});

vi.mock('@memberjunction/notifications', () => ({
    NotificationEngine: { Instance: { Config: vi.fn(), SendNotification: sendNotificationMock } },
}));

vi.mock('@memberjunction/actions', () => ({
    ActionEngineServer: {
        Instance: {
            Config: vi.fn(async () => undefined),
            Actions: [{ ID: ASSIGN_ACTION_ID, Name: 'Execute Assigned Agent' }],
            RunAction: vi.fn(async (args: RunActionParams) => {
                dispatchedRuns.push(args);
                return { Success: true, ResultCode: 'DISPATCHED', Message: 'Dispatched agent asynchronously' };
            }),
        },
    },
}));

import { handleAssignmentSave } from '../TaskNotificationHandler.js';

beforeEach(() => {
    vi.clearAllMocks();
    dispatchedRuns.length = 0;
});

describe('AGENT_TASK Workflow Dispatch (TaskNotificationHandler -> ActionEngineServer)', () => {
    it('routes AI Agent assignment on AGENT_TASK directly to Execute Assigned Agent with Async=true and skips human People lookup', async () => {
        const assignmentEntity = {
            ContextCurrentUser: USER_1,
            AssigneeEntityID: AI_AGENTS_ENTITY_ID,
            AssigneeRecordID: AGENT_ID,
            TaskID: TASK_ID,
            RoleID: null,
        } as mjBizAppsTasksTaskAssignmentEntity;

        const event = {
            type: 'save',
            saveSubType: 'create',
            baseEntity: assignmentEntity,
        } as BaseEntityEvent;

        await handleAssignmentSave(event);

        expect(sendNotificationMock).not.toHaveBeenCalled();
        expect(dispatchedRuns).toHaveLength(1);
        const run = dispatchedRuns[0];
        const paramMap = new Map<string, ActionParam['Value']>(run.Params.map((p) => [p.Name, p.Value]));
        expect(paramMap.get('TaskID')).toBe(TASK_ID);
        expect(paramMap.get('TaskTypeID')).toBe(TYPE_AGENT_TASK);
        expect(paramMap.get('AssigneeEntityID')).toBe(AI_AGENTS_ENTITY_ID);
        expect(paramMap.get('AssigneeRecordID')).toBe(AGENT_ID);
        expect(paramMap.get('AgentID')).toBe(AGENT_ID);
        expect(paramMap.get('AssigneePersonID')).toBeNull();
        expect(paramMap.get('Async')).toBe('true');
    });
});
