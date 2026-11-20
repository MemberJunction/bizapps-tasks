import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    Input,
    OnChanges,
    OnInit,
    SimpleChanges,
    inject,
} from '@angular/core';
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';
import { EscapeSQLString } from '@memberjunction/global';
import { BaseFormComponent, BaseFormsModule } from '@memberjunction/ng-base-forms';
import { NavigationService, SharedService } from '@memberjunction/ng-shared';
import {
    MJCardComponent,
    MJCardFooterDirective,
    MJCardGridComponent,
    MJCardToolsDirective,
    MJProgressBarComponent,
} from '@memberjunction/ng-ui-components';
import {
    ResolveTaskUiArchetype,
    TaskOrchestrationService,
    TaskService,
} from '@mj-biz-apps/tasks-core';
import type {
    mjBizAppsTasksTaskCheckInEntity,
    mjBizAppsTasksTaskEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    TaskAdaptiveSpotlightComponent,
    type TaskAdaptiveSpotlightInput,
    type TaskApprovalActionEvent,
    type TaskOkrCheckInSubmitEvent,
    type TaskWidgetLinkedRecord,
} from '@mj-biz-apps/tasks-ng-widgets';
import { ResolveCurrentPersonID } from '../../current-person';
import { LoadTaskRecordLinks, type TaskRecordLink } from '../../task-record-links';

interface DependencySummary {
    ID: string;
    DependencyType: string;
    DependsOnTaskID: string;
    DependsOnTaskName: string;
    DependsOnTaskStatus: string;
    IsBlocking: boolean;
}

interface ActivitySummary {
    ID: string;
    ActivityType: string;
    Description: string;
    CreatedAt: Date;
    User: string;
    EntityName?: string;
    RecordID?: string;
}

/**
 * Context-Adaptive Living Task Overview (`slot: 'before-fields'`).
 *
 * - Renders `<mjt-adaptive-spotlight>` at top (collapses to 0px on simple General tasks!)
 * - Pure official MJ semantic `--mj-*` tokens (zero hardcoded dark fallback hexes)
 * - Uses MJ's `<mj-card-grid>`, `<mj-card>`, `<mj-progress-bar>`, and `mjRecordLink`
 * - Truthful critical-path status ("Blocked" vs "Clear" — never hardcoded!)
 */
