import {
    Assert,
    AssertEqual,
    IntegrationCheckRegistry,
    type IntegrationCheckContext,
    type NamedCheck,
} from '@memberjunction/testing-integration/registry';
import {
    mjBizAppsCommonOrganizationEntity,
    mjBizAppsCommonPersonEntity,
} from '@mj-biz-apps/common-entities';
import {
    TasksBulkUpdateOperation,
    TasksInstantiateTemplateOperation,
    TasksRunRecurringPlaybooksOperation,
} from '@mj-biz-apps/tasks-core';
import {
    mjBizAppsTasksTaskActivityEntity,
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTaskCategoryEntity,
    mjBizAppsTasksTaskDependencyEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskTagEntity,
    mjBizAppsTasksTaskTagLinkEntity,
    mjBizAppsTasksTaskTemplateEntity,
    mjBizAppsTasksTaskTemplateItemDependencyEntity,
    mjBizAppsTasksTaskTemplateItemEntity,
    mjBizAppsTasksTaskTemplateItemRoleEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    PERSON_ENTITY,
    TASK_ACTIVITY_ENTITY,
    TASK_ASSIGNMENT_ENTITY,
    TASK_CATEGORY_ENTITY,
    TASK_DEPENDENCY_ENTITY,
    TASK_ENTITY,
    TASK_ROLE_ENTITY,
    TASK_TAG_ENTITY,
    TASK_TAG_LINK_ENTITY,
    TASK_TEMPLATE_ENTITY,
    TASK_TEMPLATE_ITEM_DEP_ENTITY,
    TASK_TEMPLATE_ITEM_ENTITY,
    TASK_TEMPLATE_ITEM_ROLE_ENTITY,
    TASK_TYPE_ENTITY,
} from '../entity-names.js';
import { FindRows, RequireSave, SameID } from '../wire.js';

const ORG_ENTITY = 'MJ_BizApps_Common: Organizations';

function isoDay(val: string | Date | null | undefined): string {
    if (!val) return '';
    return new Date(val).toISOString().slice(0, 10);
}

async function resolveShippedTaskTypes(ctx: IntegrationCheckContext): Promise<{ deliverableID: string; actionItemID: string }> {
    const types = await FindRows<{ ID: string; Name: string; Code: string | null }>(
        ctx,
        TASK_TYPE_ENTITY,
        '',
        ['ID', 'Name', 'Code'],
    );
    Assert(types.length > 0, 'at least one shipped Task Type exists');
    const deliverable =
        types.find((t) => t.Name === 'Deliverable' || t.Code === 'Deliverable' || t.Code === 'DELIVERABLE') ?? types[0];
    const actionItem =
        types.find((t) => t.Name === 'Action Item' || t.Code === 'ActionItem' || t.Code === 'ACTION_ITEM') ?? types[0];
    return { deliverableID: deliverable.ID, actionItemID: actionItem.ID };
}

async function resolveTwoPeople(ctx: IntegrationCheckContext): Promise<{
    personA: { ID: string };
    personB: { ID: string };
    cleanup: () => Promise<void>;
}> {
    const existing = await FindRows<{ ID: string }>(ctx, PERSON_ENTITY, '', ['ID']);
    const created: mjBizAppsCommonPersonEntity[] = [];
    const stamp = Date.now();
    while (existing.length + created.length < 2) {
        const idx = created.length + 1;
        const p = await ctx.Provider.GetEntityObject<mjBizAppsCommonPersonEntity>(PERSON_ENTITY, ctx.User);
        p.NewRecord();
        p.FirstName = `ITBulk${idx}`;
        p.LastName = `Tester${stamp}`;
        p.Email = `it-bulk-${idx}-${stamp}@task-world.test`;
        p.Status = 'Active';
        await RequireSave(p, `create temp person ${idx}`);
        created.push(p);
    }
    const all = [...existing, ...created.map((p) => ({ ID: p.ID }))];
    return {
        personA: all[0],
        personB: all[1],
        cleanup: async () => {
            for (const p of created) {
                await p.Delete();
            }
        },
    };
}

