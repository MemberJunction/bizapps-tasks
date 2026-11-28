import '@angular/compiler';
import { describe, expect, it, vi } from 'vitest';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';
import { UserInfoEngine } from '@memberjunction/core-entities';
import { TaskKanbanComponent } from '../components/task-kanban/task-kanban.component';
import { TaskListComponent } from '../components/task-list/task-list.component';
import { TaskGanttComponent } from '../components/task-gantt/task-gantt.component';
import { TaskHeaderPanel } from '../form-panels/task-header.panel';
import { TaskEditPanelComponent } from '../components/task-edit-panel/task-edit-panel.component';
import { TaskTemplateWizardComponent } from '../components/task-template-wizard/task-template-wizard.component';
import { TasksDashboardPageComponent } from '../pages/tasks-dashboard.page';
import { ApprovalsPageComponent } from '../pages/approvals.page';
import {
    SAVED_TASK_VIEWS_SETTING,
    TasksBulkUpdateOperation,
    TasksInstantiateTemplateOperation,
} from '@mj-biz-apps/tasks-core';

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

    it('TaskKanbanComponent groups cards by Organization / Company with crisp badge colors and non-redundant footers', () => {
        const setSpy = vi.spyOn(UserInfoEngine.Instance, 'SetSettingDebounced').mockImplementation(() => {});
        const injector = Injector.create({
            providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
        });
        const comp = runInInjectionContext(injector, () => new TaskKanbanComponent());
        comp.rawTasks = [
            {
                ID: 't1',
                Name: 'US Close',
                Description: null,
                Status: 'InProgress',
                Priority: 'Critical',
                DueAt: null,
                PercentComplete: 50,
                HoursEstimated: 4,
                ParentID: null,
                OrganizationID: 'org-us',
                Organization: 'Blue Cypress US LLC',
            },
            {
                ID: 't2',
                Name: 'Global Policy',
                Description: null,
                Status: 'Open',
                Priority: 'Medium',
                DueAt: null,
                PercentComplete: 0,
                HoursEstimated: 2,
                ParentID: null,
                OrganizationID: null,
                Organization: null,
            },
        ];

        comp.onGroupByChange('organization');
        expect(comp.columns.map((c) => c.Key)).toEqual(['Blue Cypress US LLC', 'No Organization']);
        const usCard = comp.cards.find((c) => c.ID === 't1');
        expect(usCard?.ColumnKey).toBe('Blue Cypress US LLC');
        // Solid status color (not pale -bg tint) for high-contrast white badge text
        expect(usCard?.BadgeColor).toBe('var(--mj-status-error)');
        // Does not repeat Organization name in card footer when already grouped by Organization
        expect(usCard?.FooterText ?? '').not.toContain('Blue Cypress US LLC');
        expect(comp.cards.find((c) => c.ID === 't2')?.ColumnKey).toBe('No Organization');

        // When grouped by status, Organization IS shown in footer
        comp.onGroupByChange('status');
        expect(comp.cards.find((c) => c.ID === 't1')?.FooterText).toContain('Blue Cypress US LLC');
        setSpy.mockRestore();
    });

    it('TaskListComponent dispatches Asana-grade bulk patches via server-side TasksBulkUpdateOperation', async () => {
        const injector = Injector.create({
            providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
        });
        const list = runInInjectionContext(injector, () => new TaskListComponent());
        list.selectedIDs = ['11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222'];
        vi.spyOn(list, 'loadTasks').mockResolvedValue();

        const execSpy = vi.spyOn(TasksBulkUpdateOperation.prototype, 'Execute').mockResolvedValue({
            Success: true,
            Output: {
                TotalRequested: 2,
                UpdatedCount: 2,
                FailedCount: 0,
                UpdatedTaskIDs: [...list.selectedIDs],
                Failures: [],
            },
        });

        await list.onBulkDockAction({
            Kind: 'apply',
            Patch: {
                DueDateMode: 'shift',
                ShiftDays: 2,
                OrganizationMode: 'set',
                OrganizationID: '33333333-3333-3333-3333-333333333333',
            },
        });

        expect(execSpy).toHaveBeenCalledTimes(1);
        expect(execSpy).toHaveBeenCalledWith({
            TaskIDs: ['11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222'],
            DueDateMode: 'shift',
            ShiftDays: 2,
            OrganizationMode: 'set',
            OrganizationID: '33333333-3333-3333-3333-333333333333',
        });
        expect(list.selectedIDs).toEqual([]);
        expect(list.bulkSuccess).toBe('Updated 2 tasks.');
        execSpy.mockRestore();
    });

    it('TaskListComponent supports Shift+click range selection and Select All visible', () => {
        const injector = Injector.create({
            providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
        });
        const list = runInInjectionContext(injector, () => new TaskListComponent());
        list.tasks = [
            { ID: 't1', Name: 'Task 1', Description: null, Status: 'Open', Priority: 'High', DueAt: null, PercentComplete: 0, HoursEstimated: null, ParentID: null, Depth: 0, IsOverdue: false, IsDueSoon: false },
            { ID: 't2', Name: 'Task 2', Description: null, Status: 'Open', Priority: 'High', DueAt: null, PercentComplete: 0, HoursEstimated: null, ParentID: null, Depth: 0, IsOverdue: false, IsDueSoon: false },
            { ID: 't3', Name: 'Task 3', Description: null, Status: 'Open', Priority: 'High', DueAt: null, PercentComplete: 0, HoursEstimated: null, ParentID: null, Depth: 0, IsOverdue: false, IsDueSoon: false },
        ];
        list.applyFilters();

        const stop = vi.fn();
        list.onCheckboxClick({ shiftKey: false, stopPropagation: stop } as unknown as MouseEvent, 't1');
        expect(list.selectedIDs).toEqual(['t1']);

        // Shift+click t3 selects t1, t2, t3
        list.onCheckboxClick({ shiftKey: true, stopPropagation: stop } as unknown as MouseEvent, 't3');
        expect(list.selectedIDs).toEqual(['t1', 't2', 't3']);
        expect(list.allVisibleSelected).toBe(true);

        // Toggle Select All clears when all selected
        list.toggleSelectAllVisible();
        expect(list.selectedIDs).toEqual([]);
    });

    it('TaskListComponent filters uniformly by Organization, Assignee, and Due Date', () => {
        const injector = Injector.create({
            providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
        });
        const list = runInInjectionContext(injector, () => new TaskListComponent());
        list.tasks = [
            {
                ID: 't-us',
                Name: 'US Close',
                Description: null,
                Status: 'InProgress',
                Priority: 'High',
                DueAt: null,
                PercentComplete: 25,
                HoursEstimated: null,
                ParentID: null,
                Depth: 0,
                IsOverdue: false,
                IsDueSoon: false,
                OrganizationID: 'org-us',
                OrganizationName: 'Blue Cypress US LLC',
                Assignees: [{ Name: 'Elena Vance', Role: 'Primary', Status: 'InProgress', EntityName: 'MJ_BizApps_Common: People', RecordID: 'p-elena' }],
            },
            {
                ID: 't-uk',
                Name: 'UK VAT Filing',
                Description: null,
                Status: 'Open',
                Priority: 'Medium',
                DueAt: new Date(Date.now() - 3 * 86_400_000),
                PercentComplete: 0,
                HoursEstimated: null,
                ParentID: null,
                Depth: 0,
                IsOverdue: true,
                IsDueSoon: false,
                OrganizationID: 'org-uk',
                OrganizationName: 'Blue Cypress UK Ltd',
                Assignees: [],
            },
        ];

        list.OrganizationIDFilter = 'org-us';
        list.applyFilters();
        expect(list.filteredTasks.map((t) => t.ID)).toEqual(['t-us']);

        list.OrganizationIDFilter = null;
        list.AssigneeFilter = '__unassigned__';
        list.applyFilters();
        expect(list.filteredTasks.map((t) => t.ID)).toEqual(['t-uk']);

        list.AssigneeFilter = null;
        list.DueDateFilter = 'overdue';
        list.applyFilters();
        expect(list.filteredTasks.map((t) => t.ID)).toEqual(['t-uk']);
    });

    it('TaskGanttComponent exposes Assignee & Organization columns with HTML-escaped cell templates and expanded default GridWidth', () => {
        const injector = Injector.create({
            providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
        });
        const gantt = runInInjectionContext(injector, () => new TaskGanttComponent());

        const colNames = gantt.EffectiveColumns.map((c) => c.Name);
        expect(colNames).toContain('assignee');
        expect(colNames).toContain('organization');
        expect(gantt.EffectiveGridWidth).toBeGreaterThanOrEqual(480);

        // Verify HTML-escaping against XSS in Assignee & Organization cell renderers
        const ganttInternal = gantt as unknown as {
            assigneesByTask: Map<string, Array<{ RecordID: string; EntityName: string; DisplayName: string; IsRole: boolean }>>;
            orgNameByTask: Map<string, string>;
        };
        ganttInternal.assigneesByTask.set('t-xss', [
            { RecordID: 'p1', EntityName: 'MJ_BizApps_Common: People', DisplayName: '<script>alert(1)</script>', IsRole: false },
        ]);
        ganttInternal.orgNameByTask.set('t-xss', 'Acme & <Corp>');

        const assigneeCol = gantt.EffectiveColumns.find((c) => c.Name === 'assignee');
        const orgCol = gantt.EffectiveColumns.find((c) => c.Name === 'organization');
        const renderedAssignee = assigneeCol?.Template?.({ id: 't-xss' }) ?? '';
        const renderedOrg = orgCol?.Template?.({ id: 't-xss' }) ?? '';

        expect(renderedAssignee).not.toContain('<script>');
        expect(renderedAssignee).toContain('&lt;script&gt;');
        expect(renderedOrg).not.toContain('<Corp>');
        expect(renderedOrg).toContain('Acme &amp; &lt;Corp&gt;');
    });

    it('TaskTemplateWizardComponent dispatches server-side TasksInstantiateTemplateOperation with OrganizationID', async () => {
        const injector = Injector.create({
            providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
        });
        const wizard = runInInjectionContext(injector, () => new TaskTemplateWizardComponent());
        wizard.selectedTemplateID = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
        wizard.startDateStr = '2026-12-01';
        wizard.categoryID = '44444444-4444-4444-8444-444444444444';
        wizard.organizationID = '33333333-3333-4333-8333-333333333333';

        const createdSpy = vi.fn();
        wizard.Created.subscribe(createdSpy);

        const execSpy = vi.spyOn(TasksInstantiateTemplateOperation.prototype, 'Execute').mockResolvedValue({
            Success: true,
            Output: {
                TemplateID: wizard.selectedTemplateID,
                CreatedCount: 3,
                CreatedTaskIDs: ['t1', 't2', 't3'],
                OrganizationID: wizard.organizationID,
            },
        });

        try {
            await wizard.onCreate();
            expect(execSpy).toHaveBeenCalledWith({
                TemplateID: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
                StartDate: '2026-12-01',
                CategoryID: '44444444-4444-4444-8444-444444444444',
                OrganizationID: '33333333-3333-4333-8333-333333333333',
                RoleAssignments: undefined,
            });
            expect(createdSpy).toHaveBeenCalledTimes(1);
            expect(createdSpy.mock.calls[0][0].CreatedCount).toBe(3);
        } finally {
            execSpy.mockRestore();
        }
    });

    it('TasksDashboardPageComponent persists Saved Filter Views via UserInfoEngine and runs lifted Bulk Dock mutations', async () => {
        const setSettingSpy = vi.spyOn(UserInfoEngine.Instance, 'SetSettingDebounced').mockImplementation(() => {});
        const execSpy = vi.spyOn(TasksBulkUpdateOperation.prototype, 'Execute').mockResolvedValue({
            Success: true,
            Output: {
                TotalRequested: 2,
                UpdatedCount: 2,
                FailedCount: 0,
                UpdatedTaskIDs: ['t1', 't2'],
                Failures: [],
            },
        });

        try {
            const injector = Injector.create({
                providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
            });
            const page = runInInjectionContext(injector, () => new TasksDashboardPageComponent());
            vi.spyOn(page, 'LoadKPIs').mockResolvedValue();

            page.SelectedCategoryID = 'cat-finance';
            page.SearchText = 'reconcile';
            page.FilterValues = { organizationId: 'org-acme', status: 'Open', priority: 'High' };
            page.ViewMode = 'kanban';
            page.NewViewName = 'Acme Month-End Close';
            page.SaveCurrentView();

            expect(page.SavedViews).toHaveLength(1);
            expect(page.SavedViews[0].Name).toBe('Acme Month-End Close');
            expect(setSettingSpy).toHaveBeenCalledWith(SAVED_TASK_VIEWS_SETTING, expect.stringContaining('Acme Month-End Close'));

            // Clear filters and re-apply saved view
            page.ResetFilters();
            expect(page.SearchText).toBe('');
            page.ApplySavedView(page.SavedViews[0]);
            expect(page.SelectedCategoryID).toBe('cat-finance');
            expect(page.SearchText).toBe('reconcile');
            expect(page.FilterValues['organizationId']).toBe('org-acme');
            expect(page.ViewMode).toBe('kanban');

            // Lifted Bulk Dock runs server-side operation across Board/Gantt/List selections
            page.OnSelectedTaskIDsChange(['t1', 't2']);
            await page.OnBulkDockAction({ Kind: 'status', Status: 'InProgress' });
            expect(execSpy).toHaveBeenCalledWith({ TaskIDs: ['t1', 't2'], Status: 'InProgress' });
            expect(page.SelectedTaskIDs).toEqual([]);
            expect(page.BulkSuccess).toContain('Updated 2 tasks');

            page.DeleteSavedView(page.SavedViews[0].ID);
            expect(page.SavedViews).toHaveLength(0);
        } finally {
            setSettingSpy.mockRestore();
            execSpy.mockRestore();
        }
    });

    it('TaskKanbanComponent and TaskGanttComponent support multi-select for the shared Bulk Action Dock', () => {
        const injector = Injector.create({
            providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
        });

        const kanban = runInInjectionContext(injector, () => new TaskKanbanComponent());
        kanban.EnableBulkSelect = true;
        kanban.cards = [
            { ID: 'k1', Title: 'Task 1', ColumnKey: 'Open' },
            { ID: 'k2', Title: 'Task 2', ColumnKey: 'Open' },
            { ID: 'k3', Title: 'Task 3', ColumnKey: 'InProgress' },
        ];
        const emittedKanban: string[][] = [];
        kanban.SelectedIDsChange.subscribe((ids) => emittedKanban.push(ids));
        kanban.ToggleSelectAllVisible();
        expect(kanban.SelectedIDs).toEqual(['k1', 'k2', 'k3']);
        expect(emittedKanban.at(-1)).toEqual(['k1', 'k2', 'k3']);

        const gantt = runInInjectionContext(injector, () => new TaskGanttComponent());
        gantt.EnableBulkSelect = true;
        expect(gantt.EffectiveColumns[0].Name).toBe('mjt_select');
        expect(gantt.EffectiveGridWidth).toBeGreaterThanOrEqual(596);
        gantt.items = [
            { ID: 'g1', Name: 'Close Step 1', StartDate: new Date(), Duration: 2 },
            { ID: 'g2', Name: 'Close Step 2', StartDate: new Date(), Duration: 2 },
        ];
        gantt.ToggleSelectAllVisible();
        expect(gantt.SelectedIDs).toEqual(['g1', 'g2']);
    });

    it('ApprovalsPageComponent navigates queue with arrows and prefills Outcome with A/R without auto-committing (WCAG 2.1.4)', () => {
        const injector = Injector.create({
            providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
        });
        const page = runInInjectionContext(injector, () => new ApprovalsPageComponent());
        const prefillSpy = vi.fn();
        const quickDecisionSpy = vi.spyOn(page, 'OnQuickDecision');
        page.decisionPanel = { PrefillOutcome: prefillSpy } as unknown as ApprovalsPageComponent['decisionPanel'];
        page.PendingApprovals = [
            { ID: 'a1', Name: 'Approve Budget', Description: null, DueAt: null, ParentID: null, Status: 'Open', Priority: 'High', PercentComplete: 0 },
            { ID: 'a2', Name: 'Approve Vendor', Description: null, DueAt: null, ParentID: null, Status: 'Open', Priority: 'Medium', PercentComplete: 0 },
        ];
        page.SelectedTaskID = 'a1';

        page.onShortcut({ key: 'ArrowDown', preventDefault: vi.fn(), target: { tagName: 'DIV' } } as unknown as KeyboardEvent);
        expect(page.SelectedTaskID).toBe('a2');

        page.onShortcut({ key: 'a', preventDefault: vi.fn(), target: { tagName: 'DIV' } } as unknown as KeyboardEvent);
        expect(prefillSpy).toHaveBeenCalledWith('Approved');
        expect(quickDecisionSpy).not.toHaveBeenCalled();

        page.onShortcut({ key: 'r', preventDefault: vi.fn(), target: { tagName: 'DIV' } } as unknown as KeyboardEvent);
        expect(prefillSpy).toHaveBeenCalledWith('Rejected');
        expect(quickDecisionSpy).not.toHaveBeenCalled();
    });
});
