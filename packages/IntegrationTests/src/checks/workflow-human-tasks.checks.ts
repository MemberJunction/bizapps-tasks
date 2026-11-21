/**
 * Workflow Human steps and agents' questions answered as BizApps Tasks tasks, end to end against a
 * live database: MJ's real task-graph dispatcher, the real `BizAppsTasks` human-task provider, the
 * real task-save handler that settles what a task was raised for, and MJ's answer path for agent
 * requests. Nothing is mocked except the agent steps around the Human step, which echo instead of
 * calling a model.
 *
 *   WH1  a step naming the provider becomes an approval task; an assignee's approval completes the
 *        step with the decision, and the workflow runs on
 *   WH2  with the install default set, a step naming no provider goes to Tasks too; a rejection
 *        completes the step with Approved: false
 *   WH3  an agent's question becomes a task; completing it answers the request from Tasks
 *   WH4  answering the question in MJ first withdraws the task
 *
 * Direct database transport only (needs `MJ_IT_LOAD_ENTITIES_SERVER=1`, so the provider and the
 * task-save handler are loaded): the dispatcher runs in this process.
 */
import { RunView, ServerOperationScopeManager, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import type { MJAIAgentRequestEntity } from '@memberjunction/core-entities';
import {
    HumanTaskProviderDefaults,
    TASK_GRAPH_RUNTIME_SECURITY_OPERATION,
    TaskNode,
    type TaskGraphSpec,
} from '@memberjunction/ai-core-plus';
import { RaiseAgentRequestThroughProvider } from '@memberjunction/ai-agents';
import {
    TaskGraphDispatcher,
    TaskGraphService,
    type ProviderFactory,
    type TaskAgentRunParams,
    type TaskAgentRunResult,
    type TaskAgentRunner,
} from '@memberjunction/task-graph';
import { SQLServerDataProvider, SQLServerProviderConfigData } from '@memberjunction/sqlserver-dataprovider';
import { UUIDsEqual } from '@memberjunction/global';
import { Assert, AssertEqual, IntegrationCheckRegistry, settle, type IntegrationCheckContext, type NamedCheck } from '@memberjunction/testing-integration/registry';
import type { mjBizAppsTasksTaskDecisionEntity, mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import { TASK_ACTIVITY_ENTITY, TASK_ASSIGNMENT_ENTITY, TASK_DECISION_ENTITY, TASK_ENTITY, TASK_LINK_ENTITY } from '../entity-names.js';
import { FindRows, PersonaUser, RequireSave } from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

const PROVIDER_KEY = 'BizAppsTasks';
const STEP_ENTITY = 'MJ: Tasks';
const REQUEST_ENTITY = 'MJ: AI Agent Requests';
const SETTLE_TIMEOUT_MS = 45_000;
const TERMINAL = new Set(['Complete', 'Failed', 'Cancelled', 'Blocked']);

/** The graphs and Tasks tasks this bundle made, unwound in teardown. */
const createdParentIDs: string[] = [];
const createdTasksTaskIDs: string[] = [];
const createdRequestIDs: string[] = [];

/** Runs the agent steps around the Human step without a model, echoing what reached it. */
class EchoAgentRunner implements TaskAgentRunner {
    public readonly EnforcesSecurityEnvelope = true;
    public async RunAgentForTask(params: TaskAgentRunParams): Promise<TaskAgentRunResult> {
        const received: Record<string, unknown> = {};
        for (const output of params.DependencyOutputs.values()) {
            if (output && typeof output === 'object' && !Array.isArray(output)) Object.assign(received, output);
        }
        return { Success: true, Output: { ranBy: 'echo', receivedKeys: Object.keys(received).sort(), received } };
    }
}

// ---------------------------------------------------------------------------
// Reading and waiting
// ---------------------------------------------------------------------------

function view(ctx: IntegrationCheckContext): RunView {
    return RunView.FromMetadataProvider(ctx.Provider as IMetadataProvider);
}

async function waitFor<T>(read: () => Promise<T>, done: (value: T) => boolean, what: string): Promise<T> {
    const deadline = Date.now() + SETTLE_TIMEOUT_MS;
    let latest = await read();
    while (Date.now() < deadline && !done(latest)) {
        await settle(250);
        latest = await read();
    }
    if (!done(latest)) Assert(false, `${what} (last saw ${JSON.stringify(latest)})`);
    return latest;
}

async function stepRow(ctx: IntegrationCheckContext, parentID: string, name: string): Promise<{ ID: string; Status: string; OutputPayload: string | null }> {
    const res = await view(ctx).RunView<{ ID: string; Name: string; Status: string; OutputPayload: string | null }>(
        { EntityName: STEP_ENTITY, ExtraFilter: `ParentID='${parentID}'`, Fields: ['ID', 'Name', 'Status', 'OutputPayload'], ResultType: 'simple', BypassCache: true },
        ctx.User,
    );
    const row = (res.Results ?? []).find((r) => r.Name === name);
    Assert(!!row, `step "${name}" not found under ${parentID}`);
    return row!;
}

async function parentStatus(ctx: IntegrationCheckContext, parentID: string): Promise<string> {
    const rows = await FindRows<{ Status: string }>(ctx, STEP_ENTITY, `ID='${parentID}'`, ['Status']);
    return rows[0]?.Status ?? '';
}

/** The Tasks task linked to an ask (a step's `MJ: Tasks` row or an agent request), once it exists. */
async function waitForLinkedTask(ctx: IntegrationCheckContext, askEntity: string, recordID: string): Promise<string> {
    const entityID = (ctx.Provider as IMetadataProvider).EntityByName(askEntity)?.ID;
    Assert(!!entityID, `${askEntity} is not in the metadata`);
    const links = await waitFor(
        () => FindRows<{ TaskID: string }>(ctx, TASK_LINK_ENTITY, `EntityID='${entityID}' AND RecordID='${recordID}'`, ['TaskID']),
        (rows) => rows.length > 0,
        `no Tasks task was raised for ${askEntity} ${recordID}`,
    );
    AssertEqual(links.length, 1, `exactly one Tasks task is raised per ask`);
    createdTasksTaskIDs.push(links[0].TaskID);
    return links[0].TaskID;
}

function parse(json: string | null | undefined): Record<string, unknown> {
    try {
        const value: unknown = JSON.parse(json ?? '{}');
        return value && typeof value === 'object' && !Array.isArray(value) ? (value as Record<string, unknown>) : {};
    } catch {
        return {};
    }
}

// ---------------------------------------------------------------------------
// The workflow side
// ---------------------------------------------------------------------------

function providerFactory(ctx: IntegrationCheckContext): ProviderFactory {
    const pool = ctx.Pool;
    if (!pool) return { CreateProvider: async () => ctx.Provider as IMetadataProvider };
    return {
        CreateProvider: async () => {
            const provider = new SQLServerDataProvider();
            await provider.Config(new SQLServerProviderConfigData(pool, ctx.Schema ?? '__mj', 0, undefined, undefined, false));
            return provider;
        },
    };
}

async function withDispatcher<T>(ctx: IntegrationCheckContext, instanceID: string, body: () => Promise<T>): Promise<T> {
    const dispatcher = new TaskGraphDispatcher(providerFactory(ctx), new EchoAgentRunner(), ctx.User as UserInfo, {
        InstanceID: instanceID,
        PollIntervalSeconds: 0.25,
        ClaimTTLSeconds: 300,
        ReconciliationIntervalSeconds: 3600,
        MaxConcurrentTasks: 5,
        RetryBackoffBaseMs: 1000,
    });
    await dispatcher.Start();
    try {
        return await body();
    } finally {
        await dispatcher.Stop();
    }
}

async function firstID(ctx: IntegrationCheckContext, entity: string): Promise<string> {
    const res = await view(ctx).RunView<{ ID: string }>({ EntityName: entity, Fields: ['ID'], ResultType: 'simple', MaxRows: 1 }, ctx.User);
    const id = res.Results?.[0]?.ID;
    Assert(!!id, `no ${entity} row to use`);
    return id!;
}

async function anyAgentName(ctx: IntegrationCheckContext): Promise<string> {
    const res = await view(ctx).RunView<{ Name: string }>({ EntityName: 'MJ: AI Agents', Fields: ['Name'], ResultType: 'simple', MaxRows: 1 }, ctx.User);
    const name = res.Results?.[0]?.Name;
    Assert(!!name, 'no AI agent to name in the graph');
    return name!;
}

async function submit(ctx: IntegrationCheckContext, spec: TaskGraphSpec): Promise<string> {
    const result = await new TaskGraphService().Submit(spec, {
        EnvironmentID: await firstID(ctx, 'MJ: Environments'),
        ConversationDetailID: null,
        ContextUser: ctx.User,
        Provider: ctx.Provider as IMetadataProvider,
    });
    Assert(result.Success && !!result.ParentTaskID, `the graph was not submitted: ${result.ErrorMessage}`);
    createdParentIDs.push(result.ParentTaskID!);
    return result.ParentTaskID!;
}

/** Before → Human → After, the Human step asking the given person through `provider` (or the default). */
function approvalGraph(label: string, agentName: string, approverPersonID: string, provider?: string): TaskGraphSpec {
    const agent = (tempId: string, name: string, dependsOn: string[]) => ({ tempId, name, description: name, kind: 'Agent' as const, configuration: { agentName }, dependsOn });
    return {
        workflowName: `tasks-it ${label} (safe to delete)`,
        reasoning: 'Integration check: a Human step answered as a BizApps Tasks approval.',
        tasks: [
            agent('before', `${label} Before`, []),
            TaskNode.Human(
                { tempId: 'review', name: `${label} Review`, description: 'Approve or reject.', dependsOn: ['before'] },
                {
                    ...(provider ? { provider } : {}),
                    instructions: `Integration check ${label}: approve or reject.`,
                    providerConfiguration: { title: `tasks-it ${label} approval (safe to delete)`, approverPersonIDs: [approverPersonID] },
                },
            ),
            agent('after', `${label} After`, ['review']),
        ],
    };
}

/** Records `outcome` on the task as the assignee, then completes the task as them. */
async function decideAsAssignee(ctx: IntegrationCheckContext, tasksTaskID: string, personID: string, outcomeName: string, notes: string): Promise<void> {
    const world = await GetOrLoadWorld(ctx);
    const outcome = world.DecisionOutcomes[outcomeName];
    Assert(!!outcome, `no "${outcomeName}" decision outcome in the world`);
    const decider = PersonaUser(ctx, personID, { canManage: true });

    const decision = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskDecisionEntity>(TASK_DECISION_ENTITY, decider);
    decision.NewRecord();
    decision.TaskID = tasksTaskID;
    decision.OutcomeID = outcome.ID;
    decision.DecidedByPersonID = personID;
    decision.DecisionNotes = notes;
    await RequireSave(decision, `${outcomeName} decision`);

    const task = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASK_ENTITY, decider);
    Assert(await task.Load(tasksTaskID), `Tasks task ${tasksTaskID} could not be loaded`);
    if (task.Status !== 'Completed') {
        task.Status = 'Completed';
        await RequireSave(task, 'complete the approval task');
    }
}

async function assertAssignedTo(ctx: IntegrationCheckContext, tasksTaskID: string, recordID: string): Promise<void> {
    const assignments = await FindRows<{ AssigneeRecordID: string }>(ctx, TASK_ASSIGNMENT_ENTITY, `TaskID='${tasksTaskID}'`, ['AssigneeRecordID']);
    Assert(assignments.some((a) => UUIDsEqual(a.AssigneeRecordID, recordID)), `the task is assigned to ${recordID} (saw ${JSON.stringify(assignments)})`);
}

/** Runs a graph whose Human step is decided in Tasks, and returns what the step recorded. */
async function runDecidedGraph(
    ctx: IntegrationCheckContext,
    label: string,
    outcomeName: string,
    provider?: string,
): Promise<{ approval: Record<string, unknown>; after: Record<string, unknown>; approverID: string; tasksTaskID: string }> {
    const world = await GetOrLoadWorld(ctx);
    const approver = world.People['sarah.connor@task-world.test'] ?? Object.values(world.People)[0];
    Assert(!!approver, 'a person to approve');
    const parentID = await submit(ctx, approvalGraph(label, await anyAgentName(ctx), approver.ID, provider));

    return withDispatcher(ctx, `tasks-it-${label.toLowerCase()}`, async () => {
        const review = await stepRow(ctx, parentID, `${label} Review`);
        const tasksTaskID = await waitForLinkedTask(ctx, STEP_ENTITY, review.ID);
        await assertAssignedTo(ctx, tasksTaskID, approver.ID);
        AssertEqual((await stepRow(ctx, parentID, `${label} Review`)).Status === 'Complete', false, 'the step waits for the decision');

        await decideAsAssignee(ctx, tasksTaskID, approver.ID, outcomeName, `${label}: decided in Tasks`);
        const status = await waitFor(() => parentStatus(ctx, parentID), (s) => TERMINAL.has(s), `the ${label} workflow did not settle`);
        AssertEqual(status, 'Complete', 'the workflow runs on past the decided step');

        const step = await stepRow(ctx, parentID, `${label} Review`);
        AssertEqual(step.Status, 'Complete', 'the Human step completes with the decision');
        const after = await stepRow(ctx, parentID, `${label} After`);
        return { approval: parse(step.OutputPayload)['approval'] as Record<string, unknown>, after: parse(after.OutputPayload), approverID: approver.ID, tasksTaskID };
    });
}

// ---------------------------------------------------------------------------
// The agent side
// ---------------------------------------------------------------------------

/** An agent request the way MJ's feedback coordinator writes one for a Chat step, raised through Tasks. */
async function raiseAgentQuestion(ctx: IntegrationCheckContext, question: string): Promise<{ request: MJAIAgentRequestEntity; tasksTaskID: string }> {
    const request = await ctx.Provider.GetEntityObject<MJAIAgentRequestEntity>(REQUEST_ENTITY, ctx.User);
    request.NewRecord();
    request.AgentID = await firstID(ctx, 'MJ: AI Agents');
    request.RequestedAt = new Date();
    request.RequestForUserID = ctx.User.ID;
    request.Status = 'Requested';
    request.Request = question;
    request.Priority = 50;
    request.HumanTaskProvider = PROVIDER_KEY;
    await RequireSave(request, 'agent request');
    createdRequestIDs.push(request.ID);

    const raised = await RaiseAgentRequestThroughProvider({
        Request: request,
        ProviderKey: PROVIDER_KEY,
        AgentName: 'tasks-it agent',
        ResponseForm: null,
        OwnerUserID: ctx.User.ID,
        ContextUser: ctx.User,
        Provider: ctx.Provider as IMetadataProvider,
    });
    AssertEqual(raised.Outcome, 'raised', `Tasks raises the question (${'Message' in raised ? raised.Message : ''})`);
    const tasksTaskID = await waitForLinkedTask(ctx, REQUEST_ENTITY, request.ID);
    return { request, tasksTaskID };
}

async function requestRow(ctx: IntegrationCheckContext, id: string): Promise<{ Status: string; Response: string | null; ResponseSource: string | null; ResponseByUserID: string | null }> {
    const rows = await FindRows<{ Status: string; Response: string | null; ResponseSource: string | null; ResponseByUserID: string | null }>(
        ctx, REQUEST_ENTITY, `ID='${id}'`, ['Status', 'Response', 'ResponseSource', 'ResponseByUserID'],
    );
    return rows[0];
}

async function tasksTaskStatus(ctx: IntegrationCheckContext, id: string): Promise<string> {
    const rows = await FindRows<{ Status: string }>(ctx, TASK_ENTITY, `ID='${id}'`, ['Status']);
    return rows[0]?.Status ?? '';
}

// ---------------------------------------------------------------------------
// Checks
// ---------------------------------------------------------------------------

const checks: NamedCheck[] = [
    {
        Id: 'workflow-human-tasks.WH1',
        Name: 'WH1 — a Human step naming BizAppsTasks is approved in Tasks; the workflow runs on with the decision',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const { approval, after, approverID, tasksTaskID } = await runDecidedGraph(ctx, 'WH1', 'Approved', PROVIDER_KEY);
            AssertEqual(approval?.['Approved'], true, 'an approving decision approves');
            AssertEqual(approval?.['Outcome'], 'Approved', 'the outcome code is recorded');
            Assert(UUIDsEqual(String(approval?.['DecidedByPersonID'] ?? ''), approverID), 'the decider is recorded');
            Assert(UUIDsEqual(String(approval?.['TaskID'] ?? ''), tasksTaskID), 'the Tasks task is recorded');
            Assert((after['receivedKeys'] as string[] | undefined)?.includes('approval') === true, 'the step after receives the decision');
        },
    },
    {
        Id: 'workflow-human-tasks.WH2',
        Name: 'WH2 — with the install default set, a step naming no provider goes to Tasks; a rejection completes it with Approved: false',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const refusal = HumanTaskProviderDefaults.Instance.Configure(PROVIDER_KEY);
            AssertEqual(refusal, null, 'BizAppsTasks is accepted as the install default');
            try {
                const { approval } = await runDecidedGraph(ctx, 'WH2', 'Rejected');
                AssertEqual(approval?.['Approved'], false, 'a rejecting decision does not approve');
                AssertEqual(approval?.['Outcome'], 'Rejected', 'the outcome code is recorded');
            } finally {
                HumanTaskProviderDefaults.Instance.Configure(null);
            }
        },
    },
    {
        Id: 'workflow-human-tasks.WH3',
        Name: "WH3 — an agent's question becomes a Tasks task; completing it answers the request from Tasks",
        RequiresMutation: true,
        Fn: async (ctx) => {
            const { request, tasksTaskID } = await raiseAgentQuestion(ctx, 'tasks-it WH3: which region should I use?');
            await assertAssignedTo(ctx, tasksTaskID, ctx.User.ID);

            const task = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASK_ENTITY, ctx.User);
            Assert(await task.Load(tasksTaskID), 'the Tasks task loads');
            task.CompletionNotes = 'Use us-east.';
            task.Status = 'Completed';
            await RequireSave(task, 'complete the question task');

            const answered = await waitFor(() => requestRow(ctx, request.ID), (r) => r?.Status !== 'Requested', 'the agent request was not answered');
            AssertEqual(answered.Status, 'Responded', 'a task completed without a decision responds');
            AssertEqual(answered.Response, 'Use us-east.', 'with the completion notes');
            AssertEqual(answered.ResponseSource, 'API', 'answered by the provider, not the inbox');
            Assert(UUIDsEqual(answered.ResponseByUserID ?? '', ctx.User.ID), 'the person who completed the task is recorded');
        },
    },
    {
        Id: 'workflow-human-tasks.WH4',
        Name: 'WH4 — answering the question in MJ first withdraws the Tasks task',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const { request, tasksTaskID } = await raiseAgentQuestion(ctx, 'tasks-it WH4: answered in MJ');
            request.Status = 'Responded';
            request.Response = 'Answered in the MJ inbox.';
            request.RespondedAt = new Date();
            request.ResponseByUserID = ctx.User.ID;
            await RequireSave(request, 'answer in MJ');

            const status = await waitFor(() => tasksTaskStatus(ctx, tasksTaskID), (s) => s === 'Cancelled', 'the Tasks task was not withdrawn');
            AssertEqual(status, 'Cancelled', 'the task is withdrawn');
            AssertEqual((await requestRow(ctx, request.ID)).Response, 'Answered in the MJ inbox.', "the withdrawal does not touch MJ's answer");
        },
    },
];

