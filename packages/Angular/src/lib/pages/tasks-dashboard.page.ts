import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    HostListener,
    OnInit,
    ViewChild,
    inject,
} from '@angular/core';
import { LogError, RunView } from '@memberjunction/core';
import { UserInfoEngine } from '@memberjunction/core-entities';
import {
    MJButtonDirective,
    MJFilterPanelComponent,
    MJFilterPopoverComponent,
    MJLeftNavComponent,
    MJLeftNavContentComponent,
    MJPageBodyComponent,
    MJPageHeaderComponent,
    MJPageLayoutComponent,
    MJPageSearchComponent,
    MJRefreshButtonComponent,
    MJStatBadgeComponent,
    MJViewToggleComponent,
    type FilterFieldConfig,
    type MJLeftNavItem,
    type MJLeftNavSection,
    type ViewToggleOption,
} from '@memberjunction/ng-ui-components';
import {
    TaskCommandPaletteComponent,
    type TaskCommandPaletteItem,
} from '@mj-biz-apps/tasks-ng-widgets';
import { ResolveCurrentPersonID } from '../current-person';
import { OpenTaskRecord } from '../open-task-record';
import { TaskDetailPanelComponent } from '../components/task-detail-panel/task-detail-panel.component';
import { TaskDrawerShellComponent } from '../components/task-drawer-shell/task-drawer-shell.component';
import { TaskEditPanelComponent } from '../components/task-edit-panel/task-edit-panel.component';
import { TaskGanttComponent } from '../components/task-gantt/task-gantt.component';
import { TaskKanbanComponent } from '../components/task-kanban/task-kanban.component';
import { TaskListComponent } from '../components/task-list/task-list.component';
import type { TaskViewMode } from '../components/task-panel/task-panel.component';
import { TaskTemplateWizardComponent } from '../components/task-template-wizard/task-template-wizard.component';

export type { TaskViewMode };
export type TasksDashboardPanelMode = 'none' | 'detail' | 'edit' | 'template';

export interface TaskCategoryOption {
    ID: string;
    Name: string;
    ParentID: string | null;
}

export interface TaskKPIs {
    TotalActive: number;
    InProgress: number;
    Blocked: number;
    Overdue: number;
    AvgPercentComplete: number;
}

const VIEW_MODE_SETTING = 'mj.tasks.dashboardViewMode.v1';
const RAIL_COLLAPSED_SETTING = 'mj.tasks.categoryRailCollapsed.v1';

/**
 * Projects & All Work Dashboard Page — official MJ Chrome Trio
 * (`<mj-page-layout>` + `<mj-page-header>` + `<mj-page-body>`) + collapsible
 * `<mj-left-nav>` Category rail (auto mobile drawer on <=700px) + unified
 * filtered List / 4-Mode Smart Board / Critical-Path Split Gantt + Mobile Milestone Stack.
 */
