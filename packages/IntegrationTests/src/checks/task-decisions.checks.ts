import { Assert, IntegrationCheckRegistry, type IntegrationCheckContext, type NamedCheck } from '@memberjunction/testing-integration/registry';
import { CompositeKey } from '@memberjunction/core';
import { mjBizAppsTasksTaskAssignmentEntity, mjBizAppsTasksTaskDecisionEntity, mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import { TaskOrchestrationService } from '@mj-biz-apps/tasks-core';
import { PERSON_ENTITY, TASK_ASSIGNMENT_ENTITY, TASK_DECISION_ENTITY, TASK_ENTITY, TASK_ROLE_ENTITY } from '../entity-names.js';
import { DeleteTask, FindRows, RequireSave, SameID } from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

// ── Service-path helpers (TDN3+) ────────────────────────────────────────────

/**
 * The Person the authenticated harness user is linked to, via MJ core's `User.LinkedEntityRecordID`.
 * `RecordDecision` derives the decider from this link, so the harness user MUST be linked to a
 * Person that exists in `MJ_BizApps_Common: People` before the service-path checks can run.
 * (An admin sets this in the MJ Users form; the harness setup does the same by SQL.)
 */
function CallerPersonID(ctx: IntegrationCheckContext): string {
    const raw = ctx.User.LinkedEntityRecordID;
    const id = raw == null ? '' : String(raw).trim();
    Assert(!!id, 'harness user is not linked to a Person (User.LinkedEntityRecordID is empty) — link it before running the service-path decision checks');
    return id;
}

/** Creates an approval request assigned to the given Person IDs; returns the new task ID. */
async function CreateApproval(ctx: IntegrationCheckContext, name: string, approverPersonIDs: string[]): Promise<string> {
    const world = await GetOrLoadWorld(ctx);
    const approvalType = world.TaskTypes['APPROVAL_REQUEST'] ?? world.TaskTypes['Approval Request'];
    const personEntity = ctx.Provider.EntityByName(PERSON_ENTITY);
    Assert(!!approvalType && !!personEntity, 'seed approval type + People entity');
    const task = await new TaskOrchestrationService().CreateApprovalRequest(
        {
            Name: name,
            TypeID: approvalType.ID,
            ApproverPersonEntityID: personEntity!.ID,
            ApproverPersonRecordIDs: approverPersonIDs,
        },
        ctx.User,
    );
    return task.ID;
}

/** Removes decisions, assignments, activities and the task itself. */
async function CleanupApproval(ctx: IntegrationCheckContext, taskID: string): Promise<void> {
    for (const entityName of [TASK_DECISION_ENTITY, TASK_ASSIGNMENT_ENTITY]) {
        const rows = await FindRows<{ ID: string }>(ctx, entityName, `TaskID = '${taskID}'`, ['ID']);
        for (const row of rows) {
            const rec = await ctx.Provider.GetEntityObject(entityName, ctx.User);
            const key = new CompositeKey();
            key.KeyValuePairs.push({ FieldName: 'ID', Value: row.ID });
            if (await rec.InnerLoad(key)) Assert(await rec.Delete(), `cleanup ${entityName} ${row.ID}`);
        }
    }
    const task = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASK_ENTITY, ctx.User);
    const key = new CompositeKey();
    key.KeyValuePairs.push({ FieldName: 'ID', Value: taskID });
    Assert(await task.InnerLoad(key), `reload task ${taskID} for cleanup`);
    await DeleteTask(ctx, task);
}

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
    {
        Id: 'task-decisions.TDN3',
        Name: 'TDN3 — RecordDecision stamps the decider from the authenticated user and binds the caller assignment',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const callerPerson = CallerPersonID(ctx);
            const taskID = await CreateApproval(ctx, 'TDN3 service-path approval', [callerPerson]);
            try {
                const svc = new TaskOrchestrationService();
                // No DecidedByPersonID supplied — the service must derive it from the caller.
                const result = await svc.RecordDecision({ TaskID: taskID, OutcomeCode: 'Approved', Notes: 'TDN3' }, ctx.User);

                Assert(SameID(result.Decision.DecidedByPersonID, callerPerson), 'decider stamped from the authenticated user');
                const assignments = await FindRows<{ ID: string; AssigneeRecordID: string }>(ctx, TASK_ASSIGNMENT_ENTITY, `TaskID = '${taskID}'`, ['ID', 'AssigneeRecordID']);
                Assert(assignments.length === 1, 'exactly one approver assignment');
                Assert(SameID(result.Decision.TaskAssignmentID, assignments[0].ID), 'decision bound to the caller\'s own assignment');
                Assert(result.NewStatus === 'Completed', `terminal outcome completed the task (got ${result.NewStatus})`);

                const persisted = await FindRows<{ ID: string; DecidedByPersonID: string; TaskAssignmentID: string }>(ctx, TASK_DECISION_ENTITY, `TaskID = '${taskID}'`, ['ID', 'DecidedByPersonID', 'TaskAssignmentID']);
                Assert(persisted.length === 1 && SameID(persisted[0].DecidedByPersonID, callerPerson), 'persisted decision carries the caller Person');
            } finally {
                await CleanupApproval(ctx, taskID);
            }
        },
    },
    {
        Id: 'task-decisions.TDN4',
        Name: 'TDN4 — RecordDecision rejects a caller who is not an active approver, and a forged decider',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const callerPerson = CallerPersonID(ctx);
            const world = await GetOrLoadWorld(ctx);
            const other = Object.values(world.People).find(p => !SameID(p.ID, callerPerson));
            Assert(!!other, 'a world Person other than the caller');
            const taskID = await CreateApproval(ctx, 'TDN4 not-my-approval', [other!.ID]);
            try {
                const svc = new TaskOrchestrationService();
                let unassignedError = '';
                try { await svc.RecordDecision({ TaskID: taskID, OutcomeCode: 'Approved' }, ctx.User); }
                catch (e) { unassignedError = e instanceof Error ? e.message : String(e); }
                Assert(/not an active approver/.test(unassignedError), `unassigned caller rejected (got: ${unassignedError || 'no error'})`);

                let forgedError = '';
                try { await svc.RecordDecision({ TaskID: taskID, OutcomeCode: 'Approved', DecidedByPersonID: other!.ID }, ctx.User); }
                catch (e) { forgedError = e instanceof Error ? e.message : String(e); }
                Assert(/another identity/.test(forgedError), `forged DecidedByPersonID rejected (got: ${forgedError || 'no error'})`);

                const decisions = await FindRows<{ ID: string }>(ctx, TASK_DECISION_ENTITY, `TaskID = '${taskID}'`, ['ID']);
                Assert(decisions.length === 0, 'no decision written on rejection');
            } finally {
                await CleanupApproval(ctx, taskID);
            }
        },
    },
    {
        Id: 'task-decisions.TDN5',
        Name: 'TDN5 — with two active assignments, the decision binds to the earliest one deterministically',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const callerPerson = CallerPersonID(ctx);
            // UQ_TaskAssignment_Unique spans (Task, AssigneeEntity, AssigneeRecord, Role), so the same
            // Person can hold two assignments only under different roles — e.g. Primary + Reviewer.
            const roles = await FindRows<{ ID: string; Name: string }>(ctx, TASK_ROLE_ENTITY, `Name IN ('Primary', 'Reviewer')`, ['ID', 'Name']);
            const primary = roles.find(r => r.Name === 'Primary');
            const reviewer = roles.find(r => r.Name === 'Reviewer');
            Assert(!!primary && !!reviewer, 'seeded Primary + Reviewer roles');
            const taskID = await CreateApproval(ctx, 'TDN5 double-assigned approval', [callerPerson]);
            try {
                const personEntity = ctx.Provider.EntityByName(PERSON_ENTITY)!;
                const second = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(TASK_ASSIGNMENT_ENTITY, ctx.User);
                second.NewRecord();
                second.TaskID = taskID;
                second.AssigneeEntityID = personEntity.ID;
                second.AssigneeRecordID = callerPerson;
                second.RoleID = reviewer!.ID;
                second.Status = 'Pending';
                await RequireSave(second, 'TDN5 second (Reviewer) assignment');

                const assignments = await FindRows<{ ID: string; __mj_CreatedAt: string | Date }>(ctx, TASK_ASSIGNMENT_ENTITY, `TaskID = '${taskID}'`, ['ID', '__mj_CreatedAt']);
                Assert(assignments.length === 2, `two assignments for the caller (got ${assignments.length})`);
                const createdAt = (a: { __mj_CreatedAt: string | Date }) => new Date(a.__mj_CreatedAt).getTime();
                const earliest = [...assignments].sort((a, b) => createdAt(a) - createdAt(b) || a.ID.localeCompare(b.ID))[0];

                const result = await new TaskOrchestrationService().RecordDecision({ TaskID: taskID, OutcomeCode: 'Approved' }, ctx.User);
                Assert(SameID(result.Decision.TaskAssignmentID, earliest.ID), 'bound to the earliest assignment');
            } finally {
                await CleanupApproval(ctx, taskID);
            }
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('task-decisions', { Setup: async () => {}, Teardown: async () => {} });
