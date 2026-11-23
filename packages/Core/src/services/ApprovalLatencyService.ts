/**
 * Approval creation-to-decision latency telemetry and reporting helpers.
 *
 * Records sanitized creation-to-decision latency metrics through `TelemetryManager.Instance`
 * using `RouteScrubber` redaction and zero PII/UUID leakage, and queries historical
 * decision latency through `RunView` (`ResultType: 'simple'`) with explicit `Fields`,
 * optional organization/date-window filters, and zero decision-truncating `MaxRows` caps.
 */
import {
    RunView,
    TelemetryManager,
    type IRunViewProvider,
    type TelemetryCustomParams,
    type UserInfo,
} from '@memberjunction/core';
import { TasksLimitsResolver } from '../config/TasksLimits.js';
import { GuidLiteral } from './sql-guards.js';

const TASK_DECISIONS_ENTITY = 'MJ_BizApps_Tasks: Task Decisions';
const TASKS_ENTITY = 'MJ_BizApps_Tasks: Tasks';

const UUID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/gi;
const EMAIL_REGEX = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/gi;
const BEARER_REGEX = /\bBearer\s+[A-Za-z0-9._-]+/gi;

/** Result shape produced by `@memberjunction/health`'s `RouteScrubber.Scrub`. */
export interface ScrubbedRouteResult {
    RouteTemplate: string;
    ScrubbedPath: string;
    ResourceType?: string;
    EntityName?: string;
    ApplicationName?: string;
}

/** Structural interface allowing callers to inject `RouteScrubber` directly or use the built-in fail-closed scrubber. */
export interface RouteScrubberLike {
    Scrub(rawUrl: string): ScrubbedRouteResult;
}

interface KnownRouteRule {
    pattern: RegExp;
    template: string;
    scrubbed: (match: RegExpMatchArray) => string;
}

const KNOWN_ROUTE_RULES: readonly KnownRouteRule[] = [
    {
        pattern: /^app\/([^/]+)\/record\/([^/]+)\/([^/]+)/,
        template: 'app/:appName/record/:entityName/:recordId',
        scrubbed: (m) => `app/${m[1]}/record/${m[2]}/_id_`,
    },
    {
        pattern: /^app\/([^/]+)\/([^/]+)\/([^/]+)/,
        template: 'app/:appName/:resourceType/:param1',
        scrubbed: (m) => `app/${m[1]}/${m[2]}/_id_`,
    },
    {
        pattern: /^app\/([^/]+)\/([^/]+)/,
        template: 'app/:appName/:navItemName',
        scrubbed: (m) => `app/${m[1]}/${m[2]}`,
    },
    {
        pattern: /^resource\/record\/([^/]+)\/([^/]+)/,
        template: 'resource/record/:entityName/:recordId',
        scrubbed: (m) => `resource/record/${m[1]}/_id_`,
    },
    {
        pattern: /^resource\/search\/(.+)/,
        template: 'resource/search/:searchInput',
        scrubbed: () => 'resource/search/[REDACTED]',
    },
    {
        pattern: /^resource\/view\/dynamic\/([^/]+)/,
        template: 'resource/view/dynamic/:entityName',
        scrubbed: (m) => `resource/view/dynamic/${m[1]}`,
    },
    {
        pattern: /^resource\/view\/([^/]+)/,
        template: 'resource/view/:viewId',
        scrubbed: () => 'resource/view/_id_',
    },
    {
        pattern: /^resource\/dashboard\/([^/]+)/,
        template: 'resource/dashboard/:dashboardId',
        scrubbed: () => 'resource/dashboard/_id_',
    },
    {
        pattern: /^resource\/artifact\/([^/]+)/,
        template: 'resource/artifact/:artifactId',
        scrubbed: () => 'resource/artifact/_id_',
    },
    {
        pattern: /^resource\/query\/([^/]+)/,
        template: 'resource/query/:queryId',
        scrubbed: () => 'resource/query/_id_',
    },
];

/**
 * Browser-safe fail-closed route scrubber matching `@memberjunction/health`'s `RouteScrubber`
 * contract so approval telemetry never ships record IDs, query params, or search terms.
 */
