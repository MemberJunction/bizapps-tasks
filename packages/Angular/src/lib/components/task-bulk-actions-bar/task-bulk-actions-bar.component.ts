import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

/**
 * Describes a bulk action to be performed on selected tasks.
 * Emitted by {@link TaskBulkActionsBarComponent} when the user applies an action.
 */
export interface BulkActionEvent {
    /** The type of bulk action being performed. */
    Action: 'StatusChange' | 'Reassign' | 'Cancel';
    /** Array of task IDs the action applies to. */
    TaskIDs: string[];
    /** New status value — only set when `Action === 'StatusChange'`. */
    NewStatus?: string;
}

/**
 * Contextual toolbar that appears when one or more tasks are selected via
 * checkboxes in the {@link TaskListComponent}.
 *
 * Provides bulk actions: status change (with dropdown), cancel all selected
 * tasks, and clear selection. The component is typically embedded inside
 * TaskListComponent and is not used standalone.
 *
 * **Note:** As of the current implementation, the bulk action bar in
 * TaskListComponent is rendered inline rather than using this component.
 * This standalone version is available for custom layouts.
 *
 * @example
 * ```html
 * <bizapps-task-bulk-actions-bar
 *     [SelectedTaskIDs]="selectedIDs"
 *     (BulkAction)="onBulkAction($event)"
 *     (ClearSelection)="clearSelection()">
 * </bizapps-task-bulk-actions-bar>
 * ```
 */
@Component({
    selector: 'bizapps-task-bulk-actions-bar',
    standalone: true,
    imports: [CommonModule, FormsModule],
    template: `
        @if (SelectedTaskIDs.length > 0) {
            <div class="bulk-bar">
                <span class="count">{{ SelectedTaskIDs.length }} selected</span>
                <select [(ngModel)]="selectedStatus" class="bulk-select">
                    <option value="">Change status...</option>
                    <option value="Open">Open</option>
                    <option value="InProgress">In Progress</option>
                    <option value="Blocked">Blocked</option>
                    <option value="Completed">Completed</option>
                </select>
                <button class="bulk-btn apply" (click)="OnApplyStatus()" [disabled]="!selectedStatus">
                    Apply
                </button>
                <button class="bulk-btn cancel-tasks" (click)="OnCancelTasks()">
                    Cancel Tasks
                </button>
                <button class="bulk-btn clear" (click)="ClearSelection.emit()">
                    Clear Selection
                </button>
            </div>
        }
    `,
    styles: [`
        .bulk-bar {
            display: flex; align-items: center; gap: 8px;
            padding: 8px 12px; background: #eef2ff; border-radius: 6px;
            border: 1px solid #c7d2fe;
        }
        .count { font-weight: 600; font-size: 0.85rem; color: #4338ca; }
        .bulk-select {
            padding: 4px 8px; border-radius: 4px; border: 1px solid #cbd5e1;
            font-size: 0.85rem;
        }
        .bulk-btn {
            padding: 4px 12px; border-radius: 4px; font-size: 0.85rem;
            border: 1px solid #cbd5e1; cursor: pointer; background: #fff;
        }
        .bulk-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .bulk-btn.apply { background: #4f46e5; color: #fff; border-color: #4f46e5; }
        .bulk-btn.cancel-tasks { background: #fee2e2; color: #991b1b; border-color: #fecaca; }
        .bulk-btn.clear { background: #f9fafb; }
    `]
})
export class TaskBulkActionsBarComponent {
    // ── Inputs ──────────────────────────────────────────────

    /**
     * Array of currently selected task IDs. When non-empty, the bar is visible.
     * Typically bound to the parent component's selection state.
     */
    @Input() SelectedTaskIDs: string[] = [];

    // ── Outputs ─────────────────────────────────────────────

    /**
     * Emitted when the user applies a bulk action (status change or cancel).
     * The parent component is responsible for executing the action against the
     * task entities and refreshing the list.
     */
    @Output() BulkAction = new EventEmitter<BulkActionEvent>();

    /**
     * Emitted when the user clicks "Clear Selection". The parent should
     * reset its selection state in response.
     */
    @Output() ClearSelection = new EventEmitter<void>();

    // ── Internal State ──────────────────────────────────────

    /** @internal */
    selectedStatus = '';

    // ── Internal Event Handlers ─────────────────────────────

    /** @internal Emits a StatusChange bulk action with the selected status. */
    OnApplyStatus(): void {
        if (!this.selectedStatus) return;
        this.BulkAction.emit({
            Action: 'StatusChange',
            TaskIDs: this.SelectedTaskIDs,
            NewStatus: this.selectedStatus,
        });
        this.selectedStatus = '';
    }

    /** @internal Emits a Cancel bulk action for all selected tasks. */
    OnCancelTasks(): void {
        this.BulkAction.emit({
            Action: 'Cancel',
            TaskIDs: this.SelectedTaskIDs,
        });
    }
}