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
import { mjBizAppsTasksTaskTimeEntryLinkEntity } from '@mj-biz-apps/tasks-entities';
import { VerifyPolymorphicRecordExists } from './PolymorphicRecordValidation.js';

export const TASK_TIME_ENTRY_LINK_ENTITY = 'MJ_BizApps_Tasks: Task Time Entry Links';

/**
 * Server-side subclass of {@link mjBizAppsTasksTaskTimeEntryLinkEntity}.
 *
 * Verifies that the target polymorphic `(EntityID, RecordID)` record exists when
 * a link is created or updated (§5.10). Once saved, the linked `TaskTimeEntry` is
 * protected from edit or deletion by Rule R8 until this link is removed.
 */
@RegisterClass(BaseEntity, TASK_TIME_ENTRY_LINK_ENTITY)
export class TaskTimeEntryLinkEntityServer extends mjBizAppsTasksTaskTimeEntryLinkEntity {
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
            return 'Cannot save a time entry link without a signed-in user context.';
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
            LogError(`TaskTimeEntryLinkEntityServer: target check failed: ${msg}`);
            return `Time entry link check failed: ${msg}`;
        }
    }
}
