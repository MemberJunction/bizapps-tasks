import { BaseEntity, RunView, ValidationErrorInfo, ValidationErrorType, type IMetadataProvider, type ValidationResult } from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { mjBizAppsTasksMeetingAgendaItemEntity, mjBizAppsTasksMeetingLinkEntity } from '@mj-biz-apps/tasks-entities';
import { MEETING_AGENDA_ITEM_ENTITY, MEETING_LINK_ENTITY, agendaParentProblem, type AgendaNode } from '@mj-biz-apps/tasks-core';

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

    private async parentElsewhere(provider: IMetadataProvider): Promise<AgendaNode[]> {
        const rows = await RunView.FromMetadataProvider(provider).RunView<AgendaNode>(
            { EntityName: MEETING_AGENDA_ITEM_ENTITY, ExtraFilter: `ID = '${this.ParentID}'`, Fields: ['ID', 'MeetingID', 'ParentID', 'Sequence'], ResultType: 'simple', MaxRows: 1 },
            this.ContextCurrentUser,
        );
        return rows.Success ? rows.Results : [];
    }
}

/** A link belongs to exactly one of a meeting and a series. */
@RegisterClass(BaseEntity, MEETING_LINK_ENTITY)
export class MeetingLinkEntityServer extends mjBizAppsTasksMeetingLinkEntity {
    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        if (!!this.MeetingID === !!this.SeriesID) return fail(result, 'MeetingID', 'A link belongs to a meeting or to a series, one of the two.');
        return result;
    }
}
