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

beforeEach(() => {
    runViewMock.mockReset();
    getEntityObjectMock.mockReset();
    runAfterCommitMock.mockReset();
    configMock.mockReset();
    // The organizer's attendee row is already there, unless a test says otherwise
    runViewMock.mockResolvedValue({ Success: true, Results: [{ PersonID: 'P-ADA', Save: vi.fn() }] });
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
        // personIdForUser falls back to People.LinkedUserID: the first read; the organizer row check is the second
        runViewMock.mockResolvedValueOnce({ Success: true, Results: [{ ID: 'P-ADA' }] });
        meeting.Status = 'InProgress';
        expect((await meeting.ValidateAsync()).Success).toBe(true);
        expect(await meeting.Save()).toBe(true);
        expect(meeting.ActualStartedAt).toBeInstanceOf(Date);
    });

    it('refuses someone else starting it', async () => {
        const meeting = scheduled();
        meeting.ContextCurrentUser = { ID: 'U-SAM', UserRoles: [], LinkedEntityID: null, LinkedEntityRecordID: null };
        runViewMock.mockResolvedValueOnce({ Success: true, Results: [{ ID: 'P-SAM' }] });
        meeting.Status = 'InProgress';
        const result = await meeting.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe('Only the organizer starts a meeting.');
    });

    it('lets a postponement go either way without the organizer', async () => {
        const meeting = scheduled();
        meeting.Status = 'Postponed';
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
        runViewMock.mockResolvedValueOnce({ Success: true, Results: [] });
        const row: Record<string, unknown> = { NewRecord: vi.fn(), Save: vi.fn(async () => true) };
        getEntityObjectMock.mockResolvedValueOnce(row);
        meeting.Name = 'Renamed';
        expect(await meeting.Save()).toBe(true);
        expect(row.MeetingID).toBe('M1');
        expect(row.PersonID).toBe('P-ADA');
        expect(row.Role).toBe('Organizer');
        expect(row.ResponseStatus).toBe('Accepted');
    });

    it('moves the organizer row to the new organizer', async () => {
        const meeting = scheduled();
        const row: Record<string, unknown> = { PersonID: 'P-ADA', UserID: 'U-ADA', Save: vi.fn(async () => true) };
        runViewMock.mockResolvedValueOnce({ Success: true, Results: [row] });
        meeting.OrganizerPersonID = 'P-NICO';
        expect(await meeting.Save()).toBe(true);
        expect(row.PersonID).toBe('P-NICO');
        expect(row.UserID).toBeNull();
    });
});
