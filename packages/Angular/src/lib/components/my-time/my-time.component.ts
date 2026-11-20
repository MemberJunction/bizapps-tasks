import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    inject,
    Input,
    OnInit,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';
import { UUIDsEqual } from '@memberjunction/global';
import { SharedGenericModule } from '@memberjunction/ng-shared-generic';
import { AddDays, CompareDays, ToCalendarDay, type CalendarDay } from '@mj-biz-apps/common-entities';
import {
    FormatDurationClock,
    ParseDurationMinutes,
    PeriodFor,
    ResolveScheduleForDate,
    TasksSettings,
    TimeTrackingService,
    UserCanManageTimeEntries,
    UserCanManageTimesheets,
    type EffectiveScheduleCandidate,
    type TimesheetCadence,
    type TimesheetPeriodBounds,
    type TimesheetPeriodType,
} from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksTaskTimeEntryEntity,
    mjBizAppsTasksTimesheetScheduleEntity,
} from '@mj-biz-apps/tasks-entities';
import { OpenTaskRecord } from '../../open-task-record';

/**
 * Lightweight representation of a single `TaskTimeEntry` inside a My Time grid cell.
 */
export interface MyTimeCellEntry {
    ID: string;
    TaskID: string;
    WorkDate: string;
    DurationMinutes: number;
    IsBillable: boolean;
    Notes: string | null;
    Source: mjBizAppsTasksTaskTimeEntryEntity['Source'];
    IsLocked: boolean;
    LockReason: string | null;
}

/**
 * Discriminated union returned by {@link ResolveGridCellAction} describing what
 * editing a cell in the My Time grid should do (§8.4).
 */
export type GridCellAction =
    | { kind: 'no-op' }
    | { kind: 'invalid'; message: string }
    | { kind: 'locked'; reason: string }
    | { kind: 'create'; durationMinutes: number }
    | { kind: 'update'; entryID: string; durationMinutes: number }
    | { kind: 'confirm-delete'; entryID: string }
    | { kind: 'open-breakdown'; entries: ReadonlyArray<MyTimeCellEntry> };

/**
 * Pure function implementing the My Time grid cell editing semantics (§8.4):
 * - **0 entries**: typing a positive duration creates one manual entry; clearing is a no-op.
 * - **1 entry**: typing a positive duration updates its duration; clearing prompts confirmation to delete.
 * - **2+ entries**: opens the breakdown dialog listing the entries in that cell.
 * - **Locked period or entry**: returns `{ kind: 'locked' }`.
 *
 * @param entriesInCell - Existing entries for `(TaskID, WorkDate)`.
 * @param rawInput - User-typed string in the cell (e.g. `'2:00'`, `'1h 30m'`, `'1.5'`, `''`).
 * @param periodLocked - True when the cell's date falls in a `Submitted` or `Approved` timesheet.
 */
export function ResolveGridCellAction(
    entriesInCell: ReadonlyArray<MyTimeCellEntry>,
    rawInput: string,
    periodLocked: boolean = false,
): GridCellAction {
    if (periodLocked) {
        return { kind: 'locked', reason: 'This timesheet period is locked.' };
    }
    if (entriesInCell.length >= 2) {
        return { kind: 'open-breakdown', entries: entriesInCell };
    }

    const trimmed = (rawInput ?? '').trim();
    const isClear = trimmed === '' || trimmed === '0' || trimmed === '0:00' || trimmed === '0h' || trimmed === '0m';

    if (entriesInCell.length === 0) {
        if (isClear) {
            return { kind: 'no-op' };
        }
        const minutes = ParseDurationMinutes(trimmed);
        if (minutes === null) {
            return {
                kind: 'invalid',
                message: 'Enter a valid duration such as "1:30", "1h 30m", "1.5", or "90m".',
            };
        }
        return { kind: 'create', durationMinutes: minutes };
    }

    // Exactly 1 entry in cell
    const single = entriesInCell[0];
    if (single.IsLocked) {
        return { kind: 'locked', reason: single.LockReason || 'This time entry is locked.' };
    }
    if (isClear) {
        return { kind: 'confirm-delete', entryID: single.ID };
    }

    const minutes = ParseDurationMinutes(trimmed);
    if (minutes === null) {
        return {
            kind: 'invalid',
            message: 'Enter a valid duration such as "1:30", "1h 30m", "1.5", or "90m".',
        };
    }
    if (minutes === single.DurationMinutes) {
        return { kind: 'no-op' };
    }
    return { kind: 'update', entryID: single.ID, durationMinutes: minutes };
}

/**
 * One row in the My Time grid representing a task and its daily cells.
 */
export interface MyTimeTaskRow {
    TaskID: string;
    TaskName: string;
    RootTaskName: string | null;
    DisplayLabel: string;
    IsTimerRunning: boolean;
    CellsByDate: Record<
        string,
        {
            Entries: MyTimeCellEntry[];
            TotalMinutes: number;
            DisplayValue: string;
        }
    >;
    RowTotalMinutes: number;
    RowBillableMinutes: number;
}

interface TaskLookupItem {
    ID: string;
    Name: string;
    RootParentID: string | null;
}

/**
 * My Time weekly / period grid component (§8.4).
 *
 * Provides:
 * - **Week | Period** toggle and date navigation (`◀`, `Today`, `▶`)
 * - Task × Day grid with project-prefixed task labels (`RootTask › Task`)
 * - Cell editing for 0, 1, or multiple entries per cell
 * - **+ Add a task** picker (assigned tasks, recently timed tasks, search)
 * - Soft daily warning above `MaxDailyLoggedMinutes`
 * - Timesheet status bar (per-part status while `Submitted`, approval date when `Approved`,
 *   rejection notes or reopen reason when `Rejected`)
 * - **Submit**, **Withdraw**, **Reopen** (for `Manage Timesheets` holders), and **Schedule** editor
 */
