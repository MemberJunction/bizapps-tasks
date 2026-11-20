import { Component, EventEmitter, Input, Output, OnInit, ViewChild, ChangeDetectionStrategy, ChangeDetectorRef, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { BaseEntity, LogError, Metadata, RunView, type IMetadataProvider, type IRunViewProvider } from '@memberjunction/core';
import { ResolveCurrentPersonID } from '../current-person';
import { OpenTaskRecord } from '../open-task-record';
import { TaskListComponent } from '../components/task-list/task-list.component';
import { TaskKanbanComponent } from '../components/task-kanban/task-kanban.component';
import { TaskGanttComponent } from '../components/task-gantt/task-gantt.component';
import { TaskDetailPanelComponent } from '../components/task-detail-panel/task-detail-panel.component';
import { TaskEditPanelComponent } from '../components/task-edit-panel/task-edit-panel.component';
import { TaskTemplateWizardComponent } from '../components/task-template-wizard/task-template-wizard.component';
import { TaskViewMode } from '../components/task-panel/task-panel.component';
import { MJViewToggleComponent, ViewToggleOption } from '@memberjunction/ng-ui-components';
import {
    BuildPendingSuggestionsSqlFilter,
    CountTotalPendingSuggestions,
    TaskFieldSuggestionsHelper,
    type TaskPendingSuggestionsSummary,
} from '../task-field-suggestions.helper';

export type { TaskViewMode };
export type TasksDashboardPanelMode = 'none' | 'detail' | 'edit' | 'template';

export interface TaskCategoryOption {
    ID: string;
    Name: string;
}

export interface TaskKPIs {
    TotalActive: number;
    InProgress: number;
    Blocked: number;
    Overdue: number;
    AvgPercentComplete: number;
}

/**
 * Tasks Dashboard Page — central task management workspace combining
 * interactive Gantt timeline scheduling, Kanban workflow boards, and structured list grids.
 */
@Component({
    selector: 'bizapps-tasks-dashboard-page',
    standalone: true,
    imports: [
        CommonModule,
        FormsModule,
        TaskListComponent,
        TaskKanbanComponent,
        TaskGanttComponent,
        TaskDetailPanelComponent,
        TaskEditPanelComponent,
        TaskTemplateWizardComponent,
        MJViewToggleComponent,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="mjt-dashboard">
            <!-- 1. Header Toolbar & Quick Stats -->
            <div class="mjt-header-card">
                <div class="mjt-header-top">
                    <div class="mjt-identity">
                        <div class="mjt-avatar">
                            <i class="fa-solid fa-list-check" aria-hidden="true"></i>
                        </div>
                        <div class="mjt-title-area">
                            <h1 class="mjt-title">Task Management &amp; Scheduling</h1>
                            <p class="mjt-subtitle">Deliverable tracking, Kanban board workflows, and Gantt timeline scheduling.</p>
                        </div>
                    </div>

                    <div class="mjt-actions-strip">
                        <!-- View Toggle -->
                        <mj-view-toggle
                            [Options]="ViewToggleOptions"
                            [ActiveKey]="ViewMode"
                            (KeyChange)="onViewToggleChange($event)">
                        </mj-view-toggle>

                        <button type="button" class="mjt-btn-secondary" (click)="OpenPanel('template')">
                            <i class="fa-solid fa-copy"></i> From Template
                        </button>
                        <button type="button" class="mjt-btn-primary" (click)="OpenPanel('edit', null)">
                            <i class="fa-solid fa-plus"></i> New Task
                        </button>
                    </div>
                </div>

                <!-- Live KPI Stat Strip -->
                <div class="mjt-kpi-bar">
                    <div class="mjt-kpi-tile">
                        <span class="mjt-kpi-label">Active Tasks</span>
                        <span class="mjt-kpi-val">{{ KPIs.TotalActive }}</span>
                    </div>
                    <div class="mjt-kpi-tile">
                        <span class="mjt-kpi-label">In Progress</span>
                        <span class="mjt-kpi-val mjt-val--blue">{{ KPIs.InProgress }}</span>
                    </div>
                    <div class="mjt-kpi-tile">
                        <span class="mjt-kpi-label">Blocked</span>
                        <span class="mjt-kpi-val" [class.mjt-val--red]="KPIs.Blocked > 0">{{ KPIs.Blocked }}</span>
                    </div>
                    <div class="mjt-kpi-tile">
                        <span class="mjt-kpi-label">Overdue</span>
                        <span class="mjt-kpi-val" [class.mjt-val--amber]="KPIs.Overdue > 0">{{ KPIs.Overdue }}</span>
                    </div>
                    <div class="mjt-kpi-tile">
                        <span class="mjt-kpi-label">Avg Completion</span>
                        <span class="mjt-kpi-val mjt-val--green">{{ KPIs.AvgPercentComplete }}%</span>
                    </div>
                </div>

                <!-- Secondary Filter Bar -->
                <div class="mjt-filter-bar">
                    <div class="mjt-filter-item">
                        <label class="mjt-filter-label"><i class="fa-solid fa-folder-tree"></i> Category</label>
                        <select class="mjt-filter-select" [(ngModel)]="SelectedCategoryID" (ngModelChange)="OnCategoryChanged()">
                            <option [ngValue]="null">All Categories</option>
                            @for (cat of Categories; track cat.ID) {
                                <option [value]="cat.ID">{{ cat.Name }}</option>
                            }
                        </select>
                    </div>

                    @if (SelectedCategoryID) {
                        <button type="button" class="mjt-btn-clear" (click)="ClearCategoryFilter()">
                            <i class="fa-solid fa-xmark"></i> Clear Category
                        </button>
                    }

                    @if (FieldSuggestionsAvailable || TotalPendingSuggestionsCount > 0 || OnlyPendingSuggestions) {
                        <button type="button"
                                class="mjt-suggestion-pill"
                                [class.mjt-suggestion-pill--active]="OnlyPendingSuggestions"
                                [attr.aria-pressed]="OnlyPendingSuggestions"
                                [attr.title]="PendingSuggestionsFilterTooltip"
                                (click)="TogglePendingSuggestions()">
                            <i class="fa-solid fa-wand-magic-sparkles" aria-hidden="true"></i>
                            <span>Pending Suggestions</span>
                            @if (TotalPendingSuggestionsCount > 0) {
                                <span class="mjt-suggestion-pill__count">{{ TotalPendingSuggestionsCount }}</span>
                            }
                        </button>
                    }

                    @if (OnlyPendingSuggestions) {
                        <button type="button" class="mjt-btn-clear" (click)="OnPendingSuggestionsChanged(false)">
                            <i class="fa-solid fa-xmark" aria-hidden="true"></i> Clear Suggestions Filter
                        </button>
                    }
                </div>
            </div>

            <!-- 2. Workspace View Body -->
            <div class="mjt-body-card">
                @if (ViewMode === 'gantt') {
                    <bizapps-task-gantt
                        #taskGantt
                        [CategoryID]="SelectedCategoryID"
                        [ExtraFilter]="GanttExtraFilter"
                        [Height]="'calc(100vh - 340px)'"
                        (TaskDoubleClicked)="OpenPanel('detail', $event)">
                    </bizapps-task-gantt>
                }
                @if (ViewMode === 'kanban') {
                    <bizapps-task-kanban
                        #taskKanban
                        [Provider]="Provider"
                        [CategoryID]="SelectedCategoryID"
                        [PendingSuggestionsOnly]="OnlyPendingSuggestions"
                        (TaskClicked)="OpenPanel('detail', $event)"
                        (TaskDoubleClicked)="OpenFullRecord($event)">
                    </bizapps-task-kanban>
                }
                @if (ViewMode === 'list') {
                    <bizapps-task-list
                        #taskList
                        [Provider]="Provider"
                        [CategoryID]="SelectedCategoryID"
                        [PendingSuggestionsOnly]="OnlyPendingSuggestions"
                        (PendingSuggestionsOnlyChange)="OnPendingSuggestionsChanged($event)"
                        [ShowCreateButton]="false"
                        (AfterTaskSelected)="OpenPanel('detail', $event.ID)"
                        (TaskDoubleClicked)="OpenFullRecord($event.ID)"
                        (CreateTask)="OpenPanel('edit', null)">
                    </bizapps-task-list>
                }
            </div>

            <!-- 3. Slide-in Side Drawer Overlay -->
            @if (PanelMode !== 'none') {
                <div class="mjt-panel-backdrop" (click)="ClosePanel()"></div>
                <aside class="mjt-side-panel">
                    @if (PanelMode === 'detail') {
                        <bizapps-task-detail-panel
                            [Provider]="Provider"
                            [TaskID]="SelectedTaskID"
                            [PersonID]="CurrentPersonID"
                            [ShowDelete]="true"
                            (EditRequested)="OpenPanel('edit', $event)"
                            (OpenRecordRequested)="OpenFullRecord($event)"
                            (DeleteRequested)="OnTaskDeleted()"
                            (Close)="ClosePanel()">
                        </bizapps-task-detail-panel>
                    }
                    @if (PanelMode === 'edit') {
                        <bizapps-task-edit-panel
                            [TaskID]="SelectedTaskID"
                            [DefaultCategoryID]="SelectedCategoryID"
                            (Saved)="OnTaskSaved($event)"
                            (Cancel)="ClosePanel()">
                        </bizapps-task-edit-panel>
                    }
                    @if (PanelMode === 'template') {
                        <bizapps-task-template-wizard
                            [DefaultCategoryID]="SelectedCategoryID"
                            (Created)="OnTemplateCreated($event)"
                            (Cancelled)="ClosePanel()">
                        </bizapps-task-template-wizard>
                    }
                </aside>
            }
        </div>
    `,
    styles: [`
        :host { display: block; width: 100%; height: 100%; }
        .mjt-dashboard { display: flex; flex-direction: column; gap: 16px; padding: 16px; min-width: 0; box-sizing: border-box; }

        /* Header Card */
        .mjt-header-card {
            background: var(--mj-bg-surface-card, #ffffff);
            border: 1px solid var(--mj-border-default, #e2e8f0);
            border-radius: var(--mj-radius-lg, 12px);
            padding: 16px 20px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .mjt-header-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            flex-wrap: wrap;
        }

        .mjt-identity {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .mjt-avatar {
            width: 48px;
            height: 48px;
            border-radius: var(--mj-radius-md, 8px);
            background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            box-shadow: 0 4px 10px rgba(2, 132, 199, 0.25);
            flex-shrink: 0;
        }

        .mjt-title-area { display: flex; flex-direction: column; gap: 2px; }
        .mjt-title { margin: 0; font-size: 18px; font-weight: 700; color: var(--mj-text-primary, #0f172a); }
        .mjt-subtitle { margin: 0; font-size: 12px; color: var(--mj-text-muted, #64748b); }

        .mjt-actions-strip { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }

        .mjt-btn-primary {
            padding: 6px 14px;
            border-radius: var(--mj-radius-sm, 6px);
            border: none;
            background: var(--mj-brand-primary, #0076b6);
            color: #ffffff;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
            box-shadow: 0 2px 4px rgba(0, 118, 182, 0.25);
        }

        .mjt-btn-secondary {
            padding: 6px 12px;
            border-radius: var(--mj-radius-sm, 6px);
            border: 1px solid var(--mj-border-default, #cbd5e1);
            background: var(--mj-bg-surface-card, #ffffff);
            color: var(--mj-text-secondary, #475569);
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        /* KPI Bar */
        .mjt-kpi-bar {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 12px;
            padding-top: 12px;
            border-top: 1px solid var(--mj-border-default, #e2e8f0);
        }

        .mjt-kpi-tile { display: flex; flex-direction: column; gap: 2px; }
        .mjt-kpi-label { font-size: 11px; font-weight: 600; color: var(--mj-text-muted, #64748b); text-transform: uppercase; letter-spacing: 0.04em; }
        .mjt-kpi-val { font-size: 15px; font-weight: 700; font-family: var(--mj-font-mono, monospace); color: var(--mj-text-primary, #0f172a); }
        .mjt-val--blue { color: #0284c7; }
        .mjt-val--green { color: #16a34a; }
        .mjt-val--amber { color: #d97706; }
        .mjt-val--red { color: #dc2626; }

        /* Secondary Filter Bar */
        .mjt-filter-bar {
            display: flex;
            align-items: center;
            gap: 12px;
            padding-top: 10px;
            border-top: 1px dashed var(--mj-border-default, #e2e8f0);
            flex-wrap: wrap;
        }

        .mjt-filter-item { display: flex; align-items: center; gap: 6px; font-size: 12px; }
        .mjt-filter-label { font-weight: 600; color: var(--mj-text-muted, #64748b); display: flex; align-items: center; gap: 4px; }
        .mjt-filter-select {
            padding: 4px 8px;
            font-size: 12px;
            border: 1px solid var(--mj-border-default, #cbd5e1);
            border-radius: var(--mj-radius-sm, 6px);
            background: var(--mj-bg-surface-card, #ffffff);
            color: var(--mj-text-primary, #0f172a);
        }

        .mjt-btn-clear {
            padding: 3px 8px;
            font-size: 11px;
            color: var(--mj-text-muted, #64748b);
            background: transparent;
            border: 1px dashed var(--mj-border-default, #cbd5e1);
            border-radius: 4px;
            cursor: pointer;
        }

        .mjt-suggestion-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 12px;
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface);
            color: var(--mj-text-secondary);
            font-size: 12px;
            font-weight: var(--mj-font-semibold);
            font-family: inherit;
            cursor: pointer;
            transition: border-color 0.15s ease, background 0.15s ease, color 0.15s ease;
        }
        .mjt-suggestion-pill:hover {
            border-color: var(--mj-brand-primary);
            color: var(--mj-text-primary);
        }
        .mjt-suggestion-pill--active {
            border-color: var(--mj-brand-primary);
            color: var(--mj-brand-primary);
            background: color-mix(in srgb, var(--mj-brand-primary) 8%, var(--mj-bg-surface));
        }
        .mjt-suggestion-pill__count {
            font-size: 11px;
            font-weight: var(--mj-font-bold);
            padding: 1px 7px;
            border-radius: var(--mj-radius-md);
            background: var(--mj-status-info-bg);
            color: var(--mj-status-info-text);
        }
        .mjt-suggestion-pill--active .mjt-suggestion-pill__count {
            background: color-mix(in srgb, var(--mj-brand-primary) 14%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
        }
        .mjt-suggestion-pill:focus-visible {
            outline: 2px solid var(--mj-brand-primary);
            outline-offset: 2px;
        }

        /* Body Card */
        .mjt-body-card {
            background: var(--mj-bg-surface-card, #ffffff);
            border: 1px solid var(--mj-border-default, #e2e8f0);
            border-radius: var(--mj-radius-lg, 12px);
            padding: 16px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
            min-width: 0;
            display: flex;
            flex-direction: column;
            min-height: calc(100vh - 340px);
        }

        /* Slide-in Side Drawer */
        .mjt-panel-backdrop {
            position: fixed; inset: 0; background: rgba(0, 0, 0, 0.45);
            z-index: 999; animation: fadeIn 0.15s ease;
        }
        .mjt-side-panel {
            position: fixed; top: 0; right: 0; bottom: 0;
            width: 540px; max-width: 90vw;
            background: var(--mj-bg-surface-card, #ffffff); z-index: 1000;
            box-shadow: -4px 0 24px rgba(0, 0, 0, 0.15);
            overflow-y: auto;
            animation: slideIn 0.2s ease;
        }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        @keyframes slideIn { from { transform: translateX(100%); } to { transform: translateX(0); } }
    `]
})
export class TasksDashboardPageComponent implements OnInit {
    @Input() Provider: IMetadataProvider | null = null;

    private _onlyPendingSuggestions = false;

    @Input()
    public get OnlyPendingSuggestions(): boolean {
        return this._onlyPendingSuggestions;
    }
    public set OnlyPendingSuggestions(value: boolean) {
        const next = Boolean(value);
        if (next !== this._onlyPendingSuggestions) {
            this._onlyPendingSuggestions = next;
            this.cdr.markForCheck();
        }
    }

    @Output() OnlyPendingSuggestionsChange = new EventEmitter<boolean>();

    public get ProviderToUse(): IMetadataProvider {
        return this.Provider ?? Metadata.Provider;
    }

    public ViewToggleOptions: ViewToggleOption[] = [
        { key: 'gantt', icon: 'fa-solid fa-chart-gantt', label: 'Timeline', title: 'Timeline View' },
        { key: 'kanban', icon: 'fa-solid fa-table-columns', label: 'Board', title: 'Board View' },
        { key: 'list', icon: 'fa-solid fa-list', label: 'List', title: 'List View' },
    ];
    public ViewMode: TaskViewMode = 'gantt';
    public PanelMode: TasksDashboardPanelMode = 'none';
    public SelectedTaskID: string | null = null;
    public SelectedCategoryID: string | null = null;
    public CurrentPersonID: string | null = null;
    public FieldSuggestionsAvailable = false;
    public PendingSuggestionsByTask = new Map<string, TaskPendingSuggestionsSummary>();
    public TotalPendingSuggestionsCount = 0;

    public Categories: TaskCategoryOption[] = [];
    public KPIs: TaskKPIs = {
        TotalActive: 0,
        InProgress: 0,
        Blocked: 0,
        Overdue: 0,
        AvgPercentComplete: 0,
    };

    @ViewChild('taskGantt') taskGantt?: TaskGanttComponent;
    @ViewChild('taskKanban') taskKanban?: TaskKanbanComponent;
    @ViewChild('taskList') taskList?: TaskListComponent;

    private cdr = inject(ChangeDetectorRef);

    public get GanttExtraFilter(): string | null {
        return BuildPendingSuggestionsSqlFilter(this._onlyPendingSuggestions, this.PendingSuggestionsByTask);
    }

    public get PendingSuggestionsFilterTooltip(): string {
        if (this.TotalPendingSuggestionsCount <= 0) {
            return 'Filter to tasks with pending AI/ambient field suggestions';
        }
        const taskCount = this.PendingSuggestionsByTask.size;
        const suggNoun = this.TotalPendingSuggestionsCount === 1 ? 'pending suggestion' : 'pending suggestions';
        const taskNoun = taskCount === 1 ? 'task' : 'tasks';
        return `${this.TotalPendingSuggestionsCount} ${suggNoun} across ${taskCount} ${taskNoun}`;
    }

    public TogglePendingSuggestions(): void {
        this.OnPendingSuggestionsChanged(!this._onlyPendingSuggestions);
    }

    public OnPendingSuggestionsChanged(next: boolean): void {
        const normalized = Boolean(next);
        if (normalized !== this._onlyPendingSuggestions) {
            this._onlyPendingSuggestions = normalized;
            this.OnlyPendingSuggestionsChange.emit(normalized);
            this.cdr.markForCheck();
        }
    }

    private createRunView(): RunView {
        const p = this.ProviderToUse;
        if (p && typeof (p as Partial<IRunViewProvider>).RunView === 'function') {
            return RunView.FromMetadataProvider(p);
        }
        return new RunView();
    }

    public OpenFullRecord(taskID: string | null): void {
        OpenTaskRecord(taskID);
    }

    async ngOnInit(): Promise<void> {
        const [personID] = await Promise.all([
            // The dashboard works without a Person ID, so a failed lookup only drops it.
            ResolveCurrentPersonID().catch((err) => {
                LogError(err);
                return null;
            }),
            this.LoadCategories(),
            this.LoadKPIs(),
        ]);
        this.CurrentPersonID = personID;
        this.cdr.markForCheck();
    }

    public SetView(mode: TaskViewMode): void {
        this.ViewMode = mode;
        this.cdr.markForCheck();
    }

    /** @internal */
    public onViewToggleChange(key: string): void {
        this.SetView(key as TaskViewMode);
    }

    public async LoadCategories(): Promise<void> {
        try {
            const rv = this.createRunView();
            const res = await rv.RunView<TaskCategoryOption>({
                EntityName: 'MJ_BizApps_Tasks: Task Categories',
                OrderBy: 'Name ASC',
                ResultType: 'simple',
            });
            if (res.Success && res.Results) {
                this.Categories = res.Results;
            }
        } catch {
            // ignore
        }
    }

    public async LoadKPIs(): Promise<void> {
        try {
            const rv = this.createRunView();
            const filter = this.SelectedCategoryID ? `CategoryID = '${this.SelectedCategoryID}'` : undefined;
            const res = await rv.RunView<{
                ID: string;
                Status: string;
                DueAt: string | null;
                PercentComplete: number;
            }>({
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                ExtraFilter: filter,
                ResultType: 'simple',
                MaxRows: 1000,
            });

            const rows = res.Success && res.Results ? res.Results : [];
            if (res.Success && res.Results) {
                const now = new Date();
                let active = 0;
                let inProg = 0;
                let blocked = 0;
                let overdue = 0;
                let totalPct = 0;

                for (const t of rows) {
                    if (t.Status !== 'Cancelled' && t.Status !== 'Completed') {
                        active++;
                        totalPct += (t.PercentComplete ?? 0);
                        if (t.Status === 'InProgress') inProg++;
                        if (t.Status === 'Blocked') blocked++;
                        if (t.DueAt && new Date(t.DueAt) < now) overdue++;
                    }
                }

                this.KPIs = {
                    TotalActive: active,
                    InProgress: inProg,
                    Blocked: blocked,
                    Overdue: overdue,
                    AvgPercentComplete: active > 0 ? Math.round(totalPct / active) : 0,
                };
            }

            const suggestions = await TaskFieldSuggestionsHelper.LoadPendingSuggestions(this.ProviderToUse, {
                taskIds: rows.map((t) => t.ID),
            });
            this.FieldSuggestionsAvailable = suggestions.available;
            this.PendingSuggestionsByTask = suggestions.byTaskId;
            this.TotalPendingSuggestionsCount = CountTotalPendingSuggestions(suggestions.byTaskId);
        } finally {
            this.cdr.markForCheck();
        }
    }

    public OnCategoryChanged(): void {
        this.LoadKPIs();
        this.RefreshActiveView();
    }

    public ClearCategoryFilter(): void {
        this.SelectedCategoryID = null;
        this.OnCategoryChanged();
    }

    public OpenPanel(mode: TasksDashboardPanelMode, taskID: string | null = null): void {
        this.PanelMode = mode;
        this.SelectedTaskID = taskID;
        this.cdr.markForCheck();
    }

    public ClosePanel(): void {
        this.PanelMode = 'none';
        this.SelectedTaskID = null;
        this.cdr.markForCheck();
    }

    public async OnTaskSaved(taskID: string): Promise<void> {
        this.ClosePanel();
        await this.LoadKPIs();
        this.RefreshActiveView();
    }

    public async OnTaskDeleted(): Promise<void> {
        this.ClosePanel();
        await this.LoadKPIs();
        this.RefreshActiveView();
    }

    public async OnTemplateCreated(_tasks: BaseEntity[]): Promise<void> {
        this.ClosePanel();
        await this.LoadKPIs();
        this.RefreshActiveView();
    }

    private RefreshActiveView(): void {
        this.taskGantt?.Refresh();
        this.taskKanban?.Refresh();
        this.taskList?.Refresh();
        this.cdr.markForCheck();
    }
}
