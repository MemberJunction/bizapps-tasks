import { Component } from '@angular/core';
import { mjBizAppsTasksMeetingAgendaItemTypeEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Meeting Agenda Item Types') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstasksmeetingagendaitemtype-form',
    templateUrl: './mjbizappstasksmeetingagendaitemtype.form.component.html'
})
export class mjBizAppsTasksMeetingAgendaItemTypeFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksMeetingAgendaItemTypeEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'itemTypeConfiguration', sectionName: 'Item Type Configuration', isExpanded: true },
            { sectionKey: 'displayAndBehavior', sectionName: 'Display and Behavior', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingAgendaItems', sectionName: 'Meeting Agenda Items', isExpanded: false }
        ]);
    }
}

