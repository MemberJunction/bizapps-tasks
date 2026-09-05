import { describe, it, expect, beforeEach, vi } from 'vitest';

// ---------------------------------------------------------------------------
// Mock @memberjunction/core. The service uses:
//   - new RunView().RunView({...})            → query children / records
//   - Metadata.Provider.GetEntityObject(name) → entity object w/ Set/Get/Save/InnerLoad
//   - new CompositeKey([...])                  → simple PK wrapper
// We provide controllable test doubles so the service logic runs in isolation.
// ---------------------------------------------------------------------------

const runViewMock = vi.fn();
const getEntityObjectMock = vi.fn();

vi.mock('@memberjunction/core', () => {
  return {
    RunView: class {
      RunView(...args: any[]) {
        return runViewMock(...args);
      }
    },
    Metadata: {
      Provider: {
        GetEntityObject: (...args: any[]) => getEntityObjectMock(...args),
      },
    },
    CompositeKey: class {
      constructor(public KeyValuePairs: any[]) {}
    },
    BaseEntity: class {},
    LogError: vi.fn(),
  };
});

import { TaskService } from '../TaskService.js';

/** Builds a fake entity object that records Set() calls and supports Get/Save/InnerLoad/NewRecord. */
function makeFakeEntity(initial: Record<string, any> = {}) {
  const data: Record<string, any> = { ...initial };
  return {
    data,
    NewRecord: vi.fn(),
    InnerLoad: vi.fn(async () => true),
    Save: vi.fn(async () => true),
    Set: vi.fn((field: string, value: any) => { data[field] = value; }),
    Get: vi.fn((field: string) => data[field]),
  };
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
    // children: 0, 50, 100 → avg 50
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
    // child A: 100% over 10h, child B: 0% over 30h → (100*10 + 0*30)/40 = 25
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

    const statusCalls = parent.Set.mock.calls.filter((c: any[]) => c[0] === 'Status');
    expect(statusCalls).toHaveLength(0);
  });

  it('recurses up the tree when the parent itself has a parent', async () => {
    // First rollup: children of parent-1
    runViewMock
      .mockResolvedValueOnce({ Results: [{ PercentComplete: 100, HoursEstimated: null, Status: 'Completed' }] })
      // Second rollup (grandparent): children of grandparent-1
      .mockResolvedValueOnce({ Results: [{ PercentComplete: 50, HoursEstimated: null, Status: 'InProgress' }] });

    const parent = makeFakeEntity({ Status: 'InProgress', ParentID: 'grandparent-1' });
    const grandparent = makeFakeEntity({ Status: 'InProgress', ParentID: null });
    getEntityObjectMock
      .mockResolvedValueOnce(parent)
      .mockResolvedValueOnce(grandparent);

    const svc = new TaskService();
    await svc.rollupParentProgress('parent-1');

    // Both parent and grandparent should have been saved
    expect(parent.Save).toHaveBeenCalledOnce();
    expect(grandparent.Save).toHaveBeenCalledOnce();
    expect(grandparent.Set).toHaveBeenCalledWith('PercentComplete', 50);
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

    const setFields = activity.Set.mock.calls.map((c: any[]) => c[0]);
    expect(setFields).not.toContain('PersonID');
    expect(setFields).not.toContain('PreviousValue');
    expect(setFields).not.toContain('NewValue');
    expect(activity.Set).toHaveBeenCalledWith('TaskID', 'task-2');
  });
});
