import { BaseEntity, ValidationErrorInfo, ValidationErrorType, type EntityDeleteOptions, type EntitySaveOptions, type IMetadataProvider, type ValidationResult } from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { mjBizAppsTasksMeetingNoteEntity } from '@mj-biz-apps/tasks-entities';
import { MEETING_NOTE_ENTITY } from '@mj-biz-apps/tasks-core';
import { callerAndMeeting } from './meeting-caller.js';

const fail = (result: ValidationResult, field: string, message: string): ValidationResult => {
    result.Success = false;
    result.Errors.push(new ValidationErrorInfo(field, message, null, ValidationErrorType.Failure));
    return result;
};

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * A note on a meeting (the meetings plan, § 2.6 and § 5): written by anyone on the meeting, the organizer included;
 * changed or removed by its author, the organizer or an administrator. The author is stamped from the caller's Person
 * when the note does not name one. A meeting the caller may not read is, to them, not there.
 */
@RegisterClass(BaseEntity, MEETING_NOTE_ENTITY)
export class MeetingNoteEntityServer extends mjBizAppsTasksMeetingNoteEntity {
    private get metadataProvider(): IMetadataProvider {
        return this.ProviderToUse as unknown as IMetadataProvider;
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        for (const field of ['MeetingID', 'AgendaItemID', 'AuthorPersonID'] as const) {
            const value = this[field];
            if (value != null && value !== '' && !UUID.test(String(value))) return fail(result, field, `${field} is not an id.`);
        }
        const access = await callerAndMeeting(this.metadataProvider, this.ContextCurrentUser, this.MeetingID);
        if (!access.found) return fail(result, 'MeetingID', 'The meeting was not found, or you may not see it.');
        if (!this.IsSaved) {
            if (!access.attends) return fail(result, 'MeetingID', 'Only someone on the meeting writes a note on it.');
            if (!this.AuthorPersonID) this.AuthorPersonID = access.caller.personId;
            return result;
        }
        if (!access.owns && !this.isAuthor(access.caller.personId)) return fail(result, 'AuthorPersonID', 'Only its author or the organizer changes a note.');
        return result;
    }

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        return super.Save(options);
    }

    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        const access = await callerAndMeeting(this.metadataProvider, this.ContextCurrentUser, this.MeetingID);
        if (!access.found || (!access.owns && !this.isAuthor(access.caller.personId))) throw new Error('Only its author or the organizer removes a note.');
        return super.Delete(options);
    }

    private isAuthor(callerPersonId: string | null): boolean {
        return !!callerPersonId && !!this.AuthorPersonID && callerPersonId.toLowerCase() === this.AuthorPersonID.toLowerCase();
    }
}
