import {
    AfterViewInit,
    ChangeDetectorRef,
    Component,
    ElementRef,
    OnDestroy,
    ViewChild,
    inject,
} from '@angular/core';
import { CompositeKey, Metadata } from '@memberjunction/core';
import { RegisterClassEx } from '@memberjunction/global';
import { UserInfoEngine } from '@memberjunction/core-entities';
import { BaseFormPanel, FormNavigationEvent } from '@memberjunction/ng-base-forms';
import { HierarchyTreeConfig } from '@memberjunction/ng-hierarchy-tree';
import type { ViewToggleOption } from '@memberjunction/ng-ui-components';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import type { TaskQuickCaptureSubmitEvent } from '@mj-biz-apps/tasks-ng-widgets';
import { TaskGanttComponent } from '../components/task-gantt/task-gantt.component';
import { TaskKanbanComponent } from '../components/task-kanban/task-kanban.component';
import { TaskListComponent } from '../components/task-list/task-list.component';
import { TASKS_ENTITY } from '../open-task-record';

const SECTION_KEY = 'subtasks';

@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:Tasks:subtasks',
    metadata: {
        entity: TASKS_ENTITY,
        slot: 'after-related',
        sortKey: 90,
        relatedEntity: TASKS_ENTITY,
        relatedJoinField: 'ParentID',
        contributionKey: SECTION_KEY,
    },
})
@Component({
    standalone: false,
    selector: 'mjt-task-subtasks-panel',
    templateUrl: './task-subtasks.panel.html',
    styleUrls: ['./task-form.css'],
})
export class TaskSubtasksPanel extends BaseFormPanel<mjBizAppsTasksTaskEntity> implements AfterViewInit, OnDestroy {
    private cdr = inject(ChangeDetectorRef);
    public readonly SectionKey = SECTION_KEY;
    public View: 'list' | 'gantt' | 'kanban' | 'hierarchy' = 'list';
    public AddingChild = false;

    public readonly ViewOptions: ViewToggleOption[] = [
        { key: 'list', icon: 'fa-solid fa-list', label: 'List', title: 'Sub-task List' },
        { key: 'gantt', icon: 'fa-solid fa-chart-gantt', label: 'Timeline', title: 'Sub-task Timeline' },
        { key: 'kanban', icon: 'fa-solid fa-table-columns', label: 'Board', title: 'Sub-task Board' },
        { key: 'hierarchy', icon: 'fa-solid fa-sitemap', label: 'Hierarchy', title: 'Sub-task Hierarchy Tree' },
    ];

    @ViewChild('subtaskFill', { static: false }) public subtaskFillRef?: ElementRef<HTMLElement>;
    @ViewChild('subList', { static: false }) public subList?: TaskListComponent;
    @ViewChild('subGantt', { static: false }) public subGantt?: TaskGanttComponent;
    @ViewChild('subKanban', { static: false }) public subKanban?: TaskKanbanComponent;

    public ComputedHeight = '520px';

    private readonly SETTING_KEY = 'mj.hierarchyTree.zoom.tasks';
    private _treeConfig: HierarchyTreeConfig | null = null;
    private _cachedRecordId: string | null = null;
    private _cachedHeight: string | null = null;

    private resizeObserver?: ResizeObserver;
    private boundOnResize = () => this.updateComputedHeight();

    public ngAfterViewInit(): void {
        this.updateComputedHeight();
        window.addEventListener('resize', this.boundOnResize);
        if (typeof ResizeObserver !== 'undefined') {
            this.resizeObserver = new ResizeObserver(() => this.updateComputedHeight());
            this.resizeObserver.observe(document.body);
            if (this.subtaskFillRef?.nativeElement) {
                this.resizeObserver.observe(this.subtaskFillRef.nativeElement);
            }
        }
    }

    public ngOnDestroy(): void {
        window.removeEventListener('resize', this.boundOnResize);
        this.resizeObserver?.disconnect();
    }

