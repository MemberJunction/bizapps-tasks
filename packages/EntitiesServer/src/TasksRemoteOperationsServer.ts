import {
    BaseRemotableOperation,
    CompositeKey,
    IMetadataProvider,
    RunView,
    UserInfo,
} from '@memberjunction/core';
import { RegisterClass } from '@memberjunction/global';
import {
    TASKS_BULK_UPDATE_OP_KEY,
    TASKS_INSTANTIATE_TEMPLATE_OP_KEY,
    TASKS_RUN_RECURRING_PLAYBOOKS_OP_KEY,
    TasksBulkUpdateFailure,
    TasksBulkUpdateInput,
    TasksBulkUpdateOperation,
    TasksBulkUpdateOutput,
    TasksInstantiateTemplateInput,
    TasksInstantiateTemplateOperation,
    TasksInstantiateTemplateOutput,
    TasksRunRecurringPlaybooksInput,
    TasksRunRecurringPlaybooksOperation,
    TasksRunRecurringPlaybooksOutput,
    type RecurringPlaybookOrgResult,
} from '@mj-biz-apps/tasks-core';
import {
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTaskDependencyEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskTagLinkEntity,
    mjBizAppsTasksTaskTemplateEntity,
    mjBizAppsTasksTaskTemplateItemDependencyEntity,
    mjBizAppsTasksTaskTemplateItemEntity,
} from '@mj-biz-apps/tasks-entities';

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const DATE_ONLY_PATTERN = /^\d{4}-\d{2}-\d{2}$/;
const MAX_BULK_TASKS = 500;
const MS_PER_DAY = 24 * 60 * 60 * 1000;

function assertUuid(value: string, label: string): string {
    const trimmed = value.trim();
    if (!UUID_PATTERN.test(trimmed)) {
        throw new Error(`Invalid ${label} '${value}'`);
    }
    return trimmed;
}

function parseIsoDate(raw: string, label: string): Date {
    const trimmed = raw.trim();
    const normalized = DATE_ONLY_PATTERN.test(trimmed) ? `${trimmed}T12:00:00.000Z` : trimmed;
    const parsed = new Date(normalized);
    if (Number.isNaN(parsed.getTime())) {
        throw new Error(`Invalid ${label} date '${raw}'`);
    }
    return parsed;
}

function shiftDateByDays(date: Date, days: number): Date {
    return new Date(date.getTime() + days * MS_PER_DAY);
}

interface TemplateItemRow {
    ID: string;
    Name: string;
    Description: string | null;
    ParentItemID: string | null;
    Priority: mjBizAppsTasksTaskTemplateItemEntity['Priority'];
    DaysFromStart: number | null;
    HoursEstimated: number | null;
    Sequence: number;
}

interface TemplateItemRoleRow {
    ItemID: string;
    RoleID: string;
}

interface TemplateItemDependencyRow {
    ItemID: string;
    DependsOnItemID: string;
    DependencyType: mjBizAppsTasksTaskTemplateItemDependencyEntity['DependencyType'];
}

function topologicalSortTemplateItems(items: TemplateItemRow[]): TemplateItemRow[] {
    const result: TemplateItemRow[] = [];
    const remaining = [...items];
    const placed = new Set<string>();

    // First pass: root items (no parent) in original Sequence order
    for (let i = 0; i < remaining.length; ) {
        if (!remaining[i].ParentItemID) {
            placed.add(remaining[i].ID.toLowerCase());
            result.push(remaining[i]);
            remaining.splice(i, 1);
        } else {
            i++;
        }
    }

    // Subsequent passes: place items once their parent is placed
    let guard = remaining.length + 1;
    while (remaining.length > 0 && guard-- > 0) {
        let progressed = false;
        for (let i = 0; i < remaining.length; ) {
            const parentKey = remaining[i].ParentItemID?.toLowerCase();
            if (parentKey && placed.has(parentKey)) {
                placed.add(remaining[i].ID.toLowerCase());
                result.push(remaining[i]);
                remaining.splice(i, 1);
                progressed = true;
            } else {
                i++;
            }
        }
        if (!progressed) break;
    }

    // Any remaining orphaned items go at the end
    result.push(...remaining);
    return result;
}

