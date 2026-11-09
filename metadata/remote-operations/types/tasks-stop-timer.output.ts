/**
 * Output for `Tasks.StopTimer`.
 *
 * NO import statements — definitions are emitted verbatim.
 */
export interface StopTimerOutput {
    Success: boolean;
    Message: string;
    CreatedTimeEntryIDs: string[];
    TotalMinutes: number;
    Discarded: boolean;
}
