/**
 * Output for `BizAppsTasks.BulkUpdateTasks`.
 *
 * NO import statements — definitions are emitted verbatim.
 */
export interface TasksBulkUpdateFailure {
    TaskID: string;
    Error: string;
}

export interface TasksBulkUpdateOutput {
    TotalRequested: number;
    UpdatedCount: number;
    FailedCount: number;
    UpdatedTaskIDs: string[];
    Failures: TasksBulkUpdateFailure[];
}