@Component({
    selector: 'bizapps-my-time',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [FormsModule, SharedGenericModule],
    template: `
        @if (!timeTrackingEnabled && !loading) {
            <div class="my-time-disabled">
                <i class="fa-solid fa-clock"></i>
                <p>Time tracking is not enabled for this Tasks deployment.</p>
            </div>
        } @else {
            <div class="my-time-root">
                <!-- Top Toolbar -->
                <div class="mt-toolbar">
                    <div class="mt-toolbar-left">
                        <div class="view-mode-toggle" role="group" aria-label="View mode">
                            <button
                                type="button"
                                class="toggle-btn"
                                [class.toggle-btn--active]="viewMode === 'week'"
                                (click)="setViewMode('week')">
                                Week
                            </button>
                            <button
                                type="button"
                                class="toggle-btn"
                                [class.toggle-btn--active]="viewMode === 'period'"
                                (click)="setViewMode('period')">
                                Period
                            </button>
                        </div>

                        <div class="period-nav">
                            <button type="button" class="nav-btn" (click)="navigate(-1)" title="Previous">
                                <i class="fa-solid fa-chevron-left"></i>
                            </button>
                            <button type="button" class="nav-btn nav-btn--today" (click)="goToToday()">
                                Today
                            </button>
                            <button type="button" class="nav-btn" (click)="navigate(1)" title="Next">
                                <i class="fa-solid fa-chevron-right"></i>
                            </button>
                            <span class="period-label">{{ headerDateLabel }}</span>
                        </div>
                    </div>

                    <div class="mt-toolbar-right">
                        @if (canEditSchedule) {
                            <button
                                type="button"
                                class="btn-mt btn-mt--secondary"
                                [disabled]="busy"
                                (click)="openScheduleDialog()">
                                <i class="fa-solid fa-calendar-days"></i> Schedule
                            </button>
                        }
                        @if (timesheetApprovalEnabled) {
                            @if (canSubmitPeriod) {
                                <button
                                    type="button"
                                    class="btn-mt btn-mt--primary"
                                    [disabled]="busy"
                                    (click)="onSubmitClicked()">
                                    <i class="fa-solid fa-paper-plane"></i> Submit
                                </button>
                            }
                            @if (canWithdrawPeriod) {
                                <button
                                    type="button"
                                    class="btn-mt btn-mt--warning"
                                    [disabled]="busy"
                                    (click)="onWithdrawClicked()">
                                    <i class="fa-solid fa-rotate-left"></i> Withdraw
                                </button>
                            }
                            @if (canReopenPeriod) {
                                <button
                                    type="button"
                                    class="btn-mt btn-mt--secondary"
                                    [disabled]="busy"
                                    (click)="showReopenDialog = true">
                                    <i class="fa-solid fa-unlock"></i> Reopen
                                </button>
                            }
                        }
                    </div>
                </div>

                @if (errorMessage) {
                    <div class="mt-error" role="alert">{{ errorMessage }}</div>
                }

                <!-- Open-Ended Submit Dialog -->
                @if (showOpenEndedSubmitDialog && activePeriod) {
                    <div class="mt-dialog">
                        <h4 class="mt-dialog-title">Submit Open-Ended Period</h4>
                        <div class="mt-dialog-row">
                            <div class="mt-field">
                                <label>Period Start</label>
                                <input type="date" [value]="activePeriod.PeriodStart" disabled class="mt-input" />
                            </div>
                            <div class="mt-field">
                                <label>Period End *</label>
                                <input type="date" [(ngModel)]="openEndedSubmitEndDate" class="mt-input" />
                            </div>
                        </div>
                        <div class="mt-dialog-actions">
                            <!-- Confirm on LEFT, Cancel on RIGHT -->
                            <button
                                type="button"
                                class="btn-mt btn-mt--primary"
                                [disabled]="busy || !openEndedSubmitEndDate"
                                (click)="confirmOpenEndedSubmit()">
                                {{ busy ? 'Submitting…' : 'Submit Timesheet' }}
                            </button>
                            <button
                                type="button"
                                class="btn-mt btn-mt--secondary"
                                [disabled]="busy"
                                (click)="showOpenEndedSubmitDialog = false">
                                Cancel
                            </button>
                        </div>
                    </div>
                }

                <!-- Reopen Timesheet Dialog -->
                @if (showReopenDialog) {
                    <div class="mt-dialog">
                        <h4 class="mt-dialog-title">Reopen Approved Timesheet</h4>
                        <div class="mt-field">
                            <label>Reason for reopening *</label>
                            <textarea
                                [(ngModel)]="reopenReason"
                                rows="2"
                                placeholder="Explain why this approved timesheet is being reopened..."
                                class="mt-input"></textarea>
                        </div>
                        <div class="mt-dialog-actions">
                            <!-- Confirm on LEFT, Cancel on RIGHT -->
                            <button
                                type="button"
                                class="btn-mt btn-mt--primary"
                                [disabled]="busy || !reopenReason.trim()"
                                (click)="confirmReopenTimesheet()">
                                {{ busy ? 'Reopening…' : 'Reopen Timesheet' }}
                            </button>
                            <button
                                type="button"
                                class="btn-mt btn-mt--secondary"
                                [disabled]="busy"
                                (click)="showReopenDialog = false">
                                Cancel
                            </button>
                        </div>
                    </div>
                }

                <!-- Schedule Configuration Dialog -->
                @if (showScheduleDialog) {
                    <div class="mt-dialog">
                        <h4 class="mt-dialog-title">Timesheet Schedule</h4>
                        <div class="mt-dialog-row">
                            <div class="mt-field">
                                <label>Cadence *</label>
                                <select [(ngModel)]="scheduleForm.Cadence" class="mt-input">
                                    <option value="Weekly">Weekly</option>
                                    <option value="BiWeekly">Bi-Weekly</option>
                                    <option value="SemiMonthly">Semi-Monthly (1st–15th, 16th–end)</option>
                                    <option value="Monthly">Monthly</option>
                                </select>
                            </div>
                            <div class="mt-field">
                                <label>Week Start Day</label>
                                <select [(ngModel)]="scheduleForm.WeekStartDay" class="mt-input">
                                    <option value="Monday">Monday</option>
                                    <option value="Sunday">Sunday</option>
                                    <option value="Saturday">Saturday</option>
                                </select>
                            </div>
                            <div class="mt-field">
                                <label>Effective From *</label>
                                <input type="date" [(ngModel)]="scheduleForm.EffectiveFrom" class="mt-input" />
                            </div>
                            @if (scheduleForm.Cadence === 'BiWeekly') {
                                <div class="mt-field">
                                    <label>Bi-Weekly Anchor Date *</label>
                                    <input type="date" [(ngModel)]="scheduleForm.BiWeeklyAnchorDate" class="mt-input" />
                                </div>
                            }
                        </div>
                        <div class="mt-dialog-actions">
                            <!-- Confirm on LEFT, Cancel on RIGHT -->
                            <button
                                type="button"
                                class="btn-mt btn-mt--primary"
                                [disabled]="busy || !scheduleForm.EffectiveFrom"
                                (click)="saveSchedule()">
                                {{ busy ? 'Saving…' : 'Save Schedule' }}
                            </button>
                            <button
                                type="button"
                                class="btn-mt btn-mt--secondary"
                                [disabled]="busy"
                                (click)="showScheduleDialog = false">
                                Cancel
                            </button>
                        </div>
                    </div>
                }

                <!-- Single-entry Delete Confirmation Banner -->
                @if (pendingDeleteEntryID) {
                    <div class="mt-confirm-banner" role="alertdialog">
                        <span>Delete this time entry?</span>
                        <div class="mt-dialog-actions">
                            <!-- Confirm on LEFT, Cancel on RIGHT -->
                            <button
                                type="button"
                                class="btn-mt btn-mt--danger"
                                [disabled]="busy"
                                (click)="confirmCellEntryDelete()">
                                Delete Entry
                            </button>
                            <button
                                type="button"
                                class="btn-mt btn-mt--secondary"
                                [disabled]="busy"
                                (click)="cancelCellEntryDelete()">
                                Cancel
                            </button>
                        </div>
                    </div>
                }

                <!-- Multi-entry Cell Breakdown Dialog -->
                @if (breakdownCell) {
                    <div class="mt-dialog">
                        <div class="mt-dialog-header">
                            <h4 class="mt-dialog-title">
                                Entries for {{ breakdownCell.TaskLabel }} on {{ breakdownCell.WorkDate }}
                            </h4>
                        </div>
                        <div class="breakdown-list">
                            @for (item of breakdownCell.Entries; track item.ID) {
                                <div class="breakdown-row">
                                    <span class="bd-duration">{{ formatClock(item.DurationMinutes) }}</span>
                                    <span class="bd-source">{{ item.Source }}</span>
                                    <span class="bd-billable">{{ item.IsBillable ? 'Billable' : 'Non-billable' }}</span>
                                    <span class="bd-notes">{{ item.Notes || '—' }}</span>
                                    @if (!isPeriodLocked && !item.IsLocked) {
                                        <button
                                            type="button"
                                            class="btn-icon-danger"
                                            [disabled]="busy"
                                            title="Delete entry"
                                            (click)="deleteEntryAndRefresh(item.ID)">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </button>
                                    }
                                </div>
                            }
                        </div>
                        @if (!isPeriodLocked) {
                            <div class="mt-dialog-row">
                                <div class="mt-field">
                                    <label>Add duration (e.g. 1:00, 45m)</label>
                                    <input
                                        type="text"
                                        [(ngModel)]="breakdownNewDuration"
                                        placeholder="1:00"
                                        class="mt-input" />
                                </div>
                                <div class="mt-field flex-2">
                                    <label>Notes</label>
                                    <input
                                        type="text"
                                        [(ngModel)]="breakdownNewNotes"
                                        placeholder="Optional notes..."
                                        class="mt-input" />
                                </div>
                            </div>
                        }
                        <div class="mt-dialog-actions">
                            <!-- Confirm on LEFT, Cancel on RIGHT -->
                            @if (!isPeriodLocked) {
                                <button
                                    type="button"
                                    class="btn-mt btn-mt--primary"
                                    [disabled]="busy || !breakdownNewDuration.trim()"
                                    (click)="addEntryFromBreakdown()">
                                    Add Entry
                                </button>
                            }
                            <button
                                type="button"
                                class="btn-mt btn-mt--secondary"
                                [disabled]="busy"
                                (click)="breakdownCell = null">
                                Close
                            </button>
                        </div>
                    </div>
                }

                @if (loading) {
                    <mj-loading text="Loading timesheet..." size="medium"></mj-loading>
                } @else {
                    <!-- Main Task × Day Grid -->
                    <div class="mt-grid-wrap">
                        <table class="mt-grid">
                            <thead>
                                <tr>
                                    <th class="col-task">Task</th>
                                    @for (day of displayedDays; track day) {
                                        <th class="col-day" [class.col-day--today]="day === todayIso">
                                            <div class="day-header-top">{{ formatDayWeekday(day) }}</div>
                                            <div class="day-header-sub">{{ formatDayNumber(day) }}</div>
                                        </th>
                                    }
                                    <th class="col-total">Total</th>
                                </tr>
                            </thead>
                            <tbody>
                                @if (rows.length === 0) {
                                    <tr>
                                        <td [attr.colspan]="displayedDays.length + 2" class="empty-grid-cell">
                                            No tasks logged for this {{ viewMode === 'week' ? 'week' : 'period' }} yet.
                                            Use <strong>+ Add a task</strong> below to start logging time.
                                        </td>
                                    </tr>
                                } @else {
                                    @for (row of rows; track row.TaskID) {
                                        <tr>
                                            <td class="col-task">
                                                <div class="task-cell-content">
                                                    @if (row.IsTimerRunning) {
                                                        <span class="running-dot" title="Timer running"></span>
                                                    }
                                                    <button
                                                        type="button"
                                                        class="task-label-btn"
                                                        (click)="openTask(row.TaskID)">
                                                        @if (row.RootTaskName) {
                                                            <span class="root-prefix">{{ row.RootTaskName }} › </span>
                                                        }
                                                        <span class="leaf-name">{{ row.TaskName }}</span>
                                                    </button>
                                                </div>
                                            </td>
                                            @for (day of displayedDays; track day) {
                                                @let cell = row.CellsByDate[day];
                                                <td
                                                    class="col-day"
                                                    [class.col-day--multi]="cell && cell.Entries.length > 1"
                                                    [class.col-day--locked]="isPeriodLocked">
                                                    @if (cell && cell.Entries.length > 1) {
                                                        <button
                                                            type="button"
                                                            class="multi-entry-btn"
                                                            (click)="openBreakdown(row, day)"
                                                            title="Multiple entries — click to view breakdown">
                                                            {{ cell.DisplayValue }}
                                                            <span class="multi-count-badge">{{ cell.Entries.length }}</span>
                                                        </button>
                                                    } @else {
                                                        <input
                                                            type="text"
                                                            class="cell-input"
                                                            [value]="cell?.DisplayValue || ''"
                                                            [disabled]="isPeriodLocked || busy"
                                                            placeholder="—"
                                                            (change)="onCellInputCommit(row, day, $event)" />
                                                    }
                                                </td>
                                            }
                                            <td class="col-total">
                                                <strong>{{ row.RowTotalMinutes > 0 ? formatClock(row.RowTotalMinutes) : '0:00' }}</strong>
                                            </td>
                                        </tr>
                                    }
                                }

                                <!-- + Add a task row -->
                                @if (!isPeriodLocked) {
                                    <tr class="add-task-row">
                                        <td [attr.colspan]="displayedDays.length + 2">
                                            @if (!showAddTaskPicker) {
                                                <button
                                                    type="button"
                                                    class="btn-add-task"
                                                    (click)="openAddTaskPicker()">
                                                    <i class="fa-solid fa-plus"></i> Add a task
                                                </button>
                                            } @else {
                                                <div class="add-task-picker">
                                                    <input
                                                        type="text"
                                                        [(ngModel)]="addTaskSearch"
                                                        placeholder="Search assigned or recent tasks..."
                                                        class="mt-input add-task-search" />
                                                    <select [(ngModel)]="selectedAddTaskID" class="mt-input add-task-select">
                                                        <option value="">Choose a task...</option>
                                                        @for (t of filteredCandidateTasks; track t.ID) {
                                                            <option [value]="t.ID">{{ t.Name }}</option>
                                                        }
                                                    </select>
                                                    <!-- Confirm on LEFT, Cancel on RIGHT -->
                                                    <button
                                                        type="button"
                                                        class="btn-mt btn-mt--primary"
                                                        [disabled]="!selectedAddTaskID"
                                                        (click)="confirmAddTaskRow()">
                                                        Add Row
                                                    </button>
                                                    <button
                                                        type="button"
                                                        class="btn-mt btn-mt--secondary"
                                                        (click)="showAddTaskPicker = false">
                                                        Cancel
                                                    </button>
                                                </div>
                                            }
                                        </td>
                                    </tr>
                                }
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td class="col-task"><strong>Total</strong></td>
                                    @for (day of displayedDays; track day) {
                                        @let dayMin = dayTotals[day] || 0;
                                        <td
                                            class="col-day"
                                            [class.col-day--warning]="dayMin > maxDailyLoggedMinutes"
                                            [title]="dayMin > maxDailyLoggedMinutes ? 'Exceeds daily warning threshold' : ''">
                                            <strong>{{ dayMin > 0 ? formatClock(dayMin) : '—' }}</strong>
                                            @if (dayMin > maxDailyLoggedMinutes) {
                                                <i class="fa-solid fa-triangle-exclamation warning-icon"></i>
                                            }
                                        </td>
                                    }
                                    <td class="col-total">
                                        <strong>{{ formatClock(grandTotalMinutes) }}</strong>
                                    </td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>

                    <!-- Status Bar (§6.5, §8.4) -->
                    <div class="mt-status-bar">
                        <div class="status-left">
                            @if (timesheetApprovalEnabled) {
                                <div class="status-headline">
                                    <strong>Status:</strong>
                                    <span class="status-pill" [class]="'status-pill--' + statusBadgeKey">
                                        {{ statusHeadline }}
                                    </span>
                                </div>
                                @if (partStatusLines.length > 0) {
                                    <div class="part-status-list">
                                        @for (line of partStatusLines; track line.ScopeLabel) {
                                            <div class="part-status-item">
                                                <i [class]="line.IconClass"></i>
                                                <span><strong>{{ line.ScopeLabel }}:</strong> {{ line.StatusText }}</span>
                                            </div>
                                        }
                                    </div>
                                }
                            }
                        </div>
                        <div class="status-right">
                            <span>Billable <strong>{{ formatClock(grandBillableMinutes) }}</strong></span>
                            <span>·</span>
                            <span>Non-billable <strong>{{ formatClock(grandNonBillableMinutes) }}</strong></span>
                        </div>
                    </div>
                }
            </div>
        }
    `,
    styles: [`
        :host {
            display: block;
            font-family: var(--mj-font-family);
        }
        .my-time-disabled {
            padding: 48px 24px;
            text-align: center;
            color: var(--mj-text-muted);
        }
        .my-time-disabled i {
            font-size: 32px;
            margin-bottom: 12px;
            display: block;
        }
        .my-time-root {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }
        .mt-toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
        }
        .mt-toolbar-left,
        .mt-toolbar-right {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }
        .view-mode-toggle {
            display: inline-flex;
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md);
            padding: 2px;
        }
        .toggle-btn {
            padding: 5px 12px;
            border: none;
            border-radius: var(--mj-radius-sm);
            background: transparent;
            color: var(--mj-text-secondary);
            font-size: 13px;
            font-weight: var(--mj-font-semibold);
            font-family: inherit;
            cursor: pointer;
        }
        .toggle-btn--active {
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            box-shadow: var(--mj-shadow-sm);
        }
        .period-nav {
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .nav-btn {
            padding: 6px 10px;
            border-radius: var(--mj-radius-sm);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-secondary);
            font-size: 12px;
            font-family: inherit;
            cursor: pointer;
        }
        .nav-btn:hover {
            border-color: var(--mj-brand-primary);
            color: var(--mj-brand-primary);
        }
        .period-label {
            font-size: 14px;
            font-weight: var(--mj-font-bold);
            color: var(--mj-text-primary);
            margin-left: 4px;
        }
        .btn-mt {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 14px;
            border-radius: var(--mj-radius-md);
            font-size: 13px;
            font-weight: var(--mj-font-semibold);
            font-family: inherit;
            cursor: pointer;
            border: 1px solid var(--mj-border-default);
        }
        .btn-mt:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .btn-mt--primary {
            background: var(--mj-brand-primary);
            border-color: var(--mj-brand-primary);
            color: var(--mj-text-inverse);
        }
        .btn-mt--secondary {
            background: var(--mj-bg-surface);
            color: var(--mj-text-secondary);
        }
        .btn-mt--warning {
            background: var(--mj-status-warning);
            border-color: var(--mj-status-warning);
            color: var(--mj-text-inverse);
        }
        .btn-mt--danger {
            background: var(--mj-status-error);
            border-color: var(--mj-status-error);
            color: var(--mj-text-inverse);
        }
        .mt-error {
            padding: 10px 12px;
            border-radius: var(--mj-radius-md);
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
            border: 1px solid var(--mj-status-error-border);
            font-size: 13px;
        }
        .mt-dialog,
        .mt-confirm-banner {
            padding: 14px;
            border-radius: var(--mj-radius-md);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            box-shadow: var(--mj-shadow-sm);
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .mt-confirm-banner {
            flex-direction: row;
            justify-content: space-between;
            align-items: center;
            background: var(--mj-status-warning-bg);
            border-color: var(--mj-status-warning-border);
        }
        .mt-dialog-title {
            margin: 0;
            font-size: 14px;
            font-weight: var(--mj-font-bold);
            color: var(--mj-text-primary);
        }
        .mt-dialog-row {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .mt-field {
            flex: 1;
            min-width: 150px;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .mt-field.flex-2 {
            flex: 2;
        }
        .mt-field label {
            font-size: 11px;
            font-weight: var(--mj-font-semibold);
            color: var(--mj-text-muted);
        }
        .mt-input {
            padding: 6px 10px;
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-sm);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-size: 13px;
            font-family: inherit;
        }
        .mt-dialog-actions {
            display: flex;
            gap: 8px;
        }
        .breakdown-list {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .breakdown-row {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 6px 10px;
            border-radius: var(--mj-radius-sm);
            background: var(--mj-bg-surface-sunken);
            font-size: 12px;
        }
        .bd-duration {
            font-weight: var(--mj-font-bold);
            color: var(--mj-brand-primary);
        }
        .bd-source,
        .bd-billable {
            color: var(--mj-text-muted);
        }
        .bd-notes {
            flex: 1;
            color: var(--mj-text-primary);
        }
        .btn-icon-danger {
            border: none;
            background: transparent;
            color: var(--mj-status-error);
            cursor: pointer;
        }
        .mt-grid-wrap {
            overflow-x: auto;
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-lg);
            background: var(--mj-bg-surface);
            box-shadow: var(--mj-shadow-sm);
        }
        .mt-grid {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            font-variant-numeric: tabular-nums;
        }
        .mt-grid th,
        .mt-grid td {
            padding: 8px 10px;
            border-bottom: 1px solid var(--mj-border-subtle);
        }
        .mt-grid thead th {
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-secondary);
            font-weight: var(--mj-font-bold);
            font-size: 11px;
            text-transform: uppercase;
        }
        .col-task {
            text-align: left;
            min-width: 240px;
        }
        .col-day {
            text-align: center;
            min-width: 72px;
        }
        .col-day--today {
            background: color-mix(in srgb, var(--mj-brand-primary) 6%, var(--mj-bg-surface-sunken));
        }
        .col-day--warning {
            color: var(--mj-status-warning-text);
            background: var(--mj-status-warning-bg);
        }
        .col-total {
            text-align: right;
            min-width: 80px;
            background: color-mix(in srgb, var(--mj-brand-primary) 4%, var(--mj-bg-surface));
        }
        .day-header-top {
            font-size: 11px;
        }
        .day-header-sub {
            font-size: 12px;
            color: var(--mj-text-primary);
        }
        .task-cell-content {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .running-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--mj-status-success);
            flex-shrink: 0;
        }
        .task-label-btn {
            border: none;
            background: transparent;
            color: var(--mj-text-primary);
            font-size: 13px;
            font-family: inherit;
            text-align: left;
            cursor: pointer;
            padding: 0;
        }
        .task-label-btn:hover .leaf-name {
            color: var(--mj-brand-primary);
            text-decoration: underline;
        }
        .root-prefix {
            color: var(--mj-text-muted);
            font-size: 12px;
        }
        .leaf-name {
            font-weight: var(--mj-font-semibold);
        }
        .cell-input {
            width: 64px;
            padding: 5px 6px;
            text-align: center;
            border: 1px solid transparent;
            border-radius: var(--mj-radius-sm);
            background: transparent;
            color: var(--mj-text-primary);
            font-size: 13px;
            font-family: inherit;
            font-variant-numeric: tabular-nums;
        }
        .cell-input:hover:not(:disabled) {
            border-color: var(--mj-border-default);
            background: var(--mj-bg-surface-sunken);
        }
        .cell-input:focus {
            outline: none;
            border-color: var(--mj-brand-primary);
            background: var(--mj-bg-surface);
        }
        .multi-entry-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
            padding: 4px 8px;
            border-radius: var(--mj-radius-sm);
            border: 1px solid color-mix(in srgb, var(--mj-brand-primary) 35%, var(--mj-border-default));
            background: color-mix(in srgb, var(--mj-brand-primary) 8%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
            font-size: 12px;
            font-weight: var(--mj-font-bold);
            font-family: inherit;
            cursor: pointer;
        }
        .multi-count-badge {
            font-size: 10px;
            padding: 0 4px;
            border-radius: 999px;
            background: var(--mj-brand-primary);
            color: var(--mj-text-inverse);
        }
        .empty-grid-cell {
            padding: 28px;
            text-align: center;
            color: var(--mj-text-muted);
        }
        .add-task-row td {
            padding: 8px 12px;
        }
        .btn-add-task {
            border: none;
            background: transparent;
            color: var(--mj-brand-primary);
            font-size: 13px;
            font-weight: var(--mj-font-semibold);
            font-family: inherit;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 0;
        }
        .btn-add-task:hover {
            text-decoration: underline;
        }
        .add-task-picker {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .add-task-search {
            width: 200px;
        }
        .add-task-select {
            min-width: 240px;
        }
        .warning-icon {
            margin-left: 4px;
            color: var(--mj-status-warning);
            font-size: 11px;
        }
        .mt-status-bar {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 12px;
            padding: 12px 16px;
            border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            font-size: 13px;
        }
        .status-left {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .status-headline {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .status-pill {
            padding: 2px 8px;
            border-radius: var(--mj-radius-sm);
            font-size: 12px;
            font-weight: var(--mj-font-semibold);
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-secondary);
        }
        .status-pill--submitted {
            background: var(--mj-status-info-bg);
            color: var(--mj-status-info-text);
        }
        .status-pill--approved {
            background: var(--mj-status-success-bg);
            color: var(--mj-status-success-text);
        }
        .status-pill--returned {
            background: var(--mj-status-warning-bg);
            color: var(--mj-status-warning-text);
        }
        .part-status-list {
            display: flex;
            flex-direction: column;
            gap: 4px;
            font-size: 12px;
            color: var(--mj-text-secondary);
        }
        .part-status-item {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .status-right {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--mj-text-secondary);
            font-variant-numeric: tabular-nums;
        }
    `],
})
export class MyTimeComponent implements OnInit {
    private _personID = '';
    private timeTracking = new TimeTrackingService();

