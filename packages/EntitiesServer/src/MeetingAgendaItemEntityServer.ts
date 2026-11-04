import { BaseEntity, RunView, ValidationErrorInfo, ValidationErrorType, type EntityDeleteOptions, type IMetadataProvider, type ValidationResult } from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { mjBizAppsTasksMeetingAgendaItemEntity, mjBizAppsTasksMeetingLinkEntity } from '@mj-biz-apps/tasks-entities';
import { MEETING_AGENDA_ITEM_ENTITY, MEETING_LINK_ENTITY, MEETING_SERIES_ENTITY, agendaParentProblem, type AgendaNode } from '@mj-biz-apps/tasks-core';
import { mjBizAppsTasksMeetingSeriesEntity } from '@mj-biz-apps/tasks-entities';
import { callerAndMeeting, callerOwnsMeeting, meetingCaller, movedFromMeetingRefusal, valueBefore } from './meeting-caller.js';

const fail = (result: ValidationResult, field: string, message: string): ValidationResult => {
    result.Success = false;
    result.Errors.push(new ValidationErrorInfo(field, message, null, ValidationErrorType.Failure));
    return result;
};

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** An agenda item's parent is in the same meeting and the tree has no cycle (the meetings plan, § 3). */
@RegisterClass(BaseEntity, MEETING_AGENDA_ITEM_ENTITY)
export class MeetingAgendaItemEntityServer extends mjBizAppsTasksMeetingAgendaItemEntity {
    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        if (this.DurationMinutes != null && this.DurationMinutes < 0) return fail(result, 'DurationMinutes', 'An agenda item takes 0 or more minutes.');
        // The ids below reach a filter before the database would refuse a malformed one: only a GUID passes
        for (const field of ['MeetingID', 'ParentID', 'DeferredToMeetingID'] as const) {
            const value = this[field];
            if (value != null && value !== '' && !UUID.test(String(value))) return fail(result, field, `${field} is not an id.`);
        }
        // The agenda is the organizer's to write (the meetings plan, § 3 and § 5), over the API as in the app
        const moved = await movedFromMeetingRefusal(this.ProviderToUse as unknown as IMetadataProvider, this.ContextCurrentUser, this);
        if (moved) return fail(result, 'MeetingID', moved);
        const access = await callerAndMeeting(this.ProviderToUse as unknown as IMetadataProvider, this.ContextCurrentUser, this.MeetingID);
        if (!access.found) return fail(result, 'MeetingID', 'The meeting was not found, or you may not see it.');
        if (!access.owns) return fail(result, 'MeetingID', 'Only the organizer changes the agenda.');
        if (this.DeferredToMeetingID && this.DeferredToMeetingID.toLowerCase() === this.MeetingID.toLowerCase()) {
            return fail(result, 'DeferredToMeetingID', 'An item is deferred to a later meeting, not to its own.');
        }
        if (this.ParentID) {
            const provider = this.ProviderToUse as unknown as IMetadataProvider;
            const rows = await RunView.FromMetadataProvider(provider).RunView<AgendaNode>(
                { EntityName: MEETING_AGENDA_ITEM_ENTITY, ExtraFilter: `MeetingID = '${this.MeetingID}'`, Fields: ['ID', 'MeetingID', 'ParentID', 'Sequence'], ResultType: 'simple', MaxRows: 2000 },
                this.ContextCurrentUser,
            );
            if (!rows.Success) return fail(result, 'ParentID', `The agenda could not be read: ${rows.ErrorMessage}`);
            // The parent may sit on another meeting: look it up there too, so the refusal says so
            const agenda = rows.Results.some((row) => row.ID.toLowerCase() === this.ParentID!.toLowerCase()) ? rows.Results : [...rows.Results, ...(await this.parentElsewhere(provider))];
            const problem = agendaParentProblem({ ID: this.ID, MeetingID: this.MeetingID, ParentID: this.ParentID, Sequence: this.Sequence }, agenda);
            if (problem) return fail(result, 'ParentID', problem);
        }
        return result;
    }

    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        const access = await callerAndMeeting(this.ProviderToUse as unknown as IMetadataProvider, this.ContextCurrentUser, this.MeetingID);
        if (!access.found || !access.owns) throw new Error('Only the organizer changes the agenda.');
        return super.Delete(options);
    }

    private async parentElsewhere(provider: IMetadataProvider): Promise<AgendaNode[]> {
        const rows = await RunView.FromMetadataProvider(provider).RunView<AgendaNode>(
            { EntityName: MEETING_AGENDA_ITEM_ENTITY, ExtraFilter: `ID = '${this.ParentID}'`, Fields: ['ID', 'MeetingID', 'ParentID', 'Sequence'], ResultType: 'simple', MaxRows: 1 },
            this.ContextCurrentUser,
        );
        return rows.Success ? rows.Results : [];
    }
}

