import { Component } from '@angular/core';
import { mjBizAppsTasksTaskAgentRunEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Task Agent Runs') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstaskagentrun-form',
    templateUrl: './mjbizappstaskstaskagentrun.form.component.html'
})
export class mjBizAppsTasksTaskAgentRunFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTaskAgentRunEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true }
        ]);
    }
}

