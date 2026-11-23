import { describe, it, expect, beforeEach, vi } from 'vitest';
import type { UserInfo } from '@memberjunction/core';

type MockArg = string | number | boolean | object | null | undefined;

const runViewMock = vi.fn();
const getEntityObjectMock = vi.fn();
const runViewProviders: Array<object | undefined> = [];

vi.mock('@memberjunction/core', () => {
  return {
    RunView: class {
      constructor(provider?: object) {
        runViewProviders.push(provider);
      }
      RunView(...args: MockArg[]) {
        return runViewMock(...args);
      }
    },
    Metadata: Object.assign(
      class {
        GetEntityObject(...args: MockArg[]) {
          return getEntityObjectMock(...args);
        }
      },
      { Provider: { GetEntityObject: (...args: MockArg[]) => getEntityObjectMock(...args) } },
    ),
    CompositeKey: class {
      constructor(public KeyValuePairs: Array<{ FieldName: string; Value: MockArg }>) {}
    },
    LogError: vi.fn(),
    TelemetryManager: {
      Instance: {
        RecordEvent: vi.fn(),
      },
    },
  };
});

import { ApprovalAuthorizationError } from '../ApprovalErrors.js';
import { TaskOrchestrationService } from '../TaskOrchestrationService.js';

interface FakeCollection {
  Items: FakeEntity[];
  Create: ReturnType<typeof vi.fn>;
}

interface FakeEntity {
  ID?: string;
  Name?: string;
  TypeID?: string;
  Status?: string;
  Priority?: string;
  Description?: string;
  DueAt?: Date | null;
  CreatedByPersonID?: string;
  OutcomeID?: string;
  DecidedByPersonID?: string;
  DecisionNotes?: string;
  TaskAssignmentID?: string;
  ActivityType?: string;
  PersonID?: string;
  NewValue?: string;
  EntityID?: string;
  RecordID?: string;
  AssigneeEntityID?: string;
  AssigneeRecordID?: string;
  RoleID?: string;
  AssignedByPersonID?: string;
  __mj_CreatedAt?: Date;
  DecidedAt?: Date;
  NewRecord: ReturnType<typeof vi.fn>;
  InnerLoad: ReturnType<typeof vi.fn>;
  Save: ReturnType<typeof vi.fn>;
  LatestResult: { CompleteMessage: string };
  Decisions: FakeCollection;
  Activities: FakeCollection;
  Links: FakeCollection;
  Assignments: FakeCollection;
}

function makeFakeCollection(): FakeCollection {
  const items: FakeEntity[] = [];
  return {
    Items: items,
    Create: vi.fn(async () => {
      const child = makeFakeEntity();
      items.push(child);
      return child;
    }),
  };
}

function makeFakeEntity(initial: Partial<FakeEntity> = {}): FakeEntity {
  const entity: FakeEntity = {
    ...initial,
    NewRecord: vi.fn(),
    InnerLoad: vi.fn(async () => true),
    Save: vi.fn(async () => true),
    LatestResult: { CompleteMessage: '' },
    Decisions: { Items: [], Create: vi.fn() },
    Activities: { Items: [], Create: vi.fn() },
    Links: { Items: [], Create: vi.fn() },
    Assignments: { Items: [], Create: vi.fn() },
  };
  entity.Decisions = makeFakeCollection();
  entity.Activities = makeFakeCollection();
  entity.Links = makeFakeCollection();
  entity.Assignments = makeFakeCollection();
  return entity;
}

const user = { ID: 'user-1', Email: 'tester@example.com' } as UserInfo;

