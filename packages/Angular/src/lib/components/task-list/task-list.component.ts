import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    ContentChild,
    EventEmitter,
    Input,
    OnChanges,
    OnInit,
    Output,
    SimpleChanges,
    TemplateRef,
    inject,
} from '@angular/core';
import { DatePipe, NgTemplateOutlet } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CompositeKey, LogError, Metadata, RunView, type IMetadataProvider, type IRunViewProvider, type RunViewParams } from '@memberjunction/core';
import { EscapeSQLString, IsValidUUID, NormalizeUUID, UUIDsEqual } from '@memberjunction/global';
import { BaseFormsModule } from '@memberjunction/ng-base-forms';
import { MJButtonDirective, MJEmptyStateComponent } from '@memberjunction/ng-ui-components';
import {
    BuildWbsTree,
    MatchesAssigneeFilter,
    MatchesDueDateFilter,
    TasksBulkUpdateOperation,
    TasksEngineBase,
    type TaskBadgeDescriptor,
    type TaskDueDateFilterKey,
    type TaskWbsNode,
} from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTaskEntity,
} from '@mj-biz-apps/tasks-entities';
import { FilterGenericCreatableTaskTypes } from '@mj-biz-apps/tasks-entities';
import {
    ResolveDefaultGenericTaskTypeID,
    SelectGenericQuickAddTaskTypeID,
} from '../../task-type-filter.helper';
import {
    TaskBulkActionDockComponent,
    TaskCompletionRingComponent,
    TaskQuickCaptureComponent,
    type TaskBulkActionRequest,
    type TaskBulkLookupOption,
    type TaskBulkPatch,
    type TaskPriorityValue,
    type TaskQuickCaptureSubmitEvent,
    type TaskStatusValue,
    type TaskWbsRowTemplateContext,
    type TaskWidgetItem,
} from '@mj-biz-apps/tasks-ng-widgets';
import { BuildTaskIDsInFilter, ChunkTaskIDs, CurrentUserRoleIDs, RoleAssigneeName } from '../../role-assignees';
import { ResolveTaskRecordLinksFromRows, type TaskLinkRow, type TaskRecordLink } from '../../task-record-links';
import { EnsureTasksEngineLoaded, RunViewsBatch } from '../../tasks-engine.helper';
import {
    CountTotalPendingSuggestions,
    FilterTasksByPendingSuggestions,
    FormatPendingSuggestionTooltip,
    TaskFieldSuggestionsHelper,
    type TaskPendingSuggestionsSummary,
} from '../../task-field-suggestions.helper';

export interface TaskListPersonRow {
    ID: string;
    FirstName: string;
    LastName: string;
}

export interface TaskRow {
    ID: string;
    Name: string;
    Description: string | null;
    Status: string;
    Priority: string;
    DueAt: Date | null;
    PercentComplete: number;
    HoursEstimated: number | null;
    ParentID: string | null;
    Depth: number;
    OrganizationID?: string | null;
    OrganizationName?: string | null;
    Assignees?: { Name: string; Role: string; Status: string; RecordID?: string; EntityName?: string; IsRole?: boolean }[];
    Tags?: { Name: string; Color: string }[];
    LinkedRecords?: TaskRecordLink[];
    TaskTypeStatusName?: string | null;
    IsOverdue: boolean;
    IsDueSoon: boolean;
    ChildCount?: number;
    CompletedChildCount?: number;
    LoggedMinutes?: number | null;
    IsTimerRunning?: boolean;
    PendingSuggestionCount?: number;
    PendingSuggestionFields?: string[];
    PendingSuggestionTooltip?: string;
    PendingSuggestionPreview?: string;
}

export function computeDueStatus(
    dueAt: Date | null,
    status: string,
    now: Date = new Date(),
): { isOverdue: boolean; isDueSoon: boolean } {
    const isActive = status !== 'Completed' && status !== 'Cancelled';
    const isOverdue = isActive && dueAt != null && dueAt < now;
    const isDueSoon =
        isActive &&
        dueAt != null &&
        dueAt >= now &&
        dueAt.getTime() - now.getTime() <= 48 * 60 * 60 * 1000;
    return { isOverdue, isDueSoon };
}

export class BeforeTaskSelectedEvent {
    Cancel = false;
    constructor(public Task: TaskRow) {}
}

export class BeforeStatusChangeEvent {
    Cancel = false;
    constructor(
        public Task: TaskRow,
        public NewStatus: string,
        public UnknownFields?: ('Assignees' | 'Tags' | 'Subtasks')[],
    ) {}
}

/**
 * Calm Hierarchical WBS Tree List (L3 Explorer component).
 *
 * - Tactile 1-click `<mjt-completion-ring>` separate from hover multi-select checkbox
 * - WBS sub-task completion rollups (`2/4`) with tree connectors
 * - Connected Business Record chips (`mjRecordLink`) + `TaskTypeStatus` stage pills
 * - Floating `<mjt-bulk-action-dock>` summoned when >= 1 task is checked
 * - Natural-language `<mjt-quick-capture>` when `ShowQuickAdd` is enabled
 */
