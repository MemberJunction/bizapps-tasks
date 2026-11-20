import {
    Assert,
    AssertEqual,
    IntegrationCheckRegistry,
    type NamedCheck,
} from '@memberjunction/testing-integration/registry';
import { AddDays, ToCalendarDay } from '@mj-biz-apps/common-entities';
import {
    TasksStartTimerOperation,
    TasksStopTimerOperation,
    mjBizAppsTasksTaskTimeEntryEntity,
    mjBizAppsTasksTaskTimerEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    TASK_TIMER_ENTITY,
    TASK_TIME_ENTRY_ENTITY,
} from '../entity-names.js';
import {
    FindRows,
    PersonaUser,
    RequireRefusal,
    RequireSave,
    SameID,
    WithTasksSetting,
} from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

async function cleanupPersonTimersAndEntries(
    ctx: Parameters<NamedCheck['Fn']>[0],
    personID: string,
    entryIDs: readonly string[],
): Promise<void> {
    const timers = await FindRows<{ ID: string }>(ctx, TASK_TIMER_ENTITY, `PersonID = '${personID}'`, ['ID']);
    for (const row of timers) {
        const timer = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimerEntity>(TASK_TIMER_ENTITY, ctx.User);
        if (await timer.Load(row.ID)) {
            await timer.Delete();
        }
    }
    for (const id of entryIDs) {
        const entry = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
            TASK_TIME_ENTRY_ENTITY,
            ctx.User,
        );
        if (await entry.Load(id)) {
            await entry.Delete();
        }
    }
}

