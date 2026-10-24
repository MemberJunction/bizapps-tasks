import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';

// vi.hoisted so the hoisted mock factories can reference these spies.
const { runViewMock, getEntityObjectMock } = vi.hoisted(() => ({
  runViewMock: vi.fn(),
  getEntityObjectMock: vi.fn(),
}));

vi.mock('@memberjunction/global', () => ({
  RegisterClass: () => () => {},
  // Real-shaped stand-in: sql-guards' GuidLiteral validates every id reaching SQL text.
  IsValidUUID: (id: unknown): boolean =>
    typeof id === 'string' && /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.test(id),
}));

vi.mock('@memberjunction/core', () => {
  class FakeValidationResult { Success = true; Errors: any[] = []; }
  return {
    ValidationResult: FakeValidationResult,
    Metadata: class {
      GetEntityObject(...args: any[]) { return getEntityObjectMock(...args); }
    },
    RunView: class {
      RunView(...args: any[]) { return runViewMock(...args); }
    },
    UserInfo: class {},
    CompositeKey: class { constructor(public KeyValuePairs: any[]) {} },
  };
});

vi.mock('@memberjunction/core-entities', () => ({ MJScheduledJobEntity: class {} }));

// BaseScheduledJob provides log/logError; the subclass calls them.
vi.mock('@memberjunction/scheduling-engine', () => ({
  BaseScheduledJob: class {
    log(..._a: any[]) {}
    logError(..._a: any[]) {}
  },
}));

vi.mock('@memberjunction/scheduling-base-types', () => ({}));

import { OverdueTaskNotificationJob } from '../OverdueTaskNotificationJob.js';

const NOW = new Date('2026-06-09T12:00:00Z');

// GuidLiteral refuses non-UUID ids before they reach SQL filter text, so the
// fixture ids must be real UUID shapes.
const TASK_ID = '11111111-1111-1111-1111-111111111111';
const TASK_ID_2 = '44444444-4444-4444-4444-444444444444';
const TYPE_ID = '22222222-2222-2222-2222-222222222222';
const PERSON_ID = '33333333-3333-3333-3333-333333333333';

/** Global config row with overrideable fields. */
function globalConfig(overrides: Record<string, any> = {}) {
  return {
    ID: 'cfg-global',
    TaskTypeID: null,
    OverdueNotificationsEnabled: true,
    OverdueGracePeriodHours: 0,
    OverdueRepeatIntervalHours: null,
    NotifyAssignees: true,
    NotifyCreator: true,
    OverdueActionID: null,
    ...overrides,
  };
}

function makeContext() {
  return { ContextUser: {} as any } as any;
}

/** Configure RunView to answer per-entity queries the job makes. */
function wireRunView(opts: {
  configs?: any[];
  tasks?: any[];
  assignments?: any[];
  people?: any[];
}) {
  runViewMock.mockImplementation((params: any) => {
    switch (params.EntityName) {
      case 'MJ_BizApps_Tasks: Task Notification Configs':
        return Promise.resolve({ Results: opts.configs ?? [] });
      case 'MJ_BizApps_Tasks: Tasks':
        return Promise.resolve({ Results: opts.tasks ?? [] });
      case 'MJ_BizApps_Tasks: Task Assignments':
        return Promise.resolve({ Results: opts.assignments ?? [] });
      case 'MJ_BizApps_Common: People':
        return Promise.resolve({ Results: opts.people ?? [] });
      case 'MJ_BizApps_Tasks: Task Types':
        return Promise.resolve({ Results: [] });
      default:
        return Promise.resolve({ Results: [] });
    }
  });
}

beforeEach(() => {
  vi.clearAllMocks();
  vi.useFakeTimers();
  vi.setSystemTime(NOW);
  // Default: GetEntityObject returns a no-op savable entity (notifications, logs, stamps)
  getEntityObjectMock.mockResolvedValue({
    NewRecord: vi.fn(), Set: vi.fn(), Save: vi.fn(async () => true),
    Get: vi.fn(), InnerLoad: vi.fn(async () => true),
  });
});

afterEach(() => {
  vi.useRealTimers();
});

describe('OverdueTaskNotificationJob.Execute — config gating', () => {
  it('skips when there is no global config', async () => {
    wireRunView({ configs: [] });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Success).toBe(true);
    expect(result.Details?.tasksNotified).toBe(0);
  });

  it('reports zero when there are no overdue tasks', async () => {
    wireRunView({ configs: [globalConfig()], tasks: [] });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);
  });
});

