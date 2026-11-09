import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, inject, Input, OnInit, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RunView } from '@memberjunction/core';
import { FormatDurationClock, TaskOrchestrationService } from '@mj-biz-apps/tasks-core';
import { ApprovalDecisionPanelComponent, DecisionRecordedEvent } from '../approval-decision-panel/approval-decision-panel.component';
import { ApprovalTypePredicate } from './approval-type-predicate';

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
 * Group of pending timesheet part approval tasks sharing the same project/scope label (§8.5).
 */
export interface ApprovalProjectGroup {
    ScopeLabel: string;
    Approvals: ApprovalRow[];
    TotalMinutes: number;
    TotalFormatted: string;
}

/**
 * Approval inbox — lists the approval-request tasks awaiting a decision from a
 * given approver and embeds the {@link ApprovalDecisionPanelComponent} for
 * recording the outcome. Once a decision is recorded the row clears from the inbox.
 *
 * "Pending" = a task of an approval type (`TaskType.IsApproval`), assigned to the
 * approver, still in an open state (not Completed/Cancelled) and without a terminal decision.
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
                    @if (ProjectGroups.length > 0) {
                        @for (group of ProjectGroups; track group.ScopeLabel) {
                            <div class="inbox-group">
                                <div class="inbox-group-header">
                                    <div class="group-meta">
                                        <span class="group-label">
                                            <i class="fa-solid fa-folder-tree"></i> {{ group.ScopeLabel }}
                                        </span>
                                        <span class="group-sub">
                                            {{ group.Approvals.length }} {{ group.Approvals.length === 1 ? 'part' : 'parts' }}
                                            · {{ group.TotalFormatted }}
                                        </span>
                                    </div>
                                    <button
                                        type="button"
                                        class="btn-approve-all"
                                        [disabled]="BatchApprovingLabel === group.ScopeLabel"
                                        (click)="ApproveAllInGroup(group); $event.stopPropagation()">
                                        <i class="fa-solid fa-check-double"></i>
                                        {{ BatchApprovingLabel === group.ScopeLabel ? 'Approving…' : 'Approve all' }}
                                    </button>
                                </div>
                                <ul class="inbox-list">
                                    @for (a of group.Approvals; track a.ID) {
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
                            </div>
                        }
                    }

                    @if (UngroupedApprovals.length > 0) {
                        <ul class="inbox-list">
                            @for (a of UngroupedApprovals; track a.ID) {
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

        .inbox-group { border-bottom: 1px solid var(--mj-border-default); }
        .inbox-group:last-child { border-bottom: none; }
        .inbox-group-header {
            display: flex; align-items: center; justify-content: space-between; gap: 12px;
            padding: 8px 16px;
            background: var(--mj-bg-surface-sunken);
            border-bottom: 1px solid var(--mj-border-subtle);
        }
        .group-meta { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .group-label {
            font-size: 12px; font-weight: var(--mj-font-bold, 700);
            color: var(--mj-text-primary); display: inline-flex; align-items: center; gap: 6px;
        }
        .group-sub { font-size: 12px; color: var(--mj-text-muted); }
        .btn-approve-all {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 4px 10px; border-radius: var(--mj-radius-sm, 4px);
            background: var(--mj-brand-primary); color: var(--mj-text-inverse, #fff);
            border: 1px solid var(--mj-brand-primary);
            font-size: 12px; font-weight: var(--mj-font-semibold, 600);
            font-family: inherit; cursor: pointer;
        }
        .btn-approve-all:disabled { opacity: 0.5; cursor: not-allowed; }
    `]
})
export class ApprovalInboxComponent implements OnInit {
    private cdr = inject(ChangeDetectorRef);
    private orchestration = new TaskOrchestrationService();

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

    /**
     * Name of a single TaskType to list. When null (the default), every task type flagged
     * `IsApproval` is listed, so an app's own approval type appears without configuring the inbox.
     */
    @Input() ApprovalTypeName: string | null = null;

    // ── Outputs ─────────────────────────────────────────────

    /** Re-emitted from the embedded decision panel after a decision is recorded. */
    @Output() DecisionRecorded = new EventEmitter<DecisionRecordedEvent>();

    // ── State ───────────────────────────────────────────────

    public Loading = false;
    public LoadError: string | null = null;
    public Approvals: ApprovalRow[] = [];
    public ProjectGroups: ApprovalProjectGroup[] = [];
    public UngroupedApprovals: ApprovalRow[] = [];
    public SelectedApprovalID: string | null = null;
    public BatchApprovingLabel: string | null = null;

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
            this.ProjectGroups = [];
            this.UngroupedApprovals = [];
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
            await this.partitionTimesheetGroups();
        } catch (err) {
            this.LoadError = err instanceof Error ? err.message : String(err);
        } finally {
            this.Loading = false;
            this.cdr.detectChanges();
        }
    }

    /**
     * Records an `Approved` decision for every approval task in the given project group (§8.5).
     */
    public async ApproveAllInGroup(group: ApprovalProjectGroup): Promise<void> {
        if (!this._approverPersonID || this.BatchApprovingLabel) {
            return;
        }
        this.BatchApprovingLabel = group.ScopeLabel;
        this.LoadError = null;
        this.cdr.detectChanges();
        try {
            for (const row of group.Approvals) {
                const res = await this.orchestration.RecordDecision({
                    TaskID: row.ID,
                    OutcomeCode: 'Approved',
                    DecidedByPersonID: this._approverPersonID,
                });
                this.DecisionRecorded.emit({
                    TaskID: row.ID,
                    OutcomeCode: 'Approved',
                    OutcomeName: 'Approved',
                    Notes: null,
                    NewStatus: res.NewStatus as 'Completed' | 'Cancelled' | null,
                });
            }
            await this.Refresh();
        } catch (err) {
            this.LoadError = err instanceof Error ? err.message : String(err);
        } finally {
            this.BatchApprovingLabel = null;
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
        this.UngroupedApprovals = this.UngroupedApprovals.filter(a => a.ID !== event.TaskID);
        this.ProjectGroups = this.ProjectGroups
            .map((g) => ({
                ...g,
                Approvals: g.Approvals.filter((a) => a.ID !== event.TaskID),
            }))
            .filter((g) => g.Approvals.length > 0);
        this.SelectedApprovalID = null;
        this.DecisionRecorded.emit(event);
        this.cdr.detectChanges();
    }

    private async partitionTimesheetGroups(): Promise<void> {
        if (this.Approvals.length === 0) {
            this.ProjectGroups = [];
            this.UngroupedApprovals = [];
            return;
        }
        const taskIDs = this.Approvals.map((a) => `'${a.ID}'`).join(',');
        const partRes = await new RunView().RunView<{
            ApprovalTaskID: string | null;
            ScopeLabel: string | null;
            Minutes: number;
        }>({
            EntityName: 'MJ_BizApps_Tasks: Timesheet Approvals',
            ExtraFilter: `ApprovalTaskID IN (${taskIDs})`,
            Fields: ['ApprovalTaskID', 'ScopeLabel', 'Minutes'],
            ResultType: 'simple',
        });

        const partByTaskID = new Map<string, { ScopeLabel: string; TotalMinutes: number }>();
        for (const p of partRes?.Results ?? []) {
            if (p.ApprovalTaskID) {
                partByTaskID.set(p.ApprovalTaskID.toLowerCase(), {
                    ScopeLabel: p.ScopeLabel || 'Timesheet',
                    TotalMinutes: Number(p.Minutes ?? 0),
                });
            }
        }

        const groupsMap = new Map<string, { Approvals: ApprovalRow[]; TotalMinutes: number }>();
        const ungrouped: ApprovalRow[] = [];

        for (const row of this.Approvals) {
            const part = partByTaskID.get(row.ID.toLowerCase());
            if (part) {
                const existing = groupsMap.get(part.ScopeLabel) ?? { Approvals: [], TotalMinutes: 0 };
                existing.Approvals.push(row);
                existing.TotalMinutes += part.TotalMinutes;
                groupsMap.set(part.ScopeLabel, existing);
            } else {
                ungrouped.push(row);
            }
        }

        this.ProjectGroups = Array.from(groupsMap.entries()).map(([label, data]) => ({
            ScopeLabel: label,
            Approvals: data.Approvals,
            TotalMinutes: data.TotalMinutes,
            TotalFormatted: FormatDurationClock(data.TotalMinutes),
        }));
        this.UngroupedApprovals = ungrouped;
    }

    /**
     * Builds the ExtraFilter for pending approvals: tasks of an approval TaskType,
     * assigned to this approver, still open, and without any terminal decision yet.
     */
    private async buildPendingFilter(): Promise<string> {
        const personID = this._approverPersonID.replace(/'/g, "''");
        return [
            `TypeID IN (SELECT ID FROM __mj_BizAppsTasks.vwTaskTypes WHERE ${ApprovalTypePredicate(this.ApprovalTypeName)})`,
            `Status NOT IN ('Completed', 'Cancelled')`,
            `ID IN (SELECT TaskID FROM __mj_BizAppsTasks.vwTaskAssignments WHERE AssigneeRecordID = '${personID}')`,
            `ID NOT IN (SELECT d.TaskID FROM __mj_BizAppsTasks.vwTaskDecisions d INNER JOIN __mj_BizAppsTasks.vwTaskDecisionOutcomes o ON d.OutcomeID = o.ID WHERE o.IsTerminal = 1)`,
        ].join(' AND ');
    }
}
