import { BaseEntity, ValidationResult, ValidationErrorInfo, ValidationErrorType } from "@memberjunction/core";
import { RegisterClass } from "@memberjunction/global";

/**
 * Custom entity subclass for MJ_BizApps_Tasks: Tasks.
 *
 * Client-safe logic ONLY: field validation and in-record status-transition
 * side-effects (StartedAt/CompletedAt/PercentComplete). Server-only side-effects
 * (activity logging, sub-task rollup) live in TaskEntityServer.
 *
 * Registered with priority 1 to override the CodeGen-generated base class (priority 0).
 */
@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Tasks', 1)
export class TaskEntity extends BaseEntity {

    // ---------------------------------------------------------------
    // Validation
    // ---------------------------------------------------------------

    public override Validate(): ValidationResult {
        const result = super.Validate();

        this.validatePercentComplete(result);
        this.validateDueAfterStart(result);
        this.applyStatusTransitionSideEffects();

        result.Success = result.Success && result.Errors.length === 0;
        return result;
    }

    private validatePercentComplete(result: ValidationResult): void {
        const pct = this.Get('PercentComplete') as number | null;
        if (pct != null && (pct < 0 || pct > 100)) {
            result.Errors.push(new ValidationErrorInfo(
                'PercentComplete',
                'Percent complete must be between 0 and 100.',
                pct,
                ValidationErrorType.Failure,
            ));
        }
    }

    private validateDueAfterStart(result: ValidationResult): void {
        const startedAt = this.Get('StartedAt') as Date | null;
        const dueAt = this.Get('DueAt') as Date | null;
        if (startedAt && dueAt && dueAt <= startedAt) {
            result.Errors.push(new ValidationErrorInfo(
                'DueAt',
                'Due date must be after the start date.',
                dueAt,
                ValidationErrorType.Failure,
            ));
        }
    }

    // ---------------------------------------------------------------
    // Status transition side-effects
    // ---------------------------------------------------------------

    private applyStatusTransitionSideEffects(): void {
        const statusField = this.Fields.find(f => f.CodeName === 'Status');
        if (!statusField || !statusField.Dirty) return;

        const oldStatus = statusField.OldValue as string | null;
        const newStatus = statusField.Value as string;

        if (newStatus === 'InProgress' && !this.Get('StartedAt')) {
            this.Set('StartedAt', new Date());
        }

        if (newStatus === 'Completed') {
            if (!this.Get('CompletedAt')) {
                this.Set('CompletedAt', new Date());
            }
            this.Set('PercentComplete', 100);
        }

        if (oldStatus === 'Completed' && newStatus !== 'Completed' && newStatus !== 'Cancelled') {
            this.Set('CompletedAt', null);
        }
    }

    // NOTE: Server-only side-effects (activity logging, sub-task progress rollup)
    // are NOT here. They live in TaskEntityServer (tasks-entities-server) so they
    // run once, authoritatively, on the server — never duplicated in the browser.
    // This shared subclass keeps only client-safe logic: validation and in-record
    // field side-effects (StartedAt/CompletedAt/PercentComplete).
}
