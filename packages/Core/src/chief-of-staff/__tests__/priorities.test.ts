/**
 * The Chief of Staff's priorities and to-dos, built from BizApps Tasks. These helpers were part of
 * MJ core's Chief of Staff dashboard until core stopped depending on BizApps (#6193); the Tasks app
 * now owns them and adds the "Priorities & To-dos" page to the Chief of Staff application.
 */
import { describe, it, expect } from 'vitest';
import {
    BuildOwnedRootTasksFilter,
    BuildPersonScopedTaskFilter,
    BuildPrioritiesAgentContext,
    BuildPrioritySummary,
    BuildScopeRootTasksFilter,
    BuildTodoItems,
    ComputeTaskMetricPercent,
    FilterPriorityCards,
    GetTaskPriorityClass,
    IsHealthFilter,
    IsTodoTask,
    LoadTaskAssignees,
    PRIORITY_CONTEXT_NAME_CAP,
    PriorityTaskRow,
    ResolvePersonTaskScope,
    ResolvePriorityObjectiveByIDOrName,
    TaskAssignee,
    TaskIDMap,
    TaskScopeQueryRunner,
} from '../priorities.js';

function makeBaseTask(overrides: Partial<PriorityTaskRow>): PriorityTaskRow {
    return {
        ID: '00000000-0000-0000-0000-000000000001',
        ParentID: null,
        Name: 'Launch Revised Platform — Q4 (12 Weeks)',
        Description: '12-week platform launch plan',
        Status: 'In Progress',
        Priority: 'High',
        IsPriority: true,
        HealthStatus: 'OnTrack',
        ConfidenceScore: 85,
        PercentComplete: null,
        CheckInCadence: 'Weekly',
        PlanningPeriod: '2026-Q4',
        BaselineValue: 0,
        TargetValue: 12,
        CurrentValue: 3,
        UnitOfMeasure: 'weeks',
        MetricDirection: 'Up',
        DueAt: '2027-01-17T00:00:00.000Z',
        LastCheckInAt: null,
        NextCheckInDueAt: '2026-10-31T00:00:00.000Z',
        Type: 'Priority Objective',
        ...overrides,
    };
}

describe('BuildPrioritySummary', () => {
    it('groups child milestones under priority objectives and computes progress and health', () => {
        const parent = makeBaseTask({ ID: '11111111-0000-0000-0000-000000000001', HealthStatus: 'OnTrack', ConfidenceScore: 80 });
        const milestone1 = makeBaseTask({
            ID: '11111111-0000-0000-0000-000000000002', ParentID: parent.ID, Name: 'Week 3: Technical Design Complete',
            IsPriority: false, Status: 'Completed', PercentComplete: 100,
        });
        const milestone2 = makeBaseTask({
            ID: '11111111-0000-0000-0000-000000000003', ParentID: parent.ID, Name: 'Week 4: UI/UX Approved',
            IsPriority: false, Status: 'In Progress', PercentComplete: 25,
        });

        const summary = BuildPrioritySummary([parent, milestone1, milestone2], new Date('2026-10-24T15:00:00.000Z'));

        expect(summary.PriorityObjectiveCount).toBe(1);
        expect(summary.MilestoneCount).toBe(2);
        expect(summary.OnTrackCount).toBe(1);
        // Metric drives progress when a target exists: (3 - 0) / (12 - 0) = 25%, not the milestone ratio.
        expect(summary.AverageProgress).toBe(25);
        expect(summary.Cards[0].EffectivePercentComplete).toBe(25);
        expect(summary.AverageConfidenceScore).toBe(80);
        expect(summary.Cards[0].CompletedSubtaskCount).toBe(1);
        expect(summary.Cards[0].MetricProgressLabel).toBe('3 weeks / 12 weeks');
    });

    it('recognizes Priority Objectives via TaskType/Type or child subtasks even when IsPriority is absent', () => {
        const parent = makeBaseTask({ ID: '11111111-0000-0000-0000-000000000010', IsPriority: null, Type: null, TaskType: 'Priority Objective' });
        const step1 = makeBaseTask({
            ID: '11111111-0000-0000-0000-000000000011', ParentID: parent.ID, Name: 'Step 1', IsPriority: null,
            Type: null, TaskType: 'General', HealthStatus: null, Status: 'Open', PercentComplete: 0,
        });
        const summary = BuildPrioritySummary([parent, step1]);
        expect(summary.PriorityObjectiveCount).toBe(1);
        expect(summary.Cards[0].Subtasks.length).toBe(1);
    });

    it('falls back to milestone completion when the objective has no metric target', () => {
        const parent = makeBaseTask({ ID: 'R1', TargetValue: null, CurrentValue: null, BaselineValue: null });
        const done = makeBaseTask({ ID: 'M1', ParentID: 'R1', Status: 'Completed', PercentComplete: 100, TargetValue: null, CurrentValue: null });
        const open = makeBaseTask({ ID: 'M2', ParentID: 'R1', Status: 'Open', PercentComplete: 0, TargetValue: null, CurrentValue: null });
        expect(BuildPrioritySummary([parent, done, open]).Cards[0].EffectivePercentComplete).toBe(50);
    });

    it('shows no cards when no root task qualifies as a priority objective', () => {
        const plainRoot = makeBaseTask({ ID: 'R1', Name: 'Renew parking pass', IsPriority: null, Type: 'General', HealthStatus: null, PlanningPeriod: null });
        const summary = BuildPrioritySummary([plainRoot]);
        expect(summary.PriorityObjectiveCount).toBe(0);
        expect(summary.Cards).toEqual([]);
    });
});