async function deleteTaskCascade(ctx: IntegrationCheckContext, taskID: string): Promise<void> {
    const depRows = await FindRows<{ ID: string }>(
        ctx,
        TASK_DEPENDENCY_ENTITY,
        `TaskID = '${taskID}' OR DependsOnTaskID = '${taskID}'`,
        ['ID'],
    );
    for (const r of depRows) {
        const dep = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskDependencyEntity>(TASK_DEPENDENCY_ENTITY, ctx.User);
        if (await dep.Load(r.ID)) await dep.Delete();
    }

    const assignRows = await FindRows<{ ID: string }>(ctx, TASK_ASSIGNMENT_ENTITY, `TaskID = '${taskID}'`, ['ID']);
    for (const r of assignRows) {
        const a = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(TASK_ASSIGNMENT_ENTITY, ctx.User);
        if (await a.Load(r.ID)) await a.Delete();
    }

    const tagLinkRows = await FindRows<{ ID: string }>(ctx, TASK_TAG_LINK_ENTITY, `TaskID = '${taskID}'`, ['ID']);
    for (const r of tagLinkRows) {
        const tl = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTagLinkEntity>(TASK_TAG_LINK_ENTITY, ctx.User);
        if (await tl.Load(r.ID)) await tl.Delete();
    }

    const actRows = await FindRows<{ ID: string }>(ctx, TASK_ACTIVITY_ENTITY, `TaskID = '${taskID}'`, ['ID']);
    for (const r of actRows) {
        const act = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskActivityEntity>(TASK_ACTIVITY_ENTITY, ctx.User);
        if (await act.Load(r.ID)) await act.Delete();
    }

    const task = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASK_ENTITY, ctx.User);
    if (await task.Load(taskID)) {
        await task.Delete();
    }
}

async function createTempOrg(ctx: IntegrationCheckContext, name: string): Promise<mjBizAppsCommonOrganizationEntity> {
    const org = await ctx.Provider.GetEntityObject<mjBizAppsCommonOrganizationEntity>(ORG_ENTITY, ctx.User);
    org.NewRecord();
    org.Name = name;
    org.Status = 'Active';
    await RequireSave(org, `create temp Organization ${name}`);
    return org;
}

/**
 * Self-contained GraphQL-wire integration checks for:
 *  - Aggregate-root Organization scoping (`Task`, `TaskCategory`, `TaskTemplate`)
 *  - Server-side parent OrganizationID inheritance (`TaskEntityServer.inheritParentOrganizationPreSave`)
 *  - Server-side Asana-grade bulk operations (`BizAppsTasks.BulkUpdateTasks`)
 *  - Server-side playbook template instantiation (`BizAppsTasks.InstantiateTemplate`)
 */
