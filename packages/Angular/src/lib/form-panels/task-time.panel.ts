import { ChangeDetectionStrategy, ChangeDetectorRef, Component, inject, OnInit } from '@angular/core';
import { Metadata } from '@memberjunction/core';
import { RegisterClassEx } from '@memberjunction/global';
import { BaseFormPanel } from '@memberjunction/ng-base-forms';
import { TasksSettings } from '@mj-biz-apps/tasks-core';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';

/**
 * Form panel contributing the **Time & Effort** section to the generic
 * `MJ_BizApps_Tasks: Tasks` entity form (`slot: 'after-fields'`, `sortKey: 250`).
 *
 * Renders nothing when `TimeTrackingEnabled` is `false`.
 */
@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:Tasks:time',
    metadata: {
        entity: 'MJ_BizApps_Tasks: Tasks',
        slot: 'after-fields',
        sortKey: 250,
        contributionKey: 'time',
    },
})
@Component({
    selector: 'mjt-task-time-panel',
    standalone: false,
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        @if (timeTrackingEnabled && taskId) {
            <mj-collapsible-panel
                SectionKey="time"
                SectionName="Time & Effort">
                <bizapps-task-time-effort
                    [TaskID]="taskId"
                    [ReadOnly]="!FormComponent.EditMode">
                </bizapps-task-time-effort>
            </mj-collapsible-panel>
        }
    `,
})
export class TaskTimePanel extends BaseFormPanel<mjBizAppsTasksTaskEntity> implements OnInit {
    public timeTrackingEnabled = false;
    private cdr = inject(ChangeDetectorRef);

    public get taskId(): string | null {
        return this.Record?.ID || null;
    }

    public ngOnInit(): void {
        void this.checkEnabled();
    }

    private async checkEnabled(): Promise<void> {
        try {
            await TasksSettings.Load(Metadata.Provider);
        } catch {
            // Fall back to cached / default settings
        }
        this.timeTrackingEnabled = TasksSettings.TimeTrackingEnabled(Metadata.Provider);
        this.cdr.markForCheck();
    }
}
