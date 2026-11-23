import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RegisterClassEx } from '@memberjunction/global';
import { BaseFormPanel, BaseFormsModule } from '@memberjunction/ng-base-forms';
import {
    ParseTaskRiskItems,
    TASK_RISK_ASSESSMENT_ENTITY,
    type TaskRiskHealthStatus,
    type TaskRiskItem,
    type TaskRiskSeverity,
    type mjBizAppsTasksTaskRiskAssessmentEntity,
} from '@mj-biz-apps/tasks-entities';

/**
 * Form panel contributing a structured Risk Assessment Summary and typed Risks breakdown
 * into the `MJ_BizApps_Tasks: Task Risk Assessments` form (`slot: 'before-fields'`).
 *
 * Uses strictly semantic `--mj-*` CSS design tokens, `ChangeDetectionStrategy.OnPush`,
 * and strongly typed entity property accessors (zero `.Get()`/`.Set()`).
 */
@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:TaskRiskAssessments:risks',
    metadata: {
        entity: TASK_RISK_ASSESSMENT_ENTITY,
        slot: 'before-fields',
        sortKey: 100,
        contributionKey: 'risks',
    },
})
@Component({
    selector: 'mjt-task-risk-assessment-panel',
    standalone: true,
    imports: [CommonModule, BaseFormsModule],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <section class="mjt-risk-panel" aria-label="Task Risk Assessment Summary">
            <header class="mjt-risk-panel__header">
                <div class="mjt-risk-panel__title-group">
                    <i class="fa-solid fa-shield-halved mjt-risk-panel__icon" aria-hidden="true"></i>
                    <h2 class="mjt-risk-panel__title">Risk &amp; Forecast Summary</h2>
                </div>
                <span class="mjt-health-badge" [attr.data-health]="HealthStatus">
                    {{ HealthStatusLabel }}
                </span>
            </header>

            <div class="mjt-risk-panel__metrics">
                <div class="mjt-metric-card">
                    <span class="mjt-metric-card__label">Forecast Completion</span>
                    <strong class="mjt-metric-card__value">{{ ForecastDateLabel }}</strong>
                </div>
                <div class="mjt-metric-card">
                    <span class="mjt-metric-card__label">Forecast Confidence</span>
                    <strong class="mjt-metric-card__value">{{ ConfidenceLabel }}</strong>
                </div>
                <div class="mjt-metric-card">
                    <span class="mjt-metric-card__label">ML Breach Probability</span>
                    <strong class="mjt-metric-card__value">{{ BreachProbabilityLabel }}</strong>
                </div>
                <div class="mjt-metric-card">
                    <span class="mjt-metric-card__label">AI Run Cost</span>
                    <strong class="mjt-metric-card__value">{{ CostLabel }}</strong>
                </div>
            </div>

            <div class="mjt-risk-panel__list">
                <div class="mjt-risk-panel__list-header">
                    <h3 class="mjt-risk-panel__subtitle">Identified Risks ({{ ParsedRisks.length }})</h3>
                    @if (TokensLabel) {
                        <span class="mjt-risk-panel__tokens">{{ TokensLabel }}</span>
                    }
                </div>

                @if (ParsedRisks.length === 0) {
                    <p class="mjt-risk-panel__empty">
                        No structured risk items recorded for this assessment.
                    </p>
                } @else {
                    <ul class="mjt-risk-items">
                        @for (risk of ParsedRisks; track risk.kind + '-' + $index) {
                            <li class="mjt-risk-item">
                                <div class="mjt-risk-item__top">
                                    <span class="mjt-risk-item__kind">{{ risk.kind }}</span>
                                    <span class="mjt-severity-pill" [attr.data-severity]="risk.severity">
                                        {{ SeverityLabel(risk.severity) }}
                                    </span>
                                </div>
                                <p class="mjt-risk-item__mitigation">{{ risk.suggestedMitigation }}</p>
                                @if (risk.evidenceLinks.length > 0) {
                                    <div class="mjt-risk-item__evidence">
                                        @for (link of risk.evidenceLinks; track link) {
                                            <span class="mjt-evidence-chip">{{ link }}</span>
                                        }
                                    </div>
                                }
                            </li>
                        }
                    </ul>
                }
            </div>
        </section>
    `,
    styles: [`
        :host {
            display: block;
            margin-bottom: var(--mj-space-4);
        }

        .mjt-risk-panel {
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-lg);
            padding: var(--mj-space-4);
            display: flex;
            flex-direction: column;
            gap: var(--mj-space-3);
            color: var(--mj-text-primary);
            font-family: var(--mj-font-family);
        }

        .mjt-risk-panel__header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: var(--mj-space-3);
        }

        .mjt-risk-panel__title-group {
            display: flex;
            align-items: center;
            gap: var(--mj-space-2);
        }

        .mjt-risk-panel__icon {
            color: var(--mj-brand-primary);
            font-size: var(--mj-text-base);
        }

        .mjt-risk-panel__title {
            margin: 0;
            font-size: var(--mj-text-base);
            font-weight: var(--mj-font-semibold);
            color: var(--mj-text-primary);
        }

        .mjt-health-badge {
            display: inline-flex;
            align-items: center;
            padding: 2px 10px;
            border-radius: var(--mj-radius-full);
            font-size: var(--mj-text-xs);
            font-weight: var(--mj-font-semibold);
            background: var(--mj-status-info-bg);
            color: var(--mj-status-info-text);
            border: 1px solid var(--mj-border-subtle);
        }

        .mjt-health-badge[data-health="OnTrack"],
        .mjt-health-badge[data-health="Completed"] {
            background: var(--mj-status-success-bg);
            color: var(--mj-status-success-text);
        }

        .mjt-health-badge[data-health="AtRisk"] {
            background: var(--mj-status-warning-bg);
            color: var(--mj-status-warning-text);
        }

        .mjt-health-badge[data-health="OffTrack"] {
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
        }

        .mjt-risk-panel__metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: var(--mj-space-2);
        }

        .mjt-metric-card {
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-subtle);
            border-radius: var(--mj-radius-md);
            padding: var(--mj-space-2) var(--mj-space-3);
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .mjt-metric-card__label {
            font-size: var(--mj-text-xs);
            color: var(--mj-text-muted);
        }

        .mjt-metric-card__value {
            font-size: var(--mj-text-sm);
            font-weight: var(--mj-font-semibold);
            color: var(--mj-text-primary);
        }

        .mjt-risk-panel__list {
            display: flex;
            flex-direction: column;
            gap: var(--mj-space-2);
            border-top: 1px solid var(--mj-border-subtle);
            padding-top: var(--mj-space-3);
        }

        .mjt-risk-panel__list-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: var(--mj-space-2);
        }

        .mjt-risk-panel__subtitle {
            margin: 0;
            font-size: var(--mj-text-sm);
            font-weight: var(--mj-font-semibold);
            color: var(--mj-text-secondary);
        }

        .mjt-risk-panel__tokens {
            font-size: var(--mj-text-xs);
            color: var(--mj-text-muted);
            font-family: var(--mj-font-family-mono);
        }

        .mjt-risk-panel__empty {
            margin: 0;
            font-size: var(--mj-text-sm);
            color: var(--mj-text-muted);
        }

        .mjt-risk-items {
            list-style: none;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            gap: var(--mj-space-2);
        }

        .mjt-risk-item {
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md);
            padding: var(--mj-space-3);
            display: flex;
            flex-direction: column;
            gap: var(--mj-space-1);
        }

        .mjt-risk-item__top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: var(--mj-space-2);
        }

        .mjt-risk-item__kind {
            font-size: var(--mj-text-sm);
            font-weight: var(--mj-font-semibold);
            color: var(--mj-text-primary);
        }

        .mjt-severity-pill {
            font-size: var(--mj-text-xs);
            font-weight: var(--mj-font-semibold);
            padding: 2px 8px;
            border-radius: var(--mj-radius-full);
            background: var(--mj-status-info-bg);
            color: var(--mj-status-info-text);
            text-transform: uppercase;
        }

        .mjt-severity-pill[data-severity="high"],
        .mjt-severity-pill[data-severity="critical"] {
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
        }

        .mjt-severity-pill[data-severity="medium"] {
            background: var(--mj-status-warning-bg);
            color: var(--mj-status-warning-text);
        }

        .mjt-risk-item__mitigation {
            margin: 0;
            font-size: var(--mj-text-sm);
            color: var(--mj-text-secondary);
            line-height: 1.45;
        }

        .mjt-risk-item__evidence {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-top: 2px;
        }

        .mjt-evidence-chip {
            font-size: var(--mj-text-xs);
            font-family: var(--mj-font-family-mono);
            padding: 2px 7px;
            border-radius: var(--mj-radius-sm);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-link);
        }
    `],
})
export class TaskRiskAssessmentRisksPanel extends BaseFormPanel<mjBizAppsTasksTaskRiskAssessmentEntity> {
    public get HealthStatus(): TaskRiskHealthStatus {
        return this.Record?.HealthStatus ?? 'OnTrack';
    }

    public get HealthStatusLabel(): string {
        switch (this.HealthStatus) {
            case 'AtRisk':
                return 'At Risk';
            case 'OffTrack':
                return 'Off Track';
            case 'Completed':
                return 'Completed';
            case 'Paused':
                return 'Paused';
            default:
                return 'On Track';
        }
    }

    public get ForecastDateLabel(): string {
        const dt = this.Record?.ForecastCompletionDate;
        if (!dt) {
            return 'Not forecasted';
        }
        const parsed = dt instanceof Date ? dt : new Date(dt);
        return Number.isNaN(parsed.getTime()) ? 'Not forecasted' : parsed.toISOString().slice(0, 10);
    }

    public get ConfidenceLabel(): string {
        const score = this.Record?.ForecastConfidence;
        return score == null ? '—' : `${Math.round(score)}%`;
    }

    public get BreachProbabilityLabel(): string {
        const prob = this.Record?.MLBreachProbability;
        return prob == null ? '—' : `${(prob * 100).toFixed(1)}%`;
    }

    public get CostLabel(): string {
        const cost = this.Record?.TotalCostUSD;
        return cost == null ? '—' : `$${cost.toFixed(4)}`;
    }

    public get TokensLabel(): string | null {
        const prompt = this.Record?.PromptTokens;
        const completion = this.Record?.CompletionTokens;
        if (prompt == null && completion == null) {
            return null;
        }
        return `${prompt ?? 0} in / ${completion ?? 0} out tokens`;
    }

    public get ParsedRisks(): TaskRiskItem[] {
        return ParseTaskRiskItems(this.Record?.Risks);
    }

    public SeverityLabel(severity: TaskRiskSeverity): string {
        return severity.toUpperCase();
    }
}
