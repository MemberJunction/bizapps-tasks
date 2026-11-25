import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    ContentChild,
    EventEmitter,
    Input,
    OnInit,
    Output,
    TemplateRef,
    ViewChild,
    inject,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { CompositeKey, Metadata, type IMetadataProvider } from '@memberjunction/core';
import { UserInfoEngine } from '@memberjunction/core-entities';
import { MJViewToggleComponent, ViewToggleOption } from '@memberjunction/ng-ui-components';
import type { TaskBadgeDescriptor } from '@mj-biz-apps/tasks-core';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import {
    TaskWbsTreeComponent,
    type TaskStatusValue,
    type TaskWbsFilterDef,
    type TaskWbsGroup,
    type TaskWbsGroupTemplateContext,
    type TaskWbsRowTemplateContext,
    type TaskWbsRowTone,
    type TaskWidgetItem,
} from '@mj-biz-apps/tasks-ng-widgets';
import { OpenTaskRecord } from '../../open-task-record';
import {
    TaskListComponent,
    TaskRow,
    BeforeTaskSelectedEvent,
    BeforeStatusChangeEvent,
    computeDueStatus,
} from '../task-list/task-list.component';
import {
    TaskKanbanComponent,
    BeforeKanbanStatusChangeEvent,
    AfterKanbanStatusChangeEvent,
    KanbanTaskData,
    type KanbanCardBadgeContext,
} from '../task-kanban/task-kanban.component';
import { TaskGanttComponent, type TaskGanttDependencyInput } from '../task-gantt/task-gantt.component';
import {
    TaskDetailPanelComponent,
    BeforeCommentPostedEvent,
    type TaskDetailTopExtensionContext,
} from '../task-detail-panel/task-detail-panel.component';
import { TaskEditPanelComponent, BeforeTaskSaveEvent } from '../task-edit-panel/task-edit-panel.component';
import { TaskDrawerShellComponent } from '../task-drawer-shell/task-drawer-shell.component';

/** The available view modes for the task panel. */
export type TaskViewMode = 'wbs' | 'list' | 'kanban' | 'gantt';

/** The current mode of the slide-in side panel. */
export type TaskPanelMode = 'none' | 'detail' | 'edit';

const VALID_VIEW_MODES: ReadonlySet<TaskViewMode> = new Set<TaskViewMode>(['wbs', 'list', 'kanban', 'gantt']);

/**
 * Cancellable event emitted before the panel opens for a task.
 * Set `Cancel = true` to prevent the panel from opening — useful when
 * you want to handle the task click with your own custom behavior instead.
 */
export class BeforePanelOpenEvent {
    /** Set to `true` to prevent the panel from opening. */
    Cancel = false;
    constructor(
        /** The panel mode that is about to open. */
        public Mode: TaskPanelMode,
        /** The task ID, or `null` for a new task. */
        public TaskID: string | null,
    ) {}
}

/**
 * Cancellable event emitted before the panel closes.
 * Set `Cancel = true` to keep the panel open (e.g., for unsaved changes confirmation).
 */
export class BeforePanelCloseEvent {
    /** Set to `true` to prevent the panel from closing. */
    Cancel = false;
}

const ALL_VIEW_OPTIONS: Record<TaskViewMode, ViewToggleOption> = {
    wbs: { key: 'wbs', icon: 'fa-solid fa-diagram-project', label: 'WBS', title: 'Work Breakdown Structure' },
    list: { key: 'list', icon: 'fa-solid fa-list', label: 'List', title: 'List View' },
    kanban: { key: 'kanban', icon: 'fa-solid fa-table-columns', label: 'Board', title: 'Board View' },
    gantt: { key: 'gantt', icon: 'fa-solid fa-chart-gantt', label: 'Timeline', title: 'Timeline View' },
};

/**
 * Unified embeddable Work Workspace (`WBS | List | Kanban | Gantt`) with responsive
 * `<bizapps-task-drawer-shell>`, `UserInfoEngine` view-mode persistence, controlled `[Tasks]`/`[Groups]`
 * OR self-fetching `[ExtraFilter]`/`[CategoryID]` modes, and pass-through extension slots.
 */
