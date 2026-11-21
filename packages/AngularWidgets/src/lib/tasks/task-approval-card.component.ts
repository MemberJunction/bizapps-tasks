import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MJButtonDirective } from '@memberjunction/ng-ui-components';
import { TASKS_WIDGET_TOKENS_CSS } from './task-tokens';
import type { TaskApprovalActionEvent, TaskWidgetItem, TaskWidgetLinkedRecord } from './task-models';

/**
 * Inline 1-click Approval Decision Card (L1 presentational widget).
 *
 * Follows MJ button ordering strictly:
 * `[Approve]` (Confirm LEFT) · `[With Conditions]` (expands inline rationale) · `[Reject]` (RIGHT).
 * Renders linked business record chips and TaskType lifecycle action hook badges when configured.
 */
@Component({
    selector: 'mjt-approval-card',
    standalone: true,
    imports: [DatePipe, FormsModule, MJButtonDirective],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <article class="mjt-app-card" [class.is-compact]="Compact">
            <div class="mjt-app-top">
                <div class="mjt-app-main" (click)="TaskClicked.emit(Task.ID)">
                    <div class="mjt-app-title-row">
                        <span class="mjt-pill mjt-pill--brand">
                            <i class="fa-solid fa-stamp" aria-hidden="true"></i> Approval
                        </span>
                        <h4 class="mjt-app-title">{{ Task.Name }}</h4>
                        <span class="mjt-pill" [class]="priorityPillClass(Task.Priority)">{{ Task.Priority }}</span>
                    </div>

                    @if (Task.Description && !Compact) {
                        <p class="mjt-app-desc">{{ Task.Description }}</p>
                    }

                    <div class="mjt-app-meta">
                        @if (Task.DueAt) {
                            <span class="mjt-meta-item">
                                <i class="fa-regular fa-calendar" aria-hidden="true"></i>
                                Due {{ Task.DueAt | date:'MMM d' }}
                            </span>
                        }
                        @if (Task.LinkedRecords && Task.LinkedRecords.length > 0) {
                            @for (rec of Task.LinkedRecords; track rec.EntityName + ':' + rec.RecordID) {
                                <button
                                    type="button"
                                    class="mjt-record-chip"
                                    (click)="onRecordClick($event, rec)">
                                    <i [class]="rec.IconClass || 'fa-solid fa-arrow-up-right-from-square'" aria-hidden="true"></i>
                                    <span>{{ rec.DisplayName }}</span>
                                </button>
                            }
                        }
                        @if (Task.OnCompleteActionName || Task.OnRejectActionName) {
                            <span class="mjt-pill mjt-pill--neutral" title="Automated workflow actions wired to this approval type">
                                <i class="fa-solid fa-bolt" aria-hidden="true"></i>
                                {{ hookSummary }}
                            </span>
                        }
                    </div>
                </div>

                @if (!ReadOnly) {
                    <div class="mjt-app-actions">
                        <button
                            type="button"
                            mjButton
                            variant="primary"
                            size="sm"
                            [disabled]="Busy"
                            (click)="decide('Approved', null)">
                            <i class="fa-solid fa-check" aria-hidden="true"></i>
                            <span>Approve</span>
                        </button>
                        <button
                            type="button"
                            mjButton
                            variant="outline"
                            size="sm"
                            [disabled]="Busy"
                            (click)="toggleConditions()">
                            <i class="fa-solid fa-list-check" aria-hidden="true"></i>
                            <span>Conditions</span>
                        </button>
                        <button
                            type="button"
                            mjButton
                            variant="outline"
                            size="sm"
                            class="mjt-btn-danger-outline"
                            [disabled]="Busy"
                            (click)="decide('Rejected', ConditionNote.trim() || null)">
                            <i class="fa-solid fa-xmark" aria-hidden="true"></i>
                            <span>Reject</span>
                        </button>
                    </div>
                }
            </div>

            @if (ShowConditionComposer && !ReadOnly) {
                <div class="mjt-cond-box">
                    <label class="mjt-cond-label" [attr.for]="'mjt-cond-' + Task.ID">Conditions or rationale</label>
                    <textarea
                        [id]="'mjt-cond-' + Task.ID"
                        rows="2"
                        class="mjt-field-textarea"
                        [(ngModel)]="ConditionNote"
                        [disabled]="Busy"
                        placeholder="State conditions for approval (e.g., Requires CFO counter-signature on multi-year term)..."></textarea>
                    <div class="mjt-cond-actions">
                        <button
                            type="button"
                            mjButton
                            variant="primary"
                            size="sm"
                            [disabled]="Busy || !ConditionNote.trim()"
                            (click)="decide('ApprovedWithConditions', ConditionNote.trim())">
                            <i class="fa-solid fa-check-double" aria-hidden="true"></i>
                            <span>Confirm With Conditions</span>
                        </button>
                        <button
                            type="button"
                            mjButton
                            variant="flat"
                            size="sm"
                            [disabled]="Busy"
                            (click)="ShowConditionComposer = false">
                            Cancel
                        </button>
                    </div>
                </div>
            }
        </article>
    `,
    styles: [
        TASKS_WIDGET_TOKENS_CSS,
        `
        .mjt-app-card {
            background: color-mix(in oklab, var(--mj-brand-primary) 4%, var(--mj-bg-surface));
            border: 1px solid color-mix(in oklab, var(--mj-brand-primary) 26%, var(--mj-border-default));
            border-radius: var(--mj-radius-md, 8px);
            padding: 12px 14px;
            display: flex;
            flex-direction: column;
            gap: 10px;
            transition: border-color 140ms ease, box-shadow 140ms ease;
        }
        .mjt-app-card:hover {
            border-color: color-mix(in oklab, var(--mj-brand-primary) 48%, var(--mj-border-strong));
            box-shadow: var(--mj-shadow-sm, 0 1px 2px rgba(0, 0, 0, 0.05));
        }
        .mjt-app-card.is-compact {
            padding: 10px 12px;
        }
        .mjt-app-top {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
        }
        .mjt-app-main {
            flex: 1 1 260px;
            min-width: 0;
            cursor: pointer;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .mjt-app-title-row {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .mjt-app-title {
            margin: 0;
            font-size: var(--mj-text-sm, 14px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-primary);
            line-height: 1.35;
        }
        .mjt-app-desc {
            margin: 0;
            font-size: var(--mj-text-xs, 12px);
            color: var(--mj-text-secondary);
            line-height: 1.45;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .mjt-app-meta {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .mjt-meta-item {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 11.5px;
            color: var(--mj-text-muted);
        }
        .mjt-app-actions {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
            flex-shrink: 0;
        }
        .mjt-cond-box {
            padding-top: 10px;
            border-top: 1px dashed var(--mj-border-default);
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .mjt-cond-label {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-secondary);
        }
        .mjt-cond-actions {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        `,
    ],
})
export class TaskApprovalCardComponent {
    @Input({ required: true }) Task!: TaskWidgetItem;
    @Input() Compact = false;
    @Input() Busy = false;
    @Input() ReadOnly = false;

    @Output() DecisionSubmitted = new EventEmitter<TaskApprovalActionEvent>();
    @Output() TaskClicked = new EventEmitter<string>();
    @Output() LinkedRecordClicked = new EventEmitter<TaskWidgetLinkedRecord>();

    public ShowConditionComposer = false;
    public ConditionNote = '';

    public get hookSummary(): string {
        const parts: string[] = [];
        if (this.Task.OnCompleteActionName) parts.push(`OnApprove: ${this.Task.OnCompleteActionName}`);
        if (this.Task.OnRejectActionName) parts.push(`OnReject: ${this.Task.OnRejectActionName}`);
        return parts.join(' · ');
    }

    public priorityPillClass(priority: string): string {
        switch (priority) {
            case 'Critical': return 'mjt-pill--error';
            case 'High': return 'mjt-pill--warning';
            case 'Medium': return 'mjt-pill--info';
            default: return 'mjt-pill--neutral';
        }
    }

    public toggleConditions(): void {
        this.ShowConditionComposer = !this.ShowConditionComposer;
    }

    public decide(outcomeCode: TaskApprovalActionEvent['OutcomeCode'], notes: string | null): void {
        this.ShowConditionComposer = false;
        this.ConditionNote = '';
        this.DecisionSubmitted.emit({
            TaskID: this.Task.ID,
            OutcomeCode: outcomeCode,
            Notes: notes,
        });
    }

    public onRecordClick(event: MouseEvent, record: TaskWidgetLinkedRecord): void {
        event.stopPropagation();
        this.LinkedRecordClicked.emit(record);
    }
}