    /**
     * Person ID whose weekly/period timesheet is shown.
     */
    @Input()
    public get PersonID(): string {
        return this._personID;
    }
    public set PersonID(value: string) {
        const changed = value !== this._personID;
        this._personID = value;
        if (changed && this.initialized) {
            void this.Refresh();
        }
    }

    public timeTrackingEnabled = false;
    public timesheetApprovalEnabled = false;
    public schedulesSelfService = false;
    public canManageTimesheets = false;
    public canManageEntries = false;
    public maxDailyLoggedMinutes = 960;

    public viewMode: 'week' | 'period' = 'week';
    public todayIso: CalendarDay = (ToCalendarDay(new Date()) ?? '2026-01-01') as CalendarDay;
    public cursorDateIso: CalendarDay = (ToCalendarDay(new Date()) ?? '2026-01-01') as CalendarDay;

    public loading = false;
    public busy = false;
    public errorMessage = '';

    public activePeriod: (TimesheetPeriodBounds & { IsOpenEnded?: boolean }) | null = null;
    public displayedDays: string[] = [];
    public rows: MyTimeTaskRow[] = [];
    public dayTotals: Record<string, number> = {};
    public grandTotalMinutes = 0;
    public grandBillableMinutes = 0;
    public grandNonBillableMinutes = 0;

