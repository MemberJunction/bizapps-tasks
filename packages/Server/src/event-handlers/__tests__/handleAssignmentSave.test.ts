import { describe, it, expect, beforeEach, vi } from 'vitest';

type ViewParams = { EntityName: string; ExtraFilter?: string; Fields?: string[] };

const { runView, runAction, sendNotification, resolveRoleUsers, ROLES_ENTITY, ROLE_FINANCE, ASSIGN_ACTION } = vi.hoisted(() => ({
  runView: vi.fn(),
  runAction: vi.fn(),
  sendNotification: vi.fn(),
  resolveRoleUsers: vi.fn(),
  ROLES_ENTITY: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  ROLE_FINANCE: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  ASSIGN_ACTION: '44444444-4444-4444-8444-444444444444',
}));

const TASK_1 = '11111111-1111-4111-8111-111111111111';
const TYPE_1 = '22222222-2222-4222-8222-222222222222';
const PERSON_1 = '33333333-3333-4333-8333-333333333333';

vi.mock('@memberjunction/core', () => ({
  BaseEntity: class { static BaseEventCode = 'BaseEntity'; },
  LogError: vi.fn(),
  LogStatus: vi.fn(),
  Metadata: class {},
  RunView: class { RunView = runView; },
  UserInfo: class {},
}));
vi.mock('@memberjunction/global', () => ({
  IsValidUUID: (v: string) => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v),
  EscapeSQLString: (v: string) => v.replace(/'/g, "''"),
  UUIDsEqual: (a?: string | null, b?: string | null) => Boolean(a && b && a.toLowerCase() === b.toLowerCase()),
  MJEventType: { ComponentEvent: 'ComponentEvent' },
  MJGlobal: { Instance: { GetGlobalObjectStore: () => ({}), GetEventListener: () => ({ subscribe: () => ({ unsubscribe() {} }) }) } },
}));
vi.mock('@mj-biz-apps/common-entities', () => {
  const linkedUsers = async (personIDs: string[]): Promise<Map<string, string>> => {
    const found = new Map<string, string>();
    for (const personID of personIDs) {
      const res = await runView({ EntityName: 'MJ_BizApps_Common: People', ExtraFilter: `ID='${personID}'`, Fields: ['ID', 'LinkedUserID'] });
      const userID = res?.Results?.[0]?.LinkedUserID;
      if (userID) found.set(personID.toLowerCase(), userID);
    }
    return found;
  };
  return {
    ResolveUserIDsForPeople: linkedUsers,
    ResolveUserIDForPerson: async (personID: string) => (await linkedUsers([personID])).get(personID.toLowerCase()) ?? null,
  };
});
vi.mock('../../role-assignees.js', () => ({
  IsRoleEntityID: (id: string | null | undefined) => id === ROLES_ENTITY,
  ResolveUserIDsForRoles: resolveRoleUsers,
  RoleName: (id: string) => (id === ROLE_FINANCE ? 'Finance' : null),
}));
vi.mock('@memberjunction/notifications', () => ({
  NotificationEngine: { Instance: { Config: vi.fn(), SendNotification: sendNotification } },
}));
vi.mock('@memberjunction/actions', () => ({
  ActionEngineServer: { Instance: { Config: vi.fn(), Actions: [{ ID: ASSIGN_ACTION }], RunAction: runAction } },
}));

import { handleAssignmentSave, handleEntityEvent } from '../TaskNotificationHandler.js';

const task = {
  ID: TASK_1,
  Name: 'Approve discount',
  Status: 'Open',
  TypeID: TYPE_1,
  Priority: 'High',
  DueAt: null,
};

function mockViews(linkedUserID: string | null): void {
  runView.mockImplementation((params: ViewParams) => {
    switch (params.EntityName) {
      case 'MJ_BizApps_Common: People':
        return Promise.resolve({
          Success: true,
          Results: params.Fields?.includes('LinkedUserID')
            ? [{ ID: PERSON_1, LinkedUserID: linkedUserID }]
            : [{ ID: PERSON_1, FirstName: 'Pat', LastName: 'Doe' }],
        });
      case 'MJ_BizApps_Tasks: Tasks':
        return Promise.resolve({ Success: true, Results: params.ExtraFilter ? [task] : [] });
      case 'MJ_BizApps_Tasks: Task Types':
        return Promise.resolve({ Success: true, Results: [{ OnAssignActionID: ASSIGN_ACTION }] });
      default:
        return Promise.resolve({ Success: true, Results: [] });
    }
  });
}

function assignmentCreated() {
  return {
    type: 'save',
    saveSubType: 'create',
    baseEntity: {
      ContextCurrentUser: { ID: 'user-ctx' },
      AssigneeEntityID: null,
      AssigneeRecordID: PERSON_1,
      TaskID: TASK_1,
      RoleID: null,
    },
  } as unknown as Parameters<typeof handleAssignmentSave>[0];
}

const paramsPassed = () =>
  Object.fromEntries((runAction.mock.calls[0][0].Params as Array<{ Name: string; Value: unknown }>).map((p) => [p.Name, p.Value]));

beforeEach(() => {
  vi.clearAllMocks();
  runAction.mockResolvedValue({ Success: true });
  sendNotification.mockResolvedValue({ success: true });
});

