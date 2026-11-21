/**
 * TaskEntityServer approval and creator rules (bizapps-tasks#209): an approval task closes through a
 * decision or a withdrawal, never through a bare status change by someone with no standing; it
 * cannot be turned into an ordinary task; and a task is created as its creator, not as someone else.
 *
 * The fake BaseEntity runs validation inside Save the way the real one does, so each test drives
 * the path a browser's save takes: Save → status sync → ValidateAsync → write.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

const PEOPLE_ID = 'A0000000-0000-0000-0000-000000000001';
const USERS_ID = 'A0000000-0000-0000-0000-000000000002';
const ROLES_ID = 'A0000000-0000-0000-0000-000000000003';
const APP_ID = 'A0000000-0000-0000-0000-0000000000AA';
const USER_ID = 'B0000000-0000-0000-0000-000000000001';
const MY_PERSON = 'C0000000-0000-0000-0000-000000000001';
const REQUESTER = 'C0000000-0000-0000-0000-000000000002';
const APPROVER = 'C0000000-0000-0000-0000-000000000003';
const TASK_ID = 'D0000000-0000-0000-0000-000000000001';
const APPROVAL_TYPE = 'E0000000-0000-0000-0000-000000000001';
const TIMESHEET_TYPE = 'E0000000-0000-0000-0000-000000000002';
const ORDINARY_TYPE = 'E0000000-0000-0000-0000-000000000003';
const APPROVED = 'F0000000-0000-0000-0000-000000000001';
const REJECTED = 'F0000000-0000-0000-0000-000000000002';
const NEEDS_INFO = 'F0000000-0000-0000-0000-000000000003';
const DONE_STAGE = 'F1000000-0000-0000-0000-000000000001';
const QUEUE_ROLE = 'A1000000-0000-0000-0000-000000000001';

const {
    COMPLETE_WITHOUT_DECISION_REFUSAL,
    WITHDRAW_REFUSAL,
    WITHDRAW_NO_USER_REFUSAL,
    APPROVAL_TYPE_CHANGE_REFUSAL,
    CREATOR_NOT_SELF_REFUSAL,
    CREATOR_AFTER_CREATE_REFUSAL,
} = await import('../ApprovalTaskAuthority.js');

type AssignmentRow = { ID: string; AssigneeEntityID: string; AssigneeRecordID: string; Status: string };

/** What the fake database returns, per entity. */
const db = {
    settings: new Map<string, string>(),
    people: [{ ID: MY_PERSON }] as Array<{ ID: string }>,
    userRoles: [] as Array<{ RoleID: string; Role: string }>,
    assignments: [] as AssignmentRow[],
    /** The outcome of the latest decision recorded on the task, or null when it has none. */
    latestOutcomeID: null as string | null,
    systemUser: false,
    fail: null as string | null,
};
const filtersSeen: string[] = [];
const written = vi.fn(async () => true);
const applyTimesheetOutcome = vi.hoisted(() => vi.fn(async () => ({ Applied: true })));

const TYPES = [
    { ID: APPROVAL_TYPE, IsApproval: true, Code: 'APPROVAL_REQUEST' },
    { ID: TIMESHEET_TYPE, IsApproval: true, Code: 'TIMESHEET_APPROVAL' },
    { ID: ORDINARY_TYPE, IsApproval: false, Code: 'GENERAL' },
];
const OUTCOMES = [
    { ID: APPROVED, Code: 'Approved' },
    { ID: REJECTED, Code: 'Rejected' },
    { ID: NEEDS_INFO, Code: 'NeedsInfo' },
];

