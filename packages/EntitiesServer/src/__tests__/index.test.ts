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
    MJGlobal: {
        Instance: {
            ClassFactory: {
                GetAllRegistrations: () => [],
            },
        },
    },
}));
vi.mock('@memberjunction/core', () => ({
    BaseEntity: class {},
    BaseEngine: class {
        public static getInstance() {
            return {};
        }
    },
    EntityPermissionType: { Read: 'Read' },
    LogError: () => {},
    LogStatus: () => {},
    Metadata: class {
        static Provider = { Entities: [] };
    },
    RunView: class {},
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
}));
vi.mock('@mj-biz-apps/tasks-core', () => ({
    TaskService: class {},
    TasksSettings: class {},
    UserCanManageTimeEntries: vi.fn().mockResolvedValue(false),
    UserCanManageTimesheets: vi.fn().mockResolvedValue(false),
    DeriveIntervalMinutes: vi.fn(),
    TimeEntryRefusal: vi.fn().mockReturnValue(null),
    AncestorRunIDsFor: vi.fn().mockReturnValue([]),
    TimesheetStatusFromParts: vi.fn().mockReturnValue('Submitted'),
}));
vi.mock('@mj-biz-apps/common-entities', () => ({
    BusinessTimeZoneEngine: { Instance: { Config: vi.fn(), GetBusinessTimeZone: () => 'UTC' } },
    TodayIn: () => '2026-04-15',
    ToCalendarDay: () => '2026-04-15',
    UTC_ZONE: 'UTC',
}));
vi.mock('@memberjunction/core-entities', () => ({
    ApplicationSettingEngine: { Instance: {} },
    MJAIAgentRunEntity: class {},
}));

describe('@mj-biz-apps/tasks-entities-server', () => {
    it('imports the entry point and exposes the bootstrap + all server subclasses', async () => {
        const mod = await import('../index.js');
        expect(mod.LoadBizAppsTasksEntitiesServer).toBeTypeOf('function');
        expect(mod.TaskEntityServer).toBeDefined();
        expect(mod.TaskCheckInEntityServer).toBeDefined();
        expect(mod.TaskDecisionEntityServer).toBeDefined();
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
