/**
 * Output for `Tasks.SubmitTimesheet`.
 *
 * NO import statements — definitions are emitted verbatim.
 */
export interface TimesheetPartSummary {
    TimesheetApprovalID: string;
    ScopeTaskID: string | null;
    ScopeTaskName: string | null;
    ApprovalTaskID: string;
    ApproverPersonIDs: string[];
    Minutes: number;
    BillableMinutes: number;
    EntryCount: number;
    Status: 'Pending' | 'Approved' | 'Rejected' | 'Canceled';
    CarriedForward: boolean;
}

export interface SubmitTimesheetOutput {
    Success: boolean;
    Message: string;
    TimesheetID?: string;
    Status?: 'Draft' | 'Submitted' | 'Approved' | 'Rejected';
    SubmissionRound?: number;
    TotalMinutes?: number;
    BillableMinutes?: number;
    Parts?: TimesheetPartSummary[];
}
