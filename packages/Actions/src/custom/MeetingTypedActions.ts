import { Metadata, RunView, type UserInfo } from '@memberjunction/core';
import type { ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import { TypedActionPolicyGuard } from '@memberjunction/ai-core-plus';
import { EscapeSQLString, IsValidUUID, NormalizeUUID, RegisterClass, UUIDsEqual } from '@memberjunction/global';
import {
    COS_TASKS_INBOX_WORKSTREAM_KEY,
    extractDecisionsFromText,
    markProposedTaskAccepted,
    MeetingNotesService,
    parseProposedTasks,
    ResolveBriefingContributorBounds,
    RunWithBriefingContributorTimeout,
    SerializeBriefingPayloadWithLimit,
    serializeProposedTasks,
    TasksLimitsResolver,
} from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksMeetingAgendaItemEntity,
    mjBizAppsTasksMeetingAttendeeEntity,
    mjBizAppsTasksMeetingEntity,
    mjBizAppsTasksMeetingNoteEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskLinkEntity,
} from '@mj-biz-apps/tasks-entities';
import { MeetingTranscriptService } from '../meetings/MeetingTranscriptService.js';
import {
    buildMeetingDeepLink,
    buildTaskDeepLink,
    checkTypedPolicyGuard,
    failResult,
    findEntityIDByName,
    getBooleanParam,
    getNumberParam,
    getStringListParam,
    getStringParam,
    MEETING_AGENDA_ITEMS_ENTITY,
    MEETING_ATTENDEES_ENTITY,
    MEETING_NOTES_ENTITY,
    MEETINGS_ENTITY,
    resolveCallerPerson,
    resolveUserIDForPersonRecord,
    setOutputParam,
    successResult,
    TASK_ASSIGNMENTS_ENTITY,
    TASK_LINKS_ENTITY,
    TASKS_ENTITY,
    toIsoOrNull,
    wakeChiefOfStaffBestEffort,
} from './action-helpers.js';

interface RawMeetingRow {
    ID: string;
    Name: string;
    Description?: string | null;
    Status: mjBizAppsTasksMeetingEntity['Status'];
    StartsAt: Date | string;
    EndsAt: Date | string;
    TimeZone: string;
    LocationType: mjBizAppsTasksMeetingEntity['LocationType'];
    Location?: string | null;
    VideoJoinURL?: string | null;
    VideoMeetingID?: string | null;
    SeriesID?: string | null;
    OrganizerPersonID: string;
    OrganizerPerson?: string | null;
    Visibility: mjBizAppsTasksMeetingEntity['Visibility'];
    TranscriptFileID?: string | null;
    Type?: string | null;
}

interface RawMeetingAttendeeRow {
    ID: string;
    MeetingID: string;
    PersonID: string | null;
    Person?: string | null;
    UserID: string | null;
    Email: string | null;
    DisplayName: string | null;
    Role: mjBizAppsTasksMeetingAttendeeEntity['Role'];
    ResponseStatus: mjBizAppsTasksMeetingAttendeeEntity['ResponseStatus'];
    AttendanceStatus: mjBizAppsTasksMeetingAttendeeEntity['AttendanceStatus'];
}

interface RawMeetingAgendaRow {
    ID: string;
    MeetingID: string;
    Sequence: number;
    Name: string;
    Description?: string | null;
    Status: mjBizAppsTasksMeetingAgendaItemEntity['Status'];
    Outcome?: string | null;
    DurationMinutes?: number | null;
    PresenterPerson?: string | null;
}

interface RawMeetingNoteRow {
    ID: string;
    MeetingID: string;
    AgendaItemID?: string | null;
    Kind: mjBizAppsTasksMeetingNoteEntity['Kind'];
    Title: string | null;
    Body: string;
    Source: mjBizAppsTasksMeetingNoteEntity['Source'];
    Status: mjBizAppsTasksMeetingNoteEntity['Status'];
    AuthorPerson?: string | null;
    ProposedTasks?: string | null;
    __mj_CreatedAt?: Date | string;
}

interface LinkExistingMatchInput {
    ProposalID: string;
    ExistingTaskID: string;
}

interface AttendeeCommitmentRef {
    AssigneePersonID: string | null;
    Title: string;
    TaskID?: string | null;
    ProposalID?: string | null;
}

/**
 * Routes meeting commitments owned by attendees other than the caller to each attendee's
 * Chief of Staff via ONE coalesced per-user `tasks-inbox` wake.
 */
async function routeOtherAttendeeCommitments(
    commitments: ReadonlyArray<AttendeeCommitmentRef>,
    meetingID: string,
    meetingName: string | null,
    noteID: string | null,
    actingUser: UserInfo,
): Promise<string[]> {
    const callerPerson = await resolveCallerPerson(actingUser);
    const byPerson = new Map<string, AttendeeCommitmentRef[]>();
    for (const c of commitments) {
        if (!c.AssigneePersonID || !IsValidUUID(c.AssigneePersonID)) continue;
        if (callerPerson?.ID && UUIDsEqual(c.AssigneePersonID, callerPerson.ID)) continue;
        const key = NormalizeUUID(c.AssigneePersonID);
        const list = byPerson.get(key) ?? [];
        list.push(c);
        byPerson.set(key, list);
    }
    if (byPerson.size === 0) return [];

    const wokenUserIDs: string[] = [];
    const seenUsers = new Set<string>();
    const meetingLabel = meetingName ? `"${meetingName}"` : `meeting ${meetingID}`;

    for (const items of byPerson.values()) {
        const personID = items[0].AssigneePersonID;
        if (!personID) continue;
        const targetUserID = await resolveUserIDForPersonRecord(personID, actingUser);
        if (!targetUserID || !IsValidUUID(targetUserID)) continue;
        if (UUIDsEqual(targetUserID, actingUser.ID)) continue;
        const normUser = NormalizeUUID(targetUserID);
        if (seenUsers.has(normUser)) continue;
        seenUsers.add(normUser);

        const titles = items.map((i) => i.Title).filter(Boolean);
        const wakeReason =
            items.length === 1
                ? `Meeting commitment from ${meetingLabel} assigned to you: "${titles[0]}".`
                : `${items.length} meeting commitments from ${meetingLabel} were assigned to you.`;

        const taskIDs = items.map((i) => i.TaskID).filter((id): id is string => Boolean(id));
        const proposalIDs = items.map((i) => i.ProposalID).filter((id): id is string => Boolean(id));

        await wakeChiefOfStaffBestEffort({
            targetUserID,
            workstreamKey: COS_TASKS_INBOX_WORKSTREAM_KEY,
            wakeReason,
            resumeState: {
                eventType: 'MeetingCommitmentRouted',
                meetingID,
                meetingName,
                meetingNoteID: noteID,
                assigneePersonID: personID,
                commitmentCount: items.length,
                taskIDs: taskIDs.length > 0 ? taskIDs.join(',') : null,
                proposalIDs: proposalIDs.length > 0 ? proposalIDs.join(',') : null,
            },
            actingUser,
        });
        wokenUserIDs.push(targetUserID);
    }

    return wokenUserIDs;
}

function parseLinkExistingMatches(raw: string | null): LinkExistingMatchInput[] {
    if (!raw) return [];
    try {
        const parsed = JSON.parse(raw) as LinkExistingMatchInput[];
        if (!Array.isArray(parsed)) return [];
        return parsed.filter(
            (item) =>
                typeof item === 'object' &&
                item !== null &&
                typeof item.ProposalID === 'string' &&
                typeof item.ExistingTaskID === 'string' &&
                IsValidUUID(item.ExistingTaskID),
        );
    } catch {
        return [];
    }
}

