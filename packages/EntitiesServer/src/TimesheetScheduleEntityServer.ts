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
import { mjBizAppsTasksTimesheetScheduleEntity } from '@mj-biz-apps/tasks-entities';
import {
    TasksSettings,
    UserCanManageTimesheets,
} from '@mj-biz-apps/tasks-core';
import { PeopleForUser } from './UserPeople.js';
import { VerifyPolymorphicRecordExists } from './PolymorphicRecordValidation.js';

export const TIMESHEET_SCHEDULE_ENTITY = 'MJ_BizApps_Tasks: Timesheet Schedules';

/**
 * Server-side subclass of {@link mjBizAppsTasksTimesheetScheduleEntity}.
 *
 * Enforces:
 * - Only holders of `Tasks/Manage Timesheets` may set any person's or scope's
 *   submission period, UNLESS `TimesheetSchedulesSelfService` is `true` and the
 *   caller is modifying a schedule for their own Person (with no `ScopeEntityID`) (§5.7, §5.8).
 * - When `ScopeEntityID` and `ScopeRecordID` are supplied, verifies that the target
 *   polymorphic record exists (§5.10).
 */
@RegisterClass(BaseEntity, TIMESHEET_SCHEDULE_ENTITY)
export class TimesheetScheduleEntityServer extends mjBizAppsTasksTimesheetScheduleEntity {
    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        const refusal = await this.checkAuthorityAndTarget();
        if (refusal) {
            return this.failScheduleWith(refusal);
        }
        return super.Save(options);
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        const refusal = await this.checkAuthorityAndTarget();
        if (refusal) {
            result.Errors.push(new ValidationErrorInfo(
                'PersonID',
                refusal,
                this.PersonID,
                ValidationErrorType.Failure,
            ));
            result.Success = false;
        }
        return result;
    }

    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        const refusal = await this.checkAuthorityAndTarget();
        if (refusal) {
            return this.failScheduleWith(refusal);
        }
        return super.Delete(options);
    }

    private async checkAuthorityAndTarget(): Promise<string | null> {
        const user = this.ContextCurrentUser;
        if (!user) {
            return 'Cannot save a timesheet schedule without a signed-in user context.';
        }

        try {
            const canManage = await UserCanManageTimesheets(user, Metadata.Provider);
            if (!canManage) {
                await TasksSettings.Load(Metadata.Provider, user);
                const selfService = await TasksSettings.TimesheetSchedulesSelfService(
                    Metadata.Provider,
                );
                if (!selfService) {
                    return 'Only a holder of the Manage Timesheets authorization can change timesheet schedules.';
                }
                const callerPersonIDs = await PeopleForUser(
                    Metadata.Provider,
                    this.RunViewProviderToUse,
                    user,
                );
                if (!this.IsSaved && !this.PersonID && !this.ScopeEntityID && callerPersonIDs[0]) {
                    this.PersonID = callerPersonIDs[0];
                }
                const isOwnPersonSchedule =
                    this.PersonID != null &&
                    !this.ScopeEntityID &&
                    callerPersonIDs.some(id => id.toLowerCase() === this.PersonID!.toLowerCase());
                if (!isOwnPersonSchedule) {
                    return 'Self-service timesheet schedules can only be set for your own person record.';
                }
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
            LogError(`TimesheetScheduleEntityServer: check failed: ${msg}`);
            return `Timesheet schedule check failed: ${msg}`;
        }
    }

    private failScheduleWith(message: string): false {
        this.LatestResult.Success = false;
        this.LatestResult.Errors.push(new ValidationErrorInfo(
            'PersonID',
            message,
            this.PersonID,
            ValidationErrorType.Failure,
        ));
        return false;
    }
}
