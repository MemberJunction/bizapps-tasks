/**
 * How server code vouches for a write the approval rules would otherwise refuse (bizapps-tasks#209).
 *
 * Three rules refuse writes that a browser could use to step around who may decide an approval:
 * adding an assignee the caller has no right to add (or adding themselves), cancelling an approval
 * that is not theirs to withdraw, and recording someone else as a task's creator. Server workflows
 * do all three legitimately: a timesheet routes to approvers the server resolved, a workflow
 * withdraws its own ask, a task is raised for the workflow's owner. Such code calls one of these
 * on the record just before saving it:
 *
 * ```ts
 * const assignment = await provider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>('MJ_BizApps_Tasks: Task Assignments', user);
 * assignment.NewRecord();
 * // ...
 * SanctionApprovalAssignment(assignment);
 * await assignment.Save();
 * ```
 *
 * Each call covers ONE save of that one object, the idiom `TaskLinkEntityServer.AuthorizeHumanAskLink`
 * set. The flag lives on the server-side object and never travels: a browser's record is a
 * different class, and nothing a client sends can set it.
 *
 * Call them only where the server itself decided what is written (who is assigned, that the request
 * is withdrawn, who the task is for) — never to pass along a value a caller supplied.
 *
 * The functions find the method by shape rather than by class, so they work on whichever subclass
 * won the class factory (bizapps-collaboration registers its own above these) and need no import of
 * the classes themselves. They return false when the record is not a server-side tasks record: the
 * save then runs under whatever rules that class has.
 */
import type { BaseEntity } from '@memberjunction/core';

/** The sanction methods of `TaskAssignmentEntityServer`. */
interface ApprovalAssignmentSanction {
    AuthorizeApprovalAssignment(): void;
}

/** The sanction methods of `TaskEntityServer`. */
interface ApprovalTaskSanctions {
    AuthorizeApprovalWithdrawal(): void;
    AuthorizeCreatorOnBehalf(): void;
}

function hasMethod<K extends string>(entity: BaseEntity, name: K): entity is BaseEntity & Record<K, () => void> {
    return typeof (entity as Partial<Record<K, unknown>>)[name] === 'function';
}

/**
 * Lets the next save of a NEW task assignment put its assignee on an approval task, whoever is
 * saving and whoever the assignee is. For server code that chose the assignee itself.
 *
 * @returns false when `assignment` is not a server-side Task Assignment record.
 */
export function SanctionApprovalAssignment(assignment: BaseEntity): boolean {
    if (!hasMethod<keyof ApprovalAssignmentSanction>(assignment, 'AuthorizeApprovalAssignment')) return false;
    assignment.AuthorizeApprovalAssignment();
    return true;
}

/**
 * Lets the next save of an approval task move it to `Cancelled` with no rejecting decision, whoever
 * is saving. For server code withdrawing a request it raised. It never lets a task be `Completed`:
 * that takes an approving decision, or someone who could record one.
 *
 * @returns false when `task` is not a server-side Task record.
 */
export function SanctionApprovalWithdrawal(task: BaseEntity): boolean {
    if (!hasMethod<keyof ApprovalTaskSanctions>(task, 'AuthorizeApprovalWithdrawal')) return false;
    task.AuthorizeApprovalWithdrawal();
    return true;
}

/**
 * Lets the next save of a task record its creator exactly as the caller left it: someone who is not
 * the user saving it, or nobody (the user saving is then not recorded either). For server code
 * raising a task on someone's behalf, or for no Person at all.
 *
 * @returns false when `task` is not a server-side Task record.
 */
export function SanctionOnBehalfCreator(task: BaseEntity): boolean {
    if (!hasMethod<keyof ApprovalTaskSanctions>(task, 'AuthorizeCreatorOnBehalf')) return false;
    task.AuthorizeCreatorOnBehalf();
    return true;
}
