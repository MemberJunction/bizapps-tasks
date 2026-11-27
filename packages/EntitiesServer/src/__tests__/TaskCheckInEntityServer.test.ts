import { describe, it, expect, beforeEach, vi } from 'vitest';
import { EnterTaskCheckInGraphScope } from '../composite-graph-scope.js';

const TASK_ID = '11111111-1111-4111-8111-111111111111';

const parentTaskMock = {
  ID: TASK_ID,
  BaselineValue: 10,
  TargetValue: 50,
  CurrentValue: 20,
  MetricDirection: 'Increase' as const,
  PercentComplete: 25,
  HealthStatus: 'OnTrack' as 'OnTrack' | 'AtRisk' | 'OffTrack' | 'Completed' | 'Paused' | null,
  ConfidenceScore: 80 as number | null,
  CheckInCadence: 'Weekly' as const,
  LastCheckInAt: null as Date | null,
  NextCheckInDueAt: null as Date | null,
  LatestResult: { CompleteMessage: 'Parent save refused' },
  Load: vi.fn(async () => true),
  Save: vi.fn(async () => true),
};

const baseSaveMock = vi.fn(async () => true);
const commitMock = vi.fn(async () => undefined);
const rollbackMock = vi.fn(async () => undefined);
const globalGetEntityObjectMock = vi.fn(async () => parentTaskMock);
const providerGetEntityObjectMock = vi.fn(async () => parentTaskMock);
const beginTxMock = vi.fn(async () => ({
  Commit: commitMock,
  Rollback: rollbackMock,
  IsNested: false,
}));

const activeProvider: {
  SupportsEntityTransactions?: boolean;
  BeginEntityTransaction?: typeof beginTxMock;
  GetEntityObject: typeof providerGetEntityObjectMock;
} = {
  SupportsEntityTransactions: true,
  BeginEntityTransaction: beginTxMock,
  GetEntityObject: providerGetEntityObjectMock,
};

vi.mock('@memberjunction/global', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@memberjunction/global')>();
  return {
    ...actual,
    RegisterClass: () => () => {},
  };
});

vi.mock('@memberjunction/core', async (importOriginal) => ({ ...(await importOriginal<typeof import('@memberjunction/core')>()),
  BaseEntity: class {},
  BaseEngine: class {
    public static getInstance() {
      return {};
    }
  },
  RegisterForStartup: () => () => {},
  BaseRemotableOperation: class {},
  LogError: vi.fn(),
  Metadata: {
    Provider: {
      GetEntityObject: (...args: unknown[]) => globalGetEntityObjectMock(...args),
    },
  },
}));

vi.mock('@mj-biz-apps/common-entities', () => ({
  BusinessTimeZoneEngine: { Instance: {} },
}));

vi.mock('@memberjunction/core-entities', () => ({
  ApplicationSettingEngine: { Instance: {} },
}));

vi.mock('@mj-biz-apps/tasks-entities', () => ({
  mjBizAppsTasksTaskEntity: class {},
  mjBizAppsTasksTaskCheckInEntity: class {
    ID = 'checkin-1';
    TaskID = TASK_ID;
    CheckInAt = new Date('2026-10-17T12:00:00.000Z');
    HealthStatus: 'OnTrack' | 'AtRisk' | 'OffTrack' | 'Completed' | 'Paused' = 'OnTrack';
    ConfidenceScore: number | null = null;
    PreviousValue: number | null = null;
    NewValue: number | null = null;
    PercentComplete: number | null = null;
    Summary = '';
    ContextCurrentUser = { ID: 'user-1' };
    get ProviderToUse() {
      return activeProvider;
    }
    async Save() {
      return baseSaveMock();
    }
  },
}));

import { TaskCheckInEntityServer } from '../TaskCheckInEntityServer.js';

