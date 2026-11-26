import '@angular/compiler';
import { describe, expect, it, vi, beforeEach } from 'vitest';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';

const { runView } = vi.hoisted(() => ({ runView: vi.fn() }));
vi.mock('@memberjunction/core', async (importOriginal) => ({
    ...(await importOriginal<typeof import('@memberjunction/core')>()),
    RunView: class {
        RunView = runView;
    },
}));

import { ApprovalInboxComponent } from '../components/approval-inbox/approval-inbox.component';

function createInbox(): ApprovalInboxComponent {
    const cdr = { markForCheck: vi.fn(), detach: vi.fn(), detectChanges: vi.fn(), checkNoChanges: vi.fn(), reattach: vi.fn() };
    const injector = Injector.create({ providers: [{ provide: ChangeDetectorRef, useValue: cdr }] });
    return runInInjectionContext(injector, () => new ApprovalInboxComponent());
}

const TASK = 'E0000000-0000-0000-0000-000000000001';

async function filterFor(approvalTypeName?: string | null): Promise<{ assignmentFilter: string; tasksFilter: string }> {
    const inbox = createInbox();
    if (approvalTypeName !== undefined) inbox.ApprovalTypeName = approvalTypeName;
    inbox.ApproverPersonID = 'person-1';
    await inbox.Refresh();
    const calls = runView.mock.calls.map(([p]) => p as { EntityName: string; ExtraFilter?: string });
    const assignmentCall = calls.find((c) => c.EntityName === 'MJ_BizApps_Tasks: Task Assignments');
    const tasksCall = calls.find((c) => c.EntityName === 'MJ_BizApps_Tasks: Tasks');
    return {
        assignmentFilter: assignmentCall?.ExtraFilter ?? '',
        tasksFilter: tasksCall?.ExtraFilter ?? '',
    };
}

describe('ApprovalInboxComponent filter', () => {
    beforeEach(() => {
        runView.mockReset();
        runView.mockImplementation((p: { EntityName: string }) =>
            Promise.resolve(
                p.EntityName === 'MJ_BizApps_Tasks: Task Assignments'
                    ? { Success: true, Results: [{ TaskID: TASK }] }
                    : { Success: true, Results: [] },
            ),
        );
    });

    it('lists every IsApproval task type by default using RLS-safe two-step lookup', async () => {
        const { assignmentFilter, tasksFilter } = await filterFor();

        expect(assignmentFilter).toContain(`AssigneeRecordID = 'person-1'`);
        expect(tasksFilter).toContain('vwTaskTypes WHERE IsApproval = 1');
        expect(tasksFilter).not.toContain('Approval Request');
        expect(tasksFilter).toContain(`ID IN ('${TASK}')`);
        expect(tasksFilter).not.toContain('vwTaskAssignments');
    });

    it('lists only the named type when ApprovalTypeName is set', async () => {
        const { tasksFilter } = await filterFor('Concession Approval');

        expect(tasksFilter).toContain(`vwTaskTypes WHERE Name = 'Concession Approval'`);
        expect(tasksFilter).not.toContain('IsApproval');
        expect(tasksFilter).not.toContain('vwTaskAssignments');
    });
});

describe('ApprovalInboxComponent role assignments and linked records (bc-aidp-next-golive#442)', () => {
    const FINANCE = 'D0000000-0000-0000-0000-00000000000A';

    beforeEach(() => {
        runView.mockReset();
    });

    it('includes the given roles in the assignee match via Task Assignments RunView', async () => {
        runView.mockResolvedValue({ Success: true, Results: [] });
        const inbox = createInbox();
        inbox.ApproverRoleIDs = [FINANCE];
        inbox.ApproverPersonID = 'person-1';
        await inbox.Refresh();
        // With no provider loaded the MJ: Roles entity is unknown, so only the person is matched.
        const firstCall = runView.mock.calls[0][0] as { EntityName: string; ExtraFilter?: string };
        expect(firstCall.EntityName).toBe('MJ_BizApps_Tasks: Task Assignments');
        expect(firstCall.ExtraFilter).toContain(`AssigneeRecordID = 'person-1'`);
        // Zero assigned tasks -> skips the Tasks RunView altogether.
        expect(runView.mock.calls.some(([p]) => p.EntityName === 'MJ_BizApps_Tasks: Tasks')).toBe(false);
    });

    it('loads the linked records of the listed approvals', async () => {
        runView.mockImplementation((p: { EntityName: string }) => {
            if (p.EntityName === 'MJ_BizApps_Tasks: Task Assignments') {
                return Promise.resolve({ Success: true, Results: [{ TaskID: TASK }] });
            }
            if (p.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                return Promise.resolve({
                    Success: true,
                    Results: [{ ID: TASK, Name: 'Order Review', Description: null, Priority: 'High', DueAt: null, Status: 'Open' }],
                });
            }
            return Promise.resolve({ Success: true, Results: [] });
        });
        const inbox = createInbox();
        inbox.ApproverPersonID = 'person-1';
        await inbox.Refresh();
        expect(runView.mock.calls.some(([p]) => p.EntityName === 'MJ_BizApps_Tasks: Task Links')).toBe(true);
        expect(inbox.LinksFor(TASK)).toEqual([]);
        expect(inbox.LoadError).toBeNull();
    });

    it('skips the linked records when ShowLinkedRecords is off', async () => {
        runView.mockImplementation((p: { EntityName: string }) => {
            if (p.EntityName === 'MJ_BizApps_Tasks: Task Assignments') {
                return Promise.resolve({ Success: true, Results: [{ TaskID: TASK }] });
            }
            if (p.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                return Promise.resolve({
                    Success: true,
                    Results: [{ ID: TASK, Name: 'x', Description: null, Priority: 'Low', DueAt: null, Status: 'Open' }],
                });
            }
            return Promise.resolve({ Success: true, Results: [] });
        });
        const inbox = createInbox();
        inbox.ShowLinkedRecords = false;
        inbox.ApproverPersonID = 'person-1';
        await inbox.Refresh();
        expect(runView.mock.calls.some(([p]) => p.EntityName === 'MJ_BizApps_Tasks: Task Links')).toBe(false);
    });
});
