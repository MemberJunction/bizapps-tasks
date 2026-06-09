import { describe, it, expect, beforeEach, vi } from 'vitest';

// ---------------------------------------------------------------------------
// Mock @memberjunction/core and @memberjunction/global.
//
// The subclass extends BaseEntity and calls super.Validate()/super.Save(),
// this.Fields, this.Get/Set, this.IsSaved. We provide a controllable fake
// BaseEntity so the subclass's own logic (validation + status side-effects +
// post-save activity logging + rollup) can be exercised in isolation.
// ---------------------------------------------------------------------------

// vi.hoisted so the (hoisted) mock factories can reference these spies.
const { runViewMock, getEntityObjectMock } = vi.hoisted(() => ({
  runViewMock: vi.fn(),
  getEntityObjectMock: vi.fn(),
}));

vi.mock('@memberjunction/global', () => ({
  RegisterClass: () => () => {},
}));

vi.mock('@memberjunction/core', () => {
  class FakeValidationResult {
    Success = true;
    Errors: any[] = [];
  }
  class FakeBaseEntity {
    _data: Record<string, any> = {};
    _fields: any[] = [];
    _isSaved = false;
    ContextCurrentUser: any = null;

    get Fields() { return this._fields; }
    get IsSaved() { return this._isSaved; }

    Get(field: string) { return this._data[field]; }
    Set(field: string, value: any) {
      this._data[field] = value;
      const f = this._fields.find((x: any) => x.CodeName === field);
      if (f) { f.Value = value; f.Dirty = true; }
    }

    Validate() { return new FakeValidationResult(); }
    async ValidateAsync() { return new FakeValidationResult(); }
    async Save(_options?: any) { return true; }
  }
  return {
    BaseEntity: FakeBaseEntity,
    EntitySaveOptions: class {},
    ValidationResult: FakeValidationResult,
    ValidationErrorInfo: class {
      constructor(public Source: string, public Message: string, public Value: any, public Type: any) {}
    },
    ValidationErrorType: { Failure: 'Failure', Warning: 'Warning' },
    Metadata: {
      Provider: { GetEntityObject: (...args: any[]) => getEntityObjectMock(...args) },
    },
    RunView: class {
      RunView(...args: any[]) { return runViewMock(...args); }
    },
    CompositeKey: class { constructor(public KeyValuePairs: any[]) {} },
  };
});

import { TaskEntity } from '../TaskEntitySubclass.js';

/** Configure a TaskEntity instance with given field data + dirty-tracked fields. */
function makeTask(data: Record<string, any>, dirtyFields: Record<string, { old?: any }> = {}, isSaved = true) {
  const t = new TaskEntity() as any;
  t._data = { ...data };
  t._isSaved = isSaved;
  t._fields = Object.keys({ ...data, ...dirtyFields }).map(code => ({
    CodeName: code,
    Value: data[code],
    OldValue: dirtyFields[code]?.old,
    Dirty: code in dirtyFields,
  }));
  return t;
}

beforeEach(() => vi.clearAllMocks());

describe('TaskEntity.Validate — field validation', () => {
  it('rejects PercentComplete below 0', () => {
    const t = makeTask({ PercentComplete: -5 });
    const result = t.Validate();
    expect(result.Success).toBe(false);
    expect(result.Errors.some((e: any) => e.Source === 'PercentComplete')).toBe(true);
  });

  it('rejects PercentComplete above 100', () => {
    const t = makeTask({ PercentComplete: 150 });
    const result = t.Validate();
    expect(result.Success).toBe(false);
    expect(result.Errors.some((e: any) => e.Source === 'PercentComplete')).toBe(true);
  });

  it('accepts PercentComplete within range', () => {
    const t = makeTask({ PercentComplete: 50 });
    const result = t.Validate();
    expect(result.Errors.some((e: any) => e.Source === 'PercentComplete')).toBe(false);
  });

  it('rejects DueAt on or before StartedAt', () => {
    const t = makeTask({
      StartedAt: new Date('2026-06-10T00:00:00Z'),
      DueAt: new Date('2026-06-05T00:00:00Z'),
    });
    const result = t.Validate();
    expect(result.Success).toBe(false);
    expect(result.Errors.some((e: any) => e.Source === 'DueAt')).toBe(true);
  });

  it('accepts DueAt after StartedAt', () => {
    const t = makeTask({
      StartedAt: new Date('2026-06-01T00:00:00Z'),
      DueAt: new Date('2026-06-10T00:00:00Z'),
    });
    const result = t.Validate();
    expect(result.Errors.some((e: any) => e.Source === 'DueAt')).toBe(false);
  });
});