describe('ComputeTaskMetricPercent', () => {
    it('returns progress toward an Up target measured from the baseline', () => {
        expect(ComputeTaskMetricPercent(makeBaseTask({ BaselineValue: 0, TargetValue: 12, CurrentValue: 3 }))).toBe(25);
    });
    it('returns progress toward a Down target (reduce from baseline)', () => {
        expect(ComputeTaskMetricPercent(makeBaseTask({ BaselineValue: 100, TargetValue: 50, CurrentValue: 75, MetricDirection: 'Down' }))).toBe(50);
    });
    it('returns null when the task has no target or the target equals the baseline', () => {
        expect(ComputeTaskMetricPercent(makeBaseTask({ TargetValue: null, CurrentValue: 3 }))).toBeNull();
        expect(ComputeTaskMetricPercent(makeBaseTask({ BaselineValue: 12, TargetValue: 12, CurrentValue: 3 }))).toBeNull();
    });
    it('clamps overshoot and regression to the 0-100 range', () => {
        expect(ComputeTaskMetricPercent(makeBaseTask({ BaselineValue: 0, TargetValue: 10, CurrentValue: 14 }))).toBe(100);
        expect(ComputeTaskMetricPercent(makeBaseTask({ BaselineValue: 0, TargetValue: 10, CurrentValue: -2 }))).toBe(0);
    });
});

describe('Task scope filters', () => {
    it('matches tasks the person created or is assigned to', () => {
        expect(BuildPersonScopedTaskFilter('P1', ['T1', 'T2'])).toBe("CreatedByPersonID = 'P1' OR ID IN ('T1', 'T2')");
        expect(BuildPersonScopedTaskFilter('P1', [])).toBe("CreatedByPersonID = 'P1'");
    });
    it('includes every task under a root objective the person owns, and escapes identifiers', () => {
        expect(BuildPersonScopedTaskFilter('P1', [], ['R1'])).toBe("CreatedByPersonID = 'P1' OR RootParentID IN ('R1')");
        expect(BuildPersonScopedTaskFilter("x'y", ["a'b"], ["r'c"])).toBe("CreatedByPersonID = 'x''y' OR ID IN ('a''b') OR RootParentID IN ('r''c')");
    });
    it('selects owned roots, and owned roots plus every assigned task for the root lookup', () => {
        expect(BuildOwnedRootTasksFilter('P1', ['T1'])).toBe("ParentID IS NULL AND (CreatedByPersonID = 'P1' OR ID IN ('T1'))");
        expect(BuildScopeRootTasksFilter('P1', ['T1'])).toBe("(ParentID IS NULL AND (CreatedByPersonID = 'P1' OR ID IN ('T1'))) OR ID IN ('T1')");
        expect(BuildScopeRootTasksFilter('P1', [])).toBe("ParentID IS NULL AND (CreatedByPersonID = 'P1')");
    });
});

