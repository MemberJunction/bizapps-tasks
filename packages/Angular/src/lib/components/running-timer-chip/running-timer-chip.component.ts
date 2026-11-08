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
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';
import { SharedGenericModule } from '@memberjunction/ng-shared-generic';
import {
    FormatDurationClock,
    LONG_RUNNING_TIMER_WARNING_MINUTES,
    TasksSettings,
    TimeTrackingService,
} from '@mj-biz-apps/tasks-core';
import type { mjBizAppsTasksTaskTimerEntity } from '@mj-biz-apps/tasks-entities';
import { ResolveCurrentPersonID } from '../../current-person';
import { OpenTaskRecord } from '../../open-task-record';

/**
 * Snapshot of a person's active `TaskTimer` row as rendered by UI components.
 */
export interface ActiveTimerSnapshot {
    ID: string;
    TaskID: string;
    Task: string | null;
    PersonID: string;
    StartedAt: string | Date;
    Notes: string | null;
    IsBillable: boolean;
}

/**
 * Pure helper that computes elapsed seconds, minutes, formatted clock string (`H:MM:SS` or `H:MM`),
 * and whether the long-running warning threshold (`LONG_RUNNING_TIMER_WARNING_MINUTES`) is exceeded.
 *
 * @param startedAtIso - ISO-8601 timestamp or Date when the timer started.
 * @param nowMs - Current epoch milliseconds (defaults to `Date.now()`).
 */
