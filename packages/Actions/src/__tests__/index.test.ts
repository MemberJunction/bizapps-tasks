import { describe, it, expect, vi } from 'vitest';

// These mocks let the module import cleanly without the heavy MJ runtime deps.
// Each custom action has focused tests alongside this smoke test.
vi.mock('@memberjunction/actions-base', () => ({}));
vi.mock('@memberjunction/actions', () => ({ BaseAction: class {}, ActionEngineServer: class {} }));
vi.mock('@memberjunction/global', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/global')>();
    return {
        ...actual,
        RegisterClass: () => () => {},
    };
});
vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    return {
        ...actual,
        BaseEntity: class {},
        BaseRemotableOperation: class {},
        CompositeKey: class { constructor(public KeyValuePairs: unknown[]) {} },
        LogError: () => {},
        LogStatus: () => {},
        Metadata: class {},
        RunView: class {},
        RunQuery: class {},
        UserInfo: class {},
    };
});
vi.mock('@memberjunction/core-entities', () => ({
    MJAIAgentRunEntity: class {},
}));
vi.mock('@mj-biz-apps/tasks-entities', () => ({
    mjBizAppsTasksTaskAgentRunEntity: class {},
    mjBizAppsTasksTaskEntity: class {},
    mjBizAppsTasksTaskTimeEntryEntity: class {},
}));
vi.mock('@memberjunction/credentials', () => ({ CredentialEngine: class {} }));

describe('@mj-biz-apps/tasks-actions', () => {
    it('imports the package entry point without error', async () => {
        const mod = await import('../index.js');
        expect(mod).toBeDefined();
        expect(mod.PostTaskAssignmentToTeamsAction).toBeDefined();
        expect(mod.LinkAgentRunToTaskAction).toBeDefined();
        expect(mod.DraftWorkReportAction).toBeDefined();
        expect(mod.SubmitWorkReportAction).toBeDefined();
        expect(mod.ReviewWorkReportAction).toBeDefined();
    });
});
