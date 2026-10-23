/**
 * The series editor's rule: a small, readable subset of RFC 5545 (daily, weekly on days, monthly; an interval; an end by
 * date or by count) written as the RRULE the server expands, and read back from one. Anything the editor does not
 * express is kept as text and shown as such.
 */
import type { SeriesRuleDraft } from './types';

export const WEEKDAYS: ReadonlyArray<{ code: string; label: string; short: string }> = [
    { code: 'MO', label: 'Monday', short: 'Mon' },
    { code: 'TU', label: 'Tuesday', short: 'Tue' },
    { code: 'WE', label: 'Wednesday', short: 'Wed' },
    { code: 'TH', label: 'Thursday', short: 'Thu' },
    { code: 'FR', label: 'Friday', short: 'Fri' },
    { code: 'SA', label: 'Saturday', short: 'Sat' },
    { code: 'SU', label: 'Sunday', short: 'Sun' },
];

export function emptySeriesRule(): SeriesRuleDraft {
    return { frequency: 'WEEKLY', interval: 1, byDay: [], ends: 'never', until: null, count: null };
}

const pad = (n: number): string => String(n).padStart(2, '0');

/** The RRULE value for the draft, without the `RRULE:` prefix. */
export function buildRecurrenceRule(draft: SeriesRuleDraft): string {
    const parts = [`FREQ=${draft.frequency}`];
    const interval = Math.max(1, Math.floor(draft.interval || 1));
    if (interval > 1) parts.push(`INTERVAL=${interval}`);
    if (draft.frequency === 'WEEKLY' && draft.byDay.length) {
        const order = WEEKDAYS.map((day) => day.code);
        parts.push(`BYDAY=${[...new Set(draft.byDay)].sort((a, b) => order.indexOf(a) - order.indexOf(b)).join(',')}`);
    }
    if (draft.ends === 'count' && draft.count && draft.count > 0) parts.push(`COUNT=${Math.floor(draft.count)}`);
    if (draft.ends === 'until' && draft.until) {
        const u = draft.until;
        parts.push(`UNTIL=${u.getUTCFullYear()}${pad(u.getUTCMonth() + 1)}${pad(u.getUTCDate())}T235959Z`);
    }
    return parts.join(';');
}

/** The draft a rule reads as, or null when the rule says something the editor does not express. */
export function parseRecurrenceRuleDraft(rule: string | null | undefined): SeriesRuleDraft | null {
    if (!rule) return null;
    const value = rule.replace(/^\s*RRULE:/i, '').trim();
    const draft = emptySeriesRule();
    for (const part of value.split(';').filter(Boolean)) {
        const [key, raw = ''] = part.split('=');
        const name = key.trim().toUpperCase();
        const text = raw.trim();
        switch (name) {
            case 'FREQ':
                if (text !== 'DAILY' && text !== 'WEEKLY' && text !== 'MONTHLY') return null;
                draft.frequency = text;
                break;
            case 'INTERVAL': {
                const interval = Number(text);
                if (!Number.isInteger(interval) || interval < 1) return null;
                draft.interval = interval;
                break;
            }
            case 'BYDAY': {
                const days = text.split(',').map((d) => d.trim().toUpperCase());
                if (days.some((d) => !WEEKDAYS.some((w) => w.code === d))) return null;
                draft.byDay = days;
                break;
            }
            case 'COUNT': {
                const count = Number(text);
                if (!Number.isInteger(count) || count < 1) return null;
                draft.ends = 'count';
                draft.count = count;
                break;
            }
            case 'UNTIL': {
                const match = /^(\d{4})(\d{2})(\d{2})/.exec(text);
                if (!match) return null;
                draft.ends = 'until';
                draft.until = new Date(Date.UTC(Number(match[1]), Number(match[2]) - 1, Number(match[3]), 23, 59, 59));
                break;
            }
            case 'WKST':
                break;
            default:
                return null;
        }
    }
    if (draft.frequency !== 'WEEKLY') draft.byDay = [];
    return draft;
}

/** The rule in words: "Every 2 weeks on Tuesday and Thursday, 10 times". */
export function describeRecurrenceRule(draft: SeriesRuleDraft): string {
    const interval = Math.max(1, Math.floor(draft.interval || 1));
    const unit = { DAILY: 'day', WEEKLY: 'week', MONTHLY: 'month' }[draft.frequency];
    let text = interval === 1 ? `Every ${unit}` : `Every ${interval} ${unit}s`;
    if (draft.frequency === 'WEEKLY' && draft.byDay.length) {
        const names = WEEKDAYS.filter((day) => draft.byDay.includes(day.code)).map((day) => day.label);
        const list = names.length > 1 ? `${names.slice(0, -1).join(', ')} and ${names[names.length - 1]}` : names[0];
        text += ` on ${list}`;
    }
    if (draft.ends === 'count' && draft.count) text += `, ${draft.count} time${draft.count === 1 ? '' : 's'}`;
    if (draft.ends === 'until' && draft.until) text += `, until ${new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric', year: 'numeric', timeZone: 'UTC' }).format(draft.until)}`;
    return text;
}
