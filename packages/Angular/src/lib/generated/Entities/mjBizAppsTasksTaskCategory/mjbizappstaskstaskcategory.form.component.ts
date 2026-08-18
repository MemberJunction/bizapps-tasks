import { Component } from '@angular/core';
import { mjBizAppsTasksTaskCategoryEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Task Categories') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstaskcategory-form',
    templateUrl: './mjbizappstaskstaskcategory.form.component.html'
})
export class mjBizAppsTasksTaskCategoryFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTaskCategoryEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'generalInformation', sectionName: 'General Information', isExpanded: true },
            { sectionKey: 'hierarchyDetails', sectionName: 'Hierarchy Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskTemplates', sectionName: 'Task Templates', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskCategories', sectionName: 'Task Categories', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTasks', sectionName: 'Tasks', isExpanded: false }
        ]);
    }
}

