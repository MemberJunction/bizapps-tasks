import {
    RunView,
    type IMetadataProvider,
    type IRunViewProvider,
    type RunViewParams,
    type RunViewResult,
    type UserInfo,
} from '@memberjunction/core';
import { EscapeSQLString, IsValidUUID, NormalizeUUID } from '@memberjunction/global';

export const TASK_FIELD_SUGGESTIONS_ENTITY_NAME = 'MJ: Field Suggestions';
export const BIZAPPS_TASKS_ENTITY_NAME = 'MJ_BizApps_Tasks: Tasks';

export type TaskFieldSuggestionSource = 'LLM' | 'Integration' | 'Agent' | 'Person';
export type TaskFieldSuggestionOutcome = 'Accepted' | 'Rejected' | 'Superseded';

/**
 * Strongly-typed projection of `MJ: Field Suggestions` (`vwFieldSuggestions`) rows
 * queried via `RunView` with `ResultType: 'simple'`.
 *
 * Schema verified against `V202611101900__v6.3.x__ConversationTypes_Comments_FieldSuggestions.sql`:
 * - `FieldSuggestion` extends `MJ: Comments` -> `MJ: Conversations` (shared-PK IS-A hierarchy).
 * - Target entity and record are stored on `LinkedEntityID` and `LinkedRecordID`.
 * - Target field name is stored on `AnchorKey` (with `AnchorType = 'field'`).
 * - Unresolved/pending suggestions have `Outcome = null`, `IsResolved = false` (`0`), and `IsArchived = false` (`0`).
 */
export interface TaskFieldSuggestionRow {
    ID: string;
    LinkedEntityID: string | null;
    LinkedRecordID: string | null;
    AnchorType?: string | null;
    AnchorKey: string | null;
    SuggestedValue?: string | null;
    Confidence?: number | null;
    Source?: TaskFieldSuggestionSource | null;
    Outcome?: TaskFieldSuggestionOutcome | null;
    IsResolved?: boolean | number | null;
    IsArchived?: boolean | number | null;
    Name?: string | null;
    Description?: string | null;
}

/**
 * Aggregated pending field-suggestion summary for a single task record.
 */
export interface TaskPendingSuggestionsSummary {
    /** Normalized lowercase task UUID (`NormalizeUUID(LinkedRecordID)`). */
    taskId: string;
    /** Number of unresolved/pending `MJ: Field Suggestions` rows anchored to this task. */
    pendingCount: number;
    /** Distinct target field names (`AnchorKey`) in order of appearance. */
    fieldNames: string[];
    /** Compact single-line preview of the top pending suggestion for badges/callouts. */
    topPreviewLabel: string;
}

/**
 * Result returned by {@link LoadTaskPendingSuggestions} and {@link TaskFieldSuggestionsHelper.LoadPendingSuggestions}.
 */
export interface TaskPendingSuggestionsResult {
    /** True when `MJ: Field Suggestions` is registered in the host's metadata (`MJ 6.3+`). */
    available: boolean;
    /** Map of per-task pending suggestion summaries keyed by normalized task UUID. */
    byTaskId: Map<string, TaskPendingSuggestionsSummary>;
}

/**
 * Minimal `RunView`-compatible runner contract for dependency injection in tests and multi-provider callers.
 */
export interface TaskRunViewRunner {
    RunView<T>(params: RunViewParams, contextUser?: UserInfo): Promise<RunViewResult<T>>;
}

export interface LoadTaskPendingSuggestionsOptions {
    /** Optional subset of Task UUIDs to scope the lookup to. */
    taskIds?: readonly string[];
    /** Optional context user forwarded to `RunView` (defaults to `provider.CurrentUser`). */
    contextUser?: UserInfo;
    /** Optional `RunView` runner override (useful in unit tests). */
    runView?: TaskRunViewRunner;
}

const MAX_INLINE_SQL_TASK_IDS = 200;
const MAX_PREVIEW_VALUE_LENGTH = 36;

interface MutableTaskSuggestionBucket {
    taskId: string;
    pendingCount: number;
    fieldNames: string[];
    seenFieldsLower: Set<string>;
    firstField: string | null;
    firstSuggestedValue: string | null | undefined;
    hasFirstSuggestion: boolean;
}

