import { BaseEntity, ValidationErrorInfo, ValidationErrorType, type EntityDeleteOptions, type EntitySaveOptions, type IMetadataProvider, type ValidationResult } from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { mjBizAppsTasksMeetingSeriesEntity } from '@mj-biz-apps/tasks-entities';
import { MEETING_SERIES_ENTITY, MeetingSeriesService, isValidTimeZone, recurrenceRuleProblem } from '@mj-biz-apps/tasks-core';
import { runAfterCommit } from './after-commit.js';
import { callerOwnsMeeting, meetingCaller } from './meeting-caller.js';

const fail = (result: ValidationResult, field: string, message: string): ValidationResult => {
    result.Success = false;
    result.Errors.push(new ValidationErrorInfo(field, message, null, ValidationErrorType.Failure));
    return result;
};

/**
 * A series' rule parses before it is saved, in a real zone, with a length (the meetings plan, § 3); its organizer or an
 * administrator is the one who makes and changes it, since a change reaches every occurrence not yet held; and once the
 * save has committed, its occurrences are made or brought up to date, through MeetingSeriesService.
 */
@RegisterClass(BaseEntity, MEETING_SERIES_ENTITY)
export class MeetingSeriesEntityServer extends mjBizAppsTasksMeetingSeriesEntity {
    private get metadataProvider(): IMetadataProvider {
        return this.ProviderToUse as unknown as IMetadataProvider;
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        const ruleProblem = recurrenceRuleProblem(this.RecurrenceRule);
        if (ruleProblem) return fail(result, 'RecurrenceRule', ruleProblem);
        if (!isValidTimeZone(this.TimeZone)) return fail(result, 'TimeZone', `"${this.TimeZone ?? ''}" is not a time zone. Use an IANA name such as America/Chicago.`);
        if (!(this.DurationMinutes > 0)) return fail(result, 'DurationMinutes', 'A series\' meetings last more than 0 minutes.');

        const caller = await meetingCaller(this.metadataProvider, this.ContextCurrentUser);
        if (caller.administers) return result;
        if (!this.IsSaved) {
            // A new series is organized by the person who makes it, unless an administrator makes it for someone
            if (!callerOwnsMeeting(caller, this.OrganizerPersonID)) return fail(result, 'OrganizerPersonID', 'A series is organized by the person who makes it.');
            return result;
        }
        const organizerField = this.Fields.find((f) => f.CodeName === 'OrganizerPersonID');
        const organizerBefore = organizerField?.Dirty ? String(organizerField.OldValue ?? '') : this.OrganizerPersonID;
        if (!callerOwnsMeeting(caller, organizerBefore)) return fail(result, 'OrganizerPersonID', 'Only the organizer changes a series.');
        return result;
    }

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        const changed = !this.IsSaved || this.Fields.some((f) => f.Dirty && f.CodeName !== 'MaterializedThrough');
        if (!(await super.Save(options))) return false;
        if (changed && this.Status === 'Active') {
            const provider = this.metadataProvider;
            const user = this.ContextCurrentUser;
            const seriesId = this.ID;
            runAfterCommit(this.ProviderToUse, `materialize series ${seriesId}`, async () => {
                await new MeetingSeriesService(provider).materialize(seriesId, user);
            });
        }
        return true;
    }

    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        const caller = await meetingCaller(this.metadataProvider, this.ContextCurrentUser);
        if (!callerOwnsMeeting(caller, this.OrganizerPersonID)) throw new Error('Only the organizer deletes a series.');
        return super.Delete(options);
    }
}