describe('ResolvePersonTaskScope', () => {
    const PEOPLE_ENTITY_ID = 'EEEEEEEE-0000-0000-0000-000000000001';
    function makeRunner(responses: Record<string, Array<Record<string, string | null>>>) {
        const calls: Array<{ Entity: string; Filter: string; Fields?: string[] }> = [];
        const runner: TaskScopeQueryRunner = {
            RunView: async <T>(params: { EntityName?: string; ExtraFilter?: string; Fields?: string[] }) => {
                calls.push({ Entity: params.EntityName ?? '', Filter: params.ExtraFilter ?? '', Fields: params.Fields });
                return { Success: true, Results: (responses[params.EntityName ?? ''] ?? []) as T[] };
            },
        };
        return { runner, calls };
    }

    it('builds a filter over created, assigned and owned-tree tasks for the person', async () => {
        const { runner, calls } = makeRunner({
            'MJ_BizApps_Tasks: Task Assignments': [{ TaskID: 'T1' }],
            'MJ_BizApps_Tasks: Tasks': [{ ID: 'R1', RootParentID: 'R1' }],
        });
        const scope = await ResolvePersonTaskScope(runner, 'P1', PEOPLE_ENTITY_ID);
        expect(scope.PersonID).toBe('P1');
        expect(scope.Filter).toBe("CreatedByPersonID = 'P1' OR ID IN ('T1') OR RootParentID IN ('R1')");
        // Task Assignments has no PersonID column: the assignee is the polymorphic (AssigneeEntityID, AssigneeRecordID) pair.
        expect(calls[0]).toEqual({ Entity: 'MJ_BizApps_Tasks: Task Assignments', Filter: `AssigneeEntityID = '${PEOPLE_ENTITY_ID}' AND AssigneeRecordID = 'P1'`, Fields: ['TaskID'] });
        expect(calls[1].Filter).toBe("(ParentID IS NULL AND (CreatedByPersonID = 'P1' OR ID IN ('T1'))) OR ID IN ('T1')");
        expect(calls[1].Fields).toEqual(['ID', 'RootParentID']);
    });

    it('adds the root above an assigned milestone so the whole objective renders for the assignee', async () => {
        const { runner } = makeRunner({
            'MJ_BizApps_Tasks: Task Assignments': [{ TaskID: 'M1' }],
            'MJ_BizApps_Tasks: Tasks': [{ ID: 'M1', RootParentID: 'R9' }],
        });
        const scope = await ResolvePersonTaskScope(runner, 'P2', PEOPLE_ENTITY_ID);
        expect(scope.Filter).toBe("CreatedByPersonID = 'P2' OR ID IN ('M1') OR RootParentID IN ('R9')");
    });

    it('de-duplicates roots reached both directly and through an assigned milestone', async () => {
        const { runner } = makeRunner({
            'MJ_BizApps_Tasks: Task Assignments': [{ TaskID: 'M1' }],
            'MJ_BizApps_Tasks: Tasks': [
                { ID: 'RRRRRRRR-0000-0000-0000-000000000001', RootParentID: 'RRRRRRRR-0000-0000-0000-000000000001' },
                { ID: 'M1', RootParentID: 'rrrrrrrr-0000-0000-0000-000000000001' },
            ],
        });
        const scope = await ResolvePersonTaskScope(runner, 'P1', PEOPLE_ENTITY_ID);
        expect(scope.Filter.match(/RootParentID IN \(([^)]*)\)/)?.[1]).toBe("'RRRRRRRR-0000-0000-0000-000000000001'");
    });

    it('throws when a lookup fails so the caller can surface the error', async () => {
        const runner: TaskScopeQueryRunner = { RunView: async () => ({ Success: false, Results: [], ErrorMessage: 'boom' }) };
        await expect(ResolvePersonTaskScope(runner, 'P1', PEOPLE_ENTITY_ID)).rejects.toThrow('boom');
    });

    it('escapes the person id and the entity id in the assignment filter', async () => {
        const { runner, calls } = makeRunner({});
        await ResolvePersonTaskScope(runner, "P'1", "E'1");
        expect(calls[0].Filter).toBe("AssigneeEntityID = 'E''1' AND AssigneeRecordID = 'P''1'");
    });
});

describe('Server-side callers pass the acting user to every query', () => {
    // Server code has no signed-in user to fall back on: RunView throws "User not found in
    // metadata" unless each call carries the context user.
    it('forwards contextUser on every scope and assignee query', async () => {
        const users: unknown[] = [];
        const runner: TaskScopeQueryRunner = {
            RunView: async <T>(params: { EntityName?: string }, contextUser?: unknown) => {
                users.push(contextUser);
                const rows: Record<string, Array<Record<string, string>>> = {
                    'MJ_BizApps_Tasks: Task Assignments': [{ TaskID: 'T1', AssigneeRecordID: 'P1' }],
                    'MJ_BizApps_Common: People': [{ ID: 'P1', FirstName: 'A', LastName: 'B' }],
                };
                return { Success: true, Results: (rows[params.EntityName ?? ''] ?? []) as T[] };
            },
        };
        const user = { ID: 'U1' } as unknown as Parameters<typeof ResolvePersonTaskScope>[3];
        await ResolvePersonTaskScope(runner, 'P1', 'E1', user);
        await LoadTaskAssignees(runner, 'E1', ['T1'], user);
        expect(users.length).toBe(4);
        expect(users.every((u) => u === user)).toBe(true);
    });
});