function viewResult(entityName: string, filter: string): { Success: boolean; Results: unknown[]; ErrorMessage?: string } {
    filtersSeen.push(`${entityName}: ${filter}`);
    if (db.fail === entityName) return { Success: false, Results: [], ErrorMessage: 'database unavailable' };
    const mentioned = <T extends { ID: string }>(rows: T[]): T[] => rows.filter((r) => filter.toUpperCase().includes(r.ID));
    switch (entityName) {
        case 'MJ_BizApps_Common: People': return { Success: true, Results: db.people };
        case 'MJ_BizApps_Tasks: Task Types': return { Success: true, Results: mentioned(TYPES) };
        case 'MJ_BizApps_Tasks: Task Decisions': return { Success: true, Results: db.latestOutcomeID ? [{ ID: 'decision-1', OutcomeID: db.latestOutcomeID }] : [] };
        case 'MJ_BizApps_Tasks: Task Decision Outcomes': return { Success: true, Results: mentioned(OUTCOMES) };
        case 'MJ_BizApps_Tasks: Task Assignments': return { Success: true, Results: db.assignments };
        case 'MJ: User Roles': return { Success: true, Results: db.userRoles };
        case 'MJ: Roles': return { Success: true, Results: [{ Name: 'Finance Admin' }] };
        default: return { Success: true, Results: [] };
    }
}

vi.mock('@memberjunction/global', async (importOriginal) => ({
    ...(await importOriginal<typeof import('@memberjunction/global')>()),
    RegisterClass: () => () => {},
}));

vi.mock('@memberjunction/core-entities', async (importOriginal) => ({
    ...(await importOriginal<typeof import('@memberjunction/core-entities')>()),
    ApplicationSettingEngine: {
        Instance: {
            Config: vi.fn(async () => undefined),
            GetSetting: (name: string, appID?: string) => (appID === APP_ID ? db.settings.get(name) : undefined),
        },
    },
}));

vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    class ValidationErrorInfo { constructor(public Source: string, public Message: string, public Value: unknown, public Type?: string) {} }
    /** The records TaskEntityServer loads by ID while saving: a stage, or the task's type. */
    const loadable = (entityName?: string) => ({
        NewRecord: vi.fn(),
        Save: vi.fn().mockResolvedValue(true),
        MacroStatus: 'Completed',
        IsTerminal: true,
        Code: null as string | null,
        async Load(id: string) {
            if (entityName === 'MJ_BizApps_Tasks: Task Types') this.Code = TYPES.find((t) => t.ID === id)?.Code ?? null;
            return true;
        },
    });
    const provider = {
        Applications: [{ Name: 'Tasks', ID: APP_ID }],
        EntityByID: (id: string) => (id === PEOPLE_ID ? { Name: 'MJ_BizApps_Common: People', ParentChain: [] } : null),
        EntityByName: (name: string) => (name === 'MJ: Users' ? { ID: USERS_ID } : name === 'MJ: Roles' ? { ID: ROLES_ID } : null),
        GetEntityObject: async (entityName?: string) => loadable(entityName),
        RunView: async () => ({ Success: true, Results: [] }),
    };
    type Refusal = { Message: string };
    return {
        ...actual,
        BaseEntity: class {
            public ContextCurrentUser: { ID: string; UserRoles?: Array<{ RoleID: string }> } | null = { ID: USER_ID };
            public Fields: Array<{ CodeName: string; Dirty: boolean; Value: unknown; OldValue: unknown }> = [];
            public IsSaved = false;
            public TransactionGroup: unknown = null;
            public ProviderToUse = provider;
            public RunViewProviderToUse = {};
            public LatestResult: { CompleteMessage: string } | null = null;
            private _fieldValues: Record<string, unknown> = {};
            public DeclareRelatedRecords() { return { Items: [] as unknown[] }; }
            public Get(fieldName: string) { return this._fieldValues[fieldName]; }
            public Set(fieldName: string, value: unknown) { this._fieldValues[fieldName] = value; }
            public GetAll() { return { ...this._fieldValues }; }
            public RegisterEventHandler() {}
            public Validate() { return { Success: true, Errors: [] as Refusal[] }; }
            public async ValidateAsync() { return { Success: true, Errors: [] as Refusal[] }; }
            /** As BaseEntity.Save: both validations, then the write only when they pass. */
            public async Save() {
                const sync = this.Validate();
                const asyncResult = await this.ValidateAsync();
                const errors = [...sync.Errors, ...asyncResult.Errors];
                if (errors.length > 0) {
                    this.LatestResult = { CompleteMessage: errors.map((e) => e.Message).join(' ') };
                    return false;
                }
                return written();
            }
        },
        BaseEngine: class { public static getInstance() { return {}; } },
        BaseRemotableOperation: class {},
        CompositeKey: class { constructor(public KeyValuePairs: unknown[]) {} },
        LogError: vi.fn(),
        LogStatus: vi.fn(),
        Metadata: class {
            public static Provider = provider;
            public async GetEntityObject(entityName?: string) { return loadable(entityName); }
        },
        RunView: class {
            public async RunView(p: { EntityName: string; ExtraFilter?: string }) {
                return viewResult(p.EntityName, p.ExtraFilter ?? '');
            }
        },
        UserInfo: class {},
        ValidationErrorInfo,
        ValidationErrorType: { Failure: 'Failure', Warning: 'Warning' },
        WellKnownUserSource: { Instance: { IsSystemUser: () => db.systemUser } },
    };
});

