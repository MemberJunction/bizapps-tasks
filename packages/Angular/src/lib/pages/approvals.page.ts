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
import { FormsModule } from '@angular/forms';
import { CompositeKey, LogError, Metadata, RunView } from '@memberjunction/core';
import { UserInfoEngine } from '@memberjunction/core-entities';
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
import { BuildLikeClause, TaskOrchestrationService } from '@mj-biz-apps/tasks-core';
import type {
    TaskApprovalActionEvent,
    TaskPriorityValue,
    TaskStatusValue,
    TaskWidgetItem,
    TaskWidgetLinkedRecord,
} from '@mj-biz-apps/tasks-ng-widgets';
import { NO_PERSON_MESSAGE, PERSON_LOOKUP_FAILED_MESSAGE, ResolveCurrentPersonID } from '../current-person';
import { OpenTaskRecord } from '../open-task-record';
import { AssignedToFilter, CurrentUserRoleIDs } from '../role-assignees';
import { LoadTaskRecordLinks } from '../task-record-links';
import { ApprovalDecisionPanelComponent, type DecisionRecordedEvent } from '../components/approval-decision-panel/approval-decision-panel.component';
import { ApprovalTypePredicate } from '../components/approval-inbox/approval-type-predicate';
import {
    APPROVAL_INBOX_PREFS_SETTING,
    ComputeApprovalLatencyIndicator,
    GroupApprovalsByOrganization,
    MatchesApprovalSearchQuery,
    ParseApprovalInboxPreferences,
    SerializeApprovalInboxPreferences,
    SortApprovalItems,
    StripRawMarkdownForExcerpt,
    type ApprovalInboxPreferences,
    type ApprovalInboxSortMode,
    type ApprovalLatencyIndicator,
    type OrganizationApprovalGroup,
} from '../components/approval-inbox/approval-inbox-grouping';
import { RunningTimerChipComponent } from '../components/running-timer-chip/running-timer-chip.component';

export interface PendingApprovalItem extends TaskWidgetItem {
    Priority: NonNullable<TaskWidgetItem['Priority']>;
    OrganizationID?: string | null;
    Organization?: string | null;
    CreatedAt?: string | null;
}

interface DecidedApprovalRow {
    ID: string;
    TaskID: string;
    Task: string;
    Outcome: string;
    DecidedAt: Date;
    DecisionNotes: string | null;
}

/**
 * Builds a dual-dialect-safe pending approval RunView filter, optionally applying
 * a LIKE-escaped search predicate across Name and Description.
 */
export function BuildApprovalsPendingFilter(
    personID: string,
    roleIDs: readonly string[],
    searchText?: string | null,
): string {
    const clauses = [
        `TypeID IN (SELECT ID FROM __mj_BizAppsTasks.vwTaskTypes WHERE ${ApprovalTypePredicate(null)})`,
        "Status NOT IN ('Completed', 'Cancelled')",
        AssignedToFilter(personID, roleIDs),
        `ID NOT IN (SELECT d.TaskID FROM __mj_BizAppsTasks.vwTaskDecisions d INNER JOIN __mj_BizAppsTasks.vwTaskDecisionOutcomes o ON o.ID = d.OutcomeID WHERE o.IsTerminal = 1)`,
    ];
    const q = (searchText ?? '').trim();
    if (q) {
        clauses.push(`(${BuildLikeClause('Name', q, { caseInsensitive: true })} OR ${BuildLikeClause('Description', q, { caseInsensitive: true })})`);
    }
    return clauses.join(' AND ');
}

/**
 * Approvals Gate Page — official MJ Page Chrome trio
 * (`<mj-page-layout>` + `<mj-page-header>` + `<mj-page-body>`) with Pending / Decided
 * tabs, Organization-grouped Decision Queue on the left (persisted via `UserInfoEngine`,
 * surfacing approval latency indicators and raw-Markdown-free excerpts), a single commit
 * pane on the right (`<bizapps-approval-decision-panel>`), and WCAG 2.1.4 scoped keyboard
 * shortcuts (`↑↓` select · `A` / `R` prefill outcome).
 */
