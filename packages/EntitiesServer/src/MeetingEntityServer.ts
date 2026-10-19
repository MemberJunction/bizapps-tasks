import { BaseEntity, LogError, RunView, ValidationErrorInfo, ValidationErrorType, type EntitySaveOptions, type IMetadataProvider, type ValidationResult } from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { mjBizAppsTasksMeetingAttendeeEntity, mjBizAppsTasksMeetingEntity, mjBizAppsTasksVideoProviderEntity } from '@mj-biz-apps/tasks-entities';
import {
    MEETING_ATTENDEE_ENTITY,
    MEETING_ENTITY,
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
import { resolveVideoProviderDriver } from './video/VideoProviderBase.js';

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
        return result;
    }

    /** The organizer the database holds, before this save changed it. */
    private get organizerBefore(): string {
        const field = this.Fields.find((f) => f.CodeName === 'OrganizerPersonID');
        return field?.Dirty ? String(field.OldValue ?? '') : this.OrganizerPersonID;
    }

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        const isNew = !this.IsSaved;
        const before = this.statusBefore;
        await this.stampDefaults(isNew);
        // A refused save leaves no stamp behind: the base class validates again inside Save and reports the refusal
        if ((await this.ValidateAsync()).Success) this.stampStatusTimes(before);
        const cancelling = this.Status === 'Cancelled' && before !== 'Cancelled';
        const videoMeetingId = this.VideoMeetingID;
        const videoProviderId = this.VideoProviderID;

        if (!(await super.Save(options))) return false;

        try {
            await this.ensureOrganizerAttendee();
        } catch (error) {
            LogError(`MeetingEntityServer: the organizer's attendee row of meeting ${this.ID} was not kept in step: ${error instanceof Error ? error.message : String(error)}`);
        }
        if (cancelling && videoProviderId && videoMeetingId) {
            runAfterCommit(this.ProviderToUse, `cancel video meeting ${videoMeetingId}`, () => this.deleteVideoMeeting(videoProviderId, videoMeetingId));
        }
        return true;
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
     * the new organizer's existing row is promoted and the old organizer's row becomes a Required attendee, so the
     * database's one-row-per-person index is never crossed. These saves are the server's own, marked so.
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
            // The old organizer stays on the meeting as an ordinary attendee
            this.maintain(organizerRow);
            if (newOrganizerRow) {
                organizerRow.Role = 'Required';
                if (!(await organizerRow.Save())) throw new Error(organizerRow.LatestResult?.Message ?? 'the former organizer\'s row was not updated');
            } else {
                organizerRow.PersonID = this.OrganizerPersonID;
                organizerRow.UserID = null; // the attendee server fills it from the new person
                organizerRow.Email = null;
                organizerRow.DisplayName = null;
                if (!(await organizerRow.Save())) throw new Error(organizerRow.LatestResult?.Message ?? 'the organizer row was not updated');
                return;
            }
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

    /** After the commit: the provider's copy of a cancelled meeting goes. Best effort, logged. */
    private async deleteVideoMeeting(videoProviderId: string, videoMeetingId: string): Promise<void> {
        const user = this.ContextCurrentUser;
        const provider = await this.metadataProvider.GetEntityObject<mjBizAppsTasksVideoProviderEntity>(VIDEO_PROVIDER_ENTITY, user);
        if (!(await provider.Load(videoProviderId))) return;
        const driver = resolveVideoProviderDriver(provider.DriverClass);
        if (!driver) return;
        await driver.Initialize({ ProviderID: provider.ID, CredentialID: provider.CredentialID, Configuration: provider.Configuration }, user);
        if (!driver.IsConfigured) {
            LogError(`Video provider '${provider.Name}' is not configured; meeting ${videoMeetingId} was not deleted there.`);
            return;
        }
        await driver.DeleteMeeting(videoMeetingId, user);
    }
}
