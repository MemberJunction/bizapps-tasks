import { Component } from '@angular/core';
import { mjBizAppsTasksTaskTemplateEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Task Templates') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstasktemplate-form',
    templateUrl: './mjbizappstaskstasktemplate.form.component.html'
})
export class mjBizAppsTasksTaskTemplateFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTaskTemplateEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'templateDetails', sectionName: 'Template Details', isExpanded: true },
            { sectionKey: 'organizationContext', sectionName: 'Organization Context', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskTemplateItems', sectionName: 'Task Template Items', isExpanded: false }
        ]);
    }
}

