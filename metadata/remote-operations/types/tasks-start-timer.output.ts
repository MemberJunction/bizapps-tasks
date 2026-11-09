/**
 * Output for `Tasks.StartTimer`.
 *
 * NO import statements — definitions are emitted verbatim.
 */
export interface StartTimerOutput {
    Success: boolean;
    Message: string;
    TimerID?: string;
    StartedAt?: string;
    AutoStoppedEntryIDs?: string[];
    AutoStoppedMinutes?: number;
}
