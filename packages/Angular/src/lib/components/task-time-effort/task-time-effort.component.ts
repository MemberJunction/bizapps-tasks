import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    EventEmitter,
    inject,
    Input,
    OnDestroy,
    OnInit,
    Output,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';
import { UUIDsEqual } from '@memberjunction/global';
import { SharedService } from '@memberjunction/ng-shared';
import { SharedGenericModule } from '@memberjunction/ng-shared-generic';
import {
    FormatDurationClock,
    FormatDurationMinutes,
    ParseDurationMinutes,
    TasksSettings,
    TimeTrackingService,
    UserCanManageTimeEntries,
} from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksTaskAgentRunEntity,
    mjBizAppsTasksTaskTimeEntryEntity,
    mjBizAppsTasksTaskTimerEntity,
} from '@mj-biz-apps/tasks-entities';
import { ResolveCurrentPersonID } from '../../current-person';
import {
    ComputeTimerChipState,
    type ActiveTimerSnapshot,
} from '../running-timer-chip/running-timer-chip.component';
import { TimeApproversComponent } from '../time-approvers/time-approvers.component';

/**
 * Effort summary for either a single task or its full subtask hierarchy.
 */
export interface TaskEffortSummary {
    LoggedMinutes: number;
    BillableMinutes: number;
    TimeEntryCount: number;
    HoursEstimated: number | null;
    AgentRunCount: number;
    AgentDurationSeconds: number;
    AgentTotalTokens: number;
    AgentTotalCost: number;
}

/**
 * Display model for a single `TaskTimeEntry` row in a task's Time & Effort section.
 */
export interface TaskTimeEntryDisplayRow {
    ID: string;
    PersonID: string;
    Person: string;
    WorkDate: string;
    DurationMinutes: number;
    DurationFormatted: string;
    StartedAt: string | null;
    EndedAt: string | null;
    IsBillable: boolean;
    Notes: string | null;
    Source: mjBizAppsTasksTaskTimeEntryEntity['Source'];
    TimesheetID: string | null;
    TimesheetStatus: string | null;
    LinkedRecords: Array<{
        ID: string;
        LinkedEntityID: string;
        LinkedEntity: string;
        LinkedRecordID: string;
        LinkType: string | null;
    }>;
    IsLocked: boolean;
    LockReason: string | null;
    CanModify: boolean;
}

/**
 * Display model for a linked `TaskAgentRun` row in a task's Time & Effort section.
 */
export interface TaskAgentRunDisplayRow {
    ID: string;
    AgentRunID: string;
    Agent: string;
    Status: string;
    StartedAt: string | null;
    DurationSeconds: number;
    TotalTokens: number;
    TotalCost: number;
    Notes: string | null;
    CanUnlink: boolean;
}

interface RecentAgentRunOption {
    ID: string;
    Agent: string | null;
    Status: string | null;
    StartedAt: string | Date | null;
    TotalTokensUsedRollup: number | null;
    TotalCost: number | null;
    TotalCostRollup: number | null;
}

/**
 * Task Time & Effort component showing:
 * - Timer controls (Start / Stop / Discard) and the **Log time** dialog (§8.1, §8.2)
 * - Side-by-side effort table (**This task** vs **With subtasks**) for human hours,
 *   estimate, and AI agent runs/tokens/cost/duration (§8.3)
 * - Time entries list with lock indicators, linked records, and inline edit/delete (§8.2, §8.5)
 * - Linked AI agent runs list and **Link a run…** dialog (§8.3)
 * - Time approvers configuration for the task (§8.5)
 *
 * Renders nothing when `TimeTrackingEnabled` is `false`.
 */
