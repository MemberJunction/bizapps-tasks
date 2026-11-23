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
import { CompositeKey, Metadata, RunView, type IMetadataProvider, type IRunViewProvider } from '@memberjunction/core';
import { EscapeSQLString, NormalizeUUID, UUIDsEqual } from '@memberjunction/global';
import { UserInfoEngine } from '@memberjunction/core-entities';
import type {
    KanbanCardData,
    KanbanCardMovedEvent,
    KanbanColumnDef,
} from '@memberjunction/ng-kanban';
import {
    FormatDurationMinutes,
    MatchesAssigneeFilter,
    MatchesDueDateFilter,
    type TaskAssigneeFilterRef,
    type TaskDueDateFilterKey,
} from '@mj-biz-apps/tasks-core';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import type { TaskPriorityValue, TaskStatusValue, TaskWidgetTypeStatus } from '@mj-biz-apps/tasks-ng-widgets';
import { CurrentUserRoleIDs, RoleAssigneeName } from '../../role-assignees';
import {
    FilterTasksByPendingSuggestions,
    FormatPendingSuggestionTooltip,
    TaskFieldSuggestionsHelper,
    type TaskPendingSuggestionsSummary,
} from '../../task-field-suggestions.helper';

export type KanbanGroupByMode = 'status' | 'workflow' | 'priority' | 'assignee' | 'organization';

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
    LoggedMinutes?: number | null;
    ParentID: string | null;
    TypeID?: string;
    Type?: string | null;
    TaskTypeStatusID?: string | null;
    TaskTypeStatus?: string | null;
    OrganizationID?: string | null;
    Organization?: string | null;
    PendingSuggestionCount?: number;
    PendingSuggestionFields?: string[];
    PendingSuggestionTooltip?: string;
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
    Critical: 'var(--mj-status-error)',
    High: 'var(--mj-status-warning)',
    Medium: 'var(--mj-status-info)',
    Low: 'var(--mj-status-success)',
};

