import { describe, it, expect, beforeEach, vi } from 'vitest';
import type { ActionParam, ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import type { UserInfo } from '@memberjunction/core';

const {
    resolvePersonForUserMock,
    draftWorkReportMock,
    submitWorkReportMock,
    recordSupervisorReviewMock,
} = vi.hoisted(() => ({
    resolvePersonForUserMock: vi.fn(),
    draftWorkReportMock: vi.fn(),
    submitWorkReportMock: vi.fn(),
    recordSupervisorReviewMock: vi.fn(),
}));

vi.mock('@memberjunction/actions-base', () => ({}));
vi.mock('@memberjunction/actions', () => ({ BaseAction: class {} }));
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
    action: DraftWorkReportAction | SubmitWorkReportAction | ReviewWorkReportAction,
    params: RunActionParams,
): Promise<ActionResultSimple> {
    return (action as Partial<InvokableAction> as InvokableAction).InternalRunAction(params);
}

beforeEach(() => {
    vi.clearAllMocks();
});

describe('WorkReportActions metadata & AuthorizesCaller', () => {
    it('declares AuthorizesCaller = true and exports UUIDv4 action IDs', () => {
        expect(DraftWorkReportAction.AuthorizesCaller).toBe(true);
        expect(SubmitWorkReportAction.AuthorizesCaller).toBe(true);
        expect(ReviewWorkReportAction.AuthorizesCaller).toBe(true);
        expect(DRAFT_WORK_REPORT_ACTION_ID).toMatch(/^[0-9a-f-]{36}$/i);
        expect(SUBMIT_WORK_REPORT_ACTION_ID).toMatch(/^[0-9a-f-]{36}$/i);
        expect(REVIEW_WORK_REPORT_ACTION_ID).toMatch(/^[0-9a-f-]{36}$/i);
    });
});

describe('DraftWorkReportAction', () => {
    it('returns NO_ACTIVITY without writing a draft when WorkReportService reports SkippedNoActivity', async () => {
        resolvePersonForUserMock.mockResolvedValueOnce({ ID: PERSON_ALICE });
        draftWorkReportMock.mockResolvedValueOnce({
            Report: null,
            Items: [],
            SkippedNoActivity: true,
            ReusedExistingDraft: false,
            GeneratedBody: '',
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
            ReusedExistingDraft: false,
            GeneratedBody: '### Completed\n- **Ship IS-A SubtypeSelector**',
        });

        const params = makeParams({ PersonID: PERSON_ALICE }, ['WorkReportID']);
        const res = await invokeAction(new DraftWorkReportAction(), makeRunParams(USER_ALICE, params));

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(params.find((p) => p.Name === 'WorkReportID')?.Value).toBe(REPORT_ID);
        expect(draftWorkReportMock).toHaveBeenCalledWith(
            expect.objectContaining({
                PersonID: PERSON_ALICE,
                PeriodStart: expect.any(Date),
                PeriodEnd: expect.any(Date),
            }),
        );
    });

    it('fails closed when ContextUser cannot be resolved to a Person or attempts to draft for another Person', async () => {
        resolvePersonForUserMock.mockResolvedValueOnce(null);
        const noPersonRes = await invokeAction(
            new DraftWorkReportAction(),
            makeRunParams(USER_ALICE, makeParams({ PersonID: PERSON_ALICE })),
        );
        expect(noPersonRes.Success).toBe(false);
        expect(noPersonRes.Message).toMatch(/No active Person record/i);

        resolvePersonForUserMock.mockResolvedValueOnce({ ID: PERSON_BOB });
        const crossPersonRes = await invokeAction(
            new DraftWorkReportAction(),
            makeRunParams(USER_BOB, makeParams({ PersonID: PERSON_ALICE })),
        );
        expect(crossPersonRes.Success).toBe(false);
        expect(crossPersonRes.Message).toMatch(/Only the report author/i);
        expect(draftWorkReportMock).not.toHaveBeenCalled();
    });

    it('rejects non-UUID PersonID before running queries', async () => {
        const res = await invokeAction(
            new DraftWorkReportAction(),
            makeRunParams(USER_ALICE, makeParams({ PersonID: 'not-a-uuid' })),
        );
        expect(res.Success).toBe(false);
        expect(resolvePersonForUserMock).not.toHaveBeenCalled();
    });
});

describe('SubmitWorkReportAction & ReviewWorkReportAction', () => {
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

    it('fails closed on SubmitWorkReportAction when caller has no resolved Person record', async () => {
        resolvePersonForUserMock.mockResolvedValueOnce(null);
        const res = await invokeAction(
            new SubmitWorkReportAction(),
            makeRunParams(USER_ALICE, makeParams({ WorkReportID: REPORT_ID })),
        );
        expect(res.Success).toBe(false);
        expect(res.Message).toMatch(/No active Person record/i);
        expect(submitWorkReportMock).not.toHaveBeenCalled();
    });

    it('rejects ReviewWorkReportAction when ContextUser is not the mapped supervisor or when no supervisor resolves', async () => {
        resolvePersonForUserMock.mockResolvedValueOnce({ ID: PERSON_CAROL });
        recordSupervisorReviewMock.mockRejectedValueOnce(
            new Error('Reviewer (33333333-3333-4333-8333-333333333333) is not the mapped supervisor for this report author'),
        );

        const res = await invokeAction(
            new ReviewWorkReportAction(),
            makeRunParams(USER_BOB, makeParams({ WorkReportID: REPORT_ID, SupervisorFeedback: 'Approved' })),
        );

        expect(res.Success).toBe(false);
        expect(res.Message).toContain('mapped supervisor');
    });
});
