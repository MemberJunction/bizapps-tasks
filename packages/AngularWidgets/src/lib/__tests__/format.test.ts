import { describe, it, expect } from 'vitest';
import { formatElapsed, formatMinutes, formatWhen, fromLocalInputValue, knownTimeZone, locationLabel, statusChipClass, toLocalInputValue, zoneAbbreviation } from '../format';

const start = new Date('2026-11-03T15:00:00Z'); // 9:00 CST, 10:00 EST
const end = new Date('2026-11-03T16:00:00Z');

describe('when a meeting is', () => {
    it('says the day and span in the meeting\'s zone, and the viewer\'s time when it differs', () => {
        expect(formatWhen(start, end, 'America/Chicago', 'America/Chicago')).toBe('Tue, Nov 3 · 9:00 AM – 10:00 AM CST');
        expect(formatWhen(start, end, 'America/Chicago', 'America/New_York')).toBe('Tue, Nov 3 · 9:00 AM – 10:00 AM CST, 10:00 AM EST for you');
    });

    it('falls back to UTC for a zone Intl does not know', () => {
        expect(knownTimeZone('Central Time')).toBe(false);
        expect(zoneAbbreviation(start, 'Central Time')).toBe('UTC');
    });

    it('round-trips a datetime-local value through the zone, across the end of daylight saving', () => {
        expect(toLocalInputValue(start, 'America/Chicago')).toBe('2026-11-03T09:00');
        expect(fromLocalInputValue('2026-11-03T09:00', 'America/Chicago')!.toISOString()).toBe('2026-11-03T15:00:00.000Z');
        expect(fromLocalInputValue('2026-10-27T09:00', 'America/Chicago')!.toISOString()).toBe('2026-10-27T14:00:00.000Z');
        expect(fromLocalInputValue('nope', 'America/Chicago')).toBeNull();
    });
});

describe('labels', () => {
    it('writes minutes and timers', () => {
        expect(formatMinutes(45)).toBe('45 min');
        expect(formatMinutes(60)).toBe('1 h');
        expect(formatMinutes(90)).toBe('1 h 30 min');
        expect(formatMinutes(null)).toBe('—');
        expect(formatElapsed(65)).toBe('01:05');
        expect(formatElapsed(3725)).toBe('1:02:05');
    });

    it('names the place', () => {
        expect(locationLabel('Virtual', null, 'https://x')).toBe('Online');
        expect(locationLabel('InPerson', 'Room 4B', null)).toBe('Room 4B');
        expect(locationLabel('Hybrid', 'Room 4B', null)).toBe('Room 4B, and online');
    });

    it('colours the status', () => {
        expect(statusChipClass('InProgress')).toContain('info');
        expect(statusChipClass('Cancelled')).toContain('error');
    });
});
