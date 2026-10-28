import { beforeEach, describe, expect, it, vi } from 'vitest';

const PEOPLE_ID = 'A0000000-0000-0000-0000-000000000001';
const USERS_ID = 'A0000000-0000-0000-0000-000000000002';
const APP_ID = 'A0000000-0000-0000-0000-0000000000AA';
const TASK_ID = 'D0000000-0000-0000-0000-000000000001';
const OTHER_TASK_ID = 'D0000000-0000-0000-0000-000000000002';
const TYPE_ID = 'E0000000-0000-0000-0000-000000000001';
const USER_ID = 'B0000000-0000-0000-0000-000000000001';
const MY_PERSON = 'C0000000-0000-0000-0000-000000000001';
const CEO_PERSON = 'C0000000-0000-0000-0000-000000000002';
const OTHER_PERSON = 'C0000000-0000-0000-0000-000000000003';

/** What the fake database returns, per entity. */
const db = {
    settings: new Map<string, string>(),
    isApproval: true,
    people: [{ ID: MY_PERSON }],
    userRoles: [] as Array<{ ID: string }>,
    failTaskLookup: false,
};
const filtersSeen: string[] = [];

function viewResult(entityName: string, filter: string): { Success: boolean; Results: unknown[]; ErrorMessage?: string } {
    filtersSeen.push(`${entityName}: ${filter}`);
    switch (entityName) {
        case 'MJ_BizApps_Tasks: Tasks':
            return db.failTaskLookup ? { Success: false, Results: [], ErrorMessage: 'database unavailable' } : { Success: true, Results: [{ TypeID: TYPE_ID }] };
        case 'MJ_BizApps_Tasks: Task Types': return { Success: true, Results: [{ IsApproval: db.isApproval }] };
        case 'MJ_BizApps_Common: People': return { Success: true, Results: db.people };
        case 'MJ: User Roles': return { Success: true, Results: db.userRoles };
        default: return { Success: false, Results: [], ErrorMessage: `unexpected entity ${entityName}` };
    }
}

vi.mock('@memberjunction/global', () => ({
    RegisterClass: () => () => {},
    IsValidUUID: (v: string) => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v),
}));

vi.mock('@memberjunction/core-entities', () => ({
    ApplicationSettingEngine: {
        Instance: {
            Config: vi.fn(async () => undefined),
            GetSetting: (name: string, appID?: string) => (appID === APP_ID ? db.settings.get(name) : undefined),
        },
    },
}));

vi.mock('@memberjunction/core', () => {
    class ValidationResult { Success = true; Errors: Array<{ Message: string }> = []; }
    class ValidationErrorInfo { constructor(public Source: string, public Message: string, public Value: unknown) {} }
    class BaseEntityResult { Success = true; Type = ''; Message = ''; EndedAt: Date | null = null; }
    const provider = {
        Applications: [{ Name: 'Tasks', ID: APP_ID }],
        EntityByID: (id: string) => (id === PEOPLE_ID ? { Name: 'MJ_BizApps_Common: People', ParentChain: [] } : id === USERS_ID ? { Name: 'MJ: Users', ParentChain: [] } : null),
        EntityByName: (name: string) => (name === 'MJ: Users' ? { ID: USERS_ID } : null),
    };
    return {
        BaseEntity: class {},
        BaseEntityResult,
        LogError: vi.fn(),
        Metadata: { Provider: provider },
        RunView: class {
            async RunView(p: { EntityName: string; ExtraFilter: string }) {
                return viewResult(p.EntityName, p.ExtraFilter);
            }
        },
        ValidationResult,
        ValidationErrorInfo,
    };
});

vi.mock('@mj-biz-apps/tasks-entities', () => ({
    mjBizAppsTasksTaskAssignmentEntity: class {
        ID: string | null = null;
        TaskID = TASK_ID;
        AssigneeEntityID = PEOPLE_ID;
        AssigneeRecordID = OTHER_PERSON;
        IsSaved = false;
        RunViewProviderToUse = {};
        ContextCurrentUser: { ID: string } | null = { ID: USER_ID };
        old = new Map<string, string>();
        history: Array<{ Success: boolean; Message: string }> = [];
        deleted = false;
        GetFieldByName(name: string) {
            const current = (this as unknown as Record<string, string>)[name];
            const was = this.old.has(name) ? this.old.get(name) : current;
            return { Dirty: was !== current, OldValue: was };
        }
        async ValidateAsync() {
            return { Success: true, Errors: [] as Array<{ Message: string }> };
        }
        async Delete() {
            this.deleted = true;
            return true;
        }
        RegisterResultHistoryEntry(r: { Success: boolean; Message: string }) {
            this.history.push(r);
        }
    },
}));

const { TaskAssignmentEntityServer, SELF_ASSIGN_REFUSAL, REASSIGN_REFUSAL, REMOVE_REFUSAL } = await import('../TaskAssignmentEntityServer.js');
type Assignment = InstanceType<typeof TaskAssignmentEntityServer> & { old: Map<string, string>; history: Array<{ Message: string }>; deleted: boolean };

/** A new assignment of the approval task to `assignee`. */
function created(assignee: string, entityID = PEOPLE_ID): Assignment {
    const a = new TaskAssignmentEntityServer() as Assignment;
    a.AssigneeEntityID = entityID;
    a.AssigneeRecordID = assignee;
    return a;
}

