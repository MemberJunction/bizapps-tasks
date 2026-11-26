import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    EventEmitter,
    HostListener,
    Input,
    OnInit,
    Output,
    ViewChild,
    inject,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CompositeKey, LogError, Metadata, RunView, type IMetadataProvider, type IRunViewProvider, type RunViewParams } from '@memberjunction/core';
import { EscapeSQLString, IsValidUUID, NormalizeUUID, UUIDsEqual } from '@memberjunction/global';
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
    TaskBulkActionDockComponent,
    TaskCommandPaletteComponent,
    TaskQuickCaptureComponent,
    TaskWbsSummaryStripComponent,
    TaskWbsTreeComponent,
    type TaskBulkActionRequest,
    type TaskBulkLookupOption,
    type TaskBulkPatch,
    type TaskCommandPaletteItem,
    type TaskPriorityValue,
    type TaskQuickCaptureSubmitEvent,
    type TaskStatusValue,
    type TaskWbsKindLabel,
    type TaskWbsRowTone,
    type TaskWidgetAssignee,
    type TaskWidgetItem,
} from '@mj-biz-apps/tasks-ng-widgets';
import {
    BuildWbsTree,
    ComputeWbsSummary,
    DeleteSavedTaskFilterView,
    FilterWbsTreePreservingAncestors,
    MatchesAssigneeFilter,
    MatchesDueDateFilter,
    ParseSavedTaskFilterViews,
    SAVED_TASK_VIEWS_SETTING,
    SerializeSavedTaskFilterViews,
    TasksBulkUpdateOperation,
    TasksEngineBase,
    UpsertSavedTaskFilterView,
    type SavedTaskFilterMap,
    type SavedTaskFilterValue,
    type SavedTaskFilterView,
    type TaskBadgeDescriptor,
    type TaskDueDateFilterKey,
    type TaskWbsNode,
    type TaskWbsSummaryMetrics,
} from '@mj-biz-apps/tasks-core';
import {
    FilterActiveSelectableTaskTypes,
    FilterGenericCreatableTaskTypes,
    type mjBizAppsTasksTaskEntity,
    type TaskTypeClassificationInput,
} from '@mj-biz-apps/tasks-entities';
import { ResolveCurrentPersonID } from '../current-person';
import { OpenTaskRecord } from '../open-task-record';
import { CurrentUserRoleIDs, RoleAssigneeName } from '../role-assignees';
import { EnsureTasksEngineLoaded, RunViewsBatch } from '../tasks-engine.helper';
import { ResolveDefaultGenericTaskTypeID, SelectGenericQuickAddTaskTypeID } from '../task-type-filter.helper';
import { TaskDetailPanelComponent } from '../components/task-detail-panel/task-detail-panel.component';
import { TaskDrawerShellComponent } from '../components/task-drawer-shell/task-drawer-shell.component';
import { TaskEditPanelComponent } from '../components/task-edit-panel/task-edit-panel.component';
import { GoalsViewComponent } from '../components/goals-view/goals-view.component';
import { TaskGanttComponent } from '../components/task-gantt/task-gantt.component';
import { TaskKanbanComponent } from '../components/task-kanban/task-kanban.component';
import { TaskListComponent } from '../components/task-list/task-list.component';
import type { TaskViewMode } from '../components/task-panel/task-panel.component';
import { TaskTemplateWizardComponent } from '../components/task-template-wizard/task-template-wizard.component';
import { RunningTimerChipComponent } from '../components/running-timer-chip/running-timer-chip.component';
import {
    BuildPendingSuggestionsSqlFilter,
    CountTotalPendingSuggestions,
    FormatPendingSuggestionTooltip,
    TaskFieldSuggestionsHelper,
    type TaskPendingSuggestionsSummary,
} from '../task-field-suggestions.helper';

export type { TaskViewMode };
export type TasksDashboardPanelMode = 'none' | 'detail' | 'edit' | 'template' | 'help';

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

export interface WbsDashboardFilterCriteria {
    CategoryID: string | null;
    SearchText: string;
    Status: string | null;
    Priority: string | null;
    TypeID: string | null;
    Assignee: string | null;
    DueDate: TaskDueDateFilterKey | null;
    OrganizationID: string | null;
    CurrentPersonID: string | null;
    CurrentRoleIDs: readonly string[];
    OnlyPendingSuggestions: boolean;
    PendingSuggestionsByTask: ReadonlyMap<string, TaskPendingSuggestionsSummary>;
}

interface WbsTaskQueryRow {
    ID: string;
    Name: string;
    Description: string | null;
    Status: TaskStatusValue;
    Priority: TaskPriorityValue;
    DueAt: string | null;
    StartedAt: string | null;
    PercentComplete: number | null;
    HoursEstimated: number | null;
    HoursActual: number | null;
    ParentID: string | null;
    TypeID: string;
    Type: string | null;
    CategoryID: string | null;
    Category: string | null;
    OrganizationID: string | null;
    Organization: string | null;
    TaskTypeStatusID: string | null;
    TaskTypeStatus: string | null;
    BlockedReason: string | null;
    Sequence: number | null;
}

interface WbsAssignmentQueryRow {
    TaskID: string;
    AssigneeEntityID: string;
    AssigneeRecordID: string;
    RoleID: string | null;
    Status: TaskWidgetAssignee['Status'] | null;
}

interface WbsDependencyQueryRow {
    TaskID: string;
    DependsOnTaskID: string;
    DependencyType: string | null;
}

function resolveWbsKindLabel(typeCode: string | null | undefined): TaskWbsKindLabel | null {
    const code = (typeCode ?? '').trim().toUpperCase();
    if (code === 'PHASE') return 'Phase';
    if (code === 'MILESTONE') return 'Milestone';
    if (code === 'SUBTASK') return 'Subtask';
    return null;
}

function matchesWbsDashboardFilter(item: TaskWidgetItem, criteria: WbsDashboardFilterCriteria): boolean {
    if (criteria.CategoryID) {
        if (!item.CategoryID || !UUIDsEqual(item.CategoryID, criteria.CategoryID)) {
            return false;
        }
    }
    if (criteria.Status && item.Status !== criteria.Status) {
        return false;
    }
    if (criteria.Priority && item.Priority !== criteria.Priority) {
        return false;
    }
    if (criteria.TypeID) {
        if (!item.TypeID || !UUIDsEqual(item.TypeID, criteria.TypeID)) {
            return false;
        }
    }
    if (criteria.OrganizationID === '__none__') {
        if (item.OrganizationID) {
            return false;
        }
    } else if (criteria.OrganizationID) {
        if (!item.OrganizationID || !UUIDsEqual(item.OrganizationID, criteria.OrganizationID)) {
            return false;
        }
    }
    if (!MatchesDueDateFilter(item.DueAt ?? item.DueDate ?? null, item.Status, criteria.DueDate)) {
        return false;
    }
    if (criteria.Assignee) {
        const assigneeRefs = (item.Assignees ?? [])
            .filter((a) => Boolean(a.RecordID))
            .map((a) => ({ RecordID: a.RecordID, EntityName: a.EntityName }));
        if (!MatchesAssigneeFilter(assigneeRefs, criteria.Assignee, criteria.CurrentPersonID, criteria.CurrentRoleIDs)) {
            return false;
        }
    }
    const q = criteria.SearchText.trim().toLowerCase();
    if (q) {
        const assigneeNames = item.AssigneeNames ?? (item.Assignees ?? []).map((a) => a.DisplayName);
        const haystacks = [
            item.Name,
            item.Description ?? '',
            item.BlockedReason ?? '',
            item.OrganizationName ?? '',
            item.CategoryName ?? '',
            item.TaskTypeName ?? item.TypeName ?? '',
            item.TaskTypeStatusName ?? '',
            ...assigneeNames,
        ];
        if (!haystacks.some((h) => h.toLowerCase().includes(q))) {
            return false;
        }
    }
    if (criteria.OnlyPendingSuggestions) {
        const summary = criteria.PendingSuggestionsByTask.get(NormalizeUUID(item.ID));
        if (!summary || summary.pendingCount <= 0) {
            return false;
        }
    }
    return true;
}

/**
 * Projects a flat task list through all active dashboard filters while keeping
 * every matching task's full WBS ancestor chain (Phase / Milestone / Parent) intact.
 */