    // Active timesheet & parts for the current period
    public activeTimesheet: {
        ID: string;
        PeriodStart: string;
        PeriodEnd: string;
        Status: string;
        SubmissionRound: number;
        ApprovedAt: string | null;
        ReopenReason: string | null;
    } | null = null;
    public activeParts: Array<{
        ID: string;
        ScopeLabel: string;
        Status: string;
        DecidedAt: string | null;
        DecisionNotes: string | null;
    }> = [];

    // Extra task IDs pinned by "+ Add a task" in the current session
    public pinnedTaskIDs: string[] = [];
    public showAddTaskPicker = false;
    public addTaskSearch = '';
    public selectedAddTaskID = '';
    public candidateTasks: TaskLookupItem[] = [];

    // Single-entry delete confirmation
    public pendingDeleteEntryID: string | null = null;

    // Multi-entry breakdown dialog
    public breakdownCell: {
        TaskID: string;
        TaskLabel: string;
        WorkDate: string;
        Entries: MyTimeCellEntry[];
    } | null = null;
    public breakdownNewDuration = '1:00';
    public breakdownNewNotes = '';

    // Open-ended submit dialog
    public showOpenEndedSubmitDialog = false;
    public openEndedSubmitEndDate: string = this.todayIso;

    // Reopen dialog
    public showReopenDialog = false;
    public reopenReason = '';

