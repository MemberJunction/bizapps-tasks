import '@angular/compiler';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { ChangeDetectorRef, Injector, SimpleChange, runInInjectionContext } from '@angular/core';
import { MJGlobal } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import { BaseResourceComponent } from '@memberjunction/ng-shared';

const { runViewMock, getEntityObjectMock, entitiesMock } = vi.hoisted(() => ({
    runViewMock: vi.fn(),
    getEntityObjectMock: vi.fn(),
    entitiesMock: [
        { ID: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', Name: 'MJ_BizApps_Common: People', Icon: 'fa-solid fa-user', DisplayNameOrName: 'People' },
        { ID: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', Name: 'MJ_BizApps_Tasks: Tasks', Icon: 'fa-solid fa-list-check', DisplayNameOrName: 'Tasks' },
        { ID: 'cccccccc-cccc-4ccc-8ccc-cccccccccccc', Name: 'MJ_BizApps_Common: Organizations', Icon: 'fa-solid fa-building', DisplayNameOrName: 'Organizations' },
    ],
}));

vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    const provider = {
        Entities: entitiesMock,
        Roles: [],
        EntityByName: (name: string) => entitiesMock.find((e) => e.Name === name),
        EntityByID: (id: string) => entitiesMock.find((e) => e.ID.toLowerCase() === id.toLowerCase()),
        GetEntityObject: (...args: unknown[]) => getEntityObjectMock(...args),
    };
    return {
        ...actual,
        RunView: class {
            static FromMetadataProvider() {
                return new this();
            }
            RunView(...args: unknown[]) {
                return runViewMock(...args);
            }
        },
        Metadata: Object.assign(
            class {
                Entities = entitiesMock;
                GetEntityObject(...args: unknown[]) {
                    return getEntityObjectMock(...args);
                }
            },
            { Provider: provider },
        ),
        CompositeKey: class {
            constructor(public KeyValuePairs: unknown[]) {}
            static FromID(id: string) {
                return new this([{ FieldName: 'ID', Value: id }]);
            }
        },
    };
});

import '../generated/generated-forms.module';
import { mjBizAppsTasksTaskFormComponent } from '../generated/Entities/mjBizAppsTasksTask/mjbizappstaskstask.form.component';
import { mjBizAppsTasksTaskTypeFormComponent } from '../generated/Entities/mjBizAppsTasksTaskType/mjbizappstaskstasktype.form.component';
import { mjBizAppsTasksTaskCheckInFormComponent } from '../generated/Entities/mjBizAppsTasksTaskCheckIn/mjbizappstaskstaskcheckin.form.component';
import '../sections/tasks-sections.component';
import '../sections/meetings-sections.component';
import { LoadBizAppsTasksClient } from '../tasks.module';
import { TaskEditPanelComponent, type TaskTypeOption } from '../components/task-edit-panel/task-edit-panel.component';
import { TaskListComponent } from '../components/task-list/task-list.component';
import { ConnectedTasksHostComponent } from '../components/connected-tasks-host/connected-tasks-host.component';
import { MyTasksPageComponent } from '../pages/my-tasks.page';
import { TasksDashboardPageComponent } from '../pages/tasks-dashboard.page';
import {
    ResolveDefaultGenericTaskTypeID,
    SelectDefaultGenericTaskTypeID,
} from '../task-type-filter.helper';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const ANGULAR_LIB_DIR = join(__dirname, '..');
const REPO_ROOT = join(ANGULAR_LIB_DIR, '../../../..');

