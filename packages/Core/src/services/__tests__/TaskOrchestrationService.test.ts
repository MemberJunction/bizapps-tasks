import { describe, it, expect, beforeEach, vi } from 'vitest';

// ---------------------------------------------------------------------------
// Mock @memberjunction/core. TaskOrchestrationService uses:
//   - new Metadata().GetEntityObject(name, user) → typed entity (property accessors)
//   - new RunView().RunView({...})               → outcome / lookup queries
//   - new CompositeKey([...])                     → PK wrapper for InnerLoad
// Entity objects are accessed via typed PROPERTIES (task.Name = ..., task.Status),
// so the fake uses real own-properties rather than Set()/Get().
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
    // Service uses `new Metadata().GetEntityObject(...)`; the shared TaskService it
    // delegates to uses the static `Metadata.Provider.GetEntityObject(...)`. Support both.
    Metadata: Object.assign(
      class {
        GetEntityObject(...args: any[]) {
          return getEntityObjectMock(...args);
        }
      },
      { Provider: { GetEntityObject: (...args: any[]) => getEntityObjectMock(...args) } },
    ),
    CompositeKey: class {
      constructor(public KeyValuePairs: any[]) {}
    },
    LogError: vi.fn(),
  };
});

import { TaskOrchestrationService } from '../TaskOrchestrationService.js';

/**
 * A fake entity supporting BOTH access styles used across the services:
 *  - typed own-properties (orchestration service: `task.Status = ...`)
 *  - Set()/Get() (the shared TaskService.logActivity path)
 */
function makeFakeEntity(initial: Record<string, any> = {}) {
  const entity: any = {
    ...initial,
    NewRecord: vi.fn(),
    InnerLoad: vi.fn(async () => true),
    Save: vi.fn(async () => true),
    LatestResult: { CompleteMessage: '' },
  };
  entity.Set = vi.fn((field: string, value: any) => { entity[field] = value; });
  entity.Get = vi.fn((field: string) => entity[field]);
  return entity;
}

const user: any = { ID: 'user-1', Email: 'tester@example.com' };

beforeEach(() => {
  vi.clearAllMocks();
});

describe('TaskOrchestrationService.CreateTask', () => {
  it('sets required fields, defaults Status to Open, and saves', async () => {
    const task = makeFakeEntity();
    getEntityObjectMock.mockResolvedValueOnce(task);

    const svc = new TaskOrchestrationService();
    const result = await svc.CreateTask({ Name: 'Approve PO #5', TypeID: 'type-1' }, user);

    expect(task.NewRecord).toHaveBeenCalledOnce();
    expect(result.Name).toBe('Approve PO #5');
    expect(result.TypeID).toBe('type-1');
    expect(result.Status).toBe('Open');
    expect(task.Save).toHaveBeenCalledOnce();
  });

  it('throws with the entity error message when Save fails', async () => {
    const task = makeFakeEntity();
    task.Save = vi.fn(async () => false);
    task.LatestResult = { CompleteMessage: 'FK violation' };
    getEntityObjectMock.mockResolvedValueOnce(task);

    const svc = new TaskOrchestrationService();
    await expect(svc.CreateTask({ Name: 'x', TypeID: 't' }, user)).rejects.toThrow(/FK violation/);
  });
});

describe('TaskOrchestrationService.TransitionStatus', () => {
  it('no-ops (no save) when the task is already in the target status', async () => {
    const task = makeFakeEntity({ Status: 'Completed' });
    getEntityObjectMock.mockResolvedValueOnce(task);

    const svc = new TaskOrchestrationService();
    await svc.TransitionStatus('task-1', 'Completed', user);

    expect(task.Save).not.toHaveBeenCalled();
  });

  it('sets the new status and saves when different', async () => {
    const task = makeFakeEntity({ Status: 'Open' });
    getEntityObjectMock.mockResolvedValueOnce(task);

    const svc = new TaskOrchestrationService();
    const result = await svc.TransitionStatus('task-1', 'InProgress', user);

    expect(result.Status).toBe('InProgress');
    expect(task.Save).toHaveBeenCalledOnce();
  });

  it('throws when the task is not found', async () => {
    const task = makeFakeEntity({ Status: 'Open' });
    task.InnerLoad = vi.fn(async () => false);
    getEntityObjectMock.mockResolvedValueOnce(task);

    const svc = new TaskOrchestrationService();
    await expect(svc.TransitionStatus('missing', 'InProgress', user)).rejects.toThrow(/not found/);
  });
});

