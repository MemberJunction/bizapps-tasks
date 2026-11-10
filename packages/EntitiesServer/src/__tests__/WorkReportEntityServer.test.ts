import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { UserInfo } from '@memberjunction/core';
import {
    WorkReportDeleteRefusal,
    WorkReportItemRefusal,
    WorkReportRefusal,
    type WorkReportAuthorityFacts,
    type WorkReportStatus,
} from '../WorkReportAuthority.js';

const PEOPLE_ENTITY_ID = 'A0000000-0000-0000-0000-000000000001';
const REPORT_ID = 'D0000000-0000-0000-0000-000000000001';
const OTHER_REPORT_ID = 'D0000000-0000-0000-0000-000000000002';
const ITEM_ID = 'E0000000-0000-0000-0000-000000000001';
const TASK_TYPE_ID = 'F0000000-0000-0000-0000-000000000001';
const USER_ALICE = 'B0000000-0000-0000-0000-000000000001';
const USER_BOB = 'B0000000-0000-0000-0000-000000000002';
const USER_CAROL = 'B0000000-0000-0000-0000-000000000003';
const PERSON_ALICE = 'C0000000-0000-0000-0000-000000000001';
const PERSON_BOB = 'C0000000-0000-0000-0000-000000000002';
const PERSON_CAROL = 'C0000000-0000-0000-0000-000000000003';
const PERSON_SKIP_LEVEL = 'C0000000-0000-0000-0000-000000000004';