// ---------------------------------------------------------------------------
// Teardown — best effort, children first
// ---------------------------------------------------------------------------

async function deleteRows(ctx: IntegrationCheckContext, entity: string, filter: string): Promise<void> {
    const res = await view(ctx).RunView<{ Delete: () => Promise<boolean> }>({ EntityName: entity, ExtraFilter: filter, ResultType: 'entity_object', BypassCache: true }, ctx.User);
    for (const row of res.Results ?? []) {
        if (!(await row.Delete())) console.warn(`      teardown: could not delete a ${entity} row`);
    }
}

async function deleteGraph(ctx: IntegrationCheckContext, parentID: string): Promise<void> {
    const children = await FindRows<{ ID: string }>(ctx, STEP_ENTITY, `ParentID='${parentID}'`, ['ID']);
    if (children.length > 0) {
        const ids = children.map((c) => `'${c.ID}'`).join(',');
        await ServerOperationScopeManager.Instance.RunWithAuthority(
            { operationKey: TASK_GRAPH_RUNTIME_SECURITY_OPERATION, source: 'ServerEngine', allowedEntities: ['MJ: Task Dependencies'], userId: ctx.User.ID },
            () => deleteRows(ctx, 'MJ: Task Dependencies', `TaskID IN (${ids})`),
        );
        await deleteRows(ctx, REQUEST_ENTITY, `OriginatingTaskID IN (${ids})`);
    }
    await deleteRows(ctx, STEP_ENTITY, `ParentID='${parentID}'`);
    await deleteRows(ctx, STEP_ENTITY, `ID='${parentID}'`);
}

