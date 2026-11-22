/**
 * @fileoverview Centralized, strongly-typed `TasksLimits` configuration contract and
 * hierarchical resolver (`TasksLimitsResolver`) for BizApps Tasks.
 *
 * Pure and browser-safe (zero Node built-in imports): hosts or apps can register overrides
 * once at startup via {@link TasksLimitsResolver.RegisterConfigOverrides} or pass per-call
 * runtime overrides to {@link TasksLimitsResolver.Resolve}. Integrates seamlessly with
 * `@memberjunction/core`'s {@link LimitsConfigResolver} so MJ-level briefing bounds
 * (`BriefingContributorTimeoutMs`, `BriefingMaxContributorChars`) propagate automatically,
 * and reads optional `MJ_TASKS_LIMIT_*` / `MJ_TASKS_LIMITS_JSON` environment overrides safely
 * when running in a Node.js host.
 *
 * Precedence order (lowest -> highest):
 * 1. `CodeFallback` (built-in approved defaults)
 * 2. `MjLimitsConfig` (resolved from `@memberjunction/core` `LimitsConfigResolver`)
 * 3. `Env` (optional `MJ_TASKS_LIMIT_*` / `MJ_TASKS_LIMITS_JSON` environment overrides)
 * 4. `AppConfig` (registered BizApps Tasks app/host overrides)
 * 5. `RuntimeOverride` (per-invocation override)
 *
 * @module @mj-biz-apps/tasks-core
 */

import * as mjCore from '@memberjunction/core';
import * as mjGlobal from '@memberjunction/global';

/** Recursive JSON-compatible scalar/object input value accepted by {@link NormalizeTasksLimitsInput}. */
export type TasksLimitsJsonScalar = string | number | boolean | null | undefined;

/** Recursive JSON-compatible object input accepted by {@link NormalizeTasksLimitsInput}. */
export interface TasksLimitsJsonObject {
    [key: string]: TasksLimitsJsonValue;
}

/** Strongly-typed recursive input value accepted by {@link NormalizeTasksLimitsInput} without `any` or `unknown`. */
export type TasksLimitsJsonValue =
    | TasksLimitsJsonScalar
    | TasksLimitsJsonObject
    | readonly TasksLimitsJsonValue[]
    | TasksLimitsOverride
    | object;

/** Environment variable map accepted by {@link TasksLimitsResolver}. */
export type TasksLimitsEnvSource = Readonly<Record<string, string | undefined>>;

interface GlobalWithOptionalProcess {
    process?: {
        env?: TasksLimitsEnvSource;
    };
}

/**
 * Precedence tier identifiers for Tasks limits resolution, ordered from lowest
 * (`CodeFallback`) to highest (`RuntimeOverride`).
 */
export type TasksLimitsSourceTier =
    | 'CodeFallback'
    | 'MjLimitsConfig'
    | 'Env'
    | 'AppConfig'
    | 'RuntimeOverride';

/**
 * Canonical 5-tier precedence chain from lowest to highest priority.
 */
export const TASKS_LIMITS_TIER_PRECEDENCE: readonly TasksLimitsSourceTier[] = [
    'CodeFallback',
    'MjLimitsConfig',
    'Env',
    'AppConfig',
    'RuntimeOverride',
] as const;

/**
 * Runaway backstop ceilings preventing unbounded fan-out, graph traversal, or excessive item expansion.
 */
export interface TasksRunawayGuardsConfig {
    /** Maximum tasks accepted in a single bulk mutation call (`MAX_BULK_TASKS`). */
    MaxBulkTasks: number;
    /** Maximum traversal depth when walking parent/ancestor task chains. */
    MaxHierarchyDepth: number;
    /** Maximum upward supervisor chain hops during work-report authority resolution. */
    MaxSupervisorChainDepth: number;
    /** Maximum BFS graph nodes visited during task-dependency cycle detection. */
    MaxDependencyWalkIterations: number;
    /** Maximum iterative topological sort passes for task-template instantiation. */
    MaxTemplateSortIterations: number;
    /** Maximum recurrence occurrences expanded per materialization window. */
    MaxSeriesOccurrences: number;
    /** Hard upper bound on items returned per briefing section. */
    BriefingMaxItemsCeiling: number;
    /** Hard upper bound on forward lookahead horizon days for Tasks/Meetings briefings. */
    BriefingMaxHorizonDays: number;
    /** Hard upper bound on lookback days for Meetings briefings. */
    BriefingMaxLookbackDays: number;
    /** Hard upper bound on lookback days for Work Reports briefings. */
    BriefingWorkReportsMaxLookbackDays: number;
    /** Hard upper bound on `DaysAhead` for Find Meetings. */
    FindMeetingsMaxHorizonDays: number;
    /** Hard upper bound on `IncludePastHours` for Find Meetings. */
    FindMeetingsMaxPastHours: number;
    /** Hard upper bound on `Limit` for Find Meetings. */
    FindMeetingsMaxLimit: number;
    /** Hard upper bound on `WindowDays` for Find Similar Tasks / transcript dedup. */
    FindSimilarTasksMaxWindowDays: number;
    /** Hard upper bound on `Limit` for Find Similar Tasks. */
    FindSimilarTasksMaxLimit: number;
}

/**
 * Bounded database query `MaxRows`, chunk sizes, per-user caps, and external API timeouts.
 */
export interface TasksResourceGuardsConfig {
    /** Row limit for single-record existence and uniqueness lookups (`MaxRows: 1`). */
    DefaultLookupSingleRow: number;
    /** Row limit for disambiguating single vs ambiguous matches (`MaxRows: 2`). */
    AmbiguousLookupMaxRows: number;
    /** Row limit for recent task-link lookups (`MaxRows: 3`). */
    RecentLinksMaxRows: number;
    /** Row limit for recent notes, decisions, and dependency previews (`MaxRows: 5`). */
    RecentContextMaxRows: number;
    /** Row limit for person/organization/task disambiguation candidates (`MaxRows: 10`). */
    CandidateLookupMaxRows: number;
    /** Row limit for related task/meeting searches (`MaxRows: 25`). */
    RelatedSearchMaxRows: number;
    /** Row limit for assignee, tag, and attendee lists (`MaxRows: 50`). */
    StandardListMaxRows: number;
    /** Standard batch row limit and linked-ID slice cap (`MaxRows: 100`). */
    StandardBatchMaxRows: number;
    /** Row limit for extended meeting queries (`MaxRows: 150`). */
    ExtendedSearchMaxRows: number;
    /** Row limit for work-report, agenda, transcript, and reconcile batches (`MaxRows: 200`). */
    WorkflowBatchMaxRows: number;
    /** Row limit for briefing task queries and open-task dedup (`MaxRows: 250`). */
    BriefingTasksMaxRows: number;
    /** Row limit for broad attendee/agenda-type/CoS wake queries (`MaxRows: 500`). */
    BroadEntityQueryMaxRows: number;
    /** Row limit for large meeting attendee/note/agenda queries (`MaxRows: 1000`). */
    LargeTreeQueryMaxRows: number;
    /** Row limit for active meeting-series materialization queries (`MaxRows: 2000`). */
    SeriesMaterializationMaxRows: number;
    /** Row limit for full task subtree effort, timesheet, and active series queries (`MaxRows: 5000`). */
    SubtreeEffortMaxRows: number;
    /** Default `MaxRows` for `FindTasksAction` when caller omits `MaxRows`/`Limit`. */
    FindTasksDefaultMaxRows: number;
    /** Hard ceiling on `MaxRows` for `FindTasksAction`. */
    FindTasksMaxRowsCeiling: number;
    /** Minimum candidate count requested during semantic task search. */
    FindTasksSemanticSearchFloor: number;
    /** Hard ceiling on fetched rows during text-filtered `FindTasksAction`. */
    FindTasksSearchFetchCeiling: number;
    /** Default `MaxRows` for `ListWorkReportsAction`. */
    FindWorkReportsDefaultMaxRows: number;
    /** Hard ceiling on `MaxRows` for `ListWorkReportsAction`. */
    FindWorkReportsMaxRowsCeiling: number;
    /** Default `MaxRows` for `ReconcileStaleTimesheetApprovals`. */
    ReconcileTimesheetApprovalsDefaultMaxRows: number;
    /** Hard ceiling on `MaxRows` for `ReconcileStaleTimesheetApprovals`. */
    ReconcileTimesheetApprovalsMaxRowsCeiling: number;
    /** Chunk size for batched SQL `IN (...)` queries. */
    SqlInClauseChunkSize: number;
    /** Maximum saved task filter views persisted per user in `UserInfoEngine`. */
    MaxSavedTaskViews: number;
    /** Maximum transcript character count accepted by `MeetingNotesService`. */
    MaxMeetingTranscriptChars: number;
    /** HTTP timeout in milliseconds for Zoom REST/OAuth calls. */
    ZoomApiTimeoutMs: number;
    /** HTTP timeout in milliseconds for Teams webhook delivery. */
    TeamsWebhookTimeoutMs: number;
}