@Component({
    selector: 'bizapps-task-list',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [
        DatePipe,
        NgTemplateOutlet,
        FormsModule,
        BaseFormsModule,
        MJButtonDirective,
        MJEmptyStateComponent,
        TaskCompletionRingComponent,
        TaskBulkActionDockComponent,
        TaskQuickCaptureComponent,
    ],
    template: `
        <div class="mjt-list-host" [class.is-compact]="Compact">
            @if (!HideToolbar) {
                <div class="mjt-list-toolbar">
                    <div class="mjt-search-box">
                        <i class="fa-solid fa-magnifying-glass mjt-search-ic" aria-hidden="true"></i>
                        <input
                            type="text"
                            class="mjt-search-inp"
                            [(ngModel)]="searchText"
                            (ngModelChange)="onSearchChange()"
                            placeholder="Search tasks..."
                            aria-label="Search tasks" />
                    </div>
                    <div class="mjt-toolbar-right">
                        <div class="mjt-status-pills" role="group" aria-label="Status filter">
                            @for (f of statusFilters; track f.value) {
                                <button
                                    type="button"
                                    class="mjt-s-pill"
                                    [class.is-active]="statusFilter === f.value"
                                    (click)="statusFilter = f.value; applyFilters()">
                                    {{ f.label }}
                                    @if (f.value === '' && tasks.length > 0) {
                                        <span class="mjt-s-count">{{ tasks.length }}</span>
                                    }
                                </button>
                            }
                        </div>
                        @if (ShowCreateButton && !ReadOnly) {
                            <button type="button" mjButton variant="primary" size="sm" (click)="CreateTask.emit()">
                                <i class="fa-solid fa-plus" aria-hidden="true"></i> New Task
                            </button>
                        }
                    </div>
                </div>
            }

            @if (ShowQuickAdd && !ReadOnly) {
                <mjt-quick-capture
                    [Compact]="true"
                    [Busy]="quickAdding"
                    Placeholder="Quick add task... (try 'Draft deck tomorrow @Jordan !high')"
                    (Submitted)="onQuickCaptureSubmit($event)">
                </mjt-quick-capture>
            }

            @if (bulkError) {
                <div class="mjt-list-error" role="alert">{{ bulkError }}</div>
            }
            @if (bulkSuccess) {
                <div class="mjt-list-success" role="status">
                    <i class="fa-solid fa-circle-check" aria-hidden="true"></i>
                    <span>{{ bulkSuccess }}</span>
                    <button type="button" class="mjt-list-dismiss" (click)="bulkSuccess = ''">Dismiss</button>
                </div>
            }

            @if (loading) {
                <div class="mjt-list-loading">Loading tasks...</div>
            } @else if (loadError) {
                <mj-empty-state
                    Icon="fa-solid fa-triangle-exclamation"
                    Title="Unable to load tasks"
                    [Message]="loadError"
                    Variant="error"
                    Size="compact">
                </mj-empty-state>
            } @else if (filteredTasks.length === 0) {
                <mj-empty-state
                    Icon="fa-solid fa-clipboard-check"
                    Title="No matching tasks"
                    Message="Adjust your filters or add a new task to get started."
                    Size="compact">
                </mj-empty-state>
            } @else {
                @if (!ReadOnly && !Compact) {
                    <div class="mjt-select-strip">
                        <label class="mjt-select-all-lbl">
                            <input
                                type="checkbox"
                                [checked]="allVisibleSelected"
                                [indeterminate]="selectedIDs.length > 0 && !allVisibleSelected"
                                (change)="toggleSelectAllVisible()" />
                            <span>{{ selectedIDs.length > 0 ? selectedIDs.length + ' of ' + filteredTasks.length + ' selected' : 'Select tasks for bulk actions (Shift+click for range)' }}</span>
                        </label>
                    </div>
                }
                <div class="mjt-tree-list" role="list" [class.has-selection]="selectedIDs.length > 0">
                    @for (task of filteredTasks; track task.ID) {
                        @if (task.Depth === 0 || isParentExpanded(task)) {
                            <div
                                class="mjt-row-wrap"
                                role="listitem"
                                [class.is-child]="task.Depth > 0"
                                [style.paddingLeft.px]="task.Depth * 24">
                                <div
                                    class="mjt-row"
                                    [class.is-selected]="isSelected(task.ID)"
                                    [class.is-done]="task.Status === 'Completed'"
                                    (click)="onTaskClick(task)"
                                    (dblclick)="onTaskDoubleClick(task)">
                                    <div class="mjt-row-left">
                                        @if (!ReadOnly) {
                                            <input
                                                type="checkbox"
                                                class="mjt-bulk-chk"
                                                [checked]="isSelected(task.ID)"
                                                [attr.aria-label]="'Select ' + task.Name"
                                                (click)="onCheckboxClick($event, task.ID)" />
                                        }

                                        @if ((task.ChildCount ?? 0) > 0) {
                                            <button
                                                type="button"
                                                class="mjt-exp-btn"
                                                [attr.aria-expanded]="expandedIDs.has(task.ID)"
                                                [attr.aria-label]="'Toggle sub-tasks for ' + task.Name"
                                                (click)="$event.stopPropagation(); toggleExpand(task.ID)">
                                                <i
                                                    class="fa-solid"
                                                    [class.fa-chevron-down]="expandedIDs.has(task.ID)"
                                                    [class.fa-chevron-right]="!expandedIDs.has(task.ID)"
                                                    aria-hidden="true"></i>
                                            </button>
                                        }

                                        <mjt-completion-ring
                                            [Status]="asStatus(task.Status)"
                                            [TaskName]="task.Name"
                                            [Disabled]="ReadOnly"
                                            (Toggled)="onRingToggle(task, $event)">
                                        </mjt-completion-ring>

                                        <div class="mjt-row-copy">
                                            <div class="mjt-row-title-line">
                                                <span class="mjt-row-title">{{ task.Name }}</span>
                                                @if (EffectiveRowBadgesTemplate) {
                                                    <span class="mjt-row-slot-badges" (click)="$event.stopPropagation()">
                                                        <ng-container *ngTemplateOutlet="EffectiveRowBadgesTemplate; context: rowBadgeContext(task)"></ng-container>
                                                    </span>
                                                }
                                                @for (badge of resolveRowBadges(task); track badge.Label) {
                                                    <span
                                                        class="mjt-badge-pill"
                                                        [class]="'mjt-badge-pill mjt-badge-pill--' + badge.Tone"
                                                        [attr.title]="badge.Tooltip || badge.Label">
                                                        @if (badge.Icon) {
                                                            <i [class]="badge.Icon" aria-hidden="true"></i>
                                                        }
                                                        <span>{{ badge.Label }}</span>
                                                    </span>
                                                }
                                                @if (task.TaskTypeStatusName) {
                                                    <span class="mjt-stage-pill">{{ task.TaskTypeStatusName }}</span>
                                                }
                                                @if ((task.ChildCount ?? 0) > 0) {
                                                    <span class="mjt-wbs-pill" title="Completed / total sub-tasks">
                                                        <i class="fa-solid fa-diagram-project" aria-hidden="true"></i>
                                                        {{ task.CompletedChildCount ?? 0 }}/{{ task.ChildCount }}
                                                    </span>
                                                }
                                            </div>
                                            @if (task.LinkedRecords && task.LinkedRecords.length > 0 && !Compact) {
                                                <div class="mjt-links-inline">
                                                    @for (rec of task.LinkedRecords; track rec.EntityName + ':' + rec.RecordID) {
                                                        <span
                                                            class="mjt-rec-link"
                                                            mjRecordLink
                                                            [EntityName]="rec.EntityName"
                                                            [RecordID]="rec.RecordID"
                                                            [DisplayName]="rec.Name"
                                                            (click)="$event.stopPropagation()">
                                                            <i class="fa-solid fa-link" aria-hidden="true"></i>
                                                            {{ rec.Name }}
                                                        </span>
                                                    }
                                                </div>
                                            }
                                        </div>
                                    </div>

                                    <div class="mjt-row-right">
                                        @if (task.OrganizationName && !Compact) {
                                            <span class="mjt-org-chip" [title]="'Organization: ' + task.OrganizationName">
                                                <i class="fa-solid fa-building" aria-hidden="true"></i>
                                                <span>{{ task.OrganizationName }}</span>
                                            </span>
                                        }

                                        @if (task.Tags && task.Tags.length > 0 && !Compact) {
                                            @for (tag of task.Tags.slice(0, 2); track tag.Name) {
                                                <span class="mjt-tag-badge">{{ tag.Name }}</span>
                                            }
                                        }

                                        <span class="mjt-pri-badge" [class]="'mjt-pri--' + task.Priority.toLowerCase()">
                                            {{ task.Priority }}
                                        </span>

                                        @if (task.DueAt) {
                                            <span
                                                class="mjt-due-lbl"
                                                [class.is-overdue]="task.IsOverdue"
                                                [class.is-soon]="task.IsDueSoon">
                                                <i class="fa-regular fa-calendar" aria-hidden="true"></i>
                                                {{ task.DueAt | date:'MMM d' }}
                                            </span>
                                        }

                                        @if (task.Assignees && task.Assignees.length > 0) {
                                            <span class="mjt-assignee-chip" [class.is-role]="task.Assignees[0].IsRole" [title]="assigneeNames(task)">
                                                @if (task.Assignees[0].IsRole) {
                                                    <i class="fa-solid fa-users mjt-assignee-role-ic" aria-hidden="true"></i>
                                                } @else {
                                                    <span class="mjt-assignee-avatar">{{ assigneeInitials(task.Assignees[0].Name) }}</span>
                                                }
                                                <span class="mjt-assignee-short">{{ assigneeShortName(task.Assignees[0].Name) }}</span>
                                                @if (task.Assignees.length > 1) {
                                                    <span class="mjt-assignee-more">+{{ task.Assignees.length - 1 }}</span>
                                                }
                                            </span>
                                        } @else if (!Compact) {
                                            <span class="mjt-unassigned-chip" title="Unassigned">Unassigned</span>
                                        }
                                    </div>
                                </div>
                            </div>
                        }
                    }
                </div>
            }

            @if (!ReadOnly && !ExternalBulkDock) {
                <mjt-bulk-action-dock
                    [SelectedCount]="selectedIDs.length"
                    [TotalCount]="filteredTasks.length"
                    [Busy]="bulkBusy"
                    [PeopleOptions]="bulkPeopleOptions"
                    [RoleOptions]="bulkRoleOptions"
                    [TaskRoleOptions]="bulkTaskRoleOptions"
                    [OrganizationOptions]="bulkOrgOptions"
                    [CategoryOptions]="bulkCategoryOptions"
                    [TaskTypeOptions]="bulkTaskTypeOptions"
                    [WorkflowStageOptions]="bulkStageOptions"
                    [TagOptions]="bulkTagOptions"
                    (ActionRequested)="onBulkDockAction($event)">
                </mjt-bulk-action-dock>
            }
        </div>
    `,
    styles: [`
        :host { display: block; width: 100%; min-width: 0; font-family: var(--mj-font-family); }
        .mjt-list-host { display: flex; flex-direction: column; gap: 10px; width: 100%; min-width: 0; }
        .mjt-list-toolbar {
            display: flex; align-items: center; justify-content: space-between; gap: 10px; flex-wrap: wrap;
        }
        .mjt-search-box {
            display: flex; align-items: center; gap: 8px; flex: 1 1 200px; max-width: 320px;
            padding: 6px 10px; border: 1px solid var(--mj-border-default); border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface);
        }
        .mjt-search-ic { color: var(--mj-text-muted); font-size: 12px; }
        .mjt-search-inp {
            border: none; outline: none; background: transparent; color: var(--mj-text-primary);
            font-family: inherit; font-size: var(--mj-text-sm, 14px); width: 100%; min-width: 0;
        }
        .mjt-toolbar-right { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
        .mjt-status-pills { display: flex; align-items: center; gap: 4px; flex-wrap: wrap; }
        .mjt-s-pill {
            display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; min-height: 28px;
            border-radius: var(--mj-radius-full, 9999px); border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface); color: var(--mj-text-secondary);
            font-family: inherit; font-size: var(--mj-text-xs, 12px); font-weight: var(--mj-font-semibold, 600);
            cursor: pointer;
        }
        .mjt-s-pill.is-active {
            background: var(--mj-brand-primary); border-color: var(--mj-brand-primary); color: var(--mj-text-inverse);
        }
        .mjt-s-count { opacity: 0.85; font-size: 11px; }
        .mjt-list-loading { padding: 32px; text-align: center; color: var(--mj-text-muted); font-size: var(--mj-text-sm, 14px); }
        .mjt-list-error {
            padding: 8px 12px; border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-status-error-bg); color: var(--mj-status-error-text); font-size: var(--mj-text-xs, 12px);
        }
        .mjt-list-success {
            display: flex; align-items: center; gap: 8px;
            padding: 8px 12px; border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-status-success-bg); color: var(--mj-status-success-text);
            font-size: var(--mj-text-xs, 12px); font-weight: var(--mj-font-semibold, 600);
        }
        .mjt-list-dismiss {
            margin-left: auto; border: none; background: transparent; color: inherit;
            text-decoration: underline; font-size: 11px; cursor: pointer;
        }
        .mjt-select-strip {
            display: flex; align-items: center; justify-content: space-between;
            padding: 2px 12px;
        }
        .mjt-select-all-lbl {
            display: inline-flex; align-items: center; gap: 8px;
            font-size: 11.5px; color: var(--mj-text-muted); cursor: pointer; user-select: none;
        }
        .mjt-select-all-lbl input { accent-color: var(--mj-brand-primary); cursor: pointer; }
        .mjt-org-chip {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 2px 7px; border-radius: var(--mj-radius-sm, 4px);
            background: var(--mj-bg-surface-sunken); border: 1px solid var(--mj-border-default);
            color: var(--mj-text-secondary); font-size: 11px; font-weight: var(--mj-font-medium, 500);
            max-width: 148px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
        }
        .mjt-org-chip i { font-size: 10px; opacity: 0.75; flex-shrink: 0; }
        .mjt-assignee-chip {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 2px 8px 2px 3px; border-radius: var(--mj-radius-full, 9999px);
            background: var(--mj-bg-surface-sunken); border: 1px solid var(--mj-border-default);
            color: var(--mj-text-primary); font-size: 11.5px; font-weight: var(--mj-font-medium, 500);
            white-space: nowrap;
        }
        .mjt-assignee-chip.is-role {
            padding-left: 7px;
            background: color-mix(in srgb, var(--mj-brand-primary) 10%, var(--mj-bg-surface));
            border-color: color-mix(in srgb, var(--mj-brand-primary) 28%, transparent);
            color: var(--mj-brand-primary);
        }
        .mjt-assignee-role-ic { font-size: 10px; }
        .mjt-assignee-avatar {
            width: 20px; height: 20px; border-radius: 50%;
            background: color-mix(in srgb, var(--mj-brand-primary) 16%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
            font-size: 9.5px; font-weight: var(--mj-font-bold, 700);
            display: inline-flex; align-items: center; justify-content: center; flex-shrink: 0;
        }
        .mjt-assignee-short { max-width: 110px; overflow: hidden; text-overflow: ellipsis; }
        .mjt-assignee-more { font-size: 10.5px; color: var(--mj-text-muted); font-weight: var(--mj-font-semibold, 600); }
        .mjt-unassigned-chip {
            font-size: 11px; color: var(--mj-text-muted); font-style: italic; white-space: nowrap;
        }
        .mjt-tree-list { display: flex; flex-direction: column; gap: 6px; padding-bottom: 80px; }
        .mjt-row-wrap { min-width: 0; }
        .mjt-row {
            display: flex; align-items: center; justify-content: space-between; gap: 12px;
            padding: 10px 12px; border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface); border: 1px solid var(--mj-border-default);
            cursor: pointer; transition: border-color 140ms ease, background 140ms ease;
        }
        .mjt-row:hover { border-color: var(--mj-brand-primary); background: var(--mj-bg-surface-hover); }
        .mjt-row.is-selected {
            border-color: var(--mj-brand-primary);
            background: var(--mj-surface-base-bg-selected, color-mix(in oklab, var(--mj-brand-primary) 8%, var(--mj-bg-surface)));
        }
        .mjt-row.is-done .mjt-row-title { text-decoration: line-through; color: var(--mj-text-muted); }
        .mjt-row-left { display: flex; align-items: center; gap: 10px; flex: 1; min-width: 0; }
        .mjt-bulk-chk {
            width: 15px; height: 15px; accent-color: var(--mj-brand-primary); cursor: pointer; flex-shrink: 0;
            opacity: 0; transition: opacity 140ms ease;
        }
        .mjt-row:hover .mjt-bulk-chk,
        .mjt-row:focus-within .mjt-bulk-chk,
        .mjt-tree-list.has-selection .mjt-bulk-chk,
        .mjt-bulk-chk:checked { opacity: 1; }
        .mjt-exp-btn {
            width: 22px; height: 22px; border: none; background: transparent; color: var(--mj-text-muted);
            cursor: pointer; display: inline-flex; align-items: center; justify-content: center;
            border-radius: var(--mj-radius-sm, 4px); flex-shrink: 0; font-size: 11px;
        }
        .mjt-exp-btn:hover { background: var(--mj-bg-surface-sunken); color: var(--mj-text-primary); }
        .mjt-row-copy { flex: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px; }
        .mjt-row-title-line { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
        .mjt-row-title {
            font-size: var(--mj-text-sm, 14px); font-weight: var(--mj-font-medium, 500);
            color: var(--mj-text-primary); line-height: 1.35;
        }
        .mjt-row-slot-badges { display: inline-flex; align-items: center; gap: 5px; flex-wrap: wrap; }
        .mjt-badge-pill {
            display: inline-flex; align-items: center; gap: 4px; padding: 1px 7px;
            border-radius: var(--mj-radius-full, 9999px); font-size: 11px; font-weight: var(--mj-font-semibold, 600);
            border: 1px solid transparent; white-space: nowrap;
        }
        .mjt-badge-pill--neutral { background: var(--mj-bg-surface-sunken); color: var(--mj-text-secondary); border-color: var(--mj-border-default); }
        .mjt-badge-pill--info { background: var(--mj-status-info-bg); color: var(--mj-status-info-text); border-color: color-mix(in oklab, var(--mj-brand-primary) 26%, transparent); }
        .mjt-badge-pill--success { background: var(--mj-status-success-bg); color: var(--mj-status-success-text); border-color: color-mix(in oklab, var(--mj-status-success) 30%, transparent); }
        .mjt-badge-pill--warning { background: var(--mj-status-warning-bg); color: var(--mj-status-warning-text); border-color: color-mix(in oklab, var(--mj-status-warning) 32%, transparent); }
        .mjt-badge-pill--error { background: var(--mj-status-error-bg); color: var(--mj-status-error-text); border-color: color-mix(in oklab, var(--mj-status-error) 32%, transparent); }
        .mjt-stage-pill {
            font-size: 11px; font-weight: var(--mj-font-semibold, 600); padding: 1px 7px;
            border-radius: var(--mj-radius-full, 9999px);
            background: color-mix(in srgb, var(--mj-brand-primary) 12%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
        }
        .mjt-wbs-pill {
            display: inline-flex; align-items: center; gap: 4px; font-size: 11px;
            font-family: var(--mj-font-family-mono, monospace); font-weight: var(--mj-font-semibold, 600);
            padding: 1px 7px; border-radius: var(--mj-radius-full, 9999px);
            background: var(--mj-bg-surface-sunken); color: var(--mj-text-secondary);
            border: 1px solid var(--mj-border-default);
        }
        .mjt-links-inline { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
        .mjt-rec-link {
            display: inline-flex; align-items: center; gap: 4px; font-size: 11.5px;
            color: var(--mj-text-link); padding: 1px 6px; border-radius: var(--mj-radius-sm, 4px);
            background: var(--mj-bg-surface-sunken); border: 1px solid var(--mj-border-subtle);
        }
        .mjt-row-right { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; justify-content: flex-end; flex-shrink: 0; }
        .mjt-tag-badge {
            font-size: 11px; padding: 2px 7px; border-radius: var(--mj-radius-sm, 4px);
            background: var(--mj-bg-surface-sunken); color: var(--mj-text-secondary);
            border: 1px solid var(--mj-border-default);
        }
        .mjt-pri-badge {
            font-size: 11px; font-weight: var(--mj-font-semibold, 600); padding: 2px 8px;
            border-radius: var(--mj-radius-full, 9999px);
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
        .mjt-due-lbl {
            display: inline-flex; align-items: center; gap: 4px; font-size: var(--mj-text-xs, 12px);
            color: var(--mj-text-muted); white-space: nowrap;
        }
        .mjt-due-lbl.is-overdue { color: var(--mj-status-error-text); font-weight: var(--mj-font-semibold, 600); }
        .mjt-due-lbl.is-soon { color: var(--mj-status-warning-text); font-weight: var(--mj-font-semibold, 600); }
        .mjt-assignee-pill {
            width: 24px; height: 24px; border-radius: 50%;
            background: color-mix(in oklab, var(--mj-brand-primary) 14%, var(--mj-bg-surface));
            color: var(--mj-brand-primary); font-size: 10px; font-weight: var(--mj-font-bold, 700);
            display: inline-flex; align-items: center; justify-content: center;
        }
        @media (max-width: 768px) {
            .mjt-select-strip,
            .mjt-bulk-chk { display: none; }
        }
        @media (max-width: 640px) {
            .mjt-row { flex-direction: column; align-items: stretch; gap: 8px; }
            .mjt-row-right { justify-content: flex-start; padding-left: 30px; }
        }
    `],
})
export class TaskListComponent implements OnInit, OnChanges {
    @Input() Provider: IMetadataProvider | null = null;
    /** Optional pre-loaded controlled tasks. When non-null, zero internal RunView queries fire. */
    @Input() Tasks: readonly TaskWidgetItem[] | null = null;
    /** Optional project root TaskID to reuse {@link TasksEngineBase.LoadProjectSubtree} across WBS/Kanban/Gantt. */
    @Input() ProjectRootTaskID: string | null = null;
    @Input() CategoryID: string | null = null;
    /** Optional pre-resolved Task IDs to fetch (RLS-safe alternative to subquery ExtraFilters). */
    @Input() PreloadedTaskIds: string[] | null = null;
    @Input() ExtraFilter: string | null = null;
    @Input() StatusFilter: string | null = null;
    @Input() PriorityFilter: string | null = null;
    @Input() TypeIDFilter: string | null = null;
    @Input() AssigneeFilter: string | null = null;
    @Input() DueDateFilter: TaskDueDateFilterKey | null = null;
    @Input() OrganizationIDFilter: string | null = null;
    @Input() CurrentPersonID: string | null = null;
    @Input() SearchText = '';
    @Input() HideToolbar = false;
    @Input() ShowCreateButton = false;
    @Input() Compact = false;
    @Input() ShowQuickAdd = false;
    @Input() QuickAddDefaultTypeID: string | null = null;
    @Input() AssigneeScope: string | string[] | null = null;
    @Input() ReadOnly = false;
    @Input() ExternalBulkDock = false;
    @Input() SelectedIDs: string[] | null = null;
    /** Optional resolver returning declarative badges rendered on each row. */
    @Input() RowBadgeResolver: ((task: TaskRow) => readonly TaskBadgeDescriptor[]) | null = null;
    /** Optional forwarded template for row badges (e.g. from TaskPanelComponent). */
    @Input() RowBadgesTemplate: TemplateRef<TaskWbsRowTemplateContext> | null = null;

