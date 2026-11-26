import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    EventEmitter,
    HostListener,
    Input,
    OnInit,
    Output,
    inject,
} from '@angular/core';
import { DatePipe } from '@angular/common';
import { CompositeKey, LogError, Metadata, type IMetadataProvider, type RunViewParams } from '@memberjunction/core';
import { EscapeSQLString } from '@memberjunction/global';
import { BaseFormsModule } from '@memberjunction/ng-base-forms';
import { SharedService } from '@memberjunction/ng-shared';
import {
    MJButtonDirective,
    MJEmptyStateComponent,
    MJFilterPanelComponent,
    MJFilterPopoverComponent,
    MJPageBodyComponent,
    MJPageHeaderComponent,
    MJPageLayoutComponent,
    MJPageSearchComponent,
    MJRefreshButtonComponent,
    MJStatBadgeComponent,
    type FilterFieldConfig,
} from '@memberjunction/ng-ui-components';
import {
    ClassifyTaskHorizon,
    ComputeChildRollups,
    ComputeTaskUrgencyCounts,
    FormatTaskStatusLabel,
    IsTaskOverdue,
    IsTaskSlaAtRisk,
    TaskOrchestrationService,
    TasksEngineBase,
    type TaskUrgencyCounts,
} from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskLinkEntity,
    mjBizAppsTasksTaskTagEntity,
    mjBizAppsTasksTaskTagLinkEntity,
} from '@mj-biz-apps/tasks-entities';
import { ResolveDefaultGenericTaskTypeID, SelectDefaultGenericTaskTypeID } from '../task-type-filter.helper';
import { CreateTasksRunView, EnsureTasksEngineLoaded, RunViewsBatch } from '../tasks-engine.helper';
import {
    TaskApprovalCardComponent,
    TaskCommandPaletteComponent,
    TaskCompletionRingComponent,
    TaskQuickCaptureComponent,
    TaskUrgencyStripComponent,
    type TaskApprovalActionEvent,
    type TaskCommandPaletteItem,
    type TaskPriorityValue,
    type TaskQuickCaptureSubmitEvent,
    type TaskStatusValue,
    type TaskUrgencyFilterKey,
    type TaskWidgetItem,
    type TaskWidgetLinkedRecord,
} from '@mj-biz-apps/tasks-ng-widgets';
import { NO_PERSON_MESSAGE, PERSON_LOOKUP_FAILED_MESSAGE, ResolveCurrentPersonID } from '../current-person';
import { OpenTaskRecord } from '../open-task-record';
import { BuildTaskIDsInFilter, ChunkTaskIDs, CurrentUserRoleIDs, LoadAssignedTaskIDs } from '../role-assignees';
import { LoadTaskRecordLinks } from '../task-record-links';
import { RecordLinkPickerDialogComponent } from '../components/record-link-picker/record-link-picker-dialog.component';
import { RunningTimerChipComponent } from '../components/running-timer-chip/running-timer-chip.component';
import { TaskDetailPanelComponent } from '../components/task-detail-panel/task-detail-panel.component';
import { TaskDrawerShellComponent } from '../components/task-drawer-shell/task-drawer-shell.component';
import { TaskEditPanelComponent } from '../components/task-edit-panel/task-edit-panel.component';

interface MyWorkTaskRow {
    ID: string;
    Name: string;
    Description: string | null;
    Status: TaskStatusValue;
    Priority: TaskPriorityValue;
    DueAt: string | null;
    StartedAt: string | null;
    PercentComplete: number;
    ParentID: string | null;
    TypeID: string;
    Type: string | null;
    CategoryID: string | null;
    Category: string | null;
    TaskTypeStatusID: string | null;
    TaskTypeStatus: string | null;
    BlockedReason: string | null;
    PredictedSLARiskBand: mjBizAppsTasksTaskEntity['PredictedSLARiskBand'];
    PredictedSLABreachProbability: number | null;
}

/**
 * My Work (Action Horizons) Page — official MJ Page Chrome trio
 * (`<mj-page-layout>` + `<mj-page-header>` + `<mj-page-body>`) + reusable
 * `@mj-biz-apps/tasks-ng-widgets` primitives.
 */