function cleanSuggestedValuePreview(rawValue: string | null | undefined): string {
    if (rawValue == null) {
        return '';
    }
    const trimmed = rawValue.trim();
    if (trimmed.length === 0) {
        return '';
    }
    const unquoted =
        trimmed.length >= 2 && trimmed.startsWith('"') && trimmed.endsWith('"')
            ? trimmed.slice(1, -1).trim()
            : trimmed;
    if (unquoted.length <= MAX_PREVIEW_VALUE_LENGTH) {
        return unquoted;
    }
    return `${unquoted.slice(0, MAX_PREVIEW_VALUE_LENGTH - 3)}...`;
}

function buildTopPreviewLabel(bucket: MutableTaskSuggestionBucket): string {
    if (bucket.firstField) {
        const cleanedValue = cleanSuggestedValuePreview(bucket.firstSuggestedValue);
        const base =
            bucket.firstSuggestedValue == null
                ? `Clear ${bucket.firstField}`
                : cleanedValue.length > 0
                  ? `${bucket.firstField}: ${cleanedValue}`
                  : bucket.firstField;
        return bucket.pendingCount > 1 ? `${base} (+${bucket.pendingCount - 1} more)` : base;
    }
    return FormatPendingSuggestionTooltip({
        pendingCount: bucket.pendingCount,
        fieldNames: bucket.fieldNames,
    });
}

/**
 * Returns `true` when a `MJ: Field Suggestions` row is unresolved and pending human review.
 */
export function IsPendingFieldSuggestionRow(row: TaskFieldSuggestionRow): boolean {
    if (!row.LinkedRecordID || row.LinkedRecordID.trim().length === 0) {
        return false;
    }
    if (row.Outcome != null && String(row.Outcome).trim().length > 0) {
        return false;
    }
    if (row.IsResolved === true || row.IsResolved === 1) {
        return false;
    }
    if (row.IsArchived === true || row.IsArchived === 1) {
        return false;
    }
    return true;
}

/**
 * Formats a concise human-readable tooltip summarizing pending field suggestions on a task
 * (for example `"2 pending suggestions: DueDate, EffortHours"`).
 */
export function FormatPendingSuggestionTooltip(
    summary: Pick<TaskPendingSuggestionsSummary, 'pendingCount' | 'fieldNames'> | null | undefined,
): string {
    if (!summary || summary.pendingCount <= 0) {
        return '';
    }
    const noun = summary.pendingCount === 1 ? 'pending suggestion' : 'pending suggestions';
    if (summary.fieldNames.length > 0) {
        return `${summary.pendingCount} ${noun}: ${summary.fieldNames.join(', ')}`;
    }
    return `${summary.pendingCount} ${noun}`;
}

/**
 * Aggregates `MJ: Field Suggestions` rows into per-task pending counts and field summaries,
 * normalizing task UUIDs case-insensitively via `NormalizeUUID`.
 */
export function AggregatePendingSuggestionsByTask(
    rows: readonly TaskFieldSuggestionRow[],
): Map<string, TaskPendingSuggestionsSummary> {
    const buckets = new Map<string, MutableTaskSuggestionBucket>();

    for (const row of rows) {
        if (!IsPendingFieldSuggestionRow(row) || !row.LinkedRecordID) {
            continue;
        }
        const normalizedTaskId = NormalizeUUID(row.LinkedRecordID);
        if (!normalizedTaskId) {
            continue;
        }

        let bucket = buckets.get(normalizedTaskId);
        if (!bucket) {
            bucket = {
                taskId: normalizedTaskId,
                pendingCount: 0,
                fieldNames: [],
                seenFieldsLower: new Set<string>(),
                firstField: null,
                firstSuggestedValue: undefined,
                hasFirstSuggestion: false,
            };
            buckets.set(normalizedTaskId, bucket);
        }

        bucket.pendingCount += 1;
        const fieldName = row.AnchorKey?.trim() ?? '';
        if (fieldName.length > 0) {
            const lowerField = fieldName.toLowerCase();
            if (!bucket.seenFieldsLower.has(lowerField)) {
                bucket.seenFieldsLower.add(lowerField);
                bucket.fieldNames.push(fieldName);
            }
        }

        if (!bucket.hasFirstSuggestion) {
            bucket.hasFirstSuggestion = true;
            bucket.firstField = fieldName.length > 0 ? fieldName : null;
            bucket.firstSuggestedValue = row.SuggestedValue;
        }
    }

    const summaries = new Map<string, TaskPendingSuggestionsSummary>();
    for (const [taskId, bucket] of buckets.entries()) {
        summaries.set(taskId, {
            taskId,
            pendingCount: bucket.pendingCount,
            fieldNames: bucket.fieldNames,
            topPreviewLabel: buildTopPreviewLabel(bucket),
        });
    }
    return summaries;
}