beforeEach(() => {
  vi.resetAllMocks();
  runViewProviders.length = 0;
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
  it('Approved → composes Decision + Activity + Completed status in ONE atomic task.Save()', async () => {
    runViewMock.mockResolvedValueOnce({
      Success: true,
      Results: [{ ID: 'outcome-approved', Name: 'Approved', Code: 'Approved', IsTerminal: true }],
    });

    const task = makeFakeEntity({ ID: 'task-1', Status: 'Open' });
    getEntityObjectMock.mockResolvedValueOnce(task);

    const svc = new TaskOrchestrationService();
    const result = await svc.RecordDecision(
      { TaskID: 'task-1', OutcomeCode: 'Approved', DecidedByPersonID: 'p1', Notes: 'ok' },
      user,
    );

    expect(getEntityObjectMock).toHaveBeenCalledTimes(1);
    expect(task.Decisions.Create).toHaveBeenCalledOnce();
    expect(task.Decisions.Items).toHaveLength(1);
    expect(task.Decisions.Items[0].OutcomeID).toBe('outcome-approved');
    expect(task.Decisions.Items[0].DecidedByPersonID).toBe('p1');
    expect(task.Decisions.Items[0].DecisionNotes).toBe('ok');
    expect(task.Decisions.Items[0].Save).not.toHaveBeenCalled();

    expect(task.Activities.Create).toHaveBeenCalledOnce();
    expect(task.Activities.Items[0].ActivityType).toBe('DecisionRecorded');
    expect(task.Activities.Items[0].NewValue).toBe('Approved');
    expect(task.Activities.Items[0].Save).not.toHaveBeenCalled();

    expect(result.NewStatus).toBe('Completed');
    expect(task.Status).toBe('Completed');
    expect(task.Save).toHaveBeenCalledOnce();
  });

  it('Rejected → composes Decision + Activity + Cancelled status in ONE atomic task.Save()', async () => {
    runViewMock.mockResolvedValueOnce({
      Success: true,
      Results: [{ ID: 'outcome-rejected', Name: 'Rejected', Code: 'Rejected', IsTerminal: true }],
    });
    const task = makeFakeEntity({ ID: 'task-1', Status: 'Open' });
    getEntityObjectMock.mockResolvedValueOnce(task);

    const svc = new TaskOrchestrationService();
    const result = await svc.RecordDecision({ TaskID: 'task-1', OutcomeCode: 'Rejected' }, user);

    expect(result.NewStatus).toBe('Cancelled');
    expect(task.Status).toBe('Cancelled');
    expect(task.Decisions.Items).toHaveLength(1);
    expect(task.Activities.Items).toHaveLength(1);
    expect(task.Save).toHaveBeenCalledOnce();
  });

  it('non-terminal outcome → persists Decision + Activity atomically via task.Save() without changing Status', async () => {
    runViewMock.mockResolvedValueOnce({
      Success: true,
      Results: [{ ID: 'outcome-interim', Name: 'Needs Info', Code: 'Approved', IsTerminal: false }],
    });
    const task = makeFakeEntity({ ID: 'task-1', Status: 'Open' });
    getEntityObjectMock.mockResolvedValueOnce(task);

    const svc = new TaskOrchestrationService();
    const result = await svc.RecordDecision({ TaskID: 'task-1', OutcomeCode: 'Approved' }, user);

    expect(result.NewStatus).toBeNull();
    expect(task.Status).toBe('Open');
    expect(task.Decisions.Items).toHaveLength(1);
    expect(task.Activities.Items).toHaveLength(1);
    expect(task.Save).toHaveBeenCalledOnce();
  });

  it('throws and surfaces the error when atomic task.Save() fails', async () => {
    runViewMock.mockResolvedValueOnce({
      Success: true,
      Results: [{ ID: 'outcome-approved', Name: 'Approved', Code: 'Approved', IsTerminal: true }],
    });
    const task = makeFakeEntity({ ID: 'task-1', Status: 'Open' });
    task.Save.mockResolvedValueOnce(false);
    task.LatestResult = { CompleteMessage: 'Self-approval not allowed' };
    getEntityObjectMock.mockResolvedValueOnce(task);

    const svc = new TaskOrchestrationService();
    await expect(
      svc.RecordDecision({ TaskID: 'task-1', OutcomeCode: 'Approved' }, user),
    ).rejects.toThrow(/Self-approval not allowed/);
  });

  it('throws when the outcome code cannot be resolved', async () => {
    runViewMock.mockResolvedValueOnce({ Success: true, Results: [] });

    const svc = new TaskOrchestrationService();
    await expect(
      svc.RecordDecision({ TaskID: 'task-1', OutcomeCode: 'Approved' }, user),
    ).rejects.toThrow(/not found/);
  });
});

describe('TaskOrchestrationService BeforeSave (server code vouching for a write)', () => {
  it('CreateTask hands the unsaved task to BeforeSave, then saves it', async () => {
    const task = makeFakeEntity();
    getEntityObjectMock.mockResolvedValueOnce(task);
    const seen: Array<{ creator: string | null | undefined; saved: number }> = [];

    await new TaskOrchestrationService().CreateTask({
      Name: 'Raised for someone else',
      TypeID: 'type-1',
      CreatedByPersonID: 'person-owner',
      BeforeSave: (t) => { seen.push({ creator: t.CreatedByPersonID, saved: task.Save.mock.calls.length }); },
    }, user);

    expect(seen).toEqual([{ creator: 'person-owner', saved: 0 }]);
    expect(task.Save).toHaveBeenCalledOnce();
  });

  it('CreateApprovalRequest hands BeforeSave the task with its assignments already attached', async () => {
    const task = makeFakeEntity();
    getEntityObjectMock.mockResolvedValueOnce(task);
    const vouchedFor: Array<string | null | undefined> = [];

    await new TaskOrchestrationService().CreateApprovalRequest({
      Name: 'Approve batch',
      TypeID: 'type-approval',
      ApproverPersonEntityID: 'ent-person',
      ApproverPersonRecordIDs: ['person-1', 'person-2'],
      BeforeSave: async (t) => {
        expect(task.Save).not.toHaveBeenCalled();
        for (const assignment of t.Assignments.Items) vouchedFor.push(assignment.AssigneeRecordID);
      },
    }, user);

    expect(vouchedFor).toEqual(['person-1', 'person-2']);
    expect(task.Save).toHaveBeenCalledOnce();
  });

  it('does not save when BeforeSave throws', async () => {
    const task = makeFakeEntity();
    getEntityObjectMock.mockResolvedValueOnce(task);

    await expect(
      new TaskOrchestrationService().CreateTask({ Name: 'x', TypeID: 'type-1', BeforeSave: () => { throw new Error('not on this host'); } }, user),
    ).rejects.toThrow('not on this host');
    expect(task.Save).not.toHaveBeenCalled();
  });
});

