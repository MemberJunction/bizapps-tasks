import { RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import { MEETING_ATTENDEE_ENTITY, MEETING_ENTITY, callerAdministersMeetings, callerIsOrganizer, personIdForUser } from '@mj-biz-apps/tasks-core';
import type { mjBizAppsTasksMeetingEntity } from '@mj-biz-apps/tasks-entities';

/**
 * Who the caller is to a meeting (the meetings plan, § 3 and § 4): an administrator (a role above UI that updates
 * Meetings), the organizer (their Person is the meeting's organizer), or someone else. The server subclasses ask this
 * before a change the plan reserves to the organizer, so the rule holds over the API and not only in the app.
 */
export interface MeetingCaller {
    administers: boolean;
    personId: string | null;
}

export async function meetingCaller(provider: IMetadataProvider, user: UserInfo | undefined): Promise<MeetingCaller> {
    if (!user) return { administers: false, personId: null };
    const administers = callerAdministersMeetings(provider, user);
    const personId = await personIdForUser(provider, user);
    return { administers, personId };
}

/** Whether the caller may change the meeting itself, invite and remove its attendees, or run it. */
export function callerOwnsMeeting(caller: MeetingCaller, organizerPersonId: string | null | undefined): boolean {
    return caller.administers || callerIsOrganizer(caller.personId, organizerPersonId);
}

/** Whether the caller sits on the meeting's attendee list: their user or their Person names a row. */
export async function callerAttendsMeeting(provider: IMetadataProvider, user: UserInfo, caller: MeetingCaller, meetingId: string): Promise<boolean> {
    const clauses = [`UserID = '${user.ID}'`];
    if (caller.personId) clauses.push(`PersonID = '${caller.personId}'`);
    const rows = await RunView.FromMetadataProvider(provider).RunView<{ ID: string }>(
        { EntityName: MEETING_ATTENDEE_ENTITY, ExtraFilter: `MeetingID = '${meetingId}' AND (${clauses.join(' OR ')})`, Fields: ['ID'], ResultType: 'simple', MaxRows: 1 },
        user,
    );
    return rows.Success && rows.Results.length > 0;
}

/** What the caller is to one meeting, in one read: not there (unreadable), owns it, or attends it. */
export async function callerAndMeeting(
    provider: IMetadataProvider,
    user: UserInfo | undefined,
    meetingId: string,
): Promise<{ found: false } | { found: true; caller: MeetingCaller; owns: boolean; attends: boolean; organizerPersonId: string }> {
    if (!user) return { found: false };
    const meeting = await provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, user);
    if (!(await meeting.Load(meetingId))) return { found: false };
    const caller = await meetingCaller(provider, user);
    const owns = callerOwnsMeeting(caller, meeting.OrganizerPersonID);
    const attends = owns ? true : await callerAttendsMeeting(provider, user, caller, meetingId);
    return { found: true, caller, owns, attends, organizerPersonId: meeting.OrganizerPersonID };
}
