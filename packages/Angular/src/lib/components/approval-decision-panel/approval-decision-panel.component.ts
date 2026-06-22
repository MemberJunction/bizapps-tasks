import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, inject, Input, OnInit, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CompositeKey, LogError, Metadata, RunView } from '@memberjunction/core';
import {
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskDecisionEntity,
} from '@mj-biz-apps/tasks-entities';

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

                <label class="decision-label" for="outcome">Outcome</label>
                <select id="outcome" class="mj-input" [(ngModel)]="SelectedOutcomeCode" [disabled]="Saving">
                    @for (o of Outcomes; track o.Code) {
                        <option [value]="o.Code">{{ o.Name }}</option>
                    }
                </select>

                <label class="decision-label" for="notes">Notes</label>
                <textarea id="notes" class="mj-textarea" rows="4"
                    [(ngModel)]="Notes" [disabled]="Saving"
                    placeholder="Optional rationale or conditions…"></textarea>

                @if (SaveError) {
                    <div class="decision-error">{{ SaveError }}</div>
                }

                <div class="decision-actions">
                    <button class="btn btn-primary" (click)="Submit()" [disabled]="Saving || !SelectedOutcomeCode">
                        {{ Saving ? 'Recording…' : 'Record Decision' }}
                    </button>
                    <button class="btn btn-secondary" (click)="Cancelled.emit()" [disabled]="Saving">Cancel</button>
                </div>
            }
        </div>
    `,
    styles: [`
        .decision-panel { display: flex; flex-direction: column; gap: 8px; padding: 16px; background: var(--mj-bg-surface); }
        .decision-title { margin: 0 0 4px; font-size: 1.1rem; font-weight: 600; color: var(--mj-text-primary); }
        .decision-label { font-size: 0.85rem; font-weight: 600; color: var(--mj-text-secondary); margin-top: 4px; }
        .decision-loading { color: var(--mj-text-muted); padding: 12px 0; }
        .decision-error { color: var(--mj-status-error-text); background: var(--mj-status-error-bg); border: 1px solid var(--mj-status-error-border); border-radius: 4px; padding: 8px; font-size: 0.85rem; }
        .decision-actions { display: flex; gap: 8px; margin-top: 8px; }
        .btn { padding: 8px 16px; border-radius: 4px; border: 1px solid transparent; cursor: pointer; font-weight: 600; }
        .btn[disabled] { opacity: 0.6; cursor: not-allowed; }
        .btn-primary { background: var(--mj-brand-primary); color: var(--mj-text-inverse); }
        .btn-primary:hover:not([disabled]) { background: var(--mj-brand-primary-hover); }
        .btn-secondary { background: var(--mj-bg-surface-card); color: var(--mj-text-primary); border-color: var(--mj-border-default); }
        .btn-secondary:hover:not([disabled]) { background: var(--mj-bg-surface-hover); }
    `]
})
export class ApprovalDecisionPanelComponent implements OnInit {
    private cdr = inject(ChangeDetectorRef);

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
            await this.recordDecision(outcome);
            const newStatus = outcome.IsTerminal ? await this.transitionForOutcome(outcome.Code) : null;
            this.DecisionRecorded.emit({
                TaskID: this._taskID,
                OutcomeCode: outcome.Code,
                OutcomeName: outcome.Name,
                Notes: this.Notes || null,
                NewStatus: newStatus,
            });
        } catch (err) {
            this.SaveError = err instanceof Error ? err.message : String(err);
        } finally {
            this.Saving = false;
            this.cdr.detectChanges();
        }
    }

    private async recordDecision(outcome: DecisionOutcomeOption): Promise<void> {
        const md = new Metadata();
        const decision = await md.GetEntityObject<mjBizAppsTasksTaskDecisionEntity>('MJ_BizApps_Tasks: Task Decisions');
        decision.NewRecord();
        decision.TaskID = this._taskID!;
        decision.OutcomeID = outcome.ID;
        if (this.DecidedByPersonID) decision.DecidedByPersonID = this.DecidedByPersonID;
        if (this.Notes) decision.DecisionNotes = this.Notes;
        if (!(await decision.Save())) {
            throw new Error(`Failed to record decision: ${decision.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }
    }

    /** Transitions the task per the terminal outcome and returns the new status. */
    private async transitionForOutcome(code: string): Promise<'Completed' | 'Cancelled'> {
        const newStatus: 'Completed' | 'Cancelled' = code === 'Rejected' ? 'Cancelled' : 'Completed';
        const md = new Metadata();
        const task = await md.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
        const loaded = await task.InnerLoad(new CompositeKey([{ FieldName: 'ID', Value: this._taskID! }]));
        if (!loaded) {
            throw new Error(`Task ${this._taskID} not found`);
        }
        if (task.Status === newStatus) return newStatus;
        task.Status = newStatus;
        if (!(await task.Save())) {
            throw new Error(`Failed to transition task: ${task.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }
        return newStatus;
    }
}
