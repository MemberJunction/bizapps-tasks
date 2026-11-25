import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    ContentChild,
    EventEmitter,
    Input,
    OnChanges,
    Output,
    SimpleChanges,
    TemplateRef,
    inject,
} from '@angular/core';
import { DatePipe, NgTemplateOutlet } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CompositeKey, Metadata, RunView, type IMetadataProvider, type IRunViewProvider } from '@memberjunction/core';
import { EscapeSQLString, IsValidUUID, NormalizeUUID, UUIDsEqual } from '@memberjunction/global';
import { BaseFormsModule } from '@memberjunction/ng-base-forms';
import { SharedService } from '@memberjunction/ng-shared';
import {
    MJButtonDirective,
    MJProgressBarComponent,
    MJTabNavComponent,
    type TabConfig,
} from '@memberjunction/ng-ui-components';
import {
    FormatTaskActivityTypeLabel,
    FormatTaskStatusLabel,
    ResolveTaskUiArchetype,
    TaskOrchestrationService,
    TaskService,
} from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTaskCheckInEntity,
    mjBizAppsTasksTaskCommentEntity,
    mjBizAppsTasksTaskDependencyEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskLinkEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    TaskAdaptiveSpotlightComponent,
    TaskCompletionRingComponent,
    TaskWorkflowStepperComponent,
    type TaskAdaptiveSpotlightInput,
    type TaskApprovalActionEvent,
    type TaskAssignmentStatusValue,
    type TaskOkrCheckInSubmitEvent,
    type TaskPriorityValue,
    type TaskStatusValue,
    type TaskWidgetLinkedRecord,
    type TaskWidgetTypeStatus,
} from '@mj-biz-apps/tasks-ng-widgets';
import { OpenTaskRecord } from '../../open-task-record';
import { RoleAssigneeName } from '../../role-assignees';
import { LoadTaskRecordLinks } from '../../task-record-links';
import {
    FormatPendingSuggestionTooltip,
    TaskFieldSuggestionsHelper,
    type TaskPendingSuggestionsSummary,
} from '../../task-field-suggestions.helper';
import { RecordLinkPickerDialogComponent } from '../record-link-picker/record-link-picker-dialog.component';
import { TaskTimeEffortComponent } from '../task-time-effort/task-time-effort.component';
import type { TaskAssigneeInfo } from '../task-assignee-list/task-assignee-list.component';

export interface ActivityEntry {
    Type: 'activity' | 'comment';
    Timestamp: Date;
    PersonName?: string;
    Content: string;
    ActivityType?: string;
}

interface PersonRow {
    ID: string;
    FirstName: string;
    LastName: string;
}

interface InspectorAssigneeRow extends TaskAssigneeInfo {
    AssignmentID: string;
    AssigneeEntityName: string;
}

interface ChildSubtaskRow {
    ID: string;
    Name: string;
    Status: TaskStatusValue;
    Priority: TaskPriorityValue;
    PercentComplete: number;
}

export class BeforeCommentPostedEvent {
    Cancel = false;
    constructor(
        public TaskID: string,
        public Content: string,
    ) {}
}

/** Template context passed to `<bizapps-task-detail-panel>` `#detailTopExtension`. */
export interface TaskDetailTopExtensionContext {
    $implicit: string;
    taskId: string;
}

/**
 * Zero-Bounce Inline Task Inspector (L3 Explorer component).
 *
 * Single-click any task anywhere to inspect AND edit in place without a
 * View → Edit detour: 1-click completion ring, inline editable title, clickable
 * `TaskTypeStatus` stepper, Adaptive Spotlight (Approval gate / OKR Check-In /
 * Blocker & Effort / SLA Risk), Connected Business Records, per-assignee status
 * cycling, inline sub-tasks, tabbed Comments | Activity, and non-shifting delete confirm.
 */