export const DefaultApprovalRouteScrubber: RouteScrubberLike = {
    Scrub(rawUrl: string): ScrubbedRouteResult {
        if (typeof rawUrl !== 'string' || rawUrl.length === 0 || rawUrl.length > 4096) {
            return { RouteTemplate: 'unknown', ScrubbedPath: '/unknown' };
        }
        const qIdx = rawUrl.indexOf('?');
        const hIdx = rawUrl.indexOf('#');
        const cutIdx = qIdx === -1 ? hIdx : hIdx === -1 ? qIdx : Math.min(qIdx, hIdx);
        const withoutQuery = cutIdx === -1 ? rawUrl : rawUrl.slice(0, cutIdx);

        let decoded: string;
        try {
            decoded = decodeURIComponent(withoutQuery);
        } catch {
            return { RouteTemplate: 'unknown', ScrubbedPath: '/unknown' };
        }
        if (decoded.split('/').some((seg) => seg === '..')) {
            return { RouteTemplate: 'unknown', ScrubbedPath: '/unknown' };
        }

        const cleanUrl = decoded.replace(/^\/+|\/+$/g, '');
        if (cleanUrl.length === 0) {
            return { RouteTemplate: 'unknown', ScrubbedPath: '/unknown' };
        }

        for (const rule of KNOWN_ROUTE_RULES) {
            const match = cleanUrl.match(rule.pattern);
            if (match) {
                return {
                    RouteTemplate: rule.template,
                    ScrubbedPath: `/${rule.scrubbed(match)}`,
                };
            }
        }
        return { RouteTemplate: 'unknown', ScrubbedPath: '/unknown' };
    },
};

/** Strips UUIDs, email addresses, and bearer tokens from any telemetry text attribute or error string. */
export function RedactTelemetryText(raw: string | null | undefined): string {
    if (!raw) return '';
    const maxChars = TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.FailureNotesMaxChars;
    return raw
        .replace(UUID_REGEX, '_id_')
        .replace(EMAIL_REGEX, '[REDACTED_EMAIL]')
        .replace(BEARER_REGEX, 'Bearer [REDACTED]')
        .slice(0, maxChars);
}

/** Input payload for {@link RecordApprovalDecisionLatency}. */
export interface ApprovalDecisionLatencyInput {
    CreatedAt: Date | string | null | undefined;
    DecidedAt?: Date | string | null | undefined;
    OutcomeCode: string;
    IsTerminal: boolean;
    Success: boolean;
    Route?: string | null;
    ErrorCode?: string | null;
    ErrorMessage?: string | null;
    Scrubber?: RouteScrubberLike;
}

/** Telemetry attributes emitted alongside an approval latency metric (strictly scalar & PII-free). */
export interface ApprovalTelemetryAttributes {
    outcomeCode: string;
    isTerminal: boolean;
    success: boolean;
    routeTemplate: string;
    scrubbedPath: string;
    latencyMs: number;
    errorCode?: string;
    errorSummary?: string;
}

function toTimestampMs(value: Date | string | null | undefined): number | null {
    if (value == null) return null;
    const ms = value instanceof Date ? value.getTime() : Date.parse(value);
    return Number.isFinite(ms) ? ms : null;
}

/**
 * Records approval creation-to-decision latency via `TelemetryManager.Instance` without
 * leaking UUIDs, emails, query strings, or user identifiers in attributes or error paths.
 */
export function RecordApprovalDecisionLatency(input: ApprovalDecisionLatencyInput): ApprovalTelemetryAttributes {
    const createdMs = toTimestampMs(input.CreatedAt);
    const decidedMs = toTimestampMs(input.DecidedAt) ?? Date.now();
    const latencyMs = createdMs != null ? Math.max(0, decidedMs - createdMs) : 0;

    const scrubber = input.Scrubber ?? DefaultApprovalRouteScrubber;
    const scrubbedRoute = input.Route
        ? scrubber.Scrub(input.Route)
        : { RouteTemplate: 'server/orchestration', ScrubbedPath: '/server/orchestration' };

    const safeAttributes: TelemetryCustomParams = {
        outcomeCode: RedactTelemetryText(input.OutcomeCode) || 'unknown',
        isTerminal: input.IsTerminal,
        success: input.Success,
        routeTemplate: scrubbedRoute.RouteTemplate,
        scrubbedPath: scrubbedRoute.ScrubbedPath,
        latencyMs,
    };

    const result: ApprovalTelemetryAttributes = {
        outcomeCode: String(safeAttributes.outcomeCode),
        isTerminal: input.IsTerminal,
        success: input.Success,
        routeTemplate: scrubbedRoute.RouteTemplate,
        scrubbedPath: scrubbedRoute.ScrubbedPath,
        latencyMs,
    };

    if (input.ErrorCode) {
        const cleanCode = RedactTelemetryText(input.ErrorCode);
        safeAttributes.errorCode = cleanCode;
        result.errorCode = cleanCode;
    }
    if (input.ErrorMessage) {
        const cleanSummary = RedactTelemetryText(input.ErrorMessage);
        safeAttributes.errorSummary = cleanSummary;
        result.errorSummary = cleanSummary;
    }

    const telemetry = TelemetryManager?.Instance;
    if (telemetry && typeof telemetry.RecordEvent === 'function') {
        telemetry.RecordEvent(
            'Custom',
            'BizAppsTasks:ApprovalDecisionLatency',
            safeAttributes,
            latencyMs,
        );
    }

    return result;
}

