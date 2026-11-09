/**
 * Input for `Tasks.SubmitTimesheet`.
 *
 * NO import statements — definitions are emitted verbatim.
 */
export interface SubmitTimesheetInput {
    TimesheetID?: string;
    PersonID?: string;
    PeriodStart?: string;
    PeriodEnd?: string;
    Notes?: string;
}
