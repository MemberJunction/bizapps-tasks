import { beforeEach, describe, expect, it, vi } from 'vitest';

const STEP_ENTITY_ID = 'A0000000-0000-0000-0000-000000000001';
const TASK_ID = 'B0000000-0000-0000-0000-000000000001';
const STEP_ID = 'C0000000-0000-0000-0000-000000000001';
const OTHER_STEP_ID = 'C0000000-0000-0000-0000-000000000002';
const APPROVED_ID = 'D0000000-0000-0000-0000-000000000001';
const REJECTED_ID = 'D0000000-0000-0000-0000-000000000002';
const PERSON_ID = 'E0000000-0000-0000-0000-000000000001';
const REQUEST_ENTITY_ID = 'A0000000-0000-0000-0000-000000000009';
const REQUEST_ID = 'F0000000-0000-0000-0000-000000000001';

type Row = Record<string, string | null>;
const db = {
    links: [] as Row[],
    decisions: [] as Row[],
    steps: [] as Row[],
    task: [] as Row[],
    systemUser: { ID: 'system' } as { ID: string } | null,
};

const { completeWaitingStep, answerAgentRequest } = vi.hoisted(() => ({ completeWaitingStep: vi.fn(), answerAgentRequest: vi.fn() }));

vi.mock('@memberjunction/core', () => ({
    LogError: vi.fn(),
    LogStatus: vi.fn(),
    WellKnownUserSource: { Instance: { GetSystemUser: vi.fn(async () => db.systemUser) } },
    RunView: {
        FromMetadataProvider: () => ({
            RunViews: async (params: Array<{ EntityName: string }>) => params.map((p) => viewResult(p.EntityName)),
            RunView: async (p: { EntityName: string }) => viewResult(p.EntityName),
        }),
    },
}));