async function ensureMeetingTaskLink(
    taskID: string,
    meetingID: string,
    description: string,
    user: UserInfo,
): Promise<boolean> {
    const meetingEntityID = findEntityIDByName(MEETINGS_ENTITY);
    if (!meetingEntityID) return false;

    const rv = new RunView();
    const existingRes = await rv.RunView<{ ID: string }>(
        {
            EntityName: TASK_LINKS_ENTITY,
            ExtraFilter:
                `TaskID = '${EscapeSQLString(taskID)}' ` +
                `AND EntityID = '${EscapeSQLString(meetingEntityID)}' ` +
                `AND RecordID = '${EscapeSQLString(meetingID)}'`,
            Fields: ['ID'],
            MaxRows: TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow,
            ResultType: 'simple',
        },
        user,
    );
    if (existingRes.Success && (existingRes.Results?.length ?? 0) > 0) {
        return true;
    }

    const md = new Metadata();
    const link = await md.GetEntityObject<mjBizAppsTasksTaskLinkEntity>(TASK_LINKS_ENTITY, user);
    link.NewRecord();
    link.TaskID = taskID;
    link.EntityID = meetingEntityID;
    link.RecordID = meetingID;
    link.Description = description;
    return link.Save();
}

// =============================================================================
// 1. Get My Upcoming Meetings
// =============================================================================

@RegisterClass(BaseAction, 'GetMyUpcomingMeetingsAction')
export class GetMyUpcomingMeetingsAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const guard = await checkTypedPolicyGuard({
            params,
            entityName: MEETINGS_ENTITY,
            operation: 'Read',
        });
        if (!guard.Allowed) return guard.Failure;

        try {
            const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
            const daysAheadRaw = getNumberParam(params, 'DaysAhead') ?? limits.Tuning.FindMeetingsDefaultDaysAhead;
            const daysAhead = Math.max(1, Math.min(limits.RunawayGuards.FindMeetingsMaxHorizonDays, Math.round(daysAheadRaw)));
            const includePastHoursRaw = getNumberParam(params, 'IncludePastHours') ?? 0;
            const includePastHours = Math.max(0, Math.min(limits.RunawayGuards.FindMeetingsMaxPastHours, includePastHoursRaw));
            const limitRaw = getNumberParam(params, 'Limit', 'MaxRows') ?? limits.Tuning.FindMeetingsDefaultLimit;
            const limit = Math.max(1, Math.min(limits.RunawayGuards.FindMeetingsMaxLimit, Math.round(limitRaw)));

            const callerPerson = await resolveCallerPerson(user);
            const rv = new RunView();

            const attendeeClauses: string[] = [];
            if (IsValidUUID(user.ID)) {
                attendeeClauses.push(`UserID = '${EscapeSQLString(user.ID)}'`);
            }
            if (callerPerson?.ID) {
                attendeeClauses.push(`PersonID = '${EscapeSQLString(callerPerson.ID)}'`);
            }

            let attendeeMeetingIDs: string[] = [];
            if (attendeeClauses.length > 0) {
                const attRes = await rv.RunView<{ MeetingID: string }>(
                    {
                        EntityName: MEETING_ATTENDEES_ENTITY,
                        ExtraFilter: attendeeClauses.join(' OR '),
                        Fields: ['MeetingID'],
                        MaxRows: limits.ResourceGuards.BroadEntityQueryMaxRows,
                        ResultType: 'simple',
                    },
                    user,
                );
                if (attRes.Success) {
                    attendeeMeetingIDs = Array.from(
                        new Set((attRes.Results ?? []).map((r) => r.MeetingID).filter((id) => IsValidUUID(id))),
                    );
                }
            }

            const scopeClauses: string[] = [];
            if (attendeeMeetingIDs.length > 0) {
                scopeClauses.push(
                    `ID IN (${attendeeMeetingIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ')})`,
                );
            }
            if (callerPerson?.ID) {
                scopeClauses.push(`OrganizerPersonID = '${EscapeSQLString(callerPerson.ID)}'`);
            }

            if (scopeClauses.length === 0) {
                return failResult(
                    'NO_PERSON_RECORD',
                    'No active Person record or meeting attendance could be resolved for ContextUser.',
                    params,
                );
            }

            const now = Date.now();
            const windowStart = new Date(now - includePastHours * 60 * 60 * 1000).toISOString();
            const windowEnd = new Date(now + daysAhead * 24 * 60 * 60 * 1000).toISOString();

            const meetingsRes = await rv.RunView<RawMeetingRow>(
                {
                    EntityName: MEETINGS_ENTITY,
                    ExtraFilter:
                        `(${scopeClauses.join(' OR ')}) ` +
                        `AND Status NOT IN ('Cancelled') ` +
                        `AND EndsAt >= '${EscapeSQLString(windowStart)}' ` +
                        `AND StartsAt <= '${EscapeSQLString(windowEnd)}'`,
                    Fields: [
                        'ID',
                        'Name',
                        'Status',
                        'StartsAt',
                        'EndsAt',
                        'TimeZone',
                        'LocationType',
                        'Location',
                        'VideoJoinURL',
                        'SeriesID',
                        'OrganizerPersonID',
                        'OrganizerPerson',
                        'Visibility',
                        'TranscriptFileID',
                        'Type',
                    ],
                    OrderBy: 'StartsAt ASC',
                    MaxRows: limit,
                    ResultType: 'simple',
                },
                user,
            );

            if (!meetingsRes.Success) {
                return failResult('ERROR', meetingsRes.ErrorMessage ?? 'Failed to load upcoming meetings.', params);
            }

            const meetings = meetingsRes.Results ?? [];
            const meetingIDs = meetings.map((m) => m.ID).filter((id) => IsValidUUID(id));

            const agendaCountByMeeting = new Map<string, number>();
            const attendeeCountByMeeting = new Map<string, number>();
            const notesCountByMeeting = new Map<string, number>();

            if (meetingIDs.length > 0) {
                const inList = meetingIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
                const [agendaRes, attCountRes, notesRes] = await Promise.all([
                    rv.RunView<{ MeetingID: string }>(
                        { EntityName: MEETING_AGENDA_ITEMS_ENTITY, ExtraFilter: `MeetingID IN (${inList})`, Fields: ['MeetingID'], ResultType: 'simple' },
                        user,
                    ),
                    rv.RunView<{ MeetingID: string }>(
                        { EntityName: MEETING_ATTENDEES_ENTITY, ExtraFilter: `MeetingID IN (${inList})`, Fields: ['MeetingID'], ResultType: 'simple' },
                        user,
                    ),
                    rv.RunView<{ MeetingID: string }>(
                        { EntityName: MEETING_NOTES_ENTITY, ExtraFilter: `MeetingID IN (${inList})`, Fields: ['MeetingID'], ResultType: 'simple' },
                        user,
                    ),
                ]);

                for (const r of agendaRes.Success ? (agendaRes.Results ?? []) : []) {
                    const k = NormalizeUUID(r.MeetingID);
                    agendaCountByMeeting.set(k, (agendaCountByMeeting.get(k) ?? 0) + 1);
                }
                for (const r of attCountRes.Success ? (attCountRes.Results ?? []) : []) {
                    const k = NormalizeUUID(r.MeetingID);
                    attendeeCountByMeeting.set(k, (attendeeCountByMeeting.get(k) ?? 0) + 1);
                }
                for (const r of notesRes.Success ? (notesRes.Results ?? []) : []) {
                    const k = NormalizeUUID(r.MeetingID);
                    notesCountByMeeting.set(k, (notesCountByMeeting.get(k) ?? 0) + 1);
                }
            }

            const compact = meetings.map((m) => {
                const k = NormalizeUUID(m.ID);
                const agendaCount = agendaCountByMeeting.get(k) ?? 0;
                const notesCount = notesCountByMeeting.get(k) ?? 0;
                return {
                    ID: m.ID,
                    Name: m.Name,
                    Status: m.Status,
                    StartsAt: toIsoOrNull(m.StartsAt),
                    EndsAt: toIsoOrNull(m.EndsAt),
                    TimeZone: m.TimeZone,
                    LocationType: m.LocationType,
                    Location: m.Location ?? null,
                    VideoJoinURL: m.VideoJoinURL ?? null,
                    Organizer: m.OrganizerPerson ?? null,
                    Type: m.Type ?? null,
                    Visibility: m.Visibility,
                    AttendeeCount: attendeeCountByMeeting.get(k) ?? 0,
                    AgendaItemCount: agendaCount,
                    HasAgenda: agendaCount > 0,
                    HasNotes: notesCount > 0,
                    HasTranscript: Boolean(m.TranscriptFileID),
                    DeepLink: buildMeetingDeepLink(m.ID),
                };
            });

            const masked = TypedActionPolicyGuard.MaskRows(compact, guard.DeniedFieldPatterns);
            const summary = `Found ${masked.length} upcoming meeting(s) within the next ${daysAhead} day(s).`;
            setOutputParam(params, 'Meetings', JSON.stringify(masked));
            setOutputParam(params, 'TotalCount', masked.length);
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }
}

