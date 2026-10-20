import { describe, it, expect, vi, beforeEach } from 'vitest';

const runViewMock = vi.fn();
const getEntityObjectMock = vi.fn();

vi.mock('@memberjunction/global', () => ({
    RegisterClass: () => () => {},
    BaseSingleton: class {
        public static getInstance() {
            return {};
        }
    },
    MJGlobal: { Instance: { ClassFactory: { CreateInstance: () => null } } },
}));

vi.mock('@memberjunction/core', () => {
    class ValidationErrorInfo {
        constructor(public Source: string, public Message: string, public Value: unknown, public Type: string) {}
    }
    class BaseEntity {
        public ContextCurrentUser: unknown = { ID: 'U-SAM', UserRoles: [], LinkedEntityID: null, LinkedEntityRecordID: null };
        public IsSaved = false;
        private readonly values: Record<string, unknown> = {};
        public ProviderToUse = { Entities: [] as unknown[], Roles: [] as unknown[], GetEntityObject: (...args: unknown[]) => getEntityObjectMock(...args) };
        public Get(name: string) {
            return this.values[name];
        }
        private readonly olds: Record<string, unknown> = {};
        private readonly dirty = new Set<string>();
        public Set(name: string, value: unknown) {
            if (this.IsSaved && !(name in this.olds)) this.olds[name] = this.values[name];
            this.values[name] = value;
            this.dirty.add(name);
        }
        public get Fields() {
            return Object.keys(this.values).map((name) => ({ CodeName: name, Name: name, Dirty: this.dirty.has(name), OldValue: this.olds[name], Value: this.values[name] }));
        }
        public async ValidateAsync() {
            return { Success: true, Errors: [] as ValidationErrorInfo[] };
        }
        public async Save() {
            this.IsSaved = true;
            return true;
        }
        public async Delete() {
            return true;
        }
        public seed(values: Record<string, unknown>) {
            Object.assign(this.values, values);
            this.IsSaved = true;
            this.dirty.clear();
            return this;
        }
    }
    return {
        BaseEntity,
        ValidationErrorInfo,
        ValidationErrorType: { Failure: 'Failure', Warning: 'Warning' },
        LogError: vi.fn(),
        RunView: { FromMetadataProvider: () => ({ RunView: (...args: unknown[]) => runViewMock(...args) }) },
    };
});

vi.mock('@mj-biz-apps/tasks-entities', async () => {
    const core = await import('@memberjunction/core');
    const Base = core.BaseEntity as unknown as new () => Record<string, unknown>;
    class mjBizAppsTasksMeetingNoteEntity extends Base {}
    for (const field of ['ID', 'MeetingID', 'AgendaItemID', 'Kind', 'Body', 'Source', 'Status', 'AuthorPersonID']) {
        Object.defineProperty(mjBizAppsTasksMeetingNoteEntity.prototype, field, {
            get() {
                return (this as { Get: (n: string) => unknown }).Get(field);
            },
            set(value: unknown) {
                (this as { Set: (n: string, v: unknown) => void }).Set(field, value);
            },
        });
    }
    return { mjBizAppsTasksMeetingNoteEntity, mjBizAppsTasksMeetingEntity: class {} };
});

import { MeetingNoteEntityServer } from '../MeetingNoteEntityServer.js';

const M1 = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F';
// People are ids too: the server checks every id it is handed before it reaches a filter
const P_SAM = '11111111-1111-4111-8111-111111111111';
const P_NICO = '22222222-2222-4222-8222-222222222222';
const P_ADA = '33333333-3333-4333-8333-333333333333';
type Seedable = MeetingNoteEntityServer & { seed(values: Record<string, unknown>): MeetingNoteEntityServer };

let callerPerson: string | null = P_SAM;
let attends = true;
let organizer = P_ADA;

beforeEach(() => {
    runViewMock.mockReset();
    getEntityObjectMock.mockReset();
    callerPerson = P_SAM;
    attends = true;
    organizer = P_ADA;
    runViewMock.mockImplementation(async (params: { EntityName: string }) => {
        if (params.EntityName === 'MJ_BizApps_Common: People') return { Success: true, Results: callerPerson ? [{ ID: callerPerson }] : [] };
        if (params.EntityName === 'MJ_BizApps_Tasks: Meeting Attendees') return { Success: true, Results: attends ? [{ ID: 'A1' }] : [] };
        return { Success: true, Results: [] };
    });
    getEntityObjectMock.mockImplementation(async () => ({ OrganizerPersonID: organizer, Load: async () => true }));
});

const newNote = (): MeetingNoteEntityServer => {
    const note = new MeetingNoteEntityServer();
    note.MeetingID = M1;
    note.Kind = 'Notes';
    note.Body = 'The numbers wait on finance.';
    note.Source = 'Manual';
    note.Status = 'Draft';
    note.AuthorPersonID = null;
    return note;
};
const saved = (author: string): Seedable => (new MeetingNoteEntityServer() as unknown as Seedable).seed({ ID: 'N1', MeetingID: M1, Kind: 'Notes', Body: 'Old', Source: 'Manual', Status: 'Draft', AuthorPersonID: author }) as Seedable;

describe('who writes a note', () => {
    it('lets someone on the meeting write one, stamped with their Person', async () => {
        const note = newNote();
        expect((await note.ValidateAsync()).Success).toBe(true);
        expect(note.AuthorPersonID).toBe(P_SAM);
    });

    it('refuses someone who is not on the meeting, in words', async () => {
        attends = false;
        const result = await newNote().ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe('Only someone on the meeting writes a note on it.');
    });

    it('is the caller\'s own on create whatever author it proposes, unless the organizer writes it for someone', async () => {
        const note = newNote();
        note.AuthorPersonID = P_NICO;
        expect((await note.ValidateAsync()).Success).toBe(true);
        expect(note.AuthorPersonID).toBe(P_SAM);
        callerPerson = P_ADA;
        const byOrganizer = newNote();
        byOrganizer.AuthorPersonID = P_NICO;
        expect((await byOrganizer.ValidateAsync()).Success).toBe(true);
        expect(byOrganizer.AuthorPersonID).toBe(P_NICO);
    });

    it('judges the author by what the database holds, and keeps it', async () => {
        const other = saved(P_NICO);
        other.AuthorPersonID = P_SAM; // the caller re-stamps the note as their own
        other.Body = 'Tampered';
        const result = await other.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe('Only its author or the organizer changes a note.');
        const own = saved(P_SAM);
        own.AuthorPersonID = P_NICO; // the author hands it to someone else
        expect((await own.ValidateAsync()).Errors[0].Message).toBe('A note keeps its author; the organizer may change it.');
    });

    it('does not move to another meeting unless the caller organizes both', async () => {
        const own = saved(P_SAM);
        own.MeetingID = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5E';
        expect((await own.ValidateAsync()).Errors[0].Message).toMatch(/moves to another meeting only at the organizer/);
    });

    it('lets the author or the organizer change and remove it, nobody else', async () => {
        const own = saved(P_SAM);
        own.Body = 'Revised';
        expect((await own.ValidateAsync()).Success).toBe(true);
        const other = saved(P_NICO);
        other.Body = 'Tampered';
        expect((await other.ValidateAsync()).Errors[0].Message).toBe('Only its author or the organizer changes a note.');
        await expect(saved(P_NICO).Delete()).rejects.toThrow(/Only its author or the organizer removes a note/);
        callerPerson = P_ADA;
        expect((await saved(P_NICO).ValidateAsync()).Success).toBe(true);
        expect(await saved(P_NICO).Delete()).toBe(true);
    });
});
