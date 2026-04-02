import { Component, ElementRef, EventEmitter, Input, Output, OnInit, OnDestroy, ViewChild, AfterViewInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RunView } from '@memberjunction/core';
import { gantt } from 'dhtmlx-gantt';

/**
 * Gantt chart visualization using the DHTMLX Gantt library.
 *
 * Renders tasks as bars on a timeline with:
 * - **Hierarchy**: parent/child relationships shown via indented tree
 * - **Dependencies**: FinishToStart, StartToStart, FinishToFinish, StartToFinish
 *   link arrows between task bars
 * - **Progress**: filled portion of each bar reflects PercentComplete
 * - **Columns**: Task name (tree), start date, duration (days), percent complete
 *
 * The chart is read-only by default. Cancelled tasks are excluded.
 * Task bars are computed from StartedAt/DueAt; if StartedAt is missing,
 * a 7-day default duration before DueAt is used.
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
    imports: [CommonModule],
    template: `
        <div #ganttContainer class="gantt-container"></div>
    `,
    styles: [`
        .gantt-container { width: 100%; height: 500px; }
    `]
})
export class TaskGanttComponent implements OnInit, AfterViewInit, OnDestroy {
    /** @internal Reference to the DOM element where DHTMLX Gantt is mounted. */
    @ViewChild('ganttContainer', { static: true }) ganttContainer!: ElementRef;

    // ── Inputs ──────────────────────────────────────────────

    /**
     * Filter chart to a specific category. Pass a TaskCategory ID to scope
     * the view, or `null` to show all tasks.
     */
    @Input() CategoryID: string | null = null;

    /**
     * Additional SQL WHERE clause filter appended to the task query.
     */
    @Input() ExtraFilter: string | null = null;

    /**
     * CSS height for the Gantt container. Accepts any valid CSS height value.
     * @default '500px'
     */
    @Input() Height: string = '500px';

    // ── Outputs ─────────────────────────────────────────────

    /**
     * Emitted when a task bar or row is clicked on the chart.
     * Payload is the task ID. Consuming apps should open a detail panel in response.
     */
    @Output() TaskClicked = new EventEmitter<string>();

    // ── Internal State ──────────────────────────────────────

    /** @internal */
    private initialized = false;

    // ── Lifecycle ───────────────────────────────────────────

    ngOnInit(): void {
        gantt.config.date_format = '%Y-%m-%d %H:%i';
        gantt.config.columns = [
            { name: 'text', label: 'Task', tree: true, width: 280 },
            { name: 'start_date', label: 'Start', align: 'center', width: 90 },
            { name: 'duration', label: 'Days', align: 'center', width: 60 },
            { name: 'progress', label: '%', align: 'center', width: 50,
              template: (obj: any) => Math.round((obj.progress || 0) * 100) + '%' },
        ];
        gantt.config.open_tree_initially = true;
        gantt.config.readonly = true;
    }

    ngAfterViewInit(): void {
        this.ganttContainer.nativeElement.style.height = this.Height;
        gantt.init(this.ganttContainer.nativeElement);
        this.initialized = true;

        gantt.attachEvent('onTaskClick', (id: string) => {
            this.TaskClicked.emit(id);
            return true;
        });

        this.LoadData();
    }

    ngOnDestroy(): void {
        if (this.initialized) {
            gantt.clearAll();
        }
    }

    // ── Public Methods ──────────────────────────────────────

    /**
     * Reloads task and dependency data from the server and re-renders the chart.
     * Call this after external changes to refresh the Gantt view.
     */
    Refresh(): void { this.LoadData(); }

    // ── Data Loading ────────────────────────────────────────

    /** @internal */
    private async LoadData(): Promise<void> {
        if (!this.initialized) return;

        const rv = new RunView();
        const filters: string[] = ["Status <> 'Cancelled'"];
        if (this.CategoryID) filters.push(`CategoryID = '${this.CategoryID}'`);
        if (this.ExtraFilter) filters.push(this.ExtraFilter);

        const [tasksResult, depsResult] = await Promise.all([
            rv.RunView<any>({
                EntityName: 'MJ.BizApps.Tasks: Tasks',
                ExtraFilter: filters.join(' AND '),
                OrderBy: 'Sequence ASC',
                ResultType: 'simple',
            }),
            new RunView().RunView<any>({
                EntityName: 'MJ.BizApps.Tasks: Task Dependencies',
                ResultType: 'simple',
            }),
        ]);

        const tasks = tasksResult?.Results ?? [];
        const deps = depsResult?.Results ?? [];

        const data = tasks.map((t: any) => {
            const startDate = t.StartedAt ? new Date(t.StartedAt) : (t.DueAt ? new Date(new Date(t.DueAt).getTime() - 7 * 86400000) : new Date());
            const endDate = t.DueAt ? new Date(t.DueAt) : new Date(startDate.getTime() + 7 * 86400000);
            const duration = Math.max(1, Math.ceil((endDate.getTime() - startDate.getTime()) / 86400000));

            return {
                id: t.ID,
                text: t.Name,
                start_date: this.formatDate(startDate),
                duration,
                progress: (t.PercentComplete ?? 0) / 100,
                parent: t.ParentID || 0,
                open: true,
            };
        });

        const taskIDs = new Set(tasks.map((t: any) => t.ID));
        const links = deps
            .filter((d: any) => taskIDs.has(d.TaskID) && taskIDs.has(d.DependsOnTaskID))
            .map((d: any) => ({
                id: d.ID,
                source: d.DependsOnTaskID,
                target: d.TaskID,
                type: this.mapDependencyType(d.DependencyType),
            }));

        gantt.clearAll();
        gantt.parse({ data, links });
    }

    /** @internal Formats a Date to the DHTMLX Gantt date format. */
    private formatDate(d: Date): string {
        const y = d.getFullYear();
        const m = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        return `${y}-${m}-${day} 00:00`;
    }

    /** @internal Maps BizAppsTasks dependency types to DHTMLX Gantt link type codes. */
    private mapDependencyType(type: string): string {
        switch (type) {
            case 'FinishToStart': return '0';
            case 'StartToStart': return '1';
            case 'FinishToFinish': return '2';
            case 'StartToFinish': return '3';
            default: return '0';
        }
    }
}