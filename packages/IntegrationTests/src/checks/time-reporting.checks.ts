import { RunQuery, type IRunQueryProvider } from '@memberjunction/core';
import {
    MJAIAgentEntity,
    MJAIAgentRunEntity,
} from '@memberjunction/core-entities';
import {
    Assert,
    AssertEqual,
    IntegrationCheckRegistry,
    type NamedCheck,
} from '@memberjunction/testing-integration/registry';
import { AddDays, FromCalendarDay, ToCalendarDay } from '@mj-biz-apps/common-entities';
import {
    TaskEntity,
    TasksSubmitTimesheetOperation,
    mjBizAppsTasksTaskAgentRunEntity,
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTaskLinkEntity,
    mjBizAppsTasksTaskTimeEntryEntity,
    mjBizAppsTasksTimeApproverEntity,
    mjBizAppsTasksTimesheetApprovalEntity,
    mjBizAppsTasksTimesheetEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    AI_AGENT_ENTITY,
    AI_AGENT_RUN_ENTITY,
    PERSON_ENTITY,
    TASK_AGENT_RUN_ENTITY,
    TASK_ASSIGNMENT_ENTITY,
    TASK_ENTITY,
    TASK_LINK_ENTITY,
    TASK_TIME_ENTRY_ENTITY,
    TIMESHEET_APPROVAL_ENTITY,
    TIMESHEET_ENTITY,
    TIME_APPROVER_ENTITY,
} from '../entity-names.js';
import {
    DeleteTask,
    FindRows,
    PersonaUser,
    RequireSave,
    SameID,
} from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

function queryRunner(ctx: Parameters<NamedCheck['Fn']>[0]): RunQuery {
    return new RunQuery(ctx.Provider as unknown as IRunQueryProvider);
}

