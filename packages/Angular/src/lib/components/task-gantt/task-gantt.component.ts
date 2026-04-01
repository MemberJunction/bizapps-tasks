import { Component, ElementRef, EventEmitter, Input, Output, OnInit, OnDestroy, ViewChild, AfterViewInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RunView } from '@memberjunction/core';
import { gantt } from 'dhtmlx-gantt';

/**
 * Gantt chart using DHTMLX Gantt library with data mapper for BizAppsTasks entities.
 * Shows task hierarchy, dependencies, and timeline.
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
    @ViewChild('ganttContainer', { static: true }) ganttContainer!: ElementRef;

    @Input() CategoryID: string | null = null;
    @Input() ExtraFilter: string | null = null;
    @Input() Height: string = '500px';

    @Output() TaskClicked = new EventEmitter<string>();

    private initialized = false;

    ngOnInit(): void {
        // Configure gantt before init
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

        this.loadData();
    }

    ngOnDestroy(): void {
        if (this.initialized) {
            gantt.clearAll();
        }
    }

    Refresh(): void { this.loadData(); }

    private async loadData(): Promise<void> {
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

        // Map tasks to DHTMLX format
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

        // Map dependencies — filter to only include deps where both tasks are in view
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

    private formatDate(d: Date): string {
        const y = d.getFullYear();
        const m = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        return `${y}-${m}-${day} 00:00`;
    }

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
