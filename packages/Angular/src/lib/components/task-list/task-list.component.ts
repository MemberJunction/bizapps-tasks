import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, inject, Input, OnInit, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Metadata, RunView, CompositeKey } from '@memberjunction/core';

/**
 * Represents a single task row as displayed by {@link TaskListComponent}.
 * Contains denormalized data including resolved assignee names, tags, and
 * computed fields like overdue/due-soon indicators.
 */
export interface TaskRow {
    /** Unique task ID (GUID). */
    ID: string;
    /** Task name / title. */
    Name: string;
    /** Optional longer description. Truncated in the list view. */
    Description: string | null;
    /** Current status: Open, InProgress, Blocked, Completed, Cancelled. */
    Status: string;
    /** Priority level: Low, Medium, High, Critical. */
    Priority: string;
    /** Due date, or null if none set. */
    DueAt: Date | null;
    /** Completion percentage (0–100). */
    PercentComplete: number;
    /** Estimated hours for the task. */
    HoursEstimated: number | null;
    /** Parent task ID for sub-task hierarchy, or null for top-level. */
    ParentID: string | null;
    /** Nesting depth in the hierarchy (0 = top-level). Adjusted when filtering. */
    Depth: number;
    /** Resolved assignee details including display name, role, and per-person status. */
    Assignees: { Name: string; Role: string; Status: string }[];
    /** Resolved tag details including display name and color code. */
    Tags: { Name: string; Color: string }[];
    /** True if the task is active (not Completed/Cancelled) and past its DueAt. */
    IsOverdue: boolean;
    /** True if the task is active and due within the next 48 hours. */
    IsDueSoon: boolean;
    /** Number of direct child tasks. Used to show the parent folder icon. */
    ChildCount: number;
}

/**
 * Cancellable event emitted before a task is selected in the list.
 * Set `Cancel = true` in a handler to prevent the selection from proceeding.
 *
 * @example
 * ```html
 * <bizapps-task-list (BeforeTaskSelected)="onBefore($event)"></bizapps-task-list>
 * ```
 * ```ts
 * onBefore(event: BeforeTaskSelectedEvent) {
 *     if (someCondition) event.Cancel = true;
 * }
 * ```
 */
export class BeforeTaskSelectedEvent {
    /** Set to `true` to prevent the task selection. */
    Cancel = false;
    constructor(
        /** The task row that is about to be selected. */
        public Task: TaskRow
    ) {}
}

/**
 * Cancellable event emitted before a bulk status change is applied to a task.
 * Set `Cancel = true` to skip the status change for this specific task.
 */
export class BeforeStatusChangeEvent {
    /** Set to `true` to prevent this status change. */
    Cancel = false;
    constructor(
        /** The task whose status is about to change. */
        public Task: TaskRow,
        /** The new status value that will be applied. */
        public NewStatus: string
    ) {}
}

