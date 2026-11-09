import { describe, it, expect, beforeEach, vi } from 'vitest';
import type { IMetadataProvider, RemoteOpServerContext, UserInfo } from '@memberjunction/core';

const {
    runViewMock,
    getSettingMock,
    peopleForUserMock,
    resolveAllForRootTasksMock,
} = vi.hoisted(() => ({
    runViewMock: vi.fn(),
    getSettingMock: vi.fn(),
    peopleForUserMock: vi.fn(),
    resolveAllForRootTasksMock: vi.fn(),
}));

vi.mock('@memberjunction/global', () => ({
    RegisterClass: () => () => {},
    IsValidUUID: (v: string) =>
        typeof v === 'string' &&
        /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v),
}));

vi.mock('@memberjunction/core', () => {
    class FakeBaseRemotableOperation<TIn = unknown, TOut = unknown> {
        public async Execute(
            input: TIn,
            provider: IMetadataProvider,
            user: UserInfo,
            context: RemoteOpServerContext,
        ): Promise<TOut> {
            return (this as unknown as {
                InternalExecute: (i: TIn, p: IMetadataProvider, u: UserInfo, c: RemoteOpServerContext) => Promise<TOut>;
            }).InternalExecute(input, provider, user, context);
        }
    }
    class FakeRemoteOperationError extends Error {
        public constructor(
            public readonly Code: string,
            message: string,
        ) {
            super(message);
        }
    }
    return {
        BaseEntity: class {},
        CompositeKey: class {
            public KeyValuePairs: unknown[] = [];
        },
        ValidationResult: class {
            public Success = true;
            public Errors: unknown[] = [];
        },
        ValidationErrorInfo: class {},
        ValidationErrorType: { Failure: 'Failure', Warning: 'Warning' },
        BaseRemotableOperation: FakeBaseRemotableOperation,
        RemoteOperationError: FakeRemoteOperationError,
        RunInEntityTransaction: async (_provider: IMetadataProvider, fn: () => Promise<unknown>) => fn(),
        RunView: class {
            public RunView(...args: unknown[]): unknown {
                return runViewMock(...args);
            }
        },
        AuthorizationEvaluator: class {
            public UserCanExecuteWithAncestors(
                auth: { ID: string },
                user: { UserRoles?: Array<{ RoleID: string }> },
            ): boolean {
                const roles = user.UserRoles ?? [];
                return roles.some((r) => r.RoleID === auth.ID);
            }
        },
        UserInfo: class {},
    };
});

vi.mock('@memberjunction/core-entities', () => ({
    ApplicationSettingEngine: {
        Instance: {
            Config: vi.fn(async () => undefined),
            GetSetting: (...args: unknown[]) => getSettingMock(...args),
        },
    },
}));

vi.mock('@mj-biz-apps/common-entities', async () => {
    return {
        UTC_ZONE: 'UTC',
        IsKnownTimeZone: () => true,
        CalendarDayIn: (date: Date) => date.toISOString().slice(0, 10),
        DayStartUtc: (day: string) => new Date(`${day}T00:00:00.000Z`),
        BusinessTimeZoneEngine: {
            Instance: {
                Config: vi.fn(async () => undefined),
                Zone: 'UTC',
            },
        },
        ToCalendarDay: (val: Date | string | null | undefined) => {
            if (!val) return null;
            if (typeof val === 'string') return val.slice(0, 10);
            return val.toISOString().slice(0, 10);
        },
        FromCalendarDay: (day: string) => new Date(`${day}T00:00:00.000Z`),
        IsCalendarDay: (day: string) => /^\d{4}-\d{2}-\d{2}$/.test(day),
        CompareDays: (a: string, b: string) => a.localeCompare(b),
        AddDays: (day: string, offset: number) => {
            const d = new Date(`${day}T00:00:00.000Z`);
            d.setUTCDate(d.getUTCDate() + offset);
            return d.toISOString().slice(0, 10);
        },
        FirstDayOfMonth: (day: string) => `${day.slice(0, 7)}-01`,
    };
});

