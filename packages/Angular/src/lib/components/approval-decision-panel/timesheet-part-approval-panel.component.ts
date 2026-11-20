import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    inject,
    OnInit,
} from '@angular/core';
import { RunView } from '@memberjunction/core';
import { RegisterClass, UUIDsEqual } from '@memberjunction/global';
import { SharedGenericModule } from '@memberjunction/ng-shared-generic';
import { FormatDurationClock, FormatDurationMinutes } from '@mj-biz-apps/tasks-core';
import { BaseApprovalSubjectPanel } from './base-approval-subject-panel';

/**
 * One task row in the timesheet part approval Task × Day grid.
 */
export interface PartGridTaskRow {
    TaskID: string;
    TaskName: string;
    DayMinutes: Record<string, number>;
    TotalMinutes: number;
    BillableMinutes: number;
    Notes: Array<{ WorkDate: string; Notes: string; DurationFormatted: string }>;
}

/**
 * Approval subject panel registered for `'MJ_BizApps_Tasks: Timesheet Approvals'` (§8.5).
 *
 * Displays:
 * - Submitter name, period start/end, and the part's scope/project label
 * - Part totals (total time, billable time, entry count)
 * - Task × Day breakdown grid and entry notes for **this part's entries only**
 * - A row-level security notice if any entries in the part are hidden from the approver (§16)
 */
