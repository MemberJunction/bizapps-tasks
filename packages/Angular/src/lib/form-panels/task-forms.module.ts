import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BaseFormsModule } from '@memberjunction/ng-base-forms';
import { TaskGanttComponent } from '../components/task-gantt/task-gantt.component';
import { TaskKanbanComponent } from '../components/task-kanban/task-kanban.component';
import { TaskOverviewComponent } from '../components/task-overview/task-overview.component';
import { TaskHeaderPanel } from './task-header.panel';
import { TaskSubtasksPanel } from './task-subtasks.panel';
import { TaskOverviewPanel } from './task-overview.panel';

const PANELS = [TaskHeaderPanel, TaskSubtasksPanel, TaskOverviewPanel];

@NgModule({
    declarations: [...PANELS],
    imports: [
        CommonModule,
        BaseFormsModule,
        TaskGanttComponent,
        TaskKanbanComponent,
        TaskOverviewComponent,
    ],
    exports: [...PANELS],
})
export class TasksFormsModule {}