@Component({
    standalone: true,
    selector: 'mjt-task-overview',
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [
        BaseFormsModule,
        MJCardGridComponent,
        MJCardComponent,
        MJCardToolsDirective,
        MJCardFooterDirective,
        MJProgressBarComponent,
        TaskAdaptiveSpotlightComponent,
    ],
    template: `
        <div class="mjt-overview">
            <mjt-adaptive-spotlight
                [Data]="SpotlightData"
                [Busy]="Busy"
                (ApprovalSubmitted)="OnApprovalSubmitted($event)"
                (CheckInSubmitted)="OnCheckInSubmitted($event)"
                (LinkedRecordClicked)="OnLinkedRecordClick($event)">
            </mjt-adaptive-spotlight>

            <mj-card-grid>
                <!-- Card 1: Subtasks & Execution Velocity -->
                <mj-card Title="Execution Velocity" Subtitle="Progress & Work Breakdown" Icon="fa-solid fa-bars-progress">
                    <ng-template mjCardTools>
                        <span class="mjt-code">{{ PercentComplete }}% Complete</span>
                    </ng-template>

                    <div class="mjt-progress-section">
                        <div class="mjt-progress-row">
                            <div class="mjt-progress-header">
                                <span>Task Completion</span>
                                <span class="mjt-code">{{ PercentComplete }}%</span>
                            </div>
                            <mj-progress-bar [Value]="PercentComplete"></mj-progress-bar>
                        </div>

                        @if (TotalSubtasksCount > 0) {
                            <div class="mjt-progress-row">
                                <div class="mjt-progress-header">
                                    <span>Sub-tasks Completed</span>
                                    <span class="mjt-code">{{ CompletedSubtasksCount }} of {{ TotalSubtasksCount }}</span>
                                </div>
                                <mj-progress-bar [Value]="SubtaskPercent"></mj-progress-bar>
                            </div>
                        }
                    </div>

                    <ng-template mjCardFooter>
                        <div class="mjt-foot-metrics">
                            <div class="card-metric">
                                <span class="card-metric__label">Sub-tasks</span>
                                <span class="card-metric__val">{{ TotalSubtasksCount }} Total</span>
                            </div>
                            <div class="card-metric">
                                <span class="card-metric__label">Status</span>
                                <span class="card-metric__val">{{ Record?.Status || 'Open' }}</span>
                            </div>
                            <div class="card-metric">
                                <span class="card-metric__label">Priority</span>
                                <span class="card-metric__val">{{ Record?.Priority || 'Medium' }}</span>
                            </div>
                        </div>
                    </ng-template>
                </mj-card>

                <!-- Card 2: Dependencies & Blockers -->
                <mj-card Title="Dependencies & Blockers" Subtitle="Upstream Tasks & Path Health" Icon="fa-solid fa-link">
                    <ng-template mjCardTools>
                        <span class="mjt-code">{{ Dependencies.length }} Linked</span>
                    </ng-template>

                    <div class="mjt-deck">
                        @if (Dependencies.length > 0) {
                            @for (dep of Dependencies; track dep.ID) {
                                <div
                                    class="mjt-deck-item"
                                    mjRecordLink
                                    [EntityName]="'MJ_BizApps_Tasks: Tasks'"
                                    [RecordID]="dep.DependsOnTaskID"
                                    [DisplayName]="dep.DependsOnTaskName"
                                    [HandleClick]="false"
                                    (click)="OnDependencyClick(dep)">
                                    <div class="mjt-deck-item__left">
                                        <div class="mjt-deck-item__icon" [class.mjt-deck-item__icon--warn]="dep.IsBlocking">
                                            <i class="fa-solid" [class.fa-triangle-exclamation]="dep.IsBlocking" [class.fa-link]="!dep.IsBlocking" aria-hidden="true"></i>
                                        </div>
                                        <div class="mjt-deck-item__text">
                                            <h4>{{ dep.DependsOnTaskName }}</h4>
                                            <p>{{ dep.DependencyType }} &bull; {{ dep.DependsOnTaskStatus }}</p>
                                        </div>
                                    </div>
                                    <span class="mjt-code">{{ dep.IsBlocking ? 'Blocking' : 'Linked' }}</span>
                                </div>
                            }
                        } @else {
                            <div class="mjt-empty-state">No upstream dependencies linked to this task.</div>
                        }
                    </div>

                    <ng-template mjCardFooter>
                        <div class="mjt-foot-metrics">
                            <div class="card-metric">
                                <span class="card-metric__label">Dependencies</span>
                                <span class="card-metric__val">{{ Dependencies.length }}</span>
                            </div>
                            <div class="card-metric">
                                <span class="card-metric__label">Blockers</span>
                                <span class="card-metric__val" [style.color]="BlockerCount > 0 ? 'var(--mj-status-error-text)' : 'var(--mj-status-success-text)'">
                                    {{ BlockerCount }} Active
                                </span>
                            </div>
                            <div class="card-metric">
                                <span class="card-metric__label">Path Status</span>
                                <span class="card-metric__val" [style.color]="BlockerCount > 0 || Record?.Status === 'Blocked' ? 'var(--mj-status-error-text)' : 'var(--mj-status-success-text)'">
                                    {{ BlockerCount > 0 || Record?.Status === 'Blocked' ? 'Blocked' : 'Clear' }}
                                </span>
                            </div>
                        </div>
                    </ng-template>
                </mj-card>

                <!-- Card 3: Recent Activity -->
                <mj-card Title="Recent Activity" Subtitle="Changes & Audit Trail" Icon="fa-solid fa-clock-rotate-left">
                    <ng-template mjCardTools>
                        <span class="mjt-code">{{ Activities.length }} Events</span>
                    </ng-template>

                    <div class="mjt-timeline">
                        @if (Activities.length > 0) {
                            @for (act of Activities; track act.ID) {
                                <div class="mjt-timeline-item" (click)="OnActivityClick(act)">
                                    <div class="mjt-timeline-item__icon">
                                        <i class="fa-solid fa-bolt" aria-hidden="true"></i>
                                    </div>
                                    <div class="mjt-timeline-item__content">
                                        <h5>{{ act.ActivityType }}</h5>
                                        <p>{{ act.Description }} &bull; {{ act.User }}</p>
                                    </div>
                                </div>
                            }
                        } @else {
                            <div class="mjt-empty-state">No recent activity logged for this task yet.</div>
                        }
                    </div>

                    <ng-template mjCardFooter>
                        <div class="mjt-foot-metrics">
                            <div class="card-metric">
                                <span class="card-metric__label">Total Updates</span>
                                <span class="card-metric__val">{{ Activities.length }}</span>
                            </div>
                            <div class="card-metric">
                                <span class="card-metric__label">Created</span>
                                <span class="card-metric__val">{{ CreatedDateLabel }}</span>
                            </div>
                        </div>
                    </ng-template>
                </mj-card>
            </mj-card-grid>
        </div>
    `,
    styles: [`
        .mjt-overview {
            display: flex;
            flex-direction: column;
            gap: 14px;
            width: 100%;
        }
        .mjt-progress-section {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .mjt-progress-row {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .mjt-progress-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-secondary);
        }
        .mjt-deck {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .mjt-deck-item {
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            padding: 8px 12px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            cursor: pointer;
            transition: border-color 140ms ease, background 140ms ease;
        }
        .mjt-deck-item:hover {
            border-color: var(--mj-brand-primary);
            background: var(--mj-bg-surface-hover);
        }
        .mjt-deck-item__left {
            display: flex;
            align-items: center;
            gap: 10px;
            min-width: 0;
        }
        .mjt-deck-item__icon {
            width: 26px;
            height: 26px;
            border-radius: var(--mj-radius-sm, 6px);
            background: color-mix(in srgb, var(--mj-brand-primary) 12%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11.5px;
            flex-shrink: 0;
        }
        .mjt-deck-item__icon--warn {
            background: var(--mj-status-warning-bg);
            color: var(--mj-status-warning-text);
        }
        .mjt-deck-item__text {
            min-width: 0;
        }
        .mjt-deck-item__text h4 {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-primary);
            margin: 0;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .mjt-deck-item__text p {
            font-size: 11px;
            color: var(--mj-text-muted);
            margin: 2px 0 0;
        }
        .mjt-timeline {
            display: flex;
            flex-direction: column;
            gap: 6px;
            max-height: 210px;
            overflow-y: auto;
        }
        .mjt-timeline-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 6px 8px;
            border-radius: var(--mj-radius-sm, 6px);
            border: 1px solid transparent;
            cursor: pointer;
        }
        .mjt-timeline-item:hover {
            background: var(--mj-bg-surface-sunken);
            border-color: var(--mj-border-default);
        }
        .mjt-timeline-item__icon {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background: var(--mj-bg-surface-sunken);
            border: 1px solid var(--mj-border-default);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            color: var(--mj-brand-primary);
            flex-shrink: 0;
        }
        .mjt-timeline-item__content {
            flex: 1;
            min-width: 0;
        }
        .mjt-timeline-item__content h5 {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-primary);
            margin: 0;
        }
        .mjt-timeline-item__content p {
            font-size: 11px;
            color: var(--mj-text-secondary);
            margin: 2px 0 0;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .mjt-code {
            font-family: var(--mj-font-family-mono, monospace);
            font-size: 11.5px;
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-brand-primary);
        }
        .mjt-empty-state {
            font-size: var(--mj-text-xs, 12px);
            color: var(--mj-text-muted);
            padding: 14px;
            text-align: center;
            font-style: italic;
        }
        .mjt-foot-metrics {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 16px;
            width: 100%;
            flex-wrap: wrap;
        }
        .card-metric {
            display: flex;
            flex-direction: column;
            gap: 2px;
            min-width: 0;
        }
        .card-metric__label {
            font-size: 10.5px;
            font-weight: var(--mj-font-semibold, 600);
            text-transform: uppercase;
            letter-spacing: 0.04em;
            color: var(--mj-text-muted);
        }
        .card-metric__val {
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-primary);
        }
    `],
})
export class TaskOverviewComponent implements OnInit, OnChanges {
    @Input() public Record: mjBizAppsTasksTaskEntity | null = null;
    @Input() public FormComponent: BaseFormComponent | null = null;

