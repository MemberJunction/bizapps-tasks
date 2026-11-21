import { ChangeDetectionStrategy, Component, EventEmitter, Input, OnChanges, Output } from '@angular/core';
import { DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MJButtonDirective, MJProgressBarComponent } from '@memberjunction/ng-ui-components';
import { TASKS_WIDGET_TOKENS_CSS } from './task-tokens';
import type {
    TaskCheckInHealthValue,
    TaskOkrCheckInSubmitEvent,
    TaskOkrMetricSnapshot,
} from './task-models';

/**
 * OKR / Key Result Metric & Inline Check-In Widget (L1 presentational widget).
 *
 * Uses MJ's `<mj-progress-bar>` and `mjButton` directive with official `--mj-*`
 * semantic tokens. Emits `CheckInSubmitted` for the host to persist a
 * `MJ_BizApps_Tasks: Task Check Ins` record and update the Task's current metric.
 */
@Component({
    selector: 'mjt-okr-checkin',
    standalone: true,
    imports: [DatePipe, FormsModule, MJButtonDirective, MJProgressBarComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <section class="mjt-okr-card" aria-label="Key Result progress">
            <div class="mjt-okr-head">
                <div class="mjt-okr-title-group">
                    <span class="mjt-pill mjt-pill--brand">
                        <i class="fa-solid fa-bullseye" aria-hidden="true"></i> Key Result
                    </span>
                    @if (Snapshot.PlanningPeriod) {
                        <span class="mjt-pill mjt-pill--neutral">{{ Snapshot.PlanningPeriod }}</span>
                    }
                    @if (Snapshot.HealthStatus) {
                        <span class="mjt-pill" [class]="healthPillClass(Snapshot.HealthStatus)">
                            {{ formatHealth(Snapshot.HealthStatus) }}
                        </span>
                    }
                    @if (Snapshot.ConfidenceScore != null) {
                        <span class="mjt-pill mjt-pill--neutral mjt-mono">
                            {{ Snapshot.ConfidenceScore }}% confidence
                        </span>
                    }
                </div>

                @if (!ReadOnly) {
                    <button
                        type="button"
                        mjButton
                        variant="outline"
                        size="sm"
                        (click)="ToggleComposer()">
                        <i class="fa-solid" [class.fa-plus]="!ComposerOpen" [class.fa-chevron-up]="ComposerOpen" aria-hidden="true"></i>
                        <span>{{ ComposerOpen ? 'Close Check-In' : 'Log Check-In' }}</span>
                    </button>
                }
            </div>

            <div class="mjt-okr-metrics">
                <div class="mjt-okr-numbers">
                    <span class="mjt-okr-current mjt-mono">{{ formatMetric(Snapshot.CurrentValue) }}</span>
                    <span class="mjt-okr-target">
                        {{ targetSummary }}
                    </span>
                    <span class="mjt-okr-pct mjt-mono">{{ Snapshot.PercentComplete }}%</span>
                </div>
                <mj-progress-bar [Value]="Snapshot.PercentComplete"></mj-progress-bar>
                <div class="mjt-okr-foot">
                    @if (Snapshot.CheckInCadence && Snapshot.CheckInCadence !== 'None') {
                        <span>Cadence: <strong>{{ Snapshot.CheckInCadence }}</strong></span>
                    }
                    @if (Snapshot.LastCheckInAt) {
                        <span>Last check-in: {{ Snapshot.LastCheckInAt | date:'MMM d, y' }}</span>
                    }
                    @if (Snapshot.NextCheckInDueAt) {
                        <span>Next due: {{ Snapshot.NextCheckInDueAt | date:'MMM d, y' }}</span>
                    }
                </div>
            </div>

            @if (ComposerOpen && !ReadOnly) {
                <div class="mjt-okr-composer">
                    <div class="mjt-okr-grid">
                        <div class="mjt-okr-field">
                            <label [attr.for]="'mjt-okr-val-' + Snapshot.TaskID">Current metric {{ Snapshot.UnitOfMeasure ? '(' + Snapshot.UnitOfMeasure + ')' : '' }}</label>
                            <input
                                [id]="'mjt-okr-val-' + Snapshot.TaskID"
                                type="number"
                                step="any"
                                class="mjt-field-input"
                                [(ngModel)]="DraftValue"
                                [disabled]="Busy" />
                        </div>
                        <div class="mjt-okr-field">
                            <label [attr.for]="'mjt-okr-health-' + Snapshot.TaskID">Health status</label>
                            <select [id]="'mjt-okr-health-' + Snapshot.TaskID" class="mjt-field-select" [(ngModel)]="DraftHealth" [disabled]="Busy">
                                <option value="OnTrack">On Track</option>
                                <option value="AtRisk">At Risk</option>
                                <option value="OffTrack">Off Track</option>
                                <option value="Paused">Paused</option>
                                <option value="Completed">Completed</option>
                            </select>
                        </div>
                        <div class="mjt-okr-field">
                            <label [attr.for]="'mjt-okr-conf-' + Snapshot.TaskID">Confidence (0–100%)</label>
                            <input
                                [id]="'mjt-okr-conf-' + Snapshot.TaskID"
                                type="number"
                                min="0"
                                max="100"
                                class="mjt-field-input"
                                [(ngModel)]="DraftConfidence"
                                [disabled]="Busy" />
                        </div>
                    </div>
                    <div class="mjt-okr-field">
                        <label [attr.for]="'mjt-okr-sum-' + Snapshot.TaskID">Check-in summary *</label>
                        <textarea
                            [id]="'mjt-okr-sum-' + Snapshot.TaskID"
                            rows="2"
                            class="mjt-field-textarea"
                            [(ngModel)]="DraftSummary"
                            [disabled]="Busy"
                            placeholder="What moved the metric since the last check-in?"></textarea>
                    </div>
                    <div class="mjt-okr-grid mjt-okr-grid--2">
                        <div class="mjt-okr-field">
                            <label [attr.for]="'mjt-okr-blk-' + Snapshot.TaskID">Blockers (optional)</label>
                            <input [id]="'mjt-okr-blk-' + Snapshot.TaskID" type="text" class="mjt-field-input" [(ngModel)]="DraftBlockers" [disabled]="Busy" placeholder="Any risks or dependencies..." />
                        </div>
                        <div class="mjt-okr-field">
                            <label [attr.for]="'mjt-okr-nxt-' + Snapshot.TaskID">Next steps (optional)</label>
                            <input [id]="'mjt-okr-nxt-' + Snapshot.TaskID" type="text" class="mjt-field-input" [(ngModel)]="DraftNextSteps" [disabled]="Busy" placeholder="Immediate focus for next period..." />
                        </div>
                    </div>
                    <div class="mjt-okr-actions">
                        <button
                            type="button"
                            mjButton
                            variant="primary"
                            size="sm"
                            [disabled]="Busy || !DraftSummary.trim()"
                            (click)="submit()">
                            <i class="fa-solid fa-check" aria-hidden="true"></i>
                            <span>{{ Busy ? 'Saving...' : 'Save Check-In' }}</span>
                        </button>
                        <button
                            type="button"
                            mjButton
                            variant="flat"
                            size="sm"
                            [disabled]="Busy"
                            (click)="ComposerOpen = false">
                            Cancel
                        </button>
                    </div>
                </div>
            }
        </section>
    `,
    styles: [
        TASKS_WIDGET_TOKENS_CSS,
        `
        .mjt-okr-card {
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            padding: 14px 16px;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .mjt-okr-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            flex-wrap: wrap;
        }
        .mjt-okr-title-group {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
        }
        .mjt-okr-metrics {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .mjt-okr-numbers {
            display: flex;
            align-items: baseline;
            gap: 8px;
            flex-wrap: wrap;
        }
        .mjt-okr-current {
            font-size: var(--mj-text-xl, 20px);
            font-weight: var(--mj-font-bold, 700);
            color: var(--mj-text-primary);
        }
        .mjt-okr-target {
            font-size: var(--mj-text-xs, 12px);
            color: var(--mj-text-secondary);
        }
        .mjt-okr-base {
            color: var(--mj-text-muted);
        }
        .mjt-okr-pct {
            margin-left: auto;
            font-size: var(--mj-text-sm, 14px);
            font-weight: var(--mj-font-bold, 700);
            color: var(--mj-brand-primary);
        }
        .mjt-okr-foot {
            display: flex;
            align-items: center;
            gap: 14px;
            flex-wrap: wrap;
            font-size: 11.5px;
            color: var(--mj-text-muted);
        }
        .mjt-okr-composer {
            padding-top: 12px;
            border-top: 1px dashed var(--mj-border-default);
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .mjt-okr-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 10px;
        }
        .mjt-okr-grid--2 {
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }
        .mjt-okr-field {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .mjt-okr-field label {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-secondary);
        }
        .mjt-okr-actions {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        @media (max-width: 640px) {
            .mjt-okr-grid,
            .mjt-okr-grid--2 {
                grid-template-columns: minmax(0, 1fr);
            }
        }
        `,
    ],
})
export class TaskOkrCheckInComponent implements OnChanges {
    @Input({ required: true }) Snapshot!: TaskOkrMetricSnapshot;
    @Input() Busy = false;
    @Input() ReadOnly = false;

    @Output() CheckInSubmitted = new EventEmitter<TaskOkrCheckInSubmitEvent>();

    public ComposerOpen = false;
    public DraftValue: number | null = null;
    public DraftHealth: TaskCheckInHealthValue = 'OnTrack';
    public DraftConfidence: number | null = 7;
    public DraftSummary = '';
    public DraftBlockers = '';
    public DraftNextSteps = '';

    public ngOnChanges(): void {
        if (!this.ComposerOpen && this.Snapshot) {
            this.DraftValue = this.Snapshot.CurrentValue;
            this.DraftHealth = this.Snapshot.HealthStatus ?? 'OnTrack';
            this.DraftConfidence = this.Snapshot.ConfidenceScore ?? 75;
        }
    }

    public ToggleComposer(): void {
        this.ComposerOpen = !this.ComposerOpen;
        if (this.ComposerOpen && this.Snapshot) {
            this.DraftValue = this.Snapshot.CurrentValue;
            this.DraftHealth = this.Snapshot.HealthStatus ?? 'OnTrack';
            this.DraftConfidence = this.Snapshot.ConfidenceScore ?? 75;
        }
    }

    public get targetSummary(): string {
        const s = this.Snapshot;
        if (!s || s.TargetValue == null) return '';
        const isLower =
            s.MetricDirection === 'Decrease' ||
            (s.BaselineValue != null && s.TargetValue < s.BaselineValue);
        const op = isLower ? '≤' : '≥';
        const parts: string[] = [`Target ${op} ${this.formatMetric(s.TargetValue)}`];
        if (s.BaselineValue != null) {
            parts.push(`from ${this.formatMetric(s.BaselineValue)} baseline`);
        }
        if (s.CurrentValue != null) {
            const diff = isLower ? s.CurrentValue - s.TargetValue : s.TargetValue - s.CurrentValue;
            if (diff > 0) {
                parts.push(`(${this.formatMetric(Number(diff.toFixed(2)))} remaining)`);
            } else {
                parts.push('(Target met)');
            }
        }
        return parts.join(' · ');
    }

    public formatMetric(val: number | null): string {
        if (val == null) return '—';
        const unit = this.Snapshot.UnitOfMeasure?.trim() ?? '';
        if (unit === '%') return `${val}%`;
        if (unit === '$') return `$${val.toLocaleString()}`;
        return unit ? `${val.toLocaleString()} ${unit}` : val.toLocaleString();
    }

    public formatHealth(health: string): string {
        switch (health) {
            case 'OnTrack': return 'On Track';
            case 'AtRisk': return 'At Risk';
            case 'OffTrack': return 'Off Track';
            default: return health;
        }
    }

    public healthPillClass(health: string): string {
        switch (health) {
            case 'OnTrack':
            case 'Completed':
                return 'mjt-pill--success';
            case 'AtRisk':
                return 'mjt-pill--warning';
            case 'OffTrack':
                return 'mjt-pill--error';
            default:
                return 'mjt-pill--neutral';
        }
    }

    public submit(): void {
        if (this.Busy || !this.DraftSummary.trim()) return;
        const clampedConfidence =
            this.DraftConfidence != null ? Math.min(100, Math.max(0, Math.round(Number(this.DraftConfidence)))) : null;
        this.CheckInSubmitted.emit({
            TaskID: this.Snapshot.TaskID,
            NewValue: this.DraftValue != null ? Number(this.DraftValue) : null,
            HealthStatus: this.DraftHealth,
            ConfidenceScore: clampedConfidence,
            Summary: this.DraftSummary.trim(),
            Blockers: this.DraftBlockers.trim() || null,
            NextSteps: this.DraftNextSteps.trim() || null,
        });
        this.DraftSummary = '';
        this.DraftBlockers = '';
        this.DraftNextSteps = '';
        this.ComposerOpen = false;
    }
}
