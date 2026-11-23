import {
    IMetadataProvider,
    IRunViewProvider,
    LogError,
    Metadata,
    RunView,
    RunViewParams,
    RunViewResult,
    UserInfo,
    WellKnownUserSource,
} from '@memberjunction/core';
import type { MJAIAgentEntityExtended } from '@memberjunction/ai-core-plus';
import { AgentRunner } from '@memberjunction/ai-agents';
import { EscapeSQLString, IsValidUUID, UUIDsEqual } from '@memberjunction/global';
import {
    AggregateProjectFreeBusy,
    AssertFreeBusyPromptPayloadIsClean,
    BuildAssigneeFreeBusySummary,
    EvaluateProjectRiskCadence,
    ParseProjectRiskAgentOutput,
    TasksLimitsResolver,
    type AssigneeFreeBusySummary,
    type BlockedDependencyEvidence,
    type BlockedDependencyEvidenceItem,
    type CheckInEvidenceItem,
    type MLBreachSignal,
    type OverdueItemsEvidence,
    type OverdueTaskEvidenceItem,
    type ProjectCheckInHealthStatusValue,
    type ProjectDependencyTypeValue,
    type ProjectFreeBusyAvailability,
    type ProjectRiskAgentRawPayload,
    type ProjectRiskAssessmentRunResult,
    type ProjectRiskCadenceEvaluation,
    type ProjectRiskEvidenceBundle,
    type ProjectRiskHealthStatusValue,
    type ProjectRootTaskSnapshot,
    type ProjectSLARiskBandValue,
    type ProjectTaskPriorityValue,
    type ProjectTaskStatusValue,
    type RawFreeBusySlotInput,
    type RelatedTaskLinkEvidenceItem,
    type SubtaskEvidenceSummary,
    type SubtaskVelocityEvidence,
    type TaskCheckInEvidence,
} from '@mj-biz-apps/tasks-core';
import {
    TASK_RISK_ASSESSMENT_ENTITY,
    TaskRiskAssessmentEntity,
} from '@mj-biz-apps/tasks-entities';

export const PROJECT_RISK_ANALYST_AGENT_NAME = 'Project Risk Analyst' as const;
export const PROJECT_RISK_ANALYST_CONFIG_NAME = 'High' as const;
const MS_PER_DAY = 86_400_000;
const SCORE_PRECISION_FACTOR = 10_000;

const TASKS_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_ASSIGNMENTS_ENTITY = 'MJ_BizApps_Tasks: Task Assignments';
const TASK_DEPENDENCIES_ENTITY = 'MJ_BizApps_Tasks: Task Dependencies';
const TASK_LINKS_ENTITY = 'MJ_BizApps_Tasks: Task Links';
const TASK_CHECK_INS_ENTITY = 'MJ_BizApps_Tasks: Task Check Ins';
const PEOPLE_ENTITY = 'MJ_BizApps_Common: People';
const USERS_ENTITY = 'MJ: Users';
const AI_AGENTS_ENTITY = 'MJ: AI Agents';
const AI_AGENT_CONFIGURATIONS_ENTITY = 'MJ: AI Agent Configurations';

const ACTIVE_OPEN_STATUSES = new Set<ProjectTaskStatusValue>(['Open', 'InProgress', 'Blocked']);

/** Row shape returned by `RunView` for the root project task. */
export interface ProjectRootTaskRow {
    ID: string;
    Name: string;
    ParentID: string | null;
    RootParentID: string | null;
    Status: ProjectTaskStatusValue;
    Priority: ProjectTaskPriorityValue;
    StartedAt: string | Date | null;
    DueAt: string | Date | null;
    PercentComplete: number;
    CreatedByPersonID: string | null;
    HealthStatus: ProjectRiskHealthStatusValue | null;
    ConfidenceScore: number | null;
    ForecastCompletionDate: string | Date | null;
    PredictedSLABreachProbability: number | null;
    PredictedSLARiskBand: ProjectSLARiskBandValue | null;
    PredictedSLAScoredAt: string | Date | null;
    __mj_CreatedAt: string | Date;
}

interface SubtaskRow {
    ID: string;
    Name: string;
    Status: ProjectTaskStatusValue;
    Priority: ProjectTaskPriorityValue;
    ParentID: string | null;
    StartedAt: string | Date | null;
    DueAt: string | Date | null;
    CompletedAt: string | Date | null;
    PercentComplete: number;
    BlockedReason: string | null;
}

interface DependencyRow {
    ID: string;
    TaskID: string;
    Task: string | null;
    DependsOnTaskID: string;
    DependsOnTask: string | null;
    DependencyType: ProjectDependencyTypeValue;
}

interface TaskLinkRow {
    ID: string;
    TaskID: string;
    EntityID: string;
    Entity: string | null;
    RecordID: string;
}

interface CheckInRow {
    ID: string;
    TaskID: string;
    CheckInAt: string | Date;
    HealthStatus: ProjectCheckInHealthStatusValue;
    ConfidenceScore: number | null;
    PercentComplete: number | null;
    Summary: string;
    Blockers: string | null;
}

interface AssignmentRow {
    ID: string;
    TaskID: string;
    AssigneeEntityID: string;
    AssigneeEntity: string | null;
    AssigneeRecordID: string;
    Role: string | null;
    Status: string;
}

interface PersonContactRow {
    ID: string;
    Email: string | null;
    LinkedUserID: string | null;
}

interface UserRecordRow {
    ID: string;
    Name: string;
    FirstName: string | null;
    LastName: string | null;
    Title: string | null;
    Email: string;
    Type: string;
    IsActive: boolean;
    LinkedRecordType: 'None' | 'Employee' | 'Other' | null;
    EmployeeID: number | null;
    LinkedEntityID: string | null;
    LinkedEntityRecordID: string | null;
}

interface LatestAssessmentRow {
    ID: string;
    AssessedAt: string | Date;
}

interface AgentRecordRow {
    ID: string;
    Name: string;
    Status: string;
    DefaultPromptEffortLevel: number | null;
}

interface AgentConfigurationRow {
    ID: string;
    Name: string;
    AIConfigurationID: string;
    IsDefault: boolean;
    Priority: number;
    Status: string;
}

/** Assignee target passed to a calendar free/busy provider. */
export interface ProjectAssigneeScheduleTarget {
    PersonID: string | null;
    UserID: string | null;
    Email: string | null;
}

/** Raw calendar free/busy slots returned by a calendar provider for one assignee. */
export interface ProjectAssigneeRawFreeBusy {
    PersonID: string | null;
    UserID: string | null;
    Slots: readonly RawFreeBusySlotInput[];
}

/** Adapter querying assignee calendar availability strictly as free/busy intervals. */
export type ProjectFreeBusyProvider = (input: {
    Assignees: readonly ProjectAssigneeScheduleTarget[];
    WindowStart: Date;
    WindowEnd: Date;
    OwnerUser: UserInfo;
}) => Promise<readonly ProjectAssigneeRawFreeBusy[]>;

/** Adapter resolving the ML SLA breach probability score for a project root task. */
export type MLBreachScoreProvider = (input: {
    RootTask: ProjectRootTaskRow;
    OwnerUser: UserInfo;
}) => Promise<MLBreachSignal | null>;