@Component({
    selector: 'bizapps-task-detail-panel',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [
        DatePipe,
        NgTemplateOutlet,
        FormsModule,
        BaseFormsModule,
        MJButtonDirective,
        MJProgressBarComponent,
        MJTabNavComponent,
        TaskCompletionRingComponent,
        TaskWorkflowStepperComponent,
        TaskAdaptiveSpotlightComponent,
        RecordLinkPickerDialogComponent,
        TaskTimeEffortComponent,
    ],
    template: `
        @if (TaskID) {
            <div class="mjt-insp">
                @if (loading) {
                    <div class="mjt-insp-loading">Loading task...</div>
                } @else if (taskEntity) {
                    <!-- Top Action Bar -->
                    <div class="mjt-insp-topbar">
                        <div class="mjt-insp-crumbs">
                            @if (parentTaskName && taskEntity.ParentID) {
                                <span
                                    class="mjt-crumb-link"
                                    mjRecordLink
                                    [EntityName]="'MJ_BizApps_Tasks: Tasks'"
                                    [RecordID]="taskEntity.ParentID"
                                    [DisplayName]="parentTaskName">
                                    <i class="fa-solid fa-folder-open" aria-hidden="true"></i>
                                    {{ parentTaskName }}
                                </span>
                                <i class="fa-solid fa-chevron-right mjt-crumb-sep" aria-hidden="true"></i>
                            }
                            <span class="mjt-type-tag">{{ taskEntity.Type || 'Task' }}</span>
                        </div>

                        <div class="mjt-insp-actions">
                            @if (!ReadOnly) {
                                <span class="mjt-autosave-pill" [class.is-saving]="autoSaveState === 'saving'" role="status">
                                    <i class="fa-solid" [class.fa-spinner]="autoSaveState === 'saving'" [class.fa-spin]="autoSaveState === 'saving'" [class.fa-check]="autoSaveState !== 'saving'" aria-hidden="true"></i>
                                    <span>{{ autoSaveState === 'saving' ? 'Saving...' : 'Auto-saved' }}</span>
                                </span>
                            }
                            @if (ShowOpenForm) {
                                <button type="button" mjButton variant="outline" size="sm" (click)="onOpenFullRecord()" title="Open full Task record">
                                    <i class="fa-solid fa-arrow-up-right-from-square" aria-hidden="true"></i>
                                    <span>Open Form</span>
                                </button>
                            }
                            @if (ShowDelete && !ReadOnly) {
                                @if (!confirmingDelete) {
                                    <button type="button" mjButton variant="flat" size="sm" aria-label="Delete task" (click)="confirmingDelete = true">
                                        <i class="fa-solid fa-trash" aria-hidden="true"></i>
                                    </button>
                                } @else {
                                    <span class="mjt-del-inline">
                                        <button type="button" mjButton variant="danger" size="sm" (click)="onDelete()">Delete</button>
                                        <button type="button" mjButton variant="flat" size="sm" (click)="confirmingDelete = false">Cancel</button>
                                    </span>
                                }
                            }
                        </div>
                    </div>

                    <!-- Tactile Ring + Inline Editable Title -->
                    <div class="mjt-insp-hero">
                        <mjt-completion-ring
                            [Status]="taskEntity.Status"
                            [TaskName]="taskEntity.Name"
                            Size="lg"
                            [Disabled]="ReadOnly || busy"
                            (Toggled)="onToggleComplete($event)">
                        </mjt-completion-ring>
                        <input
                            type="text"
                            class="mjt-insp-title-input"
                            [(ngModel)]="draftTitle"
                            [disabled]="ReadOnly"
                            aria-label="Task title"
                            (blur)="saveInlineTitle()"
                            (keydown.enter)="saveInlineTitle()" />
                    </div>

                    <!-- Clickable TaskTypeStatus Stepper -->
                    @if (typeStatuses.length > 0) {
                        <mjt-workflow-stepper
                            [Statuses]="typeStatuses"
                            [ActiveStatusID]="taskEntity.TaskTypeStatusID"
                            [ReadOnly]="ReadOnly || busy"
                            (StageSelected)="onStageSelected($event)">
                        </mjt-workflow-stepper>
                    }

                    <!-- Optional Host Extension Slot (e.g. linked PR/Issue badge) -->
                    @if (EffectiveDetailTopExtensionTemplate && TaskID) {
                        <div class="mjt-insp-top-ext">
                            <ng-container
                                *ngTemplateOutlet="
                                    EffectiveDetailTopExtensionTemplate;
                                    context: { $implicit: TaskID, taskId: TaskID }
                                ">
                            </ng-container>
                        </div>
                    }

                    <!-- Inline Editable Meta Strip (Status / Priority / Due) -->
                    <div class="mjt-meta-bar">
                        <select
                            class="mjt-meta-sel"
                            [ngModel]="taskEntity.Status"
                            [disabled]="ReadOnly || busy"
                            aria-label="Status"
                            (ngModelChange)="updateScalarField('Status', $event)">
                            <option value="Open">Open</option>
                            <option value="InProgress">In Progress</option>
                            <option value="Blocked">Blocked</option>
                            <option value="Completed">Completed</option>
                            <option value="Cancelled">Cancelled</option>
                        </select>

                        <select
                            class="mjt-meta-sel"
                            [ngModel]="taskEntity.Priority"
                            [disabled]="ReadOnly || busy"
                            aria-label="Priority"
                            (ngModelChange)="updateScalarField('Priority', $event)">
                            <option value="Low">Low Priority</option>
                            <option value="Medium">Medium Priority</option>
                            <option value="High">High Priority</option>
                            <option value="Critical">Critical Priority</option>
                        </select>

                        <input
                            type="date"
                            class="mjt-meta-sel"
                            [ngModel]="dueDateInput"
                            [disabled]="ReadOnly || busy"
                            aria-label="Due date"
                            (ngModelChange)="updateDueDate($event)" />

                        @if (organizations.length > 0) {
                            <select
                                class="mjt-meta-sel"
                                [ngModel]="taskEntity.OrganizationID"
                                [disabled]="ReadOnly || busy"
                                aria-label="Organization"
                                (ngModelChange)="updateOrganization($event)">
                                <option [ngValue]="null">No organization</option>
                                @for (org of organizations; track org.ID) {
                                    <option [value]="org.ID">{{ org.LinkedCompanyID ? '★ ' + org.Name : org.Name }}</option>
                                }
                            </select>
                        }
                    </div>

                    <!-- Adaptive Spotlight (0px on simple General tasks!) -->
                    <mjt-adaptive-spotlight
                        [Data]="spotlightData"
                        [Busy]="busy"
                        [ReadOnly]="ReadOnly"
                        (ApprovalSubmitted)="onApprovalSubmitted($event)"
                        (CheckInSubmitted)="onCheckInSubmitted($event)"
                        (LinkedRecordClicked)="openLinkedRecord($event)">
                    </mjt-adaptive-spotlight>

                    <!-- Pending AI / Ambient Field Suggestions -->
                    @if (pendingSuggestionSummary && pendingSuggestionSummary.pendingCount > 0) {
                        <div class="mjt-suggestions-banner" [attr.title]="pendingSuggestionTooltip">
                            <i class="fa-solid fa-wand-magic-sparkles" aria-hidden="true"></i>
                            <div class="mjt-suggestions-body">
                                <strong>{{ pendingSuggestionTooltip }}</strong>
                                @if (pendingSuggestionSummary.topPreviewLabel) {
                                    <p>{{ pendingSuggestionSummary.topPreviewLabel }}</p>
                                }
                            </div>
                            @if (ShowOpenForm) {
                                <button type="button" mjButton variant="outline" size="sm" (click)="onOpenFullRecord()">
                                    Review
                                </button>
                            }
                        </div>
                    }

                    <!-- Inline Editable Description -->
                    <div class="mjt-block">
                        <label class="mjt-block-label" for="mjtInspDesc">Description</label>
                        @if (ReadOnly) {
                            <p class="mjt-desc">{{ taskEntity.Description || 'No description yet.' }}</p>
                        } @else {
                            <textarea
                                id="mjtInspDesc"
                                rows="3"
                                class="mjt-desc-input"
                                [(ngModel)]="draftDescription"
                                [disabled]="busy"
                                placeholder="Add context, links, or acceptance criteria..."
                                (blur)="saveInlineDescription()"></textarea>
                        }
                    </div>

                    <!-- Connected Business Records -->
                    <div class="mjt-block">
                        <div class="mjt-block-head">
                            <span class="mjt-block-label">Connected Business Records</span>
                            @if (!ReadOnly) {
                                <button type="button" mjButton variant="flat" size="sm" (click)="showLinkPicker = true">
                                    <i class="fa-solid fa-link" aria-hidden="true"></i> Link
                                </button>
                            }
                        </div>
                        @if (linkedRecords.length === 0) {
                            <span class="mjt-muted">No connected records yet.</span>
                        } @else {
                            <div class="mjt-links-wrap">
                                @for (rec of linkedRecords; track rec.EntityName + ':' + rec.RecordID) {
                                    <button type="button" class="mjt-rec-chip" (click)="openLinkedRecord(rec)">
                                        <i [class]="rec.IconClass || 'fa-solid fa-arrow-up-right-from-square'" aria-hidden="true"></i>
                                        <span>{{ rec.DisplayName }}</span>
                                    </button>
                                }
                            </div>
                        }
                    </div>

                    <!-- Assignees with Tappable Status Pill (32px desktop / 34px mobile) -->
                    <div class="mjt-block">
                        <span class="mjt-block-label">Assignees</span>
                        @if (assignees.length === 0) {
                            <span class="mjt-muted">Unassigned</span>
                        } @else {
                            <div class="mjt-assignee-list">
                                @for (a of assignees; track a.AssignmentID) {
                                    <div class="mjt-assignee-row">
                                        <span
                                            class="mjt-assignee-name"
                                            mjRecordLink
                                            [EntityName]="a.AssigneeEntityName"
                                            [RecordID]="a.AssigneeRecordID"
                                            [DisplayName]="a.DisplayName">
                                            {{ a.DisplayName }}
                                        </span>
                                        @if (a.RoleName) {
                                            <span class="mjt-role-tag">{{ a.RoleName }}</span>
                                        }
                                        <button
                                            type="button"
                                            class="mjt-assignee-status-pill"
                                            [class]="'mjt-status-pill--' + a.Status.toLowerCase()"
                                            [disabled]="ReadOnly || busy"
                                            [title]="'Assignee status: ' + formatStatus(a.Status) + ' — click to cycle'"
                                            (click)="cycleAssigneeStatus(a)">
                                            <span class="mjt-status-dot" aria-hidden="true"></span>
                                            <span>{{ formatStatus(a.Status) }}</span>
                                            <i class="fa-solid fa-caret-down mjt-status-caret" aria-hidden="true"></i>
                                        </button>
                                    </div>
                                }
                            </div>
                        }
                    </div>

                    <!-- Time & Effort -->
                    @if (ShowTimeEffort) {
                        <bizapps-task-time-effort
                            [TaskID]="TaskID"
                            [PersonID]="PersonID"
                            [ReadOnly]="ReadOnly">
                        </bizapps-task-time-effort>
                    }

                    <!-- Work Breakdown (Sub-tasks) -->
                    <div class="mjt-block">
                        <div class="mjt-block-head">
                            <span class="mjt-block-label">Sub-tasks ({{ completedSubtasksCount }}/{{ subtasks.length }})</span>
                        </div>
                        @if (subtasks.length > 0) {
                            <mj-progress-bar [Value]="subtasksPercent"></mj-progress-bar>
                            <div class="mjt-sub-list">
                                @for (child of subtasks; track child.ID) {
                                    <div class="mjt-sub-row">
                                        <mjt-completion-ring
                                            [Status]="child.Status"
                                            [TaskName]="child.Name"
                                            [Disabled]="ReadOnly || busy"
                                            (Toggled)="toggleSubtaskComplete(child, $event)">
                                        </mjt-completion-ring>
                                        <span
                                            class="mjt-sub-name"
                                            [class.is-done]="child.Status === 'Completed'"
                                            (click)="openSubtask(child.ID)">
                                            {{ child.Name }}
                                        </span>
                                    </div>
                                }
                            </div>
                        }
                        @if (!ReadOnly) {
                            <div class="mjt-inline-add">
                                <input
                                    type="text"
                                    class="mjt-inline-inp"
                                    [(ngModel)]="newSubtaskTitle"
                                    placeholder="Break down into a sub-task..."
                                    aria-label="New sub-task title"
                                    (keydown.enter)="addSubtask()" />
                                <button type="button" mjButton variant="outline" size="sm" [disabled]="!newSubtaskTitle.trim() || busy" (click)="addSubtask()">
                                    Add
                                </button>
                            </div>
                        }
                    </div>

                    <!-- Tabbed Comments | Activity Stream -->
                    <div class="mjt-block">
                        <mj-tab-nav
                            [Tabs]="streamTabs"
                            [ActiveKey]="activeStreamTab"
                            (TabChange)="activeStreamTab = $event">
                        </mj-tab-nav>

                        @if (activeStreamTab === 'comments' && !ReadOnly) {
                            <div class="mjt-inline-add">
                                <input
                                    type="text"
                                    class="mjt-inline-inp"
                                    [(ngModel)]="newComment"
                                    placeholder="Write a comment..."
                                    (keydown.enter)="PostComment()" />
                                <button type="button" mjButton variant="primary" size="sm" [disabled]="!newComment.trim()" (click)="PostComment()">
                                    Post
                                </button>
                            </div>
                            @if (commentError) {
                                <div class="mjt-err" role="alert">{{ commentError }}</div>
                            }
                        }

                        <div class="mjt-stream">
                            @for (entry of filteredTimeline; track entry.Timestamp.getTime() + entry.Content) {
                                <div class="mjt-stream-item" [class.is-comment]="entry.Type === 'comment'">
                                    <div class="mjt-stream-meta">
                                        <span class="mjt-stream-who">{{ entry.PersonName || 'System' }}</span>
                                        <span class="mjt-stream-when">{{ entry.Timestamp | date:'MMM d, h:mm a' }}</span>
                                    </div>
                                    <div class="mjt-stream-text">{{ entry.Content }}</div>
                                </div>
                            }
                            @if (filteredTimeline.length === 0) {
                                <span class="mjt-muted">
                                    {{ activeStreamTab === 'comments' ? 'No comments yet.' : 'No activity logged yet.' }}
                                </span>
                            }
                        </div>
                    </div>
                }

                <bizapps-record-link-picker-dialog
                    [Visible]="showLinkPicker"
                    (RecordSelected)="onLinkRecordSelected($event)"
                    (Cancelled)="showLinkPicker = false">
                </bizapps-record-link-picker-dialog>
            </div>
        }
    `,
    styles: [`
        :host {
            display: block;
            font-family: var(--mj-font-family);
            color: var(--mj-text-primary);
        }
        .mjt-insp {
            padding: 16px 20px 80px;
            display: flex;
            flex-direction: column;
            gap: 14px;
        }
        .mjt-autosave-pill {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 3px 9px;
            border-radius: var(--mj-radius-full, 9999px);
            background: var(--mj-status-success-bg);
            color: var(--mj-status-success-text);
            border: 1px solid color-mix(in oklab, var(--mj-status-success) 28%, transparent);
            font-size: 11px;
            font-weight: var(--mj-font-semibold, 600);
        }
        .mjt-autosave-pill.is-saving {
            background: var(--mj-status-info-bg);
            color: var(--mj-status-info-text);
            border-color: color-mix(in oklab, var(--mj-status-info) 28%, transparent);
        }
        .mjt-insp-loading {
            padding: 48px 16px;
            text-align: center;
            color: var(--mj-text-muted);
        }
        .mjt-insp-topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            flex-wrap: wrap;
        }
        .mjt-insp-crumbs {
            display: flex;
            align-items: center;
            gap: 6px;
            min-width: 0;
            flex-wrap: wrap;
        }
        .mjt-crumb-link {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-medium, 500);
            color: var(--mj-text-link);
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .mjt-crumb-sep {
            font-size: 9px;
            color: var(--mj-text-disabled);
        }
        .mjt-type-tag {
            font-size: 11px;
            font-weight: var(--mj-font-semibold, 600);
            padding: 2px 8px;
            border-radius: var(--mj-radius-full, 9999px);
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-secondary);
            border: 1px solid var(--mj-border-default);
        }
        .mjt-insp-actions,
        .mjt-del-inline {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .mjt-insp-hero {
            display: flex;
            align-items: center;
            gap: 10px;
            min-width: 0;
            width: 100%;
        }
        .mjt-insp-title-input {
            flex: 1 1 0%;
            min-width: 0;
            width: 100%;
            box-sizing: border-box;
            border: 1px solid transparent;
            border-radius: var(--mj-radius-md, 8px);
            background: transparent;
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: clamp(15px, 4vw, 18px);
            font-weight: var(--mj-font-bold, 700);
            padding: 4px 6px;
            margin-left: -6px;
            text-overflow: ellipsis;
            transition: border-color 140ms ease, background 140ms ease;
        }
        .mjt-insp-title-input:hover:not(:disabled) {
            background: var(--mj-bg-surface-sunken);
        }
        .mjt-insp-title-input:focus {
            outline: none;
            background: var(--mj-bg-surface);
            border-color: var(--mj-brand-primary);
        }
        .mjt-meta-bar {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .mjt-meta-sel {
            padding: 5px 10px;
            min-height: 32px;
            border-radius: var(--mj-radius-md, 8px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
        }
        .mjt-block {
            display: flex;
            flex-direction: column;
            gap: 8px;
            padding-top: 10px;
            border-top: 1px solid var(--mj-border-subtle);
        }
        .mjt-block-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
        }
        .mjt-block-label {
            font-size: 11px;
            font-weight: var(--mj-font-bold, 700);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--mj-text-muted);
        }
        .mjt-hint {
            font-weight: var(--mj-font-normal, 400);
            text-transform: none;
            letter-spacing: 0;
        }
        .mjt-desc {
            margin: 0;
            font-size: var(--mj-text-sm, 14px);
            color: var(--mj-text-secondary);
            line-height: 1.5;
            white-space: pre-wrap;
        }
        .mjt-desc-input {
            width: 100%;
            box-sizing: border-box;
            padding: 8px 10px;
            border: 1px solid var(--mj-border-subtle);
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: var(--mj-text-sm, 14px);
            line-height: 1.5;
            resize: vertical;
            transition: border-color 140ms ease, background 140ms ease;
        }
        .mjt-desc-input:hover:not(:disabled) {
            border-color: var(--mj-border-strong);
        }
        .mjt-desc-input:focus {
            outline: none;
            background: var(--mj-bg-surface);
            border-color: var(--mj-brand-primary);
            box-shadow: 0 0 0 3px color-mix(in oklab, var(--mj-brand-primary) 16%, transparent);
        }
        .mjt-muted {
            font-size: var(--mj-text-xs, 12px);
            color: var(--mj-text-muted);
            font-style: italic;
        }
        .mjt-suggestions-banner {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 12px;
            background: var(--mj-status-info-bg);
            border-radius: var(--mj-radius-md, 8px);
            border: 1px solid color-mix(in srgb, var(--mj-status-info) 30%, transparent);
        }
        .mjt-suggestions-banner i { color: var(--mj-status-info); font-size: 14px; flex-shrink: 0; }
        .mjt-suggestions-body { flex: 1; min-width: 0; }
        .mjt-suggestions-body strong { display: block; font-size: 12px; color: var(--mj-status-info-text); }
        .mjt-suggestions-body p { margin: 2px 0 0; font-size: 11.5px; color: var(--mj-text-secondary); }
        .mjt-links-wrap {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
        }
        .mjt-rec-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: var(--mj-radius-sm, 4px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-link);
            font-family: inherit;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-medium, 500);
            cursor: pointer;
        }
        .mjt-rec-chip:hover {
            border-color: var(--mj-brand-primary);
            background: var(--mj-bg-surface-hover);
        }
        .mjt-assignee-list,
        .mjt-sub-list,
        .mjt-stream {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .mjt-assignee-row,
        .mjt-sub-row {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px 8px;
            border-radius: var(--mj-radius-sm, 6px);
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-subtle);
        }
        .mjt-assignee-status-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            min-height: 32px;
            padding: 4px 10px;
            border-radius: var(--mj-radius-full, 9999px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: 11.5px;
            font-weight: var(--mj-font-semibold, 600);
            cursor: pointer;
            flex-shrink: 0;
            transition: border-color 140ms ease, background 140ms ease;
        }
        .mjt-assignee-status-pill:hover:not(:disabled) {
            border-color: var(--mj-brand-primary);
        }
        .mjt-assignee-status-pill:disabled { opacity: 0.6; cursor: not-allowed; }
        .mjt-status-dot {
            width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0;
            background: var(--mj-text-muted);
        }
        .mjt-status-caret { font-size: 10px; opacity: 0.7; }
        .mjt-status-pill--pending {
            background: var(--mj-bg-surface);
            color: var(--mj-text-secondary);
        }
        .mjt-status-pill--pending .mjt-status-dot {
            background: transparent;
            border: 2px solid var(--mj-text-muted);
            box-sizing: border-box;
        }
        .mjt-status-pill--inprogress {
            background: var(--mj-status-info-bg);
            color: var(--mj-status-info-text);
            border-color: color-mix(in oklab, var(--mj-status-info) 30%, transparent);
        }
        .mjt-status-pill--inprogress .mjt-status-dot { background: var(--mj-brand-primary); }
        .mjt-status-pill--completed {
            background: var(--mj-status-success-bg);
            color: var(--mj-status-success-text);
            border-color: color-mix(in oklab, var(--mj-status-success) 30%, transparent);
        }
        .mjt-status-pill--completed .mjt-status-dot { background: var(--mj-status-success); }
        @media (max-width: 640px) {
            .mjt-assignee-status-pill { min-height: 34px; padding: 5px 12px; }
        }
        .mjt-assignee-name,
        .mjt-sub-name {
            flex: 1;
            min-width: 0;
            font-size: var(--mj-text-sm, 14px);
            font-weight: var(--mj-font-medium, 500);
            color: var(--mj-text-primary);
            cursor: pointer;
        }
        .mjt-sub-name.is-done {
            text-decoration: line-through;
            color: var(--mj-text-muted);
        }
        .mjt-role-tag {
            font-size: 11px;
            padding: 1px 7px;
            border-radius: var(--mj-radius-full, 9999px);
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            color: var(--mj-text-secondary);
        }
        .mjt-assignee-status {
            font-size: 11px;
            color: var(--mj-text-muted);
        }
        .mjt-inline-add {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .mjt-inline-inp {
            flex: 1;
            min-width: 0;
            padding: 7px 10px;
            border: 1px solid var(--mj-border-strong);
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: var(--mj-text-sm, 14px);
        }
        .mjt-stream-item {
            padding: 8px 10px;
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-subtle);
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .mjt-stream-item.is-comment {
            background: var(--mj-bg-surface);
            border-color: var(--mj-border-default);
        }
        .mjt-stream-meta {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            font-size: 11px;
            color: var(--mj-text-muted);
        }
        .mjt-stream-who {
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-secondary);
        }
        .mjt-stream-text {
            font-size: var(--mj-text-xs, 12px);
            color: var(--mj-text-primary);
            line-height: 1.45;
        }
        .mjt-err {
            padding: 8px 10px;
            border-radius: var(--mj-radius-sm, 4px);
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
            font-size: var(--mj-text-xs, 12px);
        }
    `],
})
export class TaskDetailPanelComponent implements OnChanges {
    @Input() Provider: IMetadataProvider | null = null;
    @Input() TaskID: string | null = null;
    @Input() PersonID: string | null = null;
    @Input() ShowDelete = false;
    @Input() ReadOnly = false;
    /** Controls visibility of the Explorer "Open Form" button. */
    @Input() ShowOpenForm = true;
    /** Controls visibility of the Time & Effort tracking section. */
    @Input() ShowTimeEffort = true;
    /** Optional forwarded template for `#detailTopExtension` (e.g. from TaskPanelComponent). */
    @Input() DetailTopExtensionTemplate: TemplateRef<TaskDetailTopExtensionContext> | null = null;

