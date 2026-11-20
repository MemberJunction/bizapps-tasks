import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    HostListener,
    OnInit,
    ViewChild,
    inject,
} from '@angular/core';
import { DatePipe } from '@angular/common';
import { CompositeKey, LogError, Metadata, RunView } from '@memberjunction/core';
import { EscapeSQLString } from '@memberjunction/global';
import { SharedService } from '@memberjunction/ng-shared';
import {
    MJButtonDirective,
    MJEmptyStateComponent,
    MJPageBodyComponent,
    MJPageHeaderComponent,
    MJPageLayoutComponent,
    MJRefreshButtonComponent,
    MJStatBadgeComponent,
    MJTabNavComponent,
    type TabConfig,
} from '@memberjunction/ng-ui-components';
import { TaskOrchestrationService } from '@mj-biz-apps/tasks-core';
import {
    TaskApprovalCardComponent,
    type TaskApprovalActionEvent,
    type TaskPriorityValue,
    type TaskStatusValue,
    type TaskWidgetItem,
    type TaskWidgetLinkedRecord,
} from '@mj-biz-apps/tasks-ng-widgets';
import { NO_PERSON_MESSAGE, PERSON_LOOKUP_FAILED_MESSAGE, ResolveCurrentPersonID } from '../current-person';
import { OpenTaskRecord } from '../open-task-record';
import { AssignedToFilter, CurrentUserRoleIDs } from '../role-assignees';
import { LoadTaskRecordLinks } from '../task-record-links';
import { ApprovalDecisionPanelComponent, type DecisionRecordedEvent } from '../components/approval-decision-panel/approval-decision-panel.component';
import { ApprovalTypePredicate } from '../components/approval-inbox/approval-type-predicate';

interface DecidedApprovalRow {
    ID: string;
    TaskID: string;
    Task: string;
    Outcome: string;
    DecidedAt: Date;
    DecisionNotes: string | null;
}

/**
 * Approvals Gate Page — official MJ Page Chrome trio
 * (`<mj-page-layout>` + `<mj-page-header>` + `<mj-page-body>`) with Pending / Decided
 * tabs, inline 1-click `<mjt-approval-card>`, full `<bizapps-approval-decision-panel>`,
 * and `A` / `R` keyboard shortcuts for rapid governance review.
 */
