import {
    BaseRemotableOperation,
    IMetadataProvider,
    IRunViewProvider,
    RemoteOpServerContext,
    RemoteOperationError,
    RunView,
    UserInfo,
} from '@memberjunction/core';
import { IsValidUUID, RegisterClass } from '@memberjunction/global';
import { ToCalendarDay } from '@mj-biz-apps/common-entities';
import {
    GetTaskEffortInput,
    GetTaskEffortOutput,
    TaskAgentRunSummary,
    TaskTimeEntrySummary,
    TasksGetTaskEffortOperation,
    mjBizAppsTasksTaskAgentRunEntity,
    mjBizAppsTasksTaskTimeEntryEntity,
    mjBizAppsTasksTimesheetEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    AgentRunDurationSeconds,
    CountedAgentRuns,
    type AgentRunEffortFact,
} from '@mj-biz-apps/tasks-core';

interface TaskTreeRow {
    ID: string;
    Name: string;
    ParentID: string | null;
    RootParentID: string | null;
    HoursEstimated?: number | null;
    EstimatedHours?: number | null;
}

interface AgentRunViewRow {
    ID: string;
    AgentID: string;
    Agent: string | null;
    ParentRunID: string | null;
    ParentRunIDPath: string | null;
    Status: string;
    StartedAt: Date | string;
    CompletedAt: Date | string | null;
    TotalTokensUsed: number | null;
    TotalTokensUsedRollup: number | null;
    TotalCost: number | null;
    TotalCostRollup: number | null;
}

const CHUNK_SIZE = 100;

/**
 * Server implementation of `Tasks.GetTaskEffort` (§6.4).
 *
 * Performs all reads via batched `RunView`s (no raw SQL) so behavior is identical
 * on SQL Server and PostgreSQL.
 */
