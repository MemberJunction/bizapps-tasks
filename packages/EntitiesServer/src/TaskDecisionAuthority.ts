/**
 * Who may record a decision on an approval task — the pure rule (bc-aidp-next-golive#320 §3).
 *
 * The tasks app records a decision from anywhere that can save a Task Decision: the in-app approval
 * panel (which runs in the browser), the Tasks inbox, or another app's server code. Before this rule
 * nothing checked the decider, so anyone allowed to create a Task Decision could approve any task,
 * including one they asked for themselves.
 *
 * When the Tasks setting `PreventSelfApproval` is on, a decision on an approval-type task
 * (`TaskType.IsApproval`) is refused unless:
 *   1. the decision is attributed to the deciding user's own Person, or to nobody;
 *   2. the deciding user is one of the task's assignees — assigned through a Person bound to the user,
 *      or assigned as the user directly (accounting assigns its batch approver as an `MJ: Users` row);
 *   3. a named `TaskAssignmentID` is one of the decider's own assignments; and
 *   4. the decider is not the task's creator (`Task.CreatedByPersonID`), unless they hold the role
 *      the `SelfApprovalExemptRole` setting names.
 *
 * Off (the default), every decision is accepted as before. A non-approval task is never checked.
 *
 * Kept free of MJ so the rule is unit-tested on its own; TaskDecisionEntityServer gathers the facts.
 */

/** One assignment on the task being decided. */
export interface DecisionAssignmentFact {
    ID: string;
    AssigneeEntityID: string;
    AssigneeRecordID: string;
}

/** Everything the rule needs to decide. IDs are compared case-insensitively. */
export interface TaskDecisionFacts {
    /** The Tasks `PreventSelfApproval` setting. */
    PreventSelfApproval: boolean;
    /** Whether the task's type is an approval type. */
    IsApprovalTask: boolean;
    /** The user saving the decision. */
    DeciderUserID: string;
    /** Every Person bound to that user (the user's own People link and any People.LinkedUserID match). */
    DeciderPersonIDs: readonly string[];
    /** The decision's DecidedByPersonID, when set. */
    DecidedByPersonID: string | null;
    /** The decision's TaskAssignmentID, when set. */
    TaskAssignmentID: string | null;
    /** The task's CreatedByPersonID, when set. */
    TaskCreatedByPersonID: string | null;
    /** The task's assignments. */
    Assignments: readonly DecisionAssignmentFact[];
    /** Whether an assignment's AssigneeEntityID is People (or an IS-A subtype of it). */
    IsPeopleEntityID: (entityID: string) => boolean;
    /** The `MJ: Users` entity ID, for assignments made to a user directly. */
    UsersEntityID: string | null;
    /** Whether the decider holds the `SelfApprovalExemptRole` role. */
    DeciderIsExempt: boolean;
}

const same = (a: string | null | undefined, b: string | null | undefined): boolean =>
    !!a && !!b && a.trim().toLowerCase() === b.trim().toLowerCase();

/** The decider's own assignments on the task. */
export function DeciderAssignments(facts: TaskDecisionFacts): DecisionAssignmentFact[] {
    return facts.Assignments.filter((a) =>
        (facts.IsPeopleEntityID(a.AssigneeEntityID) && facts.DeciderPersonIDs.some((p) => same(p, a.AssigneeRecordID))) ||
        (same(a.AssigneeEntityID, facts.UsersEntityID) && same(a.AssigneeRecordID, facts.DeciderUserID)),
    );
}

/**
 * Why the decision must not be recorded, or null when it may.
 *
 * @returns a sentence for the person deciding, or null.
 */
export function TaskDecisionRefusal(facts: TaskDecisionFacts): string | null {
    if (!facts.PreventSelfApproval || !facts.IsApprovalTask) return null;

    if (facts.DecidedByPersonID && !facts.DeciderPersonIDs.some((p) => same(p, facts.DecidedByPersonID))) {
        return 'This decision names someone other than you as the person deciding. A decision can only be recorded as your own.';
    }

    const mine = DeciderAssignments(facts);
    if (mine.length === 0) {
        return 'Only a person this approval is assigned to can decide it, and it is not assigned to you.';
    }
    if (facts.TaskAssignmentID && !mine.some((a) => same(a.ID, facts.TaskAssignmentID))) {
        return 'This decision is recorded against an assignment that is not yours. Decide on your own assignment.';
    }

    if (!facts.DeciderIsExempt && facts.DeciderPersonIDs.some((p) => same(p, facts.TaskCreatedByPersonID))) {
        return 'You asked for this approval, so someone else must decide it. Nobody may approve their own request.';
    }
    return null;
}
