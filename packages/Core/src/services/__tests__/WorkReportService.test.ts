import { describe, it, expect, beforeEach, vi } from 'vitest';
import { EntityInfo, RunView, UserInfo, type IMetadataProvider, type RunViewParams } from '@memberjunction/core';

const { runViewMock, getEntityObjectMock, logStatusMock, logErrorMock, MOCK_ENTITIES } = vi.hoisted(() => ({
    runViewMock: vi.fn(),
    getEntityObjectMock: vi.fn(),
    logStatusMock: vi.fn(),
    logErrorMock: vi.fn(),
    MOCK_ENTITIES: [
        { ID: '99999999-9999-4999-8999-999999999991', Name: 'MJ_BizApps_Tasks: Tasks', ParentChain: [] },
        { ID: '99999999-9999-4999-8999-999999999992', Name: 'MJ_BizApps_Common: People', ParentChain: [] },
        { ID: '99999999-9999-4999-8999-999999999993', Name: 'MJ: AI Agent Requests', ParentChain: [] },
        { ID: '99999999-9999-4999-8999-999999999994', Name: 'MJ: Field Suggestions', ParentChain: [] },
        { ID: 'a9038030-2dbd-48e1-9075-03ed5373b85a', Name: 'MJ_BizApps_Tasks: Work Reports', ParentChain: [] },
        { ID: 'd9e9ee62-78ce-4e89-8ed0-35378358e321', Name: 'MJ_BizApps_Tasks: Work Report Items', ParentChain: [] },
    ],
}));

vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    return {
        ...actual,
        RunView: class {
            RunView(params: RunViewParams, contextUser?: UserInfo) {
                return runViewMock(params, contextUser);
            }
        },
        LogStatus: (message: string) => logStatusMock(message),
        LogError: (message: string) => logErrorMock(message),
        Metadata: {
            Provider: {
                Entities: MOCK_ENTITIES,
                EntityByName: (name: string) => MOCK_ENTITIES.find((e) => e.Name === name),
                GetEntityObject: (entityName: string, contextUser?: UserInfo) => getEntityObjectMock(entityName, contextUser),
            },
        },
    };
});

import {
    BuildWorkReportMarkdown,
    BuildWorkReportsAgentContext,
    FilterWorkReports,
    GetLocalDayWindow,
    LoadPendingFieldSuggestionCountsForTasks,
    NormalizeReportPeriodWindow,
    WorkReportService,
    type WorkReportProvider,
    type WorkReportViewModel,
} from '../WorkReportService.js';

type FakeEntityValue = string | number | boolean | Date | null | undefined;
type FakeEntityState = Record<string, FakeEntityValue>;

function createFakeEntity(initial: FakeEntityState = {}) {
    const state: FakeEntityState = { ...initial };
    const target = {
        state,
        NewRecord: vi.fn(() => {
            if (!state['ID']) {
                state['ID'] = 'aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee';
            }
        }),
        Load: vi.fn(async (id: string) => {
            state['ID'] = id;
            return true;
        }),
        Save: vi.fn(async () => true),
        SetMany: vi.fn((vals: FakeEntityState) => {
            Object.assign(state, vals);
        }),
        PrimaryKey: {
            Values: () => [state['ID']],
        },
        LatestResult: { CompleteMessage: 'Mock validation error' },
    };

    return new Proxy(target, {
        get(obj, prop, receiver) {
            if (typeof prop === 'string' && prop in obj) {
                return Reflect.get(obj, prop, receiver);
            }
            if (typeof prop === 'string') {
                return state[prop];
            }
            return Reflect.get(obj, prop, receiver);
        },
        set(obj, prop, value: FakeEntityValue, receiver) {
            if (typeof prop === 'string' && !(prop in obj)) {
                state[prop] = value;
                return true;
            }
            return Reflect.set(obj, prop, value, receiver);
        },
    });
}