/**
 * Server-side implementation of `BizAppsTasks.BulkUpdateTasks`.
 *
 * Applies multi-task mutations authoritatively on the server through MJ entity
 * saves so `TaskEntityServer` lifecycle hooks (activity audit logs, parent
 * progress rollups, `TaskTypeStatus` sync, and action hooks) all fire cleanly
 * without client-side save loops.
 */
@RegisterClass(BaseRemotableOperation, TASKS_BULK_UPDATE_OP_KEY)
export class TasksBulkUpdateServerOperation extends TasksBulkUpdateOperation {
    protected override async InternalExecute(
        input: TasksBulkUpdateInput,
        provider: IMetadataProvider,
        user: UserInfo,
    ): Promise<TasksBulkUpdateOutput> {
        const rawIds = input?.TaskIDs ?? [];
        if (!Array.isArray(rawIds) || rawIds.length === 0) {
            throw new Error('TaskIDs must contain at least one task ID.');
        }

        const uniqueIds: string[] = [];
        const seen = new Set<string>();
        for (const rawId of rawIds) {
            const id = assertUuid(rawId, 'TaskID');
            const lower = id.toLowerCase();
            if (!seen.has(lower)) {
                seen.add(lower);
                uniqueIds.push(id);
            }
        }
        if (uniqueIds.length > MAX_BULK_TASKS) {
            throw new Error(`Bulk update supports at most ${MAX_BULK_TASKS} tasks per call (received ${uniqueIds.length}).`);
        }

        const dueDateMode = input.DueDateMode ?? 'unchanged';
        const parsedDueAt = dueDateMode === 'set'
            ? (() => {
                  if (!input.DueAt) throw new Error('DueAt is required when DueDateMode is "set".');
                  return parseIsoDate(input.DueAt, 'DueAt');
              })()
            : null;
        const shiftDays = dueDateMode === 'shift'
            ? (() => {
                  if (typeof input.ShiftDays !== 'number' || !Number.isFinite(input.ShiftDays) || !Number.isInteger(input.ShiftDays)) {
                      throw new Error('ShiftDays must be a finite integer when DueDateMode is "shift".');
                  }
                  return input.ShiftDays;
              })()
            : null;

        const startDateMode = input.StartDateMode ?? 'unchanged';
        const parsedStartedAt = startDateMode === 'set'
            ? (() => {
                  if (!input.StartedAt) throw new Error('StartedAt is required when StartDateMode is "set".');
                  return parseIsoDate(input.StartedAt, 'StartedAt');
              })()
            : null;

        const organizationMode = input.OrganizationMode ?? 'unchanged';
        const targetOrganizationID = organizationMode === 'set'
            ? (() => {
                  if (!input.OrganizationID) throw new Error('OrganizationID is required when OrganizationMode is "set".');
                  return assertUuid(input.OrganizationID, 'OrganizationID');
              })()
            : null;

        const categoryMode = input.CategoryMode ?? 'unchanged';
        const targetCategoryID = categoryMode === 'set'
            ? (() => {
                  if (!input.CategoryID) throw new Error('CategoryID is required when CategoryMode is "set".');
                  return assertUuid(input.CategoryID, 'CategoryID');
              })()
            : null;

        const targetTypeID = input.TypeID ? assertUuid(input.TypeID, 'TypeID') : null;
        const targetTaskTypeStatusID = input.TaskTypeStatusID
            ? assertUuid(input.TaskTypeStatusID, 'TaskTypeStatusID')
            : null;
        const targetAddTagID = input.AddTagID ? assertUuid(input.AddTagID, 'AddTagID') : null;

        const assigneeMode = input.AssigneeMode ?? 'unchanged';
        let assigneeEntityID: string | null = null;
        let assigneeRecordID: string | null = null;
        let assigneeRoleID: string | null = null;

        const rv = RunView.FromMetadataProvider(provider);

        if (assigneeMode === 'replace' || assigneeMode === 'add') {
            const entityName = input.AssigneeEntityName?.trim();
            if (!entityName) {
                throw new Error(`AssigneeEntityName is required when AssigneeMode is "${assigneeMode}".`);
            }
            const entityInfo = provider.EntityByName(entityName);
            if (!entityInfo) {
                throw new Error(`Unknown AssigneeEntityName '${entityName}'.`);
            }
            assigneeEntityID = entityInfo.ID;

            const recordId = input.AssigneeRecordID?.trim();
            if (!recordId) {
                throw new Error(`AssigneeRecordID is required when AssigneeMode is "${assigneeMode}".`);
            }
            assigneeRecordID = recordId;

            if (input.AssigneeRoleID) {
                assigneeRoleID = assertUuid(input.AssigneeRoleID, 'AssigneeRoleID');
            } else {
                const roleRes = await rv.RunView<{ ID: string; Name: string }>({
                    EntityName: 'MJ_BizApps_Tasks: Task Roles',
                    Fields: ['ID', 'Name'],
                    OrderBy: 'Sequence ASC',
                    ResultType: 'simple',
                }, user);
                if (roleRes.Success && roleRes.Results?.length) {
                    const primary = roleRes.Results.find((r) => r.Name.toLowerCase() === 'primary');
                    assigneeRoleID = (primary ?? roleRes.Results[0]).ID;
                }
            }
        }

        const updatedTaskIDs: string[] = [];
        const failures: TasksBulkUpdateFailure[] = [];

        for (const taskID of uniqueIds) {
            try {
                const task = await provider.GetEntityObject<mjBizAppsTasksTaskEntity>(
                    'MJ_BizApps_Tasks: Tasks',
                    user,
                );
                const loaded = await task.InnerLoad(CompositeKey.FromID(taskID));
                if (!loaded) {
                    failures.push({ TaskID: taskID, Error: 'Task not found.' });
                    continue;
                }

                let mutatedScalar = false;

                if (input.Status) {
                    task.Status = input.Status;
                    if (input.Status === 'Completed') {
                        if (task.PercentComplete !== 100) task.PercentComplete = 100;
                        if (!task.CompletedAt) task.CompletedAt = new Date();
                    } else if (task.CompletedAt) {
                        task.CompletedAt = null;
                    }
                    mutatedScalar = true;
                }

                if (input.Priority) {
                    task.Priority = input.Priority;
                    mutatedScalar = true;
                }

                if (dueDateMode === 'set' && parsedDueAt) {
                    task.DueAt = parsedDueAt;
                    mutatedScalar = true;
                } else if (dueDateMode === 'shift' && shiftDays !== null && shiftDays !== 0) {
                    if (task.DueAt) {
                        task.DueAt = shiftDateByDays(new Date(task.DueAt), shiftDays);
                        mutatedScalar = true;
                    }
                    if (task.StartedAt) {
                        task.StartedAt = shiftDateByDays(new Date(task.StartedAt), shiftDays);
                        mutatedScalar = true;
                    }
                } else if (dueDateMode === 'clear') {
                    task.DueAt = null;
                    mutatedScalar = true;
                }

                if (startDateMode === 'set' && parsedStartedAt) {
                    task.StartedAt = parsedStartedAt;
                    mutatedScalar = true;
                } else if (startDateMode === 'clear') {
                    task.StartedAt = null;
                    mutatedScalar = true;
                }

                if (organizationMode === 'set') {
                    task.OrganizationID = targetOrganizationID;
                    mutatedScalar = true;
                } else if (organizationMode === 'clear') {
                    task.OrganizationID = null;
                    mutatedScalar = true;
                }

                if (categoryMode === 'set') {
                    task.CategoryID = targetCategoryID;
                    mutatedScalar = true;
                } else if (categoryMode === 'clear') {
                    task.CategoryID = null;
                    mutatedScalar = true;
                }

                if (targetTypeID) {
                    task.TypeID = targetTypeID;
                    mutatedScalar = true;
                }

                if (targetTaskTypeStatusID) {
                    task.TaskTypeStatusID = targetTaskTypeStatusID;
                    mutatedScalar = true;
                }

                if (mutatedScalar && task.Dirty) {
                    const saved = await task.Save();
                    if (!saved) {
                        failures.push({
                            TaskID: taskID,
                            Error: task.LatestResult?.CompleteMessage ?? 'Failed saving task.',
                        });
                        continue;
                    }
                }

                if (assigneeMode !== 'unchanged') {
                    const existingAssignRes = await rv.RunView<mjBizAppsTasksTaskAssignmentEntity>({
                        EntityName: 'MJ_BizApps_Tasks: Task Assignments',
                        ExtraFilter: `TaskID = '${taskID}'`,
                        ResultType: 'entity_object',
                    }, user);
                    if (!existingAssignRes.Success) {
                        failures.push({
                            TaskID: taskID,
                            Error: existingAssignRes.ErrorMessage || 'Failed loading existing task assignments.',
                        });
                        continue;
                    }
                    const existingAssignments = existingAssignRes.Results ?? [];
                    const matchesTarget = (a: mjBizAppsTasksTaskAssignmentEntity): boolean =>
                        assigneeEntityID !== null &&
                        assigneeRecordID !== null &&
                        a.AssigneeEntityID.toLowerCase() === assigneeEntityID.toLowerCase() &&
                        a.AssigneeRecordID.toLowerCase() === assigneeRecordID.toLowerCase();

                    if (assigneeMode === 'clear') {
                        for (const existing of existingAssignments) {
                            await existing.Delete();
                        }
                    } else if (assigneeMode === 'replace' && assigneeEntityID && assigneeRecordID) {
                        let alreadyPresent = false;
                        for (const existing of existingAssignments) {
                            if (matchesTarget(existing) && !alreadyPresent) {
                                alreadyPresent = true;
                            } else {
                                await existing.Delete();
                            }
                        }
                        if (!alreadyPresent) {
                            const assignment = await provider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(
                                'MJ_BizApps_Tasks: Task Assignments',
                                user,
                            );
                            assignment.NewRecord();
                            assignment.TaskID = taskID;
                            assignment.AssigneeEntityID = assigneeEntityID;
                            assignment.AssigneeRecordID = assigneeRecordID;
                            if (assigneeRoleID) assignment.RoleID = assigneeRoleID;
                            const savedAssign = await assignment.Save();
                            if (!savedAssign) {
                                failures.push({
                                    TaskID: taskID,
                                    Error: assignment.LatestResult?.CompleteMessage ?? 'Failed saving replacement assignment.',
                                });
                                continue;
                            }
                        }
                    } else if (assigneeMode === 'add' && assigneeEntityID && assigneeRecordID) {
                        const alreadyPresent = existingAssignments.some(matchesTarget);
                        if (!alreadyPresent) {
                            const assignment = await provider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(
                                'MJ_BizApps_Tasks: Task Assignments',
                                user,
                            );
                            assignment.NewRecord();
                            assignment.TaskID = taskID;
                            assignment.AssigneeEntityID = assigneeEntityID;
                            assignment.AssigneeRecordID = assigneeRecordID;
                            if (assigneeRoleID) assignment.RoleID = assigneeRoleID;
                            const savedAssign = await assignment.Save();
                            if (!savedAssign) {
                                failures.push({
                                    TaskID: taskID,
                                    Error: assignment.LatestResult?.CompleteMessage ?? 'Failed adding task assignment.',
                                });
                                continue;
                            }
                        }
                    }
                }

                if (targetAddTagID) {
                    const existingTagRes = await rv.RunView<{ ID: string }>({
                        EntityName: 'MJ_BizApps_Tasks: Task Tag Links',
                        ExtraFilter: `TaskID = '${taskID}' AND TagID = '${targetAddTagID}'`,
                        Fields: ['ID'],
                        MaxRows: 1,
                        ResultType: 'simple',
                    }, user);
                    if (existingTagRes.Success && (existingTagRes.Results?.length ?? 0) === 0) {
                        const tagLink = await provider.GetEntityObject<mjBizAppsTasksTaskTagLinkEntity>(
                            'MJ_BizApps_Tasks: Task Tag Links',
                            user,
                        );
                        tagLink.NewRecord();
                        tagLink.TaskID = taskID;
                        tagLink.TagID = targetAddTagID;
                        const savedTag = await tagLink.Save();
                        if (!savedTag) {
                            failures.push({
                                TaskID: taskID,
                                Error: tagLink.LatestResult?.CompleteMessage ?? 'Failed attaching tag to task.',
                            });
                            continue;
                        }
                    }
                }

                updatedTaskIDs.push(taskID);
            } catch (err) {
                failures.push({
                    TaskID: taskID,
                    Error: err instanceof Error ? err.message : String(err),
                });
            }
        }

        return {
            TotalRequested: uniqueIds.length,
            UpdatedCount: updatedTaskIDs.length,
            FailedCount: failures.length,
            UpdatedTaskIDs: updatedTaskIDs,
            Failures: failures,
        };
    }
}