@Component({
    selector: 'bizapps-task-time-effort',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [FormsModule, SharedGenericModule, TimeApproversComponent],
    template: `
        @if (timeTrackingEnabled && TaskID) {
            <div class="time-effort-root">
                <!-- Header + Timer / Log Time Actions -->
                <div class="te-header">
                    <div class="te-title-group">
                        <span class="te-title">
                            <i class="fa-solid fa-stopwatch"></i> Time &amp; Effort
                        </span>
                        @if (activeTimerOnThisTask) {
                            <span class="running-badge">
                                <span class="pulse-dot"></span>
                                Running {{ timerElapsedDisplay }}
                            </span>
                        }
                    </div>
                    @if (!ReadOnly && currentPersonID) {
                        <div class="te-actions">
                            @if (activeTimerOnThisTask) {
                                <button
                                    type="button"
                                    class="btn-te btn-te--stop"
                                    [disabled]="busy"
                                    (click)="onStopTimer()">
                                    <i class="fa-solid fa-stop"></i> Stop
                                </button>
                                <button
                                    type="button"
                                    class="btn-te btn-te--secondary"
                                    [disabled]="busy"
                                    title="Discard running timer"
                                    (click)="onDiscardTimer()">
                                    <i class="fa-solid fa-trash-can"></i>
                                </button>
                            } @else {
                                <button
                                    type="button"
                                    class="btn-te btn-te--start"
                                    [disabled]="busy"
                                    (click)="onStartTimer()">
                                    <i class="fa-solid fa-play"></i> Start Timer
                                </button>
                            }
                            <button
                                type="button"
                                class="btn-te btn-te--primary"
                                [disabled]="busy"
                                (click)="openLogTimeDialog()">
                                <i class="fa-solid fa-plus"></i> Log Time
                            </button>
                        </div>
                    }
                </div>

                @if (errorMessage) {
                    <div class="te-error" role="alert">{{ errorMessage }}</div>
                }

                @if (loading) {
                    <mj-loading text="Loading time and effort..." size="small"></mj-loading>
                } @else {
                    <!-- Log / Edit Time Dialog -->
                    @if (showLogDialog) {
                        <div class="te-dialog">
                            <div class="te-dialog-header">
                                <span>{{ editingEntryID ? 'Edit Time Entry' : 'Log Time' }}</span>
                            </div>
                            <div class="te-form-row">
                                <div class="te-field">
                                    <label>Work Date *</label>
                                    <input type="date" [(ngModel)]="logForm.WorkDate" class="te-input" />
                                </div>
                                <div class="te-field">
                                    <label>Duration (e.g. 1h 30m, 1.5, 90m) *</label>
                                    <input
                                        type="text"
                                        [(ngModel)]="logForm.DurationInput"
                                        placeholder="1h 30m"
                                        class="te-input" />
                                </div>
                            </div>
                            <div class="te-form-row">
                                <div class="te-field">
                                    <label>Started At (optional)</label>
                                    <input type="datetime-local" [(ngModel)]="logForm.StartedAt" class="te-input" />
                                </div>
                                <div class="te-field">
                                    <label>Ended At (optional)</label>
                                    <input type="datetime-local" [(ngModel)]="logForm.EndedAt" class="te-input" />
                                </div>
                            </div>
                            <div class="te-field">
                                <label>Notes</label>
                                <textarea
                                    [(ngModel)]="logForm.Notes"
                                    rows="2"
                                    placeholder="What did you work on?"
                                    class="te-input"></textarea>
                            </div>
                            <label class="te-checkbox-row">
                                <input type="checkbox" [(ngModel)]="logForm.IsBillable" />
                                <span>Billable time</span>
                            </label>
                            <div class="te-dialog-actions">
                                <!-- Confirm on LEFT, Cancel on RIGHT -->
                                <button
                                    type="button"
                                    class="btn-te btn-te--primary"
                                    [disabled]="busy"
                                    (click)="saveLoggedTime()">
                                    {{ busy ? 'Saving...' : (editingEntryID ? 'Save Changes' : 'Log Time') }}
                                </button>
                                <button
                                    type="button"
                                    class="btn-te btn-te--secondary"
                                    [disabled]="busy"
                                    (click)="closeLogTimeDialog()">
                                    Cancel
                                </button>
                            </div>
                        </div>
                    }

                    <!-- Effort Summary Table (§8.3) -->
                    <div class="effort-table-wrap">
                        <table class="effort-table">
                            <thead>
                                <tr>
                                    <th>Metric</th>
                                    <th>This task</th>
                                    <th>With subtasks</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>Human hours (billable / total)</td>
                                    <td>
                                        <strong>{{ formatHoursPair(directEffort.BillableMinutes, directEffort.LoggedMinutes) }}</strong>
                                        <span class="sub-meta">({{ directEffort.TimeEntryCount }} entries)</span>
                                    </td>
                                    <td>
                                        <strong>{{ formatHoursPair(subtreeEffort.BillableMinutes, subtreeEffort.LoggedMinutes) }}</strong>
                                        <span class="sub-meta">({{ subtreeEffort.TimeEntryCount }} entries)</span>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Estimate</td>
                                    <td>{{ formatEstimate(directEffort.HoursEstimated) }}</td>
                                    <td>{{ formatEstimate(subtreeEffort.HoursEstimated) }}</td>
                                </tr>
                                <tr>
                                    <td>Agent runs · tokens · cost · time</td>
                                    <td>{{ formatAgentSummary(directEffort) }}</td>
                                    <td>{{ formatAgentSummary(subtreeEffort) }}</td>
                                </tr>
                            </tbody>
                        </table>
                        @if (effortTruncated) {
                            <div class="truncated-notice">
                                <i class="fa-solid fa-circle-info"></i>
                                This task hierarchy exceeds 500 tasks; some deeply nested subtasks were omitted from the rollup.
                            </div>
                        }
                    </div>

                    <!-- Time Entries List (§8.2) -->
                    <div class="te-subsection">
                        <div class="te-subsection-header">
                            <span class="te-subsection-title">Time Entries ({{ entries.length }})</span>
                        </div>
                        @if (entries.length === 0) {
                            <p class="te-empty">No time logged on this task yet.</p>
                        } @else {
                            <div class="entry-list">
                                @for (entry of entries; track entry.ID) {
                                    <div class="entry-row" [class.entry-row--locked]="entry.IsLocked">
                                        <div class="entry-main">
                                            <div class="entry-top-line">
                                                <span class="entry-person">{{ entry.Person }}</span>
                                                <span class="entry-date">{{ entry.WorkDate }}</span>
                                                <span class="entry-duration">{{ entry.DurationFormatted }}</span>
                                                @if (entry.IsBillable) {
                                                    <span class="entry-chip entry-chip--billable">Billable</span>
                                                } @else {
                                                    <span class="entry-chip">Non-billable</span>
                                                }
                                                <span class="entry-source">{{ entry.Source }}</span>
                                                @if (entry.IsLocked) {
                                                    <span class="entry-lock" [title]="entry.LockReason || 'Locked'">
                                                        <i class="fa-solid fa-lock"></i>
                                                        {{ entry.LockReason }}
                                                    </span>
                                                }
                                            </div>
                                            @if (entry.Notes) {
                                                <p class="entry-notes">{{ entry.Notes }}</p>
                                            }
                                            @if (entry.LinkedRecords.length > 0) {
                                                <div class="entry-links">
                                                    @for (link of entry.LinkedRecords; track link.ID) {
                                                        <button
                                                            type="button"
                                                            class="linked-record-pill"
                                                            (click)="openLinkedRecord(link.LinkedEntity, link.LinkedRecordID)">
                                                            <i class="fa-solid fa-link"></i>
                                                            {{ link.LinkedEntity }}: {{ link.LinkedRecordID }}
                                                        </button>
                                                    }
                                                </div>
                                            }
                                        </div>
                                        @if (!ReadOnly && entry.CanModify && !entry.IsLocked) {
                                            <div class="entry-actions">
                                                @if (confirmingDeleteEntryID === entry.ID) {
                                                    <!-- Confirm on LEFT, Cancel on RIGHT -->
                                                    <button
                                                        type="button"
                                                        class="btn-xs btn-danger"
                                                        [disabled]="busy"
                                                        (click)="confirmDeleteEntry(entry.ID)">
                                                        Delete
                                                    </button>
                                                    <button
                                                        type="button"
                                                        class="btn-xs btn-secondary"
                                                        [disabled]="busy"
                                                        (click)="confirmingDeleteEntryID = null">
                                                        Cancel
                                                    </button>
                                                } @else {
                                                    <button
                                                        type="button"
                                                        class="btn-icon"
                                                        title="Edit entry"
                                                        (click)="openEditEntryDialog(entry)">
                                                        <i class="fa-solid fa-pen"></i>
                                                    </button>
                                                    <button
                                                        type="button"
                                                        class="btn-icon"
                                                        title="Delete entry"
                                                        (click)="confirmingDeleteEntryID = entry.ID">
                                                        <i class="fa-solid fa-trash-can"></i>
                                                    </button>
                                                }
                                            </div>
                                        }
                                    </div>
                                }
                            </div>
                        }
                    </div>

                    <!-- Linked AI Agent Runs (§8.3) -->
                    <div class="te-subsection">
                        <div class="te-subsection-header">
                            <span class="te-subsection-title">Linked AI Agent Runs ({{ agentRuns.length }})</span>
                            @if (!ReadOnly && !showLinkRunDialog) {
                                <button type="button" class="btn-link" (click)="openLinkRunDialog()">
                                    <i class="fa-solid fa-robot"></i> Link a run…
                                </button>
                            }
                        </div>

                        @if (showLinkRunDialog) {
                            <div class="te-dialog">
                                <div class="te-dialog-header">
                                    <span>Link AI Agent Run (Last 30 Days)</span>
                                </div>
                                <div class="te-field">
                                    <label>Select Run *</label>
                                    <select [(ngModel)]="selectedAgentRunID" class="te-input">
                                        <option value="">Choose a recent run...</option>
                                        @for (run of recentAgentRuns; track run.ID) {
                                            <option [value]="run.ID">
                                                {{ run.Agent || 'Agent Run' }} · {{ formatRunOptionDate(run.StartedAt) }}
                                                · {{ formatRunOptionCost(run) }}
                                            </option>
                                        }
                                    </select>
                                </div>
                                <div class="te-field">
                                    <label>Notes (optional)</label>
                                    <input
                                        type="text"
                                        [(ngModel)]="linkRunNotes"
                                        placeholder="Optional attribution note..."
                                        class="te-input" />
                                </div>
                                <div class="te-dialog-actions">
                                    <!-- Confirm on LEFT, Cancel on RIGHT -->
                                    <button
                                        type="button"
                                        class="btn-te btn-te--primary"
                                        [disabled]="busy || !selectedAgentRunID"
                                        (click)="saveLinkedAgentRun()">
                                        {{ busy ? 'Linking...' : 'Link Run' }}
                                    </button>
                                    <button
                                        type="button"
                                        class="btn-te btn-te--secondary"
                                        [disabled]="busy"
                                        (click)="showLinkRunDialog = false">
                                        Cancel
                                    </button>
                                </div>
                            </div>
                        }

                        @if (agentRuns.length === 0) {
                            <p class="te-empty">No AI agent runs linked to this task.</p>
                        } @else {
                            <div class="entry-list">
                                @for (run of agentRuns; track run.ID) {
                                    <div class="entry-row">
                                        <div class="entry-main">
                                            <div class="entry-top-line">
                                                <button
                                                    type="button"
                                                    class="agent-run-link"
                                                    (click)="openAgentRunRecord(run.AgentRunID)">
                                                    <i class="fa-solid fa-robot"></i>
                                                    {{ run.Agent }}
                                                </button>
                                                @if (run.StartedAt) {
                                                    <span class="entry-date">{{ run.StartedAt }}</span>
                                                }
                                                <span class="entry-chip">
                                                    {{ run.DurationSeconds }}s · {{ run.TotalTokens.toLocaleString() }} tok · \${{ run.TotalCost.toFixed(4) }}
                                                </span>
                                                <span class="entry-source">{{ run.Status }}</span>
                                            </div>
                                            @if (run.Notes) {
                                                <p class="entry-notes">{{ run.Notes }}</p>
                                            }
                                        </div>
                                        @if (!ReadOnly && run.CanUnlink) {
                                            <div class="entry-actions">
                                                @if (confirmingUnlinkRunID === run.ID) {
                                                    <!-- Confirm on LEFT, Cancel on RIGHT -->
                                                    <button
                                                        type="button"
                                                        class="btn-xs btn-danger"
                                                        [disabled]="busy"
                                                        (click)="confirmUnlinkAgentRun(run.ID)">
                                                        Unlink
                                                    </button>
                                                    <button
                                                        type="button"
                                                        class="btn-xs btn-secondary"
                                                        [disabled]="busy"
                                                        (click)="confirmingUnlinkRunID = null">
                                                        Cancel
                                                    </button>
                                                } @else {
                                                    <button
                                                        type="button"
                                                        class="btn-icon"
                                                        title="Unlink agent run"
                                                        (click)="confirmingUnlinkRunID = run.ID">
                                                        <i class="fa-solid fa-link-slash"></i>
                                                    </button>
                                                }
                                            </div>
                                        }
                                    </div>
                                }
                            </div>
                        }
                    </div>

                    <!-- Time Approvers (§8.5) -->
                    @if (timesheetApprovalEnabled) {
                        <bizapps-time-approvers
                            [ScopeEntityName]="'MJ_BizApps_Tasks: Tasks'"
                            [ScopeRecordID]="TaskID"
                            [ReadOnly]="ReadOnly">
                        </bizapps-time-approvers>
                    }
                }
            </div>
        }
    `,
    styles: [`
        :host {
            display: block;
            font-family: var(--mj-font-family);
        }
        .time-effort-root {
            margin-top: 20px;
            padding-top: 16px;
            border-top: 1px solid var(--mj-border-subtle);
            display: flex;
            flex-direction: column;
            gap: 14px;
        }
        .te-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 8px;
        }
        .te-title-group {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .te-title {
            font-size: 13px;
            font-weight: var(--mj-font-bold);
            color: var(--mj-text-primary);
            text-transform: uppercase;
            letter-spacing: 0.4px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .running-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 2px 8px;
            border-radius: var(--mj-radius-md);
            background: var(--mj-status-success-bg);
            color: var(--mj-status-success-text);
            font-size: 12px;
            font-weight: var(--mj-font-bold);
            font-variant-numeric: tabular-nums;
        }
        .pulse-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: var(--mj-status-success);
        }
        .te-actions {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .btn-te {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 6px 12px;
            border-radius: var(--mj-radius-md);
            font-size: 12px;
            font-weight: var(--mj-font-semibold);
            font-family: inherit;
            cursor: pointer;
            border: 1px solid var(--mj-border-default);
        }
        .btn-te:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .btn-te--primary {
            background: var(--mj-brand-primary);
            border-color: var(--mj-brand-primary);
            color: var(--mj-text-inverse);
        }
        .btn-te--start {
            background: var(--mj-status-success);
            border-color: var(--mj-status-success);
            color: var(--mj-text-inverse);
        }
        .btn-te--stop {
            background: var(--mj-status-error);
            border-color: var(--mj-status-error);
            color: var(--mj-text-inverse);
        }
        .btn-te--secondary {
            background: var(--mj-bg-surface);
            color: var(--mj-text-secondary);
        }
        .te-error {
            padding: 8px 10px;
            border-radius: var(--mj-radius-md);
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
            border: 1px solid var(--mj-status-error-border);
            font-size: 12px;
        }
        .te-dialog {
            padding: 14px;
            border-radius: var(--mj-radius-md);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface-sunken);
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .te-dialog-header {
            font-size: 13px;
            font-weight: var(--mj-font-bold);
            color: var(--mj-text-primary);
        }
        .te-form-row {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .te-field {
            flex: 1;
            min-width: 150px;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .te-field label {
            font-size: 11px;
            font-weight: var(--mj-font-semibold);
            color: var(--mj-text-muted);
        }
        .te-input {
            padding: 6px 10px;
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-sm);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-size: 13px;
            font-family: inherit;
        }
        .te-checkbox-row {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
            color: var(--mj-text-primary);
            cursor: pointer;
        }
        .te-dialog-actions {
            display: flex;
            gap: 8px;
        }
        .effort-table-wrap {
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md);
            overflow: hidden;
        }
        .effort-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 12px;
        }
        .effort-table th,
        .effort-table td {
            padding: 8px 10px;
            text-align: left;
            border-bottom: 1px solid var(--mj-border-subtle);
        }
        .effort-table th {
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-secondary);
            font-weight: var(--mj-font-bold);
            font-size: 11px;
            text-transform: uppercase;
        }
        .effort-table tr:last-child td {
            border-bottom: none;
        }
        .sub-meta {
            color: var(--mj-text-muted);
            font-size: 11px;
            margin-left: 4px;
        }
        .truncated-notice {
            padding: 6px 10px;
            background: var(--mj-status-warning-bg);
            color: var(--mj-status-warning-text);
            font-size: 11px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .te-subsection {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .te-subsection-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .te-subsection-title {
            font-size: 12px;
            font-weight: var(--mj-font-bold);
            color: var(--mj-text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        .btn-link {
            border: none;
            background: transparent;
            color: var(--mj-brand-primary);
            font-size: 12px;
            font-weight: var(--mj-font-semibold);
            font-family: inherit;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .btn-link:hover {
            text-decoration: underline;
        }
        .te-empty {
            margin: 0;
            font-size: 12px;
            color: var(--mj-text-disabled);
        }
        .entry-list {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .entry-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 8px;
            padding: 8px 10px;
            border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-subtle);
            font-size: 12px;
        }
        .entry-row--locked {
            background: var(--mj-bg-surface);
        }
        .entry-main {
            flex: 1;
            min-width: 0;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .entry-top-line {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 6px;
        }
        .entry-person {
            font-weight: var(--mj-font-semibold);
            color: var(--mj-text-primary);
        }
        .entry-date {
            color: var(--mj-text-muted);
        }
        .entry-duration {
            font-weight: var(--mj-font-bold);
            color: var(--mj-brand-primary);
            font-variant-numeric: tabular-nums;
        }
        .entry-chip {
            padding: 1px 6px;
            border-radius: var(--mj-radius-sm);
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            color: var(--mj-text-secondary);
            font-size: 11px;
        }
        .entry-chip--billable {
            background: color-mix(in srgb, var(--mj-status-success) 12%, var(--mj-bg-surface));
            border-color: color-mix(in srgb, var(--mj-status-success) 35%, var(--mj-border-default));
            color: var(--mj-status-success-text);
        }
        .entry-source {
            font-size: 11px;
            color: var(--mj-text-disabled);
        }
        .entry-lock {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 11px;
            color: var(--mj-status-warning-text);
            background: var(--mj-status-warning-bg);
            padding: 1px 6px;
            border-radius: var(--mj-radius-sm);
        }
        .entry-notes {
            margin: 0;
            color: var(--mj-text-secondary);
            line-height: 1.4;
        }
        .entry-links {
            display: flex;
            flex-wrap: wrap;
            gap: 4px;
        }
        .linked-record-pill {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 2px 6px;
            border-radius: var(--mj-radius-sm);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-brand-primary);
            font-size: 11px;
            font-family: inherit;
            cursor: pointer;
        }
        .linked-record-pill:hover {
            text-decoration: underline;
        }
        .agent-run-link {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            border: none;
            background: transparent;
            color: var(--mj-brand-primary);
            font-weight: var(--mj-font-semibold);
            font-size: 12px;
            font-family: inherit;
            cursor: pointer;
            padding: 0;
        }
        .agent-run-link:hover {
            text-decoration: underline;
        }
        .entry-actions {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            flex-shrink: 0;
        }
        .btn-icon {
            border: none;
            background: transparent;
            color: var(--mj-text-disabled);
            cursor: pointer;
            padding: 4px;
        }
        .btn-icon:hover {
            color: var(--mj-text-primary);
        }
        .btn-xs {
            padding: 3px 8px;
            border-radius: var(--mj-radius-sm);
            font-size: 11px;
            font-weight: var(--mj-font-semibold);
            font-family: inherit;
            cursor: pointer;
            border: 1px solid var(--mj-border-default);
        }
        .btn-danger {
            background: var(--mj-status-error);
            border-color: var(--mj-status-error);
            color: var(--mj-text-inverse);
        }
        .btn-secondary {
            background: var(--mj-bg-surface);
            color: var(--mj-text-secondary);
        }
    `],
})
export class TaskTimeEffortComponent implements OnInit, OnDestroy {
    private _taskID: string | null = null;
    private _personID: string | null = null;
    private _readOnly = false;
    private timeTracking = new TimeTrackingService();

