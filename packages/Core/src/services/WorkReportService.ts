import {
    BaseEntity,
    IMetadataProvider,
    IRunViewProvider,
    LogError,
    LogStatus,
    Metadata,
    RunView,
    UserInfo,
} from '@memberjunction/core';
import { BaseSingleton, EscapeSQLString, IsValidUUID, NormalizeUUID, UUIDsEqual } from '@memberjunction/global';
import type {
    mjBizAppsTasksWorkReportEntity,
    mjBizAppsTasksWorkReportItemEntity,
} from '@mj-biz-apps/tasks-entities';

export type WorkReportStatus = mjBizAppsTasksWorkReportEntity['Status'];
export type WorkReportItemSection = mjBizAppsTasksWorkReportItemEntity['Section'];
export type WorkReportSection = WorkReportItemSection;
export type WorkReportStatusFilter = 'all' | WorkReportStatus;
export type WorkReportTabMode = 'mine' | 'team';

export const DRAFT_WORK_REPORT_ACTION_ID = '9F5124A5-64F2-4C06-8D71-60710DCB531B';
export const SUBMIT_WORK_REPORT_ACTION_ID = '856D4E92-79B4-486A-A092-48CF5FC22998';
export const REVIEW_WORK_REPORT_ACTION_ID = 'B880DABA-0FC1-4012-9C3B-92694D99985E';

export const TASKS_ENTITY_NAME = 'MJ_BizApps_Tasks: Tasks';
export const TASK_ASSIGNMENTS_ENTITY_NAME = 'MJ_BizApps_Tasks: Task Assignments';
export const TASK_CHECK_INS_ENTITY_NAME = 'MJ_BizApps_Tasks: Task Check-Ins';
export const TASK_ACTIVITIES_ENTITY_NAME = 'MJ_BizApps_Tasks: Task Activities';
export const WORK_REPORTS_ENTITY_NAME = 'MJ_BizApps_Tasks: Work Reports';
export const WORK_REPORT_ITEMS_ENTITY_NAME = 'MJ_BizApps_Tasks: Work Report Items';
export const PEOPLE_ENTITY_NAME = 'MJ_BizApps_Common: People';
export const EMPLOYEES_ENTITY_NAME = 'MJ: Employees';
export const USERS_ENTITY_NAME = 'MJ: Users';
export const AI_AGENTS_ENTITY_NAME = 'MJ: AI Agents';
export const AI_AGENT_REQUESTS_ENTITY_NAME = 'MJ: AI Agent Requests';
export const AI_AGENT_REQUEST_TYPES_ENTITY_NAME = 'MJ: AI Agent Request Types';
export const FIELD_SUGGESTIONS_ENTITY_NAME = 'MJ: Field Suggestions';

const PRIVILEGED_ROLE_NAMES = new Set([
    'owner',
    'admin',
    'administrator',
    'system administrator',
    'administration',
]);

const MAX_SUPERVISOR_CHAIN_DEPTH = 3;

export type WorkReportProvider = IMetadataProvider & IRunViewProvider;

export interface PersonIdentitySummary {
    ID: string;
    FirstName: string | null;
    LastName: string | null;
    Email: string | null;
    LinkedUserID: string | null;
}

export interface SupervisorResolution {
    AuthorPersonID: string;
    AuthorDisplayName: string;
    AuthorEmail: string | null;
    AuthorUserID: string | null;
    EmployeeID: string | null;
    SupervisorEmployeeID: string | null;
    SupervisorEmail: string | null;
    SupervisorUserID: string | null;
    SupervisorPersonID: string | null;
    SupervisorName: string | null;
    SupervisorChainPersonIDs?: string[];
    SupervisorChainUserIDs?: string[];
}

export interface TaskActivityWindowEntry {
    TaskID: string;
    Name: string;
    Status: string;
    Priority: string | null;
    PercentComplete: number;
    HoursActual: number | null;
    HealthStatus: string | null;
    ParentID: string | null;
    DueAt: string | null;
    CompletedAt: string | null;
    UpdatedAt: string | null;
    LatestCheckInSummary: string | null;
}

export interface PersonTaskActivitySummary {
    PersonID: string;
    PeriodStart: Date;
    PeriodEnd: Date;
    TotalActiveOrUpdatedCount: number;
    Completed: TaskActivityWindowEntry[];
    InProgress: TaskActivityWindowEntry[];
    Next: TaskActivityWindowEntry[];
    Blockers: TaskActivityWindowEntry[];
    AtRisk: TaskActivityWindowEntry[];
}

export interface DraftWorkReportParams {
    PersonID: string;
    PeriodStart: Date;
    PeriodEnd: Date;
    TimezoneOffsetMinutes?: number;
    Title?: string | null;
    CustomBody?: string | null;
    AuthoredByAgentRunID?: string | null;
    ContextUser?: UserInfo;
    Provider?: WorkReportProvider;
}

export interface DraftWorkReportOutcome {
    SkippedNoActivity: boolean;
    Activity: PersonTaskActivitySummary;
    Report: WorkReportRecordSnapshot | null;
    Items: WorkReportItemRecordSnapshot[];
}

export interface WorkReportRecordSnapshot {
    ID: string;
    PersonID: string;
    PeriodStart: Date;
    PeriodEnd: Date;
    Title: string | null;
    Body: string;
    Status: WorkReportStatus;
    AuthoredByAgentRunID: string | null;
    SupervisorFeedback: string | null;
    ReviewedByPersonID: string | null;
    ReviewedAt: Date | null;
}

export interface WorkReportItemRecordSnapshot {
    ID: string;
    WorkReportID: string;
    TaskID: string | null;
    Section: WorkReportItemSection;
    Summary: string;
    Sequence: number;
}

export interface SubmitWorkReportParams {
    WorkReportID: string;
    CallerPersonID?: string | null;
    UpdatedBody?: string | null;
    UpdatedTitle?: string | null;
    ContextUser?: UserInfo;
    Provider?: WorkReportProvider;
}

export interface SubmitWorkReportOutcome {
    Report: WorkReportRecordSnapshot;
    Supervisor: SupervisorResolution;
    SupervisorRequestID: string | null;
    SupervisorNotified: boolean;
}

export interface RecordSupervisorReviewParams {
    WorkReportID: string;
    ReviewerPersonID?: string | null;
    SupervisorFeedback: string;
    EnforceReportingLine?: boolean;
    ContextUser?: UserInfo;
    Provider?: WorkReportProvider;
}

export interface RecordSupervisorReviewOutcome {
    Report: WorkReportRecordSnapshot;
    Supervisor: SupervisorResolution;
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
    Items: WorkReportItemViewModel[];
}

export interface WorkReportItemViewModel {
    ID: string;
    TaskID: string | null;
    TaskName: string | null;
    Section: WorkReportItemSection;
    Summary: string;
    Sequence: number;
}

export interface LocalDayWindow {
    PeriodStart: Date;
    PeriodEnd: Date;
    DateString: string;
}

interface RawPersonRow {
    ID: string;
    FirstName?: string | null;
    LastName?: string | null;
    Email?: string | null;
    LinkedUserID?: string | null;
    Status?: string | null;
}

interface RawEmployeeRow {
    ID: string;
    FirstName?: string | null;
    LastName?: string | null;
    Email?: string | null;
    SupervisorID?: string | null;
    Active?: boolean | number | null;
}

interface RawUserRow {
    ID: string;
    Name?: string | null;
    Email?: string | null;
    IsActive?: boolean | number | null;
}

interface RawTaskAssignmentRow {
    TaskID: string;
}

interface RawTaskRow {
    ID: string;
    Name: string;
    Status: string;
    Priority?: string | null;
    PercentComplete?: number | null;
    HoursActual?: number | null;
    HealthStatus?: string | null;
    ParentID?: string | null;
    DueAt?: string | Date | null;
    CompletedAt?: string | Date | null;
    __mj_UpdatedAt?: string | Date | null;
}

interface RawCheckInRow {
    TaskID: string;
    Summary?: string | null;
    Blockers?: string | null;
    __mj_CreatedAt?: string | Date | null;
}

interface RawTaskActivityRow {
    TaskID: string;
    Summary?: string | null;
    ActivityType?: string | null;
    __mj_CreatedAt?: string | Date | null;
}

interface RawWorkReportLookupRow {
    ID: string;
    Status: WorkReportStatus;
}

interface RawWorkReportItemLookupRow {
    ID: string;
    Sequence: number;
}

interface RawAgentRow {
    ID: string;
    Name?: string | null;
}

interface RawRequestTypeRow {
    ID: string;
    Name?: string | null;
}

interface RawFieldSuggestionRow {
    ID: string;
    LinkedRecordID: string;
}

interface AIAgentRequestEntity extends BaseEntity {
    ID: string;
    AgentID: string | null;
    RequestedByUserID: string | null;
    RequestForUserID: string | null;
    RequestTypeID: string | null;
    OriginatingEntityID: string | null;
    OriginatingRecordID: string | null;
    Request: string;
    Status: string;
    Priority: number;
    ExpiresAt: Date | null;
    Comments: string | null;
}

function findEntityByName(
    md: IMetadataProvider,
    entityName: string,
): { ID: string; Name: string } | undefined {
    const candidate = md as IMetadataProvider & {
        EntityByName?: (name: string) => { ID: string; Name: string } | undefined;
    };
    if (typeof candidate.EntityByName === 'function') {
        const match = candidate.EntityByName(entityName);
        if (match) {
            return match;
        }
    }
    return md.Entities?.find((e) => e.Name === entityName);
}