/** Adapter resolving the active project owner `UserInfo` for a project root task. */
export type ProjectOwnerUserResolver = (input: {
    RootTask: ProjectRootTaskRow;
    Provider: IMetadataProvider;
    RunViewProvider: IRunViewProvider | null;
    LookupContextUser: UserInfo;
}) => Promise<UserInfo>;

/** Serialized prompt variable map passed into the `Tasks: Project Risk Analyst` prompt. */
export interface ProjectRiskPromptData {
    projectJson: string;
    cadenceJson: string;
    velocityJson: string;
    blockedDependenciesJson: string;
    checkInsJson: string;
    overdueItemsJson: string;
    freeBusyJson: string;
    mlBreachJson: string;
}

/** Input passed to {@link ProjectRiskAgentExecutor}. */
export interface ProjectRiskAgentExecutionInput {
    AgentName: string;
    PreferredConfigurationName: typeof PROJECT_RISK_ANALYST_CONFIG_NAME;
    OwnerUser: UserInfo;
    RootTaskID: string;
    Evidence: ProjectRiskEvidenceBundle;
    PromptData: ProjectRiskPromptData;
}

/** Result returned by {@link ProjectRiskAgentExecutor}. */
export interface ProjectRiskAgentExecutionResult {
    Success: boolean;
    Payload: string | ProjectRiskAgentRawPayload | null;
    AgentRunID: string | null;
    PromptTokens: number | null;
    CompletionTokens: number | null;
    TotalCostUSD: number | null;
    ErrorMessage?: string | null;
}

/** Adapter invoking the `Project Risk Analyst` AI agent under the project owner's `UserInfo`. */
export type ProjectRiskAgentExecutor = (
    input: ProjectRiskAgentExecutionInput,
) => Promise<ProjectRiskAgentExecutionResult>;

/** Options accepted by {@link ProjectRiskAnalystService.AssessProjectRisk}. */
export interface AssessProjectRiskOptions {
    TaskID: string;
    Provider?: IMetadataProvider;
    RunViewProvider?: IRunViewProvider | null;
    CallerContextUser?: UserInfo;
    ExplicitOwnerUserID?: string | null;
    OwnerUserResolver?: ProjectOwnerUserResolver;
    FreeBusyProvider?: ProjectFreeBusyProvider;
    MLBreachScoreProvider?: MLBreachScoreProvider;
    AgentExecutor?: ProjectRiskAgentExecutor;
    /** When `false`, skips evaluation if the active cadence cooldown window has not elapsed or task is terminal. */
    Force?: boolean;
    /** Deterministic clock override for tests. */
    Now?: Date;
}

interface ProviderWithRunViews extends IRunViewProvider {
    RunViews: <T>(params: RunViewParams[], contextUser?: UserInfo) => Promise<RunViewResult<T>[]>;
}

function toIsoOrNull(value: Date | string | null | undefined): string | null {
    if (value == null) return null;
    const d = value instanceof Date ? value : new Date(value);
    return Number.isNaN(d.getTime()) ? null : d.toISOString();
}

function toTimestampMs(value: Date | string | null | undefined): number | null {
    if (value == null) return null;
    const d = value instanceof Date ? value : new Date(value);
    const ms = d.getTime();
    return Number.isFinite(ms) ? ms : null;
}

function buildTaskLink(taskId: string): string {
    return `/resource/record/MJ_BizApps_Tasks%3A%20Tasks/${encodeURIComponent(taskId)}`;
}

function clampProbability(prob: number | null | undefined): number | null {
    if (prob == null || !Number.isFinite(prob)) return null;
    const clamped = Math.max(0, Math.min(1, prob));
    return Math.round(clamped * SCORE_PRECISION_FACTOR) / SCORE_PRECISION_FACTOR;
}

function resolveRunViewProvider(
    explicitRvProvider: IRunViewProvider | null | undefined,
    mdProvider: IMetadataProvider,
): IRunViewProvider | null {
    if (explicitRvProvider) {
        return explicitRvProvider;
    }
    const candidate = mdProvider as Partial<IRunViewProvider>;
    if (typeof candidate.RunView === 'function') {
        return candidate as IRunViewProvider;
    }
    return null;
}

async function runBatchedQueries<T>(
    rv: RunView,
    rvProvider: IRunViewProvider | null,
    queries: RunViewParams[],
    contextUser: UserInfo,
): Promise<RunViewResult<T>[]> {
    if (queries.length === 0) return [];
    const candidate = rvProvider as Partial<ProviderWithRunViews> | null;
    if (candidate && typeof candidate.RunViews === 'function') {
        return candidate.RunViews<T>(queries, contextUser);
    }
    return Promise.all(queries.map((q) => rv.RunView<T>(q, contextUser)));
}

function chunkIds(ids: readonly string[], chunkSize: number): string[][] {
    const out: string[][] = [];
    const step = Math.max(1, chunkSize);
    for (let i = 0; i < ids.length; i += step) {
        out.push(ids.slice(i, i + step));
    }
    return out;
}

function uniqueValidUuids(ids: readonly (string | null | undefined)[]): string[] {
    const seen = new Map<string, string>();
    for (const id of ids) {
        if (id && IsValidUUID(id)) {
            const key = id.toLowerCase();
            if (!seen.has(key)) {
                seen.set(key, id);
            }
        }
    }
    return [...seen.values()];
}

function buildUserInfoFromRow(provider: IMetadataProvider, row: UserRecordRow): UserInfo {
    return new UserInfo(provider, {
        ID: row.ID,
        Name: row.Name,
        FirstName: row.FirstName,
        LastName: row.LastName,
        Title: row.Title,
        Email: row.Email,
        Type: row.Type,
        IsActive: row.IsActive,
        LinkedRecordType: row.LinkedRecordType,
        EmployeeID: row.EmployeeID,
        LinkedEntityID: row.LinkedEntityID,
        LinkedEntityRecordID: row.LinkedEntityRecordID,
    });
}

function extractPromptTokens(agentRun: { TotalPromptTokensUsedRollup?: number | null; TotalPromptTokensUsed?: number | null } | null | undefined): number | null {
    if (!agentRun) return null;
    if (typeof agentRun.TotalPromptTokensUsedRollup === 'number') {
        return agentRun.TotalPromptTokensUsedRollup;
    }
    if (typeof agentRun.TotalPromptTokensUsed === 'number') {
        return agentRun.TotalPromptTokensUsed;
    }
    return null;
}

function extractCompletionTokens(agentRun: { TotalCompletionTokensUsedRollup?: number | null; TotalCompletionTokensUsed?: number | null } | null | undefined): number | null {
    if (!agentRun) return null;
    if (typeof agentRun.TotalCompletionTokensUsedRollup === 'number') {
        return agentRun.TotalCompletionTokensUsedRollup;
    }
    if (typeof agentRun.TotalCompletionTokensUsed === 'number') {
        return agentRun.TotalCompletionTokensUsed;
    }
    return null;
}

function extractTotalCost(agentRun: { TotalCostRollup?: number | null; TotalCost?: number | null } | null | undefined): number | null {
    if (!agentRun) return null;
    if (typeof agentRun.TotalCostRollup === 'number') {
        return agentRun.TotalCostRollup;
    }
    if (typeof agentRun.TotalCost === 'number') {
        return agentRun.TotalCost;
    }
    return null;
}

