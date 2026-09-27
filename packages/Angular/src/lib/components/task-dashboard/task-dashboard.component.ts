import { Component, EventEmitter, Input, Output, ViewChild, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BaseEntity } from '@memberjunction/core';
import { OpenTaskRecord } from '../../open-task-record';
import { TaskPanelComponent, TaskViewMode } from '../task-panel/task-panel.component';
import { TaskTemplateWizardComponent } from '../task-template-wizard/task-template-wizard.component';
import type { TaskListComponent } from '../task-list/task-list.component';
import type { TaskKanbanComponent } from '../task-kanban/task-kanban.component';
import type { TaskGanttComponent } from '../task-gantt/task-gantt.component';
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
        TaskPanelComponent,
        TaskTemplateWizardComponent,
    ],
    template: `
        <div class="dashboard">
            <!-- Main content area -->
            <div class="dashboard-main">
                <!-- Toolbar -->
                <div class="toolbar">
                    <h2 class="dashboard-title">
                        <i class="fa-solid fa-list-check"></i> Tasks
                    </h2>
                    <div class="toolbar-actions">
                        <button class="btn-template" (click)="openPanel('template')">
                            <i class="fa-solid fa-copy"></i> From Template
                        </button>
                        <button class="btn-create" (click)="openCreateTask()">
                            + New Task
                        </button>
                    </div>
                </div>

                <bizapps-task-panel
                    #taskPanel
                    [CategoryID]="CategoryID"
                    [ExtraFilter]="ExtraFilter"
                    [PersonID]="PersonID"
                    [ShowDelete]="ShowDelete"
                    [AllowedViewModes]="EnabledViews"
                    [ViewMode]="viewMode"
                    (ViewModeChange)="viewMode = $event"
                    [GanttHeight]="'calc(100vh - 140px)'"
                    (TaskSelected)="TaskSelected.emit($event)"
                    (TaskDoubleClicked)="onOpenFullRecord($event)"
                    (OpenRecordRequested)="onOpenFullRecord($event)">
                </bizapps-task-panel>
            </div>

            <!-- Slide-in panel overlay for template wizard -->
            @if (panelMode === 'template') {
                <div class="panel-backdrop" (click)="closePanel()"></div>
                <div class="side-panel">
                    <bizapps-task-template-wizard
                        [DefaultCategoryID]="CategoryID"
                        (Created)="onTemplateCreated($event)"
                        (Cancelled)="closePanel()">
                    </bizapps-task-template-wizard>
                </div>
            }
        </div>
    `,
    styles: [`
        :host { display: block; position: relative; }
        .dashboard { height: 100%; }
        .dashboard-main { padding: 16px; overflow: auto; }
        .panel-backdrop {
            position: fixed; inset: 0; background: var(--mj-bg-overlay);
            z-index: 999; animation: fadeIn 0.15s ease;
        }
        .side-panel {
            position: fixed; top: 0; right: 0; bottom: 0;
            width: 520px; max-width: 90vw;
            background: var(--mj-bg-surface); z-index: 1000;
            box-shadow: var(--mj-shadow-lg);
            overflow-y: auto;
            animation: slideIn 0.2s ease;
        }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        @keyframes slideIn { from { transform: translateX(100%); } to { transform: translateX(0); } }
        .toolbar {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 16px; flex-wrap: wrap; gap: 8px;
        }
        .dashboard-title {
            margin: 0; font-size: 1.3rem; font-weight: var(--mj-font-semibold); color: var(--mj-text-primary);
            display: flex; align-items: center; gap: 8px;
        }
        .toolbar-actions { display: flex; gap: 8px; align-items: center; }
        .btn-create {
            padding: 6px 14px; border: none; border-radius: var(--mj-radius-md);
            background: var(--mj-brand-primary); color: var(--mj-text-inverse); font-size: 0.85rem; cursor: pointer;
            font-weight: var(--mj-font-medium); font-family: inherit;
        }
        .btn-template {
            padding: 6px 14px; border: 1px solid var(--mj-border-strong); border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface); font-size: 0.85rem; cursor: pointer;
            display: flex; align-items: center; gap: 4px; font-family: inherit;
        }
    `]
})
export class TaskDashboardComponent implements OnInit {
    // ── Inputs ──────────────────────────────────────────────

    /**
     * Filter all views (list, kanban, gantt) to a specific category.
     * Pass `null` to show all tasks across categories.
     */
    @Input() CategoryID: string | null = null;

