/**
 * Answers the ask a bizapps-tasks task was raised for, once the task is decided: a workflow step, or
 * an agent's question.
 *
 * Agent requests are answered through `AnswerAgentRequestFromProvider` (`@memberjunction/ai-agents`),
 * which saves the answer as the request's owner and resumes the agent; see {@link AgentRequestAnswerFor}
 * for how a decision maps to an answer. A task cancelled without a decision leaves the agent's
 * question open in MJ's inbox: cancelling a task is not an answer.
 *
 * A workflow step is completed — never failed — with the decision written into the workflow payload under
 * the step's `outputKey` (default `approval`), so the workflow branches on it:
 * `payload.approval.Approved == true`. A task closed without a recorded decision is not an approval:
 * only a decision, which bizapps-tasks checks against who may decide, can set `Approved`.
 *
 * Runs as the system user, because the person deciding usually cannot read workflow rows; the
 * decider is still recorded on the step. That is safe only because a task can reach a workflow step
 * solely through a link the provider made ({@link TaskLinkEntityServer}), and only for a step that
 * names this provider.
 *
 * @module @mj-biz-apps/tasks-server
 */
import { LogError, LogStatus, RunView, WellKnownUserSource, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import { EscapeSQLString, UUIDsEqual } from '@memberjunction/global';
import { ParseStepConfiguration, TaskGraphWaitingSteps } from '@memberjunction/task-graph';
import { AnswerAgentRequestFromProvider, type AgentRequestAnswerStatus } from '@memberjunction/ai-agents';
import * as tasksCore from '@mj-biz-apps/tasks-core';
import { AGENT_REQUEST_ENTITY, TASK_LINK_ENTITY, WORKFLOW_STEP_ENTITY } from '@mj-biz-apps/tasks-entities-server';
import { BIZAPPS_TASKS_PROVIDER_KEY, WorkflowOutputKey } from './workflow-task-request.js';

const TASK_DECISIONS_ENTITY = 'MJ_BizApps_Tasks: Task Decisions';
const TASK_DECISION_OUTCOMES_ENTITY = 'MJ_BizApps_Tasks: Task Decision Outcomes';
const TASKS_ENTITY = 'MJ_BizApps_Tasks: Tasks';

/** The terminal statuses that settle a workflow step. */
export type SettledTaskStatus = 'Completed' | 'Cancelled';

/** What the workflow sees under its output key. */
export type WorkflowDecisionSummary = {
    /** The decision's outcome code (`Approved`, `ApprovedWithConditions`, `Rejected`), else the task's status. */
    Outcome: string;
    /** True only for an approving decision on a task that was completed. */
    Approved: boolean;
    Notes: string | null;
    DecidedByPersonID: string | null;
    /** The bizapps-tasks task that carried the question. */
    TaskID: string;
};

/** The latest decision on a task, as the summary needs it. */
export type LatestDecision = { OutcomeCode: string | null; Notes: string | null; DecidedByPersonID: string | null };

/** Pure: the summary for a settled task. */
export function SummarizeWorkflowDecision(taskID: string, status: SettledTaskStatus, decision: LatestDecision | null): WorkflowDecisionSummary {
    const code = decision?.OutcomeCode ?? null;
    const approved = status === 'Completed' && tasksCore.IsTaskDecisionOutcomeCode(code) && tasksCore.IsApprovalOutcome(code);
    return {
        Outcome: code ?? status,
        Approved: approved,
        Notes: decision?.Notes ?? null,
        DecidedByPersonID: decision?.DecidedByPersonID ?? null,
        TaskID: taskID,
    };
}

/** True when a step's configuration names this provider — the only steps this module completes. */
export function IsBizAppsTasksStep(configuration: string | null | undefined): boolean {
    const provider = ParseStepConfiguration(configuration).human?.provider;
    return typeof provider === 'string' && provider.trim().toLowerCase() === BIZAPPS_TASKS_PROVIDER_KEY.toLowerCase();
}

/** How an agent request is answered from a settled task, or null to leave it open. */
export type AgentRequestAnswer = { Status: AgentRequestAnswerStatus; Response: string | null };

/**
 * Pure: the answer a settled task gives an agent's question. An approving decision approves, a
 * rejecting one rejects; a task completed without a decision responds with its completion notes. A task
 * cancelled without a decision is not an answer, so the question stays open in MJ's inbox.
 */
export function AgentRequestAnswerFor(summary: WorkflowDecisionSummary, status: SettledTaskStatus, completionNotes: string | null): AgentRequestAnswer | null {
    const response = summary.Notes ?? completionNotes;
    const code = summary.Outcome;
    if (!tasksCore.IsTaskDecisionOutcomeCode(code)) {
        return status === 'Cancelled' ? null : { Status: 'Responded', Response: response };
    }
    return { Status: tasksCore.IsApprovalOutcome(code) ? 'Approved' : 'Rejected', Response: response };
}

/**
 * Answers every ask linked to a settled task: completes its workflow steps and answers its agent
 * requests. Fail-soft: the task's own save has already committed, so a problem here is logged, never
 * thrown into the caller.
 */
export async function SettleHumanAsksForTask(
    taskID: string,
    status: SettledTaskStatus,
    decider: UserInfo,
    provider: IMetadataProvider,
): Promise<void> {
    const stepEntityID = provider.EntityByName(WORKFLOW_STEP_ENTITY)?.ID ?? null;
    const requestEntityID = provider.EntityByName(AGENT_REQUEST_ENTITY)?.ID ?? null;
    if (!stepEntityID && !requestEntityID) return;
    const systemUser = await WellKnownUserSource.Instance.GetSystemUser(provider);
    if (!systemUser) {
        LogError(`[BizAppsTasks] Task ${taskID} was decided, but what it was raised for cannot be answered: no system user.`);
        return;
    }
    const facts = await loadFacts(taskID, { Step: stepEntityID, Request: requestEntityID }, provider, systemUser);
    if (!facts) return;

    const summary = SummarizeWorkflowDecision(taskID, status, facts.Decision);
    if (facts.StepIDs.length > 0) await completeSteps(facts.StepIDs, summary, decider, provider, systemUser);
    const answer = AgentRequestAnswerFor(summary, status, facts.CompletionNotes);
    for (const requestID of facts.AgentRequestIDs) {
        await answerAgentRequest(requestID, answer, summary, decider, provider);
    }
}

async function completeSteps(stepIDs: string[], summary: WorkflowDecisionSummary, decider: UserInfo, provider: IMetadataProvider, systemUser: UserInfo): Promise<void> {
    const steps = await loadSteps(stepIDs, provider, systemUser);
    for (const step of steps) {
        if (!IsBizAppsTasksStep(step.Configuration)) {
            LogError(`[BizAppsTasks] Task ${summary.TaskID} is linked to workflow step ${step.ID}, which does not name the ${BIZAPPS_TASKS_PROVIDER_KEY} provider; left alone.`);
            continue;
        }
        await completeStep(step, summary, decider, provider, systemUser);
    }
}

async function answerAgentRequest(
    requestID: string,
    answer: AgentRequestAnswer | null,
    summary: WorkflowDecisionSummary,
    decider: UserInfo,
    provider: IMetadataProvider,
): Promise<void> {
    if (!answer) {
        LogStatus(`[BizAppsTasks] Task ${summary.TaskID} was cancelled without a decision; agent request ${requestID} stays open in the inbox.`);
        return;
    }
    const result = await AnswerAgentRequestFromProvider({
        AgentRequestID: requestID,
        ProviderKey: BIZAPPS_TASKS_PROVIDER_KEY,
        Status: answer.Status,
        Response: answer.Response,
        ResponseData: { outcome: summary.Outcome, taskID: summary.TaskID },
        RespondingUserID: decider.ID,
        Provider: provider,
    });
    if (!('Refusal' in result)) {
        LogStatus(`[BizAppsTasks] Agent request ${requestID} answered by task ${summary.TaskID} (${answer.Status}).`);
    } else if (result.Refusal !== 'already-answered') {
        LogError(`[BizAppsTasks] Answering agent request ${requestID} from task ${summary.TaskID} failed: ${result.Message}`);
    }
    // Already answered: someone answered in MJ first, and that answer stands.
}

type StepRow = { ID: string; Configuration: string | null };

async function completeStep(step: StepRow, summary: WorkflowDecisionSummary, decider: UserInfo, provider: IMetadataProvider, systemUser: UserInfo): Promise<void> {
    const outputKey = WorkflowOutputKey(ParseStepConfiguration(step.Configuration).human?.providerConfiguration);
    const result = await TaskGraphWaitingSteps.CompleteWaitingStep(
        { TaskID: step.ID, Status: 'Complete', Payload: { [outputKey]: summary }, CompletedByUserID: decider.ID },
        provider,
        systemUser,
    );
    if (result.Completed.length > 0 || result.Buffered.length > 0) {
        LogStatus(`[BizAppsTasks] Workflow step ${step.ID} completed by task ${summary.TaskID} (${summary.Outcome}).`);
    } else if (result.Refused.length === 0) {
        LogError(`[BizAppsTasks] Completing workflow step ${step.ID} for task ${summary.TaskID} failed: ${result.ErrorMessage ?? 'unknown error'}`);
    }
    // A refusal means the step already finished (a re-save of a settled task, or a step that expired): nothing to do.
}

/** The facts settling reads about a task. */
type TaskFacts = { StepIDs: string[]; AgentRequestIDs: string[]; Decision: LatestDecision | null; CompletionNotes: string | null };

/** The asks the task is linked to, its latest decision and its completion notes, in one round trip. */
async function loadFacts(
    taskID: string,
    askEntityIDs: { Step: string | null; Request: string | null },
    provider: IMetadataProvider,
    user: UserInfo,
): Promise<TaskFacts | null> {
    const resolverExport = Object.prototype.hasOwnProperty.call(tasksCore, 'TasksLimitsResolver')
        ? tasksCore.TasksLimitsResolver
        : undefined;
    const singleRowMax = resolverExport?.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow;
    const id = EscapeSQLString(taskID);
    const entityList = [askEntityIDs.Step, askEntityIDs.Request].filter((e): e is string => !!e).map((e) => `'${EscapeSQLString(e)}'`).join(',');
    const [links, decisions, outcomes, tasks] = await RunView.FromMetadataProvider(provider).RunViews<Record<string, string | null>>([
        { EntityName: TASK_LINK_ENTITY, ExtraFilter: `TaskID='${id}' AND EntityID IN (${entityList})`, Fields: ['ID', 'EntityID', 'RecordID'], ResultType: 'simple', BypassCache: true },
        { EntityName: TASK_DECISIONS_ENTITY, ExtraFilter: `TaskID='${id}'`, Fields: ['ID', 'OutcomeID', 'DecisionNotes', 'DecidedByPersonID'], OrderBy: 'DecidedAt DESC, __mj_CreatedAt DESC', MaxRows: singleRowMax, ResultType: 'simple', BypassCache: true },
        { EntityName: TASK_DECISION_OUTCOMES_ENTITY, Fields: ['ID', 'Code'], ResultType: 'simple' },
        { EntityName: TASKS_ENTITY, ExtraFilter: `ID='${id}'`, Fields: ['ID', 'CompletionNotes'], MaxRows: singleRowMax, ResultType: 'simple', BypassCache: true },
    ], user);
    for (const [label, res] of [['links', links], ['decisions', decisions], ['outcomes', outcomes], ['notes', tasks]] as const) {
        if (!res?.Success) {
            LogError(`[BizAppsTasks] Reading the ${label} of decided task ${taskID} failed: ${res?.ErrorMessage}`);
            return null;
        }
    }
    const linked = (entityID: string | null) =>
        (links.Results ?? []).filter((l) => !!entityID && UUIDsEqual(l['EntityID'] ?? '', entityID)).map((l) => l['RecordID']).filter((r): r is string => !!r);
    const latest = decisions.Results?.[0];
    const outcome = latest ? (outcomes.Results ?? []).find((o) => UUIDsEqual(o['ID'] ?? '', latest['OutcomeID'] ?? '')) : undefined;
    return {
        StepIDs: linked(askEntityIDs.Step),
        AgentRequestIDs: linked(askEntityIDs.Request),
        Decision: latest
            ? { OutcomeCode: outcome?.['Code'] ?? null, Notes: latest['DecisionNotes'] ?? null, DecidedByPersonID: latest['DecidedByPersonID'] ?? null }
            : null,
        CompletionNotes: tasks.Results?.[0]?.['CompletionNotes'] ?? null,
    };
}

async function loadSteps(stepIDs: string[], provider: IMetadataProvider, user: UserInfo): Promise<StepRow[]> {
    const list = stepIDs.map((s) => `'${EscapeSQLString(s)}'`).join(',');
    const res = await RunView.FromMetadataProvider(provider).RunView<StepRow>(
        { EntityName: WORKFLOW_STEP_ENTITY, ExtraFilter: `ID IN (${list})`, Fields: ['ID', 'Configuration'], ResultType: 'simple', BypassCache: true },
        user,
    );
    if (!res?.Success) {
        LogError(`[BizAppsTasks] Reading workflow steps ${list} failed: ${res?.ErrorMessage}`);
        return [];
    }
    return res.Results ?? [];
}
