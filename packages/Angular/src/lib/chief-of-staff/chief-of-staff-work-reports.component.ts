import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    OnDestroy,
    OnInit,
    inject,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Subject } from 'rxjs';
import { debounceTime, filter, takeUntil } from 'rxjs/operators';
import { BaseEntity, LogError, RunView, type BaseEntityEvent } from '@memberjunction/core';
import type { ResourceData } from '@memberjunction/core-entities';
import { IsValidUUID, MJEventType, MJGlobal, RegisterClass, UUIDsEqual, type MJEvent } from '@memberjunction/global';
import { BaseResourceComponent } from '@memberjunction/ng-shared';
import {
    MJButtonDirective,
    MJEmptyStateComponent,
    MJFilterChipComponent,
    MJPageBodyComponent,
    MJPageHeaderComponent,
    MJPageLayoutComponent,
    MJPageSearchComponent,
    MJRefreshButtonComponent,
    MJStatBadgeComponent,
} from '@memberjunction/ng-ui-components';
import {
    BuildWorkReportsAgentContext,
    FilterWorkReports,
    WORK_REPORTS_ENTITY_NAME,
    WORK_REPORT_ITEMS_ENTITY_NAME,
    WorkReportService,
    type WorkReportProvider,
    type WorkReportSection,
    type WorkReportStatus,
    type WorkReportStatusFilter,
    type WorkReportTabMode,
    type WorkReportViewModel,
} from '@mj-biz-apps/tasks-core';
import { NO_PERSON_MESSAGE, PERSON_LOOKUP_FAILED_MESSAGE, ResolveCurrentPersonID } from '../current-person.js';
import { OpenTaskRecord } from '../open-task-record.js';

interface PageClientTool {
    Name: string;
    Description: string;
    ParameterSchema: Record<string, unknown>;
    Handler: (params: Record<string, unknown>) => Promise<unknown>;
}

interface RawWorkReportRow {
    ID: string;
    PersonID: string;
    Person: string | null;
    PeriodStart: string | Date;
    PeriodEnd: string | Date;
    Title: string | null;
    Body: string;
    Status: WorkReportStatus;
    SupervisorFeedback: string | null;
    ReviewedByPersonID: string | null;
    ReviewedByPerson: string | null;
    ReviewedAt: string | Date | null;
}

interface RawWorkReportItemRow {
    ID: string;
    WorkReportID: string;
    TaskID: string | null;
    Task: string | null;
    Section: WorkReportSection;
    Summary: string;
    Sequence: number;
}

const LIVE_ENTITIES: readonly string[] = [WORK_REPORTS_ENTITY_NAME, WORK_REPORT_ITEMS_ENTITY_NAME];

const STATUS_OPTIONS: readonly { Value: WorkReportStatusFilter; Label: string }[] = [
    { Value: 'all', Label: 'All' },
    { Value: 'Draft', Label: 'Draft' },
    { Value: 'Submitted', Label: 'Submitted' },
    { Value: 'Reviewed', Label: 'Reviewed' },
];