async function deleteTasksTask(ctx: IntegrationCheckContext, id: string): Promise<void> {
    for (const entity of [TASK_DECISION_ENTITY, TASK_ASSIGNMENT_ENTITY, TASK_LINK_ENTITY, TASK_ACTIVITY_ENTITY]) {
        await deleteRows(ctx, entity, `TaskID='${id}'`);
    }
    await deleteRows(ctx, TASK_ENTITY, `ID='${id}'`);
}

async function teardown(ctx: IntegrationCheckContext): Promise<void> {
    HumanTaskProviderDefaults.Instance.Configure(null);
    for (const id of createdTasksTaskIDs.splice(0)) await deleteTasksTask(ctx, id).catch((e) => console.warn(`      teardown: ${e}`));
    for (const id of createdParentIDs.splice(0)) await deleteGraph(ctx, id).catch((e) => console.warn(`      teardown: ${e}`));
    for (const id of createdRequestIDs.splice(0)) await deleteRows(ctx, REQUEST_ENTITY, `ID='${id}'`).catch((e) => console.warn(`      teardown: ${e}`));
}

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('workflow-human-tasks', { Setup: async () => {}, Teardown: teardown });

/** Marker so the module is not tree-shaken away. */
export const WorkflowHumanTaskChecks = checks;