const checks: NamedCheck[] = [
    {
        Id: 'time-reporting.TR1',
        Name: 'TR1 — Query 1 (Time Logged by Person and Period) and Query 2 (Task Effort vs Estimate Rollup) return exact totals',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const sarah = world.People['sarah.connor@task-world.test'];
            const generalType = world.TaskTypes['GENERAL'] ?? Object.values(world.TaskTypes)[0];
            const catID = world.Categories['Engineering & Development'].ID;
            const workDay = AddDays(ToCalendarDay(new Date())!, -4);

            const rootTask = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            rootTask.NewRecord();
            rootTask.Name = `TR1 Reporting Root ${Date.now()}`;
            rootTask.TypeID = generalType.ID;
            rootTask.CategoryID = catID;
            rootTask.Status = 'InProgress';
            rootTask.Priority = 'High';
            rootTask.HoursEstimated = 2; // 120 minutes
            await RequireSave(rootTask, 'TR1 rootTask');

            const subTask = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            subTask.NewRecord();
            subTask.Name = `TR1 Reporting Subtask ${Date.now()}`;
            subTask.ParentID = rootTask.ID;
            subTask.TypeID = generalType.ID;
            subTask.CategoryID = catID;
            subTask.Status = 'InProgress';
            subTask.Priority = 'Medium';
            await RequireSave(subTask, 'TR1 subTask');

            const e1 = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                TASK_TIME_ENTRY_ENTITY,
                ctx.User,
            );
            e1.NewRecord();
            e1.TaskID = rootTask.ID;
            e1.PersonID = sarah.ID;
            e1.WorkDate = FromCalendarDay(workDay);
            e1.Minutes = 90;
            e1.IsBillable = true;
            await RequireSave(e1, 'TR1 entry 1');

            const e2 = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                TASK_TIME_ENTRY_ENTITY,
                ctx.User,
            );
            e2.NewRecord();
            e2.TaskID = subTask.ID;
            e2.PersonID = sarah.ID;
            e2.WorkDate = FromCalendarDay(workDay);
            e2.Minutes = 60;
            e2.IsBillable = false;
            await RequireSave(e2, 'TR1 entry 2');

            try {
                // Query 1: Time Logged by Person and Period
                const q1Res = await queryRunner(ctx).RunQuery(
                    {
                        QueryName: 'Time Logged by Person and Period',
                        Parameters: {
                            StartDate: workDay,
                            EndDate: workDay,
                            PersonID: sarah.ID,
                        },
                    },
                    ctx.User,
                );
                Assert(q1Res.Success, `Query 1 succeeded: ${q1Res.ErrorMessage}`);
                const q1Rows = (q1Res.Results ?? []) as Array<{
                    PersonID: string;
                    TotalMinutes: number;
                    BillableMinutes: number;
                    NonBillableMinutes: number;
                }>;
                Assert(q1Rows.length >= 1, 'Query 1 returned Sarah row');
                const sarahRow = q1Rows.find((r) => SameID(r.PersonID, sarah.ID))!;
                Assert(Number(sarahRow.TotalMinutes) >= 150, 'TotalMinutes >= 150');
                Assert(Number(sarahRow.BillableMinutes) >= 90, 'BillableMinutes >= 90');
                Assert(Number(sarahRow.NonBillableMinutes) >= 60, 'NonBillableMinutes >= 60');

                // Query 2: Task Effort vs Estimate Rollup
                const q2Res = await queryRunner(ctx).RunQuery(
                    {
                        QueryName: 'Task Effort vs Estimate Rollup',
                        Parameters: {
                            RootTaskID: rootTask.ID,
                            OnlyOverEstimate: 'true',
                        },
                    },
                    ctx.User,
                );
                Assert(q2Res.Success, `Query 2 succeeded: ${q2Res.ErrorMessage}`);
                const q2Rows = (q2Res.Results ?? []) as Array<{
                    RootTaskID: string;
                    EstimatedMinutes: number;
                    RolledUpLoggedMinutes: number;
                    VarianceMinutes: number;
                }>;
                AssertEqual(q2Rows.length, 1, 'Query 2 returned rootTask');
                AssertEqual(Number(q2Rows[0].EstimatedMinutes), 120, 'EstimatedMinutes = 120');
                AssertEqual(Number(q2Rows[0].RolledUpLoggedMinutes), 150, 'RolledUpLoggedMinutes = 150');
                AssertEqual(Number(q2Rows[0].VarianceMinutes), 30, 'VarianceMinutes = +30');
            } finally {
                await e2.Delete();
                await e1.Delete();
                await DeleteTask(ctx, subTask);
                await DeleteTask(ctx, rootTask);
            }
        },
    },
    {
        Id: 'time-reporting.TR2',
        Name: 'TR2 — Query 3 (Agent Effort and Cost by Task) and Query 5 (Logged Time by Linked Record) return accurate totals',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const sarah = world.People['sarah.connor@task-world.test'];
            const generalType = world.TaskTypes['GENERAL'] ?? Object.values(world.TaskTypes)[0];
            const catID = world.Categories['Engineering & Development'].ID;
            const workDay = AddDays(ToCalendarDay(new Date())!, -3);
            const peopleEntity = ctx.Provider.Entities.find((e) => e.Name === PERSON_ENTITY)!;

            // Ensure test AI Agent exists
            const existingAgents = await FindRows<{ ID: string }>(
                ctx,
                AI_AGENT_ENTITY,
                "Name = 'Tasks Integration Test Agent'",
                ['ID'],
            );
            let agentID = existingAgents[0]?.ID;
            if (!agentID) {
                const agentTypes = await FindRows<{ ID: string }>(ctx, 'MJ: AI Agent Types', '', ['ID']);
                const agent = await ctx.Provider.GetEntityObject<MJAIAgentEntity>(AI_AGENT_ENTITY, ctx.User);
                agent.NewRecord();
                agent.Name = 'Tasks Integration Test Agent';
                agent.Status = 'Active';
                if (agentTypes[0]?.ID) agent.TypeID = agentTypes[0].ID;
                await RequireSave(agent, 'TR2 agent');
                agentID = agent.ID;
            }

            const rootTask = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            rootTask.NewRecord();
            rootTask.Name = `TR2 Linked Project ${Date.now()}`;
            rootTask.TypeID = generalType.ID;
            rootTask.CategoryID = catID;
            rootTask.Status = 'InProgress';
            rootTask.Priority = 'High';
            await RequireSave(rootTask, 'TR2 rootTask');

            // Link rootTask to Sarah's Person record via TaskLink
            const taskLink = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskLinkEntity>(
                TASK_LINK_ENTITY,
                ctx.User,
            );
            taskLink.NewRecord();
            taskLink.TaskID = rootTask.ID;
            taskLink.EntityID = peopleEntity.ID;
            taskLink.RecordID = sarah.ID;
            taskLink.Description = 'TR2 External Record Link';
            await RequireSave(taskLink, 'TR2 taskLink');

            // Seed time entry (75m billable) + AI Agent Run (2000 tokens, $0.05, 90s)
            const entry = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                TASK_TIME_ENTRY_ENTITY,
                ctx.User,
            );
            entry.NewRecord();
            entry.TaskID = rootTask.ID;
            entry.PersonID = sarah.ID;
            entry.WorkDate = FromCalendarDay(workDay);
            entry.Minutes = 75;
            entry.IsBillable = true;
            await RequireSave(entry, 'TR2 entry');

            const run = await ctx.Provider.GetEntityObject<MJAIAgentRunEntity>(AI_AGENT_RUN_ENTITY, ctx.User);
            run.NewRecord();
            run.AgentID = agentID;
            run.UserID = ctx.User.ID;
            run.Status = 'Completed';
            run.StartedAt = new Date('2026-03-12T14:00:00.000Z');
            run.CompletedAt = new Date('2026-03-12T14:01:30.000Z');
            run.TotalTokensUsed = 2000;
            run.TotalCost = 0.05;
            await RequireSave(run, 'TR2 run');

            const runLink = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskAgentRunEntity>(
                TASK_AGENT_RUN_ENTITY,
                ctx.User,
            );
            runLink.NewRecord();
            runLink.TaskID = rootTask.ID;
            runLink.AIAgentRunID = run.ID;
            runLink.Role = 'Executed';
            await RequireSave(runLink, 'TR2 runLink');

            try {
                // Query 3: Agent Effort and Cost by Task
                const q3Res = await queryRunner(ctx).RunQuery(
                    {
                        QueryName: 'Agent Effort and Cost by Task',
                        Parameters: { RootTaskID: rootTask.ID },
                    },
                    ctx.User,
                );
                Assert(q3Res.Success, `Query 3 succeeded: ${q3Res.ErrorMessage}`);
                const q3Rows = (q3Res.Results ?? []) as Array<{
                    TaskID: string;
                    CountedAgentRunCount: number;
                    WallClockSeconds: number;
                    TotalTokensUsed: number;
                    TotalCost: number;
                }>;
                AssertEqual(q3Rows.length, 1, 'Query 3 returned 1 row');
                AssertEqual(Number(q3Rows[0].CountedAgentRunCount), 1, 'CountedAgentRunCount = 1');
                AssertEqual(Number(q3Rows[0].WallClockSeconds), 90, 'WallClockSeconds = 90');
                AssertEqual(Number(q3Rows[0].TotalTokensUsed), 2000, 'TotalTokensUsed = 2000');
                AssertEqual(Number(Number(q3Rows[0].TotalCost).toFixed(2)), 0.05, 'TotalCost = 0.05');

                // Query 5: Logged Time by Linked Record
                const q5Res = await queryRunner(ctx).RunQuery(
                    {
                        QueryName: 'Logged Time by Linked Record',
                        Parameters: {
                            EntityName: PERSON_ENTITY,
                            RecordID: sarah.ID,
                            StartDate: workDay,
                            EndDate: workDay,
                        },
                    },
                    ctx.User,
                );
                Assert(q5Res.Success, `Query 5 succeeded: ${q5Res.ErrorMessage}`);
                const q5Rows = (q5Res.Results ?? []) as Array<{
                    RecordID: string;
                    TotalMinutes: number;
                    BillableMinutes: number;
                    AgentRunCount: number;
                    AgentTotalCost: number;
                }>;
                Assert(q5Rows.length >= 1, 'Query 5 returned linked record row');
                const linkedRow = q5Rows.find((r) => SameID(r.RecordID, sarah.ID))!;
                Assert(Number(linkedRow.TotalMinutes) >= 75, 'TotalMinutes >= 75');
                Assert(Number(linkedRow.BillableMinutes) >= 75, 'BillableMinutes >= 75');
                Assert(Number(linkedRow.AgentRunCount) >= 1, 'AgentRunCount >= 1');
            } finally {
                await runLink.Delete();
                await run.Delete();
                await entry.Delete();
                await taskLink.Delete();
                await DeleteTask(ctx, rootTask);
            }
        },
    },
    {
        Id: 'time-reporting.TR3',
        Name: 'TR3 — Query 4 (Timesheet Approval Status Summary) reports submitted timesheet and pending part counts',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const sarah = world.People['sarah.connor@task-world.test'];
            const alex = world.People['alex.chen@task-world.test'];
            const p1RootID = world.SeedTaskIDs['Website Redesign & Portal Launch'];
            const subTaskID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const sarahUser = PersonaUser(ctx, sarah.ID, { canManage: false });

            // Configure Alex as time approver on p1RootID
            const approverRule = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimeApproverEntity>(
                TIME_APPROVER_ENTITY,
                ctx.User,
            );
            approverRule.NewRecord();
            approverRule.ApproverPersonID = alex.ID;
            approverRule.ScopeTaskID = p1RootID;
            approverRule.IncludeDescendants = true;
            approverRule.IsActive = true;
            await RequireSave(approverRule, 'TR3 approver rule');

            const periodStart = '2025-02-03';
            const periodEnd = '2025-02-09';

            const entry = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                TASK_TIME_ENTRY_ENTITY,
                sarahUser,
            );
            entry.NewRecord();
            entry.TaskID = subTaskID;
            entry.PersonID = sarah.ID;
            entry.WorkDate = FromCalendarDay(periodStart);
            entry.Minutes = 120;
            entry.IsBillable = true;
            await RequireSave(entry, 'TR3 entry');

            let timesheetID: string | null = null;
            try {
                const subRes = await new TasksSubmitTimesheetOperation().Execute(
                    {
                        PersonID: sarah.ID,
                        PeriodStart: periodStart,
                        PeriodEnd: periodEnd,
                    },
                    { user: sarahUser, provider: ctx.Provider },
                );
                Assert(subRes.Success && !!subRes.Output?.Success, `TR3 submit: ${subRes.Output?.Message}`);
                timesheetID = subRes.Output!.TimesheetID!;

                const q4Res = await queryRunner(ctx).RunQuery(
                    {
                        QueryName: 'Timesheet Approval Status Summary',
                        Parameters: {
                            PeriodStart: periodStart,
                            PeriodEnd: periodEnd,
                            Status: 'Submitted',
                            ApproverPersonID: alex.ID,
                        },
                    },
                    ctx.User,
                );
                Assert(q4Res.Success, `Query 4 succeeded: ${q4Res.ErrorMessage}`);
                const q4Rows = (q4Res.Results ?? []) as Array<{
                    TimesheetID: string;
                    TotalMinutes: number;
                    TotalParts: number;
                    PendingParts: number;
                }>;
                const tsRow = q4Rows.find((r) => SameID(r.TimesheetID, timesheetID));
                Assert(!!tsRow, 'Query 4 returned submitted timesheet for approver Alex');
                AssertEqual(Number(tsRow!.TotalMinutes), 120, 'TotalMinutes = 120');
                AssertEqual(Number(tsRow!.TotalParts), 1, 'TotalParts = 1');
                AssertEqual(Number(tsRow!.PendingParts), 1, 'PendingParts = 1');
            } finally {
                if (timesheetID) {
                    const ts = await ctx.Provider.GetEntityObject<mjBizAppsTasksTimesheetEntity>(
                        TIMESHEET_ENTITY,
                        ctx.User,
                    );
                    if (await ts.Load(timesheetID)) {
                        ts.Status = 'Draft';
                        await ts.Save();
                    }
                    if (await entry.Load(entry.ID)) {
                        entry.TimesheetID = null;
                        await entry.Save();
                        await entry.Delete();
                    }
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
                            const t = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
                            if (await t.Load(p.ApprovalTaskID)) await DeleteTask(ctx, t);
                        }
                    }
                    if (await ts.Load(timesheetID)) {
                        await ts.Delete();
                    }
                } else if (await entry.Load(entry.ID)) {
                    await entry.Delete();
                }
                await approverRule.Delete();
            }
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('time-reporting', { Setup: async () => {}, Teardown: async () => {} });