/**
 * Server-side runtime orchestrator for the `Project Risk Analyst` AI agent.
 *
 * Enforces:
 * 1. Project owner user execution context (`OwnerUser` `UserInfo`) for all evidence `RunView`
 *    queries, agent runs, and persisted `Task Risk Assessments`.
 * 2. Batched `RunView` / `RunViews` evidence collection (`ResultType: 'simple'`, zero N+1 loops)
 *    for subtask velocity, blocked dependencies, check-ins, and overdue items.
 * 3. Strict calendar free/busy privacy boundary (sanitizing and verifying zero event subject,
 *    body, title, description, location, or attendee exposure).
 * 4. Explicit ML breach probability integration alongside qualitative and schedule signals.
 * 5. Deterministic weekly-to-daily timeline cadence escalation in the final 20% of the timeline.
 */
export class ProjectRiskAnalystService {
    private static readonly inFlightByRootTask = new Map<string, Promise<ProjectRiskAssessmentRunResult>>();

    /**
     * Evaluates risk for the project root task containing `options.TaskID`, persisting a
     * `Task Risk Assessments` record and triggering Slice 1 root task synchronization.
     * Deduplicates concurrent calls for the same task ID.
     */
    public async AssessProjectRisk(options: AssessProjectRiskOptions): Promise<ProjectRiskAssessmentRunResult> {
        if (!options.TaskID || !IsValidUUID(options.TaskID)) {
            throw new Error(`ProjectRiskAnalystService: invalid TaskID '${options.TaskID}'.`);
        }

        const dedupKey = options.TaskID.trim().toLowerCase();
        const existingInFlight = ProjectRiskAnalystService.inFlightByRootTask.get(dedupKey);
        if (existingInFlight) {
            return existingInFlight;
        }

        const runPromise = this.executeAssessProjectRisk(options).finally(() => {
            if (ProjectRiskAnalystService.inFlightByRootTask.get(dedupKey) === runPromise) {
                ProjectRiskAnalystService.inFlightByRootTask.delete(dedupKey);
            }
        });
        ProjectRiskAnalystService.inFlightByRootTask.set(dedupKey, runPromise);
        return runPromise;
    }

    /**
     * Evaluates deterministic review cadence (`Weekly` vs `Daily` in final 20% / overdue)
     * for a project root task without running the AI agent.
     */
    public EvaluateCadence(
        rootTask: Pick<ProjectRootTaskRow, 'Status' | 'StartedAt' | '__mj_CreatedAt' | 'DueAt'>,
        latestAssessedAt: Date | string | null | undefined,
        now: Date = new Date(),
    ): ProjectRiskCadenceEvaluation {
        return EvaluateProjectRiskCadence({
            TaskStatus: rootTask.Status,
            StartedAt: rootTask.StartedAt,
            CreatedAt: rootTask.__mj_CreatedAt,
            DueAt: rootTask.DueAt,
            LatestAssessedAt: latestAssessedAt,
            Now: now,
        });
    }