    @ContentChild('detailTopExtension') public contentDetailTopExtension?: TemplateRef<TaskDetailTopExtensionContext>;

    public get EffectiveDetailTopExtensionTemplate(): TemplateRef<TaskDetailTopExtensionContext> | null {
        return this.contentDetailTopExtension ?? this.DetailTopExtensionTemplate ?? null;
    }

    public get ProviderToUse(): IMetadataProvider {
        return this.Provider ?? Metadata.Provider;
    }

    @Output() OpenRecordRequested = new EventEmitter<string>();
    @Output() EditRequested = new EventEmitter<string>();
    @Output() BeforeCommentPosted = new EventEmitter<BeforeCommentPostedEvent>();
    @Output() AfterCommentPosted = new EventEmitter<void>();
    @Output() TaskMutated = new EventEmitter<string>();
    @Output() Close = new EventEmitter<void>();
    @Output() DeleteRequested = new EventEmitter<string>();

    public taskEntity: mjBizAppsTasksTaskEntity | null = null;
    public draftTitle = '';
    public draftDescription = '';
    public autoSaveState: 'idle' | 'saving' | 'saved' = 'saved';
    public confirmingDelete = false;
    public parentTaskName: string | null = null;
    public assignees: InspectorAssigneeRow[] = [];
    public linkedRecords: TaskWidgetLinkedRecord[] = [];
    public subtasks: ChildSubtaskRow[] = [];
    public organizations: { ID: string; Name: string; LinkedCompanyID: string | null }[] = [];
    public typeStatuses: TaskWidgetTypeStatus[] = [];
    public spotlightData: TaskAdaptiveSpotlightInput | null = null;
    public timeline: ActivityEntry[] = [];
    public pendingSuggestionSummary: TaskPendingSuggestionsSummary | null = null;
    public pendingSuggestionTooltip = '';
    public loading = false;
    public busy = false;
    public showLinkPicker = false;
    public newSubtaskTitle = '';
    public newComment = '';
    public commentError = '';
    public activeStreamTab = 'comments';

