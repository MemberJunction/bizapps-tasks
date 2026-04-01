import { BaseEntity, CompositeKey, Metadata, RunView } from "@memberjunction/core";
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
     */
    async assignToTask(params: {
        taskID: string;
        assigneeEntityID: string;
        assigneeRecordID: string;
        roleID?: string;
        roleNotes?: string;
        assignedByPersonID?: string;
    }): Promise<BaseEntity> {
        const assignment = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Task Assignments');
        assignment.NewRecord();
        assignment.Set('TaskID', params.taskID);
        assignment.Set('AssigneeEntityID', params.assigneeEntityID);
        assignment.Set('AssigneeRecordID', params.assigneeRecordID);
        if (params.roleID) assignment.Set('RoleID', params.roleID);
        if (params.roleNotes) assignment.Set('RoleNotes', params.roleNotes);
        if (params.assignedByPersonID) assignment.Set('AssignedByPersonID', params.assignedByPersonID);

        await assignment.Save();

        await this.taskService.logActivity({
            taskID: params.taskID,
            personID: params.assignedByPersonID,
            activityType: 'AssignmentAdded',
            newValue: params.assigneeRecordID,
            description: `Assignee added to task`,
        });

        return assignment;
    }

    /**
     * Removes an assignment and logs the removal.
     */
    async removeAssignment(assignmentID: string, removedByPersonID?: string): Promise<void> {
        const assignment = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Task Assignments');
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
        });
    }

    /**
     * Returns all assignments for a given task.
     */
    async getAssignmentsForTask(taskID: string): Promise<BaseEntity[]> {
        const rv = new RunView();
        const result = await rv.RunView<BaseEntity>({
            EntityName: 'MJ.BizApps.Tasks: Task Assignments',
            ExtraFilter: `TaskID = '${taskID}'`,
            ResultType: 'entity_object',
        });
        return result?.Results ?? [];
    }
}
