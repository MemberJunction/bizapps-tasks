import { describe, it, expect, beforeEach, vi } from 'vitest';
import type { ActionParam, ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import type { UserInfo } from '@memberjunction/core';

const {
    resolvePersonForUserMock,
    resolveSupervisorChainMock,
    resolveDirectReportPersonIDsMock,
    draftWorkReportMock,
    submitWorkReportMock,
    recordSupervisorReviewMock,
    checkEntityAccessMock,
    maskRecordMock,
    maskRowsMock,
    runViewMock,
} = vi.hoisted(() => ({
    resolvePersonForUserMock: vi.fn(),
    resolveSupervisorChainMock: vi.fn(),
    resolveDirectReportPersonIDsMock: vi.fn(),
    draftWorkReportMock: vi.fn(),
    submitWorkReportMock: vi.fn(),
    recordSupervisorReviewMock: vi.fn(),
    checkEntityAccessMock: vi.fn(),
    maskRecordMock: vi.fn(<T extends object>(rec: T, patterns: readonly string[]): T => {
        if (!patterns?.length) return rec;
        const copy = { ...rec } as Record<string, string | number | boolean | Date | null | undefined | object>;
        for (const p of patterns) {
            delete copy[p];
        }
        return copy as T;
    }),
    maskRowsMock: vi.fn(<T extends object>(rows: readonly T[], patterns: readonly string[]): T[] => {
        if (!patterns?.length) return [...rows];
        return rows.map((r) => {
            const copy = { ...r } as Record<string, string | number | boolean | Date | null | undefined | object>;
            for (const p of patterns) delete copy[p];
            return copy as T;
        });
    }),
    runViewMock: vi.fn(),
}));

vi.mock('@memberjunction/actions-base', () => ({}));
vi.mock('@memberjunction/actions', () => ({ BaseAction: class {} }));
vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    return {
        ...actual,
        LogError: vi.fn(),
        LogStatus: vi.fn(),
        Metadata: class {
            public static Provider = { Entities: [] };
        },
        RunView: class {
            public RunView = runViewMock;
        },
    };
});
vi.mock('@memberjunction/ai-core-plus', () => ({
    TypedActionPolicyGuard: {
        CheckEntityAccess: checkEntityAccessMock,
        MaskRecord: maskRecordMock,
        MaskRows: maskRowsMock,
    },
}));
vi.mock('@memberjunction/ai-agents', () => ({
    AgentWakeTriggerService: { Instance: { TriggerWakeForWorkstream: vi.fn() } },
}));
vi.mock('@memberjunction/generic-database-provider', () => ({
    UserCache: { Instance: { GetSystemUser: vi.fn() } },
}));
vi.mock('@mj-biz-apps/common-entities', () => ({
    ResolveUserIDForPerson: vi.fn(),
}));
vi.mock('@memberjunction/global', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/global')>();
    return {
        ...actual,
        RegisterClass: () => () => {},
    };
});
vi.mock('@mj-biz-apps/tasks-core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@mj-biz-apps/tasks-core')>();
    return {
        ...actual,
        WorkReportService: {
            Instance: {
                ResolvePersonForUser: resolvePersonForUserMock,
                ResolveSupervisorChainForPerson: resolveSupervisorChainMock,
                ResolveDirectReportPersonIDs: resolveDirectReportPersonIDsMock,
                DraftWorkReport: draftWorkReportMock,
                SubmitWorkReport: submitWorkReportMock,
                RecordSupervisorReview: recordSupervisorReviewMock,
            },
        },
    };
});

import {
    DRAFT_WORK_REPORT_ACTION_ID,
    DraftWorkReportAction,
    GetWorkReportAction,
    ListWorkReportsAction,
    REVIEW_WORK_REPORT_ACTION_ID,
    ReviewWorkReportAction,
    SUBMIT_WORK_REPORT_ACTION_ID,
    SubmitWorkReportAction,
} from '../custom/WorkReportActions.js';

interface InvokableAction {
    InternalRunAction(params: RunActionParams): Promise<ActionResultSimple>;
}

const USER_ALICE = 'aaaa1111-1111-4111-8111-111111111111';
const USER_BOB = 'bbbb2222-2222-4222-8222-222222222222';
const PERSON_ALICE = '11111111-1111-4111-8111-111111111111';
const PERSON_BOB = '22222222-2222-4222-8222-222222222222';
const PERSON_CAROL = '33333333-3333-4333-8333-333333333333';
const REPORT_ID = '44444444-4444-4444-8444-444444444444';

