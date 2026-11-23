import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { RunViewParams, UserInfo } from '@memberjunction/core';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';

const ROOT_TASK_ID = '11111111-1111-4111-8111-111111111111';
const SUB_TASK_ID = '22222222-2222-4222-8222-222222222222';

interface MockTaskRecord {
    ID: string;
    ParentID: string | null;
    RootParentID: string | null;
    HealthStatus: mjBizAppsTasksTaskEntity['HealthStatus'];
    ConfidenceScore: number | null;
    ForecastCompletionDate: Date | null;
    LatestResult: { CompleteMessage: string };
    Load: ReturnType<typeof vi.fn<[string], Promise<boolean>>>;
    Save: ReturnType<typeof vi.fn<[], Promise<boolean>>>;
}

function createTaskMock(overrides: Partial<MockTaskRecord> = {}): MockTaskRecord {
    return {
        ID: ROOT_TASK_ID,
        ParentID: null,
        RootParentID: null,
        HealthStatus: 'OnTrack',
        ConfidenceScore: 80,
        ForecastCompletionDate: null,
        LatestResult: { CompleteMessage: 'Root task save refused' },
        Load: vi.fn<[string], Promise<boolean>>(async () => true),
        Save: vi.fn<[], Promise<boolean>>(async () => true),
        ...overrides,
    };
}

let rootTaskMock = createTaskMock();

const {
    baseSaveMock,
    commitMock,
    rollbackMock,
    runViewMock,
    getEntityObjectMock,
    beginTxMock,
    activeProvider,
} = vi.hoisted(() => {
    const baseSaveMock = vi.fn<[], Promise<boolean>>(async () => true);
    const commitMock = vi.fn<[], Promise<void>>(async () => undefined);
    const rollbackMock = vi.fn<[], Promise<void>>(async () => undefined);
    const runViewMock = vi.fn<
        [RunViewParams, UserInfo | undefined],
        Promise<{ Success: boolean; Results: Array<{ ID: string; AssessedAt: string | Date }> }>
    >();
    const getEntityObjectMock = vi.fn<[string, UserInfo | undefined], Promise<MockTaskRecord>>();
    const beginTxMock = vi.fn(async () => ({
        Commit: commitMock,
        Rollback: rollbackMock,
        IsNested: false,
    }));
    const activeProvider: {
        SupportsEntityTransactions?: boolean;
        BeginEntityTransaction?: typeof beginTxMock;
        GetEntityObject: typeof getEntityObjectMock;
        RunView: typeof runViewMock;
    } = {
        SupportsEntityTransactions: true,
        BeginEntityTransaction: beginTxMock,
        GetEntityObject: getEntityObjectMock,
        RunView: runViewMock,
    };
    return {
        baseSaveMock,
        commitMock,
        rollbackMock,
        runViewMock,
        getEntityObjectMock,
        beginTxMock,
        activeProvider,
    };
});

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
        BaseEntity: class {},
        RunView: class {
            private provider: typeof activeProvider;
            constructor(provider?: typeof activeProvider) {
                this.provider = provider ?? activeProvider;
            }
            RunView(params: RunViewParams, contextUser?: UserInfo) {
                return this.provider.RunView(params, contextUser);
            }
        },
        LogError: vi.fn(),
        Metadata: {
            Provider: {
                GetEntityObject: (entityName: string, contextUser?: UserInfo) =>
                    getEntityObjectMock(entityName, contextUser),
                RunView: (params: RunViewParams, contextUser?: UserInfo) => runViewMock(params, contextUser),
            },
        },
    };
});

vi.mock('@mj-biz-apps/tasks-entities', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@mj-biz-apps/tasks-entities')>();
    return {
        ...actual,
        mjBizAppsTasksTaskEntity: class {},
        TaskRiskAssessmentEntity: class {
            ID = 'assessment-1';
            TaskID = ROOT_TASK_ID;
            AssessedAt = new Date('2026-11-22T18:00:00.000Z');
            ForecastCompletionDate: Date | null = new Date('2026-12-15T00:00:00.000Z');
            ForecastConfidence: number | null = 72;
            HealthStatus: mjBizAppsTasksTaskEntity['HealthStatus'] = 'AtRisk';
            MLBreachProbability: number | null = 0.415;
            Risks = '[]';
            AgentRunID: string | null = '33333333-3333-4333-8333-333333333333';
            PromptTokens: number | null = 1200;
            CompletionTokens: number | null = 350;
            TotalCostUSD: number | null = 0.0185;
            ContextCurrentUser = { ID: 'user-owner-1' } as UserInfo;
            get ProviderToUse() {
                return activeProvider;
            }
            async Save() {
                return baseSaveMock();
            }
        },
    };
});

import { TaskRiskAssessmentEntityServer } from '../TaskRiskAssessmentEntityServer.js';

