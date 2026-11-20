import { Component } from '@angular/core';
import { mjBizAppsTasksMeetingSeriesAttendeeEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Meeting Series Attendees') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstasksmeetingseriesattendee-form',
    templateUrl: './mjbizappstasksmeetingseriesattendee.form.component.html'
})
export class mjBizAppsTasksMeetingSeriesAttendeeFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksMeetingSeriesAttendeeEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true }
        ]);
    }
}

