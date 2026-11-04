/**
 * How the widgets say when a meeting is: in the meeting's own zone, and in the viewer's when that differs. Built on
 * Intl, so no library is needed in the browser.
 */
import type { MeetingLocationType, MeetingStatus, ResponseStatus } from './types';

/** The zone the browser runs in. */
export function viewerTimeZone(): string {
    try {
        return Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC';
    } catch {
        return 'UTC';
    }
}

/** Whether Intl knows the zone. */
export function knownTimeZone(zone: string | null | undefined): boolean {
    if (!zone) return false;
    try {
        new Intl.DateTimeFormat('en-US', { timeZone: zone });
        return true;
    } catch {
        return false;
    }
}

const safeZone = (zone: string | null | undefined): string => (knownTimeZone(zone) ? (zone as string) : 'UTC');

export function formatDay(instant: Date, zone: string): string {
    return new Intl.DateTimeFormat('en-US', { timeZone: safeZone(zone), weekday: 'short', month: 'short', day: 'numeric' }).format(instant);
}

export function formatDayLong(instant: Date, zone: string): string {
    return new Intl.DateTimeFormat('en-US', { timeZone: safeZone(zone), weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' }).format(instant);
}

export function formatTime(instant: Date, zone: string): string {
    return new Intl.DateTimeFormat('en-US', { timeZone: safeZone(zone), hour: 'numeric', minute: '2-digit' }).format(instant);
}

/** The zone's short name at that instant: CST, EDT, GMT+1. */
export function zoneAbbreviation(instant: Date, zone: string): string {
    const parts = new Intl.DateTimeFormat('en-US', { timeZone: safeZone(zone), timeZoneName: 'short' }).formatToParts(instant);
    return parts.find((part) => part.type === 'timeZoneName')?.value ?? safeZone(zone);
}

/** "9:00 – 10:00 AM CST", in the given zone. */
export function formatSpan(startsAt: Date, endsAt: Date, zone: string): string {
    return `${formatTime(startsAt, zone)} – ${formatTime(endsAt, zone)} ${zoneAbbreviation(startsAt, zone)}`;
}

/**
 * "Tue, Nov 3 · 9:00 – 10:00 AM CST" with ", 10:00 AM EST for you" when the viewer's zone differs and shows a different
 * clock time.
 */
export function formatWhen(startsAt: Date, endsAt: Date, meetingZone: string, viewerZone: string = viewerTimeZone()): string {
    const own = `${formatDay(startsAt, meetingZone)} · ${formatSpan(startsAt, endsAt, meetingZone)}`;
    if (safeZone(viewerZone) === safeZone(meetingZone)) return own;
    const mine = `${formatTime(startsAt, viewerZone)} ${zoneAbbreviation(startsAt, viewerZone)}`;
    return mine === `${formatTime(startsAt, meetingZone)} ${zoneAbbreviation(startsAt, meetingZone)}` ? own : `${own}, ${mine} for you`;
}

export function minutesBetween(startsAt: Date, endsAt: Date): number {
    return Math.max(0, Math.round((endsAt.getTime() - startsAt.getTime()) / 60000));
}

/** "45 min", "1 h", "1 h 30 min". */
export function formatMinutes(minutes: number | null | undefined): string {
    if (minutes == null || Number.isNaN(minutes)) return '—';
    const hours = Math.floor(minutes / 60);
    const rest = minutes % 60;
    if (!hours) return `${rest} min`;
    return rest ? `${hours} h ${rest} min` : `${hours} h`;
}

/** "mm:ss" or "h:mm:ss" for a timer. */
export function formatElapsed(seconds: number): string {
    const s = Math.max(0, Math.floor(seconds));
    const hours = Math.floor(s / 3600);
    const minutes = Math.floor((s % 3600) / 60);
    const rest = s % 60;
    const mm = String(minutes).padStart(2, '0');
    const ss = String(rest).padStart(2, '0');
    return hours ? `${hours}:${mm}:${ss}` : `${mm}:${ss}`;
}

export function statusLabel(status: MeetingStatus): string {
    return status === 'InProgress' ? 'In progress' : status;
}

export function statusChipClass(status: MeetingStatus): string {
    switch (status) {
        case 'InProgress':
            return 'mjt-chip mjt-chip--info';
        case 'Completed':
            return 'mjt-chip mjt-chip--ok';
        case 'Cancelled':
            return 'mjt-chip mjt-chip--error';
        case 'Postponed':
            return 'mjt-chip mjt-chip--warn';
        case 'Draft':
            return 'mjt-chip';
        case 'Scheduled':
        default:
            return 'mjt-chip mjt-chip--brand';
    }
}

export function responseLabel(response: ResponseStatus | null): string {
    switch (response) {
        case 'Accepted':
            return 'Going';
        case 'Tentative':
            return 'Maybe';
        case 'Declined':
            return 'Not going';
        case 'None':
            return 'No answer yet';
        default:
            return 'Not invited';
    }
}

export function locationLabel(locationType: MeetingLocationType, location: string | null, joinUrl: string | null): string {
    switch (locationType) {
        case 'InPerson':
            return location || 'In person';
        case 'Hybrid':
            return location ? `${location}, and online` : 'In person and online';
        case 'Phone':
            return location || 'By phone';
        case 'Virtual':
        default:
            return joinUrl ? 'Online' : 'Online (no link yet)';
    }
}

/** A local-time value for `<input type="datetime-local">`: the instant's wall clock in the zone. */
export function toLocalInputValue(instant: Date, zone: string): string {
    const parts = new Intl.DateTimeFormat('en-US', { timeZone: safeZone(zone), year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', hour12: false }).formatToParts(instant);
    const get = (type: string): string => parts.find((part) => part.type === type)?.value ?? '00';
    const hour = get('hour') === '24' ? '00' : get('hour');
    return `${get('year')}-${get('month')}-${get('day')}T${hour}:${get('minute')}`;
}

/** The instant a `<input type="datetime-local">` value means in the zone. */
export function fromLocalInputValue(value: string, zone: string): Date | null {
    const match = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})/.exec(value ?? '');
    if (!match) return null;
    const [, y, mo, d, h, mi] = match.map(Number);
    // Find the UTC instant whose wall clock in the zone is the value: start from the naive UTC guess and correct by the zone's offset
    const guess = Date.UTC(y, mo - 1, d, h, mi);
    const offsetAt = (instant: number): number => {
        const parts = new Intl.DateTimeFormat('en-US', { timeZone: safeZone(zone), year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', hour12: false }).formatToParts(new Date(instant));
        const get = (type: string): number => Number(parts.find((part) => part.type === type)?.value ?? '0');
        const hour = get('hour') === 24 ? 0 : get('hour');
        return Date.UTC(get('year'), get('month') - 1, get('day'), hour, get('minute')) - instant;
    };
    let instant = guess - offsetAt(guess);
    instant = guess - offsetAt(instant); // once more, for an instant on the far side of a transition
    return new Date(instant);
}