const mockState = vi.hoisted(() => ({
    callerPersonID: 'C0000000-0000-0000-0000-000000000001' as string | null,
    supervisorPersonID: 'C0000000-0000-0000-0000-000000000002' as string | null,
    supervisorChainPersonIDs: ['C0000000-0000-0000-0000-000000000002'] as string[],
    failPersonLookup: false,
    failSupervisorLookup: false,
    parentReportRows: [
        {
            ID: 'D0000000-0000-0000-0000-000000000001',
            PersonID: 'C0000000-0000-0000-0000-000000000001',
            Status: 'Draft' as WorkReportStatus,
        },
    ],
    failParentReportLookup: false,
    taskTypeReferencingTaskIDs: [] as Array<{ ID: string }>,
    failTaskTypeLookup: false,
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
    class BaseEntityResult {
        Complete = false;
        Errors: Array<{ Source: string; Message: string }> = [];
        MessageIncludesErrors = false;
        StartedAt = new Date();
        EndedAt = new Date();
        constructor(
            public Success: boolean = false,
            public Message: string = '',
            public Type: 'create' | 'update' | 'delete' = 'update',
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
        BaseEntityResult,
        LogError: vi.fn(),
        Metadata: { Provider: provider },
        RunView: class {
            async RunView(params: { EntityName: string }) {
                if (params.EntityName === 'MJ_BizApps_Tasks: Work Reports') {
                    if (mockState.failParentReportLookup) {
                        return { Success: false, Results: [], ErrorMessage: 'Parent report lookup failed' };
                    }
                    return { Success: true, Results: mockState.parentReportRows };
                }
                if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                    if (mockState.failTaskTypeLookup) {
                        return { Success: false, Results: [], ErrorMessage: 'Tasks lookup failed' };
                    }
                    return { Success: true, Results: mockState.taskTypeReferencingTaskIDs };
                }
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
                        SupervisorChainPersonIDs: mockState.supervisorChainPersonIDs,
                        SupervisorChainUserIDs: mockState.supervisorPersonID ? [USER_BOB] : [],
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

class MockEntityBase {
    IsSaved = false;
    ProviderToUse = undefined;
    RunViewProviderToUse = {};
    ContextCurrentUser: UserInfo | null = {
        ID: USER_ALICE,
        Email: 'alice@example.com',
        UserRoles: [],
    } as Partial<UserInfo> as UserInfo;
    ResultHistory: Array<{
        Success: boolean;
        Type: 'create' | 'update' | 'delete';
        Message: string;
        Complete: boolean;
        StartedAt: Date;
        EndedAt: Date;
    }> = [];
    fieldStates = new Map<string, MockFieldState>();
    GetFieldByName(name: string): MockFieldState | undefined {
        return this.fieldStates.get(name);
    }
    async ValidateAsync() {
        return { Success: true, Errors: [] as Array<{ Source: string; Message: string }> };
    }
    async Save(): Promise<boolean> {
        return true;
    }
    async Delete(): Promise<boolean> {
        return true;
    }
}

vi.mock('@mj-biz-apps/tasks-entities', () => ({
    mjBizAppsTasksWorkReportEntity: class extends MockEntityBase {
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
    },
    mjBizAppsTasksWorkReportItemEntity: class extends MockEntityBase {
        ID = ITEM_ID;
        WorkReportID = REPORT_ID;
    },
    mjBizAppsTasksTaskTypeEntity: class extends MockEntityBase {
        ID = TASK_TYPE_ID;
        Name = 'PR Review';
        ExtensionEntity: string | null = 'MJ_BizApps_Tasks_GitHub: PR Tasks';
    },
}));

const { WorkReportEntityServer, LoadWorkReportEntityServer } = await import('../WorkReportEntityServer.js');
const { WorkReportItemEntityServer, LoadWorkReportItemEntityServer } = await import(
    '../WorkReportItemEntityServer.js'
);
const { TaskTypeEntityServer, LoadTaskTypeEntityServer } = await import('../TaskTypeEntityServer.js');

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

    it('allows Submitted -> Reviewed by a direct or skip-level supervisor in ResolvedSupervisorPersonIDs, and refuses modifying author content during review', () => {
        expect(
            WorkReportRefusal(
                baseFacts({
                    IsSaved: true,
                    CallerUserID: USER_BOB,
                    CallerPersonIDs: [PERSON_SKIP_LEVEL],
                    PriorPersonID: PERSON_ALICE,
                    PriorStatus: 'Submitted',
                    Status: 'Reviewed',
                    SupervisorFeedback: 'Great week!',
                    ReviewedByPersonID: PERSON_SKIP_LEVEL,
                    ReviewedAt: new Date(),
                    ResolvedSupervisorPersonID: PERSON_BOB,
                    ResolvedSupervisorPersonIDs: [PERSON_BOB, PERSON_SKIP_LEVEL],
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

describe('WorkReportAuthority.WorkReportDeleteRefusal & WorkReportItemRefusal', () => {
    it('allows only the author of a Draft report (or a privileged admin) to delete a Work Report', () => {
        expect(
            WorkReportDeleteRefusal({
                CallerUserID: USER_ALICE,
                CallerPersonIDs: [PERSON_ALICE],
                CallerIsPrivileged: false,
                PersonID: PERSON_ALICE,
                Status: 'Draft',
            }),
        ).toBeNull();

        expect(
            WorkReportDeleteRefusal({
                CallerUserID: USER_ALICE,
                CallerPersonIDs: [PERSON_ALICE],
                CallerIsPrivileged: false,
                PersonID: PERSON_ALICE,
                Status: 'Submitted',
            }),
        ).toMatch(/Cannot delete a 'Submitted' Work Report/i);

        expect(
            WorkReportDeleteRefusal({
                CallerUserID: USER_BOB,
                CallerPersonIDs: [PERSON_BOB],
                CallerIsPrivileged: false,
                PersonID: PERSON_ALICE,
                Status: 'Draft',
            }),
        ).toMatch(/Only the report author.*may delete/i);

        expect(
            WorkReportDeleteRefusal({
                CallerUserID: USER_BOB,
                CallerPersonIDs: [PERSON_BOB],
                CallerIsPrivileged: true,
                PersonID: PERSON_ALICE,
                Status: 'Reviewed',
            }),
        ).toBeNull();
    });

    it('allows WorkReportItem changes only by the Draft report author (or privileged admin) and refuses WorkReportID re-parenting', () => {
        expect(
            WorkReportItemRefusal({
                Operation: 'create',
                CallerUserID: USER_ALICE,
                CallerPersonIDs: [PERSON_ALICE],
                CallerIsPrivileged: false,
                WorkReportID: REPORT_ID,
                PriorWorkReportID: null,
                ParentReportExists: true,
                ParentReportPersonID: PERSON_ALICE,
                ParentReportStatus: 'Draft',
            }),
        ).toBeNull();

        expect(
            WorkReportItemRefusal({
                Operation: 'update',
                CallerUserID: USER_ALICE,
                CallerPersonIDs: [PERSON_ALICE],
                CallerIsPrivileged: false,
                WorkReportID: REPORT_ID,
                PriorWorkReportID: REPORT_ID,
                ParentReportExists: true,
                ParentReportPersonID: PERSON_ALICE,
                ParentReportStatus: 'Submitted',
            }),
        ).toMatch(/Cannot update items on a 'Submitted' Work Report/i);

        expect(
            WorkReportItemRefusal({
                Operation: 'update',
                CallerUserID: USER_BOB,
                CallerPersonIDs: [PERSON_BOB],
                CallerIsPrivileged: false,
                WorkReportID: REPORT_ID,
                PriorWorkReportID: REPORT_ID,
                ParentReportExists: true,
                ParentReportPersonID: PERSON_ALICE,
                ParentReportStatus: 'Draft',
            }),
        ).toMatch(/Only the Work Report author may update/i);

        expect(
            WorkReportItemRefusal({
                Operation: 'update',
                CallerUserID: USER_ALICE,
                CallerPersonIDs: [PERSON_ALICE],
                CallerIsPrivileged: false,
                WorkReportID: OTHER_REPORT_ID,
                PriorWorkReportID: REPORT_ID,
                ParentReportExists: true,
                ParentReportPersonID: PERSON_ALICE,
                ParentReportStatus: 'Draft',
            }),
        ).toMatch(/WorkReportID of an existing Work Report Item cannot be changed/i);
    });
});

describe('WorkReportEntityServer', () => {
    beforeEach(() => {
        mockState.callerPersonID = PERSON_ALICE;
        mockState.supervisorPersonID = PERSON_BOB;
        mockState.supervisorChainPersonIDs = [PERSON_BOB];
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

    it('stamps ReviewedByPersonID and ReviewedAt on Submitted -> Reviewed during Save() when omitted by raw entity CRUD', async () => {
        mockState.callerPersonID = PERSON_BOB;
        mockState.supervisorPersonID = PERSON_BOB;
        mockState.supervisorChainPersonIDs = [PERSON_BOB];

        const entity = new WorkReportEntityServer();
        entity.IsSaved = true;
        entity.ContextCurrentUser = {
            ID: USER_BOB,
            Email: 'bob@example.com',
            UserRoles: [],
        } as Partial<UserInfo> as UserInfo;
        entity.Status = 'Reviewed';
        entity.SupervisorFeedback = 'Well done on the release.';
        entity.ReviewedByPersonID = null;
        entity.ReviewedAt = null;
        entity.fieldStates.set('Status', { Dirty: true, OldValue: 'Submitted' });

        const saved = await entity.Save();
        expect(saved).toBe(true);
        expect(entity.ReviewedByPersonID).toBe(PERSON_BOB);
        expect(entity.ReviewedAt).toBeInstanceOf(Date);
    });

    it('guards Delete() so only the author of a Draft report (or a privileged admin) can delete, recording refusal in ResultHistory', async () => {
        const entity = new WorkReportEntityServer();
        entity.IsSaved = true;
        entity.Status = 'Submitted';
        entity.fieldStates.set('Status', { Dirty: false, OldValue: 'Submitted' });

        const deletedSubmitted = await entity.Delete();
        expect(deletedSubmitted).toBe(false);
        expect(entity.ResultHistory.at(-1)?.Message).toMatch(/Cannot delete a 'Submitted' Work Report/i);

        entity.Status = 'Draft';
        entity.fieldStates.set('Status', { Dirty: false, OldValue: 'Draft' });
        const deletedDraft = await entity.Delete();
        expect(deletedDraft).toBe(true);
    });
});

describe('WorkReportItemEntityServer', () => {
    beforeEach(() => {
        mockState.callerPersonID = PERSON_ALICE;
        mockState.failPersonLookup = false;
        mockState.failParentReportLookup = false;
        mockState.parentReportRows = [
            {
                ID: REPORT_ID,
                PersonID: PERSON_ALICE,
                Status: 'Draft',
            },
        ];
    });

    it('allows the Draft author to validate and delete items, and refuses once the parent report is Submitted or when caller is not the author', async () => {
        LoadWorkReportItemEntityServer();
        const item = new WorkReportItemEntityServer();
        expect(item.DefaultSkipAsyncValidation).toBe(false);

        const draftValid = await item.ValidateAsync();
        expect(draftValid.Success).toBe(true);

        // Lock once parent report is Submitted
        mockState.parentReportRows = [
            {
                ID: REPORT_ID,
                PersonID: PERSON_ALICE,
                Status: 'Submitted',
            },
        ];
        const submittedValid = await item.ValidateAsync();
        expect(submittedValid.Success).toBe(false);
        expect(submittedValid.Errors[0]?.Message).toMatch(/Cannot create items on a 'Submitted' Work Report/i);

        const submittedDelete = await item.Delete();
        expect(submittedDelete).toBe(false);
        expect(item.ResultHistory.at(-1)?.Message).toMatch(/Cannot delete items on a 'Submitted' Work Report/i);

        // Refuse supervisor / non-author even on a Draft report
        mockState.parentReportRows = [
            {
                ID: REPORT_ID,
                PersonID: PERSON_ALICE,
                Status: 'Draft',
            },
        ];
        mockState.callerPersonID = PERSON_BOB;
        item.ContextCurrentUser = {
            ID: USER_BOB,
            Email: 'bob@example.com',
            UserRoles: [],
        } as Partial<UserInfo> as UserInfo;
        const bobValid = await item.ValidateAsync();
        expect(bobValid.Success).toBe(false);
        expect(bobValid.Errors[0]?.Message).toMatch(/Only the Work Report author/i);

        // Refuse re-parenting WorkReportID on a saved item
        mockState.callerPersonID = PERSON_ALICE;
        item.ContextCurrentUser = {
            ID: USER_ALICE,
            Email: 'alice@example.com',
            UserRoles: [],
        } as Partial<UserInfo> as UserInfo;
        item.IsSaved = true;
        item.WorkReportID = OTHER_REPORT_ID;
        item.fieldStates.set('WorkReportID', { Dirty: true, OldValue: REPORT_ID });
        mockState.parentReportRows = [
            {
                ID: OTHER_REPORT_ID,
                PersonID: PERSON_ALICE,
                Status: 'Draft',
            },
        ];
        const reparentValid = await item.ValidateAsync();
        expect(reparentValid.Success).toBe(false);
        expect(reparentValid.Errors[0]?.Message).toMatch(/WorkReportID of an existing Work Report Item cannot be changed/i);
    });
});

describe('TaskTypeEntityServer', () => {
    beforeEach(() => {
        mockState.taskTypeReferencingTaskIDs = [];
        mockState.failTaskTypeLookup = false;
    });

    it('refuses changing ExtensionEntity on a saved TaskType when Tasks reference that TypeID, and allows when no Tasks exist', async () => {
        LoadTaskTypeEntityServer();
        const taskType = new TaskTypeEntityServer();
        expect(taskType.DefaultSkipAsyncValidation).toBe(false);

        taskType.IsSaved = true;
        taskType.ExtensionEntity = 'MJ_BizApps_Tasks_Design: Design Tasks';
        taskType.fieldStates.set('ExtensionEntity', {
            Dirty: true,
            OldValue: 'MJ_BizApps_Tasks_GitHub: PR Tasks',
        });

        // No tasks reference this TaskType -> allowed
        const emptyValid = await taskType.ValidateAsync();
        expect(emptyValid.Success).toBe(true);

        // Tasks reference this TaskType -> refused
        mockState.taskTypeReferencingTaskIDs = [{ ID: '11111111-1111-1111-1111-111111111111' }];
        const inUseValid = await taskType.ValidateAsync();
        expect(inUseValid.Success).toBe(false);
        expect(inUseValid.Errors[0]?.Message).toMatch(/Cannot change ExtensionEntity on TaskType/i);

        // Lookup failure -> fail closed
        mockState.failTaskTypeLookup = true;
        const failClosedValid = await taskType.ValidateAsync();
        expect(failClosedValid.Success).toBe(false);
        expect(failClosedValid.Errors[0]?.Message).toMatch(/existing Task usage could not be verified/i);
    });
});