export function ComputeTimerChipState(
    startedAtIso: string | Date,
    nowMs: number = Date.now(),
): {
    elapsedSeconds: number;
    elapsedMinutes: number;
    formattedClock: string;
    formattedWithSeconds: string;
    isLongRunningWarning: boolean;
} {
    const startMs = startedAtIso instanceof Date ? startedAtIso.getTime() : new Date(startedAtIso).getTime();
    const elapsedSeconds = Number.isFinite(startMs) ? Math.max(0, Math.floor((nowMs - startMs) / 1000)) : 0;
    const elapsedMinutes = Math.floor(elapsedSeconds / 60);
    const hours = Math.floor(elapsedSeconds / 3600);
    const minutes = Math.floor((elapsedSeconds % 3600) / 60);
    const seconds = elapsedSeconds % 60;
    const formattedClock = FormatDurationClock(Math.max(1, elapsedMinutes));
    const formattedWithSeconds = `${hours}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
    const isLongRunningWarning = elapsedMinutes >= LONG_RUNNING_TIMER_WARNING_MINUTES;

    return {
        elapsedSeconds,
        elapsedMinutes,
        formattedClock,
        formattedWithSeconds,
        isLongRunningWarning,
    };
}

/**
 * Header chip displaying the signed-in person's currently running task timer.
 *
 * Renders nothing when `TimeTrackingEnabled` is `false` or when the person has
 * no running timer. Loads the active timer once on initialization and after
 * explicit start/stop actions; elapsed time ticks locally in the browser without
 * polling the server.
 */
@Component({
    selector: 'bizapps-running-timer-chip',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [SharedGenericModule],
    template: `
        @if (timeTrackingEnabled && activeTimer) {
            <div class="timer-chip" [class.timer-chip--warning]="isLongRunningWarning" role="status" aria-live="polite">
                <span class="timer-pulse" aria-hidden="true"></span>
                <button
                    type="button"
                    class="timer-task-link"
                    (click)="onOpenTask()"
                    title="Open timed task">
                    <i class="fa-solid fa-stopwatch"></i>
                    <span class="timer-task-name">{{ activeTimer.Task || 'Active Task' }}</span>
                </button>
                <span class="timer-elapsed">{{ elapsedDisplay }}</span>
                @if (isLongRunningWarning) {
                    <span class="timer-warning-badge" title="Timer has been running for over 12 hours">
                        <i class="fa-solid fa-triangle-exclamation"></i> 12h+
                    </span>
                }
                @if (busy) {
                    <mj-loading [showText]="false" size="small"></mj-loading>
                } @else if (confirmingDiscard) {
                    <div class="timer-discard-confirm">
                        <span class="discard-label">Discard?</span>
                        <button type="button" class="btn-chip btn-chip--danger" (click)="confirmDiscard()">
                            Discard
                        </button>
                        <button type="button" class="btn-chip btn-chip--cancel" (click)="confirmingDiscard = false">
                            Cancel
                        </button>
                    </div>
                } @else {
                    <button
                        type="button"
                        class="btn-chip btn-chip--stop"
                        (click)="onStopTimer()"
                        title="Stop timer and log time">
                        <i class="fa-solid fa-stop"></i> Stop
                    </button>
                    <button
                        type="button"
                        class="btn-chip btn-chip--open"
                        (click)="onOpenTask()"
                        title="Open task">
                        <i class="fa-solid fa-arrow-up-right-from-square"></i>
                    </button>
                    <button
                        type="button"
                        class="btn-chip btn-chip--discard"
                        (click)="confirmingDiscard = true"
                        title="Discard running timer without logging time">
                        <i class="fa-solid fa-trash-can"></i>
                    </button>
                }
            </div>
        }
        @if (errorMessage) {
            <span class="timer-chip-error" role="alert">{{ errorMessage }}</span>
        }
    `,
    styles: [`
        :host {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-family: var(--mj-font-family);
        }
        .timer-chip {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 5px 10px;
            border-radius: var(--mj-radius-md);
            background: color-mix(in srgb, var(--mj-brand-primary) 10%, var(--mj-bg-surface));
            border: 1px solid color-mix(in srgb, var(--mj-brand-primary) 30%, var(--mj-border-default));
            color: var(--mj-text-primary);
            font-size: 13px;
        }
        .timer-chip--warning {
            background: var(--mj-status-warning-bg);
            border-color: var(--mj-status-warning-border);
        }
        .timer-pulse {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--mj-status-success);
            box-shadow: 0 0 0 3px color-mix(in srgb, var(--mj-status-success) 25%, transparent);
            flex-shrink: 0;
        }
        .timer-task-link {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            border: none;
            background: transparent;
            color: var(--mj-text-primary);
            font-weight: var(--mj-font-semibold);
            font-size: 13px;
            font-family: inherit;
            cursor: pointer;
            padding: 0;
            max-width: 220px;
        }
        .timer-task-link:hover {
            color: var(--mj-brand-primary);
        }
        .timer-task-name {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .timer-elapsed {
            font-variant-numeric: tabular-nums;
            font-weight: var(--mj-font-bold);
            color: var(--mj-brand-primary);
            padding: 1px 6px;
            border-radius: var(--mj-radius-sm);
            background: var(--mj-bg-surface);
        }
        .timer-warning-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 1px 6px;
            border-radius: var(--mj-radius-sm);
            background: var(--mj-status-warning);
            color: var(--mj-text-inverse);
            font-size: 11px;
            font-weight: var(--mj-font-bold);
        }
        .btn-chip {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 3px 8px;
            border-radius: var(--mj-radius-sm);
            font-size: 12px;
            font-weight: var(--mj-font-semibold);
            font-family: inherit;
            cursor: pointer;
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-secondary);
        }
        .btn-chip--stop {
            background: var(--mj-status-error);
            border-color: var(--mj-status-error);
            color: var(--mj-text-inverse);
        }
        .btn-chip--stop:hover {
            opacity: 0.9;
        }
        .btn-chip--open:hover {
            border-color: var(--mj-brand-primary);
            color: var(--mj-brand-primary);
        }
        .btn-chip--discard:hover {
            border-color: var(--mj-status-error);
            color: var(--mj-status-error);
        }
        .btn-chip--danger {
            background: var(--mj-status-error);
            border-color: var(--mj-status-error);
            color: var(--mj-text-inverse);
        }
        .timer-discard-confirm {
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .discard-label {
            font-size: 11px;
            font-weight: var(--mj-font-semibold);
            color: var(--mj-status-error);
        }
        .timer-chip-error {
            font-size: 12px;
            color: var(--mj-status-error);
        }
    `],
})
export class RunningTimerChipComponent implements OnInit, OnDestroy {
    private _personID: string | null = null;
    private timeTracking = new TimeTrackingService();

    /**
     * Person ID whose running timer should be shown. When null or omitted,
     * the component resolves the signed-in user's Person ID automatically.
     */
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

    /** Emitted after the running timer is stopped or discarded. Payload is the task ID. */
    @Output() public TimerStopped = new EventEmitter<string>();

    /** Emitted when the user clicks the task name or open button. Payload is the task ID. */
    @Output() public OpenTaskRequested = new EventEmitter<string>();

    public timeTrackingEnabled = false;
    public activeTimer: ActiveTimerSnapshot | null = null;
    public elapsedDisplay = '0:00:00';
    public isLongRunningWarning = false;
    public busy = false;
    public confirmingDiscard = false;
    public errorMessage = '';

    private initialized = false;
    private tickInterval: ReturnType<typeof setInterval> | null = null;
    private cdr = inject(ChangeDetectorRef);

    public ngOnInit(): void {
        this.initialized = true;
        void this.Refresh();
    }

    public ngOnDestroy(): void {
        this.clearTickInterval();
    }

    /**
     * Reloads the feature setting and the person's active timer from the server.
     */
    public async Refresh(): Promise<void> {
        this.errorMessage = '';
        this.confirmingDiscard = false;

        try {
            await TasksSettings.Load(Metadata.Provider);
        } catch {
            // Fall back to cached / default settings
        }
        this.timeTrackingEnabled = TasksSettings.TimeTrackingEnabled(Metadata.Provider);
        if (!this.timeTrackingEnabled) {
            this.activeTimer = null;
            this.clearTickInterval();
            this.cdr.markForCheck();
            return;
        }

        let personID = this._personID;
        if (!personID) {
            try {
                personID = await ResolveCurrentPersonID();
            } catch {
                personID = null;
            }
        }
        if (!personID) {
            this.activeTimer = null;
            this.clearTickInterval();
            this.cdr.markForCheck();
            return;
        }

        const rv = new RunView();
        const timerRes = await rv.RunView<ActiveTimerSnapshot>({
            EntityName: 'MJ_BizApps_Tasks: Task Timers',
            ExtraFilter: `PersonID = '${personID}'`,
            ResultType: 'simple',
            MaxRows: 1,
            BypassCache: true,
        });
        this.activeTimer = timerRes?.Results?.[0] ?? null;
        if (this.activeTimer) {
            this.updateElapsedDisplay();
            this.startTickInterval();
        } else {
            this.clearTickInterval();
        }
        this.cdr.markForCheck();
    }

    public async onStopTimer(): Promise<void> {
        if (!this.activeTimer || this.busy) {
            return;
        }
        const taskID = this.activeTimer.TaskID;
        this.busy = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const res = await this.timeTracking.StopTimer({});
            if (!res.Success) {
                throw new Error(res.ErrorMessage || 'Could not stop timer.');
            }
            this.activeTimer = null;
            this.clearTickInterval();
            this.TimerStopped.emit(taskID);
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not stop timer.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public async confirmDiscard(): Promise<void> {
        if (!this.activeTimer || this.busy) {
            return;
        }
        const timerID = this.activeTimer.ID;
        const taskID = this.activeTimer.TaskID;
        this.busy = true;
        this.errorMessage = '';
        this.cdr.markForCheck();
        try {
            const md = new Metadata();
            const timerEntity = await md.GetEntityObject<mjBizAppsTasksTaskTimerEntity>('MJ_BizApps_Tasks: Task Timers');
            const loaded = await timerEntity.InnerLoad(CompositeKey.FromID(timerID));
            if (loaded) {
                const deleted = await timerEntity.Delete();
                if (!deleted) {
                    throw new Error(timerEntity.LatestResult?.CompleteMessage || 'Could not discard timer.');
                }
            }
            this.activeTimer = null;
            this.confirmingDiscard = false;
            this.clearTickInterval();
            this.TimerStopped.emit(taskID);
        } catch (err) {
            this.errorMessage = err instanceof Error ? err.message : 'Could not discard timer.';
        } finally {
            this.busy = false;
            this.cdr.markForCheck();
        }
    }

    public onOpenTask(): void {
        if (!this.activeTimer) {
            return;
        }
        this.OpenTaskRequested.emit(this.activeTimer.TaskID);
        OpenTaskRecord(this.activeTimer.TaskID);
    }

    public updateElapsedDisplay(nowMs: number = Date.now()): void {
        if (!this.activeTimer) {
            this.elapsedDisplay = '0:00:00';
            this.isLongRunningWarning = false;
            return;
        }
        const state = ComputeTimerChipState(this.activeTimer.StartedAt, nowMs);
        this.elapsedDisplay = state.formattedWithSeconds;
        this.isLongRunningWarning = state.isLongRunningWarning;
    }

    private startTickInterval(): void {
        this.clearTickInterval();
        this.tickInterval = setInterval(() => {
            this.updateElapsedDisplay();
            this.cdr.markForCheck();
        }, 1000);
    }

    private clearTickInterval(): void {
        if (this.tickInterval !== null) {
            clearInterval(this.tickInterval);
            this.tickInterval = null;
        }
    }
}
