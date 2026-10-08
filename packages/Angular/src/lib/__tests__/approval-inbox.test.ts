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
