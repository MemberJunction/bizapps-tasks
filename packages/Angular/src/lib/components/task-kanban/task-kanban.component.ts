import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, inject, Input, Output, OnChanges, OnInit, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';
import { MjKanbanBoardComponent, KanbanCardData, KanbanColumnDef, KanbanCardMovedEvent } from '@memberjunction/ng-kanban';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';

/**
 * Cancellable event emitted before a drag-and-drop status change on the Kanban board.
 * Set `Cancel = true` to prevent the status change from being persisted.
 */
export class BeforeKanbanStatusChangeEvent {
    Cancel = false;
    constructor(
        public TaskID: string,
        public OldStatus: string,
        public NewStatus: string
    ) {}
}

/**
 * Event emitted after a drag-and-drop status change has been persisted.
 */
export interface AfterKanbanStatusChangeEvent {
    TaskID: string;
    NewStatus: string;
}

/** The task a board click names. `ID` opens it; `Name` labels a subtask. */
export interface TaskClickRow {
    ID: string;
    Name: string;
}

/** Priority → color mapping for card accents. */
const PRIORITY_COLORS: Record<string, string> = {
    Critical: 'var(--mj-status-error)',
    High: 'var(--mj-status-warning)',
    Medium: 'var(--mj-status-info)',
    Low: 'var(--mj-status-success)',
};

/** Priority → badge background mapping. */
const PRIORITY_BADGE_COLORS: Record<string, string> = {
    Critical: 'var(--mj-status-error-bg)',
    High: 'var(--mj-status-warning-bg)',
    Medium: 'var(--mj-status-info-bg)',
    Low: 'var(--mj-status-success-bg)',
};

/**
 * Task-specific Kanban board that wraps the generic `<mj-kanban-board>`.
 *
 * Loads tasks from the BizAppsTasks entity, maps them to Kanban cards,
 * and persists status changes on drag-and-drop.
 *
 * @example
 * ```html
 * <bizapps-task-kanban
 *     [CategoryID]="committeeCategoryId"
 *     (TaskClicked)="openDetailPanel($event)">
 * </bizapps-task-kanban>
 * ```
 */
@Component({
    selector: 'bizapps-task-kanban',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [CommonModule, MjKanbanBoardComponent],
    template: `
        @if (moveError) {
            <div class="move-error" role="alert">{{ moveError }}</div>
        }
        <mj-kanban-board
            [Columns]="columns"
            [Cards]="cards"
            [ReadOnly]="ReadOnly"
            (CardMoved)="onCardMoved($event)"
            (CardClicked)="onCardClicked($event)"
            (CardDoubleClicked)="onCardDoubleClicked($event)">
        </mj-kanban-board>
    `,
    styles: [`.move-error { color: var(--mj-status-error); font-size: 12px; margin-bottom: 8px; }`]
})
export class TaskKanbanComponent implements OnInit, OnChanges {
    @Input() CategoryID: string | null = null;
    @Input() ExtraFilter: string | null = null;
    @Input() ReadOnly = false;

    @Output() BeforeStatusChange = new EventEmitter<BeforeKanbanStatusChangeEvent>();
    @Output() AfterStatusChange = new EventEmitter<AfterKanbanStatusChangeEvent>();
    @Output() TaskClicked = new EventEmitter<TaskClickRow>();
    @Output() TaskDoubleClicked = new EventEmitter<string>();

    columns: KanbanColumnDef[] = [
        { Key: 'Open',       Label: 'Open',        Color: 'var(--mj-status-info)' },
        { Key: 'InProgress', Label: 'In Progress',  Color: 'var(--mj-brand-primary)' },
        { Key: 'Blocked',    Label: 'Blocked',      Color: 'var(--mj-status-error)' },
        { Key: 'Completed',  Label: 'Completed',    Color: 'var(--mj-status-success)' },
    ];

    cards: KanbanCardData[] = [];
    /** @internal Shown when a drag's status save is refused. The card snaps back. */
    moveError = '';
    private cdr = inject(ChangeDetectorRef);

    ngOnInit(): void { this.LoadTasks(); }

    ngOnChanges(changes: SimpleChanges): void {
        const filterChanged = (changes['ExtraFilter'] && !changes['ExtraFilter'].firstChange)
            || (changes['CategoryID'] && !changes['CategoryID'].firstChange);
        if (filterChanged) this.LoadTasks();
    }

    Refresh(): void { this.LoadTasks(); }

    async LoadTasks(bypassCache: boolean = false): Promise<void> {
        const rv = new RunView();
        const filters: string[] = ["Status <> 'Cancelled'"];
        if (this.CategoryID) filters.push(`CategoryID = '${this.CategoryID}'`);
        if (this.ExtraFilter) filters.push(this.ExtraFilter);

        const result = await rv.RunView<{
            ID: string;
            Name: string;
            Description: string | null;
            Status: string;
            Priority: string;
            DueAt: string | null;
        }>({
            EntityName: 'MJ_BizApps_Tasks: Tasks',
            ExtraFilter: filters.join(' AND '),
            OrderBy: 'Sequence ASC',
            ResultType: 'simple',
            // Bypass cache on post-mutation reloads (e.g. after drag status change)
            // so the board reflects the change immediately.
            BypassCache: bypassCache,
        });

        this.cards = (result?.Results ?? []).map((r) => ({
            ID: r.ID,
            Title: r.Name,
            Subtitle: r.Description || undefined,
            ColumnKey: r.Status,
            Color: PRIORITY_COLORS[r.Priority] || undefined,
            BadgeText: r.Priority,
            BadgeColor: PRIORITY_BADGE_COLORS[r.Priority] || undefined,
            FooterText: r.DueAt ? new Date(r.DueAt).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) : undefined,
            Data: r,
        }));
        this.cdr.markForCheck();
    }

    async onCardMoved(event: KanbanCardMovedEvent): Promise<void> {
        const before = new BeforeKanbanStatusChangeEvent(event.Card.ID, event.FromColumn, event.ToColumn);
        this.BeforeStatusChange.emit(before);
        if (before.Cancel) return;

        const entity = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
        const pk = new CompositeKey([{ FieldName: 'ID', Value: event.Card.ID }]);
        await entity.InnerLoad(pk);
        entity.Status = event.ToColumn as mjBizAppsTasksTaskEntity['Status'];
        const saved = await entity.Save();
        if (!saved) {
            this.moveError = entity.LatestResult?.CompleteMessage || 'The status change was refused.';
            await this.LoadTasks(true);
            return;
        }
        this.moveError = '';

        this.AfterStatusChange.emit({ TaskID: event.Card.ID, NewStatus: event.ToColumn });
        await this.LoadTasks(true);
    }

    onCardClicked(card: KanbanCardData): void {
        this.TaskClicked.emit({ ID: card.ID, Name: card.Title });
    }

    onCardDoubleClicked(card: KanbanCardData): void {
        this.TaskDoubleClicked.emit(card.ID);
    }
}
