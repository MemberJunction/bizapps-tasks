/**
 * Output for `Tasks.WithdrawTimesheet`.
 *
 * NO import statements — definitions are emitted verbatim.
 */
export interface WithdrawTimesheetOutput {
    Success: boolean;
    Message: string;
    TimesheetID?: string;
    Status?: 'Draft' | 'Submitted' | 'Approved' | 'Rejected';
}
