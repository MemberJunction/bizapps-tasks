import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { UserInfo } from '@memberjunction/core';
import {
    WorkReportRefusal,
    WorkReportRowFilterForUser,
    type WorkReportAuthorityFacts,
    type WorkReportStatus,
} from '../WorkReportAuthority.js';

const PEOPLE_ENTITY_ID = 'A0000000-0000-0000-0000-000000000001';
const REPORT_ID = 'D0000000-0000-0000-0000-000000000001';
const USER_ALICE = 'B0000000-0000-0000-0000-000000000001';
const USER_BOB = 'B0000000-0000-0000-0000-000000000002';
const USER_CAROL = 'B0000000-0000-0000-0000-000000000003';
const PERSON_ALICE = 'C0000000-0000-0000-0000-000000000001';
const PERSON_BOB = 'C0000000-0000-0000-0000-000000000002';
const PERSON_CAROL = 'C0000000-0000-0000-0000-000000000003';

const mockState = vi.hoisted(() => ({
    callerPersonID: 'C0000000-0000-0000-0000-000000000001' as string | null,
    supervisorPersonID: 'C0000000-0000-0000-0000-000000000002' as string | null,
    failPersonLookup: false,
    failSupervisorLookup: false,
}));

vi.mock('@memberjunction/core', () => {
    class ValidationResult {
        Success = true;
        Errors: Array<{ Source: string; Message: string }> = [];
    }
    class ValidationErrorInfo {
        constructor(
            public Source: string,
            public Message: string,
            public Value: string | null,
        ) {}
    }
    const provider = {
        EntityByID: (id: string) =>
            id === PEOPLE_ENTITY_ID ? { Name: 'MJ_BizApps_Common: People', ParentChain: [] } : null,
        EntityByName: (name: string) =>
            name === 'MJ_BizApps_Common: People' ? { ID: PEOPLE_ENTITY_ID, Name: name } : null,
    };
    return {
        BaseEntity: class {},
        LogError: vi.fn(),
        Metadata: { Provider: provider },
        RunView: class {
            async RunView() {
                if (mockState.failPersonLookup) {
                    return { Success: false, Results: [], ErrorMessage: 'People lookup failed' };
                }
                return {
                    Success: true,
                    Results: mockState.callerPersonID ? [{ ID: mockState.callerPersonID }] : [],
                };
            }
        },
        ValidationResult,
        ValidationErrorInfo,
    };
});

vi.mock('@mj-biz-apps/tasks-core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@mj-biz-apps/tasks-core')>();
    return {
        ...actual,
        WorkReportService: {
            Instance: {
                ResolvePersonForUser: vi.fn(async () => {
                    if (mockState.failPersonLookup) {
                        throw new Error('People lookup failed');
                    }
                    return mockState.callerPersonID
                        ? {
                              ID: mockState.callerPersonID,
                              FirstName: 'Mock',
                              LastName: 'User',
                              Email: 'mock@example.com',
                              LinkedUserID: USER_ALICE,
                              SupervisorPersonID: mockState.supervisorPersonID,
                              Status: 'Active',
                          }
                        : null;
                }),
                ResolveSupervisorChainForPerson: vi.fn(async () => {
                    if (mockState.failSupervisorLookup) {
                        throw new Error('Supervisor chain lookup failed');
                    }
                    return {
                        PersonID: PERSON_ALICE,
                        PersonName: 'Alice Ng',
                        PersonEmail: 'alice@example.com',
                        SupervisorPersonID: mockState.supervisorPersonID,
                        SupervisorUserID: mockState.supervisorPersonID ? USER_BOB : null,
                        SupervisorEmployeeID: null,
                        SupervisorName: mockState.supervisorPersonID ? 'Bob Supervisor' : null,
                        SupervisorEmail: mockState.supervisorPersonID ? 'bob@example.com' : null,
                        Source: mockState.supervisorPersonID ? 'People.SupervisorPersonID' : 'None',
                    };
                }),
            },
        },
    };
});

interface MockFieldState {
    Dirty: boolean;
    OldValue: string | null;
}