    @ContentChild('rowBadges') public contentRowBadges?: TemplateRef<TaskWbsRowTemplateContext>;

    public get EffectiveRowBadgesTemplate(): TemplateRef<TaskWbsRowTemplateContext> | null {
        return this.contentRowBadges ?? this.RowBadgesTemplate ?? null;
    }

    public rowBadgeContext(task: TaskRow): TaskWbsRowTemplateContext {
        const controlled = this.Tasks?.find((t) => UUIDsEqual(t.ID, task.ID));
        const item: TaskWidgetItem = controlled ?? {
            ID: task.ID,
            Name: task.Name,
            Description: task.Description,
            ParentID: task.ParentID,
            Status: this.asStatus(task.Status),
            DueAt: task.DueAt,
            PercentComplete: task.PercentComplete,
            HoursEstimated: task.HoursEstimated,
            OrganizationID: task.OrganizationID ?? null,
            OrganizationName: task.OrganizationName ?? null,
            TaskTypeStatusName: task.TaskTypeStatusName ?? null,
        };
        return { $implicit: item, depth: task.Depth };
    }

    public resolveRowBadges(task: TaskRow): readonly TaskBadgeDescriptor[] {
        return this.RowBadgeResolver ? this.RowBadgeResolver(task) : [];
    }

