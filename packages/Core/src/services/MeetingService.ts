import { Metadata, RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import type { mjBizAppsTasksMeetingAttendeeEntity, mjBizAppsTasksMeetingEntity, mjBizAppsTasksMeetingLinkEntity, mjBizAppsTasksMeetingTypeEntity } from '@mj-biz-apps/tasks-entities';
import { MEETING_ATTENDEE_ENTITY, MEETING_ENTITY, MEETING_LINK_ENTITY, MEETING_TYPE_ENTITY, entityFailure } from '../meetings/entity-names.js';
import { parseAgendaTemplate } from '../meetings/agenda-template.js';
import type { MeetingStatus } from '../meetings/meeting-status.js';
import { MeetingAgendaService } from './MeetingAgendaService.js';

export interface NewMeetingAttendee {
    personId?: string | null;
    email?: string | null;
    displayName?: string | null;
    role?: 'Required' | 'Optional';
}

export interface NewMeetingLink {
    entityId: string;
    recordId: string;
    description?: string | null;
}

export interface NewMeeting {
    name: string;
    organizerPersonId: string;
    startsAt: Date;
    /** When absent, the type's default duration, else 60 minutes, from the start. */
    endsAt?: Date | null;
    /** When absent, the server's default: the business time zone. */
    timeZone?: string | null;
    typeId?: string | null;
    description?: string | null;
    locationType?: mjBizAppsTasksMeetingEntity['LocationType'] | null;
    location?: string | null;
    videoProviderId?: string | null;
    visibility?: mjBizAppsTasksMeetingEntity['Visibility'] | null;
    status?: 'Draft' | 'Scheduled';
    attendees?: readonly NewMeetingAttendee[];
    links?: readonly NewMeetingLink[];
    /** Apply the type's agenda template. Default true. */
    applyTemplate?: boolean;
    createdByPersonId?: string | null;
}

export interface MeetingStatusChange {
    ok: boolean;
    meeting: mjBizAppsTasksMeetingEntity | null;
    message: string | null;
}

const DEFAULT_DURATION_MINUTES = 60;

/**
 * Meetings as the app makes and moves them (the meetings plan, § 3): a meeting from a type, with the type's defaults,
 * its agenda template, its attendees and what it belongs to; and the organizer's moves, start, end and cancel. The
 * rules live on the entity server, so these go through the entity and report its refusal.
 */
export class MeetingService {
    constructor(private readonly provider: IMetadataProvider = Metadata.Provider) {}

    /** The meeting type, or null when none is named or found. */
    async loadType(typeId: string | null | undefined, contextUser: UserInfo): Promise<mjBizAppsTasksMeetingTypeEntity | null> {
        if (!typeId) return null;
        const type = await this.provider.GetEntityObject<mjBizAppsTasksMeetingTypeEntity>(MEETING_TYPE_ENTITY, contextUser);
        return (await type.Load(typeId)) ? type : null;
    }

    /** A meeting type by its code, or null. */
    async typeByCode(code: string, contextUser: UserInfo): Promise<mjBizAppsTasksMeetingTypeEntity | null> {
        const res = await RunView.FromMetadataProvider(this.provider).RunView<{ ID: string }>(
            { EntityName: MEETING_TYPE_ENTITY, ExtraFilter: `Code = '${code.replace(/'/g, "''")}'`, Fields: ['ID'], ResultType: 'simple', MaxRows: 1 },
            contextUser,
        );
        return res.Success && res.Results.length ? this.loadType(res.Results[0].ID, contextUser) : null;
    }

    /** Makes the meeting with the type's defaults, then its agenda from the template, its attendees and its links. */
    async createMeeting(input: NewMeeting, contextUser: UserInfo): Promise<mjBizAppsTasksMeetingEntity> {
        const type = await this.loadType(input.typeId, contextUser);
        const meeting = await this.provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, contextUser);
        meeting.NewRecord();
        meeting.Name = input.name;
        meeting.Description = input.description ?? null;
        meeting.TypeID = type?.ID ?? null;
        meeting.OrganizerPersonID = input.organizerPersonId;
        meeting.StartsAt = input.startsAt;
        const minutes = type?.DefaultDurationMinutes ?? DEFAULT_DURATION_MINUTES;
        meeting.EndsAt = input.endsAt ?? new Date(input.startsAt.getTime() + minutes * 60000);
        if (input.timeZone) meeting.TimeZone = input.timeZone;
        meeting.LocationType = input.locationType ?? type?.DefaultLocationType ?? 'Virtual';
        meeting.Location = input.location ?? null;
        meeting.VideoProviderID = input.videoProviderId ?? type?.DefaultVideoProviderID ?? null;
        meeting.Visibility = input.visibility ?? type?.DefaultVisibility ?? 'Standard';
        meeting.Status = input.status ?? 'Scheduled';
        meeting.CreatedByPersonID = input.createdByPersonId ?? null;
        if (!(await meeting.Save())) throw new Error(`The meeting was not saved: ${entityFailure(meeting)}`);

        if (input.applyTemplate !== false && type?.AgendaTemplate) {
            const template = parseAgendaTemplate(type.AgendaTemplate);
            if (template) await new MeetingAgendaService(this.provider).applyTemplate(meeting.ID, template, contextUser);
        }
        for (const attendee of input.attendees ?? []) await this.addAttendee(meeting.ID, attendee, contextUser);
        for (const link of input.links ?? []) await this.addLink(meeting.ID, link, contextUser);
        return meeting;
    }

    /** Invites a person or a guest. The organizer's own row is the entity server's and is never added here. */
    async addAttendee(meetingId: string, attendee: NewMeetingAttendee, contextUser: UserInfo): Promise<mjBizAppsTasksMeetingAttendeeEntity> {
        const row = await this.provider.GetEntityObject<mjBizAppsTasksMeetingAttendeeEntity>(MEETING_ATTENDEE_ENTITY, contextUser);
        row.NewRecord();
        row.MeetingID = meetingId;
        row.PersonID = attendee.personId ?? null;
        row.Email = attendee.email ?? null;
        row.DisplayName = attendee.displayName ?? null;
        row.Role = attendee.role ?? 'Required';
        row.ResponseStatus = 'None';
        row.AttendanceStatus = 'Unknown';
        if (!(await row.Save())) throw new Error(`The attendee was not saved: ${entityFailure(row)}`);
        return row;
    }

    /** Says what the meeting belongs to. */
    async addLink(meetingId: string, link: NewMeetingLink, contextUser: UserInfo): Promise<mjBizAppsTasksMeetingLinkEntity> {
        const row = await this.provider.GetEntityObject<mjBizAppsTasksMeetingLinkEntity>(MEETING_LINK_ENTITY, contextUser);
        row.NewRecord();
        row.MeetingID = meetingId;
        row.SeriesID = null;
        row.EntityID = link.entityId;
        row.RecordID = link.recordId;
        row.Description = link.description ?? null;
        if (!(await row.Save())) throw new Error(`The link was not saved: ${entityFailure(row)}`);
        return row;
    }

    /** The meeting's attendees. */
    async attendeesOf(meetingId: string, contextUser: UserInfo): Promise<mjBizAppsTasksMeetingAttendeeEntity[]> {
        const res = await RunView.FromMetadataProvider(this.provider).RunView<mjBizAppsTasksMeetingAttendeeEntity>(
            { EntityName: MEETING_ATTENDEE_ENTITY, ExtraFilter: `MeetingID = '${meetingId}'`, ResultType: 'entity_object', MaxRows: 1000 },
            contextUser,
        );
        if (!res.Success) throw new Error(`The attendees could not be read: ${res.ErrorMessage}`);
        return res.Results;
    }

    /** Starts the live meeting: Scheduled → InProgress. */
    startMeeting(meetingId: string, contextUser: UserInfo): Promise<MeetingStatusChange> {
        return this.moveStatus(meetingId, 'InProgress', contextUser, (meeting) => {
            if (!meeting.ActualStartedAt) meeting.ActualStartedAt = new Date();
        });
    }

    /** Ends the live meeting: InProgress → Completed. */
    endMeeting(meetingId: string, contextUser: UserInfo): Promise<MeetingStatusChange> {
        return this.moveStatus(meetingId, 'Completed', contextUser, (meeting) => {
            if (!meeting.ActualEndedAt) meeting.ActualEndedAt = new Date();
        });
    }

    /** Cancels the meeting, with the reason its attendees are told. */
    cancelMeeting(meetingId: string, reason: string | null, contextUser: UserInfo): Promise<MeetingStatusChange> {
        return this.moveStatus(meetingId, 'Cancelled', contextUser, (meeting) => {
            meeting.CancellationReason = reason ?? null;
        });
    }

    private async moveStatus(meetingId: string, to: MeetingStatus, contextUser: UserInfo, also?: (meeting: mjBizAppsTasksMeetingEntity) => void): Promise<MeetingStatusChange> {
        const meeting = await this.provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, contextUser);
        if (!(await meeting.Load(meetingId))) return { ok: false, meeting: null, message: 'The meeting was not found.' };
        meeting.Status = to;
        also?.(meeting);
        const ok = await meeting.Save();
        return { ok, meeting, message: ok ? null : entityFailure(meeting, 'The meeting was not saved.') };
    }
}