/**
 * Returns true when the user carries a server/admin role that is exempt from author/supervisor gating.
 */
export function IsPrivilegedWorkReportUser(user?: UserInfo): boolean {
    if (!user) {
        return false;
    }
    const userWithMeta = user as UserInfo & { Type?: string };
    if (typeof userWithMeta.Type === 'string' && userWithMeta.Type.trim().toLowerCase() === 'owner') {
        return true;
    }
    const roles = user.UserRoles ?? [];
    for (const ur of roles) {
        const roleName = (ur.Role ?? '').trim().toLowerCase();
        if (PRIVILEGED_ROLE_NAMES.has(roleName)) {
            return true;
        }
    }
    return false;
}

/**
 * Returns the caller's local calendar day window (`00:00:00.000` through `23:59:59.999` local time)
 * and its `YYYY-MM-DD` local calendar date string.
 * When `timezoneOffsetMinutes` is supplied (matching `Date.prototype.getTimezoneOffset()`, i.e.
 * `UTC - local` in minutes such as `480` for US Pacific), computes the calendar day in that timezone.
 */
export function GetLocalDayWindow(now: Date = new Date(), timezoneOffsetMinutes?: number): LocalDayWindow {
    const pad = (n: number): string => String(n).padStart(2, '0');
    if (typeof timezoneOffsetMinutes === 'number' && Number.isFinite(timezoneOffsetMinutes)) {
        const offsetMs = timezoneOffsetMinutes * 60_000;
        const shifted = new Date(now.getTime() - offsetMs);
        const year = shifted.getUTCFullYear();
        const month = shifted.getUTCMonth();
        const day = shifted.getUTCDate();
        const dateString = `${year}-${pad(month + 1)}-${pad(day)}`;
        return {
            PeriodStart: new Date(Date.UTC(year, month, day, 0, 0, 0, 0) + offsetMs),
            PeriodEnd: new Date(Date.UTC(year, month, day, 23, 59, 59, 999) + offsetMs),
            DateString: dateString,
        };
    }

    const year = now.getFullYear();
    const month = now.getMonth();
    const day = now.getDate();
    const dateString = `${year}-${pad(month + 1)}-${pad(day)}`;
    return {
        PeriodStart: new Date(year, month, day, 0, 0, 0, 0),
        PeriodEnd: new Date(year, month, day, 23, 59, 59, 999),
        DateString: dateString,
    };
}

/**
 * Formats a Date into a `YYYY-MM-DD` calendar date string.
 * When `timezoneOffsetMinutes` is provided (`UTC - local` in minutes), formats using that timezone.
 * Otherwise, if the Date represents exact UTC midnight (`00:00:00.000Z`), uses UTC components so
 * ISO date-only strings (`new Date('2026-11-06')`) preserve their calendar date in every timezone;
 * otherwise uses local calendar components.
 */
export function FormatReportCalendarDate(date: Date, timezoneOffsetMinutes?: number): string {
    const pad = (n: number): string => String(n).padStart(2, '0');
    if (typeof timezoneOffsetMinutes === 'number' && Number.isFinite(timezoneOffsetMinutes)) {
        const shifted = new Date(date.getTime() - timezoneOffsetMinutes * 60_000);
        return `${shifted.getUTCFullYear()}-${pad(shifted.getUTCMonth() + 1)}-${pad(shifted.getUTCDate())}`;
    }

    const isUtcMidnight =
        date.getUTCHours() === 0 &&
        date.getUTCMinutes() === 0 &&
        date.getUTCSeconds() === 0 &&
        date.getUTCMilliseconds() === 0;
    const isUtcEndOfDay =
        date.getUTCHours() === 23 &&
        date.getUTCMinutes() === 59 &&
        (date.getUTCSeconds() === 59 || date.getUTCSeconds() === 0);

    const year = isUtcMidnight || isUtcEndOfDay ? date.getUTCFullYear() : date.getFullYear();
    const month = (isUtcMidnight || isUtcEndOfDay ? date.getUTCMonth() : date.getMonth()) + 1;
    const day = isUtcMidnight || isUtcEndOfDay ? date.getUTCDate() : date.getDate();
    return `${year}-${pad(month)}-${pad(day)}`;
}

/**
 * Normalizes a `[PeriodStart, PeriodEnd]` window so that any date-only or midnight `PeriodEnd`
 * (including multi-day ranges like `2026-11-02..2026-11-06`) covers the full final day through
 * `23:59:59.999` instead of stopping at `00:00:00.000` at the start of the end date.
 */
export function NormalizeReportPeriodWindow(
    periodStart: Date,
    periodEnd: Date,
): { StartDate: Date; EndDate: Date; StartMs: number; EndMs: number } {
    const rawStartMs = periodStart.getTime();
    const rawEndMs = periodEnd.getTime();
    const minDate = rawStartMs <= rawEndMs ? new Date(rawStartMs) : new Date(rawEndMs);
    const maxDate = rawStartMs <= rawEndMs ? new Date(rawEndMs) : new Date(rawStartMs);

    const isUtcMidnight =
        maxDate.getUTCHours() === 0 &&
        maxDate.getUTCMinutes() === 0 &&
        maxDate.getUTCSeconds() === 0 &&
        maxDate.getUTCMilliseconds() === 0;
    const isLocalMidnight =
        maxDate.getHours() === 0 &&
        maxDate.getMinutes() === 0 &&
        maxDate.getSeconds() === 0 &&
        maxDate.getMilliseconds() === 0;

    const startMs = minDate.getTime();
    const endMs =
        isUtcMidnight || isLocalMidnight || maxDate.getTime() === startMs
            ? maxDate.getTime() + 24 * 60 * 60 * 1000 - 1
            : maxDate.getTime();

    return {
        StartDate: new Date(startMs),
        EndDate: new Date(endMs),
        StartMs: startMs,
        EndMs: endMs,
    };
}

function buildPersonDisplayName(row: { FirstName?: string | null; LastName?: string | null; Email?: string | null }): string {
    const full = `${row.FirstName ?? ''} ${row.LastName ?? ''}`.trim();
    if (full.length > 0) {
        return full;
    }
    return row.Email?.trim() || 'Unknown Person';
}

function toIsoStringOrNull(value: string | Date | null | undefined): string | null {
    if (!value) {
        return null;
    }
    const d = value instanceof Date ? value : new Date(value);
    return Number.isNaN(d.getTime()) ? null : d.toISOString();
}

function isTimestampWithinWindow(
    value: string | Date | null | undefined,
    startMs: number,
    endMs: number,
): boolean {
    if (!value) {
        return false;
    }
    const ms = value instanceof Date ? value.getTime() : new Date(value).getTime();
    if (Number.isNaN(ms)) {
        return false;
    }
    return ms >= startMs && ms <= endMs;
}

/**
 * Synthesizes a concise, 5-minute-readable markdown body from a person's task activity window.
 */
export function BuildWorkReportMarkdown(activity: Pick<
    PersonTaskActivitySummary,
    'Completed' | 'InProgress' | 'Next' | 'Blockers' | 'AtRisk'
>): string {
    const lines: string[] = [];

    if (activity.Completed.length > 0) {
        lines.push('### Completed');
        for (const item of activity.Completed) {
            const hoursSuffix = item.HoursActual != null && item.HoursActual > 0 ? ` (${item.HoursActual}h)` : '';
            const detail = item.LatestCheckInSummary ? ` — ${item.LatestCheckInSummary}` : '';
            lines.push(`- **${item.Name}**${hoursSuffix}${detail}`);
        }
        lines.push('');
    }

    if (activity.InProgress.length > 0) {
        lines.push('### In Progress');
        for (const item of activity.InProgress) {
            const pct = item.PercentComplete > 0 ? ` (${item.PercentComplete}%)` : '';
            const detail = item.LatestCheckInSummary ? ` — ${item.LatestCheckInSummary}` : '';
            lines.push(`- **${item.Name}**${pct}${detail}`);
        }
        lines.push('');
    }

    if (activity.Next.length > 0) {
        lines.push('### Next');
        for (const item of activity.Next) {
            const due = item.DueAt ? ` (due ${item.DueAt.slice(0, 10)})` : '';
            lines.push(`- **${item.Name}**${due}`);
        }
        lines.push('');
    }

    if (activity.Blockers.length > 0) {
        lines.push('### Blockers');
        for (const item of activity.Blockers) {
            const detail = item.LatestCheckInSummary ? `: ${item.LatestCheckInSummary}` : '';
            lines.push(`- **${item.Name}**${detail}`);
        }
        lines.push('');
    }

    if (activity.AtRisk.length > 0) {
        lines.push('### At-Risk Objectives');
        for (const item of activity.AtRisk) {
            const health = item.HealthStatus ?? 'AtRisk';
            lines.push(`- **${item.Name}** [${health}]`);
        }
        lines.push('');
    }

    if (lines.length === 0) {
        return '_No task updates recorded during this period._';
    }

    return lines.join('\n').trim();
}

/**
 * Loads pending `MJ: Field Suggestions` counts grouped by normalized Task ID.
 * Logs a warning when the host database is running an older MJ core without `MJ: Field Suggestions`.
 */
