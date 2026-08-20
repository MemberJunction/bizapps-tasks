import { Component } from '@angular/core';
import { mjBizAppsTasksTaskTypeStatusEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Task Type Status') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstasktypestatus-form',
    templateUrl: './mjbizappstaskstasktypestatus.form.component.html'
})
export class mjBizAppsTasksTaskTypeStatusFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTaskTypeStatusEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'statusConfiguration', sectionName: 'Status Configuration', isExpanded: true },
            { sectionKey: 'lifecycleSettings', sectionName: 'Lifecycle Settings', isExpanded: true },
            { sectionKey: 'uIPresentation', sectionName: 'UI Presentation', isExpanded: true },
            { sectionKey: 'automationHooks', sectionName: 'Automation Hooks', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTasks', sectionName: 'Tasks', isExpanded: false }
        ]);
    }
}

