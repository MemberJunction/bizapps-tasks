import { Component } from '@angular/core';
import { mjBizAppsTasksTaskCategoryEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ.BizApps.Tasks: Task Categories') // Tell MemberJunction about this class
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
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'mJBizAppsTasksTaskCategories', sectionName: 'MJ.BizApps.Tasks: Task Categories', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskTemplates', sectionName: 'MJ.BizApps.Tasks: Task Templates', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTasks', sectionName: 'MJ.BizApps.Tasks: Tasks', isExpanded: false }
        ]);
    }
}

