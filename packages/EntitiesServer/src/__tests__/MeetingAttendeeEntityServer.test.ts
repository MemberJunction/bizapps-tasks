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
        public ContextCurrentUser: { ID: string; UserRoles: unknown[]; LinkedEntityID: null; LinkedEntityRecordID: null } = { ID: 'U-SAM', UserRoles: [], LinkedEntityID: null, LinkedEntityRecordID: null };
        public IsSaved = false;
        private readonly values: Record<string, unknown> = {};
        private readonly olds: Record<string, unknown> = {};
        private readonly dirty = new Set<string>();
        public ProviderToUse = { Entities: [] as unknown[], Roles: [] as unknown[], GetEntityObject: (...args: unknown[]) => getEntityObjectMock(...args) };
        public Get(name: string) {
            return this.values[name];
        }
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
            this.dirty.clear();
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
        LogStatus: vi.fn(),
        Metadata: class {},
        RunView: { FromMetadataProvider: () => ({ RunView: (...args: unknown[]) => runViewMock(...args) }) },
    };
});

vi.mock('@mj-biz-apps/tasks-entities', async () => {
    const core = await import('@memberjunction/core');
    const Base = core.BaseEntity as unknown as new () => Record<string, unknown>;
    const fields = ['ID', 'MeetingID', 'SeriesID', 'PersonID', 'UserID', 'Email', 'DisplayName', 'Role', 'ResponseStatus', 'RespondedAt', 'AttendanceStatus', 'JoinedAt', 'LeftAt', 'Notes'];
    const withFields = (cls: new () => Record<string, unknown>) => {
        for (const field of fields) {
            Object.defineProperty(cls.prototype, field, {
                get() {
                    return (this as { Get: (n: string) => unknown }).Get(field);
                },
                set(value: unknown) {
                    (this as { Set: (n: string, v: unknown) => void }).Set(field, value);
                },
            });
        }
        return cls;
    };
    return {
        mjBizAppsTasksMeetingAttendeeEntity: withFields(class extends Base {}),
        mjBizAppsTasksMeetingSeriesAttendeeEntity: withFields(class extends Base {}),
        mjBizAppsTasksMeetingEntity: class {},
        mjBizAppsTasksMeetingSeriesEntity: class {},
    };
});

import { MeetingAttendeeEntityServer, MeetingSeriesAttendeeEntityServer } from '../MeetingAttendeeEntityServer.js';

type Seedable = MeetingAttendeeEntityServer & { seed(values: Record<string, unknown>): MeetingAttendeeEntityServer; ContextCurrentUser: { ID: string; UserRoles: unknown[]; LinkedEntityID: null; LinkedEntityRecordID: null } };

/** The caller's Person (through People.LinkedUserID) and the meeting the row belongs to, per test. */
let callerPerson: string | null = 'P-ADA';
let meeting: { OrganizerPersonID: string; found: boolean } = { OrganizerPersonID: 'P-ADA', found: true };

beforeEach(() => {
    runViewMock.mockReset();
    getEntityObjectMock.mockReset();
    callerPerson = 'P-ADA';
    meeting = { OrganizerPersonID: 'P-ADA', found: true };
    runViewMock.mockImplementation(async (params: { EntityName: string; ExtraFilter: string }) => {
        if (params.EntityName === 'MJ_BizApps_Common: People' && params.ExtraFilter.startsWith('LinkedUserID')) return { Success: true, Results: callerPerson ? [{ ID: callerPerson }] : [] };
        if (params.EntityName === 'MJ_BizApps_Common: People') return { Success: true, Results: [{ LinkedUserID: '2F0D7D3C-1111-4A5B-9C3D-000000000002' }] };
        return { Success: true, Results: [] };
    });
    getEntityObjectMock.mockImplementation(async (entityName: string) => {
        if (entityName === 'MJ_BizApps_Tasks: Meetings') return { OrganizerPersonID: meeting.OrganizerPersonID, Load: async () => meeting.found };
        if (entityName === 'MJ_BizApps_Tasks: Meeting Series') return { OrganizerPersonID: meeting.OrganizerPersonID, Load: async () => meeting.found };
        return {};
    });
});

const invited = (values: Record<string, unknown> = {}): Seedable =>
    (new MeetingAttendeeEntityServer() as unknown as Seedable).seed({
        ID: 'A1',
        MeetingID: 'M1',
        PersonID: 'P-SAM',
        UserID: 'U-SAM',
        Email: null,
        DisplayName: null,
        Role: 'Required',
        ResponseStatus: 'None',
        RespondedAt: null,
        AttendanceStatus: 'Unknown',
        ...values,
    }) as Seedable;

const newRow = (values: Record<string, unknown> = {}): Seedable => {
    const row = new MeetingAttendeeEntityServer() as unknown as Seedable;
    row.MeetingID = 'M1';
    row.PersonID = 'P-NEW';
    row.Role = 'Required';
    row.ResponseStatus = 'None';
    row.AttendanceStatus = 'Unknown';
    for (const [k, v] of Object.entries(values)) (row as unknown as Record<string, unknown>)[k] = v;
    return row;
};

