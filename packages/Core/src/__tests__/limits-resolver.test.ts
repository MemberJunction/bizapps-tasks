import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { beforeEach, describe, expect, it } from 'vitest';
import { LimitsConfigResolver } from '@memberjunction/core';
import {
    CODE_FALLBACK_TASKS_LIMITS,
    NormalizeTasksLimitsInput,
    ParseTasksLimitsFromEnv,
    SanitizeTasksLimitsOverride,
    TASKS_LIMITS_KEY_PATHS,
    TASKS_LIMIT_SAFETY_BOUNDS,
    TasksLimitsResolver,
    ValidateTasksLimitsConfig,
    type TasksLimitsConfig,
    type TasksLimitsJsonValue,
} from '../index.js';

interface SweepModule {
    CSV_HEADER: string;
    VALID_LABELS: ReadonlySet<string>;
    SweepLimitsLiterals: (options?: { repoRoot?: string; roots?: string[] }) => {
        filesScanned: number;
        records: Array<{
            file: string;
            line: number;
            name: string;
            value: string;
            enclosingFunction: string;
            label: string;
            disposition: string;
        }>;
    };
    FormatInventoryCsv: (
        records: Array<{
            file: string;
            line: number;
            name: string;
            value: string;
            enclosingFunction: string;
            label: string;
            disposition: string;
        }>,
    ) => string;
}

const REPO_ROOT = resolve(__dirname, '..', '..', '..', '..');

