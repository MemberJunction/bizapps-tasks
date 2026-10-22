import { Component, Input, OnInit, OnChanges, SimpleChanges, ChangeDetectorRef, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CompositeKey, Metadata, RunView } from '@memberjunction/core';
import {
    MJCardGridComponent,
    MJCardComponent,
    MJCardToolsDirective,
    MJCardFooterDirective,
} from '@memberjunction/ng-ui-components';
import { NavigationService } from '@memberjunction/ng-shared';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';

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

const TASK_OVERVIEW_CSS = `
.mjt-overview {
    display: flex;
    flex-direction: column;
    gap: 16px;
    width: 100%;
}

.mjt-progress-section {
    display: flex;
    flex-direction: column;
    gap: 12px;
    margin-top: 4px;
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
    font-size: 12px;
    font-weight: 600;
}

.mjt-progress-bar {
    height: 8px;
    background: var(--mj-bg-surface-sunken, #090e1a);
    border: 1px solid var(--mj-border-default, #223254);
    border-radius: 9999px;
    overflow: hidden;
}

.mjt-progress-fill {
    height: 100%;
    border-radius: 9999px;
    background: linear-gradient(90deg, #38bdf8, #6366f1);
    transition: width 0.3s ease;
}

.mjt-progress-fill--success {
    background: linear-gradient(90deg, #10b981, #34d399);
}

.mjt-deck {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.mjt-deck-item {
    background: var(--mj-bg-surface-sunken, #090e1a);
    border: 1px solid var(--mj-border-default, #223254);
    border-radius: 8px;
    padding: 8px 12px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    cursor: pointer;
    transition: all 0.15s ease;
}

.mjt-deck-item:hover {
    border-color: var(--mj-brand-primary, #38bdf8);
    background: var(--mj-bg-surface-elevated, #1a2744);
    transform: translateX(2px);
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
    border-radius: 6px;
    background: rgba(56, 189, 248, 0.12);
    color: var(--mj-brand-primary, #38bdf8);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 11.5px;
    flex-shrink: 0;
}

.mjt-deck-item__icon--warn {
    background: rgba(245, 158, 11, 0.15);
    color: #f59e0b;
}

.mjt-deck-item__text h4 {
    font-size: 12px;
    font-weight: 600;
    color: var(--mj-text-primary, #f8fafc);
    margin: 0;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.mjt-deck-item__text p {
    font-size: 11px;
    color: var(--mj-text-muted, #64748b);
    margin: 1px 0 0 0;
}

.mjt-timeline {
    display: flex;
    flex-direction: column;
    gap: 6px;
    max-height: 210px;
    overflow-y: auto;
    scrollbar-width: thin;
    padding-right: 4px;
}

.mjt-timeline-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 6px 8px;
    border-radius: 6px;
    border: 1px solid transparent;
    cursor: pointer;
    transition: all 0.15s ease;
}

.mjt-timeline-item:hover {
    background: var(--mj-bg-surface-sunken, #090e1a);
    border-color: var(--mj-border-default, #223254);
    transform: translateX(2px);
}

.mjt-timeline-item__icon {
    width: 24px;
    height: 24px;
    border-radius: 50%;
    background: var(--mj-bg-surface-sunken, #090e1a);
    border: 1px solid var(--mj-border-default, #223254);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 10px;
    flex-shrink: 0;
    color: var(--mj-brand-primary, #38bdf8);
}

.mjt-timeline-item__content {
    flex: 1;
    min-width: 0;
}

.mjt-timeline-item__content h5 {
    font-size: 11.5px;
    font-weight: 600;
    color: var(--mj-text-primary, #f8fafc);
    margin: 0;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.mjt-timeline-item__content p {
    font-size: 10.5px;
    color: var(--mj-text-secondary, #94a3b8);
    margin: 1px 0 0 0;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.mjt-timeline-item__arrow {
    font-size: 10px;
    color: var(--mj-text-muted, #64748b);
    opacity: 0;
    transition: opacity 0.15s ease;
}

.mjt-timeline-item:hover .mjt-timeline-item__arrow {
    opacity: 1;
    color: var(--mj-brand-primary, #38bdf8);
}

.mjt-code {
    font-family: 'JetBrains Mono', monospace;
    font-weight: 600;
    color: var(--mj-brand-primary, #38bdf8);
}

.mjt-empty-state {
    font-size: 12px;
    color: var(--mj-text-muted, #64748b);
    padding: 16px;
    text-align: center;
    font-style: italic;
}
`;