describe('who an attendee is', () => {
    it('is a person or an address, with a tidy address', async () => {
        const row = newRow({ PersonID: null, Email: null });
        expect((await row.ValidateAsync()).Errors[0].Message).toBe('An attendee is a person, or a guest with an email address.');
        const guest = newRow({ PersonID: null, Email: 'not an address' });
        expect((await guest.ValidateAsync()).Errors[0].Source).toBe('Email');
    });

    it('keeps the Organizer row on the meeting\'s organizer', async () => {
        const row = newRow({ PersonID: 'P-SAM', Role: 'Organizer' });
        const result = await row.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toMatch(/The Organizer row is the meeting's organizer/);
    });
});

describe('who may write an attendee', () => {
    it('lets the organizer invite someone', async () => {
        expect((await newRow().ValidateAsync()).Success).toBe(true);
    });

    it('refuses an invitation from someone who is not the organizer, in words', async () => {
        callerPerson = 'P-SAM';
        const result = await newRow().ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe('Only the organizer invites people to a meeting.');
    });

    it('treats a meeting the caller may not read as not there', async () => {
        callerPerson = 'P-SAM';
        meeting = { OrganizerPersonID: 'P-ADA', found: false };
        const result = await newRow().ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe('The meeting was not found, or you may not see it.');
    });

    it('lets an attendee answer and mark their own attendance', async () => {
        callerPerson = 'P-SAM';
        const row = invited();
        row.ResponseStatus = 'Accepted';
        row.RespondedAt = new Date();
        row.AttendanceStatus = 'Present';
        expect((await row.ValidateAsync()).Success).toBe(true);
    });

    it('refuses an attendee changing anything else on their own row', async () => {
        callerPerson = 'P-SAM';
        const row = invited();
        row.Role = 'Optional';
        const result = await row.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Source).toBe('Role');
        expect(result.Errors[0].Message).toMatch(/the organizer changes the rest/);
    });

    it('refuses an attendee answering for someone else', async () => {
        callerPerson = 'P-SAM';
        const row = invited({ PersonID: 'P-NICO', UserID: 'U-NICO' });
        row.ResponseStatus = 'Declined';
        const result = await row.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe('Only the organizer changes another attendee.');
    });

    it('knows the caller\'s own row by their user when they have no Person', async () => {
        callerPerson = null;
        const row = invited({ PersonID: null, UserID: 'U-SAM', Email: 'sam@example.org' });
        row.ResponseStatus = 'Tentative';
        expect((await row.ValidateAsync()).Success).toBe(true);
    });

    it('lets the meeting server keep the organizer row in step whoever saved the meeting', async () => {
        callerPerson = 'P-SAM';
        const row = newRow({ PersonID: 'P-ADA', Role: 'Organizer' });
        row.MaintainedByMeetingServer = true;
        expect((await row.ValidateAsync()).Success).toBe(true);
    });

    it('lets an administrator do all of it', async () => {
        callerPerson = 'P-SAM';
        const row = newRow();
        const admin = row as unknown as { ProviderToUse: { Entities: unknown[]; Roles: unknown[] }; ContextCurrentUser: unknown };
        admin.ProviderToUse.Entities = [{ Name: 'MJ_BizApps_Tasks: Meetings', Permissions: [{ RoleID: 'R-DEV', CanUpdate: true }] }];
        admin.ProviderToUse.Roles = [{ ID: 'R-UI', Name: 'UI' }, { ID: 'R-DEV', Name: 'Developer' }];
        admin.ContextCurrentUser = { ID: 'U-SAM', UserRoles: [{ RoleID: 'R-DEV' }], LinkedEntityID: null, LinkedEntityRecordID: null };
        expect((await row.ValidateAsync()).Success).toBe(true);
    });

    it('refuses someone who is not the organizer removing an attendee', async () => {
        callerPerson = 'P-SAM';
        await expect(invited().Delete()).rejects.toThrow(/Only the organizer removes an attendee/);
    });

    it('lets the organizer remove an attendee', async () => {
        expect(await invited().Delete()).toBe(true);
    });
});

describe('the attendee\'s user', () => {
    it('is read again when the person changes', async () => {
        const row = invited({ PersonID: 'P-SAM', UserID: 'U-SAM' });
        row.PersonID = '2F0D7D3C-1111-4A5B-9C3D-000000000001';
        await row.Save();
        expect(row.UserID).toBe('2F0D7D3C-1111-4A5B-9C3D-000000000002');
    });
});

describe('a series\' attendees', () => {
    it('are the organizer\'s to change', async () => {
        callerPerson = 'P-SAM';
        const row = new MeetingSeriesAttendeeEntityServer() as unknown as Seedable;
        row.SeriesID = 'S1';
        row.PersonID = 'P-NEW';
        row.Role = 'Required';
        const result = await row.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe('Only the organizer changes who a series invites.');
        callerPerson = 'P-ADA';
        expect((await row.ValidateAsync()).Success).toBe(true);
    });
});
