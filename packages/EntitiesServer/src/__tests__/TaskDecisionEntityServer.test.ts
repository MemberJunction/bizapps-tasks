import { beforeEach, describe, expect, it, vi } from 'vitest';

const PEOPLE_ID = 'A0000000-0000-0000-0000-000000000001';
const USERS_ID = 'A0000000-0000-0000-0000-000000000002';
const APP_ID = 'A0000000-0000-0000-0000-0000000000AA';
const TASK_ID = 'D0000000-0000-0000-0000-000000000001';
const TYPE_ID = 'E0000000-0000-0000-0000-000000000001';
const USER_ID = 'B0000000-0000-0000-0000-000000000001';
const PERSON_ID = 'C0000000-0000-0000-0000-000000000001';
const OTHER_PERSON = 'C0000000-0000-0000-0000-000000000002';
const ROLE_ID = 'F0000000-0000-0000-0000-000000000001';

/** What the fake database returns, per entity. */
const db = {
    settings: new Map<string, string>(),
    task: { ID: TASK_ID, TypeID: TYPE_ID, CreatedByPersonID: OTHER_PERSON as string | null },
    isApproval: true,
    assignments: [{ ID: 'asg-1', AssigneeEntityID: PEOPLE_ID, AssigneeRecordID: PERSON_ID, Status: 'Pending' as 'Pending' | 'InProgress' | 'Completed' }],
    people: [{ ID: PERSON_ID }],
    roles: [{ ID: ROLE_ID }],
    userRoles: [] as Array<{ ID: string }>,
    failTaskLookup: false,
};
const filtersSeen: string[] = [];
const fieldsSeen = new Map<string, string[]>();

function viewResult(entityName: string, filter: string, fields?: string[]): { Success: boolean; Results: unknown[]; ErrorMessage?: string } {
    filtersSeen.push(`${entityName}: ${filter}`);
    if (fields) fieldsSeen.set(entityName, fields);
    switch (entityName) {
        case 'MJ_BizApps_Tasks: Tasks':
            return db.failTaskLookup ? { Success: false, Results: [], ErrorMessage: 'database unavailable' } : { Success: true, Results: [db.task] };
        case 'MJ_BizApps_Tasks: Task Assignments': return { Success: true, Results: db.assignments };
        case 'MJ_BizApps_Common: People': return { Success: true, Results: db.people };
        case 'MJ_BizApps_Tasks: Task Types': return { Success: true, Results: [{ IsApproval: db.isApproval }] };
        case 'MJ: Roles': return { Success: true, Results: db.roles };
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
    const provider = {
        Applications: [{ Name: 'Tasks', ID: APP_ID }],
        EntityByID: (id: string) => (id === PEOPLE_ID ? { Name: 'MJ_BizApps_Common: People', ParentChain: [] } : id === USERS_ID ? { Name: 'MJ: Users', ParentChain: [] } : null),
        EntityByName: (name: string) => (name === 'MJ: Users' ? { ID: USERS_ID } : null),
    };
    return {
        BaseEntity: class {},
        LogError: vi.fn(),
        Metadata: { Provider: provider },
        RunView: class {
            async RunViews(params: Array<{ EntityName: string; ExtraFilter: string; Fields?: string[] }>) {
                return params.map((p) => viewResult(p.EntityName, p.ExtraFilter, p.Fields));
            }
            async RunView(p: { EntityName: string; ExtraFilter: string; Fields?: string[] }) {
                return viewResult(p.EntityName, p.ExtraFilter, p.Fields);
            }
        },
        ValidationResult,
        ValidationErrorInfo,
    };
});

vi.mock('@mj-biz-apps/tasks-entities', () => ({
    mjBizAppsTasksTaskDecisionEntity: class {
        TaskID = TASK_ID;
        OutcomeID = 'outcome-approved';
        DecidedByPersonID: string | null = PERSON_ID;
        TaskAssignmentID: string | null = null;
        IsSaved = false;
        RunViewProviderToUse = {};
        ContextCurrentUser: { ID: string; LinkedEntityID?: string; LinkedEntityRecordID?: string } | null = { ID: USER_ID };
        dirty = new Set<string>();
        GetFieldByName(name: string) { return { Dirty: this.dirty.has(name) }; }
        async ValidateAsync() {
            return { Success: true, Errors: [] as Array<{ Message: string }> };
        }
    },
}));

const { TaskDecisionEntityServer } = await import('../TaskDecisionEntityServer.js');
const { TasksSettings } = await import('../TasksSettings.js');

function decision(): InstanceType<typeof TaskDecisionEntityServer> {
    return new TaskDecisionEntityServer();
}

