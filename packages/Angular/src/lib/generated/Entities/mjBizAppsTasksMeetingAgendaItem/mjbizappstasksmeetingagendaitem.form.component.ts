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
            { sectionKey: 'agendaItemDetails', sectionName: 'Agenda Item Details', isExpanded: true },
            { sectionKey: 'planningAndTiming', sectionName: 'Planning and Timing', isExpanded: true },
            { sectionKey: 'executionTracking', sectionName: 'Execution Tracking', isExpanded: true },
            { sectionKey: 'hierarchyDetails', sectionName: 'Hierarchy Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingAgendaItems', sectionName: 'Meeting Agenda Items', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingNotes', sectionName: 'Meeting Notes', isExpanded: false }
        ]);
    }
}

