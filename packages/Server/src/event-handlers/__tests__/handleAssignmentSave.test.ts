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
  IsValidUUID: (v: string) => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v),
  MJEventType: { ComponentEvent: 'ComponentEvent' },
  MJGlobal: { Instance: { GetGlobalObjectStore: () => ({}), GetEventListener: () => ({ subscribe: () => ({ unsubscribe() {} }) }) } },
}));
vi.mock('@memberjunction/actions', () => ({
  ActionEngineServer: { Instance: { Config: vi.fn(), Actions: [{ ID: 'assign-action' }], RunAction: runAction } },
}));

import { handleAssignmentSave } from '../TaskNotificationHandler.js';

// AssigneeRecordID must be a valid UUID — the handler now rejects anything else.
const PERSON_ID = '0f0e0d0c-0b0a-4000-8000-000000000001';

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

function assignmentCreated() {
  const fields: Record<string, string | null> = { AssigneeRecordID: PERSON_ID, TaskID: 'task-1', RoleID: null };
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
