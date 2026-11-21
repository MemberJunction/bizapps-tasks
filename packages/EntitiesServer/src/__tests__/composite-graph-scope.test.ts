import { describe, it, expect } from 'vitest';
import type {
    mjBizAppsTasksTaskCheckInEntity,
    mjBizAppsTasksWorkReportEntity,
    mjBizAppsTasksWorkReportItemEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    EnterTaskCheckInGraphScope,
    EnterWorkReportGraphScope,
    FindInFlightParentWorkReportForItem,
    IsCheckInInParentTaskGraph,
} from '../composite-graph-scope.js';

describe('composite-graph-scope re-entrancy', () => {
    it('preserves in-flight WorkReport across nested Save() -> ValidateAsync() scopes until outermost exit', () => {
        const item = { ID: '22222222-2222-4222-8222-222222222222' } as mjBizAppsTasksWorkReportItemEntity;
        const report = {
            ID: '11111111-1111-4111-8111-111111111111',
            Items: { Items: [item] },
        } as mjBizAppsTasksWorkReportEntity;

        const exitSave = EnterWorkReportGraphScope(report);
        try {
            const exitValidate = EnterWorkReportGraphScope(report);
            try {
                expect(FindInFlightParentWorkReportForItem(report.ID, item)).toBe(report);
            } finally {
                exitValidate();
            }
            // Inner ValidateAsync exit must NOT evict the outer Save() scope!
            expect(FindInFlightParentWorkReportForItem(report.ID, item)).toBe(report);
        } finally {
            exitSave();
        }
        // After outermost Save() exits, scope is completely cleared
        expect(FindInFlightParentWorkReportForItem(report.ID, item)).toBeNull();
    });

    it('preserves in-flight Task check-ins across nested scopes until outermost exit', () => {
        const taskID = '33333333-3333-4333-8333-333333333333';
        const checkIn = { ID: '44444444-4444-4444-8444-444444444444' } as mjBizAppsTasksTaskCheckInEntity;

        const exitOuter = EnterTaskCheckInGraphScope(taskID, [checkIn]);
        try {
            const exitInner = EnterTaskCheckInGraphScope(taskID, [checkIn]);
            exitInner();
            // Calling exitInner twice must be idempotent and never under-decrement outer scope
            exitInner();
            expect(IsCheckInInParentTaskGraph(taskID, checkIn)).toBe(true);
        } finally {
            exitOuter();
        }
        expect(IsCheckInInParentTaskGraph(taskID, checkIn)).toBe(false);
    });
});
