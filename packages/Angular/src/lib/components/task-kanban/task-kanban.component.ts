import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    EventEmitter,
    Input,
    OnChanges,
    OnInit,
    Output,
    SimpleChanges,
    inject,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';
import { EscapeSQLString } from '@memberjunction/global';
import { UserInfoEngine } from '@memberjunction/core-entities';
import {
    KanbanCardData,
    KanbanCardMovedEvent,
    KanbanColumnDef,
    MjKanbanBoardComponent,
} from '@memberjunction/ng-kanban';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import type { TaskPriorityValue, TaskStatusValue, TaskWidgetTypeStatus } from '@mj-biz-apps/tasks-ng-widgets';

export type KanbanGroupByMode = 'status' | 'workflow' | 'priority' | 'assignee';

const KANBAN_GROUP_SETTING = 'mj.tasks.kanbanGroupBy.v1';

export class BeforeKanbanStatusChangeEvent {
    Cancel = false;
    constructor(
        public TaskID: string,
        public OldStatus: string,
        public NewStatus: string,
        public Card?: KanbanCardData,
    ) {}
}

export interface KanbanTaskData {
    ID: string;
    Name: string;
    Description: string | null;
    Status: TaskStatusValue;
    Priority: TaskPriorityValue;
    DueAt: string | null;
    PercentComplete: number | null;
    HoursEstimated: number | null;
    ParentID: string | null;
    TypeID?: string;
    Type?: string | null;
    TaskTypeStatusID?: string | null;
    TaskTypeStatus?: string | null;
}

export interface AfterKanbanStatusChangeEvent {
    TaskID: string;
    NewStatus: string;
    Card?: KanbanCardData;
}

export interface TaskClickRow {
    ID: string;
    Name: string;
}

const PRIORITY_COLORS: Record<string, string> = {
    Critical: 'var(--mj-status-error)',
    High: 'var(--mj-status-warning)',
    Medium: 'var(--mj-status-info)',
    Low: 'var(--mj-status-success)',
};

const PRIORITY_BADGE_COLORS: Record<string, string> = {
    Critical: 'var(--mj-status-error-bg)',
    High: 'var(--mj-status-warning-bg)',
    Medium: 'var(--mj-status-info-bg)',
    Low: 'var(--mj-status-success-bg)',
};

const MACRO_COLUMNS: KanbanColumnDef[] = [
    { Key: 'Open', Label: 'Open', Color: 'var(--mj-status-info)' },
    { Key: 'InProgress', Label: 'In Progress', Color: 'var(--mj-brand-primary)' },
    { Key: 'Blocked', Label: 'Blocked', Color: 'var(--mj-status-error)' },
    { Key: 'Completed', Label: 'Completed', Color: 'var(--mj-status-success)' },
];

const PRIORITY_COLUMNS: KanbanColumnDef[] = [
    { Key: 'Critical', Label: 'Critical', Color: 'var(--mj-status-error)' },
    { Key: 'High', Label: 'High', Color: 'var(--mj-status-warning)' },
    { Key: 'Medium', Label: 'Medium', Color: 'var(--mj-status-info)' },
    { Key: 'Low', Label: 'Low', Color: 'var(--mj-status-success)' },
];

/**
 * 4-Mode Smart Kanban Board wrapping MJ's generic `<mj-kanban-board>`.
 *
 * Supports grouping by:
 * - `status` — Macro Status (`Open`, `In Progress`, `Blocked`, `Completed`)
 * - `workflow` — Custom `TaskTypeStatus` workflow columns (`Spec → Build → QA → Shipped`)
 * - `priority` — Priority lanes (`Critical`, `High`, `Medium`, `Low`)
 * - `assignee` — Primary assignee swimlanes
 *
 * Persists the user's preferred grouping via `UserInfoEngine` (never `localStorage`).
 */
