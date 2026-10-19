import { describe, it, expect, vi, beforeEach } from 'vitest';

// A BaseEntity stand-in that keeps field values, dirtiness and old values the way the server subclass reads them
const runViewMock = vi.fn();
const getEntityObjectMock = vi.fn();
const runAfterCommitMock = vi.fn();
const configMock = vi.fn();

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
        public ContextCurrentUser: unknown = { ID: 'USER-1', UserRoles: [] };
        public IsSaved = false;
        private readonly values: Record<string, unknown> = {};
        private readonly olds: Record<string, unknown> = {};
        private readonly dirty = new Set<string>();
        public ProviderToUse = { RunAfterCommit: runAfterCommitMock, Entities: [], Roles: [], GetEntityObject: getEntityObjectMock };
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
        public get Dirty() {
            return this.dirty.size > 0;
        }
        public async ValidateAsync() {
            return { Success: true, Errors: [] as ValidationErrorInfo[] };
        }
        public async Save() {
            this.IsSaved = true;
            this.dirty.clear();
            return true;
        }
        /** Loads a row as if from the database: values set, nothing dirty, no old values. */
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
    const fields = ['ID', 'Name', 'Status', 'StartsAt', 'EndsAt', 'TimeZone', 'SeriesID', 'OccurrenceStartsAt', 'OrganizerPersonID', 'VideoProviderID', 'VideoMeetingID', 'ActualStartedAt', 'ActualEndedAt', 'CancelledAt', 'CancellationReason', 'Visibility', 'LocationType'];
    class mjBizAppsTasksMeetingEntity extends Base {}
    for (const field of fields) {
        Object.defineProperty(mjBizAppsTasksMeetingEntity.prototype, field, {
            get() {
                return (this as { Get: (n: string) => unknown }).Get(field);
            },
            set(value: unknown) {
                (this as { Set: (n: string, v: unknown) => void }).Set(field, value);
            },
        });
    }
    return { mjBizAppsTasksMeetingEntity, mjBizAppsTasksMeetingAttendeeEntity: class {}, mjBizAppsTasksVideoProviderEntity: class {} };
});

vi.mock('@mj-biz-apps/common-entities', () => ({
    BusinessTimeZoneEngine: { Instance: { Config: (...args: unknown[]) => configMock(...args), Zone: 'America/Chicago' } },
}));

import { MeetingEntityServer } from '../MeetingEntityServer.js';

type Seedable = MeetingEntityServer & { seed(values: Record<string, unknown>): MeetingEntityServer; ContextCurrentUser: unknown };

const scheduled = (): Seedable =>
    (new MeetingEntityServer() as unknown as Seedable).seed({
        ID: 'M1',
        Name: 'Board prep',
        Status: 'Scheduled',
        StartsAt: new Date('2026-11-03T15:00:00Z'),
        EndsAt: new Date('2026-11-03T16:00:00Z'),
        TimeZone: 'America/Chicago',
        SeriesID: null,
        OccurrenceStartsAt: null,
        OrganizerPersonID: 'P-ADA',
        VideoProviderID: null,
        VideoMeetingID: null,
    }) as Seedable;

/** Who the caller is (their Person, read through People.LinkedUserID) and the meeting's attendee rows, per test. */
let callerPerson: string | null = 'P-ADA';
let attendeeRows: Array<Record<string, unknown>> = [];

beforeEach(() => {
    runViewMock.mockReset();
    getEntityObjectMock.mockReset();
    runAfterCommitMock.mockReset();
    configMock.mockReset();
    callerPerson = 'P-ADA';
    // The organizer's attendee row is already there, unless a test says otherwise
    attendeeRows = [{ PersonID: 'P-ADA', Role: 'Organizer', Save: vi.fn(async () => true) }];
    runViewMock.mockImplementation(async (params: { EntityName: string }) =>
        params.EntityName === 'MJ_BizApps_Common: People'
            ? { Success: true, Results: callerPerson ? [{ ID: callerPerson }] : [] }
            : { Success: true, Results: attendeeRows },
    );
});

