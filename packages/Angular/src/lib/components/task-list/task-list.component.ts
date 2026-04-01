import { Component, EventEmitter, inject, Input, OnInit, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { BaseEntity, Metadata, RunView } from '@memberjunction/core';
import { TaskPriorityBadgeComponent } from '../task-priority-badge/task-priority-badge.component';
import { TaskAssigneeListComponent, TaskAssigneeInfo } from '../task-assignee-list/task-assignee-list.component';
import { TaskBulkActionsBarComponent, BulkActionEvent } from '../task-bulk-actions-bar/task-bulk-actions-bar.component';

export interface TaskRow {
    ID: string;
    Name: string;
    Description: string | null;
    Status: string;
    Priority: string;
    DueAt: Date | null;
    PercentComplete: number;
    CategoryName?: string;
    Assignees: TaskAssigneeInfo[];
    IsOverdue: boolean;
    IsDueSoon: boolean;
}

export class BeforeTaskSelectedEvent {
    Cancel = false;
    constructor(public Task: TaskRow) {}
}

export class BeforeStatusChangeEvent {
    Cancel = false;
    constructor(public Task: TaskRow, public NewStatus: string) {}
}

/**
 * Embeddable, filterable task list. Supports text search, status/category
 * filtering, checkbox multi-select for bulk operations, and urgency indicators.
 *
 * No routing — raises events only. Consuming apps wire events to their routing.
 */
@Component({
    selector: 'bizapps-task-list',
    standalone: true,
    imports: [CommonModule, FormsModule, TaskPriorityBadgeComponent, TaskAssigneeListComponent, TaskBulkActionsBarComponent],
    template: `
        <div class="task-list-container" [class.compact]="Compact">
            <!-- Header -->
            <div class="task-list-header">
                <div class="search-bar">
                    <input type="text" [(ngModel)]="SearchText" (ngModelChange)="onSearchChange()"
                           placeholder="Search tasks..." class="search-input" />
                </div>
                <div class="header-actions">
                    <select [(ngModel)]="statusFilter" (ngModelChange)="loadTasks()" class="filter-select">
                        <option value="">All Statuses</option>
                        <option value="Open">Open</option>
                        <option value="InProgress">In Progress</option>
                        <option value="Blocked">Blocked</option>
                        <option value="Completed">Completed</option>
                        <option value="Cancelled">Cancelled</option>
                    </select>
                    @if (ShowCreateButton) {
                        <button class="create-btn" (click)="CreateTask.emit()">+ New Task</button>
                    }
                </div>
            </div>

            <!-- Bulk actions -->
            <bizapps-task-bulk-actions-bar
                [SelectedTaskIDs]="selectedIDs"
                (BulkAction)="onBulkAction($event)"
                (ClearSelection)="clearSelection()">
            </bizapps-task-bulk-actions-bar>

            <!-- Loading -->
            @if (loading) {
                <div class="loading-state">Loading tasks...</div>
            }

            <!-- Empty state -->
            @if (!loading && filteredTasks.length === 0) {
                <div class="empty-state">No tasks found.</div>
            }

            <!-- Task rows -->
            @for (task of filteredTasks; track task.ID) {
                <div class="task-row"
                     [class.overdue]="task.IsOverdue"
                     [class.due-soon]="task.IsDueSoon"
                     [class.selected]="selectedIDs.includes(task.ID)"
                     [class.completed]="task.Status === 'Completed'"
                     (click)="onTaskClick(task)">
                    <input type="checkbox" class="task-checkbox"
                           [checked]="selectedIDs.includes(task.ID)"
                           (click)="$event.stopPropagation()"
                           (change)="toggleSelect(task.ID)" />
                    <div class="task-main">
                        <div class="task-name">{{ task.Name }}</div>
                        @if (!Compact && task.Description) {
                            <div class="task-desc">{{ task.Description | slice:0:120 }}</div>
                        }
                    </div>
                    <bizapps-task-priority-badge [Priority]="task.Priority"></bizapps-task-priority-badge>
                    @if (!Compact) {
                        <bizapps-task-assignee-list [Assignees]="task.Assignees"></bizapps-task-assignee-list>
                    }
                    <div class="task-meta">
                        <span class="status-chip" [ngClass]="'status-' + task.Status.toLowerCase()">
                            {{ task.Status }}
                        </span>
                        @if (task.DueAt) {
                            <span class="due-date" [class.overdue-text]="task.IsOverdue">
                                {{ task.DueAt | date:'MMM d' }}
                            </span>
                        }
                    </div>
                </div>
            }
        </div>
    `,
    styles: [`
        .task-list-container { font-family: inherit; }
        .task-list-header {
            display: flex; justify-content: space-between; align-items: center;
            gap: 8px; margin-bottom: 8px; flex-wrap: wrap;
        }
        .search-input {
            padding: 6px 12px; border: 1px solid #d1d5db; border-radius: 6px;
            font-size: 0.875rem; width: 240px;
        }
        .header-actions { display: flex; gap: 8px; align-items: center; }
        .filter-select {
            padding: 6px 8px; border: 1px solid #d1d5db; border-radius: 6px;
            font-size: 0.85rem;
        }
        .create-btn {
            padding: 6px 14px; border-radius: 6px; border: none;
            background: #4f46e5; color: #fff; font-size: 0.85rem;
            cursor: pointer; font-weight: 500;
        }
        .loading-state, .empty-state {
            padding: 32px; text-align: center; color: #6b7280; font-size: 0.9rem;
        }
        .task-row {
            display: flex; align-items: center; gap: 12px;
            padding: 10px 12px; border-bottom: 1px solid #f3f4f6;
            cursor: pointer; transition: background 0.1s;
        }
        .task-row:hover { background: #f9fafb; }
        .task-row.selected { background: #eef2ff; }
        .task-row.overdue { border-left: 3px solid #ef4444; }
        .task-row.due-soon { border-left: 3px solid #f59e0b; }
        .task-row.completed { opacity: 0.6; }
        .task-checkbox { flex-shrink: 0; width: 16px; height: 16px; cursor: pointer; }
        .task-main { flex: 1; min-width: 0; }
        .task-name { font-weight: 500; font-size: 0.9rem; }
        .task-desc {
            font-size: 0.8rem; color: #6b7280;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }
        .task-meta { display: flex; gap: 8px; align-items: center; flex-shrink: 0; }
        .status-chip {
            font-size: 0.75rem; padding: 2px 8px; border-radius: 4px;
            font-weight: 500; text-transform: capitalize;
        }
        .status-open { background: #dbeafe; color: #1e40af; }
        .status-inprogress { background: #e0e7ff; color: #4338ca; }
        .status-blocked { background: #fee2e2; color: #991b1b; }
        .status-completed { background: #dcfce7; color: #166534; }
        .status-cancelled { background: #f3f4f6; color: #6b7280; }
        .due-date { font-size: 0.8rem; color: #6b7280; white-space: nowrap; }
        .overdue-text { color: #ef4444; font-weight: 600; }
        .compact .task-row { padding: 6px 10px; }
        .compact .task-name { font-size: 0.85rem; }
    `]
})
export class TaskListComponent implements OnInit {
    // -- Inputs --
    @Input() CategoryID: string | null = null;
    @Input() ExtraFilter: string | null = null;
    @Input() StatusFilter: string | null = null;
    @Input() ShowCreateButton = false;
    @Input() Compact = false;

    private _searchText = '';
    @Input()
    get SearchText(): string { return this._searchText; }
    set SearchText(value: string) { this._searchText = value; }

    // -- Outputs --
    @Output() BeforeTaskSelected = new EventEmitter<BeforeTaskSelectedEvent>();
    @Output() AfterTaskSelected = new EventEmitter<TaskRow>();
    @Output() BeforeStatusChange = new EventEmitter<BeforeStatusChangeEvent>();
    @Output() AfterStatusChange = new EventEmitter<TaskRow>();
    @Output() CreateTask = new EventEmitter<void>();

    // -- State --
    tasks: TaskRow[] = [];
    filteredTasks: TaskRow[] = [];
    selectedIDs: string[] = [];
    loading = false;
    statusFilter = '';
    private searchTimeout: any;

    ngOnInit(): void {
        if (this.StatusFilter) this.statusFilter = this.StatusFilter;
        this.loadTasks();
    }

    // -- Public API --

    Refresh(): void { this.loadTasks(); }

    SelectTask(taskID: string): void {
        const task = this.tasks.find(t => t.ID === taskID);
        if (task) this.onTaskClick(task);
    }

    ClearSelection(): void { this.clearSelection(); }

    // -- Data loading --

    async loadTasks(): Promise<void> {
        this.loading = true;
        const rv = new RunView();
        const filters: string[] = [];
        if (this.CategoryID) filters.push(`CategoryID = '${this.CategoryID}'`);
        if (this.statusFilter) filters.push(`Status = '${this.statusFilter}'`);
        if (this.ExtraFilter) filters.push(this.ExtraFilter);

        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Tasks',
            ExtraFilter: filters.length ? filters.join(' AND ') : undefined,
            OrderBy: 'Sequence ASC, DueAt ASC',
            ResultType: 'simple',
        });

        const now = new Date();
        const soon = new Date(now.getTime() + 48 * 60 * 60 * 1000);

        this.tasks = (result?.Results ?? []).map((r: any) => {
            const dueAt = r.DueAt ? new Date(r.DueAt) : null;
            const isActive = r.Status !== 'Completed' && r.Status !== 'Cancelled';
            return {
                ID: r.ID,
                Name: r.Name,
                Description: r.Description,
                Status: r.Status,
                Priority: r.Priority,
                DueAt: dueAt,
                PercentComplete: r.PercentComplete ?? 0,
                Assignees: [],
                IsOverdue: isActive && dueAt != null && dueAt < now,
                IsDueSoon: isActive && dueAt != null && dueAt >= now && dueAt <= soon,
            } as TaskRow;
        });

        this.applyTextFilter();
        this.loading = false;
    }

    // -- Filtering --

    onSearchChange(): void {
        clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => this.applyTextFilter(), 200);
    }

    private applyTextFilter(): void {
        if (!this._searchText.trim()) {
            this.filteredTasks = this.tasks;
            return;
        }
        const q = this._searchText.toLowerCase();
        this.filteredTasks = this.tasks.filter(t =>
            t.Name.toLowerCase().includes(q) ||
            (t.Description ?? '').toLowerCase().includes(q)
        );
    }

    // -- Selection --

    onTaskClick(task: TaskRow): void {
        const before = new BeforeTaskSelectedEvent(task);
        this.BeforeTaskSelected.emit(before);
        if (before.Cancel) return;
        this.AfterTaskSelected.emit(task);
    }

    toggleSelect(taskID: string): void {
        const idx = this.selectedIDs.indexOf(taskID);
        if (idx >= 0) this.selectedIDs.splice(idx, 1);
        else this.selectedIDs.push(taskID);
    }

    clearSelection(): void { this.selectedIDs = []; }

    // -- Bulk actions --

    async onBulkAction(event: BulkActionEvent): Promise<void> {
        if (event.Action === 'StatusChange' && event.NewStatus) {
            for (const id of event.TaskIDs) {
                const task = this.tasks.find(t => t.ID === id);
                if (!task) continue;
                const before = new BeforeStatusChangeEvent(task, event.NewStatus);
                this.BeforeStatusChange.emit(before);
                if (before.Cancel) continue;

                const entity = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Tasks');
                const pk = new (await import('@memberjunction/core')).CompositeKey([{ FieldName: 'ID', Value: id }]);
                await entity.InnerLoad(pk);
                entity.Set('Status', event.NewStatus);
                await entity.Save();
                task.Status = event.NewStatus;
                this.AfterStatusChange.emit(task);
            }
        } else if (event.Action === 'Cancel') {
            for (const id of event.TaskIDs) {
                const entity = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Tasks');
                const pk = new (await import('@memberjunction/core')).CompositeKey([{ FieldName: 'ID', Value: id }]);
                await entity.InnerLoad(pk);
                entity.Set('Status', 'Cancelled');
                await entity.Save();
                const task = this.tasks.find(t => t.ID === id);
                if (task) task.Status = 'Cancelled';
            }
        }
        this.clearSelection();
        await this.loadTasks();
    }
}
