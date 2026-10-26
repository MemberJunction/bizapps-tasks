import { Component } from '@angular/core';
import { mjBizAppsTasksMeetingAttendeeEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Meeting Attendees') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstasksmeetingattendee-form',
    templateUrl: './mjbizappstasksmeetingattendee.form.component.html'
})
export class mjBizAppsTasksMeetingAttendeeFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksMeetingAttendeeEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true }
        ]);
    }
}

