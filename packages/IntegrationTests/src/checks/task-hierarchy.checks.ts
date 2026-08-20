import { Assert, AssertEqual, IntegrationCheckRegistry, type NamedCheck } from '@memberjunction/testing-integration/registry';
import { TaskEntity } from '@mj-biz-apps/tasks-entities';
import { TASK_ENTITY } from '../entity-names.js';
import { DeleteTask, FindRows, RequireSave } from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

const checks: NamedCheck[] = [
    {
        Id: 'task-hierarchy.TH1',
        Name: 'TH1 — parent/child tasks persist over GraphQL',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const typeID = world.TaskTypes['General']?.ID ?? Object.values(world.TaskTypes)[0].ID;
            const catID = world.Categories['Engineering & Development'].ID;

            const root = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            root.NewRecord();
            root.Name = `TH1 Root ${Date.now()}`;
            root.TypeID = typeID;
            root.CategoryID = catID;
            root.Status = 'InProgress';
            root.Priority = 'High';
            await RequireSave(root, 'TH1 root');

            const child = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            child.NewRecord();
            child.Name = `TH1 Child ${Date.now()}`;
            child.ParentID = root.ID;
            child.TypeID = typeID;
            child.CategoryID = catID;
            child.Status = 'Open';
            child.Priority = 'Medium';
            await RequireSave(child, 'TH1 child');

            const rows = await FindRows<{ ID: string; ParentID: string }>(
                ctx,
                TASK_ENTITY,
                `ParentID = '${root.ID}'`,
                ['ID', 'ParentID'],
            );
            AssertEqual(rows.length, 1, 'one child');
            await DeleteTask(ctx, child);
            await DeleteTask(ctx, root);
        },
    },
    {
        Id: 'task-hierarchy.TH2',
        Name: 'TH2 — multi-project domain hierarchies verified across construction and media projects',
        RequiresMutation: false,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const p2HQID = world.SeedTaskIDs['Corporate HQ Campus Construction & Relocation'];
            const p3DocID = world.SeedTaskIDs['50-Year Company Heritage Documentary Film'];
            Assert(!!p2HQID && !!p3DocID, 'divergent project roots present');

            const hqChildren = await FindRows<{ ID: string; Name: string }>(
                ctx,
                TASK_ENTITY,
                `ParentID = '${p2HQID}'`,
                ['ID', 'Name']
            );
            Assert(hqChildren.length >= 5, `expected at least 5 HQ construction subtasks, found ${hqChildren.length}`);

            const docChildren = await FindRows<{ ID: string; Name: string }>(
                ctx,
                TASK_ENTITY,
                `ParentID = '${p3DocID}'`,
                ['ID', 'Name']
            );
            Assert(docChildren.length >= 5, `expected at least 5 documentary subtasks, found ${docChildren.length}`);
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('task-hierarchy', { Setup: async () => {}, Teardown: async () => {} });
