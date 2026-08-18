import { Component, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RegisterClassEx } from '@memberjunction/global';
import { BaseFormPanel, BaseFormsModule } from '@memberjunction/ng-base-forms';
import { HierarchyTreeComponent, HierarchyTreeConfig } from '@memberjunction/ng-hierarchy-tree';
import { mjBizAppsTasksTaskCategoryEntity } from '@mj-biz-apps/tasks-entities';

/**
 * Task Category Hierarchy & Taxonomy Tree Panel.
 *
 * Attaches to `MJ_BizApps_Tasks: Task Categories` and provides an interactive
 * taxonomy visualizer powered by `@memberjunction/ng-hierarchy-tree`.
 */
@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:TaskCategories:taxonomy',
    metadata: {
        entity: 'MJ_BizApps_Tasks: Task Categories',
        slot: 'after-related',
        sortKey: 40,
        relatedEntity: 'MJ_BizApps_Tasks: Task Categories',
        relatedJoinField: 'ParentCategoryID'
    }
})
@Component({
    selector: 'bizapps-task-category-hierarchy-panel',
    standalone: true,
    imports: [CommonModule, BaseFormsModule, HierarchyTreeComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    template: `
        <mj-collapsible-panel
            SectionKey="taskCategoryTaxonomy"
            SectionName="Category Hierarchy & Taxonomy"
            Icon="fa-solid fa-sitemap"
            Variant="related-entity"
            [Form]="FormComponent"
            [FormContext]="FormContext"
            [DefaultExpanded]="true">
            @if (Record.IsSaved) {
                <mj-hierarchy-tree
                    [Config]="treeConfig"
                    (Navigate)="FormComponent.OnFormNavigate($event)">
                </mj-hierarchy-tree>
            }
        </mj-collapsible-panel>
    `,
    styles: [`
        :host {
            display: block;
            width: 100%;
            margin-bottom: 20px;
        }
    `]
})
export class TaskCategoryHierarchyPanel extends BaseFormPanel<mjBizAppsTasksTaskCategoryEntity> {
    public get treeConfig(): HierarchyTreeConfig {
        return {
            EntityName: 'MJ_BizApps_Tasks: Task Categories',
            ParentField: 'ParentCategoryID',
            SubtitleField: 'Description',
            DefaultIcon: 'fa-solid fa-folder-tree',
            DefaultColor: '#6366f1',
            FocusRecordID: this.Record?.ID || undefined,
            Height: '440px',
            ShowSearch: true,
            ShowToolbar: true
        };
    }
}
