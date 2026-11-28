import { describe, it, expect, beforeEach, vi } from 'vitest';

const runViewMock = vi.fn();
const getEntityObjectMock = vi.fn();

vi.mock('@memberjunction/core', () => ({
  RunView: class {
    RunView(...args: unknown[]) { return runViewMock(...args); }
  },
  Metadata: {
    Provider: { GetEntityObject: (...args: unknown[]) => getEntityObjectMock(...args) },
  },
  CompositeKey: class { constructor(public KeyValuePairs: unknown[]) {} },
  BaseEntity: class {},
  LogError: vi.fn(),
}));

import { TaskAssignmentService } from '../TaskAssignmentService.js';

const TASK_4 = '44444444-4444-4444-8444-444444444444';
const TASK_5 = '55555555-5555-4555-8555-555555555555';

function makeFakeEntity(initial: Record<string, unknown> = {}) {
  const data: Record<string, unknown> = { ...initial };
  const base = {
    data,
    NewRecord: vi.fn(),
    InnerLoad: vi.fn(async () => true),
    Save: vi.fn(async () => true),
    Delete: vi.fn(async () => true),
    LatestResult: { CompleteMessage: '' },
    Set: vi.fn((f: string, v: unknown) => { data[f] = v; }),
    Get: vi.fn((f: string) => data[f]),
  };
  return new Proxy(base, {
    get(target, prop, receiver) {
      if (typeof prop === 'string' && prop in target) return Reflect.get(target, prop, receiver);
      if (typeof prop === 'string') return target.Get(prop);
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

beforeEach(() => vi.clearAllMocks());

describe('TaskAssignmentService.assignToTask', () => {
  it('creates an assignment with all provided fields and logs an activity', async () => {
    const assignment = makeFakeEntity();
    const activity = makeFakeEntity();
    // 1st GetEntityObject → assignment; 2nd (inside logActivity) → activity
    getEntityObjectMock.mockResolvedValueOnce(assignment).mockResolvedValueOnce(activity);

    const svc = new TaskAssignmentService();
    const result = await svc.assignToTask({
      taskID: 'task-1',
      assigneeEntityID: 'entity-1',
      assigneeRecordID: 'person-1',
      roleID: 'role-1',
      roleNotes: 'lead',
      assignedByPersonID: 'person-9',
    });

    expect(assignment.NewRecord).toHaveBeenCalledOnce();
    expect(assignment.Set).toHaveBeenCalledWith('TaskID', 'task-1');
    expect(assignment.Set).toHaveBeenCalledWith('AssigneeEntityID', 'entity-1');
    expect(assignment.Set).toHaveBeenCalledWith('AssigneeRecordID', 'person-1');
    expect(assignment.Set).toHaveBeenCalledWith('RoleID', 'role-1');
    expect(assignment.Set).toHaveBeenCalledWith('RoleNotes', 'lead');
    expect(assignment.Set).toHaveBeenCalledWith('AssignedByPersonID', 'person-9');
    expect(assignment.Save).toHaveBeenCalledOnce();

    // activity logged with AssignmentAdded
    expect(activity.Set).toHaveBeenCalledWith('ActivityType', 'AssignmentAdded');
    expect(activity.Set).toHaveBeenCalledWith('TaskID', 'task-1');
    expect(result).toBe(assignment);
  });

  it('omits optional fields when not provided', async () => {
    const assignment = makeFakeEntity();
    const activity = makeFakeEntity();
    getEntityObjectMock.mockResolvedValueOnce(assignment).mockResolvedValueOnce(activity);

    const svc = new TaskAssignmentService();
    await svc.assignToTask({
      taskID: 'task-2',
      assigneeEntityID: 'entity-1',
      assigneeRecordID: 'person-2',
    });

    const fields = assignment.Set.mock.calls.map((c: unknown[]) => c[0]);
    expect(fields).not.toContain('RoleID');
    expect(fields).not.toContain('RoleNotes');
    expect(fields).not.toContain('AssignedByPersonID');
  });

  it('creates both the assignment and the activity on the supplied provider', async () => {
    const assignment = makeFakeEntity();
    const activity = makeFakeEntity();
    const provider = {
      GetEntityObject: vi.fn()
        .mockResolvedValueOnce(assignment)
        .mockResolvedValueOnce(activity),
    };

    const svc = new TaskAssignmentService();
    await svc.assignToTask({
      taskID: 'task-tx',
      assigneeEntityID: 'entity-1',
      assigneeRecordID: 'person-2',
    }, undefined, provider as never);

    expect(provider.GetEntityObject).toHaveBeenCalledTimes(2);
    expect(provider.GetEntityObject).toHaveBeenNthCalledWith(1, 'MJ_BizApps_Tasks: Task Assignments', undefined);
    expect(provider.GetEntityObject).toHaveBeenNthCalledWith(2, 'MJ_BizApps_Tasks: Task Activities', undefined);
    expect(getEntityObjectMock).not.toHaveBeenCalled();
  });
});

describe('TaskAssignmentService.assignToTask — beforeSave (server code vouching for the assignee)', () => {
  it('hands the unsaved assignment to beforeSave, then saves it', async () => {
    const assignment = makeFakeEntity();
    getEntityObjectMock.mockResolvedValueOnce(assignment).mockResolvedValueOnce(makeFakeEntity());
    const seen: Array<{ assignee: unknown; saved: number }> = [];

    await new TaskAssignmentService().assignToTask({
      taskID: 'task-1',
      assigneeEntityID: 'entity-1',
      assigneeRecordID: 'person-1',
      beforeSave: (a) => { seen.push({ assignee: a.AssigneeRecordID, saved: assignment.Save.mock.calls.length }); },
    });

    expect(seen).toEqual([{ assignee: 'person-1', saved: 0 }]);
    expect(assignment.Save).toHaveBeenCalledOnce();
  });
});

describe('TaskAssignmentService.assignToTask — a refused save', () => {
  it('throws with the save message and logs no activity', async () => {
    const assignment = makeFakeEntity();
    assignment.Save.mockResolvedValueOnce(false);
    (assignment as Record<string, unknown>).LatestResult = { CompleteMessage: 'Permission denied' };
    getEntityObjectMock.mockResolvedValueOnce(assignment);

    const svc = new TaskAssignmentService();
    await expect(svc.assignToTask({
      taskID: 'task-6',
      assigneeEntityID: 'entity-1',
      assigneeRecordID: 'person-6',
    })).rejects.toThrow('Failed to assign person-6 to task task-6: Permission denied');
    expect(getEntityObjectMock).toHaveBeenCalledOnce();
  });
});

describe('TaskAssignmentService.removeAssignment', () => {
  it('loads, deletes, and logs an AssignmentRemoved activity', async () => {
    const assignment = makeFakeEntity({ TaskID: 'task-3', AssigneeRecordID: 'person-3' });
    const activity = makeFakeEntity();
    getEntityObjectMock.mockResolvedValueOnce(assignment).mockResolvedValueOnce(activity);

    const svc = new TaskAssignmentService();
    await svc.removeAssignment('assignment-1', 'person-9');

    expect(assignment.InnerLoad).toHaveBeenCalledOnce();
    expect(assignment.Delete).toHaveBeenCalledOnce();
    expect(activity.Set).toHaveBeenCalledWith('ActivityType', 'AssignmentRemoved');
    expect(activity.Set).toHaveBeenCalledWith('TaskID', 'task-3');
    expect(activity.Set).toHaveBeenCalledWith('PreviousValue', 'person-3');
  });

  it('throws and skips activity logging when Delete() is refused', async () => {
    const assignment = makeFakeEntity({ TaskID: 'task-3', AssigneeRecordID: 'person-3' });
    assignment.Delete.mockResolvedValueOnce(false);
    assignment.LatestResult = { CompleteMessage: 'Delete refused by permission policy' };
    getEntityObjectMock.mockResolvedValueOnce(assignment);

    const svc = new TaskAssignmentService();
    await expect(svc.removeAssignment('assignment-1', 'person-9'))
      .rejects.toThrow("Failed to remove assignment 'assignment-1' from task task-3: Delete refused by permission policy");
    expect(getEntityObjectMock).toHaveBeenCalledOnce();
  });
});

describe('TaskAssignmentService.getAssignmentsForTask', () => {
  it('returns the RunView results array', async () => {
    const rows = [makeFakeEntity(), makeFakeEntity()];
    runViewMock.mockResolvedValueOnce({ Results: rows });

    const svc = new TaskAssignmentService();
    const result = await svc.getAssignmentsForTask(TASK_4);

    expect(result).toBe(rows);
    expect(runViewMock).toHaveBeenCalledWith(expect.objectContaining({
      EntityName: 'MJ_BizApps_Tasks: Task Assignments',
      ExtraFilter: `TaskID = '${TASK_4}'`,
    }), undefined);
  });

  it('returns an empty array when RunView yields no results', async () => {
    runViewMock.mockResolvedValueOnce(null);
    const svc = new TaskAssignmentService();
    const result = await svc.getAssignmentsForTask(TASK_5);
    expect(result).toEqual([]);
  });

  it('refuses a task ID that is not a UUID before it reaches a filter', async () => {
    const svc = new TaskAssignmentService();
    await expect(svc.getAssignmentsForTask("x' OR 1=1 --")).rejects.toThrow(/is not a valid ID/);
    expect(runViewMock).not.toHaveBeenCalled();
  });
});
