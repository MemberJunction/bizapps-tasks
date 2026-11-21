import { Metadata, RunView, type UserInfo } from '@memberjunction/core';
import type { ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import { TypedActionPolicyGuard } from '@memberjunction/ai-core-plus';
import { EscapeSQLString, IsValidUUID, NormalizeUUID, RegisterClass, UUIDsEqual } from '@memberjunction/global';
import {
    PEOPLE_ENTITY_NAME,
    rankSimilarTasks,
    WorkReportService,
    type TaskSimilarityCandidate,
} from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksTaskActivityEntity,
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTaskCheckInEntity,
    mjBizAppsTasksTaskCommentEntity,
    mjBizAppsTasksTaskDependencyEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskLinkEntity,
    mjBizAppsTasksTaskRoleEntity,
    mjBizAppsTasksTaskTypeEntity,
    mjBizAppsTasksWorkReportEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    AI_AGENTS_ENTITY,
    buildTaskDeepLink,
    buildWorkReportDeepLink,
    checkTypedPolicyGuard,
    CLIENT_REQUEST_KEY_PREFIX,
    failResult,
    findEntityIDByName,
    getBooleanParam,
    getDateParam,
    getNumberParam,
    getStringListParam,
    getStringParam,
    normalizeHealthStatus,
    normalizeTaskPriority,
    normalizeTaskStatus,
    PLANNING_TASK_TYPE_CODES,
    PLANNING_TASK_TYPE_NAMES,
    resolveCallerPerson,
    resolveOrganizationByIdentifier,
    resolvePersonByIdentifier,
    resolveUserIDForPersonRecord,
    ROLES_ENTITY,
    setOutputParam,
    successResult,
    TASK_ACTIVITIES_ENTITY,
    TASK_ASSIGNMENTS_ENTITY,
    TASK_CHECK_INS_ENTITY,
    TASK_COMMENTS_ENTITY,
    TASK_DEPENDENCIES_ENTITY,
    TASK_LINKS_ENTITY,
    TASK_ROLES_ENTITY,
    TASK_TYPES_ENTITY,
    TASKS_ENTITY,
    toIsoOrNull,
    upsertTaskOrganizationLink,
    wakeChiefOfStaffBestEffort,
    WORK_REPORTS_ENTITY,
    type TaskStatusValue,
} from './action-helpers.js';

interface TaskSummaryRow {
    ID: string;
    Name: string;
    Description?: string | null;
    Status: mjBizAppsTasksTaskEntity['Status'];
    Priority: mjBizAppsTasksTaskEntity['Priority'];
    DueAt: string | Date | null;
    StartedAt?: string | Date | null;
    CompletedAt?: string | Date | null;
    PercentComplete: number;
    TypeID: string;
    Type: string;
    CategoryID: string | null;
    Category: string | null;
    OrganizationID?: string | null;
    Organization?: string | null;
    ParentID: string | null;
    BlockedReason: string | null;
    HealthStatus: mjBizAppsTasksTaskEntity['HealthStatus'];
    CreatedByPersonID?: string | null;
    CreatedByPerson?: string | null;
    __mj_UpdatedAt?: string | Date | null;
}

interface CompactTaskSummary {
    ID: string;
    Name: string;
    Status: mjBizAppsTasksTaskEntity['Status'];
    Priority: mjBizAppsTasksTaskEntity['Priority'];
    DueAt: string | null;
    PercentComplete: number;
    Type: string;
    Category: string | null;
    OrganizationID: string | null;
    Organization: string | null;
    ParentID: string | null;
    BlockedReason: string | null;
    HealthStatus: mjBizAppsTasksTaskEntity['HealthStatus'];
    DeepLink: string;
    [key: string]: string | number | boolean | null | undefined;
}

interface TaskTypeLookupRow {
    ID: string;
    Name: string;
    Code: string;
    IsApproval?: boolean;
}

interface RawTaskAssignmentRow {
    ID: string;
    TaskID: string;
    AssigneeEntityID: string;
    AssigneeEntity?: string | null;
    AssigneeRecordID: string;
    RoleID: string | null;
    Role?: string | null;
    RoleNotes?: string | null;
    Status: mjBizAppsTasksTaskAssignmentEntity['Status'];
    AssignedAt?: string | Date | null;
}

interface RawDependencyRow {
    ID: string;
    TaskID: string;
    Task?: string | null;
    DependsOnTaskID: string;
    DependsOnTask?: string | null;
    DependencyType: mjBizAppsTasksTaskDependencyEntity['DependencyType'];
}

interface RawNamedEntityRow {
    ID: string;
    Name: string;
}

function toCompactSummary(row: TaskSummaryRow): CompactTaskSummary {
    return {
        ID: row.ID,
        Name: row.Name,
        Status: row.Status,
        Priority: row.Priority,
        DueAt: toIsoOrNull(row.DueAt),
        PercentComplete: row.PercentComplete ?? 0,
        Type: row.Type,
        Category: row.Category ?? null,
        OrganizationID: row.OrganizationID ?? null,
        Organization: row.Organization ?? null,
        ParentID: row.ParentID ?? null,
        BlockedReason: row.BlockedReason ?? null,
        HealthStatus: row.HealthStatus ?? null,
        DeepLink: buildTaskDeepLink(row.ID),
    };
}

function isPlanningTaskType(typeRow: { Code?: string | null; Name?: string | null }): boolean {
    const code = (typeRow.Code ?? '').trim().toUpperCase();
    const name = (typeRow.Name ?? '').trim().toLowerCase();
    return PLANNING_TASK_TYPE_CODES.has(code) || PLANNING_TASK_TYPE_NAMES.has(name);
}

async function loadAllTaskTypes(contextUser: UserInfo): Promise<TaskTypeLookupRow[]> {
    const rv = new RunView();
    const res = await rv.RunView<TaskTypeLookupRow>(
        {
            EntityName: TASK_TYPES_ENTITY,
            Fields: ['ID', 'Name', 'Code', 'IsApproval'],
            ResultType: 'simple',
            MaxRows: 200,
        },
        contextUser,
    );
    return res.Success ? (res.Results ?? []) : [];
}

async function getPersonAssignedTaskIDs(personID: string, contextUser: UserInfo): Promise<string[]> {
    const rv = new RunView();
    const peopleEntityID = findEntityIDByName(PEOPLE_ENTITY_NAME);
    const filter = peopleEntityID
        ? `AssigneeEntityID = '${EscapeSQLString(peopleEntityID)}' AND AssigneeRecordID = '${EscapeSQLString(personID)}'`
        : `AssigneeRecordID = '${EscapeSQLString(personID)}'`;

    const res = await rv.RunView<{ TaskID: string }>(
        {
            EntityName: TASK_ASSIGNMENTS_ENTITY,
            ExtraFilter: filter,
            Fields: ['TaskID'],
            ResultType: 'simple',
            MaxRows: 1000,
        },
        contextUser,
    );
    if (!res.Success) return [];
    return Array.from(new Set((res.Results ?? []).map((r) => r.TaskID).filter((id) => IsValidUUID(id))));
}

async function trySemanticTaskSearch(
    searchText: string,
    topK: number,
    contextUser: UserInfo,
): Promise<Map<string, number>> {
    const scores = new Map<string, number>();
    const md = new Metadata();
    if (typeof md.SearchEntity !== 'function') {
        return scores;
    }
    try {
        const results = await md.SearchEntity({
            entityName: TASKS_ENTITY,
            searchText,
            options: {
                mode: 'hybrid',
                topK,
                contextUser,
            },
        });
        for (const item of results ?? []) {
            if (item.recordId) {
                scores.set(item.recordId.toLowerCase(), item.score);
            }
        }
    } catch {
        // Semantic search vector index may not be provisioned yet — fall back to lexical search safely.
    }
    return scores;
}

// =============================================================================
// 1. Find Tasks
// =============================================================================

