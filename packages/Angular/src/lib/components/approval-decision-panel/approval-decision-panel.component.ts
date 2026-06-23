import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, inject, Input, OnInit, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RunView } from '@memberjunction/core';
import { TaskOrchestrationService, TaskDecisionOutcomeCode } from '@mj-biz-apps/tasks-core';

/** A selectable decision outcome loaded from the TaskDecisionOutcome lookup. */
export interface DecisionOutcomeOption {
    ID: string;
    Name: string;
    Code: string;
    IsTerminal: boolean;
}

/** Payload emitted after a decision is successfully recorded. */
export interface DecisionRecordedEvent {
    TaskID: string;
    OutcomeCode: string;
    OutcomeName: string;
    Notes: string | null;
    /** The status the task was transitioned to (null if the outcome was non-terminal). */
    NewStatus: 'Completed' | 'Cancelled' | null;
}

/**
 * Decision panel for an approval-request task. Presents the available outcomes
 * (Approved / Rejected / Approved With Conditions, plus any deployment-defined
 * outcomes) and records the chosen decision.
 *
 * Recording a decision creates a TaskDecision row and — for terminal outcomes —
 * transitions the task (Approved/ApprovedWithConditions → Completed,
 * Rejected → Cancelled). The server save-event handler then fires the
 * TaskType's OnComplete / OnReject / OnCancel action hooks.
 *
 * Standalone and Router-free so any Explorer or app can embed it.
 *
 * @example
 * ```html
 * <bizapps-approval-decision-panel
 *     [TaskID]="selectedApprovalID"
 *     [DecidedByPersonID]="currentUserPersonID"
 *     (DecisionRecorded)="onDecision($event)"
 *     (Cancelled)="closePanel()">
 * </bizapps-approval-decision-panel>
 * ```
 */
