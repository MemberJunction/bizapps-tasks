import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { LimitsConfigResolver } from '@memberjunction/core';
import {
    CODE_FALLBACK_TASKS_LIMITS,
    ResolveBriefingContributorBounds,
    RunWithBriefingContributorTimeout,
    SerializeBriefingPayloadWithLimit,
    TasksLimitsResolver,
} from '../index.js';

interface BriefingSamplePayload {
    Success: boolean;
    Tasks: Array<{ ID: string; Title: string }>;
    Highlights: string[];
}

describe('BriefingLimitsHelper & TasksLimitsResolver briefing overrides', () => {
    beforeEach(() => {
        TasksLimitsResolver.Instance.ClearConfigOverrides();
        LimitsConfigResolver.Instance.ClearMjConfigLimits();
        TasksLimitsResolver.Instance.InvalidateCache();
    });

    afterEach(() => {
        TasksLimitsResolver.Instance.ClearConfigOverrides();
        LimitsConfigResolver.Instance.ClearMjConfigLimits();
        TasksLimitsResolver.Instance.InvalidateCache();
    });

    it('resolves CodeFallback briefing bounds for meetings vs workReports lookback kinds', () => {
        const meetings = ResolveBriefingContributorBounds({ LookbackKind: 'meetings' });
        const reports = ResolveBriefingContributorBounds({ LookbackKind: 'workReports' });

        expect(meetings).toEqual({
            HorizonDays: CODE_FALLBACK_TASKS_LIMITS.Briefing.DefaultBriefingHorizonDays,
            LookbackDays: CODE_FALLBACK_TASKS_LIMITS.Briefing.DefaultMeetingsBriefingLookbackDays,
            MaxItems: CODE_FALLBACK_TASKS_LIMITS.Briefing.DefaultBriefingMaxItems,
            ContributorTimeoutMs: CODE_FALLBACK_TASKS_LIMITS.Briefing.ContributorTimeoutMs,
            MaxContributorChars: CODE_FALLBACK_TASKS_LIMITS.Briefing.MaxContributorChars,
        });

        expect(reports.LookbackDays).toBe(CODE_FALLBACK_TASKS_LIMITS.Briefing.DefaultWorkReportsBriefingLookbackDays);
        expect(reports.MaxItems).toBe(CODE_FALLBACK_TASKS_LIMITS.Briefing.DefaultBriefingMaxItems);
    });

    it('honors TasksLimitsResolver AppConfig overrides and MJ LimitsConfigResolver propagation', () => {
        LimitsConfigResolver.Instance.RegisterMjConfigLimits({
            BriefingContributorTimeoutMs: 4200,
            BriefingMaxContributorChars: 6400,
        });
        TasksLimitsResolver.Instance.RegisterConfigOverrides({
            Briefing: {
                DefaultBriefingHorizonDays: 12,
                DefaultBriefingMaxItems: 18,
                DefaultMeetingsBriefingLookbackDays: 9,
                DefaultWorkReportsBriefingLookbackDays: 21,
            },
            RunawayGuards: {
                BriefingMaxHorizonDays: 20,
                BriefingMaxItemsCeiling: 25,
                BriefingMaxLookbackDays: 15,
                BriefingWorkReportsMaxLookbackDays: 45,
            },
        });

        const meetings = ResolveBriefingContributorBounds({ LookbackKind: 'meetings' });
        const reports = ResolveBriefingContributorBounds({ LookbackKind: 'workReports' });

        expect(meetings).toEqual({
            HorizonDays: 12,
            LookbackDays: 9,
            MaxItems: 18,
            ContributorTimeoutMs: 4200,
            MaxContributorChars: 6400,
        });
        expect(reports.LookbackDays).toBe(21);

        // Explicit AppConfig Briefing overrides take precedence over MjLimitsConfig
        TasksLimitsResolver.Instance.RegisterConfigOverrides({
            Briefing: {
                ContributorTimeoutMs: 2500,
                MaxContributorChars: 4096,
            },
        });
        const overridden = ResolveBriefingContributorBounds();
        expect(overridden.ContributorTimeoutMs).toBe(2500);
        expect(overridden.MaxContributorChars).toBe(4096);
    });

    it('clamps caller briefing inputs to configured RunawayGuards ceilings and minimum 1', () => {
        TasksLimitsResolver.Instance.RegisterConfigOverrides({
            RunawayGuards: {
                BriefingMaxHorizonDays: 14,
                BriefingMaxLookbackDays: 10,
                BriefingWorkReportsMaxLookbackDays: 30,
                BriefingMaxItemsCeiling: 12,
            },
        });

        const oversized = ResolveBriefingContributorBounds({
            HorizonDays: 999,
            LookbackDays: 999,
            MaxItems: 999,
            LookbackKind: 'meetings',
        });
        expect(oversized.HorizonDays).toBe(14);
        expect(oversized.LookbackDays).toBe(10);
        expect(oversized.MaxItems).toBe(12);

        const undersized = ResolveBriefingContributorBounds({
            HorizonDays: -5,
            LookbackDays: 0,
            MaxItems: 0,
            LookbackKind: 'workReports',
        });
        expect(undersized.HorizonDays).toBe(1);
        expect(undersized.LookbackDays).toBe(1);
        expect(undersized.MaxItems).toBe(1);
    });

    it('enforces ContributorTimeoutMs via RunWithBriefingContributorTimeout', async () => {
        TasksLimitsResolver.Instance.RegisterConfigOverrides({
            Briefing: { ContributorTimeoutMs: 120 },
        });

        const fast = await RunWithBriefingContributorTimeout(async () => 'ok');
        expect(fast).toBe('ok');

        const timeoutMs = TasksLimitsResolver.Instance.GetCurrentLimits().Briefing.ContributorTimeoutMs;
        expect(timeoutMs).toBe(120);

        await expect(
            RunWithBriefingContributorTimeout(
                () => new Promise<string>((resolvePromise) => setTimeout(() => resolvePromise('late'), 350)),
                timeoutMs,
                'Tasks briefing test contributor',
            ),
        ).rejects.toThrow(/Tasks briefing test contributor timed out after 120ms/);
    });

    it('trims longest arrays round-robin when SerializeBriefingPayloadWithLimit exceeds MaxContributorChars', () => {
        TasksLimitsResolver.Instance.RegisterConfigOverrides({
            Briefing: { MaxContributorChars: 280 },
        });

        const payload: BriefingSamplePayload = {
            Success: true,
            Tasks: [
                { ID: '1', Title: 'First high priority deliverable item with detailed context' },
                { ID: '2', Title: 'Second deliverable item with long title and description' },
                { ID: '3', Title: 'Third deliverable item that pushes serialized json past ceiling' },
                { ID: '4', Title: 'Fourth deliverable item exceeding the 280 character ceiling easily' },
            ],
            Highlights: ['Alpha milestone', 'Beta milestone', 'Gamma milestone'],
        };

        const full = SerializeBriefingPayloadWithLimit(payload, ['Tasks', 'Highlights'], 5000);
        expect(full.Truncated).toBe(false);
        expect((JSON.parse(full.Json) as BriefingSamplePayload).Tasks).toHaveLength(4);

        const bounded = SerializeBriefingPayloadWithLimit(payload, ['Tasks', 'Highlights']);
        expect(bounded.Truncated).toBe(true);
        expect(bounded.Json.length).toBeLessThanOrEqual(280);
        const parsed = JSON.parse(bounded.Json) as BriefingSamplePayload;
        expect(parsed.Success).toBe(true);
        expect(parsed.Tasks.length).toBeLessThan(4);
    });
});
