import { RunView, type UserInfo } from '@memberjunction/core';
import type { ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import { TypedActionPolicyGuard } from '@memberjunction/ai-core-plus';
import { EscapeSQLString, IsValidUUID, RegisterClass, UUIDsEqual } from '@memberjunction/global';
import {
    EvaluateProjectRiskCadence,
    PEOPLE_ENTITY_NAME,
    ProjectRiskAnalystRegistry,
    TasksLimitsResolver,
    type MLBreachSignal,
    type ProjectAssigneeRawFreeBusy,
    type ProjectRiskAssessmentSummary,
    type ProjectRiskHealthStatusValue,
    type ProjectRiskRootTaskRollup,
    type ProjectSLARiskBandValue,
    type ProjectTaskPriorityValue,
    type ProjectTaskStatusValue,
    type RawFreeBusySlotInput,
} from '@mj-biz-apps/tasks-core';
import {
    ParseTaskRiskItems,
    TASK_RISK_ASSESSMENT_ENTITY,
    type mjBizAppsTasksTaskEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    checkTypedPolicyGuard,
    failResult,
    findEntityIDByName,
    getBooleanParam,
    getNumberParam,
    getStringParam,
    resolveCallerPerson,
    ROLES_ENTITY,
    setOutputParam,
    successResult,
    TASK_ASSIGNMENTS_ENTITY,
    TASKS_ENTITY,
    toIsoOrNull,
} from './action-helpers.js';

export const GET_PROJECT_RISK_ACTION_ID = '35DF1BB3-778B-4500-A607-DAD9B92D9AED';
export const REQUEST_PROJECT_RISK_REVIEW_ACTION_ID = '30E51973-5EF0-447C-8225-2BF57C216857';

const PRIVILEGED_ROLE_NAMES = new Set(['developer', 'administrator', 'system administrator']);

const PROJECT_TASK_FIELDS: string[] = [
    'ID',
    'Name',
    'ParentID',
    'RootParentID',
    'Status',
    'Priority',
    'Visibility',
    'StartedAt',
    'DueAt',
    'PercentComplete',
    'CreatedByPersonID',
    'HealthStatus',
    'ConfidenceScore',
    'ForecastCompletionDate',
    'PredictedSLABreachProbability',
    'PredictedSLARiskBand',
    '__mj_CreatedAt',
];

const RISK_ASSESSMENT_FIELDS: string[] = [
    'ID',
    'TaskID',
    'AssessedAt',
    'ForecastCompletionDate',
    'ForecastConfidence',
    'HealthStatus',
    'MLBreachProbability',
    'Risks',
    'AgentRunID',
    'PromptTokens',
    'CompletionTokens',
    'TotalCostUSD',
];

interface AuthorizedTaskRow {
    ID: string;
    Name: string;
    ParentID: string | null;
    RootParentID: string | null;
    Status: ProjectTaskStatusValue;
    Priority: ProjectTaskPriorityValue;
    Visibility?: mjBizAppsTasksTaskEntity['Visibility'] | null;
    StartedAt: string | Date | null;
    DueAt: string | Date | null;
    PercentComplete: number;
    CreatedByPersonID: string | null;
    HealthStatus: ProjectRiskHealthStatusValue | null;
    ConfidenceScore: number | null;
    ForecastCompletionDate: string | Date | null;
    PredictedSLABreachProbability: number | null;
    PredictedSLARiskBand: ProjectSLARiskBandValue | null;
    __mj_CreatedAt: string | Date;
}

interface TaskRiskAssessmentRow {
    ID: string;
    TaskID: string;
    AssessedAt: string | Date;
    ForecastCompletionDate: string | Date | null;
    ForecastConfidence: number | null;
    HealthStatus: ProjectRiskHealthStatusValue;
    MLBreachProbability: number | null;
    Risks: string;
    AgentRunID: string | null;
    PromptTokens: number | null;
    CompletionTokens: number | null;
    TotalCostUSD: number | null;
}

interface RawTaskAssignmentAccessRow {
    TaskID: string;
    AssigneeEntityID: string;
    AssigneeEntity?: string | null;
    AssigneeRecordID: string;
}

interface RawFreeBusyOverrideEntry {
    PersonID?: string | null;
    personId?: string | null;
    UserID?: string | null;
    userId?: string | null;
    Slots?: readonly RawFreeBusySlotInput[];
    slots?: readonly RawFreeBusySlotInput[];
}

type RootResolutionResult =
    | { Status: 'OK'; TargetTask: AuthorizedTaskRow; RootTask: AuthorizedTaskRow }
    | { Status: 'FAILURE'; Failure: ActionResultSimple };

function isPrivilegedCaller(user: UserInfo): boolean {
    return (user.UserRoles ?? []).some((ur) => PRIVILEGED_ROLE_NAMES.has((ur.Role ?? '').trim().toLowerCase()));
}

async function callerHasTaskAssignment(
    rv: RunView,
    taskIds: readonly string[],
    callerPersonId: string | null,
    user: UserInfo,
): Promise<boolean> {
    const validIds = taskIds.filter((id) => IsValidUUID(id));
    if (validIds.length === 0) return false;

    const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
    const inList = validIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
    const assignRes = await rv.RunView<RawTaskAssignmentAccessRow>(
        {
            EntityName: TASK_ASSIGNMENTS_ENTITY,
            ExtraFilter: `TaskID IN (${inList})`,
            Fields: ['TaskID', 'AssigneeEntityID', 'AssigneeEntity', 'AssigneeRecordID'],
            MaxRows: limits.ResourceGuards.StandardListMaxRows,
            ResultType: 'simple',
        },
        user,
    );
    const rows = assignRes.Success ? (assignRes.Results ?? []) : [];
    const peopleEntityID = findEntityIDByName(PEOPLE_ENTITY_NAME);
    const rolesEntityID = findEntityIDByName(ROLES_ENTITY);
    const callerRoleIds = (user.UserRoles ?? [])
        .map((ur) => ur.RoleID)
        .filter((id): id is string => Boolean(id && IsValidUUID(id)));

    return rows.some((row) => {
        if (
            callerPersonId &&
            (row.AssigneeEntity === PEOPLE_ENTITY_NAME ||
                (peopleEntityID && UUIDsEqual(row.AssigneeEntityID, peopleEntityID)))
        ) {
            return UUIDsEqual(row.AssigneeRecordID, callerPersonId);
        }
        if (
            row.AssigneeEntity === 'MJ: Users' &&
            UUIDsEqual(row.AssigneeRecordID, user.ID)
        ) {
            return true;
        }
        if (
            row.AssigneeEntity === ROLES_ENTITY ||
            (rolesEntityID && UUIDsEqual(row.AssigneeEntityID, rolesEntityID))
        ) {
            return callerRoleIds.some((roleId) => UUIDsEqual(roleId, row.AssigneeRecordID));
        }
        return false;
    });
}

/**
 * Verifies caller permissions against the target task and its root project task via
 * `params.ContextUser` BEFORE reading risk assessments or switching execution context
 * to the project owner user.
 */
async function resolveAuthorizedProjectRootTask(
    params: RunActionParams,
    taskID: string,
    user: UserInfo,
): Promise<RootResolutionResult> {
    const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
    const rv = new RunView();

    const targetRes = await rv.RunView<AuthorizedTaskRow>(
        {
            EntityName: TASKS_ENTITY,
            ExtraFilter: `ID = '${EscapeSQLString(taskID)}'`,
            Fields: PROJECT_TASK_FIELDS,
            MaxRows: limits.ResourceGuards.DefaultLookupSingleRow,
            ResultType: 'simple',
        },
        user,
    );
    const targetTask = targetRes.Success ? targetRes.Results?.[0] : undefined;
    if (!targetTask) {
        return {
            Status: 'FAILURE',
            Failure: failResult('NOT_FOUND', `Task '${taskID}' was not found or is not accessible.`, params),
        };
    }

    let rootTask: AuthorizedTaskRow = targetTask;
    if (targetTask.ParentID) {
        if (targetTask.RootParentID && !UUIDsEqual(targetTask.RootParentID, targetTask.ID)) {
            const rootRes = await rv.RunView<AuthorizedTaskRow>(
                {
                    EntityName: TASKS_ENTITY,
                    ExtraFilter: `ID = '${EscapeSQLString(targetTask.RootParentID)}'`,
                    Fields: PROJECT_TASK_FIELDS,
                    MaxRows: limits.ResourceGuards.DefaultLookupSingleRow,
                    ResultType: 'simple',
                },
                user,
            );
            const rootCandidate = rootRes.Success ? rootRes.Results?.[0] : undefined;
            if (!rootCandidate) {
                return {
                    Status: 'FAILURE',
                    Failure: failResult(
                        'NOT_FOUND',
                        `Root project task '${targetTask.RootParentID}' is not accessible to caller.`,
                        params,
                    ),
                };
            }
            rootTask = rootCandidate;
        } else {
            const visited = new Set<string>([targetTask.ID.toLowerCase()]);
            let current = targetTask;
            for (let depth = 0; depth < limits.RunawayGuards.MaxHierarchyDepth && current.ParentID; depth++) {
                const parentKey = current.ParentID.toLowerCase();
                if (visited.has(parentKey)) break;
                visited.add(parentKey);
                const parentRes = await rv.RunView<AuthorizedTaskRow>(
                    {
                        EntityName: TASKS_ENTITY,
                        ExtraFilter: `ID = '${EscapeSQLString(current.ParentID)}'`,
                        Fields: PROJECT_TASK_FIELDS,
                        MaxRows: limits.ResourceGuards.DefaultLookupSingleRow,
                        ResultType: 'simple',
                    },
                    user,
                );
                const parentRow = parentRes.Success ? parentRes.Results?.[0] : undefined;
                if (!parentRow) {
                    return {
                        Status: 'FAILURE',
                        Failure: failResult(
                            'PERMISSION_DENIED',
                            `Ancestor project task '${current.ParentID}' is not accessible to caller.`,
                            params,
                        ),
                    };
                }
                current = parentRow;
            }
            rootTask = current;
        }
    }

    if ((targetTask.Visibility === 'Private' || rootTask.Visibility === 'Private') && !isPrivilegedCaller(user)) {
        const callerPerson = await resolveCallerPerson(user);
        const callerPersonId = callerPerson?.ID ?? null;
        const isCreator =
            callerPersonId !== null &&
            ((targetTask.CreatedByPersonID && UUIDsEqual(targetTask.CreatedByPersonID, callerPersonId)) ||
                (rootTask.CreatedByPersonID && UUIDsEqual(rootTask.CreatedByPersonID, callerPersonId)));

        if (!isCreator) {
            const isAssigned = await callerHasTaskAssignment(
                rv,
                [targetTask.ID, rootTask.ID],
                callerPersonId,
                user,
            );
            if (!isAssigned) {
                return {
                    Status: 'FAILURE',
                    Failure: failResult(
                        'PERMISSION_DENIED',
                        'Caller does not have permission to access this private project task.',
                        params,
                    ),
                };
            }
        }
    }

    return { Status: 'OK', TargetTask: targetTask, RootTask: rootTask };
}

function toRootTaskRollup(row: AuthorizedTaskRow): ProjectRiskRootTaskRollup {
    return {
        ID: row.ID,
        Name: row.Name,
        Status: row.Status,
        Priority: row.Priority,
        StartedAtISO: toIsoOrNull(row.StartedAt ?? row.__mj_CreatedAt),
        DueAtISO: toIsoOrNull(row.DueAt),
        PercentComplete: row.PercentComplete ?? 0,
        HealthStatus: row.HealthStatus ?? null,
        ConfidenceScore: row.ConfidenceScore ?? null,
        ForecastCompletionDateISO: toIsoOrNull(row.ForecastCompletionDate),
        PredictedSLABreachProbability: row.PredictedSLABreachProbability ?? null,
        PredictedSLARiskBand: row.PredictedSLARiskBand ?? null,
    };
}

function toAssessmentSummary(row: TaskRiskAssessmentRow): ProjectRiskAssessmentSummary {
    return {
        AssessmentID: row.ID,
        TaskID: row.TaskID,
        AssessedAtISO: toIsoOrNull(row.AssessedAt) ?? '',
        HealthStatus: row.HealthStatus,
        ForecastCompletionDateISO: toIsoOrNull(row.ForecastCompletionDate),
        ForecastConfidence: row.ForecastConfidence ?? null,
        MLBreachProbability: row.MLBreachProbability ?? null,
        Risks: ParseTaskRiskItems(row.Risks),
        AgentRunID: row.AgentRunID ?? null,
        PromptTokens: row.PromptTokens ?? null,
        CompletionTokens: row.CompletionTokens ?? null,
        TotalCostUSD: row.TotalCostUSD ?? null,
    };
}

function normalizeSlaRiskBand(raw: string | null): ProjectSLARiskBandValue | null {
    if (!raw) return null;
    const norm = raw.trim().toLowerCase();
    switch (norm) {
        case 'low':
            return 'Low';
        case 'medium':
            return 'Medium';
        case 'high':
            return 'High';
        case 'critical':
            return 'Critical';
        default:
            return null;
    }
}

interface FreeBusyParseResult {
    Ok: boolean;
    Value?: readonly ProjectAssigneeRawFreeBusy[] | null;
    Message?: string;
}

function applyPolicyFieldMask<T extends object>(record: T, deniedPatterns: readonly string[]): T {
    if (deniedPatterns.length === 0) {
        return record;
    }
    const probe: Record<string, string | number | boolean | null | undefined> = {};
    for (const [key, val] of Object.entries(record)) {
        probe[key] =
            val == null || typeof val === 'string' || typeof val === 'number' || typeof val === 'boolean'
                ? val
                : '[object]';
    }
    const maskedProbe = TypedActionPolicyGuard.MaskRecord(probe, deniedPatterns);
    const out: Record<string, string | number | boolean | object | null | undefined> = {};
    for (const [key, val] of Object.entries(record)) {
        if (Object.prototype.hasOwnProperty.call(maskedProbe, key)) {
            out[key] = val as string | number | boolean | object | null | undefined;
        }
    }
    return out as T;
}

function parseFreeBusyOverrides(params: RunActionParams): FreeBusyParseResult {
    const param = params.Params.find(
        (p) =>
            p.Name.toLowerCase() === 'freebusyjson' ||
            p.Name.toLowerCase() === 'freebusyoverrides' ||
            p.Name.toLowerCase() === 'freebusyslots',
    );
    if (!param || param.Value == null) {
        return { Ok: true, Value: null };
    }

    let parsedInput: RawFreeBusyOverrideEntry[] | RawFreeBusySlotInput[];
    if (typeof param.Value === 'string') {
        const trimmed = param.Value.trim();
        if (!trimmed) {
            return { Ok: true, Value: null };
        }
        try {
            parsedInput = JSON.parse(trimmed) as RawFreeBusyOverrideEntry[] | RawFreeBusySlotInput[];
        } catch (err) {
            return {
                Ok: false,
                Message: `FreeBusyJSON must be valid JSON: ${err instanceof Error ? err.message : String(err)}`,
            };
        }
    } else if (Array.isArray(param.Value)) {
        parsedInput = param.Value as RawFreeBusyOverrideEntry[] | RawFreeBusySlotInput[];
    } else {
        return { Ok: false, Message: 'FreeBusyJSON must be a JSON array.' };
    }

    if (!Array.isArray(parsedInput)) {
        return { Ok: false, Message: 'FreeBusyJSON must decode to a JSON array.' };
    }
    if (parsedInput.length === 0) {
        return { Ok: true, Value: [] };
    }

    const first = parsedInput[0] as RawFreeBusyOverrideEntry & Partial<RawFreeBusySlotInput>;
    if (first && typeof first === 'object' && ('StartTime' in first || 'EndTime' in first)) {
        return {
            Ok: true,
            Value: [
                {
                    PersonID: null,
                    UserID: null,
                    Slots: parsedInput as RawFreeBusySlotInput[],
                },
            ],
        };
    }

    const mapped: ProjectAssigneeRawFreeBusy[] = [];
    for (const item of parsedInput as RawFreeBusyOverrideEntry[]) {
        if (!item || typeof item !== 'object') {
            return { Ok: false, Message: 'Each FreeBusyJSON entry must be an object.' };
        }
        const slots = item.Slots ?? item.slots;
        if (!Array.isArray(slots)) {
            return { Ok: false, Message: 'Each FreeBusyJSON entry must provide a Slots array.' };
        }
        mapped.push({
            PersonID: item.PersonID ?? item.personId ?? null,
            UserID: item.UserID ?? item.userId ?? null,
            Slots: slots,
        });
    }

    return { Ok: true, Value: mapped };
}

/**
 * Action: `Get Project Risk` (`DriverClass: 'GetProjectRiskAction'`).
 *
 * Queries the latest (and optional history) `MJ_BizApps_Tasks: Task Risk Assessments`
 * record for a project root task using batched `RunView` (`ResultType: 'simple'`),
 * returning strongly-typed forecast, health, ML breach probability, parsed `Risks[]`,
 * `AgentRunID`, cost metrics, synchronized root task fields, and current monitoring cadence.
 */
@RegisterClass(BaseAction, 'GetProjectRiskAction')
export class GetProjectRiskAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const taskID = getStringParam(params, 'TaskID');
        if (!taskID || !IsValidUUID(taskID)) {
            return failResult('VALIDATION_ERROR', 'A valid TaskID UUID is required.', params);
        }

        const tasksGuard = await checkTypedPolicyGuard({
            params,
            entityName: TASKS_ENTITY,
            operation: 'Read',
            actionName: 'Get Project Risk',
        });
        if (!tasksGuard.Allowed) return tasksGuard.Failure!;

        const assessmentGuard = await checkTypedPolicyGuard({
            params,
            entityName: TASK_RISK_ASSESSMENT_ENTITY,
            operation: 'Read',
            actionName: 'Get Project Risk',
        });
        if (!assessmentGuard.Allowed) return assessmentGuard.Failure!;

        try {
            const resolution = await resolveAuthorizedProjectRootTask(params, taskID, user);
            if (resolution.Status === 'FAILURE') {
                return resolution.Failure;
            }

            const rootTask = resolution.RootTask;
            const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
            const includeHistory = getBooleanParam(params, 'IncludeHistory', false);
            const rawHistoryLimit =
                getNumberParam(params, 'HistoryLimit') ?? limits.ResourceGuards.CandidateLookupMaxRows;
            const minLimit = limits.ResourceGuards.DefaultLookupSingleRow;
            const maxLimit = limits.ResourceGuards.StandardListMaxRows;
            const historyLimit = Math.max(minLimit, Math.min(maxLimit, Math.round(rawHistoryLimit)));

            const rv = new RunView();
            const assessRes = await rv.RunView<TaskRiskAssessmentRow>(
                {
                    EntityName: TASK_RISK_ASSESSMENT_ENTITY,
                    ExtraFilter: `TaskID = '${EscapeSQLString(rootTask.ID)}'`,
                    Fields: RISK_ASSESSMENT_FIELDS,
                    OrderBy: 'AssessedAt DESC',
                    MaxRows: includeHistory ? historyLimit : minLimit,
                    ResultType: 'simple',
                },
                user,
            );
            if (!assessRes.Success) {
                return failResult(
                    'ERROR',
                    assessRes.ErrorMessage ?? 'Failed to query Task Risk Assessments.',
                    params,
                );
            }

            const rows = assessRes.Results ?? [];
            const latestRow = rows[0] ?? null;
            const latestSummary = latestRow ? toAssessmentSummary(latestRow) : null;
            const historySummaries = includeHistory ? rows.map(toAssessmentSummary) : [];
            const cadence = EvaluateProjectRiskCadence({
                TaskStatus: rootTask.Status,
                StartedAt: rootTask.StartedAt,
                CreatedAt: rootTask.__mj_CreatedAt,
                DueAt: rootTask.DueAt,
                LatestAssessedAt: latestRow?.AssessedAt ?? null,
            });
            const maskedRootTask = applyPolicyFieldMask(
                toRootTaskRollup(rootTask),
                tasksGuard.DeniedFieldPatterns,
            );

            if (!latestSummary) {
                const emptyPayload = {
                    HasAssessment: false,
                    TaskID: rootTask.ID,
                    AssessmentID: null,
                    AssessedAt: null,
                    HealthStatus: maskedRootTask.HealthStatus ?? null,
                    ForecastCompletionDate: maskedRootTask.ForecastCompletionDateISO ?? null,
                    ForecastConfidence: maskedRootTask.ConfidenceScore ?? null,
                    MLBreachProbability: maskedRootTask.PredictedSLABreachProbability ?? null,
                    Risks: [],
                    AgentRunID: null,
                    PromptTokens: null,
                    CompletionTokens: null,
                    TotalCostUSD: null,
                    Cadence: cadence.Cadence,
                    CadenceDetail: cadence,
                    RootTask: maskedRootTask,
                    History: [],
                };
                const summary = `No risk assessment recorded yet for project "${maskedRootTask.Name ?? rootTask.ID}" (cadence: ${cadence.Cadence}).`;
                setOutputParam(params, 'HasAssessment', false);
                setOutputParam(params, 'TaskID', rootTask.ID);
                setOutputParam(params, 'AssessmentID', null);
                setOutputParam(params, 'AssessedAt', null);
                setOutputParam(params, 'HealthStatus', maskedRootTask.HealthStatus ?? null);
                setOutputParam(params, 'ForecastCompletionDate', maskedRootTask.ForecastCompletionDateISO ?? null);
                setOutputParam(params, 'ForecastConfidence', maskedRootTask.ConfidenceScore ?? null);
                setOutputParam(params, 'MLBreachProbability', maskedRootTask.PredictedSLABreachProbability ?? null);
                setOutputParam(params, 'Risks', JSON.stringify([]));
                setOutputParam(params, 'AgentRunID', null);
                setOutputParam(params, 'PromptTokens', null);
                setOutputParam(params, 'CompletionTokens', null);
                setOutputParam(params, 'TotalCostUSD', null);
                setOutputParam(params, 'Cadence', cadence.Cadence);
                setOutputParam(params, 'CadenceDetail', JSON.stringify(cadence));
                setOutputParam(params, 'RootTask', JSON.stringify(maskedRootTask));
                setOutputParam(params, 'History', JSON.stringify([]));
                setOutputParam(params, 'ProjectRisk', JSON.stringify(emptyPayload));
                setOutputParam(params, 'Summary', summary);
                return successResult(summary, params, 'NO_ASSESSMENT');
            }

            const maskedLatest = applyPolicyFieldMask(latestSummary, assessmentGuard.DeniedFieldPatterns);
            const maskedHistory = historySummaries.map((h) =>
                applyPolicyFieldMask(h, assessmentGuard.DeniedFieldPatterns),
            );

            const fullPayload = {
                HasAssessment: true,
                TaskID: rootTask.ID,
                AssessmentID: maskedLatest.AssessmentID,
                AssessedAt: maskedLatest.AssessedAtISO,
                HealthStatus: maskedLatest.HealthStatus,
                ForecastCompletionDate: maskedLatest.ForecastCompletionDateISO,
                ForecastConfidence: maskedLatest.ForecastConfidence,
                MLBreachProbability: maskedLatest.MLBreachProbability,
                Risks: maskedLatest.Risks ?? [],
                AgentRunID: maskedLatest.AgentRunID,
                PromptTokens: maskedLatest.PromptTokens,
                CompletionTokens: maskedLatest.CompletionTokens,
                TotalCostUSD: maskedLatest.TotalCostUSD,
                Cadence: cadence.Cadence,
                CadenceDetail: cadence,
                RootTask: maskedRootTask,
                History: maskedHistory,
            };

            const risksList = maskedLatest.Risks ?? [];
            const summary =
                `Project "${maskedRootTask.Name ?? rootTask.ID}" risk is ${maskedLatest.HealthStatus ?? 'Unknown'} ` +
                `(confidence: ${maskedLatest.ForecastConfidence ?? 'n/a'}%, cadence: ${cadence.Cadence}, risks: ${risksList.length}).`;

            setOutputParam(params, 'HasAssessment', true);
            setOutputParam(params, 'TaskID', rootTask.ID);
            setOutputParam(params, 'AssessmentID', maskedLatest.AssessmentID ?? null);
            setOutputParam(params, 'AssessedAt', maskedLatest.AssessedAtISO ?? null);
            setOutputParam(params, 'HealthStatus', maskedLatest.HealthStatus ?? null);
            setOutputParam(params, 'ForecastCompletionDate', maskedLatest.ForecastCompletionDateISO ?? null);
            setOutputParam(params, 'ForecastConfidence', maskedLatest.ForecastConfidence ?? null);
            setOutputParam(params, 'MLBreachProbability', maskedLatest.MLBreachProbability ?? null);
            setOutputParam(params, 'Risks', JSON.stringify(risksList));
            setOutputParam(params, 'AgentRunID', maskedLatest.AgentRunID ?? null);
            setOutputParam(params, 'PromptTokens', maskedLatest.PromptTokens ?? null);
            setOutputParam(params, 'CompletionTokens', maskedLatest.CompletionTokens ?? null);
            setOutputParam(params, 'TotalCostUSD', maskedLatest.TotalCostUSD ?? null);
            setOutputParam(params, 'Cadence', cadence.Cadence);
            setOutputParam(params, 'CadenceDetail', JSON.stringify(cadence));
            setOutputParam(params, 'RootTask', JSON.stringify(maskedRootTask));
            setOutputParam(params, 'History', JSON.stringify(maskedHistory));
            setOutputParam(params, 'ProjectRisk', JSON.stringify(fullPayload));
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }
}