export async function LoadPendingFieldSuggestionCountsForTasks(
    rv: RunView,
    tasksEntityID: string,
    taskIDs: string[],
    contextUser?: UserInfo,
    provider?: IMetadataProvider,
): Promise<Map<string, number>> {
    const counts = new Map<string, number>();
    if (!tasksEntityID || !IsValidUUID(tasksEntityID) || taskIDs.length === 0) {
        return counts;
    }

    const md = provider ?? Metadata.Provider;
    const hasFieldSuggestionsEntity = Boolean(findEntityByName(md, FIELD_SUGGESTIONS_ENTITY_NAME));
    if (!hasFieldSuggestionsEntity) {
        LogStatus(
            `WorkReportService: '${FIELD_SUGGESTIONS_ENTITY_NAME}' entity is not registered on this host (requires MJ 6.3+); skipping pending suggestion badge counts.`,
        );
        return counts;
    }

    const validIDs = taskIDs.filter((id) => IsValidUUID(id));
    if (validIDs.length === 0) {
        return counts;
    }

    const inList = validIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
    const res = await rv.RunView<RawFieldSuggestionRow>(
        {
            EntityName: FIELD_SUGGESTIONS_ENTITY_NAME,
            ExtraFilter:
                `LinkedEntityID = '${EscapeSQLString(tasksEntityID)}' ` +
                `AND Status = 'Pending' ` +
                `AND LinkedRecordID IN (${inList})`,
            Fields: ['ID', 'LinkedRecordID'],
            ResultType: 'simple',
        },
        contextUser,
    );

    if (!res.Success) {
        LogError(
            `WorkReportService: failed to load pending field suggestions for tasks: ${res.ErrorMessage ?? 'RunView failed'}`,
        );
        return counts;
    }

    for (const row of res.Results ?? []) {
        if (row.LinkedRecordID) {
            const key = NormalizeUUID(row.LinkedRecordID);
            counts.set(key, (counts.get(key) ?? 0) + 1);
        }
    }

    return counts;
}

/**
 * Pure filter helper for the Chief of Staff Work Reports resource list.
 */
export function FilterWorkReports(
    reports: WorkReportViewModel[],
    statusFilter: 'all' | WorkReportStatus,
    searchText: string,
): WorkReportViewModel[] {
    const trimmedSearch = searchText.trim().toLowerCase();
    return reports.filter((report) => {
        if (statusFilter !== 'all' && report.Status !== statusFilter) {
            return false;
        }
        if (trimmedSearch.length > 0) {
            const haystack = `${report.Title} ${report.PersonName} ${report.Body} ${report.SupervisorFeedback ?? ''}`.toLowerCase();
            if (!haystack.includes(trimmedSearch)) {
                return false;
            }
        }
        return true;
    });
}

export interface WorkReportsSelectedReportContext {
    ID: string;
    Title: string;
    PersonID: string;
    PersonName: string;
    PeriodStart: string;
    PeriodEnd: string;
    Status: WorkReportStatus;
    ItemCount: number;
    HasSupervisorFeedback: boolean;
}

export interface WorkReportsAgentContext {
    Surface: 'ChiefOfStaffWorkReports';
    ActiveTab: 'mine' | 'team';
    StatusFilter: 'all' | WorkReportStatus;
    SearchText: string;
    MyReportsCount: number;
    MyDraftCount: number;
    TeamReportsCount: number;
    TeamPendingReviewCount: number;
    FilteredCount: number;
    SelectedReport: WorkReportsSelectedReportContext | null;
    [key: string]: string | number | boolean | WorkReportsSelectedReportContext | null;
}

/**
 * Builds the compact ambient context payload published via `navigationService.SetAgentContext`
 * from the Chief of Staff Work Reports resource.
 */
export function BuildWorkReportsAgentContext(state: {
    ActiveTab: 'mine' | 'team';
    StatusFilter: 'all' | WorkReportStatus;
    SearchText: string;
    MyReports: WorkReportViewModel[];
    TeamReports: WorkReportViewModel[];
    FilteredCount: number;
    SelectedReportID: string | null;
}): WorkReportsAgentContext {
    const allReports = state.ActiveTab === 'mine' ? state.MyReports : state.TeamReports;
    const selected = state.SelectedReportID
        ? allReports.find((r) => UUIDsEqual(r.ID, state.SelectedReportID)) ?? null
        : null;

    return {
        Surface: 'ChiefOfStaffWorkReports',
        ActiveTab: state.ActiveTab,
        StatusFilter: state.StatusFilter,
        SearchText: state.SearchText,
        MyReportsCount: state.MyReports.length,
        MyDraftCount: state.MyReports.filter((r) => r.Status === 'Draft').length,
        TeamReportsCount: state.TeamReports.length,
        TeamPendingReviewCount: state.TeamReports.filter((r) => r.Status === 'Submitted').length,
        FilteredCount: state.FilteredCount,
        SelectedReport: selected
            ? {
                  ID: selected.ID,
                  Title: selected.Title,
                  PersonID: selected.PersonID,
                  PersonName: selected.PersonName,
                  PeriodStart: selected.PeriodStart,
                  PeriodEnd: selected.PeriodEnd,
                  Status: selected.Status,
                  ItemCount: selected.Items.length,
                  HasSupervisorFeedback: Boolean(selected.SupervisorFeedback),
              }
            : null,
    };
}

/**
 * Service for drafting, submitting, and reviewing 15Five-style Work Reports
 * and resolving supervisor reporting lines across `MJ_BizApps_Common: People` and `MJ: Employees`.
 */
export class WorkReportService extends BaseSingleton<WorkReportService> {
    public constructor() {
        super();
    }

    public static get Instance(): WorkReportService {
        return WorkReportService.getInstance<WorkReportService>();
    }

    private createRunView(provider?: WorkReportProvider): RunView {
        return new RunView(provider);
    }

    private getMetadataProvider(provider?: WorkReportProvider): IMetadataProvider {
        return provider ?? Metadata.Provider;
    }

    /**
     * Resolves the active `MJ_BizApps_Common: People` record for a MemberJunction `UserInfo`.
     * Uses `UserInfo.LinkedEntityRecordID` when linked to People, then `Person.LinkedUserID`,
     * and finally case-insensitive `Person.Email`.
     */
    public async ResolvePersonForUser(
        user: UserInfo,
        provider?: WorkReportProvider,
    ): Promise<PersonIdentitySummary | null> {
        const rv = this.createRunView(provider);
        const md = this.getMetadataProvider(provider);
        const peopleEntity = findEntityByName(md, PEOPLE_ENTITY_NAME);

        const userWithLink = user as UserInfo & {
            LinkedEntityID?: string | null;
            LinkedEntityRecordID?: string | null;
        };

        if (
            peopleEntity &&
            userWithLink.LinkedEntityID &&
            userWithLink.LinkedEntityRecordID &&
            UUIDsEqual(userWithLink.LinkedEntityID, peopleEntity.ID) &&
            IsValidUUID(userWithLink.LinkedEntityRecordID)
        ) {
            const byLink = await rv.RunView<RawPersonRow>(
                {
                    EntityName: PEOPLE_ENTITY_NAME,
                    ExtraFilter: `ID = '${EscapeSQLString(userWithLink.LinkedEntityRecordID)}' AND Status = 'Active'`,
                    Fields: ['ID', 'FirstName', 'LastName', 'Email', 'LinkedUserID'],
                    MaxRows: 1,
                    ResultType: 'simple',
                },
                user,
            );
            if (!byLink.Success) {
                throw new Error(`Failed to resolve linked Person record: ${byLink.ErrorMessage ?? 'RunView failed'}`);
            }
            const linkedRow = byLink.Results?.[0];
            if (linkedRow) {
                return {
                    ID: linkedRow.ID,
                    FirstName: linkedRow.FirstName ?? null,
                    LastName: linkedRow.LastName ?? null,
                    Email: linkedRow.Email ?? null,
                    LinkedUserID: linkedRow.LinkedUserID ?? null,
                };
            }
        }

        if (user.ID && IsValidUUID(user.ID)) {
            const byUser = await rv.RunView<RawPersonRow>(
                {
                    EntityName: PEOPLE_ENTITY_NAME,
                    ExtraFilter: `LinkedUserID = '${EscapeSQLString(user.ID)}' AND Status = 'Active'`,
                    Fields: ['ID', 'FirstName', 'LastName', 'Email', 'LinkedUserID'],
                    MaxRows: 1,
                    ResultType: 'simple',
                },
                user,
            );
            if (!byUser.Success) {
                throw new Error(`Failed to resolve Person by LinkedUserID: ${byUser.ErrorMessage ?? 'RunView failed'}`);
            }
            const userRow = byUser.Results?.[0];
            if (userRow) {
                return {
                    ID: userRow.ID,
                    FirstName: userRow.FirstName ?? null,
                    LastName: userRow.LastName ?? null,
                    Email: userRow.Email ?? null,
                    LinkedUserID: userRow.LinkedUserID ?? null,
                };
            }
        }

        const email = user.Email?.trim();
        if (email) {
            const byEmail = await rv.RunView<RawPersonRow>(
                {
                    EntityName: PEOPLE_ENTITY_NAME,
                    ExtraFilter: `LOWER(Email) = LOWER('${EscapeSQLString(email)}') AND Status = 'Active'`,
                    Fields: ['ID', 'FirstName', 'LastName', 'Email', 'LinkedUserID'],
                    MaxRows: 5,
                    ResultType: 'simple',
                },
                user,
            );
            if (!byEmail.Success) {
                throw new Error(`Failed to resolve Person by Email: ${byEmail.ErrorMessage ?? 'RunView failed'}`);
            }
            const candidates = byEmail.Results ?? [];
            const emailRow =
                candidates.find((row) => row.LinkedUserID && user.ID && UUIDsEqual(row.LinkedUserID, user.ID)) ??
                candidates.find((row) => !row.LinkedUserID);
            if (emailRow) {
                return {
                    ID: emailRow.ID,
                    FirstName: emailRow.FirstName ?? null,
                    LastName: emailRow.LastName ?? null,
                    Email: emailRow.Email ?? null,
                    LinkedUserID: emailRow.LinkedUserID ?? null,
                };
            }
        }

        return null;
    }

