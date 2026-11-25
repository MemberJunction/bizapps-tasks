import {
    AfterViewInit,
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    ElementRef,
    EventEmitter,
    Input,
    OnChanges,
    OnDestroy,
    OnInit,
    Output,
    SimpleChanges,
    ViewChild,
    inject,
} from '@angular/core';
import { CompositeKey, Metadata, RunView, type IMetadataProvider, type IRunViewProvider } from '@memberjunction/core';
import { EscapeSQLString, UUIDsEqual } from '@memberjunction/global';
import { UserInfoEngine } from '@memberjunction/core-entities';
import {
    AfterColumnResizeEventArgs,
    AfterGridResizeEventArgs,
    AfterZoomChangeEventArgs,
    BeforeZoomChangeEventArgs,
    GanttColumnDef,
    GanttItemClickedEvent,
    GanttItemData,
    GanttLinkData,
    GanttZoomLevelName,
    GanttZoomPercent,
    MjGanttChartComponent,
} from '@memberjunction/ng-gantt';
import {
    MJButtonDirective,
    MJEmptyStateComponent,
} from '@memberjunction/ng-ui-components';
import { IsPhoneViewport, WatchPhoneViewport } from '../../phone-viewport';
import {
    ComputeCriticalPathTaskIds,
    MatchesAssigneeFilter,
    MatchesDueDateFilter,
    type TaskAssigneeFilterRef,
    type TaskDependencyEdge,
    type TaskDueDateFilterKey,
} from '@mj-biz-apps/tasks-core';
import type { mjBizAppsTasksTaskDependencyEntity, mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import {
    TaskMobileMilestoneStackComponent,
    type TaskPriorityValue,
    type TaskStatusValue,
    type TaskWidgetItem,
} from '@mj-biz-apps/tasks-ng-widgets';
import { CurrentUserRoleIDs, RoleAssigneeName } from '../../role-assignees';
import {
    DefaultTasksGanttPref,
    ParseTasksGanttPref,
    SerializeTasksGanttPref,
    TASKS_GANTT_DEFAULT_ZOOM,
    TASKS_GANTT_PREF_SETTING,
    TASKS_GANTT_ZOOM_SETTING,
    type TasksGanttPref,
} from './gantt-zoom-pref';
import type { TaskClickRow } from '../task-kanban/task-kanban.component';

const TASK_ID_RE = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/;

/** Controlled dependency edge accepted by `<bizapps-task-gantt [Dependencies]>`. */
export interface TaskGanttDependencyInput {
    ID?: string;
    TaskID: string;
    DependsOnTaskID: string;
    DependencyType?: mjBizAppsTasksTaskDependencyEntity['DependencyType'];
}

interface GanttTaskRow {
    ID: string;
    Name: string;
    Description: string | null;
    StartedAt: string | null;
    DueAt: string | null;
    PercentComplete: number;
    HoursEstimated: number | null;
    ParentID: string | null;
    Status: TaskStatusValue;
    Priority: TaskPriorityValue;
    TaskTypeStatus: string | null;
    OrganizationID: string | null;
    Organization: string | null;
    Sequence: number;
}

function escapeGanttHtml(raw: string): string {
    return raw
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

/**
 * Critical-Path Split Gantt + Mobile Milestone Stack wrapping MJ's `<mj-gantt-chart>`.
 *
 * - Desktop & tablet (`> 768px`): full DHTMLX split-pane Gantt with zoom/grid/column-width
 *   persistence in `UserInfoEngine`, hollow-slate vs solid-blue WCAG 1.4.1 legend & bar tinting,
 *   outside labels on short 1–3 day bars, multi-select checkboxes feeding `<mjt-bulk-action-dock>`,
 *   and Critical Path DAG highlighting.
 * - Mobile (`<= 768px`, `IsPhoneViewport()`): automatically swaps to `<mjt-mobile-milestone-stack>`
 *   so phones get chronological touch milestone cards with zero horizontal overflow.
 */
@Component({
    selector: 'bizapps-task-gantt',
    standalone: true,
    imports: [
        MjGanttChartComponent,
        MJButtonDirective,
        MJEmptyStateComponent,
        TaskMobileMilestoneStackComponent,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
    host: {
        '[style.height]': 'IsPhone ? "auto" : Height',
        '[style.display]': '"flex"',
        '[style.flexDirection]': '"column"',
        '[style.width]': '"100%"',
    },
    template: `
        <div
            class="mjt-gantt-wrap"
            [style.height]="IsPhone ? 'auto' : Height"
            (click)="onGanttWrapClick($event)">
            @if (ShowToolbar) {
                <div class="mjt-gantt-toolbar">
                    <div class="mjt-gantt-legend">
                        <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--open" aria-hidden="true"></span> Open</span>
                        <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--prog" aria-hidden="true"></span> In Progress</span>
                        <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--done" aria-hidden="true"></span> Completed</span>
                        <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--blocked" aria-hidden="true"></span> Blocked</span>
                        @if (EnableBulkSelect && !IsPhone && items.length > 0) {
                            <label class="mjt-gantt-select-all">
                                <input
                                    type="checkbox"
                                    [checked]="AllVisibleSelected"
                                    [indeterminate]="SelectedIDs.length > 0 && !AllVisibleSelected"
                                    (change)="ToggleSelectAllVisible()" />
                                <span>{{ SelectedIDs.length > 0 ? SelectedIDs.length + ' selected' : 'Select rows' }}</span>
                            </label>
                        }
                    </div>

                    <div class="mjt-gantt-right">
                        @if (CriticalPathIds.size > 0) {
                            <button
                                type="button"
                                mjButton
                                [variant]="HighlightCriticalPath ? 'danger' : 'outline'"
                                size="sm"
                                (click)="ToggleCriticalPath()">
                                <i class="fa-solid fa-route" aria-hidden="true"></i>
                                <span>Critical Path ({{ CriticalPathIds.size }})</span>
                            </button>
                        }

                        @if (!IsPhone) {
                            <div class="mjt-gantt-zoom" role="group" aria-label="Gantt zoom">
                                <button
                                    type="button"
                                    class="mjt-gantt-zoom__btn"
                                    (click)="ZoomOut()"
                                    [disabled]="!CanZoomOut"
                                    title="Zoom out (Ctrl + scroll)">−</button>
                                <span class="mjt-gantt-zoom__label">{{ ZoomPercent }}%</span>
                                <button
                                    type="button"
                                    class="mjt-gantt-zoom__btn"
                                    (click)="ZoomIn()"
                                    [disabled]="!CanZoomIn"
                                    title="Zoom in (Ctrl + scroll)">+</button>
                            </div>
                        }
                    </div>
                </div>
            }

            @if (IsPhone) {
                <mjt-mobile-milestone-stack
                    [Tasks]="milestoneTasks"
                    [HighlightCriticalPath]="HighlightCriticalPath"
                    [ReadOnly]="ReadOnly"
                    (TaskClicked)="onMobileTaskClick($event)"
                    (StatusToggled)="onMobileStatusToggle($event)">
                </mjt-mobile-milestone-stack>
            } @else if (items.length === 0 && !loading) {
                <mj-empty-state
                    Icon="fa-solid fa-chart-gantt"
                    Title="No scheduled tasks"
                    Message="Add start or due dates to tasks to plot them on the timeline."
                    Size="compact">
                </mj-empty-state>
            } @else {
                <mj-gantt-chart
                    #chart
                    [Items]="items"
                    [Links]="links"
                    [Columns]="EffectiveColumns"
                    [Height]="Height"
                    [ReadOnly]="ReadOnly"
                    [ShowProgress]="true"
                    [EnableZoom]="true"
                    [EnableGridScroll]="true"
                    [EnableGridResize]="true"
                    [EnableColumnResize]="true"
                    [ZoomLevel]="ZoomLevel"
                    [GridWidth]="EffectiveGridWidth"
                    [ColumnWidths]="Pref.columnWidths"
                    (ItemClicked)="onItemClicked($event)"
                    (ItemDoubleClicked)="onItemDoubleClicked($event)"
                    (BeforeZoomChange)="OnBeforeZoomChange($event)"
                    (AfterZoomChange)="OnAfterZoomChange($event)"
                    (AfterGridResize)="OnAfterGridResize($event)"
                    (AfterColumnResize)="OnAfterColumnResize($event)">
                </mj-gantt-chart>
            }
        </div>
    `,
    styles: [`
        :host { display: flex; flex-direction: column; width: 100%; height: 100%; min-height: 0; flex: 1; }
        .mjt-gantt-wrap { display: flex; flex-direction: column; gap: 8px; width: 100%; height: 100%; flex: 1; min-height: 0; position: relative; }
        .mjt-gantt-wrap mj-gantt-chart { flex: 1; min-height: 0; display: flex; flex-direction: column; width: 100%; height: 100%; }
        .mjt-gantt-toolbar {
            display: flex; align-items: center; justify-content: space-between; gap: 10px; flex-wrap: wrap;
            padding: 6px 12px;
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            font-size: 11.5px;
        }
        .mjt-gantt-legend { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .mjt-gantt-select-all {
            display: inline-flex; align-items: center; gap: 6px;
            padding-left: 10px; border-left: 1px solid var(--mj-border-default);
            color: var(--mj-text-secondary); font-weight: 600; cursor: pointer; user-select: none;
        }
        .mjt-gantt-select-all input { accent-color: var(--mj-brand-primary); cursor: pointer; }
        .mjt-gantt-right { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
        .mjt-gantt-zoom { display: inline-flex; align-items: center; gap: 4px; }
        .mjt-gantt-zoom__btn {
            width: 26px; height: 26px; border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-sm, 4px); background: var(--mj-bg-surface);
            color: var(--mj-text-primary); cursor: pointer; font-size: 16px; line-height: 1;
        }
        .mjt-gantt-zoom__btn:hover:not(:disabled) { background: var(--mj-bg-surface-hover); }
        .mjt-gantt-zoom__btn:disabled { color: var(--mj-text-disabled); cursor: default; }
        .mjt-gantt-zoom__label {
            min-width: 2.75rem; text-align: center; font-weight: 600;
            color: var(--mj-text-secondary); font-size: 11px;
        }
        .mjt-legend-item { display: inline-flex; align-items: center; gap: 5px; color: var(--mj-text-secondary); font-weight: 500; }
        .mjt-dot { width: 9px; height: 9px; border-radius: 50%; display: inline-block; box-sizing: border-box; }
        /* Hollow slate ring for Open vs solid blue dot for In Progress (WCAG 1.4.1) */
        .mjt-dot--open { background: transparent; border: 2px solid var(--mj-text-muted); }
        .mjt-dot--prog { background: var(--mj-brand-primary); }
        .mjt-dot--done { background: var(--mj-status-success); }
        .mjt-dot--blocked { background: var(--mj-status-error); }

        /* Gantt status bar tinting & crisp outside labels on short 1-3 day bars */
        :host ::ng-deep .gantt_task_line.mjt-short-bar {
            overflow: visible !important;
        }
        :host ::ng-deep .gantt_task_line.mjt-short-bar .gantt_task_content {
            position: absolute;
            left: calc(100% + 8px);
            top: 0;
            width: auto !important;
            overflow: visible !important;
            white-space: nowrap;
            color: var(--mj-text-primary) !important;
            font-weight: 600;
            text-align: left;
            pointer-events: none;
        }
        :host ::ng-deep .gantt_task_line[data-mjt-status="open"] {
            background: color-mix(in oklab, var(--mj-text-muted) 18%, var(--mj-bg-surface)) !important;
            border: 1.5px solid var(--mj-text-muted) !important;
        }
        :host ::ng-deep .gantt_task_line[data-mjt-status="open"] .gantt_task_content {
            color: var(--mj-text-primary) !important;
        }
        :host ::ng-deep .gantt_task_line[data-mjt-status="completed"] {
            background: var(--mj-status-success) !important;
            border-color: var(--mj-status-success) !important;
        }
        :host ::ng-deep .gantt_task_line[data-mjt-status="blocked"] {
            background: var(--mj-status-error) !important;
            border-color: var(--mj-status-error) !important;
        }
        :host ::ng-deep .gantt_task_line[data-mjt-selected="true"] {
            box-shadow: 0 0 0 2px var(--mj-brand-primary), 0 0 0 4px color-mix(in oklab, var(--mj-brand-primary) 22%, transparent);
        }
        :host ::ng-deep .mjt-gantt-row-chk {
            width: 14px;
            height: 14px;
            accent-color: var(--mj-brand-primary);
            cursor: pointer;
            vertical-align: middle;
        }
    `],
})
export class TaskGanttComponent implements OnInit, AfterViewInit, OnChanges, OnDestroy {
    @Input() Provider: IMetadataProvider | null = null;
    /** Optional pre-loaded controlled tasks. When non-null, zero internal RunView queries fire. */
    @Input() Tasks: readonly TaskWidgetItem[] | null = null;
    /** Optional pre-loaded dependency edges paired with `[Tasks]`. */
    @Input() Dependencies: readonly TaskGanttDependencyInput[] | null = null;
    @Input() CategoryID: string | null = null;
    @Input() ParentTaskID: string | null = null;
    @Input() IncludeParentSummary = true;
    @Input() ExtraFilter: string | null = null;
    @Input() SearchText = '';
    @Input() PriorityFilter: string | null = null;
    @Input() TypeIDFilter: string | null = null;
    @Input() AssigneeFilter: string | null = null;
    @Input() DueDateFilter: TaskDueDateFilterKey | null = null;
    @Input() OrganizationIDFilter: string | null = null;
    @Input() CurrentPersonID: string | null = null;
    @Input() Height = '500px';
    @Input() ReadOnly = true;
    @Input() ShowToolbar = true;
    @Input() Columns: GanttColumnDef[] | null = null;
    @Input() EnableBulkSelect = false;
    @Input() SelectedIDs: string[] = [];

    public get ProviderToUse(): IMetadataProvider {
        return this.Provider ?? Metadata.Provider;
    }

    private createRunView(): RunView {
        const p = this.ProviderToUse;
        if (p && typeof (p as Partial<IRunViewProvider>).RunView === 'function') {
            return RunView.FromMetadataProvider(p);
        }
        return new RunView();
    }

    @Output() TaskClicked = new EventEmitter<string>();
    @Output() TaskRowClicked = new EventEmitter<TaskClickRow>();
    @Output() TaskDoubleClicked = new EventEmitter<string>();
    @Output() BeforeZoomChange = new EventEmitter<BeforeZoomChangeEventArgs>();
    @Output() AfterZoomChange = new EventEmitter<AfterZoomChangeEventArgs>();
    @Output() SelectedIDsChange = new EventEmitter<string[]>();
    @Output() VisibleTaskIDsChange = new EventEmitter<string[]>();

    @ViewChild('chart') private chart?: MjGanttChartComponent;

    public items: GanttItemData[] = [];
    public links: GanttLinkData[] = [];
    public milestoneTasks: TaskWidgetItem[] = [];
    public CriticalPathIds = new Set<string>();
    public HighlightCriticalPath = false;
    public IsPhone = false;
    public loading = false;
    public ZoomLevel: GanttZoomLevelName = TASKS_GANTT_DEFAULT_ZOOM;
    public Pref: TasksGanttPref = DefaultTasksGanttPref();

    private rawTasks: GanttTaskRow[] = [];
    private rawDeps: { ID: string; TaskID: string; DependsOnTaskID: string; DependencyType: mjBizAppsTasksTaskDependencyEntity['DependencyType'] }[] = [];
    private assigneesByTask = new Map<string, Array<TaskAssigneeFilterRef & { DisplayName: string; IsRole: boolean }>>();
    private orgNameByTask = new Map<string, string>();
    private dueDateByTask = new Map<string, string>();
    private statusByTask = new Map<string, TaskStatusValue>();
    private stopWatchingPhone: (() => void) | null = null;
    private hasCustomGridWidth = false;
    private lastCheckedTaskID: string | null = null;
    private barObserver: MutationObserver | null = null;
    private decorateTimer: ReturnType<typeof setTimeout> | null = null;
    private suppressNextTaskClickUntil = 0;
    private captureClickListener: ((event: Event) => void) | null = null;
    private hostRef = inject(ElementRef, { optional: true });
    private cdr = inject(ChangeDetectorRef);

    private readonly selectColumn: GanttColumnDef = {
        Name: 'mjt_select',
        Label: '',
        Align: 'center',
        Width: 34,
        Resize: false,
        Template: (obj: { id?: string | number }) => this.renderSelectCell(obj),
    };

    private readonly defaultColumns: GanttColumnDef[] = [
        { Name: 'text', Label: 'Name', Tree: true, Width: 200 },
        {
            Name: 'start_date',
            Label: 'Start',
            Align: 'center',
            Width: 66,
            Template: (obj: { start_date?: Date | string }) => this.renderShortDateCell(obj?.start_date),
        },
        {
            Name: 'due_date',
            Label: 'Due',
            Align: 'center',
            Width: 66,
            Template: (obj: { id?: string | number }) => this.renderDueCell(obj),
        },
        {
            Name: 'assignee',
            Label: 'Assignee',
            Align: 'left',
            Width: 118,
            Template: (obj: { id?: string | number }) => this.renderAssigneeCell(obj),
        },
        {
            Name: 'organization',
            Label: 'Organization',
            Align: 'left',
            Width: 138,
            Template: (obj: { id?: string | number }) => this.renderOrgCell(obj),
        },
    ];

    public get AllVisibleSelected(): boolean {
        return this.items.length > 0 && this.items.every((item) => this.IsSelected(item.ID));
    }

    public get EffectiveColumns(): GanttColumnDef[] {
        const base = this.Columns && this.Columns.length > 0 ? this.Columns : this.defaultColumns;
        return this.EnableBulkSelect && !this.IsPhone ? [this.selectColumn, ...base] : base;
    }

    public get EffectiveGridWidth(): number {
        const defaultMin = this.EnableBulkSelect ? 624 : 590;
        return this.hasCustomGridWidth ? this.Pref.gridWidth : Math.max(this.Pref.gridWidth, defaultMin);
    }

    public IsSelected(taskID: string): boolean {
        return this.SelectedIDs.some((id) => UUIDsEqual(id, taskID));
    }

    public ToggleSelectAllVisible(): void {
        if (this.AllVisibleSelected) {
            this.SelectedIDs = [];
        } else {
            this.SelectedIDs = this.items.map((item) => item.ID);
        }
        this.SelectedIDsChange.emit([...this.SelectedIDs]);
        this.syncCheckboxStatesInDom();
        this.cdr.markForCheck();
    }

    public onGanttWrapClick(event: MouseEvent): void {
        const target = event.target;
        if (!(target instanceof HTMLInputElement) || !target.classList.contains('mjt-gantt-row-chk')) {
            return;
        }
        event.stopPropagation();
        const taskID = target.getAttribute('data-mjt-gantt-chk');
        if (!taskID) return;

        if (event.shiftKey && this.lastCheckedTaskID) {
            const visibleIds = this.items.map((item) => item.ID);
            const fromIdx = visibleIds.findIndex((id) => UUIDsEqual(id, this.lastCheckedTaskID));
            const toIdx = visibleIds.findIndex((id) => UUIDsEqual(id, taskID));
            if (fromIdx >= 0 && toIdx >= 0) {
                const start = Math.min(fromIdx, toIdx);
                const end = Math.max(fromIdx, toIdx);
                const seen = new Set(this.SelectedIDs.map((id) => id.toLowerCase()));
                const merged = [...this.SelectedIDs];
                for (let i = start; i <= end; i++) {
                    const id = visibleIds[i];
                    if (!seen.has(id.toLowerCase())) {
                        seen.add(id.toLowerCase());
                        merged.push(id);
                    }
                }
                this.SelectedIDs = merged;
                this.lastCheckedTaskID = taskID;
                this.SelectedIDsChange.emit([...this.SelectedIDs]);
                this.syncCheckboxStatesInDom();
                this.cdr.markForCheck();
                return;
            }
        }

        if (this.IsSelected(taskID)) {
            this.SelectedIDs = this.SelectedIDs.filter((id) => !UUIDsEqual(id, taskID));
        } else {
            this.SelectedIDs = [...this.SelectedIDs, taskID];
        }
        this.lastCheckedTaskID = taskID;
        this.SelectedIDsChange.emit([...this.SelectedIDs]);
        this.syncCheckboxStatesInDom();
        this.cdr.markForCheck();
    }

    private renderSelectCell(obj: { id?: string | number }): string {
        const id = escapeGanttHtml(String(obj?.id ?? ''));
        const checked = this.IsSelected(String(obj?.id ?? '')) ? ' checked' : '';
        return `<input type="checkbox" class="mjt-gantt-row-chk" data-mjt-gantt-chk="${id}" aria-label="Select task"${checked} />`;
    }

    private renderShortDateCell(val?: Date | string): string {
        if (!val) return '<span style="color:var(--mj-text-muted)">—</span>';
        const d = val instanceof Date ? val : new Date(val);
        if (Number.isNaN(d.getTime())) return '<span style="color:var(--mj-text-muted)">—</span>';
        return escapeGanttHtml(d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }));
    }

    private renderDueCell(obj: { id?: string | number }): string {
        const key = String(obj?.id ?? '').toLowerCase();
        const due = this.dueDateByTask.get(key);
        if (!due) {
            return '<span style="color:var(--mj-text-muted)">—</span>';
        }
        return escapeGanttHtml(due);
    }

    private renderAssigneeCell(obj: { id?: string | number }): string {
        const key = String(obj?.id ?? '').toLowerCase();
        const list = this.assigneesByTask.get(key) ?? [];
        if (list.length === 0) {
            return '<span style="color:var(--mj-text-muted);font-style:italic">Unassigned</span>';
        }
        const first = escapeGanttHtml(list[0].DisplayName);
        const extra = list.length > 1 ? ` <span style="opacity:0.75">+${list.length - 1}</span>` : '';
        const icon = list[0].IsRole ? '<i class="fa-solid fa-users" style="margin-right:4px;opacity:0.75"></i>' : '';
        return `${icon}${first}${extra}`;
    }

    private renderOrgCell(obj: { id?: string | number }): string {
        const key = String(obj?.id ?? '').toLowerCase();
        const org = this.orgNameByTask.get(key);
        if (!org) {
            return '<span style="color:var(--mj-text-muted)">—</span>';
        }
        return `<span title="${escapeGanttHtml(org)}">${escapeGanttHtml(org)}</span>`;
    }

    public get ZoomPercent(): number {
        return this.chart?.CurrentZoomPercent ?? GanttZoomPercent(this.ZoomLevel);
    }

    public get CanZoomIn(): boolean {
        return this.chart?.CanZoomIn ?? true;
    }

    public get CanZoomOut(): boolean {
        return this.chart?.CanZoomOut ?? true;
    }

    public ZoomIn(): void {
        this.chart?.ZoomIn();
        this.scheduleBarDecoration();
    }

    public ZoomOut(): void {
        this.chart?.ZoomOut();
        this.scheduleBarDecoration();
    }

    public ToggleCriticalPath(): void {
        this.HighlightCriticalPath = !this.HighlightCriticalPath;
        this.rebuildViewModels();
    }

    public OnBeforeZoomChange(event: BeforeZoomChangeEventArgs): void {
        this.BeforeZoomChange.emit(event);
    }

    public OnAfterZoomChange(event: AfterZoomChangeEventArgs): void {
        this.ZoomLevel = event.Level;
        this.persistPref({ zoomLevel: event.Level, zoomPercent: event.Percent });
        this.AfterZoomChange.emit(event);
        this.scheduleBarDecoration();
        this.cdr.markForCheck();
    }

    public OnAfterGridResize(event: AfterGridResizeEventArgs): void {
        this.hasCustomGridWidth = true;
        this.persistPref({ gridWidth: event.Width });
        this.scheduleBarDecoration();
    }

    public OnAfterColumnResize(event: AfterColumnResizeEventArgs): void {
        this.persistPref({ columnWidths: event.ColumnWidths });
    }

    public ngOnInit(): void {
        this.IsPhone = IsPhoneViewport();
        this.stopWatchingPhone = WatchPhoneViewport(() => {
            const next = IsPhoneViewport();
            if (next !== this.IsPhone) {
                this.IsPhone = next;
                this.cdr.markForCheck();
            }
        });

        try {
            this.Pref = ParseTasksGanttPref(
                UserInfoEngine.Instance.GetSetting(TASKS_GANTT_PREF_SETTING),
                UserInfoEngine.Instance.GetSetting(TASKS_GANTT_ZOOM_SETTING),
            );
            this.ZoomLevel = this.Pref.zoomLevel;
        } catch {
            // UserInfoEngine may not be initialized in isolated unit tests
        }
        if (this.Tasks !== null) {
            this.applyControlledData();
        } else {
            void this.LoadData();
        }
    }

    public ngAfterViewInit(): void {
        const root = this.hostRef?.nativeElement as HTMLElement | undefined;
        if (root) {
            this.captureClickListener = (event: Event) => {
                const target = event.target as HTMLElement | null;
                if (target?.closest?.('.mjt-gantt-row-chk, [data-column-name="mjt_select"]')) {
                    this.suppressNextTaskClickUntil = Date.now() + 300;
                }
            };
            root.addEventListener('click', this.captureClickListener, true);
        }
        if (root && typeof MutationObserver !== 'undefined') {
            this.barObserver = new MutationObserver(() => {
                this.scheduleBarDecoration();
            });
            this.barObserver.observe(root, { childList: true, subtree: true });
        }
        this.scheduleBarDecoration();
    }

    public ngOnDestroy(): void {
        const root = this.hostRef?.nativeElement as HTMLElement | undefined;
        if (root && this.captureClickListener) {
            root.removeEventListener('click', this.captureClickListener, true);
            this.captureClickListener = null;
        }
        this.stopWatchingPhone?.();
        this.barObserver?.disconnect();
        if (this.decorateTimer) clearTimeout(this.decorateTimer);
    }

    private persistPref(partial: Partial<TasksGanttPref>): void {
        this.Pref = { ...this.Pref, ...partial };
        UserInfoEngine.Instance.SetSettingDebounced(
            TASKS_GANTT_PREF_SETTING,
            SerializeTasksGanttPref(this.Pref),
        );
    }

    public ngOnChanges(changes: SimpleChanges): void {
        if (changes['SelectedIDs'] && !changes['SelectedIDs'].firstChange) {
            this.syncCheckboxStatesInDom();
            this.scheduleBarDecoration();
        }
        if (changes['Tasks'] || changes['Dependencies']) {
            if (this.Tasks !== null) {
                this.applyControlledData();
                return;
            } else if (changes['Tasks'] && !changes['Tasks'].firstChange) {
                void this.LoadData();
                return;
            }
        }
        if (
            this.Tasks === null &&
            (changes['CategoryID'] ||
                changes['ParentTaskID'] ||
                changes['ExtraFilter'] ||
                changes['PriorityFilter'] ||
                changes['TypeIDFilter'] ||
                changes['OrganizationIDFilter'])
        ) {
            void this.LoadData();
        } else if (
            (changes['SearchText'] && !changes['SearchText'].firstChange) ||
            (changes['AssigneeFilter'] && !changes['AssigneeFilter'].firstChange) ||
            (changes['DueDateFilter'] && !changes['DueDateFilter'].firstChange)
        ) {
            this.rebuildViewModels();
        }
    }

    public Refresh(): void {
        if (this.Tasks !== null) {
            this.applyControlledData();
            return;
        }
        void this.LoadData();
    }

    private applyControlledData(): void {
        const inputTasks = this.Tasks ?? [];
        this.rawTasks = inputTasks
            .filter((t) => t.Status !== 'Cancelled')
            .map((t, idx) => {
                const startRaw = t.StartedAt ?? null;
                const startIso = startRaw instanceof Date ? startRaw.toISOString() : startRaw;
                const dueRaw = t.DueAt ?? t.DueDate ?? null;
                const dueIso = dueRaw instanceof Date ? dueRaw.toISOString() : dueRaw;
                return {
                    ID: t.ID,
                    Name: t.Name,
                    Description: t.Description ?? null,
                    StartedAt: startIso,
                    DueAt: dueIso,
                    PercentComplete: t.PercentComplete ?? 0,
                    HoursEstimated: t.HoursEstimated ?? null,
                    ParentID: t.ParentID ?? null,
                    Status: t.Status,
                    Priority: t.Priority ?? 'Medium',
                    TaskTypeStatus: t.TaskTypeStatusName ?? null,
                    OrganizationID: t.OrganizationID ?? null,
                    Organization: t.OrganizationName ?? null,
                    Sequence: t.Sequence ?? idx + 1,
                };
            });

        this.rawDeps = (this.Dependencies ?? []).map((d, idx) => ({
            ID: d.ID || `${d.DependsOnTaskID}->${d.TaskID}:${idx}`,
            TaskID: d.TaskID,
            DependsOnTaskID: d.DependsOnTaskID,
            DependencyType: d.DependencyType ?? 'FinishToStart',
        }));

        this.assigneesByTask.clear();
        for (const t of inputTasks) {
            const tKey = t.ID.toLowerCase();
            if (t.Assignees && t.Assignees.length > 0) {
                this.assigneesByTask.set(
                    tKey,
                    t.Assignees.map((a) => ({
                        EntityName: a.EntityName ?? 'MJ_BizApps_Common: People',
                        RecordID: a.RecordID,
                        DisplayName: a.DisplayName,
                        IsRole: Boolean(a.IsRole),
                    })),
                );
            } else if (t.AssigneeNames && t.AssigneeNames.length > 0) {
                this.assigneesByTask.set(
                    tKey,
                    t.AssigneeNames.map((name, idx) => ({
                        EntityName: 'MJ_BizApps_Common: People',
                        RecordID: `name:${idx}:${name}`,
                        DisplayName: name,
                        IsRole: false,
                    })),
                );
            }
        }

        this.orgNameByTask.clear();
        this.dueDateByTask.clear();
        this.statusByTask.clear();
        for (const t of this.rawTasks) {
            const key = t.ID.toLowerCase();
            if (t.Organization) {
                this.orgNameByTask.set(key, t.Organization);
            }
            if (t.DueAt) {
                this.dueDateByTask.set(
                    key,
                    new Date(t.DueAt).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
                );
            }
            this.statusByTask.set(key, t.Status);
        }

        this.loading = false;
        this.rebuildViewModels();
    }

    public async LoadData(): Promise<void> {
        if (this.Tasks !== null) {
            this.applyControlledData();
            return;
        }
        this.loading = true;
        this.cdr.markForCheck();
        try {
            const rv = this.createRunView();
            const filters: string[] = ["Status <> 'Cancelled'"];

            if (this.ParentTaskID) {
                const pid = EscapeSQLString(this.ParentTaskID);
                if (this.IncludeParentSummary) {
                    filters.push(`(ID = '${pid}' OR ParentID = '${pid}' OR RootParentID = '${pid}')`);
                } else {
                    filters.push(`(ParentID = '${pid}' OR RootParentID = '${pid}')`);
                }
            } else {
                if (this.CategoryID) filters.push(`CategoryID = '${EscapeSQLString(this.CategoryID)}'`);
                if (this.PriorityFilter) filters.push(`Priority = '${EscapeSQLString(this.PriorityFilter)}'`);
                if (this.TypeIDFilter) filters.push(`TypeID = '${EscapeSQLString(this.TypeIDFilter)}'`);
                if (this.OrganizationIDFilter === '__none__') {
                    filters.push('OrganizationID IS NULL');
                } else if (this.OrganizationIDFilter) {
                    filters.push(`OrganizationID = '${EscapeSQLString(this.OrganizationIDFilter)}'`);
                }
                if (this.ExtraFilter) filters.push(this.ExtraFilter);
            }

            const tasksResult = await rv.RunView<GanttTaskRow>({
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                ExtraFilter: filters.join(' AND '),
                OrderBy: 'Sequence ASC',
                ResultType: 'simple',
                MaxRows: 500,
            });

            this.rawTasks = tasksResult?.Results ?? [];
            const taskIds = this.rawTasks.map((t) => t.ID).filter((id) => TASK_ID_RE.test(id));
            const [depsResult, assignResult] =
                taskIds.length === 0
                    ? [null, null]
                    : await Promise.all([
                          this.createRunView().RunView<{
                              ID: string;
                              TaskID: string;
                              DependsOnTaskID: string;
                              DependencyType: mjBizAppsTasksTaskDependencyEntity['DependencyType'];
                          }>({
                              EntityName: 'MJ_BizApps_Tasks: Task Dependencies',
                              ExtraFilter: `TaskID IN (${taskIds.map((id) => `'${id}'`).join(',')}) OR DependsOnTaskID IN (${taskIds.map((id) => `'${id}'`).join(',')})`,
                              ResultType: 'simple',
                              MaxRows: 500,
                          }),
                          this.createRunView().RunView<{ TaskID: string; AssigneeEntityID: string; AssigneeRecordID: string }>({
                              EntityName: 'MJ_BizApps_Tasks: Task Assignments',
                              ExtraFilter: `TaskID IN (${taskIds.map((id) => `'${id}'`).join(',')})`,
                              Fields: ['TaskID', 'AssigneeEntityID', 'AssigneeRecordID'],
                              ResultType: 'simple',
                              MaxRows: 1000,
                          }),
                      ]);
            this.rawDeps = depsResult?.Results ?? [];

            const rolesEntityID = this.ProviderToUse.EntityByName?.('MJ: Roles')?.ID?.toLowerCase() ?? null;
            const assignedPersonIds = [
                ...new Set(
                    (assignResult?.Results ?? [])
                        .filter((a) => !rolesEntityID || a.AssigneeEntityID.toLowerCase() !== rolesEntityID)
                        .map((a) => a.AssigneeRecordID)
                        .filter(Boolean),
                ),
            ];
            const peopleResult =
                assignedPersonIds.length === 0
                    ? null
                    : await this.createRunView().RunView<{ ID: string; FirstName: string; LastName: string }>({
                          EntityName: 'MJ_BizApps_Common: People',
                          ExtraFilter:
                              assignedPersonIds.length <= 500
                                  ? `ID IN (${assignedPersonIds.map((id) => `'${EscapeSQLString(id)}'`).join(',')})`
                                  : undefined,
                          Fields: ['ID', 'FirstName', 'LastName'],
                          ResultType: 'simple',
                      });

            const personMap = new Map<string, string>();
            for (const p of peopleResult?.Results ?? []) {
                personMap.set(p.ID.toLowerCase(), `${p.FirstName ?? ''} ${p.LastName ?? ''}`.trim());
            }

            this.assigneesByTask.clear();
            for (const a of assignResult?.Results ?? []) {
                const tKey = a.TaskID.toLowerCase();
                const list = this.assigneesByTask.get(tKey) ?? [];
                const isRole = Boolean(rolesEntityID && a.AssigneeEntityID.toLowerCase() === rolesEntityID);
                const displayName =
                    personMap.get(a.AssigneeRecordID.toLowerCase()) ??
                    RoleAssigneeName(a.AssigneeEntityID, a.AssigneeRecordID) ??
                    'Assigned';
                list.push({
                    EntityName: isRole ? 'MJ: Roles' : 'MJ_BizApps_Common: People',
                    RecordID: a.AssigneeRecordID,
                    DisplayName: displayName,
                    IsRole: isRole,
                });
                this.assigneesByTask.set(tKey, list);
            }

            this.orgNameByTask.clear();
            this.dueDateByTask.clear();
            this.statusByTask.clear();
            for (const t of this.rawTasks) {
                const key = t.ID.toLowerCase();
                if (t.Organization) {
                    this.orgNameByTask.set(key, t.Organization);
                }
                if (t.DueAt) {
                    this.dueDateByTask.set(
                        key,
                        new Date(t.DueAt).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
                    );
                }
                this.statusByTask.set(key, t.Status);
            }

            this.rebuildViewModels();
        } finally {
            this.loading = false;
            this.cdr.markForCheck();
        }
    }

    private rebuildViewModels(): void {
        const q = this.SearchText.trim().toLowerCase();
        const currentRoles = CurrentUserRoleIDs();
        const tasks = this.rawTasks.filter((t) => {
            if (
                q &&
                !t.Name.toLowerCase().includes(q) &&
                !(t.Description?.toLowerCase().includes(q) ?? false) &&
                !(t.Organization?.toLowerCase().includes(q) ?? false)
            ) {
                return false;
            }
            if (!MatchesDueDateFilter(t.DueAt, t.Status, this.DueDateFilter)) {
                return false;
            }
            if (!MatchesAssigneeFilter(this.assigneesByTask.get(t.ID.toLowerCase()), this.AssigneeFilter, this.CurrentPersonID, currentRoles)) {
                return false;
            }
            return true;
        });

        const edges: TaskDependencyEdge[] = this.rawDeps.map((d) => ({
            TaskID: d.TaskID,
            DependsOnTaskID: d.DependsOnTaskID,
            DependencyType: d.DependencyType,
        }));
        this.CriticalPathIds = ComputeCriticalPathTaskIds(tasks, edges);

        const depCountByTask = new Map<string, number>();
        for (const d of this.rawDeps) {
            const k1 = d.TaskID.toLowerCase();
            depCountByTask.set(k1, (depCountByTask.get(k1) ?? 0) + 1);
        }

        const filteredTasks = this.HighlightCriticalPath && this.CriticalPathIds.size > 0
            ? tasks.filter((t) => this.CriticalPathIds.has(t.ID.toLowerCase()))
            : tasks;
        const visibleSet = new Set(filteredTasks.map((t) => t.ID.toLowerCase()));

        this.items = filteredTasks.map((t) => {
            const startDate = t.StartedAt
                ? new Date(t.StartedAt)
                : t.DueAt
                  ? new Date(new Date(t.DueAt).getTime() - 7 * 86400000)
                  : new Date();
            const endDate = t.DueAt ? new Date(t.DueAt) : undefined;
            const duration = endDate ? undefined : 7;
            const isParentRoot = this.ParentTaskID && t.ID.toLowerCase() === this.ParentTaskID.toLowerCase();
            const parentVisible = t.ParentID ? visibleSet.has(t.ParentID.toLowerCase()) : false;
            const isCritical = this.CriticalPathIds.has(t.ID.toLowerCase());

            return {
                ID: t.ID,
                Name: this.HighlightCriticalPath && isCritical ? `● ${t.Name}` : t.Name,
                StartDate: startDate,
                EndDate: endDate,
                Duration: duration,
                Progress: t.PercentComplete ?? 0,
                ParentID: isParentRoot || !parentVisible ? undefined : t.ParentID || undefined,
                Open: true,
                Data: t,
            } as GanttItemData;
        });

        this.links = this.rawDeps
            .filter((d) => visibleSet.has(d.TaskID.toLowerCase()) && visibleSet.has(d.DependsOnTaskID.toLowerCase()))
            .map(
                (d) =>
                    ({
                        ID: d.ID,
                        SourceID: d.DependsOnTaskID,
                        TargetID: d.TaskID,
                        Type: this.mapDependencyType(d.DependencyType),
                    }) as GanttLinkData,
            );

        this.milestoneTasks = tasks.map((t) => ({
            ID: t.ID,
            Name: t.Name,
            Description: t.Description,
            ParentID: t.ParentID,
            Status: t.Status,
            Priority: t.Priority,
            StartedAt: t.StartedAt,
            DueAt: t.DueAt,
            PercentComplete: t.PercentComplete ?? 0,
            HoursEstimated: t.HoursEstimated,
            OrganizationID: t.OrganizationID,
            OrganizationName: t.Organization,
            Assignees: (this.assigneesByTask.get(t.ID.toLowerCase()) ?? []).map((a) => ({
                DisplayName: a.DisplayName,
                RecordID: a.RecordID,
                EntityName: a.EntityName,
                IsRole: a.IsRole,
                Status: 'Pending' as const,
            })),
            TaskTypeStatusName: t.TaskTypeStatus,
            IsCriticalPath: this.CriticalPathIds.has(t.ID.toLowerCase()),
            DependencyCount: depCountByTask.get(t.ID.toLowerCase()) ?? 0,
        }));

        this.VisibleTaskIDsChange.emit(filteredTasks.map((t) => t.ID));
        this.scheduleBarDecoration();
        this.cdr.markForCheck();
    }

    private scheduleBarDecoration(): void {
        if (this.decorateTimer) clearTimeout(this.decorateTimer);
        this.decorateTimer = setTimeout(() => {
            this.decorateGanttBars();
            this.syncCheckboxStatesInDom();
        }, 60);
    }

    private decorateGanttBars(): void {
        const root = this.hostRef?.nativeElement as HTMLElement | undefined;
        if (!root || typeof root.querySelectorAll !== 'function') return;
        const bars = root.querySelectorAll<HTMLElement>('.gantt_task_line[task_id]');
        bars.forEach((bar) => {
            const id = bar.getAttribute('task_id') ?? '';
            const status = this.statusByTask.get(id.toLowerCase()) ?? 'Open';
            const statusKey = status.toLowerCase();
            if (bar.getAttribute('data-mjt-status') !== statusKey) {
                bar.setAttribute('data-mjt-status', statusKey);
            }
            const selected = this.IsSelected(id) ? 'true' : 'false';
            if (bar.getAttribute('data-mjt-selected') !== selected) {
                bar.setAttribute('data-mjt-selected', selected);
            }
            const content = bar.querySelector<HTMLElement>('.gantt_task_content');
            bar.classList.remove('mjt-short-bar');
            const needsOutside =
                bar.offsetWidth > 0 &&
                (bar.offsetWidth < 136 || (content != null && content.scrollWidth > bar.clientWidth - 6));
            bar.classList.toggle('mjt-short-bar', needsOutside);
        });
    }

    private syncCheckboxStatesInDom(): void {
        const root = this.hostRef?.nativeElement as HTMLElement | undefined;
        if (!root || typeof root.querySelectorAll !== 'function') return;
        const boxes = root.querySelectorAll<HTMLInputElement>('input.mjt-gantt-row-chk[data-mjt-gantt-chk]');
        boxes.forEach((box) => {
            const id = box.getAttribute('data-mjt-gantt-chk') ?? '';
            box.checked = this.IsSelected(id);
        });
    }

    public onItemClicked(event: GanttItemClickedEvent): void {
        if (Date.now() < this.suppressNextTaskClickUntil) return;
        if (event.Item?.ID) {
            this.TaskClicked.emit(event.Item.ID);
            this.TaskRowClicked.emit({ ID: event.Item.ID, Name: event.Item.Name ?? '' });
        }
    }

    public onItemDoubleClicked(event: GanttItemClickedEvent): void {
        if (Date.now() < this.suppressNextTaskClickUntil) return;
        if (event.Item?.ID) {
            this.TaskDoubleClicked.emit(event.Item.ID);
        }
    }

    public onMobileTaskClick(taskID: string): void {
        const match = this.rawTasks.find((t) => t.ID === taskID);
        this.TaskClicked.emit(taskID);
        this.TaskRowClicked.emit({ ID: taskID, Name: match?.Name ?? '' });
    }

    public async onMobileStatusToggle(event: { TaskID: string; NewStatus: TaskStatusValue }): Promise<void> {
        if (this.ReadOnly) return;
        const entity = await this.ProviderToUse.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
        await entity.InnerLoad(CompositeKey.FromID(event.TaskID));
        entity.Status = event.NewStatus;
        entity.PercentComplete = event.NewStatus === 'Completed' ? 100 : 0;
        if (await entity.Save()) {
            await this.LoadData();
        }
    }

    private mapDependencyType(type: mjBizAppsTasksTaskDependencyEntity['DependencyType']): 'FS' | 'SS' | 'FF' | 'SF' {
        switch (type) {
            case 'FinishToStart': return 'FS';
            case 'StartToStart': return 'SS';
            case 'FinishToFinish': return 'FF';
            case 'StartToFinish': return 'SF';
            default: return 'FS';
        }
    }
}