vi.mock('@memberjunction/actions', () => ({
    ActionEngineServer: { Instance: { Config: vi.fn().mockResolvedValue(undefined), Actions: [], RunAction: vi.fn() } },
}));

vi.mock('@mj-biz-apps/tasks-core', async () => ({
    ...(await vi.importActual<typeof import('@mj-biz-apps/tasks-core')>('@mj-biz-apps/tasks-core')),
    TaskService: class { public async rollupParentProgress() { return true; } },
}));

vi.mock('../TimesheetApprovalOutcome.js', () => ({
    ApplyTimesheetApprovalOutcomeForTask: applyTimesheetOutcome,
    TIMESHEET_APPROVAL_TASK_TYPE_CODE: 'TIMESHEET_APPROVAL',
}));

const { TaskEntityServer } = await import('../TaskEntityServer.js');

type Server = InstanceType<typeof TaskEntityServer>;
type Status = Server['Status'];
type PendingDecision = { IsSaved: boolean; OutcomeID: string };

/** Marks a field changed, the way a setter on a loaded record would. */
function change(t: Server, codeName: string, oldValue: unknown, value: unknown): void {
    t.Fields = [...t.Fields.filter((f) => f.CodeName !== codeName), { CodeName: codeName, Dirty: oldValue !== value, Value: value, OldValue: oldValue }];
}

/** A saved, open approval task that `REQUESTER` asked for, assigned to `APPROVER`. */
function approvalTask(typeID = APPROVAL_TYPE): Server {
    const t = new TaskEntityServer();
    t.ID = TASK_ID;
    t.Name = 'Approve access override';
    t.TypeID = typeID;
    t.Status = 'Open';
    t.CreatedByPersonID = REQUESTER;
    t.IsSaved = true;
    return t;
}

/** Moves a saved task to `status`, as a status dropdown or a kanban drop does. */
function moveTo(t: Server, status: Status): Server {
    change(t, 'Status', t.Status, status);
    t.Status = status;
    return t;
}

/** Adds a decision that is saved in the same unit of work as the task, as `RecordDecision` does. */
function decideWith(t: Server, outcomeID: string): void {
    const items = t.Decisions.Items as unknown as PendingDecision[];
    items.push({ IsSaved: false, OutcomeID: outcomeID });
}

const assignment = (recordID: string, status = 'Pending', entityID = PEOPLE_ID): AssignmentRow =>
    ({ ID: `assignment-${recordID}`, AssigneeEntityID: entityID, AssigneeRecordID: recordID, Status: status });

async function refusalOf(t: Server): Promise<string> {
    expect(await t.Save()).toBe(false);
    expect(written).not.toHaveBeenCalled();
    return t.LatestResult?.CompleteMessage ?? '';
}

beforeEach(() => {
    db.settings = new Map();
    db.people = [{ ID: MY_PERSON }];
    db.userRoles = [];
    db.assignments = [assignment(APPROVER)];
    db.latestOutcomeID = null;
    db.systemUser = false;
    db.fail = null;
    filtersSeen.length = 0;
    written.mockClear();
    applyTimesheetOutcome.mockClear();
});