@Component({
    selector: 'bizapps-approval-decision-panel',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [CommonModule, FormsModule],
    template: `
        <div class="decision-panel">
            @if (Loading) {
                <div class="decision-loading">Loading…</div>
            } @else if (LoadError) {
                <div class="decision-error">{{ LoadError }}</div>
            } @else {
                <h3 class="decision-title">{{ TaskName || 'Approval Decision' }}</h3>

                <div class="field">
                    <label class="field-label" for="outcome">Outcome</label>
                    <select id="outcome" class="mj-select" [(ngModel)]="SelectedOutcomeCode" [disabled]="Saving">
                        @for (o of Outcomes; track o.Code) {
                            <option [value]="o.Code">{{ o.Name }}</option>
                        }
                    </select>
                </div>

                <div class="field">
                    <label class="field-label" for="notes">Notes</label>
                    <textarea id="notes" class="mj-textarea" rows="4"
                        [(ngModel)]="Notes" [disabled]="Saving"
                        placeholder="Optional rationale or conditions…"></textarea>
                </div>

                @if (SaveError) {
                    <div class="decision-error">{{ SaveError }}</div>
                }

                <div class="decision-actions">
                    <button type="button" class="mj-btn mj-btn--primary" (click)="Submit()" [disabled]="Saving || !SelectedOutcomeCode">
                        {{ Saving ? 'Recording…' : 'Record Decision' }}
                    </button>
                    <button type="button" class="mj-btn mj-btn--secondary" (click)="Cancelled.emit()" [disabled]="Saving">Cancel</button>
                </div>
            }
        </div>
    `,
    styles: [`
        :host { display: block; }
        .decision-panel {
            display: flex; flex-direction: column; gap: var(--mj-space-4, 16px);
            padding: var(--mj-space-5, 20px);
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-lg, 12px);
            box-shadow: var(--mj-shadow-sm, 0 1px 2px 0 rgba(0,0,0,0.05));
        }
        .decision-title { margin: 0; font-size: var(--mj-text-lg, 1.125rem); font-weight: var(--mj-font-semibold, 600); color: var(--mj-text-primary); }
        .decision-loading { color: var(--mj-text-muted); padding: var(--mj-space-3, 12px) 0; }
        .decision-error {
            color: var(--mj-status-error-text); background: var(--mj-status-error-bg);
            border: 1px solid var(--mj-status-error-border); border-radius: var(--mj-radius-sm, 4px);
            padding: var(--mj-space-2, 8px) var(--mj-space-3, 12px); font-size: var(--mj-text-sm, 0.875rem);
        }

        /* ── form fields ── */
        .field { display: flex; flex-direction: column; gap: var(--mj-space-2, 8px); }
        .field-label { font-size: var(--mj-text-sm, 0.875rem); font-weight: var(--mj-font-semibold, 600); color: var(--mj-text-primary); }
        .mj-select, .mj-textarea {
            width: 100%; padding: 8px 12px; min-height: 38px;
            font-family: inherit; font-size: var(--mj-text-sm, 0.875rem); line-height: 1.5;
            color: var(--mj-text-primary); background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default); border-radius: var(--mj-radius-sm, 4px);
            transition: border-color 150ms ease, box-shadow 150ms ease; outline: none;
        }
        .mj-textarea { min-height: 80px; resize: vertical; }
        .mj-select::placeholder, .mj-textarea::placeholder { color: var(--mj-text-disabled); }
        .mj-select:hover:not(:disabled), .mj-textarea:hover:not(:disabled) { border-color: var(--mj-border-strong); }
        .mj-select:focus, .mj-textarea:focus {
            border-color: var(--mj-brand-primary);
            box-shadow: 0 0 0 3px color-mix(in srgb, var(--mj-brand-primary) 15%, transparent);
        }
        .mj-select:disabled, .mj-textarea:disabled { opacity: 0.5; cursor: not-allowed; background: var(--mj-bg-surface-sunken); }

        /* ── buttons (token-driven, confirm-left) ── */
        .decision-actions { display: flex; gap: var(--mj-space-2, 8px); margin-top: var(--mj-space-1, 4px); }
        .mj-btn {
            display: inline-flex; align-items: center; justify-content: center; gap: 8px;
            padding: 9px 18px; border: 1px solid transparent; border-radius: var(--mj-radius-md, 8px);
            font-family: inherit; font-size: var(--mj-text-sm, 0.875rem); font-weight: var(--mj-font-semibold, 600);
            line-height: 1.5; cursor: pointer; white-space: nowrap;
            transition: background 150ms ease, border-color 150ms ease, box-shadow 200ms ease, transform 200ms ease;
        }
        .mj-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .mj-btn:focus-visible { outline: none; box-shadow: 0 0 0 3px color-mix(in srgb, var(--mj-brand-primary) 25%, transparent); }
        .mj-btn--primary { background: var(--mj-brand-primary); color: var(--mj-brand-on-primary, #fff); border-color: var(--mj-brand-primary); }
        .mj-btn--primary:hover:not(:disabled) { background: var(--mj-brand-primary-hover); border-color: var(--mj-brand-primary-hover); transform: translateY(-1px); box-shadow: var(--mj-shadow-md, 0 4px 6px -1px rgba(0,0,0,0.1)); }
        .mj-btn--secondary { background: var(--mj-bg-surface-sunken); color: var(--mj-text-primary); border-color: var(--mj-border-default); }
        .mj-btn--secondary:hover:not(:disabled) { background: var(--mj-bg-surface-hover); border-color: var(--mj-border-strong); }
    `]
})
export class ApprovalDecisionPanelComponent implements OnInit {
    private cdr = inject(ChangeDetectorRef);
    private orchestration = new TaskOrchestrationService();

    // ── Inputs ──────────────────────────────────────────────

    /** The approval-request task to decide on. Required. */
    @Input()
    set TaskID(value: string | null) {
        const changed = value !== this._taskID;
        this._taskID = value;
        if (changed && value) {
            void this.load();
        }
    }
    get TaskID(): string | null {
        return this._taskID;
    }
    private _taskID: string | null = null;

