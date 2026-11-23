import { RunView } from '@memberjunction/core';
import type { ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import { TypedActionPolicyGuard } from '@memberjunction/ai-core-plus';
import { UserCache } from '@memberjunction/generic-database-provider';
import { EscapeSQLString, IsValidUUID, RegisterClass, UUIDsEqual } from '@memberjunction/global';
import {
    GetLocalDayWindow,
    IsPrivilegedWorkReportUser,
    ResolveBriefingContributorBounds,
    RunWithBriefingContributorTimeout,
    SerializeBriefingPayloadWithLimit,
    TasksLimitsResolver,
    WorkReportService,
} from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksWorkReportEntity,
    mjBizAppsTasksWorkReportItemEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    buildWorkReportDeepLink,
    checkTypedPolicyGuard,
    failResult,
    getDateParam,
    getNumberParam,
    getStringParam,
    setOutputParam,
    successResult,
    toIsoOrNull,
    WORK_REPORT_ITEMS_ENTITY,
    WORK_REPORTS_ENTITY,
} from './action-helpers.js';

export const DRAFT_WORK_REPORT_ACTION_ID = '9F5124A5-64F2-4C06-8D71-60710DCB531B';
export const SUBMIT_WORK_REPORT_ACTION_ID = '856D4E92-79B4-486A-A092-48CF5FC22998';
export const REVIEW_WORK_REPORT_ACTION_ID = 'B880DABA-0FC1-4012-9C3B-92694D99985E';
export const GET_MY_WORK_REPORTS_BRIEFING_ACTION_ID = '7436F4C6-1556-4D25-9487-4EAC3D6E8CB0';

type WorkReportStatusValue = mjBizAppsTasksWorkReportEntity['Status'];

const VALID_WORK_REPORT_STATUSES: ReadonlySet<WorkReportStatusValue> = new Set([
    'Draft',
    'Submitted',
    'Reviewed',
]);

function mapWorkReportServiceError(message: string): { code: string; message: string } {
    if (/not found/i.test(message)) {
        return { code: 'NOT_FOUND', message };
    }
    if (/could not be resolved to an active Person/i.test(message)) {
        return { code: 'NO_PERSON_RECORD', message };
    }
    if (
        /Only the |not the mapped supervisor|cannot review their own|does not match|No mapped supervisor/i.test(message)
    ) {
        return { code: 'PERMISSION_DENIED', message };
    }
    if (/Only a '(?:Draft|Submitted)'|already been|Invalid |is required/i.test(message)) {
        return { code: 'VALIDATION_ERROR', message };
    }
    return { code: 'ERROR', message };
}

function normalizeWorkReportStatus(raw: string | null): WorkReportStatusValue | null {
    if (!raw) return null;
    const norm = raw.trim().toLowerCase();
    if (norm === 'draft') return 'Draft';
    if (norm === 'submitted') return 'Submitted';
    if (norm === 'reviewed') return 'Reviewed';
    return VALID_WORK_REPORT_STATUSES.has(raw as WorkReportStatusValue)
        ? (raw as WorkReportStatusValue)
        : null;
}

/**
 * Action: `Tasks.GetWorkReport`
 *
 * Returns a single `MJ_BizApps_Tasks: Work Reports` record with its linked
 * `MJ_BizApps_Tasks: Work Report Items`, enforcing author/supervisor-chain
 * visibility and `TypedActionPolicyGuard` field masking.
 */
