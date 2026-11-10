/**
 * Who may create, edit, submit, or review a 15Five-style Work Report — the pure rule
 * and row-level security filter helper (`AN-BC` review #1 & #2 on PR #165).
 *
 * Kept free of entity persistence side-effects so the authorization state machine can be
 * unit-tested directly while `WorkReportEntityServer` gathers the server-side facts.
 */
import type { UserInfo } from '@memberjunction/core';
import { IsValidUUID, UUIDsEqual } from '@memberjunction/global';
import type { mjBizAppsTasksWorkReportEntity } from '@mj-biz-apps/tasks-entities';
import { IsPrivilegedWorkReportUser } from '@mj-biz-apps/tasks-core';

export type WorkReportStatus = mjBizAppsTasksWorkReportEntity['Status'];

/** Facts gathered by `WorkReportEntityServer.ValidateAsync` to evaluate a save. */
export interface WorkReportAuthorityFacts {
    /** Whether the record already exists in the database (`entity.IsSaved`). */
    IsSaved: boolean;
    /** Signed-in user ID, or null if no user context is attached. */
    CallerUserID: string | null;
    /** Every `MJ_BizApps_Common: People` ID bound to the signed-in user. */
    CallerPersonIDs: readonly string[];
    /** Whether the signed-in user holds a privileged administrative role (`Owner` / `Admin` / `Administrator`). */
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
     * Resolved supervisor `Person.ID` for the report author (`PersonID`).
     * Only required when transitioning `'Submitted'` -> `'Reviewed'` (or editing a submitted report).
     */
    ResolvedSupervisorPersonID: string | null;
}

function callerMatchesPerson(callerPersonIDs: readonly string[], targetPersonID: string | null | undefined): boolean {
    if (!targetPersonID) {
        return false;
    }
    return callerPersonIDs.some((id) => UUIDsEqual(id, targetPersonID));
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
        if (!facts.CallerIsPrivileged) {
            if (!facts.ResolvedSupervisorPersonID) {
                return 'No supervisor could be resolved for the report author; review refused.';
            }
            if (!callerMatchesPerson(facts.CallerPersonIDs, facts.ResolvedSupervisorPersonID)) {
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
 * Builds a SQL `ExtraFilter` restricting `MJ_BizApps_Tasks: Work Reports` rows to those visible
 * to `user` (the author's own reports, reports from their direct/indirect supervisees via
 * `MJ_BizApps_Common: People` or `MJ: Employees`, or all rows for privileged administrators).
 */
export function WorkReportRowFilterForUser(user: UserInfo): string {
    if (!user || !IsValidUUID(user.ID)) {
        return '1 = 0';
    }
    if (IsPrivilegedWorkReportUser(user)) {
        return '1 = 1';
    }
    const uid = user.ID;
    return `EXISTS (
        SELECT 1
        FROM [__mj_BizAppsCommon].[vwPeople] p_self
        WHERE p_self.[ID] = [PersonID]
          AND (
              p_self.[LinkedUserID] = '${uid}'
              OR p_self.[Email] = (SELECT u.[Email] FROM [__mj].[vwUsers] u WHERE u.[ID] = '${uid}')
          )
    )
    OR EXISTS (
        SELECT 1
        FROM [__mj_BizAppsCommon].[vwPeople] p_author
        INNER JOIN [__mj_BizAppsCommon].[vwPeople] p_sup ON p_author.[SupervisorPersonID] = p_sup.[ID]
        WHERE p_author.[ID] = [PersonID]
          AND (
              p_sup.[LinkedUserID] = '${uid}'
              OR p_sup.[Email] = (SELECT u.[Email] FROM [__mj].[vwUsers] u WHERE u.[ID] = '${uid}')
          )
    )
    OR EXISTS (
        SELECT 1
        FROM [__mj_BizAppsCommon].[vwPeople] p_author
        INNER JOIN [__mj_BizAppsCommon].[vwPeople] p_mid ON p_author.[SupervisorPersonID] = p_mid.[ID]
        INNER JOIN [__mj_BizAppsCommon].[vwPeople] p_sup2 ON p_mid.[SupervisorPersonID] = p_sup2.[ID]
        WHERE p_author.[ID] = [PersonID]
          AND (
              p_sup2.[LinkedUserID] = '${uid}'
              OR p_sup2.[Email] = (SELECT u.[Email] FROM [__mj].[vwUsers] u WHERE u.[ID] = '${uid}')
          )
    )
    OR EXISTS (
        SELECT 1
        FROM [__mj_BizAppsCommon].[vwPeople] p_author
        INNER JOIN [__mj].[vwEmployees] e_author ON LOWER(LTRIM(RTRIM(e_author.[Email]))) = LOWER(LTRIM(RTRIM(p_author.[Email])))
        INNER JOIN [__mj].[vwEmployees] e_sup ON e_author.[SupervisorID] = e_sup.[ID]
        WHERE p_author.[ID] = [PersonID]
          AND LOWER(LTRIM(RTRIM(e_sup.[Email]))) = LOWER(LTRIM(RTRIM((SELECT u.[Email] FROM [__mj].[vwUsers] u WHERE u.[ID] = '${uid}'))))
    )`;
}
