import { Assert, IntegrationCheckRegistry, type NamedCheck } from '@memberjunction/testing-integration/registry';
import { TaskEntity, mjBizAppsTasksTaskDependencyEntity } from '@mj-biz-apps/tasks-entities';
import { TASK_DEPENDENCY_ENTITY, TASK_ENTITY } from '../entity-names.js';
import { FindRows, RequireSave } from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

const checks: NamedCheck[] = [
    {
        Id: 'task-dependencies.TD1',
        Name: 'TD1 — FinishToStart dependency is stored and queryable',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const pred = world.SeedTaskIDs['GraphQL API Resolvers'];
            const succ = world.SeedTaskIDs['Security Review'];
            Assert(!!pred && !!succ, 'seed tasks');

            const existing = await FindRows<{ ID: string }>(
                ctx,
                TASK_DEPENDENCY_ENTITY,
                `TaskID = '${succ}' AND DependsOnTaskID = '${pred}'`,
                ['ID'],
            );
            if (existing.length === 0) {
                const dep = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskDependencyEntity>(TASK_DEPENDENCY_ENTITY, ctx.User);
                dep.NewRecord();
                dep.TaskID = succ;
                dep.DependsOnTaskID = pred;
                dep.DependencyType = 'FinishToStart';
                await RequireSave(dep, 'TD1 dep');
            }
            const rows = await FindRows<{ ID: string }>(
                ctx,
                TASK_DEPENDENCY_ENTITY,
                `TaskID = '${succ}' AND DependsOnTaskID = '${pred}'`,
                ['ID'],
            );
            Assert(rows.length >= 1, 'dependency visible over GraphQL');
            void TaskEntity;
        },
    },
    {
        Id: 'task-dependencies.TD2',
        Name: 'TD2 — critical path dependency chain across construction tasks',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const blueprints = world.SeedTaskIDs['Architectural Blueprints & Structural Engineering'];
            const excavation = world.SeedTaskIDs['Site Excavation & Deep Foundation Concrete Pour'];
            const steel = world.SeedTaskIDs['Structural Steel Erection & Building Envelope'];
            Assert(!!blueprints && !!excavation && !!steel, 'construction tasks');

            const existing = await FindRows<{ ID: string }>(
                ctx,
                TASK_DEPENDENCY_ENTITY,
                `TaskID = '${steel}' AND DependsOnTaskID = '${excavation}'`,
                ['ID']
            );
            if (existing.length === 0) {
                const dep = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskDependencyEntity>(TASK_DEPENDENCY_ENTITY, ctx.User);
                dep.NewRecord();
                dep.TaskID = steel;
                dep.DependsOnTaskID = excavation;
                dep.DependencyType = 'FinishToStart';
                await RequireSave(dep, 'TD2 steel depends on excavation');
            }

            const rows = await FindRows<{ ID: string }>(
                ctx,
                TASK_DEPENDENCY_ENTITY,
                `TaskID = '${steel}' AND DependsOnTaskID = '${excavation}'`,
                ['ID']
            );
            Assert(rows.length >= 1, 'construction dependency chain link verified');
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('task-dependencies', { Setup: async () => {}, Teardown: async () => {} });
