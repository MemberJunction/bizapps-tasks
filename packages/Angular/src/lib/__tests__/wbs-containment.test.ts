import '@angular/compiler';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { UserInfoEngine } from '@memberjunction/core-entities';
import type { TaskWbsGroup, TaskWidgetItem } from '@mj-biz-apps/tasks-ng-widgets';

const { runViewMock } = vi.hoisted(() => ({ runViewMock: vi.fn() }));
vi.mock('@memberjunction/core', async (importOriginal) => ({
    ...(await importOriginal<typeof import('@memberjunction/core')>()),
    Metadata: {
        Provider: {
            EntityByName: vi.fn(() => undefined),
            Roles: [],
        },
    },
    RunView: class {
        static FromMetadataProvider = vi.fn(() => ({ RunView: runViewMock }));
        RunView = runViewMock;
    },
}));

import { TaskListComponent } from '../components/task-list/task-list.component';
import { TaskKanbanComponent } from '../components/task-kanban/task-kanban.component';
import { TaskGanttComponent } from '../components/task-gantt/task-gantt.component';
import { TaskPanelComponent } from '../components/task-panel/task-panel.component';
import { TaskDetailPanelComponent } from '../components/task-detail-panel/task-detail-panel.component';

function createCdr(): ChangeDetectorRef {
    return {
        markForCheck: vi.fn(),
        detach: vi.fn(),
        detectChanges: vi.fn(),
        checkNoChanges: vi.fn(),
        reattach: vi.fn(),
    };
}

function createInInjector<T>(factory: () => T): T {
    const injector = Injector.create({
        providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
    });
    return runInInjectionContext(injector, factory);
}

const sampleHierarchy: TaskWidgetItem[] = [
    {
        ID: '11111111-1111-4111-8111-111111111111',
        ParentID: null,
        Name: 'Phase 1: Foundation',
        Status: 'InProgress',
        Priority: 'High',
        StartedAt: '2026-11-01T00:00:00Z',
        DueAt: '2026-11-20T00:00:00Z',
        PercentComplete: null,
        Sequence: 10,
        OrganizationName: 'Acme Corp',
        AssigneeNames: ['Alex Rivera'],
    },
    {
        ID: '22222222-2222-4222-8222-222222222222',
        ParentID: '11111111-1111-4111-8111-111111111111',
        Name: 'Milestone 1.1: Security',
        Status: 'InProgress',
        Priority: 'High',
        StartedAt: '2026-11-02T00:00:00Z',
        DueAt: '2026-11-12T00:00:00Z',
        PercentComplete: null,
        Sequence: 10,
    },
    {
        ID: '33333333-3333-4333-8333-333333333333',
        ParentID: '22222222-2222-4222-8222-222222222222',
        Name: 'Task 1.1.1: OAuth Audit',
        Status: 'Blocked',
        Priority: 'Critical',
        StartedAt: '2026-11-03T00:00:00Z',
        DueAt: '2026-11-10T00:00:00Z',
        PercentComplete: 40,
        BlockedReason: 'Pending vendor metadata',
        Sequence: 10,
        AssigneeNames: ['Morgan Chen'],
    },
    {
        ID: '44444444-4444-4444-8444-444444444444',
        ParentID: null,
        Name: 'Phase 2: Launch',
        Status: 'Completed',
        Priority: 'Low',
        StartedAt: '2026-11-15T00:00:00Z',
        DueAt: '2026-11-30T00:00:00Z',
        PercentComplete: 100,
        Sequence: 20,
    },
];

