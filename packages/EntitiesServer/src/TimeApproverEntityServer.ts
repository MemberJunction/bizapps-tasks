import {
    BaseEntity,
    EntityDeleteOptions,
    EntitySaveOptions,
    LogError,
    Metadata,
    ValidationErrorInfo,
    ValidationErrorType,
    ValidationResult,
} from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { mjBizAppsTasksTimeApproverEntity } from '@mj-biz-apps/tasks-entities';
import { UserCanManageTimesheets } from '@mj-biz-apps/tasks-core';
import { VerifyPolymorphicRecordExists } from './PolymorphicRecordValidation.js';

export const TIME_APPROVER_ENTITY = 'MJ_BizApps_Tasks: Time Approvers';

/**
 * Server-side subclass of {@link mjBizAppsTasksTimeApproverEntity}.
 *
 * Enforces:
 * - Only holders of the `Tasks/Manage Timesheets` authorization may create, update,
 *   or delete `TimeApprover` rules (§5.8).
 * - When `ScopeEntityID` and `ScopeRecordID` are supplied, verifies that the target
 *   polymorphic record exists (§5.10).
 */
@RegisterClass(BaseEntity, TIME_APPROVER_ENTITY)
export class TimeApproverEntityServer extends mjBizAppsTasksTimeApproverEntity {
    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        const refusal = await this.checkAuthorityAndTarget();
        if (refusal) {
            return this.failTimeApproverWith(refusal);
        }
        return super.Save(options);
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        const refusal = await this.checkAuthorityAndTarget();
        if (refusal) {
            result.Errors.push(new ValidationErrorInfo(
                'ApproverPersonID',
                refusal,
                this.ApproverPersonID,
                ValidationErrorType.Failure,
            ));
            result.Success = false;
        }
        return result;
    }

    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        const user = this.ContextCurrentUser;
        if (!user) {
            return this.failTimeApproverWith('Cannot delete a time approver without a signed-in user context.');
        }
        const canManage = await UserCanManageTimesheets(user, Metadata.Provider);
        if (!canManage) {
            return this.failTimeApproverWith(
                'Only a holder of the Manage Timesheets authorization can change time approvers.',
            );
        }
        return super.Delete(options);
    }

    private async checkAuthorityAndTarget(): Promise<string | null> {
        const user = this.ContextCurrentUser;
        if (!user) {
            return 'Cannot save a time approver without a signed-in user context.';
        }

        try {
            const canManage = await UserCanManageTimesheets(user, Metadata.Provider);
            if (!canManage) {
                return 'Only a holder of the Manage Timesheets authorization can change time approvers.';
            }

            if (this.ScopeEntityID && this.ScopeRecordID) {
                const targetCheck = await VerifyPolymorphicRecordExists(
                    Metadata.Provider,
                    this.RunViewProviderToUse,
                    this.ScopeEntityID,
                    this.ScopeRecordID,
                    user,
                );
                if (!targetCheck.Exists) {
                    return targetCheck.ErrorMessage ?? 'The target scope record was not found.';
                }
            }

            return null;
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`TimeApproverEntityServer: check failed: ${msg}`);
            return `Time approver check failed: ${msg}`;
        }
    }

    private failTimeApproverWith(message: string): false {
        this.LatestResult.Success = false;
        this.LatestResult.Errors.push(new ValidationErrorInfo(
            'ApproverPersonID',
            message,
            this.ApproverPersonID,
            ValidationErrorType.Failure,
        ));
        return false;
    }
}