    @Input()
    public get TaskID(): string | null {
        return this._taskID;
    }
    public set TaskID(value: string | null) {
        const changed = value !== this._taskID;
        this._taskID = value;
        if (changed && this.initialized) {
            void this.Refresh();
        }
    }

    @Input()
    public get PersonID(): string | null {
        return this._personID;
    }
    public set PersonID(value: string | null) {
        const changed = value !== this._personID;
        this._personID = value;
        if (changed && this.initialized) {
            void this.Refresh();
        }
    }

    @Input()
    public get ReadOnly(): boolean {
        return this._readOnly;
    }
    public set ReadOnly(value: boolean) {
        this._readOnly = value;
        this.cdr.markForCheck();
    }

    @Output() public TimeChanged = new EventEmitter<void>();

    public timeTrackingEnabled = false;
    public timesheetApprovalEnabled = false;
    public loading = false;
    public busy = false;
    public errorMessage = '';
    public currentPersonID: string | null = null;
    public canManageEntries = false;

    public activeTimer: ActiveTimerSnapshot | null = null;
    public timerElapsedDisplay = '0:00:00';

    public directEffort: TaskEffortSummary = this.emptyEffort();
    public subtreeEffort: TaskEffortSummary = this.emptyEffort();
    public effortTruncated = false;

