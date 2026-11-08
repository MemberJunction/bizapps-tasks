import type { IRunViewProvider } from '@memberjunction/core';
import {
    Assert,
    AssertEqual,
    IntegrationCheckRegistry,
    type NamedCheck,
} from '@memberjunction/testing-integration/registry';
import { FromCalendarDay } from '@mj-biz-apps/common-entities';
import {
    TaskEntity,
    TasksReopenTimesheetOperation,
    TasksSubmitTimesheetOperation,
    TasksWithdrawTimesheetOperation,
    mjBizAppsTasksTaskActivityEntity,
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTaskDecisionEntity,
    mjBizAppsTasksTaskLinkEntity,
    mjBizAppsTasksTaskTimeEntryEntity,
    mjBizAppsTasksTimeApproverEntity,
    mjBizAppsTasksTimesheetApprovalEntity,
    mjBizAppsTasksTimesheetEntity,
    mjBizAppsTasksTimesheetScheduleEntity,
} from '@mj-biz-apps/tasks-entities';
import { ReconcileStaleTimesheetApprovals } from '@mj-biz-apps/tasks-server';
import {
    TASK_ACTIVITY_ENTITY,
    TASK_ASSIGNMENT_ENTITY,
    TASK_CATEGORY_ENTITY,
    TASK_DECISION_ENTITY,
    TASK_ENTITY,
    TASK_LINK_ENTITY,
    TASK_TIME_ENTRY_ENTITY,
    TIMESHEET_APPROVAL_ENTITY,
    TIMESHEET_ENTITY,
    TIMESHEET_SCHEDULE_ENTITY,
    TIME_APPROVER_ENTITY,
} from '../entity-names.js';
import {
    DeleteTask,
    FindRows,
    PersonaUser,
    RequireRefusal,
    RequireSave,
    SameID,
    WithTasksSetting,
} from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

async function cleanupTimesheetTree(
    ctx: Parameters<NamedCheck['Fn']>[0],
    timesheetID: string | null | undefined,
    entryIDs: readonly string[],
): Promise<void> {
    if (timesheetID) {
        const ts = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimesheetEntity>(TIMESHEET_ENTITY, ctx.User);
        if (await ts.Load(timesheetID)) {
            ts.Status = 'Draft';
            await ts.Save();
        }
    }

    for (const id of entryIDs) {
        const e = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
            TASK_TIME_ENTRY_ENTITY,
            ctx.User,
        );
        if (await e.Load(id)) {
            if (e.TimesheetID) {
                e.TimesheetID = null;
                await e.Save();
            }
            await e.Delete();
        }
    }

    if (timesheetID) {
        const parts = await FindRows<{ ID: string; ApprovalTaskID: string | null }>(
            ctx,
            TIMESHEET_APPROVAL_ENTITY,
            `TimesheetID = '${timesheetID}'`,
            ['ID', 'ApprovalTaskID'],
        );
        for (const p of parts) {
            const pe = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimesheetApprovalEntity>(
                TIMESHEET_APPROVAL_ENTITY,
                ctx.User,
            );
            if (await pe.Load(p.ID)) await pe.Delete();

            if (p.ApprovalTaskID) {
                const decisions = await FindRows<{ ID: string }>(
                    ctx,
                    TASK_DECISION_ENTITY,
                    `TaskID = '${p.ApprovalTaskID}'`,
                    ['ID'],
                );
                for (const d of decisions) {
                    const de = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskDecisionEntity>(
                        TASK_DECISION_ENTITY,
                        ctx.User,
                    );
                    if (await de.Load(d.ID)) await de.Delete();
                }

                const links = await FindRows<{ ID: string }>(
                    ctx,
                    TASK_LINK_ENTITY,
                    `TaskID = '${p.ApprovalTaskID}'`,
                    ['ID'],
                );
                for (const l of links) {
                    const le = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskLinkEntity>(
                        TASK_LINK_ENTITY,
                        ctx.User,
                    );
                    if (await le.Load(l.ID)) await le.Delete();
                }

                const asgns = await FindRows<{ ID: string }>(
                    ctx,
                    TASK_ASSIGNMENT_ENTITY,
                    `TaskID = '${p.ApprovalTaskID}'`,
                    ['ID'],
                );
                for (const a of asgns) {
                    const ae = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(
                        TASK_ASSIGNMENT_ENTITY,
                        ctx.User,
                    );
                    if (await ae.Load(a.ID)) await ae.Delete();
                }

                const task = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
                if (await task.Load(p.ApprovalTaskID)) {
                    await DeleteTask(ctx, task);
                }
            }
        }

        const ts = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimesheetEntity>(TIMESHEET_ENTITY, ctx.User);
        if (await ts.Load(timesheetID)) {
            await ts.Delete();
        }
    }
}