/** A saved assignment to the CEO, optionally moved to `newAssignee`. */
function saved(newAssignee?: string): Assignment {
    const a = new TaskAssignmentEntityServer() as Assignment;
    a.ID = 'F0000000-0000-0000-0000-000000000001';
    a.IsSaved = true;
    a.AssigneeRecordID = CEO_PERSON;
    a.old.set('AssigneeRecordID', CEO_PERSON);
    if (newAssignee) a.AssigneeRecordID = newAssignee;
    return a;
}

describe('TaskAssignmentEntityServer', () => {
    beforeEach(() => {
        db.settings = new Map();
        db.isApproval = true;
        db.people = [{ ID: MY_PERSON }];
        db.userRoles = [];
        db.failTaskLookup = false;
        filtersSeen.length = 0;
    });

    it('opts in to async validation so the rule always runs', () => {
        expect(created(OTHER_PERSON).DefaultSkipAsyncValidation).toBe(false);
    });

    it('lets a workflow create an approval assignment for someone else', async () => {
        const result = await created(CEO_PERSON).ValidateAsync();
        expect(result.Success).toBe(true);
    });

    it('leaves create unchecked, so a workflow may assign the acting user (order review)', async () => {
        expect((await created(MY_PERSON).ValidateAsync()).Success).toBe(true);
        expect((await created(USER_ID, USERS_ID).ValidateAsync()).Success).toBe(true);
        expect(filtersSeen).toEqual([]);
    });

    it('refuses reassigning an approval to the signed-in user directly as an MJ: Users row', async () => {
        const a = saved();
        a.old.set('AssigneeEntityID', PEOPLE_ID);
        a.AssigneeEntityID = USERS_ID;
        a.AssigneeRecordID = USER_ID;
        const result = await a.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe(SELF_ASSIGN_REFUSAL);
    });

    it('refuses a business user reassigning an approval to another person', async () => {
        const result = await saved(OTHER_PERSON).ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe(REASSIGN_REFUSAL);
    });

    it('refuses a business user reassigning an approval to themselves', async () => {
        const result = await saved(MY_PERSON).ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe(SELF_ASSIGN_REFUSAL);
    });

    it('refuses moving an approval assignment onto another task', async () => {
        const a = saved();
        a.old.set('TaskID', TASK_ID);
        a.TaskID = OTHER_TASK_ID;
        const result = await a.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe(REASSIGN_REFUSAL);
        expect(filtersSeen.some((f) => f.includes(TASK_ID) && f.includes(OTHER_TASK_ID))).toBe(true);
    });

    it('lets a holder of an ApprovalReassignRoles role reassign', async () => {
        db.settings.set('ApprovalReassignRoles', 'Finance Admin, Integration');
        db.userRoles = [{ ID: 'ur-1' }];
        const result = await saved(OTHER_PERSON).ValidateAsync();
        expect(result.Success).toBe(true);
        expect(filtersSeen).toContain(`MJ: User Roles: UserID = '${USER_ID}' AND Role IN ('Finance Admin', 'Integration')`);
    });

    it('refuses self-assignment even for a holder of an ApprovalReassignRoles role', async () => {
        db.settings.set('ApprovalReassignRoles', 'Finance Admin');
        db.userRoles = [{ ID: 'ur-1' }];
        const result = await saved(MY_PERSON).ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe(SELF_ASSIGN_REFUSAL);
    });

    it('refuses reassignment when the setting names roles the user does not hold', async () => {
        db.settings.set('ApprovalReassignRoles', 'Finance Admin');
        const result = await saved(OTHER_PERSON).ValidateAsync();
        expect(result.Success).toBe(false);
    });

    it('does not check a saved assignment whose assignee did not change', async () => {
        const result = await saved().ValidateAsync();
        expect(result.Success).toBe(true);
        expect(filtersSeen).toEqual([]);
    });

    it('leaves ordinary tasks alone: reassign, self-assign and delete all pass', async () => {
        db.isApproval = false;
        expect((await saved(MY_PERSON).ValidateAsync()).Success).toBe(true);
        expect((await created(MY_PERSON).ValidateAsync()).Success).toBe(true);
        const a = saved();
        expect(await a.Delete()).toBe(true);
        expect(a.deleted).toBe(true);
    });

    it('refuses a business user deleting an approval assignment, with a readable message', async () => {
        const a = saved();
        expect(await a.Delete()).toBe(false);
        expect(a.deleted).toBe(false);
        expect(a.history[0].Message).toBe(REMOVE_REFUSAL);
    });

    it('lets a holder of an ApprovalReassignRoles role delete an approval assignment', async () => {
        db.settings.set('ApprovalReassignRoles', 'Finance Admin');
        db.userRoles = [{ ID: 'ur-1' }];
        const a = saved();
        expect(await a.Delete()).toBe(true);
        expect(a.deleted).toBe(true);
    });

    it('refuses a reassignment or delete with no signed-in user', async () => {
        const moved = saved(OTHER_PERSON);
        moved.ContextCurrentUser = null;
        expect((await moved.ValidateAsync()).Success).toBe(false);
        const removed = saved();
        removed.ContextCurrentUser = null;
        expect(await removed.Delete()).toBe(false);
    });

    it('fails closed when the task cannot be looked up', async () => {
        db.failTaskLookup = true;
        const result = await saved(OTHER_PERSON).ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toMatch(/could not be checked \(database unavailable\)/);
        const a = saved();
        expect(await a.Delete()).toBe(false);
    });
});
