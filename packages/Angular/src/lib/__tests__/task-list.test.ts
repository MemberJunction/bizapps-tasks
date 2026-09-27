import '@angular/compiler';
import { describe, expect, it, vi } from 'vitest';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';
import { TaskListComponent, TaskRow, BeforeStatusChangeEvent } from '../components/task-list/task-list.component';

describe('TaskListComponent Selection and Bulk Status', () => {
    function createTaskList(cdr?: Partial<ChangeDetectorRef>): TaskListComponent {
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
        return runInInjectionContext(injector, () => new TaskListComponent());
    }

    it('matches selected IDs using UUIDsEqual', () => {
        const component = createTaskList();
        const idLower = 'b8380182-1d5b-46c2-9e56-43b63ca09f1a';
        const idUpper = 'B8380182-1D5B-46C2-9E56-43B63CA09F1A';

        component.toggleSelect(idLower);
        expect(component.selectedIDs).toEqual([idLower]);
        expect(component.isSelected(idUpper)).toBe(true);

        // Toggling with upper case removes the id
        component.toggleSelect(idUpper);
        expect(component.selectedIDs).toEqual([]);
        expect(component.isSelected(idLower)).toBe(false);
    });

    it('applyBulkStatus skips IDs not present in current tasks', async () => {
        const component = createTaskList();
        const existingTask: TaskRow = {
            ID: 'A1111111-1111-1111-1111-111111111111',
            Name: 'In-List Task',
            Description: null,
            Status: 'Open',
            Priority: 'Medium',
            DueAt: null,
            PercentComplete: 0,
            HoursEstimated: null,
            ParentID: null,
            Depth: 0,
            IsOverdue: false,
            IsDueSoon: false,
        };
        component.tasks = [existingTask];
        // Stale ID from another space/filter plus valid ID
        component.selectedIDs = [
            'B2222222-2222-2222-2222-222222222222', // NOT in current tasks
            'a1111111-1111-1111-1111-111111111111', // in current tasks (different case)
        ];
        component.bulkStatus = 'Completed';

        vi.spyOn(component, 'loadTasks').mockResolvedValue();

        const emittedBefore: BeforeStatusChangeEvent[] = [];
        component.BeforeStatusChange.subscribe(e => {
            emittedBefore.push(e);
            e.Cancel = true; // cancel so it doesn't try to call Metadata/DB
        });

        await component.applyBulkStatus();

        // Exactly one event should be emitted (for existingTask), skipping the stale ID
        expect(emittedBefore.length).toBe(1);
        expect(emittedBefore[0].Task.ID).toBe('A1111111-1111-1111-1111-111111111111');
        expect(emittedBefore[0].NewStatus).toBe('Completed');
    });
});