    private async executeAssessProjectRisk(
        options: AssessProjectRiskOptions,
    ): Promise<ProjectRiskAssessmentRunResult> {
        const provider = options.Provider ?? Metadata.Provider;
        const rvProvider = resolveRunViewProvider(options.RunViewProvider, provider);
        const now = options.Now ?? new Date();
        const force = options.Force ?? true;

        const lookupUser = await this.resolveBootstrapLookupUser(options.CallerContextUser, provider);
        const rootTask = await this.loadRootProjectTask(options.TaskID, rvProvider, lookupUser);

        const ownerUser = options.OwnerUserResolver
            ? await options.OwnerUserResolver({
                  RootTask: rootTask,
                  Provider: provider,
                  RunViewProvider: rvProvider,
                  LookupContextUser: lookupUser,
              })
            : await this.resolveProjectOwnerUser(
                  rootTask,
                  options.ExplicitOwnerUserID ?? null,
                  provider,
                  rvProvider,
                  lookupUser,
              );

        if (!ownerUser?.ID || !IsValidUUID(ownerUser.ID)) {
            throw new Error(
                `ProjectRiskAnalystService: resolved owner UserInfo for root task '${rootTask.ID}' is invalid.`,
            );
        }

        // All project evidence, cadence checks, free/busy lookups, agent runs, and entity saves
        // strictly execute under the resolved project owner's UserInfo.
        const rv = new RunView(rvProvider);
        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        const escapedRootId = EscapeSQLString(rootTask.ID);

        const [subtasksRes, latestAssessRes] = await runBatchedQueries<SubtaskRow | LatestAssessmentRow>(
            rv,
            rvProvider,
            [
                {
                    EntityName: TASKS_ENTITY,
                    ExtraFilter: `(RootParentID = '${escapedRootId}' OR ParentID = '${escapedRootId}') AND ID <> '${escapedRootId}'`,
                    Fields: [
                        'ID',
                        'Name',
                        'Status',
                        'Priority',
                        'ParentID',
                        'StartedAt',
                        'DueAt',
                        'CompletedAt',
                        'PercentComplete',
                        'BlockedReason',
                    ],
                    OrderBy: 'Sequence ASC, DueAt ASC',
                    MaxRows: limits.ResourceGuards.LargeTreeQueryMaxRows,
                    ResultType: 'simple',
                },
                {
                    EntityName: TASK_RISK_ASSESSMENT_ENTITY,
                    ExtraFilter: `TaskID = '${escapedRootId}'`,
                    OrderBy: 'AssessedAt DESC',
                    Fields: ['ID', 'AssessedAt'],
                    MaxRows: limits.ResourceGuards.DefaultLookupSingleRow,
                    ResultType: 'simple',
                },
            ],
            ownerUser,
        );

        const latestAssessment = (latestAssessRes?.Results?.[0] as LatestAssessmentRow | undefined) ?? null;
        const cadence = this.EvaluateCadence(rootTask, latestAssessment?.AssessedAt ?? null, now);

        if (!force && cadence.ShouldSkipScheduledRun) {
            return {
                Skipped: true,
                SkipReason: cadence.SkipReason,
                TaskID: rootTask.ID,
                OwnerUserID: ownerUser.ID,
                AssessmentID: null,
                AssessedAt: null,
                HealthStatus: null,
                ForecastCompletionDate: null,
                ForecastConfidence: null,
                MLBreachProbability: null,
                Risks: [],
                Summary: null,
                AgentRunID: null,
                PromptTokens: null,
                CompletionTokens: null,
                TotalCostUSD: null,
                Cadence: cadence,
                Evidence: null,
            };
        }

        const subtasks = (subtasksRes?.Success ? (subtasksRes.Results as SubtaskRow[]) : []) ?? [];
        const projectTaskIds = uniqueValidUuids([rootTask.ID, ...subtasks.map((s) => s.ID)]);

        const { dependencies, links, checkIns, assignments } = await this.fetchProjectSubResourcesBatched(
            rv,
            rvProvider,
            projectTaskIds,
            ownerUser,
        );

        const subtaskById = new Map<string, SubtaskRow | ProjectRootTaskRow>();
        subtaskById.set(rootTask.ID.toLowerCase(), rootTask);
        for (const sub of subtasks) {
            subtaskById.set(sub.ID.toLowerCase(), sub);
        }

        const missingDependencyTargets = uniqueValidUuids(
            dependencies
                .map((d) => d.DependsOnTaskID)
                .filter((id) => !subtaskById.has(id.toLowerCase())),
        );
        if (missingDependencyTargets.length > 0) {
            const externalTasks = await this.fetchTasksByIdsBatched(
                rv,
                rvProvider,
                missingDependencyTargets,
                ownerUser,
            );
            for (const ext of externalTasks) {
                subtaskById.set(ext.ID.toLowerCase(), ext);
            }
        }

        const velocity = this.buildSubtaskVelocityEvidence(subtasks, now);
        const blockedDependencies = this.buildBlockedDependencyEvidence(dependencies, links, subtaskById);
        const checkInEvidence = this.buildCheckInEvidence(checkIns);
        const overdueItems = this.buildOverdueEvidence(rootTask, subtasks, now);
        const freeBusy = await this.collectSanitizedFreeBusy(
            rv,
            rvProvider,
            assignments,
            ownerUser,
            now,
            options.FreeBusyProvider,
        );
        const mlBreach = await this.resolveMLBreachSignal(rootTask, ownerUser, options.MLBreachScoreProvider);

        const rootSnapshot: ProjectRootTaskSnapshot = {
            ID: rootTask.ID,
            Name: rootTask.Name,
            Status: rootTask.Status,
            Priority: rootTask.Priority,
            StartedAtISO: toIsoOrNull(rootTask.StartedAt ?? rootTask.__mj_CreatedAt),
            DueAtISO: toIsoOrNull(rootTask.DueAt),
            PercentComplete: rootTask.PercentComplete ?? 0,
            HealthStatus: rootTask.HealthStatus ?? null,
            ConfidenceScore: rootTask.ConfidenceScore ?? null,
            ForecastCompletionDateISO: toIsoOrNull(rootTask.ForecastCompletionDate),
            EvidenceLink: buildTaskLink(rootTask.ID),
        };

        const evidence: ProjectRiskEvidenceBundle = {
            RootTask: rootSnapshot,
            Cadence: cadence,
            Velocity: velocity,
            BlockedDependencies: blockedDependencies,
            CheckIns: checkInEvidence,
            OverdueItems: overdueItems,
            FreeBusy: freeBusy,
            MLBreach: mlBreach,
        };

        // Fail-closed privacy firewall immediately prior to prompt serialization & LLM execution.
        AssertFreeBusyPromptPayloadIsClean(evidence.FreeBusy);

        const promptData: ProjectRiskPromptData = {
            projectJson: JSON.stringify(evidence.RootTask),
            cadenceJson: JSON.stringify(evidence.Cadence),
            velocityJson: JSON.stringify(evidence.Velocity),
            blockedDependenciesJson: JSON.stringify(evidence.BlockedDependencies),
            checkInsJson: JSON.stringify(evidence.CheckIns),
            overdueItemsJson: JSON.stringify(evidence.OverdueItems),
            freeBusyJson: JSON.stringify(evidence.FreeBusy),
            mlBreachJson: JSON.stringify(evidence.MLBreach),
        };

        const execInput: ProjectRiskAgentExecutionInput = {
            AgentName: PROJECT_RISK_ANALYST_AGENT_NAME,
            PreferredConfigurationName: PROJECT_RISK_ANALYST_CONFIG_NAME,
            OwnerUser: ownerUser,
            RootTaskID: rootTask.ID,
            Evidence: evidence,
            PromptData: promptData,
        };

        const agentResult = options.AgentExecutor
            ? await options.AgentExecutor(execInput)
            : await this.executeDefaultProjectRiskAgent(execInput, provider, rvProvider);

        if (!agentResult.Success) {
            throw new Error(
                `ProjectRiskAnalystService: agent '${PROJECT_RISK_ANALYST_AGENT_NAME}' failed for task '${rootTask.ID}': ${agentResult.ErrorMessage ?? 'unknown agent execution error'}.`,
            );
        }

        const structured = ParseProjectRiskAgentOutput(agentResult.Payload);
        const assessedAt = new Date(now.getTime());

        const assessment = await provider.GetEntityObject<TaskRiskAssessmentEntity>(
            TASK_RISK_ASSESSMENT_ENTITY,
            ownerUser,
        );
        assessment.NewRecord();
        assessment.TaskID = rootTask.ID;
        assessment.AssessedAt = assessedAt;
        assessment.ForecastCompletionDate = structured.ForecastCompletionDate;
        assessment.ForecastConfidence = structured.ForecastConfidence;
        assessment.HealthStatus = structured.HealthStatus;
        assessment.MLBreachProbability = mlBreach.Probability;
        assessment.SetParsedRisks(structured.Risks);
        assessment.AgentRunID =
            agentResult.AgentRunID && IsValidUUID(agentResult.AgentRunID) ? agentResult.AgentRunID : null;
        assessment.PromptTokens = agentResult.PromptTokens;
        assessment.CompletionTokens = agentResult.CompletionTokens;
        assessment.TotalCostUSD = agentResult.TotalCostUSD;

        const saved = await assessment.Save();
        if (!saved) {
            throw new Error(
                `ProjectRiskAnalystService: failed to save Task Risk Assessment for task '${rootTask.ID}': ${assessment.LatestResult?.CompleteMessage ?? 'save returned false'}.`,
            );
        }

        return {
            Skipped: false,
            SkipReason: null,
            TaskID: rootTask.ID,
            OwnerUserID: ownerUser.ID,
            AssessmentID: assessment.ID,
            AssessedAt: assessedAt,
            HealthStatus: structured.HealthStatus,
            ForecastCompletionDate: structured.ForecastCompletionDate,
            ForecastConfidence: structured.ForecastConfidence,
            MLBreachProbability: mlBreach.Probability,
            Risks: structured.Risks,
            Summary: structured.Summary,
            AgentRunID: assessment.AgentRunID,
            PromptTokens: assessment.PromptTokens,
            CompletionTokens: assessment.CompletionTokens,
            TotalCostUSD: assessment.TotalCostUSD,
            Cadence: cadence,
            Evidence: evidence,
        };
    }

    private async resolveBootstrapLookupUser(
        callerContextUser: UserInfo | undefined,
        provider: IMetadataProvider,
    ): Promise<UserInfo> {
        if (callerContextUser?.ID && IsValidUUID(callerContextUser.ID)) {
            return callerContextUser;
        }
        const sysUser = await WellKnownUserSource.Instance.GetSystemUser(provider);
        if (sysUser?.ID && IsValidUUID(sysUser.ID)) {
            return sysUser;
        }
        throw new Error(
            'ProjectRiskAnalystService: neither CallerContextUser nor WellKnownUserSource system user is available.',
        );
    }