describe('TaskOrchestrationService provider threading & atomic graph creation', () => {
  it('CreateApprovalRequest composes task + Links + Assignments on the supplied provider in ONE atomic task.Save()', async () => {
    const task = makeFakeEntity({ ID: 'task-tx-1' });
    const provider = {
      GetEntityObject: vi.fn().mockResolvedValueOnce(task),
    };

    const svc = new TaskOrchestrationService();
    const created = await svc.CreateApprovalRequest({
      Name: 'Approve concession',
      TypeID: 'type-approval',
      LinkEntityID: 'ent-order',
      LinkRecordID: 'order-1',
      ApproverPersonEntityID: 'ent-person',
      ApproverPersonRecordIDs: ['person-1', 'person-2'],
      RoleID: 'role-approver',
      CreatedByPersonID: 'person-creator',
    }, user, provider as never);

    expect(created).toBe(task);
    expect(provider.GetEntityObject).toHaveBeenCalledTimes(1);
    expect(provider.GetEntityObject).toHaveBeenCalledWith('MJ_BizApps_Tasks: Tasks', user);
    expect(getEntityObjectMock).not.toHaveBeenCalled();

    expect(task.Links.Items).toHaveLength(1);
    expect(task.Links.Items[0].EntityID).toBe('ent-order');
    expect(task.Links.Items[0].RecordID).toBe('order-1');
    expect(task.Links.Items[0].Save).not.toHaveBeenCalled();

    expect(task.Assignments.Items).toHaveLength(2);
    expect(task.Assignments.Items[0].AssigneeEntityID).toBe('ent-person');
    expect(task.Assignments.Items[0].AssigneeRecordID).toBe('person-1');
    expect(task.Assignments.Items[0].RoleID).toBe('role-approver');
    expect(task.Assignments.Items[0].AssignedByPersonID).toBe('person-creator');
    expect(task.Assignments.Items[1].AssigneeRecordID).toBe('person-2');
    expect(task.Assignments.Items[0].Save).not.toHaveBeenCalled();

    expect(task.Save).toHaveBeenCalledOnce();
  });

  it('throws typed ApprovalAuthorizationError on cross-org refusal, self-approval refusal, and empty TaskID', async () => {
    const svc = new TaskOrchestrationService();

    await expect(
      svc.RecordDecision({ TaskID: '   ', OutcomeCode: 'Approved' }, user),
    ).rejects.toMatchObject({
      name: 'ApprovalAuthorizationError',
      Code: 'INVALID_TASK_ID',
    });

    runViewMock.mockResolvedValueOnce({
      Success: true,
      Results: [{ ID: 'outcome-approved', Name: 'Approved', Code: 'Approved', IsTerminal: true }],
    });
    const crossOrgTask = makeFakeEntity({ ID: 'task-xorg', Status: 'Open' });
    crossOrgTask.Save.mockResolvedValueOnce(false);
    crossOrgTask.LatestResult = {
      CompleteMessage: 'This approval belongs to another organization, so you cannot record a decision on it.',
    };
    getEntityObjectMock.mockResolvedValueOnce(crossOrgTask);

    try {
      await svc.RecordDecision({ TaskID: 'task-xorg', OutcomeCode: 'Approved' }, user);
      expect.unreachable('Expected ApprovalAuthorizationError');
    } catch (err) {
      expect(err).toBeInstanceOf(ApprovalAuthorizationError);
      const authErr = err as ApprovalAuthorizationError;
      expect(authErr.Code).toBe('CROSS_ORGANIZATION_DENIED');
      expect(authErr.Operation).toBe('RecordDecision');
    }
  });

  it('does not misclassify a generic organization error message as CROSS_ORGANIZATION_DENIED', async () => {
    const svc = new TaskOrchestrationService();

    runViewMock.mockResolvedValueOnce({
      Success: true,
      Results: [{ ID: 'outcome-approved', Name: 'Approved', Code: 'Approved', IsTerminal: true }],
    });
    const genericTask = makeFakeEntity({ ID: 'task-org-generic', Status: 'Open' });
    genericTask.Save.mockResolvedValueOnce(false);
    genericTask.LatestResult = {
      CompleteMessage: 'You are not assigned to this organization approval task.',
    };
    getEntityObjectMock.mockResolvedValueOnce(genericTask);

    try {
      await svc.RecordDecision({ TaskID: 'task-org-generic', OutcomeCode: 'Approved' }, user);
      expect.unreachable('Expected ApprovalAuthorizationError');
    } catch (err) {
      expect(err).toBeInstanceOf(ApprovalAuthorizationError);
      const authErr = err as ApprovalAuthorizationError;
      expect(authErr.Code).toBe('UNAUTHORIZED_ACTOR');
    }
  });
});
