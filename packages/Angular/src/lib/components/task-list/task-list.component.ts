import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, inject, Input, OnInit, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Metadata, RunView, CompositeKey } from '@memberjunction/core';

export interface TaskRow {
    ID: string;
    Name: string;
    Description: string | null;
    Status: string;
    Priority: string;
    DueAt: Date | null;
    PercentComplete: number;
    HoursEstimated: number | null;
    ParentID: string | null;
    Depth: number;
    Assignees: { Name: string; Role: string; Status: string }[];
    Tags: { Name: string; Color: string }[];
    IsOverdue: boolean;
    IsDueSoon: boolean;
    ChildCount: number;
}

export class BeforeTaskSelectedEvent {
    Cancel = false;
    constructor(public Task: TaskRow) {}
}

export class BeforeStatusChangeEvent {
    Cancel = false;
    constructor(public Task: TaskRow, public NewStatus: string) {}
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

            <!-- Task cards -->
            @if (!loading) {
                <div class="task-grid">
                    @for (task of filteredTasks; track task.ID) {
                        <div class="task-card"
                             [class.overdue]="task.IsOverdue"
                             [class.completed]="task.Status === 'Completed'"
                             [class.sub-task]="task.Depth > 0"
                             [style.margin-left.px]="task.Depth * 28"
                             (click)="onTaskClick(task)">

                            <!-- Priority dot -->
                            <div [class]="'priority-dot priority-' + task.Priority.toLowerCase()"></div>

                            <!-- Content -->
                            <div class="card-content">
                                <div class="card-title-row">
                                    <h4 class="card-title">
                                        @if (task.ChildCount > 0) {
                                            <i class="fa-solid fa-folder-open parent-icon"></i>
                                        }
                                        @if (task.Depth > 0 && task.ParentID) {
                                            <i class="fa-solid fa-turn-up fa-flip-horizontal sub-icon"></i>
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
                    }
                </div>
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

        /* ─── Task Grid ─── */
        .task-grid { display: flex; flex-direction: column; gap: 8px; }

        .task-card {
            background: #fff; border-radius: 14px; padding: 16px 20px;
            display: flex; align-items: flex-start; gap: 14px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            transition: box-shadow 0.25s ease, transform 0.25s ease;
            cursor: pointer;
        }
        .task-card:hover {
            box-shadow: 0 8px 30px rgba(0,0,0,0.07);
            transform: translateY(-1px);
        }
        .task-card.overdue {
            background: #fff5f5; border-left: 3px solid #f43f5e;
        }
        .task-card.completed { opacity: 0.55; }
        .task-card.sub-task { border-radius: 10px; padding: 12px 16px; }

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
        .parent-icon { font-size: 12px; color: #6366f1; }
        .sub-icon { font-size: 10px; color: #94a3b8; }
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
export class TaskListComponent implements OnInit {
    @Input() CategoryID: string | null = null;
    @Input() ExtraFilter: string | null = null;
    @Input() StatusFilter: string | null = null;
    @Input() ShowCreateButton = false;
    @Input() Compact = false;

    @Output() BeforeTaskSelected = new EventEmitter<BeforeTaskSelectedEvent>();
    @Output() AfterTaskSelected = new EventEmitter<TaskRow>();
    @Output() BeforeStatusChange = new EventEmitter<BeforeStatusChangeEvent>();
    @Output() AfterStatusChange = new EventEmitter<TaskRow>();
    @Output() CreateTask = new EventEmitter<void>();

    tasks: TaskRow[] = [];
    filteredTasks: TaskRow[] = [];
    loading = false;
    searchText = '';
    statusFilter = '';
    private searchTimeout: any;
    private cdr = inject(ChangeDetectorRef);

    statusFilters = [
        { label: 'All', value: '' },
        { label: 'Open', value: 'Open' },
        { label: 'In Progress', value: 'InProgress' },
        { label: 'Blocked', value: 'Blocked' },
        { label: 'Completed', value: 'Completed' },
    ];

    ngOnInit(): void {
        if (this.StatusFilter) this.statusFilter = this.StatusFilter;
        this.loadTasks();
    }

    Refresh(): void { this.loadTasks(); }

    SelectTask(taskID: string): void {
        const task = this.tasks.find(t => t.ID === taskID);
        if (task) this.onTaskClick(task);
    }

    ClearSelection(): void {}

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
                Role: roleMap.get(a.RoleID) ?? 'Assignee',
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

    // -- Events --
    onTaskClick(task: TaskRow): void {
        const before = new BeforeTaskSelectedEvent(task);
        this.BeforeTaskSelected.emit(before);
        if (before.Cancel) return;
        this.AfterTaskSelected.emit(task);
    }
}
