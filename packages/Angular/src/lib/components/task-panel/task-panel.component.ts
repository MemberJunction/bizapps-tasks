import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, inject, Input, Output, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { OpenTaskRecord } from '../../open-task-record';
import { TaskListComponent, TaskRow, BeforeTaskSelectedEvent, BeforeStatusChangeEvent } from '../task-list/task-list.component';
import { TaskKanbanComponent, BeforeKanbanStatusChangeEvent, AfterKanbanStatusChangeEvent } from '../task-kanban/task-kanban.component';
import { TaskGanttComponent } from '../task-gantt/task-gantt.component';
import { TaskDetailPanelComponent, BeforeCommentPostedEvent } from '../task-detail-panel/task-detail-panel.component';
import { TaskEditPanelComponent, BeforeTaskSaveEvent } from '../task-edit-panel/task-edit-panel.component';

import { TaskViewMode } from '../../pages/tasks-dashboard.page';

/** The current mode of the slide-in side panel. */
export type TaskPanelMode = 'none' | 'detail' | 'edit';

/**
 * Cancellable event emitted before the panel opens for a task.
 * Set `Cancel = true` to prevent the panel from opening — useful when
 * you want to handle the task click with your own custom behavior instead.
 *
 * @example
 * ```ts
 * onBeforeOpen(event: BeforePanelOpenEvent) {
 *     if (event.Mode === 'detail') {
 *         event.Cancel = true;
 *         this.myCustomDetailView(event.TaskID);
 *     }
 * }
 * ```
 */
export class BeforePanelOpenEvent {
    /** Set to `true` to prevent the panel from opening. */
    Cancel = false;
    constructor(
        /** The panel mode that is about to open. */
        public Mode: TaskPanelMode,
        /** The task ID, or `null` for a new task. */
        public TaskID: string | null
    ) {}
}

/**
 * Cancellable event emitted before the panel closes.
 * Set `Cancel = true` to prevent the panel from closing — useful for
 * "unsaved changes" confirmation flows.
 */
export class BeforePanelCloseEvent {
    /** Set to `true` to prevent the panel from closing. */
    Cancel = false;
}

/**
 * Lightweight composite widget that wires a {@link TaskListComponent} together
 * with {@link TaskDetailPanelComponent} and {@link TaskEditPanelComponent}
 * in a single drop-in tag.
 *
 * **This is the recommended starting point** for embedding task management in
 * a consuming app. It handles the common flow:
 * - Click a task → detail panel slides in
 * - Click "Edit" in detail → edit panel replaces detail
 * - Click "+ New Task" → edit panel opens blank
 * - Save/close → panel dismisses, list refreshes
 *
 * Every interaction emits a cancellable Before event, so consuming apps can
 * intercept any step and substitute their own behavior. All granular components
 * ({@link TaskListComponent}, {@link TaskDetailPanelComponent},
 * {@link TaskEditPanelComponent}) are also published individually for full
 * custom wiring.
 *
 * @example Basic drop-in usage:
 * ```html
 * <bizapps-task-panel
 *     [CategoryID]="committeeCategoryId"
 *     [ShowCreateButton]="isOfficer"
 *     [PersonID]="currentUserPersonID">
 * </bizapps-task-panel>
 * ```
 *
 * @example Intercepting task selection:
 * ```html
 * <bizapps-task-panel
 *     [CategoryID]="committeeCategoryId"
 *     (BeforePanelOpen)="onBeforeOpen($event)">
 * </bizapps-task-panel>
 * ```
 * ```ts
 * onBeforeOpen(event: BeforePanelOpenEvent) {
 *     // Use your own detail view instead of the built-in panel
 *     event.Cancel = true;
 *     this.router.navigate(['/tasks', event.TaskID]);
 * }
 * ```
 *
 * @example Listening to saves without intercepting:
 * ```html
 * <bizapps-task-panel
 *     (AfterTaskSaved)="showToast('Task saved!')"
 *     (AfterCommentPosted)="refreshActivityFeed()">
 * </bizapps-task-panel>
 * ```
 */
