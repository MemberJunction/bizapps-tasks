import { describe, expect, it } from 'vitest';
import {
    APPROVAL_ROLE_NOTE,
    APPROVAL_SELF_NOTE,
    type AssignmentHoldingFact,
    type CallerAuthority,
    CallerMayOffboard,
    HoldingPermission,
    NOT_PERMITTED_NOTE,
    ParseStringArray,
    SelectRequested,
    SuccessorRecordFor,
    TASK_ASSIGNMENT_ENTITY_NAME,
    ToHolding,
} from '../offboarding/OffboardingRules.js';

const NOBODY: CallerAuthority = { IsLeaversSupervisor: false, HoldsSalesAdmin: false, IsCFOApprover: false, MayReassignApprovals: true };

const fact = (over: Partial<AssignmentHoldingFact> = {}): AssignmentHoldingFact => ({
    AssignmentID: 'A0000000-0000-0000-0000-000000000001',
    TaskID: 'D0000000-0000-0000-0000-000000000001',
    TaskName: 'Review contract',
    IsApproval: false,
    AssigneeEntityID: 'E0000000-0000-0000-0000-000000000001',
    AssigneeRecordID: 'C0000000-0000-0000-0000-000000000001',
    AssigneeKind: 'Person',
    ...over,
});

describe('CallerMayOffboard', () => {
    it('refuses a caller who is none of supervisor, Sales Admin or CFO approver', () => {
        expect(CallerMayOffboard(NOBODY)).toBe(false);
    });

    it.each([
        ['the supervisor', { IsLeaversSupervisor: true }],
        ['a Sales Admin', { HoldsSalesAdmin: true }],
        ['a CFO approver', { IsCFOApprover: true }],
    ])('allows %s', (_label, over) => {
        expect(CallerMayOffboard({ ...NOBODY, ...over })).toBe(true);
    });
});

describe('HoldingPermission', () => {
    it('says why a caller without authority may not move an item', () => {
        expect(HoldingPermission(false, NOBODY)).toEqual({ CanReassign: false, Note: NOT_PERMITTED_NOTE });
    });

    it('lets the supervisor move a plain task assignment', () => {
        expect(HoldingPermission(false, { ...NOBODY, IsLeaversSupervisor: true })).toEqual({ CanReassign: true, Note: null });
    });

    it('refuses an approval when the caller lacks an ApprovalReassignRoles role', () => {
        expect(HoldingPermission(true, { ...NOBODY, HoldsSalesAdmin: true, MayReassignApprovals: false })).toEqual({ CanReassign: false, Note: APPROVAL_ROLE_NOTE });
    });

    it('allows an approval with a note that it cannot go to the caller', () => {
        expect(HoldingPermission(true, { ...NOBODY, IsCFOApprover: true })).toEqual({ CanReassign: true, Note: APPROVAL_SELF_NOTE });
    });

    it('never lets the approval role alone grant the move', () => {
        expect(HoldingPermission(true, { ...NOBODY, MayReassignApprovals: true }).CanReassign).toBe(false);
    });
});

describe('ToHolding', () => {
    it('reports an approval task as APPROVAL_ASSIGNMENT in the Tasks domain', () => {
        const h = ToHolding(fact({ IsApproval: true }), { ...NOBODY, HoldsSalesAdmin: true });
        expect(h).toMatchObject({
            App: 'Tasks',
            Domain: 'Tasks',
            Kind: 'APPROVAL_ASSIGNMENT',
            KindLabel: 'Approval assignment',
            EntityName: TASK_ASSIGNMENT_ENTITY_NAME,
            RecordID: fact().AssignmentID,
            Label: 'Review contract',
            CanReassign: true,
        });
    });

    it('reports any other task as TASK_ASSIGNMENT', () => {
        expect(ToHolding(fact(), NOBODY).Kind).toBe('TASK_ASSIGNMENT');
    });
});

describe('SelectRequested', () => {
    const a = ToHolding(fact({ AssignmentID: 'A0000000-0000-0000-0000-00000000000A' }), NOBODY);
    const b = ToHolding(fact({ AssignmentID: 'A0000000-0000-0000-0000-00000000000B', IsApproval: true }), NOBODY);

    it('selects everything when nothing narrows the request', () => {
        expect(SelectRequested([a, b], null, null)).toEqual({ Selected: [a, b], Unknown: [] });
    });

    it('narrows by kind, case-insensitively', () => {
        expect(SelectRequested([a, b], ['approval_assignment'], null).Selected).toEqual([b]);
    });

    it('narrows by record ID regardless of case, and reports IDs the leaver does not hold', () => {
        const stranger = 'A0000000-0000-0000-0000-0000000000FF';
        const result = SelectRequested([a, b], null, [a.RecordID.toLowerCase(), stranger]);
        expect(result.Selected).toEqual([a]);
        expect(result.Unknown).toEqual([stranger]);
    });
});

describe('SuccessorRecordFor', () => {
    const targets = { UserID: 'U1', EmployeeID: null, PersonIDs: ['P1', 'P2'] };

    it('assigns a user assignment to the successor user', () => {
        expect(SuccessorRecordFor('User', targets)).toEqual({ RecordID: 'U1' });
    });

    it('assigns a person assignment to the successor primary Person', () => {
        expect(SuccessorRecordFor('Person', targets)).toEqual({ RecordID: 'P1' });
    });

    it('skips an employee assignment when the successor has no employee record', () => {
        expect(SuccessorRecordFor('Employee', targets)).toHaveProperty('Reason');
    });

    it('skips a person assignment when the successor has no Person', () => {
        expect(SuccessorRecordFor('Person', { ...targets, PersonIDs: [] })).toHaveProperty('Reason');
    });
});

describe('ParseStringArray', () => {
    it('treats a missing or blank value as no filter', () => {
        expect(ParseStringArray(null, 'Kinds')).toBeNull();
        expect(ParseStringArray('  ', 'Kinds')).toBeNull();
    });

    it('parses a JSON array of strings', () => {
        expect(ParseStringArray('["TASK_ASSIGNMENT"]', 'Kinds')).toEqual(['TASK_ASSIGNMENT']);
    });

    it.each(['not json', '{"a":1}', '[1, 2]'])('rejects %s', (value) => {
        expect(() => ParseStringArray(value, 'Kinds')).toThrow(/Kinds/);
    });
});