/**
 * Briefing contributor timeouts, character caps, default horizons, and excerpt sizes.
 */
export interface TasksBriefingLimitsConfig {
    /** Timeout in milliseconds per briefing contributor execution (synced from MJ `LimitsConfigResolver`). */
    ContributorTimeoutMs: number;
    /** Maximum serialized characters per briefing contributor (synced from MJ `LimitsConfigResolver`). */
    MaxContributorChars: number;
    /** Default `MaxItems` across Tasks, Meetings, and Work Reports briefings. */
    DefaultBriefingMaxItems: number;
    /** Default `HorizonDays` for Tasks and Meetings briefings. */
    DefaultBriefingHorizonDays: number;
    /** Default `LookbackDays` for `GetMyMeetingsBriefingAction`. */
    DefaultMeetingsBriefingLookbackDays: number;
    /** Default `LookbackDays` for `GetMyWorkReportsBriefingAction`. */
    DefaultWorkReportsBriefingLookbackDays: number;
    /** Maximum excerpt characters for meeting notes in summaries/briefings. */
    MeetingNoteExcerptMaxChars: number;
    /** Maximum preview characters for task notification excerpts. */
    NotificationPreviewMaxChars: number;
    /** Maximum transcript lines included in prompt excerpt headers. */
    TranscriptExcerptMaxLines: number;
}

/**
 * Operational tuning defaults for meeting horizons, similarity search, TTLs, and note truncation.
 */
export interface TasksTuningConfig {
    /** Default materialization horizon in days for active meeting series. */
    DefaultSeriesHorizonDays: number;
    /** Default meeting duration in minutes when meeting type omits `DefaultDurationMinutes`. */
    DefaultMeetingDurationMinutes: number;
    /** Default agenda item duration in minutes when an item omits `DurationMinutes`. */
    DefaultAgendaItemDurationMinutes: number;
    /** Default match limit for `findSimilarTasks`. */
    DefaultTaskSimilarityLimit: number;
    /** Match limit per commitment during transcript deduplication. */
    TranscriptDedupMatchLimit: number;
    /** Default lookback window in days for similarity and transcript dedup checks. */
    FindSimilarDefaultWindowDays: number;
    /** Default `Limit` for `FindMeetingsAction`. */
    FindMeetingsDefaultLimit: number;
    /** Default `DaysAhead` for `FindMeetingsAction`. */
    FindMeetingsDefaultDaysAhead: number;
    /** TTL in milliseconds for in-flight proposed-task creation claims. */
    ProposedTaskClaimTtlMs: number;
    /** Safety margin in milliseconds subtracted from Zoom OAuth token expiration. */
    ZoomTokenSafetyMarginMs: number;
    /** Maximum characters retained from external HTTP error bodies. */
    HttpErrorDetailMaxChars: number;
    /** Maximum characters stored on `Task.CompletionNotes` after agent execution. */
    CompletionNotesMaxChars: number;
    /** Maximum characters stored on `Task.CompletionNotes` when an agent execution fails. */
    FailureNotesMaxChars: number;
    /** Sequence increment between generated meeting agenda items. */
    DefaultAgendaSequenceStep: number;
}

/**
 * Complete resolved BizApps Tasks limits configuration surface.
 */
export interface TasksLimitsConfig {
    RunawayGuards: TasksRunawayGuardsConfig;
    ResourceGuards: TasksResourceGuardsConfig;
    Briefing: TasksBriefingLimitsConfig;
    Tuning: TasksTuningConfig;
}

/** Partial override for {@link TasksRunawayGuardsConfig}. */
export type TasksRunawayGuardsOverride = Partial<TasksRunawayGuardsConfig>;
/** Partial override for {@link TasksResourceGuardsConfig}. */
export type TasksResourceGuardsOverride = Partial<TasksResourceGuardsConfig>;
/** Partial override for {@link TasksBriefingLimitsConfig}. */
export type TasksBriefingLimitsOverride = Partial<TasksBriefingLimitsConfig>;
/** Partial override for {@link TasksTuningConfig}. */
export type TasksTuningOverride = Partial<TasksTuningConfig>;

/**
 * Partial override object accepted across all Tasks limits configuration tiers.
 */
export interface TasksLimitsOverride {
    RunawayGuards?: TasksRunawayGuardsOverride;
    ResourceGuards?: TasksResourceGuardsOverride;
    Briefing?: TasksBriefingLimitsOverride;
    Tuning?: TasksTuningOverride;
}

export type TasksRunawayGuardKey = keyof TasksRunawayGuardsConfig;
export type TasksResourceGuardKey = keyof TasksResourceGuardsConfig;
export type TasksBriefingLimitKey = keyof TasksBriefingLimitsConfig;
export type TasksTuningKey = keyof TasksTuningConfig;

/** Canonical dot-delimited key paths across {@link TasksLimitsConfig}. */
export type TasksLimitsKeyPath =
    | `RunawayGuards.${TasksRunawayGuardKey}`
    | `ResourceGuards.${TasksResourceGuardKey}`
    | `Briefing.${TasksBriefingLimitKey}`
    | `Tuning.${TasksTuningKey}`;

/** Inclusive integer safety range `[min, max]` enforced for each Tasks limit key. */
export interface TasksLimitSafetyBounds {
    readonly min: number;
    readonly max: number;
}

/**
 * Provenance metadata recorded per resolved Tasks limit key.
 */
export interface TasksLimitsKeyProvenance {
    Key: TasksLimitsKeyPath;
    Value: number;
    SourceTier: TasksLimitsSourceTier;
    IsOverridden: boolean;
    WasClampedToSafetyCeiling: boolean;
    TierValues: Partial<Record<TasksLimitsSourceTier, number>>;
}

/** Subset of `@memberjunction/core` `MJLimitsConfig` bridged into Tasks briefing limits. */
export interface TasksMjLimitsSnapshot {
    BriefingContributorTimeoutMs: number;
    BriefingMaxContributorChars: number;
}

/** Subset of `@memberjunction/core` `MJLimitsOverride` accepted by {@link TasksLimitsResolver.Resolve}. */
export interface TasksMjLimitsOverride {
    BriefingContributorTimeoutMs?: number;
    BriefingMaxContributorChars?: number;
}

/** Provenance entry subset returned by `@memberjunction/core` `LimitsConfigResolver.Resolve`. */
export interface MjLimitsFallbackProvenanceEntry {
    IsOverridden: boolean;
}

/** Structural snapshot returned by `@memberjunction/core` `LimitsConfigResolver.Resolve`. */
export interface MjLimitsResolutionSnapshot {
    Limits: TasksMjLimitsSnapshot;
    Provenance: {
        BriefingContributorTimeoutMs?: MjLimitsFallbackProvenanceEntry;
        BriefingMaxContributorChars?: MjLimitsFallbackProvenanceEntry;
    };
    ResolvedAtISO: string;
}

/** Structural interface matching `@memberjunction/core`'s `LimitsConfigResolver.Instance`. */
export interface MjLimitsResolverInstanceLike {
    GetMjConfigLimits(): TasksMjLimitsOverride | null;
    Resolve(
        input?: { MjConfig?: TasksMjLimitsOverride },
        options?: { ResolvedAtISO?: string },
    ): MjLimitsResolutionSnapshot | object;
}

/**
 * Complete output returned by {@link TasksLimitsResolver.Resolve}.
 */
export interface TasksLimitsResolutionResult {
    Limits: TasksLimitsConfig;
    MjLimits: TasksMjLimitsSnapshot;
    Provenance: Record<TasksLimitsKeyPath, TasksLimitsKeyProvenance>;
    OverriddenKeys: TasksLimitsKeyPath[];
    ClampedKeys: TasksLimitsKeyPath[];
    ResolvedAtISO: string;
}

/**
 * Explicit tier layers accepted by {@link TasksLimitsResolver.Resolve}.
 */
export interface TasksLimitsResolutionInput {
    CodeFallback?: TasksLimitsOverride;
    MjLimits?: TasksMjLimitsOverride;
    /** Explicit environment map override (`null` disables automatic `process.env` reading). */
    Env?: TasksLimitsEnvSource | null;
    AppConfig?: TasksLimitsOverride;
    RuntimeOverride?: TasksLimitsOverride;
}

/**
 * Options controlling {@link TasksLimitsResolver.Resolve}.
 */
export interface TasksLimitsResolveOptions {
    /** Deterministic ISO timestamp override (primarily for unit tests). */
    ResolvedAtISO?: string;
    /** Set `false` to skip reading `process.env` when `input.Env` is omitted. */
    UseProcessEnv?: boolean;
}

/**
 * Single validation issue detected by {@link ValidateTasksLimitsConfig}.
 */
export interface TasksLimitsValidationIssue {
    Key: TasksLimitsKeyPath;
    Message: string;
}

/**
 * Result of {@link ValidateTasksLimitsConfig}.
 */
export interface TasksLimitsValidationResult {
    Valid: boolean;
    Issues: TasksLimitsValidationIssue[];
}