@Component({
    selector: 'bizapps-task-kanban',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [FormsModule, MjKanbanBoardComponent],
    template: `
        <div class="mjt-kb-wrap">
            @if (ShowGroupByBar) {
                <div class="mjt-kb-bar">
                    <div class="mjt-kb-group-ctl">
                        <label class="mjt-kb-label" for="mjtKbGroup">
                            <i class="fa-solid fa-layer-group" aria-hidden="true"></i> Group by
                        </label>
                        <select id="mjtKbGroup" class="mjt-kb-select" [(ngModel)]="GroupBy" (ngModelChange)="onGroupByChange($event)">
                            <option value="status">Macro Status</option>
                            @if (workflowStatuses.length > 0) {
                                <option value="workflow">Workflow Stages (TaskTypeStatus)</option>
                            }
                            <option value="priority">Priority</option>
                            <option value="assignee">Assignee</option>
                        </select>
                    </div>
                    <span class="mjt-kb-hint">
                        @if (GroupBy === 'workflow') {
                            Drag cards between stages to update both TaskTypeStatus and Macro Status
                        } @else if (GroupBy === 'priority') {
                            Drag cards across lanes to reprioritize
                        } @else if (GroupBy === 'assignee') {
                            Grouped by primary assignee (drag disabled in assignee view)
                        } @else {
                            Drag cards across columns to update task status
                        }
                    </span>
                </div>
            }

            @if (moveError) {
                <div class="mjt-kb-error" role="alert">{{ moveError }}</div>
            }

            <mj-kanban-board
                [Columns]="columns"
                [Cards]="cards"
                [ReadOnly]="ReadOnly || GroupBy === 'assignee'"
                (CardMoved)="onCardMoved($event)"
                (CardClicked)="onCardClicked($event)"
                (CardDoubleClicked)="onCardDoubleClicked($event)">
            </mj-kanban-board>
        </div>
    `,
    styles: [`
        :host { display: block; width: 100%; min-width: 0; }
        .mjt-kb-wrap { display: flex; flex-direction: column; gap: 10px; width: 100%; min-width: 0; }
        .mjt-kb-bar {
            display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap;
            padding: 6px 12px;
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
        }
        .mjt-kb-group-ctl { display: flex; align-items: center; gap: 8px; }
        .mjt-kb-label {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-secondary);
            display: inline-flex; align-items: center; gap: 5px;
        }
        .mjt-kb-select {
            padding: 4px 10px;
            min-height: 30px;
            border: 1px solid var(--mj-border-strong);
            border-radius: var(--mj-radius-sm, 6px);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
        }
        .mjt-kb-hint {
            font-size: 11.5px;
            color: var(--mj-text-muted);
        }
        .mjt-kb-error {
            padding: 8px 12px;
            border-radius: var(--mj-radius-sm, 6px);
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
            font-size: var(--mj-text-xs, 12px);
        }
    `],
})
export class TaskKanbanComponent implements OnInit, OnChanges {
    @Input() CategoryID: string | null = null;
    @Input() ExtraFilter: string | null = null;
    @Input() SearchText = '';
    @Input() PriorityFilter: string | null = null;
    @Input() TypeIDFilter: string | null = null;
    @Input() ShowGroupByBar = true;
    @Input() ReadOnly = false;

    @Output() BeforeStatusChange = new EventEmitter<BeforeKanbanStatusChangeEvent>();
    @Output() AfterStatusChange = new EventEmitter<AfterKanbanStatusChangeEvent>();
    @Output() TaskClicked = new EventEmitter<string>();
    @Output() TaskRowClicked = new EventEmitter<TaskClickRow>();
    @Output() TaskDoubleClicked = new EventEmitter<string>();

    public GroupBy: KanbanGroupByMode = 'status';
    public columns: KanbanColumnDef[] = [...MACRO_COLUMNS];
    public cards: KanbanCardData[] = [];
    public workflowStatuses: TaskWidgetTypeStatus[] = [];
    public moveError = '';

    private rawTasks: KanbanTaskData[] = [];
    private assigneeByTask = new Map<string, string>();
    private cdr = inject(ChangeDetectorRef);

    public ngOnInit(): void {
        const saved = UserInfoEngine.Instance.GetSetting(KANBAN_GROUP_SETTING);
        if (saved === 'status' || saved === 'workflow' || saved === 'priority' || saved === 'assignee') {
            this.GroupBy = saved;
        }
        void this.LoadTasks();
    }

    public ngOnChanges(changes: SimpleChanges): void {
        const queryChanged =
            (changes['ExtraFilter'] && !changes['ExtraFilter'].firstChange) ||
            (changes['CategoryID'] && !changes['CategoryID'].firstChange) ||
            (changes['PriorityFilter'] && !changes['PriorityFilter'].firstChange) ||
            (changes['TypeIDFilter'] && !changes['TypeIDFilter'].firstChange);
        if (queryChanged) {
            void this.LoadTasks();
        } else if (changes['SearchText'] && !changes['SearchText'].firstChange) {
            this.rebuildBoard();
        }
    }