    /**
     * Resolves a person's supervisor chain (up to 3 levels) across `MJ_BizApps_Common: People`
     * -> `MJ: Employees.SupervisorID` -> supervisor `MJ: Employees` -> supervisor `MJ: Users`
     * and `MJ_BizApps_Common: People`.
     * Prefers `Person.LinkedUserID` over email matching, and throws if any underlying `RunView` fails
     * so callers never fail open on a query error.
     */
    public async ResolveSupervisorChainForPerson(
        authorPersonID: string,
        contextUser?: UserInfo,
        provider?: WorkReportProvider,
    ): Promise<SupervisorResolution> {
        if (!IsValidUUID(authorPersonID)) {
            throw new Error(`Invalid authorPersonID: '${authorPersonID}'`);
        }

        const rv = this.createRunView(provider);
        const personRes = await rv.RunView<RawPersonRow>(
            {
                EntityName: PEOPLE_ENTITY_NAME,
                ExtraFilter: `ID = '${EscapeSQLString(authorPersonID)}'`,
                Fields: ['ID', 'FirstName', 'LastName', 'Email', 'LinkedUserID'],
                MaxRows: 1,
                ResultType: 'simple',
            },
            contextUser,
        );

        if (!personRes.Success) {
            throw new Error(
                `Failed to load author Person '${authorPersonID}': ${personRes.ErrorMessage ?? 'RunView failed'}`,
            );
        }

        const authorRow = personRes.Results?.[0];
        if (!authorRow) {
            throw new Error(`Author Person record '${authorPersonID}' not found.`);
        }

        const chainPersonIDs: string[] = [];
        const chainUserIDs: string[] = [];

        const result: SupervisorResolution = {
            AuthorPersonID: authorRow.ID,
            AuthorDisplayName: buildPersonDisplayName(authorRow),
            AuthorEmail: authorRow.Email ?? null,
            AuthorUserID: authorRow.LinkedUserID ?? null,
            EmployeeID: null,
            SupervisorEmployeeID: null,
            SupervisorEmail: null,
            SupervisorUserID: null,
            SupervisorPersonID: null,
            SupervisorName: null,
            SupervisorChainPersonIDs: chainPersonIDs,
            SupervisorChainUserIDs: chainUserIDs,
        };

        const authorEmail = authorRow.Email?.trim();
        if (!authorEmail) {
            return result;
        }

        const empRes = await rv.RunView<RawEmployeeRow>(
            {
                EntityName: EMPLOYEES_ENTITY_NAME,
                ExtraFilter: `LOWER(Email) = LOWER('${EscapeSQLString(authorEmail)}') AND Active = 1`,
                Fields: ['ID', 'FirstName', 'LastName', 'Email', 'SupervisorID', 'Active'],
                MaxRows: 1,
                ResultType: 'simple',
            },
            contextUser,
        );

        if (!empRes.Success) {
            throw new Error(
                `Failed to query MJ: Employees for '${authorEmail}': ${empRes.ErrorMessage ?? 'RunView failed'}`,
            );
        }

        const empRow = empRes.Results?.[0];
        if (!empRow) {
            return result;
        }

        result.EmployeeID = empRow.ID;
        if (!empRow.SupervisorID || !IsValidUUID(empRow.SupervisorID)) {
            return result;
        }

        const visitedEmployeeIDs = new Set<string>([NormalizeUUID(empRow.ID)]);
        let currentSupervisorEmpID: string | null = empRow.SupervisorID;

        for (let depth = 0; depth < MAX_SUPERVISOR_CHAIN_DEPTH && currentSupervisorEmpID; depth++) {
            const normalizedEmpID = NormalizeUUID(currentSupervisorEmpID);
            if (visitedEmployeeIDs.has(normalizedEmpID)) {
                break;
            }
            visitedEmployeeIDs.add(normalizedEmpID);

            if (depth === 0) {
                result.SupervisorEmployeeID = currentSupervisorEmpID;
            }

            const supEmpRes = await rv.RunView<RawEmployeeRow>(
                {
                    EntityName: EMPLOYEES_ENTITY_NAME,
                    ExtraFilter: `ID = '${EscapeSQLString(currentSupervisorEmpID)}'`,
                    Fields: ['ID', 'FirstName', 'LastName', 'Email', 'SupervisorID', 'Active'],
                    MaxRows: 1,
                    ResultType: 'simple',
                },
                contextUser,
            );

            if (!supEmpRes.Success) {
                throw new Error(
                    `Failed to query supervisor Employee '${currentSupervisorEmpID}': ${supEmpRes.ErrorMessage ?? 'RunView failed'}`,
                );
            }

            const supEmp = supEmpRes.Results?.[0];
            if (!supEmp) {
                break;
            }

            if (depth === 0) {
                result.SupervisorName = buildPersonDisplayName(supEmp);
            }

            const supEmail = supEmp.Email?.trim();
            if (depth === 0) {
                result.SupervisorEmail = supEmail ?? null;
            }

            if (supEmail) {
                const supUserRes = await rv.RunView<RawUserRow>(
                    {
                        EntityName: USERS_ENTITY_NAME,
                        ExtraFilter: `LOWER(Email) = LOWER('${EscapeSQLString(supEmail)}') AND IsActive = 1`,
                        Fields: ['ID', 'Name', 'Email'],
                        MaxRows: 1,
                        ResultType: 'simple',
                    },
                    contextUser,
                );

                if (!supUserRes.Success) {
                    throw new Error(
                        `Failed to query supervisor User '${supEmail}': ${supUserRes.ErrorMessage ?? 'RunView failed'}`,
                    );
                }

                const supUser = supUserRes.Results?.[0];
                if (supUser?.ID) {
                    if (depth === 0) {
                        result.SupervisorUserID = supUser.ID;
                    }
                    if (!chainUserIDs.some((id) => UUIDsEqual(id, supUser.ID))) {
                        chainUserIDs.push(supUser.ID);
                    }
                }

                const supPersonFilter = supUser?.ID
                    ? `(LinkedUserID = '${EscapeSQLString(supUser.ID)}' OR LOWER(Email) = LOWER('${EscapeSQLString(supEmail)}')) AND Status = 'Active'`
                    : `LOWER(Email) = LOWER('${EscapeSQLString(supEmail)}') AND Status = 'Active'`;

                const supPersonRes = await rv.RunView<RawPersonRow>(
                    {
                        EntityName: PEOPLE_ENTITY_NAME,
                        ExtraFilter: supPersonFilter,
                        Fields: ['ID', 'FirstName', 'LastName', 'Email', 'LinkedUserID'],
                        MaxRows: 5,
                        ResultType: 'simple',
                    },
                    contextUser,
                );

                if (!supPersonRes.Success) {
                    throw new Error(
                        `Failed to query supervisor Person '${supEmail}': ${supPersonRes.ErrorMessage ?? 'RunView failed'}`,
                    );
                }

                const personRows = supPersonRes.Results ?? [];
                // Prefer the Person row bound via LinkedUserID; fall back to unlinked email match
                const supPerson =
                    (supUser?.ID
                        ? personRows.find((p) => p.LinkedUserID && UUIDsEqual(p.LinkedUserID, supUser.ID))
                        : undefined) ??
                    personRows.find((p) => !p.LinkedUserID) ??
                    personRows[0];

                if (supPerson) {
                    if (depth === 0) {
                        result.SupervisorPersonID = supPerson.ID;
                        result.SupervisorName = buildPersonDisplayName(supPerson);
                        if (!result.SupervisorUserID && supPerson.LinkedUserID) {
                            result.SupervisorUserID = supPerson.LinkedUserID;
                        }
                    }
                    if (
                        !UUIDsEqual(supPerson.ID, authorRow.ID) &&
                        !chainPersonIDs.some((id) => UUIDsEqual(id, supPerson.ID))
                    ) {
                        chainPersonIDs.push(supPerson.ID);
                    }
                    if (
                        supPerson.LinkedUserID &&
                        !chainUserIDs.some((id) => UUIDsEqual(id, supPerson.LinkedUserID!))
                    ) {
                        chainUserIDs.push(supPerson.LinkedUserID);
                    }
                }
            }

            currentSupervisorEmpID =
                supEmp.SupervisorID && IsValidUUID(supEmp.SupervisorID) ? supEmp.SupervisorID : null;
        }

        return result;
    }

