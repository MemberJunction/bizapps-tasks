import { Assert, IntegrationCheckRegistry, type IntegrationCheckContext, type NamedCheck } from '@memberjunction/testing-integration/registry';
import { CompositeKey } from '@memberjunction/core';
import type {
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskTypeEntity,
    mjBizAppsTasksTaskTypeStatusEntity,
} from '@mj-biz-apps/tasks-entities';
import { TaskOrchestrationService } from '@mj-biz-apps/tasks-core';
import {
    PERSON_ENTITY,
    TASK_ASSIGNMENT_ENTITY,
    TASK_DECISION_ENTITY,
    TASK_ENTITY,
    TASK_TYPE_ENTITY,
    TASK_TYPE_STATUS_ENTITY,
} from '../entity-names.js';
import { DeleteTask, FindId, FindRows, RequireSave } from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

/**
 * Lifecycle hook ROUTING checks (OnReject / OnCancel / OnComplete).
 *
 * Every check builds a throwaway TaskType whose reject / cancel / complete hooks point at two
 * DIFFERENT world actions, drives a transition, then counts 'MJ: Action Execution Logs' rows per
 * action written since the check started. That proves not only that a hook fired but WHICH one
 * fired, and how many times. Hook dispatch is fire-and-forget after Save, so the count is polled.
 */

const ACTION_EXECUTION_LOG_ENTITY = 'MJ: Action Execution Logs';
const PROBE_TYPE_CODE = 'HOOK_ROUTING_PROBE';

type ProbeFixture = {
    TypeID: string;
    Stages: Record<'OPEN' | 'REJECTED' | 'CANCELLED' | 'DONE', string>;
    RejectActionID: string;
    CancelActionID: string;
};

/** Creates (or reuses) the probe TaskType: OnReject → calc, OnCancel → color, OnComplete → calc. */
async function EnsureProbeType(ctx: IntegrationCheckContext): Promise<ProbeFixture> {
    const world = await GetOrLoadWorld(ctx);
    const calc = world.Actions['Calculate Expression'];
    const color = world.Actions['Color Converter'];
    Assert(!!calc && !!color, 'two distinct candidate actions available (Calculate Expression, Color Converter)');

    const existingID = await FindId(ctx, TASK_TYPE_ENTITY, `Code = '${PROBE_TYPE_CODE}'`);
    const type = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTypeEntity>(TASK_TYPE_ENTITY, ctx.User);
    if (existingID) await type.Load(existingID); else type.NewRecord();
    type.Name = 'Hook Routing Probe';
    type.Code = PROBE_TYPE_CODE;
    type.Description = 'Throwaway type for OnReject/OnCancel/OnComplete routing checks';
    type.OnRejectActionID = calc.ID;
    type.OnCancelActionID = color.ID;
    type.OnCompleteActionID = calc.ID;
    type.IsActive = true;
    await RequireSave(type, 'probe task type');

    const stageDefs: Array<{ code: ProbeFixture['Stages'] extends Record<infer K, string> ? K : never; macro: mjBizAppsTasksTaskTypeStatusEntity['MacroStatus']; seq: number; isDefault: boolean; isTerminal: boolean }> = [
        { code: 'OPEN', macro: 'Open', seq: 100, isDefault: true, isTerminal: false },
        { code: 'REJECTED', macro: 'Cancelled', seq: 200, isDefault: false, isTerminal: true },
        { code: 'CANCELLED', macro: 'Cancelled', seq: 300, isDefault: false, isTerminal: true },
        { code: 'DONE', macro: 'Completed', seq: 400, isDefault: false, isTerminal: true },
    ];
    const Stages = {} as ProbeFixture['Stages'];
    for (const def of stageDefs) {
        const stageID = await FindId(ctx, TASK_TYPE_STATUS_ENTITY, `TaskTypeID = '${type.ID}' AND Code = '${def.code}'`);
        const stage = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTypeStatusEntity>(TASK_TYPE_STATUS_ENTITY, ctx.User);
        if (stageID) await stage.Load(stageID); else stage.NewRecord();
        stage.TaskTypeID = type.ID;
        stage.Name = def.code;
        stage.Code = def.code;
        stage.MacroStatus = def.macro;
        stage.Sequence = def.seq;
        stage.IsDefault = def.isDefault;
        stage.IsTerminal = def.isTerminal;
        stage.IsActive = true;
        await RequireSave(stage, `probe stage ${def.code}`);
        Stages[def.code] = stage.ID;
    }
    return { TypeID: type.ID, Stages, RejectActionID: calc.ID, CancelActionID: color.ID };
}

