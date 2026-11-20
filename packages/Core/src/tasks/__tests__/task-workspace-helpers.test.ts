import { describe, it, expect } from 'vitest';
import {
    ClassifyTaskHorizon,
    ComputeChildRollups,
    ComputeCriticalPathTaskIds,
    ComputeTaskUrgencyCounts,
    GroupTasksIntoMilestones,
    MatchesAssigneeFilter,
    MatchesDueDateFilter,
    type TaskWorkspaceSummary,
} from '../task-workspace-helpers.js';

describe('task-workspace-helpers', () => {
    const now = new Date(2026, 10, 18, 12, 0, 0, 0);

    const sampleTasks: TaskWorkspaceSummary[] = [
        {
            ID: 't-app',
            Name: 'Approve 18% Acme discount',
            ParentID: null,
            Status: 'Open',
            Priority: 'High',
            DueAt: new Date(2026, 10, 19, 17, 0, 0),
            PercentComplete: 0,
            IsApproval: true,
            HasPendingDecision: true,
        },
        {
            ID: 't-overdue',
            Name: 'Overdue security review',
            ParentID: null,
            Status: 'InProgress',
            Priority: 'High',
            DueAt: new Date(2026, 10, 16, 17, 0, 0),
            PercentComplete: 40,
            PredictedSLARiskBand: 'High',
        },
        {
            ID: 't-blocked',
            Name: 'Blocked migration cutover',
            ParentID: 't-parent',
            Status: 'Blocked',
            Priority: 'Critical',
            DueAt: new Date(2026, 10, 22, 17, 0, 0),
            PercentComplete: 25,
        },
        {
            ID: 't-upcoming',
            Name: 'Plan Q1 kickoff',
            ParentID: 't-parent',
            Status: 'Open',
            Priority: 'Low',
            DueAt: new Date(2026, 11, 10, 17, 0, 0),
            PercentComplete: 100,
        },
        {
            ID: 't-done',
            Name: 'Publish release notes',
            ParentID: 't-parent',
            Status: 'Completed',
            Priority: 'Medium',
            DueAt: new Date(2026, 10, 15, 17, 0, 0),
            PercentComplete: 100,
        },
    ];

    it('classifies tasks into Action Horizons accurately', () => {
        expect(ClassifyTaskHorizon(sampleTasks[0], now)).toBe('needs-decision');
        expect(ClassifyTaskHorizon(sampleTasks[1], now)).toBe('focus-today');
        expect(ClassifyTaskHorizon(sampleTasks[2], now)).toBe('blocked-waiting');
        expect(ClassifyTaskHorizon(sampleTasks[3], now)).toBe('coming-up');
        expect(ClassifyTaskHorizon(sampleTasks[4], now)).toBe('completed');
    });

    it('computes non-zero urgency counts', () => {
        const counts = ComputeTaskUrgencyCounts(sampleTasks, now);
        expect(counts).toEqual({
            Overdue: 1,
            Blocked: 1,
            PendingApprovals: 1,
            SlaAtRisk: 1,
        });
    });

    it('computes parent child rollups', () => {
        const rollups = ComputeChildRollups(sampleTasks);
        const parentRollup = rollups.get('t-parent');
        expect(parentRollup).toBeDefined();
        expect(parentRollup?.TotalChildren).toBe(3);
        expect(parentRollup?.CompletedChildren).toBe(1);
        expect(parentRollup?.RollupPercent).toBe(75);
    });

    it('computes longest dependency chain for critical path', () => {
        const tasks: TaskWorkspaceSummary[] = [
            { ID: 'A', Name: 'Spec', ParentID: null, Status: 'InProgress', Priority: 'High', StartedAt: '2026-11-01', DueAt: '2026-11-04', PercentComplete: 100 },
            { ID: 'B', Name: 'Build', ParentID: null, Status: 'InProgress', Priority: 'High', StartedAt: '2026-11-04', DueAt: '2026-11-14', PercentComplete: 50 },
            { ID: 'C', Name: 'QA', ParentID: null, Status: 'Open', Priority: 'High', StartedAt: '2026-11-14', DueAt: '2026-11-18', PercentComplete: 0 },
            { ID: 'D', Name: 'Short side task', ParentID: null, Status: 'Open', Priority: 'Low', StartedAt: '2026-11-04', DueAt: '2026-11-06', PercentComplete: 0 },
        ];
        const critical = ComputeCriticalPathTaskIds(tasks, [
            { DependsOnTaskID: 'A', TaskID: 'B', DependencyType: 'FinishToStart' },
            { DependsOnTaskID: 'B', TaskID: 'C', DependencyType: 'FinishToStart' },
            { DependsOnTaskID: 'A', TaskID: 'D', DependencyType: 'FinishToStart' },
        ]);
        expect([...critical].sort()).toEqual(['a', 'b', 'c']);
    });

    it('groups tasks chronologically into mobile milestone buckets', () => {
        const buckets = GroupTasksIntoMilestones(sampleTasks, now);
        expect(buckets.map((b) => b.Key)).toEqual(['overdue', 'this-week', 'upcoming', 'completed']);
        expect(buckets[0].Tasks.map((t) => t.ID)).toEqual(['t-overdue']);
        expect(buckets[1].Tasks.map((t) => t.ID)).toEqual(['t-app', 't-blocked']);
    });

    it('filters tasks accurately by Due Date bucket across List, Board, and Gantt', () => {
        expect(MatchesDueDateFilter(new Date(2026, 10, 16, 17, 0, 0), 'InProgress', 'overdue', now)).toBe(true);
        expect(MatchesDueDateFilter(new Date(2026, 10, 16, 17, 0, 0), 'Completed', 'overdue', now)).toBe(false);
        expect(MatchesDueDateFilter(new Date(2026, 10, 18, 17, 0, 0), 'Open', 'today', now)).toBe(true);
        expect(MatchesDueDateFilter(new Date(2026, 10, 21, 17, 0, 0), 'Open', 'week', now)).toBe(true);
        expect(MatchesDueDateFilter(new Date(2026, 11, 10, 17, 0, 0), 'Open', 'month', now)).toBe(true);
        expect(MatchesDueDateFilter(null, 'Open', 'none', now)).toBe(true);
        expect(MatchesDueDateFilter(new Date(2026, 10, 18, 17, 0, 0), 'Open', 'none', now)).toBe(false);
    });

    it('filters tasks accurately by Assignee (Me, Unassigned, Person, or MJ Role)', () => {
        const assignees = [
            { EntityName: 'MJ_BizApps_Common: People', RecordID: 'p-alice' },
            { EntityName: 'MJ: Roles', RecordID: 'r-finance' },
        ];
        expect(MatchesAssigneeFilter([], '__unassigned__', 'p-alice')).toBe(true);
        expect(MatchesAssigneeFilter(assignees, '__unassigned__', 'p-alice')).toBe(false);
        expect(MatchesAssigneeFilter(assignees, '__me__', 'p-alice')).toBe(true);
        expect(MatchesAssigneeFilter(assignees, '__me__', 'p-other', ['r-finance'])).toBe(true);
        expect(MatchesAssigneeFilter(assignees, 'person:p-alice', null)).toBe(true);
        expect(MatchesAssigneeFilter(assignees, 'role:r-finance', null)).toBe(true);
        expect(MatchesAssigneeFilter(assignees, 'person:p-bob', null)).toBe(false);
    });
});