@Component({
    selector: 'bizapps-task-panel',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [CommonModule, TaskListComponent, TaskKanbanComponent, TaskGanttComponent, TaskDetailPanelComponent, TaskEditPanelComponent],
    template: `
        <div class="task-panel-host">
            @if (AllowedViewModes && AllowedViewModes.length > 1) {
                <div class="task-panel-toolbar">
                    <div class="view-switch-group" role="group" aria-label="Task view mode">
                        @if (AllowedViewModes.includes('list')) {
                            <button
                                type="button"
                                class="view-switch-btn"
                                [class.active]="ViewMode === 'list'"
                                (click)="setViewMode('list')"
                                title="List View"
                            >
                                <i class="fa-solid fa-list"></i>
                                <span>List</span>
                            </button>
                        }
                        @if (AllowedViewModes.includes('kanban')) {
                            <button
                                type="button"
                                class="view-switch-btn"
                                [class.active]="ViewMode === 'kanban'"
                                (click)="setViewMode('kanban')"
                                title="Board View"
                            >
                                <i class="fa-solid fa-table-columns"></i>
                                <span>Board</span>
                            </button>
                        }
                        @if (AllowedViewModes.includes('gantt')) {
                            <button
                                type="button"
                                class="view-switch-btn"
                                [class.active]="ViewMode === 'gantt'"
                                (click)="setViewMode('gantt')"
                                title="Timeline View"
                            >
                                <i class="fa-solid fa-chart-gantt"></i>
                                <span>Timeline</span>
                            </button>
                        }
                    </div>
                </div>
            }

            <div class="task-panel-body">
                @switch (ViewMode) {
                    @case ('list') {
                        <div class="task-panel-list">
                            <bizapps-task-list
                                #taskList
                                [CategoryID]="CategoryID"
                                [ExtraFilter]="ExtraFilter"
                                [StatusFilter]="StatusFilter"
                                [ShowCreateButton]="ShowCreateButton"
                                [ShowQuickAdd]="ShowQuickAdd"
                                [QuickAddDefaultTypeID]="DefaultTypeID"
                                [AssigneeScope]="AssigneeScope"
                                [Compact]="Compact"
                                (BeforeTaskSelected)="onBeforeTaskSelected($event)"
                                (AfterTaskSelected)="onAfterTaskSelected($event)"
                                (BeforeStatusChange)="BeforeStatusChange.emit($event)"
                                (AfterStatusChange)="AfterStatusChange.emit($event)"
                                (AfterTaskCreated)="onAfterTaskCreated($event)"
                                (TaskDoubleClicked)="onOpenFullRecord($event.ID)"
                                (CreateTask)="onCreateTask()">
                            </bizapps-task-list>
                        </div>
                    }
                    @case ('kanban') {
                        <div class="task-panel-kanban">
                            <bizapps-task-kanban
                                #taskKanban
                                [CategoryID]="CategoryID"
                                [ExtraFilter]="ExtraFilter"
                                [ReadOnly]="ReadOnly"
                                (TaskClicked)="onTaskClicked($event)"
                                (TaskDoubleClicked)="onOpenFullRecord($event)"
                                (BeforeStatusChange)="BeforeKanbanStatusChange.emit($event)"
                                (AfterStatusChange)="onKanbanStatusChange($event)">
                            </bizapps-task-kanban>
                        </div>
                    }
                    @case ('gantt') {
                        <div class="task-panel-gantt">
                            <bizapps-task-gantt
                                #taskGantt
                                [CategoryID]="CategoryID"
                                [ExtraFilter]="ExtraFilter"
                                [Height]="GanttHeight"
                                [ReadOnly]="ReadOnly"
                                (TaskClicked)="onTaskClicked($event)"
                                (TaskDoubleClicked)="onOpenFullRecord($event)">
                            </bizapps-task-gantt>
                        </div>
                    }
                }
            </div>

            @if (panelMode !== 'none') {
                <div class="task-panel-backdrop" (click)="closePanel()"></div>
                <div class="task-panel-slide">
                    @if (panelMode === 'detail' && selectedTaskID) {
                        <bizapps-task-detail-panel
                            #detailPanel
                            [TaskID]="selectedTaskID"
                            [PersonID]="PersonID"
                            [ShowDelete]="ShowDelete"
                            [ReadOnly]="ReadOnly"
                            (EditRequested)="onEditRequested($event)"
                            (OpenRecordRequested)="onOpenFullRecord($event)"
                            (DeleteRequested)="onDeleteRequested($event)"
                            (BeforeCommentPosted)="BeforeCommentPosted.emit($event)"
                            (AfterCommentPosted)="AfterCommentPosted.emit()"
                            (Close)="closePanel()">
                        </bizapps-task-detail-panel>
                    }
                    @if (panelMode === 'edit') {
                        <bizapps-task-edit-panel
                            #editPanel
                            [TaskID]="selectedTaskID"
                            [DefaultCategoryID]="CategoryID"
                            [DefaultTypeID]="DefaultTypeID"
                            [AssigneeScope]="AssigneeScope"
                            [ParentTaskFilter]="ParentTaskFilter"
                            [ReadOnly]="ReadOnly"
                            (BeforeSave)="BeforeTaskSave.emit($event)"
                            (Saved)="onTaskSaved($event)"
                            (Cancel)="closePanel()">
                        </bizapps-task-edit-panel>
                    }
                </div>
            }
        </div>
    `,
    styles: [`
        :host { display: block; position: relative; }
        .task-panel-host { position: relative; display: flex; flex-direction: column; width: 100%; }
        .task-panel-toolbar {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            padding: 8px 12px;
            margin-bottom: 8px;
            border-bottom: 1px solid var(--mj-border-default, #e2e8f0);
            background: var(--mj-bg-surface, #ffffff);
        }
        .view-switch-group {
            display: inline-flex;
            border: 1px solid var(--mj-border-default, #cbd5e1);
            border-radius: 6px;
            overflow: hidden;
            background: var(--mj-bg-surface-sunken, #f8fafc);
        }
        .view-switch-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 12px;
            border: none;
            background: transparent;
            font-size: 12.5px;
            font-weight: 500;
            color: var(--mj-text-secondary, #64748b);
            cursor: pointer;
            transition: all 0.12s ease;
        }
        .view-switch-btn:hover {
            color: var(--mj-text-primary, #0f172a);
            background: var(--mj-bg-surface-hover, #f1f5f9);
        }
        .view-switch-btn.active {
            background: var(--mj-brand-primary, #0076b6);
            color: #ffffff;
        }
        .task-panel-body {
            position: relative;
            flex: 1 1 auto;
            min-height: 0;
            width: 100%;
        }
        .task-panel-list { position: relative; z-index: 1; }
        .task-panel-kanban, .task-panel-gantt {
            width: 100%;
            min-height: 450px;
        }

        .task-panel-backdrop {
            position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
            background: var(--mj-bg-overlay); z-index: 999;
            animation: fadeIn 0.2s ease;
        }
        .task-panel-slide {
            position: fixed; top: 0; right: 0; width: 480px; height: 100vh;
            background: var(--mj-bg-surface); z-index: 1000; overflow-y: auto;
            box-shadow: var(--mj-shadow-lg);
            animation: slideIn 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        }
        @keyframes slideIn {
            from { transform: translateX(100%); }
            to { transform: translateX(0); }
        }
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        @media (max-width: 768px) {
            .task-panel-slide { width: 100%; }
        }
    `]
})
export class TaskPanelComponent {
    // ── Inputs ──────────────────────────────────────────────

