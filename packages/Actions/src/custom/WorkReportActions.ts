import { ActionParam, ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import { IsValidUUID, RegisterClass, UUIDsEqual } from '@memberjunction/global';
import {
    GetLocalDayWindow,
    IsPrivilegedWorkReportUser,
    WorkReportService,
} from '@mj-biz-apps/tasks-core';

export const DRAFT_WORK_REPORT_ACTION_ID = '9F5124A5-64F2-4C06-8D71-60710DCB531B';
export const SUBMIT_WORK_REPORT_ACTION_ID = '856D4E92-79B4-486A-A092-48CF5FC22998';
export const REVIEW_WORK_REPORT_ACTION_ID = 'B880DABA-0FC1-4012-9C3B-92694D99985E';

function getStringParam(params: RunActionParams, name: string): string | null {
    const found = params.Params.find((p) => p.Name.toLowerCase() === name.toLowerCase());
    if (!found || found.Value == null) return null;
    const str = String(found.Value).trim();
    return str.length > 0 ? str : null;
}

function setOutputParam(params: RunActionParams, name: string, value: string | boolean | null): void {
    const existing = params.Params.find((p) => p.Name.toLowerCase() === name.toLowerCase());
    if (existing) {
        existing.Value = value;
        return;
    }
    const out: ActionParam = {
        Name: name,
        Value: value,
        Type: 'Output',
    };
    params.Params.push(out);
}

function failResult(code: string, message: string): ActionResultSimple {
    return { Success: false, ResultCode: code, Message: message };
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

    protected async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('ERROR', 'ContextUser is required');

        try {
            const explicitPersonID = getStringParam(params, 'PersonID');
            if (explicitPersonID && !IsValidUUID(explicitPersonID)) {
                return failResult('ERROR', 'PersonID is not a valid UUID');
            }

            const callerPerson = await WorkReportService.Instance.ResolvePersonForUser(user);
            const callerIsPrivileged = IsPrivilegedWorkReportUser(user);
            if (!callerPerson?.ID && !callerIsPrivileged) {
                return failResult('ERROR', 'No active Person record is linked to ContextUser');
            }

            const personID = explicitPersonID ?? callerPerson?.ID ?? null;
            if (!personID) {
                return failResult('ERROR', 'No active Person record is linked to ContextUser');
            }
            if (!callerIsPrivileged && (!callerPerson?.ID || !UUIDsEqual(callerPerson.ID, personID))) {
                return failResult('ERROR', 'Only the report author (or a privileged administrator) may draft a work report for this person');
            }

            const authoredByRunID = getStringParam(params, 'AuthoredByAgentRunID');
            if (authoredByRunID && !IsValidUUID(authoredByRunID)) {
                return failResult('ERROR', 'AuthoredByAgentRunID is not a valid UUID');
            }

            const localDay = GetLocalDayWindow();
            const rawStart = getStringParam(params, 'PeriodStart');
            const rawEnd = getStringParam(params, 'PeriodEnd');
            const periodStart = rawStart ? new Date(rawStart) : localDay.PeriodStart;
            const periodEnd = rawEnd ? new Date(rawEnd) : localDay.PeriodEnd;
            if (Number.isNaN(periodStart.getTime()) || Number.isNaN(periodEnd.getTime())) {
                return failResult('ERROR', 'PeriodStart or PeriodEnd is not a valid ISO-8601 date');
            }
            const customTitle = getStringParam(params, 'Title');
            const customBody = getStringParam(params, 'Body');

            const outcome = await WorkReportService.Instance.DraftWorkReport({
                PersonID: personID,
                PeriodStart: periodStart,
                PeriodEnd: periodEnd,
                Title: customTitle,
                CustomBody: customBody,
                AuthoredByAgentRunID: authoredByRunID,
                ContextUser: user,
            });

            if (outcome.SkippedNoActivity || !outcome.Report) {
                setOutputParam(params, 'WorkReportID', '');
                return {
                    Success: true,
                    ResultCode: 'NO_ACTIVITY',
                    Message: 'No task activity occurred in the requested reporting window; skipped creating a draft.',
                };
            }

            setOutputParam(params, 'WorkReportID', outcome.Report.ID);
            return {
                Success: true,
                ResultCode: 'SUCCESS',
                Message: `Drafted WorkReport ${outcome.Report.ID} with ${outcome.Items.length} item(s).`,
            };
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            return failResult('ERROR', msg);
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

    protected async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('ERROR', 'ContextUser is required');

        const reportID = getStringParam(params, 'WorkReportID');
        if (!reportID || !IsValidUUID(reportID)) {
            return failResult('ERROR', 'Valid WorkReportID is required');
        }

        try {
            const callerPerson = await WorkReportService.Instance.ResolvePersonForUser(user);
            const callerIsPrivileged = IsPrivilegedWorkReportUser(user);
            if (!callerPerson?.ID && !callerIsPrivileged) {
                return failResult('ERROR', 'No active Person record is linked to ContextUser');
            }

            const editedTitle = getStringParam(params, 'Title');
            const editedBody = getStringParam(params, 'Body');

            const outcome = await WorkReportService.Instance.SubmitWorkReport({
                WorkReportID: reportID,
                CallerPersonID: callerPerson?.ID ?? null,
                UpdatedTitle: editedTitle ?? undefined,
                UpdatedBody: editedBody ?? undefined,
                ContextUser: user,
            });

            const requestID = outcome.SupervisorRequestID ?? '';
            const supervisorName = outcome.Supervisor.SupervisorName ?? '';
            setOutputParam(params, 'SupervisorRequestID', requestID);
            setOutputParam(params, 'SupervisorNotified', outcome.SupervisorNotified);
            setOutputParam(params, 'SupervisorName', supervisorName);

            return {
                Success: true,
                ResultCode: 'SUCCESS',
                Message: outcome.SupervisorNotified
                    ? `Submitted WorkReport ${outcome.Report.ID} and created supervisor review request ${requestID}.`
                    : `Submitted WorkReport ${outcome.Report.ID}.`,
            };
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            return failResult('ERROR', msg);
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

    protected async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('ERROR', 'ContextUser is required');

        const reportID = getStringParam(params, 'WorkReportID');
        if (!reportID || !IsValidUUID(reportID)) {
            return failResult('ERROR', 'Valid WorkReportID is required');
        }

        const feedback = getStringParam(params, 'SupervisorFeedback');
        if (!feedback) {
            return failResult('ERROR', 'SupervisorFeedback is required');
        }

        try {
            const reviewerPerson = await WorkReportService.Instance.ResolvePersonForUser(user);
            const callerIsPrivileged = IsPrivilegedWorkReportUser(user);
            if (!reviewerPerson?.ID && !callerIsPrivileged) {
                return failResult('ERROR', 'No active Person record is linked to ContextUser');
            }

            const outcome = await WorkReportService.Instance.RecordSupervisorReview({
                WorkReportID: reportID,
                ReviewerPersonID: reviewerPerson?.ID ?? null,
                SupervisorFeedback: feedback,
                ContextUser: user,
            });

            return {
                Success: true,
                ResultCode: 'SUCCESS',
                Message: `Recorded supervisor feedback on WorkReport ${outcome.Report.ID}.`,
            };
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            return failResult('ERROR', msg);
        }
    }
}
