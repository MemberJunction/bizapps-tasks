import { describe, it, expect, vi, beforeEach } from 'vitest';

const runViewMock = vi.fn();
const runAfterCommitMock = vi.fn();
const materializeMock = vi.fn();

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
        public ContextCurrentUser: unknown = { ID: 'U-ADA', UserRoles: [], LinkedEntityID: null, LinkedEntityRecordID: null };
        public IsSaved = false;
        private readonly values: Record<string, unknown> = {};
        private readonly olds: Record<string, unknown> = {};
        private readonly dirty = new Set<string>();
        public ProviderToUse = { RunAfterCommit: runAfterCommitMock, Entities: [] as unknown[], Roles: [] as unknown[] };
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
    const fields = ['ID', 'Name', 'RecurrenceRule', 'TimeZone', 'DurationMinutes', 'FirstStartsAt', 'OrganizerPersonID', 'Status', 'MaterializedThrough'];
    class mjBizAppsTasksMeetingSeriesEntity extends Base {}
    for (const field of fields) {
        Object.defineProperty(mjBizAppsTasksMeetingSeriesEntity.prototype, field, {
            get() {
                return (this as { Get: (n: string) => unknown }).Get(field);
            },
            set(value: unknown) {
                (this as { Set: (n: string, v: unknown) => void }).Set(field, value);
            },
        });
    }
    return { mjBizAppsTasksMeetingSeriesEntity };
});

vi.mock('@mj-biz-apps/tasks-core', async () => {
    const actual = await vi.importActual<typeof import('@mj-biz-apps/tasks-core')>('@mj-biz-apps/tasks-core');
    return {
        ...actual,
        MeetingSeriesService: class {
            materialize(...args: unknown[]) {
                return materializeMock(...args);
            }
        },
    };
});

import { MeetingSeriesEntityServer } from '../MeetingSeriesEntityServer.js';

type Seedable = MeetingSeriesEntityServer & { seed(values: Record<string, unknown>): MeetingSeriesEntityServer; ContextCurrentUser: unknown };

let callerPerson: string | null = 'P-ADA';

beforeEach(() => {
    runViewMock.mockReset();
    runAfterCommitMock.mockReset();
    materializeMock.mockReset();
    callerPerson = 'P-ADA';
    runViewMock.mockImplementation(async () => ({ Success: true, Results: callerPerson ? [{ ID: callerPerson }] : [] }));
    runAfterCommitMock.mockImplementation((task: () => Promise<void>) => void task());
    materializeMock.mockResolvedValue({ created: 0 });
});

const weekly = (): Seedable =>
    (new MeetingSeriesEntityServer() as unknown as Seedable).seed({
        ID: 'S1',
        Name: 'Staff sync',
        RecurrenceRule: 'FREQ=WEEKLY;BYDAY=TU',
        TimeZone: 'America/Chicago',
        DurationMinutes: 30,
        FirstStartsAt: new Date('2026-10-20T14:00:00Z'),
        OrganizerPersonID: 'P-ADA',
        Status: 'Active',
        MaterializedThrough: null,
    }) as Seedable;

describe('a series\' rule, zone and length', () => {
    it('refuses a rule that does not parse, a zone that is not real, and no length, each in words', async () => {
        const series = weekly();
        series.RecurrenceRule = 'FREQ=SOMETIMES';
        expect((await series.ValidateAsync()).Errors[0].Source).toBe('RecurrenceRule');
        const zone = weekly();
        zone.TimeZone = 'Mars/Olympus';
        expect((await zone.ValidateAsync()).Errors[0].Message).toMatch(/is not a time zone/);
        const length = weekly();
        length.DurationMinutes = 0;
        expect((await length.ValidateAsync()).Errors[0].Message).toMatch(/more than 0 minutes/);
    });
});

describe('who may write a series', () => {
    it('lets the organizer change it', async () => {
        const series = weekly();
        series.Name = 'Staff sync, renamed';
        expect((await series.ValidateAsync()).Success).toBe(true);
    });

    it('refuses someone else changing it, in words', async () => {
        callerPerson = 'P-SAM';
        const series = weekly();
        series.Name = 'Hijacked';
        const result = await series.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe('Only the organizer changes a series.');
    });

    it('judges a change of organizer by who organized it before', async () => {
        const series = weekly();
        series.OrganizerPersonID = 'P-NICO';
        expect((await series.ValidateAsync()).Success).toBe(true);
        callerPerson = 'P-NICO';
        const other = weekly();
        other.OrganizerPersonID = 'P-NICO';
        expect((await other.ValidateAsync()).Success).toBe(false);
    });

    it('refuses a new series organized by someone else, unless an administrator makes it', async () => {
        const series = new MeetingSeriesEntityServer() as unknown as Seedable;
        series.Name = 'For Nico';
        series.RecurrenceRule = 'FREQ=WEEKLY;BYDAY=TU';
        series.TimeZone = 'America/Chicago';
        series.DurationMinutes = 30;
        series.OrganizerPersonID = 'P-NICO';
        series.Status = 'Active';
        const result = await series.ValidateAsync();
        expect(result.Success).toBe(false);
        expect(result.Errors[0].Message).toBe('A series is organized by the person who makes it.');
        const admin = series as unknown as { ProviderToUse: { Entities: unknown[]; Roles: unknown[] }; ContextCurrentUser: unknown };
        admin.ProviderToUse.Entities = [{ Name: 'MJ_BizApps_Tasks: Meetings', Permissions: [{ RoleID: 'R-DEV', CanUpdate: true }] }];
        admin.ProviderToUse.Roles = [{ ID: 'R-UI', Name: 'UI' }, { ID: 'R-DEV', Name: 'Developer' }];
        admin.ContextCurrentUser = { ID: 'U-ADA', UserRoles: [{ RoleID: 'R-DEV' }], LinkedEntityID: null, LinkedEntityRecordID: null };
        expect((await series.ValidateAsync()).Success).toBe(true);
    });

    it('refuses someone else deleting it', async () => {
        callerPerson = 'P-SAM';
        await expect(weekly().Delete()).rejects.toThrow('Only the organizer deletes a series.');
    });
});

describe('after a series is saved', () => {
    it('makes its occurrences after the commit, through the provider\'s hook', async () => {
        const series = weekly();
        series.Name = 'Staff sync, renamed';
        expect(await series.Save()).toBe(true);
        expect(runAfterCommitMock).toHaveBeenCalledTimes(1);
        expect(runAfterCommitMock.mock.calls[0][1]).toBe('materialize series S1');
        expect(materializeMock).toHaveBeenCalledWith('S1', expect.anything());
    });

    it('does nothing after a save that only advanced MaterializedThrough, or of a series that is not active', async () => {
        const series = weekly();
        series.MaterializedThrough = new Date();
        await series.Save();
        const ended = weekly();
        ended.Status = 'Ended';
        await ended.Save();
        expect(runAfterCommitMock).not.toHaveBeenCalled();
    });
});
