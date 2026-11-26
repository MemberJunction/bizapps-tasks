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
    ViewChild,
    inject,
} from '@angular/core';
import { LogError, Metadata, type IMetadataProvider } from '@memberjunction/core';
import { MJEmptyStateComponent } from '@memberjunction/ng-ui-components';
import { TaskListComponent, TaskRow, BeforeTaskSelectedEvent, BeforeStatusChangeEvent } from '../task-list/task-list.component';
import { CurrentUserRoleIDs, LoadAssignedTaskIDs } from '../../role-assignees';

/**
 * "My Tasks" convenience wrapper around {@link TaskListComponent}.
 *
 * Automatically resolves task IDs assigned to the provided {@link PersonID},
 * or to an MJ role the user holds, via a first-class `RunView` on
 * `MJ_BizApps_Tasks: Task Assignments` (RLS-safe — never emits raw
 * `vwTaskAssignments` subqueries) and passes them to {@link TaskListComponent}.
 *
 * All {@link TaskListComponent} events are re-emitted so consuming apps can
 * wire up the same Before/After patterns.
 *
 * @example
 * ```html
 * <bizapps-my-tasks
 *     [PersonID]="currentUserPersonID"
 *     [ShowCreateButton]="true"
 *     (AfterTaskSelected)="openTaskDetail($event)"
 *     (CreateTask)="openNewTaskPanel()">
 * </bizapps-my-tasks>
 * ```
 */
@Component({
    selector: 'bizapps-my-tasks',
    standalone: true,
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [TaskListComponent, MJEmptyStateComponent],
    template: `
        <div class="my-tasks">
            <h3 class="my-tasks-title">My Tasks</h3>
            @if (loadError) {
                <mj-empty-state
                    Icon="fa-solid fa-triangle-exclamation"
                    Title="Unable to load your tasks"
                    [Message]="loadError"
                    Variant="error"
                    Size="compact"
                    ActionText="Retry"
                    ActionIcon="fa-solid fa-rotate-right"
                    (Action)="Refresh()">
                </mj-empty-state>
            } @else if (assignmentsLoading && !assignmentsLoaded) {
                <div class="my-tasks-loading">Loading tasks...</div>
            } @else {
                <bizapps-task-list
                    #taskList
                    [Provider]="Provider"
                    [PreloadedTaskIds]="assignedTaskIds"
                    [PendingSuggestionsOnly]="PendingSuggestionsOnly"
                    (PendingSuggestionsOnlyChange)="onPendingSuggestionsOnlyChange($event)"
                    [ShowCreateButton]="ShowCreateButton"
                    [Compact]="Compact"
                    (BeforeTaskSelected)="BeforeTaskSelected.emit($event)"
                    (AfterTaskSelected)="AfterTaskSelected.emit($event)"
                    (TaskDoubleClicked)="TaskDoubleClicked.emit($event)"
                    (BeforeStatusChange)="BeforeStatusChange.emit($event)"
                    (AfterStatusChange)="AfterStatusChange.emit($event)"
                    (CreateTask)="CreateTask.emit()">
                </bizapps-task-list>
            }
        </div>
    `,
    styles: [`
        .my-tasks-title {
            margin: 0 0 8px; font-size: 1.1rem; font-weight: var(--mj-font-semibold); color: var(--mj-text-primary);
        }
        .my-tasks-loading {
            padding: 28px; text-align: center; color: var(--mj-text-muted); font-size: var(--mj-text-sm, 14px);
        }
    `]
})
export class MyTasksComponent implements OnInit, OnChanges {
    // ── Inputs ──────────────────────────────────────────────

    /** Optional metadata/data provider forwarded to {@link TaskListComponent}. */
    @Input() Provider: IMetadataProvider | null = null;

    private _pendingSuggestionsOnly = false;

    /** When true, filters My Tasks to items with unresolved Field Suggestions. */
    @Input()
    get PendingSuggestionsOnly(): boolean {
        return this._pendingSuggestionsOnly;
    }
    set PendingSuggestionsOnly(value: boolean) {
        this._pendingSuggestionsOnly = Boolean(value);
    }

    @Output() PendingSuggestionsOnlyChange = new EventEmitter<boolean>();

    /** @internal */
    onPendingSuggestionsOnlyChange(next: boolean): void {
        this._pendingSuggestionsOnly = Boolean(next);
        this.PendingSuggestionsOnlyChange.emit(this._pendingSuggestionsOnly);
    }

    /**
     * The Person ID of the current user. Used to filter tasks via
     * TaskAssignment. Required — if empty, no tasks will be shown.
     */
    @Input() PersonID: string = '';

    /**
     * MJ role IDs whose assignments count as this person's (bc-aidp-next-golive#442). When null (the
     * default), the signed-in user's roles are used; pass `[]` to list only the person's own assignments.
     */
    @Input() RoleIDs: string[] | null = null;

