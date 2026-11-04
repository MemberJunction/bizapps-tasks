import { BaseEntity, LogError, RunView, ValidationErrorInfo, ValidationErrorType, type EntitySaveOptions, type IMetadataProvider, type ValidationResult } from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { mjBizAppsTasksMeetingAttendeeEntity, mjBizAppsTasksMeetingEntity, mjBizAppsTasksMeetingSeriesEntity, mjBizAppsTasksVideoProviderEntity } from '@mj-biz-apps/tasks-entities';
import {
    MEETING_ATTENDEE_ENTITY,
    MEETING_ENTITY,
    MEETING_SERIES_ENTITY,
    VIDEO_PROVIDER_ENTITY,
    callerAdministersMeetings,
    callerIsOrganizer,
    isMeetingStatus,
    isOrganizerOnlyMove,
    isValidTimeZone,
    meetingStatusMoveRefusal,
    meetingTimeProblem,
    personIdForUser,
    type MeetingStatus,
} from '@mj-biz-apps/tasks-core';
import { BusinessTimeZoneEngine } from '@mj-biz-apps/common-entities';
import { runAfterCommit } from './after-commit.js';
import { callerOwnsMeeting, meetingCaller } from './meeting-caller.js';
import { resolveVideoProviderDriver, type VideoMeetingInput, type VideoProviderBase } from './video/VideoProviderBase.js';

const fail = (result: ValidationResult, field: string, message: string): ValidationResult => {
    result.Success = false;
    result.Errors.push(new ValidationErrorInfo(field, message, null, ValidationErrorType.Failure));
    return result;
};

/**
 * The rules a meeting keeps whoever saves it (the meetings plan, § 3): its times and zone; its status moving forward,
 * with starting, ending and cancelling the organizer's (or an administrator's); the stamps those moves leave;
 * its organizer's attendee row, kept in step with OrganizerPersonID; and, after the commit, the video provider told of
 * a cancellation.
 */
@RegisterClass(BaseEntity, MEETING_ENTITY)
export class MeetingEntityServer extends mjBizAppsTasksMeetingEntity {
    private get metadataProvider(): IMetadataProvider {
        return this.ProviderToUse as unknown as IMetadataProvider;
    }

    private get statusBefore(): MeetingStatus | null {
        if (!this.IsSaved) return null;
        const field = this.Fields.find((f) => f.CodeName === 'Status');
        const old = field?.Dirty ? field.OldValue : this.Status;
        return typeof old === 'string' && isMeetingStatus(old) ? old : null;
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        const timeProblem = meetingTimeProblem(this.StartsAt, this.EndsAt, this.TimeZone);
        if (timeProblem) return fail(result, timeProblem.includes('zone') ? 'TimeZone' : 'EndsAt', timeProblem);
        if ((this.SeriesID == null) !== (this.OccurrenceStartsAt == null)) {
            return fail(result, 'OccurrenceStartsAt', 'An occurrence of a series names its series and its slot together; a meeting of its own has neither.');
        }
        const before = this.statusBefore;
        if (before && before !== this.Status) {
            const refusal = meetingStatusMoveRefusal(before, this.Status);
            if (refusal) return fail(result, 'Status', refusal);
            if (isOrganizerOnlyMove(before, this.Status) && !(await this.callerMayRun())) {
                const verb = this.Status === 'InProgress' ? 'starts' : this.Status === 'Completed' ? 'ends' : 'cancels';
                return fail(result, 'Status', `Only the organizer ${verb} a meeting.`);
            }
        }
        // The meeting itself is the organizer's to make and change (§ 3), over the API as in the app
        const caller = await meetingCaller(this.metadataProvider, this.ContextCurrentUser);
        if (!caller.administers) {
            if (!this.IsSaved) {
                if (!callerOwnsMeeting(caller, this.OrganizerPersonID)) return fail(result, 'OrganizerPersonID', 'A meeting is organized by the person who schedules it.');
            } else if (!callerOwnsMeeting(caller, this.organizerBefore)) {
                return fail(result, 'OrganizerPersonID', 'Only the organizer changes a meeting.');
            }
        }
        // An occurrence joins a series only at its organizer's hand: nobody slips a meeting of their own into someone else's series
        const seriesField = this.Fields.find((f) => f.CodeName === 'SeriesID');
        if (this.SeriesID && (!this.IsSaved || seriesField?.Dirty)) {
            const series = await this.metadataProvider.GetEntityObject<mjBizAppsTasksMeetingSeriesEntity>(MEETING_SERIES_ENTITY, this.ContextCurrentUser);
            if (!(await series.Load(this.SeriesID))) return fail(result, 'SeriesID', 'The series was not found, or you may not see it.');
            if (!callerOwnsMeeting(caller, series.OrganizerPersonID)) return fail(result, 'SeriesID', 'Only the organizer of a series adds a meeting to it.');
        }
        return result;
    }

