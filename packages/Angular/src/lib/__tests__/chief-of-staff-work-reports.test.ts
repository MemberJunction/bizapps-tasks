import '@angular/compiler';
import { describe, expect, it, vi, beforeEach } from 'vitest';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';
import type { WorkReportViewModel } from '@mj-biz-apps/tasks-core';

const {
    draftWorkReportMock,
    submitWorkReportMock,
    recordSupervisorReviewMock,
    resolveDirectReportsMock,
    updateQueryParamsMock,
    setAgentContextMock,
} = vi.hoisted(() => ({
    draftWorkReportMock: vi.fn(),
    submitWorkReportMock: vi.fn(),
    recordSupervisorReviewMock: vi.fn(),
    resolveDirectReportsMock: vi.fn(),
    updateQueryParamsMock: vi.fn(),
    setAgentContextMock: vi.fn(),
}));

vi.mock('@memberjunction/ng-shared', () => ({
    BaseResourceComponent: class {
        protected navigationService = {
            SetAgentClientTools: vi.fn(),
            SetAgentContext: setAgentContextMock,
        };
        protected ProviderToUse = {
            CurrentUser: { ID: 'aaaa1111-1111-4111-8111-111111111111', Email: 'alice@example.com' },
            Entities: [],
        };
        ngOnInit(): void {}
        ngOnDestroy(): void {}
        NotifyLoadComplete(): void {}
        GetQueryParams(): Record<string, string> {
            return {};
        }
        UpdateQueryParams(params: Record<string, string | null>): void {
            updateQueryParamsMock(params);
        }
    },
    SharedService: {
        Instance: {
            OpenEntityRecord: vi.fn(),
        },
    },
}));

vi.mock('@mj-biz-apps/tasks-core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@mj-biz-apps/tasks-core')>();
    return {
        ...actual,
        WorkReportService: {
            Instance: {
                DraftWorkReport: draftWorkReportMock,
                SubmitWorkReport: submitWorkReportMock,
                RecordSupervisorReview: recordSupervisorReviewMock,
                ResolveDirectReportPersonIDs: resolveDirectReportsMock,
            },
        },
    };
});

import { ChiefOfStaffWorkReportsResource } from '../chief-of-staff/chief-of-staff-work-reports.component';

function createResource(): ChiefOfStaffWorkReportsResource {
    const cdr: ChangeDetectorRef = {
        markForCheck: vi.fn(),
        detach: vi.fn(),
        detectChanges: vi.fn(),
        checkNoChanges: vi.fn(),
        reattach: vi.fn(),
    };
    const injector = Injector.create({
        providers: [{ provide: ChangeDetectorRef, useValue: cdr }],
    });
    return runInInjectionContext(injector, () => new ChiefOfStaffWorkReportsResource());
}

const SAMPLE_DRAFT: WorkReportViewModel = {
    ID: '44444444-4444-4444-8444-444444444441',
    PersonID: '11111111-1111-4111-8111-111111111111',
    PersonName: 'Alice Ng',
    PeriodStart: '2026-11-09',
    PeriodEnd: '2026-11-09',
    Title: 'Daily 15Five — 2026-11-09',
    Body: '### Completed\n- **Shipped Work Bus**',
    Status: 'Draft',
    SupervisorFeedback: null,
    ReviewedByPersonID: null,
    ReviewedByName: null,
    ReviewedAt: null,
    Items: [
        {
            ID: '66666666-6666-4666-8666-666666666661',
            TaskID: '55555555-5555-4555-8555-555555555551',
            TaskName: 'Shipped Work Bus',
            Section: 'Completed',
            Summary: 'Shipped Work Bus (3h)',
            Sequence: 1,
        },
    ],
};

const SAMPLE_TEAM_SUBMITTED: WorkReportViewModel = {
    ID: '44444444-4444-4444-8444-444444444442',
    PersonID: '33333333-3333-4333-8333-333333333333',
    PersonName: 'Devon Report',
    PeriodStart: '2026-11-09',
    PeriodEnd: '2026-11-09',
    Title: 'Daily 15Five — Devon',
    Body: '### In Progress\n- **GitHub Sync (80%)**',
    Status: 'Submitted',
    SupervisorFeedback: null,
    ReviewedByPersonID: null,
    ReviewedByName: null,
    ReviewedAt: null,
    Items: [],
};

describe('ChiefOfStaffWorkReportsResource', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('switches between My Reports and Team Reviews tabs via click and keyboard ArrowRight/ArrowLeft', () => {
        const comp = createResource();
        comp.MyReports = [SAMPLE_DRAFT];
        comp.TeamReports = [SAMPLE_TEAM_SUBMITTED];
        comp.SelectReport(SAMPLE_DRAFT.ID);

        expect(comp.ActiveTab).toBe('mine');
        expect(comp.PendingTeamReviewCount).toBe(1);
        expect(comp.SelectedReport?.ID).toBe(SAMPLE_DRAFT.ID);

        const preventDefault = vi.fn();
        comp.OnTabKeydown({ key: 'ArrowRight', preventDefault } as unknown as KeyboardEvent);

        expect(preventDefault).toHaveBeenCalled();
        expect(comp.ActiveTab).toBe('team');
        expect(comp.SelectedReport?.ID).toBe(SAMPLE_TEAM_SUBMITTED.ID);
        expect(setAgentContextMock).toHaveBeenCalled();
    });

    it('validates draft body and supervisor feedback on blur and clears inline errors on input', () => {
        const comp = createResource();

        comp.DraftEditorBody = '   ';
        comp.OnDraftBodyBlur();
        expect(comp.DraftBodyTouched).toBe(true);
        expect(comp.DraftBodyError).toContain('cannot be empty');

        comp.DraftEditorBody = '### Completed\n- Updated summary';
        comp.OnDraftBodyInput();
        expect(comp.DraftBodyError).toBeNull();

        comp.FeedbackEditorText = '';
        comp.OnFeedbackBlur();
        expect(comp.FeedbackTouched).toBe(true);
        expect(comp.FeedbackError).toContain('supervisor feedback');

        comp.FeedbackEditorText = 'Great progress this week!';
        comp.OnFeedbackInput();
        expect(comp.FeedbackError).toBeNull();
    });

    it('blocks SubmitSelectedDraft when DraftEditorBody is empty without calling WorkReportService', async () => {
        const comp = createResource();
        comp.MyReports = [SAMPLE_DRAFT];
        comp.SelectReport(SAMPLE_DRAFT.ID);
        comp.DraftEditorBody = '   ';

        await comp.SubmitSelectedDraft();

        expect(comp.DraftBodyError).toContain('cannot be empty');
        expect(submitWorkReportMock).not.toHaveBeenCalled();
    });
});
