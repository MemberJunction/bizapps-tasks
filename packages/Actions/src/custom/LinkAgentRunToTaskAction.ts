import { Metadata, RunView, UserInfo } from '@memberjunction/core';
import { ActionParam, ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import { IsValidUUID, RegisterClass } from '@memberjunction/global';
import { MJAIAgentRunEntity } from '@memberjunction/core-entities';
import {
    mjBizAppsTasksTaskAgentRunEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskTimeEntryEntity,
} from '@mj-biz-apps/tasks-entities';

const VALID_ROLES: ReadonlySet<mjBizAppsTasksTaskAgentRunEntity['Role']> = new Set([
    'Assisted',
    'Executed',
    'Planned',
    'Reviewed',
    'Triaged',
]);

/**
 * Action: `Link Agent Run to Task` (`DriverClass: LinkAgentRunToTaskAction`).
 *
 * Idempotently links an `MJ: AI Agent Runs` record to a `Task` (creating or returning the
 * `TaskAgentRun` row, subject to `TaskAgentRunEntityServer` ownership and ancestor/descendant
 * normalization rules A1–A2) and optionally creates a `TaskTimeEntry` row with `Source = 'Agent'`
 * from the agent run's elapsed wall-clock duration.
 */
@RegisterClass(BaseAction, 'LinkAgentRunToTaskAction')
export class LinkAgentRunToTaskAction extends BaseAction {
    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) {
            return fail('ERROR', 'ContextUser is required');
        }

        const taskID = stringParam(params, 'TaskID');
        const agentRunID = stringParam(params, 'AIAgentRunID') ?? stringParam(params, 'AgentRunID');
        if (!taskID || !agentRunID || !IsValidUUID(taskID) || !IsValidUUID(agentRunID)) {
            return fail('MISSING_PARAMS', 'Valid TaskID and AIAgentRunID UUIDs are required');
        }

        const rawRole = stringParam(params, 'Role') ?? 'Executed';
        const role: mjBizAppsTasksTaskAgentRunEntity['Role'] = VALID_ROLES.has(
            rawRole as mjBizAppsTasksTaskAgentRunEntity['Role'],
        )
            ? (rawRole as mjBizAppsTasksTaskAgentRunEntity['Role'])
            : 'Executed';
        const notes = stringParam(params, 'Notes');
        const logTimeEntry = boolParam(params, 'LogWallClockAsTimeEntry', false);
        const personID = stringParam(params, 'PersonID');
        if (personID && !IsValidUUID(personID)) {
            return fail('MISSING_PARAMS', 'PersonID is not a valid UUID');
        }

        try {
            const rv = new RunView();
            const [taskRes, runRes] = await Promise.all([
                rv.RunView<mjBizAppsTasksTaskEntity>({
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: `ID='${taskID}'`,
                    Fields: ['ID', 'Name'],
                    MaxRows: 1,
                    ResultType: 'simple',
                }, user),
                rv.RunView<MJAIAgentRunEntity>({
                    EntityName: 'MJ: AI Agent Runs',
                    ExtraFilter: `ID='${agentRunID}'`,
                    Fields: ['ID', 'StartedAt', 'CompletedAt'],
                    MaxRows: 1,
                    ResultType: 'simple',
                }, user),
            ]);

            const taskRow = taskRes?.Success ? taskRes.Results?.[0] : null;
            const runRow = runRes?.Success ? runRes.Results?.[0] : null;
            if (!taskRow) {
                return fail('NOT_FOUND', `Task '${taskID}' was not found`);
            }
            if (!runRow) {
                return fail('NOT_FOUND', `AI Agent Run '${agentRunID}' was not found`);
            }

            const md = new Metadata();
            const link = await md.GetEntityObject<mjBizAppsTasksTaskAgentRunEntity>(
                'MJ_BizApps_Tasks: Task Agent Runs',
                user,
            );
            link.NewRecord();
            link.TaskID = taskID;
            link.AIAgentRunID = agentRunID;
            link.Role = role;
            if (notes) {
                link.Notes = notes;
            }

            const saved = await link.Save();
            if (!saved) {
                const errMsg =
                    link.LatestResult?.CompleteMessage ||
                    link.ResultHistory?.[link.ResultHistory.length - 1]?.Message ||
                    'Failed to save TaskAgentRun link';
                return fail('ERROR', errMsg);
            }

            setOutputParam(params.Params, 'TaskAgentRunID', link.ID);

            let createdTimeEntryID: string | null = null;
            if (logTimeEntry && runRow.StartedAt && runRow.CompletedAt) {
                createdTimeEntryID = await createAgentTimeEntry(
                    md,
                    taskID,
                    runRow.StartedAt,
                    runRow.CompletedAt,
                    personID,
                    notes,
                    user,
                );
                if (createdTimeEntryID) {
                    setOutputParam(params.Params, 'TaskTimeEntryID', createdTimeEntryID);
                }
            }

            return {
                Success: true,
                ResultCode: 'SUCCESS',
                Message: `Linked AI Agent Run ${agentRunID} to Task ${taskID}`,
                Params: params.Params,
            };
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            return fail('ERROR', `Error linking AI Agent Run to Task: ${msg}`);
        }
    }
}

