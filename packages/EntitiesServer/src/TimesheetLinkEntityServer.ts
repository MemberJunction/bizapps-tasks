import {
    BaseEntity,
    EntitySaveOptions,
    LogError,
    Metadata,
    ValidationErrorInfo,
    ValidationErrorType,
    ValidationResult,
} from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import { mjBizAppsTasksTimesheetLinkEntity } from '@mj-biz-apps/tasks-entities';
import { VerifyPolymorphicRecordExists } from './PolymorphicRecordValidation.js';

export const TIMESHEET_LINK_ENTITY = 'MJ_BizApps_Tasks: Timesheet Links';

/**
 * Server-side subclass of {@link mjBizAppsTasksTimesheetLinkEntity}.
 *
 * Verifies that the target polymorphic `(EntityID, RecordID)` record exists when
 * a link is created or updated (§5.10).
 */
@RegisterClass(BaseEntity, TIMESHEET_LINK_ENTITY)
export class TimesheetLinkEntityServer extends mjBizAppsTasksTimesheetLinkEntity {
    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        const refusal = await this.checkTargetRecord();
        if (refusal) {
            this.LatestResult.Success = false;
            this.LatestResult.Errors.push(new ValidationErrorInfo(
                'RecordID',
                refusal,
                this.RecordID,
                ValidationErrorType.Failure,
            ));
            return false;
        }
        return super.Save(options);
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        const refusal = await this.checkTargetRecord();
        if (refusal) {
            result.Errors.push(new ValidationErrorInfo(
                'RecordID',
                refusal,
                this.RecordID,
                ValidationErrorType.Failure,
            ));
            result.Success = false;
        }
        return result;
    }

    private async checkTargetRecord(): Promise<string | null> {
        const user = this.ContextCurrentUser;
        if (!user) {
            return 'Cannot save a timesheet link without a signed-in user context.';
        }

        try {
            const targetCheck = await VerifyPolymorphicRecordExists(
                Metadata.Provider,
                this.RunViewProviderToUse,
                this.EntityID,
                this.RecordID,
                user,
            );
            if (!targetCheck.Exists) {
                return targetCheck.ErrorMessage ?? 'The linked record was not found.';
            }
            return null;
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`TimesheetLinkEntityServer: target check failed: ${msg}`);
            return `Timesheet link check failed: ${msg}`;
        }
    }
}