describe('TaskDecisionEntityServer', () => {
    beforeEach(() => {
        db.settings = new Map([['PreventSelfApproval', 'true']]);
        db.task = { ID: TASK_ID, TypeID: TYPE_ID, CreatedByPersonID: OTHER_PERSON };
        db.isApproval = true;
        db.assignments = [{ ID: 'asg-1', AssigneeEntityID: PEOPLE_ID, AssigneeRecordID: PERSON_ID, Status: 'Pending' }];
        db.people = [{ ID: PERSON_ID }];
        db.roles = [{ ID: ROLE_ID }];
        db.userRoles = [];
        db.failTaskLookup = false;
        filtersSeen.length = 0;
        fieldsSeen.clear();
    });

    it('opts in to async validation so the rule always runs', () => {
        expect(decision().DefaultSkipAsyncValidation).toBe(false);
    });

    it('enforces the guard by default: an unset PreventSelfApproval still refuses the creator', async () => {
        db.settings = new Map();
        db.task.CreatedByPersonID = PERSON_ID;
        const result = await decision().ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toMatch(/Nobody may approve their own request/);
    });

    it('reads nothing and accepts only when PreventSelfApproval is explicitly false', async () => {
        db.settings = new Map([['PreventSelfApproval', 'false']]);
        db.task.CreatedByPersonID = PERSON_ID;
        const result = await decision().ValidateAsync();
        expect(result.Success).toBe(true);
        expect(filtersSeen).toEqual([]);
    });

    it('accepts an assignee deciding a task someone else created', async () => {
        const result = await decision().ValidateAsync();
        expect(result.Success).toBe(true);
    });

    it('refuses the creator of the task', async () => {
        db.task.CreatedByPersonID = PERSON_ID;
        const result = await decision().ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toMatch(/Nobody may approve their own request/);
    });

    it('lets the creator decide when they hold the SelfApprovalExemptRole role', async () => {
        db.task.CreatedByPersonID = PERSON_ID;
        db.settings.set('SelfApprovalExemptRole', 'Exempt Approver');
        db.userRoles = [{ ID: 'ur-1' }];
        const result = await decision().ValidateAsync();
        expect(result.Success).toBe(true);
        expect(filtersSeen.some((f) => f.startsWith("MJ: Roles: Name = 'Exempt Approver'"))).toBe(true);
    });

    it('exempts nobody when the named exempt role does not exist', async () => {
        db.task.CreatedByPersonID = PERSON_ID;
        db.settings.set('SelfApprovalExemptRole', 'No Such Role');
        db.roles = [];
        const result = await decision().ValidateAsync();
        expect(result.Success).toBe(false);
    });

    it('refuses someone who is not assigned', async () => {
        db.assignments = [{ ID: 'asg-2', AssigneeEntityID: PEOPLE_ID, AssigneeRecordID: OTHER_PERSON, Status: 'Pending' }];
        const result = await decision().ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toMatch(/not assigned to you/);
    });

    it('refuses an assignee whose assignment is already Completed (and reads the assignment status to know)', async () => {
        db.assignments = [{ ID: 'asg-1', AssigneeEntityID: PEOPLE_ID, AssigneeRecordID: PERSON_ID, Status: 'Completed' }];
        const result = await decision().ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toMatch(/already completed/);
        expect(fieldsSeen.get('MJ_BizApps_Tasks: Task Assignments')).toContain('Status');
    });

    it('does not check a task whose type is not an approval type', async () => {
        db.isApproval = false;
        db.assignments = [];
        const result = await decision().ValidateAsync();
        expect(result.Success).toBe(true);
    });

    it("includes the user's own People link when looking up the decider's persons", async () => {
        const d = decision();
        d.ContextCurrentUser = { ID: USER_ID, LinkedEntityID: PEOPLE_ID, LinkedEntityRecordID: OTHER_PERSON };
        await d.ValidateAsync();
        expect(filtersSeen).toContain(`MJ_BizApps_Common: People: LinkedUserID = '${USER_ID}' OR ID = '${OTHER_PERSON}'`);
    });

    it('fails closed with a message when a lookup fails', async () => {
        db.failTaskLookup = true;
        const result = await decision().ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toMatch(/could not be checked \(database unavailable\)/);
    });

    it('refuses a save with no signed-in user while the guard is on', async () => {
        const d = decision();
        d.ContextCurrentUser = null;
        const result = await d.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toMatch(/without a signed-in user/);
    });

    it('refuses a save with no signed-in user even when the setting is unset (fails closed by default)', async () => {
        db.settings = new Map();
        const d = decision();
        d.ContextCurrentUser = null;
        const result = await d.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toMatch(/without a signed-in user/);
    });

    it('does not re-check a saved decision whose checked fields did not change', async () => {
        const d = decision();
        d.IsSaved = true;
        db.task.CreatedByPersonID = PERSON_ID;
        const result = await d.ValidateAsync();
        expect(result.Success).toBe(true);
        expect(filtersSeen).toEqual([]);
    });

    it('re-checks a saved decision whose decider changed', async () => {
        const d = decision();
        d.IsSaved = true;
        d.dirty.add('DecidedByPersonID');
        d.DecidedByPersonID = OTHER_PERSON;
        const result = await d.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toMatch(/someone other than you/);
    });

    it('refuses an ID that is not a UUID before it reaches a filter', async () => {
        const d = decision();
        d.TaskID = "x' OR 1=1 --";
        const result = await d.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toMatch(/is not a valid ID/);
        expect(filtersSeen).toEqual([]);
    });
});
