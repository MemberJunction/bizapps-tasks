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
import { mjBizAppsTasksTimesheetEntity } from '@mj-biz-apps/tasks-entities';
import {
    UserCanManageTimeEntries,
    UserCanManageTimesheets,
} from '@mj-biz-apps/tasks-core';
import { PeopleForUser } from './UserPeople.js';

export const TIMESHEET_ENTITY = 'MJ_BizApps_Tasks: Timesheets';

/**
 * Server-side subclass of {@link mjBizAppsTasksTimesheetEntity}.
 *
 * Enforces ownership and authorization rules on `Timesheet` records:
 * - On create, `PersonID` defaults to the signed-in user's primary Person if unset.
 * - Only the timesheet's owner or a holder of `Manage Timesheets` / `Manage Time Entries`
 *   may create or update a timesheet.
 * - A `Submitted` or `Approved` timesheet cannot be deleted directly; it must be
 *   withdrawn or reopened first.
 */
@RegisterClass(BaseEntity, TIMESHEET_ENTITY)
export class TimesheetEntityServer extends mjBizAppsTasksTimesheetEntity {
    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        const refusal = await this.prepareAndCheckAuthority();
        if (refusal) {
            return this.failTimesheetWith(refusal);
        }
        return super.Save(options);
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        const refusal = await this.prepareAndCheckAuthority();
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
        if (this.Status === 'Submitted' || this.Status === 'Approved') {
            return this.failTimesheetWith(
                `Cannot delete a ${this.Status} timesheet (${this.PeriodStart} to ${this.PeriodEnd}). Withdraw or reopen it first.`,
            );
        }
        const refusal = await this.prepareAndCheckAuthority();
        if (refusal) {
            return this.failTimesheetWith(refusal);
        }
        return super.Delete(options);
    }

    private async prepareAndCheckAuthority(): Promise<string | null> {
        const user = this.ContextCurrentUser;
        if (!user) {
            return 'Cannot save a timesheet without a signed-in user context.';
        }

        try {
            const callerPersonIDs = await PeopleForUser(
                Metadata.Provider,
                this.RunViewProviderToUse,
                user,
            );
            const callerPrimaryPersonID = callerPersonIDs[0] ?? null;

            if (!this.IsSaved && !this.PersonID && callerPrimaryPersonID) {
                this.PersonID = callerPrimaryPersonID;
            }
            if (this.Status === 'Submitted' && !this.SubmittedByUserID) {
                this.SubmittedByUserID = user.ID;
            }
            if (this.Status === 'Submitted' && !this.SubmittedAt) {
                this.SubmittedAt = new Date();
            }

            if (!this.PersonID) {
                return "You can't create a timesheet: your user has no person record.";
            }

            const isOwner = callerPersonIDs.some(
                id => id.toLowerCase() === this.PersonID.toLowerCase(),
            );
            if (isOwner) {
                return null;
            }

            const [canManageTimesheets, canManageEntries] = await Promise.all([
                UserCanManageTimesheets(user, Metadata.Provider),
                UserCanManageTimeEntries(user, Metadata.Provider),
            ]);
            if (canManageTimesheets || canManageEntries) {
                return null;
            }

            return 'Only the timesheet owner or a timesheet manager can modify this timesheet.';
        } catch (err: unknown) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`TimesheetEntityServer: authority check failed: ${msg}`);
            return `Timesheet authority check failed: ${msg}`;
        }
    }

    private failTimesheetWith(message: string): false {
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