@Component({
    selector: 'bizapps-task-panel',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [
        CommonModule,
        TaskWbsTreeComponent,
        TaskListComponent,
        TaskKanbanComponent,
        TaskGanttComponent,
        TaskDetailPanelComponent,
        TaskEditPanelComponent,
        TaskDrawerShellComponent,
        MJViewToggleComponent,
    ],
    template: `
        <div class="task-panel-host">
            <ng-content select="[header-banner]"></ng-content>
            <ng-content select="[summary-strip]"></ng-content>

            @if ((AllowedViewModes && AllowedViewModes.length > 1) || ShowToolbarActions) {
                <div class="task-panel-toolbar">
                    <div class="task-panel-toolbar-left">
                        <ng-content select="[toolbar-actions]"></ng-content>
                    </div>
                    @if (AllowedViewModes && AllowedViewModes.length > 1) {
                        <mj-view-toggle
                            [Options]="viewToggleOptions"
                            [ActiveKey]="ViewMode"
                            (KeyChange)="onViewToggleChange($event)">
                        </mj-view-toggle>
                    }
                </div>
            }

            <div class="task-panel-workspace" [class.has-side-panel]="HasSidePanel">
                <div class="task-panel-body">
                    @switch (ViewMode) {
                        @case ('wbs') {
                            <div class="task-panel-wbs">
                                <mjt-wbs-tree
                                    #taskWbs
                                    [Tasks]="EffectiveWbsTasks"
                                    [Groups]="Groups"
                                    [ShowWbsCodes]="ShowWbsCodes"
                                    [ShowTreeConnectors]="ShowTreeConnectors"
                                    [ShowProgressBars]="ShowProgressBars"
                                    [ShowToolbar]="ShowWbsToolbar"
                                    [CustomFilters]="CustomFilters"
                                    [ReadOnly]="ReadOnly"
                                    [RowBadgeResolver]="RowBadgeResolver"
                                    [RowToneResolver]="RowToneResolver"
                                    [RowBadgesTemplate]="EffectiveRowBadgesTemplate"
                                    [RowMetaTemplate]="EffectiveRowMetaTemplate"
                                    [GroupHeaderMetaTemplate]="EffectiveGroupHeaderMetaTemplate"
                                    [GroupHeaderActionsTemplate]="EffectiveGroupHeaderActionsTemplate"
                                    [GroupFooterTemplate]="EffectiveGroupFooterTemplate"
                                    [EmptyTitle]="EmptyTitle"
                                    [EmptyMessage]="EmptyMessage"
                                    (TaskClicked)="onWbsTaskClicked($event)"
                                    (TaskDoubleClicked)="onOpenFullRecord($event.ID)"
                                    (StatusToggled)="onWbsStatusToggled($event)">
                                </mjt-wbs-tree>
                            </div>
                        }
                        @case ('list') {
                            <div class="task-panel-list">
                                <bizapps-task-list
                                    #taskList
                                    [Provider]="Provider"
                                    [Tasks]="EffectiveFlatTasks"
                                    [CategoryID]="CategoryID"
                                    [ExtraFilter]="ExtraFilter"
                                    [StatusFilter]="StatusFilter"
                                    [PendingSuggestionsOnly]="PendingSuggestionsOnly"
                                    (PendingSuggestionsOnlyChange)="onPendingSuggestionsOnlyChange($event)"
                                    [ShowCreateButton]="ShowCreateButton"
                                    [ShowQuickAdd]="ShowQuickAdd"
                                    [QuickAddDefaultTypeID]="DefaultTypeID"
                                    [AssigneeScope]="AssigneeScope"
                                    [Compact]="Compact"
                                    [ReadOnly]="ReadOnly"
                                    [RowBadgeResolver]="listRowBadgeResolver"
                                    [RowBadgesTemplate]="EffectiveRowBadgesTemplate"
                                    (BeforeTaskSelected)="onBeforeTaskSelected($event)"
                                    (AfterTaskSelected)="onAfterTaskSelected($event)"
                                    (BeforeStatusChange)="BeforeStatusChange.emit($event)"
                                    (AfterStatusChange)="AfterStatusChange.emit($event)"
                                    (AfterTaskCreated)="onAfterTaskCreated($event)"
                                    (TaskDoubleClicked)="onOpenFullRecord($event.ID)"
                                    (CreateTask)="onCreateTask()">
                                </bizapps-task-list>
                            </div>
                        }
                        @case ('kanban') {
                            <div class="task-panel-kanban">
                                <bizapps-task-kanban
                                    #taskKanban
                                    [Provider]="Provider"
                                    [Tasks]="EffectiveFlatTasks"
                                    [CategoryID]="CategoryID"
                                    [ExtraFilter]="ExtraFilter"
                                    [PendingSuggestionsOnly]="PendingSuggestionsOnly"
                                    [ReadOnly]="ReadOnly"
                                    [CardBadgeResolver]="kanbanCardBadgeResolver"
                                    [CardBadgesTemplate]="EffectiveCardBadgesTemplate"
                                    (TaskClicked)="onTaskClicked($event)"
                                    (TaskDoubleClicked)="onOpenFullRecord($event)"
                                    (BeforeStatusChange)="onKanbanBeforeStatusChange($event)"
                                    (AfterStatusChange)="onKanbanStatusChange($event)">
                                </bizapps-task-kanban>
                            </div>
                        }
                        @case ('gantt') {
                            <div class="task-panel-gantt">
                                <bizapps-task-gantt
                                    #taskGantt
                                    [Provider]="Provider"
                                    [Tasks]="EffectiveFlatTasks"
                                    [Dependencies]="Dependencies"
                                    [CategoryID]="CategoryID"
                                    [ExtraFilter]="ExtraFilter"
                                    [Height]="GanttHeight"
                                    [ReadOnly]="ReadOnly"
                                    (TaskClicked)="onTaskClicked($event)"
                                    (TaskDoubleClicked)="onOpenFullRecord($event)">
                                </bizapps-task-gantt>
                            </div>
                        }
                    }
                </div>

                @if (HasSidePanel) {
                    <aside class="task-panel-side" aria-label="Companion panel">
                        <ng-content select="[side-panel]"></ng-content>
                    </aside>
                }
            </div>

            <bizapps-task-drawer-shell
                [Visible]="panelMode !== 'none'"
                [Title]="DrawerTitle"
                (Closed)="closePanel()">
                @if (panelMode === 'detail' && selectedTaskID) {
                    <bizapps-task-detail-panel
                        #detailPanel
                        [Provider]="Provider"
                        [TaskID]="selectedTaskID"
                        [PersonID]="PersonID"
                        [ShowDelete]="ShowDelete"
                        [ShowOpenForm]="ShowOpenForm"
                        [ShowTimeEffort]="ShowTimeEffort"
                        [ReadOnly]="ReadOnly"
                        [DetailTopExtensionTemplate]="EffectiveDetailTopExtensionTemplate"
                        (EditRequested)="onEditRequested($event)"
                        (OpenRecordRequested)="onOpenFullRecord($event)"
                        (DeleteRequested)="onDeleteRequested($event)"
                        (TaskMutated)="onDetailTaskMutated($event)"
                        (BeforeCommentPosted)="BeforeCommentPosted.emit($event)"
                        (AfterCommentPosted)="AfterCommentPosted.emit()"
                        (Close)="closePanel()">
                    </bizapps-task-detail-panel>
                }
                @if (panelMode === 'edit') {
                    <bizapps-task-edit-panel
                        #editPanel
                        [TaskID]="selectedTaskID"
                        [DefaultCategoryID]="CategoryID"
                        [DefaultTypeID]="DefaultTypeID"
                        [AssigneeScope]="AssigneeScope"
                        [ParentTaskFilter]="ParentTaskFilter"
                        [ReadOnly]="ReadOnly"
                        (BeforeSave)="BeforeTaskSave.emit($event)"
                        (Saved)="onTaskSaved($event)"
                        (Cancel)="closePanel()">
                    </bizapps-task-edit-panel>
                }
            </bizapps-task-drawer-shell>
        </div>
    `,
    styles: [`
        :host { display: block; position: relative; width: 100%; min-width: 0; }
        .task-panel-host { position: relative; display: flex; flex-direction: column; gap: 10px; width: 100%; min-width: 0; }
        .task-panel-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            flex-wrap: wrap;
            padding: 8px 12px;
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface);
        }
        .task-panel-toolbar-left {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            min-width: 0;
        }
        .task-panel-workspace {
            display: block;
            width: 100%;
            min-width: 0;
        }
        .task-panel-workspace.has-side-panel {
            display: grid;
            grid-template-columns: minmax(0, 1.55fr) minmax(300px, 1fr);
            gap: 14px;
            align-items: start;
        }
        .task-panel-body {
            position: relative;
            flex: 1 1 auto;
            min-width: 0;
            min-height: 0;
            width: 100%;
        }
        .task-panel-side {
            min-width: 0;
        }
        .task-panel-wbs,
        .task-panel-list { position: relative; z-index: 1; }
        .task-panel-kanban, .task-panel-gantt {
            width: 100%;
            min-height: 450px;
        }
        @media (max-width: 1024px) {
            .task-panel-workspace.has-side-panel {
                grid-template-columns: minmax(0, 1fr);
            }
        }
    `],
})
export class TaskPanelComponent implements OnInit {
    // ── Inputs ──────────────────────────────────────────────

