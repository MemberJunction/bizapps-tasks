import { describe, expect, it } from 'vitest';
import {
    ADD_ASSIGNEE_NO_USER_REFUSAL,
    ADD_ASSIGNEE_REFUSAL,
    APPROVAL_TYPE_CHANGE_REFUSAL,
    ApprovalAssignmentAddRefusal,
    ApprovalStatusChangeRefusal,
    ApprovalTypeChangeRefusal,
    COMPLETE_WITHOUT_DECISION_REFUSAL,
    CREATOR_AFTER_CREATE_REFUSAL,
    CREATOR_NO_USER_REFUSAL,
    CREATOR_NOT_SELF_REFUSAL,
    SELF_ASSIGN_REFUSAL,
    TaskCreatorRefusal,
    WITHDRAW_NO_USER_REFUSAL,
    WITHDRAW_REFUSAL,
    type ApprovalAssignmentAddFacts,
    type ApprovalStatusChangeFacts,
    type TaskCreatorFacts,
} from '../ApprovalTaskAuthority.js';

const ME = 'C0000000-0000-0000-0000-000000000001';
const SOMEONE_ELSE = 'C0000000-0000-0000-0000-000000000002';

describe('ApprovalAssignmentAddRefusal — who may put someone on an approval task', () => {
    /** A signed-in user with no standing on an open approval, adding somebody else. */
    const add = (over: Partial<ApprovalAssignmentAddFacts> = {}): string | null =>
        ApprovalAssignmentAddRefusal({
            Sanctioned: false,
            ActorIsSystem: false,
            HasActor: true,
            AssigneeIsActor: false,
            ActorIsTaskCreator: false,
            TaskIsOpen: true,
            ActorMayReassign: false,
            ...over,
        });

    it('refuses a user with no standing', () => {
        expect(add()).toBe(ADD_ASSIGNEE_REFUSAL);
    });

    it('refuses a user adding themselves, even with the reassign right', () => {
        expect(add({ AssigneeIsActor: true })).toBe(SELF_ASSIGN_REFUSAL);
        expect(add({ AssigneeIsActor: true, ActorMayReassign: true })).toBe(SELF_ASSIGN_REFUSAL);
    });

    it('lets a holder of the reassign right add someone else', () => {
        expect(add({ ActorMayReassign: true })).toBeNull();
    });

    it('lets the requester of an open request add anyone, themselves included', () => {
        expect(add({ ActorIsTaskCreator: true })).toBeNull();
        expect(add({ ActorIsTaskCreator: true, AssigneeIsActor: true })).toBeNull();
    });

    it('gives the requester nothing once the request is closed', () => {
        expect(add({ ActorIsTaskCreator: true, TaskIsOpen: false })).toBe(ADD_ASSIGNEE_REFUSAL);
        expect(add({ ActorIsTaskCreator: true, TaskIsOpen: false, AssigneeIsActor: true })).toBe(SELF_ASSIGN_REFUSAL);
        expect(add({ ActorIsTaskCreator: true, TaskIsOpen: false, ActorMayReassign: true })).toBeNull();
    });

    it('accepts sanctioned server code and the system user, whoever the assignee is', () => {
        expect(add({ Sanctioned: true, AssigneeIsActor: true })).toBeNull();
        expect(add({ ActorIsSystem: true, AssigneeIsActor: true })).toBeNull();
        expect(add({ Sanctioned: true, HasActor: false })).toBeNull();
    });

    it('refuses a save with nobody signed in', () => {
        expect(add({ HasActor: false, ActorMayReassign: true })).toBe(ADD_ASSIGNEE_NO_USER_REFUSAL);
    });
});