function formatDateInput(value: string | Date): string {
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return String(value);
    const y = d.getUTCFullYear();
    const m = String(d.getUTCMonth() + 1).padStart(2, '0');
    const day = String(d.getUTCDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
}

/**
 * Chief of Staff "Reports" resource (`BizAppsTasksChiefOfStaffWorkReports`).
 *
 * Installed into the Chief of Staff application via `NavItem.bizapps-tasks.work-reports`.
 * Provides two tabs:
 * - **My Reports**: draft a daily 15Five from today's task activity, edit & approve drafts, and read supervisor feedback.
 * - **Team Reviews**: inspect direct reports' `Submitted` 15Five reports (resolved through `MJ: Employees.SupervisorID`)
 *   and approve/send supervisor feedback.
 *
 * SAFETY BOUNDARY: Only navigational/filter/selection client tools are registered for the co-agent.
 * Submitting a report and sending supervisor feedback always require explicit human action in the UI.
 */
@Component({
    selector: 'bizapps-chief-of-staff-work-reports',
    standalone: true,
    imports: [
        CommonModule,
        FormsModule,
        MJButtonDirective,
        MJEmptyStateComponent,
        MJFilterChipComponent,
        MJPageBodyComponent,
        MJPageHeaderComponent,
        MJPageLayoutComponent,
        MJPageSearchComponent,
        MJRefreshButtonComponent,
        MJStatBadgeComponent,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
    templateUrl: './chief-of-staff-work-reports.component.html',
    styleUrls: ['./chief-of-staff-work-reports.component.css'],
})
@RegisterClass(BaseResourceComponent, 'BizAppsTasksChiefOfStaffWorkReports')
export class ChiefOfStaffWorkReportsResource extends BaseResourceComponent implements OnInit, OnDestroy {
    private cdr = inject(ChangeDetectorRef);
    protected override destroy$ = new Subject<void>();

    public IsLoading = true;
    public IsDrafting = false;
    public BusyReportID: string | null = null;
    public Banner: { Type: 'success' | 'error' | 'info'; Message: string } | null = null;
    public PersonMessage: string | null = null;

    public ActiveTab: WorkReportTabMode = 'mine';
    public StatusFilter: WorkReportStatusFilter = 'all';
    public SearchText = '';
    public SelectedReportID: string | null = null;

    public MyReports: WorkReportViewModel[] = [];
    public TeamReports: WorkReportViewModel[] = [];
    public readonly StatusFilterOptions = STATUS_OPTIONS;

    public DraftEditorTitle = '';
    public DraftEditorBody = '';
    public DraftBodyTouched = false;
    public DraftBodyError: string | null = null;

    public FeedbackEditorText = '';
    public FeedbackTouched = false;
    public FeedbackError: string | null = null;

    private currentPersonID: string | null = null;
    private initialParamsApplied = false;

    public get SourceReports(): WorkReportViewModel[] {
        return this.ActiveTab === 'mine' ? this.MyReports : this.TeamReports;
    }

    public get FilteredReports(): WorkReportViewModel[] {
        return FilterWorkReports(this.SourceReports, this.StatusFilter, this.SearchText);
    }

    public get SelectedReport(): WorkReportViewModel | null {
        if (!this.SelectedReportID) return null;
        return this.SourceReports.find((r) => UUIDsEqual(r.ID, this.SelectedReportID!)) ?? null;
    }

    public get PendingTeamReviewCount(): number {
        return this.TeamReports.filter((r) => r.Status === 'Submitted').length;
    }

    async ngOnInit(): Promise<void> {
        super.ngOnInit();
        this.applyQueryParams(this.GetQueryParams());
        this.initialParamsApplied = true;
        await this.Load();
        this.navigationService?.SetAgentClientTools(this, this.buildAgentTools());
        this.subscribeToLiveChanges();
        this.NotifyLoadComplete();
    }

    override ngOnDestroy(): void {
        super.ngOnDestroy();
        this.destroy$.next();
        this.destroy$.complete();
    }

    async GetResourceDisplayName(_data: ResourceData): Promise<string> {
        return 'Reports';
    }

    async GetResourceIconClass(_data: ResourceData): Promise<string> {
        return 'fa-solid fa-clipboard-check';
    }

    protected override OnQueryParamsChanged(params: Record<string, string>, _source: 'popstate' | 'deeplink'): void {
        this.applyQueryParams(params);
        this.syncEditorsToSelection();
        this.publishAgentContext();
        this.cdr.markForCheck();
    }

    public async Load(): Promise<void> {
        this.IsLoading = true;
        this.cdr.markForCheck();
        try {
            const personID = await this.resolvePerson();
            if (!personID) {
                this.MyReports = [];
                this.TeamReports = [];
                return;
            }

            const provider = this.ProviderToUse as unknown as WorkReportProvider;
            const rv = new RunView(provider);
            const directReportIDs = await WorkReportService.Instance.ResolveDirectReportPersonIDs(
                personID,
                this.ProviderToUse.CurrentUser,
                provider
            );

            const myReportsPromise = this.fetchReportsForPeople(rv, [personID]);
            const teamReportsPromise =
                directReportIDs.length > 0
                    ? this.fetchReportsForPeople(rv, directReportIDs, "Status IN ('Submitted', 'Reviewed')")
                    : Promise.resolve<WorkReportViewModel[]>([]);

            const [mine, team] = await Promise.all([myReportsPromise, teamReportsPromise]);
            this.MyReports = mine;
            this.TeamReports = team;

            if (!this.SelectedReport) {
                this.SelectedReportID = this.FilteredReports[0]?.ID ?? null;
            }
            this.syncEditorsToSelection();
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`Chief of Staff work reports: ${msg}`);
            this.Banner = { Type: 'error', Message: `Failed to load work reports: ${msg}` };
        } finally {
            this.IsLoading = false;
            this.publishAgentContext();
            this.cdr.markForCheck();
        }
    }

    public SwitchTab(tab: WorkReportTabMode): void {
        if (this.ActiveTab === tab) return;
        this.ActiveTab = tab;
        this.SelectedReportID = this.FilteredReports[0]?.ID ?? null;
        this.syncEditorsToSelection();
        this.afterStateChange();
    }

    public OnTabKeydown(event: KeyboardEvent): void {
        if (event.key === 'ArrowRight' || event.key === 'ArrowLeft') {
            event.preventDefault();
            const next: WorkReportTabMode = this.ActiveTab === 'mine' ? 'team' : 'mine';
            this.SwitchTab(next);
            const targetId = next === 'mine' ? 'cos-reports-tab-mine' : 'cos-reports-tab-team';
            const btn = typeof document !== 'undefined' ? document.getElementById(targetId) : null;
            btn?.focus();
        }
    }

    public OnStatusFilterChange(status: WorkReportStatusFilter): void {
        this.StatusFilter = status;
        if (!this.FilteredReports.some((r) => this.SelectedReportID != null && UUIDsEqual(r.ID, this.SelectedReportID))) {
            this.SelectedReportID = this.FilteredReports[0]?.ID ?? null;
            this.syncEditorsToSelection();
        }
        this.afterStateChange();
    }

    public OnSearchChange(value: string): void {
        this.SearchText = value;
        this.afterStateChange();
    }

    public SelectReport(reportID: string): void {
        this.SelectedReportID = reportID;
        this.syncEditorsToSelection();
        this.afterStateChange();
    }

    public OpenTask(taskID: string | null, event?: Event): void {
        event?.stopPropagation();
        if (taskID && IsValidUUID(taskID)) {
            OpenTaskRecord(taskID);
        }
    }

    public OnDraftBodyInput(): void {
        if (this.DraftBodyError && this.DraftEditorBody.trim().length > 0) {
            this.DraftBodyError = null;
        }
    }

    public OnDraftBodyBlur(): void {
        this.DraftBodyTouched = true;
        if (this.DraftEditorBody.trim().length === 0) {
            this.DraftBodyError = 'Report summary cannot be empty before submitting.';
        }
    }

    public OnFeedbackInput(): void {
        if (this.FeedbackError && this.FeedbackEditorText.trim().length > 0) {
            this.FeedbackError = null;
        }
    }

    public OnFeedbackBlur(): void {
        this.FeedbackTouched = true;
        if (this.FeedbackEditorText.trim().length === 0) {
            this.FeedbackError = 'Enter supervisor feedback before sending.';
        }
    }

    public async DraftTodayReport(): Promise<void> {
        if (!this.currentPersonID || this.IsDrafting) return;
        this.IsDrafting = true;
        this.Banner = null;
        this.cdr.markForCheck();
        try {
            const now = new Date();
            const startOfDay = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), 0, 0, 0));
            const provider = this.ProviderToUse as unknown as WorkReportProvider;
            const outcome = await WorkReportService.Instance.DraftWorkReport({
                PersonID: this.currentPersonID,
                PeriodStart: startOfDay,
                PeriodEnd: now,
                SkipIfNoActivity: true,
                ContextUser: this.ProviderToUse.CurrentUser,
                Provider: provider,
            });
            if (outcome.SkippedNoActivity || !outcome.Report) {
                this.Banner = {
                    Type: 'info',
                    Message: 'No task updates were recorded today yet, so no 15Five draft was created.',
                };
                return;
            }
            this.ActiveTab = 'mine';
            this.SelectedReportID = outcome.Report.ID;
            await this.Load();
            this.Banner = { Type: 'success', Message: 'Drafted today\'s 15Five report from your task activity.' };
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`DraftTodayReport failed: ${msg}`);
            this.Banner = { Type: 'error', Message: msg };
        } finally {
            this.IsDrafting = false;
            this.cdr.markForCheck();
        }
    }

    public async SubmitSelectedDraft(event?: Event): Promise<void> {
        event?.preventDefault();
        const report = this.SelectedReport;
        if (!report || report.Status !== 'Draft' || this.BusyReportID) return;

        if (this.DraftEditorBody.trim().length === 0) {
            this.DraftBodyTouched = true;
            this.DraftBodyError = 'Report summary cannot be empty before submitting.';
            this.cdr.markForCheck();
            return;
        }

        this.BusyReportID = report.ID;
        this.Banner = null;
        this.cdr.markForCheck();
        try {
            const provider = this.ProviderToUse as unknown as WorkReportProvider;
            const outcome = await WorkReportService.Instance.SubmitWorkReport({
                WorkReportID: report.ID,
                CallerPersonID: this.currentPersonID,
                Title: this.DraftEditorTitle,
                Body: this.DraftEditorBody,
                ContextUser: this.ProviderToUse.CurrentUser,
                Provider: provider,
            });
            await this.Load();
            this.Banner = {
                Type: 'success',
                Message: outcome.Supervisor.SupervisorName
                    ? `Submitted report and notified ${outcome.Supervisor.SupervisorName}'s Chief of Staff.`
                    : 'Submitted work report.',
            };
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`SubmitSelectedDraft failed: ${msg}`);
            this.Banner = { Type: 'error', Message: msg };
        } finally {
            this.BusyReportID = null;
            this.cdr.markForCheck();
        }
    }

    public async SendSupervisorFeedback(event?: Event): Promise<void> {
        event?.preventDefault();
        const report = this.SelectedReport;
        if (!report || !this.currentPersonID || this.BusyReportID) return;

        if (this.FeedbackEditorText.trim().length === 0) {
            this.FeedbackTouched = true;
            this.FeedbackError = 'Enter supervisor feedback before sending.';
            this.cdr.markForCheck();
            return;
        }

        this.BusyReportID = report.ID;
        this.Banner = null;
        this.cdr.markForCheck();
        try {
            const provider = this.ProviderToUse as unknown as WorkReportProvider;
            await WorkReportService.Instance.RecordSupervisorReview({
                WorkReportID: report.ID,
                ReviewerPersonID: this.currentPersonID,
                SupervisorFeedback: this.FeedbackEditorText,
                ContextUser: this.ProviderToUse.CurrentUser,
                Provider: provider,
            });
            await this.Load();
            this.Banner = { Type: 'success', Message: 'Supervisor feedback saved and delivered to the report author.' };
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`SendSupervisorFeedback failed: ${msg}`);
            this.Banner = { Type: 'error', Message: msg };
        } finally {
            this.BusyReportID = null;
            this.cdr.markForCheck();
        }
    }

    public SectionLabel(section: WorkReportSection): string {
        switch (section) {
            case 'Completed':
                return 'Completed';
            case 'InProgress':
                return 'In Progress';
            case 'Next':
                return 'Next';
            case 'Blockers':
                return 'Blockers';
            case 'AtRisk':
                return 'At-Risk Objective';
            default:
                return section;
        }
    }

    private async resolvePerson(): Promise<string | null> {
        try {
            this.currentPersonID = await ResolveCurrentPersonID(this.ProviderToUse.CurrentUser);
            this.PersonMessage = this.currentPersonID ? null : NO_PERSON_MESSAGE;
        } catch (err) {
            LogError(err);
            this.currentPersonID = null;
            this.PersonMessage = PERSON_LOOKUP_FAILED_MESSAGE;
        }
        return this.currentPersonID;
    }

    private async fetchReportsForPeople(
        rv: RunView,
        personIDs: readonly string[],
        extraClause?: string
    ): Promise<WorkReportViewModel[]> {
        const validIDs = personIDs.filter((id) => IsValidUUID(id));
        if (validIDs.length === 0) return [];
        const quoted = validIDs.map((id) => `'${id}'`).join(',');
        const filterParts = [`PersonID IN (${quoted})`];
        if (extraClause) filterParts.push(extraClause);

        const reportsRes = await rv.RunView<RawWorkReportRow>({
            EntityName: WORK_REPORTS_ENTITY_NAME,
            ExtraFilter: filterParts.join(' AND '),
            Fields: [
                'ID',
                'PersonID',
                'Person',
                'PeriodStart',
                'PeriodEnd',
                'Title',
                'Body',
                'Status',
                'SupervisorFeedback',
                'ReviewedByPersonID',
                'ReviewedByPerson',
                'ReviewedAt',
            ],
            OrderBy: 'PeriodEnd DESC, __mj_CreatedAt DESC',
            ResultType: 'simple',
        }, this.ProviderToUse.CurrentUser);

        if (!reportsRes?.Success) {
            throw new Error(reportsRes?.ErrorMessage ?? 'Failed to query Work Reports.');
        }
        const rows = reportsRes.Results ?? [];
        if (rows.length === 0) return [];

        const reportIDs = rows.map((r) => `'${r.ID}'`).join(',');
        const itemsRes = await rv.RunView<RawWorkReportItemRow>({
            EntityName: WORK_REPORT_ITEMS_ENTITY_NAME,
            ExtraFilter: `WorkReportID IN (${reportIDs})`,
            Fields: ['ID', 'WorkReportID', 'TaskID', 'Task', 'Section', 'Summary', 'Sequence'],
            OrderBy: 'Sequence ASC',
            ResultType: 'simple',
        }, this.ProviderToUse.CurrentUser);

        const itemsByReport = new Map<string, WorkReportViewModel['Items']>();
        for (const item of itemsRes?.Results ?? []) {
            const key = item.WorkReportID.toLowerCase();
            const bucket = itemsByReport.get(key) ?? [];
            bucket.push({
                ID: item.ID,
                TaskID: item.TaskID,
                TaskName: item.Task,
                Section: item.Section,
                Summary: item.Summary,
                Sequence: item.Sequence,
            });
            itemsByReport.set(key, bucket);
        }

        return rows.map((r) => {
            const startStr = formatDateInput(r.PeriodStart);
            const endStr = formatDateInput(r.PeriodEnd);
            return {
                ID: r.ID,
                PersonID: r.PersonID,
                PersonName: r.Person ?? 'Team Member',
                PeriodStart: startStr,
                PeriodEnd: endStr,
                Title: r.Title?.trim() || `15Five — ${endStr}`,
                Body: r.Body,
                Status: r.Status,
                SupervisorFeedback: r.SupervisorFeedback,
                ReviewedByPersonID: r.ReviewedByPersonID,
                ReviewedByName: r.ReviewedByPerson,
                ReviewedAt: r.ReviewedAt ? formatDateInput(r.ReviewedAt) : null,
                Items: itemsByReport.get(r.ID.toLowerCase()) ?? [],
            };
        });
    }

    private syncEditorsToSelection(): void {
        const selected = this.SelectedReport;
        this.DraftEditorTitle = selected?.Title ?? '';
        this.DraftEditorBody = selected?.Body ?? '';
        this.DraftBodyTouched = false;
        this.DraftBodyError = null;

        this.FeedbackEditorText = selected?.SupervisorFeedback ?? '';
        this.FeedbackTouched = false;
        this.FeedbackError = null;
    }

    private afterStateChange(): void {
        this.syncQueryParams();
        this.publishAgentContext();
        this.cdr.markForCheck();
    }

    private applyQueryParams(params: Record<string, string>): void {
        this.ActiveTab = params['tab'] === 'team' ? 'team' : 'mine';
        const s = params['status'];
        this.StatusFilter = s === 'Draft' || s === 'Submitted' || s === 'Reviewed' ? s : 'all';
        this.SearchText = params['search'] ?? '';
        this.SelectedReportID = params['report'] && IsValidUUID(params['report']) ? params['report'] : null;
    }

    private syncQueryParams(): void {
        if (!this.initialParamsApplied) return;
        this.UpdateQueryParams({
            tab: this.ActiveTab === 'mine' ? null : this.ActiveTab,
            status: this.StatusFilter === 'all' ? null : this.StatusFilter,
            search: this.SearchText.trim().length > 0 ? this.SearchText.trim() : null,
            report: this.SelectedReportID,
        });
    }

    private publishAgentContext(): void {
        this.navigationService?.SetAgentContext(
            this,
            BuildWorkReportsAgentContext({
                ActiveTab: this.ActiveTab,
                StatusFilter: this.StatusFilter,
                SearchText: this.SearchText,
                MyReports: this.MyReports,
                TeamReports: this.TeamReports,
                FilteredCount: this.FilteredReports.length,
                SelectedReportID: this.SelectedReportID,
            })
        );
    }

    private buildAgentTools(): PageClientTool[] {
        return [
            {
                Name: 'SwitchWorkReportsTab',
                Description: 'Switch between My Reports ("mine") and Team Reviews ("team").',
                ParameterSchema: {
                    type: 'object',
                    properties: { tab: { type: 'string', enum: ['mine', 'team'] } },
                    required: ['tab'],
                },
                Handler: async (p) => {
                    const tab: WorkReportTabMode = p['tab'] === 'team' ? 'team' : 'mine';
                    this.SwitchTab(tab);
                    return { ActiveTab: this.ActiveTab };
                },
            },
            {
                Name: 'FilterWorkReportsByStatus',
                Description: 'Filter visible work reports by lifecycle status (all, Draft, Submitted, Reviewed).',
                ParameterSchema: {
                    type: 'object',
                    properties: { status: { type: 'string', enum: ['all', 'Draft', 'Submitted', 'Reviewed'] } },
                    required: ['status'],
                },
                Handler: async (p) => {
                    const raw = p['status'];
                    const status: WorkReportStatusFilter =
                        raw === 'Draft' || raw === 'Submitted' || raw === 'Reviewed' ? raw : 'all';
                    this.OnStatusFilterChange(status);
                    return { StatusFilter: this.StatusFilter, FilteredCount: this.FilteredReports.length };
                },
            },
            {
                Name: 'SelectWorkReport',
                Description: 'Select a work report by ID or title substring to view it on screen.',
                ParameterSchema: {
                    type: 'object',
                    properties: { query: { type: 'string' } },
                    required: ['query'],
                },
                Handler: async (p) => {
                    const q = String(p['query'] ?? '').trim();
                    const match =
                        this.SourceReports.find((r) => UUIDsEqual(r.ID, q)) ??
                        this.SourceReports.find((r) => r.Title.toLowerCase().includes(q.toLowerCase()));
                    if (!match) {
                        return { Found: false, AvailableTitles: this.SourceReports.slice(0, 15).map((r) => r.Title) };
                    }
                    this.SelectReport(match.ID);
                    return { Found: true, SelectedReportID: match.ID, Title: match.Title };
                },
            },
            {
                Name: 'RefreshWorkReports',
                Description: 'Reload My Reports and Team Reviews from the database.',
                ParameterSchema: { type: 'object', properties: {} },
                Handler: async () => {
                    await this.Load();
                    return { MyReportCount: this.MyReports.length, TeamReportCount: this.TeamReports.length };
                },
            },
        ];
    }

    private subscribeToLiveChanges(): void {
        MJGlobal.Instance.GetEventListener(false)
            .pipe(
                filter((ev: MJEvent) => ev.event === MJEventType.ComponentEvent && ev.eventCode === BaseEntity.BaseEventCode),
                filter((ev: MJEvent) => {
                    const entityEv = ev.args as BaseEntityEvent | undefined;
                    const name = entityEv?.baseEntity?.EntityInfo?.Name;
                    return Boolean(name && LIVE_ENTITIES.includes(name));
                }),
                debounceTime(350),
                takeUntil(this.destroy$)
            )
            .subscribe(() => {
                void this.Load();
            });
    }
}
