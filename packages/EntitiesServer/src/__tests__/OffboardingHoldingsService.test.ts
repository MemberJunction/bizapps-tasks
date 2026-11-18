import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { UserInfo } from '@memberjunction/core';

const USERS_ENT = 'E0000000-0000-0000-0000-0000000000A1';
const EMPLOYEES_ENT = 'E0000000-0000-0000-0000-0000000000A2';
const PEOPLE_ENT = 'E0000000-0000-0000-0000-0000000000A3';
const ROLES_ENT = 'E0000000-0000-0000-0000-0000000000A4';

const LEAVER_USER = 'B0000000-0000-0000-0000-000000000001';
const LEAVER_EMP = 'F0000000-0000-0000-0000-000000000001';
const LEAVER_PERSON = 'C0000000-0000-0000-0000-000000000001';
const SUPERVISOR_EMP = 'F0000000-0000-0000-0000-000000000002';
const CALLER_USER = 'B0000000-0000-0000-0000-000000000002';
const SUCC_USER = 'B0000000-0000-0000-0000-000000000003';
const SUCC_EMP = 'F0000000-0000-0000-0000-000000000003';
const SUCC_PERSON = 'C0000000-0000-0000-0000-000000000003';

const TASK_OPEN = 'D0000000-0000-0000-0000-000000000001';
const TASK_APPROVAL = 'D0000000-0000-0000-0000-000000000002';
const TASK_DONE = 'D0000000-0000-0000-0000-000000000003';
const TYPE_PLAIN = 'A1000000-0000-0000-0000-000000000001';
const TYPE_APPROVAL = 'A1000000-0000-0000-0000-000000000002';

const A_PERSON = 'A0000000-0000-0000-0000-000000000001';
const A_USER_APPROVAL = 'A0000000-0000-0000-0000-000000000002';
const A_ON_DONE_TASK = 'A0000000-0000-0000-0000-000000000003';
const A_EMPLOYEE = 'A0000000-0000-0000-0000-000000000004';
const A_ROLE = 'A0000000-0000-0000-0000-000000000005';

type Assignment = { ID: string; TaskID: string; AssigneeEntityID: string; AssigneeRecordID: string; Status: string; AssignedByPersonID: string | null };

const db = {
    users: [] as Array<{ ID: string; IsActive: boolean; EmployeeID: string | null; LinkedEntityID: string | null; LinkedEntityRecordID: string | null }>,
    employees: [] as Array<{ ID: string; SupervisorID: string | null }>,
    people: new Map<string, string[]>(),
    callerRoles: [] as string[],
    cfoApprover: false,
    accountingInstalled: true,
    reassignRoles: [] as string[],
    assignments: [] as Assignment[],
    tasks: [] as Array<{ ID: string; Name: string; TypeID: string; Status: string }>,
    refuseSave: new Map<string, string>(),
    saves: [] as Assignment[],
};

const ids = (filter: string): string[] => (filter.match(/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}/gi) ?? []).map((s) => s.toUpperCase());

function viewResults(entity: string, filter: string): unknown[] {
    const named = ids(filter);
    switch (entity) {
        case 'MJ: Users':
            return filter.startsWith('EmployeeID') ? db.users.filter((u) => named.includes(u.EmployeeID ?? '')) : db.users.filter((u) => named.includes(u.ID));
        case 'MJ: Employees': return db.employees.filter((e) => named.includes(e.ID));
        case 'MJ: User Roles': return db.callerRoles.map((Role) => ({ Role }));
        case 'MJ_BizApps_Accounting: Accounting Company Profiles': return db.cfoApprover ? [{ ID: 'X' }] : [];
        case 'MJ_BizApps_Common: People': return named.flatMap((id) => (db.people.get(id) ?? []).map((ID) => ({ ID })));
        case 'MJ_BizApps_Tasks: Task Assignments': return assignmentsMatching(filter, named);
        case 'MJ_BizApps_Tasks: Tasks':
            return db.tasks.filter((t) => named.includes(t.ID) && !['Completed', 'Cancelled'].includes(t.Status));
        case 'MJ_BizApps_Tasks: Task Types':
            return [TYPE_APPROVAL].filter((t) => named.includes(t)).map((ID) => ({ ID, IsApproval: true }));
        default: throw new Error(`unexpected entity ${entity}`);
    }
}

/** Assignments whose (entity, record) pair is named in the filter; open ones only when the filter says so. */
function assignmentsMatching(filter: string, named: string[]): Assignment[] {
    const openOnly = filter.includes("Status IN ('Pending', 'InProgress')");
    const byTask = filter.startsWith('TaskID IN');
    return db.assignments.filter((a) =>
        (!openOnly || a.Status !== 'Completed')
        && (!byTask || named.includes(a.TaskID))
        && named.includes(a.AssigneeEntityID) && named.includes(a.AssigneeRecordID));
}

