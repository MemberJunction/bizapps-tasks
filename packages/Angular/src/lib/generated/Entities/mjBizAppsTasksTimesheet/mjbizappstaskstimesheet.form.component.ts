import { Component } from '@angular/core';
import { mjBizAppsTasksTimesheetEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Timesheets') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstimesheet-form',
    templateUrl: './mjbizappstaskstimesheet.form.component.html'
})
export class mjBizAppsTasksTimesheetFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTimesheetEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'mJBizAppsTasksTimesheetLinks', sectionName: 'Timesheet Links', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTimesheetApprovals', sectionName: 'Timesheet Approvals', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskTimeEntries', sectionName: 'Task Time Entries', isExpanded: false }
        ]);
    }
}