const MACRO_COLUMNS: KanbanColumnDef[] = [
    { Key: 'Open', Label: 'Open', Color: 'var(--mj-text-muted)' },
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
 * 5-Mode Kanban Board (Macro Status, Workflow Stages, Priority, Assignee, Organization).
 *
 * Designed to WCAG 2.1 AA contrast & calm-surface craft:
 * - 8px colored stage dots in column headers (zero top/left accent stripes)
 * - Uniform 1px card borders with soft high-contrast (>= 5.5:1) semantic priority pills
 * - Hover-reveal multi-select checkboxes (+ Shift+click range select) feeding `<mjt-bulk-action-dock>`
 * - Native HTML5 drag-and-drop across columns with optimistic status/stage/priority updates
 * - Persists user's preferred grouping via `UserInfoEngine` (never `localStorage`)
 */
@Component({
    selector: 'bizapps-task-kanban',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [FormsModule],
    template: `
        <div class="mjt-kb-wrap" [class.has-selection]="SelectedIDs.length > 0">
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
                            <option value="organization">Organization / Company</option>
                        </select>
                        @if (EnableBulkSelect && !ReadOnly && cards.length > 0) {
                            <label class="mjt-kb-select-all">
                                <input
                                    type="checkbox"
                                    [checked]="AllVisibleSelected"
                                    [indeterminate]="SelectedIDs.length > 0 && !AllVisibleSelected"
                                    (change)="ToggleSelectAllVisible()" />
                                <span>{{ SelectedIDs.length > 0 ? SelectedIDs.length + ' selected' : 'Select cards' }}</span>
                            </label>
                        }
                    </div>
                    <span class="mjt-kb-hint">
                        @if (GroupBy === 'workflow') {
                            Drag cards between stages to update both TaskTypeStatus and Macro Status
                        } @else if (GroupBy === 'priority') {
                            Drag cards across lanes to reprioritize
                        } @else if (GroupBy === 'assignee') {
                            Grouped by primary assignee (drag disabled in assignee view)
                        } @else if (GroupBy === 'organization') {
                            Grouped by Organization / Company (drag disabled in organization view)
                        } @else {
                            Drag cards across columns to update task status
                        }
                    </span>
                </div>
            }

            @if (moveError) {
                <div class="mjt-kb-error" role="alert">{{ moveError }}</div>
            }

            <div class="mjt-kb-board" role="region" aria-label="Tasks board">
                @for (col of columns; track col.Key) {
                    @let colCards = CardsForColumn(col.Key);
                    <section
                        class="mjt-kb-col"
                        [class.is-drag-over]="dragOverColKey === col.Key"
                        (dragover)="onColumnDragOver($event, col.Key)"
                        (dragleave)="onColumnDragLeave(col.Key)"
                        (drop)="onColumnDrop($event, col.Key)">
                        <header class="mjt-kb-col-head">
                            <div class="mjt-kb-col-title-row">
                                <span
                                    class="mjt-kb-stage-dot"
                                    [class.is-hollow]="GroupBy === 'status' && col.Key === 'Open'"
                                    [style.--mjt-dot-color]="col.Color || 'var(--mj-brand-primary)'"
                                    aria-hidden="true"></span>
                                <h3 class="mjt-kb-col-title">{{ col.Label }}</h3>
                            </div>
                            <span class="mjt-kb-col-count">{{ colCards.length }}</span>
                        </header>

                        <div class="mjt-kb-col-cards">
                            @for (card of colCards; track card.ID) {
                                @let task = asTaskData(card);
                                <article
                                    class="mjt-kb-card"
                                    [class.is-selected]="IsSelected(card.ID)"
                                    [class.is-dragging]="draggingCardId === card.ID"
                                    [attr.draggable]="CanDrag ? 'true' : 'false'"
                                    (dragstart)="onCardDragStart($event, card)"
                                    (dragend)="onCardDragEnd()"
                                    (click)="onCardClicked(card)"
                                    (dblclick)="onCardDoubleClicked(card)">
                                    <div class="mjt-kb-card-top">
                                        @if (card.BadgeText) {
                                            <span class="mjt-kb-pri" [class]="priorityPillClass(card.BadgeText)">
                                                {{ card.BadgeText }}
                                            </span>
                                        }
                                        @if (EnableBulkSelect && !ReadOnly) {
                                            <input
                                                type="checkbox"
                                                class="mjt-kb-chk"
                                                [checked]="IsSelected(card.ID)"
                                                [attr.aria-label]="'Select ' + card.Title"
                                                (click)="onCheckboxClick($event, card.ID)" />
                                        }
                                    </div>

                                    <div class="mjt-kb-card-title">{{ card.Title }}</div>

                                    @if (card.Subtitle) {
                                        <p class="mjt-kb-card-sub">{{ card.Subtitle }}</p>
                                    }

                                    @if (task) {
                                        <div class="mjt-kb-card-meta">
                                            @if (GroupBy !== 'organization' && task.Organization) {
                                                <span class="mjt-kb-chip mjt-kb-chip--org" [title]="task.Organization">
                                                    <i class="fa-solid fa-building" aria-hidden="true"></i>
                                                    <span>{{ task.Organization }}</span>
                                                </span>
                                            }
                                            @if (GroupBy !== 'workflow' && task.TaskTypeStatus) {
                                                <span class="mjt-kb-chip mjt-kb-chip--stage">{{ task.TaskTypeStatus }}</span>
                                            }
                                        </div>
                                    }

                                    @if (card.FooterText) {
                                        <div class="mjt-kb-card-foot">
                                            @if (GroupBy !== 'assignee' && PrimaryAssigneeName(card.ID)) {
                                                <span class="mjt-kb-assignee" [title]="PrimaryAssigneeName(card.ID)">
                                                    <span class="mjt-kb-avatar">{{ AssigneeInitials(PrimaryAssigneeName(card.ID)) }}</span>
                                                    <span class="mjt-kb-assignee-lbl">{{ PrimaryAssigneeShort(card.ID) }}</span>
                                                </span>
                                            }
                                            @if (task?.DueAt) {
                                                <span class="mjt-kb-due" [class.is-overdue]="isTaskOverdue(task)">
                                                    <i class="fa-regular fa-calendar" aria-hidden="true"></i>
                                                    {{ formatShortDate(task?.DueAt ?? null) }}
                                                </span>
                                            }
                                            @if (task?.LoggedMinutes && (task?.LoggedMinutes ?? 0) > 0) {
                                                <span class="mjt-kb-logged">
                                                    <i class="fa-regular fa-clock" aria-hidden="true"></i>
                                                    {{ formatLogged(task?.LoggedMinutes ?? 0) }}
                                                </span>
                                            }
                                        </div>
                                    }
                                </article>
                            }

                            @if (colCards.length === 0) {
                                <div class="mjt-kb-col-empty">No tasks</div>
                            }
                        </div>
                    </section>
                }
            </div>
        </div>
    `,
    styles: [`
        :host { display: block; width: 100%; min-width: 0; font-family: var(--mj-font-family); }
        .mjt-kb-wrap {
            display: flex; flex-direction: column; gap: 12px;
            width: 100%; min-width: 0; padding-bottom: 80px;
        }
        .mjt-kb-bar {
            display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap;
            padding: 6px 12px;
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
        }
        .mjt-kb-group-ctl { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .mjt-kb-label {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-secondary);
            display: inline-flex; align-items: center; gap: 5px;
        }
        .mjt-kb-select {
            padding: 4px 10px; min-height: 30px;
            border: 1px solid var(--mj-border-strong);
            border-radius: var(--mj-radius-sm, 6px);
            background: var(--mj-bg-surface);
            color: var(--mj-text-primary);
            font-family: inherit;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
        }
        .mjt-kb-select-all {
            display: inline-flex; align-items: center; gap: 6px;
            font-size: 11.5px; color: var(--mj-text-secondary); cursor: pointer; user-select: none;
            padding-left: 6px; border-left: 1px solid var(--mj-border-default);
        }
        .mjt-kb-select-all input { accent-color: var(--mj-brand-primary); cursor: pointer; }
        .mjt-kb-hint { font-size: 11.5px; color: var(--mj-text-muted); }
        .mjt-kb-error {
            padding: 8px 12px; border-radius: var(--mj-radius-sm, 6px);
            background: var(--mj-status-error-bg); color: var(--mj-status-error-text);
            font-size: var(--mj-text-xs, 12px);
        }
        .mjt-kb-board {
            display: flex; align-items: flex-start; gap: 12px;
            overflow-x: auto; padding-bottom: 8px; min-height: 360px;
        }
        .mjt-kb-col {
            flex: 1 0 268px; max-width: 340px; min-width: 256px;
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-lg, 10px);
            display: flex; flex-direction: column;
            transition: border-color 140ms ease, background 140ms ease;
        }
        .mjt-kb-col.is-drag-over {
            border-color: var(--mj-brand-primary);
            background: color-mix(in oklab, var(--mj-brand-primary) 7%, var(--mj-bg-surface-sunken));
        }
        .mjt-kb-col-head {
            display: flex; align-items: center; justify-content: space-between; gap: 8px;
            padding: 10px 12px;
            border-bottom: 1px solid var(--mj-border-subtle);
        }
        .mjt-kb-col-title-row { display: flex; align-items: center; gap: 8px; min-width: 0; }
        .mjt-kb-stage-dot {
            width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0;
            background: var(--mjt-dot-color, var(--mj-brand-primary));
            box-sizing: border-box;
        }
        .mjt-kb-stage-dot.is-hollow {
            background: transparent;
            border: 2px solid var(--mj-text-muted);
        }
        .mjt-kb-col-title {
            margin: 0; font-size: 12.5px; font-weight: var(--mj-font-bold, 700);
            color: var(--mj-text-primary);
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }
        .mjt-kb-col-count {
            font-family: var(--mj-font-family-mono, monospace);
            font-size: 11px; font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-secondary);
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-full, 9999px);
            padding: 1px 7px; flex-shrink: 0;
        }
        .mjt-kb-col-cards {
            display: flex; flex-direction: column; gap: 8px;
            padding: 10px; min-height: 100px;
        }
        .mjt-kb-col-empty {
            padding: 20px 10px; text-align: center;
            font-size: 12px; color: var(--mj-text-muted); font-style: italic;
        }
        .mjt-kb-card {
            display: flex; flex-direction: column; gap: 7px;
            padding: 11px 12px;
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            cursor: pointer;
            transition: border-color 140ms ease, background 140ms ease, box-shadow 140ms ease;
        }
        .mjt-kb-card:hover {
            border-color: var(--mj-brand-primary);
            box-shadow: var(--mj-shadow-sm, 0 1px 3px rgba(0, 0, 0, 0.08));
        }
        .mjt-kb-card.is-selected {
            border-color: var(--mj-brand-primary);
            background: color-mix(in oklab, var(--mj-brand-primary) 7%, var(--mj-bg-surface));
        }
        .mjt-kb-card.is-dragging { opacity: 0.45; }
        .mjt-kb-card-top {
            display: flex; align-items: center; justify-content: space-between; gap: 8px;
        }
        .mjt-kb-chk {
            width: 15px; height: 15px; accent-color: var(--mj-brand-primary);
            cursor: pointer; opacity: 0; transition: opacity 140ms ease; margin: 0;
        }
        .mjt-kb-card:hover .mjt-kb-chk,
        .mjt-kb-card:focus-within .mjt-kb-chk,
        .mjt-kb-wrap.has-selection .mjt-kb-chk,
        .mjt-kb-chk:checked { opacity: 1; }
        .mjt-kb-pri {
            display: inline-flex; align-items: center;
            padding: 2px 8px; border-radius: var(--mj-radius-full, 9999px);
            font-size: 11px; font-weight: var(--mj-font-semibold, 600);
            border: 1px solid transparent;
        }
        .mjt-kb-pri--critical {
            background: var(--mj-status-error-bg); color: var(--mj-status-error-text);
            border-color: color-mix(in oklab, var(--mj-status-error) 30%, transparent);
        }
        .mjt-kb-pri--high {
            background: var(--mj-status-warning-bg); color: var(--mj-status-warning-text);
            border-color: color-mix(in oklab, var(--mj-status-warning) 32%, transparent);
        }
        .mjt-kb-pri--medium {
            background: var(--mj-status-info-bg); color: var(--mj-status-info-text);
            border-color: color-mix(in oklab, var(--mj-status-info) 28%, transparent);
        }
        .mjt-kb-pri--low {
            background: var(--mj-bg-surface-sunken); color: var(--mj-text-secondary);
            border-color: var(--mj-border-default);
        }
        .mjt-kb-card-title {
            font-size: 13.5px; font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-primary); line-height: 1.35;
        }
        .mjt-kb-card-sub {
            margin: 0; font-size: 12px; color: var(--mj-text-secondary); line-height: 1.4;
            display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
        }
        .mjt-kb-card-meta { display: flex; align-items: center; gap: 5px; flex-wrap: wrap; }
        .mjt-kb-chip {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 1px 7px; border-radius: var(--mj-radius-sm, 4px);
            font-size: 11px; font-weight: var(--mj-font-medium, 500);
            max-width: 100%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
        }
        .mjt-kb-chip--org {
            background: var(--mj-bg-surface-sunken); color: var(--mj-text-secondary);
            border: 1px solid var(--mj-border-default);
        }
        .mjt-kb-chip--stage {
            background: color-mix(in oklab, var(--mj-brand-primary) 12%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
            border: 1px solid color-mix(in oklab, var(--mj-brand-primary) 26%, transparent);
        }
        .mjt-kb-card-foot {
            display: flex; align-items: center; justify-content: space-between; gap: 8px; flex-wrap: wrap;
            padding-top: 6px; border-top: 1px solid var(--mj-border-subtle);
            font-size: 11px; color: var(--mj-text-muted);
        }
        .mjt-kb-assignee {
            display: inline-flex; align-items: center; gap: 5px;
            color: var(--mj-text-secondary); font-weight: var(--mj-font-medium, 500);
            min-width: 0;
        }
        .mjt-kb-avatar {
            width: 20px; height: 20px; border-radius: 50%; flex-shrink: 0;
            background: color-mix(in oklab, var(--mj-brand-primary) 15%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
            font-size: 9.5px; font-weight: var(--mj-font-bold, 700);
            display: inline-flex; align-items: center; justify-content: center;
        }
        .mjt-kb-assignee-lbl { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 120px; }
        .mjt-kb-due,
        .mjt-kb-logged {
            display: inline-flex; align-items: center; gap: 4px; white-space: nowrap;
        }
        .mjt-kb-due.is-overdue { color: var(--mj-status-error-text); font-weight: var(--mj-font-semibold, 600); }
        @media (max-width: 768px) {
            .mjt-kb-select-all,
            .mjt-kb-chk { display: none; }
        }
    `],
})
export class TaskKanbanComponent implements OnInit, OnChanges {
    @Input() Provider: IMetadataProvider | null = null;
    @Input() CategoryID: string | null = null;
    @Input() ExtraFilter: string | null = null;
    @Input() SearchText = '';
    @Input() PriorityFilter: string | null = null;
    @Input() TypeIDFilter: string | null = null;
    @Input() AssigneeFilter: string | null = null;
    @Input() DueDateFilter: TaskDueDateFilterKey | null = null;
    @Input() OrganizationIDFilter: string | null = null;
    @Input() CurrentPersonID: string | null = null;
    @Input() ShowGroupByBar = true;
    @Input() ReadOnly = false;
    @Input() EnableBulkSelect = false;
    @Input() SelectedIDs: string[] = [];

    private _pendingSuggestionsOnly = false;
    private isInitialized = false;

    @Input()
    public get PendingSuggestionsOnly(): boolean {
        return this._pendingSuggestionsOnly;
    }
    public set PendingSuggestionsOnly(value: boolean) {
        const next = Boolean(value);
        if (next !== this._pendingSuggestionsOnly) {
            this._pendingSuggestionsOnly = next;
            if (this.isInitialized) {
                this.rebuildBoard();
            }
        }
    }

    public get ProviderToUse(): IMetadataProvider {
        return this.Provider ?? Metadata.Provider;
    }

    @Output() BeforeStatusChange = new EventEmitter<BeforeKanbanStatusChangeEvent>();
    @Output() AfterStatusChange = new EventEmitter<AfterKanbanStatusChangeEvent>();
    @Output() TaskClicked = new EventEmitter<string>();
    @Output() TaskRowClicked = new EventEmitter<TaskClickRow>();
    @Output() TaskDoubleClicked = new EventEmitter<string>();
    @Output() SelectedIDsChange = new EventEmitter<string[]>();
    @Output() VisibleTaskIDsChange = new EventEmitter<string[]>();

    public GroupBy: KanbanGroupByMode = 'status';
    public columns: KanbanColumnDef[] = [...MACRO_COLUMNS];
    public cards: KanbanCardData[] = [];
    public workflowStatuses: TaskWidgetTypeStatus[] = [];
    public rawTasks: KanbanTaskData[] = [];
    public fieldSuggestionsAvailable = false;
    public pendingSuggestionsByTask = new Map<string, TaskPendingSuggestionsSummary>();
    public moveError = '';
    public draggingCardId: string | null = null;
    public dragOverColKey: string | null = null;

    private assigneeByTask = new Map<string, string>();
    private assigneesByTask = new Map<string, Array<TaskAssigneeFilterRef & { DisplayName: string }>>();
    private lastCheckedTaskID: string | null = null;
    private cdr = inject(ChangeDetectorRef);

    public get CanDrag(): boolean {
        return !this.ReadOnly && this.GroupBy !== 'assignee' && this.GroupBy !== 'organization';
    }

    public get AllVisibleSelected(): boolean {
        return this.cards.length > 0 && this.cards.every((c) => this.IsSelected(c.ID));
    }

    public ngOnInit(): void {
        this.isInitialized = true;
        const saved = UserInfoEngine.Instance.GetSetting(KANBAN_GROUP_SETTING);
        if (
            saved === 'status' ||
            saved === 'workflow' ||
            saved === 'priority' ||
            saved === 'assignee' ||
            saved === 'organization'
        ) {
            this.GroupBy = saved;
        }
        void this.LoadTasks();
    }

    public ngOnChanges(changes: SimpleChanges): void {
        const queryChanged =
            (changes['ExtraFilter'] && !changes['ExtraFilter'].firstChange) ||
            (changes['CategoryID'] && !changes['CategoryID'].firstChange) ||
            (changes['PriorityFilter'] && !changes['PriorityFilter'].firstChange) ||
            (changes['TypeIDFilter'] && !changes['TypeIDFilter'].firstChange) ||
            (changes['OrganizationIDFilter'] && !changes['OrganizationIDFilter'].firstChange);
        if (queryChanged) {
            void this.LoadTasks();
        } else if (
            (changes['SearchText'] && !changes['SearchText'].firstChange) ||
            (changes['AssigneeFilter'] && !changes['AssigneeFilter'].firstChange) ||
            (changes['DueDateFilter'] && !changes['DueDateFilter'].firstChange)
        ) {
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

    public CardsForColumn(columnKey: string): KanbanCardData[] {
        return this.cards.filter((c) => c.ColumnKey === columnKey);
    }

    public IsSelected(taskID: string): boolean {
        return this.SelectedIDs.some((id) => UUIDsEqual(id, taskID));
    }

    public ToggleSelectAllVisible(): void {
        if (this.AllVisibleSelected) {
            this.SelectedIDs = [];
        } else {
            this.SelectedIDs = this.cards.map((c) => c.ID);
        }
        this.SelectedIDsChange.emit([...this.SelectedIDs]);
        this.cdr.markForCheck();
    }

    public onCheckboxClick(event: MouseEvent, taskID: string): void {
        event.stopPropagation();
        if (event.shiftKey && this.lastCheckedTaskID) {
            const visibleIds = this.cards.map((c) => c.ID);
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
        this.cdr.markForCheck();
    }

    public onCardDragStart(event: DragEvent, card: KanbanCardData): void {
        if (!this.CanDrag) {
            event.preventDefault();
            return;
        }
        this.draggingCardId = card.ID;
        event.dataTransfer?.setData('text/plain', card.ID);
        if (event.dataTransfer) {
            event.dataTransfer.effectAllowed = 'move';
        }
    }

    public onCardDragEnd(): void {
        this.draggingCardId = null;
        this.dragOverColKey = null;
        this.cdr.markForCheck();
    }

    public onColumnDragOver(event: DragEvent, colKey: string): void {
        if (!this.CanDrag || !this.draggingCardId) return;
        event.preventDefault();
        if (this.dragOverColKey !== colKey) {
            this.dragOverColKey = colKey;
            this.cdr.markForCheck();
        }
    }

    public onColumnDragLeave(colKey: string): void {
        if (this.dragOverColKey === colKey) {
            this.dragOverColKey = null;
            this.cdr.markForCheck();
        }
    }

    public onColumnDrop(event: DragEvent, targetColKey: string): void {
        event.preventDefault();
        this.dragOverColKey = null;
        if (!this.CanDrag) return;
        const cardId = this.draggingCardId || event.dataTransfer?.getData('text/plain') || '';
        this.draggingCardId = null;
        const card = this.cards.find((c) => UUIDsEqual(c.ID, cardId));
        if (!card || card.ColumnKey === targetColKey) {
            this.cdr.markForCheck();
            return;
        }
        void this.onCardMoved({
            Card: card,
            FromColumn: card.ColumnKey,
            ToColumn: targetColKey,
        });
    }

    public asTaskData(card: KanbanCardData): KanbanTaskData | null {
        return (card.Data as KanbanTaskData | undefined) ?? null;
    }

    public PrimaryAssigneeName(taskID: string): string {
        return this.assigneeByTask.get(taskID.toLowerCase()) ?? '';
    }

    public PrimaryAssigneeShort(taskID: string): string {
        const list = this.assigneesByTask.get(taskID.toLowerCase()) ?? [];
        if (list.length === 0) return '';
        const parts = list[0].DisplayName.trim().split(/\s+/).filter(Boolean);
        const short = parts.length <= 1 ? list[0].DisplayName.trim() : `${parts[0]} ${parts[parts.length - 1][0]}.`;
        return list.length > 1 ? `${short} +${list.length - 1}` : short;
    }

    public AssigneeInitials(name: string): string {
        const parts = name.trim().split(/\s+/).filter(Boolean);
        if (parts.length === 0) return '?';
        if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
        return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }

    public priorityPillClass(priority: string): string {
        return `mjt-kb-pri--${priority.toLowerCase()}`;
    }

    public formatShortDate(raw: string | null): string {
        if (!raw) return '';
        return new Date(raw).toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    }

    public formatLogged(minutes: number): string {
        return FormatDurationMinutes(minutes);
    }

    public isTaskOverdue(task: KanbanTaskData | null): boolean {
        if (!task?.DueAt || task.Status === 'Completed' || task.Status === 'Cancelled') return false;
        return new Date(task.DueAt) < new Date();
    }

    private createRunView(): RunView {
        const p = this.ProviderToUse;
        if (p && typeof (p as Partial<IRunViewProvider>).RunView === 'function') {
            return RunView.FromMetadataProvider(p);
        }
        return new RunView();
    }

    public async LoadTasks(bypassCache = false): Promise<void> {
        const rv = this.createRunView();
        const filters: string[] = ["Status <> 'Cancelled'"];
        if (this.CategoryID) filters.push(`CategoryID = '${EscapeSQLString(this.CategoryID)}'`);
        if (this.PriorityFilter) filters.push(`Priority = '${EscapeSQLString(this.PriorityFilter)}'`);
        if (this.TypeIDFilter) filters.push(`TypeID = '${EscapeSQLString(this.TypeIDFilter)}'`);
        if (this.OrganizationIDFilter === '__none__') {
            filters.push('OrganizationID IS NULL');
        } else if (this.OrganizationIDFilter) {
            filters.push(`OrganizationID = '${EscapeSQLString(this.OrganizationIDFilter)}'`);
        }
        if (this.ExtraFilter) filters.push(this.ExtraFilter);

        const [tasksRes, statusesRes, assignmentsRes, peopleRes] = await Promise.all([
            rv.RunView<KanbanTaskData>({
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                ExtraFilter: filters.join(' AND '),
                OrderBy: 'Sequence ASC',
                ResultType: 'simple',
                BypassCache: bypassCache,
            }),
            this.createRunView().RunView<TaskWidgetTypeStatus>({
                EntityName: 'MJ_BizApps_Tasks: Task Type Status',
                ExtraFilter: 'IsActive = 1',
                OrderBy: 'Sequence ASC',
                ResultType: 'simple',
            }),
            this.createRunView().RunView<{ TaskID: string; AssigneeEntityID: string; AssigneeRecordID: string }>({
                EntityName: 'MJ_BizApps_Tasks: Task Assignments',
                Fields: ['TaskID', 'AssigneeEntityID', 'AssigneeRecordID'],
                ResultType: 'simple',
                BypassCache: bypassCache,
            }),
            this.createRunView().RunView<{ ID: string; FirstName: string; LastName: string }>({
                EntityName: 'MJ_BizApps_Common: People',
                Fields: ['ID', 'FirstName', 'LastName'],
                ResultType: 'simple',
            }),
        ]);

        const loadedTasks = tasksRes?.Results ?? [];
        const suggestions = await TaskFieldSuggestionsHelper.LoadPendingSuggestions(this.ProviderToUse, {
            taskIds: loadedTasks.map((t) => t.ID),
        });
        this.fieldSuggestionsAvailable = suggestions.available;
        this.pendingSuggestionsByTask = suggestions.byTaskId;

        this.rawTasks = loadedTasks.map((t) => {
            const summary = this.pendingSuggestionsByTask.get(NormalizeUUID(t.ID));
            return {
                ...t,
                PendingSuggestionCount: summary?.pendingCount ?? 0,
                PendingSuggestionFields: summary?.fieldNames ?? [],
                PendingSuggestionTooltip: FormatPendingSuggestionTooltip(summary ?? null),
            };
        });
        this.workflowStatuses = statusesRes?.Results ?? [];

        const personNames = new Map<string, string>();
        for (const p of peopleRes?.Results ?? []) {
            personNames.set(p.ID.toLowerCase(), `${p.FirstName} ${p.LastName}`.trim());
        }
        this.assigneeByTask.clear();
        this.assigneesByTask.clear();
        for (const a of assignmentsRes?.Results ?? []) {
            const key = a.TaskID.toLowerCase();
            const displayName =
                personNames.get(a.AssigneeRecordID.toLowerCase()) ??
                RoleAssigneeName(a.AssigneeEntityID, a.AssigneeRecordID) ??
                'Assigned';
            const list = this.assigneesByTask.get(key) ?? [];
            list.push({ RecordID: a.AssigneeRecordID, DisplayName: displayName });
            this.assigneesByTask.set(key, list);
            if (!this.assigneeByTask.has(key)) {
                this.assigneeByTask.set(key, displayName);
            }
        }

        if (this.GroupBy === 'workflow' && this.workflowStatuses.length === 0) {
            this.GroupBy = 'status';
        }
        this.rebuildBoard();
    }

    private rebuildBoard(): void {
        const q = this.SearchText.trim().toLowerCase();
        const currentRoles = CurrentUserRoleIDs();
        let visible = this.rawTasks.filter((t) => {
            if (
                q &&
                !t.Name.toLowerCase().includes(q) &&
                !(t.Description?.toLowerCase().includes(q) ?? false) &&
                !(t.TaskTypeStatus?.toLowerCase().includes(q) ?? false) &&
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
        visible = FilterTasksByPendingSuggestions(visible, this._pendingSuggestionsOnly, this.pendingSuggestionsByTask);

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
        } else if (this.GroupBy === 'organization') {
            const orgNames = [...new Set(visible.map((r) => r.Organization || 'No Organization'))].sort((a, b) => {
                if (a === 'No Organization') return 1;
                if (b === 'No Organization') return -1;
                return a.localeCompare(b);
            });
            this.columns = orgNames.map((name) => ({
                Key: name,
                Label: name,
                Color: name === 'No Organization' ? 'var(--mj-border-strong)' : 'var(--mj-brand-primary)',
            }));
            this.cards = visible.map((r) => this.toCard(r, r.Organization || 'No Organization'));
        } else {
            this.columns = [...MACRO_COLUMNS];
            this.cards = visible.map((r) => this.toCard(r, r.Status));
        }
        this.VisibleTaskIDsChange.emit(visible.map((r) => r.ID));
        this.cdr.markForCheck();
    }

    private toCard(r: KanbanTaskData, columnKey: string): KanbanCardData {
        const dueStr = r.DueAt ? new Date(r.DueAt).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) : '';
        const list = this.assigneesByTask.get(r.ID.toLowerCase()) ?? [];
        const assigneeStr =
            list.length > 1
                ? `${list[0].DisplayName} +${list.length - 1}`
                : list.length === 1
                  ? list[0].DisplayName
                  : '';
        const loggedStr = r.LoggedMinutes && r.LoggedMinutes > 0 ? FormatDurationMinutes(r.LoggedMinutes) : '';
        const footerParts = [
            this.GroupBy !== 'assignee' ? assigneeStr : '',
            this.GroupBy !== 'organization' ? r.Organization : null,
            this.GroupBy !== 'workflow' ? r.TaskTypeStatus : null,
            dueStr,
            loggedStr,
            r.PendingSuggestionTooltip || null,
        ].filter(Boolean);
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
        if (this.GroupBy === 'assignee' || this.GroupBy === 'organization') return;

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
