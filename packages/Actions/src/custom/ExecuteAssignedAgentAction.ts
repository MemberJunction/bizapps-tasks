import { LogError, Metadata, RunView, type UserInfo } from '@memberjunction/core';
import type { ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import { AgentRunner } from '@memberjunction/ai-agents';
import { AIEngine } from '@memberjunction/aiengine';
import type { MJAIAgentEntityExtended } from '@memberjunction/ai-core-plus';
import { EscapeSQLString, IsValidUUID, RegisterClass, UUIDsEqual } from '@memberjunction/global';
import { COS_TASKS_INBOX_WORKSTREAM_KEY } from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksTaskAgentRunEntity,
    mjBizAppsTasksTaskCommentEntity,
    mjBizAppsTasksTaskEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    AI_AGENTS_ENTITY,
    checkTypedPolicyGuard,
    failResult,
    findEntityIDByName,
    getBooleanParam,
    getStringParam,
    resolveCallerPerson,
    resolveUserIDForPersonRecord,
    setOutputParam,
    successResult,
    TASK_AGENT_RUNS_ENTITY,
    TASK_ASSIGNMENTS_ENTITY,
    TASK_COMMENTS_ENTITY,
    TASKS_ENTITY,
    toIsoOrNull,
    wakeChiefOfStaffBestEffort,
} from './action-helpers.js';

interface AgentExecutionSummary {
    success: boolean;
    agentRunID: string | null;
    outcomeText: string;
    errorMessage: string | null;
}

interface AgentFinalizationOutcome {
    execution: AgentExecutionSummary;
    commentID: string | null;
    taskStatus: mjBizAppsTasksTaskEntity['Status'];
}

/**
 * Action: `Tasks.ExecuteAssignedAgent`
 *
 * `OnAssign` execution hook (and direct tool) for `Agent Task` (`AGENT_TASK`) workflows (Plan §3.6).
 * When a task is assigned to an `MJ: AI Agents` record:
 * 1. Loads the task and resolves the assigned active AI Agent.
 * 2. Transitions `Open` -> `InProgress` immediately.
 * 3. Executes the agent via `AgentRunner.RunAgent` under the assigner's `contextUser`
 *    (bounded by MJ's entity permissions, RLS, and parent policy ceiling).
 *    When `Async = true` (the default passed by the `OnAssign` hook), dispatches the agent run
 *    in the background and immediately returns `DISPATCHED` so long-running agents never stall
 *    UI saves or HTTP requests.
 * 4. Links the `MJ: AI Agent Runs` row to the task via `MJ_BizApps_Tasks: Task Agent Runs`.
 * 5. Posts a `TaskComment` summarizing the agent's outcome/artifacts or failure.
 * 6. Updates task status (`InProgress` awaiting human acceptance on success unless
 *    `AutoCompleteOnSuccess = true`; `Blocked` with `BlockedReason` on failure).
 * 7. Wakes the assigner's (and creator's) Chief of Staff on the coalesced `tasks-inbox` workstream
 *    via `AgentWakeTriggerService` (best-effort, elevating via `UserCache.Instance.GetSystemUser()` when cross-user).
 */