    public entries: TaskTimeEntryDisplayRow[] = [];
    public agentRuns: TaskAgentRunDisplayRow[] = [];

    // Log / Edit Time Dialog state
    public showLogDialog = false;
    public editingEntryID: string | null = null;
    public confirmingDeleteEntryID: string | null = null;
    public logForm = {
        WorkDate: new Date().toISOString().slice(0, 10),
        DurationInput: '1h',
        StartedAt: '',
        EndedAt: '',
        Notes: '',
        IsBillable: true,
    };

    // Link Agent Run Dialog state
    public showLinkRunDialog = false;
    public recentAgentRuns: RecentAgentRunOption[] = [];
    public selectedAgentRunID = '';
    public linkRunNotes = '';
    public confirmingUnlinkRunID: string | null = null;

    private initialized = false;
    private tickInterval: ReturnType<typeof setInterval> | null = null;
    private cdr = inject(ChangeDetectorRef);

    public get activeTimerOnThisTask(): boolean {
        return !!(
            this.activeTimer &&
            this._taskID &&
            UUIDsEqual(this.activeTimer.TaskID, this._taskID)
        );
    }

    public ngOnInit(): void {
        this.initialized = true;
        void this.Refresh();
    }

    public ngOnDestroy(): void {
        this.clearTickInterval();
    }

