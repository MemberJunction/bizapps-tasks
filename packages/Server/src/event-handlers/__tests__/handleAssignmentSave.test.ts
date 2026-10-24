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
  // Real-shaped stand-in: sql-guards' GuidLiteral validates every id reaching SQL text.
  IsValidUUID: (id: unknown): boolean =>
    typeof id === 'string' && /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.test(id),
}));
vi.mock('@memberjunction/actions', () => ({
  ActionEngineServer: { Instance: { Config: vi.fn(), Actions: [{ ID: 'assign-action' }], RunAction: runAction } },
}));

import { handleAssignmentSave } from '../TaskNotificationHandler.js';

// GuidLiteral refuses non-UUID ids before they reach SQL filter text, so the
// fixture ids must be real UUID shapes.
const TASK_ID = '11111111-1111-1111-1111-111111111111';
const TYPE_ID = '22222222-2222-2222-2222-222222222222';
const PERSON_ID = '33333333-3333-3333-3333-333333333333';

const task = {
  Get: (field: string) => ({ ID: TASK_ID, Name: 'Approve discount', Status: 'Open', TypeID: TYPE_ID } as Record<string, string>)[field],
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
  const fields: Record<string, string | null> = { AssigneeRecordID: PERSON_ID, TaskID: TASK_ID, RoleID: null };
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
      TaskID: TASK_ID,
      TaskName: 'Approve discount',
      TaskTypeID: TYPE_ID,
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
