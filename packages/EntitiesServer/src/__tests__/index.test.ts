import { describe, it, expect, vi } from 'vitest';

// Mock the heavy MJ runtime + sibling packages so the entry point imports cleanly
// without the full runtime. The server subclass's behavior (rollup) is covered by
// TaskService's unit tests; this is a smoke test for the package wiring.
vi.mock('@memberjunction/global', () => ({ RegisterClass: () => () => {} }));
vi.mock('@memberjunction/core', () => ({
  BaseEntity: class {},
  LogError: () => {},
}));
vi.mock('@mj-biz-apps/tasks-entities', () => ({ TaskEntity: class {} }));
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
