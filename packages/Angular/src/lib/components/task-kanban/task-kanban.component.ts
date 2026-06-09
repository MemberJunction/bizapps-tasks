import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, inject, Input, Output, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';
import { MjKanbanBoardComponent, KanbanCardData, KanbanColumnDef, KanbanCardMovedEvent } from '@memberjunction/ng-kanban';

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

/** Priority → color mapping for card accents. */
const PRIORITY_COLORS: Record<string, string> = {
    Critical: '#ef4444',
    High: '#f97316',
    Medium: '#eab308',
    Low: '#22c55e',
};

/** Priority → badge background mapping. */
const PRIORITY_BADGE_COLORS: Record<string, string> = {
    Critical: '#fef2f2',
    High: '#fff7ed',
    Medium: '#fefce8',
    Low: '#f0fdf4',
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
        <mj-kanban-board
            [Columns]="columns"
            [Cards]="cards"
            [ReadOnly]="ReadOnly"
            (CardMoved)="onCardMoved($event)"
            (CardClicked)="onCardClicked($event)">
        </mj-kanban-board>
    `
})
export class TaskKanbanComponent implements OnInit {
    @Input() CategoryID: string | null = null;
    @Input() ExtraFilter: string | null = null;
    @Input() ReadOnly = false;

    @Output() BeforeStatusChange = new EventEmitter<BeforeKanbanStatusChangeEvent>();
    @Output() AfterStatusChange = new EventEmitter<AfterKanbanStatusChangeEvent>();
    @Output() TaskClicked = new EventEmitter<string>();

    columns: KanbanColumnDef[] = [
        { Key: 'Open',       Label: 'Open',        Color: '#3b82f6' },
        { Key: 'InProgress', Label: 'In Progress',  Color: '#8b5cf6' },
        { Key: 'Blocked',    Label: 'Blocked',      Color: '#ef4444' },
        { Key: 'Completed',  Label: 'Completed',    Color: '#22c55e' },
    ];

    cards: KanbanCardData[] = [];
    private cdr = inject(ChangeDetectorRef);

    ngOnInit(): void { this.LoadTasks(); }

    Refresh(): void { this.LoadTasks(); }

    async LoadTasks(): Promise<void> {
        const rv = new RunView();
        const filters: string[] = ["Status <> 'Cancelled'"];
        if (this.CategoryID) filters.push(`CategoryID = '${this.CategoryID}'`);
        if (this.ExtraFilter) filters.push(this.ExtraFilter);

        const result = await rv.RunView<any>({
            EntityName: 'MJ.BizApps.Tasks: Tasks',
            ExtraFilter: filters.join(' AND '),
            OrderBy: 'Sequence ASC',
            ResultType: 'simple',
        });

        this.cards = (result?.Results ?? []).map((r: any) => ({
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

        const entity = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Tasks');
        const pk = new CompositeKey([{ FieldName: 'ID', Value: event.Card.ID }]);
        await entity.InnerLoad(pk);
        entity.Set('Status', event.ToColumn);
        await entity.Save();

        this.AfterStatusChange.emit({ TaskID: event.Card.ID, NewStatus: event.ToColumn });
        await this.LoadTasks();
    }

    onCardClicked(card: KanbanCardData): void {
        this.TaskClicked.emit(card.ID);
    }
}
