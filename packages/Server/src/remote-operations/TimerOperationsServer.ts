import {
    BaseRemotableOperation,
    IMetadataProvider,
    IRunViewProvider,
    RemoteOpServerContext,
    RunInEntityTransaction,
    RunView,
    UserInfo,
} from '@memberjunction/core';
import { IsValidUUID, RegisterClass } from '@memberjunction/global';
import { BusinessTimeZoneEngine, FromCalendarDay, UTC_ZONE } from '@mj-biz-apps/common-entities';
import {
    StartTimerInput,
    StartTimerOutput,
    StopTimerInput,
    StopTimerOutput,
    TasksStartTimerOperation,
    TasksStopTimerOperation,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskTimeEntryEntity,
    mjBizAppsTasksTaskTimerEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    ResolveTimeZoneOrUtc,
    SplitIntervalByBusinessDay,
    TasksSettings,
    UserCanManageTimeEntries,
} from '@mj-biz-apps/tasks-core';
import { PeopleForUser } from '@mj-biz-apps/tasks-entities-server';

/**
 * Adapts an `IMetadataProvider` to the transaction host accepted by `RunInEntityTransaction`.
 */
export function AsTransactionHost(
    provider: IMetadataProvider,
): Parameters<typeof RunInEntityTransaction>[0] {
    return provider as unknown as Parameters<typeof RunInEntityTransaction>[0];
}

/**
 * Resolves the effective IANA business time zone for timer day splitting.
 */
export async function ResolveBusinessTimeZone(
    provider: IMetadataProvider,
    user: UserInfo,
): Promise<string> {
    try {
        await BusinessTimeZoneEngine.Instance.Config(false, user, provider);
        return ResolveTimeZoneOrUtc(BusinessTimeZoneEngine.Instance.Zone);
    } catch {
        return UTC_ZONE;
    }
}

/**
 * Stops an existing `TaskTimer` row by splitting its `[StartedAt, endedAt]` interval
 * into per-business-day `TaskTimeEntry` rows (`Source = 'Timer'`) and deleting the timer.
 * Must be called inside `RunInEntityTransaction`.
 */
export async function ConvertTimerToEntriesInTransaction(
    timer: mjBizAppsTasksTaskTimerEntity,
    endedAt: Date,
    notesOverride: string | undefined,
    isBillableOverride: boolean | undefined,
    discardIfUnderSeconds: number | undefined,
    zone: string,
    roundingMinutes: number,
    provider: IMetadataProvider,
    user: UserInfo,
): Promise<{ CreatedTimeEntryIDs: string[]; TotalMinutes: number; Discarded: boolean }> {
    const startedAt = new Date(timer.StartedAt);
    const elapsedSeconds = Math.max(0, (endedAt.getTime() - startedAt.getTime()) / 1000);

    if (discardIfUnderSeconds != null && discardIfUnderSeconds > 0 && elapsedSeconds < discardIfUnderSeconds) {
        const deleted = await timer.Delete();
        if (!deleted) {
            throw new Error(
                timer.LatestResult?.CompleteMessage ||
                timer.ResultHistory?.[timer.ResultHistory.length - 1]?.Message ||
                'Failed to discard timer.',
            );
        }
        return { CreatedTimeEntryIDs: [], TotalMinutes: 0, Discarded: true };
    }

    const pieces = SplitIntervalByBusinessDay(startedAt, endedAt, zone, roundingMinutes);
    const createdIDs: string[] = [];
    let totalMinutes = 0;

    const effectiveNotes = notesOverride !== undefined ? notesOverride : timer.Notes;
    const effectiveBillable = isBillableOverride !== undefined ? isBillableOverride : timer.IsBillable;

    for (const piece of pieces) {
        const entry = await provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
            'MJ_BizApps_Tasks: Task Time Entries',
            user,
        );
        entry.NewRecord();
        entry.TaskID = timer.TaskID;
        entry.PersonID = timer.PersonID;
        entry.WorkDate = FromCalendarDay(piece.WorkDate);
        entry.StartedAt = piece.StartedAt;
        entry.EndedAt = piece.EndedAt;
        entry.Minutes = piece.Minutes;
        entry.Source = 'Timer';
        entry.IsBillable = effectiveBillable;
        if (effectiveNotes != null) {
            entry.Notes = effectiveNotes;
        }

        const saved = await entry.Save();
        if (!saved) {
            const msg =
                entry.LatestResult?.CompleteMessage ||
                entry.ResultHistory?.[entry.ResultHistory.length - 1]?.Message ||
                `Failed to save timer time entry for ${piece.WorkDate}.`;
            throw new Error(msg);
        }
        createdIDs.push(entry.ID);
        totalMinutes += entry.Minutes;
    }

    const timerDeleted = await timer.Delete();
    if (!timerDeleted) {
        const msg =
            timer.LatestResult?.CompleteMessage ||
            timer.ResultHistory?.[timer.ResultHistory.length - 1]?.Message ||
            'Failed to delete running timer after saving time entries.';
        throw new Error(msg);
    }

    return {
        CreatedTimeEntryIDs: createdIDs,
        TotalMinutes: totalMinutes,
        Discarded: false,
    };
}

