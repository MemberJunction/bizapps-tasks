import { describe, it, expect, beforeEach, vi } from 'vitest';

const runViewMock = vi.fn();
const getEntityObjectMock = vi.fn();

vi.mock('@memberjunction/core', () => {
  return {
    RunView: class {
      RunView(...args: unknown[]) {
        return runViewMock(...args);
      }
    },
    Metadata: {
      Provider: {
        GetEntityObject: (...args: unknown[]) => getEntityObjectMock(...args),
      },
    },
    CompositeKey: class {
      constructor(public KeyValuePairs: unknown[]) {}
    },
    BaseEntity: class {},
  };
});

import { TaskService } from '../TaskService.js';

/**
 * Builds a fake entity object that records Set() / Get() calls and also exposes
 * strongly-typed property access via a Proxy backed by Get/Set.
 */
function makeFakeEntity(initial: Record<string, unknown> = {}) {
  const data: Record<string, unknown> = { ...initial };
  const base = {
    data,
    NewRecord: vi.fn(),
    InnerLoad: vi.fn(async () => true),
    Save: vi.fn(async () => true),
    Set: vi.fn((field: string, value: unknown) => {
      data[field] = value;
    }),
    Get: vi.fn((field: string) => data[field]),
  };

  return new Proxy(base, {
    get(target, prop, receiver) {
      if (typeof prop === 'string' && prop in target) {
        return Reflect.get(target, prop, receiver);
      }
      if (typeof prop === 'string') {
        return target.Get(prop);
      }
      return Reflect.get(target, prop, receiver);
    },
    set(target, prop, value, receiver) {
      if (typeof prop === 'string' && !(prop in target)) {
        target.Set(prop, value);
        return true;
      }
      return Reflect.set(target, prop, value, receiver);
    },
  });
}

beforeEach(() => {
  vi.clearAllMocks();
});

describe('TaskService.rollupParentProgress', () => {
  it('returns early and does not load the parent when there are no children', async () => {
    runViewMock.mockResolvedValueOnce({ Results: [] });
    const svc = new TaskService();

    await svc.rollupParentProgress('parent-1');

    expect(getEntityObjectMock).not.toHaveBeenCalled();
  });

  it('computes equal-weighted average when no HoursEstimated present', async () => {
    runViewMock.mockResolvedValueOnce({
      Results: [
        { PercentComplete: 0, HoursEstimated: null, Status: 'Open' },
        { PercentComplete: 50, HoursEstimated: null, Status: 'InProgress' },
        { PercentComplete: 100, HoursEstimated: null, Status: 'Completed' },
      ],
    });
    const parent = makeFakeEntity({ Status: 'InProgress', ParentID: null });
    getEntityObjectMock.mockResolvedValueOnce(parent);

    const svc = new TaskService();
    await svc.rollupParentProgress('parent-1');

    expect(parent.Set).toHaveBeenCalledWith('PercentComplete', 50);
    expect(parent.Save).toHaveBeenCalledOnce();
  });

  it('weights by HoursEstimated when available', async () => {
    runViewMock.mockResolvedValueOnce({
      Results: [
        { PercentComplete: 100, HoursEstimated: 10, Status: 'Completed' },
        { PercentComplete: 0, HoursEstimated: 30, Status: 'Open' },
      ],
    });
    const parent = makeFakeEntity({ Status: 'InProgress', ParentID: null });
    getEntityObjectMock.mockResolvedValueOnce(parent);

    const svc = new TaskService();
    await svc.rollupParentProgress('parent-1');

    expect(parent.Set).toHaveBeenCalledWith('PercentComplete', 25);
  });

  it('weights by RollupWeight and rolls up HealthStatus and ConfidenceScore for OKR children', async () => {
    // KR 1: 80% complete, weight 3, OnTrack, confidence 90
    // KR 2: 20% complete, weight 1, AtRisk, confidence 50
    // Weighted pct: (80*3 + 20*1)/4 = 65%
    // Weighted confidence: (90*3 + 50*1)/4 = 80
    // HealthStatus: worst-case -> AtRisk
    runViewMock.mockResolvedValueOnce({
      Results: [
        {
          PercentComplete: 80,
          RollupWeight: 3,
          HoursEstimated: null,
          Status: 'InProgress',
          HealthStatus: 'OnTrack',
          ConfidenceScore: 90,
        },
        {
          PercentComplete: 20,
          RollupWeight: 1,
          HoursEstimated: null,
          Status: 'InProgress',
          HealthStatus: 'AtRisk',
          ConfidenceScore: 50,
        },
      ],
    });
    const parent = makeFakeEntity({ Status: 'InProgress', ParentID: null, HealthStatus: 'OnTrack', ConfidenceScore: 70 });
    getEntityObjectMock.mockResolvedValueOnce(parent);

    const svc = new TaskService();
    await svc.rollupParentProgress('objective-1');

    expect(parent.Set).toHaveBeenCalledWith('PercentComplete', 65);
    expect(parent.Set).toHaveBeenCalledWith('HealthStatus', 'AtRisk');
    expect(parent.Set).toHaveBeenCalledWith('ConfidenceScore', 80);
    expect(parent.Save).toHaveBeenCalledOnce();
  });

  it('marks parent Completed when all children are completed', async () => {
    runViewMock.mockResolvedValueOnce({
      Results: [
        { PercentComplete: 100, HoursEstimated: null, Status: 'Completed' },
        { PercentComplete: 100, HoursEstimated: null, Status: 'Completed' },
      ],
    });
    const parent = makeFakeEntity({ Status: 'InProgress', ParentID: null });
    getEntityObjectMock.mockResolvedValueOnce(parent);

    const svc = new TaskService();
    await svc.rollupParentProgress('parent-1');

    expect(parent.Set).toHaveBeenCalledWith('PercentComplete', 100);
    expect(parent.Set).toHaveBeenCalledWith('Status', 'Completed');
  });

  it('does NOT mark parent Completed when at least one child is incomplete', async () => {
    runViewMock.mockResolvedValueOnce({
      Results: [
        { PercentComplete: 100, HoursEstimated: null, Status: 'Completed' },
        { PercentComplete: 90, HoursEstimated: null, Status: 'InProgress' },
      ],
    });
    const parent = makeFakeEntity({ Status: 'InProgress', ParentID: null });
    getEntityObjectMock.mockResolvedValueOnce(parent);

    const svc = new TaskService();
    await svc.rollupParentProgress('parent-1');

    const statusCalls = parent.Set.mock.calls.filter((c: unknown[]) => c[0] === 'Status');
    expect(statusCalls).toHaveLength(0);
  });

  it('recurses up the tree when the parent itself has a parent', async () => {
    runViewMock
      .mockResolvedValueOnce({ Results: [{ PercentComplete: 100, HoursEstimated: null, Status: 'Completed' }] })
      .mockResolvedValueOnce({ Results: [{ PercentComplete: 50, HoursEstimated: null, Status: 'InProgress' }] });

    const parent = makeFakeEntity({ Status: 'InProgress', ParentID: 'grandparent-1' });
    const grandparent = makeFakeEntity({ Status: 'InProgress', ParentID: null });
    getEntityObjectMock
      .mockResolvedValueOnce(parent)
      .mockResolvedValueOnce(grandparent);

    const svc = new TaskService();
    await svc.rollupParentProgress('parent-1');

    expect(parent.Save).toHaveBeenCalledOnce();
    expect(grandparent.Save).toHaveBeenCalledOnce();
    expect(grandparent.Set).toHaveBeenCalledWith('PercentComplete', 50);
  });
});

