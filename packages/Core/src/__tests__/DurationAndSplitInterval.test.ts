import { describe, expect, it } from 'vitest';
import {
    ApplyMinuteRounding,
    FormatDurationClock,
    FormatDurationMinutes,
    ParseDurationMinutes,
} from '../time/DurationFormatting.js';
import { SplitIntervalByBusinessDay } from '../time/SplitIntervalByBusinessDay.js';

describe('DurationFormatting', () => {
    it('parses hours+minutes, decimal hours, colon notation, and plain minutes', () => {
        expect(ParseDurationMinutes('1h 30m')).toBe(90);
        expect(ParseDurationMinutes('2 hrs 15 mins')).toBe(135);
        expect(ParseDurationMinutes('1.5h')).toBe(90);
        expect(ParseDurationMinutes('1.5')).toBe(90);
        expect(ParseDurationMinutes('0.25')).toBe(15);
        expect(ParseDurationMinutes('90m')).toBe(90);
        expect(ParseDurationMinutes('90')).toBe(90);
        expect(ParseDurationMinutes('1:30')).toBe(90);
        expect(ParseDurationMinutes('0:05')).toBe(5);
        expect(ParseDurationMinutes(45)).toBe(45);
    });

    it('returns null on empty, zero, negative, or malformed input', () => {
        expect(ParseDurationMinutes('')).toBeNull();
        expect(ParseDurationMinutes('   ')).toBeNull();
        expect(ParseDurationMinutes('0')).toBeNull();
        expect(ParseDurationMinutes('0:00')).toBeNull();
        expect(ParseDurationMinutes(0)).toBeNull();
        expect(ParseDurationMinutes(-30)).toBeNull();
        expect(ParseDurationMinutes('abc')).toBeNull();
        expect(ParseDurationMinutes('1:75')).toBeNull();
        expect(ParseDurationMinutes(null)).toBeNull();
        expect(ParseDurationMinutes(undefined)).toBeNull();
    });

    it('formats durations as human labels and clock strings', () => {
        expect(FormatDurationMinutes(0)).toBe('0m');
        expect(FormatDurationMinutes(null)).toBe('0m');
        expect(FormatDurationMinutes(45)).toBe('45m');
        expect(FormatDurationMinutes(60)).toBe('1h');
        expect(FormatDurationMinutes(90)).toBe('1h 30m');

        expect(FormatDurationClock(0)).toBe('');
        expect(FormatDurationClock(null)).toBe('');
        expect(FormatDurationClock(30)).toBe('0:30');
        expect(FormatDurationClock(90)).toBe('1:30');
        expect(FormatDurationClock(125)).toBe('2:05');
    });

    it('applies upward minute rounding increments with [1, 1440] clamping', () => {
        expect(ApplyMinuteRounding(0, 0)).toBe(1);
        expect(ApplyMinuteRounding(7, 0)).toBe(7);
        expect(ApplyMinuteRounding(7, 5)).toBe(10);
        expect(ApplyMinuteRounding(7, 6)).toBe(12);
        expect(ApplyMinuteRounding(7, 15)).toBe(15);
        expect(ApplyMinuteRounding(15, 15)).toBe(15);
        expect(ApplyMinuteRounding(16, 15)).toBe(30);
        expect(ApplyMinuteRounding(2000, 15)).toBe(1440);
    });
});

