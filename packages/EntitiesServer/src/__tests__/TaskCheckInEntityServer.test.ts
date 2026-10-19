import { describe, it, expect, beforeEach, vi } from 'vitest';

const parentTaskMock = {
  ID: 'task-kr-1',
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
  Load: vi.fn(async () => true),
  Save: vi.fn(async () => true),
};

const baseSaveMock = vi.fn(async () => true);

vi.mock('@memberjunction/global', () => ({
  RegisterClass: () => () => {},
}));

vi.mock('@memberjunction/core', () => ({
  BaseEntity: class {},
  LogError: vi.fn(),
  Metadata: class {
    async GetEntityObject() {
      return parentTaskMock;
    }
  },
}));

vi.mock('@mj-biz-apps/tasks-entities', () => ({
  mjBizAppsTasksTaskEntity: class {},
  mjBizAppsTasksTaskCheckInEntity: class {
    ID = 'checkin-1';
    TaskID = 'task-kr-1';
    CheckInAt = new Date('2026-10-17T12:00:00.000Z');
    HealthStatus: 'OnTrack' | 'AtRisk' | 'OffTrack' | 'Completed' | 'Paused' = 'OnTrack';
    ConfidenceScore: number | null = null;
    PreviousValue: number | null = null;
    NewValue: number | null = null;
    PercentComplete: number | null = null;
    Summary = '';
    ContextCurrentUser = { ID: 'user-1' };
    async Save() {
      return baseSaveMock();
    }
  },
}));

import { TaskCheckInEntityServer } from '../TaskCheckInEntityServer.js';

describe('TaskCheckInEntityServer', () => {
  beforeEach(() => {
    vi.clearAllMocks();
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
  });

  it('populates PreviousValue, computes PercentComplete, and propagates status + cadence onto parent Task', async () => {
    const checkIn = new TaskCheckInEntityServer();
    checkIn.HealthStatus = 'AtRisk';
    checkIn.ConfidenceScore = 65;
    checkIn.NewValue = 30; // halfway between 10 and 50 -> 50%
    checkIn.Summary = 'Pipeline progressed to 30, watching enterprise deal slippage';

    const ok = await checkIn.Save();
    expect(ok).toBe(true);

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
});
