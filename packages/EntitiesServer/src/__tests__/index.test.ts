import { describe, it, expect, vi } from 'vitest';

// Mock the heavy MJ runtime + sibling packages so the entry point imports cleanly
vi.mock('@memberjunction/global', () => ({
  RegisterClass: () => () => {},
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
  mjBizAppsTasksTaskEntity: class {},
  mjBizAppsTasksTaskTypeEntity: class {},
  mjBizAppsTasksTaskTypeStatusEntity: class {},
}));
vi.mock('@mj-biz-apps/tasks-core', () => ({ TaskService: class {} }));

describe('@mj-biz-apps/tasks-entities-server', () => {
  it('imports the entry point and exposes the bootstrap + subclass', async () => {
    const mod = await import('../index.js');
    expect(mod.LoadBizAppsTasksEntitiesServer).toBeTypeOf('function');
    expect(mod.TaskEntityServer).toBeDefined();
  });

  it('LoadBizAppsTasksEntitiesServer runs without throwing', async () => {
    const mod = await import('../index.js');
    expect(() => mod.LoadBizAppsTasksEntitiesServer()).not.toThrow();
  });
});