    // Schedule dialog
    public showScheduleDialog = false;
    public scheduleForm: {
        Cadence: TimesheetCadence;
        WeekStartDay: mjBizAppsTasksTimesheetScheduleEntity['WeekStartDay'];
        BiWeeklyAnchorDate: string;
        EffectiveFrom: string;
    } = {
        Cadence: 'Weekly',
        WeekStartDay: 'Monday',
        BiWeeklyAnchorDate: '2026-01-05',
        EffectiveFrom: this.todayIso,
    };

    private initialized = false;
    private cdr = inject(ChangeDetectorRef);

    public get isPeriodLocked(): boolean {
        const status = this.activeTimesheet?.Status;
        return status === 'Submitted' || status === 'Approved';
    }

    public get canSubmitPeriod(): boolean {
        if (!this.timesheetApprovalEnabled || !this.activePeriod) {
            return false;
        }
        return !this.isPeriodLocked;
    }

    public get canWithdrawPeriod(): boolean {
        return this.timesheetApprovalEnabled && this.activeTimesheet?.Status === 'Submitted';
    }

    public get canReopenPeriod(): boolean {
        return (
            this.timesheetApprovalEnabled &&
            this.canManageTimesheets &&
            this.activeTimesheet?.Status === 'Approved'
        );
    }

    public get canEditSchedule(): boolean {
        return this.timesheetApprovalEnabled && (this.schedulesSelfService || this.canManageTimesheets);
    }

    public get headerDateLabel(): string {
        if (this.displayedDays.length === 0) {
            return this.cursorDateIso;
        }
        const first = this.displayedDays[0];
        const last = this.displayedDays[this.displayedDays.length - 1];
        if (this.viewMode === 'week') {
            return `Week of ${this.formatReadableDate(first)}`;
        }
        return `${this.formatReadableDate(first)} – ${this.formatReadableDate(last)}`;
    }

    public get statusBadgeKey(): string {
        const st = this.activeTimesheet?.Status;
        if (st === 'Submitted') return 'submitted';
        if (st === 'Approved') return 'approved';
        if (st === 'Rejected' || st === 'Returned') return 'returned';
        return 'draft';
    }

    public get statusHeadline(): string {
        if (!this.activeTimesheet || this.activeTimesheet.Status === 'Draft') {
            return 'Not submitted';
        }
        if (this.activeTimesheet.Status === 'Submitted') {
            return 'Submitted';
        }
        if (this.activeTimesheet.Status === 'Approved') {
            return this.activeTimesheet.ApprovedAt
                ? `Approved ${this.activeTimesheet.ApprovedAt}`
                : 'Approved';
        }
        if (this.activeTimesheet.Status === 'Rejected' || this.activeTimesheet.Status === 'Returned') {
            const rejectedPart = this.activeParts.find((p) => p.Status === 'Rejected');
            if (rejectedPart) {
                const notesSuffix = rejectedPart.DecisionNotes ? ` — "${rejectedPart.DecisionNotes}"` : '';
                return `Returned by ${rejectedPart.ScopeLabel}${notesSuffix}`;
            }
            if (this.activeTimesheet.ReopenReason) {
                return `Reopened — "${this.activeTimesheet.ReopenReason}"`;
            }
            return 'Withdrawn / Returned';
        }
        return this.activeTimesheet.Status;
    }

    public get partStatusLines(): Array<{ ScopeLabel: string; StatusText: string; IconClass: string }> {
        if (this.activeTimesheet?.Status !== 'Submitted') {
            return [];
        }
        return this.activeParts.map((part) => {
            if (part.Status === 'Approved') {
                return {
                    ScopeLabel: part.ScopeLabel,
                    StatusText: 'Approved',
                    IconClass: 'fa-solid fa-circle-check',
                };
            }
            return {
                ScopeLabel: part.ScopeLabel,
                StatusText: 'Waiting for approval',
                IconClass: 'fa-regular fa-clock',
            };
        });
    }

    public get filteredCandidateTasks(): TaskLookupItem[] {
        const q = this.addTaskSearch.trim().toLowerCase();
        const existingIDs = new Set(this.rows.map((r) => r.TaskID.toLowerCase()));
        return this.candidateTasks.filter(
            (t) =>
                !existingIDs.has(t.ID.toLowerCase()) &&
                (!q || t.Name.toLowerCase().includes(q)),
        );
    }

    public ngOnInit(): void {
        this.initialized = true;
        void this.Refresh();
    }

    public setViewMode(mode: 'week' | 'period'): void {
        if (this.viewMode === mode) {
            return;
        }
        this.viewMode = mode;
        void this.Refresh();
    }

    public navigate(direction: -1 | 1): void {
        if (this.viewMode === 'week') {
            this.cursorDateIso = AddDays(this.cursorDateIso, direction * 7);
        } else if (this.activePeriod) {
            this.cursorDateIso =
                direction < 0
                    ? AddDays(this.activePeriod.PeriodStart, -1)
                    : AddDays(this.activePeriod.PeriodEnd, 1);
        } else {
            this.cursorDateIso = AddDays(this.cursorDateIso, direction * 7);
        }
        void this.Refresh();
    }

    public goToToday(): void {
        this.cursorDateIso = this.todayIso;
        void this.Refresh();
    }