    private _pendingSuggestionsOnly = false;
    private isInitialized = false;

    @Input()
    public get PendingSuggestionsOnly(): boolean {
        return this._pendingSuggestionsOnly;
    }
    public set PendingSuggestionsOnly(value: boolean) {
        const next = Boolean(value);
        if (next !== this._pendingSuggestionsOnly) {
            this._pendingSuggestionsOnly = next;
            if (this.isInitialized) {
                this.applyFilters();
            }
        }
    }

    public get ProviderToUse(): IMetadataProvider {
        return this.Provider ?? Metadata.Provider;
    }

    @Output() PendingSuggestionsOnlyChange = new EventEmitter<boolean>();
    @Output() SelectedIDsChange = new EventEmitter<string[]>();
    @Output() VisibleTaskIDsChange = new EventEmitter<string[]>();
    @Output() BeforeTaskSelected = new EventEmitter<BeforeTaskSelectedEvent>();
    @Output() AfterTaskSelected = new EventEmitter<TaskRow>();
    @Output() TaskDoubleClicked = new EventEmitter<TaskRow>();
    @Output() BeforeStatusChange = new EventEmitter<BeforeStatusChangeEvent>();
    @Output() AfterStatusChange = new EventEmitter<TaskRow>();
    @Output() CreateTask = new EventEmitter<void>();
    @Output() AfterTaskCreated = new EventEmitter<string>();

    public tasks: TaskRow[] = [];
    public filteredTasks: TaskRow[] = [];
    public selectedIDs: string[] = [];
    public expandedIDs = new Set<string>();
    public quickAddPeople: TaskListPersonRow[] = [];
    public quickAddName = '';
    public quickAddPersonID = '';
    public quickAdding = false;
    public bulkStatus = '';
    public bulkPercent: number | null = null;
    public bulkError = '';
    public bulkSuccess = '';
    public bulkBusy = false;
    public bulkPeopleOptions: TaskBulkLookupOption[] = [];
    public bulkRoleOptions: TaskBulkLookupOption[] = [];
    public bulkTaskRoleOptions: TaskBulkLookupOption[] = [];
    public bulkOrgOptions: TaskBulkLookupOption[] = [];
    public bulkCategoryOptions: TaskBulkLookupOption[] = [];
    public bulkTaskTypeOptions: TaskBulkLookupOption[] = [];
    public bulkStageOptions: TaskBulkLookupOption[] = [];
    public bulkTagOptions: TaskBulkLookupOption[] = [];
    public loading = false;
    public loadError: string | null = null;
    public searchText = '';
    public statusFilter = '';
    public fieldSuggestionsAvailable = false;
    public pendingSuggestionsByTask = new Map<string, TaskPendingSuggestionsSummary>();
    public cdr = inject(ChangeDetectorRef);

    public get totalPendingSuggestionsCount(): number {
        if (this.pendingSuggestionsByTask.size > 0) {
            return CountTotalPendingSuggestions(this.pendingSuggestionsByTask);
        }
        return this.tasks.reduce((sum, t) => sum + (t.PendingSuggestionCount ?? 0), 0);
    }

    public get tasksWithPendingSuggestionsCount(): number {
        if (this.pendingSuggestionsByTask.size > 0) {
            return this.pendingSuggestionsByTask.size;
        }
        return this.tasks.filter((t) => (t.PendingSuggestionCount ?? 0) > 0).length;
    }

    public statusFilters = [
        { label: 'All', value: '' },
        { label: 'Open', value: 'Open' },
        { label: 'In Progress', value: 'InProgress' },
        { label: 'Blocked', value: 'Blocked' },
        { label: 'Completed', value: 'Completed' },
    ];

    private searchTimeout: ReturnType<typeof setTimeout> | null = null;
    private lastCheckedTaskID: string | null = null;

    public get allVisibleSelected(): boolean {
        return (
            this.filteredTasks.length > 0 &&
            this.filteredTasks.every((t) => this.isSelected(t.ID))
        );
    }

    public ngOnInit(): void {
        this.isInitialized = true;
        if (this.StatusFilter) this.statusFilter = this.StatusFilter;
        if (this.SearchText) this.searchText = this.SearchText;
        if (this.Tasks !== null) {
            this.applyControlledTasks();
        } else {
            void this.loadTasks();
            if (this.ShowQuickAdd && !this.ReadOnly) void this.loadQuickAddPeople();
        }
    }

    public ngOnChanges(changes: SimpleChanges): void {
        if (changes['Tasks']) {
            if (this.Tasks !== null) {
                this.applyControlledTasks();
                return;
            } else if (!changes['Tasks'].firstChange) {
                void this.loadTasks();
                return;
            }
        }
        const reloadNeeded =
            this.Tasks === null &&
            ((changes['ProjectRootTaskID'] && !changes['ProjectRootTaskID'].firstChange) ||
                (changes['PreloadedTaskIds'] && !changes['PreloadedTaskIds'].firstChange) ||
                (changes['ExtraFilter'] && !changes['ExtraFilter'].firstChange) ||
                (changes['CategoryID'] && !changes['CategoryID'].firstChange) ||
                (changes['PriorityFilter'] && !changes['PriorityFilter'].firstChange) ||
                (changes['TypeIDFilter'] && !changes['TypeIDFilter'].firstChange) ||
                (changes['OrganizationIDFilter'] && !changes['OrganizationIDFilter'].firstChange));
        if (changes['StatusFilter'] && !changes['StatusFilter'].firstChange) {
            this.statusFilter = this.StatusFilter ?? '';
            this.applyFilters();
        }
        if (changes['SearchText'] && !changes['SearchText'].firstChange) {
            this.searchText = this.SearchText ?? '';
            this.applyFilters();
        }
        if (changes['SelectedIDs'] && this.SelectedIDs !== null) {
            this.selectedIDs = [...this.SelectedIDs];
            this.cdr.markForCheck();
        }
        if (
            (changes['AssigneeFilter'] && !changes['AssigneeFilter'].firstChange) ||
            (changes['DueDateFilter'] && !changes['DueDateFilter'].firstChange)
        ) {
            this.applyFilters();
        }
        if (reloadNeeded) {
            void this.loadTasks();
        }
    }

    public async Refresh(): Promise<void> {
        if (this.Tasks !== null) {
            this.applyControlledTasks();
            return;
        }
        await this.loadTasks();
    }

    public SelectTask(taskID: string): void {
        const task = this.tasks.find((t) => UUIDsEqual(t.ID, taskID));
        if (task) this.onTaskClick(task);
    }

    public ClearSelection(): void {
        this.selectedIDs = [];
        this.SelectedIDsChange.emit([]);
        this.cdr.markForCheck();
    }

    private isIdExpanded(taskID: string): boolean {
        if (this.expandedIDs.has(taskID)) return true;
        for (const id of this.expandedIDs) {
            if (UUIDsEqual(id, taskID)) return true;
        }
        return false;
    }

    public ToggleExpand(taskID: string): void {
        let removed = false;
        for (const id of [...this.expandedIDs]) {
            if (UUIDsEqual(id, taskID)) {
                this.expandedIDs.delete(id);
                removed = true;
            }
        }
        if (!removed) {
            this.expandedIDs.add(taskID);
        }
        this.cdr.markForCheck();
    }

    public toggleExpand(taskID: string): void {
        this.ToggleExpand(taskID);
    }

    /**
     * Walks the entire ancestor chain up to depth 0 so collapsing any ancestor
     * hides all of its descendants (preventing orphaned grandchildren).
     */
    public isParentExpanded(task: TaskRow): boolean {
        if (!task.ParentID) return true;
        const byId = new Map<string, TaskRow>();
        for (const row of this.tasks) {
            byId.set(row.ID.toLowerCase(), row);
        }
        const visited = new Set<string>([task.ID.toLowerCase()]);
        let curParentId: string | null = task.ParentID;
        while (curParentId) {
            const norm = curParentId.toLowerCase();
            if (visited.has(norm)) break;
            visited.add(norm);
            if (!this.isIdExpanded(curParentId)) {
                return false;
            }
            const parentRow = byId.get(norm);
            if (!parentRow) break;
            curParentId = parentRow.ParentID;
        }
        return true;
    }