    /** The organizer the database holds, before this save changed it. */
    private get organizerBefore(): string {
        const field = this.Fields.find((f) => f.CodeName === 'OrganizerPersonID');
        return field?.Dirty ? String(field.OldValue ?? '') : this.OrganizerPersonID;
    }

    private static readonly callerProvidedVideoMeetingIds = new Set<string>();

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        const isNew = !this.IsSaved;
        const before = this.statusBefore;
        const maintainedBySync = Boolean(
            (this as { MaintainedByVideoSync?: boolean; MaintainedByCalendarSync?: boolean }).MaintainedByVideoSync ||
                (this as { MaintainedByVideoSync?: boolean; MaintainedByCalendarSync?: boolean }).MaintainedByCalendarSync,
        );
        if (!maintainedBySync && this.ID && this.VideoMeetingID) {
            MeetingEntityServer.callerProvidedVideoMeetingIds.add(this.ID.toLowerCase());
        }
        await this.stampDefaults(isNew);
        // A refused save leaves no stamp behind: the base class validates again inside Save and reports the refusal
        if ((await this.ValidateAsync()).Success) this.stampStatusTimes(before);
        const cancelling = this.Status === 'Cancelled' && before !== 'Cancelled';
        const videoMeetingId = this.VideoMeetingID;
        const videoProviderId = this.VideoProviderID;
        const videoDetailsChanged = !isNew && this.hasVideoDetailsDirty();

        if (maintainedBySync && this.ID && MeetingEntityServer.callerProvidedVideoMeetingIds.has(this.ID.toLowerCase())) {
            return true;
        }
        if (!(await super.Save(options))) return false;

