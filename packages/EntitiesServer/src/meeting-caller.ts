import type { IMetadataProvider, UserInfo } from '@memberjunction/core';
import { callerAdministersMeetings, callerIsOrganizer, personIdForUser } from '@mj-biz-apps/tasks-core';

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