/**
 * Filters a task collection when `onlyPendingSuggestions` is active, matching task IDs
 * case-insensitively against `byTaskId` (or falling back to `task.PendingSuggestionCount` when `byTaskId` is omitted).
 */
export function FilterTasksByPendingSuggestions<T extends { ID: string; PendingSuggestionCount?: number }>(
    tasks: readonly T[],
    onlyPendingSuggestions: boolean,
    byTaskId?: ReadonlyMap<string, Pick<TaskPendingSuggestionsSummary, 'pendingCount'>>,
): T[] {
    if (!onlyPendingSuggestions) {
        return [...tasks];
    }
    return tasks.filter((task) => {
        if (byTaskId !== undefined) {
            const summary = byTaskId.get(NormalizeUUID(task.ID));
            return (summary?.pendingCount ?? 0) > 0;
        }
        return (task.PendingSuggestionCount ?? 0) > 0;
    });
}

/**
 * Sums total pending suggestions across all tasks in a summary map.
 */
export function CountTotalPendingSuggestions(
    byTaskId: ReadonlyMap<string, Pick<TaskPendingSuggestionsSummary, 'pendingCount'>>,
): number {
    let total = 0;
    for (const summary of byTaskId.values()) {
        total += summary.pendingCount;
    }
    return total;
}

/**
 * Builds an SQL `ExtraFilter` clause restricting tasks to IDs with pending suggestions
 * when `onlyPendingSuggestions` is `true`, optionally combined with an existing `baseExtraFilter`.
 */
export function BuildPendingSuggestionsSqlFilter(
    onlyPendingSuggestions: boolean,
    byTaskId: ReadonlyMap<string, Pick<TaskPendingSuggestionsSummary, 'pendingCount'>>,
    baseExtraFilter?: string | null,
): string | null {
    const trimmedBase = baseExtraFilter?.trim() ?? '';
    if (!onlyPendingSuggestions) {
        return trimmedBase.length > 0 ? trimmedBase : null;
    }

    const quotedIds: string[] = [];
    for (const [taskId, summary] of byTaskId.entries()) {
        if (summary.pendingCount > 0 && IsValidUUID(taskId)) {
            quotedIds.push(`'${EscapeSQLString(taskId)}'`);
        }
    }

    const pendingClause = quotedIds.length > 0 ? `ID IN (${quotedIds.join(', ')})` : '1 = 0';
    return trimmedBase.length > 0 ? `(${trimmedBase}) AND ${pendingClause}` : pendingClause;
}

/**
 * Cross-version safe loader for unresolved `MJ: Field Suggestions` anchored to `MJ_BizApps_Tasks: Tasks`.
 *
 * On pre-6.3 hosts where `MJ: Field Suggestions` is not registered in `provider.Entities`,
 * returns `{ available: false, byTaskId: new Map() }` cleanly without issuing any query or logging warnings.
 */
