import { describe, it, expect, vi } from 'vitest';

// Mock the heavy MJ runtime + sibling packages so the entry point imports cleanly
vi.mock('@memberjunction/global', () => ({
  RegisterClass: () => () => {},
  IsValidUUID: () => true,
  BaseSingleton: class {
    public static getInstance() {
      return {};
    }
  },
}));
vi.mock('@memberjunction/core', () => ({
  BaseEntity: class {},
  BaseEngine: class {
    public static getInstance() {
      return {};
    }
  },
  LogError: () => {},
  LogStatus: () => {},
  Metadata: class {},
  RunView: class {},
}));
vi.mock('@memberjunction/actions', () => ({
  ActionEngineServer: {
    Instance: {
      Config: vi.fn().mockResolvedValue(undefined),
      Actions: [],
      RunAction: vi.fn().mockResolvedValue({ Success: true }),
    },
  },
}));
vi.mock('@mj-biz-apps/tasks-entities', () => ({
  TaskEntity: class {},
  mjBizAppsTasksTaskActivityEntity: class {},
  mjBizAppsTasksTaskCheckInEntity: class {},
  mjBizAppsTasksTaskDecisionEntity: class {},
  mjBizAppsTasksTaskEntity: class {},
  mjBizAppsTasksTaskTypeEntity: class {},
  mjBizAppsTasksTaskTypeStatusEntity: class {},
  mjBizAppsTasksMeetingEntity: class {},
  mjBizAppsTasksMeetingSeriesEntity: class {},
  mjBizAppsTasksMeetingAttendeeEntity: class {},
  mjBizAppsTasksMeetingSeriesAttendeeEntity: class {},
  mjBizAppsTasksMeetingAgendaItemEntity: class {},
  mjBizAppsTasksMeetingLinkEntity: class {},
  mjBizAppsTasksMeetingNoteEntity: class {},
  mjBizAppsTasksVideoProviderEntity: class {},
}));
vi.mock('@mj-biz-apps/common-entities', () => ({
  BusinessTimeZoneEngine: { Instance: { Config: async () => undefined, Zone: 'UTC' } },
}));
vi.mock('@mj-biz-apps/tasks-core', async () => ({ ...(await vi.importActual<typeof import('@mj-biz-apps/tasks-core')>('@mj-biz-apps/tasks-core')), TaskService: class {} }));
vi.mock('@memberjunction/core-entities', () => ({ ApplicationSettingEngine: { Instance: {} } }));

describe('@mj-biz-apps/tasks-entities-server', () => {
  it('imports the entry point and exposes the bootstrap + subclasses', async () => {
    const mod = await import('../index.js');
    expect(mod.LoadBizAppsTasksEntitiesServer).toBeTypeOf('function');
    expect(mod.TaskEntityServer).toBeDefined();
    expect(mod.MeetingEntityServer).toBeDefined();
    expect(mod.MeetingSeriesEntityServer).toBeDefined();
    expect(mod.TaskCheckInEntityServer).toBeDefined();
    expect(mod.TaskDecisionEntityServer).toBeDefined();
  });

  it('exports no way to override a Tasks setting in-process', async () => {
    const mod = await import('../index.js');
    expect(Object.getOwnPropertyNames(mod.TasksSettings).filter((m) => /override/i.test(m))).toEqual([]);
    expect(Object.keys(mod).filter((k) => /override/i.test(k))).toEqual([]);
  });

  it('LoadBizAppsTasksEntitiesServer runs without throwing', async () => {
    const mod = await import('../index.js');
    expect(() => mod.LoadBizAppsTasksEntitiesServer()).not.toThrow();
  });
});
