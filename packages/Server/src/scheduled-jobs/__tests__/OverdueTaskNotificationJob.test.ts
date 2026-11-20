import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import type { ScheduledJobExecutionContext, ScheduledJobResult } from '@memberjunction/scheduling-base-types';

const { runViewMock, getEntityObjectMock, sendNotificationMock, resolveRoleUsers, runActionMock } = vi.hoisted(() => ({
  runViewMock: vi.fn(),
  getEntityObjectMock: vi.fn(),
  sendNotificationMock: vi.fn(),
  resolveRoleUsers: vi.fn(),
  runActionMock: vi.fn(),
}));

const ROLES_ENTITY = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const PEOPLE_ENTITY = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
const ROLE_FINANCE = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc';
const TASK_1 = '11111111-1111-4111-8111-111111111111';
const TASK_R = '11111111-1111-4111-8111-111111111112';
const TYPE_1 = '22222222-2222-4222-8222-222222222222';
const PERSON_1 = '33333333-3333-4333-8333-333333333333';

vi.mock('@memberjunction/global', () => ({
  RegisterClass: () => () => {},
  IsValidUUID: (v: string) => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v),
  EscapeSQLString: (v: string) => v.replace(/'/g, "''"),
  UUIDsEqual: (a?: string | null, b?: string | null) => Boolean(a && b && a.toLowerCase() === b.toLowerCase()),
}));

vi.mock('@memberjunction/core', () => {
  class FakeValidationResult { Success = true; Errors: unknown[] = []; }
  return {
    ValidationResult: FakeValidationResult,
    LogError: vi.fn(),
    Metadata: class {
      GetEntityObject(...args: unknown[]) { return getEntityObjectMock(...args); }
    },
    RunView: class {
      RunView(...args: unknown[]) { return runViewMock(...args); }
    },
    UserInfo: class {},
    CompositeKey: class { constructor(public KeyValuePairs: unknown[]) {} },
  };
});

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

vi.mock('@memberjunction/scheduling-engine', () => ({
  BaseScheduledJob: class {
    log(..._a: unknown[]) {}
    logError(..._a: unknown[]) {}
  },
}));

vi.mock('@memberjunction/scheduling-base-types', () => ({}));

vi.mock('../../role-assignees.js', () => ({
  IsRoleEntityID: (id: string | null | undefined) => id === ROLES_ENTITY,
  ResolveUserIDsForRoles: resolveRoleUsers,
}));
vi.mock('@memberjunction/notifications', () => ({
  NotificationEngine: { Instance: { Config: vi.fn(), SendNotification: sendNotificationMock } },
}));
vi.mock('@memberjunction/actions', () => ({
  ActionEngineServer: { Instance: { Config: vi.fn(), Actions: [], RunAction: runActionMock } },
}));

import { OverdueTaskNotificationJob } from '../OverdueTaskNotificationJob.js';

const NOW = new Date('2026-06-09T12:00:00Z');

interface FakeEntityObj {
  NewRecord: ReturnType<typeof vi.fn>;
  Save: ReturnType<typeof vi.fn>;
  InnerLoad: ReturnType<typeof vi.fn>;
  OverdueNotifiedAt?: Date | null;
  LatestResult: { CompleteMessage: string };
}

function makeFakeEntityObj(): FakeEntityObj {
  return {
    NewRecord: vi.fn(),
    Save: vi.fn(async () => true),
    InnerLoad: vi.fn(async () => true),
    OverdueNotifiedAt: null,
    LatestResult: { CompleteMessage: '' },
  };
}

