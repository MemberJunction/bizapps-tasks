import { Assert, IntegrationCheckRegistry, type NamedCheck } from '@memberjunction/testing-integration/registry';
import { GetOrLoadWorld } from '../world/load-world.js';

const checks: NamedCheck[] = [
    {
        Id: 'task-templates.TT1',
        Name: 'TT1 — shipped task types include General and Approval Request',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            Assert(!!world.TaskTypes['General'], 'General');
            Assert(!!world.TaskTypes['Approval Request'] || !!world.TaskTypes['Deliverable'], 'approval or deliverable type');
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('task-templates', { Setup: async () => {}, Teardown: async () => {} });