    /** Optional metadata/data provider forwarded to child components. */
    @Input() Provider: IMetadataProvider | null = null;

    /** Controlled flat tasks list. When non-null, child views render directly with zero internal RunView calls. */
    @Input() Tasks: readonly TaskWidgetItem[] | null = null;

    /** Controlled multi-group portfolio sections for WBS mode (flattened automatically for List, Kanban, Gantt). */
    @Input() Groups: readonly TaskWbsGroup[] | null = null;

    /** Optional hub-level tasks merged when flattening `[Groups]` for List, Kanban, and Gantt modes. */
    @Input() HubTasks: readonly TaskWidgetItem[] | null = null;

    /** Controlled task dependencies forwarded to `<bizapps-task-gantt>`. */
    @Input() Dependencies: readonly TaskGanttDependencyInput[] | null = null;

    /** UserInfoEngine preference key for persisting the active view mode. Set to null to disable. */
    @Input() PreferenceKey: string | null = 'BizAppsTasks.WorkPanel.ViewMode';

    /** When false, disables reading/writing the preferred view mode in UserInfoEngine. */
    @Input() PersistViewMode = true;

    /** Enables the responsive 2-column grid for projected `[side-panel]` content. */
    @Input() HasSidePanel = false;

    /** Forces rendering the toolbar bar even when only 1 view mode is allowed (for `[toolbar-actions]`). */
    @Input() ShowToolbarActions = false;