describe('TaskCheckInEntityServer', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    activeProvider.SupportsEntityTransactions = true;
    activeProvider.BeginEntityTransaction = beginTxMock;
    parentTaskMock.BaselineValue = 10;
    parentTaskMock.TargetValue = 50;
    parentTaskMock.CurrentValue = 20;
    parentTaskMock.MetricDirection = 'Increase';
    parentTaskMock.PercentComplete = 25;
    parentTaskMock.HealthStatus = 'OnTrack';
    parentTaskMock.ConfidenceScore = 80;
    parentTaskMock.CheckInCadence = 'Weekly';
    parentTaskMock.LastCheckInAt = null;
    parentTaskMock.NextCheckInDueAt = null;
    parentTaskMock.Save.mockResolvedValue(true);
    baseSaveMock.mockResolvedValue(true);
  });

  it('uses ProviderToUse, wraps standalone save + parent sync in BeginEntityTransaction(), and commits on success', async () => {
    const checkIn = new TaskCheckInEntityServer();
    checkIn.HealthStatus = 'AtRisk';
    checkIn.ConfidenceScore = 65;
    checkIn.NewValue = 30; // halfway between 10 and 50 -> 50%
    checkIn.Summary = 'Pipeline progressed to 30, watching enterprise deal slippage';

    const ok = await checkIn.Save();
    expect(ok).toBe(true);

    // Used ProviderToUse, never fell back to global Metadata.Provider
    expect(providerGetEntityObjectMock).toHaveBeenCalledWith('MJ_BizApps_Tasks: Tasks', checkIn.ContextCurrentUser);
    expect(globalGetEntityObjectMock).not.toHaveBeenCalled();

    // Wrapped in BeginEntityTransaction and committed
    expect(beginTxMock).toHaveBeenCalledOnce();
    expect(commitMock).toHaveBeenCalledOnce();
    expect(rollbackMock).not.toHaveBeenCalled();

    // Pre-save defaults populated on check-in
    expect(checkIn.PreviousValue).toBe(20);
    expect(checkIn.PercentComplete).toBe(50);

    // Parent task updated and saved
    expect(parentTaskMock.CurrentValue).toBe(30);
    expect(parentTaskMock.PercentComplete).toBe(50);
    expect(parentTaskMock.HealthStatus).toBe('AtRisk');
    expect(parentTaskMock.ConfidenceScore).toBe(65);
    expect(parentTaskMock.LastCheckInAt?.toISOString()).toBe('2026-10-17T12:00:00.000Z');
    expect(parentTaskMock.NextCheckInDueAt?.toISOString()).toBe('2026-10-24T12:00:00.000Z');
    expect(parentTaskMock.Save).toHaveBeenCalledOnce();
  });

  it('rolls back the transaction when parent Task sync fails during standalone save', async () => {
    parentTaskMock.Save.mockResolvedValueOnce(false);

    const checkIn = new TaskCheckInEntityServer();
    checkIn.HealthStatus = 'AtRisk';
    checkIn.NewValue = 30;

    await expect(checkIn.Save()).rejects.toThrow(/Parent save refused/);
    expect(beginTxMock).toHaveBeenCalledOnce();
    expect(rollbackMock).toHaveBeenCalledOnce();
    expect(commitMock).not.toHaveBeenCalled();
  });

  it('skips recursive parentTask.Save() and extra transaction when saving inside a parent Task.CheckIns composite graph', async () => {
    const checkIn = new TaskCheckInEntityServer();
    checkIn.HealthStatus = 'AtRisk';
    checkIn.NewValue = 30;

    const exitScope = EnterTaskCheckInGraphScope(TASK_ID, [checkIn]);
    try {
      const ok = await checkIn.Save();
      expect(ok).toBe(true);
    } finally {
      exitScope();
    }

    expect(baseSaveMock).toHaveBeenCalledOnce();
    expect(beginTxMock).not.toHaveBeenCalled();
    expect(providerGetEntityObjectMock).not.toHaveBeenCalled();
    expect(parentTaskMock.Save).not.toHaveBeenCalled();
  });
});
