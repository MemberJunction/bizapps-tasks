import '@angular/compiler';
import { describe, it, expect } from 'vitest';
import { agendaMinutes, agendaTree } from '../meeting-agenda.component';
import { elapsedSince } from '../meeting-live.component';
import { groupMeetingsByDay } from '../meeting-list.component';
import type { AgendaItemModel, MeetingRow } from '../types';

const item = (id: string, parentId: string | null, sequence: number, durationMinutes: number | null): AgendaItemModel => ({ id, parentId, sequence, name: id, description: null, typeId: null, typeName: null, typeCode: null, presenterPersonId: null, presenterName: null, durationMinutes, status: 'Planned', outcome: null, startedAt: null, endedAt: null });

describe('the agenda widget\'s tree', () => {
    const items = [item('b', null, 200, null), item('a', null, 100, 10), item('b2', 'B', 100, 5), item('b1', 'b', 50, 15)];

    it('walks siblings by sequence and sub-items under their parent, without regard to id case', () => {
        expect(agendaTree(items).map((e) => `${e.item.id}:${e.depth}`)).toEqual(['a:0', 'b:0', 'b1:1', 'b2:1']);
    });

    it('adds the sub-items where the parent has no length', () => {
        expect(agendaMinutes(items)).toBe(30);
    });
});

describe('the live meeting\'s clock', () => {
    it('counts from the start, and nothing before one', () => {
        const now = new Date('2026-11-03T15:10:00Z');
        expect(elapsedSince(new Date('2026-11-03T15:00:00Z'), now)).toBe(600);
        expect(elapsedSince(null, now)).toBe(0);
        expect(elapsedSince(new Date('2026-11-03T16:00:00Z'), now)).toBe(0);
    });
});

describe('the list\'s days', () => {
    const row = (id: string, iso: string): MeetingRow => ({ id, name: id, status: 'Scheduled', visibility: 'Standard', typeName: null, startsAt: new Date(iso), endsAt: new Date(new Date(iso).getTime() + 3600000), timeZone: 'UTC', locationType: 'Virtual', location: null, joinUrl: null, organizerName: null, seriesId: null, myResponse: null, isMine: false });

    it('groups by the viewer\'s day and keeps the order asked', () => {
        const rows = [row('late', '2026-11-04T15:00:00Z'), row('early', '2026-11-03T15:00:00Z'), row('mid', '2026-11-03T18:00:00Z')];
        const asc = groupMeetingsByDay(rows, 'America/Chicago', 'asc');
        expect(asc.map((g) => g.meetings.map((m) => m.id))).toEqual([['early', 'mid'], ['late']]);
        expect(asc[0].label).toBe('Tue, Nov 3');
        expect(groupMeetingsByDay(rows, 'America/Chicago', 'desc')[0].meetings[0].id).toBe('late');
    });
});
