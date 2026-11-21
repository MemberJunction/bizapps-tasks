import '@angular/compiler';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { ChangeDetectorRef, Injector, SimpleChange, runInInjectionContext } from '@angular/core';
import type { RunViewParams } from '@memberjunction/core';
import { MJGlobal, UUIDsEqual } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import { BaseResourceComponent } from '@memberjunction/ng-shared';

interface MockEntityMetadata {
    ID: string;
    Name: string;
    Icon: string;
    DisplayNameOrName: string;
}

interface MockTaskListRow {
    ID: string;
    Name: string;
    Description: string | null;
    Status: string;
    Priority: string;
    DueAt: string | null;
    PercentComplete: number | null;
    HoursEstimated: number | null;
    ParentID: string | null;
    TaskTypeStatus: string | null;
}

type MockRunViewRow =
    | TaskTypeOption
    | MockTaskListRow;

interface MockRunViewResult<T = MockRunViewRow> {
    Success: boolean;
    Results: T[];
}

interface MockCollectionItem {
    Save: () => Promise<boolean>;
    AssigneeEntityID?: string;
    AssigneeRecordID?: string;
    Status?: string;
    RoleID?: string | null;
    TagID?: string;
    EntityID?: string;
    RecordID?: string;
    Description?: string | null;
}

interface MockRelatedCollection {
    readonly Items: MockCollectionItem[];
    Load: () => Promise<boolean>;
    Create: () => Promise<MockCollectionItem>;
    Remove: (item: MockCollectionItem) => boolean;
    Clear: () => void;
}

interface TaskEntityStub {
    ID: string;
    Name: string;
    Description: string | null;
    Status: string;
    Priority: string;
    StartedAt: Date | null;
    DueAt: Date | null;
    PercentComplete: number;
    HoursEstimated: number | null;
    HoursActual: number | null;
    BlockedReason: string | null;
    CompletionNotes: string | null;
    TypeID: string;
    TaskTypeStatusID: string | null;
    CategoryID: string | null;
    OrganizationID: string | null;
    ParentID: string | null;
    BaselineValue: number | null;
    TargetValue: number | null;
    CurrentValue: number | null;
    UnitOfMeasure: string | null;
    MetricDirection: string;
    PlanningPeriod: string | null;
    CheckInCadence: string;
    CreatedByPersonID: string | null;
    Sequence: number;
    NewRecord: () => void;
    InnerLoad: () => Promise<boolean>;
    Save: () => Promise<boolean>;
    LatestResult: { CompleteMessage: string };
    Assignments: MockRelatedCollection;
    TagLinks: MockRelatedCollection;
    Links: MockRelatedCollection;
}

interface TaskAssignmentStub {
    NewRecord: () => void;
    Save: () => Promise<boolean>;
    TaskID: string;
    AssigneeEntityID: string;
    AssigneeRecordID: string;
}

interface TaskLinkStub {
    NewRecord: () => void;
    Save: () => Promise<boolean>;
    TaskID: string;
    EntityID: string;
    RecordID: string;
    Description: string;
}

type MockEntityStub = TaskEntityStub | TaskAssignmentStub | TaskLinkStub;

interface CompositeKeyPairStub {
    FieldName: string;
    Value: string;
}

