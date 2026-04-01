import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TaskListComponent, TaskRow, BeforeTaskSelectedEvent, BeforeStatusChangeEvent } from '../task-list/task-list.component';

/**
 * "My Tasks" view — wraps TaskListComponent filtered to the current user's
 * PersonID (via TaskAssignment), sorted by DueAt. The #1 daily use case.
 *
 * Consuming apps provide PersonID; this component builds the ExtraFilter
 * to scope through the TaskAssignment join.
 */
@Component({
    selector: 'bizapps-my-tasks',
    standalone: true,
    imports: [CommonModule, TaskListComponent],
    template: `
        <div class="my-tasks">
            <h3 class="my-tasks-title">My Tasks</h3>
            <bizapps-task-list
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
    @Input() PersonID: string = '';
    @Input() ShowCreateButton = false;
    @Input() Compact = false;

    @Output() BeforeTaskSelected = new EventEmitter<BeforeTaskSelectedEvent>();
    @Output() AfterTaskSelected = new EventEmitter<TaskRow>();
    @Output() BeforeStatusChange = new EventEmitter<BeforeStatusChangeEvent>();
    @Output() AfterStatusChange = new EventEmitter<TaskRow>();
    @Output() CreateTask = new EventEmitter<void>();

    get assigneeFilter(): string {
        if (!this.PersonID) return '';
        return `ID IN (SELECT TaskID FROM __mj_BizAppsTasks.TaskAssignment WHERE AssigneeRecordID = '${this.PersonID}')`;
    }
}