/**
 * Server implementation of `Tasks.StartTimer` (§6.2).
 */
@RegisterClass(BaseRemotableOperation, 'Tasks.StartTimer')
export class StartTimerOperationServer extends TasksStartTimerOperation {
    protected override async InternalExecute(
        input: StartTimerInput,
        provider: IMetadataProvider,
        user: UserInfo,
        _context: RemoteOpServerContext,
    ): Promise<StartTimerOutput> {
        await TasksSettings.Load(provider, user);
        if (!TasksSettings.TimeTrackingEnabled(provider)) {
            return {
                Success: false,
                Message: 'Time tracking is disabled for the Tasks application.',
            };
        }

        if (!input?.TaskID || !IsValidUUID(input.TaskID)) {
            return {
                Success: false,
                Message: 'A valid TaskID is required to start a timer.',
            };
        }

        const rvProvider = provider as unknown as IRunViewProvider;
        const callerPersonIDs = await PeopleForUser(provider, rvProvider, user);
        const targetPersonID = input.PersonID?.trim() || callerPersonIDs[0] || null;
        if (!targetPersonID || !IsValidUUID(targetPersonID)) {
            return {
                Success: false,
                Message: "You can't start a timer: your user has no person record.",
            };
        }

        const isOwnPerson = callerPersonIDs.some((id) => id.toLowerCase() === targetPersonID.toLowerCase());
        if (!isOwnPerson && !UserCanManageTimeEntries(user, provider)) {
            return {
                Success: false,
                Message: 'Only the timer owner or a time-entry manager can start a timer for this person.',
            };
        }

        const rv = new RunView(rvProvider);
        const [taskRes, existingTimersRes] = await Promise.all([
            rv.RunView<mjBizAppsTasksTaskEntity>(
                {
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: `ID='${input.TaskID}'`,
                    Fields: ['ID', 'Name'],
                    MaxRows: 1,
                    ResultType: 'simple',
                    BypassCache: true,
                },
                user,
            ),
            rv.RunView<mjBizAppsTasksTaskTimerEntity>(
                {
                    EntityName: 'MJ_BizApps_Tasks: Task Timers',
                    ExtraFilter: `PersonID='${targetPersonID}'`,
                    MaxRows: 1,
                    ResultType: 'entity_object',
                    BypassCache: true,
                },
                user,
            ),
        ]);

        if (!taskRes?.Success || (taskRes.Results?.length ?? 0) === 0) {
            return {
                Success: false,
                Message: 'The task was not found.',
            };
        }

        const existingTimer = existingTimersRes?.Results?.[0] ?? null;
        if (existingTimer && existingTimer.TaskID.toLowerCase() === input.TaskID.toLowerCase()) {
            return {
                Success: true,
                Message: 'Timer is already running on this task.',
                TimerID: existingTimer.ID,
                StartedAt: new Date(existingTimer.StartedAt).toISOString(),
                AutoStoppedEntryIDs: [],
                AutoStoppedMinutes: 0,
            };
        }

        const zone = await ResolveBusinessTimeZone(provider, user);
        const rounding = TasksSettings.TimeEntryRoundingMinutes(provider);

        try {
            return await RunInEntityTransaction(AsTransactionHost(provider), async () => {
                let autoStoppedIDs: string[] = [];
                let autoStoppedMinutes = 0;

                if (existingTimer) {
                    const stopped = await ConvertTimerToEntriesInTransaction(
                        existingTimer,
                        new Date(),
                        undefined,
                        undefined,
                        undefined,
                        zone,
                        rounding,
                        provider,
                        user,
                    );
                    autoStoppedIDs = stopped.CreatedTimeEntryIDs;
                    autoStoppedMinutes = stopped.TotalMinutes;
                }

                const newTimer = await provider.GetEntityObject<mjBizAppsTasksTaskTimerEntity>(
                    'MJ_BizApps_Tasks: Task Timers',
                    user,
                );
                newTimer.NewRecord();
                newTimer.TaskID = input.TaskID;
                newTimer.PersonID = targetPersonID;
                newTimer.StartedAt = new Date();
                if (input.Notes !== undefined) {
                    newTimer.Notes = input.Notes;
                }
                if (input.IsBillable !== undefined) {
                    newTimer.IsBillable = input.IsBillable;
                }

                const saved = await newTimer.Save();
                if (!saved) {
                    const msg =
                        newTimer.LatestResult?.CompleteMessage ||
                        newTimer.ResultHistory?.[newTimer.ResultHistory.length - 1]?.Message ||
                        'Failed to start timer.';
                    throw new Error(msg);
                }

                return {
                    Success: true,
                    Message: 'Timer started.',
                    TimerID: newTimer.ID,
                    StartedAt: new Date(newTimer.StartedAt).toISOString(),
                    AutoStoppedEntryIDs: autoStoppedIDs,
                    AutoStoppedMinutes: autoStoppedMinutes,
                };
            });
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            return {
                Success: false,
                Message: msg,
            };
        }
    }
}