const TT_PRIORITY_ID = '7e100001-0000-0000-0000-000000000001';
const TT_PLANNING_CUSTOM_ID = '7e100001-0000-0000-0000-000000000099';
const TT_PRIORITY_OBJECTIVE_ID = '8d42a1b9-3e71-4c5a-9f20-1b6e8d3a9c01';
const TT_KEY_RESULT_ID = '8d42a1b9-3e71-4c5a-9f20-1b6e8d3a9c02';
const TT_GENERAL_ID = 'f7c1e8de-8dac-4bf8-943e-3d5a1210be82';
const TT_ACTION_ITEM_ID = 'ea525de3-b4a9-471c-ad13-1881e2055121';
const TT_DELIVERABLE_ID = '3f002eba-0f6a-4433-bd98-83bc5982e916';
const TT_APPROVAL_ID = '5961ede5-b996-4083-be48-64634b4d8d1c';
const TT_AGENT_ID = '665697fe-9b18-4691-b40c-be849fe60216';

const MIXED_TASK_TYPES: TaskTypeOption[] = [
    {
        ID: TT_PRIORITY_ID,
        Name: 'Priority',
        Code: 'PRIORITY',
        IconClass: 'fa-solid fa-bullseye',
        DefaultPriority: 'High',
        IsApproval: false,
        OnCompleteAction: null,
        OnRejectAction: null,
        OnCancelAction: null,
        ExtensionEntity: 'MJ_BizApps_Planning: Priority Tasks',
        IsActive: true,
    },
    {
        ID: TT_PLANNING_CUSTOM_ID,
        Name: 'Strategic Initiative',
        Code: 'STRATEGIC_INITIATIVE',
        IconClass: 'fa-solid fa-compass',
        DefaultPriority: 'High',
        IsApproval: false,
        OnCompleteAction: null,
        OnRejectAction: null,
        OnCancelAction: null,
        ExtensionEntity: 'MJ_BizApps_Planning: Strategic Initiatives',
        IsActive: true,
    },
    {
        ID: TT_PRIORITY_OBJECTIVE_ID,
        Name: 'Priority Objective',
        Code: 'PRIORITY_OBJECTIVE',
        IconClass: 'fa-solid fa-bullseye',
        DefaultPriority: 'High',
        IsApproval: false,
        OnCompleteAction: null,
        OnRejectAction: null,
        OnCancelAction: null,
        ExtensionEntity: null,
        IsActive: false,
    },
    {
        ID: TT_KEY_RESULT_ID,
        Name: 'Key Result',
        Code: 'KEY_RESULT',
        IconClass: 'fa-solid fa-chart-line',
        DefaultPriority: 'High',
        IsApproval: false,
        OnCompleteAction: null,
        OnRejectAction: null,
        OnCancelAction: null,
        ExtensionEntity: null,
        IsActive: false,
    },
    {
        ID: TT_GENERAL_ID,
        Name: 'General',
        Code: 'GENERAL',
        IconClass: 'fa-solid fa-circle-check',
        DefaultPriority: 'Medium',
        IsApproval: false,
        OnCompleteAction: null,
        OnRejectAction: null,
        OnCancelAction: null,
        ExtensionEntity: null,
        IsActive: true,
    },
    {
        ID: TT_ACTION_ITEM_ID,
        Name: 'Action Item',
        Code: 'ACTION_ITEM',
        IconClass: 'fa-solid fa-bolt',
        DefaultPriority: 'Medium',
        IsApproval: false,
        OnCompleteAction: null,
        OnRejectAction: null,
        OnCancelAction: null,
        ExtensionEntity: null,
        IsActive: true,
    },
    {
        ID: TT_DELIVERABLE_ID,
        Name: 'Deliverable',
        Code: 'DELIVERABLE',
        IconClass: 'fa-solid fa-file-export',
        DefaultPriority: 'High',
        IsApproval: false,
        OnCompleteAction: null,
        OnRejectAction: null,
        OnCancelAction: null,
        ExtensionEntity: null,
        IsActive: true,
    },
    {
        ID: TT_APPROVAL_ID,
        Name: 'Approval Request',
        Code: 'APPROVAL_REQUEST',
        IconClass: 'fa-solid fa-stamp',
        DefaultPriority: 'High',
        IsApproval: true,
        OnCompleteAction: null,
        OnRejectAction: null,
        OnCancelAction: null,
        ExtensionEntity: null,
        IsActive: true,
    },
    {
        ID: TT_AGENT_ID,
        Name: 'Agent Task',
        Code: 'AGENT_TASK',
        IconClass: 'fa-solid fa-robot',
        DefaultPriority: 'Medium',
        IsApproval: false,
        OnCompleteAction: null,
        OnRejectAction: null,
        OnCancelAction: null,
        ExtensionEntity: null,
        IsActive: true,
    },
];

