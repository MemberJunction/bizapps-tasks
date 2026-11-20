import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { DatePipe } from '@angular/common';
import { MJProgressBarComponent } from '@memberjunction/ng-ui-components';
import { ShouldShowAdaptiveSpotlight } from '@mj-biz-apps/tasks-core';
import { TaskApprovalCardComponent } from './task-approval-card.component';
import { TaskOkrCheckInComponent } from './task-okr-checkin.component';
import { TASKS_WIDGET_TOKENS_CSS } from './task-tokens';
import type {
    TaskAdaptiveSpotlightInput,
    TaskApprovalActionEvent,
    TaskOkrCheckInSubmitEvent,
    TaskWidgetLinkedRecord,
} from './task-models';

/**
 * Context-Adaptive Task Form Spotlight Strip (L1 presentational widget).
 *
 * Morphs cleanly based on the task's `TaskType` archetype:
 * - **Simple General Task (no blocker / no SLA risk)**: collapses to `0px` (renders nothing!)
 * - **Deliverable**: surfaces truthful Critical-Path Blocker callout + Effort burn (`<mj-progress-bar>`)
 * - **Approval Request**: embeds `<mjt-approval-card>` + TaskType Lifecycle Action Hook badges
 * - **OKR Key Result**: embeds `<mjt-okr-checkin>` live metric bar & inline check-in composer
 * - **Action Item / Follow-up**: surfaces Overdue / Predicted SLA Risk Band callout
 */