@Component({
    selector: 'bizapps-approvals-page',
    standalone: true,
    imports: [
        DatePipe,
        FormsModule,
        MJPageLayoutComponent,
        MJPageHeaderComponent,
        MJPageBodyComponent,
        MJRefreshButtonComponent,
        MJStatBadgeComponent,
        MJTabNavComponent,
        MJButtonDirective,
        MJEmptyStateComponent,
        ApprovalDecisionPanelComponent,
        RunningTimerChipComponent,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <mj-page-layout>
            <mj-page-header
                Title="Approvals"
                Icon="fa-solid fa-stamp"
                Subtitle="Review pending decisions, organization queues, and linked business records.">
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
                    <bizapps-running-timer-chip [PersonID]="PersonID"></bizapps-running-timer-chip>
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
                            <div class="mjt-app-controls">
                                <input
                                    type="search"
                                    class="mjt-app-search"
                                    placeholder="Filter approvals by title, description, or organization..."
                                    aria-label="Filter pending approvals"
                                    [ngModel]="SearchText"
                                    (ngModelChange)="OnSearchChange($event)" />
                                <select
                                    class="mjt-app-sort"
                                    aria-label="Sort pending approvals"
                                    [ngModel]="SortBy"
                                    (ngModelChange)="OnSortChange($event)">
                                    <option value="due">Sort: Due Date</option>
                                    <option value="latency">Sort: Wait Latency</option>
                                    <option value="priority">Sort: Priority</option>
                                </select>
                                <button
                                    type="button"
                                    class="mjt-group-toggle"
                                    [class.is-active]="GroupByOrganization"
                                    [attr.aria-pressed]="GroupByOrganization"
                                    (click)="ToggleGroupByOrganization()">
                                    <i class="fa-solid fa-building" aria-hidden="true"></i>
                                    <span>Group by Organization</span>
                                </button>
                            </div>

                            @if (FilteredPendingApprovals.length === 0) {
                                <mj-empty-state
                                    Icon="fa-solid fa-filter-circle-xmark"
                                    Title="No matching approvals"
                                    Message="Clear or adjust your filter to view pending approval requests.">
                                </mj-empty-state>
                            } @else {
                                <div class="mjt-app-grid">
                                    <!-- Left Pane: Organization-Grouped Decision Queue -->
                                    <div class="mjt-app-list" role="listbox" aria-label="Pending approval queue">
                                        <div class="mjt-queue-header">
                                            <span>Decision queue ({{ FilteredPendingApprovals.length }})</span>
                                            <span class="mjt-queue-hint">Select an item to review &amp; commit</span>
                                        </div>

                                        @if (GroupByOrganization) {
                                            @for (orgGroup of OrganizationGroups; track orgGroup.OrganizationKey) {
                                                <section class="mjt-org-group" [attr.data-org-key]="orgGroup.OrganizationKey">
                                                    <button
                                                        type="button"
                                                        class="mjt-org-header"
                                                        [attr.aria-expanded]="!IsOrganizationCollapsed(orgGroup.OrganizationKey)"
                                                        (click)="ToggleOrganizationGroup(orgGroup.OrganizationKey)">
                                                        <div class="mjt-org-title">
                                                            <i
                                                                class="fa-solid"
                                                                [class.fa-chevron-right]="IsOrganizationCollapsed(orgGroup.OrganizationKey)"
                                                                [class.fa-chevron-down]="!IsOrganizationCollapsed(orgGroup.OrganizationKey)"
                                                                aria-hidden="true"></i>
                                                            <i class="fa-solid fa-building mjt-org-icon" aria-hidden="true"></i>
                                                            <span>{{ orgGroup.OrganizationName }}</span>
                                                            <span class="mjt-org-count">{{ orgGroup.Count }}</span>
                                                        </div>
                                                        <span class="mjt-org-latency" [class]="'mjt-org-latency--' + orgGroup.HighestTier">
                                                            <i class="fa-solid fa-gauge-high" aria-hidden="true"></i>
                                                            Avg {{ orgGroup.AvgWaitFormatted }} · Max {{ orgGroup.MaxWaitFormatted }}
                                                        </span>
                                                    </button>

                                                    @if (!IsOrganizationCollapsed(orgGroup.OrganizationKey)) {
                                                        <div class="mjt-org-items">
                                                            @for (item of orgGroup.Items; track item.ID) {
                                                                <article
                                                                    class="mjt-queue-card"
                                                                    role="option"
                                                                    tabindex="0"
                                                                    [attr.aria-selected]="SelectedTaskID === item.ID"
                                                                    [class.is-selected]="SelectedTaskID === item.ID"
                                                                    (click)="SelectQueueItem(item.ID)"
                                                                    (keydown.enter)="SelectQueueItem(item.ID)">
                                                                    <div class="mjt-queue-top">
                                                                        <span class="mjt-queue-badge">
                                                                            <i class="fa-solid fa-stamp" aria-hidden="true"></i> Approval
                                                                        </span>
                                                                        <div class="mjt-queue-meta">
                                                                            <span class="mjt-latency-pill" [class]="'mjt-latency--' + LatencyFor(item).Tier">
                                                                                <i class="fa-regular fa-clock" aria-hidden="true"></i>
                                                                                {{ LatencyFor(item).Label }}
                                                                            </span>
                                                                            <span class="mjt-pri-pill" [class]="'mjt-pri--' + item.Priority.toLowerCase()">
                                                                                {{ item.Priority }}
                                                                            </span>
                                                                            @if (item.DueAt) {
                                                                                <span class="mjt-queue-due">
                                                                                    <i class="fa-regular fa-calendar" aria-hidden="true"></i>
                                                                                    Due {{ item.DueAt | date:'MMM d' }}
                                                                                </span>
                                                                            }
                                                                        </div>
                                                                    </div>

                                                                    <h4 class="mjt-queue-title">{{ item.Name }}</h4>

                                                                    @if (ExcerptFor(item.Description)) {
                                                                        <p class="mjt-queue-desc">{{ ExcerptFor(item.Description) }}</p>
                                                                    }

                                                                    @if (item.LinkedRecords && item.LinkedRecords.length > 0) {
                                                                        <div class="mjt-queue-links">
                                                                            @for (rec of item.LinkedRecords; track rec.EntityName + ':' + rec.RecordID) {
                                                                                <button
                                                                                    type="button"
                                                                                    class="mjt-queue-link-chip"
                                                                                    (click)="$event.stopPropagation(); OpenLinkedRecord(rec)">
                                                                                    <i [class]="rec.IconClass || 'fa-solid fa-link'" aria-hidden="true"></i>
                                                                                    <span>{{ rec.DisplayName }}</span>
                                                                                </button>
                                                                            }
                                                                        </div>
                                                                    }

                                                                    @if (item.OnCompleteActionName || item.OnRejectActionName) {
                                                                        <div class="mjt-queue-hooks">
                                                                            @if (item.OnCompleteActionName) {
                                                                                <span class="mjt-hook-tag">
                                                                                    <i class="fa-solid fa-bolt" aria-hidden="true"></i>
                                                                                    On approve: {{ item.OnCompleteActionName }}
                                                                                </span>
                                                                            }
                                                                            @if (item.OnRejectActionName) {
                                                                                <span class="mjt-hook-tag">
                                                                                    <i class="fa-solid fa-bolt" aria-hidden="true"></i>
                                                                                    On reject: {{ item.OnRejectActionName }}
                                                                                </span>
                                                                            }
                                                                        </div>
                                                                    }
                                                                </article>
                                                            }
                                                        </div>
                                                    }
                                                </section>
                                            }
                                        } @else {
                                            @for (item of FilteredPendingApprovals; track item.ID) {
                                                <article
                                                    class="mjt-queue-card"
                                                    role="option"
                                                    tabindex="0"
                                                    [attr.aria-selected]="SelectedTaskID === item.ID"
                                                    [class.is-selected]="SelectedTaskID === item.ID"
                                                    (click)="SelectQueueItem(item.ID)"
                                                    (keydown.enter)="SelectQueueItem(item.ID)">
                                                    <div class="mjt-queue-top">
                                                        <span class="mjt-queue-badge">
                                                            <i class="fa-solid fa-stamp" aria-hidden="true"></i> Approval
                                                        </span>
                                                        <div class="mjt-queue-meta">
                                                            <span class="mjt-latency-pill" [class]="'mjt-latency--' + LatencyFor(item).Tier">
                                                                <i class="fa-regular fa-clock" aria-hidden="true"></i>
                                                                {{ LatencyFor(item).Label }}
                                                            </span>
                                                            <span class="mjt-pri-pill" [class]="'mjt-pri--' + item.Priority.toLowerCase()">
                                                                {{ item.Priority }}
                                                            </span>
                                                            @if (item.DueAt) {
                                                                <span class="mjt-queue-due">
                                                                    <i class="fa-regular fa-calendar" aria-hidden="true"></i>
                                                                    Due {{ item.DueAt | date:'MMM d' }}
                                                                </span>
                                                            }
                                                        </div>
                                                    </div>

                                                    <h4 class="mjt-queue-title">{{ item.Name }}</h4>

                                                    @if (ExcerptFor(item.Description)) {
                                                        <p class="mjt-queue-desc">{{ ExcerptFor(item.Description) }}</p>
                                                    }

                                                    @if (item.LinkedRecords && item.LinkedRecords.length > 0) {
                                                        <div class="mjt-queue-links">
                                                            @for (rec of item.LinkedRecords; track rec.EntityName + ':' + rec.RecordID) {
                                                                <button
                                                                    type="button"
                                                                    class="mjt-queue-link-chip"
                                                                    (click)="$event.stopPropagation(); OpenLinkedRecord(rec)">
                                                                    <i [class]="rec.IconClass || 'fa-solid fa-link'" aria-hidden="true"></i>
                                                                    <span>{{ rec.DisplayName }}</span>
                                                                </button>
                                                            }
                                                        </div>
                                                    }

                                                    @if (item.OnCompleteActionName || item.OnRejectActionName) {
                                                        <div class="mjt-queue-hooks">
                                                            @if (item.OnCompleteActionName) {
                                                                <span class="mjt-hook-tag">
                                                                    <i class="fa-solid fa-bolt" aria-hidden="true"></i>
                                                                    On approve: {{ item.OnCompleteActionName }}
                                                                </span>
                                                            }
                                                            @if (item.OnRejectActionName) {
                                                                <span class="mjt-hook-tag">
                                                                    <i class="fa-solid fa-bolt" aria-hidden="true"></i>
                                                                    On reject: {{ item.OnRejectActionName }}
                                                                </span>
                                                            }
                                                        </div>
                                                    }
                                                </article>
                                            }
                                        }
                                    </div>

                                    <!-- Right Pane: Single Authoritative Commit Pane -->
                                    @if (SelectedTaskID) {
                                        <aside class="mjt-app-detail">
                                            <div class="mjt-app-detail-bar">
                                                <span class="mjt-app-kbd-hint">
                                                    List focus: <kbd>↑</kbd><kbd>↓</kbd> select · <kbd>A</kbd> / <kbd>R</kbd> prefill
                                                </span>
                                                <button type="button" mjButton variant="outline" size="sm" (click)="OpenFullRecord(SelectedTaskID)">
                                                    <i class="fa-solid fa-arrow-up-right-from-square" aria-hidden="true"></i>
                                                    Open Task Form
                                                </button>
                                            </div>
                                            <bizapps-approval-decision-panel
                                                #approvalDecisionPanel
                                                [TaskID]="SelectedTaskID"
                                                [DecidedByPersonID]="PersonID"
                                                (DecisionRecorded)="OnDecisionRecorded($event)"
                                                (Cancelled)="SelectedTaskID = null; cdr.markForCheck()">
                                            </bizapps-approval-decision-panel>
                                        </aside>
                                    }
                                </div>
                            }
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
                                                <span class="mjt-decided-notes">{{ ExcerptFor(d.DecisionNotes) }}</span>
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
        .mjt-app-page { max-width: 1180px; width: 100%; margin: 0 auto; padding-bottom: 80px; }
        .mjt-app-loading { padding: 36px; text-align: center; color: var(--mj-text-muted); }
        .mjt-app-controls {
            display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
            margin-bottom: 14px;
            padding: 10px 12px;
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-default);
        }
        .mjt-app-search {
            flex: 1 1 240px; min-width: 0;
            padding: 7px 10px;
            border-radius: var(--mj-radius-sm, 4px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: var(--mj-text-sm, 14px);
        }
        .mjt-app-sort {
            padding: 7px 10px;
            border-radius: var(--mj-radius-sm, 4px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: 12.5px;
        }
        .mjt-group-toggle {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 7px 12px;
            border-radius: var(--mj-radius-sm, 4px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-secondary);
            font-family: inherit;
            font-size: 12.5px;
            font-weight: var(--mj-font-semibold, 600);
            cursor: pointer;
        }
        .mjt-group-toggle.is-active {
            border-color: var(--mj-brand-primary);
            color: var(--mj-brand-primary);
            background: color-mix(in oklab, var(--mj-brand-primary) 10%, var(--mj-bg-surface));
        }
        .mjt-app-grid {
            display: grid;
            grid-template-columns: minmax(0, 1.15fr) minmax(0, 1fr);
            gap: 18px;
            align-items: start;
        }
        .mjt-app-list { display: flex; flex-direction: column; gap: 10px; }
        .mjt-queue-header {
            display: flex; align-items: center; justify-content: space-between; gap: 8px;
            padding: 2px 2px 4px;
            font-size: 12px; font-weight: var(--mj-font-semibold, 600); color: var(--mj-text-secondary);
        }
        .mjt-queue-hint { font-weight: var(--mj-font-normal, 400); color: var(--mj-text-muted); font-size: 11.5px; }
        .mjt-org-group {
            display: flex; flex-direction: column;
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface);
            overflow: hidden;
        }
        .mjt-org-header {
            width: 100%;
            display: flex; align-items: center; justify-content: space-between; gap: 10px; flex-wrap: wrap;
            padding: 10px 14px;
            border: none;
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: 13px;
            font-weight: var(--mj-font-semibold, 600);
            cursor: pointer;
            text-align: left;
        }
        .mjt-org-header:hover { background: var(--mj-bg-surface-hover); }
        .mjt-org-title { display: inline-flex; align-items: center; gap: 8px; }
        .mjt-org-icon { color: var(--mj-brand-primary); }
        .mjt-org-count {
            display: inline-flex; align-items: center; justify-content: center;
            min-width: 22px; padding: 1px 7px; border-radius: var(--mj-radius-full, 9999px);
            font-size: 11.5px; font-weight: var(--mj-font-semibold, 600);
            background: color-mix(in oklab, var(--mj-brand-primary) 14%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
        }
        .mjt-org-latency {
            display: inline-flex; align-items: center; gap: 5px;
            font-size: 11.5px; font-weight: var(--mj-font-medium, 500);
            color: var(--mj-text-muted);
        }
        .mjt-org-latency--elevated { color: var(--mj-status-warning-text); }
        .mjt-org-latency--overdue { color: var(--mj-status-error-text); }
        .mjt-org-items {
            display: flex; flex-direction: column; gap: 8px;
            padding: 10px;
            border-top: 1px solid var(--mj-border-subtle);
        }
        .mjt-queue-card {
            display: flex; flex-direction: column; gap: 8px;
            padding: 12px 14px;
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            cursor: pointer;
            transition: border-color 140ms ease, background 140ms ease;
        }
        .mjt-queue-card:hover {
            border-color: var(--mj-border-strong);
            background: var(--mj-bg-surface-hover);
        }
        .mjt-queue-card.is-selected {
            border-color: var(--mj-brand-primary);
            background: color-mix(in oklab, var(--mj-brand-primary) 7%, var(--mj-bg-surface));
        }
        .mjt-queue-card:focus-visible {
            outline: 2px solid var(--mj-brand-primary);
            outline-offset: 2px;
        }
        .mjt-queue-top {
            display: flex; align-items: center; justify-content: space-between; gap: 8px; flex-wrap: wrap;
        }
        .mjt-queue-badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 2px 8px; border-radius: var(--mj-radius-full, 9999px);
            font-size: 11px; font-weight: var(--mj-font-semibold, 600);
            background: color-mix(in oklab, var(--mj-brand-primary) 12%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
            border: 1px solid color-mix(in oklab, var(--mj-brand-primary) 26%, transparent);
        }
        .mjt-queue-meta { display: inline-flex; align-items: center; gap: 6px; flex-wrap: wrap; }
        .mjt-latency-pill {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 2px 7px; border-radius: var(--mj-radius-full, 9999px);
            font-size: 11px; font-weight: var(--mj-font-medium, 500);
            background: var(--mj-bg-surface-sunken); color: var(--mj-text-secondary);
            border: 1px solid var(--mj-border-default);
        }
        .mjt-latency--elevated {
            background: var(--mj-status-warning-bg); color: var(--mj-status-warning-text);
            border-color: color-mix(in oklab, var(--mj-status-warning) 30%, transparent);
        }
        .mjt-latency--overdue {
            background: var(--mj-status-error-bg); color: var(--mj-status-error-text);
            border-color: color-mix(in oklab, var(--mj-status-error) 28%, transparent);
        }
        .mjt-pri-pill {
            padding: 2px 8px; border-radius: var(--mj-radius-full, 9999px);
            font-size: 11px; font-weight: var(--mj-font-semibold, 600);
            border: 1px solid transparent;
        }
        .mjt-pri--critical {
            background: var(--mj-status-error-bg); color: var(--mj-status-error-text);
            border-color: color-mix(in oklab, var(--mj-status-error) 28%, transparent);
        }
        .mjt-pri--high {
            background: var(--mj-status-warning-bg); color: var(--mj-status-warning-text);
            border-color: color-mix(in oklab, var(--mj-status-warning) 30%, transparent);
        }
        .mjt-pri--medium {
            background: var(--mj-status-info-bg); color: var(--mj-status-info-text);
            border-color: color-mix(in oklab, var(--mj-status-info) 26%, transparent);
        }
        .mjt-pri--low {
            background: var(--mj-bg-surface-sunken); color: var(--mj-text-secondary);
            border-color: var(--mj-border-default);
        }
        .mjt-queue-due {
            display: inline-flex; align-items: center; gap: 4px;
            font-size: 11.5px; color: var(--mj-text-muted);
        }
        .mjt-queue-title {
            margin: 0; font-size: var(--mj-text-sm, 14px);
            font-weight: var(--mj-font-semibold, 600); color: var(--mj-text-primary); line-height: 1.35;
        }
        .mjt-queue-desc {
            margin: 0; font-size: 12.5px; color: var(--mj-text-secondary); line-height: 1.45;
            display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
        }
        .mjt-queue-links,
        .mjt-queue-hooks { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
        .mjt-queue-link-chip {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 2px 8px; border-radius: var(--mj-radius-sm, 4px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface-sunken); color: var(--mj-text-link);
            font-family: inherit; font-size: 11.5px; cursor: pointer;
        }
        .mjt-queue-link-chip:hover { border-color: var(--mj-brand-primary); }
        .mjt-hook-tag {
            display: inline-flex; align-items: center; gap: 4px;
            font-size: 11px; color: var(--mj-text-muted);
            padding: 1px 6px; border-radius: var(--mj-radius-sm, 4px);
            background: var(--mj-bg-surface-sunken);
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

    public PendingApprovals: PendingApprovalItem[] = [];
    public FilteredPendingApprovals: PendingApprovalItem[] = [];
    public OrganizationGroups: OrganizationApprovalGroup<PendingApprovalItem>[] = [];
    public DecidedHistory: DecidedApprovalRow[] = [];
    public SelectedTaskID: string | null = null;
    public Loading = false;
    public Busy = false;

    public SearchText = '';
    public SortBy: ApprovalInboxSortMode = 'due';
    public GroupByOrganization = true;
    public CollapsedOrgKeys = new Set<string>();

    @ViewChild('approvalDecisionPanel') public decisionPanel?: ApprovalDecisionPanelComponent;

    public cdr = inject(ChangeDetectorRef);
    private orchestration = new TaskOrchestrationService();
    private prefsLoaded = false;

    /**
     * WCAG 2.1.4 safe keyboard navigation:
     * - ArrowUp / ArrowDown moves selection through the Decision Queue.
     * - `A` / `R` prefills the Outcome dropdown in the right-hand commit pane without
     *   auto-submitting, preventing accidental single-key destructive decisions.
     */
    @HostListener('window:keydown', ['$event'])
    public onShortcut(event: KeyboardEvent): void {
        const navList = this.orderedVisibleItems();
        if (this.ActiveTab !== 'pending' || navList.length === 0 || this.Busy) return;
        const target = event.target as HTMLElement | null;
        const tag = target?.tagName;
        if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT' || target?.isContentEditable) return;
        if (event.metaKey || event.ctrlKey || event.altKey) return;

        if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
            event.preventDefault();
            const curIdx = navList.findIndex((a) => a.ID === this.SelectedTaskID);
            const delta = event.key === 'ArrowDown' ? 1 : -1;
            const nextIdx =
                curIdx < 0
                    ? 0
                    : (curIdx + delta + navList.length) % navList.length;
            this.SelectedTaskID = navList[nextIdx].ID;
            this.cdr.markForCheck();
            return;
        }

        if (!this.SelectedTaskID) return;
        const lower = event.key.toLowerCase();
        if (lower === 'a') {
            event.preventDefault();
            this.decisionPanel?.PrefillOutcome('Approved');
        } else if (lower === 'r') {
            event.preventDefault();
            this.decisionPanel?.PrefillOutcome('Rejected');
        }
    }

    public SelectQueueItem(taskID: string): void {
        this.SelectedTaskID = taskID;
        this.cdr.markForCheck();
    }

    public ToggleGroupByOrganization(): void {
        this.GroupByOrganization = !this.GroupByOrganization;
        this.persistPreferences();
        this.rebuildViewModels();
        this.cdr.markForCheck();
    }

    public ToggleOrganizationGroup(orgKey: string): void {
        const normalized = orgKey.trim().toLowerCase();
        if (this.CollapsedOrgKeys.has(normalized)) {
            this.CollapsedOrgKeys.delete(normalized);
        } else {
            this.CollapsedOrgKeys.add(normalized);
        }
        this.persistPreferences();
        this.cdr.markForCheck();
    }

    public IsOrganizationCollapsed(orgKey: string): boolean {
        return this.CollapsedOrgKeys.has(orgKey.trim().toLowerCase());
    }

    public OnSearchChange(value: string): void {
        this.SearchText = value ?? '';
        this.rebuildViewModels();
        this.cdr.markForCheck();
    }

    public OnSortChange(mode: ApprovalInboxSortMode): void {
        this.SortBy = mode;
        this.persistPreferences();
        this.rebuildViewModels();
        this.cdr.markForCheck();
    }

    public LatencyFor(item: PendingApprovalItem): ApprovalLatencyIndicator {
        return ComputeApprovalLatencyIndicator(item.CreatedAt, item.DueAt);
    }

    public ExcerptFor(raw: string | null | undefined): string {
        return StripRawMarkdownForExcerpt(raw);
    }

    public async ngOnInit(): Promise<void> {
        this.ensurePrefsLoaded();
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
        this.ensurePrefsLoaded();
        if (!this.PersonID) return;
        this.Loading = true;
        this.cdr.markForCheck();
        try {
            const pendingFilter = BuildApprovalsPendingFilter(this.PersonID, CurrentUserRoleIDs());

            const [pendingRes, typesRes, decidedRes] = await Promise.all([
                new RunView().RunView<{
                    ID: string;
                    Name: string;
                    Description: string | null;
                    Priority: TaskPriorityValue;
                    DueAt: string | null;
                    Status: TaskStatusValue;
                    TypeID: string;
                    OrganizationID: string | null;
                    Organization: string | null;
                    __mj_CreatedAt: string | null;
                }>({
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: pendingFilter,
                    OrderBy: 'DueAt ASC',
                    Fields: ['ID', 'Name', 'Description', 'Priority', 'DueAt', 'Status', 'TypeID', 'OrganizationID', 'Organization', '__mj_CreatedAt'],
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
                    Fields: ['ID', 'TaskID', 'Task', 'Outcome', 'DecidedAt', 'DecisionNotes'],
                    OrderBy: 'DecidedAt DESC',
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
                    OrganizationID: r.OrganizationID ?? null,
                    Organization: r.Organization ?? null,
                    CreatedAt: r.__mj_CreatedAt ?? null,
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
            this.rebuildViewModels();
        } finally {
            this.Loading = false;
            this.cdr.markForCheck();
        }
    }

    public RebuildGroups(): void {
        this.ensurePrefsLoaded();
        this.rebuildViewModels();
    }

    private ensurePrefsLoaded(): void {
        if (this.prefsLoaded) return;
        this.prefsLoaded = true;
        const parsed = ParseApprovalInboxPreferences(
            UserInfoEngine.Instance.GetSetting(APPROVAL_INBOX_PREFS_SETTING),
        );
        this.GroupByOrganization = parsed.groupByOrganization;
        this.SortBy = parsed.sortBy;
        this.CollapsedOrgKeys = new Set(parsed.collapsedOrgKeys);
    }

    private persistPreferences(): void {
        const prefs: ApprovalInboxPreferences = {
            groupByOrganization: this.GroupByOrganization,
            collapsedOrgKeys: [...this.CollapsedOrgKeys],
            sortBy: this.SortBy,
        };
        UserInfoEngine.Instance.SetSettingDebounced(
            APPROVAL_INBOX_PREFS_SETTING,
            SerializeApprovalInboxPreferences(prefs),
        );
    }

    private rebuildViewModels(): void {
        const filtered = this.PendingApprovals.filter((item) => MatchesApprovalSearchQuery(item, this.SearchText));
        this.FilteredPendingApprovals = SortApprovalItems(filtered, this.SortBy);
        this.OrganizationGroups = this.GroupByOrganization
            ? GroupApprovalsByOrganization(filtered, { sortBy: this.SortBy })
            : [];
        const navItems = this.orderedVisibleItems();
        if (!this.SelectedTaskID || !navItems.some((a) => a.ID === this.SelectedTaskID)) {
            this.SelectedTaskID = navItems[0]?.ID ?? null;
        }
    }

    private orderedVisibleItems(): PendingApprovalItem[] {
        if (!this.GroupByOrganization) {
            return this.FilteredPendingApprovals.length > 0 ? this.FilteredPendingApprovals : this.PendingApprovals;
        }
        if (this.OrganizationGroups.length === 0) {
            return this.FilteredPendingApprovals.length > 0 ? this.FilteredPendingApprovals : this.PendingApprovals;
        }
        return this.OrganizationGroups.flatMap((g) => g.Items);
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
