import { Component, EventEmitter, Input, Output, OnInit, OnChanges, SimpleChanges, ChangeDetectionStrategy, ChangeDetectorRef, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RunView } from '@memberjunction/core';
import { MjGanttChartComponent, GanttItemData, GanttLinkData, GanttItemClickedEvent, GanttColumnDef } from '@memberjunction/ng-gantt';

/**
 * Task-specific Gantt chart that wraps the generic `<mj-gantt-chart>`.
 *
 * Loads tasks and dependencies from BizAppsTasks entities, maps them
 * to the generic Gantt interfaces, and emits click events.
 *
 * Supports global views, category scopes, and sub-task parent scopes.
 *
 * @example
 * ```html
 * <!-- Full Category Gantt -->
 * <bizapps-task-gantt
 *     [CategoryID]="categoryId"
 *     [Height]="'600px'"
 *     (TaskClicked)="openDetailPanel($event)">
 * </bizapps-task-gantt>
 *
 * <!-- Single Task Sub-Tasks Breakdown -->
 * <bizapps-task-gantt
 *     [ParentTaskID]="task.ID"
 *     [IncludeParentSummary]="true"
 *     [Height]="'350px'">
 * </bizapps-task-gantt>
 * ```
 */
@Component({
    selector: 'bizapps-task-gantt',
    standalone: true,
    imports: [CommonModule, MjGanttChartComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="mjt-gantt-wrap">
            @if (ShowToolbar) {
                <div class="mjt-gantt-toolbar">
                    <div class="mjt-gantt-legend">
                        <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--open"></span> Open</span>
                        <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--prog"></span> In Progress</span>
                        <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--done"></span> Completed</span>
                        <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--blocked"></span> Blocked</span>
                    </div>
                </div>
            }

            @if (items.length === 0 && !loading) {
                <div class="mjt-gantt-empty">
                    <i class="fa-solid fa-chart-gantt"></i>
                    <span>No tasks with schedule dates found to plot on timeline.</span>
                </div>
            } @else {
                <mj-gantt-chart
                    [Items]="items"
                    [Links]="links"
                    [Columns]="Columns"
                    [Height]="Height"
                    [ReadOnly]="ReadOnly"
                    [ShowProgress]="true"
                    (ItemClicked)="onItemClicked($event)"
                    (ItemDoubleClicked)="onItemDoubleClicked($event)">
                </mj-gantt-chart>
            }
        </div>
    `,
    styles: [`
        :host { display: block; width: 100%; }
        .mjt-gantt-wrap { display: flex; flex-direction: column; gap: 8px; width: 100%; position: relative; }
        .mjt-gantt-toolbar {
            display: flex; align-items: center; justify-content: space-between;
            padding: 6px 12px; background: var(--mj-bg-surface-sunken, #f8fafc);
            border: 1px solid var(--mj-border-default, #e2e8f0); border-radius: var(--mj-radius-sm, 6px);
            font-size: 11.5px;
        }
        .mjt-gantt-legend { display: flex; align-items: center; gap: 12px; }
        .mjt-legend-item { display: inline-flex; align-items: center; gap: 5px; color: var(--mj-text-secondary, #475569); font-weight: 500; }
        .mjt-dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; }
        .mjt-dot--open { background: #0284c7; }
        .mjt-dot--prog { background: #3b82f6; }
        .mjt-dot--done { background: #16a34a; }
        .mjt-dot--blocked { background: #ef4444; }
        .mjt-gantt-empty {
            padding: 36px 16px; text-align: center; color: var(--mj-text-muted, #64748b);
            display: flex; flex-direction: column; align-items: center; gap: 8px; font-size: 13px;
            background: var(--mj-bg-surface-sunken, #f8fafc); border: 1px dashed var(--mj-border-default, #cbd5e1);
            border-radius: var(--mj-radius-md, 8px);
        }
        .mjt-gantt-empty i { font-size: 24px; color: var(--mj-text-muted, #94a3b8); }
    `]
})
export class TaskGanttComponent implements OnInit, OnChanges {
    @Input() CategoryID: string | null = null;
    @Input() ParentTaskID: string | null = null;
    @Input() IncludeParentSummary = true;
    @Input() ExtraFilter: string | null = null;
    @Input() Height = '500px';
    @Input() ReadOnly = true;
    @Input() ShowToolbar = true;
    @Input() Columns: GanttColumnDef[] | null = null;

    @Output() TaskClicked = new EventEmitter<string>();
    @Output() TaskDoubleClicked = new EventEmitter<string>();

    public items: GanttItemData[] = [];
    public links: GanttLinkData[] = [];
    public loading = false;

    private cdr = inject(ChangeDetectorRef);

    ngOnInit(): void {
        this.LoadData();
    }

    ngOnChanges(changes: SimpleChanges): void {
        if (changes['CategoryID'] || changes['ParentTaskID'] || changes['ExtraFilter']) {
            this.LoadData();
        }
    }

    public Refresh(): void {
        this.LoadData();
    }

    public async LoadData(): Promise<void> {
        this.loading = true;
        this.cdr.markForCheck();
        try {
            const rv = new RunView();
            const filters: string[] = ["Status <> 'Cancelled'"];

            if (this.ParentTaskID) {
                if (this.IncludeParentSummary) {
                    filters.push(`(ID = '${this.ParentTaskID}' OR ParentID = '${this.ParentTaskID}' OR RootParentID = '${this.ParentTaskID}')`);
                } else {
                    filters.push(`(ParentID = '${this.ParentTaskID}' OR RootParentID = '${this.ParentTaskID}')`);
                }
            } else {
                if (this.CategoryID) filters.push(`CategoryID = '${this.CategoryID}'`);
                if (this.ExtraFilter) filters.push(this.ExtraFilter);
            }

            const [tasksResult, depsResult] = await Promise.all([
                rv.RunView<{
                    ID: string;
                    Name: string;
                    StartedAt: string | null;
                    DueAt: string | null;
                    PercentComplete: number;
                    ParentID: string | null;
                    Status: string;
                    Priority: string;
                    Sequence: number;
                }>({
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: filters.join(' AND '),
                    OrderBy: 'Sequence ASC',
                    ResultType: 'simple',
                    MaxRows: 500,
                }),
                new RunView().RunView<{
                    ID: string;
                    TaskID: string;
                    DependsOnTaskID: string;
                    DependencyType: string;
                }>({
                    EntityName: 'MJ_BizApps_Tasks: Task Dependencies',
                    ResultType: 'simple',
                    MaxRows: 500,
                }),
            ]);

            const tasks = tasksResult?.Results ?? [];
            const deps = depsResult?.Results ?? [];

            this.items = tasks.map((t) => {
                const startDate = t.StartedAt ? new Date(t.StartedAt) : (t.DueAt ? new Date(new Date(t.DueAt).getTime() - 7 * 86400000) : new Date());
                const endDate = t.DueAt ? new Date(t.DueAt) : undefined;
                const duration = endDate ? undefined : 7;
                const isParentRoot = this.ParentTaskID && t.ID.toLowerCase() === this.ParentTaskID.toLowerCase();

                return {
                    ID: t.ID,
                    Name: t.Name,
                    StartDate: startDate,
                    EndDate: endDate,
                    Duration: duration,
                    Progress: t.PercentComplete ?? 0,
                    ParentID: isParentRoot ? undefined : (t.ParentID || undefined),
                    Open: true,
                    Data: t,
                } as GanttItemData;
            });

            const taskIDs = new Set(tasks.map((t) => t.ID.toLowerCase()));
            this.links = deps
                .filter((d) => taskIDs.has(d.TaskID.toLowerCase()) && taskIDs.has(d.DependsOnTaskID.toLowerCase()))
                .map((d) => ({
                    ID: d.ID,
                    SourceID: d.DependsOnTaskID,
                    TargetID: d.TaskID,
                    Type: this.mapDependencyType(d.DependencyType),
                } as GanttLinkData));
        } finally {
            this.loading = false;
            this.cdr.markForCheck();
        }
    }

    public onItemClicked(event: GanttItemClickedEvent): void {
        if (event.Item?.ID) {
            this.TaskClicked.emit(event.Item.ID);
        }
    }

    public onItemDoubleClicked(event: GanttItemClickedEvent): void {
        if (event.Item?.ID) {
            this.TaskDoubleClicked.emit(event.Item.ID);
        }
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
