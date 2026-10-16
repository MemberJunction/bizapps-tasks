import { Component } from '@angular/core';
import { mjBizAppsTasksMeetingAgendaItemEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Meeting Agenda Items') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstasksmeetingagendaitem-form',
    templateUrl: './mjbizappstasksmeetingagendaitem.form.component.html'
})
export class mjBizAppsTasksMeetingAgendaItemFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksMeetingAgendaItemEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'meetingContext', sectionName: 'Meeting Context', isExpanded: true },
            { sectionKey: 'hierarchyAndOrdering', sectionName: 'Hierarchy and Ordering', isExpanded: true },
            { sectionKey: 'agendaItemDetails', sectionName: 'Agenda Item Details', isExpanded: true },
            { sectionKey: 'presenterAndTiming', sectionName: 'Presenter and Timing', isExpanded: true },
            { sectionKey: 'meetingExecutionAndOutcome', sectionName: 'Meeting Execution and Outcome', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingAgendaItems', sectionName: 'Meeting Agenda Items', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingNotes', sectionName: 'Meeting Notes', isExpanded: false }
        ]);
    }
}

