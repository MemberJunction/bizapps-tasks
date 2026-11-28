import { Component } from '@angular/core';
import { mjBizAppsTasksWorkReportItemEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Work Report Items') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstasksworkreportitem-form',
    templateUrl: './mjbizappstasksworkreportitem.form.component.html'
})
export class mjBizAppsTasksWorkReportItemFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksWorkReportItemEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'relationships', sectionName: 'Relationships', isExpanded: true },
            { sectionKey: 'reportItemDetails', sectionName: 'Report Item Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