describe('Layer 1 WBS & Containment Upgrades (tasks-ng)', () => {
    beforeEach(() => {
        runViewMock.mockReset();
    });

    it('TaskListComponent controlled [Tasks] fires zero RunViews, walks full ancestor chain on collapse, and preserves ancestors on filter', () => {
        const list = createInInjector(() => new TaskListComponent());
        list.Tasks = sampleHierarchy;
        list.ngOnInit();

        expect(runViewMock).not.toHaveBeenCalled();
        expect(list.tasks.map((t) => [t.Name, t.Depth])).toEqual([
            ['Phase 1: Foundation', 0],
            ['Milestone 1.1: Security', 1],
            ['Task 1.1.1: OAuth Audit', 2],
            ['Phase 2: Launch', 0],
        ]);

        // Expand Milestone 1.1 while Phase 1 is collapsed -> grandchild Task 1.1.1 MUST be hidden!
        list.expandedIDs.clear();
        list.expandedIDs.add('22222222-2222-4222-8222-222222222222');
        const grandchild = list.tasks.find((t) => t.ID === '33333333-3333-4333-8333-333333333333')!;
        expect(list.isParentExpanded(grandchild)).toBe(false);

        // Expand Phase 1 as well -> now grandchild is visible
        list.expandedIDs.add('11111111-1111-4111-8111-111111111111');
        expect(list.isParentExpanded(grandchild)).toBe(true);

        // Ancestor-preserving search: searching "OAuth" keeps Phase 1 -> Milestone 1.1 -> Task 1.1.1
        list.searchText = 'OAuth';
        list.applyFilters();
        expect(list.filteredTasks.map((t) => t.ID)).toEqual([
            '11111111-1111-4111-8111-111111111111',
            '22222222-2222-4222-8222-222222222222',
            '33333333-3333-4333-8333-333333333333',
        ]);
    });

    it('TaskListComponent skips bulk-dock lookup RunViews when ReadOnly === true and scopes Task Assignments', async () => {
        runViewMock.mockImplementation((params: { EntityName: string }) => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                return Promise.resolve({
                    Success: true,
                    Results: [
                        {
                            ID: '11111111-1111-4111-8111-111111111111',
                            Name: 'Read-only Task',
                            Description: null,
                            Status: 'Open',
                            Priority: 'Medium',
                            DueAt: null,
                            PercentComplete: 0,
                            HoursEstimated: null,
                            ParentID: null,
                            TaskTypeStatus: null,
                        },
                    ],
                });
            }
            return Promise.resolve({ Success: true, Results: [] });
        });

        const list = createInInjector(() => new TaskListComponent());
        list.ReadOnly = true;
        await list.loadTasks();

        const queriedEntities = runViewMock.mock.calls.map(
            (c) => (c[0] as { EntityName: string }).EntityName,
        );
        expect(queriedEntities).toContain('MJ_BizApps_Tasks: Tasks');
        expect(queriedEntities).not.toContain('MJ_BizApps_Common: Organizations');
        expect(queriedEntities).not.toContain('MJ_BizApps_Tasks: Task Categories');
        expect(queriedEntities).not.toContain('MJ_BizApps_Tasks: Task Types');
        expect(queriedEntities).not.toContain('MJ_BizApps_Tasks: Task Type Status');

        const assignmentCall = runViewMock.mock.calls.find(
            (c) => (c[0] as { EntityName: string }).EntityName === 'MJ_BizApps_Tasks: Task Assignments',
        );
        expect((assignmentCall?.[0] as { ExtraFilter?: string })?.ExtraFilter).toContain(
            '11111111-1111-4111-8111-111111111111',
        );
    });

    it('TaskKanbanComponent controlled [Tasks] renders across columns with zero RunViews and resolves CardBadgeResolver', () => {
        const getSettingSpy = vi.spyOn(UserInfoEngine.Instance, 'GetSetting').mockReturnValue(undefined);
        try {
            const kanban = createInInjector(() => new TaskKanbanComponent());
            kanban.Tasks = sampleHierarchy;
            kanban.CardBadgeResolver = (id) =>
                id === '33333333-3333-4333-8333-333333333333'
                    ? [{ Label: 'Team Only', Tone: 'info' }]
                    : [];
            kanban.ngOnInit();

            expect(runViewMock).not.toHaveBeenCalled();
            expect(kanban.cards).toHaveLength(4);
            expect(kanban.CardsForColumn('Blocked').map((c) => c.ID)).toEqual([
                '33333333-3333-4333-8333-333333333333',
            ]);
            expect(kanban.resolveCardBadges('33333333-3333-4333-8333-333333333333')).toEqual([
                { Label: 'Team Only', Tone: 'info' },
            ]);
        } finally {
            getSettingSpy.mockRestore();
        }
    });

    it('TaskGanttComponent controlled [Tasks] + [Dependencies] builds DHTMLX items, links, critical path, and mobile milestones with zero RunViews', () => {
        const getSettingSpy = vi.spyOn(UserInfoEngine.Instance, 'GetSetting').mockReturnValue(undefined);
        try {
            const gantt = createInInjector(() => new TaskGanttComponent());
            gantt.Tasks = sampleHierarchy;
            gantt.Dependencies = [
                {
                    TaskID: '44444444-4444-4444-8444-444444444444',
                    DependsOnTaskID: '33333333-3333-4333-8333-333333333333',
                    DependencyType: 'FinishToStart',
                },
            ];
            gantt.ngOnInit();

            expect(runViewMock).not.toHaveBeenCalled();
            expect(gantt.items).toHaveLength(4);
            expect(gantt.links).toHaveLength(1);
            expect(gantt.links[0]).toMatchObject({
                SourceID: '33333333-3333-4333-8333-333333333333',
                TargetID: '44444444-4444-4444-8444-444444444444',
                Type: 'FS',
            });
            expect(gantt.CriticalPathIds.size).toBe(2);
            expect(gantt.milestoneTasks).toHaveLength(4);
        } finally {
            getSettingSpy.mockRestore();
        }
    });

    it('TaskPanelComponent persists 4-mode ViewMode in UserInfoEngine, flattens [Groups] + [HubTasks], and exposes OpenDetail/CloseDetail', () => {
        const getSettingSpy = vi.spyOn(UserInfoEngine.Instance, 'GetSetting').mockReturnValue('kanban');
        const setSettingSpy = vi.spyOn(UserInfoEngine.Instance, 'SetSettingDebounced').mockImplementation(() => {});
        try {
            const panel = createInInjector(() => new TaskPanelComponent());
            panel.AllowedViewModes = ['wbs', 'list', 'kanban', 'gantt'];
            panel.PreferenceKey = 'Test.WorkPanel.ViewMode';
            panel.ngOnInit();

            // Restored persisted 'kanban' preference from UserInfoEngine
            expect(panel.ViewMode).toBe('kanban');
            expect(getSettingSpy).toHaveBeenCalledWith('Test.WorkPanel.ViewMode');

            // Switching to 'wbs' persists via SetSettingDebounced
            panel.SetViewMode('wbs');
            expect(panel.ViewMode).toBe('wbs');
            expect(setSettingSpy).toHaveBeenCalledWith('Test.WorkPanel.ViewMode', 'wbs');

            // Groups + HubTasks flatten cleanly (deduped) for List/Kanban/Gantt
            const groups: TaskWbsGroup[] = [
                { ID: 'g1', Title: 'Initiative 1', Tasks: sampleHierarchy.slice(0, 3) },
                { ID: 'g2', Title: 'Initiative 2', Tasks: [sampleHierarchy[2], sampleHierarchy[3]] },
            ];
            panel.Groups = groups;
            panel.HubTasks = [sampleHierarchy[0]];
            expect(panel.EffectiveFlatTasks?.map((t) => t.ID)).toEqual([
                '11111111-1111-4111-8111-111111111111',
                '22222222-2222-4222-8222-222222222222',
                '33333333-3333-4333-8333-333333333333',
                '44444444-4444-4444-8444-444444444444',
            ]);

            // OpenDetail & CloseDetail drawer API
            panel.OpenDetail('33333333-3333-4333-8333-333333333333');
            expect(panel.panelMode).toBe('detail');
            expect(panel.selectedTaskID).toBe('33333333-3333-4333-8333-333333333333');

            panel.CloseDetail();
            expect(panel.panelMode).toBe('none');
            expect(panel.selectedTaskID).toBeNull();
        } finally {
            getSettingSpy.mockRestore();
            setSettingSpy.mockRestore();
        }
    });

    it('TaskDetailPanelComponent defaults ShowOpenForm and ShowTimeEffort to true and respects overrides', () => {
        const detail = createInInjector(() => new TaskDetailPanelComponent());
        expect(detail.ShowOpenForm).toBe(true);
        expect(detail.ShowTimeEffort).toBe(true);

        detail.ShowOpenForm = false;
        detail.ShowTimeEffort = false;
        expect(detail.ShowOpenForm).toBe(false);
        expect(detail.ShowTimeEffort).toBe(false);
    });
});
