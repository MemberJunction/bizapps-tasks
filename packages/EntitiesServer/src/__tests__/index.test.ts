import { describe, it, expect, vi } from 'vitest';

// Mock the heavy MJ runtime + sibling packages so the entry point imports cleanly
vi.mock('@memberjunction/global', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/global')>();
    return {
        ...actual,
        RegisterClass: () => () => {},
        MJGlobal: {
            Instance: {
                ClassFactory: {
                    GetAllRegistrations: () => [],
                },
            },
        },
    };
});
vi.mock('@memberjunction/core', () => ({
    BaseEntity: class {},
    BaseEntityResult: class {
        public ValidationErrors: object[] = [];
    },
    BaseEngine: class {
        public static getInstance() {
            return {};
        }
    },
    BaseRemotableOperation: class {},
    CompositeKey: class { constructor(public KeyValuePairs: unknown[]) {} },
    EntityPermissionType: { Read: 'Read' },
    LogError: () => {},
    LogStatus: () => {},
    Metadata: class {
        static Provider = { Entities: [] };
    },
    RunView: class {},
    UserInfo: class {},
    ValidationErrorInfo: class {},
    ValidationErrorType: { Failure: 'Failure' },
    ValidationResult: class {},
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
    mjBizAppsTasksTaskAgentRunEntity: class {},
    mjBizAppsTasksTaskAssignmentEntity: class {},
    mjBizAppsTasksTaskCheckInEntity: class {},
    mjBizAppsTasksTaskCommentEntity: class {},
    mjBizAppsTasksTaskDecisionEntity: class {},
    mjBizAppsTasksTaskEntity: class {},
    mjBizAppsTasksTaskLinkEntity: class {},
    mjBizAppsTasksTaskTimeEntryEntity: class {},
    mjBizAppsTasksTaskTimeEntryLinkEntity: class {},
    mjBizAppsTasksTaskTimerEntity: class {},
    mjBizAppsTasksTaskTypeEntity: class {},
    mjBizAppsTasksTaskTypeStatusEntity: class {},
    mjBizAppsTasksTimeApproverEntity: class {},
    mjBizAppsTasksTimesheetApprovalEntity: class {},
    mjBizAppsTasksTimesheetEntity: class {},
    mjBizAppsTasksTimesheetLinkEntity: class {},
    mjBizAppsTasksTimesheetScheduleEntity: class {},
    mjBizAppsTasksWorkReportEntity: class {},
    mjBizAppsTasksWorkReportItemEntity: class {},
    mjBizAppsTasksMeetingEntity: class {},
    mjBizAppsTasksMeetingSeriesEntity: class {},
    mjBizAppsTasksMeetingAttendeeEntity: class {},
    mjBizAppsTasksMeetingSeriesAttendeeEntity: class {},
    mjBizAppsTasksMeetingAgendaItemEntity: class {},
    mjBizAppsTasksMeetingLinkEntity: class {},
    mjBizAppsTasksMeetingNoteEntity: class {},
    mjBizAppsTasksVideoProviderEntity: class {},
}));
// The real tasks-core: the Meetings subclasses read its constants and pure rules at import time.
// Only the pieces that reach for the runtime are replaced.
vi.mock('@mj-biz-apps/tasks-core', async () => ({
    ...(await vi.importActual<typeof import('@mj-biz-apps/tasks-core')>('@mj-biz-apps/tasks-core')),
    TaskService: class {},
    UserCanManageTimeEntries: vi.fn().mockResolvedValue(false),
    UserCanManageTimesheets: vi.fn().mockResolvedValue(false),
    TASKS_ENTITY_NAME: 'MJ_BizApps_Tasks: Tasks',
    WORK_REPORTS_ENTITY_NAME: 'MJ_BizApps_Tasks: Work Reports',
    IsPrivilegedWorkReportUser: () => false,
    WorkReportService: { Instance: {} },
}));
vi.mock('@mj-biz-apps/common-entities', () => ({
    BusinessTimeZoneEngine: { Instance: { Config: vi.fn(), GetBusinessTimeZone: () => 'UTC', Zone: 'UTC' } },
    TodayIn: () => '2026-04-15',
    ToCalendarDay: () => '2026-04-15',
    UTC_ZONE: 'UTC',
    ResolvePersonIDForUser: vi.fn().mockResolvedValue(null),
    ResolveUserIDForPerson: vi.fn().mockResolvedValue(null),
}));
vi.mock('@memberjunction/credentials', () => ({
    CredentialEngine: { Instance: { Config: vi.fn(), GetCredential: vi.fn() } },
}));
vi.mock('@memberjunction/communication-engine', () => ({
    BaseCalendarEventLinkHandler: class {},
    CalendarEventLinks: class {},
}));
vi.mock('@memberjunction/core-entities', () => ({
    ApplicationSettingEngine: { Instance: {} },
    MJAIAgentRunEntity: class {},
}));
vi.mock('@memberjunction/ai-core-plus', () => ({
    AgentUserPolicyEngine: {
        Instance: {
            GetEffectivePolicyAgentChain: vi.fn(() => []),
            GetCachedPolicy: vi.fn(() => null),
            ResolvePolicyForAgentAndUser: vi.fn(),
            EvaluateActionExecution: vi.fn(),
        },
    },
    TypedActionPolicyGuard: {
        CheckEntityAccess: vi.fn().mockResolvedValue({ Allowed: true, Active: false, DeniedFieldPatterns: [] }),
    },
}));

