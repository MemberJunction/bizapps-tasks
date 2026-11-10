/**
 * Server-side subclass of `MJ_BizApps_Tasks: Work Reports` (`AN-BC` reviews #1 & #2 on PR #165).
 *
 * Enforces row-level write/delete authorization and status transition invariants on the server
 * whenever a Work Report is created, updated, or deleted (whether via GraphQL entity CRUD, an action,
 * or server-side orchestration):
 *   - New reports must start in `'Draft'` with no supervisor review fields, and can only be
 *     created by the report's author (`PersonID`) or a privileged administrator.
 *   - `'Draft'` reports can only be edited, deleted, or transitioned to `'Submitted'` by their author
 *     (or a privileged administrator), and cannot jump directly to `'Reviewed'`.
 *   - `'Submitted'` reports can only transition to `'Reviewed'` with non-empty `SupervisorFeedback`,
 *     never by the author, and only by a supervisor in the author's resolved supervisor chain (via
 *     `WorkReportService.Instance.ResolveSupervisorChainForPerson`) or a privileged administrator.
 *     Stamps `ReviewedByPersonID` and `ReviewedAt` automatically on `Submitted -> Reviewed`.
 *   - `'Reviewed'` reports are locked against further edits or deletion by non-administrators.
 *   - Any identity or supervisor lookup failure fails closed.
 */
import {
    BaseEntity,
    BaseEntityResult,
    type EntityDeleteOptions,
    type EntitySaveOptions,
    LogError,
    ValidationErrorInfo,
    ValidationResult,
    type UserInfo,
} from '@memberjunction/core';
import { RegisterClass, UUIDsEqual } from '@memberjunction/global';
import { mjBizAppsTasksWorkReportEntity } from '@mj-biz-apps/tasks-entities';
import {
    IsPrivilegedWorkReportUser,
    WorkReportService,
    type WorkReportProvider,
} from '@mj-biz-apps/tasks-core';
import {
    ResolveEntityWorkReportProvider,
    WorkReportDeleteRefusal,
    WorkReportRefusal,
    type WorkReportAuthorityFacts,
    type WorkReportStatus,
} from './WorkReportAuthority.js';

export const WORK_REPORT_ENTITY = 'MJ_BizApps_Tasks: Work Reports';
const VALIDATE_SOURCE = 'WorkReportEntityServer.ValidateAsync';
const DELETE_SOURCE = 'WorkReportEntityServer.Delete';
const AUTHOR_CONTENT_FIELDS = ['Title', 'Body', 'PeriodStart', 'PeriodEnd'] as const;

