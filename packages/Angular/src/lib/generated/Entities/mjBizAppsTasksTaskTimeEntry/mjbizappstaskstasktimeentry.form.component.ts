import { Component } from '@angular/core';
import { mjBizAppsTasksTaskTimeEntryEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Task Time Entries') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstasktimeentry-form',
    templateUrl: './mjbizappstaskstasktimeentry.form.component.html'
})
export class mjBizAppsTasksTaskTimeEntryFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTaskTimeEntryEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'mJBizAppsTasksTaskTimeEntryLinks', sectionName: 'Task Time Entry Links', isExpanded: false }
        ]);
    }
}