const checks: NamedCheck[] = [
    {
        Id: 'task-org-bulk-ops.TOB1',
        Name: 'TOB1 — OrganizationID persists and resolves Organization display name on Task, TaskCategory, and TaskTemplate',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const { deliverableID, actionItemID } = await resolveShippedTaskTypes(ctx);
            const stamp = Date.now();
            const org = await createTempOrg(ctx, `IT Close Entity ${stamp}`);
            let catID: string | null = null;
            let tplID: string | null = null;
            let taskID: string | null = null;

            try {
                const cat = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskCategoryEntity>(TASK_CATEGORY_ENTITY, ctx.User);
                cat.NewRecord();
                cat.Name = `IT Close Cat ${stamp}`;
                cat.OrganizationID = org.ID;
                await RequireSave(cat, 'save org-scoped TaskCategory');
                catID = cat.ID;

                const tpl = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateEntity>(TASK_TEMPLATE_ENTITY, ctx.User);
                tpl.NewRecord();
                tpl.Name = `IT Close Playbook ${stamp}`;
                tpl.TypeID = deliverableID;
                tpl.CategoryID = cat.ID;
                tpl.OrganizationID = org.ID;
                await RequireSave(tpl, 'save org-scoped TaskTemplate');
                tplID = tpl.ID;

                const task = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASK_ENTITY, ctx.User);
                task.NewRecord();
                task.Name = `IT Close Task ${stamp}`;
                task.TypeID = actionItemID;
                task.CategoryID = cat.ID;
                task.OrganizationID = org.ID;
                task.Status = 'Open';
                task.Priority = 'High';
                await RequireSave(task, 'save org-scoped Task');
                taskID = task.ID;

                const [catRow] = await FindRows<{ OrganizationID: string | null; Organization: string | null }>(
                    ctx,
                    TASK_CATEGORY_ENTITY,
                    `ID = '${cat.ID}'`,
                    ['OrganizationID', 'Organization'],
                );
                Assert(SameID(catRow?.OrganizationID, org.ID), 'TaskCategory.OrganizationID persisted');
                AssertEqual(catRow?.Organization ?? '', org.Name, 'vwTaskCategories resolves Organization name');

                const [tplRow] = await FindRows<{ OrganizationID: string | null; Organization: string | null }>(
                    ctx,
                    TASK_TEMPLATE_ENTITY,
                    `ID = '${tpl.ID}'`,
                    ['OrganizationID', 'Organization'],
                );
                Assert(SameID(tplRow?.OrganizationID, org.ID), 'TaskTemplate.OrganizationID persisted');
                AssertEqual(tplRow?.Organization ?? '', org.Name, 'vwTaskTemplates resolves Organization name');

                const [taskRow] = await FindRows<{ OrganizationID: string | null; Organization: string | null }>(
                    ctx,
                    TASK_ENTITY,
                    `ID = '${task.ID}'`,
                    ['OrganizationID', 'Organization'],
                );
                Assert(SameID(taskRow?.OrganizationID, org.ID), 'Task.OrganizationID persisted');
                AssertEqual(taskRow?.Organization ?? '', org.Name, 'vwTasks resolves Organization name');
            } finally {
                if (taskID) await deleteTaskCascade(ctx, taskID);
                if (tplID) {
                    const tpl = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateEntity>(TASK_TEMPLATE_ENTITY, ctx.User);
                    if (await tpl.Load(tplID)) await tpl.Delete();
                }
                if (catID) {
                    const cat = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskCategoryEntity>(TASK_CATEGORY_ENTITY, ctx.User);
                    if (await cat.Load(catID)) await cat.Delete();
                }
                await org.Delete();
            }
        },
    },
    {
        Id: 'task-org-bulk-ops.TOB2',
        Name: 'TOB2 — TaskEntityServer auto-inherits parent OrganizationID on new sub-task when unset and respects explicit overrides',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const { deliverableID, actionItemID } = await resolveShippedTaskTypes(ctx);
            const stamp = Date.now();
            const orgParent = await createTempOrg(ctx, `IT Parent Org ${stamp}`);
            const orgOverride = await createTempOrg(ctx, `IT Override Org ${stamp}`);
            let parentID: string | null = null;
            let inheritedChildID: string | null = null;
            let overrideChildID: string | null = null;

            try {
                const parent = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASK_ENTITY, ctx.User);
                parent.NewRecord();
                parent.Name = `IT Parent Task ${stamp}`;
                parent.TypeID = deliverableID;
                parent.OrganizationID = orgParent.ID;
                parent.Status = 'Open';
                parent.Priority = 'High';
                await RequireSave(parent, 'save parent task');
                parentID = parent.ID;

                // Child created WITHOUT OrganizationID -> inherits orgParent.ID server-side
                const childInherited = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASK_ENTITY, ctx.User);
                childInherited.NewRecord();
                childInherited.Name = `IT Inherited Subtask ${stamp}`;
                childInherited.TypeID = actionItemID;
                childInherited.ParentID = parent.ID;
                childInherited.Status = 'Open';
                childInherited.Priority = 'Medium';
                await RequireSave(childInherited, 'save inherited child task');
                inheritedChildID = childInherited.ID;

                const [inhRow] = await FindRows<{ OrganizationID: string | null; Organization: string | null }>(
                    ctx,
                    TASK_ENTITY,
                    `ID = '${childInherited.ID}'`,
                    ['OrganizationID', 'Organization'],
                );
                Assert(SameID(inhRow?.OrganizationID, orgParent.ID), 'new sub-task inherited parent OrganizationID');
                AssertEqual(inhRow?.Organization ?? '', orgParent.Name, 'inherited sub-task resolves parent Organization name');

                // Child created WITH explicit OrganizationID -> keeps orgOverride.ID
                const childOverride = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASK_ENTITY, ctx.User);
                childOverride.NewRecord();
                childOverride.Name = `IT Override Subtask ${stamp}`;
                childOverride.TypeID = actionItemID;
                childOverride.ParentID = parent.ID;
                childOverride.OrganizationID = orgOverride.ID;
                childOverride.Status = 'Open';
                childOverride.Priority = 'Low';
                await RequireSave(childOverride, 'save override child task');
                overrideChildID = childOverride.ID;

                const [ovRow] = await FindRows<{ OrganizationID: string | null }>(
                    ctx,
                    TASK_ENTITY,
                    `ID = '${childOverride.ID}'`,
                    ['OrganizationID'],
                );
                Assert(SameID(ovRow?.OrganizationID, orgOverride.ID), 'explicit OrganizationID on sub-task was preserved');
            } finally {
                if (overrideChildID) await deleteTaskCascade(ctx, overrideChildID);
                if (inheritedChildID) await deleteTaskCascade(ctx, inheritedChildID);
                if (parentID) await deleteTaskCascade(ctx, parentID);
                await orgOverride.Delete();
                await orgParent.Delete();
            }
        },
    },
    {
        Id: 'task-org-bulk-ops.TOB3',
        Name: 'TOB3 — BizAppsTasks.BulkUpdateTasks replaces, adds, and clears Person & MJ Role assignees over GraphQL',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const { actionItemID } = await resolveShippedTaskTypes(ctx);
            const { personA, personB, cleanup } = await resolveTwoPeople(ctx);
            const stamp = Date.now();
            const roles = await FindRows<{ ID: string; Name: string }>(ctx, 'MJ: Roles', '', ['ID', 'Name']);
            Assert(roles.length > 0, 'at least one MJ: Role exists for role assignment check');
            const targetRole = roles[0];

            const createdIDs: string[] = [];
            try {
                for (const label of ['A', 'B']) {
                    const t = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASK_ENTITY, ctx.User);
                    t.NewRecord();
                    t.Name = `IT Bulk Reassign ${label} ${stamp}`;
                    t.TypeID = actionItemID;
                    t.Status = 'Open';
                    t.Priority = 'Medium';
                    await RequireSave(t, `create bulk reassign task ${label}`);
                    createdIDs.push(t.ID);
                }

                const op = new TasksBulkUpdateOperation();

                // 1. Replace with personA
                const r1 = await op.Execute(
                    {
                        TaskIDs: createdIDs,
                        AssigneeMode: 'replace',
                        AssigneeEntityName: PERSON_ENTITY,
                        AssigneeRecordID: personA.ID,
                    },
                    { provider: ctx.Provider, user: ctx.User },
                );
                Assert(r1.Success && r1.Output?.UpdatedCount === 2, `bulk replace failed: ${r1.ErrorMessage ?? 'unknown'}`);

                // 2. Add personB (keeps personA + adds personB)
                const r2 = await op.Execute(
                    {
                        TaskIDs: createdIDs,
                        AssigneeMode: 'add',
                        AssigneeEntityName: PERSON_ENTITY,
                        AssigneeRecordID: personB.ID,
                    },
                    { provider: ctx.Provider, user: ctx.User },
                );
                Assert(r2.Success && r2.Output?.UpdatedCount === 2, 'bulk add Person succeeded');

                // 3. Add MJ Role
                const r3 = await op.Execute(
                    {
                        TaskIDs: createdIDs,
                        AssigneeMode: 'add',
                        AssigneeEntityName: 'MJ: Roles',
                        AssigneeRecordID: targetRole.ID,
                    },
                    { provider: ctx.Provider, user: ctx.User },
                );
                Assert(r3.Success && r3.Output?.UpdatedCount === 2, 'bulk add MJ Role succeeded');

                for (const tid of createdIDs) {
                    const rows = await FindRows<{ AssigneeRecordID: string }>(
                        ctx,
                        TASK_ASSIGNMENT_ENTITY,
                        `TaskID = '${tid}'`,
                        ['AssigneeRecordID'],
                    );
                    AssertEqual(rows.length, 3, `task ${tid} has 3 assignees (personA, personB, MJ Role)`);
                }

                // 4. Clear all assignees
                const r4 = await op.Execute(
                    { TaskIDs: createdIDs, AssigneeMode: 'clear' },
                    { provider: ctx.Provider, user: ctx.User },
                );
                Assert(r4.Success && r4.Output?.UpdatedCount === 2, 'bulk clear assignees succeeded');

                for (const tid of createdIDs) {
                    const rows = await FindRows<{ ID: string }>(ctx, TASK_ASSIGNMENT_ENTITY, `TaskID = '${tid}'`, ['ID']);
                    AssertEqual(rows.length, 0, `task ${tid} has 0 assignees after clear`);
                }
            } finally {
                for (const id of createdIDs) await deleteTaskCascade(ctx, id);
                await cleanup();
            }
        },
    },
    {
        Id: 'task-org-bulk-ops.TOB4',
        Name: 'TOB4 — BizAppsTasks.BulkUpdateTasks redates (set, shift ±d on DueAt+StartedAt, clear), scopes Org, updates Status/Priority, and links Tags idempotently',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const { actionItemID } = await resolveShippedTaskTypes(ctx);
            const stamp = Date.now();
            const org = await createTempOrg(ctx, `IT Bulk Org ${stamp}`);
            const tag = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTagEntity>(TASK_TAG_ENTITY, ctx.User);
            tag.NewRecord();
            tag.Name = `IT-Bulk-${stamp}`;
            await RequireSave(tag, 'create temp tag');

            const createdIDs: string[] = [];
            try {
                for (const label of ['1', '2']) {
                    const t = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASK_ENTITY, ctx.User);
                    t.NewRecord();
                    t.Name = `IT Bulk MultiField ${label} ${stamp}`;
                    t.TypeID = actionItemID;
                    t.Status = 'Open';
                    t.Priority = 'Low';
                    t.StartedAt = new Date('2026-12-01T12:00:00.000Z');
                    t.DueAt = new Date('2026-12-05T12:00:00.000Z');
                    await RequireSave(t, `create bulk multi-field task ${label}`);
                    createdIDs.push(t.ID);
                }

                const op = new TasksBulkUpdateOperation();

                // 1. Shift +4d, set Org, set Priority Critical, set InProgress, add Tag
                const shiftRes = await op.Execute(
                    {
                        TaskIDs: createdIDs,
                        Status: 'InProgress',
                        Priority: 'Critical',
                        DueDateMode: 'shift',
                        ShiftDays: 4,
                        OrganizationMode: 'set',
                        OrganizationID: org.ID,
                        AddTagID: tag.ID,
                    },
                    { provider: ctx.Provider, user: ctx.User },
                );
                Assert(shiftRes.Success && shiftRes.Output?.UpdatedCount === 2, 'compound bulk patch succeeded');

                // Calling AddTagID a second time must be idempotent (still 1 tag link per task)
                const dupTagRes = await op.Execute(
                    { TaskIDs: createdIDs, AddTagID: tag.ID },
                    { provider: ctx.Provider, user: ctx.User },
                );
                Assert(dupTagRes.Success, 'idempotent AddTagID succeeded');

                for (const tid of createdIDs) {
                    const [row] = await FindRows<{
                        Status: string;
                        Priority: string;
                        StartedAt: string | null;
                        DueAt: string | null;
                        OrganizationID: string | null;
                    }>(ctx, TASK_ENTITY, `ID = '${tid}'`, ['Status', 'Priority', 'StartedAt', 'DueAt', 'OrganizationID']);
                    AssertEqual(row.Status, 'InProgress', 'Status updated to InProgress');
                    AssertEqual(row.Priority, 'Critical', 'Priority updated to Critical');
                    Assert(SameID(row.OrganizationID, org.ID), 'OrganizationID stamped');
                    AssertEqual(isoDay(row.StartedAt), '2026-12-05', `StartedAt shifted +4d (got ${row.StartedAt})`);
                    AssertEqual(isoDay(row.DueAt), '2026-12-09', `DueAt shifted +4d (got ${row.DueAt})`);

                    const links = await FindRows<{ ID: string }>(
                        ctx,
                        TASK_TAG_LINK_ENTITY,
                        `TaskID = '${tid}' AND TagID = '${tag.ID}'`,
                        ['ID'],
                    );
                    AssertEqual(links.length, 1, 'AddTagID remained idempotent (1 link)');
                }

                // 2. Clear DueAt & OrganizationID
                const clearRes = await op.Execute(
                    { TaskIDs: createdIDs, DueDateMode: 'clear', OrganizationMode: 'clear' },
                    { provider: ctx.Provider, user: ctx.User },
                );
                Assert(clearRes.Success && clearRes.Output?.UpdatedCount === 2, 'bulk clear dates + org succeeded');
                const [cleared] = await FindRows<{ DueAt: string | null; OrganizationID: string | null }>(
                    ctx,
                    TASK_ENTITY,
                    `ID = '${createdIDs[0]}'`,
                    ['DueAt', 'OrganizationID'],
                );
                Assert(cleared.DueAt == null, 'DueAt cleared');
                Assert(cleared.OrganizationID == null, 'OrganizationID cleared');
            } finally {
                for (const id of createdIDs) await deleteTaskCascade(ctx, id);
                await tag.Delete();
                await org.Delete();
            }
        },
    },
    {
        Id: 'task-org-bulk-ops.TOB5',
        Name: 'TOB5 — BizAppsTasks.BulkUpdateTasks refuses empty TaskIDs and malformed UUIDs over GraphQL',
        RequiresMutation: false,
        Fn: async (ctx) => {
            const op = new TasksBulkUpdateOperation();

            const emptyRes = await op.Execute({ TaskIDs: [] }, { provider: ctx.Provider, user: ctx.User });
            Assert(!emptyRes.Success, 'empty TaskIDs must be refused');

            const badUuid = await op.Execute(
                { TaskIDs: ["invalid' OR 1=1 --"] },
                { provider: ctx.Provider, user: ctx.User },
            );
            Assert(!badUuid.Success, 'non-UUID TaskID must be refused');
        },
    },
    {
        Id: 'task-org-bulk-ops.TOB6',
        Name: 'TOB6 — BizAppsTasks.InstantiateTemplate creates parent/child tasks, dependencies, role assignments, and stamps OrganizationID',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const { deliverableID } = await resolveShippedTaskTypes(ctx);
            const { personA, cleanup } = await resolveTwoPeople(ctx);
            const stamp = Date.now();
            const org = await createTempOrg(ctx, `IT Playbook Org ${stamp}`);
            const taskRoles = await FindRows<{ ID: string; Name: string }>(ctx, TASK_ROLE_ENTITY, '', ['ID', 'Name']);
            const primaryRoleID = (taskRoles.find((r) => r.Name === 'Primary') ?? taskRoles[0])?.ID;
            Assert(Boolean(primaryRoleID), 'at least one Task Role exists');

            let tplID: string | null = null;
            let parentItemID: string | null = null;
            let childItemID: string | null = null;
            let itemRoleID: string | null = null;
            let itemDepID: string | null = null;
            let createdTaskIDs: string[] = [];

            try {
                const tpl = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateEntity>(TASK_TEMPLATE_ENTITY, ctx.User);
                tpl.NewRecord();
                tpl.Name = `IT Close Blueprint ${stamp}`;
                tpl.TypeID = deliverableID;
                await RequireSave(tpl, 'create test template');
                tplID = tpl.ID;

                const parentItem = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateItemEntity>(
                    TASK_TEMPLATE_ITEM_ENTITY,
                    ctx.User,
                );
                parentItem.NewRecord();
                parentItem.TemplateID = tpl.ID;
                parentItem.Name = `Close Kickoff ${stamp}`;
                parentItem.Priority = 'Critical';
                parentItem.DaysFromStart = 0;
                parentItem.Sequence = 10;
                await RequireSave(parentItem, 'create parent template item');
                parentItemID = parentItem.ID;

                const childItem = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateItemEntity>(
                    TASK_TEMPLATE_ITEM_ENTITY,
                    ctx.User,
                );
                childItem.NewRecord();
                childItem.TemplateID = tpl.ID;
                childItem.ParentItemID = parentItem.ID;
                childItem.Name = `Trial Balance Sign-off ${stamp}`;
                childItem.Priority = 'High';
                childItem.DaysFromStart = 5;
                childItem.Sequence = 20;
                await RequireSave(childItem, 'create child template item');
                childItemID = childItem.ID;

                const itemRole = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateItemRoleEntity>(
                    TASK_TEMPLATE_ITEM_ROLE_ENTITY,
                    ctx.User,
                );
                itemRole.NewRecord();
                itemRole.ItemID = childItem.ID;
                itemRole.RoleID = primaryRoleID;
                await RequireSave(itemRole, 'create template item role');
                itemRoleID = itemRole.ID;

                const itemDep = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateItemDependencyEntity>(
                    TASK_TEMPLATE_ITEM_DEP_ENTITY,
                    ctx.User,
                );
                itemDep.NewRecord();
                itemDep.ItemID = childItem.ID;
                itemDep.DependsOnItemID = parentItem.ID;
                itemDep.DependencyType = 'FinishToStart';
                await RequireSave(itemDep, 'create template item dependency');
                itemDepID = itemDep.ID;

                // Execute server-side InstantiateTemplate RPC over GraphQL
                const op = new TasksInstantiateTemplateOperation();
                const res = await op.Execute(
                    {
                        TemplateID: tpl.ID,
                        StartDate: '2026-12-01',
                        OrganizationID: org.ID,
                        RoleAssignments: [
                            {
                                RoleID: primaryRoleID,
                                EntityName: PERSON_ENTITY,
                                RecordID: personA.ID,
                            },
                        ],
                    },
                    { provider: ctx.Provider, user: ctx.User },
                );

                Assert(res.Success, `InstantiateTemplate RPC failed: ${res.ErrorMessage ?? 'unknown'}`);
                AssertEqual(res.Output?.CreatedCount, 2, '2 tasks created from playbook');
                Assert(SameID(res.Output?.OrganizationID, org.ID), 'output echoes stamped OrganizationID');
                createdTaskIDs = res.Output?.CreatedTaskIDs ?? [];

                const [rootRow] = await FindRows<{
                    ID: string;
                    Name: string;
                    ParentID: string | null;
                    OrganizationID: string | null;
                    DueAt: string | null;
                }>(ctx, TASK_ENTITY, `ID = '${createdTaskIDs[0]}'`, ['ID', 'Name', 'ParentID', 'OrganizationID', 'DueAt']);
                const [childRow] = await FindRows<{
                    ID: string;
                    Name: string;
                    ParentID: string | null;
                    OrganizationID: string | null;
                    DueAt: string | null;
                }>(ctx, TASK_ENTITY, `ID = '${createdTaskIDs[1]}'`, ['ID', 'Name', 'ParentID', 'OrganizationID', 'DueAt']);

                AssertEqual(rootRow.Name, parentItem.Name, 'parent created first');
                Assert(SameID(rootRow.OrganizationID, org.ID), 'root task stamped with OrganizationID');
                Assert(SameID(childRow.ParentID, rootRow.ID), 'child linked to created parent');
                Assert(SameID(childRow.OrganizationID, org.ID), 'child task stamped with OrganizationID');
                AssertEqual(isoDay(childRow.DueAt), '2026-12-06', `child DueAt offset +5d (got ${childRow.DueAt})`);

                const childAssigns = await FindRows<{ AssigneeRecordID: string }>(
                    ctx,
                    TASK_ASSIGNMENT_ENTITY,
                    `TaskID = '${childRow.ID}'`,
                    ['AssigneeRecordID'],
                );
                AssertEqual(childAssigns.length, 1, 'child received role-mapped assignee');
                Assert(SameID(childAssigns[0].AssigneeRecordID, personA.ID), 'child assigned to personA');

                const childDeps = await FindRows<{ DependsOnTaskID: string; DependencyType: string }>(
                    ctx,
                    TASK_DEPENDENCY_ENTITY,
                    `TaskID = '${childRow.ID}'`,
                    ['DependsOnTaskID', 'DependencyType'],
                );
                AssertEqual(childDeps.length, 1, 'child received dependency link');
                Assert(SameID(childDeps[0].DependsOnTaskID, rootRow.ID), 'dependency points to created root task');
            } finally {
                for (const id of [...createdTaskIDs].reverse()) {
                    await deleteTaskCascade(ctx, id);
                }
                if (itemDepID) {
                    const e = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateItemDependencyEntity>(TASK_TEMPLATE_ITEM_DEP_ENTITY, ctx.User);
                    if (await e.Load(itemDepID)) await e.Delete();
                }
                if (itemRoleID) {
                    const e = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateItemRoleEntity>(TASK_TEMPLATE_ITEM_ROLE_ENTITY, ctx.User);
                    if (await e.Load(itemRoleID)) await e.Delete();
                }
                if (childItemID) {
                    const e = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateItemEntity>(TASK_TEMPLATE_ITEM_ENTITY, ctx.User);
                    if (await e.Load(childItemID)) await e.Delete();
                }
                if (parentItemID) {
                    const e = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateItemEntity>(TASK_TEMPLATE_ITEM_ENTITY, ctx.User);
                    if (await e.Load(parentItemID)) await e.Delete();
                }
                if (tplID) {
                    const e = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateEntity>(TASK_TEMPLATE_ENTITY, ctx.User);
                    if (await e.Load(tplID)) await e.Delete();
                }
                await org.Delete();
                await cleanup();
            }
        },
    },

    // =========================================================================
    // TOB7: BizAppsTasks.RunRecurringPlaybooks — DryRun + multi-org rollout +
    //       idempotent PeriodKey skip on re-run
    // =========================================================================
    {
        Id: 'task-org-bulk-ops.TOB7',
        Name: 'TOB7 — BizAppsTasks.RunRecurringPlaybooks idempotently launches multi-org close playbook for a PeriodKey',
        RequiresMutation: true,
        Fn: async (ctx: IntegrationCheckContext) => {
            const { deliverableID } = await resolveShippedTaskTypes(ctx);
            const stamp = Date.now();
            const org1 = await createTempOrg(ctx, `CloseSub US ${stamp}`);
            const org2 = await createTempOrg(ctx, `CloseSub UK ${stamp}`);
            let tplID: string | null = null;
            let itemID: string | null = null;
            const createdTaskIDs: string[] = [];

            try {
                const tpl = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateEntity>(TASK_TEMPLATE_ENTITY, ctx.User);
                tpl.NewRecord();
                tpl.Name = `Month-End Close Recurring ${stamp}`;
                tpl.TypeID = deliverableID;
                tpl.IsActive = true;
                await RequireSave(tpl, 'create recurring close template');
                tplID = tpl.ID;

                const item = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateItemEntity>(TASK_TEMPLATE_ITEM_ENTITY, ctx.User);
                item.NewRecord();
                item.TemplateID = tpl.ID;
                item.Name = 'Reconcile Intercompany Balances';
                item.Priority = 'High';
                item.DaysFromStart = 2;
                item.Sequence = 10;
                await RequireSave(item, 'create recurring close template item');
                itemID = item.ID;

                const periodKey = `2026-12-IT-${Date.now().toString(36)}`;
                const op = new TasksRunRecurringPlaybooksOperation();

                // 1. DryRun reports 2 dry-run targets without creating tasks
                const dry = await op.Execute(
                    {
                        TemplateID: tpl.ID,
                        AnchorDate: '2026-12-01',
                        PeriodKey: periodKey,
                        OrganizationIDs: [org1.ID, org2.ID],
                        DryRun: true,
                    },
                    { provider: ctx.Provider, user: ctx.User },
                );
                Assert(dry.Success && dry.Output != null, `DryRun failed: ${dry.ErrorMessage ?? 'unknown'}`);
                AssertEqual(dry.Output.TargetOrganizations, 2, 'DryRun targets both orgs');
                AssertEqual(dry.Output.LaunchedCount, 0, 'DryRun launches zero');
                AssertEqual(dry.Output.Results.filter((r) => r.Status === 'dry-run').length, 2, 'Both marked dry-run');

                // 2. Live run spawns close tasks for both orgs
                const live1 = await op.Execute(
                    {
                        TemplateID: tpl.ID,
                        AnchorDate: '2026-12-01',
                        PeriodKey: periodKey,
                        OrganizationIDs: [org1.ID, org2.ID],
                        DryRun: false,
                    },
                    { provider: ctx.Provider, user: ctx.User },
                );
                Assert(live1.Success && live1.Output != null, `Live run 1 failed: ${live1.ErrorMessage ?? 'unknown'}`);
                AssertEqual(live1.Output.LaunchedCount, 2, 'Launched for both orgs');
                AssertEqual(live1.Output.SkippedCount, 0, 'Zero skipped on first run');
                AssertEqual(live1.Output.TotalTasksCreated, 2, 'Created 1 task per org');
                for (const r of live1.Output.Results) {
                    createdTaskIDs.push(...r.CreatedTaskIDs);
                }

                // 3. Re-running with the same PeriodKey skips both idempotently
                const live2 = await op.Execute(
                    {
                        TemplateID: tpl.ID,
                        AnchorDate: '2026-12-01',
                        PeriodKey: periodKey,
                        OrganizationIDs: [org1.ID, org2.ID],
                        DryRun: false,
                    },
                    { provider: ctx.Provider, user: ctx.User },
                );
                Assert(live2.Success && live2.Output != null, `Live run 2 failed: ${live2.ErrorMessage ?? 'unknown'}`);
                AssertEqual(live2.Output.LaunchedCount, 0, 'Zero launched on idempotent re-run');
                AssertEqual(live2.Output.SkippedCount, 2, 'Both orgs skipped on re-run');
                AssertEqual(live2.Output.TotalTasksCreated, 0, 'Zero duplicate tasks created');
            } finally {
                for (const tid of [...createdTaskIDs].reverse()) {
                    await deleteTaskCascade(ctx, tid);
                }
                if (itemID) {
                    const e = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateItemEntity>(TASK_TEMPLATE_ITEM_ENTITY, ctx.User);
                    if (await e.Load(itemID)) await e.Delete();
                }
                if (tplID) {
                    const e = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTemplateEntity>(TASK_TEMPLATE_ENTITY, ctx.User);
                    if (await e.Load(tplID)) await e.Delete();
                }
                await org1.Delete();
                await org2.Delete();
            }
        },
    },
];

for (const check of checks) {
    IntegrationCheckRegistry.Instance.Register(check);
}

IntegrationCheckRegistry.Instance.RegisterLifecycle('task-org-bulk-ops', {
    Setup: async () => {},
    Teardown: async () => {},
});
