import { CompositeKey, LogError, Metadata, RunView, UserInfo } from "@memberjunction/core";
import type {
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskDecisionEntity,
    mjBizAppsTasksTaskDecisionOutcomeEntity,
    mjBizAppsTasksTaskLinkEntity,
    mjBizAppsTasksTaskAssignmentEntity,
} from "@mj-biz-apps/tasks-entities";
import { TaskService } from "./TaskService.js";
import { TaskAssignmentService } from "./TaskAssignmentService.js";

const TASKS_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_DECISIONS_ENTITY = 'MJ_BizApps_Tasks: Task Decisions';
const TASK_DECISION_OUTCOMES_ENTITY = 'MJ_BizApps_Tasks: Task Decision Outcomes';
const TASK_LINKS_ENTITY = 'MJ_BizApps_Tasks: Task Links';
const TASK_ASSIGNMENTS_ENTITY = 'MJ_BizApps_Tasks: Task Assignments';

/** The TaskAssignment.Status values that mean the assignment is still actionable (can decide). */
const ACTIVE_ASSIGNMENT_STATUSES: ReadonlySet<string> = new Set(['Pending', 'InProgress']);

/**
 * Case-insensitive UUID equality. SQL Server returns UUIDs uppercase and PostgreSQL lowercase,
 * so identity comparisons across the decider Person, the linked-user record, and the assignment's
 * assignee must normalize case rather than use `===`.
 */
function uuidEquals(a: string | null | undefined, b: string | null | undefined): boolean {
    return !!a && !!b && a.trim().toLowerCase() === b.trim().toLowerCase();
}

/**
 * Normalizes a user's linked-identity field to a trimmed string. `UserInfo.LinkedEntityID` /
 * `LinkedEntityRecordID` are typed `number` in the generated interface but carry GUID strings at
 * runtime — coerce (never cast to `any`) and treat null/undefined as absent.
 */
function idToString(value: string | number | null | undefined): string {
    return value == null ? '' : String(value).trim();
}