describe('TaskEntityServer — an approval task is completed by a decision, or by someone who could decide it', () => {
    it('refuses a user with no standing completing an approval task, and writes nothing', async () => {
        expect(await refusalOf(moveTo(approvalTask(), 'Completed'))).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);
    });

    it('refuses it whatever PreventSelfApproval says: the setting opens decisions, not the status', async () => {
        db.settings.set('PreventSelfApproval', 'false');
        expect(await refusalOf(moveTo(approvalTask(), 'Completed'))).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);
    });

    it('refuses the requester, also when they are an assignee of their own request', async () => {
        const own = approvalTask();
        own.CreatedByPersonID = MY_PERSON;
        expect(await refusalOf(moveTo(own, 'Completed'))).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);

        written.mockClear();
        db.assignments = [assignment(MY_PERSON)];
        const selfAssigned = approvalTask();
        selfAssigned.CreatedByPersonID = MY_PERSON;
        expect(await refusalOf(moveTo(selfAssigned, 'Completed'))).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);
    });

    it('refuses an assignee whose assignment is already completed', async () => {
        db.assignments = [assignment(MY_PERSON, 'Completed')];
        expect(await refusalOf(moveTo(approvalTask(), 'Completed'))).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);
    });

    it('refuses it for the system user and for server code that may withdraw', async () => {
        db.systemUser = true;
        expect(await refusalOf(moveTo(approvalTask(), 'Completed'))).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);

        db.systemUser = false;
        const t = moveTo(approvalTask(), 'Completed');
        t.AuthorizeApprovalWithdrawal();
        expect(await refusalOf(t)).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);
    });

    it('lets an active assignee who did not ask for it complete it: as a Person, a user, or a role queue', async () => {
        const cases: Array<{ rows: AssignmentRow[]; roles?: Array<{ RoleID: string; Role: string }> }> = [
            { rows: [assignment(MY_PERSON, 'InProgress')] },
            { rows: [assignment(USER_ID, 'Pending', USERS_ID)] },
            { rows: [assignment(QUEUE_ROLE, 'Pending', ROLES_ID)], roles: [{ RoleID: QUEUE_ROLE, Role: 'Approvers' }] },
        ];
        for (const c of cases) {
            written.mockClear();
            db.assignments = c.rows;
            db.userRoles = c.roles ?? [];
            expect(await moveTo(approvalTask(), 'Completed').Save()).toBe(true);
            expect(written).toHaveBeenCalledTimes(1);
        }
    });

    it('lets the person an agent asked answer its question by completing the task (nobody is its requester)', async () => {
        db.assignments = [assignment(USER_ID, 'Pending', USERS_ID)];
        const question = approvalTask();
        question.CreatedByPersonID = null;
        question.CompletionNotes = 'Use us-east.';
        expect(await moveTo(question, 'Completed').Save()).toBe(true);
    });

    it('lets a requester who holds SelfApprovalExemptRole complete their own assigned request, as they may decide it', async () => {
        db.assignments = [assignment(MY_PERSON)];
        db.settings.set('SelfApprovalExemptRole', 'CFO');
        const ownRequest = (): Server => {
            const own = approvalTask();
            own.CreatedByPersonID = MY_PERSON;
            return moveTo(own, 'Completed');
        };
        expect(await refusalOf(ownRequest())).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);

        db.userRoles = [{ RoleID: 'r-cfo', Role: ' cfo ' }];
        expect(await ownRequest().Save()).toBe(true);
        expect(written).toHaveBeenCalledTimes(1);
    });

    it('refuses reaching Completed through a stage, where the status is synced from the stage', async () => {
        const t = approvalTask();
        change(t, 'TaskTypeStatusID', null, DONE_STAGE);
        t.TaskTypeStatusID = DONE_STAGE;
        // The sync sets Status from the stage inside Save; the field then reads as changed.
        change(t, 'Status', 'Open', 'Completed');
        expect(await refusalOf(t)).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);
        expect(t.Status).toBe('Completed');
    });

    it('does not approve a timesheet from a bare status change by someone who is not its approver', async () => {
        expect(await refusalOf(moveTo(approvalTask(TIMESHEET_TYPE), 'Completed'))).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);
        expect(applyTimesheetOutcome).not.toHaveBeenCalled();

        // Nor by the person whose timesheet it is, were they to become an assignee of it.
        db.assignments = [assignment(MY_PERSON)];
        const own = approvalTask(TIMESHEET_TYPE);
        own.CreatedByPersonID = MY_PERSON;
        expect(await refusalOf(moveTo(own, 'Completed'))).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);
        expect(applyTimesheetOutcome).not.toHaveBeenCalled();
    });

    it('lets a decision saved with the task complete it (RecordDecision), and the timesheet outcome follows', async () => {
        const t = moveTo(approvalTask(TIMESHEET_TYPE), 'Completed');
        decideWith(t, APPROVED);
        expect(await t.Save()).toBe(true);
        expect(written).toHaveBeenCalledTimes(1);
        expect(applyTimesheetOutcome).toHaveBeenCalledWith(TASK_ID, 'Completed', expect.anything(), expect.anything(), expect.anything());
        // The decision travelling with the task is the one that stands: no stored decision is read.
        expect(filtersSeen.some((f) => f.startsWith('MJ_BizApps_Tasks: Task Decisions:'))).toBe(false);
    });

    it('lets a rejecting decision saved with the task cancel it, whoever holds no other standing', async () => {
        db.settings.set('ApprovalReassignRoles', 'Finance Admin');
        const t = moveTo(approvalTask(), 'Cancelled');
        decideWith(t, REJECTED);
        expect(await t.Save()).toBe(true);
    });

    it('refuses Completed when the decision saved with the task rejects, or does not close a task', async () => {
        for (const outcome of [REJECTED, NEEDS_INFO]) {
            written.mockClear();
            const t = moveTo(approvalTask(), 'Completed');
            decideWith(t, outcome);
            expect(await refusalOf(t)).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);
        }
    });

    it('lets the status follow the latest recorded decision (a decision saved first, the status after)', async () => {
        db.latestOutcomeID = APPROVED;
        expect(await moveTo(approvalTask(), 'Completed').Save()).toBe(true);
        expect(filtersSeen).toContain(`MJ_BizApps_Tasks: Task Decisions: TaskID = '${TASK_ID}'`);
    });

    it('refuses a user with no standing completing an approval whose latest decision rejected it', async () => {
        db.latestOutcomeID = REJECTED;
        expect(await refusalOf(moveTo(approvalTask(), 'Completed'))).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);
    });

    it('refuses creating an approval task that is already Completed', async () => {
        const t = new TaskEntityServer();
        t.Name = 'Born approved';
        t.TypeID = APPROVAL_TYPE;
        t.Status = 'Completed';
        expect(await refusalOf(t)).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);
    });

    it('fails closed when the task type cannot be read', async () => {
        db.fail = 'MJ_BizApps_Tasks: Task Types';
        expect(await refusalOf(moveTo(approvalTask(), 'Completed'))).toMatch(/could not be checked \(database unavailable\)/);
    });

    it('fails closed when the decisions cannot be read', async () => {
        db.fail = 'MJ_BizApps_Tasks: Task Decisions';
        expect(await refusalOf(moveTo(approvalTask(), 'Completed'))).toMatch(/could not be checked \(database unavailable\)/);
    });
});

