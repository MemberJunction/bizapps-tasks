import {
    CompositeKey,
    EntityTransactionScope,
    IEntityDataProvider,
    IMetadataProvider,
    IRunViewProvider,
    Metadata,
    RunView,
    UserInfo,
} from "@memberjunction/core";
import { EscapeSQLString, IsValidUUID } from "@memberjunction/global";
import type {
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskTemplateEntity,
    mjBizAppsTasksTaskTemplateItemEntity,
} from "@mj-biz-apps/tasks-entities";

/** A provider that can instantiate entities and run views. */
export type TaskTemplateProvider = IMetadataProvider & IRunViewProvider;

interface TransactionalProvider extends IEntityDataProvider {
    SupportsEntityTransactions: true;
    BeginEntityTransaction(): Promise<EntityTransactionScope>;
}

function isTransactionalProvider(provider: unknown): provider is TransactionalProvider {
    const candidate = provider as Partial<IEntityDataProvider> | null | undefined;
    return candidate?.SupportsEntityTransactions === true && typeof candidate.BeginEntityTransaction === 'function';
}

/**
 * Service for instantiating tasks from templates.
 *
 * "Create from Template" hydrates real Task records from a TaskTemplate:
 *   - Converts DaysFromStart offsets to actual DueAt dates
 *   - Recreates the sub-task hierarchy (ParentID)
 *   - Recreates dependencies between tasks via `task.Dependencies`
 *   - Creates TaskAssignment rows for pre-defined roles via `task.Assignments`
 *   - Loads template items + roles + dependencies in a single batched `IncludeRelatedRecords` query
 *   - Wraps multi-task instantiation in `BeginEntityTransaction()` when supported by the provider
 */
export class TaskTemplateService {

