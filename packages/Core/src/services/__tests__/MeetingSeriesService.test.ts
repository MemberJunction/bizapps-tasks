import { describe, it, expect, vi, beforeEach } from 'vitest';

const runViewMock = vi.fn();

vi.mock('@memberjunction/core', () => ({
    RunView: { FromMetadataProvider: () => ({ RunView: (...args: unknown[]) => runViewMock(...args) }) },
    Metadata: { Provider: {} },
    BaseEntity: class {},
    CompositeKey: class {},
    LogError: vi.fn(),
}));

import { MeetingSeriesService } from '../MeetingSeriesService.js';

/** An entity stand-in: field values behind a proxy, dirtiness on change, Load from and Save to an in-memory store. */
type Row = Record<string, unknown>;
class Fake {
    public dirty = new Set<string>();
    public saves = 0;
    private loadedFrom: Row | null = null;
    constructor(public values: Row, private readonly store: Row[]) {}
    get Dirty(): boolean {
        return this.dirty.size > 0;
    }
    NewRecord(): void {
        this.values = {};
        this.loadedFrom = null;
    }
    async Load(id: string): Promise<boolean> {
        const row = this.store.find((r) => String(r.ID).toLowerCase() === id.toLowerCase());
        if (!row) return false;
        this.values = { ...row };
        this.dirty.clear();
        this.loadedFrom = row;
        return true;
    }
    async Save(): Promise<boolean> {
        this.saves += 1;
        this.dirty.clear();
        if (this.loadedFrom) Object.assign(this.loadedFrom, this.values);
        else {
            this.values.ID = this.values.ID ?? `NEW-${this.store.length + 1}`;
            this.store.push({ ...this.values });
            this.loadedFrom = this.store[this.store.length - 1];
        }
        return true;
    }
}
const proxied = (fake: Fake): Fake =>
    new Proxy(fake, {
        get(target, prop: string) {
            if (prop in target) return (target as unknown as Row)[prop];
            return target.values[prop];
        },
        set(target, prop: string, value: unknown) {
            if (prop in target) {
                (target as unknown as Row)[prop] = value;
                return true;
            }
            const before = target.values[prop];
            const same = before instanceof Date && value instanceof Date ? before.getTime() === value.getTime() : before === value;
            if (!same) target.dirty.add(prop);
            target.values[prop] = value;
            return true;
        },
    });

const MEETINGS = 'MJ_BizApps_Tasks: Meetings';
const SERIES = 'MJ_BizApps_Tasks: Meeting Series';
const ATTENDEES = 'MJ_BizApps_Tasks: Meeting Attendees';
const SERIES_ATTENDEES = 'MJ_BizApps_Tasks: Meeting Series Attendees';
const LINKS = 'MJ_BizApps_Tasks: Meeting Links';

let stores: Map<string, Row[]>;
const provider = { GetEntityObject: async (name: string) => proxied(new Fake({}, stores.get(name) ?? [])) };
const user = { ID: 'U-ADA' };

// A weekly 9:00 Tuesday series in Chicago, first on 2026-10-20; "now" is the day before; three slots fit 21 days, the third
// after daylight saving ends on 2026-11-01 (9:00 CST is 15:00Z)
const series = (values: Row = {}): Row => ({
    ID: 'S1', Name: 'Staff sync', Description: null, TypeID: null, OrganizerPersonID: 'P-ADA', RecurrenceRule: 'FREQ=WEEKLY;BYDAY=TU', TimeZone: 'America/Chicago',
    FirstStartsAt: new Date('2026-10-20T14:00:00Z'), DurationMinutes: 30, LocationType: 'Virtual', Location: null, VideoProviderID: null, Visibility: 'Standard', Status: 'Active',
    MaterializedThrough: null, CreatedByPersonID: null, ...values,
});
const slot = (iso: string): Date => new Date(iso);
const occurrence = (id: string, iso: string, values: Row = {}): Row => ({
    ID: id, SeriesID: 'S1', Name: 'Old name', OccurrenceStartsAt: slot(iso), StartsAt: slot(iso), EndsAt: new Date(slot(iso).getTime() + 1800000), Status: 'Scheduled', OrganizerPersonID: 'P-ADA', TimeZone: 'America/Chicago', ...values,
});
const options = { now: new Date('2026-10-19T00:00:00Z'), horizonDays: 21 };