    /**
     * Filter tasks to a specific category. Passed through to the inner
     * {@link TaskListComponent} and used as the default for new tasks.
     */
    @Input() CategoryID: string | null = null;

    /**
     * Additional SQL WHERE clause filter. Passed through to the inner list.
     */
    @Input() ExtraFilter: string | null = null;

    /**
     * Pre-select a status filter on the list. Passed through.
     */
    @Input() StatusFilter: string | null = null;

    /**
     * Whether to show the "+ New Task" button. Typically bound to a permission check.
     * @default false
     */
    @Input() ShowCreateButton = false;

    /** Whether to show the delete button in the detail panel. @default false */
    @Input() ShowDelete = false;

    /**
     * Compact mode for the list. Passed through.
     * @default false
     */
    @Input() Compact = false;

    /**
     * Whether to show the quick-add inline input at the bottom of the list.
     * @default false
     */
    @Input() ShowQuickAdd = false;

    /**
     * PersonID of the current user. Used for comment attribution in the
     * detail panel and as a context hint for the edit panel.
     */
    @Input() PersonID: string | null = null;

    /**
     * Default task type for new tasks. Passed through to the edit panel.
     */
    @Input() DefaultTypeID: string | null = null;

    /**
     * Narrows the assignee picker in the edit panel. Accepts a SQL filter
     * string or an array of Person IDs. Passed through.
     */
    @Input() AssigneeScope: string | string[] | null = null;