describe('@mj-biz-apps/tasks-entities-server', () => {
    it('imports the entry point and exposes the bootstrap + all server subclasses', async () => {
        const mod = await import('../index.js');
        expect(mod.LoadBizAppsTasksEntitiesServer).toBeTypeOf('function');
        expect(mod.TaskEntityServer).toBeDefined();
        expect(mod.TaskCheckInEntityServer).toBeDefined();
        expect(mod.TaskDecisionEntityServer).toBeDefined();
        expect(mod.TaskAssignmentEntityServer).toBeDefined();
        expect(mod.TaskTypeEntityServer).toBeDefined();
        expect(mod.WorkReportEntityServer).toBeDefined();
        expect(mod.WorkReportItemEntityServer).toBeDefined();
        expect(mod.TaskTimeEntryEntityServer).toBeDefined();
        expect(mod.TaskTimerEntityServer).toBeDefined();
        expect(mod.TaskAgentRunEntityServer).toBeDefined();
        expect(mod.TimesheetEntityServer).toBeDefined();
        expect(mod.TimesheetApprovalEntityServer).toBeDefined();
        expect(mod.TimeApproverEntityServer).toBeDefined();
        expect(mod.TimesheetScheduleEntityServer).toBeDefined();
        expect(mod.TimesheetLinkEntityServer).toBeDefined();
        expect(mod.TaskTimeEntryLinkEntityServer).toBeDefined();
        expect(mod.BaseTimeApproverResolver).toBeDefined();
        expect(mod.TaskLinkScopeApproverResolver).toBeDefined();
        expect(mod.ApplyTimesheetApprovalOutcomeForTask).toBeTypeOf('function');
        expect(mod.MeetingEntityServer).toBeDefined();
        expect(mod.MeetingSeriesEntityServer).toBeDefined();
    });

    it('does not re-export TasksSettings from @mj-biz-apps/tasks-core (Rule 5)', async () => {
        const mod = await import('../index.js');
        expect('TasksSettings' in mod).toBe(false);
        expect(Object.keys(mod).filter((k) => /override/i.test(k))).toEqual([]);
    });

    it('LoadBizAppsTasksEntitiesServer runs without throwing', async () => {
        const mod = await import('../index.js');
        expect(() => mod.LoadBizAppsTasksEntitiesServer()).not.toThrow();
    });
});
