import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, inject, Input, Output, OnChanges, OnInit, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CompositeKey, Metadata, RunView, type IMetadataProvider, type IRunViewProvider } from '@memberjunction/core';
import { NormalizeUUID } from '@memberjunction/global';
import { MjKanbanBoardComponent, KanbanCardData, KanbanColumnDef, KanbanCardMovedEvent } from '@memberjunction/ng-kanban';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import {
    FilterTasksByPendingSuggestions,
    FormatPendingSuggestionTooltip,
    TaskFieldSuggestionsHelper,
    type TaskPendingSuggestionsSummary,
} from '../../task-field-suggestions.helper';

/**
 * Cancellable event emitted before a drag-and-drop status change on the Kanban board.
 * Set `Cancel = true` to prevent the status change from being persisted.
 */
export class BeforeKanbanStatusChangeEvent {
    Cancel = false;
    constructor(
        public TaskID: string,
        public OldStatus: string,
        public NewStatus: string,
        public Card?: KanbanCardData
    ) {}
}

/** Shape of task entity row stored in KanbanCardData.Data. */
export interface KanbanTaskData {
    ID: string;
    Name: string;
    Description: string | null;
    Status: string;
    Priority: string;
    DueAt: string | null;
    PercentComplete: number | null;
    HoursEstimated: number | null;
    ParentID: string | null;
    PendingSuggestionCount?: number;
    PendingSuggestionFields?: string[];
    PendingSuggestionTooltip?: string;
}

/**
 * Event emitted after a drag-and-drop status change has been persisted.
 */
export interface AfterKanbanStatusChangeEvent {
    TaskID: string;
    NewStatus: string;
    Card?: KanbanCardData;
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
    @Input() Provider: IMetadataProvider | null = null;
    @Input() CategoryID: string | null = null;
    @Input() ExtraFilter: string | null = null;
    @Input() ReadOnly = false;

    private _pendingSuggestionsOnly = false;
    private isInitialized = false;

    @Input()
    get PendingSuggestionsOnly(): boolean {
        return this._pendingSuggestionsOnly;
    }
    set PendingSuggestionsOnly(value: boolean) {
        const next = Boolean(value);
        if (next !== this._pendingSuggestionsOnly) {
            this._pendingSuggestionsOnly = next;
            if (this.isInitialized) {
                this.rebuildCards();
                this.cdr.markForCheck();
            }
        }
    }

    public get ProviderToUse(): IMetadataProvider {
        return this.Provider ?? Metadata.Provider;
    }

    @Output() BeforeStatusChange = new EventEmitter<BeforeKanbanStatusChangeEvent>();
    @Output() AfterStatusChange = new EventEmitter<AfterKanbanStatusChangeEvent>();
    @Output() TaskClicked = new EventEmitter<string>();
    /** The clicked card's id and title. `TaskClicked` stays the id. */
    @Output() TaskRowClicked = new EventEmitter<TaskClickRow>();
    @Output() TaskDoubleClicked = new EventEmitter<string>();

    columns: KanbanColumnDef[] = [
        { Key: 'Open',       Label: 'Open',        Color: 'var(--mj-status-info)' },
        { Key: 'InProgress', Label: 'In Progress',  Color: 'var(--mj-brand-primary)' },
        { Key: 'Blocked',    Label: 'Blocked',      Color: 'var(--mj-status-error)' },
        { Key: 'Completed',  Label: 'Completed',    Color: 'var(--mj-status-success)' },
    ];

    cards: KanbanCardData[] = [];
    /** @internal Unfiltered task rows loaded from the server. */
    rawTasks: KanbanTaskData[] = [];
    /** @internal True when `MJ: Field Suggestions` is available on the host. */
    fieldSuggestionsAvailable = false;
    /** @internal Per-task pending suggestion summaries keyed by normalized task UUID. */
    pendingSuggestionsByTask = new Map<string, TaskPendingSuggestionsSummary>();
    /** @internal Shown when a drag's status save is refused. The card snaps back. */
    moveError = '';

    private cdr = inject(ChangeDetectorRef);

    ngOnInit(): void {
        this.isInitialized = true;
        this.LoadTasks();
    }