export function ProjectFilteredWbsTasks(
    allTasks: readonly TaskWidgetItem[],
    criteria: WbsDashboardFilterCriteria,
): TaskWidgetItem[] {
    if (allTasks.length === 0) {
        return [];
    }
    const hasFilter = Boolean(
        criteria.CategoryID ||
            criteria.SearchText.trim() ||
            criteria.Status ||
            criteria.Priority ||
            criteria.TypeID ||
            criteria.Assignee ||
            criteria.DueDate ||
            criteria.OrganizationID ||
            criteria.OnlyPendingSuggestions,
    );
    if (!hasFilter) {
        return [...allTasks];
    }

    const tree = BuildWbsTree(allTasks);
    const filteredTree = FilterWbsTreePreservingAncestors(tree, (item) =>
        matchesWbsDashboardFilter(item, criteria),
    );
    const out: TaskWidgetItem[] = [];
    const flatten = (nodes: readonly TaskWbsNode<TaskWidgetItem>[]): void => {
        for (const node of nodes) {
            out.push(node.Item);
            if (node.Children.length > 0) {
                flatten(node.Children);
            }
        }
    };
    flatten(filteredTree);
    return out;
}

const VIEW_MODE_SETTING = 'mj.tasks.dashboardViewMode.v1';
const RAIL_COLLAPSED_SETTING = 'mj.tasks.categoryRailCollapsed.v1';

/**
 * All Work Dashboard Page — official MJ Chrome Trio
 * (`<mj-page-layout>` + `<mj-page-header>` + `<mj-page-body>`) + collapsible
 * `<mj-left-nav>` Category rail + UserInfoEngine-persisted Saved Filter Views +
 * unified filtered List / 5-Mode Board / Critical-Path Split Gantt +
 * shared `<mjt-bulk-action-dock>` (`BizAppsTasks.BulkUpdateTasks`) across all three views.
 */
