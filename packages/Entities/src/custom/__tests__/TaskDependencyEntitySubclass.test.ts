import { describe, it, expect, beforeEach, vi } from 'vitest';

// vi.hoisted so the mock factory (which is hoisted above imports) can see these.
const { runViewMock } = vi.hoisted(() => ({ runViewMock: vi.fn() }));

vi.mock('@memberjunction/global', () => ({
  RegisterClass: () => () => {},
  IsValidUUID: (v: string) => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v),
}));

// Filter IDs must now be real UUIDs: anything else is refused before it reaches an ExtraFilter.
const TASK_1 = 'A0000000-0000-0000-0000-000000000001';
const TASK_2 = 'A0000000-0000-0000-0000-000000000002';
const TASK_3 = 'A0000000-0000-0000-0000-000000000003';

vi.mock('@memberjunction/core', () => {
  class FakeValidationResult {
    Success = true;
    Errors: any[] = [];
  }
  class FakeBaseEntity {
    _data: Record<string, any> = {};
    Get(field: string) { return this._data[field]; }
    Set(field: string, value: any) { this._data[field] = value; }
    Validate() { return new FakeValidationResult(); }
    async ValidateAsync() { return new FakeValidationResult(); }
  }
  return {
    BaseEntity: FakeBaseEntity,
    ValidationResult: FakeValidationResult,
    ValidationErrorInfo: class {
      constructor(public Source: string, public Message: string, public Value: any, public Type: any) {}
    },
    ValidationErrorType: { Failure: 'Failure', Warning: 'Warning' },
    Metadata: { Provider: {} },
    RunView: class {
      RunView(...args: any[]) { return runViewMock(...args); }
    },
  };
});

import { TaskDependencyEntity } from '../TaskDependencyEntitySubclass.js';

function makeDep(taskID: string, dependsOnTaskID: string) {
  const d = new TaskDependencyEntity() as any;
  d._data = { TaskID: taskID, DependsOnTaskID: dependsOnTaskID };
  return d;
}

beforeEach(() => vi.clearAllMocks());

describe('TaskDependencyEntity.Validate — self-reference', () => {
  it('rejects a task depending on itself', () => {
    const d = makeDep(TASK_1, TASK_1);
    const result = d.Validate();
    expect(result.Success).toBe(false);
    expect(result.Errors.some((e: any) => e.Source === 'DependsOnTaskID')).toBe(true);
  });

  it('allows a dependency between two different tasks', () => {
    const d = makeDep(TASK_1, TASK_2);
    const result = d.Validate();
    expect(result.Errors.some((e: any) => e.Source === 'DependsOnTaskID')).toBe(false);
  });
});

describe('TaskDependencyEntity.ValidateAsync — cycle detection', () => {
  it('allows an acyclic dependency (DependsOn has no path back to Task)', async () => {
    // task-1 depends on task-2; task-2 depends on nothing.
    runViewMock.mockResolvedValue({ Results: [] }); // task-2 has no upstream deps

    const d = makeDep(TASK_1, TASK_2);
    const result = await d.ValidateAsync();

    expect(result.Success).toBe(true);
    expect(result.Errors).toHaveLength(0);
  });

  it('detects a direct cycle (task-2 already depends on task-1)', async () => {
    // Adding task-1 → depends-on task-2, but task-2 → depends-on task-1 already exists.
    // Walk from task-2: its upstream includes task-1 → reaches TaskID → cycle.
    runViewMock.mockImplementation((opts: any) => {
      if (opts.ExtraFilter === `TaskID = '${TASK_2}'`) {
        return Promise.resolve({ Results: [{ DependsOnTaskID: TASK_1 }] });
      }
      return Promise.resolve({ Results: [] });
    });

    const d = makeDep(TASK_1, TASK_2);
    const result = await d.ValidateAsync();

    expect(result.Success).toBe(false);
    expect(result.Errors.some((e: any) => e.Source === 'DependsOnTaskID')).toBe(true);
  });

  it('detects a transitive cycle (task-2 → task-3 → task-1)', async () => {
    runViewMock.mockImplementation((opts: any) => {
      if (opts.ExtraFilter === `TaskID = '${TASK_2}'`) {
        return Promise.resolve({ Results: [{ DependsOnTaskID: TASK_3 }] });
      }
      if (opts.ExtraFilter === `TaskID = '${TASK_3}'`) {
        return Promise.resolve({ Results: [{ DependsOnTaskID: TASK_1 }] });
      }
      return Promise.resolve({ Results: [] });
    });

    const d = makeDep(TASK_1, TASK_2);
    const result = await d.ValidateAsync();

    expect(result.Success).toBe(false);
    expect(result.Errors.some((e: any) => e.Source === 'DependsOnTaskID')).toBe(true);
  });

  it('terminates and passes when the graph has a cycle NOT involving the new edge', async () => {
    // task-2 → task-3 → task-2 (a cycle among others), but none reaches task-1.
    // The visited-set must prevent infinite looping.
    runViewMock.mockImplementation((opts: any) => {
      if (opts.ExtraFilter === `TaskID = '${TASK_2}'`) {
        return Promise.resolve({ Results: [{ DependsOnTaskID: TASK_3 }] });
      }
      if (opts.ExtraFilter === `TaskID = '${TASK_3}'`) {
        return Promise.resolve({ Results: [{ DependsOnTaskID: TASK_2 }] });
      }
      return Promise.resolve({ Results: [] });
    });

    const d = makeDep(TASK_1, TASK_2);
    const result = await d.ValidateAsync();

    // No path reaches task-1, and visited-set prevents hang → valid.
    expect(result.Success).toBe(true);
  });

  it('refuses an ID that is not a UUID before it reaches a filter', async () => {
    const d = makeDep(TASK_1, "x' OR 1=1 --");
    const result = await d.ValidateAsync();

    expect(result.Success).toBe(false);
    expect(result.Errors.some((e: any) => /is not a valid ID/.test(e.Message))).toBe(true);
    expect(runViewMock).not.toHaveBeenCalled();
  });

  it('refuses a walked dependency row whose ID is not a UUID (defense in depth)', async () => {
    runViewMock.mockImplementation((opts: any) => {
      if (opts.ExtraFilter === `TaskID = '${TASK_2}'`) {
        return Promise.resolve({ Results: [{ DependsOnTaskID: "y'; DROP TABLE Task --" }] });
      }
      return Promise.resolve({ Results: [] });
    });

    const d = makeDep(TASK_1, TASK_2);
    const result = await d.ValidateAsync();

    expect(result.Success).toBe(false);
    expect(result.Errors.some((e: any) => /is not a valid ID/.test(e.Message))).toBe(true);
    // Only the valid starting ID was ever queried; the poisoned row never reached a filter.
    expect(runViewMock).toHaveBeenCalledTimes(1);
  });
});