@Component({
    selector: 'bizapps-my-tasks-page',
    standalone: true,
    imports: [
        DatePipe,
        BaseFormsModule,
        MJPageLayoutComponent,
        MJPageHeaderComponent,
        MJPageBodyComponent,
        MJPageSearchComponent,
        MJFilterPopoverComponent,
        MJFilterPanelComponent,
        MJRefreshButtonComponent,
        MJStatBadgeComponent,
        MJButtonDirective,
        MJEmptyStateComponent,
        TaskQuickCaptureComponent,
        TaskUrgencyStripComponent,
        TaskApprovalCardComponent,
        TaskCompletionRingComponent,
        TaskCommandPaletteComponent,
        TaskDrawerShellComponent,
        TaskDetailPanelComponent,
        TaskEditPanelComponent,
        RecordLinkPickerDialogComponent,
        RunningTimerChipComponent,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <mj-page-layout>
            <mj-page-header
                Title="My Work"
                Icon="fa-solid fa-user-check"
                Subtitle="Action horizons for your tasks, decisions, and connected records.">
                @if (AllTasks.length > 0) {
                    <div meta>
                        <mj-stat-badge
                            [Count]="FilteredTasks.length"
                            [Total]="AllTasks.length"
                            Label="tasks">
                        </mj-stat-badge>
                    </div>
                }

                <div actions>
                    <bizapps-running-timer-chip [PersonID]="PersonID"></bizapps-running-timer-chip>
                    <mj-refresh-button [Loading]="Loading" (Clicked)="LoadMyWork(true)" />
                    <button type="button" class="mjt-desktop-only mjt-toolbar-btn" mjButton variant="outline" size="sm" (click)="ShowCmdK = true" title="Tasks Quick Jump (Cmd/Ctrl+J)" aria-label="Tasks Quick Jump">
                        <i class="fa-solid fa-terminal" aria-hidden="true"></i>
                        <span class="action-btn-label">⌘J</span>
                    </button>
                    <button type="button" mjButton variant="primary" size="sm" (click)="OpenCreate()" title="Create New Task" aria-label="New Task">
                        <i class="fa-solid fa-plus" aria-hidden="true"></i>
                        <span class="action-btn-label">New Task</span>
                    </button>
                </div>

                <div toolbar>
                    <mj-page-search
                        Placeholder="Filter my work..."
                        [Value]="SearchText"
                        (ValueChange)="SearchText = $event; cdr.markForCheck()">
                    </mj-page-search>
                    <mj-filter-popover
                        Label="Filters"
                        Icon="fa-solid fa-filter"
                        [ActiveCount]="ActiveFilterCount"
                        [ShowClearAll]="ActiveFilterCount > 0"
                        (ClearAllRequested)="ResetFilters()">
                        <mj-filter-panel
                            [Fields]="FilterFields"
                            [Values]="FilterValues"
                            (ValuesChange)="OnFilterValuesChange($event)"
                            (Reset)="ResetFilters()">
                        </mj-filter-panel>
                    </mj-filter-popover>
                </div>
            </mj-page-header>

            <mj-page-body>
                <div class="mjt-my-wrap">
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
                    } @else {
                        <!-- 1. Natural-Language Quick-Capture Bar -->
                        <mjt-quick-capture
                            [Busy]="Busy"
                            [ShowLinkRecordButton]="true"
                            [LinkedRecord]="QuickCaptureRecord"
                            (LinkRecordRequested)="ShowLinkPicker = true"
                            (ClearLinkedRecord)="QuickCaptureRecord = null"
                            (Submitted)="OnQuickCapture($event)">
                        </mjt-quick-capture>

                        <!-- 2. Non-Zero Whisper Urgency Strip -->
                        <mjt-urgency-strip
                            [Counts]="UrgencyCounts"
                            [ActiveFilter]="UrgencyFilter"
                            (FilterChange)="UrgencyFilter = $event; cdr.markForCheck()">
                        </mjt-urgency-strip>

                        @if (ToastMessage) {
                            <div class="mjt-toast-banner" role="status">
                                <span>{{ ToastMessage }}</span>
                                <button type="button" mjButton variant="flat" size="sm" (click)="ToastMessage = ''">Dismiss</button>
                            </div>
                        }

                        @if (Loading && AllTasks.length === 0) {
                            <div class="mjt-loading">Loading your action horizons...</div>
                        } @else if (FilteredTasks.length === 0) {
                            <mj-empty-state
                                Icon="fa-regular fa-circle-check"
                                Title="You're all caught up"
                                Message="Capture a new task above or clear active filters to see more."
                                ActionText="New Task"
                                ActionIcon="fa-solid fa-plus"
                                (Action)="OpenCreate()">
                            </mj-empty-state>
                        } @else {
                            <!-- 3. Horizon 1: Needs Your Decision -->
                            @if (DecisionTasks.length > 0) {
                                <section class="mjt-horizon">
                                    <header class="mjt-horizon-head">
                                        <span class="mjt-horizon-title mjt-horizon-title--violet">
                                            <i class="fa-solid fa-stamp" aria-hidden="true"></i>
                                            Needs Your Decision
                                        </span>
                                        <span class="mjt-horizon-count">{{ DecisionTasks.length }}</span>
                                    </header>
                                    <div class="mjt-horizon-stack">
                                        @for (task of DecisionTasks; track task.ID) {
                                            <mjt-approval-card
                                                [Task]="task"
                                                [Busy]="Busy"
                                                (TaskClicked)="OpenInspector($event)"
                                                (LinkedRecordClicked)="OpenLinkedRecord($event)"
                                                (DecisionSubmitted)="OnApprovalDecision($event)">
                                            </mjt-approval-card>
                                        }
                                    </div>
                                </section>
                            }

                            <!-- 4. Horizon 2: Focus Today -->
                            @if (FocusTodayTasks.length > 0) {
                                <section class="mjt-horizon">
                                    <header class="mjt-horizon-head">
                                        <span class="mjt-horizon-title">
                                            <i class="fa-solid fa-bullseye" aria-hidden="true"></i>
                                            Focus Today
                                        </span>
                                        <span class="mjt-horizon-count">{{ FocusTodayTasks.length }}</span>
                                    </header>
                                    <div class="mjt-horizon-stack">
                                        @for (task of FocusTodayTasks; track task.ID) {
                                            <article
                                                class="mjt-task-row"
                                                [class.is-overdue]="isOverdue(task)"
                                                (click)="OpenInspector(task.ID)"
                                                (dblclick)="OpenFullRecord(task.ID)">
                                                <div class="mjt-task-row-left">
                                                    <mjt-completion-ring
                                                        [Status]="task.Status"
                                                        [TaskName]="task.Name"
                                                        [Disabled]="Busy"
                                                        (Toggled)="OnStatusToggle(task.ID, $event)">
                                                    </mjt-completion-ring>
                                                    <div class="mjt-task-copy">
                                                        <div class="mjt-task-title-line">
                                                            <span class="mjt-task-name">{{ task.Name }}</span>
                                                            @if (task.TaskTypeStatusName) {
                                                                <span class="mjt-badge mjt-badge--brand">{{ task.TaskTypeStatusName }}</span>
                                                            }
                                                            @if (task.ChildCount && task.ChildCount > 0) {
                                                                <span class="mjt-badge mjt-badge--neutral">
                                                                    {{ task.CompletedChildCount ?? 0 }}/{{ task.ChildCount }}
                                                                </span>
                                                            }
                                                            @if (isSlaRisk(task)) {
                                                                <span class="mjt-badge mjt-badge--warn">
                                                                    <i class="fa-solid fa-sparkles" aria-hidden="true"></i>
                                                                    {{ task.PredictedSLARiskBand || 'High' }} SLA Risk
                                                                </span>
                                                            }
                                                        </div>
                                                        @if (task.LinkedRecords && task.LinkedRecords.length > 0) {
                                                            <div class="mjt-links-row">
                                                                @for (rec of task.LinkedRecords; track rec.EntityName + ':' + rec.RecordID) {
                                                                    <button
                                                                        type="button"
                                                                        class="mjt-link-chip"
                                                                        (click)="$event.stopPropagation(); OpenLinkedRecord(rec)">
                                                                        <i [class]="rec.IconClass || 'fa-solid fa-link'" aria-hidden="true"></i>
                                                                        {{ rec.DisplayName }}
                                                                    </button>
                                                                }
                                                            </div>
                                                        }
                                                    </div>
                                                </div>
                                                <div class="mjt-task-row-right">
                                                    @if (task.CategoryName) {
                                                        <span class="mjt-badge mjt-badge--neutral">{{ task.CategoryName }}</span>
                                                    }
                                                    <span class="mjt-badge" [class]="priorityClass(task.Priority)">{{ task.Priority }}</span>
                                                    @if (task.DueAt) {
                                                        <span class="mjt-due" [class.is-overdue]="isOverdue(task)">
                                                            <i class="fa-regular fa-calendar" aria-hidden="true"></i>
                                                            {{ task.DueAt | date:'MMM d' }}
                                                        </span>
                                                    }
                                                </div>
                                            </article>
                                        }
                                    </div>
                                </section>
                            }

                            <!-- 5. Horizon 3: Blocked & Waiting (collapsible <details>) -->
                            @if (BlockedTasks.length > 0) {
                                <details class="mjt-horizon-details" open>
                                    <summary class="mjt-horizon-summary">
                                        <span class="mjt-horizon-title mjt-horizon-title--warn">
                                            <i class="fa-solid fa-ban" aria-hidden="true"></i>
                                            Blocked &amp; Waiting
                                        </span>
                                        <span class="mjt-horizon-count">{{ BlockedTasks.length }}</span>
                                    </summary>
                                    <div class="mjt-horizon-stack">
                                        @for (task of BlockedTasks; track task.ID) {
                                            <article class="mjt-task-row mjt-task-row--blocked" (click)="OpenInspector(task.ID)">
                                                <div class="mjt-task-row-left">
                                                    <mjt-completion-ring
                                                        [Status]="task.Status"
                                                        [TaskName]="task.Name"
                                                        [Disabled]="Busy"
                                                        (Toggled)="OnStatusToggle(task.ID, $event)">
                                                    </mjt-completion-ring>
                                                    <div class="mjt-task-copy">
                                                        <span class="mjt-task-name">{{ task.Name }}</span>
                                                        @if (task.BlockedReason) {
                                                            <span class="mjt-blocked-reason">{{ task.BlockedReason }}</span>
                                                        }
                                                    </div>
                                                </div>
                                                <div class="mjt-task-row-right">
                                                    <span class="mjt-badge" [class]="priorityClass(task.Priority)">{{ task.Priority }}</span>
                                                    @if (task.DueAt) {
                                                        <span class="mjt-due">{{ task.DueAt | date:'MMM d' }}</span>
                                                    }
                                                </div>
                                            </article>
                                        }
                                    </div>
                                </details>
                            }

                            <!-- 6. Horizon 4: Coming Up (collapsible <details>) -->
                            @if (ComingUpTasks.length > 0) {
                                <details class="mjt-horizon-details" [open]="FocusTodayTasks.length === 0 && DecisionTasks.length === 0">
                                    <summary class="mjt-horizon-summary">
                                        <span class="mjt-horizon-title">
                                            <i class="fa-regular fa-calendar" aria-hidden="true"></i>
                                            Coming Up
                                        </span>
                                        <span class="mjt-horizon-count">{{ ComingUpTasks.length }}</span>
                                    </summary>
                                    <div class="mjt-horizon-stack">
                                        @for (task of ComingUpTasks; track task.ID) {
                                            <article class="mjt-task-row" (click)="OpenInspector(task.ID)">
                                                <div class="mjt-task-row-left">
                                                    <mjt-completion-ring
                                                        [Status]="task.Status"
                                                        [TaskName]="task.Name"
                                                        [Disabled]="Busy"
                                                        (Toggled)="OnStatusToggle(task.ID, $event)">
                                                    </mjt-completion-ring>
                                                    <div class="mjt-task-copy">
                                                        <span class="mjt-task-name">{{ task.Name }}</span>
                                                    </div>
                                                </div>
                                                <div class="mjt-task-row-right">
                                                    <span class="mjt-badge" [class]="priorityClass(task.Priority)">{{ task.Priority }}</span>
                                                    @if (task.DueAt) {
                                                        <span class="mjt-due">{{ task.DueAt | date:'MMM d' }}</span>
                                                    }
                                                </div>
                                            </article>
                                        }
                                    </div>
                                </details>
                            }

                            <!-- 7. Completed (only when filter toggled on) -->
                            @if (CompletedTasks.length > 0) {
                                <details class="mjt-horizon-details">
                                    <summary class="mjt-horizon-summary">
                                        <span class="mjt-horizon-title">
                                            <i class="fa-solid fa-circle-check" aria-hidden="true"></i>
                                            Completed
                                        </span>
                                        <span class="mjt-horizon-count">{{ CompletedTasks.length }}</span>
                                    </summary>
                                    <div class="mjt-horizon-stack">
                                        @for (task of CompletedTasks; track task.ID) {
                                            <article class="mjt-task-row is-done" (click)="OpenInspector(task.ID)">
                                                <div class="mjt-task-row-left">
                                                    <mjt-completion-ring
                                                        [Status]="task.Status"
                                                        [TaskName]="task.Name"
                                                        [Disabled]="Busy"
                                                        (Toggled)="OnStatusToggle(task.ID, $event)">
                                                    </mjt-completion-ring>
                                                    <span class="mjt-task-name">{{ task.Name }}</span>
                                                </div>
                                            </article>
                                        }
                                    </div>
                                </details>
                            }
                        }
                    }
                </div>
            </mj-page-body>
        </mj-page-layout>

        <!-- Responsive Inspector / Express Create Drawer -->
        <bizapps-task-drawer-shell
            [Visible]="PanelMode !== 'none'"
            [Title]="PanelMode === 'edit' ? (SelectedTaskID ? 'Edit Task' : 'New Task') : 'Task Inspector'"
            (Closed)="ClosePanel()">
            @if (PanelMode === 'detail' && SelectedTaskID) {
                <bizapps-task-detail-panel
                    [Provider]="Provider"
                    [TaskID]="SelectedTaskID"
                    [PersonID]="PersonID"
                    [ShowDelete]="true"
                    (EditRequested)="PanelMode = 'edit'"
                    (OpenRecordRequested)="OpenFullRecord($event)"
                    (TaskMutated)="LoadMyWork(true)"
                    (DeleteRequested)="ClosePanel(); LoadMyWork(true)"
                    (Close)="ClosePanel()">
                </bizapps-task-detail-panel>
            }
            @if (PanelMode === 'edit') {
                <bizapps-task-edit-panel
                    [TaskID]="SelectedTaskID"
                    (Saved)="ClosePanel(); LoadMyWork(true)"
                    (Cancel)="ClosePanel()">
                </bizapps-task-edit-panel>
            }
        </bizapps-task-drawer-shell>

        <!-- Command Palette (Cmd/Ctrl+K) -->
        <mjt-command-palette
            [Visible]="ShowCmdK"
            [Items]="CommandItems"
            (ItemSelected)="OnCommandSelected($event)"
            (Closed)="ShowCmdK = false">
        </mjt-command-palette>

        <!-- Quick-Capture Linked Record Picker -->
        <bizapps-record-link-picker-dialog
            [Visible]="ShowLinkPicker"
            (RecordSelected)="QuickCaptureRecord = $event; ShowLinkPicker = false; cdr.markForCheck()"
            (Cancelled)="ShowLinkPicker = false">
        </bizapps-record-link-picker-dialog>
    `,
    styles: [`
        :host { display: block; width: 100%; height: 100%; }
        .mjt-my-wrap {
            display: flex; flex-direction: column; gap: 16px;
            max-width: 1040px; width: 100%; margin: 0 auto; min-width: 0;
            padding-bottom: 80px;
        }
        .mjt-toolbar-btn { background: var(--mj-bg-surface-elevated, var(--mj-bg-surface)); }
        .mjt-loading { padding: 36px; text-align: center; color: var(--mj-text-muted); font-size: var(--mj-text-sm, 14px); }
        .mjt-toast-banner {
            display: flex; align-items: center; justify-content: space-between; gap: 10px;
            padding: 8px 12px; border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-status-success-bg); color: var(--mj-status-success-text);
            border: 1px solid color-mix(in oklab, var(--mj-status-success) 30%, transparent);
            font-size: var(--mj-text-xs, 12px); font-weight: var(--mj-font-semibold, 600);
        }
        .mjt-horizon { display: flex; flex-direction: column; gap: 8px; }
        .mjt-horizon-head,
        .mjt-horizon-summary {
            display: flex; align-items: center; justify-content: space-between; gap: 8px;
            padding: 4px 2px; list-style: none; cursor: pointer;
        }
        .mjt-horizon-summary::-webkit-details-marker { display: none; }
        .mjt-horizon-details {
            display: flex; flex-direction: column; gap: 8px;
            padding-top: 8px; border-top: 1px solid var(--mj-border-subtle);
        }
        .mjt-horizon-title {
            display: inline-flex; align-items: center; gap: 7px;
            font-size: var(--mj-text-xs, 12px); font-weight: var(--mj-font-bold, 700);
            text-transform: uppercase; letter-spacing: 0.05em; color: var(--mj-text-secondary);
        }
        .mjt-horizon-title--violet { color: var(--mj-brand-primary); }
        .mjt-horizon-title--warn { color: var(--mj-status-warning-text); }
        .mjt-horizon-count {
            font-family: var(--mj-font-family-mono, monospace); font-size: 11px;
            font-weight: var(--mj-font-semibold, 600); color: var(--mj-text-muted);
        }
        .mjt-horizon-stack { display: flex; flex-direction: column; gap: 6px; }
        .mjt-task-row {
            display: flex; align-items: center; justify-content: space-between; gap: 12px;
            padding: 10px 14px; border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface); border: 1px solid var(--mj-border-default);
            cursor: pointer; transition: border-color 140ms ease, background 140ms ease;
        }
        .mjt-task-row:hover { border-color: var(--mj-brand-primary); background: var(--mj-bg-surface-hover); }
        .mjt-task-row.is-overdue {
            border-color: color-mix(in oklab, var(--mj-status-error) 35%, var(--mj-border-default));
            background: color-mix(in oklab, var(--mj-status-error-bg) 42%, var(--mj-bg-surface));
        }
        .mjt-task-row--blocked {
            border-color: color-mix(in oklab, var(--mj-status-warning) 38%, var(--mj-border-default));
            background: color-mix(in oklab, var(--mj-status-warning-bg) 42%, var(--mj-bg-surface));
        }
        .mjt-task-row.is-done .mjt-task-name { text-decoration: line-through; color: var(--mj-text-muted); }
        .mjt-task-row-left { display: flex; align-items: flex-start; gap: 10px; flex: 1; min-width: 0; }
        .mjt-task-copy { display: flex; flex-direction: column; gap: 4px; flex: 1; min-width: 0; }
        .mjt-task-title-line { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
        .mjt-task-name {
            font-size: var(--mj-text-sm, 14px); font-weight: var(--mj-font-medium, 500);
            color: var(--mj-text-primary); line-height: 1.35;
        }
        .mjt-blocked-reason { font-size: var(--mj-text-xs, 12px); color: var(--mj-status-warning-text); }
        .mjt-links-row { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
        .mjt-link-chip {
            display: inline-flex; align-items: center; gap: 5px; padding: 2px 7px;
            border-radius: var(--mj-radius-sm, 4px); border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface-sunken); color: var(--mj-text-link);
            font-family: inherit; font-size: 11.5px; cursor: pointer;
        }
        .mjt-task-row-right { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; justify-content: flex-end; flex-shrink: 0; }
        .mjt-badge {
            display: inline-flex; align-items: center; gap: 4px; padding: 2px 8px;
            border-radius: var(--mj-radius-full, 9999px); font-size: 11px; font-weight: var(--mj-font-semibold, 600);
        }
        .mjt-badge--neutral { background: var(--mj-bg-surface-sunken); color: var(--mj-text-secondary); }
        .mjt-badge--brand { background: color-mix(in srgb, var(--mj-brand-primary) 12%, var(--mj-bg-surface)); color: var(--mj-brand-primary); }
        .mjt-badge--warn { background: var(--mj-status-warning-bg); color: var(--mj-status-warning-text); }
        .mjt-badge--error { background: var(--mj-status-error-bg); color: var(--mj-status-error-text); }
        .mjt-badge--info { background: var(--mj-status-info-bg); color: var(--mj-status-info-text); }
        .mjt-due {
            display: inline-flex; align-items: center; gap: 4px; font-size: var(--mj-text-xs, 12px);
            color: var(--mj-text-muted); white-space: nowrap;
        }
        .mjt-due.is-overdue { color: var(--mj-status-error-text); font-weight: var(--mj-font-semibold, 600); }
        @media (max-width: 640px) {
            .mjt-desktop-only { display: none !important; }
            .mjt-task-row { flex-direction: column; align-items: stretch; gap: 8px; }
            .mjt-task-row-right { justify-content: flex-start; padding-left: 30px; }
        }
    `],
})
export class MyTasksPageComponent implements OnInit {
    @Input() Provider: IMetadataProvider | null = null;
    @Output() DrawerOpenChange = new EventEmitter<boolean>();
    public PersonID: string | null = null;
    public PersonResolved = false;
    public PersonLookupFailed = false;
    public readonly NoPersonMessage = NO_PERSON_MESSAGE;
    public readonly LookupFailedMessage = PERSON_LOOKUP_FAILED_MESSAGE;

    public AllTasks: TaskWidgetItem[] = [];
    public Loading = false;
    public Busy = false;
    public SearchText = '';
    public UrgencyFilter: TaskUrgencyFilterKey = '';
    public FilterValues: Record<string, unknown> = { priority: null, showCompleted: 'hide' };
    public SelectedTaskID: string | null = null;
    public PanelMode: 'none' | 'detail' | 'edit' = 'none';
    public ShowCmdK = false;
    public ShowLinkPicker = false;
    public QuickCaptureRecord: TaskWidgetLinkedRecord | null = null;
    public ToastMessage = '';

    public FilterFields: FilterFieldConfig[] = [
        {
            key: 'priority',
            type: 'dropdown',
            label: 'Priority',
            icon: 'fa-solid fa-flag',
            placeholder: 'All priorities',
            options: [
                { text: 'All priorities', value: null },
                { text: 'Critical', value: 'Critical' },
                { text: 'High', value: 'High' },
                { text: 'Medium', value: 'Medium' },
                { text: 'Low', value: 'Low' },
            ],
        },
        {
            key: 'showCompleted',
            type: 'chips',
            label: 'Completed tasks',
            chipOptions: [
                { text: 'Hide completed', value: 'hide' },
                { text: 'Show completed', value: 'show' },
            ],
        },
    ];

    public cdr = inject(ChangeDetectorRef);
    private orchestration = new TaskOrchestrationService();
    private peopleLookup: { ID: string; FirstName: string; LastName: string }[] = [];

    @HostListener('window:keydown', ['$event'])
    public onGlobalKeydown(event: KeyboardEvent): void {
        if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'j') {
            event.preventDefault();
            this.ShowCmdK = !this.ShowCmdK;
            this.cdr.markForCheck();
        }
    }

    public get ActiveFilterCount(): number {
        let count = 0;
        if (this.FilterValues['priority']) count++;
        if (this.FilterValues['showCompleted'] === 'show') count++;
        if (this.UrgencyFilter) count++;
        return count;
    }

    public get UrgencyCounts(): TaskUrgencyCounts {
        return ComputeTaskUrgencyCounts(this.AllTasks);
    }

    public get FilteredTasks(): TaskWidgetItem[] {
        const q = this.SearchText.trim().toLowerCase();
        const pri = this.FilterValues['priority'] as string | null;
        const showCompleted = this.FilterValues['showCompleted'] === 'show';

        return this.AllTasks.filter((t) => {
            if (!showCompleted && (t.Status === 'Completed' || t.Status === 'Cancelled')) return false;
            if (pri && t.Priority !== pri) return false;
            if (this.UrgencyFilter === 'overdue' && !IsTaskOverdue(t.DueAt, t.Status)) return false;
            if (this.UrgencyFilter === 'blocked' && t.Status !== 'Blocked') return false;
            if (this.UrgencyFilter === 'approvals' && !t.IsApproval) return false;
            if (this.UrgencyFilter === 'sla' && !IsTaskSlaAtRisk(t)) return false;
            if (
                q &&
                !t.Name.toLowerCase().includes(q) &&
                !(t.Description?.toLowerCase().includes(q) ?? false) &&
                !(t.CategoryName?.toLowerCase().includes(q) ?? false)
            ) {
                return false;
            }
            return true;
        });
    }

    public get DecisionTasks(): TaskWidgetItem[] {
        return this.FilteredTasks.filter((t) => ClassifyTaskHorizon(t) === 'needs-decision');
    }

    public get FocusTodayTasks(): TaskWidgetItem[] {
        return this.FilteredTasks.filter((t) => ClassifyTaskHorizon(t) === 'focus-today');
    }

    public get BlockedTasks(): TaskWidgetItem[] {
        return this.FilteredTasks.filter((t) => ClassifyTaskHorizon(t) === 'blocked-waiting');
    }

    public get ComingUpTasks(): TaskWidgetItem[] {
        return this.FilteredTasks.filter((t) => ClassifyTaskHorizon(t) === 'coming-up');
    }

    public get CompletedTasks(): TaskWidgetItem[] {
        return this.FilteredTasks.filter((t) => ClassifyTaskHorizon(t) === 'completed');
    }

    public get CommandItems(): TaskCommandPaletteItem[] {
        const actions: TaskCommandPaletteItem[] = [
            { ID: 'new-task', Label: 'Create New Task', Group: 'Actions', IconClass: 'fa-solid fa-plus' },
            { ID: 'filter-overdue', Label: 'Filter: Overdue Tasks', Group: 'Views', IconClass: 'fa-solid fa-clock' },
            { ID: 'filter-approvals', Label: 'Filter: Pending Approvals', Group: 'Views', IconClass: 'fa-solid fa-stamp' },
            { ID: 'reset-filters', Label: 'Clear All Filters', Group: 'Actions', IconClass: 'fa-solid fa-filter-circle-xmark' },
        ];
        const taskItems: TaskCommandPaletteItem[] = this.AllTasks.slice(0, 20).map((t) => ({
            ID: `task:${t.ID}`,
            Label: t.Name,
            Subtitle: `${t.Priority} · ${FormatTaskStatusLabel(t.Status)}`,
            Group: 'Tasks',
            IconClass: t.IsApproval ? 'fa-solid fa-stamp' : 'fa-regular fa-circle-check',
            Status: t.Status,
            TaskID: t.ID,
        }));
        return [...actions, ...taskItems];
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
            await this.LoadMyWork(false);
        }
        this.cdr.markForCheck();
    }

    public async LoadMyWork(bypassCache: boolean): Promise<void> {
        if (!this.PersonID) return;
        this.Loading = true;
        this.cdr.markForCheck();
        try {
            const effectiveProvider = this.Provider ?? Metadata.Provider;
            const roleIDs = CurrentUserRoleIDs(effectiveProvider?.CurrentUser);
            const assignedRes = await LoadAssignedTaskIDs(this.PersonID, roleIDs, effectiveProvider, bypassCache);
            if (!assignedRes.Success) {
                const msg = assignedRes.ErrorMessage || 'Failed to load task assignments.';
                LogError(msg);
                this.ToastMessage = msg;
                this.AllTasks = [];
                return;
            }
            if (assignedRes.TaskIDs.length === 0) {
                this.AllTasks = [];
                return;
            }

            const chunks = ChunkTaskIDs(assignedRes.TaskIDs);
            const rv = CreateTasksRunView(effectiveProvider);
            const chunkParams: RunViewParams[] = chunks.map((chunk) => ({
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                ExtraFilter: `${BuildTaskIDsInFilter(chunk)} AND Status <> 'Cancelled'`,
                OrderBy: 'DueAt ASC, Sequence ASC',
                ResultType: 'simple',
                BypassCache: bypassCache,
            }));

            const [taskChunkResults, engine, people] = await Promise.all([
                RunViewsBatch(rv, chunkParams),
                EnsureTasksEngineLoaded(effectiveProvider),
                TasksEngineBase.Instance.GetOrLoadAllPeople(effectiveProvider).catch(() => []),
            ]);

            const failedChunk = taskChunkResults.find((res) => !res?.Success);
            if (failedChunk) {
                const msg = failedChunk.ErrorMessage || 'Failed to load tasks.';
                LogError(msg);
                this.ToastMessage = msg;
                this.AllTasks = [];
                return;
            }

            this.peopleLookup = people.map((p) => ({
                ID: p.ID,
                FirstName: p.FirstName,
                LastName: p.LastName,
            }));
            const seenIds = new Set<string>();
            const rows: MyWorkTaskRow[] = [];
            for (const res of taskChunkResults) {
                for (const row of (res.Results ?? []) as MyWorkTaskRow[]) {
                    const key = row.ID.toLowerCase();
                    if (!seenIds.has(key)) {
                        seenIds.add(key);
                        rows.push(row);
                    }
                }
            }
            let linksMap = new Map<string, { EntityName: string; RecordID: string; Name: string }[]>();
            try {
                linksMap = await LoadTaskRecordLinks(rows.map((r) => r.ID), effectiveProvider);
            } catch {
                // optional enrichment
            }

            const rollups = ComputeChildRollups(rows);
            this.AllTasks = rows.map((r) => {
                const tt = engine.TaskTypeById(r.TypeID);
                const childStat = rollups.get(r.ID.toLowerCase());
                const links = (linksMap.get(r.ID.toLowerCase()) ?? []).map((l) => ({
                    EntityName: l.EntityName,
                    RecordID: l.RecordID,
                    DisplayName: l.Name,
                    IconClass: Metadata.Provider.EntityByName(l.EntityName)?.Icon || 'fa-solid fa-link',
                }));
                return {
                    ID: r.ID,
                    Name: r.Name,
                    Description: r.Description,
                    ParentID: r.ParentID,
                    Status: r.Status,
                    Priority: r.Priority,
                    DueAt: r.DueAt,
                    StartedAt: r.StartedAt,
                    PercentComplete: r.PercentComplete ?? 0,
                    TypeID: r.TypeID,
                    TypeName: r.Type,
                    TypeCode: tt?.Code ?? null,
                    CategoryID: r.CategoryID,
                    CategoryName: r.Category,
                    TaskTypeStatusID: r.TaskTypeStatusID,
                    TaskTypeStatusName: r.TaskTypeStatus,
                    BlockedReason: r.BlockedReason,
                    IsApproval: tt?.IsApproval ?? false,
                    HasPendingDecision: tt?.IsApproval ? r.Status !== 'Completed' && r.Status !== 'Cancelled' : false,
                    PredictedSLARiskBand: r.PredictedSLARiskBand,
                    PredictedSLABreachProbability: r.PredictedSLABreachProbability,
                    LinkedRecords: links,
                    ChildCount: childStat?.TotalChildren ?? 0,
                    CompletedChildCount: childStat?.CompletedChildren ?? 0,
                    OnCompleteActionName: tt?.OnCompleteAction ?? null,
                    OnRejectActionName: tt?.OnRejectAction ?? null,
                    OnCancelActionName: tt?.OnCancelAction ?? null,
                };
            });
        } finally {
            this.Loading = false;
            this.cdr.markForCheck();
        }
    }

    public OnFilterValuesChange(values: Record<string, unknown>): void {
        this.FilterValues = { ...values };
        this.cdr.markForCheck();
    }

    public ResetFilters(): void {
        this.FilterValues = { priority: null, showCompleted: 'hide' };
        this.UrgencyFilter = '';
        this.SearchText = '';
        this.cdr.markForCheck();
    }

    public async OnQuickCapture(event: TaskQuickCaptureSubmitEvent): Promise<void> {
        if (!this.PersonID || !event.Title) return;
        this.Busy = true;
        this.cdr.markForCheck();
        try {
            const effectiveProvider = this.Provider ?? Metadata.Provider;
            const engine = await EnsureTasksEngineLoaded(effectiveProvider);
            const cachedTypeId =
                engine.TaskTypes.length > 0 ? SelectDefaultGenericTaskTypeID(engine.TaskTypes) : null;
            const typeID = cachedTypeId ?? (await ResolveDefaultGenericTaskTypeID(CreateTasksRunView(effectiveProvider)));
            if (!typeID) return;

            const task = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            task.NewRecord();
            task.Name = event.Title;
            task.TypeID = typeID;
            task.Status = 'Open';
            task.Priority = event.Priority ?? 'Medium';
            task.CreatedByPersonID = this.PersonID;
            if (event.DueAt) task.DueAt = event.DueAt;
            if (event.HoursEstimated != null) task.HoursEstimated = event.HoursEstimated;

            if (await task.Save()) {
                const peopleEntityID = Metadata.Provider.EntityByName('MJ_BizApps_Common: People')?.ID;
                if (peopleEntityID) {
                    let targetPersonID = this.PersonID;
                    if (event.AssigneeQuery) {
                        const q = event.AssigneeQuery.toLowerCase();
                        const match = this.peopleLookup.find((p) => `${p.FirstName} ${p.LastName}`.toLowerCase().includes(q));
                        if (match) targetPersonID = match.ID;
                    }
                    const assign = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>('MJ_BizApps_Tasks: Task Assignments');
                    assign.NewRecord();
                    assign.TaskID = task.ID;
                    assign.AssigneeEntityID = peopleEntityID;
                    assign.AssigneeRecordID = targetPersonID;
                    await assign.Save();
                }

                // Persist linked business record if attached
                if (event.LinkedRecord) {
                    const targetEntity = Metadata.Provider.EntityByName(event.LinkedRecord.EntityName);
                    if (targetEntity) {
                        const link = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskLinkEntity>('MJ_BizApps_Tasks: Task Links');
                        link.NewRecord();
                        link.TaskID = task.ID;
                        link.EntityID = targetEntity.ID;
                        link.RecordID = event.LinkedRecord.RecordID;
                        link.Description = event.LinkedRecord.DisplayName;
                        await link.Save();
                    }
                }

                // Persist #Tags if parsed
                for (const tagName of event.TagNames) {
                    let tagID: string | undefined = engine.TaskTagByName(tagName)?.ID;
                    if (!tagID && engine.TaskTags.length === 0) {
                        const existing = await CreateTasksRunView(effectiveProvider).RunView<{ ID: string }>({
                            EntityName: 'MJ_BizApps_Tasks: Task Tags',
                            ExtraFilter: `Name = '${EscapeSQLString(tagName)}'`,
                            Fields: ['ID'],
                            MaxRows: 1,
                            ResultType: 'simple',
                        });
                        tagID = existing?.Results?.[0]?.ID;
                    }
                    if (!tagID) {
                        const newTag = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskTagEntity>('MJ_BizApps_Tasks: Task Tags');
                        newTag.NewRecord();
                        newTag.Name = tagName;
                        newTag.ColorCode = null;
                        if (await newTag.Save()) tagID = newTag.ID;
                    }
                    if (tagID) {
                        const tl = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskTagLinkEntity>('MJ_BizApps_Tasks: Task Tag Links');
                        tl.NewRecord();
                        tl.TaskID = task.ID;
                        tl.TagID = tagID;
                        await tl.Save();
                    }
                }

                this.QuickCaptureRecord = null;
                this.ToastMessage = `Added "${task.Name}"`;
                await this.LoadMyWork(true);
            }
        } finally {
            this.Busy = false;
            this.cdr.markForCheck();
        }
    }

    public async OnStatusToggle(taskID: string, nextStatus: TaskStatusValue): Promise<void> {
        this.Busy = true;
        this.cdr.markForCheck();
        try {
            const entity = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            await entity.InnerLoad(CompositeKey.FromID(taskID));
            entity.Status = nextStatus;
            entity.PercentComplete = nextStatus === 'Completed' ? 100 : 0;
            if (await entity.Save()) {
                this.ToastMessage = nextStatus === 'Completed' ? `Completed "${entity.Name}"` : `Reopened "${entity.Name}"`;
                await this.LoadMyWork(true);
            }
        } finally {
            this.Busy = false;
            this.cdr.markForCheck();
        }
    }

    public async OnApprovalDecision(event: TaskApprovalActionEvent): Promise<void> {
        this.Busy = true;
        this.cdr.markForCheck();
        try {
            await this.orchestration.RecordDecision({
                TaskID: event.TaskID,
                OutcomeCode: event.OutcomeCode,
                DecidedByPersonID: this.PersonID ?? undefined,
                Notes: event.Notes ?? undefined,
            });
            this.ToastMessage = `Decision recorded: ${event.OutcomeCode}`;
            await this.LoadMyWork(true);
        } finally {
            this.Busy = false;
            this.cdr.markForCheck();
        }
    }

    public OpenCreate(): void {
        this.SelectedTaskID = null;
        this.PanelMode = 'edit';
        this.DrawerOpenChange.emit(true);
        this.cdr.markForCheck();
    }

    public OpenInspector(taskID: string): void {
        this.SelectedTaskID = taskID;
        this.PanelMode = 'detail';
        this.DrawerOpenChange.emit(true);
        this.cdr.markForCheck();
    }

    public ClosePanel(): void {
        this.PanelMode = 'none';
        this.SelectedTaskID = null;
        this.DrawerOpenChange.emit(false);
        this.cdr.markForCheck();
    }

    public OpenFullRecord(taskID: string | null): void {
        this.ClosePanel();
        OpenTaskRecord(taskID);
    }

    public OpenLinkedRecord(rec: TaskWidgetLinkedRecord): void {
        SharedService.Instance.OpenEntityRecord(rec.EntityName, CompositeKey.FromID(rec.RecordID));
    }

    public OnCommandSelected(item: TaskCommandPaletteItem): void {
        this.ShowCmdK = false;
        if (item.TaskID) {
            this.OpenInspector(item.TaskID);
        } else if (item.ID === 'new-task') {
            this.OpenCreate();
        } else if (item.ID === 'filter-overdue') {
            this.UrgencyFilter = 'overdue';
        } else if (item.ID === 'filter-approvals') {
            this.UrgencyFilter = 'approvals';
        } else if (item.ID === 'reset-filters') {
            this.ResetFilters();
        }
        this.cdr.markForCheck();
    }

    public isOverdue(task: TaskWidgetItem): boolean {
        return IsTaskOverdue(task.DueAt, task.Status);
    }

    public isSlaRisk(task: TaskWidgetItem): boolean {
        return IsTaskSlaAtRisk(task);
    }

    public priorityClass(priority: string | null | undefined): string {
        switch (priority) {
            case 'Critical': return 'mjt-badge--error';
            case 'High': return 'mjt-badge--warn';
            case 'Medium': return 'mjt-badge--info';
            default: return 'mjt-badge--neutral';
        }
    }
}
