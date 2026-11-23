import type {
    mjBizAppsTasksTaskCheckInEntity,
    mjBizAppsTasksTaskDependencyEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskRiskAssessmentEntity,
    TaskRiskItem,
} from '@mj-biz-apps/tasks-entities';

/** Task status union derived directly from generated `Task` entity type. */
export type ProjectTaskStatusValue = mjBizAppsTasksTaskEntity['Status'];

/** Task priority union derived directly from generated `Task` entity type. */
export type ProjectTaskPriorityValue = mjBizAppsTasksTaskEntity['Priority'];

/** Health status union derived directly from generated `Task Risk Assessment` entity type. */
export type ProjectRiskHealthStatusValue = mjBizAppsTasksTaskRiskAssessmentEntity['HealthStatus'];

/** SLA risk band union derived directly from generated `Task` entity type. */
export type ProjectSLARiskBandValue = NonNullable<mjBizAppsTasksTaskEntity['PredictedSLARiskBand']>;

/** Dependency type union derived directly from generated `Task Dependency` entity type. */
export type ProjectDependencyTypeValue = mjBizAppsTasksTaskDependencyEntity['DependencyType'];

/** Check-in health status union derived directly from generated `Task Check In` entity type. */
export type ProjectCheckInHealthStatusValue = mjBizAppsTasksTaskCheckInEntity['HealthStatus'];

/** Review cadence frequency for Project Risk Analyst scheduled evaluations. */
export type ProjectRiskCadence = 'Weekly' | 'Daily';

/** Deterministic reason explaining the selected review cadence. */
export type ProjectRiskCadenceReason =
    | 'First80Percent'
    | 'Final20Percent'
    | 'Overdue'
    | 'MissingTimelineDates'
    | 'TerminalTaskStatus';

/** Input describing a root project task's timeline bounds and latest assessment timestamp. */
export interface ProjectRiskCadenceInput {
    TaskStatus: ProjectTaskStatusValue;
    StartedAt: Date | string | null | undefined;
    CreatedAt?: Date | string | null | undefined;
    DueAt: Date | string | null | undefined;
    LatestAssessedAt?: Date | string | null | undefined;
    Now?: Date;
}

/** Deterministic cadence & cooldown evaluation result. */
export interface ProjectRiskCadenceEvaluation {
    Cadence: ProjectRiskCadence;
    IntervalHours: number;
    ElapsedRatio: number | null;
    RemainingRatio: number | null;
    IsFinal20Percent: boolean;
    IsOverdue: boolean;
    Reason: ProjectRiskCadenceReason;
    ShouldSkipScheduledRun: boolean;
    SkipReason: string | null;
    NextDueAt: Date | null;
}

/** Busy status values retained after free/busy sanitization (never includes event titles/bodies). */
export type SanitizedBusyStatus = 'Busy' | 'Tentative' | 'OutOfOffice' | 'WorkingElsewhere';

/** Single sanitized free/busy time interval with zero sensitive calendar metadata. */
export interface SanitizedBusyInterval {
    StartISO: string;
    EndISO: string;
    BusyMinutes: number;
    Status: SanitizedBusyStatus;
}

/** Sanitized per-assignee calendar availability summary for prompt context. */
export interface AssigneeFreeBusySummary {
    PersonID: string | null;
    UserID: string | null;
    AvailabilityKey: string;
    WindowStartISO: string;
    WindowEndISO: string;
    TotalWindowMinutes: number;
    BusyMinutes: number;
    FreeMinutes: number;
    AvailabilityRatio: number;
    BusyIntervals: SanitizedBusyInterval[];
}

/** Aggregated project-wide assignee free/busy availability summary. */
export interface ProjectFreeBusyAvailability {
    WindowStartISO: string;
    WindowEndISO: string;
    AssigneeCount: number;
    AverageAvailabilityRatio: number;
    TotalBusyMinutes: number;
    TotalFreeMinutes: number;
    Assignees: AssigneeFreeBusySummary[];
}

/** Source of the ML breach probability signal consumed by Project Risk Analyst. */
export type MLBreachSignalSource = 'TaskRecord' | 'ScoringProvider' | 'Unavailable';

/** Structured ML breach probability input provided to the Project Risk Analyst agent. */
export interface MLBreachSignal {
    Probability: number | null;
    RiskBand: ProjectSLARiskBandValue | null;
    ScoredAtISO: string | null;
    Source: MLBreachSignalSource;
}

/** Compact subtask summary included in the prompt payload. */
export interface SubtaskEvidenceSummary {
    TaskID: string;
    Name: string;
    Status: ProjectTaskStatusValue;
    PercentComplete: number;
    DueAtISO: string | null;
    CompletedAtISO: string | null;
    EvidenceLink: string;
}

