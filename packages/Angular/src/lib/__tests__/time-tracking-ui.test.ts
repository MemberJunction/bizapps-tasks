import '@angular/compiler';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';

const { runViewMock, runViewsMock } = vi.hoisted(() => ({
    runViewMock: vi.fn(),
    runViewsMock: vi.fn(),
}));

vi.mock('@memberjunction/core', async (importOriginal) => ({
    ...(await importOriginal<typeof import('@memberjunction/core')>()),
    RunView: class {
        RunView = runViewMock;
        RunViews = runViewsMock;
    },
}));

import { TasksSettings } from '@mj-biz-apps/tasks-core';
import {
    ComputeTimerChipState,
    RunningTimerChipComponent,
} from '../components/running-timer-chip/running-timer-chip.component';
import {
    MyTimeComponent,
    ResolveGridCellAction,
    type MyTimeCellEntry,
} from '../components/my-time/my-time.component';
import { HasApprovalSubjectPanelRegistration } from '../components/approval-decision-panel/base-approval-subject-panel';
import '../components/approval-decision-panel/timesheet-part-approval-panel.component';

function createCdrMock(): ChangeDetectorRef {
    return {
        markForCheck: vi.fn(),
        detach: vi.fn(),
        detectChanges: vi.fn(),
        checkNoChanges: vi.fn(),
        reattach: vi.fn(),
    };
}

describe('MyTimeComponent — ResolveGridCellAction cell editing semantics (§8.4)', () => {
    const sampleEntry: MyTimeCellEntry = {
        ID: '11111111-1111-4111-8111-111111111111',
        TaskID: '22222222-2222-4222-8222-222222222222',
        WorkDate: '2026-11-02',
        DurationMinutes: 90,
        IsBillable: true,
        Notes: 'Initial work',
        Source: 'Manual',
        IsLocked: false,
        LockReason: null,
    };

    it('creates a manual entry when cell has 0 entries and user types a valid duration', () => {
        expect(ResolveGridCellAction([], '1h 30m')).toEqual({
            kind: 'create',
            durationMinutes: 90,
        });
        expect(ResolveGridCellAction([], '1.5')).toEqual({
            kind: 'create',
            durationMinutes: 90,
        });
        expect(ResolveGridCellAction([], '2:15')).toEqual({
            kind: 'create',
            durationMinutes: 135,
        });
    });

    it('returns no-op when cell has 0 entries and user clears or types 0', () => {
        expect(ResolveGridCellAction([], '')).toEqual({ kind: 'no-op' });
        expect(ResolveGridCellAction([], '0:00')).toEqual({ kind: 'no-op' });
    });

    it('returns invalid when user types an unparseable duration', () => {
        const res = ResolveGridCellAction([], 'abc');
        expect(res.kind).toBe('invalid');
    });

    it('updates the single entry when cell has 1 entry and user types a new duration', () => {
        expect(ResolveGridCellAction([sampleEntry], '2:00')).toEqual({
            kind: 'update',
            entryID: sampleEntry.ID,
            durationMinutes: 120,
        });
    });

    it('returns no-op when cell has 1 entry and user types the unchanged duration', () => {
        expect(ResolveGridCellAction([sampleEntry], '1:30')).toEqual({ kind: 'no-op' });
    });

    it('prompts delete confirmation when cell has 1 entry and user clears the cell', () => {
        expect(ResolveGridCellAction([sampleEntry], '')).toEqual({
            kind: 'confirm-delete',
            entryID: sampleEntry.ID,
        });
        expect(ResolveGridCellAction([sampleEntry], '0')).toEqual({
            kind: 'confirm-delete',
            entryID: sampleEntry.ID,
        });
    });

    it('opens the breakdown dialog when cell has 2 or more entries', () => {
        const secondEntry: MyTimeCellEntry = {
            ...sampleEntry,
            ID: '33333333-3333-4333-8333-333333333333',
            DurationMinutes: 30,
        };
        const res = ResolveGridCellAction([sampleEntry, secondEntry], '3:00');
        expect(res.kind).toBe('open-breakdown');
    });

    it('refuses edits when the period or entry is locked', () => {
        expect(ResolveGridCellAction([], '1:00', true).kind).toBe('locked');
        const lockedEntry: MyTimeCellEntry = {
            ...sampleEntry,
            IsLocked: true,
            LockReason: 'Used by Invoice Line',
        };
        expect(ResolveGridCellAction([lockedEntry], '2:00', false)).toEqual({
            kind: 'locked',
            reason: 'Used by Invoice Line',
        });
    });
});

