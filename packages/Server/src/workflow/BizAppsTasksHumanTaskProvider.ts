/**
 * Puts a human ask in front of people as a bizapps-tasks task: a workflow's Human step, or an agent's
 * question.
 *
 * A Human step names it with `provider: 'BizAppsTasks'`. It also declares `CanBeDefault`, so an install
 * that sets `humanTasks.defaultProvider: 'BizAppsTasks'` sends it every Human step that names no
 * provider and every agent's question (Chat step). Each ask becomes one task (assignees, the record
 * the decision is about, a due date) linked to the ask: the step's `MJ: Tasks` row, or the
 * `MJ: AI Agent Requests` row. Deciding the task answers the ask ({@link SettleHumanAsksForTask}),
 * through bizapps-tasks' own rules for who may decide.
 *
 * Raising is idempotent: an ask already linked to a task is not raised again, so a caller that
 * retries after a dropped connection does not put the same question to people twice.
 *
 * The provider writes as whoever runs the workflow or agent, and bizapps-tasks refuses some of those
 * writes from an ordinary user on an approval task (bizapps-tasks#209): a creator who is not the
 * user saving, an assignee the user has no right to add (themselves, say, for an agent's question
 * that goes back to whoever ran it), and a cancel by someone with no standing on the task. The
 * workflow decided each of those, so the provider vouches for each save it makes
 * (`SanctionOnBehalfCreator`, `SanctionApprovalAssignment`, `SanctionApprovalWithdrawal`). Deciding
 * the task is never vouched for: that stays with bizapps-tasks' rule for who may decide.
 *
 * @module @mj-biz-apps/tasks-server
 */