@Component({
    selector: 'bizapps-task-list',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [CommonModule, FormsModule],
    template: `
        <div class="task-list-host">
            <!-- Toolbar -->
            <div class="toolbar">
                <div class="search-wrap">
                    <i class="fa-solid fa-magnifying-glass search-icon"></i>
                    <input type="text" [(ngModel)]="searchText" (ngModelChange)="onSearchChange()"
                           placeholder="Search tasks..." class="search-input" />
                </div>
                <div class="toolbar-right">
                    <div class="filter-pills">
                        @for (f of statusFilters; track f.value) {
                            <button class="filter-pill" [class.active]="statusFilter === f.value"
                                    (click)="statusFilter = f.value; applyFilters()">
                                {{ f.label }}
                                @if (f.value === '' && tasks.length > 0) {
                                    <span class="filter-count">{{ tasks.length }}</span>
                                }
                            </button>
                        }
                    </div>
                    @if (ShowCreateButton) {
                        <button class="btn-create" (click)="CreateTask.emit()">
                            <i class="fa-solid fa-plus"></i> New Task
                        </button>
                    }
                </div>
            </div>

            <!-- Loading -->
            @if (loading) {
                <div class="empty-state"><p>Loading tasks...</p></div>
            }

            <!-- Empty -->
            @if (!loading && filteredTasks.length === 0) {
                <div class="empty-state">
                    <i class="fa-solid fa-clipboard-check"></i>
                    <p>No tasks match this filter.</p>
                </div>
            }

            <!-- Bulk actions -->
            @if (selectedIDs.length > 0) {
                <div class="bulk-bar">
                    <span class="bulk-count">{{ selectedIDs.length }} selected</span>
                    <select [(ngModel)]="bulkStatus" class="bulk-select">
                        <option value="">Change status...</option>
                        <option value="Open">Open</option>
                        <option value="InProgress">In Progress</option>
                        <option value="Blocked">Blocked</option>
                        <option value="Completed">Completed</option>
                        <option value="Cancelled">Cancelled</option>
                    </select>
                    @if (bulkStatus === 'InProgress') {
                        <input type="number" [(ngModel)]="bulkPercent" name="bulkPct"
                               min="0" max="100" placeholder="%" class="bulk-pct-input" />
                    }
                    <button class="bulk-btn bulk-apply" [disabled]="!bulkStatus" (click)="applyBulkStatus()">Apply</button>
                    <button class="bulk-btn bulk-cancel" (click)="selectedIDs = []; cdr.markForCheck()">Clear</button>
                </div>
            }

            <!-- Task cards -->
            @if (!loading) {
                <div class="task-grid">
                    @for (task of filteredTasks; track task.ID) {
                        <!-- Skip sub-tasks whose parent is collapsed -->
                        @if (task.Depth === 0 || isParentExpanded(task)) {
                            <div class="task-card-wrapper" [class.is-child]="task.Depth > 0">
                                <!-- Tree connector line for sub-tasks -->
                                @if (task.Depth > 0) {
                                    <div class="tree-connector">
                                        <div class="tree-line-vertical"></div>
                                        <div class="tree-line-horizontal"></div>
                                    </div>
                                }
                                <div class="task-card"
                                     [class.overdue]="task.IsOverdue"
                                     [class.completed]="task.Status === 'Completed'"
                                     [class.selected]="selectedIDs.includes(task.ID)"
                                     [class.sub-task]="task.Depth > 0"
                                     (click)="onTaskClick(task)">

                                    <!-- Checkbox -->
                                    <input type="checkbox" class="task-checkbox"
                                           [checked]="selectedIDs.includes(task.ID)"
                                           (click)="$event.stopPropagation()"
                                           (change)="toggleSelect(task.ID)" />

                                    <!-- Expand/collapse toggle for parents -->
                                    @if (task.ChildCount > 0) {
                                        <button class="expand-toggle" (click)="toggleExpand(task.ID); $event.stopPropagation()">
                                            <i [class]="expandedIDs.has(task.ID) ? 'fa-solid fa-chevron-down' : 'fa-solid fa-chevron-right'"></i>
                                        </button>
                                    }

                                    <!-- Priority dot -->
                                    <div [class]="'priority-dot priority-' + task.Priority.toLowerCase()"></div>

                                    <!-- Content -->
                                    <div class="card-content">
                                        <div class="card-title-row">
                                            <h4 class="card-title">
                                                @if (task.ChildCount > 0) {
                                                    <span class="child-count-badge">{{ task.ChildCount }}</span>
                                                }
                                                {{ task.Name }}
                                            </h4>
                                        </div>

                                @if (!Compact && task.Description) {
                                    <p class="card-desc">{{ task.Description }}</p>
                                }

                                <!-- Progress bar -->
                                @if (task.PercentComplete > 0 || task.ChildCount > 0) {
                                    <div class="progress-row">
                                        <div class="progress-bar">
                                            <div class="progress-fill"
                                                 [style.width.%]="task.PercentComplete"
                                                 [class.complete]="task.PercentComplete === 100"></div>
                                        </div>
                                        <span class="progress-label">{{ task.PercentComplete }}%</span>
                                    </div>
                                }

                                <!-- Meta row -->
                                <div class="card-meta">
                                    @if (task.Assignees.length > 0) {
                                        @for (a of task.Assignees; track a.Name) {
                                            <span class="meta-chip assignee-chip">
                                                <span class="assignee-dot" [ngClass]="'dot-' + a.Status.toLowerCase()"></span>
                                                {{ a.Name }}
                                                @if (a.Role !== 'Primary') {
                                                    <span class="role-label">{{ a.Role }}</span>
                                                }
                                            </span>
                                        }
                                    }
                                    @if (task.DueAt) {
                                        <span class="meta-chip due-chip" [class.overdue-text]="task.IsOverdue" [class.due-soon-text]="task.IsDueSoon">
                                            <i class="fa-solid fa-calendar"></i>
                                            {{ task.DueAt | date:'MMM d' }}
                                        </span>
                                    }
                                    @if (task.HoursEstimated) {
                                        <span class="meta-chip">
                                            <i class="fa-solid fa-clock"></i>
                                            {{ task.HoursEstimated }}h
                                        </span>
                                    }
                                    @for (tag of task.Tags; track tag.Name) {
                                        <span class="meta-chip tag-chip" [style.background]="tag.Color + '18'" [style.color]="tag.Color">
                                            {{ tag.Name }}
                                        </span>
                                    }
                                </div>
                            </div>

                            <!-- Status badge -->
                            <div class="card-status">
                                <span [class]="'status-badge status-' + task.Status.toLowerCase()">
                                    {{ formatStatus(task.Status) }}
                                </span>
                            </div>
                        </div>
                    </div>
                        }
                    }
                </div>

                <!-- Quick-add inline -->
                @if (ShowQuickAdd) {
                    <div class="quick-add-row">
                        <i class="fa-solid fa-plus quick-add-icon"></i>
                        <input type="text" [(ngModel)]="quickAddName" name="quickAdd"
                               placeholder="Add a task..."
                               class="quick-add-input"
                               (keydown.enter)="quickAddTask()" />
                        <select [(ngModel)]="quickAddPersonID" name="quickAddPerson" class="quick-add-person">
                            <option value="">Unassigned</option>
                            @for (p of quickAddPeople; track p.ID) {
                                <option [value]="p.ID">{{ p.FirstName }} {{ p.LastName }}</option>
                            }
                        </select>
                        @if (quickAddName.trim()) {
                            <button class="quick-add-btn" (click)="quickAddTask()" [disabled]="quickAdding">
                                {{ quickAdding ? '...' : 'Add' }}
                            </button>
                        }
                    </div>
                }
            }
        </div>
    `,
    styles: [`
        :host {
            display: block;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            -webkit-font-smoothing: antialiased;
        }

        /* ─── Toolbar ─── */
        .toolbar {
            display: flex; justify-content: space-between; align-items: center;
            gap: 16px; margin-bottom: 24px; flex-wrap: wrap;
        }
        .toolbar-right { display: flex; gap: 12px; align-items: center; flex-wrap: wrap; }
        .search-wrap { position: relative; }
        .search-icon {
            position: absolute; left: 12px; top: 50%; transform: translateY(-50%);
            font-size: 13px; color: #94a3b8;
        }
        .search-input {
            padding: 8px 14px 8px 34px; border: 1px solid #e2e8f0; border-radius: 10px;
            font-size: 14px; width: 260px; font-family: inherit;
            transition: border-color 0.15s, box-shadow 0.15s;
        }
        .search-input:focus {
            outline: none; border-color: #6366f1;
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
        }
        .filter-pills {
            display: flex; gap: 2px; background: #f1f5f9; border-radius: 10px; padding: 3px;
        }
        .filter-pill {
            padding: 7px 14px; border: none; border-radius: 8px; background: transparent;
            font-size: 13px; font-weight: 600; color: #94a3b8; cursor: pointer;
            transition: all 0.15s ease; font-family: inherit;
            display: flex; align-items: center; gap: 6px;
        }
        .filter-pill:hover { color: #64748b; }
        .filter-pill.active {
            background: #fff; color: #0f172a; box-shadow: 0 1px 3px rgba(0,0,0,0.06);
        }
        .filter-count {
            font-size: 11px; font-weight: 700; padding: 1px 8px; border-radius: 10px;
            background: rgba(0,0,0,0.06);
        }
        .filter-pill.active .filter-count { background: #eef2ff; color: #6366f1; }
        .btn-create {
            padding: 9px 18px; border: none; border-radius: 10px; background: #6366f1;
            font-size: 14px; font-weight: 600; color: #fff; cursor: pointer;
            box-shadow: 0 1px 3px rgba(99, 102, 241, 0.3);
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            font-family: inherit; display: inline-flex; align-items: center; gap: 6px;
        }
        .btn-create:hover {
            background: #4f46e5; box-shadow: 0 4px 12px rgba(99, 102, 241, 0.35);
            transform: translateY(-1px);
        }

        /* ─── Bulk Actions ─── */
        .bulk-bar {
            display: flex; align-items: center; gap: 8px; padding: 10px 14px;
            background: #eef2ff; border-radius: 10px; margin-bottom: 12px;
            border: 1px solid #c7d2fe;
        }
        .bulk-count { font-size: 13px; font-weight: 700; color: #4338ca; }
        .bulk-select {
            padding: 5px 8px; border: 1px solid #cbd5e1; border-radius: 8px;
            font-size: 13px; font-family: inherit;
        }
        .bulk-btn {
            padding: 5px 14px; border-radius: 8px; font-size: 13px;
            cursor: pointer; font-family: inherit; border: 1px solid #cbd5e1;
        }
        .bulk-apply { background: #6366f1; color: #fff; border-color: #6366f1; }
        .bulk-apply:disabled { opacity: 0.4; cursor: not-allowed; }
        .bulk-cancel { background: #fff; }
        .bulk-pct-input {
            width: 60px; padding: 5px 8px; border: 1px solid #cbd5e1; border-radius: 8px;
            font-size: 13px; font-family: inherit; text-align: center;
        }
        .task-checkbox {
            width: 15px; height: 15px; cursor: pointer; flex-shrink: 0;
            accent-color: #6366f1;
        }
        .task-card.selected { background: #eef2ff; }

        /* ─── Task Grid ─── */
        .task-grid { display: flex; flex-direction: column; gap: 4px; }

        /* ─── Tree Structure ─── */
        .task-card-wrapper {
            position: relative;
            display: flex; align-items: stretch;
        }
        .task-card-wrapper.is-child {
            margin-left: 32px;
        }
        .tree-connector {
            position: relative; width: 24px; flex-shrink: 0;
        }
        .tree-line-vertical {
            position: absolute; left: 11px; top: -4px; bottom: 50%;
            width: 1px; background: #d1d5db;
        }
        .tree-line-horizontal {
            position: absolute; left: 11px; top: 50%; width: 12px;
            height: 1px; background: #d1d5db;
        }
        .expand-toggle {
            display: flex; align-items: center; justify-content: center;
            width: 22px; height: 22px; border-radius: 6px; border: 1px solid #e2e8f0;
            background: #fff; color: #94a3b8; cursor: pointer; flex-shrink: 0;
            font-size: 10px; margin-right: 4px; transition: all 0.15s;
        }
        .expand-toggle:hover { background: #f1f5f9; color: #6366f1; border-color: #c7d2fe; }
        .child-count-badge {
            display: inline-flex; align-items: center; justify-content: center;
            min-width: 18px; height: 18px; padding: 0 5px; border-radius: 9px;
            background: #eef2ff; color: #6366f1; font-size: 10px; font-weight: 700;
            margin-right: 4px;
        }

        .task-card {
            background: #fff; border-radius: 14px; padding: 16px 20px;
            display: flex; align-items: flex-start; gap: 14px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            transition: box-shadow 0.25s ease, transform 0.25s ease;
            cursor: pointer; flex: 1;
        }
        .task-card:hover {
            box-shadow: 0 8px 30px rgba(0,0,0,0.07);
            transform: translateY(-1px);
        }
        .task-card.overdue {
            background: #fff5f5; border-left: 3px solid #f43f5e;
        }
        .task-card.completed { opacity: 0.55; }
        .task-card.sub-task { border-radius: 10px; padding: 12px 16px; flex: 1; }

        /* ─── Priority Dot ─── */
        .priority-dot {
            width: 9px; height: 9px; border-radius: 50%; flex-shrink: 0; margin-top: 6px;
        }
        .priority-critical { background: #f43f5e; box-shadow: 0 0 0 3px rgba(244, 63, 94, 0.15); }
        .priority-high { background: #f43f5e; box-shadow: 0 0 0 3px rgba(244, 63, 94, 0.15); }
        .priority-medium { background: #f59e0b; box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.15); }
        .priority-low { background: #10b981; box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15); }

        /* ─── Card Content ─── */
        .card-content { flex: 1; min-width: 0; }
        .card-title-row { display: flex; align-items: center; gap: 6px; }
        .card-title {
            font-size: 15px; font-weight: 600; color: #0f172a; margin: 0;
            letter-spacing: -0.2px; display: flex; align-items: center; gap: 6px;
        }
        .card-desc {
            font-size: 13px; color: #94a3b8; line-height: 1.4; margin: 4px 0 0 0;
            display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
        }

        /* ─── Progress ─── */
        .progress-row {
            display: flex; align-items: center; gap: 8px; margin-top: 8px;
        }
        .progress-bar {
            flex: 1; max-width: 140px; height: 5px; background: #e2e8f0;
            border-radius: 3px; overflow: hidden;
        }
        .progress-fill {
            height: 100%; background: #6366f1; border-radius: 3px;
            transition: width 0.3s ease;
        }
        .progress-fill.complete { background: #10b981; }
        .progress-label { font-size: 11px; font-weight: 600; color: #94a3b8; }

        /* ─── Meta Row ─── */
        .card-meta {
            display: flex; align-items: center; gap: 8px; margin-top: 8px; flex-wrap: wrap;
        }
        .meta-chip {
            display: inline-flex; align-items: center; gap: 4px;
            font-size: 12px; color: #64748b;
        }
        .meta-chip i { font-size: 10px; color: #cbd5e1; }
        .assignee-chip {
            background: #f1f5f9; padding: 2px 10px; border-radius: 12px; font-weight: 500;
        }
        .assignee-dot {
            width: 7px; height: 7px; border-radius: 50%; flex-shrink: 0;
        }
        .dot-pending { background: #94a3b8; }
        .dot-inprogress { background: #6366f1; }
        .dot-completed { background: #10b981; }
        .role-label {
            font-size: 10px; color: #94a3b8; font-weight: 400; margin-left: 2px;
        }
        .due-chip { font-weight: 500; }
        .overdue-text { color: #f43f5e !important; font-weight: 600; }
        .overdue-text i { color: #f43f5e !important; }
        .due-soon-text { color: #f59e0b !important; font-weight: 600; }
        .tag-chip {
            padding: 1px 8px; border-radius: 6px; font-size: 11px; font-weight: 600;
        }

        /* ─── Status Badge ─── */
        .card-status { flex-shrink: 0; }
        .status-badge {
            font-size: 11px; font-weight: 600; padding: 3px 10px;
            border-radius: 6px; white-space: nowrap;
        }
        .status-open { background: #fef3c7; color: #92400e; }
        .status-inprogress { background: #e0e7ff; color: #3730a3; }
        .status-completed { background: #d1fae5; color: #065f46; }
        .status-blocked { background: #fef2f2; color: #991b1b; }
        .status-cancelled { background: #f1f5f9; color: #64748b; }

        /* ─── Quick Add ─── */
        .quick-add-row {
            display: flex; align-items: center; gap: 10px;
            padding: 12px 20px; margin-top: 4px;
            border: 1px dashed #d1d5db; border-radius: 14px;
            transition: border-color 0.15s, background 0.15s;
        }
        .quick-add-row:focus-within {
            border-color: #6366f1; background: #fafbff;
        }
        .quick-add-icon { color: #94a3b8; font-size: 13px; }
        .quick-add-input {
            flex: 1; border: none; background: transparent; font-size: 14px;
            font-family: inherit; outline: none; color: #1e293b;
        }
        .quick-add-input::placeholder { color: #94a3b8; }
        .quick-add-btn {
            padding: 5px 14px; border: none; border-radius: 8px;
            background: #6366f1; color: #fff; font-size: 13px; font-weight: 600;
            cursor: pointer; font-family: inherit; flex-shrink: 0;
        }
        .quick-add-person {
            padding: 4px 8px; border: 1px solid #e2e8f0; border-radius: 8px;
            font-size: 13px; font-family: inherit; color: #475569;
            background: #fff; max-width: 180px; flex-shrink: 0;
        }
        .quick-add-person:focus { border-color: #6366f1; outline: none; }
        .quick-add-btn:disabled { opacity: 0.4; }

        /* ─── Empty State ─── */
        .empty-state { text-align: center; padding: 64px 24px; }
        .empty-state i { font-size: 40px; color: #e2e8f0; display: block; margin-bottom: 16px; }
        .empty-state p { font-size: 15px; font-weight: 500; color: #94a3b8; margin: 0; }

        /* ─── Responsive ─── */
        @media (max-width: 768px) {
            .toolbar { flex-direction: column; align-items: stretch; }
            .search-input { width: 100%; }
            .filter-pills { flex-wrap: wrap; }
            .task-card { padding: 12px 14px; gap: 10px; }
        }
    `]
})
/**
 * Embeddable, filterable task list with hierarchical display, multi-select,
 * bulk operations, search, and urgency indicators.
 *
 * Renders tasks as premium cards with priority dots, progress bars, assignee
 * chips, tags, and status badges. Supports parent/child hierarchy with
 * indentation, and flattens orphaned sub-tasks when filtering.
 *
 * **No routing** — raises events only. Consuming apps wire events to their
 * own navigation or panel logic.
 *
 * @example
 * ```html
 * <bizapps-task-list
 *     [CategoryID]="committeeCategoryId"
 *     [ShowCreateButton]="isOfficer"
 *     (BeforeTaskSelected)="onBeforeSelect($event)"
 *     (AfterTaskSelected)="onTaskSelected($event)"
 *     (CreateTask)="openNewTaskPanel()">
 * </bizapps-task-list>
 * ```
 */