    ngOnChanges(changes: SimpleChanges): void {
        const filterChanged = (changes['ExtraFilter'] && !changes['ExtraFilter'].firstChange)
            || (changes['CategoryID'] && !changes['CategoryID'].firstChange);
        if (filterChanged) this.LoadTasks();
    }

    Refresh(): void { this.LoadTasks(); }

    private createRunView(): RunView {
        const p = this.ProviderToUse;
        if (p && typeof (p as Partial<IRunViewProvider>).RunView === 'function') {
            return RunView.FromMetadataProvider(p);
        }
        return new RunView();
    }

    async LoadTasks(bypassCache: boolean = false): Promise<void> {
        const rv = this.createRunView();
        const filters: string[] = ["Status <> 'Cancelled'"];
        if (this.CategoryID) filters.push(`CategoryID = '${this.CategoryID}'`);
        if (this.ExtraFilter) filters.push(this.ExtraFilter);

        const result = await rv.RunView<KanbanTaskData>({
            EntityName: 'MJ_BizApps_Tasks: Tasks',
            ExtraFilter: filters.join(' AND '),
            OrderBy: 'Sequence ASC',
            ResultType: 'simple',
            // Bypass cache on post-mutation reloads (e.g. after drag status change)
            // so the board reflects the change immediately.
            BypassCache: bypassCache,
        });

        this.rawTasks = result?.Results ?? [];
        const suggestions = await TaskFieldSuggestionsHelper.LoadPendingSuggestions(this.ProviderToUse, {
            taskIds: this.rawTasks.map((r) => r.ID),
        });
        this.fieldSuggestionsAvailable = suggestions.available;
        this.pendingSuggestionsByTask = suggestions.byTaskId;

        this.rebuildCards();
        this.cdr.markForCheck();
    }

    rebuildCards(): void {
        const mapToUse = this.pendingSuggestionsByTask.size > 0 ? this.pendingSuggestionsByTask : undefined;
        const visibleTasks = FilterTasksByPendingSuggestions(
            this.rawTasks,
            this._pendingSuggestionsOnly,
            mapToUse ?? this.pendingSuggestionsByTask,
        );

        this.cards = visibleTasks.map((r) => {
            const summary = this.pendingSuggestionsByTask.get(NormalizeUUID(r.ID));
            const pendingCount = summary?.pendingCount ?? 0;
            const suggestionTooltip = summary ? FormatPendingSuggestionTooltip(summary) : '';
            const dueLabel = r.DueAt
                ? new Date(r.DueAt).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
                : '';
            const footerParts: string[] = [];
            if (dueLabel) {
                footerParts.push(dueLabel);
            }
            if (pendingCount > 0 && suggestionTooltip) {
                footerParts.push(suggestionTooltip);
            }
            const enriched: KanbanTaskData = {
                ...r,
                PendingSuggestionCount: pendingCount,
                PendingSuggestionFields: summary ? [...summary.fieldNames] : [],
                PendingSuggestionTooltip: suggestionTooltip,
            };

            return {
                ID: r.ID,
                Title: r.Name,
                Subtitle: r.Description || undefined,
                ColumnKey: r.Status,
                Color: PRIORITY_COLORS[r.Priority] || undefined,
                BadgeText: r.Priority,
                BadgeColor: PRIORITY_BADGE_COLORS[r.Priority] || undefined,
                FooterText: footerParts.length > 0 ? footerParts.join(' · ') : undefined,
                Data: enriched,
            };
        });
    }

    async onCardMoved(event: KanbanCardMovedEvent): Promise<void> {
        const before = new BeforeKanbanStatusChangeEvent(event.Card.ID, event.FromColumn, event.ToColumn, event.Card);
        this.BeforeStatusChange.emit(before);
        if (before.Cancel) return;

        const entity = await this.ProviderToUse.GetEntityObject<mjBizAppsTasksTaskEntity>('MJ_BizApps_Tasks: Tasks');
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

        this.AfterStatusChange.emit({ TaskID: event.Card.ID, NewStatus: event.ToColumn, Card: event.Card });
        await this.LoadTasks(true);
    }

    onCardClicked(card: KanbanCardData): void {
        this.TaskClicked.emit(card.ID);
        this.TaskRowClicked.emit({ ID: card.ID, Name: card.Title });
    }

    onCardDoubleClicked(card: KanbanCardData): void {
        this.TaskDoubleClicked.emit(card.ID);
    }
}
