import { beforeEach, describe, expect, it, vi } from 'vitest';

const PEOPLE_ID = 'A0000000-0000-0000-0000-000000000001';
const USER_ID = 'B0000000-0000-0000-0000-000000000001';
const PERSON_ID = 'C0000000-0000-0000-0000-000000000001';
const OTHER_PERSON = 'C0000000-0000-0000-0000-000000000002';
const TASK_ID = 'D0000000-0000-0000-0000-000000000001';

const deleteDescendantSpy = vi.fn(async () => true);

const fakeDb = {
    people: [{ ID: PERSON_ID, Name: 'Alice Worker' }],
    tasks: [{ ID: TASK_ID }],
    timesheets: [] as Array<{
        ID: string;
        PersonID: string;
        PeriodStart: string;
        PeriodEnd: string;
        Status: 'Draft' | 'Submitted' | 'Approved' | 'Rejected';
    }>,
    entryLinks: [] as Array<{ ID: string; Entity: string; RecordID: string; Relationship?: string }>,
    agentRuns: [] as Array<{
        ID: string;
        UserID: string | null;
        ParentRunID: string | null;
        ParentRunIDPath: string | null;
    }>,
    taskAgentRuns: [] as Array<{ ID: string; TaskID: string; AIAgentRunID: string }>,
    canManageTimeEntries: false,
    canManageTimesheets: false,
    selfServiceSchedules: false,
};

vi.mock('@memberjunction/global', () => ({
    RegisterClass: () => () => {},
    IsValidUUID: (v: string) => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v),
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

vi.mock('@memberjunction/core-entities', () => ({
    ApplicationSettingEngine: {
        Instance: {
            Config: vi.fn(async () => undefined),
            GetSetting: () => undefined,
        },
    },
    MJAIAgentRunEntity: class {},
}));

vi.mock('@mj-biz-apps/common-entities', () => ({
    BusinessTimeZoneEngine: {
        Instance: {
            Config: vi.fn(async () => undefined),
            GetBusinessTimeZone: () => 'UTC',
            Today: () => '2026-04-15',
        },
    },
    TodayIn: () => '2026-04-15',
    ToCalendarDay: (d: Date | string | null | undefined) => {
        if (!d) return null;
        if (typeof d === 'string') return d.slice(0, 10);
        return d.toISOString().slice(0, 10);
    },
    AddDays: (day: string, delta: number) => {
        const dt = new Date(`${day}T00:00:00Z`);
        dt.setUTCDate(dt.getUTCDate() + delta);
        return dt.toISOString().slice(0, 10);
    },
    CompareDays: (a: string, b: string) => (a < b ? -1 : a > b ? 1 : 0),
    IsCalendarDay: (s: unknown) => typeof s === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(s),
    UTC_ZONE: 'UTC',
}));

vi.mock('@mj-biz-apps/tasks-core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@mj-biz-apps/tasks-core')>();
    return {
        ...actual,
        UserCanManageTimeEntries: vi.fn(() => fakeDb.canManageTimeEntries),
        UserCanManageTimesheets: vi.fn(() => fakeDb.canManageTimesheets),
        TasksSettings: {
            Load: vi.fn(async () => undefined),
            TimeTrackingEnabled: () => true,
            LockApprovedTimeEntries: () => true,
            TimesheetSchedulesSelfService: () => fakeDb.selfServiceSchedules,
        },
    };
});

