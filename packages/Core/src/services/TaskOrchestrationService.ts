import { CompositeKey, IMetadataProvider, IRunViewProvider, Metadata, RunView, UserInfo } from "@memberjunction/core";
import { EscapeSQLString } from "@memberjunction/global";
import { TasksLimitsResolver } from "../config/TasksLimits.js";
import type {
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskDecisionEntity,
    mjBizAppsTasksTaskDecisionOutcomeEntity,
} from "@mj-biz-apps/tasks-entities";

/** A provider that can both instantiate entities and run views. */
export type TaskOrchestrationProvider = IMetadataProvider & IRunViewProvider;

const TASKS_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_DECISION_OUTCOMES_ENTITY = 'MJ_BizApps_Tasks: Task Decision Outcomes';

/** The closed set of task statuses, derived directly from the generated Task entity. */
export type TaskStatus = mjBizAppsTasksTaskEntity['Status'];

/** The closed set of task priorities, derived directly from the generated Task entity. */
export type TaskPriority = mjBizAppsTasksTaskEntity['Priority'];

/**
 * The seeded TaskDecisionOutcome rows, and what each one MEANS.
 *
 * A runtime table rather than a bare union, because every consuming application has to answer two
 * questions a type cannot answer at runtime: "is this a code I accept?" and "does it mean approved?"
 * Accounting answered both by hand-copying these literals into its own sets. That copy compiled
 * perfectly against a widened union — TypeScript sees a narrower set as a legal subset — so adding
 * an approving outcome here would have left the accounting gate classifying it as NOT approved, on
 * the path that posts a journal entry batch to the ERP. Silent, and in the money.
 *
 * Add an outcome HERE and consumers follow: the union widens, `TaskDecisionOutcomeCodes` grows, and
 * `IsApprovalOutcome` classifies it. Nothing downstream needs editing.
 */
export const TaskDecisionOutcomes = {
    Approved:               { IsApproval: true,  Status: 'Completed' },
    ApprovedWithConditions: { IsApproval: true,  Status: 'Completed' },
    Rejected:               { IsApproval: false, Status: 'Cancelled' },
} as const satisfies Record<string, { IsApproval: boolean; Status: TaskStatus }>;

/** Stable codes for the seeded TaskDecisionOutcome rows. */
export type TaskDecisionOutcomeCode = keyof typeof TaskDecisionOutcomes;

/** Every outcome code, in declaration order — for validating caller input and building messages. */
export const TaskDecisionOutcomeCodes = Object.keys(TaskDecisionOutcomes) as readonly TaskDecisionOutcomeCode[];

/** Whether `code` is a seeded outcome code. Narrows unvalidated caller input. */
export function IsTaskDecisionOutcomeCode(code: string | null | undefined): code is TaskDecisionOutcomeCode {
    return !!code && Object.prototype.hasOwnProperty.call(TaskDecisionOutcomes, code);
}

/** Whether an outcome means "approved" — the question every approval gate downstream actually asks. */
export function IsApprovalOutcome(code: TaskDecisionOutcomeCode): boolean {
    return TaskDecisionOutcomes[code].IsApproval;
}

/**
 * Called with the unsaved task, and whatever links and assignments travel with it, just before it
 * is saved.
 *
 * It exists for SERVER code whose write the tasks server would otherwise refuse: recording a
 * creator who is not the user saving, or assigning approvers the server chose itself. Such code
 * passes the sanction functions of `@mj-biz-apps/tasks-entities-server` here, for example
 * `BeforeSave: SanctionOnBehalfCreator`, or
 * `BeforeSave: (task) => task.Assignments.Items.forEach(SanctionApprovalAssignment)`.
 * In a browser those functions do nothing and the server's rules decide, so this hook grants
 * nothing by itself.
 */
export type TaskBeforeSave = (task: mjBizAppsTasksTaskEntity) => void | Promise<void>;

export type CreateTaskParams = {
    Name: string;
    TypeID: string;
    Description?: string;
    CategoryID?: string;
    ParentID?: string;
    Priority?: TaskPriority;
    DueAt?: Date;
    /**
     * Who asked for the task. Leave it out and the server records the user saving. The server
     * refuses anyone else unless the system user is saving or server code vouched for it through
     * {@link CreateTaskParams.BeforeSave}.
     */
    CreatedByPersonID?: string;
    /** Initial status; defaults to 'Open'. */
    Status?: TaskStatus;
    /** See {@link TaskBeforeSave}. */
    BeforeSave?: TaskBeforeSave;
};

export type RecordDecisionParams = {
    TaskID: string;
    OutcomeCode: TaskDecisionOutcomeCode;
    DecidedByPersonID?: string;
    Notes?: string;
    /** When set, records a per-assignee decision for multi-approver flows. */
    TaskAssignmentID?: string;
};

