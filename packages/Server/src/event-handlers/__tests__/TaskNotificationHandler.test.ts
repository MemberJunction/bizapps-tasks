import { describe, it, expect, beforeEach, vi } from 'vitest';

// vi.hoisted so the hoisted mock factory can reference the shared store/spies.
const { store, subscribeMock, getEventListenerMock, runViewCalls } = vi.hoisted(() => {
  const store: Record<string, any> = {};
  const subscribeMock = vi.fn(() => ({ unsubscribe: vi.fn() }));
  const getEventListenerMock = vi.fn(() => ({ subscribe: subscribeMock }));
  const runViewCalls: Array<{ EntityName?: string; ExtraFilter?: string; ResultType?: string }> = [];
  return { store, subscribeMock, getEventListenerMock, runViewCalls };
});

vi.mock('@memberjunction/core', () => ({
  BaseEntity: class { static BaseEventCode = 'BaseEntity'; },
  LogError: vi.fn(),
  LogStatus: vi.fn(),
  Metadata: class {},
  RunView: class {
    RunView(params: { EntityName?: string; ExtraFilter?: string; ResultType?: string }) {
      runViewCalls.push(params);
      return Promise.resolve({ Success: true, Results: [] });
    }
  },
  UserInfo: class {},
}));

vi.mock('@memberjunction/global', () => ({
  MJEventType: { ComponentEvent: 'ComponentEvent' },
  IsValidUUID: (v: string | null | undefined) => !!v && /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.test(v.trim()),
  MJGlobal: {
    Instance: {
      GetGlobalObjectStore: () => store,
      GetEventListener: (...args: any[]) => getEventListenerMock(...args),
    },
  },
}));

import { InitTaskNotificationHandler } from '../TaskNotificationHandler.js';

beforeEach(() => {
  vi.clearAllMocks();
  runViewCalls.length = 0;
  for (const k of Object.keys(store)) delete store[k];
});

/** Dispatches a fake BaseEntity save event through the subscriber captured from MJGlobal. */
async function dispatchSave(entityName: string, fields: Record<string, unknown>, saveSubType = 'create'): Promise<void> {
  InitTaskNotificationHandler();
  const subscriber = (subscribeMock.mock.calls[0] as unknown[])[0] as (e: unknown) => void;
  subscriber({
    event: 'ComponentEvent',
    eventCode: 'BaseEntity',
    args: {
      type: 'save',
      saveSubType,
      baseEntity: {
        EntityInfo: { Name: entityName },
        ContextCurrentUser: { ID: 'user-1', Email: 'u@example.test' },
        Get: (f: string) => fields[f],
      },
    },
  });
  // handleEntityEvent is fire-and-forget — let the async handler chain settle.
  await new Promise(resolve => setTimeout(resolve, 0));
  await new Promise(resolve => setTimeout(resolve, 0));
}

describe('InitTaskNotificationHandler', () => {
  it('subscribes to the MJGlobal event listener on first init', () => {
    InitTaskNotificationHandler();
    expect(getEventListenerMock).toHaveBeenCalledOnce();
    expect(subscribeMock).toHaveBeenCalledOnce();
  });

  it('stores the subscription in the global object store', () => {
    InitTaskNotificationHandler();
    const keys = Object.keys(store);
    expect(keys.length).toBe(1);
    expect(store[keys[0]]).toBeTruthy();
  });

  it('guards against double-subscription on repeated init', () => {
    InitTaskNotificationHandler();
    InitTaskNotificationHandler();
    InitTaskNotificationHandler();
    // Only the first call should have subscribed.
    expect(subscribeMock).toHaveBeenCalledOnce();
  });
});

describe('handleAssignmentSave', () => {
  it('still invokes the OnAssign hook when the assignee has no linked MJ user', async () => {
    // Person lookup returns no rows (mock RunView always returns []), so no notification recipient.
    await dispatchSave('MJ_BizApps_Tasks: Task Assignments', {
      AssigneeRecordID: '08E2768C-4261-4B35-8C7E-60AC82B7004F',
      TaskID: 'A1B2C3D4-E5F6-7890-ABCD-EF1234567890',
      RoleID: null,
    });

    // The hook path loads the task as an entity object to read its TaskType — that must happen
    // even though the notification path bailed out on a null linked user.
    const hookTaskLoad = runViewCalls.find(c => c.EntityName === 'MJ_BizApps_Tasks: Tasks' && c.ResultType === 'entity_object');
    expect(hookTaskLoad).toBeTruthy();
    // And the notification's own task load (simple) never ran, since there was no recipient.
    const notifyTaskLoad = runViewCalls.find(c => c.EntityName === 'MJ_BizApps_Tasks: Tasks' && c.ResultType === 'simple');
    expect(notifyTaskLoad).toBeUndefined();
  });

  it('skips a non-UUID assignee for the People lookup but still reaches the OnAssign hook', async () => {
    await dispatchSave('MJ_BizApps_Tasks: Task Assignments', {
      AssigneeRecordID: "x' OR 1=1 --",
      TaskID: 'A1B2C3D4-E5F6-7890-ABCD-EF1234567890',
      RoleID: null,
    });
    expect(runViewCalls.some(c => c.EntityName === 'MJ_BizApps_Common: People')).toBe(false);
    expect(runViewCalls.some(c => c.EntityName === 'MJ_BizApps_Tasks: Tasks' && c.ResultType === 'entity_object')).toBe(true);
  });
});