vi.mock('@mj-biz-apps/tasks-entities-server', () => ({
    PEOPLE_ENTITY: 'MJ_BizApps_Common: People',
    TIMESHEET_APPROVAL_TASK_TYPE_CODE: 'TIMESHEET_APPROVAL',
    PeopleForUser: (...args: unknown[]) => peopleForUserMock(...args),
    BaseTimeApproverResolver: {
        ResolveAllForRootTasks: (...args: unknown[]) => resolveAllForRootTasksMock(...args),
    },
}));

import {
    StartTimerOperationServer,
    StopTimerOperationServer,
} from '../TimerOperationsServer.js';
import { GetTaskEffortOperationServer } from '../GetTaskEffortOperationServer.js';
import {
    ReopenTimesheetOperationServer,
    SubmitTimesheetOperationServer,
    WithdrawTimesheetOperationServer,
} from '../TimesheetOperationsServer.js';

const APP_ID = '00000000-0000-4000-8000-000000000001';
const USER_ID = '00000000-0000-4000-8000-000000000002';
const PERSON_ID = '00000000-0000-4000-8000-000000000003';
const OTHER_PERSON_ID = '00000000-0000-4000-8000-000000000004';
const APPROVER_PERSON_ID = '00000000-0000-4000-8000-000000000005';
const TASK_1_ID = '00000000-0000-4000-8000-000000000011';
const TASK_2_ID = '00000000-0000-4000-8000-000000000012';
const TIMER_1_ID = '00000000-0000-4000-8000-000000000021';
const TIMER_2_ID = '00000000-0000-4000-8000-000000000022';
const ENTRY_1_ID = '00000000-0000-4000-8000-000000000031';
const ENTRY_2_ID = '00000000-0000-4000-8000-000000000032';
const TIMESHEET_ID = '00000000-0000-4000-8000-000000000041';
const PART_1_ID = '00000000-0000-4000-8000-000000000051';
const APPROVAL_TASK_ID = '00000000-0000-4000-8000-000000000061';
const TASK_TYPE_ID = '00000000-0000-4000-8000-000000000071';
const RUN_ROOT_ID = '00000000-0000-4000-8000-000000000081';
const RUN_CHILD_ID = '00000000-0000-4000-8000-000000000082';
const MANAGE_TS_AUTH_ID = '00000000-0000-4000-8000-000000000091';
const MANAGE_TE_AUTH_ID = '00000000-0000-4000-8000-000000000092';

function makeUser(roleIDs: string[] = []): UserInfo {
    return {
        ID: USER_ID,
        Name: 'Test Worker',
        Email: 'worker@example.com',
        UserRoles: roleIDs.map((id) => ({ RoleID: id })),
    } as unknown as UserInfo;
}

interface FakeEntityRecord {
    ID: string;
    EntityName: string;
    SavedCount: number;
    DeletedCount: number;
    LoadResult?: boolean;
    SaveResult?: boolean;
    DeleteResult?: boolean;
    LatestResult?: { CompleteMessage?: string };
    ResultHistory?: Array<{ Message: string }>;
    [key: string]: unknown;
}

function makeProvider(options: {
    onCreateEntity?: (entityName: string) => FakeEntityRecord;
} = {}): { provider: IMetadataProvider; created: FakeEntityRecord[] } {
    const created: FakeEntityRecord[] = [];
    let seq = 1;
    const provider = {
        Applications: [{ ID: APP_ID, Name: 'Tasks' }],
        Entities: [
            { ID: '00000000-0000-4000-8000-000000000101', Name: 'MJ_BizApps_Tasks: Tasks' },
            { ID: '00000000-0000-4000-8000-000000000102', Name: 'MJ_BizApps_Common: People' },
            { ID: '00000000-0000-4000-8000-000000000103', Name: 'MJ_BizApps_Tasks: Timesheet Approvals' },
        ],
        Authorizations: [
            { ID: '00000000-0000-4000-8000-000000000090', Name: 'Tasks', ParentID: null },
            {
                ID: MANAGE_TS_AUTH_ID,
                Name: 'Manage Timesheets',
                ParentID: '00000000-0000-4000-8000-000000000090',
            },
            {
                ID: MANAGE_TE_AUTH_ID,
                Name: 'Manage Time Entries',
                ParentID: '00000000-0000-4000-8000-000000000090',
            },
        ],
        GetEntityObject: vi.fn(async (entityName: string) => {
            if (options.onCreateEntity) {
                const custom = options.onCreateEntity(entityName);
                created.push(custom);
                return custom;
            }
            const idSuffix = String(seq++).padStart(12, '0');
            const rec: FakeEntityRecord = {
                ID: `00000000-0000-4000-9000-${idSuffix}`,
                EntityName: entityName,
                SavedCount: 0,
                DeletedCount: 0,
                LatestResult: { CompleteMessage: '' },
                ResultHistory: [],
                NewRecord: vi.fn(),
                Load: vi.fn(async (id: string) => {
                    rec.ID = id;
                    return rec.LoadResult ?? true;
                }),
                Save: vi.fn(async () => {
                    rec.SavedCount++;
                    return rec.SaveResult ?? true;
                }),
                Delete: vi.fn(async () => {
                    rec.DeletedCount++;
                    return rec.DeleteResult ?? true;
                }),
            };
            created.push(rec);
            return rec;
        }),
    } as unknown as IMetadataProvider;

    return { provider, created };
}