    /**
     * Loads the person's week/period in a single `RunViews` batch (§8.4).
     */
    public async Refresh(): Promise<void> {
        this.errorMessage = '';
        this.pendingDeleteEntryID = null;

        const provider = Metadata.Provider;
        try {
            await TasksSettings.Load(provider);
        } catch {
            // Fall back to cached / default settings
        }
        this.timeTrackingEnabled = TasksSettings.TimeTrackingEnabled(provider);
        if (!this.timeTrackingEnabled || !this._personID) {
            this.loading = false;
            this.cdr.markForCheck();
            return;
        }

        this.loading = true;
        this.cdr.markForCheck();

        try {
            this.timesheetApprovalEnabled = TasksSettings.TimesheetApprovalEnabled(provider);
            this.schedulesSelfService = TasksSettings.TimesheetSchedulesSelfService(provider);
            this.canManageTimesheets = UserCanManageTimesheets(provider.CurrentUser, provider);
            this.canManageEntries = UserCanManageTimeEntries(provider.CurrentUser, provider);
            this.maxDailyLoggedMinutes = TasksSettings.MaxDailyLoggedMinutes(provider);

            const defaultCadence = TasksSettings.TimesheetCadence(provider);
            const defaultWeekStart = TasksSettings.TimesheetWeekStartDay(provider);
            const defaultAnchor = TasksSettings.TimesheetBiWeeklyAnchorDate(provider);

            // Broad window around cursorDateIso to cover both week and monthly/open-ended periods in one batch
            const windowStart = AddDays(this.cursorDateIso, -40);
            const windowEnd = AddDays(this.cursorDateIso, 40);

            const rv = new RunView();
            const batchResults = await rv.RunViews([
                {
                    EntityName: 'MJ_BizApps_Tasks: Task Time Entries',
                    ExtraFilter: `PersonID = '${this._personID}' AND WorkDate >= '${windowStart}' AND WorkDate <= '${windowEnd}'`,
                    OrderBy: 'WorkDate ASC, __mj_CreatedAt ASC',
                    ResultType: 'simple',
                },
                {
                    EntityName: 'MJ_BizApps_Tasks: Task Timers',
                    ExtraFilter: `PersonID = '${this._personID}'`,
                    ResultType: 'simple',
                    MaxRows: 1,
                },
                {
                    EntityName: 'MJ_BizApps_Tasks: Timesheet Schedules',
                    ExtraFilter: `PersonID IS NULL OR PersonID = '${this._personID}'`,
                    OrderBy: 'EffectiveFrom ASC',
                    ResultType: 'simple',
                },
                {
                    EntityName: 'MJ_BizApps_Tasks: Timesheets',
                    ExtraFilter: `PersonID = '${this._personID}'`,
                    OrderBy: 'PeriodStart ASC',
                    ResultType: 'simple',
                },
            ]);

            const rawEntries = (batchResults[0]?.Results ?? []) as Array<{
                ID: string;
                TaskID: string;
                Task: string | null;
                WorkDate: string | Date;
                Minutes: number;
                IsBillable: boolean;
                Notes: string | null;
                Source: mjBizAppsTasksTaskTimeEntryEntity['Source'];
                TimesheetID: string | null;
            }>;
            const rawTimers = (batchResults[1]?.Results ?? []) as Array<{
                ID: string;
                TaskID: string;
                Task: string | null;
            }>;
            const rawSchedules = (batchResults[2]?.Results ?? []) as Array<{
                ID: string;
                PersonID: string | null;
                ScopeEntityID: string | null;
                ScopeRecordID: string | null;
                Cadence: TimesheetCadence;
                WeekStartDay: mjBizAppsTasksTimesheetScheduleEntity['WeekStartDay'];
                BiWeeklyAnchorDate: string | Date;
                EffectiveFrom: string | Date;
                EffectiveTo: string | Date | null;
            }>;
            const rawTimesheets = (batchResults[3]?.Results ?? []) as Array<{
                ID: string;
                PeriodStart: string | Date;
                PeriodEnd: string | Date;
                Status: string;
                SubmissionRound: number;
                ApprovedAt: string | Date | null;
                ReopenReason: string | null;
            }>;

            const scheduleCandidates: EffectiveScheduleCandidate[] = rawSchedules.map((s) => ({
                ID: s.ID,
                PersonID: s.PersonID,
                ScopeEntityID: s.ScopeEntityID,
                ScopeRecordID: s.ScopeRecordID,
                Cadence: s.Cadence,
                WeekStartDay: s.WeekStartDay,
                BiWeeklyAnchorDate: s.BiWeeklyAnchorDate,
                EffectiveFrom: s.EffectiveFrom,
                EffectiveTo: s.EffectiveTo,
            }));

            const matchedSched = ResolveScheduleForDate(this.cursorDateIso, scheduleCandidates, this._personID);
            const submittedPriorEnds = rawTimesheets
                .filter((ts) => ts.Status === 'Submitted' || ts.Status === 'Approved')
                .map((ts) => this.toIsoDate(ts.PeriodEnd))
                .filter((endStr) => CompareDays(endStr, this.cursorDateIso) < 0)
                .sort((a, b) => CompareDays(b, a));
            const lastSubmittedEnd = submittedPriorEnds[0] ?? null;

            const effectiveCadence: TimesheetPeriodType = matchedSched?.Cadence ?? defaultCadence;
            const effectiveWeekStart = matchedSched?.WeekStartDay ?? defaultWeekStart;
            const effectiveAnchor = matchedSched?.BiWeeklyAnchorDate ?? defaultAnchor;

            const computedPeriod = PeriodFor(this.cursorDateIso, {
                Cadence: effectiveCadence,
                WeekStartDay: effectiveWeekStart,
                BiWeeklyAnchorDate: effectiveAnchor,
                LastSubmittedPeriodEnd: lastSubmittedEnd,
            });
            this.activePeriod = {
                ...computedPeriod,
                IsOpenEnded: computedPeriod.Cadence === 'OpenEnded',
            };

            // Compute displayedDays
            const weekPeriod = PeriodFor(this.cursorDateIso, {
                Cadence: 'Weekly',
                WeekStartDay: effectiveWeekStart,
            });
            const rangeStart = this.viewMode === 'week' ? weekPeriod.PeriodStart : computedPeriod.PeriodStart;
            const rangeEnd = this.viewMode === 'week' ? weekPeriod.PeriodEnd : computedPeriod.PeriodEnd;
            this.displayedDays = this.enumerateDays(rangeStart, rangeEnd, 31);

            // Match timesheet for computedPeriod
            const matchedTs = rawTimesheets.find(
                (ts) =>
                    this.toIsoDate(ts.PeriodStart) === computedPeriod.PeriodStart &&
                    (computedPeriod.Cadence === 'OpenEnded' || this.toIsoDate(ts.PeriodEnd) === computedPeriod.PeriodEnd),
            );
            this.activeTimesheet = matchedTs
                ? {
                      ID: matchedTs.ID,
                      PeriodStart: this.toIsoDate(matchedTs.PeriodStart),
                      PeriodEnd: this.toIsoDate(matchedTs.PeriodEnd),
                      Status: matchedTs.Status,
                      SubmissionRound: matchedTs.SubmissionRound,
                      ApprovedAt: matchedTs.ApprovedAt ? this.toIsoDate(matchedTs.ApprovedAt) : null,
                      ReopenReason: matchedTs.ReopenReason,
                  }
                : null;

            if (this.activeTimesheet) {
                const partsRes = await rv.RunView<{
                    ID: string;
                    ScopeLabel: string | null;
                    Status: string;
                    DecidedAt: string | Date | null;
                    DecisionNotes: string | null;
                }>({
                    EntityName: 'MJ_BizApps_Tasks: Timesheet Approvals',
                    ExtraFilter: `TimesheetID = '${this.activeTimesheet.ID}' AND SubmissionRound = ${this.activeTimesheet.SubmissionRound}`,
                    OrderBy: 'ScopeLabel ASC',
                    ResultType: 'simple',
                });
                this.activeParts = (partsRes.Results ?? []).map((p) => ({
                    ID: p.ID,
                    ScopeLabel: p.ScopeLabel || 'Timesheet Part',
                    Status: p.Status,
                    DecidedAt: p.DecidedAt ? this.toIsoDate(p.DecidedAt) : null,
                    DecisionNotes: p.DecisionNotes,
                }));
            } else {
                this.activeParts = [];
            }

            // Filter entries to displayedDays
            const displayedSet = new Set(this.displayedDays);
            const entriesInView = rawEntries.filter((e) => displayedSet.has(this.toIsoDate(e.WorkDate)));

            // Gather all task IDs (entries + active timer + pinned tasks)
            const activeTimerTaskID = rawTimers[0]?.TaskID ?? null;
            const allTaskIDs = Array.from(
                new Set([
                    ...entriesInView.map((e) => e.TaskID),
                    ...(activeTimerTaskID ? [activeTimerTaskID] : []),
                    ...this.pinnedTaskIDs,
                ]),
            );

            await this.buildGridRows(allTaskIDs, entriesInView, activeTimerTaskID, rv);
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Failed to load My Time grid.';
        } finally {
            this.loading = false;
            this.cdr.markForCheck();
        }
    }

