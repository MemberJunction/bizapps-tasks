import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, inject, Input, OnInit, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RunView } from '@memberjunction/core';
import { ApprovalDecisionPanelComponent, DecisionRecordedEvent } from '../approval-decision-panel/approval-decision-panel.component';

/** A pending approval-request task shown in the inbox. */
export interface ApprovalRow {
    ID: string;
    Name: string;
    Description: string | null;
    Priority: string;
    DueAt: Date | null;
    Status: string;
}

/**
 * Approval inbox — lists the approval-request tasks awaiting a decision from a
 * given approver and embeds the {@link ApprovalDecisionPanelComponent} for
 * recording the outcome. Once a decision is recorded the row clears from the inbox.
 *
 * "Pending" = a task of the "Approval Request" type, assigned to the approver,
 * still in an open state (not Completed/Cancelled) and without a terminal decision.
 *
 * Standalone and Router-free so any Explorer or app can embed it.
 *
 * @example
 * ```html
 * <bizapps-approval-inbox
 *     [ApproverPersonID]="currentUserPersonID"
 *     (DecisionRecorded)="refreshSourceRecord($event)">
 * </bizapps-approval-inbox>
 * ```
 */
@Component({
    selector: 'bizapps-approval-inbox',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [CommonModule, ApprovalDecisionPanelComponent],
    template: `
        <div class="approval-inbox">
            <h3 class="inbox-title">Approvals</h3>

            @if (Loading) {
                <div class="inbox-empty">Loading…</div>
            } @else if (LoadError) {
                <div class="inbox-error">{{ LoadError }}</div>
            } @else if (Approvals.length === 0) {
                <div class="inbox-empty">No approvals waiting on you.</div>
            } @else {
                <ul class="inbox-list">
                    @for (a of Approvals; track a.ID) {
                        <li class="inbox-item"
                            [class.selected]="a.ID === SelectedApprovalID"
                            (click)="Select(a.ID)">
                            <span class="item-name">{{ a.Name }}</span>
                            <span class="item-priority" [attr.data-priority]="a.Priority">{{ a.Priority }}</span>
                        </li>
                    }
                </ul>

                @if (SelectedApprovalID) {
                    <bizapps-approval-decision-panel
                        [TaskID]="SelectedApprovalID"
                        [DecidedByPersonID]="ApproverPersonID"
                        (DecisionRecorded)="onDecisionRecorded($event)"
                        (Cancelled)="SelectedApprovalID = null">
                    </bizapps-approval-decision-panel>
                }
            }
        </div>
    `,
    styles: [`
        .approval-inbox { display: flex; flex-direction: column; gap: 8px; }
        .inbox-title { margin: 0 0 4px; font-size: 1.1rem; font-weight: 600; color: var(--mj-text-primary); }
        .inbox-empty { color: var(--mj-text-muted); padding: 12px 0; }
        .inbox-error { color: var(--mj-status-error-text); background: var(--mj-status-error-bg); border: 1px solid var(--mj-status-error-border); border-radius: 4px; padding: 8px; font-size: 0.85rem; }
        .inbox-list { list-style: none; margin: 0; padding: 0; }
        .inbox-item { display: flex; justify-content: space-between; align-items: center; gap: 8px; padding: 10px 12px; border: 1px solid var(--mj-border-subtle); border-radius: 4px; margin-bottom: 4px; cursor: pointer; }
        .inbox-item:hover { background: var(--mj-bg-surface-hover); }
        .inbox-item.selected { border-color: var(--mj-brand-primary); background: color-mix(in srgb, var(--mj-brand-primary) 8%, var(--mj-bg-surface)); }
        .item-name { color: var(--mj-text-primary); font-weight: 500; }
        .item-priority { font-size: 0.75rem; color: var(--mj-text-secondary); }
    `]
})
export class ApprovalInboxComponent implements OnInit {
    private cdr = inject(ChangeDetectorRef);

    // ── Inputs ──────────────────────────────────────────────

    /** The approver's Person ID. Required — scopes the inbox to that person. */
    @Input()
    set ApproverPersonID(value: string) {
        const changed = value !== this._approverPersonID;
        this._approverPersonID = value;
        if (changed && value) {
            void this.Refresh();
        }
    }
    get ApproverPersonID(): string {
        return this._approverPersonID;
    }
    private _approverPersonID = '';

    /** Name of the TaskType used for approval requests. @default 'Approval Request' */
    @Input() ApprovalTypeName = 'Approval Request';

    // ── Outputs ─────────────────────────────────────────────

    /** Re-emitted from the embedded decision panel after a decision is recorded. */
    @Output() DecisionRecorded = new EventEmitter<DecisionRecordedEvent>();

    // ── State ───────────────────────────────────────────────

    public Loading = false;
    public LoadError: string | null = null;
    public Approvals: ApprovalRow[] = [];
    public SelectedApprovalID: string | null = null;

    async ngOnInit(): Promise<void> {
        if (this._approverPersonID) {
            await this.Refresh();
        }
    }

    // ── Public API ──────────────────────────────────────────

    /** Reloads the pending approvals from the server. */
    async Refresh(): Promise<void> {
        if (!this._approverPersonID) {
            this.Approvals = [];
            return;
        }
        this.Loading = true;
        this.LoadError = null;
        this.cdr.detectChanges();
        try {
            const filter = await this.buildPendingFilter();
            const result = await new RunView().RunView<ApprovalRow>({
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                ExtraFilter: filter,
                OrderBy: 'DueAt ASC',
                Fields: ['ID', 'Name', 'Description', 'Priority', 'DueAt', 'Status'],
                ResultType: 'simple',
            });
            if (!result?.Success) {
                throw new Error(result?.ErrorMessage || 'Failed to load approvals');
            }
            this.Approvals = result.Results ?? [];
        } catch (err) {
            this.LoadError = err instanceof Error ? err.message : String(err);
        } finally {
            this.Loading = false;
            this.cdr.detectChanges();
        }
    }

    // ── Internal ────────────────────────────────────────────

    Select(approvalID: string): void {
        this.SelectedApprovalID = approvalID;
    }

    onDecisionRecorded(event: DecisionRecordedEvent): void {
        // Clear the decided row from the inbox and re-emit for consumers.
        this.Approvals = this.Approvals.filter(a => a.ID !== event.TaskID);
        this.SelectedApprovalID = null;
        this.DecisionRecorded.emit(event);
        this.cdr.detectChanges();
    }

    /**
     * Builds the ExtraFilter for pending approvals: tasks of the approval TaskType,
     * assigned to this approver, still open, and without any terminal decision yet.
     */
    private async buildPendingFilter(): Promise<string> {
        const typeName = this.ApprovalTypeName.replace(/'/g, "''");
        const personID = this._approverPersonID.replace(/'/g, "''");
        return [
            `TypeID IN (SELECT ID FROM __mj_BizAppsTasks.TaskType WHERE Name = '${typeName}')`,
            `Status NOT IN ('Completed', 'Cancelled')`,
            `ID IN (SELECT TaskID FROM __mj_BizAppsTasks.TaskAssignment WHERE AssigneeRecordID = '${personID}')`,
            `ID NOT IN (SELECT d.TaskID FROM __mj_BizAppsTasks.TaskDecision d INNER JOIN __mj_BizAppsTasks.TaskDecisionOutcome o ON d.OutcomeID = o.ID WHERE o.IsTerminal = 1)`,
        ].join(' AND ');
    }
}
