import { Component, OnInit, OnChanges, SimpleChanges, ChangeDetectorRef, inject } from '@angular/core';
import { CompositeKey, Metadata } from '@memberjunction/core';
import { RegisterClassEx } from '@memberjunction/global';
import { BaseFormPanel } from '@memberjunction/ng-base-forms';
import { UserInfoEngine } from '@memberjunction/core-entities';
import { FormatTaskStatusLabel, TasksEngineBase } from '@mj-biz-apps/tasks-core';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import type { TaskStatusValue, TaskWidgetLinkedRecord, TaskWidgetTypeStatus } from '@mj-biz-apps/tasks-ng-widgets';
import { LoadTaskRecordLinks, type TaskRecordLink } from '../task-record-links';
import { EnsureTasksEngineLoaded, MapTaskTypeStatusesToWidget } from '../tasks-engine.helper';
import {
    FormatTaskDate,
    TaskPriorityChipClass,
    TaskProgressLabel,
    TaskStatusChipClass,
} from './task-form.helpers';

/**
 * Context-Connected Living Task Header Panel (`slot: 'header'`).
 *
 * - Breadcrumb ancestry (`Parent` link via `mjRecordLink`)
 * - 1-click `<mjt-completion-ring>` to toggle Completed/Open directly from the form hero
 * - Clickable `<mjt-workflow-stepper>` for custom `TaskTypeStatus` stages
 * - Connected Business Records strip (`TaskLinks` resolved via `LoadTaskRecordLinks`)
 * - Strongly typed `Record.HoursEstimated` & `Record.HoursActual` (zero `.Get()`)
 * - Pure MJ semantic `--mj-*` tokens & `UserInfoEngine` collapse persistence
 */
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
export class TaskHeaderPanel extends BaseFormPanel<mjBizAppsTasksTaskEntity> implements OnInit, OnChanges {
    private cdr = inject(ChangeDetectorRef);

    public IsCollapsed = false;
    public TypeStatuses: TaskWidgetTypeStatus[] = [];
    public LinkedRecords: TaskWidgetLinkedRecord[] = [];
    public Busy = false;

    private loadedTaskId: string | null = null;

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
        void this.loadHeaderContext();
    }

    public ngOnChanges(changes: SimpleChanges): void {
        if (changes['Record'] && this.Record?.ID !== this.loadedTaskId) {
            void this.loadHeaderContext();
        }
    }

    private async loadHeaderContext(): Promise<void> {
        if (!this.Record?.IsSaved || !this.Record.ID) {
            this.TypeStatuses = [];
            this.LinkedRecords = [];
            return;
        }
        this.loadedTaskId = this.Record.ID;
        try {
            const [engine, linksMap] = await Promise.all([
                this.Record.TypeID ? EnsureTasksEngineLoaded(Metadata.Provider) : Promise.resolve(TasksEngineBase.Instance),
                LoadTaskRecordLinks([this.Record.ID]).catch(() => new Map<string, TaskRecordLink[]>()),
            ]);

            this.TypeStatuses = this.Record.TypeID
                ? MapTaskTypeStatusesToWidget(engine.StatusesForType(this.Record.TypeID, true))
                : [];
            const links = linksMap.get(this.Record.ID.toLowerCase()) ?? [];
            this.LinkedRecords = links.map((l) => ({
                EntityName: l.EntityName,
                RecordID: l.RecordID,
                DisplayName: l.Name,
                IconClass: Metadata.Provider.EntityByName(l.EntityName)?.Icon || 'fa-solid fa-link',
            }));
        } finally {
            this.cdr.markForCheck();
        }
    }

    public ToggleCollapse(): void {
        this.IsCollapsed = !this.IsCollapsed;
        UserInfoEngine.Instance.SetSettingDebounced(this.StorageKey, JSON.stringify(this.IsCollapsed));
        this.cdr.markForCheck();
    }

    public async OnCompletionToggled(nextStatus: TaskStatusValue): Promise<void> {
        if (!this.Record?.IsSaved || this.Busy) return;
        this.Busy = true;
        this.cdr.markForCheck();
        try {
            this.Record.Status = nextStatus;
            this.Record.PercentComplete = nextStatus === 'Completed' ? 100 : 0;
            await this.Record.Save();
        } finally {
            this.Busy = false;
            this.cdr.markForCheck();
        }
    }

    public async OnStageSelected(stage: TaskWidgetTypeStatus): Promise<void> {
        if (!this.Record?.IsSaved || this.Busy) return;
        this.Busy = true;
        this.cdr.markForCheck();
        try {
            this.Record.TaskTypeStatusID = stage.ID;
            this.Record.Status = stage.MacroStatus;
            if (stage.MacroStatus === 'Completed') {
                this.Record.PercentComplete = 100;
            }
            await this.Record.Save();
        } finally {
            this.Busy = false;
            this.cdr.markForCheck();
        }
    }

    public OpenLinkedRecord(rec: TaskWidgetLinkedRecord): void {
        this.FormComponent.OnFormNavigate({
            Kind: 'record',
            EntityName: rec.EntityName,
            PrimaryKey: CompositeKey.FromID(rec.RecordID),
        });
    }

    public get Title(): string {
        return this.Record?.Name || 'New Task';
    }

    public get StatusLabel(): string {
        return FormatTaskStatusLabel(this.Record?.Status);
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
        return Number(this.Record?.HoursEstimated ?? 0);
    }

    public get ActualHours(): number {
        return Number(this.Record?.HoursActual ?? 0);
    }
}
