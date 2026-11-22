import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import type { ActionParam, ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import type { UserInfo } from '@memberjunction/core';
import { TasksLimitsResolver } from '@mj-biz-apps/tasks-core';

interface RecordedRunViewCall {
    EntityName: string;
    MaxRows?: number;
}

const {
    checkEntityAccessMock,
    maskRowsMock,
    resolvePersonForUserMock,
    resolveDirectReportPersonIDsMock,
    runViewMock,
    recordedRunViews,
} = vi.hoisted(() => ({
    checkEntityAccessMock: vi.fn(),
    maskRowsMock: vi.fn(<T extends object>(rows: readonly T[]): T[] => [...rows]),
    resolvePersonForUserMock: vi.fn(),
    resolveDirectReportPersonIDsMock: vi.fn(),
    runViewMock: vi.fn(),
    recordedRunViews: [] as RecordedRunViewCall[],
}));

vi.mock('@memberjunction/actions-base', () => ({}));
vi.mock('@memberjunction/actions', () => ({ BaseAction: class {} }));
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
        LogError: vi.fn(),
        LogStatus: vi.fn(),
        Metadata: class {
            public static Provider = {
                Entities: [
                    { ID: 'e0000001-0000-4000-8000-000000000001', Name: 'MJ_BizApps_Common: People' },
                    { ID: 'e0000005-0000-4000-8000-000000000005', Name: 'MJ_BizApps_Tasks: Tasks' },
                    { ID: 'e0000006-0000-4000-8000-000000000006', Name: 'MJ_BizApps_Tasks: Work Reports' },
                    { ID: 'e0000007-0000-4000-8000-000000000007', Name: 'MJ_BizApps_Tasks: Meetings' },
                ],
                GetEntityObject: vi.fn(),
            };
            public Entities = [];
            public GetEntityObject = vi.fn();
            public SearchEntity = vi.fn();
        },
        RunView: class {
            public RunView = runViewMock;
        },
    };
});
vi.mock('@memberjunction/ai-core-plus', () => ({
    TypedActionPolicyGuard: {
        CheckEntityAccess: checkEntityAccessMock,
        MaskRecord: <T extends object>(rec: T): T => rec,
        MaskRows: maskRowsMock,
    },
}));
vi.mock('@memberjunction/ai-agents', () => ({
    AgentWakeTriggerService: {
        Instance: {
            TriggerWakeForWorkstream: vi.fn(),
        },
    },
}));
vi.mock('@memberjunction/generic-database-provider', () => ({
    UserCache: {
        Instance: {
            GetSystemUser: vi.fn(),
        },
    },
}));
vi.mock('@mj-biz-apps/common-entities', () => ({
    ResolveUserIDForPerson: vi.fn(),
}));
vi.mock('@mj-biz-apps/tasks-core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@mj-biz-apps/tasks-core')>();
    return {
        ...actual,
        WorkReportService: {
            Instance: {
                ResolvePersonForUser: resolvePersonForUserMock,
                ResolveDirectReportPersonIDs: resolveDirectReportPersonIDsMock,
            },
        },
    };
});

import { FindTasksAction, GetMyTasksBriefingAction } from '../custom/TaskTypedActions.js';
import { GetMyWorkReportsBriefingAction, ListWorkReportsAction } from '../custom/WorkReportActions.js';
import { GetMyMeetingsBriefingAction } from '../custom/MeetingTypedActions.js';

class TestableFindTasksAction extends FindTasksAction {
    public Run(params: RunActionParams): Promise<ActionResultSimple> {
        return this.InternalRunAction(params);
    }
}

class TestableGetMyTasksBriefingAction extends GetMyTasksBriefingAction {
    public Run(params: RunActionParams): Promise<ActionResultSimple> {
        return this.InternalRunAction(params);
    }
}

class TestableListWorkReportsAction extends ListWorkReportsAction {
    public Run(params: RunActionParams): Promise<ActionResultSimple> {
        return this.InternalRunAction(params);
    }
}

