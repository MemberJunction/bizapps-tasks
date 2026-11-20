import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { TASKS_WIDGET_TOKENS_CSS } from './task-tokens';
import type { TaskBulkActionRequest, TaskPriorityValue, TaskStatusValue } from './task-models';

/**
 * Floating bottom Bulk Action Dock (L1 presentational widget).
 *
 * Summoned cleanly at the bottom edge (`safe-area-inset-bottom` aware) whenever
 * the user checks >= 1 task in a list or tree. Uses MJ brand secondary/navy token
 * surface so bulk actions never push page content down.
 */
@Component({
    selector: 'mjt-bulk-action-dock',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        @if (SelectedCount > 0) {
            <div class="mjt-bulk-dock" role="region" aria-label="Bulk task actions">
                <span class="mjt-dock-count mjt-mono">{{ SelectedCount }} selected</span>
                <span class="mjt-dock-sep" aria-hidden="true"></span>

                <button type="button" class="mjt-dock-btn" [disabled]="Busy" (click)="emitStatus('InProgress')">
                    <i class="fa-solid fa-play" aria-hidden="true"></i> In Progress
                </button>
                <button type="button" class="mjt-dock-btn mjt-dock-btn--success" [disabled]="Busy" (click)="emitStatus('Completed')">
                    <i class="fa-solid fa-check" aria-hidden="true"></i> Complete
                </button>
                <button type="button" class="mjt-dock-btn" [disabled]="Busy" (click)="emitStatus('Blocked')">
                    <i class="fa-solid fa-ban" aria-hidden="true"></i> Blocked
                </button>

                <select
                    class="mjt-dock-select"
                    aria-label="Set bulk priority"
                    [disabled]="Busy"
                    (change)="onPriorityChange($event)">
                    <option value="">Set priority...</option>
                    <option value="Critical">Critical</option>
                    <option value="High">High</option>
                    <option value="Medium">Medium</option>
                    <option value="Low">Low</option>
                </select>

                <button type="button" class="mjt-dock-btn mjt-dock-btn--ghost" [disabled]="Busy" (click)="ActionRequested.emit({ Kind: 'clear' })">
                    <i class="fa-solid fa-xmark" aria-hidden="true"></i> Clear
                </button>
            </div>
        }
    `,
    styles: [
        TASKS_WIDGET_TOKENS_CSS,
        `
        .mjt-bulk-dock {
            position: fixed;
            bottom: max(16px, env(safe-area-inset-bottom, 0px));
            left: 50%;
            transform: translateX(-50%);
            z-index: 80;
            background: var(--mj-brand-secondary, #092340);
            color: var(--mj-brand-on-secondary, #ffffff);
            padding: 8px 14px;
            border-radius: var(--mj-radius-full, 9999px);
            box-shadow: var(--mj-shadow-xl, 0 20px 25px -5px rgba(0, 0, 0, 0.25));
            display: inline-flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            max-width: calc(100vw - 24px);
        }
        .mjt-dock-count {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-bold, 700);
            padding: 0 4px;
            white-space: nowrap;
        }
        .mjt-dock-sep {
            width: 1px;
            height: 16px;
            background: color-mix(in srgb, var(--mj-brand-on-secondary, #ffffff) 25%, transparent);
        }
        .mjt-dock-btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 10px;
            min-height: 28px;
            border-radius: var(--mj-radius-full, 9999px);
            border: 1px solid color-mix(in srgb, var(--mj-brand-on-secondary, #ffffff) 22%, transparent);
            background: color-mix(in srgb, var(--mj-brand-on-secondary, #ffffff) 12%, transparent);
            color: var(--mj-brand-on-secondary, #ffffff);
            font-family: inherit;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            cursor: pointer;
            transition: background 140ms ease;
        }
        .mjt-dock-btn:hover:not(:disabled) {
            background: color-mix(in srgb, var(--mj-brand-on-secondary, #ffffff) 22%, transparent);
        }
        .mjt-dock-btn--success {
            background: var(--mj-status-success);
            border-color: var(--mj-status-success);
        }
        .mjt-dock-btn--ghost {
            background: transparent;
            border-color: transparent;
            opacity: 0.85;
        }
        .mjt-dock-btn--ghost:hover:not(:disabled) {
            opacity: 1;
        }
        .mjt-dock-select {
            padding: 4px 8px;
            min-height: 28px;
            border-radius: var(--mj-radius-full, 9999px);
            border: 1px solid color-mix(in srgb, var(--mj-brand-on-secondary, #ffffff) 26%, transparent);
            background: color-mix(in srgb, var(--mj-brand-on-secondary, #ffffff) 14%, transparent);
            color: var(--mj-brand-on-secondary, #ffffff);
            font-family: inherit;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            cursor: pointer;
        }
        .mjt-dock-select option {
            color: var(--mj-text-primary);
            background: var(--mj-bg-surface);
        }
        `,
    ],
})
export class TaskBulkActionDockComponent {
    @Input() SelectedCount = 0;
    @Input() Busy = false;

    @Output() ActionRequested = new EventEmitter<TaskBulkActionRequest>();

    public emitStatus(status: TaskStatusValue): void {
        this.ActionRequested.emit({ Kind: 'status', Status: status });
    }

    public onPriorityChange(event: Event): void {
        const select = event.target as HTMLSelectElement;
        const val = select.value as TaskPriorityValue | '';
        if (!val) return;
        this.ActionRequested.emit({ Kind: 'priority', Priority: val });
        select.value = '';
    }
}
