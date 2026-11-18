import { describe, it, expect } from 'vitest';
import { buildMeetingIcs, escapeIcsText, foldIcsLine, icsUtc, type IcsMeeting } from '../ics.js';

const meeting: IcsMeeting = {
    uid: 'C1000001-0000-4000-8000-00000000AAAA',
    method: 'REQUEST',
    summary: 'Board prep; agenda, numbers',
    startsAt: new Date('2026-11-03T15:00:00Z'),
    endsAt: new Date('2026-11-03T16:00:00Z'),
    dtstamp: new Date('2026-10-14T12:00:00Z'),
    description: 'Line one\nLine two, with a comma',
    location: 'Room 4B',
    organizer: { email: 'ada@example.org', name: 'Ada Owner' },
    attendees: [
        { email: 'sam@example.org', name: 'Sam Member' },
        { email: 'guest@example.org', role: 'OPT-PARTICIPANT', status: 'ACCEPTED' },
    ],
};

describe('the .ics file', () => {
    it('escapes text as RFC 5545 asks', () => {
        expect(escapeIcsText('a;b,c\\d\nnext')).toBe('a\\;b\\,c\\\\d\\nnext');
    });

    it('writes instants as UTC date-times', () => {
        expect(icsUtc(new Date('2026-11-03T15:00:00.000Z'))).toBe('20261103T150000Z');
    });

    it('folds a long line at 75 octets with a space, without splitting a character', () => {
        const folded = foldIcsLine('DESCRIPTION:' + 'x'.repeat(100));
        const lines = folded.split('\r\n');
        expect(lines).toHaveLength(2);
        expect(new TextEncoder().encode(lines[0]).length).toBe(75);
        expect(lines[1].startsWith(' ')).toBe(true);
        const accented = foldIcsLine('SUMMARY:' + 'é'.repeat(60)); // 2 bytes each
        for (const line of accented.split('\r\n')) expect(new TextEncoder().encode(line).length).toBeLessThanOrEqual(75);
        expect(accented.replace(/\r\n /g, '')).toBe('SUMMARY:' + 'é'.repeat(60));
    });

    it('holds one event with the method, UID, DTSTAMP, times, people and the escaped text', () => {
        const ics = buildMeetingIcs(meeting);
        const unfolded = ics.replace(/\r\n /g, '');
        expect(ics.endsWith('\r\n')).toBe(true);
        expect(ics).not.toMatch(/[^\r]\n/);
        for (const line of [
            'BEGIN:VCALENDAR',
            'METHOD:REQUEST',
            'UID:C1000001-0000-4000-8000-00000000AAAA',
            'DTSTAMP:20261014T120000Z',
            'SEQUENCE:0',
            'DTSTART:20261103T150000Z',
            'DTEND:20261103T160000Z',
            'SUMMARY:Board prep\\; agenda\\, numbers',
            'STATUS:CONFIRMED',
            'DESCRIPTION:Line one\\nLine two\\, with a comma',
            'LOCATION:Room 4B',
            'ORGANIZER;CN=Ada Owner:mailto:ada@example.org',
            'ATTENDEE;CN=Sam Member;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE:mailto:sam@example.org',
            'ATTENDEE;ROLE=OPT-PARTICIPANT;PARTSTAT=ACCEPTED;RSVP=TRUE:mailto:guest@example.org',
            'END:VEVENT',
        ]) expect(unfolded).toContain(line + '\r\n');
    });

    it('cancels with METHOD:CANCEL, STATUS:CANCELLED and the next sequence, keeping the UID', () => {
        const ics = buildMeetingIcs({ ...meeting, method: 'CANCEL', sequence: 2 });
        expect(ics).toContain('METHOD:CANCEL\r\n');
        expect(ics).toContain('STATUS:CANCELLED\r\n');
        expect(ics).toContain('SEQUENCE:2\r\n');
        expect(ics).toContain('UID:C1000001-0000-4000-8000-00000000AAAA\r\n');
    });

    it('quotes a name that carries a reserved character', () => {
        const ics = buildMeetingIcs({ ...meeting, organizer: { email: 'o@example.org', name: 'Owner, Ada' } });
        expect(ics).toContain('ORGANIZER;CN="Owner, Ada":mailto:o@example.org');
    });
});