    public async Refresh(): Promise<void> {
        this.errorMessage = '';
        this.confirmingDeleteEntryID = null;
        this.confirmingUnlinkRunID = null;

        const provider = Metadata.Provider;
        try {
            await TasksSettings.Load(provider);
        } catch {
            // Fall back to cached / default settings
        }
        this.timeTrackingEnabled = TasksSettings.TimeTrackingEnabled(provider);
        if (!this.timeTrackingEnabled || !this._taskID) {
            this.clearTickInterval();
            this.cdr.markForCheck();
            return;
        }

        this.loading = true;
        this.cdr.markForCheck();

        try {
            const rv = new RunView();
            let personID = this._personID;
            if (!personID) {
                try {
                    personID = await ResolveCurrentPersonID();
                } catch {
                    personID = null;
                }
            }
            this.currentPersonID = personID;

            const approvalEnabled = TasksSettings.TimesheetApprovalEnabled(provider);
            const hasManageEntries = UserCanManageTimeEntries(provider.CurrentUser, provider);

            const [activeTimerRes, effortPair] = await Promise.all([
                personID
                    ? rv.RunView<ActiveTimerSnapshot>({
                          EntityName: 'MJ_BizApps_Tasks: Task Timers',
                          ExtraFilter: `PersonID = '${personID}'`,
                          ResultType: 'simple',
                          MaxRows: 1,
                          BypassCache: true,
                      })
                    : Promise.resolve({ Results: [] as ActiveTimerSnapshot[] }),
                this.loadEffortSafe(this._taskID, rv),
            ]);

            this.timesheetApprovalEnabled = approvalEnabled;
            this.canManageEntries = hasManageEntries;
            this.activeTimer = activeTimerRes.Results?.[0] ?? null;
            this.directEffort = effortPair.Direct;
            this.subtreeEffort = effortPair.WithSubtasks;
            this.effortTruncated = effortPair.Truncated;

            if (this.activeTimerOnThisTask && this.activeTimer) {
                this.updateTimerElapsed();
                this.startTickInterval();
            } else {
                this.clearTickInterval();
            }

            await Promise.all([this.loadTimeEntries(this._taskID, rv), this.loadAgentRuns(this._taskID, rv)]);
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Failed to load task time & effort.';
        } finally {
            this.loading = false;
            this.cdr.markForCheck();
        }
    }

