import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, inject, Input, Output, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';
import { TaskPriorityBadgeComponent } from '../task-priority-badge/task-priority-badge.component';

/**
 * Cancellable event emitted before a drag-and-drop status change on the Kanban board.
 * Set `Cancel = true` to prevent the status change from being persisted.
 *
 * @example
 * ```ts
 * onBeforeChange(event: BeforeKanbanStatusChangeEvent) {
 *     if (event.NewStatus === 'Completed' && !confirm('Mark as done?')) {
 *         event.Cancel = true;
 *     }
 * }
 * ```
 */
export class BeforeKanbanStatusChangeEvent {
    /** Set to `true` to prevent the status change. */
    Cancel = false;
    constructor(
        /** ID of the task being moved. */
        public TaskID: string,
        /** The status column the card was dragged from. */
        public OldStatus: string,
        /** The status column the card was dropped into. */
        public NewStatus: string
    ) {}
}

/**
 * Event emitted after a drag-and-drop status change has been persisted.
 */
export interface AfterKanbanStatusChangeEvent {
    /** ID of the task that was moved. */
    TaskID: string;
    /** The new status that was saved. */
    NewStatus: string;
}

/** @internal Represents a single card on the Kanban board. */
interface KanbanCard {
    ID: string;
    Name: string;
    Priority: string;
    DueAt: Date | null;
    PercentComplete: number;
    Sequence: number;
}

/** @internal Represents a status column on the Kanban board. */
interface KanbanColumn {
    Status: string;
    Label: string;
    Cards: KanbanCard[];
    Color: string;
}

/**
 * Kanban board with columns per task status (Open, In Progress, Blocked, Completed).
 *
 * Supports native HTML5 drag-and-drop to move cards between columns, which
 * triggers a status change on the underlying task entity. Cards show the task
 * name, priority badge, and due date.
 *
 * Cancelled tasks are excluded from the board by default.
 *
 * @example
 * ```html
 * <bizapps-task-kanban
 *     [CategoryID]="committeeCategoryId"
 *     (BeforeStatusChange)="onBeforeChange($event)"
 *     (AfterStatusChange)="onAfterChange($event)"
 *     (TaskClicked)="openDetailPanel($event)">
 * </bizapps-task-kanban>
 * ```
 */
@Component({
    selector: 'bizapps-task-kanban',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [CommonModule, TaskPriorityBadgeComponent],
    template: `
        <div class="kanban-board">
            @for (col of columns; track col.Status) {
                <div class="kanban-column"
                     (dragover)="onDragOver($event)"
                     (drop)="onDrop($event, col.Status)">
                    <div class="column-header" [style.border-top-color]="col.Color">
                        <span class="column-title">{{ col.Label }}</span>
                        <span class="column-count">{{ col.Cards.length }}</span>
                    </div>
                    <div class="column-body">
                        @for (card of col.Cards; track card.ID) {
                            <div class="kanban-card"
                                 draggable="true"
                                 (dragstart)="onDragStart($event, card, col.Status)"
                                 (click)="TaskClicked.emit(card.ID)">
                                <div class="card-name">{{ card.Name }}</div>
                                <div class="card-footer">
                                    <bizapps-task-priority-badge [Priority]="card.Priority"></bizapps-task-priority-badge>
                                    @if (card.DueAt) {
                                        <span class="card-due">{{ card.DueAt | date:'MMM d' }}</span>
                                    }
                                </div>
                            </div>
                        }
                        @if (col.Cards.length === 0) {
                            <div class="empty-column">No tasks</div>
                        }
                    </div>
                </div>
            }
        </div>
    `,
    styles: [`
        .kanban-board {
            display: flex; gap: 12px; overflow-x: auto; padding-bottom: 8px;
            min-height: 400px;
        }
        .kanban-column {
            flex: 0 0 260px; background: #f9fafb; border-radius: 8px;
            display: flex; flex-direction: column;
        }
        .column-header {
            padding: 10px 12px; font-weight: 600; font-size: 0.85rem;
            display: flex; justify-content: space-between; align-items: center;
            border-top: 3px solid #d1d5db; border-radius: 8px 8px 0 0;
        }
        .column-count {
            background: #e5e7eb; border-radius: 10px; padding: 1px 8px;
            font-size: 0.75rem; color: #6b7280;
        }
        .column-body { flex: 1; padding: 8px; display: flex; flex-direction: column; gap: 6px; min-height: 100px; }
        .kanban-card {
            background: #fff; border: 1px solid #e5e7eb; border-radius: 6px;
            padding: 10px; cursor: grab; transition: box-shadow 0.15s;
        }
        .kanban-card:hover { box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
        .kanban-card:active { cursor: grabbing; }
        .card-name { font-size: 0.875rem; font-weight: 500; margin-bottom: 6px; }
        .card-footer { display: flex; justify-content: space-between; align-items: center; }
        .card-due { font-size: 0.75rem; color: #6b7280; }
        .empty-column { text-align: center; color: #9ca3af; font-size: 0.8rem; padding: 16px; }
    `]
})
export class TaskKanbanComponent implements OnInit {
    // ── Inputs ──────────────────────────────────────────────

