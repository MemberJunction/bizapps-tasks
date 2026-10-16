import { Component } from '@angular/core';
import { mjBizAppsTasksMeetingLinkEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Meeting Links') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstasksmeetinglink-form',
    templateUrl: './mjbizappstasksmeetinglink.form.component.html'
})
export class mjBizAppsTasksMeetingLinkFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksMeetingLinkEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'meetingAssociation', sectionName: 'Meeting Association', isExpanded: true },
            { sectionKey: 'targetRecord', sectionName: 'Target Record', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

