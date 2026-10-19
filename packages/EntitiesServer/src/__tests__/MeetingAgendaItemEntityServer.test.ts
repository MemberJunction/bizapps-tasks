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
        public ContextCurrentUser: unknown = { ID: 'U-ADA' };
        public IsSaved = false;
        private readonly values: Record<string, unknown> = {};
        public ProviderToUse = { Entities: [] as unknown[], Roles: [] as unknown[], GetEntityObject: (...args: unknown[]) => getEntityObjectMock(...args) };
        public Get(name: string) {
            return this.values[name];
        }
        public Set(name: string, value: unknown) {
            this.values[name] = value;
        }
        public async ValidateAsync() {
            return { Success: true, Errors: [] as ValidationErrorInfo[] };
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
    const fields = ['ID', 'MeetingID', 'ParentID', 'DeferredToMeetingID', 'Sequence', 'DurationMinutes', 'SeriesID'];
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
    return { mjBizAppsTasksMeetingAgendaItemEntity: withFields(class extends Base {}), mjBizAppsTasksMeetingLinkEntity: withFields(class extends Base {}), mjBizAppsTasksMeetingSeriesEntity: class {}, mjBizAppsTasksMeetingEntity: class {} };
});

import { MeetingAgendaItemEntityServer, MeetingLinkEntityServer } from '../MeetingAgendaItemEntityServer.js';

const M1 = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F';
const M2 = '28FA9C58-F27F-48B2-8A6B-F8755C8B0872';
const I1 = '1A697CB1-6D3A-468A-93E4-63561A2FE118';
const I2 = '85CCE1B6-C24C-4786-9632-40218A339F02';

const item = (values: Record<string, unknown>): MeetingAgendaItemEntityServer => {
    const row = new MeetingAgendaItemEntityServer();
    row.ID = I2;
    row.MeetingID = M1;
    row.ParentID = null;
    row.DeferredToMeetingID = null;
    row.Sequence = 100;
    row.DurationMinutes = 10;
    for (const [k, v] of Object.entries(values)) (row as unknown as Record<string, unknown>)[k] = v;
    return row;
};

/** The caller's Person (through People.LinkedUserID), and whether the meeting or series loads and who organizes it, per test. */
let callerPerson: string | null = 'P-ADA';
let meeting: { OrganizerPersonID: string; found: boolean } = { OrganizerPersonID: 'P-ADA', found: true };
let agendaRows: Array<Record<string, unknown>> = [];

beforeEach(() => {
    runViewMock.mockReset();
    getEntityObjectMock.mockReset();
    callerPerson = 'P-ADA';
    meeting = { OrganizerPersonID: 'P-ADA', found: true };
    agendaRows = [];
    runViewMock.mockImplementation(async (params: { EntityName: string; ExtraFilter: string }) => {
        if (params.EntityName === 'MJ_BizApps_Common: People') return { Success: true, Results: callerPerson ? [{ ID: callerPerson }] : [] };
        if (params.EntityName === 'MJ_BizApps_Tasks: Meeting Attendees') return { Success: true, Results: [] };
        return { Success: true, Results: agendaRows };
    });
    getEntityObjectMock.mockImplementation(async () => ({ OrganizerPersonID: meeting.OrganizerPersonID, Load: async () => meeting.found }));
});

describe('an agenda item', () => {
    it('takes 0 or more minutes', async () => {
        expect((await item({ DurationMinutes: -5 }).ValidateAsync()).Errors[0].Message).toBe('An agenda item takes 0 or more minutes.');
    });

    it('is deferred to a later meeting, not its own', async () => {
        expect((await item({ DeferredToMeetingID: M1 }).ValidateAsync()).Errors[0].Source).toBe('DeferredToMeetingID');
    });

    it('refuses an id that is not one before it reaches a filter', async () => {
        const result = await item({ MeetingID: "x' OR 1=1 --" }).ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Source).toBe('MeetingID');
        expect(getEntityObjectMock).not.toHaveBeenCalled();
        const parent = await item({ ParentID: 'not-a-guid' }).ValidateAsync();
        expect(parent.Errors[0].Source).toBe('ParentID');
    });

    it('refuses a parent on another meeting, in words', async () => {
        runViewMock.mockImplementation(async (params: { EntityName: string; ExtraFilter: string }) => {
            if (params.EntityName === 'MJ_BizApps_Common: People') return { Success: true, Results: [{ ID: 'P-ADA' }] };
            if (params.EntityName === 'MJ_BizApps_Tasks: Meeting Attendees') return { Success: true, Results: [] };
            return params.ExtraFilter.startsWith('ID =') ? { Success: true, Results: [{ ID: I1, MeetingID: M2, ParentID: null, Sequence: 100 }] } : { Success: true, Results: [] };
        });
        const result = await item({ ParentID: I1 }).ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Source).toBe('ParentID');
        expect(result.Errors[0].Message).toMatch(/meeting/i);
    });

    it('accepts a parent on the same meeting', async () => {
        agendaRows = [{ ID: I1, MeetingID: M1, ParentID: null, Sequence: 100 }];
        expect((await item({ ParentID: I1 }).ValidateAsync()).Success).toBe(true);
    });
});

describe('who writes the agenda', () => {
    it('lets the organizer, and refuses anyone else in words', async () => {
        expect((await item({}).ValidateAsync()).Success).toBe(true);
        callerPerson = 'P-SAM';
        const result = await item({}).ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe('Only the organizer changes the agenda.');
        await expect(item({}).Delete()).rejects.toThrow('Only the organizer changes the agenda.');
    });

    it('treats a meeting the caller may not read as not there', async () => {
        meeting = { OrganizerPersonID: 'P-ADA', found: false };
        expect((await item({}).ValidateAsync()).Errors[0].Message).toBe('The meeting was not found, or you may not see it.');
    });
});

describe('a meeting link', () => {
    it('is the organizer\'s to write, on a meeting and on a series', async () => {
        callerPerson = 'P-SAM';
        const onMeeting = new MeetingLinkEntityServer();
        onMeeting.MeetingID = M1;
        onMeeting.SeriesID = null;
        expect((await onMeeting.ValidateAsync()).Errors[0].Message).toBe('Only the organizer changes what a meeting is linked to.');
        const onSeries = new MeetingLinkEntityServer();
        onSeries.MeetingID = null;
        onSeries.SeriesID = M2;
        expect((await onSeries.ValidateAsync()).Errors[0].Message).toBe('Only the organizer changes what a series is linked to.');
        callerPerson = 'P-ADA';
        expect((await onSeries.ValidateAsync()).Success).toBe(true);
    });

    it('belongs to a meeting or a series, one of the two', async () => {
        const both = new MeetingLinkEntityServer();
        both.MeetingID = M1;
        both.SeriesID = M2;
        expect((await both.ValidateAsync()).Errors[0].Message).toMatch(/one of the two/);
        const neither = new MeetingLinkEntityServer();
        neither.MeetingID = null;
        neither.SeriesID = null;
        expect((await neither.ValidateAsync()).Success).toBe(false);
        const one = new MeetingLinkEntityServer();
        one.MeetingID = M1;
        one.SeriesID = null;
        expect((await one.ValidateAsync()).Success).toBe(true);
    });
});