export type CreateApprovalRequestParams = {
    Name: string;
    /** TaskType ID for the approval — typically the seeded "Approval Request" type. */
    TypeID: string;
    Description?: string;
    Priority?: TaskPriority;
    DueAt?: Date;
    /**
     * Who asked for the approval: the person the no-self-approval rule refuses a decision on it.
     * Leave it out and the server records the user saving. The server refuses anyone else unless
     * the system user is saving or server code vouched for it through
     * {@link CreateApprovalRequestParams.BeforeSave}.
     */
    CreatedByPersonID?: string;
    /** Source record this approval is about (polymorphic link). */
    LinkEntityID?: string;
    LinkRecordID?: string;
    /** Approvers to assign, by Person entity record ID. */
    ApproverPersonEntityID?: string;
    ApproverPersonRecordIDs?: string[];
    /** Optional TaskRole applied to each assignment. */
    RoleID?: string;
    /** See {@link TaskBeforeSave}. */
    BeforeSave?: TaskBeforeSave;
};

export type RecordDecisionResult = {
    Decision: mjBizAppsTasksTaskDecisionEntity;
    Task: mjBizAppsTasksTaskEntity;
    /** The status the task was transitioned to as a result of the decision (null if non-terminal). */
    NewStatus: TaskStatus | null;
};

/**
 * Generic orchestration verbs for the task / approval workflow substrate.
 *
 * Thin layer over the MJ entity API — every method saves through strongly-typed
 * generated entities and their `RelatedRecordCollection` companions so that
 * entity-subclass validation, atomic graph persistence, and server-side action
 * hooks fire automatically.
 *
 * Every method threads an explicit `contextUser` and optional `provider` for
 * correct multi-user and transactional isolation on the server.
 */
export class TaskOrchestrationService {

    // ---------------------------------------------------------------
    // Create
    // ---------------------------------------------------------------