@Component({
    selector: 'bizapps-approvals-page',
    standalone: true,
    imports: [
        DatePipe,
        MJPageLayoutComponent,
        MJPageHeaderComponent,
        MJPageBodyComponent,
        MJRefreshButtonComponent,
        MJStatBadgeComponent,
        MJTabNavComponent,
        MJButtonDirective,
        MJEmptyStateComponent,
        TaskApprovalCardComponent,
        ApprovalDecisionPanelComponent,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <mj-page-layout>
            <mj-page-header
                Title="Approvals"
                Icon="fa-solid fa-stamp"
                Subtitle="Review pending decisions, conditions, and linked business records.">
                @if (PendingApprovals.length > 0) {
                    <div meta>
                        <mj-stat-badge
                            [Count]="PendingApprovals.length"
                            Label="pending"
                            Variant="warning">
                        </mj-stat-badge>
                    </div>
                }

                <div actions>
                    <mj-refresh-button [Loading]="Loading" (Clicked)="LoadApprovals(true)" />
                </div>

                <div toolbar>
                    <mj-tab-nav
                        [Tabs]="Tabs"
                        [ActiveKey]="ActiveTab"
                        (TabChange)="ActiveTab = $event; cdr.markForCheck()">
                    </mj-tab-nav>
                </div>
            </mj-page-header>

            <mj-page-body>
                <div class="mjt-app-page">
                    @if (PersonLookupFailed) {
                        <mj-empty-state
                            Icon="fa-solid fa-triangle-exclamation"
                            Title="Could not load profile"
                            [Message]="LookupFailedMessage"
                            Variant="error">
                        </mj-empty-state>
                    } @else if (PersonResolved && !PersonID) {
                        <mj-empty-state
                            Icon="fa-solid fa-user-slash"
                            Title="No linked Person record"
                            [Message]="NoPersonMessage">
                        </mj-empty-state>
                    } @else if (ActiveTab === 'pending') {
                        @if (Loading && PendingApprovals.length === 0) {
                            <div class="mjt-app-loading">Loading pending approvals...</div>
                        } @else if (PendingApprovals.length === 0) {
                            <mj-empty-state
                                Icon="fa-regular fa-circle-check"
                                Title="Inbox zero"
                                Message="No approval requests are currently waiting on you or your roles.">
                            </mj-empty-state>
                        } @else {
                            <div class="mjt-app-grid">
                                <div class="mjt-app-list">
                                    @for (item of PendingApprovals; track item.ID) {
                                        <div class="mjt-app-selectable" [class.is-selected]="SelectedTaskID === item.ID">
                                            <mjt-approval-card
                                                [Task]="item"
                                                [Busy]="Busy"
                                                (TaskClicked)="SelectedTaskID = $event; cdr.markForCheck()"
                                                (LinkedRecordClicked)="OpenLinkedRecord($event)"
                                                (DecisionSubmitted)="OnQuickDecision($event)">
                                            </mjt-approval-card>
                                        </div>
                                    }
                                </div>

                                @if (SelectedTaskID) {
                                    <aside class="mjt-app-detail">
                                        <div class="mjt-app-detail-bar">
                                            <span class="mjt-app-kbd-hint">Shortcuts: <kbd>A</kbd> Approve · <kbd>R</kbd> Reject</span>
                                            <button type="button" mjButton variant="outline" size="sm" (click)="OpenFullRecord(SelectedTaskID)">
                                                <i class="fa-solid fa-arrow-up-right-from-square" aria-hidden="true"></i>
                                                Open Task Form
                                            </button>
                                        </div>
                                        <bizapps-approval-decision-panel
                                            #decisionPanel
                                            [TaskID]="SelectedTaskID"
                                            [DecidedByPersonID]="PersonID"
                                            (DecisionRecorded)="OnDecisionRecorded($event)"
                                            (Cancelled)="SelectedTaskID = null; cdr.markForCheck()">
                                        </bizapps-approval-decision-panel>
                                    </aside>
                                }
                            </div>
                        }
                    } @else {
                        @if (DecidedHistory.length === 0) {
                            <mj-empty-state
                                Icon="fa-solid fa-clock-rotate-left"
                                Title="No recorded decisions yet"
                                Message="Approvals you decide on will appear in your audit history here.">
                            </mj-empty-state>
                        } @else {
                            <div class="mjt-decided-list">
                                @for (d of DecidedHistory; track d.ID) {
                                    <article class="mjt-decided-row" (click)="OpenFullRecord(d.TaskID)">
                                        <div class="mjt-decided-main">
                                            <span class="mjt-decided-title">{{ d.Task }}</span>
                                            @if (d.DecisionNotes) {
                                                <span class="mjt-decided-notes">{{ d.DecisionNotes }}</span>
                                            }
                                        </div>
                                        <div class="mjt-decided-meta">
                                            <span class="mjt-decided-badge" [class.is-rejected]="d.Outcome.toLowerCase().includes('reject')">
                                                {{ d.Outcome }}
                                            </span>
                                            <span class="mjt-decided-date">{{ d.DecidedAt | date:'MMM d, y' }}</span>
                                        </div>
                                    </article>
                                }
                            </div>
                        }
                    }
                </div>
            </mj-page-body>
        </mj-page-layout>
    `,
    styles: [`
        :host { display: block; width: 100%; height: 100%; }
        .mjt-app-page { max-width: 1180px; width: 100%; margin: 0 auto; }
        .mjt-app-loading { padding: 36px; text-align: center; color: var(--mj-text-muted); }
        .mjt-app-grid {
            display: grid;
            grid-template-columns: minmax(0, 1.25fr) minmax(0, 1fr);
            gap: 16px;
            align-items: start;
        }
        .mjt-app-list { display: flex; flex-direction: column; gap: 10px; }
        .mjt-app-selectable.is-selected {
            border-radius: var(--mj-radius-md, 8px);
            box-shadow: 0 0 0 2px var(--mj-brand-primary);
        }
        .mjt-app-detail { display: flex; flex-direction: column; gap: 10px; position: sticky; top: 12px; }
        .mjt-app-detail-bar {
            display: flex; align-items: center; justify-content: space-between; gap: 8px; flex-wrap: wrap;
        }
        .mjt-app-kbd-hint { font-size: 11.5px; color: var(--mj-text-muted); }
        .mjt-app-kbd-hint kbd {
            padding: 1px 5px; border-radius: var(--mj-radius-sm, 4px);
            border: 1px solid var(--mj-border-default); background: var(--mj-bg-surface-sunken);
            font-family: var(--mj-font-family-mono, monospace); font-size: 11px;
        }
        .mjt-decided-list { display: flex; flex-direction: column; gap: 8px; }
        .mjt-decided-row {
            display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap;
            padding: 12px 14px; border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface); border: 1px solid var(--mj-border-default);
            cursor: pointer;
        }
        .mjt-decided-row:hover { border-color: var(--mj-brand-primary); background: var(--mj-bg-surface-hover); }
        .mjt-decided-main { display: flex; flex-direction: column; gap: 3px; min-width: 0; flex: 1; }
        .mjt-decided-title { font-size: var(--mj-text-sm, 14px); font-weight: var(--mj-font-semibold, 600); color: var(--mj-text-primary); }
        .mjt-decided-notes { font-size: var(--mj-text-xs, 12px); color: var(--mj-text-secondary); }
        .mjt-decided-meta { display: flex; align-items: center; gap: 8px; }
        .mjt-decided-badge {
            padding: 2px 9px; border-radius: var(--mj-radius-full, 9999px);
            font-size: 11px; font-weight: var(--mj-font-semibold, 600);
            background: var(--mj-status-success-bg); color: var(--mj-status-success-text);
        }
        .mjt-decided-badge.is-rejected {
            background: var(--mj-status-error-bg); color: var(--mj-status-error-text);
        }
        .mjt-decided-date { font-size: 11.5px; color: var(--mj-text-muted); }
        @media (max-width: 820px) {
            .mjt-app-grid { grid-template-columns: minmax(0, 1fr); }
            .mjt-app-detail { position: static; }
        }
    `],
})
export class ApprovalsPageComponent implements OnInit {
    public PersonID: string | null = null;
    public PersonResolved = false;
    public PersonLookupFailed = false;
    public readonly NoPersonMessage = NO_PERSON_MESSAGE;
    public readonly LookupFailedMessage = PERSON_LOOKUP_FAILED_MESSAGE;

    public ActiveTab = 'pending';
    public readonly Tabs: TabConfig[] = [
        { key: 'pending', label: 'Pending Decisions', icon: 'fa-solid fa-hourglass-half' },
        { key: 'decided', label: 'Decided History', icon: 'fa-solid fa-clock-rotate-left' },
    ];

    public PendingApprovals: TaskWidgetItem[] = [];
    public DecidedHistory: DecidedApprovalRow[] = [];
    public SelectedTaskID: string | null = null;
    public Loading = false;
    public Busy = false;

    @ViewChild('decisionPanel') public decisionPanel?: ApprovalDecisionPanelComponent;

    public cdr = inject(ChangeDetectorRef);
    private orchestration = new TaskOrchestrationService();

    @HostListener('window:keydown', ['$event'])
    public onShortcut(event: KeyboardEvent): void {
        if (this.ActiveTab !== 'pending' || !this.SelectedTaskID || this.Busy) return;
        const tag = (event.target as HTMLElement | null)?.tagName;
        if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT') return;
        if (event.metaKey || event.ctrlKey || event.altKey) return;

        if (event.key.toLowerCase() === 'a') {
            event.preventDefault();
            void this.OnQuickDecision({ TaskID: this.SelectedTaskID, OutcomeCode: 'Approved', Notes: null });
        } else if (event.key.toLowerCase() === 'r') {
            event.preventDefault();
            void this.OnQuickDecision({ TaskID: this.SelectedTaskID, OutcomeCode: 'Rejected', Notes: null });
        }
    }

    public async ngOnInit(): Promise<void> {
        try {
            this.PersonID = await ResolveCurrentPersonID();
        } catch (err) {
            LogError(err);
            this.PersonLookupFailed = true;
        }
        this.PersonResolved = true;
        if (this.PersonID) {
            await this.LoadApprovals(false);
        }
        this.cdr.markForCheck();
    }

    public async LoadApprovals(bypassCache: boolean): Promise<void> {
        if (!this.PersonID) return;
        this.Loading = true;
        this.cdr.markForCheck();
        try {
            const pendingFilter = [
                `TypeID IN (SELECT ID FROM __mj_BizAppsTasks.vwTaskTypes WHERE ${ApprovalTypePredicate(null)})`,
                "Status NOT IN ('Completed', 'Cancelled')",
                AssignedToFilter(this.PersonID, CurrentUserRoleIDs()),
                `ID NOT IN (SELECT d.TaskID FROM __mj_BizAppsTasks.vwTaskDecisions d INNER JOIN __mj_BizAppsTasks.vwTaskDecisionOutcomes o ON o.ID = d.OutcomeID WHERE o.IsTerminal = 1)`,
            ].join(' AND ');

            const [pendingRes, typesRes, decidedRes] = await Promise.all([
                new RunView().RunView<{
                    ID: string;
                    Name: string;
                    Description: string | null;
                    Priority: TaskPriorityValue;
                    DueAt: string | null;
                    Status: TaskStatusValue;
                    TypeID: string;
                }>({
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: pendingFilter,
                    OrderBy: 'DueAt ASC',
                    ResultType: 'simple',
                    BypassCache: bypassCache,
                }),
                new RunView().RunView<{
                    ID: string;
                    OnCompleteAction: string | null;
                    OnRejectAction: string | null;
                    OnCancelAction: string | null;
                }>({
                    EntityName: 'MJ_BizApps_Tasks: Task Types',
                    ExtraFilter: 'IsApproval = 1',
                    Fields: ['ID', 'OnCompleteAction', 'OnRejectAction', 'OnCancelAction'],
                    ResultType: 'simple',
                }),
                new RunView().RunView<DecidedApprovalRow>({
                    EntityName: 'MJ_BizApps_Tasks: Task Decisions',
                    ExtraFilter: `DecidedByPersonID = '${EscapeSQLString(this.PersonID)}'`,
                    OrderBy: 'DecidedAt DESC',
                    MaxRows: 50,
                    ResultType: 'simple',
                    BypassCache: bypassCache,
                }),
            ]);

            const rows = pendingRes?.Results ?? [];
            const typeMap = new Map((typesRes?.Results ?? []).map((t) => [t.ID.toLowerCase(), t]));
            let linksMap = new Map<string, { EntityName: string; RecordID: string; Name: string }[]>();
            try {
                linksMap = await LoadTaskRecordLinks(rows.map((r) => r.ID));
            } catch {
                // optional
            }

            this.PendingApprovals = rows.map((r) => {
                const tt = typeMap.get(r.TypeID.toLowerCase());
                return {
                    ID: r.ID,
                    Name: r.Name,
                    Description: r.Description,
                    ParentID: null,
                    Status: r.Status,
                    Priority: r.Priority,
                    DueAt: r.DueAt,
                    PercentComplete: 0,
                    IsApproval: true,
                    HasPendingDecision: true,
                    LinkedRecords: (linksMap.get(r.ID.toLowerCase()) ?? []).map((l) => ({
                        EntityName: l.EntityName,
                        RecordID: l.RecordID,
                        DisplayName: l.Name,
                        IconClass: Metadata.Provider.EntityByName(l.EntityName)?.Icon || 'fa-solid fa-link',
                    })),
                    OnCompleteActionName: tt?.OnCompleteAction ?? null,
                    OnRejectActionName: tt?.OnRejectAction ?? null,
                    OnCancelActionName: tt?.OnCancelAction ?? null,
                };
            });

            this.DecidedHistory = decidedRes?.Results ?? [];
            if (!this.SelectedTaskID || !this.PendingApprovals.some((a) => a.ID === this.SelectedTaskID)) {
                this.SelectedTaskID = this.PendingApprovals[0]?.ID ?? null;
            }
        } finally {
            this.Loading = false;
            this.cdr.markForCheck();
        }
    }

    public async OnQuickDecision(event: TaskApprovalActionEvent): Promise<void> {
        this.Busy = true;
        this.cdr.markForCheck();
        try {
            await this.orchestration.RecordDecision({
                TaskID: event.TaskID,
                OutcomeCode: event.OutcomeCode,
                DecidedByPersonID: this.PersonID ?? undefined,
                Notes: event.Notes ?? undefined,
            });
            await this.LoadApprovals(true);
        } finally {
            this.Busy = false;
            this.cdr.markForCheck();
        }
    }

    public OnDecisionRecorded(_event: DecisionRecordedEvent): void {
        void this.LoadApprovals(true);
    }

    public OpenFullRecord(taskID: string | null): void {
        OpenTaskRecord(taskID);
    }

    public OpenLinkedRecord(rec: TaskWidgetLinkedRecord): void {
        SharedService.Instance.OpenEntityRecord(rec.EntityName, CompositeKey.FromID(rec.RecordID));
    }
}
