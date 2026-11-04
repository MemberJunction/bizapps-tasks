import { describe, it, expect } from 'vitest';
import { isValidTimeZone, meetingTimeProblem, minutesBetween } from '../meeting-times.js';

describe('a meeting\'s times', () => {
    const start = new Date('2026-11-03T15:00:00Z');

    it('accepts an end later than the start in a real zone', () => {
        expect(meetingTimeProblem(start, new Date('2026-11-03T16:00:00Z'), 'America/Chicago')).toBeNull();
    });

    it('refuses an end at or before the start', () => {
        expect(meetingTimeProblem(start, start)).toBe('A meeting ends after it starts.');
        expect(meetingTimeProblem(start, new Date('2026-11-03T14:59:00Z'))).toBe('A meeting ends after it starts.');
    });

    it('asks for both times', () => {
        expect(meetingTimeProblem(null, start)).toBe('A meeting needs a start time.');
        expect(meetingTimeProblem(start, undefined)).toBe('A meeting needs an end time.');
    });

    it('refuses a zone that is not an IANA name', () => {
        expect(isValidTimeZone('America/Chicago')).toBe(true);
        expect(isValidTimeZone('Central Time')).toBe(false);
        expect(isValidTimeZone('')).toBe(false);
        expect(meetingTimeProblem(start, new Date('2026-11-03T16:00:00Z'), 'Central Time')).toMatch(/not a time zone/);
    });

    it('counts the minutes between', () => {
        expect(minutesBetween(start, new Date('2026-11-03T16:30:00Z'))).toBe(90);
    });
});