    public TotalSubtasksCount = 0;
    public CompletedSubtasksCount = 0;
    public Dependencies: DependencySummary[] = [];
    public Activities: ActivitySummary[] = [];
    public SpotlightData: TaskAdaptiveSpotlightInput | null = null;
    public IsLoading = false;
    public Busy = false;

    private cdr = inject(ChangeDetectorRef);
    private navService = inject(NavigationService, { optional: true });
    private orchestration = new TaskOrchestrationService();

    public get PercentComplete(): number {
        return Math.round(this.Record?.PercentComplete ?? 0);
    }

    public get SubtaskPercent(): number {
        if (this.TotalSubtasksCount === 0) return this.PercentComplete;
        return Math.round((this.CompletedSubtasksCount / this.TotalSubtasksCount) * 100);
    }

    public get BlockerCount(): number {
        return this.Dependencies.filter((d) => d.IsBlocking).length;
    }

    public get CreatedDateLabel(): string {
        const raw = this.Record?.__mj_CreatedAt || this.Record?.StartedAt;
        if (!raw) return '—';
        return new Date(raw).toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    }

    public ngOnInit(): void {
        void this.LoadData();
    }

    public ngOnChanges(changes: SimpleChanges): void {
        if (changes['Record'] && !changes['Record'].firstChange) {
            void this.LoadData();
        }
    }