    /** Controls visibility of Explorer's "Open Form" button in the detail drawer. */
    @Input() ShowOpenForm = true;

    /** Controls visibility of the Time & Effort section in the detail drawer. */
    @Input() ShowTimeEffort = true;

    /** WBS tree display options. */
    @Input() ShowWbsCodes = true;
    @Input() ShowTreeConnectors = true;
    @Input() ShowProgressBars = true;
    @Input() ShowWbsToolbar = true;
    @Input() EmptyTitle = 'No tasks match your filter';
    @Input() EmptyMessage = 'Clear filters or add a task to get started.';

    /** Custom filter chips forwarded to `<mjt-wbs-tree>`. */
    @Input() CustomFilters: readonly TaskWbsFilterDef[] = [];

    /** Declarative row badge resolver forwarded across WBS, List, and (as fallback) Kanban cards. */
    @Input() RowBadgeResolver: ((task: TaskWidgetItem) => readonly TaskBadgeDescriptor[]) | null = null;

    /** Optional Kanban-specific card badge resolver (falls back to `RowBadgeResolver` when null). */
    @Input() CardBadgeResolver: ((taskId: string) => readonly TaskBadgeDescriptor[]) | null = null;

    /** Declarative row highlight tone resolver forwarded to `<mjt-wbs-tree>`. */
    @Input() RowToneResolver: ((task: TaskWidgetItem) => TaskWbsRowTone) | null = null;

    /** Optional programmatically forwarded templates for nested wrappers (e.g. Collaboration). */
    @Input() TaskRowBadgesTemplate: TemplateRef<TaskWbsRowTemplateContext> | null = null;
    @Input() TaskRowMetaTemplate: TemplateRef<TaskWbsRowTemplateContext> | null = null;
    @Input() TaskCardBadgesTemplate: TemplateRef<KanbanCardBadgeContext> | null = null;
    @Input() GroupHeaderMetaTemplate: TemplateRef<TaskWbsGroupTemplateContext> | null = null;
    @Input() GroupHeaderActionsTemplate: TemplateRef<TaskWbsGroupTemplateContext> | null = null;
    @Input() GroupFooterTemplate: TemplateRef<TaskWbsGroupTemplateContext> | null = null;
    @Input() DetailTopExtensionTemplate: TemplateRef<TaskDetailTopExtensionContext> | null = null;

    @ContentChild('taskRowBadges') public contentTaskRowBadges?: TemplateRef<TaskWbsRowTemplateContext>;
    @ContentChild('taskRowMeta') public contentTaskRowMeta?: TemplateRef<TaskWbsRowTemplateContext>;
    @ContentChild('taskCardBadges') public contentTaskCardBadges?: TemplateRef<KanbanCardBadgeContext>;
    @ContentChild('groupHeaderMeta') public contentGroupHeaderMeta?: TemplateRef<TaskWbsGroupTemplateContext>;
    @ContentChild('groupHeaderActions') public contentGroupHeaderActions?: TemplateRef<TaskWbsGroupTemplateContext>;
    @ContentChild('groupFooter') public contentGroupFooter?: TemplateRef<TaskWbsGroupTemplateContext>;
    @ContentChild('detailTopExtension') public contentDetailTopExtension?: TemplateRef<TaskDetailTopExtensionContext>;

    private _pendingSuggestionsOnly = false;

    /** When true, filters inner list/kanban views to tasks with pending Field Suggestions. */
    @Input()
    public get PendingSuggestionsOnly(): boolean {
        return this._pendingSuggestionsOnly;
    }
    public set PendingSuggestionsOnly(value: boolean) {
        const next = Boolean(value);
        if (next !== this._pendingSuggestionsOnly) {
            this._pendingSuggestionsOnly = next;
            this.cdr.markForCheck();
        }
    }

    @Output() PendingSuggestionsOnlyChange = new EventEmitter<boolean>();

    /** @internal */
    onPendingSuggestionsOnlyChange(next: boolean): void {
        this._pendingSuggestionsOnly = Boolean(next);
        this.PendingSuggestionsOnlyChange.emit(this._pendingSuggestionsOnly);
        this.cdr.markForCheck();
    }

    /** Filter tasks to a specific category. */
    @Input() CategoryID: string | null = null;

    /** Additional SQL WHERE clause filter. */
    @Input() ExtraFilter: string | null = null;

    /** Pre-select a status filter on the list. */
    @Input() StatusFilter: string | null = null;

    /** Whether to show the "+ New Task" button. */
    @Input() ShowCreateButton = false;

    /** Whether to show the delete button in the detail panel. */
    @Input() ShowDelete = false;

    /** Compact mode for the list. */
    @Input() Compact = false;

    /** Whether to show the quick-add inline input at the bottom of the list. */
    @Input() ShowQuickAdd = false;

    /** PersonID of the current user. */
    @Input() PersonID: string | null = null;

    /** Default task type for new tasks. */
    @Input() DefaultTypeID: string | null = null;