@Component({
    selector: 'mjt-adaptive-spotlight',
    standalone: true,
    imports: [DatePipe, MJProgressBarComponent, TaskApprovalCardComponent, TaskOkrCheckInComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        @if (ShouldRender && Data) {
            <div class="mjt-spotlight">
                @switch (Data.Archetype) {
                    @case ('approval') {
                        @if (Data.ApprovalTask) {
                            <mjt-approval-card
                                [Task]="Data.ApprovalTask"
                                [Busy]="Busy"
                                [ReadOnly]="ReadOnly || Data.Status === 'Completed' || Data.Status === 'Cancelled'"
                                (DecisionSubmitted)="ApprovalSubmitted.emit($event)"
                                (LinkedRecordClicked)="LinkedRecordClicked.emit($event)">
                            </mjt-approval-card>
                        }
                    }

                    @case ('key-result') {
                        @if (Data.OkrSnapshot) {
                            <mjt-okr-checkin
                                [Snapshot]="Data.OkrSnapshot"
                                [Busy]="Busy"
                                [ReadOnly]="ReadOnly"
                                (CheckInSubmitted)="CheckInSubmitted.emit($event)">
                            </mjt-okr-checkin>
                        }
                    }

                    @default {
                        <div class="mjt-spot-grid">
                            @if (HasBlocker) {
                                <div class="mjt-spot-card mjt-spot-card--error">
                                    <div class="mjt-spot-head">
                                        <span class="mjt-pill mjt-pill--error">
                                            <i class="fa-solid fa-triangle-exclamation" aria-hidden="true"></i>
                                            {{ Data.Status === 'Blocked' ? 'Blocked' : 'Blocking Dependencies' }}
                                        </span>
                                    </div>
                                    @if (Data.BlockedReason) {
                                        <p class="mjt-spot-copy">{{ Data.BlockedReason }}</p>
                                    }
                                    @if (Data.BlockingDependencyNames.length > 0) {
                                        <p class="mjt-spot-copy">
                                            Waiting on: <strong>{{ Data.BlockingDependencyNames.join(', ') }}</strong>
                                        </p>
                                    }
                                </div>
                            }

                            @if (Data.HoursEstimated != null && Data.HoursEstimated > 0) {
                                <div class="mjt-spot-card">
                                    <div class="mjt-spot-head">
                                        <span class="mjt-spot-title">
                                            <i class="fa-regular fa-clock" aria-hidden="true"></i> Effort Burn
                                        </span>
                                        <span class="mjt-mono mjt-spot-val">
                                            {{ Data.HoursActual ?? 0 }}h / {{ Data.HoursEstimated }}h
                                        </span>
                                    </div>
                                    <mj-progress-bar [Value]="EffortPercent"></mj-progress-bar>
                                </div>
                            }

                            @if (HasSlaOrOverdue) {
                                <div class="mjt-spot-card mjt-spot-card--warn">
                                    <div class="mjt-spot-head">
                                        <span class="mjt-pill mjt-pill--warning">
                                            <i class="fa-solid fa-sparkles" aria-hidden="true"></i>
                                            {{ Data.PredictedSLARiskBand ? Data.PredictedSLARiskBand + ' SLA Risk' : 'Overdue' }}
                                        </span>
                                        @if (Data.PredictedSLABreachProbability != null) {
                                            <span class="mjt-mono mjt-spot-val">
                                                {{ formatProb(Data.PredictedSLABreachProbability) }} breach likelihood
                                            </span>
                                        }
                                    </div>
                                    @if (Data.DueAt) {
                                        <p class="mjt-spot-copy">
                                            Target due date: <strong>{{ Data.DueAt | date:'MMM d, y' }}</strong>
                                        </p>
                                    }
                                </div>
                            }
                        </div>
                    }
                }
            </div>
        }
    `,
    styles: [
        TASKS_WIDGET_TOKENS_CSS,
        `
        .mjt-spotlight {
            margin-bottom: 14px;
        }
        .mjt-spot-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 12px;
        }
        .mjt-spot-card {
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            padding: 12px 14px;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .mjt-spot-card--error {
            border-left: 3px solid var(--mj-status-error);
            background: color-mix(in srgb, var(--mj-status-error-bg) 45%, var(--mj-bg-surface));
        }
        .mjt-spot-card--warn {
            border-left: 3px solid var(--mj-status-warning);
            background: color-mix(in srgb, var(--mj-status-warning-bg) 45%, var(--mj-bg-surface));
        }
        .mjt-spot-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            flex-wrap: wrap;
        }
        .mjt-spot-title {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-secondary);
        }
        .mjt-spot-val {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-bold, 700);
            color: var(--mj-text-primary);
        }
        .mjt-spot-copy {
            margin: 0;
            font-size: var(--mj-text-xs, 12px);
            color: var(--mj-text-secondary);
            line-height: 1.45;
        }
        `,
    ],
})
export class TaskAdaptiveSpotlightComponent {
    @Input() Data: TaskAdaptiveSpotlightInput | null = null;
    @Input() Busy = false;
    @Input() ReadOnly = false;

    @Output() ApprovalSubmitted = new EventEmitter<TaskApprovalActionEvent>();
    @Output() CheckInSubmitted = new EventEmitter<TaskOkrCheckInSubmitEvent>();
    @Output() LinkedRecordClicked = new EventEmitter<TaskWidgetLinkedRecord>();

    public get ShouldRender(): boolean {
        if (!this.Data) return false;
        return ShouldShowAdaptiveSpotlight(
            this.Data.Archetype,
            {
                Status: this.Data.Status,
                DueAt: this.Data.DueAt,
                HoursEstimated: this.Data.HoursEstimated,
                HoursActual: this.Data.HoursActual,
                BlockedReason: this.Data.BlockedReason,
                PredictedSLARiskBand: this.Data.PredictedSLARiskBand,
                PredictedSLABreachProbability: this.Data.PredictedSLABreachProbability,
            },
            this.Data.BlockingDependencyNames.length,
        );
    }

    public get HasBlocker(): boolean {
        if (!this.Data) return false;
        return (
            this.Data.Status === 'Blocked' ||
            Boolean(this.Data.BlockedReason?.trim()) ||
            this.Data.BlockingDependencyNames.length > 0
        );
    }

    public get HasSlaOrOverdue(): boolean {
        if (!this.Data) return false;
        if (this.Data.PredictedSLARiskBand === 'Critical' || this.Data.PredictedSLARiskBand === 'High') {
            return true;
        }
        const active = this.Data.Status !== 'Completed' && this.Data.Status !== 'Cancelled';
        const due = this.Data.DueAt ? new Date(this.Data.DueAt) : null;
        return active && due != null && !Number.isNaN(due.getTime()) && due.getTime() < Date.now();
    }

    public get EffortPercent(): number {
        if (!this.Data || !this.Data.HoursEstimated || this.Data.HoursEstimated <= 0) return 0;
        const actual = this.Data.HoursActual ?? 0;
        return Math.min(100, Math.round((actual / this.Data.HoursEstimated) * 100));
    }

    public formatProb(prob: number): string {
        const pct = prob <= 1 ? Math.round(prob * 100) : Math.round(prob);
        return `${pct}%`;
    }
}