// =============================================================================
// 2. Prepare Meeting Brief
// =============================================================================

@RegisterClass(BaseAction, 'PrepareMeetingBriefAction')
export class PrepareMeetingBriefAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const meetingID = getStringParam(params, 'MeetingID');
        if (!meetingID || !IsValidUUID(meetingID)) {
            return failResult('VALIDATION_ERROR', 'A valid MeetingID UUID is required.', params);
        }

        const meetingGuard = await checkTypedPolicyGuard({
            params,
            entityName: MEETINGS_ENTITY,
            operation: 'Read',
        });
        if (!meetingGuard.Allowed) return meetingGuard.Failure;

        const tasksGuard = await checkTypedPolicyGuard({
            params,
            entityName: TASKS_ENTITY,
            operation: 'Read',
        });
        if (!tasksGuard.Allowed) return tasksGuard.Failure;

        try {
            const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
            const noteExcerptMaxChars = limits.Briefing.MeetingNoteExcerptMaxChars;
            const rv = new RunView();
            const escapedMeetingID = EscapeSQLString(meetingID);
            const [meetingRes, attendeesRes, agendaRes, currentNotesRes] = await Promise.all([
                rv.RunView<RawMeetingRow>(
                    {
                        EntityName: MEETINGS_ENTITY,
                        ExtraFilter: `ID = '${escapedMeetingID}'`,
                        MaxRows: limits.ResourceGuards.DefaultLookupSingleRow,
                        ResultType: 'simple',
                    },
                    user,
                ),
                rv.RunView<RawMeetingAttendeeRow>(
                    {
                        EntityName: MEETING_ATTENDEES_ENTITY,
                        ExtraFilter: `MeetingID = '${escapedMeetingID}'`,
                        Fields: ['ID', 'MeetingID', 'PersonID', 'Person', 'UserID', 'Email', 'DisplayName', 'Role', 'ResponseStatus', 'AttendanceStatus'],
                        MaxRows: limits.ResourceGuards.StandardBatchMaxRows,
                        ResultType: 'simple',
                    },
                    user,
                ),
                rv.RunView<RawMeetingAgendaRow>(
                    {
                        EntityName: MEETING_AGENDA_ITEMS_ENTITY,
                        ExtraFilter: `MeetingID = '${escapedMeetingID}'`,
                        Fields: ['ID', 'MeetingID', 'Sequence', 'Name', 'Description', 'Status', 'Outcome', 'DurationMinutes', 'PresenterPerson'],
                        OrderBy: 'Sequence ASC',
                        MaxRows: limits.ResourceGuards.StandardBatchMaxRows,
                        ResultType: 'simple',
                    },
                    user,
                ),
                rv.RunView<RawMeetingNoteRow>(
                    {
                        EntityName: MEETING_NOTES_ENTITY,
                        ExtraFilter: `MeetingID = '${escapedMeetingID}'`,
                        Fields: ['ID', 'MeetingID', 'Kind', 'Title', 'Body', 'Status', 'Source', '__mj_CreatedAt'],
                        OrderBy: '__mj_CreatedAt DESC',
                        MaxRows: limits.ResourceGuards.RecentContextMaxRows,
                        ResultType: 'simple',
                    },
                    user,
                ),
            ]);

            const meeting = meetingRes.Success ? meetingRes.Results?.[0] : undefined;
            if (!meeting) {
                return failResult('NOT_FOUND', `Meeting '${meetingID}' was not found or is not accessible.`, params);
            }

            const attendees = attendeesRes.Success ? (attendeesRes.Results ?? []) : [];
            const agendaItems = agendaRes.Success ? (agendaRes.Results ?? []) : [];
            const attendeePersonIDs = Array.from(
                new Set(
                    attendees
                        .map((a) => a.PersonID)
                        .filter((id): id is string => Boolean(id && IsValidUUID(id))),
                ),
            );

            // Load prior meeting notes from the same recurring series (if any)
            let priorSeriesNotes: Array<Record<string, string | null>> = [];
            if (meeting.SeriesID && IsValidUUID(meeting.SeriesID)) {
                const priorMeetingsRes = await rv.RunView<{ ID: string; Name: string; StartsAt: Date | string }>(
                    {
                        EntityName: MEETINGS_ENTITY,
                        ExtraFilter:
                            `SeriesID = '${EscapeSQLString(meeting.SeriesID)}' ` +
                            `AND ID <> '${escapedMeetingID}' ` +
                            `AND StartsAt < '${EscapeSQLString(toIsoOrNull(meeting.StartsAt) ?? new Date().toISOString())}'`,
                        Fields: ['ID', 'Name', 'StartsAt'],
                        OrderBy: 'StartsAt DESC',
                        MaxRows: limits.ResourceGuards.RecentLinksMaxRows,
                        ResultType: 'simple',
                    },
                    user,
                );
                const priorIds = (priorMeetingsRes.Success ? (priorMeetingsRes.Results ?? []) : []).map((m) => m.ID);
                if (priorIds.length > 0) {
                    const priorNotesRes = await rv.RunView<RawMeetingNoteRow>(
                        {
                            EntityName: MEETING_NOTES_ENTITY,
                            ExtraFilter: `MeetingID IN (${priorIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ')})`,
                            Fields: ['ID', 'MeetingID', 'Kind', 'Title', 'Body', 'Status', '__mj_CreatedAt'],
                            OrderBy: '__mj_CreatedAt DESC',
                            MaxRows: limits.ResourceGuards.RecentContextMaxRows,
                            ResultType: 'simple',
                        },
                        user,
                    );
                    priorSeriesNotes = (priorNotesRes.Success ? (priorNotesRes.Results ?? []) : []).map((n) => ({
                        ID: n.ID,
                        MeetingID: n.MeetingID,
                        Kind: n.Kind,
                        Title: n.Title ?? null,
                        Excerpt: (n.Body ?? '').slice(0, noteExcerptMaxChars),
                        CreatedAt: toIsoOrNull(n.__mj_CreatedAt),
                    }));
                }
            }

            // Load open/recent tasks linked to this meeting or assigned to attendees
            const taskIds = new Set<string>();
            const meetingEntityID = findEntityIDByName(MEETINGS_ENTITY);
            if (meetingEntityID) {
                const linkRes = await rv.RunView<{ TaskID: string }>(
                    {
                        EntityName: TASK_LINKS_ENTITY,
                        ExtraFilter: `EntityID = '${EscapeSQLString(meetingEntityID)}' AND RecordID = '${escapedMeetingID}'`,
                        Fields: ['TaskID'],
                        MaxRows: limits.ResourceGuards.StandardListMaxRows,
                        ResultType: 'simple',
                    },
                    user,
                );
                for (const l of linkRes.Success ? (linkRes.Results ?? []) : []) {
                    if (IsValidUUID(l.TaskID)) taskIds.add(l.TaskID);
                }
            }
            if (attendeePersonIDs.length > 0) {
                const assignRes = await rv.RunView<{ TaskID: string }>(
                    {
                        EntityName: TASK_ASSIGNMENTS_ENTITY,
                        ExtraFilter: `AssigneeRecordID IN (${attendeePersonIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ')})`,
                        Fields: ['TaskID'],
                        MaxRows: limits.ResourceGuards.ExtendedSearchMaxRows,
                        ResultType: 'simple',
                    },
                    user,
                );
                for (const a of assignRes.Success ? (assignRes.Results ?? []) : []) {
                    if (IsValidUUID(a.TaskID)) taskIds.add(a.TaskID);
                }
            }

            let relatedOpenTasks: Array<Record<string, string | number | boolean | null | undefined>> = [];
            if (taskIds.size > 0) {
                const inTasks = Array.from(taskIds)
                    .slice(0, limits.ResourceGuards.StandardBatchMaxRows)
                    .map((id) => `'${EscapeSQLString(id)}'`)
                    .join(', ');
                const tRes = await rv.RunView<
                    Pick<mjBizAppsTasksTaskEntity, 'ID' | 'Name' | 'Status' | 'Priority' | 'DueAt' | 'PercentComplete' | 'BlockedReason'>
                >(
                    {
                        EntityName: TASKS_ENTITY,
                        ExtraFilter: `ID IN (${inTasks}) AND Status NOT IN ('Completed', 'Cancelled')`,
                        Fields: ['ID', 'Name', 'Status', 'Priority', 'DueAt', 'PercentComplete', 'BlockedReason'],
                        OrderBy: 'DueAt ASC',
                        MaxRows: limits.ResourceGuards.RelatedSearchMaxRows,
                        ResultType: 'simple',
                    },
                    user,
                );
                const rawTasks = (tRes.Success ? (tRes.Results ?? []) : []).map((t) => ({
                    ID: t.ID,
                    Name: t.Name,
                    Status: t.Status,
                    Priority: t.Priority,
                    DueAt: toIsoOrNull(t.DueAt),
                    PercentComplete: t.PercentComplete ?? 0,
                    BlockedReason: t.BlockedReason ?? null,
                    DeepLink: buildTaskDeepLink(t.ID),
                }));
                relatedOpenTasks = TypedActionPolicyGuard.MaskRows(rawTasks, tasksGuard.DeniedFieldPatterns);
            }

            const maskedMeeting = TypedActionPolicyGuard.MaskRecord(
                {
                    ID: meeting.ID,
                    Name: meeting.Name,
                    Description: meeting.Description ?? null,
                    Status: meeting.Status,
                    StartsAt: toIsoOrNull(meeting.StartsAt),
                    EndsAt: toIsoOrNull(meeting.EndsAt),
                    TimeZone: meeting.TimeZone,
                    LocationType: meeting.LocationType,
                    Location: meeting.Location ?? null,
                    VideoJoinURL: meeting.VideoJoinURL ?? null,
                    Organizer: meeting.OrganizerPerson ?? null,
                    Visibility: meeting.Visibility,
                    DeepLink: buildMeetingDeepLink(meeting.ID),
                },
                meetingGuard.DeniedFieldPatterns,
            );

            const brief = {
                Meeting: maskedMeeting,
                LiveCalendarRecheck: {
                    Recommended: true,
                    IsCancelled: meeting.Status === 'Cancelled',
                    ScheduledStartsAt: toIsoOrNull(meeting.StartsAt),
                    ScheduledEndsAt: toIsoOrNull(meeting.EndsAt),
                    Guidance:
                        'Verify live calendar event status before delivering this brief; skip silently if cancelled or reschedule wake if moved.',
                },
                Attendees: attendees.map((a) => ({
                    PersonID: a.PersonID ?? null,
                    Name: a.DisplayName || a.Person || a.Email || 'Guest',
                    Email: a.Email ?? null,
                    Role: a.Role,
                    ResponseStatus: a.ResponseStatus,
                })),
                Agenda: agendaItems.map((item) => ({
                    ID: item.ID,
                    Sequence: item.Sequence,
                    Name: item.Name,
                    Status: item.Status,
                    DurationMinutes: item.DurationMinutes ?? null,
                    Presenter: item.PresenterPerson ?? null,
                    Outcome: item.Outcome ?? null,
                })),
                ExistingNotesForThisMeeting: (currentNotesRes.Success ? (currentNotesRes.Results ?? []) : []).map((n) => ({
                    ID: n.ID,
                    Kind: n.Kind,
                    Title: n.Title ?? null,
                    Excerpt: (n.Body ?? '').slice(0, noteExcerptMaxChars),
                })),
                PriorMeetingNotes: priorSeriesNotes,
                RelatedOpenTasks: relatedOpenTasks,
            };

            const summary =
                `Prepared brief for "${meeting.Name}" (${attendees.length} attendee(s), ` +
                `${agendaItems.length} agenda item(s), ${relatedOpenTasks.length} open task(s), ` +
                `${priorSeriesNotes.length} prior note(s)).`;
            setOutputParam(params, 'Brief', JSON.stringify(brief));
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }
}