describe('OverdueTaskNotificationJob.Execute — grace period & repeat filtering', () => {
  const baseTask = {
    ID: TASK_ID, Name: 'Overdue Task', TypeID: TYPE_ID,
    Status: 'Open', Priority: 'High',
    DueAt: '2026-06-08T12:00:00Z',   // 24h before NOW
    OverdueNotifiedAt: null,
    CreatedByPersonID: PERSON_ID,
  };

  it('notifies a task past its grace period with a resolvable recipient', async () => {
    wireRunView({
      configs: [globalConfig({ OverdueGracePeriodHours: 0 })],
      tasks: [baseTask],
      assignments: [{ AssigneeRecordID: PERSON_ID }],
      people: [{ ID: PERSON_ID, LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(1);
  });

  it('does NOT notify when still within the grace period', async () => {
    // grace 48h; task is only 24h overdue → cutoff is in the future
    wireRunView({
      configs: [globalConfig({ OverdueGracePeriodHours: 48 })],
      tasks: [baseTask],
      assignments: [{ AssigneeRecordID: PERSON_ID }],
      people: [{ ID: PERSON_ID, LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);
  });

  it('does NOT re-notify an already-notified task when repeat interval is null (notify-once)', async () => {
    wireRunView({
      configs: [globalConfig({ OverdueRepeatIntervalHours: null })],
      tasks: [{ ...baseTask, OverdueNotifiedAt: '2026-06-08T13:00:00Z' }],
      assignments: [{ AssigneeRecordID: PERSON_ID }],
      people: [{ ID: PERSON_ID, LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);
  });

  it('re-notifies when the repeat interval has elapsed since last notification', async () => {
    // last notified 25h ago, repeat every 12h → due for re-notification
    wireRunView({
      configs: [globalConfig({ OverdueRepeatIntervalHours: 12 })],
      tasks: [{ ...baseTask, OverdueNotifiedAt: '2026-06-08T11:00:00Z' }],
      assignments: [{ AssigneeRecordID: PERSON_ID }],
      people: [{ ID: PERSON_ID, LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(1);
  });

  it('does NOT re-notify when within the repeat interval window', async () => {
    // last notified 1h ago, repeat every 12h → too soon
    wireRunView({
      configs: [globalConfig({ OverdueRepeatIntervalHours: 12 })],
      tasks: [{ ...baseTask, OverdueNotifiedAt: '2026-06-09T11:00:00Z' }],
      assignments: [{ AssigneeRecordID: PERSON_ID }],
      people: [{ ID: PERSON_ID, LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);
  });

  it('skips a task whose resolved config has notifications disabled', async () => {
    wireRunView({
      configs: [globalConfig({ OverdueNotificationsEnabled: false })],
      tasks: [baseTask],
      assignments: [{ AssigneeRecordID: PERSON_ID }],
      people: [{ ID: PERSON_ID, LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);
  });

  it('skips a task with no resolvable recipients', async () => {
    wireRunView({
      configs: [globalConfig()],
      tasks: [{ ...baseTask, CreatedByPersonID: null }],
      assignments: [],   // no assignees
      people: [],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);
  });
});

describe('OverdueTaskNotificationJob — per-TaskType config override', () => {
  it('uses a per-type config (disabled) over the enabled global default', async () => {
    wireRunView({
      configs: [
        globalConfig({ OverdueNotificationsEnabled: true }),
        globalConfig({ ID: 'cfg-type', TaskTypeID: TYPE_ID, OverdueNotificationsEnabled: false }),
      ],
      tasks: [{
        ID: TASK_ID_2, Name: 'T', TypeID: TYPE_ID, Status: 'Open', Priority: 'Low',
        DueAt: '2026-06-08T12:00:00Z', OverdueNotifiedAt: null, CreatedByPersonID: PERSON_ID,
      }],
      assignments: [{ AssigneeRecordID: PERSON_ID }],
      people: [{ ID: PERSON_ID, LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);
  });
});

describe('OverdueTaskNotificationJob.FormatNotification', () => {
  it('produces a Normal-priority summary when tasks were notified', () => {
    const job = new OverdueTaskNotificationJob();
    const content = job.FormatNotification(makeContext(), { Success: true, Details: { tasksNotified: 3 } } as any);
    expect(content.Subject).toContain('3');
    expect(content.Priority).toBe('Normal');
  });

  it('produces a Low-priority message when nothing was notified', () => {
    const job = new OverdueTaskNotificationJob();
    const content = job.FormatNotification(makeContext(), { Success: true, Details: { tasksNotified: 0 } } as any);
    expect(content.Priority).toBe('Low');
  });
});