/**
 * Built-in approved default Tasks limits (`CodeFallback` tier).
 */
export const CODE_FALLBACK_TASKS_LIMITS: Readonly<TasksLimitsConfig> = {
    RunawayGuards: {
        MaxBulkTasks: 500,
        MaxHierarchyDepth: 100,
        MaxSupervisorChainDepth: 3,
        MaxDependencyWalkIterations: 5_000,
        MaxTemplateSortIterations: 1_000,
        MaxSeriesOccurrences: 500,
        BriefingMaxItemsCeiling: 50,
        BriefingMaxHorizonDays: 30,
        BriefingMaxLookbackDays: 30,
        BriefingWorkReportsMaxLookbackDays: 90,
        FindMeetingsMaxHorizonDays: 30,
        FindMeetingsMaxPastHours: 72,
        FindMeetingsMaxLimit: 50,
        FindSimilarTasksMaxWindowDays: 365,
        FindSimilarTasksMaxLimit: 25,
    },
    ResourceGuards: {
        DefaultLookupSingleRow: 1,
        AmbiguousLookupMaxRows: 2,
        RecentLinksMaxRows: 3,
        RecentContextMaxRows: 5,
        CandidateLookupMaxRows: 10,
        RelatedSearchMaxRows: 25,
        StandardListMaxRows: 50,
        StandardBatchMaxRows: 100,
        ExtendedSearchMaxRows: 150,
        WorkflowBatchMaxRows: 200,
        BriefingTasksMaxRows: 250,
        BroadEntityQueryMaxRows: 500,
        LargeTreeQueryMaxRows: 1_000,
        SeriesMaterializationMaxRows: 2_000,
        SubtreeEffortMaxRows: 5_000,
        FindTasksDefaultMaxRows: 25,
        FindTasksMaxRowsCeiling: 100,
        FindTasksSemanticSearchFloor: 40,
        FindTasksSearchFetchCeiling: 200,
        FindWorkReportsDefaultMaxRows: 20,
        FindWorkReportsMaxRowsCeiling: 100,
        ReconcileTimesheetApprovalsDefaultMaxRows: 200,
        ReconcileTimesheetApprovalsMaxRowsCeiling: 1_000,
        SqlInClauseChunkSize: 100,
        MaxSavedTaskViews: 25,
        MaxMeetingTranscriptChars: 100_000,
        ZoomApiTimeoutMs: 15_000,
        TeamsWebhookTimeoutMs: 15_000,
    },
    Briefing: {
        ContributorTimeoutMs: 10_000,
        MaxContributorChars: 32_768,
        DefaultBriefingMaxItems: 10,
        DefaultBriefingHorizonDays: 7,
        DefaultMeetingsBriefingLookbackDays: 7,
        DefaultWorkReportsBriefingLookbackDays: 14,
        MeetingNoteExcerptMaxChars: 600,
        NotificationPreviewMaxChars: 100,
        TranscriptExcerptMaxLines: 8,
    },
    Tuning: {
        DefaultSeriesHorizonDays: 90,
        DefaultMeetingDurationMinutes: 60,
        DefaultAgendaItemDurationMinutes: 10,
        DefaultTaskSimilarityLimit: 5,
        TranscriptDedupMatchLimit: 3,
        FindSimilarDefaultWindowDays: 30,
        FindMeetingsDefaultLimit: 20,
        FindMeetingsDefaultDaysAhead: 7,
        ProposedTaskClaimTtlMs: 60_000,
        ZoomTokenSafetyMarginMs: 60_000,
        HttpErrorDetailMaxChars: 300,
        CompletionNotesMaxChars: 2_000,
        FailureNotesMaxChars: 1_000,
        DefaultAgendaSequenceStep: 100,
    },
};

/**
 * Safety bounds (`[min, max]` inclusive positive integers) enforced for every Tasks limit key
 * so misconfigured overrides can never disable a `RunawayGuard` or `ResourceGuard`.
 */
export const TASKS_LIMIT_SAFETY_BOUNDS: Readonly<Record<TasksLimitsKeyPath, TasksLimitSafetyBounds>> = {
    'RunawayGuards.MaxBulkTasks': { min: 1, max: 10_000 },
    'RunawayGuards.MaxHierarchyDepth': { min: 1, max: 1_000 },
    'RunawayGuards.MaxSupervisorChainDepth': { min: 1, max: 50 },
    'RunawayGuards.MaxDependencyWalkIterations': { min: 1, max: 100_000 },
    'RunawayGuards.MaxTemplateSortIterations': { min: 1, max: 100_000 },
    'RunawayGuards.MaxSeriesOccurrences': { min: 1, max: 10_000 },
    'RunawayGuards.BriefingMaxItemsCeiling': { min: 1, max: 500 },
    'RunawayGuards.BriefingMaxHorizonDays': { min: 1, max: 365 },
    'RunawayGuards.BriefingMaxLookbackDays': { min: 1, max: 365 },
    'RunawayGuards.BriefingWorkReportsMaxLookbackDays': { min: 1, max: 365 },
    'RunawayGuards.FindMeetingsMaxHorizonDays': { min: 1, max: 365 },
    'RunawayGuards.FindMeetingsMaxPastHours': { min: 1, max: 720 },
    'RunawayGuards.FindMeetingsMaxLimit': { min: 1, max: 500 },
    'RunawayGuards.FindSimilarTasksMaxWindowDays': { min: 1, max: 3_650 },
    'RunawayGuards.FindSimilarTasksMaxLimit': { min: 1, max: 200 },
    'ResourceGuards.DefaultLookupSingleRow': { min: 1, max: 100 },
    'ResourceGuards.AmbiguousLookupMaxRows': { min: 1, max: 100 },
    'ResourceGuards.RecentLinksMaxRows': { min: 1, max: 100 },
    'ResourceGuards.RecentContextMaxRows': { min: 1, max: 500 },
    'ResourceGuards.CandidateLookupMaxRows': { min: 1, max: 500 },
    'ResourceGuards.RelatedSearchMaxRows': { min: 1, max: 1_000 },
    'ResourceGuards.StandardListMaxRows': { min: 1, max: 5_000 },
    'ResourceGuards.StandardBatchMaxRows': { min: 1, max: 10_000 },
    'ResourceGuards.ExtendedSearchMaxRows': { min: 1, max: 10_000 },
    'ResourceGuards.WorkflowBatchMaxRows': { min: 1, max: 10_000 },
    'ResourceGuards.BriefingTasksMaxRows': { min: 1, max: 10_000 },
    'ResourceGuards.BroadEntityQueryMaxRows': { min: 1, max: 25_000 },
    'ResourceGuards.LargeTreeQueryMaxRows': { min: 1, max: 50_000 },
    'ResourceGuards.SeriesMaterializationMaxRows': { min: 1, max: 50_000 },
    'ResourceGuards.SubtreeEffortMaxRows': { min: 1, max: 100_000 },
    'ResourceGuards.FindTasksDefaultMaxRows': { min: 1, max: 1_000 },
    'ResourceGuards.FindTasksMaxRowsCeiling': { min: 1, max: 1_000 },
    'ResourceGuards.FindTasksSemanticSearchFloor': { min: 1, max: 1_000 },
    'ResourceGuards.FindTasksSearchFetchCeiling': { min: 1, max: 5_000 },
    'ResourceGuards.FindWorkReportsDefaultMaxRows': { min: 1, max: 1_000 },
    'ResourceGuards.FindWorkReportsMaxRowsCeiling': { min: 1, max: 1_000 },
    'ResourceGuards.ReconcileTimesheetApprovalsDefaultMaxRows': { min: 1, max: 10_000 },
    'ResourceGuards.ReconcileTimesheetApprovalsMaxRowsCeiling': { min: 1, max: 10_000 },
    'ResourceGuards.SqlInClauseChunkSize': { min: 1, max: 2_500 },
    'ResourceGuards.MaxSavedTaskViews': { min: 1, max: 500 },
    'ResourceGuards.MaxMeetingTranscriptChars': { min: 100, max: 10_000_000 },
    'ResourceGuards.ZoomApiTimeoutMs': { min: 100, max: 300_000 },
    'ResourceGuards.TeamsWebhookTimeoutMs': { min: 100, max: 300_000 },
    'Briefing.ContributorTimeoutMs': { min: 100, max: 300_000 },
    'Briefing.MaxContributorChars': { min: 256, max: 1_000_000 },
    'Briefing.DefaultBriefingMaxItems': { min: 1, max: 500 },
    'Briefing.DefaultBriefingHorizonDays': { min: 1, max: 365 },
    'Briefing.DefaultMeetingsBriefingLookbackDays': { min: 1, max: 365 },
    'Briefing.DefaultWorkReportsBriefingLookbackDays': { min: 1, max: 365 },
    'Briefing.MeetingNoteExcerptMaxChars': { min: 20, max: 20_000 },
    'Briefing.NotificationPreviewMaxChars': { min: 20, max: 5_000 },
    'Briefing.TranscriptExcerptMaxLines': { min: 1, max: 200 },
    'Tuning.DefaultSeriesHorizonDays': { min: 1, max: 3_650 },
    'Tuning.DefaultMeetingDurationMinutes': { min: 1, max: 1_440 },
    'Tuning.DefaultAgendaItemDurationMinutes': { min: 1, max: 1_440 },
    'Tuning.DefaultTaskSimilarityLimit': { min: 1, max: 100 },
    'Tuning.TranscriptDedupMatchLimit': { min: 1, max: 100 },
    'Tuning.FindSimilarDefaultWindowDays': { min: 1, max: 3_650 },
    'Tuning.FindMeetingsDefaultLimit': { min: 1, max: 500 },
    'Tuning.FindMeetingsDefaultDaysAhead': { min: 1, max: 365 },
    'Tuning.ProposedTaskClaimTtlMs': { min: 1_000, max: 3_600_000 },
    'Tuning.ZoomTokenSafetyMarginMs': { min: 1_000, max: 3_600_000 },
    'Tuning.HttpErrorDetailMaxChars': { min: 50, max: 10_000 },
    'Tuning.CompletionNotesMaxChars': { min: 50, max: 100_000 },
    'Tuning.FailureNotesMaxChars': { min: 50, max: 100_000 },
    'Tuning.DefaultAgendaSequenceStep': { min: 1, max: 10_000 },
};