@Component({
    selector: 'bizapps-tasks-dashboard-page',
    standalone: true,
    imports: [
        FormsModule,
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
        GoalsViewComponent,
        TaskTemplateWizardComponent,
        TaskDrawerShellComponent,
        TaskCommandPaletteComponent,
        TaskBulkActionDockComponent,
        TaskQuickCaptureComponent,
        TaskWbsSummaryStripComponent,
        TaskWbsTreeComponent,
        RunningTimerChipComponent,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <mj-page-layout>
            <mj-page-header
                Title="All Work"
                Icon="fa-solid fa-list-check"
                Subtitle="Hierarchical WBS breakdown, tree lists, workflow boards, and critical-path Gantt timelines.">
                <div meta class="mjt-meta-strip">
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
                    <bizapps-running-timer-chip [PersonID]="CurrentPersonID"></bizapps-running-timer-chip>
                    <mj-refresh-button [Loading]="Loading" (Clicked)="RefreshAll()" />
                    <button
                        type="button"
                        class="mjt-desktop-only mjt-toolbar-btn"
                        mjButton
                        variant="outline"
                        size="sm"
                        (click)="ShowCmdK = true"
                        title="Tasks Quick Jump (Cmd/Ctrl+J)"
                        aria-label="Tasks Quick Jump">
                        <i class="fa-solid fa-terminal" aria-hidden="true"></i>
                        <span class="action-btn-label">⌘J</span>
                    </button>
                    <button
                        type="button"
                        class="mjt-toolbar-btn"
                        mjButton
                        variant="outline"
                        size="sm"
                        (click)="OpenPanel('help')"
                        title="In-app help for OKRs, Goals migration, and BizApps Planning"
                        aria-label="OKRs and Help">
                        <i class="fa-regular fa-circle-question" aria-hidden="true"></i>
                        <span class="action-btn-label">OKRs &amp; Help</span>
                    </button>
                    <button
                        type="button"
                        class="mjt-toolbar-btn"
                        mjButton
                        variant="outline"
                        size="sm"
                        (click)="OpenPanel('template')"
                        title="Create from Template"
                        aria-label="From Template">
                        <i class="fa-solid fa-copy" aria-hidden="true"></i>
                        <span class="action-btn-label">From Template</span>
                    </button>
                    <button type="button" mjButton variant="primary" size="sm" (click)="OpenPanel('edit', null)" title="Create New Task" aria-label="New Task">
                        <i class="fa-solid fa-plus" aria-hidden="true"></i>
                        <span class="action-btn-label">New Task</span>
                    </button>
                </div>

                <div toolbar class="mjt-toolbar-row">
                    <mj-page-search
                        class="mjt-search-flex"
                        Placeholder="Search tasks across projects..."
                        [Value]="SearchText"
                        (ValueChange)="OnSearchTextChange($event)">
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

                    <button
                        type="button"
                        class="mjt-toolbar-btn mjt-save-view-btn"
                        mjButton
                        variant="outline"
                        size="sm"
                        (click)="ToggleSaveViewComposer()"
                        title="Save current filter configuration as a reusable view"
                        aria-label="Save filter view">
                        <i class="fa-regular fa-bookmark" aria-hidden="true"></i>
                        <span class="action-btn-label">Save View</span>
                    </button>

                    @if (FieldSuggestionsAvailable || TotalPendingSuggestionsCount > 0 || OnlyPendingSuggestions) {
                        <button type="button"
                                class="mjt-suggestion-pill"
                                [class.mjt-suggestion-pill--active]="OnlyPendingSuggestions"
                                [attr.aria-pressed]="OnlyPendingSuggestions"
                                [attr.title]="PendingSuggestionsFilterTooltip"
                                (click)="TogglePendingSuggestions()">
                            <i class="fa-solid fa-wand-magic-sparkles" aria-hidden="true"></i>
                            <span class="action-btn-label">Suggestions</span>
                            @if (TotalPendingSuggestionsCount > 0) {
                                <span class="mjt-suggestion-pill__count">{{ TotalPendingSuggestionsCount }}</span>
                            }
                        </button>
                    }

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
                        @if (SavedViews.length > 0 || ShowSaveViewInput) {
                            <div class="mjt-saved-views-bar" role="region" aria-label="Saved filter views">
                                <span class="mjt-saved-views-lbl">
                                    <i class="fa-solid fa-bookmark" aria-hidden="true"></i> Views
                                </span>
                                <div class="mjt-saved-views-chips">
                                    @for (view of SavedViews; track view.ID) {
                                        <span class="mjt-view-chip" [class.is-active]="ActiveSavedViewID === view.ID">
                                            <button
                                                type="button"
                                                class="mjt-view-chip-btn"
                                                (click)="ApplySavedView(view)">
                                                {{ view.Name }}
                                            </button>
                                            <button
                                                type="button"
                                                class="mjt-view-chip-del"
                                                [attr.aria-label]="'Delete saved view ' + view.Name"
                                                (click)="DeleteSavedView(view.ID)">
                                                &times;
                                            </button>
                                        </span>
                                    }
                                </div>
                                @if (ShowSaveViewInput) {
                                    <div class="mjt-save-view-form">
                                        <input
                                            type="text"
                                            class="mjt-save-view-inp"
                                            [(ngModel)]="NewViewName"
                                            placeholder="View name (e.g. Acme Close)..."
                                            aria-label="Saved view name"
                                            (keydown.enter)="SaveCurrentView()"
                                            (keydown.escape)="ShowSaveViewInput = false" />
                                        <button
                                            type="button"
                                            mjButton
                                            variant="primary"
                                            size="sm"
                                            [disabled]="!NewViewName.trim()"
                                            (click)="SaveCurrentView()">
                                            Save
                                        </button>
                                        <button
                                            type="button"
                                            mjButton
                                            variant="flat"
                                            size="sm"
                                            (click)="ShowSaveViewInput = false; NewViewName = ''">
                                            Cancel
                                        </button>
                                    </div>
                                }
                            </div>
                        }

                        @if (BulkError) {
                            <div class="mjt-bulk-banner mjt-bulk-banner--error" role="alert">
                                <span>{{ BulkError }}</span>
                                <button type="button" class="mjt-bulk-dismiss" (click)="BulkError = ''">Dismiss</button>
                            </div>
                        }
                        @if (BulkSuccess) {
                            <div class="mjt-bulk-banner mjt-bulk-banner--success" role="status">
                                <i class="fa-solid fa-circle-check" aria-hidden="true"></i>
                                <span>{{ BulkSuccess }}</span>
                                <button type="button" class="mjt-bulk-dismiss" (click)="BulkSuccess = ''">Dismiss</button>
                            </div>
                        }

                        @if (ViewMode === 'wbs') {
                            <div class="mjt-wbs-stage">
                                <mjt-wbs-summary-strip
                                    [Summary]="WbsSummary"
                                    [ActiveFilterKey]="WbsSummaryActiveKey"
                                    (TileClicked)="OnWbsSummaryTileClicked($event)">
                                </mjt-wbs-summary-strip>

                                <mjt-quick-capture
                                    [Compact]="true"
                                    [Busy]="WbsQuickAdding"
                                    Placeholder="Quick add task... (try 'Draft deck tomorrow @Jordan !high')"
                                    (Submitted)="OnWbsQuickCapture($event)">
                                </mjt-quick-capture>

                                @if (WbsLoading && WbsAllTasks.length === 0) {
                                    <div class="mjt-wbs-loading">Loading WBS hierarchy...</div>
                                } @else if (WbsLoadError) {
                                    <div class="mjt-bulk-banner mjt-bulk-banner--error" role="alert">
                                        <span>{{ WbsLoadError }}</span>
                                        <button type="button" class="mjt-bulk-dismiss" (click)="LoadWbsTasks()">Retry</button>
                                    </div>
                                } @else {
                                    <mjt-wbs-tree
                                        #taskWbs
                                        [Tasks]="FilteredWbsTasks"
                                        [ShowWbsCodes]="true"
                                        [ShowTreeConnectors]="true"
                                        [ShowProgressBars]="true"
                                        [ShowStatusPill]="true"
                                        [ShowTypeBadge]="true"
                                        [ShowBlockedReason]="true"
                                        [ShowToolbar]="true"
                                        [EnableBulkSelect]="true"
                                        [SelectedIDs]="SelectedTaskIDs"
                                        [ShowAddSubtaskAction]="true"
                                        [RowBadgeResolver]="WbsRowBadgeResolver"
                                        [RowToneResolver]="WbsRowToneResolver"
                                        EmptyTitle="No matching tasks"
                                        EmptyMessage="Adjust your filters or add a task above to build your WBS hierarchy."
                                        (SelectedIDsChange)="OnSelectedTaskIDsChange($event)"
                                        (TaskClicked)="SelectTask($event.ID)"
                                        (TaskDoubleClicked)="OpenFullRecord($event.ID)"
                                        (StatusToggled)="OnWbsStatusToggled($event)"
                                        (CreateTaskRequested)="OnWbsCreateTaskRequested($event)">
                                    </mjt-wbs-tree>
                                }
                            </div>
                        }
                        @if (ViewMode === 'list') {
                            <bizapps-task-list
                                #taskList
                                [Provider]="Provider"
                                [CategoryID]="SelectedCategoryID"
                                [SearchText]="SearchText"
                                [StatusFilter]="StatusFilterValue"
                                [PriorityFilter]="PriorityFilterValue"
                                [TypeIDFilter]="TypeFilterValue"
                                [AssigneeFilter]="AssigneeFilterValue"
                                [DueDateFilter]="DueDateFilterValue"
                                [OrganizationIDFilter]="OrganizationFilterValue"
                                [CurrentPersonID]="CurrentPersonID"
                                [PendingSuggestionsOnly]="OnlyPendingSuggestions"
                                (PendingSuggestionsOnlyChange)="OnPendingSuggestionsChanged($event)"
                                [HideToolbar]="true"
                                [ShowCreateButton]="false"
                                [ShowQuickAdd]="true"
                                [ExternalBulkDock]="true"
                                [SelectedIDs]="SelectedTaskIDs"
                                (SelectedIDsChange)="OnSelectedTaskIDsChange($event)"
                                (VisibleTaskIDsChange)="OnVisibleTaskIDsChange($event)"
                                (AfterTaskSelected)="OpenPanel('detail', $event.ID)"
                                (TaskDoubleClicked)="OpenFullRecord($event.ID)"
                                (AfterTaskCreated)="LoadKPIs()"
                                (AfterStatusChange)="LoadKPIs()"
                                (CreateTask)="OpenPanel('edit', null)">
                            </bizapps-task-list>
                        }
                        @if (ViewMode === 'kanban') {
                            <bizapps-task-kanban
                                #taskKanban
                                [Provider]="Provider"
                                [CategoryID]="SelectedCategoryID"
                                [SearchText]="SearchText"
                                [PriorityFilter]="PriorityFilterValue"
                                [TypeIDFilter]="TypeFilterValue"
                                [AssigneeFilter]="AssigneeFilterValue"
                                [DueDateFilter]="DueDateFilterValue"
                                [OrganizationIDFilter]="OrganizationFilterValue"
                                [CurrentPersonID]="CurrentPersonID"
                                [PendingSuggestionsOnly]="OnlyPendingSuggestions"
                                [EnableBulkSelect]="true"
                                [SelectedIDs]="SelectedTaskIDs"
                                (SelectedIDsChange)="OnSelectedTaskIDsChange($event)"
                                (VisibleTaskIDsChange)="OnVisibleTaskIDsChange($event)"
                                (TaskClicked)="OpenPanel('detail', $event)"
                                (TaskDoubleClicked)="OpenFullRecord($event)"
                                (AfterStatusChange)="LoadKPIs()">
                            </bizapps-task-kanban>
                        }
                        @if (ViewMode === 'gantt') {
                            <bizapps-task-gantt
                                #taskGantt
                                [CategoryID]="SelectedCategoryID"
                                [ExtraFilter]="GanttExtraFilter"
                                [SearchText]="SearchText"
                                [PriorityFilter]="PriorityFilterValue"
                                [TypeIDFilter]="TypeFilterValue"
                                [AssigneeFilter]="AssigneeFilterValue"
                                [DueDateFilter]="DueDateFilterValue"
                                [OrganizationIDFilter]="OrganizationFilterValue"
                                [CurrentPersonID]="CurrentPersonID"
                                [EnableBulkSelect]="true"
                                [SelectedIDs]="SelectedTaskIDs"
                                (SelectedIDsChange)="OnSelectedTaskIDsChange($event)"
                                (VisibleTaskIDsChange)="OnVisibleTaskIDsChange($event)"
                                [Height]="'calc(100vh - 250px)'"
                                (TaskClicked)="OpenPanel('detail', $event)"
                                (TaskDoubleClicked)="OpenFullRecord($event)">
                            </bizapps-task-gantt>
                        }

                        <mjt-bulk-action-dock
                            [SelectedCount]="SelectedTaskIDs.length"
                            [TotalCount]="VisibleTaskIDs.length"
                            [Busy]="BulkBusy"
                            [PeopleOptions]="BulkPeopleOptions"
                            [RoleOptions]="BulkRoleOptions"
                            [TaskRoleOptions]="BulkTaskRoleOptions"
                            [OrganizationOptions]="BulkOrgOptions"
                            [CategoryOptions]="BulkCategoryOptions"
                            [TaskTypeOptions]="BulkTaskTypeOptions"
                            [WorkflowStageOptions]="BulkStageOptions"
                            [TagOptions]="BulkTagOptions"
                            (ActionRequested)="OnBulkDockAction($event)">
                        </mjt-bulk-action-dock>
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
                    [Provider]="Provider"
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
                    [DefaultOrganizationID]="ActiveOrganizationDefaultID"
                    [DefaultParentID]="DefaultParentTaskID"
                    (Saved)="OnTaskSaved($event)"
                    (Cancel)="ClosePanel()">
                </bizapps-task-edit-panel>
            }
            @if (PanelMode === 'template') {
                <bizapps-task-template-wizard
                    [DefaultCategoryID]="SelectedCategoryID"
                    [DefaultOrganizationID]="ActiveOrganizationDefaultID"
                    (Created)="OnTemplateCreated($event)"
                    (Cancelled)="ClosePanel()">
                </bizapps-task-template-wizard>
            }
            @if (PanelMode === 'help') {
                <bizapps-goals-view
                    [Provider]="Provider"
                    (TaskSelected)="OpenPanel('detail', $event)">
                </bizapps-goals-view>
            }
        </bizapps-task-drawer-shell>

        <!-- Command Palette (Cmd/Ctrl+J) -->
        <mjt-command-palette
            [Visible]="ShowCmdK"
            [Items]="CommandItems"
            (ItemSelected)="OnCommandSelected($event)"
            (Closed)="ShowCmdK = false">
        </mjt-command-palette>
    `,
    styles: [`
        :host { display: block; width: 100%; height: 100%; }
        .mjt-toolbar-btn {
            background: var(--mj-bg-surface-elevated, var(--mj-bg-surface));
        }
        .mjt-meta-strip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
        }
        .mjt-toolbar-row {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            width: 100%;
        }
        .mjt-search-flex {
            flex: 1 1 200px;
            min-width: 160px;
        }
        .mjt-saved-views-bar {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 10px;
            padding: 6px 10px;
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
        }
        .mjt-saved-views-lbl {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: 11px;
            font-weight: var(--mj-font-bold, 700);
            text-transform: uppercase;
            letter-spacing: 0.04em;
            color: var(--mj-text-muted);
        }
        .mjt-saved-views-chips {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
        }
        .mjt-view-chip {
            display: inline-flex;
            align-items: center;
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-full, 9999px);
            background: var(--mj-bg-surface);
            overflow: hidden;
        }
        .mjt-view-chip.is-active {
            border-color: var(--mj-brand-primary);
            background: color-mix(in oklab, var(--mj-brand-primary) 12%, var(--mj-bg-surface));
        }
        .mjt-view-chip-btn {
            border: none;
            background: transparent;
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: 11.5px;
            font-weight: var(--mj-font-semibold, 600);
            padding: 3px 8px 3px 10px;
            cursor: pointer;
        }
        .mjt-view-chip.is-active .mjt-view-chip-btn {
            color: var(--mj-brand-primary);
        }
        .mjt-view-chip-del {
            border: none;
            background: transparent;
            color: var(--mj-text-muted);
            padding: 3px 7px 3px 2px;
            font-size: 13px;
            line-height: 1;
            cursor: pointer;
        }
        .mjt-view-chip-del:hover {
            color: var(--mj-status-error-text);
        }
        .mjt-save-view-form {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            margin-left: auto;
            flex-wrap: wrap;
        }
        .mjt-save-view-inp {
            min-width: 180px;
            padding: 4px 10px;
            min-height: 30px;
            border: 1px solid var(--mj-border-strong);
            border-radius: var(--mj-radius-sm, 6px);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: 12px;
        }
        .mjt-bulk-banner {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 10px;
            padding: 8px 12px;
            border-radius: var(--mj-radius-md, 8px);
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
        }
        .mjt-bulk-banner--success {
            background: var(--mj-status-success-bg);
            color: var(--mj-status-success-text);
            border: 1px solid color-mix(in oklab, var(--mj-status-success) 30%, transparent);
        }
        .mjt-bulk-banner--error {
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
            border: 1px solid color-mix(in oklab, var(--mj-status-error) 30%, transparent);
        }
        .mjt-bulk-dismiss {
            margin-left: auto;
            border: none;
            background: transparent;
            color: inherit;
            text-decoration: underline;
            font-size: 11px;
            cursor: pointer;
        }
        .mjt-suggestion-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 11px;
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md);
            background: var(--mj-bg-surface-elevated, var(--mj-bg-surface));
            color: var(--mj-text-secondary);
            font-size: 12px;
            font-weight: var(--mj-font-semibold);
            font-family: inherit;
            cursor: pointer;
            white-space: nowrap;
        }
        .mjt-suggestion-pill:hover {
            border-color: var(--mj-brand-primary);
            color: var(--mj-text-primary);
        }
        .mjt-suggestion-pill--active {
            border-color: var(--mj-brand-primary);
            color: var(--mj-brand-primary);
            background: color-mix(in oklab, var(--mj-brand-primary) 10%, var(--mj-bg-surface));
        }
        .mjt-suggestion-pill__count {
            font-size: 11px;
            font-weight: var(--mj-font-bold);
            padding: 1px 6px;
            border-radius: var(--mj-radius-full, 9999px);
            background: var(--mj-status-info-bg);
            color: var(--mj-status-info-text);
        }
        .mjt-proj-stage {
            padding: 16px;
            min-width: 0;
            width: 100%;
            box-sizing: border-box;
        }
        .mjt-wbs-stage {
            display: flex;
            flex-direction: column;
            gap: 12px;
            min-width: 0;
            width: 100%;
            padding-bottom: 80px;
        }
        .mjt-wbs-loading {
            padding: 32px;
            text-align: center;
            color: var(--mj-text-muted);
            font-size: var(--mj-text-sm, 14px);
        }
        @media (max-width: 640px) {
            .mjt-desktop-only { display: none !important; }
            .mjt-save-view-btn .action-btn-label { display: none; }
            .mjt-proj-stage { padding: 12px; }
            .mjt-search-flex { flex: 1 1 180px; min-width: 160px; }
        }
    `],
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
    @Output() DrawerOpenChange = new EventEmitter<boolean>();

    public get ProviderToUse(): IMetadataProvider {
        return this.Provider ?? Metadata.Provider;
    }

    public ViewToggleOptions: ViewToggleOption[] = [
        { key: 'wbs', icon: 'fa-solid fa-sitemap', label: 'WBS', title: 'Work Breakdown Structure' },
        { key: 'list', icon: 'fa-solid fa-list', label: 'List', title: 'Tree List View' },
        { key: 'kanban', icon: 'fa-solid fa-table-columns', label: 'Board', title: 'Board View' },
        { key: 'gantt', icon: 'fa-solid fa-chart-gantt', label: 'Timeline', title: 'Gantt Timeline View' },
    ];
    public ViewMode: TaskViewMode = 'wbs';
    public PanelMode: TasksDashboardPanelMode = 'none';
    public SelectedTaskID: string | null = null;
    public DefaultParentTaskID: string | null = null;
    public SelectedCategoryID: string | null = null;
    public CurrentPersonID: string | null = null;
    public RailCollapsed = false;
    public Loading = false;
    public SearchText = '';
    public ShowCmdK = false;
    public FieldSuggestionsAvailable = false;
    public PendingSuggestionsByTask = new Map<string, TaskPendingSuggestionsSummary>();
    public TotalPendingSuggestionsCount = 0;

    // WBS Hierarchy view state (loaded via TasksEngineBase + batched RunViews)
    public WbsAllTasks: TaskWidgetItem[] = [];
    public FilteredWbsTasks: TaskWidgetItem[] = [];
    public WbsSummary: TaskWbsSummaryMetrics = {
        TotalCount: 0,
        CompletedCount: 0,
        InProgressCount: 0,
        BlockedCount: 0,
        OpenCount: 0,
        OverdueCount: 0,
        OverallCompletionPercent: 0,
    };
    public WbsLoading = false;
    public WbsLoadError: string | null = null;
    public WbsQuickAdding = false;
    private wbsLoaded = false;

    // Saved Filter Views (UserInfoEngine persisted — zero localStorage)
    public SavedViews: SavedTaskFilterView[] = [];
    public ActiveSavedViewID: string | null = null;
    public ShowSaveViewInput = false;
    public NewViewName = '';

    // Shared multi-select Bulk Action Dock across List, Board, AND Gantt
    public SelectedTaskIDs: string[] = [];
    public VisibleTaskIDs: string[] = [];
    public BulkBusy = false;
    public BulkError = '';
    public BulkSuccess = '';
    public BulkPeopleOptions: TaskBulkLookupOption[] = [];
    public BulkRoleOptions: TaskBulkLookupOption[] = [];
    public BulkTaskRoleOptions: TaskBulkLookupOption[] = [];
    public BulkOrgOptions: TaskBulkLookupOption[] = [];
    public BulkCategoryOptions: TaskBulkLookupOption[] = [];
    public BulkTaskTypeOptions: TaskBulkLookupOption[] = [];
    public BulkStageOptions: TaskBulkLookupOption[] = [];
    public BulkTagOptions: TaskBulkLookupOption[] = [];

    public Categories: TaskCategoryOption[] = [];
    public CategoryNavSections: MJLeftNavSection[] = [];
    public TaskTypes: Array<TaskTypeClassificationInput & { ID: string; Name: string }> = [];
    public PeopleOptions: { ID: string; Name: string }[] = [];
    public OrganizationOptions: { ID: string; Name: string; LinkedCompanyID: string | null }[] = [];
    public FilterValues: Record<string, unknown> = {
        assignee: null,
        dueDate: null,
        organizationId: null,
        status: null,
        priority: null,
        typeId: null,
    };
    public FilterFields: FilterFieldConfig[] = [];
    public KPIs: TaskKPIs = {
        TotalActive: 0,
        InProgress: 0,
        Blocked: 0,
        Overdue: 0,
        AvgPercentComplete: 0,
    };

    @ViewChild('taskWbs') public taskWbs?: TaskWbsTreeComponent;
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
        if (this.PanelMode === 'help') return 'OKRs & Goals Help';
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

    public get AssigneeFilterValue(): string | null {
        return (this.FilterValues['assignee'] as string | null) ?? null;
    }

    public get DueDateFilterValue(): TaskDueDateFilterKey | null {
        return (this.FilterValues['dueDate'] as TaskDueDateFilterKey | null) ?? null;
    }

    public get OrganizationFilterValue(): string | null {
        return (this.FilterValues['organizationId'] as string | null) ?? null;
    }

    public get ActiveOrganizationDefaultID(): string | null {
        const val = this.OrganizationFilterValue;
        return val && val !== '__none__' ? val : null;
    }

    public get ActiveFilterCount(): number {
        let count = 0;
        if (this.FilterValues['assignee']) count++;
        if (this.FilterValues['dueDate']) count++;
        if (this.FilterValues['organizationId']) count++;
        if (this.FilterValues['status']) count++;
        if (this.FilterValues['priority']) count++;
        if (this.FilterValues['typeId']) count++;
        return count;
    }

    public get CommandItems(): TaskCommandPaletteItem[] {
        const savedViewCommands: TaskCommandPaletteItem[] = this.SavedViews.map((v) => ({
            ID: `saved-view:${v.ID}`,
            Label: `Saved View: ${v.Name}`,
            Group: 'Views',
            IconClass: 'fa-solid fa-bookmark',
        }));
        return [
            { ID: 'new-task', Label: 'Create New Task', Group: 'Actions', IconClass: 'fa-solid fa-plus' },
            { ID: 'from-template', Label: 'Launch from Template', Group: 'Actions', IconClass: 'fa-solid fa-copy' },
            { ID: 'view-wbs', Label: 'Switch to WBS Hierarchy View', Group: 'Views', IconClass: 'fa-solid fa-sitemap' },
            { ID: 'view-list', Label: 'Switch to Tree List View', Group: 'Views', IconClass: 'fa-solid fa-list' },
            { ID: 'view-kanban', Label: 'Switch to Board View', Group: 'Views', IconClass: 'fa-solid fa-table-columns' },
            { ID: 'view-gantt', Label: 'Switch to Timeline / Gantt View', Group: 'Views', IconClass: 'fa-solid fa-chart-gantt' },
            ...savedViewCommands,
            { ID: 'reset-filters', Label: 'Clear All Filters', Group: 'Actions', IconClass: 'fa-solid fa-filter-circle-xmark' },
        ];
    }

    public get WbsSummaryActiveKey(): string | null {
        switch (this.StatusFilterValue) {
            case 'InProgress':
                return 'in-progress';
            case 'Blocked':
                return 'blocked';
            case 'Completed':
                return 'completed';
            default:
                return null;
        }
    }

    public readonly WbsRowBadgeResolver = (task: TaskWidgetItem): readonly TaskBadgeDescriptor[] => {
        const badges: TaskBadgeDescriptor[] = [];
        if (task.Priority === 'Critical') {
            badges.push({ Label: 'Critical', Icon: 'fa-solid fa-fire', Tone: 'error', Tooltip: 'Critical priority' });
        } else if (task.Priority === 'High') {
            badges.push({ Label: 'High', Icon: 'fa-solid fa-flag', Tone: 'warning', Tooltip: 'High priority' });
        }
        if (task.TaskTypeStatusName) {
            badges.push({ Label: task.TaskTypeStatusName, Tone: 'info', Tooltip: `Stage: ${task.TaskTypeStatusName}` });
        }
        if (task.OrganizationName) {
            badges.push({
                Label: task.OrganizationName,
                Icon: 'fa-solid fa-building',
                Tone: 'neutral',
                Tooltip: `Organization: ${task.OrganizationName}`,
            });
        }
        if (task.DependencyCount && task.DependencyCount > 0) {
            const noun = task.DependencyCount === 1 ? 'dep' : 'deps';
            badges.push({
                Label: `${task.DependencyCount} ${noun}`,
                Icon: 'fa-solid fa-link',
                Tone: 'neutral',
                Tooltip: `${task.DependencyCount} linked ${task.DependencyCount === 1 ? 'dependency' : 'dependencies'}`,
            });
        }
        const suggestionSummary = this.PendingSuggestionsByTask.get(NormalizeUUID(task.ID));
        if (suggestionSummary && suggestionSummary.pendingCount > 0) {
            badges.push({
                Label: `${suggestionSummary.pendingCount}`,
                Icon: 'fa-solid fa-wand-magic-sparkles',
                Tone: 'info',
                Tooltip: FormatPendingSuggestionTooltip(suggestionSummary),
            });
        }
        return badges;
    };

    public readonly WbsRowToneResolver = (task: TaskWidgetItem): TaskWbsRowTone => {
        if (task.Status === 'Blocked') return 'error';
        if (task.Status === 'Completed') return 'muted';
        return 'default';
    };

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
            this.recomputeWbsProjection();
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

    private canReadEntity(entityName: string): boolean {
        const provider = this.ProviderToUse;
        const currentUser = provider?.CurrentUser;
        if (!currentUser) return true;
        const entity = provider?.EntityByName?.(entityName);
        if (!entity) return false;
        return Boolean(entity.GetUserPermisions(currentUser)?.CanRead);
    }

    public SelectTask(taskID: string): void {
        this.OpenPanel('detail', taskID);
    }

    public OpenFullRecord(taskID: string | null): void {
        this.ClosePanel();
        OpenTaskRecord(taskID);
    }

    public async ngOnInit(): Promise<void> {
        try {
            const savedView = UserInfoEngine.Instance.GetSetting(VIEW_MODE_SETTING);
            if (savedView === 'wbs' || savedView === 'list' || savedView === 'kanban' || savedView === 'gantt') {
                this.ViewMode = savedView;
            }
            const savedRail = UserInfoEngine.Instance.GetSetting(RAIL_COLLAPSED_SETTING);
            if (savedRail === 'true') {
                this.RailCollapsed = true;
            }
            this.SavedViews = ParseSavedTaskFilterViews(
                UserInfoEngine.Instance.GetSetting(SAVED_TASK_VIEWS_SETTING),
            );
        } catch {
            // Safe fallback when UserInfoEngine is not bootstrapped in isolated tests
        }

        const [personID] = await Promise.all([
            ResolveCurrentPersonID().catch((err) => {
                LogError(err);
                return null;
            }),
            this.LoadCategoriesAndTypes(),
            this.LoadKPIs(),
            this.ViewMode === 'wbs' ? this.LoadWbsTasks() : Promise.resolve(),
        ]);
        this.CurrentPersonID = personID;
        this.buildCategoryNav();
        this.buildFilterFields();
        this.recomputeWbsProjection();
        this.cdr.markForCheck();
    }

    public SetView(mode: TaskViewMode): void {
        this.ViewMode = mode;
        try {
            UserInfoEngine.Instance.SetSettingDebounced(VIEW_MODE_SETTING, mode);
        } catch {
            // Safe fallback when UserInfoEngine is not initialized
        }
        if (mode === 'wbs') {
            if (!this.wbsLoaded) {
                void this.LoadWbsTasks();
            } else {
                this.recomputeWbsProjection();
            }
        }
        this.cdr.markForCheck();
    }

    public onViewToggleChange(key: string): void {
        if (key === 'wbs' || key === 'list' || key === 'kanban' || key === 'gantt') {
            this.SetView(key);
        }
    }

    public OnSearchTextChange(value: string): void {
        this.SearchText = value;
        this.ActiveSavedViewID = null;
        this.recomputeWbsProjection();
        this.cdr.markForCheck();
    }

    public OnRailCollapsedChange(collapsed: boolean): void {
        this.RailCollapsed = collapsed;
        UserInfoEngine.Instance.SetSettingDebounced(RAIL_COLLAPSED_SETTING, String(collapsed));
        this.cdr.markForCheck();
    }

    public OnCategoryNavClicked(item: MJLeftNavItem): void {
        this.SelectedCategoryID = item.id === '__all__' ? null : item.id;
        this.ActiveSavedViewID = null;
        this.OnCategoryChanged();
    }

    public OnFilterValuesChange(values: Record<string, unknown>): void {
        this.FilterValues = { ...values };
        this.ActiveSavedViewID = null;
        this.recomputeWbsProjection();
        this.cdr.markForCheck();
    }

    public ResetFilters(): void {
        this.FilterValues = {
            assignee: null,
            dueDate: null,
            organizationId: null,
            status: null,
            priority: null,
            typeId: null,
        };
        this.SearchText = '';
        this.ActiveSavedViewID = null;
        this.OnPendingSuggestionsChanged(false);
        this.recomputeWbsProjection();
        this.cdr.markForCheck();
    }

    public OnWbsSummaryTileClicked(key: string): void {
        let nextStatus: string | null = null;
        if (key === 'in-progress') {
            nextStatus = this.StatusFilterValue === 'InProgress' ? null : 'InProgress';
        } else if (key === 'blocked') {
            nextStatus = this.StatusFilterValue === 'Blocked' ? null : 'Blocked';
        } else if (key === 'completed') {
            nextStatus = this.StatusFilterValue === 'Completed' ? null : 'Completed';
        }
        this.FilterValues = {
            ...this.FilterValues,
            status: nextStatus,
        };
        this.ActiveSavedViewID = null;
        this.recomputeWbsProjection();
        this.cdr.markForCheck();
    }

    public OnWbsCreateTaskRequested(event: { GroupID?: string; ParentTaskID?: string }): void {
        this.OpenPanel('edit', null, event.ParentTaskID ?? null);
    }

    public async OnWbsStatusToggled(event: { TaskID: string; NewStatus: TaskStatusValue }): Promise<void> {
        const provider = this.ProviderToUse;
        if (typeof provider?.GetEntityObject !== 'function') return;
        try {
            const entity = await provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            await entity.InnerLoad(CompositeKey.FromID(event.TaskID));
            entity.Status = event.NewStatus;
            entity.PercentComplete = event.NewStatus === 'Completed' ? 100 : 0;
            if (await entity.Save()) {
                this.WbsAllTasks = this.WbsAllTasks.map((t) =>
                    UUIDsEqual(t.ID, event.TaskID)
                        ? { ...t, Status: event.NewStatus, PercentComplete: entity.PercentComplete }
                        : t,
                );
                this.recomputeWbsProjection();
                await Promise.all([this.LoadKPIs(), this.LoadWbsTasks()]);
            }
        } catch (err) {
            LogError(err);
        } finally {
            this.cdr.markForCheck();
        }
    }

    public async OnWbsQuickCapture(event: TaskQuickCaptureSubmitEvent): Promise<void> {
        if (!event.Title || this.WbsQuickAdding) return;
        this.WbsQuickAdding = true;
        this.cdr.markForCheck();
        try {
            const provider = this.ProviderToUse;
            const engine = await EnsureTasksEngineLoaded(provider);
            const typeID =
                engine.TaskTypes.length > 0
                    ? SelectGenericQuickAddTaskTypeID(engine.TaskTypes)
                    : await ResolveDefaultGenericTaskTypeID(this.createRunView());
            if (!typeID || typeof provider?.GetEntityObject !== 'function') return;

            const entity = await provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            entity.NewRecord();
            entity.Name = event.Title;
            entity.TypeID = typeID;
            entity.Status = 'Open';
            entity.Priority = event.Priority ?? 'Medium';
            if (this.SelectedCategoryID) entity.CategoryID = this.SelectedCategoryID;
            if (this.ActiveOrganizationDefaultID) entity.OrganizationID = this.ActiveOrganizationDefaultID;
            if (this.CurrentPersonID) entity.CreatedByPersonID = this.CurrentPersonID;
            if (event.DueAt) entity.DueAt = event.DueAt;
            if (event.HoursEstimated != null) entity.HoursEstimated = event.HoursEstimated;

            if (event.AssigneeQuery) {
                const q = event.AssigneeQuery.toLowerCase();
                const match = this.PeopleOptions.find((p) => p.Name.toLowerCase().includes(q));
                const peopleEntityID = provider.EntityByName?.('MJ_BizApps_Common: People')?.ID;
                if (match && peopleEntityID && entity.Assignments) {
                    const assignment = await entity.Assignments.Create();
                    assignment.AssigneeEntityID = peopleEntityID;
                    assignment.AssigneeRecordID = match.ID;
                    assignment.Status = 'Pending';
                }
            }

            if (await entity.Save()) {
                await Promise.all([this.LoadKPIs(), this.LoadWbsTasks()]);
            }
        } catch (err) {
            LogError(err);
        } finally {
            this.WbsQuickAdding = false;
            this.cdr.markForCheck();
        }
    }

    /**
     * Loads WBS hierarchy tasks + assignees + dependencies using `TasksEngineBase.Instance`
     * (cached taxonomy & directory) and a single batched `rv.RunViews([...])` call for
     * dynamic relations, then projects through all active dashboard filters preserving
     * full WBS ancestor chains.
     */
    public async LoadWbsTasks(): Promise<void> {
        this.WbsLoading = true;
        this.WbsLoadError = null;
        this.cdr.markForCheck();
        try {
            const provider = this.ProviderToUse;
            const rv = this.createRunView();
            const [engine, peopleList, orgsList, tasksRes] = await Promise.all([
                EnsureTasksEngineLoaded(provider),
                TasksEngineBase.Instance.GetOrLoadAllPeople(provider).catch(() => []),
                TasksEngineBase.Instance.GetOrLoadActiveOrganizations(provider).catch(() => []),
                rv.RunView<WbsTaskQueryRow>({
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: "Status <> 'Cancelled'",
                    OrderBy: 'Sequence ASC, DueAt ASC',
                    Fields: [
                        'ID',
                        'Name',
                        'Description',
                        'Status',
                        'Priority',
                        'DueAt',
                        'StartedAt',
                        'PercentComplete',
                        'HoursEstimated',
                        'HoursActual',
                        'ParentID',
                        'TypeID',
                        'Type',
                        'CategoryID',
                        'Category',
                        'OrganizationID',
                        'Organization',
                        'TaskTypeStatusID',
                        'TaskTypeStatus',
                        'BlockedReason',
                        'Sequence',
                    ],
                    ResultType: 'simple',
                    BypassCache: true,
                }),
            ]);

            if (tasksRes && tasksRes.Success === false) {
                const msg = tasksRes.ErrorMessage || 'Failed to load WBS tasks.';
                LogError(msg);
                this.WbsLoadError = msg;
                this.WbsAllTasks = [];
                this.recomputeWbsProjection();
                return;
            }

            const rawTasks = tasksRes?.Results ?? [];
            const taskIds = rawTasks.map((t) => t.ID).filter((id) => IsValidUUID(id));
            const scopeClause =
                taskIds.length > 0 && taskIds.length <= 500
                    ? `TaskID IN (${taskIds.map((id) => `'${EscapeSQLString(id)}'`).join(',')})`
                    : undefined;
            const depScopeClause =
                taskIds.length > 0 && taskIds.length <= 500
                    ? `TaskID IN (${taskIds.map((id) => `'${EscapeSQLString(id)}'`).join(',')}) OR DependsOnTaskID IN (${taskIds.map((id) => `'${EscapeSQLString(id)}'`).join(',')})`
                    : undefined;

            type WbsBatchSlot = 'assignments' | 'dependencies';
            const batchParams: RunViewParams[] = [];
            const batchSlots: WbsBatchSlot[] = [];

            if (rawTasks.length > 0 && this.canReadEntity('MJ_BizApps_Tasks: Task Assignments')) {
                batchParams.push({
                    EntityName: 'MJ_BizApps_Tasks: Task Assignments',
                    ExtraFilter: scopeClause,
                    Fields: ['TaskID', 'AssigneeEntityID', 'AssigneeRecordID', 'RoleID', 'Status'],
                    ResultType: 'simple',
                    BypassCache: true,
                });
                batchSlots.push('assignments');
            }
            if (rawTasks.length > 0 && this.canReadEntity('MJ_BizApps_Tasks: Task Dependencies')) {
                batchParams.push({
                    EntityName: 'MJ_BizApps_Tasks: Task Dependencies',
                    ExtraFilter: depScopeClause,
                    Fields: ['TaskID', 'DependsOnTaskID', 'DependencyType'],
                    ResultType: 'simple',
                    BypassCache: true,
                });
                batchSlots.push('dependencies');
            }

            const batchResults =
                batchParams.length > 0 ? await RunViewsBatch(rv, batchParams).catch(() => []) : [];

            let assignmentRows: WbsAssignmentQueryRow[] = [];
            let dependencyRows: WbsDependencyQueryRow[] = [];

            for (let i = 0; i < batchSlots.length; i++) {
                const res = batchResults[i];
                if (!res?.Success) continue;
                if (batchSlots[i] === 'assignments') {
                    assignmentRows = (res.Results ?? []) as WbsAssignmentQueryRow[];
                } else if (batchSlots[i] === 'dependencies') {
                    dependencyRows = (res.Results ?? []) as WbsDependencyQueryRow[];
                }
            }

            const personNameById = new Map<string, string>();
            for (const p of peopleList) {
                personNameById.set(p.ID.toLowerCase(), p.FullName);
            }
            const orgNameById = new Map<string, string>();
            for (const o of orgsList) {
                orgNameById.set(o.ID.toLowerCase(), o.Name);
            }
            const roleNameById = new Map<string, string>();
            for (const r of engine.TaskRoles) {
                roleNameById.set(r.ID.toLowerCase(), r.Name);
            }
            const rolesEntityID = provider.EntityByName?.('MJ: Roles')?.ID ?? null;

            const assigneesByTask = new Map<string, TaskWidgetAssignee[]>();
            for (const a of assignmentRows) {
                if (!a.TaskID || !a.AssigneeRecordID) continue;
                const taskKey = a.TaskID.toLowerCase();
                const isRole = Boolean(rolesEntityID && UUIDsEqual(a.AssigneeEntityID, rolesEntityID));
                const displayName =
                    personNameById.get(a.AssigneeRecordID.toLowerCase()) ??
                    RoleAssigneeName(a.AssigneeEntityID, a.AssigneeRecordID) ??
                    a.AssigneeRecordID;
                const list = assigneesByTask.get(taskKey) ?? [];
                list.push({
                    DisplayName: displayName,
                    RoleName: a.RoleID ? (roleNameById.get(a.RoleID.toLowerCase()) ?? null) : null,
                    Status: a.Status ?? 'Pending',
                    EntityName: isRole ? 'MJ: Roles' : 'MJ_BizApps_Common: People',
                    RecordID: a.AssigneeRecordID,
                    IsRole: isRole,
                });
                assigneesByTask.set(taskKey, list);
            }

            const depCountByTask = new Map<string, number>();
            for (const d of dependencyRows) {
                if (d.TaskID) {
                    const k = d.TaskID.toLowerCase();
                    depCountByTask.set(k, (depCountByTask.get(k) ?? 0) + 1);
                }
                if (d.DependsOnTaskID) {
                    const k = d.DependsOnTaskID.toLowerCase();
                    depCountByTask.set(k, (depCountByTask.get(k) ?? 0) + 1);
                }
            }

            this.WbsAllTasks = rawTasks.map((r) => {
                const taskKey = r.ID.toLowerCase();
                const taskType = engine.TaskTypeById(r.TypeID);
                const category = engine.CategoryById(r.CategoryID);
                const typeStatus = engine.TaskTypeStatusById(r.TaskTypeStatusID);
                const assignees = assigneesByTask.get(taskKey) ?? [];
                const orgName =
                    r.Organization ?? (r.OrganizationID ? (orgNameById.get(r.OrganizationID.toLowerCase()) ?? null) : null);

                return {
                    ID: r.ID,
                    Name: r.Name,
                    Description: r.Description,
                    ParentID: r.ParentID,
                    Status: r.Status,
                    Priority: r.Priority,
                    DueAt: r.DueAt,
                    StartedAt: r.StartedAt,
                    PercentComplete: r.PercentComplete,
                    HoursEstimated: r.HoursEstimated,
                    HoursActual: r.HoursActual,
                    Sequence: r.Sequence,
                    TypeID: r.TypeID,
                    TypeName: taskType?.Name ?? r.Type ?? null,
                    TaskTypeName: taskType?.Name ?? r.Type ?? null,
                    TypeCode: taskType?.Code ?? null,
                    KindLabel: resolveWbsKindLabel(taskType?.Code),
                    CategoryID: r.CategoryID,
                    CategoryName: category?.Name ?? r.Category ?? null,
                    OrganizationID: r.OrganizationID,
                    OrganizationName: orgName,
                    TaskTypeStatusID: r.TaskTypeStatusID,
                    TaskTypeStatusName: typeStatus?.Name ?? r.TaskTypeStatus ?? null,
                    BlockedReason: r.BlockedReason,
                    Assignees: assignees,
                    AssigneeNames: assignees.map((a) => a.DisplayName),
                    DependencyCount: depCountByTask.get(taskKey) ?? 0,
                };
            });

            this.wbsLoaded = true;
            this.recomputeWbsProjection();
        } catch (err) {
            LogError(err);
            this.WbsLoadError = err instanceof Error ? err.message : 'Failed to load WBS tasks.';
            this.WbsAllTasks = [];
            this.recomputeWbsProjection();
        } finally {
            this.WbsLoading = false;
            this.cdr.markForCheck();
        }
    }

    public recomputeWbsProjection(): void {
        const projected = ProjectFilteredWbsTasks(this.WbsAllTasks, {
            CategoryID: this.SelectedCategoryID,
            SearchText: this.SearchText,
            Status: this.StatusFilterValue,
            Priority: this.PriorityFilterValue,
            TypeID: this.TypeFilterValue,
            Assignee: this.AssigneeFilterValue,
            DueDate: this.DueDateFilterValue,
            OrganizationID: this.OrganizationFilterValue,
            CurrentPersonID: this.CurrentPersonID,
            CurrentRoleIDs: CurrentUserRoleIDs(this.ProviderToUse?.CurrentUser),
            OnlyPendingSuggestions: this._onlyPendingSuggestions,
            PendingSuggestionsByTask: this.PendingSuggestionsByTask,
        });
        this.FilteredWbsTasks = projected;
        this.WbsSummary = ComputeWbsSummary(BuildWbsTree(projected));
        if (this.ViewMode === 'wbs') {
            this.VisibleTaskIDs = projected.map((t) => t.ID);
        }
    }

    public ToggleSaveViewComposer(): void {
        this.ShowSaveViewInput = !this.ShowSaveViewInput;
        this.cdr.markForCheck();
    }

    public SaveCurrentView(): void {
        const name = this.NewViewName.trim();
        if (!name) return;
        const cleanFilters: SavedTaskFilterMap = {};
        for (const [k, v] of Object.entries(this.FilterValues)) {
            if (typeof v === 'string' || typeof v === 'number' || typeof v === 'boolean' || v === null) {
                cleanFilters[k] = v as SavedTaskFilterValue;
            }
        }
        this.SavedViews = UpsertSavedTaskFilterView(this.SavedViews, {
            Name: name,
            CategoryID: this.SelectedCategoryID,
            ViewMode: this.ViewMode,
            SearchText: this.SearchText,
            Filters: cleanFilters,
        });
        this.ActiveSavedViewID = this.SavedViews.find((v) => v.Name.toLowerCase() === name.toLowerCase())?.ID ?? null;
        UserInfoEngine.Instance.SetSettingDebounced(
            SAVED_TASK_VIEWS_SETTING,
            SerializeSavedTaskFilterViews(this.SavedViews),
        );
        this.NewViewName = '';
        this.ShowSaveViewInput = false;
        this.cdr.markForCheck();
    }

    public ApplySavedView(view: SavedTaskFilterView): void {
        this.SelectedCategoryID = view.CategoryID ?? null;
        this.SearchText = view.SearchText ?? '';
        this.FilterValues = {
            assignee: view.Filters['assignee'] ?? null,
            dueDate: view.Filters['dueDate'] ?? null,
            organizationId: view.Filters['organizationId'] ?? null,
            status: view.Filters['status'] ?? null,
            priority: view.Filters['priority'] ?? null,
            typeId: view.Filters['typeId'] ?? null,
        };
        if (view.ViewMode && view.ViewMode !== this.ViewMode) {
            this.SetView(view.ViewMode);
        }
        this.ActiveSavedViewID = view.ID;
        this.recomputeWbsProjection();
        this.OnCategoryChanged();
    }

    public DeleteSavedView(viewId: string): void {
        this.SavedViews = DeleteSavedTaskFilterView(this.SavedViews, viewId);
        if (this.ActiveSavedViewID === viewId) {
            this.ActiveSavedViewID = null;
        }
        UserInfoEngine.Instance.SetSettingDebounced(
            SAVED_TASK_VIEWS_SETTING,
            SerializeSavedTaskFilterViews(this.SavedViews),
        );
        this.cdr.markForCheck();
    }

    public OnSelectedTaskIDsChange(ids: string[]): void {
        this.SelectedTaskIDs = [...ids];
        this.cdr.markForCheck();
    }

    public OnVisibleTaskIDsChange(ids: string[]): void {
        this.VisibleTaskIDs = [...ids];
        this.cdr.markForCheck();
    }

    public async OnBulkDockAction(action: TaskBulkActionRequest): Promise<void> {
        if (action.Kind === 'clear') {
            this.SelectedTaskIDs = [];
            this.cdr.markForCheck();
            return;
        }
        if (action.Kind === 'select-all') {
            this.SelectedTaskIDs = [...this.VisibleTaskIDs];
            this.cdr.markForCheck();
            return;
        }
        if (action.Kind === 'status' && action.Status) {
            await this.ExecuteBulkPatch({ Status: action.Status });
            return;
        }
        if (action.Kind === 'priority' && action.Priority) {
            await this.ExecuteBulkPatch({ Priority: action.Priority });
            return;
        }
        if (action.Kind === 'apply' && action.Patch) {
            await this.ExecuteBulkPatch(action.Patch);
        }
    }

    public async ExecuteBulkPatch(patch: TaskBulkPatch): Promise<void> {
        if (this.SelectedTaskIDs.length === 0 || this.BulkBusy) return;
        this.BulkBusy = true;
        this.BulkError = '';
        this.BulkSuccess = '';
        this.cdr.markForCheck();
        try {
            const res = await new TasksBulkUpdateOperation().Execute({
                TaskIDs: [...this.SelectedTaskIDs],
                ...patch,
            });
            if (!res.Success || !res.Output) {
                this.BulkError = res.ErrorMessage || 'Bulk update failed on the server.';
                return;
            }
            const out = res.Output;
            if (out.FailedCount > 0) {
                this.BulkError = `${out.UpdatedCount} updated, ${out.FailedCount} failed: ${out.Failures[0]?.Error ?? 'unknown error'}`;
            } else {
                this.BulkSuccess = `Updated ${out.UpdatedCount} ${out.UpdatedCount === 1 ? 'task' : 'tasks'}.`;
            }
            this.SelectedTaskIDs = [];
            await this.LoadKPIs();
            this.RefreshActiveView();
        } catch (err) {
            this.BulkError = err instanceof Error ? err.message : 'Bulk update failed.';
        } finally {
            this.BulkBusy = false;
            this.cdr.markForCheck();
        }
    }

    public async RefreshAll(): Promise<void> {
        await Promise.all([this.LoadCategoriesAndTypes(), this.LoadKPIs()]);
        this.buildCategoryNav();
        this.buildFilterFields();
        this.RefreshActiveView();
    }

    private async LoadCategoriesAndTypes(): Promise<void> {
        const provider = this.ProviderToUse;
        const [engine, people, orgs] = await Promise.all([
            EnsureTasksEngineLoaded(provider),
            TasksEngineBase.Instance.GetOrLoadAllPeople(provider).catch(() => []),
            TasksEngineBase.Instance.GetOrLoadActiveOrganizations(provider).catch(() => []),
        ]);

        this.Categories = engine.ActiveCategories.map((c) => ({
            ID: c.ID,
            Name: c.Name,
            ParentID: c.ParentID,
            ColorCode: c.ColorCode,
        }));
        this.TaskTypes = engine.ActiveTaskTypes.map((t) => ({
            ID: t.ID,
            Name: t.Name,
            Code: t.Code,
            ExtensionEntity: t.ExtensionEntity,
            IsActive: t.IsActive,
        }));
        this.PeopleOptions = people.map((p) => ({
            ID: p.ID,
            Name: p.FullName,
        }));
        this.OrganizationOptions = [...orgs];

        // Populate shared Bulk Action Dock lookups once for List, Board, and Gantt
        this.BulkPeopleOptions = this.PeopleOptions.map((p) => ({
            ID: p.ID,
            Label: p.Name,
            EntityName: 'MJ_BizApps_Common: People',
        }));
        this.BulkRoleOptions = (provider?.Roles ?? []).map((r) => ({
            ID: r.ID,
            Label: r.Name,
            EntityName: 'MJ: Roles',
        }));
        this.BulkTaskRoleOptions = engine.TaskRoles.map((r) => ({ ID: r.ID, Label: r.Name }));
        this.BulkOrgOptions = this.OrganizationOptions.map((o) => ({
            ID: o.ID,
            Label: o.Name,
            Sublabel: o.LinkedCompanyID ? 'Company' : undefined,
        }));
        this.BulkCategoryOptions = this.Categories.map((c) => ({ ID: c.ID, Label: c.Name }));
        this.BulkTaskTypeOptions = FilterGenericCreatableTaskTypes(this.TaskTypes).map((t) => ({
            ID: t.ID,
            Label: t.Name,
        }));
        this.BulkStageOptions = engine.ActiveTypeStatuses.map((s) => ({ ID: s.ID, Label: s.Name }));
        this.BulkTagOptions = engine.TaskTags.map((t) => ({ ID: t.ID, Label: t.Name }));
    }

    public async LoadKPIs(): Promise<void> {
        this.Loading = true;
        this.cdr.markForCheck();
        try {
            const rv = this.createRunView();
            const res = await rv.RunView<{
                ID: string;
                Status: string;
                DueAt: string | null;
                PercentComplete: number;
                CategoryID: string | null;
            }>({
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                Fields: ['ID', 'Status', 'DueAt', 'PercentComplete', 'CategoryID'],
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

            const suggestions = await TaskFieldSuggestionsHelper.LoadPendingSuggestions(this.ProviderToUse, {
                taskIds: rows.map((t) => t.ID),
            });
            this.FieldSuggestionsAvailable = suggestions.available;
            this.PendingSuggestionsByTask = suggestions.byTaskId;
            this.TotalPendingSuggestionsCount = CountTotalPendingSuggestions(suggestions.byTaskId);
            this.recomputeWbsProjection();
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
        const mjRoles = (this.ProviderToUse?.Roles ?? []).map((r) => ({
            text: `${r.Name} (Role)`,
            value: `role:${r.ID}`,
        }));
        this.FilterFields = [
            {
                key: 'assignee',
                type: 'dropdown',
                label: 'Assignee',
                icon: 'fa-solid fa-user',
                placeholder: 'All assignees',
                options: [
                    { text: 'All assignees', value: null },
                    { text: 'Assigned to Me', value: '__me__' },
                    { text: 'Unassigned', value: '__unassigned__' },
                    ...this.PeopleOptions.map((p) => ({ text: p.Name, value: `person:${p.ID}` })),
                    ...mjRoles,
                ],
            },
            {
                key: 'dueDate',
                type: 'dropdown',
                label: 'Due Date',
                icon: 'fa-regular fa-calendar',
                placeholder: 'Any due date',
                options: [
                    { text: 'Any due date', value: null },
                    { text: 'Overdue', value: 'overdue' },
                    { text: 'Due Today', value: 'today' },
                    { text: 'Next 7 Days', value: 'week' },
                    { text: 'Next 30 Days', value: 'month' },
                    { text: 'No Due Date', value: 'none' },
                ],
            },
            {
                key: 'organizationId',
                type: 'dropdown',
                label: 'Organization / Company',
                icon: 'fa-solid fa-building',
                placeholder: 'All organizations',
                options: [
                    { text: 'All organizations', value: null },
                    { text: 'No organization', value: '__none__' },
                    ...this.OrganizationOptions.map((o) => ({
                        text: o.LinkedCompanyID ? `★ ${o.Name} (Company)` : o.Name,
                        value: o.ID,
                    })),
                ],
            },
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
                    ...FilterActiveSelectableTaskTypes(this.TaskTypes).map((t) => ({ text: t.Name, value: t.ID })),
                ],
            },
        ];
    }

    public OnCategoryChanged(): void {
        this.recomputeWbsProjection();
        void this.LoadKPIs();
        this.RefreshActiveView();
    }

    public OpenPanel(
        mode: TasksDashboardPanelMode,
        taskID: string | null = null,
        defaultParentTaskID: string | null = null,
    ): void {
        this.PanelMode = mode;
        this.SelectedTaskID = taskID;
        this.DefaultParentTaskID = mode === 'edit' && !taskID ? defaultParentTaskID : null;
        this.DrawerOpenChange.emit(mode !== 'none');
        this.cdr.markForCheck();
    }

    public ClosePanel(): void {
        this.PanelMode = 'none';
        this.SelectedTaskID = null;
        this.DefaultParentTaskID = null;
        this.DrawerOpenChange.emit(false);
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
        if (item.ID.startsWith('saved-view:')) {
            const viewId = item.ID.slice('saved-view:'.length);
            const match = this.SavedViews.find((v) => v.ID === viewId);
            if (match) this.ApplySavedView(match);
        } else if (item.ID === 'new-task') this.OpenPanel('edit', null);
        else if (item.ID === 'from-template') this.OpenPanel('template');
        else if (item.ID === 'view-wbs') this.SetView('wbs');
        else if (item.ID === 'view-list') this.SetView('list');
        else if (item.ID === 'view-kanban') this.SetView('kanban');
        else if (item.ID === 'view-gantt') this.SetView('gantt');
        else if (item.ID === 'reset-filters') this.ResetFilters();
        this.cdr.markForCheck();
    }

    private RefreshActiveView(): void {
        if (this.ViewMode === 'wbs' || this.wbsLoaded) {
            void this.LoadWbsTasks();
        }
        this.taskGantt?.Refresh();
        this.taskKanban?.Refresh();
        void this.taskList?.Refresh();
        this.cdr.markForCheck();
    }
}
