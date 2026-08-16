import { Component, OnInit, ChangeDetectorRef, inject } from '@angular/core';
import { RegisterClassEx } from '@memberjunction/global';
import { BaseFormPanel } from '@memberjunction/ng-base-forms';
import { UserInfoEngine } from '@memberjunction/core-entities';
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
        slot: 'header',
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
export class TaskHeaderPanel extends BaseFormPanel<mjBizAppsTasksTaskEntity> implements OnInit {
    private cdr = inject(ChangeDetectorRef);
    public IsCollapsed = false;

    private get StorageKey(): string {
        const id = this.Record?.ID ? String(this.Record.ID).toLowerCase() : 'new';
        return `mj.taskHero.collapsed.${id}`;
    }

    public ngOnInit(): void {
        const raw = UserInfoEngine.Instance.GetSetting(this.StorageKey);
        if (raw) {
            try {
                this.IsCollapsed = JSON.parse(raw) === true;
            } catch {
                this.IsCollapsed = false;
            }
        }
    }

    public ToggleCollapse(): void {
        this.IsCollapsed = !this.IsCollapsed;
        UserInfoEngine.Instance.SetSettingDebounced(this.StorageKey, JSON.stringify(this.IsCollapsed));
        this.cdr.detectChanges();
    }

    public get Title(): string {
        return this.Record?.Name || 'New Task';
    }

    public get StatusClass(): string {
        return TaskStatusChipClass(this.Record?.Status);
    }

    public get PriorityClass(): string {
        return TaskPriorityChipClass(this.Record?.Priority);
    }

    public get Progress(): string {
        return TaskProgressLabel(this.Record?.PercentComplete);
    }

    public get Schedule(): string {
        if (!this.Record?.StartedAt && !this.Record?.DueAt) return '—';
        return `${FormatTaskDate(this.Record?.StartedAt)} – ${FormatTaskDate(this.Record?.DueAt)}`;
    }

    public get DueLabel(): string {
        return FormatTaskDate(this.Record?.DueAt);
    }

    public get TypeName(): string {
        return this.Record?.Type || 'Task';
    }

    public get CategoryName(): string {
        return this.Record?.Category || 'General';
    }

    public get EstimatedHours(): number {
        return Number(this.Record?.Get('EstimatedHours') || 0);
    }

    public get ActualHours(): number {
        return Number(this.Record?.Get('ActualHours') || 0);
    }
}
