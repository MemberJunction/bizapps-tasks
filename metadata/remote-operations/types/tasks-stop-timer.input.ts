/**
 * Input for `Tasks.StopTimer`.
 *
 * NO import statements — definitions are emitted verbatim.
 */
export interface StopTimerInput {
    PersonID?: string;
    Notes?: string;
    IsBillable?: boolean;
    EndedAt?: string;
    DiscardIfUnderSeconds?: number;
}
