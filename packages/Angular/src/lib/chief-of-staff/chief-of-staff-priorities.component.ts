import { ChangeDetectionStrategy, ChangeDetectorRef, Component, OnDestroy, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Subject } from 'rxjs';
import { debounceTime, filter, takeUntil } from 'rxjs/operators';
import { BaseEntity, LogError, RunView, type BaseEntityEvent } from '@memberjunction/core';
import type { ResourceData } from '@memberjunction/core-entities';
import { MJEventType, MJGlobal, RegisterClass, UUIDSet, type MJEvent } from '@memberjunction/global';
import { BaseResourceComponent } from '@memberjunction/ng-shared';
import {
    MJButtonDirective,
    MJEmptyStateComponent,
    MJFilterChipComponent,
    MJPageBodyComponent,
    MJPageHeaderComponent,
    MJPageLayoutComponent,
    MJPageSearchComponent,
    MJRefreshButtonComponent,
    MJStatBadgeComponent,
} from '@memberjunction/ng-ui-components';
import type { TaskEntity } from '@mj-biz-apps/tasks-entities';
import {
    BuildPrioritiesAgentContext,
    BuildPrioritySummary,
    FilterPriorityCards,
    GetTaskPriorityClass,
    HEALTH_FILTERS,
    IsHealthFilter,
    LoadTaskAssignees,
    PEOPLE_ENTITY_NAME,
    ResolvePersonTaskScope,
    ResolvePriorityObjectiveByIDOrName,
    TASK_ASSIGNMENTS_ENTITY_NAME,
    TASKS_ENTITY_NAME,
    type HealthFilter,
    type PriorityObjectiveCardViewModel,
    type PrioritySummary,
    type PriorityTaskRow,
    type TaskHealthStatus,
} from '@mj-biz-apps/tasks-core';
import { NO_PERSON_MESSAGE, PERSON_LOOKUP_FAILED_MESSAGE, ResolveCurrentPersonID } from '../current-person';
import { OpenTaskRecord } from '../open-task-record';

/** The Tasks view columns the page reads (see `PriorityTaskRow`); the view has no IsPriority column. */
const TASK_FIELDS: string[] = [
    'ID', 'ParentID', 'RootParentID', 'Name', 'Description', 'Status', 'Priority', 'HealthStatus', 'ConfidenceScore',
    'PercentComplete', 'CheckInCadence', 'PlanningPeriod', 'BaselineValue', 'TargetValue', 'CurrentValue',
    'UnitOfMeasure', 'MetricDirection', 'DueAt', 'LastCheckInAt', 'NextCheckInDueAt', 'TypeID', 'Type',
    'CreatedByPersonID', 'CreatedByPerson',
];

/** Entities whose change reloads the page: tasks and who they are assigned to. */
const LIVE_ENTITIES: readonly string[] = [TASKS_ENTITY_NAME, TASK_ASSIGNMENTS_ENTITY_NAME];

const HEALTH_LABELS: Readonly<Record<HealthFilter, string>> = {
    all: 'All',
    OnTrack: 'On Track',
    AtRisk: 'At Risk',
    OffTrack: 'Off Track',
    Completed: 'Completed',
    Paused: 'Paused',
};

/** A client tool this page registers for the co-agent. */
interface PageClientTool {
    Name: string;
    Description: string;
    ParameterSchema: Record<string, unknown>;
    Handler: (params: Record<string, unknown>) => Promise<unknown>;
}

/**
 * "Priorities & To-dos": the page the Tasks app adds to the Chief of Staff application.
 *
 * Shown as a nav item of the Chief of Staff app through the `NavItem.bizapps-tasks.chief-of-staff`
 * application setting this app installs; core's Chief of Staff never references it. It lists the
 * signed-in person's open to-dos and the priority objectives in their scope (see
 * `ResolvePersonTaskScope`), with milestones, assignees and progress.
 */
