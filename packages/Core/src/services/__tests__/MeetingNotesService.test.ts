import { describe, expect, it } from 'vitest';
import type { IMetadataProvider, UserInfo } from '@memberjunction/core';
import {
    MEETING_AGENDA_ITEM_ENTITY,
    MEETING_ATTENDEE_ENTITY,
    MEETING_ENTITY,
    MEETING_NOTE_ENTITY,
    MEETING_TYPE_ENTITY,
} from '../../meetings/entity-names.js';
import { PEOPLE_ENTITY } from '../../meetings/person-user.js';
import { parseProposedTasks } from '../../meetings/proposed-tasks.js';
import { MeetingNotesService } from '../MeetingNotesService.js';

const USER = { ID: 'user-ivy' } as unknown as UserInfo;
const PERSON_IVY = '11111111-1111-4111-8111-111111111111';
const PERSON_JUN = '22222222-2222-4222-8222-222222222222';
const MEETING_ID = '33333333-3333-4333-8333-333333333333';
const AGENDA_ITEM_ID = '44444444-4444-4444-8444-444444444444';

function buildFakeWorld() {
    const savedNotes = new Map<string, Record<string, unknown>>();
    const savedTasks: Array<Record<string, unknown>> = [];
    const savedLinks: Array<Record<string, unknown>> = [];
    const savedAssignments: Array<Record<string, unknown>> = [];
    let counter = 0;

    const provider = {
        Entities: [
            { ID: 'ent-meeting', Name: MEETING_ENTITY, ParentID: null },
            { ID: 'ent-item', Name: MEETING_AGENDA_ITEM_ENTITY, ParentID: null },
            { ID: 'ent-people', Name: PEOPLE_ENTITY, ParentID: null },
        ],
        GetEntityObject: async (entityName: string) => {
            if (entityName === MEETING_ENTITY) {
                return {
                    ID: MEETING_ID,
                    Name: 'Q4 Budget Review',
                    Description: 'Quarterly review',
                    StartsAt: new Date('2026-11-10T15:00:00Z'),
                    EndsAt: new Date('2026-11-10T16:00:00Z'),
                    TimeZone: 'America/Chicago',
                    TypeID: 'type-team',
                    OrganizerPersonID: PERSON_IVY,
                    Load: async (id: string) => id === MEETING_ID,
                };
            }
            if (entityName === MEETING_TYPE_ENTITY) {
                return {
                    ID: 'type-team',
                    NotesPromptID: 'prompt-custom-notes',
                    Load: async (id: string) => id === 'type-team',
                };
            }
            if (entityName === MEETING_NOTE_ENTITY) {
                const row: Record<string, unknown> = {
                    ID: '',
                    MeetingID: '',
                    AgendaItemID: null,
                    Kind: 'Summary',
                    Title: null,
                    Body: '',
                    Source: 'Manual',
                    Status: 'Draft',
                    AuthorPersonID: null,
                    AIPromptRunID: null,
                    ProposedTasks: null,
                    NewRecord() {
                        row.ID = `note-${++counter}`;
                    },
                    Load: async (id: string) => {
                        const existing = savedNotes.get(id);
                        if (!existing) return false;
                        const { Load: _l, Save: _s, NewRecord: _n, ...data } = existing;
                        Object.assign(row, data);
                        return true;
                    },
                    Save: async () => {
                        savedNotes.set(String(row.ID), { ...row });
                        return true;
                    },
                };
                return row;
            }
            if (entityName === 'MJ_BizApps_Tasks: Tasks') {
                const row: Record<string, unknown> = {
                    ID: '',
                    NewRecord() {
                        row.ID = `task-${++counter}`;
                    },
                    Save: async () => {
                        savedTasks.push({ ...row });
                        return true;
                    },
                };
                return row;
            }
            if (entityName === 'MJ_BizApps_Tasks: Task Links') {
                const row: Record<string, unknown> = {
                    ID: '',
                    NewRecord() {
                        row.ID = `link-${++counter}`;
                    },
                    Save: async () => {
                        savedLinks.push({ ...row });
                        return true;
                    },
                };
                return row;
            }
            if (entityName === 'MJ_BizApps_Tasks: Task Assignments') {
                const row: Record<string, unknown> = {
                    ID: '',
                    NewRecord() {
                        row.ID = `assign-${++counter}`;
                    },
                    Save: async () => {
                        savedAssignments.push({ ...row });
                        return true;
                    },
                };
                return row;
            }
            throw new Error(`Unexpected entity ${entityName}`);
        },
        RunView: async (params: { EntityName: string }) => {
            if (params.EntityName === MEETING_AGENDA_ITEM_ENTITY) {
                return {
                    Success: true,
                    Results: [
                        {
                            ID: AGENDA_ITEM_ID,
                            Sequence: 100,
                            Name: 'Variance Analysis',
                            Description: null,
                            Status: 'Done',
                            Outcome: 'Approved',
                        },
                    ],
                };
            }
            if (params.EntityName === MEETING_ATTENDEE_ENTITY) {
                return {
                    Success: true,
                    Results: [
                        {
                            ID: 'att-1',
                            PersonID: PERSON_JUN,
                            Person: 'Jun Park',
                            DisplayName: 'Jun Park',
                            Email: 'jun@example.com',
                            Role: 'Required',
                            AttendanceStatus: 'Present',
                        },
                    ],
                };
            }
            if (params.EntityName === PEOPLE_ENTITY) {
                return { Success: true, Results: [{ ID: PERSON_IVY }] };
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Types') {
                return { Success: true, Results: [{ ID: 'task-type-action-item' }] };
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Assignments') {
                return { Success: true, Results: [] };
            }
            return { Success: true, Results: [] };
        },
    } as unknown as IMetadataProvider;

    return { provider, savedNotes, savedTasks, savedLinks, savedAssignments };
}