/** Filter parameters for querying approval creation-to-decision latency via `RunView`. */
export interface ApprovalLatencyQueryFilter {
    OrganizationID?: string | null;
    TaskTypeID?: string | null;
    Since?: Date | string | null;
    Until?: Date | string | null;
}

interface RawDecisionLatencyRow {
    ID: string;
    TaskID: string;
    OutcomeID: string;
    Outcome: string | null;
    DecidedAt: Date | string;
    __mj_CreatedAt: Date | string;
}

interface RawTaskTimingRow {
    ID: string;
    TypeID: string;
    OrganizationID: string | null;
    Status: string;
    __mj_CreatedAt: Date | string;
    CompletedAt: Date | string | null;
}

/** One calculated approval latency measurement. */
export interface ApprovalLatencyMetricRow {
    DecisionID: string;
    TaskID: string;
    OrganizationID: string | null;
    TaskTypeID: string;
    OutcomeID: string;
    Outcome: string | null;
    TaskStatus: string;
    TaskCreatedAt: string;
    DecidedAt: string;
    LatencyMs: number;
}

/** Aggregate statistics across queried approval decisions. */
export interface ApprovalLatencySummary {
    Count: number;
    MinLatencyMs: number;
    MaxLatencyMs: number;
    AvgLatencyMs: number;
    P95LatencyMs: number;
}

/** Combined rows and summary returned by {@link QueryApprovalLatencyMetrics}. */
export interface ApprovalLatencyQueryResult {
    Records: ApprovalLatencyMetricRow[];
    Summary: ApprovalLatencySummary;
}

const EMPTY_SUMMARY: ApprovalLatencySummary = {
    Count: 0,
    MinLatencyMs: 0,
    MaxLatencyMs: 0,
    AvgLatencyMs: 0,
    P95LatencyMs: 0,
};

function toIsoLiteral(value: Date | string, label: string): string {
    const dt = value instanceof Date ? value : new Date(value);
    if (Number.isNaN(dt.getTime())) {
        throw new Error(`${label} is not a valid date.`);
    }
    return `'${dt.toISOString()}'`;
}

/**
 * Queries approval creation-to-decision latency across `Task Decisions` and `Tasks`
 * via `RunView` (`ResultType: 'simple'`, explicit `Fields`, batched task lookup, and
 * NO `MaxRows` cap so decision-feeding and reporting datasets are never truncated).
 */
