import { describe, it, expect, beforeEach, vi } from 'vitest';
import type { UserInfo } from '@memberjunction/core';

const runViewMock = vi.fn();
const getEntityObjectMock = vi.fn();
const runViewProviders: unknown[] = [];

vi.mock('@memberjunction/core', async (importOriginal) => ({ ...(await importOriginal<typeof import('@memberjunction/core')>()),
  RunView: class {
    constructor(provider?: unknown) {
      runViewProviders.push(provider);
    }
    RunView(...args: unknown[]) { return runViewMock(...args); }
  },
  Metadata: {
    Provider: { GetEntityObject: (...args: unknown[]) => getEntityObjectMock(...args) },
  },
  CompositeKey: class { constructor(public KeyValuePairs: unknown[]) {} },
  BaseEntity: class {},
}));

import { TaskTemplateService } from '../TaskTemplateService.js';

const TMPL_1 = '11111111-1111-4111-8111-111111111111';
const TYPE_1 = '22222222-2222-4222-8222-222222222222';
const ITEM_1 = '33333333-3333-4333-8333-333333333331';
const ITEM_PARENT = '33333333-3333-4333-8333-333333333332';
const ITEM_CHILD = '33333333-3333-4333-8333-333333333333';
const ITEM_A = '33333333-3333-4333-8333-333333333334';
const ITEM_B = '33333333-3333-4333-8333-333333333335';
const TASK_1 = '44444444-4444-4444-8444-444444444441';
const TASK_PARENT = '44444444-4444-4444-8444-444444444442';
const TASK_CHILD = '44444444-4444-4444-8444-444444444443';
const TASK_A = '44444444-4444-4444-8444-444444444444';
const TASK_B = '44444444-4444-4444-8444-444444444445';
const ROLE_1 = '55555555-5555-4555-8555-555555555551';
const ENTITY_PERSON = '66666666-6666-4666-8666-666666666661';
const PERSON_1 = '77777777-7777-4777-8777-777777777771';

interface FakeCollection {
  Items: Record<string, unknown>[];
  Create: ReturnType<typeof vi.fn>;
}

function makeFakeCollection(): FakeCollection {
  const items: Record<string, unknown>[] = [];
  return {
    Items: items,
    Create: vi.fn(async () => {
      const child: Record<string, unknown> = {};
      items.push(child);
      return child;
    }),
  };
}

/** Fake entity that exposes typed properties + RelatedRecordCollection accessors. */
function makeFakeTask(id: string, initial: Record<string, unknown> = {}) {
  return {
    ID: id,
    ...initial,
    NewRecord: vi.fn(),
    InnerLoad: vi.fn(async () => true),
    Save: vi.fn(async () => true),
    LatestResult: { CompleteMessage: '' },
    Assignments: makeFakeCollection(),
    Dependencies: makeFakeCollection(),
  };
}

function makeFakeTemplateItem(
  item: Record<string, unknown>,
  roles: Array<{ RoleID: string }> = [],
  deps: Array<{ ItemID: string; DependsOnItemID: string; DependencyType?: string }> = [],
) {
  return {
    ...item,
    Roles: { Items: roles },
    Dependencies: { Items: deps },
  };
}

beforeEach(() => {
  vi.resetAllMocks();
  runViewProviders.length = 0;
});