describe('ApprovalStatusChangeRefusal — how an approval task may close', () => {
    /** A signed-in user with no standing, and no decision on the task. */
    const close = (over: Partial<ApprovalStatusChangeFacts> & Pick<ApprovalStatusChangeFacts, 'NewStatus'>): string | null =>
        ApprovalStatusChangeRefusal({
            DecidedStatus: null,
            ActorMayDecide: false,
            WithdrawalSanctioned: false,
            ActorIsSystem: false,
            HasActor: true,
            ActorIsTaskCreator: false,
            ActorHoldsActiveAssignment: false,
            ActorMayReassign: false,
            ...over,
        });

    it('lets the status follow the standing decision, whoever saves it', () => {
        expect(close({ NewStatus: 'Completed', DecidedStatus: 'Completed' })).toBeNull();
        expect(close({ NewStatus: 'Cancelled', DecidedStatus: 'Cancelled' })).toBeNull();
        expect(close({ NewStatus: 'Completed', DecidedStatus: 'Completed', HasActor: false })).toBeNull();
    });

    it('refuses completing an approval with no decision for anyone who could not decide it', () => {
        expect(close({ NewStatus: 'Completed' })).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);
        // None of these is being entitled to approve: the requester, an assignee the decision rule
        // would refuse (ActorMayDecide says so), the reassign right, the system user, a vouched withdrawal.
        for (const standing of [
            { ActorIsTaskCreator: true },
            { ActorHoldsActiveAssignment: true },
            { ActorMayReassign: true },
            { ActorIsSystem: true },
            { WithdrawalSanctioned: true },
        ]) {
            expect(close({ NewStatus: 'Completed', ...standing })).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);
        }
    });

    it('lets someone who could record the decision themselves complete it without one', () => {
        expect(close({ NewStatus: 'Completed', ActorMayDecide: true })).toBeNull();
    });

    it('applies the same test when the standing decision rejected the approval', () => {
        expect(close({ NewStatus: 'Completed', DecidedStatus: 'Cancelled' })).toBe(COMPLETE_WITHOUT_DECISION_REFUSAL);
        expect(close({ NewStatus: 'Completed', DecidedStatus: 'Cancelled', ActorMayDecide: true })).toBeNull();
    });

    it('does not let being able to decide stand in for the right to withdraw', () => {
        expect(close({ NewStatus: 'Cancelled', ActorMayDecide: true })).toBe(WITHDRAW_REFUSAL);
    });

    it('refuses a user with no standing cancelling an approval', () => {
        expect(close({ NewStatus: 'Cancelled' })).toBe(WITHDRAW_REFUSAL);
    });

    it('lets the requester, an active assignee, or a holder of the reassign right withdraw it', () => {
        expect(close({ NewStatus: 'Cancelled', ActorIsTaskCreator: true })).toBeNull();
        expect(close({ NewStatus: 'Cancelled', ActorHoldsActiveAssignment: true })).toBeNull();
        expect(close({ NewStatus: 'Cancelled', ActorMayReassign: true })).toBeNull();
    });

    it('lets sanctioned server code and the system user withdraw it', () => {
        expect(close({ NewStatus: 'Cancelled', WithdrawalSanctioned: true, HasActor: false })).toBeNull();
        expect(close({ NewStatus: 'Cancelled', ActorIsSystem: true })).toBeNull();
    });

    it('treats cancelling an approved task as a withdrawal, not as following the decision', () => {
        expect(close({ NewStatus: 'Cancelled', DecidedStatus: 'Completed' })).toBe(WITHDRAW_REFUSAL);
        expect(close({ NewStatus: 'Cancelled', DecidedStatus: 'Completed', ActorIsTaskCreator: true })).toBeNull();
    });

    it('refuses a withdrawal with nobody signed in', () => {
        expect(close({ NewStatus: 'Cancelled', HasActor: false })).toBe(WITHDRAW_NO_USER_REFUSAL);
    });
});

describe('ApprovalTypeChangeRefusal — an approval stays an approval', () => {
    const change = (WasApprovalType: boolean, IsApprovalType: boolean, ActorIsSystem = false): string | null =>
        ApprovalTypeChangeRefusal({ WasApprovalType, IsApprovalType, ActorIsSystem });

    it('refuses turning an approval task into an ordinary one', () => {
        expect(change(true, false)).toBe(APPROVAL_TYPE_CHANGE_REFUSAL);
    });

    it('allows every other change of type', () => {
        expect(change(true, true)).toBeNull();
        expect(change(false, true)).toBeNull();
        expect(change(false, false)).toBeNull();
    });

    it('allows the system user', () => {
        expect(change(true, false, true)).toBeNull();
    });
});

describe('TaskCreatorRefusal — who a task may be created as', () => {
    /** A signed-in user naming a creator on a new task. */
    const creator = (over: Partial<TaskCreatorFacts> = {}): string | null =>
        TaskCreatorRefusal({
            CreatorPersonID: SOMEONE_ELSE,
            TaskIsSaved: false,
            ActorPersonIDs: [ME],
            OnBehalfSanctioned: false,
            ActorIsSystem: false,
            HasActor: true,
            ...over,
        });

    it('refuses naming someone else as the creator', () => {
        expect(creator()).toBe(CREATOR_NOT_SELF_REFUSAL);
        expect(creator({ ActorPersonIDs: [] })).toBe(CREATOR_NOT_SELF_REFUSAL);
    });

    it('accepts any of the user\'s own People, compared without regard to case', () => {
        expect(creator({ CreatorPersonID: ME })).toBeNull();
        expect(creator({ CreatorPersonID: ` ${ME.toLowerCase()} ` })).toBeNull();
        expect(creator({ CreatorPersonID: SOMEONE_ELSE, ActorPersonIDs: [ME, SOMEONE_ELSE] })).toBeNull();
    });

    it('has nothing to check when no creator is named', () => {
        expect(creator({ CreatorPersonID: null })).toBeNull();
        expect(creator({ CreatorPersonID: null, HasActor: false })).toBeNull();
    });

    it('accepts sanctioned server code and the system user recording someone else', () => {
        expect(creator({ OnBehalfSanctioned: true })).toBeNull();
        expect(creator({ ActorIsSystem: true })).toBeNull();
        expect(creator({ OnBehalfSanctioned: true, TaskIsSaved: true })).toBeNull();
    });

    it('refuses a user recording a creator on a task that was saved without one, even themselves', () => {
        expect(creator({ TaskIsSaved: true })).toBe(CREATOR_AFTER_CREATE_REFUSAL);
        expect(creator({ TaskIsSaved: true, CreatorPersonID: ME })).toBe(CREATOR_AFTER_CREATE_REFUSAL);
    });

    it('refuses a named creator with nobody signed in', () => {
        expect(creator({ HasActor: false })).toBe(CREATOR_NO_USER_REFUSAL);
    });
});
