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
            <div class="inbox-card">
                <div class="inbox-card-header">
                    <h3 class="inbox-title"><i class="fa-solid fa-stamp"></i> Approvals</h3>
                    @if (!Loading && !LoadError && Approvals.length > 0) {
                        <span class="inbox-count">{{ Approvals.length }} pending</span>
                    }
                </div>

                @if (Loading) {
                    <div class="inbox-empty">Loading…</div>
                } @else if (LoadError) {
                    <div class="inbox-error">{{ LoadError }}</div>
                } @else if (Approvals.length === 0) {
                    <div class="inbox-empty"><i class="fa-regular fa-circle-check"></i> No approvals waiting on you.</div>
                } @else {
                    <ul class="inbox-list">
                        @for (a of Approvals; track a.ID) {
                            <li class="inbox-row"
                                [class.selected]="a.ID === SelectedApprovalID"
                                (click)="Select(a.ID)" tabindex="0">
                                <div class="row-main">
                                    <span class="row-name">{{ a.Name }}</span>
                                    @if (a.Description) { <span class="row-desc">{{ a.Description }}</span> }
                                </div>
                                <span class="badge" [class]="priorityBadgeClass(a.Priority)">{{ a.Priority }}</span>
                            </li>
                        }
                    </ul>
                }
            </div>

            @if (SelectedApprovalID) {
                <bizapps-approval-decision-panel
                    [TaskID]="SelectedApprovalID"
                    [DecidedByPersonID]="ApproverPersonID"
                    (DecisionRecorded)="onDecisionRecorded($event)"
                    (Cancelled)="SelectedApprovalID = null">
                </bizapps-approval-decision-panel>
            }
        </div>
    `,
    styles: [`
        :host { display: block; }
        .approval-inbox { display: flex; flex-direction: column; gap: var(--mj-space-4, 16px); }

        .inbox-card {
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-lg, 12px);
            box-shadow: var(--mj-shadow-sm, 0 1px 2px 0 rgba(0,0,0,0.05));
            overflow: hidden;
        }
        .inbox-card-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: var(--mj-space-3, 12px) var(--mj-space-4, 16px);
            border-bottom: 1px solid var(--mj-border-subtle);
        }
        .inbox-title {
            margin: 0; font-size: var(--mj-text-base, 1rem); font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-primary); display: flex; align-items: center; gap: var(--mj-space-2, 8px);
        }
        .inbox-title i { color: var(--mj-brand-primary); }
        .inbox-count { font-size: var(--mj-text-sm, 0.875rem); color: var(--mj-text-muted); }

        .inbox-empty {
            color: var(--mj-text-muted); padding: var(--mj-space-5, 20px) var(--mj-space-4, 16px);
            font-size: var(--mj-text-sm, 0.875rem); display: flex; align-items: center; gap: var(--mj-space-2, 8px);
        }
        .inbox-error {
            color: var(--mj-status-error-text); background: var(--mj-status-error-bg);
            border-top: 1px solid var(--mj-status-error-border);
            padding: var(--mj-space-3, 12px) var(--mj-space-4, 16px); font-size: var(--mj-text-sm, 0.875rem);
        }

        .inbox-list { list-style: none; margin: 0; padding: 0; }
        .inbox-row {
            display: flex; align-items: center; justify-content: space-between; gap: var(--mj-space-3, 12px);
            padding: var(--mj-space-3, 12px) var(--mj-space-4, 16px);
            border-bottom: 1px solid var(--mj-border-subtle); cursor: pointer;
            transition: background 150ms ease; border-left: 3px solid transparent;
        }
        .inbox-row:last-child { border-bottom: none; }
        .inbox-row:hover { background: var(--mj-bg-surface-hover); }
        .inbox-row.selected {
            background: color-mix(in srgb, var(--mj-brand-primary) 8%, var(--mj-bg-surface));
            border-left-color: var(--mj-brand-primary);
        }
        .row-main { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
        .row-name { color: var(--mj-text-primary); font-weight: var(--mj-font-medium, 500); }
        .row-desc {
            color: var(--mj-text-muted); font-size: var(--mj-text-sm, 0.875rem);
            overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
        }

        /* ── priority badge (token pill) ── */
        .badge {
            flex-shrink: 0; display: inline-block; padding: 3px 10px; border-radius: var(--mj-radius-full, 9999px);
            font-size: var(--mj-text-xs, 0.75rem); font-weight: var(--mj-font-bold, 700);
            text-transform: uppercase; letter-spacing: 0.04em; line-height: 1.4;
            color: var(--mj-text-primary); background: var(--mj-bg-surface-sunken);
        }
        .badge--critical { color: var(--mj-status-error-text); background: var(--mj-status-error-bg); }
        .badge--high { color: var(--mj-status-warning-text); background: var(--mj-status-warning-bg); }
        .badge--medium { color: var(--mj-status-info-text); background: var(--mj-status-info-bg); }
        .badge--low { color: var(--mj-text-secondary); background: var(--mj-bg-surface-sunken); }
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

    /** Maps a task priority to its badge modifier class (token-driven status colors). */
    priorityBadgeClass(priority: string): string {
        switch ((priority || '').toLowerCase()) {
            case 'critical': return 'badge--critical';
            case 'high': return 'badge--high';
            case 'medium': return 'badge--medium';
            default: return 'badge--low';
        }
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
