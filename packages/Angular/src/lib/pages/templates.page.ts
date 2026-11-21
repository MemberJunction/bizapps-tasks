import { ChangeDetectionStrategy, ChangeDetectorRef, Component, EventEmitter, OnInit, Output, inject } from '@angular/core';
import { RunView } from '@memberjunction/core';
import {
    MJButtonDirective,
    MJCardComponent,
    MJCardFooterDirective,
    MJCardGridComponent,
    MJCardToolsDirective,
    MJEmptyStateComponent,
    MJPageBodyComponent,
    MJPageHeaderComponent,
    MJPageLayoutComponent,
    MJPageSearchComponent,
    MJRefreshButtonComponent,
    MJStatBadgeComponent,
} from '@memberjunction/ng-ui-components';
import { RunningTimerChipComponent } from '../components/running-timer-chip/running-timer-chip.component';
import { TaskDrawerShellComponent } from '../components/task-drawer-shell/task-drawer-shell.component';
import { TaskTemplateWizardComponent } from '../components/task-template-wizard/task-template-wizard.component';

interface TemplateCard {
    ID: string;
    Name: string;
    Description: string | null;
    CategoryID: string | null;
    Category: string | null;
    IsActive: boolean;
    StepCount: number;
    TotalHours: number;
}

/**
 * Playbooks & Templates Page — official MJ Page Chrome trio
 * (`<mj-page-layout>` + `<mj-page-header>` + `<mj-page-body>`) + `<mj-card-grid>`
 * + `<mj-card>` + 1-Screen Playbook Launcher inside `<bizapps-task-drawer-shell>`.
 */