/**
 * Action: `Request Project Risk Review` (`DriverClass: 'RequestProjectRiskReviewAction'`).
 *
 * Verifies caller permissions via `params.ContextUser`, then dispatches an on-demand
 * `ProjectRiskAnalystService` evaluation running as the project owner user, enforcing
 * the free/busy privacy boundary and persisting a `Task Risk Assessments` record that
 * automatically synchronizes `HealthStatus`, `ConfidenceScore`, and `ForecastCompletionDate`
 * onto the root project `Task`.
 */
@RegisterClass(BaseAction, 'RequestProjectRiskReviewAction')
export class RequestProjectRiskReviewAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const taskID = getStringParam(params, 'TaskID');
        if (!taskID || !IsValidUUID(taskID)) {
            return failResult('VALIDATION_ERROR', 'A valid TaskID UUID is required.', params);
        }

        const mlBreachProbability = getNumberParam(params, 'MLBreachProbability');
        // ProtocolLimit: Probability must be within [0, 1]
        if (mlBreachProbability !== null && (mlBreachProbability < 0 || mlBreachProbability > 1)) {
            return failResult(
                'VALIDATION_ERROR',
                'MLBreachProbability must be a finite number between 0 and 1.',
                params,
            );
        }

        const rawRiskBand = getStringParam(params, 'MLBreachRiskBand');
        const mlBreachRiskBand = normalizeSlaRiskBand(rawRiskBand);
        if (rawRiskBand && !mlBreachRiskBand) {
            return failResult(
                'VALIDATION_ERROR',
                `Invalid MLBreachRiskBand '${rawRiskBand}'. Expected Low, Medium, High, or Critical.`,
                params,
            );
        }

        const freeBusyParse = parseFreeBusyOverrides(params);
        if (!freeBusyParse.Ok) {
            return failResult('VALIDATION_ERROR', freeBusyParse.Message ?? 'Invalid FreeBusyJSON parameter.', params);
        }

        const tasksReadGuard = await checkTypedPolicyGuard({
            params,
            entityName: TASKS_ENTITY,
            operation: 'Read',
            actionName: 'Request Project Risk Review',
        });
        if (!tasksReadGuard.Allowed) return tasksReadGuard.Failure!;

        const assessmentCreateGuard = await checkTypedPolicyGuard({
            params,
            entityName: TASK_RISK_ASSESSMENT_ENTITY,
            operation: 'Create',
            writeFields: [
                'TaskID',
                'AssessedAt',
                'ForecastCompletionDate',
                'ForecastConfidence',
                'HealthStatus',
                'MLBreachProbability',
                'Risks',
                'AgentRunID',
                'PromptTokens',
                'CompletionTokens',
                'TotalCostUSD',
            ],
            actionName: 'Request Project Risk Review',
        });
        if (!assessmentCreateGuard.Allowed) return assessmentCreateGuard.Failure!;

        const assessmentReadGuard = await checkTypedPolicyGuard({
            params,
            entityName: TASK_RISK_ASSESSMENT_ENTITY,
            operation: 'Read',
            actionName: 'Request Project Risk Review',
        });
        if (!assessmentReadGuard.Allowed) return assessmentReadGuard.Failure!;

        try {
            const resolution = await resolveAuthorizedProjectRootTask(params, taskID, user);
            if (resolution.Status === 'FAILURE') {
                return resolution.Failure;
            }

            const rootTask = resolution.RootTask;
            const force = getBooleanParam(params, 'Force', true);
            const mlBreachOverride: MLBreachSignal | null =
                mlBreachProbability !== null
                    ? {
                          Probability: mlBreachProbability,
                          RiskBand: mlBreachRiskBand ?? rootTask.PredictedSLARiskBand ?? null,
                          ScoredAtISO: new Date().toISOString(),
                          Source: 'ScoringProvider',
                      }
                    : null;

            const result = await ProjectRiskAnalystRegistry.Instance.RunReview({
                TaskID: rootTask.ID,
                CallerContextUser: user,
                Force: force,
                MLBreachSignalOverride: mlBreachOverride,
                FreeBusyOverrides: freeBusyParse.Value ?? null,
            });

            if (result.Skipped) {
                const maskedRootTask = applyPolicyFieldMask(
                    toRootTaskRollup(rootTask),
                    tasksReadGuard.DeniedFieldPatterns,
                );
                const skippedPayload = {
                    Skipped: true,
                    SkipReason: result.SkipReason,
                    TaskID: result.TaskID,
                    OwnerUserID: result.OwnerUserID,
                    AssessmentID: null,
                    Cadence: result.Cadence.Cadence,
                    CadenceDetail: result.Cadence,
                    RootTask: maskedRootTask,
                };
                const skipMsg =
                    result.SkipReason ??
                    `Risk review skipped for project "${maskedRootTask.Name ?? rootTask.ID}" within ${result.Cadence.Cadence} cooldown window.`;
                setOutputParam(params, 'Skipped', true);
                setOutputParam(params, 'SkipReason', result.SkipReason);
                setOutputParam(params, 'TaskID', result.TaskID);
                setOutputParam(params, 'OwnerUserID', result.OwnerUserID);
                setOutputParam(params, 'AssessmentID', null);
                setOutputParam(params, 'Cadence', result.Cadence.Cadence);
                setOutputParam(params, 'CadenceDetail', JSON.stringify(result.Cadence));
                setOutputParam(params, 'RootTask', JSON.stringify(maskedRootTask));
                setOutputParam(params, 'Assessment', JSON.stringify(skippedPayload));
                setOutputParam(params, 'Summary', skipMsg);
                return successResult(skipMsg, params, 'SKIPPED_COOLDOWN');
            }

            // Reload root task under caller context so output reflects persisted entity-server rollup.
            const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
            const rv = new RunView();
            const reloadedRes = await rv.RunView<AuthorizedTaskRow>(
                {
                    EntityName: TASKS_ENTITY,
                    ExtraFilter: `ID = '${EscapeSQLString(result.TaskID)}'`,
                    Fields: PROJECT_TASK_FIELDS,
                    MaxRows: limits.ResourceGuards.DefaultLookupSingleRow,
                    ResultType: 'simple',
                },
                user,
            );
            const updatedRootRow = (reloadedRes.Success ? reloadedRes.Results?.[0] : undefined) ?? rootTask;
            const rootRollup = applyPolicyFieldMask(
                toRootTaskRollup(updatedRootRow),
                tasksReadGuard.DeniedFieldPatterns,
            );
            const assessedAtISO = toIsoOrNull(result.AssessedAt);
            const forecastCompletionDateISO = toIsoOrNull(result.ForecastCompletionDate);

            const assessmentDeniedPatterns = [
                ...new Set([
                    ...assessmentCreateGuard.DeniedFieldPatterns,
                    ...assessmentReadGuard.DeniedFieldPatterns,
                ]),
            ];
            const rawAssessmentSummary: ProjectRiskAssessmentSummary = {
                AssessmentID: result.AssessmentID ?? '',
                TaskID: result.TaskID,
                AssessedAtISO: assessedAtISO ?? '',
                HealthStatus: result.HealthStatus ?? 'OnTrack',
                ForecastCompletionDateISO: forecastCompletionDateISO,
                ForecastConfidence: result.ForecastConfidence,
                MLBreachProbability: result.MLBreachProbability,
                Risks: result.Risks,
                AgentRunID: result.AgentRunID,
                PromptTokens: result.PromptTokens,
                CompletionTokens: result.CompletionTokens,
                TotalCostUSD: result.TotalCostUSD,
            };
            const maskedAssessment = applyPolicyFieldMask(rawAssessmentSummary, assessmentDeniedPatterns);
            const maskedAssessmentId = result.AssessmentID ? (maskedAssessment.AssessmentID ?? null) : null;
            const maskedAssessedAt = assessedAtISO ? (maskedAssessment.AssessedAtISO ?? null) : null;
            const maskedHealthStatus = result.HealthStatus ? (maskedAssessment.HealthStatus ?? null) : null;
            const maskedForecastCompletionDate = maskedAssessment.ForecastCompletionDateISO ?? null;
            const maskedForecastConfidence = maskedAssessment.ForecastConfidence ?? null;
            const maskedMLBreachProbability = maskedAssessment.MLBreachProbability ?? null;
            const maskedRisks = maskedAssessment.Risks ?? [];
            const maskedAgentRunId = maskedAssessment.AgentRunID ?? null;
            const maskedPromptTokens = maskedAssessment.PromptTokens ?? null;
            const maskedCompletionTokens = maskedAssessment.CompletionTokens ?? null;
            const maskedTotalCostUSD = maskedAssessment.TotalCostUSD ?? null;

            const responsePayload = {
                Skipped: false,
                SkipReason: null,
                AssessmentID: maskedAssessmentId,
                TaskID: result.TaskID,
                OwnerUserID: result.OwnerUserID,
                AssessedAt: maskedAssessedAt,
                HealthStatus: maskedHealthStatus,
                ForecastCompletionDate: maskedForecastCompletionDate,
                ForecastConfidence: maskedForecastConfidence,
                MLBreachProbability: maskedMLBreachProbability,
                Risks: maskedRisks,
                Summary: result.Summary,
                AgentRunID: maskedAgentRunId,
                PromptTokens: maskedPromptTokens,
                CompletionTokens: maskedCompletionTokens,
                TotalCostUSD: maskedTotalCostUSD,
                Cadence: result.Cadence.Cadence,
                CadenceDetail: result.Cadence,
                RootTask: rootRollup,
            };

            const summary =
                `Completed risk review for project "${rootRollup.Name ?? updatedRootRow.ID}": ${maskedHealthStatus ?? 'Unknown'} ` +
                `(confidence: ${maskedForecastConfidence ?? 'n/a'}%, cadence: ${result.Cadence.Cadence}, risks: ${maskedRisks.length}).`;

            setOutputParam(params, 'Skipped', false);
            setOutputParam(params, 'SkipReason', null);
            setOutputParam(params, 'AssessmentID', maskedAssessmentId);
            setOutputParam(params, 'TaskID', result.TaskID);
            setOutputParam(params, 'OwnerUserID', result.OwnerUserID);
            setOutputParam(params, 'AssessedAt', maskedAssessedAt);
            setOutputParam(params, 'HealthStatus', maskedHealthStatus);
            setOutputParam(params, 'ForecastCompletionDate', maskedForecastCompletionDate);
            setOutputParam(params, 'ForecastConfidence', maskedForecastConfidence);
            setOutputParam(params, 'MLBreachProbabilityOutput', maskedMLBreachProbability);
            setOutputParam(params, 'MLBreachProbability', maskedMLBreachProbability);
            setOutputParam(params, 'Risks', JSON.stringify(maskedRisks));
            setOutputParam(params, 'AgentRunID', maskedAgentRunId);
            setOutputParam(params, 'PromptTokens', maskedPromptTokens);
            setOutputParam(params, 'CompletionTokens', maskedCompletionTokens);
            setOutputParam(params, 'TotalCostUSD', maskedTotalCostUSD);
            setOutputParam(params, 'Cadence', result.Cadence.Cadence);
            setOutputParam(params, 'CadenceDetail', JSON.stringify(result.Cadence));
            setOutputParam(params, 'RootTask', JSON.stringify(rootRollup));
            setOutputParam(params, 'Assessment', JSON.stringify(responsePayload));
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }
}