    public updateComputedHeight(): void {
        if (!this.subtaskFillRef?.nativeElement) return;
        const rect = this.subtaskFillRef.nativeElement.getBoundingClientRect();
        const bottomSafetyPadding = 28;
        const available = window.innerHeight - rect.top - bottomSafetyPadding;
        const next = `${Math.floor(Math.max(360, available))}px`;
        if (next !== this.ComputedHeight) {
            this.ComputedHeight = next;
            this.cdr.markForCheck();
        }
    }

    public get ParentFilter(): string | null {
        if (!this.Record?.IsSaved) return null;
        return `ParentID = '${this.Record.ID}'`;
    }

    public OpenChild(taskID: string): void {
        this.FormComponent.OnFormNavigate({
            Kind: 'record',
            EntityName: TASKS_ENTITY,
            PrimaryKey: CompositeKey.FromID(taskID),
        });
    }

    public OnViewToggleChange(key: string): void {
        this.SetView(key as 'list' | 'gantt' | 'kanban' | 'hierarchy');
    }

    public SetView(view: 'list' | 'gantt' | 'kanban' | 'hierarchy'): void {
        this.View = view;
        setTimeout(() => this.updateComputedHeight(), 0);
        this.cdr.markForCheck();
    }

    public async OnQuickAddChild(event: TaskQuickCaptureSubmitEvent): Promise<void> {
        if (!this.Record?.IsSaved || !event.Title || this.AddingChild) return;
        this.AddingChild = true;
        this.cdr.markForCheck();
        try {
            const child = await Metadata.Provider.GetEntityObject<mjBizAppsTasksTaskEntity>(TASKS_ENTITY);
            child.NewRecord();
            child.Name = event.Title;
            child.ParentID = this.Record.ID;
            child.TypeID = this.Record.TypeID;
            child.CategoryID = this.Record.CategoryID;
            child.Status = 'Open';
            child.Priority = event.Priority ?? this.Record.Priority;
            if (event.DueAt) child.DueAt = event.DueAt;
            if (event.HoursEstimated != null) child.HoursEstimated = event.HoursEstimated;
            if (await child.Save()) {
                void this.subList?.Refresh();
                this.subGantt?.Refresh();
                this.subKanban?.Refresh();
            }
        } finally {
            this.AddingChild = false;
            this.cdr.markForCheck();
        }
    }

    public get persistedZoomLevel(): number | undefined {
        const raw = UserInfoEngine.Instance.GetSetting(this.SETTING_KEY);
        return raw ? parseFloat(raw) : undefined;
    }

    public onZoomChange(zoom: number): void {
        UserInfoEngine.Instance.SetSettingDebounced(this.SETTING_KEY, zoom.toFixed(2));
    }

    public onNavigate(event: FormNavigationEvent): void {
        if (this.FormComponent?.OnFormNavigate) {
            this.FormComponent.OnFormNavigate(event);
        }
    }

    public get treeConfig(): HierarchyTreeConfig {
        const recId = this.Record?.ID || null;
        if (!this._treeConfig || this._cachedRecordId !== recId || this._cachedHeight !== this.ComputedHeight) {
            this._cachedRecordId = recId;
            this._cachedHeight = this.ComputedHeight;
            const filter = recId
                ? `(ID = '${recId}' OR RootParentID = '${recId}' OR ParentID = '${recId}')`
                : '';
            this._treeConfig = {
                EntityName: TASKS_ENTITY,
                ParentField: 'ParentID',
                SubtitleField: 'Status',
                DefaultIcon: 'fa-solid fa-circle-check',
                DefaultColor: 'var(--mj-brand-primary)',
                ActiveRecordID: recId || undefined,
                ExtraFilter: filter,
                Height: this.ComputedHeight,
                MinHeight: '360px',
                ShowSearch: true,
                ShowToolbar: true,
                Orientation: 'top-to-bottom',
            };
        }
        return this._treeConfig;
    }
}