    /**
     * Resolves the `MJ_BizApps_Common: People` IDs of all active direct reports whose
     * `MJ: Employees.SupervisorID` points to the supervisor's `MJ: Employees` record.
     * Throws if any underlying `RunView` fails.
     */
    public async ResolveDirectReportPersonIDs(
        supervisorPersonID: string,
        contextUser?: UserInfo,
        provider?: WorkReportProvider,
    ): Promise<string[]> {
        if (!IsValidUUID(supervisorPersonID)) {
            return [];
        }

        const rv = this.createRunView(provider);
        const supPersonRes = await rv.RunView<RawPersonRow>(
            {
                EntityName: PEOPLE_ENTITY_NAME,
                ExtraFilter: `ID = '${EscapeSQLString(supervisorPersonID)}'`,
                Fields: ['ID', 'Email', 'LinkedUserID'],
                MaxRows: 1,
                ResultType: 'simple',
            },
            contextUser,
        );

        if (!supPersonRes.Success) {
            throw new Error(
                `Failed to load supervisor Person '${supervisorPersonID}': ${supPersonRes.ErrorMessage ?? 'RunView failed'}`,
            );
        }

        const supPerson = supPersonRes.Results?.[0];
        const supEmail = supPerson?.Email?.trim();
        if (!supEmail) {
            return [];
        }

        const supEmpRes = await rv.RunView<RawEmployeeRow>(
            {
                EntityName: EMPLOYEES_ENTITY_NAME,
                ExtraFilter: `LOWER(Email) = LOWER('${EscapeSQLString(supEmail)}') AND Active = 1`,
                Fields: ['ID', 'Email'],
                MaxRows: 1,
                ResultType: 'simple',
            },
            contextUser,
        );

        if (!supEmpRes.Success) {
            throw new Error(
                `Failed to load supervisor Employee '${supEmail}': ${supEmpRes.ErrorMessage ?? 'RunView failed'}`,
            );
        }

        const supEmp = supEmpRes.Results?.[0];
        if (!supEmp) {
            return [];
        }

        const directEmpRes = await rv.RunView<RawEmployeeRow>(
            {
                EntityName: EMPLOYEES_ENTITY_NAME,
                ExtraFilter: `SupervisorID = '${EscapeSQLString(supEmp.ID)}' AND Active = 1`,
                Fields: ['ID', 'Email'],
                ResultType: 'simple',
            },
            contextUser,
        );

        if (!directEmpRes.Success) {
            throw new Error(
                `Failed to load direct-report Employees for '${supEmp.ID}': ${directEmpRes.ErrorMessage ?? 'RunView failed'}`,
            );
        }

        const emails = (directEmpRes.Results ?? [])
            .map((e) => e.Email?.trim())
            .filter((e): e is string => Boolean(e));

        if (emails.length === 0) {
            return [];
        }

        const lowerEmailFilter = emails
            .map((email) => `LOWER(Email) = LOWER('${EscapeSQLString(email)}')`)
            .join(' OR ');

        const [peopleByEmailRes, usersByEmailRes] = await Promise.all([
            rv.RunView<RawPersonRow>(
                {
                    EntityName: PEOPLE_ENTITY_NAME,
                    ExtraFilter: `(${lowerEmailFilter}) AND Status = 'Active'`,
                    Fields: ['ID', 'Email', 'LinkedUserID'],
                    ResultType: 'simple',
                },
                contextUser,
            ),
            rv.RunView<RawUserRow>(
                {
                    EntityName: USERS_ENTITY_NAME,
                    ExtraFilter: `(${lowerEmailFilter}) AND IsActive = 1`,
                    Fields: ['ID', 'Email'],
                    ResultType: 'simple',
                },
                contextUser,
            ),
        ]);

        if (!peopleByEmailRes.Success) {
            throw new Error(
                `Failed to load direct-report People by email: ${peopleByEmailRes.ErrorMessage ?? 'RunView failed'}`,
            );
        }
        if (!usersByEmailRes.Success) {
            throw new Error(
                `Failed to load direct-report Users by email: ${usersByEmailRes.ErrorMessage ?? 'RunView failed'}`,
            );
        }

        const personIDMap = new Map<string, string>();
        for (const p of peopleByEmailRes.Results ?? []) {
            personIDMap.set(NormalizeUUID(p.ID), p.ID);
        }

        const userIDs = (usersByEmailRes.Results ?? [])
            .map((u) => u.ID)
            .filter((id) => IsValidUUID(id));

        if (userIDs.length > 0) {
            const inUsers = userIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
            const peopleByUserRes = await rv.RunView<RawPersonRow>(
                {
                    EntityName: PEOPLE_ENTITY_NAME,
                    ExtraFilter: `LinkedUserID IN (${inUsers}) AND Status = 'Active'`,
                    Fields: ['ID'],
                    ResultType: 'simple',
                },
                contextUser,
            );
            if (!peopleByUserRes.Success) {
                throw new Error(
                    `Failed to load direct-report People by LinkedUserID: ${peopleByUserRes.ErrorMessage ?? 'RunView failed'}`,
                );
            }
            for (const p of peopleByUserRes.Results ?? []) {
                personIDMap.set(NormalizeUUID(p.ID), p.ID);
            }
        }

        return Array.from(personIDMap.values());
    }

    /**
     * Collects a person's task activity (tasks created/assigned to the person that changed,
     * had check-ins, or had activity entries during `[periodStart, periodEnd]`).
     */
    public async GetPersonTaskActivityForWindow(
        personID: string,
        periodStart: Date,
        periodEnd: Date,
        contextUser?: UserInfo,
        provider?: WorkReportProvider,
    ): Promise<PersonTaskActivitySummary> {
        if (!IsValidUUID(personID)) {
            throw new Error(`Invalid PersonID '${personID}'`);
        }

        const rv = this.createRunView(provider);
        const md = this.getMetadataProvider(provider);
        const normalizedWindow = NormalizeReportPeriodWindow(periodStart, periodEnd);
        const startDate = normalizedWindow.StartDate;
        const endDate = normalizedWindow.EndDate;
        const startMs = normalizedWindow.StartMs;
        const endMs = normalizedWindow.EndMs;

        const peopleEntity = findEntityByName(md, PEOPLE_ENTITY_NAME);
        const assigneeFilter = peopleEntity
            ? `AssigneeEntityID = '${EscapeSQLString(peopleEntity.ID)}' AND AssigneeRecordID = '${EscapeSQLString(personID)}' AND Status NOT IN ('Removed', 'Declined')`
            : `AssigneeRecordID = '${EscapeSQLString(personID)}' AND Status NOT IN ('Removed', 'Declined')`;

        const assignmentsRes = await rv.RunView<RawTaskAssignmentRow>(
            {
                EntityName: TASK_ASSIGNMENTS_ENTITY_NAME,
                ExtraFilter: assigneeFilter,
                Fields: ['TaskID'],
                ResultType: 'simple',
            },
            contextUser,
        );

        if (!assignmentsRes.Success) {
            throw new Error(
                `Failed to load Task Assignments for '${personID}': ${assignmentsRes.ErrorMessage ?? 'RunView failed'}`,
            );
        }

        const assignedTaskIDs = Array.from(
            new Set(
                (assignmentsRes.Results ?? [])
                    .map((a) => a.TaskID)
                    .filter((id) => IsValidUUID(id)),
            ),
        );

        const taskClauses: string[] = [`CreatedByPersonID = '${EscapeSQLString(personID)}'`];
        if (assignedTaskIDs.length > 0) {
            const inList = assignedTaskIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
            taskClauses.push(`ID IN (${inList})`);
        }

        const tasksRes = await rv.RunView<RawTaskRow>(
            {
                EntityName: TASKS_ENTITY_NAME,
                ExtraFilter: `(${taskClauses.join(' OR ')})`,
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
                ResultType: 'simple',
            },
            contextUser,
        );

        if (!tasksRes.Success) {
            throw new Error(
                `Failed to load Tasks for '${personID}': ${tasksRes.ErrorMessage ?? 'RunView failed'}`,
            );
        }

        const scopedTasks = tasksRes.Results ?? [];
        if (scopedTasks.length === 0) {
            return {
                PersonID: personID,
                PeriodStart: startDate,
                PeriodEnd: endDate,
                TotalActiveOrUpdatedCount: 0,
                Completed: [],
                InProgress: [],
                Next: [],
                Blockers: [],
                AtRisk: [],
            };
        }

        const scopedTaskIDs = scopedTasks.map((t) => t.ID).filter((id) => IsValidUUID(id));
        const inScopedTasks = scopedTaskIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ');

        const [checkInsRes, activitiesRes] = await Promise.all([
            rv.RunView<RawCheckInRow>(
                {
                    EntityName: TASK_CHECK_INS_ENTITY_NAME,
                    ExtraFilter: `TaskID IN (${inScopedTasks})`,
                    Fields: ['TaskID', 'Summary', 'Blockers', '__mj_CreatedAt'],
                    OrderBy: '__mj_CreatedAt DESC',
                    ResultType: 'simple',
                },
                contextUser,
            ),
            rv.RunView<RawTaskActivityRow>(
                {
                    EntityName: TASK_ACTIVITIES_ENTITY_NAME,
                    ExtraFilter: `TaskID IN (${inScopedTasks})`,
                    Fields: ['TaskID', 'Summary', 'ActivityType', '__mj_CreatedAt'],
                    OrderBy: '__mj_CreatedAt DESC',
                    ResultType: 'simple',
                },
                contextUser,
            ),
        ]);

        if (!checkInsRes.Success) {
            throw new Error(
                `Failed to load Task Check-Ins for '${personID}': ${checkInsRes.ErrorMessage ?? 'RunView failed'}`,
            );
        }
        if (!activitiesRes.Success) {
            throw new Error(
                `Failed to load Task Activities for '${personID}': ${activitiesRes.ErrorMessage ?? 'RunView failed'}`,
            );
        }

        const touchedInWindowTaskKeys = new Set<string>();
        const latestSummaryByTaskKey = new Map<string, string>();

        for (const ci of checkInsRes.Results ?? []) {
            if (isTimestampWithinWindow(ci.__mj_CreatedAt, startMs, endMs)) {
                const key = NormalizeUUID(ci.TaskID);
                touchedInWindowTaskKeys.add(key);
                const text = ci.Summary?.trim() || ci.Blockers?.trim() || null;
                if (text && !latestSummaryByTaskKey.has(key)) {
                    latestSummaryByTaskKey.set(key, text);
                }
            }
        }

        for (const act of activitiesRes.Results ?? []) {
            if (isTimestampWithinWindow(act.__mj_CreatedAt, startMs, endMs)) {
                const key = NormalizeUUID(act.TaskID);
                touchedInWindowTaskKeys.add(key);
                const text = act.Summary?.trim() || null;
                if (text && !latestSummaryByTaskKey.has(key)) {
                    latestSummaryByTaskKey.set(key, text);
                }
            }
        }

        const completed: TaskActivityWindowEntry[] = [];
        const inProgress: TaskActivityWindowEntry[] = [];
        const next: TaskActivityWindowEntry[] = [];
        const blockers: TaskActivityWindowEntry[] = [];
        const atRisk: TaskActivityWindowEntry[] = [];
        const activeTaskKeys = new Set<string>();

        for (const task of scopedTasks) {
            const key = NormalizeUUID(task.ID);
            const updatedInWindow = isTimestampWithinWindow(task.__mj_UpdatedAt, startMs, endMs);
            const completedInWindow = isTimestampWithinWindow(task.CompletedAt, startMs, endMs);
            const touchedInWindow =
                updatedInWindow || completedInWindow || touchedInWindowTaskKeys.has(key);

            if (!touchedInWindow) {
                continue;
            }

            activeTaskKeys.add(key);
            const entry: TaskActivityWindowEntry = {
                TaskID: task.ID,
                Name: task.Name,
                Status: task.Status,
                Priority: task.Priority ?? null,
                PercentComplete: task.PercentComplete ?? 0,
                HoursActual: task.HoursActual ?? null,
                HealthStatus: task.HealthStatus ?? null,
                ParentID: task.ParentID ?? null,
                DueAt: toIsoStringOrNull(task.DueAt),
                CompletedAt: toIsoStringOrNull(task.CompletedAt),
                UpdatedAt: toIsoStringOrNull(task.__mj_UpdatedAt),
                LatestCheckInSummary: latestSummaryByTaskKey.get(key) ?? null,
            };

            if (task.Status === 'Completed') {
                completed.push(entry);
            } else if (task.Status === 'Blocked') {
                blockers.push(entry);
            } else if (task.Status === 'InProgress' || task.Status === 'InReview') {
                inProgress.push(entry);
            } else if (task.Status === 'Open') {
                next.push(entry);
            }

            if (
                task.Status !== 'Completed' &&
                task.Status !== 'Cancelled' &&
                (task.HealthStatus === 'AtRisk' || task.HealthStatus === 'OffTrack')
            ) {
                atRisk.push(entry);
            }
        }

        return {
            PersonID: personID,
            PeriodStart: startDate,
            PeriodEnd: endDate,
            TotalActiveOrUpdatedCount: activeTaskKeys.size,
            Completed: completed,
            InProgress: inProgress,
            Next: next,
            Blockers: blockers,
            AtRisk: atRisk,
        };
    }

