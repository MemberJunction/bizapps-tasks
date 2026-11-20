import { describe, it, expect, beforeEach, vi } from 'vitest';

const { runViewMock, runViewCtorMock } = vi.hoisted(() => ({
  runViewMock: vi.fn(),
  runViewCtorMock: vi.fn(),
}));

const TASK_1 = '11111111-1111-4111-8111-111111111111';
const TASK_2 = '22222222-2222-4222-8222-222222222222';
const TASK_3 = '33333333-3333-4333-8333-333333333333';

vi.mock('@memberjunction/global', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@memberjunction/global')>();
  return {
    ...actual,
    RegisterClass: () => () => {},
  };
});

vi.mock('@memberjunction/core', () => {
  class FakeValidationResult {
    Success = true;
    Errors: Array<{ Source: string; Message: string; Value: unknown; Type: string }> = [];
  }
  class FakeBaseEntity {
    _data: Record<string, unknown> = {};
    ContextCurrentUser: unknown = null;
    RunViewProviderToUse: unknown = undefined;
    Get(field: string) { return this._data[field]; }
    Set(field: string, value: unknown) { this._data[field] = value; }
    Validate() { return new FakeValidationResult(); }
    async ValidateAsync() { return new FakeValidationResult(); }
    DeclareRelatedRecords(options: unknown) { return { Options: options }; }
  }
  return {
    BaseEntity: FakeBaseEntity,
    ValidationResult: FakeValidationResult,
    ValidationErrorInfo: class {
      constructor(public Source: string, public Message: string, public Value: unknown, public Type: string) {}
    },
    ValidationErrorType: { Failure: 'Failure', Warning: 'Warning' },
    Metadata: { Provider: {} },
    RunView: class {
      constructor(provider?: unknown) {
        runViewCtorMock(provider);
      }
      RunView(...args: unknown[]) { return runViewMock(...args); }
    },
  };
});

import { TaskDependencyEntity } from '../TaskDependencyEntitySubclass.js';

interface TestDependencyHandle {
  _data: Record<string, unknown>;
  ContextCurrentUser: unknown;
  RunViewProviderToUse: unknown;
}

function makeDep(
  taskID: string,
  dependsOnTaskID: string,
  options?: { contextUser?: unknown; runViewProvider?: unknown },
): TaskDependencyEntity {
  const d = new TaskDependencyEntity();
  const handle = d as unknown as TestDependencyHandle;
  handle._data = { TaskID: taskID, DependsOnTaskID: dependsOnTaskID };
  handle.ContextCurrentUser = options?.contextUser ?? { ID: 'user-1' };
  handle.RunViewProviderToUse = options?.runViewProvider ?? { tag: 'scoped-rv-provider' };
  return d;
}

beforeEach(() => vi.clearAllMocks());

describe('TaskDependencyEntity.Validate — self-reference', () => {
  it('rejects a task depending on itself (case-insensitive UUID match)', () => {
    const d = makeDep(TASK_1.toUpperCase(), TASK_1.toLowerCase());
    const result = d.Validate();
    expect(result.Success).toBe(false);
    expect(result.Errors.some(e => e.Source === 'DependsOnTaskID')).toBe(true);
  });

  it('allows a dependency between two different tasks', () => {
    const d = makeDep(TASK_1, TASK_2);
    const result = d.Validate();
    expect(result.Errors.some(e => e.Source === 'DependsOnTaskID')).toBe(false);
  });
});

describe('TaskDependencyEntity.ValidateAsync — cycle detection, provider/user threading, UUID guards', () => {
  it('allows an acyclic dependency and threads RunViewProviderToUse and ContextCurrentUser', async () => {
    runViewMock.mockResolvedValue({ Results: [] });
    const ctxUser = { ID: 'user-ctx-99' };
    const scopedProvider = { tag: 'tx-provider' };

    const d = makeDep(TASK_1, TASK_2, { contextUser: ctxUser, runViewProvider: scopedProvider });
    const result = await d.ValidateAsync();

    expect(result.Success).toBe(true);
    expect(result.Errors).toHaveLength(0);
    expect(runViewCtorMock).toHaveBeenCalledWith(scopedProvider);
    expect(runViewMock).toHaveBeenCalledWith(
      expect.objectContaining({
        EntityName: 'MJ_BizApps_Tasks: Task Dependencies',
        ExtraFilter: `TaskID = '${TASK_2}'`,
        ResultType: 'simple',
      }),
      ctxUser,
    );
  });

  it('rejects non-UUID TaskID or DependsOnTaskID without executing RunView', async () => {
    const badTask = makeDep("' OR 1=1 --", TASK_2);
    const r1 = await badTask.ValidateAsync();
    expect(r1.Success).toBe(false);
    expect(r1.Errors.some(e => e.Source === 'TaskID')).toBe(true);
    expect(runViewMock).not.toHaveBeenCalled();

    const badDep = makeDep(TASK_1, 'not-a-uuid');
    const r2 = await badDep.ValidateAsync();
    expect(r2.Success).toBe(false);
    expect(r2.Errors.some(e => e.Source === 'DependsOnTaskID')).toBe(true);
    expect(runViewMock).not.toHaveBeenCalled();
  });

  it('detects a direct cycle (TASK_2 already depends on TASK_1)', async () => {
    runViewMock.mockImplementation((opts: { ExtraFilter?: string }) => {
      if (opts.ExtraFilter === `TaskID = '${TASK_2}'`) {
        return Promise.resolve({ Results: [{ DependsOnTaskID: TASK_1 }] });
      }
      return Promise.resolve({ Results: [] });
    });

    const d = makeDep(TASK_1, TASK_2);
    const result = await d.ValidateAsync();

    expect(result.Success).toBe(false);
    expect(result.Errors.some(e => e.Source === 'DependsOnTaskID')).toBe(true);
  });

  it('detects a transitive cycle (TASK_2 → TASK_3 → TASK_1)', async () => {
    runViewMock.mockImplementation((opts: { ExtraFilter?: string }) => {
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
    expect(result.Errors.some(e => e.Source === 'DependsOnTaskID')).toBe(true);
  });

  it('terminates and passes when the graph has a cycle NOT involving the new edge', async () => {
    runViewMock.mockImplementation((opts: { ExtraFilter?: string }) => {
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

    expect(result.Success).toBe(true);
  });
});
