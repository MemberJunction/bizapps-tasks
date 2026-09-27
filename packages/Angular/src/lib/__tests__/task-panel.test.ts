import '@angular/compiler';
import { describe, expect, it, vi } from 'vitest';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';
import { TaskPanelComponent } from '../components/task-panel/task-panel.component';
import { BeforeKanbanStatusChangeEvent } from '../components/task-kanban/task-kanban.component';
import type { TaskRow } from '../components/task-list/task-list.component';

describe('TaskPanelComponent', () => {
    function createPanel(cdr?: Partial<ChangeDetectorRef>): TaskPanelComponent {
        const mock: ChangeDetectorRef = {
            markForCheck: cdr?.markForCheck ?? vi.fn(),
            detach: cdr?.detach ?? vi.fn(),
            detectChanges: cdr?.detectChanges ?? vi.fn(),
            checkNoChanges: cdr?.checkNoChanges ?? vi.fn(),
            reattach: cdr?.reattach ?? vi.fn(),
        };
        const injector = Injector.create({
            providers: [{ provide: ChangeDetectorRef, useValue: mock }],
        });
        return runInInjectionContext(injector, () => new TaskPanelComponent());
    }

    it('initializes with default list view mode and opt-in allowed modes', () => {
        const component = createPanel();
        expect(component.ViewMode).toBe('list');
        expect(component.AllowedViewModes).toEqual(['list']);
        expect(component.panelMode).toBe('none');
        expect(component.selectedTaskID).toBeNull();
    });

    it('keeps ViewMode inside AllowedViewModes and falls back to first allowed mode', () => {
        const component = createPanel();

        // When AllowedViewModes does not include current ViewMode ('list'), it falls back to first allowed mode
        component.AllowedViewModes = ['kanban', 'gantt'];
        expect(component.ViewMode).toBe('kanban');

        // Setting a ViewMode outside AllowedViewModes falls back to first allowed mode
        component.ViewMode = 'list';
        expect(component.ViewMode).toBe('kanban');

        // Setting a valid ViewMode succeeds
        component.ViewMode = 'gantt';
        expect(component.ViewMode).toBe('gantt');

        // If AllowedViewModes is set to empty array, it gracefully keeps the default list
        component.AllowedViewModes = [];
        expect(component.AllowedViewModes).toEqual(['list']);
        expect(component.ViewMode).toBe('list');
    });

    it('switches view mode via SetViewMode and emits ViewModeChange', () => {
        const component = createPanel();
        component.AllowedViewModes = ['list', 'kanban', 'gantt'];

        const emitted: string[] = [];
        component.ViewModeChange.subscribe(mode => emitted.push(mode));

        component.SetViewMode('kanban');
        expect(component.ViewMode).toBe('kanban');
        expect(emitted).toEqual(['kanban']);

        component.SetViewMode('gantt');
        expect(component.ViewMode).toBe('gantt');
        expect(emitted).toEqual(['kanban', 'gantt']);

        // Attempting to set disallowed mode does nothing
        component.AllowedViewModes = ['list'];
        component.SetViewMode('kanban');
        expect(component.ViewMode).toBe('list');
    });

    it('routes kanban status changes through unified BeforeStatusChange and AfterStatusChange', () => {
        const component = createPanel();
        component.AllowedViewModes = ['list', 'kanban'];
        component.SetViewMode('kanban');

        let beforeFired = false;
        let beforeTaskID = '';
        let beforeNewStatus = '';
        component.BeforeStatusChange.subscribe(e => {
            beforeFired = true;
            beforeTaskID = e.Task.ID;
            beforeNewStatus = e.NewStatus;
        });

        let afterFired = false;
        let afterTaskID = '';
        let afterNewStatus = '';
        component.AfterStatusChange.subscribe(task => {
            afterFired = true;
            afterTaskID = task.ID;
            afterNewStatus = task.Status;
        });

        const kanbanBefore = new BeforeKanbanStatusChangeEvent(
            'task-1',
            'Open',
            'InProgress',
            { ID: 'task-1', Title: 'Test Task', ColumnKey: 'Open' }
        );
        component.onKanbanBeforeStatusChange(kanbanBefore);

        expect(beforeFired).toBe(true);
        expect(beforeTaskID).toBe('task-1');
        expect(beforeNewStatus).toBe('InProgress');
        expect(kanbanBefore.Cancel).toBe(false);

        component.onKanbanStatusChange({ TaskID: 'task-1', NewStatus: 'InProgress' });
        expect(afterFired).toBe(true);
        expect(afterTaskID).toBe('task-1');
        expect(afterNewStatus).toBe('InProgress');
    });

    it('cancelling BeforeStatusChange cancels the kanban move', () => {
        const component = createPanel();
        component.BeforeStatusChange.subscribe(e => {
            e.Cancel = true;
        });

        const kanbanBefore = new BeforeKanbanStatusChangeEvent(
            'task-1',
            'Open',
            'InProgress',
            { ID: 'task-1', Title: 'Test Task', ColumnKey: 'Open' }
        );
        component.onKanbanBeforeStatusChange(kanbanBefore);

        expect(kanbanBefore.Cancel).toBe(true);
    });

    it('opens and closes slide-in detail panel on task click and emits TaskSelected', () => {
        const component = createPanel();
        const taskID = 'task-uuid-1234';

        let selectedID = '';
        component.TaskSelected.subscribe(id => { selectedID = id; });

        component.onTaskClicked(taskID);
        expect(selectedID).toBe(taskID);
        expect(component.panelMode).toBe('detail');
        expect(component.selectedTaskID).toBe(taskID);

        component.closePanel();
        expect(component.panelMode).toBe('none');
        expect(component.selectedTaskID).toBeNull();
    });

    it('delegates Refresh to all active views', () => {
        const component = createPanel();
        const mockList = { Refresh: vi.fn() };
        const mockKanban = { Refresh: vi.fn() };
        const mockGantt = { Refresh: vi.fn() };

        component.taskList = mockList as unknown as TaskPanelComponent['taskList'];
        component.taskKanban = mockKanban as unknown as TaskPanelComponent['taskKanban'];
        component.taskGantt = mockGantt as unknown as TaskPanelComponent['taskGantt'];

        component.Refresh();
        expect(mockList.Refresh).toHaveBeenCalled();
        expect(mockKanban.Refresh).toHaveBeenCalled();
        expect(mockGantt.Refresh).toHaveBeenCalled();
    });
});
