import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BaseFormsModule } from '@memberjunction/ng-base-forms';
import { TaskGanttComponent } from '../components/task-gantt/task-gantt.component';
import { TaskKanbanComponent } from '../components/task-kanban/task-kanban.component';
import { TaskOverviewComponent } from '../components/task-overview/task-overview.component';
import { TaskTimeEffortComponent } from '../components/task-time-effort/task-time-effort.component';
import { TaskHeaderPanel } from './task-header.panel';
import { TaskSubtasksPanel } from './task-subtasks.panel';
import { TaskOverviewPanel } from './task-overview.panel';
import { TaskTimePanel } from './task-time.panel';
import { TaskCategoryHierarchyPanel } from './task-category-hierarchy.panel';
import { TaskTemplateItemHierarchyPanel } from './task-template-item-hierarchy.panel';
import { HierarchyTreeComponent } from '@memberjunction/ng-hierarchy-tree';

const MODULE_PANELS = [TaskHeaderPanel, TaskSubtasksPanel, TaskOverviewPanel, TaskTimePanel];

@NgModule({
    declarations: [...MODULE_PANELS],
    imports: [
        CommonModule,
        BaseFormsModule,
        HierarchyTreeComponent,
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
