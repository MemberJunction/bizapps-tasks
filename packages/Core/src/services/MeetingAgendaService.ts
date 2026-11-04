import { Metadata, RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import type { mjBizAppsTasksMeetingAgendaItemEntity, mjBizAppsTasksMeetingAgendaItemTypeEntity } from '@mj-biz-apps/tasks-entities';
import { MEETING_AGENDA_ITEM_ENTITY, MEETING_AGENDA_ITEM_TYPE_ENTITY, entityFailure } from '../meetings/entity-names.js';
import { flattenAgendaTemplate, type AgendaTemplate } from '../meetings/agenda-template.js';
import { orderAgenda, type AgendaNode } from '../meetings/agenda.js';

type AgendaItemRow = Pick<mjBizAppsTasksMeetingAgendaItemEntity, 'ID' | 'MeetingID' | 'ParentID' | 'Sequence' | 'Name' | 'Description' | 'TypeID' | 'PresenterPersonID' | 'DurationMinutes' | 'Status'>;

const AGENDA_FIELDS = ['ID', 'MeetingID', 'ParentID', 'Sequence', 'Name', 'Description', 'TypeID', 'PresenterPersonID', 'DurationMinutes', 'Status'];

/**
 * A meeting's agenda (the meetings plan, § 3): the type's template applied to a new meeting, items reordered, and the
 * items a meeting left unfinished carried forward to the next one. Every write goes through the entity, so the agenda
 * item server's rules (parent in the same meeting, no cycle) hold here too.
 */
export class MeetingAgendaService {
    constructor(private readonly provider: IMetadataProvider = Metadata.Provider) {}

    /** The meeting's agenda, in reading order. */
    async itemsOf(meetingId: string, contextUser: UserInfo): Promise<AgendaItemRow[]> {
        const res = await RunView.FromMetadataProvider(this.provider).RunView<AgendaItemRow>(
            { EntityName: MEETING_AGENDA_ITEM_ENTITY, ExtraFilter: `MeetingID = '${meetingId}'`, Fields: AGENDA_FIELDS, ResultType: 'simple', MaxRows: 1000 },
            contextUser,
        );
        if (!res.Success) throw new Error(`The agenda could not be read: ${res.ErrorMessage}`);
        return orderAgenda(res.Results as unknown as AgendaNode[]) as unknown as AgendaItemRow[];
    }

    /** The agenda item types by code, upper-cased. */
    async typesByCode(contextUser: UserInfo): Promise<Map<string, string>> {
        const res = await RunView.FromMetadataProvider(this.provider).RunView<Pick<mjBizAppsTasksMeetingAgendaItemTypeEntity, 'ID' | 'Code'>>(
            { EntityName: MEETING_AGENDA_ITEM_TYPE_ENTITY, Fields: ['ID', 'Code'], ResultType: 'simple', MaxRows: 500 },
            contextUser,
        );
        if (!res.Success) throw new Error(`The agenda item types could not be read: ${res.ErrorMessage}`);
        return new Map(res.Results.map((row) => [row.Code.toUpperCase(), row.ID]));
    }

    /**
     * Writes the template's items onto the meeting's agenda, after whatever is there, keeping the template's nesting. A
     * type code the catalogue does not know leaves the item untyped. Returns the items made, in order.
     */
    async applyTemplate(meetingId: string, template: AgendaTemplate, contextUser: UserInfo): Promise<mjBizAppsTasksMeetingAgendaItemEntity[]> {
        const flat = flattenAgendaTemplate(template);
        if (!flat.length) return [];
        const types = await this.typesByCode(contextUser);
        const existing = await this.itemsOf(meetingId, contextUser);
        const topLevelAfter = existing.filter((item) => !item.ParentID).reduce((max, item) => Math.max(max, item.Sequence), 0);
        const made: mjBizAppsTasksMeetingAgendaItemEntity[] = [];
        for (const entry of flat) {
            const item = await this.provider.GetEntityObject<mjBizAppsTasksMeetingAgendaItemEntity>(MEETING_AGENDA_ITEM_ENTITY, contextUser);
            item.NewRecord();
            item.MeetingID = meetingId;
            item.ParentID = entry.parentIndex == null ? null : made[entry.parentIndex].ID;
            item.Sequence = entry.parentIndex == null ? topLevelAfter + entry.sequence : entry.sequence;
            item.Name = entry.title;
            item.Description = entry.description ?? null;
            item.TypeID = entry.typeCode ? (types.get(entry.typeCode.toUpperCase()) ?? null) : null;
            item.DurationMinutes = entry.durationMinutes ?? null;
            item.Status = 'Planned';
            if (!(await item.Save())) throw new Error(`The agenda item "${entry.title}" was not saved: ${entityFailure(item)}`);
            made.push(item);
        }
        return made;
    }

    /** Puts the named items in this order among their siblings: Sequence 100, 200, 300 … Items not named keep their place after. */
    async reorder(meetingId: string, orderedIds: readonly string[], contextUser: UserInfo): Promise<void> {
        const wanted = orderedIds.map((id) => id.toLowerCase());
        let sequence = 0;
        for (const id of wanted) {
            const item = await this.provider.GetEntityObject<mjBizAppsTasksMeetingAgendaItemEntity>(MEETING_AGENDA_ITEM_ENTITY, contextUser);
            if (!(await item.Load(id))) throw new Error(`Agenda item ${id} was not found.`);
            if (item.MeetingID.toLowerCase() !== meetingId.toLowerCase()) throw new Error(`Agenda item ${id} is not on this meeting.`);
            sequence += 100;
            if (item.Sequence !== sequence) {
                item.Sequence = sequence;
                if (!(await item.Save())) throw new Error(`The agenda item was not reordered: ${entityFailure(item)}`);
            }
        }
    }

    /**
     * Carries the items the meeting left unfinished (Planned, InProgress or Deferred without a destination) to the next
     * meeting: each is copied there with its sub-items, and the original is marked Deferred to it. Returns the copies.
     */
    async carryForward(fromMeetingId: string, toMeetingId: string, contextUser: UserInfo): Promise<mjBizAppsTasksMeetingAgendaItemEntity[]> {
        if (fromMeetingId.toLowerCase() === toMeetingId.toLowerCase()) throw new Error('An agenda is carried forward to a different meeting.');
        const items = await this.itemsOf(fromMeetingId, contextUser);
        const unfinished = new Set(items.filter((item) => item.Status === 'Planned' || item.Status === 'InProgress').map((item) => item.ID.toLowerCase()));
        if (!unfinished.size) return [];
        const target = await this.itemsOf(toMeetingId, contextUser);
        let topLevelAfter = target.filter((item) => !item.ParentID).reduce((max, item) => Math.max(max, item.Sequence), 0);
        const copies = new Map<string, string>(); // source id → copy id
        const made: mjBizAppsTasksMeetingAgendaItemEntity[] = [];
        for (const source of items) {
            // A sub-item travels with its parent; one whose parent stays is carried as a top-level item of its own
            const parentCopy = source.ParentID ? copies.get(source.ParentID.toLowerCase()) : undefined;
            if (!unfinished.has(source.ID.toLowerCase()) && !parentCopy) continue;
            const copy = await this.provider.GetEntityObject<mjBizAppsTasksMeetingAgendaItemEntity>(MEETING_AGENDA_ITEM_ENTITY, contextUser);
            copy.NewRecord();
            copy.MeetingID = toMeetingId;
            copy.ParentID = parentCopy ?? null;
            copy.Sequence = parentCopy ? source.Sequence : (topLevelAfter += 100);
            copy.Name = source.Name;
            copy.Description = source.Description;
            copy.TypeID = source.TypeID;
            copy.PresenterPersonID = source.PresenterPersonID;
            copy.DurationMinutes = source.DurationMinutes;
            copy.Status = 'Planned';
            if (!(await copy.Save())) throw new Error(`The agenda item "${source.Name}" was not carried forward: ${entityFailure(copy)}`);
            copies.set(source.ID.toLowerCase(), copy.ID);
            made.push(copy);
            const original = await this.provider.GetEntityObject<mjBizAppsTasksMeetingAgendaItemEntity>(MEETING_AGENDA_ITEM_ENTITY, contextUser);
            if (await original.Load(source.ID)) {
                original.Status = 'Deferred';
                original.DeferredToMeetingID = toMeetingId;
                if (!(await original.Save())) throw new Error(`The agenda item "${source.Name}" was not marked deferred: ${entityFailure(original)}`);
            }
        }
        return made;
    }
}
