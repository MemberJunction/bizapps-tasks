import type { UserInfo } from '@memberjunction/core';
import { ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import { IsValidUUID } from '@memberjunction/global';
import { type LeaverIdentity, OffboardingHoldingsService } from '@mj-biz-apps/tasks-entities-server';

/** A resolved request: the service bound to the caller, and the leaver. */
export interface OffboardingRequest {
    Service: OffboardingHoldingsService;
    Leaver: LeaverIdentity;
}

/**
 * Shared input handling for the Tasks offboarding actions (bc-aidp-next-golive#297): reads
 * `LeaverUserID` / `LeaverEmployeeID`, resolves the leaver as the calling user, and turns errors
 * into result codes. The work itself is OffboardingHoldingsService's.
 */
export abstract class OffboardingActionBase extends BaseAction {
    /** Builds the service; a seam for tests. */
    protected createService(user: UserInfo): OffboardingHoldingsService {
        return new OffboardingHoldingsService(user);
    }

    /** The service and leaver for this run, or the failure to return. */
    protected async resolveRequest(params: RunActionParams): Promise<OffboardingRequest | ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return Fail('ERROR', 'ContextUser is required');
        const userID = ParamValue(params, 'LeaverUserID');
        const employeeID = ParamValue(params, 'LeaverEmployeeID');
        if (!userID && !employeeID) return Fail('INVALID_INPUT', 'LeaverUserID or LeaverEmployeeID is required');
        if ((userID && !IsValidUUID(userID)) || (employeeID && !IsValidUUID(employeeID))) {
            return Fail('INVALID_INPUT', 'LeaverUserID and LeaverEmployeeID must be valid IDs');
        }
        const service = this.createService(user);
        const leaver = await service.ResolveLeaver(userID, employeeID);
        if (!leaver) return Fail('INVALID_INPUT', 'Neither LeaverUserID nor LeaverEmployeeID matches a user or employee');
        return { Service: service, Leaver: leaver };
    }

    /** Runs the action body, reporting an unexpected error as ERROR rather than throwing. */
    protected async guarded(run: () => Promise<ActionResultSimple>): Promise<ActionResultSimple> {
        try {
            return await run();
        } catch (err) {
            return Fail('ERROR', err instanceof Error ? err.message : String(err));
        }
    }
}

/** True when `resolveRequest` returned a failure. */
export function IsFailure(value: OffboardingRequest | ActionResultSimple): value is ActionResultSimple {
    return 'ResultCode' in value;
}

export function ParamValue(params: RunActionParams, name: string): string | null {
    const value = params.Params.find((p) => p.Name.toLowerCase() === name.toLowerCase())?.Value;
    return typeof value === 'string' && value.trim() ? value.trim() : null;
}

export function SetOutput(params: RunActionParams, name: string, value: string | number): void {
    const existing = params.Params.find((p) => p.Name.toLowerCase() === name.toLowerCase());
    if (existing) {
        existing.Value = value;
        existing.Type = 'Output';
        return;
    }
    params.Params.push({ Name: name, Type: 'Output', Value: value });
}

export function Fail(resultCode: string, message: string): ActionResultSimple {
    return { Success: false, ResultCode: resultCode, Message: message };
}