@Component({
    selector: 'bizapps-templates-page',
    standalone: true,
    imports: [
        MJPageLayoutComponent,
        MJPageHeaderComponent,
        MJPageBodyComponent,
        MJPageSearchComponent,
        MJRefreshButtonComponent,
        MJStatBadgeComponent,
        MJCardGridComponent,
        MJCardComponent,
        MJCardToolsDirective,
        MJCardFooterDirective,
        MJEmptyStateComponent,
        MJButtonDirective,
        RunningTimerChipComponent,
        TaskDrawerShellComponent,
        TaskTemplateWizardComponent,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <mj-page-layout>
            <mj-page-header
                Title="Templates"
                Icon="fa-solid fa-copy"
                Subtitle="Repeatable playbooks that generate hierarchies, dependencies, and role assignments in one click.">
                @if (Templates.length > 0) {
                    <div meta>
                        <mj-stat-badge
                            [Count]="FilteredTemplates.length"
                            [Total]="Templates.length"
                            Label="templates">
                        </mj-stat-badge>
                    </div>
                }

                <div actions>
                    <bizapps-running-timer-chip></bizapps-running-timer-chip>
                    <mj-refresh-button [Loading]="Loading" (Clicked)="LoadTemplates()" />
                    <button type="button" mjButton variant="primary" size="sm" (click)="OpenLauncher(null)" title="Launch Template" aria-label="Launch Template">
                        <i class="fa-solid fa-wand-magic-sparkles" aria-hidden="true"></i>
                        <span class="action-btn-label">Launch Template</span>
                    </button>
                </div>

                <div toolbar>
                    <mj-page-search
                        Placeholder="Search playbooks..."
                        [Value]="SearchText"
                        (ValueChange)="SearchText = $event; cdr.markForCheck()">
                    </mj-page-search>
                </div>
            </mj-page-header>

            <mj-page-body>
                @if (Loading && Templates.length === 0) {
                    <div class="mjt-tpl-loading">Loading task templates...</div>
                } @else if (FilteredTemplates.length === 0) {
                    <mj-empty-state
                        Icon="fa-solid fa-copy"
                        Title="No task templates found"
                        Message="Create a Task Template record to reuse multi-step playbooks across teams.">
                    </mj-empty-state>
                } @else {
                    <mj-card-grid>
                        @for (tmpl of FilteredTemplates; track tmpl.ID) {
                            <mj-card
                                [Title]="tmpl.Name"
                                [Subtitle]="tmpl.Category || 'General Playbook'"
                                Icon="fa-solid fa-diagram-project">
                                <ng-template mjCardTools>
                                    <span class="mjt-step-pill">{{ tmpl.StepCount }} steps</span>
                                </ng-template>

                                <p class="mjt-tpl-desc">
                                    {{ tmpl.Description || 'Standardized task checklist with relative due dates and dependencies.' }}
                                </p>

                                <ng-template mjCardFooter>
                                    <div class="mjt-tpl-foot-row">
                                        <span class="mjt-tpl-hours">
                                            {{ tmpl.TotalHours > 0 ? tmpl.TotalHours + 'h est.' : 'Flexible effort' }}
                                        </span>
                                        <button type="button" mjButton variant="primary" size="sm" (click)="OpenLauncher(tmpl.ID)">
                                            <i class="fa-solid fa-play" aria-hidden="true"></i>
                                            <span>Use Template</span>
                                        </button>
                                    </div>
                                </ng-template>
                            </mj-card>
                        }
                    </mj-card-grid>
                }
            </mj-page-body>
        </mj-page-layout>

        <bizapps-task-drawer-shell
            [Visible]="ShowWizard"
            Title="Launch Playbook Template"
            (Closed)="CloseWizard()">
            <bizapps-task-template-wizard
                [SelectedTemplateID]="SelectedTemplateID"
                (Created)="CloseWizard(); LoadTemplates()"
                (Cancelled)="CloseWizard()">
            </bizapps-task-template-wizard>
        </bizapps-task-drawer-shell>
    `,
    styles: [`
        :host { display: block; width: 100%; height: 100%; }
        mj-card-grid { display: block; padding-bottom: 80px; }
        .mjt-tpl-loading { padding: 36px; text-align: center; color: var(--mj-text-muted); }
        .mjt-step-pill {
            font-family: var(--mj-font-family-mono, monospace);
            font-size: 11px;
            font-weight: var(--mj-font-semibold, 600);
            padding: 2px 8px;
            border-radius: var(--mj-radius-full, 9999px);
            background: color-mix(in srgb, var(--mj-brand-primary) 12%, var(--mj-bg-surface));
            color: var(--mj-brand-primary);
        }
        .mjt-tpl-desc {
            margin: 0;
            font-size: var(--mj-text-sm, 14px);
            color: var(--mj-text-secondary);
            line-height: 1.5;
        }
        .mjt-tpl-foot-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            width: 100%;
        }
        .mjt-tpl-hours {
            font-size: var(--mj-text-xs, 12px);
            font-family: var(--mj-font-family-mono, monospace);
            color: var(--mj-text-muted);
        }
    `],
})
export class TemplatesPageComponent implements OnInit {
    @Output() DrawerOpenChange = new EventEmitter<boolean>();

    public Templates: TemplateCard[] = [];
    public Loading = false;
    public ShowWizard = false;
    public SelectedTemplateID: string | null = null;
    public SearchText = '';

    public cdr = inject(ChangeDetectorRef);

    public get FilteredTemplates(): TemplateCard[] {
        const q = this.SearchText.trim().toLowerCase();
        if (!q) return this.Templates;
        return this.Templates.filter(
            (t) =>
                t.Name.toLowerCase().includes(q) ||
                (t.Description?.toLowerCase().includes(q) ?? false) ||
                (t.Category?.toLowerCase().includes(q) ?? false),
        );
    }

    public ngOnInit(): void {
        void this.LoadTemplates();
    }

    public async LoadTemplates(): Promise<void> {
        this.Loading = true;
        this.cdr.markForCheck();
        try {
            const [tplsRes, itemsRes] = await Promise.all([
                new RunView().RunView<{
                    ID: string;
                    Name: string;
                    Description: string | null;
                    CategoryID: string | null;
                    Category: string | null;
                    IsActive: boolean;
                }>({
                    EntityName: 'MJ_BizApps_Tasks: Task Templates',
                    ExtraFilter: 'IsActive = 1',
                    OrderBy: 'Name ASC',
                    ResultType: 'simple',
                    BypassCache: true,
                }),
                new RunView().RunView<{ TemplateID: string; HoursEstimated: number | null }>({
                    EntityName: 'MJ_BizApps_Tasks: Task Template Items',
                    Fields: ['TemplateID', 'HoursEstimated'],
                    ResultType: 'simple',
                }),
            ]);

            const stepCounts = new Map<string, number>();
            const hoursTotals = new Map<string, number>();
            for (const item of itemsRes?.Results ?? []) {
                const k = item.TemplateID.toLowerCase();
                stepCounts.set(k, (stepCounts.get(k) ?? 0) + 1);
                hoursTotals.set(k, (hoursTotals.get(k) ?? 0) + (item.HoursEstimated ?? 0));
            }

            this.Templates = (tplsRes?.Results ?? []).map((t) => {
                const k = t.ID.toLowerCase();
                return {
                    ...t,
                    StepCount: stepCounts.get(k) ?? 0,
                    TotalHours: hoursTotals.get(k) ?? 0,
                };
            });
        } finally {
            this.Loading = false;
            this.cdr.markForCheck();
        }
    }

    public OpenLauncher(templateID: string | null): void {
        this.SelectedTemplateID = templateID;
        this.ShowWizard = true;
        this.DrawerOpenChange.emit(true);
        this.cdr.markForCheck();
    }

    public CloseWizard(): void {
        this.ShowWizard = false;
        this.SelectedTemplateID = null;
        this.DrawerOpenChange.emit(false);
        this.cdr.markForCheck();
    }
}
