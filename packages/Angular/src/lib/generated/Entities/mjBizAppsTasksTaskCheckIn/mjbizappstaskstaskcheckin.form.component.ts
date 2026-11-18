import { Component } from '@angular/core';
import { mjBizAppsTasksTaskCheckInEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Task Check Ins') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstaskcheckin-form',
    templateUrl: './mjbizappstaskstaskcheckin.form.component.html'
})
export class mjBizAppsTasksTaskCheckInFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTaskCheckInEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'checkInDetails', sectionName: 'Check-In Details', isExpanded: true },
            { sectionKey: 'authorshipAndAgents', sectionName: 'Authorship and Agents', isExpanded: true },
            { sectionKey: 'statusAndMetrics', sectionName: 'Status and Metrics', isExpanded: true },
            { sectionKey: 'progressNarrative', sectionName: 'Progress Narrative', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

