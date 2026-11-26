import '@angular/compiler';
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
import { TASKS_ENGINE_ENTITIES, TasksEngineBase } from '@mj-biz-apps/tasks-core';
import { TaskDetailPanelComponent } from '../components/task-detail-panel/task-detail-panel.component';
import { TaskListComponent } from '../components/task-list/task-list.component';
import { TaskKanbanComponent } from '../components/task-kanban/task-kanban.component';
import { TaskGanttComponent } from '../components/task-gantt/task-gantt.component';

const ROOT_ID = '11111111-1111-4111-8111-111111111111';
const CHILD_ID = '22222222-2222-4222-8222-222222222222';
const TYPE_ID = '33333333-3333-4333-8333-333333333333';
const STATUS_ID = '44444444-4444-4444-8444-444444444444';
const ROLE_ID = '55555555-5555-4555-8555-555555555555';
const PERSON_ID = '66666666-6666-4666-8666-666666666666';
const PEOPLE_ENTITY_ID = '77777777-7777-4777-8777-777777777777';
const ROLES_ENTITY_ID = '88888888-8888-4888-8888-888888888888';

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

describe('Angular components TasksEngineBase wiring & RunViews batching', () => {
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

    it('TaskDetailPanelComponent.LoadTask batches dynamic relations in 1 RunViews call and avoids taxonomy RunViews', async () => {
        const batchCalls: string[][] = [];
        const singleCalls: string[] = [];

        const engine = TasksEngineBase.Instance;
        vi.spyOn(engine, 'Config').mockImplementation(async () => {
            const internal = engine as unknown as Record<string, unknown>;
            internal['_taskTypes'] = [
                {
                    ID: TYPE_ID,
                    Name: 'Deliverable',
                    Code: 'DELIVERABLE',
                    IsActive: true,
                    IsApproval: false,
                    OnCompleteAction: null,
                    OnRejectAction: null,
                    OnCancelAction: null,
                },
            ];
            internal['_taskTypeStatuses'] = [
                {
                    ID: STATUS_ID,
                    TaskTypeID: TYPE_ID,
                    Name: 'In Review',
                    Code: 'REVIEW',
                    Sequence: 10,
                    MacroStatus: 'InProgress',
                    IsDefault: true,
                    IsTerminal: false,
                    IsActive: true,
                    Color: '#2563eb',
                    IconClass: null,
                },
            ];
            internal['_taskRoles'] = [{ ID: ROLE_ID, Name: 'Lead', Sequence: 1 }];
        });

        const provider = {
            CurrentUser: { ID: 'user-1', Email: 'u1@example.com' } as UserInfo,
            Roles: [],
            Entities: [],
            EntityByName: (name: string): EntityInfo | undefined => {
                if (name === 'MJ_BizApps_Common: People') {
                    return { ID: PEOPLE_ENTITY_ID, Name: name, GetUserPermisions: () => ({ CanRead: true }) } as unknown as EntityInfo;
                }
                if (name === 'MJ: Roles') {
                    return { ID: ROLES_ENTITY_ID, Name: name, GetUserPermisions: () => ({ CanRead: true }) } as unknown as EntityInfo;
                }
                if (name === 'MJ: Field Suggestions') return undefined;
                return { ID: `ent-${name}`, Name: name, Icon: 'fa-solid fa-link', GetUserPermisions: () => ({ CanRead: true }) } as unknown as EntityInfo;
            },
            EntityByID: (id: string) => {
                if (id === PEOPLE_ENTITY_ID) return { ID: PEOPLE_ENTITY_ID, Name: 'MJ_BizApps_Common: People', Icon: 'fa-solid fa-user' };
                return undefined;
            },
            GetEntityObject: vi.fn().mockResolvedValue({
                ID: ROOT_ID,
                Name: 'Ship Perf Wave',
                Description: 'Batch all RunViews',
                Status: 'InProgress',
                Priority: 'High',
                TypeID: TYPE_ID,
                Type: 'Deliverable',
                TaskTypeStatusID: STATUS_ID,
                ParentID: null,
                Parent: null,
                OrganizationID: null,
                DueAt: null,
                PercentComplete: 40,
                HoursEstimated: 8,
                HoursActual: 3,
                BlockedReason: null,
                PredictedSLARiskBand: null,
                PredictedSLABreachProbability: null,
                TargetValue: null,
                HealthStatus: null,
                InnerLoad: vi.fn().mockResolvedValue(true),
            }),
            RunView: vi.fn(async (params: RunViewParams): Promise<RunViewResult> => {
                singleCalls.push(params.EntityName ?? '');
                if (params.EntityName === TASKS_ENGINE_ENTITIES.People) {
                    return {
                        Success: true,
                        Results: [{ ID: PERSON_ID, FirstName: 'Ada', LastName: 'Lovelace' }],
                    } as unknown as RunViewResult;
                }
                if (params.EntityName === TASKS_ENGINE_ENTITIES.Organizations) {
                    return { Success: true, Results: [] } as unknown as RunViewResult;
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
                                    ID: 'asgn-1',
                                    AssigneeEntityID: PEOPLE_ENTITY_ID,
                                    AssigneeRecordID: PERSON_ID,
                                    RoleID: ROLE_ID,
                                    Status: 'InProgress',
                                },
                            ],
                        } as unknown as RunViewResult;
                    }
                    if (p.EntityName === 'MJ_BizApps_Tasks: Task Comments') {
                        return {
                            Success: true,
                            Results: [{ __mj_CreatedAt: new Date('2026-11-25T10:00:00Z'), PersonID: PERSON_ID, Content: 'Looks great!' }],
                        } as unknown as RunViewResult;
                    }
                    if (p.EntityName === TASKS_ENGINE_ENTITIES.Tasks) {
                        return {
                            Success: true,
                            Results: [{ ID: CHILD_ID, Name: 'Subtask A', Status: 'Completed', Priority: 'Medium', PercentComplete: 100 }],
                        } as unknown as RunViewResult;
                    }
                    return { Success: true, Results: [] } as unknown as RunViewResult;
                });
            }),
        } as unknown as IMetadataProvider & IRunViewProvider;

        const detail = createInInjector(() => new TaskDetailPanelComponent());
        detail.Provider = provider;
        detail.TaskID = ROOT_ID;
        await detail.LoadTask();

        // 1 batched RunViews call containing all 6 dynamic relations
        expect(batchCalls).toHaveLength(1);
        expect(batchCalls[0]).toEqual([
            'MJ_BizApps_Tasks: Task Assignments',
            'MJ_BizApps_Tasks: Task Activities',
            'MJ_BizApps_Tasks: Task Comments',
            'MJ_BizApps_Tasks: Tasks',
            'MJ_BizApps_Tasks: Task Dependencies',
            'MJ_BizApps_Tasks: Task Links',
        ]);

        // Zero taxonomy RunView queries (served from TasksEngineBase)
        const allQueried = [...singleCalls, ...batchCalls.flat()];
        expect(allQueried).not.toContain(TASKS_ENGINE_ENTITIES.TaskTypes);
        expect(allQueried).not.toContain(TASKS_ENGINE_ENTITIES.TaskTypeStatus);
        expect(allQueried).not.toContain(TASKS_ENGINE_ENTITIES.TaskRoles);

        // People resolved once across both assignees and comments
        expect(singleCalls.filter((e) => e === TASKS_ENGINE_ENTITIES.People)).toHaveLength(1);
        expect(detail.assignees[0]?.DisplayName).toBe('Ada Lovelace');
        expect(detail.assignees[0]?.RoleName).toBe('Lead');
        expect(detail.typeStatuses.map((s) => s.Name)).toEqual(['In Review']);
        expect(detail.subtasks).toHaveLength(1);
        expect(detail.timeline).toHaveLength(1);
        expect(detail.timeline[0]?.PersonName).toBe('Ada Lovelace');
    });

    it('WBS (TaskList), Kanban (TaskKanban), and Gantt (TaskGantt) share 1 cached LoadProjectSubtree bundle', async () => {
        let tasksFetchCount = 0;
        let subtreeBatchCount = 0;

        const engine = TasksEngineBase.Instance;
        vi.spyOn(engine, 'Config').mockResolvedValue(undefined);

        const provider = {
            CurrentUser: { ID: 'user-project-1', Email: 'p1@example.com' } as UserInfo,
            Roles: [],
            Entities: [],
            EntityByName: (name: string): EntityInfo | undefined => {
                if (name === 'MJ: Field Suggestions') return undefined;
                if (name === 'MJ: Roles') {
                    return { ID: ROLES_ENTITY_ID, Name: name, GetUserPermisions: () => ({ CanRead: true }) } as unknown as EntityInfo;
                }
                return { ID: `ent-${name}`, Name: name, GetUserPermisions: () => ({ CanRead: true }) } as unknown as EntityInfo;
            },
            EntityByID: vi.fn(),
            RunView: vi.fn(async (params: RunViewParams): Promise<RunViewResult> => {
                if (params.EntityName === TASKS_ENGINE_ENTITIES.Tasks) {
                    tasksFetchCount += 1;
                    return {
                        Success: true,
                        Results: [
                            { ID: ROOT_ID, Name: 'Project Root', Description: null, Status: 'InProgress', Priority: 'High', StartedAt: '2026-11-01', DueAt: '2026-12-01', PercentComplete: 50, HoursEstimated: 10, ParentID: null, RootParentID: null, TypeID: TYPE_ID, Sequence: 1 },
                            { ID: CHILD_ID, Name: 'Child Task', Description: null, Status: 'Open', Priority: 'Medium', StartedAt: '2026-11-02', DueAt: '2026-11-10', PercentComplete: 0, HoursEstimated: 4, ParentID: ROOT_ID, RootParentID: ROOT_ID, TypeID: TYPE_ID, Sequence: 2 },
                        ],
                    } as unknown as RunViewResult;
                }
                if (params.EntityName === TASKS_ENGINE_ENTITIES.People) {
                    return {
                        Success: true,
                        Results: [{ ID: PERSON_ID, FirstName: 'Grace', LastName: 'Hopper' }],
                    } as unknown as RunViewResult;
                }
                return { Success: true, Results: [] } as unknown as RunViewResult;
            }),
            RunViews: vi.fn(async (paramsList: RunViewParams[]): Promise<RunViewResult[]> => {
                if (
                    paramsList.some((p) => p.EntityName === TASKS_ENGINE_ENTITIES.TaskAssignments) &&
                    paramsList.some((p) => p.EntityName === TASKS_ENGINE_ENTITIES.TaskDependencies)
                ) {
                    subtreeBatchCount += 1;
                }
                return paramsList.map((p) => {
                    if (p.EntityName === TASKS_ENGINE_ENTITIES.TaskAssignments) {
                        return {
                            Success: true,
                            Results: [
                                { ID: 'a-1', TaskID: CHILD_ID, AssigneeEntityID: PEOPLE_ENTITY_ID, AssigneeRecordID: PERSON_ID, RoleID: null, Status: 'Pending' },
                            ],
                        } as unknown as RunViewResult;
                    }
                    if (p.EntityName === TASKS_ENGINE_ENTITIES.TaskDependencies) {
                        return {
                            Success: true,
                            Results: [{ ID: 'd-1', TaskID: CHILD_ID, DependsOnTaskID: ROOT_ID, DependencyType: 'FinishToStart' }],
                        } as unknown as RunViewResult;
                    }
                    return { Success: true, Results: [] } as unknown as RunViewResult;
                });
            }),
        } as unknown as IMetadataProvider & IRunViewProvider;

        // 1. WBS List loads the subtree
        const list = createInInjector(() => new TaskListComponent());
        list.Provider = provider;
        list.ReadOnly = true;
        list.ProjectRootTaskID = ROOT_ID;
        await list.loadTasks();
        expect(list.tasks).toHaveLength(2);
        expect(tasksFetchCount).toBe(1);
        expect(subtreeBatchCount).toBe(1);

        // 2. Switching to Kanban reuses the exact cached subtree (0 additional Tasks/Assignments fetches!)
        const kanban = createInInjector(() => new TaskKanbanComponent());
        kanban.Provider = provider;
        kanban.ParentTaskID = ROOT_ID;
        await kanban.LoadTasks();
        expect(kanban.rawTasks).toHaveLength(2);
        expect(tasksFetchCount).toBe(1);
        expect(subtreeBatchCount).toBe(1);

        // 3. Switching to Gantt ALSO reuses the exact cached subtree (0 additional Tasks/Assignments/Dependencies fetches!)
        const gantt = createInInjector(() => new TaskGanttComponent());
        gantt.Provider = provider;
        gantt.ParentTaskID = ROOT_ID;
        await gantt.LoadData();
        expect(gantt.items).toHaveLength(2);
        expect(gantt.links).toHaveLength(1);
        expect(tasksFetchCount).toBe(1);
        expect(subtreeBatchCount).toBe(1);
    });
});