describe('SplitIntervalByBusinessDay', () => {
    it('keeps a single-day interval in one segment', () => {
        const start = new Date('2026-11-04T14:00:00.000Z');
        const end = new Date('2026-11-04T15:30:00.000Z');
        const segments = SplitIntervalByBusinessDay(start, end, 'UTC');

        expect(segments).toHaveLength(1);
        expect(segments[0].WorkDate).toBe('2026-11-04');
        expect(segments[0].RawMinutes).toBe(90);
        expect(segments[0].Minutes).toBe(90);
        expect(segments[0].StartedAt.toISOString()).toBe('2026-11-04T14:00:00.000Z');
        expect(segments[0].EndedAt.toISOString()).toBe('2026-11-04T15:30:00.000Z');
    });

    it('splits across local midnight in a non-UTC timezone (America/New_York)', () => {
        // 2026-11-04 23:00 EST (04:00 UTC on Nov 5) to 2026-11-05 01:30 EST (06:30 UTC on Nov 5)
        const start = new Date('2026-11-05T04:00:00.000Z');
        const end = new Date('2026-11-05T06:30:00.000Z');
        const segments = SplitIntervalByBusinessDay(start, end, 'America/New_York');

        expect(segments).toHaveLength(2);
        expect(segments[0].WorkDate).toBe('2026-11-04');
        expect(segments[0].Minutes).toBe(60);
        expect(segments[0].EndedAt.toISOString()).toBe('2026-11-05T05:00:00.000Z');

        expect(segments[1].WorkDate).toBe('2026-11-05');
        expect(segments[1].Minutes).toBe(90);
        expect(segments[1].StartedAt.toISOString()).toBe('2026-11-05T05:00:00.000Z');
    });

    it('splits a multi-day timer into one segment per calendar day', () => {
        // 2026-11-02 22:00 UTC through 2026-11-04 02:00 UTC -> 3 calendar days
        const start = new Date('2026-11-02T22:00:00.000Z');
        const end = new Date('2026-11-04T02:00:00.000Z');
        const segments = SplitIntervalByBusinessDay(start, end, 'UTC');

        expect(segments.map((s) => ({ day: s.WorkDate, mins: s.Minutes }))).toEqual([
            { day: '2026-11-02', mins: 120 },
            { day: '2026-11-03', mins: 1440 },
            { day: '2026-11-04', mins: 120 },
        ]);
    });

    it('handles DST spring-forward (23-hour day) and fall-back (25-hour day) in America/New_York', () => {
        // 2026-03-08 is US spring-forward (clocks jump 02:00 EST -> 03:00 EDT; day is 23 hours = 1380 mins)
        const springStart = new Date('2026-03-08T05:00:00.000Z'); // 2026-03-08 00:00 EST
        const springEnd = new Date('2026-03-09T04:00:00.000Z'); // 2026-03-09 00:00 EDT
        const springSegs = SplitIntervalByBusinessDay(springStart, springEnd, 'America/New_York');
        expect(springSegs).toHaveLength(1);
        expect(springSegs[0].WorkDate).toBe('2026-03-08');
        expect(springSegs[0].Minutes).toBe(23 * 60);

        // 2026-11-01 is US fall-back (25-hour day = 1500 raw mins, capped at 1440 per entry)
        const fallStart = new Date('2026-11-01T04:00:00.000Z'); // 2026-11-01 00:00 EDT
        const fallEnd = new Date('2026-11-02T05:00:00.000Z'); // 2026-11-02 00:00 EST
        const fallSegs = SplitIntervalByBusinessDay(fallStart, fallEnd, 'America/New_York');
        expect(fallSegs).toHaveLength(1);
        expect(fallSegs[0].WorkDate).toBe('2026-11-01');
        expect(fallSegs[0].Minutes).toBe(1440);
    });

    it('drops zero-minute tail pieces and returns a 1-minute piece when total duration < 30 seconds', () => {
        // Crosses midnight by only 10 seconds -> second piece rounds to 0 and is dropped
        const start = new Date('2026-11-04T23:30:00.000Z');
        const end = new Date('2026-11-05T00:00:10.000Z');
        const segs = SplitIntervalByBusinessDay(start, end, 'UTC');
        expect(segs).toHaveLength(1);
        expect(segs[0].WorkDate).toBe('2026-11-04');
        expect(segs[0].Minutes).toBe(30);

        // 12-second total timer -> returns 1-minute piece on start day
        const briefStart = new Date('2026-11-04T10:00:00.000Z');
        const briefEnd = new Date('2026-11-04T10:00:12.000Z');
        const briefSegs = SplitIntervalByBusinessDay(briefStart, briefEnd, 'UTC');
        expect(briefSegs).toHaveLength(1);
        expect(briefSegs[0].WorkDate).toBe('2026-11-04');
        expect(briefSegs[0].Minutes).toBe(1);
    });
});