const dummyContext = {} as unknown as RemoteOpServerContext;

describe('StartTimerOperationServer & StopTimerOperationServer', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        getSettingMock.mockReturnValue(undefined);
        peopleForUserMock.mockResolvedValue([PERSON_ID]);
        resolveAllForRootTasksMock.mockResolvedValue(new Map());
    });

    it('StartTimer refuses when TimeTrackingEnabled is false', async () => {
        getSettingMock.mockImplementation((key: string) => (key === 'TimeTrackingEnabled' ? 'false' : undefined));
        const { provider } = makeProvider();
        const op = new StartTimerOperationServer();
        const res = await op.Execute({ TaskID: TASK_1_ID }, provider, makeUser(), dummyContext);
        expect(res.Success).toBe(false);
        expect(res.Message).toContain('disabled');
    });

    it('StartTimer refuses when TaskID is invalid or caller has no Person', async () => {
        const { provider } = makeProvider();
        const op = new StartTimerOperationServer();

        const badId = await op.Execute({ TaskID: 'not-a-uuid' }, provider, makeUser(), dummyContext);
        expect(badId.Success).toBe(false);

        peopleForUserMock.mockResolvedValueOnce([]);
        const noPerson = await op.Execute({ TaskID: TASK_1_ID }, provider, makeUser(), dummyContext);
        expect(noPerson.Success).toBe(false);
        expect(noPerson.Message).toContain('no person record');
    });

    it('StartTimer returns existing timer idempotently when already running on the same task', async () => {
        const existingTimer = {
            ID: TIMER_1_ID,
            TaskID: TASK_1_ID,
            PersonID: PERSON_ID,
            StartedAt: new Date('2026-11-08T10:00:00Z'),
        };
        runViewMock.mockImplementation((params: { EntityName: string }) => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                return Promise.resolve({ Success: true, Results: [{ ID: TASK_1_ID, Name: 'Task 1' }] });
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Timers') {
                return Promise.resolve({ Success: true, Results: [existingTimer] });
            }
            return Promise.resolve({ Success: true, Results: [] });
        });

        const { provider, created } = makeProvider();
        const op = new StartTimerOperationServer();
        const res = await op.Execute({ TaskID: TASK_1_ID }, provider, makeUser(), dummyContext);
        expect(res.Success).toBe(true);
        expect(res.TimerID).toBe(TIMER_1_ID);
        expect(created.length).toBe(0);
    });

    it('StartTimer atomically stops an existing timer on another task and starts the new timer', async () => {
        const oldTimer = {
            ID: TIMER_1_ID,
            TaskID: TASK_1_ID,
            PersonID: PERSON_ID,
            StartedAt: new Date(Date.now() - 30 * 60_000),
            Notes: 'Earlier task work',
            IsBillable: true,
            Delete: vi.fn(async () => true),
        };
        runViewMock.mockImplementation((params: { EntityName: string }) => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                return Promise.resolve({ Success: true, Results: [{ ID: TASK_2_ID, Name: 'Task 2' }] });
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Timers') {
                return Promise.resolve({ Success: true, Results: [oldTimer] });
            }
            return Promise.resolve({ Success: true, Results: [] });
        });

        const { provider, created } = makeProvider();
        const op = new StartTimerOperationServer();
        const res = await op.Execute({ TaskID: TASK_2_ID, Notes: 'New work' }, provider, makeUser(), dummyContext);
        expect(res.Success).toBe(true);
        expect(res.AutoStoppedEntryIDs?.length).toBe(1);
        expect(res.AutoStoppedMinutes).toBeGreaterThanOrEqual(29);
        expect(oldTimer.Delete).toHaveBeenCalledTimes(1);
        const timerCreated = created.find((c) => c.EntityName === 'MJ_BizApps_Tasks: Task Timers');
        expect(timerCreated?.TaskID).toBe(TASK_2_ID);
    });

    it('StopTimer splits a cross-midnight timer into per-day TaskTimeEntry rows and deletes the timer', async () => {
        const runningTimer = {
            ID: TIMER_2_ID,
            TaskID: TASK_1_ID,
            PersonID: PERSON_ID,
            StartedAt: new Date('2026-11-07T23:00:00Z'),
            Notes: 'Late night deploy',
            IsBillable: true,
            Delete: vi.fn(async () => true),
        };
        runViewMock.mockResolvedValue({ Success: true, Results: [runningTimer] });

        const { provider, created } = makeProvider();
        const op = new StopTimerOperationServer();
        const res = await op.Execute(
            { EndedAt: '2026-11-08T01:30:00Z' },
            provider,
            makeUser(),
            dummyContext,
        );
        expect(res.Success).toBe(true);
        expect(res.CreatedTimeEntryIDs.length).toBe(2);
        expect(res.TotalMinutes).toBe(150);
        expect(runningTimer.Delete).toHaveBeenCalledTimes(1);
        const savedEntries = created.filter((c) => c.EntityName === 'MJ_BizApps_Tasks: Task Time Entries');
        expect(savedEntries).toHaveLength(2);
        expect(savedEntries[0].Minutes).toBe(60);
        expect(savedEntries[1].Minutes).toBe(90);
    });

    it('StopTimer discards a short timer when elapsed seconds < DiscardIfUnderSeconds', async () => {
        const shortTimer = {
            ID: TIMER_2_ID,
            TaskID: TASK_1_ID,
            PersonID: PERSON_ID,
            StartedAt: new Date('2026-11-08T10:00:00Z'),
            Notes: null,
            IsBillable: true,
            Delete: vi.fn(async () => true),
        };
        runViewMock.mockResolvedValue({ Success: true, Results: [shortTimer] });

        const { provider } = makeProvider();
        const op = new StopTimerOperationServer();
        const res = await op.Execute(
            { EndedAt: '2026-11-08T10:00:10Z', DiscardIfUnderSeconds: 30 },
            provider,
            makeUser(),
            dummyContext,
        );
        expect(res.Success).toBe(true);
        expect(res.Discarded).toBe(true);
        expect(res.CreatedTimeEntryIDs).toEqual([]);
        expect(shortTimer.Delete).toHaveBeenCalledTimes(1);
    });
});

