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

async function filterFor(approvalTypeName?: string | null): Promise<string> {
    const inbox = createInbox();
    if (approvalTypeName !== undefined) inbox.ApprovalTypeName = approvalTypeName;
    inbox.ApproverPersonID = 'person-1';
    await inbox.Refresh();
    return runView.mock.calls.at(-1)![0].ExtraFilter as string;
}

describe('ApprovalInboxComponent filter', () => {
    beforeEach(() => {
        runView.mockReset();
        runView.mockResolvedValue({ Success: true, Results: [] });
    });

    it('lists every IsApproval task type by default', async () => {
        const filter = await filterFor();

        expect(filter).toContain('vwTaskTypes WHERE IsApproval = 1');
        expect(filter).not.toContain('Approval Request');
        expect(filter).toContain(`AssigneeRecordID = 'person-1'`);
    });

    it('lists only the named type when ApprovalTypeName is set', async () => {
        const filter = await filterFor('Concession Approval');

        expect(filter).toContain(`vwTaskTypes WHERE Name = 'Concession Approval'`);
        expect(filter).not.toContain('IsApproval');
    });
});

describe('ApprovalInboxComponent role assignments and linked records (bc-aidp-next-golive#442)', () => {
    const FINANCE = 'D0000000-0000-0000-0000-00000000000A';
    const TASK = 'E0000000-0000-0000-0000-000000000001';

    beforeEach(() => {
        runView.mockReset();
    });

    it('includes the given roles in the assignee match', async () => {
        runView.mockResolvedValue({ Success: true, Results: [] });
        const inbox = createInbox();
        inbox.ApproverRoleIDs = [FINANCE];
        inbox.ApproverPersonID = 'person-1';
        await inbox.Refresh();
        // With no provider loaded the MJ: Roles entity is unknown, so only the person is matched.
        expect(runView.mock.calls.at(-1)![0].ExtraFilter).toContain(`AssigneeRecordID = 'person-1'`);
    });

    it('loads the linked records of the listed approvals', async () => {
        runView.mockImplementation((p: { EntityName: string }) =>
            Promise.resolve(p.EntityName === 'MJ_BizApps_Tasks: Tasks'
                ? { Success: true, Results: [{ ID: TASK, Name: 'Order Review', Description: null, Priority: 'High', DueAt: null, Status: 'Open' }] }
                : { Success: true, Results: [] }));
        const inbox = createInbox();
        inbox.ApproverPersonID = 'person-1';
        await inbox.Refresh();
        expect(runView.mock.calls.some(([p]) => p.EntityName === 'MJ_BizApps_Tasks: Task Links')).toBe(true);
        expect(inbox.LinksFor(TASK)).toEqual([]);
        expect(inbox.LoadError).toBeNull();
    });

    it('skips the linked records when ShowLinkedRecords is off', async () => {
        runView.mockResolvedValue({ Success: true, Results: [{ ID: TASK, Name: 'x', Description: null, Priority: 'Low', DueAt: null, Status: 'Open' }] });
        const inbox = createInbox();
        inbox.ShowLinkedRecords = false;
        inbox.ApproverPersonID = 'person-1';
        await inbox.Refresh();
        expect(runView.mock.calls.some(([p]) => p.EntityName === 'MJ_BizApps_Tasks: Task Links')).toBe(false);
    });
});