import { LogError, RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import { EscapeSQLString, RegisterClassEx, UUIDsEqual } from '@memberjunction/global';
import {
    BaseHumanTaskProvider,
    HUMAN_TASK_PROVIDER_CAN_BE_DEFAULT,
    type HumanTaskRaiseContext,
    type HumanTaskRaiseResult,
    type HumanTaskSubject,
    type HumanTaskWithdrawContext,
} from '@memberjunction/ai-core-plus';
import type {
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskLinkEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    AGENT_REQUEST_ENTITY,
    PEOPLE_ENTITY,
    SanctionApprovalAssignment,
    SanctionApprovalWithdrawal,
    SanctionOnBehalfCreator,
    TASK_LINK_ENTITY,
    TaskLinkEntityServer,
    WORKFLOW_STEP_ENTITY,
} from '@mj-biz-apps/tasks-entities-server';
import {
    BIZAPPS_TASKS_PROVIDER_KEY,
    ResolveWorkflowTaskRequest,
    WORKFLOW_ASSIGNEE_USERS_ENTITY,
    type WorkflowRecordRef,
    type WorkflowTaskRequest,
} from './workflow-task-request.js';

const TASKS_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_TYPES_ENTITY = 'MJ_BizApps_Tasks: Task Types';
const TASK_ASSIGNMENTS_ENTITY = 'MJ_BizApps_Tasks: Task Assignments';
const OPEN_STATUSES = new Set(['Open', 'InProgress', 'Blocked']);

/** A record pointer with its entity resolved to an ID. */
type ResolvedRef = { EntityID: string; RecordID: string };

/** Everything raising writes, with every name already resolved. */
type RaisePlan = {
    Request: WorkflowTaskRequest;
    TaskTypeID: string;
    /** The ask the task answers: the step's row, or the agent request's. */
    Ask: ResolvedRef;
    Assignees: ResolvedRef[];
    LinkedRecord: ResolvedRef | null;
    /** Who the task is from, or null when no Person asked (see {@link RequesterPersonID}). */
    CreatorPersonID: string | null;
};

/** The record an ask lives in: a workflow step's `MJ: Tasks` row, or an `MJ: AI Agent Requests` row. */
export function HumanAskRecord(subject: HumanTaskSubject): WorkflowRecordRef {
    return subject.Kind === 'WorkflowStep'
        ? { EntityName: WORKFLOW_STEP_ENTITY, RecordID: subject.TaskID }
        : { EntityName: AGENT_REQUEST_ENTITY, RecordID: subject.AgentRequestID };
}

/** A short description of the ask, for log lines. */
function describeAsk(subject: HumanTaskSubject): string {
    return subject.Kind === 'WorkflowStep' ? `workflow step ${subject.TaskID}` : `agent request ${subject.AgentRequestID}`;
}

@RegisterClassEx(BaseHumanTaskProvider, {
    key: BIZAPPS_TASKS_PROVIDER_KEY,
    // It handles any ask: an agent's question carries no provider configuration and still gets someone to ask.
    metadata: { [HUMAN_TASK_PROVIDER_CAN_BE_DEFAULT]: true },
})
export class BizAppsTasksHumanTaskProvider extends BaseHumanTaskProvider {
    public async RaiseTask(ctx: HumanTaskRaiseContext): Promise<HumanTaskRaiseResult> {
        const ask = HumanAskRecord(ctx.Subject);
        const resolved = ResolveWorkflowTaskRequest({
            Name: ctx.Name,
            Instructions: ctx.Instructions,
            DueAt: ctx.DueAt,
            // An agent's question with no one named (a shared inbox) goes to the user who ran the agent.
            // A workflow step never falls back to its owner: that is often who is asking for the approval.
            AssignedUserID: ctx.AssignedUserID ?? (ctx.Subject.Kind === 'AgentRequest' ? ctx.OwnerUserID : null),
            ProviderConfiguration: ctx.ProviderConfiguration,
            Payload: ctx.Payload,
        });
        if ('Error' in resolved) return { Outcome: 'permanent-failure', Message: resolved.Error };
        try {
            const existing = await RaisedTaskIDsFor(ask, ctx.Provider, ctx.ContextUser);
            if (existing.length > 0) return { Outcome: 'raised', ExternalReference: existing[0] };
            const plan = await this.plan(resolved.Request, ask, ctx);
            if ('Error' in plan) return { Outcome: 'permanent-failure', Message: plan.Error };
            const taskID = await this.raise(plan, ctx);
            return { Outcome: 'raised', ExternalReference: taskID };
        } catch (e) {
            const message = e instanceof Error ? e.message : String(e);
            LogError(`[BizAppsTasks] Raising a task for ${describeAsk(ctx.Subject)} failed: ${message}`);
            return { Outcome: 'transient-failure', Message: message };
        }
    }

    /** Cancels the task the ask raised, if it is still open. Its people no longer need to answer it. */
    public override async WithdrawTask(ctx: HumanTaskWithdrawContext): Promise<void> {
        const taskIDs = await RaisedTaskIDsFor(HumanAskRecord(ctx.Subject), ctx.Provider, ctx.ContextUser);
        for (const taskID of taskIDs) {
            const task = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASKS_ENTITY, ctx.ContextUser);
            if (!(await task.Load(taskID)) || !OPEN_STATUSES.has(task.Status)) continue;
            task.Status = 'Cancelled';
            task.CompletionNotes = withdrawalNote(ctx);
            // The workflow or agent withdraws its own ask; whoever runs it need hold nothing on the task.
            SanctionApprovalWithdrawal(task);
            if (!(await task.Save())) {
                LogError(`[BizAppsTasks] Withdrawing task ${taskID} for ${describeAsk(ctx.Subject)} failed: ${task.LatestResult?.CompleteMessage ?? 'unknown error'}`);
            }
        }
    }

    /** Resolves every name in the request to an ID, or says which one does not exist. */
    private async plan(request: WorkflowTaskRequest, askRef: WorkflowRecordRef, ctx: HumanTaskRaiseContext): Promise<RaisePlan | { Error: string }> {
        const ask = resolveRefs(ctx.Provider, [askRef]);
        if ('Error' in ask) return ask;
        const assignees = resolveRefs(ctx.Provider, request.Assignees);
        if ('Error' in assignees) return assignees;
        const linked = request.LinkedRecord ? resolveRefs(ctx.Provider, [request.LinkedRecord]) : { Value: [] };
        if ('Error' in linked) return linked;

        const lookups = await this.lookUpTypeAndCreator(request.TaskType, ctx);
        if ('Error' in lookups) return lookups;
        return {
            Request: request,
            TaskTypeID: lookups.TaskTypeID,
            Ask: ask.Value[0],
            Assignees: assignees.Value,
            LinkedRecord: linked.Value[0] ?? null,
            CreatorPersonID: RequesterPersonID(ctx, lookups.CreatorPersonID, assignees.Value),
        };
    }

    /** The task type, by Code or Name, and the workflow owner's Person — who the task is "from". */
    private async lookUpTypeAndCreator(
        taskType: string,
        ctx: HumanTaskRaiseContext,
    ): Promise<{ TaskTypeID: string; CreatorPersonID: string | null } | { Error: string }> {
        const escaped = EscapeSQLString(taskType);
        const ownerFilter = ctx.OwnerUserID ? `LinkedUserID='${EscapeSQLString(ctx.OwnerUserID)}'` : '1=0';
        const [types, people] = await RunView.FromMetadataProvider(ctx.Provider).RunViews<{ ID: string; IsActive?: boolean }>([
            { EntityName: TASK_TYPES_ENTITY, ExtraFilter: `Code='${escaped}' OR Name='${escaped}'`, Fields: ['ID', 'IsActive'], ResultType: 'simple', MaxRows: 2 },
            { EntityName: PEOPLE_ENTITY, ExtraFilter: ownerFilter, Fields: ['ID'], OrderBy: 'ID', ResultType: 'simple', MaxRows: 1 },
        ], ctx.ContextUser);
        if (!types?.Success) throw new Error(`looking up task type "${taskType}" failed: ${types?.ErrorMessage}`);
        if (!people?.Success) throw new Error(`looking up the workflow owner's Person failed: ${people?.ErrorMessage}`);
        const type = (types.Results ?? []).find((t) => t.IsActive !== false);
        if (!type) return { Error: `There is no active task type with the Code or Name "${taskType}".` };
        return { TaskTypeID: type.ID, CreatorPersonID: people.Results?.[0]?.ID ?? null };
    }

    /** Writes the task, its link to the ask, its record link and its assignees. Undoes them on failure. */
    private async raise(plan: RaisePlan, ctx: HumanTaskRaiseContext): Promise<string> {
        const task = await this.createTask(plan, ctx);
        let askLink: mjBizAppsTasksTaskLinkEntity | null = null;
        try {
            askLink = await this.createLink(task.ID, plan.Ask, ctx, true);
            if (plan.LinkedRecord) await this.createLink(task.ID, plan.LinkedRecord, ctx, false);
            for (const assignee of plan.Assignees) await this.assign(task.ID, assignee, plan.CreatorPersonID, ctx);
            return task.ID;
        } catch (e) {
            await discardPartialTask(task, askLink);
            throw e;
        }
    }

    private async createTask(plan: RaisePlan, ctx: HumanTaskRaiseContext): Promise<mjBizAppsTasksTaskEntity> {
        const task = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASKS_ENTITY, ctx.ContextUser);
        task.NewRecord();
        task.Name = plan.Request.Title;
        task.TypeID = plan.TaskTypeID;
        task.Status = 'Open';
        task.Priority = plan.Request.Priority;
        if (plan.Request.Description) task.Description = plan.Request.Description;
        if (plan.Request.DueAt) task.DueAt = plan.Request.DueAt;
        // The provider decides who the task is from: the owner, who is often not the user running this
        // step, or nobody. Vouching for it also stops the user saving being recorded in their place.
        if (plan.CreatorPersonID) task.CreatedByPersonID = plan.CreatorPersonID;
        SanctionOnBehalfCreator(task);
        if (!(await task.Save())) throw new Error(`the task could not be created: ${task.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        return task;
    }

    private async createLink(taskID: string, ref: ResolvedRef, ctx: HumanTaskRaiseContext, isAsk: boolean): Promise<mjBizAppsTasksTaskLinkEntity> {
        const link = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskLinkEntity>(TASK_LINK_ENTITY, ctx.ContextUser);
        link.NewRecord();
        link.TaskID = taskID;
        link.EntityID = ref.EntityID;
        link.RecordID = ref.RecordID;
        if (isAsk) {
            if (!(link instanceof TaskLinkEntityServer)) throw new Error('the Task Links server subclass is not registered on this host.');
            link.AuthorizeHumanAskLink();
        }
        if (!(await link.Save())) throw new Error(`linking the task failed: ${link.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        return link;
    }

    private async assign(taskID: string, ref: ResolvedRef, assignedBy: string | null, ctx: HumanTaskRaiseContext): Promise<void> {
        const assignment = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(TASK_ASSIGNMENTS_ENTITY, ctx.ContextUser);
        assignment.NewRecord();
        assignment.TaskID = taskID;
        assignment.AssigneeEntityID = ref.EntityID;
        assignment.AssigneeRecordID = ref.RecordID;
        if (assignedBy) assignment.AssignedByPersonID = assignedBy;
        // The step's configuration names the assignees; the user running it did not choose them.
        SanctionApprovalAssignment(assignment);
        if (!(await assignment.Save())) {
            throw new Error(`assigning ${ref.RecordID} failed: ${assignment.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }
    }
}

/**
 * Who a raised task is from: the owner's Person, except for an agent's question put to the owner
 * themselves, which is from nobody.
 *
 * bizapps-tasks refuses the person who asked for an approval any say on it: they may neither decide
 * it nor complete it. That is right for a workflow step, whose owner is often who wants the approval,
 * and for a question an agent puts to someone else on its owner's behalf. But when an agent asks the
 * very user who ran it, that user is the one answering, not the one asking; recorded as the requester
 * they could never answer their own agent in Tasks.
 */
export function RequesterPersonID(
    ctx: Pick<HumanTaskRaiseContext, 'Subject' | 'OwnerUserID' | 'Provider'>,
    ownerPersonID: string | null,
    assignees: ReadonlyArray<{ EntityID: string; RecordID: string }>,
): string | null {
    if (ctx.Subject.Kind !== 'AgentRequest' || !ownerPersonID) return ownerPersonID;
    const usersEntityID = ctx.Provider.EntityByName(WORKFLOW_ASSIGNEE_USERS_ENTITY)?.ID ?? null;
    const ownerIsAsked = assignees.some((a) =>
        (!!usersEntityID && !!ctx.OwnerUserID && UUIDsEqual(a.EntityID, usersEntityID) && UUIDsEqual(a.RecordID, ctx.OwnerUserID)) ||
        UUIDsEqual(a.RecordID, ownerPersonID),
    );
    return ownerIsAsked ? null : ownerPersonID;
}

/** The bizapps-tasks tasks linked to one ask (a workflow step or an agent request), oldest first. */
export async function RaisedTaskIDsFor(ask: WorkflowRecordRef, provider: IMetadataProvider, user: UserInfo): Promise<string[]> {
    const askEntityID = provider.EntityByName(ask.EntityName)?.ID;
    if (!askEntityID) return [];
    const res = await RunView.FromMetadataProvider(provider).RunView<{ TaskID: string }>({
        EntityName: TASK_LINK_ENTITY,
        ExtraFilter: `EntityID='${EscapeSQLString(askEntityID)}' AND RecordID='${EscapeSQLString(ask.RecordID)}'`,
        Fields: ['ID', 'TaskID'],
        OrderBy: '__mj_CreatedAt ASC',
        ResultType: 'simple',
        BypassCache: true,
    }, user);
    if (!res?.Success) throw new Error(`looking up the task raised for ${ask.EntityName} ${ask.RecordID} failed: ${res?.ErrorMessage}`);
    return (res.Results ?? []).map((r) => r.TaskID);
}

/** What a withdrawn task says about why. */
function withdrawalNote(ctx: HumanTaskWithdrawContext): string {
    if (ctx.Reason === 'completed-elsewhere') return 'Withdrawn: the request was answered somewhere else.';
    return ctx.Subject.Kind === 'WorkflowStep' ? `Withdrawn by the workflow (${ctx.Reason}).` : `Withdrawn by the agent (${ctx.Reason}).`;
}

function resolveRefs(provider: IMetadataProvider, refs: WorkflowRecordRef[]): { Value: ResolvedRef[] } | { Error: string } {
    const out: ResolvedRef[] = [];
    for (const ref of refs) {
        const entity = provider.EntityByName(ref.EntityName);
        if (!entity) return { Error: `There is no entity named "${ref.EntityName}".` };
        out.push({ EntityID: entity.ID, RecordID: ref.RecordID });
    }
    return { Value: out };
}

/**
 * Undoes a half-raised task so a retry starts clean. The ask link goes first: cancelling the task
 * while it is still linked would settle the ask as cancelled.
 */
async function discardPartialTask(task: mjBizAppsTasksTaskEntity, askLink: mjBizAppsTasksTaskLinkEntity | null): Promise<void> {
    try {
        if (askLink && !(await askLink.Delete())) {
            LogError(`[BizAppsTasks] Could not remove the ask link of half-raised task ${task.ID}: ${askLink.LatestResult?.CompleteMessage ?? 'unknown error'}`);
            return;
        }
        task.Status = 'Cancelled';
        task.CompletionNotes = 'Raising this task failed part-way; it was withdrawn.';
        SanctionApprovalWithdrawal(task);
        if (!(await task.Save())) {
            LogError(`[BizAppsTasks] Could not withdraw half-raised task ${task.ID}: ${task.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }
    } catch (e) {
        LogError(`[BizAppsTasks] Cleaning up half-raised task ${task.ID} failed: ${e instanceof Error ? e.message : String(e)}`);
    }
}

/** Anti-tree-shaking anchor, called from the server bootstrap. */
export function LoadBizAppsTasksHumanTaskProvider(): void {
    // Referencing the class keeps its @RegisterClassEx registration in the bundle.
    if (!BizAppsTasksHumanTaskProvider) throw new Error('BizAppsTasksHumanTaskProvider missing');
}
