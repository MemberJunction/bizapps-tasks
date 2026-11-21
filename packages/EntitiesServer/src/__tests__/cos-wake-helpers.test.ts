import { describe, it, expect, beforeEach, vi } from 'vitest';
import type { IMetadataProvider, UserInfo } from '@memberjunction/core';
import {
    ChiefOfStaffWakeRegistry,
    COS_MEETINGS_TRANSCRIPT_WORKSTREAM_KEY,
    COS_TASKS_INBOX_WORKSTREAM_KEY,
} from '@mj-biz-apps/tasks-core';

const { runViewMock } = vi.hoisted(() => ({
    runViewMock: vi.fn(),
}));

vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    return {
        ...actual,
        LogError: vi.fn(),
        Metadata: { Provider: {} },
        RunView: Object.assign(
            class {
                public RunView = runViewMock;
            },
            {
                FromMetadataProvider: () => ({ RunView: runViewMock }),
            },
        ),
    };
});

import {
    wakeAssigneesForTaskAssignment,
    wakeAssigneesForTaskUnblock,
    wakeMeetingParticipantsForTranscript,
} from '../cos-wake-helpers.js';

const PEOPLE_ENTITY_ID = 'e0000001-0000-4000-8000-000000000001';
const ROLES_ENTITY_ID = 'e0000002-0000-4000-8000-000000000002';
const AGENTS_ENTITY_ID = 'e0000003-0000-4000-8000-000000000003';
const USERS_ENTITY_ID = 'e0000004-0000-4000-8000-000000000004';

const USER_ALICE = '11111111-1111-4111-8111-111111111111';
const USER_BOB = '22222222-2222-4222-8222-222222222222';
const USER_CAROL = '33333333-3333-4333-8333-333333333333';
const PERSON_ALICE = 'a1111111-1111-4111-8111-111111111111';
const PERSON_BOB = 'b2222222-2222-4222-8222-222222222222';
const ROLE_FINANCE = 'f4444444-4444-4444-8444-444444444444';
const AGENT_1 = '99999999-9999-4999-8999-999999999999';
const TASK_1 = 'd1111111-1111-4111-8111-111111111111';
const TASK_2 = 'd2222222-2222-4222-8222-222222222222';
const TASK_3 = 'd3333333-3333-4333-8333-333333333333';
const ASSIGN_1 = 'c1111111-1111-4111-8111-111111111111';
const MEETING_1 = '77777777-7777-4777-8777-777777777777';
const NOTE_1 = '88888888-8888-4888-8888-888888888888';

const ACTING_ALICE = { ID: USER_ALICE, Name: 'Alice', Email: 'alice@example.com' } as UserInfo;

const mockProvider = {
    EntityByName: (name: string) => {
        if (name === 'MJ_BizApps_Common: People') return { ID: PEOPLE_ENTITY_ID, Name: name };
        if (name === 'MJ: Roles') return { ID: ROLES_ENTITY_ID, Name: name };
        if (name === 'MJ: AI Agents') return { ID: AGENTS_ENTITY_ID, Name: name };
        if (name === 'MJ: Users') return { ID: USERS_ENTITY_ID, Name: name };
        return undefined;
    },
    EntityByID: (id: string) => {
        if (id === PEOPLE_ENTITY_ID) return { ID: id, Name: 'MJ_BizApps_Common: People', ParentChain: [] };
        if (id === ROLES_ENTITY_ID) return { ID: id, Name: 'MJ: Roles', ParentChain: [] };
        if (id === AGENTS_ENTITY_ID) return { ID: id, Name: 'MJ: AI Agents', ParentChain: [] };
        if (id === USERS_ENTITY_ID) return { ID: id, Name: 'MJ: Users', ParentChain: [] };
        return undefined;
    },
} as unknown as IMetadataProvider;

