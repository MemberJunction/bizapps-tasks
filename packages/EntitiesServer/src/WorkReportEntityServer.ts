/**
 * Server-side subclass of `MJ_BizApps_Tasks: Work Reports` (`AN-BC` review #1 & #2 on PR #165).
 *
 * Enforces row-level write authorization and status transition invariants on the server
 * whenever a Work Report is created or updated (whether via GraphQL entity CRUD, an action,
 * or server-side orchestration):
 *   - New reports must start in `'Draft'` with no supervisor review fields, and can only be
 *     created by the report's author (`PersonID`) or a privileged administrator.
 *   - `'Draft'` reports can only be edited or transitioned to `'Submitted'` by their author
 *     (or a privileged administrator), and cannot jump directly to `'Reviewed'`.
 *   - `'Submitted'` reports can only transition to `'Reviewed'` with non-empty `SupervisorFeedback`,
 *     never by the author, and only by the author's resolved supervisor (via
 *     `WorkReportService.Instance.ResolveSupervisorChainForPerson`) or a privileged administrator.
 *   - `'Reviewed'` reports are locked against further edits by non-administrators.
 *   - Any identity or supervisor lookup failure fails closed.
 */
import {
    BaseEntity,
    LogError,
    Metadata,
    ValidationErrorInfo,
    ValidationResult,
    type IMetadataProvider,
    type IRunViewProvider,
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
    WorkReportRefusal,
    type WorkReportAuthorityFacts,
    type WorkReportStatus,
} from './WorkReportAuthority.js';
import { PrimaryPersonIDForUser } from './UserPeople.js';

export const WORK_REPORT_ENTITY = 'MJ_BizApps_Tasks: Work Reports';
const SOURCE = 'WorkReportEntityServer.ValidateAsync';
const AUTHOR_CONTENT_FIELDS = ['Title', 'Body', 'PeriodStart', 'PeriodEnd'] as const;

@RegisterClass(BaseEntity, WORK_REPORT_ENTITY)
export class WorkReportEntityServer extends mjBizAppsTasksWorkReportEntity {
    /** Async validation enforces the server-side author/supervisor state machine on every save. */
    public override get DefaultSkipAsyncValidation(): boolean {
        return false;
    }

    public override async ValidateAsync(): Promise<ValidationResult> {
        const result = await super.ValidateAsync();
        try {
            const refusal = await this.evaluateAuthorityRefusal();
            if (refusal) {
                result.Success = false;
                result.Errors.push(new ValidationErrorInfo(SOURCE, refusal, null));
            }
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`WorkReportEntityServer: authorization check failed for WorkReport ${this.ID || '(new)'}: ${msg}`);
            result.Success = false;
            result.Errors.push(
                new ValidationErrorInfo(
                    SOURCE,
                    `The Work Report could not be saved because authorization checks failed (${msg}).`,
                    null,
                ),
            );
        }
        return result;
    }

    private resolveWorkReportProvider(): WorkReportProvider {
        const mdProvider: IMetadataProvider = Metadata.Provider;
        const rvProvider: IRunViewProvider | undefined = this.RunViewProviderToUse;
        if (rvProvider && rvProvider !== (mdProvider as Partial<IRunViewProvider>)) {
            return new Proxy(mdProvider as WorkReportProvider, {
                get(target, prop, receiver) {
                    if ((prop === 'RunView' || prop === 'RunViews') && prop in rvProvider) {
                        const fn = Reflect.get(rvProvider, prop, rvProvider);
                        return typeof fn === 'function' ? fn.bind(rvProvider) : fn;
                    }
                    return Reflect.get(target, prop, receiver);
                },
            });
        }
        return mdProvider as WorkReportProvider;
    }

    private async resolveCallerPersonIDs(user: UserInfo, provider: WorkReportProvider): Promise<string[]> {
        const ids: string[] = [];
        const addId = (candidate: string | null | undefined): void => {
            if (candidate && !ids.some((existing) => UUIDsEqual(existing, candidate))) {
                ids.push(candidate);
            }
        };

        const resolvedPerson = await WorkReportService.Instance.ResolvePersonForUser(user, provider);
        if (resolvedPerson?.ID) {
            addId(resolvedPerson.ID);
        }

        const primaryId = await PrimaryPersonIDForUser(
            Metadata.Provider,
            this.RunViewProviderToUse,
            user,
        );
        addId(primaryId);

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
        };

        return WorkReportRefusal(facts);
    }
}

export function LoadWorkReportEntityServer(): void {
    // Prevent tree-shaking of @RegisterClass side effects.
    if (!WorkReportEntityServer) {
        throw new Error('WorkReportEntityServer failed to load');
    }
}
