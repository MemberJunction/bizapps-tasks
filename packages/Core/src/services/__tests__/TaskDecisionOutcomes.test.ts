/**
 * The decision-outcome table — the one fact several applications ask about.
 *
 * WHY THIS EXISTS
 * `TaskDecisionOutcomeCode` used to be a bare union, and bizapps-accounting answered two runtime
 * questions about it — "do I accept this code?" and "does it mean approved?" — by hand-copying the
 * literals into its own `Set`s. A `Set` holding a subset of a union is a legal value, so widening
 * the union here produced NO error there: `tsc` returned 0, the accounting approval gate stopped
 * counting the new outcome as approved, and a journal entry batch that a CFO had approved would
 * never have been sent to the ERP. Nothing would have said a word.
 *
 * So the table is now the source of truth and the union is derived from it. These tests hold the
 * properties that make that substitution safe — the ones a consumer is entitled to rely on.
 */
import { describe, expect, it } from 'vitest';
import {
    IsApprovalOutcome,
    IsTaskDecisionOutcomeCode,
    TaskDecisionOutcomeCodes,
    TaskDecisionOutcomes,
    type TaskDecisionOutcomeCode,
} from '../TaskOrchestrationService.js';

describe('the outcome table', () => {
    it('carries every seeded code', () => {
        // These three have TaskDecisionOutcome rows in the seed metadata. A code declared here with
        // no seeded row makes resolveOutcome throw at decision time, so the list is not free to grow
        // without a migration alongside it.
        expect([...TaskDecisionOutcomeCodes].sort()).toEqual(['Approved', 'ApprovedWithConditions', 'Rejected']);
    });

    it('classifies each one', () => {
        expect(IsApprovalOutcome('Approved')).toBe(true);
        expect(IsApprovalOutcome('ApprovedWithConditions')).toBe(true);
        expect(IsApprovalOutcome('Rejected')).toBe(false);
    });

    it('drives a terminal status for every outcome', () => {
        // statusForOutcome reads Status straight off this table. A missing entry would save a task
        // with `undefined` status — which is what the switch it replaced did once the union widened.
        for (const code of TaskDecisionOutcomeCodes) {
            expect(['Completed', 'Cancelled'], `${code} must drive a terminal status`)
                .toContain(TaskDecisionOutcomes[code].Status);
        }
    });

    it('cancels exactly the outcomes that are not approvals', () => {
        // The pairing consumers assume: approved ⇒ Completed, not approved ⇒ Cancelled. Asserted as
        // a property rather than three literals, so it still holds for an outcome added later.
        for (const code of TaskDecisionOutcomeCodes) {
            const entry = TaskDecisionOutcomes[code];
            expect(entry.Status, `${code}`).toBe(entry.IsApproval ? 'Completed' : 'Cancelled');
        }
    });
});

describe('validating unvalidated input', () => {
    it('accepts every declared code', () => {
        for (const code of TaskDecisionOutcomeCodes) expect(IsTaskDecisionOutcomeCode(code)).toBe(true);
    });

    it('rejects a code that is not declared', () => {
        expect(IsTaskDecisionOutcomeCode('Approve')).toBe(false);
        expect(IsTaskDecisionOutcomeCode('approved')).toBe(false); // codes are case-sensitive
    });

    it('rejects absent input rather than throwing', () => {
        // Callers pass this straight off a request body. `undefined` has to come back false, not
        // blow up inside the guard — accounting's operation relies on it to build its error message.
        expect(IsTaskDecisionOutcomeCode(undefined)).toBe(false);
        expect(IsTaskDecisionOutcomeCode(null)).toBe(false);
        expect(IsTaskDecisionOutcomeCode('')).toBe(false);
    });

    it('is not fooled by inherited Object properties', () => {
        // The guard is a property lookup on an object literal. Written as `code in TaskDecisionOutcomes`
        // or a truthy index, 'constructor' and 'toString' would both pass and reach resolveOutcome,
        // which would then fail against the database with a confusing "is the metadata seeded?".
        for (const inherited of ['constructor', 'toString', 'hasOwnProperty', '__proto__', 'valueOf']) {
            expect(IsTaskDecisionOutcomeCode(inherited), inherited).toBe(false);
        }
    });

    it('narrows the type once it passes', () => {
        const fromRequestBody: string = 'ApprovedWithConditions';
        if (IsTaskDecisionOutcomeCode(fromRequestBody)) {
            // Compiles only because the guard narrows string -> TaskDecisionOutcomeCode. This is the
            // cast that accounting used to perform blind (`input.Decision as TaskDecisionOutcomeCode`).
            const narrowed: TaskDecisionOutcomeCode = fromRequestBody;
            expect(IsApprovalOutcome(narrowed)).toBe(true);
        } else {
            expect.unreachable('a declared code must pass the guard');
        }
    });
});

describe('the derived code list', () => {
    it('stays in step with the table', () => {
        // TaskDecisionOutcomeCodes is what accounting joins into its "Expected ..." error message and
        // what any consumer iterates. If it could drift from the table, the message would name codes
        // the guard rejects.
        expect([...TaskDecisionOutcomeCodes].sort()).toEqual(Object.keys(TaskDecisionOutcomes).sort());
    });

    it('contains no duplicates', () => {
        expect(new Set(TaskDecisionOutcomeCodes).size).toBe(TaskDecisionOutcomeCodes.length);
    });
});