    public readonly streamTabs: TabConfig[] = [
        { key: 'comments', label: 'Comments', icon: 'fa-regular fa-comments' },
        { key: 'activity', label: 'Activity', icon: 'fa-solid fa-clock-rotate-left' },
    ];

    private orchestration = new TaskOrchestrationService();
    private cdr = inject(ChangeDetectorRef);

    public get dueDateInput(): string {
        if (!this.taskEntity?.DueAt) return '';
        return new Date(this.taskEntity.DueAt).toISOString().split('T')[0];
    }

    public get completedSubtasksCount(): number {
        return this.subtasks.filter((s) => s.Status === 'Completed').length;
    }

    public get subtasksPercent(): number {
        if (this.subtasks.length === 0) return 0;
        return Math.round((this.completedSubtasksCount / this.subtasks.length) * 100);
    }

    public get filteredTimeline(): ActivityEntry[] {
        if (this.activeStreamTab === 'comments') {
            return this.timeline.filter((e) => e.Type === 'comment');
        }
        return this.timeline.filter((e) => e.Type === 'activity');
    }

    public ngOnChanges(changes: SimpleChanges): void {
        if (changes['TaskID'] && this.TaskID) {
            void this.LoadTask();
        }
    }

    public formatStatus(status: string): string {
        return FormatTaskStatusLabel(status);
    }