    public isSelected(taskID: string): boolean {
        return this.selectedIDs.some((id) => UUIDsEqual(id, taskID));
    }

    public onCheckboxClick(event: MouseEvent, taskID: string): void {
        event.stopPropagation();
        if (event.shiftKey && this.lastCheckedTaskID) {
            const visibleIds = this.filteredTasks.map((t) => t.ID);
            const fromIdx = visibleIds.findIndex((id) => UUIDsEqual(id, this.lastCheckedTaskID));
            const toIdx = visibleIds.findIndex((id) => UUIDsEqual(id, taskID));
            if (fromIdx >= 0 && toIdx >= 0) {
                const start = Math.min(fromIdx, toIdx);
                const end = Math.max(fromIdx, toIdx);
                const next = new Set(this.selectedIDs.map((id) => id.toLowerCase()));
                const merged = [...this.selectedIDs];
                for (let i = start; i <= end; i++) {
                    const id = visibleIds[i];
                    if (!next.has(id.toLowerCase())) {
                        next.add(id.toLowerCase());
                        merged.push(id);
                    }
                }
                this.selectedIDs = merged;
                this.lastCheckedTaskID = taskID;
                this.SelectedIDsChange.emit([...this.selectedIDs]);
                this.cdr.markForCheck();
                return;
            }
        }
        this.toggleSelect(taskID);
        this.lastCheckedTaskID = taskID;
    }

    public toggleSelectAllVisible(): void {
        if (this.allVisibleSelected) {
            this.selectedIDs = [];
        } else {
            this.selectedIDs = this.filteredTasks.map((t) => t.ID);
        }
        this.SelectedIDsChange.emit([...this.selectedIDs]);
        this.cdr.markForCheck();
    }

    public toggleSelect(taskID: string): void {
        if (this.isSelected(taskID)) {
            this.selectedIDs = this.selectedIDs.filter((id) => !UUIDsEqual(id, taskID));
        } else {
            this.selectedIDs = [...this.selectedIDs, taskID];
        }
        this.SelectedIDsChange.emit([...this.selectedIDs]);
        this.cdr.markForCheck();
    }

    public asStatus(status: string): TaskStatusValue {
        if (status === 'Open' || status === 'InProgress' || status === 'Blocked' || status === 'Completed' || status === 'Cancelled') {
            return status;
        }
        return 'Open';
    }

    public assigneeNames(task: TaskRow): string {
        return (task.Assignees ?? []).map((a) => a.Name).join(', ');
    }

    public assigneeShortName(name: string): string {
        const parts = name.trim().split(/\s+/).filter(Boolean);
        if (parts.length <= 1) return name.trim();
        return `${parts[0]} ${parts[parts.length - 1][0]}.`;
    }

    public assigneeInitials(name: string): string {
        const parts = name.trim().split(/\s+/).filter(Boolean);
        if (parts.length === 0) return '?';
        if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
        return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }

