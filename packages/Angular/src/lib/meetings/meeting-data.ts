/**
 * The Meetings app's data, in one place (the meetings plan, § 5): it reads the records and builds the models the widgets
 * draw, and it makes every change through the entities and tasks-core's services, so the server's rules apply. Pages and
 * form panels own an instance each; the widgets never read a record.
 */
import { CompositeKey, LogError, Metadata, RunView, type UserInfo } from '@memberjunction/core';
import type {
    mjBizAppsTasksMeetingAgendaItemEntity,
    mjBizAppsTasksMeetingAttendeeEntity,
    mjBizAppsTasksMeetingEntity,
    mjBizAppsTasksMeetingLinkEntity,
    mjBizAppsTasksMeetingNoteEntity,
    mjBizAppsTasksMeetingSeriesEntity,
    mjBizAppsTasksTaskLinkEntity,
    TaskEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    MEETING_AGENDA_ITEM_ENTITY,
    MEETING_AGENDA_ITEM_TYPE_ENTITY,
    MEETING_ATTENDEE_ENTITY,
    MEETING_ENTITY,
    MEETING_LINK_ENTITY,
    MEETING_NOTE_ENTITY,
    MEETING_SERIES_ENTITY,
    MEETING_TYPE_ENTITY,
    MeetingAgendaService,
    MeetingCalendarFile,
    MeetingService,
    TaskAssignmentService,
    VIDEO_PROVIDER_ENTITY,
    callerAdministersMeetings,
    entityFailure,
    parseAgendaTemplate,
    type MeetingStatusChange,
} from '@mj-biz-apps/tasks-core';
import type {
    AgendaItemDraft,
    AgendaItemModel,
    AgendaItemTypeOption,
    AttendeeModel,
    FollowUpDraft,
    FollowUpModel,
    LinkModel,
    MeetingPermissions,
    MeetingRow,
    MeetingTypeOption,
    NewMeetingDraft,
    NoteDraft,
    NoteModel,
    PersonOption,
    ResponseStatus,
    SeriesModel,
    VideoProviderOption,
} from '@mj-biz-apps/tasks-ng-widgets';
import type { SeriesDraft } from '@mj-biz-apps/tasks-ng-widgets';
import { ResolveCurrentPersonID, PEOPLE_ENTITY } from '../current-person';

const TASKS_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_LINKS_ENTITY = 'MJ_BizApps_Tasks: Task Links';
const TASK_TYPES_ENTITY = 'MJ_BizApps_Tasks: Task Types';
const TASK_ASSIGNMENTS_ENTITY = 'MJ_BizApps_Tasks: Task Assignments';
const ACTION_ITEM_CODE = 'ACTION_ITEM';

interface MeetingRecordRow {
    ID: string;
    Name: string;
    Description: string | null;
    Status: MeetingRow['status'];
    Visibility: MeetingRow['visibility'];
    Type: string | null;
    TypeID: string | null;
    StartsAt: string;
    EndsAt: string;
    TimeZone: string;
    LocationType: MeetingRow['locationType'];
    Location: string | null;
    VideoJoinURL: string | null;
    OrganizerPersonID: string;
    OrganizerPerson: string | null;
    SeriesID: string | null;
    CancellationReason: string | null;
    ActualStartedAt: string | null;
}

interface AttendeeRecordRow {
    ID: string;
    MeetingID: string;
    PersonID: string | null;
    UserID: string | null;
    Email: string | null;
    DisplayName: string | null;
    Person: string | null;
    Role: AttendeeModel['role'];
    ResponseStatus: ResponseStatus;
    AttendanceStatus: AttendeeModel['attendanceStatus'];
}

interface PersonRow {
    ID: string;
    DisplayName: string | null;
    FirstName: string | null;
    LastName: string | null;
    Email: string | null;
}

const MEETING_FIELDS = ['ID', 'Name', 'Description', 'Status', 'Visibility', 'Type', 'TypeID', 'StartsAt', 'EndsAt', 'TimeZone', 'LocationType', 'Location', 'VideoJoinURL', 'OrganizerPersonID', 'OrganizerPerson', 'SeriesID', 'CancellationReason', 'ActualStartedAt'];
const ATTENDEE_FIELDS = ['ID', 'MeetingID', 'PersonID', 'UserID', 'Email', 'DisplayName', 'Person', 'Role', 'ResponseStatus', 'AttendanceStatus'];