describe('TaskEntityServer — who may cancel an approval task that nobody rejected', () => {
    beforeEach(() => {
        // With no role named, everyone holds the reassign right, so name one to see the other rules.
        db.settings.set('ApprovalReassignRoles', 'Finance Admin');
    });

    it('refuses a user with no standing', async () => {
        expect(await refusalOf(moveTo(approvalTask(), 'Cancelled'))).toBe(WITHDRAW_REFUSAL);
    });

    it('lets the requester withdraw their own request', async () => {
        const t = approvalTask();
        t.CreatedByPersonID = MY_PERSON.toLowerCase();
        expect(await moveTo(t, 'Cancelled').Save()).toBe(true);
        // Being the requester settles it: assignments and roles are not read.
        expect(filtersSeen.some((f) => f.startsWith('MJ_BizApps_Tasks: Task Assignments') || f.startsWith('MJ: User Roles'))).toBe(false);
    });

    it('lets an active assignee close what they could have rejected: as a Person, a user, or a role queue', async () => {
        const cases: Array<{ rows: AssignmentRow[]; roles?: Array<{ RoleID: string; Role: string }> }> = [
            { rows: [assignment(MY_PERSON, 'InProgress')] },
            { rows: [assignment(USER_ID, 'Pending', USERS_ID)] },
            { rows: [assignment(QUEUE_ROLE, 'Pending', ROLES_ID)], roles: [{ RoleID: QUEUE_ROLE, Role: 'Approvers' }] },
        ];
        for (const c of cases) {
            written.mockClear();
            db.assignments = c.rows;
            db.userRoles = c.roles ?? [];
            expect(await moveTo(approvalTask(), 'Cancelled').Save()).toBe(true);
            expect(written).toHaveBeenCalledTimes(1);
        }
    });

    it('does not count an assignment that is already completed', async () => {
        db.assignments = [assignment(MY_PERSON, 'Completed')];
        expect(await refusalOf(moveTo(approvalTask(), 'Cancelled'))).toBe(WITHDRAW_REFUSAL);
    });

    it('lets a holder of an ApprovalReassignRoles role cancel it', async () => {
        db.userRoles = [{ RoleID: 'r-1', Role: 'finance admin' }];
        expect(await moveTo(approvalTask(), 'Cancelled').Save()).toBe(true);
    });

    it('lets anyone cancel it while ApprovalReassignRoles names no role, as for removing an assignee', async () => {
        db.settings = new Map();
        expect(await moveTo(approvalTask(), 'Cancelled').Save()).toBe(true);
    });

    it('lets server code withdrawing its own request vouch for one save, and only one', async () => {
        const t = moveTo(approvalTask(), 'Cancelled');
        t.AuthorizeApprovalWithdrawal();
        expect(await t.Save()).toBe(true);
        // Vouched for: who is saving is never read.
        expect(filtersSeen.some((f) => f.startsWith('MJ_BizApps_Common: People'))).toBe(false);
        written.mockClear();
        expect(await refusalOf(t)).toBe(WITHDRAW_REFUSAL);
    });

    it('lets the system user cancel it', async () => {
        db.systemUser = true;
        expect(await moveTo(approvalTask(), 'Cancelled').Save()).toBe(true);
    });

    it('refuses a cancel with nobody signed in', async () => {
        const t = moveTo(approvalTask(), 'Cancelled');
        t.ContextCurrentUser = null;
        expect(await refusalOf(t)).toBe(WITHDRAW_NO_USER_REFUSAL);
    });

    it('treats cancelling an approved task as a withdrawal: the approval does not license it', async () => {
        db.latestOutcomeID = APPROVED;
        const t = approvalTask();
        t.Status = 'Completed';
        expect(await refusalOf(moveTo(t, 'Cancelled'))).toBe(WITHDRAW_REFUSAL);
    });

    it('lets the person creating an approval task create it already cancelled', async () => {
        const t = new TaskEntityServer();
        t.Name = 'Withdrawn before it was sent';
        t.TypeID = APPROVAL_TYPE;
        t.Status = 'Cancelled';
        expect(await t.Save()).toBe(true);
    });
});