@RegisterClass(BaseAction, 'Tasks.GetWorkReport')
export class GetWorkReportAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const reportID = getStringParam(params, 'WorkReportID');
        if (!reportID || !IsValidUUID(reportID)) {
            return failResult('VALIDATION_ERROR', 'A valid WorkReportID UUID is required.', params);
        }

        const reportGuard = await checkTypedPolicyGuard({
            params,
            entityName: WORK_REPORTS_ENTITY,
            operation: 'Read',
        });
        if (!reportGuard.Allowed) return reportGuard.Failure;

        const itemsGuard = await checkTypedPolicyGuard({
            params,
            entityName: WORK_REPORT_ITEMS_ENTITY,
            operation: 'Read',
        });
        if (!itemsGuard.Allowed) return itemsGuard.Failure;

        try {
            const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
            const callerPerson = await WorkReportService.Instance.ResolvePersonForUser(user);
            const callerIsPrivileged = IsPrivilegedWorkReportUser(user);
            if (!callerPerson?.ID && !callerIsPrivileged) {
                return failResult(
                    'NO_PERSON_RECORD',
                    'No active Person record is linked to ContextUser.',
                    params,
                );
            }

            const rv = new RunView();
            const escapedId = EscapeSQLString(reportID);
            const [reportRes, itemsRes] = await Promise.all([
                rv.RunView<
                    Pick<
                        mjBizAppsTasksWorkReportEntity,
                        | 'ID'
                        | 'PersonID'
                        | 'Person'
                        | 'PeriodStart'
                        | 'PeriodEnd'
                        | 'Title'
                        | 'Body'
                        | 'Status'
                        | 'SupervisorFeedback'
                        | 'ReviewedByPersonID'
                        | 'ReviewedByPerson'
                        | 'ReviewedAt'
                    >
                >(
                    {
                        EntityName: WORK_REPORTS_ENTITY,
                        ExtraFilter: `ID = '${escapedId}'`,
                        Fields: [
                            'ID',
                            'PersonID',
                            'Person',
                            'PeriodStart',
                            'PeriodEnd',
                            'Title',
                            'Body',
                            'Status',
                            'SupervisorFeedback',
                            'ReviewedByPersonID',
                            'ReviewedByPerson',
                            'ReviewedAt',
                        ],
                        MaxRows: limits.ResourceGuards.DefaultLookupSingleRow,
                        ResultType: 'simple',
                    },
                    user,
                ),
                rv.RunView<
                    Pick<
                        mjBizAppsTasksWorkReportItemEntity,
                        'ID' | 'WorkReportID' | 'TaskID' | 'Task' | 'Section' | 'Summary' | 'Sequence'
                    >
                >(
                    {
                        EntityName: WORK_REPORT_ITEMS_ENTITY,
                        ExtraFilter: `WorkReportID = '${escapedId}'`,
                        Fields: ['ID', 'WorkReportID', 'TaskID', 'Task', 'Section', 'Summary', 'Sequence'],
                        OrderBy: 'Sequence ASC',
                        MaxRows: limits.ResourceGuards.WorkflowBatchMaxRows,
                        ResultType: 'simple',
                    },
                    user,
                ),
            ]);

            const report = reportRes.Success ? reportRes.Results?.[0] : undefined;
            if (!report) {
                return failResult('NOT_FOUND', `WorkReport '${reportID}' was not found or is not accessible.`, params);
            }

            // Explicit defense-in-depth reporting-line check in addition to RLS
            if (!callerIsPrivileged && callerPerson?.ID && !UUIDsEqual(report.PersonID, callerPerson.ID)) {
                const chain = await WorkReportService.Instance.ResolveSupervisorChainForPerson(
                    report.PersonID,
                    user,
                );
                const supervisorPersonIDs =
                    chain.SupervisorChainPersonIDs && chain.SupervisorChainPersonIDs.length > 0
                        ? chain.SupervisorChainPersonIDs
                        : chain.SupervisorPersonID
                          ? [chain.SupervisorPersonID]
                          : [];
                const isSupervisor = supervisorPersonIDs.some((id) => UUIDsEqual(id, callerPerson.ID));
                if (!isSupervisor) {
                    return failResult(
                        'PERMISSION_DENIED',
                        'Only the report author, their supervisor chain, or an administrator may read this work report.',
                        params,
                    );
                }
            }

            const maskedHeader = TypedActionPolicyGuard.MaskRecord(
                {
                    ID: report.ID,
                    PersonID: report.PersonID,
                    PersonName: report.Person ?? null,
                    PeriodStart: toIsoOrNull(report.PeriodStart),
                    PeriodEnd: toIsoOrNull(report.PeriodEnd),
                    Title: report.Title ?? null,
                    Body: report.Body,
                    Status: report.Status,
                    SupervisorFeedback: report.SupervisorFeedback ?? null,
                    ReviewedByPersonID: report.ReviewedByPersonID ?? null,
                    ReviewedByPersonName: report.ReviewedByPerson ?? null,
                    ReviewedAt: toIsoOrNull(report.ReviewedAt),
                    DeepLink: buildWorkReportDeepLink(report.ID),
                },
                reportGuard.DeniedFieldPatterns,
            );

            const items = TypedActionPolicyGuard.MaskRows(
                (itemsRes.Success ? (itemsRes.Results ?? []) : []).map((item) => ({
                    ID: item.ID,
                    TaskID: item.TaskID ?? null,
                    TaskName: item.Task ?? null,
                    Section: item.Section,
                    Summary: item.Summary,
                    Sequence: item.Sequence,
                })),
                itemsGuard.DeniedFieldPatterns,
            );

            const payload = {
                ...maskedHeader,
                Items: items,
            };

            const summary = `Loaded WorkReport "${report.Title ?? report.ID}" (${report.Status}) with ${items.length} item(s).`;
            setOutputParam(params, 'WorkReport', JSON.stringify(payload));
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            const mapped = mapWorkReportServiceError(err instanceof Error ? err.message : String(err));
            return failResult(mapped.code, mapped.message, params);
        }
    }
}