const same = (a: string | null | undefined, b: string | null | undefined): boolean => !!a && !!b && a.toLowerCase() === b.toLowerCase();
/** The meeting reads in flight or just finished, shared by the panels of one page. */
const detailCache = new Map<string, { promise: Promise<MeetingDetail>; at: number }>();
const DETAIL_SHARE_MS = 3000;
const quote = (value: string): string => value.replace(/'/g, "''");
const dateLabel = (value: string | Date | null | undefined): string => (value ? new Date(value).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : '');

/** What the viewer may do: the organizer and an administrator everything; an invited person writes notes and follow-ups. */
export function meetingPermissions(isOrganizer: boolean, isInvited: boolean, administers: boolean): MeetingPermissions {
    const owns = isOrganizer || administers;
    return { canEdit: owns, canRun: owns, canInvite: owns, canWriteNotes: owns || isInvited, canAddFollowUps: owns || isInvited };
}

export interface MeetingDetail {
    row: MeetingRow;
    description: string | null;
    cancellationReason: string | null;
    startedAt: Date | null;
    typeId: string | null;
    typeHasTemplate: boolean;
    attendees: AttendeeModel[];
    agenda: AgendaItemModel[];
    notes: NoteModel[];
    followUps: FollowUpModel[];
    links: LinkModel[];
    permissions: MeetingPermissions;
    myAttendeeId: string | null;
}

export class MeetingData {
    private readonly md = new Metadata();
    private personId: string | null | undefined;
    private typeIcons = new Map<string, string | null>();
    private typeTemplates = new Set<string>();

    private get user(): UserInfo {
        return this.md.CurrentUser;
    }

    /** The viewer's Person, looked up once; null when they have none. */
    async currentPersonId(): Promise<string | null> {
        if (this.personId === undefined) {
            try {
                this.personId = await ResolveCurrentPersonID();
            } catch (error) {
                LogError(`Meetings: the viewer's Person could not be read: ${error instanceof Error ? error.message : String(error)}`);
                this.personId = null;
            }
        }
        return this.personId;
    }

    /** Whether the viewer may change every meeting: a role above UI that updates Meetings. */
    administers(): boolean {
        return callerAdministersMeetings(Metadata.Provider, this.user);
    }

    // ── reads ────────────────────────────────────────────────────────────────

    private async rows<T extends object>(entityName: string, extraFilter: string, fields: string[], orderBy = '', maxRows = 500): Promise<T[]> {
        const res = await new RunView().RunView<T>({ EntityName: entityName, ExtraFilter: extraFilter, Fields: fields, OrderBy: orderBy, ResultType: 'simple', MaxRows: maxRows, BypassCache: true }, this.user);
        if (!res.Success) throw new Error(res.ErrorMessage ?? `${entityName} could not be read`);
        return res.Results ?? [];
    }

    async loadTypes(): Promise<MeetingTypeOption[]> {
        const rows = await this.rows<{ ID: string; Name: string; Code: string; IconClass: string | null; DefaultDurationMinutes: number | null; DefaultLocationType: MeetingRow['locationType'] | null; DefaultVisibility: MeetingRow['visibility'] | null; AgendaTemplate: string | null; IsActive: boolean }>(
            MEETING_TYPE_ENTITY, 'IsActive = 1', ['ID', 'Name', 'Code', 'IconClass', 'DefaultDurationMinutes', 'DefaultLocationType', 'DefaultVisibility', 'AgendaTemplate', 'IsActive'], 'Sequence ASC',
        );
        this.typeIcons = new Map(rows.map((r) => [r.ID.toLowerCase(), r.IconClass]));
        this.typeTemplates = new Set(rows.filter((r) => !!parseAgendaTemplate(r.AgendaTemplate)?.items.length).map((r) => r.ID.toLowerCase()));
        return rows.map((r) => ({ id: r.ID, name: r.Name, code: r.Code, iconClass: r.IconClass, defaultDurationMinutes: r.DefaultDurationMinutes, defaultLocationType: r.DefaultLocationType, defaultVisibility: r.DefaultVisibility }));
    }

    typesWithTemplate(): string[] {
        return [...this.typeTemplates];
    }

    async loadAgendaItemTypes(): Promise<AgendaItemTypeOption[]> {
        const rows = await this.rows<{ ID: string; Name: string; Code: string; DefaultDurationMinutes: number | null }>(MEETING_AGENDA_ITEM_TYPE_ENTITY, 'IsActive = 1', ['ID', 'Name', 'Code', 'DefaultDurationMinutes'], 'Sequence ASC');
        return rows.map((r) => ({ id: r.ID, name: r.Name, code: r.Code, defaultDurationMinutes: r.DefaultDurationMinutes }));
    }

    async loadVideoProviders(): Promise<VideoProviderOption[]> {
        const rows = await this.rows<{ ID: string; Name: string; Code: string }>(VIDEO_PROVIDER_ENTITY, 'IsActive = 1', ['ID', 'Name', 'Code'], 'Name ASC');
        return rows.map((r) => ({ id: r.ID, name: r.Name, code: r.Code }));
    }

    async loadPeople(): Promise<PersonOption[]> {
        const rows = await this.rows<PersonRow>(PEOPLE_ENTITY, "Status = 'Active'", ['ID', 'DisplayName', 'FirstName', 'LastName', 'Email'], 'LastName ASC, FirstName ASC', 1000);
        return rows.map((r) => ({ id: r.ID, name: this.personName(r), email: r.Email }));
    }

    private personName(row: PersonRow): string {
        return row.DisplayName || [row.FirstName, row.LastName].filter(Boolean).join(' ') || row.Email || 'Someone';
    }

    /**
     * Meeting rows for a list. `mine` keeps the meetings the viewer organizes or is invited to; otherwise every meeting the
     * viewer may read. The viewer's answer comes from their attendee row.
     */
    async loadMeetingRows(options: { mine: boolean; from?: Date | null; through?: Date | null; extraFilter?: string }): Promise<MeetingRow[]> {
        if (!this.typeIcons.size) await this.loadTypes();
        const personId = await this.currentPersonId();
        const filters: string[] = [];
        if (options.from) filters.push(`EndsAt >= '${options.from.toISOString()}'`);
        if (options.through) filters.push(`StartsAt <= '${options.through.toISOString()}'`);
        if (options.extraFilter) filters.push(`(${options.extraFilter})`);
        if (options.mine) {
            const parts = [`ID IN (SELECT MeetingID FROM [__mj_BizAppsTasks].[vwMeetingAttendees] WHERE UserID = '${this.user.ID}')`];
            if (personId) parts.push(`OrganizerPersonID = '${personId}'`, `ID IN (SELECT MeetingID FROM [__mj_BizAppsTasks].[vwMeetingAttendees] WHERE PersonID = '${personId}')`);
            filters.push(`(${parts.join(' OR ')})`);
        }
        const meetings = await this.rows<MeetingRecordRow>(MEETING_ENTITY, filters.join(' AND '), MEETING_FIELDS, 'StartsAt ASC', 500);
        if (!meetings.length) return [];
        const ids = meetings.map((m) => `'${m.ID}'`).join(',');
        const attendees = await this.rows<AttendeeRecordRow>(MEETING_ATTENDEE_ENTITY, `MeetingID IN (${ids})`, ATTENDEE_FIELDS, '', 5000);
        const counts = new Map<string, number>();
        const mine = new Map<string, AttendeeRecordRow>();
        for (const a of attendees) {
            const key = a.MeetingID.toLowerCase();
            counts.set(key, (counts.get(key) ?? 0) + 1);
            if (same(a.UserID, this.user.ID) || (personId && same(a.PersonID, personId))) mine.set(key, a);
        }
        return meetings.map((m) => this.toRow(m, personId, mine.get(m.ID.toLowerCase()) ?? null, counts.get(m.ID.toLowerCase())));
    }

    private toRow(m: MeetingRecordRow, personId: string | null, myRow: AttendeeRecordRow | null, attendeeCount?: number): MeetingRow {
        const isMine = !!personId && same(m.OrganizerPersonID, personId);
        return {
            id: m.ID,
            name: m.Name,
            status: m.Status,
            visibility: m.Visibility,
            typeName: m.Type,
            typeIcon: m.TypeID ? (this.typeIcons.get(m.TypeID.toLowerCase()) ?? null) : null,
            startsAt: new Date(m.StartsAt),
            endsAt: new Date(m.EndsAt),
            timeZone: m.TimeZone,
            locationType: m.LocationType,
            location: m.Location,
            joinUrl: m.VideoJoinURL,
            organizerName: m.OrganizerPerson,
            seriesId: m.SeriesID,
            myResponse: myRow ? myRow.ResponseStatus : isMine ? 'Accepted' : null,
            isMine,
            attendeeCount,
        };
    }

    /**
     * Everything the meeting page shows. The six panels of a meeting's form each ask for it as they mount, so one read is
     * shared by everyone who asks within a few seconds; any change made through this layer forgets it, and the next ask
     * reads again.
     */
    loadMeeting(meetingId: string): Promise<MeetingDetail> {
        const key = meetingId.toLowerCase();
        const cached = detailCache.get(key);
        if (cached && Date.now() - cached.at < DETAIL_SHARE_MS) return cached.promise;
        const promise = this.loadMeetingNow(meetingId).catch((error: unknown) => {
            if (detailCache.get(key)?.promise === promise) detailCache.delete(key);
            throw error;
        });
        detailCache.set(key, { promise, at: Date.now() });
        return promise;
    }

    /** Forgets every shared read: the next loadMeeting reads the server. Called after any change made here. */
    static forgetDetails(): void {
        detailCache.clear();
    }

    private async loadMeetingNow(meetingId: string): Promise<MeetingDetail> {
        if (!this.typeIcons.size) await this.loadTypes();
        const personId = await this.currentPersonId();
        const [record] = await this.rows<MeetingRecordRow>(MEETING_ENTITY, `ID = '${meetingId}'`, MEETING_FIELDS, '', 1);
        if (!record) throw new Error('The meeting was not found, or you may not see it.');
        const attendeeRows = await this.rows<AttendeeRecordRow>(MEETING_ATTENDEE_ENTITY, `MeetingID = '${meetingId}'`, ATTENDEE_FIELDS, 'Role ASC', 1000);
        const myRow = attendeeRows.find((a) => same(a.UserID, this.user.ID) || (personId && same(a.PersonID, personId))) ?? null;
        const row = this.toRow(record, personId, myRow, attendeeRows.length);
        const attendees = attendeeRows.map((a): AttendeeModel => ({
            id: a.ID, personId: a.PersonID, userId: a.UserID, email: a.Email, name: a.DisplayName || a.Person || a.Email || 'Guest', role: a.Role, responseStatus: a.ResponseStatus, attendanceStatus: a.AttendanceStatus, isMe: !!myRow && same(a.ID, myRow.ID),
        }));
        const [agenda, notes, links] = await Promise.all([this.loadAgenda(meetingId), this.loadNotes(meetingId), this.loadLinks(meetingId)]);
        const followUps = await this.loadFollowUps(meetingId, agenda.map((a) => a.id));
        const permissions = meetingPermissions(row.isMine, !!myRow, this.administers());
        return {
            row, description: record.Description, cancellationReason: record.CancellationReason, startedAt: record.ActualStartedAt ? new Date(record.ActualStartedAt) : null, typeId: record.TypeID,
            typeHasTemplate: !!record.TypeID && this.typeTemplates.has(record.TypeID.toLowerCase()), attendees, agenda, notes, followUps, links, permissions, myAttendeeId: myRow?.ID ?? null,
        };
    }

    async loadAgenda(meetingId: string): Promise<AgendaItemModel[]> {
        const rows = await this.rows<{ ID: string; ParentID: string | null; Sequence: number; Name: string; Description: string | null; TypeID: string | null; Type: string | null; PresenterPersonID: string | null; PresenterPerson: string | null; DurationMinutes: number | null; Status: AgendaItemModel['status']; Outcome: string | null; StartedAt: string | null; EndedAt: string | null }>(
            MEETING_AGENDA_ITEM_ENTITY, `MeetingID = '${meetingId}'`, ['ID', 'ParentID', 'Sequence', 'Name', 'Description', 'TypeID', 'Type', 'PresenterPersonID', 'PresenterPerson', 'DurationMinutes', 'Status', 'Outcome', 'StartedAt', 'EndedAt'], 'Sequence ASC', 1000,
        );
        return rows.map((r) => ({ id: r.ID, parentId: r.ParentID, sequence: r.Sequence, name: r.Name, description: r.Description, typeId: r.TypeID, typeName: r.Type, typeCode: null, presenterPersonId: r.PresenterPersonID, presenterName: r.PresenterPerson, durationMinutes: r.DurationMinutes, status: r.Status, outcome: r.Outcome, startedAt: r.StartedAt ? new Date(r.StartedAt) : null, endedAt: r.EndedAt ? new Date(r.EndedAt) : null }));
    }

    async loadNotes(meetingId: string): Promise<NoteModel[]> {
        const personId = await this.currentPersonId();
        const rows = await this.rows<{ ID: string; AgendaItemID: string | null; Kind: NoteModel['kind']; Title: string | null; Body: string; Source: NoteModel['source']; Status: NoteModel['status']; AuthorPersonID: string | null; AuthorPerson: string | null; __mj_UpdatedAt: string }>(
            MEETING_NOTE_ENTITY, `MeetingID = '${meetingId}'`, ['ID', 'AgendaItemID', 'Kind', 'Title', 'Body', 'Source', 'Status', 'AuthorPersonID', 'AuthorPerson', '__mj_UpdatedAt'], '__mj_UpdatedAt DESC', 500,
        );
        return rows.map((r) => ({ id: r.ID, agendaItemId: r.AgendaItemID, kind: r.Kind, title: r.Title, body: r.Body, source: r.Source, status: r.Status, authorName: r.AuthorPerson, updatedLabel: dateLabel(r.__mj_UpdatedAt), isMine: !!personId && same(r.AuthorPersonID, personId) }));
    }

    async loadLinks(meetingId: string): Promise<LinkModel[]> {
        const rows = await this.rows<{ ID: string; EntityID: string; Entity: string; RecordID: string; Description: string | null }>(MEETING_LINK_ENTITY, `MeetingID = '${meetingId}'`, ['ID', 'EntityID', 'Entity', 'RecordID', 'Description'], '', 200);
        if (!rows.length) return [];
        // One call names every linked record; a name that cannot be read leaves the link with its id
        const names = new Map<string, string>();
        try {
            const results = await this.md.GetEntityRecordNames(rows.map((r) => ({ EntityName: r.Entity, CompositeKey: CompositeKey.FromID(r.RecordID) })), this.user);
            for (const result of results) {
                if (result.Success && result.RecordName) names.set(`${result.EntityName.toLowerCase()}|${result.CompositeKey.ToString().toLowerCase()}`, result.RecordName);
            }
        } catch {
            // the links show without names
        }
        return rows.map((r) => ({ id: r.ID, entityName: r.Entity, recordId: r.RecordID, recordName: names.get(`${r.Entity.toLowerCase()}|${CompositeKey.FromID(r.RecordID).ToString().toLowerCase()}`) ?? null, description: r.Description }));
    }

    /** The tasks linked to the meeting or any of its agenda items. */
    async loadFollowUps(meetingId: string, agendaItemIds: string[]): Promise<FollowUpModel[]> {
        const meetingsEntity = this.md.EntityByName(MEETING_ENTITY);
        const itemsEntity = this.md.EntityByName(MEETING_AGENDA_ITEM_ENTITY);
        if (!meetingsEntity || !itemsEntity) return [];
        const clauses = [`(EntityID = '${meetingsEntity.ID}' AND RecordID = '${meetingId}')`];
        if (agendaItemIds.length) clauses.push(`(EntityID = '${itemsEntity.ID}' AND RecordID IN (${agendaItemIds.map((id) => `'${id}'`).join(',')}))`);
        const links = await this.rows<{ TaskID: string; EntityID: string; RecordID: string }>(TASK_LINKS_ENTITY, clauses.join(' OR '), ['TaskID', 'EntityID', 'RecordID'], '', 500);
        if (!links.length) return [];
        const taskIds = [...new Set(links.map((l) => l.TaskID.toUpperCase()))];
        const tasks = await this.rows<{ ID: string; Name: string; Status: string; Priority: string | null; DueAt: string | null }>(TASKS_ENTITY, `ID IN (${taskIds.map((id) => `'${id}'`).join(',')})`, ['ID', 'Name', 'Status', 'Priority', 'DueAt'], 'DueAt ASC', 500);
        const assignments = await this.rows<{ TaskID: string; Assignee: string | null; AssigneeRecordID: string }>(TASK_ASSIGNMENTS_ENTITY, `TaskID IN (${taskIds.map((id) => `'${id}'`).join(',')})`, ['TaskID', 'Assignee', 'AssigneeRecordID'], '', 2000).catch(() => []);
        const itemOf = new Map(links.filter((l) => same(l.EntityID, itemsEntity.ID)).map((l) => [l.TaskID.toLowerCase(), l.RecordID]));
        return tasks.map((t) => ({
            id: t.ID, name: t.Name, status: t.Status, priority: t.Priority, dueAt: t.DueAt ? new Date(t.DueAt) : null,
            assigneeNames: assignments.filter((a) => same(a.TaskID, t.ID)).map((a) => a.Assignee ?? a.AssigneeRecordID),
            agendaItemId: itemOf.get(t.ID.toLowerCase()) ?? null,
        }));
    }

    async loadSeries(filter = ''): Promise<SeriesModel[]> {
        const rows = await this.rows<{ ID: string; Name: string; Description: string | null; Type: string | null; OrganizerPerson: string | null; RecurrenceRule: string; TimeZone: string; FirstStartsAt: string; DurationMinutes: number; Status: SeriesModel['status']; MaterializedThrough: string | null }>(
            MEETING_SERIES_ENTITY, filter, ['ID', 'Name', 'Description', 'Type', 'OrganizerPerson', 'RecurrenceRule', 'TimeZone', 'FirstStartsAt', 'DurationMinutes', 'Status', 'MaterializedThrough'], 'FirstStartsAt DESC', 500,
        );
        if (!rows.length) return [];
        const ids = rows.map((r) => `'${r.ID}'`).join(',');
        const occurrences = await this.rows<{ SeriesID: string; StartsAt: string; Status: string }>(MEETING_ENTITY, `SeriesID IN (${ids})`, ['SeriesID', 'StartsAt', 'Status'], 'StartsAt ASC', 5000);
        const now = Date.now();
        return rows.map((r) => {
            const own = occurrences.filter((o) => same(o.SeriesID, r.ID));
            const next = own.map((o) => new Date(o.StartsAt)).filter((d) => d.getTime() >= now).sort((a, b) => a.getTime() - b.getTime())[0] ?? null;
            return { id: r.ID, name: r.Name, description: r.Description, typeName: r.Type, organizerName: r.OrganizerPerson, recurrenceRule: r.RecurrenceRule, timeZone: r.TimeZone, firstStartsAt: new Date(r.FirstStartsAt), durationMinutes: r.DurationMinutes, status: r.Status, materializedThrough: r.MaterializedThrough ? new Date(r.MaterializedThrough) : null, occurrenceCount: own.length, nextOccurrenceAt: next };
        });
    }

    // ── writes ───────────────────────────────────────────────────────────────

    async createMeeting(draft: NewMeetingDraft): Promise<mjBizAppsTasksMeetingEntity> {
        MeetingData.forgetDetails();
        const personId = await this.currentPersonId();
        if (!personId) throw new Error('Your user account is not linked to a Person, so you cannot organize a meeting. Ask an administrator to link one.');
        const service = new MeetingService(Metadata.Provider);
        const meeting = await service.createMeeting(
            {
                name: draft.name, typeId: draft.typeId, organizerPersonId: personId, startsAt: draft.startsAt, endsAt: new Date(draft.startsAt.getTime() + draft.durationMinutes * 60000), timeZone: draft.timeZone,
                locationType: draft.locationType, location: draft.location || null, videoProviderId: draft.videoProviderId, visibility: draft.visibility, description: draft.description || null, applyTemplate: draft.applyTemplate, createdByPersonId: personId,
                attendees: [...draft.attendeePersonIds.map((id) => ({ personId: id })), ...draft.guestEmails.map((email) => ({ email }))],
            },
            this.user,
        );
        if (draft.joinUrl && !draft.videoProviderId) {
            meeting.VideoJoinURL = draft.joinUrl;
            if (!(await meeting.Save())) throw new Error(entityFailure(meeting));
        }
        return meeting;
    }

    startMeeting(id: string): Promise<MeetingStatusChange> {
        MeetingData.forgetDetails();
        return new MeetingService(Metadata.Provider).startMeeting(id, this.user);
    }

    endMeeting(id: string): Promise<MeetingStatusChange> {
        MeetingData.forgetDetails();
        return new MeetingService(Metadata.Provider).endMeeting(id, this.user);
    }

    cancelMeeting(id: string, reason: string | null): Promise<MeetingStatusChange> {
        MeetingData.forgetDetails();
        return new MeetingService(Metadata.Provider).cancelMeeting(id, reason, this.user);
    }

    async respond(attendeeId: string, response: ResponseStatus): Promise<void> {
        MeetingData.forgetDetails();
        const row = await this.md.GetEntityObject<mjBizAppsTasksMeetingAttendeeEntity>(MEETING_ATTENDEE_ENTITY, this.user);
        if (!(await row.Load(attendeeId))) throw new Error('Your invitation was not found.');
        row.ResponseStatus = response;
        row.RespondedAt = new Date();
        if (!(await row.Save())) throw new Error(entityFailure(row));
    }

    /** The viewer answers a meeting they are invited to: their attendee row is found by their user or person. */
    async respondToMeeting(meetingId: string, response: ResponseStatus): Promise<void> {
        MeetingData.forgetDetails();
        const personId = await this.currentPersonId();
        const rows = await this.rows<AttendeeRecordRow>(MEETING_ATTENDEE_ENTITY, `MeetingID = '${meetingId}'`, ATTENDEE_FIELDS, '', 1000);
        const mine = rows.find((a) => same(a.UserID, this.user.ID) || (personId && same(a.PersonID, personId)));
        if (!mine) throw new Error('You are not invited to this meeting.');
        await this.respond(mine.ID, response);
    }

    async invite(meetingId: string, invite: { personId: string | null; email: string | null; displayName: string | null; role: 'Required' | 'Optional' }): Promise<void> {
        MeetingData.forgetDetails();
        await new MeetingService(Metadata.Provider).addAttendee(meetingId, invite, this.user);
    }

    async removeAttendee(attendeeId: string): Promise<void> {
        MeetingData.forgetDetails();
        const row = await this.md.GetEntityObject<mjBizAppsTasksMeetingAttendeeEntity>(MEETING_ATTENDEE_ENTITY, this.user);
        if (!(await row.Load(attendeeId))) return;
        if (!(await row.Delete())) throw new Error(entityFailure(row));
    }

    async markAttendance(attendeeId: string, attendance: AttendeeModel['attendanceStatus']): Promise<void> {
        MeetingData.forgetDetails();
        const row = await this.md.GetEntityObject<mjBizAppsTasksMeetingAttendeeEntity>(MEETING_ATTENDEE_ENTITY, this.user);
        if (!(await row.Load(attendeeId))) throw new Error('The attendee was not found.');
        row.AttendanceStatus = attendance;
        if (attendance === 'Present' || attendance === 'Late') row.JoinedAt = row.JoinedAt ?? new Date();
        if (attendance === 'LeftEarly') row.LeftAt = new Date();
        if (!(await row.Save())) throw new Error(entityFailure(row));
    }

    async saveAgendaItem(meetingId: string, draft: AgendaItemDraft, agenda: AgendaItemModel[]): Promise<void> {
        MeetingData.forgetDetails();
        const item = await this.md.GetEntityObject<mjBizAppsTasksMeetingAgendaItemEntity>(MEETING_AGENDA_ITEM_ENTITY, this.user);
        if (draft.id) {
            if (!(await item.Load(draft.id))) throw new Error('The agenda item was not found.');
        } else {
            item.NewRecord();
            item.MeetingID = meetingId;
            item.Status = 'Planned';
            const siblings = agenda.filter((a) => (a.parentId ?? '').toLowerCase() === (draft.parentId ?? '').toLowerCase());
            item.Sequence = siblings.reduce((max, a) => Math.max(max, a.sequence), 0) + 100;
        }
        item.ParentID = draft.parentId;
        item.Name = draft.name;
        item.Description = draft.description || null;
        item.TypeID = draft.typeId;
        item.PresenterPersonID = draft.presenterPersonId;
        item.DurationMinutes = draft.durationMinutes;
        if (!(await item.Save())) throw new Error(entityFailure(item));
    }

    async removeAgendaItem(itemId: string): Promise<void> {
        MeetingData.forgetDetails();
        const item = await this.md.GetEntityObject<mjBizAppsTasksMeetingAgendaItemEntity>(MEETING_AGENDA_ITEM_ENTITY, this.user);
        if (!(await item.Load(itemId))) return;
        if (!(await item.Delete())) throw new Error(entityFailure(item));
    }

    reorderAgenda(meetingId: string, orderedIds: string[]): Promise<void> {
        MeetingData.forgetDetails();
        return new MeetingAgendaService(Metadata.Provider).reorder(meetingId, orderedIds, this.user);
    }

    async moveAgendaItem(itemId: string, parentId: string | null, agenda: AgendaItemModel[]): Promise<void> {
        MeetingData.forgetDetails();
        const item = await this.md.GetEntityObject<mjBizAppsTasksMeetingAgendaItemEntity>(MEETING_AGENDA_ITEM_ENTITY, this.user);
        if (!(await item.Load(itemId))) throw new Error('The agenda item was not found.');
        const siblings = agenda.filter((a) => (a.parentId ?? '').toLowerCase() === (parentId ?? '').toLowerCase() && !same(a.id, itemId));
        item.ParentID = parentId;
        item.Sequence = siblings.reduce((max, a) => Math.max(max, a.sequence), 0) + 100;
        if (!(await item.Save())) throw new Error(entityFailure(item));
    }

    async applyTemplate(meetingId: string, typeId: string): Promise<void> {
        MeetingData.forgetDetails();
        const [type] = await this.rows<{ AgendaTemplate: string | null }>(MEETING_TYPE_ENTITY, `ID = '${typeId}'`, ['AgendaTemplate'], '', 1);
        const template = parseAgendaTemplate(type?.AgendaTemplate);
        if (!template) throw new Error('The type has no agenda template.');
        await new MeetingAgendaService(Metadata.Provider).applyTemplate(meetingId, template, this.user);
    }

    async setAgendaItemStatus(itemId: string, status: AgendaItemModel['status'], outcome?: string | null): Promise<void> {
        MeetingData.forgetDetails();
        const item = await this.md.GetEntityObject<mjBizAppsTasksMeetingAgendaItemEntity>(MEETING_AGENDA_ITEM_ENTITY, this.user);
        if (!(await item.Load(itemId))) throw new Error('The agenda item was not found.');
        item.Status = status;
        if (status === 'InProgress' && !item.StartedAt) item.StartedAt = new Date();
        if ((status === 'Done' || status === 'Skipped' || status === 'Deferred') && !item.EndedAt) item.EndedAt = new Date();
        if (outcome !== undefined) item.Outcome = outcome;
        if (!(await item.Save())) throw new Error(entityFailure(item));
    }

    async saveNote(meetingId: string, draft: NoteDraft): Promise<void> {
        MeetingData.forgetDetails();
        const personId = await this.currentPersonId();
        const note = await this.md.GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(MEETING_NOTE_ENTITY, this.user);
        if (draft.id) {
            if (!(await note.Load(draft.id))) throw new Error('The note was not found.');
        } else {
            note.NewRecord();
            note.MeetingID = meetingId;
            note.Source = 'Manual';
            note.AuthorPersonID = personId;
        }
        note.AgendaItemID = draft.agendaItemId;
        note.Kind = draft.kind;
        note.Title = draft.title || null;
        note.Body = draft.body;
        note.Status = draft.status;
        if (!(await note.Save())) throw new Error(entityFailure(note));
    }

    async deleteNote(noteId: string): Promise<void> {
        MeetingData.forgetDetails();
        const note = await this.md.GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(MEETING_NOTE_ENTITY, this.user);
        if (!(await note.Load(noteId))) return;
        if (!(await note.Delete())) throw new Error(entityFailure(note));
    }

    /** A follow-up: an ACTION_ITEM task, assigned when asked, linked to the meeting or the agenda item. */
    async addFollowUp(meetingId: string, draft: FollowUpDraft): Promise<string> {
        MeetingData.forgetDetails();
        const personId = await this.currentPersonId();
        const [type] = await this.rows<{ ID: string }>(TASK_TYPES_ENTITY, `Code = '${ACTION_ITEM_CODE}'`, ['ID'], '', 1);
        if (!type) throw new Error('The Action Item task type is not installed.');
        const task = await this.md.GetEntityObject<TaskEntity>(TASKS_ENTITY, this.user);
        task.NewRecord();
        task.Name = draft.name;
        task.TypeID = type.ID;
        task.Status = 'Open';
        task.Priority = 'Medium';
        task.PercentComplete = 0;
        task.DueAt = draft.dueAt;
        task.CreatedByPersonID = personId;
        if (!(await task.Save())) throw new Error(entityFailure(task));
        const target = draft.agendaItemId ? { entity: MEETING_AGENDA_ITEM_ENTITY, id: draft.agendaItemId } : { entity: MEETING_ENTITY, id: meetingId };
        const entityInfo = this.md.EntityByName(target.entity);
        if (entityInfo) {
            const link = await this.md.GetEntityObject<mjBizAppsTasksTaskLinkEntity>(TASK_LINKS_ENTITY, this.user);
            link.NewRecord();
            link.TaskID = task.ID;
            link.EntityID = entityInfo.ID;
            link.RecordID = target.id;
            link.Description = 'Follow-up from the meeting';
            if (!(await link.Save())) throw new Error(entityFailure(link));
        }
        if (draft.assigneePersonId) {
            const people = this.md.EntityByName(PEOPLE_ENTITY);
            if (people) await new TaskAssignmentService().assignToTask({ taskID: task.ID, assigneeEntityID: people.ID, assigneeRecordID: draft.assigneePersonId, assignedByPersonID: personId ?? undefined }, this.user);
        }
        return task.ID;
    }

    async removeLink(linkId: string): Promise<void> {
        MeetingData.forgetDetails();
        const link = await this.md.GetEntityObject<mjBizAppsTasksMeetingLinkEntity>(MEETING_LINK_ENTITY, this.user);
        if (!(await link.Load(linkId))) return;
        if (!(await link.Delete())) throw new Error(entityFailure(link));
    }

    async calendarFile(meetingId: string, method: 'REQUEST' | 'CANCEL'): Promise<{ fileName: string; content: string }> {
        return new MeetingCalendarFile(Metadata.Provider).forMeeting(meetingId, method, this.user, { url: window.location.href });
    }

    async saveSeries(draft: SeriesDraft): Promise<mjBizAppsTasksMeetingSeriesEntity> {
        MeetingData.forgetDetails();
        const personId = draft.organizerPersonId ?? (await this.currentPersonId());
        if (!personId) throw new Error('Your user account is not linked to a Person, so you cannot organize a series.');
        const series = await this.md.GetEntityObject<mjBizAppsTasksMeetingSeriesEntity>(MEETING_SERIES_ENTITY, this.user);
        if (draft.id) {
            if (!(await series.Load(draft.id))) throw new Error('The series was not found.');
        } else {
            series.NewRecord();
            series.Status = 'Active';
            series.CreatedByPersonID = personId;
        }
        series.Name = draft.name;
        series.Description = draft.description || null;
        series.TypeID = draft.typeId;
        series.OrganizerPersonID = personId;
        series.RecurrenceRule = draft.recurrenceRule;
        series.TimeZone = draft.timeZone;
        series.FirstStartsAt = draft.firstStartsAt;
        series.DurationMinutes = draft.durationMinutes;
        series.LocationType = draft.locationType;
        series.Location = draft.location || null;
        series.VideoProviderID = draft.videoProviderId;
        series.Visibility = draft.visibility;
        if (!(await series.Save())) throw new Error(entityFailure(series));
        return series;
    }

    /** The error's text for a callout. */
    static message(error: unknown): string {
        return error instanceof Error ? error.message : String(error);
    }
}

/** Hands the browser a file to save: the `.ics`. */
export function downloadTextFile(fileName: string, content: string, mimeType = 'text/calendar'): void {
    const blob = new Blob([content], { type: `${mimeType};charset=utf-8` });
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement('a');
    anchor.href = url;
    anchor.download = fileName;
    document.body.appendChild(anchor);
    anchor.click();
    anchor.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
}

export function quoteSql(value: string): string {
    return quote(value);
}