function makeParams(
    inputs: Record<string, string | boolean | null | undefined>,
    outputs: string[] = [],
): ActionParam[] {
    return [
        ...Object.entries(inputs).map(([Name, Value]) => ({
            Name,
            Value,
            Type: 'Input' as const,
        })),
        ...outputs.map((Name) => ({
            Name,
            Value: undefined,
            Type: 'Output' as const,
        })),
    ];
}

function makeRunParams(userId: string, params: ActionParam[], roles: string[] = []): RunActionParams {
    return {
        ContextUser: {
            ID: userId,
            Email: 'user@example.com',
            UserRoles: roles.map((Role) => ({ Role })),
        } as Partial<UserInfo> as UserInfo,
        Params: params,
    } as Partial<RunActionParams> as RunActionParams;
}

function invokeAction(
    action:
        | GetWorkReportAction
        | ListWorkReportsAction
        | DraftWorkReportAction
        | SubmitWorkReportAction
        | ReviewWorkReportAction,
    params: RunActionParams,
): Promise<ActionResultSimple> {
    return (action as Partial<InvokableAction> as InvokableAction).InternalRunAction(params);
}

beforeEach(() => {
    vi.clearAllMocks();
    checkEntityAccessMock.mockResolvedValue({
        Allowed: true,
        Active: false,
        DeniedFieldPatterns: [],
    });
});

describe('WorkReportActions metadata & AuthorizesCaller', () => {
    it('declares AuthorizesCaller = true across all 5 actions and exports UUIDv4 action IDs', () => {
        expect(GetWorkReportAction.AuthorizesCaller).toBe(true);
        expect(ListWorkReportsAction.AuthorizesCaller).toBe(true);
        expect(DraftWorkReportAction.AuthorizesCaller).toBe(true);
        expect(SubmitWorkReportAction.AuthorizesCaller).toBe(true);
        expect(ReviewWorkReportAction.AuthorizesCaller).toBe(true);
        expect(DRAFT_WORK_REPORT_ACTION_ID).toMatch(/^[0-9a-f-]{36}$/i);
        expect(SUBMIT_WORK_REPORT_ACTION_ID).toMatch(/^[0-9a-f-]{36}$/i);
        expect(REVIEW_WORK_REPORT_ACTION_ID).toMatch(/^[0-9a-f-]{36}$/i);
    });
});