vi.mock('@memberjunction/core', () => {
    class ValidationResult {
        Success = true;
        Errors: Array<{ Source: string; Message: string; Value: unknown }> = [];
    }
    class ValidationErrorInfo {
        constructor(
            public Source: string,
            public Message: string,
            public Value: unknown,
            public Type?: string,
        ) {}
    }
    class BaseEntityResult {
        Type: 'create' | 'update' | 'delete' = 'create';
        Success = true;
        Message = '';
    }
    const provider = {
        Entities: [
            {
                ID: PEOPLE_ID,
                Name: 'MJ_BizApps_Common: People',
                FirstPrimaryKey: { Name: 'ID' },
                CheckPermissions: () => true,
            },
        ],
        EntityByID: (id: string) =>
            id === PEOPLE_ID ? { Name: 'MJ_BizApps_Common: People', ParentChain: [] } : null,
    };
    return {
        BaseEntity: class {},
        BaseEntityResult,
        BaseEngine: class {
            public static getInstance() {
                return {};
            }
        },
        BaseRemotableOperation: class {},
        EntityPermissionType: { Read: 'Read' },
        LogError: vi.fn(),
        LogStatus: vi.fn(),
        Metadata: class {
            public static Provider = provider;
            public async GetEntityObject() {
                return {
                    Load: vi.fn(async () => true),
                    Delete: deleteDescendantSpy,
                };
            }
        },
        RunView: class {
            async RunView(p: { EntityName: string; ExtraFilter?: string }) {
                switch (p.EntityName) {
                    case 'MJ_BizApps_Common: People':
                        return { Success: true, Results: fakeDb.people };
                    case 'MJ_BizApps_Tasks: Tasks':
                        return { Success: true, Results: fakeDb.tasks };
                    case 'MJ_BizApps_Tasks: Timesheets':
                        return { Success: true, Results: fakeDb.timesheets };
                    case 'MJ_BizApps_Tasks: Task Time Entry Links':
                        return { Success: true, Results: fakeDb.entryLinks };
                    case 'MJ: AI Agent Runs':
                        return { Success: true, Results: fakeDb.agentRuns };
                    case 'MJ_BizApps_Tasks: Task Agent Runs':
                        return { Success: true, Results: fakeDb.taskAgentRuns };
                    default:
                        return { Success: true, Results: [] };
                }
            }
        },
        ValidationResult,
        ValidationErrorInfo,
        ValidationErrorType: { Failure: 'Failure' },
    };
});

vi.mock('@mj-biz-apps/tasks-entities', () => {
    class MockBaseEntity {
        ID = 'E0000000-0000-0000-0000-000000000001';
        IsSaved = false;
        RunViewProviderToUse = {};
        ContextCurrentUser: { ID: string } | null = { ID: USER_ID };
        ResultHistory: Array<{ Type: string; Success: boolean; Message: string }> = [];
        LatestResult = {
            Success: true,
            Errors: [] as Array<{ Source: string; Message: string; Value: unknown }>,
            CompleteMessage: '',
        };
        fields = new Map<string, { Dirty: boolean; OldValue: unknown }>();
        GetFieldByName(name: string) {
            return this.fields.get(name) ?? { Dirty: false, OldValue: null };
        }
        async Load(_id: string): Promise<boolean> {
            return true;
        }
        async Save(): Promise<boolean> {
            const val = await this.ValidateAsync();
            if (!val.Success) {
                this.LatestResult.Success = false;
                this.LatestResult.Errors.push(...val.Errors);
                return false;
            }
            this.IsSaved = true;
            return true;
        }
        async Delete(): Promise<boolean> {
            return true;
        }
        async ValidateAsync() {
            return {
                Success: true,
                Errors: [] as Array<{ Source: string; Message: string; Value: unknown }>,
            };
        }
    }

    return {
        mjBizAppsTasksTaskTimeEntryEntity: class extends MockBaseEntity {
            TaskID = TASK_ID;
            PersonID = PERSON_ID;
            WorkDate = new Date('2026-04-15T00:00:00Z');
            Minutes = 60;
            StartedAt: Date | null = null;
            EndedAt: Date | null = null;
            TimesheetID: string | null = null;
            Person = 'Alice Worker';
        },
        mjBizAppsTasksTaskTimerEntity: class extends MockBaseEntity {
            TaskID = TASK_ID;
            PersonID = PERSON_ID;
            StartedAt = new Date('2026-04-15T10:00:00Z');
            Person = 'Alice Worker';
        },
        mjBizAppsTasksTaskAgentRunEntity: class extends MockBaseEntity {
            TaskID = TASK_ID;
            AIAgentRunID = 'F0000000-0000-0000-0000-000000000001';
            Role: 'Executed' | 'Assisted' = 'Executed';
        },
        mjBizAppsTasksTimeApproverEntity: class extends MockBaseEntity {
            ApproverPersonID = OTHER_PERSON;
            ScopeEntityID: string | null = null;
            ScopeRecordID: string | null = null;
        },
        mjBizAppsTasksTimesheetScheduleEntity: class extends MockBaseEntity {
            PersonID: string | null = PERSON_ID;
            ScopeEntityID: string | null = null;
            ScopeRecordID: string | null = null;
        },
    };
});

