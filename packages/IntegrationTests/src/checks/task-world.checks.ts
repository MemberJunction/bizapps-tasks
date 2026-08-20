import { Assert, IntegrationCheckRegistry, type IntegrationCheckContext, type NamedCheck } from '@memberjunction/testing-integration/registry';
import { LoadWorld } from '../world/load-world.js';
import { World } from '../world/world.js';

const checks: NamedCheck[] = [
    {
        Id: 'task-world.TW1',
        Name: 'TW1 — TASK-WORLD loads over GraphQL; types, statuses, actions, and 3 project hierarchies establish baseline',
        RequiresMutation: true,
        Fn: async (ctx: IntegrationCheckContext) => {
            const world = await LoadWorld(ctx);

            // 1. Shipped and Custom Task Types with unique Codes
            Assert(!!world.TaskTypes['General'] || !!world.TaskTypes['GENERAL'], 'General task type missing');
            Assert(!!world.TaskTypes['Deliverable'] || !!world.TaskTypes['DELIVERABLE'], 'Deliverable task type missing');
            Assert(!!world.TaskTypes['Approval Request'] || !!world.TaskTypes['APPROVAL_REQUEST'], 'Approval Request task type missing');
            Assert(!!world.TaskTypes['Action Item'] || !!world.TaskTypes['ACTION_ITEM'], 'Action Item task type missing');
            Assert(!!world.TaskTypes['CONSTRUCTION_MILESTONE'], 'Construction Milestone task type missing');
            Assert(!!world.TaskTypes['MEDIA_PRODUCTION'], 'Media Production Stage task type missing');

            // 2. Dynamic TaskTypeStatus Stages
            Assert(!!world.TaskTypeStatuses['DELIVERABLE.DRAFT'], 'DELIVERABLE.DRAFT status missing');
            Assert(world.TaskTypeStatuses['DELIVERABLE.DRAFT'].IsDefault === true, 'DELIVERABLE.DRAFT must be default');
            Assert(!!world.TaskTypeStatuses['DELIVERABLE.APPROVED'], 'DELIVERABLE.APPROVED status missing');
            Assert(world.TaskTypeStatuses['DELIVERABLE.APPROVED'].IsTerminal === true, 'DELIVERABLE.APPROVED must be terminal');

            Assert(!!world.TaskTypeStatuses['APPROVAL_REQUEST.SUBMITTED'], 'APPROVAL_REQUEST.SUBMITTED status missing');
            Assert(!!world.TaskTypeStatuses['APPROVAL_REQUEST.APPROVED'], 'APPROVAL_REQUEST.APPROVED status missing');
            Assert(!!world.TaskTypeStatuses['APPROVAL_REQUEST.REJECTED'], 'APPROVAL_REQUEST.REJECTED status missing');

            Assert(!!world.TaskTypeStatuses['CONSTRUCTION_MILESTONE.PLANNING'], 'CONSTRUCTION_MILESTONE.PLANNING missing');
            Assert(!!world.TaskTypeStatuses['CONSTRUCTION_MILESTONE.INSPECTION_PASSED'], 'CONSTRUCTION_MILESTONE.INSPECTION_PASSED missing');

            Assert(!!world.TaskTypeStatuses['MEDIA_PRODUCTION.PRE_PRODUCTION'], 'MEDIA_PRODUCTION.PRE_PRODUCTION missing');
            Assert(!!world.TaskTypeStatuses['MEDIA_PRODUCTION.COLOR_AND_SOUND'], 'MEDIA_PRODUCTION.COLOR_AND_SOUND missing');
            Assert(!!world.TaskTypeStatuses['MEDIA_PRODUCTION.RELEASED'], 'MEDIA_PRODUCTION.RELEASED missing');

            // 3. Multi-domain Categories
            Assert(!!world.Categories['Engineering & Development'], 'Engineering category missing');
            Assert(!!world.Categories['Core Platform & API'], 'Core Platform category missing');
            Assert(!!world.Categories['Corporate Real Estate & Facilities'], 'Corporate Real Estate category missing');
            Assert(!!world.Categories['Architecture & Civil Engineering'], 'Architecture category missing');
            Assert(!!world.Categories['General Contracting & Construction'], 'General Contracting category missing');
            Assert(!!world.Categories['Media & Creative Production'], 'Media & Creative Production category missing');
            Assert(!!world.Categories['Principal Photography & Sound'], 'Principal Photography category missing');
            Assert(!!world.Categories['Post-Production, VFX & Color'], 'Post-Production category missing');

            // 4. People across operational roles
            Assert(!!world.People['sarah.connor@task-world.test'], 'Sarah Connor missing');
            Assert(!!world.People['alex.chen@task-world.test'], 'Alex Chen missing');
            Assert(!!world.People['david.miller@task-world.test'], 'David Miller missing');
            Assert(!!world.People['maya.lin@task-world.test'], 'Maya Lin missing');

            // 5. 3 Divergent Top-Level Projects Seeded
            Assert(!!world.SeedTaskIDs['Website Redesign & Portal Launch'], 'P1 Software Launch root task missing');
            Assert(!!world.SeedTaskIDs['GraphQL API Resolvers'], 'P1 GraphQL Resolvers subtask missing');

            Assert(!!world.SeedTaskIDs['Corporate HQ Campus Construction & Relocation'], 'P2 HQ Construction root task missing');
            Assert(!!world.SeedTaskIDs['Architectural Blueprints & Structural Engineering'], 'P2 Architectural Blueprints missing');
            Assert(!!world.SeedTaskIDs['Site Excavation & Deep Foundation Concrete Pour'], 'P2 Foundation Pour missing');
            Assert(!!world.SeedTaskIDs['Structural Steel Erection & Building Envelope'], 'P2 Structural Steel missing');

            Assert(!!world.SeedTaskIDs['50-Year Company Heritage Documentary Film'], 'P3 Documentary Film root task missing');
            Assert(!!world.SeedTaskIDs['Founder & Early Pioneer 4K On-Camera Interviews'], 'P3 Founder Interviews missing');
            Assert(!!world.SeedTaskIDs['Assembly Edit & Storyline Rough Cut'], 'P3 Assembly Edit missing');
            Assert(!!world.SeedTaskIDs['Original Cinematic Score Recording & Sound Mix'], 'P3 Score Recording missing');

            // 6. Roles and Decision Outcomes
            Assert(Object.keys(world.Roles).length > 0, 'no task roles');
            Assert(Object.keys(world.DecisionOutcomes).length > 0, 'no decision outcomes');

            World();
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('task-world', { Setup: async () => {}, Teardown: async () => {} });