/**
 * Action: `Tasks.ListWorkReports`
 *
 * Lists Work Reports scoped to `Mine`, `TeamPendingReview`, or `TeamRecent` via RLS-safe `RunView`,
 * enforcing `TypedActionPolicyGuard` narrowing and field masking.
 */
@RegisterClass(BaseAction, 'Tasks.ListWorkReports')
export class ListWorkReportsAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const guard = await checkTypedPolicyGuard({
            params,
            entityName: WORK_REPORTS_ENTITY,
            operation: 'Read',
        });
        if (!guard.Allowed) return guard.Failure;

        try {
            const scopeRaw = (getStringParam(params, 'Scope') ?? 'Mine').trim().toLowerCase();
            if (scopeRaw !== 'mine' && scopeRaw !== 'teampendingreview' && scopeRaw !== 'teamrecent') {
                return failResult(
                    'VALIDATION_ERROR',
                    `Invalid Scope '${scopeRaw}'. Expected Mine, TeamPendingReview, or TeamRecent.`,
                    params,
                );
            }

            const statusRaw = getStringParam(params, 'Status');
            const status = statusRaw ? normalizeWorkReportStatus(statusRaw) : null;
            if (statusRaw && !status) {
                return failResult(
                    'VALIDATION_ERROR',
                    `Invalid Status '${statusRaw}'. Expected Draft, Submitted, or Reviewed.`,
                    params,
                );
            }

            const since = getDateParam(params, 'Since');
            if (since === 'INVALID') {
                return failResult('VALIDATION_ERROR', 'Since must be a valid ISO-8601 date.', params);
            }

            const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
            const limitRaw = getNumberParam(params, 'Limit', 'MaxRows') ?? limits.ResourceGuards.FindWorkReportsDefaultMaxRows;
            const limit = Math.max(1, Math.min(limits.ResourceGuards.FindWorkReportsMaxRowsCeiling, Math.round(limitRaw)));

            const callerPerson = await WorkReportService.Instance.ResolvePersonForUser(user);
            const callerIsPrivileged = IsPrivilegedWorkReportUser(user);
            if (!callerPerson?.ID && !callerIsPrivileged) {
                return failResult(
                    'NO_PERSON_RECORD',
                    'No active Person record is linked to ContextUser.',
                    params,
                );
            }

            const filters: string[] = [];
            if (scopeRaw === 'mine') {
                if (!callerPerson?.ID) {
                    return failResult(
                        'NO_PERSON_RECORD',
                        'No active Person record is linked to ContextUser.',
                        params,
                    );
                }
                filters.push(`PersonID = '${EscapeSQLString(callerPerson.ID)}'`);
            } else {
                const directReportIDs = callerPerson?.ID
                    ? await WorkReportService.Instance.ResolveDirectReportPersonIDs(callerPerson.ID, user)
                    : [];
                if (directReportIDs.length === 0) {
                    const emptySummary = 'No team work reports found (no direct reports mapped in MJ: Employees).';
                    setOutputParam(params, 'WorkReports', '[]');
                    setOutputParam(params, 'TotalCount', 0);
                    setOutputParam(params, 'Summary', emptySummary);
                    return successResult(emptySummary, params);
                }
                const inTeam = directReportIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
                filters.push(`PersonID IN (${inTeam})`);
                if (scopeRaw === 'teampendingreview') {
                    filters.push(`Status = 'Submitted'`);
                }
            }

            if (status) {
                filters.push(`Status = '${EscapeSQLString(status)}'`);
            }
            if (since) {
                filters.push(`PeriodEnd >= '${EscapeSQLString(since.toISOString().slice(0, 10))}'`);
            }

            const rv = new RunView();
            const res = await rv.RunView<
                Pick<
                    mjBizAppsTasksWorkReportEntity,
                    'ID' | 'PersonID' | 'Person' | 'PeriodStart' | 'PeriodEnd' | 'Title' | 'Status' | 'ReviewedAt'
                >
            >(
                {
                    EntityName: WORK_REPORTS_ENTITY,
                    ExtraFilter: filters.join(' AND '),
                    Fields: ['ID', 'PersonID', 'Person', 'PeriodStart', 'PeriodEnd', 'Title', 'Status', 'ReviewedAt'],
                    OrderBy: 'PeriodEnd DESC, __mj_UpdatedAt DESC',
                    MaxRows: limit,
                    ResultType: 'simple',
                },
                user,
            );

            if (!res.Success) {
                return failResult('ERROR', res.ErrorMessage ?? 'Failed to list work reports.', params);
            }

            const compact = (res.Results ?? []).map((r) => ({
                ID: r.ID,
                PersonID: r.PersonID,
                PersonName: r.Person ?? null,
                PeriodStart: toIsoOrNull(r.PeriodStart),
                PeriodEnd: toIsoOrNull(r.PeriodEnd),
                Title: r.Title ?? null,
                Status: r.Status,
                ReviewedAt: toIsoOrNull(r.ReviewedAt),
                DeepLink: buildWorkReportDeepLink(r.ID),
            }));
            const masked = TypedActionPolicyGuard.MaskRows(compact, guard.DeniedFieldPatterns);

            const summary = `Found ${masked.length} work report(s) for scope '${scopeRaw}'.`;
            setOutputParam(params, 'WorkReports', JSON.stringify(masked));
            setOutputParam(params, 'TotalCount', masked.length);
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            const mapped = mapWorkReportServiceError(err instanceof Error ? err.message : String(err));
            return failResult(mapped.code, mapped.message, params);
        }
    }
}

