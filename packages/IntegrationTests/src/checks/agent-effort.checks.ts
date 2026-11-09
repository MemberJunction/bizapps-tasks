import {
    MJActionEntity,
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
import { LinkAgentRunToTaskAction } from '@mj-biz-apps/tasks-actions';
import {
    TaskEntity,
    TasksGetTaskEffortOperation,
    mjBizAppsTasksTaskAgentRunEntity,
    mjBizAppsTasksTaskTimeEntryEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    ACTION_ENTITY,
    AI_AGENT_ENTITY,
    AI_AGENT_RUN_ENTITY,
    TASK_AGENT_RUN_ENTITY,
    TASK_ENTITY,
    TASK_TIME_ENTRY_ENTITY,
} from '../entity-names.js';
import {
    DeleteTask,
    FindRows,
    RequireSave,
    SameID,
} from '../wire.js';
import { GetOrLoadWorld } from '../world/load-world.js';

async function getOrCreateTestAgent(ctx: Parameters<NamedCheck['Fn']>[0]): Promise<{ ID: string; Created: boolean }> {
    const existing = await FindRows<{ ID: string }>(
        ctx,
        AI_AGENT_ENTITY,
        "Name = 'Tasks Integration Test Agent'",
        ['ID'],
    );
    if (existing.length > 0) {
        return { ID: existing[0].ID, Created: false };
    }
    const agentTypes = await FindRows<{ ID: string }>(ctx, 'MJ: AI Agent Types', '', ['ID']);
    const agent = await ctx.Provider.GetEntityObject<MJAIAgentEntity>(AI_AGENT_ENTITY, ctx.User);
    agent.NewRecord();
    agent.Name = 'Tasks Integration Test Agent';
    agent.Description = 'Synthetic agent for Tasks integration checks';
    agent.Status = 'Active';
    if (agentTypes[0]?.ID) {
        agent.TypeID = agentTypes[0].ID;
    }
    await RequireSave(agent, 'seed test AI Agent');
    return { ID: agent.ID, Created: true };
}

async function createAgentRun(
    ctx: Parameters<NamedCheck['Fn']>[0],
    agentID: string,
    fields: {
        ParentRunID?: string | null;
        StartedAt: Date;
        CompletedAt: Date;
        TotalTokensUsed: number;
        TotalTokensUsedRollup?: number | null;
        TotalCost: number;
        TotalCostRollup?: number | null;
    },
): Promise<MJAIAgentRunEntity> {
    const run = await ctx.Provider.GetEntityObject<MJAIAgentRunEntity>(AI_AGENT_RUN_ENTITY, ctx.User);
    run.NewRecord();
    run.AgentID = agentID;
    run.UserID = ctx.User.ID;
    run.Status = 'Completed';
    run.StartedAt = fields.StartedAt;
    run.CompletedAt = fields.CompletedAt;
    if (fields.ParentRunID) {
        run.ParentRunID = fields.ParentRunID;
    }
    run.TotalTokensUsed = fields.TotalTokensUsed;
    if (fields.TotalTokensUsedRollup !== undefined) {
        run.TotalTokensUsedRollup = fields.TotalTokensUsedRollup;
    }
    run.TotalCost = fields.TotalCost;
    if (fields.TotalCostRollup !== undefined) {
        run.TotalCostRollup = fields.TotalCostRollup;
    }
    await RequireSave(run, 'create AI Agent Run');
    return run;
}

const checks: NamedCheck[] = [
    {
        Id: 'agent-effort.AE1',
        Name: 'AE1 — linking a child run then its parent run replaces the child link; linking a second child is a no-op (A2, D7)',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const generalType = world.TaskTypes['GENERAL'] ?? Object.values(world.TaskTypes)[0];
            const catID = world.Categories['Engineering & Development'].ID;
            const { ID: agentID } = await getOrCreateTestAgent(ctx);

            const task = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            task.NewRecord();
            task.Name = `AE1 Normalization Task ${Date.now()}`;
            task.TypeID = generalType.ID;
            task.CategoryID = catID;
            task.Status = 'InProgress';
            task.Priority = 'Medium';
            await RequireSave(task, 'AE1 task');

            const parentRun = await createAgentRun(ctx, agentID, {
                StartedAt: new Date('2026-03-10T10:00:00.000Z'),
                CompletedAt: new Date('2026-03-10T10:02:00.000Z'),
                TotalTokensUsed: 1000,
                TotalTokensUsedRollup: 3500,
                TotalCost: 0.02,
                TotalCostRollup: 0.07,
            });
            const childRun1 = await createAgentRun(ctx, agentID, {
                ParentRunID: parentRun.ID,
                StartedAt: new Date('2026-03-10T10:00:15.000Z'),
                CompletedAt: new Date('2026-03-10T10:01:00.000Z'),
                TotalTokensUsed: 1200,
                TotalCost: 0.025,
            });
            const childRun2 = await createAgentRun(ctx, agentID, {
                ParentRunID: parentRun.ID,
                StartedAt: new Date('2026-03-10T10:01:05.000Z'),
                CompletedAt: new Date('2026-03-10T10:01:55.000Z'),
                TotalTokensUsed: 1300,
                TotalCost: 0.025,
            });

            try {
                // 1. Link childRun1 first
                const linkChild1 = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskAgentRunEntity>(
                    TASK_AGENT_RUN_ENTITY,
                    ctx.User,
                );
                linkChild1.NewRecord();
                linkChild1.TaskID = task.ID;
                linkChild1.AIAgentRunID = childRun1.ID;
                linkChild1.Role = 'Executed';
                await RequireSave(linkChild1, 'AE1 link childRun1');

                let links = await FindRows<{ ID: string; AIAgentRunID: string }>(
                    ctx,
                    TASK_AGENT_RUN_ENTITY,
                    `TaskID = '${task.ID}'`,
                    ['ID', 'AIAgentRunID'],
                );
                AssertEqual(links.length, 1, '1 link after childRun1');
                Assert(SameID(links[0].AIAgentRunID, childRun1.ID), 'childRun1 is linked');

                // 2. Link parentRun -> replaces childRun1 on the same task
                const linkParent = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskAgentRunEntity>(
                    TASK_AGENT_RUN_ENTITY,
                    ctx.User,
                );
                linkParent.NewRecord();
                linkParent.TaskID = task.ID;
                linkParent.AIAgentRunID = parentRun.ID;
                linkParent.Role = 'Executed';
                await RequireSave(linkParent, 'AE1 link parentRun');

                links = await FindRows<{ ID: string; AIAgentRunID: string }>(
                    ctx,
                    TASK_AGENT_RUN_ENTITY,
                    `TaskID = '${task.ID}'`,
                    ['ID', 'AIAgentRunID'],
                );
                AssertEqual(links.length, 1, 'still 1 link after parentRun replaces childRun1');
                Assert(SameID(links[0].AIAgentRunID, parentRun.ID), 'parentRun replaced childRun1');

                // 3. Link childRun2 while parentRun is already linked -> no-op, keeps parentRun only
                const linkChild2 = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskAgentRunEntity>(
                    TASK_AGENT_RUN_ENTITY,
                    ctx.User,
                );
                linkChild2.NewRecord();
                linkChild2.TaskID = task.ID;
                linkChild2.AIAgentRunID = childRun2.ID;
                linkChild2.Role = 'Assisted';
                await RequireSave(linkChild2, 'AE1 link childRun2 covered by parentRun');

                links = await FindRows<{ ID: string; AIAgentRunID: string }>(
                    ctx,
                    TASK_AGENT_RUN_ENTITY,
                    `TaskID = '${task.ID}'`,
                    ['ID', 'AIAgentRunID'],
                );
                AssertEqual(links.length, 1, 'still 1 link after childRun2 no-op');
                Assert(SameID(links[0].AIAgentRunID, parentRun.ID), 'parentRun remains sole link');
            } finally {
                const remainingLinks = await FindRows<{ ID: string }>(
                    ctx,
                    TASK_AGENT_RUN_ENTITY,
                    `TaskID = '${task.ID}'`,
                    ['ID'],
                );
                for (const row of remainingLinks) {
                    const l = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskAgentRunEntity>(
                        TASK_AGENT_RUN_ENTITY,
                        ctx.User,
                    );
                    if (await l.Load(row.ID)) await l.Delete();
                }
                await childRun2.Delete();
                await childRun1.Delete();
                await parentRun.Delete();
                await DeleteTask(ctx, task);
            }
        },
    },
    {
        Id: 'agent-effort.AE2',
        Name: 'AE2 — vwTasks and Tasks.GetTaskEffort totals match hand-computed values, deduplicating nested and shared runs across a task tree',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const sarah = world.People['sarah.connor@task-world.test'];
            const generalType = world.TaskTypes['GENERAL'] ?? Object.values(world.TaskTypes)[0];
            const catID = world.Categories['Engineering & Development'].ID;
            const workDay = AddDays(ToCalendarDay(new Date())!, -2);
            const { ID: agentID } = await getOrCreateTestAgent(ctx);

            // Create root task (HoursEstimated = 2 -> 120 minutes) and two subtasks
            const rootTask = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            rootTask.NewRecord();
            rootTask.Name = `AE2 Root Project ${Date.now()}`;
            rootTask.TypeID = generalType.ID;
            rootTask.CategoryID = catID;
            rootTask.Status = 'InProgress';
            rootTask.Priority = 'High';
            rootTask.HoursEstimated = 2;
            await RequireSave(rootTask, 'AE2 rootTask');

            const subTaskA = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            subTaskA.NewRecord();
            subTaskA.Name = `AE2 Subtask A ${Date.now()}`;
            subTaskA.ParentID = rootTask.ID;
            subTaskA.TypeID = generalType.ID;
            subTaskA.CategoryID = catID;
            subTaskA.Status = 'InProgress';
            subTaskA.Priority = 'Medium';
            await RequireSave(subTaskA, 'AE2 subTaskA');

            const subTaskB = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            subTaskB.NewRecord();
            subTaskB.Name = `AE2 Subtask B ${Date.now()}`;
            subTaskB.ParentID = rootTask.ID;
            subTaskB.TypeID = generalType.ID;
            subTaskB.CategoryID = catID;
            subTaskB.Status = 'InProgress';
            subTaskB.Priority = 'Medium';
            await RequireSave(subTaskB, 'AE2 subTaskB');

            // Seed 3 runs: parentRun (120s, 3500 tokens, $0.07), childRun (45s, 1200 tokens, $0.025), siblingRun (60s, 1500 tokens, $0.03)
            const parentRun = await createAgentRun(ctx, agentID, {
                StartedAt: new Date('2026-03-10T10:00:00.000Z'),
                CompletedAt: new Date('2026-03-10T10:02:00.000Z'),
                TotalTokensUsed: 1000,
                TotalTokensUsedRollup: 3500,
                TotalCost: 0.02,
                TotalCostRollup: 0.07,
            });
            const childRun = await createAgentRun(ctx, agentID, {
                ParentRunID: parentRun.ID,
                StartedAt: new Date('2026-03-10T10:00:15.000Z'),
                CompletedAt: new Date('2026-03-10T10:01:00.000Z'),
                TotalTokensUsed: 1200,
                TotalCost: 0.025,
            });
            const siblingRun = await createAgentRun(ctx, agentID, {
                StartedAt: new Date('2026-03-10T11:00:00.000Z'),
                CompletedAt: new Date('2026-03-10T11:01:00.000Z'),
                TotalTokensUsed: 1500,
                TotalCost: 0.03,
            });

            const createdEntries: mjBizAppsTasksTaskTimeEntryEntity[] = [];
            const createdLinks: mjBizAppsTasksTaskAgentRunEntity[] = [];

            try {
                // Log human time: 30m billable on rootTask, 45m billable on subTaskA, 15m non-billable on subTaskB
                const logEntry = async (tID: string, mins: number, billable: boolean) => {
                    const e = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                        TASK_TIME_ENTRY_ENTITY,
                        ctx.User,
                    );
                    e.NewRecord();
                    e.TaskID = tID;
                    e.PersonID = sarah.ID;
                    e.WorkDate = FromCalendarDay(workDay);
                    e.Minutes = mins;
                    e.IsBillable = billable;
                    await RequireSave(e, 'AE2 log entry');
                    createdEntries.push(e);
                };
                await logEntry(rootTask.ID, 30, true);
                await logEntry(subTaskA.ID, 45, true);
                await logEntry(subTaskB.ID, 15, false);

                // Link parentRun to rootTask AND to subTaskA (shared run across 2 tasks in one tree)
                // Link childRun AND siblingRun to subTaskB (childRun covered by parentRun in tree; siblingRun counted)
                const linkRun = async (tID: string, rID: string) => {
                    const l = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskAgentRunEntity>(
                        TASK_AGENT_RUN_ENTITY,
                        ctx.User,
                    );
                    l.NewRecord();
                    l.TaskID = tID;
                    l.AIAgentRunID = rID;
                    l.Role = 'Executed';
                    await RequireSave(l, 'AE2 link run');
                    createdLinks.push(l);
                };
                await linkRun(rootTask.ID, parentRun.ID);
                await linkRun(subTaskA.ID, parentRun.ID);
                await linkRun(subTaskB.ID, childRun.ID);
                await linkRun(subTaskB.ID, siblingRun.ID);

                // 1. Check vwTasks columns on rootTask directly
                const vwRootRows = await FindRows<{
                    ID: string;
                    LoggedMinutes: number;
                    AgentRunCount: number;
                    AgentTokens: number;
                    AgentCost: number;
                }>(
                    ctx,
                    TASK_ENTITY,
                    `ID = '${rootTask.ID}'`,
                    ['ID', 'LoggedMinutes', 'AgentRunCount', 'AgentTokens', 'AgentCost'],
                );
                AssertEqual(vwRootRows.length, 1, 'rootTask found in vwTasks');
                AssertEqual(Number(vwRootRows[0].LoggedMinutes), 30, 'vwTasks direct LoggedMinutes = 30');
                AssertEqual(Number(vwRootRows[0].AgentRunCount), 1, 'vwTasks direct AgentRunCount = 1');
                AssertEqual(Number(vwRootRows[0].AgentTokens), 3500, 'vwTasks direct AgentTokens = 3500');
                AssertEqual(Number(Number(vwRootRows[0].AgentCost).toFixed(2)), 0.07, 'vwTasks direct AgentCost = 0.07');

                // 2. Call Tasks.GetTaskEffort with IncludeDescendants = true on rootTask
                const effortRes = await new TasksGetTaskEffortOperation().Execute(
                    { TaskID: rootTask.ID, IncludeDescendants: true },
                    { user: ctx.User, provider: ctx.Provider },
                );
                Assert(effortRes.Success && !!effortRes.Output, 'GetTaskEffort succeeded');
                const effort = effortRes.Output!;

                AssertEqual(effort.EstimatedMinutes, 120, 'EstimatedMinutes = 120');
                AssertEqual(effort.DirectLoggedMinutes, 30, 'DirectLoggedMinutes = 30');
                AssertEqual(effort.RolledUpLoggedMinutes, 90, 'RolledUpLoggedMinutes = 90');
                AssertEqual(effort.BillableMinutes, 75, 'BillableMinutes = 75');
                AssertEqual(effort.NonBillableMinutes, 15, 'NonBillableMinutes = 15');
                AssertEqual(effort.VarianceMinutes, -30, 'VarianceMinutes = -30');

                // Agent rollup: parentRun counted ONCE (despite 2 links + childRun in tree) + siblingRun = 2 runs
                AssertEqual(effort.DirectAgentRunCount, 1, 'DirectAgentRunCount = 1');
                AssertEqual(effort.RolledUpAgentRunCount, 2, 'RolledUpAgentRunCount = 2 (deduplicated)');
                AssertEqual(effort.AgentTotalTokens, 5000, 'AgentTotalTokens = 3500 + 1500 = 5000');
                AssertEqual(Number(effort.AgentTotalCost.toFixed(2)), 0.1, 'AgentTotalCost = 0.07 + 0.03 = 0.10');
                AssertEqual(effort.AgentWallClockSeconds, 180, 'AgentWallClockSeconds = 120 + 60 = 180');
            } finally {
                for (const l of createdLinks) {
                    if (await l.Load(l.ID)) await l.Delete();
                }
                for (const e of createdEntries) {
                    if (await e.Load(e.ID)) await e.Delete();
                }
                await siblingRun.Delete();
                await childRun.Delete();
                await parentRun.Delete();
                await DeleteTask(ctx, subTaskB);
                await DeleteTask(ctx, subTaskA);
                await DeleteTask(ctx, rootTask);
            }
        },
    },
    {
        Id: 'agent-effort.AE3',
        Name: 'AE3 — Link Agent Run to Task action links an agent run and returns TaskAgentRunID',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await GetOrLoadWorld(ctx);
            const taskID = world.SeedTaskIDs['GraphQL API Resolvers'];
            const { ID: agentID } = await getOrCreateTestAgent(ctx);

            const run = await createAgentRun(ctx, agentID, {
                StartedAt: new Date('2026-03-11T09:00:00.000Z'),
                CompletedAt: new Date('2026-03-11T09:01:00.000Z'),
                TotalTokensUsed: 800,
                TotalCost: 0.015,
            });

            try {
                const actionRows = await FindRows<{ ID: string }>(
                    ctx,
                    ACTION_ENTITY,
                    "Name = 'Link Agent Run to Task'",
                    ['ID'],
                );
                Assert(actionRows.length > 0, 'Link Agent Run to Task action metadata present');
                const actionEntity = await ctx.Provider.GetEntityObject<MJActionEntity>(ACTION_ENTITY, ctx.User);
                await actionEntity.Load(actionRows[0].ID);

                const action = new LinkAgentRunToTaskAction();
                const params = [
                    { Name: 'TaskID', Value: taskID, Type: 'Input' as const },
                    { Name: 'AIAgentRunID', Value: run.ID, Type: 'Input' as const },
                    { Name: 'Role', Value: 'Assisted', Type: 'Input' as const },
                    { Name: 'Notes', Value: 'AE3 action link test', Type: 'Input' as const },
                    { Name: 'TaskAgentRunID', Value: null, Type: 'Output' as const },
                ];
                const res = await action.Run({
                    Action: actionEntity,
                    Params: params,
                    ContextUser: ctx.User,
                    Filters: [],
                });
                Assert(res.Success, `LinkAgentRunToTaskAction succeeded: ${res.Message}`);
                AssertEqual(res.ResultCode, 'SUCCESS', 'ResultCode is SUCCESS');

                const links = await FindRows<{ ID: string; Role: string }>(
                    ctx,
                    TASK_AGENT_RUN_ENTITY,
                    `TaskID = '${taskID}' AND AIAgentRunID = '${run.ID}'`,
                    ['ID', 'Role'],
                );
                AssertEqual(links.length, 1, 'TaskAgentRun created by action');
                AssertEqual(links[0].Role, 'Assisted', 'Role persisted as Assisted');
            } finally {
                const links = await FindRows<{ ID: string }>(
                    ctx,
                    TASK_AGENT_RUN_ENTITY,
                    `TaskID = '${taskID}' AND AIAgentRunID = '${run.ID}'`,
                    ['ID'],
                );
                for (const row of links) {
                    const l = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskAgentRunEntity>(
                        TASK_AGENT_RUN_ENTITY,
                        ctx.User,
                    );
                    if (await l.Load(row.ID)) await l.Delete();
                }
                await run.Delete();
            }
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('agent-effort', { Setup: async () => {}, Teardown: async () => {} });
