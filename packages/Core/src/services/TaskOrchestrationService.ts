import { CompositeKey, LogError, Metadata, RunView, UserInfo } from "@memberjunction/core";
import type {
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskDecisionEntity,
    mjBizAppsTasksTaskDecisionOutcomeEntity,
    mjBizAppsTasksTaskLinkEntity,
} from "@mj-biz-apps/tasks-entities";
import { TaskService } from "./TaskService.js";
import { TaskAssignmentService } from "./TaskAssignmentService.js";

const TASKS_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_DECISIONS_ENTITY = 'MJ_BizApps_Tasks: Task Decisions';
const TASK_DECISION_OUTCOMES_ENTITY = 'MJ_BizApps_Tasks: Task Decision Outcomes';
const TASK_LINKS_ENTITY = 'MJ_BizApps_Tasks: Task Links';

/** The closed set of task statuses (mirrors the generated Task.Status union). */
export type TaskStatus = 'Open' | 'InProgress' | 'Blocked' | 'Completed' | 'Cancelled';

/** Stable codes for the seeded TaskDecisionOutcome rows. */
export type TaskDecisionOutcomeCode = 'Approved' | 'Rejected' | 'ApprovedWithConditions';

export type CreateTaskParams = {
    Name: string;
    TypeID: string;
    Description?: string;
    CategoryID?: string;
    ParentID?: string;
    Priority?: 'Low' | 'Medium' | 'High' | 'Critical';
    DueAt?: Date;
    CreatedByPersonID?: string;
    /** Initial status; defaults to 'Open'. */
    Status?: TaskStatus;
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
    Priority?: 'Low' | 'Medium' | 'High' | 'Critical';
    DueAt?: Date;
    CreatedByPersonID?: string;
    /** Source record this approval is about (polymorphic link). */
    LinkEntityID?: string;
    LinkRecordID?: string;
    /** Approvers to assign, by Person entity record ID. */
    ApproverPersonEntityID?: string;
    ApproverPersonRecordIDs?: string[];
    /** Optional TaskRole applied to each assignment. */
    RoleID?: string;
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
 * generated entities so that entity-subclass validation (status side-effects,
 * cycle checks) and the server-side action hooks fire automatically.
 *
 * Every method threads an explicit `contextUser` for correct multi-user isolation
 * on the server.
 */
export class TaskOrchestrationService {
    private assignmentService = new TaskAssignmentService();
    private taskService = new TaskService();

    // ---------------------------------------------------------------
    // Create
    // ---------------------------------------------------------------

    /** Creates a new task and returns the saved entity. */
    async CreateTask(params: CreateTaskParams, contextUser: UserInfo): Promise<mjBizAppsTasksTaskEntity> {
        const md = new Metadata();
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
     */
    async TransitionStatus(taskID: string, newStatus: TaskStatus, contextUser: UserInfo): Promise<mjBizAppsTasksTaskEntity> {
        const task = await this.loadTask(taskID, contextUser);
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
     * Records an approve/reject decision against a task: creates a TaskDecision
     * row, logs a DecisionRecorded activity, and (for terminal outcomes) transitions
     * the task — Approved/ApprovedWithConditions → Completed, Rejected → Cancelled.
     *
     * The status transition fires the existing server hook seam, so consumers' OnReject /
     * OnCancel / OnComplete actions run as a side-effect of recording the decision.
     */
    async RecordDecision(params: RecordDecisionParams, contextUser: UserInfo): Promise<RecordDecisionResult> {
        const outcome = await this.resolveOutcome(params.OutcomeCode, contextUser);

        const md = new Metadata();
        const decision = await md.GetEntityObject<mjBizAppsTasksTaskDecisionEntity>(TASK_DECISIONS_ENTITY, contextUser);
        decision.NewRecord();
        decision.TaskID = params.TaskID;
        decision.OutcomeID = outcome.ID;
        if (params.DecidedByPersonID != null) decision.DecidedByPersonID = params.DecidedByPersonID;
        if (params.Notes != null) decision.DecisionNotes = params.Notes;
        if (params.TaskAssignmentID != null) decision.TaskAssignmentID = params.TaskAssignmentID;

        if (!(await decision.Save())) {
            throw new Error(`Failed to record decision for task ${params.TaskID}: ${decision.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }

        await this.taskService.logActivity({
            taskID: params.TaskID,
            personID: params.DecidedByPersonID,
            activityType: 'DecisionRecorded',
            newValue: outcome.Code,
            description: `Decision recorded: ${outcome.Name}`,
        }, contextUser);

        // Only terminal outcomes drive a status transition. Interim outcomes leave the task open.
        let task: mjBizAppsTasksTaskEntity;
        let newStatus: TaskStatus | null = null;
        if (outcome.IsTerminal) {
            newStatus = this.statusForOutcome(params.OutcomeCode);
            task = await this.TransitionStatus(params.TaskID, newStatus, contextUser);
        } else {
            task = await this.loadTask(params.TaskID, contextUser);
        }

        return { Decision: decision, Task: task, NewStatus: newStatus };
    }

    // ---------------------------------------------------------------
    // Create approval request (convenience)
    // ---------------------------------------------------------------

    /**
     * Creates an approval-request task, optionally links it to a source record,
     * and assigns the named approvers. Returns the created task.
     */
    async CreateApprovalRequest(params: CreateApprovalRequestParams, contextUser: UserInfo): Promise<mjBizAppsTasksTaskEntity> {
        const task = await this.CreateTask({
            Name: params.Name,
            TypeID: params.TypeID,
            Description: params.Description,
            Priority: params.Priority ?? 'High',
            DueAt: params.DueAt,
            CreatedByPersonID: params.CreatedByPersonID,
            Status: 'Open',
        }, contextUser);

        if (params.LinkEntityID && params.LinkRecordID) {
            await this.linkSourceRecord(task.ID, params.LinkEntityID, params.LinkRecordID, contextUser);
        }

        if (params.ApproverPersonEntityID && params.ApproverPersonRecordIDs?.length) {
            for (const recordID of params.ApproverPersonRecordIDs) {
                await this.assignmentService.assignToTask({
                    taskID: task.ID,
                    assigneeEntityID: params.ApproverPersonEntityID,
                    assigneeRecordID: recordID,
                    roleID: params.RoleID,
                    assignedByPersonID: params.CreatedByPersonID,
                }, contextUser);
            }
        }

        return task;
    }

    // ---------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------

    private async loadTask(taskID: string, contextUser: UserInfo): Promise<mjBizAppsTasksTaskEntity> {
        const md = new Metadata();
        const task = await md.GetEntityObject<mjBizAppsTasksTaskEntity>(TASKS_ENTITY, contextUser);
        const loaded = await task.InnerLoad(new CompositeKey([{ FieldName: 'ID', Value: taskID }]));
        if (!loaded) {
            throw new Error(`Task ${taskID} not found`);
        }
        return task;
    }

    /** Maps a terminal outcome code to the task status it drives. */
    private statusForOutcome(code: TaskDecisionOutcomeCode): TaskStatus {
        switch (code) {
            case 'Approved':
            case 'ApprovedWithConditions':
                return 'Completed';
            case 'Rejected':
                return 'Cancelled';
        }
    }

    private async resolveOutcome(code: TaskDecisionOutcomeCode, contextUser: UserInfo): Promise<mjBizAppsTasksTaskDecisionOutcomeEntity> {
        const rv = new RunView();
        const result = await rv.RunView<mjBizAppsTasksTaskDecisionOutcomeEntity>({
            EntityName: TASK_DECISION_OUTCOMES_ENTITY,
            ExtraFilter: `Code = '${code.replace(/'/g, "''")}'`,
            ResultType: 'entity_object',
            MaxRows: 1,
        }, contextUser);

        const outcome = result?.Results?.[0];
        if (!result?.Success || !outcome) {
            throw new Error(`Task decision outcome with code '${code}' not found (is the metadata seeded?)`);
        }
        return outcome;
    }

    private async linkSourceRecord(taskID: string, entityID: string, recordID: string, contextUser: UserInfo): Promise<void> {
        const md = new Metadata();
        const link = await md.GetEntityObject<mjBizAppsTasksTaskLinkEntity>(TASK_LINKS_ENTITY, contextUser);
        link.NewRecord();
        link.TaskID = taskID;
        link.EntityID = entityID;
        link.RecordID = recordID;
        if (!(await link.Save())) {
            LogError(`Failed to link task ${taskID} to ${entityID}/${recordID}: ${link.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }
    }
}