    public async LoadData(): Promise<void> {
        if (!this.Record?.ID) return;
        this.IsLoading = true;
        this.cdr.markForCheck();

        try {
            const id = EscapeSQLString(this.Record.ID);
            const [subtaskResult, depResult, actResult, typeResult, linksMap] = await Promise.all([
                new RunView().RunView<{ ID: string; Status: string }>({
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: `ParentID = '${id}'`,
                    Fields: ['ID', 'Status'],
                    ResultType: 'simple',
                }),
                new RunView().RunView<{ ID: string; DependencyType: string; DependsOnTaskID: string; DependsOnTask: string }>({
                    EntityName: 'MJ_BizApps_Tasks: Task Dependencies',
                    ExtraFilter: `TaskID = '${id}'`,
                    Fields: ['ID', 'DependencyType', 'DependsOnTaskID', 'DependsOnTask'],
                    ResultType: 'simple',
                }),
                new RunView().RunView<{
                    ID: string;
                    ActivityType: string;
                    Description: string | null;
                    __mj_CreatedAt: Date;
                    Person: string | null;
                }>({
                    EntityName: 'MJ_BizApps_Tasks: Task Activities',
                    ExtraFilter: `TaskID = '${id}'`,
                    OrderBy: '__mj_CreatedAt DESC',
                    MaxRows: 10,
                    ResultType: 'simple',
                }),
                this.Record.TypeID
                    ? new RunView().RunView<{
                          ID: string;
                          Name: string;
                          Code: string;
                          IsApproval: boolean;
                          OnCompleteAction: string | null;
                          OnRejectAction: string | null;
                          OnCancelAction: string | null;
                      }>({
                          EntityName: 'MJ_BizApps_Tasks: Task Types',
                          ExtraFilter: `ID = '${EscapeSQLString(this.Record.TypeID)}'`,
                          MaxRows: 1,
                          ResultType: 'simple',
                      })
                    : Promise.resolve(null),
                LoadTaskRecordLinks([this.Record.ID]).catch(() => new Map<string, TaskRecordLink[]>()),
            ]);

            const subs = subtaskResult?.Results ?? [];
            this.TotalSubtasksCount = subs.length;
            this.CompletedSubtasksCount = subs.filter((s) => s.Status === 'Completed').length;

            // Resolve actual status of upstream tasks for truthful blocking indicator
            const depRows = depResult?.Results ?? [];
            const depTaskIds = depRows.map((d) => `'${EscapeSQLString(d.DependsOnTaskID)}'`);
            const depStatusMap = new Map<string, string>();
            if (depTaskIds.length > 0) {
                const upstream = await new RunView().RunView<{ ID: string; Status: string }>({
                    EntityName: 'MJ_BizApps_Tasks: Tasks',
                    ExtraFilter: `ID IN (${depTaskIds.join(',')})`,
                    Fields: ['ID', 'Status'],
                    ResultType: 'simple',
                });
                for (const u of upstream?.Results ?? []) {
                    depStatusMap.set(u.ID.toLowerCase(), u.Status);
                }
            }

            this.Dependencies = depRows.map((d) => {
                const upStatus = depStatusMap.get(d.DependsOnTaskID.toLowerCase()) ?? 'Open';
                const isBlocking =
                    (d.DependencyType === 'FinishToStart' || d.DependencyType === 'StartToStart') &&
                    upStatus !== 'Completed';
                return {
                    ID: d.ID,
                    DependencyType: d.DependencyType,
                    DependsOnTaskID: d.DependsOnTaskID,
                    DependsOnTaskName: d.DependsOnTask || 'Linked Task',
                    DependsOnTaskStatus: upStatus,
                    IsBlocking: isBlocking,
                };
            });

            this.Activities = (actResult?.Results ?? []).map((a) => ({
                ID: a.ID,
                ActivityType: a.ActivityType,
                Description: a.Description || 'Task updated',
                CreatedAt: new Date(a.__mj_CreatedAt),
                User: a.Person || 'System',
                EntityName: 'MJ_BizApps_Tasks: Task Activities',
                RecordID: a.ID,
            }));

            const tt = typeResult?.Results?.[0];
            const archetype = ResolveTaskUiArchetype(
                tt ? { Code: tt.Code, Name: tt.Name, IsApproval: tt.IsApproval } : null,
                { TargetValue: this.Record.TargetValue, HealthStatus: this.Record.HealthStatus },
            );

            const linkedRecords: TaskWidgetLinkedRecord[] = (linksMap.get(this.Record.ID.toLowerCase()) ?? []).map((l) => ({
                EntityName: l.EntityName,
                RecordID: l.RecordID,
                DisplayName: l.Name,
                IconClass: Metadata.Provider.EntityByName(l.EntityName)?.Icon || 'fa-solid fa-link',
            }));

            this.SpotlightData = {
                TaskID: this.Record.ID,
                TaskName: this.Record.Name,
                Archetype: archetype,
                Status: this.Record.Status,
                DueAt: this.Record.DueAt,
                PercentComplete: this.PercentComplete,
                HoursEstimated: this.Record.HoursEstimated,
                HoursActual: this.Record.HoursActual,
                BlockedReason: this.Record.BlockedReason,
                BlockingDependencyNames: this.Dependencies.filter((d) => d.IsBlocking).map((d) => d.DependsOnTaskName),
                PredictedSLARiskBand: this.Record.PredictedSLARiskBand,
                PredictedSLABreachProbability: this.Record.PredictedSLABreachProbability,
                OkrSnapshot:
                    archetype === 'key-result'
                        ? {
                              TaskID: this.Record.ID,
                              BaselineValue: this.Record.BaselineValue,
                              TargetValue: this.Record.TargetValue,
                              CurrentValue: this.Record.CurrentValue,
                              UnitOfMeasure: this.Record.UnitOfMeasure,
                              MetricDirection: this.Record.MetricDirection,
                              PercentComplete: this.PercentComplete,
                              HealthStatus: this.Record.HealthStatus,
                              ConfidenceScore: this.Record.ConfidenceScore,
                              PlanningPeriod: this.Record.PlanningPeriod,
                              CheckInCadence: this.Record.CheckInCadence,
                              LastCheckInAt: this.Record.LastCheckInAt,
                              NextCheckInDueAt: this.Record.NextCheckInDueAt,
                          }
                        : null,
                ApprovalTask:
                    archetype === 'approval'
                        ? {
                              ID: this.Record.ID,
                              Name: this.Record.Name,
                              Description: this.Record.Description,
                              ParentID: this.Record.ParentID,
                              Status: this.Record.Status,
                              Priority: this.Record.Priority,
                              DueAt: this.Record.DueAt,
                              PercentComplete: this.PercentComplete,
                              IsApproval: true,
                              LinkedRecords: linkedRecords,
                              OnCompleteActionName: tt?.OnCompleteAction ?? null,
                              OnRejectActionName: tt?.OnRejectAction ?? null,
                              OnCancelActionName: tt?.OnCancelAction ?? null,
                          }
                        : null,
            };
        } finally {
            this.IsLoading = false;
            this.cdr.markForCheck();
        }
    }

