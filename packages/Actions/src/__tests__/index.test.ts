import { describe, it, expect, vi } from 'vitest';

// These mocks let the module import cleanly without the heavy MJ runtime deps.
// Each custom action has focused tests alongside this smoke test.
vi.mock('@memberjunction/actions-base', () => ({}));
vi.mock('@memberjunction/actions', () => ({ BaseAction: class {}, ActionEngineServer: class {} }));
vi.mock('@memberjunction/global', () => ({ RegisterClass: () => () => {}, MJGlobal: {} }));
vi.mock('@memberjunction/core', () => ({ Metadata: class {}, RunView: class {}, RunQuery: class {} }));
vi.mock('@memberjunction/credentials', () => ({ CredentialEngine: class {} }));

describe('@mj-biz-apps/tasks-actions', () => {
  it('imports the package entry point without error', async () => {
    const mod = await import('../index.js');
    expect(mod).toBeDefined();
  });
});
