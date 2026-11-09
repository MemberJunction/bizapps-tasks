import {
    BaseEntity,
    IMetadataProvider,
    IRunViewProvider,
    Metadata,
    RunView,
    UserInfo,
} from '@memberjunction/core';
import { BaseSingleton, IsValidUUID, UUIDsEqual } from '@memberjunction/global';
import type {
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksWorkReportEntity,
    mjBizAppsTasksWorkReportItemEntity,
} from '@mj-biz-apps/tasks-entities';

export const WORK_REPORTS_ENTITY_NAME = 'MJ_BizApps_Tasks: Work Reports';
export const WORK_REPORT_ITEMS_ENTITY_NAME = 'MJ_BizApps_Tasks: Work Report Items';
export const TASKS_ENTITY_NAME = 'MJ_BizApps_Tasks: Tasks';
export const TASK_ASSIGNMENTS_ENTITY_NAME = 'MJ_BizApps_Tasks: Task Assignments';
export const TASK_CHECK_INS_ENTITY_NAME = 'MJ_BizApps_Tasks: Task Check Ins';
export const TASK_ACTIVITIES_ENTITY_NAME = 'MJ_BizApps_Tasks: Task Activities';
export const PEOPLE_ENTITY_NAME = 'MJ_BizApps_Common: People';
export const EMPLOYEES_ENTITY_NAME = 'MJ: Employees';
export const USERS_ENTITY_NAME = 'MJ: Users';
export const AI_AGENTS_ENTITY_NAME = 'MJ: AI Agents';
export const AI_AGENT_REQUESTS_ENTITY_NAME = 'MJ: AI Agent Requests';
export const FIELD_SUGGESTIONS_ENTITY_NAME = 'MJ: Field Suggestions';

export type WorkReportStatus = mjBizAppsTasksWorkReportEntity['Status'];
export type WorkReportSection = mjBizAppsTasksWorkReportItemEntity['Section'];
export type WorkReportProvider = IMetadataProvider & IRunViewProvider;

export interface WorkReportPersonSummary {
    ID: string;
    FirstName: string;
    LastName: string;
    Email: string | null;
    LinkedUserID: string | null;
}

export interface SupervisorChainResolution {
    AuthorPersonID: string;
    AuthorEmail: string | null;
    EmployeeID: string | null;
    SupervisorEmployeeID: string | null;
    SupervisorEmail: string | null;
    SupervisorUserID: string | null;
    SupervisorPersonID: string | null;
    SupervisorName: string | null;
}

export interface WorkReportDraftItemInput {
    TaskID: string | null;
    Section: WorkReportSection;
    Summary: string;
}

export interface ActivityTaskSnapshot {
    ID: string;
    Name: string;
    Status: mjBizAppsTasksTaskEntity['Status'];
    Priority: mjBizAppsTasksTaskEntity['Priority'];
    PercentComplete: number;
    HoursActual: number | null;
    HealthStatus: mjBizAppsTasksTaskEntity['HealthStatus'];
    ParentID: string | null;
    DueAt: Date | null;
    CompletedAt: Date | null;
    UpdatedAt: Date | null;
    LatestCheckInSummary?: string | null;
}

export interface GetPersonTaskActivityParams {
    PersonID: string;
    PeriodStart: Date;
    PeriodEnd: Date;
    ContextUser?: UserInfo;
    Provider?: WorkReportProvider;
}

export interface PersonTaskActivitySummary {
    PersonID: string;
    PeriodStart: Date;
    PeriodEnd: Date;
    HasActivity: boolean;
    Completed: ActivityTaskSnapshot[];
    InProgress: ActivityTaskSnapshot[];
    Next: ActivityTaskSnapshot[];
    Blockers: ActivityTaskSnapshot[];
    AtRisk: ActivityTaskSnapshot[];
    Items: WorkReportDraftItemInput[];
    SuggestedTitle: string;
    SuggestedBody: string;
}

export interface DraftWorkReportParams {
    PersonID: string;
    PeriodStart: Date;
    PeriodEnd: Date;
    Title?: string | null;
    Body?: string | null;
    AuthoredByAgentRunID?: string | null;
    CustomItems?: WorkReportDraftItemInput[];
    SkipIfNoActivity?: boolean;
    ContextUser?: UserInfo;
    Provider?: WorkReportProvider;
}

export interface DraftWorkReportOutcome {
    SkippedNoActivity: boolean;
    Report: mjBizAppsTasksWorkReportEntity | null;
    Items: mjBizAppsTasksWorkReportItemEntity[];
    Activity: PersonTaskActivitySummary;
}

export interface SubmitWorkReportParams {
    WorkReportID: string;
    CallerPersonID?: string | null;
    Title?: string | null;
    Body?: string | null;
    CreateSupervisorAgentRequest?: boolean;
    ContextUser?: UserInfo;
    Provider?: WorkReportProvider;
}

export interface SubmitWorkReportOutcome {
    Report: mjBizAppsTasksWorkReportEntity;
    Supervisor: SupervisorChainResolution;
    SupervisorRequestID: string | null;
}

export interface RecordSupervisorReviewParams {
    WorkReportID: string;
    ReviewerPersonID: string;
    SupervisorFeedback: string;
    EnforceReportingLine?: boolean;
    ContextUser?: UserInfo;
    Provider?: WorkReportProvider;
}

export interface RecordSupervisorReviewOutcome {
    Report: mjBizAppsTasksWorkReportEntity;
    Supervisor: SupervisorChainResolution;
}