describe('GetWorkReportAction & ListWorkReportsAction', () => {
    it('loads a work report and its ordered items for the author and applies field masking', async () => {
        checkEntityAccessMock
            .mockResolvedValueOnce({ Allowed: true, Active: true, DeniedFieldPatterns: ['SupervisorFeedback'] })
            .mockResolvedValueOnce({ Allowed: true, Active: true, DeniedFieldPatterns: [] });
        resolvePersonForUserMock.mockResolvedValueOnce({ ID: PERSON_ALICE });
        runViewMock
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    {
                        ID: REPORT_ID,
                        PersonID: PERSON_ALICE,
                        Person: 'Alice Ng',
                        PeriodStart: '2026-11-20',
                        PeriodEnd: '2026-11-20',
                        Title: 'Daily 15Five — 2026-11-20',
                        Body: '### Completed\n- Shipped typed actions',
                        Status: 'Submitted',
                        SupervisorFeedback: 'Secret draft feedback',
                    },
                ],
            })
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    {
                        ID: '55555555-5555-4555-8555-555555555555',
                        WorkReportID: REPORT_ID,
                        TaskID: '66666666-6666-4666-8666-666666666666',
                        Task: 'Ship typed actions',
                        Section: 'Completed',
                        Summary: 'Shipped typed actions',
                        Sequence: 1,
                    },
                ],
            });

        const params = makeParams({ WorkReportID: REPORT_ID });
        const res = await invokeAction(new GetWorkReportAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        const reportJson = JSON.parse(String(params.find((p) => p.Name === 'WorkReport')?.Value));
        expect(reportJson.ID).toBe(REPORT_ID);
        expect(reportJson.SupervisorFeedback).toBeUndefined();
        expect(reportJson.Items).toHaveLength(1);
    });

    it('returns PERMISSION_DENIED when caller is neither author nor in supervisor chain', async () => {
        resolvePersonForUserMock.mockResolvedValueOnce({ ID: PERSON_CAROL });
        runViewMock
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: REPORT_ID, PersonID: PERSON_ALICE, Body: 'Body', Status: 'Submitted' }],
            })
            .mockResolvedValueOnce({ Success: true, Results: [] });
        resolveSupervisorChainMock.mockResolvedValueOnce({
            AuthorPersonID: PERSON_ALICE,
            SupervisorPersonID: PERSON_BOB,
            SupervisorChainPersonIDs: [PERSON_BOB],
        });

        const res = await invokeAction(
            new GetWorkReportAction(),
            makeRunParams(USER_BOB, makeParams({ WorkReportID: REPORT_ID })),
        );
        expect(res).toMatchObject({ Success: false, ResultCode: 'PERMISSION_DENIED' });
    });

    it('lists TeamPendingReview work reports scoped to direct reports', async () => {
        resolvePersonForUserMock.mockResolvedValueOnce({ ID: PERSON_BOB });
        resolveDirectReportPersonIDsMock.mockResolvedValueOnce([PERSON_ALICE]);
        runViewMock.mockResolvedValueOnce({
            Success: true,
            Results: [
                {
                    ID: REPORT_ID,
                    PersonID: PERSON_ALICE,
                    Person: 'Alice Ng',
                    PeriodStart: '2026-11-20',
                    PeriodEnd: '2026-11-20',
                    Title: 'Daily 15Five',
                    Status: 'Submitted',
                },
            ],
        });

        const params = makeParams({ Scope: 'TeamPendingReview' });
        const res = await invokeAction(new ListWorkReportsAction(), makeRunParams(USER_BOB, params));
        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(params.find((p) => p.Name === 'TotalCount')?.Value).toBe(1);
        expect(runViewMock).toHaveBeenCalledWith(
            expect.objectContaining({
                ExtraFilter: expect.stringContaining(`Status = 'Submitted'`),
            }),
            expect.anything(),
        );
    });

    it('enforces TypedActionPolicyGuard and returns POLICY_DENIED when blocked', async () => {
        checkEntityAccessMock.mockResolvedValueOnce({
            Allowed: false,
            Active: true,
            DeniedFieldPatterns: [],
            ResultCode: 'POLICY_DENIED',
            Message: 'ReadOnly agent policy blocks Work Report creation.',
        });

        const res = await invokeAction(
            new DraftWorkReportAction(),
            makeRunParams(USER_ALICE, makeParams({})),
        );
        expect(res).toMatchObject({ Success: false, ResultCode: 'POLICY_DENIED' });
        expect(draftWorkReportMock).not.toHaveBeenCalled();
    });
});

describe('DraftWorkReportAction (upgraded canonical ResultCodes)', () => {
    it('returns NO_ACTIVITY without writing a draft when WorkReportService reports SkippedNoActivity', async () => {
        resolvePersonForUserMock.mockResolvedValueOnce({ ID: PERSON_ALICE });
        draftWorkReportMock.mockResolvedValueOnce({
            Report: null,
            Items: [],
            SkippedNoActivity: true,
        });

        const params = makeParams(
            {
                PersonID: PERSON_ALICE,
                PeriodStart: '2026-11-09',
                PeriodEnd: '2026-11-09',
            },
            ['WorkReportID'],
        );
        const res = await invokeAction(new DraftWorkReportAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'NO_ACTIVITY' });
        expect(params.find((p) => p.Name === 'WorkReportID')?.Value).toBe('');
    });

    it('delegates to WorkReportService.DraftWorkReport with local day window when PeriodStart/PeriodEnd are omitted', async () => {
        resolvePersonForUserMock.mockResolvedValueOnce({ ID: PERSON_ALICE });
        draftWorkReportMock.mockResolvedValueOnce({
            Report: { ID: REPORT_ID, Status: 'Draft' },
            Items: [{ ID: 'item-1' }],
            SkippedNoActivity: false,
        });

        const params = makeParams({ PersonID: PERSON_ALICE }, ['WorkReportID']);
        const res = await invokeAction(new DraftWorkReportAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(params.find((p) => p.Name === 'WorkReportID')?.Value).toBe(REPORT_ID);
    });

    it('returns NO_PERSON_RECORD when unlinked and PERMISSION_DENIED when drafting for another Person', async () => {
        resolvePersonForUserMock.mockResolvedValueOnce(null);
        const noPersonRes = await invokeAction(
            new DraftWorkReportAction(),
            makeRunParams(USER_ALICE, makeParams({ PersonID: PERSON_ALICE })),
        );
        expect(noPersonRes).toMatchObject({ Success: false, ResultCode: 'NO_PERSON_RECORD' });

        resolvePersonForUserMock.mockResolvedValueOnce({ ID: PERSON_BOB });
        const crossPersonRes = await invokeAction(
            new DraftWorkReportAction(),
            makeRunParams(USER_BOB, makeParams({ PersonID: PERSON_ALICE })),
        );
        expect(crossPersonRes).toMatchObject({ Success: false, ResultCode: 'PERMISSION_DENIED' });
        expect(draftWorkReportMock).not.toHaveBeenCalled();
    });

    it('returns VALIDATION_ERROR on non-UUID PersonID before running queries', async () => {
        const res = await invokeAction(
            new DraftWorkReportAction(),
            makeRunParams(USER_ALICE, makeParams({ PersonID: 'not-a-uuid' })),
        );
        expect(res).toMatchObject({ Success: false, ResultCode: 'VALIDATION_ERROR' });
        expect(resolvePersonForUserMock).not.toHaveBeenCalled();
    });
});