    public async onStartTimer(): Promise<void> {
        if (!this._taskID || this.busy) {
            return;
        }
        this.busy = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const res = await this.timeTracking.StartTimer({
                TaskID: this._taskID,
                IsBillable: true,
            });
            if (!res.Success) {
                throw new Error(res.ErrorMessage || 'Could not start timer.');
            }
            this.TimeChanged.emit();
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not start timer.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async onStopTimer(): Promise<void> {
        if (this.busy) {
            return;
        }
        this.busy = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const res = await this.timeTracking.StopTimer({});
            if (!res.Success) {
                throw new Error(res.ErrorMessage || 'Could not stop timer.');
            }
            this.TimeChanged.emit();
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not stop timer.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async onDiscardTimer(): Promise<void> {
        if (!this.activeTimer || this.busy) {
            return;
        }
        this.busy = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const md = new Metadata();
            const timerEntity = await md.GetEntityObject<mjBizAppsTasksTaskTimerEntity>('MJ_BizApps_Tasks: Task Timers');
            const loaded = await timerEntity.InnerLoad(CompositeKey.FromID(this.activeTimer.ID));
            if (loaded) {
                const deleted = await timerEntity.Delete();
                if (!deleted) {
                    throw new Error(timerEntity.LatestResult?.CompleteMessage || 'Could not discard timer.');
                }
            }
            this.TimeChanged.emit();
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not discard timer.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public openLogTimeDialog(): void {
        this.editingEntryID = null;
        this.logForm = {
            WorkDate: new Date().toISOString().slice(0, 10),
            DurationInput: '1h',
            StartedAt: '',
            EndedAt: '',
            Notes: '',
            IsBillable: true,
        };
        this.showLogDialog = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
    }

    public openEditEntryDialog(entry: TaskTimeEntryDisplayRow): void {
        this.editingEntryID = entry.ID;
        this.logForm = {
            WorkDate: entry.WorkDate,
            DurationInput: FormatDurationClock(entry.DurationMinutes),
            StartedAt: entry.StartedAt ? entry.StartedAt.slice(0, 16) : '',
            EndedAt: entry.EndedAt ? entry.EndedAt.slice(0, 16) : '',
            Notes: entry.Notes ?? '',
            IsBillable: entry.IsBillable,
        };
        this.showLogDialog = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
    }

    public closeLogTimeDialog(): void {
        this.showLogDialog = false;
        this.editingEntryID = null;
        this.cdr.markForCheck();
    }

    public async saveLoggedTime(): Promise<void> {
        if (!this._taskID || !this.currentPersonID || this.busy) {
            return;
        }

        const parsedMinutes = ParseDurationMinutes(this.logForm.DurationInput);
        const hasInterval = !!(this.logForm.StartedAt && this.logForm.EndedAt);
        if (!hasInterval && parsedMinutes === null) {
            this.errorMessage = 'Enter a valid duration such as "1h 30m", "1.5", "90m", or "1:30".';
            this.cdr.markForCheck();
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
            if (this.editingEntryID) {
                const loaded = await entity.InnerLoad(CompositeKey.FromID(this.editingEntryID));
                if (!loaded) {
                    throw new Error('Time entry could not be found.');
                }
            } else {
                entity.NewRecord();
                entity.TaskID = this._taskID;
                entity.PersonID = this.currentPersonID;
                entity.Source = 'Manual';
            }

            entity.WorkDate = new Date(`${this.logForm.WorkDate}T00:00:00.000Z`);
            if (hasInterval) {
                const start = new Date(this.logForm.StartedAt);
                const end = new Date(this.logForm.EndedAt);
                entity.StartedAt = start;
                entity.EndedAt = end;
                entity.Minutes = Math.max(1, Math.round((end.getTime() - start.getTime()) / 60000));
            } else {
                entity.StartedAt = null;
                entity.EndedAt = null;
                entity.Minutes = parsedMinutes!;
            }
            entity.Notes = this.logForm.Notes.trim() || null;
            entity.IsBillable = this.logForm.IsBillable;

            const saved = await entity.Save();
            if (!saved) {
                throw new Error(entity.LatestResult?.CompleteMessage || 'Could not save time entry.');
            }

            this.showLogDialog = false;
            this.editingEntryID = null;
            this.TimeChanged.emit();
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not save time entry.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async confirmDeleteEntry(entryID: string): Promise<void> {
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
            this.confirmingDeleteEntryID = null;
            this.TimeChanged.emit();
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not delete time entry.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async openLinkRunDialog(): Promise<void> {
        this.showLinkRunDialog = true;
        this.selectedAgentRunID = '';
        this.linkRunNotes = '';
        this.errorMessage = '';
        this.cdr.markForCheck();

        const rv = new RunView();
        const cutoff = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();
        const currentUserID = new Metadata().CurrentUser?.ID;
        const userFilter =
            !this.canManageEntries && currentUserID ? ` AND UserID = '${currentUserID}'` : '';
        const res = await rv.RunView<RecentAgentRunOption>({
            EntityName: 'MJ: AI Agent Runs',
            ExtraFilter: `StartedAt >= '${cutoff}'${userFilter}`,
            OrderBy: 'StartedAt DESC',
            MaxRows: 50,
            ResultType: 'simple',
        });
        const linkedSet = new Set(this.agentRuns.map((r) => r.AgentRunID.toLowerCase()));
        this.recentAgentRuns = (res.Results ?? []).filter(
            (r) => !linkedSet.has(r.ID.toLowerCase()),
        );
        this.cdr.markForCheck();
    }

    public async saveLinkedAgentRun(): Promise<void> {
        if (!this._taskID || !this.selectedAgentRunID || this.busy) {
            return;
        }
        this.busy = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const md = new Metadata();
            const entity = await md.GetEntityObject<mjBizAppsTasksTaskAgentRunEntity>(
                'MJ_BizApps_Tasks: Task Agent Runs',
            );
            entity.NewRecord();
            entity.TaskID = this._taskID;
            entity.AIAgentRunID = this.selectedAgentRunID;
            entity.Role = 'Executed';
            entity.Notes = this.linkRunNotes.trim() || null;

            const saved = await entity.Save();
            if (!saved) {
                throw new Error(entity.LatestResult?.CompleteMessage || 'Could not link AI agent run.');
            }
            this.showLinkRunDialog = false;
            this.TimeChanged.emit();
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not link AI agent run.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async confirmUnlinkAgentRun(taskAgentRunID: string): Promise<void> {
        if (this.busy) {
            return;
        }
        this.busy = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const md = new Metadata();
            const entity = await md.GetEntityObject<mjBizAppsTasksTaskAgentRunEntity>(
                'MJ_BizApps_Tasks: Task Agent Runs',
            );
            const loaded = await entity.InnerLoad(CompositeKey.FromID(taskAgentRunID));
            if (loaded) {
                const deleted = await entity.Delete();
                if (!deleted) {
                    throw new Error(entity.LatestResult?.CompleteMessage || 'Could not unlink AI agent run.');
                }
            }
            this.confirmingUnlinkRunID = null;
            this.TimeChanged.emit();
            await this.Refresh();
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not unlink AI agent run.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public openLinkedRecord(entityName: string, recordID: string): void {
        if (!entityName || !recordID) {
            return;
        }
        SharedService.Instance.OpenEntityRecord(entityName, CompositeKey.FromID(recordID));
    }

    public openAgentRunRecord(agentRunID: string): void {
        if (!agentRunID) {
            return;
        }
        SharedService.Instance.OpenEntityRecord('MJ: AI Agent Runs', CompositeKey.FromID(agentRunID));
    }

    public formatHoursPair(billableMinutes: number, totalMinutes: number): string {
        const billHrs = Number((billableMinutes / 60).toFixed(2));
        const totHrs = Number((totalMinutes / 60).toFixed(2));
        return `${billHrs}h / ${totHrs}h (${FormatDurationMinutes(totalMinutes)})`;
    }

    public formatEstimate(hours: number | null): string {
        if (hours === null || hours === undefined) {
            return '—';
        }
        return `${Number(hours.toFixed(2))}h`;
    }

    public formatAgentSummary(effort: TaskEffortSummary): string {
        const costStr = `$${Number((effort.AgentTotalCost ?? 0).toFixed(4))}`;
        return `${effort.AgentRunCount} runs · ${(effort.AgentTotalTokens ?? 0).toLocaleString()} tok · ${costStr} · ${effort.AgentDurationSeconds ?? 0}s`;
    }

    public formatRunOptionDate(startedAt: string | Date | null): string {
        if (!startedAt) {
            return '';
        }
        const d = startedAt instanceof Date ? startedAt : new Date(startedAt);
        return Number.isNaN(d.getTime()) ? '' : d.toISOString().slice(0, 10);
    }

    public formatRunOptionCost(run: RecentAgentRunOption): string {
        const cost = Number(run.TotalCostRollup ?? run.TotalCost ?? 0);
        return `$${cost.toFixed(4)}`;
    }

    private async loadEffortSafe(
        taskID: string,
        rv: RunView,
    ): Promise<{ Direct: TaskEffortSummary; WithSubtasks: TaskEffortSummary; Truncated: boolean }> {
        try {
            const res = await this.timeTracking.GetTaskEffort({ TaskID: taskID, IncludeDescendants: true });
            if (res.Success && res.Output) {
                const out = res.Output;
                const directEntries = (out.TimeEntries ?? []).filter((e) => UUIDsEqual(e.TaskID, taskID));
                const directBillable = directEntries
                    .filter((e) => e.IsBillable)
                    .reduce((acc, e) => acc + (e.Minutes ?? 0), 0);
                const directRuns = (out.AgentRuns ?? []).filter(
                    (r) => UUIDsEqual(r.TaskID, taskID) && r.CountedInTotals,
                );
                const estHours = out.EstimatedMinutes != null ? Number((out.EstimatedMinutes / 60).toFixed(2)) : null;

                return {
                    Direct: {
                        LoggedMinutes: out.DirectLoggedMinutes ?? 0,
                        BillableMinutes: directBillable,
                        TimeEntryCount: directEntries.length,
                        HoursEstimated: estHours,
                        AgentRunCount: out.DirectAgentRunCount ?? 0,
                        AgentDurationSeconds: directRuns.reduce((acc, r) => acc + (r.DurationSeconds ?? 0), 0),
                        AgentTotalTokens: directRuns.reduce((acc, r) => acc + (r.TotalTokensUsed ?? 0), 0),
                        AgentTotalCost: directRuns.reduce((acc, r) => acc + (r.TotalCost ?? 0), 0),
                    },
                    WithSubtasks: {
                        LoggedMinutes: out.RolledUpLoggedMinutes ?? 0,
                        BillableMinutes: out.BillableMinutes ?? 0,
                        TimeEntryCount: (out.TimeEntries ?? []).length,
                        HoursEstimated: estHours,
                        AgentRunCount: out.RolledUpAgentRunCount ?? 0,
                        AgentDurationSeconds: out.AgentWallClockSeconds ?? 0,
                        AgentTotalTokens: out.AgentTotalTokens ?? 0,
                        AgentTotalCost: out.AgentTotalCost ?? 0,
                    },
                    Truncated: false,
                };
            }
        } catch {
            // Fall through to direct view query
        }

        const res = await rv.RunView<{
            HoursEstimated: number | null;
            LoggedMinutes: number | null;
            BillableMinutes: number | null;
            TimeEntryCount: number | null;
            AgentRunCount: number | null;
            AgentDurationSeconds: number | null;
            AgentTotalTokens: number | null;
            AgentTotalCost: number | null;
        }>({
            EntityName: 'MJ_BizApps_Tasks: Tasks',
            ExtraFilter: `ID = '${taskID}'`,
            ResultType: 'simple',
            MaxRows: 1,
        });
        const row = res.Results?.[0];
        const direct: TaskEffortSummary = {
            LoggedMinutes: Number(row?.LoggedMinutes ?? 0),
            BillableMinutes: Number(row?.BillableMinutes ?? 0),
            TimeEntryCount: Number(row?.TimeEntryCount ?? 0),
            HoursEstimated: row?.HoursEstimated != null ? Number(row.HoursEstimated) : null,
            AgentRunCount: Number(row?.AgentRunCount ?? 0),
            AgentDurationSeconds: Number(row?.AgentDurationSeconds ?? 0),
            AgentTotalTokens: Number(row?.AgentTotalTokens ?? 0),
            AgentTotalCost: Number(row?.AgentTotalCost ?? 0),
        };
        return {
            Direct: direct,
            WithSubtasks: { ...direct },
            Truncated: false,
        };
    }

    private async loadTimeEntries(taskID: string, rv: RunView): Promise<void> {
        const res = await rv.RunView<{
            ID: string;
            PersonID: string;
            Person: string | null;
            WorkDate: string | Date;
            Minutes: number;
            StartedAt: string | Date | null;
            EndedAt: string | Date | null;
            IsBillable: boolean;
            Notes: string | null;
            Source: mjBizAppsTasksTaskTimeEntryEntity['Source'];
            TimesheetID: string | null;
        }>({
            EntityName: 'MJ_BizApps_Tasks: Task Time Entries',
            ExtraFilter: `TaskID = '${taskID}'`,
            OrderBy: 'WorkDate DESC, __mj_CreatedAt DESC',
            ResultType: 'simple',
        });

        const rawEntries = res.Results ?? [];
        if (rawEntries.length === 0) {
            this.entries = [];
            return;
        }

        const entryIDs = rawEntries.map((e) => `'${e.ID}'`).join(',');
        const timesheetIDs = Array.from(
            new Set(rawEntries.map((e) => e.TimesheetID).filter((id): id is string => !!id)),
        );

        const [linksRes, timesheetsRes] = await Promise.all([
            rv.RunView<{
                ID: string;
                TaskTimeEntryID: string;
                LinkedEntityID: string;
                LinkedEntity: string | null;
                LinkedRecordID: string;
                LinkType: string | null;
            }>({
                EntityName: 'MJ_BizApps_Tasks: Task Time Entry Links',
                ExtraFilter: `TaskTimeEntryID IN (${entryIDs})`,
                ResultType: 'simple',
            }),
            timesheetIDs.length > 0
                ? rv.RunView<{ ID: string; Status: string }>({
                      EntityName: 'MJ_BizApps_Tasks: Timesheets',
                      ExtraFilter: `ID IN (${timesheetIDs.map((id) => `'${id}'`).join(',')})`,
                      Fields: ['ID', 'Status'],
                      ResultType: 'simple',
                  })
                : Promise.resolve({ Results: [] as Array<{ ID: string; Status: string }> }),
        ]);

        const linksByEntry = new Map<
            string,
            Array<{
                ID: string;
                LinkedEntityID: string;
                LinkedEntity: string;
                LinkedRecordID: string;
                LinkType: string | null;
            }>
        >();
        for (const l of linksRes.Results ?? []) {
            const key = l.TaskTimeEntryID.toLowerCase();
            const bucket = linksByEntry.get(key) ?? [];
            bucket.push({
                ID: l.ID,
                LinkedEntityID: l.LinkedEntityID,
                LinkedEntity: l.LinkedEntity || 'Record',
                LinkedRecordID: l.LinkedRecordID,
                LinkType: l.LinkType,
            });
            linksByEntry.set(key, bucket);
        }

        const timesheetStatusByID = new Map<string, string>();
        for (const ts of timesheetsRes.Results ?? []) {
            timesheetStatusByID.set(ts.ID.toLowerCase(), ts.Status);
        }

        this.entries = rawEntries.map((e) => {
            const workDate =
                e.WorkDate instanceof Date
                    ? e.WorkDate.toISOString().slice(0, 10)
                    : String(e.WorkDate).slice(0, 10);
            const links = linksByEntry.get(e.ID.toLowerCase()) ?? [];
            const tsStatus = e.TimesheetID
                ? (timesheetStatusByID.get(e.TimesheetID.toLowerCase()) ?? null)
                : null;
            const lockedByTimesheet = tsStatus === 'Submitted' || tsStatus === 'Approved';
            const lockedByLinks = links.length > 0;
            const isLocked = lockedByTimesheet || lockedByLinks;
            let lockReason: string | null = null;
            if (lockedByTimesheet) {
                lockReason = `Timesheet ${tsStatus}`;
            } else if (lockedByLinks) {
                lockReason = `Used by ${links[0].LinkedEntity}`;
            }

            const isOwner = !!(this.currentPersonID && UUIDsEqual(this.currentPersonID, e.PersonID));
            return {
                ID: e.ID,
                PersonID: e.PersonID,
                Person: e.Person || e.PersonID,
                WorkDate: workDate,
                DurationMinutes: e.Minutes,
                DurationFormatted: FormatDurationClock(e.Minutes),
                StartedAt: e.StartedAt ? new Date(e.StartedAt).toISOString() : null,
                EndedAt: e.EndedAt ? new Date(e.EndedAt).toISOString() : null,
                IsBillable: e.IsBillable,
                Notes: e.Notes,
                Source: e.Source,
                TimesheetID: e.TimesheetID,
                TimesheetStatus: tsStatus,
                LinkedRecords: links,
                IsLocked: isLocked,
                LockReason: lockReason,
                CanModify: isOwner || this.canManageEntries,
            };
        });
    }

    private async loadAgentRuns(taskID: string, rv: RunView): Promise<void> {
        const res = await rv.RunView<{
            ID: string;
            AIAgentRunID: string;
            AIAgentRun: string | null;
            Notes: string | null;
        }>({
            EntityName: 'MJ_BizApps_Tasks: Task Agent Runs',
            ExtraFilter: `TaskID = '${taskID}'`,
            OrderBy: '__mj_CreatedAt DESC',
            ResultType: 'simple',
        });

        const rawLinks = res.Results ?? [];
        if (rawLinks.length === 0) {
            this.agentRuns = [];
            return;
        }

        const runIDs = rawLinks.map((r) => `'${r.AIAgentRunID}'`).join(',');
        const runsRes = await rv.RunView<{
            ID: string;
            Agent: string | null;
            Status: string | null;
            StartedAt: string | Date | null;
            CompletedAt: string | Date | null;
            TotalTokensUsedRollup: number | null;
            TotalTokensUsed: number | null;
            TotalCostRollup: number | null;
            TotalCost: number | null;
        }>({
            EntityName: 'MJ: AI Agent Runs',
            ExtraFilter: `ID IN (${runIDs})`,
            ResultType: 'simple',
        });
        const runDetailByID = new Map<string, NonNullable<typeof runsRes.Results>[number]>();
        for (const r of runsRes.Results ?? []) {
            runDetailByID.set(r.ID.toLowerCase(), r);
        }

        this.agentRuns = rawLinks.map((link) => {
            const run = runDetailByID.get(link.AIAgentRunID.toLowerCase());
            const startedStr = run?.StartedAt
                ? (run.StartedAt instanceof Date
                      ? run.StartedAt.toISOString().slice(0, 10)
                      : String(run.StartedAt).slice(0, 10))
                : null;
            let durationSec = 0;
            if (run?.StartedAt && run?.CompletedAt) {
                const s = new Date(run.StartedAt).getTime();
                const e = new Date(run.CompletedAt).getTime();
                if (Number.isFinite(s) && Number.isFinite(e) && e > s) {
                    durationSec = Math.round((e - s) / 1000);
                }
            }
            return {
                ID: link.ID,
                AgentRunID: link.AIAgentRunID,
                Agent: run?.Agent || link.AIAgentRun || 'AI Agent Run',
                Status: run?.Status || 'Completed',
                StartedAt: startedStr,
                DurationSeconds: durationSec,
                TotalTokens: Number(run?.TotalTokensUsedRollup ?? run?.TotalTokensUsed ?? 0),
                TotalCost: Number(run?.TotalCostRollup ?? run?.TotalCost ?? 0),
                Notes: link.Notes,
                CanUnlink: this.canManageEntries || !!this.currentPersonID,
            };
        });
    }

    private updateTimerElapsed(): void {
        if (!this.activeTimer) {
            this.timerElapsedDisplay = '0:00:00';
            return;
        }
        this.timerElapsedDisplay = ComputeTimerChipState(this.activeTimer.StartedAt).formattedWithSeconds;
    }

    private startTickInterval(): void {
        this.clearTickInterval();
        this.tickInterval = setInterval(() => {
            this.updateTimerElapsed();
            this.cdr.markForCheck();
        }, 1000);
    }

    private clearTickInterval(): void {
        if (this.tickInterval !== null) {
            clearInterval(this.tickInterval);
            this.tickInterval = null;
        }
    }

    private emptyEffort(): TaskEffortSummary {
        return {
            LoggedMinutes: 0,
            BillableMinutes: 0,
            TimeEntryCount: 0,
            HoursEstimated: null,
            AgentRunCount: 0,
            AgentDurationSeconds: 0,
            AgentTotalTokens: 0,
            AgentTotalCost: 0,
        };
    }
}
