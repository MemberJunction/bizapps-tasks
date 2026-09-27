import '@angular/compiler';
import { describe, expect, it, vi } from 'vitest';
import type { ChangeDetectorRef } from '@angular/core';
import { TaskPanelComponent } from '../components/task-panel/task-panel.component';

describe('TaskPanelComponent', () => {
    const mockCdr: ChangeDetectorRef = {
        markForCheck: vi.fn(),
        detach: vi.fn(),
        detectChanges: vi.fn(),
        checkNoChanges: vi.fn(),
        reattach: vi.fn(),
    };

    it('initializes with default list view mode and allowed modes', () => {
        const component = new TaskPanelComponent(mockCdr);
        expect(component.ViewMode).toBe('list');
        expect(component.AllowedViewModes).toEqual(['list', 'kanban', 'gantt']);
        expect(component.panelMode).toBe('none');
        expect(component.selectedTaskID).toBeNull();
    });

    it('switches view mode and emits ViewModeChange', () => {
        const component = new TaskPanelComponent(mockCdr);
        const emitted: string[] = [];
        component.ViewModeChange.subscribe(mode => emitted.push(mode));

        component.setViewMode('kanban');
        expect(component.ViewMode).toBe('kanban');
        expect(emitted).toEqual(['kanban']);
        expect(mockCdr.markForCheck).toHaveBeenCalled();

        component.setViewMode('gantt');
        expect(component.ViewMode).toBe('gantt');
        expect(emitted).toEqual(['kanban', 'gantt']);
    });

    it('opens and closes slide-in detail panel on task click', () => {
        const component = new TaskPanelComponent(mockCdr);
        const taskID = 'task-uuid-1234';

        component.onTaskClicked(taskID);
        expect(component.panelMode).toBe('detail');
        expect(component.selectedTaskID).toBe(taskID);

        component.closePanel();
        expect(component.panelMode).toBe('none');
        expect(component.selectedTaskID).toBeNull();
    });

    it('delegates Refresh to all active views', () => {
        const component = new TaskPanelComponent(mockCdr);
        const mockList = { Refresh: vi.fn() } as unknown;
        const mockKanban = { Refresh: vi.fn() } as unknown;
        const mockGantt = { Refresh: vi.fn() } as unknown;

        component.taskList = mockList as TaskPanelComponent['taskList'];
        component.taskKanban = mockKanban as TaskPanelComponent['taskKanban'];
        component.taskGantt = mockGantt as TaskPanelComponent['taskGantt'];

        component.Refresh();
        expect((mockList as { Refresh: ReturnType<typeof vi.fn> }).Refresh).toHaveBeenCalled();
        expect((mockKanban as { Refresh: ReturnType<typeof vi.fn> }).Refresh).toHaveBeenCalled();
        expect((mockGantt as { Refresh: ReturnType<typeof vi.fn> }).Refresh).toHaveBeenCalled();
    });
});
