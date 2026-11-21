import { describe, it, expect, beforeEach, vi } from 'vitest';
import type { UserInfo } from '@memberjunction/core';
import {
    ChiefOfStaffWakeRegistry,
    COS_MEETINGS_TRANSCRIPT_WORKSTREAM_KEY,
    COS_TASKS_INBOX_WORKSTREAM_KEY,
} from '../ChiefOfStaffWakeRegistry.js';

vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    return {
        ...actual,
        LogError: vi.fn(),
    };
});

const USER_A = '11111111-1111-4111-8111-111111111111';
const USER_B = '22222222-2222-4222-8222-222222222222';
const ACTING_USER = { ID: USER_A, Name: 'Alice', Email: 'alice@example.com' } as UserInfo;

describe('ChiefOfStaffWakeRegistry', () => {
    beforeEach(() => {
        ChiefOfStaffWakeRegistry.Instance.ClearHandler();
    });

    it('exports canonical coalesced workstream keys', () => {
        expect(COS_TASKS_INBOX_WORKSTREAM_KEY).toBe('tasks-inbox');
        expect(COS_MEETINGS_TRANSCRIPT_WORKSTREAM_KEY).toBe('meetings-transcript');
    });

    it('returns false when no handler is registered or targetUserID is invalid', async () => {
        expect(ChiefOfStaffWakeRegistry.Instance.HasHandler).toBe(false);
        const noHandler = await ChiefOfStaffWakeRegistry.Instance.Dispatch({
            targetUserID: USER_B,
            workstreamKey: COS_TASKS_INBOX_WORKSTREAM_KEY,
            wakeReason: 'Assigned task',
            resumeState: { eventType: 'TaskAssigned' },
            actingUser: ACTING_USER,
        });
        expect(noHandler).toBe(false);

        const spy = vi.fn().mockResolvedValue(true);
        ChiefOfStaffWakeRegistry.Instance.RegisterHandler(spy);
        expect(ChiefOfStaffWakeRegistry.Instance.HasHandler).toBe(true);

        const invalidTarget = await ChiefOfStaffWakeRegistry.Instance.Dispatch({
            targetUserID: 'not-a-uuid',
            workstreamKey: COS_TASKS_INBOX_WORKSTREAM_KEY,
            wakeReason: 'Assigned task',
            resumeState: { eventType: 'TaskAssigned' },
            actingUser: ACTING_USER,
        });
        expect(invalidTarget).toBe(false);
        expect(spy).not.toHaveBeenCalled();
    });

    it('invokes registered handler and catches errors safely', async () => {
        const spy = vi.fn().mockResolvedValueOnce(true).mockRejectedValueOnce(new Error('boom'));
        ChiefOfStaffWakeRegistry.Instance.RegisterHandler(spy);

        const ok = await ChiefOfStaffWakeRegistry.Instance.Dispatch({
            targetUserID: USER_B,
            workstreamKey: COS_TASKS_INBOX_WORKSTREAM_KEY,
            wakeReason: 'Task unblocked',
            resumeState: { eventType: 'TaskUnblocked' },
            actingUser: ACTING_USER,
        });
        expect(ok).toBe(true);
        expect(spy).toHaveBeenCalledTimes(1);

        const failed = await ChiefOfStaffWakeRegistry.Instance.Dispatch({
            targetUserID: USER_B,
            workstreamKey: COS_MEETINGS_TRANSCRIPT_WORKSTREAM_KEY,
            wakeReason: 'Meeting completed',
            resumeState: { eventType: 'MeetingCompleted' },
            actingUser: ACTING_USER,
        });
        expect(failed).toBe(false);
    });
});