export interface WorkReportViewModel {
    ID: string;
    PersonID: string;
    PersonName: string;
    PeriodStart: string;
    PeriodEnd: string;
    Title: string;
    Body: string;
    Status: WorkReportStatus;
    SupervisorFeedback: string | null;
    ReviewedByPersonID: string | null;
    ReviewedByName: string | null;
    ReviewedAt: string | null;
    Items: {
        ID: string;
        TaskID: string | null;
        TaskName: string | null;
        Section: WorkReportSection;
        Summary: string;
        Sequence: number;
    }[];
}

export type WorkReportTabMode = 'mine' | 'team';
export type WorkReportStatusFilter = 'all' | WorkReportStatus;

interface RawEmployeeRow {
    ID: string;
    FirstName: string | null;
    LastName: string | null;
    Email: string | null;
    SupervisorID: string | null;
    Active: boolean | number | null;
}

interface RawUserRow {
    ID: string;
    Name: string | null;
    Email: string | null;
    LinkedEntityID?: string | null;
    LinkedEntityRecordID?: string | null;
}

interface RawTaskRow {
    ID: string;
    Name: string;
    Status: mjBizAppsTasksTaskEntity['Status'];
    Priority: mjBizAppsTasksTaskEntity['Priority'];
    PercentComplete: number | null;
    HoursActual: number | null;
    HealthStatus: mjBizAppsTasksTaskEntity['HealthStatus'];
    ParentID: string | null;
    DueAt: string | Date | null;
    CompletedAt: string | Date | null;
    __mj_UpdatedAt: string | Date | null;
}

interface AIAgentRequestFields {
    ID: string;
    AgentID: string;
    RequestedAt: Date;
    RequestForUserID: string | null;
    Status: string;
    Request: string;
    Priority: number;
    Comments: string | null;
}

