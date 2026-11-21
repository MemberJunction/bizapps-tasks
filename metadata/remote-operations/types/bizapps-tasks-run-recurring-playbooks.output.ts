/**
 * Output for `BizAppsTasks.RunRecurringPlaybooks`.
 *
 * NO import statements — definitions are emitted verbatim.
 */
export interface RecurringPlaybookOrgResult {
    OrganizationID: string;
    OrganizationName: string;
    Status: 'created' | 'skipped' | 'dry-run' | 'failed';
    CreatedCount: number;
    CreatedTaskIDs: string[];
    Reason?: string;
}

export interface TasksRunRecurringPlaybooksOutput {
    TemplateID: string;
    PeriodKey: string;
    AnchorDate: string;
    DryRun: boolean;
    TargetOrganizations: number;
    LaunchedCount: number;
    SkippedCount: number;
    FailedCount: number;
    TotalTasksCreated: number;
    Results: RecurringPlaybookOrgResult[];
}
