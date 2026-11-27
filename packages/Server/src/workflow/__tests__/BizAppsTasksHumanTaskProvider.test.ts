import { beforeEach, describe, expect, it, vi } from 'vitest';

const STEP_ENTITY_ID = 'A0000000-0000-0000-0000-000000000001';
const REQUEST_ENTITY_ID = 'A0000000-0000-0000-0000-000000000009';
const USERS_ENTITY_ID = 'A0000000-0000-0000-0000-000000000005';
const TYPE_ID = 'D0000000-0000-0000-0000-000000000001';
const REQUEST_ID = 'F0000000-0000-0000-0000-000000000001';
const STEP_ID = 'C0000000-0000-0000-0000-000000000001';
const OWNER_ID = 'E0000000-0000-0000-0000-000000000001';

const OWNER_PERSON = 'B0000000-0000-0000-0000-000000000001';
const RUNNER_ID = 'E0000000-0000-0000-0000-000000000003';

/** Shared with the hoisted mocks: link rows already present, every saved record, every registration. */
const { db, saved, registrations } = vi.hoisted(() => ({
    db: {
        existingLinks: [] as Record<string, string | null>[],
        /** The People rows linked to the workflow's owner. */
        ownerPeople: [] as Array<{ ID: string }>,
        /** Entities whose next save is refused. */
        refuseSaveOf: null as string | null,
        /** The status an existing task loads with. */
        loadedTaskStatus: 'Open',
    },
    /** One entry per save, with what the record had vouched for at that moment. */
    saved: [] as Array<{ Entity: string; Record: Record<string, unknown>; Vouched: string[] }>,
    registrations: [] as Array<{ key: string; metadata?: Record<string, unknown> }>,
}));

vi.mock('@memberjunction/core', async (importOriginal) => ({ ...(await importOriginal<typeof import('@memberjunction/core')>()),
    LogError: vi.fn(),
    RunView: {
        FromMetadataProvider: () => ({
            RunView: async () => ({ Success: true, Results: db.existingLinks }),
            RunViews: async () => [
                { Success: true, Results: [{ ID: 'D0000000-0000-0000-0000-000000000001', IsActive: true }] },
                { Success: true, Results: db.ownerPeople },
            ],
        }),
    },
}));