/**
 * Action: `Tasks.DraftWorkReport`
 *
 * Delegates to {@link WorkReportService.DraftWorkReport} to read a person's task activity,
 * check-ins, and audit events in `[PeriodStart, PeriodEnd]` and create or update a `Draft`
 * `MJ_BizApps_Tasks: Work Reports` record plus `MJ_BizApps_Tasks: Work Report Items`.
 * Returns `NO_ACTIVITY` without writing a draft when no tasks changed in the window.
 */
@RegisterClass(BaseAction, 'Tasks.DraftWorkReport')
export class DraftWorkReportAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required', params);

        const guard = await checkTypedPolicyGuard({
            params,
            entityName: WORK_REPORTS_ENTITY,
            operation: 'Create',
            writeFields: ['PersonID', 'PeriodStart', 'PeriodEnd', 'Title', 'Body', 'Status'],
        });
        if (!guard.Allowed) return guard.Failure;

        try {
            const explicitPersonID = getStringParam(params, 'PersonID');
            if (explicitPersonID && !IsValidUUID(explicitPersonID)) {
                return failResult('VALIDATION_ERROR', 'PersonID is not a valid UUID', params);
            }

            const callerPerson = await WorkReportService.Instance.ResolvePersonForUser(user);
            const callerIsPrivileged = IsPrivilegedWorkReportUser(user);
            if (!callerPerson?.ID && !callerIsPrivileged) {
                return failResult('NO_PERSON_RECORD', 'No active Person record is linked to ContextUser', params);
            }

            const personID = explicitPersonID ?? callerPerson?.ID ?? null;
            if (!personID) {
                return failResult('NO_PERSON_RECORD', 'No active Person record is linked to ContextUser', params);
            }
            if (!callerIsPrivileged && (!callerPerson?.ID || !UUIDsEqual(callerPerson.ID, personID))) {
                return failResult(
                    'PERMISSION_DENIED',
                    'Only the report author (or a privileged administrator) may draft a work report for this person',
                    params,
                );
            }

            const authoredByRunID = getStringParam(params, 'AuthoredByAgentRunID');
            if (authoredByRunID && !IsValidUUID(authoredByRunID)) {
                return failResult('VALIDATION_ERROR', 'AuthoredByAgentRunID is not a valid UUID', params);
            }

            const rawTzOffset = getStringParam(params, 'TimezoneOffsetMinutes');
            const parsedTzOffset = rawTzOffset != null ? Number(rawTzOffset) : undefined;
            const tzOffsetMinutes =
                parsedTzOffset !== undefined && Number.isFinite(parsedTzOffset) ? parsedTzOffset : undefined;
            const localDay = GetLocalDayWindow(new Date(), tzOffsetMinutes);
            const rawStart = getStringParam(params, 'PeriodStart');
            const rawEnd = getStringParam(params, 'PeriodEnd');
            const periodStart = rawStart ? new Date(rawStart) : localDay.PeriodStart;
            const periodEnd = rawEnd ? new Date(rawEnd) : localDay.PeriodEnd;
            if (Number.isNaN(periodStart.getTime()) || Number.isNaN(periodEnd.getTime())) {
                return failResult('VALIDATION_ERROR', 'PeriodStart or PeriodEnd is not a valid ISO-8601 date', params);
            }
            const customTitle = getStringParam(params, 'Title');
            const customBody = getStringParam(params, 'Body');

            const outcome = await WorkReportService.Instance.DraftWorkReport({
                PersonID: personID,
                PeriodStart: periodStart,
                PeriodEnd: periodEnd,
                TimezoneOffsetMinutes: tzOffsetMinutes,
                Title: customTitle,
                CustomBody: customBody,
                AuthoredByAgentRunID: authoredByRunID,
                ContextUser: user,
            });

            if (outcome.SkippedNoActivity || !outcome.Report) {
                setOutputParam(params, 'WorkReportID', '');
                setOutputParam(params, 'WorkReportItemsCreated', '0');
                return successResult(
                    'No task activity occurred in the requested reporting window; skipped creating a draft.',
                    params,
                    'NO_ACTIVITY',
                );
            }

            setOutputParam(params, 'WorkReportID', outcome.Report.ID);
            setOutputParam(params, 'WorkReportItemsCreated', String(outcome.Items.length));
            return successResult(
                `Drafted WorkReport ${outcome.Report.ID} with ${outcome.Items.length} item(s).`,
                params,
            );
        } catch (err) {
            const mapped = mapWorkReportServiceError(err instanceof Error ? err.message : String(err));
            return failResult(mapped.code, mapped.message, params);
        }
    }
}

