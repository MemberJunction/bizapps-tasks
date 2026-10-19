import { BaseEntity, ValidationErrorInfo, ValidationErrorType, type EntityDeleteOptions, type EntitySaveOptions, type IMetadataProvider, type ValidationResult } from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { mjBizAppsTasksMeetingAttendeeEntity, mjBizAppsTasksMeetingEntity, mjBizAppsTasksMeetingSeriesAttendeeEntity, mjBizAppsTasksMeetingSeriesEntity } from '@mj-biz-apps/tasks-entities';
import { MEETING_ATTENDEE_ENTITY, MEETING_ENTITY, MEETING_SERIES_ATTENDEE_ENTITY, MEETING_SERIES_ENTITY, userIdForPerson } from '@mj-biz-apps/tasks-core';
import { callerOwnsMeeting, meetingCaller } from './meeting-caller.js';

const fail = (result: ValidationResult, field: string, message: string): ValidationResult => {
    result.Success = false;
    result.Errors.push(new ValidationErrorInfo(field, message, null, ValidationErrorType.Failure));
    return result;
};

const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/** What an attendee changes on their own row: their answer and their attendance. The rest is the organizer's. */
const OWN_ROW_FIELDS = new Set(['ResponseStatus', 'RespondedAt', 'AttendanceStatus', 'JoinedAt', 'LeftAt', 'Notes']);

/** An attendee is a person or an address (the meetings plan, § 3); the address is kept tidy. */
function personOrEmailProblem(personId: string | null, email: string | null): { field: string; message: string } | null {
    if (!personId && !email) return { field: 'PersonID', message: 'An attendee is a person, or a guest with an email address.' };
    if (email && !EMAIL.test(email)) return { field: 'Email', message: `"${email}" is not an email address.` };
    return null;
}

/**
 * An attendee of a meeting: a person or an address, once per meeting (the database's index), their MJ user filled from
 * the person's account, and an Organizer row that names the meeting's organizer. Who may write it (§ 3, § 4): the
 * organizer or an administrator invites, removes and changes attendees; an attendee changes only their own answer and
 * attendance. The meeting server keeps the organizer's row in step itself and marks those saves as its own.
 */
@RegisterClass(BaseEntity, MEETING_ATTENDEE_ENTITY)
export class MeetingAttendeeEntityServer extends mjBizAppsTasksMeetingAttendeeEntity {
    /** Set by MeetingEntityServer on the rows it keeps in step; never a column, so nothing over the API can set it. */
    public MaintainedByMeetingServer = false;

    private get metadataProvider(): IMetadataProvider {
        return this.ProviderToUse as unknown as IMetadataProvider;
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        const problem = personOrEmailProblem(this.PersonID, this.Email);
        if (problem) return fail(result, problem.field, problem.message);

        const meeting = await this.metadataProvider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, this.ContextCurrentUser);
        const found = await meeting.Load(this.MeetingID);
        if (this.Role === 'Organizer' && found && (this.PersonID ?? '').toLowerCase() !== meeting.OrganizerPersonID.toLowerCase()) {
            return fail(result, 'Role', 'The Organizer row is the meeting\'s organizer. Change the meeting\'s organizer instead.');
        }
        if (this.MaintainedByMeetingServer) return result;

        // The meeting a caller may not read (a Private one they are not on) is, to them, not there
        if (!found) return fail(result, 'MeetingID', 'The meeting was not found, or you may not see it.');
        const caller = await meetingCaller(this.metadataProvider, this.ContextCurrentUser);
        if (callerOwnsMeeting(caller, meeting.OrganizerPersonID)) return result;
        if (!this.IsSaved) return fail(result, 'MeetingID', 'Only the organizer invites people to a meeting.');
        if (!this.isCallersOwnRow(caller.personId)) return fail(result, 'PersonID', 'Only the organizer changes another attendee.');
        const beyondOwn = this.Fields.filter((f) => f.Dirty && !OWN_ROW_FIELDS.has(f.CodeName)).map((f) => f.CodeName);
        if (beyondOwn.length) return fail(result, beyondOwn[0], 'An attendee changes their own answer and attendance; the organizer changes the rest.');
        return result;
    }

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        if (this.Email) this.Email = this.Email.trim().toLowerCase();
        const personChanged = this.Fields.some((f) => f.CodeName === 'PersonID' && f.Dirty);
        if (this.PersonID && (!this.UserID || personChanged)) {
            this.UserID = await userIdForPerson(this.metadataProvider, this.PersonID, this.ContextCurrentUser);
        }
        return super.Save(options);
    }

    /** Removing an attendee is the organizer's; an attendee who will not come answers Declined instead. */
    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        if (!this.MaintainedByMeetingServer) {
            const meeting = await this.metadataProvider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, this.ContextCurrentUser);
            const found = await meeting.Load(this.MeetingID);
            const caller = await meetingCaller(this.metadataProvider, this.ContextCurrentUser);
            if (!found || !callerOwnsMeeting(caller, meeting.OrganizerPersonID)) {
                throw new Error('Only the organizer removes an attendee. An attendee who will not come answers Declined.');
            }
        }
        return super.Delete(options);
    }

    /** The row is the caller's when it names their Person or their user. */
    private isCallersOwnRow(callerPersonId: string | null): boolean {
        const user = this.ContextCurrentUser;
        const byUser = !!user?.ID && !!this.UserID && user.ID.toLowerCase() === this.UserID.toLowerCase();
        const byPerson = !!callerPersonId && !!this.PersonID && callerPersonId.toLowerCase() === this.PersonID.toLowerCase();
        return byUser || byPerson;
    }
}

/** Who each new occurrence of a series invites: the same shape, without an organizer row; the series' organizer or an administrator writes them. */
@RegisterClass(BaseEntity, MEETING_SERIES_ATTENDEE_ENTITY)
export class MeetingSeriesAttendeeEntityServer extends mjBizAppsTasksMeetingSeriesAttendeeEntity {
    private get metadataProvider(): IMetadataProvider {
        return this.ProviderToUse as unknown as IMetadataProvider;
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        const problem = personOrEmailProblem(this.PersonID, this.Email);
        if (problem) return fail(result, problem.field, problem.message);
        if (!(await this.callerOwnsSeries())) return fail(result, 'SeriesID', 'Only the organizer changes who a series invites.');
        return result;
    }

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        if (this.Email) this.Email = this.Email.trim().toLowerCase();
        const personChanged = this.Fields.some((f) => f.CodeName === 'PersonID' && f.Dirty);
        if (this.PersonID && (!this.UserID || personChanged)) {
            this.UserID = await userIdForPerson(this.metadataProvider, this.PersonID, this.ContextCurrentUser);
        }
        return super.Save(options);
    }

    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        if (!(await this.callerOwnsSeries())) throw new Error('Only the organizer changes who a series invites.');
        return super.Delete(options);
    }

    private async callerOwnsSeries(): Promise<boolean> {
        const series = await this.metadataProvider.GetEntityObject<mjBizAppsTasksMeetingSeriesEntity>(MEETING_SERIES_ENTITY, this.ContextCurrentUser);
        if (!(await series.Load(this.SeriesID))) return false;
        const caller = await meetingCaller(this.metadataProvider, this.ContextCurrentUser);
        return callerOwnsMeeting(caller, series.OrganizerPersonID);
    }
}
