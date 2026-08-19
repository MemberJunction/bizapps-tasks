import { Component, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RegisterClassEx } from '@memberjunction/global';
import { BaseFormPanel, BaseFormsModule, FormNavigationEvent } from '@memberjunction/ng-base-forms';
import { HierarchyTreeComponent, HierarchyTreeConfig } from '@memberjunction/ng-hierarchy-tree';
import { UserInfoEngine } from '@memberjunction/core-entities';
import { mjBizAppsTasksTaskTemplateItemEntity } from '@mj-biz-apps/tasks-entities';

/**
 * Task Template Item Hierarchy Tree Panel.
 *
 * Attaches to `MJ_BizApps_Tasks: Task Template Items` and provides an interactive
 * breakdown structure visualizer for nested template items powered by `@memberjunction/ng-hierarchy-tree`.
 */
@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:TaskTemplateItems:hierarchy',
    metadata: {
        entity: 'MJ_BizApps_Tasks: Task Template Items',
        slot: 'after-related',
        sortKey: 40,
        relatedEntity: 'MJ_BizApps_Tasks: Task Template Items',
        relatedJoinField: 'ParentItemID'
    }
})
@Component({
    selector: 'bizapps-task-template-item-hierarchy-panel',
    standalone: true,
    imports: [CommonModule, BaseFormsModule, HierarchyTreeComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <mj-collapsible-panel
            SectionKey="taskTemplateItemHierarchy"
            SectionName="Hierarchy"
            Icon="fa-solid fa-list-check"
            Variant="related-entity"
            [Form]="FormComponent"
            [FormContext]="FormContext"
            [DefaultExpanded]="true">
            @if (Record.IsSaved) {
                <mj-hierarchy-tree
                    [Config]="treeConfig"
                    [ZoomLevel]="persistedZoomLevel"
                    (ZoomChange)="onZoomChange($event)"
                    (Navigate)="onNavigate($event)">
                </mj-hierarchy-tree>
            }
        </mj-collapsible-panel>
    `,
    styles: [`
        :host {
            display: flex;
            flex-direction: column;
            width: 100%;
            height: 100%;
            min-height: 640px;
            min-height: calc(100vh - 280px);
            flex: 1;
            margin-bottom: 20px;
        }
    `]
})
export class TaskTemplateItemHierarchyPanel extends BaseFormPanel<mjBizAppsTasksTaskTemplateItemEntity> {
    private readonly SETTING_KEY = 'mj.hierarchyTree.zoom.task_template_items';
    private _treeConfig: HierarchyTreeConfig | null = null;
    private _cachedRecordId: string | null = null;
    private _cachedTemplateId: string | null = null;

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
        const templateId = this.Record?.TemplateID || null;
        if (!this._treeConfig || this._cachedRecordId !== recId || this._cachedTemplateId !== templateId) {
            this._cachedRecordId = recId;
            this._cachedTemplateId = templateId;
            const filter = templateId ? `TemplateID = '${templateId}'` : '';
            this._treeConfig = {
                EntityName: 'MJ_BizApps_Tasks: Task Template Items',
                ParentField: 'ParentItemID',
                SubtitleField: 'Description',
                DefaultIcon: 'fa-solid fa-list-check',
                DefaultColor: '#10b981',
                ActiveRecordID: recId || undefined,
                ExtraFilter: filter,
                Height: '100%',
                MinHeight: '640px',
                ShowSearch: true,
                ShowToolbar: true,
                Orientation: 'top-to-bottom'
            };
        }
        return this._treeConfig;
    }
}