const TASKS_ENTITY_ID = '99999999-9999-4999-8999-999999999991';
const PEOPLE_ENTITY_ID = '99999999-9999-4999-8999-999999999992';
const PERSON_ALICE = '11111111-1111-4111-8111-111111111111';
const PERSON_BOB = '22222222-2222-4222-8222-222222222222';
const PERSON_CAROL = '33333333-3333-4333-8333-333333333333';
const USER_ALICE = 'aaaa1111-1111-4111-8111-111111111111';
const USER_BOB = 'bbbb2222-2222-4222-8222-222222222222';
const USER_CAROL = 'cccc3333-3333-4333-8333-333333333333';
const EMP_ALICE = 'eeee1111-1111-4111-8111-111111111111';
const EMP_BOB = 'eeee2222-2222-4222-8222-222222222222';
const REPORT_ID = '44444444-4444-4444-8444-444444444444';
const TASK_DONE = '55555555-5555-4555-8555-555555555551';
const TASK_ACTIVE = '55555555-5555-4555-8555-555555555552';
const TASK_BLOCKED = '55555555-5555-4555-8555-555555555553';
const AGENT_COS = '77777777-7777-4777-8777-777777777777';

function createFakeUser(id: string, email: string): UserInfo {
    const u = new UserInfo();
    u.ID = id;
    u.Email = email;
    return u;
}

const fakeProvider: WorkReportProvider = new Proxy(
    {
        Entities: MOCK_ENTITIES as ReadonlyArray<Pick<EntityInfo, 'ID' | 'Name'>>,
        EntityByName: (name: string) => MOCK_ENTITIES.find((e) => e.Name === name),
        GetEntityObject: (entityName: string, contextUser?: UserInfo) => getEntityObjectMock(entityName, contextUser),
        RunView: (params: RunViewParams, contextUser?: UserInfo) => runViewMock(params, contextUser),
        RunViews: vi.fn(),
    } as Partial<WorkReportProvider> as WorkReportProvider,
    {},
);

const aliceUser = createFakeUser(USER_ALICE, 'alice@example.com');
const bobUser = createFakeUser(USER_BOB, 'bob@example.com');
const carolUser = createFakeUser(USER_CAROL, 'carol@example.com');

beforeEach(() => {
    vi.clearAllMocks();
});

