import '@angular/compiler';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { ChangeDetectorRef, Injector, runInInjectionContext } from '@angular/core';
import type {
    EntityInfo,
    IMetadataProvider,
    IRunViewProvider,
    RunViewParams,
    RunViewResult,
    UserInfo,
} from '@memberjunction/core';
import { Metadata } from '@memberjunction/core';
import { UserInfoEngine } from '@memberjunction/core-entities';
import { TASKS_ENGINE_ENTITIES, TasksEngineBase } from '@mj-biz-apps/tasks-core';
import type { TaskWidgetItem } from '@mj-biz-apps/tasks-ng-widgets';
import {
    ProjectFilteredWbsTasks,
    TasksDashboardPageComponent,
    type WbsDashboardFilterCriteria,
} from '../pages/tasks-dashboard.page';
import { MyTasksPageComponent } from '../pages/my-tasks.page';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const ANGULAR_LIB_DIR = join(__dirname, '..');

const PHASE_ID = '11111111-1111-4111-8111-111111111111';
const MILESTONE_ID = '22222222-2222-4222-8222-222222222222';
const CHILD_ID = '33333333-3333-4333-8333-333333333333';
const OTHER_ROOT_ID = '44444444-4444-4444-8444-444444444444';
const TYPE_PHASE_ID = '55555555-5555-4555-8555-555555555551';
const TYPE_MILESTONE_ID = '55555555-5555-4555-8555-555555555552';
const TYPE_GENERAL_ID = '55555555-5555-4555-8555-555555555553';
const CAT_OPS_ID = '66666666-6666-4666-8666-666666666661';
const CAT_ENG_ID = '66666666-6666-4666-8666-666666666662';
const ORG_ACME_ID = '77777777-7777-4777-8777-777777777771';
const PERSON_JORDAN_ID = '88888888-8888-4888-8888-888888888881';
const PEOPLE_ENTITY_ID = '99999999-9999-4999-8999-999999999991';
const ROLES_ENTITY_ID = '99999999-9999-4999-8999-999999999992';
const ROLE_LEAD_ID = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1';

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

function baseFilterCriteria(overrides: Partial<WbsDashboardFilterCriteria> = {}): WbsDashboardFilterCriteria {
    return {
        CategoryID: null,
        SearchText: '',
        Status: null,
        Priority: null,
        TypeID: null,
        Assignee: null,
        DueDate: null,
        OrganizationID: null,
        CurrentPersonID: null,
        CurrentRoleIDs: [],
        OnlyPendingSuggestions: false,
        PendingSuggestionsByTask: new Map(),
        ...overrides,
    };
}

