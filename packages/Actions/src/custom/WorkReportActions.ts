import { BaseEntity, Metadata, RunView, UserInfo } from '@memberjunction/core';
import { ActionParam, ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import { IsValidUUID, RegisterClass, UUIDsEqual } from '@memberjunction/global';

export interface WorkReportEntityContract extends BaseEntity {
    ID: string;
    PersonID: string;
    PeriodStart: Date;
    PeriodEnd: Date;
    Title: string | null;
    Body: string;
    Status: 'Draft' | 'Reviewed' | 'Submitted';
    AuthoredByAgentRunID: string | null;
    SupervisorFeedback: string | null;
    ReviewedByPersonID: string | null;
    ReviewedAt: Date | null;
    Load(ID: string, EntityRelationshipsToLoad?: string[]): Promise<boolean>;
}

export interface WorkReportItemEntityContract extends BaseEntity {
    ID: string;
    WorkReportID: string;
    TaskID: string | null;
    Section: 'AtRisk' | 'Blockers' | 'Completed' | 'InProgress' | 'Next';
    Summary: string;
    Sequence: number;
}

interface SupervisorRequestEntityContract extends BaseEntity {
    ID: string;
    AgentID: string;
    RequestedAt: Date;
    RequestForUserID: string | null;
    Status: string;
    Priority: number;
    Request: string;
    Comments: string | null;
}

interface PersonRow {
    ID: string;
    FirstName: string;
    LastName: string;
    Email: string | null;
    LinkedUserID: string | null;
}

interface EmployeeRow {
    ID: string;
    FirstName: string | null;
    LastName: string | null;
    Email: string | null;
    SupervisorID: string | null;
    Active: boolean | number | null;
}

interface TaskActivityRow {
    ID: string;
    Name: string;
    Status: string;
    PercentComplete: number | null;
    HoursActual: number | null;
    HealthStatus: string | null;
    DueAt: string | Date | null;
    CompletedAt: string | Date | null;
    __mj_UpdatedAt: string | Date | null;
}

function escapeSql(val: string): string {
    return val.replace(/'/g, "''");
}

function getStringParam(params: RunActionParams, name: string): string | null {
    const found = params.Params.find((p) => p.Name.toLowerCase() === name.toLowerCase());
    if (!found || found.Value == null) return null;
    const str = String(found.Value).trim();
    return str.length > 0 ? str : null;
}

function setOutputParam(params: RunActionParams, name: string, value: string | null): void {
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

function formatDateOnly(d: Date): string {
    const y = d.getUTCFullYear();
    const m = String(d.getUTCMonth() + 1).padStart(2, '0');
    const day = String(d.getUTCDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
}

async function resolveCallerPersonID(user: UserInfo): Promise<string | null> {
    if (!user?.ID || !IsValidUUID(user.ID)) return null;
    const md = new Metadata();
    const rawEntityID = user.LinkedEntityID as unknown as string | null | undefined;
    const rawRecordID = user.LinkedEntityRecordID as unknown as string | null | undefined;
    let directID: string | null = null;
    if (rawEntityID && rawRecordID && IsValidUUID(rawRecordID)) {
        const ent = md.Entities.find((e) => UUIDsEqual(e.ID, rawEntityID));
        if (ent && (ent.Name === 'MJ_BizApps_Common: People' || ent.ParentChain.some((p) => p.Name === 'MJ_BizApps_Common: People'))) {
            directID = rawRecordID;
        }
    }
    const rv = new RunView();
    const res = await rv.RunView<{ ID: string }>({
        EntityName: 'MJ_BizApps_Common: People',
        ExtraFilter: directID
            ? `ID = '${directID}' AND Status = 'Active'`
            : `LinkedUserID = '${user.ID}' AND Status = 'Active'`,
        Fields: ['ID'],
        ResultType: 'simple',
        MaxRows: 1,
    }, user);
    return res?.Success ? res.Results?.[0]?.ID ?? null : null;
}

async function resolveSupervisorForPerson(
    personID: string,
    user: UserInfo
): Promise<{ SupervisorUserID: string | null; SupervisorPersonID: string | null }> {
    const rv = new RunView();
    const pRes = await rv.RunView<PersonRow>({
        EntityName: 'MJ_BizApps_Common: People',
        ExtraFilter: `ID = '${personID}'`,
        Fields: ['ID', 'FirstName', 'LastName', 'Email', 'LinkedUserID'],
        ResultType: 'simple',
        MaxRows: 1,
    }, user);
    const person = pRes?.Results?.[0];
    if (!person) return { SupervisorUserID: null, SupervisorPersonID: null };

    let email = person.Email?.trim() || null;
    if (!email && person.LinkedUserID && IsValidUUID(person.LinkedUserID)) {
        const uRes = await rv.RunView<{ Email: string | null }>({
            EntityName: 'MJ: Users',
            ExtraFilter: `ID = '${person.LinkedUserID}'`,
            Fields: ['Email'],
            ResultType: 'simple',
            MaxRows: 1,
        }, user);
        email = uRes?.Results?.[0]?.Email?.trim() || null;
    }
    if (!email) return { SupervisorUserID: null, SupervisorPersonID: null };

    const empRes = await rv.RunView<EmployeeRow>({
        EntityName: 'MJ: Employees',
        ExtraFilter: `LOWER(Email) = LOWER('${escapeSql(email)}')`,
        Fields: ['ID', 'SupervisorID', 'Active'],
        OrderBy: 'Active DESC',
        ResultType: 'simple',
        MaxRows: 1,
    }, user);
    const supEmpID = empRes?.Results?.[0]?.SupervisorID;
    if (!supEmpID || !IsValidUUID(supEmpID)) {
        return { SupervisorUserID: null, SupervisorPersonID: null };
    }

    const supEmpRes = await rv.RunView<EmployeeRow>({
        EntityName: 'MJ: Employees',
        ExtraFilter: `ID = '${supEmpID}'`,
        Fields: ['ID', 'Email'],
        ResultType: 'simple',
        MaxRows: 1,
    }, user);
    const supEmail = supEmpRes?.Results?.[0]?.Email?.trim();
    if (!supEmail) return { SupervisorUserID: null, SupervisorPersonID: null };

    const escaped = escapeSql(supEmail);
    const [supUserRes, supPersonRes] = await Promise.all([
        rv.RunView<{ ID: string }>({
            EntityName: 'MJ: Users',
            ExtraFilter: `LOWER(Email) = LOWER('${escaped}') AND IsActive = 1`,
            Fields: ['ID'],
            ResultType: 'simple',
            MaxRows: 1,
        }, user),
        rv.RunView<{ ID: string }>({
            EntityName: 'MJ_BizApps_Common: People',
            ExtraFilter: `LOWER(Email) = LOWER('${escaped}') AND Status = 'Active'`,
            Fields: ['ID'],
            ResultType: 'simple',
            MaxRows: 1,
        }, user),
    ]);

    const supUserID = supUserRes?.Results?.[0]?.ID ?? null;
    let supPersonID = supPersonRes?.Results?.[0]?.ID ?? null;
    if (!supPersonID && supUserID && IsValidUUID(supUserID)) {
        const byUser = await rv.RunView<{ ID: string }>({
            EntityName: 'MJ_BizApps_Common: People',
            ExtraFilter: `LinkedUserID = '${supUserID}' AND Status = 'Active'`,
            Fields: ['ID'],
            ResultType: 'simple',
            MaxRows: 1,
        }, user);
        supPersonID = byUser?.Results?.[0]?.ID ?? null;
    }
    return { SupervisorUserID: supUserID, SupervisorPersonID: supPersonID };
}

/**
 * Action: `Tasks.DraftWorkReport`
 *
 * Reads a person's task activity in `[PeriodStart, PeriodEnd]` and creates a `Draft`
 * `MJ_BizApps_Tasks: Work Reports` record plus `MJ_BizApps_Tasks: Work Report Items`.
 * Returns `NO_ACTIVITY` without writing a draft when no tasks changed in the window.
 */
@RegisterClass(BaseAction, 'Tasks.DraftWorkReport')
export class DraftWorkReportAction extends BaseAction {
    protected async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('ERROR', 'ContextUser is required');

        const explicitPersonID = getStringParam(params, 'PersonID');
        if (explicitPersonID && !IsValidUUID(explicitPersonID)) {
            return failResult('ERROR', 'PersonID is not a valid UUID');
        }
        const personID = explicitPersonID ?? (await resolveCallerPersonID(user));
        if (!personID) {
            return failResult('ERROR', 'No active Person record is linked to ContextUser');
        }

        const authoredByRunID = getStringParam(params, 'AuthoredByAgentRunID');
        if (authoredByRunID && !IsValidUUID(authoredByRunID)) {
            return failResult('ERROR', 'AuthoredByAgentRunID is not a valid UUID');
        }

        const now = new Date();
        const defaultStart = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), 0, 0, 0));
        const rawStart = getStringParam(params, 'PeriodStart');
        const rawEnd = getStringParam(params, 'PeriodEnd');
        const periodStart = rawStart ? new Date(rawStart) : defaultStart;
        const periodEnd = rawEnd ? new Date(rawEnd) : now;
        if (Number.isNaN(periodStart.getTime()) || Number.isNaN(periodEnd.getTime())) {
            return failResult('ERROR', 'PeriodStart or PeriodEnd is not a valid ISO-8601 date');
        }

        const startMs = periodStart.getTime();
        const endMs = periodEnd.getTime() <= startMs ? startMs + 24 * 60 * 60 * 1000 - 1 : periodEnd.getTime();
        const customBody = getStringParam(params, 'Body');

        const rv = new RunView();
        const assignments = await rv.RunView<{ TaskID: string }>({
            EntityName: 'MJ_BizApps_Tasks: Task Assignments',
            ExtraFilter: `AssigneeRecordID = '${personID}'`,
            Fields: ['TaskID'],
            ResultType: 'simple',
        }, user);
        const assignedIDs = (assignments?.Results ?? []).map((a) => a.TaskID).filter((id) => IsValidUUID(id));
        const clauses = [`CreatedByPersonID = '${personID}'`];
        if (assignedIDs.length > 0) {
            clauses.push(`ID IN (${assignedIDs.map((id) => `'${id}'`).join(',')})`);
        }

        const tasksRes = await rv.RunView<TaskActivityRow>({
            EntityName: 'MJ_BizApps_Tasks: Tasks',
            ExtraFilter: `(${clauses.join(' OR ')})`,
            Fields: ['ID', 'Name', 'Status', 'PercentComplete', 'HoursActual', 'HealthStatus', 'DueAt', 'CompletedAt', '__mj_UpdatedAt'],
            OrderBy: 'DueAt ASC, Name ASC',
            ResultType: 'simple',
        }, user);

        const changedTasks = (tasksRes?.Results ?? []).filter((t) => {
            const u = t.__mj_UpdatedAt ? new Date(t.__mj_UpdatedAt).getTime() : 0;
            const c = t.CompletedAt ? new Date(t.CompletedAt).getTime() : 0;
            return (u >= startMs && u <= endMs) || (c >= startMs && c <= endMs);
        });

        if (changedTasks.length === 0 && !customBody) {
            setOutputParam(params, 'WorkReportID', '');
            return {
                Success: true,
                ResultCode: 'NO_ACTIVITY',
                Message: 'No task activity occurred in the requested reporting window; skipped creating a draft.',
            };
        }

        const itemDrafts: { TaskID: string; Section: WorkReportItemEntityContract['Section']; Summary: string }[] = [];
        const linesBySection: Record<WorkReportItemEntityContract['Section'], string[]> = {
            Completed: [],
            InProgress: [],
            Next: [],
            Blockers: [],
            AtRisk: [],
        };

        for (const t of changedTasks) {
            const pct = t.PercentComplete ?? 0;
            if (t.Status === 'Completed') {
                const summary = `${t.Name}${t.HoursActual ? ` (${t.HoursActual}h)` : ''}`;
                itemDrafts.push({ TaskID: t.ID, Section: 'Completed', Summary: summary });
                linesBySection.Completed.push(`- **${summary}**`);
            } else if (t.Status === 'Blocked') {
                itemDrafts.push({ TaskID: t.ID, Section: 'Blockers', Summary: t.Name });
                linesBySection.Blockers.push(`- **${t.Name}**`);
            } else if (t.Status === 'InProgress') {
                const summary = `${t.Name} (${pct}%)`;
                itemDrafts.push({ TaskID: t.ID, Section: 'InProgress', Summary: summary });
                linesBySection.InProgress.push(`- **${summary}**`);
            } else if (t.Status === 'Open') {
                itemDrafts.push({ TaskID: t.ID, Section: 'Next', Summary: t.Name });
                linesBySection.Next.push(`- **${t.Name}**`);
            }
            if (t.HealthStatus === 'AtRisk' || t.HealthStatus === 'OffTrack') {
                const summary = `${t.Name} (${t.HealthStatus}, ${pct}%)`;
                itemDrafts.push({ TaskID: t.ID, Section: 'AtRisk', Summary: summary });
                linesBySection.AtRisk.push(`- **${summary}**`);
            }
        }

        const sectionBlocks: string[] = [];
        if (linesBySection.Completed.length > 0) sectionBlocks.push(`### Completed\n${linesBySection.Completed.join('\n')}`);
        if (linesBySection.InProgress.length > 0) sectionBlocks.push(`### In Progress\n${linesBySection.InProgress.join('\n')}`);
        if (linesBySection.Next.length > 0) sectionBlocks.push(`### Next\n${linesBySection.Next.join('\n')}`);
        if (linesBySection.Blockers.length > 0) sectionBlocks.push(`### Blockers\n${linesBySection.Blockers.join('\n')}`);
        if (linesBySection.AtRisk.length > 0) sectionBlocks.push(`### At-Risk Objectives\n${linesBySection.AtRisk.join('\n')}`);

        const md = new Metadata();
        const report = await md.GetEntityObject<WorkReportEntityContract>('MJ_BizApps_Tasks: Work Reports', user);
        report.NewRecord();
        report.PersonID = personID;
        report.PeriodStart = periodStart;
        report.PeriodEnd = periodEnd;
        report.Title = `Daily 15Five — ${formatDateOnly(periodStart)}`;
        report.Body = customBody ?? sectionBlocks.join('\n\n');
        report.Status = 'Draft';
        if (authoredByRunID) {
            report.AuthoredByAgentRunID = authoredByRunID;
        }
        if (!(await report.Save())) {
            return failResult('ERROR', `Failed to save Draft WorkReport: ${report.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }

        for (let i = 0; i < itemDrafts.length; i++) {
            const d = itemDrafts[i];
            const item = await md.GetEntityObject<WorkReportItemEntityContract>('MJ_BizApps_Tasks: Work Report Items', user);
            item.NewRecord();
            item.WorkReportID = report.ID;
            item.TaskID = d.TaskID;
            item.Section = d.Section;
            item.Summary = d.Summary;
            item.Sequence = i + 1;
            await item.Save();
        }

        setOutputParam(params, 'WorkReportID', report.ID);
        return {
            Success: true,
            ResultCode: 'SUCCESS',
            Message: `Drafted WorkReport ${report.ID} with ${itemDrafts.length} item(s).`,
        };
    }
}

/**
 * Action: `Tasks.SubmitWorkReport`
 *
 * Submits an author-approved `Draft` WorkReport and dispatches an inter-agent review request
 * to the supervisor's Chief of Staff resolved via `MJ: Employees.SupervisorID`.
 */
@RegisterClass(BaseAction, 'Tasks.SubmitWorkReport')
export class SubmitWorkReportAction extends BaseAction {
    protected async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('ERROR', 'ContextUser is required');

        const reportID = getStringParam(params, 'WorkReportID');
        if (!reportID || !IsValidUUID(reportID)) {
            return failResult('ERROR', 'Valid WorkReportID is required');
        }

        const md = new Metadata();
        const report = await md.GetEntityObject<WorkReportEntityContract>('MJ_BizApps_Tasks: Work Reports', user);
        if (!(await report.Load(reportID))) {
            return failResult('ERROR', `WorkReport not found: ${reportID}`);
        }
        if (report.Status !== 'Draft') {
            return failResult('ERROR', `Only Draft work reports can be submitted (current status: ${report.Status})`);
        }

        const callerPersonID = await resolveCallerPersonID(user);
        if (callerPersonID && !UUIDsEqual(report.PersonID, callerPersonID)) {
            return failResult('ERROR', 'Only the report author can approve and submit this work report');
        }

        const editedBody = getStringParam(params, 'Body');
        if (editedBody) {
            report.Body = editedBody;
        }
        report.Status = 'Submitted';
        if (!(await report.Save())) {
            return failResult('ERROR', `Failed to submit WorkReport: ${report.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }

        const supervisor = await resolveSupervisorForPerson(report.PersonID, user);
        let requestID: string | null = null;
        if (supervisor.SupervisorUserID && md.Entities.some((e) => e.Name === 'MJ: AI Agent Requests')) {
            const rv = new RunView();
            const cosRes = await rv.RunView<{ ID: string }>({
                EntityName: 'MJ: AI Agents',
                ExtraFilter: `Name = 'Chief of Staff' AND Status = 'Active'`,
                Fields: ['ID'],
                ResultType: 'simple',
                MaxRows: 1,
            }, user);
            const cosAgentID = cosRes?.Results?.[0]?.ID;
            if (cosAgentID) {
                const req = await md.GetEntityObject<SupervisorRequestEntityContract>('MJ: AI Agent Requests', user);
                req.NewRecord();
                req.AgentID = cosAgentID;
                req.RequestedAt = new Date();
                req.RequestForUserID = supervisor.SupervisorUserID;
                req.Status = 'Requested';
                req.Priority = 50;
                req.Request = `Review submitted 15Five work report "${report.Title ?? report.ID}" and draft supervisor feedback.`;
                req.Comments = JSON.stringify({
                    Kind: 'WorkReportSupervisorReview',
                    WorkReportID: report.ID,
                    AuthorPersonID: report.PersonID,
                    SupervisorPersonID: supervisor.SupervisorPersonID,
                });
                if (await req.Save()) {
                    requestID = req.ID;
                }
            }
        }

        setOutputParam(params, 'SupervisorRequestID', requestID ?? '');
        return {
            Success: true,
            ResultCode: 'SUCCESS',
            Message: requestID
                ? `Submitted WorkReport ${report.ID} and created supervisor review request ${requestID}.`
                : `Submitted WorkReport ${report.ID}.`,
        };
    }
}

/**
 * Action: `Tasks.ReviewWorkReport`
 *
 * Records supervisor-approved feedback on a `Submitted` WorkReport, enforcing reporting-line
 * ownership via `MJ: Employees.SupervisorID`.
 */
@RegisterClass(BaseAction, 'Tasks.ReviewWorkReport')
export class ReviewWorkReportAction extends BaseAction {
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

        const reviewerPersonID = await resolveCallerPersonID(user);
        if (!reviewerPersonID) {
            return failResult('ERROR', 'No active Person record is linked to ContextUser');
        }

        const md = new Metadata();
        const report = await md.GetEntityObject<WorkReportEntityContract>('MJ_BizApps_Tasks: Work Reports', user);
        if (!(await report.Load(reportID))) {
            return failResult('ERROR', `WorkReport not found: ${reportID}`);
        }
        if (report.Status === 'Draft') {
            return failResult('ERROR', 'Draft work reports cannot be reviewed before author submission');
        }
        if (UUIDsEqual(report.PersonID, reviewerPersonID)) {
            return failResult('ERROR', 'A report author cannot review their own work report');
        }

        const supervisor = await resolveSupervisorForPerson(report.PersonID, user);
        if (supervisor.SupervisorPersonID && !UUIDsEqual(supervisor.SupervisorPersonID, reviewerPersonID)) {
            return failResult('ERROR', 'ContextUser is not the mapped supervisor for this report author');
        }

        report.SupervisorFeedback = feedback;
        report.ReviewedByPersonID = reviewerPersonID;
        report.ReviewedAt = new Date();
        report.Status = 'Reviewed';
        if (!(await report.Save())) {
            return failResult('ERROR', `Failed to save supervisor feedback: ${report.LatestResult?.CompleteMessage ?? 'unknown error'}`);
        }

        return {
            Success: true,
            ResultCode: 'SUCCESS',
            Message: `Recorded supervisor feedback on WorkReport ${report.ID}.`,
        };
    }
}