const { runViewMock, getEntityObjectMock, entitiesMock } = vi.hoisted(() => {
    const entities: MockEntityMetadata[] = [
        { ID: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', Name: 'MJ_BizApps_Common: People', Icon: 'fa-solid fa-user', DisplayNameOrName: 'People' },
        { ID: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', Name: 'MJ_BizApps_Tasks: Tasks', Icon: 'fa-solid fa-list-check', DisplayNameOrName: 'Tasks' },
        { ID: 'cccccccc-cccc-4ccc-8ccc-cccccccccccc', Name: 'MJ_BizApps_Common: Organizations', Icon: 'fa-solid fa-building', DisplayNameOrName: 'Organizations' },
    ];
    return {
        runViewMock: vi.fn<[RunViewParams], Promise<MockRunViewResult | undefined>>(),
        getEntityObjectMock: vi.fn<[string], Promise<MockEntityStub>>(),
        entitiesMock: entities,
    };
});

vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    const provider = {
        Entities: entitiesMock,
        Roles: [],
        EntityByName: (name: string) => entitiesMock.find((e) => e.Name === name),
        EntityByID: (id: string) => entitiesMock.find((e) => UUIDsEqual(e.ID, id)),
        GetEntityObject: (entityName: string) => getEntityObjectMock(entityName),
    };
    return {
        ...actual,
        RunView: class {
            static FromMetadataProvider() {
                return new this();
            }
            RunView(params: RunViewParams): Promise<MockRunViewResult | undefined> {
                return runViewMock(params);
            }
        },
        Metadata: Object.assign(
            class {
                Entities = entitiesMock;
                GetEntityObject(entityName: string) {
                    return getEntityObjectMock(entityName);
                }
            },
            { Provider: provider },
        ),
        CompositeKey: class {
            constructor(public KeyValuePairs: CompositeKeyPairStub[]) {}
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
    SelectGenericQuickAddTaskTypeID,
    type TaskTypeRunViewLike,
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

function makeCollection(): MockRelatedCollection {
    const items: MockCollectionItem[] = [];
    return {
        get Items() {
            return items;
        },
        Load: vi.fn(async () => true),
        Create: vi.fn(async () => {
            const child: MockCollectionItem = { Save: vi.fn(async () => true) };
            items.push(child);
            return child;
        }),
        Remove: vi.fn(() => true),
        Clear: vi.fn(() => {
            items.length = 0;
        }),
    };
}

function makeTaskEntityStub(overrides: Partial<TaskEntityStub> = {}): TaskEntityStub {
    return {
        ID: '11111111-1111-4111-8111-111111111111',
        Name: '',
        Description: null,
        Status: 'Open',
        Priority: 'Medium',
        StartedAt: null,
        DueAt: null,
        PercentComplete: 0,
        HoursEstimated: null,
        HoursActual: null,
        BlockedReason: null,
        CompletionNotes: null,
        TypeID: '',
        TaskTypeStatusID: null,
        CategoryID: null,
        OrganizationID: null,
        ParentID: null,
        BaselineValue: null,
        TargetValue: null,
        CurrentValue: null,
        UnitOfMeasure: null,
        MetricDirection: 'Increase',
        PlanningPeriod: null,
        CheckInCadence: 'Weekly',
        CreatedByPersonID: null,
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

function setupDefaultLookupRunView(taskTypes: TaskTypeOption[] = MIXED_TASK_TYPES): void {
    runViewMock.mockImplementation(async (params: RunViewParams): Promise<MockRunViewResult> => {
        if (params.EntityName === 'MJ_BizApps_Tasks: Task Types') {
            return { Success: true, Results: taskTypes };
        }
        return { Success: true, Results: [] };
    });
}

async function initEditPanelViaLifecycle(
    panel: TaskEditPanelComponent,
    previousTaskId: string | null = null,
    expectedTaskName?: string,
): Promise<void> {
    panel.ngOnChanges({
        TaskID: new SimpleChange(previousTaskId, panel.TaskID, previousTaskId === null),
    });
    await vi.waitFor(() => {
        expect(panel.taskTypes.length).toBeGreaterThan(0);
        if (panel.TaskID) {
            expect(panel.isNew).toBe(false);
            expect(panel.loading).toBe(false);
            if (expectedTaskName !== undefined) {
                expect(panel.form.Name).toBe(expectedTaskName);
            }
        } else {
            expect(panel.form.TypeID.length).toBeGreaterThan(0);
        }
    });
}

beforeEach(() => {
    vi.resetAllMocks();
});

describe('Generic Task Type Creation Filtering', () => {
    it('SelectDefaultGenericTaskTypeID, SelectGenericQuickAddTaskTypeID, and ResolveDefaultGenericTaskTypeID exclude PRIORITY, Planning ExtensionEntity, and inactive OKR types and compare UUIDs case-insensitively', async () => {
        expect(SelectDefaultGenericTaskTypeID(MIXED_TASK_TYPES)).toBe(TT_GENERAL_ID);

        const withoutGeneral = MIXED_TASK_TYPES.filter((t) => t.ID !== TT_GENERAL_ID);
        expect(SelectDefaultGenericTaskTypeID(withoutGeneral)).toBe(TT_ACTION_ITEM_ID);

        const planningOnly = MIXED_TASK_TYPES.filter((t) =>
            [TT_PRIORITY_ID, TT_PLANNING_CUSTOM_ID, TT_PRIORITY_OBJECTIVE_ID, TT_KEY_RESULT_ID].includes(t.ID),
        );
        expect(SelectDefaultGenericTaskTypeID(planningOnly)).toBeNull();

        // Explicit valid generic default is retained across differently-cased UUIDs
        expect(SelectGenericQuickAddTaskTypeID(MIXED_TASK_TYPES, TT_DELIVERABLE_ID.toUpperCase())).toBe(TT_DELIVERABLE_ID);
        // Planning-owned or inactive OKR defaults fall back to GENERAL
        expect(SelectGenericQuickAddTaskTypeID(MIXED_TASK_TYPES, TT_PRIORITY_ID.toUpperCase())).toBe(TT_GENERAL_ID);
        expect(SelectGenericQuickAddTaskTypeID(MIXED_TASK_TYPES, TT_PLANNING_CUSTOM_ID)).toBe(TT_GENERAL_ID);
        expect(SelectGenericQuickAddTaskTypeID(MIXED_TASK_TYPES, TT_KEY_RESULT_ID)).toBe(TT_GENERAL_ID);
        expect(SelectGenericQuickAddTaskTypeID(planningOnly, TT_PRIORITY_ID)).toBeNull();

        type TaskTypeLookupRunViewParams = Parameters<TaskTypeRunViewLike['RunView']>[0];
        type TaskTypeLookupRunViewReturn = ReturnType<TaskTypeRunViewLike['RunView']>;
        const taskTypeLookupSpy = vi.fn<[TaskTypeLookupRunViewParams], TaskTypeLookupRunViewReturn>(
            async () => ({ Success: true, Results: MIXED_TASK_TYPES }),
        );
        const runViewDouble: TaskTypeRunViewLike = {
            RunView: (params) => taskTypeLookupSpy(params),
        };
        expect(await ResolveDefaultGenericTaskTypeID(runViewDouble)).toBe(TT_GENERAL_ID);
        expect(await ResolveDefaultGenericTaskTypeID(runViewDouble, TT_DELIVERABLE_ID.toUpperCase())).toBe(TT_DELIVERABLE_ID);
        expect(await ResolveDefaultGenericTaskTypeID(runViewDouble, TT_PRIORITY_ID)).toBe(TT_GENERAL_ID);

        // When RunView returns undefined (e.g. unstubbed unit-test mocks), block known Planning/OKR IDs & codes
        // while permitting non-Planning generic default IDs.
        taskTypeLookupSpy.mockResolvedValue(undefined);
        for (const blockedId of [
            null,
            '',
            TT_PRIORITY_ID,
            TT_PRIORITY_ID.toUpperCase(),
            TT_PRIORITY_OBJECTIVE_ID,
            TT_KEY_RESULT_ID,
            'PRIORITY',
            'PRIORITY_OBJECTIVE',
            'OBJECTIVE',
            'KEY_RESULT',
            'planning-priority-type',
            'okr-key-result',
        ]) {
            expect(await ResolveDefaultGenericTaskTypeID(runViewDouble, blockedId)).toBeNull();
        }
        expect(await ResolveDefaultGenericTaskTypeID(runViewDouble, TT_DELIVERABLE_ID)).toBe(TT_DELIVERABLE_ID);
        expect(await ResolveDefaultGenericTaskTypeID(runViewDouble, '55555555-5555-4555-8555-555555555551')).toBe(
            '55555555-5555-4555-8555-555555555551',
        );
        expect(await ResolveDefaultGenericTaskTypeID(runViewDouble, 'type-1')).toBe('type-1');

        // Fail closed when RunView explicitly returns Success=false
        taskTypeLookupSpy.mockResolvedValue({ Success: false, Results: [] });
        for (const candidateId of [null, TT_PRIORITY_ID, TT_PLANNING_CUSTOM_ID, TT_KEY_RESULT_ID, TT_DELIVERABLE_ID]) {
            expect(await ResolveDefaultGenericTaskTypeID(runViewDouble, candidateId)).toBeNull();
        }
    });

    it('TaskEditPanelComponent hides PRIORITY, external Planning ExtensionEntity, and inactive OKR types in creatableTaskTypes while handling differently-cased UUIDs', async () => {
        setupDefaultLookupRunView();
        const panel = createInContext(() => new TaskEditPanelComponent());
        panel.DefaultTypeID = TT_PRIORITY_ID;

        await initEditPanelViaLifecycle(panel);

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

        // Differently-cased valid generic DefaultTypeID is matched via UUIDsEqual and normalized
        const upperCasePanel = createInContext(() => new TaskEditPanelComponent());
        upperCasePanel.DefaultTypeID = TT_DELIVERABLE_ID.toUpperCase();
        await initEditPanelViaLifecycle(upperCasePanel);
        expect(upperCasePanel.form.TypeID).toBe(TT_DELIVERABLE_ID);
        expect(upperCasePanel.activeTaskType?.Code).toBe('DELIVERABLE');
    });

    it('TaskEditPanelComponent allows viewing/inspecting existing PRIORITY and legacy KEY_RESULT tasks as read-only locked type', async () => {
        setupDefaultLookupRunView();
        const existingPriorityTask = makeTaskEntityStub({
            ID: '22222222-2222-4222-8222-222222222222',
            Name: 'Q4 Revenue Priority',
            TypeID: TT_PRIORITY_ID.toUpperCase(),
            Status: 'InProgress',
            Priority: 'High',
        });
        getEntityObjectMock.mockResolvedValueOnce(existingPriorityTask);

        const panel = createInContext(() => new TaskEditPanelComponent());
        panel.TaskID = existingPriorityTask.ID;
        await initEditPanelViaLifecycle(panel, null, 'Q4 Revenue Priority');

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
        await initEditPanelViaLifecycle(panel, existingPriorityTask.ID, 'Legacy KR');

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
        await initEditPanelViaLifecycle(createPanel);

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

    it('TaskListComponent filters Planning-owned types out of quick-add, quick-capture, and bulkTaskTypeOptions even when QuickAddDefaultTypeID is explicitly set', async () => {
        runViewMock.mockImplementation(async (params: RunViewParams): Promise<MockRunViewResult> => {
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

        // 1. Unset QuickAddDefaultTypeID -> resolves GENERAL
        const quickDefaultTask = makeTaskEntityStub();
        getEntityObjectMock.mockResolvedValueOnce(quickDefaultTask);
        list.QuickAddDefaultTypeID = null;
        list.quickAddName = 'Follow up with finance';
        await list.quickAddTask();
        expect(quickDefaultTask.TypeID).toBe(TT_GENERAL_ID);

        // 2. QuickAddDefaultTypeID set to PRIORITY -> falls back to GENERAL
        const quickPriorityTask = makeTaskEntityStub();
        getEntityObjectMock.mockResolvedValueOnce(quickPriorityTask);
        list.QuickAddDefaultTypeID = TT_PRIORITY_ID;
        list.quickAddName = 'Attempt priority quick-add';
        await list.quickAddTask();
        expect(quickPriorityTask.TypeID).toBe(TT_GENERAL_ID);

        // 3. QuickAddDefaultTypeID set to custom Planning ExtensionEntity -> falls back to GENERAL
        const quickPlanningCustomTask = makeTaskEntityStub();
        getEntityObjectMock.mockResolvedValueOnce(quickPlanningCustomTask);
        list.QuickAddDefaultTypeID = TT_PLANNING_CUSTOM_ID;
        list.quickAddName = 'Attempt custom planning quick-add';
        await list.quickAddTask();
        expect(quickPlanningCustomTask.TypeID).toBe(TT_GENERAL_ID);

        // 4. QuickAddDefaultTypeID set to inactive OKR type -> falls back to GENERAL
        const quickInactiveOkrTask = makeTaskEntityStub();
        getEntityObjectMock.mockResolvedValueOnce(quickInactiveOkrTask);
        list.QuickAddDefaultTypeID = TT_KEY_RESULT_ID;
        list.quickAddName = 'Attempt inactive KR quick-add';
        await list.quickAddTask();
        expect(quickInactiveOkrTask.TypeID).toBe(TT_GENERAL_ID);

        // 5. QuickAddDefaultTypeID set to valid generic type (differently-cased UUID) -> retains DELIVERABLE
        const quickDeliverableTask = makeTaskEntityStub();
        getEntityObjectMock.mockResolvedValueOnce(quickDeliverableTask);
        list.QuickAddDefaultTypeID = TT_DELIVERABLE_ID.toUpperCase();
        list.quickAddName = 'Ship Q4 deliverable';
        await list.quickAddTask();
        expect(quickDeliverableTask.TypeID).toBe(TT_DELIVERABLE_ID);

        // 6. onQuickCaptureSubmit with unset, PRIORITY, custom Planning ExtensionEntity, inactive OKR, and valid generic defaults
        const capturePayloads: Array<{ defaultTypeId: string | null; expectedTypeId: string; title: string }> = [
            { defaultTypeId: null, expectedTypeId: TT_GENERAL_ID, title: 'Review contract' },
            { defaultTypeId: TT_PRIORITY_ID, expectedTypeId: TT_GENERAL_ID, title: 'Capture with PRIORITY default' },
            { defaultTypeId: TT_PLANNING_CUSTOM_ID, expectedTypeId: TT_GENERAL_ID, title: 'Capture with Planning ExtensionEntity default' },
            { defaultTypeId: TT_KEY_RESULT_ID, expectedTypeId: TT_GENERAL_ID, title: 'Capture with inactive KR default' },
            { defaultTypeId: TT_DELIVERABLE_ID.toUpperCase(), expectedTypeId: TT_DELIVERABLE_ID, title: 'Capture with valid Deliverable default' },
        ];

        for (const scenario of capturePayloads) {
            const qcTask = makeTaskEntityStub();
            getEntityObjectMock.mockResolvedValueOnce(qcTask);
            list.QuickAddDefaultTypeID = scenario.defaultTypeId;
            await list.onQuickCaptureSubmit({
                RawText: `${scenario.title} !high`,
                Title: scenario.title,
                Priority: 'High',
                DueAt: null,
                AssigneeQuery: null,
                TagNames: [],
                HoursEstimated: null,
                LinkedRecord: null,
            });
            expect(qcTask.TypeID).toBe(scenario.expectedTypeId);
        }

        // 7. Rejects quickAddTask and onQuickCaptureSubmit cleanly when no eligible generic types exist
        const planningOnlyTypes = MIXED_TASK_TYPES.filter((t) =>
            [TT_PRIORITY_ID, TT_PLANNING_CUSTOM_ID, TT_PRIORITY_OBJECTIVE_ID, TT_KEY_RESULT_ID].includes(t.ID),
        );
        setupDefaultLookupRunView(planningOnlyTypes);
        getEntityObjectMock.mockClear();

        list.QuickAddDefaultTypeID = TT_PRIORITY_ID;
        list.quickAddName = 'Blocked quick-add';
        await list.quickAddTask();
        await list.onQuickCaptureSubmit({
            RawText: 'Blocked quick-capture',
            Title: 'Blocked quick-capture',
            Priority: 'Medium',
            DueAt: null,
            AssigneeQuery: null,
            TagNames: [],
            HoursEstimated: null,
            LinkedRecord: null,
        });
        expect(getEntityObjectMock).not.toHaveBeenCalled();

        // 8. Block Planning/OKR defaults in quickAddTask() and onQuickCaptureSubmit() when RunView returns undefined,
        // while still allowing non-Planning generic default IDs (unstubbed test compatibility).
        runViewMock.mockResolvedValue(undefined);
        getEntityObjectMock.mockClear();
        for (const blockedDefaultId of [null, TT_PRIORITY_ID, TT_PRIORITY_OBJECTIVE_ID, TT_KEY_RESULT_ID, 'PRIORITY', 'OBJECTIVE', 'KEY_RESULT']) {
            list.QuickAddDefaultTypeID = blockedDefaultId;
            list.quickAddName = 'Should abort when Planning/OKR default and lookup is undefined';
            await list.quickAddTask();
            expect(list.quickAdding).toBe(false);
            expect(list.quickAddName).toBe('Should abort when Planning/OKR default and lookup is undefined');

            await list.onQuickCaptureSubmit({
                RawText: 'Should abort capture when Planning/OKR default and lookup is undefined',
                Title: 'Should abort capture when Planning/OKR default and lookup is undefined',
                Priority: 'High',
                DueAt: null,
                AssigneeQuery: null,
                TagNames: [],
                HoursEstimated: null,
                LinkedRecord: null,
            });
            expect(list.quickAdding).toBe(false);
        }
        expect(getEntityObjectMock).not.toHaveBeenCalled();

        const unstubbedGenericTask = makeTaskEntityStub();
        getEntityObjectMock.mockResolvedValueOnce(unstubbedGenericTask);
        list.QuickAddDefaultTypeID = TT_DELIVERABLE_ID;
        list.quickAddName = 'Generic quick add with unstubbed RunView';
        await list.quickAddTask();
        expect(unstubbedGenericTask.TypeID).toBe(TT_DELIVERABLE_ID);
        expect(unstubbedGenericTask.Save).toHaveBeenCalledTimes(1);
    });

    it('MyTasksPageComponent, TasksDashboardPageComponent, and ConnectedTasksHostComponent filter Planning-owned types on create/bulk while preserving task visibility', async () => {
        setupDefaultLookupRunView();

        // MyTasksPageComponent.OnQuickCapture
        const myTasksPage = createInContext(() => new MyTasksPageComponent());
        myTasksPage.PersonID = 'person-1';
        vi.spyOn(myTasksPage, 'LoadMyWork').mockResolvedValue();
        const myQuickTask = makeTaskEntityStub();
        const myAssignment: TaskAssignmentStub = {
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

        // TasksDashboardPageComponent initialized via public RefreshAll()
        const dashboard = createInContext(() => new TasksDashboardPageComponent());
        await dashboard.RefreshAll();
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
        const linkEntity: TaskLinkStub = {
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