function createCdr(): ChangeDetectorRef {
    return {
        markForCheck: vi.fn(),
        detach: vi.fn(),
        detectChanges: vi.fn(),
        checkNoChanges: vi.fn(),
        reattach: vi.fn(),
    };
}

function createInContext<T>(factory: () => T): T {
    const injector = Injector.create({
        providers: [{ provide: ChangeDetectorRef, useValue: createCdr() }],
    });
    return runInInjectionContext(injector, factory);
}

function makeCollection() {
    const items: Record<string, unknown>[] = [];
    return {
        get Items() {
            return items;
        },
        Load: vi.fn(async () => true),
        Create: vi.fn(async () => {
            const child: Record<string, unknown> = { Save: vi.fn(async () => true) };
            items.push(child);
            return child;
        }),
        Remove: vi.fn(() => true),
        Clear: vi.fn(() => {
            items.length = 0;
        }),
    };
}

function makeTaskEntityStub(overrides: Record<string, unknown> = {}) {
    return {
        ID: '11111111-1111-4111-8111-111111111111',
        Name: '',
        Description: null as string | null,
        Status: 'Open',
        Priority: 'Medium',
        StartedAt: null as Date | null,
        DueAt: null as Date | null,
        PercentComplete: 0,
        HoursEstimated: null as number | null,
        HoursActual: null as number | null,
        BlockedReason: null as string | null,
        CompletionNotes: null as string | null,
        TypeID: '',
        TaskTypeStatusID: null as string | null,
        CategoryID: null as string | null,
        OrganizationID: null as string | null,
        ParentID: null as string | null,
        BaselineValue: null as number | null,
        TargetValue: null as number | null,
        CurrentValue: null as number | null,
        UnitOfMeasure: null as string | null,
        MetricDirection: 'Increase',
        PlanningPeriod: null as string | null,
        CheckInCadence: 'Weekly',
        CreatedByPersonID: null as string | null,
        Sequence: 0,
        NewRecord: vi.fn(),
        InnerLoad: vi.fn(async () => true),
        Save: vi.fn(async () => true),
        LatestResult: { CompleteMessage: '' },
        Assignments: makeCollection(),
        TagLinks: makeCollection(),
        Links: makeCollection(),
        ...overrides,
    };
}

function setupDefaultLookupRunView(taskTypes: TaskTypeOption[] = MIXED_TASK_TYPES) {
    runViewMock.mockImplementation(async (params: { EntityName: string }) => {
        if (params.EntityName === 'MJ_BizApps_Tasks: Task Types') {
            return { Success: true, Results: taskTypes };
        }
        return { Success: true, Results: [] };
    });
}

beforeEach(() => {
    vi.resetAllMocks();
});