describe('TaskService OKR metric & cadence helpers', () => {
  it('computes quantitative PercentComplete for Increase, Decrease, and Maintain directions', () => {
    expect(TaskService.computeQuantitativePercentComplete(10, 50, 30, 'Increase')).toBe(50);
    expect(TaskService.computeQuantitativePercentComplete(100, 20, 40, 'Decrease')).toBe(75);
    expect(TaskService.computeQuantitativePercentComplete(99, 99, 99, 'Maintain')).toBe(100);
    expect(TaskService.computeQuantitativePercentComplete(99, 99, 95, 'Maintain')).toBe(0);
  });

  it('computes NextCheckInDueAt across cadences', () => {
    const base = new Date('2026-10-01T12:00:00.000Z');
    expect(TaskService.computeNextCheckInDueAt(base, 'Daily')?.toISOString()).toBe('2026-10-02T12:00:00.000Z');
    expect(TaskService.computeNextCheckInDueAt(base, 'Weekly')?.toISOString()).toBe('2026-10-08T12:00:00.000Z');
    expect(TaskService.computeNextCheckInDueAt(base, 'BiWeekly')?.toISOString()).toBe('2026-10-15T12:00:00.000Z');
    expect(TaskService.computeNextCheckInDueAt(base, 'None')).toBeNull();
  });
});

describe('TaskService.logActivity', () => {
  it('creates a TaskActivity record with required fields', async () => {
    const activity = makeFakeEntity();
    getEntityObjectMock.mockResolvedValueOnce(activity);

    const svc = new TaskService();
    await svc.logActivity({
      taskID: 'task-1',
      personID: 'person-1',
      activityType: 'StatusChange',
      previousValue: 'Open',
      newValue: 'InProgress',
      description: 'Status changed',
    });

    expect(activity.NewRecord).toHaveBeenCalledOnce();
    expect(activity.Set).toHaveBeenCalledWith('TaskID', 'task-1');
    expect(activity.Set).toHaveBeenCalledWith('PersonID', 'person-1');
    expect(activity.Set).toHaveBeenCalledWith('ActivityType', 'StatusChange');
    expect(activity.Set).toHaveBeenCalledWith('PreviousValue', 'Open');
    expect(activity.Set).toHaveBeenCalledWith('NewValue', 'InProgress');
    expect(activity.Set).toHaveBeenCalledWith('Description', 'Status changed');
    expect(activity.Save).toHaveBeenCalledOnce();
  });

  it('omits optional fields when not provided', async () => {
    const activity = makeFakeEntity();
    getEntityObjectMock.mockResolvedValueOnce(activity);

    const svc = new TaskService();
    await svc.logActivity({
      taskID: 'task-2',
      activityType: 'Created',
      description: 'Task created',
    });

    const setFields = activity.Set.mock.calls.map((c: unknown[]) => c[0]);
    expect(setFields).not.toContain('PersonID');
    expect(setFields).not.toContain('PreviousValue');
    expect(setFields).not.toContain('NewValue');
    expect(activity.Set).toHaveBeenCalledWith('TaskID', 'task-2');
  });
});
