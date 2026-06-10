import { describe, it, expect, beforeEach, vi } from 'vitest';

// vi.hoisted so the hoisted mock factory can reference the shared store/spies.
const { store, subscribeMock, getEventListenerMock } = vi.hoisted(() => {
  const store: Record<string, any> = {};
  const subscribeMock = vi.fn(() => ({ unsubscribe: vi.fn() }));
  const getEventListenerMock = vi.fn(() => ({ subscribe: subscribeMock }));
  return { store, subscribeMock, getEventListenerMock };
});

vi.mock('@memberjunction/core', () => ({
  BaseEntity: class { static BaseEventCode = 'BaseEntity'; },
  LogError: vi.fn(),
  LogStatus: vi.fn(),
  Metadata: class {},
  RunView: class { RunView() { return Promise.resolve({ Results: [] }); } },
  UserInfo: class {},
}));

vi.mock('@memberjunction/global', () => ({
  MJEventType: { ComponentEvent: 'ComponentEvent' },
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
  for (const k of Object.keys(store)) delete store[k];
});

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
