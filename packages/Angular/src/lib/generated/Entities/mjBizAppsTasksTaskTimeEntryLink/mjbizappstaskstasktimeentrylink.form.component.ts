import { Component } from '@angular/core';
import { mjBizAppsTasksTaskTimeEntryLinkEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Task Time Entry Links') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstasktimeentrylink-form',
    templateUrl: './mjbizappstaskstasktimeentrylink.form.component.html'
})
export class mjBizAppsTasksTaskTimeEntryLinkFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTaskTimeEntryLinkEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true }
        ]);
    }
}

