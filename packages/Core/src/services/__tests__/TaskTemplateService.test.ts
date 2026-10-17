import { describe, it, expect, beforeEach, vi } from 'vitest';

const runViewMock = vi.fn();
const getEntityObjectMock = vi.fn();

vi.mock('@memberjunction/core', () => ({
  RunView: class {
    RunView(...args: any[]) { return runViewMock(...args); }
  },
  Metadata: {
    Provider: { GetEntityObject: (...args: any[]) => getEntityObjectMock(...args) },
  },
  CompositeKey: class { constructor(public KeyValuePairs: any[]) {} },
  BaseEntity: class {},
}));

import { TaskTemplateService } from '../TaskTemplateService.js';

// instantiateTemplate now requires a valid UUID templateID, and template item IDs
// are UUID-validated before interpolation into filters.
const TMPL_ID = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const ITEM_1 = '11111111-1111-4111-8111-111111111111';
const ITEM_PARENT = '22222222-2222-4222-8222-222222222222';
const ITEM_CHILD = '33333333-3333-4333-8333-333333333333';
const ITEM_A = '44444444-4444-4444-8444-444444444444';
const ITEM_B = '55555555-5555-4555-8555-555555555555';

/** Fake entity that auto-assigns an ID on NewRecord so item→task mapping works. */
function makeFakeTask(id: string, initial: Record<string, any> = {}) {
  const data: Record<string, any> = { ID: id, ...initial };
  return {
    data,
    NewRecord: vi.fn(),
    InnerLoad: vi.fn(async () => true),
    Save: vi.fn(async () => true),
    Set: vi.fn((f: string, v: any) => { data[f] = v; }),
    Get: vi.fn((f: string) => data[f]),
  };
}

beforeEach(() => vi.clearAllMocks());

