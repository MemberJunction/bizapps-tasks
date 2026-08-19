import { Assert, IntegrationCheckRegistry, type IntegrationCheckContext, type NamedCheck } from '@memberjunction/testing-integration/registry';
import { LoadWorld } from '../world/load-world.js';
import { World } from '../world/world.js';

const checks: NamedCheck[] = [
    {
        Id: 'task-world.TW1',
        Name: 'TW1 — TASK-WORLD loads over GraphQL; types come from metadata',
        RequiresMutation: true,
        Fn: async (ctx: IntegrationCheckContext) => {
            const world = await LoadWorld(ctx);
            Assert(!!world.TaskTypes['General'], 'General task type missing — push metadata/task-types');
            Assert(Object.keys(world.Roles).length > 0, 'no task roles');
            Assert(Object.keys(world.DecisionOutcomes).length > 0, 'no decision outcomes');
            Assert(!!world.People['sarah.connor@task-world.test'], 'Sarah missing');
            Assert(!!world.SeedTaskIDs['Website Redesign & Portal Launch'], 'root task missing');
            Assert(!!world.Categories['Engineering & Development'], 'Engineering category missing');
            Assert(!!world.Categories['Core Platform & API'], 'Core Platform category missing');
            Assert(!!world.Categories['Frontend Applications'], 'Frontend Applications category missing');
            Assert(!!world.Categories['Database & Migrations'], 'Database & Migrations category missing');
            Assert(!!world.Categories['Explorer Shell'], 'Explorer Shell category missing');
            World();
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('task-world', { Setup: async () => {}, Teardown: async () => {} });
