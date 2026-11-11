/**
 * Server-side subclass of `MJ_BizApps_Tasks: Work Report Items` (`AN-BC` review round 2 #2 on PR #165).
 *
 * Enforces parent-report write/delete authorization and status lock on every `Work Report Item`:
 *   - Items can only be created, updated, or deleted while their parent `Work Report` is in `'Draft'` status.
 *     Once the parent report is `'Submitted'` or `'Reviewed'`, items are locked against creates, updates,
 *     and deletes by non-administrators (including the author and supervisor).
 *   - Only the parent report's author (`PersonID`) or a privileged administrator may create, update,
 *     or delete items on a `'Draft'` report (supervisors and other UI users are refused).
 *   - An existing item's `WorkReportID` cannot be re-pointed to another report.
 *   - Any parent report or caller identity lookup failure fails closed.
 */
import {
    BaseEntity,
    BaseEntityResult,
    type EntityDeleteOptions,
    LogError,
    RunView,
    ValidationErrorInfo,
    ValidationResult,
} from '@memberjunction/core';
import { EscapeSQLString, IsValidUUID, RegisterClass, UUIDsEqual } from '@memberjunction/global';
import { mjBizAppsTasksWorkReportItemEntity } from '@mj-biz-apps/tasks-entities';
import {
    IsPrivilegedWorkReportUser,
    WORK_REPORTS_ENTITY_NAME,
    WorkReportService,
    type WorkReportProvider,
} from '@mj-biz-apps/tasks-core';
import {
    ResolveEntityWorkReportProvider,
    WorkReportItemRefusal,
    type WorkReportStatus,
} from './WorkReportAuthority.js';

export const WORK_REPORT_ITEM_ENTITY = 'MJ_BizApps_Tasks: Work Report Items';
const VALIDATE_SOURCE = 'WorkReportItemEntityServer.ValidateAsync';
const DELETE_SOURCE = 'WorkReportItemEntityServer.Delete';

interface ParentWorkReportRow {
    ID: string;
    PersonID: string;
    Status: WorkReportStatus;
}

@RegisterClass(BaseEntity, WORK_REPORT_ITEM_ENTITY)
export class WorkReportItemEntityServer extends mjBizAppsTasksWorkReportItemEntity {
    /** Async validation enforces the parent report's author and status lock on every save. */
    public override get DefaultSkipAsyncValidation(): boolean {
        return false;
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        try {
            const refusal = await this.evaluateItemRefusal(this.IsSaved ? 'update' : 'create');
            if (refusal) {
                result.Success = false;
                result.Errors.push(new ValidationErrorInfo(VALIDATE_SOURCE, refusal, null));
            }
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`WorkReportItemEntityServer: authorization check failed for WorkReportItem ${this.ID || '(new)'}: ${msg}`);
            result.Success = false;
            result.Errors.push(
                new ValidationErrorInfo(
                    VALIDATE_SOURCE,
                    `The Work Report Item could not be saved because authorization checks failed (${msg}).`,
                    null,
                ),
            );
        }
        return result;
    }

    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        try {
            const refusal = await this.evaluateItemRefusal('delete');
            if (refusal) {
                this.recordFailureResult('delete', DELETE_SOURCE, refusal);
                return false;
            }
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`WorkReportItemEntityServer: delete authorization check failed for WorkReportItem ${this.ID || '(unsaved)'}: ${msg}`);
            this.recordFailureResult(
                'delete',
                DELETE_SOURCE,
                `The Work Report Item could not be deleted because authorization checks failed (${msg}).`,
            );
            return false;
        }
        return super.Delete(options);
    }

    private resolveWorkReportProvider(): WorkReportProvider {
        return ResolveEntityWorkReportProvider(this.ProviderToUse, this.RunViewProviderToUse);
    }

    private readPriorWorkReportID(): string | null {
        const field =
            this.GetFieldByName?.('WorkReportID') ??
            this.Fields?.find((f) => f.CodeName === 'WorkReportID' || f.Name === 'WorkReportID');
        if (!field) {
            return this.WorkReportID ?? null;
        }
        if (field.Dirty && field.OldValue != null) {
            return String(field.OldValue);
        }
        return this.WorkReportID ?? null;
    }

    private async evaluateItemRefusal(operation: 'create' | 'update' | 'delete'): Promise<string | null> {
        const user = this.ContextCurrentUser;
        if (!user) {
            return `Work Report Item could not be ${operation}d: a signed-in user context is required.`;
        }

        const workReportID = this.WorkReportID ?? null;
        const priorWorkReportID = this.IsSaved ? this.readPriorWorkReportID() : null;
        if (!workReportID || !IsValidUUID(workReportID)) {
            return `Work Report Item could not be ${operation}d: a valid WorkReportID is required.`;
        }
        if (operation === 'update' && priorWorkReportID && !UUIDsEqual(priorWorkReportID, workReportID)) {
            return 'The WorkReportID of an existing Work Report Item cannot be changed.';
        }

        const provider = this.resolveWorkReportProvider();
        const rv = new RunView(provider);
        const parentRes = await rv.RunView<ParentWorkReportRow>(
            {
                EntityName: WORK_REPORTS_ENTITY_NAME,
                ExtraFilter: `ID = '${EscapeSQLString(workReportID)}'`,
                Fields: ['ID', 'PersonID', 'Status'],
                MaxRows: 1,
                ResultType: 'simple',
                BypassCache: true,
            },
            user,
        );
        if (!parentRes?.Success) {
            throw new Error(parentRes?.ErrorMessage ?? `Failed to load parent Work Report '${workReportID}'`);
        }

        const parentReport = parentRes.Results?.[0] ?? null;
        const callerIsPrivileged = IsPrivilegedWorkReportUser(user);
        const callerPersonIDs: string[] = [];
        if (!callerIsPrivileged) {
            const resolvedPerson = await WorkReportService.Instance.ResolvePersonForUser(user, provider);
            if (resolvedPerson?.ID) {
                callerPersonIDs.push(resolvedPerson.ID);
            }
        }

        return WorkReportItemRefusal({
            Operation: operation,
            CallerUserID: user.ID,
            CallerPersonIDs: callerPersonIDs,
            CallerIsPrivileged: callerIsPrivileged,
            WorkReportID: workReportID,
            PriorWorkReportID: priorWorkReportID,
            ParentReportExists: Boolean(parentReport),
            ParentReportPersonID: parentReport?.PersonID ?? null,
            ParentReportStatus: parentReport?.Status ?? null,
        });
    }

    private recordFailureResult(
        type: 'create' | 'update' | 'delete',
        source: string,
        message: string,
    ): void {
        const entry = new BaseEntityResult(false, message, type);
        entry.StartedAt = new Date();
        entry.EndedAt = new Date();
        entry.Errors = [new ValidationErrorInfo(source, message, null)];
        entry.MessageIncludesErrors = true;
        if (typeof this.RegisterResultHistoryEntry === 'function') {
            this.RegisterResultHistoryEntry(entry);
        } else {
            this.ResultHistory.push(entry);
        }
    }
}

export function LoadWorkReportItemEntityServer(): void {
    // Prevent tree-shaking of @RegisterClass side effects.
    if (!WorkReportItemEntityServer) {
        throw new Error('WorkReportItemEntityServer failed to load');
    }
}
