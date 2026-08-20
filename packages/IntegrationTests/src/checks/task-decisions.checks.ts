import { Assert, IntegrationCheckRegistry, type NamedCheck } from '@memberjunction/testing-integration/registry';
import { mjBizAppsTasksTaskDecisionEntity } from '@mj-biz-apps/tasks-entities';
import { TASK_DECISION_ENTITY } from '../entity-names.js';
import { FindRows, RequireSave } from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

const checks: NamedCheck[] = [
    {
        Id: 'task-decisions.TDN1',
        Name: 'TDN1 — record a decision on the Security Review task',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const taskID = world.SeedTaskIDs['Security Review'];
            const outcome = world.DecisionOutcomes['Approved'] ?? Object.values(world.DecisionOutcomes)[0];
            const sarah = world.People['sarah.connor@task-world.test'];
            Assert(!!taskID && !!outcome, 'seed review + outcome');

            const decision = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskDecisionEntity>(TASK_DECISION_ENTITY, ctx.User);
            decision.NewRecord();
            decision.TaskID = taskID;
            decision.OutcomeID = outcome.ID;
            decision.DecidedByPersonID = sarah.ID;
            decision.DecisionNotes = 'Wire integration — approved for coverage';
            await RequireSave(decision, 'TDN1 decision');
            const rows = await FindRows<{ ID: string }>(ctx, TASK_DECISION_ENTITY, `TaskID = '${taskID}'`, ['ID']);
            Assert(rows.length >= 1, 'decision visible');
            Assert(await decision.Delete(), 'cleanup decision');
        },
    },
    {
        Id: 'task-decisions.TDN2',
        Name: 'TDN2 — record a decision on Municipal Zoning Variance by Chief Architect',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const taskID = world.SeedTaskIDs['Municipal Zoning Variance & Building Permits'];
            const outcome = world.DecisionOutcomes['Approved'] ?? Object.values(world.DecisionOutcomes)[0];
            const robert = world.People['robert.hayes@task-world.test'] ?? Object.values(world.People)[0];
            Assert(!!taskID && !!outcome && !!robert, 'seed permit task + outcome + architect');

            const decision = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskDecisionEntity>(TASK_DECISION_ENTITY, ctx.User);
            decision.NewRecord();
            decision.TaskID = taskID;
            decision.OutcomeID = outcome.ID;
            decision.DecidedByPersonID = robert.ID;
            decision.DecisionNotes = 'City council zoning variance approved without conditions';
            await RequireSave(decision, 'TDN2 zoning decision');

            const rows = await FindRows<{ ID: string }>(ctx, TASK_DECISION_ENTITY, `TaskID = '${taskID}'`, ['ID']);
            Assert(rows.length >= 1, 'zoning decision queryable');
            Assert(await decision.Delete(), 'cleanup decision');
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('task-decisions', { Setup: async () => {}, Teardown: async () => {} });
