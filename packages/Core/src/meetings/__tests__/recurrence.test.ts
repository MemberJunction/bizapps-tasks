import { describe, it, expect } from 'vitest';
import { expandOccurrences, normalizeRecurrenceRule, recurrenceRuleProblem, seriesHasEnded } from '../recurrence.js';

// A weekly 9:00 Tuesday meeting in Chicago, first on 2026-10-20 (CDT, UTC-5). Daylight saving ends 2026-11-01.
const weekly = { rule: 'FREQ=WEEKLY;BYDAY=TU', timeZone: 'America/Chicago', firstStartsAt: new Date('2026-10-20T14:00:00Z'), durationMinutes: 60 };

describe('a series\' rule', () => {
    it('is read with or without its RRULE: prefix', () => {
        expect(normalizeRecurrenceRule('RRULE:FREQ=WEEKLY;BYDAY=TU')).toBe('FREQ=WEEKLY;BYDAY=TU');
        expect(recurrenceRuleProblem('RRULE:FREQ=WEEKLY;BYDAY=TU')).toBeNull();
    });

    it('must name a frequency and parse', () => {
        expect(recurrenceRuleProblem('')).toMatch(/needs a recurrence rule/);
        expect(recurrenceRuleProblem('BYDAY=TU')).toMatch(/names its frequency/);
        expect(recurrenceRuleProblem('FREQ=SOMETIMES')).toMatch(/could not be read/);
    });
});

describe('a series\' occurrences', () => {
    it('keep their wall-clock time across the end of daylight saving', () => {
        const got = expandOccurrences(weekly, { from: new Date('2026-10-20T00:00:00Z'), through: new Date('2026-11-11T00:00:00Z') });
        expect(got.map((o) => o.startsAt.toISOString())).toEqual([
            '2026-10-20T14:00:00.000Z', // 9:00 CDT
            '2026-10-27T14:00:00.000Z', // 9:00 CDT
            '2026-11-03T15:00:00.000Z', // 9:00 CST: the instant moved an hour, the wall clock did not
            '2026-11-10T15:00:00.000Z',
        ]);
        expect(got[2].endsAt.toISOString()).toBe('2026-11-03T16:00:00.000Z');
    });

    it('name each occurrence by its slot, so a moved one keeps its identity', () => {
        const [first] = expandOccurrences(weekly, { from: new Date('2026-10-20T00:00:00Z'), through: new Date('2026-10-21T00:00:00Z') });
        expect(first.occurrenceStartsAt.toISOString()).toBe(first.startsAt.toISOString());
    });

    it('stop at COUNT and at UNTIL', () => {
        const counted = { ...weekly, rule: 'FREQ=WEEKLY;BYDAY=TU;COUNT=2' };
        expect(expandOccurrences(counted, { from: new Date('2026-10-01T00:00:00Z'), through: new Date('2027-01-01T00:00:00Z') })).toHaveLength(2);
        const until = { ...weekly, rule: 'FREQ=WEEKLY;BYDAY=TU;UNTIL=20261028T000000Z' };
        expect(expandOccurrences(until, { from: new Date('2026-10-01T00:00:00Z'), through: new Date('2027-01-01T00:00:00Z') })).toHaveLength(2);
        expect(seriesHasEnded(until, new Date('2026-11-01T00:00:00Z'))).toBe(true);
        expect(seriesHasEnded(weekly, new Date('2026-11-01T00:00:00Z'))).toBe(false);
    });

    it('take only the window, and no more than max', () => {
        const got = expandOccurrences(weekly, { from: new Date('2026-10-26T00:00:00Z'), through: new Date('2026-12-31T00:00:00Z') }, 3);
        expect(got).toHaveLength(3);
        expect(got[0].startsAt.toISOString()).toBe('2026-10-27T14:00:00.000Z');
        expect(expandOccurrences(weekly, { from: new Date('2026-12-01T00:00:00Z'), through: new Date('2026-11-01T00:00:00Z') })).toEqual([]);
    });

    it('refuse a bad rule, zone or duration before expanding', () => {
        expect(() => expandOccurrences({ ...weekly, rule: 'BYDAY=TU' }, { from: new Date(), through: new Date() })).toThrow(/frequency/);
        expect(() => expandOccurrences({ ...weekly, timeZone: 'Central' }, { from: new Date(), through: new Date() })).toThrow(/not a time zone/);
        expect(() => expandOccurrences({ ...weekly, durationMinutes: 0 }, { from: new Date(), through: new Date() })).toThrow(/more than 0/);
    });
});
