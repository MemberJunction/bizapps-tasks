import { LogError, Metadata, RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import type { ActionParam, ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import {
    TypedActionPolicyGuard,
    type AgentEntityCrudOperation,
} from '@memberjunction/ai-core-plus';
import { AgentWakeTriggerService } from '@memberjunction/ai-agents';
import { UserCache } from '@memberjunction/generic-database-provider';
import { EscapeSQLString, IsValidUUID, UUIDsEqual } from '@memberjunction/global';
import { ResolveUserIDForPerson } from '@mj-biz-apps/common-entities';
import {
    PEOPLE_ENTITY_NAME,
    WorkReportService,
    type PersonIdentitySummary,
} from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskLinkEntity,
} from '@mj-biz-apps/tasks-entities';

export const TASKS_ENTITY = 'MJ_BizApps_Tasks: Tasks';
export const TASK_ASSIGNMENTS_ENTITY = 'MJ_BizApps_Tasks: Task Assignments';
export const TASK_DEPENDENCIES_ENTITY = 'MJ_BizApps_Tasks: Task Dependencies';
export const TASK_COMMENTS_ENTITY = 'MJ_BizApps_Tasks: Task Comments';
export const TASK_CHECK_INS_ENTITY = 'MJ_BizApps_Tasks: Task Check Ins';
export const TASK_LINKS_ENTITY = 'MJ_BizApps_Tasks: Task Links';
export const TASK_ACTIVITIES_ENTITY = 'MJ_BizApps_Tasks: Task Activities';
export const TASK_TYPES_ENTITY = 'MJ_BizApps_Tasks: Task Types';
export const TASK_ROLES_ENTITY = 'MJ_BizApps_Tasks: Task Roles';
export const TASK_AGENT_RUNS_ENTITY = 'MJ_BizApps_Tasks: Task Agent Runs';
export const WORK_REPORTS_ENTITY = 'MJ_BizApps_Tasks: Work Reports';
export const WORK_REPORT_ITEMS_ENTITY = 'MJ_BizApps_Tasks: Work Report Items';
export const ORGANIZATIONS_ENTITY = 'MJ_BizApps_Common: Organizations';
export const AI_AGENTS_ENTITY = 'MJ: AI Agents';
export const ROLES_ENTITY = 'MJ: Roles';
export const MEETINGS_ENTITY = 'MJ_BizApps_Tasks: Meetings';
export const MEETING_ATTENDEES_ENTITY = 'MJ_BizApps_Tasks: Meeting Attendees';
export const MEETING_AGENDA_ITEMS_ENTITY = 'MJ_BizApps_Tasks: Meeting Agenda Items';
export const MEETING_NOTES_ENTITY = 'MJ_BizApps_Tasks: Meeting Notes';
export const VIDEO_PROVIDERS_ENTITY = 'MJ_BizApps_Tasks: Video Providers';

export const PLANNING_TASK_TYPE_CODES = new Set<string>([
    'PRIORITY_OBJECTIVE',
    'KEY_RESULT',
    'PRIORITY',
]);

export const PLANNING_TASK_TYPE_NAMES = new Set<string>([
    'priority objective',
    'key result',
    'priority',
]);

export const CLIENT_REQUEST_KEY_PREFIX = 'client_request_key:';

export type TaskStatusValue = mjBizAppsTasksTaskEntity['Status'];
export type TaskPriorityValue = mjBizAppsTasksTaskEntity['Priority'];
export type TaskHealthStatusValue = NonNullable<mjBizAppsTasksTaskEntity['HealthStatus']>;

export interface ResolvedPersonCandidate {
    ID: string;
    Name: string;
    Email: string | null;
    LinkedUserID: string | null;
}

export type PersonLookupResult =
    | { Status: 'FOUND'; Person: ResolvedPersonCandidate }
    | { Status: 'NOT_FOUND'; Message: string }
    | { Status: 'AMBIGUOUS'; Candidates: ResolvedPersonCandidate[]; Message: string };

export interface PolicyGuardCheckResult {
    Allowed: boolean;
    DeniedFieldPatterns: string[];
    Failure?: ActionResultSimple;
}

export function getStringParam(params: RunActionParams, name: string, ...aliases: string[]): string | null {
    const names = [name, ...aliases].map((n) => n.toLowerCase());
    for (const target of names) {
        const found = params.Params.find((p) => p.Name.toLowerCase() === target);
        if (found && found.Value != null) {
            const str = String(found.Value).trim();
            if (str.length > 0) return str;
        }
    }
    return null;
}

export function getNumberParam(params: RunActionParams, name: string, ...aliases: string[]): number | null {
    const raw = getStringParam(params, name, ...aliases);
    if (raw === null) return null;
    const parsed = Number(raw);
    return Number.isFinite(parsed) ? parsed : null;
}

export function getBooleanParam(
    params: RunActionParams,
    name: string,
    defaultValue: boolean,
    ...aliases: string[]
): boolean {
    const names = [name, ...aliases].map((n) => n.toLowerCase());
    for (const target of names) {
        const found = params.Params.find((p) => p.Name.toLowerCase() === target);
        if (!found || found.Value == null) continue;
        if (typeof found.Value === 'boolean') return found.Value;
        const norm = String(found.Value).trim().toLowerCase();
        if (norm === 'true' || norm === '1' || norm === 'yes') return true;
        if (norm === 'false' || norm === '0' || norm === 'no') return false;
    }
    return defaultValue;
}

export function getDateParam(params: RunActionParams, name: string, ...aliases: string[]): Date | null | 'INVALID' {
    const raw = getStringParam(params, name, ...aliases);
    if (raw === null) return null;
    const dateOnly = /^(\d{4})-(\d{2})-(\d{2})$/.exec(raw);
    if (dateOnly) {
        const d = new Date(Date.UTC(Number(dateOnly[1]), Number(dateOnly[2]) - 1, Number(dateOnly[3]), 17, 0, 0));
        return Number.isNaN(d.getTime()) ? 'INVALID' : d;
    }
    const parsed = new Date(raw);
    return Number.isNaN(parsed.getTime()) ? 'INVALID' : parsed;
}

export function getStringListParam(params: RunActionParams, name: string, ...aliases: string[]): string[] {
    const names = [name, ...aliases].map((n) => n.toLowerCase());
    for (const target of names) {
        const found = params.Params.find((p) => p.Name.toLowerCase() === target);
        if (!found || found.Value == null) continue;
        if (Array.isArray(found.Value)) {
            return found.Value.map((v) => String(v).trim()).filter(Boolean);
        }
        const raw = String(found.Value).trim();
        if (!raw) continue;
        if (raw.startsWith('[')) {
            try {
                const parsed = JSON.parse(raw) as string[];
                if (Array.isArray(parsed)) {
                    return parsed.map((v) => String(v).trim()).filter(Boolean);
                }
            } catch {
                // Fall through to comma-split
            }
        }
        return raw.split(',').map((s) => s.trim()).filter(Boolean);
    }
    return [];
}

export function setOutputParam(
    params: RunActionParams,
    name: string,
    value: string | number | boolean | null,
): void {
    const existing = params.Params.find((p) => p.Name.toLowerCase() === name.toLowerCase());
    if (existing) {
        existing.Value = value;
        return;
    }
    const out: ActionParam = { Name: name, Value: value, Type: 'Output' };
    params.Params.push(out);
}

export function failResult(code: string, message: string, params?: RunActionParams): ActionResultSimple {
    return params
        ? { Success: false, ResultCode: code, Message: message, Params: params.Params }
        : { Success: false, ResultCode: code, Message: message };
}

export function successResult(
    message: string,
    params: RunActionParams,
    resultCode = 'SUCCESS',
): ActionResultSimple {
    return { Success: true, ResultCode: resultCode, Message: message, Params: params.Params };
}

export async function checkTypedPolicyGuard(input: {
    params: RunActionParams;
    entityName: string;
    operation: AgentEntityCrudOperation;
    writeFields?: readonly string[];
    record?: Record<string, string | number | boolean | null | undefined>;
    provider?: IMetadataProvider;
}): Promise<PolicyGuardCheckResult> {
    const outcome = await TypedActionPolicyGuard.CheckEntityAccess({
        entityName: input.entityName,
        operation: input.operation,
        contextUser: input.params.ContextUser,
        actionContext: input.params.Context,
        writeFields: input.writeFields,
        record: input.record,
        provider: input.provider,
    });
    if (!outcome.Allowed) {
        return {
            Allowed: false,
            DeniedFieldPatterns: [],
            Failure: failResult(
                outcome.ResultCode ?? 'POLICY_DENIED',
                outcome.Message ?? `Action on "${input.entityName}" (${input.operation}) blocked by agent user policy.`,
                input.params,
            ),
        };
    }
    return {
        Allowed: true,
        DeniedFieldPatterns: outcome.DeniedFieldPatterns,
    };
}

export function findEntityIDByName(entityName: string, provider: IMetadataProvider = Metadata.Provider): string | null {
    const match = provider.Entities?.find((e) => e.Name === entityName);
    return match?.ID ?? null;
}

export function normalizeTaskStatus(raw: string | null): TaskStatusValue | null {
    if (!raw) return null;
    const norm = raw.trim().toLowerCase().replace(/[\s_-]+/g, '');
    switch (norm) {
        case 'open':
        case 'todo':
        case 'pending':
            return 'Open';
        case 'inprogress':
        case 'active':
        case 'working':
            return 'InProgress';
        case 'blocked':
            return 'Blocked';
        case 'completed':
        case 'complete':
        case 'done':
            return 'Completed';
        case 'cancelled':
        case 'canceled':
            return 'Cancelled';
        default:
            return null;
    }
}

export function normalizeTaskPriority(raw: string | null): TaskPriorityValue | null {
    if (!raw) return null;
    const norm = raw.trim().toLowerCase();
    switch (norm) {
        case 'low':
            return 'Low';
        case 'medium':
        case 'normal':
            return 'Medium';
        case 'high':
            return 'High';
        case 'critical':
        case 'urgent':
            return 'Critical';
        default:
            return null;
    }
}

export function normalizeHealthStatus(raw: string | null): TaskHealthStatusValue | null {
    if (!raw) return null;
    const norm = raw.trim().toLowerCase().replace(/[\s_-]+/g, '');
    switch (norm) {
        case 'ontrack':
            return 'OnTrack';
        case 'atrisk':
            return 'AtRisk';
        case 'offtrack':
            return 'OffTrack';
        case 'completed':
        case 'complete':
            return 'Completed';
        case 'paused':
            return 'Paused';
        default:
            return null;
    }
}

export function toIsoOrNull(value: Date | string | null | undefined): string | null {
    if (!value) return null;
    const d = value instanceof Date ? value : new Date(value);
    return Number.isNaN(d.getTime()) ? null : d.toISOString();
}

export function buildTaskDeepLink(taskID: string): string {
    return `/resource/record/MJ_BizApps_Tasks%3A%20Tasks/${encodeURIComponent(taskID)}`;
}

export function buildMeetingDeepLink(meetingID: string): string {
    return `/resource/record/MJ_BizApps_Tasks%3A%20Meetings/${encodeURIComponent(meetingID)}`;
}

export function buildWorkReportDeepLink(workReportID: string): string {
    return `/resource/record/MJ_BizApps_Tasks%3A%20Work%20Reports/${encodeURIComponent(workReportID)}`;
}

export async function resolveCallerPerson(user: UserInfo): Promise<PersonIdentitySummary | null> {
    return WorkReportService.Instance.ResolvePersonForUser(user);
}

interface RawPersonLookupRow {
    ID: string;
    FirstName?: string | null;
    LastName?: string | null;
    PreferredName?: string | null;
    Email?: string | null;
    LinkedUserID?: string | null;
}

function formatPersonRow(row: RawPersonLookupRow): ResolvedPersonCandidate {
    const full = `${row.FirstName ?? ''} ${row.LastName ?? ''}`.trim();
    const display = full || row.PreferredName?.trim() || row.Email?.trim() || row.ID;
    return {
        ID: row.ID,
        Name: display,
        Email: row.Email ?? null,
        LinkedUserID: row.LinkedUserID ?? null,
    };
}

/**
 * Resolves a `MJ_BizApps_Common: People` record by ID, email, or name.
 * Returns `AMBIGUOUS` with candidate details when multiple active people match.
 */
export async function resolvePersonByIdentifier(
    input: { personID?: string | null; email?: string | null; name?: string | null },
    contextUser: UserInfo,
): Promise<PersonLookupResult> {
    const rv = new RunView();

    if (input.personID) {
        if (!IsValidUUID(input.personID)) {
            return { Status: 'NOT_FOUND', Message: `PersonID '${input.personID}' is not a valid UUID.` };
        }
        const res = await rv.RunView<RawPersonLookupRow>(
            {
                EntityName: PEOPLE_ENTITY_NAME,
                ExtraFilter: `ID = '${EscapeSQLString(input.personID)}'`,
                Fields: ['ID', 'FirstName', 'LastName', 'PreferredName', 'Email', 'LinkedUserID'],
                MaxRows: 1,
                ResultType: 'simple',
            },
            contextUser,
        );
        const row = res.Success ? res.Results?.[0] : undefined;
        if (!row) {
            return { Status: 'NOT_FOUND', Message: `No Person found with ID '${input.personID}'.` };
        }
        return { Status: 'FOUND', Person: formatPersonRow(row) };
    }

    if (input.email) {
        const cleanEmail = input.email.trim();
        const res = await rv.RunView<RawPersonLookupRow>(
            {
                EntityName: PEOPLE_ENTITY_NAME,
                ExtraFilter: `LOWER(Email) = LOWER('${EscapeSQLString(cleanEmail)}') AND Status = 'Active'`,
                Fields: ['ID', 'FirstName', 'LastName', 'PreferredName', 'Email', 'LinkedUserID'],
                MaxRows: 10,
                ResultType: 'simple',
            },
            contextUser,
        );
        const rows = res.Success ? (res.Results ?? []) : [];
        if (rows.length === 0) {
            return { Status: 'NOT_FOUND', Message: `No active Person found with email '${cleanEmail}'.` };
        }
        if (rows.length === 1) {
            return { Status: 'FOUND', Person: formatPersonRow(rows[0]) };
        }
        const candidates = rows.map(formatPersonRow);
        return {
            Status: 'AMBIGUOUS',
            Candidates: candidates,
            Message: `Multiple active People matched email '${cleanEmail}'. Please clarify by PersonID.`,
        };
    }

    if (input.name) {
        const cleanName = input.name.trim();
        const tokens = cleanName.split(/\s+/).filter(Boolean);
        let filter: string;
        if (tokens.length >= 2) {
            const first = EscapeSQLString(tokens[0]);
            const last = EscapeSQLString(tokens[tokens.length - 1]);
            filter =
                `Status = 'Active' AND (` +
                `(LOWER(FirstName) LIKE LOWER('${first}%') AND LOWER(LastName) LIKE LOWER('${last}%')) ` +
                `OR (LOWER(PreferredName) LIKE LOWER('${first}%') AND LOWER(LastName) LIKE LOWER('${last}%'))` +
                `)`;
        } else {
            const escaped = EscapeSQLString(cleanName);
            filter =
                `Status = 'Active' AND (` +
                `LOWER(FirstName) LIKE LOWER('%${escaped}%') ` +
                `OR LOWER(LastName) LIKE LOWER('%${escaped}%') ` +
                `OR LOWER(PreferredName) LIKE LOWER('%${escaped}%') ` +
                `OR LOWER(Email) LIKE LOWER('%${escaped}%')` +
                `)`;
        }

        const res = await rv.RunView<RawPersonLookupRow>(
            {
                EntityName: PEOPLE_ENTITY_NAME,
                ExtraFilter: filter,
                Fields: ['ID', 'FirstName', 'LastName', 'PreferredName', 'Email', 'LinkedUserID'],
                MaxRows: 10,
                ResultType: 'simple',
            },
            contextUser,
        );
        const rows = res.Success ? (res.Results ?? []) : [];
        if (rows.length === 0) {
            return { Status: 'NOT_FOUND', Message: `No active Person matched '${cleanName}'.` };
        }
        if (rows.length === 1) {
            return { Status: 'FOUND', Person: formatPersonRow(rows[0]) };
        }
        const candidates = rows.map(formatPersonRow);
        const exactMatch = candidates.filter(
            (c) => c.Name.toLowerCase() === cleanName.toLowerCase(),
        );
        if (exactMatch.length === 1) {
            return { Status: 'FOUND', Person: exactMatch[0] };
        }
        return {
            Status: 'AMBIGUOUS',
            Candidates: candidates,
            Message: `Multiple active People matched '${cleanName}'. Please clarify which person to use.`,
        };
    }

    return { Status: 'NOT_FOUND', Message: 'No person identifier supplied.' };
}

/**
 * Resolves the MJ UserID linked to a Person record (best-effort).
 */
export async function resolveUserIDForPersonRecord(
    personID: string,
    contextUser: UserInfo,
): Promise<string | null> {
    if (!IsValidUUID(personID)) return null;
    try {
        return await ResolveUserIDForPerson(personID, Metadata.Provider, contextUser);
    } catch {
        return null;
    }
}

/**
 * Best-effort Chief of Staff wake helper for domain events (task assignment, dependency unblock,
 * assigned-agent completion). Uses the sanctioned cross-user elevation pattern: domain authority
 * has already been validated under `actingUser`, so cross-user wake persistence runs with
 * `UserCache.Instance.GetSystemUser() ?? actingUser` while recording `triggeredByUserID`.
 */
export async function wakeChiefOfStaffBestEffort(input: {
    targetUserID: string;
    workstreamKey: string;
    wakeReason: string;
    resumeState: Record<string, string | number | boolean | null>;
    actingUser: UserInfo;
}): Promise<boolean> {
    if (!IsValidUUID(input.targetUserID)) return false;
    try {
        const isSelfWake = UUIDsEqual(input.actingUser.ID, input.targetUserID);
        const wakeContextUser = isSelfWake
            ? input.actingUser
            : (UserCache.Instance.GetSystemUser() ?? input.actingUser);

        const res = await AgentWakeTriggerService.Instance.TriggerWakeForWorkstream({
            targetUserID: input.targetUserID,
            targetAgentName: 'Chief of Staff',
            workstreamKey: input.workstreamKey,
            wakeReason: input.wakeReason,
            resumeState: {
                ...input.resumeState,
                triggeredByUserID: input.actingUser.ID,
            },
            contextUser: wakeContextUser,
        });
        return res.triggered;
    } catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        LogError(`[BizAppsTasks] Best-effort Chief of Staff wake failed for workstream '${input.workstreamKey}': ${msg}`);
        return false;
    }
}