describe('a meeting\'s times and slot', () => {
    it('refuses an end at or before the start, in words', async () => {
        const meeting = scheduled();
        meeting.EndsAt = new Date('2026-11-03T14:00:00Z');
        const result = await meeting.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe('A meeting ends after it starts.');
    });

    it('refuses a slot without a series and a series without a slot', async () => {
        const meeting = scheduled();
        meeting.SeriesID = 'S1';
        const result = await meeting.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Source).toBe('OccurrenceStartsAt');
    });
});

describe('a meeting\'s status', () => {
    it('refuses a move backwards', async () => {
        const meeting = scheduled();
        meeting.Status = 'Draft';
        const result = await meeting.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toMatch(/A Scheduled meeting moves to/);
    });

    it('lets the organizer start it, and stamps when it started', async () => {
        const meeting = scheduled();
        meeting.ContextCurrentUser = { ID: 'U-ADA', UserRoles: [], LinkedEntityID: null, LinkedEntityRecordID: null };
        meeting.Status = 'InProgress';
        expect((await meeting.ValidateAsync()).Success).toBe(true);
        expect(await meeting.Save()).toBe(true);
        expect(meeting.ActualStartedAt).toBeInstanceOf(Date);
    });

    it('refuses someone else starting it', async () => {
        const meeting = scheduled();
        meeting.ContextCurrentUser = { ID: 'U-SAM', UserRoles: [], LinkedEntityID: null, LinkedEntityRecordID: null };
        callerPerson = 'P-SAM';
        meeting.Status = 'InProgress';
        const result = await meeting.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe('Only the organizer starts a meeting.');
    });

    it('lets the organizer postpone it and put it back', async () => {
        const meeting = scheduled();
        meeting.Status = 'Postponed';
        expect((await meeting.ValidateAsync()).Success).toBe(true);
        expect(await meeting.Save()).toBe(true);
        meeting.Status = 'Scheduled';
        expect((await meeting.ValidateAsync()).Success).toBe(true);
    });

    it('refuses someone else changing the meeting at all, and leaves no stamp behind', async () => {
        const meeting = scheduled();
        callerPerson = 'P-SAM';
        meeting.Name = 'Renamed by a stranger';
        const result = await meeting.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe('Only the organizer changes a meeting.');
        meeting.Status = 'InProgress';
        await meeting.Save();
        expect(meeting.ActualStartedAt).toBeUndefined();
    });

    it('lets an administrator change any meeting', async () => {
        const meeting = scheduled();
        callerPerson = 'P-SAM';
        const admin = meeting as unknown as { ProviderToUse: { Entities: unknown[]; Roles: unknown[] }; ContextCurrentUser: unknown };
        admin.ProviderToUse.Entities = [{ Name: 'MJ_BizApps_Tasks: Meetings', Permissions: [{ RoleID: 'R-DEV', CanUpdate: true }] }];
        admin.ProviderToUse.Roles = [{ ID: 'R-UI', Name: 'UI' }, { ID: 'R-DEV', Name: 'Developer' }];
        admin.ContextCurrentUser = { ID: 'U-SAM', UserRoles: [{ RoleID: 'R-DEV' }], LinkedEntityID: null, LinkedEntityRecordID: null };
        meeting.Name = 'Renamed by an administrator';
        expect((await meeting.ValidateAsync()).Success).toBe(true);
    });

    it('stamps the cancellation and tells the video provider after the commit', async () => {
        const meeting = scheduled();
        meeting.seed({ VideoProviderID: 'VP1', VideoMeetingID: 'zoom-123' });
        meeting.ContextCurrentUser = { ID: 'U-ADA', UserRoles: [], LinkedEntityID: null, LinkedEntityRecordID: null };
        meeting.Status = 'Cancelled';
        expect(await meeting.Save()).toBe(true);
        expect(meeting.CancelledAt).toBeInstanceOf(Date);
        expect(runAfterCommitMock).toHaveBeenCalledTimes(1);
        expect(runAfterCommitMock.mock.calls[0][1]).toBe('cancel video meeting zoom-123');
    });
});

