/**
 * TASK-WORLD over the GraphQL wire.
 * Types / roles / decision outcomes are LOOKED UP from shipped metadata.
 * People come from Common. Seed tasks are upserted through TaskEntity.
 */
import type { IntegrationCheckContext } from '@memberjunction/testing-integration/registry';
import { Assert } from '@memberjunction/testing-integration/registry';
import { TaskEntity, mjBizAppsTasksTaskCategoryEntity } from '@mj-biz-apps/tasks-entities';
import { mjBizAppsCommonPersonEntity } from '@mj-biz-apps/common-entities';
import {
    PERSON_ENTITY,
    TASK_CATEGORY_ENTITY,
    TASK_DECISION_OUTCOME_ENTITY,
    TASK_ENTITY,
    TASK_ROLE_ENTITY,
    TASK_TYPE_ENTITY,
} from '../entity-names.js';
import { FindId, FindRows, Quote, RequireSave } from '../wire.js';
import { SetWorld, type WorldState } from './world.js';

const WORLD_DOMAIN = 'task-world.test';

export async function LoadWorld(ctx: IntegrationCheckContext): Promise<WorldState> {
    const typeRows = await FindRows<{ ID: string; Name: string }>(ctx, TASK_TYPE_ENTITY, '', ['ID', 'Name']);
    const roleRows = await FindRows<{ ID: string; Name: string }>(ctx, TASK_ROLE_ENTITY, '', ['ID', 'Name']);
    const outcomeRows = await FindRows<{ ID: string; Name: string }>(ctx, TASK_DECISION_OUTCOME_ENTITY, '', ['ID', 'Name']);
    Assert(typeRows.length > 0, 'no Task Types — push metadata/task-types');
    Assert(roleRows.length > 0, 'no Task Roles — push metadata/task-roles');
    Assert(outcomeRows.length > 0, 'no Decision Outcomes — push metadata/task-decision-outcomes');

    const TaskTypes: WorldState['TaskTypes'] = {};
    for (const row of typeRows) TaskTypes[row.Name] = row;
    const Roles: WorldState['Roles'] = {};
    for (const row of roleRows) Roles[row.Name] = row;
    const DecisionOutcomes: WorldState['DecisionOutcomes'] = {};
    for (const row of outcomeRows) DecisionOutcomes[row.Name] = row;

    const Categories: WorldState['Categories'] = {};
    const categoryTreeDefs: Array<{
        name: string;
        description?: string;
        parentName?: string;
    }> = [
        // Level 1: Root Categories
        { name: 'Engineering & Development', description: 'Core software engineering and technical product development' },
        { name: 'Product & Design', description: 'Product strategy, UX/UI design, and product specifications' },
        { name: 'Operations & Legal', description: 'Business operations, legal compliance, and facilities' },

        // Level 2: Sub-categories
        { name: 'Core Platform & API', description: 'Platform infrastructure, database schemas, and API services', parentName: 'Engineering & Development' },
        { name: 'Frontend Applications', description: 'Web UI apps, design systems, and client libraries', parentName: 'Engineering & Development' },
        { name: 'DevOps & Quality Engineering', description: 'CI/CD pipelines, automated testing, and cloud infrastructure', parentName: 'Engineering & Development' },
        { name: 'User Experience & Research', description: 'User interviews, usability testing, and wireframes', parentName: 'Product & Design' },
        { name: 'Design Systems & Tokens', description: 'Color palettes, typography, and UI iconography', parentName: 'Product & Design' },
        { name: 'Information Security & Compliance', description: 'SOC2 audits, penetration testing, and security policy reviews', parentName: 'Operations & Legal' },
        { name: 'Finance & Accounting Operations', description: 'Budget tracking, invoicing, and contract reviews', parentName: 'Operations & Legal' },

        // Level 3: Leaf Categories
        { name: 'Database & Migrations', description: 'SQL DDL migrations, views, and data seeding', parentName: 'Core Platform & API' },
        { name: 'GraphQL Services', description: 'Resolvers, schema generation, and query pipeline', parentName: 'Core Platform & API' },
        { name: 'Explorer Shell', description: 'Resource tabs, navigation rails, and core layouts', parentName: 'Frontend Applications' },
        { name: 'Shared Component Library', description: 'Angular UI components, directives, and forms', parentName: 'Frontend Applications' },
    ];

    for (const def of categoryTreeDefs) {
        const existing = await FindId(ctx, TASK_CATEGORY_ENTITY, `Name = '${Quote(def.name)}'`);
        const cat = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskCategoryEntity>(TASK_CATEGORY_ENTITY, ctx.User);
        if (existing) {
            await cat.Load(existing);
        } else {
            cat.NewRecord();
        }
        cat.Name = def.name;
        cat.Description = def.description ?? null;
        cat.ParentID = def.parentName && Categories[def.parentName] ? Categories[def.parentName].ID : null;
        cat.IsActive = true;
        await RequireSave(cat, `category ${def.name}`);
        Categories[def.name] = { ID: cat.ID, Name: def.name };
    }

    const People: WorldState['People'] = {};
    const peopleDefs = [
        { Email: `sarah.connor@${WORLD_DOMAIN}`, First: 'Sarah', Last: 'Connor' },
        { Email: `alex.chen@${WORLD_DOMAIN}`, First: 'Alex', Last: 'Chen' },
        { Email: `marcus.vance@${WORLD_DOMAIN}`, First: 'Marcus', Last: 'Vance' },
        { Email: `elena.rostova@${WORLD_DOMAIN}`, First: 'Elena', Last: 'Rostova' },
    ];
    for (const def of peopleDefs) {
        const existing = await FindId(ctx, PERSON_ENTITY, `Email = '${Quote(def.Email)}'`);
        const person = await ctx.Provider.GetEntityObject<mjBizAppsCommonPersonEntity>(PERSON_ENTITY, ctx.User);
        if (existing) {
            await person.Load(existing);
        } else {
            person.NewRecord();
        }
        person.FirstName = def.First;
        person.LastName = def.Last;
        person.Email = def.Email;
        person.Status = 'Active';
        await RequireSave(person, `person ${def.Email}`);
        People[def.Email] = { ID: person.ID, Email: def.Email, FirstName: def.First, LastName: def.Last };
    }

    const generalType = TaskTypes['General'] ?? Object.values(TaskTypes)[0];
    const deliverableType = TaskTypes['Deliverable'] ?? generalType;
    const approvalType = TaskTypes['Approval Request'] ?? generalType;
    const eng = Categories['Engineering & Development'];
    const sarah = People[`sarah.connor@${WORLD_DOMAIN}`];

    const SeedTaskIDs: Record<string, string> = {};
    SeedTaskIDs['Website Redesign & Portal Launch'] = await upsertTask(ctx, {
        Name: 'Website Redesign & Portal Launch',
        TypeID: deliverableType.ID,
        CategoryID: eng.ID,
        Status: 'InProgress',
        Priority: 'High',
        PercentComplete: 40,
    });
    SeedTaskIDs['GraphQL API Resolvers'] = await upsertTask(ctx, {
        Name: 'GraphQL API Resolvers',
        ParentID: SeedTaskIDs['Website Redesign & Portal Launch'],
        TypeID: generalType.ID,
        CategoryID: eng.ID,
        Status: 'InProgress',
        Priority: 'High',
        PercentComplete: 70,
    });
    SeedTaskIDs['Security Review'] = await upsertTask(ctx, {
        Name: 'Security Review',
        ParentID: SeedTaskIDs['Website Redesign & Portal Launch'],
        TypeID: approvalType.ID,
        CategoryID: Categories['Operations & Legal'].ID,
        Status: 'Open',
        Priority: 'Critical',
        PercentComplete: 0,
    });

    const world: WorldState = { Categories, Roles, DecisionOutcomes, TaskTypes, People, SeedTaskIDs };
    SetWorld(world);
    void sarah;
    return world;
}

export async function GetOrLoadWorld(ctx: IntegrationCheckContext): Promise<WorldState> {
    const { GetWorld } = await import('./world.js');
    return GetWorld() ?? LoadWorld(ctx);
}

async function upsertTask(
    ctx: IntegrationCheckContext,
    fields: {
        Name: string;
        ParentID?: string;
        TypeID: string;
        CategoryID: string;
        Status: TaskEntity['Status'];
        Priority: TaskEntity['Priority'];
        PercentComplete: number;
    },
): Promise<string> {
    const existing = await FindId(ctx, TASK_ENTITY, `Name = '${Quote(fields.Name)}'`);
    const task = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
    if (existing) {
        await task.Load(existing);
    } else {
        task.NewRecord();
    }
    task.Name = fields.Name;
    task.TypeID = fields.TypeID;
    task.CategoryID = fields.CategoryID;
    if (fields.ParentID) task.ParentID = fields.ParentID;
    task.Status = fields.Status;
    task.Priority = fields.Priority;
    task.PercentComplete = fields.PercentComplete;
    await RequireSave(task, `task ${fields.Name}`);
    return task.ID;
}
