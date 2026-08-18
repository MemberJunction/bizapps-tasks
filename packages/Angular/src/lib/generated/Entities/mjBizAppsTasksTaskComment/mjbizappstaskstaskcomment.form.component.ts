import { Component } from '@angular/core';
import { mjBizAppsTasksTaskCommentEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Task Comments') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstaskstaskcomment-form',
    templateUrl: './mjbizappstaskstaskcomment.form.component.html'
})
export class mjBizAppsTasksTaskCommentFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksTaskCommentEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'taskContext', sectionName: 'Task Context', isExpanded: true },
            { sectionKey: 'threadingInformation', sectionName: 'Threading Information', isExpanded: true },
            { sectionKey: 'authorInformation', sectionName: 'Author Information', isExpanded: true },
            { sectionKey: 'commentContent', sectionName: 'Comment Content', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskComments', sectionName: 'Task Comments', isExpanded: false }
        ]);
    }
}