describe('Generic Task Type Creation Filtering', () => {
    it('SelectDefaultGenericTaskTypeID and ResolveDefaultGenericTaskTypeID exclude PRIORITY, Planning ExtensionEntity, and inactive OKR types', async () => {
        expect(SelectDefaultGenericTaskTypeID(MIXED_TASK_TYPES)).toBe(TT_GENERAL_ID);

        const withoutGeneral = MIXED_TASK_TYPES.filter((t) => t.ID !== TT_GENERAL_ID);
        expect(SelectDefaultGenericTaskTypeID(withoutGeneral)).toBe(TT_ACTION_ITEM_ID);

        const planningOnly = MIXED_TASK_TYPES.filter((t) =>
            [TT_PRIORITY_ID, TT_PLANNING_CUSTOM_ID, TT_PRIORITY_OBJECTIVE_ID, TT_KEY_RESULT_ID].includes(t.ID),
        );
        expect(SelectDefaultGenericTaskTypeID(planningOnly)).toBeNull();

        setupDefaultLookupRunView(MIXED_TASK_TYPES);
        const resolved = await ResolveDefaultGenericTaskTypeID({
            RunView: (p: unknown) => runViewMock(p),
        } as never);
        expect(resolved).toBe(TT_GENERAL_ID);
    });

    it('TaskEditPanelComponent hides PRIORITY, external Planning ExtensionEntity, and inactive OKR types in creatableTaskTypes while keeping generic types selectable', async () => {
        setupDefaultLookupRunView();
        const panel = createInContext(() => new TaskEditPanelComponent());
        panel.DefaultTypeID = TT_PRIORITY_ID;

        await (panel as unknown as { init: () => Promise<void> }).init();

        const creatableCodes = panel.creatableTaskTypes.map((t) => t.Code);
        expect(creatableCodes).toEqual([
            'GENERAL',
            'ACTION_ITEM',
            'DELIVERABLE',
            'APPROVAL_REQUEST',
            'AGENT_TASK',
        ]);
        expect(creatableCodes).not.toContain('PRIORITY');
        expect(creatableCodes).not.toContain('STRATEGIC_INITIATIVE');
        expect(creatableCodes).not.toContain('PRIORITY_OBJECTIVE');
        expect(creatableCodes).not.toContain('KEY_RESULT');

        // Refuses Planning-owned DefaultTypeID on create and falls back to GENERAL
        expect(panel.form.TypeID).toBe(TT_GENERAL_ID);
        expect(panel.isCurrentTypeLocked).toBe(false);

        // Attempting to select a Planning-owned type while creating is ignored
        panel.selectTaskType(MIXED_TASK_TYPES[0]);
        expect(panel.form.TypeID).toBe(TT_GENERAL_ID);

        // Selecting a valid generic type succeeds
        panel.selectTaskType(MIXED_TASK_TYPES.find((t) => t.Code === 'DELIVERABLE')!);
        expect(panel.form.TypeID).toBe(TT_DELIVERABLE_ID);
        expect(panel.form.Priority).toBe('High');
    });

    it('TaskEditPanelComponent allows viewing/inspecting existing PRIORITY and legacy KEY_RESULT tasks as read-only locked type', async () => {
        setupDefaultLookupRunView();
        const existingPriorityTask = makeTaskEntityStub({
            ID: '22222222-2222-4222-8222-222222222222',
            Name: 'Q4 Revenue Priority',
            TypeID: TT_PRIORITY_ID,
            Status: 'InProgress',
            Priority: 'High',
        });
        getEntityObjectMock.mockResolvedValueOnce(existingPriorityTask);

        const panel = createInContext(() => new TaskEditPanelComponent());
        panel.TaskID = existingPriorityTask.ID;
        await (panel as unknown as { init: () => Promise<void> }).init();

        expect(panel.isNew).toBe(false);
        expect(panel.activeTaskType?.Code).toBe('PRIORITY');
        expect(panel.isCurrentTypeLocked).toBe(true);
        expect(panel.currentTypeOwnershipNote).toBe('Managed in Planning');
        expect(panel.creatableTaskTypes.some((t) => t.Code === 'PRIORITY')).toBe(false);

        // Existing legacy KEY_RESULT task still opens and resolves key-result archetype
        const existingLegacyKr = makeTaskEntityStub({
            ID: '33333333-3333-4333-8333-333333333333',
            Name: 'Legacy KR',
            TypeID: TT_KEY_RESULT_ID,
            TargetValue: 100,
        });
        getEntityObjectMock.mockResolvedValueOnce(existingLegacyKr);
        panel.TaskID = existingLegacyKr.ID;
        await (panel as unknown as { init: () => Promise<void> }).init();

        expect(panel.activeTaskType?.Code).toBe('KEY_RESULT');
        expect(panel.ActiveArchetype).toBe('key-result');
        expect(panel.isCurrentTypeLocked).toBe(true);
        expect(panel.currentTypeOwnershipNote).toBe('Legacy OKR type (read-only)');
    });

    it('TaskEditPanelComponent persists generic measurable task metrics on save and restores them on reopen', async () => {
        setupDefaultLookupRunView();
        const persistedStore = makeTaskEntityStub({
            ID: '44444444-4444-4444-8444-444444444444',
        });
        getEntityObjectMock.mockResolvedValueOnce(persistedStore);

        const createPanel = createInContext(() => new TaskEditPanelComponent());
        await (createPanel as unknown as { init: () => Promise<void> }).init();

        const deliverable = createPanel.creatableTaskTypes.find((t) => t.Code === 'DELIVERABLE')!;
        createPanel.selectTaskType(deliverable);
        createPanel.form.Name = 'Reduce Onboarding Cycle Time';
        createPanel.trackMetrics = true;
        createPanel.form.BaselineValue = 14;
        createPanel.form.CurrentValue = 9;
        createPanel.form.TargetValue = 5;
        createPanel.form.UnitOfMeasure = 'days';
        createPanel.form.MetricDirection = 'Decrease';
        createPanel.form.PlanningPeriod = 'Q4 2026';
        createPanel.form.CheckInCadence = 'Weekly';

        await createPanel.save();

        expect(persistedStore.TypeID).toBe(TT_DELIVERABLE_ID);
        expect(persistedStore.BaselineValue).toBe(14);
        expect(persistedStore.CurrentValue).toBe(9);
        expect(persistedStore.TargetValue).toBe(5);
        expect(persistedStore.UnitOfMeasure).toBe('days');
        expect(persistedStore.MetricDirection).toBe('Decrease');
        expect(persistedStore.PlanningPeriod).toBe('Q4 2026');
        expect(persistedStore.CheckInCadence).toBe('Weekly');
        expect(persistedStore.Save).toHaveBeenCalledTimes(1);

        // Reopen the saved measurable task and verify type + metrics restore
        getEntityObjectMock.mockResolvedValueOnce(persistedStore);
        const reopenPanel = createInContext(() => new TaskEditPanelComponent());
        reopenPanel.TaskID = persistedStore.ID;
        reopenPanel.ngOnChanges({
            TaskID: new SimpleChange(null, persistedStore.ID, true),
        });
        await vi.waitFor(() => {
            expect(reopenPanel.form.Name).toBe('Reduce Onboarding Cycle Time');
        });

        expect(reopenPanel.form.TypeID).toBe(TT_DELIVERABLE_ID);
        expect(reopenPanel.trackMetrics).toBe(true);
        expect(reopenPanel.form.BaselineValue).toBe(14);
        expect(reopenPanel.form.CurrentValue).toBe(9);
        expect(reopenPanel.form.TargetValue).toBe(5);
        expect(reopenPanel.form.UnitOfMeasure).toBe('days');
        expect(reopenPanel.form.MetricDirection).toBe('Decrease');
        expect(reopenPanel.form.PlanningPeriod).toBe('Q4 2026');
    });

    it('TaskListComponent filters Planning-owned types out of quick-add and bulkTaskTypeOptions while displaying all existing tasks', async () => {
        runViewMock.mockImplementation(async (params: { EntityName: string }) => {
            if (params.EntityName === 'MJ_BizApps_Tasks: Task Types') {
                return { Success: true, Results: MIXED_TASK_TYPES };
            }
            if (params.EntityName === 'MJ_BizApps_Tasks: Tasks') {
                return {
                    Success: true,
                    Results: [
                        {
                            ID: 'task-priority-1',
                            Name: 'Existing Priority Task',
                            Description: null,
                            Status: 'InProgress',
                            Priority: 'High',
                            DueAt: null,
                            PercentComplete: 50,
                            HoursEstimated: null,
                            ParentID: null,
                            TaskTypeStatus: null,
                        },
                    ],
                };
            }
            return { Success: true, Results: [] };
        });

        const list = createInContext(() => new TaskListComponent());
        await list.loadTasks();

        expect(list.tasks).toHaveLength(1);
        expect(list.tasks[0].ID).toBe('task-priority-1');

        const bulkLabels = list.bulkTaskTypeOptions.map((o) => o.Label);
        expect(bulkLabels).toContain('General');
        expect(bulkLabels).toContain('Deliverable');
        expect(bulkLabels).not.toContain('Priority');
        expect(bulkLabels).not.toContain('Strategic Initiative');
        expect(bulkLabels).not.toContain('Priority Objective');
        expect(bulkLabels).not.toContain('Key Result');

        // Quick-add ignores PRIORITY and selects GENERAL
        const quickTask = makeTaskEntityStub();
        getEntityObjectMock.mockResolvedValueOnce(quickTask);
        list.quickAddName = 'Follow up with finance';
        await list.quickAddTask();
        expect(quickTask.TypeID).toBe(TT_GENERAL_ID);

        // Natural-language quick-capture also selects GENERAL
        const qcTask = makeTaskEntityStub();
        getEntityObjectMock.mockResolvedValueOnce(qcTask);
        await list.onQuickCaptureSubmit({
            RawText: 'Review contract !high',
            Title: 'Review contract',
            Priority: 'High',
            DueAt: null,
            AssigneeQuery: null,
            TagNames: [],
            HoursEstimated: null,
            LinkedRecord: null,
        });
        expect(qcTask.TypeID).toBe(TT_GENERAL_ID);
    });

    it('MyTasksPageComponent, TasksDashboardPageComponent, and ConnectedTasksHostComponent filter Planning-owned types on create/bulk while preserving task visibility', async () => {
        setupDefaultLookupRunView();

        // MyTasksPageComponent.OnQuickCapture
        const myTasksPage = createInContext(() => new MyTasksPageComponent());
        myTasksPage.PersonID = 'person-1';
        vi.spyOn(myTasksPage, 'LoadMyWork').mockResolvedValue();
        const myQuickTask = makeTaskEntityStub();
        const myAssignment = {
            NewRecord: vi.fn(),
            Save: vi.fn(async () => true),
            TaskID: '',
            AssigneeEntityID: '',
            AssigneeRecordID: '',
        };
        getEntityObjectMock.mockResolvedValueOnce(myQuickTask).mockResolvedValueOnce(myAssignment);

        await myTasksPage.OnQuickCapture({
            RawText: 'Draft memo',
            Title: 'Draft memo',
            Priority: 'Medium',
            DueAt: null,
            AssigneeQuery: null,
            TagNames: [],
            HoursEstimated: null,
            LinkedRecord: null,
        });
        expect(myQuickTask.TypeID).toBe(TT_GENERAL_ID);

        // TasksDashboardPageComponent.LoadCategoriesAndTypes
        const dashboard = createInContext(() => new TasksDashboardPageComponent());
        await (dashboard as unknown as { LoadCategoriesAndTypes: () => Promise<void> }).LoadCategoriesAndTypes();
        const dashBulkLabels = dashboard.BulkTaskTypeOptions.map((o) => o.Label);
        expect(dashBulkLabels).toContain('General');
        expect(dashBulkLabels).not.toContain('Priority');
        expect(dashBulkLabels).not.toContain('Strategic Initiative');
        expect(dashBulkLabels).not.toContain('Key Result');

        // ConnectedTasksHostComponent.onQuickAdd
        const connectedHost = createInContext(() => new ConnectedTasksHostComponent());
        connectedHost.EntityName = 'MJ_BizApps_Common: Organizations';
        connectedHost.RecordID = 'org-1';
        vi.spyOn(connectedHost, 'Refresh').mockResolvedValue();
        const connectedTask = makeTaskEntityStub();
        const linkEntity = {
            NewRecord: vi.fn(),
            Save: vi.fn(async () => true),
            TaskID: '',
            EntityID: '',
            RecordID: '',
            Description: '',
        };
        getEntityObjectMock.mockResolvedValueOnce(connectedTask).mockResolvedValueOnce(linkEntity);

        await connectedHost.onQuickAdd({
            RawText: 'Schedule onboarding',
            Title: 'Schedule onboarding',
            Priority: 'Medium',
            DueAt: null,
            AssigneeQuery: null,
            TagNames: [],
            HoursEstimated: null,
            LinkedRecord: null,
        });
        expect(connectedTask.TypeID).toBe(TT_GENERAL_ID);
    });
});

