import { beforeEach, describe, expect, it, vi } from 'vitest';

const PEOPLE_ID = 'A0000000-0000-0000-0000-000000000001';
const USERS_ID = 'A0000000-0000-0000-0000-000000000002';
const ROLES_ID = 'A0000000-0000-0000-0000-000000000003';
const QUEUE_ROLE = 'A1000000-0000-0000-0000-000000000001';
const APP_ID = 'A0000000-0000-0000-0000-0000000000AA';
const TASK_ID = 'D0000000-0000-0000-0000-000000000001';
const OTHER_TASK_ID = 'D0000000-0000-0000-0000-000000000002';
const TYPE_ID = 'E0000000-0000-0000-0000-000000000001';
const USER_ID = 'B0000000-0000-0000-0000-000000000001';
const MY_PERSON = 'C0000000-0000-0000-0000-000000000001';
const CEO_PERSON = 'C0000000-0000-0000-0000-000000000002';
const OTHER_PERSON = 'C0000000-0000-0000-0000-000000000003';

/** What the fake database returns, per entity. */
const logError = vi.hoisted(() => vi.fn());

const db = {
    settings: new Map<string, string>(),
    isApproval: true,
    people: [{ ID: MY_PERSON }],
    userRoles: [] as Array<{ ID: string; Role: string; RoleID?: string }>,
    roles: ['Finance Admin', 'Integration'],
    failTaskLookup: false,
    /** Who asked for the approval: someone else unless a test says the signed-in user did. */
    taskCreator: CEO_PERSON as string | null,
    taskStatus: 'Open',
    /** False when the signed-in user may not read the task (row-level security hides it). */
    taskReadable: true,
    systemUser: false,
};
const filtersSeen: string[] = [];

function viewResult(entityName: string, filter: string): { Success: boolean; Results: unknown[]; ErrorMessage?: string } {
    filtersSeen.push(`${entityName}: ${filter}`);
    switch (entityName) {
        case 'MJ_BizApps_Tasks: Tasks':
            if (db.failTaskLookup) return { Success: false, Results: [], ErrorMessage: 'database unavailable' };
            return { Success: true, Results: db.taskReadable ? [{ ID: TASK_ID, TypeID: TYPE_ID, CreatedByPersonID: db.taskCreator, Status: db.taskStatus }] : [] };
        case 'MJ_BizApps_Tasks: Task Types': return { Success: true, Results: [{ IsApproval: db.isApproval }] };
        case 'MJ_BizApps_Common: People': return { Success: true, Results: db.people };
        case 'MJ: User Roles': return { Success: true, Results: userRolesMatching(filter) };
        case 'MJ: Roles': return { Success: true, Results: db.roles.map((Name) => ({ Name })) };
        default: return { Success: false, Results: [], ErrorMessage: `unexpected entity ${entityName}` };
    }
}

/** A user's roles, filtered as a case-sensitive collation would apply a `Role IN (...)` clause. */
function userRolesMatching(filter: string): Array<{ ID: string; Role: string; RoleID?: string }> {
    const inList = /Role IN \((.*)\)/.exec(filter)?.[1];
    if (!inList) return db.userRoles;
    const names = inList.split(',').map((n) => n.trim().replace(/^'|'$/g, ''));
    return db.userRoles.filter((r) => names.includes(r.Role));
}

vi.mock('@memberjunction/global', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/global')>();
    return {
        ...actual,
        RegisterClass: () => () => {},
    };
});

