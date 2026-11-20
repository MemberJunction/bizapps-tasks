import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';

// vi.hoisted so the hoisted mock factories can reference these spies.
const { runViewMock, getEntityObjectMock, sendNotificationMock } = vi.hoisted(() => ({
  runViewMock: vi.fn(),
  getEntityObjectMock: vi.fn(),
  sendNotificationMock: vi.fn(),
}));

vi.mock('@memberjunction/global', () => ({
  RegisterClass: () => () => {},
  IsValidUUID: (v: string | null | undefined) =>
    !!v && /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.test(v.trim()),
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

// The resolver answers from the mocked People rows' LinkedUserID here; its own rules (the user's
// People link first) are covered by @mj-biz-apps/common-entities' own tests.
vi.mock('@mj-biz-apps/common-entities', () => {
  const linkedUsers = async (personIDs: string[]): Promise<Map<string, string>> => {
    const found = new Map<string, string>();
    for (const personID of personIDs) {
      const res = await runViewMock({ EntityName: 'MJ_BizApps_Common: People', ExtraFilter: `ID='${personID}'`, Fields: ['ID', 'LinkedUserID'] });
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
vi.mock('@memberjunction/core-entities', () => ({ MJScheduledJobEntity: class {} }));

// BaseScheduledJob provides log/logError; the subclass calls them.
vi.mock('@memberjunction/scheduling-engine', () => ({
  BaseScheduledJob: class {
    log(..._a: any[]) {}
    logError(..._a: any[]) {}
  },
}));

vi.mock('@memberjunction/scheduling-base-types', () => ({}));

const { resolveRoleUsers } = vi.hoisted(() => ({ resolveRoleUsers: vi.fn() }));
vi.mock('../../role-assignees.js', () => ({
  IsRoleEntityID: (id: string | null | undefined) => id === 'roles-entity',
  ResolveUserIDsForRoles: resolveRoleUsers,
}));
vi.mock('@memberjunction/notifications', () => ({
  NotificationEngine: { Instance: { Config: vi.fn(), SendNotification: sendNotificationMock } },
}));

import { OverdueTaskNotificationJob } from '../OverdueTaskNotificationJob.js';

const NOW = new Date('2026-06-09T12:00:00Z');

// GuidLiteral and AssigneeRecordID validation require UUID shapes for IDs reaching SQL text.
const TASK_ID = '11111111-1111-1111-1111-111111111111';
const TASK_ID_2 = '44444444-4444-4444-4444-444444444444';
const TASK_ID_ROLE = '55555555-5555-5555-5555-555555555555';
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
  resolveRoleUsers.mockResolvedValue([]);
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

  it('filters out non-UUID assignee record IDs so they never reach a SQL filter', async () => {
    wireRunView({
      configs: [globalConfig()],
      tasks: [{ ...baseTask, CreatedByPersonID: null }],
      assignments: [{ AssigneeRecordID: `x' OR 1=1 --` }],
      people: [{ ID: PERSON_ID, LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);
    const peopleCalls = runViewMock.mock.calls.filter(
      (c: unknown[]) => (c[0] as { EntityName?: string })?.EntityName === 'MJ_BizApps_Common: People',
    );
    expect(peopleCalls).toHaveLength(0);
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
    const content = job.FormatNotification(makeContext(), { Success: true, Details: { tasksNotified: 3 } } as never);
    expect(content.Subject).toContain('3');
    expect(content.Priority).toBe('Normal');
  });

  it('produces a Low-priority message when nothing was notified', () => {
    const job = new OverdueTaskNotificationJob();
    const content = job.FormatNotification(makeContext(), { Success: true, Details: { tasksNotified: 0 } } as never);
    expect(content.Priority).toBe('Low');
  });
});

describe('OverdueTaskNotificationJob.Execute — role assignees (bc-aidp-next-golive#442)', () => {
  const task = {
    ID: TASK_ID_ROLE, Name: 'Order Review', TypeID: TYPE_ID, Status: 'Open', Priority: 'High',
    DueAt: '2026-06-08T12:00:00Z', OverdueNotifiedAt: null, CreatedByPersonID: null,
  };

  it('notifies the active holders of an assigned MJ role', async () => {
    resolveRoleUsers.mockResolvedValue(['user-a', 'user-b']);
    wireRunView({
      configs: [globalConfig()],
      tasks: [task],
      assignments: [{ AssigneeEntityID: 'roles-entity', AssigneeRecordID: 'role-finance' }],
    });
    const result = await new OverdueTaskNotificationJob().Execute(makeContext());
    expect(resolveRoleUsers).toHaveBeenCalledWith(['role-finance'], {});
    expect(result.Details?.tasksNotified).toBe(1);
    expect(runViewMock.mock.calls.some(([p]) => p.EntityName === 'MJ_BizApps_Common: People' && p.ExtraFilter.includes('role-finance'))).toBe(false);
  });

  it('keeps going when the role lookup fails', async () => {
    resolveRoleUsers.mockRejectedValue(new Error('database down'));
    wireRunView({
      configs: [globalConfig()],
      tasks: [task],
      assignments: [
        { AssigneeEntityID: 'roles-entity', AssigneeRecordID: 'role-finance' },
        { AssigneeEntityID: 'people-entity', AssigneeRecordID: PERSON_ID },
      ],
      people: [{ ID: PERSON_ID, LinkedUserID: 'user-1' }],
    });
    const result = await new OverdueTaskNotificationJob().Execute(makeContext());
    expect(result.Success).toBe(true);
    expect(result.Details?.tasksNotified).toBe(1);
  });
});

describe('OverdueTaskNotificationJob — Task Overdue notification', () => {
  const overdueTask = {
    ID: TASK_ID, Name: 'File quarterly report', TypeID: TYPE_ID,
    Status: 'In Progress', Priority: 'High',
    DueAt: '2026-06-08T12:00:00Z',
    OverdueNotifiedAt: null as string | null,
    CreatedByPersonID: null,
  };

  function wireOverdue(task: typeof overdueTask, repeatHours: number | null = null) {
    wireRunView({
      configs: [globalConfig({ OverdueRepeatIntervalHours: repeatHours })],
      tasks: [task],
      assignments: [{ AssigneeRecordID: PERSON_ID }],
      people: [{ ID: PERSON_ID, LinkedUserID: 'user-1' }],
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
