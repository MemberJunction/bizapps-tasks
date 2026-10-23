import { Component } from '@angular/core';
import { mjBizAppsTasksVideoProviderEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Video Providers') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstasksvideoprovider-form',
    templateUrl: './mjbizappstasksvideoprovider.form.component.html'
})
export class mjBizAppsTasksVideoProviderFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksVideoProviderEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'mJBizAppsTasksMeetingSeries', sectionName: 'Meeting Series', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetings', sectionName: 'Meetings', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingTypes', sectionName: 'Meeting Types', isExpanded: false }
        ]);
    }
}