const checks: NamedCheck[] = [
    {
        Id: 'timesheets.TSH1',
        Name: 'TSH1 — period spanning two projects and personal scope submits as 3 parts, enforces R6 lock and D13 self-decision refusal, and turns Approved when all 3 parts are approved',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const sarah = world.People['sarah.connor@task-world.test'];
            const alex = world.People['alex.chen@task-world.test'];
            const marcus = world.People['marcus.vance@task-world.test'];
            const elena = world.People['elena.rostova@task-world.test'];
            const p1RootID = world.SeedTaskIDs['Website Redesign & Portal Launch'];
            const p1SubID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const p2RootID = world.SeedTaskIDs['Corporate HQ Campus Construction & Relocation'];
            const p2SubID = world.SeedTaskIDs['Architectural Blueprints & Structural Engineering'];
            const generalType = world.TaskTypes['GENERAL'] ?? Object.values(world.TaskTypes)[0];
            const catID = world.Categories['Operations & Legal'].ID;
            const approvedOutcome = world.DecisionOutcomes['Approved'] ?? Object.values(world.DecisionOutcomes)[0];

            const sarahUser = PersonaUser(ctx, sarah.ID, { canManage: false });
            const alexUser = PersonaUser(ctx, alex.ID, { canManage: false });

            // Standalone unassigned task with no task-level approver (falls back to Sarah's worker approver Elena)
            const standaloneTask = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            standaloneTask.NewRecord();
            standaloneTask.Name = `TSH1 Internal Admin Task ${Date.now()}`;
            standaloneTask.TypeID = generalType.ID;
            standaloneTask.CategoryID = catID;
            standaloneTask.Status = 'InProgress';
            standaloneTask.Priority = 'Low';
            await RequireSave(standaloneTask, 'TSH1 standaloneTask');

            // Create 3 TimeApprover rules: Alex on Project 1, Marcus on Project 2, Elena as Sarah's worker approver
            const createdRules: mjBizAppsTasksTimeApproverEntity[] = [];
            const addRule = async (fields: {
                ApproverPersonID: string;
                ScopeTaskID?: string;
                WorkerPersonID?: string;
            }) => {
                const r = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimeApproverEntity>(
                    TIME_APPROVER_ENTITY,
                    ctx.User,
                );
                r.NewRecord();
                r.ApproverPersonID = fields.ApproverPersonID;
                if (fields.ScopeTaskID) r.ScopeTaskID = fields.ScopeTaskID;
                if (fields.WorkerPersonID) r.WorkerPersonID = fields.WorkerPersonID;
                r.IncludeDescendants = true;
                r.IsActive = true;
                await RequireSave(r, 'TSH1 addRule');
                createdRules.push(r);
            };
            await addRule({ ApproverPersonID: alex.ID, ScopeTaskID: p1RootID });
            await addRule({ ApproverPersonID: marcus.ID, ScopeTaskID: p2RootID });
            await addRule({ ApproverPersonID: elena.ID, WorkerPersonID: sarah.ID });

            const periodStart = '2025-03-03';
            const periodEnd = '2025-03-09';
            const entryIDs: string[] = [];
            let timesheetID: string | null = null;

            try {
                const logEntry = async (tID: string, day: string, mins: number) => {
                    const e = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                        TASK_TIME_ENTRY_ENTITY,
                        sarahUser,
                    );
                    e.NewRecord();
                    e.TaskID = tID;
                    e.PersonID = sarah.ID;
                    e.WorkDate = FromCalendarDay(day);
                    e.Minutes = mins;
                    e.IsBillable = true;
                    await RequireSave(e, 'TSH1 logEntry');
                    entryIDs.push(e.ID);
                    return e;
                };

                const e1 = await logEntry(p1SubID, '2025-03-03', 60);
                await logEntry(p2SubID, '2025-03-04', 120);
                await logEntry(standaloneTask.ID, '2025-03-05', 30);

                // Submit timesheet -> 3 parts
                const subRes = await new TasksSubmitTimesheetOperation().Execute(
                    {
                        PersonID: sarah.ID,
                        PeriodStart: periodStart,
                        PeriodEnd: periodEnd,
                    },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(subRes.Success && !!subRes.Output?.Success, `TSH1 submit: ${subRes.Output?.Message}`);
                timesheetID = subRes.Output!.TimesheetID!;
                const parts = subRes.Output!.Parts ?? [];
                AssertEqual(parts.length, 3, 'submitted 3 approval parts (2 projects + 1 worker scope)');
                AssertEqual(subRes.Output!.Status, 'Submitted', 'timesheet status is Submitted');
                AssertEqual(subRes.Output!.TotalMinutes, 210, 'total 210 minutes');

                // Verify R6 lock: creating, editing, or deleting an entry in [2025-03-03..2025-03-09] is refused
                const lockedEdit = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    sarahUser,
                );
                Assert(await lockedEdit.Load(e1.ID), 'load e1');
                lockedEdit.Minutes = 90;
                await RequireRefusal(() => lockedEdit.Save(), lockedEdit, 'TSH1 R6 edit in Submitted period', 'submitted');

                const lockedCreate = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    sarahUser,
                );
                lockedCreate.NewRecord();
                lockedCreate.TaskID = p1SubID;
                lockedCreate.PersonID = sarah.ID;
                lockedCreate.WorkDate = FromCalendarDay('2025-03-06');
                lockedCreate.Minutes = 30;
                await RequireRefusal(() => lockedCreate.Save(), lockedCreate, 'TSH1 R6 create in Submitted period', 'submitted');

                // Verify D13 self-decision refusal: Sarah tries to record a TaskDecision on Part 1's approval task
                const part1 = parts.find((p) => SameID(p.ScopeTaskID, p1RootID))!;
                const part2 = parts.find((p) => SameID(p.ScopeTaskID, p2RootID))!;
                const part3 = parts.find((p) => p.ScopeTaskID == null)!;
                Assert(!!part1 && !!part2 && !!part3, 'all 3 parts identified');

                const selfDecision = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskDecisionEntity>(
                    TASK_DECISION_ENTITY,
                    sarahUser,
                );
                selfDecision.NewRecord();
                selfDecision.TaskID = part1.ApprovalTaskID;
                selfDecision.OutcomeID = approvedOutcome.ID;
                selfDecision.DecidedByPersonID = sarah.ID;
                await RequireRefusal(
                    () => selfDecision.Save(),
                    selfDecision,
                    'TSH1 D13 self-approval refusal',
                    'assigned',
                );

                // Alex records decision on Part 1 and completes Part 1's approval task
                const alexDecision = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskDecisionEntity>(
                    TASK_DECISION_ENTITY,
                    alexUser,
                );
                alexDecision.NewRecord();
                alexDecision.TaskID = part1.ApprovalTaskID;
                alexDecision.OutcomeID = approvedOutcome.ID;
                alexDecision.DecidedByPersonID = alex.ID;
                alexDecision.DecisionNotes = 'Project 1 time approved';
                await RequireSave(alexDecision, 'TSH1 Alex decision on Part 1');

                const completeApprovalTask = async (taskID: string) => {
                    const t = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
                    Assert(await t.Load(taskID), `load approval task ${taskID}`);
                    t.Status = 'Completed';
                    await RequireSave(t, `complete approval task ${taskID}`);
                };

                await completeApprovalTask(part1.ApprovalTaskID);
                await completeApprovalTask(part2.ApprovalTaskID);

                // After 2 of 3 parts approved, timesheet is still Submitted
                const tsMid = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimesheetEntity>(
                    TIMESHEET_ENTITY,
                    ctx.User,
                );
                Assert(await tsMid.Load(timesheetID), 'load timesheet mid-approval');
                AssertEqual(tsMid.Status, 'Submitted', 'timesheet stays Submitted until last part is approved');

                // Approve Part 3 -> timesheet turns Approved
                await completeApprovalTask(part3.ApprovalTaskID);
                const tsFinal = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimesheetEntity>(
                    TIMESHEET_ENTITY,
                    ctx.User,
                );
                Assert(await tsFinal.Load(timesheetID), 'load timesheet after all 3 parts approved');
                AssertEqual(tsFinal.Status, 'Approved', 'timesheet is now Approved');
            } finally {
                await cleanupTimesheetTree(ctx, timesheetID, entryIDs);
                for (const r of createdRules) {
                    if (await r.Load(r.ID)) await r.Delete();
                }
                await DeleteTask(ctx, standaloneTask);
            }
        },
    },
    {
        Id: 'timesheets.TSH2',
        Name: 'TSH2 — rejecting one part returns the timesheet and cancels sibling pending parts; resubmit carries forward unchanged approved part or re-requests all under TimesheetResubmitReapprovesAll',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const sarah = world.People['sarah.connor@task-world.test'];
            const alex = world.People['alex.chen@task-world.test'];
            const marcus = world.People['marcus.vance@task-world.test'];
            const p1RootID = world.SeedTaskIDs['Website Redesign & Portal Launch'];
            const p1SubID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const p2RootID = world.SeedTaskIDs['Corporate HQ Campus Construction & Relocation'];
            const p2SubID = world.SeedTaskIDs['Architectural Blueprints & Structural Engineering'];
            const sarahUser = PersonaUser(ctx, sarah.ID, { canManage: false });

            const rule1 = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimeApproverEntity>(
                TIME_APPROVER_ENTITY,
                ctx.User,
            );
            rule1.NewRecord();
            rule1.ApproverPersonID = alex.ID;
            rule1.ScopeTaskID = p1RootID;
            rule1.IncludeDescendants = true;
            rule1.IsActive = true;
            await RequireSave(rule1, 'TSH2 rule1');

            const rule2 = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimeApproverEntity>(
                TIME_APPROVER_ENTITY,
                ctx.User,
            );
            rule2.NewRecord();
            rule2.ApproverPersonID = marcus.ID;
            rule2.ScopeTaskID = p2RootID;
            rule2.IncludeDescendants = true;
            rule2.IsActive = true;
            await RequireSave(rule2, 'TSH2 rule2');

            const periodStart = '2025-03-10';
            const periodEnd = '2025-03-16';
            const entryIDs: string[] = [];
            let timesheetID: string | null = null;

            try {
                const e1 = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    sarahUser,
                );
                e1.NewRecord();
                e1.TaskID = p1SubID;
                e1.PersonID = sarah.ID;
                e1.WorkDate = FromCalendarDay('2025-03-10');
                e1.Minutes = 60;
                e1.IsBillable = true;
                await RequireSave(e1, 'TSH2 e1');
                entryIDs.push(e1.ID);

                const e2 = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    sarahUser,
                );
                e2.NewRecord();
                e2.TaskID = p2SubID;
                e2.PersonID = sarah.ID;
                e2.WorkDate = FromCalendarDay('2025-03-11');
                e2.Minutes = 90;
                e2.IsBillable = true;
                await RequireSave(e2, 'TSH2 e2');
                entryIDs.push(e2.ID);

                // Round 1 submit
                const r1 = await new TasksSubmitTimesheetOperation().Execute(
                    { PersonID: sarah.ID, PeriodStart: periodStart, PeriodEnd: periodEnd },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(r1.Success && !!r1.Output?.Success, 'TSH2 Round 1 submit');
                timesheetID = r1.Output!.TimesheetID!;
                const r1Parts = r1.Output!.Parts ?? [];
                const r1P1 = r1Parts.find((p) => SameID(p.ScopeTaskID, p1RootID))!;
                const r1P2 = r1Parts.find((p) => SameID(p.ScopeTaskID, p2RootID))!;

                // Reject Part 2 while Part 1 is still Pending -> Part 1 is automatically Canceled and timesheet becomes Rejected
                const t2 = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
                Assert(await t2.Load(r1P2.ApprovalTaskID), 'load r1P2 task');
                t2.Status = 'Cancelled';
                await RequireSave(t2, 'reject r1P2 task');

                const p1AfterReject = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimesheetApprovalEntity>(
                    TIMESHEET_APPROVAL_ENTITY,
                    ctx.User,
                );
                Assert(await p1AfterReject.Load(r1P1.TimesheetApprovalID), 'load r1P1 after sibling reject');
                AssertEqual(p1AfterReject.Status, 'Canceled', 'sibling pending part automatically Canceled');

                const tsAfterReject = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimesheetEntity>(
                    TIMESHEET_ENTITY,
                    ctx.User,
                );
                Assert(await tsAfterReject.Load(timesheetID), 'load timesheet after reject');
                AssertEqual(tsAfterReject.Status, 'Rejected', 'timesheet status is Rejected');

                // Resubmit Round 2, approve Part 1, then reject Part 2 so Part 1 is Approved
                const r2 = await new TasksSubmitTimesheetOperation().Execute(
                    { TimesheetID: timesheetID },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(r2.Success && !!r2.Output?.Success, 'TSH2 Round 2 submit');
                const r2Parts = r2.Output!.Parts ?? [];
                const r2P1 = r2Parts.find((p) => SameID(p.ScopeTaskID, p1RootID))!;
                const r2P2 = r2Parts.find((p) => SameID(p.ScopeTaskID, p2RootID))!;

                const r2Task1 = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
                Assert(await r2Task1.Load(r2P1.ApprovalTaskID), 'load r2P1 task');
                r2Task1.Status = 'Completed';
                await RequireSave(r2Task1, 'approve r2P1');

                const r2Task2 = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
                Assert(await r2Task2.Load(r2P2.ApprovalTaskID), 'load r2P2 task');
                r2Task2.Status = 'Cancelled';
                await RequireSave(r2Task2, 'reject r2P2');

                // Edit e2 (Project 2) while leaving e1 (Project 1) unchanged
                const editE2 = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    sarahUser,
                );
                Assert(await editE2.Load(e2.ID), 'load e2 for correction');
                editE2.Minutes = 105;
                await RequireSave(editE2, 'update e2 to 105m');

                // Resubmit Round 3 (default TimesheetResubmitReapprovesAll = false):
                // Project 1 is carried forward as Approved; Project 2 gets a new Pending part
                const r3 = await new TasksSubmitTimesheetOperation().Execute(
                    { TimesheetID: timesheetID },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(r3.Success && !!r3.Output?.Success, 'TSH2 Round 3 submit');
                const r3Parts = r3.Output!.Parts ?? [];
                const r3P1 = r3Parts.find((p) => SameID(p.ScopeTaskID, p1RootID))!;
                const r3P2 = r3Parts.find((p) => SameID(p.ScopeTaskID, p2RootID))!;
                AssertEqual(r3P1.CarriedForward, true, 'unchanged Project 1 part carried forward');
                AssertEqual(r3P1.Status, 'Approved', 'carried-forward part remains Approved');
                AssertEqual(r3P2.CarriedForward, false, 'changed Project 2 part re-requested');
                AssertEqual(r3P2.Status, 'Pending', 'changed Project 2 part is Pending');

                // Withdraw Round 3 and resubmit with TimesheetResubmitReapprovesAll = true -> both parts Pending
                const wd = await new TasksWithdrawTimesheetOperation().Execute(
                    { TimesheetID: timesheetID, Reason: 'Test reapprove all' },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(wd.Success && !!wd.Output?.Success, 'withdraw Round 3');

                await WithTasksSetting(ctx, 'TimesheetResubmitReapprovesAll', 'true', async () => {
                    const r4 = await new TasksSubmitTimesheetOperation().Execute(
                        { TimesheetID: timesheetID! },
                        { user: sarahUser, provider: ctx.Provider },
                    );
                    Assert(r4.Success && !!r4.Output?.Success, 'TSH2 Round 4 submit with reapproveAll');
                    for (const part of r4.Output!.Parts ?? []) {
                        AssertEqual(part.CarriedForward, false, 'no part carried forward when reapproveAll is on');
                        AssertEqual(part.Status, 'Pending', 'every part is Pending');
                    }
                });
            } finally {
                await cleanupTimesheetTree(ctx, timesheetID, entryIDs);
                await rule2.Delete();
                await rule1.Delete();
            }
        },
    },
    {
        Id: 'timesheets.TSH3',
        Name: 'TSH3 — Withdraw returns Submitted timesheet to Draft; Reopen requires Manage Timesheets and a non-empty Reason and records TaskActivity',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const sarah = world.People['sarah.connor@task-world.test'];
            const alex = world.People['alex.chen@task-world.test'];
            const p1RootID = world.SeedTaskIDs['Website Redesign & Portal Launch'];
            const p1SubID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const sarahUser = PersonaUser(ctx, sarah.ID, { canManage: false });
            const managerUser = PersonaUser(ctx, alex.ID, { canManage: true });

            const rule = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimeApproverEntity>(
                TIME_APPROVER_ENTITY,
                ctx.User,
            );
            rule.NewRecord();
            rule.ApproverPersonID = alex.ID;
            rule.ScopeTaskID = p1RootID;
            rule.IncludeDescendants = true;
            rule.IsActive = true;
            await RequireSave(rule, 'TSH3 rule');

            const periodStart = '2025-03-17';
            const periodEnd = '2025-03-23';
            const entryIDs: string[] = [];
            let timesheetID: string | null = null;

            try {
                const entry = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    sarahUser,
                );
                entry.NewRecord();
                entry.TaskID = p1SubID;
                entry.PersonID = sarah.ID;
                entry.WorkDate = FromCalendarDay('2025-03-18');
                entry.Minutes = 60;
                await RequireSave(entry, 'TSH3 entry');
                entryIDs.push(entry.ID);

                // Submit -> Withdraw -> edit entry -> Resubmit -> Approve
                const sub1 = await new TasksSubmitTimesheetOperation().Execute(
                    { PersonID: sarah.ID, PeriodStart: periodStart, PeriodEnd: periodEnd },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(sub1.Success && !!sub1.Output?.Success, 'TSH3 submit 1');
                timesheetID = sub1.Output!.TimesheetID!;

                const wd = await new TasksWithdrawTimesheetOperation().Execute(
                    { TimesheetID: timesheetID, Reason: 'Forgot Friday hours' },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(wd.Success && !!wd.Output?.Success, 'TSH3 withdraw');
                AssertEqual(wd.Output!.Status, 'Draft', 'withdrawn to Draft');

                const sub2 = await new TasksSubmitTimesheetOperation().Execute(
                    { TimesheetID: timesheetID },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(sub2.Success && !!sub2.Output?.Success, 'TSH3 submit 2');
                const approvalTaskID = sub2.Output!.Parts![0].ApprovalTaskID;

                const appTask = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
                Assert(await appTask.Load(approvalTaskID), 'load approval task');
                appTask.Status = 'Completed';
                await RequireSave(appTask, 'approve timesheet');

                // 1. Non-manager (Sarah) is refused from reopening
                const unauthReopen = await new TasksReopenTimesheetOperation().Execute(
                    { TimesheetID: timesheetID, Reason: 'Want to edit' },
                    { user: sarahUser, provider: ctx.Provider },
                );
                AssertEqual(unauthReopen.Output?.Success, false, 'non-manager refused reopen');

                // 2. Manager without reason is refused
                const noReasonReopen = await new TasksReopenTimesheetOperation().Execute(
                    { TimesheetID: timesheetID, Reason: '   ' },
                    { user: managerUser, provider: ctx.Provider },
                );
                AssertEqual(noReasonReopen.Output?.Success, false, 'empty reason refused reopen');

                // 3. Manager with reason succeeds and writes TaskActivity
                const reopenRes = await new TasksReopenTimesheetOperation().Execute(
                    { TimesheetID: timesheetID, Reason: 'Adjusting billing rate classification' },
                    { user: managerUser, provider: ctx.Provider },
                );
                Assert(reopenRes.Success && !!reopenRes.Output?.Success, `TSH3 reopen: ${reopenRes.Output?.Message}`);
                AssertEqual(reopenRes.Output!.Status, 'Draft', 'reopened to Draft');

                const activities = await FindRows<{ ID: string; Description: string }>(
                    ctx,
                    TASK_ACTIVITY_ENTITY,
                    `TaskID = '${approvalTaskID}'`,
                    ['ID', 'Description'],
                );
                Assert(
                    activities.some((a) => (a.Description ?? '').includes('Timesheet reopened')),
                    'TaskActivity audit recorded on approval task',
                );
            } finally {
                await cleanupTimesheetTree(ctx, timesheetID, entryIDs);
                await rule.Delete();
            }
        },
    },
    {
        Id: 'timesheets.TSH4',
        Name: 'TSH4 — entry with no approver anywhere refuses submit; resolver-supplied scope (TaskLinkScopeApproverResolver) resolves approvers in chain order',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const david = world.People['david.miller@task-world.test'];
            const robert = world.People['robert.hayes@task-world.test'];
            const generalType = world.TaskTypes['GENERAL'] ?? Object.values(world.TaskTypes)[0];
            const cat = world.Categories['Engineering & Development'];
            const catEntity = ctx.Provider.Entities.find((e) => e.Name === TASK_CATEGORY_ENTITY)!;
            const davidUser = PersonaUser(ctx, david.ID, { canManage: false });

            // Create a standalone root task with no task approver
            const orphanTask = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            orphanTask.NewRecord();
            orphanTask.Name = `TSH4 Unassigned Root Task ${Date.now()}`;
            orphanTask.TypeID = generalType.ID;
            orphanTask.CategoryID = cat.ID;
            orphanTask.Status = 'InProgress';
            orphanTask.Priority = 'Medium';
            await RequireSave(orphanTask, 'TSH4 orphanTask');

            const periodStart = '2025-03-24';
            const periodEnd = '2025-03-30';
            const entryIDs: string[] = [];
            let timesheetID: string | null = null;
            let taskLink: mjBizAppsTasksTaskLinkEntity | null = null;
            let scopeRule: mjBizAppsTasksTimeApproverEntity | null = null;

            try {
                const entry = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    davidUser,
                );
                entry.NewRecord();
                entry.TaskID = orphanTask.ID;
                entry.PersonID = david.ID;
                entry.WorkDate = FromCalendarDay('2025-03-25');
                entry.Minutes = 45;
                await RequireSave(entry, 'TSH4 entry');
                entryIDs.push(entry.ID);

                // 1. Submit with no approver anywhere -> refused
                const refusedSubmit = await new TasksSubmitTimesheetOperation().Execute(
                    { PersonID: david.ID, PeriodStart: periodStart, PeriodEnd: periodEnd },
                    { user: davidUser, provider: ctx.Provider },
                );
                AssertEqual(refusedSubmit.Output?.Success, false, 'submit refused when no approver exists');
                Assert(
                    (refusedSubmit.Output?.Message ?? '').toLowerCase().includes('no approver for time'),
                    `expected 'no approver for time' refusal, got: ${refusedSubmit.Output?.Message}`,
                );

                // 2. Link orphanTask to Category record via TaskLink and add a polymorphic TimeApprover rule on that Category record
                taskLink = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskLinkEntity>(
                    TASK_LINK_ENTITY,
                    ctx.User,
                );
                taskLink.NewRecord();
                taskLink.TaskID = orphanTask.ID;
                taskLink.EntityID = catEntity.ID;
                taskLink.RecordID = cat.ID;
                taskLink.Description = 'Engineering Scope Container';
                await RequireSave(taskLink, 'TSH4 taskLink');

                scopeRule = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimeApproverEntity>(
                    TIME_APPROVER_ENTITY,
                    ctx.User,
                );
                scopeRule.NewRecord();
                scopeRule.ApproverPersonID = robert.ID;
                scopeRule.ScopeEntityID = catEntity.ID;
                scopeRule.ScopeRecordID = cat.ID;
                scopeRule.IncludeDescendants = true;
                scopeRule.IsActive = true;
                await RequireSave(scopeRule, 'TSH4 scopeRule');

                // Submit now succeeds via TaskLinkScopeApproverResolver -> Robert is assigned
                const okSubmit = await new TasksSubmitTimesheetOperation().Execute(
                    { PersonID: david.ID, PeriodStart: periodStart, PeriodEnd: periodEnd },
                    { user: davidUser, provider: ctx.Provider },
                );
                Assert(okSubmit.Success && !!okSubmit.Output?.Success, `TSH4 submit via resolver: ${okSubmit.Output?.Message}`);
                timesheetID = okSubmit.Output!.TimesheetID!;
                AssertEqual(okSubmit.Output!.Parts?.length, 1, '1 part created');
                Assert(
                    SameID(okSubmit.Output!.Parts![0].ApproverPersonIDs[0], robert.ID),
                    'Robert resolved as approver via TaskLinkScopeApproverResolver',
                );
            } finally {
                await cleanupTimesheetTree(ctx, timesheetID, entryIDs);
                if (scopeRule && (await scopeRule.Load(scopeRule.ID))) await scopeRule.Delete();
                if (taskLink && (await taskLink.Load(taskLink.ID))) await taskLink.Delete();
                await DeleteTask(ctx, orphanTask);
            }
        },
    },
    {
        Id: 'timesheets.TSH5',
        Name: 'TSH5 — person-specific TimesheetSchedule resolves SemiMonthly period dates, and ReconcileStaleTimesheetApprovals repairs a stale Pending part',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const maya = world.People['maya.lin@task-world.test'];
            const alex = world.People['alex.chen@task-world.test'];
            const p1RootID = world.SeedTaskIDs['Website Redesign & Portal Launch'];
            const p1SubID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const mayaUser = PersonaUser(ctx, maya.ID, { canManage: false });

            const rule = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimeApproverEntity>(
                TIME_APPROVER_ENTITY,
                ctx.User,
            );
            rule.NewRecord();
            rule.ApproverPersonID = alex.ID;
            rule.ScopeTaskID = p1RootID;
            rule.IncludeDescendants = true;
            rule.IsActive = true;
            await RequireSave(rule, 'TSH5 rule');

            const schedule = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimesheetScheduleEntity>(
                TIMESHEET_SCHEDULE_ENTITY,
                ctx.User,
            );
            schedule.NewRecord();
            schedule.PersonID = maya.ID;
            schedule.Cadence = 'SemiMonthly';
            schedule.WeekStartDay = 'Monday';
            schedule.EffectiveFrom = FromCalendarDay('2025-01-01');
            await RequireSave(schedule, 'TSH5 SemiMonthly schedule for Maya');

            const entryIDs: string[] = [];
            let timesheetID: string | null = null;

            try {
                const entry = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    mayaUser,
                );
                entry.NewRecord();
                entry.TaskID = p1SubID;
                entry.PersonID = maya.ID;
                entry.WorkDate = FromCalendarDay('2025-04-05');
                entry.Minutes = 90;
                await RequireSave(entry, 'TSH5 entry');
                entryIDs.push(entry.ID);

                // Submit with only PeriodStart = '2025-04-01' -> SemiMonthly schedule derives PeriodEnd = '2025-04-15'
                const subRes = await new TasksSubmitTimesheetOperation().Execute(
                    { PersonID: maya.ID, PeriodStart: '2025-04-01' },
                    { user: mayaUser, provider: ctx.Provider },
                );
                Assert(subRes.Success && !!subRes.Output?.Success, `TSH5 SemiMonthly submit: ${subRes.Output?.Message}`);
                timesheetID = subRes.Output!.TimesheetID!;

                const ts = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimesheetEntity>(
                    TIMESHEET_ENTITY,
                    ctx.User,
                );
                Assert(await ts.Load(timesheetID), 'load Maya timesheet');
                const endStr = ts.PeriodEnd instanceof Date ? ts.PeriodEnd.toISOString().slice(0, 10) : String(ts.PeriodEnd).slice(0, 10);
                AssertEqual(endStr, '2025-04-15', 'SemiMonthly first-half period ends on 2025-04-15');

                // Simulate a stale Pending part whose approval task is already Completed
                const partID = subRes.Output!.Parts![0].TimesheetApprovalID;
                const approvalTaskID = subRes.Output!.Parts![0].ApprovalTaskID;

                const appTask = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
                Assert(await appTask.Load(approvalTaskID), 'load approval task');
                appTask.Status = 'Completed';
                await RequireSave(appTask, 'complete approval task');

                // Force part back to Pending and timesheet back to Submitted to simulate a missed outcome write
                const staleTs = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimesheetEntity>(
                    TIMESHEET_ENTITY,
                    ctx.User,
                );
                Assert(await staleTs.Load(timesheetID), 'load timesheet');
                staleTs.Status = 'Submitted';
                await RequireSave(staleTs, 'set timesheet to Submitted');

                const stalePart = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimesheetApprovalEntity>(
                    TIMESHEET_APPROVAL_ENTITY,
                    ctx.User,
                );
                Assert(await stalePart.Load(partID), 'load part');
                stalePart.Status = 'Pending';
                await RequireSave(stalePart, 'set part to stale Pending');

                // Run ReconcileStaleTimesheetApprovals sweep
                const sweepSummary = await ReconcileStaleTimesheetApprovals(
                    ctx.User,
                    200,
                    ctx.Provider,
                    ctx.Provider as unknown as IRunViewProvider,
                );
                Assert(sweepSummary.RepairedCount >= 1, 'sweep repaired at least 1 stale part');
                Assert(
                    sweepSummary.RepairedPartIDs.some((id) => SameID(id, partID)),
                    'sweep repaired our stale part',
                );

                const repairedTs = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimesheetEntity>(
                    TIMESHEET_ENTITY,
                    ctx.User,
                );
                Assert(await repairedTs.Load(timesheetID), 'reload repaired timesheet');
                AssertEqual(repairedTs.Status, 'Approved', 'sweep promoted timesheet to Approved');
            } finally {
                await cleanupTimesheetTree(ctx, timesheetID, entryIDs);
                await schedule.Delete();
                await rule.Delete();
            }
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('timesheets', { Setup: async () => {}, Teardown: async () => {} });
