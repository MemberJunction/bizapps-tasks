/**
 * Client- and server-safe orchestration service for Tasks time tracking, timers, AI agent run linking,
 * and timesheet periods (`@mj-biz-apps/tasks-core`).
 *
 * Wraps the generated Remote Operation classes (`TasksStartTimerOperation`, `TasksStopTimerOperation`,
 * `TasksGetTaskEffortOperation`, `TasksSubmitTimesheetOperation`, `TasksWithdrawTimesheetOperation`,
 * `TasksReopenTimesheetOperation`) and strongly typed entity classes from `@mj-biz-apps/tasks-entities`.
 */
import {
    Metadata,
    RunView,
    type IMetadataProvider,
    type IRunViewProvider,
    type RemoteOpResult,
    type UserInfo,
} from '@memberjunction/core';
import { IsValidUUID } from '@memberjunction/global';
import { FromCalendarDay, ToCalendarDay, type CalendarDay } from '@mj-biz-apps/common-entities';
import {
    TasksGetTaskEffortOperation,
    TasksReopenTimesheetOperation,
    TasksStartTimerOperation,
    TasksStopTimerOperation,
    TasksSubmitTimesheetOperation,
    TasksWithdrawTimesheetOperation,
    type GetTaskEffortInput,
    type GetTaskEffortOutput,
    type ReopenTimesheetInput,
    type ReopenTimesheetOutput,
    type StartTimerInput,
    type StartTimerOutput,
    type StopTimerInput,
    type StopTimerOutput,
    type SubmitTimesheetInput,
    type SubmitTimesheetOutput,
    type WithdrawTimesheetInput,
    type WithdrawTimesheetOutput,
    type mjBizAppsTasksTaskAgentRunEntity,
    type mjBizAppsTasksTaskTimeEntryEntity,
    type mjBizAppsTasksTaskTimerEntity,
    type mjBizAppsTasksTimesheetScheduleEntity,
} from '@mj-biz-apps/tasks-entities';
import { TasksSettings } from '../config/TasksSettings.js';
import { DeriveIntervalMinutes } from '../time/TimeEntryAuthority.js';
import {
    PeriodFor,
    ResolveScheduleForDate,
    type EffectiveScheduleCandidate,
    type TimesheetPeriodBounds,
} from '../time/TimesheetPeriod.js';

/** Parameters for creating or updating a manual time entry via {@link TimeTrackingService.LogTime}. */
export interface LogTimeParams {
    ID?: string;
    TaskID: string;
    PersonID?: string;
    WorkDate: CalendarDay | Date;
    Minutes?: number;
    StartedAt?: Date | null;
    EndedAt?: Date | null;
    Notes?: string | null;
    IsBillable?: boolean;
    Source?: mjBizAppsTasksTaskTimeEntryEntity['Source'];
}

/** Parameters for linking an AI agent run to a task via {@link TimeTrackingService.LinkAgentRunToTask}. */
export interface LinkAgentRunParams {
    TaskID: string;
    AIAgentRunID: string;
    Role?: mjBizAppsTasksTaskAgentRunEntity['Role'];
    Notes?: string | null;
}

/**
 * Orchestrates time entries, stopwatch timers, AI agent effort attribution, and timesheet submissions.
 */
export class TimeTrackingService {
    /**
     * Starts a stopwatch timer on a task via `Tasks.StartTimer`.
     */
    public async StartTimer(
        input: StartTimerInput,
        contextUser?: UserInfo,
        provider?: IMetadataProvider,
    ): Promise<RemoteOpResult<StartTimerOutput>> {
        return new TasksStartTimerOperation().Execute(input, { user: contextUser, provider });
    }

    /**
     * Stops the active stopwatch timer via `Tasks.StopTimer`, splitting cross-midnight intervals by business day.
     */
    public async StopTimer(
        input: StopTimerInput = {},
        contextUser?: UserInfo,
        provider?: IMetadataProvider,
    ): Promise<RemoteOpResult<StopTimerOutput>> {
        return new TasksStopTimerOperation().Execute(input, { user: contextUser, provider });
    }

    /**
     * Discards a running `TaskTimer` row without creating any time entries (§6.2).
     */
    public async DiscardTimer(timerID: string, contextUser?: UserInfo): Promise<boolean> {
        if (!IsValidUUID(timerID)) {
            throw new Error(`Invalid TimerID '${timerID}'.`);
        }
        const md = new Metadata();
        const timer = await md.GetEntityObject<mjBizAppsTasksTaskTimerEntity>(
            'MJ_BizApps_Tasks: Task Timers',
            contextUser,
        );
        const loaded = await timer.Load(timerID);
        if (!loaded) {
            return false;
        }
        return timer.Delete();
    }

