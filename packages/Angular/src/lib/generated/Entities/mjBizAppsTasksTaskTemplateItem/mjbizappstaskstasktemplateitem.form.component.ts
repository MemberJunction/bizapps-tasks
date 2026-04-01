import { Component } from '@angular/core';
import { mjBizAppsTasksTaskTemplateItemEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ.BizApps.Tasks: Task Template Items') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstasktemplateitem-form',
    templateUrl: './mjbizappstaskstasktemplateitem.form.component.html'
})
export class mjBizAppsTasksTaskTemplateItemFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTaskTemplateItemEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'mJBizAppsTasksTaskTemplateItemDependenciesDependsOnItemID', sectionName: 'MJ.BizApps.Tasks: Task Template Item Dependencies (Depends On Item ID)', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskTemplateItemRoles', sectionName: 'MJ.BizApps.Tasks: Task Template Item Roles', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskTemplateItemDependenciesItemID', sectionName: 'MJ.BizApps.Tasks: Task Template Item Dependencies (Item ID)', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskTemplateItems', sectionName: 'MJ.BizApps.Tasks: Task Template Items', isExpanded: false }
        ]);
    }
}