/**
 * Action: `Tasks.SubmitWorkReport`
 *
 * Delegates to {@link WorkReportService.SubmitWorkReport} to transition an author-approved
 * `Draft` WorkReport to `Submitted` and dispatch an inter-agent review request to the
 * supervisor's Chief of Staff.
 */
@RegisterClass(BaseAction, 'Tasks.SubmitWorkReport')
export class SubmitWorkReportAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required', params);

        const reportID = getStringParam(params, 'WorkReportID');
        if (!reportID || !IsValidUUID(reportID)) {
            return failResult('VALIDATION_ERROR', 'Valid WorkReportID is required', params);
        }

        const guard = await checkTypedPolicyGuard({
            params,
            entityName: WORK_REPORTS_ENTITY,
            operation: 'Update',
            writeFields: ['Status', 'Title', 'Body'],
        });
        if (!guard.Allowed) return guard.Failure;

        try {
            const callerPerson = await WorkReportService.Instance.ResolvePersonForUser(user);
            const callerIsPrivileged = IsPrivilegedWorkReportUser(user);
            if (!callerPerson?.ID && !callerIsPrivileged) {
                return failResult('NO_PERSON_RECORD', 'No active Person record is linked to ContextUser', params);
            }

            const editedTitle = getStringParam(params, 'Title');
            const editedBody = getStringParam(params, 'Body');

            const systemUser = UserCache.Instance.GetSystemUser() ?? user;
            const outcome = await WorkReportService.Instance.SubmitWorkReport({
                WorkReportID: reportID,
                CallerPersonID: callerPerson?.ID ?? null,
                UpdatedTitle: editedTitle ?? undefined,
                UpdatedBody: editedBody ?? undefined,
                ContextUser: user,
                ServiceContextUser: systemUser,
            });

            const requestID = outcome.SupervisorRequestID ?? '';
            const supervisorName = outcome.Supervisor.SupervisorName ?? '';
            setOutputParam(params, 'SupervisorRequestID', requestID);
            setOutputParam(params, 'SupervisorNotified', outcome.SupervisorNotified);
            setOutputParam(params, 'SupervisorName', supervisorName);

            return successResult(
                outcome.SupervisorNotified
                    ? `Submitted WorkReport ${outcome.Report.ID} and created supervisor review request ${requestID}.`
                    : `Submitted WorkReport ${outcome.Report.ID}.`,
                params,
            );
        } catch (err) {
            const mapped = mapWorkReportServiceError(err instanceof Error ? err.message : String(err));
            return failResult(mapped.code, mapped.message, params);
        }
    }
}

