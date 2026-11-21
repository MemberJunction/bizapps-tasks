import { BaseRemotableOperation } from '@memberjunction/core';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';

/**
 * Stable registry key for server-side bulk task mutations (reassign, redate/shift,
 * status, priority, organization, category, workflow stage, tag).
 */
export const TASKS_BULK_UPDATE_OP_KEY = 'BizAppsTasks.BulkUpdateTasks';

/**
 * Stable registry key for server-side Playbook / TaskTemplate instantiation
 * (hydrates tasks, parent/child WBS, dependencies, role assignments, and target Organization).
 */
export const TASKS_INSTANTIATE_TEMPLATE_OP_KEY = 'BizAppsTasks.InstantiateTemplate';

/**
 * Stable registry key for scheduled / recurring multi-entity Playbook launches
 * (e.g., Month-End / Quarter-End Financial Close rollovers across mirrored Companies).
 */
export const TASKS_RUN_RECURRING_PLAYBOOKS_OP_KEY = 'BizAppsTasks.RunRecurringPlaybooks';

export type TaskBulkStatus = mjBizAppsTasksTaskEntity['Status'];
export type TaskBulkPriority = mjBizAppsTasksTaskEntity['Priority'];

export type TaskBulkDateMode = 'unchanged' | 'set' | 'shift' | 'clear';
export type TaskBulkStartDateMode = 'unchanged' | 'set' | 'clear';
export type TaskBulkAssigneeMode = 'unchanged' | 'replace' | 'add' | 'clear';
export type TaskBulkNullableRefMode = 'unchanged' | 'set' | 'clear';

export interface TasksBulkUpdateInput {
    /** Task primary keys (UUIDs) to update (1–500 unique IDs per invocation). */
    TaskIDs: string[];

    /** Update macro status when provided. */
    Status?: TaskBulkStatus | null;
    /** Update priority when provided. */
    Priority?: TaskBulkPriority | null;

    /** Due-date action: leave unchanged, set exact ISO date, shift existing dates by ±ShiftDays, or clear. */
    DueDateMode?: TaskBulkDateMode;
    /** Target ISO date (`YYYY-MM-DD` or full ISO string) when `DueDateMode === 'set'`. */
    DueAt?: string | null;
    /** Signed integer days to shift `DueAt` (and `StartedAt` when present) when `DueDateMode === 'shift'`. */
    ShiftDays?: number | null;

    /** Start-date action: leave unchanged, set exact ISO date, or clear. */
    StartDateMode?: TaskBulkStartDateMode;
    /** Target ISO date (`YYYY-MM-DD` or full ISO string) when `StartDateMode === 'set'`. */
    StartedAt?: string | null;

    /** Assignee action: leave unchanged, replace existing assignees, add an assignee, or clear all assignees. */
    AssigneeMode?: TaskBulkAssigneeMode;
    /** Entity name of the assignee (e.g. `'MJ_BizApps_Common: People'`, `'MJ: Roles'`, `'MJ_BizApps_Common: Organizations'`). */
    AssigneeEntityName?: string | null;
    /** Primary key of the assignee record when `AssigneeMode` is `'replace'` or `'add'`. */
    AssigneeRecordID?: string | null;
    /** Optional `MJ_BizApps_Tasks: Task Roles` ID (defaults to `Primary` when omitted). */
    AssigneeRoleID?: string | null;

    /** Organization scoping action: leave unchanged, set `OrganizationID`, or clear to NULL. */
    OrganizationMode?: TaskBulkNullableRefMode;
    /** Target `MJ_BizApps_Common: Organizations.ID` when `OrganizationMode === 'set'`. */
    OrganizationID?: string | null;

    /** Category scoping action: leave unchanged, set `CategoryID`, or clear to NULL. */
    CategoryMode?: TaskBulkNullableRefMode;
    /** Target `MJ_BizApps_Tasks: Task Categories.ID` when `CategoryMode === 'set'`. */
    CategoryID?: string | null;