export class TaskListComponent implements OnInit {
    // ── Inputs ──────────────────────────────────────────────

    /**
     * Filter tasks to a specific category. Pass a TaskCategory ID to scope
     * the list (e.g., to a single committee). Pass `null` to show all categories.
     */
    @Input() CategoryID: string | null = null;

    /**
     * Additional SQL WHERE clause filter appended to the task query.
     * Use this for advanced filtering beyond CategoryID, e.g.:
     * `"ID IN (SELECT TaskID FROM ... WHERE ...)"`.
     */
    @Input() ExtraFilter: string | null = null;

    /**
     * Pre-select a status filter on initialization. Must match one of:
     * `'Open'`, `'InProgress'`, `'Blocked'`, `'Completed'`, `'Cancelled'`.
     * Pass `null` to default to "All".
     */
    @Input() StatusFilter: string | null = null;

    /**
     * Whether to show the "+ New Task" button in the toolbar.
     * Typically bound to a permission check (e.g., `isOfficer`).
     * @default false
     */
    @Input() ShowCreateButton = false;

    /**
     * Compact mode reduces padding, hides descriptions, and optimizes for
     * scanning on small screens or embedded widgets.
     * @default false
     */
    @Input() Compact = false;

    /**
     * Whether to show the quick-add inline input at the bottom of the list.
     * Creates a task with just a name and sensible defaults (Status=Open,
     * Priority=Medium, CategoryID from the component's CategoryID input).
     * @default false
     */
    @Input() ShowQuickAdd = false;

