import { ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import { RegisterClass } from '@memberjunction/global';
import { IsFailure, OffboardingActionBase, SetOutput } from './OffboardingActionBase.js';

/**
 * Action: Tasks.ListOffboardingHoldings ("Tasks: List Offboarding Holdings")
 *
 * Lists the open task assignments a departed user holds, for the common Offboarding screen, which runs
 * every action in the "Offboarding Holdings" category. Output `Holdings` is a JSON array; each item's
 * CanReassign says whether the calling user may move it.
 */
@RegisterClass(BaseAction, 'Tasks.ListOffboardingHoldings')
export class ListOffboardingHoldingsAction extends OffboardingActionBase {
    /**
     * Any signed-in user may run this action: it checks the caller itself (as ContextUser, per item),
     * so MJ's action authorization does not also require a linked authorization. Declared on this
     * class because MJ reads the marker as the registered class's own static field.
     */
    public static readonly AuthorizesCaller = true;

    protected async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        return this.guarded(async () => {
            const request = await this.resolveRequest(params);
            if (IsFailure(request)) return request;
            const authority = await request.Service.ResolveCallerAuthority(request.Leaver);
            const { Holdings } = await request.Service.ListHoldings(request.Leaver, authority);
            SetOutput(params, 'Holdings', JSON.stringify(Holdings));
            return { Success: true, ResultCode: 'SUCCESS', Message: `Found ${Holdings.length} open task assignment(s).` };
        });
    }
}