describe('handleAssignmentSave', () => {
  it('passes the assignee and task type to the OnAssign action', async () => {
    mockViews('user-1');

    await handleAssignmentSave(assignmentCreated());

    expect(runAction).toHaveBeenCalledOnce();
    expect(paramsPassed()).toMatchObject({
      TaskID: TASK_1,
      TaskName: 'Approve discount',
      TaskTypeID: TYPE_1,
      AssigneePersonID: PERSON_1,
      AssigneeName: 'Pat Doe',
    });
    expect(sendNotification).toHaveBeenCalledOnce();
  });

  it("sends the assignment as MJ's Task Assignment notification type", async () => {
    mockViews('user-1');

    await handleAssignmentSave(assignmentCreated());

    expect(sendNotification).toHaveBeenCalledWith(
      expect.objectContaining({
        userId: 'user-1',
        typeNameOrId: 'Task Assignment',
        title: 'Task Assigned: Approve discount',
      }),
      expect.anything(),
    );
  });

  it('still invokes the OnAssign action when the assignee has no linked user', async () => {
    mockViews(null);

    await handleAssignmentSave(assignmentCreated());

    expect(sendNotification).not.toHaveBeenCalled();
    expect(runAction).toHaveBeenCalledOnce();
    expect(paramsPassed().AssigneePersonID).toBe(PERSON_1);
  });

  it('still invokes the OnAssign action when the notification throws', async () => {
    mockViews('user-1');
    sendNotification.mockRejectedValue(new Error('notification store down'));

    await handleAssignmentSave(assignmentCreated());

    expect(runAction).toHaveBeenCalledOnce();
  });

  it('ignores updates to an existing assignment', async () => {
    mockViews('user-1');
    const event = { ...assignmentCreated(), saveSubType: 'update' } as Parameters<typeof handleAssignmentSave>[0];

    await handleAssignmentSave(event);

    expect(runAction).not.toHaveBeenCalled();
  });

  it('queues assignment notifications and OnAssign hooks via RunAfterCommit when saved inside a transaction', async () => {
    mockViews('user-1');
    const token = { frame: 'tx-1' };
    const runAfterCommit = vi.fn();
    const capturePostCommitToken = vi.fn(() => token);
    const event = {
      type: 'save',
      saveSubType: 'create',
      baseEntity: {
        EntityInfo: { Name: 'MJ_BizApps_Tasks: Task Assignments' },
        ContextCurrentUser: { ID: 'user-ctx' },
        ProviderToUse: {
          CapturePostCommitToken: capturePostCommitToken,
          RunAfterCommit: runAfterCommit,
        },
        AssigneeEntityID: null,
        AssigneeRecordID: PERSON_1,
        TaskID: TASK_1,
        RoleID: null,
      },
    } as unknown as Parameters<typeof handleEntityEvent>[0];

    handleEntityEvent(event);

    expect(capturePostCommitToken).toHaveBeenCalledOnce();
    expect(runAfterCommit).toHaveBeenCalledOnce();
    expect(runAction).not.toHaveBeenCalled();
    expect(sendNotification).not.toHaveBeenCalled();

    const [queuedTask, description, passedToken] = runAfterCommit.mock.calls[0];
    expect(description).toBe('Task assignment notification and OnAssign hook');
    expect(passedToken).toBe(token);

    await (queuedTask as () => Promise<void>)();
    expect(sendNotification).toHaveBeenCalledOnce();
    expect(runAction).toHaveBeenCalledOnce();
  });
});

describe('handleAssignmentSave for a role assignee (bc-aidp-next-golive#442)', () => {
  function roleAssignmentCreated() {
    return {
      type: 'save',
      saveSubType: 'create',
      baseEntity: {
        ContextCurrentUser: { ID: 'user-ctx' },
        AssigneeEntityID: ROLES_ENTITY,
        AssigneeRecordID: ROLE_FINANCE,
        TaskID: TASK_1,
        RoleID: null,
      },
    } as unknown as Parameters<typeof handleAssignmentSave>[0];
  }

  it('notifies every active holder of the role', async () => {
    mockViews(null);
    resolveRoleUsers.mockResolvedValue(['user-a', 'user-b']);

    await handleAssignmentSave(roleAssignmentCreated());

    expect(resolveRoleUsers).toHaveBeenCalledWith([ROLE_FINANCE], { ID: 'user-ctx' });
    expect(sendNotification.mock.calls.map(([p]) => (p as { userId: string }).userId)).toEqual(['user-a', 'user-b']);
    expect(runView.mock.calls.some(([p]) => (p as ViewParams).EntityName === 'MJ_BizApps_Common: People')).toBe(false);
  });

  it('names the role, not a person, to the OnAssign action', async () => {
    mockViews(null);
    resolveRoleUsers.mockResolvedValue([]);

    await handleAssignmentSave(roleAssignmentCreated());

    expect(sendNotification).not.toHaveBeenCalled();
    expect(paramsPassed()).toMatchObject({ AssigneePersonID: null, AssigneeName: 'Finance' });
  });

  it('still invokes the OnAssign action when the member lookup fails', async () => {
    mockViews(null);
    resolveRoleUsers.mockRejectedValue(new Error('database down'));

    await handleAssignmentSave(roleAssignmentCreated());

    expect(runAction).toHaveBeenCalledOnce();
  });
});