/** Creates a probe task in its default (OPEN) stage and returns the loaded entity. */
async function CreateProbeTask(ctx: IntegrationCheckContext, fixture: ProbeFixture, name: string): Promise<mjBizAppsTasksTaskEntity> {
    const task = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASK_ENTITY, ctx.User);
    task.NewRecord();
    task.Name = name;
    task.TypeID = fixture.TypeID;
    task.TaskTypeStatusID = fixture.Stages.OPEN;
    task.Status = 'Open';
    task.Priority = 'Medium';
    await RequireSave(task, `probe task ${name}`);
    return task;
}

/** Counts execution-log rows for an action started at or after `since`, polling until the count settles. */
async function CountRuns(ctx: IntegrationCheckContext, actionID: string, since: Date): Promise<number> {
    const sinceISO = since.toISOString();
    let last = -1;
    let stable = 0;
    for (let i = 0; i < 16; i++) {
        await new Promise(resolve => setTimeout(resolve, 500));
        const rows = await FindRows<{ ID: string }>(ctx, ACTION_EXECUTION_LOG_ENTITY, `ActionID = '${actionID}' AND StartedAt >= '${sinceISO}'`, ['ID']);
        if (rows.length === last) { if (++stable >= 3) break; } else { stable = 0; }
        last = rows.length;
    }
    return Math.max(last, 0);
}

async function DeleteRowsForTask(ctx: IntegrationCheckContext, entityName: string, taskID: string): Promise<void> {
    const rows = await FindRows<{ ID: string }>(ctx, entityName, `TaskID = '${taskID}'`, ['ID']);
    for (const row of rows) {
        const rec = await ctx.Provider.GetEntityObject(entityName, ctx.User);
        const key = new CompositeKey();
        key.KeyValuePairs.push({ FieldName: 'ID', Value: row.ID });
        if (await rec.InnerLoad(key)) Assert(await rec.Delete(), `cleanup ${entityName} ${row.ID}`);
    }
}

async function CleanupProbeTask(ctx: IntegrationCheckContext, taskID: string): Promise<void> {
    await DeleteRowsForTask(ctx, TASK_DECISION_ENTITY, taskID);
    await DeleteRowsForTask(ctx, TASK_ASSIGNMENT_ENTITY, taskID);
    const task = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASK_ENTITY, ctx.User);
    const key = new CompositeKey();
    key.KeyValuePairs.push({ FieldName: 'ID', Value: taskID });
    Assert(await task.InnerLoad(key), `reload probe task ${taskID}`);
    await DeleteTask(ctx, task);
}

/** Person the harness user is linked to — required for the decision-driven checks. */
function CallerPersonID(ctx: IntegrationCheckContext): string {
    const raw = ctx.User.LinkedEntityRecordID;
    const id = raw == null ? '' : String(raw).trim();
    Assert(!!id, 'harness user must be linked to a Person (User.LinkedEntityRecordID) for decision-driven checks');
    return id;
}