/**
 * Links a task to an `MJ_BizApps_Common: Organizations` record via `TaskLink` (idempotent).
 * Keeps organization scoping working cleanly prior to the physical `Task.OrganizationID` migration.
 */
export async function upsertTaskOrganizationLink(
    taskID: string,
    organizationID: string,
    contextUser: UserInfo,
): Promise<void> {
    const orgEntityID = findEntityIDByName(ORGANIZATIONS_ENTITY);
    if (!orgEntityID || !IsValidUUID(organizationID)) return;

    const rv = new RunView();
    const existing = await rv.RunView<{ ID: string; RecordID: string }>(
        {
            EntityName: TASK_LINKS_ENTITY,
            ExtraFilter: `TaskID = '${EscapeSQLString(taskID)}' AND EntityID = '${EscapeSQLString(orgEntityID)}'`,
            Fields: ['ID', 'RecordID'],
            MaxRows: 10,
            ResultType: 'simple',
        },
        contextUser,
    );
    const rows = existing.Success ? (existing.Results ?? []) : [];
    if (rows.some((r) => UUIDsEqual(r.RecordID, organizationID))) {
        return;
    }

    const md = new Metadata();
    const link = await md.GetEntityObject<mjBizAppsTasksTaskLinkEntity>(TASK_LINKS_ENTITY, contextUser);
    link.NewRecord();
    link.TaskID = taskID;
    link.EntityID = orgEntityID;
    link.RecordID = organizationID;
    link.Description = 'Scoped organization';
    await link.Save();
}