describe('TaskEntityServer — ordinary tasks and ordinary saves are left alone', () => {
    it('lets anyone complete or cancel a task that is not an approval, reading only its type', async () => {
        db.settings.set('ApprovalReassignRoles', 'Finance Admin');
        for (const status of ['Completed', 'Cancelled'] as const) {
            filtersSeen.length = 0;
            expect(await moveTo(approvalTask(ORDINARY_TYPE), status).Save()).toBe(true);
            expect(filtersSeen).toEqual([`MJ_BizApps_Tasks: Task Types: ID IN ('${ORDINARY_TYPE}')`]);
        }
    });

    it('reads nothing for a save that neither closes the task nor changes its type', async () => {
        const t = moveTo(approvalTask(), 'InProgress');
        change(t, 'Priority', 'Medium', 'High');
        expect(await t.Save()).toBe(true);
        expect(filtersSeen).toEqual([]);
    });

    it('does not check a closed approval task again when something else on it is edited', async () => {
        const t = approvalTask();
        t.Status = 'Completed';
        change(t, 'Description', null, 'typo fix');
        expect(await t.Save()).toBe(true);
        expect(filtersSeen).toEqual([]);
    });
});

describe('TaskEntityServer — an approval task stays an approval', () => {
    function retyped(from: string, to: string): Server {
        const t = approvalTask(from);
        change(t, 'TypeID', from, to);
        t.TypeID = to;
        return t;
    }

    it('refuses turning an approval task into an ordinary task', async () => {
        expect(await refusalOf(retyped(APPROVAL_TYPE, ORDINARY_TYPE))).toBe(APPROVAL_TYPE_CHANGE_REFUSAL);
    });

    it('refuses the change of type and the completion together, so one save cannot do both', async () => {
        const t = moveTo(retyped(APPROVAL_TYPE, ORDINARY_TYPE), 'Completed');
        const message = await refusalOf(t);
        expect(message).toContain(APPROVAL_TYPE_CHANGE_REFUSAL);
        expect(message).toContain(COMPLETE_WITHOUT_DECISION_REFUSAL);
    });

    it('allows moving between approval types, and making an ordinary task an approval', async () => {
        expect(await retyped(APPROVAL_TYPE, TIMESHEET_TYPE).Save()).toBe(true);
        expect(await retyped(ORDINARY_TYPE, APPROVAL_TYPE).Save()).toBe(true);
    });

    it('allows the system user to change it', async () => {
        db.systemUser = true;
        expect(await retyped(APPROVAL_TYPE, ORDINARY_TYPE).Save()).toBe(true);
    });
});

