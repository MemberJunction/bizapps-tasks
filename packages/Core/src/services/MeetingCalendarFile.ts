import { Metadata, RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import type { mjBizAppsTasksMeetingEntity } from '@mj-biz-apps/tasks-entities';
import { MEETING_ATTENDEE_ENTITY, MEETING_ENTITY } from '../meetings/entity-names.js';
import { buildMeetingIcs, type IcsAttendee, type IcsPerson } from '../meetings/ics.js';
import { PEOPLE_ENTITY } from '../meetings/person-user.js';

export interface CalendarFile {
    fileName: string;
    mimeType: 'text/calendar';
    content: string;
}

export interface CalendarFileOptions {
    /** The calendar link's iCalendar UID when there is one (T2); else the meeting's ID is the UID. */
    uid?: string | null;
    /** The revision; a change or a cancellation sends a higher one. Default 0. */
    sequence?: number;
    /** When the file was made. Default the clock. */
    dtstamp?: Date;
    /** The link attendees join by, when the meeting has none of its own. */
    url?: string | null;
}

interface AttendeeRow {
    PersonID: string | null;
    Email: string | null;
    DisplayName: string | null;
    Role: 'Organizer' | 'Required' | 'Optional';
    ResponseStatus: 'None' | 'Accepted' | 'Tentative' | 'Declined';
    Person: string | null;
}

interface PersonRow {
    ID: string;
    Email: string | null;
    DisplayName: string | null;
}

const PARTSTAT: Record<AttendeeRow['ResponseStatus'], IcsAttendee['status']> = { None: 'NEEDS-ACTION', Accepted: 'ACCEPTED', Tentative: 'TENTATIVE', Declined: 'DECLINED' };

/** The `.ics` for a meeting (the meetings plan, § 6): built on the server from the meeting and its attendees, with no calendar provider. */
export class MeetingCalendarFile {
    constructor(private readonly provider: IMetadataProvider = Metadata.Provider) {}

    async forMeeting(meetingId: string, method: 'REQUEST' | 'CANCEL', contextUser: UserInfo, options: CalendarFileOptions = {}): Promise<CalendarFile> {
        const meeting = await this.provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, contextUser);
        if (!(await meeting.Load(meetingId))) throw new Error(`Meeting ${meetingId} was not found.`);
        const attendees = await this.attendees(meeting.ID, contextUser);
        const people = await this.people([meeting.OrganizerPersonID, ...attendees.map((a) => a.PersonID)], contextUser);
        const organizerPerson = people.get(meeting.OrganizerPersonID.toLowerCase());
        const organizerRow = attendees.find((a) => a.Role === 'Organizer');
        const organizer: IcsPerson | null = this.person(organizerRow ?? null, organizerPerson);
        const others = attendees
            .filter((a) => a.Role !== 'Organizer')
            .map((a): IcsAttendee | null => {
                const who = this.person(a, a.PersonID ? people.get(a.PersonID.toLowerCase()) : undefined);
                return who ? { ...who, role: a.Role === 'Optional' ? 'OPT-PARTICIPANT' : 'REQ-PARTICIPANT', status: PARTSTAT[a.ResponseStatus] } : null;
            })
            .filter((a): a is IcsAttendee => a !== null);
        const content = buildMeetingIcs({
            uid: options.uid ?? meeting.ID,
            method,
            sequence: options.sequence ?? 0,
            dtstamp: options.dtstamp ?? new Date(),
            summary: meeting.Name,
            description: meeting.Description,
            location: meeting.LocationType === 'Virtual' ? null : meeting.Location,
            url: meeting.VideoJoinURL ?? options.url ?? null,
            startsAt: meeting.StartsAt,
            endsAt: meeting.EndsAt,
            organizer,
            attendees: others,
        });
        const slug = meeting.Name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '') || 'meeting';
        return { fileName: `${slug}.ics`, mimeType: 'text/calendar', content };
    }

    private person(row: AttendeeRow | null, person: PersonRow | undefined): IcsPerson | null {
        const email = row?.Email ?? person?.Email ?? null;
        if (!email) return null;
        return { email, name: row?.DisplayName ?? person?.DisplayName ?? row?.Person ?? null };
    }

    private async attendees(meetingId: string, contextUser: UserInfo): Promise<AttendeeRow[]> {
        const res = await RunView.FromMetadataProvider(this.provider).RunView<AttendeeRow>(
            { EntityName: MEETING_ATTENDEE_ENTITY, ExtraFilter: `MeetingID = '${meetingId}'`, Fields: ['PersonID', 'Email', 'DisplayName', 'Role', 'ResponseStatus', 'Person'], ResultType: 'simple', MaxRows: 1000 },
            contextUser,
        );
        if (!res.Success) throw new Error(`The attendees could not be read: ${res.ErrorMessage}`);
        return res.Results;
    }

    private async people(ids: ReadonlyArray<string | null>, contextUser: UserInfo): Promise<Map<string, PersonRow>> {
        const wanted = [...new Set(ids.filter((id): id is string => !!id).map((id) => id.toUpperCase()))];
        if (!wanted.length) return new Map();
        const res = await RunView.FromMetadataProvider(this.provider).RunView<PersonRow>(
            { EntityName: PEOPLE_ENTITY, ExtraFilter: `ID IN (${wanted.map((id) => `'${id}'`).join(',')})`, Fields: ['ID', 'Email', 'DisplayName'], ResultType: 'simple', MaxRows: wanted.length },
            contextUser,
        );
        if (!res.Success) throw new Error(`The people could not be read: ${res.ErrorMessage}`);
        return new Map(res.Results.map((row) => [row.ID.toLowerCase(), row]));
    }
}
