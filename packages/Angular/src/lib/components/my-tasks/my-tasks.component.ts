import { Component, EventEmitter, Input, Output, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TaskListComponent, TaskRow, BeforeTaskSelectedEvent, BeforeStatusChangeEvent } from '../task-list/task-list.component';

/**
 * "My Tasks" convenience wrapper around {@link TaskListComponent}.
 *
 * Automatically filters tasks to those assigned to the provided {@link PersonID}
 * via the TaskAssignment join table. This is the #1 daily use case — "what do
 * I need to do?" — and can be embedded by any consuming app.
 *
 * All {@link TaskListComponent} events are re-emitted so consuming apps can
 * wire up the same Before/After patterns.
 *
 * @example
 * ```html
 * <bizapps-my-tasks
 *     [PersonID]="currentUserPersonID"
 *     [ShowCreateButton]="true"
 *     (AfterTaskSelected)="openTaskDetail($event)"
 *     (CreateTask)="openNewTaskPanel()">
 * </bizapps-my-tasks>
 * ```
 */
@Component({
    selector: 'bizapps-my-tasks',
    standalone: true,
    imports: [CommonModule, TaskListComponent],
    template: `
        <div class="my-tasks">
            <h3 class="my-tasks-title">My Tasks</h3>
            <bizapps-task-list
                #taskList
                [ExtraFilter]="assigneeFilter"
                [ShowCreateButton]="ShowCreateButton"
                [Compact]="Compact"
                (BeforeTaskSelected)="BeforeTaskSelected.emit($event)"
                (AfterTaskSelected)="AfterTaskSelected.emit($event)"
                (BeforeStatusChange)="BeforeStatusChange.emit($event)"
                (AfterStatusChange)="AfterStatusChange.emit($event)"
                (CreateTask)="CreateTask.emit()">
            </bizapps-task-list>
        </div>
    `,
    styles: [`
        .my-tasks-title {
            margin: 0 0 8px; font-size: 1.1rem; font-weight: 600; color: #1f2937;
        }
    `]
})
export class MyTasksComponent {
    // ── Inputs ──────────────────────────────────────────────

    /**
     * The Person ID of the current user. Used to filter tasks via
     * TaskAssignment. Required — if empty, no tasks will be shown.
     */
    @Input() PersonID: string = '';

    /**
     * Whether to show the "+ New Task" button in the embedded list toolbar.
     * @default false
     */
    @Input() ShowCreateButton = false;

    /**
     * Compact mode — reduces padding and hides descriptions.
     * Useful for sidebar or widget embedding.
     * @default false
     */
    @Input() Compact = false;

    // ── Outputs ─────────────────────────────────────────────

    /**
     * Re-emitted from the inner {@link TaskListComponent}.
     * Cancellable — set `event.Cancel = true` to prevent the selection.
     */
    @Output() BeforeTaskSelected = new EventEmitter<BeforeTaskSelectedEvent>();

    /**
     * Re-emitted from the inner {@link TaskListComponent}.
     * Payload is the selected {@link TaskRow}.
     */
    @Output() AfterTaskSelected = new EventEmitter<TaskRow>();

    /** Re-emitted from the inner {@link TaskListComponent}. Cancellable. */
    @Output() BeforeStatusChange = new EventEmitter<BeforeStatusChangeEvent>();

    /** Re-emitted from the inner {@link TaskListComponent}. */
    @Output() AfterStatusChange = new EventEmitter<TaskRow>();

    /** Re-emitted when the user clicks "+ New Task" in the embedded list. */
    @Output() CreateTask = new EventEmitter<void>();

    // ── View References ─────────────────────────────────────

    /** @internal */
    @ViewChild('taskList') taskList?: TaskListComponent;

    // ── Public Methods ──────────────────────────────────────

    /**
     * Reloads the inner task list from the server.
     */
    Refresh(): void {
        this.taskList?.Refresh();
    }

    // ── Internal ────────────────────────────────────────────

    /** @internal Builds the ExtraFilter to scope tasks by assignee PersonID. */
    get assigneeFilter(): string {
        if (!this.PersonID) return '';
        return `ID IN (SELECT TaskID FROM __mj_BizAppsTasks.TaskAssignment WHERE AssigneeRecordID = '${this.PersonID}')`;
    }
}