class TestableGetMyWorkReportsBriefingAction extends GetMyWorkReportsBriefingAction {
    public Run(params: RunActionParams): Promise<ActionResultSimple> {
        return this.InternalRunAction(params);
    }
}

class TestableGetMyMeetingsBriefingAction extends GetMyMeetingsBriefingAction {
    public Run(params: RunActionParams): Promise<ActionResultSimple> {
        return this.InternalRunAction(params);
    }
}

const USER_ID = '10000000-0000-4000-8000-000000000001';
const PERSON_ID = '20000000-0000-4000-8000-000000000002';

function makeUser(): UserInfo {
    return {
        ID: USER_ID,
        Name: 'Test User',
        Email: 'test@example.com',
        UserRoles: [],
    } as UserInfo;
}

function makeParams(entries: Array<{ Name: string; Value: ActionParam['Value'] }> = []): RunActionParams {
    const paramsList: ActionParam[] = entries.map((e) => ({
        Name: e.Name,
        Value: e.Value,
        Type: 'Input',
    }));
    return {
        ContextUser: makeUser(),
        Action: { ID: 'act-1', Name: 'TestAction' } as RunActionParams['Action'],
        Params: paramsList,
        Filters: [],
    };
}

describe('Actions Limits Resolution (@mj-biz-apps/tasks-actions)', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        recordedRunViews.length = 0;
        TasksLimitsResolver.Instance.ClearConfigOverrides();
        TasksLimitsResolver.Instance.InvalidateCache();

        checkEntityAccessMock.mockResolvedValue({
            Allowed: true,
            MaskedFields: [],
            RowFilter: null,
        });
        resolvePersonForUserMock.mockResolvedValue({
            ID: PERSON_ID,
            FirstName: 'Pat',
            LastName: 'Doe',
            Email: 'pat@example.com',
            LinkedUserID: USER_ID,
        });
        resolveDirectReportPersonIDsMock.mockResolvedValue([]);

        runViewMock.mockImplementation(async (params: { EntityName: string; MaxRows?: number }) => {
            recordedRunViews.push({ EntityName: params.EntityName, MaxRows: params.MaxRows });
            if (params.EntityName === 'MJ_BizApps_Common: People') {
                return {
                    Success: true,
                    Results: [{ ID: PERSON_ID, FirstName: 'Pat', LastName: 'Doe', Email: 'pat@example.com' }],
                };
            }
            return { Success: true, Results: [] };
        });
    });

    afterEach(() => {
        TasksLimitsResolver.Instance.ClearConfigOverrides();
        TasksLimitsResolver.Instance.InvalidateCache();
    });

    it('routes FindTasksAction default MaxRows and ceiling through TasksLimitsResolver', async () => {
        TasksLimitsResolver.Instance.RegisterConfigOverrides({
            ResourceGuards: {
                FindTasksDefaultMaxRows: 11,
                FindTasksMaxRowsCeiling: 19,
            },
        });

        const action = new TestableFindTasksAction();
        await action.Run(makeParams([{ Name: 'Scope', Value: 'Team' }]));
        const firstTaskQuery = recordedRunViews.find((c) => c.EntityName === 'MJ_BizApps_Tasks: Tasks');
        expect(firstTaskQuery?.MaxRows).toBe(11);

        recordedRunViews.length = 0;
        await action.Run(
            makeParams([
                { Name: 'Scope', Value: 'Team' },
                { Name: 'MaxRows', Value: 999 },
            ]),
        );
        const clampedTaskQuery = recordedRunViews.find((c) => c.EntityName === 'MJ_BizApps_Tasks: Tasks');
        expect(clampedTaskQuery?.MaxRows).toBe(19);
    });

    it('routes ListWorkReportsAction limit defaults and ceilings through TasksLimitsResolver', async () => {
        TasksLimitsResolver.Instance.RegisterConfigOverrides({
            ResourceGuards: {
                FindWorkReportsDefaultMaxRows: 7,
                FindWorkReportsMaxRowsCeiling: 13,
            },
        });

        const action = new TestableListWorkReportsAction();
        await action.Run(makeParams([{ Name: 'Scope', Value: 'Mine' }]));
        expect(recordedRunViews.find((c) => c.EntityName === 'MJ_BizApps_Tasks: Work Reports')?.MaxRows).toBe(7);

        recordedRunViews.length = 0;
        await action.Run(
            makeParams([
                { Name: 'Scope', Value: 'Mine' },
                { Name: 'Limit', Value: 500 },
            ]),
        );
        expect(recordedRunViews.find((c) => c.EntityName === 'MJ_BizApps_Tasks: Work Reports')?.MaxRows).toBe(13);
    });

    it('honors BriefingLimitsHelper bounds and BriefingTasksMaxRows in GetMyTasksBriefingAction', async () => {
        TasksLimitsResolver.Instance.RegisterConfigOverrides({
            ResourceGuards: {
                BriefingTasksMaxRows: 42,
            },
            Briefing: {
                DefaultBriefingHorizonDays: 9,
                DefaultBriefingMaxItems: 6,
            },
            RunawayGuards: {
                BriefingMaxHorizonDays: 15,
                BriefingMaxItemsCeiling: 8,
            },
        });

        const runParams = makeParams([{ Name: 'HorizonDays', Value: 500 }]);
        const action = new TestableGetMyTasksBriefingAction();
        const result = await action.Run(runParams);
        expect(result.Success).toBe(true);

        const taskViews = recordedRunViews.filter((c) => c.EntityName === 'MJ_BizApps_Tasks: Tasks');
        expect(taskViews.length).toBeGreaterThan(0);
        for (const call of taskViews) {
            expect(call.MaxRows).toBe(42);
        }

        const rawBriefing = runParams.Params.find((p) => p.Name === 'Briefing')?.Value;
        const payload = JSON.parse(typeof rawBriefing === 'string' ? rawBriefing : '{}') as {
            HorizonDays?: number;
        };
        expect(payload.HorizonDays).toBe(15);
    });

    it('honors Briefing WorkReports and Meetings lookback/horizon bounds in briefing actions', async () => {
        TasksLimitsResolver.Instance.RegisterConfigOverrides({
            ResourceGuards: {
                BroadEntityQueryMaxRows: 88,
                WorkflowBatchMaxRows: 33,
            },
            Briefing: {
                DefaultWorkReportsBriefingLookbackDays: 19,
                DefaultMeetingsBriefingLookbackDays: 6,
                DefaultBriefingHorizonDays: 11,
                DefaultBriefingMaxItems: 5,
            },
            RunawayGuards: {
                BriefingWorkReportsMaxLookbackDays: 25,
                BriefingMaxLookbackDays: 10,
                BriefingMaxHorizonDays: 14,
                BriefingMaxItemsCeiling: 9,
            },
        });

        const reportsParams = makeParams([{ Name: 'LookbackDays', Value: 999 }]);
        const reportsAction = new TestableGetMyWorkReportsBriefingAction();
        const reportsResult = await reportsAction.Run(reportsParams);
        expect(reportsResult.Success).toBe(true);
        const rawReportsBriefing = reportsParams.Params.find((p) => p.Name === 'Briefing')?.Value;
        const reportsPayload = JSON.parse(typeof rawReportsBriefing === 'string' ? rawReportsBriefing : '{}') as {
            LookbackDays?: number;
        };
        expect(reportsPayload.LookbackDays).toBe(25);
        expect(recordedRunViews.find((c) => c.EntityName === 'MJ_BizApps_Tasks: Work Reports')?.MaxRows).toBe(10);

        recordedRunViews.length = 0;
        const meetingsParams = makeParams();
        const meetingsAction = new TestableGetMyMeetingsBriefingAction();
        const meetingsResult = await meetingsAction.Run(meetingsParams);
        expect(meetingsResult.Success).toBe(true);
        expect(
            recordedRunViews.find((c) => c.EntityName === 'MJ_BizApps_Tasks: Meeting Attendees')?.MaxRows,
        ).toBe(88);
        const rawMeetingsBriefing = meetingsParams.Params.find((p) => p.Name === 'Briefing')?.Value;
        const meetingsPayload = JSON.parse(typeof rawMeetingsBriefing === 'string' ? rawMeetingsBriefing : '{}') as {
            HorizonDays?: number;
            LookbackDays?: number;
        };
        expect(meetingsPayload.HorizonDays).toBe(11);
        expect(meetingsPayload.LookbackDays).toBe(6);
    });

    it('bounds delegated task assignment lookup with LargeTreeQueryMaxRows in GetMyTasksBriefingAction', async () => {
        TasksLimitsResolver.Instance.RegisterConfigOverrides({
            ResourceGuards: {
                LargeTreeQueryMaxRows: 333,
            },
        });

        runViewMock.mockImplementation(async (params: { EntityName: string; MaxRows?: number }) => {
            recordedRunViews.push({ EntityName: params.EntityName, MaxRows: params.MaxRows });
            if (params.EntityName === 'MJ_BizApps_Common: People') {
                return {
                    Success: true,
                    Results: [{ ID: PERSON_ID, FirstName: 'Pat', LastName: 'Doe', Email: 'pat@example.com' }],
                };
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                return {
                    Success: true,
                    Results: [
                        {
                            ID: '30000000-0000-4000-8000-000000000003',
                            Name: 'Delegated Task',
                            Status: 'In Progress',
                            Priority: 'Normal',
                            DueAt: null,
                            PercentComplete: 0,
                            TypeID: '40000000-0000-4000-8000-000000000004',
                            Type: 'Standard',
                            Category: null,
                            OrganizationID: null,
                            Organization: null,
                            ParentID: null,
                            BlockedReason: null,
                            HealthStatus: 'On Track',
                            CreatedByPersonID: PERSON_ID,
                        },
                    ],
                };
            }
            return { Success: true, Results: [] };
        });

        const action = new TestableGetMyTasksBriefingAction();
        const result = await action.Run(makeParams());
        expect(result.Success).toBe(true);

        const taskAssignmentQueries = recordedRunViews.filter(
            (c) => c.EntityName === 'MJ_BizApps_Tasks: Task Assignments',
        );
        expect(taskAssignmentQueries.some((c) => c.MaxRows === 333)).toBe(true);
    });

    it('enforces Briefing.ContributorTimeoutMs across GetMyTasksBriefingAction, GetMyMeetingsBriefingAction, and GetMyWorkReportsBriefingAction', async () => {
        TasksLimitsResolver.Instance.RegisterConfigOverrides({
            Briefing: {
                ContributorTimeoutMs: 100,
            },
        });

        runViewMock.mockImplementation(async (params: { EntityName: string; MaxRows?: number }) => {
            recordedRunViews.push({ EntityName: params.EntityName, MaxRows: params.MaxRows });
            if (params.EntityName === 'MJ_BizApps_Common: People') {
                return {
                    Success: true,
                    Results: [{ ID: PERSON_ID, FirstName: 'Pat', LastName: 'Doe', Email: 'pat@example.com' }],
                };
            }
            await new Promise((resolve) => setTimeout(resolve, 250));
            return { Success: true, Results: [] };
        });

        const tasksRes = await new TestableGetMyTasksBriefingAction().Run(makeParams());
        expect(tasksRes.Success).toBe(false);
        expect(tasksRes.ResultCode).toBe('ERROR');
        expect(tasksRes.Message).toMatch(/GetMyTasksBriefingAction timed out after 100ms/);

        const meetingsRes = await new TestableGetMyMeetingsBriefingAction().Run(makeParams());
        expect(meetingsRes.Success).toBe(false);
        expect(meetingsRes.ResultCode).toBe('ERROR');
        expect(meetingsRes.Message).toMatch(/GetMyMeetingsBriefingAction timed out after 100ms/);

        const workReportsRes = await new TestableGetMyWorkReportsBriefingAction().Run(makeParams());
        expect(workReportsRes.Success).toBe(false);
        expect(workReportsRes.ResultCode).toBe('ERROR');
        expect(workReportsRes.Message).toMatch(/GetMyWorkReportsBriefingAction timed out after 100ms/);
    });
});
