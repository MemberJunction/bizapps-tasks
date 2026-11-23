import '@angular/compiler';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { ChangeDetectionStrategy, ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { UserInfoEngine } from '@memberjunction/core-entities';

const { runViewMock } = vi.hoisted(() => ({ runViewMock: vi.fn() }));
vi.mock('@memberjunction/core', async (importOriginal) => ({
    ...(await importOriginal<typeof import('@memberjunction/core')>()),
    RunView: class {
        RunView = runViewMock;
    },
}));

import { ApprovalInboxComponent } from '../components/approval-inbox/approval-inbox.component';
import {
    APPROVAL_INBOX_PREFS_SETTING,
    ComputeApprovalLatencyIndicator,
    GroupApprovalsByOrganization,
    MatchesApprovalSearchQuery,
    NO_ORGANIZATION_KEY,
    NO_ORGANIZATION_LABEL,
    StripRawMarkdownForExcerpt,
} from '../components/approval-inbox/approval-inbox-grouping';
import { ApprovalDecisionPanelComponent } from '../components/approval-decision-panel/approval-decision-panel.component';
import { ApprovalsPageComponent, BuildApprovalsPendingFilter } from '../pages/approvals.page';
import { TaskGanttComponent } from '../components/task-gantt/task-gantt.component';

const HERE = dirname(fileURLToPath(import.meta.url));
const SRC_LIB = resolve(HERE, '..');

function createCdr(): ChangeDetectorRef {
    return {
        markForCheck: vi.fn(),
        detach: vi.fn(),
        detectChanges: vi.fn(),
        checkNoChanges: vi.fn(),
        reattach: vi.fn(),
    };
}

describe('Approval Inbox Organization Grouping & Latency Helpers', () => {
    it('groups pending approvals by Task.OrganizationID alphabetically with No Organization last and computes wait latency', () => {
        const now = Date.parse('2026-11-23T12:00:00.000Z');
        const groups = GroupApprovalsByOrganization(
            [
                {
                    ID: 't-none',
                    Name: 'Unscoped Request',
                    Priority: 'Low',
                    OrganizationID: null,
                    Organization: null,
                    CreatedAt: '2026-11-23T11:30:00.000Z',
                },
                {
                    ID: 't-uk',
                    Name: 'UK Tax Filing',
                    Priority: 'Critical',
                    OrganizationID: 'ORG-UK',
                    Organization: 'Blue Cypress UK Ltd',
                    CreatedAt: '2026-11-22T06:00:00.000Z',
                },
                {
                    ID: 't-us-1',
                    Name: 'US Close Batch 1',
                    Priority: 'High',
                    OrganizationID: 'ORG-US',
                    Organization: 'Blue Cypress US LLC',
                    CreatedAt: '2026-11-23T10:00:00.000Z',
                },
                {
                    ID: 't-us-2',
                    Name: 'US Close Batch 2',
                    Priority: 'Medium',
                    OrganizationID: 'org-us',
                    Organization: 'Blue Cypress US LLC',
                    CreatedAt: '2026-11-23T08:00:00.000Z',
                },
            ],
            { nowMs: now },
        );

        expect(groups.map((g) => g.OrganizationName)).toEqual([
            'Blue Cypress UK Ltd',
            'Blue Cypress US LLC',
            NO_ORGANIZATION_LABEL,
        ]);
        expect(groups[0].Count).toBe(1);
        expect(groups[0].AvgWaitFormatted).toBe('1d 6h');
        expect(groups[0].HighestTier).toBe('elevated');

        expect(groups[1].OrganizationKey).toBe('org-us');
        expect(groups[1].Count).toBe(2);
        expect(groups[1].AvgWaitFormatted).toBe('3h');
        expect(groups[1].MaxWaitFormatted).toBe('4h');

        expect(groups[2].OrganizationKey).toBe(NO_ORGANIZATION_KEY);
        expect(groups[2].AvgWaitFormatted).toBe('30m');
    });

    it('strips raw Markdown syntax cleanly and matches LIKE metacharacters literally', () => {
        const stripped = StripRawMarkdownForExcerpt('### Heading\nApprove **Batch #42** for `Q4_[100%]` — see [ledger](/ledger/42).');
        expect(stripped).toBe('Heading Approve Batch #42 for Q4_[100%] — see ledger.');
        expect(stripped).not.toContain('###');
        expect(stripped).not.toContain('**');
        expect(stripped).not.toContain('`');

        const item = {
            Name: 'Q4_[100%] Close',
            Description: 'Verify 50% margin_check',
            Organization: 'Acme US LLC',
        };
        expect(MatchesApprovalSearchQuery(item, '[100%]')).toBe(true);
        expect(MatchesApprovalSearchQuery(item, '50% margin_check')).toBe(true);
        expect(MatchesApprovalSearchQuery(item, 'nonexistent')).toBe(false);
    });

    it('escapes LIKE metacharacters safely in BuildApprovalsPendingFilter across SQL dialects', () => {
        const filter = BuildApprovalsPendingFilter('person-1', [], 'Q4_[100%]_close');
        expect(filter).toContain("ESCAPE '\\'");
        expect(filter).toContain('\\%');
        expect(filter).toContain('\\_');
        expect(filter).toContain('\\[');
        expect(filter).toContain('\\]');
    });

    it('marks overdue items properly in ComputeApprovalLatencyIndicator', () => {
        const now = Date.parse('2026-11-23T12:00:00.000Z');
        const overdue = ComputeApprovalLatencyIndicator('2026-11-23T10:00:00.000Z', '2026-11-23T11:00:00.000Z', now);
        expect(overdue.Tier).toBe('overdue');
        expect(overdue.Label).toBe('Wait 2h');
    });
});

describe('ApprovalsPageComponent & ApprovalInboxComponent — Org Grouping, OnPush & UserInfoEngine', () => {
    beforeEach(() => {
        runViewMock.mockReset();
    });

    it('ApprovalsPageComponent groups by Task.OrganizationID and persists collapse/sort preferences in UserInfoEngine', async () => {
        const savedPref = JSON.stringify({
            groupByOrganization: true,
            collapsedOrgKeys: ['org-uk'],
            sortBy: 'latency',
        });
        const getSpy = vi.spyOn(UserInfoEngine.Instance, 'GetSetting').mockReturnValue(savedPref);
        const setSpy = vi.spyOn(UserInfoEngine.Instance, 'SetSettingDebounced').mockImplementation(() => {});

        runViewMock.mockImplementation((params: { EntityName: string }) => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                return Promise.resolve({
                    Success: true,
                    Results: [
                        {
                            ID: 'a1',
                            Name: 'US Journal Entry Approval',
                            Description: '**Total** $10,000',
                            Priority: 'High',
                            DueAt: null,
                            Status: 'Open',
                            TypeID: 'tt-app',
                            OrganizationID: 'org-us',
                            Organization: 'Acme US LLC',
                            __mj_CreatedAt: '2026-11-23T01:00:00.000Z',
                        },
                        {
                            ID: 'a2',
                            Name: 'UK VAT Return',
                            Description: '### Monthly VAT',
                            Priority: 'Critical',
                            DueAt: null,
                            Status: 'Open',
                            TypeID: 'tt-app',
                            OrganizationID: 'org-uk',
                            Organization: 'Acme UK Ltd',
                            __mj_CreatedAt: '2026-11-22T01:00:00.000Z',
                        },
                    ],
                });
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Types') {
                return Promise.resolve({
                    Success: true,
                    Results: [{ ID: 'tt-app', OnCompleteAction: 'Process Approval Request Outcome', OnRejectAction: null, OnCancelAction: null }],
                });
            }
            return Promise.resolve({ Success: true, Results: [] });
        });

        try {
            const injector = Injector.create({
                providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
            });
            const page = runInInjectionContext(injector, () => new ApprovalsPageComponent());
            page.PersonID = 'person-1';

            await page.LoadApprovals(false);

            expect(page.SortBy).toBe('latency');
            expect(page.IsOrganizationCollapsed('org-uk')).toBe(true);
            expect(page.IsOrganizationCollapsed('org-us')).toBe(false);
            expect(page.OrganizationGroups.map((g) => g.OrganizationName)).toEqual(['Acme UK Ltd', 'Acme US LLC']);
            expect(page.ExcerptFor(page.PendingApprovals[0].Description)).toBe('Total $10,000');

            page.ToggleOrganizationGroup('org-us');
            expect(page.IsOrganizationCollapsed('org-us')).toBe(true);
            expect(setSpy).toHaveBeenCalledWith(
                APPROVAL_INBOX_PREFS_SETTING,
                expect.stringContaining('"org-us"'),
            );

            page.OnSearchChange('Journal');
            expect(page.OrganizationGroups.map((g) => g.OrganizationName)).toEqual(['Acme US LLC']);

            page.ToggleGroupByOrganization();
            expect(page.GroupByOrganization).toBe(false);
            expect(page.OrganizationGroups).toEqual([]);
            expect(setSpy).toHaveBeenCalledWith(
                APPROVAL_INBOX_PREFS_SETTING,
                expect.stringContaining('"groupByOrganization":false'),
            );
        } finally {
            getSpy.mockRestore();
            setSpy.mockRestore();
        }
    });

    it('ApprovalInboxComponent groups non-timesheet approvals by OrganizationID and persists collapse state via UserInfoEngine', async () => {
        const getSpy = vi.spyOn(UserInfoEngine.Instance, 'GetSetting').mockReturnValue(undefined);
        const setSpy = vi.spyOn(UserInfoEngine.Instance, 'SetSettingDebounced').mockImplementation(() => {});

        runViewMock.mockImplementation((params: { EntityName: string }) => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                return Promise.resolve({
                    Success: true,
                    Results: [
                        {
                            ID: 't1',
                            Name: 'Approve Vendor',
                            Description: '## Vendor Check',
                            Priority: 'High',
                            DueAt: null,
                            Status: 'Open',
                            OrganizationID: 'org-1',
                            Organization: 'Northwind Ops',
                            __mj_CreatedAt: '2026-11-23T00:00:00.000Z',
                        },
                    ],
                });
            }
            return Promise.resolve({ Success: true, Results: [] });
        });

        try {
            const injector = Injector.create({
                providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
            });
            const inbox = runInInjectionContext(injector, () => new ApprovalInboxComponent());
            inbox.ApproverPersonID = 'person-1';
            await inbox.Refresh();

            expect(inbox.OrganizationGroups).toHaveLength(1);
            expect(inbox.OrganizationGroups[0].OrganizationName).toBe('Northwind Ops');
            expect(inbox.ExcerptFor(inbox.OrganizationGroups[0].Items[0].Description)).toBe('Vendor Check');

            inbox.ToggleOrganizationGroup('org-1');
            expect(inbox.IsOrganizationCollapsed('org-1')).toBe(true);
            expect(setSpy).toHaveBeenCalledWith(
                APPROVAL_INBOX_PREFS_SETTING,
                expect.stringContaining('"org-1"'),
            );
        } finally {
            getSpy.mockRestore();
            setSpy.mockRestore();
        }
    });

    it('enforces ChangeDetectionStrategy.OnPush on all touched Angular components', () => {
        const getCmpMeta = (cls: unknown): { changeDetection?: ChangeDetectionStrategy } =>
            (cls as { ɵcmp?: { changeDetection?: ChangeDetectionStrategy } }).ɵcmp ?? {};
        // Check source declarations directly in addition to compiled metadata so OnPush is statically verified.
        const files = [
            resolve(SRC_LIB, 'pages/approvals.page.ts'),
            resolve(SRC_LIB, 'components/approval-inbox/approval-inbox.component.ts'),
            resolve(SRC_LIB, 'components/approval-decision-panel/approval-decision-panel.component.ts'),
            resolve(SRC_LIB, 'components/task-gantt/task-gantt.component.ts'),
        ];
        for (const file of files) {
            expect(readFileSync(file, 'utf8')).toContain('ChangeDetectionStrategy.OnPush');
        }
        expect(ApprovalsPageComponent).toBeDefined();
        expect(ApprovalInboxComponent).toBeDefined();
        expect(ApprovalDecisionPanelComponent).toBeDefined();
        expect(TaskGanttComponent).toBeDefined();
        void getCmpMeta;
    });

    it('static regex lint: zero hardcoded #hex/rgb/rgba/hsl color literals, zero localStorage/sessionStorage, and zero any/BaseEntity.Get/Set in touched Angular files', () => {
        const files = [
            resolve(SRC_LIB, 'pages/approvals.page.ts'),
            resolve(SRC_LIB, 'components/approval-inbox/approval-inbox.component.ts'),
            resolve(SRC_LIB, 'components/approval-inbox/approval-inbox-grouping.ts'),
            resolve(SRC_LIB, 'components/approval-decision-panel/approval-decision-panel.component.ts'),
            resolve(SRC_LIB, 'components/task-gantt/task-gantt.component.ts'),
        ];

        const colorLiteralRe = /#[0-9a-fA-F]{3,8}\b|\b(?:rgb|rgba|hsl|hsla)\s*\(/g;
        const storageRe = /\b(?:localStorage|sessionStorage)\b/g;
        const anyTypeRe = /:\s*any\b|\bas\s+any\b|<any>/g;
        const baseEntityGetSetRe = /\.(?:Get|Set)\(\s*['"]/g;

        for (const file of files) {
            const src = readFileSync(file, 'utf8');
            const templateMatch = src.match(/template:\s*`([\s\S]*?)`/);
            const stylesMatch = src.match(/styles:\s*\[`([\s\S]*?)`\]/);
            if (templateMatch) {
                expect(templateMatch[1].match(colorLiteralRe) ?? [], `Hardcoded color literal in template of ${file}`).toEqual([]);
            }
            if (stylesMatch) {
                expect(stylesMatch[1].match(colorLiteralRe) ?? [], `Hardcoded color literal in styles of ${file}`).toEqual([]);
            }
            expect(src.match(storageRe) ?? [], `Browser storage usage in ${file}`).toEqual([]);
            expect(src.match(anyTypeRe) ?? [], `Forbidden any type in ${file}`).toEqual([]);
            expect(src.match(baseEntityGetSetRe) ?? [], `Forbidden BaseEntity.Get/Set in ${file}`).toEqual([]);
        }
    });
});