    private createRunView(): RunView {
        const p = this.ProviderToUse;
        if (p && typeof (p as Partial<IRunViewProvider>).RunView === 'function') {
            return RunView.FromMetadataProvider(p);
        }
        return new RunView();
    }

    private async loadPeopleByIDs(ids: (string | null | undefined)[]): Promise<Map<string, string>> {
        const validIds = [...new Set(ids.filter((id): id is string => Boolean(id && IsValidUUID(id))))];
        const map = new Map<string, string>();
        if (validIds.length === 0) return map;

        const rv = this.createRunView();
        const res = await rv.RunView<PersonRow>({
            EntityName: 'MJ_BizApps_Common: People',
            ExtraFilter: `ID IN (${validIds.map((id) => `'${EscapeSQLString(id)}'`).join(',')})`,
            Fields: ['ID', 'FirstName', 'LastName'],
            ResultType: 'simple',
        });
        for (const p of res?.Results ?? []) {
            map.set(p.ID.toLowerCase(), `${p.FirstName} ${p.LastName}`.trim());
        }
        return map;
    }

    public async LoadTask(): Promise<void> {
        if (!this.TaskID) return;
        this.loading = true;
        this.confirmingDelete = false;
        this.pendingSuggestionSummary = null;
        this.pendingSuggestionTooltip = '';
        this.cdr.markForCheck();
        try {
            const p = this.ProviderToUse;
            if (typeof p.GetEntityObject === 'function') {
                const entity = await p.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
                if (entity && typeof entity.InnerLoad === 'function') {
                    await entity.InnerLoad(CompositeKey.FromID(this.TaskID));
                    this.taskEntity = entity;
                    this.draftTitle = entity.Name ?? '';
                    this.draftDescription = entity.Description ?? '';
                    this.autoSaveState = 'saved';
                }
            }

            await Promise.all([
                this.loadAssignees().catch(() => { this.assignees = []; }),
                this.loadTimeline().catch(() => { this.timeline = []; }),
                this.loadParentTask().catch(() => { this.parentTaskName = null; }),
                this.loadLinkedRecords().catch(() => { this.linkedRecords = []; }),
                this.loadSubtasks().catch(() => { this.subtasks = []; }),
                this.loadOrganizations().catch(() => { this.organizations = []; }),
                this.loadTypeAndSpotlight().catch(() => { this.typeStatuses = []; }),
                this.loadPendingSuggestions().catch(() => {
                    this.pendingSuggestionSummary = null;
                    this.pendingSuggestionTooltip = '';
                }),
            ]);
        } finally {
            this.loading = false;
            this.cdr.markForCheck();
        }
    }

    private async loadPendingSuggestions(): Promise<void> {
        if (!this.TaskID) return;
        const res = await TaskFieldSuggestionsHelper.LoadPendingSuggestions(this.ProviderToUse, {
            taskIds: [this.TaskID],
        });
        const summary = res.byTaskId.get(NormalizeUUID(this.TaskID)) ?? null;
        this.pendingSuggestionSummary = summary;
        this.pendingSuggestionTooltip = FormatPendingSuggestionTooltip(summary);
    }