export async function QueryApprovalLatencyMetrics(
    filter: ApprovalLatencyQueryFilter = {},
    contextUser?: UserInfo,
    provider?: IRunViewProvider,
): Promise<ApprovalLatencyQueryResult> {
    const rv = new RunView(provider);

    const decisionFilters: string[] = [];
    if (filter.Since != null) {
        decisionFilters.push(`DecidedAt >= ${toIsoLiteral(filter.Since, 'Since')}`);
    }
    if (filter.Until != null) {
        decisionFilters.push(`DecidedAt <= ${toIsoLiteral(filter.Until, 'Until')}`);
    }

    const scopedTaskIds = new Set<string>();
    const hasTaskScopeFilter = Boolean(filter.OrganizationID || filter.TaskTypeID);
    const taskLookupById = new Map<string, RawTaskTimingRow>();

    if (hasTaskScopeFilter) {
        const taskFilters: string[] = [];
        if (filter.OrganizationID) {
            taskFilters.push(`OrganizationID = ${GuidLiteral(filter.OrganizationID, 'OrganizationID')}`);
        }
        if (filter.TaskTypeID) {
            taskFilters.push(`TypeID = ${GuidLiteral(filter.TaskTypeID, 'TaskTypeID')}`);
        }
        const scopedTasksRes = await rv.RunView<RawTaskTimingRow>(
            {
                EntityName: TASKS_ENTITY,
                ExtraFilter: taskFilters.join(' AND '),
                Fields: ['ID', 'TypeID', 'OrganizationID', 'Status', '__mj_CreatedAt', 'CompletedAt'],
                ResultType: 'simple',
            },
            contextUser,
        );
        if (!scopedTasksRes?.Success) {
            throw new Error(scopedTasksRes?.ErrorMessage ?? 'Failed to query scoped approval tasks.');
        }
        const scopedRows = scopedTasksRes.Results ?? [];
        if (scopedRows.length === 0) {
            return { Records: [], Summary: { ...EMPTY_SUMMARY } };
        }
        for (const t of scopedRows) {
            const norm = t.ID.trim().toLowerCase();
            scopedTaskIds.add(norm);
            taskLookupById.set(norm, t);
        }
        decisionFilters.push(
            `TaskID IN (${scopedRows.map((t) => GuidLiteral(t.ID, 'TaskID')).join(', ')})`,
        );
    }

    const decisionsRes = await rv.RunView<RawDecisionLatencyRow>(
        {
            EntityName: TASK_DECISIONS_ENTITY,
            ExtraFilter: decisionFilters.join(' AND '),
            Fields: ['ID', 'TaskID', 'OutcomeID', 'Outcome', 'DecidedAt', '__mj_CreatedAt'],
            OrderBy: 'DecidedAt DESC',
            ResultType: 'simple',
        },
        contextUser,
    );
    if (!decisionsRes?.Success) {
        throw new Error(decisionsRes?.ErrorMessage ?? 'Failed to query approval decision latency.');
    }
    const decisions = decisionsRes.Results ?? [];
    if (decisions.length === 0) {
        return { Records: [], Summary: { ...EMPTY_SUMMARY } };
    }

    if (!hasTaskScopeFilter) {
        const uniqueTaskIds = [...new Set(decisions.map((d) => d.TaskID))];
        const tasksRes = await rv.RunView<RawTaskTimingRow>(
            {
                EntityName: TASKS_ENTITY,
                ExtraFilter: `ID IN (${uniqueTaskIds.map((id) => GuidLiteral(id, 'TaskID')).join(', ')})`,
                Fields: ['ID', 'TypeID', 'OrganizationID', 'Status', '__mj_CreatedAt', 'CompletedAt'],
                ResultType: 'simple',
            },
            contextUser,
        );
        if (!tasksRes?.Success) {
            throw new Error(tasksRes?.ErrorMessage ?? 'Failed to load task timestamps for approval latency.');
        }
        for (const t of tasksRes.Results ?? []) {
            taskLookupById.set(t.ID.trim().toLowerCase(), t);
        }
    }

    const records: ApprovalLatencyMetricRow[] = [];
    for (const d of decisions) {
        const taskRow = taskLookupById.get(d.TaskID.trim().toLowerCase());
        if (!taskRow) continue;
        if (hasTaskScopeFilter && !scopedTaskIds.has(taskRow.ID.trim().toLowerCase())) continue;

        const createdMs = toTimestampMs(taskRow.__mj_CreatedAt);
        const decidedMs = toTimestampMs(d.DecidedAt) ?? toTimestampMs(d.__mj_CreatedAt);
        if (createdMs == null || decidedMs == null) continue;

        const latencyMs = Math.max(0, decidedMs - createdMs);
        records.push({
            DecisionID: d.ID,
            TaskID: d.TaskID,
            OrganizationID: taskRow.OrganizationID ?? null,
            TaskTypeID: taskRow.TypeID,
            OutcomeID: d.OutcomeID,
            Outcome: d.Outcome ?? null,
            TaskStatus: taskRow.Status,
            TaskCreatedAt: new Date(createdMs).toISOString(),
            DecidedAt: new Date(decidedMs).toISOString(),
            LatencyMs: latencyMs,
        });
    }

    if (records.length === 0) {
        return { Records: [], Summary: { ...EMPTY_SUMMARY } };
    }

    const sortedLatencies = records.map((r) => r.LatencyMs).sort((a, b) => a - b);
    const total = sortedLatencies.reduce((acc, v) => acc + v, 0);
    const p95Index = Math.min(sortedLatencies.length - 1, Math.floor(sortedLatencies.length * 0.95));

    return {
        Records: records,
        Summary: {
            Count: sortedLatencies.length,
            MinLatencyMs: sortedLatencies[0],
            MaxLatencyMs: sortedLatencies[sortedLatencies.length - 1],
            AvgLatencyMs: Math.round(total / sortedLatencies.length),
            P95LatencyMs: sortedLatencies[p95Index],
        },
    };
}