@RegisterClass(BaseAction, 'FindTasksAction')
export class FindTasksAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const guard = await checkTypedPolicyGuard({
            params,
            entityName: TASKS_ENTITY,
            operation: 'Read',
        });
        if (!guard.Allowed) return guard.Failure;

        try {
            const scopeRaw = getStringParam(params, 'Scope')?.toLowerCase() ?? null;
            const mineOnly = getBooleanParam(
                params,
                'MineOnly',
                scopeRaw === 'team' ? false : true,
            );
            const scope = scopeRaw ?? (mineOnly ? 'mine' : 'team');
            const categoryID = getStringParam(params, 'CategoryID');
            const organizationID = getStringParam(params, 'OrganizationID');
            const organizationName = getStringParam(params, 'OrganizationName');
            const parentTaskID = getStringParam(params, 'ParentTaskID', 'ParentID');
            const taskTypeParam = getStringParam(params, 'TaskType', 'TypeCode');
            const priorityRaw = getStringParam(params, 'Priority');
            const statusParams = getStringListParam(params, 'Status');
            const searchText = getStringParam(params, 'SearchText', 'Query');
            const dueBefore = getDateParam(params, 'DueBefore');
            const dueAfter = getDateParam(params, 'DueAfter');
            const maxRowsRaw = getNumberParam(params, 'MaxRows', 'Limit') ?? 25;
            const maxRows = Math.max(1, Math.min(100, Math.round(maxRowsRaw)));

            if (categoryID && !IsValidUUID(categoryID)) {
                return failResult('VALIDATION_ERROR', 'CategoryID must be a valid UUID.', params);
            }
            if (organizationID && !IsValidUUID(organizationID)) {
                return failResult('VALIDATION_ERROR', 'OrganizationID must be a valid UUID.', params);
            }
            if (parentTaskID && !IsValidUUID(parentTaskID)) {
                return failResult('VALIDATION_ERROR', 'ParentTaskID must be a valid UUID.', params);
            }
            if (dueBefore === 'INVALID' || dueAfter === 'INVALID') {
                return failResult('VALIDATION_ERROR', 'DueBefore and DueAfter must be valid ISO-8601 dates.', params);
            }

            const priority = priorityRaw ? normalizeTaskPriority(priorityRaw) : null;
            if (priorityRaw && !priority) {
                return failResult(
                    'VALIDATION_ERROR',
                    `Invalid Priority '${priorityRaw}'. Expected Low, Medium, High, or Critical.`,
                    params,
                );
            }

            const statuses: TaskStatusValue[] = [];
            for (const s of statusParams) {
                const normalized = normalizeTaskStatus(s);
                if (!normalized) {
                    return failResult(
                        'VALIDATION_ERROR',
                        `Invalid Status '${s}'. Expected Open, InProgress, Blocked, Completed, or Cancelled.`,
                        params,
                    );
                }
                statuses.push(normalized);
            }

            const explicitClosedStatus = statuses.some((s) => s === 'Completed' || s === 'Cancelled');
            const includeCompleted = getBooleanParam(params, 'IncludeCompleted', explicitClosedStatus);
            const excludePlanningDefault = !taskTypeParam;
            const excludePlanningTypes = getBooleanParam(
                params,
                'ExcludePlanningTypes',
                excludePlanningDefault,
            );

            const filters: string[] = [];

            // Scope resolution (caller -> Person)
            if (scope !== 'team') {
                const callerPerson = await resolveCallerPerson(user);
                if (!callerPerson) {
                    return failResult(
                        'NO_PERSON_RECORD',
                        'No active MJ_BizApps_Common: People record is linked to your user account.',
                        params,
                    );
                }
                const assignedIds = await getPersonAssignedTaskIDs(callerPerson.ID, user);
                if (scope === 'assignedtome') {
                    if (assignedIds.length === 0) {
                        return this.returnEmpty(params, 'No tasks assigned to you match the requested filters.');
                    }
                    filters.push(`ID IN (${assignedIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ')})`);
                } else if (scope === 'createdbyme') {
                    filters.push(`CreatedByPersonID = '${EscapeSQLString(callerPerson.ID)}'`);
                } else if (scope === 'delegatedbyme') {
                    if (assignedIds.length > 0) {
                        const notMine = assignedIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
                        filters.push(
                            `CreatedByPersonID = '${EscapeSQLString(callerPerson.ID)}' AND ID NOT IN (${notMine})`,
                        );
                    } else {
                        filters.push(`CreatedByPersonID = '${EscapeSQLString(callerPerson.ID)}'`);
                    }
                } else {
                    // Default 'mine': assigned to me OR created by me
                    if (assignedIds.length > 0) {
                        const inList = assignedIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
                        filters.push(
                            `(CreatedByPersonID = '${EscapeSQLString(callerPerson.ID)}' OR ID IN (${inList}))`,
                        );
                    } else {
                        filters.push(`CreatedByPersonID = '${EscapeSQLString(callerPerson.ID)}'`);
                    }
                }
            }

            // TaskType filtering + planning-type exclusion
            const allTypes = await loadAllTaskTypes(user);
            if (taskTypeParam) {
                const needle = taskTypeParam.trim().toLowerCase();
                const matchedType = allTypes.find(
                    (t) =>
                        t.Code.toLowerCase() === needle ||
                        t.Name.toLowerCase() === needle ||
                        (IsValidUUID(taskTypeParam) && UUIDsEqual(t.ID, taskTypeParam)),
                );
                if (!matchedType) {
                    return failResult(
                        'NOT_FOUND',
                        `TaskType '${taskTypeParam}' was not found.`,
                        params,
                    );
                }
                filters.push(`TypeID = '${EscapeSQLString(matchedType.ID)}'`);
            } else if (excludePlanningTypes) {
                const planningTypeIds = allTypes.filter(isPlanningTaskType).map((t) => t.ID);
                if (planningTypeIds.length > 0) {
                    const notIn = planningTypeIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
                    filters.push(`(TypeID IS NULL OR TypeID NOT IN (${notIn}))`);
                }
            }

            if (statuses.length > 0) {
                filters.push(`Status IN (${statuses.map((s) => `'${EscapeSQLString(s)}'`).join(', ')})`);
            } else if (!includeCompleted) {
                filters.push(`Status NOT IN ('Completed', 'Cancelled')`);
            }

            if (priority) {
                filters.push(`Priority = '${EscapeSQLString(priority)}'`);
            }
            if (categoryID) {
                filters.push(`CategoryID = '${EscapeSQLString(categoryID)}'`);
            }
            if (parentTaskID) {
                filters.push(`ParentID = '${EscapeSQLString(parentTaskID)}'`);
            }
            if (dueBefore) {
                filters.push(`DueAt <= '${EscapeSQLString(dueBefore.toISOString())}'`);
            }
            if (dueAfter) {
                filters.push(`DueAt >= '${EscapeSQLString(dueAfter.toISOString())}'`);
            }

            if (organizationID || organizationName) {
                const orgLookup = await resolveOrganizationByIdentifier(
                    { organizationID, organizationName },
                    user,
                );
                if (orgLookup.Status === 'INVALID') {
                    return failResult('VALIDATION_ERROR', orgLookup.Message, params);
                }
                if (orgLookup.Status === 'NOT_FOUND') {
                    return failResult('NOT_FOUND', orgLookup.Message, params);
                }
                if (orgLookup.Status === 'AMBIGUOUS') {
                    setOutputParam(params, 'Candidates', JSON.stringify(orgLookup.Candidates));
                    return failResult('AMBIGUOUS', orgLookup.Message, params);
                }
                if (orgLookup.Status === 'FOUND') {
                    filters.push(`OrganizationID = '${EscapeSQLString(orgLookup.Organization.ID)}'`);
                }
            }

            // Optional semantic + lexical search
            let semanticScores: Map<string, number> | null = null;
            if (searchText) {
                semanticScores = await trySemanticTaskSearch(searchText, Math.max(maxRows * 2, 40), user);
                const escaped = EscapeSQLString(searchText);
                const semanticIds = Array.from(semanticScores.keys()).filter((id) => IsValidUUID(id));
                if (semanticIds.length > 0) {
                    const inSemantic = semanticIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
                    filters.push(
                        `(ID IN (${inSemantic}) OR Name LIKE '%${escaped}%' OR Description LIKE '%${escaped}%')`,
                    );
                } else {
                    filters.push(`(Name LIKE '%${escaped}%' OR Description LIKE '%${escaped}%')`);
                }
            }

            const rv = new RunView();
            const res = await rv.RunView<TaskSummaryRow>(
                {
                    EntityName: TASKS_ENTITY,
                    ExtraFilter: filters.join(' AND '),
                    Fields: [
                        'ID',
                        'Name',
                        'Description',
                        'Status',
                        'Priority',
                        'DueAt',
                        'PercentComplete',
                        'TypeID',
                        'Type',
                        'CategoryID',
                        'Category',
                        'OrganizationID',
                        'Organization',
                        'ParentID',
                        'BlockedReason',
                        'HealthStatus',
                        '__mj_UpdatedAt',
                    ],
                    OrderBy: 'DueAt ASC, __mj_UpdatedAt DESC',
                    MaxRows: searchText ? Math.min(200, maxRows * 3) : maxRows,
                    ResultType: 'simple',
                },
                user,
            );

            if (!res.Success) {
                return failResult('ERROR', res.ErrorMessage ?? 'Failed to query tasks.', params);
            }

            let rows = res.Results ?? [];
            if (excludePlanningTypes && !taskTypeParam) {
                // Defensive in-memory filter in case TaskType metadata wasn't returned in mock environments
                rows = rows.filter((r) => !PLANNING_TASK_TYPE_NAMES.has((r.Type ?? '').trim().toLowerCase()));
            }

            if (searchText && semanticScores && semanticScores.size > 0) {
                rows = [...rows].sort((a, b) => {
                    const scoreA = semanticScores?.get(a.ID.toLowerCase()) ?? 0;
                    const scoreB = semanticScores?.get(b.ID.toLowerCase()) ?? 0;
                    return scoreB - scoreA;
                });
            }

            const sliced = rows.slice(0, maxRows).map(toCompactSummary);
            const masked = TypedActionPolicyGuard.MaskRows(sliced, guard.DeniedFieldPatterns);

            const summary = `Found ${masked.length} task(s).`;
            setOutputParam(params, 'Tasks', JSON.stringify(masked));
            setOutputParam(params, 'TotalCount', masked.length);
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }

    private returnEmpty(params: RunActionParams, summary: string): ActionResultSimple {
        setOutputParam(params, 'Tasks', '[]');
        setOutputParam(params, 'TotalCount', 0);
        setOutputParam(params, 'Summary', summary);
        return successResult(summary, params);
    }
}

// =============================================================================
// 2. Get Task
// =============================================================================

