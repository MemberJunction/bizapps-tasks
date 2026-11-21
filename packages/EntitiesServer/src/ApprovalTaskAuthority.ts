/**
 * Who may put someone on an approval task, close one, or say who asked for it — the pure rules
 * (bizapps-tasks#209).
 *
 * {@link TaskDecisionRefusal} (./TaskDecisionAuthority.ts) says who may DECIDE an approval task: an
 * active assignee who is not the person recorded as its creator. Three writes used to step around
 * that rule without recording a decision it could check:
 *
 *   1. Creating an assignment. Create was never checked, so anyone allowed to create a Task
 *      Assignment could make themselves an assignee of any approval and then decide it.
 *   2. Changing the task's status. Timesheets approve on `Status = 'Completed'`, a type's
 *      OnComplete action runs on it, and a task raised for a workflow step or an agent's question
 *      answers it when it closes, so anyone allowed to update a task could produce an outcome
 *      without deciding anything.
 *   3. Naming someone else as the creator when creating the task. The no-self-approval rule
 *      compares the decider with `Task.CreatedByPersonID`, so a requester who named another person
 *      was no longer "the requester".
 *
 * The rules here close those. They apply to approval-type tasks (`TaskType.IsApproval`) whatever
 * the `PreventSelfApproval` setting says; the creator rule applies to every task, because a task's
 * type can change after it is created.
 *
 * "The reassign right" below is the existing `ApprovalReassignRoles` setting, read the way it has
 * always been read: while it names no role, everyone holds it.
 *
 * Kept free of MJ so each rule is unit-tested on its own; TaskAssignmentEntityServer and
 * TaskEntityServer gather the facts.
 */

/** The statuses that close an approval task. */
export type ApprovalClosingStatus = 'Completed' | 'Cancelled';

export const SELF_ASSIGN_REFUSAL = 'You cannot assign an approval to yourself. Someone else must approve it.';
export const ADD_ASSIGNEE_REFUSAL = 'This is an approval task, and your role does not allow adding an assignee to it.';
export const ADD_ASSIGNEE_NO_USER_REFUSAL = 'An approval assignment cannot be added without a signed-in user.';
export const COMPLETE_WITHOUT_DECISION_REFUSAL =
    'Only a person who may decide this approval can complete it, and no approving decision stands on it. To approve it, record your decision.';
export const WITHDRAW_REFUSAL =
    'Only the person who asked for this approval, a person it is assigned to, or a role allowed to reassign approvals can cancel it.';
export const WITHDRAW_NO_USER_REFUSAL = 'An approval task cannot be cancelled without a signed-in user.';
export const APPROVAL_TYPE_CHANGE_REFUSAL = "An approval task's type cannot be changed to a type that is not an approval.";
export const CREATOR_NOT_SELF_REFUSAL =
    'You cannot create a task in someone else\'s name. Leave its creator empty, or set it to yourself.';
export const CREATOR_AFTER_CREATE_REFUSAL = "A task's creator is recorded when the task is created and cannot be set afterwards.";
export const CREATOR_NO_USER_REFUSAL = "A task's creator cannot be checked without a signed-in user.";

// ---------------------------------------------------------------------------
// 1. Adding an assignee
// ---------------------------------------------------------------------------

/** What the add rule needs to know about a NEW assignment on an approval task. */
export interface ApprovalAssignmentAddFacts {
    /** Server code that chose the assignee itself vouched for this save (`AuthorizeApprovalAssignment`). */
    Sanctioned: boolean;
    /** The save runs as the MJ system user. */
    ActorIsSystem: boolean;
    /** Whether anyone is signed in at all. */
    HasActor: boolean;
    /** The assignee is one of the actor's People, the actor's own user row, or an MJ role the actor holds. */
    AssigneeIsActor: boolean;
    /** The actor is the person recorded as the task's creator. */
    ActorIsTaskCreator: boolean;
    /** The task is neither Completed nor Cancelled. */
    TaskIsOpen: boolean;
    /** The actor holds the reassign right (everyone does while `ApprovalReassignRoles` names no role). */
    ActorMayReassign: boolean;
}

/**
 * Why a new assignment must not be added to an approval task, or null when it may.
 *
 * The person who asked for an approval names who they are asking, while the request is still open:
 * every approval workflow creates its assignments as the requester. They may even name themselves,
 * because the decision rule refuses a requester their own request; that is what lets a requester who
 * is also the only approver (accounting's CFO building a batch, a reviewer saving an order) raise it.
 * Anyone else needs the reassign right, the same right as changing an assignee, and may never make
 * themselves an assignee: that was the way around "only an assignee decides".
 *
 * @returns a sentence for the person saving, or null.
 */
export function ApprovalAssignmentAddRefusal(facts: ApprovalAssignmentAddFacts): string | null {
    if (facts.Sanctioned || facts.ActorIsSystem) return null;
    if (!facts.HasActor) return ADD_ASSIGNEE_NO_USER_REFUSAL;
    const ownOpenRequest = facts.ActorIsTaskCreator && facts.TaskIsOpen;
    if (facts.AssigneeIsActor) return ownOpenRequest ? null : SELF_ASSIGN_REFUSAL;
    return ownOpenRequest || facts.ActorMayReassign ? null : ADD_ASSIGNEE_REFUSAL;
}

// ---------------------------------------------------------------------------
// 2. Closing the task
// ---------------------------------------------------------------------------

