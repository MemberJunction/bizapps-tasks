import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { DatePipe } from '@angular/common';
import { MJButtonDirective, MJEmptyStateComponent } from '@memberjunction/ng-ui-components';
import { IsTaskOverdue } from '@mj-biz-apps/tasks-core';
import { TaskCompletionRingComponent } from './task-completion-ring.component';
import { TaskQuickCaptureComponent } from './task-quick-capture.component';
import { TASKS_WIDGET_TOKENS_CSS } from './task-tokens';
import type {
    TaskApprovalActionEvent,
    TaskQuickCaptureSubmitEvent,
    TaskStatusValue,
    TaskWidgetItem,
    TaskWidgetLinkedRecord,
} from './task-models';

/**
 * `<mjt-connected-tasks>` — Drop-in Reusable Connected Tasks Widget (L1/L2).
 *
 * Embeddable inside ANY Angular app, CRM Deal record, Account sidebar, Meeting,
 * Committee, or MJ Explorer dashboard with ZERO Router or Explorer dependencies.
 *
 * Uses native CSS **`@container mjt-connected (max-width: 460px)`** to reflow
 * horizontal desktop rows into stacked touch cards automatically whenever placed
 * inside a narrow sidebar or mobile screen.
 */
@Component({
    selector: 'mjt-connected-tasks',
    standalone: true,
    imports: [
        DatePipe,
        MJButtonDirective,
        MJEmptyStateComponent,
        TaskCompletionRingComponent,
        TaskQuickCaptureComponent,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <section class="mjt-conn-host" [attr.aria-label]="Title">
            @if (ShowHeader) {
                <header class="mjt-conn-head">
                    <div class="mjt-conn-title-group">
                        <i [class]="Icon" class="mjt-conn-icon" aria-hidden="true"></i>
                        <h3 class="mjt-conn-title">{{ Title }}</h3>
                        <span class="mjt-pill mjt-pill--neutral mjt-mono">{{ ActiveCount }} open</span>
                    </div>
                    <div class="mjt-conn-head-actions">
                        @if (ShowCompletedToggle && CompletedCount > 0) {
                            <button
                                type="button"
                                mjButton
                                variant="flat"
                                size="sm"
                                (click)="ShowCompleted = !ShowCompleted">
                                {{ ShowCompleted ? 'Hide completed' : 'Show ' + CompletedCount + ' done' }}
                            </button>
                        }
                        @if (ShowNewButton && !ReadOnly) {
                            <button
                                type="button"
                                mjButton
                                variant="primary"
                                size="sm"
                                (click)="NewTaskRequested.emit()">
                                <i class="fa-solid fa-plus" aria-hidden="true"></i>
                                <span>New</span>
                            </button>
                        }
                    </div>
                </header>
            }

            @if (ShowQuickAdd && !ReadOnly) {
                <mjt-quick-capture
                    [Compact]="true"
                    [Busy]="Busy"
                    [Placeholder]="QuickAddPlaceholder"
                    [LinkedRecord]="ContextRecord"
                    [LockedLinkedRecord]="Boolean(ContextRecord)"
                    (Submitted)="QuickAddSubmitted.emit($event)">
                </mjt-quick-capture>
            }

            @if (Loading) {
                <div class="mjt-conn-loading">Loading tasks...</div>
            } @else if (VisibleTasks.length === 0) {
                <mj-empty-state
                    Icon="fa-regular fa-circle-check"
                    [Title]="EmptyTitle"
                    [Message]="EmptyMessage"
                    Size="compact">
                </mj-empty-state>
            } @else {
                <div class="mjt-conn-list" role="list">
                    @for (task of VisibleTasks; track task.ID) {
                        <div
                            class="mjt-conn-row"
                            role="listitem"
                            [class.is-done]="task.Status === 'Completed'"
                            [class.is-selected]="SelectedTaskID === task.ID"
                            (click)="TaskClicked.emit(task.ID)"
                            (dblclick)="TaskDoubleClicked.emit(task.ID)">
                            <div class="mjt-conn-row-main">
                                <mjt-completion-ring
                                    [Status]="task.Status"
                                    [TaskName]="task.Name"
                                    [Disabled]="ReadOnly"
                                    (Toggled)="StatusToggled.emit({ TaskID: task.ID, NewStatus: $event })">
                                </mjt-completion-ring>

                                <div class="mjt-conn-copy">
                                    <div class="mjt-conn-name-line">
                                        <span class="mjt-conn-name">{{ task.Name }}</span>
                                        @if (task.TaskTypeStatusName) {
                                            <span class="mjt-pill mjt-pill--brand">{{ task.TaskTypeStatusName }}</span>
                                        } @else if (task.IsApproval) {
                                            <span class="mjt-pill mjt-pill--violet">
                                                <i class="fa-solid fa-stamp" aria-hidden="true"></i> Approval
                                            </span>
                                        }
                                    </div>

                                    @if (task.ChildCount && task.ChildCount > 0) {
                                        <span class="mjt-conn-sub mjt-mono">
                                            <i class="fa-solid fa-diagram-project" aria-hidden="true"></i>
                                            {{ task.CompletedChildCount ?? 0 }}/{{ task.ChildCount }} sub-tasks
                                        </span>
                                    }

                                    @if (ShowLinkedRecords && task.LinkedRecords && task.LinkedRecords.length > 0) {
                                        <div class="mjt-conn-links">
                                            @for (rec of task.LinkedRecords; track rec.EntityName + ':' + rec.RecordID) {
                                                <button
                                                    type="button"
                                                    class="mjt-record-chip"
                                                    (click)="onRecordClick($event, rec)">
                                                    <i [class]="rec.IconClass || 'fa-solid fa-link'" aria-hidden="true"></i>
                                                    <span>{{ rec.DisplayName }}</span>
                                                </button>
                                            }
                                        </div>
                                    }
                                </div>
                            </div>

                            <div class="mjt-conn-meta">
                                @if (task.IsApproval && task.Status !== 'Completed' && task.Status !== 'Cancelled' && !ReadOnly) {
                                    <button
                                        type="button"
                                        mjButton
                                        variant="primary"
                                        size="sm"
                                        (click)="onQuickApproval($event, task.ID, 'Approved')">
                                        Approve
                                    </button>
                                    <button
                                        type="button"
                                        mjButton
                                        variant="outline"
                                        size="sm"
                                        (click)="onQuickApproval($event, task.ID, 'Rejected')">
                                        Reject
                                    </button>
                                }

                                @if (task.DueAt) {
                                    <span class="mjt-due" [class.is-overdue]="isOverdue(task)">
                                        <i class="fa-regular fa-calendar" aria-hidden="true"></i>
                                        {{ task.DueAt | date:'MMM d' }}
                                    </span>
                                }

                                <span class="mjt-pill" [class]="priorityPillClass(task.Priority)">
                                    {{ task.Priority }}
                                </span>

                                @if (task.Assignees && task.Assignees.length > 0) {
                                    <span class="mjt-avatar-pill" [title]="task.Assignees[0].DisplayName">
                                        {{ initials(task.Assignees[0].DisplayName) }}
                                    </span>
                                }
                            </div>
                        </div>
                    }
                </div>
            }
        </section>
    `,
    styles: [
        TASKS_WIDGET_TOKENS_CSS,
        `
        .mjt-conn-host {
            container: mjt-connected / inline-size;
            display: flex;
            flex-direction: column;
            gap: 10px;
            width: 100%;
            min-width: 0;
        }
        .mjt-conn-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            flex-wrap: wrap;
        }
        .mjt-conn-title-group {
            display: flex;
            align-items: center;
            gap: 8px;
            min-width: 0;
        }
        .mjt-conn-icon {
            color: var(--mj-brand-primary);
            font-size: 14px;
        }
        .mjt-conn-title {
            margin: 0;
            font-size: var(--mj-text-sm, 14px);
            font-weight: var(--mj-font-bold, 700);
            color: var(--mj-text-primary);
        }
        .mjt-conn-head-actions {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .mjt-conn-loading {
            padding: 20px;
            text-align: center;
            font-size: var(--mj-text-xs, 12px);
            color: var(--mj-text-muted);
        }
        .mjt-conn-list {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .mjt-conn-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding: 10px 12px;
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            cursor: pointer;
            transition: border-color 140ms ease, background 140ms ease;
        }
        .mjt-conn-row:hover {
            border-color: var(--mj-brand-primary);
            background: var(--mj-bg-surface-hover);
        }
        .mjt-conn-row.is-selected {
            border-color: var(--mj-brand-primary);
            background: var(--mj-surface-base-bg-selected, color-mix(in srgb, var(--mj-brand-primary) 8%, var(--mj-bg-surface)));
        }
        .mjt-conn-row.is-done .mjt-conn-name {
            text-decoration: line-through;
            color: var(--mj-text-muted);
        }
        .mjt-conn-row-main {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            flex: 1;
            min-width: 0;
        }
        .mjt-conn-copy {
            display: flex;
            flex-direction: column;
            gap: 4px;
            min-width: 0;
            flex: 1;
        }
        .mjt-conn-name-line {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
        }
        .mjt-conn-name {
            font-size: var(--mj-text-sm, 14px);
            font-weight: var(--mj-font-medium, 500);
            color: var(--mj-text-primary);
            line-height: 1.35;
        }
        .mjt-conn-sub {
            font-size: 11px;
            color: var(--mj-text-muted);
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .mjt-conn-links {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
        }
        .mjt-conn-meta {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            justify-content: flex-end;
            flex-shrink: 0;
        }
        .mjt-due {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: var(--mj-text-xs, 12px);
            color: var(--mj-text-muted);
            white-space: nowrap;
        }
        .mjt-due.is-overdue {
            color: var(--mj-status-error-text);
            font-weight: var(--mj-font-semibold, 600);
        }
        .mjt-avatar-pill {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background: color-mix(in srgb, var(--mj-brand-primary) 14%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
            font-size: 10px;
            font-weight: var(--mj-font-bold, 700);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        /* True Container Query Reflow for sidebars & mobile panels (<= 460px) */
        @container mjt-connected (max-width: 460px) {
            .mjt-conn-head {
                flex-direction: column;
                align-items: flex-start;
            }
            .mjt-conn-row {
                flex-direction: column;
                align-items: stretch;
                gap: 8px;
            }
            .mjt-conn-meta {
                justify-content: flex-start;
                padding-left: 30px;
            }
        }
        `,
    ],
})
export class ConnectedTasksWidgetComponent {
    @Input() Title = 'Connected Tasks';
    @Input() Icon = 'fa-solid fa-list-check';
    @Input() Tasks: readonly TaskWidgetItem[] = [];
    @Input() SelectedTaskID: string | null = null;
    @Input() ContextRecord: TaskWidgetLinkedRecord | null = null;
    @Input() QuickAddPlaceholder = 'Add a task for this record... (e.g. "Follow up tomorrow !high")';
    @Input() EmptyTitle = 'All caught up';
    @Input() EmptyMessage = 'Add a task above to track next steps here.';
    @Input() ShowHeader = true;
    @Input() ShowQuickAdd = true;
    @Input() ShowNewButton = false;
    @Input() ShowCompletedToggle = true;
    @Input() ShowLinkedRecords = true;
    @Input() ShowCompleted = false;
    @Input() Loading = false;
    @Input() Busy = false;
    @Input() ReadOnly = false;

    @Output() TaskClicked = new EventEmitter<string>();
    @Output() TaskDoubleClicked = new EventEmitter<string>();
    @Output() StatusToggled = new EventEmitter<{ TaskID: string; NewStatus: TaskStatusValue }>();
    @Output() QuickAddSubmitted = new EventEmitter<TaskQuickCaptureSubmitEvent>();
    @Output() ApprovalActionRequested = new EventEmitter<TaskApprovalActionEvent>();
    @Output() LinkedRecordClicked = new EventEmitter<TaskWidgetLinkedRecord>();
    @Output() NewTaskRequested = new EventEmitter<void>();

    public readonly Boolean = Boolean;

    public get ActiveCount(): number {
        return this.Tasks.filter((t) => t.Status !== 'Completed' && t.Status !== 'Cancelled').length;
    }

    public get CompletedCount(): number {
        return this.Tasks.filter((t) => t.Status === 'Completed').length;
    }

    public get VisibleTasks(): TaskWidgetItem[] {
        if (this.ShowCompleted) return [...this.Tasks];
        return this.Tasks.filter((t) => t.Status !== 'Completed' && t.Status !== 'Cancelled');
    }

    public isOverdue(task: TaskWidgetItem): boolean {
        return IsTaskOverdue(task.DueAt, task.Status);
    }

    public priorityPillClass(priority: string): string {
        switch (priority) {
            case 'Critical': return 'mjt-pill--error';
            case 'High': return 'mjt-pill--warning';
            case 'Medium': return 'mjt-pill--info';
            default: return 'mjt-pill--neutral';
        }
    }

    public initials(name: string): string {
        const parts = name.trim().split(/\s+/).filter(Boolean);
        if (parts.length === 0) return '?';
        if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
        return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }

    public onRecordClick(event: MouseEvent, record: TaskWidgetLinkedRecord): void {
        event.stopPropagation();
        this.LinkedRecordClicked.emit(record);
    }

    public onQuickApproval(
        event: MouseEvent,
        taskID: string,
        outcomeCode: 'Approved' | 'Rejected',
    ): void {
        event.stopPropagation();
        this.ApprovalActionRequested.emit({
            TaskID: taskID,
            OutcomeCode: outcomeCode,
            Notes: null,
        });
    }
}
