/**
 * Who may create, edit, submit, review, or delete a 15Five-style Work Report or Work Report Item —
 * pure authorization rules (`AN-BC` reviews #1 & #2 on PR #165).
 *
 * Kept free of entity persistence side-effects so the authorization state machine can be
 * unit-tested directly while `WorkReportEntityServer` and `WorkReportItemEntityServer`
 * gather the server-side facts.
 */
import {
    Metadata,
    type IEntityDataProvider,
    type IMetadataProvider,
    type IRunViewProvider,
} from '@memberjunction/core';
import { IsValidUUID, UUIDsEqual } from '@memberjunction/global';
import type { mjBizAppsTasksWorkReportEntity } from '@mj-biz-apps/tasks-entities';
import type { WorkReportProvider } from '@mj-biz-apps/tasks-core';

export type WorkReportStatus = mjBizAppsTasksWorkReportEntity['Status'];

export function IsEntityMetadataProvider(
    candidate: IEntityDataProvider | IMetadataProvider | IRunViewProvider | null | undefined,
): candidate is IMetadataProvider {
    return (
        candidate != null &&
        ('Entities' in candidate || 'EntityByName' in candidate || 'EntityByID' in candidate)
    );
}

export function IsEntityRunViewProvider(
    candidate: IEntityDataProvider | IMetadataProvider | IRunViewProvider | null | undefined,
): candidate is IRunViewProvider {
    return candidate != null && 'RunView' in candidate && typeof candidate.RunView === 'function';
}

/**
 * Resolves a {@link WorkReportProvider} that honours the entity instance's bound `ProviderToUse`
 * and `RunViewProviderToUse` before falling back to `Metadata.Provider`.
 */
export function ResolveEntityWorkReportProvider(
    entityProvider: IEntityDataProvider | null | undefined,
    runViewProvider: IRunViewProvider | null | undefined,
): WorkReportProvider {
    const baseMetadata: IMetadataProvider = IsEntityMetadataProvider(entityProvider)
        ? entityProvider
        : Metadata.Provider;
    const activeRunView: IRunViewProvider | undefined = IsEntityRunViewProvider(entityProvider)
        ? entityProvider
        : IsEntityRunViewProvider(runViewProvider)
          ? runViewProvider
          : IsEntityRunViewProvider(baseMetadata)
            ? baseMetadata
            : undefined;
    if (activeRunView && activeRunView !== (baseMetadata as Partial<IRunViewProvider>)) {
        const combined: IMetadataProvider & IRunViewProvider = Object.assign(
            Object.create(Object.getPrototypeOf(baseMetadata)),
            baseMetadata,
            {
                Entities: baseMetadata.Entities,
                EntityByName:
                    typeof baseMetadata.EntityByName === 'function'
                        ? baseMetadata.EntityByName.bind(baseMetadata)
                        : undefined,
                EntityByID:
                    typeof baseMetadata.EntityByID === 'function'
                        ? baseMetadata.EntityByID.bind(baseMetadata)
                        : undefined,
                GetEntityObject:
                    typeof baseMetadata.GetEntityObject === 'function'
                        ? baseMetadata.GetEntityObject.bind(baseMetadata)
                        : undefined,
                RunView: activeRunView.RunView.bind(activeRunView),
                RunViews:
                    typeof activeRunView.RunViews === 'function'
                        ? activeRunView.RunViews.bind(activeRunView)
                        : activeRunView.RunView.bind(activeRunView),
            },
        );
        return combined;
    }
    return baseMetadata as WorkReportProvider;
}

/** Facts gathered by `WorkReportEntityServer.ValidateAsync` to evaluate a save. */
export interface WorkReportAuthorityFacts {
    /** Whether the record already exists in the database (`entity.IsSaved`). */
    IsSaved: boolean;
    /** Signed-in user ID, or null if no user context is attached. */
    CallerUserID: string | null;
    /** Every `MJ_BizApps_Common: People` ID bound to the signed-in user. */
    CallerPersonIDs: readonly string[];
    /** Whether the signed-in user holds a privileged administrative role (`Owner` / `Admin` / `Administrator` / `System Administrator` / `Administration`). */
    CallerIsPrivileged: boolean;
    /** Target `PersonID` on the report being saved. */
    PersonID: string | null;
    /** Prior `PersonID` before this save (when `IsSaved` is true). */
    PriorPersonID: string | null;
    /** Target `Status` on the report being saved. */
    Status: WorkReportStatus;
    /** Prior `Status` before this save (when `IsSaved` is true). */
    PriorStatus: WorkReportStatus | null;
    /** Target `SupervisorFeedback` on the report being saved. */
    SupervisorFeedback: string | null;
    /** Target `ReviewedByPersonID` on the report being saved. */
    ReviewedByPersonID: string | null;
    /** Target `ReviewedAt` on the report being saved. */
    ReviewedAt: Date | null;
    /** Whether any author-owned content field (`Title`, `Body`, `PeriodStart`, `PeriodEnd`) was modified on an existing report. */
    AuthorContentDirty: boolean;
    /**
     * Direct resolved supervisor `Person.ID` for the report author (`PersonID`).
     */
    ResolvedSupervisorPersonID: string | null;
    /**
     * Full resolved supervisor chain `Person.ID`s (up to 3 levels via `MJ: Employees.SupervisorID`)
     * for the report author (`PersonID`). When omitted, falls back to `[ResolvedSupervisorPersonID]`.
     */
    ResolvedSupervisorPersonIDs?: readonly string[];
}