    /** Narrows the assignee picker in the edit panel. */
    @Input() AssigneeScope: string | string[] | null = null;

    /** Extra SQL filter for the edit panel's Parent Task list. */
    @Input() ParentTaskFilter: string | null = null;

    /** Hides Edit, comment box, list bulk actions, completion ring mutations, and edit save. */
    @Input() ReadOnly = false;

    private _allowedViewModes: TaskViewMode[] = ['list'];
    private _viewMode: TaskViewMode = 'list';

    /**
     * Allowed view modes. If more than 1 mode is provided, a view-mode toggle toolbar is rendered.
     * @default ['list']
     */
    @Input()
    public get AllowedViewModes(): TaskViewMode[] {
        return this._allowedViewModes;
    }
    public set AllowedViewModes(modes: TaskViewMode[]) {
        this._allowedViewModes = Array.isArray(modes) && modes.length > 0 ? modes : ['list'];
        this.ensureValidViewMode();
    }

    /**
     * The active view mode ('wbs' | 'list' | 'kanban' | 'gantt').
     * Defaults to the first allowed view mode if the requested mode is not in AllowedViewModes.
     * @default 'list'
     */
    @Input()
    public get ViewMode(): TaskViewMode {
        return this._viewMode;
    }
    public set ViewMode(mode: TaskViewMode) {
        this._viewMode = mode;
        this.ensureValidViewMode();
    }

    private ensureValidViewMode(): void {
        if (this._allowedViewModes.length > 0 && !this._allowedViewModes.includes(this._viewMode)) {
            this._viewMode = this._allowedViewModes[0];
        }
    }

    /** @internal */
    public get viewToggleOptions(): ViewToggleOption[] {
        return this.AllowedViewModes
            .filter((m): m is TaskViewMode => ALL_VIEW_OPTIONS[m] != null)
            .map((m) => ALL_VIEW_OPTIONS[m]);
    }

    /** Height for the Gantt chart when in 'gantt' view mode. */
    @Input() GanttHeight = '600px';

    /** Emitted when the user toggles the view mode. */
    @Output() ViewModeChange = new EventEmitter<TaskViewMode>();

    // ── Outputs (Before — cancellable) ──────────────────────

    @Output() BeforePanelOpen = new EventEmitter<BeforePanelOpenEvent>();
    @Output() BeforePanelClose = new EventEmitter<BeforePanelCloseEvent>();
    @Output() BeforeTaskSelected = new EventEmitter<BeforeTaskSelectedEvent>();
    @Output() BeforeStatusChange = new EventEmitter<BeforeStatusChangeEvent>();
    @Output() BeforeKanbanStatusChange = new EventEmitter<BeforeKanbanStatusChangeEvent>();
    @Output() AfterKanbanStatusChange = new EventEmitter<AfterKanbanStatusChangeEvent>();
    @Output() BeforeCommentPosted = new EventEmitter<BeforeCommentPostedEvent>();
    @Output() BeforeTaskSave = new EventEmitter<BeforeTaskSaveEvent>();

    // ── Outputs (After — informational) ─────────────────────

    @Output() AfterTaskSelected = new EventEmitter<TaskRow>();
    @Output() AfterStatusChange = new EventEmitter<TaskRow>();
    @Output() AfterCommentPosted = new EventEmitter<void>();
    @Output() AfterTaskSaved = new EventEmitter<string>();
    @Output() AfterTaskCreated = new EventEmitter<string>();
    @Output() AfterPanelClosed = new EventEmitter<void>();
    @Output() TaskDoubleClicked = new EventEmitter<string>();
    @Output() OpenRecordRequested = new EventEmitter<string>();
    @Output() TaskSelected = new EventEmitter<string>();
    @Output() WbsStatusToggled = new EventEmitter<{ TaskID: string; NewStatus: TaskStatusValue }>();

    // ── View References ─────────────────────────────────────

    /** @internal */
    @ViewChild('taskWbs') taskWbs?: TaskWbsTreeComponent;
    /** @internal */
    @ViewChild('taskList') taskList?: TaskListComponent;
    /** @internal */
    @ViewChild('taskKanban') taskKanban?: TaskKanbanComponent;
    /** @internal */
    @ViewChild('taskGantt') taskGantt?: TaskGanttComponent;
    /** @internal */
    @ViewChild('detailPanel') detailPanel?: TaskDetailPanelComponent;
    /** @internal */
    @ViewChild('editPanel') editPanel?: TaskEditPanelComponent;

    // ── Internal State ──────────────────────────────────────

    /** @internal */
    panelMode: TaskPanelMode = 'none';
    /** @internal */
    selectedTaskID: string | null = null;

    private cdr = inject(ChangeDetectorRef);

    public get ProviderToUse(): IMetadataProvider {
        return this.Provider ?? Metadata.Provider;
    }

    public get DrawerTitle(): string {
        if (this.panelMode === 'edit') {
            return this.selectedTaskID ? 'Edit Task' : 'New Task';
        }
        return 'Task Details';
    }

