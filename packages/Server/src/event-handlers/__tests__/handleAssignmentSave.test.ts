import { describe, it, expect, beforeEach, vi } from 'vitest';

type ViewParams = { EntityName: string; ExtraFilter?: string; Fields?: string[] };

const { runView, runAction, saveNotification } = vi.hoisted(() => ({
  runView: vi.fn(),
  runAction: vi.fn(),
  saveNotification: vi.fn(),
}));

vi.mock('@memberjunction/core', () => ({
  BaseEntity: class { static BaseEventCode = 'BaseEntity'; },
  LogError: vi.fn(),
  LogStatus: vi.fn(),
  Metadata: class {
    GetEntityObject() {
      return Promise.resolve({ NewRecord() {}, Set() {}, Save: saveNotification });
    }
  },
  RunView: class { RunView = runView; },
  UserInfo: class {},
}));
vi.mock('@memberjunction/global', () => ({
  MJEventType: { ComponentEvent: 'ComponentEvent' },
  MJGlobal: { Instance: { GetGlobalObjectStore: () => ({}), GetEventListener: () => ({ subscribe: () => ({ unsubscribe() {} }) }) } },
  // Faithful stand-in for the real validator: 8-4-4-4-12 hex.
  IsValidUUID: (v: string) => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v),
}));
vi.mock('@memberjunction/actions', () => ({
  ActionEngineServer: { Instance: { Config: vi.fn(), Actions: [{ ID: 'assign-action' }], RunAction: runAction } },
}));

import { handleAssignmentSave } from '../TaskNotificationHandler.js';

// AssigneeRecordID is a polymorphic NVARCHAR column; the handler only accepts UUID values,
// so the fixture must be a real UUID.
const PERSON_ID = '0b9c551c-27dc-4d53-9b3e-2a7d54e27e5a';

const task = {
  Get: (field: string) => ({ ID: 'task-1', Name: 'Approve discount', Status: 'Open', TypeID: 'type-1' } as Record<string, string>)[field],
};

function mockViews(linkedUserID: string | null): void {
  runView.mockImplementation((params: ViewParams) => {
    switch (params.EntityName) {
      case 'MJ_BizApps_Common: People':
        return Promise.resolve({
          Success: true,
          Results: params.Fields?.includes('LinkedUserID')
            ? [{ ID: PERSON_ID, LinkedUserID: linkedUserID }]
            : [{ ID: PERSON_ID, FirstName: 'Pat', LastName: 'Doe' }],
        });
      case 'MJ_BizApps_Tasks: Tasks':
        return Promise.resolve({ Success: true, Results: params.ExtraFilter ? [task] : [] });
      case 'MJ_BizApps_Tasks: Task Types':
        return Promise.resolve({ Success: true, Results: [{ OnAssignActionID: 'assign-action' }] });
      default:
        return Promise.resolve({ Success: true, Results: [] });
    }
  });
}

function assignmentCreated(assigneeRecordID: string = PERSON_ID) {
  const fields: Record<string, string | null> = { AssigneeRecordID: assigneeRecordID, TaskID: 'task-1', RoleID: null };
  return {
    type: 'save',
    saveSubType: 'create',
    baseEntity: { ContextCurrentUser: { ID: 'user-ctx' }, Get: (f: string) => fields[f] },
  } as unknown as Parameters<typeof handleAssignmentSave>[0];
}

const paramsPassed = () =>
  Object.fromEntries((runAction.mock.calls[0][0].Params as Array<{ Name: string; Value: unknown }>).map((p) => [p.Name, p.Value]));

beforeEach(() => {
  vi.clearAllMocks();
  runAction.mockResolvedValue({ Success: true });
  saveNotification.mockResolvedValue(true);
});

describe('handleAssignmentSave', () => {
  it('passes the assignee and task type to the OnAssign action', async () => {
    mockViews('user-1');

    await handleAssignmentSave(assignmentCreated());

    expect(runAction).toHaveBeenCalledOnce();
    expect(paramsPassed()).toMatchObject({
      TaskID: 'task-1',
      TaskName: 'Approve discount',
      TaskTypeID: 'type-1',
      AssigneePersonID: PERSON_ID,
      AssigneeName: 'Pat Doe',
    });
    expect(saveNotification).toHaveBeenCalledOnce();
  });

  it('still invokes the OnAssign action when the assignee has no linked user', async () => {
    mockViews(null);

    await handleAssignmentSave(assignmentCreated());

    expect(saveNotification).not.toHaveBeenCalled();
    expect(runAction).toHaveBeenCalledOnce();
    expect(paramsPassed().AssigneePersonID).toBe(PERSON_ID);
  });

  it('never interpolates a non-UUID AssigneeRecordID into a People filter (SQLi guard)', async () => {
    mockViews('user-1');
    const payload = `x' OR 1=1 --`;

    await handleAssignmentSave(assignmentCreated(payload));

    // The guard short-circuits the People lookups, so no filter ever carries the payload…
    const peopleFilters = runView.mock.calls
      .map((c) => c[0] as ViewParams)
      .filter((p) => p.EntityName === 'MJ_BizApps_Common: People')
      .map((p) => p.ExtraFilter ?? '');
    expect(peopleFilters.every((f) => !f.includes(payload))).toBe(true);
    // …no notification can be resolved, but the OnAssign hook still fires.
    expect(saveNotification).not.toHaveBeenCalled();
    expect(runAction).toHaveBeenCalledOnce();
  });

  it('still invokes the OnAssign action when the notification throws', async () => {
    mockViews('user-1');
    saveNotification.mockRejectedValue(new Error('notification store down'));

    await handleAssignmentSave(assignmentCreated());

    expect(runAction).toHaveBeenCalledOnce();
  });

  it('ignores updates to an existing assignment', async () => {
    mockViews('user-1');
    const event = { ...assignmentCreated(), saveSubType: 'update' } as Parameters<typeof handleAssignmentSave>[0];

    await handleAssignmentSave(event);

    expect(runAction).not.toHaveBeenCalled();
  });
});
