import { DateTime } from 'luxon';
import rrule from 'rrule';

// rrule ships a CommonJS main whose named exports Node's ESM loader cannot see: take them off the default export
const { RRule, rrulestr } = rrule;
import { isValidTimeZone } from './meeting-times.js';

/**
 * A series' rule, expanded in the series' own time zone (the meetings plan, § 2.2 and § 3): the rule is an RFC 5545
 * RRULE value such as FREQ=WEEKLY;BYDAY=TU, and a 9:00 meeting stays at 9:00 across daylight-saving changes because the
 * rule runs over wall-clock times in that zone, not over instants.
 *
 * How: the first start is taken apart into its wall-clock parts in the zone, the rule is run over "floating" times
 * (those parts read as UTC, which is how rrule works without a zone), and each result is put back together in the zone to
 * give the instant it means there. An UNTIL in the rule is compared in the same floating space.
 */
export interface SeriesRecurrence {
    /** The RRULE value, with or without the leading `RRULE:`. */
    rule: string;
    /** The IANA zone the rule is expanded in. */
    timeZone: string;
    /** The rule's DTSTART: when the first occurrence starts. */
    firstStartsAt: Date;
    /** How long each occurrence lasts. */
    durationMinutes: number;
}

export interface SeriesOccurrence {
    /** The series' slot for this occurrence, which names it even after it moves (Meeting.OccurrenceStartsAt). */
    occurrenceStartsAt: Date;
    startsAt: Date;
    endsAt: Date;
}

const RULE_PREFIX = /^\s*RRULE:/i;

/** The rule's value without a `RRULE:` prefix, trimmed. */
export function normalizeRecurrenceRule(rule: string): string {
    return rule.replace(RULE_PREFIX, '').trim();
}

/** What is wrong with a rule, or null when it parses and names a frequency. */
export function recurrenceRuleProblem(rule: string | null | undefined): string | null {
    if (!rule || !rule.trim()) return 'A series needs a recurrence rule, such as FREQ=WEEKLY;BYDAY=TU.';
    const value = normalizeRecurrenceRule(rule);
    if (!/(^|;)FREQ=/i.test(value)) return 'A recurrence rule names its frequency: FREQ=DAILY, WEEKLY, MONTHLY or YEARLY.';
    try {
        const parsed = rrulestr(`RRULE:${value}`);
        if (!(parsed instanceof RRule)) return 'A series takes one RRULE, not a set.';
        return null;
    } catch (error) {
        return `The recurrence rule could not be read: ${error instanceof Error ? error.message : String(error)}`;
    }
}

/** The wall-clock parts of an instant in a zone, read as if they were UTC: rrule's floating time. */
function toFloating(instant: Date, zone: string): Date {
    const local = DateTime.fromJSDate(instant, { zone });
    return new Date(Date.UTC(local.year, local.month - 1, local.day, local.hour, local.minute, local.second));
}

/** A floating time's parts, put back together in the zone: the instant it means there. */
function fromFloating(floating: Date, zone: string): Date {
    return DateTime.fromObject(
        {
            year: floating.getUTCFullYear(),
            month: floating.getUTCMonth() + 1,
            day: floating.getUTCDate(),
            hour: floating.getUTCHours(),
            minute: floating.getUTCMinutes(),
            second: floating.getUTCSeconds(),
        },
        { zone },
    ).toJSDate();
}

/**
 * The occurrences of a series whose start falls in the window, inclusive, oldest first, at most `max` of them.
 * Throws when the rule or the zone is wrong; check with recurrenceRuleProblem and isValidTimeZone first.
 */
export function expandOccurrences(series: SeriesRecurrence, window: { from: Date; through: Date }, max = 500): SeriesOccurrence[] {
    const problem = recurrenceRuleProblem(series.rule);
    if (problem) throw new Error(problem);
    if (!isValidTimeZone(series.timeZone)) throw new Error(`"${series.timeZone}" is not a time zone.`);
    if (!(series.durationMinutes > 0)) throw new Error('A series\' occurrences last more than 0 minutes.');
    if (window.through.getTime() < window.from.getTime()) return [];

    const options = RRule.parseString(normalizeRecurrenceRule(series.rule));
    const rule = new RRule({ ...options, dtstart: toFloating(series.firstStartsAt, series.timeZone) });
    const starts = rule.between(toFloating(window.from, series.timeZone), toFloating(window.through, series.timeZone), true);
    return starts.slice(0, max).map((floating) => {
        const startsAt = fromFloating(floating, series.timeZone);
        return { occurrenceStartsAt: startsAt, startsAt, endsAt: new Date(startsAt.getTime() + series.durationMinutes * 60000) };
    });
}

/** Whether a rule has run out by an instant: an UNTIL or COUNT reached, read in the series' zone. */
export function seriesHasEnded(series: SeriesRecurrence, at: Date): boolean {
    const options = RRule.parseString(normalizeRecurrenceRule(series.rule));
    const rule = new RRule({ ...options, dtstart: toFloating(series.firstStartsAt, series.timeZone) });
    return rule.after(toFloating(at, series.timeZone), false) === null;
}