// =============================================================================
// 3. Process Meeting Transcript
// =============================================================================

@RegisterClass(BaseAction, 'ProcessMeetingTranscriptAction')
export class ProcessMeetingTranscriptAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const meetingID = getStringParam(params, 'MeetingID');
        if (!meetingID || !IsValidUUID(meetingID)) {
            return failResult('VALIDATION_ERROR', 'A valid MeetingID UUID is required.', params);
        }

        const autoCreate = getBooleanParam(params, 'AutoCreateCommitments', false);

        const meetingGuard = await checkTypedPolicyGuard({
            params,
            entityName: MEETINGS_ENTITY,
            operation: 'Read',
        });
        if (!meetingGuard.Allowed) return meetingGuard.Failure;

        const notesGuard = await checkTypedPolicyGuard({
            params,
            entityName: MEETING_NOTES_ENTITY,
            operation: 'Create',
            writeFields: ['MeetingID', 'Kind', 'Title', 'Body', 'Source', 'Status', 'ProposedTasks'],
        });
        if (!notesGuard.Allowed) return notesGuard.Failure;

        if (autoCreate) {
            const taskCreateGuard = await checkTypedPolicyGuard({
                params,
                entityName: TASKS_ENTITY,
                operation: 'Create',
                writeFields: ['Name', 'Description', 'TypeID', 'Status', 'Priority', 'DueAt'],
            });
            if (!taskCreateGuard.Allowed) return taskCreateGuard.Failure;
        }

        try {
            const transcriptText = getStringParam(params, 'TranscriptText');
            const sourceDriver = getStringParam(params, 'SourceDriver');
            const windowDays =
                getNumberParam(params, 'WindowDays') ??
                TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.FindSimilarDefaultWindowDays;

            const service = new MeetingTranscriptService(Metadata.Provider);
            const result = await service.ProcessMeetingTranscript(
                {
                    MeetingID: meetingID,
                    TranscriptText: transcriptText,
                    SourceDriver: sourceDriver,
                    WindowDays: windowDays,
                },
                user,
            );

            const autoCreatedTaskIDs: string[] = [];
            const autoLinkedTaskIDs: string[] = [];
            const createdTaskIdByProposal = new Map<string, string>();

            if (autoCreate && result.Status === 'PROCESSED' && result.NoteID) {
                const notesService = new MeetingNotesService(Metadata.Provider);
                for (const proposal of result.ProposedNewCommitments) {
                    const accepted = await notesService.acceptProposedTask(
                        result.NoteID,
                        proposal.ProposalID,
                        user,
                    );
                    autoCreatedTaskIDs.push(accepted.task.ID);
                    createdTaskIdByProposal.set(proposal.ProposalID.toLowerCase(), accepted.task.ID);
                }
                for (const matched of result.MatchedExistingTasks) {
                    const linked = await ensureMeetingTaskLink(
                        matched.MatchedTask.TaskID,
                        meetingID,
                        `Matched commitment from meeting transcript: ${matched.ProposalTitle}`,
                        user,
                    );
                    if (linked) {
                        autoLinkedTaskIDs.push(matched.MatchedTask.TaskID);
                    }
                }
            }

            // Route other attendees' commitments to their Chief of Staff via coalesced 'tasks-inbox' wake
            let routedAttendeeUserIDs: string[] = [];
            if (result.Status === 'PROCESSED') {
                const commitmentRefs: AttendeeCommitmentRef[] = [
                    ...result.ProposedNewCommitments.map((p) => ({
                        AssigneePersonID: p.AssigneePersonID ?? null,
                        Title: p.Title,
                        TaskID: createdTaskIdByProposal.get(p.ProposalID.toLowerCase()) ?? null,
                        ProposalID: p.ProposalID,
                    })),
                    ...result.MatchedExistingTasks.map((m) => ({
                        AssigneePersonID: m.AssigneePersonID ?? null,
                        Title: m.ProposalTitle,
                        TaskID: m.MatchedTask.TaskID,
                        ProposalID: m.ProposalID,
                    })),
                ];
                routedAttendeeUserIDs = await routeOtherAttendeeCommitments(
                    commitmentRefs,
                    meetingID,
                    result.MeetingName,
                    result.NoteID,
                    user,
                );
            }

            const payload = {
                ...result,
                AutoCreateCommitments: autoCreate,
                AutoCreatedTaskIDs: autoCreatedTaskIDs,
                AutoLinkedTaskIDs: autoLinkedTaskIDs,
                RoutedAttendeeUserIDs: routedAttendeeUserIDs,
            };

            setOutputParam(params, 'Status', result.Status);
            setOutputParam(params, 'NoteID', result.NoteID ?? '');
            setOutputParam(params, 'Result', JSON.stringify(payload));
            setOutputParam(params, 'Summary', result.Message);
            return successResult(result.Message, params);
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            if (/not found/i.test(msg)) return failResult('NOT_FOUND', msg, params);
            if (/Only the meeting organizer/i.test(msg)) return failResult('PERMISSION_DENIED', msg, params);
            return failResult('ERROR', msg, params);
        }
    }
}