@RegisterClass(BaseAction, 'GetTaskAction')
export class GetTaskAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const taskID = getStringParam(params, 'TaskID');
        if (!taskID || !IsValidUUID(taskID)) {
            return failResult('VALIDATION_ERROR', 'A valid TaskID UUID is required.', params);
        }

        const guard = await checkTypedPolicyGuard({
            params,
            entityName: TASKS_ENTITY,
            operation: 'Read',
        });
        if (!guard.Allowed) return guard.Failure;

        try {
            const rv = new RunView();
            const escapedId = EscapeSQLString(taskID);
            const [
                taskRes,
                assignRes,
                blockedByRes,
                blocksRes,
                commentsRes,
                checkInsRes,
                linksRes,
                subTasksRes,
            ] = await Promise.all([
                rv.RunView<TaskSummaryRow>(
                    {
                        EntityName: TASKS_ENTITY,
                        ExtraFilter: `ID = '${escapedId}'`,
                        MaxRows: 1,
                        ResultType: 'simple',
                    },
                    user,
                ),
                rv.RunView<RawTaskAssignmentRow>(
                    {
                        EntityName: TASK_ASSIGNMENTS_ENTITY,
                        ExtraFilter: `TaskID = '${escapedId}'`,
                        Fields: ['ID', 'TaskID', 'AssigneeEntityID', 'AssigneeEntity', 'AssigneeRecordID', 'RoleID', 'Role', 'RoleNotes', 'Status', 'AssignedAt'],
                        MaxRows: 50,
                        ResultType: 'simple',
                    },
                    user,
                ),
                rv.RunView<RawDependencyRow>(
                    {
                        EntityName: TASK_DEPENDENCIES_ENTITY,
                        ExtraFilter: `TaskID = '${escapedId}'`,
                        Fields: ['ID', 'TaskID', 'DependsOnTaskID', 'DependsOnTask', 'DependencyType'],
                        MaxRows: 50,
                        ResultType: 'simple',
                    },
                    user,
                ),
                rv.RunView<RawDependencyRow>(
                    {
                        EntityName: TASK_DEPENDENCIES_ENTITY,
                        ExtraFilter: `DependsOnTaskID = '${escapedId}'`,
                        Fields: ['ID', 'TaskID', 'Task', 'DependsOnTaskID', 'DependencyType'],
                        MaxRows: 50,
                        ResultType: 'simple',
                    },
                    user,
                ),
                rv.RunView<Pick<mjBizAppsTasksTaskCommentEntity, 'ID' | 'PersonID' | 'Person' | 'Content' | '__mj_CreatedAt'>>(
                    {
                        EntityName: TASK_COMMENTS_ENTITY,
                        ExtraFilter: `TaskID = '${escapedId}'`,
                        Fields: ['ID', 'PersonID', 'Person', 'Content', '__mj_CreatedAt'],
                        OrderBy: '__mj_CreatedAt DESC',
                        MaxRows: 5,
                        ResultType: 'simple',
                    },
                    user,
                ),
                rv.RunView<Pick<mjBizAppsTasksTaskCheckInEntity, 'ID' | 'AuthorPerson' | 'HealthStatus' | 'ConfidenceScore' | 'PercentComplete' | 'Summary' | 'Blockers' | 'NextSteps' | 'CheckInAt'>>(
                    {
                        EntityName: TASK_CHECK_INS_ENTITY,
                        ExtraFilter: `TaskID = '${escapedId}'`,
                        Fields: ['ID', 'AuthorPerson', 'HealthStatus', 'ConfidenceScore', 'PercentComplete', 'Summary', 'Blockers', 'NextSteps', 'CheckInAt'],
                        OrderBy: 'CheckInAt DESC',
                        MaxRows: 5,
                        ResultType: 'simple',
                    },
                    user,
                ),
                rv.RunView<Pick<mjBizAppsTasksTaskLinkEntity, 'ID' | 'EntityID' | 'Entity' | 'RecordID' | 'Description'>>(
                    {
                        EntityName: TASK_LINKS_ENTITY,
                        ExtraFilter: `TaskID = '${escapedId}'`,
                        Fields: ['ID', 'EntityID', 'Entity', 'RecordID', 'Description'],
                        MaxRows: 10,
                        ResultType: 'simple',
                    },
                    user,
                ),
                rv.RunView<TaskSummaryRow>(
                    {
                        EntityName: TASKS_ENTITY,
                        ExtraFilter: `ParentID = '${escapedId}'`,
                        Fields: ['ID', 'Name', 'Status', 'Priority', 'DueAt', 'PercentComplete', 'Type', 'Category', 'OrganizationID', 'Organization', 'ParentID', 'BlockedReason', 'HealthStatus'],
                        OrderBy: 'Sequence ASC, DueAt ASC',
                        MaxRows: 25,
                        ResultType: 'simple',
                    },
                    user,
                ),
            ]);

            const task = taskRes.Success ? taskRes.Results?.[0] : undefined;
            if (!task) {
                return failResult('NOT_FOUND', `Task '${taskID}' was not found or is not accessible.`, params);
            }

            const baseDetail: Record<string, string | number | boolean | null | undefined> = {
                ID: task.ID,
                Name: task.Name,
                Description: task.Description ?? null,
                Status: task.Status,
                Priority: task.Priority,
                DueAt: toIsoOrNull(task.DueAt),
                StartedAt: toIsoOrNull(task.StartedAt),
                CompletedAt: toIsoOrNull(task.CompletedAt),
                PercentComplete: task.PercentComplete ?? 0,
                Type: task.Type,
                Category: task.Category ?? null,
                OrganizationID: task.OrganizationID ?? null,
                Organization: task.Organization ?? null,
                ParentID: task.ParentID ?? null,
                BlockedReason: task.BlockedReason ?? null,
                HealthStatus: task.HealthStatus ?? null,
                CreatedByPersonID: task.CreatedByPersonID ?? null,
                CreatedByPerson: task.CreatedByPerson ?? null,
                DeepLink: buildTaskDeepLink(task.ID),
            };
            const maskedTask = TypedActionPolicyGuard.MaskRecord(baseDetail, guard.DeniedFieldPatterns);

            const subTasks = TypedActionPolicyGuard.MaskRows(
                (subTasksRes.Success ? (subTasksRes.Results ?? []) : []).map(toCompactSummary),
                guard.DeniedFieldPatterns,
            );

            const payload = {
                ...maskedTask,
                Assignments: (assignRes.Success ? (assignRes.Results ?? []) : []).map((a) => ({
                    ID: a.ID,
                    AssigneeEntity: a.AssigneeEntity ?? a.AssigneeEntityID,
                    AssigneeRecordID: a.AssigneeRecordID,
                    Role: a.Role ?? null,
                    RoleNotes: a.RoleNotes ?? null,
                    Status: a.Status,
                    AssignedAt: toIsoOrNull(a.AssignedAt),
                })),
                Dependencies: {
                    BlockedBy: (blockedByRes.Success ? (blockedByRes.Results ?? []) : []).map((d) => ({
                        ID: d.ID,
                        DependsOnTaskID: d.DependsOnTaskID,
                        DependsOnTask: d.DependsOnTask ?? null,
                        DependencyType: d.DependencyType,
                    })),
                    Blocks: (blocksRes.Success ? (blocksRes.Results ?? []) : []).map((d) => ({
                        ID: d.ID,
                        TaskID: d.TaskID,
                        Task: d.Task ?? null,
                        DependencyType: d.DependencyType,
                    })),
                },
                RecentComments: (commentsRes.Success ? (commentsRes.Results ?? []) : []).map((c) => ({
                    ID: c.ID,
                    Person: c.Person,
                    Content: c.Content,
                    CreatedAt: toIsoOrNull(c.__mj_CreatedAt),
                })),
                RecentCheckIns: (checkInsRes.Success ? (checkInsRes.Results ?? []) : []).map((ci) => ({
                    ID: ci.ID,
                    AuthorPerson: ci.AuthorPerson ?? null,
                    HealthStatus: ci.HealthStatus,
                    ConfidenceScore: ci.ConfidenceScore ?? null,
                    PercentComplete: ci.PercentComplete ?? null,
                    Summary: ci.Summary,
                    Blockers: ci.Blockers ?? null,
                    NextSteps: ci.NextSteps ?? null,
                    CheckInAt: toIsoOrNull(ci.CheckInAt),
                })),
                Links: (linksRes.Success ? (linksRes.Results ?? []) : []).map((l) => ({
                    ID: l.ID,
                    Entity: l.Entity,
                    RecordID: l.RecordID,
                    Description: l.Description ?? null,
                })),
                SubTasks: subTasks,
            };

            const summary = `Loaded task "${task.Name}" (${task.Status}, ${task.Priority}, ${task.PercentComplete ?? 0}%).`;
            setOutputParam(params, 'Task', JSON.stringify(payload));
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }
}

// =============================================================================
// 3. Create Task
// =============================================================================

