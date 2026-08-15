import { Component } from '@angular/core';
import { RegisterClassEx } from '@memberjunction/global';
import { BaseFormPanel } from '@memberjunction/ng-base-forms';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import {
    FormatTaskDate,
    TaskPriorityChipClass,
    TaskProgressLabel,
    TaskStatusChipClass,
} from './task-form.helpers';

@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:Tasks:header',
    metadata: {
        entity: 'MJ_BizApps_Tasks: Tasks',
        slot: 'before-fields',
        sortKey: 100,
        contributionKey: 'header',
    },
})
@Component({
    standalone: false,
    selector: 'mjt-task-header-panel',
    templateUrl: './task-header.panel.html',
    styleUrls: ['./task-form.css'],
})
export class TaskHeaderPanel extends BaseFormPanel<mjBizAppsTasksTaskEntity> {
    public get Title(): string {
        return this.Record.Name || 'New task';
    }

    public get StatusClass(): string {
        return TaskStatusChipClass(this.Record.Status);
    }

    public get PriorityClass(): string {
        return TaskPriorityChipClass(this.Record.Priority);
    }

    public get Progress(): string {
        return TaskProgressLabel(this.Record.PercentComplete);
    }

    public get Schedule(): string {
        return `${FormatTaskDate(this.Record.StartedAt)} – ${FormatTaskDate(this.Record.DueAt)}`;
    }

    public get DueLabel(): string {
        return FormatTaskDate(this.Record.DueAt);
    }

    public get TypeName(): string {
        return this.Record.Type || '—';
    }

    public get CategoryName(): string {
        return this.Record.Category || '—';
    }
}
