import { AfterViewInit, ChangeDetectionStrategy, Component, OnDestroy, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RegisterClass } from '@memberjunction/global';
import { BaseResourceComponent } from '@memberjunction/ng-shared';
import type { ResourceData } from '@memberjunction/core-entities';
import { TasksDashboardPageComponent, type TaskViewMode } from '../pages/tasks-dashboard.page';
import { MyTasksPageComponent } from '../pages/my-tasks.page';
import { MyTimePageComponent } from '../pages/my-time.page';
import { ApprovalsPageComponent } from '../pages/approvals.page';
import { TemplatesPageComponent } from '../pages/templates.page';

/**
 * 1. Tasks Section Resource — Projects & All Work Tab
 *
 * SAFETY BOUNDARY: Exposes read/navigation/filter/view-switch client tools only.
 * Destructive mutations (delete task, bulk status apply) remain strictly user-initiated.
 */
@Component({
    selector: 'bizapps-tasks-section-resource',
    standalone: true,
    imports: [CommonModule, TasksDashboardPageComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `<bizapps-tasks-dashboard-page #page (DrawerOpenChange)="OnDrawerOpenChange($event)"></bizapps-tasks-dashboard-page>`,
    styles: [`:host { display: block; width: 100%; height: 100%; }`],
})
@RegisterClass(BaseResourceComponent, 'TasksSectionResource')
export class TasksSectionResource extends BaseResourceComponent implements AfterViewInit, OnDestroy {
    @ViewChild('page') private page?: TasksDashboardPageComponent;
    private drawerOpen = false;

    override ngOnInit(): void {
        super.ngOnInit();
        this.NotifyLoadComplete();
    }

    public OnDrawerOpenChange(isOpen: boolean): void {
        this.drawerOpen = isOpen;
        this.publishAgentContext();
    }

    public ngAfterViewInit(): void {
        this.publishAgentContext();
        this.navigationService?.SetAgentClientTools(this, [
            {
                Name: 'SwitchTasksView',
                Description: 'Switch the All Work view between list, kanban, or gantt.',
                ParameterSchema: {
                    type: 'object',
                    properties: {
                        view: { type: 'string', enum: ['list', 'kanban', 'gantt'] },
                    },
                    required: ['view'],
                },
                Handler: async (params: Record<string, unknown>) => {
                    const view = String(params['view'] ?? '') as TaskViewMode;
                    if (view === 'list' || view === 'kanban' || view === 'gantt') {
                        this.page?.SetView(view);
                        this.publishAgentContext();
                        return { Success: true, Message: `Switched view to ${view}.` };
                    }
                    return { Success: false, ErrorMessage: 'Invalid view. Use list, kanban, or gantt.' };
                },
            },
            {
                Name: 'SearchTasks',
                Description: 'Filter visible tasks by search query.',
                ParameterSchema: {
                    type: 'object',
                    properties: {
                        query: { type: 'string' },
                    },
                    required: ['query'],
                },
                Handler: async (params: Record<string, unknown>) => {
                    if (this.page) {
                        this.page.SearchText = String(params['query'] ?? '');
                        this.page.cdr.markForCheck();
                        this.publishAgentContext();
                    }
                    return { Success: true, Message: 'Updated search filter.' };
                },
            },
            {
                Name: 'OpenNewTaskDrawer',
                Description: 'Open the Express New Task creation drawer for the user to review and submit.',
                ParameterSchema: { type: 'object', properties: {} },
                Handler: async () => {
                    this.page?.OpenPanel('edit', null);
                    return { Success: true, Message: 'Opened New Task drawer.' };
                },
            },
        ]);
    }

    override ngOnDestroy(): void {
        if (this.drawerOpen) {
            this.drawerOpen = false;
            this.publishAgentContext();
        }
        super.ngOnDestroy();
    }

    private publishAgentContext(): void {
        this.navigationService?.SetAgentContext(this, {
            Surface: 'BizApps Tasks — All Work',
            ViewMode: this.page?.ViewMode ?? 'list',
            SelectedCategoryID: this.page?.SelectedCategoryID ?? null,
            SearchText: this.page?.SearchText ?? '',
            ActiveTasks: this.page?.KPIs.TotalActive ?? 0,
            OverdueTasks: this.page?.KPIs.Overdue ?? 0,
            BlockedTasks: this.page?.KPIs.Blocked ?? 0,
            SuppressChatOverlay: this.drawerOpen,
        });
    }

    async GetResourceDisplayName(_data: ResourceData): Promise<string> {
        return 'All Work';
    }

    async GetResourceIconClass(_data: ResourceData): Promise<string> {
        return 'fa-solid fa-list-check';
    }
}

/**
 * 2. My Tasks Section Resource — My Work Action Horizons Tab
 *
 * SAFETY BOUNDARY: Exposes search/filter/inspect/open-drawer tools only.
 * Approval decisions and task completion remain strictly user-initiated.
 */
@Component({
    selector: 'bizapps-my-tasks-section-resource',
    standalone: true,
    imports: [CommonModule, MyTasksPageComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `<bizapps-my-tasks-page #page (DrawerOpenChange)="OnDrawerOpenChange($event)"></bizapps-my-tasks-page>`,
    styles: [`:host { display: block; width: 100%; height: 100%; }`],
})
@RegisterClass(BaseResourceComponent, 'MyTasksSectionResource')
export class MyTasksSectionResource extends BaseResourceComponent implements AfterViewInit, OnDestroy {
    @ViewChild('page') private page?: MyTasksPageComponent;
    private drawerOpen = false;

    override ngOnInit(): void {
        super.ngOnInit();
        this.NotifyLoadComplete();
    }

    public OnDrawerOpenChange(isOpen: boolean): void {
        this.drawerOpen = isOpen;
        this.publishAgentContext();
    }

    private publishAgentContext(): void {
        this.navigationService?.SetAgentContext(this, {
            Surface: 'BizApps Tasks — My Work',
            TaskCount: this.page?.AllTasks.length ?? 0,
            UrgencyFilter: this.page?.UrgencyFilter ?? '',
            SuppressChatOverlay: this.drawerOpen,
        });
    }

    public ngAfterViewInit(): void {
        this.publishAgentContext();
        this.navigationService?.SetAgentClientTools(this, [
            {
                Name: 'FilterMyWorkUrgency',
                Description: 'Filter My Work by urgency bucket (overdue, blocked, approvals, sla, or empty to clear).',
                ParameterSchema: {
                    type: 'object',
                    properties: {
                        bucket: { type: 'string', enum: ['', 'overdue', 'blocked', 'approvals', 'sla'] },
                    },
                    required: ['bucket'],
                },
                Handler: async (params: Record<string, unknown>) => {
                    const bucket = String(params['bucket'] ?? '') as '' | 'overdue' | 'blocked' | 'approvals' | 'sla';
                    if (this.page) {
                        this.page.UrgencyFilter = bucket;
                        this.page.cdr.markForCheck();
                        this.publishAgentContext();
                    }
                    return { Success: true, Message: bucket ? `Filtered to ${bucket}.` : 'Cleared urgency filter.' };
                },
            },
            {
                Name: 'RefreshMyWork',
                Description: 'Reload the signed-in user tasks and pending approvals.',
                ParameterSchema: { type: 'object', properties: {} },
                Handler: async () => {
                    await this.page?.LoadMyWork(true);
                    return { Success: true, Message: 'Refreshed My Work.' };
                },
            },
        ]);
    }

    override ngOnDestroy(): void {
        if (this.drawerOpen) {
            this.drawerOpen = false;
            this.publishAgentContext();
        }
        super.ngOnDestroy();
    }

    async GetResourceDisplayName(_data: ResourceData): Promise<string> {
        return 'My Work';
    }

    async GetResourceIconClass(_data: ResourceData): Promise<string> {
        return 'fa-solid fa-user-check';
    }
}

/**
 * 3. Approvals Section Resource — Decisions Inbox Tab
 *
 * SAFETY BOUNDARY: Read-only navigation and refresh only; recording approval
 * decisions is strictly human-confirmed in the UI.
 */
@Component({
    selector: 'bizapps-approvals-section-resource',
    standalone: true,
    imports: [CommonModule, ApprovalsPageComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `<bizapps-approvals-page #page></bizapps-approvals-page>`,
    styles: [`:host { display: block; width: 100%; height: 100%; }`],
})
@RegisterClass(BaseResourceComponent, 'ApprovalsSectionResource')
export class ApprovalsSectionResource extends BaseResourceComponent implements AfterViewInit {
    @ViewChild('page') private page?: ApprovalsPageComponent;

    override ngOnInit(): void {
        super.ngOnInit();
        this.NotifyLoadComplete();
    }

    public ngAfterViewInit(): void {
        this.navigationService?.SetAgentContext(this, {
            Surface: 'BizApps Tasks — Approvals',
            ActiveTab: this.page?.ActiveTab ?? 'pending',
            PendingCount: this.page?.PendingApprovals.length ?? 0,
        });
        this.navigationService?.SetAgentClientTools(this, [
            {
                Name: 'SwitchApprovalsTab',
                Description: 'Switch Approvals view between pending and decided history.',
                ParameterSchema: {
                    type: 'object',
                    properties: { tab: { type: 'string', enum: ['pending', 'decided'] } },
                    required: ['tab'],
                },
                Handler: async (params: Record<string, unknown>) => {
                    const tab = String(params['tab'] ?? 'pending');
                    if (this.page && (tab === 'pending' || tab === 'decided')) {
                        this.page.ActiveTab = tab;
                        this.page.cdr.markForCheck();
                        return { Success: true, Message: `Switched to ${tab} approvals.` };
                    }
                    return { Success: false, ErrorMessage: 'Use pending or decided.' };
                },
            },
        ]);
    }

    async GetResourceDisplayName(_data: ResourceData): Promise<string> {
        return 'Approvals';
    }

    async GetResourceIconClass(_data: ResourceData): Promise<string> {
        return 'fa-solid fa-stamp';
    }
}

/**
 * 4. Templates Section Resource — Playbooks & Templates Tab
 *
 * SAFETY BOUNDARY: Search and open launcher UI only; instantiating templates
 * remains user-confirmed.
 */
@Component({
    selector: 'bizapps-templates-section-resource',
    standalone: true,
    imports: [CommonModule, TemplatesPageComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `<bizapps-templates-page #page (DrawerOpenChange)="OnDrawerOpenChange($event)"></bizapps-templates-page>`,
    styles: [`:host { display: block; width: 100%; height: 100%; }`],
})
@RegisterClass(BaseResourceComponent, 'TemplatesSectionResource')
export class TemplatesSectionResource extends BaseResourceComponent implements AfterViewInit, OnDestroy {
    @ViewChild('page') private page?: TemplatesPageComponent;
    private drawerOpen = false;

    override ngOnInit(): void {
        super.ngOnInit();
        this.NotifyLoadComplete();
    }

    public OnDrawerOpenChange(isOpen: boolean): void {
        this.drawerOpen = isOpen;
        this.publishAgentContext();
    }

    private publishAgentContext(): void {
        this.navigationService?.SetAgentContext(this, {
            Surface: 'BizApps Tasks — Templates',
            TemplateCount: this.page?.Templates.length ?? 0,
            SuppressChatOverlay: this.drawerOpen,
        });
    }

    public ngAfterViewInit(): void {
        this.publishAgentContext();
        this.navigationService?.SetAgentClientTools(this, [
            {
                Name: 'SearchTemplates',
                Description: 'Filter visible task playbook templates by name or description.',
                ParameterSchema: {
                    type: 'object',
                    properties: { query: { type: 'string' } },
                    required: ['query'],
                },
                Handler: async (params: Record<string, unknown>) => {
                    if (this.page) {
                        this.page.SearchText = String(params['query'] ?? '');
                        this.page.cdr.markForCheck();
                    }
                    return { Success: true, Message: 'Filtered templates.' };
                },
            },
        ]);
    }

    override ngOnDestroy(): void {
        if (this.drawerOpen) {
            this.drawerOpen = false;
            this.publishAgentContext();
        }
        super.ngOnDestroy();
    }

    async GetResourceDisplayName(_data: ResourceData): Promise<string> {
        return 'Templates';
    }

    async GetResourceIconClass(_data: ResourceData): Promise<string> {
        return 'fa-solid fa-copy';
    }
}

/**
 * 5. My Time Section Resource — Weekly & Period Timesheet Tab
 */
@Component({
    selector: 'bizapps-my-time-section-resource',
    standalone: true,
    imports: [CommonModule, MyTimePageComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `<bizapps-my-time-page></bizapps-my-time-page>`,
    styles: [`:host { display: block; width: 100%; height: 100%; }`],
})
@RegisterClass(BaseResourceComponent, 'MyTimeSectionResource')
export class MyTimeSectionResource extends BaseResourceComponent {
    override ngOnInit(): void {
        super.ngOnInit();
        this.NotifyLoadComplete();
    }

    async GetResourceDisplayName(_data: ResourceData): Promise<string> {
        return 'My Time';
    }

    async GetResourceIconClass(_data: ResourceData): Promise<string> {
        return 'fa-solid fa-stopwatch';
    }
}

/** Tree-shaking prevention anchor function */
export function LoadTasksSectionResources(): void {
    // Anchors section resources in bundlers
}
