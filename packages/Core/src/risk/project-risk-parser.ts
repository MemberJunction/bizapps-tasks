import { TryParseTaskRiskItems, type TaskRiskItem } from '@mj-biz-apps/tasks-entities';
import { TasksLimitsResolver } from '../config/TasksLimits.js';
import type {
    ProjectRiskAgentStructuredOutput,
    ProjectRiskHealthStatusValue,
} from './project-risk-types.js';

/** Raw JSON payload shape expected from the Project Risk Analyst agent. */
export interface ProjectRiskAgentRawPayload {
    healthStatus?: string | null;
    HealthStatus?: string | null;
    forecastCompletionDate?: string | Date | null;
    ForecastCompletionDate?: string | Date | null;
    forecastConfidence?: number | string | null;
    ForecastConfidence?: number | string | null;
    summary?: string | null;
    Summary?: string | null;
    risks?: readonly ProjectRiskAgentRawRiskItem[] | string | null;
    Risks?: readonly ProjectRiskAgentRawRiskItem[] | string | null;
}

/** Raw risk item shape accepted prior to strict schema validation. */
export interface ProjectRiskAgentRawRiskItem {
    kind?: string;
    severity?: string;
    evidenceLinks?: readonly string[];
    suggestedMitigation?: string;
}

function normalizeHealthStatus(raw: string | null | undefined): ProjectRiskHealthStatusValue | null {
    if (!raw) return null;
    const compact = raw.trim().toLowerCase().replace(/[\s_-]+/g, '');
    switch (compact) {
        case 'ontrack':
            return 'OnTrack';
        case 'atrisk':
            return 'AtRisk';
        case 'offtrack':
            return 'OffTrack';
        case 'completed':
        case 'complete':
            return 'Completed';
        case 'paused':
            return 'Paused';
        default:
            return null;
    }
}

function parseOptionalDate(raw: string | Date | null | undefined): Date | null {
    if (raw == null) return null;
    if (raw instanceof Date) {
        return Number.isNaN(raw.getTime()) ? null : raw;
    }
    const trimmed = raw.trim();
    if (!trimmed) return null;
    const parsed = new Date(trimmed);
    if (Number.isNaN(parsed.getTime())) {
        throw new Error(`Project Risk Analyst returned invalid forecastCompletionDate '${trimmed}'.`);
    }
    return parsed;
}

function parseConfidenceScore(raw: number | string | null | undefined): number {
    if (raw == null || raw === '') {
        throw new Error('Project Risk Analyst response is missing required forecastConfidence.');
    }
    const num = typeof raw === 'number' ? raw : Number(raw);
    if (!Number.isFinite(num)) {
        throw new Error(`Project Risk Analyst returned non-numeric forecastConfidence '${String(raw)}'.`);
    }
    // ProtocolLimit: ForecastConfidence schema percentage range [0, 100]
    return Math.max(0, Math.min(100, Math.round(num)));
}

function stripJsonFence(rawText: string): string {
    const trimmed = rawText.trim();
    return trimmed
        .replace(/^```(?:json)?\s*/i, '')
        .replace(/\s*```$/i, '')
        .trim();
}

function parseRawObject(
    raw: string | ProjectRiskAgentRawPayload | null | undefined,
): ProjectRiskAgentRawPayload {
    if (raw == null) {
        throw new Error('Project Risk Analyst returned an empty response payload.');
    }
    if (typeof raw === 'object') {
        return raw;
    }
    const cleaned = stripJsonFence(raw);
    if (!cleaned) {
        throw new Error('Project Risk Analyst returned an empty string payload.');
    }
    try {
        return JSON.parse(cleaned) as ProjectRiskAgentRawPayload;
    } catch {
        const firstBrace = cleaned.indexOf('{');
        const lastBrace = cleaned.lastIndexOf('}');
        if (firstBrace >= 0 && lastBrace > firstBrace) {
            return JSON.parse(cleaned.slice(firstBrace, lastBrace + 1)) as ProjectRiskAgentRawPayload;
        }
        throw new Error('Project Risk Analyst did not return valid JSON.');
    }
}

/**
 * Parses and validates the JSON payload produced by the `Project Risk Analyst` agent
 * into strongly-typed fields ready for {@link TaskRiskAssessmentEntity} persistence.
 */
export function ParseProjectRiskAgentOutput(
    raw: string | ProjectRiskAgentRawPayload | null | undefined,
): ProjectRiskAgentStructuredOutput {
    const obj = parseRawObject(raw);
    const healthStatus = normalizeHealthStatus(obj.healthStatus ?? obj.HealthStatus);
    if (!healthStatus) {
        throw new Error(
            `Project Risk Analyst returned invalid or missing healthStatus '${String(obj.healthStatus ?? obj.HealthStatus ?? '')}'.`,
        );
    }

    const forecastConfidence = parseConfidenceScore(obj.forecastConfidence ?? obj.ForecastConfidence);
    const forecastCompletionDate = parseOptionalDate(
        obj.forecastCompletionDate ?? obj.ForecastCompletionDate,
    );

    const rawRisks = obj.risks ?? obj.Risks ?? [];
    const serializedRisks = typeof rawRisks === 'string' ? rawRisks : JSON.stringify(rawRisks);
    const parsedRisks = TryParseTaskRiskItems(serializedRisks);
    if (!parsedRisks.valid) {
        throw new Error(`Project Risk Analyst returned invalid risks array: ${parsedRisks.error ?? 'validation failed'}`);
    }

    const excerptLimit = TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.FailureNotesMaxChars;
    const rawSummary = (obj.summary ?? obj.Summary ?? '').trim();
    const summary = rawSummary.slice(0, excerptLimit);

    const risks: TaskRiskItem[] = parsedRisks.items;
    return {
        HealthStatus: healthStatus,
        ForecastCompletionDate: forecastCompletionDate,
        ForecastConfidence: forecastConfidence,
        Summary: summary,
        Risks: risks,
    };
}
