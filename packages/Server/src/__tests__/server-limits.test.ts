import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import type { IMetadataProvider, IRunViewProvider, RunViewParams, UserInfo } from '@memberjunction/core';
import { TasksLimitsResolver } from '@mj-biz-apps/tasks-core/limits';
import { ReconcileStaleTimesheetApprovals } from '../scheduled-jobs/TimesheetApprovalReconcileJob.js';
import { CheckSourceTextStandards, CheckStandards } from '../../../../scripts/check-standards.mjs';
import {
    CANONICAL_LIMITS_CONFIG_REL,
    FindUnapprovedRunawayGuards,
    FindUnroutedBackendLimits,
    SweepLimitsLiterals,
} from '../../../../scripts/sweep-limits.mjs';

const REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '../../../..');

interface CapturedRunViewCall {
    EntityName: string;
    MaxRows?: number;
}

describe('Server Limits & Standards Enforcement', () => {
    beforeEach(() => {
        TasksLimitsResolver.Instance.ClearConfigOverrides();
        TasksLimitsResolver.Instance.InvalidateCache();
    });

    afterEach(() => {
        TasksLimitsResolver.Instance.ClearConfigOverrides();
        TasksLimitsResolver.Instance.InvalidateCache();
    });

    it('passes CheckStandards across the live repository with zero violations and CSV parity', () => {
        const result = CheckStandards({ repoRoot: REPO_ROOT });
        expect(result.violations).toEqual([]);
        expect(result.ok).toBe(true);
        expect(result.filesScanned).toBeGreaterThan(50);
        expect(result.sweepSummary.unapprovedRunawayCount).toBe(0);
        expect(result.sweepSummary.unroutedBackendCount).toBe(0);
    });

    it('rejects synthetic any, lazy unknown casts, non-catch unknown, and BaseEntity.Get/Set', () => {
        const badSource = [
            'export function sample(entity: { Get(f: string): string; Set(f: string, v: string): void }, raw: unknown) {',
            '    const a: any = 1;',
            '    const b = raw as unknown as Record<string, string>;',
            '    const c = raw as unknown;',
            '    const s = entity.Get("Status");',
            '    entity.Set("Status", "Completed");',
            '    return { a, b, c, s };',
            '}',
        ].join('\n');

        const res = CheckSourceTextStandards(badSource, 'packages/Server/src/synthetic/BadFile.ts', {
            strictUnknown: true,
        });
        const rules = res.violations.map((v: { rule: string }) => v.rule);

        expect(rules).toContain('no-any');
        expect(rules).toContain('no-unknown-record-cast');
        expect(rules).toContain('no-lazy-unknown');
        expect(rules).toContain('no-base-entity-get-set');
        expect(res.violations.length).toBeGreaterThanOrEqual(5);
    });

    it('allows standard catch (err: unknown) blocks under CheckSourceTextStandards', () => {
        const cleanSource = [
            'export function safeRun(fn: () => string): string {',
            '    try {',
            '        return fn();',
            '    } catch (err: unknown) {',
            '        return err instanceof Error ? err.message : String(err);',
            '    }',
            '}',
        ].join('\n');

        const res = CheckSourceTextStandards(cleanSource, 'packages/Server/src/synthetic/CleanFile.ts', {
            strictUnknown: true,
        });
        expect(res.violations).toEqual([]);
    });

    it('flags unrouted magic MaxRows, loop depth caps, and slice caps in synthetic TypeScript sources', () => {
        const tempRoot = mkdtempSync(join(tmpdir(), 'bizapps-tasks-limits-check-'));
        try {
            const synthFile = join(tempRoot, 'packages/Server/src/UnroutedService.ts');
            mkdirSync(dirname(synthFile), { recursive: true });
            writeFileSync(
                synthFile,
                [
                    'export function unroutedExample(text: string): number {',
                    '    const query = { EntityName: "MJ_BizApps_Tasks: Tasks", MaxRows: 500 };',
                    '    let sum = 0;',
                    '    for (let depth = 0; depth < 12; depth++) { sum += depth; }',
                    '    return query.MaxRows + sum + text.slice(0, 300).length;',
                    '}',
                ].join('\n'),
                'utf8',
            );

            const sweep = SweepLimitsLiterals({ repoRoot: tempRoot, roots: ['packages'] });
            const runaway = FindUnapprovedRunawayGuards(sweep.records);
            const unrouted = FindUnroutedBackendLimits(sweep.records);

            expect(runaway.length).toBe(1);
            expect(runaway[0]?.name).toBe('depth_LoopBound');
            expect(unrouted.map((u: { name: string }) => u.name).sort()).toEqual([
                'depth_LoopBound',
                'MaxRows',
                'text.slice_Cap',
            ].sort());
            expect(CANONICAL_LIMITS_CONFIG_REL).toBe('packages/Core/src/config/TasksLimits.ts');
        } finally {
            rmSync(tempRoot, { recursive: true, force: true });
        }
    });

    it('routes ReconcileStaleTimesheetApprovals MaxRows and ceiling through TasksLimitsResolver', async () => {
        const captured: CapturedRunViewCall[] = [];
        const fakeUser: UserInfo = { ID: '11111111-1111-4111-8111-111111111111' } as UserInfo;
        const fakeMd: IMetadataProvider = {} as IMetadataProvider;
        const fakeRv: IRunViewProvider = {
            RunView: vi.fn(async <T>(params: RunViewParams) => {
                captured.push({ EntityName: params.EntityName ?? '', MaxRows: params.MaxRows });
                return {
                    Success: true,
                    Results: [] as T[],
                    RowCount: 0,
                    TotalRowCount: 0,
                    ExecutionTime: 0,
                    ErrorMessage: '',
                    UserViewGridState: undefined,
                };
            }),
            RunViews: vi.fn(),
        };

        await ReconcileStaleTimesheetApprovals(fakeUser, undefined, fakeMd, fakeRv);
        expect(captured[0]?.MaxRows).toBe(200);

        TasksLimitsResolver.Instance.RegisterConfigOverrides({
            ResourceGuards: {
                ReconcileTimesheetApprovalsDefaultMaxRows: 17,
                ReconcileTimesheetApprovalsMaxRowsCeiling: 29,
            },
        });

        await ReconcileStaleTimesheetApprovals(fakeUser, undefined, fakeMd, fakeRv);
        expect(captured[1]?.MaxRows).toBe(17);

        await ReconcileStaleTimesheetApprovals(fakeUser, 500, fakeMd, fakeRv);
        expect(captured[2]?.MaxRows).toBe(29);
    });
});
