import { Component } from '@angular/core';
import { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ.BizApps.Tasks: Tasks') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstask-form',
    templateUrl: './mjbizappstaskstask.form.component.html'
})
export class mjBizAppsTasksTaskFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTaskEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'mJBizAppsTasksTaskDependenciesTaskID', sectionName: 'MJ.BizApps.Tasks: Task Dependencies (Task ID)', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskTagLinks', sectionName: 'MJ.BizApps.Tasks: Task Tag Links', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskDependenciesDependsOnTaskID', sectionName: 'MJ.BizApps.Tasks: Task Dependencies (Depends On Task ID)', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskLinks', sectionName: 'MJ.BizApps.Tasks: Task Links', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskActivities', sectionName: 'MJ.BizApps.Tasks: Task Activities', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskNotificationLogs', sectionName: 'Task Notification Logs', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskComments', sectionName: 'MJ.BizApps.Tasks: Task Comments', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTasks', sectionName: 'MJ.BizApps.Tasks: Tasks', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskAssignments', sectionName: 'MJ.BizApps.Tasks: Task Assignments', isExpanded: false }
        ]);
    }
}

