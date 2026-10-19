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
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'mJBizAppsTasksMeetingAgendaItems', sectionName: 'Meeting Agenda Items', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingNotes', sectionName: 'Meeting Notes', isExpanded: false }
        ]);
    }
}