@RegisterClass(BaseAction, 'CreateTaskAction')
export class CreateTaskAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const name = getStringParam(params, 'Name');
        if (!name) {
            return failResult('VALIDATION_ERROR', 'Name is required to create a task.', params);
        }

        const description = getStringParam(params, 'Description');
        const priorityRaw = getStringParam(params, 'Priority');
        const priority = priorityRaw ? normalizeTaskPriority(priorityRaw) : 'Medium';
        if (!priority) {
            return failResult(
                'VALIDATION_ERROR',
                `Invalid Priority '${priorityRaw}'. Expected Low, Medium, High, or Critical.`,
                params,
            );
        }

        const dueAt = getDateParam(params, 'DueAt');
        const startedAt = getDateParam(params, 'StartedAt');
        if (dueAt === 'INVALID' || startedAt === 'INVALID') {
            return failResult('VALIDATION_ERROR', 'DueAt and StartedAt must be valid ISO-8601 dates.', params);
        }

        const categoryID = getStringParam(params, 'CategoryID');
        const organizationID = getStringParam(params, 'OrganizationID');
        const organizationName = getStringParam(params, 'OrganizationName');
        const parentTaskID = getStringParam(params, 'ParentTaskID', 'ParentID');
        const taskTypeName = getStringParam(params, 'TaskTypeName', 'TypeCode', 'TaskType');
        const assigneePersonID = getStringParam(params, 'AssigneePersonID');
        const assigneeEmail = getStringParam(params, 'AssigneeEmail');
        const assigneeName = getStringParam(params, 'AssigneeName');
        const clientRequestKey = getStringParam(params, 'ClientRequestKey');

        if (categoryID && !IsValidUUID(categoryID)) {
            return failResult('VALIDATION_ERROR', 'CategoryID must be a valid UUID.', params);
        }
        if (organizationID && !IsValidUUID(organizationID)) {
            return failResult('VALIDATION_ERROR', 'OrganizationID must be a valid UUID.', params);
        }
        if (parentTaskID && !IsValidUUID(parentTaskID)) {
            return failResult('VALIDATION_ERROR', 'ParentTaskID must be a valid UUID.', params);
        }
        if (assigneePersonID && !IsValidUUID(assigneePersonID)) {
            return failResult('VALIDATION_ERROR', 'AssigneePersonID must be a valid UUID.', params);
        }

        const writeFields: string[] = ['Name', 'TypeID', 'Status', 'Priority', 'PercentComplete', 'CreatedByPersonID'];
        if (description) writeFields.push('Description');
        if (dueAt) writeFields.push('DueAt');
        if (startedAt) writeFields.push('StartedAt');
        if (categoryID) writeFields.push('CategoryID');
        if (organizationID || organizationName) writeFields.push('OrganizationID');
        if (parentTaskID) writeFields.push('ParentID');

        const guard = await checkTypedPolicyGuard({
            params,
            entityName: TASKS_ENTITY,
            operation: 'Create',
            writeFields,
        });
        if (!guard.Allowed) return guard.Failure;

        try {
            const callerPerson = await resolveCallerPerson(user);
            if (!callerPerson) {
                return failResult(
                    'NO_PERSON_RECORD',
                    'No active MJ_BizApps_Common: People record is linked to your user account.',
                    params,
                );
            }

            // Idempotent ClientRequestKey lookup before creating any new record
            if (clientRequestKey) {
                const existingTask = await this.findByClientRequestKey(clientRequestKey, callerPerson.ID, user);
                if (existingTask) {
                    const summary = `Reused existing task "${existingTask.Name}" for ClientRequestKey '${clientRequestKey}'.`;
                    setOutputParam(params, 'TaskID', existingTask.ID);
                    setOutputParam(params, 'OrganizationID', existingTask.OrganizationID ?? null);
                    setOutputParam(params, 'Task', JSON.stringify(toCompactSummary(existingTask)));
                    setOutputParam(params, 'IdempotentHit', true);
                    setOutputParam(params, 'Summary', summary);
                    return successResult(summary, params);
                }
            }

            // Resolve optional Organization BEFORE persisting the task so NOT_FOUND/AMBIGUOUS leaves no orphan task
            let resolvedOrg: { ID: string; Name: string } | null = null;
            if (organizationID || organizationName) {
                const orgLookup = await resolveOrganizationByIdentifier(
                    { organizationID, organizationName },
                    user,
                );
                if (orgLookup.Status === 'INVALID') {
                    return failResult('VALIDATION_ERROR', orgLookup.Message, params);
                }
                if (orgLookup.Status === 'NOT_FOUND') {
                    return failResult('NOT_FOUND', orgLookup.Message, params);
                }
                if (orgLookup.Status === 'AMBIGUOUS') {
                    setOutputParam(params, 'Candidates', JSON.stringify(orgLookup.Candidates));
                    return failResult('AMBIGUOUS', orgLookup.Message, params);
                }
                if (orgLookup.Status === 'FOUND') {
                    resolvedOrg = orgLookup.Organization;
                }
            }

            // Resolve optional assignee BEFORE persisting the task so AMBIGUOUS/NOT_FOUND leaves no orphan task
            let resolvedAssignee: { ID: string; Name: string; Email: string | null; LinkedUserID: string | null } | null = null;
            if (assigneePersonID || assigneeEmail || assigneeName) {
                const lookup = await resolvePersonByIdentifier(
                    { personID: assigneePersonID, email: assigneeEmail, name: assigneeName },
                    user,
                );
                if (lookup.Status === 'AMBIGUOUS') {
                    setOutputParam(params, 'Candidates', JSON.stringify(lookup.Candidates));
                    return failResult('AMBIGUOUS', lookup.Message, params);
                }
                if (lookup.Status === 'NOT_FOUND') {
                    return failResult('NOT_FOUND', lookup.Message, params);
                }
                resolvedAssignee = lookup.Person;
            }

            // Resolve TaskType
            const allTypes = await loadAllTaskTypes(user);
            let selectedType: TaskTypeLookupRow | undefined;
            if (taskTypeName) {
                const needle = taskTypeName.trim().toLowerCase();
                selectedType = allTypes.find(
                    (t) =>
                        t.Code.toLowerCase() === needle ||
                        t.Name.toLowerCase() === needle ||
                        (IsValidUUID(taskTypeName) && UUIDsEqual(t.ID, taskTypeName)),
                );
                if (!selectedType) {
                    return failResult('NOT_FOUND', `TaskType '${taskTypeName}' was not found.`, params);
                }
            } else {
                selectedType =
                    allTypes.find((t) => t.Code.toUpperCase() === 'GENERAL') ??
                    allTypes.find((t) => t.Name.toLowerCase() === 'general') ??
                    allTypes[0];
            }
            if (!selectedType) {
                return failResult('VALIDATION_ERROR', 'No Task Types are installed to create a task.', params);
            }

            const md = new Metadata();
            const task = await md.GetEntityObject<mjBizAppsTasksTaskEntity>(TASKS_ENTITY, user);
            task.NewRecord();
            task.Name = name;
            task.Description = description ?? null;
            task.TypeID = selectedType.ID;
            task.Status = 'Open';
            task.Priority = priority;
            task.PercentComplete = 0;
            task.DueAt = dueAt;
            task.StartedAt = startedAt;
            task.CategoryID = categoryID ?? null;
            task.OrganizationID = resolvedOrg?.ID ?? null;
            task.ParentID = parentTaskID ?? null;
            task.CreatedByPersonID = callerPerson.ID;

            if (!(await task.Save())) {
                const msg = task.LatestResult?.CompleteMessage ?? 'Failed to save new task.';
                return failResult('ERROR', msg, params);
            }

            // Record idempotency key in TaskActivity
            if (clientRequestKey) {
                const act = await md.GetEntityObject<mjBizAppsTasksTaskActivityEntity>(TASK_ACTIVITIES_ENTITY, user);
                act.NewRecord();
                act.TaskID = task.ID;
                act.PersonID = callerPerson.ID;
                act.ActivityType = 'Created';
                act.NewValue = `${CLIENT_REQUEST_KEY_PREFIX}${clientRequestKey}`;
                act.Description = `Created via Create Task action (ClientRequestKey: ${clientRequestKey})`;
                await act.Save();
            }

            // Create assignment if assignee resolved
            if (resolvedAssignee) {
                const peopleEntityID = findEntityIDByName(PEOPLE_ENTITY_NAME);
                if (peopleEntityID) {
                    const assignment = await md.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(
                        TASK_ASSIGNMENTS_ENTITY,
                        user,
                    );
                    assignment.NewRecord();
                    assignment.TaskID = task.ID;
                    assignment.AssigneeEntityID = peopleEntityID;
                    assignment.AssigneeRecordID = resolvedAssignee.ID;
                    assignment.AssignedByPersonID = callerPerson.ID;
                    await assignment.Save();

                    const assigneeUserID =
                        resolvedAssignee.LinkedUserID ??
                        (await resolveUserIDForPersonRecord(resolvedAssignee.ID, user));
                    if (assigneeUserID && !UUIDsEqual(assigneeUserID, user.ID)) {
                        await wakeChiefOfStaffBestEffort({
                            targetUserID: assigneeUserID,
                            workstreamKey: `task-assigned-${task.ID}`,
                            wakeReason: `New task "${task.Name}" assigned to you by ${user.Name ?? user.Email}.`,
                            resumeState: {
                                eventType: 'TaskAssigned',
                                taskID: task.ID,
                                taskName: task.Name,
                                assigneePersonID: resolvedAssignee.ID,
                            },
                            actingUser: user,
                        });
                    }
                }
            }

            const compact: CompactTaskSummary = {
                ID: task.ID,
                Name: task.Name,
                Status: task.Status,
                Priority: task.Priority,
                DueAt: toIsoOrNull(task.DueAt),
                PercentComplete: task.PercentComplete ?? 0,
                Type: selectedType.Name,
                Category: task.Category ?? null,
                OrganizationID: task.OrganizationID ?? null,
                Organization: task.Organization ?? (resolvedOrg?.Name ? resolvedOrg.Name : null),
                ParentID: task.ParentID ?? null,
                BlockedReason: task.BlockedReason ?? null,
                HealthStatus: task.HealthStatus ?? null,
                DeepLink: buildTaskDeepLink(task.ID),
            };

            const assignedSuffix = resolvedAssignee ? ` and assigned to ${resolvedAssignee.Name}` : '';
            const summary = `Created task "${task.Name}" (${task.ID})${assignedSuffix}.`;
            setOutputParam(params, 'TaskID', task.ID);
            setOutputParam(params, 'OrganizationID', task.OrganizationID ?? null);
            setOutputParam(params, 'Task', JSON.stringify(compact));
            setOutputParam(params, 'IdempotentHit', false);
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }

    private async findByClientRequestKey(
        clientRequestKey: string,
        callerPersonID: string,
        user: UserInfo,
    ): Promise<TaskSummaryRow | null> {
        const rv = new RunView();
        const marker = `${CLIENT_REQUEST_KEY_PREFIX}${clientRequestKey}`;
        const actRes = await rv.RunView<{ TaskID: string }>(
            {
                EntityName: TASK_ACTIVITIES_ENTITY,
                ExtraFilter:
                    `ActivityType = 'Created' ` +
                    `AND PersonID = '${EscapeSQLString(callerPersonID)}' ` +
                    `AND NewValue = '${EscapeSQLString(marker)}'`,
                Fields: ['TaskID'],
                OrderBy: '__mj_CreatedAt DESC',
                MaxRows: 1,
                ResultType: 'simple',
            },
            user,
        );
        const existingTaskID = actRes.Success ? actRes.Results?.[0]?.TaskID : undefined;
        if (!existingTaskID || !IsValidUUID(existingTaskID)) return null;

        const taskRes = await rv.RunView<TaskSummaryRow>(
            {
                EntityName: TASKS_ENTITY,
                ExtraFilter: `ID = '${EscapeSQLString(existingTaskID)}'`,
                MaxRows: 1,
                ResultType: 'simple',
            },
            user,
        );
        return taskRes.Success ? (taskRes.Results?.[0] ?? null) : null;
    }
}

// =============================================================================
// 4. Update Task
// =============================================================================

@RegisterClass(BaseAction, 'UpdateTaskAction')
export class UpdateTaskAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const taskID = getStringParam(params, 'TaskID');
        if (!taskID || !IsValidUUID(taskID)) {
            return failResult('VALIDATION_ERROR', 'A valid TaskID UUID is required.', params);
        }

        const name = getStringParam(params, 'Name');
        const description = getStringParam(params, 'Description');
        const statusRaw = getStringParam(params, 'Status');
        const priorityRaw = getStringParam(params, 'Priority');
        const dueAt = getDateParam(params, 'DueAt', 'ExpectedCompletionAt');
        const startedAt = getDateParam(params, 'StartedAt');
        const percentComplete = getNumberParam(params, 'PercentComplete');
        const blockedReason = getStringParam(params, 'BlockedReason');
        const categoryID = getStringParam(params, 'CategoryID');
        const organizationID = getStringParam(params, 'OrganizationID');
        const healthRaw = getStringParam(params, 'HealthStatus');
        const confidenceScore = getNumberParam(params, 'ConfidenceScore');

        if (dueAt === 'INVALID' || startedAt === 'INVALID') {
            return failResult('VALIDATION_ERROR', 'DueAt, ExpectedCompletionAt, and StartedAt must be valid ISO-8601 dates.', params);
        }
        if (categoryID && !IsValidUUID(categoryID)) {
            return failResult('VALIDATION_ERROR', 'CategoryID must be a valid UUID.', params);
        }
        if (organizationID && !IsValidUUID(organizationID)) {
            return failResult('VALIDATION_ERROR', 'OrganizationID must be a valid UUID.', params);
        }
        if (percentComplete != null && (percentComplete < 0 || percentComplete > 100)) {
            return failResult('VALIDATION_ERROR', 'PercentComplete must be between 0 and 100.', params);
        }
        if (confidenceScore != null && (confidenceScore < 0 || confidenceScore > 100)) {
            return failResult('VALIDATION_ERROR', 'ConfidenceScore must be between 0 and 100.', params);
        }

        const status = statusRaw ? normalizeTaskStatus(statusRaw) : null;
        if (statusRaw && !status) {
            return failResult('VALIDATION_ERROR', `Invalid Status '${statusRaw}'.`, params);
        }
        const priority = priorityRaw ? normalizeTaskPriority(priorityRaw) : null;
        if (priorityRaw && !priority) {
            return failResult('VALIDATION_ERROR', `Invalid Priority '${priorityRaw}'.`, params);
        }
        const healthStatus = healthRaw ? normalizeHealthStatus(healthRaw) : null;
        if (healthRaw && !healthStatus) {
            return failResult('VALIDATION_ERROR', `Invalid HealthStatus '${healthRaw}'.`, params);
        }

        const writeFields: string[] = [];
        if (name !== null) writeFields.push('Name');
        if (description !== null) writeFields.push('Description');
        if (status !== null) writeFields.push('Status');
        if (priority !== null) writeFields.push('Priority');
        if (dueAt !== null) writeFields.push('DueAt');
        if (startedAt !== null) writeFields.push('StartedAt');
        if (percentComplete !== null) writeFields.push('PercentComplete');
        if (blockedReason !== null) writeFields.push('BlockedReason');
        if (categoryID !== null) writeFields.push('CategoryID');
        if (organizationID !== null) writeFields.push('OrganizationID');
        if (healthStatus !== null) writeFields.push('HealthStatus');
        if (confidenceScore !== null) writeFields.push('ConfidenceScore');

        if (writeFields.length === 0) {
            return failResult('VALIDATION_ERROR', 'At least one field to update must be supplied.', params);
        }

        try {
            const md = new Metadata();
            const task = await md.GetEntityObject<mjBizAppsTasksTaskEntity>(TASKS_ENTITY, user);
            if (!(await task.Load(taskID))) {
                return failResult('NOT_FOUND', `Task '${taskID}' was not found or is not accessible.`, params);
            }

            const guard = await checkTypedPolicyGuard({
                params,
                entityName: TASKS_ENTITY,
                operation: 'Update',
                writeFields,
                record: {
                    ID: task.ID,
                    Name: task.Name,
                    Status: task.Status,
                    Priority: task.Priority,
                    CategoryID: task.CategoryID,
                    OrganizationID: task.OrganizationID,
                },
            });
            if (!guard.Allowed) return guard.Failure;

            if (name !== null) task.Name = name;
            if (description !== null) task.Description = description;
            if (status !== null) task.Status = status;
            if (priority !== null) task.Priority = priority;
            if (dueAt !== null) task.DueAt = dueAt;
            if (startedAt !== null) task.StartedAt = startedAt;
            if (percentComplete !== null) task.PercentComplete = Math.round(percentComplete);
            if (blockedReason !== null) task.BlockedReason = blockedReason;
            if (categoryID !== null) task.CategoryID = categoryID;
            if (organizationID !== null) task.OrganizationID = organizationID;
            if (healthStatus !== null) task.HealthStatus = healthStatus;
            if (confidenceScore !== null) task.ConfidenceScore = Math.round(confidenceScore);

            if (writeFields.length > 0) {
                if (!(await task.Save())) {
                    const msg = task.LatestResult?.CompleteMessage ?? 'Failed to update task.';
                    return failResult('ERROR', msg, params);
                }
            }

            if (organizationID) {
                await upsertTaskOrganizationLink(task.ID, organizationID, user);
            }

            const compact: CompactTaskSummary = {
                ID: task.ID,
                Name: task.Name,
                Status: task.Status,
                Priority: task.Priority,
                DueAt: toIsoOrNull(task.DueAt),
                PercentComplete: task.PercentComplete ?? 0,
                Type: task.Type,
                Category: task.Category ?? null,
                OrganizationID: task.OrganizationID ?? null,
                Organization: task.Organization ?? null,
                ParentID: task.ParentID ?? null,
                BlockedReason: task.BlockedReason ?? null,
                HealthStatus: task.HealthStatus ?? null,
                DeepLink: buildTaskDeepLink(task.ID),
            };

            const summary = `Updated task "${task.Name}" (${writeFields.join(', ')}).`;
            setOutputParam(params, 'TaskID', task.ID);
            setOutputParam(params, 'Task', JSON.stringify(compact));
            setOutputParam(params, 'UpdatedFields', JSON.stringify(writeFields));
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }
}

