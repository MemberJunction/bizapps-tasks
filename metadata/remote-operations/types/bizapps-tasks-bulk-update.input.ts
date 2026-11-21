/**
 * Input for `BizAppsTasks.BulkUpdateTasks`.
 *
 * NO import statements — definitions are emitted verbatim.
 */
export interface TasksBulkUpdateInput {
    TaskIDs: string[];
    Status?: 'Open' | 'InProgress' | 'Completed' | 'Cancelled' | 'Paused' | 'Blocked' | null;
    Priority?: 'Low' | 'Normal' | 'High' | 'Urgent' | null;
    DueDateMode?: 'unchanged' | 'set' | 'shift' | 'clear';
    DueAt?: string | null;
    ShiftDays?: number | null;
    StartDateMode?: 'unchanged' | 'set' | 'clear';
    StartedAt?: string | null;
    AssigneeMode?: 'unchanged' | 'replace' | 'add' | 'clear';
    AssigneeEntityName?: string | null;
    AssigneeRecordID?: string | null;
    AssigneeRoleID?: string | null;
    OrganizationMode?: 'unchanged' | 'set' | 'clear';
    OrganizationID?: string | null;
    CategoryMode?: 'unchanged' | 'set' | 'clear';
    CategoryID?: string | null;
    TypeID?: string | null;
    TaskTypeStatusID?: string | null;
    AddTagID?: string | null;
}
