import { describe, it, expect, vi, beforeEach } from 'vitest';

const runViewMock = vi.fn();

vi.mock('@memberjunction/core', () => ({
    RunView: { FromMetadataProvider: () => ({ RunView: (...args: unknown[]) => runViewMock(...args) }) },
    Metadata: { Provider: {} },
    BaseEntity: class {},
    CompositeKey: class {},
}));

import { MeetingAgendaService } from '../MeetingAgendaService.js';

type Row = Record<string, unknown>;
const ITEMS = 'MJ_BizApps_Tasks: Meeting Agenda Items';
let items: Row[];
let nextId = 1;

/** An agenda item stand-in over the shared rows: Load reads one, Save writes it back or adds it. */
function fakeItem(): Row {
    let loaded: Row | null = null;
    const values: Row = {};
    const fake: Row = {
        NewRecord: () => {
            loaded = null;
        },
        Load: async (id: string) => {
            const row = items.find((r) => String(r.ID).toLowerCase() === id.toLowerCase());
            if (!row) return false;
            Object.assign(values, row);
            loaded = row;
            return true;
        },
        Save: async () => {
            if (loaded) Object.assign(loaded, values);
            else {
                values.ID = values.ID ?? `N${nextId++}`;
                items.push({ ...values });
            }
            return true;
        },
    };
    return new Proxy(fake, {
        get: (target, prop: string) => (prop in target ? target[prop] : values[prop]),
        set: (target, prop: string, value: unknown) => {
            if (prop in target) target[prop] = value;
            else values[prop] = value;
            return true;
        },
    });
}
const provider = { GetEntityObject: async () => fakeItem() };
const user = { ID: 'U-ADA' };
const item = (id: string, meeting: string, values: Row = {}): Row => ({ ID: id, MeetingID: meeting, ParentID: null, Sequence: 100, Name: id, Description: null, TypeID: null, PresenterPersonID: null, DurationMinutes: 10, Status: 'Planned', ...values });

beforeEach(() => {
    nextId = 1;
    items = [];
    runViewMock.mockReset();
    runViewMock.mockImplementation(async (params: { EntityName: string; ExtraFilter: string }) => {
        const meetingId = /MeetingID = '([^']+)'/.exec(params.ExtraFilter)?.[1];
        return { Success: true, Results: params.EntityName === ITEMS ? items.filter((r) => !meetingId || r.MeetingID === meetingId).sort((a, b) => (a.Sequence as number) - (b.Sequence as number)) : [] };
    });
});

describe('reordering an agenda', () => {
    it('puts the named items in order among their siblings, 100 apart, saving only what moved', async () => {
        items.push(item('A', 'M1', { Sequence: 100 }), item('B', 'M1', { Sequence: 200 }), item('C', 'M1', { Sequence: 300 }));
        await new MeetingAgendaService(provider as never).reorder('M1', ['C', 'A', 'B'], user as never);
        expect(items.map((r) => [r.ID, r.Sequence])).toEqual([['A', 200], ['B', 300], ['C', 100]]);
    });

    it('refuses an item of another meeting', async () => {
        items.push(item('A', 'M1'), item('X', 'M2'));
        await expect(new MeetingAgendaService(provider as never).reorder('M1', ['X', 'A'], user as never)).rejects.toThrow(/Agenda item x is not on this meeting/);
    });
});

describe('carrying an agenda forward', () => {
    it('copies the unfinished items with their sub-items to the next meeting and marks the originals deferred', async () => {
        items.push(
            item('P', 'M1', { Status: 'Planned', Sequence: 100 }),
            item('P-child', 'M1', { ParentID: 'P', Status: 'Done', Sequence: 100 }),
            item('D', 'M1', { Status: 'Done', Sequence: 200 }),
            item('I', 'M1', { Status: 'InProgress', Sequence: 300 }),
            item('T', 'M2', { Status: 'Planned', Sequence: 100 }),
        );
        const made = await new MeetingAgendaService(provider as never).carryForward('M1', 'M2', user as never);
        expect(made.map((m) => m.Name)).toEqual(['P', 'P-child', 'I']);
        const copies = items.filter((r) => r.MeetingID === 'M2' && r.ID !== 'T');
        expect(copies.map((r) => [r.Name, r.Sequence, r.Status])).toEqual([['P', 200, 'Planned'], ['P-child', 100, 'Planned'], ['I', 300, 'Planned']]);
        const childCopy = copies.find((r) => r.Name === 'P-child');
        const parentCopy = copies.find((r) => r.Name === 'P');
        expect(childCopy?.ParentID).toBe(parentCopy?.ID);
        expect(items.find((r) => r.ID === 'P')?.Status).toBe('Deferred');
        expect(items.find((r) => r.ID === 'P')?.DeferredToMeetingID).toBe('M2');
        expect(items.find((r) => r.ID === 'D')?.Status).toBe('Done');
    });

    it('does nothing when nothing is unfinished, and refuses the same meeting', async () => {
        items.push(item('D', 'M1', { Status: 'Done' }));
        expect(await new MeetingAgendaService(provider as never).carryForward('M1', 'M2', user as never)).toEqual([]);
        await expect(new MeetingAgendaService(provider as never).carryForward('M1', 'M1', user as never)).rejects.toThrow(/different meeting/);
    });
});