describe('SubmitWorkReportAction & ReviewWorkReportAction (upgraded canonical ResultCodes)', () => {
    it('submits an author-owned Draft report and populates SupervisorRequestID, SupervisorNotified, and SupervisorName', async () => {
        resolvePersonForUserMock.mockResolvedValueOnce({ ID: PERSON_ALICE });
        submitWorkReportMock.mockResolvedValueOnce({
            Report: { ID: REPORT_ID, Status: 'Submitted' },
            Supervisor: {
                AuthorPersonID: PERSON_ALICE,
                AuthorDisplayName: 'Alice Ng',
                AuthorEmail: 'alice@example.com',
                AuthorUserID: USER_ALICE,
                EmployeeID: null,
                SupervisorEmployeeID: null,
                SupervisorEmail: 'bob@example.com',
                SupervisorUserID: USER_BOB,
                SupervisorPersonID: PERSON_BOB,
                SupervisorName: 'Bob Supervisor',
            },
            SupervisorRequestID: '88888888-8888-4888-8888-888888888888',
            SupervisorNotified: true,
        });

        const params = makeParams(
            { WorkReportID: REPORT_ID, Title: 'Updated Title', Body: 'Updated Body' },
            ['SupervisorRequestID', 'SupervisorNotified', 'SupervisorName'],
        );
        const res = await invokeAction(new SubmitWorkReportAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(params.find((p) => p.Name === 'SupervisorRequestID')?.Value).toBe(
            '88888888-8888-4888-8888-888888888888',
        );
        expect(params.find((p) => p.Name === 'SupervisorNotified')?.Value).toBe(true);
        expect(params.find((p) => p.Name === 'SupervisorName')?.Value).toBe('Bob Supervisor');
    });

    it('returns NO_PERSON_RECORD on SubmitWorkReportAction when caller has no resolved Person record', async () => {
        resolvePersonForUserMock.mockResolvedValueOnce(null);
        const res = await invokeAction(
            new SubmitWorkReportAction(),
            makeRunParams(USER_ALICE, makeParams({ WorkReportID: REPORT_ID })),
        );
        expect(res).toMatchObject({ Success: false, ResultCode: 'NO_PERSON_RECORD' });
        expect(submitWorkReportMock).not.toHaveBeenCalled();
    });

    it('maps service errors to PERMISSION_DENIED and NOT_FOUND in ReviewWorkReportAction', async () => {
        resolvePersonForUserMock.mockResolvedValueOnce({ ID: PERSON_CAROL });
        recordSupervisorReviewMock.mockRejectedValueOnce(
            new Error('Reviewer (33333333-3333-4333-8333-333333333333) is not the mapped supervisor for this report author'),
        );

        const permRes = await invokeAction(
            new ReviewWorkReportAction(),
            makeRunParams(USER_BOB, makeParams({ WorkReportID: REPORT_ID, SupervisorFeedback: 'Approved' })),
        );
        expect(permRes).toMatchObject({ Success: false, ResultCode: 'PERMISSION_DENIED' });

        resolvePersonForUserMock.mockResolvedValueOnce({ ID: PERSON_BOB });
        recordSupervisorReviewMock.mockRejectedValueOnce(new Error(`WorkReport '${REPORT_ID}' not found.`));
        const notFoundRes = await invokeAction(
            new ReviewWorkReportAction(),
            makeRunParams(USER_BOB, makeParams({ WorkReportID: REPORT_ID, SupervisorFeedback: 'Approved' })),
        );
        expect(notFoundRes).toMatchObject({ Success: false, ResultCode: 'NOT_FOUND' });
    });
});