const { TaskTimeEntryEntityServer } = await import('../TaskTimeEntryEntityServer.js');
const { TaskTimerEntityServer } = await import('../TaskTimerEntityServer.js');
const { TaskAgentRunEntityServer } = await import('../TaskAgentRunEntityServer.js');
const { TimeApproverEntityServer } = await import('../TimeApproverEntityServer.js');
const { TimesheetScheduleEntityServer } = await import('../TimesheetScheduleEntityServer.js');

describe('TimeTrackingEntitiesServer', () => {
    beforeEach(() => {
        fakeDb.people = [{ ID: PERSON_ID, Name: 'Alice Worker' }];
        fakeDb.tasks = [{ ID: TASK_ID }];
        fakeDb.timesheets = [];
        fakeDb.entryLinks = [];
        fakeDb.agentRuns = [];
        fakeDb.taskAgentRuns = [];
        fakeDb.canManageTimeEntries = false;
        fakeDb.canManageTimesheets = false;
        fakeDb.selfServiceSchedules = false;
        deleteDescendantSpy.mockClear();
    });

    describe('TaskTimeEntryEntityServer (R1–R8)', () => {
        it('stamps PersonID on create (R1) and derives Minutes when StartedAt & EndedAt are set (R4)', async () => {
            const entry = new TaskTimeEntryEntityServer();
            entry.PersonID = '';
            entry.StartedAt = new Date('2026-04-15T09:00:00Z');
            entry.EndedAt = new Date('2026-04-15T10:30:00Z');
            const ok = await entry.Save();
            expect(ok).toBe(true);
            expect(entry.PersonID).toBe(PERSON_ID);
            expect(entry.Minutes).toBe(90);
        });

        it('refuses editing another person entry without Manage Time Entries (R2)', async () => {
            const entry = new TaskTimeEntryEntityServer();
            entry.PersonID = OTHER_PERSON;
            entry.Person = 'Bob';
            const ok = await entry.Save();
            expect(ok).toBe(false);
            expect(entry.LatestResult.Errors[0].Message).toMatch(/Only Bob or a time-entry manager/);
        });

        it('refuses logging time in a Submitted or Approved timesheet period (R6)', async () => {
            fakeDb.timesheets = [
                {
                    ID: 'A1000000-0000-0000-0000-000000000001',
                    PersonID: PERSON_ID,
                    PeriodStart: '2026-04-13',
                    PeriodEnd: '2026-04-19',
                    Status: 'Approved',
                },
            ];
            const entry = new TaskTimeEntryEntityServer();
            const ok = await entry.Save();
            expect(ok).toBe(false);
            expect(entry.LatestResult.Errors[0].Message).toMatch(/The period 2026-04-13 to 2026-04-19 is Approved/);
        });

        it('automatically binds TimesheetID to a Draft timesheet covering WorkDate (R7)', async () => {
            const draftTsId = 'A1000000-0000-0000-0000-000000000002';
            fakeDb.timesheets = [
                {
                    ID: draftTsId,
                    PersonID: PERSON_ID,
                    PeriodStart: '2026-04-13',
                    PeriodEnd: '2026-04-19',
                    Status: 'Draft',
                },
            ];
            const entry = new TaskTimeEntryEntityServer();
            const ok = await entry.Save();
            expect(ok).toBe(true);
            expect(entry.TimesheetID).toBe(draftTsId);
        });

        it('refuses updating or deleting an entry referenced by a TaskTimeEntryLink (R8)', async () => {
            fakeDb.entryLinks = [{ ID: 'l-1', Entity: 'Invoices', RecordID: 'INV-900' }];
            const entry = new TaskTimeEntryEntityServer();
            entry.IsSaved = true;
            const saveOk = await entry.Save();
            expect(saveOk).toBe(false);
            expect(entry.LatestResult.Errors[0].Message).toMatch(/used by Invoices \(INV-900\)/);

            const delOk = await entry.Delete();
            expect(delOk).toBe(false);
        });
    });

    describe('TaskTimerEntityServer (R2)', () => {
        it('allows owner to save and delete their own timer, and refuses non-owners without Manage Time Entries', async () => {
            const ownTimer = new TaskTimerEntityServer();
            expect(await ownTimer.Save()).toBe(true);
            expect(await ownTimer.Delete()).toBe(true);

            const otherTimer = new TaskTimerEntityServer();
            otherTimer.PersonID = OTHER_PERSON;
            otherTimer.Person = 'Bob';
            expect(await otherTimer.Delete()).toBe(false);
            expect(otherTimer.ResultHistory[0].Message).toMatch(/Only Bob or a time-entry manager/);
        });
    });

    describe('TaskAgentRunEntityServer (A1–A2)', () => {
        it('refuses linking a run owned by another user unless Manage Time Entries is held (A1)', async () => {
            fakeDb.agentRuns = [
                {
                    ID: 'F0000000-0000-0000-0000-000000000001',
                    UserID: 'B0000000-0000-0000-0000-000000000099',
                    ParentRunID: null,
                    ParentRunIDPath: null,
                },
            ];
            const link = new TaskAgentRunEntityServer();
            expect(await link.Save()).toBe(false);
            expect(link.ResultHistory[0].Message).toMatch(/runs that you started yourself/);
        });

        it('skips saving when an ancestor run is already linked to the same task, and removes descendant links when linking a parent run (A2)', async () => {
            const rootRun = 'F0000000-0000-0000-0000-000000000001';
            const childRun = 'F0000000-0000-0000-0000-000000000002';
            fakeDb.agentRuns = [
                { ID: rootRun, UserID: USER_ID, ParentRunID: null, ParentRunIDPath: `/${rootRun}/` },
                { ID: childRun, UserID: USER_ID, ParentRunID: rootRun, ParentRunIDPath: `/${rootRun}/${childRun}/` },
            ];
            fakeDb.taskAgentRuns = [
                { ID: 'A2000000-0000-0000-0000-000000000001', TaskID: TASK_ID, AIAgentRunID: rootRun },
            ];

            // Attempting to link childRun when rootRun is already linked -> skipped, returns true without saving
            const childLink = new TaskAgentRunEntityServer();
            childLink.AIAgentRunID = childRun;
            expect(await childLink.Save()).toBe(true);
            expect(childLink.IsSaved).toBe(false);

            // Linking rootRun when childRun is already linked -> deletes childRun link and saves rootRun link
            fakeDb.taskAgentRuns = [
                { ID: 'A2000000-0000-0000-0000-000000000002', TaskID: TASK_ID, AIAgentRunID: childRun },
            ];
            const parentLink = new TaskAgentRunEntityServer();
            parentLink.AIAgentRunID = rootRun;
            expect(await parentLink.Save()).toBe(true);
            expect(parentLink.IsSaved).toBe(true);
            expect(deleteDescendantSpy).toHaveBeenCalledTimes(1);
        });
    });

    describe('TimeApproverEntityServer & TimesheetScheduleEntityServer', () => {
        it('requires Manage Timesheets on TimeApproverEntityServer', async () => {
            const approver = new TimeApproverEntityServer();
            expect(await approver.Save()).toBe(false);
            expect(approver.LatestResult.Errors[0].Message).toMatch(/Manage Timesheets/);

            fakeDb.canManageTimesheets = true;
            expect(await approver.Save()).toBe(true);
        });

        it('allows self-service schedule for own Person when TimesheetSchedulesSelfService is true', async () => {
            const sched = new TimesheetScheduleEntityServer();
            expect(await sched.Save()).toBe(false);

            fakeDb.selfServiceSchedules = true;
            expect(await sched.Save()).toBe(true);

            // Still refuses self-service schedule for another person
            const otherSched = new TimesheetScheduleEntityServer();
            otherSched.PersonID = OTHER_PERSON;
            expect(await otherSched.Save()).toBe(false);
        });
    });
});
