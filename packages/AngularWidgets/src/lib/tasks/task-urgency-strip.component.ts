import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import type { TaskUrgencyCounts } from '@mj-biz-apps/tasks-core';
import { TASKS_WIDGET_TOKENS_CSS } from './task-tokens';
import type { TaskUrgencyFilterKey } from './task-models';

/**
 * Whisper-thin clickable Urgency Strip (L1 presentational widget).
 *
 * Surfaces ONLY non-zero actionable risk counts (`Overdue`, `Blocked`,
 * `Approvals`, `SLA At Risk`). Collapses to zero vertical height when
 * everything is clear — replacing dead KPI tile walls with pure signal.
 */
@Component({
    selector: 'mjt-urgency-strip',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        @if (HasAnySignal) {
            <div class="mjt-urgency-strip" role="group" aria-label="Urgency filters">
                @if (Counts.Overdue > 0) {
                    <button
                        type="button"
                        class="mjt-urg-pill mjt-urg-pill--error"
                        [class.is-active]="ActiveFilter === 'overdue'"
                        (click)="toggle('overdue')">
                        <i class="fa-solid fa-clock" aria-hidden="true"></i>
                        <span>{{ Counts.Overdue }} Overdue</span>
                    </button>
                }
                @if (Counts.Blocked > 0) {
                    <button
                        type="button"
                        class="mjt-urg-pill mjt-urg-pill--warning"
                        [class.is-active]="ActiveFilter === 'blocked'"
                        (click)="toggle('blocked')">
                        <i class="fa-solid fa-ban" aria-hidden="true"></i>
                        <span>{{ Counts.Blocked }} Blocked</span>
                    </button>
                }
                @if (Counts.PendingApprovals > 0) {
                    <button
                        type="button"
                        class="mjt-urg-pill mjt-urg-pill--violet"
                        [class.is-active]="ActiveFilter === 'approvals'"
                        (click)="toggle('approvals')">
                        <i class="fa-solid fa-stamp" aria-hidden="true"></i>
                        <span>{{ Counts.PendingApprovals }} {{ Counts.PendingApprovals === 1 ? 'Approval' : 'Approvals' }}</span>
                    </button>
                }
                @if (Counts.SlaAtRisk > 0) {
                    <button
                        type="button"
                        class="mjt-urg-pill mjt-urg-pill--info"
                        [class.is-active]="ActiveFilter === 'sla'"
                        (click)="toggle('sla')">
                        <i class="fa-solid fa-sparkles" aria-hidden="true"></i>
                        <span>{{ Counts.SlaAtRisk }} SLA Risk</span>
                    </button>
                }
                @if (ActiveFilter) {
                    <button
                        type="button"
                        class="mjt-urg-clear"
                        (click)="FilterChange.emit('')">
                        <i class="fa-solid fa-xmark" aria-hidden="true"></i> Clear filter
                    </button>
                }
            </div>
        }
    `,
    styles: [
        TASKS_WIDGET_TOKENS_CSS,
        `
        .mjt-urgency-strip {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .mjt-urg-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 11px;
            min-height: 28px;
            border-radius: var(--mj-radius-full, 9999px);
            font-family: inherit;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            border: 1px solid transparent;
            cursor: pointer;
            transition: transform 120ms ease, border-color 140ms ease, box-shadow 140ms ease;
        }
        .mjt-urg-pill:hover {
            transform: translateY(-1px);
        }
        .mjt-urg-pill:focus-visible {
            outline: 2px solid var(--mj-border-focus, var(--mj-brand-primary));
            outline-offset: 2px;
        }
        .mjt-urg-pill.is-active {
            box-shadow: 0 0 0 2px var(--mj-brand-primary);
        }
        .mjt-urg-pill--error {
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
            border-color: color-mix(in srgb, var(--mj-status-error) 28%, transparent);
        }
        .mjt-urg-pill--warning {
            background: var(--mj-status-warning-bg);
            color: var(--mj-status-warning-text);
            border-color: color-mix(in srgb, var(--mj-status-warning) 28%, transparent);
        }
        /* Standard MJE brand tokens (no purple) — retained class name for backwards compatibility */
        .mjt-urg-pill--violet {
            background: color-mix(in oklab, var(--mj-brand-primary) 12%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
            border-color: color-mix(in oklab, var(--mj-brand-primary) 28%, transparent);
        }
        .mjt-urg-pill--info {
            background: var(--mj-status-info-bg);
            color: var(--mj-status-info-text);
            border-color: color-mix(in srgb, var(--mj-status-info) 28%, transparent);
        }
        .mjt-urg-clear {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 8px;
            background: transparent;
            border: none;
            color: var(--mj-text-muted);
            font-family: inherit;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-medium, 500);
            cursor: pointer;
        }
        .mjt-urg-clear:hover {
            color: var(--mj-text-primary);
        }
        @media (pointer: coarse), (max-width: 640px) {
            .mjt-urg-pill {
                min-height: 36px;
                padding: 6px 12px;
            }
        }
        `,
    ],
})
export class TaskUrgencyStripComponent {
    @Input() Counts: TaskUrgencyCounts = { Overdue: 0, Blocked: 0, PendingApprovals: 0, SlaAtRisk: 0 };
    @Input() ActiveFilter: TaskUrgencyFilterKey = '';

    @Output() FilterChange = new EventEmitter<TaskUrgencyFilterKey>();

    public get HasAnySignal(): boolean {
        return (
            this.Counts.Overdue > 0 ||
            this.Counts.Blocked > 0 ||
            this.Counts.PendingApprovals > 0 ||
            this.Counts.SlaAtRisk > 0
        );
    }

    public toggle(key: TaskUrgencyFilterKey): void {
        this.FilterChange.emit(this.ActiveFilter === key ? '' : key);
    }
}
