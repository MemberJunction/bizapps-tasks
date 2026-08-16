import { Component } from '@angular/core';
import { RegisterClassEx } from '@memberjunction/global';
import { BaseFormPanel } from '@memberjunction/ng-base-forms';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';

/**
 * TaskOverviewPanel — contributes the primary 'Overview' rail section to the Tasks form.
 * Wrapped in <mj-collapsible-panel SectionKey="overview" SectionName="Overview">
 * with slot: 'before-fields', contributionKey: 'overview', sortKey: 100.
 */
@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:Tasks:overview',
    metadata: {
        entity: 'MJ_BizApps_Tasks: Tasks',
        slot: 'before-fields',
        sortKey: 100,
        contributionKey: 'overview',
    },
})
@Component({
    standalone: false,
    selector: 'mjt-task-overview-panel',
    template: `
        <mj-collapsible-panel
            SectionKey="overview"
            SectionName="Overview">
            <mjt-task-overview
                [Record]="Record"
                [FormComponent]="FormComponent">
            </mjt-task-overview>
        </mj-collapsible-panel>
    `,
})
export class TaskOverviewPanel extends BaseFormPanel<mjBizAppsTasksTaskEntity> {}
