import { describe, expect, it } from 'vitest';
import {
    AssignWbsCodes,
    BuildWbsTree,
    ComputeWbsSummary,
    FilterWbsTreePreservingAncestors,
    FlattenVisibleWbsNodes,
    type TaskWbsNode,
    type TaskWbsNodeInput,
} from '../wbs/wbs-tree.js';

interface TestTask extends TaskWbsNodeInput {
    Tag?: string;
}

describe('wbs-tree pure algorithms', () => {
    const sampleTasks: TestTask[] = [
        { ID: 'p2', ParentID: null, Name: 'Phase 2: Launch', Status: 'Open', PercentComplete: null, Sequence: 20, DueAt: '2026-12-20T00:00:00Z' },
        { ID: 'p1', ParentID: null, Name: 'Phase 1: Discovery', Status: 'InProgress', PercentComplete: null, Sequence: 10, DueAt: '2026-11-10T00:00:00Z' },
        { ID: 'm1', ParentID: 'p1', Name: 'Milestone A', Status: 'InProgress', PercentComplete: null, Sequence: 10, DueAt: '2026-11-05T00:00:00Z' },
        { ID: 't1', ParentID: 'm1', Name: 'Stakeholder Interviews', Status: 'Completed', PercentComplete: 100, Sequence: 10, DueAt: '2026-11-01T00:00:00Z' },
        { ID: 't2', ParentID: 'm1', Name: 'Security Review', Status: 'Blocked', PercentComplete: 20, Sequence: 20, DueAt: '2026-11-02T00:00:00Z' },
        { ID: 's1', ParentID: 't2', Name: 'SOC2 Checklist', Status: 'Open', PercentComplete: 0, Sequence: 10, DueAt: '2026-11-01T00:00:00Z' },
        { ID: 'm2', ParentID: 'p1', Name: 'Milestone B', Status: 'Open', PercentComplete: 0, Sequence: 20, DueAt: '2026-12-01T00:00:00Z' },
    ];

    it('BuildWbsTree builds 4-level hierarchy sorted deterministically by Sequence ASC, Name ASC', () => {
        const tree = BuildWbsTree(sampleTasks);

        expect(tree.map((n) => n.Item.ID)).toEqual(['p1', 'p2']);
        expect(tree[0].WbsCode).toBe('1');
        expect(tree[0].Depth).toBe(0);
        expect(tree[1].WbsCode).toBe('2');
        expect(tree[1].Depth).toBe(0);

        // Level 1 under Phase 1
        expect(tree[0].Children.map((n) => [n.Item.ID, n.WbsCode, n.Depth])).toEqual([
            ['m1', '1.1', 1],
            ['m2', '1.2', 1],
        ]);

        // Level 2 under Milestone A
        const m1 = tree[0].Children[0];
        expect(m1.Children.map((n) => [n.Item.ID, n.WbsCode, n.Depth])).toEqual([
            ['t1', '1.1.1', 2],
            ['t2', '1.1.2', 2],
        ]);

        // Level 3 under Security Review
        const t2 = m1.Children[1];
        expect(t2.Children.map((n) => [n.Item.ID, n.WbsCode, n.Depth])).toEqual([['s1', '1.1.2.1', 3]]);
    });

    it('sorts ties in Sequence alphabetically by Name ASC and handles null Sequence last', () => {
        const tasks: TestTask[] = [
            { ID: 'c', ParentID: null, Name: 'Zeta', Status: 'Open', Sequence: null },
            { ID: 'b', ParentID: null, Name: 'Beta', Status: 'Open', Sequence: 1 },
            { ID: 'a', ParentID: null, Name: 'Alpha', Status: 'Open', Sequence: 1 },
            { ID: 'd', ParentID: null, Name: 'Gamma', Status: 'Open', Sequence: undefined },
        ];
        const tree = BuildWbsTree(tasks);
        expect(tree.map((n) => n.Item.ID)).toEqual(['a', 'b', 'd', 'c']);
        expect(tree.map((n) => n.WbsCode)).toEqual(['1', '2', '3', '4']);
    });

    it('promotes orphans and breaks parent cycles gracefully without dropping tasks', () => {
        const tasks: TestTask[] = [
            { ID: 'orphan', ParentID: 'missing-parent', Name: 'Orphan Task', Status: 'Open', Sequence: 1 },
            { ID: 'self', ParentID: 'self', Name: 'Self Parent', Status: 'Open', Sequence: 2 },
            { ID: 'cyc-a', ParentID: 'cyc-b', Name: 'Cycle A', Status: 'Open', Sequence: 3 },
            { ID: 'cyc-b', ParentID: 'cyc-a', Name: 'Cycle B', Status: 'Open', Sequence: 4 },
        ];
        const tree = BuildWbsTree(tasks);
        expect(tree.map((n) => n.Item.ID)).toEqual(['orphan', 'self', 'cyc-a', 'cyc-b']);
    });

    it('AssignWbsCodes rolls up child average PercentComplete when parent PercentComplete is null', () => {
        const tree = BuildWbsTree(sampleTasks);

        // m1 has null PercentComplete; children t1 (100) and t2 (20) -> average 60
        const m1 = tree[0].Children[0];
        expect(m1.EffectivePercentComplete).toBe(60);

        // p1 has null PercentComplete; children m1 (60) and m2 (0) -> average 30
        expect(tree[0].EffectivePercentComplete).toBe(30);
        expect(tree[0].TotalDescendantCount).toBe(5);
        expect(tree[0].CompletedDescendantCount).toBe(1);

        // Explicit parent PercentComplete is preserved (t2 has 20 even though child s1 is 0)
        const t2 = m1.Children[1];
        expect(t2.EffectivePercentComplete).toBe(20);

        // Purity: re-running AssignWbsCodes returns fresh clones without mutating input
        const renumbered = AssignWbsCodes([tree[1], tree[0]]);
        expect(renumbered[0].WbsCode).toBe('1');
        expect(renumbered[1].WbsCode).toBe('2');
        expect(tree[0].WbsCode).toBe('1');
    });

    it('ComputeWbsSummary computes accurate status, overdue, and overall completion metrics', () => {
        const tree = BuildWbsTree(sampleTasks);
        const now = new Date('2026-11-15T00:00:00Z');
        const summary = ComputeWbsSummary(tree, now);

        expect(summary.TotalCount).toBe(7);
        expect(summary.CompletedCount).toBe(1); // t1
        expect(summary.InProgressCount).toBe(2); // p1, m1
        expect(summary.BlockedCount).toBe(1); // t2
        expect(summary.OpenCount).toBe(3); // p2, s1, m2
        // Overdue active tasks (< 2026-11-15): p1 (Nov 10), m1 (Nov 5), t2 (Nov 2), s1 (Nov 1). t1 is Completed so NOT overdue.
        expect(summary.OverdueCount).toBe(4);
        // Effective percents: p1=30, m1=60, t1=100, t2=20, s1=0, m2=0, p2=0 -> sum=210 / 7 = 30
        expect(summary.OverallCompletionPercent).toBe(30);

        expect(ComputeWbsSummary([])).toEqual({
            TotalCount: 0,
            CompletedCount: 0,
            InProgressCount: 0,
            BlockedCount: 0,
            OpenCount: 0,
            OverdueCount: 0,
            OverallCompletionPercent: 0,
        });
    });

    it('FilterWbsTreePreservingAncestors keeps full ancestor chain and preserves original WbsCodes', () => {
        const tree = BuildWbsTree(sampleTasks);
        const filtered = FilterWbsTreePreservingAncestors(tree, (item) => item.Name.includes('SOC2'));

        // p1 -> m1 -> t2 -> s1 must be preserved; p2, m2, t1 pruned
        expect(filtered.map((n) => n.Item.ID)).toEqual(['p1']);
        expect(filtered[0].WbsCode).toBe('1');
        expect(filtered[0].Children.map((n) => n.Item.ID)).toEqual(['m1']);
        expect(filtered[0].Children[0].WbsCode).toBe('1.1');
        expect(filtered[0].Children[0].Children.map((n) => n.Item.ID)).toEqual(['t2']);
        expect(filtered[0].Children[0].Children[0].WbsCode).toBe('1.1.2');
        expect(filtered[0].Children[0].Children[0].Children.map((n) => n.Item.ID)).toEqual(['s1']);
        expect(filtered[0].Children[0].Children[0].Children[0].WbsCode).toBe('1.1.2.1');
    });

    it('FlattenVisibleWbsNodes hides ALL descendants when ANY ancestor is collapsed (no orphaned grandchildren)', () => {
        const tree = BuildWbsTree(sampleTasks);

        // Expanded by default -> all 7 rows visible
        const allRows = FlattenVisibleWbsNodes(tree, new Set());
        expect(allRows.map((r) => r.Item.ID)).toEqual(['p1', 'm1', 't1', 't2', 's1', 'm2', 'p2']);
        expect(allRows.find((r) => r.Item.ID === 's1')?.AncestorIds).toEqual(['p1', 'm1', 't2']);

        // Collapsing Level 0 root p1 (even with uppercase ID) hides m1, t1, t2, s1, m2 completely
        const collapsedRoot = FlattenVisibleWbsNodes(tree, new Set(['P1']));
        expect(collapsedRoot.map((r) => r.Item.ID)).toEqual(['p1', 'p2']);
        expect(collapsedRoot[0].HasChildren).toBe(true);
        expect(collapsedRoot[0].Expanded).toBe(false);

        // Collapsing Level 1 m1 hides t1, t2, AND grandchild s1, while keeping m2
        const collapsedM1 = FlattenVisibleWbsNodes(tree, new Set(['m1']));
        expect(collapsedM1.map((r) => r.Item.ID)).toEqual(['p1', 'm1', 'm2', 'p2']);

        // forceExpandAll overrides collapsedIds
        const forced = FlattenVisibleWbsNodes(tree, new Set(['p1', 'm1']), true);
        expect(forced.map((r) => r.Item.ID)).toEqual(['p1', 'm1', 't1', 't2', 's1', 'm2', 'p2']);
        expect(forced[0].Expanded).toBe(true);
    });

    it('supports mixed-case parent/child UUIDs cleanly', () => {
        const tree: TaskWbsNode<TestTask>[] = BuildWbsTree([
            { ID: 'AAAA-1111', ParentID: null, Name: 'Root', Status: 'Open', Sequence: 1 },
            { ID: 'BBBB-2222', ParentID: 'aaaa-1111', Name: 'Child', Status: 'Completed', Sequence: 1 },
        ]);
        expect(tree).toHaveLength(1);
        expect(tree[0].Children).toHaveLength(1);
        expect(tree[0].Children[0].WbsCode).toBe('1.1');
    });
});
