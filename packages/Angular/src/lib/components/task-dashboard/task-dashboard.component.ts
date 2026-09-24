import { Component, EventEmitter, Input, Output, ViewChild, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { OpenTaskRecord } from '../../open-task-record';
import { TaskListComponent, TaskRow } from '../task-list/task-list.component';
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
        <div class="dashboard">
            <!-- Main content area -->
            <div class="dashboard-main">
                <!-- Toolbar -->
                <div class="toolbar">
                    <h2 class="dashboard-title">
                        <i class="fa-solid fa-list-check"></i> Tasks
                    </h2>
                    <div class="toolbar-actions">
                        @if (enabledViewCount > 1) {
                            <div class="view-toggle">
                                @if (EnabledViews.includes('list')) {
                                    <button [class.active]="viewMode === 'list'" (click)="viewMode = 'list'">
                                        <i class="fa-solid fa-list"></i> List
                                    </button>
                                }
                                @if (EnabledViews.includes('kanban')) {
                                    <button [class.active]="viewMode === 'kanban'" (click)="viewMode = 'kanban'">
                                        <i class="fa-solid fa-columns"></i> Board
                                    </button>
                                }
                                @if (EnabledViews.includes('gantt')) {
                                    <button [class.active]="viewMode === 'gantt'" (click)="viewMode = 'gantt'">
                                        <i class="fa-solid fa-chart-gantt"></i> Gantt
                                    </button>
                                }
                            </div>
                        }
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
                        (TaskDoubleClicked)="onOpenFullRecord($event.ID)"
                        (CreateTask)="openPanel('edit', null)">
                    </bizapps-task-list>
                }
                @if (viewMode === 'kanban') {
                    <bizapps-task-kanban
                        #taskKanban
                        [CategoryID]="CategoryID"
                        [ExtraFilter]="ExtraFilter"
                        (TaskClicked)="openPanel('detail', $event)"
                        (TaskDoubleClicked)="onOpenFullRecord($event)">
                    </bizapps-task-kanban>
                }
                @if (viewMode === 'gantt') {
                    <bizapps-task-gantt
                        #taskGantt
                        [CategoryID]="CategoryID"
                        [ExtraFilter]="ExtraFilter"
                        [Height]="'calc(100vh - 140px)'"
                        (TaskDoubleClicked)="openPanel('detail', $event)">
                    </bizapps-task-gantt>
                }
            </div>

            <!-- Slide-in panel overlay -->
            @if (panelMode !== 'none') {
                <div class="panel-backdrop" (click)="closePanel()"></div>
                <div class="side-panel">
                    @if (panelMode === 'detail') {
                        <bizapps-task-detail-panel
                            [TaskID]="selectedTaskID"
                            [PersonID]="PersonID"
                            [ShowDelete]="ShowDelete"
                            (EditRequested)="openPanel('edit', $event)"
                            (OpenRecordRequested)="onOpenFullRecord($event)"
                            (DeleteRequested)="onTaskDeleted()"
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
        .view-toggle {
            display: inline-flex; border: 1px solid var(--mj-border-strong); border-radius: var(--mj-radius-md); overflow: hidden;
        }
        .view-toggle button {
            padding: 6px 12px; border: none; background: var(--mj-bg-surface); font-size: 0.85rem;
            cursor: pointer; display: flex; align-items: center; gap: 4px;
            border-right: 1px solid var(--mj-border-strong); font-family: inherit;
        }
        .view-toggle button:last-child { border-right: none; }
        .view-toggle button.active { background: var(--mj-brand-primary); color: var(--mj-text-inverse); }
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
/**
 * Full-featured Tasks dashboard combining list, kanban, and gantt views
 * with a view toggle toolbar, slide-in detail/edit panels, and template wizard.
 *
 * Designed to be registered as a standalone MJ Application with its own nav
 * entry, or embedded within any consuming app's layout. Internally composes
 * {@link TaskListComponent}, {@link TaskKanbanComponent}, {@link TaskGanttComponent},
 * {@link TaskDetailPanelComponent}, {@link TaskEditPanelComponent}, and
 * {@link TaskTemplateWizardComponent}.
 *
 * @example
 * ```html
 * <bizapps-task-dashboard
 *     [CategoryID]="committeeCategoryId"
 *     [PersonID]="currentUserPersonID"
 *     (TaskSelected)="onTaskOpened($event)">
 * </bizapps-task-dashboard>
 * ```
 */
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
    @Input() EnabledViews: ViewMode[] = ['list', 'kanban', 'gantt'];

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
    @ViewChild('taskList') taskList?: TaskListComponent;
    /** @internal */
    @ViewChild('taskKanban') taskKanban?: TaskKanbanComponent;
    /** @internal */
    @ViewChild('taskGantt') taskGantt?: TaskGanttComponent;

    // ── Internal State ──────────────────────────────────────

    /** @internal Current active view tab. */
    viewMode: ViewMode = 'list';

    ngOnInit(): void {
        // Default to the first enabled view
        if (this.EnabledViews.length > 0 && !this.EnabledViews.includes(this.viewMode)) {
            this.viewMode = this.EnabledViews[0];
        }
    }
    /** @internal Current slide-in panel state. */
    panelMode: PanelMode = 'none';
    /** @internal Task ID for the open detail/edit panel, or null for new task. */
    selectedTaskID: string | null = null;

    // ── Public Methods ──────────────────────────────────────

    /**
     * Refreshes whichever view is currently active (list, kanban, or gantt).
     */
    RefreshCurrentView(): void {
        this.taskList?.Refresh();
        this.taskKanban?.Refresh();
        this.taskGantt?.Refresh();
    }

    /**
     * Programmatically opens the detail panel for a specific task.
     * @param taskID - The task to display.
     */
    OpenDetailPanel(taskID: string): void {
        this.openPanel('detail', taskID);
    }

    /**
     * Programmatically opens the edit panel. Pass a task ID to edit,
     * or `null` to create a new task.
     * @param taskID - The task to edit, or `null` for new.
     */
    OpenEditPanel(taskID: string | null): void {
        this.openPanel('edit', taskID);
    }

    /**
     * Closes any open slide-in panel (detail, edit, or template wizard).
     */
    ClosePanel(): void {
        this.closePanel();
    }

    // ── Internal Event Handlers ─────────────────────────────

    /** @internal */
    onTaskSelected(task: TaskRow): void {
        this.openPanel('detail', task.ID);
        this.TaskSelected.emit(task.ID);
    }

    /** @internal */
    openPanel(mode: PanelMode, taskID?: string | null): void {
        this.panelMode = mode;
        this.selectedTaskID = taskID ?? null;
    }

    /** @internal */
    closePanel(): void {
        this.panelMode = 'none';
        this.selectedTaskID = null;
    }

    /** @internal */
    onTaskSaved(_taskID: string): void {
        this.closePanel();
        this.RefreshCurrentView();
    }

    /** @internal */
    onTaskDeleted(): void {
        this.closePanel();
        this.RefreshCurrentView();
    }

    /** @internal */
    onTemplateCreated(_tasks: any[]): void {
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
