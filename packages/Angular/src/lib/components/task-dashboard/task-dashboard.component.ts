import { Component, EventEmitter, Input, Output, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TaskListComponent, TaskRow, BeforeTaskSelectedEvent } from '../task-list/task-list.component';
import { TaskKanbanComponent } from '../task-kanban/task-kanban.component';
import { TaskGanttComponent } from '../task-gantt/task-gantt.component';
import { TaskDetailPanelComponent } from '../task-detail-panel/task-detail-panel.component';
import { TaskEditPanelComponent } from '../task-edit-panel/task-edit-panel.component';
import { TaskTemplateWizardComponent } from '../task-template-wizard/task-template-wizard.component';

type ViewMode = 'list' | 'kanban' | 'gantt';
type PanelMode = 'none' | 'detail' | 'edit' | 'template';

/**
 * Full Tasks dashboard — combines list + kanban + gantt views with a view toggle,
 * plus slide-in detail/edit panels and template wizard.
 *
 * Register as an MJ Application component for standalone navigation.
 */
@Component({
    selector: 'bizapps-task-dashboard',
    standalone: true,
    imports: [
        CommonModule,
        TaskListComponent, TaskKanbanComponent, TaskGanttComponent,
        TaskDetailPanelComponent, TaskEditPanelComponent, TaskTemplateWizardComponent,
    ],
    template: `
        <div class="dashboard" [class.panel-open]="panelMode !== 'none'">
            <!-- Main content area -->
            <div class="dashboard-main">
                <!-- Toolbar -->
                <div class="toolbar">
                    <h2 class="dashboard-title">
                        <i class="fa-solid fa-list-check"></i> Tasks
                    </h2>
                    <div class="toolbar-actions">
                        <div class="view-toggle">
                            <button [class.active]="viewMode === 'list'" (click)="viewMode = 'list'">
                                <i class="fa-solid fa-list"></i> List
                            </button>
                            <button [class.active]="viewMode === 'kanban'" (click)="viewMode = 'kanban'">
                                <i class="fa-solid fa-columns"></i> Board
                            </button>
                            <button [class.active]="viewMode === 'gantt'" (click)="viewMode = 'gantt'">
                                <i class="fa-solid fa-chart-gantt"></i> Gantt
                            </button>
                        </div>
                        <button class="btn-template" (click)="openPanel('template')">
                            <i class="fa-solid fa-copy"></i> From Template
                        </button>
                        <button class="btn-create" (click)="openPanel('edit', null)">
                            + New Task
                        </button>
                    </div>
                </div>

                <!-- Views -->
                @if (viewMode === 'list') {
                    <bizapps-task-list
                        #taskList
                        [CategoryID]="CategoryID"
                        [ExtraFilter]="ExtraFilter"
                        [ShowCreateButton]="false"
                        (AfterTaskSelected)="onTaskSelected($event)"
                        (CreateTask)="openPanel('edit', null)">
                    </bizapps-task-list>
                }
                @if (viewMode === 'kanban') {
                    <bizapps-task-kanban
                        #taskKanban
                        [CategoryID]="CategoryID"
                        [ExtraFilter]="ExtraFilter"
                        (TaskClicked)="openPanel('detail', $event)">
                    </bizapps-task-kanban>
                }
                @if (viewMode === 'gantt') {
                    <bizapps-task-gantt
                        #taskGantt
                        [CategoryID]="CategoryID"
                        [ExtraFilter]="ExtraFilter"
                        [Height]="'calc(100vh - 140px)'"
                        (TaskClicked)="openPanel('detail', $event)">
                    </bizapps-task-gantt>
                }
            </div>

            <!-- Side panel -->
            @if (panelMode !== 'none') {
                <div class="side-panel">
                    @if (panelMode === 'detail') {
                        <bizapps-task-detail-panel
                            [TaskID]="selectedTaskID"
                            [PersonID]="PersonID"
                            (EditRequested)="openPanel('edit', $event)"
                            (Close)="closePanel()">
                        </bizapps-task-detail-panel>
                    }
                    @if (panelMode === 'edit') {
                        <bizapps-task-edit-panel
                            [TaskID]="selectedTaskID"
                            [DefaultCategoryID]="CategoryID"
                            (Saved)="onTaskSaved($event)"
                            (Cancel)="closePanel()">
                        </bizapps-task-edit-panel>
                    }
                    @if (panelMode === 'template') {
                        <bizapps-task-template-wizard
                            [DefaultCategoryID]="CategoryID"
                            (Created)="onTemplateCreated($event)"
                            (Cancelled)="closePanel()">
                        </bizapps-task-template-wizard>
                    }
                </div>
            }
        </div>
    `,
    styles: [`
        .dashboard { display: flex; height: 100%; }
        .dashboard-main { flex: 1; min-width: 0; padding: 16px; overflow: auto; }
        .side-panel {
            width: 480px; flex-shrink: 0; border-left: 1px solid #e5e7eb;
            overflow-y: auto; background: #fff;
        }
        .toolbar {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 16px; flex-wrap: wrap; gap: 8px;
        }
        .dashboard-title {
            margin: 0; font-size: 1.3rem; font-weight: 600; color: #1f2937;
            display: flex; align-items: center; gap: 8px;
        }
        .toolbar-actions { display: flex; gap: 8px; align-items: center; }
        .view-toggle {
            display: inline-flex; border: 1px solid #d1d5db; border-radius: 6px; overflow: hidden;
        }
        .view-toggle button {
            padding: 6px 12px; border: none; background: #fff; font-size: 0.85rem;
            cursor: pointer; display: flex; align-items: center; gap: 4px;
            border-right: 1px solid #d1d5db;
        }
        .view-toggle button:last-child { border-right: none; }
        .view-toggle button.active { background: #4f46e5; color: #fff; }
        .btn-create {
            padding: 6px 14px; border: none; border-radius: 6px;
            background: #4f46e5; color: #fff; font-size: 0.85rem; cursor: pointer; font-weight: 500;
        }
        .btn-template {
            padding: 6px 14px; border: 1px solid #d1d5db; border-radius: 6px;
            background: #fff; font-size: 0.85rem; cursor: pointer;
            display: flex; align-items: center; gap: 4px;
        }
        @media (max-width: 768px) {
            .dashboard { flex-direction: column; }
            .side-panel { width: 100%; border-left: none; border-top: 1px solid #e5e7eb; }
        }
    `]
})
export class TaskDashboardComponent {
    @Input() CategoryID: string | null = null;
    @Input() ExtraFilter: string | null = null;
    @Input() PersonID: string | null = null;

    @Output() TaskSelected = new EventEmitter<string>();

    @ViewChild('taskList') taskList?: TaskListComponent;
    @ViewChild('taskKanban') taskKanban?: TaskKanbanComponent;
    @ViewChild('taskGantt') taskGantt?: TaskGanttComponent;

    viewMode: ViewMode = 'list';
    panelMode: PanelMode = 'none';
    selectedTaskID: string | null = null;

    onTaskSelected(task: TaskRow): void {
        this.openPanel('detail', task.ID);
        this.TaskSelected.emit(task.ID);
    }

    openPanel(mode: PanelMode, taskID?: string | null): void {
        this.panelMode = mode;
        this.selectedTaskID = taskID ?? null;
    }

    closePanel(): void {
        this.panelMode = 'none';
        this.selectedTaskID = null;
    }

    onTaskSaved(taskID: string): void {
        this.closePanel();
        this.refreshCurrentView();
    }

    onTemplateCreated(tasks: any[]): void {
        this.closePanel();
        this.refreshCurrentView();
    }

    private refreshCurrentView(): void {
        this.taskList?.Refresh();
        this.taskKanban?.Refresh();
        this.taskGantt?.Refresh();
    }
}
