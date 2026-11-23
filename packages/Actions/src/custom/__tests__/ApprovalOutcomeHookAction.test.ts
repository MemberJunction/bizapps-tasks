import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { ActionParam, RunActionParams } from '@memberjunction/actions-base';
import type { UserInfo } from '@memberjunction/core';

const { USER, runViewMock, wakeTriggerMock, activityRecords } = vi.hoisted(() => ({
    USER: { ID: '44444444-4444-4444-8444-444444444444', Email: 'approver@acme.test' } as UserInfo,
    runViewMock: vi.fn(),
    wakeTriggerMock: vi.fn(async () => undefined),
    activityRecords: [] as Array<{
        TaskID: string;
        ActivityType: string;
        PreviousValue: string | null;
        NewValue: string | null;
        Description: string;
        Save: ReturnType<typeof vi.fn>;
    }>,
}));

vi.mock('@memberjunction/global', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/global')>();
    return {
        ...actual,
        RegisterClass: () => () => {},
    };
});

vi.mock('@memberjunction/actions', () => ({
    BaseAction: class {},
}));

vi.mock('@memberjunction/ai-agents', () => ({
    AgentWakeTriggerService: {
        Instance: {
            TriggerWakeForWorkstream: (...args: Array<{ targetUserID: string; workstreamKey: string }>) =>
                wakeTriggerMock(...args),
        },
    },
}));

vi.mock('@memberjunction/generic-database-provider', () => ({
    UserCache: { Instance: { Users: [], GetSystemUser: () => USER } },
}));

vi.mock('@memberjunction/ai-core-plus', () => ({
    AgentUserPolicyEngine: { Instance: {} },
    TypedActionPolicyGuard: { Instance: {} },
}));

vi.mock('@memberjunction/aiengine', () => ({
    AIEngine: { Instance: {} },
}));

vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    return {
        ...actual,
        LogError: vi.fn(),
        Metadata: class {
            public async GetEntityObject() {
                const rec = {
                    TaskID: '',
                    ActivityType: '',
                    PreviousValue: null as string | null,
                    NewValue: null as string | null,
                    Description: '',
                    NewRecord: vi.fn(),
                    Save: vi.fn(async () => true),
                };
                activityRecords.push(rec);
                return rec;
            }
        },
        RunView: class {
            public RunView(params: { EntityName: string; ExtraFilter: string }) {
                return runViewMock(params);
            }
        },
    };
});

vi.mock('@mj-biz-apps/tasks-core', async (importOriginal) => {
    return await importOriginal<typeof import('@mj-biz-apps/tasks-core')>();
});

import { ApprovalOutcomeHookAction } from '../ApprovalOutcomeHookAction.js';

const TASK_ID = '11111111-1111-4111-8111-111111111111';
const DOWNSTREAM_ID = '22222222-2222-4222-8222-222222222222';
const OUTCOME_APPROVED = '33333333-3333-4333-8333-333333333331';
const OUTCOME_REJECTED = '33333333-3333-4333-8333-333333333332';

function makeParams(extra: ActionParam[]): RunActionParams {
    return {
        ContextUser: USER,
        Action: { ID: 'act-1', Name: 'Process Approval Request Outcome' } as RunActionParams['Action'],
        Filters: [],
        Params: extra,
    };
}

class TestableApprovalOutcomeHookAction extends ApprovalOutcomeHookAction {
    public runTest(params: RunActionParams) {
        return this.InternalRunAction(params);
    }
}

beforeEach(() => {
    vi.clearAllMocks();
    activityRecords.length = 0;
});

describe('ApprovalOutcomeHookAction', () => {
    it('executes OnComplete approve-then-act hook when a standing Approved decision exists and wakes downstream tasks', async () => {
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TASK_ID, Name: 'Approve Release', Status: 'Completed' }] })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: 'dec-1', OutcomeID: OUTCOME_APPROVED }] })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: OUTCOME_APPROVED, Code: 'Approved' }] })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: 'lnk-1', EntityID: 'ent-po', RecordID: 'po-42' }] })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: 'dep-1', TaskID: DOWNSTREAM_ID, DependencyType: 'FinishToStart' }] });

        const params = makeParams([
            { Name: 'TaskID', Type: 'Input', Value: TASK_ID },
            { Name: 'Status', Type: 'Input', Value: 'Completed' },
            { Name: 'PreviousStatus', Type: 'Input', Value: 'Open' },
            { Name: 'TaskTypeCode', Type: 'Input', Value: 'APPROVAL_REQUEST' },
        ]);

        const res = await new TestableApprovalOutcomeHookAction().runTest(params);

        expect(res.Success).toBe(true);
        expect(res.ResultCode).toBe('SUCCESS');
        expect(params.Params.find((p) => p.Name === 'HookEvent')?.Value).toBe('OnComplete');
        expect(params.Params.find((p) => p.Name === 'OutcomeKind')?.Value).toBe('Approved');
        expect(params.Params.find((p) => p.Name === 'DependentTaskCount')?.Value).toBe(1);
        expect(activityRecords).toHaveLength(1);
        expect(activityRecords[0].NewValue).toBe('Approved');
        expect(wakeTriggerMock).toHaveBeenCalledTimes(1);
    });

    it('fails closed (UNAUTHORIZED) if a Completed APPROVAL_REQUEST task has no standing approving TaskDecision', async () => {
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TASK_ID, Name: 'Approve Release', Status: 'Completed' }] })
            .mockResolvedValueOnce({ Success: true, Results: [] });

        const params = makeParams([
            { Name: 'TaskID', Type: 'Input', Value: TASK_ID },
            { Name: 'Status', Type: 'Input', Value: 'Completed' },
        ]);

        const res = await new TestableApprovalOutcomeHookAction().runTest(params);
        expect(res.Success).toBe(false);
        expect(res.ResultCode).toBe('UNAUTHORIZED');
        expect(wakeTriggerMock).not.toHaveBeenCalled();
    });

    it('routes Cancelled + Rejected outcome to OnReject without waking downstream approved tasks', async () => {
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TASK_ID, Name: 'Approve Release', Status: 'Cancelled' }] })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: 'dec-2', OutcomeID: OUTCOME_REJECTED }] })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: OUTCOME_REJECTED, Code: 'Rejected' }] })
            .mockResolvedValueOnce({ Success: true, Results: [] })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: 'dep-1', TaskID: DOWNSTREAM_ID, DependencyType: 'FinishToStart' }] });

        const params = makeParams([
            { Name: 'TaskID', Type: 'Input', Value: TASK_ID },
            { Name: 'Status', Type: 'Input', Value: 'Cancelled' },
            { Name: 'PreviousStatus', Type: 'Input', Value: 'Open' },
        ]);

        const res = await new TestableApprovalOutcomeHookAction().runTest(params);
        expect(res.Success).toBe(true);
        expect(params.Params.find((p) => p.Name === 'HookEvent')?.Value).toBe('OnReject');
        expect(params.Params.find((p) => p.Name === 'OutcomeKind')?.Value).toBe('Rejected');
        expect(wakeTriggerMock).not.toHaveBeenCalled();
    });

    it('rejects malformed TaskID cleanly with VALIDATION_ERROR', async () => {
        const res = await new TestableApprovalOutcomeHookAction().runTest(
            makeParams([{ Name: 'TaskID', Type: 'Input', Value: 'not-a-uuid' }]),
        );
        expect(res.Success).toBe(false);
        expect(res.ResultCode).toBe('VALIDATION_ERROR');
    });
});