@RegisterClass(BaseApprovalSubjectPanel, 'MJ_BizApps_Tasks: Timesheet Approvals')
@Component({
    selector: 'bizapps-timesheet-part-approval-panel',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [SharedGenericModule],
    template: `
        <div class="part-approval-card">
            @if (loading) {
                <mj-loading text="Loading timesheet part..." size="small"></mj-loading>
            } @else if (part) {
                <div class="part-header">
                    <div class="part-header-top">
                        <span class="part-badge">
                            <i class="fa-solid fa-calendar-check"></i> Timesheet Part
                        </span>
                        <span class="part-round">Round {{ part.SubmissionRound }}</span>
                    </div>
                    <h4 class="part-scope-title">{{ part.ScopeLabel }}</h4>
                    @if (timesheet) {
                        <div class="part-meta">
                            <span><strong>Person:</strong> {{ timesheet.Person || timesheet.PersonID }}</span>
                            <span><strong>Period:</strong> {{ timesheet.PeriodStart }} – {{ timesheet.PeriodEnd }}</span>
                        </div>
                    }
                    <div class="part-totals">
                        <span class="total-pill">
                            <strong>Total:</strong> {{ formatClock(part.Minutes) }} ({{ formatSummary(part.Minutes) }})
                        </span>
                        <span class="total-pill total-pill--billable">
                            <strong>Billable:</strong> {{ formatClock(part.BillableMinutes) }}
                        </span>
                        <span class="total-pill">
                            <strong>Entries:</strong> {{ part.EntryCount }}
                        </span>
                    </div>
                </div>

                @if (hiddenEntryCount > 0) {
                    <div class="rls-notice" role="status">
                        <i class="fa-solid fa-eye-slash"></i>
                        {{ hiddenEntryCount }} {{ hiddenEntryCount === 1 ? 'entry in this part is' : 'entries in this part are' }}
                        hidden by row-level security.
                    </div>
                }

                @if (taskRows.length > 0) {
                    <div class="part-grid-scroll">
                        <table class="part-grid">
                            <thead>
                                <tr>
                                    <th class="col-task">Task</th>
                                    @for (day of days; track day) {
                                        <th class="col-day">{{ formatDayShort(day) }}</th>
                                    }
                                    <th class="col-total">Total</th>
                                </tr>
                            </thead>
                            <tbody>
                                @for (row of taskRows; track row.TaskID) {
                                    <tr>
                                        <td class="col-task">{{ row.TaskName }}</td>
                                        @for (day of days; track day) {
                                            <td class="col-day">
                                                {{ row.DayMinutes[day] ? formatClock(row.DayMinutes[day]) : '—' }}
                                            </td>
                                        }
                                        <td class="col-total">
                                            <strong>{{ formatClock(row.TotalMinutes) }}</strong>
                                        </td>
                                    </tr>
                                }
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td class="col-task"><strong>Day Total</strong></td>
                                    @for (day of days; track day) {
                                        <td class="col-day">
                                            <strong>{{ dayTotals[day] ? formatClock(dayTotals[day]) : '—' }}</strong>
                                        </td>
                                    }
                                    <td class="col-total">
                                        <strong>{{ formatClock(visibleTotalMinutes) }}</strong>
                                    </td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>

                    @if (allNotes.length > 0) {
                        <div class="part-notes">
                            <span class="notes-heading">Entry Notes</span>
                            @for (note of allNotes; track $index) {
                                <div class="note-item">
                                    <span class="note-meta">
                                        <strong>{{ note.TaskName }}</strong> · {{ note.WorkDate }} ({{ note.DurationFormatted }})
                                    </span>
                                    <span class="note-text">{{ note.Notes }}</span>
                                </div>
                            }
                        </div>
                    }
                } @else if (part.EntryCount === 0) {
                    <p class="empty-part-note">This timesheet part confirms 0 hours logged for the period.</p>
                }
            }
        </div>
    `,
    styles: [`
        :host {
            display: block;
            font-family: var(--mj-font-family);
        }
        .part-approval-card {
            margin: 12px 0;
            padding: 14px;
            border-radius: var(--mj-radius-md);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface-sunken);
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .part-header {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .part-header-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .part-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: 11px;
            font-weight: var(--mj-font-bold);
            text-transform: uppercase;
            color: var(--mj-brand-primary);
            letter-spacing: 0.4px;
        }
        .part-round {
            font-size: 11px;
            color: var(--mj-text-muted);
        }
        .part-scope-title {
            margin: 0;
            font-size: 15px;
            font-weight: var(--mj-font-bold);
            color: var(--mj-text-primary);
        }
        .part-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 14px;
            font-size: 12px;
            color: var(--mj-text-secondary);
        }
        .part-totals {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 2px;
        }
        .total-pill {
            padding: 3px 8px;
            border-radius: var(--mj-radius-sm);
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            font-size: 12px;
            color: var(--mj-text-primary);
        }
        .total-pill--billable {
            background: color-mix(in srgb, var(--mj-status-success) 10%, var(--mj-bg-surface));
            border-color: color-mix(in srgb, var(--mj-status-success) 30%, var(--mj-border-default));
        }
        .rls-notice {
            padding: 8px 10px;
            border-radius: var(--mj-radius-sm);
            background: var(--mj-status-warning-bg);
            color: var(--mj-status-warning-text);
            border: 1px solid var(--mj-status-warning-border);
            font-size: 12px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .part-grid-scroll {
            overflow-x: auto;
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-sm);
            background: var(--mj-bg-surface);
        }
        .part-grid {
            width: 100%;
            border-collapse: collapse;
            font-size: 12px;
            font-variant-numeric: tabular-nums;
        }
        .part-grid th,
        .part-grid td {
            padding: 6px 8px;
            border-bottom: 1px solid var(--mj-border-subtle);
        }
        .part-grid th {
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-secondary);
            font-size: 11px;
            font-weight: var(--mj-font-bold);
        }
        .col-task {
            text-align: left;
            min-width: 140px;
        }
        .col-day {
            text-align: right;
            white-space: nowrap;
        }
        .col-total {
            text-align: right;
            white-space: nowrap;
            background: color-mix(in srgb, var(--mj-brand-primary) 5%, var(--mj-bg-surface));
        }
        .part-notes {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .notes-heading {
            font-size: 11px;
            font-weight: var(--mj-font-bold);
            color: var(--mj-text-muted);
            text-transform: uppercase;
        }
        .note-item {
            padding: 6px 8px;
            border-radius: var(--mj-radius-sm);
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-subtle);
            font-size: 12px;
            display: flex;
            flex-direction: column;
            gap: 2px;
        }
        .note-meta {
            color: var(--mj-text-secondary);
            font-size: 11px;
        }
        .note-text {
            color: var(--mj-text-primary);
        }
        .empty-part-note {
            margin: 0;
            font-size: 12px;
            color: var(--mj-text-muted);
        }
    `],
})
export class TimesheetPartApprovalPanelComponent extends BaseApprovalSubjectPanel implements OnInit {
    public loading = false;
    public part: {
        ID: string;
        TimesheetID: string;
        SubmissionRound: number;
        ScopeTaskID: string | null;
        ScopeEntityID: string | null;
        ScopeRecordID: string | null;
        ScopeLabel: string;
        EntryCount: number;
        Minutes: number;
        BillableMinutes: number;
        Status: string;
    } | null = null;
    public timesheet: {
        ID: string;
        PersonID: string;
        Person: string | null;
        PeriodStart: string;
        PeriodEnd: string;
        Status: string;
    } | null = null;
    public days: string[] = [];
    public taskRows: PartGridTaskRow[] = [];
    public dayTotals: Record<string, number> = {};
    public visibleTotalMinutes = 0;
    public hiddenEntryCount = 0;
    public allNotes: Array<{ TaskName: string; WorkDate: string; DurationFormatted: string; Notes: string }> = [];

