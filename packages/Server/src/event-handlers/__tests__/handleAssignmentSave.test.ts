import { describe, it, expect, beforeEach, vi } from 'vitest';

type ViewParams = { EntityName: string; ExtraFilter?: string; Fields?: string[] };

const { runView, runAction, saveNotification, resolveRoleUsers, notifiedUsers } = vi.hoisted(() => ({
  runView: vi.fn(),
  runAction: vi.fn(),
  saveNotification: vi.fn(),
  resolveRoleUsers: vi.fn(),
  notifiedUsers: [] as string[],
}));

const ROLES_ENTITY = 'roles-entity';

vi.mock('@memberjunction/core', () => ({
  BaseEntity: class { static BaseEventCode = 'BaseEntity'; },
  LogError: vi.fn(),
  LogStatus: vi.fn(),
  Metadata: class {
    GetEntityObject() {
      return Promise.resolve({
        NewRecord() {},
        Set(field: string, value: string) { if (field === 'UserID') notifiedUsers.push(value); },
        Save: saveNotification,
      });
    }
  },
  RunView: class { RunView = runView; },
  UserInfo: class {},
}));
vi.mock('@memberjunction/global', () => ({
  MJEventType: { ComponentEvent: 'ComponentEvent' },
  MJGlobal: { Instance: { GetGlobalObjectStore: () => ({}), GetEventListener: () => ({ subscribe: () => ({ unsubscribe() {} }) }) } },
}));
vi.mock('../../role-assignees.js', () => ({
  IsRoleEntityID: (id: string | null | undefined) => id === ROLES_ENTITY,
  ResolveUserIDsForRoles: resolveRoleUsers,
  RoleName: (id: string) => (id === 'role-finance' ? 'Finance' : null),
}));
vi.mock('@memberjunction/actions', () => ({
  ActionEngineServer: { Instance: { Config: vi.fn(), Actions: [{ ID: 'assign-action' }], RunAction: runAction } },
}));

import { handleAssignmentSave } from '../TaskNotificationHandler.js';

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
            ? [{ ID: 'person-1', LinkedUserID: linkedUserID }]
            : [{ ID: 'person-1', FirstName: 'Pat', LastName: 'Doe' }],
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
  const fields: Record<string, string | null> = { AssigneeRecordID: 'person-1', TaskID: 'task-1', RoleID: null };
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
  notifiedUsers.length = 0;
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
      AssigneePersonID: 'person-1',
      AssigneeName: 'Pat Doe',
    });
    expect(saveNotification).toHaveBeenCalledOnce();
  });

  it('still invokes the OnAssign action when the assignee has no linked user', async () => {
    mockViews(null);

    await handleAssignmentSave(assignmentCreated());

    expect(saveNotification).not.toHaveBeenCalled();
    expect(runAction).toHaveBeenCalledOnce();
    expect(paramsPassed().AssigneePersonID).toBe('person-1');
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

describe('handleAssignmentSave for a role assignee (bc-aidp-next-golive#442)', () => {
  function roleAssignmentCreated() {
    const fields: Record<string, string | null> = { AssigneeEntityID: ROLES_ENTITY, AssigneeRecordID: 'role-finance', TaskID: 'task-1', RoleID: null };
    return {
      type: 'save',
      saveSubType: 'create',
      baseEntity: { ContextCurrentUser: { ID: 'user-ctx' }, Get: (f: string) => fields[f] },
    } as unknown as Parameters<typeof handleAssignmentSave>[0];
  }

  it('notifies every active holder of the role', async () => {
    mockViews(null);
    resolveRoleUsers.mockResolvedValue(['user-a', 'user-b']);

    await handleAssignmentSave(roleAssignmentCreated());

    expect(resolveRoleUsers).toHaveBeenCalledWith(['role-finance'], { ID: 'user-ctx' });
    expect(notifiedUsers).toEqual(['user-a', 'user-b']);
    expect(runView.mock.calls.some(([p]) => (p as ViewParams).EntityName === 'MJ_BizApps_Common: People')).toBe(false);
  });

  it('names the role, not a person, to the OnAssign action', async () => {
    mockViews(null);
    resolveRoleUsers.mockResolvedValue([]);

    await handleAssignmentSave(roleAssignmentCreated());

    expect(saveNotification).not.toHaveBeenCalled();
    expect(paramsPassed()).toMatchObject({ AssigneePersonID: null, AssigneeName: 'Finance' });
  });

  it('still invokes the OnAssign action when the member lookup fails', async () => {
    mockViews(null);
    resolveRoleUsers.mockRejectedValue(new Error('database down'));

    await handleAssignmentSave(roleAssignmentCreated());

    expect(runAction).toHaveBeenCalledOnce();
  });
});