    /** Optional `MJ_BizApps_Tasks: Task Types.ID` to apply across all selected tasks. */
    TypeID?: string | null;
    /** Optional `MJ_BizApps_Tasks: Task Type Status.ID` to apply across all selected tasks. */
    TaskTypeStatusID?: string | null;
    /** Optional `MJ_BizApps_Tasks: Task Tags.ID` to attach idempotently to all selected tasks. */
    AddTagID?: string | null;
}

/** Per-task failure detail emitted when a task cannot be loaded or saved during a bulk update. */
export interface TasksBulkUpdateFailure {
    /** Primary key of the task that failed. */
    TaskID: string;
    /** Human-readable server error message for this task. */
    Error: string;
}

/** Aggregate result summary returned by `BizAppsTasks.BulkUpdateTasks`. */
export interface TasksBulkUpdateOutput {
    /** Number of unique task IDs requested after deduplication. */
    TotalRequested: number;
    /** Number of tasks updated successfully. */
    UpdatedCount: number;
    /** Number of tasks that encountered an error. */
    FailedCount: number;
    /** Primary keys of every task updated successfully. */
    UpdatedTaskIDs: string[];
    /** Granular per-task failure details for any partial failures. */
    Failures: TasksBulkUpdateFailure[];
}

/**
 * Typed Remotable Operation shell for Asana-grade bulk task updates —
 * callable identically from browser (`GraphQLDataProvider`) or server (`DatabaseProviderBase`):
 *
 * ```ts
 * const res = await new TasksBulkUpdateOperation().Execute({
 *   TaskIDs: selectedIds,
 *   Status: 'InProgress',
 *   DueDateMode: 'shift',
 *   ShiftDays: 2,
 * });
 * ```
 */
export class TasksBulkUpdateOperation extends BaseRemotableOperation<
    TasksBulkUpdateInput,
    TasksBulkUpdateOutput
> {
    public readonly OperationKey = TASKS_BULK_UPDATE_OP_KEY;
    public readonly AuthorizedWriteEntities = [
        'MJ_BizApps_Tasks: Tasks',
        'MJ_BizApps_Tasks: Task Assignments',
        'MJ_BizApps_Tasks: Task Tag Links',
    ] as const;
    public readonly ExposeAsAgentTool = true;
    public readonly ExposeAsMCPTool = true;
    public readonly ToolDescription =
        'Bulk update multiple tasks server-side (reassign, redate/shift dates, status, priority, organization, category, task type/stage, or tag).';
}

export interface TemplateRoleAssignmentInput {
    /** `MJ_BizApps_Tasks: Task Roles.ID` placeholder from the template. */
    RoleID: string;
    /** Target assignee entity name (`'MJ_BizApps_Common: People'`, `'MJ: Roles'`, or `'MJ_BizApps_Common: Organizations'`). */
    EntityName: string;
    /** Target assignee record primary key. */
    RecordID: string;
}

export interface TasksInstantiateTemplateInput {
    /** `MJ_BizApps_Tasks: Task Templates.ID` to instantiate. */
    TemplateID: string;
    /** Kickoff anchor date (`YYYY-MM-DD` or ISO timestamp) for relative `DaysFromStart` offsets. */
    StartDate: string;
    /** Optional category override (falls back to template default). */
    CategoryID?: string | null;
    /** Optional organization/company scope override (falls back to template default). */
    OrganizationID?: string | null;
    /** Role placeholder mappings to concrete People, MJ Roles, or Organizations. */
    RoleAssignments?: TemplateRoleAssignmentInput[];
}

export interface TasksInstantiateTemplateOutput {
    TemplateID: string;
    CreatedCount: number;
    CreatedTaskIDs: string[];
    OrganizationID: string | null;
}

/**
 * Typed Remotable Operation shell for server-side Task Template (Playbook) instantiation.
 */
export class TasksInstantiateTemplateOperation extends BaseRemotableOperation<
    TasksInstantiateTemplateInput,
    TasksInstantiateTemplateOutput
