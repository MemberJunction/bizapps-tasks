/**
 * Completes the workflow step a bizapps-tasks task was raised for, once the task is decided.
 *
 * The step is completed — never failed — with the decision written into the workflow payload under
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
import { IsApprovalOutcome, IsTaskDecisionOutcomeCode } from '@mj-biz-apps/tasks-core';
import { TASK_LINK_ENTITY, WORKFLOW_STEP_ENTITY } from '@mj-biz-apps/tasks-entities-server';
import { BIZAPPS_TASKS_PROVIDER_KEY, WorkflowOutputKey } from './workflow-task-request.js';

const TASK_DECISIONS_ENTITY = 'MJ_BizApps_Tasks: Task Decisions';
const TASK_DECISION_OUTCOMES_ENTITY = 'MJ_BizApps_Tasks: Task Decision Outcomes';

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
    const approved = status === 'Completed' && IsTaskDecisionOutcomeCode(code) && IsApprovalOutcome(code);
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

/**
 * Completes every workflow step linked to a settled task. Fail-soft: the task's own save has already
 * committed, so a problem here is logged, never thrown into the caller.
 */
export async function CompleteWorkflowStepsForTask(
    taskID: string,
    status: SettledTaskStatus,
    decider: UserInfo,
    provider: IMetadataProvider,
): Promise<void> {
    const stepEntityID = provider.EntityByName(WORKFLOW_STEP_ENTITY)?.ID;
    if (!stepEntityID) return;
    const systemUser = await WellKnownUserSource.Instance.GetSystemUser(provider);
    if (!systemUser) {
        LogError(`[BizAppsTasks] Task ${taskID} was decided, but its workflow step cannot be completed: no system user.`);
        return;
    }
    const facts = await loadFacts(taskID, stepEntityID, provider, systemUser);
    if (!facts || facts.StepIDs.length === 0) return;

    const summary = SummarizeWorkflowDecision(taskID, status, facts.Decision);
    const steps = await loadSteps(facts.StepIDs, provider, systemUser);
    for (const step of steps) {
        if (!IsBizAppsTasksStep(step.Configuration)) {
            LogError(`[BizAppsTasks] Task ${taskID} is linked to workflow step ${step.ID}, which does not name the ${BIZAPPS_TASKS_PROVIDER_KEY} provider; left alone.`);
            continue;
        }
        await completeStep(step, summary, decider, provider, systemUser);
    }
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

/** The steps the task is linked to, and its latest decision, in one round trip. */
async function loadFacts(
    taskID: string,
    stepEntityID: string,
    provider: IMetadataProvider,
    user: UserInfo,
): Promise<{ StepIDs: string[]; Decision: LatestDecision | null } | null> {
    const id = EscapeSQLString(taskID);
    const [links, decisions, outcomes] = await RunView.FromMetadataProvider(provider).RunViews<Record<string, string | null>>([
        { EntityName: TASK_LINK_ENTITY, ExtraFilter: `TaskID='${id}' AND EntityID='${stepEntityID}'`, Fields: ['ID', 'RecordID'], ResultType: 'simple', BypassCache: true },
        { EntityName: TASK_DECISIONS_ENTITY, ExtraFilter: `TaskID='${id}'`, Fields: ['ID', 'OutcomeID', 'DecisionNotes', 'DecidedByPersonID'], OrderBy: 'DecidedAt DESC, __mj_CreatedAt DESC', MaxRows: 1, ResultType: 'simple', BypassCache: true },
        { EntityName: TASK_DECISION_OUTCOMES_ENTITY, Fields: ['ID', 'Code'], ResultType: 'simple' },
    ], user);
    for (const [label, res] of [['links', links], ['decisions', decisions], ['outcomes', outcomes]] as const) {
        if (!res?.Success) {
            LogError(`[BizAppsTasks] Reading the ${label} of decided task ${taskID} failed: ${res?.ErrorMessage}`);
            return null;
        }
    }
    const stepIDs = (links.Results ?? []).map((l) => l['RecordID']).filter((r): r is string => !!r);
    const latest = decisions.Results?.[0];
    const outcome = latest ? (outcomes.Results ?? []).find((o) => UUIDsEqual(o['ID'] ?? '', latest['OutcomeID'] ?? '')) : undefined;
    return {
        StepIDs: stepIDs,
        Decision: latest
            ? { OutcomeCode: outcome?.['Code'] ?? null, Notes: latest['DecisionNotes'] ?? null, DecidedByPersonID: latest['DecidedByPersonID'] ?? null }
            : null,
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
