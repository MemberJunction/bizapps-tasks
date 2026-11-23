import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import {
    EvaluateProjectRiskCadence,
    ParseProjectRiskAgentOutput,
    TasksLimitsResolver,
} from '@mj-biz-apps/tasks-core';

describe('Project Risk Cadence & Output Parser', () => {
    beforeEach(() => {
        TasksLimitsResolver.Instance.ClearConfigOverrides();
        TasksLimitsResolver.Instance.InvalidateCache();
    });

    afterEach(() => {
        TasksLimitsResolver.Instance.ClearConfigOverrides();
        TasksLimitsResolver.Instance.InvalidateCache();
    });

    it('honors TasksLimitsResolver overrides for cadence intervals and final window percentage', () => {
        TasksLimitsResolver.Instance.RegisterConfigOverrides({
            Tuning: {
                RiskAnalystWeeklyCadenceHours: 120,
                RiskAnalystDailyCadenceHours: 12,
                RiskAnalystFinalWindowPercent: 25,
            },
        });

        const start = new Date('2026-11-01T00:00:00.000Z');
        const due = new Date('2026-11-05T04:00:00.000Z'); // 100 hours

        // 74% elapsed -> 26% remaining -> Weekly (120h)
        const early = EvaluateProjectRiskCadence({
            TaskStatus: 'InProgress',
            StartedAt: start,
            DueAt: due,
            Now: new Date('2026-11-04T02:00:00.000Z'),
        });
        expect(early.Cadence).toBe('Weekly');
        expect(early.IntervalHours).toBe(120);

        // 75% elapsed -> 25% remaining -> Daily (12h) under overridden 25% threshold
        const finalQuarter = EvaluateProjectRiskCadence({
            TaskStatus: 'InProgress',
            StartedAt: start,
            DueAt: due,
            Now: new Date('2026-11-04T03:00:00.000Z'),
        });
        expect(finalQuarter.Cadence).toBe('Daily');
        expect(finalQuarter.IntervalHours).toBe(12);
        expect(finalQuarter.IsFinal20Percent).toBe(true);
    });

    it('parses markdown-fenced JSON output and clamps confidence into 0..100', () => {
        const raw = [
            '```json',
            JSON.stringify({
                healthStatus: 'off_track',
                forecastCompletionDate: '2026-12-05T17:00:00.000Z',
                forecastConfidence: 108,
                summary: 'Multiple critical path blockers.',
                risks: [
                    {
                        kind: 'overdue_subtasks',
                        severity: 'critical',
                        evidenceLinks: ['/resource/record/MJ_BizApps_Tasks%3A%20Tasks/abc'],
                        suggestedMitigation: 'Reassign overdue subtasks immediately.',
                    },
                ],
            }),
            '```',
        ].join('\n');

        const parsed = ParseProjectRiskAgentOutput(raw);
        expect(parsed.HealthStatus).toBe('OffTrack');
        expect(parsed.ForecastConfidence).toBe(100);
        expect(parsed.ForecastCompletionDate?.toISOString()).toBe('2026-12-05T17:00:00.000Z');
        expect(parsed.Risks).toHaveLength(1);
        expect(parsed.Risks[0].severity).toBe('critical');
    });

    it('rejects invalid healthStatus or malformed risks entries', () => {
        expect(() =>
            ParseProjectRiskAgentOutput({
                healthStatus: 'BogusStatus',
                forecastConfidence: 50,
                risks: [],
            }),
        ).toThrow(/healthStatus/i);

        expect(() =>
            ParseProjectRiskAgentOutput({
                healthStatus: 'AtRisk',
                forecastConfidence: 50,
                risks: [
                    {
                        kind: 'dependency_blocker',
                        severity: 'extreme',
                        evidenceLinks: [],
                        suggestedMitigation: 'N/A',
                    },
                ],
            }),
        ).toThrow(/invalid risks array/i);
    });
});