/** Facts gathered by `WorkReportEntityServer.Delete` to evaluate a delete. */
export interface WorkReportDeleteAuthorityFacts {
    CallerUserID: string | null;
    CallerPersonIDs: readonly string[];
    CallerIsPrivileged: boolean;
    PersonID: string | null;
    Status: WorkReportStatus | null;
}

/** Facts gathered by `WorkReportItemEntityServer` to evaluate an item create, update, or delete. */
export interface WorkReportItemAuthorityFacts {
    Operation: 'create' | 'update' | 'delete';
    CallerUserID: string | null;
    CallerPersonIDs: readonly string[];
    CallerIsPrivileged: boolean;
    WorkReportID: string | null;
    PriorWorkReportID: string | null;
    ParentReportExists: boolean;
    ParentReportPersonID: string | null;
    ParentReportStatus: WorkReportStatus | null;
}

function callerMatchesPerson(callerPersonIDs: readonly string[], targetPersonID: string | null | undefined): boolean {
    if (!targetPersonID) {
        return false;
    }
    return callerPersonIDs.some((id) => UUIDsEqual(id, targetPersonID));
}

function callerMatchesAnyPerson(
    callerPersonIDs: readonly string[],
    targetPersonIDs: readonly string[],
): boolean {
    return targetPersonIDs.some((targetID) => callerMatchesPerson(callerPersonIDs, targetID));
}

/**
 * Evaluates whether a `WorkReport` save is permitted.
 * Returns a human-readable refusal reason when forbidden, or `null` when permitted.
 */
export function WorkReportRefusal(facts: WorkReportAuthorityFacts): string | null {
    if (!facts.CallerUserID) {
        return 'Work Report could not be saved: a signed-in user context is required.';
    }

    if (!facts.PersonID || !IsValidUUID(facts.PersonID)) {
        return 'Work Report could not be saved: a valid author PersonID is required.';
    }

    if (!facts.CallerIsPrivileged && facts.CallerPersonIDs.length === 0) {
        return 'Work Report could not be saved: the signed-in user could not be resolved to an active Person record.';
    }

    const isAuthor = callerMatchesPerson(facts.CallerPersonIDs, facts.PersonID);
    const hasReviewMetadata =
        Boolean(facts.SupervisorFeedback && facts.SupervisorFeedback.trim().length > 0) ||
        Boolean(facts.ReviewedByPersonID) ||
        facts.ReviewedAt != null;

    if (!facts.IsSaved) {
        if (facts.Status !== 'Draft') {
            return `A new Work Report must start in 'Draft' status (received '${facts.Status}').`;
        }
        if (hasReviewMetadata) {
            return 'A new Draft Work Report cannot include supervisor review fields.';
        }
        if (!isAuthor && !facts.CallerIsPrivileged) {
            return 'Only the report author (or a privileged administrator) may create a Work Report for this person.';
        }
        return null;
    }

    if (facts.PriorPersonID && !UUIDsEqual(facts.PriorPersonID, facts.PersonID)) {
        return 'The PersonID of an existing Work Report cannot be changed.';
    }

    const priorStatus = facts.PriorStatus ?? 'Draft';

    if (priorStatus === 'Reviewed') {
        if (!facts.CallerIsPrivileged) {
            return 'Reviewed Work Reports are locked and cannot be modified.';
        }
        return null;
    }

    if (priorStatus === 'Draft') {
        if (facts.Status !== 'Draft' && facts.Status !== 'Submitted') {
            return `Invalid Work Report status transition from 'Draft' to '${facts.Status}'. A Draft report must be Submitted before it can be Reviewed.`;
        }
        if (hasReviewMetadata) {
            return `Supervisor review fields cannot be set while a Work Report is in '${facts.Status}' status.`;
        }
        if (!isAuthor && !facts.CallerIsPrivileged) {
            return facts.Status === 'Submitted'
                ? 'Only the report author may submit this Work Report.'
                : 'Only the report author may edit a Draft Work Report.';
        }
        return null;
    }

    if (priorStatus === 'Submitted') {
        if (facts.Status !== 'Reviewed') {
            return `A Submitted Work Report cannot remain in or transition to '${facts.Status}'; only a transition to 'Reviewed' is allowed.`;
        }
        if (facts.AuthorContentDirty && !facts.CallerIsPrivileged) {
            return 'Author report fields (Title, Body, PeriodStart, PeriodEnd) cannot be modified after the report has been submitted.';
        }
        if (!facts.SupervisorFeedback || facts.SupervisorFeedback.trim().length === 0) {
            return 'SupervisorFeedback is required when transitioning a Work Report to Reviewed.';
        }
        if (isAuthor) {
            return 'A report author cannot review their own Work Report.';
        }
        const resolvedSupervisorChain =
            facts.ResolvedSupervisorPersonIDs && facts.ResolvedSupervisorPersonIDs.length > 0
                ? facts.ResolvedSupervisorPersonIDs
                : facts.ResolvedSupervisorPersonID
                  ? [facts.ResolvedSupervisorPersonID]
                  : [];
        if (!facts.CallerIsPrivileged) {
            if (resolvedSupervisorChain.length === 0) {
                return 'No supervisor could be resolved for the report author; review refused.';
            }
            if (!callerMatchesAnyPerson(facts.CallerPersonIDs, resolvedSupervisorChain)) {
                return 'Only the resolved supervisor for the report author may review this Work Report.';
            }
        }
        if (
            facts.ReviewedByPersonID &&
            !callerMatchesPerson(facts.CallerPersonIDs, facts.ReviewedByPersonID) &&
            !facts.CallerIsPrivileged
        ) {
            return 'ReviewedByPersonID must match the signed-in reviewer Person record.';
        }
        return null;
    }

    return `Unsupported prior Work Report status '${String(priorStatus)}'.`;
}