    /**
     * Effective flat task list for List, Kanban, and Gantt modes.
     * - Returns `Tasks` directly when supplied.
     * - When `Groups` is supplied (and `Tasks` is null), flattens `HubTasks` + all `Groups[].Tasks` deduped by ID.
     * - Returns `null` when neither is supplied (enabling self-fetching mode in List/Kanban/Gantt).
     */
    public get EffectiveFlatTasks(): readonly TaskWidgetItem[] | null {
        if (this.Tasks !== null) {
            return this.Tasks;
        }
        if (this.Groups !== null) {
            const seen = new Set<string>();
            const merged: TaskWidgetItem[] = [];
            const pushAll = (items: readonly TaskWidgetItem[] | null | undefined): void => {
                if (!items) return;
                for (const item of items) {
                    const key = item.ID.toLowerCase();
                    if (!seen.has(key)) {
                        seen.add(key);
                        merged.push(item);
                    }
                }
            };
            pushAll(this.HubTasks);
            for (const g of this.Groups) {
                pushAll(g.Tasks);
            }
            return merged;
        }
        return null;
    }

    /** Tasks passed to `<mjt-wbs-tree>` when not using `[Groups]`. */
    public get EffectiveWbsTasks(): readonly TaskWidgetItem[] {
        return this.Tasks ?? this.HubTasks ?? [];
    }

    public get EffectiveRowBadgesTemplate(): TemplateRef<TaskWbsRowTemplateContext> | null {
        return this.contentTaskRowBadges ?? this.TaskRowBadgesTemplate ?? null;
    }

    public get EffectiveRowMetaTemplate(): TemplateRef<TaskWbsRowTemplateContext> | null {
        return this.contentTaskRowMeta ?? this.TaskRowMetaTemplate ?? null;
    }

    public get EffectiveCardBadgesTemplate(): TemplateRef<KanbanCardBadgeContext> | null {
        return this.contentTaskCardBadges ?? this.TaskCardBadgesTemplate ?? null;
    }

    public get EffectiveGroupHeaderMetaTemplate(): TemplateRef<TaskWbsGroupTemplateContext> | null {
        return this.contentGroupHeaderMeta ?? this.GroupHeaderMetaTemplate ?? null;
    }

    public get EffectiveGroupHeaderActionsTemplate(): TemplateRef<TaskWbsGroupTemplateContext> | null {
        return this.contentGroupHeaderActions ?? this.GroupHeaderActionsTemplate ?? null;
    }

    public get EffectiveGroupFooterTemplate(): TemplateRef<TaskWbsGroupTemplateContext> | null {
        return this.contentGroupFooter ?? this.GroupFooterTemplate ?? null;
    }

    public get EffectiveDetailTopExtensionTemplate(): TemplateRef<TaskDetailTopExtensionContext> | null {
        return this.contentDetailTopExtension ?? this.DetailTopExtensionTemplate ?? null;
    }

    /** @internal Adapter so a single `RowBadgeResolver(task: TaskWidgetItem)` works across WBS and List. */
    public readonly listRowBadgeResolver = (row: TaskRow): readonly TaskBadgeDescriptor[] => {
        if (!this.RowBadgeResolver) return [];
        const match = this.findControlledTask(row.ID);
        if (match) {
            return this.RowBadgeResolver(match);
        }
        return this.RowBadgeResolver(this.taskRowToWidgetItem(row));
    };

    /** @internal Adapter so `CardBadgeResolver` (or fallback `RowBadgeResolver`) works on Kanban cards. */
    public readonly kanbanCardBadgeResolver = (taskId: string): readonly TaskBadgeDescriptor[] => {
        if (this.CardBadgeResolver) {
            return this.CardBadgeResolver(taskId);
        }
        if (this.RowBadgeResolver) {
            const match = this.findControlledTask(taskId);
            if (match) {
                return this.RowBadgeResolver(match);
            }
        }
        return [];
    };

    private findControlledTask(taskId: string): TaskWidgetItem | undefined {
        const list = this.EffectiveFlatTasks;
        if (!list) return undefined;
        const target = taskId.toLowerCase();
        return list.find((t) => t.ID.toLowerCase() === target);
    }

    private taskRowToWidgetItem(row: TaskRow): TaskWidgetItem {
        const status: TaskStatusValue =
            row.Status === 'Open' ||
            row.Status === 'InProgress' ||
            row.Status === 'Blocked' ||
            row.Status === 'Completed' ||
            row.Status === 'Cancelled'
                ? row.Status
                : 'Open';
        return {
            ID: row.ID,
            Name: row.Name,
            Description: row.Description,
            ParentID: row.ParentID,
            Status: status,
            DueAt: row.DueAt,
            PercentComplete: row.PercentComplete,
            HoursEstimated: row.HoursEstimated,
            OrganizationID: row.OrganizationID ?? null,
            OrganizationName: row.OrganizationName ?? null,
            TaskTypeStatusName: row.TaskTypeStatusName ?? null,
        };
    }

    // ── Lifecycle ───────────────────────────────────────────

