import { Component } from '@angular/core';
import { mjBizAppsTasksTimeApproverEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Time Approvers') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstimeapprover-form',
    templateUrl: './mjbizappstaskstimeapprover.form.component.html'
})
export class mjBizAppsTasksTimeApproverFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTimeApproverEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true }
        ]);
    }
}

