import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BaseFormsModule } from '@memberjunction/ng-base-forms';
import { HierarchyTreeComponent } from '@memberjunction/ng-hierarchy-tree';
import { MJViewToggleComponent } from '@memberjunction/ng-ui-components';
import {
    TaskCompletionRingComponent,
    TaskQuickCaptureComponent,
    TaskWorkflowStepperComponent,
} from '@mj-biz-apps/tasks-ng-widgets';
import { TaskGanttComponent } from '../components/task-gantt/task-gantt.component';
import { TaskKanbanComponent } from '../components/task-kanban/task-kanban.component';
import { TaskListComponent } from '../components/task-list/task-list.component';
import { TaskOverviewComponent } from '../components/task-overview/task-overview.component';
import { TaskTimeEffortComponent } from '../components/task-time-effort/task-time-effort.component';
import { TaskCategoryHierarchyPanel } from './task-category-hierarchy.panel';
import { TaskHeaderPanel } from './task-header.panel';
import { TaskOverviewPanel } from './task-overview.panel';
import { TaskSubtasksPanel } from './task-subtasks.panel';
import { TaskTimePanel } from './task-time.panel';
import { TaskTemplateItemHierarchyPanel } from './task-template-item-hierarchy.panel';

const MODULE_PANELS = [TaskHeaderPanel, TaskSubtasksPanel, TaskOverviewPanel, TaskTimePanel];

@NgModule({
    declarations: [...MODULE_PANELS],
    imports: [
        CommonModule,
        BaseFormsModule,
        HierarchyTreeComponent,
        MJViewToggleComponent,
        TaskCompletionRingComponent,
        TaskWorkflowStepperComponent,
        TaskQuickCaptureComponent,
        TaskListComponent,
        TaskGanttComponent,
        TaskKanbanComponent,
        TaskOverviewComponent,
        TaskTimeEffortComponent,
        TaskCategoryHierarchyPanel,
        TaskTemplateItemHierarchyPanel,
    ],
    exports: [
        ...MODULE_PANELS,
        TaskCategoryHierarchyPanel,
        TaskTemplateItemHierarchyPanel,
    ],
})
export class TasksFormsModule {}
