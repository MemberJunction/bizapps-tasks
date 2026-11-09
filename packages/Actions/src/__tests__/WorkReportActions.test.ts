import { describe, it, expect, beforeEach, vi } from 'vitest';

const { runViewMock, getEntityObjectMock } = vi.hoisted(() => ({
    runViewMock: vi.fn(),
    getEntityObjectMock: vi.fn(),
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
vi.mock('@memberjunction/core', () => ({
    RunView: class {
        RunView = runViewMock;
    },
    Metadata: class {
        Entities = [
            { ID: '99999999-9999-4999-8999-999999999992', Name: 'MJ_BizApps_Common: People', ParentChain: [] },
            { ID: '99999999-9999-4999-8999-999999999993', Name: 'MJ: AI Agent Requests', ParentChain: [] },
        ];
        GetEntityObject = getEntityObjectMock;
    },
}));

import {
    DraftWorkReportAction,
    SubmitWorkReportAction,
    ReviewWorkReportAction,
} from '../custom/WorkReportActions.js';

interface ActionTestParam {
    Name: string;
    Value: unknown;
    Type: 'Input' | 'Output' | 'Both';
}

interface ActionTestResult {
    Success: boolean;
    ResultCode: string;
    Message?: string;
}

interface InvokableAction {
    InternalRunAction(params: {
        ContextUser?: { ID: string; Email?: string };
        Params: ActionTestParam[];
    }): Promise<ActionTestResult>;
}

interface FakeEntityState {
    [key: string]: unknown;
}

function createFakeEntity(initial: FakeEntityState = {}) {
    const state: FakeEntityState = { ...initial };
    const target = {
        state,
        NewRecord: vi.fn(() => {
            if (!state['ID']) {
                state['ID'] = 'aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee';
            }
        }),
        Load: vi.fn(async (id: string) => {
            state['ID'] = id;
            return true;
        }),
        Save: vi.fn(async () => true),
        LatestResult: { CompleteMessage: 'Mock validation error' },
    };
    return new Proxy(target, {
        get(obj, prop, receiver) {
            if (typeof prop === 'string' && prop in obj) return Reflect.get(obj, prop, receiver);
            if (typeof prop === 'string') return state[prop];
            return Reflect.get(obj, prop, receiver);
        },
        set(obj, prop, value, receiver) {
            if (typeof prop === 'string' && !(prop in obj)) {
                state[prop] = value;
                return true;
            }
            return Reflect.set(obj, prop, value, receiver);
        },
    });
}

const USER_ALICE = 'aaaa1111-1111-4111-8111-111111111111';
const USER_BOB = 'bbbb2222-2222-4222-8222-222222222222';
const PERSON_ALICE = '11111111-1111-4111-8111-111111111111';
const PERSON_BOB = '22222222-2222-4222-8222-222222222222';
const PERSON_CAROL = '33333333-3333-4333-8333-333333333333';
const EMP_ALICE = 'eeee1111-1111-4111-8111-111111111111';
const EMP_BOB = 'eeee2222-2222-4222-8222-222222222222';
const REPORT_ID = '44444444-4444-4444-8444-444444444444';
const TASK_DONE = '55555555-5555-4555-8555-555555555551';
const AGENT_COS = '77777777-7777-4777-8777-777777777777';

function makeParams(inputs: Record<string, unknown>, outputs: string[] = []): ActionTestParam[] {
    return [
        ...Object.entries(inputs).map(([Name, Value]) => ({ Name, Value, Type: 'Input' as const })),
        ...outputs.map((Name) => ({ Name, Value: undefined, Type: 'Output' as const })),
    ];
}

beforeEach(() => {
    vi.clearAllMocks();
});

describe('DraftWorkReportAction', () => {
    it('returns NO_ACTIVITY without writing a draft when no tasks changed in the window', async () => {
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [] }) // assignments
            .mockResolvedValueOnce({ Success: true, Results: [] }); // tasks

        const params = makeParams(
            {
                PersonID: PERSON_ALICE,
                PeriodStart: '2026-11-09T00:00:00.000Z',
                PeriodEnd: '2026-11-09T23:59:59.000Z',
            },
            ['WorkReportID'],
        );
        const action = new DraftWorkReportAction() as unknown as InvokableAction;
        const res = await action.InternalRunAction({
            ContextUser: { ID: USER_ALICE },
            Params: params,
        });

        expect(res).toMatchObject({ Success: true, ResultCode: 'NO_ACTIVITY' });
        expect(params.find((p) => p.Name === 'WorkReportID')?.Value).toBe('');
        expect(getEntityObjectMock).not.toHaveBeenCalled();
    });

    it('creates a Draft WorkReport + WorkReportItem and populates WorkReportID output', async () => {
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ TaskID: TASK_DONE }] })
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    {
                        ID: TASK_DONE,
                        Name: 'Ship IS-A SubtypeSelector',
                        Status: 'Completed',
                        PercentComplete: 100,
                        HoursActual: 4,
                        HealthStatus: 'OnTrack',
                        DueAt: null,
                        CompletedAt: '2026-11-09T12:00:00.000Z',
                        __mj_UpdatedAt: '2026-11-09T12:00:00.000Z',
                    },
                ],
            });

        const reportEntity = createFakeEntity({ ID: REPORT_ID });
        const itemEntity = createFakeEntity({ ID: '66666666-6666-4666-8666-666666666661' });
        getEntityObjectMock.mockImplementation(async (name: string) =>
            name === 'MJ_BizApps_Tasks: Work Reports' ? reportEntity : itemEntity,
        );

        const params = makeParams(
            {
                PersonID: PERSON_ALICE,
                PeriodStart: '2026-11-09T00:00:00.000Z',
                PeriodEnd: '2026-11-09T23:59:59.000Z',
            },
            ['WorkReportID'],
        );
        const action = new DraftWorkReportAction() as unknown as InvokableAction;
        const res = await action.InternalRunAction({
            ContextUser: { ID: USER_ALICE },
            Params: params,
        });

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(params.find((p) => p.Name === 'WorkReportID')?.Value).toBe(REPORT_ID);
        expect(reportEntity.state['Status']).toBe('Draft');
        expect(String(reportEntity.state['Body'])).toContain('Ship IS-A SubtypeSelector');
    });

    it('rejects non-UUID PersonID before running queries', async () => {
        const action = new DraftWorkReportAction() as unknown as InvokableAction;
        const res = await action.InternalRunAction({
            ContextUser: { ID: USER_ALICE },
            Params: makeParams({ PersonID: 'not-a-uuid' }),
        });

        expect(res.Success).toBe(false);
        expect(runViewMock).not.toHaveBeenCalled();
    });
});