    public async OnApprovalSubmitted(event: TaskApprovalActionEvent): Promise<void> {
        if (!this.Record) return;
        this.Busy = true;
        this.cdr.markForCheck();
        try {
            const personID = await ResolveCurrentPersonID().catch(() => null);
            await this.orchestration.RecordDecision({
                TaskID: event.TaskID,
                OutcomeCode: event.OutcomeCode,
                DecidedByPersonID: personID ?? undefined,
                Notes: event.Notes ?? undefined,
            });
            await this.Record.InnerLoad(CompositeKey.FromID(this.Record.ID));
            await this.LoadData();
        } finally {
            this.Busy = false;
            this.cdr.markForCheck();
        }
    }

    public async OnCheckInSubmitted(event: TaskOkrCheckInSubmitEvent): Promise<void> {
        if (!this.Record) return;
        this.Busy = true;
        this.cdr.markForCheck();
        try {
            const personID = await ResolveCurrentPersonID().catch(() => null);
            const ci = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskCheckInEntity>('MJ_BizApps_Tasks: Task Check Ins');
            ci.NewRecord();
            ci.TaskID = event.TaskID;
            ci.AuthorPersonID = personID;
            ci.AuthorUserID = Metadata.Provider.CurrentUser?.ID ?? null;
            ci.CheckInAt = new Date();
            ci.HealthStatus = event.HealthStatus;
            ci.ConfidenceScore = event.ConfidenceScore;
            ci.PreviousValue = this.Record.CurrentValue;
            ci.NewValue = event.NewValue;
            const computedPct = TaskService.computeQuantitativePercentComplete(
                this.Record.BaselineValue,
                this.Record.TargetValue,
                event.NewValue,
                this.Record.MetricDirection,
            );
            ci.PercentComplete = computedPct ?? this.Record.PercentComplete;
            ci.Summary = event.Summary;
            ci.Blockers = event.Blockers;
            ci.NextSteps = event.NextSteps;
            const saved = await ci.Save();
            if (saved) {
                // Server-side TaskCheckIn save propagates CurrentValue, HealthStatus, ConfidenceScore,
                // PercentComplete, LastCheckInAt, and NextCheckInDueAt onto the parent Task.
                // Reload the fresh server state to avoid concurrent-modification conflicts.
                await this.Record.InnerLoad(CompositeKey.FromID(this.Record.ID));
                await this.LoadData();
            }
        } finally {
            this.Busy = false;
            this.cdr.markForCheck();
        }
    }

    public OnLinkedRecordClick(rec: TaskWidgetLinkedRecord): void {
        SharedService.Instance.OpenEntityRecord(rec.EntityName, CompositeKey.FromID(rec.RecordID));
    }

    public OnDependencyClick(dep: DependencySummary): void {
        if (!dep.DependsOnTaskID) return;
        const pk = CompositeKey.FromID(dep.DependsOnTaskID);
        if (this.navService) {
            this.navService.OpenEntityRecord('MJ_BizApps_Tasks: Tasks', pk);
        } else if (this.FormComponent) {
            this.FormComponent.OnFormNavigate({
                Kind: 'record',
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                PrimaryKey: pk,
            });
        }
    }

    public OnActivityClick(act: ActivitySummary): void {
        if (!act.EntityName || !act.RecordID) return;
        const pk = CompositeKey.FromID(act.RecordID);
        if (this.navService) {
            this.navService.OpenEntityRecord(act.EntityName, pk);
        } else if (this.FormComponent) {
            this.FormComponent.OnFormNavigate({
                Kind: 'record',
                EntityName: act.EntityName,
                PrimaryKey: pk,
            });
        }
    }
}