vi.mock('@mj-biz-apps/tasks-entities', () => ({
    mjBizAppsTasksWorkReportEntity: class {
        ID = REPORT_ID;
        PersonID = PERSON_ALICE;
        PeriodStart = new Date('2026-11-02T00:00:00.000Z');
        PeriodEnd = new Date('2026-11-06T23:59:59.999Z');
        Title = 'Weekly 15Five';
        Body = '### Completed\n- **Shipped Work Bus**';
        Status: WorkReportStatus = 'Draft';
        SupervisorFeedback: string | null = null;
        ReviewedByPersonID: string | null = null;
        ReviewedAt: Date | null = null;
        IsSaved = false;
        ProviderToUse = undefined;
        RunViewProviderToUse = {};
        ContextCurrentUser: UserInfo | null = {
            ID: USER_ALICE,
            Email: 'alice@example.com',
            UserRoles: [],
        } as Partial<UserInfo> as UserInfo;
        fieldStates = new Map<string, MockFieldState>();
        GetFieldByName(name: string): MockFieldState | undefined {
            return this.fieldStates.get(name);
        }
        async ValidateAsync() {
            return { Success: true, Errors: [] as Array<{ Source: string; Message: string }> };
        }
    },
}));

const { WorkReportEntityServer, LoadWorkReportEntityServer } = await import('../WorkReportEntityServer.js');

function baseFacts(overrides: Partial<WorkReportAuthorityFacts> = {}): WorkReportAuthorityFacts {
    return {
        IsSaved: false,
        CallerUserID: USER_ALICE,
        CallerPersonIDs: [PERSON_ALICE],
        CallerIsPrivileged: false,
        PersonID: PERSON_ALICE,
        PriorPersonID: null,
        Status: 'Draft',
        PriorStatus: null,
        SupervisorFeedback: null,
        ReviewedByPersonID: null,
        ReviewedAt: null,
        AuthorContentDirty: false,
        ResolvedSupervisorPersonID: null,
        ...overrides,
    };
}

