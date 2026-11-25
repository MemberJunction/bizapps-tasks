import '@angular/compiler';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';
import { describe, expect, it, vi } from 'vitest';
import {
    TaskWbsSummaryStripComponent,
    TaskWbsTreeComponent,
    type TaskWbsGroup,
    type TaskWidgetItem,
} from '../tasks/index';

function createWbsTree(): TaskWbsTreeComponent {
    const cdr: ChangeDetectorRef = {
        markForCheck: vi.fn(),
        detach: vi.fn(),
        detectChanges: vi.fn(),
        checkNoChanges: vi.fn(),
        reattach: vi.fn(),
    };
    const injector = Injector.create({
        providers: [{ provide: ChangeDetectorRef, useValue: cdr }],
    });
    return runInInjectionContext(injector, () => new TaskWbsTreeComponent());
}

describe('WBS widgets (TaskWbsSummaryStripComponent & TaskWbsTreeComponent)', () => {
    const sampleTasks: TaskWidgetItem[] = [
        {
            ID: 'phase-1',
            ParentID: null,
            Name: 'Discovery Phase',
            Status: 'InProgress',
            Priority: 'High',
            PercentComplete: null,
            KindLabel: 'Phase',
            Sequence: 10,
            AssigneeNames: ['Jane Doe'],
        },
        {
            ID: 'ms-1',
            ParentID: 'phase-1',
            Name: 'Architecture Signoff',
            Status: 'InProgress',
            Priority: 'High',
            PercentComplete: null,
            KindLabel: 'Milestone',
            Sequence: 10,
        },
        {
            ID: 'task-1',
            ParentID: 'ms-1',
            Name: 'Draft Security Plan',
            Status: 'Blocked',
            Priority: 'Critical',
            PercentComplete: 25,
            BlockedReason: 'Waiting on IAM credentials',
            KindLabel: 'Task',
            Sequence: 10,
            AssigneeNames: ['Alex Rivera', 'Morgan Chen'],
        },
        {
            ID: 'sub-1',
            ParentID: 'task-1',
            Name: 'Review OAuth Scopes',
            Status: 'Completed',
            Priority: 'Medium',
            PercentComplete: 100,
            KindLabel: 'Subtask',
            Sequence: 10,
        },
        {
            ID: 'phase-2',
            ParentID: null,
            Name: 'Launch Phase',
            Status: 'Open',
            Priority: 'Medium',
            PercentComplete: 0,
            KindLabel: 'Phase',
            Sequence: 20,
        },
    ];

    it('TaskWbsSummaryStripComponent builds KPI tiles from Summary plus LeadingTiles and ExtraTiles and emits TileClicked', () => {
        const strip = new TaskWbsSummaryStripComponent();
        strip.LeadingTiles = [{ Key: 'initiatives', Label: 'Initiatives', Value: 3, Tone: 'info' }];
        strip.Summary = {
            TotalCount: 10,
            CompletedCount: 4,
            InProgressCount: 3,
            BlockedCount: 1,
            OpenCount: 2,
            OverdueCount: 2,
            OverallCompletionPercent: 52,
        };
        strip.ExtraTiles = [{ Key: 'prs', Label: 'Synced PRs', Value: 7, Tone: 'default' }];

        const keys = strip.AllTiles.map((t) => t.Key);
        expect(keys).toEqual(['initiatives', 'all', 'completed', 'in-progress', 'blocked', 'prs']);
        const blockedTile = strip.AllTiles.find((t) => t.Key === 'blocked');
        expect(blockedTile?.Alert).toBe(true);
        const completionTile = strip.AllTiles.find((t) => t.Key === 'completed');
        expect(completionTile?.ProgressPercent).toBe(52);

        const clicked: string[] = [];
        strip.TileClicked.subscribe((k) => clicked.push(k));
        strip.onTileClick('blocked');
        expect(clicked).toEqual(['blocked']);
    });

    it('TaskWbsTreeComponent renders 4-level WBS codes, hides all descendants on ancestor collapse, and supports ExpandAll/CollapseAll', () => {
        const tree = createWbsTree();
        tree.Tasks = sampleTasks;

        expect(tree.VisibleRows.map((r) => [r.Item.ID, r.WbsCode, r.Depth])).toEqual([
            ['phase-1', '1', 0],
            ['ms-1', '1.1', 1],
            ['task-1', '1.1.1', 2],
            ['sub-1', '1.1.1.1', 3],
            ['phase-2', '2', 0],
        ]);

        // Collapsing phase-1 hides ms-1, task-1, AND sub-1 (no orphaned grandchildren)
        tree.ToggleNode('phase-1');
        expect(tree.VisibleRows.map((r) => r.Item.ID)).toEqual(['phase-1', 'phase-2']);

        // ExpandAll restores full tree
        tree.ExpandAll();
        expect(tree.VisibleRows).toHaveLength(5);

        // CollapseAll collapses all parents
        tree.CollapseAll();
        expect(tree.VisibleRows.map((r) => r.Item.ID)).toEqual(['phase-1', 'phase-2']);
    });

    it('TaskWbsTreeComponent preserves ancestor chain during search, built-in filters, and CustomFilters', () => {
        const tree = createWbsTree();
        tree.Tasks = sampleTasks;
        tree.CustomFilters = [
            { Key: 'milestones', Label: 'Milestones Only', Predicate: (t) => t.KindLabel === 'Milestone' },
        ];

        // Collapse phase-1 first — search should auto-expand matching branch
        tree.CollapseAll();
        tree.SearchText = 'OAuth';
        expect(tree.VisibleRows.map((r) => r.Item.ID)).toEqual(['phase-1', 'ms-1', 'task-1', 'sub-1']);

        // Built-in Blocked filter preserves ancestors phase-1 -> ms-1 -> task-1
        tree.SearchText = '';
        tree.SetFilter('blocked');
        expect(tree.VisibleRows.map((r) => r.Item.ID)).toEqual(['phase-1', 'ms-1', 'task-1']);

        // CustomFilter preserves phase-1 -> ms-1
        tree.SetFilter('milestones');
        expect(tree.VisibleRows.map((r) => r.Item.ID)).toEqual(['phase-1', 'ms-1']);
    });

    it('TaskWbsTreeComponent supports multi-group portfolio accordion mode with section filtering and nested groups', () => {
        const tree = createWbsTree();
        const groups: TaskWbsGroup<{ stage: string }>[] = [
            {
                ID: 'init-1',
                Title: 'Core Migration',
                TagLabel: 'Active',
                Tasks: sampleTasks.slice(0, 4),
                Data: { stage: 'Execution' },
            },
            {
                ID: 'init-2',
                Title: 'Sub-Project: Analytics',
                IsNested: true,
                Tasks: [sampleTasks[4]],
                Data: { stage: 'Planning' },
            },
        ];
        tree.Groups = groups;

        expect(tree.IsGroupMode).toBe(true);
        expect(tree.RenderedGroups).toHaveLength(2);
        expect(tree.RenderedGroups[0].Summary.TotalCount).toBe(4);
        expect(tree.RenderedGroups[1].Group.IsNested).toBe(true);

        // Section chip filter narrows to init-2
        tree.SetSelectedGroup('init-2');
        expect(tree.RenderedGroups.map((g) => g.Group.ID)).toEqual(['init-2']);

        // Reset section filter and filter by 'blocked' -> only init-1 matches
        tree.SetSelectedGroup(null);
        tree.SetFilter('blocked');
        expect(tree.RenderedGroups.map((g) => g.Group.ID)).toEqual(['init-1']);
    });

    it('TaskWbsTreeComponent resolves badges, tones, clicks, and respects ReadOnly on StatusToggled', () => {
        const tree = createWbsTree();
        tree.Tasks = [sampleTasks[2]];
        tree.RowBadgeResolver = (t) =>
            t.Status === 'Blocked' ? [{ Label: 'Needs Unblock', Tone: 'error', Icon: 'fa-solid fa-lock' }] : [];
        tree.RowToneResolver = (t) => (t.Status === 'Blocked' ? 'error' : 'default');

        expect(tree.resolveRowBadges(sampleTasks[2])).toHaveLength(1);
        expect(tree.resolveRowTone(sampleTasks[2])).toBe('error');

        const clicked: string[] = [];
        const toggled: Array<{ TaskID: string; NewStatus: string }> = [];
        tree.TaskClicked.subscribe((t) => clicked.push(t.ID));
        tree.StatusToggled.subscribe((e) => toggled.push(e));

        tree.onRowClick(sampleTasks[2]);
        expect(clicked).toEqual(['task-1']);

        tree.ReadOnly = true;
        tree.onRingToggle(sampleTasks[2], 'Completed');
        expect(toggled).toEqual([]);

        tree.ReadOnly = false;
        tree.onRingToggle(sampleTasks[2], 'Completed');
        expect(toggled).toEqual([{ TaskID: 'task-1', NewStatus: 'Completed' }]);
    });
});
