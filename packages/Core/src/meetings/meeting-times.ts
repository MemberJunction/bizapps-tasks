import { IANAZone } from 'luxon';

/** Whether a string names an IANA time zone luxon knows, such as America/Chicago. */
export function isValidTimeZone(zone: string | null | undefined): boolean {
    return typeof zone === 'string' && zone.trim().length > 0 && IANAZone.isValidZone(zone);
}

/**
 * What is wrong with a meeting's times, or null: the end must be later than the start, and the zone must be a real one.
 * The database's CHECK says the same about the times; this says it first, in words.
 */
export function meetingTimeProblem(startsAt: Date | null | undefined, endsAt: Date | null | undefined, timeZone?: string | null): string | null {
    if (!startsAt || Number.isNaN(startsAt.getTime())) return 'A meeting needs a start time.';
    if (!endsAt || Number.isNaN(endsAt.getTime())) return 'A meeting needs an end time.';
    if (endsAt.getTime() <= startsAt.getTime()) return 'A meeting ends after it starts.';
    if (timeZone !== undefined && !isValidTimeZone(timeZone)) return `"${timeZone ?? ''}" is not a time zone. Use an IANA name such as America/Chicago.`;
    return null;
}

/** Minutes between two instants, rounded to the nearest minute. */
export function minutesBetween(startsAt: Date, endsAt: Date): number {
    return Math.round((endsAt.getTime() - startsAt.getTime()) / 60000);
}
