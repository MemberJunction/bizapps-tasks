import { Component } from '@angular/core';
import { mjBizAppsTasksMeetingTypeEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Meeting Types') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstasksmeetingtype-form',
    templateUrl: './mjbizappstasksmeetingtype.form.component.html'
})
export class mjBizAppsTasksMeetingTypeFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksMeetingTypeEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'meetingTypeDetails', sectionName: 'Meeting Type Details', isExpanded: true },
            { sectionKey: 'defaultMeetingSettings', sectionName: 'Default Meeting Settings', isExpanded: true },
            { sectionKey: 'templatesAndPrompts', sectionName: 'Templates and Prompts', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetingSeries', sectionName: 'Meeting Series', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksMeetings', sectionName: 'Meetings', isExpanded: false }
        ]);
    }
}

