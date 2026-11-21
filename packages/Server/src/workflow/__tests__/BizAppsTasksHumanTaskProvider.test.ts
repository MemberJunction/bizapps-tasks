import { beforeEach, describe, expect, it, vi } from 'vitest';

const STEP_ENTITY_ID = 'A0000000-0000-0000-0000-000000000001';
const REQUEST_ENTITY_ID = 'A0000000-0000-0000-0000-000000000009';
const USERS_ENTITY_ID = 'A0000000-0000-0000-0000-000000000005';
const TYPE_ID = 'D0000000-0000-0000-0000-000000000001';
const REQUEST_ID = 'F0000000-0000-0000-0000-000000000001';
const STEP_ID = 'C0000000-0000-0000-0000-000000000001';
const OWNER_ID = 'E0000000-0000-0000-0000-000000000001';

/** Shared with the hoisted mocks: link rows already present, every saved record, every registration. */
const { db, saved, registrations } = vi.hoisted(() => ({
    db: { existingLinks: [] as Record<string, string | null>[] },
    saved: [] as Array<{ Entity: string; Record: Record<string, unknown> }>,
    registrations: [] as Array<{ key: string; metadata?: Record<string, unknown> }>,
}));

vi.mock('@memberjunction/core', () => ({
    LogError: vi.fn(),
    RunView: {
        FromMetadataProvider: () => ({
            RunView: async () => ({ Success: true, Results: db.existingLinks }),
            RunViews: async () => [
                { Success: true, Results: [{ ID: 'D0000000-0000-0000-0000-000000000001', IsActive: true }] },
                { Success: true, Results: [] },
            ],
        }),
    },
}));