    public onSearchChange(): void {
        if (this.searchTimeout) clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => this.applyFilters(), 150);
    }

    public get pendingSuggestionsOnly(): boolean {
        return this._pendingSuggestionsOnly;
    }

    public togglePendingSuggestionsFilter(): void {
        this._pendingSuggestionsOnly = !this._pendingSuggestionsOnly;
        this.PendingSuggestionsOnlyChange.emit(this._pendingSuggestionsOnly);
        this.applyFilters();
    }

    public getTaskSuggestionTooltip(task: TaskRow): string {
        if (task.PendingSuggestionTooltip) return task.PendingSuggestionTooltip;
        const summary =
            this.pendingSuggestionsByTask.get(NormalizeUUID(task.ID)) ??
            ((task.PendingSuggestionCount ?? 0) > 0
                ? {
                      pendingCount: task.PendingSuggestionCount ?? 0,
                      fieldNames: task.PendingSuggestionFields ?? [],
                  }
                : null);
        return FormatPendingSuggestionTooltip(summary);
    }

    public resetFilters(): void {
        this.statusFilter = '';
        this.searchText = '';
        if (this._pendingSuggestionsOnly) {
            this._pendingSuggestionsOnly = false;
            this.PendingSuggestionsOnlyChange.emit(false);
        }
        this.applyFilters();
    }

    public applyFilters(): void {
        const q = this.searchText.trim().toLowerCase();
        const currentRoles = CurrentUserRoleIDs();
        const hasActiveFilter = Boolean(
            q ||
                this.statusFilter ||
                this.OrganizationIDFilter ||
                this.DueDateFilter ||
                this.AssigneeFilter ||
                this._pendingSuggestionsOnly,
        );

        let matched = this.tasks.filter((t) => {
            if (this.statusFilter && t.Status !== this.statusFilter) return false;
            if (this.OrganizationIDFilter === '__none__') {
                if (t.OrganizationID) return false;
            } else if (this.OrganizationIDFilter) {
                if (!t.OrganizationID || !UUIDsEqual(t.OrganizationID, this.OrganizationIDFilter)) return false;
            }
            if (
                q &&
                !t.Name.toLowerCase().includes(q) &&
                !(t.Description?.toLowerCase().includes(q) ?? false) &&
                !(t.OrganizationName?.toLowerCase().includes(q) ?? false)
            ) {
                return false;
            }
            if (!MatchesDueDateFilter(t.DueAt, t.Status, this.DueDateFilter)) {
                return false;
            }
            const assigneeRefs = (t.Assignees ?? [])
                .filter((a) => Boolean(a.RecordID))
                .map((a) => ({ RecordID: a.RecordID!, EntityName: a.EntityName }));
            if (!MatchesAssigneeFilter(assigneeRefs, this.AssigneeFilter, this.CurrentPersonID, currentRoles)) {
                return false;
            }
            return true;
        });
        if (this._pendingSuggestionsOnly) {
            if (this.pendingSuggestionsByTask.size > 0) {
                matched = FilterTasksByPendingSuggestions(matched, true, this.pendingSuggestionsByTask);
            } else {
                matched = matched.filter((t) => (t.PendingSuggestionCount ?? 0) > 0);
            }
        }

        // Preserve full ancestor chains for hierarchical tasks when filters are active
        let list = matched;
        if (hasActiveFilter && matched.length > 0 && matched.length < this.tasks.length) {
            const byId = new Map<string, TaskRow>();
            for (const row of this.tasks) {
                byId.set(row.ID.toLowerCase(), row);
            }
            const keepIds = new Set<string>();
            for (const row of matched) {
                keepIds.add(row.ID.toLowerCase());
                let curParentId = row.ParentID;
                const seen = new Set<string>([row.ID.toLowerCase()]);
                while (curParentId) {
                    const norm = curParentId.toLowerCase();
                    if (seen.has(norm)) break;
                    seen.add(norm);
                    const parentRow = byId.get(norm);
                    if (!parentRow) break;
                    keepIds.add(norm);
                    this.expandedIDs.add(parentRow.ID);
                    curParentId = parentRow.ParentID;
                }
            }
            list = this.tasks.filter((row) => keepIds.has(row.ID.toLowerCase()));
        }

        this.filteredTasks = list;
        this.VisibleTaskIDsChange.emit(list.map((t) => t.ID));
        this.cdr.markForCheck();
    }

    private applyControlledTasks(): void {
        const inputTasks = this.Tasks ?? [];
        const tree = BuildWbsTree(inputTasks);
        const ordered: TaskRow[] = [];
        const now = new Date();

        const visit = (node: TaskWbsNode<TaskWidgetItem>): void => {
            const item = node.Item;
            const dueRaw = item.DueAt ?? item.DueDate ?? null;
            const dueAt = dueRaw ? (dueRaw instanceof Date ? dueRaw : new Date(dueRaw)) : null;
            const validDue = dueAt && !Number.isNaN(dueAt.getTime()) ? dueAt : null;
            const { isOverdue, isDueSoon } = computeDueStatus(validDue, item.Status, now);

            const assignees =
                item.Assignees && item.Assignees.length > 0
                    ? item.Assignees.map((a) => ({
                          Name: a.DisplayName,
                          Role: a.RoleName ?? '',
                          Status: a.Status,
                          RecordID: a.RecordID,
                          EntityName: a.EntityName,
                          IsRole: a.IsRole,
                      }))
                    : item.AssigneeNames && item.AssigneeNames.length > 0
                      ? item.AssigneeNames.map((name) => ({
                            Name: name,
                            Role: '',
                            Status: 'Pending',
                        }))
                      : undefined;

            const tags = item.Tags?.map((t) => ({
                Name: t.Name,
                Color: t.ColorCode ?? 'var(--mj-brand-primary)',
            }));

            const linkedRecords = item.LinkedRecords?.map((l) => ({
                TaskID: item.ID,
                EntityName: l.EntityName,
                RecordID: l.RecordID,
                Name: l.DisplayName,
            }));

            const completedDirectChildren = node.Children.filter((c) => c.Item.Status === 'Completed').length;

            ordered.push({
                ID: item.ID,
                Name: item.Name,
                Description: item.Description ?? null,
                Status: item.Status,
                Priority: item.Priority ?? 'Medium',
                DueAt: validDue,
                PercentComplete: node.EffectivePercentComplete,
                HoursEstimated: item.HoursEstimated ?? null,
                ParentID: item.ParentID ?? null,
                Depth: node.Depth,
                OrganizationID: item.OrganizationID ?? null,
                OrganizationName: item.OrganizationName ?? null,
                Assignees: assignees,
                Tags: tags,
                LinkedRecords: linkedRecords,
                TaskTypeStatusName: item.TaskTypeStatusName ?? null,
                IsOverdue: isOverdue,
                IsDueSoon: isDueSoon,
                ChildCount: node.Children.length,
                CompletedChildCount: completedDirectChildren,
            });

            if (node.Children.length > 0 && node.Depth === 0) {
                this.expandedIDs.add(item.ID);
            }
            for (const child of node.Children) {
                visit(child);
            }
        };

        for (const root of tree) {
            visit(root);
        }

        this.loading = false;
        this.tasks = ordered;
        this.applyFilters();
    }

    public onTaskClick(task: TaskRow): void {
        const before = new BeforeTaskSelectedEvent(task);
        this.BeforeTaskSelected.emit(before);
        if (before.Cancel) return;
        this.AfterTaskSelected.emit(task);
    }

    public onTaskDoubleClick(task: TaskRow): void {
        this.TaskDoubleClicked.emit(task);
    }

    public async onRingToggle(task: TaskRow, nextStatus: TaskStatusValue): Promise<void> {
        const before = new BeforeStatusChangeEvent(task, nextStatus);
        this.BeforeStatusChange.emit(before);
        if (before.Cancel) return;

        const entity = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
        await entity.InnerLoad(CompositeKey.FromID(task.ID));
        entity.Status = nextStatus;
        entity.PercentComplete = nextStatus === 'Completed' ? 100 : 0;
        if (await entity.Save()) {
            task.Status = nextStatus;
            task.PercentComplete = entity.PercentComplete;
            this.AfterStatusChange.emit(task);
            await this.loadTasks();
        }
    }

    public async onBulkDockAction(action: TaskBulkActionRequest): Promise<void> {
        if (action.Kind === 'clear') {
            this.ClearSelection();
            return;
        }
        if (action.Kind === 'select-all') {
            this.selectedIDs = this.filteredTasks.map((t) => t.ID);
            this.cdr.markForCheck();
            return;
        }
        if (action.Kind === 'status' && action.Status) {
            await this.executeBulkPatch({ Status: action.Status });
            return;
        }
        if (action.Kind === 'priority' && action.Priority) {
            await this.executeBulkPatch({ Priority: action.Priority });
            return;
        }
        if (action.Kind === 'apply' && action.Patch) {
            await this.executeBulkPatch(action.Patch);
        }
    }

    /**
     * Dispatches bulk multi-field task updates in a single server-side Remotable Operation
     * (`BizAppsTasks.BulkUpdateTasks`) so all entity lifecycle hooks and audit logs fire authoritatively.
     */
    public async executeBulkPatch(patch: TaskBulkPatch): Promise<void> {
        if (this.selectedIDs.length === 0 || this.bulkBusy) return;
        this.bulkBusy = true;
        this.bulkError = '';
        this.bulkSuccess = '';
        this.cdr.markForCheck();

        try {
            const targetIds = [...this.selectedIDs];
            const res = await new TasksBulkUpdateOperation().Execute({
                TaskIDs: targetIds,
                ...patch,
            });
            if (!res.Success || !res.Output) {
                this.bulkError = res.ErrorMessage || 'Bulk update failed on the server.';
                return;
            }
            const out = res.Output;
            if (out.FailedCount > 0) {
                this.bulkError = `${out.UpdatedCount} updated, ${out.FailedCount} failed: ${out.Failures[0]?.Error ?? 'unknown error'}`;
            } else {
                this.bulkSuccess = `Updated ${out.UpdatedCount} ${out.UpdatedCount === 1 ? 'task' : 'tasks'}.`;
            }
            this.selectedIDs = [];
            await this.loadTasks();
            const firstUpdated = this.tasks.find((t) => out.UpdatedTaskIDs.some((id) => UUIDsEqual(id, t.ID)));
            if (firstUpdated) {
                this.AfterStatusChange.emit(firstUpdated);
            }
        } catch (err) {
            this.bulkError = err instanceof Error ? err.message : 'Bulk update failed.';
        } finally {
            this.bulkBusy = false;
            this.cdr.markForCheck();
        }
    }

    public async applyBulkStatus(): Promise<void> {
        if (!this.bulkStatus || this.selectedIDs.length === 0) return;
        this.bulkError = '';

        for (const id of [...this.selectedIDs]) {
            const task = this.tasks.find((t) => UUIDsEqual(t.ID, id));
            if (!task) continue;
            const before = new BeforeStatusChangeEvent(task, this.bulkStatus);
            this.BeforeStatusChange.emit(before);
            if (before.Cancel) continue;

            const entity = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            await entity.InnerLoad(CompositeKey.FromID(task.ID));
            entity.Status = this.bulkStatus as TaskStatusValue;
            if (this.bulkStatus === 'Completed') {
                entity.PercentComplete = 100;
            } else if (this.bulkStatus === 'InProgress' && this.bulkPercent != null) {
                entity.PercentComplete = this.bulkPercent;
            }
            const saved = await entity.Save();
            if (!saved) {
                this.bulkError = entity.LatestResult?.CompleteMessage || 'Bulk update failed.';
                break;
            }
            task.Status = this.bulkStatus;
            this.AfterStatusChange.emit(task);
        }

        this.selectedIDs = [];
        this.bulkStatus = '';
        await this.loadTasks();
    }

    private async applyBulkPriority(priority: TaskPriorityValue): Promise<void> {
        this.bulkError = '';
        for (const id of [...this.selectedIDs]) {
            const task = this.tasks.find((t) => UUIDsEqual(t.ID, id));
            if (!task) continue;
            const entity = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            await entity.InnerLoad(CompositeKey.FromID(task.ID));
            entity.Priority = priority;
            if (!(await entity.Save())) {
                this.bulkError = entity.LatestResult?.CompleteMessage || 'Bulk priority update failed.';
                break;
            }
        }
        this.selectedIDs = [];
        await this.loadTasks();
    }

    private async loadQuickAddPeople(): Promise<void> {
        if (!this.canReadEntity('MJ_BizApps_Common: People')) {
            this.quickAddPeople = [];
            this.cdr.markForCheck();
            return;
        }
        if (!this.AssigneeScope) {
            const people = await TasksEngineBase.Instance.GetOrLoadAllPeople(this.ProviderToUse).catch(() => []);
            this.quickAddPeople = people.map((p) => ({
                ID: p.ID,
                FirstName: p.FirstName,
                LastName: p.LastName,
            }));
            this.cdr.markForCheck();
            return;
        }
        let extraFilter: string | undefined;
        if (Array.isArray(this.AssigneeScope) && this.AssigneeScope.length > 0) {
            extraFilter = `ID IN (${this.AssigneeScope.map((id) => `'${EscapeSQLString(id)}'`).join(',')})`;
        } else if (typeof this.AssigneeScope === 'string' && this.AssigneeScope) {
            extraFilter = this.AssigneeScope;
        }
        const res = await this.createRunView().RunView<TaskListPersonRow>({
            EntityName: 'MJ_BizApps_Common: People',
            ExtraFilter: extraFilter,
            OrderBy: 'LastName ASC, FirstName ASC',
            ResultType: 'simple',
        });
        this.quickAddPeople = res?.Results ?? [];
        this.cdr.markForCheck();
    }

    /**
     * Checks whether the current user has Read permission on `entityName` before issuing
     * optional enrichment `RunView` queries, preventing avoidable GraphQL permission errors
     * for restricted roles (e.g. Space Participants).
     */
    public canReadEntity(entityName: string): boolean {
        const provider = this.ProviderToUse;
        const currentUser = provider?.CurrentUser;
        if (!currentUser) return true;
        const entity = provider?.EntityByName?.(entityName);
        if (!entity) return false;
        return Boolean(entity.GetUserPermisions(currentUser)?.CanRead);
    }

    private createRunView(): RunView {
        const p = this.ProviderToUse;
        if (p && typeof (p as Partial<IRunViewProvider>).RunView === 'function') {
            return RunView.FromMetadataProvider(p);
        }
        return new RunView();
    }

    private async resolveQuickAddTypeId(): Promise<string | null> {
        const engine = await EnsureTasksEngineLoaded(this.ProviderToUse);
        if (engine.TaskTypes.length > 0) {
            return SelectGenericQuickAddTaskTypeID(engine.TaskTypes, this.QuickAddDefaultTypeID);
        }
        return ResolveDefaultGenericTaskTypeID(this.createRunView(), this.QuickAddDefaultTypeID);
    }

    public async quickAddTask(): Promise<void> {
        const name = this.quickAddName.trim();
        if (!name || this.quickAdding) return;
        this.quickAdding = true;
        this.cdr.markForCheck();
        try {
            const typeID = await this.resolveQuickAddTypeId();
            if (!typeID) return;

            const entity = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            entity.NewRecord();
            entity.Name = name;
            entity.TypeID = typeID;
            entity.Status = 'Open';
            entity.Priority = 'Medium';
            if (this.CategoryID) entity.CategoryID = this.CategoryID;

            if (this.quickAddPersonID) {
                const peopleEntityID = Metadata.Provider.EntityByName('MJ_BizApps_Common: People')?.ID;
                if (peopleEntityID) {
                    const assignment = await entity.Assignments.Create();
                    assignment.AssigneeEntityID = peopleEntityID;
                    assignment.AssigneeRecordID = this.quickAddPersonID;
                    assignment.Status = 'Pending';
                }
            }

            if (await entity.Save()) {
                this.quickAddName = '';
                this.quickAddPersonID = '';
                this.AfterTaskCreated.emit(entity.ID);
                await this.loadTasks();
            }
        } finally {
            this.quickAdding = false;
            this.cdr.markForCheck();
        }
    }

    public async onQuickCaptureSubmit(event: TaskQuickCaptureSubmitEvent): Promise<void> {
        if (!event.Title || this.quickAdding) return;
        this.quickAdding = true;
        this.cdr.markForCheck();
        try {
            const typeID = await this.resolveQuickAddTypeId();
            if (!typeID) return;

            const entity = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            entity.NewRecord();
            entity.Name = event.Title;
            entity.TypeID = typeID;
            entity.Status = 'Open';
            entity.Priority = event.Priority ?? 'Medium';
            entity.CategoryID = this.CategoryID;
            if (event.DueAt) entity.DueAt = event.DueAt;
            if (event.HoursEstimated != null) entity.HoursEstimated = event.HoursEstimated;

            if (await entity.Save()) {
                if (event.AssigneeQuery) {
                    const q = event.AssigneeQuery.toLowerCase();
                    const match = this.quickAddPeople.find((p) =>
                        `${p.FirstName} ${p.LastName}`.toLowerCase().includes(q),
                    );
                    const peopleEntityID = Metadata.Provider.EntityByName('MJ_BizApps_Common: People')?.ID;
                    if (match && peopleEntityID) {
                        const a = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>('MJ_BizApps_Tasks: Task Assignments');
                        a.NewRecord();
                        a.TaskID = entity.ID;
                        a.AssigneeEntityID = peopleEntityID;
                        a.AssigneeRecordID = match.ID;
                        await a.Save();
                    }
                }
                this.AfterTaskCreated.emit(entity.ID);
                await this.loadTasks();
            }
        } finally {
            this.quickAdding = false;
            this.cdr.markForCheck();
        }
    }

    public async loadTasks(): Promise<void> {
        if (this.Tasks !== null) {
            this.loadError = null;
            this.applyControlledTasks();
            return;
        }
        this.loading = true;
        this.loadError = null;
        this.cdr.markForCheck();
        try {
            if (this.PreloadedTaskIds !== null) {
                const chunks = ChunkTaskIDs(this.PreloadedTaskIds);
                if (chunks.length === 0) {
                    this.tasks = [];
                    this.filteredTasks = [];
                    this.VisibleTaskIDsChange.emit([]);
                    return;
                }
            }

            const filters: string[] = ["Status <> 'Cancelled'"];
            if (this.CategoryID) filters.push(`CategoryID = '${EscapeSQLString(this.CategoryID)}'`);
            if (this.PriorityFilter) filters.push(`Priority = '${EscapeSQLString(this.PriorityFilter)}'`);
            if (this.TypeIDFilter) filters.push(`TypeID = '${EscapeSQLString(this.TypeIDFilter)}'`);
            if (this.OrganizationIDFilter === '__none__') {
                filters.push('OrganizationID IS NULL');
            } else if (this.OrganizationIDFilter) {
                filters.push(`OrganizationID = '${EscapeSQLString(this.OrganizationIDFilter)}'`);
            }
            if (this.ExtraFilter) filters.push(this.ExtraFilter);

            type TaskQueryRow = {
                ID: string;
                Name: string;
                Description: string | null;
                Status: string;
                Priority: string;
                DueAt: string | null;
                PercentComplete: number | null;
                HoursEstimated: number | null;
                LoggedMinutes?: number | null;
                ParentID: string | null;
                TaskTypeStatus: string | null;
                OrganizationID?: string | null;
                Organization?: string | null;
            };
            type TaskAssignmentRow = {
                TaskID: string;
                AssigneeEntityID: string;
                AssigneeRecordID: string;
                RoleID: string | null;
                Status: string | null;
            };

            const provider = this.ProviderToUse;
            const useProjectSubtree =
                Boolean(this.ProjectRootTaskID && IsValidUUID(this.ProjectRootTaskID)) &&
                this.PreloadedTaskIds === null &&
                !this.ExtraFilter &&
                !this.CategoryID &&
                !this.PriorityFilter &&
                !this.TypeIDFilter &&
                !this.OrganizationIDFilter;

            let raw: TaskQueryRow[] = [];
            let subtreeAssignments: TaskAssignmentRow[] | null = null;

            const enginePromise = EnsureTasksEngineLoaded(provider);

            if (useProjectSubtree && this.ProjectRootTaskID) {
                const bundle = await TasksEngineBase.Instance.LoadProjectSubtree(this.ProjectRootTaskID, {
                    provider,
                });
                raw = bundle.Tasks.map((t) => ({
                    ID: t.ID,
                    Name: t.Name,
                    Description: t.Description,
                    Status: t.Status,
                    Priority: t.Priority,
                    DueAt: t.DueAt,
                    PercentComplete: t.PercentComplete,
                    HoursEstimated: t.HoursEstimated,
                    LoggedMinutes: t.LoggedMinutes ?? null,
                    ParentID: t.ParentID,
                    TaskTypeStatus: t.TaskTypeStatus ?? null,
                    OrganizationID: t.OrganizationID ?? null,
                    Organization: t.Organization ?? null,
                }));
                subtreeAssignments = bundle.Assignments.map((a) => ({
                    TaskID: a.TaskID,
                    AssigneeEntityID: a.AssigneeEntityID,
                    AssigneeRecordID: a.AssigneeRecordID,
                    RoleID: a.RoleID,
                    Status: a.Status,
                }));
            } else if (this.PreloadedTaskIds !== null) {
                const chunks = ChunkTaskIDs(this.PreloadedTaskIds);
                const chunkParams: RunViewParams[] = chunks.map((chunk) => ({
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: [...filters, BuildTaskIDsInFilter(chunk)].join(' AND '),
                    OrderBy: 'Sequence ASC, DueAt ASC',
                    ResultType: 'simple',
                    BypassCache: true,
                }));
                const chunkResults = await RunViewsBatch(this.createRunView(), chunkParams);
                const failed = chunkResults.find((res) => !res?.Success);
                if (failed) {
                    const msg = failed.ErrorMessage || 'Failed to load tasks.';
                    LogError(msg);
                    this.loadError = msg;
                    this.tasks = [];
                    this.filteredTasks = [];
                    this.VisibleTaskIDsChange.emit([]);
                    return;
                }
                const seenIds = new Set<string>();
                for (const res of chunkResults) {
                    for (const row of (res.Results ?? []) as TaskQueryRow[]) {
                        const key = row.ID.toLowerCase();
                        if (!seenIds.has(key)) {
                            seenIds.add(key);
                            raw.push(row);
                        }
                    }
                }
            } else {
                const tasksRes = await this.createRunView().RunView<TaskQueryRow>({
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: filters.join(' AND '),
                    OrderBy: 'Sequence ASC, DueAt ASC',
                    ResultType: 'simple',
                    BypassCache: true,
                });
                if (!tasksRes?.Success) {
                    const msg = tasksRes?.ErrorMessage || 'Failed to load tasks.';
                    LogError(msg);
                    this.loadError = msg;
                    this.tasks = [];
                    this.filteredTasks = [];
                    this.VisibleTaskIDsChange.emit([]);
                    return;
                }
                raw = tasksRes.Results ?? [];
            }

            const taskIds = raw.map((r) => r.ID);
            const scopeFilter =
                taskIds.length > 0 && taskIds.length <= 500
                    ? `TaskID IN (${taskIds.map((id) => `'${EscapeSQLString(id)}'`).join(',')})`
                    : undefined;

            type ListBatchSlot = 'assignments' | 'tagLinks' | 'links';
            const dynamicBatchParams: RunViewParams[] = [];
            const dynamicBatchSlots: ListBatchSlot[] = [];

            if (
                subtreeAssignments === null &&
                taskIds.length > 0 &&
                this.canReadEntity('MJ_BizApps_Tasks: Task Assignments')
            ) {
                dynamicBatchParams.push({
                    EntityName: 'MJ_BizApps_Tasks: Task Assignments',
                    ExtraFilter: scopeFilter,
                    ResultType: 'simple',
                    BypassCache: true,
                });
                dynamicBatchSlots.push('assignments');
            }
            if (taskIds.length > 0 && this.canReadEntity('MJ_BizApps_Tasks: Task Tag Links')) {
                dynamicBatchParams.push({
                    EntityName: 'MJ_BizApps_Tasks: Task Tag Links',
                    ExtraFilter: scopeFilter,
                    Fields: ['TaskID', 'TagID'],
                    ResultType: 'simple',
                });
                dynamicBatchSlots.push('tagLinks');
            }
            const validLinkTaskIds = taskIds.filter((id) => IsValidUUID(id));
            if (validLinkTaskIds.length > 0 && validLinkTaskIds.length <= 500 && this.canReadEntity('MJ_BizApps_Tasks: Task Links')) {
                dynamicBatchParams.push({
                    EntityName: 'MJ_BizApps_Tasks: Task Links',
                    ExtraFilter: `TaskID IN (${validLinkTaskIds.map((id) => `'${EscapeSQLString(id)}'`).join(',')})`,
                    Fields: ['TaskID', 'EntityID', 'RecordID', 'Description'],
                    ResultType: 'simple',
                });
                dynamicBatchSlots.push('links');
            }

            const [engine, orgs, dynamicBatchResults, suggestionsRes] = await Promise.all([
                enginePromise,
                !this.ReadOnly && this.canReadEntity('MJ_BizApps_Common: Organizations')
                    ? TasksEngineBase.Instance.GetOrLoadActiveOrganizations(provider).catch(() => [])
                    : Promise.resolve([]),
                dynamicBatchParams.length > 0
                    ? RunViewsBatch(this.createRunView(), dynamicBatchParams).catch(() => [])
                    : Promise.resolve([]),
                taskIds.length > 0
                    ? TaskFieldSuggestionsHelper.LoadPendingSuggestions(provider, { taskIds }).catch(() => ({
                          available: false,
                          byTaskId: new Map<string, TaskPendingSuggestionsSummary>(),
                      }))
                    : Promise.resolve({
                          available: false,
                          byTaskId: new Map<string, TaskPendingSuggestionsSummary>(),
                      }),
            ]);

            let assignmentRows: TaskAssignmentRow[] = subtreeAssignments ?? [];
            let tagLinkRows: Array<{ TaskID: string; TagID: string }> = [];
            let linkRows: TaskLinkRow[] = [];

            for (let i = 0; i < dynamicBatchSlots.length; i++) {
                const res = dynamicBatchResults[i];
                if (!res?.Success) continue;
                switch (dynamicBatchSlots[i]) {
                    case 'assignments':
                        assignmentRows = (res.Results ?? []) as TaskAssignmentRow[];
                        break;
                    case 'tagLinks':
                        tagLinkRows = (res.Results ?? []) as Array<{ TaskID: string; TagID: string }>;
                        break;
                    case 'links':
                        linkRows = (res.Results ?? []) as TaskLinkRow[];
                        break;
                }
            }

            const rolesEntityID = provider.EntityByName?.('MJ: Roles')?.ID ?? null;
            const assignedPersonIds = [
                ...new Set(
                    assignmentRows
                        .filter((a) => !rolesEntityID || !UUIDsEqual(a.AssigneeEntityID, rolesEntityID))
                        .map((a) => a.AssigneeRecordID)
                        .filter(Boolean),
                ),
            ];
            const canReadPeople = this.canReadEntity('MJ_BizApps_Common: People');

            const [peopleList, peopleByIdMap, linksMap] = await Promise.all([
                !this.ReadOnly && canReadPeople
                    ? TasksEngineBase.Instance.GetOrLoadAllPeople(provider).catch(() => [])
                    : Promise.resolve([]),
                this.ReadOnly && canReadPeople && assignedPersonIds.length > 0
                    ? TasksEngineBase.Instance.GetOrLoadPeopleByIds(assignedPersonIds, provider).catch(() => new Map())
                    : Promise.resolve(new Map()),
                ResolveTaskRecordLinksFromRows(linkRows, provider).catch(() => new Map<string, TaskRecordLink[]>()),
            ]);

            const canReadRoles = this.canReadEntity('MJ_BizApps_Tasks: Task Roles');
            const canReadTags = this.canReadEntity('MJ_BizApps_Tasks: Task Tags');
            const canReadCategories = this.canReadEntity('MJ_BizApps_Tasks: Task Categories');
            const canReadTypes = this.canReadEntity('MJ_BizApps_Tasks: Task Types');
            const canReadStages = this.canReadEntity('MJ_BizApps_Tasks: Task Type Status');

            const effectiveTagRows = canReadTags ? engine.TaskTags : [];
            const effectiveRoles = canReadRoles ? engine.TaskRoles : [];

            if (!this.ReadOnly) {
                this.bulkPeopleOptions = peopleList.map((p) => ({
                    ID: p.ID,
                    Label: p.FullName,
                    EntityName: 'MJ_BizApps_Common: People',
                }));
                this.bulkRoleOptions = (provider.Roles ?? []).map((r) => ({
                    ID: r.ID,
                    Label: r.Name,
                    EntityName: 'MJ: Roles',
                }));
                this.bulkTaskRoleOptions = effectiveRoles.map((r) => ({ ID: r.ID, Label: r.Name }));
                this.bulkOrgOptions = orgs.map((o) => ({
                    ID: o.ID,
                    Label: o.Name,
                    Sublabel: o.LinkedCompanyID ? 'Company' : undefined,
                }));
                this.bulkCategoryOptions = (canReadCategories ? engine.ActiveCategories : []).map((c) => ({
                    ID: c.ID,
                    Label: c.Name,
                }));
                this.bulkTaskTypeOptions = FilterGenericCreatableTaskTypes(
                    canReadTypes ? engine.ActiveTaskTypes : [],
                ).map((t) => ({
                    ID: t.ID,
                    Label: t.Name,
                }));
                this.bulkStageOptions = (canReadStages ? engine.ActiveTypeStatuses : []).map((s) => ({
                    ID: s.ID,
                    Label: s.Name,
                }));
                this.bulkTagOptions = effectiveTagRows.map((t) => ({ ID: t.ID, Label: t.Name }));
            }

            this.fieldSuggestionsAvailable = suggestionsRes.available;
            this.pendingSuggestionsByTask = suggestionsRes.byTaskId;

            const personMap = new Map<string, string>();
            for (const p of peopleList) {
                personMap.set(p.ID.toLowerCase(), p.FullName);
            }
            for (const [k, p] of peopleByIdMap.entries()) {
                personMap.set(k, p.FullName);
            }
            const roleMap = new Map<string, string>();
            for (const r of effectiveRoles) {
                roleMap.set(r.ID.toLowerCase(), r.Name);
            }
            const tagMap = new Map<string, { Name: string; Color: string }>();
            for (const t of effectiveTagRows) {
                tagMap.set(t.ID.toLowerCase(), { Name: t.Name, Color: t.ColorCode ?? 'var(--mj-brand-primary)' });
            }
            const assigneesByTask = new Map<
                string,
                { Name: string; Role: string; Status: string; RecordID: string; EntityName: string; IsRole: boolean }[]
            >();
            for (const a of assignmentRows) {
                const key = a.TaskID.toLowerCase();
                const list = assigneesByTask.get(key) ?? [];
                const isRole = Boolean(rolesEntityID && UUIDsEqual(a.AssigneeEntityID, rolesEntityID));
                const displayName =
                    personMap.get(a.AssigneeRecordID.toLowerCase()) ??
                    RoleAssigneeName(a.AssigneeEntityID, a.AssigneeRecordID) ??
                    a.AssigneeRecordID;
                list.push({
                    Name: displayName,
                    Role: a.RoleID ? (roleMap.get(a.RoleID.toLowerCase()) ?? '') : '',
                    Status: a.Status ?? 'Pending',
                    RecordID: a.AssigneeRecordID,
                    EntityName: isRole ? 'MJ: Roles' : 'MJ_BizApps_Common: People',
                    IsRole: isRole,
                });
                assigneesByTask.set(key, list);
            }

            const tagsByTask = new Map<string, { Name: string; Color: string }[]>();
            for (const tl of tagLinkRows) {
                const tag = tagMap.get(tl.TagID.toLowerCase());
                if (!tag) continue;
                const key = tl.TaskID.toLowerCase();
                const list = tagsByTask.get(key) ?? [];
                list.push(tag);
                tagsByTask.set(key, list);
            }

            // Build tree order & child rollup counts
            const byId = new Map(raw.map((r) => [r.ID.toLowerCase(), r]));
            const childrenByParent = new Map<string, typeof raw>();
            const roots: typeof raw = [];
            for (const r of raw) {
                if (r.ParentID && byId.has(r.ParentID.toLowerCase())) {
                    const pKey = r.ParentID.toLowerCase();
                    const list = childrenByParent.get(pKey) ?? [];
                    list.push(r);
                    childrenByParent.set(pKey, list);
                } else {
                    roots.push(r);
                }
            }

            const ordered: TaskRow[] = [];
            const now = new Date();
            const visit = (item: (typeof raw)[number], depth: number): void => {
                const key = item.ID.toLowerCase();
                const kids = childrenByParent.get(key) ?? [];
                const completedKids = kids.filter((k) => k.Status === 'Completed').length;
                const dueAt = item.DueAt ? new Date(item.DueAt) : null;
                const { isOverdue, isDueSoon } = computeDueStatus(dueAt, item.Status, now);

                const summary = this.pendingSuggestionsByTask.get(NormalizeUUID(item.ID)) ?? null;
                ordered.push({
                    ID: item.ID,
                    Name: item.Name,
                    Description: item.Description,
                    Status: item.Status,
                    Priority: item.Priority,
                    DueAt: dueAt,
                    PercentComplete: item.PercentComplete ?? 0,
                    HoursEstimated: item.HoursEstimated,
                    LoggedMinutes: item.LoggedMinutes ?? null,
                    ParentID: item.ParentID,
                    Depth: depth,
                    OrganizationID: item.OrganizationID ?? null,
                    OrganizationName: item.Organization ?? null,
                    Assignees: assigneesByTask.get(key),
                    Tags: tagsByTask.get(key),
                    LinkedRecords: linksMap.get(key),
                    TaskTypeStatusName: item.TaskTypeStatus,
                    IsOverdue: isOverdue,
                    IsDueSoon: isDueSoon,
                    ChildCount: kids.length,
                    CompletedChildCount: completedKids,
                    PendingSuggestionCount: summary?.pendingCount ?? 0,
                    PendingSuggestionFields: summary?.fieldNames ?? [],
                    PendingSuggestionTooltip: FormatPendingSuggestionTooltip(summary),
                    PendingSuggestionPreview: summary?.topPreviewLabel ?? undefined,
                });
                if (kids.length > 0 && depth === 0) {
                    this.expandedIDs.add(item.ID);
                }
                for (const child of kids) {
                    visit(child, depth + 1);
                }
            };

            for (const root of roots) {
                visit(root, 0);
            }

            this.tasks = ordered;
            this.applyFilters();
        } catch (err) {
            LogError(err);
            this.loadError = err instanceof Error ? err.message : 'Failed to load tasks.';
            this.tasks = [];
            this.filteredTasks = [];
            this.VisibleTaskIDsChange.emit([]);
        } finally {
            this.loading = false;
            this.cdr.markForCheck();
        }
    }
}
