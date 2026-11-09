/**
 * Output for `Tasks.ReopenTimesheet`.
 *
 * NO import statements — definitions are emitted verbatim.
 */
export interface ReopenTimesheetOutput {
    Success: boolean;
    Message: string;
    TimesheetID?: string;
    Status?: 'Draft' | 'Submitted' | 'Approved' | 'Rejected';
}