    private async loadRootProjectTask(
        taskId: string,
        rvProvider: IRunViewProvider | null,
        lookupUser: UserInfo,
    ): Promise<ProjectRootTaskRow> {
        const rv = new RunView(rvProvider);
        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        const taskFields = [
            'ID',
            'Name',
            'ParentID',
            'RootParentID',
            'Status',
            'Priority',
            'StartedAt',
            'DueAt',
            'PercentComplete',
            'CreatedByPersonID',
            'HealthStatus',
            'ConfidenceScore',
            'ForecastCompletionDate',
            'PredictedSLABreachProbability',
            'PredictedSLARiskBand',
            'PredictedSLAScoredAt',
            '__mj_CreatedAt',
        ];

        const initialRes = await rv.RunView<ProjectRootTaskRow>(
            {
                EntityName: TASKS_ENTITY,
                ExtraFilter: `ID = '${EscapeSQLString(taskId)}'`,
                Fields: taskFields,
                MaxRows: limits.ResourceGuards.DefaultLookupSingleRow,
                ResultType: 'simple',
            },
            lookupUser,
        );

        const task = initialRes?.Success ? initialRes.Results?.[0] : undefined;
        if (!task) {
            throw new Error(`ProjectRiskAnalystService: task '${taskId}' was not found.`);
        }

        if (!task.ParentID) {
            return task;
        }

        if (task.RootParentID && !UUIDsEqual(task.RootParentID, task.ID)) {
            const rootRes = await rv.RunView<ProjectRootTaskRow>(
                {
                    EntityName: TASKS_ENTITY,
                    ExtraFilter: `ID = '${EscapeSQLString(task.RootParentID)}'`,
                    Fields: taskFields,
                    MaxRows: limits.ResourceGuards.DefaultLookupSingleRow,
                    ResultType: 'simple',
                },
                lookupUser,
            );
            const rootCandidate = rootRes?.Success ? rootRes.Results?.[0] : undefined;
            if (rootCandidate) {
                return rootCandidate;
            }
        }

        const maxDepth = limits.RunawayGuards.MaxHierarchyDepth;
        const visited = new Set<string>([task.ID.toLowerCase()]);
        let current = task;
        for (let depth = 0; depth < maxDepth && current.ParentID; depth++) {
            const parentKey = current.ParentID.toLowerCase();
            if (visited.has(parentKey)) break;
            visited.add(parentKey);

            const parentRes = await rv.RunView<ProjectRootTaskRow>(
                {
                    EntityName: TASKS_ENTITY,
                    ExtraFilter: `ID = '${EscapeSQLString(current.ParentID)}'`,
                    Fields: taskFields,
                    MaxRows: limits.ResourceGuards.DefaultLookupSingleRow,
                    ResultType: 'simple',
                },
                lookupUser,
            );
            const parentRow = parentRes?.Success ? parentRes.Results?.[0] : undefined;
            if (!parentRow) break;
            current = parentRow;
        }
        return current;
    }

    private async resolveProjectOwnerUser(
        rootTask: ProjectRootTaskRow,
        explicitOwnerUserId: string | null,
        provider: IMetadataProvider,
        rvProvider: IRunViewProvider | null,
        lookupUser: UserInfo,
    ): Promise<UserInfo> {
        const rv = new RunView(rvProvider);
        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        let ownerUserId: string | null =
            explicitOwnerUserId && IsValidUUID(explicitOwnerUserId) ? explicitOwnerUserId : null;

        if (!ownerUserId) {
            const assignRes = await rv.RunView<AssignmentRow>(
                {
                    EntityName: TASK_ASSIGNMENTS_ENTITY,
                    ExtraFilter: `TaskID = '${EscapeSQLString(rootTask.ID)}'`,
                    Fields: ['ID', 'TaskID', 'AssigneeEntityID', 'AssigneeEntity', 'AssigneeRecordID', 'Role', 'Status'],
                    OrderBy: 'AssignedAt ASC',
                    MaxRows: limits.ResourceGuards.StandardListMaxRows,
                    ResultType: 'simple',
                },
                lookupUser,
            );
            const rootAssignments = assignRes?.Success ? (assignRes.Results ?? []) : [];
            const usersEntityId = provider.EntityByName(USERS_ENTITY)?.ID ?? null;
            const peopleEntityId = provider.EntityByName(PEOPLE_ENTITY)?.ID ?? null;

            const primaryFirst = [...rootAssignments].sort((a, b) => {
                const aPrimary = a.Role?.toLowerCase() === 'primary' ? 0 : 1;
                const bPrimary = b.Role?.toLowerCase() === 'primary' ? 0 : 1;
                return aPrimary - bPrimary;
            });

            const directUserAssignment = primaryFirst.find(
                (a) =>
                    ((usersEntityId && UUIDsEqual(a.AssigneeEntityID, usersEntityId)) ||
                        a.AssigneeEntity === USERS_ENTITY) &&
                    IsValidUUID(a.AssigneeRecordID),
            );
            if (directUserAssignment) {
                ownerUserId = directUserAssignment.AssigneeRecordID;
            } else {
                const candidatePersonIds = uniqueValidUuids([
                    ...primaryFirst
                        .filter(
                            (a) =>
                                (peopleEntityId && UUIDsEqual(a.AssigneeEntityID, peopleEntityId)) ||
                                a.AssigneeEntity === PEOPLE_ENTITY,
                        )
                        .map((a) => a.AssigneeRecordID),
                    rootTask.CreatedByPersonID,
                ]);

                if (candidatePersonIds.length > 0) {
                    const inClause = candidatePersonIds.map((id) => `'${EscapeSQLString(id)}'`).join(',');
                    const peopleRes = await rv.RunView<PersonContactRow>(
                        {
                            EntityName: PEOPLE_ENTITY,
                            ExtraFilter: `ID IN (${inClause})`,
                            Fields: ['ID', 'Email', 'LinkedUserID'],
                            MaxRows: limits.ResourceGuards.StandardListMaxRows,
                            ResultType: 'simple',
                        },
                        lookupUser,
                    );
                    const peopleRows = peopleRes?.Success ? (peopleRes.Results ?? []) : [];
                    const personById = new Map(peopleRows.map((p) => [p.ID.toLowerCase(), p]));
                    for (const pid of candidatePersonIds) {
                        const match = personById.get(pid.toLowerCase());
                        if (match?.LinkedUserID && IsValidUUID(match.LinkedUserID)) {
                            ownerUserId = match.LinkedUserID;
                            break;
                        }
                    }
                }
            }
        }

        if (!ownerUserId || !IsValidUUID(ownerUserId)) {
            throw new Error(
                `ProjectRiskAnalystService: unable to resolve project owner user for root task '${rootTask.ID}'.`,
            );
        }

        const userRes = await rv.RunView<UserRecordRow>(
            {
                EntityName: USERS_ENTITY,
                ExtraFilter: `ID = '${EscapeSQLString(ownerUserId)}'`,
                Fields: [
                    'ID',
                    'Name',
                    'FirstName',
                    'LastName',
                    'Title',
                    'Email',
                    'Type',
                    'IsActive',
                    'LinkedRecordType',
                    'EmployeeID',
                    'LinkedEntityID',
                    'LinkedEntityRecordID',
                ],
                MaxRows: limits.ResourceGuards.DefaultLookupSingleRow,
                ResultType: 'simple',
            },
            lookupUser,
        );

        const userRow = userRes?.Success ? userRes.Results?.[0] : undefined;
        if (!userRow || userRow.IsActive === false) {
            throw new Error(
                `ProjectRiskAnalystService: resolved owner user '${ownerUserId}' for root task '${rootTask.ID}' was not found or is inactive.`,
            );
        }

        return buildUserInfoFromRow(provider, userRow);
    }