describe('TaskTemplateService.instantiateTemplate', () => {
  it('returns empty array when the template has no items', async () => {
    const template = makeFakeTask(TMPL_ID, { TypeID: 'type-1' });
    getEntityObjectMock.mockResolvedValueOnce(template); // template load
    runViewMock.mockResolvedValueOnce({ Results: [] });   // items query → none

    const svc = new TaskTemplateService();
    const result = await svc.instantiateTemplate({
      templateID: TMPL_ID,
      startDate: new Date('2026-06-01T00:00:00Z'),
    });

    expect(result).toEqual([]);
  });

  it('creates a task per item, applies template TypeID, and computes DueAt from DaysFromStart', async () => {
    const template = makeFakeTask(TMPL_ID, { TypeID: 'type-1' });
    // one root item, due 5 days after start
    const items = [
      { ID: ITEM_1, Name: 'Kickoff', Description: 'd', Priority: 'High', HoursEstimated: 4, Sequence: 1, DaysFromStart: 5, ParentItemID: null },
    ];

    getEntityObjectMock.mockResolvedValueOnce(template); // template load
    runViewMock.mockResolvedValueOnce({ Results: items }); // items query

    const createdTask = makeFakeTask('task-1');
    getEntityObjectMock.mockResolvedValueOnce(createdTask); // task creation

    // createAssignmentsForItem: no assigneeMap → returns early (no RunView)
    // createDependencies: items query, then deps query
    runViewMock
      .mockResolvedValueOnce({ Results: items })   // createDependencies items
      .mockResolvedValueOnce({ Results: [] });     // createDependencies deps → none

    const svc = new TaskTemplateService();
    const start = new Date('2026-06-01T00:00:00Z');
    const result = await svc.instantiateTemplate({ templateID: TMPL_ID, startDate: start });

    expect(result).toHaveLength(1);
    expect(createdTask.Set).toHaveBeenCalledWith('Name', 'Kickoff');
    expect(createdTask.Set).toHaveBeenCalledWith('Priority', 'High');
    expect(createdTask.Set).toHaveBeenCalledWith('TypeID', 'type-1');

    // DueAt should be start + 5 days
    const dueCall = createdTask.Set.mock.calls.find((c: any[]) => c[0] === 'DueAt');
    expect(dueCall).toBeTruthy();
    const due = dueCall![1] as Date;
    const expected = new Date(start);
    expected.setDate(expected.getDate() + 5);
    expect(due.getTime()).toBe(expected.getTime());
  });

  it('creates parent tasks before children and wires ParentID via the item→task map', async () => {
    const template = makeFakeTask(TMPL_ID, { TypeID: 'type-1' });
    // child listed BEFORE parent to exercise topological sort
    const items = [
      { ID: ITEM_CHILD, Name: 'Child', Sequence: 2, ParentItemID: ITEM_PARENT, DaysFromStart: null },
      { ID: ITEM_PARENT, Name: 'Parent', Sequence: 1, ParentItemID: null, DaysFromStart: null },
    ];

    getEntityObjectMock.mockResolvedValueOnce(template);
    runViewMock.mockResolvedValueOnce({ Results: items });

    // Parent must be created first (topo sort), then child.
    const parentTask = makeFakeTask('task-parent');
    const childTask = makeFakeTask('task-child');
    getEntityObjectMock
      .mockResolvedValueOnce(parentTask)  // parent created first
      .mockResolvedValueOnce(childTask);  // then child

    runViewMock
      .mockResolvedValueOnce({ Results: items }) // createDependencies items
      .mockResolvedValueOnce({ Results: [] });   // deps none

    const svc = new TaskTemplateService();
    const result = await svc.instantiateTemplate({
      templateID: TMPL_ID,
      startDate: new Date('2026-06-01T00:00:00Z'),
    });

    expect(result).toHaveLength(2);
    // first created should be the parent
    expect(parentTask.Set).toHaveBeenCalledWith('Name', 'Parent');
    // child should have ParentID set to the parent's created task ID
    expect(childTask.Set).toHaveBeenCalledWith('ParentID', 'task-parent');
  });

  it('recreates dependencies between newly created tasks', async () => {
    const template = makeFakeTask(TMPL_ID, { TypeID: 'type-1' });
    const items = [
      { ID: ITEM_A, Name: 'A', Sequence: 1, ParentItemID: null, DaysFromStart: null },
      { ID: ITEM_B, Name: 'B', Sequence: 2, ParentItemID: null, DaysFromStart: null },
    ];

    getEntityObjectMock.mockResolvedValueOnce(template);
    runViewMock.mockResolvedValueOnce({ Results: items });

    // topologicalSortByParent processes root items in reverse order, so the
    // first created task corresponds to item-b and the second to item-a.
    const firstCreated = makeFakeTask('task-for-item-b');
    const secondCreated = makeFakeTask('task-for-item-a');
    getEntityObjectMock.mockResolvedValueOnce(firstCreated).mockResolvedValueOnce(secondCreated);

    // createDependencies: items query, then deps query (B depends on A)
    runViewMock
      .mockResolvedValueOnce({ Results: items })
      .mockResolvedValueOnce({ Results: [{ ItemID: ITEM_B, DependsOnItemID: ITEM_A, DependencyType: 'FinishToStart' }] });

    const taskDep = makeFakeTask('dep-1');
    getEntityObjectMock.mockResolvedValueOnce(taskDep); // dependency creation

    const svc = new TaskTemplateService();
    await svc.instantiateTemplate({
      templateID: TMPL_ID,
      startDate: new Date('2026-06-01T00:00:00Z'),
    });

    // dep maps item-b → task-for-item-b (TaskID), item-a → task-for-item-a (DependsOnTaskID)
    expect(taskDep.Set).toHaveBeenCalledWith('TaskID', 'task-for-item-b');
    expect(taskDep.Set).toHaveBeenCalledWith('DependsOnTaskID', 'task-for-item-a');
    expect(taskDep.Set).toHaveBeenCalledWith('DependencyType', 'FinishToStart');
  });

  it('creates role-based assignments when an assigneeMap is supplied', async () => {
    const template = makeFakeTask(TMPL_ID, { TypeID: 'type-1' });
    const items = [
      { ID: ITEM_1, Name: 'Task', Sequence: 1, ParentItemID: null, DaysFromStart: null },
    ];

    getEntityObjectMock.mockResolvedValueOnce(template);
    runViewMock.mockResolvedValueOnce({ Results: items });

    const createdTask = makeFakeTask('task-1');
    getEntityObjectMock.mockResolvedValueOnce(createdTask);

    // createAssignmentsForItem: roles query returns one role mapped in assigneeMap
    runViewMock.mockResolvedValueOnce({ Results: [{ RoleID: 'role-1' }] });
    const assignment = makeFakeTask('assignment-1');
    getEntityObjectMock.mockResolvedValueOnce(assignment);

    // createDependencies
    runViewMock
      .mockResolvedValueOnce({ Results: items })
      .mockResolvedValueOnce({ Results: [] });

    const assigneeMap = new Map([['role-1', { entityID: 'entity-1', recordID: 'person-1' }]]);

    const svc = new TaskTemplateService();
    await svc.instantiateTemplate({
      templateID: TMPL_ID,
      startDate: new Date('2026-06-01T00:00:00Z'),
      assigneeMap,
    });

    expect(assignment.Set).toHaveBeenCalledWith('TaskID', 'task-1');
    expect(assignment.Set).toHaveBeenCalledWith('RoleID', 'role-1');
    expect(assignment.Set).toHaveBeenCalledWith('AssigneeRecordID', 'person-1');
  });

  it('throws when templateID is not a valid UUID', async () => {
    const svc = new TaskTemplateService();
    await expect(svc.instantiateTemplate({
      templateID: "x' OR '1'='1",
      startDate: new Date('2026-06-01T00:00:00Z'),
    })).rejects.toThrow('not a valid UUID');
    expect(runViewMock).not.toHaveBeenCalled();
  });
});