    private async loadTypeAndSpotlight(): Promise<void> {
        if (!this.taskEntity) return;
        const [typeRes, statusesRes, depsRes] = await Promise.all([
            this.createRunView().RunView<{
                ID: string;
                Name: string;
                Code: string;
                IsApproval: boolean;
                OnCompleteAction: string | null;
                OnRejectAction: string | null;
                OnCancelAction: string | null;
            }>({
                EntityName: 'MJ_BizApps_Tasks: Task Types',
                ExtraFilter: `ID = '${EscapeSQLString(this.taskEntity.TypeID)}'`,
                MaxRows: 1,
                ResultType: 'simple',
            }),
            this.createRunView().RunView<TaskWidgetTypeStatus>({
                EntityName: 'MJ_BizApps_Tasks: Task Type Status',
                ExtraFilter: `TaskTypeID = '${EscapeSQLString(this.taskEntity.TypeID)}' AND IsActive = 1`,
                OrderBy: 'Sequence ASC',
                ResultType: 'simple',
            }),
            this.createRunView().RunView<{ DependsOnTask: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Dependencies',
                ExtraFilter: `TaskID = '${EscapeSQLString(this.taskEntity.ID)}'`,
                Fields: ['DependsOnTask'],
                ResultType: 'simple',
            }),
        ]);

        this.typeStatuses = statusesRes?.Results ?? [];
        const tt = typeRes?.Results?.[0];
        const archetype = ResolveTaskUiArchetype(
            tt ? { Code: tt.Code, Name: tt.Name, IsApproval: tt.IsApproval } : null,
            { TargetValue: this.taskEntity.TargetValue, HealthStatus: this.taskEntity.HealthStatus },
        );