describe('MeetingNotesService', () => {
    it('drafts an AI note with ProposedTasks from a transcript using a stub prompt runner, then accepts and dismisses proposals', async () => {
        const world = buildFakeWorld();
        const service = new MeetingNotesService(world.provider);

        const note = await service.draftFromTranscript(
            MEETING_ID,
            'Ivy opened the review. Jun agreed to circulate the Q4 variance sheet by Friday.',
            USER,
            {
                promptRunner: async (ctx) => {
                    expect(ctx.promptId).toBe('prompt-custom-notes');
                    expect(ctx.agendaItems).toHaveLength(1);
                    expect(ctx.attendees).toHaveLength(1);
                    return {
                        title: 'Q4 Budget Review — AI Summary',
                        summary: 'Reviewed Q4 variance and agreed on follow-ups.',
                        promptRunId: 'run-99',
                        proposedTasks: [
                            {
                                id: 'prop-1',
                                title: 'Circulate Q4 variance sheet',
                                description: 'Send to all attendees',
                                assigneePersonId: PERSON_JUN,
                                assigneeName: 'Jun Park',
                                dueAt: '2026-11-14T17:00:00.000Z',
                                agendaItemId: AGENDA_ITEM_ID,
                            },
                            {
                                id: 'prop-2',
                                title: 'Schedule optional follow-up',
                            },
                        ],
                    };
                },
            },
        );

        expect(note.Source).toBe('AI');
        expect(note.Status).toBe('Draft');
        expect(note.AIPromptRunID).toBe('run-99');

        const initialProposals = parseProposedTasks(note.ProposedTasks);
        expect(initialProposals).toHaveLength(2);
        expect(initialProposals[0].status).toBe('Pending');

        // Accept prop-1 -> files an ACTION_ITEM task, links to the agenda item, assigns Jun, and records taskId
        const accepted = await service.acceptProposedTask(note.ID, 'prop-1', USER);
        expect(accepted.task.Name).toBe('Circulate Q4 variance sheet');
        expect(accepted.task.TypeID).toBe('task-type-action-item');
        expect(accepted.proposal.status).toBe('Accepted');
        expect(accepted.proposal.taskId).toBe(accepted.task.ID);
        expect(world.savedLinks).toHaveLength(1);
        expect(world.savedLinks[0].EntityID).toBe('ent-item');
        expect(world.savedLinks[0].RecordID).toBe(AGENDA_ITEM_ID);
        expect(world.savedAssignments).toHaveLength(1);
        expect(world.savedAssignments[0].AssigneeRecordID).toBe(PERSON_JUN);

        // Dismiss prop-2 -> marks Dismissed and files no task
        const dismissed = await service.dismissProposedTask(note.ID, 'prop-2', USER);
        expect(dismissed.proposal.status).toBe('Dismissed');
        expect(dismissed.proposal.taskId).toBeNull();
        expect(world.savedTasks).toHaveLength(1);
    });

    it('uses the built-in fallback extractor when no custom prompt runner is passed', async () => {
        const world = buildFakeWorld();
        const service = new MeetingNotesService(world.provider);

        const note = await service.draftFromTranscript(
            MEETING_ID,
            'Discussion went well.\nACTION: Jun Park to send updated slides\nTODO: Archive old deck',
            USER,
        );
        const proposals = parseProposedTasks(note.ProposedTasks);
        expect(proposals).toHaveLength(2);
        expect(proposals[0].title).toBe('Jun Park to send updated slides');
        expect(proposals[0].assigneePersonId).toBe(PERSON_JUN);
    });

    it('reads TranscriptFileID via GetFileContents and executes RunAIPrompt when no transcript string is passed', async () => {
        const world = buildFakeWorld();
        const executeGqlCalls: Array<{ query: string; variables?: Record<string, unknown> }> = [];
        const baseGetEntityObject = world.provider.GetEntityObject.bind(world.provider);
        (world.provider as unknown as { GetEntityObject: typeof world.provider.GetEntityObject }).GetEntityObject = async (
            entityName: string,
            user?: UserInfo,
        ) => {
            const obj = await baseGetEntityObject(entityName, user);
            if (entityName === MEETING_ENTITY) {
                (obj as unknown as Record<string, unknown>).TranscriptFileID = 'file-transcript-1';
            }
            return obj;
        };
        (world.provider as unknown as { ExecuteGQL: (query: string, variables?: Record<string, unknown>) => Promise<Record<string, unknown>> }).ExecuteGQL =
            async (query: string, variables?: Record<string, unknown>) => {
                executeGqlCalls.push({ query, variables });
                if (query.includes('GetFileContents')) {
                    return {
                        GetFileContents: {
                            Success: true,
                            Base64: Buffer.from('Ivy and Jun reviewed the Q4 forecast.').toString('base64'),
                        },
                    };
                }
                if (query.includes('RunAIPrompt')) {
                    return {
                        RunAIPrompt: {
                            success: true,
                            promptRunId: 'ai-run-777',
                            parsedResult: {
                                title: 'Q4 Forecast Notes',
                                summary: '### Key Outcomes\n- Forecast approved.',
                                proposedTasks: [
                                    {
                                        id: 'ai-prop-1',
                                        title: 'Publish approved forecast',
                                        assigneePersonId: PERSON_JUN,
                                        assigneeName: 'Jun Park',
                                    },
                                ],
                            },
                        },
                    };
                }
                return {};
            };

        const service = new MeetingNotesService(world.provider);
        const note = await service.draftFromTranscript(MEETING_ID, null, USER);
        expect(note.Title).toBe('Q4 Forecast Notes');
        expect(note.AIPromptRunID).toBe('ai-run-777');
        expect(executeGqlCalls).toHaveLength(2);
        const proposals = parseProposedTasks(note.ProposedTasks);
        expect(proposals).toHaveLength(1);
        expect(proposals[0].title).toBe('Publish approved forecast');

        // Idempotent accept: calling acceptProposedTask twice returns the same task without creating a duplicate
        const firstAccept = await service.acceptProposedTask(note.ID, 'ai-prop-1', USER);
        const secondAccept = await service.acceptProposedTask(note.ID, 'ai-prop-1', USER);
        expect(secondAccept.task.ID).toBe(firstAccept.task.ID);
        expect(world.savedTasks).toHaveLength(1);
    });
});