vi.mock('@mj-biz-apps/common-entities', () => ({
    BusinessTimeZoneEngine: { Instance: {} },
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
        EntityByName: (name: string) => (name === 'MJ: Users' ? { ID: USERS_ID } : name === 'MJ: Roles' ? { ID: ROLES_ID } : null),
    };
    return {
        BaseEntity: class {},
        BaseEngine: class {
            public static getInstance() {
                return {};
            }
        },
        RegisterForStartup: () => () => {},
        BaseRemotableOperation: class {},
        BaseEntityResult,
        CompositeKey: class { constructor(public KeyValuePairs: unknown[]) {} },
        LogError: logError,
        LogStatus: vi.fn(),
        Metadata: { Provider: provider },
        RunView: class {
            async RunView(p: { EntityName: string; ExtraFilter: string }) {
                return viewResult(p.EntityName, p.ExtraFilter);
            }
        },
        UserInfo: class {},
        ValidationResult,
        ValidationErrorInfo,
        WellKnownUserSource: { Instance: { IsSystemUser: () => db.systemUser } },
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
        ContextCurrentUser: { ID: string; UserRoles?: Array<{ RoleID: string }> } | null = { ID: USER_ID };
        old = new Map<string, string>();
        history: Array<{ Success: boolean; Message: string }> = [];
        deleted = false;
        /** As BaseEntity.Save: validates through the subclass, and writes only a valid record. */
        async Save() {
            return (await this.ValidateAsync()).Success;
        }
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
const { ADD_ASSIGNEE_REFUSAL, ADD_ASSIGNEE_NO_USER_REFUSAL } = await import('../ApprovalTaskAuthority.js');
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
        db.roles = ['Finance Admin', 'Integration'];
        logError.mockClear();
        db.failTaskLookup = false;
        db.taskCreator = CEO_PERSON;
        db.taskStatus = 'Open';
        db.taskReadable = true;
        db.systemUser = false;
        filtersSeen.length = 0;
    });

    it('opts in to async validation so the rule always runs', () => {
        expect(created(OTHER_PERSON).DefaultSkipAsyncValidation).toBe(false);
    });

    describe('adding an assignee to an approval task (bizapps-tasks#209)', () => {
        it('refuses a user making themselves an assignee of an approval they did not ask for', async () => {
            const asPerson = await created(MY_PERSON).ValidateAsync();
            expect(asPerson.Success).toBe(false);
            expect(asPerson.Errors[0].Message).toBe(SELF_ASSIGN_REFUSAL);

            const asUser = await created(USER_ID, USERS_ID).ValidateAsync();
            expect(asUser.Errors[0]?.Message).toBe(SELF_ASSIGN_REFUSAL);
        });

        it('refuses a user assigning the approval to a role queue they are in', async () => {
            db.userRoles = [{ ID: 'ur-1', Role: 'Approvers', RoleID: QUEUE_ROLE }];
            const result = await created(QUEUE_ROLE, ROLES_ID).ValidateAsync();
            expect(result.Errors[0]?.Message).toBe(SELF_ASSIGN_REFUSAL);
        });

        it('counts a role the session already carries, even before the database row is read', async () => {
            const a = created(QUEUE_ROLE, ROLES_ID);
            a.ContextCurrentUser = { ID: USER_ID, UserRoles: [{ RoleID: QUEUE_ROLE.toLowerCase() }] };
            expect((await a.ValidateAsync()).Errors[0]?.Message).toBe(SELF_ASSIGN_REFUSAL);
        });

        it('lets a user assign the approval to a role queue they are not in', async () => {
            expect((await created(QUEUE_ROLE, ROLES_ID).ValidateAsync()).Success).toBe(true);
        });

        it('refuses self-assignment even for a holder of an ApprovalReassignRoles role', async () => {
            db.settings.set('ApprovalReassignRoles', 'Finance Admin');
            db.userRoles = [{ ID: 'ur-1', Role: 'Finance Admin' }];
            expect((await created(MY_PERSON).ValidateAsync()).Errors[0]?.Message).toBe(SELF_ASSIGN_REFUSAL);
        });

        it('lets the requester name who they are asking, whatever ApprovalReassignRoles says', async () => {
            db.taskCreator = MY_PERSON;
            db.settings.set('ApprovalReassignRoles', 'Finance Admin');
            expect((await created(CEO_PERSON).ValidateAsync()).Success).toBe(true);
            expect(filtersSeen.some((f) => f.startsWith('MJ: User Roles'))).toBe(false);
        });

        it('lets the requester name themselves: the decision rule refuses them their own request (order review, a CFO-built batch)', async () => {
            db.taskCreator = MY_PERSON.toLowerCase();
            expect((await created(MY_PERSON).ValidateAsync()).Success).toBe(true);
            expect((await created(USER_ID, USERS_ID).ValidateAsync()).Success).toBe(true);
        });

        it('stops treating the requester specially once the approval is closed', async () => {
            db.taskCreator = MY_PERSON;
            db.settings.set('ApprovalReassignRoles', 'Finance Admin');
            for (const status of ['Completed', 'Cancelled']) {
                db.taskStatus = status;
                expect((await created(MY_PERSON).ValidateAsync()).Errors[0]?.Message).toBe(SELF_ASSIGN_REFUSAL);
                expect((await created(OTHER_PERSON).ValidateAsync()).Errors[0]?.Message).toBe(ADD_ASSIGNEE_REFUSAL);
            }
        });

        it('lets anyone add someone else while ApprovalReassignRoles is empty, as for a reassignment', async () => {
            expect((await created(OTHER_PERSON).ValidateAsync()).Success).toBe(true);
        });

        it('needs the reassign right to add someone else to an approval the user did not ask for', async () => {
            db.settings.set('ApprovalReassignRoles', 'Finance Admin');
            const refused = await created(OTHER_PERSON).ValidateAsync();
            expect(refused.Success).toBe(false);
            expect(refused.Errors[0].Message).toBe(ADD_ASSIGNEE_REFUSAL);

            db.userRoles = [{ ID: 'ur-1', Role: 'Finance Admin' }];
            expect((await created(OTHER_PERSON).ValidateAsync()).Success).toBe(true);
        });

        it('lets server code that chose the assignee vouch for one save, and only one', async () => {
            db.settings.set('ApprovalReassignRoles', 'Finance Admin');
            const a = created(MY_PERSON);
            a.AuthorizeApprovalAssignment();
            expect(await a.Save()).toBe(true);
            expect(filtersSeen).toEqual([]);
            expect(await a.Save()).toBe(false);
        });

        it('spends the vouching even when the save it covered throws', async () => {
            const a = created(MY_PERSON);
            a.AuthorizeApprovalAssignment();
            db.taskReadable = true;
            const base = Object.getPrototypeOf(TaskAssignmentEntityServer.prototype) as { Save: () => Promise<boolean> };
            const realSave = base.Save;
            base.Save = async () => { throw new Error('connection lost'); };
            try {
                await expect(a.Save()).rejects.toThrow('connection lost');
            } finally {
                base.Save = realSave;
            }
            expect(await a.Save()).toBe(false);
        });

        it('accepts the system user without reading anything', async () => {
            db.systemUser = true;
            db.settings.set('ApprovalReassignRoles', 'Finance Admin');
            expect((await created(MY_PERSON).ValidateAsync()).Success).toBe(true);
            expect(filtersSeen).toEqual([]);
        });

        it('refuses adding an approval assignment with no signed-in user', async () => {
            const a = created(OTHER_PERSON);
            a.ContextCurrentUser = null;
            const result = await a.ValidateAsync();
            expect(result.Errors[0]?.Message).toBe(ADD_ASSIGNEE_NO_USER_REFUSAL);
        });

        it('refuses an assignment on a task the user may not read, rather than passing it as not an approval', async () => {
            db.taskReadable = false;
            const result = await created(OTHER_PERSON).ValidateAsync();
            expect(result.Success).toBe(false);
            expect(result.Errors[0].Message).toMatch(/was not saved.*its task was not found, or you may not read it/);
        });

        it('fails closed when the task cannot be looked up', async () => {
            db.failTaskLookup = true;
            const result = await created(OTHER_PERSON).ValidateAsync();
            expect(result.Success).toBe(false);
            expect(result.Errors[0].Message).toMatch(/could not be checked \(database unavailable\)/);
        });

        it('leaves an ordinary task alone: anyone may be added, the user included', async () => {
            db.isApproval = false;
            db.settings.set('ApprovalReassignRoles', 'Finance Admin');
            expect((await created(MY_PERSON).ValidateAsync()).Success).toBe(true);
            expect((await created(OTHER_PERSON).ValidateAsync()).Success).toBe(true);
            expect(filtersSeen.some((f) => f.startsWith('MJ_BizApps_Common: People'))).toBe(false);
        });
    });

    it('refuses reassigning an approval to a role queue the user is in', async () => {
        db.userRoles = [{ ID: 'ur-1', Role: 'Approvers', RoleID: QUEUE_ROLE }];
        const a = saved();
        a.old.set('AssigneeEntityID', PEOPLE_ID);
        a.AssigneeEntityID = ROLES_ID;
        a.AssigneeRecordID = QUEUE_ROLE;
        expect((await a.ValidateAsync()).Errors[0]?.Message).toBe(SELF_ASSIGN_REFUSAL);
    });

    it('switches the role rule off while ApprovalReassignRoles is absent, empty or blank', async () => {
        for (const value of [undefined, '', '  ,  ']) {
            db.settings = new Map();
            if (value !== undefined) db.settings.set('ApprovalReassignRoles', value);
            expect((await saved(OTHER_PERSON).ValidateAsync()).Success).toBe(true);
            const a = saved();
            expect(await a.Delete()).toBe(true);
            expect(a.deleted).toBe(true);
        }
        expect(filtersSeen.some((f) => f.startsWith('MJ: User Roles'))).toBe(false);
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
        db.settings.set('ApprovalReassignRoles', 'Finance Admin');
        const result = await saved(OTHER_PERSON).ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe(REASSIGN_REFUSAL);
    });

    it('refuses a business user reassigning an approval to themselves, with the setting empty', async () => {
        const result = await saved(MY_PERSON).ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe(SELF_ASSIGN_REFUSAL);
    });

    it('refuses moving an approval assignment onto another task', async () => {
        db.settings.set('ApprovalReassignRoles', 'Finance Admin');
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
        db.userRoles = [{ ID: 'ur-1', Role: 'Integration' }];
        const result = await saved(OTHER_PERSON).ValidateAsync();
        expect(result.Success).toBe(true);
        expect(filtersSeen).toContain(`MJ: User Roles: UserID = '${USER_ID}'`);
    });

    it('matches role names trimmed and case-insensitively, whatever the database collation', async () => {
        db.settings.set('ApprovalReassignRoles', ' finance admin ,cfo');
        db.roles = ['Finance Admin', 'CFO'];
        db.userRoles = [{ ID: 'ur-1', Role: 'Finance Admin' }];
        const result = await saved(OTHER_PERSON).ValidateAsync();
        expect(result.Success).toBe(true);
        expect(logError).not.toHaveBeenCalled();
    });

    it('logs one warning naming the configured roles that do not exist, and refuses', async () => {
        db.settings.set('ApprovalReassignRoles', 'Senior Finance, Finance Admin, Nobody');
        db.userRoles = [{ ID: 'ur-1', Role: 'UI' }];
        const result = await saved(OTHER_PERSON).ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe(REASSIGN_REFUSAL);
        expect(logError).toHaveBeenCalledTimes(1);
        expect(logError.mock.calls[0][0]).toContain("'Senior Finance', 'Nobody', which are not roles");
    });

    it('refuses self-assignment even for a holder of an ApprovalReassignRoles role', async () => {
        db.settings.set('ApprovalReassignRoles', 'Finance Admin');
        db.userRoles = [{ ID: 'ur-1', Role: 'Finance Admin' }];
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
        db.settings.set('ApprovalReassignRoles', 'Finance Admin');
        const a = saved();
        expect(await a.Delete()).toBe(false);
        expect(a.deleted).toBe(false);
        expect(a.history[0].Message).toBe(REMOVE_REFUSAL);
    });

    it('lets a holder of an ApprovalReassignRoles role delete an approval assignment', async () => {
        db.settings.set('ApprovalReassignRoles', 'Finance Admin');
        db.userRoles = [{ ID: 'ur-1', Role: 'Finance Admin' }];
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
        db.settings.set('ApprovalReassignRoles', 'Finance Admin');
        db.failTaskLookup = true;
        const result = await saved(OTHER_PERSON).ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toMatch(/could not be checked \(database unavailable\)/);
        const a = saved();
        expect(await a.Delete()).toBe(false);
    });
});
