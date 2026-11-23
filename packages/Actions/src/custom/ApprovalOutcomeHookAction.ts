import { LogError, Metadata, RunView } from '@memberjunction/core';
import type { ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import { IsValidUUID, RegisterClass, UUIDsEqual } from '@memberjunction/global';
import {
    COS_TASKS_INBOX_WORKSTREAM_KEY,
    GuidLiteral,
    IsTaskDecisionOutcomeCode,
    TaskDecisionOutcomes,
} from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksTaskActivityEntity,
    mjBizAppsTasksTaskDecisionEntity,
    mjBizAppsTasksTaskDecisionOutcomeEntity,
    mjBizAppsTasksTaskDependencyEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskLinkEntity,
} from '@mj-biz-apps/tasks-entities';
import { failResult, getStringParam, setOutputParam, successResult, wakeChiefOfStaffBestEffort } from './action-helpers.js';

export const PROCESS_APPROVAL_OUTCOME_ACTION_NAME = 'Process Approval Request Outcome';

const TASKS_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_DECISIONS_ENTITY = 'MJ_BizApps_Tasks: Task Decisions';
const TASK_DECISION_OUTCOMES_ENTITY = 'MJ_BizApps_Tasks: Task Decision Outcomes';
const TASK_LINKS_ENTITY = 'MJ_BizApps_Tasks: Task Links';
const TASK_DEPENDENCIES_ENTITY = 'MJ_BizApps_Tasks: Task Dependencies';
const TASK_ACTIVITIES_ENTITY = 'MJ_BizApps_Tasks: Task Activities';

export type ApprovalHookOutcomeKind = 'Approved' | 'Rejected' | 'Cancelled';

/**
 * Approve-then-act hook action for `APPROVAL_REQUEST` tasks (`OnComplete`, `OnReject`, `OnCancel`).
 *
 * Enforces fail-closed verification that an `OnComplete` execution actually carries an approving
 * `TaskDecision` before acting, audits settlement on `TaskActivity`, inspects linked source records
 * and downstream blocked dependencies, and signals the Chief of Staff registry so dependent workflows
 * proceed cleanly after explicit human approval.
 */