describe('ComputeTimerChipState — elapsed time & long-running warning (§8.1)', () => {
    it('computes elapsed H:MM:SS and does not warn under 12 hours', () => {
        const startedAt = '2026-11-08T10:00:00.000Z';
        const nowMs = new Date('2026-11-08T11:35:09.000Z').getTime();
        const state = ComputeTimerChipState(startedAt, nowMs);

        expect(state.elapsedMinutes).toBe(95);
        expect(state.formattedWithSeconds).toBe('1:35:09');
        expect(state.isLongRunningWarning).toBe(false);
    });

    it('flags long-running timer warning at or above 720 minutes (12 hours)', () => {
        const startedAt = '2026-11-08T00:00:00.000Z';
        const nowMs = new Date('2026-11-08T12:00:00.000Z').getTime();
        const state = ComputeTimerChipState(startedAt, nowMs);

        expect(state.elapsedMinutes).toBe(720);
        expect(state.formattedWithSeconds).toBe('12:00:00');
        expect(state.isLongRunningWarning).toBe(true);
    });
});

describe('Feature gating by TimeTrackingEnabled setting (§8)', () => {
    beforeEach(() => {
        runViewMock.mockReset();
        runViewsMock.mockReset();
        vi.restoreAllMocks();
    });

    it('RunningTimerChipComponent stays inactive when TimeTrackingEnabled is false', async () => {
        vi.spyOn(TasksSettings, 'Load').mockResolvedValue(undefined);
        vi.spyOn(TasksSettings, 'TimeTrackingEnabled').mockReturnValue(false);

        const injector = Injector.create({
            providers: [{ provide: ChangeDetectorRef, useValue: createCdrMock() }],
        });
        const chip = runInInjectionContext(injector, () => new RunningTimerChipComponent());
        chip.PersonID = '11111111-1111-4111-8111-111111111111';
        await chip.Refresh();

        expect(chip.timeTrackingEnabled).toBe(false);
        expect(chip.activeTimer).toBeNull();
        expect(runViewMock).not.toHaveBeenCalled();
    });

    it('MyTimeComponent skips batch loading when TimeTrackingEnabled is false', async () => {
        vi.spyOn(TasksSettings, 'Load').mockResolvedValue(undefined);
        vi.spyOn(TasksSettings, 'TimeTrackingEnabled').mockReturnValue(false);

        const injector = Injector.create({
            providers: [{ provide: ChangeDetectorRef, useValue: createCdrMock() }],
        });
        const myTime = runInInjectionContext(injector, () => new MyTimeComponent());
        myTime.PersonID = '11111111-1111-4111-8111-111111111111';
        await myTime.Refresh();

        expect(myTime.timeTrackingEnabled).toBe(false);
        expect(runViewsMock).not.toHaveBeenCalled();
    });
});

describe('Approval subject panel registration (§8.5)', () => {
    it('registers TimesheetPartApprovalPanelComponent for MJ_BizApps_Tasks: Timesheet Approvals', () => {
        expect(HasApprovalSubjectPanelRegistration('MJ_BizApps_Tasks: Timesheet Approvals')).toBe(true);
        expect(HasApprovalSubjectPanelRegistration('NonExistent: Entity')).toBe(false);
    });
});
