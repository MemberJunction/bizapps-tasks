import { Metadata, RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import type {
    mjBizAppsTasksMeetingAttendeeEntity,
    mjBizAppsTasksMeetingEntity,
    mjBizAppsTasksMeetingLinkEntity,
    mjBizAppsTasksMeetingSeriesAttendeeEntity,
    mjBizAppsTasksMeetingSeriesEntity,
} from '@mj-biz-apps/tasks-entities';
import { MEETING_ATTENDEE_ENTITY, MEETING_ENTITY, MEETING_LINK_ENTITY, MEETING_SERIES_ATTENDEE_ENTITY, MEETING_SERIES_ENTITY, entityFailure } from '../meetings/entity-names.js';
import { expandOccurrences, seriesHasEnded } from '../meetings/recurrence.js';

export interface MaterializeOptions {
    /** How far ahead occurrences are made. Default 90 days. */
    horizonDays?: number;
    /** "Now", for tests. Default the clock. */
    now?: Date;
}

export interface MaterializeResult {
    seriesId: string;
    created: number;
    updated: number;
    cancelled: number;
    through: Date | null;
    ended: boolean;
}

export const DEFAULT_HORIZON_DAYS = 90;

type OccurrenceRow = Pick<mjBizAppsTasksMeetingEntity, 'ID' | 'OccurrenceStartsAt' | 'StartsAt' | 'Status'>;

const sameInstant = (a: Date | null | undefined, b: Date | null | undefined): boolean => !!a && !!b && a.getTime() === b.getTime();

/**
 * A series' occurrences (the meetings plan, § 3): real Meeting rows made ahead of time up to a horizon, each named by
 * its slot. Saving or changing a series calls this: a slot with no meeting gets one; a meeting that has not started and
 * was not moved or cancelled on its own takes the series' current values; one that was moved, started or cancelled is
 * left alone; and a future meeting whose slot the rule no longer produces is cancelled, unless it was changed on its own.
 */
/** The materialization in flight per series, so two saves close together run one after the other, never over each other. */
const inFlight = new Map<string, Promise<MaterializeResult>>();

export class MeetingSeriesService {
    constructor(private readonly provider: IMetadataProvider = Metadata.Provider) {}

    async materialize(seriesId: string, contextUser: UserInfo, options: MaterializeOptions = {}): Promise<MaterializeResult> {
        const key = seriesId.toLowerCase();
        const previous = inFlight.get(key) ?? Promise.resolve(null);
        const run = previous.then(
            () => this.materializeNow(seriesId, contextUser, options),
            () => this.materializeNow(seriesId, contextUser, options),
        );
        inFlight.set(key, run);
        try {
            return await run;
        } finally {
            if (inFlight.get(key) === run) inFlight.delete(key);
        }
    }

    private async materializeNow(seriesId: string, contextUser: UserInfo, options: MaterializeOptions): Promise<MaterializeResult> {
        const series = await this.provider.GetEntityObject<mjBizAppsTasksMeetingSeriesEntity>(MEETING_SERIES_ENTITY, contextUser);
        if (!(await series.Load(seriesId))) throw new Error(`Series ${seriesId} was not found.`);
        const result: MaterializeResult = { seriesId: series.ID, created: 0, updated: 0, cancelled: 0, through: null, ended: false };
        if (series.Status !== 'Active') return result;

        const now = options.now ?? new Date();
        const through = new Date(now.getTime() + (options.horizonDays ?? DEFAULT_HORIZON_DAYS) * 86400000);
        const recurrence = { rule: series.RecurrenceRule, timeZone: series.TimeZone, firstStartsAt: series.FirstStartsAt, durationMinutes: series.DurationMinutes };
        const slots = expandOccurrences(recurrence, { from: now, through });
        const existing = await this.futureOccurrences(series.ID, now, contextUser);
        const bySlot = new Map(existing.map((row) => [row.OccurrenceStartsAt?.getTime() ?? 0, row]));
        const attendees = await this.seriesAttendees(series.ID, contextUser);
        const links = await this.seriesLinks(series.ID, contextUser);

        for (const slot of slots) {
            const found = bySlot.get(slot.occurrenceStartsAt.getTime());
            if (!found) {
                if (await this.createOccurrence(series, slot, attendees, links, contextUser)) result.created += 1;
                continue;
            }
            if (this.isUntouched(found)) {
                const meeting = await this.provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, contextUser);
                if (await meeting.Load(found.ID)) {
                    this.copySeriesValues(series, meeting, slot.startsAt, slot.endsAt);
                    let changed = false;
                    if (meeting.Dirty) {
                        if (!(await meeting.Save())) throw new Error(`Occurrence ${meeting.ID} was not updated: ${entityFailure(meeting)}`);
                        changed = true;
                    }
                    if (await this.ensureAttendees(meeting.ID, attendees, contextUser)) changed = true;
                    if (await this.ensureLinks(meeting.ID, links, contextUser)) changed = true;
                    if (changed) result.updated += 1;
                }
            }
        }
        // A future slot the rule no longer produces: cancelled when the meeting was never changed on its own
        const produced = new Set(slots.map((slot) => slot.occurrenceStartsAt.getTime()));
        for (const row of existing) {
            const slotTime = row.OccurrenceStartsAt?.getTime() ?? 0;
            if (produced.has(slotTime) || slotTime > through.getTime() || !this.isUntouched(row)) continue;
            const meeting = await this.provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, contextUser);
            if (await meeting.Load(row.ID)) {
                meeting.Status = 'Cancelled';
                meeting.CancellationReason = 'The series changed and no longer meets then.';
                if (!(await meeting.Save())) throw new Error(`Occurrence ${meeting.ID} was not cancelled: ${entityFailure(meeting)}`);
                result.cancelled += 1;
            }
        }

        series.MaterializedThrough = through;
        result.through = through;
        if (seriesHasEnded(recurrence, now) && slots.length === 0) {
            series.Status = 'Ended';
            result.ended = true;
        }
        if (series.Dirty && !(await series.Save())) throw new Error(`The series was not updated: ${entityFailure(series)}`);
        return result;
    }

    /** The series' meetings whose slot is at or after the instant. */
    async futureOccurrences(seriesId: string, from: Date, contextUser: UserInfo): Promise<OccurrenceRow[]> {
        const res = await RunView.FromMetadataProvider(this.provider).RunView<OccurrenceRow>(
            {
                EntityName: MEETING_ENTITY,
                ExtraFilter: `SeriesID = '${seriesId}' AND OccurrenceStartsAt >= '${from.toISOString()}'`,
                Fields: ['ID', 'OccurrenceStartsAt', 'StartsAt', 'Status'],
                ResultType: 'simple',
                MaxRows: 2000,
            },
            contextUser,
        );
        if (!res.Success) throw new Error(`The series' occurrences could not be read: ${res.ErrorMessage}`);
        return res.Results.map((row) => ({
            ...row,
            OccurrenceStartsAt: row.OccurrenceStartsAt ? new Date(row.OccurrenceStartsAt) : null,
            StartsAt: new Date(row.StartsAt),
        }));
    }

    async seriesAttendees(seriesId: string, contextUser: UserInfo): Promise<mjBizAppsTasksMeetingSeriesAttendeeEntity[]> {
        const res = await RunView.FromMetadataProvider(this.provider).RunView<mjBizAppsTasksMeetingSeriesAttendeeEntity>(
            { EntityName: MEETING_SERIES_ATTENDEE_ENTITY, ExtraFilter: `SeriesID = '${seriesId}'`, ResultType: 'entity_object', MaxRows: 1000 },
            contextUser,
        );
        if (!res.Success) throw new Error(`The series' attendees could not be read: ${res.ErrorMessage}`);
        return res.Results;
    }

    async seriesLinks(seriesId: string, contextUser: UserInfo): Promise<mjBizAppsTasksMeetingLinkEntity[]> {
        const res = await RunView.FromMetadataProvider(this.provider).RunView<mjBizAppsTasksMeetingLinkEntity>(
            { EntityName: MEETING_LINK_ENTITY, ExtraFilter: `SeriesID = '${seriesId}'`, ResultType: 'entity_object', MaxRows: 1000 },
            contextUser,
        );
        if (!res.Success) throw new Error(`The series' links could not be read: ${res.ErrorMessage}`);
        return res.Results;
    }

    /** A meeting that still sits in its slot, scheduled and unstarted: the series may change it. */
    private isUntouched(row: OccurrenceRow): boolean {
        return row.Status === 'Scheduled' && sameInstant(row.StartsAt, row.OccurrenceStartsAt);
    }

    private copySeriesValues(series: mjBizAppsTasksMeetingSeriesEntity, meeting: mjBizAppsTasksMeetingEntity, startsAt: Date, endsAt: Date): void {
        meeting.Name = series.Name;
        meeting.Description = series.Description;
        meeting.TypeID = series.TypeID;
        meeting.OrganizerPersonID = series.OrganizerPersonID;
        meeting.TimeZone = series.TimeZone;
        meeting.LocationType = series.LocationType;
        meeting.Location = series.Location;
        meeting.VideoProviderID = series.VideoProviderID;
        meeting.Visibility = series.Visibility;
        if (!sameInstant(meeting.StartsAt, startsAt)) meeting.StartsAt = startsAt;
        if (!sameInstant(meeting.EndsAt, endsAt)) meeting.EndsAt = endsAt;
    }

    private async createOccurrence(
        series: mjBizAppsTasksMeetingSeriesEntity,
        slot: { occurrenceStartsAt: Date; startsAt: Date; endsAt: Date },
        attendees: readonly mjBizAppsTasksMeetingSeriesAttendeeEntity[],
        links: readonly mjBizAppsTasksMeetingLinkEntity[],
        contextUser: UserInfo,
    ): Promise<boolean> {
        const meeting = await this.provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, contextUser);
        meeting.NewRecord();
        meeting.SeriesID = series.ID;
        meeting.OccurrenceStartsAt = slot.occurrenceStartsAt;
        meeting.Status = 'Scheduled';
        meeting.CreatedByPersonID = series.CreatedByPersonID;
        this.copySeriesValues(series, meeting, slot.startsAt, slot.endsAt);
        if (!(await meeting.Save())) {
            const message = entityFailure(meeting);
            if (message.includes('UX_Meeting_Series_Occurrence')) return false; // another run made this slot meanwhile
            throw new Error(`The occurrence at ${slot.startsAt.toISOString()} was not made: ${message}`);
        }
        await this.ensureAttendees(meeting.ID, attendees, contextUser);
        await this.ensureLinks(meeting.ID, links, contextUser);
        return true;
    }

    /** The series' attendees the occurrence lacks are invited; nobody is removed. True when any were added. */
    private async ensureAttendees(meetingId: string, attendees: readonly mjBizAppsTasksMeetingSeriesAttendeeEntity[], contextUser: UserInfo): Promise<boolean> {
        if (!attendees.length) return false;
        const existing = await RunView.FromMetadataProvider(this.provider).RunView<{ PersonID: string | null; Email: string | null }>(
            { EntityName: MEETING_ATTENDEE_ENTITY, ExtraFilter: `MeetingID = '${meetingId}'`, Fields: ['PersonID', 'Email'], ResultType: 'simple', MaxRows: 1000 },
            contextUser,
        );
        if (!existing.Success) throw new Error(`The occurrence's attendees could not be read: ${existing.ErrorMessage}`);
        const people = new Set(existing.Results.map((row) => (row.PersonID ?? '').toLowerCase()).filter(Boolean));
        const emails = new Set(existing.Results.map((row) => (row.Email ?? '').toLowerCase()).filter(Boolean));
        let added = false;
        for (const attendee of attendees) {
            const person = (attendee.PersonID ?? '').toLowerCase();
            const email = (attendee.Email ?? '').toLowerCase();
            if ((person && people.has(person)) || (!person && email && emails.has(email))) continue;
            const row = await this.provider.GetEntityObject<mjBizAppsTasksMeetingAttendeeEntity>(MEETING_ATTENDEE_ENTITY, contextUser);
            row.NewRecord();
            row.MeetingID = meetingId;
            row.PersonID = attendee.PersonID;
            row.UserID = attendee.UserID;
            row.Email = attendee.Email;
            row.DisplayName = attendee.DisplayName;
            row.Role = attendee.Role;
            row.ResponseStatus = 'None';
            row.AttendanceStatus = 'Unknown';
            if (!(await row.Save())) throw new Error(`An attendee of the occurrence was not saved: ${entityFailure(row)}`);
            added = true;
        }
        return added;
    }

    /** The series' links the occurrence lacks are copied; none is removed. True when any were added. */
    private async ensureLinks(meetingId: string, links: readonly mjBizAppsTasksMeetingLinkEntity[], contextUser: UserInfo): Promise<boolean> {
        if (!links.length) return false;
        const existing = await RunView.FromMetadataProvider(this.provider).RunView<{ EntityID: string; RecordID: string }>(
            { EntityName: MEETING_LINK_ENTITY, ExtraFilter: `MeetingID = '${meetingId}'`, Fields: ['EntityID', 'RecordID'], ResultType: 'simple', MaxRows: 1000 },
            contextUser,
        );
        if (!existing.Success) throw new Error(`The occurrence's links could not be read: ${existing.ErrorMessage}`);
        const have = new Set(existing.Results.map((row) => `${row.EntityID.toLowerCase()}|${row.RecordID.toLowerCase()}`));
        let added = false;
        for (const link of links) {
            if (have.has(`${link.EntityID.toLowerCase()}|${link.RecordID.toLowerCase()}`)) continue;
            const row = await this.provider.GetEntityObject<mjBizAppsTasksMeetingLinkEntity>(MEETING_LINK_ENTITY, contextUser);
            row.NewRecord();
            row.MeetingID = meetingId;
            row.SeriesID = null;
            row.EntityID = link.EntityID;
            row.RecordID = link.RecordID;
            row.Description = link.Description;
            if (!(await row.Save())) throw new Error(`A link of the occurrence was not saved: ${entityFailure(row)}`);
            added = true;
        }
        return added;
    }
}