    public async onCellInputCommit(row: MyTimeTaskRow, workDate: string, event: Event): Promise<void> {
        const inputEl = event.target as HTMLInputElement;
        const cell = row.CellsByDate[workDate] ?? { Entries: [], TotalMinutes: 0, DisplayValue: '' };
        const action = ResolveGridCellAction(cell.Entries, inputEl.value, this.isPeriodLocked);

        switch (action.kind) {
            case 'no-op':
                inputEl.value = cell.DisplayValue;
                return;
            case 'invalid':
                this.errorMessage = action.message;
                inputEl.value = cell.DisplayValue;
                this.cdr.markForCheck();
                return;
            case 'locked':
                this.errorMessage = action.reason;
                inputEl.value = cell.DisplayValue;
                this.cdr.markForCheck();
                return;
            case 'confirm-delete':
                this.pendingDeleteEntryID = action.entryID;
                inputEl.value = cell.DisplayValue;
                this.cdr.markForCheck();
                return;
            case 'open-breakdown':
                this.openBreakdown(row, workDate);
                inputEl.value = cell.DisplayValue;
                this.cdr.markForCheck();
                return;
            case 'create':
                await this.createManualCellEntry(row.TaskID, workDate, action.durationMinutes);
                return;
            case 'update':
                await this.updateSingleCellEntry(action.entryID, action.durationMinutes);
                return;
        }
    }

    public openBreakdown(row: MyTimeTaskRow, workDate: string): void {
        const cell = row.CellsByDate[workDate];
        if (!cell) {
            return;
        }
        this.breakdownCell = {
            TaskID: row.TaskID,
            TaskLabel: row.DisplayLabel,
            WorkDate: workDate,
            Entries: cell.Entries,
        };
        this.breakdownNewDuration = '1:00';
        this.breakdownNewNotes = '';
        this.cdr.markForCheck();
    }

    public async addEntryFromBreakdown(): Promise<void> {
        if (!this.breakdownCell || this.busy) {
            return;
        }
        const minutes = ParseDurationMinutes(this.breakdownNewDuration);
        if (minutes === null) {
            this.errorMessage = 'Enter a valid duration such as "1:00" or "45m".';
            this.cdr.markForCheck();
            return;
        }
        const { TaskID, WorkDate } = this.breakdownCell;
        const notes = this.breakdownNewNotes.trim() || null;
        this.breakdownCell = null;
        await this.createManualCellEntry(TaskID, WorkDate, minutes, notes);
    }

    public async confirmCellEntryDelete(): Promise<void> {
        if (!this.pendingDeleteEntryID) {
            return;
        }
        const id = this.pendingDeleteEntryID;
        this.pendingDeleteEntryID = null;
        await this.deleteEntryAndRefresh(id);
    }

    public cancelCellEntryDelete(): void {
        this.pendingDeleteEntryID = null;
        this.cdr.markForCheck();
    }

    public async deleteEntryAndRefresh(entryID: string): Promise<void> {
        if (this.busy) {
            return;
        }
        this.busy = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const md = new Metadata();
            const entity = await md.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                'MJ_BizApps_Tasks: Task Time Entries',
            );
            const loaded = await entity.InnerLoad(CompositeKey.FromID(entryID));
            if (loaded) {
                const deleted = await entity.Delete();
                if (!deleted) {
                    throw new Error(entity.LatestResult?.CompleteMessage || 'Could not delete time entry.');
                }
            }
            this.breakdownCell = null;
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not delete time entry.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async openAddTaskPicker(): Promise<void> {
        this.showAddTaskPicker = true;
        this.addTaskSearch = '';
        this.selectedAddTaskID = '';
        this.cdr.markForCheck();

        if (this.candidateTasks.length === 0) {
            const rv = new RunView();
            const res = await rv.RunView<TaskLookupItem>({
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                ExtraFilter: `Status NOT IN ('Cancelled')`,
                OrderBy: 'Name ASC',
                Fields: ['ID', 'Name', 'RootParentID'],
                MaxRows: 200,
                ResultType: 'simple',
            });
            this.candidateTasks = res.Results ?? [];
            this.cdr.markForCheck();
        }
    }

    public confirmAddTaskRow(): void {
        if (!this.selectedAddTaskID) {
            return;
        }
        if (!this.pinnedTaskIDs.some((id) => UUIDsEqual(id, this.selectedAddTaskID))) {
            this.pinnedTaskIDs.push(this.selectedAddTaskID);
        }
        this.showAddTaskPicker = false;
        void this.Refresh();
    }

    public async onSubmitClicked(): Promise<void> {
        if (!this.activePeriod || this.busy) {
            return;
        }
        if (this.activePeriod.IsOpenEnded) {
            this.openEndedSubmitEndDate = this.todayIso;
            this.showOpenEndedSubmitDialog = true;
            this.cdr.markForCheck();
            return;
        }
        await this.executeSubmit(this.activePeriod.PeriodStart, this.activePeriod.PeriodEnd);
    }

    public async confirmOpenEndedSubmit(): Promise<void> {
        if (!this.activePeriod || !this.openEndedSubmitEndDate || this.busy) {
            return;
        }
        this.showOpenEndedSubmitDialog = false;
        await this.executeSubmit(this.activePeriod.PeriodStart, this.openEndedSubmitEndDate);
    }