describe('a new meeting', () => {
    it('takes the business time zone when none was given', async () => {
        const meeting = new MeetingEntityServer() as unknown as Seedable;
        meeting.Name = 'Quick sync';
        meeting.Status = 'Scheduled';
        meeting.StartsAt = new Date('2026-11-03T15:00:00Z');
        meeting.EndsAt = new Date('2026-11-03T15:30:00Z');
        meeting.OrganizerPersonID = 'P-ADA';
        meeting.SeriesID = null;
        meeting.OccurrenceStartsAt = null;
        expect(await meeting.Save()).toBe(true);
        expect(meeting.TimeZone).toBe('America/Chicago');
        expect(configMock).toHaveBeenCalled();
    });

    it('makes the organizer\'s attendee row when none is there', async () => {
        const meeting = scheduled();
        attendeeRows = [];
        const row: Record<string, unknown> = { NewRecord: vi.fn(), Save: vi.fn(async () => true) };
        getEntityObjectMock.mockResolvedValueOnce(row);
        meeting.Name = 'Renamed';
        expect(await meeting.Save()).toBe(true);
        expect(row.MeetingID).toBe('M1');
        expect(row.PersonID).toBe('P-ADA');
        expect(row.Role).toBe('Organizer');
        expect(row.ResponseStatus).toBe('Accepted');
        expect(row.MaintainedByMeetingServer).toBe(true);
    });

    it('refuses a new meeting organized by someone else, unless an administrator schedules it', async () => {
        const meeting = new MeetingEntityServer() as unknown as Seedable;
        meeting.Name = 'For Nico';
        meeting.Status = 'Scheduled';
        meeting.StartsAt = new Date('2026-11-03T15:00:00Z');
        meeting.EndsAt = new Date('2026-11-03T15:30:00Z');
        meeting.TimeZone = 'America/Chicago';
        meeting.OrganizerPersonID = 'P-NICO';
        meeting.SeriesID = null;
        meeting.OccurrenceStartsAt = null;
        const result = await meeting.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe('A meeting is organized by the person who schedules it.');
    });

    it('moves the organizer row to the new organizer', async () => {
        const meeting = scheduled();
        const row: Record<string, unknown> = { PersonID: 'P-ADA', Role: 'Organizer', UserID: 'U-ADA', Save: vi.fn(async () => true) };
        attendeeRows = [row];
        meeting.OrganizerPersonID = 'P-NICO';
        expect(await meeting.Save()).toBe(true);
        expect(row.PersonID).toBe('P-NICO');
        expect(row.UserID).toBeNull();
        expect(row.MaintainedByMeetingServer).toBe(true);
    });

    it('promotes the new organizer\'s own row and keeps the old organizer as an attendee', async () => {
        const meeting = scheduled();
        const old: Record<string, unknown> = { PersonID: 'P-ADA', Role: 'Organizer', Save: vi.fn(async () => true) };
        const nico: Record<string, unknown> = { PersonID: 'P-NICO', Role: 'Required', ResponseStatus: 'None', RespondedAt: null, Save: vi.fn(async () => true) };
        attendeeRows = [old, nico];
        meeting.OrganizerPersonID = 'P-NICO';
        expect(await meeting.Save()).toBe(true);
        expect(old.Role).toBe('Required');
        expect(old.PersonID).toBe('P-ADA');
        expect(nico.Role).toBe('Organizer');
        expect(nico.ResponseStatus).toBe('Accepted');
        expect(nico.RespondedAt).toBeInstanceOf(Date);
        expect(old.Save).toHaveBeenCalled();
        expect(nico.Save).toHaveBeenCalled();
    });
});