// =============================================================================
// 5. Complete Task
// =============================================================================

@RegisterClass(BaseAction, 'CompleteTaskAction')
export class CompleteTaskAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const taskID = getStringParam(params, 'TaskID');
        if (!taskID || !IsValidUUID(taskID)) {
            return failResult('VALIDATION_ERROR', 'A valid TaskID UUID is required.', params);
        }

        const completionNote = getStringParam(params, 'CompletionNote', 'Note');

        const guard = await checkTypedPolicyGuard({
            params,
            entityName: TASKS_ENTITY,
            operation: 'Update',
            writeFields: ['Status', 'PercentComplete', 'CompletedAt', 'CompletionNotes'],
        });
        if (!guard.Allowed) return guard.Failure;

        try {
            const md = new Metadata();
            const task = await md.GetEntityObject<mjBizAppsTasksTaskEntity>(TASKS_ENTITY, user);
            if (!(await task.Load(taskID))) {
                return failResult('NOT_FOUND', `Task '${taskID}' was not found or is not accessible.`, params);
            }

            if (task.Status === 'Completed') {
                const summary = `Task "${task.Name}" is already completed.`;
                setOutputParam(params, 'TaskID', task.ID);
                setOutputParam(params, 'AlreadyCompleted', true);
                setOutputParam(params, 'UnblockedTaskIDs', '[]');
                setOutputParam(params, 'Summary', summary);
                return successResult(summary, params, 'ALREADY_COMPLETED');
            }

            task.Status = 'Completed';
            task.PercentComplete = 100;
            task.CompletedAt = new Date();
            if (completionNote) {
                task.CompletionNotes = completionNote;
            }

            if (!(await task.Save())) {
                const msg = task.LatestResult?.CompleteMessage ?? 'Failed to complete task.';
                return failResult('ERROR', msg, params);
            }

            if (completionNote) {
                const callerPerson = await resolveCallerPerson(user);
                if (callerPerson) {
                    const comment = await md.GetEntityObject<mjBizAppsTasksTaskCommentEntity>(
                        TASK_COMMENTS_ENTITY,
                        user,
                    );
                    comment.NewRecord();
                    comment.TaskID = task.ID;
                    comment.PersonID = callerPerson.ID;
                    comment.Content = completionNote;
                    await comment.Save();
                }
            }

            const unblockedTaskIDs = await this.notifyUnblockedDownstreamTasks(task.ID, task.Name, user);

            const summary =
                unblockedTaskIDs.length > 0
                    ? `Completed task "${task.Name}" and unblocked ${unblockedTaskIDs.length} downstream task(s).`
                    : `Completed task "${task.Name}".`;
            setOutputParam(params, 'TaskID', task.ID);
            setOutputParam(params, 'AlreadyCompleted', false);
            setOutputParam(params, 'UnblockedTaskIDs', JSON.stringify(unblockedTaskIDs));
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }

    private async notifyUnblockedDownstreamTasks(
        completedTaskID: string,
        completedTaskName: string,
        actingUser: UserInfo,
    ): Promise<string[]> {
        const rv = new RunView();
        const depsRes = await rv.RunView<{ TaskID: string; Task?: string | null }>(
            {
                EntityName: TASK_DEPENDENCIES_ENTITY,
                ExtraFilter: `DependsOnTaskID = '${EscapeSQLString(completedTaskID)}'`,
                Fields: ['TaskID', 'Task'],
                MaxRows: 100,
                ResultType: 'simple',
            },
            actingUser,
        );
        const dependentRows = depsRes.Success ? (depsRes.Results ?? []) : [];
        if (dependentRows.length === 0) return [];

        const downstreamIds = Array.from(
            new Set(dependentRows.map((d) => d.TaskID).filter((id) => IsValidUUID(id))),
        );
        if (downstreamIds.length === 0) return [];

        const inDownstream = downstreamIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
        const [downstreamTasksRes, allPrereqsRes] = await Promise.all([
            rv.RunView<{ ID: string; Name: string; Status: TaskStatusValue }>(
                {
                    EntityName: TASKS_ENTITY,
                    ExtraFilter: `ID IN (${inDownstream}) AND Status NOT IN ('Completed', 'Cancelled')`,
                    Fields: ['ID', 'Name', 'Status'],
                    ResultType: 'simple',
                },
                actingUser,
            ),
            rv.RunView<{ TaskID: string; DependsOnTaskID: string }>(
                {
                    EntityName: TASK_DEPENDENCIES_ENTITY,
                    ExtraFilter: `TaskID IN (${inDownstream})`,
                    Fields: ['TaskID', 'DependsOnTaskID'],
                    ResultType: 'simple',
                },
                actingUser,
            ),
        ]);

        const openDownstream = downstreamTasksRes.Success ? (downstreamTasksRes.Results ?? []) : [];
        if (openDownstream.length === 0) return [];

        const allPrereqs = allPrereqsRes.Success ? (allPrereqsRes.Results ?? []) : [];
        const otherPrereqIds = Array.from(
            new Set(
                allPrereqs
                    .map((p) => p.DependsOnTaskID)
                    .filter((id) => IsValidUUID(id) && !UUIDsEqual(id, completedTaskID)),
            ),
        );

        const incompletePrereqIds = new Set<string>();
        if (otherPrereqIds.length > 0) {
            const prereqTasksRes = await rv.RunView<{ ID: string; Status: TaskStatusValue }>(
                {
                    EntityName: TASKS_ENTITY,
                    ExtraFilter: `ID IN (${otherPrereqIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ')}) AND Status <> 'Completed'`,
                    Fields: ['ID', 'Status'],
                    ResultType: 'simple',
                },
                actingUser,
            );
            for (const row of prereqTasksRes.Success ? (prereqTasksRes.Results ?? []) : []) {
                incompletePrereqIds.add(NormalizeUUID(row.ID));
            }
        }

        const unblocked: Array<{ ID: string; Name: string }> = [];
        for (const dsTask of openDownstream) {
            const prereqsForTask = allPrereqs.filter((p) => UUIDsEqual(p.TaskID, dsTask.ID));
            const stillBlocked = prereqsForTask.some(
                (p) =>
                    !UUIDsEqual(p.DependsOnTaskID, completedTaskID) &&
                    incompletePrereqIds.has(NormalizeUUID(p.DependsOnTaskID)),
            );
            if (!stillBlocked) {
                unblocked.push(dsTask);
            }
        }

        if (unblocked.length === 0) return [];

        const peopleEntityID = findEntityIDByName(PEOPLE_ENTITY_NAME);
        const inUnblocked = unblocked.map((t) => `'${EscapeSQLString(t.ID)}'`).join(', ');
        const assignFilter = peopleEntityID
            ? `TaskID IN (${inUnblocked}) AND AssigneeEntityID = '${EscapeSQLString(peopleEntityID)}'`
            : `TaskID IN (${inUnblocked})`;
        const assignRes = await rv.RunView<{ TaskID: string; AssigneeRecordID: string }>(
            {
                EntityName: TASK_ASSIGNMENTS_ENTITY,
                ExtraFilter: assignFilter,
                Fields: ['TaskID', 'AssigneeRecordID'],
                ResultType: 'simple',
            },
            actingUser,
        );

        const assignments = assignRes.Success ? (assignRes.Results ?? []) : [];
        for (const dsTask of unblocked) {
            const taskAssignees = assignments.filter((a) => UUIDsEqual(a.TaskID, dsTask.ID));
            for (const assignee of taskAssignees) {
                const targetUserID = await resolveUserIDForPersonRecord(assignee.AssigneeRecordID, actingUser);
                if (!targetUserID) continue;
                await wakeChiefOfStaffBestEffort({
                    targetUserID,
                    workstreamKey: `task-unblocked-${dsTask.ID}`,
                    wakeReason: `Prerequisite task "${completedTaskName}" was completed, unblocking "${dsTask.Name}".`,
                    resumeState: {
                        eventType: 'TaskUnblocked',
                        taskID: dsTask.ID,
                        taskName: dsTask.Name,
                        completedDependencyTaskID: completedTaskID,
                        completedDependencyTaskName: completedTaskName,
                    },
                    actingUser,
                });
            }
        }

        return unblocked.map((t) => t.ID);
    }
}

// =============================================================================
// 6. Assign Task
// =============================================================================