    public ngOnInit(): void {
        if (this.PersistViewMode && this.PreferenceKey) {
            try {
                const saved = UserInfoEngine.Instance.GetSetting(this.PreferenceKey);
                if (saved && VALID_VIEW_MODES.has(saved as TaskViewMode)) {
                    const savedMode = saved as TaskViewMode;
                    if (this._allowedViewModes.includes(savedMode)) {
                        this._viewMode = savedMode;
                    }
                }
            } catch {
                // UserInfoEngine may not be initialized in isolated unit tests
            }
        }
        this.ensureValidViewMode();
    }

    // ── Public Methods ──────────────────────────────────────

    /** Refreshes the active task views from the server (or re-applies controlled inputs). */
    Refresh(): void {
        this.taskList?.Refresh();
        this.taskKanban?.Refresh();
        this.taskGantt?.Refresh();
    }

    /** Programmatically opens the detail drawer for a task. Emits `BeforePanelOpen` (cancellable). */
    OpenDetail(taskID: string): void {
        this.tryOpenPanel('detail', taskID);
    }

    /** Programmatically closes the detail/edit drawer. Alias for {@link Close}. */
    CloseDetail(): void {
        this.closePanel();
    }

    /** Programmatically opens the edit drawer (`null` for new task). Emits `BeforePanelOpen` (cancellable). */
    OpenEdit(taskID: string | null): void {
        this.tryOpenPanel('edit', taskID);
    }

    /** Programmatically closes the drawer. Emits `BeforePanelClose` (cancellable). */
    Close(): void {
        this.closePanel();
    }

    /** Switch view mode, persist in `UserInfoEngine`, and emit `ViewModeChange`. */
    SetViewMode(mode: TaskViewMode): void {
        if (!this._allowedViewModes.includes(mode)) return;
        this._viewMode = mode;
        if (this.PersistViewMode && this.PreferenceKey) {
            try {
                UserInfoEngine.Instance.SetSettingDebounced(this.PreferenceKey, mode);
            } catch {
                // Safe fallback when UserInfoEngine isn't initialized
            }
        }
        this.ViewModeChange.emit(mode);
        this.cdr.markForCheck();
    }

    /** @internal */
    onViewToggleChange(key: string): void {
        if (VALID_VIEW_MODES.has(key as TaskViewMode)) {
            this.SetViewMode(key as TaskViewMode);
        }
    }

    // ── Internal Event Handlers ─────────────────────────────

    /** @internal */
    onWbsTaskClicked(task: TaskWidgetItem): void {
        this.onTaskClicked(task.ID);
    }

    /** @internal */
    async onWbsStatusToggled(event: { TaskID: string; NewStatus: TaskStatusValue }): Promise<void> {
        this.WbsStatusToggled.emit(event);
        const match = this.findControlledTask(event.TaskID);
        const dueRaw = match?.DueAt ?? match?.DueDate ?? null;
        const dueAt = dueRaw ? (dueRaw instanceof Date ? dueRaw : new Date(dueRaw)) : null;
        const { isOverdue, isDueSoon } = computeDueStatus(dueAt, match?.Status ?? 'Open');
        const row: TaskRow = {
            ID: event.TaskID,
            Name: match?.Name ?? '',
            Description: match?.Description ?? null,
            Status: match?.Status ?? 'Open',
            Priority: match?.Priority ?? 'Medium',
            DueAt: dueAt,
            PercentComplete: match?.PercentComplete ?? 0,
            HoursEstimated: match?.HoursEstimated ?? null,
            ParentID: match?.ParentID ?? null,
            Depth: 0,
            IsOverdue: isOverdue,
            IsDueSoon: isDueSoon,
        };

        const before = new BeforeStatusChangeEvent(row, event.NewStatus);
        this.BeforeStatusChange.emit(before);
        if (before.Cancel) return;

        const provider = this.ProviderToUse;
        if (typeof provider?.GetEntityObject !== 'function') return;

        const entity = await provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
        await entity.InnerLoad(CompositeKey.FromID(event.TaskID));
        entity.Status = event.NewStatus;
        entity.PercentComplete = event.NewStatus === 'Completed' ? 100 : 0;
        if (await entity.Save()) {
            row.Status = event.NewStatus;
            row.PercentComplete = entity.PercentComplete;
            this.AfterStatusChange.emit(row);
            this.Refresh();
        }
    }

    /** @internal */
    onBeforeTaskSelected(event: BeforeTaskSelectedEvent): void {
        this.BeforeTaskSelected.emit(event);
    }

    /** @internal */
    onAfterTaskSelected(task: TaskRow): void {
        this.TaskSelected.emit(task.ID);
        this.AfterTaskSelected.emit(task);
        this.tryOpenPanel('detail', task.ID);
    }

    /** @internal */
    onTaskClicked(taskID: string): void {
        this.TaskSelected.emit(taskID);
        this.tryOpenPanel('detail', taskID);
    }