describe('WorkReportService', () => {
    it('exposes a BaseSingleton Instance', () => {
        expect(WorkReportService.Instance).toBeInstanceOf(WorkReportService);
        expect(WorkReportService.Instance).toBe(WorkReportService.Instance);
    });

    describe('ResolvePersonForUser', () => {
        it('resolves via LinkedEntityID + LinkedEntityRecordID when linked to People', async () => {
            const linkedUser = createFakeUser(USER_ALICE, 'alice@example.com');
            Object.assign(linkedUser as object, {
                LinkedEntityID: PEOPLE_ENTITY_ID,
                LinkedEntityRecordID: PERSON_ALICE,
            });

            runViewMock.mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: PERSON_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', LinkedUserID: USER_ALICE }],
            });

            const person = await WorkReportService.Instance.ResolvePersonForUser(linkedUser, fakeProvider);
            expect(person?.ID).toBe(PERSON_ALICE);
            expect(runViewMock.mock.calls[0][0]).toMatchObject({
                EntityName: 'MJ_BizApps_Common: People',
                ExtraFilter: `ID = '${PERSON_ALICE}' AND Status = 'Active'`,
            });
        });

        it('queries LinkedUserID when LinkedEntityID is absent', async () => {
            runViewMock.mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: PERSON_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', LinkedUserID: USER_ALICE }],
            });

            const person = await WorkReportService.Instance.ResolvePersonForUser(aliceUser, fakeProvider);
            expect(person?.ID).toBe(PERSON_ALICE);
            expect(runViewMock.mock.calls[0][0]).toMatchObject({
                ExtraFilter: `LinkedUserID = '${USER_ALICE}' AND Status = 'Active'`,
            });
        });

        it('throws when the underlying RunView fails instead of returning null silently', async () => {
            runViewMock.mockResolvedValueOnce({
                Success: false,
                ErrorMessage: 'Database connection lost',
            });

            await expect(
                WorkReportService.Instance.ResolvePersonForUser(aliceUser, fakeProvider),
            ).rejects.toThrow(/Database connection lost/);
        });
    });

    describe('ResolveSupervisorChainForPerson & ResolveDirectReportPersonIDs', () => {
        it('resolves supervisor UserID and PersonID through MJ: Employees.SupervisorID case-insensitive email matching', async () => {
            runViewMock
                // 1. Author Person
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'Alice@Example.com', LinkedUserID: USER_ALICE }],
                })
                // 2. Author Employee
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: EMP_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', SupervisorID: EMP_BOB, Active: 1 }],
                })
                // 3. Supervisor Employee
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: EMP_BOB, FirstName: 'Bob', LastName: 'Supervisor', Email: 'BOB@Example.com', Active: 1 }],
                })
                // 4. Supervisor User
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: USER_BOB, Name: 'Bob Supervisor', Email: 'bob@example.com' }],
                })
                // 5. Supervisor Person
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_BOB, FirstName: 'Bob', LastName: 'Supervisor', Email: 'bob@example.com', LinkedUserID: USER_BOB }],
                });

            const sup = await WorkReportService.Instance.ResolveSupervisorChainForPerson(
                PERSON_ALICE,
                aliceUser,
                fakeProvider,
            );

            expect(sup).toMatchObject({
                AuthorPersonID: PERSON_ALICE,
                EmployeeID: EMP_ALICE,
                SupervisorEmployeeID: EMP_BOB,
                SupervisorUserID: USER_BOB,
                SupervisorPersonID: PERSON_BOB,
                SupervisorName: 'Bob Supervisor',
            });
        });

        it('throws when any RunView in the supervisor chain fails instead of failing open as no-supervisor', async () => {
            runViewMock
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', LinkedUserID: USER_ALICE }],
                })
                .mockResolvedValueOnce({
                    Success: false,
                    ErrorMessage: 'MJ: Employees query timed out',
                });

            await expect(
                WorkReportService.Instance.ResolveSupervisorChainForPerson(PERSON_ALICE, aliceUser, fakeProvider),
            ).rejects.toThrow(/MJ: Employees query timed out/);
        });

        it('resolves direct report PersonIDs for a supervisor via MJ: Employees.SupervisorID', async () => {
            runViewMock
                // 1. Supervisor Person
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_BOB, Email: 'bob@example.com', LinkedUserID: USER_BOB }],
                })
                // 2. Supervisor Employee
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: EMP_BOB, Email: 'bob@example.com', Active: 1 }],
                })
                // 3. Direct report Employees
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: EMP_ALICE, Email: 'alice@example.com' }],
                })
                // 4. People by email
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_ALICE }],
                })
                // 5. Users by email
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [],
                });

            const directIDs = await WorkReportService.Instance.ResolveDirectReportPersonIDs(
                PERSON_BOB,
                bobUser,
                fakeProvider,
            );

            expect(directIDs).toEqual([PERSON_ALICE]);
        });
    });

    describe('GetPersonTaskActivityForWindow & DraftWorkReport', () => {
        it('returns SkippedNoActivity=true without persisting rows when zero tasks changed in the window', async () => {
            runViewMock
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_ALICE, Email: 'alice@example.com', LinkedUserID: USER_ALICE }],
                }) // caller Person resolution
                .mockResolvedValueOnce({ Success: true, Results: [] }) // assignments
                .mockResolvedValueOnce({ Success: true, Results: [] }); // tasks

            const outcome = await WorkReportService.Instance.DraftWorkReport({
                PersonID: PERSON_ALICE,
                PeriodStart: new Date('2026-11-09T00:00:00.000Z'),
                PeriodEnd: new Date('2026-11-09T23:59:59.000Z'),
                ContextUser: aliceUser,
                Provider: fakeProvider,
            });

            expect(outcome.SkippedNoActivity).toBe(true);
            expect(outcome.Report).toBeNull();
            expect(outcome.Items).toHaveLength(0);
            expect(getEntityObjectMock).not.toHaveBeenCalled();
        });

        it('refuses DraftWorkReport when caller resolves to a different Person than params.PersonID', async () => {
            runViewMock.mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: PERSON_ALICE, Email: 'alice@example.com', LinkedUserID: USER_ALICE }],
            });

            await expect(
                WorkReportService.Instance.DraftWorkReport({
                    PersonID: PERSON_BOB,
                    PeriodStart: new Date('2026-11-09T00:00:00.000Z'),
                    PeriodEnd: new Date('2026-11-09T23:59:59.000Z'),
                    ContextUser: aliceUser,
                    Provider: fakeProvider,
                }),
            ).rejects.toThrow(/Only the report author/);
        });

        it('creates a Draft WorkReport and section WorkReportItems when tasks changed in the window', async () => {
            runViewMock
                // 0. Caller Person resolution
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_ALICE, Email: 'alice@example.com', LinkedUserID: USER_ALICE }],
                })
                // 1. Assignments
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ TaskID: TASK_DONE }, { TaskID: TASK_ACTIVE }, { TaskID: TASK_BLOCKED }],
                })
                // 2. Scoped Tasks
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [
                        {
                            ID: TASK_DONE,
                            Name: 'Ship IS-A SubtypeSelector',
                            Status: 'Completed',
                            Priority: 'High',
                            PercentComplete: 100,
                            HoursActual: 3,
                            HealthStatus: 'OnTrack',
                            ParentID: null,
                            DueAt: null,
                            CompletedAt: '2026-11-09T14:00:00.000Z',
                            __mj_UpdatedAt: '2026-11-09T14:00:00.000Z',
                        },
                        {
                            ID: TASK_ACTIVE,
                            Name: 'Build 15Five Reports Resource',
                            Status: 'InProgress',
                            Priority: 'High',
                            PercentComplete: 75,
                            HoursActual: null,
                            HealthStatus: 'OnTrack',
                            ParentID: null,
                            DueAt: '2026-11-10T18:00:00.000Z',
                            CompletedAt: null,
                            __mj_UpdatedAt: '2026-11-09T15:00:00.000Z',
                        },
                        {
                            ID: TASK_BLOCKED,
                            Name: 'Provision GitHub Webhook Secret',
                            Status: 'Blocked',
                            Priority: 'Critical',
                            PercentComplete: 20,
                            HoursActual: null,
                            HealthStatus: 'AtRisk',
                            ParentID: null,
                            DueAt: null,
                            CompletedAt: null,
                            __mj_UpdatedAt: '2026-11-09T15:30:00.000Z',
                        },
                    ],
                })
                // 3. Check-ins
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ TaskID: TASK_ACTIVE, Summary: 'UI layout complete', __mj_CreatedAt: '2026-11-09T15:00:00.000Z' }],
                })
                // 4. Task activities
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [],
                })
                // 5. Existing WorkReport lookup
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [],
                });

            const createdReport = createFakeEntity({ ID: REPORT_ID });
            const createdItems = [
                createFakeEntity({ ID: '66666666-6666-4666-8666-666666666661' }),
                createFakeEntity({ ID: '66666666-6666-4666-8666-666666666662' }),
                createFakeEntity({ ID: '66666666-6666-4666-8666-666666666663' }),
                createFakeEntity({ ID: '66666666-6666-4666-8666-666666666664' }),
            ];
            let itemIdx = 0;
            getEntityObjectMock.mockImplementation(async (entityName: string) => {
                if (entityName === 'MJ_BizApps_Tasks: Work Reports') {
                    return createdReport;
                }
                const next = createdItems[itemIdx];
                itemIdx += 1;
                return next;
            });

            const outcome = await WorkReportService.Instance.DraftWorkReport({
                PersonID: PERSON_ALICE,
                PeriodStart: new Date('2026-11-09T00:00:00.000Z'),
                PeriodEnd: new Date('2026-11-09T23:59:59.000Z'),
                ContextUser: aliceUser,
                Provider: fakeProvider,
            });

            expect(outcome.SkippedNoActivity).toBe(false);
            expect(createdReport.state['Status']).toBe('Draft');
            expect(String(createdReport.state['Body'])).toContain('### Completed');
            expect(String(createdReport.state['Body'])).toContain('UI layout complete');
            expect(String(createdReport.state['Body'])).toContain('### Blockers');
            expect(outcome.Items).toHaveLength(4); // Completed, InProgress, Blockers, AtRisk
        });

        it('reuses and updates an existing Draft WorkReport for the same (PersonID, PeriodStart, PeriodEnd) instead of duplicating', async () => {
            runViewMock
                // 0. Caller Person resolution
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_ALICE, Email: 'alice@example.com', LinkedUserID: USER_ALICE }],
                })
                // 1. Assignments
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ TaskID: TASK_DONE }],
                })
                // 2. Scoped Tasks
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [
                        {
                            ID: TASK_DONE,
                            Name: 'Ship IS-A SubtypeSelector',
                            Status: 'Completed',
                            Priority: 'High',
                            PercentComplete: 100,
                            HoursActual: 3,
                            HealthStatus: 'OnTrack',
                            ParentID: null,
                            DueAt: null,
                            CompletedAt: '2026-11-09T14:00:00.000Z',
                            __mj_UpdatedAt: '2026-11-09T14:00:00.000Z',
                        },
                    ],
                })
                // 3. Check-ins
                .mockResolvedValueOnce({ Success: true, Results: [] })
                // 4. Activities
                .mockResolvedValueOnce({ Success: true, Results: [] })
                // 5. Existing WorkReport lookup -> returns existing Draft
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: REPORT_ID, Status: 'Draft' }],
                })
                // 6. Existing WorkReportItems lookup -> returns 1 existing item
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: '66666666-6666-4666-8666-666666666661', Sequence: 1 }],
                });

            const existingReport = createFakeEntity({
                ID: REPORT_ID,
                PersonID: PERSON_ALICE,
                PeriodStart: new Date('2026-11-09T00:00:00.000Z'),
                PeriodEnd: new Date('2026-11-09T23:59:59.000Z'),
                Status: 'Draft',
            });
            const existingItem = createFakeEntity({
                ID: '66666666-6666-4666-8666-666666666661',
                WorkReportID: REPORT_ID,
            });
            getEntityObjectMock.mockImplementation(async (entityName: string) =>
                entityName === 'MJ_BizApps_Tasks: Work Reports' ? existingReport : existingItem,
            );

            const outcome = await WorkReportService.Instance.DraftWorkReport({
                PersonID: PERSON_ALICE,
                PeriodStart: new Date('2026-11-09T00:00:00.000Z'),
                PeriodEnd: new Date('2026-11-09T23:59:59.000Z'),
                ContextUser: aliceUser,
                Provider: fakeProvider,
            });

            expect(outcome.Report?.ID).toBe(REPORT_ID);
            expect(existingReport.Load).toHaveBeenCalledWith(REPORT_ID);
            expect(existingReport.NewRecord).not.toHaveBeenCalled();
            expect(existingItem.Load).toHaveBeenCalledWith('66666666-6666-4666-8666-666666666661');
            expect(existingItem.NewRecord).not.toHaveBeenCalled();
        });

        it('includes tasks on the last day of a multi-day date-only range (2026-11-02..2026-11-06)', async () => {
            const normalized = NormalizeReportPeriodWindow(
                new Date('2026-11-02'),
                new Date('2026-11-06'),
            );
            expect(normalized.EndDate.toISOString()).toBe('2026-11-06T23:59:59.999Z');

            const localEvening = new Date(2026, 10, 9, 20, 30, 0); // Nov 9, 2026 8:30pm local time
            const localWin = GetLocalDayWindow(localEvening);
            expect(localWin.DateString).toBe('2026-11-09');
            expect(localWin.PeriodStart.getFullYear()).toBe(2026);
            expect(localWin.PeriodStart.getMonth()).toBe(10);
            expect(localWin.PeriodStart.getDate()).toBe(9);
        });
    });

    describe('SubmitWorkReport & RecordSupervisorReview', () => {
        it('submits an author-approved Draft report and creates an MJ: AI Agent Requests review request for the supervisor', async () => {
            const reportEntity = createFakeEntity({
                ID: REPORT_ID,
                PersonID: PERSON_ALICE,
                Status: 'Draft',
                Title: 'Daily 15Five — 2026-11-09',
                Body: '### Completed\n- **Shipped Work Bus**',
                PeriodStart: new Date('2026-11-09T00:00:00.000Z'),
                PeriodEnd: new Date('2026-11-09T23:59:59.000Z'),
            });
            const reqEntity = createFakeEntity({ ID: '88888888-8888-4888-8888-888888888888' });

            getEntityObjectMock.mockImplementation(async (entityName: string) => {
                if (entityName === 'MJ_BizApps_Tasks: Work Reports') {
                    return reportEntity;
                }
                if (entityName === 'MJ: AI Agent Requests') {
                    return reqEntity;
                }
                throw new Error(`Unexpected entity ${entityName}`);
            });

            runViewMock
                // Supervisor resolution (5 queries)
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', LinkedUserID: USER_ALICE }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: EMP_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', SupervisorID: EMP_BOB, Active: 1 }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: EMP_BOB, FirstName: 'Bob', LastName: 'Supervisor', Email: 'bob@example.com', Active: 1 }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: USER_BOB, Name: 'Bob Supervisor', Email: 'bob@example.com' }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_BOB, FirstName: 'Bob', LastName: 'Supervisor', Email: 'bob@example.com', LinkedUserID: USER_BOB }],
                })
                // Chief of Staff agent lookup
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: AGENT_COS }],
                });

            const outcome = await WorkReportService.Instance.SubmitWorkReport({
                WorkReportID: REPORT_ID,
                CallerPersonID: PERSON_ALICE,
                ContextUser: aliceUser,
                Provider: fakeProvider,
            });

            expect(reportEntity.state['Status']).toBe('Submitted');
            expect(outcome.SupervisorRequestID).toBe('88888888-8888-4888-8888-888888888888');
            expect(outcome.SupervisorNotified).toBe(true);
            expect(reqEntity.state['AgentID']).toBe(AGENT_COS);
            expect(reqEntity.state['RequestForUserID']).toBe(USER_BOB);
        });

        it('sets SupervisorNotified=false when the MJ: AI Agent Requests save fails even if SupervisorName is resolved', async () => {
            const reportEntity = createFakeEntity({
                ID: REPORT_ID,
                PersonID: PERSON_ALICE,
                Status: 'Draft',
                Title: 'Daily 15Five — 2026-11-09',
                Body: '### Completed\n- **Shipped Work Bus**',
                PeriodStart: new Date('2026-11-09T00:00:00.000Z'),
                PeriodEnd: new Date('2026-11-09T23:59:59.000Z'),
            });
            const reqEntity = createFakeEntity({ ID: '88888888-8888-4888-8888-888888888888' });
            reqEntity.Save.mockResolvedValueOnce(false);

            getEntityObjectMock.mockImplementation(async (entityName: string) =>
                entityName === 'MJ_BizApps_Tasks: Work Reports' ? reportEntity : reqEntity,
            );

            runViewMock
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', LinkedUserID: USER_ALICE }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: EMP_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', SupervisorID: EMP_BOB, Active: 1 }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: EMP_BOB, FirstName: 'Bob', LastName: 'Supervisor', Email: 'bob@example.com', Active: 1 }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: USER_BOB, Name: 'Bob Supervisor', Email: 'bob@example.com' }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_BOB, FirstName: 'Bob', LastName: 'Supervisor', Email: 'bob@example.com', LinkedUserID: USER_BOB }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: AGENT_COS }],
                });

            const outcome = await WorkReportService.Instance.SubmitWorkReport({
                WorkReportID: REPORT_ID,
                CallerPersonID: PERSON_ALICE,
                ContextUser: aliceUser,
                Provider: fakeProvider,
            });

            expect(outcome.Supervisor.SupervisorName).toBe('Bob Supervisor');
            expect(outcome.SupervisorRequestID).toBeNull();
            expect(outcome.SupervisorNotified).toBe(false);
            expect(logErrorMock).toHaveBeenCalled();
        });

        it('refuses SubmitWorkReport when CallerPersonID is omitted and user has no Person record', async () => {
            const reportEntity = createFakeEntity({
                ID: REPORT_ID,
                PersonID: PERSON_ALICE,
                Status: 'Draft',
            });
            getEntityObjectMock.mockResolvedValueOnce(reportEntity);

            runViewMock
                .mockResolvedValueOnce({ Success: true, Results: [] }) // by LinkedUserID
                .mockResolvedValueOnce({ Success: true, Results: [] }); // by Email

            await expect(
                WorkReportService.Instance.SubmitWorkReport({
                    WorkReportID: REPORT_ID,
                    ContextUser: carolUser,
                    Provider: fakeProvider,
                }),
            ).rejects.toThrow(/Caller could not be resolved to an active Person record/);
        });

        it('rejects RecordSupervisorReview when no supervisor is mapped in MJ: Employees (fails closed)', async () => {
            const reportEntity = createFakeEntity({
                ID: REPORT_ID,
                PersonID: PERSON_ALICE,
                Status: 'Submitted',
            });
            getEntityObjectMock.mockResolvedValueOnce(reportEntity);

            runViewMock
                // Author Person
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', LinkedUserID: USER_ALICE }],
                })
                // Author Employee with NO SupervisorID
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: EMP_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', SupervisorID: null, Active: 1 }],
                });

            await expect(
                WorkReportService.Instance.RecordSupervisorReview({
                    WorkReportID: REPORT_ID,
                    ReviewerPersonID: PERSON_CAROL,
                    SupervisorFeedback: 'Trying to review a peer with no supervisor',
                    ContextUser: carolUser,
                    Provider: fakeProvider,
                }),
            ).rejects.toThrow(/No mapped supervisor in MJ: Employees/);
        });

        it('rejects RecordSupervisorReview when caller is not the mapped supervisor in MJ: Employees', async () => {
            const reportEntity = createFakeEntity({
                ID: REPORT_ID,
                PersonID: PERSON_ALICE,
                Status: 'Submitted',
            });
            getEntityObjectMock.mockResolvedValueOnce(reportEntity);

            runViewMock
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', LinkedUserID: USER_ALICE }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: EMP_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', SupervisorID: EMP_BOB, Active: 1 }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: EMP_BOB, FirstName: 'Bob', LastName: 'Supervisor', Email: 'bob@example.com', Active: 1 }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: USER_BOB, Name: 'Bob Supervisor', Email: 'bob@example.com' }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_BOB, FirstName: 'Bob', LastName: 'Supervisor', Email: 'bob@example.com', LinkedUserID: USER_BOB }],
                });

            await expect(
                WorkReportService.Instance.RecordSupervisorReview({
                    WorkReportID: REPORT_ID,
                    ReviewerPersonID: PERSON_CAROL,
                    SupervisorFeedback: 'Looks good!',
                    ContextUser: bobUser,
                    Provider: fakeProvider,
                }),
            ).rejects.toThrow(/mapped supervisor/);
        });

        it('records supervisor review when ReviewerPersonID matches the mapped supervisor', async () => {
            const reportEntity = createFakeEntity({
                ID: REPORT_ID,
                PersonID: PERSON_ALICE,
                Status: 'Submitted',
            });
            getEntityObjectMock.mockResolvedValueOnce(reportEntity);

            runViewMock
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', LinkedUserID: USER_ALICE }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: EMP_ALICE, FirstName: 'Alice', LastName: 'Ng', Email: 'alice@example.com', SupervisorID: EMP_BOB, Active: 1 }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: EMP_BOB, FirstName: 'Bob', LastName: 'Supervisor', Email: 'bob@example.com', Active: 1 }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: USER_BOB, Name: 'Bob Supervisor', Email: 'bob@example.com' }],
                })
                .mockResolvedValueOnce({
                    Success: true,
                    Results: [{ ID: PERSON_BOB, FirstName: 'Bob', LastName: 'Supervisor', Email: 'bob@example.com', LinkedUserID: USER_BOB }],
                });

            const outcome = await WorkReportService.Instance.RecordSupervisorReview({
                WorkReportID: REPORT_ID,
                ReviewerPersonID: PERSON_BOB,
                SupervisorFeedback: 'Strong progress across all milestones!',
                ContextUser: bobUser,
                Provider: fakeProvider,
            });

            expect(outcome.Report.Status).toBe('Reviewed');
            expect(reportEntity.state['ReviewedByPersonID']).toBe(PERSON_BOB);
            expect(reportEntity.state['SupervisorFeedback']).toBe('Strong progress across all milestones!');
        });
    });

    describe('LoadPendingFieldSuggestionCountsForTasks & pure helpers', () => {
        it('aggregates pending MJ: Field Suggestions counts case-insensitively by task ID', async () => {
            runViewMock.mockResolvedValueOnce({
                Success: true,
                Results: [
                    { ID: 'fs-1', LinkedRecordID: TASK_DONE.toUpperCase() },
                    { ID: 'fs-2', LinkedRecordID: TASK_DONE.toLowerCase() },
                    { ID: 'fs-3', LinkedRecordID: TASK_BLOCKED },
                ],
            });

            const rv = new RunView();
            const counts = await LoadPendingFieldSuggestionCountsForTasks(
                rv,
                TASKS_ENTITY_ID,
                [TASK_DONE, TASK_ACTIVE, TASK_BLOCKED],
                aliceUser,
                fakeProvider,
            );

            expect(counts.get(TASK_DONE.toLowerCase())).toBe(2);
            expect(counts.get(TASK_BLOCKED.toLowerCase())).toBe(1);
            expect(counts.get(TASK_ACTIVE.toLowerCase())).toBeUndefined();
        });

        it('logs a clear message when MJ: Field Suggestions is absent on a pre-6.3 host', async () => {
            const pre63Provider: IMetadataProvider = {
                Entities: [{ ID: TASKS_ENTITY_ID, Name: 'MJ_BizApps_Tasks: Tasks' } as EntityInfo],
                EntityByName: () => undefined,
            } as Partial<IMetadataProvider> as IMetadataProvider;
            const rv = new RunView();

            const counts = await LoadPendingFieldSuggestionCountsForTasks(
                rv,
                TASKS_ENTITY_ID,
                [TASK_DONE],
                aliceUser,
                pre63Provider,
            );

            expect(counts.size).toBe(0);
            expect(logStatusMock).toHaveBeenCalledWith(
                expect.stringContaining('MJ: Field Suggestions'),
            );
        });

        it('filters WorkReportViewModels and builds a compact Chief of Staff agent context + markdown', () => {
            const sample: WorkReportViewModel[] = [
                {
                    ID: REPORT_ID,
                    PersonID: PERSON_ALICE,
                    PersonName: 'Alice Ng',
                    PeriodStart: '2026-11-03',
                    PeriodEnd: '2026-11-09',
                    Title: 'Weekly 15Five — Alice',
                    Body: '### Completed\n- **Work Bus**',
                    Status: 'Submitted',
                    SupervisorFeedback: null,
                    ReviewedByPersonID: null,
                    ReviewedByName: null,
                    ReviewedAt: null,
                    Items: [],
                },
            ];

            expect(FilterWorkReports(sample, 'Submitted', 'work bus')).toHaveLength(1);
            expect(FilterWorkReports(sample, 'Draft', '')).toHaveLength(0);

            const ctx = BuildWorkReportsAgentContext({
                ActiveTab: 'team',
                StatusFilter: 'all',
                SearchText: '',
                MyReports: [],
                TeamReports: sample,
                FilteredCount: 1,
                SelectedReportID: REPORT_ID,
            });
            expect(ctx['Surface']).toBe('ChiefOfStaffWorkReports');
            expect(ctx['TeamPendingReviewCount']).toBe(1);
            expect(ctx['SelectedReport']).toMatchObject({ ID: REPORT_ID, Status: 'Submitted' });

            const md = BuildWorkReportMarkdown({
                Completed: [],
                InProgress: [],
                Next: [],
                Blockers: [],
                AtRisk: [],
            });
            expect(md).toContain('No task updates recorded');
        });
    });
});