    /**
     * Loads the active `TaskTimer` row for a `personID`, or `null` if no timer is running.
     */
    public async GetRunningTimer(
        personID: string,
        contextUser?: UserInfo,
        runViewProvider?: IRunViewProvider,
    ): Promise<mjBizAppsTasksTaskTimerEntity | null> {
        if (!IsValidUUID(personID)) {
            throw new Error(`Invalid PersonID '${personID}'.`);
        }
        const rv = new RunView(runViewProvider);
        const res = await rv.RunView<mjBizAppsTasksTaskTimerEntity>(
            {
                EntityName: 'MJ_BizApps_Tasks: Task Timers',
                ExtraFilter: `PersonID = '${personID}'`,
                ResultType: 'entity_object',
                MaxRows: 1,
                BypassCache: true,
            },
            contextUser,
        );
        if (!res?.Success) {
            throw new Error(res?.ErrorMessage ?? 'Failed to load running timer.');
        }
        return res.Results?.[0] ?? null;
    }

    /**
     * Creates or updates a `TaskTimeEntry` row (`MJ_BizApps_Tasks: Task Time Entries`).
     */
    public async LogTime(
        params: LogTimeParams,
        contextUser?: UserInfo,
    ): Promise<mjBizAppsTasksTaskTimeEntryEntity> {
        const md = new Metadata();
        const entry = await md.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
            'MJ_BizApps_Tasks: Task Time Entries',
            contextUser,
        );

        if (params.ID) {
            const loaded = await entry.Load(params.ID);
            if (!loaded) {
                throw new Error(`TaskTimeEntry '${params.ID}' not found.`);
            }
        } else {
            entry.NewRecord();
            entry.Source = params.Source ?? 'Manual';
        }

        entry.TaskID = params.TaskID;
        if (params.PersonID) {
            entry.PersonID = params.PersonID;
        }
        const workDay = ToCalendarDay(params.WorkDate);
        if (!workDay) {
            throw new Error(`Invalid WorkDate '${String(params.WorkDate)}'.`);
        }
        entry.WorkDate = FromCalendarDay(workDay);

        if (params.StartedAt !== undefined) {
            entry.StartedAt = params.StartedAt;
        }
        if (params.EndedAt !== undefined) {
            entry.EndedAt = params.EndedAt;
        }

        if (entry.StartedAt && entry.EndedAt) {
            const derived = DeriveIntervalMinutes(entry.StartedAt, entry.EndedAt);
            if (derived != null) {
                entry.Minutes = derived;
            }
        } else if (params.Minutes != null) {
            entry.Minutes = Math.round(params.Minutes);
        }

        if (params.Notes !== undefined) {
            entry.Notes = params.Notes;
        }
        if (params.IsBillable !== undefined) {
            entry.IsBillable = params.IsBillable;
        }