function globalConfig(overrides: Record<string, unknown> = {}) {
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

function makeContext(): ScheduledJobExecutionContext {
  return { ContextUser: {} } as unknown as ScheduledJobExecutionContext;
}

function wireRunView(opts: {
  configs?: Record<string, unknown>[];
  tasks?: Record<string, unknown>[];
  assignments?: Record<string, unknown>[];
  people?: Record<string, unknown>[];
}) {
  runViewMock.mockImplementation((params: { EntityName: string }) => {
    switch (params.EntityName) {
      case 'MJ_BizApps_Tasks: Task Notification Configs':
        return Promise.resolve({ Success: true, Results: opts.configs ?? [] });
      case 'MJ_BizApps_Tasks: Tasks':
        return Promise.resolve({ Success: true, Results: opts.tasks ?? [] });
      case 'MJ_BizApps_Tasks: Task Assignments':
        return Promise.resolve({ Success: true, Results: opts.assignments ?? [] });
      case 'MJ_BizApps_Common: People':
        return Promise.resolve({ Success: true, Results: opts.people ?? [] });
      case 'MJ_BizApps_Tasks: Task Types':
        return Promise.resolve({ Success: true, Results: [] });
      default:
        return Promise.resolve({ Success: true, Results: [] });
    }
  });
}

let createdEntities: FakeEntityObj[] = [];

beforeEach(() => {
  vi.clearAllMocks();
  createdEntities = [];
  resolveRoleUsers.mockResolvedValue([]);
  vi.useFakeTimers();
  vi.setSystemTime(NOW);
  getEntityObjectMock.mockImplementation(async () => {
    const obj = makeFakeEntityObj();
    createdEntities.push(obj);
    return obj;
  });
  sendNotificationMock.mockResolvedValue({ success: true });
});

afterEach(() => {
  vi.useRealTimers();
});

describe('OverdueTaskNotificationJob.Execute — config gating & portable SQL', () => {
  it('skips when there is no global config', async () => {
    wireRunView({ configs: [] });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Success).toBe(true);
    expect(result.Details?.tasksNotified).toBe(0);
  });

  it('uses a portable ISO UTC timestamp filter instead of SQL Server-only GETUTCDATE()', async () => {
    wireRunView({ configs: [globalConfig()], tasks: [] });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);

    const taskQuery = runViewMock.mock.calls.find(
      ([p]) => (p as { EntityName: string }).EntityName === 'MJ_BizApps_Tasks: Tasks',
    );
    expect(taskQuery).toBeDefined();
    const filter = String((taskQuery![0] as { ExtraFilter?: string }).ExtraFilter);
    expect(filter).toContain(`DueAt < '${NOW.toISOString()}'`);
    expect(filter).not.toMatch(/GETUTCDATE/i);
  });
});

