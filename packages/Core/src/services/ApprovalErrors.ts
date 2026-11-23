/**
 * Typed error definitions for approval authorization and validation failures.
 */

export type ApprovalAuthorizationErrorCode =
    | 'UNAUTHENTICATED_ACTOR'
    | 'INVALID_TASK_ID'
    | 'TASK_NOT_FOUND'
    | 'TASK_ALREADY_CLOSED'
    | 'UNAUTHORIZED_ACTOR'
    | 'CROSS_ORGANIZATION_DENIED'
    | 'MISMATCHED_ROLE'
    | 'SELF_APPROVAL_DENIED'
    | 'INVALID_OUTCOME';

/**
 * Strongly-typed authorization error thrown or surfaced when an actor attempts
 * an approval operation they are not permitted to perform (wrong role, cross-org,
 * unauthenticated, self-approval, or closed task).
 */
export class ApprovalAuthorizationError extends Error {
    public readonly Code: ApprovalAuthorizationErrorCode;
    public readonly Operation: string;

    public constructor(
        code: ApprovalAuthorizationErrorCode,
        operation: string,
        message: string,
    ) {
        super(message);
        this.name = 'ApprovalAuthorizationError';
        this.Code = code;
        this.Operation = operation;
        Object.setPrototypeOf(this, ApprovalAuthorizationError.prototype);
    }
}
