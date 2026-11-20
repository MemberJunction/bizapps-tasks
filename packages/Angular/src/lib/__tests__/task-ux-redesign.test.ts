import '@angular/compiler';
import { describe, expect, it, vi } from 'vitest';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';
import { UserInfoEngine } from '@memberjunction/core-entities';
import { TaskKanbanComponent } from '../components/task-kanban/task-kanban.component';
import { TaskHeaderPanel } from '../form-panels/task-header.panel';
import { TaskEditPanelComponent } from '../components/task-edit-panel/task-edit-panel.component';

function createCdr(): ChangeDetectorRef {
    return {
        markForCheck: vi.fn(),
        detach: vi.fn(),
        detectChanges: vi.fn(),
        checkNoChanges: vi.fn(),
        reattach: vi.fn(),
    };
}

describe('Task UX Redesign L3 Components', () => {
    it('TaskKanbanComponent switches between Macro Status, Priority, and Workflow grouping', () => {
        const setSpy = vi.spyOn(UserInfoEngine.Instance, 'SetSettingDebounced').mockImplementation(() => {});
        const injector = Injector.create({
            providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
        });
        const comp = runInInjectionContext(injector, () => new TaskKanbanComponent());

        comp.workflowStatuses = [
            { ID: 'st-spec', TaskTypeID: 'tt-del', Name: 'Spec', Code: 'Spec', Sequence: 1, MacroStatus: 'Open', IsDefault: true, IsTerminal: false, Color: '#2563eb', IconClass: null },
            { ID: 'st-build', TaskTypeID: 'tt-del', Name: 'Build', Code: 'Build', Sequence: 2, MacroStatus: 'InProgress', IsDefault: false, IsTerminal: false, Color: '#f59e0b', IconClass: null },
            { ID: 'st-ship', TaskTypeID: 'tt-del', Name: 'Shipped', Code: 'Shipped', Sequence: 3, MacroStatus: 'Completed', IsDefault: false, IsTerminal: true, Color: '#10b981', IconClass: null },
        ];

        comp.onGroupByChange('priority');
        expect(comp.GroupBy).toBe('priority');
        expect(comp.columns.map((c) => c.Key)).toEqual(['Critical', 'High', 'Medium', 'Low']);
        expect(setSpy).toHaveBeenCalledWith('mj.tasks.kanbanGroupBy.v1', 'priority');

        comp.onGroupByChange('workflow');
        expect(comp.columns.map((c) => c.Key)).toEqual(['st-spec', 'st-build', 'st-ship', '__unassigned_stage__']);

        comp.onGroupByChange('status');
        expect(comp.columns.map((c) => c.Key)).toEqual(['Open', 'InProgress', 'Blocked', 'Completed']);
        setSpy.mockRestore();
    });

    it('TaskHeaderPanel reads strongly typed HoursEstimated and HoursActual (no .Get)', () => {
        const injector = Injector.create({
            providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
        });
        const panel = runInInjectionContext(injector, () => new TaskHeaderPanel());
        const recordStub: Partial<TaskHeaderPanel['Record']> = {
            ID: '11111111-1111-1111-1111-111111111111',
            Name: 'Q4 Launch',
            Status: 'InProgress',
            Priority: 'High',
            HoursEstimated: 40,
            HoursActual: 24.5,
            PercentComplete: 60,
            IsSaved: true,
        };
        Object.defineProperty(panel, 'Record', { value: recordStub, writable: true });

        expect(panel.EstimatedHours).toBe(40);
        expect(panel.ActualHours).toBe(24.5);
        expect(panel.Progress).toBe('60%');
    });

    it('TaskEditPanelComponent exposes adaptive archetype properties based on selected TaskType', () => {
        const injector = Injector.create({
            providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
        });
        const edit = runInInjectionContext(injector, () => new TaskEditPanelComponent());
        edit.taskTypes = [
            { ID: 't-gen', Name: 'General', Code: 'General', IconClass: null, DefaultPriority: 'Medium', IsApproval: false, OnCompleteAction: null, OnRejectAction: null, OnCancelAction: null },
            { ID: 't-app', Name: 'Approval Request', Code: 'Approval', IconClass: null, DefaultPriority: 'High', IsApproval: true, OnCompleteAction: null, OnRejectAction: null, OnCancelAction: null },
            { ID: 't-kr', Name: 'Key Result', Code: 'KeyResult', IconClass: null, DefaultPriority: 'High', IsApproval: false, OnCompleteAction: null, OnRejectAction: null, OnCancelAction: null },
            { ID: 't-del', Name: 'Deliverable', Code: 'Deliverable', IconClass: null, DefaultPriority: 'Medium', IsApproval: false, OnCompleteAction: null, OnRejectAction: null, OnCancelAction: null },
        ];

        edit.form.TypeID = 't-gen';
        expect(edit.ActiveArchetype).toBe('general');

        edit.form.TypeID = 't-app';
        expect(edit.ActiveArchetype).toBe('approval');

        edit.form.TypeID = 't-kr';
        expect(edit.ActiveArchetype).toBe('key-result');

        edit.form.TypeID = 't-del';
        expect(edit.ActiveArchetype).toBe('deliverable');
    });
});