    public async onWithdrawClicked(): Promise<void> {
        if (!this.activeTimesheet || this.busy) {
            return;
        }
        this.busy = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const res = await this.timeTracking.WithdrawTimesheet({
                TimesheetID: this.activeTimesheet.ID,
            });
            if (!res.Success) {
                throw new Error(res.ErrorMessage || 'Could not withdraw timesheet.');
            }
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not withdraw timesheet.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async confirmReopenTimesheet(): Promise<void> {
        if (!this.activeTimesheet || !this.reopenReason.trim() || this.busy) {
            return;
        }
        this.busy = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const res = await this.timeTracking.ReopenTimesheet({
                TimesheetID: this.activeTimesheet.ID,
                Reason: this.reopenReason.trim(),
            });
            if (!res.Success) {
                throw new Error(res.ErrorMessage || 'Could not reopen timesheet.');
            }
            this.showReopenDialog = false;
            this.reopenReason = '';
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not reopen timesheet.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public openScheduleDialog(): void {
        this.showScheduleDialog = true;
        if (this.activePeriod) {
            if (this.activePeriod.Cadence !== 'OpenEnded') {
                this.scheduleForm.Cadence = this.activePeriod.Cadence;
            }
            this.scheduleForm.EffectiveFrom = AddDays(this.activePeriod.PeriodEnd, 1);
        }
        this.cdr.markForCheck();
    }

    public async saveSchedule(): Promise<void> {
        if (!this._personID || !this.scheduleForm.EffectiveFrom || this.busy) {
            return;
        }
        this.busy = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const md = new Metadata();
            const entity = await md.GetEntityObject<mjBizAppsTasksTimesheetScheduleEntity>(
                'MJ_BizApps_Tasks: Timesheet Schedules',
            );
            entity.NewRecord();
            entity.PersonID = this._personID;
            entity.Cadence = this.scheduleForm.Cadence;
            entity.WeekStartDay = this.scheduleForm.WeekStartDay;
            entity.EffectiveFrom = new Date(`${this.scheduleForm.EffectiveFrom}T00:00:00.000Z`);
            entity.BiWeeklyAnchorDate = new Date(
                `${this.scheduleForm.BiWeeklyAnchorDate || '2026-01-05'}T00:00:00.000Z`,
            );

            const saved = await entity.Save();
            if (!saved) {
                throw new Error(entity.LatestResult?.CompleteMessage || 'Could not save timesheet schedule.');
            }
            this.showScheduleDialog = false;
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not save timesheet schedule.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public openTask(taskID: string): void {
        OpenTaskRecord(taskID);
    }

    public formatClock(minutes: number): string {
        return FormatDurationClock(minutes) || '0:00';
    }

    public formatDayWeekday(isoDate: string): string {
        const d = new Date(`${isoDate}T00:00:00.000Z`);
        return Number.isNaN(d.getTime())
            ? isoDate
            : d.toLocaleDateString('en-US', { weekday: 'short', timeZone: 'UTC' });
    }

    public formatDayNumber(isoDate: string): string {
        const d = new Date(`${isoDate}T00:00:00.000Z`);
        return Number.isNaN(d.getTime())
            ? ''
            : d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', timeZone: 'UTC' });
    }

    private formatReadableDate(isoDate: string): string {
        const d = new Date(`${isoDate}T00:00:00.000Z`);
        return Number.isNaN(d.getTime())
            ? isoDate
            : d.toLocaleDateString('en-US', {
                  day: 'numeric',
                  month: 'short',
                  year: 'numeric',
                  timeZone: 'UTC',
              });
    }

    private async executeSubmit(periodStart: string, periodEnd: string | undefined): Promise<void> {
        this.busy = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const res = await this.timeTracking.SubmitTimesheet({
                PeriodStart: periodStart,
                PeriodEnd: periodEnd,
            });
            if (!res.Success) {
                throw new Error(res.ErrorMessage || 'Could not submit timesheet.');
            }
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not submit timesheet.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    private async createManualCellEntry(
        taskID: string,
        workDate: string,
        durationMinutes: number,
        notes: string | null = null,
    ): Promise<void> {
        if (!this._personID || this.busy) {
            return;
        }
        this.busy = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const md = new Metadata();
            const entity = await md.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                'MJ_BizApps_Tasks: Task Time Entries',
            );
            entity.NewRecord();
            entity.TaskID = taskID;
            entity.PersonID = this._personID;
            entity.WorkDate = new Date(`${workDate}T00:00:00.000Z`);
            entity.Minutes = durationMinutes;
            entity.IsBillable = true;
            entity.Source = 'Manual';
            entity.Notes = notes;

            const saved = await entity.Save();
            if (!saved) {
                throw new Error(entity.LatestResult?.CompleteMessage || 'Could not create time entry.');
            }
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not create time entry.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    private async updateSingleCellEntry(entryID: string, durationMinutes: number): Promise<void> {
        if (this.busy) {
            return;
        }
        this.busy = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const md = new Metadata();
            const entity = await md.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                'MJ_BizApps_Tasks: Task Time Entries',
            );
            const loaded = await entity.InnerLoad(CompositeKey.FromID(entryID));
            if (!loaded) {
                throw new Error('Time entry could not be found.');
            }
            entity.StartedAt = null;
            entity.EndedAt = null;
            entity.Minutes = durationMinutes;

            const saved = await entity.Save();
            if (!saved) {
                throw new Error(entity.LatestResult?.CompleteMessage || 'Could not update time entry.');
            }
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not update time entry.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    private async buildGridRows(
        taskIDs: string[],
        entriesInView: Array<{
            ID: string;
            TaskID: string;
            Task: string | null;
            WorkDate: string | Date;
            Minutes: number;
            IsBillable: boolean;
            Notes: string | null;
            Source: mjBizAppsTasksTaskTimeEntryEntity['Source'];
        }>,
        activeTimerTaskID: string | null,
        rv: RunView,
    ): Promise<void> {
        const dayTotals: Record<string, number> = {};
        for (const d of this.displayedDays) {
            dayTotals[d] = 0;
        }

        if (taskIDs.length === 0) {
            this.rows = [];
            this.dayTotals = dayTotals;
            this.grandTotalMinutes = 0;
            this.grandBillableMinutes = 0;
            this.grandNonBillableMinutes = 0;
            return;
        }

        // Load tasks + root tasks for labels
        const tasksRes = await rv.RunView<TaskLookupItem>({
            EntityName: 'MJ_BizApps_Tasks: Tasks',
            ExtraFilter: `ID IN (${taskIDs.map((id) => `'${id}'`).join(',')})`,
            Fields: ['ID', 'Name', 'RootParentID'],
            ResultType: 'simple',
        });
        const taskMap = new Map<string, TaskLookupItem>();
        const rootIDs = new Set<string>();
        for (const t of tasksRes.Results ?? []) {
            taskMap.set(t.ID.toLowerCase(), t);
            if (t.RootParentID && !UUIDsEqual(t.RootParentID, t.ID)) {
                rootIDs.add(t.RootParentID);
            }
        }

        const missingRootIDs = Array.from(rootIDs).filter((id) => !taskMap.has(id.toLowerCase()));
        if (missingRootIDs.length > 0) {
            const rootsRes = await rv.RunView<{ ID: string; Name: string }>({
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                ExtraFilter: `ID IN (${missingRootIDs.map((id) => `'${id}'`).join(',')})`,
                Fields: ['ID', 'Name'],
                ResultType: 'simple',
            });
            for (const r of rootsRes.Results ?? []) {
                taskMap.set(r.ID.toLowerCase(), { ID: r.ID, Name: r.Name, RootParentID: null });
            }
        }

        const rowsMap = new Map<string, MyTimeTaskRow>();
        for (const taskID of taskIDs) {
            const key = taskID.toLowerCase();
            const info = taskMap.get(key);
            const taskName = info?.Name || taskID;
            let rootName: string | null = null;
            if (info?.RootParentID && !UUIDsEqual(info.RootParentID, taskID)) {
                rootName = taskMap.get(info.RootParentID.toLowerCase())?.Name ?? null;
            }
            const cellsByDate: MyTimeTaskRow['CellsByDate'] = {};
            for (const d of this.displayedDays) {
                cellsByDate[d] = { Entries: [], TotalMinutes: 0, DisplayValue: '' };
            }
            rowsMap.set(key, {
                TaskID: taskID,
                TaskName: taskName,
                RootTaskName: rootName,
                DisplayLabel: rootName ? `${rootName} › ${taskName}` : taskName,
                IsTimerRunning: !!(activeTimerTaskID && UUIDsEqual(activeTimerTaskID, taskID)),
                CellsByDate: cellsByDate,
                RowTotalMinutes: 0,
                RowBillableMinutes: 0,
            });
        }

        let grandTotal = 0;
        let grandBillable = 0;

        for (const entry of entriesInView) {
            const taskKey = entry.TaskID.toLowerCase();
            const row = rowsMap.get(taskKey);
            if (!row) {
                continue;
            }
            const dateIso = this.toIsoDate(entry.WorkDate);
            const cell = row.CellsByDate[dateIso];
            if (!cell) {
                continue;
            }
            cell.Entries.push({
                ID: entry.ID,
                TaskID: entry.TaskID,
                WorkDate: dateIso,
                DurationMinutes: entry.Minutes,
                IsBillable: entry.IsBillable,
                Notes: entry.Notes,
                Source: entry.Source,
                IsLocked: this.isPeriodLocked,
                LockReason: this.isPeriodLocked ? 'Timesheet locked' : null,
            });
            cell.TotalMinutes += entry.Minutes;
            cell.DisplayValue = FormatDurationClock(cell.TotalMinutes);

            row.RowTotalMinutes += entry.Minutes;
            if (entry.IsBillable) {
                row.RowBillableMinutes += entry.Minutes;
                grandBillable += entry.Minutes;
            }
            dayTotals[dateIso] = (dayTotals[dateIso] ?? 0) + entry.Minutes;
            grandTotal += entry.Minutes;
        }

        this.rows = Array.from(rowsMap.values()).sort((a, b) =>
            a.DisplayLabel.localeCompare(b.DisplayLabel),
        );
        this.dayTotals = dayTotals;
        this.grandTotalMinutes = grandTotal;
        this.grandBillableMinutes = grandBillable;
        this.grandNonBillableMinutes = Math.max(0, grandTotal - grandBillable);
    }

    private enumerateDays(startIso: CalendarDay, endIso: CalendarDay, maxDays: number): string[] {
        const days: string[] = [];
        let cursor = startIso;
        while (CompareDays(cursor, endIso) <= 0 && days.length < maxDays) {
            days.push(cursor);
            cursor = AddDays(cursor, 1);
        }
        return days;
    }

    private toIsoDate(val: string | Date): CalendarDay {
        const d = ToCalendarDay(val);
        if (d) return d;
        if (val instanceof Date) {
            return val.toISOString().slice(0, 10) as CalendarDay;
        }
        return String(val).slice(0, 10) as CalendarDay;
    }
}