@RegisterClass(BaseAction, 'AssignTaskAction')
export class AssignTaskAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const taskID = getStringParam(params, 'TaskID');
        if (!taskID || !IsValidUUID(taskID)) {
            return failResult('VALIDATION_ERROR', 'A valid TaskID UUID is required.', params);
        }

        const assigneeTypeRaw = getStringParam(params, 'AssigneeType')?.toLowerCase() ?? null;
        const assigneePersonID = getStringParam(params, 'AssigneePersonID');
        const assigneeEmail = getStringParam(params, 'AssigneeEmail');
        const assigneeName = getStringParam(params, 'AssigneeName');
        const agentID = getStringParam(params, 'AgentID');
        const agentName = getStringParam(params, 'AgentName');
        const mjRoleID = getStringParam(params, 'AssigneeRoleID', 'MJRoleID');
        const mjRoleName = getStringParam(params, 'AssigneeRoleName', 'MJRoleName', 'RoleName');
        const taskRoleRaw = getStringParam(params, 'Role', 'TaskRole', 'AssignmentRole');
        const roleNotes = getStringParam(params, 'RoleNotes');
        const replaceExisting = getBooleanParam(params, 'ReplaceExisting', false);

        const guard = await checkTypedPolicyGuard({
            params,
            entityName: TASK_ASSIGNMENTS_ENTITY,
            operation: 'Create',
            writeFields: ['TaskID', 'AssigneeEntityID', 'AssigneeRecordID', 'RoleID', 'RoleNotes'],
        });
        if (!guard.Allowed) return guard.Failure;

        if (replaceExisting) {
            const delGuard = await checkTypedPolicyGuard({
                params,
                entityName: TASK_ASSIGNMENTS_ENTITY,
                operation: 'Delete',
            });
            if (!delGuard.Allowed) return delGuard.Failure;
        }

        try {
            const rv = new RunView();
            const taskRes = await rv.RunView<{ ID: string; Name: string }>(
                {
                    EntityName: TASKS_ENTITY,
                    ExtraFilter: `ID = '${EscapeSQLString(taskID)}'`,
                    Fields: ['ID', 'Name'],
                    MaxRows: 1,
                    ResultType: 'simple',
                },
                user,
            );
            const task = taskRes.Success ? taskRes.Results?.[0] : undefined;
            if (!task) {
                return failResult('NOT_FOUND', `Task '${taskID}' was not found or is not accessible.`, params);
            }

            // Determine assignee kind: Agent, Role, or Person
            const inferredType: 'agent' | 'role' | 'person' =
                assigneeTypeRaw === 'agent' || Boolean(agentID || agentName)
                    ? 'agent'
                    : assigneeTypeRaw === 'role' || Boolean(mjRoleID || mjRoleName)
                      ? 'role'
                      : 'person';

            let targetEntityName: string;
            let targetRecordID: string;
            let targetDisplayName: string;
            let humanLinkedUserID: string | null = null;

            if (inferredType === 'agent') {
                targetEntityName = AI_AGENTS_ENTITY;
                const resolved = await this.resolveNamedRecord(AI_AGENTS_ENTITY, agentID, agentName, user);
                if (resolved.Status === 'NOT_FOUND') {
                    return failResult('NOT_FOUND', resolved.Message, params);
                }
                if (resolved.Status === 'AMBIGUOUS') {
                    setOutputParam(params, 'Candidates', JSON.stringify(resolved.Candidates));
                    return failResult('AMBIGUOUS', resolved.Message, params);
                }
                targetRecordID = resolved.Record.ID;
                targetDisplayName = resolved.Record.Name;
            } else if (inferredType === 'role') {
                targetEntityName = ROLES_ENTITY;
                const resolved = await this.resolveNamedRecord(ROLES_ENTITY, mjRoleID, mjRoleName, user);
                if (resolved.Status === 'NOT_FOUND') {
                    return failResult('NOT_FOUND', resolved.Message, params);
                }
                if (resolved.Status === 'AMBIGUOUS') {
                    setOutputParam(params, 'Candidates', JSON.stringify(resolved.Candidates));
                    return failResult('AMBIGUOUS', resolved.Message, params);
                }
                targetRecordID = resolved.Record.ID;
                targetDisplayName = resolved.Record.Name;
            } else {
                if (!assigneePersonID && !assigneeEmail && !assigneeName) {
                    return failResult(
                        'VALIDATION_ERROR',
                        'Provide AssigneePersonID, AssigneeEmail, AssigneeName, AgentID/AgentName, or AssigneeRoleID/AssigneeRoleName.',
                        params,
                    );
                }
                targetEntityName = PEOPLE_ENTITY_NAME;
                const lookup = await resolvePersonByIdentifier(
                    { personID: assigneePersonID, email: assigneeEmail, name: assigneeName },
                    user,
                );
                if (lookup.Status === 'AMBIGUOUS') {
                    setOutputParam(params, 'Candidates', JSON.stringify(lookup.Candidates));
                    return failResult('AMBIGUOUS', lookup.Message, params);
                }
                if (lookup.Status === 'NOT_FOUND') {
                    return failResult('NOT_FOUND', lookup.Message, params);
                }
                targetRecordID = lookup.Person.ID;
                targetDisplayName = lookup.Person.Name;
                humanLinkedUserID =
                    lookup.Person.LinkedUserID ?? (await resolveUserIDForPersonRecord(lookup.Person.ID, user));
            }

            const targetEntityID = findEntityIDByName(targetEntityName);
            if (!targetEntityID) {
                return failResult(
                    'ERROR',
                    `Entity metadata for '${targetEntityName}' could not be resolved.`,
                    params,
                );
            }

            const taskRoleID = await this.resolveTaskRoleID(taskRoleRaw, user);
            const callerPerson = await resolveCallerPerson(user);

            // Check existing assignments
            const existingRes = await rv.RunView<mjBizAppsTasksTaskAssignmentEntity>(
                {
                    EntityName: TASK_ASSIGNMENTS_ENTITY,
                    ExtraFilter: `TaskID = '${EscapeSQLString(taskID)}'`,
                    ResultType: 'entity_object',
                    MaxRows: 100,
                },
                user,
            );
            const existingRows = existingRes.Success ? (existingRes.Results ?? []) : [];

            const alreadyAssigned = existingRows.find(
                (a) =>
                    UUIDsEqual(a.AssigneeEntityID, targetEntityID) &&
                    UUIDsEqual(a.AssigneeRecordID, targetRecordID),
            );

            if (replaceExisting) {
                for (const row of existingRows) {
                    if (alreadyAssigned && UUIDsEqual(row.ID, alreadyAssigned.ID)) continue;
                    await row.Delete();
                }
            }

            let assignmentID: string;
            if (alreadyAssigned) {
                if (taskRoleID && !UUIDsEqual(alreadyAssigned.RoleID, taskRoleID)) {
                    alreadyAssigned.RoleID = taskRoleID;
                    if (roleNotes) alreadyAssigned.RoleNotes = roleNotes;
                    await alreadyAssigned.Save();
                }
                assignmentID = alreadyAssigned.ID;
            } else {
                const md = new Metadata();
                const assignment = await md.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(
                    TASK_ASSIGNMENTS_ENTITY,
                    user,
                );
                assignment.NewRecord();
                assignment.TaskID = taskID;
                assignment.AssigneeEntityID = targetEntityID;
                assignment.AssigneeRecordID = targetRecordID;
                if (taskRoleID) assignment.RoleID = taskRoleID;
                if (roleNotes) assignment.RoleNotes = roleNotes;
                if (callerPerson) assignment.AssignedByPersonID = callerPerson.ID;

                if (!(await assignment.Save())) {
                    const msg = assignment.LatestResult?.CompleteMessage ?? 'Failed to save task assignment.';
                    return failResult('ERROR', msg, params);
                }
                assignmentID = assignment.ID;
            }

            // Wake human assignee's Chief of Staff (best-effort, non-blocking)
            if (inferredType === 'person' && humanLinkedUserID && !UUIDsEqual(humanLinkedUserID, user.ID)) {
                await wakeChiefOfStaffBestEffort({
                    targetUserID: humanLinkedUserID,
                    workstreamKey: `task-assigned-${taskID}`,
                    wakeReason: `Task "${task.Name}" was assigned to you by ${user.Name ?? user.Email}.`,
                    resumeState: {
                        eventType: 'TaskAssigned',
                        taskID,
                        taskName: task.Name,
                        taskAssignmentID: assignmentID,
                        assigneePersonID: targetRecordID,
                    },
                    actingUser: user,
                });
            }

            const summary = `Assigned "${task.Name}" to ${targetDisplayName} (${targetEntityName}).`;
            setOutputParam(params, 'TaskAssignmentID', assignmentID);
            setOutputParam(params, 'TaskID', taskID);
            setOutputParam(params, 'AssigneeEntity', targetEntityName);
            setOutputParam(params, 'AssigneeRecordID', targetRecordID);
            setOutputParam(params, 'AssigneeDisplayName', targetDisplayName);
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }

    private async resolveTaskRoleID(rawRole: string | null, user: UserInfo): Promise<string | null> {
        if (!rawRole) return null;
        if (IsValidUUID(rawRole)) return rawRole;

        const norm = rawRole.trim().toLowerCase();
        const canonicalName =
            norm === 'owner' || norm === 'assignee' || norm === 'primary'
                ? 'Primary'
                : norm === 'watcher' || norm === 'observer'
                  ? 'Observer'
                  : norm === 'reviewer'
                    ? 'Reviewer'
                    : rawRole.trim();

        const rv = new RunView();
        const res = await rv.RunView<Pick<mjBizAppsTasksTaskRoleEntity, 'ID' | 'Name'>>(
            {
                EntityName: TASK_ROLES_ENTITY,
                ExtraFilter: `LOWER(Name) = LOWER('${EscapeSQLString(canonicalName)}')`,
                Fields: ['ID', 'Name'],
                MaxRows: 1,
                ResultType: 'simple',
            },
            user,
        );
        return res.Success ? (res.Results?.[0]?.ID ?? null) : null;
    }

    private async resolveNamedRecord(
        entityName: string,
        id: string | null,
        name: string | null,
        user: UserInfo,
    ): Promise<
        | { Status: 'FOUND'; Record: RawNamedEntityRow }
        | { Status: 'NOT_FOUND'; Message: string }
        | { Status: 'AMBIGUOUS'; Candidates: RawNamedEntityRow[]; Message: string }
    > {
        const rv = new RunView();
        if (id) {
            if (!IsValidUUID(id)) {
                return { Status: 'NOT_FOUND', Message: `Invalid UUID '${id}' for ${entityName}.` };
            }
            const res = await rv.RunView<RawNamedEntityRow>(
                {
                    EntityName: entityName,
                    ExtraFilter: `ID = '${EscapeSQLString(id)}'`,
                    Fields: ['ID', 'Name'],
                    MaxRows: 1,
                    ResultType: 'simple',
                },
                user,
            );
            const row = res.Success ? res.Results?.[0] : undefined;
            return row
                ? { Status: 'FOUND', Record: row }
                : { Status: 'NOT_FOUND', Message: `No ${entityName} record found with ID '${id}'.` };
        }
        if (!name) {
            return { Status: 'NOT_FOUND', Message: `Name or ID is required for ${entityName}.` };
        }
        const res = await rv.RunView<RawNamedEntityRow>(
            {
                EntityName: entityName,
                ExtraFilter: `LOWER(Name) LIKE LOWER('%${EscapeSQLString(name.trim())}%')`,
                Fields: ['ID', 'Name'],
                MaxRows: 10,
                ResultType: 'simple',
            },
            user,
        );
        const rows = res.Success ? (res.Results ?? []) : [];
        if (rows.length === 0) {
            return { Status: 'NOT_FOUND', Message: `No ${entityName} record matched '${name}'.` };
        }
        if (rows.length === 1) {
            return { Status: 'FOUND', Record: rows[0] };
        }
        const exact = rows.filter((r) => r.Name.toLowerCase() === name.trim().toLowerCase());
        if (exact.length === 1) {
            return { Status: 'FOUND', Record: exact[0] };
        }
        return {
            Status: 'AMBIGUOUS',
            Candidates: rows,
            Message: `Multiple ${entityName} records matched '${name}'. Please clarify by ID.`,
        };
    }
}