/**
 * Server-side implementation of `BizAppsTasks.InstantiateTemplate`.
 *
 * Hydrates a Task Template playbook on the server:
 *   - Topologically creates root + nested child tasks with relative `DueAt`
 *   - Stamps target `OrganizationID` (input override or template default) & `CategoryID`
 *   - Resolves and creates `TaskAssignment` rows from `RoleAssignments`
 *   - Recreates `TaskDependency` links between instantiated tasks
 */
@RegisterClass(BaseRemotableOperation, TASKS_INSTANTIATE_TEMPLATE_OP_KEY)
export class TasksInstantiateTemplateServerOperation extends TasksInstantiateTemplateOperation {
    protected override async InternalExecute(
        input: TasksInstantiateTemplateInput,
        provider: IMetadataProvider,
        user: UserInfo,
    ): Promise<TasksInstantiateTemplateOutput> {
        const templateID = assertUuid(input?.TemplateID ?? '', 'TemplateID');
        const startDate = parseIsoDate(input?.StartDate ?? '', 'StartDate');
        const inputOrgID = input?.OrganizationID ? assertUuid(input.OrganizationID, 'OrganizationID') : null;
        const inputCatID = input?.CategoryID ? assertUuid(input.CategoryID, 'CategoryID') : null;

        const template = await provider.GetEntityObject<mjBizAppsTasksTaskTemplateEntity>(
            'MJ_BizApps_Tasks: Task Templates',
            user,
        );
        const loadedTemplate = await template.InnerLoad(CompositeKey.FromID(templateID));
        if (!loadedTemplate) {
            throw new Error(`Task Template '${templateID}' not found.`);
        }

        const effectiveOrganizationID =
            input.OrganizationID !== undefined ? inputOrgID : (template.OrganizationID ?? null);
        const effectiveCategoryID =
            input.CategoryID !== undefined ? inputCatID : (template.CategoryID ?? null);

        const rv = RunView.FromMetadataProvider(provider);
        const itemsRes = await rv.RunView<TemplateItemRow>({
            EntityName: 'MJ_BizApps_Tasks: Task Template Items',
            ExtraFilter: `TemplateID = '${templateID}'`,
            Fields: ['ID', 'Name', 'Description', 'ParentItemID', 'Priority', 'DaysFromStart', 'HoursEstimated', 'Sequence'],
            OrderBy: 'Sequence ASC',
            ResultType: 'simple',
        }, user);

        if (!itemsRes.Success) {
            throw new Error(`Failed loading template items: ${itemsRes.ErrorMessage}`);
        }

        const items = itemsRes.Results ?? [];
        if (items.length === 0) {
            return {
                TemplateID: templateID,
                CreatedCount: 0,
                CreatedTaskIDs: [],
                OrganizationID: effectiveOrganizationID,
            };
        }

        // Resolve role placeholder assignments up front
        const roleMap = new Map<string, { entityID: string; recordID: string }>();
        for (const ra of input.RoleAssignments ?? []) {
            if (!ra.RoleID || !ra.EntityName || !ra.RecordID) continue;
            const entityInfo = provider.EntityByName(ra.EntityName.trim());
            if (!entityInfo) {
                throw new Error(`Unknown assignee EntityName '${ra.EntityName}' for RoleID '${ra.RoleID}'.`);
            }
            roleMap.set(ra.RoleID.toLowerCase(), {
                entityID: entityInfo.ID,
                recordID: ra.RecordID.trim(),
            });
        }

        // Batch-load item roles & item dependencies
        const itemIdList = items.map((i) => `'${assertUuid(i.ID, 'TemplateItemID')}'`).join(',');
        const [rolesRes, depsRes] = await Promise.all([
            roleMap.size > 0
                ? rv.RunView<TemplateItemRoleRow>({
                      EntityName: 'MJ_BizApps_Tasks: Task Template Item Roles',
                      ExtraFilter: `ItemID IN (${itemIdList})`,
                      Fields: ['ItemID', 'RoleID'],
                      ResultType: 'simple',
                  }, user)
                : Promise.resolve({ Success: true, Results: [] as TemplateItemRoleRow[] }),
            rv.RunView<TemplateItemDependencyRow>({
                EntityName: 'MJ_BizApps_Tasks: Task Template Item Dependencies',
                ExtraFilter: `ItemID IN (${itemIdList})`,
                Fields: ['ItemID', 'DependsOnItemID', 'DependencyType'],
                ResultType: 'simple',
            }, user),
        ]);

        const rolesByItem = new Map<string, string[]>();
        if (rolesRes.Success) {
            for (const row of rolesRes.Results ?? []) {
                const key = row.ItemID.toLowerCase();
                const list = rolesByItem.get(key) ?? [];
                list.push(row.RoleID);
                rolesByItem.set(key, list);
            }
        }

        const sortedItems = topologicalSortTemplateItems(items);
        const itemToTaskID = new Map<string, string>();
        const createdTaskIDs: string[] = [];

        for (const item of sortedItems) {
            const task = await provider.GetEntityObject<mjBizAppsTasksTaskEntity>(
                'MJ_BizApps_Tasks: Tasks',
                user,
            );
            task.NewRecord();
            task.Name = item.Name;
            task.Description = item.Description ?? null;
            task.Priority = item.Priority ?? 'Medium';
            task.HoursEstimated = item.HoursEstimated ?? null;
            task.Sequence = item.Sequence ?? 100;

            if (template.TypeID) task.TypeID = template.TypeID;
            if (effectiveCategoryID) task.CategoryID = effectiveCategoryID;
            if (effectiveOrganizationID) task.OrganizationID = effectiveOrganizationID;

            if (item.DaysFromStart != null) {
                task.DueAt = shiftDateByDays(startDate, item.DaysFromStart);
            }

            if (item.ParentItemID) {
                const parentTaskID = itemToTaskID.get(item.ParentItemID.toLowerCase());
                if (parentTaskID) {
                    task.ParentID = parentTaskID;
                }
            }

            const saved = await task.Save();
            if (!saved) {
                throw new Error(
                    `Failed creating task '${item.Name}' from template: ${task.LatestResult?.CompleteMessage ?? 'unknown error'}`,
                );
            }

            itemToTaskID.set(item.ID.toLowerCase(), task.ID);
            createdTaskIDs.push(task.ID);

            const itemRoleIds = rolesByItem.get(item.ID.toLowerCase()) ?? [];
            for (const roleID of itemRoleIds) {
                const mapped = roleMap.get(roleID.toLowerCase());
                if (!mapped) continue;
                const assignment = await provider.GetEntityObject<mjBizAppsTasksTaskAssignmentEntity>(
                    'MJ_BizApps_Tasks: Task Assignments',
                    user,
                );
                assignment.NewRecord();
                assignment.TaskID = task.ID;
                assignment.AssigneeEntityID = mapped.entityID;
                assignment.AssigneeRecordID = mapped.recordID;
                assignment.RoleID = roleID;
                await assignment.Save();
            }
        }

        if (depsRes.Success) {
            for (const dep of depsRes.Results ?? []) {
                const taskID = itemToTaskID.get(dep.ItemID.toLowerCase());
                const dependsOnTaskID = itemToTaskID.get(dep.DependsOnItemID.toLowerCase());
                if (!taskID || !dependsOnTaskID) continue;

                const taskDep = await provider.GetEntityObject<mjBizAppsTasksTaskDependencyEntity>(
                    'MJ_BizApps_Tasks: Task Dependencies',
                    user,
                );
                taskDep.NewRecord();
                taskDep.TaskID = taskID;
                taskDep.DependsOnTaskID = dependsOnTaskID;
                taskDep.DependencyType = dep.DependencyType ?? 'FinishToStart';
                await taskDep.Save();
            }
        }

        return {
            TemplateID: templateID,
            CreatedCount: createdTaskIDs.length,
            CreatedTaskIDs: createdTaskIDs,
            OrganizationID: effectiveOrganizationID,
        };
    }
}