    /**
     * Default TypeID used when creating tasks via quick-add.
     * If not set, the first active TaskType is used.
     */
    @Input() QuickAddDefaultTypeID: string | null = null;

    /**
     * Narrows the assignee person picker in quick-add. Accepts either:
     * - A SQL `ExtraFilter` string (e.g. `"ID IN (SELECT PersonID FROM ...)"`)
     * - An array of Person ID strings to include
     *
     * When `null`, all people in BizAppsCommon are shown.
     */
    @Input() AssigneeScope: string | string[] | null = null;

    // ── Outputs ─────────────────────────────────────────────

    /**
     * Emitted **before** a task is selected (clicked). The event is cancellable:
     * set `event.Cancel = true` in the handler to prevent the selection.
     */
    @Output() BeforeTaskSelected = new EventEmitter<BeforeTaskSelectedEvent>();

    /**
     * Emitted **after** a task is selected. Contains the full {@link TaskRow}
     * data for the selected task. Use this to open a detail or edit panel.
     */
    @Output() AfterTaskSelected = new EventEmitter<TaskRow>();

    /**
     * Emitted **before** a bulk status change is applied to each task.
     * The event is cancellable per-task.
     */
    @Output() BeforeStatusChange = new EventEmitter<BeforeStatusChangeEvent>();

