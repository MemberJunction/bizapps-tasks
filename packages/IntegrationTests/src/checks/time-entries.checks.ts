import {
    Assert,
    AssertEqual,
    IntegrationCheckRegistry,
    type NamedCheck,
} from '@memberjunction/testing-integration/registry';
import { AddDays, FromCalendarDay, ToCalendarDay } from '@mj-biz-apps/common-entities';
import {
    TaskEntity,
    mjBizAppsTasksTaskTimeEntryEntity,
    mjBizAppsTasksTaskTimeEntryLinkEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    PERSON_ENTITY,
    TASK_ENTITY,
    TASK_TIME_ENTRY_ENTITY,
    TASK_TIME_ENTRY_LINK_ENTITY,
} from '../entity-names.js';
import {
    DeleteTask,
    PersonaUser,
    RequireRefusal,
    RequireSave,
    SameID,
} from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

const checks: NamedCheck[] = [
    {
        Id: 'time-entries.TE1',
        Name: 'TE1 — worker creates, edits, and deletes own time entries with R1 PersonID default',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const taskID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const sarah = world.People['sarah.connor@task-world.test'];
            Assert(!!taskID && !!sarah, 'seed task and Sarah available');

            const sarahUser = PersonaUser(ctx, sarah.ID, { canManage: false });
            const today = ToCalendarDay(new Date())!;
            const workDay = AddDays(today, -2);

            const entry = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                TASK_TIME_ENTRY_ENTITY,
                sarahUser,
            );
            entry.NewRecord();
            entry.TaskID = taskID;
            // Omit PersonID so R1 defaults it to sarah.ID
            entry.WorkDate = FromCalendarDay(workDay);
            entry.Minutes = 45;
            entry.Notes = 'TE1 initial entry';
            entry.IsBillable = true;
            await RequireSave(entry, 'TE1 create own entry');

            Assert(SameID(entry.PersonID, sarah.ID), 'R1 defaulted PersonID to caller Person');
            AssertEqual(entry.Minutes, 45, 'saved 45 minutes');

            entry.Minutes = 75;
            entry.Notes = 'TE1 updated entry';
            await RequireSave(entry, 'TE1 edit own entry');
            AssertEqual(entry.Minutes, 75, 'updated to 75 minutes');

            Assert(await entry.Delete(), 'TE1 delete own entry');
        },
    },
    {
        Id: 'time-entries.TE2',
        Name: 'TE2 — another user without Manage Time Entries is refused; authorization holder succeeds (R2)',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const taskID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const sarah = world.People['sarah.connor@task-world.test'];
            const alex = world.People['alex.chen@task-world.test'];
            Assert(!!taskID && !!sarah && !!alex, 'seed task, Sarah, and Alex available');

            const sarahUser = PersonaUser(ctx, sarah.ID, { canManage: false });
            const alexUser = PersonaUser(ctx, alex.ID, { canManage: false });
            const managerUser = PersonaUser(ctx, alex.ID, { canManage: true });
            const workDay = AddDays(ToCalendarDay(new Date())!, -3);

            // Sarah creates her own entry
            const sarahEntry = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                TASK_TIME_ENTRY_ENTITY,
                sarahUser,
            );
            sarahEntry.NewRecord();
            sarahEntry.TaskID = taskID;
            sarahEntry.PersonID = sarah.ID;
            sarahEntry.WorkDate = FromCalendarDay(workDay);
            sarahEntry.Minutes = 60;
            sarahEntry.Notes = 'TE2 Sarah entry';
            await RequireSave(sarahEntry, 'TE2 Sarah create');

            try {
                // Alex (no Manage Time Entries) tries to create an entry for Sarah
                const spoofCreate = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    alexUser,
                );
                spoofCreate.NewRecord();
                spoofCreate.TaskID = taskID;
                spoofCreate.PersonID = sarah.ID;
                spoofCreate.WorkDate = FromCalendarDay(workDay);
                spoofCreate.Minutes = 30;
                await RequireRefusal(() => spoofCreate.Save(), spoofCreate, 'TE2 Alex create for Sarah');

                // Alex tries to edit Sarah's entry
                const alexEdit = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    alexUser,
                );
                Assert(await alexEdit.Load(sarahEntry.ID), 'load Sarah entry as Alex');
                alexEdit.Minutes = 90;
                await RequireRefusal(() => alexEdit.Save(), alexEdit, 'TE2 Alex edit Sarah entry');

                // Alex tries to delete Sarah's entry
                await RequireRefusal(() => alexEdit.Delete(), alexEdit, 'TE2 Alex delete Sarah entry');

                // Manager (with Manage Time Entries) edits Sarah's entry and succeeds
                const mgrEdit = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    managerUser,
                );
                Assert(await mgrEdit.Load(sarahEntry.ID), 'load Sarah entry as manager');
                mgrEdit.Minutes = 90;
                mgrEdit.Notes = 'TE2 updated by manager';
                await RequireSave(mgrEdit, 'TE2 manager edit Sarah entry');
                AssertEqual(mgrEdit.Minutes, 90, 'manager updated minutes to 90');
            } finally {
                const cleanup = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    managerUser,
                );
                if (await cleanup.Load(sarahEntry.ID)) {
                    await cleanup.Delete();
                }
            }
        },
    },
    {
        Id: 'time-entries.TE3',
        Name: 'TE3 — duration derived from StartedAt/EndedAt and cleared when Minutes edited by hand (R4)',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const taskID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const sarah = world.People['sarah.connor@task-world.test'];
            const sarahUser = PersonaUser(ctx, sarah.ID, { canManage: false });
            const workDay = AddDays(ToCalendarDay(new Date())!, -2);

            const entry = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                TASK_TIME_ENTRY_ENTITY,
                sarahUser,
            );
            entry.NewRecord();
            entry.TaskID = taskID;
            entry.PersonID = sarah.ID;
            entry.WorkDate = FromCalendarDay(workDay);
            entry.StartedAt = new Date('2026-03-10T09:00:00.000Z');
            entry.EndedAt = new Date('2026-03-10T10:30:00.000Z');
            entry.Minutes = 1; // R4 overwrites with 90
            entry.Source = 'Timer';
            await RequireSave(entry, 'TE3 save interval entry');

            try {
                AssertEqual(entry.Minutes, 90, 'R4 derived 90 minutes from 90-minute interval');
                Assert(entry.StartedAt != null && entry.EndedAt != null, 'interval timestamps preserved');

                // Reload and edit Minutes by hand without touching StartedAt/EndedAt
                const reloaded = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    sarahUser,
                );
                Assert(await reloaded.Load(entry.ID), 'reload interval entry');
                reloaded.Minutes = 120;
                await RequireSave(reloaded, 'TE3 hand-edit Minutes');

                AssertEqual(reloaded.Minutes, 120, 'Minutes updated to 120');
                AssertEqual(reloaded.StartedAt, null, 'StartedAt cleared on manual duration edit');
                AssertEqual(reloaded.EndedAt, null, 'EndedAt cleared on manual duration edit');
                AssertEqual(reloaded.Source, 'Timer', 'Source remains Timer');
            } finally {
                const cleanup = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    ctx.User,
                );
                if (await cleanup.Load(entry.ID)) {
                    await cleanup.Delete();
                }
            }
        },
    },
    {
        Id: 'time-entries.TE4',
        Name: 'TE4 — future WorkDate beyond +1 day is refused (R5)',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const taskID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const sarah = world.People['sarah.connor@task-world.test'];
            const sarahUser = PersonaUser(ctx, sarah.ID, { canManage: false });
            const futureDay = AddDays(ToCalendarDay(new Date())!, 5);

            const entry = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                TASK_TIME_ENTRY_ENTITY,
                sarahUser,
            );
            entry.NewRecord();
            entry.TaskID = taskID;
            entry.PersonID = sarah.ID;
            entry.WorkDate = FromCalendarDay(futureDay);
            entry.Minutes = 60;

            await RequireRefusal(() => entry.Save(), entry, 'TE4 future WorkDate', 'future');
        },
    },
    {
        Id: 'time-entries.TE5',
        Name: 'TE5 — deleting a task with logged time entries is refused with the entry count (§6.1)',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const sarah = world.People['sarah.connor@task-world.test'];
            const generalType = world.TaskTypes['GENERAL'] ?? Object.values(world.TaskTypes)[0];
            const catID = world.Categories['Engineering & Development'].ID;
            const workDay = AddDays(ToCalendarDay(new Date())!, -2);

            const task = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            task.NewRecord();
            task.Name = `TE5 Task Delete Guard ${Date.now()}`;
            task.TypeID = generalType.ID;
            task.CategoryID = catID;
            task.Status = 'Open';
            task.Priority = 'Medium';
            await RequireSave(task, 'TE5 create task');

            const e1 = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                TASK_TIME_ENTRY_ENTITY,
                ctx.User,
            );
            e1.NewRecord();
            e1.TaskID = task.ID;
            e1.PersonID = sarah.ID;
            e1.WorkDate = FromCalendarDay(workDay);
            e1.Minutes = 30;
            await RequireSave(e1, 'TE5 entry 1');

            const e2 = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                TASK_TIME_ENTRY_ENTITY,
                ctx.User,
            );
            e2.NewRecord();
            e2.TaskID = task.ID;
            e2.PersonID = sarah.ID;
            e2.WorkDate = FromCalendarDay(workDay);
            e2.Minutes = 45;
            await RequireSave(e2, 'TE5 entry 2');

            try {
                await RequireRefusal(() => task.Delete(), task, 'TE5 delete task with 2 entries', '2 logged time entries');
            } finally {
                await e1.Delete();
                await e2.Delete();
                await DeleteTask(ctx, task);
            }
        },
    },
    {
        Id: 'time-entries.TE6',
        Name: 'TE6 — linked time entry (TaskTimeEntryLink) refuses edit and delete until link is removed (R8)',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const taskID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const sarah = world.People['sarah.connor@task-world.test'];
            const sarahUser = PersonaUser(ctx, sarah.ID, { canManage: false });
            const workDay = AddDays(ToCalendarDay(new Date())!, -2);
            const peopleEntity = ctx.Provider.Entities.find((e) => e.Name === PERSON_ENTITY);
            Assert(!!peopleEntity, 'People entity metadata present');

            const entry = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                TASK_TIME_ENTRY_ENTITY,
                sarahUser,
            );
            entry.NewRecord();
            entry.TaskID = taskID;
            entry.PersonID = sarah.ID;
            entry.WorkDate = FromCalendarDay(workDay);
            entry.Minutes = 60;
            entry.Notes = 'TE6 billable entry';
            await RequireSave(entry, 'TE6 create entry');

            const link = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryLinkEntity>(
                TASK_TIME_ENTRY_LINK_ENTITY,
                sarahUser,
            );
            link.NewRecord();
            link.TaskTimeEntryID = entry.ID;
            link.EntityID = peopleEntity!.ID;
            link.RecordID = sarah.ID;
            link.Relationship = 'InvoiceLine';
            await RequireSave(link, 'TE6 create TaskTimeEntryLink');

            try {
                // Attempt to edit locked entry -> refused
                const toEdit = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    sarahUser,
                );
                Assert(await toEdit.Load(entry.ID), 'load linked entry');
                toEdit.Minutes = 90;
                await RequireRefusal(() => toEdit.Save(), toEdit, 'TE6 edit linked entry', 'link');

                // Attempt to delete locked entry -> refused
                const toDelete = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    sarahUser,
                );
                Assert(await toDelete.Load(entry.ID), 'reload linked entry');
                await RequireRefusal(() => toDelete.Delete(), toDelete, 'TE6 delete linked entry', 'link');
            } finally {
                Assert(await link.Delete(), 'TE6 remove TaskTimeEntryLink');
                const unlocked = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    sarahUser,
                );
                if (await unlocked.Load(entry.ID)) {
                    unlocked.Minutes = 75;
                    await RequireSave(unlocked, 'TE6 edit after unlinking');
                    Assert(await unlocked.Delete(), 'TE6 delete after unlinking');
                }
            }
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('time-entries', { Setup: async () => {}, Teardown: async () => {} });