describe('Tasks App WBS Hierarchy Integration (TasksDashboardPageComponent & MyTasksPageComponent)', () => {
    let originalProvider: IMetadataProvider;

    beforeEach(() => {
        originalProvider = Metadata.Provider;
        TasksEngineBase.Instance.ClearUserScopedCaches();
    });

    afterEach(() => {
        Metadata.Provider = originalProvider;
        TasksEngineBase.Instance.ClearUserScopedCaches();
        vi.restoreAllMocks();
    });

    it('puts WBS first in ViewToggleOptions, defaults ViewMode to wbs when unset, and honors persisted UserInfoEngine preference', async () => {
        const getSettingSpy = vi.spyOn(UserInfoEngine.Instance, 'GetSetting').mockReturnValue(undefined);
        const setSettingSpy = vi.spyOn(UserInfoEngine.Instance, 'SetSettingDebounced').mockImplementation(() => {});

        const page = createInInjector(() => new TasksDashboardPageComponent());
        expect(page.ViewToggleOptions.map((o) => o.key)).toEqual(['wbs', 'list', 'kanban', 'gantt']);
        expect(page.ViewToggleOptions[0]).toEqual({
            key: 'wbs',
            icon: 'fa-solid fa-sitemap',
            label: 'WBS',
            title: 'Work Breakdown Structure',
        });
        expect(page.ViewMode).toBe('wbs');

        // Persisted 'kanban' setting is honored on ngOnInit
        getSettingSpy.mockImplementation((key: string) =>
            key === 'mj.tasks.dashboardViewMode.v1' ? 'kanban' : undefined,
        );
        vi.spyOn(page, 'LoadKPIs').mockResolvedValue();
        vi.spyOn(page, 'LoadWbsTasks').mockResolvedValue();
        vi.spyOn(TasksEngineBase.Instance, 'Config').mockResolvedValue();
        vi.spyOn(TasksEngineBase.Instance, 'GetOrLoadAllPeople').mockResolvedValue([]);
        vi.spyOn(TasksEngineBase.Instance, 'GetOrLoadActiveOrganizations').mockResolvedValue([]);
        page.Provider = { Roles: [], Entities: [] } as unknown as IMetadataProvider;

        await page.ngOnInit();
        expect(page.ViewMode).toBe('kanban');

        // Switching back to wbs persists and triggers LoadWbsTasks
        page.onViewToggleChange('wbs');
        expect(page.ViewMode).toBe('wbs');
        expect(setSettingSpy).toHaveBeenCalledWith('mj.tasks.dashboardViewMode.v1', 'wbs');
    });

    it('LoadWbsTasks uses TasksEngineBase + single batched RunViews for Assignments & Dependencies and resolves badges', async () => {
        const batchCalls: string[][] = [];
        const singleCalls: string[] = [];

        const engine = TasksEngineBase.Instance;
        vi.spyOn(engine, 'Config').mockImplementation(async () => {
            const internal = engine as unknown as Record<string, unknown>;
            internal['_taskTypes'] = [
                { ID: TYPE_PHASE_ID, Name: 'Phase', Code: 'PHASE', IsActive: true, ExtensionEntity: null },
                { ID: TYPE_MILESTONE_ID, Name: 'Milestone', Code: 'MILESTONE', IsActive: true, ExtensionEntity: null },
                { ID: TYPE_GENERAL_ID, Name: 'General', Code: 'GENERAL', IsActive: true, ExtensionEntity: null },
            ];
            internal['_taskCategories'] = [
                { ID: CAT_OPS_ID, Name: 'Operations', ParentID: null, IsActive: true, Sequence: 1 },
            ];
            internal['_taskRoles'] = [{ ID: ROLE_LEAD_ID, Name: 'Lead', Sequence: 1 }];
            internal['_taskTypesById'] = null;
            internal['_categoriesById'] = null;
            internal['_rolesById'] = null;
        });
        vi.spyOn(engine, 'GetOrLoadAllPeople').mockResolvedValue([
            { ID: PERSON_JORDAN_ID, FirstName: 'Jordan', LastName: 'Lee', FullName: 'Jordan Lee' },
        ]);
        vi.spyOn(engine, 'GetOrLoadActiveOrganizations').mockResolvedValue([
            { ID: ORG_ACME_ID, Name: 'Acme Corp', LinkedCompanyID: null },
        ]);

        const provider = {
            CurrentUser: { ID: 'user-wbs-1', Email: 'u@example.com' } as UserInfo,
            Roles: [],
            Entities: [],
            EntityByName: (name: string): EntityInfo | undefined => {
                if (name === 'MJ_BizApps_Common: People') {
                    return { ID: PEOPLE_ENTITY_ID, Name: name, GetUserPermisions: () => ({ CanRead: true }) } as unknown as EntityInfo;
                }
                if (name === 'MJ: Roles') {
                    return { ID: ROLES_ENTITY_ID, Name: name, GetUserPermisions: () => ({ CanRead: true }) } as unknown as EntityInfo;
                }
                return { ID: `ent-${name}`, Name: name, GetUserPermisions: () => ({ CanRead: true }) } as unknown as EntityInfo;
            },
            EntityByID: vi.fn(),
            RunView: vi.fn(async (params: RunViewParams): Promise<RunViewResult> => {
                singleCalls.push(params.EntityName ?? '');
                if (params.EntityName === TASKS_ENGINE_ENTITIES.Tasks) {
                    return {
                        Success: true,
                        Results: [
                            {
                                ID: PHASE_ID,
                                Name: 'Phase 1: Foundation',
                                Description: null,
                                Status: 'InProgress',
                                Priority: 'Medium',
                                DueAt: '2026-12-20T00:00:00Z',
                                StartedAt: '2026-12-01T00:00:00Z',
                                PercentComplete: null,
                                HoursEstimated: 40,
                                HoursActual: 10,
                                ParentID: null,
                                TypeID: TYPE_PHASE_ID,
                                Type: 'Phase',
                                CategoryID: CAT_OPS_ID,
                                Category: 'Operations',
                                OrganizationID: ORG_ACME_ID,
                                Organization: 'Acme Corp',
                                TaskTypeStatusID: null,
                                TaskTypeStatus: null,
                                BlockedReason: null,
                                Sequence: 10,
                            },
                            {
                                ID: CHILD_ID,
                                Name: 'Complete Security Audit',
                                Description: 'SOC2 scope',
                                Status: 'Blocked',
                                Priority: 'Critical',
                                DueAt: '2026-12-10T00:00:00Z',
                                StartedAt: '2026-12-02T00:00:00Z',
                                PercentComplete: 30,
                                HoursEstimated: 12,
                                HoursActual: 4,
                                ParentID: PHASE_ID,
                                TypeID: TYPE_GENERAL_ID,
                                Type: 'General',
                                CategoryID: CAT_OPS_ID,
                                Category: 'Operations',
                                OrganizationID: ORG_ACME_ID,
                                Organization: 'Acme Corp',
                                TaskTypeStatusID: null,
                                TaskTypeStatus: 'Security Review',
                                BlockedReason: 'Awaiting pen-test report',
                                Sequence: 20,
                            },
                        ],
                    } as unknown as RunViewResult;
                }
                return { Success: true, Results: [] } as unknown as RunViewResult;
            }),
            RunViews: vi.fn(async (paramsList: RunViewParams[]): Promise<RunViewResult[]> => {
                batchCalls.push(paramsList.map((p) => p.EntityName ?? ''));
                return paramsList.map((p) => {
                    if (p.EntityName === TASKS_ENGINE_ENTITIES.TaskAssignments) {
                        return {
                            Success: true,
                            Results: [
                                {
                                    TaskID: CHILD_ID,
                                    AssigneeEntityID: PEOPLE_ENTITY_ID,
                                    AssigneeRecordID: PERSON_JORDAN_ID,
                                    RoleID: ROLE_LEAD_ID,
                                    Status: 'InProgress',
                                },
                            ],
                        } as unknown as RunViewResult;
                    }
                    if (p.EntityName === TASKS_ENGINE_ENTITIES.TaskDependencies) {
                        return {
                            Success: true,
                            Results: [
                                {
                                    TaskID: CHILD_ID,
                                    DependsOnTaskID: PHASE_ID,
                                    DependencyType: 'FinishToStart',
                                },
                            ],
                        } as unknown as RunViewResult;
                    }
                    return { Success: true, Results: [] } as unknown as RunViewResult;
                });
            }),
        } as unknown as IMetadataProvider & IRunViewProvider;

        const page = createInInjector(() => new TasksDashboardPageComponent());
        page.Provider = provider;
        await page.LoadWbsTasks();

        // Single batched RunViews call for Task Assignments + Task Dependencies
        expect(batchCalls).toHaveLength(1);
        expect(batchCalls[0]).toEqual([
            TASKS_ENGINE_ENTITIES.TaskAssignments,
            TASKS_ENGINE_ENTITIES.TaskDependencies,
        ]);
        expect(singleCalls).toEqual([TASKS_ENGINE_ENTITIES.Tasks]);

        expect(page.WbsAllTasks).toHaveLength(2);
        const phaseItem = page.WbsAllTasks.find((t) => t.ID === PHASE_ID)!;
        const childItem = page.WbsAllTasks.find((t) => t.ID === CHILD_ID)!;
        expect(phaseItem.KindLabel).toBe('Phase');
        expect(phaseItem.DependencyCount).toBe(1);
        expect(childItem.AssigneeNames).toEqual(['Jordan Lee']);
        expect(childItem.DependencyCount).toBe(1);
        expect(page.VisibleTaskIDs).toEqual([PHASE_ID, CHILD_ID]);

        const badges = page.WbsRowBadgeResolver(childItem);
        expect(badges.map((b) => b.Label)).toContain('Critical');
        expect(badges.map((b) => b.Label)).toContain('Security Review');
        expect(badges.map((b) => b.Label)).toContain('Acme Corp');
        expect(badges.map((b) => b.Label)).toContain('1 dep');
    });

    it('ProjectFilteredWbsTasks preserves full WBS ancestor chains across all active dashboard filters', () => {
        const yesterday = new Date(Date.now() - 2 * 86_400_000).toISOString();
        const tasks: TaskWidgetItem[] = [
            {
                ID: PHASE_ID,
                ParentID: null,
                Name: 'Phase 1: Core',
                Status: 'InProgress',
                Priority: 'Medium',
                CategoryID: CAT_ENG_ID,
                TypeID: TYPE_PHASE_ID,
                OrganizationID: null,
                Sequence: 10,
            },
            {
                ID: MILESTONE_ID,
                ParentID: PHASE_ID,
                Name: 'Milestone 1.1: Audit',
                Status: 'InProgress',
                Priority: 'Medium',
                CategoryID: CAT_ENG_ID,
                TypeID: TYPE_MILESTONE_ID,
                OrganizationID: ORG_ACME_ID,
                Sequence: 10,
            },
            {
                ID: CHILD_ID,
                ParentID: MILESTONE_ID,
                Name: 'Rotate API Keys',
                Status: 'Blocked',
                Priority: 'Critical',
                DueAt: yesterday,
                CategoryID: CAT_OPS_ID,
                TypeID: TYPE_GENERAL_ID,
                OrganizationID: ORG_ACME_ID,
                Assignees: [
                    {
                        DisplayName: 'Jordan Lee',
                        RecordID: PERSON_JORDAN_ID,
                        EntityName: 'MJ_BizApps_Common: People',
                        Status: 'InProgress',
                    },
                ],
                AssigneeNames: ['Jordan Lee'],
                Sequence: 10,
            },
            {
                ID: OTHER_ROOT_ID,
                ParentID: null,
                Name: 'Phase 2: Marketing',
                Status: 'Open',
                Priority: 'Low',
                CategoryID: CAT_ENG_ID,
                TypeID: TYPE_PHASE_ID,
                OrganizationID: null,
                Sequence: 20,
            },
        ];

        // Filtering by child-only CategoryID keeps Phase 1 -> Milestone 1.1 -> Child
        expect(ProjectFilteredWbsTasks(tasks, baseFilterCriteria({ CategoryID: CAT_OPS_ID })).map((t) => t.ID)).toEqual([
            PHASE_ID,
            MILESTONE_ID,
            CHILD_ID,
        ]);

        // Filtering by Priority, Status, TypeID, Assignee, DueDate, Organization, SearchText, PendingSuggestions
        expect(ProjectFilteredWbsTasks(tasks, baseFilterCriteria({ Priority: 'Critical' })).map((t) => t.ID)).toEqual([
            PHASE_ID,
            MILESTONE_ID,
            CHILD_ID,
        ]);
        expect(ProjectFilteredWbsTasks(tasks, baseFilterCriteria({ Status: 'Blocked' })).map((t) => t.ID)).toEqual([
            PHASE_ID,
            MILESTONE_ID,
            CHILD_ID,
        ]);
        expect(ProjectFilteredWbsTasks(tasks, baseFilterCriteria({ TypeID: TYPE_GENERAL_ID })).map((t) => t.ID)).toEqual([
            PHASE_ID,
            MILESTONE_ID,
            CHILD_ID,
        ]);
        expect(
            ProjectFilteredWbsTasks(
                tasks,
                baseFilterCriteria({ Assignee: '__me__', CurrentPersonID: PERSON_JORDAN_ID }),
            ).map((t) => t.ID),
        ).toEqual([PHASE_ID, MILESTONE_ID, CHILD_ID]);
        expect(ProjectFilteredWbsTasks(tasks, baseFilterCriteria({ DueDate: 'overdue' })).map((t) => t.ID)).toEqual([
            PHASE_ID,
            MILESTONE_ID,
            CHILD_ID,
        ]);
        expect(ProjectFilteredWbsTasks(tasks, baseFilterCriteria({ SearchText: 'Rotate' })).map((t) => t.ID)).toEqual([
            PHASE_ID,
            MILESTONE_ID,
            CHILD_ID,
        ]);
        expect(
            ProjectFilteredWbsTasks(
                tasks,
                baseFilterCriteria({
                    OnlyPendingSuggestions: true,
                    PendingSuggestionsByTask: new Map([
                        [
                            CHILD_ID.toLowerCase(),
                            {
                                taskId: CHILD_ID,
                                pendingCount: 2,
                                fieldNames: ['DueAt', 'Priority'],
                                topPreviewLabel: 'DueAt: 2026-12-20',
                            },
                        ],
                    ]),
                }),
            ).map((t) => t.ID),
        ).toEqual([PHASE_ID, MILESTONE_ID, CHILD_ID]);
    });

    it('wires WBS task clicks, subtask creation, inline status toggle, and quick-capture into TasksDashboardPageComponent', async () => {
        const mockEntity = {
            ID: CHILD_ID,
            Name: 'Rotate API Keys',
            Status: 'Open',
            Priority: 'Medium',
            PercentComplete: 0,
            TypeID: '',
            CategoryID: null as string | null,
            OrganizationID: null as string | null,
            CreatedByPersonID: null as string | null,
            DueAt: null as Date | null,
            HoursEstimated: null as number | null,
            NewRecord: vi.fn(),
            InnerLoad: vi.fn(async () => true),
            Save: vi.fn(async () => true),
            Assignments: {
                Items: [] as Array<Record<string, unknown>>,
                Create: vi.fn(async () => {
                    const row: Record<string, unknown> = {};
                    mockEntity.Assignments.Items.push(row);
                    return row;
                }),
            },
        };

        const provider = {
            CurrentUser: { ID: 'user-wbs-2', Email: 'u2@example.com' } as UserInfo,
            Roles: [],
            Entities: [],
            EntityByName: (name: string) =>
                name === 'MJ_BizApps_Common: People'
                    ? ({ ID: PEOPLE_ENTITY_ID, Name: name } as unknown as EntityInfo)
                    : undefined,
            GetEntityObject: vi.fn(async () => mockEntity),
        } as unknown as IMetadataProvider;

        const engine = TasksEngineBase.Instance;
        vi.spyOn(engine, 'Config').mockImplementation(async () => {
            const internal = engine as unknown as Record<string, unknown>;
            internal['_taskTypes'] = [
                { ID: TYPE_GENERAL_ID, Name: 'General', Code: 'GENERAL', IsActive: true, ExtensionEntity: null },
            ];
        });

        const page = createInInjector(() => new TasksDashboardPageComponent());
        page.Provider = provider;
        page.PeopleOptions = [{ ID: PERSON_JORDAN_ID, Name: 'Jordan Lee' }];
        page.SelectedCategoryID = CAT_OPS_ID;
        page.WbsAllTasks = [
            { ID: CHILD_ID, ParentID: null, Name: 'Rotate API Keys', Status: 'Open', Priority: 'High', PercentComplete: 0 },
        ];
        const kpiSpy = vi.spyOn(page, 'LoadKPIs').mockResolvedValue();
        const wbsSpy = vi.spyOn(page, 'LoadWbsTasks').mockResolvedValue();

        // 1. Clicking a WBS row opens slide-over detail drawer
        page.SelectTask(CHILD_ID);
        expect(page.PanelMode).toBe('detail');
        expect(page.SelectedTaskID).toBe(CHILD_ID);

        // 2. Requesting subtask creation opens edit drawer pre-scoped to ParentTaskID
        page.OnWbsCreateTaskRequested({ ParentTaskID: PHASE_ID });
        expect(page.PanelMode).toBe('edit');
        expect(page.SelectedTaskID).toBeNull();
        expect(page.DefaultParentTaskID).toBe(PHASE_ID);

        page.ClosePanel();
        expect(page.DefaultParentTaskID).toBeNull();

        // 3. Inline status toggle saves typed properties and refreshes KPIs + WBS
        await page.OnWbsStatusToggled({ TaskID: CHILD_ID, NewStatus: 'Completed' });
        expect(mockEntity.Status).toBe('Completed');
        expect(mockEntity.PercentComplete).toBe(100);
        expect(mockEntity.Save).toHaveBeenCalledTimes(1);
        expect(kpiSpy).toHaveBeenCalledTimes(1);
        expect(wbsSpy).toHaveBeenCalledTimes(1);

        // 4. Inline quick-capture creates task + atomic assignment and refreshes
        await page.OnWbsQuickCapture({
            RawText: 'Draft release checklist @Jordan !high',
            Title: 'Draft release checklist',
            Priority: 'High',
            DueAt: null,
            AssigneeQuery: 'Jordan',
            TagNames: [],
            HoursEstimated: 3,
            LinkedRecord: null,
        });
        expect(mockEntity.NewRecord).toHaveBeenCalledTimes(1);
        expect(mockEntity.Name).toBe('Draft release checklist');
        expect(mockEntity.TypeID).toBe(TYPE_GENERAL_ID);
        expect(mockEntity.CategoryID).toBe(CAT_OPS_ID);
        expect(mockEntity.Priority).toBe('High');
        expect(mockEntity.HoursEstimated).toBe(3);
        expect(mockEntity.Assignments.Items).toHaveLength(1);
        expect(mockEntity.Assignments.Items[0]).toMatchObject({
            AssigneeEntityID: PEOPLE_ENTITY_ID,
            AssigneeRecordID: PERSON_JORDAN_ID,
            Status: 'Pending',
        });

        // 5. Summary strip tile click toggles Status filter cleanly
        page.OnWbsSummaryTileClicked('blocked');
        expect(page.StatusFilterValue).toBe('Blocked');
        page.OnWbsSummaryTileClicked('blocked');
        expect(page.StatusFilterValue).toBeNull();
    });

    it('MyTasksPageComponent supports List | WBS view toggle with UserInfoEngine persistence and ancestor preservation', () => {
        const setSettingSpy = vi.spyOn(UserInfoEngine.Instance, 'SetSettingDebounced').mockImplementation(() => {});

        const page = createInInjector(() => new MyTasksPageComponent());
        expect(page.ViewToggleOptions.map((o) => o.key)).toEqual(['list', 'wbs']);
        expect(page.ViewMode).toBe('list');

        page.OnViewToggleChange('wbs');
        expect(page.ViewMode).toBe('wbs');
        expect(setSettingSpy).toHaveBeenCalledWith('mj.tasks.myTasksViewMode.v1', 'wbs');

        page.AllTasks = [
            { ID: PHASE_ID, ParentID: null, Name: 'Phase 1', Status: 'InProgress', Priority: 'Medium', PercentComplete: 50 },
            { ID: CHILD_ID, ParentID: PHASE_ID, Name: 'Urgent Audit', Status: 'Blocked', Priority: 'Critical', PercentComplete: 10 },
            { ID: OTHER_ROOT_ID, ParentID: null, Name: 'Phase 2', Status: 'Open', Priority: 'Low', PercentComplete: 0 },
        ];
        page.SearchText = 'Audit';
        // Ancestor Phase 1 stays intact above matching child Urgent Audit
        expect(page.WbsTasks.map((t) => t.ID)).toEqual([PHASE_ID, CHILD_ID]);
    });

    it('keeps my-tasks.page.ts compliant with OnPush, --mj-* tokens, and zero raw color literals', () => {
        const source = readFileSync(join(ANGULAR_LIB_DIR, 'pages/my-tasks.page.ts'), 'utf8');
        expect(source).toContain('ChangeDetectionStrategy.OnPush');
        expect(source).not.toMatch(/\blocalStorage\s*[.\[]/);
        expect(source).not.toMatch(/#[0-9a-fA-F]{3,8}\b/);
        expect(source).not.toMatch(/\b(?:rgb|rgba|hsl|hsla)\s*\(/i);
    });
});