    private initialized = false;
    private cdr = inject(ChangeDetectorRef);

    public ngOnInit(): void {
        this.initialized = true;
        void this.Refresh();
    }

    protected override onSubjectInputsChanged(): void {
        if (this.initialized) {
            void this.Refresh();
        }
    }

    public async Refresh(): Promise<void> {
        if (!this.SubjectRecordID && !this.ApprovalTaskID) {
            this.part = null;
            this.cdr.markForCheck();
            return;
        }

        this.loading = true;
        this.cdr.markForCheck();

        try {
            const rv = new RunView();
            const filter = this.SubjectRecordID
                ? `ID = '${this.SubjectRecordID}'`
                : `ApprovalTaskID = '${this.ApprovalTaskID}'`;
            const partRes = await rv.RunView<{
                ID: string;
                TimesheetID: string;
                SubmissionRound: number;
                ScopeTaskID: string | null;
                ScopeEntityID: string | null;
                ScopeRecordID: string | null;
                ScopeLabel: string | null;
                EntryCount: number;
                Minutes: number;
                BillableMinutes: number;
                Status: string;
            }>({
                EntityName: 'MJ_BizApps_Tasks: Timesheet Approvals',
                ExtraFilter: filter,
                ResultType: 'simple',
                MaxRows: 1,
            });
            const partRow = partRes.Results?.[0] ?? null;
            this.part = partRow
                ? {
                      ...partRow,
                      ScopeLabel: partRow.ScopeLabel || 'Timesheet Part',
                  }
                : null;
            if (!partRow) {
                this.loading = false;
                this.cdr.markForCheck();
                return;
            }

            const [tsRes, siblingPartsRes, entriesRes] = await Promise.all([
                rv.RunView<{
                    ID: string;
                    PersonID: string;
                    Person: string | null;
                    PeriodStart: string | Date;
                    PeriodEnd: string | Date;
                    Status: string;
                }>({
                    EntityName: 'MJ_BizApps_Tasks: Timesheets',
                    ExtraFilter: `ID = '${partRow.TimesheetID}'`,
                    ResultType: 'simple',
                    MaxRows: 1,
                }),
                rv.RunView<{
                    ID: string;
                    ScopeTaskID: string | null;
                    ScopeEntityID: string | null;
                    ScopeRecordID: string | null;
                    SubmissionRound: number;
                }>({
                    EntityName: 'MJ_BizApps_Tasks: Timesheet Approvals',
                    ExtraFilter: `TimesheetID = '${partRow.TimesheetID}' AND SubmissionRound = ${partRow.SubmissionRound}`,
                    ResultType: 'simple',
                }),
                rv.RunView<{
                    ID: string;
                    TaskID: string;
                    Task: string | null;
                    WorkDate: string | Date;
                    Minutes: number;
                    IsBillable: boolean;
                    Notes: string | null;
                }>({
                    EntityName: 'MJ_BizApps_Tasks: Task Time Entries',
                    ExtraFilter: `TimesheetID = '${partRow.TimesheetID}'`,
                    OrderBy: 'WorkDate ASC',
                    ResultType: 'simple',
                }),
            ]);

            const tsRow = tsRes.Results?.[0];
            this.timesheet = tsRow
                ? {
                      ID: tsRow.ID,
                      PersonID: tsRow.PersonID,
                      Person: tsRow.Person,
                      PeriodStart: this.toIsoDate(tsRow.PeriodStart),
                      PeriodEnd: this.toIsoDate(tsRow.PeriodEnd),
                      Status: tsRow.Status,
                  }
                : null;

            const allEntries = entriesRes.Results ?? [];
            const siblingParts = siblingPartsRes.Results ?? [];

            let partEntries = allEntries;
            if (siblingParts.length > 1 && allEntries.length > 0) {
                // Filter entries to those belonging to this part's scope
                const taskIDs = Array.from(new Set(allEntries.map((e) => e.TaskID)));
                const tasksRes = await rv.RunView<{
                    ID: string;
                    ParentID: string | null;
                    RootParentID: string | null;
                }>({
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: `ID IN (${taskIDs.map((id) => `'${id}'`).join(',')})`,
                    Fields: ['ID', 'ParentID', 'RootParentID'],
                    ResultType: 'simple',
                });
                const rootByTaskID = new Map<string, string>();
                for (const t of tasksRes.Results ?? []) {
                    rootByTaskID.set(t.ID.toLowerCase(), (t.RootParentID || t.ID).toLowerCase());
                }

                const otherScopeTaskIDs = new Set(
                    siblingParts
                        .filter((sp) => !UUIDsEqual(sp.ID, partRow.ID))
                        .map((sp) => (sp.ScopeTaskID || sp.ScopeRecordID || '').toLowerCase())
                        .filter((id) => !!id),
                );
                const thisScopeTaskLower = (partRow.ScopeTaskID || partRow.ScopeRecordID || '').toLowerCase();
                const isUnassignedPart = !thisScopeTaskLower || !!(
                    this.timesheet && UUIDsEqual(thisScopeTaskLower, this.timesheet.PersonID)
                );

                partEntries = allEntries.filter((entry) => {
                    const taskLower = entry.TaskID.toLowerCase();
                    const rootLower = rootByTaskID.get(taskLower) ?? taskLower;
                    if (thisScopeTaskLower && (taskLower === thisScopeTaskLower || rootLower === thisScopeTaskLower)) {
                        return true;
                    }
                    if (
                        isUnassignedPart &&
                        !otherScopeTaskIDs.has(taskLower) &&
                        !otherScopeTaskIDs.has(rootLower)
                    ) {
                        return true;
                    }
                    return false;
                });
            }

            this.hiddenEntryCount = Math.max(0, partRow.EntryCount - partEntries.length);

            const daySet = new Set<string>();
            const rowsByTask = new Map<string, PartGridTaskRow>();
            const dayTotals: Record<string, number> = {};
            const allNotes: Array<{
                TaskName: string;
                WorkDate: string;
                DurationFormatted: string;
                Notes: string;
            }> = [];
            let visibleTotal = 0;

            for (const entry of partEntries) {
                const day = this.toIsoDate(entry.WorkDate);
                daySet.add(day);
                dayTotals[day] = (dayTotals[day] ?? 0) + entry.Minutes;
                visibleTotal += entry.Minutes;

                const taskKey = entry.TaskID.toLowerCase();
                let row = rowsByTask.get(taskKey);
                if (!row) {
                    row = {
                        TaskID: entry.TaskID,
                        TaskName: entry.Task || entry.TaskID,
                        DayMinutes: {},
                        TotalMinutes: 0,
                        BillableMinutes: 0,
                        Notes: [],
                    };
                    rowsByTask.set(taskKey, row);
                }
                row.DayMinutes[day] = (row.DayMinutes[day] ?? 0) + entry.Minutes;
                row.TotalMinutes += entry.Minutes;
                if (entry.IsBillable) {
                    row.BillableMinutes += entry.Minutes;
                }
                if (entry.Notes?.trim()) {
                    const noteItem = {
                        TaskName: row.TaskName,
                        WorkDate: day,
                        DurationFormatted: FormatDurationClock(entry.Minutes),
                        Notes: entry.Notes.trim(),
                    };
                    row.Notes.push(noteItem);
                    allNotes.push(noteItem);
                }
            }

            this.days = Array.from(daySet).sort();
            this.taskRows = Array.from(rowsByTask.values()).sort((a, b) =>
                a.TaskName.localeCompare(b.TaskName),
            );
            this.dayTotals = dayTotals;
            this.visibleTotalMinutes = visibleTotal;
            this.allNotes = allNotes;
        } finally {
            this.loading = false;
            this.cdr.markForCheck();
        }
    }

    public formatClock(minutes: number): string {
        return FormatDurationClock(minutes) || '0:00';
    }

    public formatSummary(minutes: number): string {
        return FormatDurationMinutes(minutes);
    }

    public formatDayShort(isoDate: string): string {
        const d = new Date(`${isoDate}T00:00:00.000Z`);
        if (Number.isNaN(d.getTime())) {
            return isoDate;
        }
        return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', timeZone: 'UTC' });
    }

    private toIsoDate(val: string | Date): string {
        if (val instanceof Date) {
            return val.toISOString().slice(0, 10);
        }
        return String(val).slice(0, 10);
    }
}