    private async fetchProjectSubResourcesBatched(
        rv: RunView,
        rvProvider: IRunViewProvider | null,
        projectTaskIds: readonly string[],
        ownerUser: UserInfo,
    ): Promise<{
        dependencies: DependencyRow[];
        links: TaskLinkRow[];
        checkIns: CheckInRow[];
        assignments: AssignmentRow[];
    }> {
        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        const chunks = chunkIds(projectTaskIds, limits.ResourceGuards.SqlInClauseChunkSize);

        const dependencies: DependencyRow[] = [];
        const links: TaskLinkRow[] = [];
        const checkIns: CheckInRow[] = [];
        const assignments: AssignmentRow[] = [];

        for (const chunk of chunks) {
            const inList = chunk.map((id) => `'${EscapeSQLString(id)}'`).join(',');
            const [depsRes, linksRes, checkInsRes, assignRes] = await runBatchedQueries<
                DependencyRow | TaskLinkRow | CheckInRow | AssignmentRow
            >(
                rv,
                rvProvider,
                [
                    {
                        EntityName: TASK_DEPENDENCIES_ENTITY,
                        ExtraFilter: `TaskID IN (${inList})`,
                        Fields: ['ID', 'TaskID', 'Task', 'DependsOnTaskID', 'DependsOnTask', 'DependencyType'],
                        MaxRows: limits.ResourceGuards.BroadEntityQueryMaxRows,
                        ResultType: 'simple',
                    },
                    {
                        EntityName: TASK_LINKS_ENTITY,
                        ExtraFilter: `TaskID IN (${inList})`,
                        Fields: ['ID', 'TaskID', 'EntityID', 'Entity', 'RecordID'],
                        MaxRows: limits.ResourceGuards.BroadEntityQueryMaxRows,
                        ResultType: 'simple',
                    },
                    {
                        EntityName: TASK_CHECK_INS_ENTITY,
                        ExtraFilter: `TaskID IN (${inList})`,
                        OrderBy: 'CheckInAt DESC',
                        Fields: [
                            'ID',
                            'TaskID',
                            'CheckInAt',
                            'HealthStatus',
                            'ConfidenceScore',
                            'PercentComplete',
                            'Summary',
                            'Blockers',
                        ],
                        MaxRows: limits.Tuning.RiskAnalystEvidenceCheckInCap,
                        ResultType: 'simple',
                    },
                    {
                        EntityName: TASK_ASSIGNMENTS_ENTITY,
                        ExtraFilter: `TaskID IN (${inList})`,
                        Fields: [
                            'ID',
                            'TaskID',
                            'AssigneeEntityID',
                            'AssigneeEntity',
                            'AssigneeRecordID',
                            'Role',
                            'Status',
                        ],
                        MaxRows: limits.ResourceGuards.BroadEntityQueryMaxRows,
                        ResultType: 'simple',
                    },
                ],
                ownerUser,
            );

            if (depsRes?.Success && Array.isArray(depsRes.Results)) {
                dependencies.push(...(depsRes.Results as DependencyRow[]));
            }
            if (linksRes?.Success && Array.isArray(linksRes.Results)) {
                links.push(...(linksRes.Results as TaskLinkRow[]));
            }
            if (checkInsRes?.Success && Array.isArray(checkInsRes.Results)) {
                checkIns.push(...(checkInsRes.Results as CheckInRow[]));
            }
            if (assignRes?.Success && Array.isArray(assignRes.Results)) {
                assignments.push(...(assignRes.Results as AssignmentRow[]));
            }
        }

        checkIns.sort((a, b) => (toTimestampMs(b.CheckInAt) ?? 0) - (toTimestampMs(a.CheckInAt) ?? 0));
        return {
            dependencies,
            links,
            checkIns: checkIns.slice(0, limits.Tuning.RiskAnalystEvidenceCheckInCap),
            assignments,
        };
    }

    private async fetchTasksByIdsBatched(
        rv: RunView,
        rvProvider: IRunViewProvider | null,
        taskIds: readonly string[],
        ownerUser: UserInfo,
    ): Promise<SubtaskRow[]> {
        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        const chunks = chunkIds(taskIds, limits.ResourceGuards.SqlInClauseChunkSize);
        const queries: RunViewParams[] = chunks.map((chunk) => ({
            EntityName: TASKS_ENTITY,
            ExtraFilter: `ID IN (${chunk.map((id) => `'${EscapeSQLString(id)}'`).join(',')})`,
            Fields: [
                'ID',
                'Name',
                'Status',
                'Priority',
                'ParentID',
                'StartedAt',
                'DueAt',
                'CompletedAt',
                'PercentComplete',
                'BlockedReason',
            ],
            MaxRows: limits.ResourceGuards.StandardBatchMaxRows,
            ResultType: 'simple',
        }));

        const results = await runBatchedQueries<SubtaskRow>(rv, rvProvider, queries, ownerUser);
        const rows: SubtaskRow[] = [];
        for (const res of results) {
            if (res?.Success && Array.isArray(res.Results)) {
                rows.push(...res.Results);
            }
        }
        return rows;
    }

    private buildSubtaskVelocityEvidence(subtasks: readonly SubtaskRow[], now: Date): SubtaskVelocityEvidence {
        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        const recentCutoffMs =
            now.getTime() - limits.Briefing.DefaultWorkReportsBriefingLookbackDays * MS_PER_DAY;

        let completedCount = 0;
        let inProgressCount = 0;
        let openCount = 0;
        let blockedCount = 0;
        let cancelledCount = 0;
        let recentlyCompletedCount = 0;
        let percentSum = 0;

        for (const sub of subtasks) {
            percentSum += sub.PercentComplete ?? 0;
            switch (sub.Status) {
                case 'Completed':
                    completedCount++;
                    {
                        const completedMs = toTimestampMs(sub.CompletedAt);
                        if (completedMs !== null && completedMs >= recentCutoffMs) {
                            recentlyCompletedCount++;
                        }
                    }
                    break;
                case 'InProgress':
                    inProgressCount++;
                    break;
                case 'Blocked':
                    blockedCount++;
                    break;
                case 'Cancelled':
                    cancelledCount++;
                    break;
                case 'Open':
                    openCount++;
                    break;
            }
        }

        const total = subtasks.length;
        const activeDenominator = total - cancelledCount;
        const completionRate =
            activeDenominator > 0
                ? Math.round((completedCount / activeDenominator) * SCORE_PRECISION_FACTOR) / SCORE_PRECISION_FACTOR
                : 0;
        const averagePercentComplete = total > 0 ? Math.round(percentSum / total) : 0;

        const summaries: SubtaskEvidenceSummary[] = subtasks
            .slice(0, limits.Tuning.RiskAnalystEvidenceSubtaskCap)
            .map((sub) => ({
                TaskID: sub.ID,
                Name: sub.Name,
                Status: sub.Status,
                PercentComplete: sub.PercentComplete ?? 0,
                DueAtISO: toIsoOrNull(sub.DueAt),
                CompletedAtISO: toIsoOrNull(sub.CompletedAt),
                EvidenceLink: buildTaskLink(sub.ID),
            }));

        return {
            TotalSubtasks: total,
            CompletedCount: completedCount,
            InProgressCount: inProgressCount,
            OpenCount: openCount,
            BlockedCount: blockedCount,
            CancelledCount: cancelledCount,
            CompletionRate: completionRate,
            RecentlyCompletedCount: recentlyCompletedCount,
            AveragePercentComplete: averagePercentComplete,
            SubtaskSummaries: summaries,
        };
    }

