import type {
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTaskCheckInEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskTypeStatusEntity,
} from '@mj-biz-apps/tasks-entities';
import type { TaskUiArchetype, TaskWorkspaceSummary } from '@mj-biz-apps/tasks-core';

/** Strongly-typed status union derived directly from the generated Task entity. */
export type TaskStatusValue = mjBizAppsTasksTaskEntity['Status'];

/** Strongly-typed priority union derived directly from the generated Task entity. */
export type TaskPriorityValue = mjBizAppsTasksTaskEntity['Priority'];

/** Strongly-typed OKR health status union derived directly from the generated Task entity. */
export type TaskHealthStatusValue = mjBizAppsTasksTaskEntity['HealthStatus'];

/** Strongly-typed OKR metric direction union derived directly from the generated Task entity. */
export type TaskMetricDirectionValue = mjBizAppsTasksTaskEntity['MetricDirection'];

/** Strongly-typed OKR check-in cadence union derived directly from the generated Task entity. */
export type TaskCheckInCadenceValue = mjBizAppsTasksTaskEntity['CheckInCadence'];

/** Strongly-typed predicted SLA risk band derived directly from the generated Task entity. */
export type TaskSlaRiskBandValue = mjBizAppsTasksTaskEntity['PredictedSLARiskBand'];

/** Strongly-typed assignment status union derived from TaskAssignment entity. */
export type TaskAssignmentStatusValue = mjBizAppsTasksTaskAssignmentEntity['Status'];

/** Strongly-typed check-in health union derived from TaskCheckIn entity. */
export type TaskCheckInHealthValue = mjBizAppsTasksTaskCheckInEntity['HealthStatus'];

/** A TaskTypeStatus workflow step shown in the clickable stepper or workflow board. */
export interface TaskWidgetTypeStatus {
    ID: string;
    TaskTypeID: string;
    Name: string;
    Code: string;
    MacroStatus: mjBizAppsTasksTaskTypeStatusEntity['MacroStatus'];
    Sequence: number;
    IsDefault: boolean;
    IsTerminal: boolean;
    Color: string | null;
    IconClass: string | null;
}

/** A resolved assignee pill rendered on task rows, cards, or inspectors. */
export interface TaskWidgetAssignee {
    ID?: string;
    DisplayName: string;
    Initials?: string;
    RoleName?: string | null;
    Status: TaskAssignmentStatusValue;
    EntityName?: string;
    RecordID: string;
}

/** A linked business record (TaskLink) displayed as a clickable context chip. */
export interface TaskWidgetLinkedRecord {
    EntityName: string;
    RecordID: string;
    DisplayName: string;
    IconClass?: string;
}

/** A tag chip attached to a task. */
export interface TaskWidgetTag {
    ID: string;
    Name: string;
    ColorCode: string | null;
}

/**
 * Rich L1/L2 view model for rendering a task across `<mjt-connected-tasks>`,
 * `<mjt-approval-card>`, `<mjt-mobile-milestone-stack>`, and Explorer dashboards.
 */
export interface TaskWidgetItem extends TaskWorkspaceSummary {
    Description: string | null;
    TypeID?: string;
    TypeName?: string | null;
    TypeCode?: string | null;
    CategoryID?: string | null;
    CategoryName?: string | null;
    TaskTypeStatusID?: string | null;
    TaskTypeStatusName?: string | null;
    BlockedReason?: string | null;
    Assignees?: TaskWidgetAssignee[];
    LinkedRecords?: TaskWidgetLinkedRecord[];
    Tags?: TaskWidgetTag[];
    ChildCount?: number;
    CompletedChildCount?: number;
    IsCriticalPath?: boolean;
    DependencyCount?: number;
    OnCompleteActionName?: string | null;
    OnRejectActionName?: string | null;
    OnCancelActionName?: string | null;
}

/** Payload emitted when the user submits a quick-captured task. */
export interface TaskQuickCaptureSubmitEvent {
    RawText: string;
    Title: string;
    Priority: TaskPriorityValue | null;
    DueAt: Date | null;
    AssigneeQuery: string | null;
    TagNames: string[];
    HoursEstimated: number | null;
    LinkedRecord: TaskWidgetLinkedRecord | null;
}

/** Payload emitted when an approver clicks Approve, Conditions, or Reject on an approval card. */
export interface TaskApprovalActionEvent {
    TaskID: string;
    OutcomeCode: 'Approved' | 'ApprovedWithConditions' | 'Rejected';
    Notes: string | null;
}

/** Payload emitted when a user logs an OKR Key Result check-in from the inline composer. */
export interface TaskOkrCheckInSubmitEvent {
    TaskID: string;
    NewValue: number | null;
    HealthStatus: TaskCheckInHealthValue;
    ConfidenceScore: number | null;
    Summary: string;
    Blockers: string | null;
    NextSteps: string | null;
}

/** Snapshot displayed by `<mjt-okr-checkin>`. */
export interface TaskOkrMetricSnapshot {
    TaskID: string;
    BaselineValue: number | null;
    TargetValue: number | null;
    CurrentValue: number | null;
    UnitOfMeasure: string | null;
    MetricDirection: TaskMetricDirectionValue;
    PercentComplete: number;
    HealthStatus: TaskHealthStatusValue;
    ConfidenceScore: number | null;
    PlanningPeriod: string | null;
    CheckInCadence: TaskCheckInCadenceValue;
    LastCheckInAt: Date | string | null;
    NextCheckInDueAt: Date | string | null;
}

/** Input payload for `<mjt-adaptive-spotlight>` on the full Task Record Form. */
export interface TaskAdaptiveSpotlightInput {
    TaskID: string;
    TaskName: string;
    Archetype: TaskUiArchetype;
    Status: TaskStatusValue;
    DueAt: Date | string | null;
    PercentComplete: number;
    HoursEstimated: number | null;
    HoursActual: number | null;
    BlockedReason: string | null;
    BlockingDependencyNames: string[];
    PredictedSLARiskBand: TaskSlaRiskBandValue;
    PredictedSLABreachProbability: number | null;
    OkrSnapshot?: TaskOkrMetricSnapshot | null;
    ApprovalTask?: TaskWidgetItem | null;
    LifecycleHooks?: {
        OnComplete?: string | null;
        OnReject?: string | null;
        OnCancel?: string | null;
    };
}

/** Command item rendered inside `<mjt-command-palette>`. */
export interface TaskCommandPaletteItem {
    ID: string;
    Label: string;
    Subtitle?: string;
    Group: 'Actions' | 'Views' | 'Tasks';
    IconClass: string;
    Shortcut?: string;
    TaskID?: string;
}

/** Urgency filter key emitted when the user clicks a pill in `<mjt-urgency-strip>`. */
export type TaskUrgencyFilterKey = '' | 'overdue' | 'blocked' | 'approvals' | 'sla';

/** Bulk action request emitted by `<mjt-bulk-action-dock>`. */
export interface TaskBulkActionRequest {
    Kind: 'status' | 'priority' | 'clear';
    Status?: TaskStatusValue;
    Priority?: TaskPriorityValue;
}