describe('TaskTemplateService.instantiateTemplate', () => {
  it('returns empty array when the template has no items', async () => {
    const template = makeFakeTask(TMPL_1, { TypeID: TYPE_1 });
    getEntityObjectMock.mockResolvedValueOnce(template);
    runViewMock.mockResolvedValueOnce({ Success: true, Results: [] });

    const svc = new TaskTemplateService();
    const result = await svc.instantiateTemplate({
      templateID: TMPL_1,
      startDate: new Date('2026-06-01T00:00:00Z'),
    });

    expect(result).toEqual([]);
    expect(runViewMock).toHaveBeenCalledOnce();
    expect(runViewMock).toHaveBeenCalledWith(expect.objectContaining({
      EntityName: 'MJ_BizApps_Tasks: Task Template Items',
      ResultType: 'entity_object',
      IncludeRelatedRecords: ['Roles', 'Dependencies'],
    }), undefined);
  });

  it('creates a task per item with a single batched RunView (no N+1) and computes DueAt from DaysFromStart', async () => {
    const template = makeFakeTask(TMPL_1, { TypeID: TYPE_1 });
    const items = [
      makeFakeTemplateItem({
        ID: ITEM_1,
        Name: 'Kickoff',
        Description: 'd',
        Priority: 'High',
        HoursEstimated: 4,
        Sequence: 1,
        DaysFromStart: 5,
        ParentItemID: null,
      }),
    ];

    getEntityObjectMock.mockResolvedValueOnce(template);
    runViewMock.mockResolvedValueOnce({ Success: true, Results: items });

    const createdTask = makeFakeTask(TASK_1);
    getEntityObjectMock.mockResolvedValueOnce(createdTask);

    const svc = new TaskTemplateService();
    const start = new Date('2026-06-01T00:00:00Z');
    const result = await svc.instantiateTemplate({ templateID: TMPL_1, startDate: start });

    expect(result).toHaveLength(1);
    // Single batched query for items + Roles + Dependencies
    expect(runViewMock).toHaveBeenCalledTimes(1);
    expect(createdTask.Name).toBe('Kickoff');
    expect(createdTask.Priority).toBe('High');
    expect(createdTask.TypeID).toBe(TYPE_1);

    const expected = new Date(start);
    expected.setDate(expected.getDate() + 5);
    expect((createdTask.DueAt as Date).getTime()).toBe(expected.getTime());
    expect(createdTask.Save).toHaveBeenCalledOnce();
  });

  it('creates parent tasks before children and wires ParentID via the item→task map', async () => {
    const template = makeFakeTask(TMPL_1, { TypeID: TYPE_1 });
    // child listed BEFORE parent to exercise topological sort
    const items = [
      makeFakeTemplateItem({ ID: ITEM_CHILD, Name: 'Child', Sequence: 2, ParentItemID: ITEM_PARENT, DaysFromStart: null }),
      makeFakeTemplateItem({ ID: ITEM_PARENT, Name: 'Parent', Sequence: 1, ParentItemID: null, DaysFromStart: null }),
    ];

    getEntityObjectMock.mockResolvedValueOnce(template);
    runViewMock.mockResolvedValueOnce({ Success: true, Results: items });

    const parentTask = makeFakeTask(TASK_PARENT);
    const childTask = makeFakeTask(TASK_CHILD);
    getEntityObjectMock
      .mockResolvedValueOnce(parentTask)
      .mockResolvedValueOnce(childTask);

    const svc = new TaskTemplateService();
    const result = await svc.instantiateTemplate({
      templateID: TMPL_1,
      startDate: new Date('2026-06-01T00:00:00Z'),
    });

    expect(result).toHaveLength(2);
    expect(parentTask.Name).toBe('Parent');
    expect(childTask.ParentID).toBe(TASK_PARENT);
    expect(runViewMock).toHaveBeenCalledTimes(1);
  });

  it('attaches dependencies onto task.Dependencies using pre-loaded item.Dependencies', async () => {
    const template = makeFakeTask(TMPL_1, { TypeID: TYPE_1 });
    const items = [
      makeFakeTemplateItem({ ID: ITEM_A, Name: 'A', Sequence: 1, ParentItemID: null, DaysFromStart: null }),
      makeFakeTemplateItem(
        { ID: ITEM_B, Name: 'B', Sequence: 2, ParentItemID: null, DaysFromStart: null },
        [],
        [{ ItemID: ITEM_B, DependsOnItemID: ITEM_A, DependencyType: 'FinishToStart' }],
      ),
    ];

    getEntityObjectMock.mockResolvedValueOnce(template);
    runViewMock.mockResolvedValueOnce({ Success: true, Results: items });

    // topologicalSortByParent processes root items in reverse order: B first, then A.
    const taskForB = makeFakeTask(TASK_B);
    const taskForA = makeFakeTask(TASK_A);
    getEntityObjectMock.mockResolvedValueOnce(taskForB).mockResolvedValueOnce(taskForA);

    const svc = new TaskTemplateService();
    await svc.instantiateTemplate({
      templateID: TMPL_1,
      startDate: new Date('2026-06-01T00:00:00Z'),
    });

    expect(runViewMock).toHaveBeenCalledTimes(1);
    expect(taskForB.Dependencies.Create).toHaveBeenCalledOnce();
    expect(taskForB.Dependencies.Items[0]).toEqual({
      DependsOnTaskID: TASK_A,
      DependencyType: 'FinishToStart',
    });
    // Task B saved once on creation, once after attaching dependencies
    expect(taskForB.Save).toHaveBeenCalledTimes(2);
    expect(taskForA.Save).toHaveBeenCalledTimes(1);
  });

  it('attaches role-based assignments onto task.Assignments in the same initial task.Save()', async () => {
    const template = makeFakeTask(TMPL_1, { TypeID: TYPE_1 });
    const items = [
      makeFakeTemplateItem(
        { ID: ITEM_1, Name: 'Task', Sequence: 1, ParentItemID: null, DaysFromStart: null },
        [{ RoleID: ROLE_1 }],
      ),
    ];

    getEntityObjectMock.mockResolvedValueOnce(template);
    runViewMock.mockResolvedValueOnce({ Success: true, Results: items });

    const createdTask = makeFakeTask(TASK_1);
    getEntityObjectMock.mockResolvedValueOnce(createdTask);

    const assigneeMap = new Map([[ROLE_1, { entityID: ENTITY_PERSON, recordID: PERSON_1 }]]);

    const svc = new TaskTemplateService();
    await svc.instantiateTemplate({
      templateID: TMPL_1,
      startDate: new Date('2026-06-01T00:00:00Z'),
      assigneeMap,
    });

    expect(runViewMock).toHaveBeenCalledTimes(1);
    expect(createdTask.Assignments.Create).toHaveBeenCalledOnce();
    expect(createdTask.Assignments.Items[0]).toEqual({
      AssigneeEntityID: ENTITY_PERSON,
      AssigneeRecordID: PERSON_1,
      RoleID: ROLE_1,
    });
    // Task + its assignment saved in ONE task.Save()
    expect(createdTask.Save).toHaveBeenCalledOnce();
  });

  it('threads contextUser + provider and wraps multi-task creation in BeginEntityTransaction() with Commit/Rollback', async () => {
    const contextUser = { ID: 'user-1', Email: 'u@example.com' } as UserInfo;
    const commitMock = vi.fn(async () => undefined);
    const rollbackMock = vi.fn(async () => undefined);
    const template = makeFakeTask(TMPL_1, { TypeID: TYPE_1 });
    const firstTask = makeFakeTask(TASK_1);
    const secondTask = makeFakeTask(TASK_B);

    const provider = {
      SupportsEntityTransactions: true,
      BeginEntityTransaction: vi.fn(async () => ({
        Commit: commitMock,
        Rollback: rollbackMock,
        IsNested: false,
      })),
      GetEntityObject: vi.fn()
        .mockResolvedValueOnce(template)
        .mockResolvedValueOnce(firstTask)
        .mockResolvedValueOnce(secondTask),
      RunView: vi.fn(),
    };

    const items = [
      makeFakeTemplateItem({ ID: ITEM_A, Name: 'A', Sequence: 1, ParentItemID: null, DaysFromStart: null }),
      makeFakeTemplateItem({ ID: ITEM_B, Name: 'B', Sequence: 2, ParentItemID: null, DaysFromStart: null }),
    ];
    runViewMock.mockResolvedValueOnce({ Success: true, Results: items });

    const svc = new TaskTemplateService();
    const created = await svc.instantiateTemplate(
      { templateID: TMPL_1, startDate: new Date('2026-06-01T00:00:00Z') },
      contextUser,
      provider as never,
    );

    expect(created).toHaveLength(2);
    expect(runViewProviders).toEqual([provider]);
    expect(provider.GetEntityObject).toHaveBeenCalledWith('MJ_BizApps_Tasks: Task Templates', contextUser);
    expect(provider.GetEntityObject).toHaveBeenCalledWith('MJ_BizApps_Tasks: Tasks', contextUser);
    expect(getEntityObjectMock).not.toHaveBeenCalled();
    expect(provider.BeginEntityTransaction).toHaveBeenCalledOnce();
    expect(commitMock).toHaveBeenCalledOnce();
    expect(rollbackMock).not.toHaveBeenCalled();

    // Now verify Rollback on failure
    const failingTask = makeFakeTask(TASK_1);
    failingTask.Save.mockResolvedValueOnce(false);
    failingTask.LatestResult = { CompleteMessage: 'DB constraint error' };
    provider.GetEntityObject
      .mockResolvedValueOnce(template)
      .mockResolvedValueOnce(failingTask);
    runViewMock.mockResolvedValueOnce({
      Success: true,
      Results: [makeFakeTemplateItem({ ID: ITEM_1, Name: 'FailMe', Sequence: 1, ParentItemID: null, DaysFromStart: null })],
    });

    await expect(svc.instantiateTemplate(
      { templateID: TMPL_1, startDate: new Date('2026-06-01T00:00:00Z') },
      contextUser,
      provider as never,
    )).rejects.toThrow(/DB constraint error/);

    expect(rollbackMock).toHaveBeenCalledOnce();
    expect(commitMock).toHaveBeenCalledOnce(); // still only 1 commit from the first run
  });

  it('refuses a template ID that is not a UUID before any DB lookup', async () => {
    const svc = new TaskTemplateService();
    await expect(svc.instantiateTemplate({
      templateID: "x' OR 1=1 --",
      startDate: new Date('2026-06-01T00:00:00Z'),
    })).rejects.toThrow(/is not a valid ID/);

    expect(getEntityObjectMock).not.toHaveBeenCalled();
    expect(runViewMock).not.toHaveBeenCalled();
  });
});