const checks: NamedCheck[] = [
    {
        Id: 'timers.TMR1',
        Name: 'TMR1 — StartTimer then StopTimer creates a Timer time entry and deletes the TaskTimer row',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const taskID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const sarah = world.People['sarah.connor@task-world.test'];
            const sarahUser = PersonaUser(ctx, sarah.ID, { canManage: false });
            const createdEntryIDs: string[] = [];

            await cleanupPersonTimersAndEntries(ctx, sarah.ID, []);

            try {
                const startRes = await new TasksStartTimerOperation().Execute(
                    {
                        TaskID: taskID,
                        Notes: 'TMR1 stopwatch work',
                        IsBillable: true,
                    },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(startRes.Success && !!startRes.Output?.Success, `StartTimer succeeded: ${startRes.Output?.Message}`);
                const timerID = startRes.Output!.TimerID!;
                Assert(!!timerID, 'TimerID returned');

                // Backdate StartedAt by 45 minutes so StopTimer records a 45-minute entry
                const timerEntity = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimerEntity>(
                    TASK_TIMER_ENTITY,
                    sarahUser,
                );
                Assert(await timerEntity.Load(timerID), 'load active timer');
                const endedAt = new Date();
                const startedAt = new Date(endedAt.getTime() - 45 * 60_000);
                timerEntity.StartedAt = startedAt;
                await RequireSave(timerEntity, 'TMR1 backdate timer StartedAt');

                const stopRes = await new TasksStopTimerOperation().Execute(
                    { EndedAt: endedAt.toISOString() },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(stopRes.Success && !!stopRes.Output?.Success, `StopTimer succeeded: ${stopRes.Output?.Message}`);
                createdEntryIDs.push(...(stopRes.Output!.CreatedTimeEntryIDs ?? []));

                AssertEqual(stopRes.Output!.Discarded, false, 'timer not discarded');
                AssertEqual(stopRes.Output!.TotalMinutes, 45, 'logged 45 minutes');
                AssertEqual(createdEntryIDs.length, 1, 'created 1 time entry');

                const remainingTimers = await FindRows<{ ID: string }>(
                    ctx,
                    TASK_TIMER_ENTITY,
                    `PersonID = '${sarah.ID}'`,
                    ['ID'],
                );
                AssertEqual(remainingTimers.length, 0, 'TaskTimer row deleted on stop');

                const entry = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    sarahUser,
                );
                Assert(await entry.Load(createdEntryIDs[0]), 'load created timer entry');
                AssertEqual(entry.Source, 'Timer', 'entry Source is Timer');
                AssertEqual(entry.Minutes, 45, 'entry Minutes is 45');
                AssertEqual(entry.IsBillable, true, 'entry IsBillable carried over');
                AssertEqual(entry.Notes, 'TMR1 stopwatch work', 'entry Notes carried over');
            } finally {
                await cleanupPersonTimersAndEntries(ctx, sarah.ID, createdEntryIDs);
            }
        },
    },
    {
        Id: 'timers.TMR2',
        Name: 'TMR2 — starting a second timer on another task stops the first timer in one transaction',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const taskA = world.SeedTaskIDs['GraphQL API Resolvers'];
            const taskB = world.SeedTaskIDs['Angular Explorer Shell Dashboard'];
            const sarah = world.People['sarah.connor@task-world.test'];
            const sarahUser = PersonaUser(ctx, sarah.ID, { canManage: false });
            const createdEntryIDs: string[] = [];

            await cleanupPersonTimersAndEntries(ctx, sarah.ID, []);

            try {
                // 1. Start timer on Task A
                const firstStart = await new TasksStartTimerOperation().Execute(
                    { TaskID: taskA, Notes: 'TMR2 Task A timer', IsBillable: true },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(firstStart.Success && !!firstStart.Output?.Success, 'first timer started');
                const firstTimerID = firstStart.Output!.TimerID!;

                // Backdate first timer by 30 minutes
                const timerA = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimerEntity>(
                    TASK_TIMER_ENTITY,
                    sarahUser,
                );
                Assert(await timerA.Load(firstTimerID), 'load first timer');
                timerA.StartedAt = new Date(Date.now() - 30 * 60_000);
                await RequireSave(timerA, 'backdate first timer');

                // 2. Start timer on Task B -> auto-stops Task A timer in the same transaction
                const secondStart = await new TasksStartTimerOperation().Execute(
                    { TaskID: taskB, Notes: 'TMR2 Task B timer', IsBillable: false },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(secondStart.Success && !!secondStart.Output?.Success, 'second timer started');
                const autoStoppedIDs = secondStart.Output!.AutoStoppedEntryIDs ?? [];
                createdEntryIDs.push(...autoStoppedIDs);

                AssertEqual(autoStoppedIDs.length, 1, 'first timer converted to 1 entry');
                Assert((secondStart.Output!.AutoStoppedMinutes ?? 0) >= 30, 'auto-stopped at least 30 minutes');

                const activeTimers = await FindRows<{ ID: string; TaskID: string }>(
                    ctx,
                    TASK_TIMER_ENTITY,
                    `PersonID = '${sarah.ID}'`,
                    ['ID', 'TaskID'],
                );
                AssertEqual(activeTimers.length, 1, 'still only 1 active timer for person');
                Assert(SameID(activeTimers[0].TaskID, taskB), 'active timer is now on Task B');
            } finally {
                await cleanupPersonTimersAndEntries(ctx, sarah.ID, createdEntryIDs);
            }
        },
    },
    {
        Id: 'timers.TMR3',
        Name: 'TMR3 — cross-midnight timer splits into per-business-day TaskTimeEntry rows (D5)',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const taskID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const sarah = world.People['sarah.connor@task-world.test'];
            const sarahUser = PersonaUser(ctx, sarah.ID, { canManage: false });
            const createdEntryIDs: string[] = [];

            await cleanupPersonTimersAndEntries(ctx, sarah.ID, []);

            try {
                const startRes = await new TasksStartTimerOperation().Execute(
                    { TaskID: taskID, Notes: 'TMR3 cross-midnight', IsBillable: true },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(startRes.Success && !!startRes.Output?.Success, 'timer started');

                // Set StartedAt to 23:00 UTC two days ago and EndedAt to 01:30 UTC one day ago (60m + 90m = 150m across 2 UTC days)
                const today = ToCalendarDay(new Date())!;
                const day1 = AddDays(today, -2);
                const day2 = AddDays(today, -1);
                const startedAt = new Date(`${day1}T23:00:00.000Z`);
                const endedAt = new Date(`${day2}T01:30:00.000Z`);

                const timer = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimerEntity>(
                    TASK_TIMER_ENTITY,
                    sarahUser,
                );
                Assert(await timer.Load(startRes.Output!.TimerID!), 'load timer');
                timer.StartedAt = startedAt;
                await RequireSave(timer, 'set cross-midnight StartedAt');

                const stopRes = await new TasksStopTimerOperation().Execute(
                    { EndedAt: endedAt.toISOString() },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(stopRes.Success && !!stopRes.Output?.Success, `StopTimer cross-midnight: ${stopRes.Output?.Message}`);
                createdEntryIDs.push(...(stopRes.Output!.CreatedTimeEntryIDs ?? []));

                AssertEqual(createdEntryIDs.length, 2, 'split into 2 per-day entries');
                AssertEqual(stopRes.Output!.TotalMinutes, 150, 'total 150 minutes across both days');
            } finally {
                await cleanupPersonTimersAndEntries(ctx, sarah.ID, createdEntryIDs);
            }
        },
    },
    {
        Id: 'timers.TMR4',
        Name: 'TMR4 — discard timer via DiscardIfUnderSeconds or owner Delete; non-owner refused',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const taskID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const sarah = world.People['sarah.connor@task-world.test'];
            const alex = world.People['alex.chen@task-world.test'];
            const sarahUser = PersonaUser(ctx, sarah.ID, { canManage: false });
            const alexUser = PersonaUser(ctx, alex.ID, { canManage: false });

            await cleanupPersonTimersAndEntries(ctx, sarah.ID, []);

            try {
                // 1. Discard via DiscardIfUnderSeconds
                const start1 = await new TasksStartTimerOperation().Execute(
                    { TaskID: taskID },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(start1.Success && !!start1.Output?.Success, 'start1');

                const stopDiscard = await new TasksStopTimerOperation().Execute(
                    { DiscardIfUnderSeconds: 3600 },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(stopDiscard.Success && !!stopDiscard.Output?.Success, 'stopDiscard');
                AssertEqual(stopDiscard.Output!.Discarded, true, 'Discarded flag true');
                AssertEqual(stopDiscard.Output!.CreatedTimeEntryIDs.length, 0, 'no entries created on discard');

                // 2. Direct Delete guard: Alex (non-owner) is refused; Sarah (owner) succeeds
                const start2 = await new TasksStartTimerOperation().Execute(
                    { TaskID: taskID },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(start2.Success && !!start2.Output?.Success, 'start2');
                const timerID = start2.Output!.TimerID!;

                const alexTimer = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimerEntity>(
                    TASK_TIMER_ENTITY,
                    alexUser,
                );
                Assert(await alexTimer.Load(timerID), 'Alex loads Sarah timer');
                await RequireRefusal(() => alexTimer.Delete(), alexTimer, 'TMR4 Alex delete Sarah timer');

                const sarahTimer = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimerEntity>(
                    TASK_TIMER_ENTITY,
                    sarahUser,
                );
                Assert(await sarahTimer.Load(timerID), 'Sarah loads her own timer');
                Assert(await sarahTimer.Delete(), 'Sarah discards her own timer');
            } finally {
                await cleanupPersonTimersAndEntries(ctx, sarah.ID, []);
            }
        },
    },
    {
        Id: 'timers.TMR5',
        Name: 'TMR5 — StartTimer and StopTimer are refused when TimeTrackingEnabled is false',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const taskID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const sarah = world.People['sarah.connor@task-world.test'];
            const sarahUser = PersonaUser(ctx, sarah.ID, { canManage: false });

            await WithTasksSetting(ctx, 'TimeTrackingEnabled', 'false', async () => {
                const startRes = await new TasksStartTimerOperation().Execute(
                    { TaskID: taskID },
                    { user: sarahUser, provider: ctx.Provider },
                );
                AssertEqual(startRes.Output?.Success, false, 'StartTimer refused when disabled');
                Assert(
                    (startRes.Output?.Message ?? '').toLowerCase().includes('disabled'),
                    `StartTimer refusal message: ${startRes.Output?.Message}`,
                );

                const stopRes = await new TasksStopTimerOperation().Execute(
                    {},
                    { user: sarahUser, provider: ctx.Provider },
                );
                AssertEqual(stopRes.Output?.Success, false, 'StopTimer refused when disabled');
                Assert(
                    (stopRes.Output?.Message ?? '').toLowerCase().includes('disabled'),
                    `StopTimer refusal message: ${stopRes.Output?.Message}`,
                );
            });
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('timers', { Setup: async () => {}, Teardown: async () => {} });