const RUNAWAY_GUARD_KEYS: readonly TasksRunawayGuardKey[] = [
    'MaxBulkTasks',
    'MaxHierarchyDepth',
    'MaxSupervisorChainDepth',
    'MaxDependencyWalkIterations',
    'MaxTemplateSortIterations',
    'MaxSeriesOccurrences',
    'BriefingMaxItemsCeiling',
    'BriefingMaxHorizonDays',
    'BriefingMaxLookbackDays',
    'BriefingWorkReportsMaxLookbackDays',
    'FindMeetingsMaxHorizonDays',
    'FindMeetingsMaxPastHours',
    'FindMeetingsMaxLimit',
    'FindSimilarTasksMaxWindowDays',
    'FindSimilarTasksMaxLimit',
];

const RESOURCE_GUARD_KEYS: readonly TasksResourceGuardKey[] = [
    'DefaultLookupSingleRow',
    'AmbiguousLookupMaxRows',
    'RecentLinksMaxRows',
    'RecentContextMaxRows',
    'CandidateLookupMaxRows',
    'RelatedSearchMaxRows',
    'StandardListMaxRows',
    'StandardBatchMaxRows',
    'ExtendedSearchMaxRows',
    'WorkflowBatchMaxRows',
    'BriefingTasksMaxRows',
    'BroadEntityQueryMaxRows',
    'LargeTreeQueryMaxRows',
    'SeriesMaterializationMaxRows',
    'SubtreeEffortMaxRows',
    'FindTasksDefaultMaxRows',
    'FindTasksMaxRowsCeiling',
    'FindTasksSemanticSearchFloor',
    'FindTasksSearchFetchCeiling',
    'FindWorkReportsDefaultMaxRows',
    'FindWorkReportsMaxRowsCeiling',
    'ReconcileTimesheetApprovalsDefaultMaxRows',
    'ReconcileTimesheetApprovalsMaxRowsCeiling',
    'SqlInClauseChunkSize',
    'MaxSavedTaskViews',
    'MaxMeetingTranscriptChars',
    'ZoomApiTimeoutMs',
    'TeamsWebhookTimeoutMs',
];

const BRIEFING_KEYS: readonly TasksBriefingLimitKey[] = [
    'ContributorTimeoutMs',
    'MaxContributorChars',
    'DefaultBriefingMaxItems',
    'DefaultBriefingHorizonDays',
    'DefaultMeetingsBriefingLookbackDays',
    'DefaultWorkReportsBriefingLookbackDays',
    'MeetingNoteExcerptMaxChars',
    'NotificationPreviewMaxChars',
    'TranscriptExcerptMaxLines',
];

const TUNING_KEYS: readonly TasksTuningKey[] = [
    'DefaultSeriesHorizonDays',
    'DefaultMeetingDurationMinutes',
    'DefaultAgendaItemDurationMinutes',
    'DefaultTaskSimilarityLimit',
    'TranscriptDedupMatchLimit',
    'FindSimilarDefaultWindowDays',
    'FindMeetingsDefaultLimit',
    'FindMeetingsDefaultDaysAhead',
    'ProposedTaskClaimTtlMs',
    'ZoomTokenSafetyMarginMs',
    'HttpErrorDetailMaxChars',
    'CompletionNotesMaxChars',
    'FailureNotesMaxChars',
    'DefaultAgendaSequenceStep',
];

/** Ordered list of every canonical {@link TasksLimitsKeyPath}. */
export const TASKS_LIMITS_KEY_PATHS: readonly TasksLimitsKeyPath[] = [
    ...RUNAWAY_GUARD_KEYS.map((k): TasksLimitsKeyPath => `RunawayGuards.${k}`),
    ...RESOURCE_GUARD_KEYS.map((k): TasksLimitsKeyPath => `ResourceGuards.${k}`),
    ...BRIEFING_KEYS.map((k): TasksLimitsKeyPath => `Briefing.${k}`),
    ...TUNING_KEYS.map((k): TasksLimitsKeyPath => `Tuning.${k}`),
] as const;

interface ParsedLimitCandidate {
    value: number;
    wasClamped: boolean;
}

interface SanitizedLayer {
    override: TasksLimitsOverride;
    clampedKeys: Set<TasksLimitsKeyPath>;
}

const STRICT_NUMERIC_STRING_RE = /^[+-]?(?:\d+\.?\d*|\.\d+)$/;

function isJsonObject(value: TasksLimitsJsonValue | undefined): value is TasksLimitsJsonObject {
    if (Object.prototype.hasOwnProperty.call(mjGlobal, 'IsPlainObject') && typeof mjGlobal.IsPlainObject === 'function') {
        return mjGlobal.IsPlainObject(value);
    }
    if (value === null || typeof value !== 'object' || Array.isArray(value)) {
        return false;
    }
    const proto = Object.getPrototypeOf(value);
    return proto === null || proto === Object.prototype;
}

function readObjectProperty(obj: TasksLimitsJsonObject, names: readonly string[]): TasksLimitsJsonValue | undefined {
    for (const name of names) {
        if (Object.prototype.hasOwnProperty.call(obj, name)) {
            return obj[name];
        }
    }
    return undefined;
}

function toUpperSnakeCase(key: string): string {
    return key.replace(/([a-z0-9])([A-Z])/g, '$1_$2').toUpperCase();
}

function readProcessEnvSafely(): TasksLimitsEnvSource | null {
    const host = globalThis as typeof globalThis & GlobalWithOptionalProcess;
    const env = host.process?.env;
    return env && typeof env === 'object' ? env : null;
}

/**
 * Validates and clamps a raw numeric or string candidate against the key's {@link TasksLimitSafetyBounds}.
 * Rejects `NaN`, `<= 0`, `Infinity`, `-Infinity`, malformed strings, and values below `bounds.min`
 * so invalid inputs fall back to lower-tier safe positive defaults. Positive finite integers above
 * `bounds.max` are clamped to `bounds.max`.
 */
function parseAndClampPositiveInt(
    raw: TasksLimitsJsonValue | number | undefined,
    bounds: TasksLimitSafetyBounds,
): ParsedLimitCandidate | undefined {
    let numeric: number;
    if (typeof raw === 'number') {
        numeric = raw;
    } else if (typeof raw === 'string') {
        const trimmed = raw.trim();
        if (!trimmed || !STRICT_NUMERIC_STRING_RE.test(trimmed)) {
            return undefined;
        }
        numeric = Number(trimmed);
    } else {
        return undefined;
    }

    if (!Number.isFinite(numeric) || numeric <= 0) {
        return undefined;
    }
    const floored = Math.floor(numeric);
    if (floored < bounds.min) {
        return undefined;
    }
    if (floored > bounds.max) {
        return { value: bounds.max, wasClamped: true };
    }
    return { value: floored, wasClamped: false };
}

function normalizeSectionFromJson<K extends string>(
    raw: TasksLimitsJsonValue | undefined,
    keys: readonly K[],
    sectionPrefix: 'RunawayGuards' | 'ResourceGuards' | 'Briefing' | 'Tuning',
    clampedKeys: Set<TasksLimitsKeyPath>,
): Partial<Record<K, number>> | undefined {
    if (!isJsonObject(raw)) {
        return undefined;
    }
    const out: Partial<Record<K, number>> = {};
    for (const key of keys) {
        const camel = key.charAt(0).toLowerCase() + key.slice(1);
        const candidate = readObjectProperty(raw, [key, camel]);
        const keyPath = `${sectionPrefix}.${key}` as TasksLimitsKeyPath;
        const parsed = parseAndClampPositiveInt(candidate, TASKS_LIMIT_SAFETY_BOUNDS[keyPath]);
        if (parsed !== undefined) {
            out[key] = parsed.value;
            if (parsed.wasClamped) {
                clampedKeys.add(keyPath);
            }
        }
    }
    return Object.keys(out).length > 0 ? out : undefined;
}