    private buildBlockedDependencyEvidence(
        dependencies: readonly DependencyRow[],
        links: readonly TaskLinkRow[],
        taskById: ReadonlyMap<string, SubtaskRow | ProjectRootTaskRow>,
    ): BlockedDependencyEvidence {
        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        const blockedItems: BlockedDependencyEvidenceItem[] = [];

        for (const dep of dependencies) {
            const upstream = taskById.get(dep.DependsOnTaskID.toLowerCase());
            const upstreamStatus: ProjectTaskStatusValue = upstream?.Status ?? 'Open';
            const downstream = taskById.get(dep.TaskID.toLowerCase());

            const isBlocking =
                upstreamStatus === 'Blocked' ||
                (upstreamStatus !== 'Completed' &&
                    upstreamStatus !== 'Cancelled' &&
                    downstream?.Status === 'Blocked');

            if (isBlocking) {
                blockedItems.push({
                    DependencyID: dep.ID,
                    TaskID: dep.TaskID,
                    TaskName: downstream?.Name ?? dep.Task ?? dep.TaskID,
                    DependsOnTaskID: dep.DependsOnTaskID,
                    DependsOnTaskName: upstream?.Name ?? dep.DependsOnTask ?? dep.DependsOnTaskID,
                    DependsOnStatus: upstreamStatus,
                    DependencyType: dep.DependencyType,
                    EvidenceLink: buildTaskLink(dep.TaskID),
                });
            }
        }

        const taskLinks: RelatedTaskLinkEvidenceItem[] = links
            .slice(0, limits.ResourceGuards.StandardListMaxRows)
            .map((link) => ({
                LinkID: link.ID,
                TaskID: link.TaskID,
                EntityName: link.Entity ?? link.EntityID,
                RecordID: link.RecordID,
                EvidenceLink: buildTaskLink(link.TaskID),
            }));

        return {
            TotalDependencies: dependencies.length,
            BlockedDependencyCount: blockedItems.length,
            RelatedLinkCount: links.length,
            BlockedItems: blockedItems.slice(0, limits.ResourceGuards.StandardListMaxRows),
            TaskLinks: taskLinks,
        };
    }

    private buildCheckInEvidence(checkIns: readonly CheckInRow[]): TaskCheckInEvidence {
        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        const excerptLimit = limits.Tuning.RiskAnalystNoteExcerptMaxChars;
        const capped = checkIns.slice(0, limits.Tuning.RiskAnalystEvidenceCheckInCap);

        const items: CheckInEvidenceItem[] = capped.map((ci) => ({
            CheckInID: ci.ID,
            TaskID: ci.TaskID,
            CheckInAtISO: toIsoOrNull(ci.CheckInAt) ?? '',
            HealthStatus: ci.HealthStatus,
            ConfidenceScore: ci.ConfidenceScore ?? null,
            PercentComplete: ci.PercentComplete ?? null,
            SummaryExcerpt: (ci.Summary ?? '').trim().slice(0, excerptLimit),
            BlockersExcerpt: ci.Blockers?.trim() ? ci.Blockers.trim().slice(0, excerptLimit) : null,
            EvidenceLink: buildTaskLink(ci.TaskID),
        }));

        return {
            TotalCheckIns: checkIns.length,
            LatestCheckInAtISO: items[0]?.CheckInAtISO ?? null,
            CheckIns: items,
        };
    }

    private buildOverdueEvidence(
        rootTask: ProjectRootTaskRow,
        subtasks: readonly SubtaskRow[],
        now: Date,
    ): OverdueItemsEvidence {
        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        const nowMs = now.getTime();
        const items: OverdueTaskEvidenceItem[] = [];
        let rootTaskOverdue = false;

        const candidates: Array<{
            ID: string;
            Name: string;
            Status: ProjectTaskStatusValue;
            Priority: ProjectTaskPriorityValue;
            DueAt: string | Date | null;
            IsRoot: boolean;
        }> = [
            {
                ID: rootTask.ID,
                Name: rootTask.Name,
                Status: rootTask.Status,
                Priority: rootTask.Priority,
                DueAt: rootTask.DueAt,
                IsRoot: true,
            },
            ...subtasks.map((s) => ({
                ID: s.ID,
                Name: s.Name,
                Status: s.Status,
                Priority: s.Priority,
                DueAt: s.DueAt,
                IsRoot: false,
            })),
        ];

        for (const task of candidates) {
            if (!ACTIVE_OPEN_STATUSES.has(task.Status)) continue;
            const dueMs = toTimestampMs(task.DueAt);
            if (dueMs === null || dueMs >= nowMs) continue;

            if (task.IsRoot) {
                rootTaskOverdue = true;
            }
            const daysOverdue = Math.max(1, Math.ceil((nowMs - dueMs) / MS_PER_DAY));
            items.push({
                TaskID: task.ID,
                Name: task.Name,
                Status: task.Status,
                Priority: task.Priority,
                DueAtISO: new Date(dueMs).toISOString(),
                DaysOverdue: daysOverdue,
                EvidenceLink: buildTaskLink(task.ID),
            });
        }

        items.sort((a, b) => b.DaysOverdue - a.DaysOverdue);
        return {
            OverdueCount: items.length,
            RootTaskOverdue: rootTaskOverdue,
            Items: items.slice(0, limits.ResourceGuards.StandardListMaxRows),
        };
    }

    private async collectSanitizedFreeBusy(
        rv: RunView,
        rvProvider: IRunViewProvider | null,
        assignments: readonly AssignmentRow[],
        ownerUser: UserInfo,
        now: Date,
        freeBusyProvider: ProjectFreeBusyProvider | undefined,
    ): Promise<ProjectFreeBusyAvailability> {
        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        const windowStart = new Date(now.getTime());
        const windowEnd = new Date(now.getTime() + limits.Tuning.RiskAnalystFreeBusyLookaheadDays * MS_PER_DAY);

        const personIds = uniqueValidUuids(
            assignments
                .filter((a) => a.AssigneeEntity === PEOPLE_ENTITY || !a.AssigneeEntity)
                .map((a) => a.AssigneeRecordID),
        );

        const personById = new Map<string, PersonContactRow>();
        if (personIds.length > 0) {
            const chunks = chunkIds(personIds, limits.ResourceGuards.SqlInClauseChunkSize);
            const queries: RunViewParams[] = chunks.map((chunk) => ({
                EntityName: PEOPLE_ENTITY,
                ExtraFilter: `ID IN (${chunk.map((id) => `'${EscapeSQLString(id)}'`).join(',')})`,
                Fields: ['ID', 'Email', 'LinkedUserID'],
                MaxRows: limits.ResourceGuards.StandardBatchMaxRows,
                ResultType: 'simple',
            }));
            const results = await runBatchedQueries<PersonContactRow>(rv, rvProvider, queries, ownerUser);
            for (const res of results) {
                if (res?.Success && Array.isArray(res.Results)) {
                    for (const row of res.Results) {
                        personById.set(row.ID.toLowerCase(), row);
                    }
                }
            }
        }

        const targets: ProjectAssigneeScheduleTarget[] = [];
        const seenKeys = new Set<string>();
        for (const pid of personIds) {
            const person = personById.get(pid.toLowerCase());
            const key = `p:${pid.toLowerCase()}`;
            if (!seenKeys.has(key)) {
                seenKeys.add(key);
                targets.push({
                    PersonID: pid,
                    UserID: person?.LinkedUserID ?? null,
                    Email: person?.Email ?? null,
                });
            }
        }
        if (targets.length === 0) {
            targets.push({
                PersonID: null,
                UserID: ownerUser.ID,
                Email: ownerUser.Email ?? null,
            });
        }

        const rawSchedules = freeBusyProvider
            ? await freeBusyProvider({
                  Assignees: targets,
                  WindowStart: windowStart,
                  WindowEnd: windowEnd,
                  OwnerUser: ownerUser,
              })
            : [];

        const rawByKey = new Map<string, readonly RawFreeBusySlotInput[]>();
        for (const sched of rawSchedules) {
            const key = sched.PersonID
                ? `p:${sched.PersonID.toLowerCase()}`
                : sched.UserID
                  ? `u:${sched.UserID.toLowerCase()}`
                  : 'default';
            rawByKey.set(key, sched.Slots);
        }

        const summaries: AssigneeFreeBusySummary[] = targets.map((target) => {
            const key = target.PersonID
                ? `p:${target.PersonID.toLowerCase()}`
                : target.UserID
                  ? `u:${target.UserID.toLowerCase()}`
                  : 'default';
            const slots = rawByKey.get(key) ?? [];
            return BuildAssigneeFreeBusySummary({
                personId: target.PersonID,
                userId: target.UserID,
                windowStart,
                windowEnd,
                slots,
                mode: 'strip',
            });
        });

        return AggregateProjectFreeBusy({
            windowStart,
            windowEnd,
            assignees: summaries,
        });
    }