describe('WorkReportAuthority.WorkReportRefusal (pure state machine)', () => {
    it('allows the author to create a new Draft report without review fields', () => {
        expect(WorkReportRefusal(baseFacts())).toBeNull();
    });

    it('refuses creating a report when no signed-in user or Person resolves', () => {
        expect(WorkReportRefusal(baseFacts({ CallerUserID: null }))).toMatch(/signed-in user/i);
        expect(WorkReportRefusal(baseFacts({ CallerPersonIDs: [] }))).toMatch(/could not be resolved/i);
    });

    it('refuses creating a report for another person unless caller is privileged', () => {
        expect(
            WorkReportRefusal(baseFacts({ CallerPersonIDs: [PERSON_BOB], PersonID: PERSON_ALICE })),
        ).toMatch(/Only the report author/i);
        expect(
            WorkReportRefusal(
                baseFacts({
                    CallerPersonIDs: [PERSON_BOB],
                    CallerIsPrivileged: true,
                    PersonID: PERSON_ALICE,
                }),
            ),
        ).toBeNull();
    });

    it('refuses creating a new report directly in Submitted or Reviewed status or with review fields', () => {
        expect(WorkReportRefusal(baseFacts({ Status: 'Submitted' }))).toMatch(/must start in 'Draft'/i);
        expect(WorkReportRefusal(baseFacts({ Status: 'Reviewed' }))).toMatch(/must start in 'Draft'/i);
        expect(
            WorkReportRefusal(baseFacts({ Status: 'Draft', SupervisorFeedback: 'Pre-filled' })),
        ).toMatch(/cannot include supervisor review fields/i);
    });

    it('allows the author to edit a Draft or transition Draft -> Submitted, and refuses non-authors', () => {
        expect(
            WorkReportRefusal(
                baseFacts({
                    IsSaved: true,
                    PriorPersonID: PERSON_ALICE,
                    PriorStatus: 'Draft',
                    Status: 'Draft',
                }),
            ),
        ).toBeNull();

        expect(
            WorkReportRefusal(
                baseFacts({
                    IsSaved: true,
                    PriorPersonID: PERSON_ALICE,
                    PriorStatus: 'Draft',
                    Status: 'Submitted',
                }),
            ),
        ).toBeNull();

        expect(
            WorkReportRefusal(
                baseFacts({
                    IsSaved: true,
                    CallerPersonIDs: [PERSON_BOB],
                    PriorPersonID: PERSON_ALICE,
                    PriorStatus: 'Draft',
                    Status: 'Submitted',
                }),
            ),
        ).toMatch(/Only the report author may submit/i);
    });

    it('refuses jumping directly from Draft -> Reviewed', () => {
        expect(
            WorkReportRefusal(
                baseFacts({
                    IsSaved: true,
                    PriorPersonID: PERSON_ALICE,
                    PriorStatus: 'Draft',
                    Status: 'Reviewed',
                    SupervisorFeedback: 'Skipping submit',
                }),
            ),
        ).toMatch(/must be Submitted before it can be Reviewed/i);
    });

    it('refuses Submitted -> Reviewed by the author (self-review), when no supervisor resolves, or by a non-supervisor', () => {
        // Self-review
        expect(
            WorkReportRefusal(
                baseFacts({
                    IsSaved: true,
                    CallerPersonIDs: [PERSON_ALICE],
                    PriorPersonID: PERSON_ALICE,
                    PriorStatus: 'Submitted',
                    Status: 'Reviewed',
                    SupervisorFeedback: 'Self review',
                    ResolvedSupervisorPersonID: PERSON_ALICE,
                }),
            ),
        ).toMatch(/cannot review their own/i);

        // Fail closed when no supervisor resolves
        expect(
            WorkReportRefusal(
                baseFacts({
                    IsSaved: true,
                    CallerUserID: USER_BOB,
                    CallerPersonIDs: [PERSON_BOB],
                    PriorPersonID: PERSON_ALICE,
                    PriorStatus: 'Submitted',
                    Status: 'Reviewed',
                    SupervisorFeedback: 'Looks good',
                    ResolvedSupervisorPersonID: null,
                }),
            ),
        ).toMatch(/No supervisor could be resolved/i);

        // Non-supervisor colleague Carol
        expect(
            WorkReportRefusal(
                baseFacts({
                    IsSaved: true,
                    CallerUserID: USER_CAROL,
                    CallerPersonIDs: [PERSON_CAROL],
                    PriorPersonID: PERSON_ALICE,
                    PriorStatus: 'Submitted',
                    Status: 'Reviewed',
                    SupervisorFeedback: 'Carol attempting review',
                    ResolvedSupervisorPersonID: PERSON_BOB,
                }),
            ),
        ).toMatch(/Only the resolved supervisor/i);
    });

    it('allows Submitted -> Reviewed by the resolved supervisor with feedback, and refuses modifying author content during review', () => {
        expect(
            WorkReportRefusal(
                baseFacts({
                    IsSaved: true,
                    CallerUserID: USER_BOB,
                    CallerPersonIDs: [PERSON_BOB],
                    PriorPersonID: PERSON_ALICE,
                    PriorStatus: 'Submitted',
                    Status: 'Reviewed',
                    SupervisorFeedback: 'Great week!',
                    ReviewedByPersonID: PERSON_BOB,
                    ReviewedAt: new Date(),
                    ResolvedSupervisorPersonID: PERSON_BOB,
                }),
            ),
        ).toBeNull();

        expect(
            WorkReportRefusal(
                baseFacts({
                    IsSaved: true,
                    CallerUserID: USER_BOB,
                    CallerPersonIDs: [PERSON_BOB],
                    PriorPersonID: PERSON_ALICE,
                    PriorStatus: 'Submitted',
                    Status: 'Reviewed',
                    SupervisorFeedback: 'Great week!',
                    AuthorContentDirty: true,
                    ResolvedSupervisorPersonID: PERSON_BOB,
                }),
            ),
        ).toMatch(/Author report fields.*cannot be modified/i);
    });

    it('locks Reviewed reports against further edits by non-privileged users', () => {
        expect(
            WorkReportRefusal(
                baseFacts({
                    IsSaved: true,
                    CallerUserID: USER_BOB,
                    CallerPersonIDs: [PERSON_BOB],
                    PriorPersonID: PERSON_ALICE,
                    PriorStatus: 'Reviewed',
                    Status: 'Reviewed',
                    SupervisorFeedback: 'Changed feedback',
                }),
            ),
        ).toMatch(/Reviewed Work Reports are locked/i);
    });
});