function normalizeTasksLimitsWithTracking(
    raw: TasksLimitsJsonValue | TasksLimitsOverride | undefined,
): SanitizedLayer {
    const clampedKeys = new Set<TasksLimitsKeyPath>();
    if (!isJsonObject(raw)) {
        return { override: {}, clampedKeys };
    }
    const out: TasksLimitsOverride = {};

    const runaway = normalizeSectionFromJson(
        readObjectProperty(raw, ['RunawayGuards', 'runawayGuards']),
        RUNAWAY_GUARD_KEYS,
        'RunawayGuards',
        clampedKeys,
    );
    if (runaway) out.RunawayGuards = runaway;

    const resource = normalizeSectionFromJson(
        readObjectProperty(raw, ['ResourceGuards', 'resourceGuards']),
        RESOURCE_GUARD_KEYS,
        'ResourceGuards',
        clampedKeys,
    );
    if (resource) out.ResourceGuards = resource;

    const briefing = normalizeSectionFromJson(
        readObjectProperty(raw, ['Briefing', 'briefing']),
        BRIEFING_KEYS,
        'Briefing',
        clampedKeys,
    );
    if (briefing) out.Briefing = briefing;

    const tuning = normalizeSectionFromJson(
        readObjectProperty(raw, ['Tuning', 'tuning']),
        TUNING_KEYS,
        'Tuning',
        clampedKeys,
    );
    if (tuning) out.Tuning = tuning;

    return { override: out, clampedKeys };
}

function sanitizeTypedSection<K extends string>(
    raw: Partial<Record<K, number>> | undefined,
    keys: readonly K[],
    sectionPrefix: 'RunawayGuards' | 'ResourceGuards' | 'Briefing' | 'Tuning',
    clampedKeys: Set<TasksLimitsKeyPath>,
): Partial<Record<K, number>> | undefined {
    if (!raw) return undefined;
    const out: Partial<Record<K, number>> = {};
    for (const key of keys) {
        const keyPath = `${sectionPrefix}.${key}` as TasksLimitsKeyPath;
        const parsed = parseAndClampPositiveInt(raw[key], TASKS_LIMIT_SAFETY_BOUNDS[keyPath]);
        if (parsed !== undefined) {
            out[key] = parsed.value;
            if (parsed.wasClamped) {
                clampedKeys.add(keyPath);
            }
        }
    }
    return Object.keys(out).length > 0 ? out : undefined;
}

function sanitizeTasksLimitsWithTracking(override: TasksLimitsOverride | undefined): SanitizedLayer {
    const clampedKeys = new Set<TasksLimitsKeyPath>();
    if (!override) {
        return { override: {}, clampedKeys };
    }
    const out: TasksLimitsOverride = {};

    const runaway = sanitizeTypedSection(override.RunawayGuards, RUNAWAY_GUARD_KEYS, 'RunawayGuards', clampedKeys);
    if (runaway) out.RunawayGuards = runaway;

    const resource = sanitizeTypedSection(override.ResourceGuards, RESOURCE_GUARD_KEYS, 'ResourceGuards', clampedKeys);
    if (resource) out.ResourceGuards = resource;

    const briefing = sanitizeTypedSection(override.Briefing, BRIEFING_KEYS, 'Briefing', clampedKeys);
    if (briefing) out.Briefing = briefing;

    const tuning = sanitizeTypedSection(override.Tuning, TUNING_KEYS, 'Tuning', clampedKeys);
    if (tuning) out.Tuning = tuning;

    return { override: out, clampedKeys };
}

/**
 * Tolerantly normalizes an untyped JSON limits block into a strongly typed {@link TasksLimitsOverride}.
 * Accepts both PascalCase and camelCase field names. Non-finite, non-positive, or malformed inputs
 * are discarded cleanly; finite integers exceeding safety ceilings are clamped to safe maximums.
 */
export function NormalizeTasksLimitsInput(
    raw: TasksLimitsJsonValue | TasksLimitsOverride | undefined,
): TasksLimitsOverride {
    return normalizeTasksLimitsWithTracking(raw).override;
}

/**
 * Sanitizes a typed {@link TasksLimitsOverride} by discarding any invalid, non-positive,
 * or non-finite values and clamping oversized values to per-key safety ceilings.
 */
export function SanitizeTasksLimitsOverride(
    override: TasksLimitsOverride | undefined,
): TasksLimitsOverride {
    return sanitizeTasksLimitsWithTracking(override).override;
}

/**
 * Parses `MJ_TASKS_LIMITS_JSON` and `MJ_TASKS_LIMIT_<KEY>` environment variables into a sanitized
 * {@link TasksLimitsOverride}. Invalid or non-positive values are ignored cleanly; oversized finite
 * values are clamped to per-key safety ceilings.
 */
export function ParseTasksLimitsFromEnv(env: TasksLimitsEnvSource | null | undefined): TasksLimitsOverride {
    return parseTasksLimitsFromEnvWithTracking(env).override;
}

function parseTasksLimitsFromEnvWithTracking(env: TasksLimitsEnvSource | null | undefined): SanitizedLayer {
    const clampedKeys = new Set<TasksLimitsKeyPath>();
    if (!env) {
        return { override: {}, clampedKeys };
    }

    let merged: TasksLimitsOverride = {};
    const jsonRaw = env['MJ_TASKS_LIMITS_JSON'];
    if (typeof jsonRaw === 'string' && jsonRaw.trim().length > 0) {
        try {
            const parsedJson = JSON.parse(jsonRaw) as TasksLimitsJsonValue;
            const jsonLayer = normalizeTasksLimitsWithTracking(parsedJson);
            merged = jsonLayer.override;
            for (const k of jsonLayer.clampedKeys) clampedKeys.add(k);
        } catch {
            // Malformed MJ_TASKS_LIMITS_JSON is ignored so defaults remain intact
        }
    }

    for (const keyPath of TASKS_LIMITS_KEY_PATHS) {
        const dotIdx = keyPath.indexOf('.');
        const section = keyPath.slice(0, dotIdx) as keyof TasksLimitsOverride;
        const field = keyPath.slice(dotIdx + 1);
        const upperKey = toUpperSnakeCase(field);
        const upperSection = toUpperSnakeCase(section);
        const candidate =
            env[`MJ_TASKS_LIMIT_${upperSection}_${upperKey}`] ??
            env[`MJ_TASKS_LIMIT_${upperKey}`];
        if (candidate === undefined) continue;

        const parsed = parseAndClampPositiveInt(candidate, TASKS_LIMIT_SAFETY_BOUNDS[keyPath]);
        if (parsed === undefined) continue;

        assignOverrideValue(merged, keyPath, parsed.value);
        if (parsed.wasClamped) {
            clampedKeys.add(keyPath);
        } else {
            clampedKeys.delete(keyPath);
        }
    }

    return { override: merged, clampedKeys };
}

function cloneDefaultTasksLimits(): TasksLimitsConfig {
    return {
        RunawayGuards: { ...CODE_FALLBACK_TASKS_LIMITS.RunawayGuards },
        ResourceGuards: { ...CODE_FALLBACK_TASKS_LIMITS.ResourceGuards },
        Briefing: { ...CODE_FALLBACK_TASKS_LIMITS.Briefing },
        Tuning: { ...CODE_FALLBACK_TASKS_LIMITS.Tuning },
    };
}

function buildMjBridgeLayer(
    mjResult: TasksMjLimitsSnapshot,
    mjLimitsResolverHasOverride: boolean,
    clampedKeys: Set<TasksLimitsKeyPath>,
): TasksLimitsOverride | null {
    if (!mjLimitsResolverHasOverride) {
        return null;
    }
    const briefing: TasksBriefingLimitsOverride = {};
    const timeout = parseAndClampPositiveInt(
        mjResult.BriefingContributorTimeoutMs,
        TASKS_LIMIT_SAFETY_BOUNDS['Briefing.ContributorTimeoutMs'],
    );
    if (timeout !== undefined) {
        briefing.ContributorTimeoutMs = timeout.value;
        if (timeout.wasClamped) clampedKeys.add('Briefing.ContributorTimeoutMs');
    }
    const maxChars = parseAndClampPositiveInt(
        mjResult.BriefingMaxContributorChars,
        TASKS_LIMIT_SAFETY_BOUNDS['Briefing.MaxContributorChars'],
    );
    if (maxChars !== undefined) {
        briefing.MaxContributorChars = maxChars.value;
        if (maxChars.wasClamped) clampedKeys.add('Briefing.MaxContributorChars');
    }
    return Object.keys(briefing).length > 0 ? { Briefing: briefing } : null;
}

