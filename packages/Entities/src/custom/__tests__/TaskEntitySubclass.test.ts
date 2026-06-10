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

// NOTE: Activity logging and sub-task progress rollup were moved OUT of this
// client-safe TaskEntity subclass into the server-only TaskEntityServer
// (tasks-entities-server) so they run once on the server, never duplicated in
// the browser. Activity-logging coverage now lives in tasks-entities-server's
// tests; rollup logic is covered by TaskService's unit tests. This shared
// subclass now owns only validation + in-record field side-effects (above).
