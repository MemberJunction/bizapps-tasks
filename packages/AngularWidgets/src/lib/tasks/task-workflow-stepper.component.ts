import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { TASKS_WIDGET_TOKENS_CSS } from './task-tokens';
import type { TaskWidgetTypeStatus } from './task-models';

/**
 * Clickable `TaskTypeStatus` workflow stepper (L1 presentational widget).
 *
 * Renders the ordered custom lifecycle stages configured on a TaskType
 * (e.g. `Spec → Build → QA → Shipped`) with past/current/upcoming visual states.
 * Collapses cleanly to nothing when a TaskType has no custom statuses.
 */
@Component({
    selector: 'mjt-workflow-stepper',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        @if (SortedStatuses.length > 0) {
            <div class="mjt-stepper" role="group" [attr.aria-label]="AriaLabel">
                @for (stage of SortedStatuses; track stage.ID; let i = $index) {
                    @if (i > 0) {
                        <i class="fa-solid fa-chevron-right mjt-step-sep" aria-hidden="true"></i>
                    }
                    <button
                        type="button"
                        class="mjt-step-btn"
                        [class.is-past]="i < CurrentIndex"
                        [class.is-now]="i === CurrentIndex"
                        [disabled]="ReadOnly"
                        [attr.aria-current]="i === CurrentIndex ? 'step' : null"
                        (click)="onSelect(stage)">
                        @if (i < CurrentIndex) {
                            <i class="fa-solid fa-check mjt-step-ic" aria-hidden="true"></i>
                        } @else if (stage.IconClass) {
                            <i [class]="stage.IconClass + ' mjt-step-ic'" aria-hidden="true"></i>
                        } @else {
                            <span
                                class="mjt-step-dot"
                                [style.background]="i === CurrentIndex ? 'currentColor' : (stage.Color || 'var(--mj-border-strong)')">
                            </span>
                        }
                        <span>{{ stage.Name }}</span>
                    </button>
                }
            </div>
        }
    `,
    styles: [
        TASKS_WIDGET_TOKENS_CSS,
        `
        .mjt-stepper {
            display: flex;
            align-items: center;
            gap: 4px;
            flex-wrap: wrap;
        }
        .mjt-step-sep {
            font-size: 9px;
            color: var(--mj-text-disabled);
        }
        .mjt-step-btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            min-height: 28px;
            border-radius: var(--mj-radius-full, 9999px);
            font-family: inherit;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-muted);
            cursor: pointer;
            transition: background 140ms ease, color 140ms ease, border-color 140ms ease;
        }
        .mjt-step-btn:hover:not(:disabled):not(.is-now) {
            border-color: var(--mj-brand-primary);
            color: var(--mj-text-primary);
            background: var(--mj-bg-surface-hover);
        }
        .mjt-step-btn:focus-visible {
            outline: 2px solid var(--mj-border-focus, var(--mj-brand-primary));
            outline-offset: 2px;
        }
        .mjt-step-btn.is-past {
            background: var(--mj-status-success-bg);
            border-color: transparent;
            color: var(--mj-status-success-text);
        }
        .mjt-step-btn.is-now {
            background: var(--mj-brand-primary);
            border-color: var(--mj-brand-primary);
            color: var(--mj-brand-on-primary, #ffffff);
        }
        .mjt-step-btn:disabled {
            cursor: default;
            opacity: 0.7;
        }
        .mjt-step-ic {
            font-size: 10px;
        }
        .mjt-step-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            flex-shrink: 0;
        }
        @media (pointer: coarse), (max-width: 640px) {
            .mjt-step-btn {
                min-height: 36px;
                padding: 6px 12px;
            }
        }
        `,
    ],
})
export class TaskWorkflowStepperComponent {
    @Input() Statuses: readonly TaskWidgetTypeStatus[] = [];
    @Input() ActiveStatusID: string | null = null;
    @Input() ReadOnly = false;
    @Input() AriaLabel = 'Task workflow stages';

    @Output() StageSelected = new EventEmitter<TaskWidgetTypeStatus>();

    public get SortedStatuses(): TaskWidgetTypeStatus[] {
        return [...this.Statuses].sort((a, b) => a.Sequence - b.Sequence);
    }

    public get CurrentIndex(): number {
        if (!this.ActiveStatusID) return -1;
        const target = this.ActiveStatusID.toLowerCase();
        return this.SortedStatuses.findIndex((s) => s.ID.toLowerCase() === target);
    }

    public onSelect(stage: TaskWidgetTypeStatus): void {
        if (this.ReadOnly) return;
        this.StageSelected.emit(stage);
    }
}