function extractTierValue(layer: TasksLimitsOverride, key: TasksLimitsKeyPath): number | undefined {
    if (key.startsWith('RunawayGuards.')) {
        const subKey = key.slice('RunawayGuards.'.length) as TasksRunawayGuardKey;
        return layer.RunawayGuards?.[subKey];
    }
    if (key.startsWith('ResourceGuards.')) {
        const subKey = key.slice('ResourceGuards.'.length) as TasksResourceGuardKey;
        return layer.ResourceGuards?.[subKey];
    }
    if (key.startsWith('Briefing.')) {
        const subKey = key.slice('Briefing.'.length) as TasksBriefingLimitKey;
        return layer.Briefing?.[subKey];
    }
    const subKey = key.slice('Tuning.'.length) as TasksTuningKey;
    return layer.Tuning?.[subKey];
}

function assignOverrideValue(target: TasksLimitsOverride, key: TasksLimitsKeyPath, value: number): void {
    if (key.startsWith('RunawayGuards.')) {
        const subKey = key.slice('RunawayGuards.'.length) as TasksRunawayGuardKey;
        target.RunawayGuards = target.RunawayGuards ?? {};
        target.RunawayGuards[subKey] = value;
        return;
    }
    if (key.startsWith('ResourceGuards.')) {
        const subKey = key.slice('ResourceGuards.'.length) as TasksResourceGuardKey;
        target.ResourceGuards = target.ResourceGuards ?? {};
        target.ResourceGuards[subKey] = value;
        return;
    }
    if (key.startsWith('Briefing.')) {
        const subKey = key.slice('Briefing.'.length) as TasksBriefingLimitKey;
        target.Briefing = target.Briefing ?? {};
        target.Briefing[subKey] = value;
        return;
    }
    const subKey = key.slice('Tuning.'.length) as TasksTuningKey;
    target.Tuning = target.Tuning ?? {};
    target.Tuning[subKey] = value;
}

function assignResolvedValue(target: TasksLimitsConfig, key: TasksLimitsKeyPath, value: number): void {
    if (key.startsWith('RunawayGuards.')) {
        const subKey = key.slice('RunawayGuards.'.length) as TasksRunawayGuardKey;
        target.RunawayGuards[subKey] = value;
        return;
    }
    if (key.startsWith('ResourceGuards.')) {
        const subKey = key.slice('ResourceGuards.'.length) as TasksResourceGuardKey;
        target.ResourceGuards[subKey] = value;
        return;
    }
    if (key.startsWith('Briefing.')) {
        const subKey = key.slice('Briefing.'.length) as TasksBriefingLimitKey;
        target.Briefing[subKey] = value;
        return;
    }
    const subKey = key.slice('Tuning.'.length) as TasksTuningKey;
    target.Tuning[subKey] = value;
}

function enforceCeilingConsistency(
    resolved: TasksLimitsConfig,
    provenance: Record<TasksLimitsKeyPath, TasksLimitsKeyProvenance>,
    clampedSet: Set<TasksLimitsKeyPath>,
): void {
    const pairs: Array<readonly [TasksLimitsKeyPath, TasksLimitsKeyPath]> = [
        ['Briefing.DefaultBriefingMaxItems', 'RunawayGuards.BriefingMaxItemsCeiling'],
        ['Briefing.DefaultBriefingHorizonDays', 'RunawayGuards.BriefingMaxHorizonDays'],
        ['Briefing.DefaultMeetingsBriefingLookbackDays', 'RunawayGuards.BriefingMaxLookbackDays'],
        ['Briefing.DefaultWorkReportsBriefingLookbackDays', 'RunawayGuards.BriefingWorkReportsMaxLookbackDays'],
        ['ResourceGuards.FindTasksDefaultMaxRows', 'ResourceGuards.FindTasksMaxRowsCeiling'],
        ['ResourceGuards.FindWorkReportsDefaultMaxRows', 'ResourceGuards.FindWorkReportsMaxRowsCeiling'],
        ['ResourceGuards.ReconcileTimesheetApprovalsDefaultMaxRows', 'ResourceGuards.ReconcileTimesheetApprovalsMaxRowsCeiling'],
        ['Tuning.FindMeetingsDefaultLimit', 'RunawayGuards.FindMeetingsMaxLimit'],
        ['Tuning.FindMeetingsDefaultDaysAhead', 'RunawayGuards.FindMeetingsMaxHorizonDays'],
        ['Tuning.FindSimilarDefaultWindowDays', 'RunawayGuards.FindSimilarTasksMaxWindowDays'],
    ];

    for (const [defaultKey, ceilingKey] of pairs) {
        const defaultVal = provenance[defaultKey].Value;
        const ceilingVal = provenance[ceilingKey].Value;
        if (defaultVal > ceilingVal) {
            assignResolvedValue(resolved, defaultKey, ceilingVal);
            provenance[defaultKey].Value = ceilingVal;
            provenance[defaultKey].WasClampedToSafetyCeiling = true;
            clampedSet.add(defaultKey);
        }
    }
}

/**
 * Validates a resolved {@link TasksLimitsConfig} for safety-bound and default-vs-ceiling invariants.
 */
export function ValidateTasksLimitsConfig(config: TasksLimitsConfig): TasksLimitsValidationResult {
    const issues: TasksLimitsValidationIssue[] = [];

    for (const key of TASKS_LIMITS_KEY_PATHS) {
        const val = extractTierValue(config, key);
        const bounds = TASKS_LIMIT_SAFETY_BOUNDS[key];
        if (val === undefined || !Number.isFinite(val) || !Number.isInteger(val) || val < bounds.min || val > bounds.max) {
            issues.push({
                Key: key,
                Message: `${key} must be an integer between ${bounds.min} and ${bounds.max} (got ${String(val)}).`,
            });
        }
    }

    if (config.Briefing.DefaultBriefingMaxItems > config.RunawayGuards.BriefingMaxItemsCeiling) {
        issues.push({
            Key: 'Briefing.DefaultBriefingMaxItems',
            Message: 'DefaultBriefingMaxItems cannot exceed BriefingMaxItemsCeiling.',
        });
    }
    if (config.Briefing.DefaultBriefingHorizonDays > config.RunawayGuards.BriefingMaxHorizonDays) {
        issues.push({
            Key: 'Briefing.DefaultBriefingHorizonDays',
            Message: 'DefaultBriefingHorizonDays cannot exceed BriefingMaxHorizonDays.',
        });
    }
    if (config.Briefing.DefaultMeetingsBriefingLookbackDays > config.RunawayGuards.BriefingMaxLookbackDays) {
        issues.push({
            Key: 'Briefing.DefaultMeetingsBriefingLookbackDays',
            Message: 'DefaultMeetingsBriefingLookbackDays cannot exceed BriefingMaxLookbackDays.',
        });
    }
    if (config.Briefing.DefaultWorkReportsBriefingLookbackDays > config.RunawayGuards.BriefingWorkReportsMaxLookbackDays) {
        issues.push({
            Key: 'Briefing.DefaultWorkReportsBriefingLookbackDays',
            Message: 'DefaultWorkReportsBriefingLookbackDays cannot exceed BriefingWorkReportsMaxLookbackDays.',
        });
    }
    if (config.ResourceGuards.FindTasksDefaultMaxRows > config.ResourceGuards.FindTasksMaxRowsCeiling) {
        issues.push({
            Key: 'ResourceGuards.FindTasksDefaultMaxRows',
            Message: 'FindTasksDefaultMaxRows cannot exceed FindTasksMaxRowsCeiling.',
        });
    }
    if (config.ResourceGuards.FindWorkReportsDefaultMaxRows > config.ResourceGuards.FindWorkReportsMaxRowsCeiling) {
        issues.push({
            Key: 'ResourceGuards.FindWorkReportsDefaultMaxRows',
            Message: 'FindWorkReportsDefaultMaxRows cannot exceed FindWorkReportsMaxRowsCeiling.',
        });
    }
    if (config.ResourceGuards.ReconcileTimesheetApprovalsDefaultMaxRows > config.ResourceGuards.ReconcileTimesheetApprovalsMaxRowsCeiling) {
        issues.push({
            Key: 'ResourceGuards.ReconcileTimesheetApprovalsDefaultMaxRows',
            Message: 'ReconcileTimesheetApprovalsDefaultMaxRows cannot exceed ReconcileTimesheetApprovalsMaxRowsCeiling.',
        });
    }
    if (config.Tuning.FindMeetingsDefaultLimit > config.RunawayGuards.FindMeetingsMaxLimit) {
        issues.push({
            Key: 'Tuning.FindMeetingsDefaultLimit',
            Message: 'FindMeetingsDefaultLimit cannot exceed FindMeetingsMaxLimit.',
        });
    }
    if (config.Tuning.FindMeetingsDefaultDaysAhead > config.RunawayGuards.FindMeetingsMaxHorizonDays) {
        issues.push({
            Key: 'Tuning.FindMeetingsDefaultDaysAhead',
            Message: 'FindMeetingsDefaultDaysAhead cannot exceed FindMeetingsMaxHorizonDays.',
        });
    }
    if (config.Tuning.FindSimilarDefaultWindowDays > config.RunawayGuards.FindSimilarTasksMaxWindowDays) {
        issues.push({
            Key: 'Tuning.FindSimilarDefaultWindowDays',
            Message: 'FindSimilarDefaultWindowDays cannot exceed FindSimilarTasksMaxWindowDays.',
        });
    }

    return { Valid: issues.length === 0, Issues: issues };
}