vi.mock('@memberjunction/global', () => ({
    EscapeSQLString: (v: string) => v.replace(/'/g, "''"),
    RegisterClassEx: (_base: unknown, options: { key: string; metadata?: Record<string, unknown> }) => () => {
        registrations.push(options);
    },
}));

vi.mock('@memberjunction/ai-core-plus', () => ({
    BaseHumanTaskProvider: class {},
    HUMAN_TASK_PROVIDER_CAN_BE_DEFAULT: 'CanBeDefault',
    ResolveMappedInput: (value: unknown) => value,
}));

vi.mock('@mj-biz-apps/tasks-entities-server', () => {
    class TaskLinkEntityServer {
        public Authorized = false;
        public AuthorizeHumanAskLink(): void {
            this.Authorized = true;
        }
    }
    return {
        TaskLinkEntityServer,
        TASK_LINK_ENTITY: 'MJ_BizApps_Tasks: Task Links',
        WORKFLOW_STEP_ENTITY: 'MJ: Tasks',
        AGENT_REQUEST_ENTITY: 'MJ: AI Agent Requests',
        PEOPLE_ENTITY: 'MJ_BizApps_Common: People',
    };
});

import { TaskLinkEntityServer } from '@mj-biz-apps/tasks-entities-server';
import { BizAppsTasksHumanTaskProvider, HumanAskRecord } from '../BizAppsTasksHumanTaskProvider.js';
import type { HumanTaskRaiseContext } from '@memberjunction/ai-core-plus';
import type { IMetadataProvider, UserInfo } from '@memberjunction/core';

const ENTITY_IDS: Record<string, string> = {
    'MJ: Tasks': STEP_ENTITY_ID,
    'MJ: AI Agent Requests': REQUEST_ENTITY_ID,
    'MJ: Users': USERS_ENTITY_ID,
};

let nextID = 0;
const provider = {
    EntityByName: (name: string) => (ENTITY_IDS[name] ? { ID: ENTITY_IDS[name] } : undefined),
    GetEntityObject: async (entity: string) => {
        const record: Record<string, unknown> =
            entity === 'MJ_BizApps_Tasks: Task Links' ? new TaskLinkEntityServer() as unknown as Record<string, unknown> : {};
        Object.assign(record, {
            NewRecord: () => true,
            Save: async () => {
                record['ID'] = record['ID'] ?? `id-${++nextID}`;
                saved.push({ Entity: entity, Record: record });
                return true;
            },
        });
        return record;
    },
} as unknown as IMetadataProvider;

function context(overrides: Partial<HumanTaskRaiseContext>): HumanTaskRaiseContext {
    return {
        Subject: { Kind: 'AgentRequest', AgentRequestID: REQUEST_ID, AgentRunID: null },
        Name: 'Research Agent',
        Instructions: 'Which region should I use?',
        AssignedUserID: null,
        OwnerUserID: OWNER_ID,
        DueAt: null,
        Payload: {},
        ProviderConfiguration: {},
        ContextUser: { ID: OWNER_ID } as UserInfo,
        Provider: provider,
        ...overrides,
    };
}

function savedOf(entity: string): Record<string, unknown>[] {
    return saved.filter((s) => s.Entity === entity).map((s) => s.Record);
}

beforeEach(() => {
    saved.length = 0;
    db.existingLinks = [];
});

describe('BizAppsTasksHumanTaskProvider registration', () => {
    it('registers under BizAppsTasks and declares it can be the install default', () => {
        expect(registrations).toEqual([{ key: 'BizAppsTasks', metadata: { CanBeDefault: true } }]);
    });
});

describe('HumanAskRecord', () => {
    it("points at the step's MJ: Tasks row or at the agent request", () => {
        expect(HumanAskRecord({ Kind: 'WorkflowStep', TaskID: STEP_ID, ParentTaskID: 'p' })).toEqual({ EntityName: 'MJ: Tasks', RecordID: STEP_ID });
        expect(HumanAskRecord({ Kind: 'AgentRequest', AgentRequestID: REQUEST_ID, AgentRunID: null })).toEqual({ EntityName: 'MJ: AI Agent Requests', RecordID: REQUEST_ID });
    });
});

describe('BizAppsTasksHumanTaskProvider.RaiseTask — an agent request', () => {
    it('raises one task linked to the agent request, through an authorized link, for the user who ran the agent', async () => {
        const result = await new BizAppsTasksHumanTaskProvider().RaiseTask(context({}));
        expect(result).toMatchObject({ Outcome: 'raised' });

        const [task] = savedOf('MJ_BizApps_Tasks: Tasks');
        expect(task).toMatchObject({ Name: 'Research Agent', Description: 'Which region should I use?', TypeID: TYPE_ID, Status: 'Open' });
        const [link] = savedOf('MJ_BizApps_Tasks: Task Links');
        expect(link).toMatchObject({ TaskID: task['ID'], EntityID: REQUEST_ENTITY_ID, RecordID: REQUEST_ID, Authorized: true });
        const [assignment] = savedOf('MJ_BizApps_Tasks: Task Assignments');
        expect(assignment).toMatchObject({ AssigneeEntityID: USERS_ENTITY_ID, AssigneeRecordID: OWNER_ID });
    });

    it('assigns the user the request names over the user who ran the agent', async () => {
        await new BizAppsTasksHumanTaskProvider().RaiseTask(context({ AssignedUserID: 'E0000000-0000-0000-0000-000000000002' }));
        expect(savedOf('MJ_BizApps_Tasks: Task Assignments')[0]).toMatchObject({ AssigneeRecordID: 'E0000000-0000-0000-0000-000000000002' });
    });

    it('does not raise a second task for a request already linked to one', async () => {
        db.existingLinks = [{ ID: 'l', TaskID: 'existing-task' }];
        const result = await new BizAppsTasksHumanTaskProvider().RaiseTask(context({}));
        expect(result).toEqual({ Outcome: 'raised', ExternalReference: 'existing-task' });
        expect(saved).toHaveLength(0);
    });
});

describe('BizAppsTasksHumanTaskProvider.RaiseTask — a workflow step', () => {
    it("never falls back to the workflow's owner: a step that names no one is refused", async () => {
        const result = await new BizAppsTasksHumanTaskProvider().RaiseTask(
            context({ Subject: { Kind: 'WorkflowStep', TaskID: STEP_ID, ParentTaskID: 'p' } }),
        );
        expect(result).toMatchObject({ Outcome: 'permanent-failure' });
        expect(saved).toHaveLength(0);
    });
});