@Component({
    standalone: true,
    selector: 'mjt-task-overview',
    imports: [
        CommonModule,
        MJCardGridComponent,
        MJCardComponent,
        MJCardToolsDirective,
        MJCardFooterDirective,
    ],
    template: `
        <div class="mjt-overview">
            <mj-card-grid>
                
                <!-- Card 1: Subtasks & Execution Velocity -->
                <mj-card Title="Subtasks & Execution Velocity" Subtitle="Work Breakdown & Time Tracking" Icon="fa-solid fa-bars-progress">
                    <div mjCardTools>
                        <span class="mjt-code">{{ PercentComplete }}% Complete</span>
                    </div>

                    <div class="mjt-progress-section">
                        <div class="mjt-progress-row">
                            <div class="mjt-progress-header">
                                <span style="color: var(--mj-text-secondary);">Task Completion</span>
                                <span class="mjt-code">{{ PercentComplete }}%</span>
                            </div>
                            <div class="mjt-progress-bar">
                                <div class="mjt-progress-fill" [style.width.%]="PercentComplete"></div>
                            </div>
                        </div>

                        <div class="mjt-progress-row">
                            <div class="mjt-progress-header">
                                <span style="color: var(--mj-text-secondary);">Subtasks Completed</span>
                                <span class="mjt-code">{{ CompletedSubtasksCount }} of {{ TotalSubtasksCount }}</span>
                            </div>
                            <div class="mjt-progress-bar">
                                <div class="mjt-progress-fill mjt-progress-fill--success" [style.width.%]="SubtaskPercent"></div>
                            </div>
                        </div>
                    </div>

                    <div mjCardFooter>
                        <div class="card-metric">
                            <span class="card-metric__label">Subtasks</span>
                            <span class="card-metric__val">{{ TotalSubtasksCount }} Total</span>
                        </div>
                        <div class="card-metric">
                            <span class="card-metric__label">Status</span>
                            <span class="card-metric__val" style="color: var(--mj-status-success);">{{ Record?.Status || 'Active' }}</span>
                        </div>
                        <div class="card-metric">
                            <span class="card-metric__label">Priority</span>
                            <span class="card-metric__val">{{ Record?.Priority || 'Normal' }}</span>
                        </div>
                    </div>
                </mj-card>

                <!-- Card 2: Decisions & Dependencies -->
                <mj-card Title="Decisions & Dependencies" Subtitle="Critical Path & Blocker Status" Icon="fa-solid fa-gavel">
                    <div mjCardTools>
                        <span class="mjt-code">{{ Dependencies.length }} Linked</span>
                    </div>

                    <div class="mjt-deck">
                        @if (Dependencies.length > 0) {
                            @for (dep of Dependencies; track dep.ID) {
                                <div class="mjt-deck-item" (click)="OnDependencyClick(dep)">
                                    <div class="mjt-deck-item__left">
                                        <div class="mjt-deck-item__icon" [class.mjt-deck-item__icon--warn]="dep.IsBlocking">
                                            <i class="fa-solid" [class.fa-triangle-exclamation]="dep.IsBlocking" [class.fa-link]="!dep.IsBlocking"></i>
                                        </div>
                                        <div class="mjt-deck-item__text">
                                            <h4>{{ dep.DependsOnTaskName }}</h4>
                                            <p>{{ dep.DependencyType }} &bull; Status: {{ dep.DependsOnTaskStatus }}</p>
                                        </div>
                                    </div>
                                    <span class="mjt-code" style="font-size: 11px;">{{ dep.IsBlocking ? 'Blocking' : 'Linked' }}</span>
                                </div>
                            }
                        } @else {
                            <div class="mjt-empty-state">No blocking dependencies linked to this task.</div>
                        }
                    </div>

                    <div mjCardFooter>
                        <div class="card-metric">
                            <span class="card-metric__label">Dependencies</span>
                            <span class="card-metric__val">{{ Dependencies.length }}</span>
                        </div>
                        <div class="card-metric">
                            <span class="card-metric__label">Blockers</span>
                            <span class="card-metric__val" [style.color]="BlockerCount > 0 ? 'var(--mj-status-error)' : 'var(--mj-status-success)'">
                                {{ BlockerCount }} Active
                            </span>
                        </div>
                        <div class="card-metric">
                            <span class="card-metric__label">Path Status</span>
                            <span class="card-metric__val" style="color: var(--mj-status-success);">Clear</span>
                        </div>
                    </div>
                </mj-card>

                <!-- Card 3: Recent Activity & Discussion -->
                <mj-card Title="Recent Activity & Audit Trail" Subtitle="Touchpoints & Assignment Changes" Icon="fa-solid fa-comments">
                    <div mjCardTools>
                        <span class="mjt-code">Live Feed</span>
                    </div>

                    <div class="mjt-timeline">
                        @if (Activities.length > 0) {
                            @for (act of Activities; track act.ID) {
                                <div class="mjt-timeline-item" (click)="OnActivityClick(act)">
                                    <div class="mjt-timeline-item__icon">
                                        <i class="fa-solid fa-bolt-lightning"></i>
                                    </div>
                                    <div class="mjt-timeline-item__content">
                                        <h5>{{ act.ActivityType }}</h5>
                                        <p>{{ act.Description }} &bull; {{ act.User }}</p>
                                    </div>
                                    <div class="mjt-timeline-item__arrow">
                                        <i class="fa-solid fa-arrow-up-right-from-square"></i>
                                    </div>
                                </div>
                            }
                        } @else {
                            <div class="mjt-empty-state">No recent activity logged for this task yet.</div>
                        }
                    </div>

                    <div mjCardFooter>
                        <div class="card-metric">
                            <span class="card-metric__label">Total Updates</span>
                            <span class="card-metric__val">{{ Activities.length }}</span>
                        </div>
                        <div class="card-metric">
                            <span class="card-metric__label">Created</span>
                            <span class="card-metric__val">{{ CreatedDateLabel }}</span>
                        </div>
                        <div class="card-metric">
                            <span class="card-metric__label">Audit State</span>
                            <span class="card-metric__val" style="color: var(--mj-brand-primary);">Logged</span>
                        </div>
                    </div>
                </mj-card>

                <!-- Card 4: Linked Context & Resources -->
                <mj-card Title="Linked Deliverables & Context" Subtitle="Related Entities & Specifications" Icon="fa-solid fa-paperclip">
                    <div mjCardTools>
                        <span class="mjt-code">Artifacts</span>
                    </div>

                    <div class="mjt-deck">
                        @if (Record?.ParentID) {
                            <div class="mjt-deck-item" (click)="OnParentClick()">
                                <div class="mjt-deck-item__left">
                                    <div class="mjt-deck-item__icon">
                                        <i class="fa-solid fa-folder-tree"></i>
                                    </div>
                                    <div class="mjt-deck-item__text">
                                        <h4>Parent Task Container</h4>
                                        <p>Click to open parent task record</p>
                                    </div>
                                </div>
                                <span class="mjt-code" style="font-size: 11px;">Parent</span>
                            </div>
                        }
                        <div class="mjt-deck-item">
                            <div class="mjt-deck-item__left">
                                <div class="mjt-deck-item__icon">
                                    <i class="fa-solid fa-layer-group"></i>
                                </div>
                                <div class="mjt-deck-item__text">
                                    <h4>Category: {{ Record?.Category || 'General Deliverable' }}</h4>
                                    <p>Type: {{ Record?.Type || 'Standard Task' }}</p>
                                </div>
                            </div>
                            <span class="mjt-code" style="font-size: 11px;">Scope</span>
                        </div>
                    </div>

                    <div mjCardFooter>
                        <div class="card-metric">
                            <span class="card-metric__label">Task Type</span>
                            <span class="card-metric__val">{{ Record?.Type || 'Standard' }}</span>
                        </div>
                        <div class="card-metric">
                            <span class="card-metric__label">Category</span>
                            <span class="card-metric__val">{{ Record?.Category || 'General' }}</span>
                        </div>
                        <div class="card-metric">
                            <span class="card-metric__label">Parent Link</span>
                            <span class="card-metric__val">{{ Record?.ParentID ? 'Linked' : 'None' }}</span>
                        </div>
                    </div>
                </mj-card>

            </mj-card-grid>
        </div>
    `,
    styles: [TASK_OVERVIEW_CSS]
})
export class TaskOverviewComponent implements OnInit, OnChanges {
    @Input() public Record: mjBizAppsTasksTaskEntity | null = null;
    @Input() public FormComponent: BaseFormComponent | null = null;