// =============================================================================
// 7. Add Task Update
// =============================================================================

@RegisterClass(BaseAction, 'AddTaskUpdateAction')
export class AddTaskUpdateAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const taskID = getStringParam(params, 'TaskID');
        if (!taskID || !IsValidUUID(taskID)) {
            return failResult('VALIDATION_ERROR', 'A valid TaskID UUID is required.', params);
        }

        const content = getStringParam(params, 'Content', 'Note', 'Summary');
        if (!content) {
            return failResult('VALIDATION_ERROR', 'Content (or Note) is required for a task update.', params);
        }

        const healthRaw = getStringParam(params, 'HealthStatus');
        const confidence = getNumberParam(params, 'ConfidenceScore', 'Confidence');
        const percentComplete = getNumberParam(params, 'PercentComplete');
        const blockers = getStringParam(params, 'Blockers');
        const nextSteps = getStringParam(params, 'NextSteps');
        const explicitKind = getStringParam(params, 'UpdateKind')?.toLowerCase() ?? null;

        const healthStatus = healthRaw ? normalizeHealthStatus(healthRaw) : null;
        if (healthRaw && !healthStatus) {
            return failResult('VALIDATION_ERROR', `Invalid HealthStatus '${healthRaw}'.`, params);
        }
        if (confidence != null && (confidence < 0 || confidence > 100)) {
            return failResult('VALIDATION_ERROR', 'ConfidenceScore must be between 0 and 100.', params);
        }
        if (percentComplete != null && (percentComplete < 0 || percentComplete > 100)) {
            return failResult('VALIDATION_ERROR', 'PercentComplete must be between 0 and 100.', params);
        }

        const isCheckIn =
            explicitKind === 'checkin' ||
            (explicitKind !== 'comment' &&
                Boolean(healthStatus || confidence != null || blockers || nextSteps));

        const targetEntity = isCheckIn ? TASK_CHECK_INS_ENTITY : TASK_COMMENTS_ENTITY;
        const guard = await checkTypedPolicyGuard({
            params,
            entityName: targetEntity,
            operation: 'Create',
            writeFields: isCheckIn
                ? ['TaskID', 'AuthorPersonID', 'AuthorUserID', 'Summary', 'HealthStatus', 'ConfidenceScore', 'PercentComplete', 'Blockers', 'NextSteps']
                : ['TaskID', 'PersonID', 'Content'],
        });
        if (!guard.Allowed) return guard.Failure;

        try {
            const callerPerson = await resolveCallerPerson(user);
            if (!callerPerson) {
                return failResult(
                    'NO_PERSON_RECORD',
                    'No active MJ_BizApps_Common: People record is linked to your user account.',
                    params,
                );
            }

            const rv = new RunView();
            const taskRes = await rv.RunView<{ ID: string; Name: string }>(
                {
                    EntityName: TASKS_ENTITY,
                    ExtraFilter: `ID = '${EscapeSQLString(taskID)}'`,
                    Fields: ['ID', 'Name'],
                    MaxRows: 1,
                    ResultType: 'simple',
                },
                user,
            );
            const task = taskRes.Success ? taskRes.Results?.[0] : undefined;
            if (!task) {
                return failResult('NOT_FOUND', `Task '${taskID}' was not found or is not accessible.`, params);
            }

            const md = new Metadata();
            if (isCheckIn) {
                const checkIn = await md.GetEntityObject<mjBizAppsTasksTaskCheckInEntity>(
                    TASK_CHECK_INS_ENTITY,
                    user,
                );
                checkIn.NewRecord();
                checkIn.TaskID = task.ID;
                checkIn.AuthorPersonID = callerPerson.ID;
                checkIn.AuthorUserID = user.ID;
                checkIn.CheckInAt = new Date();
                checkIn.HealthStatus = healthStatus ?? 'OnTrack';
                checkIn.Summary = content;
                if (confidence != null) checkIn.ConfidenceScore = Math.round(confidence);
                if (percentComplete != null) checkIn.PercentComplete = Math.round(percentComplete);
                if (blockers) checkIn.Blockers = blockers;
                if (nextSteps) checkIn.NextSteps = nextSteps;

                if (!(await checkIn.Save())) {
                    return failResult(
                        'ERROR',
                        checkIn.LatestResult?.CompleteMessage ?? 'Failed to save task check-in.',
                        params,
                    );
                }

                const summary = `Recorded check-in on "${task.Name}" (${checkIn.HealthStatus}).`;
                setOutputParam(params, 'CheckInID', checkIn.ID);
                setOutputParam(params, 'UpdateKind', 'CheckIn');
                setOutputParam(params, 'TaskID', task.ID);
                setOutputParam(params, 'Summary', summary);
                return successResult(summary, params);
            }

            const comment = await md.GetEntityObject<mjBizAppsTasksTaskCommentEntity>(
                TASK_COMMENTS_ENTITY,
                user,
            );
            comment.NewRecord();
            comment.TaskID = task.ID;
            comment.PersonID = callerPerson.ID;
            comment.Content = content;

            if (!(await comment.Save())) {
                return failResult(
                    'ERROR',
                    comment.LatestResult?.CompleteMessage ?? 'Failed to save task comment.',
                    params,
                );
            }

            const summary = `Added update comment to "${task.Name}".`;
            setOutputParam(params, 'CommentID', comment.ID);
            setOutputParam(params, 'UpdateKind', 'Comment');
            setOutputParam(params, 'TaskID', task.ID);
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }
}

// =============================================================================
// 8. Find Similar Tasks
// =============================================================================

@RegisterClass(BaseAction, 'FindSimilarTasksAction')
export class FindSimilarTasksAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const text = getStringParam(params, 'Text', 'Query', 'Title');
        if (!text) {
            return failResult('VALIDATION_ERROR', 'Text is required to search for similar tasks.', params);
        }

        const guard = await checkTypedPolicyGuard({
            params,
            entityName: TASKS_ENTITY,
            operation: 'Read',
        });
        if (!guard.Allowed) return guard.Failure;

        try {
            const windowDaysRaw = getNumberParam(params, 'WindowDays') ?? 30;
            const windowDays = Math.max(1, Math.min(365, Math.round(windowDaysRaw)));
            const minScoreRaw = getNumberParam(params, 'MinScore') ?? 0.35;
            const minScore = Math.max(0.05, Math.min(1, minScoreRaw));
            const limitRaw = getNumberParam(params, 'Limit', 'MaxRows') ?? 5;
            const limit = Math.max(1, Math.min(25, Math.round(limitRaw)));
            const assigneePersonIDParam = getStringParam(params, 'AssigneePersonID');
            const assigneeEmailParam = getStringParam(params, 'AssigneeEmail');

            let preferredAssigneePersonID: string | null = null;
            if (assigneePersonIDParam || assigneeEmailParam) {
                const lookup = await resolvePersonByIdentifier(
                    { personID: assigneePersonIDParam, email: assigneeEmailParam },
                    user,
                );
                if (lookup.Status === 'FOUND') {
                    preferredAssigneePersonID = lookup.Person.ID;
                }
            }

            const cutoff = new Date(Date.now() - windowDays * 24 * 60 * 60 * 1000).toISOString();
            const rv = new RunView();
            const [tasksRes, semanticScores] = await Promise.all([
                rv.RunView<TaskSummaryRow>(
                    {
                        EntityName: TASKS_ENTITY,
                        ExtraFilter: `Status IN ('Open', 'InProgress', 'Blocked') OR __mj_UpdatedAt >= '${EscapeSQLString(cutoff)}'`,
                        Fields: ['ID', 'Name', 'Description', 'Status', 'Priority', 'DueAt', '__mj_UpdatedAt'],
                        OrderBy: '__mj_UpdatedAt DESC',
                        MaxRows: 250,
                        ResultType: 'simple',
                    },
                    user,
                ),
                trySemanticTaskSearch(text, 25, user),
            ]);

            if (!tasksRes.Success) {
                return failResult('ERROR', tasksRes.ErrorMessage ?? 'Failed to load candidate tasks.', params);
            }

            const rows = tasksRes.Results ?? [];
            const validIds = rows.map((r) => r.ID).filter((id) => IsValidUUID(id));
            const assigneesByTask = new Map<string, string[]>();
            if (validIds.length > 0 && preferredAssigneePersonID) {
                const assignRes = await rv.RunView<{ TaskID: string; AssigneeRecordID: string }>(
                    {
                        EntityName: TASK_ASSIGNMENTS_ENTITY,
                        ExtraFilter: `TaskID IN (${validIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ')})`,
                        Fields: ['TaskID', 'AssigneeRecordID'],
                        ResultType: 'simple',
                    },
                    user,
                );
                for (const row of assignRes.Success ? (assignRes.Results ?? []) : []) {
                    const key = row.TaskID.toLowerCase();
                    const list = assigneesByTask.get(key) ?? [];
                    list.push(row.AssigneeRecordID);
                    assigneesByTask.set(key, list);
                }
            }

            const candidates: TaskSimilarityCandidate[] = rows.map((r) => ({
                ID: r.ID,
                Name: r.Name,
                Description: r.Description ?? null,
                Status: r.Status,
                Priority: r.Priority,
                DueAt: toIsoOrNull(r.DueAt),
                UpdatedAt: toIsoOrNull(r.__mj_UpdatedAt),
                AssigneePersonIDs: assigneesByTask.get(r.ID.toLowerCase()) ?? [],
            }));

            const ranked = rankSimilarTasks(text, candidates, {
                semanticScoresByTaskID: semanticScores,
                preferredAssigneePersonID,
                minScore,
                limit,
            });

            const enriched = ranked.map((m) => ({
                TaskID: m.TaskID,
                Name: m.Name,
                Status: m.Status,
                Priority: m.Priority,
                DueAt: m.DueAt,
                Score: m.Score,
                LexicalScore: m.LexicalScore,
                SemanticScore: m.SemanticScore,
                MatchReason: m.MatchReason,
                DeepLink: buildTaskDeepLink(m.TaskID),
            }));
            const masked = TypedActionPolicyGuard.MaskRows(enriched, guard.DeniedFieldPatterns);
            const hasLikelyDuplicate = ranked.length > 0 && ranked[0].Score >= 0.55;

            const summary = hasLikelyDuplicate
                ? `Found ${masked.length} similar task(s); top match "${ranked[0].Name}" (score ${ranked[0].Score}) looks like a duplicate.`
                : `Found ${masked.length} similar task(s) within the last ${windowDays} day(s).`;

            setOutputParam(params, 'Matches', JSON.stringify(masked));
            setOutputParam(params, 'HasLikelyDuplicate', hasLikelyDuplicate);
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }
}

// =============================================================================
// 9. Get My Tasks Briefing (Role = 'Briefing', ExposeToModel = false)
// =============================================================================