    /**
     * Extra SQL filter for the edit panel's Parent Task list.
     * Passed through.
     */
    @Input() ParentTaskFilter: string | null = null;

    /**
     * Hides Edit, the comment box, and the edit panel's save.
     * @default false
     */
    @Input() ReadOnly = false;

    /**
     * Allowed view modes. If more than 1 mode is provided, a view-mode toggle toolbar is rendered.
     * @default ['list', 'kanban', 'gantt']
     */
    @Input() AllowedViewModes: TaskViewMode[] = ['list', 'kanban', 'gantt'];

    /**
     * The active view mode ('list' | 'kanban' | 'gantt').
     * @default 'list'
     */
    @Input() ViewMode: TaskViewMode = 'list';

    /**
     * Height for the Gantt chart when in 'gantt' view mode.
     * @default '600px'
     */
    @Input() GanttHeight = '600px';

    /**
     * Emitted when the user toggles the view mode.
     */
    @Output() ViewModeChange = new EventEmitter<TaskViewMode>();

    // ── Outputs (Before — cancellable) ──────────────────────

    /**
     * Emitted **before** the slide-in panel opens (for detail, edit, or new task).
     * Set `event.Cancel = true` to prevent the panel from opening and handle
     * the interaction yourself.
     */
    @Output() BeforePanelOpen = new EventEmitter<BeforePanelOpenEvent>();

    /**
     * Emitted **before** the slide-in panel closes. Set `event.Cancel = true`
     * to keep the panel open (e.g., for unsaved changes confirmation).
     */
    @Output() BeforePanelClose = new EventEmitter<BeforePanelCloseEvent>();

    /**
     * Re-emitted from the inner {@link TaskListComponent}. Cancellable.
     */
    @Output() BeforeTaskSelected = new EventEmitter<BeforeTaskSelectedEvent>();

    /**
     * Re-emitted from the inner {@link TaskListComponent}. Cancellable.
     */
    @Output() BeforeStatusChange = new EventEmitter<BeforeStatusChangeEvent>();

    /**
     * Re-emitted from the inner {@link TaskKanbanComponent}. Cancellable.
     */
    @Output() BeforeKanbanStatusChange = new EventEmitter<BeforeKanbanStatusChangeEvent>();

    /**
     * Emitted after a status change is persisted from the kanban board.
     */
    @Output() AfterKanbanStatusChange = new EventEmitter<AfterKanbanStatusChangeEvent>();

    /**
     * Re-emitted from the inner {@link TaskDetailPanelComponent}. Cancellable.
     */
    @Output() BeforeCommentPosted = new EventEmitter<BeforeCommentPostedEvent>();

    /**
     * Re-emitted from the inner {@link TaskEditPanelComponent}. Cancellable.
     */
    @Output() BeforeTaskSave = new EventEmitter<BeforeTaskSaveEvent>();

    // ── Outputs (After — informational) ─────────────────────

    /**
     * Emitted after a task is selected (clicked) in the list.
     * Fires regardless of whether the panel opens (even if cancelled).
     */
    @Output() AfterTaskSelected = new EventEmitter<TaskRow>();

    /**
     * Emitted after a bulk status change is applied.
     */
    @Output() AfterStatusChange = new EventEmitter<TaskRow>();

    /**
     * Emitted after a comment is posted in the detail panel.
     */
    @Output() AfterCommentPosted = new EventEmitter<void>();

    /**
     * Emitted after a task is saved (created or updated) from the edit panel.
     * Payload is the saved task's ID.
     */
    @Output() AfterTaskSaved = new EventEmitter<string>();

    /**
     * Emitted after a task is created via the quick-add input.
     * Payload is the new task's ID.
     */
    @Output() AfterTaskCreated = new EventEmitter<string>();

    /**
     * Emitted after the panel closes (for any reason).
     */
    @Output() AfterPanelClosed = new EventEmitter<void>();

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
    /** @internal */
    @ViewChild('detailPanel') detailPanel?: TaskDetailPanelComponent;
    /** @internal */
    @ViewChild('editPanel') editPanel?: TaskEditPanelComponent;

    // ── Internal State ──────────────────────────────────────

    /** @internal */
    panelMode: TaskPanelMode = 'none';
    /** @internal */
    selectedTaskID: string | null = null;