export async function LoadTaskPendingSuggestions(
    provider: IMetadataProvider | null | undefined,
    options?: LoadTaskPendingSuggestionsOptions,
): Promise<TaskPendingSuggestionsResult> {
    const entities = provider?.Entities;
    if (!Array.isArray(entities) || !entities.some((e) => e.Name === TASK_FIELD_SUGGESTIONS_ENTITY_NAME)) {
        return { available: false, byTaskId: new Map() };
    }

    const tasksEntityId = entities.find((e) => e.Name === BIZAPPS_TASKS_ENTITY_NAME)?.ID ?? null;
    if (!tasksEntityId || !IsValidUUID(tasksEntityId)) {
        return { available: true, byTaskId: new Map() };
    }

    let scopedTaskIdSet: Set<string> | null = null;
    let inlineSqlIds: string[] | null = null;
    if (options?.taskIds !== undefined) {
        const validIds = options.taskIds.filter((id) => IsValidUUID(id));
        if (validIds.length === 0) {
            return { available: true, byTaskId: new Map() };
        }
        scopedTaskIdSet = new Set(validIds.map((id) => NormalizeUUID(id)));
        if (validIds.length <= MAX_INLINE_SQL_TASK_IDS) {
            inlineSqlIds = validIds;
        }
    }

    const filterClauses: string[] = [
        `LinkedEntityID = '${EscapeSQLString(tasksEntityId)}'`,
        `Outcome IS NULL`,
        `IsResolved = 0`,
        `(IsArchived IS NULL OR IsArchived = 0)`,
    ];
    if (inlineSqlIds && inlineSqlIds.length > 0) {
        const quotedIds = inlineSqlIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
        filterClauses.push(`LinkedRecordID IN (${quotedIds})`);
    }

    const hasProviderRunView =
        provider != null && typeof (provider as Partial<IRunViewProvider>).RunView === 'function';
    const runner: TaskRunViewRunner =
        options?.runView ?? (hasProviderRunView ? RunView.FromMetadataProvider(provider!) : new RunView());
    const contextUser = options?.contextUser ?? provider?.CurrentUser;

    try {
        const res = await runner.RunView<TaskFieldSuggestionRow>(
            {
                EntityName: TASK_FIELD_SUGGESTIONS_ENTITY_NAME,
                ExtraFilter: filterClauses.join(' AND '),
                Fields: [
                    'ID',
                    'LinkedEntityID',
                    'LinkedRecordID',
                    'AnchorType',
                    'AnchorKey',
                    'SuggestedValue',
                    'Confidence',
                    'Source',
                    'Outcome',
                    'IsResolved',
                    'IsArchived',
                    'Name',
                    'Description',
                ],
                ResultType: 'simple',
            },
            contextUser,
        );

        if (!res?.Success || !Array.isArray(res.Results)) {
            return { available: true, byTaskId: new Map() };
        }

        const candidateRows =
            scopedTaskIdSet != null
                ? res.Results.filter(
                      (row) => row.LinkedRecordID != null && scopedTaskIdSet.has(NormalizeUUID(row.LinkedRecordID)),
                  )
                : res.Results;

        return {
            available: true,
            byTaskId: AggregatePendingSuggestionsByTask(candidateRows),
        };
    } catch {
        return { available: true, byTaskId: new Map() };
    }
}

/**
 * Facade grouping cross-version safe `MJ: Field Suggestions` discovery, querying,
 * per-task aggregation, filtering, and tooltip formatting for BizApps Tasks UI components.
 */
export class TaskFieldSuggestionsHelper {
    public static readonly FieldSuggestionsEntityName = TASK_FIELD_SUGGESTIONS_ENTITY_NAME;
    public static readonly TasksEntityName = BIZAPPS_TASKS_ENTITY_NAME;

    public static IsAvailable(provider: Pick<IMetadataProvider, 'Entities'> | null | undefined): boolean {
        return Boolean(
            provider?.Entities &&
                Array.isArray(provider.Entities) &&
                provider.Entities.some((e) => e.Name === TASK_FIELD_SUGGESTIONS_ENTITY_NAME),
        );
    }

    public static ResolveTasksEntityId(
        provider: Pick<IMetadataProvider, 'Entities'> | null | undefined,
    ): string | null {
        const id = provider?.Entities?.find((e) => e.Name === BIZAPPS_TASKS_ENTITY_NAME)?.ID ?? null;
        return id && IsValidUUID(id) ? id : null;
    }

    public static LoadPendingSuggestions(
        provider: IMetadataProvider | null | undefined,
        options?: LoadTaskPendingSuggestionsOptions,
    ): Promise<TaskPendingSuggestionsResult> {
        return LoadTaskPendingSuggestions(provider, options);
    }

    public static AggregatePendingSuggestionsByTask = AggregatePendingSuggestionsByTask;
    public static FilterTasksByPendingSuggestions = FilterTasksByPendingSuggestions;
    public static FormatPendingSuggestionTooltip = FormatPendingSuggestionTooltip;
    public static CountTotalPendingSuggestions = CountTotalPendingSuggestions;
    public static BuildPendingSuggestionsSqlFilter = BuildPendingSuggestionsSqlFilter;
}
