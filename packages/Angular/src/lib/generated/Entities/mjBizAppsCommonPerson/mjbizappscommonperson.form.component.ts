import { Component } from '@angular/core';
import { mjBizAppsCommonPersonEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'MJ.BizApps.Common: People') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappscommonperson-form',
    templateUrl: './mjbizappscommonperson.form.component.html'
})
export class mjBizAppsCommonPersonFormComponent extends BaseFormComponent {
    public record!: mjBizAppsCommonPersonEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'personalIdentity', sectionName: 'Personal Identity', isExpanded: true },
            { sectionKey: 'professionalAndProfile', sectionName: 'Professional and Profile', isExpanded: true },
            { sectionKey: 'accountAndStatus', sectionName: 'Account and Status', isExpanded: false },
            { sectionKey: 'primaryAddress', sectionName: 'Primary Address', isExpanded: false },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskActivities', sectionName: 'MJ.BizApps.Tasks: Task Activities', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskComments', sectionName: 'MJ.BizApps.Tasks: Task Comments', isExpanded: false },
            { sectionKey: 'mJBizAppsCommonContactMethods', sectionName: 'MJ.BizApps.Common: Contact Methods', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTaskAssignments', sectionName: 'MJ.BizApps.Tasks: Task Assignments', isExpanded: false },
            { sectionKey: 'mJBizAppsTasksTasks', sectionName: 'MJ.BizApps.Tasks: Tasks', isExpanded: false },
            { sectionKey: 'mJBizAppsCommonRelationshipsToPersonID', sectionName: 'MJ.BizApps.Common: Relationships', isExpanded: false },
            { sectionKey: 'mJBizAppsCommonRelationshipsFromPersonID', sectionName: 'MJ.BizApps.Common: Relationships', isExpanded: false }
        ]);
    }
}

