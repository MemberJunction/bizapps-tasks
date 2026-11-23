import {
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    Component,
    EventEmitter,
    Input,
    OnInit,
    Output,
    inject,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { Metadata, RunView, type IMetadataProvider, type IRunViewProvider } from '@memberjunction/core';
import { EscapeSQLString } from '@memberjunction/global';
import { MJButtonDirective, MJEmptyStateComponent } from '@memberjunction/ng-ui-components';
import { LEGACY_OKR_TASK_TYPE_IDS } from '@mj-biz-apps/tasks-entities';
import { OpenTaskRecord } from '../../open-task-record';

export const GOALS_PLANNING_APP_NAME = 'BizApps Planning';
export const GOALS_IMPORT_ACTION_NAME = 'Import Tasks OKRs';
export const GOALS_EMPTY_STATE_TITLE = 'OKRs & Goals have moved to BizApps Planning';
export const GOALS_EMPTY_STATE_MESSAGE =
    'PRIORITY_OBJECTIVE and KEY_RESULT task types are deactivated in BizApps Tasks 1.x. Create and track Objectives and Key Results in BizApps Planning, or run the Import Tasks OKRs action to migrate existing legacy OKR tasks.';

export interface LegacyOkrTaskSummary {
    ID: string;
    Name: string;
    Type: string | null;
    Status: string;
    PercentComplete: number;
    PlanningPeriod: string | null;
    HealthStatus: string | null;
}

/**
 * Goals & Legacy OKR Migration View (`<bizapps-goals-view>`).
 *
 * Surfaces the 1.x OKR deprecation notice, steers users to **BizApps Planning**
 * and the **`Import Tasks OKRs`** migration action, and safely renders any
 * existing legacy `PRIORITY_OBJECTIVE` or `KEY_RESULT` tasks as read-only
 * until migrated.
 *
 * Styled exclusively with semantic `--mj-*` CSS custom properties.
 */
@Component({
    selector: 'bizapps-goals-view',
    standalone: true,
    imports: [CommonModule, MJButtonDirective, MJEmptyStateComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <div class="mjt-goals-view" data-testid="goals-view">
            <section class="mjt-goals-notice" role="region" aria-label="BizApps Planning OKR migration guidance">
                <div class="mjt-goals-notice__icon" aria-hidden="true">
                    <i class="fa-solid fa-compass"></i>
                </div>
                <div class="mjt-goals-notice__body">
                    <h2 class="mjt-goals-notice__title">Objectives &amp; Key Results (OKRs) live in {{ PlanningAppName }}</h2>
                    <p class="mjt-goals-notice__copy">
                        Strategic OKR task types (<code>PRIORITY_OBJECTIVE</code> and <code>KEY_RESULT</code>) are
                        deactivated in BizApps Tasks 1.x while existing OKR columns remain preserved for safe upgrades.
                        Use <strong>{{ PlanningAppName }}</strong> to create and manage new OKRs, and run the
                        <strong>{{ ImportActionName }}</strong> action (preview with <code>DryRun: true</code>) to
                        migrate historical OKR tasks.
                    </p>
                </div>
            </section>

            @if (LoadError) {
                <div class="mjt-goals-error" role="alert">
                    <i class="fa-solid fa-triangle-exclamation" aria-hidden="true"></i>
                    <span>{{ LoadError }}</span>
                </div>
            }

            @if (Loading) {
                <div class="mjt-goals-loading">Checking for legacy OKR tasks...</div>
            } @else if (LegacyTasks.length === 0) {
                <div class="mjt-goals-empty" data-testid="goals-empty-state">
                    <mj-empty-state
                        Icon="fa-solid fa-bullseye"
                        [Title]="EmptyStateTitle"
                        [Message]="EmptyStateMessage">
                    </mj-empty-state>
                </div>
            } @else {
                <section class="mjt-goals-legacy" aria-label="Legacy OKR tasks">
                    <header class="mjt-goals-legacy__head">
                        <div>
                            <h3 class="mjt-goals-legacy__title">
                                Legacy OKR Tasks ({{ LegacyTasks.length }})
                            </h3>
                            <p class="mjt-goals-legacy__sub">
                                Readable in 1.x until migrated to {{ PlanningAppName }} via
                                <strong>{{ ImportActionName }}</strong>.
                            </p>
                        </div>
                        <button
                            type="button"
                            mjButton
                            variant="outline"
                            size="sm"
                            (click)="LoadLegacyOkrTasks()">
                            <i class="fa-solid fa-rotate" aria-hidden="true"></i>
                            <span>Refresh</span>
                        </button>
                    </header>

                    <div class="mjt-goals-legacy__list" role="list">
                        @for (task of LegacyTasks; track task.ID) {
                            <button
                                type="button"
                                class="mjt-goals-legacy__row"
                                role="listitem"
                                (click)="OnSelectTask(task.ID)">
                                <div class="mjt-goals-legacy__row-main">
                                    <span class="mjt-goals-legacy__name">{{ task.Name }}</span>
                                    <span class="mjt-goals-pill mjt-goals-pill--muted">
                                        {{ task.Type || 'Legacy OKR' }}
                                    </span>
                                    @if (task.PlanningPeriod) {
                                        <span class="mjt-goals-pill">{{ task.PlanningPeriod }}</span>
                                    }
                                </div>
                                <div class="mjt-goals-legacy__row-meta">
                                    <span class="mjt-goals-pill">{{ task.Status }}</span>
                                    <span class="mjt-goals-pct">{{ task.PercentComplete }}%</span>
                                </div>
                            </button>
                        }
                    </div>
                </section>
            }

            <section class="mjt-goals-help" data-testid="goals-in-app-help" aria-label="In-app help for OKRs and Goals">
                <h3 class="mjt-goals-help__title">
                    <i class="fa-regular fa-circle-question" aria-hidden="true"></i>
                    <span>In-App Help: Migrating Goals &amp; OKRs</span>
                </h3>
                <ul class="mjt-goals-help__list">
                    <li>
                        <strong>New OKRs &amp; Strategic Priorities:</strong> Open <strong>{{ PlanningAppName }}</strong>
                        to create Priorities, Objectives, Key Results, Critical Numbers, and Huddle check-ins.
                    </li>
                    <li>
                        <strong>Migrate Existing Legacy OKR Tasks:</strong> Invoke the
                        <strong>{{ ImportActionName }}</strong> action in {{ PlanningAppName }} (starting with
                        <code>DryRun: true</code>) to import historical <code>PRIORITY_OBJECTIVE</code> and
                        <code>KEY_RESULT</code> tasks idempotently.
                    </li>
                    <li>
                        <strong>Operational Tasks:</strong> Continue tracking day-to-day deliverables, action items,
                        approvals, and measurable operational tasks here in BizApps Tasks.
                    </li>
                </ul>
            </section>
        </div>
    `,
    styles: [`
        :host {
            display: block;
            width: 100%;
            font-family: var(--mj-font-family);
            color: var(--mj-text-primary);
        }
        .mjt-goals-view {
            display: flex;
            flex-direction: column;
            gap: 16px;
            padding: 16px;
        }
        .mjt-goals-notice {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 14px 16px;
            border-radius: var(--mj-radius-md, 8px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-status-info-bg);
            color: var(--mj-status-info-text);
        }
        .mjt-goals-notice__icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface);
            color: var(--mj-brand-primary);
            flex-shrink: 0;
            font-size: 15px;
        }
        .mjt-goals-notice__body {
            display: flex;
            flex-direction: column;
            gap: 6px;
            min-width: 0;
        }
        .mjt-goals-notice__title {
            margin: 0;
            font-size: var(--mj-text-sm, 14px);
            font-weight: var(--mj-font-bold, 700);
            color: var(--mj-text-primary);
        }
        .mjt-goals-notice__copy {
            margin: 0;
            font-size: var(--mj-text-xs, 12px);
            line-height: 1.5;
            color: var(--mj-text-secondary);
        }
        .mjt-goals-notice__copy code,
        .mjt-goals-help__list code {
            font-family: var(--mj-font-family-mono, monospace);
            font-size: 11px;
            padding: 1px 5px;
            border-radius: var(--mj-radius-sm, 4px);
            background: var(--mj-bg-surface);
            border: 1px solid var(--mj-border-subtle);
            color: var(--mj-text-primary);
            white-space: nowrap;
        }
        .mjt-goals-error {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 10px 12px;
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-status-error-bg);
            color: var(--mj-status-error-text);
            border: 1px solid var(--mj-status-error-border, var(--mj-border-default));
            font-size: var(--mj-text-xs, 12px);
        }
        .mjt-goals-loading {
            padding: 28px 16px;
            text-align: center;
            color: var(--mj-text-muted);
            font-size: var(--mj-text-sm, 14px);
        }
        .mjt-goals-empty {
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-lg, 10px);
            background: var(--mj-bg-surface);
            padding: 20px 16px;
        }
        .mjt-goals-legacy {
            display: flex;
            flex-direction: column;
            gap: 10px;
            padding: 14px 16px;
            border: 1px solid var(--mj-border-default);
            border-radius: var(--mj-radius-md, 8px);
            background: var(--mj-bg-surface);
        }
        .mjt-goals-legacy__head {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
        }
        .mjt-goals-legacy__title {
            margin: 0;
            font-size: var(--mj-text-sm, 14px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-primary);
        }
        .mjt-goals-legacy__sub {
            margin: 4px 0 0;
            font-size: var(--mj-text-xs, 12px);
            color: var(--mj-text-secondary);
        }
        .mjt-goals-legacy__list {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .mjt-goals-legacy__row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            width: 100%;
            text-align: left;
            padding: 10px 12px;
            border-radius: var(--mj-radius-md, 8px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface-sunken);
            color: var(--mj-text-primary);
            font-family: inherit;
            cursor: pointer;
        }
        .mjt-goals-legacy__row:hover {
            border-color: var(--mj-brand-primary);
            background: var(--mj-bg-surface-hover);
        }
        .mjt-goals-legacy__row-main {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            min-width: 0;
        }
        .mjt-goals-legacy__name {
            font-size: var(--mj-text-sm, 14px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-primary);
        }
        .mjt-goals-legacy__row-meta {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-shrink: 0;
        }
        .mjt-goals-pill {
            display: inline-flex;
            align-items: center;
            padding: 2px 8px;
            border-radius: var(--mj-radius-full, 9999px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface);
            color: var(--mj-text-secondary);
            font-size: 11px;
            font-weight: var(--mj-font-semibold, 600);
        }
        .mjt-goals-pill--muted {
            color: var(--mj-text-muted);
        }
        .mjt-goals-pct {
            font-family: var(--mj-font-family-mono, monospace);
            font-size: var(--mj-text-xs, 12px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-brand-primary);
        }
        .mjt-goals-help {
            padding: 14px 16px;
            border-radius: var(--mj-radius-md, 8px);
            border: 1px solid var(--mj-border-default);
            background: var(--mj-bg-surface-sunken);
        }
        .mjt-goals-help__title {
            display: flex;
            align-items: center;
            gap: 8px;
            margin: 0 0 10px;
            font-size: var(--mj-text-sm, 14px);
            font-weight: var(--mj-font-semibold, 600);
            color: var(--mj-text-primary);
        }
        .mjt-goals-help__list {
            margin: 0;
            padding-left: 18px;
            display: flex;
            flex-direction: column;
            gap: 8px;
            font-size: var(--mj-text-xs, 12px);
            line-height: 1.5;
            color: var(--mj-text-secondary);
        }
    `],
})
export class GoalsViewComponent implements OnInit {
    @Input() Provider: IMetadataProvider | null = null;
    @Input() AutoLoad = true;
    @Output() TaskSelected = new EventEmitter<string>();

    public readonly PlanningAppName = GOALS_PLANNING_APP_NAME;
    public readonly ImportActionName = GOALS_IMPORT_ACTION_NAME;
    public readonly EmptyStateTitle = GOALS_EMPTY_STATE_TITLE;
    public readonly EmptyStateMessage = GOALS_EMPTY_STATE_MESSAGE;

    public Loading = false;
    public LoadError: string | null = null;
    public LegacyTasks: LegacyOkrTaskSummary[] = [];

    private cdr = inject(ChangeDetectorRef);

    public async ngOnInit(): Promise<void> {
        if (this.AutoLoad) {
            await this.LoadLegacyOkrTasks();
        }
    }

    private createRunView(): RunView {
        const provider = this.Provider ?? Metadata.Provider;
        if (provider && typeof (provider as Partial<IRunViewProvider>).RunView === 'function') {
            return RunView.FromMetadataProvider(provider);
        }
        return new RunView();
    }

    public async LoadLegacyOkrTasks(): Promise<void> {
        this.Loading = true;
        this.LoadError = null;
        this.cdr.markForCheck();
        try {
            const typeIds = Array.from(LEGACY_OKR_TASK_TYPE_IDS).map((id) => `'${EscapeSQLString(id)}'`);
            const rv = this.createRunView();
            const res = await rv.RunView<{
                ID: string;
                Name: string;
                Type: string | null;
                Status: string;
                PercentComplete: number | null;
                PlanningPeriod: string | null;
                HealthStatus: string | null;
            }>({
                EntityName: 'MJ_BizApps_Tasks: Tasks',
                ExtraFilter: `TypeID IN (${typeIds.join(', ')})`,
                Fields: ['ID', 'Name', 'Type', 'Status', 'PercentComplete', 'PlanningPeriod', 'HealthStatus'],
                OrderBy: '__mj_UpdatedAt DESC',
                ResultType: 'simple',
            });
            if (!res) {
                this.LegacyTasks = [];
                return;
            }
            if (!res.Success) {
                this.LoadError = res.ErrorMessage || 'Could not load legacy OKR tasks.';
                this.LegacyTasks = [];
                return;
            }
            this.LegacyTasks = (res.Results ?? []).map((row) => ({
                ID: row.ID,
                Name: row.Name,
                Type: row.Type ?? null,
                Status: row.Status,
                PercentComplete: row.PercentComplete ?? 0,
                PlanningPeriod: row.PlanningPeriod ?? null,
                HealthStatus: row.HealthStatus ?? null,
            }));
        } catch (err) {
            this.LoadError = err instanceof Error ? err.message : 'Failed to load legacy OKR tasks.';
            this.LegacyTasks = [];
        } finally {
            this.Loading = false;
            this.cdr.markForCheck();
        }
    }

    public OnSelectTask(taskID: string): void {
        if (!taskID) return;
        this.TaskSelected.emit(taskID);
        OpenTaskRecord(taskID);
    }
}
