/**
 * Offboarding holdings — the pure rules (bc-aidp-next-golive#297).
 *
 * When someone leaves, the open task assignments they hold move to a successor. These rules decide
 * who may move them, which of the leaver's assignments a request covers, and where each one goes.
 * OffboardingHoldingsService gathers the facts; the rules are kept free of MJ so they are unit-tested
 * on their own.
 *
 * Who may move a Tasks holding: the leaver's supervisor (the leaver's `MJ: Employees`.SupervisorID is
 * the caller's employee), a holder of the "Sales Admin" role, or the CFO approver of any accounting
 * company profile. On an approval task the assignment's own guard (TaskAssignmentEntityServer) also
 * applies: while the Tasks setting `ApprovalReassignRoles` names roles, only their holders may
 * reassign, and nobody may reassign an approval to themselves.
 */
import { NormalizeUUID } from '@memberjunction/global';

/** The entity every Tasks holding is a row of. */
export const TASK_ASSIGNMENT_ENTITY_NAME = 'MJ_BizApps_Tasks: Task Assignments';

/** Stable codes for the kinds of Tasks holdings. */
export const TASKS_OFFBOARDING_KIND = {
    TaskAssignment: 'TASK_ASSIGNMENT',
    ApprovalAssignment: 'APPROVAL_ASSIGNMENT',
} as const;
export type TasksOffboardingKind = (typeof TASKS_OFFBOARDING_KIND)[keyof typeof TASKS_OFFBOARDING_KIND];

const KIND_LABELS: Record<TasksOffboardingKind, string> = {
    TASK_ASSIGNMENT: 'Task assignment',
    APPROVAL_ASSIGNMENT: 'Approval assignment',
};

/** The role that, alongside the supervisor and CFO approvers, may move a leaver's items. */
export const SALES_ADMIN_ROLE = 'Sales Admin';

export const NOT_PERMITTED_NOTE = "Only the leaver's supervisor, a Sales Admin or a company's CFO approver can move this.";
export const APPROVAL_ROLE_NOTE = 'This is an approval, and your role is not one the Tasks ApprovalReassignRoles setting allows to reassign approvals.';
export const APPROVAL_SELF_NOTE = 'This is an approval: it cannot be moved to you.';
export const NOT_HELD_REASON = 'This is not an open task assignment held by the leaver.';
export const ALREADY_ASSIGNED_REASON = 'The successor is already assigned to this task.';

/** Which identity an assignment names its assignee by. Roles are shared queues, not a person's holdings. */
export type AssigneeKind = 'User' | 'Person' | 'Employee';

/** One holding as the List action returns it. */
export interface OffboardingHolding {
    App: 'Tasks';
    Domain: 'Tasks';
    Kind: TasksOffboardingKind;
    KindLabel: string;
    EntityName: string;
    RecordID: string;
    Label: string;
    CanReassign: boolean;
    Note: string | null;
}

/** An item the Reassign action did not move, and why. */
export interface OffboardingSkip {
    Kind: string;
    EntityName: string;
    RecordID: string;
    Reason: string;
}

/** What a listing knows about one open assignment of the leaver's. */
export interface AssignmentHoldingFact {
    AssignmentID: string;
    TaskID: string;
    TaskName: string;
    IsApproval: boolean;
    AssigneeEntityID: string;
    AssigneeRecordID: string;
    AssigneeKind: AssigneeKind;
}

/** What is known about the calling user. */
export interface CallerAuthority {
    /** The leaver's employee record names the caller's employee as supervisor. */
    IsLeaversSupervisor: boolean;
    HoldsSalesAdmin: boolean;
    IsCFOApprover: boolean;
    /** The caller may reassign approvals under `ApprovalReassignRoles` (true while the setting is empty). */
    MayReassignApprovals: boolean;
}

