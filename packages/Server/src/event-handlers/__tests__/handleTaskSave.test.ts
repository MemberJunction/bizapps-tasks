import { describe, it, expect, beforeEach, vi } from 'vitest';

type ViewParams = { EntityName: string; ExtraFilter?: string; Fields?: string[] };
type EntityEventListener = (event: { event: string; eventCode: string; args: unknown }) => void;

const { runView, runAction, sendNotification, listeners } = vi.hoisted(() => ({
  runView: vi.fn(),
  runAction: vi.fn(),
  sendNotification: vi.fn(),
  listeners: [] as EntityEventListener[],
}));

vi.mock('@memberjunction/core', () => ({
  BaseEntity: class { static BaseEventCode = 'BaseEntity'; },
  LogError: vi.fn(),
  LogStatus: vi.fn(),
  Metadata: class {},
  RunView: class { RunView = runView; },
  UserInfo: class {},
}));
vi.mock('@memberjunction/global', () => ({
  MJEventType: { ComponentEvent: 'ComponentEvent' },
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
vi.mock('@memberjunction/notifications', () => ({
  NotificationEngine: { Instance: { Config: vi.fn(), SendNotification: sendNotification } },
}));
vi.mock('@memberjunction/actions', () => ({
  ActionEngineServer: { Instance: { Config: vi.fn(), Actions: [{ ID: 'complete-action' }], RunAction: runAction } },
}));

import { InitTaskNotificationHandler } from '../TaskNotificationHandler.js';

const taskFields: Record<string, string | null> = {
  ID: 'task-1',
  Name: 'Approve journal batch',
  Status: 'Completed',
  TypeID: 'type-1',
};

function mockViews(): void {
  runView.mockImplementation((params: ViewParams) => {
    switch (params.EntityName) {
      case 'MJ_BizApps_Tasks: Task Assignments':
        return Promise.resolve({ Success: true, Results: [{ AssigneeRecordID: 'person-1' }, { AssigneeRecordID: 'person-2' }] });
      case 'MJ_BizApps_Common: People':
        return Promise.resolve({
          Success: true,
          Results: [{ ID: 'person-1', LinkedUserID: 'user-1' }, { ID: 'person-2', LinkedUserID: 'user-2' }],
        });
      case 'MJ_BizApps_Tasks: Task Types':
        return Promise.resolve({ Success: true, Results: [{ OnCompleteActionID: 'complete-action' }] });
      default:
        return Promise.resolve({ Success: true, Results: [] });
    }
  });
}

/** Publishes a task update through the handler's MJGlobal subscription. */
function publishTaskUpdate(): void {
  const baseEntity = {
    ContextCurrentUser: { ID: 'user-ctx' },
    EntityInfo: { Name: 'MJ_BizApps_Tasks: Tasks' },
    Get: (field: string) => taskFields[field],
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

describe('task completed notification', () => {
  it('sends the Task Completed type to every assignee with the existing title and message', async () => {
    publishTaskUpdate();

    await vi.waitFor(() => expect(runAction).toHaveBeenCalledOnce());
    expect(sendNotification).toHaveBeenCalledTimes(2);
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
  });

  it('still invokes the OnComplete action when the notification send fails', async () => {
    sendNotification.mockRejectedValue(new Error('notification store down'));

    publishTaskUpdate();

    await vi.waitFor(() => expect(runAction).toHaveBeenCalledOnce());
  });
});
