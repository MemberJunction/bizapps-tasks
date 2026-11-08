import { Component } from '@angular/core';
import { mjBizAppsTasksTimesheetScheduleEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Timesheet Schedules') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstimesheetschedule-form',
    templateUrl: './mjbizappstaskstimesheetschedule.form.component.html'
})
export class mjBizAppsTasksTimesheetScheduleFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTimesheetScheduleEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true }
        ]);
    }
}

