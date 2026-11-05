import { CompositeKey, Metadata, RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import {
    CalendarEventLinks,
    type CalendarCredentialSource,
    type LinkedEventResult,
    type SyncCalendarResult,
} from '@memberjunction/communication-engine';
import type {
    CalendarEventAttendeeInput,
    CalendarEventInput,
    CalendarTarget,
} from '@memberjunction/communication-types';
import type {
    mjBizAppsTasksMeetingAttendeeEntity,
    mjBizAppsTasksMeetingEntity,
    mjBizAppsTasksVideoProviderEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    MEETING_ATTENDEE_ENTITY,
    MEETING_ENTITY,
    PEOPLE_ENTITY,
    VIDEO_PROVIDER_ENTITY,
} from '@mj-biz-apps/tasks-core';
import { ResolvePersonIDForUser, ResolveUserIDForPerson } from '@mj-biz-apps/common-entities';
import { TasksSettings } from '../TasksSettings.js';

export interface MeetingCalendarSyncOptions extends CalendarCredentialSource {
    /** Overrides `TasksSettings.DefaultCalendarProviderName`. */
    providerName?: string;
    /** Overrides the organizer mailbox target. */
    target?: CalendarTarget;
    /** Optional comment sent when cancelling a linked calendar event. */
    comment?: string;
}

interface AttendeeLookupRow {
    PersonID: string | null;
    Email: string | null;
    DisplayName: string | null;
    Person: string | null;
    Role: 'Organizer' | 'Required' | 'Optional';
}

interface PersonEmailRow {
    ID: string;
    Email: string | null;
    DisplayName: string | null;
}

/**
 * Outbound and inbound calendar synchronization for `MJ_BizApps_Tasks: Meetings` (the meetings plan, § 5 / T2).
 *
 * Wraps `CalendarEventLinks` from `@memberjunction/communication-engine` so a meeting's lifecycle
 * (`CreateLinkedEvent`, `UpdateLinkedEvent`, `CancelLinkedEvent`, `SyncCalendar`) writes to the organizer's
 * calendar (or the configured `SharedCalendarMailbox` fallback), attaches a Teams / Google Meet online
 * meeting when requested (`IsOnlineMeeting: true`), and records any returned `OnlineMeetingUrl` onto
 * `Meeting.VideoJoinURL`.
 */
export class MeetingCalendarSyncService {
    private readonly links: CalendarEventLinks;

    constructor(
        private readonly provider: IMetadataProvider = Metadata.Provider,
        links?: CalendarEventLinks,
    ) {
        this.links = links ?? new CalendarEventLinks(this.provider);
    }

    /**
     * Creates or updates the calendar event linked to a meeting.
     * Returns `null` when no calendar communication provider is configured.
     */
    async syncMeeting(
        meetingId: string,
        contextUser: UserInfo,
        options: MeetingCalendarSyncOptions = {},
    ): Promise<LinkedEventResult | null> {
        const providerName = await this.resolveProviderName(options.providerName, contextUser);
        if (!providerName) return null;

        const meeting = await this.provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, contextUser);
        if (!(await meeting.Load(meetingId))) {
            return { Success: false, ErrorMessage: `Meeting ${meetingId} was not found.` };
        }

        if (meeting.Status === 'Cancelled') {
            return this.cancelMeetingEvent(meeting, contextUser, { ...options, providerName });
        }

        const target = options.target ?? (await this.resolveOrganizerTarget(meeting.OrganizerPersonID, contextUser));
        if (!target) {
            return {
                Success: false,
                ErrorMessage: `Meeting ${meeting.ID} has no organizer email or SharedCalendarMailbox for calendar sync.`,
            };
        }

        const eventInput = await this.buildCalendarEventInput(meeting, contextUser);
        const recordKey = CompositeKey.FromID(meeting.ID);
        const hasActiveLink = await this.hasActiveLink(meeting.ID, contextUser);

        const result = hasActiveLink
            ? await this.links.UpdateLinkedEvent(
                  {
                      ProviderName: providerName,
                      EntityName: MEETING_ENTITY,
                      RecordKey: recordKey,
                      Identifier: target.Identifier,
                      Changes: eventInput,
                      Credentials: options.Credentials,
                      CredentialID: options.CredentialID,
                      CredentialName: options.CredentialName,
                  },
                  contextUser,
              )
            : await this.links.CreateLinkedEvent(
                  {
                      ProviderName: providerName,
                      Target: target,
                      EntityName: MEETING_ENTITY,
                      RecordKey: recordKey,
                      Event: eventInput,
                      Credentials: options.Credentials,
                      CredentialID: options.CredentialID,
                      CredentialName: options.CredentialName,
                  },
                  contextUser,
              );

        if (result.Success && result.Event?.OnlineMeetingUrl && !meeting.VideoJoinURL) {
            (meeting as mjBizAppsTasksMeetingEntity & { MaintainedByCalendarSync?: boolean }).MaintainedByCalendarSync = true;
            meeting.VideoJoinURL = result.Event.OnlineMeetingUrl;
            await meeting.Save();
        }

        return result;
    }

    /** Cancels the active calendar event linked to a meeting, if one exists. */
    async cancelMeetingEvent(
        meetingOrId: string | mjBizAppsTasksMeetingEntity,
        contextUser: UserInfo,
        options: MeetingCalendarSyncOptions = {},
    ): Promise<LinkedEventResult | null> {
        const providerName = await this.resolveProviderName(options.providerName, contextUser);
        if (!providerName) return null;

        const meetingId = typeof meetingOrId === 'string' ? meetingOrId : meetingOrId.ID;
        if (!(await this.hasActiveLink(meetingId, contextUser))) {
            return null;
        }

        return this.links.CancelLinkedEvent(
            {
                ProviderName: providerName,
                EntityName: MEETING_ENTITY,
                RecordKey: CompositeKey.FromID(meetingId),
                Identifier: options.target?.Identifier,
                Comment: options.comment ?? (typeof meetingOrId === 'string' ? undefined : (meetingOrId.CancellationReason ?? undefined)),
                Credentials: options.Credentials,
                CredentialID: options.CredentialID,
                CredentialName: options.CredentialName,
            },
            contextUser,
        );
    }

    /** Runs an incremental or full delta sync for a calendar target via `CalendarEventLinks.SyncCalendar`. */
    async syncCalendar(
        target: CalendarTarget,
        contextUser: UserInfo,
        options: MeetingCalendarSyncOptions & { windowStart?: Date; windowEnd?: Date } = {},
    ): Promise<SyncCalendarResult> {
        const providerName = await this.resolveProviderName(options.providerName, contextUser);
        if (!providerName) {
            return {
                Success: false,
                Changes: 0,
                LinksUpdated: 0,
                Resynced: false,
                Errors: [],
                ErrorMessage: 'No calendar communication provider is configured.',
            };
        }
        return this.links.SyncCalendar(
            {
                ProviderName: providerName,
                Target: target,
                WindowStart: options.windowStart,
                WindowEnd: options.windowEnd,
                Credentials: options.Credentials,
                CredentialID: options.CredentialID,
                CredentialName: options.CredentialName,
            },
            contextUser,
        );
    }

    /**
     * Resolves the calendar owner (`CalendarTarget`) for a meeting (Decision A1):
     * 1. The organizer's (`OrganizerPersonID`) email from `MJ_BizApps_Common: People`, or the linked MJ user's email
     *    via `ResolveUserIDForPerson` / `ResolvePersonIDForUser` (`@mj-biz-apps/common-entities`).
     * 2. Fallback to `TasksSettings.SharedCalendarMailbox` when configured.
     */
    async resolveOrganizerTarget(organizerPersonId: string, contextUser: UserInfo): Promise<CalendarTarget | null> {
        const people = await this.loadPeopleEmails([organizerPersonId], contextUser);
        const organizerEmail = people.get(organizerPersonId.toLowerCase())?.Email?.trim();
        if (organizerEmail) {
            return { Identifier: organizerEmail };
        }
        try {
            const linkedUserId = await ResolveUserIDForPerson(organizerPersonId, this.provider, contextUser);
            if (linkedUserId) {
                const usersRes = await RunView.FromMetadataProvider(this.provider).RunView<{ Email: string | null }>(
                    {
                        EntityName: 'MJ: Users',
                        ExtraFilter: `ID = '${linkedUserId}'`,
                        Fields: ['Email'],
                        ResultType: 'simple',
                        MaxRows: 1,
                    },
                    contextUser,
                );
                const userEmail = usersRes?.Success ? usersRes.Results?.[0]?.Email?.trim() : null;
                if (userEmail) return { Identifier: userEmail };
            }
            const callerPersonId = await ResolvePersonIDForUser(contextUser, this.provider, contextUser);
            if (callerPersonId && callerPersonId.toLowerCase() === organizerPersonId.toLowerCase() && contextUser.Email?.trim()) {
                return { Identifier: contextUser.Email.trim() };
            }
        } catch {
            // Fall through to SharedCalendarMailbox when user/person link lookup is unavailable.
        }
        await TasksSettings.Load(this.provider, contextUser);
        const sharedMailbox = TasksSettings.SharedCalendarMailbox(this.provider);
        return sharedMailbox ? { Identifier: sharedMailbox } : null;
    }

    /** Maps a `Meeting` and its `MeetingAttendee` rows to `CalendarEventInput`. */
    async buildCalendarEventInput(
        meeting: mjBizAppsTasksMeetingEntity,
        contextUser: UserInfo,
    ): Promise<CalendarEventInput> {
        const attendees = await this.loadMeetingAttendees(meeting.ID, contextUser);
        const personIds = attendees.map((a) => a.PersonID).filter((id): id is string => !!id);
        const peopleById = await this.loadPeopleEmails(personIds, contextUser);

        const mappedAttendees: CalendarEventAttendeeInput[] = [];
        for (const row of attendees) {
            if (row.Role === 'Organizer') continue;
            const person = row.PersonID ? peopleById.get(row.PersonID.toLowerCase()) : undefined;
            const email = (row.Email ?? person?.Email ?? '').trim();
            if (!email) continue;
            const name = (row.DisplayName ?? person?.DisplayName ?? row.Person ?? '').trim() || undefined;
            mappedAttendees.push({
                Email: email,
                Name: name,
                Type: row.Role === 'Optional' ? 'Optional' : 'Required',
            });
        }

        const isOnlineMeeting = await this.shouldRequestCalendarOnlineMeeting(meeting, contextUser);

        return {
            Subject: meeting.Name,
            Body: meeting.Description ?? undefined,
            BodyType: 'Text',
            Start: meeting.StartsAt,
            End: meeting.EndsAt,
            TimeZone: meeting.TimeZone || 'UTC',
            IsAllDay: false,
            Location: meeting.LocationType === 'Virtual' ? undefined : (meeting.Location ?? undefined),
            Attendees: mappedAttendees,
            IsOnlineMeeting: isOnlineMeeting,
        };
    }

    /**
     * Requests a calendar-native online meeting (Teams on Graph, Google Meet on Gmail) when the meeting is
     * Virtual or Hybrid and does not already have a standalone `VideoJoinURL` or a standalone `Zoom` video provider.
     */
    private async shouldRequestCalendarOnlineMeeting(
        meeting: mjBizAppsTasksMeetingEntity,
        contextUser: UserInfo,
    ): Promise<boolean> {
        if (meeting.LocationType !== 'Virtual' && meeting.LocationType !== 'Hybrid') {
            return false;
        }
        if (!meeting.VideoProviderID) {
            return !meeting.VideoJoinURL;
        }
        const vp = await this.provider.GetEntityObject<mjBizAppsTasksVideoProviderEntity>(VIDEO_PROVIDER_ENTITY, contextUser);
        if (!(await vp.Load(meeting.VideoProviderID))) {
            return !meeting.VideoJoinURL;
        }
        const code = (vp.Code ?? '').toUpperCase();
        return !vp.DriverClass || code === 'TEAMS' || code === 'GOOGLE_MEET';
    }

    private async resolveProviderName(explicit: string | undefined, contextUser: UserInfo): Promise<string | null> {
        if (explicit && explicit.trim()) return explicit.trim();
        await TasksSettings.Load(this.provider, contextUser);
        return TasksSettings.DefaultCalendarProviderName(this.provider);
    }

    private async hasActiveLink(meetingId: string, contextUser: UserInfo): Promise<boolean> {
        const compactKey = CompositeKey.FromID(meetingId).ToCompactURLSegment();
        const res = await RunView.FromMetadataProvider(this.provider).RunView<{ ID: string }>(
            {
                EntityName: 'MJ: Calendar Event Links',
                ExtraFilter: `Entity = '${MEETING_ENTITY}' AND Status = 'Active' AND (RecordID = '${meetingId}' OR RecordID = '${compactKey}')`,
                Fields: ['ID'],
                ResultType: 'simple',
                MaxRows: 1,
            },
            contextUser,
        );
        return Boolean(res?.Success && res.Results?.length);
    }

    private async loadMeetingAttendees(meetingId: string, contextUser: UserInfo): Promise<AttendeeLookupRow[]> {
        const res = await RunView.FromMetadataProvider(this.provider).RunView<mjBizAppsTasksMeetingAttendeeEntity>(
            {
                EntityName: MEETING_ATTENDEE_ENTITY,
                ExtraFilter: `MeetingID = '${meetingId}'`,
                Fields: ['PersonID', 'Email', 'DisplayName', 'Person', 'Role'],
                ResultType: 'simple',
                MaxRows: 1000,
            },
            contextUser,
        );
        if (!res.Success) throw new Error(`Failed to load meeting attendees: ${res.ErrorMessage}`);
        return res.Results as unknown as AttendeeLookupRow[];
    }

    private async loadPeopleEmails(
        personIds: readonly string[],
        contextUser: UserInfo,
    ): Promise<Map<string, PersonEmailRow>> {
        const unique = [...new Set(personIds.filter(Boolean).map((id) => id.toUpperCase()))];
        if (!unique.length) return new Map();
        const res = await RunView.FromMetadataProvider(this.provider).RunView<PersonEmailRow>(
            {
                EntityName: PEOPLE_ENTITY,
                ExtraFilter: `ID IN (${unique.map((id) => `'${id}'`).join(',')})`,
                Fields: ['ID', 'Email', 'DisplayName'],
                ResultType: 'simple',
                MaxRows: unique.length,
            },
            contextUser,
        );
        if (!res.Success) throw new Error(`Failed to load people emails: ${res.ErrorMessage}`);
        return new Map((res.Results ?? []).map((row) => [row.ID.toLowerCase(), row]));
    }
}