describe('Server CoS coalesced wake helpers', () => {
    const dispatchSpy = vi.fn();

    beforeEach(() => {
        vi.clearAllMocks();
        dispatchSpy.mockResolvedValue(true);
        ChiefOfStaffWakeRegistry.Instance.RegisterHandler(dispatchSpy);
    });

    it('wakes human assignee on coalesced tasks-inbox key when assigned (UI, BulkUpdate, or CoS)', async () => {
        runViewMock.mockImplementation(async (p: { EntityName: string }) => {
            if (p.EntityName === 'MJ: Users') return { Success: true, Results: [{ ID: USER_BOB }] };
            if (p.EntityName === 'MJ_BizApps_Common: People') return { Success: true, Results: [{ ID: PERSON_BOB, LinkedUserID: USER_BOB }] };
            if (p.EntityName === 'MJ_BizApps_Tasks: Tasks') return { Success: true, Results: [{ Name: 'Close Q4 Books' }] };
            return { Success: true, Results: [] };
        });

        const count = await wakeAssigneesForTaskAssignment({
            taskID: TASK_1,
            taskAssignmentID: ASSIGN_1,
            assigneeEntityID: PEOPLE_ENTITY_ID,
            assigneeRecordID: PERSON_BOB,
            actingUser: ACTING_ALICE,
            provider: mockProvider,
        });

        expect(count).toBe(1);
        expect(dispatchSpy).toHaveBeenCalledTimes(1);
        expect(dispatchSpy).toHaveBeenCalledWith(
            expect.objectContaining({
                targetUserID: USER_BOB,
                workstreamKey: COS_TASKS_INBOX_WORKSTREAM_KEY,
                resumeState: expect.objectContaining({
                    eventType: 'TaskAssigned',
                    taskID: TASK_1,
                    taskName: 'Close Q4 Books',
                }),
            }),
        );
    });

    it('wakes role members (excluding acting user) on tasks-inbox and skips AI Agent assignees', async () => {
        runViewMock.mockImplementation(async (p: { EntityName: string }) => {
            if (p.EntityName === 'MJ: User Roles') {
                return { Success: true, Results: [{ UserID: USER_ALICE }, { UserID: USER_BOB }, { UserID: USER_CAROL }] };
            }
            if (p.EntityName === 'MJ_BizApps_Tasks: Tasks') return { Success: true, Results: [{ Name: 'Approve Invoice' }] };
            return { Success: true, Results: [] };
        });

        const roleCount = await wakeAssigneesForTaskAssignment({
            taskID: TASK_1,
            taskAssignmentID: ASSIGN_1,
            assigneeEntityID: ROLES_ENTITY_ID,
            assigneeRecordID: ROLE_FINANCE,
            actingUser: ACTING_ALICE,
            provider: mockProvider,
        });
        expect(roleCount).toBe(2);
        expect(dispatchSpy).toHaveBeenCalledTimes(2);
        expect(dispatchSpy.mock.calls.map((c) => c[0].targetUserID).sort()).toEqual([USER_BOB, USER_CAROL]);

        dispatchSpy.mockClear();
        const agentCount = await wakeAssigneesForTaskAssignment({
            taskID: TASK_1,
            taskAssignmentID: ASSIGN_1,
            assigneeEntityID: AGENTS_ENTITY_ID,
            assigneeRecordID: AGENT_1,
            actingUser: ACTING_ALICE,
            provider: mockProvider,
        });
        expect(agentCount).toBe(0);
        expect(dispatchSpy).not.toHaveBeenCalled();
    });

    it('coalesces multiple newly unblocked downstream tasks for the same user into ONE tasks-inbox wake', async () => {
        runViewMock.mockImplementation(async (p: { EntityName: string; ExtraFilter?: string }) => {
            if (p.EntityName === 'MJ_BizApps_Tasks: Task Dependencies') {
                if (p.ExtraFilter?.includes('DependsOnTaskID')) {
                    return { Success: true, Results: [{ TaskID: TASK_2 }, { TaskID: TASK_3 }] };
                }
                return {
                    Success: true,
                    Results: [
                        { TaskID: TASK_2, DependsOnTaskID: TASK_1 },
                        { TaskID: TASK_3, DependsOnTaskID: TASK_1 },
                    ],
                };
            }
            if (p.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                return {
                    Success: true,
                    Results: [
                        { ID: TASK_2, Name: 'Deploy API', Status: 'Blocked' },
                        { ID: TASK_3, Name: 'Publish Docs', Status: 'Open' },
                    ],
                };
            }
            if (p.EntityName === 'MJ_BizApps_Tasks: Task Assignments') {
                return {
                    Success: true,
                    Results: [
                        { TaskID: TASK_2, AssigneeEntityID: PEOPLE_ENTITY_ID, AssigneeRecordID: PERSON_BOB },
                        { TaskID: TASK_3, AssigneeEntityID: PEOPLE_ENTITY_ID, AssigneeRecordID: PERSON_BOB },
                    ],
                };
            }
            if (p.EntityName === 'MJ: Users') return { Success: true, Results: [{ ID: USER_BOB }] };
            if (p.EntityName === 'MJ_BizApps_Common: People') return { Success: true, Results: [{ ID: PERSON_BOB, LinkedUserID: USER_BOB }] };
            return { Success: true, Results: [] };
        });

        const count = await wakeAssigneesForTaskUnblock({
            taskID: TASK_1,
            taskName: 'Approve Release Spec',
            oldStatus: 'InProgress',
            newStatus: 'Completed',
            actingUser: ACTING_ALICE,
            provider: mockProvider,
        });

        expect(count).toBe(1);
        expect(dispatchSpy).toHaveBeenCalledTimes(1);
        expect(dispatchSpy).toHaveBeenCalledWith(
            expect.objectContaining({
                targetUserID: USER_BOB,
                workstreamKey: COS_TASKS_INBOX_WORKSTREAM_KEY,
                resumeState: expect.objectContaining({
                    eventType: 'TaskUnblocked',
                    unblockedCount: 2,
                    completedDependencyTaskID: TASK_1,
                }),
            }),
        );
    });

    it('wakes assignee on tasks-inbox when a Blocked task transitions directly to InProgress', async () => {
        runViewMock.mockImplementation(async (p: { EntityName: string }) => {
            if (p.EntityName === 'MJ_BizApps_Tasks: Task Assignments') {
                return { Success: true, Results: [{ TaskID: TASK_2, AssigneeEntityID: PEOPLE_ENTITY_ID, AssigneeRecordID: PERSON_BOB }] };
            }
            if (p.EntityName === 'MJ: Users') return { Success: true, Results: [{ ID: USER_BOB }] };
            return { Success: true, Results: [] };
        });

        const count = await wakeAssigneesForTaskUnblock({
            taskID: TASK_2,
            taskName: 'Deploy API',
            oldStatus: 'Blocked',
            newStatus: 'InProgress',
            actingUser: ACTING_ALICE,
            provider: mockProvider,
        });

        expect(count).toBe(1);
        expect(dispatchSpy).toHaveBeenCalledWith(
            expect.objectContaining({
                targetUserID: USER_BOB,
                workstreamKey: COS_TASKS_INBOX_WORKSTREAM_KEY,
                resumeState: expect.objectContaining({
                    eventType: 'TaskUnblocked',
                    previousStatus: 'Blocked',
                    newStatus: 'InProgress',
                }),
            }),
        );
    });

    it('wakes meeting participants on meetings-transcript when completed and excludes acting user on AI note saves', async () => {
        runViewMock.mockImplementation(async (p: { EntityName: string }) => {
            if (p.EntityName === 'MJ_BizApps_Tasks: Meeting Attendees') {
                return {
                    Success: true,
                    Results: [
                        { PersonID: PERSON_ALICE, UserID: USER_ALICE },
                        { PersonID: PERSON_BOB, UserID: USER_BOB },
                    ],
                };
            }
            if (p.EntityName === 'MJ_BizApps_Tasks: Meetings') {
                return { Success: true, Results: [{ Name: 'Weekly Sync', OrganizerPersonID: PERSON_ALICE, TranscriptFileID: null }] };
            }
            if (p.EntityName === 'MJ: Users') return { Success: true, Results: [{ ID: USER_ALICE }] };
            return { Success: true, Results: [] };
        });

        const completedCount = await wakeMeetingParticipantsForTranscript({
            meetingID: MEETING_1,
            meetingName: 'Weekly Sync',
            organizerPersonID: PERSON_ALICE,
            eventType: 'MeetingCompleted',
            hasTranscriptFile: false,
            excludeActingUser: false,
            actingUser: ACTING_ALICE,
            provider: mockProvider,
        });
        expect(completedCount).toBe(2);
        expect(dispatchSpy).toHaveBeenCalledTimes(2);
        expect(dispatchSpy.mock.calls.every((c) => c[0].workstreamKey === COS_MEETINGS_TRANSCRIPT_WORKSTREAM_KEY)).toBe(true);

        dispatchSpy.mockClear();
        const aiNoteCount = await wakeMeetingParticipantsForTranscript({
            meetingID: MEETING_1,
            noteID: NOTE_1,
            eventType: 'MeetingNoteSaved',
            hasTranscriptFile: false,
            excludeActingUser: true,
            actingUser: ACTING_ALICE,
            provider: mockProvider,
        });
        expect(aiNoteCount).toBe(1);
        expect(dispatchSpy).toHaveBeenCalledWith(
            expect.objectContaining({
                targetUserID: USER_BOB,
                workstreamKey: COS_MEETINGS_TRANSCRIPT_WORKSTREAM_KEY,
                resumeState: expect.objectContaining({
                    eventType: 'MeetingNoteSaved',
                    noteID: NOTE_1,
                }),
            }),
        );
    });
});