/**
 * Server implementation of `Tasks.StopTimer` (§6.2).
 */
@RegisterClass(BaseRemotableOperation, 'Tasks.StopTimer')
export class StopTimerOperationServer extends TasksStopTimerOperation {
    protected override async InternalExecute(
        input: StopTimerInput,
        provider: IMetadataProvider,
        user: UserInfo,
        _context: RemoteOpServerContext,
    ): Promise<StopTimerOutput> {
        await TasksSettings.Load(provider, user);
        if (!TasksSettings.TimeTrackingEnabled(provider)) {
            return {
                Success: false,
                Message: 'Time tracking is disabled for the Tasks application.',
                CreatedTimeEntryIDs: [],
                TotalMinutes: 0,
                Discarded: false,
            };
        }

        const rvProvider = provider as unknown as IRunViewProvider;
        const callerPersonIDs = await PeopleForUser(provider, rvProvider, user);
        const targetPersonID = input?.PersonID?.trim() || callerPersonIDs[0] || null;
        if (!targetPersonID || !IsValidUUID(targetPersonID)) {
            return {
                Success: false,
                Message: "You can't stop a timer: your user has no person record.",
                CreatedTimeEntryIDs: [],
                TotalMinutes: 0,
                Discarded: false,
            };
        }

        const isOwnPerson = callerPersonIDs.some((id) => id.toLowerCase() === targetPersonID.toLowerCase());
        if (!isOwnPerson && !UserCanManageTimeEntries(user, provider)) {
            return {
                Success: false,
                Message: 'Only the timer owner or a time-entry manager can stop this timer.',
                CreatedTimeEntryIDs: [],
                TotalMinutes: 0,
                Discarded: false,
            };
        }

        const rv = new RunView(rvProvider);
        const timerRes = await rv.RunView<mjBizAppsTasksTaskTimerEntity>(
            {
                EntityName: 'MJ_BizApps_Tasks: Task Timers',
                ExtraFilter: `PersonID='${targetPersonID}'`,
                MaxRows: 1,
                ResultType: 'entity_object',
                BypassCache: true,
            },
            user,
        );
        const timer = timerRes?.Results?.[0] ?? null;
        if (!timer) {
            return {
                Success: false,
                Message: 'No running timer found.',
                CreatedTimeEntryIDs: [],
                TotalMinutes: 0,
                Discarded: false,
            };
        }

        const now = new Date();
        const endedAt = input?.EndedAt ? new Date(input.EndedAt) : now;
        if (Number.isNaN(endedAt.getTime())) {
            return {
                Success: false,
                Message: 'EndedAt is not a valid timestamp.',
                CreatedTimeEntryIDs: [],
                TotalMinutes: 0,
                Discarded: false,
            };
        }

        const startedAt = new Date(timer.StartedAt);
        if (endedAt <= startedAt) {
            return {
                Success: false,
                Message: 'EndedAt must be after the timer StartedAt timestamp.',
                CreatedTimeEntryIDs: [],
                TotalMinutes: 0,
                Discarded: false,
            };
        }
        // Allow up to 60 seconds clock skew
        if (endedAt.getTime() > now.getTime() + 60_000) {
            return {
                Success: false,
                Message: 'EndedAt cannot be in the future.',
                CreatedTimeEntryIDs: [],
                TotalMinutes: 0,
                Discarded: false,
            };
        }

        const zone = await ResolveBusinessTimeZone(provider, user);
        const rounding = TasksSettings.TimeEntryRoundingMinutes(provider);

        try {
            return await RunInEntityTransaction(AsTransactionHost(provider), async () => {
                const outcome = await ConvertTimerToEntriesInTransaction(
                    timer,
                    endedAt,
                    input?.Notes,
                    input?.IsBillable,
                    input?.DiscardIfUnderSeconds,
                    zone,
                    rounding,
                    provider,
                    user,
                );
                return {
                    Success: true,
                    Message: outcome.Discarded
                        ? 'Timer discarded.'
                        : `Stopped timer and logged ${outcome.TotalMinutes} minute(s).`,
                    CreatedTimeEntryIDs: outcome.CreatedTimeEntryIDs,
                    TotalMinutes: outcome.TotalMinutes,
                    Discarded: outcome.Discarded,
                };
            });
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            return {
                Success: false,
                Message: msg,
                CreatedTimeEntryIDs: [],
                TotalMinutes: 0,
                Discarded: false,
            };
        }
    }
}
