import { Component } from '@angular/core';
import { mjBizAppsTasksWorkReportEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Work Reports') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstasksworkreport-form',
    templateUrl: './mjbizappstasksworkreport.form.component.html'
})
export class mjBizAppsTasksWorkReportFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksWorkReportEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'reportInformation', sectionName: 'Report Information', isExpanded: true },
            { sectionKey: 'reportContent', sectionName: 'Report Content', isExpanded: true },
            { sectionKey: 'automationReview', sectionName: 'Automation & Review', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksWorkReportItems', sectionName: 'Work Report Items', isExpanded: false }
        ]);
    }
}