/**
 * Action: `Tasks.ReviewWorkReport`
 *
 * Delegates to {@link WorkReportService.RecordSupervisorReview} to record supervisor-approved
 * feedback on a `Submitted` WorkReport, enforcing fail-closed reporting-line ownership.
 */
@RegisterClass(BaseAction, 'Tasks.ReviewWorkReport')
export class ReviewWorkReportAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required', params);

        const reportID = getStringParam(params, 'WorkReportID');
        if (!reportID || !IsValidUUID(reportID)) {
            return failResult('VALIDATION_ERROR', 'Valid WorkReportID is required', params);
        }

        const feedback = getStringParam(params, 'SupervisorFeedback');
        if (!feedback) {
            return failResult('VALIDATION_ERROR', 'SupervisorFeedback is required', params);
        }

        const guard = await checkTypedPolicyGuard({
            params,
            entityName: WORK_REPORTS_ENTITY,
            operation: 'Update',
            writeFields: ['Status', 'SupervisorFeedback', 'ReviewedByPersonID', 'ReviewedAt'],
        });
        if (!guard.Allowed) return guard.Failure;

        try {
            const reviewerPerson = await WorkReportService.Instance.ResolvePersonForUser(user);
            const callerIsPrivileged = IsPrivilegedWorkReportUser(user);
            if (!reviewerPerson?.ID && !callerIsPrivileged) {
                return failResult('NO_PERSON_RECORD', 'No active Person record is linked to ContextUser', params);
            }

            const outcome = await WorkReportService.Instance.RecordSupervisorReview({
                WorkReportID: reportID,
                ReviewerPersonID: reviewerPerson?.ID ?? null,
                SupervisorFeedback: feedback,
                ContextUser: user,
            });

            return successResult(
                `Recorded supervisor feedback on WorkReport ${outcome.Report.ID}.`,
                params,
            );
        } catch (err) {
            const mapped = mapWorkReportServiceError(err instanceof Error ? err.message : String(err));
            return failResult(mapped.code, mapped.message, params);
        }
    }
}

