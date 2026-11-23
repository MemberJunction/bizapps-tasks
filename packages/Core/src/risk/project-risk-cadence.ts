import { TasksLimitsResolver } from '../config/TasksLimits.js';
import type {
    ProjectRiskCadence,
    ProjectRiskCadenceEvaluation,
    ProjectRiskCadenceInput,
    ProjectTaskStatusValue,
} from './project-risk-types.js';

const MS_PER_HOUR = 3_600_000;
const PERCENT_DIVISOR = 100;
const RATIO_PRECISION_FACTOR = 10_000;
const BOUNDARY_EPSILON = 1e-9;

const TERMINAL_TASK_STATUSES = new Set<ProjectTaskStatusValue>(['Completed', 'Cancelled']);

function toValidDate(value: Date | string | null | undefined): Date | null {
    if (value == null) return null;
    const d = value instanceof Date ? value : new Date(value);
    return Number.isNaN(d.getTime()) ? null : d;
}

function roundRatio(ratio: number): number {
    return Math.round(ratio * RATIO_PRECISION_FACTOR) / RATIO_PRECISION_FACTOR;
}

function computeNextDueAt(latestAssessedAt: Date | null, intervalHours: number, now: Date): Date {
    if (!latestAssessedAt) {
        return now;
    }
    return new Date(latestAssessedAt.getTime() + intervalHours * MS_PER_HOUR);
}

/**
 * Deterministically evaluates the Project Risk Analyst review cadence for a project root task:
 * - Skips scheduled runs when the root task is in a terminal status (`Completed` or `Cancelled`).
 * - Uses `Weekly` cadence during the first 80% of the timeline (and when timeline bounds are missing).
 * - Escalates automatically to `Daily` cadence when the project enters the final 20% of its timeline
 *   (`remainingRatio <= 0.20`, i.e., `elapsedRatio >= 0.80`) or becomes overdue.
 * - Applies cooldown deduplication when a fresh assessment already exists within the active cadence window.
 */
export function EvaluateProjectRiskCadence(input: ProjectRiskCadenceInput): ProjectRiskCadenceEvaluation {
    const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
    const weeklyHours = limits.Tuning.RiskAnalystWeeklyCadenceHours;
    const dailyHours = limits.Tuning.RiskAnalystDailyCadenceHours;
    const finalWindowRatio = limits.Tuning.RiskAnalystFinalWindowPercent / PERCENT_DIVISOR;

    const now = input.Now ?? new Date();
    const nowMs = now.getTime();
    const latestAssessedAt = toValidDate(input.LatestAssessedAt);

    if (TERMINAL_TASK_STATUSES.has(input.TaskStatus)) {
        return {
            Cadence: 'Weekly',
            IntervalHours: weeklyHours,
            ElapsedRatio: null,
            RemainingRatio: null,
            IsFinal20Percent: false,
            IsOverdue: false,
            Reason: 'TerminalTaskStatus',
            ShouldSkipScheduledRun: true,
            SkipReason: `Root project task is in terminal status '${input.TaskStatus}'.`,
            NextDueAt: null,
        };
    }

    const startDate = toValidDate(input.StartedAt) ?? toValidDate(input.CreatedAt);
    const dueDate = toValidDate(input.DueAt);

    let cadence: ProjectRiskCadence = 'Weekly';
    let intervalHours = weeklyHours;
    let elapsedRatio: number | null = null;
    let remainingRatio: number | null = null;
    let isFinal20Percent = false;
    let isOverdue = false;
    let reason: ProjectRiskCadenceEvaluation['Reason'] = 'MissingTimelineDates';

    if (dueDate && (!startDate || dueDate.getTime() <= startDate.getTime())) {
        if (nowMs > dueDate.getTime()) {
            cadence = 'Daily';
            intervalHours = dailyHours;
            isFinal20Percent = true;
            isOverdue = true;
            reason = 'Overdue';
        }
    } else if (startDate && dueDate && dueDate.getTime() > startDate.getTime()) {
        const startMs = startDate.getTime();
        const dueMs = dueDate.getTime();
        const totalMs = dueMs - startMs;

        if (nowMs > dueMs) {
            cadence = 'Daily';
            intervalHours = dailyHours;
            elapsedRatio = roundRatio((nowMs - startMs) / totalMs);
            remainingRatio = 0;
            isFinal20Percent = true;
            isOverdue = true;
            reason = 'Overdue';
        } else if (nowMs <= startMs) {
            cadence = 'Weekly';
            intervalHours = weeklyHours;
            elapsedRatio = 0;
            remainingRatio = 1;
            isFinal20Percent = false;
            isOverdue = false;
            reason = 'First80Percent';
        } else {
            const rawElapsed = (nowMs - startMs) / totalMs;
            const rawRemaining = (dueMs - nowMs) / totalMs;
            elapsedRatio = roundRatio(rawElapsed);
            remainingRatio = roundRatio(rawRemaining);

            if (rawRemaining <= finalWindowRatio + BOUNDARY_EPSILON) {
                cadence = 'Daily';
                intervalHours = dailyHours;
                isFinal20Percent = true;
                reason = 'Final20Percent';
            } else {
                cadence = 'Weekly';
                intervalHours = weeklyHours;
                isFinal20Percent = false;
                reason = 'First80Percent';
            }
        }
    }

    const nextDueAt = computeNextDueAt(latestAssessedAt, intervalHours, now);
    const withinCooldown = latestAssessedAt !== null && nowMs < nextDueAt.getTime();

    return {
        Cadence: cadence,
        IntervalHours: intervalHours,
        ElapsedRatio: elapsedRatio,
        RemainingRatio: remainingRatio,
        IsFinal20Percent: isFinal20Percent,
        IsOverdue: isOverdue,
        Reason: reason,
        ShouldSkipScheduledRun: withinCooldown,
        SkipReason: withinCooldown
            ? `Fresh Task Risk Assessment already exists within the active ${cadence} cadence window (next due ${nextDueAt.toISOString()}).`
            : null,
        NextDueAt: nextDueAt,
    };
}