describe('OverdueTaskNotificationJob.Execute — grace period & repeat filtering', () => {
  const baseTask = {
    ID: TASK_1, Name: 'Overdue Task', TypeID: TYPE_1,
    Status: 'Open', Priority: 'High',
    DueAt: '2026-06-08T12:00:00Z',
    OverdueNotifiedAt: null,
    CreatedByPersonID: PERSON_1,
  };

  it('notifies a task past its grace period with a resolvable recipient', async () => {
    wireRunView({
      configs: [globalConfig({ OverdueGracePeriodHours: 0 })],
      tasks: [baseTask],
      assignments: [{ AssigneeRecordID: PERSON_1 }],
      people: [{ ID: PERSON_1, LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(1);
  });

  it('does NOT notify when still within the grace period', async () => {
    wireRunView({
      configs: [globalConfig({ OverdueGracePeriodHours: 48 })],
      tasks: [baseTask],
      assignments: [{ AssigneeRecordID: PERSON_1 }],
      people: [{ ID: PERSON_1, LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);
  });

  it('does NOT re-notify an already-notified task when repeat interval is null (notify-once)', async () => {
    wireRunView({
      configs: [globalConfig({ OverdueRepeatIntervalHours: null })],
      tasks: [{ ...baseTask, OverdueNotifiedAt: '2026-06-08T13:00:00Z' }],
      assignments: [{ AssigneeRecordID: PERSON_1 }],
      people: [{ ID: PERSON_1, LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);
  });

  it('re-notifies when the repeat interval has elapsed since last notification', async () => {
    wireRunView({
      configs: [globalConfig({ OverdueRepeatIntervalHours: 12 })],
      tasks: [{ ...baseTask, OverdueNotifiedAt: '2026-06-08T11:00:00Z' }],
      assignments: [{ AssigneeRecordID: PERSON_1 }],
      people: [{ ID: PERSON_1, LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(1);
  });

  it('does NOT re-notify when within the repeat interval window', async () => {
    wireRunView({
      configs: [globalConfig({ OverdueRepeatIntervalHours: 12 })],
      tasks: [{ ...baseTask, OverdueNotifiedAt: '2026-06-09T11:00:00Z' }],
      assignments: [{ AssigneeRecordID: PERSON_1 }],
      people: [{ ID: PERSON_1, LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);
  });

  it('skips a task whose resolved config has notifications disabled', async () => {
    wireRunView({
      configs: [globalConfig({ OverdueNotificationsEnabled: false })],
      tasks: [baseTask],
      assignments: [{ AssigneeRecordID: PERSON_1 }],
      people: [{ ID: PERSON_1, LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);
  });

  it('skips a task with no resolvable recipients', async () => {
    wireRunView({
      configs: [globalConfig()],
      tasks: [{ ...baseTask, CreatedByPersonID: null }],
      assignments: [],
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
        globalConfig({ ID: 'cfg-type', TaskTypeID: TYPE_1, OverdueNotificationsEnabled: false }),
      ],
      tasks: [{
        ID: TASK_1, Name: 'T', TypeID: TYPE_1, Status: 'Open', Priority: 'Low',
        DueAt: '2026-06-08T12:00:00Z', OverdueNotifiedAt: null, CreatedByPersonID: PERSON_1,
      }],
      assignments: [{ AssigneeRecordID: PERSON_1 }],
      people: [{ ID: PERSON_1, LinkedUserID: 'user-1' }],
    });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());
    expect(result.Details?.tasksNotified).toBe(0);
  });
});

describe('OverdueTaskNotificationJob.FormatNotification', () => {
  it('produces a Normal-priority summary when tasks were notified', () => {
    const job = new OverdueTaskNotificationJob();
    const content = job.FormatNotification(makeContext(), { Success: true, Details: { tasksNotified: 3 } } as ScheduledJobResult);
    expect(content.Subject).toContain('3');
    expect(content.Priority).toBe('Normal');
  });

  it('produces a Low-priority message when nothing was notified', () => {
    const job = new OverdueTaskNotificationJob();
    const content = job.FormatNotification(makeContext(), { Success: true, Details: { tasksNotified: 0 } } as ScheduledJobResult);
    expect(content.Priority).toBe('Low');
  });
});

describe('OverdueTaskNotificationJob.Execute — role assignees (bc-aidp-next-golive#442)', () => {
  const task = {
    ID: TASK_R, Name: 'Order Review', TypeID: TYPE_1, Status: 'Open', Priority: 'High',
    DueAt: '2026-06-08T12:00:00Z', OverdueNotifiedAt: null, CreatedByPersonID: null,
  };

  it('notifies the active holders of an assigned MJ role', async () => {
    resolveRoleUsers.mockResolvedValue(['user-a', 'user-b']);
    wireRunView({
      configs: [globalConfig()],
      tasks: [task],
      assignments: [{ AssigneeEntityID: ROLES_ENTITY, AssigneeRecordID: ROLE_FINANCE }],
    });
    const result = await new OverdueTaskNotificationJob().Execute(makeContext());
    expect(resolveRoleUsers).toHaveBeenCalledWith([ROLE_FINANCE], {});
    expect(result.Details?.tasksNotified).toBe(1);
    expect(
      runViewMock.mock.calls.some(
        ([p]) => (p as { EntityName: string; ExtraFilter?: string }).EntityName === 'MJ_BizApps_Common: People' &&
          String((p as { ExtraFilter?: string }).ExtraFilter).includes(ROLE_FINANCE),
      ),
    ).toBe(false);
  });

  it('keeps going when the role lookup fails', async () => {
    resolveRoleUsers.mockRejectedValue(new Error('database down'));
    wireRunView({
      configs: [globalConfig()],
      tasks: [task],
      assignments: [
        { AssigneeEntityID: ROLES_ENTITY, AssigneeRecordID: ROLE_FINANCE },
        { AssigneeEntityID: PEOPLE_ENTITY, AssigneeRecordID: PERSON_1 },
      ],
      people: [{ ID: PERSON_1, LinkedUserID: 'user-1' }],
    });
    const result = await new OverdueTaskNotificationJob().Execute(makeContext());
    expect(result.Success).toBe(true);
    expect(result.Details?.tasksNotified).toBe(1);
  });
});

describe('OverdueTaskNotificationJob — Task Overdue notification', () => {
  const overdueTask = {
    ID: TASK_1, Name: 'File quarterly report', TypeID: TYPE_1,
    Status: 'In Progress', Priority: 'High',
    DueAt: '2026-06-08T12:00:00Z',
    OverdueNotifiedAt: null as string | null,
    CreatedByPersonID: null,
  };

  function wireOverdue(task: typeof overdueTask, repeatHours: number | null = null) {
    wireRunView({
      configs: [globalConfig({ OverdueRepeatIntervalHours: repeatHours })],
      tasks: [task],
      assignments: [{ AssigneeRecordID: PERSON_1 }],
      people: [{ ID: PERSON_1, LinkedUserID: 'user-1' }],
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

  it('keeps going and stamps the task with typed OverdueNotifiedAt when the send fails', async () => {
    wireOverdue(overdueTask);
    sendNotificationMock.mockResolvedValue({ success: false, errors: ['Notification type not found: Task Overdue'] });
    const job = new OverdueTaskNotificationJob();
    const result = await job.Execute(makeContext());

    expect(result.Success).toBe(true);
    expect(result.Details?.tasksNotified).toBe(1);
    const stampedTask = createdEntities.at(-1);
    expect(stampedTask?.OverdueNotifiedAt).toBeInstanceOf(Date);
    expect(stampedTask?.Save).toHaveBeenCalledOnce();
  });
});