@RegisterClass(BaseAction, 'Tasks.ExecuteAssignedAgent')
export class ExecuteAssignedAgentAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    private static readonly pendingExecutions = new Set<Promise<void>>();

    /**
     * Awaits all currently tracked background (`Async = true`) executions.
     * Useful for graceful server shutdown and deterministic unit tests.
     */
    public static async WaitForPendingExecutions(): Promise<void> {
        while (ExecuteAssignedAgentAction.pendingExecutions.size > 0) {
            await Promise.allSettled([...ExecuteAssignedAgentAction.pendingExecutions]);
        }
    }

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const taskID = getStringParam(params, 'TaskID');
        if (!taskID || !IsValidUUID(taskID)) {
            return failResult('VALIDATION_ERROR', 'A valid TaskID UUID is required.', params);
        }

        const taskGuard = await checkTypedPolicyGuard({
            params,
            entityName: TASKS_ENTITY,
            operation: 'Update',
            writeFields: ['Status', 'PercentComplete', 'BlockedReason', 'CompletionNotes'],
        });
        if (!taskGuard.Allowed) return taskGuard.Failure;

        const commentGuard = await checkTypedPolicyGuard({
            params,
            entityName: TASK_COMMENTS_ENTITY,
            operation: 'Create',
            writeFields: ['TaskID', 'PersonID', 'Content'],
        });
        if (!commentGuard.Allowed) return commentGuard.Failure;

        try {
            const md = new Metadata();
            const task = await md.GetEntityObject<mjBizAppsTasksTaskEntity>(TASKS_ENTITY, user);
            if (!(await task.Load(taskID))) {
                return failResult('NOT_FOUND', `Task '${taskID}' was not found or is not accessible.`, params);
            }

            const resolvedAgentID = await this.resolveAssignedAgentID(params, task.ID, user);
            if (!resolvedAgentID) {
                const msg = `Task "${task.Name}" has no AI Agent assignee; skipping agent execution.`;
                setOutputParam(params, 'TaskID', task.ID);
                setOutputParam(params, 'Summary', msg);
                return successResult(msg, params, 'NO_AGENT_ASSIGNED');
            }

            const agent = await this.loadActiveAgent(resolvedAgentID, user);
            if (!agent) {
                return failResult(
                    'NOT_FOUND',
                    `Assigned AI Agent '${resolvedAgentID}' was not found or is not Active.`,
                    params,
                );
            }

            // Transition Open -> InProgress while the agent executes
            if (task.Status === 'Open') {
                task.Status = 'InProgress';
                await task.Save();
            }

            const additionalInstructions = getStringParam(params, 'AdditionalInstructions');
            const autoCompleteOnSuccess = getBooleanParam(params, 'AutoCompleteOnSuccess', false);
            const runAsync = getBooleanParam(params, 'Async', false);
            const taskPrompt = this.buildAgentTaskPrompt(task, additionalInstructions);

            if (runAsync) {
                const bgTask = this.runAgentAndFinalize(
                    md,
                    task,
                    agent,
                    taskPrompt,
                    autoCompleteOnSuccess,
                    user,
                )
                    .then(() => undefined)
                    .catch((err) => {
                        const msg = err instanceof Error ? err.message : String(err);
                        LogError(
                            `[BizAppsTasks] Background agent execution failed for task '${task.ID}' (agent '${agent.Name}'): ${msg}`,
                        );
                    });

                ExecuteAssignedAgentAction.pendingExecutions.add(bgTask);
                void bgTask.finally(() => {
                    ExecuteAssignedAgentAction.pendingExecutions.delete(bgTask);
                });

                const summary = `Dispatched agent "${agent.Name}" in background for task "${task.Name}" (status: ${task.Status}).`;
                setOutputParam(params, 'AgentID', agent.ID);
                setOutputParam(params, 'AgentName', agent.Name);
                setOutputParam(params, 'AgentRunID', '');
                setOutputParam(params, 'TaskStatus', task.Status);
                setOutputParam(params, 'CommentID', '');
                setOutputParam(params, 'OutcomeSummary', summary);
                setOutputParam(params, 'Async', true);
                setOutputParam(params, 'Summary', summary);
                return successResult(summary, params, 'DISPATCHED');
            }

            const outcome = await this.runAgentAndFinalize(
                md,
                task,
                agent,
                taskPrompt,
                autoCompleteOnSuccess,
                user,
            );

            setOutputParam(params, 'AgentID', agent.ID);
            setOutputParam(params, 'AgentName', agent.Name);
            setOutputParam(params, 'AgentRunID', outcome.execution.agentRunID ?? '');
            setOutputParam(params, 'TaskStatus', outcome.taskStatus);
            setOutputParam(params, 'CommentID', outcome.commentID ?? '');
            setOutputParam(params, 'OutcomeSummary', outcome.execution.outcomeText);

            if (!outcome.execution.success) {
                return failResult(
                    'AGENT_EXECUTION_FAILED',
                    `Assigned agent "${agent.Name}" failed on task "${task.Name}": ${outcome.execution.errorMessage ?? 'unknown error'}`,
                    params,
                );
            }

            const summary = `Executed agent "${agent.Name}" on task "${task.Name}" (status: ${outcome.taskStatus}).`;
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }

    private async runAgentAndFinalize(
        md: Metadata,
        task: mjBizAppsTasksTaskEntity,
        agent: MJAIAgentEntityExtended,
        taskPrompt: string,
        autoCompleteOnSuccess: boolean,
        user: UserInfo,
    ): Promise<AgentFinalizationOutcome> {
        let execution: AgentExecutionSummary;
        try {
            execution = await this.executeAgent(agent, taskPrompt, user);
        } catch (runErr) {
            const errMsg = runErr instanceof Error ? runErr.message : String(runErr);
            execution = {
                success: false,
                agentRunID: null,
                outcomeText: errMsg,
                errorMessage: errMsg,
            };
        }

        // Best-effort link to MJ_BizApps_Tasks: Task Agent Runs
        if (execution.agentRunID && IsValidUUID(execution.agentRunID)) {
            try {
                const link = await md.GetEntityObject<mjBizAppsTasksTaskAgentRunEntity>(
                    TASK_AGENT_RUNS_ENTITY,
                    user,
                );
                link.NewRecord();
                link.TaskID = task.ID;
                link.AIAgentRunID = execution.agentRunID;
                link.Role = 'Executed';
                link.Notes = execution.success
                    ? `Executed by assigned agent "${agent.Name}"`
                    : `Execution failed for assigned agent "${agent.Name}": ${execution.errorMessage ?? 'unknown error'}`;
                await link.Save();
            } catch (linkErr) {
                LogError(
                    `[BizAppsTasks] Failed to link AgentRun '${execution.agentRunID}' to Task '${task.ID}': ${
                        linkErr instanceof Error ? linkErr.message : String(linkErr)
                    }`,
                );
            }
        }

        // Write progress / outcome comment on the task
        const callerPerson = await resolveCallerPerson(user);
        const commentAuthorPersonID = callerPerson?.ID ?? task.CreatedByPersonID ?? null;
        let commentID: string | null = null;
        if (commentAuthorPersonID) {
            const comment = await md.GetEntityObject<mjBizAppsTasksTaskCommentEntity>(
                TASK_COMMENTS_ENTITY,
                user,
            );
            comment.NewRecord();
            comment.TaskID = task.ID;
            comment.PersonID = commentAuthorPersonID;
            comment.Content = execution.success
                ? `**Agent "${agent.Name}" completed execution:**\n\n${execution.outcomeText}`
                : `**Agent "${agent.Name}" encountered an error:**\n\n${execution.errorMessage ?? 'Execution failed without an error message.'}`;
            if (await comment.Save()) {
                commentID = comment.ID;
            }
        }

        // Update task status cleanly (human remains accountable for acceptance unless AutoCompleteOnSuccess = true)
        if (execution.success) {
            if (autoCompleteOnSuccess) {
                task.Status = 'Completed';
                task.PercentComplete = 100;
                task.CompletedAt = new Date();
            } else {
                task.Status = 'InProgress';
                task.PercentComplete = Math.max(task.PercentComplete ?? 0, 90);
            }
            task.CompletionNotes = execution.outcomeText.slice(0, 2000);
            task.BlockedReason = null;
        } else {
            task.Status = 'Blocked';
            task.BlockedReason = `Assigned agent "${agent.Name}" failed: ${execution.errorMessage ?? 'unknown error'}`.slice(
                0,
                1000,
            );
        }
        await task.Save();

        // Wake assigner's (and creator's) Chief of Staff on coalesced `tasks-inbox` workstream
        const wakeUserIDs = new Set<string>();
        if (IsValidUUID(user.ID)) wakeUserIDs.add(user.ID);
        if (task.CreatedByPersonID) {
            const creatorUserID = await resolveUserIDForPersonRecord(task.CreatedByPersonID, user);
            if (creatorUserID && !Array.from(wakeUserIDs).some((id) => UUIDsEqual(id, creatorUserID))) {
                wakeUserIDs.add(creatorUserID);
            }
        }

        for (const targetUserID of wakeUserIDs) {
            await wakeChiefOfStaffBestEffort({
                targetUserID,
                workstreamKey: COS_TASKS_INBOX_WORKSTREAM_KEY,
                wakeReason: execution.success
                    ? `Agent "${agent.Name}" finished work on task "${task.Name}" and left results ready for review.`
                    : `Agent "${agent.Name}" failed on task "${task.Name}" and needs human attention.`,
                resumeState: {
                    eventType: execution.success ? 'AgentTaskCompleted' : 'AgentTaskFailed',
                    taskID: task.ID,
                    taskName: task.Name,
                    agentID: agent.ID,
                    agentName: agent.Name,
                    agentRunID: execution.agentRunID,
                    commentID,
                    taskStatus: task.Status,
                },
                actingUser: user,
            });
        }

        return {
            execution,
            commentID,
            taskStatus: task.Status,
        };
    }

    private async resolveAssignedAgentID(
        params: RunActionParams,
        taskID: string,
        user: UserInfo,
    ): Promise<string | null> {
        const explicitAgentID = getStringParam(params, 'AgentID');
        if (explicitAgentID && IsValidUUID(explicitAgentID)) {
            return explicitAgentID;
        }

        const agentsEntityID = findEntityIDByName(AI_AGENTS_ENTITY);
        const assigneeEntityID = getStringParam(params, 'AssigneeEntityID');
        const assigneeRecordID = getStringParam(params, 'AssigneeRecordID');
        if (
            agentsEntityID &&
            assigneeEntityID &&
            assigneeRecordID &&
            UUIDsEqual(assigneeEntityID, agentsEntityID) &&
            IsValidUUID(assigneeRecordID)
        ) {
            return assigneeRecordID;
        }

        if (!agentsEntityID) return null;

        const rv = new RunView();
        const assignRes = await rv.RunView<{ AssigneeRecordID: string }>(
            {
                EntityName: TASK_ASSIGNMENTS_ENTITY,
                ExtraFilter:
                    `TaskID = '${EscapeSQLString(taskID)}' ` +
                    `AND AssigneeEntityID = '${EscapeSQLString(agentsEntityID)}'`,
                Fields: ['AssigneeRecordID'],
                OrderBy: 'AssignedAt DESC',
                MaxRows: 1,
                ResultType: 'simple',
            },
            user,
        );
        const recordID = assignRes.Success ? assignRes.Results?.[0]?.AssigneeRecordID : undefined;
        return recordID && IsValidUUID(recordID) ? recordID : null;
    }

    private async loadActiveAgent(
        agentID: string,
        user: UserInfo,
    ): Promise<MJAIAgentEntityExtended | null> {
        await AIEngine.Instance.Config(false, user);
        const agent = AIEngine.Instance.Agents.find((a) => UUIDsEqual(a.ID, agentID));
        if (!agent) return null;
        if (agent.Status && agent.Status !== 'Active') return null;
        return agent;
    }

    private buildAgentTaskPrompt(
        task: mjBizAppsTasksTaskEntity,
        additionalInstructions: string | null,
    ): string {
        const lines: string[] = [
            `You have been assigned the following BizApps Task to execute:`,
            `- **Task ID:** ${task.ID}`,
            `- **Title:** ${task.Name}`,
            `- **Priority:** ${task.Priority}`,
        ];
        if (task.DueAt) {
            lines.push(`- **Due:** ${toIsoOrNull(task.DueAt)}`);
        }
        if (task.Description?.trim()) {
            lines.push(`\n### Description\n${task.Description.trim()}`);
        }
        if (additionalInstructions?.trim()) {
            lines.push(`\n### Additional Instructions\n${additionalInstructions.trim()}`);
        }
        lines.push(
            `\nComplete the requested work and return a concise summary of what you accomplished, any outputs/artifacts created, and anything requiring human review.`,
        );
        return lines.join('\n');
    }

    private async executeAgent(
        agent: MJAIAgentEntityExtended,
        prompt: string,
        user: UserInfo,
    ): Promise<AgentExecutionSummary> {
        const runner = new AgentRunner();
        const result = await runner.RunAgent({
            agent,
            conversationMessages: [{ role: 'user', content: prompt }],
            contextUser: user,
        });

        const agentRunID = result.agentRun?.ID ?? null;
        if (!result.success) {
            const errMsg =
                result.agentRun?.ErrorMessage ??
                result.errorMessage ??
                'Agent execution returned success=false.';
            return {
                success: false,
                agentRunID,
                outcomeText: errMsg,
                errorMessage: errMsg,
            };
        }

        const payloadText = this.formatAgentPayload(result.payload, result.agentRun?.FinalPayload);
        return {
            success: true,
            agentRunID,
            outcomeText: payloadText || 'Agent completed execution with no text summary.',
            errorMessage: null,
        };
    }

    private formatAgentPayload(
        payload: object | string | number | boolean | null | undefined,
        finalPayload: string | null | undefined,
    ): string {
        if (typeof payload === 'string' && payload.trim()) {
            return payload.trim();
        }
        if (payload && typeof payload === 'object') {
            const candidate = payload as { summary?: string; message?: string; response?: string };
            if (typeof candidate.summary === 'string' && candidate.summary.trim()) {
                return candidate.summary.trim();
            }
            if (typeof candidate.message === 'string' && candidate.message.trim()) {
                return candidate.message.trim();
            }
            if (typeof candidate.response === 'string' && candidate.response.trim()) {
                return candidate.response.trim();
            }
            return JSON.stringify(payload);
        }
        if (typeof finalPayload === 'string' && finalPayload.trim()) {
            return finalPayload.trim();
        }
        return '';
    }
}