@RegisterClass(BaseRemotableOperation, 'Tasks.GetTaskEffort')
export class GetTaskEffortOperationServer extends TasksGetTaskEffortOperation {
    protected override async InternalExecute(
        input: GetTaskEffortInput,
        provider: IMetadataProvider,
        user: UserInfo,
        _context: RemoteOpServerContext,
    ): Promise<GetTaskEffortOutput> {
        if (!input?.TaskID || !IsValidUUID(input.TaskID)) {
            throw new RemoteOperationError('INVALID_INPUT', 'A valid TaskID UUID is required.');
        }

        const includeDescendants = input.IncludeDescendants !== false;
        const rv = new RunView(provider as unknown as IRunViewProvider);

        // 1. Load target task
        const taskRes = await rv.RunView<TaskTreeRow>(
            {
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                ExtraFilter: `ID='${input.TaskID}'`,
                Fields: ['ID', 'Name', 'ParentID', 'RootParentID', 'HoursEstimated'],
                MaxRows: 1,
                ResultType: 'simple',
            },
            user,
        );
        const targetTask = taskRes?.Success ? taskRes.Results?.[0] : null;
        if (!targetTask) {
            throw new RemoteOperationError('NOT_FOUND', `Task '${input.TaskID}' was not found.`);
        }

        // 2. Collect subtree tasks
        const taskNameById = new Map<string, string>([[targetTask.ID.toLowerCase(), targetTask.Name]]);
        const subtreeIds: string[] = [targetTask.ID];

        if (includeDescendants) {
            const rootId = targetTask.RootParentID || targetTask.ID;
            const treeRes = await rv.RunView<TaskTreeRow>(
                {
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: `RootParentID='${rootId}' OR ID='${rootId}'`,
                    Fields: ['ID', 'Name', 'ParentID'],
                    MaxRows: 5000,
                    ResultType: 'simple',
                },
                user,
            );
            const treeRows = treeRes?.Success ? (treeRes.Results ?? []) : [];
            const childrenByParent = new Map<string, TaskTreeRow[]>();
            for (const row of treeRows) {
                taskNameById.set(row.ID.toLowerCase(), row.Name);
                if (row.ParentID) {
                    const key = row.ParentID.toLowerCase();
                    const list = childrenByParent.get(key) ?? [];
                    list.push(row);
                    childrenByParent.set(key, list);
                }
            }

            const seen = new Set<string>([targetTask.ID.toLowerCase()]);
            const queue: string[] = [targetTask.ID.toLowerCase()];
            while (queue.length > 0) {
                const cur = queue.shift()!;
                const kids = childrenByParent.get(cur) ?? [];
                for (const kid of kids) {
                    const normKid = kid.ID.toLowerCase();
                    if (!seen.has(normKid)) {
                        seen.add(normKid);
                        subtreeIds.push(kid.ID);
                        queue.push(normKid);
                    }
                }
            }
        }

        // 3. Load time entries and agent links across subtreeIds (chunked)
        const [timeEntryRows, agentLinkRows] = await Promise.all([
            this.loadChunkedByTaskIds<mjBizAppsTasksTaskTimeEntryEntity>(
                rv,
                'MJ_BizApps_Tasks: Task Time Entries',
                subtreeIds,
                [
                    'ID',
                    'TaskID',
                    'Task',
                    'PersonID',
                    'Person',
                    'WorkDate',
                    'Minutes',
                    'StartedAt',
                    'EndedAt',
                    'Notes',
                    'Source',
                    'IsBillable',
                    'TimesheetID',
                ],
                'WorkDate DESC, __mj_CreatedAt DESC',
                user,
            ),
            this.loadChunkedByTaskIds<mjBizAppsTasksTaskAgentRunEntity>(
                rv,
                'MJ_BizApps_Tasks: Task Agent Runs',
                subtreeIds,
                ['ID', 'TaskID', 'Task', 'AIAgentRunID', 'Role', 'Notes'],
                '__mj_CreatedAt DESC',
                user,
            ),
        ]);

        // 4. Load timesheet statuses for any referenced TimesheetIDs
        const timesheetIds = [
            ...new Set(
                timeEntryRows
                    .map((r) => r.TimesheetID)
                    .filter((id): id is string => typeof id === 'string' && IsValidUUID(id)),
            ),
        ];
        const timesheetStatusById = new Map<string, mjBizAppsTasksTimesheetEntity['Status']>();
        if (timesheetIds.length > 0) {
            const tsLiterals = timesheetIds.map((id) => `'${id}'`).join(', ');
            const tsRes = await rv.RunView<{ ID: string; Status: mjBizAppsTasksTimesheetEntity['Status'] }>(
                {
                    EntityName: 'MJ_BizApps_Tasks: Timesheets',
                    ExtraFilter: `ID IN (${tsLiterals})`,
                    Fields: ['ID', 'Status'],
                    ResultType: 'simple',
                },
                user,
            );
            for (const ts of tsRes?.Results ?? []) {
                timesheetStatusById.set(ts.ID.toLowerCase(), ts.Status);
            }
        }

        // 5. Build TimeEntries summary & human totals
        const targetTaskNorm = targetTask.ID.toLowerCase();
        let directLoggedMinutes = 0;
        let rolledUpLoggedMinutes = 0;
        let billableMinutes = 0;
        let nonBillableMinutes = 0;

        const timeEntries: TaskTimeEntrySummary[] = timeEntryRows.map((row) => {
            const mins = Number(row.Minutes ?? 0);
            const isDirect = row.TaskID.toLowerCase() === targetTaskNorm;
            if (isDirect) {
                directLoggedMinutes += mins;
            }
            rolledUpLoggedMinutes += mins;
            if (row.IsBillable) {
                billableMinutes += mins;
            } else {
                nonBillableMinutes += mins;
            }
            const workDateStr = ToCalendarDay(row.WorkDate) ?? String(row.WorkDate).slice(0, 10);
            const tsStatus = row.TimesheetID
                ? (timesheetStatusById.get(row.TimesheetID.toLowerCase()) ?? null)
                : null;
            return {
                ID: row.ID,
                TaskID: row.TaskID,
                TaskName: row.Task || taskNameById.get(row.TaskID.toLowerCase()) || '',
                PersonID: row.PersonID,
                PersonName: row.Person || '',
                WorkDate: workDateStr,
                Minutes: mins,
                StartedAt: row.StartedAt ? new Date(row.StartedAt).toISOString() : null,
                EndedAt: row.EndedAt ? new Date(row.EndedAt).toISOString() : null,
                Notes: row.Notes ?? null,
                Source: row.Source,
                IsBillable: Boolean(row.IsBillable),
                TimesheetID: row.TimesheetID ?? null,
                TimesheetStatus: tsStatus,
            };
        });

        // 6. Load linked AI Agent Runs and deduplicate via CountedAgentRuns
        const uniqueRunIds = [
            ...new Set(
                agentLinkRows
                    .map((r) => r.AIAgentRunID)
                    .filter((id): id is string => typeof id === 'string' && IsValidUUID(id)),
            ),
        ];
        const runRowById = new Map<string, AgentRunViewRow>();
        if (uniqueRunIds.length > 0) {
            for (let i = 0; i < uniqueRunIds.length; i += CHUNK_SIZE) {
                const chunk = uniqueRunIds.slice(i, i + CHUNK_SIZE).map((id) => `'${id}'`).join(', ');
                const runsRes = await rv.RunView<AgentRunViewRow>(
                    {
                        EntityName: 'MJ: AI Agent Runs',
                        ExtraFilter: `ID IN (${chunk})`,
                        Fields: [
                            'ID',
                            'AgentID',
                            'Agent',
                            'ParentRunID',
                            'ParentRunIDPath',
                            'Status',
                            'StartedAt',
                            'CompletedAt',
                            'TotalTokensUsed',
                            'TotalTokensUsedRollup',
                            'TotalCost',
                            'TotalCostRollup',
                        ],
                        ResultType: 'simple',
                    },
                    user,
                );
                for (const r of runsRes?.Results ?? []) {
                    runRowById.set(r.ID.toLowerCase(), r);
                }
            }
        }

        const runFacts: AgentRunEffortFact[] = [];
        for (const r of runRowById.values()) {
            runFacts.push({
                AIAgentRunID: r.ID,
                ParentRunID: r.ParentRunID,
                ParentRunIDPath: r.ParentRunIDPath,
                StartedAt: r.StartedAt,
                CompletedAt: r.CompletedAt,
                TotalCost: r.TotalCost,
                TotalCostRollup: r.TotalCostRollup,
                TotalTokensUsed: r.TotalTokensUsed,
                TotalTokensUsedRollup: r.TotalTokensUsedRollup,
            });
        }

        const countedFacts = CountedAgentRuns(runFacts);
        const countedRunIdSet = new Set(countedFacts.map((f) => f.AIAgentRunID.toLowerCase()));

        // Deduplicate multiple task links to the same counted run so each counted run is summed once
        const summedRunIds = new Set<string>();
        let directAgentRunCount = 0;
        let rolledUpAgentRunCount = 0;
        let agentWallClockSeconds = 0;
        let agentTotalTokens = 0;
        let agentTotalCost = 0;

        const agentRuns: TaskAgentRunSummary[] = [];
        for (const link of agentLinkRows) {
            const runNorm = link.AIAgentRunID.toLowerCase();
            const r = runRowById.get(runNorm);
            if (!r) continue;

            const isDirect = link.TaskID.toLowerCase() === targetTaskNorm;
            if (isDirect) {
                directAgentRunCount++;
            }

            const durationSeconds = AgentRunDurationSeconds({
                StartedAt: r.StartedAt,
                CompletedAt: r.CompletedAt,
            });
            const tokens = Number(r.TotalTokensUsedRollup ?? r.TotalTokensUsed ?? 0);
            const cost = Number(r.TotalCostRollup ?? r.TotalCost ?? 0);
            const counted = countedRunIdSet.has(runNorm) && !summedRunIds.has(runNorm);

            if (counted) {
                summedRunIds.add(runNorm);
                rolledUpAgentRunCount++;
                agentWallClockSeconds += durationSeconds;
                agentTotalTokens += tokens;
                agentTotalCost += cost;
            }

            agentRuns.push({
                ID: link.ID,
                TaskID: link.TaskID,
                TaskName: link.Task || taskNameById.get(link.TaskID.toLowerCase()) || '',
                AIAgentRunID: link.AIAgentRunID,
                AgentID: r.AgentID,
                AgentName: r.Agent || '',
                ParentRunID: r.ParentRunID ?? null,
                Role: link.Role,
                Status: r.Status || 'Completed',
                StartedAt: r.StartedAt ? new Date(r.StartedAt).toISOString() : new Date().toISOString(),
                CompletedAt: r.CompletedAt ? new Date(r.CompletedAt).toISOString() : null,
                DurationSeconds: durationSeconds,
                TotalTokensUsed: tokens,
                TotalCost: cost,
                Notes: link.Notes ?? null,
                CountedInTotals: counted,
            });
        }

        const rawEstHours = targetTask.HoursEstimated ?? targetTask.EstimatedHours ?? null;
        const estimatedMinutes =
            rawEstHours != null && Number.isFinite(Number(rawEstHours))
                ? Math.round(Number(rawEstHours) * 60)
                : null;
        const effectiveLogged = includeDescendants ? rolledUpLoggedMinutes : directLoggedMinutes;
        const varianceMinutes = estimatedMinutes != null ? effectiveLogged - estimatedMinutes : null;

        return {
            TaskID: targetTask.ID,
            IncludeDescendants: includeDescendants,
            EstimatedMinutes: estimatedMinutes,
            DirectLoggedMinutes: directLoggedMinutes,
            RolledUpLoggedMinutes: rolledUpLoggedMinutes,
            BillableMinutes: billableMinutes,
            NonBillableMinutes: nonBillableMinutes,
            VarianceMinutes: varianceMinutes,
            DirectAgentRunCount: directAgentRunCount,
            RolledUpAgentRunCount: rolledUpAgentRunCount,
            AgentWallClockSeconds: agentWallClockSeconds,
            AgentTotalTokens: agentTotalTokens,
            AgentTotalCost: Number(agentTotalCost.toFixed(6)),
            TimeEntries: timeEntries,
            AgentRuns: agentRuns,
        };
    }

    private async loadChunkedByTaskIds<T>(
        rv: RunView,
        entityName: string,
        taskIds: readonly string[],
        fields: string[],
        orderBy: string,
        user: UserInfo,
    ): Promise<T[]> {
        const all: T[] = [];
        for (let i = 0; i < taskIds.length; i += CHUNK_SIZE) {
            const chunk = taskIds
                .slice(i, i + CHUNK_SIZE)
                .filter((id) => IsValidUUID(id))
                .map((id) => `'${id}'`)
                .join(', ');
            if (!chunk) continue;
            const res = await rv.RunView<T>(
                {
                    EntityName: entityName,
                    ExtraFilter: `TaskID IN (${chunk})`,
                    Fields: fields,
                    OrderBy: orderBy,
                    ResultType: 'simple',
                },
                user,
            );
            if (res?.Success && res.Results) {
                all.push(...res.Results);
            }
        }
        return all;
    }
}
