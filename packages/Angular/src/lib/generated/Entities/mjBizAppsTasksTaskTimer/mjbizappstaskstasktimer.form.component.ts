import { Component } from '@angular/core';
import { mjBizAppsTasksTaskTimerEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Task Timers') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstasktimer-form',
    templateUrl: './mjbizappstaskstasktimer.form.component.html'
})
export class mjBizAppsTasksTaskTimerFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTaskTimerEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true }
        ]);
    }
}