/**
 * Evaluates whether a `WorkReport` delete is permitted.
 * Only a privileged administrator or the report's author (while the report is still in `'Draft'` status)
 * may delete a `WorkReport`.
 */
export function WorkReportDeleteRefusal(facts: WorkReportDeleteAuthorityFacts): string | null {
    if (!facts.CallerUserID) {
        return 'Work Report could not be deleted: a signed-in user context is required.';
    }
    if (facts.CallerIsPrivileged) {
        return null;
    }
    if (facts.CallerPersonIDs.length === 0) {
        return 'Work Report could not be deleted: the signed-in user could not be resolved to an active Person record.';
    }
    const status = facts.Status ?? 'Draft';
    if (status !== 'Draft') {
        return `Cannot delete a '${status}' Work Report; only 'Draft' reports may be deleted.`;
    }
    if (!callerMatchesPerson(facts.CallerPersonIDs, facts.PersonID)) {
        return 'Only the report author (or a privileged administrator) may delete a Draft Work Report.';
    }
    return null;
}

/**
 * Evaluates whether a `WorkReportItem` create, update, or delete is permitted.
 * Items may only be created, updated, or deleted while their parent `WorkReport` is in `'Draft'` status,
 * and only by the parent report's author (or a privileged administrator).
 */
export function WorkReportItemRefusal(facts: WorkReportItemAuthorityFacts): string | null {
    if (!facts.CallerUserID) {
        return `Work Report Item could not be ${facts.Operation}d: a signed-in user context is required.`;
    }
    if (!facts.WorkReportID || !IsValidUUID(facts.WorkReportID)) {
        return `Work Report Item could not be ${facts.Operation}d: a valid WorkReportID is required.`;
    }
    if (
        facts.Operation === 'update' &&
        facts.PriorWorkReportID &&
        !UUIDsEqual(facts.PriorWorkReportID, facts.WorkReportID)
    ) {
        return 'The WorkReportID of an existing Work Report Item cannot be changed.';
    }
    if (!facts.ParentReportExists) {
        return `Work Report Item could not be ${facts.Operation}d: parent Work Report '${facts.WorkReportID}' was not found.`;
    }
    if (facts.CallerIsPrivileged) {
        return null;
    }
    if (facts.CallerPersonIDs.length === 0) {
        return `Work Report Item could not be ${facts.Operation}d: the signed-in user could not be resolved to an active Person record.`;
    }
    if (facts.ParentReportStatus !== 'Draft') {
        return `Cannot ${facts.Operation} items on a '${facts.ParentReportStatus ?? 'Unknown'}' Work Report; only 'Draft' reports can be edited.`;
    }
    if (!callerMatchesPerson(facts.CallerPersonIDs, facts.ParentReportPersonID)) {
        return `Only the Work Report author may ${facts.Operation} its items.`;
    }
    return null;
}