vi.mock('@memberjunction/global', async (importOriginal) => ({ ...(await importOriginal<typeof import('@memberjunction/global')>()),
    EscapeSQLString: (v: string) => v.replace(/'/g, "''"),
    UUIDsEqual: (a: string | null | undefined, b: string | null | undefined) => !!a && !!b && a.toLowerCase() === b.toLowerCase(),
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
    /** As the real sanction functions: call the record's own method when it has one. */
    const sanction = (method: string) => (record: Record<string, unknown>): boolean => {
        const authorize = record[method];
        if (typeof authorize !== 'function') return false;
        authorize.call(record);
        return true;
    };
    return {
        TaskLinkEntityServer,
        TASK_LINK_ENTITY: 'MJ_BizApps_Tasks: Task Links',
        WORKFLOW_STEP_ENTITY: 'MJ: Tasks',
        AGENT_REQUEST_ENTITY: 'MJ: AI Agent Requests',
        PEOPLE_ENTITY: 'MJ_BizApps_Common: People',
        SanctionApprovalAssignment: sanction('AuthorizeApprovalAssignment'),
        SanctionApprovalWithdrawal: sanction('AuthorizeApprovalWithdrawal'),
        SanctionOnBehalfCreator: sanction('AuthorizeCreatorOnBehalf'),
    };
});

import { TaskLinkEntityServer } from '@mj-biz-apps/tasks-entities-server';
import { BizAppsTasksHumanTaskProvider, HumanAskRecord, RequesterPersonID } from '../BizAppsTasksHumanTaskProvider.js';
import type { HumanTaskRaiseContext, HumanTaskWithdrawContext } from '@memberjunction/ai-core-plus';
import type { IMetadataProvider, UserInfo } from '@memberjunction/core';

const ENTITY_IDS: Record<string, string> = {
    'MJ: Tasks': STEP_ENTITY_ID,
    'MJ: AI Agent Requests': REQUEST_ENTITY_ID,
    'MJ: Users': USERS_ENTITY_ID,
    'MJ_BizApps_Common: People': 'A0000000-0000-0000-0000-000000000006',
};

/** The one-save vouching methods of the tasks server subclasses, by entity. */
const VOUCHING: Record<string, string[]> = {
    'MJ_BizApps_Tasks: Tasks': ['AuthorizeCreatorOnBehalf', 'AuthorizeApprovalWithdrawal'],
    'MJ_BizApps_Tasks: Task Assignments': ['AuthorizeApprovalAssignment'],
};

let nextID = 0;
const provider = {
    EntityByName: (name: string) => (ENTITY_IDS[name] ? { ID: ENTITY_IDS[name] } : undefined),
    GetEntityObject: async (entity: string) => {
        const record: Record<string, unknown> =
            entity === 'MJ_BizApps_Tasks: Task Links' ? new TaskLinkEntityServer() as unknown as Record<string, unknown> : {};
        const vouched = new Set<string>();
        for (const method of VOUCHING[entity] ?? []) record[method] = () => { vouched.add(method); };
        Object.assign(record, {
            NewRecord: () => true,
            Load: async (id: string) => {
                record['ID'] = id;
                record['Status'] = db.loadedTaskStatus;
                return true;
            },
            Delete: async () => true,
            LatestResult: { CompleteMessage: 'refused by the test' },
            Save: async () => {
                // As the server subclasses: what was vouched for covers this save only.
                const covering = [...vouched];
                vouched.clear();
                if (db.refuseSaveOf === entity) return false;
                record['ID'] = record['ID'] ?? `id-${++nextID}`;
                saved.push({ Entity: entity, Record: { ...record }, Vouched: covering });
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

/** What each save of `entity` was vouched for, in order. */
function vouchedOf(entity: string): string[][] {
    return saved.filter((s) => s.Entity === entity).map((s) => s.Vouched);
}

beforeEach(() => {
    saved.length = 0;
    db.existingLinks = [];
    db.ownerPeople = [];
    db.refuseSaveOf = null;
    db.loadedTaskStatus = 'Open';
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

describe('BizAppsTasksHumanTaskProvider — the writes bizapps-tasks refuses an ordinary user (bizapps-tasks#209)', () => {
    const stepContext = (overrides: Partial<HumanTaskRaiseContext> = {}): HumanTaskRaiseContext =>
        context({
            Subject: { Kind: 'WorkflowStep', TaskID: STEP_ID, ParentTaskID: 'p' },
            ContextUser: { ID: RUNNER_ID } as UserInfo,
            ProviderConfiguration: { approverPersonIDs: ['C0000000-0000-0000-0000-000000000007'] },
            ...overrides,
        });

    it("vouches for the assignee it was configured with, also when that is the user running the agent", async () => {
        await new BizAppsTasksHumanTaskProvider().RaiseTask(context({}));
        expect(savedOf('MJ_BizApps_Tasks: Task Assignments')[0]).toMatchObject({ AssigneeRecordID: OWNER_ID });
        expect(vouchedOf('MJ_BizApps_Tasks: Task Assignments')).toEqual([['AuthorizeApprovalAssignment']]);
    });

    it("vouches for a creator who is the workflow's owner, not the user running the step", async () => {
        db.ownerPeople = [{ ID: OWNER_PERSON }];
        await new BizAppsTasksHumanTaskProvider().RaiseTask(stepContext());
        expect(savedOf('MJ_BizApps_Tasks: Tasks')[0]).toMatchObject({ CreatedByPersonID: OWNER_PERSON });
        expect(vouchedOf('MJ_BizApps_Tasks: Tasks')).toEqual([['AuthorizeCreatorOnBehalf']]);
    });

    it('names no creator when the owner has no Person, and vouches for that so the user running it is not recorded instead', async () => {
        await new BizAppsTasksHumanTaskProvider().RaiseTask(stepContext());
        expect(savedOf('MJ_BizApps_Tasks: Tasks')[0]['CreatedByPersonID']).toBeUndefined();
        expect(vouchedOf('MJ_BizApps_Tasks: Tasks')).toEqual([['AuthorizeCreatorOnBehalf']]);
    });

    it("raises an agent's question to its own user as nobody's request, so that user can answer it", async () => {
        db.ownerPeople = [{ ID: OWNER_PERSON }];
        await new BizAppsTasksHumanTaskProvider().RaiseTask(context({}));
        expect(savedOf('MJ_BizApps_Tasks: Task Assignments')[0]).toMatchObject({ AssigneeRecordID: OWNER_ID });
        expect(savedOf('MJ_BizApps_Tasks: Tasks')[0]['CreatedByPersonID']).toBeUndefined();
        expect(vouchedOf('MJ_BizApps_Tasks: Tasks')).toEqual([['AuthorizeCreatorOnBehalf']]);
    });

    it("keeps the owner as the requester of an agent's question put to someone else", async () => {
        db.ownerPeople = [{ ID: OWNER_PERSON }];
        await new BizAppsTasksHumanTaskProvider().RaiseTask(context({ AssignedUserID: 'E0000000-0000-0000-0000-000000000002' }));
        expect(savedOf('MJ_BizApps_Tasks: Tasks')[0]).toMatchObject({ CreatedByPersonID: OWNER_PERSON });
    });

    it('vouches for cancelling the task when the workflow withdraws its ask', async () => {
        db.existingLinks = [{ ID: 'l', TaskID: 'raised-task' }];
        const withdraw: HumanTaskWithdrawContext = {
            Subject: { Kind: 'WorkflowStep', TaskID: STEP_ID, ParentTaskID: 'p' },
            Reason: 'expired',
            ContextUser: { ID: RUNNER_ID } as UserInfo,
            Provider: provider,
        } as HumanTaskWithdrawContext;
        await new BizAppsTasksHumanTaskProvider().WithdrawTask(withdraw);

        expect(savedOf('MJ_BizApps_Tasks: Tasks')).toMatchObject([{ ID: 'raised-task', Status: 'Cancelled' }]);
        expect(vouchedOf('MJ_BizApps_Tasks: Tasks')).toEqual([['AuthorizeApprovalWithdrawal']]);
    });

    it('leaves a task that is already closed alone when the ask is withdrawn', async () => {
        db.existingLinks = [{ ID: 'l', TaskID: 'raised-task' }];
        db.loadedTaskStatus = 'Completed';
        await new BizAppsTasksHumanTaskProvider().WithdrawTask({
            Subject: { Kind: 'WorkflowStep', TaskID: STEP_ID, ParentTaskID: 'p' },
            Reason: 'expired',
            ContextUser: { ID: RUNNER_ID } as UserInfo,
            Provider: provider,
        } as HumanTaskWithdrawContext);
        expect(saved).toHaveLength(0);
    });

    it('vouches for withdrawing a task it could not finish raising', async () => {
        db.refuseSaveOf = 'MJ_BizApps_Tasks: Task Assignments';
        const result = await new BizAppsTasksHumanTaskProvider().RaiseTask(stepContext());
        expect(result).toMatchObject({ Outcome: 'transient-failure' });

        const tasks = savedOf('MJ_BizApps_Tasks: Tasks');
        expect(tasks.map((t) => t['Status'])).toEqual(['Open', 'Cancelled']);
        expect(vouchedOf('MJ_BizApps_Tasks: Tasks')[1]).toEqual(['AuthorizeApprovalWithdrawal']);
    });

    it('never vouches for a decision: it writes none', async () => {
        await new BizAppsTasksHumanTaskProvider().RaiseTask(stepContext());
        expect(saved.map((s) => s.Entity)).not.toContain('MJ_BizApps_Tasks: Task Decisions');
    });
});

describe('RequesterPersonID', () => {
    const agentAsk = { Subject: { Kind: 'AgentRequest' as const, AgentRequestID: REQUEST_ID, AgentRunID: null }, OwnerUserID: OWNER_ID, Provider: provider };
    const stepAsk = { Subject: { Kind: 'WorkflowStep' as const, TaskID: STEP_ID, ParentTaskID: 'p' }, OwnerUserID: OWNER_ID, Provider: provider };
    const ownerAsUser = { EntityID: USERS_ENTITY_ID, RecordID: OWNER_ID.toLowerCase() };
    const ownerAsPerson = { EntityID: 'A0000000-0000-0000-0000-000000000006', RecordID: OWNER_PERSON };
    const someoneElse = { EntityID: USERS_ENTITY_ID, RecordID: 'E0000000-0000-0000-0000-000000000002' };

    it("is nobody for an agent's question put to the owner, as a user or as their Person", () => {
        expect(RequesterPersonID(agentAsk, OWNER_PERSON, [ownerAsUser])).toBeNull();
        expect(RequesterPersonID(agentAsk, OWNER_PERSON, [someoneElse, ownerAsPerson])).toBeNull();
    });

    it("is the owner for an agent's question put to someone else", () => {
        expect(RequesterPersonID(agentAsk, OWNER_PERSON, [someoneElse])).toBe(OWNER_PERSON);
    });

    it('is always the owner for a workflow step, who is who wants the approval', () => {
        expect(RequesterPersonID(stepAsk, OWNER_PERSON, [ownerAsUser])).toBe(OWNER_PERSON);
    });

    it('is nobody when the owner has no Person', () => {
        expect(RequesterPersonID(stepAsk, null, [someoneElse])).toBeNull();
    });
});