    /**
     * Creates a new task and returns the saved entity.
     *
     * Pass `provider` to create and save the task on the caller's transactional provider
     * instead of the process-global provider.
     */
    async CreateTask(
        params: CreateTaskParams,
        contextUser?: UserInfo,
        provider?: IMetadataProvider,
    ): Promise<mjBizAppsTasksTaskEntity> {
        const md = provider ?? new Metadata();
        const task = await md.GetEntityObject<mjBizAppsTasksTaskEntity>(TASKS_ENTITY, contextUser);
        task.NewRecord();
        task.Name = params.Name;
        task.TypeID = params.TypeID;
        task.Status = params.Status ?? 'Open';
        if (params.Description != null) task.Description = params.Description;
        if (params.CategoryID != null) task.CategoryID = params.CategoryID;
        if (params.ParentID != null) task.ParentID = params.ParentID;
        if (params.Priority != null) task.Priority = params.Priority;
        if (params.DueAt != null) task.DueAt = params.DueAt;
        if (params.CreatedByPersonID != null) task.CreatedByPersonID = params.CreatedByPersonID;

        if (params.BeforeSave) await params.BeforeSave(task);
        if (!(await task.Save())) {
            throw new Error(`Failed to create task "${params.Name}": ${task.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }
        return task;
    }

    // ---------------------------------------------------------------
    // Transition
    // ---------------------------------------------------------------

    /**
     * Transitions a task to a new status and saves it. The entity subclass
     * applies status side-effects (StartedAt/CompletedAt) and the server save-event
     * handler fires any configured action hooks.
     *
     * An approval task is not completed this way: the server refuses `Completed` on one with no
     * approving decision standing, and `Cancelled` from someone who may not withdraw it. Use
     * {@link RecordDecision} to approve or reject.
     *
     * @throws when the save is refused, with the server's reason.
     */
    async TransitionStatus(
        taskID: string,
        newStatus: TaskStatus,
        contextUser?: UserInfo,
        provider?: IMetadataProvider,
    ): Promise<mjBizAppsTasksTaskEntity> {
        const task = await this.loadTask(taskID, contextUser, provider);
        if (task.Status === newStatus) {
            return task; // no-op; avoid a redundant save + hook fire
        }
        task.Status = newStatus;
        if (!(await task.Save())) {
            throw new Error(`Failed to transition task ${taskID} to ${newStatus}: ${task.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }
        return task;
    }

    // ---------------------------------------------------------------
    // Record decision
    // ---------------------------------------------------------------

    /**
     * Records an approve/reject decision against a task in ONE atomic `task.Save()` graph:
     * attaches a `TaskDecision` (`task.Decisions`), logs a `DecisionRecorded` activity
     * (`task.Activities`), and (for terminal outcomes) transitions the task status —
     * Approved/ApprovedWithConditions → Completed, Rejected → Cancelled.
     *
     * Because all three writes execute inside a single `EntitySavePlan` transaction,
     * a validation refusal (e.g. self-approval or closed-task guard) rejects the entire
     * unit with zero partial rows, and post-commit lifecycle hooks (`OnComplete` / `OnReject`)
     * observe the committed decision row cleanly.
     */
    async RecordDecision(
        params: RecordDecisionParams,
        contextUser?: UserInfo,
        provider?: TaskOrchestrationProvider,
    ): Promise<RecordDecisionResult> {
        const outcome = await this.resolveOutcome(params.OutcomeCode, contextUser, provider);
        const task = await this.loadTask(params.TaskID, contextUser, provider);

        const decision = await task.Decisions.Create();
        decision.OutcomeID = outcome.ID;
        if (params.DecidedByPersonID != null) decision.DecidedByPersonID = params.DecidedByPersonID;
        if (params.Notes != null) decision.DecisionNotes = params.Notes;
        if (params.TaskAssignmentID != null) decision.TaskAssignmentID = params.TaskAssignmentID;

        const activity = await task.Activities.Create();
        activity.ActivityType = 'DecisionRecorded';
        if (params.DecidedByPersonID != null) activity.PersonID = params.DecidedByPersonID;
        activity.NewValue = outcome.Code;
        activity.Description = `Decision recorded: ${outcome.Name}`;

        let newStatus: TaskStatus | null = null;
        if (outcome.IsTerminal) {
            newStatus = this.statusForOutcome(params.OutcomeCode);
            if (task.Status !== newStatus) {
                task.Status = newStatus;
            }
        }

        if (!(await task.Save())) {
            throw new Error(`Failed to record decision for task ${params.TaskID}: ${task.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }

        return { Decision: decision, Task: task, NewStatus: newStatus };
    }

    // ---------------------------------------------------------------
    // Create approval request (convenience)
    // ---------------------------------------------------------------

    /**
     * Creates an approval-request task, optionally links it to a source record (`task.Links`),
     * and assigns the named approvers (`task.Assignments`) in ONE atomic `task.Save()` graph.
     *
     * Pass `provider` so the entire graph writes on the caller's transactional provider
     * (rolling back together if any child validation or save fails).
     */
    async CreateApprovalRequest(
        params: CreateApprovalRequestParams,
        contextUser?: UserInfo,
        provider?: IMetadataProvider,
    ): Promise<mjBizAppsTasksTaskEntity> {
        const md = provider ?? new Metadata();
        const task = await md.GetEntityObject<mjBizAppsTasksTaskEntity>(TASKS_ENTITY, contextUser);
        task.NewRecord();
        task.Name = params.Name;
        task.TypeID = params.TypeID;
        task.Status = 'Open';
        task.Priority = params.Priority ?? 'High';
        if (params.Description != null) task.Description = params.Description;
        if (params.DueAt != null) task.DueAt = params.DueAt;
        if (params.CreatedByPersonID != null) task.CreatedByPersonID = params.CreatedByPersonID;

        if (params.LinkEntityID && params.LinkRecordID) {
            const link = await task.Links.Create();
            link.EntityID = params.LinkEntityID;
            link.RecordID = params.LinkRecordID;
        }

        if (params.ApproverPersonEntityID && params.ApproverPersonRecordIDs?.length) {
            for (const recordID of params.ApproverPersonRecordIDs) {
                const assignment = await task.Assignments.Create();
                assignment.AssigneeEntityID = params.ApproverPersonEntityID;
                assignment.AssigneeRecordID = recordID;
                if (params.RoleID != null) assignment.RoleID = params.RoleID;
                if (params.CreatedByPersonID != null) assignment.AssignedByPersonID = params.CreatedByPersonID;
            }
        }

        if (params.BeforeSave) await params.BeforeSave(task);
        if (!(await task.Save())) {
            throw new Error(`Failed to create approval request "${params.Name}": ${task.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }

        return task;
    }

    // ---------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------

    private async loadTask(
        taskID: string,
        contextUser?: UserInfo,
        provider?: IMetadataProvider,
    ): Promise<mjBizAppsTasksTaskEntity> {
        const md = provider ?? new Metadata();
        const task = await md.GetEntityObject<mjBizAppsTasksTaskEntity>(TASKS_ENTITY, contextUser);
        const loaded = await task.InnerLoad(new CompositeKey([{ FieldName: 'ID', Value: taskID }]));
        if (!loaded) {
            throw new Error(`Task ${taskID} not found`);
        }
        return task;
    }

    /** Maps a terminal outcome code to the task status it drives. */
    private statusForOutcome(code: TaskDecisionOutcomeCode): TaskStatus {
        return TaskDecisionOutcomes[code].Status;
    }

    private async resolveOutcome(
        code: TaskDecisionOutcomeCode,
        contextUser?: UserInfo,
        provider?: IRunViewProvider,
    ): Promise<mjBizAppsTasksTaskDecisionOutcomeEntity> {
        const rv = new RunView(provider);
        const result = await rv.RunView<mjBizAppsTasksTaskDecisionOutcomeEntity>({
            EntityName: TASK_DECISION_OUTCOMES_ENTITY,
            ExtraFilter: `Code = '${EscapeSQLString(code)}'`,
            ResultType: 'entity_object',
            MaxRows: TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow,
        }, contextUser);

        const outcome = result?.Results?.[0];
        if (!result?.Success || !outcome) {
            throw new Error(`Task decision outcome with code '${code}' not found (is the metadata seeded?)`);
        }
        return outcome;
    }
}