describe('LoadTaskAssignees', () => {
    const PEOPLE_ENTITY_ID = 'EEEEEEEE-0000-0000-0000-000000000001';
    it('maps each task to the people assigned to it, by name, and runs no query for an empty list', async () => {
        const calls: string[] = [];
        const responses: Record<string, Array<Record<string, string | null>>> = {
            'MJ_BizApps_Tasks: Task Assignments': [
                { TaskID: 'T1', AssigneeRecordID: 'p1' },
                { TaskID: 'T1', AssigneeRecordID: 'P2' },
                { TaskID: 'T2', AssigneeRecordID: 'P2' },
            ],
            'MJ_BizApps_Common: People': [
                { ID: 'P1', FirstName: 'Paul', LastName: 'Christmann' },
                { ID: 'P2', FirstName: 'Jimmy', LastName: 'Smits' },
            ],
        };
        const runner: TaskScopeQueryRunner = {
            RunView: async <T>(params: { EntityName?: string; ExtraFilter?: string }) => {
                calls.push(params.ExtraFilter ?? '');
                return { Success: true, Results: (responses[params.EntityName ?? ''] ?? []) as T[] };
            },
        };
        const map = await LoadTaskAssignees(runner, PEOPLE_ENTITY_ID, ['T1', 'T2']);
        expect(map.Get('t1')?.map((a) => a.Name)).toEqual(['Paul Christmann', 'Jimmy Smits']);
        expect(map.Get('T2')?.map((a) => a.PersonID)).toEqual(['P2']);
        expect(calls).toEqual([`AssigneeEntityID = '${PEOPLE_ENTITY_ID}' AND TaskID IN ('T1', 'T2')`, "ID IN ('p1', 'P2')"]);

        calls.length = 0;
        expect((await LoadTaskAssignees(runner, PEOPLE_ENTITY_ID, [])).Get('T1')).toBeUndefined();
        expect(calls).toEqual([]);
    });
});