/** What the status rule needs to know about an approval task moving to a closing status. */
export interface ApprovalStatusChangeFacts {
    /** The status the task is moving to. */
    NewStatus: ApprovalClosingStatus;
    /**
     * The status the decision standing on the task leads to: `Completed` for an approving outcome,
     * `Cancelled` for a rejecting one, null when no decision stands. The standing decision is the
     * one being saved with the task, else the latest one recorded.
     */
    DecidedStatus: ApprovalClosingStatus | null;
    /**
     * The actor could record a decision on the task themselves: {@link TaskDecisionRefusal} accepts
     * them with the self-approval guard on, whatever the `PreventSelfApproval` setting says. That is
     * an active assignee who did not ask for the approval (or holds `SelfApprovalExemptRole`).
     */
    ActorMayDecide: boolean;
    /** Server code withdrawing its own request vouched for this save (`AuthorizeApprovalWithdrawal`). */
    WithdrawalSanctioned: boolean;
    /** The save runs as the MJ system user. */
    ActorIsSystem: boolean;
    /** Whether anyone is signed in at all. */
    HasActor: boolean;
    /** The actor is the person recorded as the task's creator. */
    ActorIsTaskCreator: boolean;
    /** The actor holds a Pending or InProgress assignment on the task. */
    ActorHoldsActiveAssignment: boolean;
    /** The actor holds the reassign right (everyone does while `ApprovalReassignRoles` names no role). */
    ActorMayReassign: boolean;
}

/**
 * Why an approval task must not move to `NewStatus`, or null when it may.
 *
 * A status that matches the standing decision is the decision path, and who may decide was checked
 * when the decision was saved. Without one:
 *   - `Completed` is allowed only for someone who could have recorded the decision themselves. A
 *     type's OnComplete action and a timesheet part read a completed approval as approved, so a
 *     completion must come from someone entitled to approve; nothing vouches around that, not even
 *     the system user. An assignee can still close what they were asked without approving or
 *     rejecting it (an agent's question answered with completion notes);
 *   - `Cancelled` is a withdrawal, not a rejection. The requester may withdraw their request, an
 *     active assignee may close what they could have rejected, and a holder of the reassign right
 *     or sanctioned server code (a workflow withdrawing its ask, a resubmitted timesheet) may too.
 *
 * @returns a sentence for the person saving, or null.
 */
export function ApprovalStatusChangeRefusal(facts: ApprovalStatusChangeFacts): string | null {
    if (facts.DecidedStatus === facts.NewStatus) return null;
    if (facts.NewStatus === 'Completed') return facts.ActorMayDecide ? null : COMPLETE_WITHOUT_DECISION_REFUSAL;
    if (facts.WithdrawalSanctioned || facts.ActorIsSystem) return null;
    if (!facts.HasActor) return WITHDRAW_NO_USER_REFUSAL;
    const mayWithdraw = facts.ActorIsTaskCreator || facts.ActorHoldsActiveAssignment || facts.ActorMayReassign;
    return mayWithdraw ? null : WITHDRAW_REFUSAL;
}

/** What the type rule needs to know about a saved task whose type is changing. */
export interface ApprovalTypeChangeFacts {
    /** The type the task had was an approval type. */
    WasApprovalType: boolean;
    /** The type the task is getting is an approval type. */
    IsApprovalType: boolean;
    /** The save runs as the MJ system user. */
    ActorIsSystem: boolean;
}

/**
 * Why a saved task's type must not change, or null when it may. An approval task that became an
 * ordinary task could be completed by anyone, and whatever reads its status as an outcome (a
 * timesheet part, a workflow step) would still read it. So it stays an approval.
 *
 * @returns a sentence for the person saving, or null.
 */
export function ApprovalTypeChangeRefusal(facts: ApprovalTypeChangeFacts): string | null {
    if (!facts.WasApprovalType || facts.IsApprovalType || facts.ActorIsSystem) return null;
    return APPROVAL_TYPE_CHANGE_REFUSAL;
}

// ---------------------------------------------------------------------------
// 3. Naming the creator
// ---------------------------------------------------------------------------

/** What the creator rule needs to know about a task whose creator is being recorded. */
export interface TaskCreatorFacts {
    /** The creator the caller is recording, when there is one. IDs are compared case-insensitively. */
    CreatorPersonID: string | null;
    /** The task already exists; its creator was empty until this save. */
    TaskIsSaved: boolean;
    /** Every Person bound to the acting user. */
    ActorPersonIDs: readonly string[];
    /** Server code creating the task for someone else vouched for this save (`AuthorizeCreatorOnBehalf`). */
    OnBehalfSanctioned: boolean;
    /** The save runs as the MJ system user. */
    ActorIsSystem: boolean;
    /** Whether anyone is signed in at all. */
    HasActor: boolean;
}

/**
 * Why the creator must not be recorded as given, or null when it may.
 *
 * A new task's creator is the person creating it. Only the system user and sanctioned server code
 * record someone else (a workflow raising a task for its owner, a manager submitting a report's
 * timesheet) or leave it empty, and only they record a creator on a task that was saved without
 * one: a user who could claim an existing request as their own would gain the requester's rights
 * over it.
 *
 * @returns a sentence for the person saving, or null.
 */
export function TaskCreatorRefusal(facts: TaskCreatorFacts): string | null {
    if (!facts.CreatorPersonID || facts.OnBehalfSanctioned || facts.ActorIsSystem) return null;
    if (!facts.HasActor) return CREATOR_NO_USER_REFUSAL;
    if (facts.TaskIsSaved) return CREATOR_AFTER_CREATE_REFUSAL;
    const creator = facts.CreatorPersonID.trim().toLowerCase();
    const isActor = facts.ActorPersonIDs.some((id) => id.trim().toLowerCase() === creator);
    return isActor ? null : CREATOR_NOT_SELF_REFUSAL;
}
