import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
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
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';
import { EscapeSQLString } from '@memberjunction/global';
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
    IsPhoneViewport,
    MJButtonDirective,
    MJEmptyStateComponent,
    WatchPhoneViewport,
} from '@memberjunction/ng-ui-components';
import { ComputeCriticalPathTaskIds, type TaskDependencyEdge } from '@mj-biz-apps/tasks-core';
import type { mjBizAppsTasksTaskDependencyEntity, mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import {
    TaskMobileMilestoneStackComponent,
    type TaskPriorityValue,
    type TaskStatusValue,
    type TaskWidgetItem,
} from '@mj-biz-apps/tasks-ng-widgets';
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
    Sequence: number;
}

/**
 * Critical-Path Split Gantt + Mobile Milestone Stack wrapping MJ's `<mj-gantt-chart>`.
 *
 * - Desktop & tablet (`> 768px`): full DHTMLX split-pane Gantt via `<mj-gantt-chart>` with
 *   zoom/grid/column-width persistence in `UserInfoEngine`, FS/SS/FF/SF dependency arrows,
 *   and a **Critical Path** highlight toggle powered by L0 DAG longest-path calculation.
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
        <div class="mjt-gantt-wrap" [style.height]="IsPhone ? 'auto' : Height">
            @if (ShowToolbar) {
                <div class="mjt-gantt-toolbar">
                    <div class="mjt-gantt-legend">
                        <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--open"></span> Open</span>
                        <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--prog"></span> In Progress</span>
                        <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--done"></span> Completed</span>
                        <span class="mjt-legend-item"><span class="mjt-dot mjt-dot--blocked"></span> Blocked</span>
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
                    [Columns]="Columns"
                    [Height]="Height"
                    [ReadOnly]="ReadOnly"
                    [ShowProgress]="true"
                    [EnableZoom]="true"
                    [EnableGridScroll]="true"
                    [EnableGridResize]="true"
                    [EnableColumnResize]="true"
                    [ZoomLevel]="ZoomLevel"
                    [GridWidth]="Pref.gridWidth"
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
        .mjt-dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; }
        .mjt-dot--open { background: var(--mj-status-info); }
        .mjt-dot--prog { background: var(--mj-brand-primary); }
        .mjt-dot--done { background: var(--mj-status-success); }
        .mjt-dot--blocked { background: var(--mj-status-error); }
    `],
})
export class TaskGanttComponent implements OnInit, OnChanges, OnDestroy {
    @Input() CategoryID: string | null = null;
    @Input() ParentTaskID: string | null = null;
    @Input() IncludeParentSummary = true;
    @Input() ExtraFilter: string | null = null;
    @Input() SearchText = '';
    @Input() PriorityFilter: string | null = null;
    @Input() TypeIDFilter: string | null = null;
    @Input() Height = '500px';
    @Input() ReadOnly = true;
    @Input() ShowToolbar = true;
    @Input() Columns: GanttColumnDef[] | null = null;

    @Output() TaskClicked = new EventEmitter<string>();
    @Output() TaskRowClicked = new EventEmitter<TaskClickRow>();
    @Output() TaskDoubleClicked = new EventEmitter<string>();
    @Output() BeforeZoomChange = new EventEmitter<BeforeZoomChangeEventArgs>();
    @Output() AfterZoomChange = new EventEmitter<AfterZoomChangeEventArgs>();

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
    private stopWatchingPhone: (() => void) | null = null;
    private cdr = inject(ChangeDetectorRef);

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
    }

    public ZoomOut(): void {
        this.chart?.ZoomOut();
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
        this.cdr.markForCheck();
    }

    public OnAfterGridResize(event: AfterGridResizeEventArgs): void {
        this.persistPref({ gridWidth: event.Width });
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

        this.Pref = ParseTasksGanttPref(
            UserInfoEngine.Instance.GetSetting(TASKS_GANTT_PREF_SETTING),
            UserInfoEngine.Instance.GetSetting(TASKS_GANTT_ZOOM_SETTING),
        );
        this.ZoomLevel = this.Pref.zoomLevel;
        void this.LoadData();
    }

    public ngOnDestroy(): void {
        this.stopWatchingPhone?.();
    }

    private persistPref(partial: Partial<TasksGanttPref>): void {
        this.Pref = { ...this.Pref, ...partial };
        UserInfoEngine.Instance.SetSettingDebounced(
            TASKS_GANTT_PREF_SETTING,
            SerializeTasksGanttPref(this.Pref),
        );
    }

    public ngOnChanges(changes: SimpleChanges): void {
        if (
            changes['CategoryID'] ||
            changes['ParentTaskID'] ||
            changes['ExtraFilter'] ||
            changes['PriorityFilter'] ||
            changes['TypeIDFilter']
        ) {
            void this.LoadData();
        } else if (changes['SearchText'] && !changes['SearchText'].firstChange) {
            this.rebuildViewModels();
        }
    }

    public Refresh(): void {
        void this.LoadData();
    }

    public async LoadData(): Promise<void> {
        this.loading = true;
        this.cdr.markForCheck();
        try {
            const rv = new RunView();
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
            const depsResult =
                taskIds.length === 0
                    ? null
                    : await new RunView().RunView<{
                          ID: string;
                          TaskID: string;
                          DependsOnTaskID: string;
                          DependencyType: mjBizAppsTasksTaskDependencyEntity['DependencyType'];
                      }>({
                          EntityName: 'MJ_BizApps_Tasks: Task Dependencies',
                          ExtraFilter: `TaskID IN (${taskIds.map((id) => `'${id}'`).join(',')}) OR DependsOnTaskID IN (${taskIds.map((id) => `'${id}'`).join(',')})`,
                          ResultType: 'simple',
                          MaxRows: 500,
                      });
            this.rawDeps = depsResult?.Results ?? [];

            this.rebuildViewModels();
        } finally {
            this.loading = false;
            this.cdr.markForCheck();
        }
    }

    private rebuildViewModels(): void {
        const q = this.SearchText.trim().toLowerCase();
        const tasks = q
            ? this.rawTasks.filter(
                  (t) =>
                      t.Name.toLowerCase().includes(q) ||
                      (t.Description?.toLowerCase().includes(q) ?? false),
              )
            : this.rawTasks;

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
            TaskTypeStatusName: t.TaskTypeStatus,
            IsCriticalPath: this.CriticalPathIds.has(t.ID.toLowerCase()),
            DependencyCount: depCountByTask.get(t.ID.toLowerCase()) ?? 0,
        }));
        this.cdr.markForCheck();
    }

    public onItemClicked(event: GanttItemClickedEvent): void {
        if (event.Item?.ID) {
            this.TaskClicked.emit(event.Item.ID);
            this.TaskRowClicked.emit({ ID: event.Item.ID, Name: event.Item.Name ?? '' });
        }
    }

    public onItemDoubleClicked(event: GanttItemClickedEvent): void {
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
        const entity = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
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