describe('TaskEntity.Validate — status transition side-effects', () => {
  it('stamps StartedAt when status becomes InProgress and StartedAt is empty', () => {
    const t = makeTask({ Status: 'InProgress', StartedAt: null }, { Status: { old: 'Open' } });
    t.Validate();
    expect(t.Get('StartedAt')).toBeInstanceOf(Date);
  });

  it('does not overwrite an existing StartedAt', () => {
    const existing = new Date('2026-06-01T00:00:00Z');
    const t = makeTask({ Status: 'InProgress', StartedAt: existing }, { Status: { old: 'Open' } });
    t.Validate();
    expect(t.Get('StartedAt')).toBe(existing);
  });

  it('stamps CompletedAt and forces PercentComplete=100 when status becomes Completed', () => {
    const t = makeTask({ Status: 'Completed', CompletedAt: null, PercentComplete: 80 }, { Status: { old: 'InProgress' } });
    t.Validate();
    expect(t.Get('CompletedAt')).toBeInstanceOf(Date);
    expect(t.Get('PercentComplete')).toBe(100);
  });

  it('clears CompletedAt when reopening from Completed to InProgress', () => {
    const t = makeTask(
      { Status: 'InProgress', CompletedAt: new Date('2026-06-01T00:00:00Z') },
      { Status: { old: 'Completed' } },
    );
    t.Validate();
    expect(t.Get('CompletedAt')).toBeNull();
  });

  it('does nothing when Status field is not dirty', () => {
    const t = makeTask({ Status: 'InProgress', StartedAt: null }); // not dirty
    t.Validate();
    expect(t.Get('StartedAt')).toBeNull();
  });
});

describe('TaskEntity.Save — post-save activity logging', () => {
  it('logs a Created activity for a new task', async () => {
    const activity = { NewRecord: vi.fn(), Set: vi.fn(), Save: vi.fn(async () => true), Get: vi.fn() };
    getEntityObjectMock.mockResolvedValue(activity);
    runViewMock.mockResolvedValue({ Results: [] });

    const t = makeTask({ ID: 'task-1', Name: 'New Task', Status: 'Open', ParentID: null }, {}, false /* not saved → new */);
    await t.Save();

    const types = activity.Set.mock.calls.filter((c: any[]) => c[0] === 'ActivityType').map((c: any[]) => c[1]);
    expect(types).toContain('Created');
  });

  it('logs a StatusChange activity for an existing task whose status changed', async () => {
    const activity = { NewRecord: vi.fn(), Set: vi.fn(), Save: vi.fn(async () => true), Get: vi.fn() };
    getEntityObjectMock.mockResolvedValue(activity);
    runViewMock.mockResolvedValue({ Results: [] });

    const t = makeTask(
      { ID: 'task-2', Name: 'T', Status: 'InProgress', ParentID: null },
      { Status: { old: 'Open' } },
      true /* already saved → update */,
    );
    await t.Save();

    const types = activity.Set.mock.calls.filter((c: any[]) => c[0] === 'ActivityType').map((c: any[]) => c[1]);
    expect(types).toContain('StatusChange');
  });

  it('logs a Completed activity when status changed to Completed', async () => {
    const activity = { NewRecord: vi.fn(), Set: vi.fn(), Save: vi.fn(async () => true), Get: vi.fn() };
    getEntityObjectMock.mockResolvedValue(activity);
    runViewMock.mockResolvedValue({ Results: [] });

    const t = makeTask(
      { ID: 'task-3', Name: 'T', Status: 'Completed', ParentID: null },
      { Status: { old: 'InProgress' } },
      true,
    );
    await t.Save();

    const types = activity.Set.mock.calls.filter((c: any[]) => c[0] === 'ActivityType').map((c: any[]) => c[1]);
    expect(types).toContain('StatusChange');
    expect(types).toContain('Completed');
  });

  it('triggers parent rollup when a child task with a parent changes percent', async () => {
    const activity = { NewRecord: vi.fn(), Set: vi.fn(), Save: vi.fn(async () => true), Get: vi.fn() };
    const parent = {
      Set: vi.fn(), Save: vi.fn(async () => true),
      Get: vi.fn((f: string) => (f === 'PercentComplete' ? 0 : null)),
      InnerLoad: vi.fn(async () => true),
    };
    // GetEntityObject called for: activity log(s), then parent rollup load
    getEntityObjectMock.mockResolvedValue(activity);
    getEntityObjectMock.mockResolvedValueOnce(activity).mockResolvedValueOnce(parent);
    // rollup children query
    runViewMock.mockResolvedValue({ Results: [{ PercentComplete: 50 }] });

    const t = makeTask(
      { ID: 'child-1', Name: 'Child', Status: 'InProgress', PercentComplete: 50, ParentID: 'parent-1' },
      { PercentComplete: { old: 0 } },
      true,
    );
    await t.Save();

    // parent rollup should have queried children
    expect(runViewMock).toHaveBeenCalledWith(expect.objectContaining({
      ExtraFilter: "ParentID = 'parent-1'",
    }));
  });
});
