import '@angular/compiler';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';
import {
    EntityInfo,
    UserInfo,
    type IMetadataProvider,
    type IRunViewProvider,
    type RunViewParams,
    type RunViewResult,
} from '@memberjunction/core';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import {
    AggregatePendingSuggestionsByTask,
    BIZAPPS_TASKS_ENTITY_NAME,
    BuildPendingSuggestionsSqlFilter,
    CountTotalPendingSuggestions,
    FilterTasksByPendingSuggestions,
    FormatPendingSuggestionTooltip,
    IsPendingFieldSuggestionRow,
    LoadTaskPendingSuggestions,
    TASK_FIELD_SUGGESTIONS_ENTITY_NAME,
    TaskFieldSuggestionsHelper,
    type TaskFieldSuggestionRow,
    type TaskRunViewRunner,
} from '../task-field-suggestions.helper';
import { TaskListComponent, type TaskRow } from '../components/task-list/task-list.component';
import { TaskKanbanComponent, type KanbanTaskData } from '../components/task-kanban/task-kanban.component';
import { TaskDetailPanelComponent } from '../components/task-detail-panel/task-detail-panel.component';
import { TasksDashboardPageComponent } from '../pages/tasks-dashboard.page';

const TASKS_ENTITY_ID = '99999999-9999-4999-8999-999999999991';
const FIELD_SUGGESTIONS_ENTITY_ID = '99999999-9999-4999-8999-999999999994';
const TASK_ALPHA = '11111111-1111-4111-8111-111111111111';
const TASK_BETA = '22222222-2222-4222-8222-222222222222';
const TASK_GAMMA = '33333333-3333-4333-8333-333333333333';

type TestMetadataAndRunViewProvider = IMetadataProvider & IRunViewProvider;

function makeEntityStub(id: string, name: string): EntityInfo {
    return { ID: id, Name: name } as Partial<EntityInfo> as EntityInfo;
}

type MockRowPayload = object;

function makeRunViewSuccess(rows: readonly MockRowPayload[]) {
    return {
        Success: true,
        Results: rows,
        RowCount: rows.length,
        TotalRowCount: rows.length,
        ExecutionTime: 1,
        ErrorMessage: '',
    };
}

function createMockProvider(options: {
    includeFieldSuggestions: boolean;
    includeTasksEntity?: boolean;
    onRunView?: (params: RunViewParams, contextUser?: UserInfo) => {
        Success: boolean;
        Results: readonly MockRowPayload[];
        RowCount: number;
        TotalRowCount: number;
        ExecutionTime: number;
        ErrorMessage: string;
    };
}): TestMetadataAndRunViewProvider {
    const entities: EntityInfo[] = [];
    if (options.includeTasksEntity !== false) {
        entities.push(makeEntityStub(TASKS_ENTITY_ID, BIZAPPS_TASKS_ENTITY_NAME));
    }
    if (options.includeFieldSuggestions) {
        entities.push(makeEntityStub(FIELD_SUGGESTIONS_ENTITY_ID, TASK_FIELD_SUGGESTIONS_ENTITY_NAME));
    }

    const user = new UserInfo();
    user.ID = 'aaaa1111-1111-4111-8111-111111111111';
    user.Email = 'tester@example.com';

    const runViewSpy = vi.fn(async (params: RunViewParams, contextUser?: UserInfo) => {
        if (options.onRunView) {
            return options.onRunView(params, contextUser);
        }
        return makeRunViewSuccess([]);
    });

    const partial: Partial<TestMetadataAndRunViewProvider> = {
        Entities: entities,
        CurrentUser: user,
        EntityByName: (name: string) => entities.find((e) => e.Name === name),
        RunView: <T>(params: RunViewParams, contextUser?: UserInfo): Promise<RunViewResult<T>> =>
            runViewSpy(params, contextUser) as Promise<RunViewResult<never>> as Promise<RunViewResult<T>>,
        RunViews: async () => [],
    };
    return partial as TestMetadataAndRunViewProvider;
}

function createCdrMock(): ChangeDetectorRef {
    return {
        markForCheck: vi.fn(),
        detach: vi.fn(),
        detectChanges: vi.fn(),
        checkNoChanges: vi.fn(),
        reattach: vi.fn(),
    };
}

function createWithCdr<T>(factory: () => T): T {
    const injector = Injector.create({
        providers: [{ provide: ChangeDetectorRef, useValue: createCdrMock() }],
    });
    return runInInjectionContext(injector, factory);
}

