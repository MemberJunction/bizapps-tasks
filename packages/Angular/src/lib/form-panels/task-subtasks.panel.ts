import { Component } from '@angular/core';
import { CompositeKey } from '@memberjunction/core';
import { RegisterClassEx } from '@memberjunction/global';
import { BaseFormPanel } from '@memberjunction/ng-base-forms';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';
import { TASKS_ENTITY } from '../open-task-record';

const SECTION_KEY = 'subtasks';

@RegisterClassEx(BaseFormPanel, {
    key: 'form-panel:Tasks:subtasks',
    metadata: {
        entity: TASKS_ENTITY,
        slot: 'after-fields',
        sortKey: 90,
        relatedEntity: TASKS_ENTITY,
        relatedJoinField: 'ParentID',
        contributionKey: SECTION_KEY,
    },
})
@Component({
    standalone: false,
    selector: 'mjt-task-subtasks-panel',
    templateUrl: './task-subtasks.panel.html',
    styleUrls: ['./task-form.css'],
})
export class TaskSubtasksPanel extends BaseFormPanel<mjBizAppsTasksTaskEntity> {
    public readonly SectionKey = SECTION_KEY;
    public View: 'gantt' | 'kanban' = 'gantt';

    public get ParentFilter(): string | null {
        if (!this.Record.IsSaved) return null;
        return `ParentID = '${this.Record.ID}'`;
    }

    public OpenChild(taskID: string): void {
        this.FormComponent.OnFormNavigate({
            Kind: 'record',
            EntityName: TASKS_ENTITY,
            PrimaryKey: CompositeKey.FromID(taskID),
        });
    }

    public SetView(view: 'gantt' | 'kanban'): void {
        this.View = view;
    }
}
