import { Component } from '@angular/core';
import { mjBizAppsTasksMeetingSeriesEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Meeting Series') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstasksmeetingseries-form',
    templateUrl: './mjbizappstasksmeetingseries.form.component.html'
})
export class mjBizAppsTasksMeetingSeriesFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksMeetingSeriesEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'meetingSeriesDetails', sectionName: 'Meeting Series Details', isExpanded: true },
            { sectionKey: 'scheduleAndRecurrence', sectionName: 'Schedule and Recurrence', isExpanded: true },
            { sectionKey: 'locationAndLogistics', sectionName: 'Location and Logistics', isExpanded: true },
            { sectionKey: 'settingsAndStatus', sectionName: 'Settings and Status', isExpanded: true },
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetings', sectionName: 'Meetings', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingLinks', sectionName: 'Meeting Links', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingSeriesAttendees', sectionName: 'Meeting Series Attendees', isExpanded: false }
        ]);
    }
}