describe('WorkReportRowFilterForUser', () => {
    it('returns 1 = 0 for missing user, 1 = 1 for privileged Owner, and author/supervisor SQL for standard users', () => {
        expect(WorkReportRowFilterForUser({ ID: 'not-a-uuid' } as Partial<UserInfo> as UserInfo)).toBe('1 = 0');
        expect(
            WorkReportRowFilterForUser({
                ID: USER_ALICE,
                UserRoles: [{ Role: 'Owner' }],
            } as Partial<UserInfo> as UserInfo),
        ).toBe('1 = 1');

        const filter = WorkReportRowFilterForUser({
            ID: USER_ALICE,
            UserRoles: [{ Role: 'UI' }],
        } as Partial<UserInfo> as UserInfo);
        expect(filter).toContain(USER_ALICE);
        expect(filter).toContain('[SupervisorPersonID]');
    });
});

describe('WorkReportEntityServer.ValidateAsync', () => {
    beforeEach(() => {
        mockState.callerPersonID = PERSON_ALICE;
        mockState.supervisorPersonID = PERSON_BOB;
        mockState.failPersonLookup = false;
        mockState.failSupervisorLookup = false;
    });

    it('registers and opts in to async validation', () => {
        LoadWorkReportEntityServer();
        const entity = new WorkReportEntityServer();
        expect(entity.DefaultSkipAsyncValidation).toBe(false);
    });

    it('passes ValidateAsync when the author creates a Draft or transitions Draft -> Submitted', async () => {
        const entity = new WorkReportEntityServer();
        const draftRes = await entity.ValidateAsync();
        expect(draftRes.Success).toBe(true);

        entity.IsSaved = true;
        entity.Status = 'Submitted';
        entity.fieldStates.set('Status', { Dirty: true, OldValue: 'Draft' });
        const submitRes = await entity.ValidateAsync();
        expect(submitRes.Success).toBe(true);
    });

    it('fails ValidateAsync when the resolved supervisor reviews a Submitted report if supervisor lookup throws (fail closed)', async () => {
        mockState.callerPersonID = PERSON_BOB;
        mockState.failSupervisorLookup = true;

        const entity = new WorkReportEntityServer();
        entity.IsSaved = true;
        entity.ContextCurrentUser = {
            ID: USER_BOB,
            Email: 'bob@example.com',
            UserRoles: [],
        } as Partial<UserInfo> as UserInfo;
        entity.Status = 'Reviewed';
        entity.SupervisorFeedback = 'Reviewed!';
        entity.ReviewedByPersonID = PERSON_BOB;
        entity.fieldStates.set('Status', { Dirty: true, OldValue: 'Submitted' });

        const res = await entity.ValidateAsync();
        expect(res.Success).toBe(false);
        expect(res.Errors[0]?.Message).toMatch(/Supervisor chain lookup failed/i);
    });

    it('passes ValidateAsync when the resolved supervisor reviews a Submitted report', async () => {
        mockState.callerPersonID = PERSON_BOB;
        mockState.supervisorPersonID = PERSON_BOB;

        const entity = new WorkReportEntityServer();
        entity.IsSaved = true;
        entity.ContextCurrentUser = {
            ID: USER_BOB,
            Email: 'bob@example.com',
            UserRoles: [],
        } as Partial<UserInfo> as UserInfo;
        entity.Status = 'Reviewed';
        entity.SupervisorFeedback = 'Well done on the release.';
        entity.ReviewedByPersonID = PERSON_BOB;
        entity.ReviewedAt = new Date();
        entity.fieldStates.set('Status', { Dirty: true, OldValue: 'Submitted' });

        const res = await entity.ValidateAsync();
        expect(res.Success).toBe(true);
    });
});