    /** The Person recording the decision (stamped on the TaskDecision). */
    @Input() DecidedByPersonID: string | null = null;

    // ── Outputs ─────────────────────────────────────────────

    /** Emitted after a decision is successfully recorded and the task transitioned. */
    @Output() DecisionRecorded = new EventEmitter<DecisionRecordedEvent>();

    /** Emitted when the user cancels without recording a decision. */
    @Output() Cancelled = new EventEmitter<void>();

    // ── State ───────────────────────────────────────────────

    public Loading = false;
    public Saving = false;
    public LoadError: string | null = null;
    public SaveError: string | null = null;
    public TaskName = '';
    public Outcomes: DecisionOutcomeOption[] = [];
    public SelectedOutcomeCode = '';
    public Notes = '';

    async ngOnInit(): Promise<void> {
        if (this._taskID) {
            await this.load();
        }
    }

    // ── Data loading ────────────────────────────────────────

    private async load(): Promise<void> {
        this.Loading = true;
        this.LoadError = null;
        this.cdr.detectChanges();
        try {
            await Promise.all([this.loadTaskName(), this.loadOutcomes()]);
        } catch (err) {
            this.LoadError = err instanceof Error ? err.message : String(err);
        } finally {
            this.Loading = false;
            this.cdr.detectChanges();
        }
    }

    private async loadTaskName(): Promise<void> {
        if (!this._taskID) return;
        const result = await new RunView().RunView<{ Name: string }>({
            EntityName: 'MJ_BizApps_Tasks: Tasks',
            ExtraFilter: `ID = '${this._taskID}'`,
            Fields: ['Name'],
            ResultType: 'simple',
            MaxRows: 1,
        });
        this.TaskName = result?.Results?.[0]?.Name ?? '';
    }

    private async loadOutcomes(): Promise<void> {
        const result = await new RunView().RunView<DecisionOutcomeOption>({
            EntityName: 'MJ_BizApps_Tasks: Task Decision Outcomes',
            ExtraFilter: 'IsActive = 1',
            OrderBy: 'Sequence ASC',
            Fields: ['ID', 'Name', 'Code', 'IsTerminal'],
            ResultType: 'simple',
        });
        this.Outcomes = result?.Results ?? [];
        if (this.Outcomes.length > 0 && !this.SelectedOutcomeCode) {
            this.SelectedOutcomeCode = this.Outcomes[0].Code;
        }
    }

    // ── Submit ──────────────────────────────────────────────

    async Submit(): Promise<void> {
        if (!this._taskID || !this.SelectedOutcomeCode) return;
        const outcome = this.Outcomes.find(o => o.Code === this.SelectedOutcomeCode);
        if (!outcome) return;

        this.Saving = true;
        this.SaveError = null;
        this.cdr.detectChanges();
        try {
            // Delegate to the shared orchestration service so the decision row,
            // the DecisionRecorded activity log, and the status transition all
            // happen through ONE code path (server + browser identical). The
            // service falls back to the provider's CurrentUser when contextUser
            // is omitted (client-side), per the MJ pattern.
            const result = await this.orchestration.RecordDecision({
                TaskID: this._taskID,
                OutcomeCode: outcome.Code as TaskDecisionOutcomeCode,
                DecidedByPersonID: this.DecidedByPersonID ?? undefined,
                Notes: this.Notes || undefined,
            });
            this.DecisionRecorded.emit({
                TaskID: this._taskID,
                OutcomeCode: outcome.Code,
                OutcomeName: outcome.Name,
                Notes: this.Notes || null,
                NewStatus: result.NewStatus as 'Completed' | 'Cancelled' | null,
            });
        } catch (err) {
            this.SaveError = err instanceof Error ? err.message : String(err);
        } finally {
            this.Saving = false;
            this.cdr.detectChanges();
        }
    }
}
