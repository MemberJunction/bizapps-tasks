import { BaseEntity, CompositeKey, IMetadataProvider, IRunViewProvider, Metadata, RunView, UserInfo } from "@memberjunction/core";
import { TaskService } from "./TaskService.js";

/**
 * Service for managing task assignments.
 * Handles polymorphic assignee operations (People and AI Agents)
 * and triggers activity logging on assignment changes.
 */
export class TaskAssignmentService {
    private taskService = new TaskService();

    /**
     * Assigns an entity record (Person or Agent) to a task with an optional role.
     * Logs an activity entry after successful assignment.
     *
     * Pass `provider` to create the assignment and activity on the caller's transactional
     * provider instead of the process-global provider.
     *
     * @throws when the assignment does not save. A refused save used to return the unsaved entity
     * with an ID already on it, so the caller recorded an assignment with no row behind it and the
     * task was assigned to no one. No activity is logged for a refused assignment.
     */
    async assignToTask(params: {
        taskID: string;
        assigneeEntityID: string;
        assigneeRecordID: string;
        roleID?: string;
        roleNotes?: string;
        assignedByPersonID?: string;
    }, contextUser?: UserInfo, provider?: IMetadataProvider): Promise<BaseEntity> {
        const assignment = await (provider ?? Metadata.Provider).GetEntityObject('MJ_BizApps_Tasks: Task Assignments', contextUser);
        assignment.NewRecord();
        assignment.Set('TaskID', params.taskID);
        assignment.Set('AssigneeEntityID', params.assigneeEntityID);
        assignment.Set('AssigneeRecordID', params.assigneeRecordID);
        if (params.roleID) assignment.Set('RoleID', params.roleID);
        if (params.roleNotes) assignment.Set('RoleNotes', params.roleNotes);
        if (params.assignedByPersonID) assignment.Set('AssignedByPersonID', params.assignedByPersonID);

        if (!(await assignment.Save())) {
            throw new Error(
                `Failed to assign ${params.assigneeRecordID} to task ${params.taskID}: ${assignment.LatestResult?.CompleteMessage ?? 'the save was refused without a reason'}`,
            );
        }

        await this.taskService.logActivity({
            taskID: params.taskID,
            personID: params.assignedByPersonID,
            activityType: 'AssignmentAdded',
            newValue: params.assigneeRecordID,
            description: `Assignee added to task`,
        }, contextUser, provider);

        return assignment;
    }

    /**
     * Removes an assignment and logs the removal.
     */
    async removeAssignment(
        assignmentID: string,
        removedByPersonID?: string,
        contextUser?: UserInfo,
        provider?: IMetadataProvider,
    ): Promise<void> {
        const assignment = await (provider ?? Metadata.Provider).GetEntityObject('MJ_BizApps_Tasks: Task Assignments', contextUser);
        const pk = new CompositeKey([{ FieldName: 'ID', Value: assignmentID }]);
        await assignment.InnerLoad(pk);

        const taskID = assignment.Get('TaskID') as string;
        const assigneeRecordID = assignment.Get('AssigneeRecordID') as string;

        await assignment.Delete();

        await this.taskService.logActivity({
            taskID,
            personID: removedByPersonID,
            activityType: 'AssignmentRemoved',
            previousValue: assigneeRecordID,
            description: `Assignee removed from task`,
        }, contextUser, provider);
    }

    /**
     * Returns all assignments for a given task.
     */
    async getAssignmentsForTask(
        taskID: string,
        contextUser?: UserInfo,
        provider?: IRunViewProvider,
    ): Promise<BaseEntity[]> {
        const rv = new RunView(provider);
        const result = await rv.RunView<BaseEntity>({
            EntityName: 'MJ_BizApps_Tasks: Task Assignments',
            ExtraFilter: `TaskID = '${taskID}'`,
            ResultType: 'entity_object',
        }, contextUser);
        return result?.Results ?? [];
    }
}