vi.mock('@memberjunction/core', () => {
    const entities = [
        { ID: USERS_ENT, Name: 'MJ: Users', ParentChain: [] },
        { ID: EMPLOYEES_ENT, Name: 'MJ: Employees', ParentChain: [] },
        { ID: PEOPLE_ENT, Name: 'MJ_BizApps_Common: People', ParentChain: [] },
        { ID: ROLES_ENT, Name: 'MJ: Roles', ParentChain: [] },
    ];
    const provider = {
        Entities: entities,
        EntityByID: (id: string) => entities.find((e) => e.ID === id.toUpperCase()),
        EntityByName: (name: string) =>
            name === 'MJ_BizApps_Accounting: Accounting Company Profiles'
                ? (db.accountingInstalled ? { ID: 'ACCT', Name: name } : undefined)
                : entities.find((e) => e.Name === name),
    };
    class FakeAssignment {
        ID = '';
        TaskID = '';
        AssigneeEntityID = '';
        AssigneeRecordID = '';
        Status = '';
        AssignedByPersonID: string | null = null;
        LatestResult: { CompleteMessage: string } | null = null;
        async Load(id: string) {
            const row = db.assignments.find((a) => a.ID === id);
            if (!row) return false;
            Object.assign(this, row);
            return true;
        }
        async Save() {
            const refusal = db.refuseSave.get(this.ID);
            if (refusal) {
                this.LatestResult = { CompleteMessage: refusal };
                return false;
            }
            const row = db.assignments.find((a) => a.ID === this.ID)!;
            Object.assign(row, { AssigneeEntityID: this.AssigneeEntityID, AssigneeRecordID: this.AssigneeRecordID, AssignedByPersonID: this.AssignedByPersonID, Status: this.Status });
            db.saves.push({ ...row });
            return true;
        }
    }
    class Metadata {
        static Provider = provider;
        async GetEntityObject() {
            return new FakeAssignment();
        }
    }
    return {
        Metadata,
        RunView: class {
            async RunView(p: { EntityName: string; ExtraFilter: string }) {
                return { Success: true, Results: viewResults(p.EntityName, p.ExtraFilter ?? '') };
            }
        },
    };
});

vi.mock('../TasksSettings.js', () => ({
    TasksSettings: { Load: vi.fn(async () => undefined), ApprovalReassignRoles: () => db.reassignRoles },
}));

vi.mock('@mj-biz-apps/tasks-entities', () => ({ mjBizAppsTasksTaskAssignmentEntity: class {} }));

const { OffboardingHoldingsService } = await import('../offboarding/OffboardingHoldingsService.js');

const caller = { ID: CALLER_USER, EmployeeID: SUPERVISOR_EMP };
const service = () => new OffboardingHoldingsService(caller as unknown as UserInfo);

function seed(): void {
    db.users = [
        { ID: LEAVER_USER, IsActive: false, EmployeeID: LEAVER_EMP, LinkedEntityID: null, LinkedEntityRecordID: null },
        { ID: SUCC_USER, IsActive: true, EmployeeID: SUCC_EMP, LinkedEntityID: null, LinkedEntityRecordID: null },
        { ID: CALLER_USER, IsActive: true, EmployeeID: SUPERVISOR_EMP, LinkedEntityID: null, LinkedEntityRecordID: null },
    ];
    db.employees = [{ ID: LEAVER_EMP, SupervisorID: SUPERVISOR_EMP }, { ID: SUCC_EMP, SupervisorID: null }];
    db.people = new Map([[LEAVER_USER, [LEAVER_PERSON]], [SUCC_USER, [SUCC_PERSON]]]);
    db.callerRoles = [];
    db.cfoApprover = false;
    db.accountingInstalled = true;
    db.reassignRoles = [];
    db.tasks = [
        { ID: TASK_OPEN, Name: 'Prepare onboarding pack', TypeID: TYPE_PLAIN, Status: 'InProgress' },
        { ID: TASK_APPROVAL, Name: 'Approve discount', TypeID: TYPE_APPROVAL, Status: 'Open' },
        { ID: TASK_DONE, Name: 'Old task', TypeID: TYPE_PLAIN, Status: 'Completed' },
    ];
    const requester = 'C0000000-0000-0000-0000-0000000000AA';
    db.assignments = [
        { ID: A_PERSON, TaskID: TASK_OPEN, AssigneeEntityID: PEOPLE_ENT, AssigneeRecordID: LEAVER_PERSON, Status: 'Pending', AssignedByPersonID: requester },
        { ID: A_USER_APPROVAL, TaskID: TASK_APPROVAL, AssigneeEntityID: USERS_ENT, AssigneeRecordID: LEAVER_USER, Status: 'InProgress', AssignedByPersonID: requester },
        { ID: A_ON_DONE_TASK, TaskID: TASK_DONE, AssigneeEntityID: PEOPLE_ENT, AssigneeRecordID: LEAVER_PERSON, Status: 'Pending', AssignedByPersonID: requester },
        { ID: A_EMPLOYEE, TaskID: TASK_OPEN, AssigneeEntityID: EMPLOYEES_ENT, AssigneeRecordID: LEAVER_EMP, Status: 'Pending', AssignedByPersonID: null },
        { ID: A_ROLE, TaskID: TASK_OPEN, AssigneeEntityID: ROLES_ENT, AssigneeRecordID: LEAVER_USER, Status: 'Pending', AssignedByPersonID: null },
    ];
    db.refuseSave = new Map();
    db.saves = [];
}