        this.spotlightData = {
            TaskID: this.taskEntity.ID,
            TaskName: this.taskEntity.Name,
            Archetype: archetype,
            Status: this.taskEntity.Status,
            DueAt: this.taskEntity.DueAt,
            PercentComplete: this.taskEntity.PercentComplete ?? 0,
            HoursEstimated: this.taskEntity.HoursEstimated,
            HoursActual: this.taskEntity.HoursActual,
            BlockedReason: this.taskEntity.BlockedReason,
            BlockingDependencyNames: (depsRes?.Results ?? []).map((d) => d.DependsOnTask),
            PredictedSLARiskBand: this.taskEntity.PredictedSLARiskBand,
            PredictedSLABreachProbability: this.taskEntity.PredictedSLABreachProbability,
            OkrSnapshot:
                archetype === 'key-result'
                    ? {
                          TaskID: this.taskEntity.ID,
                          BaselineValue: this.taskEntity.BaselineValue,
                          TargetValue: this.taskEntity.TargetValue,
                          CurrentValue: this.taskEntity.CurrentValue,
                          UnitOfMeasure: this.taskEntity.UnitOfMeasure,
                          MetricDirection: this.taskEntity.MetricDirection,
                          PercentComplete: this.taskEntity.PercentComplete ?? 0,
                          HealthStatus: this.taskEntity.HealthStatus,
                          ConfidenceScore: this.taskEntity.ConfidenceScore,
                          PlanningPeriod: this.taskEntity.PlanningPeriod,
                          CheckInCadence: this.taskEntity.CheckInCadence,
                          LastCheckInAt: this.taskEntity.LastCheckInAt,
                          NextCheckInDueAt: this.taskEntity.NextCheckInDueAt,
                      }
                    : null,
            ApprovalTask:
                archetype === 'approval'
                    ? {
                          ID: this.taskEntity.ID,
                          Name: this.taskEntity.Name,
                          Description: this.taskEntity.Description,
                          ParentID: this.taskEntity.ParentID,
                          Status: this.taskEntity.Status,
                          Priority: this.taskEntity.Priority,
                          DueAt: this.taskEntity.DueAt,
                          PercentComplete: this.taskEntity.PercentComplete ?? 0,
                          IsApproval: true,
                          LinkedRecords: this.linkedRecords,
                          OnCompleteActionName: tt?.OnCompleteAction ?? null,
                          OnRejectActionName: tt?.OnRejectAction ?? null,
                          OnCancelActionName: tt?.OnCancelAction ?? null,
                      }
                    : null,
        };
    }

    private async loadParentTask(): Promise<void> {
        this.parentTaskName = this.taskEntity?.Parent ?? null;
    }

    private async loadLinkedRecords(): Promise<void> {
        if (!this.TaskID) {
            this.linkedRecords = [];
            return;
        }
        try {
            const byTask = await LoadTaskRecordLinks([this.TaskID]);
            const links = byTask.get(this.TaskID.toLowerCase()) ?? [];
            this.linkedRecords = links.map((l) => ({
                EntityName: l.EntityName,
                RecordID: l.RecordID,
                DisplayName: l.Name,
                IconClass: this.ProviderToUse.EntityByName(l.EntityName)?.Icon || 'fa-solid fa-link',
            }));
        } catch {
            this.linkedRecords = [];
        }
    }

    private async loadSubtasks(): Promise<void> {
        if (!this.TaskID) return;
        const res = await this.createRunView().RunView<ChildSubtaskRow>({
            EntityName: 'MJ_BizApps_Tasks: Tasks',
            ExtraFilter: `ParentID = '${EscapeSQLString(this.TaskID)}' AND Status <> 'Cancelled'`,
            Fields: ['ID', 'Name', 'Status', 'Priority', 'PercentComplete'],
            OrderBy: 'Sequence ASC',
            ResultType: 'simple',
        });
        this.subtasks = res?.Results ?? [];
    }

    private async loadAssignees(): Promise<void> {
        if (!this.TaskID || !IsValidUUID(this.TaskID)) return;
        const rv = this.createRunView();
        const [assignmentResult, rolesResult] = await Promise.all([
            rv.RunView<{
                ID: string;
                AssigneeEntityID: string;
                AssigneeRecordID: string;
                RoleID: string | null;
                Status: TaskAssignmentStatusValue;
            }>({
                EntityName: 'MJ_BizApps_Tasks: Task Assignments',
                ExtraFilter: `TaskID = '${EscapeSQLString(this.TaskID)}'`,
                ResultType: 'simple',
            }),
            this.createRunView().RunView<{ ID: string; Name: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Roles',
                ResultType: 'simple',
            }),
        ]);

        const rows = assignmentResult?.Results ?? [];
        const peopleEntityID = this.ProviderToUse.EntityByName('MJ_BizApps_Common: People')?.ID;
        const personIDs = rows
            .filter((a) => !peopleEntityID || UUIDsEqual(a.AssigneeEntityID, peopleEntityID))
            .map((a) => a.AssigneeRecordID);
        const personMap = await this.loadPeopleByIDs(personIDs);

        const roleMap = new Map<string, string>();
        for (const r of rolesResult?.Results ?? []) {
            roleMap.set(r.ID.toLowerCase(), r.Name);
        }

        this.assignees = rows.map((a) => {
            const entity = this.ProviderToUse.EntityByID?.(a.AssigneeEntityID);
            return {
                AssignmentID: a.ID,
                AssigneeEntityName: entity?.Name || 'MJ_BizApps_Common: People',
                AssigneeRecordID: a.AssigneeRecordID,
                DisplayName:
                    personMap.get(a.AssigneeRecordID.toLowerCase()) ??
                    RoleAssigneeName(a.AssigneeEntityID, a.AssigneeRecordID) ??
                    a.AssigneeRecordID,
                RoleName: a.RoleID ? (roleMap.get(a.RoleID.toLowerCase()) ?? '') : '',
                Status: a.Status ?? 'Pending',
            };
        });
    }

    private async loadTimeline(): Promise<void> {
        if (!this.TaskID || !IsValidUUID(this.TaskID)) return;
        const rv = this.createRunView();
        const [activities, comments] = await Promise.all([
            rv.RunView<{ __mj_CreatedAt: Date; PersonID: string | null; ActivityType: string; Description: string | null }>({
                EntityName: 'MJ_BizApps_Tasks: Task Activities',
                ExtraFilter: `TaskID = '${EscapeSQLString(this.TaskID)}'`,
                OrderBy: '__mj_CreatedAt DESC',
                ResultType: 'simple',
            }),
            this.createRunView().RunView<{ __mj_CreatedAt: Date; PersonID: string; Content: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Comments',
                ExtraFilter: `TaskID = '${EscapeSQLString(this.TaskID)}'`,
                OrderBy: '__mj_CreatedAt DESC',
                ResultType: 'simple',
            }),
        ]);

        const activityRows = activities?.Results ?? [];
        const commentRows = comments?.Results ?? [];
        const personMap = await this.loadPeopleByIDs([
            ...activityRows.map((a) => a.PersonID),
            ...commentRows.map((c) => c.PersonID),
        ]);

        const entries: ActivityEntry[] = [];
        for (const a of activityRows) {
            entries.push({
                Type: 'activity',
                Timestamp: new Date(a.__mj_CreatedAt),
                PersonName: a.PersonID ? personMap.get(a.PersonID.toLowerCase()) : undefined,
                ActivityType: FormatTaskActivityTypeLabel(a.ActivityType),
                Content: a.Description ?? FormatTaskActivityTypeLabel(a.ActivityType),
            });
        }
        for (const c of commentRows) {
            entries.push({
                Type: 'comment',
                Timestamp: new Date(c.__mj_CreatedAt),
                PersonName: c.PersonID ? (personMap.get(c.PersonID.toLowerCase()) ?? c.PersonID) : undefined,
                Content: c.Content,
            });
        }
        this.timeline = entries.sort((a, b) => b.Timestamp.getTime() - a.Timestamp.getTime());
    }

    public async onToggleComplete(nextStatus: TaskStatusValue): Promise<void> {
        if (!this.taskEntity || this.ReadOnly) return;
        this.busy = true;
        this.cdr.markForCheck();
        try {
            this.taskEntity.Status = nextStatus;
            this.taskEntity.PercentComplete = nextStatus === 'Completed' ? 100 : 0;
            if (await this.taskEntity.Save()) {
                this.TaskMutated.emit(this.taskEntity.ID);
                await this.LoadTask();
            }
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async saveInlineTitle(): Promise<void> {
        if (!this.taskEntity || this.ReadOnly) return;
        const clean = this.draftTitle.trim();
        if (!clean || clean === this.taskEntity.Name) {
            this.draftTitle = this.taskEntity.Name;
            return;
        }
        this.busy = true;
        this.autoSaveState = 'saving';
        this.cdr.markForCheck();
        try {
            this.taskEntity.Name = clean;
            if (await this.taskEntity.Save()) {
                this.autoSaveState = 'saved';
                this.TaskMutated.emit(this.taskEntity.ID);
            }
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async saveInlineDescription(): Promise<void> {
        if (!this.taskEntity || this.ReadOnly) return;
        const next = this.draftDescription.trim() || null;
        if (next === (this.taskEntity.Description?.trim() || null)) return;
        this.busy = true;
        this.autoSaveState = 'saving';
        this.cdr.markForCheck();
        try {
            this.taskEntity.Description = next;
            if (await this.taskEntity.Save()) {
                this.autoSaveState = 'saved';
                this.TaskMutated.emit(this.taskEntity.ID);
            }
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async onStageSelected(stage: TaskWidgetTypeStatus): Promise<void> {
        if (!this.taskEntity || this.ReadOnly) return;
        this.busy = true;
        this.cdr.markForCheck();
        try {
            this.taskEntity.TaskTypeStatusID = stage.ID;
            this.taskEntity.Status = stage.MacroStatus;
            if (stage.MacroStatus === 'Completed') {
                this.taskEntity.PercentComplete = 100;
            }
            if (await this.taskEntity.Save()) {
                this.TaskMutated.emit(this.taskEntity.ID);
                await this.LoadTask();
            }
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async updateScalarField(field: 'Status' | 'Priority', value: string): Promise<void> {
        if (!this.taskEntity || this.ReadOnly) return;
        this.busy = true;
        this.cdr.markForCheck();
        try {
            if (field === 'Status') {
                this.taskEntity.Status = value as TaskStatusValue;
                if (value === 'Completed') this.taskEntity.PercentComplete = 100;
            } else {
                this.taskEntity.Priority = value as TaskPriorityValue;
            }
            if (await this.taskEntity.Save()) {
                this.TaskMutated.emit(this.taskEntity.ID);
                await this.LoadTask();
            }
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    private async loadOrganizations(): Promise<void> {
        const res = await this.createRunView().RunView<{ ID: string; Name: string; LinkedCompanyID: string | null }>({
            EntityName: 'MJ_BizApps_Common: Organizations',
            ExtraFilter: "Status = 'Active'",
            Fields: ['ID', 'Name', 'LinkedCompanyID'],
            OrderBy: 'Name ASC',
            ResultType: 'simple',
        });
        this.organizations = [...(res?.Results ?? [])].sort((a, b) => {
            if (Boolean(a.LinkedCompanyID) !== Boolean(b.LinkedCompanyID)) {
                return a.LinkedCompanyID ? -1 : 1;
            }
            return a.Name.localeCompare(b.Name);
        });
    }

    public async updateOrganization(orgId: string | null): Promise<void> {
        if (!this.taskEntity || this.ReadOnly) return;
        this.busy = true;
        this.cdr.markForCheck();
        try {
            this.taskEntity.OrganizationID = orgId || null;
            if (await this.taskEntity.Save()) {
                this.TaskMutated.emit(this.taskEntity.ID);
            }
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async updateDueDate(dateStr: string): Promise<void> {
        if (!this.taskEntity || this.ReadOnly) return;
        this.busy = true;
        this.cdr.markForCheck();
        try {
            this.taskEntity.DueAt = dateStr ? new Date(`${dateStr}T17:00:00`) : null;
            if (await this.taskEntity.Save()) {
                this.TaskMutated.emit(this.taskEntity.ID);
            }
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async cycleAssigneeStatus(row: InspectorAssigneeRow): Promise<void> {
        if (this.ReadOnly || this.busy) return;
        const next: TaskAssignmentStatusValue =
            row.Status === 'Pending' ? 'InProgress' : row.Status === 'InProgress' ? 'Completed' : 'Pending';
        this.busy = true;
        this.cdr.markForCheck();
        try {
            const entity = await this.ProviderToUse.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>('MJ_BizApps_Tasks: Task Assignments');
            await entity.InnerLoad(CompositeKey.FromID(row.AssignmentID));
            entity.Status = next;
            if (await entity.Save()) {
                row.Status = next;
                this.TaskMutated.emit(this.TaskID!);
            }
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async onLinkRecordSelected(rec: TaskWidgetLinkedRecord): Promise<void> {
        this.showLinkPicker = false;
        if (!this.TaskID) return;
        const entity = this.ProviderToUse.EntityByName(rec.EntityName);
        if (!entity) return;

        const link = await this.ProviderToUse.GetEntityObject<mjBizAppsTasksTaskLinkEntity>('MJ_BizApps_Tasks: Task Links');
        link.NewRecord();
        link.TaskID = this.TaskID;
        link.EntityID = entity.ID;
        link.RecordID = rec.RecordID;
        link.Description = rec.DisplayName;
        if (await link.Save()) {
            await this.loadLinkedRecords();
            this.cdr.markForCheck();
        }
    }

    public openLinkedRecord(rec: TaskWidgetLinkedRecord): void {
        SharedService.Instance.OpenEntityRecord(rec.EntityName, CompositeKey.FromID(rec.RecordID));
    }

    public async toggleSubtaskComplete(child: ChildSubtaskRow, nextStatus: TaskStatusValue): Promise<void> {
        this.busy = true;
        this.cdr.markForCheck();
        try {
            const entity = await this.ProviderToUse.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            await entity.InnerLoad(CompositeKey.FromID(child.ID));
            entity.Status = nextStatus;
            entity.PercentComplete = nextStatus === 'Completed' ? 100 : 0;
            if (await entity.Save()) {
                child.Status = nextStatus;
                child.PercentComplete = entity.PercentComplete;
                this.TaskMutated.emit(this.TaskID!);
            }
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async addSubtask(): Promise<void> {
        const title = this.newSubtaskTitle.trim();
        if (!title || !this.taskEntity) return;
        this.busy = true;
        this.cdr.markForCheck();
        try {
            const child = await this.ProviderToUse.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            child.NewRecord();
            child.Name = title;
            child.ParentID = this.taskEntity.ID;
            child.TypeID = this.taskEntity.TypeID;
            child.CategoryID = this.taskEntity.CategoryID;
            child.Status = 'Open';
            child.Priority = this.taskEntity.Priority;
            child.Sequence = (this.subtasks.length + 1) * 10;
            if (await child.Save()) {
                this.newSubtaskTitle = '';
                await this.loadSubtasks();
                this.TaskMutated.emit(this.taskEntity.ID);
            }
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public openSubtask(childID: string): void {
        this.TaskID = childID;
        void this.LoadTask();
    }

    public async onApprovalSubmitted(event: TaskApprovalActionEvent): Promise<void> {
        this.busy = true;
        this.cdr.markForCheck();
        try {
            await this.orchestration.RecordDecision({
                TaskID: event.TaskID,
                OutcomeCode: event.OutcomeCode,
                DecidedByPersonID: this.PersonID ?? undefined,
                Notes: event.Notes ?? undefined,
            });
            this.TaskMutated.emit(event.TaskID);
            await this.LoadTask();
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async onCheckInSubmitted(event: TaskOkrCheckInSubmitEvent): Promise<void> {
        if (!this.taskEntity) return;
        this.busy = true;
        this.cdr.markForCheck();
        try {
            const ci = await this.ProviderToUse.GetEntityObject<mjBizAppsTasksTaskCheckInEntity>('MJ_BizApps_Tasks: Task Check Ins');
            ci.NewRecord();
            ci.TaskID = event.TaskID;
            ci.AuthorPersonID = this.PersonID;
            ci.AuthorUserID = this.ProviderToUse.CurrentUser?.ID ?? null;
            ci.CheckInAt = new Date();
            ci.HealthStatus = event.HealthStatus;
            ci.ConfidenceScore = event.ConfidenceScore;
            ci.PreviousValue = this.taskEntity.CurrentValue;
            ci.NewValue = event.NewValue;
            const computedPct = TaskService.computeQuantitativePercentComplete(
                this.taskEntity.BaselineValue,
                this.taskEntity.TargetValue,
                event.NewValue,
                this.taskEntity.MetricDirection,
            );
            ci.PercentComplete = computedPct ?? this.taskEntity.PercentComplete;
            ci.Summary = event.Summary;
            ci.Blockers = event.Blockers;
            ci.NextSteps = event.NextSteps;
            const saved = await ci.Save();
            if (saved) {
                // Server-side TaskCheckIn save updates the parent Task metrics & check-in timestamps.
                // Reload fresh state rather than double-saving a stale entity instance.
                this.TaskMutated.emit(event.TaskID);
                await this.LoadTask();
            }
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async PostComment(): Promise<void> {
        if (this.ReadOnly || !this.newComment.trim() || !this.TaskID) return;
        const before = new BeforeCommentPostedEvent(this.TaskID, this.newComment.trim());
        this.BeforeCommentPosted.emit(before);
        if (before.Cancel) return;

        const comment = await this.ProviderToUse.GetEntityObject<mjBizAppsTasksTaskCommentEntity>('MJ_BizApps_Tasks: Task Comments');
        comment.NewRecord();
        comment.TaskID = this.TaskID;
        if (this.PersonID) comment.PersonID = this.PersonID;
        comment.Content = this.newComment.trim();
        const saved = await comment.Save();
        if (!saved) {
            this.commentError = comment.LatestResult?.CompleteMessage || 'The comment was refused.';
            this.cdr.markForCheck();
            return;
        }
        this.commentError = '';
        this.newComment = '';
        await this.loadTimeline();
        this.cdr.markForCheck();
        this.AfterCommentPosted.emit();
    }

    public async onDelete(): Promise<void> {
        this.confirmingDelete = false;
        if (!this.TaskID || !IsValidUUID(this.TaskID)) return;
        const entity = await this.ProviderToUse.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
        const pk = new CompositeKey([{ FieldName: 'ID', Value: this.TaskID }]);
        const loaded = await entity.InnerLoad(pk);
        if (!loaded) return;

        await Promise.all([
            entity.Assignments.Load(true),
            entity.TagLinks.Load(true),
            entity.Links.Load(true),
            entity.Dependencies.Load(true),
            entity.Comments.Load(true),
            entity.CheckIns.Load(true),
            entity.Activities.Load(true),
            entity.NotificationLogs.Load(true),
            entity.SubTasks.Load(true),
        ]);

        if (entity.SubTasks.Items.length > 0) {
            entity.SubTasks.Clear();
            if (!(await entity.Save())) return;
        }

        const rv = this.createRunView();
        const incomingDeps = await rv.RunView<mjBizAppsTasksTaskDependencyEntity>({
            EntityName: 'MJ_BizApps_Tasks: Task Dependencies',
            ExtraFilter: `DependsOnTaskID = '${EscapeSQLString(this.TaskID)}'`,
            ResultType: 'entity_object',
        });
        for (const dep of incomingDeps?.Results ?? []) {
            if (!UUIDsEqual(dep.TaskID, this.TaskID) && !(await dep.Delete())) return;
        }

        if (await entity.Delete()) {
            this.DeleteRequested.emit(this.TaskID);
        }
    }

    public onOpenFullRecord(): void {
        if (this.TaskID) {
            this.OpenRecordRequested.emit(this.TaskID);
            OpenTaskRecord(this.TaskID);
        }
    }
}
