import { Assert, AssertEqual, IntegrationCheckRegistry, type NamedCheck } from '@memberjunction/testing-integration/registry';
import { TaskEntity } from '@mj-biz-apps/tasks-entities';
import { TASK_ENTITY } from '../entity-names.js';
import { DeleteTask, FindRows, RequireSave } from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

const checks: NamedCheck[] = [
    {
        Id: 'task-statuses.TS1',
        Name: 'TS1 — task creation defaults TaskTypeStatusID and synchronizes MacroStatus',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const deliverableType = world.TaskTypes['DELIVERABLE'] ?? world.TaskTypes['Deliverable'];
            const draftStatus = world.TaskTypeStatuses['DELIVERABLE.DRAFT'];
            const catID = world.Categories['Product & Design']?.ID ?? Object.values(world.Categories)[0].ID;
            Assert(!!deliverableType && !!draftStatus, 'deliverable type and draft status available');

            const task = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            task.NewRecord();
            task.Name = `TS1 Draft Task ${Date.now()}`;
            task.TypeID = deliverableType.ID;
            task.CategoryID = catID;
            task.Priority = 'Medium';
            await RequireSave(task, 'TS1 task');

            Assert(!!task.TaskTypeStatusID, 'TaskTypeStatusID auto-assigned by server default');
            AssertEqual(task.TaskTypeStatusID.toLowerCase(), draftStatus.ID.toLowerCase(), 'assigned DRAFT status');
            AssertEqual(task.Status, 'Open', 'macro status is Open');

            await DeleteTask(ctx, task);
        },
    },
    {
        Id: 'task-statuses.TS2',
        Name: 'TS2 — advancing to terminal status auto-sets Completed macro status and 100% progress',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const deliverableType = world.TaskTypes['DELIVERABLE'] ?? world.TaskTypes['Deliverable'];
            const inReviewStatus = world.TaskTypeStatuses['DELIVERABLE.IN_REVIEW'];
            const approvedStatus = world.TaskTypeStatuses['DELIVERABLE.APPROVED'];
            const catID = world.Categories['Engineering & Development'].ID;
            Assert(!!deliverableType && !!inReviewStatus && !!approvedStatus, 'status definitions');

            const task = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            task.NewRecord();
            task.Name = `TS2 Terminal Lifecycle ${Date.now()}`;
            task.TypeID = deliverableType.ID;
            task.TaskTypeStatusID = inReviewStatus.ID;
            task.CategoryID = catID;
            task.Priority = 'High';
            task.PercentComplete = 30;
            await RequireSave(task, 'TS2 task in review');

            AssertEqual(task.Status, 'InProgress', 'in review is InProgress');

            // Advance to terminal approved status
            task.TaskTypeStatusID = approvedStatus.ID;
            await RequireSave(task, 'TS2 task approved');

            AssertEqual(task.Status, 'Completed', 'macro status transitioned to Completed');
            AssertEqual(task.PercentComplete, 100, 'percent complete is 100%');
            Assert(!!task.CompletedAt, 'CompletedAt timestamp populated');

            await DeleteTask(ctx, task);
        },
    },
    {
        Id: 'task-statuses.TS3',
        Name: 'TS3 — multi-stage construction lifecycle transitions and inspection gates',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const constrType = world.TaskTypes['CONSTRUCTION_MILESTONE'];
            const planning = world.TaskTypeStatuses['CONSTRUCTION_MILESTONE.PLANNING'];
            const underConstr = world.TaskTypeStatuses['CONSTRUCTION_MILESTONE.UNDER_CONSTRUCTION'];
            const passed = world.TaskTypeStatuses['CONSTRUCTION_MILESTONE.INSPECTION_PASSED'];
            const catID = world.Categories['General Contracting & Construction']?.ID ?? Object.values(world.Categories)[0].ID;
            Assert(!!constrType && !!planning && !!underConstr && !!passed, 'construction type and statuses');

            const task = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            task.NewRecord();
            task.Name = `TS3 Foundation Inspection ${Date.now()}`;
            task.TypeID = constrType.ID;
            task.TaskTypeStatusID = planning.ID;
            task.CategoryID = catID;
            task.Priority = 'Critical';
            await RequireSave(task, 'TS3 task planning');

            AssertEqual(task.Status, 'Open', 'planning stage is Open');

            // Move to active construction
            task.TaskTypeStatusID = underConstr.ID;
            task.PercentComplete = 50;
            await RequireSave(task, 'TS3 under construction');
            AssertEqual(task.Status, 'InProgress', 'under construction is InProgress');

            // Final inspection passed (terminal)
            task.TaskTypeStatusID = passed.ID;
            await RequireSave(task, 'TS3 inspection passed');
            AssertEqual(task.Status, 'Completed', 'inspection passed is Completed');
            AssertEqual(task.PercentComplete, 100, 'progress is 100%');

            await DeleteTask(ctx, task);
        },
    },
    {
        Id: 'task-statuses.TS4',
        Name: 'TS4 — approval request rejection maps to Cancelled terminal status',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const approvalType = world.TaskTypes['APPROVAL_REQUEST'] ?? world.TaskTypes['Approval Request'];
            const submitted = world.TaskTypeStatuses['APPROVAL_REQUEST.SUBMITTED'];
            const rejected = world.TaskTypeStatuses['APPROVAL_REQUEST.REJECTED'];
            const catID = world.Categories['Operations & Legal'].ID;
            Assert(!!approvalType && !!submitted && !!rejected, 'approval type and rejected status');

            const task = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            task.NewRecord();
            task.Name = `TS4 Budget Variance ${Date.now()}`;
            task.TypeID = approvalType.ID;
            task.TaskTypeStatusID = submitted.ID;
            task.CategoryID = catID;
            task.Priority = 'Medium';
            await RequireSave(task, 'TS4 task submitted');

            AssertEqual(task.Status, 'Open', 'submitted is Open');

            // Transition to Rejected (terminal Cancelled)
            task.TaskTypeStatusID = rejected.ID;
            await RequireSave(task, 'TS4 task rejected');

            AssertEqual(task.Status, 'Cancelled', 'rejected mapped to Cancelled macro status');
            AssertEqual(task.PercentComplete, 100, 'progress is 100% on rejection');

            await DeleteTask(ctx, task);
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('task-statuses', { Setup: async () => {}, Teardown: async () => {} });
