import { BaseEntity, ValidationErrorInfo, ValidationErrorType, type EntitySaveOptions, type IMetadataProvider, type ValidationResult } from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { mjBizAppsTasksMeetingAttendeeEntity, mjBizAppsTasksMeetingEntity, mjBizAppsTasksMeetingSeriesAttendeeEntity } from '@mj-biz-apps/tasks-entities';
import { MEETING_ATTENDEE_ENTITY, MEETING_ENTITY, MEETING_SERIES_ATTENDEE_ENTITY, userIdForPerson } from '@mj-biz-apps/tasks-core';

const fail = (result: ValidationResult, field: string, message: string): ValidationResult => {
    result.Success = false;
    result.Errors.push(new ValidationErrorInfo(field, message, null, ValidationErrorType.Failure));
    return result;
};

const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/** An attendee is a person or an address (the meetings plan, § 3); the address is kept tidy. */
function personOrEmailProblem(personId: string | null, email: string | null): { field: string; message: string } | null {
    if (!personId && !email) return { field: 'PersonID', message: 'An attendee is a person, or a guest with an email address.' };
    if (email && !EMAIL.test(email)) return { field: 'Email', message: `"${email}" is not an email address.` };
    return null;
}

/**
 * An attendee of a meeting: a person or an address, once per meeting (the database's index), their MJ user filled from
 * the person's account, and an Organizer row that names the meeting's organizer.
 */
@RegisterClass(BaseEntity, MEETING_ATTENDEE_ENTITY)
export class MeetingAttendeeEntityServer extends mjBizAppsTasksMeetingAttendeeEntity {
    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        const problem = personOrEmailProblem(this.PersonID, this.Email);
        if (problem) return fail(result, problem.field, problem.message);
        if (this.Role === 'Organizer') {
            const provider = this.ProviderToUse as unknown as IMetadataProvider;
            const meeting = await provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, this.ContextCurrentUser);
            if (await meeting.Load(this.MeetingID)) {
                if ((this.PersonID ?? '').toLowerCase() !== meeting.OrganizerPersonID.toLowerCase()) {
                    return fail(result, 'Role', 'The Organizer row is the meeting\'s organizer. Change the meeting\'s organizer instead.');
                }
            }
        }
        return result;
    }

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        if (this.Email) this.Email = this.Email.trim().toLowerCase();
        if (this.PersonID && !this.UserID) {
            this.UserID = await userIdForPerson(this.ProviderToUse as unknown as IMetadataProvider, this.PersonID, this.ContextCurrentUser);
        }
        return super.Save(options);
    }
}

/** Who each new occurrence of a series invites: the same rules, without an organizer row. */
@RegisterClass(BaseEntity, MEETING_SERIES_ATTENDEE_ENTITY)
export class MeetingSeriesAttendeeEntityServer extends mjBizAppsTasksMeetingSeriesAttendeeEntity {
    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        const problem = personOrEmailProblem(this.PersonID, this.Email);
        if (problem) return fail(result, problem.field, problem.message);
        return result;
    }

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        if (this.Email) this.Email = this.Email.trim().toLowerCase();
        if (this.PersonID && !this.UserID) {
            this.UserID = await userIdForPerson(this.ProviderToUse as unknown as IMetadataProvider, this.PersonID, this.ContextCurrentUser);
        }
        return super.Save(options);
    }
}