    /**
     * Drafts a `WorkReport` (status = `Draft`) and its section `WorkReportItem` records for `[PeriodStart, PeriodEnd]`.
     * Enforces that a non-privileged caller may only draft for their own resolved Person record,
     * reuses an existing `Draft` report for the same `(PersonID, PeriodStart, PeriodEnd)` window to prevent duplicates,
     * and returns `SkippedNoActivity: true` without creating rows when zero tasks changed in the window.
     */
    public async DraftWorkReport(params: DraftWorkReportParams): Promise<DraftWorkReportOutcome> {
        if (!IsValidUUID(params.PersonID)) {
            throw new Error(`Invalid PersonID '${params.PersonID}'`);
        }

        const md = this.getMetadataProvider(params.Provider);
        const rv = this.createRunView(params.Provider);

        // Fail-closed caller identity check when ContextUser carries identity metadata
        if (params.ContextUser && !IsPrivilegedWorkReportUser(params.ContextUser)) {
            const hasLinkedIdentityHint = Boolean(
                params.ContextUser.Email ||
                    (params.ContextUser as UserInfo & { LinkedEntityRecordID?: string | null }).LinkedEntityRecordID,
            );
            if (hasLinkedIdentityHint) {
                const callerPerson = await this.ResolvePersonForUser(params.ContextUser, params.Provider);
                if (!callerPerson) {
                    throw new Error('Caller could not be resolved to an active Person record; cannot draft work report.');
                }
                if (!UUIDsEqual(callerPerson.ID, params.PersonID)) {
                    throw new Error('Only the report author (or an administrator) may draft a work report for this person.');
                }
            }
        }

        const activity = await this.GetPersonTaskActivityForWindow(
            params.PersonID,
            params.PeriodStart,
            params.PeriodEnd,
            params.ContextUser,
            params.Provider,
        );

        if (activity.TotalActiveOrUpdatedCount === 0) {
            return {
                SkippedNoActivity: true,
                Activity: activity,
                Report: null,
                Items: [],
            };
        }

        const startLabel = FormatReportCalendarDate(activity.PeriodStart, params.TimezoneOffsetMinutes);
        const endLabel = FormatReportCalendarDate(activity.PeriodEnd, params.TimezoneOffsetMinutes);
        const defaultTitle =
            startLabel === endLabel
                ? `Daily 15Five — ${startLabel}`
                : `Work Report — ${startLabel} to ${endLabel}`;
        const explicitTitle = params.Title?.trim() || null;
        const explicitBody = params.CustomBody?.trim() || null;
        const synthesizedBody = BuildWorkReportMarkdown(activity);

        const reportEntity = await md.GetEntityObject<mjBizAppsTasksWorkReportEntity>(
            WORK_REPORTS_ENTITY_NAME,
            params.ContextUser,
        );

        // Check whether a WorkReport already exists for (PersonID, PeriodStart, PeriodEnd)
        let existingReportID: string | null = null;
        if (findEntityByName(md, WORK_REPORTS_ENTITY_NAME)) {
            const existingRes = await rv.RunView<RawWorkReportLookupRow>(
                {
                    EntityName: WORK_REPORTS_ENTITY_NAME,
                    ExtraFilter:
                        `PersonID = '${EscapeSQLString(params.PersonID)}' ` +
                        `AND PeriodStart = '${EscapeSQLString(startLabel)}' ` +
                        `AND PeriodEnd = '${EscapeSQLString(endLabel)}'`,
                    Fields: ['ID', 'Status'],
                    MaxRows: 1,
                    ResultType: 'simple',
                },
                params.ContextUser,
            );
            if (!existingRes.Success) {
                throw new Error(
                    `Failed to check for existing WorkReport: ${existingRes.ErrorMessage ?? 'RunView failed'}`,
                );
            }
            const existing = existingRes.Results?.[0];
            if (existing) {
                if (existing.Status !== 'Draft') {
                    throw new Error(
                        `A work report for period ${startLabel} to ${endLabel} has already been ${existing.Status.toLowerCase()}.`,
                    );
                }
                existingReportID = existing.ID;
            }
        }

        if (existingReportID) {
            const loaded = await reportEntity.Load(existingReportID);
            if (!loaded) {
                throw new Error(`Failed to load existing Draft WorkReport '${existingReportID}'.`);
            }
            // Preserve existing author-edited Title/Body unless the caller explicitly passed an override
            const existingTitle = reportEntity.Title?.trim();
            const existingBody = reportEntity.Body?.trim();
            reportEntity.Title = explicitTitle ?? (existingTitle || defaultTitle);
            reportEntity.Body = explicitBody ?? (existingBody || synthesizedBody);
        } else {
            reportEntity.NewRecord();
            reportEntity.PersonID = params.PersonID;
            reportEntity.PeriodStart = activity.PeriodStart;
            reportEntity.PeriodEnd = activity.PeriodEnd;
            reportEntity.Status = 'Draft';
            reportEntity.Title = explicitTitle ?? defaultTitle;
            reportEntity.Body = explicitBody ?? synthesizedBody;
        }

        reportEntity.AuthoredByAgentRunID =
            params.AuthoredByAgentRunID && IsValidUUID(params.AuthoredByAgentRunID)
                ? params.AuthoredByAgentRunID
                : null;

        const saved = await reportEntity.Save();
        if (!saved) {
            const msg = reportEntity.LatestResult?.CompleteMessage ?? 'Failed to save Draft WorkReport';
            throw new Error(msg);
        }

        const reportID = String(reportEntity.ID ?? reportEntity.PrimaryKey.Values()[0]);
        const sectionPlan: Array<{ Section: WorkReportItemSection; Entries: TaskActivityWindowEntry[] }> = [
            { Section: 'Completed', Entries: activity.Completed },
            { Section: 'InProgress', Entries: activity.InProgress },
            { Section: 'Next', Entries: activity.Next },
            { Section: 'Blockers', Entries: activity.Blockers },
            { Section: 'AtRisk', Entries: activity.AtRisk },
        ];

        let existingItems: RawWorkReportItemLookupRow[] = [];
        if (existingReportID && findEntityByName(md, WORK_REPORT_ITEMS_ENTITY_NAME)) {
            const existingItemsRes = await rv.RunView<RawWorkReportItemLookupRow>(
                {
                    EntityName: WORK_REPORT_ITEMS_ENTITY_NAME,
                    ExtraFilter: `WorkReportID = '${EscapeSQLString(reportID)}'`,
                    Fields: ['ID', 'Sequence'],
                    OrderBy: 'Sequence ASC',
                    ResultType: 'simple',
                },
                params.ContextUser,
            );
            if (!existingItemsRes.Success) {
                throw new Error(
                    `Failed to load existing WorkReportItems: ${existingItemsRes.ErrorMessage ?? 'RunView failed'}`,
                );
            }
            existingItems = existingItemsRes.Results ?? [];
        }

        const createdItems: WorkReportItemRecordSnapshot[] = [];
        let sequence = 1;
        let existingIdx = 0;

        for (const group of sectionPlan) {
            for (const entry of group.Entries) {
                const itemEntity = await md.GetEntityObject<mjBizAppsTasksWorkReportItemEntity>(
                    WORK_REPORT_ITEMS_ENTITY_NAME,
                    params.ContextUser,
                );
                const summary = this.buildItemSummary(group.Section, entry);
                const existingItem = existingItems[existingIdx];
                existingIdx += 1;

                if (existingItem) {
                    const itemLoaded = await itemEntity.Load(existingItem.ID);
                    if (!itemLoaded) {
                        throw new Error(`Failed to load existing WorkReportItem '${existingItem.ID}'.`);
                    }
                } else {
                    itemEntity.NewRecord();
                    itemEntity.WorkReportID = reportID;
                }

                itemEntity.TaskID = entry.TaskID;
                itemEntity.Section = group.Section;
                itemEntity.Summary = summary;
                itemEntity.Sequence = sequence;

                const itemSaved = await itemEntity.Save();
                if (!itemSaved) {
                    const msg = itemEntity.LatestResult?.CompleteMessage ?? 'Failed to save WorkReportItem';
                    throw new Error(msg);
                }

                const itemID = String(itemEntity.ID ?? itemEntity.PrimaryKey.Values()[0]);
                createdItems.push({
                    ID: itemID,
                    WorkReportID: reportID,
                    TaskID: entry.TaskID,
                    Section: group.Section,
                    Summary: summary,
                    Sequence: sequence,
                });
                sequence += 1;
            }
        }

        // Delete any surplus existing WorkReportItems when re-drafting shrinks the item list
        const surplusItems = existingItems.slice(existingIdx);
        for (const surplus of surplusItems) {
            const surplusEntity = await md.GetEntityObject<mjBizAppsTasksWorkReportItemEntity>(
                WORK_REPORT_ITEMS_ENTITY_NAME,
                params.ContextUser,
            );
            const loadedSurplus = await surplusEntity.Load(surplus.ID);
            if (!loadedSurplus) {
                throw new Error(`Failed to load surplus WorkReportItem '${surplus.ID}' for deletion.`);
            }
            const deleted = await surplusEntity.Delete();
            if (!deleted) {
                const msg = surplusEntity.LatestResult?.CompleteMessage ?? `Failed to delete surplus WorkReportItem '${surplus.ID}'.`;
                throw new Error(msg);
            }
        }

        return {
            SkippedNoActivity: false,
            Activity: activity,
            Report: this.snapshotReport(reportEntity, reportID),
            Items: createdItems,
        };
    }

