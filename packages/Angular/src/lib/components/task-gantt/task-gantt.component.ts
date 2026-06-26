import { Component, EventEmitter, Input, Output, OnInit, ChangeDetectionStrategy, ChangeDetectorRef, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RunView } from '@memberjunction/core';
import { MjGanttChartComponent, GanttItemData, GanttLinkData, GanttItemClickedEvent } from '@memberjunction/ng-gantt';

/**
 * Task-specific Gantt chart that wraps the generic `<mj-gantt-chart>`.
 *
 * Loads tasks and dependencies from BizAppsTasks entities, maps them
 * to the generic Gantt interfaces, and emits click events.
 *
 * @example
 * ```html
 * <bizapps-task-gantt
 *     [CategoryID]="committeeCategoryId"
 *     [Height]="'600px'"
 *     (TaskClicked)="openDetailPanel($event)">
 * </bizapps-task-gantt>
 * ```
 */
@Component({
    selector: 'bizapps-task-gantt',
    standalone: true,
    imports: [CommonModule, MjGanttChartComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <mj-gantt-chart
            [Items]="items"
            [Links]="links"
            [Height]="Height"
            [ReadOnly]="ReadOnly"
            [ShowProgress]="true"
            (ItemClicked)="onItemClicked($event)">
        </mj-gantt-chart>
    `
})
export class TaskGanttComponent implements OnInit {
    @Input() CategoryID: string | null = null;
    @Input() ExtraFilter: string | null = null;
    @Input() Height = '500px';
    @Input() ReadOnly = true;

    @Output() TaskClicked = new EventEmitter<string>();

    items: GanttItemData[] = [];
    links: GanttLinkData[] = [];
    private cdr = inject(ChangeDetectorRef);

    ngOnInit(): void { this.LoadData(); }

    Refresh(): void { this.LoadData(); }

    async LoadData(): Promise<void> {
        const rv = new RunView();
        const filters: string[] = ["Status <> 'Cancelled'"];
        if (this.CategoryID) filters.push(`CategoryID = '${this.CategoryID}'`);
        if (this.ExtraFilter) filters.push(this.ExtraFilter);

        const [tasksResult, depsResult] = await Promise.all([
            rv.RunView<{
                ID: string;
                Name: string;
                StartedAt: string | null;
                DueAt: string | null;
                PercentComplete: number;
                ParentID: string | null;
            }>({
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                ExtraFilter: filters.join(' AND '),
                OrderBy: 'Sequence ASC',
                ResultType: 'simple',
            }),
            new RunView().RunView<{
                ID: string;
                TaskID: string;
                DependsOnTaskID: string;
                DependencyType: string;
            }>({
                EntityName: 'MJ_BizApps_Tasks: Task Dependencies',
                ResultType: 'simple',
            }),
        ]);

        const tasks = tasksResult?.Results ?? [];
        const deps = depsResult?.Results ?? [];

        this.items = tasks.map((t) => {
            const startDate = t.StartedAt ? new Date(t.StartedAt) : (t.DueAt ? new Date(new Date(t.DueAt).getTime() - 7 * 86400000) : new Date());
            const endDate = t.DueAt ? new Date(t.DueAt) : undefined;
            const duration = endDate ? undefined : 7;

            return {
                ID: t.ID,
                Name: t.Name,
                StartDate: startDate,
                EndDate: endDate,
                Duration: duration,
                Progress: t.PercentComplete ?? 0,
                ParentID: t.ParentID || undefined,
                Data: t,
            } as GanttItemData;
        });

        const taskIDs = new Set(tasks.map((t) => t.ID));
        this.links = deps
            .filter((d) => taskIDs.has(d.TaskID) && taskIDs.has(d.DependsOnTaskID))
            .map((d) => ({
                ID: d.ID,
                SourceID: d.DependsOnTaskID,
                TargetID: d.TaskID,
                Type: this.mapDependencyType(d.DependencyType),
            } as GanttLinkData));

        this.cdr.markForCheck();
    }

    onItemClicked(event: GanttItemClickedEvent): void {
        this.TaskClicked.emit(event.Item.ID);
    }

    private mapDependencyType(type: string): 'FS' | 'SS' | 'FF' | 'SF' {
        switch (type) {
            case 'FinishToStart': return 'FS';
            case 'StartToStart': return 'SS';
            case 'FinishToFinish': return 'FF';
            case 'StartToFinish': return 'SF';
            default: return 'FS';
        }
    }
}