    private async resolveMLBreachSignal(
        rootTask: ProjectRootTaskRow,
        ownerUser: UserInfo,
        provider: MLBreachScoreProvider | undefined,
    ): Promise<MLBreachSignal> {
        if (provider) {
            const provided = await provider({ RootTask: rootTask, OwnerUser: ownerUser });
            if (provided) {
                return {
                    Probability: clampProbability(provided.Probability),
                    RiskBand: provided.RiskBand ?? null,
                    ScoredAtISO: provided.ScoredAtISO ?? null,
                    Source: provided.Source,
                };
            }
        }

        const prob = clampProbability(rootTask.PredictedSLABreachProbability);
        if (prob !== null) {
            return {
                Probability: prob,
                RiskBand: rootTask.PredictedSLARiskBand ?? null,
                ScoredAtISO: toIsoOrNull(rootTask.PredictedSLAScoredAt),
                Source: 'TaskRecord',
            };
        }

        return {
            Probability: null,
            RiskBand: null,
            ScoredAtISO: null,
            Source: 'Unavailable',
        };
    }

    private async executeDefaultProjectRiskAgent(
        input: ProjectRiskAgentExecutionInput,
        provider: IMetadataProvider,
        rvProvider: IRunViewProvider | null,
    ): Promise<ProjectRiskAgentExecutionResult> {
        const rv = new RunView(rvProvider);
        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        const escapedName = EscapeSQLString(input.AgentName);

        const agentRes = await rv.RunView<AgentRecordRow>(
            {
                EntityName: AI_AGENTS_ENTITY,
                ExtraFilter: `Name = '${escapedName}' AND Status = 'Active'`,
                Fields: ['ID', 'Name', 'Status', 'DefaultPromptEffortLevel'],
                MaxRows: limits.ResourceGuards.DefaultLookupSingleRow,
                ResultType: 'simple',
            },
            input.OwnerUser,
        );

        const agentRow = agentRes?.Success ? agentRes.Results?.[0] : undefined;
        if (!agentRow) {
            throw new Error(
                `ProjectRiskAnalystService: active AI Agent '${input.AgentName}' was not found.`,
            );
        }

        const [agentEntity, configRes] = await Promise.all([
            provider.GetEntityObject<MJAIAgentEntityExtended>(AI_AGENTS_ENTITY, input.OwnerUser),
            rv.RunView<AgentConfigurationRow>(
                {
                    EntityName: AI_AGENT_CONFIGURATIONS_ENTITY,
                    ExtraFilter: `AgentID = '${EscapeSQLString(agentRow.ID)}' AND Status = 'Active'`,
                    Fields: ['ID', 'Name', 'AIConfigurationID', 'IsDefault', 'Priority', 'Status'],
                    OrderBy: 'Priority DESC',
                    MaxRows: limits.ResourceGuards.CandidateLookupMaxRows,
                    ResultType: 'simple',
                },
                input.OwnerUser,
            ),
        ]);

        if (!(await agentEntity.Load(agentRow.ID))) {
            throw new Error(`ProjectRiskAnalystService: failed to load AI Agent '${agentRow.ID}'.`);
        }

        const configs = configRes?.Success ? (configRes.Results ?? []) : [];
        const highConfig =
            configs.find((c) => c.Name.toLowerCase() === input.PreferredConfigurationName.toLowerCase()) ??
            configs.find((c) => c.IsDefault) ??
            configs[0];

        const runner = new AgentRunner();
        const runResult = await runner.RunAgent({
            agent: agentEntity,
            contextUser: input.OwnerUser,
            userId: input.OwnerUser.ID,
            configurationId: highConfig?.AIConfigurationID,
            effortLevel: agentRow.DefaultPromptEffortLevel ?? limits.Tuning.RiskAnalystDefaultEffortLevel,
            PrimaryScopeEntityName: TASKS_ENTITY,
            PrimaryScopeRecordID: input.RootTaskID,
            data: {
                projectJson: input.PromptData.projectJson,
                cadenceJson: input.PromptData.cadenceJson,
                velocityJson: input.PromptData.velocityJson,
                blockedDependenciesJson: input.PromptData.blockedDependenciesJson,
                checkInsJson: input.PromptData.checkInsJson,
                overdueItemsJson: input.PromptData.overdueItemsJson,
                freeBusyJson: input.PromptData.freeBusyJson,
                mlBreachJson: input.PromptData.mlBreachJson,
            },
            TrustReservedRunData: true,
            conversationMessages: [
                {
                    role: 'user',
                    content: `Assess delivery risk and forecast completion for project root task ${input.RootTaskID}. Return strictly valid JSON.`,
                },
            ],
        });

        const agentRunID = runResult.agentRun?.ID ?? null;
        if (!runResult.success) {
            const errMsg =
                runResult.agentRun?.ErrorMessage ??
                runResult.errorMessage ??
                `Agent '${input.AgentName}' failed without an error message.`;
            LogError(`ProjectRiskAnalystService: ${errMsg}`);
            return {
                Success: false,
                Payload: null,
                AgentRunID: agentRunID,
                PromptTokens: extractPromptTokens(runResult.agentRun),
                CompletionTokens: extractCompletionTokens(runResult.agentRun),
                TotalCostUSD: extractTotalCost(runResult.agentRun),
                ErrorMessage: errMsg,
            };
        }

        return {
            Success: true,
            Payload: (runResult.payload as ProjectRiskAgentRawPayload | string | null | undefined) ??
                runResult.agentRun?.FinalPayload ??
                null,
            AgentRunID: agentRunID,
            PromptTokens: extractPromptTokens(runResult.agentRun),
            CompletionTokens: extractCompletionTokens(runResult.agentRun),
            TotalCostUSD: extractTotalCost(runResult.agentRun),
            ErrorMessage: null,
        };
    }
}