    /** @internal */
    onKanbanBeforeStatusChange(event: BeforeKanbanStatusChangeEvent): void {
        this.BeforeKanbanStatusChange.emit(event);
        if (event.Cancel) return;

        const data = event.Card?.Data as KanbanTaskData | undefined;
        const dueAt = data?.DueAt ? new Date(data.DueAt) : null;
        const { isOverdue, isDueSoon } = computeDueStatus(dueAt, event.OldStatus);

        const row: TaskRow = {
            ID: event.TaskID,
            Name: data?.Name ?? event.Card?.Title ?? '',
            Description: data?.Description ?? (event.Card?.Subtitle || null),
            Status: event.OldStatus,
            Priority: data?.Priority ?? event.Card?.BadgeText ?? 'Medium',
            DueAt: dueAt,
            PercentComplete: data?.PercentComplete ?? (event.OldStatus === 'Completed' ? 100 : 0),
            HoursEstimated: data?.HoursEstimated ?? null,
            ParentID: data?.ParentID ?? null,
            Depth: 0,
            Assignees: undefined,
            Tags: undefined,
            ChildCount: undefined,
            IsOverdue: isOverdue,
            IsDueSoon: isDueSoon,
        };
        const before = new BeforeStatusChangeEvent(row, event.NewStatus, ['Assignees', 'Tags', 'Subtasks']);
        this.BeforeStatusChange.emit(before);
        if (before.Cancel) {
            event.Cancel = true;
        }
    }

    /** @internal */
    onKanbanStatusChange(event: AfterKanbanStatusChangeEvent): void {
        this.AfterKanbanStatusChange.emit(event);
        const data = event.Card?.Data as KanbanTaskData | undefined;
        const dueAt = data?.DueAt ? new Date(data.DueAt) : null;
        const { isOverdue, isDueSoon } = computeDueStatus(dueAt, event.NewStatus);

        const row: TaskRow = {
            ID: event.TaskID,
            Name: data?.Name ?? event.Card?.Title ?? '',
            Description: data?.Description ?? (event.Card?.Subtitle || null),
            Status: event.NewStatus,
            Priority: data?.Priority ?? event.Card?.BadgeText ?? 'Medium',
            DueAt: dueAt,
            PercentComplete: event.NewStatus === 'Completed' ? 100 : (data?.PercentComplete ?? 0),
            HoursEstimated: data?.HoursEstimated ?? null,
            ParentID: data?.ParentID ?? null,
            Depth: 0,
            Assignees: undefined,
            Tags: undefined,
            ChildCount: undefined,
            IsOverdue: isOverdue,
            IsDueSoon: isDueSoon,
        };
        this.AfterStatusChange.emit(row);
    }

    /** @internal */
    onAfterTaskCreated(taskID: string): void {
        this.AfterTaskCreated.emit(taskID);
        this.taskKanban?.Refresh();
        this.taskGantt?.Refresh();
    }

    /** @internal */
    onCreateTask(): void {
        this.tryOpenPanel('edit', null);
    }

    /** @internal */
    onEditRequested(taskID: string): void {
        this.tryOpenPanel('edit', taskID);
    }

    /** @internal */
    onDetailTaskMutated(taskID: string): void {
        this.AfterTaskSaved.emit(taskID);
        this.Refresh();
    }

    /** @internal Handles delete from the detail panel — closes panel and refreshes views. */
    async onDeleteRequested(_taskID: string): Promise<void> {
        this.panelMode = 'none';
        this.selectedTaskID = null;
        this.cdr.markForCheck();
        await this.taskList?.Refresh();
        this.taskKanban?.Refresh();
        this.taskGantt?.Refresh();
        this.cdr.markForCheck();
    }

    /** @internal */
    onTaskSaved(taskID: string): void {
        this.AfterTaskSaved.emit(taskID);
        this.panelMode = 'none';
        this.selectedTaskID = null;
        this.AfterPanelClosed.emit();
        this.taskList?.Refresh();
        this.taskKanban?.Refresh();
        this.taskGantt?.Refresh();
        this.cdr.markForCheck();
    }

    /** @internal */
    closePanel(): void {
        if (this.panelMode === 'none') return;
        const before = new BeforePanelCloseEvent();
        this.BeforePanelClose.emit(before);
        if (before.Cancel) return;

        this.panelMode = 'none';
        this.selectedTaskID = null;
        this.AfterPanelClosed.emit();
        this.cdr.markForCheck();
    }

    /** @internal */
    private tryOpenPanel(mode: TaskPanelMode, taskID: string | null): void {
        const before = new BeforePanelOpenEvent(mode, taskID);
        this.BeforePanelOpen.emit(before);
        if (before.Cancel) return;

        this.panelMode = mode;
        this.selectedTaskID = taskID;
        this.cdr.markForCheck();
    }

    /** @internal */
    onOpenFullRecord(taskID: string | null): void {
        if (!taskID) return;
        this.TaskDoubleClicked.emit(taskID);
        this.OpenRecordRequested.emit(taskID);
        if (this.ShowOpenForm) {
            OpenTaskRecord(taskID);
        }
    }
}
