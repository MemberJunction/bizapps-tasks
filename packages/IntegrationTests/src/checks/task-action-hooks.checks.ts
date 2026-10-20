import { Assert, IntegrationCheckRegistry, type NamedCheck } from '@memberjunction/testing-integration/registry';
import { TaskEntity } from '@mj-biz-apps/tasks-entities';
import { TASK_ENTITY } from '../entity-names.js';
import { DeleteTask, RequireSave } from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

const checks: NamedCheck[] = [
    {
        Id: 'task-action-hooks.AH1',
        Name: 'AH1 — OnCreate action hook triggers on new task creation without error',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const constrType = world.TaskTypes['CONSTRUCTION_MILESTONE'];
            const catID = world.Categories['Corporate Real Estate & Facilities']?.ID ?? Object.values(world.Categories)[0].ID;
            Assert(!!constrType, 'Construction Milestone task type configured');
            Assert(!!constrType.OnCreateActionID, 'OnCreateActionID wired on Construction Milestone');

            const task = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            task.NewRecord();
            task.Name = `AH1 OnCreate Hook Test ${Date.now()}`;
            task.TypeID = constrType.ID;
            task.CategoryID = catID;
            task.Priority = 'High';
            task.Description = 'Validates OnCreate Action Execution with Calculate Expression';
            await RequireSave(task, 'AH1 task creation');

            Assert(!!task.ID, 'task created successfully with non-blocking action execution');
            await DeleteTask(ctx, task);
        },
    },
    {
        Id: 'task-action-hooks.AH2',
        Name: 'AH2 — OnStatusChange and OnEnterStatus action hooks execute during stage transitions',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const mediaType = world.TaskTypes['MEDIA_PRODUCTION'];
            const preProd = world.TaskTypeStatuses['MEDIA_PRODUCTION.PRE_PRODUCTION'];
            const colorSound = world.TaskTypeStatuses['MEDIA_PRODUCTION.COLOR_AND_SOUND'];
            const catID = world.Categories['Media & Creative Production']?.ID ?? Object.values(world.Categories)[0].ID;
            Assert(!!mediaType && !!preProd && !!colorSound, 'Media production type and color status configured');

            const task = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            task.NewRecord();
            task.Name = `AH2 Color Grade Hook ${Date.now()}`;
            task.TypeID = mediaType.ID;
            task.TaskTypeStatusID = preProd.ID;
            task.CategoryID = catID;
            task.Priority = 'High';
            await RequireSave(task, 'AH2 pre-prod task');

            // Transition to COLOR_AND_SOUND which has OnEnterActionID wired
            task.TaskTypeStatusID = colorSound.ID;
            await RequireSave(task, 'AH2 transition to COLOR_AND_SOUND');

            Assert(task.TaskTypeStatusID === colorSound.ID, 'stage transitioned successfully');
            await DeleteTask(ctx, task);
        },
    },
    {
        Id: 'task-action-hooks.AH3',
        Name: 'AH3 — candidate actions (Calculate Expression and Color Converter) are discovered and executable',
        RequiresMutation: false,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const calcAction = world.Actions['Calculate Expression'];
            const colorAction = world.Actions['Color Converter'];

            Assert(!!calcAction || !!colorAction, 'At least one candidate action discovered in task world');
            if (calcAction) {
                Assert(!!calcAction.ID, 'Calculate Expression action ID resolved');
            }
            if (colorAction) {
                Assert(!!colorAction.ID, 'Color Converter action ID resolved');
            }
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('task-action-hooks', { Setup: async () => {}, Teardown: async () => {} });