@RegisterClass(BaseAction, 'Tasks.ProcessApprovalOutcomeHook')
export class ApprovalOutcomeHookAction extends BaseAction {
    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) {
            return failResult('UNAUTHORIZED', 'ProcessApprovalOutcomeHook requires a signed-in ContextUser.');
        }

        const taskID = (getStringParam(params, 'TaskID', 'RecordID') ?? '').trim();
        if (!IsValidUUID(taskID)) {
            return failResult('VALIDATION_ERROR', `Invalid or missing TaskID '${taskID}'.`);
        }

        const statusParam = (getStringParam(params, 'Status') ?? '').trim();
        const previousStatus = (getStringParam(params, 'PreviousStatus') ?? '').trim();
        const taskTypeCode = (getStringParam(params, 'TaskTypeCode') ?? 'APPROVAL_REQUEST').trim();
        const taskTypeStatusCode = (getStringParam(params, 'TaskTypeStatusCode') ?? '').trim();

        const rv = new RunView();
        const md = new Metadata();
        const taskFilter = GuidLiteral(taskID, 'TaskID');

        try {
            const taskRes = await rv.RunView<mjBizAppsTasksTaskEntity>(
                {
                    EntityName: TASKS_ENTITY,
                    ExtraFilter: `ID = ${taskFilter}`,
                    ResultType: 'entity_object',
                    BypassCache: true,
                },
                user,
            );
            const task = taskRes?.Results?.[0];
            if (!taskRes?.Success || !task) {
                return {
                    Success: false,
                    ResultCode: 'FAILED',
                    Message: `Approval task ${taskID} could not be loaded: ${taskRes?.ErrorMessage ?? 'not found'}.`,
                };
            }

            const effectiveStatus = statusParam || task.Status;
            const decisionsRes = await rv.RunView<mjBizAppsTasksTaskDecisionEntity>(
                {
                    EntityName: TASK_DECISIONS_ENTITY,
                    ExtraFilter: `TaskID = ${taskFilter}`,
                    Fields: ['ID', 'OutcomeID', 'DecidedByPersonID', 'DecidedAt'],
                    OrderBy: 'DecidedAt DESC, __mj_CreatedAt DESC',
                    ResultType: 'simple',
                    BypassCache: true,
                },
                user,
            );
            if (!decisionsRes?.Success) {
                return {
                    Success: false,
                    ResultCode: 'FAILED',
                    Message: `Could not verify standing decisions for task ${taskID}: ${decisionsRes?.ErrorMessage ?? 'unknown error'}.`,
                };
            }

            const latestDecision = decisionsRes.Results?.[0];
            let latestOutcomeCode: string | null = null;
            if (latestDecision?.OutcomeID) {
                const outcomeRes = await rv.RunView<mjBizAppsTasksTaskDecisionOutcomeEntity>(
                    {
                        EntityName: TASK_DECISION_OUTCOMES_ENTITY,
                        ExtraFilter: `ID = ${GuidLiteral(latestDecision.OutcomeID, 'OutcomeID')}`,
                        Fields: ['ID', 'Code'],
                        ResultType: 'simple',
                    },
                    user,
                );
                latestOutcomeCode = outcomeRes?.Results?.[0]?.Code ?? null;
            }

            if (effectiveStatus === 'Completed') {
                const isApprovedDecision =
                    IsTaskDecisionOutcomeCode(latestOutcomeCode) && TaskDecisionOutcomes[latestOutcomeCode].IsApproval;
                if (!isApprovedDecision) {
                    return {
                        Success: false,
                        ResultCode: 'UNAUTHORIZED',
                        Message: `Approve-then-act hook refused for task ${taskID}: Completed approval task requires a standing approving TaskDecision.`,
                    };
                }
            }

            const outcomeKind: ApprovalHookOutcomeKind =
                effectiveStatus === 'Completed'
                    ? 'Approved'
                    : latestOutcomeCode === 'Rejected' || taskTypeStatusCode.toUpperCase() === 'REJECTED'
                      ? 'Rejected'
                      : 'Cancelled';

            const hookEvent =
                outcomeKind === 'Approved'
                    ? 'OnComplete'
                    : outcomeKind === 'Rejected'
                      ? 'OnReject'
                      : 'OnCancel';

            const [linksRes, depsRes] = await Promise.all([
                rv.RunView<mjBizAppsTasksTaskLinkEntity>(
                    {
                        EntityName: TASK_LINKS_ENTITY,
                        ExtraFilter: `TaskID = ${taskFilter}`,
                        Fields: ['ID', 'EntityID', 'RecordID'],
                        ResultType: 'simple',
                    },
                    user,
                ),
                rv.RunView<mjBizAppsTasksTaskDependencyEntity>(
                    {
                        EntityName: TASK_DEPENDENCIES_ENTITY,
                        ExtraFilter: `DependsOnTaskID = ${taskFilter}`,
                        Fields: ['ID', 'TaskID', 'DependencyType'],
                        ResultType: 'simple',
                    },
                    user,
                ),
            ]);

            const linkedRecords = linksRes?.Success ? (linksRes.Results ?? []) : [];
            const downstreamDeps = depsRes?.Success ? (depsRes.Results ?? []) : [];

            const activity = await md.GetEntityObject<mjBizAppsTasksTaskActivityEntity>(TASK_ACTIVITIES_ENTITY, user);
            activity.NewRecord();
            activity.TaskID = task.ID;
            activity.ActivityType = 'DecisionRecorded';
            activity.PreviousValue = previousStatus || null;
            activity.NewValue = outcomeKind;
            activity.Description = `Approve-then-act hook (${hookEvent}) settled for ${taskTypeCode} (${linkedRecords.length} linked record(s), ${downstreamDeps.length} downstream task(s)).`;
            await activity.Save();

            if (outcomeKind === 'Approved') {
                const targetTaskIDs = [...new Set(downstreamDeps.map((d) => d.TaskID).filter((id) => IsValidUUID(id) && !UUIDsEqual(id, task.ID)))];
                if (targetTaskIDs.length > 0 && IsValidUUID(user.ID)) {
                    await wakeChiefOfStaffBestEffort({
                        targetUserID: user.ID,
                        workstreamKey: COS_TASKS_INBOX_WORKSTREAM_KEY,
                        wakeReason: `Approval '${task.Name}' granted; ${targetTaskIDs.length} downstream task(s) ready.`,
                        resumeState: {
                            eventType: 'ApprovalHookSettled',
                            hookEvent,
                            outcomeKind,
                            taskID: task.ID,
                            downstreamCount: targetTaskIDs.length,
                            linkedRecordCount: linkedRecords.length,
                        },
                        actingUser: user,
                    });
                }
            }

            const summary = `${hookEvent} executed for task '${task.Name}' (${outcomeKind}); linked=${linkedRecords.length}, downstream=${downstreamDeps.length}.`;
            setOutputParam(params, 'HookEvent', hookEvent);
            setOutputParam(params, 'OutcomeKind', outcomeKind);
            setOutputParam(params, 'LinkedRecordCount', linkedRecords.length);
            setOutputParam(params, 'DependentTaskCount', downstreamDeps.length);
            setOutputParam(params, 'Summary', summary);

            return successResult(summary, params);
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`ApprovalOutcomeHookAction failed for task ${taskID}: ${msg}`);
            return failResult('FAILED', msg, params);
        }
    }
}