describe('GetTaskEffortOperationServer', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('aggregates human hours and deduplicates nested AI agent runs across a task subtree', async () => {
        runViewMock.mockImplementation((params: { EntityName: string; ExtraFilter?: string }) => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                if (params.ExtraFilter?.includes(`ID='${TASK_1_ID}'`)) {
                    return Promise.resolve({
                        Success: true,
                        Results: [
                            {
                                ID: TASK_1_ID,
                                Name: 'Root Project',
                                ParentID: null,
                                RootParentID: null,
                                HoursEstimated: 5,
                            },
                        ],
                    });
                }
                return Promise.resolve({
                    Success: true,
                    Results: [
                        {
                            ID: TASK_1_ID,
                            Name: 'Root Project',
                            ParentID: null,
                            RootParentID: null,
                            HoursEstimated: 5,
                        },
                        {
                            ID: TASK_2_ID,
                            Name: 'Child Task',
                            ParentID: TASK_1_ID,
                            RootParentID: TASK_1_ID,
                            HoursEstimated: 2,
                        },
                    ],
                });
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Time Entries') {
                return Promise.resolve({
                    Success: true,
                    Results: [
                        {
                            ID: ENTRY_1_ID,
                            TaskID: TASK_1_ID,
                            Task: 'Root Project',
                            PersonID: PERSON_ID,
                            Person: 'Alice',
                            WorkDate: '2026-11-03',
                            Minutes: 120,
                            StartedAt: null,
                            EndedAt: null,
                            Notes: 'Architecture',
                            Source: 'Manual',
                            IsBillable: true,
                            TimesheetID: null,
                        },
                        {
                            ID: ENTRY_2_ID,
                            TaskID: TASK_2_ID,
                            Task: 'Child Task',
                            PersonID: OTHER_PERSON_ID,
                            Person: 'Bob',
                            WorkDate: '2026-11-04',
                            Minutes: 60,
                            StartedAt: null,
                            EndedAt: null,
                            Notes: 'Internal sync',
                            Source: 'Timer',
                            IsBillable: false,
                            TimesheetID: null,
                        },
                    ],
                });
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Agent Runs') {
                return Promise.resolve({
                    Success: true,
                    Results: [
                        {
                            ID: 'link-1',
                            TaskID: TASK_1_ID,
                            Task: 'Root Project',
                            AIAgentRunID: RUN_ROOT_ID,
                            Role: 'Executed',
                            Notes: 'Parent orchestrator run',
                        },
                        {
                            ID: 'link-2',
                            TaskID: TASK_2_ID,
                            Task: 'Child Task',
                            AIAgentRunID: RUN_CHILD_ID,
                            Role: 'Assisted',
                            Notes: 'Child sub-agent run',
                        },
                    ],
                });
            }
            if (params.EntityName === 'MJ: AI Agent Runs') {
                return Promise.resolve({
                    Success: true,
                    Results: [
                        {
                            ID: RUN_ROOT_ID,
                            AgentID: 'agent-1',
                            Agent: 'Orchestrator',
                            ParentRunID: null,
                            Status: 'Completed',
                            StartedAt: '2026-11-03T10:00:00Z',
                            CompletedAt: '2026-11-03T10:02:00Z',
                            TotalTokensUsed: 1000,
                            TotalTokensUsedRollup: 1500,
                            TotalCost: 0.1,
                            TotalCostRollup: 0.25,
                        },
                        {
                            ID: RUN_CHILD_ID,
                            AgentID: 'agent-2',
                            Agent: 'SubAgent',
                            ParentRunID: RUN_ROOT_ID,
                            Status: 'Completed',
                            StartedAt: '2026-11-03T10:00:30Z',
                            CompletedAt: '2026-11-03T10:01:00Z',
                            TotalTokensUsed: 500,
                            TotalTokensUsedRollup: null,
                            TotalCost: 0.15,
                            TotalCostRollup: null,
                        },
                    ],
                });
            }
            return Promise.resolve({ Success: true, Results: [] });
        });

        const { provider } = makeProvider();
        const op = new GetTaskEffortOperationServer();
        const res = await op.Execute(
            { TaskID: TASK_1_ID, IncludeDescendants: true },
            provider,
            makeUser(),
            dummyContext,
        );

        expect(res.DirectLoggedMinutes).toBe(120);
        expect(res.RolledUpLoggedMinutes).toBe(180);
        expect(res.BillableMinutes).toBe(120);
        expect(res.NonBillableMinutes).toBe(60);
        expect(res.EstimatedMinutes).toBe(300); // 5h * 60
        expect(res.VarianceMinutes).toBe(-120); // 180 - 300
        expect(res.DirectAgentRunCount).toBe(1);
        expect(res.RolledUpAgentRunCount).toBe(1); // Child run deduplicated under root run
        expect(res.AgentTotalTokens).toBe(1500);
        expect(res.AgentTotalCost).toBeCloseTo(0.25, 5);
        expect(res.AgentWallClockSeconds).toBe(120);
        expect(res.AgentRuns.find((r) => r.AIAgentRunID === RUN_ROOT_ID)?.CountedInTotals).toBe(true);
        expect(res.AgentRuns.find((r) => r.AIAgentRunID === RUN_CHILD_ID)?.CountedInTotals).toBe(false);
    });
});