@Component({
    selector: 'bizapps-chief-of-staff-priorities',
    standalone: true,
    imports: [
        CommonModule,
        MJButtonDirective,
        MJEmptyStateComponent,
        MJFilterChipComponent,
        MJPageBodyComponent,
        MJPageHeaderComponent,
        MJPageLayoutComponent,
        MJPageSearchComponent,
        MJRefreshButtonComponent,
        MJStatBadgeComponent,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
    templateUrl: './chief-of-staff-priorities.component.html',
    styleUrls: ['./chief-of-staff-priorities.component.css'],
})
@RegisterClass(BaseResourceComponent, 'BizAppsTasksChiefOfStaffPriorities')
export class ChiefOfStaffPrioritiesResource extends BaseResourceComponent implements OnInit, OnDestroy {
    private cdr = inject(ChangeDetectorRef);
    protected override destroy$ = new Subject<void>();

    public IsLoading = true;
    public Banner: { Type: 'success' | 'error'; Message: string } | null = null;
    /** Set when the signed-in user has no active People record, or the lookup failed. */
    public PersonMessage: string | null = null;
    public Summary: PrioritySummary = BuildPrioritySummary([]);
    public HealthFilter: HealthFilter = 'all';
    public SearchText = '';
    public BusyTodoID: string | null = null;
    public readonly HealthFilterOptions = HEALTH_FILTERS.map((value) => ({ Value: value, Label: HEALTH_LABELS[value] }));

    private currentPersonID: string | null = null;
    private readonly expanded = new UUIDSet();
    private initialParamsApplied = false;
    private liveReloadPending = false;

    public get FilteredCards(): PriorityObjectiveCardViewModel[] {
        return FilterPriorityCards(this.Summary.Cards, this.HealthFilter, this.SearchText);
    }

    public get HasFilter(): boolean {
        return this.HealthFilter !== 'all' || this.SearchText.trim().length > 0;
    }

    async ngOnInit(): Promise<void> {
        super.ngOnInit();
        this.applyQueryParams(this.GetQueryParams());
        this.initialParamsApplied = true;
        await this.Load();
        this.navigationService.SetAgentClientTools(this, this.agentTools());
        this.navigationService.ResourceReattached$.pipe(filter((c) => c === this), takeUntil(this.destroy$)).subscribe(() => this.publishAgentContext());
        this.subscribeToLiveChanges();
        this.NotifyLoadComplete();
    }

    override ngOnDestroy(): void {
        super.ngOnDestroy();
        this.destroy$.next();
        this.destroy$.complete();
    }

    async GetResourceDisplayName(_data: ResourceData): Promise<string> {
        return 'Priorities & To-dos';
    }

    async GetResourceIconClass(_data: ResourceData): Promise<string> {
        return 'fa-solid fa-bullseye';
    }

    protected override OnQueryParamsChanged(params: Record<string, string>, _source: 'popstate' | 'deeplink'): void {
        this.applyQueryParams(params);
        this.publishAgentContext();
        this.cdr.markForCheck();
    }

    /** Loads the signed-in person's scoped tasks and their assignees. */
    public async Load(): Promise<void> {
        this.IsLoading = true;
        this.cdr.markForCheck();
        try {
            const provider = this.ProviderToUse;
            const personID = await this.resolvePerson();
            if (!personID) {
                this.Summary = BuildPrioritySummary([]);
                return;
            }
            const peopleEntity = provider.Entities.find((e) => e.Name === PEOPLE_ENTITY_NAME);
            if (!peopleEntity) {
                throw new Error(`The "${PEOPLE_ENTITY_NAME}" entity is not installed.`);
            }
            const rv = RunView.FromMetadataProvider(provider);
            const scope = await ResolvePersonTaskScope(rv, personID, peopleEntity.ID);
            const tasks = await rv.RunView<PriorityTaskRow>({
                EntityName: TASKS_ENTITY_NAME,
                ExtraFilter: scope.Filter,
                Fields: TASK_FIELDS,
                OrderBy: 'DueAt ASC, Name ASC',
                ResultType: 'simple',
            });
            if (!tasks.Success) {
                throw new Error(tasks.ErrorMessage ?? 'Failed to load tasks.');
            }
            const rows = tasks.Results ?? [];
            const assignees = await LoadTaskAssignees(rv, peopleEntity.ID, rows.map((t) => t.ID));
            this.Summary = BuildPrioritySummary(rows, new Date(), { Assignees: assignees, CurrentPersonID: personID });
        } catch (err) {
            const msg = err instanceof Error ? err.message : String(err);
            LogError(`Chief of Staff priorities: ${msg}`);
            this.showBanner('error', `Failed to load priorities: ${msg}`);
        } finally {
            this.IsLoading = false;
            this.publishAgentContext();
            this.cdr.markForCheck();
        }
    }

    /** The signed-in user's People ID, or null with {@link PersonMessage} explaining why. */
    private async resolvePerson(): Promise<string | null> {
        try {
            this.currentPersonID = await ResolveCurrentPersonID(this.ProviderToUse.CurrentUser);
            this.PersonMessage = this.currentPersonID ? null : NO_PERSON_MESSAGE;
        } catch (err) {
            LogError(err);
            this.currentPersonID = null;
            this.PersonMessage = PERSON_LOOKUP_FAILED_MESSAGE;
        }
        return this.currentPersonID;
    }

    // ── Filters and search ───────────────────────────────────────────────────────────

    public OnHealthFilterChange(value: HealthFilter): void {
        this.HealthFilter = value;
        this.afterFilterChange();
    }

    public OnSearchChange(value: string): void {
        this.SearchText = value;
        this.afterFilterChange();
    }

    public ClearFilters(): void {
        this.HealthFilter = 'all';
        this.SearchText = '';
        this.afterFilterChange();
    }

    private afterFilterChange(): void {
        this.syncQueryParams();
        this.publishAgentContext();
        this.cdr.markForCheck();
    }

    private applyQueryParams(params: Record<string, string>): void {
        this.HealthFilter = IsHealthFilter(params['health']) ? params['health'] : 'all';
        this.SearchText = params['search'] ?? '';
    }

    private syncQueryParams(): void {
        if (!this.initialParamsApplied) {
            return;
        }
        this.UpdateQueryParams({
            health: this.HealthFilter === 'all' ? null : this.HealthFilter,
            search: this.SearchText.trim().length > 0 ? this.SearchText.trim() : null,
        });
    }

    // ── Cards and to-dos ─────────────────────────────────────────────────────────────

    public IsExpanded(taskID: string): boolean {
        return this.expanded.Has(taskID);
    }

    public ToggleExpanded(taskID: string): void {
        if (this.expanded.Has(taskID)) {
            this.expanded.Delete(taskID);
        } else {
            this.expanded.Add(taskID);
        }
        this.cdr.markForCheck();
    }

    public OpenTask(taskID: string, event?: Event): void {
        event?.stopPropagation();
        OpenTaskRecord(taskID);
    }

    /** Marks a to-do Completed; the Task entity stamps CompletedAt, and the live reload drops the row. */
    public async MarkTodoDone(task: PriorityTaskRow, event?: Event): Promise<void> {
        event?.stopPropagation();
        if (this.BusyTodoID) {
            return;
        }
        this.BusyTodoID = task.ID;
        this.cdr.markForCheck();
        try {
            const provider = this.ProviderToUse;
            const entity = await provider.GetEntityObject<TaskEntity>(TASKS_ENTITY_NAME, provider.CurrentUser);
            if (!(await entity.Load(task.ID))) {
                throw new Error('The task could not be loaded.');
            }
            entity.Status = 'Completed';
            if (!(await entity.Save())) {
                throw new Error(entity.LatestResult?.CompleteMessage ?? 'The task could not be saved.');
            }
            this.showBanner('success', `Marked "${task.Name}" done.`);
            await this.Load();
        } catch (err) {
            this.showBanner('error', `Could not mark "${task.Name}" done: ${err instanceof Error ? err.message : String(err)}`);
        } finally {
            this.BusyTodoID = null;
            this.cdr.markForCheck();
        }
    }

    public IsCurrentPerson(personID: string): boolean {
        return !!this.currentPersonID && personID.toLowerCase() === this.currentPersonID.toLowerCase();
    }

    public PriorityClass(priority: string | null): string {
        return GetTaskPriorityClass(priority);
    }

    public HealthLabel(health: TaskHealthStatus): string {
        return HEALTH_LABELS[health];
    }

    public HealthClass(health: TaskHealthStatus): string {
        return health.toLowerCase();
    }

    public DismissBanner(): void {
        this.Banner = null;
        this.cdr.markForCheck();
    }

    private showBanner(type: 'success' | 'error', message: string): void {
        this.Banner = { Type: type, Message: message };
        this.cdr.markForCheck();
    }

    // ── Live reload ──────────────────────────────────────────────────────────────────

    /** Reloads once per burst of task or assignment changes; a detached tab reloads when shown again. */
    private subscribeToLiveChanges(): void {
        MJGlobal.Instance.GetEventListener(false).pipe(
            filter((event) => IsTasksEntityChange(event)),
            debounceTime(750),
            takeUntil(this.destroy$),
        ).subscribe(() => {
            if (this.navigationService.IsResourceDetached(this)) {
                this.liveReloadPending = true;
                return;
            }
            void this.Load();
        });
        this.navigationService.ResourceReattached$.pipe(
            filter((c) => c === this && this.liveReloadPending),
            takeUntil(this.destroy$),
        ).subscribe(() => {
            this.liveReloadPending = false;
            void this.Load();
        });
    }

    // ── Agent context and tools ──────────────────────────────────────────────────────

    private publishAgentContext(): void {
        if (this.navigationService.IsResourceDetached(this)) {
            return;
        }
        this.navigationService.SetAgentContext(this, BuildPrioritiesAgentContext(this.Summary, this.HealthFilter, this.SearchText));
    }

    private agentTools(): PageClientTool[] {
        return [
            {
                Name: 'FilterChiefOfStaffPriorities',
                Description: "Filter the priority objectives on the Priorities & To-dos page by health ('all', 'OnTrack', 'AtRisk', 'OffTrack', 'Completed', 'Paused') and search text.",
                ParameterSchema: {
                    type: 'object',
                    properties: {
                        health: { type: 'string', enum: [...HEALTH_FILTERS] },
                        query: { type: 'string', description: 'Search text; empty string clears.' },
                    },
                },
                Handler: async (params) => {
                    const health = params['health'];
                    if (health !== undefined && !IsHealthFilter(health)) {
                        return { Success: false, ErrorMessage: `health must be one of ${HEALTH_FILTERS.join(', ')}` };
                    }
                    const query = params['query'];
                    if (query !== undefined && typeof query !== 'string') {
                        return { Success: false, ErrorMessage: 'query must be a string' };
                    }
                    if (health !== undefined) this.HealthFilter = health;
                    if (query !== undefined) this.SearchText = query;
                    this.afterFilterChange();
                    return { Success: true, Data: { HealthFilter: this.HealthFilter, SearchText: this.SearchText, VisibleObjectiveCount: this.FilteredCards.length } };
                },
            },
            {
                Name: 'InspectChiefOfStaffPriority',
                Description: 'Expand one priority objective on the Priorities & To-dos page, by ID or name.',
                ParameterSchema: {
                    type: 'object',
                    properties: { objective: { type: 'string', description: 'Objective ID or name' } },
                    required: ['objective'],
                },
                Handler: async (params) => {
                    const match = ResolvePriorityObjectiveByIDOrName(this.Summary.Cards, params['objective']);
                    if (!match.ok) {
                        return { Success: false, ErrorMessage: match.error };
                    }
                    this.expanded.Add(match.value.Task.ID);
                    this.cdr.markForCheck();
                    return {
                        Success: true,
                        Data: {
                            Name: match.value.Task.Name,
                            Health: match.value.EffectiveHealth,
                            PercentComplete: match.value.EffectivePercentComplete,
                            MilestoneCount: match.value.Subtasks.length,
                            CompletedMilestoneCount: match.value.CompletedSubtaskCount,
                        },
                    };
                },
            },
            {
                Name: 'RefreshChiefOfStaffPriorities',
                Description: 'Reload the priority objectives and to-dos from the server.',
                ParameterSchema: { type: 'object', properties: {} },
                Handler: async () => {
                    await this.Load();
                    return { Success: true, Data: { PriorityObjectiveCount: this.Summary.PriorityObjectiveCount, OpenTodoCount: this.Summary.OpenTodoCount } };
                },
            },
        ];
    }
}

/** True for a save, delete or remote invalidation of a task or a task assignment. */
export function IsTasksEntityChange(event: MJEvent): boolean {
    if (event.event !== MJEventType.ComponentEvent || event.eventCode !== BaseEntity.BaseEventCode || !event.args) {
        return false;
    }
    const args = event.args as BaseEntityEvent;
    const name = args.type === 'remote-invalidate'
        ? args.entityName
        : args.type === 'save' || args.type === 'delete' ? args.baseEntity?.EntityInfo?.Name : null;
    return !!name && LIVE_ENTITIES.some((n) => n.toLowerCase() === name.trim().toLowerCase());
}

export function LoadChiefOfStaffPrioritiesResource(): void {
    // Intentionally empty: forces inclusion of the @RegisterClass side effect.
}