    constructor(private cdr: ChangeDetectorRef) {}

    // ── Public Methods ──────────────────────────────────────

    /**
     * Refreshes the task views from the server.
     */
    Refresh(): void {
        this.taskList?.Refresh();
        this.taskKanban?.Refresh();
        this.taskGantt?.Refresh();
    }

    /**
     * Programmatically opens the detail panel for a task.
     * Emits {@link BeforePanelOpen} — cancellable.
     * @param taskID - The task to display.
     */
    OpenDetail(taskID: string): void {
        this.tryOpenPanel('detail', taskID);
    }

    /**
     * Programmatically opens the edit panel. Pass a task ID to edit,
     * or `null` to create a new task.
     * Emits {@link BeforePanelOpen} — cancellable.
     * @param taskID - The task to edit, or `null` for new.
     */
    OpenEdit(taskID: string | null): void {
        this.tryOpenPanel('edit', taskID);
    }

    /**
     * Programmatically closes the panel. Emits {@link BeforePanelClose} — cancellable.
     */
    Close(): void {
        this.closePanel();
    }

    /**
     * Switch view mode and emit change event.
     */
    setViewMode(mode: TaskViewMode): void {
        this.ViewMode = mode;
        this.ViewModeChange.emit(mode);
        this.cdr.markForCheck();
    }

    // ── Internal Event Handlers ─────────────────────────────

    /** @internal */
    onBeforeTaskSelected(event: BeforeTaskSelectedEvent): void {
        this.BeforeTaskSelected.emit(event);
    }

    /** @internal */
    onAfterTaskSelected(task: TaskRow): void {
        this.AfterTaskSelected.emit(task);
        this.tryOpenPanel('detail', task.ID);
    }

    /** @internal */
    onTaskClicked(taskID: string): void {
        this.tryOpenPanel('detail', taskID);
    }

    /** @internal */
    onKanbanStatusChange(event: AfterKanbanStatusChangeEvent): void {
        this.AfterKanbanStatusChange.emit(event);
        this.taskList?.Refresh();
    }

    /** @internal */
    onAfterTaskCreated(taskID: string): void {
        this.AfterTaskCreated.emit(taskID);
        this.taskKanban?.Refresh();
        this.taskGantt?.Refresh();
    }

    /** @internal */
    onCreateTask(): void {
        this.tryOpenPanel('edit', null);
    }

    /** @internal */
    onEditRequested(taskID: string): void {
        this.tryOpenPanel('edit', taskID);
    }

    /** @internal Handles delete from the detail panel — closes panel and refreshes list. */
    async onDeleteRequested(_taskID: string): Promise<void> {
        this.panelMode = 'none';
        this.selectedTaskID = null;
        this.cdr.markForCheck();
        await this.taskList?.Refresh();
        this.taskKanban?.Refresh();
        this.taskGantt?.Refresh();
        this.cdr.markForCheck();
    }

    /** @internal */
    onTaskSaved(taskID: string): void {
        this.AfterTaskSaved.emit(taskID);
        this.panelMode = 'none';
        this.selectedTaskID = null;
        this.AfterPanelClosed.emit();
        this.taskList?.Refresh();
        this.taskKanban?.Refresh();
        this.taskGantt?.Refresh();
        this.cdr.markForCheck();
    }

    /** @internal */
    closePanel(): void {
        if (this.panelMode === 'none') return;
        const before = new BeforePanelCloseEvent();
        this.BeforePanelClose.emit(before);
        if (before.Cancel) return;

        this.panelMode = 'none';
        this.selectedTaskID = null;
        this.AfterPanelClosed.emit();
        this.cdr.markForCheck();
    }

    /** @internal */
    private tryOpenPanel(mode: TaskPanelMode, taskID: string | null): void {
        const before = new BeforePanelOpenEvent(mode, taskID);
        this.BeforePanelOpen.emit(before);
        if (before.Cancel) return;

        this.panelMode = mode;
        this.selectedTaskID = taskID;
        this.cdr.markForCheck();
    }

    /** @internal */
    onOpenFullRecord(taskID: string | null): void {
        if (!taskID) return;
        this.TaskDoubleClicked.emit(taskID);
        this.OpenRecordRequested.emit(taskID);
        OpenTaskRecord(taskID);
    }
}