describe('TaskRiskAssessmentEntityServer', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        activeProvider.SupportsEntityTransactions = true;
        activeProvider.BeginEntityTransaction = beginTxMock;
        rootTaskMock = createTaskMock();
        getEntityObjectMock.mockImplementation(async () => rootTaskMock);
        baseSaveMock.mockResolvedValue(true);
        runViewMock.mockResolvedValue({ Success: true, Results: [] });
    });

    it('syncs HealthStatus, ConfidenceScore, and ForecastCompletionDate onto the linked root task inside a transaction', async () => {
        const assessment = new TaskRiskAssessmentEntityServer();
        assessment.HealthStatus = 'AtRisk';
        assessment.ForecastConfidence = 64;
        assessment.ForecastCompletionDate = new Date('2026-12-20T00:00:00.000Z');

        const ok = await assessment.Save();

        expect(ok).toBe(true);
        expect(beginTxMock).toHaveBeenCalledTimes(1);
        expect(baseSaveMock).toHaveBeenCalledTimes(1);
        expect(getEntityObjectMock).toHaveBeenCalledWith('MJ_BizApps_Tasks: Tasks', assessment.ContextCurrentUser);
        expect(rootTaskMock.Load).toHaveBeenCalledWith(ROOT_TASK_ID);
        expect(rootTaskMock.HealthStatus).toBe('AtRisk');
        expect(rootTaskMock.ConfidenceScore).toBe(64);
        expect(rootTaskMock.ForecastCompletionDate?.toISOString()).toBe('2026-12-20T00:00:00.000Z');
        expect(rootTaskMock.Save).toHaveBeenCalledTimes(1);
        expect(commitMock).toHaveBeenCalledTimes(1);
        expect(rollbackMock).not.toHaveBeenCalled();
    });

    it('resolves RootParentID when TaskID points to a child task before syncing', async () => {
        const childInstance = createTaskMock({ ID: SUB_TASK_ID, ParentID: ROOT_TASK_ID, RootParentID: ROOT_TASK_ID });
        const rootInstance = createTaskMock({ ID: ROOT_TASK_ID, ParentID: null, RootParentID: null });
        let callCount = 0;
        getEntityObjectMock.mockImplementation(async () => {
            callCount += 1;
            return callCount === 1 ? childInstance : rootInstance;
        });

        const assessment = new TaskRiskAssessmentEntityServer();
        assessment.TaskID = SUB_TASK_ID;
        assessment.HealthStatus = 'OffTrack';
        assessment.ForecastConfidence = 38;
        assessment.ForecastCompletionDate = new Date('2027-01-10T00:00:00.000Z');

        const ok = await assessment.Save();

        expect(ok).toBe(true);
        expect(childInstance.Load).toHaveBeenCalledWith(SUB_TASK_ID);
        expect(rootInstance.Load).toHaveBeenCalledWith(ROOT_TASK_ID);
        expect(rootInstance.HealthStatus).toBe('OffTrack');
        expect(rootInstance.ConfidenceScore).toBe(38);
        expect(rootInstance.ForecastCompletionDate?.toISOString()).toBe('2027-01-10T00:00:00.000Z');
        expect(rootInstance.Save).toHaveBeenCalledTimes(1);
        expect(childInstance.Save).not.toHaveBeenCalled();
    });

    it('does not overwrite root task when a newer assessment by AssessedAt already exists', async () => {
        runViewMock.mockResolvedValueOnce({
            Success: true,
            Results: [
                {
                    ID: 'newer-assessment-id',
                    AssessedAt: '2026-11-23T12:00:00.000Z',
                },
            ],
        });

        const assessment = new TaskRiskAssessmentEntityServer();
        assessment.ID = 'older-assessment-id';
        assessment.AssessedAt = new Date('2026-11-20T12:00:00.000Z');
        assessment.HealthStatus = 'OffTrack';
        assessment.ForecastConfidence = 20;

        const ok = await assessment.Save();

        expect(ok).toBe(true);
        expect(baseSaveMock).toHaveBeenCalledTimes(1);
        expect(rootTaskMock.Save).not.toHaveBeenCalled();
        expect(rootTaskMock.HealthStatus).toBe('OnTrack');
        expect(commitMock).toHaveBeenCalledTimes(1);
    });

    it('rolls back the transaction when root task save fails', async () => {
        rootTaskMock.Save.mockResolvedValueOnce(false);
        const assessment = new TaskRiskAssessmentEntityServer();

        await expect(assessment.Save()).rejects.toThrow(/Failed to sync task risk assessment/);
        expect(rollbackMock).toHaveBeenCalledTimes(1);
        expect(commitMock).not.toHaveBeenCalled();
    });

    it('rolls back without touching root task when super.Save() returns false', async () => {
        baseSaveMock.mockResolvedValueOnce(false);
        const assessment = new TaskRiskAssessmentEntityServer();

        const ok = await assessment.Save();

        expect(ok).toBe(false);
        expect(rootTaskMock.Save).not.toHaveBeenCalled();
        expect(rollbackMock).toHaveBeenCalledTimes(1);
        expect(commitMock).not.toHaveBeenCalled();
    });
});