const checks: NamedCheck[] = [
    {
        Id: 'task-hook-routing.HR1',
        Name: 'HR1 — landing on the REJECTED stage (no decision row) fires OnReject once and never OnCancel',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const fx = await EnsureProbeType(ctx);
            const task = await CreateProbeTask(ctx, fx, 'HR1 stage-driven rejection');
            try {
                const since = new Date();
                task.TaskTypeStatusID = fx.Stages.REJECTED;
                await RequireSave(task, 'HR1 move to REJECTED stage');
                Assert(task.Status === 'Cancelled', `macro status synced to Cancelled (got ${task.Status})`);

                const rejects = await CountRuns(ctx, fx.RejectActionID, since);
                const cancels = await CountRuns(ctx, fx.CancelActionID, since);
                Assert(rejects === 1, `OnReject fired exactly once (got ${rejects})`);
                Assert(cancels === 0, `OnCancel did not fire (got ${cancels})`);
            } finally {
                await CleanupProbeTask(ctx, task.ID);
            }
        },
    },
    {
        Id: 'task-hook-routing.HR2',
        Name: 'HR2 — landing on a plain CANCELLED stage fires OnCancel once and never OnReject',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const fx = await EnsureProbeType(ctx);
            const task = await CreateProbeTask(ctx, fx, 'HR2 plain cancel');
            try {
                const since = new Date();
                task.TaskTypeStatusID = fx.Stages.CANCELLED;
                await RequireSave(task, 'HR2 move to CANCELLED stage');
                Assert(task.Status === 'Cancelled', `macro status synced to Cancelled (got ${task.Status})`);

                const cancels = await CountRuns(ctx, fx.CancelActionID, since);
                const rejects = await CountRuns(ctx, fx.RejectActionID, since);
                Assert(cancels === 1, `OnCancel fired exactly once (got ${cancels})`);
                Assert(rejects === 0, `OnReject did not fire (got ${rejects})`);
            } finally {
                await CleanupProbeTask(ctx, task.ID);
            }
        },
    },
    {
        Id: 'task-hook-routing.HR3',
        Name: 'HR3 — a Rejected decision via RecordDecision fires OnReject exactly once (no double dispatch)',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const fx = await EnsureProbeType(ctx);
            const callerPerson = CallerPersonID(ctx);
            const personEntity = ctx.Provider.EntityByName(PERSON_ENTITY);
            Assert(!!personEntity, 'People entity');
            const svc = new TaskOrchestrationService();
            const task = await svc.CreateApprovalRequest({
                Name: 'HR3 decision-driven rejection',
                TypeID: fx.TypeID,
                ApproverPersonEntityID: personEntity!.ID,
                ApproverPersonRecordIDs: [callerPerson],
            }, ctx.User);
            try {
                const since = new Date();
                const result = await svc.RecordDecision({ TaskID: task.ID, OutcomeCode: 'Rejected', Notes: 'HR3' }, ctx.User);
                Assert(result.NewStatus === 'Cancelled', `Rejected maps to Cancelled (got ${result.NewStatus})`);

                const rejects = await CountRuns(ctx, fx.RejectActionID, since);
                const cancels = await CountRuns(ctx, fx.CancelActionID, since);
                Assert(rejects === 1, `OnReject fired exactly once — not twice (got ${rejects})`);
                Assert(cancels === 0, `OnCancel did not fire alongside OnReject (got ${cancels})`);
            } finally {
                await CleanupProbeTask(ctx, task.ID);
            }
        },
    },
    {
        Id: 'task-hook-routing.HR4',
        Name: 'HR4 — approving via RecordDecision fires OnComplete exactly once, and a later edit does not replay it',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const fx = await EnsureProbeType(ctx);
            const callerPerson = CallerPersonID(ctx);
            const personEntity = ctx.Provider.EntityByName(PERSON_ENTITY);
            Assert(!!personEntity, 'People entity');
            const svc = new TaskOrchestrationService();
            const task = await svc.CreateApprovalRequest({
                Name: 'HR4 approve once',
                TypeID: fx.TypeID,
                ApproverPersonEntityID: personEntity!.ID,
                ApproverPersonRecordIDs: [callerPerson],
            }, ctx.User);
            try {
                const since = new Date();
                const result = await svc.RecordDecision({ TaskID: task.ID, OutcomeCode: 'Approved', Notes: 'HR4' }, ctx.User);
                Assert(result.NewStatus === 'Completed', `Approved maps to Completed (got ${result.NewStatus})`);
                // OnComplete → calc action; nothing routes to the color action on completion.
                const completes = await CountRuns(ctx, fx.RejectActionID, since);
                Assert(completes === 1, `OnComplete fired exactly once — not twice (got ${completes})`);

                // A later non-status edit of the Completed task must NOT replay OnComplete.
                const editSince = new Date();
                const reloaded = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASK_ENTITY, ctx.User);
                const key = new CompositeKey();
                key.KeyValuePairs.push({ FieldName: 'ID', Value: task.ID });
                Assert(await reloaded.InnerLoad(key), 'reload completed task');
                reloaded.Description = 'HR4 typo fix after completion';
                await RequireSave(reloaded, 'HR4 post-completion edit');
                const replays = await CountRuns(ctx, fx.RejectActionID, editSince);
                Assert(replays === 0, `editing a Completed task did not replay OnComplete (got ${replays})`);
            } finally {
                await CleanupProbeTask(ctx, task.ID);
            }
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('task-hook-routing', { Setup: async () => {}, Teardown: async () => {} });
