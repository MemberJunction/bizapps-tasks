import { Assert, IntegrationCheckRegistry, type NamedCheck } from '@memberjunction/testing-integration/registry';
import { mjBizAppsTasksTaskAssignmentEntity } from '@mj-biz-apps/tasks-entities';
import { PERSON_ENTITY, TASK_ASSIGNMENT_ENTITY } from '../entity-names.js';
import { FindRows, RequireSave } from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

const checks: NamedCheck[] = [
    {
        Id: 'task-assignments.TA1',
        Name: 'TA1 — assign a person to a seed task over GraphQL',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const taskID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const sarah = world.People['sarah.connor@task-world.test'];
            const role = Object.values(world.Roles)[0];
            const personEntity = ctx.Provider.EntityByName(PERSON_ENTITY);
            Assert(!!personEntity, 'People entity');

            const existing = await FindRows<{ ID: string }>(
                ctx,
                TASK_ASSIGNMENT_ENTITY,
                `TaskID = '${taskID}' AND AssigneeRecordID = '${sarah.ID}'`,
                ['ID'],
            );
            if (existing.length === 0) {
                const assign = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(TASK_ASSIGNMENT_ENTITY, ctx.User);
                assign.NewRecord();
                assign.TaskID = taskID;
                assign.AssigneeEntityID = personEntity!.ID;
                assign.AssigneeRecordID = sarah.ID;
                assign.RoleID = role.ID;
                assign.Status = 'InProgress';
                await RequireSave(assign, 'TA1 assignment');
            }
            const rows = await FindRows<{ ID: string }>(
                ctx,
                TASK_ASSIGNMENT_ENTITY,
                `TaskID = '${taskID}' AND AssigneeRecordID = '${sarah.ID}'`,
                ['ID'],
            );
            Assert(rows.length >= 1, 'assignment visible');
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('task-assignments', { Setup: async () => {}, Teardown: async () => {} });
