import { BaseEntity, CompositeKey, Metadata, RunView } from "@memberjunction/core";

/**
 * Service for instantiating tasks from templates.
 *
 * "Create from Template" hydrates real Task records from a TaskTemplate:
 *   - Converts DaysFromStart offsets to actual DueAt dates
 *   - Recreates the sub-task hierarchy (ParentID)
 *   - Recreates dependencies between tasks
 *   - Creates placeholder TaskAssignment rows for pre-defined roles
 */
export class TaskTemplateService {

    /**
     * Instantiates a full set of Tasks from a template.
     *
     * @param templateID  - The TaskTemplate to instantiate
     * @param startDate   - The reference date for DaysFromStart calculations
     * @param categoryID  - Optional category to assign to all created tasks
     * @param assigneeMap - Optional map of RoleID → { entityID, recordID } for
     *                      filling in role placeholders with real assignees
     * @returns The created Task entities (root-level + children)
     */
    async instantiateTemplate(params: {
        templateID: string;
        startDate: Date;
        categoryID?: string;
        assigneeMap?: Map<string, { entityID: string; recordID: string }>;
    }): Promise<BaseEntity[]> {
        const { templateID, startDate, categoryID, assigneeMap } = params;
        const rv = new RunView();

        // 1. Load the template
        const template = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Task Templates');
        const pk = new CompositeKey([{ FieldName: 'ID', Value: templateID }]);
        await template.InnerLoad(pk);

        // 2. Load all template items
        const itemsResult = await rv.RunView<BaseEntity>({
            EntityName: 'MJ.BizApps.Tasks: Task Template Items',
            ExtraFilter: `TemplateID = '${templateID}'`,
            OrderBy: 'Sequence ASC',
            ResultType: 'simple',
        });
        const items = itemsResult?.Results ?? [];
        if (items.length === 0) return [];

        // 3. Create tasks from items, maintaining a map of templateItemID → new taskID
        const itemToTaskID = new Map<string, string>();
        const createdTasks: BaseEntity[] = [];

        // Sort items so parents are created before children
        const sorted = this.topologicalSortByParent(items);

        for (const item of sorted) {
            const itemID = (item as any).ID as string;
            const task = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Tasks');
            task.NewRecord();
            task.Set('Name', (item as any).Name);
            task.Set('Description', (item as any).Description ?? null);
            task.Set('Priority', (item as any).Priority ?? 'Medium');
            task.Set('HoursEstimated', (item as any).HoursEstimated ?? null);
            task.Set('Sequence', (item as any).Sequence ?? 100);

            // Set type and category from template defaults
            const typeID = template.Get('TypeID') as string | null;
            if (typeID) task.Set('TypeID', typeID);
            if (categoryID) task.Set('CategoryID', categoryID);

            // Calculate DueAt from DaysFromStart
            const daysFromStart = (item as any).DaysFromStart as number | null;
            if (daysFromStart != null) {
                const dueAt = new Date(startDate);
                dueAt.setDate(dueAt.getDate() + daysFromStart);
                task.Set('DueAt', dueAt);
            }

            // Wire up parent task
            const parentItemID = (item as any).ParentItemID as string | null;
            if (parentItemID && itemToTaskID.has(parentItemID)) {
                task.Set('ParentID', itemToTaskID.get(parentItemID)!);
            }

            await task.Save();
            const newTaskID = task.Get('ID') as string;
            itemToTaskID.set(itemID, newTaskID);
            createdTasks.push(task);

            // 4. Create assignments from template item roles
            await this.createAssignmentsForItem(itemID, newTaskID, assigneeMap);
        }

        // 5. Create dependencies between the new tasks
        await this.createDependencies(templateID, itemToTaskID);

        return createdTasks;
    }

    /**
     * Sort template items so that parents come before children (simple iterative approach).
     */
    private topologicalSortByParent(items: any[]): any[] {
        const result: any[] = [];
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
                if (placed.has(remaining[i].ParentItemID)) {
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

    /**
     * Creates TaskAssignment records for a newly created task based on
     * the template item's pre-defined roles.
     */
    private async createAssignmentsForItem(
        templateItemID: string,
        taskID: string,
        assigneeMap?: Map<string, { entityID: string; recordID: string }>,
    ): Promise<void> {
        if (!assigneeMap || assigneeMap.size === 0) return;

        const rv = new RunView();
        const rolesResult = await rv.RunView<BaseEntity>({
            EntityName: 'MJ.BizApps.Tasks: Task Template Item Roles',
            ExtraFilter: `ItemID = '${templateItemID}'`,
            ResultType: 'simple',
        });

        for (const role of rolesResult?.Results ?? []) {
            const roleID = (role as any).RoleID as string;
            const assignee = assigneeMap.get(roleID);
            if (!assignee) continue;

            const assignment = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Task Assignments');
            assignment.NewRecord();
            assignment.Set('TaskID', taskID);
            assignment.Set('AssigneeEntityID', assignee.entityID);
            assignment.Set('AssigneeRecordID', assignee.recordID);
            assignment.Set('RoleID', roleID);
            await assignment.Save();
        }
    }

    /**
     * Recreates the dependency graph between newly instantiated tasks
     * based on the template's TaskTemplateItemDependency records.
     */
    private async createDependencies(
        templateID: string,
        itemToTaskID: Map<string, string>,
    ): Promise<void> {
        const rv = new RunView();

        // Get all template items for this template (we need their IDs to filter deps)
        const itemsResult = await rv.RunView<BaseEntity>({
            EntityName: 'MJ.BizApps.Tasks: Task Template Items',
            ExtraFilter: `TemplateID = '${templateID}'`,
            ResultType: 'simple',
        });
        const itemIDs = (itemsResult?.Results ?? []).map((i: any) => `'${i.ID}'`).join(',');
        if (!itemIDs) return;

        const depsResult = await rv.RunView<BaseEntity>({
            EntityName: 'MJ.BizApps.Tasks: Task Template Item Dependencies',
            ExtraFilter: `ItemID IN (${itemIDs})`,
            ResultType: 'simple',
        });

        for (const dep of depsResult?.Results ?? []) {
            const itemID = (dep as any).ItemID as string;
            const dependsOnItemID = (dep as any).DependsOnItemID as string;
            const taskID = itemToTaskID.get(itemID);
            const dependsOnTaskID = itemToTaskID.get(dependsOnItemID);
            if (!taskID || !dependsOnTaskID) continue;

            const taskDep = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Task Dependencies');
            taskDep.NewRecord();
            taskDep.Set('TaskID', taskID);
            taskDep.Set('DependsOnTaskID', dependsOnTaskID);
            taskDep.Set('DependencyType', (dep as any).DependencyType ?? 'FinishToStart');
            await taskDep.Save();
        }
    }
}