    /**
     * Marks an author-approved `Draft` `WorkReport` as `Submitted` and creates an `MJ: AI Agent Requests`
     * review request routed to the supervisor's Chief of Staff.
     * Fails closed when the caller cannot be positively identified as the report's author (unless privileged).
     */
    public async SubmitWorkReport(params: SubmitWorkReportParams): Promise<SubmitWorkReportOutcome> {
        if (!IsValidUUID(params.WorkReportID)) {
            throw new Error(`Invalid WorkReportID '${params.WorkReportID}'`);
        }

        const md = this.getMetadataProvider(params.Provider);
        const reportEntity = await md.GetEntityObject<mjBizAppsTasksWorkReportEntity>(
            WORK_REPORTS_ENTITY_NAME,
            params.ContextUser,
        );
        const loaded = await reportEntity.Load(params.WorkReportID);
        if (!loaded) {
            throw new Error(`WorkReport '${params.WorkReportID}' not found.`);
        }

        const isPrivileged = IsPrivilegedWorkReportUser(params.ContextUser);
        let callerPersonID = params.CallerPersonID?.trim() || null;

        if (!callerPersonID) {
            if (!params.ContextUser) {
                throw new Error('Caller identity is required to submit a work report.');
            }
            const resolvedPerson = await this.ResolvePersonForUser(params.ContextUser, params.Provider);
            if (!resolvedPerson && !isPrivileged) {
                throw new Error('Caller could not be resolved to an active Person record; cannot submit work report.');
            }
            callerPersonID = resolvedPerson?.ID ?? null;
        } else if (!IsValidUUID(callerPersonID)) {
            throw new Error(`Invalid CallerPersonID '${callerPersonID}'.`);
        }

        if (!isPrivileged && (!callerPersonID || !UUIDsEqual(reportEntity.PersonID, callerPersonID))) {
            throw new Error('Only the author of a work report may submit it.');
        }

        if (reportEntity.Status !== 'Draft') {
            throw new Error(`Only a 'Draft' work report can be submitted; current status is '${reportEntity.Status}'.`);
        }

        // Resolve supervisor chain (also verifies author Person identity against ContextUser)
        const supervisor = await this.ResolveSupervisorChainForPerson(
            reportEntity.PersonID,
            params.ContextUser,
            params.Provider,
        );

        if (!isPrivileged && params.ContextUser) {
            const matchesUser =
                supervisor.AuthorUserID != null &&
                IsValidUUID(supervisor.AuthorUserID) &&
                UUIDsEqual(supervisor.AuthorUserID, params.ContextUser.ID);
            const matchesEmail =
                supervisor.AuthorEmail != null &&
                params.ContextUser.Email != null &&
                supervisor.AuthorEmail.trim().toLowerCase() === params.ContextUser.Email.trim().toLowerCase();
            if (supervisor.AuthorUserID && params.ContextUser.ID && !matchesUser && !matchesEmail) {
                throw new Error('Authenticated user does not match the report author.');
            }
        }

        if (params.UpdatedTitle != null && params.UpdatedTitle.trim().length > 0) {
            reportEntity.Title = params.UpdatedTitle.trim();
        }
        if (params.UpdatedBody != null && params.UpdatedBody.trim().length > 0) {
            reportEntity.Body = params.UpdatedBody.trim();
        }
        reportEntity.Status = 'Submitted';

        const saved = await reportEntity.Save();
        if (!saved) {
            const msg = reportEntity.LatestResult?.CompleteMessage ?? 'Failed to submit WorkReport';
            throw new Error(msg);
        }

        let supervisorRequestID: string | null = null;
        if (supervisor.SupervisorUserID) {
            supervisorRequestID = await this.createSupervisorReviewAgentRequest({
                Report: this.snapshotReport(reportEntity, params.WorkReportID),
                Supervisor: supervisor,
                ContextUser: params.ContextUser,
                Provider: params.Provider,
            });
        }

        return {
            Report: this.snapshotReport(reportEntity, params.WorkReportID),
            Supervisor: supervisor,
            SupervisorRequestID: supervisorRequestID,
            SupervisorNotified: supervisorRequestID !== null,
        };
    }