    /**
     * Whether to show the "+ New Task" button in the embedded list toolbar.
     * @default false
     */
    @Input() ShowCreateButton = false;

    /**
     * Compact mode — reduces padding and hides descriptions.
     * Useful for sidebar or widget embedding.
     * @default false
     */
    @Input() Compact = false;

    // ── Outputs ─────────────────────────────────────────────

    /**
     * Re-emitted from the inner {@link TaskListComponent}.
     * Cancellable — set `event.Cancel = true` to prevent the selection.
     */
    @Output() BeforeTaskSelected = new EventEmitter<BeforeTaskSelectedEvent>();

    /**
     * Re-emitted from the inner {@link TaskListComponent}.
     * Payload is the selected {@link TaskRow}.
     */
    @Output() AfterTaskSelected = new EventEmitter<TaskRow>();

    /**
     * Re-emitted from the inner {@link TaskListComponent} when double-clicked.
     */
    @Output() TaskDoubleClicked = new EventEmitter<TaskRow>();

    /** Re-emitted from the inner {@link TaskListComponent}. Cancellable. */
    @Output() BeforeStatusChange = new EventEmitter<BeforeStatusChangeEvent>();

    /** Re-emitted from the inner {@link TaskListComponent}. */
    @Output() AfterStatusChange = new EventEmitter<TaskRow>();

    /** Re-emitted when the user clicks "+ New Task" in the embedded list. */
    @Output() CreateTask = new EventEmitter<void>();

    // ── View References ─────────────────────────────────────

    /** @internal */
    @ViewChild('taskList') taskList?: TaskListComponent;

    // ── State ───────────────────────────────────────────────

    /** Deduplicated Task IDs resolved from `MJ_BizApps_Tasks: Task Assignments`. */
    public assignedTaskIds: string[] = [];
    public assignmentsLoaded = false;
    public assignmentsLoading = false;
    public loadError: string | null = null;

    private readonly cdr = inject(ChangeDetectorRef, { optional: true });
    private loadSeq = 0;

    public get ProviderToUse(): IMetadataProvider {
        return this.Provider ?? Metadata.Provider;
    }

    // ── Lifecycle ───────────────────────────────────────────

    public ngOnInit(): void {
        void this.resolveAssignedTaskIds(true);
    }

    public ngOnChanges(changes: SimpleChanges): void {
        if (
            (changes['PersonID'] && !changes['PersonID'].firstChange) ||
            (changes['RoleIDs'] && !changes['RoleIDs'].firstChange) ||
            (changes['Provider'] && !changes['Provider'].firstChange)
        ) {
            void this.resolveAssignedTaskIds(true);
        }
    }

    // ── Public Methods ──────────────────────────────────────

    /**
     * Re-resolves task assignments from the server and reloads the inner task list.
     */
    public async Refresh(): Promise<void> {
        const ok = await this.resolveAssignedTaskIds(true);
        if (ok && this.taskList) {
            this.taskList.PreloadedTaskIds = this.assignedTaskIds;
            await this.taskList.Refresh();
        }
    }

    // ── Internal ────────────────────────────────────────────

    private async resolveAssignedTaskIds(bypassCache: boolean): Promise<boolean> {
        const seq = ++this.loadSeq;
        if (!this.PersonID) {
            this.assignedTaskIds = [];
            this.loadError = null;
            this.assignmentsLoaded = true;
            this.assignmentsLoading = false;
            this.cdr?.markForCheck();
            return true;
        }

        this.assignmentsLoading = true;
        this.loadError = null;
        this.cdr?.markForCheck();

        try {
            const roleIDs = this.RoleIDs ?? CurrentUserRoleIDs(this.ProviderToUse?.CurrentUser);
            const res = await LoadAssignedTaskIDs(this.PersonID, roleIDs, this.ProviderToUse, bypassCache);
            if (seq !== this.loadSeq) return false;

            if (!res.Success) {
                const msg = res.ErrorMessage || 'Failed to load task assignments.';
                LogError(msg);
                this.loadError = msg;
                this.assignedTaskIds = [];
                this.assignmentsLoaded = true;
                return false;
            }

            this.assignedTaskIds = res.TaskIDs;
            this.assignmentsLoaded = true;
            return true;
        } catch (err) {
            if (seq !== this.loadSeq) return false;
            LogError(err);
            this.loadError = err instanceof Error ? err.message : 'Failed to load task assignments.';
            this.assignedTaskIds = [];
            this.assignmentsLoaded = true;
            return false;
        } finally {
            if (seq === this.loadSeq) {
                this.assignmentsLoading = false;
                this.cdr?.markForCheck();
            }
        }
    }
}