// =============================================================================
// 4. Accept Meeting Commitments
// =============================================================================

@RegisterClass(BaseAction, 'AcceptMeetingCommitmentsAction')
export class AcceptMeetingCommitmentsAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const noteID = getStringParam(params, 'MeetingNoteID', 'NoteID');
        if (!noteID || !IsValidUUID(noteID)) {
            return failResult('VALIDATION_ERROR', 'A valid MeetingNoteID UUID is required.', params);
        }

        const taskGuard = await checkTypedPolicyGuard({
            params,
            entityName: TASKS_ENTITY,
            operation: 'Create',
            writeFields: ['Name', 'Description', 'TypeID', 'Status', 'Priority', 'DueAt'],
        });
        if (!taskGuard.Allowed) return taskGuard.Failure;

        const noteGuard = await checkTypedPolicyGuard({
            params,
            entityName: MEETING_NOTES_ENTITY,
            operation: 'Update',
            writeFields: ['ProposedTasks'],
        });
        if (!noteGuard.Allowed) return noteGuard.Failure;

        try {
            const md = new Metadata();
            const note = await md.GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(MEETING_NOTES_ENTITY, user);
            if (!(await note.Load(noteID))) {
                return failResult('NOT_FOUND', `Meeting note '${noteID}' was not found or is not accessible.`, params);
            }

            const existingProposals = parseProposedTasks(note.ProposedTasks);
            const requestedProposalIDs = getStringListParam(params, 'ProposalIDs');
            const linkMatches = parseLinkExistingMatches(getStringParam(params, 'LinkExistingMatches'));
            const linkByProposal = new Map<string, string>(
                linkMatches.map((m) => [m.ProposalID.toLowerCase(), m.ExistingTaskID]),
            );

            const targetProposalIDs =
                requestedProposalIDs.length > 0
                    ? requestedProposalIDs
                    : existingProposals.filter((p) => p.status === 'Pending').map((p) => p.id);

            if (targetProposalIDs.length === 0 && linkMatches.length === 0) {
                const summary = 'No pending meeting commitments to accept on this note.';
                setOutputParam(params, 'AcceptedTasks', '[]');
                setOutputParam(params, 'LinkedTasks', '[]');
                setOutputParam(params, 'Summary', summary);
                return successResult(summary, params);
            }

            const acceptedTasks: Array<{ ProposalID: string; TaskID: string; Title: string; DeepLink: string }> = [];
            const linkedTasks: Array<{ ProposalID: string; ExistingTaskID: string; DeepLink: string }> = [];
            const routedCommitmentRefs: AttendeeCommitmentRef[] = [];

            // 1. Link proposals matched to existing tasks (prevents duplicates!)
            let updatedProposals = existingProposals;
            let proposalsModified = false;
            for (const match of linkMatches) {
                const target = updatedProposals.find(
                    (p) => p.id.toLowerCase() === match.ProposalID.toLowerCase(),
                );
                if (!target) continue;
                await ensureMeetingTaskLink(
                    match.ExistingTaskID,
                    note.MeetingID,
                    `Linked existing task to meeting commitment: ${target.title}`,
                    user,
                );
                updatedProposals = markProposedTaskAccepted(updatedProposals, target.id, match.ExistingTaskID);
                proposalsModified = true;
                linkedTasks.push({
                    ProposalID: target.id,
                    ExistingTaskID: match.ExistingTaskID,
                    DeepLink: buildTaskDeepLink(match.ExistingTaskID),
                });
                routedCommitmentRefs.push({
                    AssigneePersonID: target.assigneePersonId,
                    Title: target.title,
                    TaskID: match.ExistingTaskID,
                    ProposalID: target.id,
                });
            }

            if (proposalsModified) {
                note.ProposedTasks = serializeProposedTasks(updatedProposals);
                await note.Save();
            }

            // 2. Accept remaining requested proposals via idempotent MeetingNotesService.acceptProposedTask
            const notesService = new MeetingNotesService(Metadata.Provider);
            for (const proposalId of targetProposalIDs) {
                if (linkByProposal.has(proposalId.toLowerCase())) continue;
                const res = await notesService.acceptProposedTask(noteID, proposalId, user);
                acceptedTasks.push({
                    ProposalID: res.proposal.id,
                    TaskID: res.task.ID,
                    Title: res.task.Name || res.proposal.title,
                    DeepLink: buildTaskDeepLink(res.task.ID),
                });
                routedCommitmentRefs.push({
                    AssigneePersonID: res.proposal.assigneePersonId,
                    Title: res.task.Name || res.proposal.title,
                    TaskID: res.task.ID,
                    ProposalID: res.proposal.id,
                });
            }

            // 3. Route commitments assigned to other attendees to their Chief of Staff via coalesced 'tasks-inbox' wake
            await routeOtherAttendeeCommitments(
                routedCommitmentRefs,
                note.MeetingID,
                note.Meeting ?? null,
                noteID,
                user,
            );

            const summary = `Accepted ${acceptedTasks.length} new commitment task(s) and linked ${linkedTasks.length} existing task(s).`;
            setOutputParam(params, 'AcceptedTasks', JSON.stringify(acceptedTasks));
            setOutputParam(params, 'LinkedTasks', JSON.stringify(linkedTasks));
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            if (/not found/i.test(msg)) return failResult('NOT_FOUND', msg, params);
            if (/Only the meeting organizer|can accept or dismiss/i.test(msg)) {
                return failResult('PERMISSION_DENIED', msg, params);
            }
            return failResult('ERROR', msg, params);
        }
    }
}