    /**
     * Filter board to a specific category. Pass a TaskCategory ID to scope
     * the board, or `null` to show all tasks.
     */
    @Input() CategoryID: string | null = null;

    /**
     * Additional SQL WHERE clause filter appended to the task query.
     */
    @Input() ExtraFilter: string | null = null;

    // ── Outputs ─────────────────────────────────────────────

    /**
     * Emitted **before** a drag-and-drop status change is persisted.
     * Cancellable — set `event.Cancel = true` to prevent the change.
     */
    @Output() BeforeStatusChange = new EventEmitter<BeforeKanbanStatusChangeEvent>();

    /**
     * Emitted **after** a drag-and-drop status change has been saved.
     */
    @Output() AfterStatusChange = new EventEmitter<AfterKanbanStatusChangeEvent>();

    /**
     * Emitted when a card is clicked (not dragged). Payload is the task ID.
     * Consuming apps should open a detail or edit panel in response.
     */
    @Output() TaskClicked = new EventEmitter<string>();

    // ── Internal State ──────────────────────────────────────

    /** @internal */
    columns: KanbanColumn[] = [
        { Status: 'Open',       Label: 'Open',        Cards: [], Color: '#3b82f6' },
        { Status: 'InProgress', Label: 'In Progress',  Cards: [], Color: '#8b5cf6' },
        { Status: 'Blocked',    Label: 'Blocked',      Cards: [], Color: '#ef4444' },
        { Status: 'Completed',  Label: 'Completed',    Cards: [], Color: '#22c55e' },
    ];
    /** @internal */
    private dragCardID: string | null = null;
    /** @internal */
    private dragSourceStatus: string | null = null;
    /** @internal */
    private cdr = inject(ChangeDetectorRef);

    // ── Lifecycle ───────────────────────────────────────────

    ngOnInit(): void { this.LoadTasks(); }

    // ── Public Methods ──────────────────────────────────────

    /**
     * Reloads all task data and re-populates the board columns.
     * Call this after external changes to refresh the board.
     */
    Refresh(): void { this.LoadTasks(); }

    /**
     * Loads tasks from the server and distributes them into status columns.
     * Called automatically on init and after each drag-and-drop.
     */
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

        for (const col of this.columns) col.Cards = [];

        for (const r of result?.Results ?? []) {
            const col = this.columns.find(c => c.Status === r.Status);
            if (!col) continue;
            col.Cards.push({
                ID: r.ID,
                Name: r.Name,
                Priority: r.Priority,
                DueAt: r.DueAt ? new Date(r.DueAt) : null,
                PercentComplete: r.PercentComplete ?? 0,
                Sequence: r.Sequence ?? 100,
            });
        }
        this.cdr.markForCheck();
    }

    // ── Drag and Drop ───────────────────────────────────────

    /** @internal */
    onDragStart(event: DragEvent, card: KanbanCard, sourceStatus: string): void {
        this.dragCardID = card.ID;
        this.dragSourceStatus = sourceStatus;
        event.dataTransfer?.setData('text/plain', card.ID);
    }

    /** @internal */
    onDragOver(event: DragEvent): void {
        event.preventDefault();
    }

    /** @internal */
    async onDrop(event: DragEvent, targetStatus: string): Promise<void> {
        event.preventDefault();
        if (!this.dragCardID || this.dragSourceStatus === targetStatus) return;

        const before = new BeforeKanbanStatusChangeEvent(this.dragCardID, this.dragSourceStatus!, targetStatus);
        this.BeforeStatusChange.emit(before);
        if (before.Cancel) return;

        const entity = await Metadata.Provider.GetEntityObject('MJ.BizApps.Tasks: Tasks');
        const pk = new CompositeKey([{ FieldName: 'ID', Value: this.dragCardID }]);
        await entity.InnerLoad(pk);
        entity.Set('Status', targetStatus);
        await entity.Save();

        this.AfterStatusChange.emit({ TaskID: this.dragCardID, NewStatus: targetStatus });
        this.dragCardID = null;
        this.dragSourceStatus = null;
        await this.LoadTasks();
    }
}