const TASKS_LIMITS_SINGLETON_KEY = '__mj_biz_apps_tasks_TasksLimitsResolver__';
let fallbackTasksLimitsResolver: TasksLimitsResolver | null = null;
let customMjLimitsResolverOverride: MjLimitsResolverInstanceLike | null = null;

type RuntimeDynamicValue = object | string | number | boolean | symbol | bigint | null | undefined;

function readDynamicMember(target: object, memberName: string): RuntimeDynamicValue {
    const val: RuntimeDynamicValue = Reflect.get(target, memberName);
    return val;
}

function isObjectLike(value: RuntimeDynamicValue): value is object {
    return value !== null && (typeof value === 'object' || typeof value === 'function');
}

function isRecordObject(value: RuntimeDynamicValue): value is object {
    return value !== null && typeof value === 'object';
}

function readFinitePositiveNumber(value: RuntimeDynamicValue): number | undefined {
    return typeof value === 'number' && Number.isFinite(value) && value > 0 ? value : undefined;
}

function readProvenanceIsOverridden(provenanceObj: object, keys: readonly string[]): boolean {
    for (const key of keys) {
        const entry = readDynamicMember(provenanceObj, key);
        if (isRecordObject(entry) && readDynamicMember(entry, 'IsOverridden') === true) {
            return true;
        }
    }
    return false;
}

function isMjLimitsResolverInstanceLike(candidate: object): candidate is MjLimitsResolverInstanceLike {
    return (
        typeof readDynamicMember(candidate, 'GetMjConfigLimits') === 'function' &&
        typeof readDynamicMember(candidate, 'Resolve') === 'function'
    );
}

/**
 * Safely reads `@memberjunction/core`'s `LimitsConfigResolver.Instance` (or global-store
 * fallback) without casting `typeof mjCore` directly, avoiding `TS2352` if `MJ` `next`
 * evolves `LimitsConfigResolver`'s TypeScript signatures.
 */
export function ReadOptionalMjLimitsResolverInstance(): MjLimitsResolverInstanceLike | undefined {
    if (customMjLimitsResolverOverride) {
        return customMjLimitsResolverOverride;
    }
    if (Object.prototype.hasOwnProperty.call(mjCore, 'LimitsConfigResolver')) {
        const resolverExport = readDynamicMember(mjCore, 'LimitsConfigResolver');
        if (isObjectLike(resolverExport)) {
            const resolverInstance = readDynamicMember(resolverExport, 'Instance');
            if (isRecordObject(resolverInstance) && isMjLimitsResolverInstanceLike(resolverInstance)) {
                return resolverInstance;
            }
        }
    }
    if (
        Object.prototype.hasOwnProperty.call(mjGlobal, 'GetGlobalObjectStore') &&
        typeof mjGlobal.GetGlobalObjectStore === 'function'
    ) {
        const store = mjGlobal.GetGlobalObjectStore();
        if (store && typeof store === 'object') {
            const candidate = store['__mj_LimitsConfigResolver__'] ?? store['LimitsConfigResolver'];
            if (candidate && typeof candidate === 'object' && isMjLimitsResolverInstanceLike(candidate)) {
                return candidate;
            }
        }
    }
    return undefined;
}

function getMjLimitsConfigSafely(): TasksMjLimitsOverride | null {
    const resolver = ReadOptionalMjLimitsResolverInstance();
    return resolver ? resolver.GetMjConfigLimits() : null;
}

function normalizeMjLimitsResolutionSnapshot(
    rawSnapshot: object,
    inputMjConfig: TasksMjLimitsOverride | undefined,
    fallbackIso: string,
): MjLimitsResolutionSnapshot {
    const rawLimits = readDynamicMember(rawSnapshot, 'Limits');
    const limitsObj = isRecordObject(rawLimits) ? rawLimits : undefined;
    const rawBriefing = limitsObj ? readDynamicMember(limitsObj, 'Briefing') : undefined;
    const briefingObj = isRecordObject(rawBriefing) ? rawBriefing : undefined;

    const timeoutFromMj =
        (limitsObj ? readFinitePositiveNumber(readDynamicMember(limitsObj, 'BriefingContributorTimeoutMs')) : undefined) ??
        (briefingObj ? readFinitePositiveNumber(readDynamicMember(briefingObj, 'ContributorTimeoutMs')) : undefined);
    const maxCharsFromMj =
        (limitsObj ? readFinitePositiveNumber(readDynamicMember(limitsObj, 'BriefingMaxContributorChars')) : undefined) ??
        (briefingObj ? readFinitePositiveNumber(readDynamicMember(briefingObj, 'MaxContributorChars')) : undefined);

    const rawProvenance = readDynamicMember(rawSnapshot, 'Provenance');
    const provenanceObj = isRecordObject(rawProvenance) ? rawProvenance : undefined;
    const timeoutOverridden = provenanceObj
        ? readProvenanceIsOverridden(provenanceObj, ['BriefingContributorTimeoutMs', 'Briefing.ContributorTimeoutMs'])
        : false;
    const maxCharsOverridden = provenanceObj
        ? readProvenanceIsOverridden(provenanceObj, ['BriefingMaxContributorChars', 'Briefing.MaxContributorChars'])
        : false;

    const rawIso = readDynamicMember(rawSnapshot, 'ResolvedAtISO');
    const resolvedAtISO = typeof rawIso === 'string' && rawIso.length > 0 ? rawIso : fallbackIso;

    return {
        Limits: {
            BriefingContributorTimeoutMs:
                timeoutFromMj ??
                inputMjConfig?.BriefingContributorTimeoutMs ??
                CODE_FALLBACK_TASKS_LIMITS.Briefing.ContributorTimeoutMs,
            BriefingMaxContributorChars:
                maxCharsFromMj ??
                inputMjConfig?.BriefingMaxContributorChars ??
                CODE_FALLBACK_TASKS_LIMITS.Briefing.MaxContributorChars,
        },
        Provenance: {
            BriefingContributorTimeoutMs: {
                IsOverridden: timeoutOverridden || inputMjConfig?.BriefingContributorTimeoutMs !== undefined,
            },
            BriefingMaxContributorChars: {
                IsOverridden: maxCharsOverridden || inputMjConfig?.BriefingMaxContributorChars !== undefined,
            },
        },
        ResolvedAtISO: resolvedAtISO,
    };
}

function resolveMjLimitsSafely(
    input?: { MjConfig?: TasksMjLimitsOverride },
    options?: { ResolvedAtISO?: string },
): MjLimitsResolutionSnapshot {
    const fallbackIso = options?.ResolvedAtISO ?? new Date().toISOString();
    const resolver = ReadOptionalMjLimitsResolverInstance();
    if (resolver) {
        const rawSnapshot = resolver.Resolve(input, options);
        if (isRecordObject(rawSnapshot)) {
            return normalizeMjLimitsResolutionSnapshot(rawSnapshot, input?.MjConfig, fallbackIso);
        }
    }
    return {
        Limits: {
            BriefingContributorTimeoutMs:
                input?.MjConfig?.BriefingContributorTimeoutMs ?? CODE_FALLBACK_TASKS_LIMITS.Briefing.ContributorTimeoutMs,
            BriefingMaxContributorChars:
                input?.MjConfig?.BriefingMaxContributorChars ?? CODE_FALLBACK_TASKS_LIMITS.Briefing.MaxContributorChars,
        },
        Provenance: {
            BriefingContributorTimeoutMs: { IsOverridden: input?.MjConfig?.BriefingContributorTimeoutMs !== undefined },
            BriefingMaxContributorChars: { IsOverridden: input?.MjConfig?.BriefingMaxContributorChars !== undefined },
        },
        ResolvedAtISO: fallbackIso,
    };
}

/**
 * Hierarchical resolver for BizApps Tasks limits backed by `@memberjunction/global`'s
 * global object store and integrated with `@memberjunction/core`'s {@link LimitsConfigResolver}.
 */
export class TasksLimitsResolver {
    private registeredAppConfig: TasksLimitsOverride | null = null;
    private registeredAppConfigClamped: Set<TasksLimitsKeyPath> = new Set();
    private cachedDefaultResult: TasksLimitsResolutionResult | null = null;
    private cachedMjConfigRef: TasksMjLimitsOverride | null = null;

    public constructor() {}

    /** Returns the process-wide singleton {@link TasksLimitsResolver}. */
    public static get Instance(): TasksLimitsResolver {
        if (
            Object.prototype.hasOwnProperty.call(mjGlobal, 'GetGlobalObjectStore') &&
            typeof mjGlobal.GetGlobalObjectStore === 'function'
        ) {
            const store = mjGlobal.GetGlobalObjectStore();
            if (store && typeof store === 'object') {
                const existing = store[TASKS_LIMITS_SINGLETON_KEY];
                if (existing instanceof TasksLimitsResolver) {
                    return existing;
                }
                const created = new TasksLimitsResolver();
                store[TASKS_LIMITS_SINGLETON_KEY] = created;
                return created;
            }
        }
        if (!fallbackTasksLimitsResolver) {
            fallbackTasksLimitsResolver = new TasksLimitsResolver();
        }
        return fallbackTasksLimitsResolver;
    }

