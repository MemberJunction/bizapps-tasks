import { Metadata, RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import type {
    mjBizAppsTasksMeetingAgendaItemEntity,
    mjBizAppsTasksMeetingAgendaItemTypeEntity,
    mjBizAppsTasksMeetingEntity,
    mjBizAppsTasksMeetingLinkEntity,
    mjBizAppsTasksMeetingTypeEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    MEETING_AGENDA_ITEM_ENTITY,
    MEETING_AGENDA_ITEM_TYPE_ENTITY,
    MEETING_ENTITY,
    MEETING_LINK_ENTITY,
    MEETING_TYPE_ENTITY,
    entityFailure,
} from '../meetings/entity-names.js';
import { flattenAgendaTemplate, parseAgendaTemplate, type AgendaTemplate, type AgendaTemplateItem } from '../meetings/agenda-template.js';
import { orderAgenda, type AgendaNode } from '../meetings/agenda.js';

const TASKS_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_LINKS_ENTITY = 'MJ_BizApps_Tasks: Task Links';

export const DEFAULT_MEETING_AGENDA_PROMPT_NAME = 'Tasks: Meeting Agenda Draft';

type AgendaItemRow = Pick<mjBizAppsTasksMeetingAgendaItemEntity, 'ID' | 'MeetingID' | 'ParentID' | 'Sequence' | 'Name' | 'Description' | 'TypeID' | 'PresenterPersonID' | 'DurationMinutes' | 'Status'>;

const AGENDA_FIELDS = ['ID', 'MeetingID', 'ParentID', 'Sequence', 'Name', 'Description', 'TypeID', 'PresenterPersonID', 'DurationMinutes', 'Status'];

export interface OpenLinkedTaskSummary {
    id: string;
    name: string;
    status: string;
    priority: string | null;
    dueAt: string | null;
}

export interface UnfinishedPriorItemSummary {
    id: string;
    name: string;
    description: string | null;
    durationMinutes: number | null;
}

export interface DraftAgendaContext {
    meeting: Pick<mjBizAppsTasksMeetingEntity, 'ID' | 'Name' | 'Description' | 'StartsAt' | 'EndsAt' | 'SeriesID' | 'TypeID'>;
    template: AgendaTemplate | null;
    openTasks: OpenLinkedTaskSummary[];
    unfinishedItems: UnfinishedPriorItemSummary[];
}

export type MeetingAgendaPromptRunner = (
    input: DraftAgendaContext,
    contextUser: UserInfo,
) => Promise<AgendaTemplate>;

export interface DraftAgendaOptions {
    promptRunner?: MeetingAgendaPromptRunner;
}

/**
 * Built-in deterministic agenda builder used when no external AI prompt runner is supplied:
 * combines the meeting type's template, unfinished items from the last occurrence in the series,
 * and open tasks linked to the same records the meeting belongs to.
 */
export async function defaultMeetingAgendaPromptRunner(ctx: DraftAgendaContext): Promise<AgendaTemplate> {
    const items: AgendaTemplateItem[] = ctx.template ? [...ctx.template.items] : [];

    if (ctx.unfinishedItems.length) {
        items.push({
            title: 'Carry-over from previous meeting',
            typeCode: 'DISCUSSION',
            durationMinutes: ctx.unfinishedItems.reduce((sum, item) => sum + (item.durationMinutes ?? 10), 0),
            items: ctx.unfinishedItems.map((item) => ({
                title: item.name,
                description: item.description,
                durationMinutes: item.durationMinutes ?? 10,
                typeCode: 'DISCUSSION',
            })),
        });
    }

    if (ctx.openTasks.length) {
        items.push({
            title: 'Open tasks & action items',
            typeCode: 'ACTION_REVIEW',
            durationMinutes: Math.max(5, ctx.openTasks.length * 5),
            items: ctx.openTasks.map((task) => ({
                title: task.name,
                description: `Status: ${task.status}${task.priority ? ` · Priority: ${task.priority}` : ''}`,
                durationMinutes: 5,
                typeCode: 'ACTION_REVIEW',
            })),
        });
    }

    return { items };
}

/**
 * A meeting's agenda (the meetings plan, § 3 and § 8): the type's template applied to a new meeting, items reordered,
 * the items a meeting left unfinished carried forward to the next one, and AI agenda drafting from the type's template,
 * open linked tasks, and unfinished items from the last occurrence. Every write goes through the entity, so the agenda
 * item server's rules (parent in the same meeting, no cycle) hold here too.
 */
export class MeetingAgendaService {
    constructor(
        private readonly provider: IMetadataProvider = Metadata.Provider,
        private readonly defaultRunner: MeetingAgendaPromptRunner = defaultMeetingAgendaPromptRunner,
    ) {}

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

    /**
     * Drafts an agenda for the meeting (the meetings plan, § 8): gathers the meeting type's template, the open tasks
     * linked to what the meeting belongs to (`MeetingLink` → `TaskLink`), and the items the last occurrence in the
     * series left unfinished, passes them to the prompt runner, and writes the resulting items onto the meeting.
     */
    async draftAgenda(
        meetingId: string,
        contextUser: UserInfo,
        options: DraftAgendaOptions = {},
    ): Promise<mjBizAppsTasksMeetingAgendaItemEntity[]> {
        const meeting = await this.provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, contextUser);
        if (!(await meeting.Load(meetingId))) {
            throw new Error('The meeting was not found, or you may not see it.');
        }

        let template: AgendaTemplate | null = null;
        if (meeting.TypeID) {
            const type = await this.provider.GetEntityObject<mjBizAppsTasksMeetingTypeEntity>(MEETING_TYPE_ENTITY, contextUser);
            if (await type.Load(meeting.TypeID)) {
                template = parseAgendaTemplate(type.AgendaTemplate);
            }
        }

        const [openTasks, unfinishedItems] = await Promise.all([
            this.loadOpenLinkedTasks(meeting, contextUser),
            this.loadUnfinishedPriorItems(meeting, contextUser),
        ]);

        const runner = options.promptRunner ?? this.defaultRunner;
        const drafted = await runner(
            {
                meeting,
                template,
                openTasks,
                unfinishedItems,
            },
            contextUser,
        );

        if (!drafted.items.length) return [];
        return this.applyTemplate(meetingId, drafted, contextUser);
    }

    private async loadOpenLinkedTasks(
        meeting: Pick<mjBizAppsTasksMeetingEntity, 'ID' | 'SeriesID'>,
        contextUser: UserInfo,
    ): Promise<OpenLinkedTaskSummary[]> {
        const rv = RunView.FromMetadataProvider(this.provider);
        const clauses = [`MeetingID = '${meeting.ID}'`];
        if (meeting.SeriesID) clauses.push(`SeriesID = '${meeting.SeriesID}'`);

        const linksRes = await rv.RunView<Pick<mjBizAppsTasksMeetingLinkEntity, 'EntityID' | 'RecordID'>>(
            {
                EntityName: MEETING_LINK_ENTITY,
                ExtraFilter: clauses.join(' OR '),
                Fields: ['EntityID', 'RecordID'],
                ResultType: 'simple',
                MaxRows: 200,
            },
            contextUser,
        );
        if (!linksRes.Success || !linksRes.Results.length) return [];

        const targetClauses = linksRes.Results.map(
            (l) => `(EntityID = '${l.EntityID.replace(/'/g, "''")}' AND RecordID = '${l.RecordID.replace(/'/g, "''")}')`,
        );
        const taskLinksRes = await rv.RunView<{ TaskID: string }>(
            {
                EntityName: TASK_LINKS_ENTITY,
                ExtraFilter: targetClauses.join(' OR '),
                Fields: ['TaskID'],
                ResultType: 'simple',
                MaxRows: 500,
            },
            contextUser,
        );
        if (!taskLinksRes.Success || !taskLinksRes.Results.length) return [];

        const taskIds = [...new Set(taskLinksRes.Results.map((r) => r.TaskID))];
        const tasksRes = await rv.RunView<{ ID: string; Name: string; Status: string; Priority: string | null; DueAt: string | null }>(
            {
                EntityName: TASKS_ENTITY,
                ExtraFilter: `ID IN (${taskIds.map((id) => `'${id.replace(/'/g, "''")}'`).join(',')}) AND Status NOT IN ('Done', 'Completed', 'Cancelled')`,
                Fields: ['ID', 'Name', 'Status', 'Priority', 'DueAt'],
                OrderBy: 'DueAt ASC',
                ResultType: 'simple',
                MaxRows: 200,
            },
            contextUser,
        );
        if (!tasksRes.Success) return [];
        return tasksRes.Results.map((t) => ({
            id: t.ID,
            name: t.Name,
            status: t.Status,
            priority: t.Priority,
            dueAt: t.DueAt,
        }));
    }

    private async loadUnfinishedPriorItems(
        meeting: Pick<mjBizAppsTasksMeetingEntity, 'ID' | 'SeriesID' | 'StartsAt'>,
        contextUser: UserInfo,
    ): Promise<UnfinishedPriorItemSummary[]> {
        if (!meeting.SeriesID) return [];
        const rv = RunView.FromMetadataProvider(this.provider);
        const startsAtIso = meeting.StartsAt instanceof Date ? meeting.StartsAt.toISOString() : String(meeting.StartsAt);
        const priorRes = await rv.RunView<{ ID: string }>(
            {
                EntityName: MEETING_ENTITY,
                ExtraFilter: `SeriesID = '${meeting.SeriesID}' AND ID <> '${meeting.ID}' AND StartsAt < '${startsAtIso}' AND Status <> 'Cancelled'`,
                Fields: ['ID'],
                OrderBy: 'StartsAt DESC',
                ResultType: 'simple',
                MaxRows: 1,
            },
            contextUser,
        );
        const priorId = priorRes.Success ? priorRes.Results[0]?.ID : undefined;
        if (!priorId) return [];

        const priorItems = await this.itemsOf(priorId, contextUser);
        return priorItems
            .filter((item) => item.Status === 'Planned' || item.Status === 'InProgress')
            .map((item) => ({
                id: item.ID,
                name: item.Name,
                description: item.Description,
                durationMinutes: item.DurationMinutes,
            }));
    }
}
