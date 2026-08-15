import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BaseFormsModule } from '@memberjunction/ng-base-forms';
import { TaskGanttComponent } from '../components/task-gantt/task-gantt.component';
import { TaskKanbanComponent } from '../components/task-kanban/task-kanban.component';
import { TaskHeaderPanel } from './task-header.panel';
import { TaskSubtasksPanel } from './task-subtasks.panel';

const PANELS = [TaskHeaderPanel, TaskSubtasksPanel];

@NgModule({
    declarations: [...PANELS],
    imports: [
        CommonModule,
        BaseFormsModule,
        TaskGanttComponent,
        TaskKanbanComponent,
    ],
    exports: [...PANELS],
})
export class TasksFormsModule {}
