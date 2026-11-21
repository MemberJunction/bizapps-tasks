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
        CompositeKey: class { constructor(public KeyValuePairs: Array<{ FieldName: string; Value: string }> = []) {} },
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
vi.mock('@memberjunction/ai-core-plus', () => ({
    TypedActionPolicyGuard: { CheckEntityAccess: vi.fn(), MaskRecord: vi.fn(), MaskRows: vi.fn() },
}));
vi.mock('@memberjunction/ai-agents', () => ({
    AgentRunner: class {},
    AgentWakeTriggerService: { Instance: { TriggerWakeForWorkstream: vi.fn() } },
}));
vi.mock('@memberjunction/aiengine', () => ({
    AIEngine: { Instance: { Config: vi.fn(), Agents: [] } },
}));
vi.mock('@memberjunction/generic-database-provider', () => ({
    UserCache: { Instance: { GetSystemUser: vi.fn() } },
}));
vi.mock('@memberjunction/storage', () => ({
    FileStorageEngine: { Instance: { Config: vi.fn() } },
}));
vi.mock('@mj-biz-apps/common-entities', () => ({
    ResolveUserIDForPerson: vi.fn(),
}));
vi.mock('@mj-biz-apps/tasks-entities', () => ({
    mjBizAppsTasksTaskAgentRunEntity: class {},
    mjBizAppsTasksTaskEntity: class {},
    mjBizAppsTasksTaskTimeEntryEntity: class {},
}));
vi.mock('@memberjunction/credentials', () => ({ CredentialEngine: class {} }));

describe('@mj-biz-apps/tasks-actions', () => {
    it('imports the package entry point without error and exports all typed actions and transcript plugins', async () => {
        const mod = await import('../index.js');
        expect(mod).toBeDefined();
        expect(mod.PostTaskAssignmentToTeamsAction).toBeDefined();
        expect(mod.LinkAgentRunToTaskAction).toBeDefined();
        // Work Report actions (6)
        expect(mod.GetWorkReportAction).toBeDefined();
        expect(mod.ListWorkReportsAction).toBeDefined();
        expect(mod.DraftWorkReportAction).toBeDefined();
        expect(mod.SubmitWorkReportAction).toBeDefined();
        expect(mod.ReviewWorkReportAction).toBeDefined();
        expect(mod.GetMyWorkReportsBriefingAction).toBeDefined();
        // Typed Task actions (9)
        expect(mod.FindTasksAction).toBeDefined();
        expect(mod.GetTaskAction).toBeDefined();
        expect(mod.CreateTaskAction).toBeDefined();
        expect(mod.UpdateTaskAction).toBeDefined();
        expect(mod.CompleteTaskAction).toBeDefined();
        expect(mod.AssignTaskAction).toBeDefined();
        expect(mod.AddTaskUpdateAction).toBeDefined();
        expect(mod.FindSimilarTasksAction).toBeDefined();
        expect(mod.GetMyTasksBriefingAction).toBeDefined();
        // Typed Meetings actions (6) & Transcript plugins/service
        expect(mod.GetMyUpcomingMeetingsAction).toBeDefined();
        expect(mod.PrepareMeetingBriefAction).toBeDefined();
        expect(mod.ProcessMeetingTranscriptAction).toBeDefined();
        expect(mod.AcceptMeetingCommitmentsAction).toBeDefined();
        expect(mod.GetMeetingNotesAction).toBeDefined();
        expect(mod.GetMyMeetingsBriefingAction).toBeDefined();
        expect(mod.ZoomTranscriptSource).toBeDefined();
        expect(mod.AttachedFileTranscriptSource).toBeDefined();
        expect(mod.MeetingTranscriptService).toBeDefined();
        // Agent Task OnAssign hook, Recurring Playbooks & CoS wake dispatcher
        expect(mod.ExecuteAssignedAgentAction).toBeDefined();
        expect(mod.RunRecurringPlaybooksAction).toBeDefined();
        expect(mod.registerChiefOfStaffWakeDispatcher).toBeDefined();
    });
});