    public Refresh(): void {
        void this.LoadTasks(true);
    }

    public onGroupByChange(mode: KanbanGroupByMode): void {
        this.GroupBy = mode;
        UserInfoEngine.Instance.SetSettingDebounced(KANBAN_GROUP_SETTING, mode);
        this.rebuildBoard();
    }

    public async LoadTasks(bypassCache = false): Promise<void> {
        const rv = new RunView();
        const filters: string[] = ["Status <> 'Cancelled'"];
        if (this.CategoryID) filters.push(`CategoryID = '${EscapeSQLString(this.CategoryID)}'`);
        if (this.PriorityFilter) filters.push(`Priority = '${EscapeSQLString(this.PriorityFilter)}'`);
        if (this.TypeIDFilter) filters.push(`TypeID = '${EscapeSQLString(this.TypeIDFilter)}'`);
        if (this.ExtraFilter) filters.push(this.ExtraFilter);

        const [tasksRes, statusesRes, assignmentsRes, peopleRes] = await Promise.all([
            rv.RunView<KanbanTaskData>({
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                ExtraFilter: filters.join(' AND '),
                OrderBy: 'Sequence ASC',
                ResultType: 'simple',
                BypassCache: bypassCache,
            }),
            new RunView().RunView<TaskWidgetTypeStatus>({
                EntityName: 'MJ_BizApps_Tasks: Task Type Status',
                ExtraFilter: 'IsActive = 1',
                OrderBy: 'Sequence ASC',
                ResultType: 'simple',
            }),
            new RunView().RunView<{ TaskID: string; AssigneeRecordID: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Assignments',
                Fields: ['TaskID', 'AssigneeRecordID'],
                ResultType: 'simple',
                BypassCache: bypassCache,
            }),
            new RunView().RunView<{ ID: string; FirstName: string; LastName: string }>({
                EntityName: 'MJ_BizApps_Common: People',
                Fields: ['ID', 'FirstName', 'LastName'],
                ResultType: 'simple',
            }),
        ]);

        this.rawTasks = tasksRes?.Results ?? [];
        this.workflowStatuses = statusesRes?.Results ?? [];

        const personNames = new Map<string, string>();
        for (const p of peopleRes?.Results ?? []) {
            personNames.set(p.ID.toLowerCase(), `${p.FirstName} ${p.LastName}`.trim());
        }
        this.assigneeByTask.clear();
        for (const a of assignmentsRes?.Results ?? []) {
            const key = a.TaskID.toLowerCase();
            if (!this.assigneeByTask.has(key)) {
                this.assigneeByTask.set(key, personNames.get(a.AssigneeRecordID.toLowerCase()) || 'Assigned');
            }
        }

