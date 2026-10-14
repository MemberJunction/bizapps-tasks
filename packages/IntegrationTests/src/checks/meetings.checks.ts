/**
 * Meetings (T1), over the GraphQL wire: a meeting made from a type gets its agenda and its organizer's row; a series
 * makes and keeps its occurrences; the status moves, and who may make them; a private meeting is read by its attendees
 * only; cancelling tells the video provider's driver after the commit.
 */
import { Assert, IntegrationCheckRegistry, type IntegrationCheckContext, type NamedCheck } from '@memberjunction/testing-integration/registry';
import { CompositeKey, type IMetadataProvider } from '@memberjunction/core';
import type {
    mjBizAppsTasksMeetingAttendeeEntity,
    mjBizAppsTasksMeetingEntity,
    mjBizAppsTasksMeetingSeriesAttendeeEntity,
    mjBizAppsTasksMeetingSeriesEntity,
    mjBizAppsTasksVideoProviderEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    MEETING_AGENDA_ITEM_ENTITY,
    MEETING_ATTENDEE_ENTITY,
    MEETING_ENTITY,
    MEETING_LINK_ENTITY,
    MEETING_NOTE_ENTITY,
    MEETING_SERIES_ATTENDEE_ENTITY,
    MEETING_SERIES_ENTITY,
    MeetingCalendarFile,
    MeetingService,
    VIDEO_PROVIDER_ENTITY,
} from '@mj-biz-apps/tasks-core';
import { FindRows, Quote, RequireSave } from '../wire.js';
import { LoadMeetingWorld } from '../world/meeting-world.js';
import { cleanupPersonaProviders, getPersonaContext } from '../persona-provider.js';

const MARK = 'TASKS-CHECK meetings';
const FAKE_DRIVER = 'FakeVideoProvider';

const provider = (ctx: IntegrationCheckContext): IMetadataProvider => ctx.Provider as IMetadataProvider;

async function deleteRows(ctx: IntegrationCheckContext, entityName: string, filter: string): Promise<void> {
    const rows = await FindRows<{ ID: string }>(ctx, entityName, filter, ['ID']);
    for (const row of rows) {
        const entity = await ctx.Provider.GetEntityObject(entityName, ctx.User);
        const key = new CompositeKey();
        key.KeyValuePairs.push({ FieldName: 'ID', Value: row.ID });
        if (await entity.InnerLoad(key)) await entity.Delete();
    }
}

/** Everything a meeting owns, then the meeting, as the harness user (who may delete). */
async function deleteMeeting(ctx: IntegrationCheckContext, meetingId: string): Promise<void> {
    await deleteRows(ctx, MEETING_NOTE_ENTITY, `MeetingID = '${meetingId}'`);
    await deleteRows(ctx, MEETING_AGENDA_ITEM_ENTITY, `MeetingID = '${meetingId}' AND ParentID IS NOT NULL`);
    await deleteRows(ctx, MEETING_AGENDA_ITEM_ENTITY, `MeetingID = '${meetingId}'`);
    await deleteRows(ctx, MEETING_ATTENDEE_ENTITY, `MeetingID = '${meetingId}'`);
    await deleteRows(ctx, MEETING_LINK_ENTITY, `MeetingID = '${meetingId}'`);
    await deleteRows(ctx, MEETING_ENTITY, `ID = '${meetingId}'`);
}

async function deleteSeries(ctx: IntegrationCheckContext, seriesId: string): Promise<void> {
    const occurrences = await FindRows<{ ID: string }>(ctx, MEETING_ENTITY, `SeriesID = '${seriesId}'`, ['ID']);
    for (const row of occurrences) await deleteMeeting(ctx, row.ID);
    await deleteRows(ctx, MEETING_SERIES_ATTENDEE_ENTITY, `SeriesID = '${seriesId}'`);
    await deleteRows(ctx, MEETING_LINK_ENTITY, `SeriesID = '${seriesId}'`);
    await deleteRows(ctx, MEETING_SERIES_ENTITY, `ID = '${seriesId}'`);
}