describe('TasksLimitsResolver (@mj-biz-apps/tasks-core)', () => {
    beforeEach(() => {
        LimitsConfigResolver.Instance.ClearMjConfigLimits();
        TasksLimitsResolver.Instance.ClearConfigOverrides();
        TasksLimitsResolver.Instance.InvalidateCache();
    });

    it('resolves all CodeFallback defaults and passes structural validation', () => {
        const result = TasksLimitsResolver.Resolve(
            { Env: null },
            { ResolvedAtISO: '2026-11-22T00:00:00.000Z' },
        );

        expect(result.ResolvedAtISO).toBe('2026-11-22T00:00:00.000Z');
        expect(result.OverriddenKeys).toEqual([]);
        expect(result.ClampedKeys).toEqual([]);
        expect(result.Limits).toEqual(CODE_FALLBACK_TASKS_LIMITS);
        expect(ValidateTasksLimitsConfig(result.Limits)).toEqual({ Valid: true, Issues: [] });

        for (const key of TASKS_LIMITS_KEY_PATHS) {
            expect(result.Provenance[key].SourceTier).toBe('CodeFallback');
            expect(result.Provenance[key].IsOverridden).toBe(false);
            expect(result.Provenance[key].WasClampedToSafetyCeiling).toBe(false);
            expect(TasksLimitsResolver.Instance.GetLimitValue(result, key)).toBe(result.Provenance[key].Value);
        }
    });

    it('propagates MJ LimitsConfigResolver briefing bounds into TasksLimitsConfig', () => {
        LimitsConfigResolver.Instance.RegisterMjConfigLimits({
            BriefingContributorTimeoutMs: 18_500,
            BriefingMaxContributorChars: 16_384,
        });

        const result = TasksLimitsResolver.Resolve({ Env: null });
        expect(result.Limits.Briefing.ContributorTimeoutMs).toBe(18_500);
        expect(result.Limits.Briefing.MaxContributorChars).toBe(16_384);
        expect(result.MjLimits.BriefingContributorTimeoutMs).toBe(18_500);
        expect(result.MjLimits.BriefingMaxContributorChars).toBe(16_384);
        expect(result.Provenance['Briefing.ContributorTimeoutMs'].SourceTier).toBe('MjLimitsConfig');
        expect(result.Provenance['Briefing.MaxContributorChars'].SourceTier).toBe('MjLimitsConfig');
    });

    it('resolves 5-tier precedence (CodeFallback < MjLimitsConfig < Env < AppConfig < RuntimeOverride)', () => {
        LimitsConfigResolver.Instance.RegisterMjConfigLimits({
            BriefingContributorTimeoutMs: 12_000,
        });
        TasksLimitsResolver.Instance.RegisterConfigOverrides({
            RunawayGuards: { MaxBulkTasks: 300, MaxHierarchyDepth: 60 },
            Briefing: { ContributorTimeoutMs: 14_000 },
        });

        const result = TasksLimitsResolver.Resolve({
            Env: {
                MJ_TASKS_LIMIT_MAX_BULK_TASKS: '400',
                MJ_TASKS_LIMIT_ZOOM_API_TIMEOUT_MS: '20000',
            },
            RuntimeOverride: {
                RunawayGuards: { MaxHierarchyDepth: 45 },
            },
        });

        expect(result.Limits.RunawayGuards.MaxBulkTasks).toBe(300);
        expect(result.Provenance['RunawayGuards.MaxBulkTasks'].SourceTier).toBe('AppConfig');
        expect(result.Provenance['RunawayGuards.MaxBulkTasks'].TierValues).toEqual({
            CodeFallback: 500,
            Env: 400,
            AppConfig: 300,
        });

        expect(result.Limits.RunawayGuards.MaxHierarchyDepth).toBe(45);
        expect(result.Provenance['RunawayGuards.MaxHierarchyDepth'].SourceTier).toBe('RuntimeOverride');

        expect(result.Limits.ResourceGuards.ZoomApiTimeoutMs).toBe(20_000);
        expect(result.Provenance['ResourceGuards.ZoomApiTimeoutMs'].SourceTier).toBe('Env');

        expect(result.Limits.Briefing.ContributorTimeoutMs).toBe(14_000);
        expect(result.Provenance['Briefing.ContributorTimeoutMs'].SourceTier).toBe('AppConfig');
    });

    it('parses MJ_TASKS_LIMITS_JSON and section-qualified env overrides safely', () => {
        const parsed = ParseTasksLimitsFromEnv({
            MJ_TASKS_LIMITS_JSON: JSON.stringify({
                runawayGuards: { maxSupervisorChainDepth: 6 },
                resourceGuards: { sqlInClauseChunkSize: 50 },
            }),
            MJ_TASKS_LIMIT_RESOURCE_GUARDS_SUBTREE_EFFORT_MAX_ROWS: '2500',
            MJ_TASKS_LIMIT_MAX_SAVED_TASK_VIEWS: '40',
        });

        expect(parsed).toEqual({
            RunawayGuards: { MaxSupervisorChainDepth: 6 },
            ResourceGuards: {
                SqlInClauseChunkSize: 50,
                SubtreeEffortMaxRows: 2500,
                MaxSavedTaskViews: 40,
            },
        });
    });

    it('rejects NaN, <= 0, Infinity, and malformed override strings so guards can never be disabled', () => {
        const rawBadJson: TasksLimitsJsonValue = {
            runawayGuards: {
                maxBulkTasks: 0,
                maxHierarchyDepth: -5,
                maxSupervisorChainDepth: Number.NaN,
                briefingMaxItemsCeiling: Number.POSITIVE_INFINITY,
                maxSeriesOccurrences: 'not-a-number',
            },
            resourceGuards: {
                defaultLookupSingleRow: -1,
                subtreeEffortMaxRows: Number.NEGATIVE_INFINITY,
                zoomApiTimeoutMs: 0,
            },
        };
        expect(NormalizeTasksLimitsInput(rawBadJson)).toEqual({});

        const badTyped = SanitizeTasksLimitsOverride({
            RunawayGuards: {
                MaxBulkTasks: Number.NaN,
                MaxHierarchyDepth: 0,
                MaxSupervisorChainDepth: -3,
                MaxDependencyWalkIterations: Number.POSITIVE_INFINITY,
                MaxTemplateSortIterations: 0.4,
            },
            ResourceGuards: {
                FindTasksMaxRowsCeiling: -100,
                TeamsWebhookTimeoutMs: 50, // below min 100
            },
        });
        expect(badTyped).toEqual({});

        const envParsed = ParseTasksLimitsFromEnv({
            MJ_TASKS_LIMITS_JSON: '{invalid-json',
            MJ_TASKS_LIMIT_MAX_BULK_TASKS: 'NaN',
            MJ_TASKS_LIMIT_MAX_HIERARCHY_DEPTH: '0',
            MJ_TASKS_LIMIT_MAX_SUPERVISOR_CHAIN_DEPTH: '-10',
            MJ_TASKS_LIMIT_BRIEFING_MAX_ITEMS_CEILING: 'Infinity',
            MJ_TASKS_LIMIT_SUBTREE_EFFORT_MAX_ROWS: '12abc',
            MJ_TASKS_LIMIT_ZOOM_API_TIMEOUT_MS: '',
        });
        expect(envParsed).toEqual({});

        const resolved = TasksLimitsResolver.Resolve({
            Env: {
                MJ_TASKS_LIMIT_MAX_BULK_TASKS: '-1',
                MJ_TASKS_LIMIT_MAX_HIERARCHY_DEPTH: 'NaN',
            },
            RuntimeOverride: {
                RunawayGuards: { MaxBulkTasks: 0, BriefingMaxItemsCeiling: Number.NaN },
                ResourceGuards: { SubtreeEffortMaxRows: Number.POSITIVE_INFINITY },
            },
        });

        expect(resolved.Limits).toEqual(CODE_FALLBACK_TASKS_LIMITS);
        expect(ValidateTasksLimitsConfig(resolved.Limits).Valid).toBe(true);
    });

    it('clamps oversized finite overrides to per-key safety ceilings and enforces default <= ceiling', () => {
        const result = TasksLimitsResolver.Resolve({
            Env: {
                MJ_TASKS_LIMIT_MAX_BULK_TASKS: '999999999',
                MJ_TASKS_LIMIT_BRIEFING_MAX_ITEMS_CEILING: '5',
            },
            RuntimeOverride: {
                RunawayGuards: { MaxHierarchyDepth: 50_000 },
                ResourceGuards: { ZoomApiTimeoutMs: 9_999_999 },
            },
        });

        expect(result.Limits.RunawayGuards.MaxBulkTasks).toBe(
            TASKS_LIMIT_SAFETY_BOUNDS['RunawayGuards.MaxBulkTasks'].max,
        );
        expect(result.Limits.RunawayGuards.MaxHierarchyDepth).toBe(
            TASKS_LIMIT_SAFETY_BOUNDS['RunawayGuards.MaxHierarchyDepth'].max,
        );
        expect(result.Limits.ResourceGuards.ZoomApiTimeoutMs).toBe(
            TASKS_LIMIT_SAFETY_BOUNDS['ResourceGuards.ZoomApiTimeoutMs'].max,
        );
        expect(result.Limits.Briefing.DefaultBriefingMaxItems).toBe(5);
        expect(result.ClampedKeys).toContain('RunawayGuards.MaxBulkTasks');
        expect(result.ClampedKeys).toContain('RunawayGuards.MaxHierarchyDepth');
        expect(result.ClampedKeys).toContain('ResourceGuards.ZoomApiTimeoutMs');
        expect(result.ClampedKeys).toContain('Briefing.DefaultBriefingMaxItems');
        expect(result.Provenance['RunawayGuards.MaxBulkTasks'].WasClampedToSafetyCeiling).toBe(true);
        expect(ValidateTasksLimitsConfig(result.Limits).Valid).toBe(true);
    });

    it('memoizes GetCurrentLimits() and invalidates on RegisterConfigOverrides or LimitsConfigResolver updates', () => {
        const initial = TasksLimitsResolver.Instance.GetCurrentLimits();
        expect(TasksLimitsResolver.Instance.GetCurrentLimits()).toBe(initial);

        TasksLimitsResolver.Instance.RegisterConfigOverrides({
            RunawayGuards: { MaxBulkTasks: 222 },
        });
        const afterAppOverride = TasksLimitsResolver.Instance.GetCurrentLimits();
        expect(afterAppOverride).not.toBe(initial);
        expect(afterAppOverride.RunawayGuards.MaxBulkTasks).toBe(222);

        LimitsConfigResolver.Instance.RegisterMjConfigLimits({
            BriefingContributorTimeoutMs: 15_500,
        });
        const afterMjOverride = TasksLimitsResolver.Instance.GetCurrentLimits();
        expect(afterMjOverride.Briefing.ContributorTimeoutMs).toBe(15_500);
    });

    it('ValidateTasksLimitsConfig rejects manually constructed invalid configs', () => {
        const invalid: TasksLimitsConfig = {
            ...CODE_FALLBACK_TASKS_LIMITS,
            RunawayGuards: {
                ...CODE_FALLBACK_TASKS_LIMITS.RunawayGuards,
                MaxBulkTasks: 0,
                BriefingMaxItemsCeiling: 5,
            },
            Briefing: {
                ...CODE_FALLBACK_TASKS_LIMITS.Briefing,
                DefaultBriefingMaxItems: 20,
            },
        };

        const validation = ValidateTasksLimitsConfig(invalid);
        expect(validation.Valid).toBe(false);
        expect(validation.Issues.some((i) => i.Key === 'RunawayGuards.MaxBulkTasks')).toBe(true);
        expect(validation.Issues.some((i) => i.Key === 'Briefing.DefaultBriefingMaxItems')).toBe(true);
    });

    it('runs sweep-limits.mjs deterministically and matches committed classified CSV reports', async () => {
        const sweepMod = (await import('../../../../scripts/sweep-limits.mjs')) as SweepModule;
        const first = sweepMod.SweepLimitsLiterals({ repoRoot: REPO_ROOT });
        const second = sweepMod.SweepLimitsLiterals({ repoRoot: REPO_ROOT });

        expect(first.filesScanned).toBeGreaterThan(100);
        expect(first.records.length).toBeGreaterThan(100);

        const csv1 = sweepMod.FormatInventoryCsv(first.records);
        const csv2 = sweepMod.FormatInventoryCsv(second.records);
        expect(csv1).toBe(csv2);

        const committedScriptsCsv = readFileSync(resolve(REPO_ROOT, 'scripts/limits-sweep-classified.csv'), 'utf8');
        const committedSpecsCsv = readFileSync(resolve(REPO_ROOT, '.mj/specs/limits-sweep-bizapps-tasks.csv'), 'utf8');
        expect(committedScriptsCsv).toBe(csv1);
        expect(committedSpecsCsv).toBe(csv1);

        const lines = csv1.trimEnd().split('\n');
        expect(lines[0]).toBe(sweepMod.CSV_HEADER);
        for (const rec of first.records) {
            expect(rec.file.length).toBeGreaterThan(0);
            expect(rec.line).toBeGreaterThan(0);
            expect(rec.name.length).toBeGreaterThan(0);
            expect(rec.value.length).toBeGreaterThan(0);
            expect(sweepMod.VALID_LABELS.has(rec.label)).toBe(true);
            expect(rec.disposition.length).toBeGreaterThan(0);
        }

        const filesPresent = new Set(first.records.map((r) => r.file));
        expect(filesPresent.has('packages/Core/src/config/TasksLimits.ts')).toBe(true);
        expect(filesPresent.has('packages/Core/src/services/WorkReportService.ts')).toBe(true);
        expect(filesPresent.has('packages/Actions/src/custom/TaskTypedActions.ts')).toBe(true);
        expect(filesPresent.has('packages/EntitiesServer/src/TasksRemoteOperationsServer.ts')).toBe(true);
    });
});