describe('TaskFieldSuggestionsHelper & pure functions', () => {
    beforeEach(() => {
        vi.restoreAllMocks();
    });

    describe('Graceful pre-6.3 host behavior (MJ: Field Suggestions absent)', () => {
        it('returns available=false and empty map with zero RunView calls or console warnings when entity is absent', async () => {
            const warnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {});
            const errorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
            const runViewCalls: RunViewParams[] = [];

            const pre63Provider = createMockProvider({
                includeFieldSuggestions: false,
                onRunView: (params: RunViewParams) => {
                    runViewCalls.push(params);
                    return makeRunViewSuccess([]);
                },
            });

            expect(TaskFieldSuggestionsHelper.IsAvailable(pre63Provider)).toBe(false);
            expect(TaskFieldSuggestionsHelper.IsAvailable(null)).toBe(false);

            const res = await TaskFieldSuggestionsHelper.LoadPendingSuggestions(pre63Provider, {
                taskIds: [TASK_ALPHA],
            });
            expect(res.available).toBe(false);
            expect(res.byTaskId.size).toBe(0);
            expect(runViewCalls).toHaveLength(0);
            expect(warnSpy).not.toHaveBeenCalled();
            expect(errorSpy).not.toHaveBeenCalled();

            const nullRes = await LoadTaskPendingSuggestions(null, { taskIds: [TASK_ALPHA] });
            expect(nullRes.available).toBe(false);
            expect(nullRes.byTaskId.size).toBe(0);
        });

        it('returns available=true and empty map without calling RunView when taskIds is empty or Tasks entity is missing', async () => {
            const runViewCalls: RunViewParams[] = [];
            const provider = createMockProvider({
                includeFieldSuggestions: true,
                onRunView: (params: RunViewParams) => {
                    runViewCalls.push(params);
                    return makeRunViewSuccess([]);
                },
            });

            const emptyScope = await TaskFieldSuggestionsHelper.LoadPendingSuggestions(provider, {
                taskIds: [],
            });
            expect(emptyScope.available).toBe(true);
            expect(emptyScope.byTaskId.size).toBe(0);
            expect(runViewCalls).toHaveLength(0);

            const noTasksEntityProvider = createMockProvider({
                includeFieldSuggestions: true,
                includeTasksEntity: false,
            });
            const missingTasksRes = await TaskFieldSuggestionsHelper.LoadPendingSuggestions(noTasksEntityProvider, {
                taskIds: [TASK_ALPHA],
            });
            expect(missingTasksRes.available).toBe(true);
            expect(missingTasksRes.byTaskId.size).toBe(0);
        });
    });

    describe('Schema-verified RunView query & aggregation', () => {
        it('queries MJ: Field Suggestions with Outcome IS NULL, IsResolved = 0, and (IsArchived IS NULL OR IsArchived = 0)', async () => {
            const capturedParams: RunViewParams[] = [];
            const rows: TaskFieldSuggestionRow[] = [
                {
                    ID: 'aaaa0000-0000-4000-8000-000000000001',
                    LinkedEntityID: TASKS_ENTITY_ID,
                    LinkedRecordID: TASK_ALPHA.toUpperCase(),
                    AnchorType: 'field',
                    AnchorKey: 'DueAt',
                    SuggestedValue: '"2026-12-01"',
                    Confidence: 0.94,
                    Source: 'LLM',
                    Outcome: null,
                    IsResolved: false,
                    IsArchived: false,
                },
                {
                    ID: 'aaaa0000-0000-4000-8000-000000000002',
                    LinkedEntityID: TASKS_ENTITY_ID,
                    LinkedRecordID: TASK_ALPHA.toLowerCase(),
                    AnchorType: 'field',
                    AnchorKey: 'HoursEstimated',
                    SuggestedValue: '6',
                    Confidence: 0.85,
                    Source: 'Agent',
                    Outcome: null,
                    IsResolved: 0,
                    IsArchived: 0,
                },
                {
                    ID: 'aaaa0000-0000-4000-8000-000000000003',
                    LinkedEntityID: TASKS_ENTITY_ID,
                    LinkedRecordID: TASK_BETA,
                    AnchorType: 'field',
                    AnchorKey: 'Priority',
                    SuggestedValue: '"High"',
                    Confidence: 0.9,
                    Source: 'Integration',
                    Outcome: null,
                    IsResolved: false,
                    IsArchived: false,
                },
            ];

            const runnerSpy = vi.fn(async (params: RunViewParams) => {
                capturedParams.push(params);
                return makeRunViewSuccess(rows);
            });
            const runner: TaskRunViewRunner = {
                RunView: <T>(params: RunViewParams): Promise<RunViewResult<T>> =>
                    runnerSpy(params) as Promise<RunViewResult<never>> as Promise<RunViewResult<T>>,
            };

            const provider = createMockProvider({ includeFieldSuggestions: true });
            const res = await TaskFieldSuggestionsHelper.LoadPendingSuggestions(provider, {
                taskIds: [TASK_ALPHA, TASK_BETA, TASK_GAMMA],
                runView: runner,
            });

            expect(capturedParams).toHaveLength(1);
            const query = capturedParams[0];
            expect(query.EntityName).toBe('MJ: Field Suggestions');
            expect(query.ResultType).toBe('simple');
            const extraFilter = String(query.ExtraFilter);
            expect(extraFilter).toContain(`LinkedEntityID = '${TASKS_ENTITY_ID}'`);
            expect(extraFilter).toContain('Outcome IS NULL');
            expect(extraFilter).toContain('IsResolved = 0');
            expect(extraFilter).toContain('(IsArchived IS NULL OR IsArchived = 0)');
            expect(extraFilter).toContain(TASK_ALPHA);
            expect(extraFilter).not.toContain("Status = 'Pending'");
            expect(query.Fields).toEqual(
                expect.arrayContaining([
                    'ID',
                    'LinkedEntityID',
                    'LinkedRecordID',
                    'AnchorType',
                    'AnchorKey',
                    'SuggestedValue',
                    'Confidence',
                    'Source',
                    'Outcome',
                    'IsResolved',
                    'IsArchived',
                ]),
            );

            expect(res.available).toBe(true);
            expect(res.byTaskId.size).toBe(2);
            expect(CountTotalPendingSuggestions(res.byTaskId)).toBe(3);

            const alphaSummary = res.byTaskId.get(TASK_ALPHA.toLowerCase());
            expect(alphaSummary).toEqual({
                taskId: TASK_ALPHA.toLowerCase(),
                pendingCount: 2,
                fieldNames: ['DueAt', 'HoursEstimated'],
                topPreviewLabel: 'DueAt: 2026-12-01 (+1 more)',
            });

            const betaSummary = res.byTaskId.get(TASK_BETA.toLowerCase());
            expect(betaSummary).toEqual({
                taskId: TASK_BETA.toLowerCase(),
                pendingCount: 1,
                fieldNames: ['Priority'],
                topPreviewLabel: 'Priority: High',
            });

            expect(res.byTaskId.has(TASK_GAMMA.toLowerCase())).toBe(false);
        });

        it('aggregates case-insensitively, deduplicates repeated field names, and excludes resolved/accepted/archived rows', () => {
            const mixedRows: TaskFieldSuggestionRow[] = [
                {
                    ID: 'fs-1',
                    LinkedEntityID: TASKS_ENTITY_ID,
                    LinkedRecordID: `  ${TASK_ALPHA.toUpperCase()}  `,
                    AnchorKey: 'DueAt',
                    SuggestedValue: null,
                    Outcome: null,
                    IsResolved: false,
                },
                {
                    ID: 'fs-2',
                    LinkedEntityID: TASKS_ENTITY_ID,
                    LinkedRecordID: TASK_ALPHA.toLowerCase(),
                    AnchorKey: 'dueat',
                    SuggestedValue: '"2026-12-15"',
                    Outcome: null,
                    IsResolved: 0,
                },
                {
                    ID: 'fs-accepted',
                    LinkedEntityID: TASKS_ENTITY_ID,
                    LinkedRecordID: TASK_ALPHA,
                    AnchorKey: 'Priority',
                    SuggestedValue: '"Critical"',
                    Outcome: 'Accepted',
                    IsResolved: true,
                },
                {
                    ID: 'fs-rejected',
                    LinkedEntityID: TASKS_ENTITY_ID,
                    LinkedRecordID: TASK_BETA,
                    AnchorKey: 'HoursEstimated',
                    SuggestedValue: '12',
                    Outcome: 'Rejected',
                    IsResolved: false,
                },
                {
                    ID: 'fs-archived',
                    LinkedEntityID: TASKS_ENTITY_ID,
                    LinkedRecordID: TASK_GAMMA,
                    AnchorKey: 'ParentID',
                    SuggestedValue: '"999"',
                    Outcome: null,
                    IsResolved: false,
                    IsArchived: true,
                },
            ];

            expect(IsPendingFieldSuggestionRow(mixedRows[0])).toBe(true);
            expect(IsPendingFieldSuggestionRow(mixedRows[2])).toBe(false);
            expect(IsPendingFieldSuggestionRow(mixedRows[3])).toBe(false);
            expect(IsPendingFieldSuggestionRow(mixedRows[4])).toBe(false);

            const byTask = AggregatePendingSuggestionsByTask(mixedRows);
            expect(byTask.size).toBe(1);
            const alpha = byTask.get(TASK_ALPHA.toLowerCase());
            expect(alpha).toEqual({
                taskId: TASK_ALPHA.toLowerCase(),
                pendingCount: 2,
                fieldNames: ['DueAt'],
                topPreviewLabel: 'Clear DueAt (+1 more)',
            });
        });
    });

    describe('FilterTasksByPendingSuggestions, FormatPendingSuggestionTooltip & BuildPendingSuggestionsSqlFilter', () => {
        it('filters task collections accurately when onlyPendingSuggestions is true vs false', () => {
            const sampleTasks = [
                { ID: TASK_ALPHA.toUpperCase(), Name: 'Alpha' },
                { ID: TASK_BETA.toLowerCase(), Name: 'Beta' },
                { ID: TASK_GAMMA, Name: 'Gamma' },
            ];
            const byTask = AggregatePendingSuggestionsByTask([
                {
                    ID: 'fs-1',
                    LinkedEntityID: TASKS_ENTITY_ID,
                    LinkedRecordID: TASK_ALPHA.toLowerCase(),
                    AnchorKey: 'DueAt',
                    Outcome: null,
                    IsResolved: 0,
                },
                {
                    ID: 'fs-2',
                    LinkedEntityID: TASKS_ENTITY_ID,
                    LinkedRecordID: TASK_GAMMA.toUpperCase(),
                    AnchorKey: 'HoursEstimated',
                    Outcome: null,
                    IsResolved: 0,
                },
            ]);

            const unfiltered = FilterTasksByPendingSuggestions(sampleTasks, false, byTask);
            expect(unfiltered.map((t) => t.Name)).toEqual(['Alpha', 'Beta', 'Gamma']);

            const filtered = FilterTasksByPendingSuggestions(sampleTasks, true, byTask);
            expect(filtered.map((t) => t.Name)).toEqual(['Alpha', 'Gamma']);

            // Property fallback when map is omitted
            const fallbackTasks = [
                { ID: TASK_ALPHA, PendingSuggestionCount: 0 },
                { ID: TASK_BETA, PendingSuggestionCount: 3 },
            ];
            expect(FilterTasksByPendingSuggestions(fallbackTasks, true).map((t) => t.ID)).toEqual([TASK_BETA]);
        });

        it('formats singular, plural, field-less, and empty tooltips cleanly', () => {
            expect(
                FormatPendingSuggestionTooltip({
                    pendingCount: 2,
                    fieldNames: ['DueDate', 'EffortHours'],
                }),
            ).toBe('2 pending suggestions: DueDate, EffortHours');

            expect(
                FormatPendingSuggestionTooltip({
                    pendingCount: 1,
                    fieldNames: ['DueAt'],
                }),
            ).toBe('1 pending suggestion: DueAt');

            expect(
                FormatPendingSuggestionTooltip({
                    pendingCount: 3,
                    fieldNames: [],
                }),
            ).toBe('3 pending suggestions');

            expect(FormatPendingSuggestionTooltip(null)).toBe('');
            expect(FormatPendingSuggestionTooltip({ pendingCount: 0, fieldNames: ['DueAt'] })).toBe('');
        });

        it('builds SQL ExtraFilter clauses for Gantt views when OnlyPendingSuggestions is toggled', () => {
            const byTask = AggregatePendingSuggestionsByTask([
                {
                    ID: 'fs-1',
                    LinkedEntityID: TASKS_ENTITY_ID,
                    LinkedRecordID: TASK_ALPHA,
                    AnchorKey: 'DueAt',
                    Outcome: null,
                    IsResolved: 0,
                },
            ]);

            expect(BuildPendingSuggestionsSqlFilter(false, byTask)).toBeNull();
            expect(BuildPendingSuggestionsSqlFilter(false, byTask, "Status = 'Open'")).toBe("Status = 'Open'");
            expect(BuildPendingSuggestionsSqlFilter(true, byTask)).toBe(`ID IN ('${TASK_ALPHA}')`);
            expect(BuildPendingSuggestionsSqlFilter(true, byTask, "Status = 'Open'")).toBe(
                `(Status = 'Open') AND ID IN ('${TASK_ALPHA}')`,
            );
            expect(BuildPendingSuggestionsSqlFilter(true, new Map())).toBe('1 = 0');
        });
    });

    describe('Component UI state integration (List, Kanban, Dashboard, Detail Panel)', () => {
        it('loads pending suggestions into TaskListComponent rows, supports PendingSuggestionsOnly input/output, and resets cleanly', async () => {
            const provider = createMockProvider({
                includeFieldSuggestions: true,
                onRunView: (params: RunViewParams) => {
                    if (params.EntityName === BIZAPPS_TASKS_ENTITY_NAME) {
                        return makeRunViewSuccess([
                            {
                                ID: TASK_ALPHA.toUpperCase(),
                                Name: 'Prepare Q4 Milestone',
                                Description: null,
                                Status: 'Open',
                                Priority: 'High',
                                DueAt: null,
                                PercentComplete: 25,
                                HoursEstimated: 4,
                                ParentID: null,
                            },
                            {
                                ID: TASK_BETA,
                                Name: 'Routine Check',
                                Description: null,
                                Status: 'Open',
                                Priority: 'Low',
                                DueAt: null,
                                PercentComplete: 0,
                                HoursEstimated: null,
                                ParentID: null,
                            },
                        ]);
                    }
                    if (params.EntityName === TASK_FIELD_SUGGESTIONS_ENTITY_NAME) {
                        const fsRows: TaskFieldSuggestionRow[] = [
                            {
                                ID: 'fs-1',
                                LinkedEntityID: TASKS_ENTITY_ID,
                                LinkedRecordID: TASK_ALPHA.toLowerCase(),
                                AnchorKey: 'DueAt',
                                SuggestedValue: '"2026-12-10"',
                                Outcome: null,
                                IsResolved: 0,
                            },
                            {
                                ID: 'fs-2',
                                LinkedEntityID: TASKS_ENTITY_ID,
                                LinkedRecordID: TASK_ALPHA.toUpperCase(),
                                AnchorKey: 'HoursEstimated',
                                SuggestedValue: '8',
                                Outcome: null,
                                IsResolved: 0,
                            },
                        ];
                        return makeRunViewSuccess(fsRows);
                    }
                    return makeRunViewSuccess([]);
                },
            });

            const list = createWithCdr(() => new TaskListComponent());
            list.Provider = provider;
            list.ngOnInit();
            await list.Refresh();

            expect(list.fieldSuggestionsAvailable).toBe(true);
            expect(list.totalPendingSuggestionsCount).toBe(2);
            expect(list.tasksWithPendingSuggestionsCount).toBe(1);

            const alphaRow: TaskRow | undefined = list.tasks.find((t) => t.Name === 'Prepare Q4 Milestone');
            expect(alphaRow?.PendingSuggestionCount).toBe(2);
            expect(alphaRow?.PendingSuggestionFields).toEqual(['DueAt', 'HoursEstimated']);
            expect(alphaRow ? list.getTaskSuggestionTooltip(alphaRow) : '').toBe(
                '2 pending suggestions: DueAt, HoursEstimated',
            );

            const emittedChanges: boolean[] = [];
            list.PendingSuggestionsOnlyChange.subscribe((val: boolean) => emittedChanges.push(val));

            list.PendingSuggestionsOnly = true;
            expect(list.filteredTasks.map((t) => t.Name)).toEqual(['Prepare Q4 Milestone']);

            list.resetFilters();
            expect(list.PendingSuggestionsOnly).toBe(false);
            expect(emittedChanges).toEqual([false]);
            expect(list.filteredTasks).toHaveLength(2);
        });

        it('filters Kanban cards and enriches FooterText when PendingSuggestionsOnly toggles on TaskKanbanComponent', async () => {
            const provider = createMockProvider({
                includeFieldSuggestions: true,
                onRunView: (params: RunViewParams) => {
                    if (params.EntityName === BIZAPPS_TASKS_ENTITY_NAME) {
                        const rows: KanbanTaskData[] = [
                            {
                                ID: TASK_ALPHA,
                                Name: 'Kanban Suggested Task',
                                Description: null,
                                Status: 'InProgress',
                                Priority: 'High',
                                DueAt: null,
                                PercentComplete: 50,
                                HoursEstimated: 3,
                                ParentID: null,
                            },
                            {
                                ID: TASK_BETA,
                                Name: 'Kanban Plain Task',
                                Description: null,
                                Status: 'Open',
                                Priority: 'Medium',
                                DueAt: null,
                                PercentComplete: 0,
                                HoursEstimated: null,
                                ParentID: null,
                            },
                        ];
                        return makeRunViewSuccess(rows);
                    }
                    if (params.EntityName === TASK_FIELD_SUGGESTIONS_ENTITY_NAME) {
                        const fsRows: TaskFieldSuggestionRow[] = [
                            {
                                ID: 'fs-k1',
                                LinkedEntityID: TASKS_ENTITY_ID,
                                LinkedRecordID: TASK_ALPHA,
                                AnchorKey: 'ParentID',
                                SuggestedValue: '"goal-1"',
                                Outcome: null,
                                IsResolved: 0,
                            },
                        ];
                        return makeRunViewSuccess(fsRows);
                    }
                    return makeRunViewSuccess([]);
                },
            });

            const kanban = createWithCdr(() => new TaskKanbanComponent());
            kanban.Provider = provider;
            kanban.ngOnInit();
            await kanban.LoadTasks();

            expect(kanban.cards).toHaveLength(2);
            expect(kanban.cards[0].FooterText).toBe('1 pending suggestion: ParentID');

            kanban.PendingSuggestionsOnly = true;
            expect(kanban.cards.map((c) => c.ID)).toEqual([TASK_ALPHA]);

            kanban.PendingSuggestionsOnly = false;
            expect(kanban.cards).toHaveLength(2);
        });

        it('loads KPIs + pending suggestion totals on TasksDashboardPageComponent and loads detail banner summary on TaskDetailPanelComponent', async () => {
            const provider = createMockProvider({
                includeFieldSuggestions: true,
                onRunView: (params: RunViewParams) => {
                    if (params.EntityName === BIZAPPS_TASKS_ENTITY_NAME) {
                        return makeRunViewSuccess([
                            {
                                ID: TASK_ALPHA,
                                Name: 'Alpha Deliverable',
                                Status: 'InProgress',
                                Priority: 'High',
                                ParentID: null,
                                PercentComplete: 60,
                                DueAt: null,
                                StartedAt: null,
                                HoursEstimated: 5,
                                HoursActual: 2,
                                Description: 'Deliverable',
                                BlockedReason: null,
                            },
                        ]);
                    }
                    if (params.EntityName === TASK_FIELD_SUGGESTIONS_ENTITY_NAME) {
                        const fsRows: TaskFieldSuggestionRow[] = [
                            {
                                ID: 'fs-d1',
                                LinkedEntityID: TASKS_ENTITY_ID,
                                LinkedRecordID: TASK_ALPHA,
                                AnchorKey: 'DueAt',
                                SuggestedValue: '"2026-12-20"',
                                Outcome: null,
                                IsResolved: 0,
                            },
                        ];
                        return makeRunViewSuccess(fsRows);
                    }
                    return makeRunViewSuccess([]);
                },
            });

            const dashboard = createWithCdr(() => new TasksDashboardPageComponent());
            dashboard.Provider = provider;
            await dashboard.LoadKPIs();

            expect(dashboard.FieldSuggestionsAvailable).toBe(true);
            expect(dashboard.TotalPendingSuggestionsCount).toBe(1);
            expect(dashboard.GanttExtraFilter).toBeNull();

            dashboard.TogglePendingSuggestions();
            expect(dashboard.OnlyPendingSuggestions).toBe(true);
            expect(dashboard.GanttExtraFilter).toBe(`ID IN ('${TASK_ALPHA}')`);

            const detail = createWithCdr(() => new TaskDetailPanelComponent());
            detail.Provider = provider;
            detail.TaskID = TASK_ALPHA;
            await detail.LoadTask();

            expect(detail.pendingSuggestionSummary?.pendingCount).toBe(1);
            expect(detail.pendingSuggestionTooltip).toBe('1 pending suggestion: DueAt');
        });
    });
});
