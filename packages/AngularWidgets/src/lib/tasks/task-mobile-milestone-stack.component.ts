import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { DatePipe } from '@angular/common';
import { MJEmptyStateComponent, MJProgressBarComponent } from '@memberjunction/ng-ui-components';
import { GroupTasksIntoMilestones, type MilestoneBucket } from '@mj-biz-apps/tasks-core';
import { TaskCompletionRingComponent } from './task-completion-ring.component';
import { TASKS_WIDGET_TOKENS_CSS } from './task-tokens';
import type { TaskStatusValue, TaskWidgetItem } from './task-models';

/**
 * Mobile Milestone Stack (L1 presentational widget).
 *
 * Replaces horizontal desktop Gantt charts automatically on phones and narrow
 * containers (`<= 640px`), organizing scheduled tasks into chronological milestone
 * buckets (`Overdue`, `This Week`, `Upcoming`, `Unscheduled`, `Completed`) with
 * zero horizontal page overflow.
 */
@Component({
    selector: 'mjt-mobile-milestone-stack',
    standalone: true,
    imports: [DatePipe, MJEmptyStateComponent, MJProgressBarComponent, TaskCompletionRingComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        @if (Buckets.length === 0) {
            <mj-empty-state
                Icon="fa-solid fa-calendar-check"
                Title="No scheduled milestones"
                Message="Tasks with start or due dates will appear here grouped chronologically.">
            </mj-empty-state>
        } @else {
            <div class="mjt-ms-stack">
                @for (bucket of Buckets; track bucket.Key) {
                    <section class="mjt-ms-group">
                        <header class="mjt-ms-header">
                            <span class="mjt-ms-label" [class.is-overdue]="bucket.Key === 'overdue'">
                                {{ bucket.Label }}
                            </span>
                            <span class="mjt-ms-count mjt-mono">{{ bucket.Tasks.length }}</span>
                        </header>

                        <div class="mjt-ms-list">
                            @for (task of bucket.Tasks; track task.ID) {
                                <article
                                    class="mjt-ms-card"
                                    [class.is-critical]="HighlightCriticalPath && task.IsCriticalPath"
                                    (click)="TaskClicked.emit(task.ID)">
                                    <div class="mjt-ms-row">
                                        <mjt-completion-ring
                                            [Status]="task.Status"
                                            [TaskName]="task.Name"
                                            [Disabled]="ReadOnly"
                                            (Toggled)="StatusToggled.emit({ TaskID: task.ID, NewStatus: $event })">
                                        </mjt-completion-ring>
                                        <div class="mjt-ms-copy">
                                            <div class="mjt-ms-title">{{ task.Name }}</div>
                                            <div class="mjt-ms-meta">
                                                @if (task.StartedAt || task.DueAt) {
                                                    <span class="mjt-mono">
                                                        @if (task.StartedAt) { {{ task.StartedAt | date:'MMM d' }} → }
                                                        {{ task.DueAt ? (task.DueAt | date:'MMM d') : 'No due date' }}
                                                    </span>
                                                }
                                                @if (task.TaskTypeStatusName) {
                                                    <span class="mjt-pill mjt-pill--brand">{{ task.TaskTypeStatusName }}</span>
                                                }
                                                @if (HighlightCriticalPath && task.IsCriticalPath) {
                                                    <span class="mjt-pill mjt-pill--error">
                                                        <i class="fa-solid fa-route" aria-hidden="true"></i> Critical Path
                                                    </span>
                                                }
                                                @if (task.DependencyCount && task.DependencyCount > 0) {
                                                    <span class="mjt-pill mjt-pill--neutral">
                                                        <i class="fa-solid fa-link" aria-hidden="true"></i> {{ task.DependencyCount }}
                                                    </span>
                                                }
                                            </div>
                                        </div>
                                        <span class="mjt-ms-pct mjt-mono">{{ task.PercentComplete }}%</span>
                                    </div>
                                    <mj-progress-bar [Value]="task.PercentComplete"></mj-progress-bar>
                                </article>
                            }
                        </div>
                    </section>
                }
            </div>
        }
    `,
    styles: [
        TASKS_WIDGET_TOKENS_CSS,
        `
        .mjt-ms-stack {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .mjt-ms-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .mjt-ms-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 2px;
        }
        .mjt-ms-label {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-bold, 700);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--mj-text-muted);
        }
        .mjt-ms-label.is-overdue {
            color: var(--mj-status-error-text);
        }
        .mjt-ms-count {
            font-size: 11px;
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-muted);
        }
        .mjt-ms-list {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .mjt-ms-card {
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            padding: 12px;
            display: flex;
            flex-direction: column;
            gap: 8px;
            cursor: pointer;
            transition: border-color 140ms ease, background 140ms ease;
        }
        .mjt-ms-card:hover {
            border-color: var(--mj-brand-primary);
            background: var(--mj-bg-surface-hover);
        }
        .mjt-ms-card.is-critical {
            border-left: 3px solid var(--mj-status-error);
        }
        .mjt-ms-row {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            min-width: 0;
        }
        .mjt-ms-copy {
            flex: 1;
            min-width: 0;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .mjt-ms-title {
            font-size: var(--mj-text-sm, 14px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-primary);
            line-height: 1.3;
        }
        .mjt-ms-meta {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
            font-size: 11.5px;
            color: var(--mj-text-muted);
        }
        .mjt-ms-pct {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-secondary);
            flex-shrink: 0;
        }
        `,
    ],
})
export class TaskMobileMilestoneStackComponent {
    @Input() Tasks: readonly TaskWidgetItem[] = [];
    @Input() HighlightCriticalPath = false;
    @Input() ReadOnly = false;

    @Output() TaskClicked = new EventEmitter<string>();
    @Output() StatusToggled = new EventEmitter<{ TaskID: string; NewStatus: TaskStatusValue }>();

    public get Buckets(): MilestoneBucket<TaskWidgetItem>[] {
        return GroupTasksIntoMilestones(this.Tasks);
    }
}