        if (this.GroupBy === 'workflow' && this.workflowStatuses.length === 0) {
            this.GroupBy = 'status';
        }
        this.rebuildBoard();
    }

    private rebuildBoard(): void {
        const q = this.SearchText.trim().toLowerCase();
        const visible = q
            ? this.rawTasks.filter(
                  (t) =>
                      t.Name.toLowerCase().includes(q) ||
                      (t.Description?.toLowerCase().includes(q) ?? false) ||
                      (t.TaskTypeStatus?.toLowerCase().includes(q) ?? false),
              )
            : this.rawTasks;

        if (this.GroupBy === 'workflow' && this.workflowStatuses.length > 0) {
            this.columns = [
                ...this.workflowStatuses.map((s) => ({
                    Key: s.ID,
                    Label: s.Name,
                    Color: s.Color || 'var(--mj-brand-primary)',
                })),
                { Key: '__unassigned_stage__', Label: 'No Workflow Stage', Color: 'var(--mj-border-strong)' },
            ];
            this.cards = visible.map((r) => this.toCard(r, r.TaskTypeStatusID || '__unassigned_stage__'));
        } else if (this.GroupBy === 'priority') {
            this.columns = [...PRIORITY_COLUMNS];
            this.cards = visible.map((r) => this.toCard(r, r.Priority));
        } else if (this.GroupBy === 'assignee') {
            const names = [...new Set(visible.map((r) => this.assigneeByTask.get(r.ID.toLowerCase()) || 'Unassigned'))].sort();
            this.columns = names.map((name) => ({
                Key: name,
                Label: name,
                Color: name === 'Unassigned' ? 'var(--mj-border-strong)' : 'var(--mj-brand-primary)',
            }));
            this.cards = visible.map((r) => this.toCard(r, this.assigneeByTask.get(r.ID.toLowerCase()) || 'Unassigned'));
        } else {
            this.columns = [...MACRO_COLUMNS];
            this.cards = visible.map((r) => this.toCard(r, r.Status));
        }
        this.cdr.markForCheck();
    }

    private toCard(r: KanbanTaskData, columnKey: string): KanbanCardData {
        const dueStr = r.DueAt ? new Date(r.DueAt).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) : '';
        const assignee = this.assigneeByTask.get(r.ID.toLowerCase());
        const footerParts = [r.TaskTypeStatus, dueStr, assignee].filter(Boolean);
        return {
            ID: r.ID,
            Title: r.Name,
            Subtitle: r.Description || undefined,
            ColumnKey: columnKey,
            Color: PRIORITY_COLORS[r.Priority] || undefined,
            BadgeText: r.Priority,
            BadgeColor: PRIORITY_BADGE_COLORS[r.Priority] || undefined,
            FooterText: footerParts.length > 0 ? footerParts.join(' · ') : undefined,
            Data: r,
        };
    }

    public async onCardMoved(event: KanbanCardMovedEvent): Promise<void> {
        if (this.GroupBy === 'assignee') return;

        if (this.GroupBy === 'priority') {
            const entity = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            await entity.InnerLoad(CompositeKey.FromID(event.Card.ID));
            entity.Priority = event.ToColumn as TaskPriorityValue;
            const saved = await entity.Save();
            if (!saved) {
                this.moveError = entity.LatestResult?.CompleteMessage || 'Priority update was refused.';
            } else {
                this.moveError = '';
            }
            await this.LoadTasks(true);
            return;
        }

        if (this.GroupBy === 'workflow') {
            const stage = this.workflowStatuses.find((s) => s.ID === event.ToColumn);
            const targetMacro: TaskStatusValue = stage ? stage.MacroStatus : 'Open';
            const before = new BeforeKanbanStatusChangeEvent(event.Card.ID, event.FromColumn, targetMacro, event.Card);
            this.BeforeStatusChange.emit(before);
            if (before.Cancel) return;

            const entity = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
            await entity.InnerLoad(CompositeKey.FromID(event.Card.ID));
            entity.TaskTypeStatusID = stage ? stage.ID : null;
            entity.Status = targetMacro;
            if (targetMacro === 'Completed') entity.PercentComplete = 100;
            const saved = await entity.Save();
            if (!saved) {
                this.moveError = entity.LatestResult?.CompleteMessage || 'The stage change was refused.';
                await this.LoadTasks(true);
                return;
            }
            this.moveError = '';
            this.AfterStatusChange.emit({ TaskID: event.Card.ID, NewStatus: targetMacro, Card: event.Card });
            await this.LoadTasks(true);
            return;
        }

        // Default: Macro Status move
        const before = new BeforeKanbanStatusChangeEvent(event.Card.ID, event.FromColumn, event.ToColumn, event.Card);
        this.BeforeStatusChange.emit(before);
        if (before.Cancel) return;

        const entity = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
        await entity.InnerLoad(CompositeKey.FromID(event.Card.ID));
        entity.Status = event.ToColumn as TaskStatusValue;
        const saved = await entity.Save();
        if (!saved) {
            this.moveError = entity.LatestResult?.CompleteMessage || 'The status change was refused.';
            await this.LoadTasks(true);
            return;
        }
        this.moveError = '';

        this.AfterStatusChange.emit({ TaskID: event.Card.ID, NewStatus: event.ToColumn, Card: event.Card });
        await this.LoadTasks(true);
    }

    public onCardClicked(card: KanbanCardData): void {
        this.TaskClicked.emit(card.ID);
        this.TaskRowClicked.emit({ ID: card.ID, Name: card.Title });
    }

    public onCardDoubleClicked(card: KanbanCardData): void {
        this.TaskDoubleClicked.emit(card.ID);
    }
}
