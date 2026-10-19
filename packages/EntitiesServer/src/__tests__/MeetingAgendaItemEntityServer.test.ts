import { describe, it, expect, vi, beforeEach } from 'vitest';

const runViewMock = vi.fn();

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
        public ProviderToUse = {};
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
    return { mjBizAppsTasksMeetingAgendaItemEntity: withFields(class extends Base {}), mjBizAppsTasksMeetingLinkEntity: withFields(class extends Base {}) };
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

beforeEach(() => {
    runViewMock.mockReset();
    runViewMock.mockResolvedValue({ Success: true, Results: [] });
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
        expect(runViewMock).not.toHaveBeenCalled();
        const parent = await item({ ParentID: 'not-a-guid' }).ValidateAsync();
        expect(parent.Errors[0].Source).toBe('ParentID');
    });

    it('refuses a parent on another meeting, in words', async () => {
        runViewMock.mockImplementation(async (params: { ExtraFilter: string }) =>
            params.ExtraFilter.startsWith('ID =') ? { Success: true, Results: [{ ID: I1, MeetingID: M2, ParentID: null, Sequence: 100 }] } : { Success: true, Results: [] },
        );
        const result = await item({ ParentID: I1 }).ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Source).toBe('ParentID');
        expect(result.Errors[0].Message).toMatch(/meeting/i);
    });

    it('accepts a parent on the same meeting', async () => {
        runViewMock.mockResolvedValue({ Success: true, Results: [{ ID: I1, MeetingID: M1, ParentID: null, Sequence: 100 }] });
        expect((await item({ ParentID: I1 }).ValidateAsync()).Success).toBe(true);
    });
});

describe('a meeting link', () => {
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