function escapeSqlLiteral(value: string): string {
    return value.replace(/'/g, "''");
}

function assertValidUUID(value: string, label: string): void {
    if (!IsValidUUID(value)) {
        throw new Error(`${label} is not a valid UUID: ${value}`);
    }
}

function formatIsoDateOnly(d: Date): string {
    const year = d.getUTCFullYear();
    const month = String(d.getUTCMonth() + 1).padStart(2, '0');
    const day = String(d.getUTCDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

function resolveMetadataProvider(provider?: WorkReportProvider): IMetadataProvider {
    return provider ?? Metadata.Provider;
}

function createRunView(provider?: WorkReportProvider): RunView {
    return provider ? new RunView(provider) : new RunView();
}

/**
 * Loads counts of pending (`Outcome IS NULL AND IsResolved = 0`) MJ core Field Suggestions
 * anchored to `MJ_BizApps_Tasks: Tasks` rows. Returns a Map keyed by lowercased Task ID.
 *
 * Gracefully returns an empty map when `MJ: Field Suggestions` is not installed in metadata.
 */
export async function LoadPendingFieldSuggestionCountsForTasks(
    rv: RunView,
    tasksEntityID: string,
    taskIDs: readonly string[],
    contextUser?: UserInfo,
    provider?: IMetadataProvider
): Promise<Map<string, number>> {
    const counts = new Map<string, number>();
    if (!tasksEntityID || !IsValidUUID(tasksEntityID) || taskIDs.length === 0) {
        return counts;
    }

    const md = provider ?? Metadata.Provider;
    const hasFieldSuggestions = md?.Entities?.some((e) => e.Name === FIELD_SUGGESTIONS_ENTITY_NAME) ?? false;
    if (!hasFieldSuggestions) {
        return counts;
    }

    const validTaskIDs = taskIDs.filter((id) => IsValidUUID(id));
    if (validTaskIDs.length === 0) {
        return counts;
    }

    const quotedTaskIDs = validTaskIDs.map((id) => `'${id}'`).join(',');
    const result = await rv.RunView<{ ID: string; LinkedRecordID: string | null }>({
        EntityName: FIELD_SUGGESTIONS_ENTITY_NAME,
        ExtraFilter: `LinkedEntityID = '${tasksEntityID}' AND LinkedRecordID IN (${quotedTaskIDs}) AND Outcome IS NULL AND IsResolved = 0`,
        Fields: ['ID', 'LinkedRecordID'],
        ResultType: 'simple',
    }, contextUser);

    if (!result?.Success) {
        return counts;
    }

    for (const row of result.Results ?? []) {
        if (row.LinkedRecordID) {
            const key = row.LinkedRecordID.toLowerCase();
            counts.set(key, (counts.get(key) ?? 0) + 1);
        }
    }
    return counts;
}

/**
 * Pure filter helper for the Chief of Staff Work Reports surface.
 */
export function FilterWorkReports(
    reports: readonly WorkReportViewModel[],
    statusFilter: WorkReportStatusFilter,
    searchText: string
): WorkReportViewModel[] {
    const query = searchText.trim().toLowerCase();
    return reports.filter((r) => {
        if (statusFilter !== 'all' && r.Status !== statusFilter) {
            return false;
        }
        if (!query) {
            return true;
        }
        if (r.Title.toLowerCase().includes(query)) return true;
        if (r.PersonName.toLowerCase().includes(query)) return true;
        if (r.Body.toLowerCase().includes(query)) return true;
        if ((r.SupervisorFeedback ?? '').toLowerCase().includes(query)) return true;
        return r.Items.some((item) =>
            item.Summary.toLowerCase().includes(query) ||
            (item.TaskName ?? '').toLowerCase().includes(query)
        );
    });
}

/**
 * Pure agent-context builder for the Chief of Staff Work Reports surface.
 */
export function BuildWorkReportsAgentContext(params: {
    ActiveTab: WorkReportTabMode;
    StatusFilter: WorkReportStatusFilter;
    SearchText: string;
    MyReports: readonly WorkReportViewModel[];
    TeamReports: readonly WorkReportViewModel[];
    FilteredCount: number;
    SelectedReportID: string | null;
}): Record<string, unknown> {
    const source = params.ActiveTab === 'mine' ? params.MyReports : params.TeamReports;
    const selected = params.SelectedReportID
        ? source.find((r) => UUIDsEqual(r.ID, params.SelectedReportID!)) ?? null
        : null;
    return {
        Surface: 'ChiefOfStaffWorkReports',
        ActiveTab: params.ActiveTab,
        StatusFilter: params.StatusFilter,
        SearchText: params.SearchText,
        MyReportCount: params.MyReports.length,
        MyDraftCount: params.MyReports.filter((r) => r.Status === 'Draft').length,
        TeamPendingReviewCount: params.TeamReports.filter((r) => r.Status === 'Submitted').length,
        TeamTotalCount: params.TeamReports.length,
        FilteredCount: params.FilteredCount,
        SelectedReport: selected
            ? {
                  ID: selected.ID,
                  Title: selected.Title,
                  PersonName: selected.PersonName,
                  PeriodStart: selected.PeriodStart,
                  PeriodEnd: selected.PeriodEnd,
                  Status: selected.Status,
                  ItemCount: selected.Items.length,
              }
            : null,
        RecentTitles: source.slice(0, 15).map((r) => `${r.Title} (${r.Status})`),
    };
}

/**
 * Synthesizes a concise, 5-minute Markdown report body from structured section snapshots.
 */
export function BuildWorkReportMarkdown(sections: {
    Completed: readonly ActivityTaskSnapshot[];
    InProgress: readonly ActivityTaskSnapshot[];
    Next: readonly ActivityTaskSnapshot[];
    Blockers: readonly ActivityTaskSnapshot[];
    AtRisk: readonly ActivityTaskSnapshot[];
}): string {
    const blocks: string[] = [];

    if (sections.Completed.length > 0) {
        blocks.push(
            '### Completed\n' +
                sections.Completed.map((t) => `- **${t.Name}**${t.HoursActual ? ` (${t.HoursActual}h)` : ''}`).join('\n')
        );
    }

    if (sections.InProgress.length > 0) {
        blocks.push(
            '### In Progress\n' +
                sections.InProgress.map((t) => {
                    const checkIn = t.LatestCheckInSummary ? ` — ${t.LatestCheckInSummary}` : '';
                    return `- **${t.Name}** (${t.PercentComplete}%)${checkIn}`;
                }).join('\n')
        );
    }

    if (sections.Next.length > 0) {
        blocks.push(
            '### Next\n' +
                sections.Next.map((t) => `- **${t.Name}**${t.DueAt ? ` (due ${formatIsoDateOnly(t.DueAt)})` : ''}`).join('\n')
        );
    }

    if (sections.Blockers.length > 0) {
        blocks.push(
            '### Blockers\n' +
                sections.Blockers.map((t) => {
                    const detail = t.LatestCheckInSummary ? ` — ${t.LatestCheckInSummary}` : '';
                    return `- **${t.Name}**${detail}`;
                }).join('\n')
        );
    }

    if (sections.AtRisk.length > 0) {
        blocks.push(
            '### At-Risk Objectives\n' +
                sections.AtRisk.map((t) => `- **${t.Name}** (${t.HealthStatus ?? 'AtRisk'}, ${t.PercentComplete}%)`).join('\n')
        );
    }

    return blocks.length > 0
        ? blocks.join('\n\n')
        : '_No task updates recorded during this reporting window._';
}

/**
 * Service coordinating daily/periodic 15Five work reports (`MJ_BizApps_Tasks: Work Reports`),
 * zero-activity wake skipping, supervisor reporting-line lookup via `MJ: Employees.SupervisorID`,
 * inter-agent review requests, and supervisor feedback recording.
 */
export class WorkReportService extends BaseSingleton<WorkReportService> {
    public constructor() {
        super();
    }

    public static get Instance(): WorkReportService {
        return WorkReportService.getInstance<WorkReportService>();
    }

    /**
     * Resolves the active `MJ_BizApps_Common: People` record linked to a user.
     */
    public async ResolvePersonForUser(
        user: UserInfo,
        provider?: WorkReportProvider
    ): Promise<WorkReportPersonSummary | null> {
        if (!user?.ID || !IsValidUUID(user.ID)) {
            return null;
        }
        const md = resolveMetadataProvider(provider);
        const rv = createRunView(provider);

        const rawLinkedEntityID = user.LinkedEntityID as unknown as string | null | undefined;
        const rawLinkedRecordID = user.LinkedEntityRecordID as unknown as string | null | undefined;
        let linkedPersonID: string | null = null;
        if (rawLinkedEntityID && rawLinkedRecordID && IsValidUUID(rawLinkedRecordID)) {
            const ent = md.Entities.find((e) => UUIDsEqual(e.ID, rawLinkedEntityID));
            if (ent && (ent.Name === PEOPLE_ENTITY_NAME || ent.ParentChain.some((p) => p.Name === PEOPLE_ENTITY_NAME))) {
                linkedPersonID = rawLinkedRecordID;
            }
        }

        const filter = linkedPersonID
            ? `ID = '${linkedPersonID}' AND Status = 'Active'`
            : `LinkedUserID = '${user.ID}' AND Status = 'Active'`;
        const res = await rv.RunView<WorkReportPersonSummary>({
            EntityName: PEOPLE_ENTITY_NAME,
            ExtraFilter: filter,
            Fields: ['ID', 'FirstName', 'LastName', 'Email', 'LinkedUserID'],
            ResultType: 'simple',
            MaxRows: 1,
        }, user);

        if (!res?.Success) {
            throw new Error(`Person lookup failed: ${res?.ErrorMessage ?? 'unknown error'}`);
        }
        return res.Results?.[0] ?? null;
    }

    /**
     * Resolves a person's reporting line via core MJ's `MJ: Employees.SupervisorID`,
     * matching employee emails case-insensitively to `MJ: Users` and `MJ_BizApps_Common: People`.
     */
    public async ResolveSupervisorChainForPerson(
        personID: string,
        contextUser?: UserInfo,
        provider?: WorkReportProvider
    ): Promise<SupervisorChainResolution> {
        assertValidUUID(personID, 'PersonID');
        const rv = createRunView(provider);

        const empty: SupervisorChainResolution = {
            AuthorPersonID: personID,
            AuthorEmail: null,
            EmployeeID: null,
            SupervisorEmployeeID: null,
            SupervisorEmail: null,
            SupervisorUserID: null,
            SupervisorPersonID: null,
            SupervisorName: null,
        };

        const personRes = await rv.RunView<WorkReportPersonSummary>({
            EntityName: PEOPLE_ENTITY_NAME,
            ExtraFilter: `ID = '${personID}'`,
            Fields: ['ID', 'FirstName', 'LastName', 'Email', 'LinkedUserID'],
            ResultType: 'simple',
            MaxRows: 1,
        }, contextUser);
        const person = personRes?.Results?.[0];
        if (!person) {
            return empty;
        }

        let authorEmail = person.Email?.trim() || null;
        if (!authorEmail && person.LinkedUserID && IsValidUUID(person.LinkedUserID)) {
            const userRes = await rv.RunView<RawUserRow>({
                EntityName: USERS_ENTITY_NAME,
                ExtraFilter: `ID = '${person.LinkedUserID}'`,
                Fields: ['ID', 'Name', 'Email'],
                ResultType: 'simple',
                MaxRows: 1,
            }, contextUser);
            authorEmail = userRes?.Results?.[0]?.Email?.trim() || null;
        }
        empty.AuthorEmail = authorEmail;
        if (!authorEmail) {
            return empty;
        }

        const empRes = await rv.RunView<RawEmployeeRow>({
            EntityName: EMPLOYEES_ENTITY_NAME,
            ExtraFilter: `LOWER(Email) = LOWER('${escapeSqlLiteral(authorEmail)}')`,
            Fields: ['ID', 'FirstName', 'LastName', 'Email', 'SupervisorID', 'Active'],
            OrderBy: 'Active DESC',
            ResultType: 'simple',
            MaxRows: 1,
        }, contextUser);
        const emp = empRes?.Results?.[0];
        if (!emp) {
            return empty;
        }
        empty.EmployeeID = emp.ID;
        if (!emp.SupervisorID || !IsValidUUID(emp.SupervisorID)) {
            return empty;
        }
        empty.SupervisorEmployeeID = emp.SupervisorID;

        const supEmpRes = await rv.RunView<RawEmployeeRow>({
            EntityName: EMPLOYEES_ENTITY_NAME,
            ExtraFilter: `ID = '${emp.SupervisorID}'`,
            Fields: ['ID', 'FirstName', 'LastName', 'Email', 'Active'],
            ResultType: 'simple',
            MaxRows: 1,
        }, contextUser);
        const supEmp = supEmpRes?.Results?.[0];
        if (!supEmp) {
            return empty;
        }
        const supEmail = supEmp.Email?.trim() || null;
        empty.SupervisorEmail = supEmail;
        empty.SupervisorName = [supEmp.FirstName, supEmp.LastName].filter(Boolean).join(' ').trim() || null;
        if (!supEmail) {
            return empty;
        }

        const escapedSupEmail = escapeSqlLiteral(supEmail);
        const [supUserRes, supPersonByEmailRes] = await Promise.all([
            rv.RunView<RawUserRow>({
                EntityName: USERS_ENTITY_NAME,
                ExtraFilter: `LOWER(Email) = LOWER('${escapedSupEmail}') AND IsActive = 1`,
                Fields: ['ID', 'Name', 'Email'],
                ResultType: 'simple',
                MaxRows: 1,
            }, contextUser),
            rv.RunView<WorkReportPersonSummary>({
                EntityName: PEOPLE_ENTITY_NAME,
                ExtraFilter: `LOWER(Email) = LOWER('${escapedSupEmail}') AND Status = 'Active'`,
                Fields: ['ID', 'FirstName', 'LastName', 'Email', 'LinkedUserID'],
                ResultType: 'simple',
                MaxRows: 1,
            }, contextUser),
        ]);

        const supUser = supUserRes?.Results?.[0] ?? null;
        empty.SupervisorUserID = supUser?.ID ?? null;

        let supPerson = supPersonByEmailRes?.Results?.[0] ?? null;
        if (!supPerson && supUser?.ID && IsValidUUID(supUser.ID)) {
            const supPersonByUserRes = await rv.RunView<WorkReportPersonSummary>({
                EntityName: PEOPLE_ENTITY_NAME,
                ExtraFilter: `LinkedUserID = '${supUser.ID}' AND Status = 'Active'`,
                Fields: ['ID', 'FirstName', 'LastName', 'Email', 'LinkedUserID'],
                ResultType: 'simple',
                MaxRows: 1,
            }, contextUser);
            supPerson = supPersonByUserRes?.Results?.[0] ?? null;
        }

        if (supPerson) {
            empty.SupervisorPersonID = supPerson.ID;
            empty.SupervisorName = `${supPerson.FirstName} ${supPerson.LastName}`.trim() || empty.SupervisorName;
        }
        return empty;
    }

    /**
     * Resolves all active `MJ_BizApps_Common: People` IDs who report directly to `supervisorPersonID`
     * according to `MJ: Employees.SupervisorID` matched by email.
     */
    public async ResolveDirectReportPersonIDs(
        supervisorPersonID: string,
        contextUser?: UserInfo,
        provider?: WorkReportProvider
    ): Promise<string[]> {
        assertValidUUID(supervisorPersonID, 'SupervisorPersonID');
        const rv = createRunView(provider);

        const supPersonRes = await rv.RunView<WorkReportPersonSummary>({
            EntityName: PEOPLE_ENTITY_NAME,
            ExtraFilter: `ID = '${supervisorPersonID}'`,
            Fields: ['ID', 'Email', 'LinkedUserID'],
            ResultType: 'simple',
            MaxRows: 1,
        }, contextUser);
        const supPerson = supPersonRes?.Results?.[0];
        if (!supPerson) {
            return [];
        }

        let supEmail = supPerson.Email?.trim() || null;
        if (!supEmail && supPerson.LinkedUserID && IsValidUUID(supPerson.LinkedUserID)) {
            const userRes = await rv.RunView<RawUserRow>({
                EntityName: USERS_ENTITY_NAME,
                ExtraFilter: `ID = '${supPerson.LinkedUserID}'`,
                Fields: ['ID', 'Email'],
                ResultType: 'simple',
                MaxRows: 1,
            }, contextUser);
            supEmail = userRes?.Results?.[0]?.Email?.trim() || null;
        }
        if (!supEmail) {
            return [];
        }

        const supEmpRes = await rv.RunView<RawEmployeeRow>({
            EntityName: EMPLOYEES_ENTITY_NAME,
            ExtraFilter: `LOWER(Email) = LOWER('${escapeSqlLiteral(supEmail)}')`,
            Fields: ['ID', 'Email', 'Active'],
            OrderBy: 'Active DESC',
            ResultType: 'simple',
            MaxRows: 1,
        }, contextUser);
        const supEmp = supEmpRes?.Results?.[0];
        if (!supEmp?.ID || !IsValidUUID(supEmp.ID)) {
            return [];
        }

        const directEmpsRes = await rv.RunView<RawEmployeeRow>({
            EntityName: EMPLOYEES_ENTITY_NAME,
            ExtraFilter: `SupervisorID = '${supEmp.ID}' AND Active = 1`,
            Fields: ['ID', 'Email'],
            ResultType: 'simple',
        }, contextUser);
        const emails = (directEmpsRes?.Results ?? [])
            .map((e) => e.Email?.trim().toLowerCase() || '')
            .filter((e) => e.length > 0);
        if (emails.length === 0) {
            return [];
        }

        const quotedEmails = emails.map((e) => `'${escapeSqlLiteral(e)}'`).join(',');
        const [peopleByEmail, usersByEmail] = await Promise.all([
            rv.RunView<{ ID: string }>({
                EntityName: PEOPLE_ENTITY_NAME,
                ExtraFilter: `LOWER(Email) IN (${quotedEmails}) AND Status = 'Active'`,
                Fields: ['ID'],
                ResultType: 'simple',
            }, contextUser),
            rv.RunView<{ ID: string }>({
                EntityName: USERS_ENTITY_NAME,
                ExtraFilter: `LOWER(Email) IN (${quotedEmails}) AND IsActive = 1`,
                Fields: ['ID'],
                ResultType: 'simple',
            }, contextUser),
        ]);

        const personIDs = new Map<string, string>();
        for (const p of peopleByEmail?.Results ?? []) {
            personIDs.set(p.ID.toLowerCase(), p.ID);
        }

        const userIDs = (usersByEmail?.Results ?? []).map((u) => u.ID).filter((id) => IsValidUUID(id));
        if (userIDs.length > 0) {
            const quotedUserIDs = userIDs.map((id) => `'${id}'`).join(',');
            const peopleByUser = await rv.RunView<{ ID: string }>({
                EntityName: PEOPLE_ENTITY_NAME,
                ExtraFilter: `LinkedUserID IN (${quotedUserIDs}) AND Status = 'Active'`,
                Fields: ['ID'],
                ResultType: 'simple',
            }, contextUser);
            for (const p of peopleByUser?.Results ?? []) {
                personIDs.set(p.ID.toLowerCase(), p.ID);
            }
        }

        return Array.from(personIDs.values());
    }

    /**
     * Collects a person's task activity within `[PeriodStart, PeriodEnd]` across assigned and
     * authored tasks, `TaskCheckIn` rows, and `TaskActivity` entries, returning `HasActivity`
     * (used by the wake gate to skip empty reports) and structured 15Five report sections.
     */
    public async GetPersonTaskActivityForWindow(
        params: GetPersonTaskActivityParams
    ): Promise<PersonTaskActivitySummary> {
        assertValidUUID(params.PersonID, 'PersonID');
        const md = resolveMetadataProvider(params.Provider);
        const rv = createRunView(params.Provider);
        const peopleEntity = md.Entities.find((e) => e.Name === PEOPLE_ENTITY_NAME);

        const startMs = new Date(params.PeriodStart).getTime();
        // Expand date-only PeriodEnd to end-of-day UTC when passed as midnight UTC equal to PeriodStart
        let endMs = new Date(params.PeriodEnd).getTime();
        if (endMs <= startMs) {
            endMs = startMs + 24 * 60 * 60 * 1000 - 1;
        }
        const isoStart = new Date(startMs).toISOString();
        const isoEnd = new Date(endMs).toISOString();

        const assignmentFilter = peopleEntity
            ? `AssigneeEntityID = '${peopleEntity.ID}' AND AssigneeRecordID = '${params.PersonID}'`
            : `AssigneeRecordID = '${params.PersonID}'`;
        const assignmentsRes = await rv.RunView<{ TaskID: string }>({
            EntityName: TASK_ASSIGNMENTS_ENTITY_NAME,
            ExtraFilter: assignmentFilter,
            Fields: ['TaskID'],
            ResultType: 'simple',
        }, params.ContextUser);

        const assignedTaskIDs = (assignmentsRes?.Results ?? [])
            .map((a) => a.TaskID)
            .filter((id) => IsValidUUID(id));

        const scopeClauses: string[] = [`CreatedByPersonID = '${params.PersonID}'`];
        if (assignedTaskIDs.length > 0) {
            scopeClauses.push(`ID IN (${assignedTaskIDs.map((id) => `'${id}'`).join(',')})`);
        }

        const tasksRes = await rv.RunView<RawTaskRow>({
            EntityName: TASKS_ENTITY_NAME,
            ExtraFilter: `(${scopeClauses.join(' OR ')})`,
            Fields: [
                'ID',
                'Name',
                'Status',
                'Priority',
                'PercentComplete',
                'HoursActual',
                'HealthStatus',
                'ParentID',
                'DueAt',
                'CompletedAt',
                '__mj_UpdatedAt',
            ],
            OrderBy: 'DueAt ASC, Name ASC',
            ResultType: 'simple',
        }, params.ContextUser);

        const scopedTasks = tasksRes?.Results ?? [];
        const scopedTaskIDs = scopedTasks.map((t) => t.ID).filter((id) => IsValidUUID(id));
        const checkInMap = new Map<string, string>();
        const activeTaskIDSet = new Set<string>();

        if (scopedTaskIDs.length > 0) {
            const quotedTaskIDs = scopedTaskIDs.map((id) => `'${id}'`).join(',');
            const [checkInsRes, activitiesRes] = await Promise.all([
                rv.RunView<{ TaskID: string; Summary: string | null; __mj_CreatedAt: string | Date }>({
                    EntityName: TASK_CHECK_INS_ENTITY_NAME,
                    ExtraFilter: `TaskID IN (${quotedTaskIDs}) AND __mj_CreatedAt >= '${isoStart}' AND __mj_CreatedAt <= '${isoEnd}'`,
                    Fields: ['TaskID', 'Summary', '__mj_CreatedAt'],
                    OrderBy: '__mj_CreatedAt DESC',
                    ResultType: 'simple',
                }, params.ContextUser),
                rv.RunView<{ TaskID: string }>({
                    EntityName: TASK_ACTIVITIES_ENTITY_NAME,
                    ExtraFilter: `TaskID IN (${quotedTaskIDs}) AND __mj_CreatedAt >= '${isoStart}' AND __mj_CreatedAt <= '${isoEnd}'`,
                    Fields: ['TaskID'],
                    ResultType: 'simple',
                }, params.ContextUser),
            ]);

            for (const ci of checkInsRes?.Results ?? []) {
                const key = ci.TaskID.toLowerCase();
                activeTaskIDSet.add(key);
                if (!checkInMap.has(key) && ci.Summary) {
                    checkInMap.set(key, ci.Summary);
                }
            }
            for (const act of activitiesRes?.Results ?? []) {
                activeTaskIDSet.add(act.TaskID.toLowerCase());
            }
        }

        const completed: ActivityTaskSnapshot[] = [];
        const inProgress: ActivityTaskSnapshot[] = [];
        const next: ActivityTaskSnapshot[] = [];
        const blockers: ActivityTaskSnapshot[] = [];
        const atRisk: ActivityTaskSnapshot[] = [];
        let changedInWindowCount = 0;

        for (const row of scopedTasks) {
            const updatedAt = row.__mj_UpdatedAt ? new Date(row.__mj_UpdatedAt) : null;
            const completedAt = row.CompletedAt ? new Date(row.CompletedAt) : null;
            const dueAt = row.DueAt ? new Date(row.DueAt) : null;
            const key = row.ID.toLowerCase();

            const updatedInWindow =
                (updatedAt != null && updatedAt.getTime() >= startMs && updatedAt.getTime() <= endMs) ||
                (completedAt != null && completedAt.getTime() >= startMs && completedAt.getTime() <= endMs) ||
                activeTaskIDSet.has(key);

            if (updatedInWindow) {
                changedInWindowCount++;
            }

            const snapshot: ActivityTaskSnapshot = {
                ID: row.ID,
                Name: row.Name,
                Status: row.Status,
                Priority: row.Priority,
                PercentComplete: row.PercentComplete ?? 0,
                HoursActual: row.HoursActual ?? null,
                HealthStatus: row.HealthStatus,
                ParentID: row.ParentID,
                DueAt: dueAt,
                CompletedAt: completedAt,
                UpdatedAt: updatedAt,
                LatestCheckInSummary: checkInMap.get(key) ?? null,
            };

            if (row.HealthStatus === 'AtRisk' || row.HealthStatus === 'OffTrack') {
                atRisk.push(snapshot);
            }

            if (row.Status === 'Completed' && updatedInWindow) {
                completed.push(snapshot);
            } else if (row.Status === 'Blocked' && updatedInWindow) {
                blockers.push(snapshot);
            } else if (row.Status === 'InProgress' && updatedInWindow) {
                inProgress.push(snapshot);
            } else if (row.Status === 'Open' && updatedInWindow) {
                next.push(snapshot);
            }
        }

        const hasActivity = changedInWindowCount > 0;
        const items: WorkReportDraftItemInput[] = [];
        for (const t of completed) {
            items.push({
                TaskID: t.ID,
                Section: 'Completed',
                Summary: `${t.Name}${t.HoursActual ? ` (${t.HoursActual}h)` : ''}`,
            });
        }
        for (const t of inProgress) {
            items.push({
                TaskID: t.ID,
                Section: 'InProgress',
                Summary: `${t.Name} (${t.PercentComplete}%)${t.LatestCheckInSummary ? ` — ${t.LatestCheckInSummary}` : ''}`,
            });
        }
        for (const t of next) {
            items.push({
                TaskID: t.ID,
                Section: 'Next',
                Summary: `${t.Name}${t.DueAt ? ` (due ${formatIsoDateOnly(t.DueAt)})` : ''}`,
            });
        }
        for (const t of blockers) {
            items.push({
                TaskID: t.ID,
                Section: 'Blockers',
                Summary: `${t.Name}${t.LatestCheckInSummary ? ` — ${t.LatestCheckInSummary}` : ''}`,
            });
        }
        for (const t of atRisk) {
            if (hasActivity) {
                items.push({
                    TaskID: t.ID,
                    Section: 'AtRisk',
                    Summary: `${t.Name} (${t.HealthStatus ?? 'AtRisk'}, ${t.PercentComplete}%)`,
                });
            }
        }

        const dateLabel = formatIsoDateOnly(new Date(startMs));
        return {
            PersonID: params.PersonID,
            PeriodStart: new Date(startMs),
            PeriodEnd: new Date(endMs),
            HasActivity: hasActivity,
            Completed: completed,
            InProgress: inProgress,
            Next: next,
            Blockers: blockers,
            AtRisk: hasActivity ? atRisk : [],
            Items: items,
            SuggestedTitle: `Daily 15Five — ${dateLabel}`,
            SuggestedBody: BuildWorkReportMarkdown({
                Completed: completed,
                InProgress: inProgress,
                Next: next,
                Blockers: blockers,
                AtRisk: hasActivity ? atRisk : [],
            }),
        };
    }

    /**
     * Drafts a new `WorkReport` (`Status = 'Draft'`) and its `WorkReportItem` lines.
     * When `SkipIfNoActivity` is true (default) and no task activity occurred in the window,
     * returns `{ SkippedNoActivity: true, Report: null }` without persisting any rows.
     */
    public async DraftWorkReport(params: DraftWorkReportParams): Promise<DraftWorkReportOutcome> {
        assertValidUUID(params.PersonID, 'PersonID');
        if (params.AuthoredByAgentRunID) {
            assertValidUUID(params.AuthoredByAgentRunID, 'AuthoredByAgentRunID');
        }

        const activity = await this.GetPersonTaskActivityForWindow({
            PersonID: params.PersonID,
            PeriodStart: params.PeriodStart,
            PeriodEnd: params.PeriodEnd,
            ContextUser: params.ContextUser,
            Provider: params.Provider,
        });

        const skipIfEmpty = params.SkipIfNoActivity !== false;
        const hasCustomContent = Boolean(params.Body?.trim()) || Boolean(params.CustomItems?.length);
        if (skipIfEmpty && !activity.HasActivity && !hasCustomContent) {
            return {
                SkippedNoActivity: true,
                Report: null,
                Items: [],
                Activity: activity,
            };
        }

        const md = resolveMetadataProvider(params.Provider);
        const report = await md.GetEntityObject<mjBizAppsTasksWorkReportEntity>(
            WORK_REPORTS_ENTITY_NAME,
            params.ContextUser
        );
        report.NewRecord();
        report.PersonID = params.PersonID;
        report.PeriodStart = params.PeriodStart;
        report.PeriodEnd = params.PeriodEnd;
        report.Title = params.Title?.trim() || activity.SuggestedTitle;
        report.Body = params.Body?.trim() || activity.SuggestedBody;
        report.Status = 'Draft';
        if (params.AuthoredByAgentRunID) {
            report.AuthoredByAgentRunID = params.AuthoredByAgentRunID;
        }

        const reportSaved = await report.Save();
        if (!reportSaved) {
            throw new Error(
                `Failed to save Draft WorkReport: ${report.LatestResult?.CompleteMessage ?? 'unknown error'}`
            );
        }

        const sourceItems = params.CustomItems ?? activity.Items;
        const savedItems: mjBizAppsTasksWorkReportItemEntity[] = [];
        for (let i = 0; i < sourceItems.length; i++) {
            const raw = sourceItems[i];
            if (raw.TaskID) {
                assertValidUUID(raw.TaskID, 'WorkReportItem.TaskID');
            }
            const item = await md.GetEntityObject<mjBizAppsTasksWorkReportItemEntity>(
                WORK_REPORT_ITEMS_ENTITY_NAME,
                params.ContextUser
            );
            item.NewRecord();
            item.WorkReportID = report.ID;
            item.TaskID = raw.TaskID;
            item.Section = raw.Section;
            item.Summary = raw.Summary;
            item.Sequence = i + 1;
            const itemSaved = await item.Save();
            if (!itemSaved) {
                throw new Error(
                    `Failed to save WorkReportItem: ${item.LatestResult?.CompleteMessage ?? 'unknown error'}`
                );
            }
            savedItems.push(item);
        }

        return {
            SkippedNoActivity: false,
            Report: report,
            Items: savedItems,
            Activity: activity,
        };
    }

    /**
     * Transitions a `Draft` WorkReport to `Submitted` after human author approval and
     * dispatches an inter-agent review request to the supervisor's Chief of Staff.
     */
    public async SubmitWorkReport(params: SubmitWorkReportParams): Promise<SubmitWorkReportOutcome> {
        assertValidUUID(params.WorkReportID, 'WorkReportID');
        if (params.CallerPersonID) {
            assertValidUUID(params.CallerPersonID, 'CallerPersonID');
        }

        const md = resolveMetadataProvider(params.Provider);
        const report = await md.GetEntityObject<mjBizAppsTasksWorkReportEntity>(
            WORK_REPORTS_ENTITY_NAME,
            params.ContextUser
        );
        const loaded = await report.Load(params.WorkReportID);
        if (!loaded) {
            throw new Error(`WorkReport not found: ${params.WorkReportID}`);
        }
        if (params.CallerPersonID && !UUIDsEqual(report.PersonID, params.CallerPersonID)) {
            throw new Error('Only the report author can approve and submit this work report.');
        }
        if (report.Status !== 'Draft') {
            throw new Error(`Only Draft work reports can be submitted (current status: ${report.Status}).`);
        }

        if (params.Title !== undefined && params.Title !== null && params.Title.trim().length > 0) {
            report.Title = params.Title.trim();
        }
        if (params.Body !== undefined && params.Body !== null && params.Body.trim().length > 0) {
            report.Body = params.Body.trim();
        }
        report.Status = 'Submitted';

        const saved = await report.Save();
        if (!saved) {
            throw new Error(
                `Failed to submit WorkReport: ${report.LatestResult?.CompleteMessage ?? 'unknown error'}`
            );
        }

        const supervisor = await this.ResolveSupervisorChainForPerson(
            report.PersonID,
            params.ContextUser,
            params.Provider
        );

        let supervisorRequestID: string | null = null;
        if (params.CreateSupervisorAgentRequest !== false && supervisor.SupervisorUserID) {
            supervisorRequestID = await this.createSupervisorReviewAgentRequest(
                report,
                supervisor,
                params.ContextUser,
                params.Provider
            );
        }

        return {
            Report: report,
            Supervisor: supervisor,
            SupervisorRequestID: supervisorRequestID,
        };
    }

    /**
     * Records approved supervisor feedback on a `Submitted` (or `Reviewed`) WorkReport,
     * enforcing reporting-line ownership via `MJ: Employees.SupervisorID` when configured.
     */
    public async RecordSupervisorReview(
        params: RecordSupervisorReviewParams
    ): Promise<RecordSupervisorReviewOutcome> {
        assertValidUUID(params.WorkReportID, 'WorkReportID');
        assertValidUUID(params.ReviewerPersonID, 'ReviewerPersonID');

        const trimmedFeedback = params.SupervisorFeedback.trim();
        if (!trimmedFeedback) {
            throw new Error('SupervisorFeedback cannot be empty.');
        }

        const md = resolveMetadataProvider(params.Provider);
        const report = await md.GetEntityObject<mjBizAppsTasksWorkReportEntity>(
            WORK_REPORTS_ENTITY_NAME,
            params.ContextUser
        );
        const loaded = await report.Load(params.WorkReportID);
        if (!loaded) {
            throw new Error(`WorkReport not found: ${params.WorkReportID}`);
        }
        if (report.Status === 'Draft') {
            throw new Error('Draft work reports cannot receive supervisor review before author submission.');
        }
        if (UUIDsEqual(report.PersonID, params.ReviewerPersonID)) {
            throw new Error('A report author cannot submit supervisor feedback on their own work report.');
        }

        const supervisor = await this.ResolveSupervisorChainForPerson(
            report.PersonID,
            params.ContextUser,
            params.Provider
        );
        if (
            params.EnforceReportingLine !== false &&
            supervisor.SupervisorPersonID &&
            !UUIDsEqual(supervisor.SupervisorPersonID, params.ReviewerPersonID)
        ) {
            throw new Error('Caller is not the mapped supervisor for this report author.');
        }

        report.SupervisorFeedback = trimmedFeedback;
        report.ReviewedByPersonID = params.ReviewerPersonID;
        report.ReviewedAt = new Date();
        report.Status = 'Reviewed';

        const saved = await report.Save();
        if (!saved) {
            throw new Error(
                `Failed to save supervisor feedback: ${report.LatestResult?.CompleteMessage ?? 'unknown error'}`
            );
        }

        return {
            Report: report,
            Supervisor: supervisor,
        };
    }

    private async createSupervisorReviewAgentRequest(
        report: mjBizAppsTasksWorkReportEntity,
        supervisor: SupervisorChainResolution,
        contextUser?: UserInfo,
        provider?: WorkReportProvider
    ): Promise<string | null> {
        const md = resolveMetadataProvider(provider);
        const hasRequestsEntity = md.Entities.some((e) => e.Name === AI_AGENT_REQUESTS_ENTITY_NAME);
        if (!hasRequestsEntity || !supervisor.SupervisorUserID) {
            return null;
        }

        const rv = createRunView(provider);
        const cosAgentRes = await rv.RunView<{ ID: string }>({
            EntityName: AI_AGENTS_ENTITY_NAME,
            ExtraFilter: `Name = 'Chief of Staff' AND Status = 'Active'`,
            Fields: ['ID'],
            ResultType: 'simple',
            MaxRows: 1,
        }, contextUser);
        const cosAgentID = cosAgentRes?.Results?.[0]?.ID;
        if (!cosAgentID) {
            return null;
        }

        const reqEntity = await md.GetEntityObject<BaseEntity<AIAgentRequestFields>>(
            AI_AGENT_REQUESTS_ENTITY_NAME,
            contextUser
        );
        reqEntity.NewRecord();
        reqEntity.SetMany({
            AgentID: cosAgentID,
            RequestedAt: new Date(),
            RequestForUserID: supervisor.SupervisorUserID,
            Status: 'Requested',
            Priority: 50,
            Request: `Review submitted 15Five work report "${report.Title ?? report.ID}" (${formatIsoDateOnly(new Date(report.PeriodStart))} – ${formatIsoDateOnly(new Date(report.PeriodEnd))}) and draft feedback for supervisor approval.`,
            Comments: JSON.stringify({
                Kind: 'WorkReportSupervisorReview',
                WorkReportID: report.ID,
                AuthorPersonID: report.PersonID,
                SupervisorPersonID: supervisor.SupervisorPersonID,
            }),
        });
        const saved = await reqEntity.Save();
        return saved ? String(reqEntity.PrimaryKey.Values()[0]) : null;
    }
}