/** The closed set of task statuses (mirrors the generated Task.Status union). */
export type TaskStatus = 'Open' | 'InProgress' | 'Blocked' | 'Completed' | 'Cancelled';

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
    /**
     * @deprecated Client-supplied identity is NOT trusted and no longer determines who is
     * recorded as the decider — `RecordDecision` always stamps the decision from the
     * authenticated caller's linked Person. If supplied, it is asserted to equal the resolved
     * caller's Person (a mismatch throws, to surface a forged-identity attempt); otherwise it is
     * ignored. New callers should omit it.
     */
    DecidedByPersonID?: string;
    Notes?: string;
    /**
     * When set, records a per-assignee decision for multi-approver flows. It is validated
     * against the caller's own active assignments on the task — a value that does not belong to
     * the caller is rejected.
     */
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
    async CreateTask(params: CreateTaskParams, contextUser?: UserInfo): Promise<mjBizAppsTasksTaskEntity> {
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
    async TransitionStatus(taskID: string, newStatus: TaskStatus, contextUser?: UserInfo): Promise<mjBizAppsTasksTaskEntity> {
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
     *
     * Security (non-repudiation): the decider is derived from the authenticated caller's linked
     * Person, never from client-supplied `DecidedByPersonID`, and the caller must hold an ACTIVE
     * assignment on the task. This prevents any user who can write a TaskDecision from approving
     * an arbitrary task and attributing it to another Person. See `assertCallerIsActiveApprover`.
     *
     * NOTE (defense in depth): this identity + assignment enforcement lives in the service so it
     * holds on every call path, but the browser calls this service directly with no server
     * boundary in between, so a determined client could still call the underlying entity API.
     * This decision path should be moved behind a server-side Action / GraphQL resolver
     * (`ResolverBase` with a per-request `contextUser`) that is the ONLY writer of TaskDecision +
     * the terminal Task transition, with entity permissions denying direct TaskDecision create to
     * ordinary users. The checks below are written to run unchanged there.
     */
    async RecordDecision(params: RecordDecisionParams, contextUser?: UserInfo): Promise<RecordDecisionResult> {
        const outcome = await this.resolveOutcome(params.OutcomeCode, contextUser);

        // Derive the decider from the authenticated caller — client input is not trusted.
        const caller = this.resolveCaller(contextUser);
        const callerPersonID = this.resolveCallerPersonID(caller);

        // A client-supplied decider that disagrees with the caller is a forgery attempt — reject it.
        if (params.DecidedByPersonID != null && !uuidEquals(params.DecidedByPersonID, callerPersonID)) {
            throw new Error(
                `Refusing to record a decision under another identity: supplied DecidedByPersonID does not match the authenticated user.`,
            );
        }

        // Enforce the assignee gate: only an active approver assigned to THIS task may decide it.
        const assignment = await this.assertCallerIsActiveApprover(params.TaskID, caller, callerPersonID, params.TaskAssignmentID, contextUser);

        const md = new Metadata();
        const decision = await md.GetEntityObject<mjBizAppsTasksTaskDecisionEntity>(TASK_DECISIONS_ENTITY, contextUser);
        decision.NewRecord();
        decision.TaskID = params.TaskID;
        decision.OutcomeID = outcome.ID;
        decision.DecidedByPersonID = callerPersonID; // server-derived identity, never client input
        if (params.Notes != null) decision.DecisionNotes = params.Notes;
        decision.TaskAssignmentID = assignment.ID;   // the caller's own validated assignment

        if (!(await decision.Save())) {
            throw new Error(`Failed to record decision for task ${params.TaskID}: ${decision.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }

        await this.taskService.logActivity({
            taskID: params.TaskID,
            personID: callerPersonID,
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
    async CreateApprovalRequest(params: CreateApprovalRequestParams, contextUser?: UserInfo): Promise<mjBizAppsTasksTaskEntity> {
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

    /**
     * Resolves the authenticated caller. Prefers the server-supplied `contextUser`; falls back to
     * the provider's `CurrentUser` on the client. Throws when neither is available — a decision may
     * never be recorded without an identity.
     */
    private resolveCaller(contextUser?: UserInfo): UserInfo {
        const caller = contextUser ?? new Metadata().CurrentUser;
        if (!caller) {
            throw new Error('Cannot record a task decision: no authenticated user in context.');
        }
        return caller;
    }

    /**
     * The caller's linked Person record ID — the identity actually stamped on the decision. A user
     * that is not linked to a Person cannot be an approver, so this throws rather than guessing.
     */
    private resolveCallerPersonID(caller: UserInfo): string {
        const personID = idToString(caller.LinkedEntityRecordID);
        if (!personID) {
            throw new Error(
                `Cannot record a task decision: user '${caller.Email ?? caller.ID}' is not linked to a Person record.`,
            );
        }
        return personID;
    }

    /**
     * Assignee gate. Loads the task's assignments and asserts the caller holds one that is (a) still
     * active and (b) points at the caller's own linked Person (matching BOTH the assignee entity and
     * record, so an Agent assignment that happens to share a record id cannot satisfy it). Returns
     * the matched assignment so the decision can be bound to it. Throws otherwise — this is the check
     * that stops a non-approver from recording, or forging, a decision.
     */
    private async assertCallerIsActiveApprover(
        taskID: string,
        caller: UserInfo,
        callerPersonID: string,
        requestedAssignmentID: string | undefined,
        contextUser?: UserInfo,
    ): Promise<mjBizAppsTasksTaskAssignmentEntity> {
        const rv = new RunView();
        const result = await rv.RunView<mjBizAppsTasksTaskAssignmentEntity>({
            EntityName: TASK_ASSIGNMENTS_ENTITY,
            ExtraFilter: `TaskID = '${taskID.replace(/'/g, "''")}'`,
            ResultType: 'entity_object',
        }, contextUser);

        if (!result?.Success) {
            throw new Error(`Failed to load assignments for task ${taskID}: ${result?.ErrorMessage ?? 'unknown error'}`);
        }

        const callerEntityID = idToString(caller.LinkedEntityID);
        const callerAssignments = (result.Results ?? []).filter(a =>
            ACTIVE_ASSIGNMENT_STATUSES.has(a.Status) &&
            uuidEquals(a.AssigneeEntityID, callerEntityID) &&
            uuidEquals(a.AssigneeRecordID, callerPersonID),
        );

        if (callerAssignments.length === 0) {
            throw new Error(`User is not an active approver on task ${taskID}; cannot record a decision.`);
        }

        // For multi-approver flows, honor a requested assignment only if it is one of the caller's own.
        if (requestedAssignmentID != null) {
            const chosen = callerAssignments.find(a => uuidEquals(a.ID, requestedAssignmentID));
            if (!chosen) {
                throw new Error(`TaskAssignment ${requestedAssignmentID} does not belong to the authenticated user for task ${taskID}.`);
            }
            return chosen;
        }
        return callerAssignments[0];
    }

    private async loadTask(taskID: string, contextUser?: UserInfo): Promise<mjBizAppsTasksTaskEntity> {
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
        // Read from the outcome table rather than re-deciding here. As a switch this silently
        // returned undefined for any outcome added later — the union widened, no case matched, and
        // the task was saved with no status at all.
        return TaskDecisionOutcomes[code].Status;
    }

    private async resolveOutcome(code: TaskDecisionOutcomeCode, contextUser?: UserInfo): Promise<mjBizAppsTasksTaskDecisionOutcomeEntity> {
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

    private async linkSourceRecord(taskID: string, entityID: string, recordID: string, contextUser?: UserInfo): Promise<void> {
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
