import { Component, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RegisterClass } from '@memberjunction/global';
import { BaseResourceComponent } from '@memberjunction/ng-shared';
import type { ResourceData } from '@memberjunction/core-entities';
import { TasksDashboardPageComponent } from '../pages/tasks-dashboard.page';
import { MyTasksPageComponent } from '../pages/my-tasks.page';
import { ApprovalsPageComponent } from '../pages/approvals.page';
import { TemplatesPageComponent } from '../pages/templates.page';

/**
 * 1. Tasks Section Resource — Main Tasks Dashboard Tab
 */
@Component({
    selector: 'bizapps-tasks-section-resource',
    standalone: true,
    imports: [CommonModule, TasksDashboardPageComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `<bizapps-tasks-dashboard-page></bizapps-tasks-dashboard-page>`,
    styles: [`:host { display: block; width: 100%; height: 100%; }`],
})
@RegisterClass(BaseResourceComponent, 'TasksSectionResource')
export class TasksSectionResource extends BaseResourceComponent {
    override ngOnInit(): void {
        super.ngOnInit();
        this.NotifyLoadComplete();
    }

    async GetResourceDisplayName(_data: ResourceData): Promise<string> {
        return 'Tasks';
    }

    async GetResourceIconClass(_data: ResourceData): Promise<string> {
        return 'fa-solid fa-list-check';
    }
}

/**
 * 2. My Tasks Section Resource — User Deliverables Tab
 */
@Component({
    selector: 'bizapps-my-tasks-section-resource',
    standalone: true,
    imports: [CommonModule, MyTasksPageComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `<bizapps-my-tasks-page></bizapps-my-tasks-page>`,
    styles: [`:host { display: block; width: 100%; height: 100%; }`],
})
@RegisterClass(BaseResourceComponent, 'MyTasksSectionResource')
export class MyTasksSectionResource extends BaseResourceComponent {
    override ngOnInit(): void {
        super.ngOnInit();
        this.NotifyLoadComplete();
    }

    async GetResourceDisplayName(_data: ResourceData): Promise<string> {
        return 'My Tasks';
    }

    async GetResourceIconClass(_data: ResourceData): Promise<string> {
        return 'fa-solid fa-user-check';
    }
}

/**
 * 3. Approvals Section Resource — Decisions Inbox Tab
 */
@Component({
    selector: 'bizapps-approvals-section-resource',
    standalone: true,
    imports: [CommonModule, ApprovalsPageComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `<bizapps-approvals-page></bizapps-approvals-page>`,
    styles: [`:host { display: block; width: 100%; height: 100%; }`],
})
@RegisterClass(BaseResourceComponent, 'ApprovalsSectionResource')
export class ApprovalsSectionResource extends BaseResourceComponent {
    override ngOnInit(): void {
        super.ngOnInit();
        this.NotifyLoadComplete();
    }

    async GetResourceDisplayName(_data: ResourceData): Promise<string> {
        return 'Approvals';
    }

    async GetResourceIconClass(_data: ResourceData): Promise<string> {
        return 'fa-solid fa-stamp';
    }
}

/**
 * 4. Templates Section Resource — Task Templates Tab
 */
@Component({
    selector: 'bizapps-templates-section-resource',
    standalone: true,
    imports: [CommonModule, TemplatesPageComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `<bizapps-templates-page></bizapps-templates-page>`,
    styles: [`:host { display: block; width: 100%; height: 100%; }`],
})
@RegisterClass(BaseResourceComponent, 'TemplatesSectionResource')
export class TemplatesSectionResource extends BaseResourceComponent {
    override ngOnInit(): void {
        super.ngOnInit();
        this.NotifyLoadComplete();
    }

    async GetResourceDisplayName(_data: ResourceData): Promise<string> {
        return 'Templates';
    }

    async GetResourceIconClass(_data: ResourceData): Promise<string> {
        return 'fa-solid fa-copy';
    }
}

/** Tree-shaking prevention anchor function */
export function LoadTasksSectionResources(): void {
    // Anchors section resources in bundlers
}