describe('Assignees, owners and holders', () => {
    function assigneesWith(entries: Array<[string, string, string?]>): TaskIDMap<TaskAssignee[]> {
        const map = new TaskIDMap<TaskAssignee[]>();
        for (const [task, person, name] of entries) {
            map.Set(task, [...(map.Get(task) ?? []), { PersonID: person, Name: name ?? person }]);
        }
        return map;
    }
    const root = () => makeBaseTask({ ID: 'R1', Name: 'Launch', CreatedByPersonID: 'P1', CreatedByPerson: 'Paul Christmann' });

    it('attaches assignees to the objective and each milestone, and marks the ones held by the current person', () => {
        const card = BuildPrioritySummary(
            [makeBaseTask({ ID: 'R1', Name: 'Launch', CreatedByPersonID: 'P2' }), makeBaseTask({ ID: 'M1', ParentID: 'R1' }), makeBaseTask({ ID: 'M2', ParentID: 'R1' })],
            new Date(),
            { Assignees: assigneesWith([['r1', 'P1', 'Paul Christmann'], ['M1', 'p2', 'Jimmy Smits']]), CurrentPersonID: 'P2' },
        ).Cards[0];
        expect(card.Assignees.map((a) => a.Name)).toEqual(['Paul Christmann']);
        expect(card.Milestones.map((m) => [m.Task.ID, m.Assignees.map((a) => a.Name), m.AssignedToMe])).toEqual([
            ['M1', ['Jimmy Smits'], true],
            ['M2', [], false],
        ]);
    });

    it('a non-owner assignee sees only the milestones they hold, while progress still counts them all', () => {
        const card = BuildPrioritySummary(
            [root(), makeBaseTask({ ID: 'M1', ParentID: 'R1' }), makeBaseTask({ ID: 'M2', ParentID: 'R1', CreatedByPersonID: 'P1' }), makeBaseTask({ ID: 'M3', ParentID: 'R1', Status: 'Completed', CreatedByPersonID: 'P1' })],
            new Date(),
            { Assignees: assigneesWith([['M1', 'P2']]), CurrentPersonID: 'P2' },
        ).Cards[0];
        expect(card.IsOwner).toBe(false);
        expect(card.Milestones.map((m) => m.Task.ID)).toEqual(['M1']);
        expect(card.Subtasks.length).toBe(3);
        expect(card.EffectivePercentComplete).toBe(25);
    });

    it('the creator, or a person assigned to the objective itself, owns it and sees every milestone', () => {
        const tasks = [root(), makeBaseTask({ ID: 'M1', ParentID: 'R1' }), makeBaseTask({ ID: 'M2', ParentID: 'R1' })];
        expect(BuildPrioritySummary(tasks, new Date(), { CurrentPersonID: 'p1' }).Cards[0].Milestones.length).toBe(2);
        const assigned = BuildPrioritySummary(tasks, new Date(), { Assignees: assigneesWith([['R1', 'P3']]), CurrentPersonID: 'P3' }).Cards[0];
        expect(assigned.IsOwner).toBe(true);
        expect(assigned.Milestones.length).toBe(2);
    });

    it('names the owner from the creator, and has none when the objective carries no creator', () => {
        const card = BuildPrioritySummary([root()], new Date(), { CurrentPersonID: 'P2' }).Cards[0];
        expect(card.Owner).toEqual({ PersonID: 'P1', Name: 'Paul Christmann' });
        expect(card.OwnedByMe).toBe(false);
        expect(BuildPrioritySummary([makeBaseTask({ ID: 'R1', CreatedByPersonID: null })]).Cards[0].Owner).toBeNull();
    });

    it('an unassigned milestone is held by its creator, else by the objective\'s owner', () => {
        const byCreator = BuildPrioritySummary([root(), makeBaseTask({ ID: 'M1', ParentID: 'R1', CreatedByPersonID: 'P2', CreatedByPerson: 'Jimmy Smits' })], new Date(), { CurrentPersonID: 'P2' }).Cards[0].Milestones[0];
        expect(byCreator.Holders).toEqual([{ PersonID: 'P2', Name: 'Jimmy Smits' }]);
        expect(byCreator.IsImplicitlyHeld).toBe(true);
        expect(byCreator.HeldByMe).toBe(true);
        expect(byCreator.AssignedToMe).toBe(false);

        const byOwner = BuildPrioritySummary([root(), makeBaseTask({ ID: 'M1', ParentID: 'R1', CreatedByPersonID: null })], new Date(), { CurrentPersonID: 'p1' }).Cards[0].Milestones[0];
        expect(byOwner.Holders).toEqual([{ PersonID: 'P1', Name: 'Paul Christmann' }]);
    });
});

describe('To-dos and reminders', () => {
    const now = new Date('2026-10-28T18:00:00.000Z');
    const todo = (over: Partial<PriorityTaskRow>) => makeBaseTask({
        ID: 'T-' + (over.Name ?? 'x'), Type: 'General', IsPriority: false, HealthStatus: null, PlanningPeriod: null,
        TargetValue: null, CurrentValue: null, BaselineValue: null, Status: 'Open', ...over,
    });

    it('a root task of a to-do type that is not an objective is a to-do', () => {
        for (const type of ['General', 'Action Item', 'follow-up', 'Reminder']) {
            expect(IsTodoTask(todo({ Type: type }))).toBe(true);
        }
        expect(IsTodoTask(makeBaseTask({ Name: 'Launch' }))).toBe(false);
        expect(IsTodoTask(todo({ ParentID: 'R1' }))).toBe(false);
        expect(IsTodoTask(todo({ Type: 'Key Result' }))).toBe(false);
        expect(IsTodoTask(todo({ Type: null }))).toBe(false);
        expect(IsTodoTask(todo({ HealthStatus: 'OnTrack' }))).toBe(false);
    });

    it('lists open to-dos by due date, undated last, and flags overdue and due-today ones', () => {
        const items = BuildTodoItems([
            todo({ Name: 'Undated', DueAt: null }),
            todo({ Name: 'Tomorrow', DueAt: '2026-10-29T15:00:00.000Z' }),
            todo({ Name: 'Yesterday', DueAt: '2026-10-27T15:00:00.000Z' }),
            todo({ Name: 'Today', DueAt: '2026-10-28T22:00:00.000Z' }),
            todo({ Name: 'Done', DueAt: '2026-10-26T15:00:00.000Z', Status: 'Completed' }),
            todo({ Name: 'Dropped', DueAt: '2026-10-26T15:00:00.000Z', Status: 'Cancelled' }),
            makeBaseTask({ Name: 'Launch' }),
        ], now);
        expect(items.map((i) => i.Task.Name)).toEqual(['Yesterday', 'Today', 'Tomorrow', 'Undated']);
        expect(items.map((i) => i.IsOverdue)).toEqual([true, false, false, false]);
        expect(items.map((i) => i.IsDueToday)).toEqual([false, true, false, false]);
    });

    it('the summary carries the to-dos and their open count', () => {
        const summary = BuildPrioritySummary([todo({ Name: 'Call Mom' }), todo({ Name: 'Done', Status: 'Completed' }), makeBaseTask({ Name: 'Launch' })], now);
        expect(summary.TodoItems.map((i) => i.Task.Name)).toEqual(['Call Mom']);
        expect(summary.OpenTodoCount).toBe(1);
        expect(summary.Cards.map((c) => c.Task.Name)).toEqual(['Launch']);
    });
});