/** Work the server does after the commit lands a moment after the mutation returns: read again for a few seconds. */
async function eventually<T>(read: () => Promise<T>, ok: (value: T) => boolean, what: string, timeoutMs = 15000): Promise<T> {
    const deadline = Date.now() + timeoutMs;
    let last: T = await read();
    while (!ok(last) && Date.now() < deadline) {
        await new Promise((resolve) => setTimeout(resolve, 500));
        last = await read();
    }
    Assert(ok(last), `${what} (waited ${timeoutMs}ms)`);
    return last;
}

const nextWeek = (): Date => {
    const date = new Date();
    date.setUTCDate(date.getUTCDate() + 7);
    date.setUTCHours(15, 0, 0, 0);
    return date;
};

const checks: NamedCheck[] = [
    {
        Id: 'meetings.M1',
        Name: 'M1 — a meeting made from the Team type gets the type\'s length, its agenda from the template, the organizer\'s attendee row, and an .ics',
        RequiresMutation: true,
        Fn: async (ctx: IntegrationCheckContext) => {
            const world = await LoadMeetingWorld(ctx);
            const service = new MeetingService(provider(ctx));
            const type = await service.typeByCode('TEAM', ctx.User);
            Assert(!!type, 'the Team meeting type is pushed');
            let meetingId: string | null = null;
            try {
                const meeting = await service.createMeeting(
                    { name: `${MARK} team sync`, typeId: type!.ID, organizerPersonId: world.ivy.personId, startsAt: nextWeek(), timeZone: 'America/Chicago', attendees: [{ personId: world.jun.personId }], links: [] },
                    ctx.User,
                );
                meetingId = meeting.ID;
                Assert(meeting.EndsAt.getTime() - meeting.StartsAt.getTime() === 60 * 60000, 'the Team type gives 60 minutes');
                Assert(meeting.Status === 'Scheduled' && meeting.Visibility === 'Standard', 'a Team meeting starts Scheduled and Standard');
                const agenda = await FindRows<{ ID: string; Name: string; Sequence: number; TypeID: string | null }>(ctx, MEETING_AGENDA_ITEM_ENTITY, `MeetingID = '${meeting.ID}'`, ['ID', 'Name', 'Sequence', 'TypeID']);
                Assert(agenda.length === 4, `the template gave 4 agenda items (${agenda.length})`);
                Assert(agenda.every((item) => !!item.TypeID), 'each template item found its agenda item type by code');
                Assert([...agenda].sort((a, b) => a.Sequence - b.Sequence)[0].Name === 'Updates', 'the first item is the template\'s first');
                const attendees = await FindRows<{ PersonID: string | null; Role: string; UserID: string | null; ResponseStatus: string }>(ctx, MEETING_ATTENDEE_ENTITY, `MeetingID = '${meeting.ID}'`, ['PersonID', 'Role', 'UserID', 'ResponseStatus']);
                const organizer = attendees.find((a) => a.Role === 'Organizer');
                Assert(!!organizer && organizer.PersonID?.toLowerCase() === world.ivy.personId.toLowerCase(), 'the organizer\'s attendee row is there, made by the server');
                Assert(organizer!.UserID?.toLowerCase() === world.ivy.userId.toLowerCase(), 'the organizer row carries her MJ user, found through the user\'s link to the person');
                const jun = attendees.find((a) => a.PersonID?.toLowerCase() === world.jun.personId.toLowerCase());
                Assert(!!jun && jun.Role === 'Required' && jun.UserID?.toLowerCase() === world.jun.userId.toLowerCase(), 'the invited person\'s row carries his MJ user');
                const file = await new MeetingCalendarFile(provider(ctx)).forMeeting(meeting.ID, 'REQUEST', ctx.User, { dtstamp: new Date('2026-10-14T12:00:00Z') });
                Assert(file.fileName.endsWith('.ics') && file.content.includes(`UID:${meeting.ID}`) && file.content.includes('METHOD:REQUEST'), 'the .ics names the meeting');
                Assert(file.content.includes(`mailto:${world.ivy.email}`) && file.content.includes(`mailto:${world.jun.email}`), 'the .ics carries the organizer and the attendee');
            } finally {
                if (meetingId) await deleteMeeting(ctx, meetingId);
            }
        },
    },
    {
        Id: 'meetings.M2',
        Name: 'M2 — a weekly series makes its occurrences after the commit, each with the series\' attendees; a change reaches the untouched ones and leaves a moved one alone',
        RequiresMutation: true,
        Fn: async (ctx: IntegrationCheckContext) => {
            const world = await LoadMeetingWorld(ctx);
            let seriesId: string | null = null;
            try {
                const first = nextWeek();
                const series = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingSeriesEntity>(MEETING_SERIES_ENTITY, ctx.User);
                series.NewRecord();
                series.Name = `${MARK} weekly`;
                series.OrganizerPersonID = world.ivy.personId;
                series.RecurrenceRule = 'FREQ=WEEKLY;COUNT=4';
                series.TimeZone = 'America/Chicago';
                series.FirstStartsAt = first;
                series.DurationMinutes = 45;
                series.LocationType = 'Virtual';
                series.Visibility = 'Standard';
                series.Status = 'Active';
                await RequireSave(series, 'the series');
                seriesId = series.ID;
                const invite = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingSeriesAttendeeEntity>(MEETING_SERIES_ATTENDEE_ENTITY, ctx.User);
                invite.NewRecord();
                invite.SeriesID = series.ID;
                invite.PersonID = world.jun.personId;
                invite.Role = 'Optional';
                await RequireSave(invite, 'the series attendee');
                // The save made the occurrences after the commit; a save of the series again makes the attendee reach them
                series.Description = 'Every week.';
                await RequireSave(series, 'the series again');

                const occurrences = await eventually(
                    () => FindRows<{ ID: string; StartsAt: string; OccurrenceStartsAt: string; Name: string; Status: string }>(ctx, MEETING_ENTITY, `SeriesID = '${series.ID}'`, ['ID', 'StartsAt', 'OccurrenceStartsAt', 'Name', 'Status']),
                    (rows) => rows.length === 4,
                    'four occurrences are made',
                );
                Assert(occurrences.every((o) => o.OccurrenceStartsAt && new Date(o.StartsAt).getTime() === new Date(o.OccurrenceStartsAt).getTime()), 'each occurrence sits in its slot');
                const sorted = [...occurrences].sort((a, b) => new Date(a.StartsAt).getTime() - new Date(b.StartsAt).getTime());
                Assert(new Date(sorted[0].StartsAt).getTime() === first.getTime(), 'the first occurrence is the first start');
                Assert(new Date(sorted[1].StartsAt).getTime() - new Date(sorted[0].StartsAt).getTime() === 7 * 86400000, 'occurrences are a week apart');
                const attendeesOfSecond = await eventually(
                    () => FindRows<{ PersonID: string | null; Role: string }>(ctx, MEETING_ATTENDEE_ENTITY, `MeetingID = '${sorted[1].ID}'`, ['PersonID', 'Role']),
                    (rows) => rows.length === 2,
                    'the second occurrence has the organizer and the series attendee',
                );
                Assert(attendeesOfSecond.some((a) => a.Role === 'Organizer') && attendeesOfSecond.some((a) => a.PersonID?.toLowerCase() === world.jun.personId.toLowerCase() && a.Role === 'Optional'), 'the organizer row and the invited person');

                // Move the third occurrence on its own, then rename the series
                const moved = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, ctx.User);
                Assert(await moved.Load(sorted[2].ID), 'the third occurrence loads');
                moved.StartsAt = new Date(moved.StartsAt.getTime() + 60 * 60000);
                moved.EndsAt = new Date(moved.EndsAt.getTime() + 60 * 60000);
                await RequireSave(moved, 'the moved occurrence');
                series.Name = `${MARK} weekly, renamed`;
                await RequireSave(series, 'the renamed series');
                const after = await eventually(
                    () => FindRows<{ ID: string; Name: string; StartsAt: string }>(ctx, MEETING_ENTITY, `SeriesID = '${series.ID}'`, ['ID', 'Name', 'StartsAt']),
                    (rows) => rows.filter((r) => r.Name.endsWith('renamed')).length === 3,
                    'the three untouched occurrences take the new name',
                );
                const third = after.find((r) => r.ID.toLowerCase() === sorted[2].ID.toLowerCase());
                Assert(!!third && third.Name === `${MARK} weekly` && new Date(third.StartsAt).getTime() === moved.StartsAt.getTime(), 'the moved occurrence keeps its name and its time');
                const reloaded = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingSeriesEntity>(MEETING_SERIES_ENTITY, ctx.User);
                Assert((await reloaded.Load(series.ID)) && !!reloaded.MaterializedThrough, 'the series records how far it is materialized');
            } finally {
                if (seriesId) await deleteSeries(ctx, seriesId);
            }
        },
    },
    {
        Id: 'meetings.M3',
        Name: 'M3 — the status moves forward: a jump is refused in words, the organizer starts the meeting, someone else is refused',
        RequiresMutation: true,
        Fn: async (ctx: IntegrationCheckContext) => {
            const world = await LoadMeetingWorld(ctx);
            const service = new MeetingService(provider(ctx));
            let meetingId: string | null = null;
            try {
                const meeting = await service.createMeeting({ name: `${MARK} status`, organizerPersonId: world.ivy.personId, startsAt: nextWeek(), status: 'Draft', attendees: [{ personId: world.jun.personId }] }, ctx.User);
                meetingId = meeting.ID;
                const jump = await service.endMeeting(meeting.ID, ctx.User);
                Assert(!jump.ok && /A Draft meeting moves to/.test(jump.message ?? ''), `Draft does not jump to Completed: ${jump.message}`);
                const scheduled = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, ctx.User);
                Assert(await scheduled.Load(meeting.ID), 'load');
                scheduled.Status = 'Scheduled';
                await RequireSave(scheduled, 'Draft to Scheduled');

                const asJun = await getPersonaContext(ctx, world.jun.email);
                const junStarts = await new MeetingService(provider(asJun)).startMeeting(meeting.ID, asJun.User);
                Assert(!junStarts.ok && /Only the organizer starts a meeting/.test(junStarts.message ?? ''), `an attendee who is not the organizer is refused: ${junStarts.message}`);

                const asIvy = await getPersonaContext(ctx, world.ivy.email);
                const ivyStarts = await new MeetingService(provider(asIvy)).startMeeting(meeting.ID, asIvy.User);
                Assert(ivyStarts.ok, `the organizer, a UI-only user, starts it: ${ivyStarts.message}`);
                Assert(!!ivyStarts.meeting?.ActualStartedAt, 'the start is stamped');
                const ivyEnds = await new MeetingService(provider(asIvy)).endMeeting(meeting.ID, asIvy.User);
                Assert(ivyEnds.ok && !!ivyEnds.meeting?.ActualEndedAt, `the organizer ends it: ${ivyEnds.message}`);
                const cancelDone = await service.cancelMeeting(meeting.ID, 'too late', ctx.User);
                Assert(!cancelDone.ok, 'a completed meeting is not cancelled');
            } finally {
                await cleanupPersonaProviders(ctx);
                if (meetingId) await deleteMeeting(ctx, meetingId);
            }
        },
    },
    {
        Id: 'meetings.M4',
        Name: 'M4 — a private meeting is read by its attendees only: the organizer and an invited UI user see it, a UI user not invited does not; a Standard one is seen by all',
        RequiresMutation: true,
        Fn: async (ctx: IntegrationCheckContext) => {
            const world = await LoadMeetingWorld(ctx);
            const service = new MeetingService(provider(ctx));
            let privateId: string | null = null;
            let standardId: string | null = null;
            try {
                const privateMeeting = await service.createMeeting({ name: `${MARK} one-on-one`, organizerPersonId: world.ivy.personId, startsAt: nextWeek(), visibility: 'Private' }, ctx.User);
                privateId = privateMeeting.ID;
                const standard = await service.createMeeting({ name: `${MARK} open`, organizerPersonId: world.ivy.personId, startsAt: nextWeek(), visibility: 'Standard' }, ctx.User);
                standardId = standard.ID;

                const asIvy = await getPersonaContext(ctx, world.ivy.email);
                const asJun = await getPersonaContext(ctx, world.jun.email);
                const ivySees = await FindRows<{ ID: string }>(asIvy, MEETING_ENTITY, `ID = '${privateMeeting.ID}'`, ['ID']);
                Assert(ivySees.length === 1, 'the organizer reads her private meeting');
                const junBlind = await FindRows<{ ID: string }>(asJun, MEETING_ENTITY, `ID = '${privateMeeting.ID}'`, ['ID']);
                Assert(junBlind.length === 0, 'a UI user who is not invited does not read it');
                const junAgendaBlind = await FindRows<{ ID: string }>(asJun, MEETING_ATTENDEE_ENTITY, `MeetingID = '${privateMeeting.ID}'`, ['ID']);
                Assert(junAgendaBlind.length === 0, 'nor its attendee rows');
                const junSeesStandard = await FindRows<{ ID: string }>(asJun, MEETING_ENTITY, `ID = '${standard.ID}'`, ['ID']);
                Assert(junSeesStandard.length === 1, 'a Standard meeting is read by anyone who reads meetings');

                await service.addAttendee(privateMeeting.ID, { personId: world.jun.personId }, ctx.User);
                // MJ's RunViewsWithCacheCheck judges freshness without the caller's row filter, so the provider would hand back the
                // empty result it cached a moment ago; the read bypasses the cache (an MJ finding, in the T1 note)
                const junInvited = await FindRows<{ ID: string }>(asJun, MEETING_ENTITY, `ID = '${privateMeeting.ID}'`, ['ID'], { BypassCache: true });
                Assert(junInvited.length === 1, 'once invited, he reads it');
            } finally {
                await cleanupPersonaProviders(ctx);
                if (privateId) await deleteMeeting(ctx, privateId);
                if (standardId) await deleteMeeting(ctx, standardId);
            }
        },
    },
    {
        Id: 'meetings.M5',
        Name: 'M5 — cancelling a meeting stamps it and, after the commit, tells the video provider\'s driver to delete the provider\'s meeting',
        RequiresMutation: true,
        Fn: async (ctx: IntegrationCheckContext) => {
            const world = await LoadMeetingWorld(ctx);
            const service = new MeetingService(provider(ctx));
            let meetingId: string | null = null;
            let providerId: string | null = null;
            try {
                const existing = await FindRows<{ ID: string }>(ctx, VIDEO_PROVIDER_ENTITY, `Code = 'FAKE'`, ['ID']);
                const fake = await ctx.Provider.GetEntityObject<mjBizAppsTasksVideoProviderEntity>(VIDEO_PROVIDER_ENTITY, ctx.User);
                if (existing[0]) await fake.Load(existing[0].ID);
                else fake.NewRecord();
                fake.Name = `${MARK} fake provider`;
                fake.Code = 'FAKE';
                fake.DriverClass = FAKE_DRIVER;
                fake.IsActive = true;
                fake.IsDefault = false;
                fake.SupportsTranscripts = false;
                await RequireSave(fake, 'the fake video provider');
                providerId = fake.ID;

                const videoMeetingId = `fake-${Date.now()}`;
                const meeting = await service.createMeeting({ name: `${MARK} on video`, organizerPersonId: world.ivy.personId, startsAt: nextWeek(), videoProviderId: fake.ID }, ctx.User);
                meetingId = meeting.ID;
                const withVideo = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, ctx.User);
                Assert(await withVideo.Load(meeting.ID), 'load');
                withVideo.VideoMeetingID = videoMeetingId;
                withVideo.VideoJoinURL = `https://fake.video/${videoMeetingId}`;
                await RequireSave(withVideo, 'the provider\'s meeting id');

                const cancelled = await service.cancelMeeting(meeting.ID, 'Moved to email.', ctx.User);
                Assert(cancelled.ok && !!cancelled.meeting?.CancelledAt && cancelled.meeting.CancellationReason === 'Moved to email.', `cancelled and stamped: ${cancelled.message}`);
                await eventually(
                    () => FindRows<{ Body: string }>(ctx, MEETING_NOTE_ENTITY, `MeetingID = '${meeting.ID}' AND Body LIKE '%${Quote(videoMeetingId)}%'`, ['Body']),
                    (rows) => rows.some((r) => r.Body.includes('deleted video meeting')),
                    'the fake driver recorded the delete after the commit',
                );
            } finally {
                if (meetingId) await deleteMeeting(ctx, meetingId);
                if (providerId) await deleteRows(ctx, VIDEO_PROVIDER_ENTITY, `ID = '${providerId}'`);
            }
        },
    },
];

for (const check of checks) IntegrationCheckRegistry.Instance.Register(check);
IntegrationCheckRegistry.Instance.RegisterLifecycle('meetings', { Setup: async () => {}, Teardown: async () => {} });