/** A link belongs to exactly one of a meeting and a series, and is the organizer's (or an administrator's) to write. */
@RegisterClass(BaseEntity, MEETING_LINK_ENTITY)
export class MeetingLinkEntityServer extends mjBizAppsTasksMeetingLinkEntity {
    private get metadataProvider(): IMetadataProvider {
        return this.ProviderToUse as unknown as IMetadataProvider;
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        if (!!this.MeetingID === !!this.SeriesID) return fail(result, 'MeetingID', 'A link belongs to a meeting or to a series, one of the two.');
        for (const field of ['MeetingID', 'SeriesID'] as const) {
            const value = this[field];
            if (value != null && value !== '' && !UUID.test(String(value))) return fail(result, field, `${field} is not an id.`);
        }
        const refusal = await this.callerRefusal();
        if (refusal) return fail(result, this.MeetingID ? 'MeetingID' : 'SeriesID', refusal);
        return result;
    }

    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        const refusal = await this.callerRefusal();
        if (refusal) throw new Error(refusal);
        return super.Delete(options);
    }

    /** Why the caller may not write this link, or null. A link that moves needs the caller on both ends. */
    private async callerRefusal(): Promise<string | null> {
        const moved = await movedFromMeetingRefusal(this.metadataProvider, this.ContextCurrentUser, this);
        if (moved) return moved;
        const seriesField = this.Fields.find((f) => f.CodeName === 'SeriesID');
        const seriesBefore = this.IsSaved && seriesField?.Dirty ? valueBefore(this, 'SeriesID') : null;
        if (seriesBefore) {
            const series = await this.metadataProvider.GetEntityObject<mjBizAppsTasksMeetingSeriesEntity>(MEETING_SERIES_ENTITY, this.ContextCurrentUser);
            const caller = await meetingCaller(this.metadataProvider, this.ContextCurrentUser);
            if (!(await series.Load(seriesBefore)) || !callerOwnsMeeting(caller, series.OrganizerPersonID)) return 'A link moves to another series only at the organizer\'s hand, on both series.';
        }
        if (this.MeetingID) {
            const access = await callerAndMeeting(this.metadataProvider, this.ContextCurrentUser, this.MeetingID);
            if (!access.found) return 'The meeting was not found, or you may not see it.';
            return access.owns ? null : 'Only the organizer changes what a meeting is linked to.';
        }
        const series = await this.metadataProvider.GetEntityObject<mjBizAppsTasksMeetingSeriesEntity>(MEETING_SERIES_ENTITY, this.ContextCurrentUser);
        if (!this.SeriesID || !(await series.Load(this.SeriesID))) return 'The series was not found, or you may not see it.';
        const caller = await meetingCaller(this.metadataProvider, this.ContextCurrentUser);
        return callerOwnsMeeting(caller, series.OrganizerPersonID) ? null : 'Only the organizer changes what a series is linked to.';
    }
}