        const saved = await entry.Save();
        if (!saved) {
            const msg = entry.LatestResult?.CompleteMessage || entry.LatestResult?.Message || 'Failed to save time entry.';
            throw new Error(msg);
        }
        return entry;
    }

    /**
     * Reads a task's own and subtree effort metrics via `Tasks.GetTaskEffort`.
     */
    public async GetTaskEffort(
        input: GetTaskEffortInput,
        contextUser?: UserInfo,
        provider?: IMetadataProvider,
    ): Promise<RemoteOpResult<GetTaskEffortOutput>> {
        return new TasksGetTaskEffortOperation().Execute(input, { user: contextUser, provider });
    }

    /**
     * Links an AI agent run (`MJ: AI Agent Runs`) to a task (`MJ_BizApps_Tasks: Task Agent Runs`).
     */
    public async LinkAgentRunToTask(
        params: LinkAgentRunParams,
        contextUser?: UserInfo,
    ): Promise<mjBizAppsTasksTaskAgentRunEntity> {
        const md = new Metadata();
        const link = await md.GetEntityObject<mjBizAppsTasksTaskAgentRunEntity>(
            'MJ_BizApps_Tasks: Task Agent Runs',
            contextUser,
        );
        link.NewRecord();
        link.TaskID = params.TaskID;
        link.AIAgentRunID = params.AIAgentRunID;
        link.Role = params.Role ?? 'Executed';
        if (params.Notes !== undefined) {
            link.Notes = params.Notes;
        }
        const saved = await link.Save();
        if (!saved) {
            const msg = link.LatestResult?.CompleteMessage || link.LatestResult?.Message || 'Failed to link agent run to task.';
            throw new Error(msg);
        }
        return link;
    }

    /**
     * Removes a `TaskAgentRun` link by ID.
     */
    public async UnlinkAgentRunFromTask(taskAgentRunID: string, contextUser?: UserInfo): Promise<boolean> {
        if (!IsValidUUID(taskAgentRunID)) {
            throw new Error(`Invalid TaskAgentRun ID '${taskAgentRunID}'.`);
        }
        const md = new Metadata();
        const link = await md.GetEntityObject<mjBizAppsTasksTaskAgentRunEntity>(
            'MJ_BizApps_Tasks: Task Agent Runs',
            contextUser,
        );
        const loaded = await link.Load(taskAgentRunID);
        if (!loaded) {
            return false;
        }
        return link.Delete();
    }

    /**
     * Submits a timesheet period for approval via `Tasks.SubmitTimesheet`.
     */
    public async SubmitTimesheet(
        input: SubmitTimesheetInput,
        contextUser?: UserInfo,
        provider?: IMetadataProvider,
    ): Promise<RemoteOpResult<SubmitTimesheetOutput>> {
        return new TasksSubmitTimesheetOperation().Execute(input, { user: contextUser, provider });
    }

    /**
     * Withdraws a `Submitted` timesheet back to `Draft` via `Tasks.WithdrawTimesheet`.
     */
    public async WithdrawTimesheet(
        input: WithdrawTimesheetInput,
        contextUser?: UserInfo,
        provider?: IMetadataProvider,
    ): Promise<RemoteOpResult<WithdrawTimesheetOutput>> {
        return new TasksWithdrawTimesheetOperation().Execute(input, { user: contextUser, provider });
    }

    /**
     * Reopens an `Approved` timesheet back to `Draft` via `Tasks.ReopenTimesheet` (requires `Manage Timesheets`).
     */
    public async ReopenTimesheet(
        input: ReopenTimesheetInput,
        contextUser?: UserInfo,
        provider?: IMetadataProvider,
    ): Promise<RemoteOpResult<ReopenTimesheetOutput>> {
        return new TasksReopenTimesheetOperation().Execute(input, { user: contextUser, provider });
    }

    /**
     * Resolves the inclusive `[PeriodStart, PeriodEnd]` timesheet period for `workDate` and optional `personID`,
     * consulting `MJ_BizApps_Tasks: Timesheet Schedules` first and falling back to `TasksSettings`.
     */
    public async ResolvePeriodForDate(
        workDate: CalendarDay | Date,
        personID?: string | null,
        contextUser?: UserInfo,
        runViewProvider?: IRunViewProvider,
    ): Promise<TimesheetPeriodBounds> {
        const provider = Metadata.Provider;
        if (contextUser) {
            await TasksSettings.Load(provider, contextUser);
        }

        const rv = new RunView(runViewProvider);
        const filter =
            personID && IsValidUUID(personID)
                ? `PersonID IS NULL OR PersonID = '${personID}'`
                : 'PersonID IS NULL';

        const scheduleRes = await rv.RunView<mjBizAppsTasksTimesheetScheduleEntity>(
            {
                EntityName: 'MJ_BizApps_Tasks: Timesheet Schedules',
                ExtraFilter: filter,
                ResultType: 'simple',
                BypassCache: true,
            },
            contextUser,
        );

        const candidates: EffectiveScheduleCandidate[] = (scheduleRes?.Results ?? []).map((row) => ({
            ID: row.ID,
            PersonID: row.PersonID,
            ScopeEntityID: row.ScopeEntityID,
            ScopeRecordID: row.ScopeRecordID,
            Cadence: row.Cadence,
            WeekStartDay: row.WeekStartDay,
            BiWeeklyAnchorDate: row.BiWeeklyAnchorDate,
            EffectiveFrom: row.EffectiveFrom,
            EffectiveTo: row.EffectiveTo,
        }));

        const matched = ResolveScheduleForDate(workDate, candidates, personID);
        if (matched) {
            return PeriodFor(workDate, {
                Cadence: matched.Cadence,
                WeekStartDay: matched.WeekStartDay,
                BiWeeklyAnchorDate: matched.BiWeeklyAnchorDate,
            });
        }

        return PeriodFor(workDate, {
            Cadence: TasksSettings.TimesheetCadence(provider),
            WeekStartDay: TasksSettings.TimesheetWeekStartDay(provider),
            BiWeeklyAnchorDate: TasksSettings.TimesheetBiWeeklyAnchorDate(provider),
        });
    }
}
