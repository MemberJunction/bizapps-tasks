import { Component } from '@angular/core';
import { mjBizAppsTasksMeetingEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Meetings') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstasksmeeting-form',
    templateUrl: './mjbizappstasksmeeting.form.component.html'
})
export class mjBizAppsTasksMeetingFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksMeetingEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'mJBizAppsTasksMeetingAgendaItemsMeetingID', sectionName: 'Meeting Agenda Items (Meeting ID)', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingAgendaItemsDeferredToMeetingID', sectionName: 'Meeting Agenda Items (Deferred To Meeting ID)', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingAttendees', sectionName: 'Meeting Attendees', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingNotes', sectionName: 'Meeting Notes', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingLinks', sectionName: 'Meeting Links', isExpanded: false }
        ]);
    }
}