    /**
     * Emitted **after** a bulk status change has been applied to a task.
     */
    @Output() AfterStatusChange = new EventEmitter<TaskRow>();

    /**
     * Emitted when the user clicks the "+ New Task" button.
     * The consuming app should open its create-task flow in response.
     */
    @Output() CreateTask = new EventEmitter<void>();

    /**
     * Emitted after a task is created via the quick-add input.
     * Payload is the new task's ID.
     */
    @Output() AfterTaskCreated = new EventEmitter<string>();

    // ── Internal State ──────────────────────────────────────

    /** @internal Full unfiltered task list. */
    tasks: TaskRow[] = [];
    /** @internal Currently visible tasks after filtering. */
    filteredTasks: TaskRow[] = [];
    /** @internal IDs of tasks selected via checkboxes for bulk operations. */
    selectedIDs: string[] = [];
    /** @internal IDs of parent tasks that are expanded to show children. */
    expandedIDs = new Set<string>();
    /** @internal */
    quickAddName = '';
    /** @internal */
    quickAddPersonID = '';
    /** @internal */
    quickAddPeople: any[] = [];
    /** @internal */
    quickAdding = false;
    /** @internal */
    bulkStatus = '';
    /** @internal */
    bulkPercent: number | null = null;
    /** @internal */
    loading = false;
    /** @internal */
    searchText = '';
    /** @internal */
    statusFilter = '';
    /** @internal */
    private searchTimeout: any;
    /** @internal */
    cdr = inject(ChangeDetectorRef);

