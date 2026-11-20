import { Component } from '@angular/core';
import { mjBizAppsTasksMeetingNoteEntity } from '@mj-biz-apps/tasks-entities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'MJ_BizApps_Tasks: Meeting Notes') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-mjbizappstasksmeetingnote-form',
    templateUrl: './mjbizappstasksmeetingnote.form.component.html'
})
export class mjBizAppsTasksMeetingNoteFormComponent extends BaseFormComponent {
    public record!: mjBizAppsTasksMeetingNoteEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'meetingAuthorContext', sectionName: 'Meeting & Author Context', isExpanded: true },
            { sectionKey: 'noteDetails', sectionName: 'Note Details', isExpanded: true },
            { sectionKey: 'aIGenerationTasks', sectionName: 'AI Generation & Tasks', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