    /**
     * Instantiates a full set of Tasks from a template.
     *
     * @param params      - Template instantiation parameters
     * @param contextUser - Optional caller UserInfo for multi-user server isolation
     * @param provider    - Optional metadata/view/transaction provider (defaults to Metadata.Provider)
     * @returns The created Task entities (root-level + children)
     */
    async instantiateTemplate(
        params: {
            templateID: string;
            startDate: Date;
            categoryID?: string;
            assigneeMap?: Map<string, { entityID: string; recordID: string }>;
        },
        contextUser?: UserInfo,
        provider?: TaskTemplateProvider,
    ): Promise<mjBizAppsTasksTaskEntity[]> {
        const { templateID, startDate, categoryID, assigneeMap } = params;
        if (!IsValidUUID(templateID)) {
            throw new Error(`Invalid templateID '${templateID}'`);
        }

        const md: IMetadataProvider = provider ?? Metadata.Provider;
        const rv = new RunView(provider);

        // 1. Load the template
        const template = await md.GetEntityObject<mjBizAppsTasksTaskTemplateEntity>(
            'MJ_BizApps_Tasks: Task Templates',
            contextUser,
        );
        const pk = new CompositeKey([{ FieldName: 'ID', Value: templateID }]);
        const templateLoaded = await template.InnerLoad(pk);
        if (!templateLoaded) {
            throw new Error(`Task template '${templateID}' not found`);
        }

        // 2. Load all template items with their Roles and Dependencies batched in one 1+2 RunView call
        const itemsResult = await rv.RunView<mjBizAppsTasksTaskTemplateItemEntity>({
            EntityName: 'MJ_BizApps_Tasks: Task Template Items',
            ExtraFilter: `TemplateID = '${EscapeSQLString(templateID)}'`,
            OrderBy: 'Sequence ASC',
            ResultType: 'entity_object',
            IncludeRelatedRecords: ['Roles', 'Dependencies'],
        }, contextUser);
        if (!itemsResult?.Success) {
            throw new Error(`Failed to load template items for '${templateID}': ${itemsResult?.ErrorMessage ?? 'unknown error'}`);
        }

        const items = itemsResult.Results ?? [];
        if (items.length === 0) return [];

        // Sort items so parents are created before children
        const sorted = this.topologicalSortByParent(items);

        // 3. Instantiate all tasks + assignments + dependencies inside one transaction when supported
        const txScope = isTransactionalProvider(md)
            ? await md.BeginEntityTransaction()
            : null;

        try {
            const itemToTask = new Map<string, mjBizAppsTasksTaskEntity>();
            const createdTasks: mjBizAppsTasksTaskEntity[] = [];

            for (const item of sorted) {
                const task = await md.GetEntityObject<mjBizAppsTasksTaskEntity>(
                    'MJ_BizApps_Tasks: Tasks',
                    contextUser,
                );
                task.NewRecord();
                task.Name = item.Name;
                task.Description = item.Description ?? null;
                task.Priority = item.Priority ?? 'Medium';
                task.HoursEstimated = item.HoursEstimated ?? null;
                task.Sequence = item.Sequence ?? 100;

                if (template.TypeID) {
                    task.TypeID = template.TypeID;
                }
                if (categoryID) {
                    task.CategoryID = categoryID;
                }

                if (item.DaysFromStart != null) {
                    const dueAt = new Date(startDate);
                    dueAt.setDate(dueAt.getDate() + item.DaysFromStart);
                    task.DueAt = dueAt;
                }

                if (item.ParentItemID && itemToTask.has(item.ParentItemID)) {
                    task.ParentID = itemToTask.get(item.ParentItemID)!.ID;
                }

                // Attach assignments from pre-loaded item.Roles onto task.Assignments
                if (assigneeMap && assigneeMap.size > 0) {
                    for (const role of item.Roles?.Items ?? []) {
                        const assignee = assigneeMap.get(role.RoleID);
                        if (!assignee) continue;
                        const assignment = await task.Assignments.Create();
                        assignment.AssigneeEntityID = assignee.entityID;
                        assignment.AssigneeRecordID = assignee.recordID;
                        assignment.RoleID = role.RoleID;
                    }
                }

                if (!(await task.Save())) {
                    throw new Error(
                        `Failed to create task "${item.Name}" from template ${templateID}: ${task.LatestResult?.CompleteMessage ?? 'unknown error'}`,
                    );
                }

                itemToTask.set(item.ID, task);
                createdTasks.push(task);
            }

            // 4. Attach dependencies from pre-loaded item.Dependencies onto each task's Dependencies collection
            for (const item of sorted) {
                const deps = item.Dependencies?.Items ?? [];
                if (deps.length === 0) continue;

                const targetTask = itemToTask.get(item.ID);
                if (!targetTask) continue;

                let addedDeps = 0;
                for (const dep of deps) {
                    const dependsOnTask = itemToTask.get(dep.DependsOnItemID);
                    if (!dependsOnTask) continue;

                    const taskDep = await targetTask.Dependencies.Create();
                    taskDep.DependsOnTaskID = dependsOnTask.ID;
                    taskDep.DependencyType = dep.DependencyType ?? 'FinishToStart';
                    addedDeps += 1;
                }

                if (addedDeps > 0 && !(await targetTask.Save())) {
                    throw new Error(
                        `Failed to save dependencies for task "${targetTask.Name}" from template ${templateID}: ${targetTask.LatestResult?.CompleteMessage ?? 'unknown error'}`,
                    );
                }
            }

            if (txScope) {
                await txScope.Commit();
            }
            return createdTasks;
        } catch (err) {
            if (txScope) {
                await txScope.Rollback();
            }
            throw err;
        }
    }

    /**
     * Sort template items so that parents come before children (iterative topological sort).
     */
    private topologicalSortByParent(
        items: readonly mjBizAppsTasksTaskTemplateItemEntity[],
    ): mjBizAppsTasksTaskTemplateItemEntity[] {
        const result: mjBizAppsTasksTaskTemplateItemEntity[] = [];
        const remaining = [...items];
        const placed = new Set<string>();

        // First pass: items with no parent
        for (let i = remaining.length - 1; i >= 0; i--) {
            if (!remaining[i].ParentItemID) {
                placed.add(remaining[i].ID);
                result.push(remaining[i]);
                remaining.splice(i, 1);
            }
        }

        // Subsequent passes: place items whose parent is already placed
        let maxIterations = remaining.length + 1;
        while (remaining.length > 0 && maxIterations-- > 0) {
            for (let i = remaining.length - 1; i >= 0; i--) {
                const parentID = remaining[i].ParentItemID;
                if (parentID && placed.has(parentID)) {
                    placed.add(remaining[i].ID);
                    result.push(remaining[i]);
                    remaining.splice(i, 1);
                }
            }
        }

        // Any remaining items (orphans) go at the end
        result.push(...remaining);
        return result;
    }
}