> {
    public readonly OperationKey = TASKS_INSTANTIATE_TEMPLATE_OP_KEY;
    public readonly AuthorizedWriteEntities = [
        'MJ_BizApps_Tasks: Tasks',
        'MJ_BizApps_Tasks: Task Assignments',
        'MJ_BizApps_Tasks: Task Dependencies',
    ] as const;
    public readonly ExposeAsAgentTool = true;
    public readonly ExposeAsMCPTool = true;
    public readonly ToolDescription =
        'Instantiate a Task Template playbook on the server with relative due dates, hierarchy, dependencies, role assignments, and target Organization scoping.';
}

/**
 * Input payload for `BizAppsTasks.RunRecurringPlaybooks` — idempotently launches a reusable
 * playbook (such as Month-End Financial Close) across one or more target Organizations or every
 * mirrored internal Company (`Organization.LinkedCompanyID IS NOT NULL`).
 */
export interface TasksRunRecurringPlaybooksInput {
    /** `MJ_BizApps_Tasks: Task Templates.ID` to instantiate per target Organization. */
    TemplateID: string;
    /** Kickoff anchor date (`YYYY-MM-DD` or ISO string) used to calculate relative due dates. */
    AnchorDate: string;
    /**
     * Stable period idempotency key (e.g., `'2026-12'`, `'2026-Q4'`). Any Organization that
     * already has a root task tagged with `[Period:<PeriodKey>]` from this template is skipped
     * so scheduled jobs never double-spawn work.
     */
    PeriodKey: string;
    /** Explicit list of `MJ_BizApps_Common: Organizations.ID` UUIDs to launch for. */
    OrganizationIDs?: string[];
    /**
     * When `true` and `OrganizationIDs` is omitted, targets every active Organization mirrored
     * from `MJ: Companies` (`LinkedCompanyID IS NOT NULL`).
     */
    AllMirroredCompanies?: boolean;
    /** Optional category override (falls back to template default). */
    CategoryID?: string | null;
    /** Optional default role placeholder mappings applied to every launched organization. */
    RoleAssignments?: TemplateRoleAssignmentInput[];
    /** When `true`, resolves targets & checks idempotency without creating any rows. */
    DryRun?: boolean;
}

/** Per-organization outcome emitted by `BizAppsTasks.RunRecurringPlaybooks`. */
export interface RecurringPlaybookOrgResult {
    OrganizationID: string;
    OrganizationName: string;
    Status: 'created' | 'skipped' | 'dry-run' | 'failed';
    CreatedCount: number;
    CreatedTaskIDs: string[];
    Reason?: string;
}

/** Aggregate summary returned by `BizAppsTasks.RunRecurringPlaybooks`. */
export interface TasksRunRecurringPlaybooksOutput {
    TemplateID: string;
    PeriodKey: string;
    AnchorDate: string;
    DryRun: boolean;
    TargetOrganizations: number;
    LaunchedCount: number;
    SkippedCount: number;
    FailedCount: number;
    TotalTasksCreated: number;
    Results: RecurringPlaybookOrgResult[];
}

/**
 * Typed Remotable Operation shell for scheduled / recurring multi-entity Playbook rollovers
 * (callable from UI, Flow Agents, MCP, or MJ Scheduled Jobs).
 */
export class TasksRunRecurringPlaybooksOperation extends BaseRemotableOperation<
    TasksRunRecurringPlaybooksInput,
    TasksRunRecurringPlaybooksOutput
> {
    public readonly OperationKey = TASKS_RUN_RECURRING_PLAYBOOKS_OP_KEY;
    public readonly AuthorizedWriteEntities = [
        'MJ_BizApps_Tasks: Tasks',
        'MJ_BizApps_Tasks: Task Assignments',
        'MJ_BizApps_Tasks: Task Dependencies',
    ] as const;
    public readonly ExposeAsAgentTool = true;
    public readonly ExposeAsMCPTool = true;
    public readonly ToolDescription =
        'Idempotently instantiate a recurring Task Template playbook (such as Month-End Close) across explicit Organizations or all mirrored internal Companies for a fiscal PeriodKey.';
}