    private cdr = inject(ChangeDetectorRef);
    private navService = inject(NavigationService, { optional: true });

    public TotalSubtasksCount = 0;
    public CompletedSubtasksCount = 0;
    public Dependencies: DependencySummary[] = [];
    public Activities: ActivitySummary[] = [];
    public IsLoading = false;

    public get PercentComplete(): number {
        return Math.round(this.Record?.PercentComplete ?? 0);
    }

    public get SubtaskPercent(): number {
        if (this.TotalSubtasksCount === 0) return this.PercentComplete;
        return Math.round((this.CompletedSubtasksCount / this.TotalSubtasksCount) * 100);
    }

    public get BlockerCount(): number {
        return this.Dependencies.filter(d => d.IsBlocking).length;
    }

    public get CreatedDateLabel(): string {
        const raw = this.Record?.Get('__mj_CreatedAt') || this.Record?.StartedAt;
        if (!raw) return '—';
        return new Date(raw).toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    }

    public ngOnInit(): void {
        this.LoadData();
    }

    public ngOnChanges(changes: SimpleChanges): void {
        if (changes['Record'] && !changes['Record'].firstChange) {
            this.LoadData();
        }
    }

    public async LoadData(): Promise<void> {
        if (!this.Record?.ID) return;
        this.IsLoading = true;

        try {
            const rv = new RunView();
            const md = new Metadata();

            // Load subtasks
            const subtaskResult = await rv.RunView<Record<string, unknown>>({
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                ExtraFilter: `ParentID = '${this.Record.ID}'`,
                ResultType: 'simple'
            });

            if (subtaskResult?.Success && subtaskResult.Results) {
                this.TotalSubtasksCount = subtaskResult.Results.length;
                this.CompletedSubtasksCount = subtaskResult.Results.filter(
                    (s: Record<string, unknown>) => s['Status'] === 'Completed'
                ).length;
            }

            // Load dependencies
            const depResult = await rv.RunView<Record<string, unknown>>({
                EntityName: 'MJ_BizApps_Tasks: Task Dependencies',
                ExtraFilter: `TaskID = '${this.Record.ID}'`,
                ResultType: 'simple'
            });

            if (depResult?.Success && depResult.Results) {
                this.Dependencies = depResult.Results.map((d: Record<string, unknown>) => ({
                    ID: String(d['ID'] || ''),
                    DependencyType: String(d['DependencyType'] || 'Blocks'),
                    DependsOnTaskID: String(d['DependsOnTaskID'] || ''),
                    DependsOnTaskName: String(d['DependsOnTaskName'] || d['DependsOnTask'] || 'Linked Task'),
                    DependsOnTaskStatus: String(d['DependsOnTaskStatus'] || 'Open'),
                    IsBlocking: d['DependencyType'] === 'Blocks' || d['DependencyType'] === 'FinishToStart'
                }));
            }

            // Load activities
            const actResult = await rv.RunView<Record<string, unknown>>({
                EntityName: 'MJ_BizApps_Tasks: Task Activities',
                ExtraFilter: `TaskID = '${this.Record.ID}'`,
                OrderBy: '__mj_CreatedAt DESC',
                MaxRows: 10,
                ResultType: 'simple'
            });

            if (actResult?.Success && actResult.Results) {
                this.Activities = actResult.Results.map((a: Record<string, unknown>) => ({
                    ID: String(a['ID'] || ''),
                    ActivityType: String(a['ActivityType'] || 'Update'),
                    Description: String(a['Description'] || a['Name'] || 'Task updated'),
                    CreatedAt: new Date(String(a['__mj_CreatedAt'] || a['CreatedAt'] || Date.now())),
                    User: String(a['User'] || 'System'),
                    EntityName: 'MJ_BizApps_Tasks: Task Activities',
                    RecordID: String(a['ID'] || '')
                }));
            }
        } catch (e) {
            console.warn('[TaskOverview] Error loading task details:', e);
        } finally {
            this.IsLoading = false;
            this.cdr.detectChanges();
        }
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

    public OnParentClick(): void {
        if (!this.Record?.ParentID) return;
        const pk = CompositeKey.FromID(this.Record.ParentID);
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
}
