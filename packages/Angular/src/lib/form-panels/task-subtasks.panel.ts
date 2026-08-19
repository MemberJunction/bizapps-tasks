import { Component, ChangeDetectorRef, ElementRef, ViewChild, AfterViewInit, OnDestroy, inject } from '@angular/core';
import { CompositeKey } from '@memberjunction/core';
import { RegisterClassEx } from '@memberjunction/global';
import { BaseFormPanel, FormNavigationEvent } from '@memberjunction/ng-base-forms';
import { HierarchyTreeConfig } from '@memberjunction/ng-hierarchy-tree';
import { UserInfoEngine } from '@memberjunction/core-entities';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import { TASKS_ENTITY } from '../open-task-record';

const SECTION_KEY = 'subtasks';

@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:Tasks:subtasks',
    metadata: {
        entity: TASKS_ENTITY,
        slot: 'after-fields',
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
    public View: 'gantt' | 'kanban' | 'hierarchy' = 'gantt';

    @ViewChild('subtaskFill', { static: false }) subtaskFillRef?: ElementRef<HTMLElement>;
    public ComputedHeight: string = '520px';

    private readonly SETTING_KEY = 'mj.hierarchyTree.zoom.tasks';
    private _treeConfig: HierarchyTreeConfig | null = null;
    private _cachedRecordId: string | null = null;
    private _cachedHeight: string | null = null;

    private resizeObserver?: ResizeObserver;
    private boundOnResize = () => this.updateComputedHeight();

    ngAfterViewInit(): void {
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

    ngOnDestroy(): void {
        window.removeEventListener('resize', this.boundOnResize);
        this.resizeObserver?.disconnect();
    }

    public updateComputedHeight(): void {
        if (!this.subtaskFillRef?.nativeElement) return;
        const rect = this.subtaskFillRef.nativeElement.getBoundingClientRect();
        // Dynamically compute exact available height from top offset to viewport bottom with clean margin
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

    public SetView(view: 'gantt' | 'kanban' | 'hierarchy'): void {
        this.View = view;
        setTimeout(() => this.updateComputedHeight(), 0);
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
                DefaultColor: '#3b82f6',
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
