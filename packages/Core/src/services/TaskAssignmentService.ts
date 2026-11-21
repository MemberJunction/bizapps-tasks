import { CompositeKey, IMetadataProvider, IRunViewProvider, LogError, Metadata, RunView, UserInfo } from "@memberjunction/core";
import type { mjBizAppsTasksTaskAssignmentEntity } from "@mj-biz-apps/tasks-entities";
import { TaskService } from "./TaskService.js";
import { GuidLiteral } from "./sql-guards.js";

/**
 * Service for managing task assignments.
 * Handles polymorphic assignee operations (People and AI Agents)
 * and triggers activity logging on assignment changes.
 */
export class TaskAssignmentService {
    private taskService = new TaskService();

    constructor(private readonly provider: IMetadataProvider = Metadata.Provider) {}

    /**
     * Assigns an entity record (Person or Agent) to a task with an optional role.
     * Logs an activity entry after successful assignment.
     *
     * Pass `provider` to create the assignment and activity on the caller's transactional
     * provider instead of the process-global provider.
     *
     * On an approval task the server decides who may add an assignee (the requester while the request
     * is open, otherwise a holder of the reassign right, and nobody may add themselves). Server code
     * that chose the assignee itself passes `beforeSave: SanctionApprovalAssignment` from
     * `@mj-biz-apps/tasks-entities-server`; in a browser that function does nothing.
     *
     * @throws when the assignment does not save. No activity is logged for a refused assignment.
     */
    async assignToTask(params: {
        taskID: string;
        assigneeEntityID: string;
        assigneeRecordID: string;
        roleID?: string;
        roleNotes?: string;
        assignedByPersonID?: string;
        /** Called with the unsaved assignment just before it is saved. */
        beforeSave?: (assignment: mjBizAppsTasksTaskAssignmentEntity) => void | Promise<void>;
    }, contextUser?: UserInfo, provider?: IMetadataProvider): Promise<mjBizAppsTasksTaskAssignmentEntity> {
        const effectiveProvider = provider ?? this.provider;
        const assignment = await effectiveProvider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(
            'MJ_BizApps_Tasks: Task Assignments',
            contextUser,
        );
        assignment.NewRecord();
        assignment.TaskID = params.taskID;
        assignment.AssigneeEntityID = params.assigneeEntityID;
        assignment.AssigneeRecordID = params.assigneeRecordID;
        if (params.roleID) assignment.RoleID = params.roleID;
        if (params.roleNotes) assignment.RoleNotes = params.roleNotes;
        if (params.assignedByPersonID) assignment.AssignedByPersonID = params.assignedByPersonID;

        if (params.beforeSave) await params.beforeSave(assignment);
        if (!(await assignment.Save())) {
            const detail = assignment.LatestResult?.CompleteMessage ?? 'the save was refused without a reason';
            LogError(`TaskAssignmentService.assignToTask: failed to save assignment for task ${params.taskID}: ${detail}`);
            throw new Error(
                `Failed to assign ${params.assigneeRecordID} to task ${params.taskID}: ${detail}`,
            );
        }

        await this.taskService.logActivity({
            taskID: params.taskID,
            personID: params.assignedByPersonID,
            activityType: 'AssignmentAdded',
            newValue: params.assigneeRecordID,
            description: `Assignee added to task`,
        }, contextUser, effectiveProvider);

        return assignment;
    }

    /**
     * Removes an assignment and logs the removal.
     *
     * @throws when the assignment cannot be loaded or the delete is refused (no activity is logged on refusal).
     */
    async removeAssignment(
        assignmentID: string,
        removedByPersonID?: string,
        contextUser?: UserInfo,
        provider?: IMetadataProvider,
    ): Promise<void> {
        const effectiveProvider = provider ?? this.provider;
        const assignment = await effectiveProvider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(
            'MJ_BizApps_Tasks: Task Assignments',
            contextUser,
        );
        const pk = new CompositeKey([{ FieldName: 'ID', Value: assignmentID }]);
        const loaded = await assignment.InnerLoad(pk);
        if (!loaded) {
            throw new Error(`Task assignment '${assignmentID}' not found`);
        }

        const taskID = assignment.TaskID;
        const assigneeRecordID = assignment.AssigneeRecordID;

        const deleted = await assignment.Delete();
        if (!deleted) {
            throw new Error(
                `Failed to remove assignment '${assignmentID}' from task ${taskID}: ${assignment.LatestResult?.CompleteMessage ?? 'the delete was refused without a reason'}`,
            );
        }

        await this.taskService.logActivity({
            taskID,
            personID: removedByPersonID,
            activityType: 'AssignmentRemoved',
            previousValue: assigneeRecordID,
            description: `Assignee removed from task`,
        }, contextUser, effectiveProvider);
    }

    /**
     * Returns all assignments for a given task.
     *
     * @throws when `taskID` is not a UUID — it reaches SQL text, so an invalid value fails loudly.
     */
    async getAssignmentsForTask(
        taskID: string,
        contextUser?: UserInfo,
        provider?: IRunViewProvider,
    ): Promise<mjBizAppsTasksTaskAssignmentEntity[]> {
        const taskLiteral = GuidLiteral(taskID, 'TaskID');
        const rv = new RunView(provider);
        const result = await rv.RunView<mjBizAppsTasksTaskAssignmentEntity>({
            EntityName: 'MJ_BizApps_Tasks: Task Assignments',
            ExtraFilter: `TaskID = ${taskLiteral}`,
            ResultType: 'entity_object',
        }, contextUser);
        return result?.Results ?? [];
    }
}
