import { RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import { BaseCalendarEventLinkHandler, type CalendarLinkChange } from '@memberjunction/communication-engine';
import type { CalendarEventAttendee } from '@memberjunction/communication-types';
import { RegisterClass } from '@memberjunction/global';
import type { mjBizAppsTasksMeetingAttendeeEntity, mjBizAppsTasksMeetingEntity } from '@mj-biz-apps/tasks-entities';
import { MEETING_ATTENDEE_ENTITY, MEETING_ENTITY, PEOPLE_ENTITY } from '@mj-biz-apps/tasks-core';

interface PersonEmailLookup {
    ID: string;
    Email: string | null;
}

/** Extracts the raw UUID from either `<uuid>` or `ID|<uuid>` (`CompositeKey.ToCompactURLSegment()`). */
export function extractMeetingRecordId(rawRecordId: string | null | undefined): string | null {
    if (!rawRecordId) return null;
    const trimmed = rawRecordId.trim();
    if (!trimmed) return null;
    const pipeIndex = trimmed.indexOf('|');
    return (pipeIndex >= 0 ? trimmed.slice(pipeIndex + 1) : trimmed).trim() || null;
}

/**
 * Applies inbound calendar changes (`CalendarEventLinks.SyncCalendar`) to `MJ_BizApps_Tasks: Meetings`
 * and its `MJ_BizApps_Tasks: Meeting Attendees` rows (the meetings plan, § 5 / T2).
 *
 * Idempotent: sets the meeting's title, times, location, online meeting join URL, cancellation status,
 * and attendee RSVP responses (`ResponseStatus`, `RespondedAt`) to the state reported by the calendar.
 */
@RegisterClass(BaseCalendarEventLinkHandler, MEETING_ENTITY)
export class MeetingCalendarEventLinkHandler extends BaseCalendarEventLinkHandler {
    public override async HandleChange(
        change: CalendarLinkChange,
        contextUser: UserInfo,
        provider: IMetadataProvider,
    ): Promise<boolean> {
        const meetingId = extractMeetingRecordId(change.Link?.RecordID);
        if (!meetingId) return false;

        const meeting = await provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, contextUser);
        if (!(await meeting.Load(meetingId))) {
            // If the meeting row was already deleted, nothing remains to apply.
            return true;
        }

        (meeting as mjBizAppsTasksMeetingEntity & { MaintainedByCalendarSync?: boolean }).MaintainedByCalendarSync = true;

        if (change.IsCancelled) {
            if (meeting.Status !== 'Cancelled' && meeting.Status !== 'Completed') {
                meeting.Status = 'Cancelled';
                if (!meeting.CancelledAt) meeting.CancelledAt = new Date();
                if (!(await meeting.Save())) return false;
            }
            return true;
        }

        const event = change.Event;
        if (!event) return true;

        let changed = false;
        if (event.Subject && event.Subject.trim() && event.Subject.trim() !== meeting.Name) {
            meeting.Name = event.Subject.trim();
            changed = true;
        }
        if (
            event.Start instanceof Date &&
            event.End instanceof Date &&
            !Number.isNaN(event.Start.getTime()) &&
            !Number.isNaN(event.End.getTime()) &&
            event.End.getTime() > event.Start.getTime()
        ) {
            if (
                meeting.StartsAt?.getTime() !== event.Start.getTime() ||
                meeting.EndsAt?.getTime() !== event.End.getTime()
            ) {
                meeting.StartsAt = event.Start;
                meeting.EndsAt = event.End;
                changed = true;
            }
        }
        if (event.Location !== null && event.Location !== undefined && event.Location !== meeting.Location) {
            meeting.Location = event.Location;
            changed = true;
        }
        if (event.OnlineMeetingUrl && !meeting.VideoJoinURL) {
            meeting.VideoJoinURL = event.OnlineMeetingUrl;
            changed = true;
        }

        if (changed && !(await meeting.Save())) {
            return false;
        }

        if (event.Attendees?.length) {
            const rsvpSaved = await this.applyAttendeeResponses(meeting.ID, event.Attendees, contextUser, provider);
            if (!rsvpSaved) return false;
        }

        return true;
    }

    private async applyAttendeeResponses(
        meetingId: string,
        calendarAttendees: readonly CalendarEventAttendee[],
        contextUser: UserInfo,
        provider: IMetadataProvider,
    ): Promise<boolean> {
        const rv = RunView.FromMetadataProvider(provider);
        const rowsRes = await rv.RunView<mjBizAppsTasksMeetingAttendeeEntity>(
            {
                EntityName: MEETING_ATTENDEE_ENTITY,
                ExtraFilter: `MeetingID = '${meetingId}'`,
                ResultType: 'entity_object',
                MaxRows: 1000,
            },
            contextUser,
        );
        if (!rowsRes.Success) return false;
        const rows = rowsRes.Results ?? [];
        if (!rows.length) return true;

        const personIds = [...new Set(rows.map((r) => r.PersonID).filter((id): id is string => !!id))];
        const personEmailById = new Map<string, string>();
        if (personIds.length) {
            const peopleRes = await rv.RunView<PersonEmailLookup>(
                {
                    EntityName: PEOPLE_ENTITY,
                    ExtraFilter: `ID IN (${personIds.map((id) => `'${id}'`).join(',')})`,
                    Fields: ['ID', 'Email'],
                    ResultType: 'simple',
                    MaxRows: personIds.length,
                },
                contextUser,
            );
            if (peopleRes.Success) {
                for (const p of peopleRes.Results ?? []) {
                    if (p.Email) personEmailById.set(p.ID.toLowerCase(), p.Email.trim().toLowerCase());
                }
            }
        }

        const responseByEmail = new Map<string, CalendarEventAttendee['Response']>();
        for (const att of calendarAttendees) {
            if (att.Email?.trim()) {
                responseByEmail.set(att.Email.trim().toLowerCase(), att.Response);
            }
        }

        for (const row of rows) {
            if (row.Role === 'Organizer') continue;
            const rowEmail = (
                row.Email?.trim() ||
                (row.PersonID ? personEmailById.get(row.PersonID.toLowerCase()) : '') ||
                ''
            ).toLowerCase();
            if (!rowEmail) continue;
            const incomingResponse = responseByEmail.get(rowEmail);
            if (!incomingResponse || incomingResponse === row.ResponseStatus) continue;

            (row as mjBizAppsTasksMeetingAttendeeEntity & { MaintainedByMeetingServer?: boolean }).MaintainedByMeetingServer = true;
            row.ResponseStatus = incomingResponse;
            row.RespondedAt = new Date();
            if (!(await row.Save())) return false;
        }

        return true;
    }
}
