/**
 * TaskEntityServer creator integrity: the no-self-approval rule compares deciders against
 * Task.CreatedByPersonID, so a task must record its creator even when the caller never passes one
 * (bizapps-orders' access-override request, bizapps-marketing's strategy approval), and a recorded
 * creator must not be editable away afterwards.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

const PEOPLE_ID = 'A0000000-0000-0000-0000-000000000001';
const USER_ID = 'B0000000-0000-0000-0000-000000000001';
const PERSON_ID = 'C0000000-0000-0000-0000-000000000001';
const LINKED_PERSON = 'C0000000-0000-0000-0000-000000000002';
const OTHER_PERSON = 'C0000000-0000-0000-0000-000000000003';

const people = {
    results: [{ ID: PERSON_ID }] as Array<{ ID: string }>,
    fail: false,
    filters: [] as string[],
};
const superSave = vi.fn(async () => true);

vi.mock('@memberjunction/global', () => ({
    RegisterClass: () => () => {},
    IsValidUUID: (v: string) => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v),
}));

vi.mock('@memberjunction/core', () => {
    class ValidationErrorInfo { constructor(public Source: string, public Message: string, public Value: unknown, public Type?: string) {} }
    const provider = {
        EntityByID: (id: string) => (id === PEOPLE_ID ? { Name: 'MJ_BizApps_Common: People', ParentChain: [] } : null),
    };
    return {
        BaseEntity: class {
            public ContextCurrentUser: { ID: string; LinkedEntityID?: string; LinkedEntityRecordID?: string } | null = { ID: USER_ID };
            public Fields: Array<{ CodeName: string; Dirty: boolean; Value: unknown; OldValue: unknown }> = [];
            public IsSaved = false;
            public RunViewProviderToUse = {};
            private _fieldValues: Record<string, unknown> = {};
            public Get(fieldName: string) { return this._fieldValues[fieldName]; }
            public Set(fieldName: string, value: unknown) { this._fieldValues[fieldName] = value; }
            public GetAll() { return { ...this._fieldValues }; }
            public RegisterEventHandler() {}
            public Validate() { return { Success: true, Errors: [] as Array<{ Source: string; Message: string }> }; }
            public async Save() { return superSave(); }
        },
        BaseEngine: class { public static getInstance() { return {}; } },
        LogError: vi.fn(),
        LogStatus: vi.fn(),
        Metadata: class {
            public static Provider = provider;
            public async GetEntityObject() {
                return { NewRecord: vi.fn(), Save: vi.fn().mockResolvedValue(true), Load: vi.fn().mockResolvedValue(true) };
            }
        },
        RunView: class {
            public async RunView(p: { EntityName: string; ExtraFilter: string }) {
                if (p.EntityName !== 'MJ_BizApps_Common: People') return { Success: true, Results: [] };
                people.filters.push(p.ExtraFilter);
                return people.fail ? { Success: false, Results: [], ErrorMessage: 'database unavailable' } : { Success: true, Results: people.results };
            }
        },
        ValidationErrorInfo,
        ValidationErrorType: { Failure: 'Failure', Warning: 'Warning' },
    };
});

vi.mock('@memberjunction/actions', () => ({
    ActionEngineServer: { Instance: { Config: vi.fn().mockResolvedValue(undefined), Actions: [], RunAction: vi.fn() } },
}));

vi.mock('@mj-biz-apps/tasks-core', () => ({
    TaskService: class { public async rollupParentProgress() { return true; } },
}));

const { TaskEntityServer } = await import('../TaskEntityServer.js');

type Server = InstanceType<typeof TaskEntityServer>;

/** A new task with no type, so the status sync and lifecycle hooks around the creator stamp are no-ops. */
function newTask(): Server {
    const t = new TaskEntityServer();
    t.Name = 'Approve access override';
    return t;
}

function creatorField(t: Server, oldValue: string | null, value: string | null): void {
    t.Fields = [{ CodeName: 'CreatedByPersonID', Dirty: oldValue !== value, Value: value, OldValue: oldValue }];
    t.CreatedByPersonID = value;
}

describe('TaskEntityServer — recording the creator', () => {
    beforeEach(() => {
        people.results = [{ ID: PERSON_ID }];
        people.fail = false;
        people.filters = [];
        superSave.mockClear();
    });

    it("records the signed-in user's Person when the caller passes no creator", async () => {
        const t = newTask();
        expect(await t.Save()).toBe(true);
        expect(t.CreatedByPersonID).toBe(PERSON_ID);
        expect(people.filters).toEqual([`LinkedUserID = '${USER_ID}'`]);
    });

    it("prefers the user's own People link over other Persons linked back to them", async () => {
        const t = newTask();
        t.ContextCurrentUser = { ID: USER_ID, LinkedEntityID: PEOPLE_ID, LinkedEntityRecordID: LINKED_PERSON };
        people.results = [{ ID: PERSON_ID }, { ID: LINKED_PERSON.toLowerCase() }];
        await t.Save();
        expect(t.CreatedByPersonID).toBe(LINKED_PERSON.toLowerCase());
        expect(people.filters).toEqual([`LinkedUserID = '${USER_ID}' OR ID = '${LINKED_PERSON}'`]);
    });

    it('keeps a creator the caller supplied, without a lookup (accounting records the batch builder)', async () => {
        const t = newTask();
        t.CreatedByPersonID = OTHER_PERSON;
        await t.Save();
        expect(t.CreatedByPersonID).toBe(OTHER_PERSON);
        expect(people.filters).toEqual([]);
    });

    it('leaves the creator unset for a user with no Person', async () => {
        const t = newTask();
        people.results = [];
        expect(await t.Save()).toBe(true);
        expect(t.CreatedByPersonID ?? null).toBeNull();
    });

    it('does not look anything up when saving an existing task', async () => {
        const t = newTask();
        t.IsSaved = true;
        await t.Save();
        expect(people.filters).toEqual([]);
    });

    it('fails closed: the task is not created when its creator cannot be looked up', async () => {
        const t = newTask();
        people.fail = true;
        await expect(t.Save()).rejects.toThrow(/creator could not be recorded \(database unavailable\)/);
        expect(superSave).not.toHaveBeenCalled();
    });
});

describe('TaskEntityServer — a recorded creator cannot change', () => {
    it('refuses clearing a recorded creator', () => {
        const t = newTask();
        t.IsSaved = true;
        creatorField(t, PERSON_ID, null);
        const result = t.Validate();
        expect(result.Success).toBe(false);
        expect(result.Errors.map((e) => e.Message)).toContain("A task's creator cannot be changed once it is recorded.");
    });

    it('refuses replacing a recorded creator with someone else', () => {
        const t = newTask();
        t.IsSaved = true;
        creatorField(t, PERSON_ID, OTHER_PERSON);
        expect(t.Validate().Success).toBe(false);
    });

    it('allows recording a creator on a task that never had one', () => {
        const t = newTask();
        t.IsSaved = true;
        creatorField(t, null, OTHER_PERSON);
        expect(t.Validate().Success).toBe(true);
    });

    it('treats a change of case only as no change', () => {
        const t = newTask();
        t.IsSaved = true;
        t.Fields = [{ CodeName: 'CreatedByPersonID', Dirty: true, Value: PERSON_ID.toLowerCase(), OldValue: PERSON_ID }];
        expect(t.Validate().Success).toBe(true);
    });

    it('allows any creator on a new task', () => {
        const t = newTask();
        creatorField(t, null, OTHER_PERSON);
        expect(t.Validate().Success).toBe(true);
    });
});
