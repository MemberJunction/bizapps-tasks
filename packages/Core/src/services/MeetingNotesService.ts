import { Metadata, RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import type {
    mjBizAppsTasksMeetingAgendaItemEntity,
    mjBizAppsTasksMeetingAttendeeEntity,
    mjBizAppsTasksMeetingEntity,
    mjBizAppsTasksMeetingNoteEntity,
    mjBizAppsTasksMeetingTypeEntity,
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTaskLinkEntity,
    TaskEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    MEETING_AGENDA_ITEM_ENTITY,
    MEETING_ATTENDEE_ENTITY,
    MEETING_ENTITY,
    MEETING_NOTE_ENTITY,
    MEETING_TYPE_ENTITY,
    entityFailure,
} from '../meetings/entity-names.js';
import { PEOPLE_ENTITY, personIdForUser } from '../meetings/person-user.js';
import {
    markProposedTaskAccepted,
    markProposedTaskDismissed,
    parseProposedTasks,
    serializeProposedTasks,
    type ProposedTask,
} from '../meetings/proposed-tasks.js';
import { TaskAssignmentService } from './TaskAssignmentService.js';

const TASKS_ENTITY = 'MJ_BizApps_Tasks: Tasks';
const TASK_LINKS_ENTITY = 'MJ_BizApps_Tasks: Task Links';
const TASK_TYPES_ENTITY = 'MJ_BizApps_Tasks: Task Types';
const ACTION_ITEM_CODE = 'ACTION_ITEM';

export const DEFAULT_MEETING_NOTES_PROMPT_NAME = 'Tasks: Meeting Notes from Transcript';

export interface MeetingTranscriptContext {
    meeting: Pick<mjBizAppsTasksMeetingEntity, 'ID' | 'Name' | 'Description' | 'StartsAt' | 'EndsAt' | 'TimeZone' | 'TypeID'>;
    promptId: string | null;
    promptName: string;
    agendaItems: Array<Pick<mjBizAppsTasksMeetingAgendaItemEntity, 'ID' | 'Sequence' | 'Name' | 'Description' | 'Status' | 'Outcome'>>;
    attendees: Array<Pick<mjBizAppsTasksMeetingAttendeeEntity, 'ID' | 'PersonID' | 'Person' | 'DisplayName' | 'Email' | 'Role' | 'AttendanceStatus'>>;
    transcript: string;
}

export interface DraftedMeetingNotesOutput {
    title?: string | null;
    summary: string;
    proposedTasks?: Array<{
        id?: string | null;
        title: string;
        description?: string | null;
        assigneePersonId?: string | null;
        assigneeName?: string | null;
        dueAt?: string | null;
        agendaItemId?: string | null;
    }>;
    promptRunId?: string | null;
}

export type MeetingNotesPromptRunner = (
    input: MeetingTranscriptContext,
    contextUser: UserInfo,
) => Promise<DraftedMeetingNotesOutput>;

export interface DraftFromTranscriptOptions {
    title?: string | null;
    kind?: 'Notes' | 'Summary' | 'Decision';
    agendaItemId?: string | null;
    authorPersonId?: string | null;
    promptRunner?: MeetingNotesPromptRunner;
}

export interface AcceptProposedTaskOverrides {
    title?: string | null;
    description?: string | null;
    assigneePersonId?: string | null;
    dueAt?: Date | string | null;
    agendaItemId?: string | null;
    priority?: 'Low' | 'Medium' | 'High' | 'Critical';
    createdByPersonId?: string | null;
}

export interface AcceptedProposedTaskResult {
    note: mjBizAppsTasksMeetingNoteEntity;
    task: TaskEntity;
    proposal: ProposedTask;
}

/**
 * Built-in fallback extractor used when no external AI prompt runner is supplied: builds a clean Markdown summary of
 * the meeting and extracts any explicit `ACTION:` / `TODO:` / `- [ ]` lines from the transcript as proposed tasks.
 */
export async function defaultMeetingNotesPromptRunner(
    ctx: MeetingTranscriptContext,
): Promise<DraftedMeetingNotesOutput> {
    const attendeeNames = ctx.attendees
        .map((a) => a.DisplayName || a.Person || a.Email)
        .filter((v): v is string => !!v);
    const agendaSummary = ctx.agendaItems.length
        ? ctx.agendaItems.map((item) => `- **${item.Name}** (${item.Status})${item.Outcome ? `: ${item.Outcome}` : ''}`).join('\n')
        : '- General discussion';

    const proposedTasks: NonNullable<DraftedMeetingNotesOutput['proposedTasks']> = [];
    const lines = ctx.transcript
        .split(/\r?\n/)
        .map((l) => l.trim())
        .filter(Boolean);

    for (const line of lines) {
        const match = /^(?:ACTION(?:\s+ITEM)?|TODO|FOLLOW[- ]UP|-\s*\[\s*\])\s*:?\s*(.+)$/i.exec(line);
        if (!match) continue;
        const rawTitle = match[1].trim();
        if (!rawTitle) continue;
        // Match an attendee name if mentioned in the action line
        const matchedAttendee = ctx.attendees.find((a) => {
            const label = (a.DisplayName || a.Person || '').trim();
            return label.length > 1 && rawTitle.toLowerCase().includes(label.toLowerCase());
        });
        proposedTasks.push({
            id: `proposal-${proposedTasks.length + 1}`,
            title: rawTitle,
            assigneePersonId: matchedAttendee?.PersonID ?? null,
            assigneeName: matchedAttendee ? (matchedAttendee.DisplayName || matchedAttendee.Person || null) : null,
        });
    }

    const transcriptExcerpt = lines.slice(0, 8).join('\n');
    const summary = [
        `## ${ctx.meeting.Name} — Summary`,
        attendeeNames.length ? `**Participants:** ${attendeeNames.join(', ')}` : null,
        `### Agenda Covered\n${agendaSummary}`,
        transcriptExcerpt ? `### Discussion Notes\n${transcriptExcerpt}` : null,
    ]
        .filter(Boolean)
        .join('\n\n');

    return {
        title: `${ctx.meeting.Name} — AI Notes`,
        summary,
        proposedTasks,
        promptRunId: null,
    };
}

/**
 * AI-assisted meeting notes and proposed tasks (the meetings plan, § 8):
 * - drafts a `MeetingNote` (`Source = 'AI'`, `Status = 'Draft'`) with `ProposedTasks` from a transcript and the
 *   meeting's structured agenda and attendees;
 * - accepts a proposed task into a real `ACTION_ITEM` task with a `TaskLink` to the meeting or agenda item and
 *   an optional `TaskAssignment`, recording the created `taskId` on the proposal;
 * - dismisses a proposed task so it is never filed.
 */
export class MeetingNotesService {
    constructor(
        private readonly provider: IMetadataProvider = Metadata.Provider,
        private readonly defaultRunner: MeetingNotesPromptRunner = defaultMeetingNotesPromptRunner,
    ) {}

    /**
     * Drafts an AI note with proposed tasks from a meeting's transcript.
     * Uses the meeting type's `NotesPromptID` when present, otherwise the default meeting notes prompt.
     */
    async draftFromTranscript(
        meetingId: string,
        transcript: string,
        contextUser: UserInfo,
        options: DraftFromTranscriptOptions = {},
    ): Promise<mjBizAppsTasksMeetingNoteEntity> {
        const cleanTranscript = transcript?.trim() ?? '';
        if (!cleanTranscript) throw new Error('A transcript is required to draft AI meeting notes.');

        const meeting = await this.provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, contextUser);
        if (!(await meeting.Load(meetingId))) {
            throw new Error('The meeting was not found, or you may not see it.');
        }

        let promptId: string | null = null;
        if (meeting.TypeID) {
            const type = await this.provider.GetEntityObject<mjBizAppsTasksMeetingTypeEntity>(MEETING_TYPE_ENTITY, contextUser);
            if (await type.Load(meeting.TypeID)) {
                promptId = type.NotesPromptID ?? null;
            }
        }

        const rv = RunView.FromMetadataProvider(this.provider);
        const [agendaRes, attendeeRes] = await Promise.all([
            rv.RunView<Pick<mjBizAppsTasksMeetingAgendaItemEntity, 'ID' | 'Sequence' | 'Name' | 'Description' | 'Status' | 'Outcome'>>(
                {
                    EntityName: MEETING_AGENDA_ITEM_ENTITY,
                    ExtraFilter: `MeetingID = '${meetingId}'`,
                    Fields: ['ID', 'Sequence', 'Name', 'Description', 'Status', 'Outcome'],
                    OrderBy: 'Sequence ASC',
                    ResultType: 'simple',
                    MaxRows: 1000,
                },
                contextUser,
            ),
            rv.RunView<Pick<mjBizAppsTasksMeetingAttendeeEntity, 'ID' | 'PersonID' | 'Person' | 'DisplayName' | 'Email' | 'Role' | 'AttendanceStatus'>>(
                {
                    EntityName: MEETING_ATTENDEE_ENTITY,
                    ExtraFilter: `MeetingID = '${meetingId}'`,
                    Fields: ['ID', 'PersonID', 'Person', 'DisplayName', 'Email', 'Role', 'AttendanceStatus'],
                    ResultType: 'simple',
                    MaxRows: 1000,
                },
                contextUser,
            ),
        ]);

        const runner = options.promptRunner ?? this.defaultRunner;
        const drafted = await runner(
            {
                meeting,
                promptId,
                promptName: DEFAULT_MEETING_NOTES_PROMPT_NAME,
                agendaItems: agendaRes.Success ? agendaRes.Results : [],
                attendees: attendeeRes.Success ? attendeeRes.Results : [],
                transcript: cleanTranscript,
            },
            contextUser,
        );

        const proposals = parseProposedTasks(
            JSON.stringify(
                (drafted.proposedTasks ?? []).map((p, index) => ({
                    id: p.id ?? `proposal-${index + 1}`,
                    title: p.title,
                    description: p.description ?? null,
                    assigneePersonId: p.assigneePersonId ?? null,
                    assigneeName: p.assigneeName ?? null,
                    dueAt: p.dueAt ?? null,
                    agendaItemId: p.agendaItemId ?? options.agendaItemId ?? null,
                    status: 'Pending',
                    taskId: null,
                })),
            ),
        );

        const authorPersonId = options.authorPersonId ?? (await personIdForUser(this.provider, contextUser)) ?? meeting.OrganizerPersonID;
        const note = await this.provider.GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(MEETING_NOTE_ENTITY, contextUser);
        note.NewRecord();
        note.MeetingID = meeting.ID;
        note.AgendaItemID = options.agendaItemId ?? null;
        note.Kind = options.kind ?? 'Summary';
        note.Title = options.title ?? drafted.title ?? `${meeting.Name} — AI Notes`;
        note.Body = drafted.summary.trim();
        note.Source = 'AI';
        note.Status = 'Draft';
        note.AuthorPersonID = authorPersonId;
        note.AIPromptRunID = drafted.promptRunId ?? null;
        note.ProposedTasks = proposals.length ? serializeProposedTasks(proposals) : null;

        if (!(await note.Save())) {
            throw new Error(`The AI meeting note was not saved: ${entityFailure(note)}`);
        }
        return note;
    }

    /**
     * Accepts one proposed task on a note: files an `ACTION_ITEM` task, assigns the person when present, links the task
     * to the agenda item or meeting through `TaskLink`, and records the created `taskId` on the note's `ProposedTasks`.
     */
    async acceptProposedTask(
        noteId: string,
        proposalId: string,
        contextUser: UserInfo,
        overrides: AcceptProposedTaskOverrides = {},
    ): Promise<AcceptedProposedTaskResult> {
        const note = await this.provider.GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(MEETING_NOTE_ENTITY, contextUser);
        if (!(await note.Load(noteId))) {
            throw new Error('The meeting note was not found, or you may not see it.');
        }

        const proposals = parseProposedTasks(note.ProposedTasks);
        const existing = proposals.find((p) => p.id.toLowerCase() === proposalId.trim().toLowerCase());
        if (!existing) throw new Error(`Proposed task "${proposalId}" was not found on this note.`);
        if (existing.status === 'Dismissed') {
            throw new Error(`Proposed task "${existing.title}" was already dismissed.`);
        }
        if (existing.status === 'Accepted' && existing.taskId) {
            throw new Error(`Proposed task "${existing.title}" was already accepted as task ${existing.taskId}.`);
        }

        const typeRes = await RunView.FromMetadataProvider(this.provider).RunView<{ ID: string }>(
            {
                EntityName: TASK_TYPES_ENTITY,
                ExtraFilter: `Code = '${ACTION_ITEM_CODE}'`,
                Fields: ['ID'],
                ResultType: 'simple',
                MaxRows: 1,
            },
            contextUser,
        );
        const actionTypeId = typeRes.Success ? typeRes.Results[0]?.ID : undefined;
        if (!actionTypeId) {
            throw new Error('The Action Item task type (ACTION_ITEM) is not installed.');
        }

        const createdByPersonId =
            overrides.createdByPersonId ??
            (await personIdForUser(this.provider, contextUser)) ??
            note.AuthorPersonID ??
            null;

        const dueAtRaw = overrides.dueAt !== undefined ? overrides.dueAt : existing.dueAt;
        const dueAt = dueAtRaw instanceof Date ? dueAtRaw : dueAtRaw ? new Date(dueAtRaw) : null;

        const task = await this.provider.GetEntityObject<TaskEntity>(TASKS_ENTITY, contextUser);
        task.NewRecord();
        task.Name = (overrides.title ?? existing.title).trim();
        task.Description = overrides.description !== undefined ? overrides.description : existing.description;
        task.TypeID = actionTypeId;
        task.Status = 'Open';
        task.Priority = overrides.priority ?? 'Medium';
        task.PercentComplete = 0;
        task.DueAt = dueAt && !Number.isNaN(dueAt.getTime()) ? dueAt : null;
        task.CreatedByPersonID = createdByPersonId;
        if (!(await task.Save())) {
            throw new Error(`The action item task was not saved: ${entityFailure(task)}`);
        }

        const targetAgendaItemId =
            overrides.agendaItemId !== undefined ? overrides.agendaItemId : (existing.agendaItemId ?? note.AgendaItemID);
        const targetEntityName = targetAgendaItemId ? MEETING_AGENDA_ITEM_ENTITY : MEETING_ENTITY;
        const targetRecordId = targetAgendaItemId ?? note.MeetingID;
        const targetEntity = this.provider.Entities.find((e) => e.Name === targetEntityName);
        if (targetEntity) {
            const link = await this.provider.GetEntityObject<mjBizAppsTasksTaskLinkEntity>(TASK_LINKS_ENTITY, contextUser);
            link.NewRecord();
            link.TaskID = task.ID;
            link.EntityID = targetEntity.ID;
            link.RecordID = targetRecordId;
            link.Description = 'Action item accepted from meeting notes';
            if (!(await link.Save())) {
                throw new Error(`The task link was not saved: ${entityFailure(link)}`);
            }
        }

        const assigneePersonId =
            overrides.assigneePersonId !== undefined ? overrides.assigneePersonId : existing.assigneePersonId;
        if (assigneePersonId) {
            const peopleEntity = this.provider.Entities.find((e) => e.Name === PEOPLE_ENTITY);
            if (peopleEntity) {
                const assignment = await this.provider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(
                    'MJ_BizApps_Tasks: Task Assignments',
                    contextUser,
                );
                assignment.NewRecord();
                assignment.TaskID = task.ID;
                assignment.AssigneeEntityID = peopleEntity.ID;
                assignment.AssigneeRecordID = assigneePersonId;
                assignment.AssignedByPersonID = createdByPersonId;
                if (!(await assignment.Save())) {
                    throw new Error(`The task assignment was not saved: ${entityFailure(assignment)}`);
                }
            }
        }

        const updatedProposals = markProposedTaskAccepted(proposals, proposalId, task.ID);
        note.ProposedTasks = serializeProposedTasks(updatedProposals);
        if (!(await note.Save())) {
            throw new Error(`The note's proposed tasks were not updated: ${entityFailure(note)}`);
        }

        const acceptedProposal = updatedProposals.find((p) => p.id.toLowerCase() === proposalId.trim().toLowerCase())!;
        return { note, task, proposal: acceptedProposal };
    }

    /** Dismisses one proposed task on a note so it will not be filed. */
    async dismissProposedTask(
        noteId: string,
        proposalId: string,
        contextUser: UserInfo,
    ): Promise<{ note: mjBizAppsTasksMeetingNoteEntity; proposal: ProposedTask }> {
        const note = await this.provider.GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(MEETING_NOTE_ENTITY, contextUser);
        if (!(await note.Load(noteId))) {
            throw new Error('The meeting note was not found, or you may not see it.');
        }
        const proposals = parseProposedTasks(note.ProposedTasks);
        const updatedProposals = markProposedTaskDismissed(proposals, proposalId);
        note.ProposedTasks = serializeProposedTasks(updatedProposals);
        if (!(await note.Save())) {
            throw new Error(`The note's proposed tasks were not updated: ${entityFailure(note)}`);
        }
        const dismissedProposal = updatedProposals.find((p) => p.id.toLowerCase() === proposalId.trim().toLowerCase())!;
        return { note, proposal: dismissedProposal };
    }
}

