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

import { TaskAssignmentService } from '../TaskAssignmentService.js';

function makeFakeEntity(initial: Record<string, any> = {}) {
  const data: Record<string, any> = { ...initial };
  const base = {
    data,
    NewRecord: vi.fn(),
    InnerLoad: vi.fn(async () => true),
    Save: vi.fn(async () => true),
    Delete: vi.fn(async () => true),
    Set: vi.fn((f: string, v: any) => { data[f] = v; }),
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

    const fields = assignment.Set.mock.calls.map((c: any[]) => c[0]);
    expect(fields).not.toContain('RoleID');
    expect(fields).not.toContain('RoleNotes');
    expect(fields).not.toContain('AssignedByPersonID');
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
});

// IDs that reach an ExtraFilter must be real UUIDs: anything else is refused before SQL text.
const TASK_4 = 'D0000000-0000-0000-0000-000000000004';
const TASK_5 = 'D0000000-0000-0000-0000-000000000005';

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
    }));
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
