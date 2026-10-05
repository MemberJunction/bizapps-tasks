import { describe, expect, it } from 'vitest';
import { ApprovalTypePredicate } from '../components/approval-inbox/approval-type-predicate';

describe('ApprovalTypePredicate', () => {
    it('selects every IsApproval type by default', () => {
        expect(ApprovalTypePredicate(null)).toBe('IsApproval = 1');
    });

    it('selects one named type when given, escaping quotes', () => {
        expect(ApprovalTypePredicate("Owner's Sign-off")).toBe("Name = 'Owner''s Sign-off'");
    });
});