@RegisterClass(BaseAction, 'GetMyTasksBriefingAction')
export class GetMyTasksBriefingAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);

        const taskGuard = await checkTypedPolicyGuard({
            params,
            entityName: TASKS_ENTITY,
            operation: 'Read',
        });
        if (!taskGuard.Allowed) return taskGuard.Failure;

        try {
            const callerPerson = await resolveCallerPerson(user);
            if (!callerPerson) {
                return failResult(
                    'NO_PERSON_RECORD',
                    'No active MJ_BizApps_Common: People record is linked to your user account.',
                    params,
                );
            }

            const horizonDaysRaw = getNumberParam(params, 'HorizonDays') ?? 7;
            const horizonDays = Math.max(1, Math.min(30, Math.round(horizonDaysRaw)));
            const maxItemsRaw = getNumberParam(params, 'MaxItems') ?? 10;
            const maxItems = Math.max(1, Math.min(50, Math.round(maxItemsRaw)));
            const organizationID = getStringParam(params, 'OrganizationID');
            const organizationName = getStringParam(params, 'OrganizationName');

            let resolvedOrg: { ID: string; Name: string } | null = null;
            if (organizationID || organizationName) {
                const orgLookup = await resolveOrganizationByIdentifier(
                    { organizationID, organizationName },
                    user,
                );
                if (orgLookup.Status === 'INVALID') {
                    return failResult('VALIDATION_ERROR', orgLookup.Message, params);
                }
                if (orgLookup.Status === 'NOT_FOUND') {
                    return failResult('NOT_FOUND', orgLookup.Message, params);
                }
                if (orgLookup.Status === 'AMBIGUOUS') {
                    setOutputParam(params, 'Candidates', JSON.stringify(orgLookup.Candidates));
                    return failResult('AMBIGUOUS', orgLookup.Message, params);
                }
                if (orgLookup.Status === 'FOUND') {
                    resolvedOrg = orgLookup.Organization;
                }
            }

            const now = new Date();
            const startOfToday = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), 0, 0, 0, 0));
            const endOfToday = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), 23, 59, 59, 999));
            const horizonEnd = new Date(endOfToday.getTime() + horizonDays * 24 * 60 * 60 * 1000);

            const [assignedIds, allTypes] = await Promise.all([
                getPersonAssignedTaskIDs(callerPerson.ID, user),
                loadAllTaskTypes(user),
            ]);

            const approvalTypeIds = new Set(
                allTypes.filter((t) => Boolean(t.IsApproval)).map((t) => NormalizeUUID(t.ID)),
            );
            const planningTypeIds = new Set(
                allTypes.filter(isPlanningTaskType).map((t) => NormalizeUUID(t.ID)),
            );

            const taskScopeClauses: string[] = [`CreatedByPersonID = '${EscapeSQLString(callerPerson.ID)}'`];
            if (assignedIds.length > 0) {
                const inAssigned = assignedIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
                taskScopeClauses.push(`ID IN (${inAssigned})`);
            }

            const orgClause = resolvedOrg
                ? ` AND OrganizationID = '${EscapeSQLString(resolvedOrg.ID)}'`
                : '';

            const rv = new RunView();
            const tasksRes = await rv.RunView<TaskSummaryRow>(
                {
                    EntityName: TASKS_ENTITY,
                    ExtraFilter: `(${taskScopeClauses.join(' OR ')}) AND Status NOT IN ('Completed', 'Cancelled')${orgClause}`,
                    Fields: [
                        'ID',
                        'Name',
                        'Status',
                        'Priority',
                        'DueAt',
                        'PercentComplete',
                        'TypeID',
                        'Type',
                        'Category',
                        'OrganizationID',
                        'Organization',
                        'ParentID',
                        'BlockedReason',
                        'HealthStatus',
                        'CreatedByPersonID',
                    ],
                    OrderBy: 'DueAt ASC',
                    MaxRows: 250,
                    ResultType: 'simple',
                },
                user,
            );
            if (!tasksRes.Success) {
                return failResult('ERROR', tasksRes.ErrorMessage ?? 'Failed to load briefing tasks.', params);
            }

            const activeTasks = (tasksRes.Results ?? []).filter(
                (t) => !planningTypeIds.has(NormalizeUUID(t.TypeID)),
            );
            const assignedSet = new Set(assignedIds.map((id) => NormalizeUUID(id)));

            // Find assignments on created-by-me tasks to distinguish "waiting on others"
            const createdOnlyIds = activeTasks
                .filter(
                    (t) =>
                        t.CreatedByPersonID &&
                        UUIDsEqual(t.CreatedByPersonID, callerPerson.ID) &&
                        !assignedSet.has(NormalizeUUID(t.ID)),
                )
                .map((t) => t.ID);
            const delegatedTaskIds = new Set<string>();
            if (createdOnlyIds.length > 0) {
                const delRes = await rv.RunView<{ TaskID: string }>(
                    {
                        EntityName: TASK_ASSIGNMENTS_ENTITY,
                        ExtraFilter: `TaskID IN (${createdOnlyIds.map((id) => `'${EscapeSQLString(id)}'`).join(', ')})`,
                        Fields: ['TaskID'],
                        ResultType: 'simple',
                    },
                    user,
                );
                for (const row of delRes.Success ? (delRes.Results ?? []) : []) {
                    delegatedTaskIds.add(NormalizeUUID(row.TaskID));
                }
            }

            const overdue: CompactTaskSummary[] = [];
            const dueToday: CompactTaskSummary[] = [];
            const upcoming: CompactTaskSummary[] = [];
            const blocked: CompactTaskSummary[] = [];
            const waitingOnOthers: CompactTaskSummary[] = [];
            const pendingApprovals: CompactTaskSummary[] = [];

            for (const task of activeTasks) {
                const compact = toCompactSummary(task);
                const normId = NormalizeUUID(task.ID);
                const isMine = assignedSet.has(normId) || !delegatedTaskIds.has(normId);

                if (delegatedTaskIds.has(normId)) {
                    waitingOnOthers.push(compact);
                }

                if (assignedSet.has(normId) && approvalTypeIds.has(NormalizeUUID(task.TypeID))) {
                    pendingApprovals.push(compact);
                }

                if (!isMine) continue;

                if (task.Status === 'Blocked') {
                    blocked.push(compact);
                }

                if (task.DueAt) {
                    const dueDate = task.DueAt instanceof Date ? task.DueAt : new Date(task.DueAt);
                    if (!Number.isNaN(dueDate.getTime())) {
                        if (dueDate.getTime() < startOfToday.getTime()) {
                            overdue.push(compact);
                        } else if (dueDate.getTime() <= endOfToday.getTime()) {
                            dueToday.push(compact);
                        } else if (dueDate.getTime() <= horizonEnd.getTime()) {
                            upcoming.push(compact);
                        }
                    }
                }
            }

            // Recent unreviewed Work Reports (my drafts + direct reports' submitted) if policy permits
            const unreviewedWorkReports: Array<Record<string, string | null>> = [];
            const wrGuard = await checkTypedPolicyGuard({
                params,
                entityName: WORK_REPORTS_ENTITY,
                operation: 'Read',
            });
            if (wrGuard.Allowed) {
                let directReportPersonIDs: string[] = [];
                try {
                    directReportPersonIDs = await WorkReportService.Instance.ResolveDirectReportPersonIDs(
                        callerPerson.ID,
                        user,
                    );
                } catch {
                    directReportPersonIDs = [];
                }

                const wrClauses: string[] = [
                    `(PersonID = '${EscapeSQLString(callerPerson.ID)}' AND Status = 'Draft')`,
                ];
                if (directReportPersonIDs.length > 0) {
                    const inTeam = directReportPersonIDs.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
                    wrClauses.push(`(PersonID IN (${inTeam}) AND Status = 'Submitted')`);
                }

                const wrRes = await rv.RunView<
                    Pick<mjBizAppsTasksWorkReportEntity, 'ID' | 'Title' | 'PersonID' | 'Person' | 'Status' | 'PeriodStart' | 'PeriodEnd'>
                >(
                    {
                        EntityName: WORK_REPORTS_ENTITY,
                        ExtraFilter: wrClauses.join(' OR '),
                        Fields: ['ID', 'Title', 'PersonID', 'Person', 'Status', 'PeriodStart', 'PeriodEnd'],
                        OrderBy: 'PeriodEnd DESC',
                        MaxRows: maxItems,
                        ResultType: 'simple',
                    },
                    user,
                );
                for (const wr of wrRes.Success ? (wrRes.Results ?? []) : []) {
                    const row = TypedActionPolicyGuard.MaskRecord(
                        {
                            ID: wr.ID,
                            Title: wr.Title ?? 'Work Report',
                            Person: wr.Person ?? null,
                            Status: wr.Status,
                            PeriodStart: toIsoOrNull(wr.PeriodStart),
                            PeriodEnd: toIsoOrNull(wr.PeriodEnd),
                            DeepLink: buildWorkReportDeepLink(wr.ID),
                        },
                        wrGuard.DeniedFieldPatterns,
                    );
                    unreviewedWorkReports.push(row as Record<string, string | null>);
                }
            }

            const briefing = {
                GeneratedAt: now.toISOString(),
                HorizonDays: horizonDays,
                OrganizationID: resolvedOrg?.ID ?? null,
                OrganizationName: resolvedOrg?.Name || null,
                Counts: {
                    Overdue: overdue.length,
                    DueToday: dueToday.length,
                    Upcoming: upcoming.length,
                    Blocked: blocked.length,
                    WaitingOnOthers: waitingOnOthers.length,
                    PendingApprovals: pendingApprovals.length,
                    UnreviewedWorkReports: unreviewedWorkReports.length,
                },
                OverdueTasks: TypedActionPolicyGuard.MaskRows(overdue.slice(0, maxItems), taskGuard.DeniedFieldPatterns),
                DueTodayTasks: TypedActionPolicyGuard.MaskRows(dueToday.slice(0, maxItems), taskGuard.DeniedFieldPatterns),
                UpcomingTasks: TypedActionPolicyGuard.MaskRows(upcoming.slice(0, maxItems), taskGuard.DeniedFieldPatterns),
                BlockedTasks: TypedActionPolicyGuard.MaskRows(blocked.slice(0, maxItems), taskGuard.DeniedFieldPatterns),
                WaitingOnOthersTasks: TypedActionPolicyGuard.MaskRows(waitingOnOthers.slice(0, maxItems), taskGuard.DeniedFieldPatterns),
                PendingApprovalTasks: TypedActionPolicyGuard.MaskRows(pendingApprovals.slice(0, maxItems), taskGuard.DeniedFieldPatterns),
                UnreviewedWorkReports: unreviewedWorkReports,
            };

            const summary =
                `Tasks briefing: ${overdue.length} overdue, ${dueToday.length} due today, ` +
                `${upcoming.length} upcoming (${horizonDays}d), ${blocked.length} blocked, ` +
                `${waitingOnOthers.length} waiting on others, ${pendingApprovals.length} pending approval(s), ` +
                `${unreviewedWorkReports.length} unreviewed work report(s).`;

            setOutputParam(params, 'Briefing', JSON.stringify(briefing));
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            return failResult('ERROR', err instanceof Error ? err.message : String(err), params);
        }
    }
}