    /**
     * Additional SQL WHERE clause filter applied to all views.
     */
    @Input() ExtraFilter: string | null = null;

    /**
     * PersonID of the currently logged-in user. Passed to the detail panel
     * for attributing comments, and to the template wizard for assignee defaults.
     */
    @Input() PersonID: string | null = null;

    /**
     * Which views to make available in the toggle. Pass a subset to hide views.
     * The first enabled view becomes the default. If only one view is enabled
     * the toggle is hidden entirely.
     * @default ['list', 'kanban', 'gantt']
     */
    @Input() EnabledViews: TaskViewMode[] = ['list', 'kanban', 'gantt'];

    /**
     * Whether to show the delete control in the task detail panel.
     * Host apps pass this based on the current user's permissions.
     * @default false
     */
    @Input() ShowDelete = false;

    /** @internal */
    get enabledViewCount(): number { return this.EnabledViews.length; }

    // ── Outputs ─────────────────────────────────────────────

    /**
     * Emitted when a task is selected (clicked) in any view. Payload is the task ID.
     */
    @Output() TaskSelected = new EventEmitter<string>();

    /**
     * Emitted when a task is double clicked. Payload is the task ID.
     */
    @Output() TaskDoubleClicked = new EventEmitter<string>();

    /**
     * Emitted when open full record is requested from detail panel or double-click.
     */
    @Output() OpenRecordRequested = new EventEmitter<string>();

    // ── View References ─────────────────────────────────────

    /** @internal */
    @ViewChild('taskPanel') taskPanel?: TaskPanelComponent;

    get taskList(): TaskListComponent | undefined { return this.taskPanel?.taskList; }
    get taskKanban(): TaskKanbanComponent | undefined { return this.taskPanel?.taskKanban; }
    get taskGantt(): TaskGanttComponent | undefined { return this.taskPanel?.taskGantt; }

    // ── Internal State ──────────────────────────────────────

    /** @internal Current active view tab. */
    viewMode: TaskViewMode = 'list';

    ngOnInit(): void {
        // Default to the first enabled view
        if (this.EnabledViews.length > 0 && !this.EnabledViews.includes(this.viewMode)) {
            this.viewMode = this.EnabledViews[0];
        }
    }

    /** @internal Current slide-in panel state. */
    panelMode: PanelMode = 'none';

    // ── Public Methods ──────────────────────────────────────

    /**
     * Refreshes whichever view is currently active (list, kanban, or gantt).
     */
    RefreshCurrentView(): void {
        this.taskPanel?.Refresh();
    }

    /**
     * Programmatically opens the detail panel for a specific task.
     * @param taskID - The task to display.
     */
    OpenDetailPanel(taskID: string): void {
        this.taskPanel?.OpenDetail(taskID);
    }

    /**
     * Programmatically opens the edit panel. Pass a task ID to edit,
     * or `null` to create a new task.
     * @param taskID - The task to edit, or `null` for new.
     */
    OpenEditPanel(taskID: string | null): void {
        this.taskPanel?.OpenEdit(taskID);
    }

    /**
     * Closes any open slide-in panel (detail, edit, or template wizard).
     */
    ClosePanel(): void {
        this.taskPanel?.Close();
        this.closePanel();
    }

    // ── Internal Event Handlers ─────────────────────────────

    /** @internal */
    openCreateTask(): void {
        this.taskPanel?.OpenEdit(null);
    }

    /** @internal */
    openPanel(mode: PanelMode, taskID?: string | null): void {
        if (mode === 'template') {
            this.panelMode = 'template';
        } else if (mode === 'detail' && taskID) {
            this.taskPanel?.OpenDetail(taskID);
        } else if (mode === 'edit') {
            this.taskPanel?.OpenEdit(taskID ?? null);
        } else {
            this.closePanel();
        }
    }

    /** @internal */
    closePanel(): void {
        this.panelMode = 'none';
    }

    /** @internal */
    onTemplateCreated(_tasks: BaseEntity[]): void {
        this.closePanel();
        this.RefreshCurrentView();
    }

    /** @internal */
    onOpenFullRecord(taskID: string | null): void {
        if (!taskID) return;
        this.TaskDoubleClicked.emit(taskID);
        this.OpenRecordRequested.emit(taskID);
        OpenTaskRecord(taskID);
    }
}
