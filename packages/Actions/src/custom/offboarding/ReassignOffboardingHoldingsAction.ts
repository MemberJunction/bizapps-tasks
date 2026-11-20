import { ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import { RegisterClass } from '@memberjunction/global';
import { ParseStringArray } from '@mj-biz-apps/tasks-entities-server';
import { Fail, IsFailure, OffboardingActionBase, ParamValue, SetOutput } from './OffboardingActionBase.js';

/**
 * Action: Tasks.ReassignOffboardingHoldings ("Tasks: Reassign Offboarding Holdings")
 *
 * Moves a departed user's open task assignments to `SuccessorUserID`, optionally narrowed by `Kinds`
 * and `RecordIDs` (JSON arrays). Permission is re-checked per item, and each move is the assignment's
 * own Save as the calling user, so the approval reassignment guard runs; a refusal is reported in
 * `Skipped`, never bypassed. The requester (AssignedByPersonID) is kept.
 */
@RegisterClass(BaseAction, 'Tasks.ReassignOffboardingHoldings')
export class ReassignOffboardingHoldingsAction extends OffboardingActionBase {
    /**
     * Any signed-in user may run this action: it checks the caller itself (as ContextUser, per item),
     * so MJ's action authorization does not also require a linked authorization. Declared on this
     * class because MJ reads the marker as the registered class's own static field.
     */
    public static readonly AuthorizesCaller = true;

    protected async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        return this.guarded(async () => {
            const successorUserID = ParamValue(params, 'SuccessorUserID');
            if (!successorUserID) return Fail('INVALID_INPUT', 'SuccessorUserID is required');
            const filters = readFilters(params);
            if ('Error' in filters) return Fail('INVALID_INPUT', filters.Error);

            const request = await this.resolveRequest(params);
            if (IsFailure(request)) return request;
            const outcome = await request.Service.Reassign(request.Leaver, successorUserID, filters.Kinds, filters.RecordIDs);
            SetOutput(params, 'Moved', outcome.Moved);
            SetOutput(params, 'Skipped', JSON.stringify(outcome.Skipped));
            return { Success: outcome.ResultCode === 'SUCCESS', ResultCode: outcome.ResultCode, Message: outcome.Message };
        });
    }
}

function readFilters(params: RunActionParams): { Kinds: string[] | null; RecordIDs: string[] | null } | { Error: string } {
    try {
        return {
            Kinds: ParseStringArray(ParamValue(params, 'Kinds'), 'Kinds'),
            RecordIDs: ParseStringArray(ParamValue(params, 'RecordIDs'), 'RecordIDs'),
        };
    } catch (err) {
        return { Error: err instanceof Error ? err.message : String(err) };
    }
}