describe('TaskOrchestrationService.RecordDecision', () => {
  it('Approved → records decision, logs activity, transitions task to Completed', async () => {
    // 1) resolveOutcome RunView → Approved (terminal)
    runViewMock.mockResolvedValueOnce({
      Success: true,
      Results: [{ ID: 'outcome-approved', Name: 'Approved', Code: 'Approved', IsTerminal: true }],
    });

    const decision = makeFakeEntity();
    const activity = makeFakeEntity();
    const task = makeFakeEntity({ Status: 'Open' });
    getEntityObjectMock
      .mockResolvedValueOnce(decision)   // TaskDecision
      .mockResolvedValueOnce(activity)   // logActivity → Task Activities
      .mockResolvedValueOnce(task);      // TransitionStatus → load Task

    const svc = new TaskOrchestrationService();
    const result = await svc.RecordDecision(
      { TaskID: 'task-1', OutcomeCode: 'Approved', DecidedByPersonID: 'p1', Notes: 'ok' },
      user,
    );

    expect(decision.OutcomeID).toBe('outcome-approved');
    expect(decision.TaskID).toBe('task-1');
    expect(decision.Save).toHaveBeenCalledOnce();
    expect(result.NewStatus).toBe('Completed');
    expect(task.Status).toBe('Completed');
    expect(task.Save).toHaveBeenCalledOnce();
  });

  it('Rejected → transitions task to Cancelled', async () => {
    runViewMock.mockResolvedValueOnce({
      Success: true,
      Results: [{ ID: 'outcome-rejected', Name: 'Rejected', Code: 'Rejected', IsTerminal: true }],
    });
    const decision = makeFakeEntity();
    const activity = makeFakeEntity();
    const task = makeFakeEntity({ Status: 'Open' });
    getEntityObjectMock
      .mockResolvedValueOnce(decision)
      .mockResolvedValueOnce(activity)
      .mockResolvedValueOnce(task);

    const svc = new TaskOrchestrationService();
    const result = await svc.RecordDecision({ TaskID: 'task-1', OutcomeCode: 'Rejected' }, user);

    expect(result.NewStatus).toBe('Cancelled');
    expect(task.Status).toBe('Cancelled');
  });

  it('non-terminal outcome → records decision but does not transition', async () => {
    runViewMock.mockResolvedValueOnce({
      Success: true,
      Results: [{ ID: 'outcome-interim', Name: 'Needs Info', Code: 'Approved', IsTerminal: false }],
    });
    const decision = makeFakeEntity();
    const activity = makeFakeEntity();
    const task = makeFakeEntity({ Status: 'Open' });
    getEntityObjectMock
      .mockResolvedValueOnce(decision)
      .mockResolvedValueOnce(activity)
      .mockResolvedValueOnce(task);  // loadTask (no transition)

    const svc = new TaskOrchestrationService();
    const result = await svc.RecordDecision({ TaskID: 'task-1', OutcomeCode: 'Approved' }, user);

    expect(result.NewStatus).toBeNull();
    expect(task.Save).not.toHaveBeenCalled();
  });

  it('throws when the outcome code cannot be resolved', async () => {
    runViewMock.mockResolvedValueOnce({ Success: true, Results: [] });

    const svc = new TaskOrchestrationService();
    await expect(
      svc.RecordDecision({ TaskID: 'task-1', OutcomeCode: 'Approved' }, user),
    ).rejects.toThrow(/not found/);
  });
});