@Component({
    selector: 'bizapps-tasks-dashboard-page',
    standalone: true,
    imports: [
        MJPageLayoutComponent,
        MJPageHeaderComponent,
        MJPageBodyComponent,
        MJPageSearchComponent,
        MJFilterPopoverComponent,
        MJFilterPanelComponent,
        MJRefreshButtonComponent,
        MJStatBadgeComponent,
        MJViewToggleComponent,
        MJLeftNavComponent,
        MJLeftNavContentComponent,
        MJButtonDirective,
        TaskListComponent,
        TaskKanbanComponent,
        TaskGanttComponent,
        TaskDetailPanelComponent,
        TaskEditPanelComponent,
        TaskTemplateWizardComponent,
        TaskDrawerShellComponent,
        TaskCommandPaletteComponent,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <mj-page-layout>
            <mj-page-header
                Title="Projects & All Work"
                Icon="fa-solid fa-list-check"
                Subtitle="Hierarchical tree lists, workflow boards, and critical-path Gantt timelines.">
                <div meta>
                    <mj-stat-badge
                        [Count]="KPIs.TotalActive"
                        Label="active">
                    </mj-stat-badge>
                    @if (KPIs.Overdue > 0) {
                        <mj-stat-badge
                            [Count]="KPIs.Overdue"
                            Label="overdue"
                            Variant="error">
                        </mj-stat-badge>
                    }
                    @if (KPIs.Blocked > 0) {
                        <mj-stat-badge
                            [Count]="KPIs.Blocked"
                            Label="blocked"
                            Variant="warning">
                        </mj-stat-badge>
                    }
                </div>

                <div actions>
                    <mj-refresh-button [Loading]="Loading" (Clicked)="RefreshAll()" />
                    <button type="button" mjButton variant="outline" size="sm" (click)="ShowCmdK = true" title="Tasks Quick Jump (Cmd/Ctrl+J)" aria-label="Tasks Quick Jump">
                        <i class="fa-solid fa-terminal" aria-hidden="true"></i>
                        <span class="action-btn-label">⌘J</span>
                    </button>
                    <button type="button" mjButton variant="outline" size="sm" (click)="OpenPanel('template')" title="Create from Template" aria-label="From Template">
                        <i class="fa-solid fa-copy" aria-hidden="true"></i>
                        <span class="action-btn-label">From Template</span>
                    </button>
                    <button type="button" mjButton variant="primary" size="sm" (click)="OpenPanel('edit', null)" title="Create New Task" aria-label="New Task">
                        <i class="fa-solid fa-plus" aria-hidden="true"></i>
                        <span class="action-btn-label">New Task</span>
                    </button>
                </div>

                <div toolbar>
                    <mj-page-search
                        Placeholder="Search tasks across projects..."
                        [Value]="SearchText"
                        (ValueChange)="SearchText = $event; cdr.markForCheck()">
                    </mj-page-search>

                    <mj-filter-popover
                        Label="Filters"
                        Icon="fa-solid fa-filter"
                        [ActiveCount]="ActiveFilterCount"
                        [ShowClearAll]="ActiveFilterCount > 0"
                        (ClearAllRequested)="ResetFilters()">
                        <mj-filter-panel
                            [Fields]="FilterFields"
                            [Values]="FilterValues"
                            (ValuesChange)="OnFilterValuesChange($event)"
                            (Reset)="ResetFilters()">
                        </mj-filter-panel>
                    </mj-filter-popover>

                    <mj-view-toggle
                        [Options]="ViewToggleOptions"
                        [ActiveKey]="ViewMode"
                        (KeyChange)="onViewToggleChange($event)">
                    </mj-view-toggle>
                </div>
            </mj-page-header>

            <mj-page-body [Padding]="false" [Flex]="true" Direction="row">
                <mj-left-nav
                    [Sections]="CategoryNavSections"
                    [ActiveId]="SelectedCategoryID ?? '__all__'"
                    [Width]="224"
                    [Collapsible]="true"
                    [Collapsed]="RailCollapsed"
                    MobileTitle="Categories"
                    (CollapsedChange)="OnRailCollapsedChange($event)"
                    (ItemClicked)="OnCategoryNavClicked($event)">
                </mj-left-nav>

                <mj-left-nav-content>
                    <div class="mjt-proj-stage">
                        @if (ViewMode === 'list') {
                            <bizapps-task-list
                                #taskList
                                [CategoryID]="SelectedCategoryID"
                                [SearchText]="SearchText"
                                [StatusFilter]="StatusFilterValue"
                                [PriorityFilter]="PriorityFilterValue"
                                [TypeIDFilter]="TypeFilterValue"
                                [HideToolbar]="true"
                                [ShowCreateButton]="false"
                                [ShowQuickAdd]="true"
                                (AfterTaskSelected)="OpenPanel('detail', $event.ID)"
                                (TaskDoubleClicked)="OpenFullRecord($event.ID)"
                                (AfterTaskCreated)="LoadKPIs()"
                                (CreateTask)="OpenPanel('edit', null)">
                            </bizapps-task-list>
                        }
                        @if (ViewMode === 'kanban') {
                            <bizapps-task-kanban
                                #taskKanban
                                [CategoryID]="SelectedCategoryID"
                                [SearchText]="SearchText"
                                [PriorityFilter]="PriorityFilterValue"
                                [TypeIDFilter]="TypeFilterValue"
                                (TaskClicked)="OpenPanel('detail', $event)"
                                (TaskDoubleClicked)="OpenFullRecord($event)"
                                (AfterStatusChange)="LoadKPIs()">
                            </bizapps-task-kanban>
                        }
                        @if (ViewMode === 'gantt') {
                            <bizapps-task-gantt
                                #taskGantt
                                [CategoryID]="SelectedCategoryID"
                                [SearchText]="SearchText"
                                [PriorityFilter]="PriorityFilterValue"
                                [TypeIDFilter]="TypeFilterValue"
                                [Height]="'calc(100vh - 250px)'"
                                (TaskClicked)="OpenPanel('detail', $event)"
                                (TaskDoubleClicked)="OpenFullRecord($event)">
                            </bizapps-task-gantt>
                        }
                    </div>
                </mj-left-nav-content>
            </mj-page-body>
        </mj-page-layout>

        <!-- Responsive Slide-Over / Mobile Bottom Sheet -->
        <bizapps-task-drawer-shell
            [Visible]="PanelMode !== 'none'"
            [Title]="DrawerTitle"
            (Closed)="ClosePanel()">
            @if (PanelMode === 'detail' && SelectedTaskID) {
                <bizapps-task-detail-panel
                    [TaskID]="SelectedTaskID"
                    [PersonID]="CurrentPersonID"
                    [ShowDelete]="true"
                    (EditRequested)="OpenPanel('edit', $event)"
                    (OpenRecordRequested)="OpenFullRecord($event)"
                    (TaskMutated)="OnTaskMutated()"
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
        </bizapps-task-drawer-shell>

        <!-- Command Palette (Cmd/Ctrl+K) -->
        <mjt-command-palette
            [Visible]="ShowCmdK"
            [Items]="CommandItems"
            (ItemSelected)="OnCommandSelected($event)"
            (Closed)="ShowCmdK = false">
        </mjt-command-palette>
    `,
    styles: [`
        :host { display: block; width: 100%; height: 100%; }
        .mjt-proj-stage {
            padding: 16px;
            min-width: 0;
            width: 100%;
            box-sizing: border-box;
        }
        @media (max-width: 640px) {
            .mjt-proj-stage { padding: 12px; }
        }
    `],
})
export class TasksDashboardPageComponent implements OnInit {
    public ViewToggleOptions: ViewToggleOption[] = [
        { key: 'list', icon: 'fa-solid fa-list', label: 'List', title: 'Tree List View' },
        { key: 'kanban', icon: 'fa-solid fa-table-columns', label: 'Board', title: 'Smart Board View' },
        { key: 'gantt', icon: 'fa-solid fa-chart-gantt', label: 'Timeline', title: 'Gantt Timeline View' },
    ];
    public ViewMode: TaskViewMode = 'list';
    public PanelMode: TasksDashboardPanelMode = 'none';
    public SelectedTaskID: string | null = null;
    public SelectedCategoryID: string | null = null;
    public CurrentPersonID: string | null = null;
    public RailCollapsed = false;
    public Loading = false;
    public SearchText = '';
    public ShowCmdK = false;

    public Categories: TaskCategoryOption[] = [];
    public CategoryNavSections: MJLeftNavSection[] = [];
    public TaskTypes: { ID: string; Name: string }[] = [];
    public FilterValues: Record<string, unknown> = { status: null, priority: null, typeId: null };
    public FilterFields: FilterFieldConfig[] = [];
    public KPIs: TaskKPIs = {
        TotalActive: 0,
        InProgress: 0,
        Blocked: 0,
        Overdue: 0,
        AvgPercentComplete: 0,
    };

    @ViewChild('taskGantt') public taskGantt?: TaskGanttComponent;
    @ViewChild('taskKanban') public taskKanban?: TaskKanbanComponent;
    @ViewChild('taskList') public taskList?: TaskListComponent;

    public cdr = inject(ChangeDetectorRef);
    private categoryCounts = new Map<string, number>();

    @HostListener('window:keydown', ['$event'])
    public onGlobalKeydown(event: KeyboardEvent): void {
        if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'j') {
            event.preventDefault();
            this.ShowCmdK = !this.ShowCmdK;
            this.cdr.markForCheck();
        }
    }

    public get DrawerTitle(): string {
        if (this.PanelMode === 'edit') return this.SelectedTaskID ? 'Edit Task' : 'New Task';
        if (this.PanelMode === 'template') return 'Launch Playbook Template';
        return 'Task Inspector';
    }

    public get StatusFilterValue(): string | null {
        return (this.FilterValues['status'] as string | null) ?? null;
    }

    public get PriorityFilterValue(): string | null {
        return (this.FilterValues['priority'] as string | null) ?? null;
    }

    public get TypeFilterValue(): string | null {
        return (this.FilterValues['typeId'] as string | null) ?? null;
    }

    public get ActiveFilterCount(): number {
        let count = 0;
        if (this.FilterValues['status']) count++;
        if (this.FilterValues['priority']) count++;
        if (this.FilterValues['typeId']) count++;
        return count;
    }

    public get CommandItems(): TaskCommandPaletteItem[] {
        return [
            { ID: 'new-task', Label: 'Create New Task', Group: 'Actions', IconClass: 'fa-solid fa-plus' },
            { ID: 'from-template', Label: 'Launch from Template', Group: 'Actions', IconClass: 'fa-solid fa-copy' },
            { ID: 'view-list', Label: 'Switch to Tree List View', Group: 'Views', IconClass: 'fa-solid fa-list' },
            { ID: 'view-kanban', Label: 'Switch to Smart Board View', Group: 'Views', IconClass: 'fa-solid fa-table-columns' },
            { ID: 'view-gantt', Label: 'Switch to Timeline / Gantt View', Group: 'Views', IconClass: 'fa-solid fa-chart-gantt' },
            { ID: 'reset-filters', Label: 'Clear All Filters', Group: 'Actions', IconClass: 'fa-solid fa-filter-circle-xmark' },
        ];
    }

    public OpenFullRecord(taskID: string | null): void {
        OpenTaskRecord(taskID);
    }

    public async ngOnInit(): Promise<void> {
        const savedView = UserInfoEngine.Instance.GetSetting(VIEW_MODE_SETTING);
        if (savedView === 'list' || savedView === 'kanban' || savedView === 'gantt') {
            this.ViewMode = savedView;
        }
        const savedRail = UserInfoEngine.Instance.GetSetting(RAIL_COLLAPSED_SETTING);
        if (savedRail === 'true') {
            this.RailCollapsed = true;
        }

        const [personID] = await Promise.all([
            ResolveCurrentPersonID().catch((err) => {
                LogError(err);
                return null;
            }),
            this.LoadCategoriesAndTypes(),
            this.LoadKPIs(),
        ]);
        this.CurrentPersonID = personID;
        this.buildCategoryNav();
        this.buildFilterFields();
        this.cdr.markForCheck();
    }

    public SetView(mode: TaskViewMode): void {
        this.ViewMode = mode;
        UserInfoEngine.Instance.SetSettingDebounced(VIEW_MODE_SETTING, mode);
        this.cdr.markForCheck();
    }

    public onViewToggleChange(key: string): void {
        this.SetView(key as TaskViewMode);
    }

    public OnRailCollapsedChange(collapsed: boolean): void {
        this.RailCollapsed = collapsed;
        UserInfoEngine.Instance.SetSettingDebounced(RAIL_COLLAPSED_SETTING, String(collapsed));
        this.cdr.markForCheck();
    }

    public OnCategoryNavClicked(item: MJLeftNavItem): void {
        this.SelectedCategoryID = item.id === '__all__' ? null : item.id;
        this.OnCategoryChanged();
    }

    public OnFilterValuesChange(values: Record<string, unknown>): void {
        this.FilterValues = { ...values };
        this.cdr.markForCheck();
    }

    public ResetFilters(): void {
        this.FilterValues = { status: null, priority: null, typeId: null };
        this.SearchText = '';
        this.cdr.markForCheck();
    }

    public async RefreshAll(): Promise<void> {
        await Promise.all([this.LoadCategoriesAndTypes(), this.LoadKPIs()]);
        this.buildCategoryNav();
        this.RefreshActiveView();
    }

    private async LoadCategoriesAndTypes(): Promise<void> {
        const [catsRes, typesRes] = await Promise.all([
            new RunView().RunView<TaskCategoryOption>({
                EntityName: 'MJ_BizApps_Tasks: Task Categories',
                ExtraFilter: 'IsActive = 1',
                OrderBy: 'Sequence ASC, Name ASC',
                ResultType: 'simple',
            }),
            new RunView().RunView<{ ID: string; Name: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Types',
                ExtraFilter: 'IsActive = 1',
                OrderBy: 'Name ASC',
                ResultType: 'simple',
            }),
        ]);
        this.Categories = catsRes?.Results ?? [];
        this.TaskTypes = typesRes?.Results ?? [];
    }

    public async LoadKPIs(): Promise<void> {
        this.Loading = true;
        this.cdr.markForCheck();
        try {
            const res = await new RunView().RunView<{
                Status: string;
                DueAt: string | null;
                PercentComplete: number;
                CategoryID: string | null;
            }>({
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                Fields: ['Status', 'DueAt', 'PercentComplete', 'CategoryID'],
                ResultType: 'simple',
                MaxRows: 1000,
                BypassCache: true,
            });

            const rows = res?.Results ?? [];
            const now = new Date();
            this.categoryCounts.clear();

            let active = 0;
            let inProg = 0;
            let blocked = 0;
            let overdue = 0;
            let totalPct = 0;

            for (const t of rows) {
                const isActive = t.Status !== 'Cancelled' && t.Status !== 'Completed';
                if (isActive && t.CategoryID) {
                    const k = t.CategoryID.toLowerCase();
                    this.categoryCounts.set(k, (this.categoryCounts.get(k) ?? 0) + 1);
                }
                if (this.SelectedCategoryID && t.CategoryID?.toLowerCase() !== this.SelectedCategoryID.toLowerCase()) {
                    continue;
                }
                if (isActive) {
                    active++;
                    totalPct += t.PercentComplete ?? 0;
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
            this.buildCategoryNav();
        } finally {
            this.Loading = false;
            this.cdr.markForCheck();
        }
    }

    private buildCategoryNav(): void {
        let totalActive = 0;
        for (const n of this.categoryCounts.values()) totalActive += n;

        const catItems: MJLeftNavItem[] = this.Categories.map((c) => {
            const count = this.categoryCounts.get(c.ID.toLowerCase()) ?? 0;
            return {
                id: c.ID,
                label: c.Name,
                icon: 'fa-solid fa-folder',
                badge: count > 0 ? count : undefined,
            };
        });

        this.CategoryNavSections = [
            {
                label: 'Scope',
                items: [
                    {
                        id: '__all__',
                        label: 'All Work',
                        icon: 'fa-solid fa-layer-group',
                        badge: this.KPIs.TotalActive > 0 ? this.KPIs.TotalActive : (totalActive || undefined),
                    },
                ],
            },
            ...(catItems.length > 0 ? [{ label: 'Categories', items: catItems }] : []),
        ];
    }

    private buildFilterFields(): void {
        this.FilterFields = [
            {
                key: 'status',
                type: 'dropdown',
                label: 'Status',
                icon: 'fa-solid fa-circle-dot',
                placeholder: 'All statuses',
                options: [
                    { text: 'All statuses', value: null },
                    { text: 'Open', value: 'Open' },
                    { text: 'In Progress', value: 'InProgress' },
                    { text: 'Blocked', value: 'Blocked' },
                    { text: 'Completed', value: 'Completed' },
                ],
            },
            {
                key: 'priority',
                type: 'dropdown',
                label: 'Priority',
                icon: 'fa-solid fa-flag',
                placeholder: 'All priorities',
                options: [
                    { text: 'All priorities', value: null },
                    { text: 'Critical', value: 'Critical' },
                    { text: 'High', value: 'High' },
                    { text: 'Medium', value: 'Medium' },
                    { text: 'Low', value: 'Low' },
                ],
            },
            {
                key: 'typeId',
                type: 'dropdown',
                label: 'Task Type',
                icon: 'fa-solid fa-shapes',
                placeholder: 'All task types',
                options: [
                    { text: 'All task types', value: null },
                    ...this.TaskTypes.map((t) => ({ text: t.Name, value: t.ID })),
                ],
            },
        ];
    }

    public OnCategoryChanged(): void {
        void this.LoadKPIs();
        this.RefreshActiveView();
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

    public async OnTaskSaved(_taskID: string): Promise<void> {
        this.ClosePanel();
        await this.LoadKPIs();
        this.RefreshActiveView();
    }

    public async OnTaskMutated(): Promise<void> {
        await this.LoadKPIs();
        this.RefreshActiveView();
    }

    public async OnTaskDeleted(): Promise<void> {
        this.ClosePanel();
        await this.LoadKPIs();
        this.RefreshActiveView();
    }

    public async OnTemplateCreated(_result: unknown): Promise<void> {
        this.ClosePanel();
        await this.LoadKPIs();
        this.RefreshActiveView();
    }

    public OnCommandSelected(item: TaskCommandPaletteItem): void {
        this.ShowCmdK = false;
        if (item.ID === 'new-task') this.OpenPanel('edit', null);
        else if (item.ID === 'from-template') this.OpenPanel('template');
        else if (item.ID === 'view-list') this.SetView('list');
        else if (item.ID === 'view-kanban') this.SetView('kanban');
        else if (item.ID === 'view-gantt') this.SetView('gantt');
        else if (item.ID === 'reset-filters') this.ResetFilters();
        this.cdr.markForCheck();
    }

    private RefreshActiveView(): void {
        this.taskGantt?.Refresh();
        this.taskKanban?.Refresh();
        void this.taskList?.Refresh();
        this.cdr.markForCheck();
    }
}
