import '@angular/compiler';
import { describe, expect, it, vi, beforeEach } from 'vitest';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';
import { TaskClosedError, TaskOrchestrationService } from '@mj-biz-apps/tasks-core';

const { runView } = vi.hoisted(() => ({ runView: vi.fn() }));
vi.mock('@memberjunction/core', async (importOriginal) => ({
    ...(await importOriginal<typeof import('@memberjunction/core')>()),
    RunView: class {
        RunView = runView;
    },
}));

import { ApprovalDecisionPanelComponent } from '../components/approval-decision-panel/approval-decision-panel.component';
import { ApprovalInboxComponent } from '../components/approval-inbox/approval-inbox.component';

function injector(): Injector {
    const cdr = { markForCheck: vi.fn(), detach: vi.fn(), detectChanges: vi.fn(), checkNoChanges: vi.fn(), reattach: vi.fn() };
    return Injector.create({ providers: [{ provide: ChangeDetectorRef, useValue: cdr }] });
}

const APPROVED = { ID: 'outcome-approved', Name: 'Approved', Code: 'Approved', IsTerminal: true };

/** A panel loaded for task-1 with Approved selected, as the user sees it before clicking. */
async function loadedPanel(): Promise<ApprovalDecisionPanelComponent> {
    const panel = runInInjectionContext(injector(), () => new ApprovalDecisionPanelComponent());
    panel.TaskID = 'task-1';
    await vi.waitFor(() => expect(panel.Loading).toBe(false));
    panel.SelectedOutcomeCode = 'Approved';
    return panel;
}

describe('ApprovalDecisionPanelComponent on a task closed after it loaded', () => {
    beforeEach(() => {
        vi.restoreAllMocks();
        runView.mockReset();
        runView.mockImplementation(async (params: { EntityName: string }) =>
            params.EntityName.endsWith('Task Decision Outcomes')
                ? { Success: true, Results: [APPROVED] }
                : { Success: true, Results: [{ Name: 'Approve batch' }] });
    });

    it('shows the refusal and emits TaskClosed instead of DecisionRecorded', async () => {
        vi.spyOn(TaskOrchestrationService.prototype, 'RecordDecision')
            .mockRejectedValue(new TaskClosedError('task-1', 'Cancelled'));
        const panel = await loadedPanel();
        const closed = vi.fn();
        const recorded = vi.fn();
        panel.TaskClosed.subscribe(closed);
        panel.DecisionRecorded.subscribe(recorded);

        await panel.Submit();

        expect(panel.SaveError).toContain('already Cancelled');
        expect(closed).toHaveBeenCalledWith('task-1');
        expect(recorded).not.toHaveBeenCalled();
    });

    it('does not emit TaskClosed for other failures', async () => {
        vi.spyOn(TaskOrchestrationService.prototype, 'RecordDecision')
            .mockRejectedValue(new Error('network down'));
        const panel = await loadedPanel();
        const closed = vi.fn();
        panel.TaskClosed.subscribe(closed);

        await panel.Submit();

        expect(panel.SaveError).toBe('network down');
        expect(closed).not.toHaveBeenCalled();
    });
});

describe('ApprovalInboxComponent.onTaskClosed', () => {
    it('reloads the list and keeps the panel open to show the refusal', async () => {
        runView.mockReset();
        runView.mockResolvedValue({ Success: true, Results: [] });
        const inbox = runInInjectionContext(injector(), () => new ApprovalInboxComponent());
        inbox.ApproverPersonID = 'person-1';
        await vi.waitFor(() => expect(inbox.Loading).toBe(false));
        inbox.SelectedApprovalID = 'task-1';
        runView.mockClear();

        inbox.onTaskClosed();
        await vi.waitFor(() => expect(inbox.Loading).toBe(false));

        expect(runView).toHaveBeenCalledOnce();
        expect(inbox.SelectedApprovalID).toBe('task-1');
    });
});
