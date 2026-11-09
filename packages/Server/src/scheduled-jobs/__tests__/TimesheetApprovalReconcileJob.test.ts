import { describe, it, expect, beforeEach, vi } from 'vitest';
import type { IMetadataProvider, IRunViewProvider, UserInfo } from '@memberjunction/core';
import type { ScheduledJobExecutionContext } from '@memberjunction/scheduling-engine';

const { runViewMock, applyOutcomeMock } = vi.hoisted(() => ({
    runViewMock: vi.fn(),
    applyOutcomeMock: vi.fn(),
}));

vi.mock('@memberjunction/global', () => ({
    RegisterClass: () => () => {},
    IsValidUUID: (v: string) =>
        typeof v === 'string' &&
        /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9-a-f]{4}-[0-9a-f]{12}$/i.test(v),
}));

vi.mock('@memberjunction/core', () => {
    class FakeValidationResult {
        public Success = true;
        public Errors: unknown[] = [];
    }
    return {
        ValidationResult: FakeValidationResult,
        Metadata: { Provider: {} },
        RunView: class {
            public RunView(...args: unknown[]): unknown {
                return runViewMock(...args);
            }
        },
        UserInfo: class {},
    };
});

vi.mock('@memberjunction/core-entities', () => ({
    MJScheduledJobEntity: class {},
}));

vi.mock('@memberjunction/scheduling-engine', () => ({
    BaseScheduledJob: class {
        public log(..._a: unknown[]): void {}
        public logError(..._a: unknown[]): void {}
    },
}));

vi.mock('@memberjunction/scheduling-base-types', () => ({}));

vi.mock('@mj-biz-apps/tasks-entities', () => ({}));

vi.mock('@mj-biz-apps/tasks-entities-server', () => ({
    ApplyTimesheetApprovalOutcomeForTask: (...args: unknown[]) => applyOutcomeMock(...args),
}));

import {
    ReconcileStaleTimesheetApprovals,
    TimesheetApprovalReconcileJob,
} from '../TimesheetApprovalReconcileJob.js';

const PART_1_ID = '11111111-1111-4111-8111-111111111111';
const PART_2_ID = '22222222-2222-4222-8222-222222222222';
const TS_1_ID = '33333333-3333-4333-8333-333333333333';
const TASK_1_ID = '44444444-4444-4444-8444-444444444444';
const TASK_2_ID = '55555555-5555-4555-8555-555555555555';

const fakeUser = { ID: '66666666-6666-4666-8666-666666666666' } as unknown as UserInfo;
const fakeMd = {} as unknown as IMetadataProvider;
const fakeRv = {} as unknown as IRunViewProvider;

describe('TimesheetApprovalReconcileJob & ReconcileStaleTimesheetApprovals', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('returns zero counts when no Pending parts exist', async () => {
        runViewMock.mockResolvedValueOnce({ Success: true, Results: [] });

        const summary = await ReconcileStaleTimesheetApprovals(fakeUser, 200, fakeMd, fakeRv);
        expect(summary.ScannedPendingCount).toBe(0);
        expect(summary.RepairedCount).toBe(0);
        expect(applyOutcomeMock).not.toHaveBeenCalled();
    });

    it('repairs Pending parts whose backing approval task is already Completed or Cancelled', async () => {
        runViewMock
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    { ID: PART_1_ID, TimesheetID: TS_1_ID, ApprovalTaskID: TASK_1_ID, Status: 'Pending' },
                    { ID: PART_2_ID, TimesheetID: TS_1_ID, ApprovalTaskID: TASK_2_ID, Status: 'Pending' },
                ],
            })
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: TASK_1_ID, Status: 'Completed' }],
            });

        applyOutcomeMock.mockResolvedValueOnce({
            Applied: true,
            TimesheetID: TS_1_ID,
            PartID: PART_1_ID,
            PartStatus: 'Approved',
            TimesheetStatus: 'Submitted',
        });

        const summary = await ReconcileStaleTimesheetApprovals(fakeUser, 200, fakeMd, fakeRv);
        expect(summary.ScannedPendingCount).toBe(2);
        expect(summary.RepairedCount).toBe(1);
        expect(summary.RepairedPartIDs).toEqual([PART_1_ID]);
        expect(summary.RepairedTimesheetIDs).toEqual([TS_1_ID]);
        expect(applyOutcomeMock).toHaveBeenCalledWith(TASK_1_ID, 'Completed', fakeUser, fakeMd, fakeRv);
    });

    it('Executes via ScheduledJob driver and formats notification content', async () => {
        runViewMock
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: PART_1_ID, TimesheetID: TS_1_ID, ApprovalTaskID: TASK_1_ID, Status: 'Pending' }],
            })
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: TASK_1_ID, Status: 'Cancelled' }],
            });

        applyOutcomeMock.mockResolvedValueOnce({
            Applied: true,
            TimesheetID: TS_1_ID,
            PartID: PART_1_ID,
            PartStatus: 'Rejected',
            TimesheetStatus: 'Rejected',
        });

        const job = new TimesheetApprovalReconcileJob();
        const ctx = { ContextUser: fakeUser } as unknown as ScheduledJobExecutionContext;
        const result = await job.Execute(ctx);
        expect(result.Success).toBe(true);
        expect(result.Details?.repairedCount).toBe(1);

        const notification = job.FormatNotification(ctx, result);
        expect(notification.Priority).toBe('Normal');
        expect(notification.Subject).toContain('1 part(s) repaired');
    });
});