describe('SubmitTimesheet, WithdrawTimesheet, and ReopenTimesheet operations', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        getSettingMock.mockReturnValue(undefined);
        peopleForUserMock.mockResolvedValue([PERSON_ID]);
        resolveAllForRootTasksMock.mockResolvedValue(new Map());
    });

    it('SubmitTimesheet refuses when an entry has no resolved approver', async () => {
        runViewMock.mockImplementation((params: { EntityName: string }) => {
            switch (params.EntityName) {
                case 'MJ_BizApps_Tasks: Task Time Entries':
                    return Promise.resolve({
                        Success: true,
                        Results: [
                            {
                                ID: ENTRY_1_ID,
                                TaskID: TASK_1_ID,
                                Task: 'Unassigned Project',
                                WorkDate: '2026-11-03',
                                Minutes: 120,
                                IsBillable: true,
                                Notes: 'Work',
                            },
                        ],
                    });
                case 'MJ_BizApps_Tasks: Tasks':
                    return Promise.resolve({
                        Success: true,
                        Results: [{ ID: TASK_1_ID, Name: 'Unassigned Project', ParentID: null, RootParentID: null }],
                    });
                default:
                    return Promise.resolve({ Success: true, Results: [] });
            }
        });

        const { provider } = makeProvider();
        const op = new SubmitTimesheetOperationServer();
        const res = await op.Execute(
            { PeriodStart: '2026-11-02', PeriodEnd: '2026-11-08' },
            provider,
            makeUser(),
            dummyContext,
        );
        expect(res.Success).toBe(false);
        expect(res.Message).toContain('No approver for time on Unassigned Project');
    });

    it('SubmitTimesheet groups entries by project, creates TIMESHEET_APPROVAL task and part, and links entries', async () => {
        const entryEntity = {
            ID: ENTRY_1_ID,
            TaskID: TASK_1_ID,
            Task: 'Client Alpha',
            WorkDate: '2026-11-03',
            Minutes: 180,
            IsBillable: true,
            Notes: 'Workshop',
            TimesheetID: null as string | null,
            Save: vi.fn(async () => true),
        };

        runViewMock.mockImplementation((params: { EntityName: string }) => {
            switch (params.EntityName) {
                case 'MJ_BizApps_Tasks: Task Time Entries':
                    return Promise.resolve({ Success: true, Results: [entryEntity] });
                case 'MJ_BizApps_Tasks: Tasks':
                    return Promise.resolve({
                        Success: true,
                        Results: [{ ID: TASK_1_ID, Name: 'Client Alpha', ParentID: null, RootParentID: TASK_1_ID }],
                    });
                case 'MJ_BizApps_Tasks: Time Approvers':
                    return Promise.resolve({
                        Success: true,
                        Results: [
                            {
                                ID: 'rule-1',
                                ApproverPersonID: APPROVER_PERSON_ID,
                                ScopeTaskID: TASK_1_ID,
                                IncludeDescendants: true,
                                IsActive: true,
                            },
                        ],
                    });
                case 'MJ_BizApps_Tasks: Task Types':
                    return Promise.resolve({ Success: true, Results: [{ ID: TASK_TYPE_ID }] });
                case 'MJ_BizApps_Common: People':
                    return Promise.resolve({
                        Success: true,
                        Results: [{ ID: PERSON_ID, DisplayName: 'Alice Worker' }],
                    });
                default:
                    return Promise.resolve({ Success: true, Results: [] });
            }
        });

        const { provider, created } = makeProvider();
        const op = new SubmitTimesheetOperationServer();
        const res = await op.Execute(
            { PeriodStart: '2026-11-02', PeriodEnd: '2026-11-08', Notes: 'Week 45' },
            provider,
            makeUser(),
            dummyContext,
        );

        expect(res.Success).toBe(true);
        expect(res.Status).toBe('Submitted');
        expect(res.SubmissionRound).toBe(1);
        expect(res.TotalMinutes).toBe(180);
        expect(res.BillableMinutes).toBe(180);
        expect(res.Parts).toHaveLength(1);
        expect(res.Parts?.[0].ApproverPersonIDs).toEqual([APPROVER_PERSON_ID]);
        expect(res.Parts?.[0].CarriedForward).toBe(false);
        expect(entryEntity.Save).toHaveBeenCalledTimes(1);
        expect(entryEntity.TimesheetID).toBe(res.TimesheetID);

        const createdTask = created.find((c) => c.EntityName === 'MJ_BizApps_Tasks: Tasks');
        expect(createdTask?.Name).toContain('Timesheet: Alice Worker');
        const createdAsgn = created.find((c) => c.EntityName === 'MJ_BizApps_Tasks: Task Assignments');
        expect(createdAsgn?.AssigneeRecordID).toBe(APPROVER_PERSON_ID);
    });

    it('WithdrawTimesheet cancels Pending parts and their approval tasks and reverts status to Draft', async () => {
        const pendingPart = {
            ID: PART_1_ID,
            TimesheetID: TIMESHEET_ID,
            ApprovalTaskID: APPROVAL_TASK_ID,
            Status: 'Pending',
            DecidedAt: null as Date | null,
            DecisionNotes: null as string | null,
            Save: vi.fn(async () => true),
        };
        runViewMock.mockResolvedValue({ Success: true, Results: [pendingPart] });

        const { provider, created } = makeProvider({
            onCreateEntity: (entityName) => {
                const base: FakeEntityRecord = {
                    ID: entityName === 'MJ_BizApps_Tasks: Timesheets' ? TIMESHEET_ID : APPROVAL_TASK_ID,
                    EntityName: entityName,
                    PersonID: PERSON_ID,
                    Status: entityName === 'MJ_BizApps_Tasks: Timesheets' ? 'Submitted' : 'Open',
                    Notes: null,
                    SavedCount: 0,
                    DeletedCount: 0,
                    NewRecord: vi.fn(),
                    Load: vi.fn(async () => true),
                    Save: vi.fn(async () => {
                        base.SavedCount++;
                        return true;
                    }),
                    Delete: vi.fn(async () => true),
                };
                return base;
            },
        });

        const op = new WithdrawTimesheetOperationServer();
        const res = await op.Execute(
            { TimesheetID: TIMESHEET_ID, Reason: 'Forgot Friday hours' },
            provider,
            makeUser(),
            dummyContext,
        );

        expect(res.Success).toBe(true);
        expect(res.Status).toBe('Draft');
        expect(pendingPart.Status).toBe('Canceled');
        expect(pendingPart.Save).toHaveBeenCalledTimes(1);
        const approvalTask = created.find((c) => c.EntityName === 'MJ_BizApps_Tasks: Tasks');
        expect(approvalTask?.Status).toBe('Cancelled');
    });

    it('ReopenTimesheet enforces Manage Timesheets authorization and non-empty Reason, then reopens to Draft', async () => {
        runViewMock.mockResolvedValue({
            Success: true,
            Results: [{ ID: PART_1_ID, SubmissionRound: 1, ApprovalTaskID: APPROVAL_TASK_ID }],
        });

        const { provider, created } = makeProvider({
            onCreateEntity: (entityName) => {
                const base: FakeEntityRecord = {
                    ID: TIMESHEET_ID,
                    EntityName: entityName,
                    PersonID: PERSON_ID,
                    Status: 'Approved',
                    Notes: null,
                    SavedCount: 0,
                    DeletedCount: 0,
                    NewRecord: vi.fn(),
                    Load: vi.fn(async () => true),
                    Save: vi.fn(async () => {
                        base.SavedCount++;
                        return true;
                    }),
                    Delete: vi.fn(async () => true),
                };
                return base;
            },
        });

        const op = new ReopenTimesheetOperationServer();

        // Unauthorized caller
        const unauth = await op.Execute(
            { TimesheetID: TIMESHEET_ID, Reason: 'Billing adjustment' },
            provider,
            makeUser([]),
            dummyContext,
        );
        expect(unauth.Success).toBe(false);
        expect(unauth.Message).toContain('Manage Timesheets');

        // Authorized caller with empty reason
        const noReason = await op.Execute(
            { TimesheetID: TIMESHEET_ID, Reason: '   ' },
            provider,
            makeUser([MANAGE_TS_AUTH_ID]),
            dummyContext,
        );
        expect(noReason.Success).toBe(false);
        expect(noReason.Message).toContain('Reason');

        // Authorized caller with valid reason
        const ok = await op.Execute(
            { TimesheetID: TIMESHEET_ID, Reason: 'Adjusting Tuesday client hours' },
            provider,
            makeUser([MANAGE_TS_AUTH_ID]),
            dummyContext,
        );
        expect(ok.Success).toBe(true);
        expect(ok.Status).toBe('Draft');
        const activity = created.find((c) => c.EntityName === 'MJ_BizApps_Tasks: Task Activities');
        expect(activity?.Description).toContain('Adjusting Tuesday client hours');
    });
});