/** Subtask completion and velocity metrics collected from batched RunView queries. */
export interface SubtaskVelocityEvidence {
    TotalSubtasks: number;
    CompletedCount: number;
    InProgressCount: number;
    OpenCount: number;
    BlockedCount: number;
    CancelledCount: number;
    CompletionRate: number;
    RecentlyCompletedCount: number;
    AveragePercentComplete: number;
    SubtaskSummaries: SubtaskEvidenceSummary[];
}

/** Blocked or unresolved dependency summary collected from Task Dependencies. */
export interface BlockedDependencyEvidenceItem {
    DependencyID: string;
    TaskID: string;
    TaskName: string;
    DependsOnTaskID: string;
    DependsOnTaskName: string;
    DependsOnStatus: ProjectTaskStatusValue;
    DependencyType: ProjectDependencyTypeValue;
    EvidenceLink: string;
}

/** Related record link summary collected from Task Links. */
export interface RelatedTaskLinkEvidenceItem {
    LinkID: string;
    TaskID: string;
    EntityName: string;
    RecordID: string;
    EvidenceLink: string;
}

/** Blocked dependencies and task links evidence summary. */
export interface BlockedDependencyEvidence {
    TotalDependencies: number;
    BlockedDependencyCount: number;
    RelatedLinkCount: number;
    BlockedItems: BlockedDependencyEvidenceItem[];
    TaskLinks: RelatedTaskLinkEvidenceItem[];
}

/** Bounded task check-in excerpt for prompt evidence. */
export interface CheckInEvidenceItem {
    CheckInID: string;
    TaskID: string;
    CheckInAtISO: string;
    HealthStatus: ProjectCheckInHealthStatusValue;
    ConfidenceScore: number | null;
    PercentComplete: number | null;
    SummaryExcerpt: string;
    BlockersExcerpt: string | null;
    EvidenceLink: string;
}

/** Aggregated task check-in evidence. */
export interface TaskCheckInEvidence {
    TotalCheckIns: number;
    LatestCheckInAtISO: string | null;
    CheckIns: CheckInEvidenceItem[];
}

/** Overdue project or subtask summary. */
export interface OverdueTaskEvidenceItem {
    TaskID: string;
    Name: string;
    Status: ProjectTaskStatusValue;
    Priority: ProjectTaskPriorityValue;
    DueAtISO: string;
    DaysOverdue: number;
    EvidenceLink: string;
}

/** Overdue items summary across root task and subtasks. */
export interface OverdueItemsEvidence {
    OverdueCount: number;
    RootTaskOverdue: boolean;
    Items: OverdueTaskEvidenceItem[];
}

/** Root project task snapshot included in the evidence bundle. */
export interface ProjectRootTaskSnapshot {
    ID: string;
    Name: string;
    Status: ProjectTaskStatusValue;
    Priority: ProjectTaskPriorityValue;
    StartedAtISO: string | null;
    DueAtISO: string | null;
    PercentComplete: number;
    HealthStatus: ProjectRiskHealthStatusValue | null;
    ConfidenceScore: number | null;
    ForecastCompletionDateISO: string | null;
    EvidenceLink: string;
}

/** Complete privacy-guarded evidence bundle delivered to the Project Risk Analyst agent. */
export interface ProjectRiskEvidenceBundle {
    RootTask: ProjectRootTaskSnapshot;
    Cadence: ProjectRiskCadenceEvaluation;
    Velocity: SubtaskVelocityEvidence;
    BlockedDependencies: BlockedDependencyEvidence;
    CheckIns: TaskCheckInEvidence;
    OverdueItems: OverdueItemsEvidence;
    FreeBusy: ProjectFreeBusyAvailability;
    MLBreach: MLBreachSignal;
}

/** Validated structured assessment returned by the Project Risk Analyst agent. */
export interface ProjectRiskAgentStructuredOutput {
    HealthStatus: ProjectRiskHealthStatusValue;
    ForecastCompletionDate: Date | null;
    ForecastConfidence: number;
    Summary: string;
    Risks: TaskRiskItem[];
}

/** Persisted assessment result returned by `ProjectRiskAnalystService.AssessProjectRisk`. */
export interface ProjectRiskAssessmentRunResult {
    Skipped: boolean;
    SkipReason: string | null;
    TaskID: string;
    OwnerUserID: string;
    AssessmentID: string | null;
    AssessedAt: Date | null;
    HealthStatus: ProjectRiskHealthStatusValue | null;
    ForecastCompletionDate: Date | null;
    ForecastConfidence: number | null;
    MLBreachProbability: number | null;
    Risks: TaskRiskItem[];
    Summary: string | null;
    AgentRunID: string | null;
    PromptTokens: number | null;
    CompletionTokens: number | null;
    TotalCostUSD: number | null;
    Cadence: ProjectRiskCadenceEvaluation;
    Evidence: ProjectRiskEvidenceBundle | null;
}