// =============================================================================
// 5. Get Meeting Notes
// =============================================================================

@RegisterClass(BaseAction, 'GetMeetingNotesAction')
export class GetMeetingNotesAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const meetingID = getStringParam(params, 'MeetingID');
        if (!meetingID || !IsValidUUID(meetingID)) {
            return failResult('VALIDATION_ERROR', 'A valid MeetingID UUID is required.', params);
        }

        const meetingGuard = await checkTypedPolicyGuard({
            params,
            entityName: MEETINGS_ENTITY,
            operation: 'Read',
        });
        if (!meetingGuard.Allowed) return meetingGuard.Failure;

        const notesGuard = await checkTypedPolicyGuard({
            params,
            entityName: MEETING_NOTES_ENTITY,
            operation: 'Read',
        });
        if (!notesGuard.Allowed) return notesGuard.Failure;

        try {
            const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
            const includeProposed = getBooleanParam(params, 'IncludeProposedTasks', true);
            const rv = new RunView();
            const escapedMeetingID = EscapeSQLString(meetingID);

            const [meetingRes, notesRes, agendaRes] = await Promise.all([
                rv.RunView<RawMeetingRow>(
                    {
                        EntityName: MEETINGS_ENTITY,
                        ExtraFilter: `ID = '${escapedMeetingID}'`,
                        Fields: ['ID', 'Name', 'Status', 'StartsAt', 'EndsAt', 'OrganizerPerson', 'Visibility', 'TranscriptFileID'],
                        MaxRows: limits.ResourceGuards.DefaultLookupSingleRow,
                        ResultType: 'simple',
                    },
                    user,
                ),
                rv.RunView<RawMeetingNoteRow>(
                    {
                        EntityName: MEETING_NOTES_ENTITY,
                        ExtraFilter: `MeetingID = '${escapedMeetingID}'`,
                        Fields: ['ID', 'MeetingID', 'AgendaItemID', 'Kind', 'Title', 'Body', 'Source', 'Status', 'AuthorPerson', 'ProposedTasks', '__mj_CreatedAt'],
                        OrderBy: '__mj_CreatedAt DESC',
                        MaxRows: limits.ResourceGuards.StandardListMaxRows,
                        ResultType: 'simple',
                    },
                    user,
                ),
                rv.RunView<RawMeetingAgendaRow>(
                    {
                        EntityName: MEETING_AGENDA_ITEMS_ENTITY,
                        ExtraFilter: `MeetingID = '${escapedMeetingID}'`,
                        Fields: ['ID', 'Sequence', 'Name', 'Status', 'Outcome'],
                        OrderBy: 'Sequence ASC',
                        MaxRows: limits.ResourceGuards.StandardBatchMaxRows,
                        ResultType: 'simple',
                    },
                    user,
                ),
            ]);

            const meeting = meetingRes.Success ? meetingRes.Results?.[0] : undefined;
            if (!meeting) {
                return failResult('NOT_FOUND', `Meeting '${meetingID}' was not found or is not accessible.`, params);
            }

            const notes = notesRes.Success ? (notesRes.Results ?? []) : [];
            const agenda = agendaRes.Success ? (agendaRes.Results ?? []) : [];

            // Linked tasks on this meeting
            const meetingEntityID = findEntityIDByName(MEETINGS_ENTITY);
            let linkedTasks: Array<{ TaskID: string; Name: string; Status: string; DueAt: string | null; DeepLink: string }> = [];
            if (meetingEntityID) {
                const linksRes = await rv.RunView<{ TaskID: string }>(
                    {
                        EntityName: TASK_LINKS_ENTITY,
                        ExtraFilter: `EntityID = '${EscapeSQLString(meetingEntityID)}' AND RecordID = '${escapedMeetingID}'`,
                        Fields: ['TaskID'],
                        MaxRows: limits.ResourceGuards.StandardListMaxRows,
                        ResultType: 'simple',
                    },
                    user,
                );
                const linkedTaskIds = Array.from(
                    new Set((linksRes.Success ? (linksRes.Results ?? []) : []).map((l) => l.TaskID).filter((id) => IsValidUUID(id))),
                );
                if (linkedTaskIds.length > 0) {
                    const tRes = await rv.RunView<Pick<mjBizAppsTasksTaskEntity, 'ID' | 'Name' | 'Status' | 'DueAt'>>(
                        {
                            EntityName: TASKS_ENTITY,
                            ExtraFilter: `ID IN (${linkedTaskIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ')})`,
                            Fields: ['ID', 'Name', 'Status', 'DueAt'],
                            ResultType: 'simple',
                        },
                        user,
                    );
                    linkedTasks = (tRes.Success ? (tRes.Results ?? []) : []).map((t) => ({
                        TaskID: t.ID,
                        Name: t.Name,
                        Status: t.Status,
                        DueAt: toIsoOrNull(t.DueAt),
                        DeepLink: buildTaskDeepLink(t.ID),
                    }));
                }
            }

            const decisions: string[] = [];
            for (const n of notes) {
                if (n.Kind === 'Decision' && n.Body.trim()) {
                    decisions.push(n.Body.trim());
                } else {
                    decisions.push(...extractDecisionsFromText(n.Body));
                }
            }
            for (const item of agenda) {
                if (item.Outcome?.trim()) {
                    decisions.push(`${item.Name}: ${item.Outcome.trim()}`);
                }
            }

            const formattedNotes = notes.map((n) => {
                const baseRecord: Record<string, string | number | boolean | object | null | undefined> = {
                    ID: n.ID,
                    AgendaItemID: n.AgendaItemID ?? null,
                    Kind: n.Kind,
                    Title: n.Title ?? null,
                    Body: n.Body,
                    Source: n.Source,
                    Status: n.Status,
                    AuthorPerson: n.AuthorPerson ?? null,
                    CreatedAt: toIsoOrNull(n.__mj_CreatedAt),
                };
                if (includeProposed) {
                    try {
                        baseRecord.ProposedTasks = parseProposedTasks(n.ProposedTasks);
                    } catch {
                        baseRecord.ProposedTasks = [];
                    }
                }
                return TypedActionPolicyGuard.MaskRecord(baseRecord, notesGuard.DeniedFieldPatterns);
            });

            const payload = {
                Meeting: TypedActionPolicyGuard.MaskRecord(
                    {
                        ID: meeting.ID,
                        Name: meeting.Name,
                        Status: meeting.Status,
                        StartsAt: toIsoOrNull(meeting.StartsAt),
                        EndsAt: toIsoOrNull(meeting.EndsAt),
                        Organizer: meeting.OrganizerPerson ?? null,
                        HasTranscript: Boolean(meeting.TranscriptFileID),
                        DeepLink: buildMeetingDeepLink(meeting.ID),
                    },
                    meetingGuard.DeniedFieldPatterns,
                ),
                Notes: formattedNotes,
                Decisions: Array.from(new Set(decisions)),
                LinkedTasks: linkedTasks,
            };

            const summary = `Loaded ${formattedNotes.length} note(s), ${payload.Decisions.length} decision(s), and ${linkedTasks.length} linked task(s) for "${meeting.Name}".`;
            setOutputParam(params, 'MeetingNotes', JSON.stringify(payload));
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }
}

// =============================================================================
// 6. Get My Meetings Briefing (Role = 'Briefing', ExposeToModel = false)
// =============================================================================