const PERIOD_KEY_PATTERN = /^[A-Za-z0-9._-]{1,40}$/;

function buildPeriodMarker(periodKey: string, templateID: string): string {
    return `[Period:${periodKey}][Template:${templateID.toLowerCase()}]`;
}

/**
 * Server-side implementation of `BizAppsTasks.RunRecurringPlaybooks`.
 *
 * Idempotently launches a reusable playbook (such as Month-End Financial Close) across
 * explicit Organization IDs or every active mirrored internal Company
 * (`Organization.LinkedCompanyID IS NOT NULL`), guaranteeing zero duplicate task runs
 * for a given `(TemplateID, OrganizationID, PeriodKey)`.
 */
@RegisterClass(BaseRemotableOperation, TASKS_RUN_RECURRING_PLAYBOOKS_OP_KEY)
export class TasksRunRecurringPlaybooksServerOperation extends TasksRunRecurringPlaybooksOperation {
    protected override async InternalExecute(
        input: TasksRunRecurringPlaybooksInput,
        provider: IMetadataProvider,
        user: UserInfo,
    ): Promise<TasksRunRecurringPlaybooksOutput> {
        const templateID = assertUuid(input?.TemplateID ?? '', 'TemplateID');
        if (!input?.AnchorDate) {
            throw new Error('AnchorDate is required.');
        }
        parseIsoDate(input.AnchorDate, 'AnchorDate');

        const periodKey = (input?.PeriodKey ?? '').trim();
        if (!PERIOD_KEY_PATTERN.test(periodKey)) {
            throw new Error(
                `Invalid PeriodKey '${input?.PeriodKey ?? ''}'. Expected 1–40 alphanumeric/._- characters (e.g., '2026-12' or '2026-Q4').`,
            );
        }

        const dryRun = Boolean(input.DryRun);
        const rv = RunView.FromMetadataProvider(provider);

        // Resolve target organizations
        const targetOrgs: Array<{ ID: string; Name: string }> = [];
        const explicitIds = Array.isArray(input.OrganizationIDs)
            ? input.OrganizationIDs.map((id) => assertUuid(id, 'OrganizationID'))
            : [];

        if (explicitIds.length > 0) {
            const seen = new Set<string>();
            const deduped = explicitIds.filter((id) => {
                const lower = id.toLowerCase();
                if (seen.has(lower)) return false;
                seen.add(lower);
                return true;
            });
            const inClause = deduped.map((id) => `'${id}'`).join(', ');
            const orgsRes = await rv.RunView<{ ID: string; Name: string }>({
                EntityName: 'MJ_BizApps_Common: Organizations',
                ExtraFilter: `ID IN (${inClause})`,
                Fields: ['ID', 'Name'],
                OrderBy: 'Name ASC',
                ResultType: 'simple',
            }, user);
            if (!orgsRes.Success) {
                throw new Error(`Failed loading target Organizations: ${orgsRes.ErrorMessage ?? 'unknown error'}`);
            }
            for (const row of orgsRes.Results ?? []) {
                targetOrgs.push({ ID: row.ID, Name: row.Name });
            }
        } else if (input.AllMirroredCompanies !== false) {
            const orgsRes = await rv.RunView<{ ID: string; Name: string }>({
                EntityName: 'MJ_BizApps_Common: Organizations',
                ExtraFilter: "LinkedCompanyID IS NOT NULL AND (Status IS NULL OR Status = 'Active')",
                Fields: ['ID', 'Name'],
                OrderBy: 'Name ASC',
                ResultType: 'simple',
            }, user);
            if (!orgsRes.Success) {
                throw new Error(`Failed loading mirrored Company Organizations: ${orgsRes.ErrorMessage ?? 'unknown error'}`);
            }
            for (const row of orgsRes.Results ?? []) {
                targetOrgs.push({ ID: row.ID, Name: row.Name });
            }
        }

        const marker = buildPeriodMarker(periodKey, templateID);
        // Quote-doubling alone leaves `%`, `_` and `[` live as LIKE wildcards, and
        // PERIOD_KEY_PATTERN permits `_` — so a key like `2026_12` would also match
        // `2026-12` and wrongly skip a playbook run. Bracket-escape the wildcards too.
        const escapedMarker = marker.replace(/'/g, "''").replace(/[[%_]/g, '[$&]');
        const results: RecurringPlaybookOrgResult[] = [];
        let launchedCount = 0;
        let skippedCount = 0;
        let failedCount = 0;
        let totalTasksCreated = 0;

        const instantiateRunner = new TasksInstantiateTemplateServerOperation();

        for (const org of targetOrgs) {
            try {
                const existingRes = await rv.RunView<{ ID: string }>({
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: `OrganizationID='${org.ID}' AND Description LIKE '%${escapedMarker}%'`,
                    Fields: ['ID'],
                    MaxRows: 1,
                    ResultType: 'simple',
                }, user);

                if (existingRes.Success && (existingRes.Results?.length ?? 0) > 0) {
                    skippedCount++;
                    results.push({
                        OrganizationID: org.ID,
                        OrganizationName: org.Name,
                        Status: 'skipped',
                        CreatedCount: 0,
                        CreatedTaskIDs: [],
                        Reason: `Already instantiated for period '${periodKey}'.`,
                    });
                    continue;
                }

                if (dryRun) {
                    results.push({
                        OrganizationID: org.ID,
                        OrganizationName: org.Name,
                        Status: 'dry-run',
                        CreatedCount: 0,
                        CreatedTaskIDs: [],
                        Reason: `Would launch template for '${org.Name}' (${periodKey}).`,
                    });
                    continue;
                }

                const instRes = await instantiateRunner['InternalExecute'](
                    {
                        TemplateID: templateID,
                        StartDate: input.AnchorDate,
                        CategoryID: input.CategoryID ?? null,
                        OrganizationID: org.ID,
                        RoleAssignments: input.RoleAssignments ?? [],
                    },
                    provider,
                    user,
                );

                // Stamp the idempotency marker on the first created root task so re-runs skip cleanly
                if (instRes.CreatedTaskIDs.length > 0) {
                    const rootTask = await provider.GetEntityObject<mjBizAppsTasksTaskEntity>(
                        'MJ_BizApps_Tasks: Tasks',
                        user,
                    );
                    const loaded = await rootTask.InnerLoad(CompositeKey.FromID(instRes.CreatedTaskIDs[0]));
                    if (loaded) {
                        const existingDesc = (rootTask.Description ?? '').trim();
                        rootTask.Description = existingDesc ? `${existingDesc}\n\n${marker}` : marker;
                        await rootTask.Save();
                    }
                }

                launchedCount++;
                totalTasksCreated += instRes.CreatedCount;
                results.push({
                    OrganizationID: org.ID,
                    OrganizationName: org.Name,
                    Status: 'created',
                    CreatedCount: instRes.CreatedCount,
                    CreatedTaskIDs: instRes.CreatedTaskIDs,
                });
            } catch (err) {
                failedCount++;
                results.push({
                    OrganizationID: org.ID,
                    OrganizationName: org.Name,
                    Status: 'failed',
                    CreatedCount: 0,
                    CreatedTaskIDs: [],
                    Reason: err instanceof Error ? err.message : String(err),
                });
            }
        }

        return {
            TemplateID: templateID,
            PeriodKey: periodKey,
            AnchorDate: input.AnchorDate,
            DryRun: dryRun,
            TargetOrganizations: targetOrgs.length,
            LaunchedCount: launchedCount,
            SkippedCount: skippedCount,
            FailedCount: failedCount,
            TotalTasksCreated: totalTasksCreated,
            Results: results,
        };
    }
}