beforeEach(() => {
    stores = new Map([[MEETINGS, []], [SERIES, [series()]], [ATTENDEES, []], [SERIES_ATTENDEES, []], [LINKS, []]]);
    runViewMock.mockReset();
    runViewMock.mockImplementation(async (params: { EntityName: string; ExtraFilter: string }) => {
        const rows = stores.get(params.EntityName) ?? [];
        if (params.EntityName === MEETINGS) {
            return { Success: true, Results: rows.map((r) => ({ ID: r.ID, OccurrenceStartsAt: (r.OccurrenceStartsAt as Date).toISOString(), StartsAt: (r.StartsAt as Date).toISOString(), Status: r.Status, OrganizerPersonID: r.OrganizerPersonID })) };
        }
        if (params.EntityName === ATTENDEES) {
            const meetingId = /MeetingID = '([^']+)'/.exec(params.ExtraFilter)?.[1] ?? '';
            return { Success: true, Results: rows.filter((r) => r.MeetingID === meetingId) };
        }
        return { Success: true, Results: rows };
    });
});

const meetings = (): Row[] => stores.get(MEETINGS)!;
const slotsOf = (): string[] => meetings().map((m) => (m.OccurrenceStartsAt as Date).toISOString()).sort();

describe('a series\' occurrences', () => {
    it('are made for every slot up to the horizon, each with the series\' attendees', async () => {
        stores.get(SERIES_ATTENDEES)!.push({ PersonID: 'P-NICO', UserID: null, Email: null, DisplayName: null, Role: 'Required' });
        const result = await new MeetingSeriesService(provider as never).materialize('S1', user as never, options);
        expect(result.created).toBe(3);
        expect(slotsOf()).toEqual(['2026-10-20T14:00:00.000Z', '2026-10-27T14:00:00.000Z', '2026-11-03T15:00:00.000Z']);
        expect(meetings().every((m) => m.SeriesID === 'S1' && m.Name === 'Staff sync' && m.Status === 'Scheduled')).toBe(true);
        expect(stores.get(ATTENDEES)!.filter((a) => a.PersonID === 'P-NICO')).toHaveLength(3);
        expect(result.through).toBeInstanceOf(Date);
    });

    it('bring an untouched occurrence up to the series\' values and leave one moved on its own alone', async () => {
        meetings().push(occurrence('M-A', '2026-10-20T14:00:00Z'));
        meetings().push(occurrence('M-B', '2026-10-27T14:00:00Z', { StartsAt: slot('2026-10-28T14:00:00Z'), EndsAt: slot('2026-10-28T14:30:00Z') }));
        const result = await new MeetingSeriesService(provider as never).materialize('S1', user as never, options);
        expect(result.updated).toBe(1);
        expect(result.created).toBe(1);
        expect(meetings().find((m) => m.ID === 'M-A')?.Name).toBe('Staff sync');
        expect(meetings().find((m) => m.ID === 'M-B')?.Name).toBe('Old name');
    });

    it('move with the series when its time changes, each keeping its own day, its identity and its agenda', async () => {
        for (const [id, iso] of [['M-1', '2026-10-20T14:00:00Z'], ['M-2', '2026-10-27T14:00:00Z'], ['M-3', '2026-11-03T15:00:00Z']]) meetings().push(occurrence(id, iso));
        stores.get(SERIES)![0].FirstStartsAt = new Date('2026-10-20T15:00:00Z'); // 10:00 instead of 9:00
        const result = await new MeetingSeriesService(provider as never).materialize('S1', user as never, options);
        expect(result.cancelled).toBe(0);
        expect(result.created).toBe(0);
        expect(result.updated).toBe(3);
        const byId = (id: string) => (meetings().find((m) => m.ID === id)!.OccurrenceStartsAt as Date).toISOString();
        expect(byId('M-1')).toBe('2026-10-20T15:00:00.000Z');
        expect(byId('M-2')).toBe('2026-10-27T15:00:00.000Z');
        expect(byId('M-3')).toBe('2026-11-03T16:00:00.000Z'); // 10:00 CST
        expect(meetings().every((m) => (m.StartsAt as Date).getTime() === (m.OccurrenceStartsAt as Date).getTime())).toBe(true);
    });

    it('keep a meeting on its own day across a gap: a cancelled week in between is not filled by the next meeting', async () => {
        meetings().push(occurrence('M-1', '2026-10-20T14:00:00Z'));
        meetings().push(occurrence('M-2', '2026-10-27T14:00:00Z', { Status: 'Cancelled' })); // cancelled on its own
        meetings().push(occurrence('M-3', '2026-11-03T15:00:00Z', { Name: 'Budget review' }));
        stores.get(SERIES)![0].FirstStartsAt = new Date('2026-10-20T15:00:00Z'); // 10:00 instead of 9:00
        const result = await new MeetingSeriesService(provider as never).materialize('S1', user as never, options);
        const byId = (id: string) => meetings().find((m) => m.ID === id)!;
        expect((byId('M-3').OccurrenceStartsAt as Date).toISOString()).toBe('2026-11-03T16:00:00.000Z'); // still Nov 3, at 10:00
        expect(byId('M-2').Status).toBe('Cancelled');
        expect(result.created).toBe(1); // a new meeting for Oct 27 at 10:00: the cancelled one stays cancelled
        expect(meetings().filter((m) => (m.OccurrenceStartsAt as Date).toISOString() === '2026-10-27T15:00:00.000Z' && m.Status === 'Scheduled')).toHaveLength(1);
    });

    it('move the meetings to the nearest new slots in order when the weekday changes', async () => {
        for (const [id, iso] of [['M-1', '2026-10-20T14:00:00Z'], ['M-2', '2026-10-27T14:00:00Z'], ['M-3', '2026-11-03T15:00:00Z']]) meetings().push(occurrence(id, iso));
        stores.get(SERIES)![0].RecurrenceRule = 'FREQ=WEEKLY;BYDAY=WE';
        stores.get(SERIES)![0].FirstStartsAt = new Date('2026-10-21T14:00:00Z');
        const result = await new MeetingSeriesService(provider as never).materialize('S1', user as never, options);
        expect(result.created).toBe(0);
        expect(result.cancelled).toBe(0);
        expect(meetings().map((m) => [m.ID, (m.OccurrenceStartsAt as Date).toISOString()])).toEqual([['M-1', '2026-10-21T14:00:00.000Z'], ['M-2', '2026-10-28T14:00:00.000Z'], ['M-3', '2026-11-04T15:00:00.000Z']]);
    });

    it('cancel an untouched occurrence whose slot the rule no longer produces when no new slot takes it', async () => {
        for (const [id, iso] of [['M-1', '2026-10-20T14:00:00Z'], ['M-2', '2026-10-27T14:00:00Z'], ['M-3', '2026-11-03T14:00:00Z']]) meetings().push(occurrence(id, iso));
        stores.get(SERIES)![0].RecurrenceRule = 'FREQ=WEEKLY;BYDAY=TU;COUNT=2';
        const result = await new MeetingSeriesService(provider as never).materialize('S1', user as never, options);
        expect(result.cancelled).toBe(1);
        expect(result.created).toBe(0);
        const third = meetings().find((m) => m.ID === 'M-3');
        expect(third?.Status).toBe('Cancelled');
        expect(third?.CancellationReason).toMatch(/no longer meets then/);
    });

    it('leave a started or cancelled occurrence alone even when its slot goes', async () => {
        meetings().push(occurrence('M-1', '2026-10-20T14:00:00Z'));
        meetings().push(occurrence('M-2', '2026-10-27T14:00:00Z', { Status: 'InProgress' }));
        meetings().push(occurrence('M-3', '2026-11-03T14:00:00Z'));
        stores.get(SERIES)![0].RecurrenceRule = 'FREQ=WEEKLY;BYDAY=TU;COUNT=1';
        const result = await new MeetingSeriesService(provider as never).materialize('S1', user as never, options);
        expect(meetings().find((m) => m.ID === 'M-2')?.Status).toBe('InProgress');
        expect(result.cancelled).toBe(1);
    });

    it('leave an occurrence whose organizer was changed on its own alone', async () => {
        meetings().push(occurrence('M-1', '2026-10-20T14:00:00Z', { OrganizerPersonID: 'P-NICO' }));
        const result = await new MeetingSeriesService(provider as never).materialize('S1', user as never, options);
        expect(meetings().find((m) => m.ID === 'M-1')?.Name).toBe('Old name');
        expect(meetings().find((m) => m.ID === 'M-1')?.OrganizerPersonID).toBe('P-NICO');
        expect(result.created).toBe(2);
    });

    it('go on past an occurrence that cannot be changed, and say which', async () => {
        meetings().push(occurrence('M-1', '2026-10-20T14:00:00Z'));
        const failing = provider.GetEntityObject;
        let calls = 0;
        const flaky = { GetEntityObject: async (name: string) => {
            const entity = await failing(name);
            if (name === MEETINGS && ++calls === 1) (entity as unknown as { Save: () => Promise<boolean> }).Save = async () => false;
            return entity;
        } };
        const result = await new MeetingSeriesService(flaky as never).materialize('S1', user as never, options);
        expect(result.failures).toHaveLength(1);
        expect(result.failures[0]).toMatch(/occurrence M-1/);
        expect(result.created).toBe(2);
    });

    it('end the series once its rule produces nothing more', async () => {
        stores.get(SERIES)![0].RecurrenceRule = 'FREQ=WEEKLY;BYDAY=TU;UNTIL=20261001T000000Z';
        const result = await new MeetingSeriesService(provider as never).materialize('S1', user as never, options);
        expect(result.ended).toBe(true);
        expect(stores.get(SERIES)![0].Status).toBe('Ended');
    });

    it('are all cancelled when the series is cancelled, the ones not yet held and not already over', async () => {
        meetings().push(occurrence('M-1', '2026-10-20T14:00:00Z'));
        meetings().push(occurrence('M-2', '2026-10-27T14:00:00Z', { StartsAt: slot('2026-10-28T14:00:00Z') })); // moved on its own: still cancelled
        meetings().push(occurrence('M-3', '2026-11-03T15:00:00Z', { Status: 'Completed' }));
        runViewMock.mockImplementation(async (params: { EntityName: string; ExtraFilter: string }) => {
            const rows = meetings().filter((r) => ['Draft', 'Scheduled', 'Postponed'].includes(String(r.Status)) && (r.StartsAt as Date).getTime() >= options.now.getTime());
            return { Success: true, Results: params.EntityName === MEETINGS ? rows.map((r) => ({ ID: r.ID, Status: r.Status })) : [] };
        });
        const result = await new MeetingSeriesService(provider as never).cancelFutureOccurrences('S1', user as never, { now: options.now });
        expect(result.cancelled).toBe(2);
        expect(meetings().map((m) => [m.ID, m.Status])).toEqual([['M-1', 'Cancelled'], ['M-2', 'Cancelled'], ['M-3', 'Completed']]);
        expect(meetings()[0].CancellationReason).toBe('The series was cancelled.');
    });

    it('do nothing for a series that is not active', async () => {
        stores.get(SERIES)![0].Status = 'Paused';
        const result = await new MeetingSeriesService(provider as never).materialize('S1', user as never, options);
        expect(result.created).toBe(0);
        expect(meetings()).toHaveLength(0);
    });

    it('run one after the other for the same series', async () => {
        const service = new MeetingSeriesService(provider as never);
        const [first, second] = await Promise.all([service.materialize('S1', user as never, options), service.materialize('S1', user as never, options)]);
        expect(first.created + second.created).toBe(3);
        expect(meetings()).toHaveLength(3);
    });
});
