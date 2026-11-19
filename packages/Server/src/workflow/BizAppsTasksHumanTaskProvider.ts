/**
 * Puts a workflow's Human step in front of people as a bizapps-tasks task.
 *
 * A Human step names it with `provider: 'BizAppsTasks'`. When the dispatcher reaches the step, this
 * raises one task — assignees, the record the decision is about, a due date — and links it to the
 * step's `MJ: Tasks` row. Deciding the task completes the step ({@link CompleteWorkflowStepsForTask}),
 * through bizapps-tasks' own rules for who may decide.
 *
 * Raising is idempotent: a step already linked to a task is not raised again, so a dispatcher that
 * retries after a dropped connection does not put the same question to people twice.
 *
 * @module @mj-biz-apps/tasks-server
 */
import { LogError, RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import { EscapeSQLString, RegisterClass } from '@memberjunction/global';
import {
    BaseHumanTaskProvider,
    type HumanTaskRaiseContext,
    type HumanTaskRaiseResult,
    type HumanTaskWithdrawContext,
} from '@memberjunction/task-graph';
import type {
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskLinkEntity,
} from '@mj-biz-apps/tasks-entities';
import { TASK_LINK_ENTITY, TaskLinkEntityServer, WORKFLOW_STEP_ENTITY, PEOPLE_ENTITY } from '@mj-biz-apps/tasks-entities-server';
import {
    BIZAPPS_TASKS_PROVIDER_KEY,
    ResolveWorkflowTaskRequest,
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
    StepEntityID: string;
    Assignees: ResolvedRef[];
    LinkedRecord: ResolvedRef | null;
    CreatorPersonID: string | null;
};

@RegisterClass(BaseHumanTaskProvider, BIZAPPS_TASKS_PROVIDER_KEY)
export class BizAppsTasksHumanTaskProvider extends BaseHumanTaskProvider {
    public async RaiseTask(ctx: HumanTaskRaiseContext): Promise<HumanTaskRaiseResult> {
        const resolved = ResolveWorkflowTaskRequest({
            Name: ctx.Name,
            Instructions: ctx.Instructions,
            DueAt: ctx.DueAt,
            AssignedUserID: ctx.AssignedUserID,
            ProviderConfiguration: ctx.ProviderConfiguration,
            Payload: ctx.Payload,
        });
        if ('Error' in resolved) return { Outcome: 'permanent-failure', Message: resolved.Error };
        try {
            const existing = await RaisedTaskIDsForStep(ctx.TaskID, ctx.Provider, ctx.ContextUser);
            if (existing.length > 0) return { Outcome: 'raised', ExternalReference: existing[0] };
            const plan = await this.plan(resolved.Request, ctx);
            if ('Error' in plan) return { Outcome: 'permanent-failure', Message: plan.Error };
            const taskID = await this.raise(plan, ctx);
            return { Outcome: 'raised', ExternalReference: taskID };
        } catch (e) {
            const message = e instanceof Error ? e.message : String(e);
            LogError(`[BizAppsTasks] Raising a task for workflow step ${ctx.TaskID} failed: ${message}`);
            return { Outcome: 'transient-failure', Message: message };
        }
    }

    /** Cancels the task the step raised, if it is still open. Its people no longer need to answer it. */
    public override async WithdrawTask(ctx: HumanTaskWithdrawContext): Promise<void> {
        const taskIDs = await RaisedTaskIDsForStep(ctx.TaskID, ctx.Provider, ctx.ContextUser);
        for (const taskID of taskIDs) {
            const task = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASKS_ENTITY, ctx.ContextUser);
            if (!(await task.Load(taskID)) || !OPEN_STATUSES.has(task.Status)) continue;
            task.Status = 'Cancelled';
            task.CompletionNotes = `Withdrawn by the workflow (${ctx.Reason}).`;
            if (!(await task.Save())) {
                LogError(`[BizAppsTasks] Withdrawing task ${taskID} for workflow step ${ctx.TaskID} failed: ${task.LatestResult?.CompleteMessage ?? 'unknown error'}`);
            }
        }
    }

    /** Resolves every name in the request to an ID, or says which one does not exist. */
    private async plan(request: WorkflowTaskRequest, ctx: HumanTaskRaiseContext): Promise<RaisePlan | { Error: string }> {
        const stepEntityID = ctx.Provider.EntityByName(WORKFLOW_STEP_ENTITY)?.ID;
        if (!stepEntityID) return { Error: `The ${WORKFLOW_STEP_ENTITY} entity is not in this host's metadata.` };
        const assignees = resolveRefs(ctx.Provider, request.Assignees);
        if ('Error' in assignees) return assignees;
        const linked = request.LinkedRecord ? resolveRefs(ctx.Provider, [request.LinkedRecord]) : { Value: [] };
        if ('Error' in linked) return linked;

        const lookups = await this.lookUpTypeAndCreator(request.TaskType, ctx);
        if ('Error' in lookups) return lookups;
        return {
            Request: request,
            TaskTypeID: lookups.TaskTypeID,
            StepEntityID: stepEntityID,
            Assignees: assignees.Value,
            LinkedRecord: linked.Value[0] ?? null,
            CreatorPersonID: lookups.CreatorPersonID,
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

    /** Writes the task, its link to the step, its record link and its assignees. Undoes them on failure. */
    private async raise(plan: RaisePlan, ctx: HumanTaskRaiseContext): Promise<string> {
        const task = await this.createTask(plan, ctx);
        let stepLink: mjBizAppsTasksTaskLinkEntity | null = null;
        try {
            stepLink = await this.createLink(task.ID, { EntityID: plan.StepEntityID, RecordID: ctx.TaskID }, ctx, true);
            if (plan.LinkedRecord) await this.createLink(task.ID, plan.LinkedRecord, ctx, false);
            for (const assignee of plan.Assignees) await this.assign(task.ID, assignee, plan.CreatorPersonID, ctx);
            return task.ID;
        } catch (e) {
            await discardPartialTask(task, stepLink);
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
        if (plan.CreatorPersonID) task.CreatedByPersonID = plan.CreatorPersonID;
        if (!(await task.Save())) throw new Error(`the task could not be created: ${task.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        return task;
    }

    private async createLink(taskID: string, ref: ResolvedRef, ctx: HumanTaskRaiseContext, isStep: boolean): Promise<mjBizAppsTasksTaskLinkEntity> {
        const link = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskLinkEntity>(TASK_LINK_ENTITY, ctx.ContextUser);
        link.NewRecord();
        link.TaskID = taskID;
        link.EntityID = ref.EntityID;
        link.RecordID = ref.RecordID;
        if (isStep) {
            if (!(link instanceof TaskLinkEntityServer)) throw new Error('the Task Links server subclass is not registered on this host.');
            link.AuthorizeWorkflowStepLink();
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
        if (!(await assignment.Save())) {
            throw new Error(`assigning ${ref.RecordID} failed: ${assignment.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }
    }
}

/** The bizapps-tasks tasks linked to one workflow step, oldest first. */
export async function RaisedTaskIDsForStep(stepTaskID: string, provider: IMetadataProvider, user: UserInfo): Promise<string[]> {
    const stepEntityID = provider.EntityByName(WORKFLOW_STEP_ENTITY)?.ID;
    if (!stepEntityID) return [];
    const res = await RunView.FromMetadataProvider(provider).RunView<{ TaskID: string }>({
        EntityName: TASK_LINK_ENTITY,
        ExtraFilter: `EntityID='${stepEntityID}' AND RecordID='${EscapeSQLString(stepTaskID)}'`,
        Fields: ['ID', 'TaskID'],
        OrderBy: '__mj_CreatedAt ASC',
        ResultType: 'simple',
        BypassCache: true,
    }, user);
    if (!res?.Success) throw new Error(`looking up the task raised for step ${stepTaskID} failed: ${res?.ErrorMessage}`);
    return (res.Results ?? []).map((r) => r.TaskID);
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
 * Undoes a half-raised task so a retry starts clean. The step link goes first: cancelling the task
 * while it is still linked would complete the step as cancelled.
 */
async function discardPartialTask(task: mjBizAppsTasksTaskEntity, stepLink: mjBizAppsTasksTaskLinkEntity | null): Promise<void> {
    try {
        if (stepLink && !(await stepLink.Delete())) {
            LogError(`[BizAppsTasks] Could not remove the step link of half-raised task ${task.ID}: ${stepLink.LatestResult?.CompleteMessage ?? 'unknown error'}`);
            return;
        }
        task.Status = 'Cancelled';
        task.CompletionNotes = 'Raising this workflow task failed part-way; it was withdrawn.';
        if (!(await task.Save())) {
            LogError(`[BizAppsTasks] Could not withdraw half-raised task ${task.ID}: ${task.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }
    } catch (e) {
        LogError(`[BizAppsTasks] Cleaning up half-raised task ${task.ID} failed: ${e instanceof Error ? e.message : String(e)}`);
    }
}

/** Anti-tree-shaking anchor, called from the server bootstrap. */
export function LoadBizAppsTasksHumanTaskProvider(): void {
    // Referencing the class keeps its @RegisterClass registration in the bundle.
    if (!BizAppsTasksHumanTaskProvider) throw new Error('BizAppsTasksHumanTaskProvider missing');
}