    /**
     * Registers an explicit {@link MjLimitsResolverInstanceLike} bridge (or `null` to restore
     * automatic `@memberjunction/core` `LimitsConfigResolver` lookup) and invalidates the
     * memoized snapshot.
     */
    public static SetMjLimitsResolver(resolver: MjLimitsResolverInstanceLike | null): void {
        customMjLimitsResolverOverride = resolver;
        TasksLimitsResolver.Instance.InvalidateCache();
    }

    /**
     * Convenience static entry point delegating to {@link TasksLimitsResolver.Instance.Resolve}.
     */
    public static Resolve(
        input?: TasksLimitsResolutionInput,
        options?: TasksLimitsResolveOptions,
    ): TasksLimitsResolutionResult {
        return TasksLimitsResolver.Instance.Resolve(input, options);
    }

    /**
     * Registers Tier 4 (`AppConfig`) overrides for BizApps Tasks limits.
     * Invalid or non-positive values are ignored during normalization; oversized integers are clamped.
     */
    public RegisterConfigOverrides(overrides: TasksLimitsOverride | TasksLimitsJsonValue | null): void {
        if (overrides === null) {
            this.registeredAppConfig = null;
            this.registeredAppConfigClamped = new Set();
            this.cachedDefaultResult = null;
            return;
        }
        const sanitized = isJsonObject(overrides)
            ? normalizeTasksLimitsWithTracking(overrides)
            : sanitizeTasksLimitsWithTracking(overrides as TasksLimitsOverride);
        this.registeredAppConfig = Object.keys(sanitized.override).length > 0 ? sanitized.override : null;
        this.registeredAppConfigClamped = sanitized.clampedKeys;
        this.cachedDefaultResult = null;
    }

    /** Returns the currently registered Tier 4 (`AppConfig`) override, or `null` when unset. */
    public GetConfigOverrides(): TasksLimitsOverride | null {
        return this.registeredAppConfig;
    }

    /** Clears registered `AppConfig` overrides and invalidates the memoized snapshot. */
    public ClearConfigOverrides(): void {
        this.registeredAppConfig = null;
        this.registeredAppConfigClamped = new Set();
        this.cachedDefaultResult = null;
    }

    /** Invalidates the memoized `GetCurrentLimits()` snapshot (useful when `process.env` mutates in tests). */
    public InvalidateCache(): void {
        this.cachedDefaultResult = null;
    }

    /**
     * Fast memoized accessor returning the currently active resolved {@link TasksLimitsConfig}
     * without repeated resolution overhead when neither `LimitsConfigResolver` nor `AppConfig` changed.
     */
    public GetCurrentLimits(): TasksLimitsConfig {
        const currentMjConfig = getMjLimitsConfigSafely();
        if (this.cachedDefaultResult && this.cachedMjConfigRef === currentMjConfig) {
            return this.cachedDefaultResult.Limits;
        }
        const resolved = this.Resolve();
        this.cachedMjConfigRef = currentMjConfig;
        this.cachedDefaultResult = resolved;
        return resolved.Limits;
    }

    /**
     * Resolves all Tasks limits across the 5-tier precedence chain
     * (`CodeFallback` -> `MjLimitsConfig` -> `Env` -> `AppConfig` -> `RuntimeOverride`),
     * rejecting invalid/non-positive overrides, clamping oversized overrides to safety ceilings,
     * and tracking full per-key provenance.
     */
    public Resolve(
        input: TasksLimitsResolutionInput = {},
        options: TasksLimitsResolveOptions = {},
    ): TasksLimitsResolutionResult {
        const mjResult = resolveMjLimitsSafely(
            input.MjLimits ? { MjConfig: input.MjLimits } : undefined,
            options.ResolvedAtISO ? { ResolvedAtISO: options.ResolvedAtISO } : undefined,
        );
        const mjOverrodeBriefing =
            mjResult.Provenance['BriefingContributorTimeoutMs']?.IsOverridden === true ||
            mjResult.Provenance['BriefingMaxContributorChars']?.IsOverridden === true ||
            input.MjLimits !== undefined;

        const codeFallbackLayer = input.CodeFallback
            ? sanitizeTasksLimitsWithTracking(input.CodeFallback)
            : { override: {}, clampedKeys: new Set<TasksLimitsKeyPath>() };

        const mjClamped = new Set<TasksLimitsKeyPath>();
        const mjBridgeLayer = buildMjBridgeLayer(mjResult.Limits, mjOverrodeBriefing, mjClamped);

        const envSource =
            input.Env !== undefined
                ? input.Env
                : options.UseProcessEnv === false
                    ? null
                    : readProcessEnvSafely();
        const envLayer = parseTasksLimitsFromEnvWithTracking(envSource);

        const appLayer =
            input.AppConfig !== undefined
                ? sanitizeTasksLimitsWithTracking(input.AppConfig)
                : { override: this.registeredAppConfig ?? {}, clampedKeys: this.registeredAppConfigClamped };

        const runtimeLayer = input.RuntimeOverride
            ? sanitizeTasksLimitsWithTracking(input.RuntimeOverride)
            : { override: {}, clampedKeys: new Set<TasksLimitsKeyPath>() };

        const tiers: Record<TasksLimitsSourceTier, TasksLimitsOverride | null> = {
            CodeFallback: Object.keys(codeFallbackLayer.override).length > 0 ? codeFallbackLayer.override : null,
            MjLimitsConfig: mjBridgeLayer,
            Env: Object.keys(envLayer.override).length > 0 ? envLayer.override : null,
            AppConfig: Object.keys(appLayer.override).length > 0 ? appLayer.override : null,
            RuntimeOverride: Object.keys(runtimeLayer.override).length > 0 ? runtimeLayer.override : null,
        };

        const tierClamped: Record<TasksLimitsSourceTier, Set<TasksLimitsKeyPath>> = {
            CodeFallback: codeFallbackLayer.clampedKeys,
            MjLimitsConfig: mjClamped,
            Env: envLayer.clampedKeys,
            AppConfig: appLayer.clampedKeys,
            RuntimeOverride: runtimeLayer.clampedKeys,
        };

        const defaults = cloneDefaultTasksLimits();
        const resolvedLimits = cloneDefaultTasksLimits();
        const provenanceEntries: Array<[TasksLimitsKeyPath, TasksLimitsKeyProvenance]> = [];
        const overriddenKeys: TasksLimitsKeyPath[] = [];
        const clampedSet = new Set<TasksLimitsKeyPath>();

        for (const key of TASKS_LIMITS_KEY_PATHS) {
            const baseVal = extractTierValue(defaults, key) ?? 1;
            const tierValues: Partial<Record<TasksLimitsSourceTier, number>> = {
                CodeFallback: baseVal,
            };
            let winningValue = baseVal;
            let sourceTier: TasksLimitsSourceTier = 'CodeFallback';
            let wasClamped = false;

            for (const tier of TASKS_LIMITS_TIER_PRECEDENCE) {
                const layer = tiers[tier];
                if (!layer) continue;
                const candidate = extractTierValue(layer, key);
                if (candidate !== undefined && Number.isFinite(candidate) && candidate > 0) {
                    tierValues[tier] = candidate;
                    winningValue = candidate;
                    sourceTier = tier;
                    wasClamped = tierClamped[tier].has(key);
                }
            }

            assignResolvedValue(resolvedLimits, key, winningValue);
            const isOverridden = sourceTier !== 'CodeFallback';
            if (isOverridden) {
                overriddenKeys.push(key);
            }
            if (wasClamped) {
                clampedSet.add(key);
            }
            provenanceEntries.push([
                key,
                {
                    Key: key,
                    Value: winningValue,
                    SourceTier: sourceTier,
                    IsOverridden: isOverridden,
                    WasClampedToSafetyCeiling: wasClamped,
                    TierValues: tierValues,
                },
            ]);
        }

        const provenance = Object.fromEntries(provenanceEntries) as Record<
            TasksLimitsKeyPath,
            TasksLimitsKeyProvenance
        >;

        enforceCeilingConsistency(resolvedLimits, provenance, clampedSet);

        return {
            Limits: resolvedLimits,
            MjLimits: mjResult.Limits,
            Provenance: provenance,
            OverriddenKeys: overriddenKeys,
            ClampedKeys: [...clampedSet],
            ResolvedAtISO: options.ResolvedAtISO ?? mjResult.ResolvedAtISO,
        };
    }

    /**
     * Reads a single resolved numeric value from a resolution result by canonical key path.
     */
    public GetLimitValue(result: TasksLimitsResolutionResult, key: TasksLimitsKeyPath): number {
        return result.Provenance[key].Value;
    }
}
