import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import type { TaskWbsSummaryMetrics } from '@mj-biz-apps/tasks-core';
import type { TaskSummaryTile } from './task-models';
import { TASKS_WIDGET_TOKENS_CSS } from './task-tokens';

/**
 * Responsive KPI summary strip for WBS trees and task portfolios (L1/L2 widget).
 *
 * Zero Explorer or Router dependencies — styled exclusively with `--mj-*` semantic tokens.
 * Supports leading/extra host tiles, completion progress bars, blocked-state alerting,
 * and clickable cross-filtering via `(TileClicked)`.
 */
@Component({
    selector: 'mjt-wbs-summary-strip',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        @if (AllTiles.length > 0) {
            <div class="mjt-sum-grid" role="group" aria-label="Task summary metrics">
                @for (tile of AllTiles; track tile.Key) {
                    <button
                        type="button"
                        class="mjt-sum-tile"
                        [class]="'mjt-sum-tile mjt-sum-tile--' + (tile.Tone || 'default')"
                        [class.is-active]="ActiveFilterKey === tile.Key"
                        [class.is-alert]="tile.Alert"
                        [attr.aria-pressed]="ActiveFilterKey === tile.Key"
                        (click)="onTileClick(tile.Key)">
                        <div class="mjt-sum-top">
                            <span class="mjt-sum-label">{{ tile.Label }}</span>
                            @if (tile.Icon) {
                                <span class="mjt-sum-icon" aria-hidden="true">
                                    <i [class]="tile.Icon"></i>
                                </span>
                            }
                        </div>

                        <div class="mjt-sum-val mjt-mono">{{ tile.Value }}</div>

                        @if (tile.ProgressPercent != null) {
                            <div class="mjt-sum-bar" role="progressbar" [attr.aria-valuenow]="tile.ProgressPercent" aria-valuemin="0" aria-valuemax="100">
                                <div class="mjt-sum-bar-fill" [style.width.%]="clampPercent(tile.ProgressPercent)"></div>
                            </div>
                        }

                        @if (tile.Subtext) {
                            <div class="mjt-sum-sub">{{ tile.Subtext }}</div>
                        }
                    </button>
                }
            </div>
        }
    `,
    styles: [
        TASKS_WIDGET_TOKENS_CSS,
        `
        .mjt-sum-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(168px, 1fr));
            gap: 10px;
            width: 100%;
        }
        .mjt-sum-tile {
            display: flex;
            flex-direction: column;
            align-items: stretch;
            gap: 6px;
            padding: 12px 14px;
            border-radius: var(--mj-radius-lg, 10px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            text-align: left;
            font-family: inherit;
            cursor: pointer;
            transition: border-color 140ms ease, background 140ms ease, box-shadow 140ms ease, transform 140ms ease;
        }
        .mjt-sum-tile:hover {
            border-color: var(--mj-brand-primary);
            background: var(--mj-bg-surface-hover);
        }
        .mjt-sum-tile:focus-visible {
            outline: none;
            border-color: var(--mj-border-focus, var(--mj-brand-primary));
            box-shadow: 0 0 0 3px color-mix(in oklab, var(--mj-brand-primary) 18%, transparent);
        }
        .mjt-sum-tile.is-active {
            border-color: var(--mj-brand-primary);
            background: color-mix(in oklab, var(--mj-brand-primary) 8%, var(--mj-bg-surface));
            box-shadow: 0 0 0 1px var(--mj-brand-primary);
        }
        .mjt-sum-tile.is-alert {
            border-color: var(--mj-status-error-border, color-mix(in oklab, var(--mj-status-error) 40%, var(--mj-border-default)));
            background: var(--mj-status-error-bg);
        }
        .mjt-sum-tile.is-alert .mjt-sum-val,
        .mjt-sum-tile.is-alert .mjt-sum-icon {
            color: var(--mj-status-error-text);
        }
        .mjt-sum-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
        }
        .mjt-sum-label {
            font-size: 11.5px;
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }
        .mjt-sum-icon {
            width: 24px;
            height: 24px;
            border-radius: var(--mj-radius-sm, 6px);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-secondary);
            flex-shrink: 0;
        }
        .mjt-sum-tile--info .mjt-sum-icon {
            background: var(--mj-status-info-bg);
            color: var(--mj-status-info-text);
        }
        .mjt-sum-tile--success .mjt-sum-icon {
            background: var(--mj-status-success-bg);
            color: var(--mj-status-success-text);
        }
        .mjt-sum-tile--warning .mjt-sum-icon {
            background: var(--mj-status-warning-bg);
            color: var(--mj-status-warning-text);
        }
        .mjt-sum-tile--error .mjt-sum-icon {
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
        }
        .mjt-sum-val {
            font-size: 22px;
            font-weight: var(--mj-font-bold, 700);
            line-height: 1.15;
            color: var(--mj-text-primary);
        }
        .mjt-sum-bar {
            width: 100%;
            height: 5px;
            border-radius: var(--mj-radius-full, 9999px);
            background: var(--mj-bg-surface-sunken);
            overflow: hidden;
        }
        .mjt-sum-bar-fill {
            height: 100%;
            border-radius: var(--mj-radius-full, 9999px);
            background: var(--mj-status-success);
            transition: width 220ms ease;
        }
        .mjt-sum-sub {
            font-size: 11.5px;
            color: var(--mj-text-muted);
            line-height: 1.3;
        }
        `,
    ],
})
export class TaskWbsSummaryStripComponent {
    @Input() Summary: TaskWbsSummaryMetrics | null = null;
    @Input() LeadingTiles: readonly TaskSummaryTile[] = [];
    @Input() ExtraTiles: readonly TaskSummaryTile[] = [];
    @Input() ActiveFilterKey: string | null = null;

    @Output() TileClicked = new EventEmitter<string>();

    public get SummaryTiles(): TaskSummaryTile[] {
        if (!this.Summary) return [];
        const s = this.Summary;
        return [
            {
                Key: 'all',
                Label: 'Total Tasks',
                Value: s.TotalCount,
                Subtext: `${s.OpenCount} open`,
                Icon: 'fa-solid fa-list-check',
                Tone: 'default',
            },
            {
                Key: 'completed',
                Label: 'Completion',
                Value: `${s.OverallCompletionPercent}%`,
                Subtext: `${s.CompletedCount} of ${s.TotalCount} completed`,
                Icon: 'fa-solid fa-circle-check',
                Tone: 'success',
                ProgressPercent: s.OverallCompletionPercent,
            },
            {
                Key: 'in-progress',
                Label: 'In Progress',
                Value: s.InProgressCount,
                Subtext: s.OverdueCount > 0 ? `${s.OverdueCount} overdue` : 'Active execution',
                Icon: 'fa-solid fa-spinner',
                Tone: 'info',
            },
            {
                Key: 'blocked',
                Label: 'Blocked',
                Value: s.BlockedCount,
                Subtext: s.BlockedCount > 0 ? 'Needs attention' : 'No blockers',
                Icon: 'fa-solid fa-ban',
                Tone: s.BlockedCount > 0 ? 'error' : 'default',
                Alert: s.BlockedCount > 0,
            },
        ];
    }

    public get AllTiles(): TaskSummaryTile[] {
        return [...(this.LeadingTiles ?? []), ...this.SummaryTiles, ...(this.ExtraTiles ?? [])];
    }

    public clampPercent(val: number): number {
        return Math.max(0, Math.min(100, Math.round(val)));
    }

    public onTileClick(key: string): void {
        this.TileClicked.emit(key);
    }
}