describe('Filtering, lookup and badge helpers', () => {
    const summary = () => BuildPrioritySummary([
        makeBaseTask({ ID: '11111111-0000-0000-0000-000000000001', Name: 'Launch Revised Platform — Q4', HealthStatus: 'OnTrack' }),
        makeBaseTask({ ID: '11111111-0000-0000-0000-000000000002', Name: 'Expand Enterprise Partner Network', HealthStatus: 'AtRisk' }),
    ]);

    it('filters cards by health and by search text in the name or description', () => {
        const cards = summary().Cards;
        expect(FilterPriorityCards(cards, 'AtRisk', '').map((c) => c.Task.Name)).toEqual(['Expand Enterprise Partner Network']);
        expect(FilterPriorityCards(cards, 'all', 'revised').map((c) => c.Task.Name)).toEqual(['Launch Revised Platform — Q4']);
        expect(FilterPriorityCards(cards, 'all', '').length).toBe(2);
    });

    it('accepts only known health filters', () => {
        expect(IsHealthFilter('AtRisk')).toBe(true);
        expect(IsHealthFilter('all')).toBe(true);
        expect(IsHealthFilter('unknown')).toBe(false);
        expect(IsHealthFilter(3)).toBe(false);
    });

    it('resolves an objective by ID, exact name, or unambiguous partial name', () => {
        const cards = summary().Cards;
        expect(ResolvePriorityObjectiveByIDOrName(cards, '11111111-0000-0000-0000-000000000001').ok).toBe(true);
        const byPartial = ResolvePriorityObjectiveByIDOrName(cards, 'partner');
        expect(byPartial.ok && byPartial.value.Task.Name).toBe('Expand Enterprise Partner Network');
        expect(ResolvePriorityObjectiveByIDOrName(cards, 'nonexistent').ok).toBe(false);
        expect(ResolvePriorityObjectiveByIDOrName(cards, 'e').ok).toBe(false);
    });

    it('maps the Tasks Priority value list onto badge classes', () => {
        expect(GetTaskPriorityClass('Critical')).toBe('priority-critical');
        expect(GetTaskPriorityClass('High')).toBe('priority-high');
        expect(GetTaskPriorityClass('Medium')).toBe('priority-normal');
        expect(GetTaskPriorityClass('Low')).toBe('priority-low');
        expect(GetTaskPriorityClass(null)).toBe('priority-normal');
    });
});

describe('BuildPrioritiesAgentContext', () => {
    it('publishes counts and bounded names, never descriptions', () => {
        const tasks = Array.from({ length: PRIORITY_CONTEXT_NAME_CAP + 3 }, (_, i) =>
            makeBaseTask({ ID: `R${i}`, Name: `Objective ${i + 1}`, Description: 'private detail' }));
        const ctx = BuildPrioritiesAgentContext(BuildPrioritySummary(tasks), 'all', '');
        expect(ctx['Surface']).toBe('ChiefOfStaff.TasksPriorities');
        expect(ctx['PriorityObjectiveCount']).toBe(PRIORITY_CONTEXT_NAME_CAP + 3);
        expect((ctx['VisiblePriorityObjectiveNames'] as string[]).length).toBe(PRIORITY_CONTEXT_NAME_CAP);
        expect(ctx['VisiblePriorityObjectiveNamesTruncated']).toBe(true);
        expect(JSON.stringify(ctx)).not.toContain('private detail');
    });
});
