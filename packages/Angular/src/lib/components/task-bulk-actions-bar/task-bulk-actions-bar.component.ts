import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

export interface BulkActionEvent {
    Action: 'StatusChange' | 'Reassign' | 'Cancel';
    TaskIDs: string[];
    NewStatus?: string;
}

/**
 * Appears when items are multi-selected in TaskListComponent.
 * Actions: bulk Status change, bulk Reassign, bulk Cancel.
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
                <button class="bulk-btn apply" (click)="onApplyStatus()" [disabled]="!selectedStatus">
                    Apply
                </button>
                <button class="bulk-btn cancel-tasks" (click)="onCancelTasks()">
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
    @Input() SelectedTaskIDs: string[] = [];
    @Output() BulkAction = new EventEmitter<BulkActionEvent>();
    @Output() ClearSelection = new EventEmitter<void>();

    selectedStatus = '';

    onApplyStatus(): void {
        if (!this.selectedStatus) return;
        this.BulkAction.emit({
            Action: 'StatusChange',
            TaskIDs: this.SelectedTaskIDs,
            NewStatus: this.selectedStatus,
        });
        this.selectedStatus = '';
    }

    onCancelTasks(): void {
        this.BulkAction.emit({
            Action: 'Cancel',
            TaskIDs: this.SelectedTaskIDs,
        });
    }
}