    /** @internal Status filter pill definitions. */
    statusFilters = [
        { label: 'All', value: '' },
        { label: 'Open', value: 'Open' },
        { label: 'In Progress', value: 'InProgress' },
        { label: 'Blocked', value: 'Blocked' },
        { label: 'Completed', value: 'Completed' },
    ];

    // ── Lifecycle ───────────────────────────────────────────

    ngOnInit(): void {
        if (this.StatusFilter) this.statusFilter = this.StatusFilter;
        this.loadTasks();
        if (this.ShowQuickAdd) this.loadQuickAddPeople();
    }

    // ── Public Methods ──────────────────────────────────────

    /**
     * Reloads all task data from the server and re-applies filters.
     * Call this after external changes (e.g., a task was created or
     * updated via a different component).
     */
    async Refresh(): Promise<void> { await this.loadTasks(); }

    /**
     * Programmatically selects a task by ID, triggering the same
     * Before/After event flow as a user click.
     * @param taskID - The ID of the task to select.
     */
    SelectTask(taskID: string): void {
        const task = this.tasks.find(t => t.ID === taskID);
        if (task) this.onTaskClick(task);
    }

    /**
     * Deselects all checked tasks and hides the bulk action bar.
     */
    ClearSelection(): void {
        this.selectedIDs = [];
        this.cdr.markForCheck();
    }

    /**
     * Toggles the expand/collapse state of a parent task.
     * @param taskID - The parent task ID to toggle.
     */
    ToggleExpand(taskID: string): void {
        if (this.expandedIDs.has(taskID)) {
            this.expandedIDs.delete(taskID);
        } else {
            this.expandedIDs.add(taskID);
        }
        this.cdr.markForCheck();
    }

    /** @internal Template helper — toggles expand state. */
    toggleExpand(taskID: string): void { this.ToggleExpand(taskID); }

    /** @internal Returns true if the task's parent is expanded (or task is top-level). */
    isParentExpanded(task: TaskRow): boolean {
        if (!task.ParentID) return true;
        return this.expandedIDs.has(task.ParentID);
    }

    // ── Quick Add ───────────────────────────────────────────