@RegisterClass(BaseEntity, WORK_REPORT_ENTITY)
export class WorkReportEntityServer extends mjBizAppsTasksWorkReportEntity {
    /** Async validation enforces the server-side author/supervisor state machine on every save. */
    public override get DefaultSkipAsyncValidation(): boolean {
        return false;
    }

    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        await this.stampReviewMetadataPreSave();
        return super.Save(options);
    }

    public override async Delete(options?: EntityDeleteOptions): Promise<boolean> {
        try {
            const refusal = await this.evaluateDeleteRefusal();
            if (refusal) {
                this.recordFailureResult('delete', DELETE_SOURCE, refusal);
                return false;
            }
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`WorkReportEntityServer: delete authorization check failed for WorkReport ${this.ID || '(unsaved)'}: ${msg}`);
            this.recordFailureResult(
                'delete',
                DELETE_SOURCE,
                `The Work Report could not be deleted because authorization checks failed (${msg}).`,
            );
            return false;
        }
        return super.Delete(options);
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        try {
            const refusal = await this.evaluateAuthorityRefusal();
            if (refusal) {
                result.Success = false;
                result.Errors.push(new ValidationErrorInfo(VALIDATE_SOURCE, refusal, null));
            }
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`WorkReportEntityServer: authorization check failed for WorkReport ${this.ID || '(new)'}: ${msg}`);
            result.Success = false;
            result.Errors.push(
                new ValidationErrorInfo(
                    VALIDATE_SOURCE,
                    `The Work Report could not be saved because authorization checks failed (${msg}).`,
                    null,
                ),
            );
        }
        return result;
    }

    private resolveWorkReportProvider(): WorkReportProvider {
        return ResolveEntityWorkReportProvider(this.ProviderToUse, this.RunViewProviderToUse);
    }

    private async resolveCallerPersonIDs(user: UserInfo, provider: WorkReportProvider): Promise<string[]> {
        const ids: string[] = [];
        const resolvedPerson = await WorkReportService.Instance.ResolvePersonForUser(user, provider);
        if (resolvedPerson?.ID && !ids.some((existing) => UUIDsEqual(existing, resolvedPerson.ID))) {
            ids.push(resolvedPerson.ID);
        }
        return ids;
    }

    private readFieldState(fieldName: string): { Dirty: boolean; OldValue: string | WorkReportStatus | null } {
        const field =
            this.GetFieldByName?.(fieldName) ??
            this.Fields?.find((f) => f.CodeName === fieldName || f.Name === fieldName);
        if (!field) {
            return { Dirty: false, OldValue: null };
        }
        const rawOld = field.OldValue;
        return {
            Dirty: Boolean(field.Dirty),
            OldValue: rawOld != null ? String(rawOld) : null,
        };
    }

    private async stampReviewMetadataPreSave(): Promise<void> {
        if (!this.IsSaved || this.Status !== 'Reviewed') {
            return;
        }
        const statusField = this.readFieldState('Status');
        const priorStatus: WorkReportStatus =
            (statusField.Dirty && statusField.OldValue
                ? (statusField.OldValue as WorkReportStatus)
                : this.Status) ?? 'Draft';
        if (priorStatus !== 'Submitted') {
            return;
        }

        if (!this.ReviewedAt) {
            this.ReviewedAt = new Date();
        }

        const user = this.ContextCurrentUser;
        if (!user) {
            return;
        }

        try {
            const provider = this.resolveWorkReportProvider();
            const callerPersonIDs = await this.resolveCallerPersonIDs(user, provider);
            const callerPersonID = callerPersonIDs[0] ?? null;
            if (callerPersonID && (!this.ReviewedByPersonID || !IsPrivilegedWorkReportUser(user))) {
                this.ReviewedByPersonID = callerPersonID;
            }
        } catch {
            // ValidateAsync will surface the lookup error cleanly and fail closed.
        }
    }

    private async evaluateAuthorityRefusal(): Promise<string | null> {
        const user = this.ContextCurrentUser;
        if (!user) {
            return 'Work Report could not be saved: a signed-in user context is required.';
        }

        const provider = this.resolveWorkReportProvider();
        const callerIsPrivileged = IsPrivilegedWorkReportUser(user);
        const callerPersonIDs = await this.resolveCallerPersonIDs(user, provider);

        const statusField = this.readFieldState('Status');
        const personField = this.readFieldState('PersonID');

        const priorStatus: WorkReportStatus | null = this.IsSaved
            ? ((statusField.Dirty && statusField.OldValue
                  ? (statusField.OldValue as WorkReportStatus)
                  : this.Status) ?? 'Draft')
            : null;
        const priorPersonID: string | null = this.IsSaved
            ? (personField.Dirty && personField.OldValue ? personField.OldValue : this.PersonID)
            : null;

        const authorContentDirty = this.IsSaved
            ? AUTHOR_CONTENT_FIELDS.some((name) => this.readFieldState(name).Dirty)
            : false;

        let resolvedSupervisorPersonID: string | null = null;
        let resolvedSupervisorPersonIDs: string[] = [];
        if (
            this.IsSaved &&
            this.PersonID &&
            (priorStatus === 'Submitted' || this.Status === 'Reviewed')
        ) {
            const chain = await WorkReportService.Instance.ResolveSupervisorChainForPerson(
                this.PersonID,
                user,
                provider,
            );
            resolvedSupervisorPersonID = chain.SupervisorPersonID;
            resolvedSupervisorPersonIDs =
                chain.SupervisorChainPersonIDs && chain.SupervisorChainPersonIDs.length > 0
                    ? chain.SupervisorChainPersonIDs
                    : chain.SupervisorPersonID
                      ? [chain.SupervisorPersonID]
                      : [];
        }

        // Stamp ReviewedByPersonID / ReviewedAt when ValidateAsync is called on a Submitted -> Reviewed transition
        if (this.IsSaved && priorStatus === 'Submitted' && this.Status === 'Reviewed') {
            if (!this.ReviewedAt) {
                this.ReviewedAt = new Date();
            }
            if (!this.ReviewedByPersonID && callerPersonIDs[0]) {
                this.ReviewedByPersonID = callerPersonIDs[0];
            }
        }

        const facts: WorkReportAuthorityFacts = {
            IsSaved: this.IsSaved,
            CallerUserID: user.ID,
            CallerPersonIDs: callerPersonIDs,
            CallerIsPrivileged: callerIsPrivileged,
            PersonID: this.PersonID ?? null,
            PriorPersonID: priorPersonID,
            Status: this.Status,
            PriorStatus: priorStatus,
            SupervisorFeedback: this.SupervisorFeedback ?? null,
            ReviewedByPersonID: this.ReviewedByPersonID ?? null,
            ReviewedAt: this.ReviewedAt ?? null,
            AuthorContentDirty: authorContentDirty,
            ResolvedSupervisorPersonID: resolvedSupervisorPersonID,
            ResolvedSupervisorPersonIDs: resolvedSupervisorPersonIDs,
        };

        return WorkReportRefusal(facts);
    }

    private async evaluateDeleteRefusal(): Promise<string | null> {
        const user = this.ContextCurrentUser;
        if (!user) {
            return 'Work Report could not be deleted: a signed-in user context is required.';
        }

        const provider = this.resolveWorkReportProvider();
        const callerIsPrivileged = IsPrivilegedWorkReportUser(user);
        const callerPersonIDs = callerIsPrivileged ? [] : await this.resolveCallerPersonIDs(user, provider);

        const statusField = this.readFieldState('Status');
        const personField = this.readFieldState('PersonID');
        const effectiveStatus: WorkReportStatus =
            (statusField.Dirty && statusField.OldValue
                ? (statusField.OldValue as WorkReportStatus)
                : this.Status) ?? 'Draft';
        const effectivePersonID: string | null =
            personField.Dirty && personField.OldValue ? personField.OldValue : (this.PersonID ?? null);

        return WorkReportDeleteRefusal({
            CallerUserID: user.ID,
            CallerPersonIDs: callerPersonIDs,
            CallerIsPrivileged: callerIsPrivileged,
            PersonID: effectivePersonID,
            Status: effectiveStatus,
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

export function LoadWorkReportEntityServer(): void {
    // Prevent tree-shaking of @RegisterClass side effects.
    if (!WorkReportEntityServer) {
        throw new Error('WorkReportEntityServer failed to load');
    }
}