describe('OpenApp v3 Registration, Navigation Parity & CSS Token Hygiene', () => {
    it('retains @RegisterClass(BaseFormComponent) registrations and BaseResourceComponent navigation parity', () => {
        LoadBizAppsTasksClient();

        expect(mjBizAppsTasksTaskFormComponent).toBeDefined();
        expect(mjBizAppsTasksTaskTypeFormComponent).toBeDefined();
        expect(mjBizAppsTasksTaskCheckInFormComponent).toBeDefined();

        expect(
            MJGlobal.Instance.ClassFactory.GetRegistration(BaseFormComponent, 'MJ_BizApps_Tasks: Tasks'),
        ).toBeDefined();
        expect(
            MJGlobal.Instance.ClassFactory.GetRegistration(BaseFormComponent, 'MJ_BizApps_Tasks: Task Types'),
        ).toBeDefined();
        expect(
            MJGlobal.Instance.ClassFactory.GetRegistration(BaseFormComponent, 'MJ_BizApps_Tasks: Task Check Ins'),
        ).toBeDefined();

        const tasksAppRaw = readFileSync(
            join(REPO_ROOT, 'metadata/applications/.tasks-application.json'),
            'utf8',
        );
        const meetingsAppRaw = readFileSync(
            join(REPO_ROOT, 'metadata/applications/.meetings-application.json'),
            'utf8',
        );
        const tasksApp = JSON.parse(tasksAppRaw) as Array<{ fields: { DefaultNavItems: Array<{ DriverClass: string }> } }>;
        const meetingsApp = JSON.parse(meetingsAppRaw) as Array<{ fields: { DefaultNavItems: Array<{ DriverClass: string }> } }>;
        const driverClasses = [
            ...tasksApp[0].fields.DefaultNavItems.map((n) => n.DriverClass),
            ...meetingsApp[0].fields.DefaultNavItems.map((n) => n.DriverClass),
        ];

        for (const driver of driverClasses) {
            expect(
                MJGlobal.Instance.ClassFactory.GetRegistration(BaseResourceComponent, driver),
                `Missing BaseResourceComponent registration for ${driver}`,
            ).toBeDefined();
        }
    });

    it('uses semantic --mj-* CSS tokens without raw hex/rgb/hsl literals or window.print/localStorage in edited components', () => {
        const filesToCheck = [
            'components/task-edit-panel/task-edit-panel.component.ts',
            'components/task-list/task-list.component.ts',
            'components/connected-tasks-host/connected-tasks-host.component.ts',
            'pages/my-tasks.page.ts',
            'pages/tasks-dashboard.page.ts',
        ];

        for (const relPath of filesToCheck) {
            const source = readFileSync(join(ANGULAR_LIB_DIR, relPath), 'utf8');
            expect(source).toContain('ChangeDetectionStrategy.OnPush');
            expect(source).not.toMatch(/\bwindow\.print\s*\(/);
            expect(source).not.toMatch(/\blocalStorage\s*[.\[]/);

            const stylesMatch = source.match(/styles:\s*\[`([\s\S]*?)`\]/);
            if (stylesMatch) {
                const css = stylesMatch[1];
                expect(css, `Raw #hex literal in ${relPath}`).not.toMatch(/#[0-9a-fA-F]{3,8}\b/);
                expect(css, `Raw rgb/rgba/hsl literal in ${relPath}`).not.toMatch(/\b(?:rgb|rgba|hsl|hsla)\s*\(/i);
            }
        }
    });
});