vi.mock('@memberjunction/global', () => ({
    EscapeSQLString: (v: string) => v.replace(/'/g, "''"),
    UUIDsEqual: (a: string, b: string) => a.toLowerCase() === b.toLowerCase(),
}));

vi.mock('@memberjunction/task-graph', () => ({
    ParseStepConfiguration: (raw: string | null) => (raw ? JSON.parse(raw) : {}),
    TaskGraphWaitingSteps: { CompleteWaitingStep: completeWaitingStep },
}));

vi.mock('@memberjunction/ai-core-plus', () => ({ ResolveMappedInput: vi.fn() }));

vi.mock('@memberjunction/ai-agents', () => ({ AnswerAgentRequestFromProvider: answerAgentRequest }));

vi.mock('@mj-biz-apps/tasks-core', () => ({
    IsTaskDecisionOutcomeCode: (code: string | null) => code === 'Approved' || code === 'ApprovedWithConditions' || code === 'Rejected',
    IsApprovalOutcome: (code: string) => code !== 'Rejected',
}));

vi.mock('@mj-biz-apps/tasks-entities-server', () => ({
    TASK_LINK_ENTITY: 'MJ_BizApps_Tasks: Task Links',
    WORKFLOW_STEP_ENTITY: 'MJ: Tasks',
    AGENT_REQUEST_ENTITY: 'MJ: AI Agent Requests',
}));

function viewResult(entityName: string): { Success: boolean; Results: Row[] } {
    switch (entityName) {
        case 'MJ_BizApps_Tasks: Task Links': return { Success: true, Results: db.links };
        case 'MJ_BizApps_Tasks: Task Decisions': return { Success: true, Results: db.decisions };
        case 'MJ_BizApps_Tasks: Task Decision Outcomes':
            return { Success: true, Results: [{ ID: APPROVED_ID, Code: 'Approved' }, { ID: REJECTED_ID, Code: 'Rejected' }] };
        case 'MJ: Tasks': return { Success: true, Results: db.steps };
        case 'MJ_BizApps_Tasks: Tasks': return { Success: true, Results: db.task };
        default: return { Success: false, Results: [] };
    }
}

import { AgentRequestAnswerFor, SettleHumanAsksForTask, IsBizAppsTasksStep, SummarizeWorkflowDecision } from '../workflow-step-completion.js';
import type { IMetadataProvider, UserInfo } from '@memberjunction/core';

const provider = {
    EntityByName: (n: string) => (n === 'MJ: Tasks' ? { ID: STEP_ENTITY_ID } : n === 'MJ: AI Agent Requests' ? { ID: REQUEST_ENTITY_ID } : undefined),
} as unknown as IMetadataProvider;
const decider = { ID: 'decider' } as UserInfo;
const stepConfig = (providerKey: string, extra: Record<string, unknown> = {}) =>
    JSON.stringify({ human: { provider: providerKey, providerConfiguration: extra } });

beforeEach(() => {
    completeWaitingStep.mockReset();
    completeWaitingStep.mockResolvedValue({ Success: true, Completed: [STEP_ID], Buffered: [], Refused: [] });
    answerAgentRequest.mockReset();
    answerAgentRequest.mockResolvedValue({ Success: true });
    db.links = [{ ID: 'link', EntityID: STEP_ENTITY_ID, RecordID: STEP_ID }];
    db.task = [{ ID: TASK_ID, CompletionNotes: 'Done in the call' }];
    db.decisions = [{ ID: 'dec', OutcomeID: APPROVED_ID, DecisionNotes: 'Looks good', DecidedByPersonID: PERSON_ID }];
    db.steps = [{ ID: STEP_ID, Configuration: stepConfig('BizAppsTasks') }];
    db.systemUser = { ID: 'system' };
});

describe('SummarizeWorkflowDecision', () => {
    it('is approved only for an approving decision on a completed task', () => {
        const decision = { OutcomeCode: 'Approved', Notes: null, DecidedByPersonID: PERSON_ID };
        expect(SummarizeWorkflowDecision(TASK_ID, 'Completed', decision).Approved).toBe(true);
        expect(SummarizeWorkflowDecision(TASK_ID, 'Cancelled', decision).Approved).toBe(false);
        expect(SummarizeWorkflowDecision(TASK_ID, 'Cancelled', { ...decision, OutcomeCode: 'Rejected' })).toMatchObject({ Outcome: 'Rejected', Approved: false });
    });

    it('is never approved without a recorded decision, whatever the status', () => {
        expect(SummarizeWorkflowDecision(TASK_ID, 'Completed', null)).toEqual({
            Outcome: 'Completed', Approved: false, Notes: null, DecidedByPersonID: null, TaskID: TASK_ID,
        });
    });
});

describe('IsBizAppsTasksStep', () => {
    it('matches the provider key in any case and nothing else', () => {
        expect(IsBizAppsTasksStep(stepConfig('bizappstasks'))).toBe(true);
        expect(IsBizAppsTasksStep(stepConfig('SomeOtherApp'))).toBe(false);
        expect(IsBizAppsTasksStep(JSON.stringify({ human: {} }))).toBe(false);
        expect(IsBizAppsTasksStep(null)).toBe(false);
    });
});

describe('SettleHumanAsksForTask', () => {
    it('completes the linked step as the system user, recording the decider and the decision', async () => {
        await SettleHumanAsksForTask(TASK_ID, 'Completed', decider, provider);
        expect(completeWaitingStep).toHaveBeenCalledTimes(1);
        const [request, , runAs] = completeWaitingStep.mock.calls[0];
        expect(runAs).toEqual({ ID: 'system' });
        expect(request).toEqual({
            TaskID: STEP_ID,
            Status: 'Complete',
            CompletedByUserID: 'decider',
            Payload: { approval: { Outcome: 'Approved', Approved: true, Notes: 'Looks good', DecidedByPersonID: PERSON_ID, TaskID: TASK_ID } },
        });
    });

    it("writes under the step's outputKey", async () => {
        db.steps = [{ ID: STEP_ID, Configuration: stepConfig('BizAppsTasks', { outputKey: 'legal' }) }];
        await SettleHumanAsksForTask(TASK_ID, 'Completed', decider, provider);
        expect(Object.keys(completeWaitingStep.mock.calls[0][0].Payload)).toEqual(['legal']);
    });

    it('records a rejection as a completed step that is not approved', async () => {
        db.decisions = [{ ID: 'dec', OutcomeID: REJECTED_ID, DecisionNotes: 'Too long', DecidedByPersonID: PERSON_ID }];
        await SettleHumanAsksForTask(TASK_ID, 'Cancelled', decider, provider);
        expect(completeWaitingStep.mock.calls[0][0]).toMatchObject({ Status: 'Complete', Payload: { approval: { Outcome: 'Rejected', Approved: false } } });
    });

    it('leaves alone a linked step that names another provider', async () => {
        db.links = [{ ID: 'a', EntityID: STEP_ENTITY_ID, RecordID: STEP_ID }, { ID: 'b', EntityID: STEP_ENTITY_ID, RecordID: OTHER_STEP_ID }];
        db.steps = [{ ID: STEP_ID, Configuration: stepConfig('BizAppsTasks') }, { ID: OTHER_STEP_ID, Configuration: stepConfig('AgentRequest') }];
        await SettleHumanAsksForTask(TASK_ID, 'Completed', decider, provider);
        expect(completeWaitingStep.mock.calls.map((c) => c[0].TaskID)).toEqual([STEP_ID]);
    });

    it('does nothing for a task with no workflow step, or with no system user', async () => {
        db.links = [];
        await SettleHumanAsksForTask(TASK_ID, 'Completed', decider, provider);
        db.links = [{ ID: 'link', EntityID: STEP_ENTITY_ID, RecordID: STEP_ID }];
        db.systemUser = null;
        await SettleHumanAsksForTask(TASK_ID, 'Completed', decider, provider);
        expect(completeWaitingStep).not.toHaveBeenCalled();
    });
});

describe('AgentRequestAnswerFor', () => {
    const summary = (outcome: string, notes: string | null = null) => ({ Outcome: outcome, Approved: false, Notes: notes, DecidedByPersonID: null, TaskID: TASK_ID });

    it('approves on an approving decision and rejects on a rejecting one, answering with the decision notes', () => {
        expect(AgentRequestAnswerFor(summary('Approved', 'Yes'), 'Completed', 'notes')).toEqual({ Status: 'Approved', Response: 'Yes' });
        expect(AgentRequestAnswerFor(summary('ApprovedWithConditions'), 'Completed', null)).toEqual({ Status: 'Approved', Response: null });
        expect(AgentRequestAnswerFor(summary('Rejected', 'No'), 'Cancelled', null)).toEqual({ Status: 'Rejected', Response: 'No' });
    });

    it('responds with the completion notes when the task was completed without a decision', () => {
        expect(AgentRequestAnswerFor(summary('Completed'), 'Completed', 'Use the EU region')).toEqual({ Status: 'Responded', Response: 'Use the EU region' });
    });

    it('leaves the question open when the task was cancelled without a decision', () => {
        expect(AgentRequestAnswerFor(summary('Cancelled'), 'Cancelled', 'n/a')).toBeNull();
    });
});

describe('SettleHumanAsksForTask — agent requests', () => {
    beforeEach(() => {
        db.links = [{ ID: 'link', EntityID: REQUEST_ENTITY_ID, RecordID: REQUEST_ID }];
    });

    it('answers the linked agent request through MJ, as this provider, naming the decider', async () => {
        await SettleHumanAsksForTask(TASK_ID, 'Completed', decider, provider);
        expect(completeWaitingStep).not.toHaveBeenCalled();
        expect(answerAgentRequest).toHaveBeenCalledWith({
            AgentRequestID: REQUEST_ID,
            ProviderKey: 'BizAppsTasks',
            Status: 'Approved',
            Response: 'Looks good',
            ResponseData: { outcome: 'Approved', taskID: TASK_ID },
            RespondingUserID: 'decider',
            Provider: provider,
        });
    });

    it('answers with the completion notes when no decision was recorded', async () => {
        db.decisions = [];
        await SettleHumanAsksForTask(TASK_ID, 'Completed', decider, provider);
        expect(answerAgentRequest.mock.calls[0][0]).toMatchObject({ Status: 'Responded', Response: 'Done in the call' });
    });

    it('does not answer when the task was cancelled without a decision', async () => {
        db.decisions = [];
        await SettleHumanAsksForTask(TASK_ID, 'Cancelled', decider, provider);
        expect(answerAgentRequest).not.toHaveBeenCalled();
    });

    it('settles a step and an agent request linked to the same task', async () => {
        db.links = [
            { ID: 'a', EntityID: STEP_ENTITY_ID, RecordID: STEP_ID },
            { ID: 'b', EntityID: REQUEST_ENTITY_ID, RecordID: REQUEST_ID },
        ];
        await SettleHumanAsksForTask(TASK_ID, 'Completed', decider, provider);
        expect(completeWaitingStep).toHaveBeenCalledTimes(1);
        expect(answerAgentRequest).toHaveBeenCalledTimes(1);
    });
});
