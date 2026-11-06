import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';

// vi.hoisted so the hoisted mock factories can reference these spies.
const { runViewMock, getEntityObjectMock, sendNotificationMock } = vi.hoisted(() => ({
  runViewMock: vi.fn(),
  getEntityObjectMock: vi.fn(),
  sendNotificationMock: vi.fn(),
}));

vi.mock('@memberjunction/global', () => ({
  RegisterClass: () => () => {},
}));

vi.mock('@memberjunction/core', () => {
  class FakeValidationResult { Success = true; Errors: any[] = []; }
  return {
    ValidationResult: FakeValidationResult,
    LogError: vi.fn(),
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

vi.mock('@memberjunction/notifications', () => ({
  NotificationEngine: { Instance: { Config: vi.fn(), SendNotification: sendNotificationMock } },
}));

import { OverdueTaskNotificationJob } from '../OverdueTaskNotificationJob.js';

const NOW = new Date('2026-06-09T12:00:00Z');

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
  sendNotificationMock.mockResolvedValue({ success: true });
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
    ID: 'task-1', Name: 'Overdue Task', TypeID: 'type-1',
    Status: 'Open', Priority: 'High',
    DueAt: '2026-06-08T12:00:00Z',   // 24h before NOW
    OverdueNotifiedAt: null,
    CreatedByPersonID: 'person-1',
  };

  it('notifies a task past its grace period with a resolvable recipient', async () => {
    wireRunView({
      configs: [globalConfig({ OverdueGracePeriodHours: 0 })],
      tasks: [baseTask],
      assignments: [{ AssigneeRecordID: 'person-1' }],
      people: [{ ID: 'person-1', LinkedUserID: 'user-1' }],
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
      assignments: [{ AssigneeRecordID: 'person-1' }],
      people: [{ ID: 'person-1', LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);
  });

  it('does NOT re-notify an already-notified task when repeat interval is null (notify-once)', async () => {
    wireRunView({
      configs: [globalConfig({ OverdueRepeatIntervalHours: null })],
      tasks: [{ ...baseTask, OverdueNotifiedAt: '2026-06-08T13:00:00Z' }],
      assignments: [{ AssigneeRecordID: 'person-1' }],
      people: [{ ID: 'person-1', LinkedUserID: 'user-1' }],
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
      assignments: [{ AssigneeRecordID: 'person-1' }],
      people: [{ ID: 'person-1', LinkedUserID: 'user-1' }],
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
      assignments: [{ AssigneeRecordID: 'person-1' }],
      people: [{ ID: 'person-1', LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);
  });

  it('skips a task whose resolved config has notifications disabled', async () => {
    wireRunView({
      configs: [globalConfig({ OverdueNotificationsEnabled: false })],
      tasks: [baseTask],
      assignments: [{ AssigneeRecordID: 'person-1' }],
      people: [{ ID: 'person-1', LinkedUserID: 'user-1' }],
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
        globalConfig({ ID: 'cfg-type', TaskTypeID: 'type-1', OverdueNotificationsEnabled: false }),
      ],
      tasks: [{
        ID: 't1', Name: 'T', TypeID: 'type-1', Status: 'Open', Priority: 'Low',
        DueAt: '2026-06-08T12:00:00Z', OverdueNotifiedAt: null, CreatedByPersonID: 'person-1',
      }],
      assignments: [{ AssigneeRecordID: 'person-1' }],
      people: [{ ID: 'person-1', LinkedUserID: 'user-1' }],
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

describe('OverdueTaskNotificationJob — Task Overdue notification', () => {
  const overdueTask = {
    ID: 'task-1', Name: 'File quarterly report', TypeID: 'type-1',
    Status: 'In Progress', Priority: 'High',
    DueAt: '2026-06-08T12:00:00Z',
    OverdueNotifiedAt: null as string | null,
    CreatedByPersonID: null,
  };

  function wireOverdue(task: typeof overdueTask, repeatHours: number | null = null) {
    wireRunView({
      configs: [globalConfig({ OverdueRepeatIntervalHours: repeatHours })],
      tasks: [task],
      assignments: [{ AssigneeRecordID: 'person-1' }],
      people: [{ ID: 'person-1', LinkedUserID: 'user-1' }],
    });
  }

  it('sends the Task Overdue type through the engine with the existing title and message', async () => {
    wireOverdue(overdueTask);
    const job = new OverdueTaskNotificationJob();
    await job.Execute(makeContext());

    expect(sendNotificationMock).toHaveBeenCalledOnce();
    const [params] = sendNotificationMock.mock.calls[0];
    expect(params).toMatchObject({
      userId: 'user-1',
      typeNameOrId: 'Task Overdue',
      title: 'Task Overdue: File quarterly report',
      message: '"File quarterly report" was due Jun 8, 2026 and is still In Progress. Priority: High.',
      templateData: {
        taskName: 'File quarterly report',
        dueDate: 'Jun 8, 2026',
        status: 'In Progress',
        priority: 'High',
        isReminder: false,
      },
    });
  });

  it('titles a repeat notification as a reminder', async () => {
    wireOverdue({ ...overdueTask, OverdueNotifiedAt: '2026-06-08T11:00:00Z' }, 12);
    const job = new OverdueTaskNotificationJob();
    await job.Execute(makeContext());

    const [params] = sendNotificationMock.mock.calls[0];
    expect(params.title).toBe('Overdue Reminder: File quarterly report');
    expect(params.templateData.isReminder).toBe(true);
  });

  it('keeps going and stamps the task when the send fails', async () => {
    wireOverdue(overdueTask);
    sendNotificationMock.mockResolvedValue({ success: false, errors: ['Notification type not found: Task Overdue'] });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());

    expect(result.Success).toBe(true);
    expect(result.Details?.tasksNotified).toBe(1);
    const stampedTask = (await getEntityObjectMock.mock.results.at(-1)?.value) as { Set: ReturnType<typeof vi.fn> };
    expect(stampedTask.Set).toHaveBeenCalledWith('OverdueNotifiedAt', expect.any(Date));
  });
});