async function createAgentTimeEntry(
    md: Metadata,
    taskID: string,
    startedAtRaw: Date | string,
    completedAtRaw: Date | string,
    personID: string | null,
    notes: string | null,
    user: UserInfo,
): Promise<string | null> {
    const startedAt = new Date(startedAtRaw);
    const endedAt = new Date(completedAtRaw);
    if (Number.isNaN(startedAt.getTime()) || Number.isNaN(endedAt.getTime()) || endedAt <= startedAt) {
        return null;
    }
    const elapsedMinutes = Math.max(1, Math.min(1440, Math.round((endedAt.getTime() - startedAt.getTime()) / 60000)));
    const entry = await md.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
        'MJ_BizApps_Tasks: Task Time Entries',
        user,
    );
    entry.NewRecord();
    entry.TaskID = taskID;
    if (personID) {
        entry.PersonID = personID;
    }
    entry.WorkDate = new Date(Date.UTC(startedAt.getUTCFullYear(), startedAt.getUTCMonth(), startedAt.getUTCDate()));
    entry.StartedAt = startedAt;
    entry.EndedAt = endedAt;
    entry.Minutes = elapsedMinutes;
    entry.Source = 'Agent';
    entry.IsBillable = false;
    if (notes) {
        entry.Notes = notes;
    }
    const ok = await entry.Save();
    return ok ? entry.ID : null;
}

function stringParam(params: RunActionParams, name: string): string | null {
    const value = params.Params.find((p) => p.Name.toLowerCase() === name.toLowerCase())?.Value;
    return typeof value === 'string' && value.trim() ? value.trim() : null;
}

function boolParam(params: RunActionParams, name: string, fallback: boolean): boolean {
    const value = params.Params.find((p) => p.Name.toLowerCase() === name.toLowerCase())?.Value;
    if (typeof value === 'boolean') return value;
    if (typeof value === 'string') {
        const norm = value.trim().toLowerCase();
        if (norm === 'true' || norm === '1' || norm === 'yes') return true;
        if (norm === 'false' || norm === '0' || norm === 'no') return false;
    }
    return fallback;
}

function setOutputParam(paramsList: ActionParam[], name: string, value: unknown): void {
    const existing = paramsList.find((p) => p.Name.toLowerCase() === name.toLowerCase());
    if (existing) {
        existing.Value = value;
    } else {
        paramsList.push({ Name: name, Type: 'Output', Value: value });
    }
}

function fail(resultCode: string, message: string): ActionResultSimple {
    return { Success: false, ResultCode: resultCode, Message: message };
}
