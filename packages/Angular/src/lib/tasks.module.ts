import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

// Standalone components — imported into the module for re-export convenience
import { TaskPriorityBadgeComponent } from './components/task-priority-badge/task-priority-badge.component';
import { TaskAssigneeListComponent } from './components/task-assignee-list/task-assignee-list.component';
import { TaskBulkActionsBarComponent } from './components/task-bulk-actions-bar/task-bulk-actions-bar.component';
import { TaskListComponent } from './components/task-list/task-list.component';
import { MyTasksComponent } from './components/my-tasks/my-tasks.component';
import { TaskDetailPanelComponent } from './components/task-detail-panel/task-detail-panel.component';
import { TaskEditPanelComponent } from './components/task-edit-panel/task-edit-panel.component';
import { TaskKanbanComponent } from './components/task-kanban/task-kanban.component';

@NgModule({
    imports: [
        CommonModule,
        FormsModule,
        // Standalone components
        TaskPriorityBadgeComponent,
        TaskAssigneeListComponent,
        TaskBulkActionsBarComponent,
        TaskListComponent,
        MyTasksComponent,
        TaskDetailPanelComponent,
        TaskEditPanelComponent,
        TaskKanbanComponent,
    ],
    exports: [
        TaskPriorityBadgeComponent,
        TaskAssigneeListComponent,
        TaskBulkActionsBarComponent,
        TaskListComponent,
        MyTasksComponent,
        TaskDetailPanelComponent,
        TaskEditPanelComponent,
        TaskKanbanComponent,
    ]
})
export class BizAppsTasksModule { }

/** Tree-shaking prevention — call from consuming app bootstrap */
export function LoadBizAppsTasksClient() {
    // Static imports above ensure all components are registered.
}