    /**
     * Records supervisor-approved feedback on a `Submitted` `WorkReport` and transitions it to `Reviewed`.
     * Fails closed: refuses when the caller cannot be resolved to a Person, when no supervisor is mapped
     * in `MJ: Employees` (unless the caller holds a privileged admin role or `EnforceReportingLine === false`),
     * or when the caller does not match the mapped supervisor.
     */
    public async RecordSupervisorReview(
        params: RecordSupervisorReviewParams,
    ): Promise<RecordSupervisorReviewOutcome> {
        if (!IsValidUUID(params.WorkReportID)) {
            throw new Error(`Invalid WorkReportID '${params.WorkReportID}'`);
        }
        const feedback = params.SupervisorFeedback?.trim();
        if (!feedback) {
            throw new Error('SupervisorFeedback is required when reviewing a work report.');
        }

        const isPrivileged = IsPrivilegedWorkReportUser(params.ContextUser);
        let reviewerPersonID = params.ReviewerPersonID?.trim() || null;
        if (!reviewerPersonID && params.ContextUser) {
            const resolvedReviewer = await this.ResolvePersonForUser(params.ContextUser, params.Provider);
            reviewerPersonID = resolvedReviewer?.ID ?? null;
        }
        if (!reviewerPersonID || !IsValidUUID(reviewerPersonID)) {
            throw new Error('ReviewerPersonID could not be resolved to an active Person record.');
        }

        const md = this.getMetadataProvider(params.Provider);
        const reportEntity = await md.GetEntityObject<mjBizAppsTasksWorkReportEntity>(
            WORK_REPORTS_ENTITY_NAME,
            params.ContextUser,
        );
        const loaded = await reportEntity.Load(params.WorkReportID);
        if (!loaded) {
            throw new Error(`WorkReport '${params.WorkReportID}' not found.`);
        }

        if (reportEntity.Status !== 'Submitted') {
            throw new Error(
                `Only a 'Submitted' work report can be reviewed; current status is '${reportEntity.Status}'.`,
            );
        }

        if (UUIDsEqual(reportEntity.PersonID, reviewerPersonID)) {
            throw new Error('A work report author cannot review their own report.');
        }

        const supervisor = await this.ResolveSupervisorChainForPerson(
            reportEntity.PersonID,
            params.ContextUser,
            params.Provider,
        );

        if (params.EnforceReportingLine !== false && !isPrivileged) {
            const chainPersonIDs =
                supervisor.SupervisorChainPersonIDs && supervisor.SupervisorChainPersonIDs.length > 0
                    ? supervisor.SupervisorChainPersonIDs
                    : supervisor.SupervisorPersonID
                      ? [supervisor.SupervisorPersonID]
                      : [];
            if (chainPersonIDs.length === 0) {
                throw new Error(
                    "No mapped supervisor in MJ: Employees was resolved for this report's author; review refused.",
                );
            }
            if (!chainPersonIDs.some((id) => UUIDsEqual(id, reviewerPersonID))) {
                throw new Error(
                    "Only the author's mapped supervisor in MJ: Employees may record supervisor feedback on this report.",
                );
            }
            const chainUserIDs =
                supervisor.SupervisorChainUserIDs && supervisor.SupervisorChainUserIDs.length > 0
                    ? supervisor.SupervisorChainUserIDs
                    : supervisor.SupervisorUserID
                      ? [supervisor.SupervisorUserID]
                      : [];
            if (
                params.ContextUser?.ID &&
                chainUserIDs.length > 0 &&
                !chainUserIDs.some((id) => UUIDsEqual(id, params.ContextUser!.ID))
            ) {
                throw new Error(
                    "Authenticated user does not match the author's mapped supervisor in MJ: Employees.",
                );
            }
        }

        reportEntity.Status = 'Reviewed';
        reportEntity.SupervisorFeedback = feedback;
        reportEntity.ReviewedByPersonID = reviewerPersonID;
        reportEntity.ReviewedAt = new Date();

        const saved = await reportEntity.Save();
        if (!saved) {
            const msg = reportEntity.LatestResult?.CompleteMessage ?? 'Failed to save supervisor review on WorkReport';
            throw new Error(msg);
        }

        return {
            Report: this.snapshotReport(reportEntity, params.WorkReportID),
            Supervisor: supervisor,
        };
    }

    private buildItemSummary(section: WorkReportItemSection, entry: TaskActivityWindowEntry): string {
        switch (section) {
            case 'Completed': {
                const hrs = entry.HoursActual != null && entry.HoursActual > 0 ? ` (${entry.HoursActual}h)` : '';
                return entry.LatestCheckInSummary
                    ? `${entry.Name}${hrs} — ${entry.LatestCheckInSummary}`
                    : `${entry.Name}${hrs}`;
            }
            case 'InProgress': {
                const pct = entry.PercentComplete > 0 ? ` (${entry.PercentComplete}%)` : '';
                return entry.LatestCheckInSummary
                    ? `${entry.Name}${pct} — ${entry.LatestCheckInSummary}`
                    : `${entry.Name}${pct}`;
            }
            case 'Next': {
                const due = entry.DueAt ? ` (due ${entry.DueAt.slice(0, 10)})` : '';
                return `${entry.Name}${due}`;
            }
            case 'Blockers': {
                return entry.LatestCheckInSummary
                    ? `${entry.Name}: ${entry.LatestCheckInSummary}`
                    : entry.Name;
            }
            case 'AtRisk': {
                return `${entry.Name} [${entry.HealthStatus ?? 'AtRisk'}]`;
            }
            default: {
                return entry.Name;
            }
        }
    }

    private snapshotReport(entity: mjBizAppsTasksWorkReportEntity, fallbackID: string): WorkReportRecordSnapshot {
        return {
            ID: String(entity.ID ?? fallbackID),
            PersonID: entity.PersonID,
            PeriodStart: entity.PeriodStart instanceof Date ? entity.PeriodStart : new Date(entity.PeriodStart),
            PeriodEnd: entity.PeriodEnd instanceof Date ? entity.PeriodEnd : new Date(entity.PeriodEnd),
            Title: entity.Title ?? null,
            Body: entity.Body,
            Status: entity.Status,
            AuthoredByAgentRunID: entity.AuthoredByAgentRunID ?? null,
            SupervisorFeedback: entity.SupervisorFeedback ?? null,
            ReviewedByPersonID: entity.ReviewedByPersonID ?? null,
            ReviewedAt:
                entity.ReviewedAt instanceof Date
                    ? entity.ReviewedAt
                    : entity.ReviewedAt
                      ? new Date(entity.ReviewedAt)
                      : null,
        };
    }

    private async createSupervisorReviewAgentRequest(params: {
        Report: WorkReportRecordSnapshot;
        Supervisor: SupervisorResolution;
        ContextUser?: UserInfo;
        Provider?: WorkReportProvider;
    }): Promise<string | null> {
        const md = this.getMetadataProvider(params.Provider);
        const hasRequestsEntity = Boolean(findEntityByName(md, AI_AGENT_REQUESTS_ENTITY_NAME));
        if (!hasRequestsEntity || !params.Supervisor.SupervisorUserID) {
            return null;
        }

        const rv = this.createRunView(params.Provider);
        const workReportsEntity = findEntityByName(md, WORK_REPORTS_ENTITY_NAME);

        // Look up the Chief of Staff agent ID if available
        let cosAgentID: string | null = null;
        const cosAgentRes = await rv.RunView<RawAgentRow>(
            {
                EntityName: AI_AGENTS_ENTITY_NAME,
                ExtraFilter: `Name = 'Chief of Staff'`,
                Fields: ['ID'],
                MaxRows: 1,
                ResultType: 'simple',
            },
            params.ContextUser,
        );
        if (!cosAgentRes.Success) {
            LogError(
                `WorkReportService: failed to look up Chief of Staff agent for supervisor notification: ${cosAgentRes.ErrorMessage ?? 'RunView failed'}`,
            );
            return null;
        }
        cosAgentID = cosAgentRes.Results?.[0]?.ID ?? null;

        let requestTypeID: string | null = null;
        if (findEntityByName(md, AI_AGENT_REQUEST_TYPES_ENTITY_NAME)) {
            const rtRes = await rv.RunView<RawRequestTypeRow>(
                {
                    EntityName: AI_AGENT_REQUEST_TYPES_ENTITY_NAME,
                    ExtraFilter: `Name IN ('Approval', 'Information', 'Confirmation')`,
                    Fields: ['ID', 'Name'],
                    MaxRows: 1,
                    ResultType: 'simple',
                },
                params.ContextUser,
            );
            if (rtRes.Success) {
                requestTypeID = rtRes.Results?.[0]?.ID ?? null;
            }
        }

        const reqEntity = await md.GetEntityObject<AIAgentRequestEntity>(
            AI_AGENT_REQUESTS_ENTITY_NAME,
            params.ContextUser,
        );
        reqEntity.NewRecord();

        const periodStart = FormatReportCalendarDate(params.Report.PeriodStart);
        const periodEnd = FormatReportCalendarDate(params.Report.PeriodEnd);
        const periodLabel = periodStart === periodEnd ? periodStart : `${periodStart}..${periodEnd}`;
        const promptText =
            `15Five Work Report submitted by ${params.Supervisor.AuthorDisplayName} for ${periodLabel}:\n\n` +
            `${params.Report.Body}\n\n` +
            `Draft concise supervisor feedback and request ${params.Supervisor.SupervisorName ?? 'supervisor'}'s approval before recording it on WorkReport ${params.Report.ID}.`;

        reqEntity.AgentID = cosAgentID;
        reqEntity.RequestedByUserID = params.Supervisor.AuthorUserID ?? params.ContextUser?.ID ?? null;
        reqEntity.RequestForUserID = params.Supervisor.SupervisorUserID;
        reqEntity.RequestTypeID = requestTypeID;
        reqEntity.OriginatingEntityID = workReportsEntity?.ID ?? null;
        reqEntity.OriginatingRecordID = params.Report.ID;
        reqEntity.Request = promptText;
        reqEntity.Status = 'Requested';
        reqEntity.Priority = 50;
        reqEntity.ExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
        reqEntity.Comments = JSON.stringify({
            Kind: 'WorkReportSupervisorReview',
            WorkReportID: params.Report.ID,
            AuthorPersonID: params.Supervisor.AuthorPersonID,
            AuthorDisplayName: params.Supervisor.AuthorDisplayName,
            SupervisorPersonID: params.Supervisor.SupervisorPersonID,
            PeriodStart: periodStart,
            PeriodEnd: periodEnd,
        });

        const saved = await reqEntity.Save();
        if (!saved) {
            LogError(
                `WorkReportService: failed to save supervisor AI Agent Request for WorkReport '${params.Report.ID}': ${reqEntity.LatestResult?.CompleteMessage ?? 'Save returned false'}`,
            );
            return null;
        }
        return String(reqEntity.ID ?? reqEntity.PrimaryKey.Values()[0]);
    }
}