        try {
            await this.ensureOrganizerAttendee();
        } catch (error) {
            LogError(`MeetingEntityServer: the organizer's attendee row of meeting ${this.ID} was not kept in step: ${error instanceof Error ? error.message : String(error)}`);
        }
        if (cancelling && videoProviderId && videoMeetingId) {
            runAfterCommit(this.ProviderToUse, `cancel video meeting ${videoMeetingId}`, () => this.deleteVideoMeeting(videoProviderId, videoMeetingId));
        } else if (!cancelling && this.Status !== 'Draft' && videoProviderId && !videoMeetingId && !maintainedBySync) {
            const meetingId = this.ID;
            runAfterCommit(this.ProviderToUse, `provision video meeting for ${meetingId}`, () => this.provisionVideoMeeting(meetingId, videoProviderId));
        } else if (!cancelling && !isNew && videoProviderId && videoMeetingId && videoDetailsChanged && !maintainedBySync) {
            const snapshot = this.videoInputSnapshot();
            runAfterCommit(this.ProviderToUse, `update video meeting ${videoMeetingId}`, () => this.updateVideoMeeting(videoProviderId, videoMeetingId, snapshot));
        }
        if (!maintainedBySync && this.Status !== 'Draft' && this.metadataProvider.Applications?.length) {
            const meetingId = this.ID;
            runAfterCommit(this.ProviderToUse, `sync calendar event for meeting ${meetingId}`, async () => {
                const { TasksSettings } = await import('./TasksSettings.js');
                if (!TasksSettings.DefaultCalendarProviderName(this.metadataProvider)) return;
                const { MeetingCalendarSyncService } = await import('./calendar/MeetingCalendarSyncService.js');
                await new MeetingCalendarSyncService(this.metadataProvider).syncMeeting(meetingId, this.ContextCurrentUser);
            });
        }
        return true;
    }

    private hasVideoDetailsDirty(): boolean {
        const watched = new Set(['Name', 'StartsAt', 'EndsAt', 'TimeZone', 'Description']);
        return this.Fields.some((f) => watched.has(f.CodeName) && f.Dirty);
    }

    private videoInputSnapshot(): VideoMeetingInput {
        return {
            Title: this.Name,
            StartsAt: this.StartsAt,
            EndsAt: this.EndsAt,
            TimeZone: this.TimeZone || 'UTC',
            Description: this.Description,
        };
    }

    /** Whether the caller is the organizer, or someone who may change every meeting. */
    private async callerMayRun(): Promise<boolean> {
        const user = this.ContextCurrentUser;
        if (!user) return false;
        if (callerAdministersMeetings(this.metadataProvider, user)) return true;
        const personId = await personIdForUser(this.metadataProvider, user);
        return callerIsOrganizer(personId, this.OrganizerPersonID);
    }

    /** A new meeting's zone defaults from the business time zone when none was given. */
    private async stampDefaults(isNew: boolean): Promise<void> {
        if (!isNew) return;
        if (!this.TimeZone || !isValidTimeZone(this.TimeZone)) this.TimeZone = await this.defaultTimeZone();
    }

    private async defaultTimeZone(): Promise<string> {
        try {
            const engine = BusinessTimeZoneEngine.Instance;
            await engine.Config(false, this.ContextCurrentUser, this.metadataProvider);
            return isValidTimeZone(engine.Zone) ? engine.Zone : 'UTC';
        } catch (error) {
            LogError(`MeetingEntityServer: the business time zone could not be read, using UTC: ${error instanceof Error ? error.message : String(error)}`);
            return 'UTC';
        }
    }

    /** The moves leave their marks: started, ended, cancelled. */
    private stampStatusTimes(before: MeetingStatus | null): void {
        if (before === this.Status) return;
        const now = new Date();
        if (this.Status === 'InProgress' && !this.ActualStartedAt) this.ActualStartedAt = now;
        if (this.Status === 'Completed' && !this.ActualEndedAt) this.ActualEndedAt = now;
        if (this.Status === 'Cancelled' && !this.CancelledAt) this.CancelledAt = now;
    }

    /**
     * The organizer's attendee row, kept in step with OrganizerPersonID: made when missing; when the organizer changed,
     * the old organizer's row becomes a Required attendee and the new organizer's row (their existing one, promoted, or
     * a new one) is the Organizer row, so the database's one-row-per-person index is never crossed. These saves are the
     * server's own, marked so.
     */
    private async ensureOrganizerAttendee(): Promise<void> {
        const user = this.ContextCurrentUser;
        const rows = await RunView.FromMetadataProvider(this.metadataProvider).RunView<mjBizAppsTasksMeetingAttendeeEntity>(
            { EntityName: MEETING_ATTENDEE_ENTITY, ExtraFilter: `MeetingID = '${this.ID}'`, ResultType: 'entity_object', MaxRows: 1000 },
            user,
        );
        if (!rows.Success) throw new Error(rows.ErrorMessage);
        const organizerId = this.OrganizerPersonID.toLowerCase();
        const organizerRow = rows.Results.find((row) => row.Role === 'Organizer') ?? null;
        const newOrganizerRow = rows.Results.find((row) => (row.PersonID ?? '').toLowerCase() === organizerId) ?? null;
        if (organizerRow && (organizerRow.PersonID ?? '').toLowerCase() === organizerId) return;

        if (organizerRow) {
            // The old organizer stays on the meeting as an ordinary attendee; the new organizer gets a row of their own
            this.maintain(organizerRow);
            organizerRow.Role = 'Required';
            if (!(await organizerRow.Save())) throw new Error(organizerRow.LatestResult?.Message ?? 'the former organizer\'s row was not updated');
        }
        if (newOrganizerRow) {
            this.maintain(newOrganizerRow);
            newOrganizerRow.Role = 'Organizer';
            newOrganizerRow.ResponseStatus = 'Accepted';
            if (!newOrganizerRow.RespondedAt) newOrganizerRow.RespondedAt = new Date();
            if (!(await newOrganizerRow.Save())) throw new Error(newOrganizerRow.LatestResult?.Message ?? 'the organizer row was not promoted');
            return;
        }
        const row = await this.metadataProvider.GetEntityObject<mjBizAppsTasksMeetingAttendeeEntity>(MEETING_ATTENDEE_ENTITY, user);
        this.maintain(row);
        row.NewRecord();
        row.MeetingID = this.ID;
        row.PersonID = this.OrganizerPersonID;
        row.Role = 'Organizer';
        row.ResponseStatus = 'Accepted';
        row.RespondedAt = new Date();
        row.AttendanceStatus = 'Unknown';
        if (!(await row.Save())) throw new Error(row.LatestResult?.Message ?? 'the organizer row was not made');
    }

    /** Marks an attendee row as the meeting server's own save, so the attendee server's caller gate lets it through. */
    private maintain(row: mjBizAppsTasksMeetingAttendeeEntity): void {
        (row as mjBizAppsTasksMeetingAttendeeEntity & { MaintainedByMeetingServer?: boolean }).MaintainedByMeetingServer = true;
    }

    /** After the commit: provisions a new video meeting and stamps `VideoJoinURL`, `VideoMeetingID`, and `DialInDetails`. */
    private async provisionVideoMeeting(meetingId: string, videoProviderId: string): Promise<void> {
        const key = meetingId.toLowerCase();
        if (MeetingEntityServer.callerProvidedVideoMeetingIds.has(key)) return;
        const ready = await this.loadConfiguredDriver(videoProviderId, `provision for meeting ${meetingId}`);
        if (!ready || MeetingEntityServer.callerProvidedVideoMeetingIds.has(key)) return;
        const user = this.ContextCurrentUser;
        const meeting = await this.metadataProvider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, user);
        if (!(await meeting.Load(meetingId))) return;
        if (meeting.VideoMeetingID || meeting.Status === 'Cancelled' || MeetingEntityServer.callerProvidedVideoMeetingIds.has(key)) return;
        const created = await ready.driver.CreateMeeting(
            {
                Title: meeting.Name,
                StartsAt: meeting.StartsAt,
                EndsAt: meeting.EndsAt,
                TimeZone: meeting.TimeZone || 'UTC',
                Description: meeting.Description,
            },
            user,
        );
        if (MeetingEntityServer.callerProvidedVideoMeetingIds.has(key)) return;
        (meeting as mjBizAppsTasksMeetingEntity & { MaintainedByVideoSync?: boolean }).MaintainedByVideoSync = true;
        meeting.VideoJoinURL = created.JoinURL;
        meeting.VideoMeetingID = created.ProviderMeetingID;
        if (created.DialInDetails !== undefined) {
            meeting.DialInDetails = created.DialInDetails;
        }
        if (!(await meeting.Save())) {
            LogError(`MeetingEntityServer: video meeting ${created.ProviderMeetingID} was created for meeting ${meetingId}, but saving VideoJoinURL failed: ${meeting.LatestResult?.Message ?? 'unknown error'}`);
        }
    }

    /** After the commit: updates the provider's copy when a meeting moves or is renamed. */
    private async updateVideoMeeting(videoProviderId: string, videoMeetingId: string, input: VideoMeetingInput): Promise<void> {
        const ready = await this.loadConfiguredDriver(videoProviderId, `update video meeting ${videoMeetingId}`);
        if (!ready) return;
        await ready.driver.UpdateMeeting(videoMeetingId, input, this.ContextCurrentUser);
    }

    /** After the commit: the provider's copy of a cancelled meeting goes. Best effort, logged. */
    private async deleteVideoMeeting(videoProviderId: string, videoMeetingId: string): Promise<void> {
        const ready = await this.loadConfiguredDriver(videoProviderId, `delete video meeting ${videoMeetingId}`);
        if (!ready) return;
        await ready.driver.DeleteMeeting(videoMeetingId, this.ContextCurrentUser);
    }

    private async loadConfiguredDriver(
        videoProviderId: string,
        actionLabel: string,
    ): Promise<{ provider: mjBizAppsTasksVideoProviderEntity; driver: VideoProviderBase } | null> {
        const user = this.ContextCurrentUser;
        const provider = await this.metadataProvider.GetEntityObject<mjBizAppsTasksVideoProviderEntity>(VIDEO_PROVIDER_ENTITY, user);
        if (!(await provider.Load(videoProviderId))) return null;
        if (!provider.DriverClass) return null;
        const driver = resolveVideoProviderDriver(provider.DriverClass);
        if (!driver) return null;
        await driver.Initialize({ ProviderID: provider.ID, CredentialID: provider.CredentialID, Configuration: provider.Configuration }, user);
        if (!driver.IsConfigured) {
            LogError(`Video provider '${provider.Name}' is not configured; could not ${actionLabel}.`);
            return null;
        }
        return { provider, driver };
    }
}
