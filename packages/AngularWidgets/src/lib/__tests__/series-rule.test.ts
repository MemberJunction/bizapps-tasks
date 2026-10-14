import { describe, it, expect } from 'vitest';
import { buildRecurrenceRule, describeRecurrenceRule, parseRecurrenceRuleDraft } from '../series-rule';

describe('the series editor\'s rule', () => {
    it('writes a weekly rule on days, with an interval and a count', () => {
        expect(buildRecurrenceRule({ frequency: 'WEEKLY', interval: 2, byDay: ['TH', 'TU'], ends: 'count', until: null, count: 10 })).toBe('FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH;COUNT=10');
    });

    it('writes an end date as the end of that day, UTC', () => {
        expect(buildRecurrenceRule({ frequency: 'DAILY', interval: 1, byDay: [], ends: 'until', until: new Date('2026-12-31T00:00:00Z'), count: null })).toBe('FREQ=DAILY;UNTIL=20261231T235959Z');
    });

    it('reads its own rules back, and refuses one it does not express', () => {
        expect(parseRecurrenceRuleDraft('RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH;COUNT=10')).toEqual({ frequency: 'WEEKLY', interval: 2, byDay: ['TU', 'TH'], ends: 'count', until: null, count: 10 });
        expect(parseRecurrenceRuleDraft('FREQ=MONTHLY;UNTIL=20261231T235959Z')?.ends).toBe('until');
        expect(parseRecurrenceRuleDraft('FREQ=YEARLY')).toBeNull();
        expect(parseRecurrenceRuleDraft('FREQ=MONTHLY;BYMONTHDAY=15')).toBeNull();
        expect(parseRecurrenceRuleDraft('')).toBeNull();
    });

    it('says the rule in words', () => {
        expect(describeRecurrenceRule({ frequency: 'WEEKLY', interval: 2, byDay: ['TU', 'TH'], ends: 'count', until: null, count: 10 })).toBe('Every 2 weeks on Tuesday and Thursday, 10 times');
        expect(describeRecurrenceRule({ frequency: 'DAILY', interval: 1, byDay: [], ends: 'never', until: null, count: null })).toBe('Every day');
        expect(describeRecurrenceRule({ frequency: 'MONTHLY', interval: 1, byDay: [], ends: 'until', until: new Date('2026-12-31T23:59:59Z'), count: null })).toBe('Every month, until Dec 31, 2026');
    });
});
