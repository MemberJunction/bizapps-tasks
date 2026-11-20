import { describe, it, expect, beforeEach, vi } from 'vitest';

type ViewParams = { EntityName: string; ExtraFilter?: string; Fields?: string[] };
type EntityEventListener = (event: { event: string; eventCode: string; args: unknown }) => void;

const { runView, runAction, sendNotification, getEntityObject, listeners } = vi.hoisted(() => ({
  runView: vi.fn(),
  runAction: vi.fn(),
  sendNotification: vi.fn(),
  getEntityObject: vi.fn(),
  listeners: [] as EntityEventListener[],
}));

const TASK_1 = '11111111-1111-4111-8111-111111111111';
const TYPE_1 = '22222222-2222-4222-8222-222222222222';
const PERSON_1 = '33333333-3333-4333-8333-333333333331';
const PERSON_2 = '33333333-3333-4333-8333-333333333332';

vi.mock('@memberjunction/core', () => ({
  BaseEntity: class { static BaseEventCode = 'BaseEntity'; },
  LogError: vi.fn(),
  LogStatus: vi.fn(),
  Metadata: class {
    GetEntityObject(...args: unknown[]) {
      return getEntityObject(...args);
    }
  },
  RunView: class { RunView = runView; },
  UserInfo: class {},
}));
vi.mock('@memberjunction/global', () => ({
  EscapeSQLString: (v: string) => v.replace(/'/g, "''"),
  UUIDsEqual: (a?: string | null, b?: string | null) => Boolean(a && b && a.toLowerCase() === b.toLowerCase()),
  MJEventType: { ComponentEvent: 'ComponentEvent' },
  IsValidUUID: (v: string | null | undefined) =>
    !!v && /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.test(v.trim()),
  MJGlobal: {
    Instance: {
      GetGlobalObjectStore: () => ({}),
      GetEventListener: () => ({
        subscribe: (listener: EntityEventListener) => {
          listeners.push(listener);
          return { unsubscribe() {} };
        },
      }),
    },
  },
}));
vi.mock('@mj-biz-apps/common-entities', () => ({
  ResolveUserIDsForPeople: async (personIDs: string[]): Promise<Map<string, string>> => {
    const res = await runView({ EntityName: 'MJ_BizApps_Common: People', ExtraFilter: personIDs.join(','), Fields: ['ID', 'LinkedUserID'] });
    const wanted = new Set(personIDs.map(id => id.toLowerCase()));
    const found = new Map<string, string>();
    for (const row of (res?.Results ?? []) as Array<{ ID: string; LinkedUserID: string | null }>) {
      if (row.LinkedUserID && wanted.has(row.ID.toLowerCase())) found.set(row.ID.toLowerCase(), row.LinkedUserID);
    }
    return found;
  },
  ResolveUserIDForPerson: vi.fn(),
}));
vi.mock('../../role-assignees.js', () => ({
  IsRoleEntityID: () => false,
  ResolveUserIDsForRoles: vi.fn(),
  RoleName: () => null,
}));
vi.mock('@memberjunction/notifications', () => ({
  NotificationEngine: { Instance: { Config: vi.fn(), SendNotification: sendNotification } },
}));
vi.mock('@memberjunction/actions', () => ({
  ActionEngineServer: { Instance: { Config: vi.fn(), Actions: [{ ID: 'complete-action' }], RunAction: runAction } },
}));

import { InitTaskNotificationHandler } from '../TaskNotificationHandler.js';

function mockViews(): void {
  runView.mockImplementation((params: ViewParams) => {
    switch (params.EntityName) {
      case 'MJ_BizApps_Tasks: Task Assignments':
        return Promise.resolve({ Success: true, Results: [{ AssigneeRecordID: PERSON_1 }, { AssigneeRecordID: PERSON_2 }] });
      case 'MJ_BizApps_Common: People':
        return Promise.resolve({
          Success: true,
          Results: [{ ID: PERSON_1, LinkedUserID: 'user-1' }, { ID: PERSON_2, LinkedUserID: 'user-2' }],
        });
      case 'MJ_BizApps_Tasks: Task Types':
        return Promise.resolve({ Success: true, Results: [{ OnCompleteActionID: 'complete-action' }] });
      default:
        return Promise.resolve({ Success: true, Results: [] });
    }
  });
}

/** Publishes a task update through the handler's MJGlobal subscription. */
function publishTaskUpdate(status: 'Completed' | 'Blocked' | 'Cancelled' = 'Completed'): void {
  const baseEntity = {
    ContextCurrentUser: { ID: 'user-ctx' },
    EntityInfo: { Name: 'MJ_BizApps_Tasks: Tasks' },
    ID: TASK_1,
    Name: 'Approve journal batch',
    Status: status,
    TypeID: TYPE_1,
  };
  for (const listener of listeners) {
    listener({ event: 'ComponentEvent', eventCode: 'BaseEntity', args: { type: 'save', saveSubType: 'update', baseEntity } });
  }
}

beforeEach(() => {
  vi.clearAllMocks();
  mockViews();
  runAction.mockResolvedValue({ Success: true });
  sendNotification.mockResolvedValue({ success: true });
  if (listeners.length === 0) {
    InitTaskNotificationHandler();
  }
});

describe('task status notifications & single-owner hook dispatch', () => {
  it('sends the Task Completed notification to every assignee and does NOT duplicate TaskEntityServer OnComplete action hooks', async () => {
    publishTaskUpdate('Completed');

    await vi.waitFor(() => expect(sendNotification).toHaveBeenCalledTimes(2));
    for (const userId of ['user-1', 'user-2']) {
      expect(sendNotification).toHaveBeenCalledWith(
        {
          userId,
          typeNameOrId: 'Task Completed',
          title: 'Task Completed: Approve journal batch',
          message: '"Approve journal batch" has been marked as completed.',
          templateData: {
            taskName: 'Approve journal batch',
            message: '"Approve journal batch" has been marked as completed.',
          },
        },
        expect.anything(),
      );
    }
    // Lifecycle action hooks (OnComplete/OnCancel/OnReject) are owned exclusively by TaskEntityServer.
    expect(runAction).not.toHaveBeenCalled();
  });

  it('sends Task Blocked notifications to every assignee and does NOT fire OnReject', async () => {
    const savedNotifications: Array<Record<string, unknown>> = [];
    getEntityObject.mockImplementation(async () => {
      const notif: Record<string, unknown> = {
        NewRecord: vi.fn(),
        Save: vi.fn(async () => true),
      };
      savedNotifications.push(notif);
      return notif;
    });

    publishTaskUpdate('Blocked');

    await vi.waitFor(() => expect(savedNotifications).toHaveLength(2));
    expect(savedNotifications.map((n) => n.UserID)).toEqual(['user-1', 'user-2']);
    expect(savedNotifications[0].Title).toBe('Task Blocked: Approve journal batch');
    expect(runAction).not.toHaveBeenCalled();
  });

  it('does NOT dispatch OnCancel or OnReject on a Cancelled task save', async () => {
    publishTaskUpdate('Cancelled');
    await new Promise(resolve => setTimeout(resolve, 10));

    expect(runAction).not.toHaveBeenCalled();
  });

  it('filters out non-UUID AssigneeRecordID values before calling People lookup', async () => {
    runView.mockImplementation((params: ViewParams) => {
      if (params.EntityName === 'MJ_BizApps_Tasks: Task Assignments') {
        return Promise.resolve({
          Success: true,
          Results: [{ AssigneeRecordID: "x' OR 1=1 --" }, { AssigneeRecordID: PERSON_1 }],
        });
      }
      if (params.EntityName === 'MJ_BizApps_Common: People') {
        return Promise.resolve({
          Success: true,
          Results: [{ ID: PERSON_1, LinkedUserID: 'user-1' }],
        });
      }
      return Promise.resolve({ Success: true, Results: [] });
    });

    publishTaskUpdate('Completed');

    await vi.waitFor(() => expect(sendNotification).toHaveBeenCalledOnce());
    const peopleCalls = runView.mock.calls.filter(([p]) => (p as ViewParams).EntityName === 'MJ_BizApps_Common: People');
    for (const [call] of peopleCalls) {
      expect((call as ViewParams).ExtraFilter).not.toContain('OR 1=1');
    }
  });
});
