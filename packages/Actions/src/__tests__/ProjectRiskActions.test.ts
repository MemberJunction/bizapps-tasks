import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { ActionParam, ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import type { UserInfo } from '@memberjunction/core';
import {
    ProjectRiskAnalystRegistry,
    type ProjectRiskAssessmentRunResult,
    type ProjectRiskReviewDispatchInput,
} from '@mj-biz-apps/tasks-core';
import { SerializeTaskRiskItems } from '@mj-biz-apps/tasks-entities';

const {
    checkEntityAccessMock,
    maskRecordMock,
    maskRowsMock,
    resolvePersonForUserMock,
    runViewMock,
} = vi.hoisted(() => ({
    checkEntityAccessMock: vi.fn(),
    maskRecordMock: vi.fn(<T extends object>(rec: T, patterns: readonly string[]): T => {
        if (!patterns?.length) return rec;
        const copy = { ...rec } as Record<string, string | number | boolean | Date | null | undefined | object>;
        for (const p of patterns) delete copy[p];
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
    resolvePersonForUserMock: vi.fn(),
    runViewMock: vi.fn(),
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
vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    return {
        ...actual,
        LogError: vi.fn(),
        LogStatus: vi.fn(),
        Metadata: class {
            public static Provider = {
                Entities: [
                    { ID: 'e0000001-0000-4000-8000-000000000001', Name: 'MJ_BizApps_Common: People' },
                    { ID: 'e0000002-0000-4000-8000-000000000002', Name: 'MJ: Roles' },
                    { ID: 'e0000005-0000-4000-8000-000000000005', Name: 'MJ_BizApps_Tasks: Tasks' },
                ],
                GetEntityObject: vi.fn(),
            };
            public Entities = [];
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
    AgentUserPolicyEngine: {
        Instance: {
            GetEffectivePolicyAgentChain: () => [],
        },
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
vi.mock('@mj-biz-apps/tasks-core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@mj-biz-apps/tasks-core')>();
    return {
        ...actual,
        WorkReportService: {
            Instance: {
                ResolvePersonForUser: resolvePersonForUserMock,
            },
        },
    };
});

import {
    GET_PROJECT_RISK_ACTION_ID,
    GetProjectRiskAction,
    REQUEST_PROJECT_RISK_REVIEW_ACTION_ID,
    RequestProjectRiskReviewAction,
} from '../custom/ProjectRiskActions.js';

class TestableGetProjectRiskAction extends GetProjectRiskAction {
    public Run(params: RunActionParams): Promise<ActionResultSimple> {
        return this.InternalRunAction(params);
    }
}

class TestableRequestProjectRiskReviewAction extends RequestProjectRiskReviewAction {
    public Run(params: RunActionParams): Promise<ActionResultSimple> {
        return this.InternalRunAction(params);
    }
}

const ROOT_TASK_ID = '11111111-1111-4111-8111-111111111111';
const SUB_TASK_ID = '22222222-2222-4222-8222-222222222222';
const ASSESSMENT_ID_1 = '33333333-3333-4333-8333-333333333331';
const ASSESSMENT_ID_2 = '33333333-3333-4333-8333-333333333332';
const AGENT_RUN_ID = '44444444-4444-4444-8444-444444444444';
const OWNER_USER_ID = '55555555-5555-4555-8555-555555555555';
const CALLER_USER_ID = '66666666-6666-4666-8666-666666666666';
const CALLER_PERSON_ID = '77777777-7777-4777-8777-777777777777';
const OTHER_PERSON_ID = '88888888-8888-4888-8888-888888888888';

function makeParams(
    inputs: Record<string, string | number | boolean | null | undefined>,
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

function makeRunParams(userId: string, params: ActionParam[], roles: string[] = ['UI']): RunActionParams {
    return {
        ContextUser: {
            ID: userId,
            Email: 'caller@acme.test',
            UserRoles: roles.map((Role) => ({ Role, RoleID: 'e0000002-0000-4000-8000-000000000001' })),
        } as Partial<UserInfo> as UserInfo,
        Params: params,
    } as Partial<RunActionParams> as RunActionParams;
}

function readOutput<T>(result: ActionResultSimple, name: string): T | undefined {
    const p =
        result.Params?.find((item) => item.Name.toLowerCase() === name.toLowerCase() && item.Type !== 'Input') ??
        result.Params?.find((item) => item.Name.toLowerCase() === name.toLowerCase());
    return p?.Value as T | undefined;
}

function makeRootTaskRow(overrides: Record<string, string | number | Date | null> = {}) {
    return {
        ID: ROOT_TASK_ID,
        Name: 'ERP Cloud Migration',
        ParentID: null,
        RootParentID: null,
        Status: 'InProgress',
        Priority: 'High',
        Visibility: 'Standard',
        StartedAt: '2026-11-01T00:00:00.000Z',
        DueAt: '2026-12-31T00:00:00.000Z',
        PercentComplete: 45,
        CreatedByPersonID: OTHER_PERSON_ID,
        HealthStatus: 'AtRisk',
        ConfidenceScore: 67,
        ForecastCompletionDate: '2027-01-05T17:00:00.000Z',
        PredictedSLABreachProbability: 0.415,
        PredictedSLARiskBand: 'Medium',
        __mj_CreatedAt: '2026-11-01T00:00:00.000Z',
        ...overrides,
    };
}

describe('Project Risk Actions (GetProjectRiskAction & RequestProjectRiskReviewAction)', () => {
    let getAction: TestableGetProjectRiskAction;
    let requestAction: TestableRequestProjectRiskReviewAction;

    beforeEach(() => {
        vi.clearAllMocks();
        ProjectRiskAnalystRegistry.Instance.RegisterHandler(null);
        checkEntityAccessMock.mockResolvedValue({ Allowed: true, DeniedFieldPatterns: [] });
        resolvePersonForUserMock.mockResolvedValue({
            ID: CALLER_PERSON_ID,
            FullName: 'Caller User',
            Email: 'caller@acme.test',
        });
        getAction = new TestableGetProjectRiskAction();
        requestAction = new TestableRequestProjectRiskReviewAction();
    });

    it('exports canonical action IDs', () => {
        expect(GET_PROJECT_RISK_ACTION_ID).toMatch(/^[0-9A-F-]{36}$/);
        expect(REQUEST_PROJECT_RISK_REVIEW_ACTION_ID).toMatch(/^[0-9A-F-]{36}$/);
        expect(GET_PROJECT_RISK_ACTION_ID).not.toBe(REQUEST_PROJECT_RISK_REVIEW_ACTION_ID);
    });

    describe('GetProjectRiskAction', () => {
        it('rejects missing or invalid TaskID with VALIDATION_ERROR', async () => {
            const res = await getAction.Run(
                makeRunParams(CALLER_USER_ID, makeParams({ TaskID: 'not-a-uuid' })),
            );
            expect(res.Success).toBe(false);
            expect(res.ResultCode).toBe('VALIDATION_ERROR');
            expect(runViewMock).not.toHaveBeenCalled();
        });

        it('enforces Private task isolation via ContextUser before querying Task Risk Assessments', async () => {
            runViewMock.mockImplementation(async (params: { EntityName: string }) => {
                if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                    return {
                        Success: true,
                        Results: [makeRootTaskRow({ Visibility: 'Private', CreatedByPersonID: OTHER_PERSON_ID })],
                    };
                }
                if (params.EntityName === 'MJ_BizApps_Tasks: Task Assignments') {
                    return { Success: true, Results: [] };
                }
                throw new Error(`Unexpected query to ${params.EntityName} prior to authorization`);
            });

            const res = await getAction.Run(
                makeRunParams(CALLER_USER_ID, makeParams({ TaskID: ROOT_TASK_ID })),
            );
            expect(res.Success).toBe(false);
            expect(res.ResultCode).toBe('PERMISSION_DENIED');
        });

        it('returns deterministic NO_ASSESSMENT empty state when no prior assessment exists', async () => {
            runViewMock.mockImplementation(async (params: { EntityName: string }) => {
                if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                    return {
                        Success: true,
                        Results: [
                            makeRootTaskRow({
                                HealthStatus: null,
                                ConfidenceScore: null,
                                ForecastCompletionDate: null,
                            }),
                        ],
                    };
                }
                if (params.EntityName === 'MJ_BizApps_Tasks: Task Risk Assessments') {
                    return { Success: true, Results: [] };
                }
                return { Success: true, Results: [] };
            });

            const res = await getAction.Run(
                makeRunParams(CALLER_USER_ID, makeParams({ TaskID: ROOT_TASK_ID })),
            );
            expect(res.Success).toBe(true);
            expect(res.ResultCode).toBe('NO_ASSESSMENT');
            expect(readOutput<boolean>(res, 'HasAssessment')).toBe(false);
            expect(readOutput<string | null>(res, 'AssessmentID')).toBeNull();
            expect(JSON.parse(readOutput<string>(res, 'Risks') ?? 'null')).toEqual([]);
            expect(['Weekly', 'Daily']).toContain(readOutput<string>(res, 'Cadence'));
        });

        it('resolves a subtask to its root project task and returns typed latest assessment, history, and cadence', async () => {
            const risks1 = SerializeTaskRiskItems([
                {
                    kind: 'blocked_dependency',
                    severity: 'high',
                    evidenceLinks: [`/resource/record/MJ_BizApps_Tasks%3A%20Tasks/${SUB_TASK_ID}`],
                    suggestedMitigation: 'Escalate database cutover blocker.',
                },
            ]);
            const risks2 = SerializeTaskRiskItems([
                {
                    kind: 'schedule_slip',
                    severity: 'medium',
                    evidenceLinks: [`/resource/record/MJ_BizApps_Tasks%3A%20Tasks/${ROOT_TASK_ID}`],
                    suggestedMitigation: 'Rebalance QA staffing.',
                },
            ]);

            runViewMock.mockImplementation(
                async (params: { EntityName: string; ExtraFilter?: string; ResultType?: string }) => {
                    expect(params.ResultType).toBe('simple');
                    if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                        if (params.ExtraFilter?.includes(SUB_TASK_ID)) {
                            return {
                                Success: true,
                                Results: [
                                    makeRootTaskRow({
                                        ID: SUB_TASK_ID,
                                        Name: 'DB Cutover',
                                        ParentID: ROOT_TASK_ID,
                                        RootParentID: ROOT_TASK_ID,
                                    }),
                                ],
                            };
                        }
                        return { Success: true, Results: [makeRootTaskRow()] };
                    }
                    if (params.EntityName === 'MJ_BizApps_Tasks: Task Risk Assessments') {
                        return {
                            Success: true,
                            Results: [
                                {
                                    ID: ASSESSMENT_ID_1,
                                    TaskID: ROOT_TASK_ID,
                                    AssessedAt: '2026-11-22T10:00:00.000Z',
                                    ForecastCompletionDate: '2027-01-05T17:00:00.000Z',
                                    ForecastConfidence: 67,
                                    HealthStatus: 'AtRisk',
                                    MLBreachProbability: 0.415,
                                    Risks: risks1,
                                    AgentRunID: AGENT_RUN_ID,
                                    PromptTokens: 1400,
                                    CompletionTokens: 310,
                                    TotalCostUSD: 0.0392,
                                },
                                {
                                    ID: ASSESSMENT_ID_2,
                                    TaskID: ROOT_TASK_ID,
                                    AssessedAt: '2026-11-15T10:00:00.000Z',
                                    ForecastCompletionDate: '2026-12-30T17:00:00.000Z',
                                    ForecastConfidence: 78,
                                    HealthStatus: 'OnTrack',
                                    MLBreachProbability: 0.21,
                                    Risks: risks2,
                                    AgentRunID: AGENT_RUN_ID,
                                    PromptTokens: 1200,
                                    CompletionTokens: 280,
                                    TotalCostUSD: 0.031,
                                },
                            ],
                        };
                    }
                    return { Success: true, Results: [] };
                },
            );

            const res = await getAction.Run(
                makeRunParams(
                    CALLER_USER_ID,
                    makeParams({ TaskID: SUB_TASK_ID, IncludeHistory: true, HistoryLimit: 5 }),
                ),
            );
            expect(res.Success).toBe(true);
            expect(res.ResultCode).toBe('SUCCESS');
            expect(readOutput<boolean>(res, 'HasAssessment')).toBe(true);
            expect(readOutput<string>(res, 'TaskID')).toBe(ROOT_TASK_ID);
            expect(readOutput<string>(res, 'AssessmentID')).toBe(ASSESSMENT_ID_1);
            expect(readOutput<string>(res, 'HealthStatus')).toBe('AtRisk');
            expect(readOutput<number>(res, 'ForecastConfidence')).toBe(67);
            expect(readOutput<number>(res, 'MLBreachProbability')).toBe(0.415);
            expect(readOutput<string>(res, 'AgentRunID')).toBe(AGENT_RUN_ID);
            expect(readOutput<number>(res, 'PromptTokens')).toBe(1400);
            expect(readOutput<number>(res, 'CompletionTokens')).toBe(310);
            expect(readOutput<number>(res, 'TotalCostUSD')).toBe(0.0392);

            const parsedRisks = JSON.parse(readOutput<string>(res, 'Risks') ?? '[]') as Array<{
                kind: string;
                severity: string;
            }>;
            expect(parsedRisks).toHaveLength(1);
            expect(parsedRisks[0].kind).toBe('blocked_dependency');
            expect(parsedRisks[0].severity).toBe('high');

            const parsedHistory = JSON.parse(readOutput<string>(res, 'History') ?? '[]') as Array<{
                AssessmentID: string;
            }>;
            expect(parsedHistory.map((h) => h.AssessmentID)).toEqual([ASSESSMENT_ID_1, ASSESSMENT_ID_2]);
        });
    });

    describe('RequestProjectRiskReviewAction', () => {
        it('validates MLBreachProbability bounds and FreeBusyJSON syntax before calling analyst registry', async () => {
            const badProb = await requestAction.Run(
                makeRunParams(CALLER_USER_ID, makeParams({ TaskID: ROOT_TASK_ID, MLBreachProbability: 1.5 })),
            );
            expect(badProb.Success).toBe(false);
            expect(badProb.ResultCode).toBe('VALIDATION_ERROR');

            const badJson = await requestAction.Run(
                makeRunParams(CALLER_USER_ID, makeParams({ TaskID: ROOT_TASK_ID, FreeBusyJSON: '{bad json' })),
            );
            expect(badJson.Success).toBe(false);
            expect(badJson.ResultCode).toBe('VALIDATION_ERROR');
        });

        it('verifies caller permissions before switching execution context to project owner via ProjectRiskAnalystRegistry', async () => {
            const handlerSpy = vi.fn<[ProjectRiskReviewDispatchInput], Promise<ProjectRiskAssessmentRunResult>>();
            ProjectRiskAnalystRegistry.Instance.RegisterHandler(handlerSpy);

            runViewMock.mockImplementation(async (params: { EntityName: string }) => {
                if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                    return {
                        Success: true,
                        Results: [makeRootTaskRow({ Visibility: 'Private', CreatedByPersonID: OTHER_PERSON_ID })],
                    };
                }
                return { Success: true, Results: [] };
            });

            const denied = await requestAction.Run(
                makeRunParams(CALLER_USER_ID, makeParams({ TaskID: ROOT_TASK_ID })),
            );
            expect(denied.Success).toBe(false);
            expect(denied.ResultCode).toBe('PERMISSION_DENIED');
            expect(handlerSpy).not.toHaveBeenCalled();
        });

        it('dispatches review through ProjectRiskAnalystRegistry with ML breach and free/busy overrides and returns synced root rollup', async () => {
            let capturedDispatch: ProjectRiskReviewDispatchInput | null = null;
            let reviewCompleted = false;

            ProjectRiskAnalystRegistry.Instance.RegisterHandler(async (input) => {
                capturedDispatch = input;
                reviewCompleted = true;
                return {
                    Skipped: false,
                    SkipReason: null,
                    TaskID: input.TaskID,
                    OwnerUserID: OWNER_USER_ID,
                    AssessmentID: ASSESSMENT_ID_1,
                    AssessedAt: new Date('2026-11-22T12:00:00.000Z'),
                    HealthStatus: 'OffTrack',
                    ForecastCompletionDate: new Date('2027-01-12T17:00:00.000Z'),
                    ForecastConfidence: 52,
                    MLBreachProbability: input.MLBreachSignalOverride?.Probability ?? 0.81,
                    Risks: [
                        {
                            kind: 'capacity_crunch',
                            severity: 'critical',
                            evidenceLinks: [`/resource/record/MJ_BizApps_Tasks%3A%20Tasks/${ROOT_TASK_ID}`],
                            suggestedMitigation: 'De-scope non-critical integrations.',
                        },
                    ],
                    Summary: 'High ML breach probability and tight calendar capacity push project off track.',
                    AgentRunID: AGENT_RUN_ID,
                    PromptTokens: 1620,
                    CompletionTokens: 410,
                    TotalCostUSD: 0.0512,
                    Cadence: {
                        Cadence: 'Daily',
                        IntervalHours: 24,
                        ElapsedRatio: 0.85,
                        RemainingRatio: 0.15,
                        IsFinal20Percent: true,
                        IsOverdue: false,
                        Reason: 'Final20Percent',
                        ShouldSkipScheduledRun: false,
                        SkipReason: null,
                        NextDueAt: new Date('2026-11-23T12:00:00.000Z'),
                    },
                    Evidence: null,
                };
            });

            runViewMock.mockImplementation(async (params: { EntityName: string }) => {
                if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                    return {
                        Success: true,
                        Results: [
                            reviewCompleted
                                ? makeRootTaskRow({
                                      HealthStatus: 'OffTrack',
                                      ConfidenceScore: 52,
                                      ForecastCompletionDate: '2027-01-12T17:00:00.000Z',
                                  })
                                : makeRootTaskRow(),
                        ],
                    };
                }
                return { Success: true, Results: [] };
            });

            const res = await requestAction.Run(
                makeRunParams(
                    CALLER_USER_ID,
                    makeParams({
                        TaskID: ROOT_TASK_ID,
                        MLBreachProbability: 0.81,
                        MLBreachRiskBand: 'Critical',
                        FreeBusyJSON: JSON.stringify([
                            {
                                PersonID: OTHER_PERSON_ID,
                                Slots: [
                                    {
                                        StartTime: '2026-11-23T09:00:00.000Z',
                                        EndTime: '2026-11-23T13:00:00.000Z',
                                        Status: 'Busy',
                                        Subject: 'Private HR Meeting',
                                    },
                                ],
                            },
                        ]),
                    }),
                ),
            );

            expect(res.Success).toBe(true);
            expect(res.ResultCode).toBe('SUCCESS');
            expect(capturedDispatch).not.toBeNull();
            expect(capturedDispatch!.TaskID).toBe(ROOT_TASK_ID);
            expect(capturedDispatch!.Force).toBe(true);
            expect(capturedDispatch!.MLBreachSignalOverride?.Probability).toBe(0.81);
            expect(capturedDispatch!.MLBreachSignalOverride?.RiskBand).toBe('Critical');
            expect(capturedDispatch!.FreeBusyOverrides).toHaveLength(1);

            expect(readOutput<string>(res, 'AssessmentID')).toBe(ASSESSMENT_ID_1);
            expect(readOutput<string>(res, 'OwnerUserID')).toBe(OWNER_USER_ID);
            expect(readOutput<string>(res, 'HealthStatus')).toBe('OffTrack');
            expect(readOutput<number>(res, 'ForecastConfidence')).toBe(52);
            expect(readOutput<number>(res, 'MLBreachProbabilityOutput')).toBe(0.81);
            expect(readOutput<number>(res, 'MLBreachProbability')).toBe(0.81);
            expect(readOutput<string>(res, 'Cadence')).toBe('Daily');

            const rootTaskOut = JSON.parse(readOutput<string>(res, 'RootTask') ?? '{}') as {
                HealthStatus: string;
                ConfidenceScore: number;
                ForecastCompletionDateISO: string;
            };
            expect(rootTaskOut.HealthStatus).toBe('OffTrack');
            expect(rootTaskOut.ConfidenceScore).toBe(52);
            expect(rootTaskOut.ForecastCompletionDateISO).toBe('2027-01-12T17:00:00.000Z');
        });

        it('populates MLBreachProbabilityOutput without mutating Input params of the same name', async () => {
            ProjectRiskAnalystRegistry.Instance.RegisterHandler(async () => ({
                Skipped: false,
                SkipReason: null,
                TaskID: ROOT_TASK_ID,
                OwnerUserID: OWNER_USER_ID,
                AssessmentID: ASSESSMENT_ID_1,
                AssessedAt: new Date('2026-11-22T12:00:00.000Z'),
                HealthStatus: 'AtRisk',
                ForecastCompletionDate: new Date('2027-01-10T17:00:00.000Z'),
                ForecastConfidence: 68,
                MLBreachProbability: 0.35,
                Risks: [],
                Summary: 'Assessed.',
                AgentRunID: AGENT_RUN_ID,
                PromptTokens: 900,
                CompletionTokens: 200,
                TotalCostUSD: 0.02,
                Cadence: {
                    Cadence: 'Weekly',
                    IntervalHours: 168,
                    ElapsedRatio: 0.3,
                    RemainingRatio: 0.7,
                    IsFinal20Percent: false,
                    IsOverdue: false,
                    Reason: 'First80Percent',
                    ShouldSkipScheduledRun: false,
                    SkipReason: null,
                    NextDueAt: new Date('2026-11-29T12:00:00.000Z'),
                },
                Evidence: null,
            }));

            runViewMock.mockImplementation(async (params: { EntityName: string; ExtraFilter?: string }) => {
                if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                    if (params.ExtraFilter?.includes(SUB_TASK_ID)) {
                        return {
                            Success: true,
                            Results: [
                                makeRootTaskRow({
                                    ID: SUB_TASK_ID,
                                    ParentID: ROOT_TASK_ID,
                                    RootParentID: ROOT_TASK_ID,
                                }),
                            ],
                        };
                    }
                    return { Success: true, Results: [makeRootTaskRow()] };
                }
                return { Success: true, Results: [] };
            });

            const res = await requestAction.Run(
                makeRunParams(
                    CALLER_USER_ID,
                    makeParams(
                        {
                            TaskID: SUB_TASK_ID,
                            MLBreachProbability: 0.81,
                        },
                        ['MLBreachProbabilityOutput', 'AssessmentID'],
                    ),
                ),
            );

            expect(res.Success).toBe(true);
            expect(readOutput<number>(res, 'MLBreachProbabilityOutput')).toBe(0.35);
            expect(readOutput<number>(res, 'MLBreachProbability')).toBe(0.35);
            expect(readOutput<string>(res, 'TaskID')).toBe(ROOT_TASK_ID);

            const inputProbParam = res.Params?.find(
                (p) => p.Name === 'MLBreachProbability' && p.Type === 'Input',
            );
            const inputTaskParam = res.Params?.find((p) => p.Name === 'TaskID' && p.Type === 'Input');
            expect(inputProbParam?.Value).toBe(0.81);
            expect(inputTaskParam?.Value).toBe(SUB_TASK_ID);
        });

        it('enforces policy field masking on RootTask and assessment fields in RequestProjectRiskReviewAction', async () => {
            checkEntityAccessMock.mockImplementation(async (input: { entityName: string }) => {
                if (input.entityName === 'MJ_BizApps_Tasks: Tasks') {
                    return {
                        Allowed: true,
                        DeniedFieldPatterns: ['PredictedSLABreachProbability', 'ConfidenceScore'],
                    };
                }
                if (input.entityName === 'MJ_BizApps_Tasks: Task Risk Assessments') {
                    return {
                        Allowed: true,
                        DeniedFieldPatterns: ['TotalCostUSD', 'MLBreachProbability'],
                    };
                }
                return { Allowed: true, DeniedFieldPatterns: [] };
            });

            ProjectRiskAnalystRegistry.Instance.RegisterHandler(async () => ({
                Skipped: false,
                SkipReason: null,
                TaskID: ROOT_TASK_ID,
                OwnerUserID: OWNER_USER_ID,
                AssessmentID: ASSESSMENT_ID_1,
                AssessedAt: new Date('2026-11-22T12:00:00.000Z'),
                HealthStatus: 'AtRisk',
                ForecastCompletionDate: new Date('2027-01-05T17:00:00.000Z'),
                ForecastConfidence: 67,
                MLBreachProbability: 0.415,
                Risks: [],
                Summary: 'Assessed.',
                AgentRunID: AGENT_RUN_ID,
                PromptTokens: 1200,
                CompletionTokens: 300,
                TotalCostUSD: 0.041,
                Cadence: {
                    Cadence: 'Weekly',
                    IntervalHours: 168,
                    ElapsedRatio: 0.3,
                    RemainingRatio: 0.7,
                    IsFinal20Percent: false,
                    IsOverdue: false,
                    Reason: 'First80Percent',
                    ShouldSkipScheduledRun: false,
                    SkipReason: null,
                    NextDueAt: new Date('2026-11-29T12:00:00.000Z'),
                },
                Evidence: null,
            }));

            runViewMock.mockImplementation(async (params: { EntityName: string }) => {
                if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                    return { Success: true, Results: [makeRootTaskRow()] };
                }
                return { Success: true, Results: [] };
            });

            const res = await requestAction.Run(
                makeRunParams(CALLER_USER_ID, makeParams({ TaskID: ROOT_TASK_ID })),
            );

            expect(res.Success).toBe(true);
            expect(readOutput<number | null>(res, 'MLBreachProbabilityOutput')).toBeNull();
            expect(readOutput<number | null>(res, 'TotalCostUSD')).toBeNull();
            expect(readOutput<number>(res, 'PromptTokens')).toBe(1200);

            const rootTaskOut = JSON.parse(readOutput<string>(res, 'RootTask') ?? '{}') as Record<string, unknown>;
            expect(rootTaskOut).not.toHaveProperty('PredictedSLABreachProbability');
            expect(rootTaskOut).not.toHaveProperty('ConfidenceScore');
            expect(rootTaskOut).toHaveProperty('HealthStatus', 'AtRisk');

            const assessmentOut = JSON.parse(readOutput<string>(res, 'Assessment') ?? '{}') as {
                TotalCostUSD: number | null;
                MLBreachProbability: number | null;
                RootTask: Record<string, unknown>;
            };
            expect(assessmentOut.TotalCostUSD).toBeNull();
            expect(assessmentOut.MLBreachProbability).toBeNull();
            expect(assessmentOut.RootTask).not.toHaveProperty('PredictedSLABreachProbability');
            expect(assessmentOut.RootTask).not.toHaveProperty('ConfidenceScore');
        });
    });
});
