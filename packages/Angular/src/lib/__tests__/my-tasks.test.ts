import '@angular/compiler';
import { describe, expect, it, vi } from 'vitest';

const { entityByName } = vi.hoisted(() => ({
    entityByName: vi.fn(() => ({ SchemaName: '__mj_bizappstasks', BaseView: 'vwTaskAssignments' })),
}));
vi.mock('@memberjunction/core', async (importOriginal) => ({
    ...(await importOriginal<typeof import('@memberjunction/core')>()),
    Metadata: class {
        static Provider = { EntityByName: entityByName };
    },
}));

import { MyTasksComponent } from '../components/my-tasks/my-tasks.component';

describe('MyTasksComponent assigneeFilter', () => {
    it('is empty without a PersonID', () => {
        expect(new MyTasksComponent().assigneeFilter).toBe('');
    });

    it('filters through the assignments view named by metadata', () => {
        const myTasks = new MyTasksComponent();
        myTasks.PersonID = 'person-1';

        expect(myTasks.assigneeFilter).toBe(
            "[ID] IN (SELECT [TaskID] FROM [__mj_bizappstasks].[vwTaskAssignments] WHERE [AssigneeRecordID] = 'person-1')",
        );
        expect(entityByName).toHaveBeenCalledWith('MJ_BizApps_Tasks: Task Assignments');
    });

    it('escapes quotes in the PersonID', () => {
        const myTasks = new MyTasksComponent();
        myTasks.PersonID = "o'brien";

        expect(myTasks.assigneeFilter).toContain("[AssigneeRecordID] = 'o''brien'");
    });
});
