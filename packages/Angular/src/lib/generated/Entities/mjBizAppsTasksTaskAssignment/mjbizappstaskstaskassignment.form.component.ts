import { Component } from '@angular/core';
import { mjBizAppsTasksTaskAssignmentEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'MJ.BizApps.Tasks: Task Assignments') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstaskassignment-form',
    templateUrl: './mjbizappstaskstaskassignment.form.component.html'
})
export class mjBizAppsTasksTaskAssignmentFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTaskAssignmentEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true }
        ]);
    }
}

