import { BaseEntity, ValidationResult, ValidationErrorInfo, ValidationErrorType } from "@memberjunction/core";
import { RegisterClass } from "@memberjunction/global";

/**
 * Custom entity subclass for MJ.BizApps.Tasks: Tasks.
 * Handles status transition side-effects, field validation, and sub-task rollup.
 *
 * Registered with priority 1 to override the CodeGen-generated base class (priority 0).
 * Once CodeGen has run, change the extends clause to the generated base class
 * (e.g. `tasksTaskEntity`) for full type safety.
 */
@RegisterClass(BaseEntity, 'MJ.BizApps.Tasks: Tasks', 1)
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

    /**
     * PercentComplete must be between 0 and 100.
     * (Also enforced by the DB CHECK constraint, but catching it early gives a better UX.)
     */
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

    /**
     * If both StartedAt and DueAt are set, DueAt must be after StartedAt.
     */
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

    /**
     * Auto-set timestamp fields when Status transitions:
     *   - Open/Blocked → InProgress: set StartedAt (if not already set)
     *   - Any → Completed: set CompletedAt + PercentComplete = 100
     *   - Completed → reopened (Open/InProgress): clear CompletedAt
     */
    private applyStatusTransitionSideEffects(): void {
        const statusField = this.Fields.find(f => f.CodeName === 'Status');
        if (!statusField || !statusField.Dirty) return;

        const oldStatus = statusField.OldValue as string | null;
        const newStatus = statusField.Value as string;

        // Transitioning to InProgress — stamp StartedAt if blank
        if (newStatus === 'InProgress' && !this.Get('StartedAt')) {
            this.Set('StartedAt', new Date());
        }

        // Transitioning to Completed — stamp CompletedAt and set 100%
        if (newStatus === 'Completed') {
            if (!this.Get('CompletedAt')) {
                this.Set('CompletedAt', new Date());
            }
            this.Set('PercentComplete', 100);
        }

        // Re-opening a completed task — clear CompletedAt
        if (oldStatus === 'Completed' && newStatus !== 'Completed' && newStatus !== 'Cancelled') {
            this.Set('CompletedAt', null);
        }
    }
}