/**
 * Action: `Get My Work Reports Briefing` (`Role = 'Briefing'`, `ExposeToModel = false`)
 *
 * Returns a deterministic Chief of Staff briefing slice containing:
 * - The caller's current `Draft` / recently `Submitted` work reports (plus whether today's report exists)
 * - Any direct reports' `Submitted` work reports awaiting supervisor review
 */
@RegisterClass(BaseAction, 'GetMyWorkReportsBriefingAction')
export class GetMyWorkReportsBriefingAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const guard = await checkTypedPolicyGuard({
            params,
            entityName: WORK_REPORTS_ENTITY,
            operation: 'Read',
        });
        if (!guard.Allowed) return guard.Failure;

        try {
            const bounds = ResolveBriefingContributorBounds({
                LookbackDays: getNumberParam(params, 'LookbackDays'),
                MaxItems: getNumberParam(params, 'MaxItems'),
                LookbackKind: 'workReports',
            });
            const lookbackDays = bounds.LookbackDays;
            const maxItems = bounds.MaxItems;

            return await RunWithBriefingContributorTimeout(
                async () => {
                    const callerPerson = await WorkReportService.Instance.ResolvePersonForUser(user);
            if (!callerPerson?.ID) {
                return failResult(
                    'NO_PERSON_RECORD',
                    'No active Person record is linked to ContextUser.',
                    params,
                );
            }

            const now = new Date();
            const lookbackDateStr = new Date(now.getTime() - lookbackDays * 24 * 60 * 60 * 1000)
                .toISOString()
                .slice(0, 10);
            const todayDateStr = GetLocalDayWindow(now).PeriodStart.toISOString().slice(0, 10);

            let directReportPersonIDs: string[] = [];
            try {
                directReportPersonIDs = await WorkReportService.Instance.ResolveDirectReportPersonIDs(
                    callerPerson.ID,
                    user,
                );
            } catch {
                directReportPersonIDs = [];
            }

            const rv = new RunView();
            const myReportsPromise = rv.RunView<
                Pick<
                    mjBizAppsTasksWorkReportEntity,
                    'ID' | 'PersonID' | 'Person' | 'PeriodStart' | 'PeriodEnd' | 'Title' | 'Status' | 'ReviewedAt'
                >
            >(
                {
                    EntityName: WORK_REPORTS_ENTITY,
                    ExtraFilter:
                        `PersonID = '${EscapeSQLString(callerPerson.ID)}' ` +
                        `AND (Status = 'Draft' OR PeriodEnd >= '${EscapeSQLString(lookbackDateStr)}')`,
                    Fields: ['ID', 'PersonID', 'Person', 'PeriodStart', 'PeriodEnd', 'Title', 'Status', 'ReviewedAt'],
                    OrderBy: 'PeriodEnd DESC, __mj_UpdatedAt DESC',
                    MaxRows: maxItems * 2,
                    ResultType: 'simple',
                },
                user,
            );

            const directReportsPromise =
                directReportPersonIDs.length > 0
                    ? rv.RunView<
                          Pick<
                              mjBizAppsTasksWorkReportEntity,
                              'ID' | 'PersonID' | 'Person' | 'PeriodStart' | 'PeriodEnd' | 'Title' | 'Status' | 'ReviewedAt'
                          >
                      >(
                          {
                              EntityName: WORK_REPORTS_ENTITY,
                              ExtraFilter:
                                  `PersonID IN (${directReportPersonIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ')}) ` +
                                  `AND Status = 'Submitted'`,
                              Fields: ['ID', 'PersonID', 'Person', 'PeriodStart', 'PeriodEnd', 'Title', 'Status', 'ReviewedAt'],
                              OrderBy: 'PeriodEnd DESC, __mj_UpdatedAt DESC',
                              MaxRows: maxItems,
                              ResultType: 'simple',
                          },
                          user,
                      )
                    : Promise.resolve({ Success: true, Results: [] as Array<Pick<
                          mjBizAppsTasksWorkReportEntity,
                          'ID' | 'PersonID' | 'Person' | 'PeriodStart' | 'PeriodEnd' | 'Title' | 'Status' | 'ReviewedAt'
                      >> });

            const [myRes, teamRes] = await Promise.all([myReportsPromise, directReportsPromise]);
            if (!myRes.Success) {
                return failResult('ERROR', myRes.ErrorMessage ?? 'Failed to load caller work reports.', params);
            }
            if (!teamRes.Success) {
                const errMsg =
                    'ErrorMessage' in teamRes && typeof teamRes.ErrorMessage === 'string' && teamRes.ErrorMessage
                        ? teamRes.ErrorMessage
                        : 'Failed to load direct reports work reports.';
                return failResult('ERROR', errMsg, params);
            }

            const toBriefingRow = (
                r: Pick<
                    mjBizAppsTasksWorkReportEntity,
                    'ID' | 'PersonID' | 'Person' | 'PeriodStart' | 'PeriodEnd' | 'Title' | 'Status' | 'ReviewedAt'
                >,
            ) => ({
                ID: r.ID,
                PersonID: r.PersonID,
                PersonName: r.Person ?? null,
                PeriodStart: toIsoOrNull(r.PeriodStart),
                PeriodEnd: toIsoOrNull(r.PeriodEnd),
                Title: r.Title ?? 'Work Report',
                Status: r.Status,
                ReviewedAt: toIsoOrNull(r.ReviewedAt),
                DeepLink: buildWorkReportDeepLink(r.ID),
            });

            const myRows = myRes.Results ?? [];
            const hasReportForToday = myRows.some((r) => {
                const endIso = toIsoOrNull(r.PeriodEnd);
                return endIso !== null && endIso.slice(0, 10) >= todayDateStr;
            });

            const myDrafts = myRows.filter((r) => r.Status === 'Draft').map(toBriefingRow);
            const mySubmitted = myRows.filter((r) => r.Status === 'Submitted').map(toBriefingRow);
            const directReportsAwaitingReview = (teamRes.Results ?? []).map(toBriefingRow);

            const briefing = {
                GeneratedAt: now.toISOString(),
                LookbackDays: lookbackDays,
                HasReportForToday: hasReportForToday,
                Counts: {
                    MyDrafts: myDrafts.length,
                    MySubmitted: mySubmitted.length,
                    DirectReportsAwaitingReview: directReportsAwaitingReview.length,
                    TotalActionable: myDrafts.length + directReportsAwaitingReview.length,
                },
                MyDraftReports: TypedActionPolicyGuard.MaskRows(myDrafts.slice(0, maxItems), guard.DeniedFieldPatterns),
                MySubmittedReports: TypedActionPolicyGuard.MaskRows(
                    mySubmitted.slice(0, maxItems),
                    guard.DeniedFieldPatterns,
                ),
                DirectReportsAwaitingReview: TypedActionPolicyGuard.MaskRows(
                    directReportsAwaitingReview.slice(0, maxItems),
                    guard.DeniedFieldPatterns,
                ),
            };

            const summary =
                `Work reports briefing: ${myDrafts.length} draft(s), ${mySubmitted.length} submitted awaiting review, ` +
                `${directReportsAwaitingReview.length} direct report(s) awaiting your review ` +
                `(today's report ${hasReportForToday ? 'exists' : 'not yet drafted'}).`;

            const serialized = SerializeBriefingPayloadWithLimit(
                briefing,
                ['MyDraftReports', 'MySubmittedReports', 'DirectReportsAwaitingReview'],
                bounds.MaxContributorChars,
            );
                    setOutputParam(params, 'Briefing', serialized.Json);
                    setOutputParam(params, 'Summary', summary);
                    return successResult(summary, params);
                },
                bounds.ContributorTimeoutMs,
                'GetMyWorkReportsBriefingAction',
            );
        } catch (err) {
            const mapped = mapWorkReportServiceError(err instanceof Error ? err.message : String(err));
            return failResult(mapped.code, mapped.message, params);
        }
    }
}
