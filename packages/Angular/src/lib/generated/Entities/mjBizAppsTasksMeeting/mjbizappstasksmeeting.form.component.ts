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
            { sectionKey: 'meetingDetails', sectionName: 'Meeting Details', isExpanded: true },
            { sectionKey: 'recurrenceAndSeries', sectionName: 'Recurrence and Series', isExpanded: true },
            { sectionKey: 'scheduleAndTimeline', sectionName: 'Schedule and Timeline', isExpanded: true },
            { sectionKey: 'locationAndVirtualAccess', sectionName: 'Location and Virtual Access', isExpanded: true },
            { sectionKey: 'participantsAndOwnership', sectionName: 'Participants and Ownership', isExpanded: true },
            { sectionKey: 'cancellationDetails', sectionName: 'Cancellation Details', isExpanded: true },
            { sectionKey: 'recordingAndTranscript', sectionName: 'Recording and Transcript', isExpanded: true },
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingLinks', sectionName: 'Meeting Links', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingAgendaItemsMeetingID', sectionName: 'Meeting Agenda Items (Meeting)', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingAgendaItemsDeferredToMeetingID', sectionName: 'Meeting Agenda Items (Deferred To Meeting)', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingAttendees', sectionName: 'Meeting Attendees', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingNotes', sectionName: 'Meeting Notes', isExpanded: false }
        ]);
    }
}