    /** @internal Loads people for the quick-add assignee picker. */
    private async loadQuickAddPeople(): Promise<void> {
        let extraFilter: string | undefined;
        if (Array.isArray(this.AssigneeScope)) {
            const ids = this.AssigneeScope.map(id => `'${id}'`).join(',');
            extraFilter = `ID IN (${ids})`;
        } else if (typeof this.AssigneeScope === 'string' && this.AssigneeScope) {
            extraFilter = this.AssigneeScope;
        }
        const rv = new RunView();
        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Common: People',
            ExtraFilter: extraFilter,
            OrderBy: 'LastName ASC, FirstName ASC',
            ResultType: 'simple',
        });
        this.quickAddPeople = result?.Results ?? [];
        this.cdr.markForCheck();
    }

    /**
     * Creates a task with just a name via the inline quick-add input.
     * Uses sensible defaults: Status=Open, Priority=Medium, CategoryID
     * from the component's input, first active TaskType.
     */
    async quickAddTask(): Promise<void> {
        const name = this.quickAddName.trim();
        if (!name || this.quickAdding) return;
        this.quickAdding = true;
        this.cdr.markForCheck();

        try {
            // Resolve default TypeID if not provided
            let typeID = this.QuickAddDefaultTypeID;
            if (!typeID) {
                const rv = new RunView();
                const types = await rv.RunView<any>({
                    EntityName: 'MJ.BizApps.Tasks: Task Types',
                    ExtraFilter: 'IsActive = 1',
                    OrderBy: 'Name ASC',
                    MaxRows: 1,
                    ResultType: 'simple',
                });
                typeID = types?.Results?.[0]?.ID ?? null;
            }

            if (!typeID) {
                console.error('Quick-add failed: no TaskType found. Ensure at least one active Task Type exists.');
                return;
            }

            const entity = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Tasks');
            entity.NewRecord();
            entity.Set('Name', name);
            entity.Set('Status', 'Open');
            entity.Set('Priority', 'Medium');
            entity.Set('TypeID', typeID);
            if (this.CategoryID) entity.Set('CategoryID', this.CategoryID);
            const saved = await entity.Save();

            if (!saved) {
                console.error('Quick-add Save() returned false. LatestResult:', entity.LatestResult);
                return;
            }

            const savedID = entity.Get('ID') as string;

            // Create assignment if a person was selected
            if (this.quickAddPersonID) {
                try {
                    const peEntityResult = await new RunView().RunView<any>({
                        EntityName: 'MJ: Entities',
                        ExtraFilter: `Name = 'MJ.BizApps.Common: People'`,
                        ResultType: 'simple',
                        MaxRows: 1,
                    });
                    const peopleEntityID = peEntityResult?.Results?.[0]?.ID;
                    if (peopleEntityID) {
                        const assignment = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Task Assignments');
                        assignment.NewRecord();
                        assignment.Set('TaskID', savedID);
                        assignment.Set('AssigneeEntityID', peopleEntityID);
                        assignment.Set('AssigneeRecordID', this.quickAddPersonID);
                        assignment.Set('Status', 'Pending');
                        await assignment.Save();
                    }
                } catch (e) {
                    console.error('Quick-add assignment failed:', e);
                }
            }

            this.quickAddName = '';
            this.quickAddPersonID = '';
            this.AfterTaskCreated.emit(savedID);
            await this.loadTasks();
        } catch (e) {
            console.error('Quick-add failed:', e);
        }

        this.quickAdding = false;
        this.cdr.markForCheck();
    }

    formatStatus(status: string): string {
        if (!status) return '';
        return status.replace(/([a-z])([A-Z])/g, '$1 $2');
    }

    async loadTasks(): Promise<void> {
        this.loading = true;
        this.cdr.markForCheck();

        const rv = new RunView();
        const filters: string[] = [];
        if (this.CategoryID) filters.push(`CategoryID = '${this.CategoryID}'`);
        if (this.ExtraFilter) filters.push(this.ExtraFilter);

        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Tasks',
            ExtraFilter: filters.length ? filters.join(' AND ') : undefined,
            OrderBy: 'Sequence ASC, DueAt ASC',
            ResultType: 'simple',
        });

        const now = new Date();
        const soon = new Date(now.getTime() + 48 * 60 * 60 * 1000);
        const rawTasks = result?.Results ?? [];

        // Build parent-child map for depth and child counts
        const childCounts = new Map<string, number>();
        for (const r of rawTasks) {
            if (r.ParentID) childCounts.set(r.ParentID, (childCounts.get(r.ParentID) ?? 0) + 1);
        }

        // Calculate depth
        const depthMap = new Map<string, number>();
        const getDepth = (id: string): number => {
            if (depthMap.has(id)) return depthMap.get(id)!;
            const r = rawTasks.find((t: any) => t.ID === id);
            if (!r?.ParentID) { depthMap.set(id, 0); return 0; }
            const d = getDepth(r.ParentID) + 1;
            depthMap.set(id, d);
            return d;
        };
        for (const r of rawTasks) getDepth(r.ID);

        // Sort: parents first, then children grouped under parents
        const sorted = this.sortHierarchically(rawTasks, depthMap);

        this.tasks = sorted.map((r: any) => {
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
                HoursEstimated: r.HoursEstimated,
                ParentID: r.ParentID,
                Depth: depthMap.get(r.ID) ?? 0,
                Assignees: [],
                Tags: [],
                IsOverdue: isActive && dueAt != null && dueAt < now,
                IsDueSoon: isActive && dueAt != null && dueAt >= now && dueAt <= soon,
                ChildCount: childCounts.get(r.ID) ?? 0,
            } as TaskRow;
        });

        // Load assignees and tags in parallel
        await Promise.all([this.loadAssignees(), this.loadTags()]);
        this.applyFilters();
        this.loading = false;
        this.cdr.markForCheck();
    }

    private async loadAssignees(): Promise<void> {
        if (this.tasks.length === 0) return;
        const rv = new RunView();
        const taskIDs = this.tasks.map(t => `'${t.ID}'`).join(',');

        const [assignments, people] = await Promise.all([
            rv.RunView<any>({
                EntityName: 'MJ.BizApps.Tasks: Task Assignments',
                ExtraFilter: `TaskID IN (${taskIDs})`,
                ResultType: 'simple',
            }),
            new RunView().RunView<any>({
                EntityName: 'MJ.BizApps.Common: People',
                ResultType: 'simple',
            }),
        ]);

        // Load roles
        const roles = await new RunView().RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Task Roles',
            ResultType: 'simple',
        });

        const personMap = new Map<string, string>();
        for (const p of people?.Results ?? []) {
            personMap.set(p.ID, `${p.FirstName} ${p.LastName}`);
        }

        const roleMap = new Map<string, string>();
        for (const r of roles?.Results ?? []) {
            roleMap.set(r.ID, r.Name);
        }

        for (const a of assignments?.Results ?? []) {
            const task = this.tasks.find(t => t.ID === a.TaskID);
            if (!task) continue;
            task.Assignees.push({
                Name: personMap.get(a.AssigneeRecordID) ?? 'Unknown',
                Role: roleMap.get(a.RoleID) ?? 'Primary',
                Status: a.Status ?? 'Pending',
            });
        }
    }

    private async loadTags(): Promise<void> {
        if (this.tasks.length === 0) return;
        const rv = new RunView();
        const taskIDs = this.tasks.map(t => `'${t.ID}'`).join(',');

        const [tagLinks, tags] = await Promise.all([
            rv.RunView<any>({
                EntityName: 'MJ.BizApps.Tasks: Task Tag Links',
                ExtraFilter: `TaskID IN (${taskIDs})`,
                ResultType: 'simple',
            }),
            new RunView().RunView<any>({
                EntityName: 'MJ.BizApps.Tasks: Task Tags',
                ResultType: 'simple',
            }),
        ]);

        const tagMap = new Map<string, { Name: string; Color: string }>();
        for (const t of tags?.Results ?? []) {
            tagMap.set(t.ID, { Name: t.Name, Color: t.ColorCode ?? '#6366f1' });
        }

        for (const link of tagLinks?.Results ?? []) {
            const task = this.tasks.find(t => t.ID === link.TaskID);
            const tag = tagMap.get(link.TagID);
            if (task && tag) task.Tags.push(tag);
        }
    }

    private sortHierarchically(items: any[], depthMap: Map<string, number>): any[] {
        const result: any[] = [];
        const childrenOf = new Map<string | null, any[]>();

        for (const item of items) {
            const parentID = item.ParentID || null;
            if (!childrenOf.has(parentID)) childrenOf.set(parentID, []);
            childrenOf.get(parentID)!.push(item);
        }

        const addChildren = (parentID: string | null) => {
            const children = childrenOf.get(parentID) ?? [];
            for (const child of children) {
                result.push(child);
                addChildren(child.ID);
            }
        };

        addChildren(null);
        return result;
    }

    // -- Filtering --
    onSearchChange(): void {
        clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => { this.applyFilters(); this.cdr.markForCheck(); }, 200);
    }

    applyFilters(): void {
        let filtered = this.tasks;

        if (this.statusFilter) {
            filtered = filtered.filter(t => t.Status === this.statusFilter);
        }

        if (this.searchText.trim()) {
            const q = this.searchText.toLowerCase();
            filtered = filtered.filter(t =>
                t.Name.toLowerCase().includes(q) ||
                (t.Description ?? '').toLowerCase().includes(q)
            );
        }

        // Reset depth for tasks whose parent isn't in the filtered set
        const filteredIDs = new Set(filtered.map(t => t.ID));
        this.filteredTasks = filtered.map(t => ({
            ...t,
            Depth: t.ParentID && filteredIDs.has(t.ParentID) ? t.Depth : 0,
        }));
    }

    // -- Selection + Bulk --
    toggleSelect(taskID: string): void {
        const idx = this.selectedIDs.indexOf(taskID);
        if (idx >= 0) this.selectedIDs.splice(idx, 1);
        else this.selectedIDs.push(taskID);
        this.cdr.markForCheck();
    }

    async applyBulkStatus(): Promise<void> {
        if (!this.bulkStatus || this.selectedIDs.length === 0) return;
        const status = this.bulkStatus;
        const pct = this.bulkPercent;
        // Clear selection immediately so UI updates
        const ids = [...this.selectedIDs];
        this.selectedIDs = [];
        this.bulkStatus = '';
        this.bulkPercent = null;
        this.cdr.markForCheck();

        for (const id of ids) {
            try {
                const entity = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Tasks');
                const pk = new CompositeKey([{ FieldName: 'ID', Value: id }]);
                await entity.InnerLoad(pk);
                entity.Set('Status', status);
                if (status === 'InProgress' && pct != null) {
                    entity.Set('PercentComplete', Math.min(100, Math.max(0, pct)));
                }
                if (status === 'Completed') {
                    entity.Set('PercentComplete', 100);
                }
                await entity.Save();
            } catch (e) {
                console.error(`Failed to update task ${id}:`, e);
            }
        }
        await this.loadTasks();
    }

    // -- Events --
    onTaskClick(task: TaskRow): void {
        const before = new BeforeTaskSelectedEvent(task);
        this.BeforeTaskSelected.emit(before);
        if (before.Cancel) return;
        this.AfterTaskSelected.emit(task);
    }
}