beforeEach(seed);

describe('ResolveLeaver', () => {
    it('fills in the employee and People from the user', async () => {
        expect(await service().ResolveLeaver(LEAVER_USER, null)).toEqual({
            UserID: LEAVER_USER, EmployeeID: LEAVER_EMP, SupervisorEmployeeID: SUPERVISOR_EMP, PersonIDs: [LEAVER_PERSON],
        });
    });

    it('finds the user from the employee', async () => {
        expect((await service().ResolveLeaver(null, LEAVER_EMP))?.UserID).toBe(LEAVER_USER);
    });

    it('returns null when neither ID matches a record', async () => {
        expect(await service().ResolveLeaver('B0000000-0000-0000-0000-0000000000FF', null)).toBeNull();
    });
});

describe('ResolveCallerAuthority', () => {
    const leaver = { UserID: LEAVER_USER, EmployeeID: LEAVER_EMP, SupervisorEmployeeID: SUPERVISOR_EMP, PersonIDs: [] };

    it("recognises the leaver's supervisor", async () => {
        expect((await service().ResolveCallerAuthority(leaver)).IsLeaversSupervisor).toBe(true);
    });

    it('recognises a Sales Admin regardless of case', async () => {
        db.callerRoles = [' sales admin '];
        const authority = await service().ResolveCallerAuthority({ ...leaver, SupervisorEmployeeID: null });
        expect(authority).toMatchObject({ IsLeaversSupervisor: false, HoldsSalesAdmin: true });
    });

    it('recognises a CFO approver, and treats a missing accounting app as no', async () => {
        db.cfoApprover = true;
        expect((await service().ResolveCallerAuthority(leaver)).IsCFOApprover).toBe(true);
        db.accountingInstalled = false;
        expect((await service().ResolveCallerAuthority(leaver)).IsCFOApprover).toBe(false);
    });

    it('applies ApprovalReassignRoles when it names roles', async () => {
        db.reassignRoles = ['Finance Admin'];
        expect((await service().ResolveCallerAuthority(leaver)).MayReassignApprovals).toBe(false);
        db.callerRoles = ['Finance Admin'];
        expect((await service().ResolveCallerAuthority(leaver)).MayReassignApprovals).toBe(true);
    });
});

describe('ListHoldings', () => {
    it('lists open assignments on open tasks, by user, Person or employee, and never role assignments', async () => {
        const s = service();
        const leaver = (await s.ResolveLeaver(LEAVER_USER, null))!;
        const { Holdings } = await s.ListHoldings(leaver, await s.ResolveCallerAuthority(leaver));
        expect(Holdings.map((h) => [h.RecordID, h.Kind, h.CanReassign])).toEqual([
            [A_PERSON, 'TASK_ASSIGNMENT', true],
            [A_USER_APPROVAL, 'APPROVAL_ASSIGNMENT', true],
            [A_EMPLOYEE, 'TASK_ASSIGNMENT', true],
        ]);
    });
});

