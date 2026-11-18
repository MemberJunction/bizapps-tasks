import { beforeEach, describe, expect, it, vi } from 'vitest';

const { service } = vi.hoisted(() => ({
    service: {
        ResolveLeaver: vi.fn(),
        ResolveCallerAuthority: vi.fn(),
        ListHoldings: vi.fn(),
        Reassign: vi.fn(),
    },
}));

vi.mock('@memberjunction/actions-base', () => ({}));
vi.mock('@memberjunction/actions', () => ({ BaseAction: class {} }));
vi.mock('@memberjunction/global', () => ({
    RegisterClass: () => () => {},
    IsValidUUID: (v: string) => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v),
}));
vi.mock('@mj-biz-apps/tasks-entities-server', () => ({
    OffboardingHoldingsService: class {
        constructor() {
            return service;
        }
    },
    ParseStringArray: (value: string | null, name: string) => {
        if (!value) return null;
        const parsed = JSON.parse(value);
        if (!Array.isArray(parsed)) throw new Error(`${name} must be a JSON array of strings.`);
        return parsed;
    },
}));

import { ListOffboardingHoldingsAction } from '../custom/offboarding/ListOffboardingHoldingsAction.js';
import { ReassignOffboardingHoldingsAction } from '../custom/offboarding/ReassignOffboardingHoldingsAction.js';

const LEAVER = 'b0000000-0000-0000-0000-000000000001';
const SUCCESSOR = 'b0000000-0000-0000-0000-000000000002';
const leaver = { UserID: LEAVER, EmployeeID: null, SupervisorEmployeeID: null, PersonIDs: [] };

type Param = { Name: string; Value: string | number; Type: string };
type Result = { Success: boolean; ResultCode: string; Message?: string };
type Runnable = { InternalRunAction(p: { ContextUser: { ID: string } | null; Params: Param[] }): Promise<Result> };

async function run(action: object, inputs: Record<string, string>, user: { ID: string } | null = { ID: 'caller' }): Promise<{ result: Result; params: Param[] }> {
    const params: Param[] = Object.entries(inputs).map(([Name, Value]) => ({ Name, Value, Type: 'Input' }));
    const result = await (action as Runnable).InternalRunAction({ ContextUser: user, Params: params });
    return { result, params };
}

const output = (params: Param[], name: string) => params.find((p) => p.Name === name && p.Type === 'Output')?.Value;

beforeEach(() => {
    vi.clearAllMocks();
    service.ResolveLeaver.mockResolvedValue(leaver);
    service.ResolveCallerAuthority.mockResolvedValue({ IsLeaversSupervisor: true, HoldsSalesAdmin: false, IsCFOApprover: false, MayReassignApprovals: true });
});

describe('Tasks: List Offboarding Holdings', () => {
    it('returns the holdings as JSON', async () => {
        const holdings = [{ App: 'Tasks', Kind: 'TASK_ASSIGNMENT', RecordID: 'a1', CanReassign: true }];
        service.ListHoldings.mockResolvedValue({ Holdings: holdings, Facts: [] });
        const { result, params } = await run(new ListOffboardingHoldingsAction(), { LeaverUserID: LEAVER });
        expect(result).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(JSON.parse(String(output(params, 'Holdings')))).toEqual(holdings);
        expect(service.ResolveLeaver).toHaveBeenCalledWith(LEAVER, null);
    });

    it('needs a leaver ID', async () => {
        const { result } = await run(new ListOffboardingHoldingsAction(), {});
        expect(result.ResultCode).toBe('INVALID_INPUT');
    });

    it('refuses an ID that is not a UUID before reaching the database', async () => {
        const { result } = await run(new ListOffboardingHoldingsAction(), { LeaverEmployeeID: "x' OR 1=1" });
        expect(result.ResultCode).toBe('INVALID_INPUT');
        expect(service.ResolveLeaver).not.toHaveBeenCalled();
    });

    it('returns INVALID_INPUT when the leaver does not resolve', async () => {
        service.ResolveLeaver.mockResolvedValue(null);
        const { result } = await run(new ListOffboardingHoldingsAction(), { LeaverUserID: LEAVER });
        expect(result.ResultCode).toBe('INVALID_INPUT');
    });

    it('reports a failed lookup as ERROR', async () => {
        service.ResolveLeaver.mockRejectedValue(new Error('database unavailable'));
        const { result } = await run(new ListOffboardingHoldingsAction(), { LeaverUserID: LEAVER });
        expect(result).toMatchObject({ Success: false, ResultCode: 'ERROR', Message: 'database unavailable' });
    });

    it('needs a context user', async () => {
        const { result } = await run(new ListOffboardingHoldingsAction(), { LeaverUserID: LEAVER }, null);
        expect(result.ResultCode).toBe('ERROR');
    });
});

describe('Tasks: Reassign Offboarding Holdings', () => {
    it('passes the filters through and returns Moved and Skipped', async () => {
        const skipped = [{ Kind: 'APPROVAL_ASSIGNMENT', EntityName: 'MJ_BizApps_Tasks: Task Assignments', RecordID: 'a2', Reason: 'refused' }];
        service.Reassign.mockResolvedValue({ ResultCode: 'SUCCESS', Message: 'Moved 1', Moved: 1, Skipped: skipped });
        const { result, params } = await run(new ReassignOffboardingHoldingsAction(), {
            LeaverUserID: LEAVER, SuccessorUserID: SUCCESSOR, Kinds: '["TASK_ASSIGNMENT"]', RecordIDs: '["a1","a2"]',
        });
        expect(result).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(service.Reassign).toHaveBeenCalledWith(leaver, SUCCESSOR, ['TASK_ASSIGNMENT'], ['a1', 'a2']);
        expect(output(params, 'Moved')).toBe(1);
        expect(JSON.parse(String(output(params, 'Skipped')))).toEqual(skipped);
    });

    it('returns NOT_AUTHORIZED as a failure, with the skips', async () => {
        service.Reassign.mockResolvedValue({ ResultCode: 'NOT_AUTHORIZED', Message: 'no', Moved: 0, Skipped: [] });
        const { result, params } = await run(new ReassignOffboardingHoldingsAction(), { LeaverUserID: LEAVER, SuccessorUserID: SUCCESSOR });
        expect(result).toMatchObject({ Success: false, ResultCode: 'NOT_AUTHORIZED' });
        expect(output(params, 'Moved')).toBe(0);
    });

    it('needs a successor', async () => {
        const { result } = await run(new ReassignOffboardingHoldingsAction(), { LeaverUserID: LEAVER });
        expect(result.ResultCode).toBe('INVALID_INPUT');
        expect(service.Reassign).not.toHaveBeenCalled();
    });

    it('refuses filters that are not JSON arrays', async () => {
        const { result } = await run(new ReassignOffboardingHoldingsAction(), { LeaverUserID: LEAVER, SuccessorUserID: SUCCESSOR, Kinds: '{"a":1}' });
        expect(result.ResultCode).toBe('INVALID_INPUT');
        expect(service.Reassign).not.toHaveBeenCalled();
    });
});