@RegisterClass(BaseAction, 'GetMyMeetingsBriefingAction')
export class GetMyMeetingsBriefingAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const meetingGuard = await checkTypedPolicyGuard({
            params,
            entityName: MEETINGS_ENTITY,
            operation: 'Read',
        });
        if (!meetingGuard.Allowed) return meetingGuard.Failure;

        const notesGuard = await checkTypedPolicyGuard({
            params,
            entityName: MEETING_NOTES_ENTITY,
            operation: 'Read',
        });
        if (!notesGuard.Allowed) return notesGuard.Failure;

        try {
            const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
            const bounds = ResolveBriefingContributorBounds({
                HorizonDays: getNumberParam(params, 'HorizonDays'),
                LookbackDays: getNumberParam(params, 'LookbackDays'),
                MaxItems: getNumberParam(params, 'MaxItems'),
                LookbackKind: 'meetings',
            });
            const horizonDays = bounds.HorizonDays;
            const lookbackDays = bounds.LookbackDays;
            const maxItems = bounds.MaxItems;

            return await RunWithBriefingContributorTimeout(
                async () => {
                    const callerPerson = await resolveCallerPerson(user);
            const rv = new RunView();

            const attendeeClauses: string[] = [];
            if (IsValidUUID(user.ID)) {
                attendeeClauses.push(`UserID = '${EscapeSQLString(user.ID)}'`);
            }
            if (callerPerson?.ID) {
                attendeeClauses.push(`PersonID = '${EscapeSQLString(callerPerson.ID)}'`);
            }

            let attendeeMeetingIDs: string[] = [];
            if (attendeeClauses.length > 0) {
                const attRes = await rv.RunView<{ MeetingID: string }>(
                    {
                        EntityName: MEETING_ATTENDEES_ENTITY,
                        ExtraFilter: attendeeClauses.join(' OR '),
                        Fields: ['MeetingID'],
                        MaxRows: limits.ResourceGuards.BroadEntityQueryMaxRows,
                        ResultType: 'simple',
                    },
                    user,
                );
                if (attRes.Success) {
                    attendeeMeetingIDs = Array.from(
                        new Set((attRes.Results ?? []).map((r) => r.MeetingID).filter((id) => IsValidUUID(id))),
                    );
                }
            }

            const scopeClauses: string[] = [];
            if (attendeeMeetingIDs.length > 0) {
                scopeClauses.push(
                    `ID IN (${attendeeMeetingIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ')})`,
                );
            }
            if (callerPerson?.ID) {
                scopeClauses.push(`OrganizerPersonID = '${EscapeSQLString(callerPerson.ID)}'`);
            }

            if (scopeClauses.length === 0) {
                return failResult(
                    'NO_PERSON_RECORD',
                    'No active Person record or meeting attendance could be resolved for ContextUser.',
                    params,
                );
            }

            const now = new Date();
            const nowMs = now.getTime();
            const lookbackStart = new Date(nowMs - lookbackDays * 24 * 60 * 60 * 1000).toISOString();
            const horizonEnd = new Date(nowMs + horizonDays * 24 * 60 * 60 * 1000).toISOString();

            const meetingsRes = await rv.RunView<RawMeetingRow>(
                {
                    EntityName: MEETINGS_ENTITY,
                    ExtraFilter:
                        `(${scopeClauses.join(' OR ')}) ` +
                        `AND Status NOT IN ('Cancelled') ` +
                        `AND EndsAt >= '${EscapeSQLString(lookbackStart)}' ` +
                        `AND StartsAt <= '${EscapeSQLString(horizonEnd)}'`,
                    Fields: [
                        'ID',
                        'Name',
                        'Status',
                        'StartsAt',
                        'EndsAt',
                        'TimeZone',
                        'LocationType',
                        'Location',
                        'VideoJoinURL',
                        'OrganizerPersonID',
                        'OrganizerPerson',
                        'Visibility',
                        'TranscriptFileID',
                        'Type',
                    ],
                    OrderBy: 'StartsAt ASC',
                    MaxRows: limits.ResourceGuards.StandardBatchMaxRows,
                    ResultType: 'simple',
                },
                user,
            );
            if (!meetingsRes.Success) {
                return failResult('ERROR', meetingsRes.ErrorMessage ?? 'Failed to load meetings briefing.', params);
            }

            const allMeetings = meetingsRes.Results ?? [];
            const allMeetingIDs = allMeetings.map((m) => m.ID).filter((id) => IsValidUUID(id));
            const meetingNameByNormID = new Map<string, string>(
                allMeetings.map((m) => [NormalizeUUID(m.ID), m.Name]),
            );

            const agendaCountByMeeting = new Map<string, number>();
            const attendeeCountByMeeting = new Map<string, number>();
            const notesByMeeting = new Map<string, RawMeetingNoteRow[]>();

            if (allMeetingIDs.length > 0) {
                const inList = allMeetingIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
                const [agendaRes, attCountRes, notesRes] = await Promise.all([
                    rv.RunView<{ MeetingID: string }>(
                        {
                            EntityName: MEETING_AGENDA_ITEMS_ENTITY,
                            ExtraFilter: `MeetingID IN (${inList})`,
                            Fields: ['MeetingID'],
                            ResultType: 'simple',
                        },
                        user,
                    ),
                    rv.RunView<{ MeetingID: string }>(
                        {
                            EntityName: MEETING_ATTENDEES_ENTITY,
                            ExtraFilter: `MeetingID IN (${inList})`,
                            Fields: ['MeetingID'],
                            ResultType: 'simple',
                        },
                        user,
                    ),
                    rv.RunView<RawMeetingNoteRow>(
                        {
                            EntityName: MEETING_NOTES_ENTITY,
                            ExtraFilter: `MeetingID IN (${inList})`,
                            Fields: ['ID', 'MeetingID', 'Kind', 'Source', 'Status', 'ProposedTasks'],
                            ResultType: 'simple',
                        },
                        user,
                    ),
                ]);

                for (const r of agendaRes.Success ? (agendaRes.Results ?? []) : []) {
                    const k = NormalizeUUID(r.MeetingID);
                    agendaCountByMeeting.set(k, (agendaCountByMeeting.get(k) ?? 0) + 1);
                }
                for (const r of attCountRes.Success ? (attCountRes.Results ?? []) : []) {
                    const k = NormalizeUUID(r.MeetingID);
                    attendeeCountByMeeting.set(k, (attendeeCountByMeeting.get(k) ?? 0) + 1);
                }
                for (const n of notesRes.Success ? (notesRes.Results ?? []) : []) {
                    const k = NormalizeUUID(n.MeetingID);
                    const list = notesByMeeting.get(k) ?? [];
                    list.push(n);
                    notesByMeeting.set(k, list);
                }
            }

            const upcomingRaw: Array<Record<string, string | number | boolean | null>> = [];
            const recentCompletedNeedingFollowUpRaw: Array<
                Record<string, string | number | boolean | string[] | null>
            > = [];
            let needingTranscriptCount = 0;
            let needingAcceptanceCount = 0;

            for (const m of allMeetings) {
                const normID = NormalizeUUID(m.ID);
                const endsAtMs = new Date(m.EndsAt).getTime();
                const isPastOrCompleted =
                    m.Status === 'Completed' || (!Number.isNaN(endsAtMs) && endsAtMs < nowMs);
                const meetingNotes = notesByMeeting.get(normID) ?? [];

                if (!isPastOrCompleted) {
                    const agendaCount = agendaCountByMeeting.get(normID) ?? 0;
                    upcomingRaw.push({
                        ID: m.ID,
                        Name: m.Name,
                        Status: m.Status,
                        StartsAt: toIsoOrNull(m.StartsAt),
                        EndsAt: toIsoOrNull(m.EndsAt),
                        TimeZone: m.TimeZone,
                        LocationType: m.LocationType,
                        Location: m.Location ?? null,
                        VideoJoinURL: m.VideoJoinURL ?? null,
                        Organizer: m.OrganizerPerson ?? null,
                        Type: m.Type ?? null,
                        Visibility: m.Visibility,
                        AttendeeCount: attendeeCountByMeeting.get(normID) ?? 0,
                        AgendaItemCount: agendaCount,
                        HasAgenda: agendaCount > 0,
                        HasNotes: meetingNotes.length > 0,
                        HasTranscript: Boolean(m.TranscriptFileID),
                        DeepLink: buildMeetingDeepLink(m.ID),
                    });
                } else {
                    const hasProcessedNote = meetingNotes.some(
                        (n) => n.Source === 'AI' || n.Kind === 'Summary',
                    );
                    let pendingCommitmentsCount = 0;
                    const pendingNoteIDs: string[] = [];
                    for (const n of meetingNotes) {
                        if (!n.ProposedTasks) continue;
                        try {
                            const pending = parseProposedTasks(n.ProposedTasks).filter((p) => p.status === 'Pending');
                            if (pending.length > 0) {
                                pendingCommitmentsCount += pending.length;
                                pendingNoteIDs.push(n.ID);
                            }
                        } catch {
                            // Ignore malformed legacy JSON when summarizing briefing counts
                        }
                    }

                    const needsTranscriptProcessing = !hasProcessedNote;
                    const needsCommitmentAcceptance = pendingCommitmentsCount > 0;
                    if (needsTranscriptProcessing) needingTranscriptCount += 1;
                    if (needsCommitmentAcceptance) needingAcceptanceCount += 1;

                    if (needsTranscriptProcessing || needsCommitmentAcceptance) {
                        recentCompletedNeedingFollowUpRaw.push({
                            ID: m.ID,
                            Name: m.Name,
                            Status: m.Status,
                            StartsAt: toIsoOrNull(m.StartsAt),
                            EndsAt: toIsoOrNull(m.EndsAt),
                            Organizer: m.OrganizerPerson ?? null,
                            Visibility: m.Visibility,
                            HasTranscript: Boolean(m.TranscriptFileID),
                            NeedsTranscriptProcessing: needsTranscriptProcessing,
                            NeedsCommitmentAcceptance: needsCommitmentAcceptance,
                            PendingCommitmentsCount: pendingCommitmentsCount,
                            PendingNoteIDs: pendingNoteIDs,
                            DeepLink: buildMeetingDeepLink(m.ID),
                        });
                    }
                }
            }

            // Most recent completed meetings first
            recentCompletedNeedingFollowUpRaw.reverse();

            // Load open follow-up tasks linked to the caller's meetings (if policy permits reading Tasks)
            let openFollowUpTasks: Array<Record<string, string | number | boolean | null | undefined>> = [];
            const meetingEntityID = findEntityIDByName(MEETINGS_ENTITY);
            if (meetingEntityID && allMeetingIDs.length > 0) {
                const tasksGuard = await checkTypedPolicyGuard({
                    params,
                    entityName: TASKS_ENTITY,
                    operation: 'Read',
                });
                if (tasksGuard.Allowed) {
                    const inMeetings = allMeetingIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
                    const linksRes = await rv.RunView<{ TaskID: string; RecordID: string }>(
                        {
                            EntityName: TASK_LINKS_ENTITY,
                            ExtraFilter: `EntityID = '${EscapeSQLString(meetingEntityID)}' AND RecordID IN (${inMeetings})`,
                            Fields: ['TaskID', 'RecordID'],
                            MaxRows: limits.ResourceGuards.WorkflowBatchMaxRows,
                            ResultType: 'simple',
                        },
                        user,
                    );
                    const meetingIdByTaskNorm = new Map<string, string>();
                    const linkedTaskIds: string[] = [];
                    for (const link of linksRes.Success ? (linksRes.Results ?? []) : []) {
                        if (!IsValidUUID(link.TaskID)) continue;
                        const normTask = NormalizeUUID(link.TaskID);
                        if (!meetingIdByTaskNorm.has(normTask)) {
                            meetingIdByTaskNorm.set(normTask, link.RecordID);
                            linkedTaskIds.push(link.TaskID);
                        }
                    }

                    if (linkedTaskIds.length > 0) {
                        const inTasks = linkedTaskIds
                            .slice(0, limits.ResourceGuards.StandardBatchMaxRows)
                            .map((id) => `'${EscapeSQLString(id)}'`)
                            .join(', ');
                        const tasksRes = await rv.RunView<
                            Pick<
                                mjBizAppsTasksTaskEntity,
                                'ID' | 'Name' | 'Status' | 'Priority' | 'Visibility' | 'DueAt' | 'PercentComplete' | 'BlockedReason'
                            >
                        >(
                            {
                                EntityName: TASKS_ENTITY,
                                ExtraFilter: `ID IN (${inTasks}) AND Status NOT IN ('Completed', 'Cancelled')`,
                                Fields: [
                                    'ID',
                                    'Name',
                                    'Status',
                                    'Priority',
                                    'Visibility',
                                    'DueAt',
                                    'PercentComplete',
                                    'BlockedReason',
                                ],
                                OrderBy: 'DueAt ASC',
                                MaxRows: maxItems,
                                ResultType: 'simple',
                            },
                            user,
                        );
                        const rawTasks = (tasksRes.Success ? (tasksRes.Results ?? []) : []).map((t) => {
                            const mId = meetingIdByTaskNorm.get(NormalizeUUID(t.ID)) ?? null;
                            return {
                                ID: t.ID,
                                Name: t.Name,
                                Status: t.Status,
                                Priority: t.Priority,
                                Visibility: t.Visibility ?? 'Standard',
                                DueAt: toIsoOrNull(t.DueAt),
                                PercentComplete: t.PercentComplete ?? 0,
                                BlockedReason: t.BlockedReason ?? null,
                                MeetingID: mId,
                                MeetingName: mId ? (meetingNameByNormID.get(NormalizeUUID(mId)) ?? null) : null,
                                DeepLink: buildTaskDeepLink(t.ID),
                            };
                        });
                        openFollowUpTasks = TypedActionPolicyGuard.MaskRows(rawTasks, tasksGuard.DeniedFieldPatterns);
                    }
                }
            }

            const upcomingMeetings = TypedActionPolicyGuard.MaskRows(
                upcomingRaw.slice(0, maxItems),
                meetingGuard.DeniedFieldPatterns,
            );
            const recentCompletedNeedingFollowUp = TypedActionPolicyGuard.MaskRows(
                recentCompletedNeedingFollowUpRaw.slice(0, maxItems),
                meetingGuard.DeniedFieldPatterns,
            );

            const briefing = {
                GeneratedAt: now.toISOString(),
                HorizonDays: horizonDays,
                LookbackDays: lookbackDays,
                Counts: {
                    UpcomingMeetings: upcomingRaw.length,
                    RecentCompletedNeedingFollowUp: recentCompletedNeedingFollowUpRaw.length,
                    NeedingTranscriptProcessing: needingTranscriptCount,
                    NeedingCommitmentAcceptance: needingAcceptanceCount,
                    OpenMeetingFollowUpTasks: openFollowUpTasks.length,
                },
                UpcomingMeetings: upcomingMeetings,
                RecentCompletedMeetingsNeedingFollowUp: recentCompletedNeedingFollowUp,
                OpenMeetingFollowUpTasks: openFollowUpTasks,
            };

            const summary =
                `Meetings briefing: ${upcomingRaw.length} upcoming (${horizonDays}d), ` +
                `${recentCompletedNeedingFollowUpRaw.length} recent completed needing follow-up ` +
                `(${needingTranscriptCount} transcript, ${needingAcceptanceCount} commitment acceptance), ` +
                `${openFollowUpTasks.length} open meeting follow-up task(s).`;

            const serialized = SerializeBriefingPayloadWithLimit(
                briefing,
                ['UpcomingMeetings', 'RecentCompletedMeetingsNeedingFollowUp', 'OpenMeetingFollowUpTasks'],
                bounds.MaxContributorChars,
            );
                    setOutputParam(params, 'Briefing', serialized.Json);
                    setOutputParam(params, 'Summary', summary);
                    return successResult(summary, params);
                },
                bounds.ContributorTimeoutMs,
                'GetMyMeetingsBriefingAction',
            );
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }
}
