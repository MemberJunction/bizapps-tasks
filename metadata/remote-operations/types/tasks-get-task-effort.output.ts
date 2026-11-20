/**
 * Output for `Tasks.GetTaskEffort`.
 *
 * NO import statements — definitions are emitted verbatim.
 */
export interface TaskTimeEntrySummary {
    ID: string;
    TaskID: string;
    TaskName: string;
    PersonID: string;
    PersonName: string;
    WorkDate: string;
    Minutes: number;
    StartedAt: string | null;
    EndedAt: string | null;
    Notes: string | null;
    Source: 'Manual' | 'Timer' | 'Imported' | 'Agent';
    IsBillable: boolean;
    TimesheetID: string | null;
    TimesheetStatus: 'Draft' | 'Submitted' | 'Approved' | 'Rejected' | null;
}

export interface TaskAgentRunSummary {
    ID: string;
    TaskID: string;
    TaskName: string;
    AIAgentRunID: string;
    AgentID: string;
    AgentName: string;
    ParentRunID: string | null;
    Role: 'Executed' | 'Assisted' | 'Reviewed' | 'Planned' | 'Triaged';
    Status: string;
    StartedAt: string;
    CompletedAt: string | null;
    DurationSeconds: number;
    TotalTokensUsed: number;
    TotalCost: number;
    Notes: string | null;
    CountedInTotals: boolean;
}

export interface GetTaskEffortOutput {
    TaskID: string;
    IncludeDescendants: boolean;
    EstimatedMinutes: number | null;
    DirectLoggedMinutes: number;
    RolledUpLoggedMinutes: number;
    BillableMinutes: number;
    NonBillableMinutes: number;
    VarianceMinutes: number | null;
    DirectAgentRunCount: number;
    RolledUpAgentRunCount: number;
    AgentWallClockSeconds: number;
    AgentTotalTokens: number;
    AgentTotalCost: number;
    TimeEntries: TaskTimeEntrySummary[];
    AgentRuns: TaskAgentRunSummary[];
}