/** Whether the caller may move a leaver's items at all. */
export function CallerMayOffboard(authority: CallerAuthority): boolean {
    return authority.IsLeaversSupervisor || authority.HoldsSalesAdmin || authority.IsCFOApprover;
}

/** Whether the caller may move one holding, and the note that explains a no (or a limit). */
export function HoldingPermission(isApproval: boolean, authority: CallerAuthority): { CanReassign: boolean; Note: string | null } {
    if (!CallerMayOffboard(authority)) return { CanReassign: false, Note: NOT_PERMITTED_NOTE };
    if (!isApproval) return { CanReassign: true, Note: null };
    if (!authority.MayReassignApprovals) return { CanReassign: false, Note: APPROVAL_ROLE_NOTE };
    return { CanReassign: true, Note: APPROVAL_SELF_NOTE };
}

/** The holding the List action reports for an assignment. */
export function ToHolding(fact: AssignmentHoldingFact, authority: CallerAuthority): OffboardingHolding {
    const kind = fact.IsApproval ? TASKS_OFFBOARDING_KIND.ApprovalAssignment : TASKS_OFFBOARDING_KIND.TaskAssignment;
    return {
        App: 'Tasks',
        Domain: 'Tasks',
        Kind: kind,
        KindLabel: KIND_LABELS[kind],
        EntityName: TASK_ASSIGNMENT_ENTITY_NAME,
        RecordID: fact.AssignmentID,
        Label: fact.TaskName,
        ...HoldingPermission(fact.IsApproval, authority),
    };
}

/** The requested subset of the holdings, and the requested record IDs that are not among them. */
export function SelectRequested(
    holdings: readonly OffboardingHolding[],
    kinds: readonly string[] | null,
    recordIDs: readonly string[] | null,
): { Selected: OffboardingHolding[]; Unknown: string[] } {
    const kindSet = kinds ? new Set(kinds.map((k) => k.trim().toUpperCase())) : null;
    const idSet = recordIDs ? new Set(recordIDs.map((id) => NormalizeUUID(id.trim()))) : null;
    const selected = holdings.filter(
        (h) => (!kindSet || kindSet.has(h.Kind)) && (!idSet || idSet.has(NormalizeUUID(h.RecordID))),
    );
    const held = new Set(holdings.map((h) => NormalizeUUID(h.RecordID)));
    const unknown = (recordIDs ?? []).filter((id) => !held.has(NormalizeUUID(id.trim())));
    return { Selected: selected, Unknown: unknown };
}

/** The successor's record for each kind of assignee; null where they have none. */
export interface SuccessorTargets {
    UserID: string;
    EmployeeID: string | null;
    /** The successor's People, primary first. */
    PersonIDs: readonly string[];
}

/** The record the successor is assigned as, in the same entity the leaver was assigned through, or why not. */
export function SuccessorRecordFor(kind: AssigneeKind, targets: SuccessorTargets): { RecordID: string } | { Reason: string } {
    switch (kind) {
        case 'User':
            return { RecordID: targets.UserID };
        case 'Employee':
            return targets.EmployeeID ? { RecordID: targets.EmployeeID } : { Reason: 'The successor has no employee record, and this assignment is to an employee.' };
        case 'Person':
            return targets.PersonIDs[0] ? { RecordID: targets.PersonIDs[0] } : { Reason: 'The successor has no Person record, and this assignment is to a person.' };
    }
}

/**
 * Parses an optional JSON array of strings. Null when absent or blank.
 *
 * @throws when the value is not a JSON array of strings.
 */
export function ParseStringArray(value: string | null, name: string): string[] | null {
    if (value == null || value.trim() === '') return null;
    let parsed: unknown;
    try {
        parsed = JSON.parse(value);
    } catch {
        throw new Error(`${name} is not valid JSON.`);
    }
    if (!Array.isArray(parsed) || parsed.some((v) => typeof v !== 'string')) throw new Error(`${name} must be a JSON array of strings.`);
    return parsed as string[];
}