describe('Reassign', () => {
    async function reassign(successor = SUCC_USER, kinds: string[] | null = null, recordIDs: string[] | null = null) {
        const s = service();
        const leaver = (await s.ResolveLeaver(LEAVER_USER, null))!;
        return s.Reassign(leaver, successor, kinds, recordIDs);
    }

    it("moves each holding to the successor's record of the same kind and keeps the requester", async () => {
        const outcome = await reassign();
        expect(outcome).toMatchObject({ ResultCode: 'SUCCESS', Moved: 3, Skipped: [] });
        const byID = new Map(db.assignments.map((a) => [a.ID, a]));
        expect(byID.get(A_PERSON)).toMatchObject({ AssigneeEntityID: PEOPLE_ENT, AssigneeRecordID: SUCC_PERSON, AssignedByPersonID: 'C0000000-0000-0000-0000-0000000000AA' });
        expect(byID.get(A_USER_APPROVAL)).toMatchObject({ AssigneeEntityID: USERS_ENT, AssigneeRecordID: SUCC_USER });
        expect(byID.get(A_EMPLOYEE)).toMatchObject({ AssigneeEntityID: EMPLOYEES_ENT, AssigneeRecordID: SUCC_EMP });
        expect(byID.get(A_ON_DONE_TASK)?.AssigneeRecordID).toBe(LEAVER_PERSON);
        expect(byID.get(A_ROLE)?.AssigneeRecordID).toBe(LEAVER_USER);
    });

    it('narrows by Kinds and RecordIDs and reports an ID the leaver does not hold', async () => {
        const stranger = 'A0000000-0000-0000-0000-0000000000FF';
        const outcome = await reassign(SUCC_USER, ['TASK_ASSIGNMENT'], [A_PERSON, A_USER_APPROVAL, stranger]);
        expect(outcome.Moved).toBe(1);
        expect(outcome.Skipped).toEqual([expect.objectContaining({ RecordID: stranger })]);
        expect(db.saves.map((s) => s.ID)).toEqual([A_PERSON]);
    });

    it('reports a save the approval guard refuses as skipped, not as a failure', async () => {
        db.refuseSave.set(A_USER_APPROVAL, 'You cannot assign an approval to yourself.');
        const outcome = await reassign();
        expect(outcome.ResultCode).toBe('SUCCESS');
        expect(outcome.Moved).toBe(2);
        expect(outcome.Skipped).toEqual([{ Kind: 'APPROVAL_ASSIGNMENT', EntityName: 'MJ_BizApps_Tasks: Task Assignments', RecordID: A_USER_APPROVAL, Reason: 'You cannot assign an approval to yourself.' }]);
    });

    it('skips approvals, without saving, when the caller lacks an ApprovalReassignRoles role', async () => {
        db.reassignRoles = ['Finance Admin'];
        const outcome = await reassign();
        expect(outcome.Moved).toBe(2);
        expect(outcome.Skipped.map((s) => s.RecordID)).toEqual([A_USER_APPROVAL]);
        expect(db.saves.map((s) => s.ID)).not.toContain(A_USER_APPROVAL);
    });

    it('returns NOT_AUTHORIZED, moving nothing, when the caller may move none of the items', async () => {
        db.employees[0].SupervisorID = null;
        const outcome = await reassign();
        expect(outcome).toMatchObject({ ResultCode: 'NOT_AUTHORIZED', Moved: 0 });
        expect(outcome.Skipped).toHaveLength(3);
        expect(db.saves).toEqual([]);
    });

    it('skips an assignment the successor already holds on the same task', async () => {
        db.assignments.push({ ID: 'A0000000-0000-0000-0000-000000000009', TaskID: TASK_OPEN, AssigneeEntityID: PEOPLE_ENT, AssigneeRecordID: SUCC_PERSON, Status: 'Pending', AssignedByPersonID: null });
        const outcome = await reassign();
        expect(outcome.Skipped).toEqual([expect.objectContaining({ RecordID: A_PERSON, Reason: 'The successor is already assigned to this task.' })]);
    });

    it('skips a Person assignment when the successor has no Person', async () => {
        db.people.delete(SUCC_USER);
        const outcome = await reassign();
        expect(outcome.Skipped.map((s) => s.RecordID)).toEqual([A_PERSON]);
    });

    it.each([
        ['an inactive successor', SUCC_USER, /inactive/, () => { db.users[1].IsActive = false; }],
        ['the leaver as successor', LEAVER_USER, /is the leaver/, () => { db.users[0].IsActive = true; }],
        ['a successor sharing the leaver employee record', SUCC_USER, /is the leaver/, () => { db.users[1].EmployeeID = LEAVER_EMP; }],
    ])('refuses %s as INVALID_INPUT', async (_label, successor, message, arrange) => {
        arrange();
        const outcome = await reassign(successor);
        expect(outcome.ResultCode).toBe('INVALID_INPUT');
        expect(outcome.Message).toMatch(message);
        expect(db.saves).toEqual([]);
    });

    it('refuses a successor that is not a user', async () => {
        expect((await reassign('B0000000-0000-0000-0000-0000000000FF')).ResultCode).toBe('INVALID_INPUT');
    });
});