describe('SubmitWorkReportAction & ReviewWorkReportAction', () => {
    it('submits an author-owned Draft report and creates a supervisor review AI Agent Request', async () => {
        const reportEntity = createFakeEntity({
            ID: REPORT_ID,
            PersonID: PERSON_ALICE,
            Status: 'Draft',
            Title: 'Daily 15Five — 2026-11-09',
            Body: '### Completed\n- **Work Bus**',
        });
        const reqEntity = createFakeEntity({ ID: '88888888-8888-4888-8888-888888888888' });
        getEntityObjectMock.mockImplementation(async (name: string) =>
            name === 'MJ_BizApps_Tasks: Work Reports' ? reportEntity : reqEntity,
        );

        runViewMock
            // resolveCallerPersonID
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: PERSON_ALICE }] })
            // resolveSupervisorForPerson (5 queries)
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: PERSON_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', LinkedUserID: USER_ALICE }],
            })
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: EMP_ALICE, SupervisorID: EMP_BOB, Active: 1 }],
            })
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: EMP_BOB, Email: 'bob@example.com' }],
            })
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: USER_BOB }],
            })
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: PERSON_BOB }],
            })
            // Chief of Staff agent lookup
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: AGENT_COS }],
            });

        const params = makeParams({ WorkReportID: REPORT_ID }, ['SupervisorRequestID']);
        const action = new SubmitWorkReportAction() as unknown as InvokableAction;
        const res = await action.InternalRunAction({
            ContextUser: { ID: USER_ALICE },
            Params: params,
        });

        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(reportEntity.state['Status']).toBe('Submitted');
        expect(params.find((p) => p.Name === 'SupervisorRequestID')?.Value).toBe('88888888-8888-4888-8888-888888888888');
    });

    it('rejects ReviewWorkReportAction when ContextUser is not the mapped supervisor', async () => {
        const reportEntity = createFakeEntity({
            ID: REPORT_ID,
            PersonID: PERSON_ALICE,
            Status: 'Submitted',
        });
        getEntityObjectMock.mockResolvedValueOnce(reportEntity);

        runViewMock
            // resolveCallerPersonID -> Carol (not Alice's supervisor)
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: PERSON_CAROL }] })
            // resolveSupervisorForPerson -> Bob IS Alice's supervisor
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: PERSON_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', LinkedUserID: USER_ALICE }],
            })
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: EMP_ALICE, SupervisorID: EMP_BOB, Active: 1 }],
            })
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: EMP_BOB, Email: 'bob@example.com' }],
            })
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: USER_BOB }],
            })
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: PERSON_BOB }],
            });

        const action = new ReviewWorkReportAction() as unknown as InvokableAction;
        const res = await action.InternalRunAction({
            ContextUser: { ID: USER_BOB },
            Params: makeParams({ WorkReportID: REPORT_ID, SupervisorFeedback: 'Approved' }),
        });

        expect(res.Success).toBe(false);
        expect(res.Message).toContain('mapped supervisor');
    });
});
