/**
 * A meeting as an iCalendar file (the meetings plan, § 6): one VEVENT, METHOD:REQUEST or METHOD:CANCEL, with a DTSTAMP,
 * the meeting's UID (the calendar link's iCalendar UID when there is one, else the meeting's ID, so an imported file and
 * an invitation hold one event, not two), times as UTC instants, text escaped as RFC 5545 asks, and lines folded at 75
 * octets. It needs nothing from a calendar provider.
 */
export interface IcsPerson {
    email: string;
    name?: string | null;
}

export interface IcsAttendee extends IcsPerson {
    role?: 'REQ-PARTICIPANT' | 'OPT-PARTICIPANT';
    status?: 'NEEDS-ACTION' | 'ACCEPTED' | 'TENTATIVE' | 'DECLINED';
}

export interface IcsMeeting {
    uid: string;
    method: 'REQUEST' | 'CANCEL';
    summary: string;
    startsAt: Date;
    endsAt: Date;
    /** When the file was made. Given, not taken from the clock, so a file can be reproduced. */
    dtstamp: Date;
    /** The revision of the event; a change or a cancellation sends a higher one. Default 0. */
    sequence?: number;
    description?: string | null;
    location?: string | null;
    url?: string | null;
    organizer?: IcsPerson | null;
    attendees?: readonly IcsAttendee[];
    /** The product that made the file, for PRODID. */
    product?: string;
}

const CRLF = '\r\n';

/** Text as RFC 5545 § 3.3.11 wants it: backslash, semicolon and comma escaped, newlines as \n. */
export function escapeIcsText(text: string): string {
    return text.replace(/\\/g, '\\\\').replace(/;/g, '\\;').replace(/,/g, '\\,').replace(/\r\n|\r|\n/g, '\\n');
}

/** An instant as an iCalendar UTC date-time: 20261103T150000Z. */
export function icsUtc(instant: Date): string {
    return instant.toISOString().replace(/[-:]/g, '').replace(/\.\d{3}Z$/, 'Z');
}

/**
 * A content line folded at 75 octets (RFC 5545 § 3.1): a long line continues on the next line after one space. The
 * split never lands inside a multi-byte character.
 */
export function foldIcsLine(line: string): string {
    const LIMIT = 75;
    const encoder = new TextEncoder();
    const out: string[] = [];
    let current = '';
    let currentBytes = 0;
    let first = true;
    for (const char of line) {
        const bytes = encoder.encode(char).length;
        const room = first ? LIMIT : LIMIT - 1; // a continuation line starts with the space, which counts
        if (currentBytes + bytes > room) {
            out.push(first ? current : ` ${current}`);
            first = false;
            current = char;
            currentBytes = bytes;
        } else {
            current += char;
            currentBytes += bytes;
        }
    }
    out.push(first ? current : ` ${current}`);
    return out.join(CRLF);
}

function person(role: 'ORGANIZER' | 'ATTENDEE', who: IcsPerson, params: string[] = []): string {
    const all = [...(who.name ? [`CN=${escapeParam(who.name)}`] : []), ...params];
    return `${role}${all.length ? ';' + all.join(';') : ''}:mailto:${who.email}`;
}

/** A parameter value: quoted when it carries a character the grammar reserves, double quotes dropped. */
function escapeParam(value: string): string {
    const clean = value.replace(/"/g, '');
    return /[;:,]/.test(clean) ? `"${clean}"` : clean;
}

/** The whole file, lines ending in CRLF, folded. */
export function buildMeetingIcs(meeting: IcsMeeting): string {
    const lines: string[] = [
        'BEGIN:VCALENDAR',
        'VERSION:2.0',
        `PRODID:-//${escapeIcsText(meeting.product ?? 'MemberJunction BizApps Tasks')}//EN`,
        'CALSCALE:GREGORIAN',
        `METHOD:${meeting.method}`,
        'BEGIN:VEVENT',
        `UID:${meeting.uid}`,
        `DTSTAMP:${icsUtc(meeting.dtstamp)}`,
        `SEQUENCE:${meeting.sequence ?? 0}`,
        `DTSTART:${icsUtc(meeting.startsAt)}`,
        `DTEND:${icsUtc(meeting.endsAt)}`,
        `SUMMARY:${escapeIcsText(meeting.summary)}`,
        `STATUS:${meeting.method === 'CANCEL' ? 'CANCELLED' : 'CONFIRMED'}`,
    ];
    if (meeting.description) lines.push(`DESCRIPTION:${escapeIcsText(meeting.description)}`);
    if (meeting.location) lines.push(`LOCATION:${escapeIcsText(meeting.location)}`);
    if (meeting.url) lines.push(`URL:${meeting.url}`);
    if (meeting.organizer) lines.push(person('ORGANIZER', meeting.organizer));
    for (const attendee of meeting.attendees ?? []) {
        lines.push(person('ATTENDEE', attendee, [`ROLE=${attendee.role ?? 'REQ-PARTICIPANT'}`, `PARTSTAT=${attendee.status ?? 'NEEDS-ACTION'}`, 'RSVP=TRUE']));
    }
    lines.push('END:VEVENT', 'END:VCALENDAR');
    return lines.map(foldIcsLine).join(CRLF) + CRLF;
}
