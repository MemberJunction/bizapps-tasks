/**
 * Input for `Tasks.StartTimer`.
 *
 * NO import statements — definitions are emitted verbatim.
 */
export interface StartTimerInput {
    TaskID: string;
    PersonID?: string;
    Notes?: string;
    IsBillable?: boolean;
}