describe('TaskEntityServer — a task is created as its creator', () => {
    function newTask(creator?: string): Server {
        const t = new TaskEntityServer();
        t.Name = 'Approve my own request';
        if (creator) t.CreatedByPersonID = creator;
        return t;
    }

    it('refuses a caller creating a task in someone else\'s name', async () => {
        expect(await refusalOf(newTask(REQUESTER))).toBe(CREATOR_NOT_SELF_REFUSAL);
    });

    it('accepts a caller naming one of their own People', async () => {
        db.people = [{ ID: MY_PERSON }, { ID: REQUESTER.toLowerCase() }];
        expect(await newTask(REQUESTER).Save()).toBe(true);
    });

    it('does not look the creator up again when this class recorded it', async () => {
        const t = newTask();
        expect(await t.Save()).toBe(true);
        expect(t.CreatedByPersonID).toBe(MY_PERSON);
        expect(filtersSeen.filter((f) => f.startsWith('MJ_BizApps_Common: People'))).toHaveLength(1);
    });

    it('lets server code raising a task for someone else vouch for one save, and only one', async () => {
        const t = newTask(REQUESTER);
        t.AuthorizeCreatorOnBehalf();
        expect(await t.Save()).toBe(true);
        expect(filtersSeen).toEqual([]);
        written.mockClear();
        expect(await refusalOf(t)).toBe(CREATOR_NOT_SELF_REFUSAL);
    });

    it('lets sanctioned server code create a task that is nobody\'s request: the user saving is not recorded either', async () => {
        const t = newTask();
        t.AuthorizeCreatorOnBehalf();
        expect(await t.Save()).toBe(true);
        expect(t.CreatedByPersonID ?? null).toBeNull();
        expect(filtersSeen).toEqual([]);
    });

    it('lets the system user create a task on someone\'s behalf', async () => {
        db.systemUser = true;
        expect(await newTask(REQUESTER).Save()).toBe(true);
        expect(filtersSeen).toEqual([]);
    });

    it('refuses a user recording a creator on a task that was saved without one, even themselves', async () => {
        const t = approvalTask();
        t.CreatedByPersonID = null;
        change(t, 'CreatedByPersonID', null, MY_PERSON);
        t.CreatedByPersonID = MY_PERSON;
        expect(await refusalOf(t)).toBe(CREATOR_AFTER_CREATE_REFUSAL);
    });

    it('lets sanctioned server code record a creator on a task that was saved without one', async () => {
        const t = approvalTask();
        change(t, 'CreatedByPersonID', null, REQUESTER);
        t.AuthorizeCreatorOnBehalf();
        expect(await t.Save()).toBe(true);
    });

    it('fails closed when the caller\'s People cannot be read', async () => {
        db.fail = 'MJ_BizApps_Common: People';
        expect(await refusalOf(newTask(REQUESTER))).toMatch(/could not be checked \(database unavailable\)/);
    });
});
