import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import type {
    BaseEntity,
    BaseEntityEvent,
    EntityInfo,
    IMetadataProvider,
    IRunViewProvider,
    RunViewParams,
    RunViewResult,
    UserInfo,
} from '@memberjunction/core';
import { Metadata } from '@memberjunction/core';
import {
    TASKS_ENGINE_ENTITIES,
    TasksEngineBase,
} from '../engine/TasksEngineBase.js';

const ROOT_TASK_ID = '11111111-1111-4111-8111-111111111111';
const CHILD_TASK_ID = '22222222-2222-4222-8222-222222222222';
const OTHER_TASK_ID = '33333333-3333-4333-8333-333333333333';
const PERSON_A_ID = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const PERSON_B_ID = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
const PERSON_C_ID = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc';
const TYPE_GENERAL_ID = '44444444-4444-4444-8444-444444444444';
const TYPE_DELIV_ID = '55555555-5555-4555-8555-555555555555';
const STATUS_1_ID = '66666666-6666-4666-8666-666666666666';
const STATUS_2_ID = '77777777-7777-4777-8777-777777777777';
const STATUS_INACTIVE_ID = '88888888-8888-4888-8888-888888888888';
const CAT_ACTIVE_ID = '99999999-9999-4999-8999-999999999999';
const CAT_INACTIVE_ID = '12121212-1212-4121-8121-121212121212';
const ROLE_OWNER_ID = '13131313-1313-4131-8131-131313131313';
const TAG_URGENT_ID = '14141414-1414-4141-8141-141414141414';
const USER_1_ID = 'u1111111-1111-4111-8111-111111111111';
const USER_2_ID = 'u2222222-2222-4222-8222-222222222222';

interface MockProviderOptions {
    userId?: string;
    deniedEntities?: string[];
    runView?: (params: RunViewParams) => Promise<RunViewResult>;
    runViews?: (params: RunViewParams[]) => Promise<RunViewResult[]>;
}

function makeMockProvider(options: MockProviderOptions = {}): IMetadataProvider & IRunViewProvider {
    const denied = new Set((options.deniedEntities ?? []).map((e) => e.toLowerCase()));
    const user: UserInfo | undefined = options.userId
        ? ({ ID: options.userId, Email: `${options.userId}@example.com`, Name: options.userId } as UserInfo)
        : undefined;

    const entityByName = (name: string): EntityInfo | undefined => {
        const lower = name.toLowerCase();
        return {
            ID: `ent-${lower}`,
            Name: name,
            Fields: [],
            PrimaryKeys: [{ Name: 'ID', IsUniqueIdentifier: true }],
            GetUserPermisions: () => ({ CanRead: !denied.has(lower) }),
        } as unknown as EntityInfo;
    };

    const runView = vi.fn(async (params: RunViewParams): Promise<RunViewResult> => {
        if (options.runView) return options.runView(params);
        return { Success: true, Results: [] } as unknown as RunViewResult;
    });

    const runViews = vi.fn(async (paramsList: RunViewParams[]): Promise<RunViewResult[]> => {
        if (options.runViews) return options.runViews(paramsList);
        const results: RunViewResult[] = [];
        for (const p of paramsList) {
            results.push(await runView(p));
        }
        return results;
    });

    return {
        CurrentUser: user,
        Entities: [],
        EntityByName: entityByName,
        EntityByID: vi.fn(),
        GetEntityObject: vi.fn(),
        RunView: runView,
        RunViews: runViews,
    } as unknown as IMetadataProvider & IRunViewProvider;
}

describe('TasksEngineBase', () => {
    let originalMetadataProvider: IMetadataProvider;

    beforeEach(() => {
        originalMetadataProvider = Metadata.Provider;
        TasksEngineBase.Instance.ClearUserScopedCaches();
    });

    afterEach(() => {
        Metadata.Provider = originalMetadataProvider;
        TasksEngineBase.Instance.ClearUserScopedCaches();
        vi.restoreAllMocks();
    });

    it('loads and caches all 5 taxonomy tables with O(1) lookup helpers and CanRead gating', async () => {
        const queriedEntities: string[] = [];
        const provider = makeMockProvider({
            userId: USER_1_ID,
            deniedEntities: [TASKS_ENGINE_ENTITIES.TaskTags],
            runViews: async (paramsList) => {
                return paramsList.map((p) => {
                    queriedEntities.push(p.EntityName ?? '');
                    switch (p.EntityName) {
                        case TASKS_ENGINE_ENTITIES.TaskTypes:
                            return {
                                Success: true,
                                Results: [
                                    { ID: TYPE_GENERAL_ID, Name: 'General', Code: 'GENERAL', IsActive: true },
                                    { ID: TYPE_DELIV_ID, Name: 'Deliverable', Code: 'DELIVERABLE', IsActive: true },
                                ],
                            } as unknown as RunViewResult;
                        case TASKS_ENGINE_ENTITIES.TaskTypeStatus:
                            return {
                                Success: true,
                                Results: [
                                    { ID: STATUS_2_ID, TaskTypeID: TYPE_DELIV_ID, Name: 'Review', Sequence: 20, IsActive: true, MacroStatus: 'InProgress' },
                                    { ID: STATUS_1_ID, TaskTypeID: TYPE_DELIV_ID, Name: 'Draft', Sequence: 10, IsActive: true, MacroStatus: 'Open' },
                                    { ID: STATUS_INACTIVE_ID, TaskTypeID: TYPE_DELIV_ID, Name: 'Archived', Sequence: 30, IsActive: false, MacroStatus: 'Cancelled' },
                                ],
                            } as unknown as RunViewResult;
                        case TASKS_ENGINE_ENTITIES.TaskCategories:
                            return {
                                Success: true,
                                Results: [
                                    { ID: CAT_ACTIVE_ID, Name: 'Engineering', Sequence: 10, IsActive: true },
                                    { ID: CAT_INACTIVE_ID, Name: 'Retired', Sequence: 20, IsActive: false },
                                ],
                            } as unknown as RunViewResult;
                        case TASKS_ENGINE_ENTITIES.TaskRoles:
                            return {
                                Success: true,
                                Results: [{ ID: ROLE_OWNER_ID, Name: 'Owner', Sequence: 1 }],
                            } as unknown as RunViewResult;
                        default:
                            return { Success: true, Results: [] } as unknown as RunViewResult;
                    }
                });
            },
        });

        // Stub Load so we verify exact BaseEnginePropertyConfigs passed (CacheLocal, AutoRefresh, CanRead gating)
        const engine = TasksEngineBase.Instance;
        const loadSpy = vi.spyOn(engine as unknown as { Load: Function }, 'Load').mockImplementation(
            async (configs: Array<{ PropertyName: string; EntityName: string; CacheLocal: boolean; AutoRefresh: boolean }>) => {
                // Verify all passed taxonomy configs are CacheLocal: true and AutoRefresh: true
                for (const cfg of configs) {
                    expect(cfg.CacheLocal).toBe(true);
                    expect(cfg.AutoRefresh).toBe(true);
                }
                const results = await provider.RunViews(
                    configs.map((c) => ({ EntityName: c.EntityName })),
                );
                configs.forEach((c, idx) => {
                    (engine as unknown as Record<string, unknown>)[c.PropertyName] = results[idx]?.Results ?? [];
                });
                await (engine as unknown as { AdditionalLoading: () => Promise<void> }).AdditionalLoading();
            },
        );

        await engine.Config(true, provider.CurrentUser, provider);

        expect(loadSpy).toHaveBeenCalledTimes(1);
        // TaskTags was denied by CanRead so it must NOT have been queried
        expect(queriedEntities).not.toContain(TASKS_ENGINE_ENTITIES.TaskTags);
        expect(queriedEntities).toContain(TASKS_ENGINE_ENTITIES.TaskTypes);
        expect(queriedEntities).toContain(TASKS_ENGINE_ENTITIES.TaskTypeStatus);
        expect(queriedEntities).toContain(TASKS_ENGINE_ENTITIES.TaskCategories);
        expect(queriedEntities).toContain(TASKS_ENGINE_ENTITIES.TaskRoles);

        expect(engine.TaskTypeById(TYPE_GENERAL_ID.toUpperCase())?.Code).toBe('GENERAL');
        expect(engine.TaskTypeByCode('deliverable')?.ID).toBe(TYPE_DELIV_ID);
        expect(engine.StatusesForType(TYPE_DELIV_ID).map((s) => s.Name)).toEqual(['Draft', 'Review']);
        expect(engine.StatusesForType(TYPE_DELIV_ID, false).map((s) => s.Name)).toEqual(['Draft', 'Review', 'Archived']);
        expect(engine.ActiveCategories.map((c) => c.ID)).toEqual([CAT_ACTIVE_ID]);
        expect(engine.TaskRoleById(ROLE_OWNER_ID)?.Name).toBe('Owner');
        expect(engine.TaskTags).toEqual([]);
    });

    it('follows live Metadata.Provider when Config() omits provider and never latches to stale bootstrap provider', async () => {
        const providerA = makeMockProvider({ userId: USER_1_ID });
        const providerB = makeMockProvider({ userId: USER_2_ID });

        const engine = TasksEngineBase.Instance;
        vi.spyOn(engine as unknown as { Load: Function }, 'Load').mockResolvedValue(undefined);

        await engine.Config(true, providerA.CurrentUser, providerA);
        expect(engine.ProviderToUse).toBe(providerA);

        Metadata.Provider = providerB;
        await engine.Config(false);
        expect(engine.ProviderToUse).toBe(providerB);
    });

    it('GetOrLoadPeopleByIds caches incrementally and only queries unseen PersonIDs, resetting on user switch', async () => {
        const queriedFilters: string[] = [];
        const provider1 = makeMockProvider({
            userId: USER_1_ID,
            runView: async (params) => {
                queriedFilters.push(params.ExtraFilter ?? '');
                const all = [
                    { ID: PERSON_A_ID, FirstName: 'Ada', LastName: 'Lovelace' },
                    { ID: PERSON_B_ID, FirstName: 'Grace', LastName: 'Hopper' },
                    { ID: PERSON_C_ID, FirstName: 'Alan', LastName: 'Turing' },
                ];
                const filter = (params.ExtraFilter ?? '').toLowerCase();
                return {
                    Success: true,
                    Results: all.filter((p) => filter.includes(p.ID.toLowerCase())),
                } as unknown as RunViewResult;
            },
        });

        const engine = TasksEngineBase.Instance;
        const first = await engine.GetOrLoadPeopleByIds([PERSON_A_ID, PERSON_B_ID, PERSON_A_ID.toUpperCase()], provider1);
        expect(first.size).toBe(2);
        expect(first.get(PERSON_A_ID)?.FullName).toBe('Ada Lovelace');
        expect(queriedFilters).toHaveLength(1);

        // Second call with A (cached) + C (unseen): must ONLY query C!
        const second = await engine.GetOrLoadPeopleByIds([PERSON_A_ID, PERSON_C_ID], provider1);
        expect(second.size).toBe(2);
        expect(second.get(PERSON_C_ID)?.FullName).toBe('Alan Turing');
        expect(queriedFilters).toHaveLength(2);
        expect(queriedFilters[1].toLowerCase()).toContain(PERSON_C_ID);
        expect(queriedFilters[1].toLowerCase()).not.toContain(PERSON_A_ID);

        // Third call with all cached IDs: 0 queries!
        const third = await engine.GetOrLoadPeopleByIds([PERSON_A_ID, PERSON_B_ID, PERSON_C_ID], provider1);
        expect(third.size).toBe(3);
        expect(queriedFilters).toHaveLength(2);

        // Switch user (impersonation): cache must auto-clear and re-query
        const provider2 = makeMockProvider({
            userId: USER_2_ID,
            runView: async (params) => {
                queriedFilters.push(`user2:${params.ExtraFilter ?? ''}`);
                return {
                    Success: true,
                    Results: [{ ID: PERSON_A_ID, FirstName: 'Ada', LastName: 'Lovelace' }],
                } as unknown as RunViewResult;
            },
        });
        const afterSwitch = await engine.GetOrLoadPeopleByIds([PERSON_A_ID], provider2);
        expect(afterSwitch.size).toBe(1);
        expect(queriedFilters).toHaveLength(3);
        expect(queriedFilters[2]).toContain('user2:');
    });

    it('LoadProjectSubtree caches by rootTaskId, batches Assignments + Dependencies via RunViews, and invalidates on BaseEntity events & user switch', async () => {
        let taskQueries = 0;
        let batchQueries = 0;

        const makeSubtreeProvider = (userId: string) =>
            makeMockProvider({
                userId,
                runView: async (params) => {
                    if (params.EntityName === TASKS_ENGINE_ENTITIES.Tasks) {
                        taskQueries += 1;
                        return {
                            Success: true,
                            Results: [
                                { ID: ROOT_TASK_ID, Name: 'Project Alpha', Status: 'InProgress', Priority: 'High', ParentID: null, RootParentID: null, TypeID: TYPE_DELIV_ID, Sequence: 1, PercentComplete: 50, Description: null, StartedAt: null, DueAt: null, HoursEstimated: null },
                                { ID: CHILD_TASK_ID, Name: 'Milestone 1', Status: 'Open', Priority: 'Medium', ParentID: ROOT_TASK_ID, RootParentID: ROOT_TASK_ID, TypeID: TYPE_GENERAL_ID, Sequence: 2, PercentComplete: 0, Description: null, StartedAt: null, DueAt: null, HoursEstimated: null },
                            ],
                        } as unknown as RunViewResult;
                    }
                    return { Success: true, Results: [] } as unknown as RunViewResult;
                },
                runViews: async (paramsList) => {
                    batchQueries += 1;
                    return paramsList.map((p) => {
                        if (p.EntityName === TASKS_ENGINE_ENTITIES.TaskAssignments) {
                            return {
                                Success: true,
                                Results: [
                                    { ID: 'a1', TaskID: CHILD_TASK_ID, AssigneeEntityID: 'ent-people', AssigneeRecordID: PERSON_A_ID, RoleID: ROLE_OWNER_ID, Status: 'InProgress' },
                                ],
                            } as unknown as RunViewResult;
                        }
                        if (p.EntityName === TASKS_ENGINE_ENTITIES.TaskDependencies) {
                            return {
                                Success: true,
                                Results: [
                                    { ID: 'd1', TaskID: CHILD_TASK_ID, DependsOnTaskID: ROOT_TASK_ID, DependencyType: 'FinishToStart' },
                                ],
                            } as unknown as RunViewResult;
                        }
                        return { Success: true, Results: [] } as unknown as RunViewResult;
                    });
                },
            });

        const engine = TasksEngineBase.Instance;
        const provider1 = makeSubtreeProvider(USER_1_ID);

        // First load (e.g., WBS view): 1 Tasks query + 1 batched RunViews([Assignments, Dependencies])
        const bundle1 = await engine.LoadProjectSubtree(ROOT_TASK_ID, { provider: provider1 });
        expect(bundle1.Tasks).toHaveLength(2);
        expect(bundle1.Assignments).toHaveLength(1);
        expect(bundle1.Dependencies).toHaveLength(1);
        expect(taskQueries).toBe(1);
        expect(batchQueries).toBe(1);

        // Second load (e.g., switching to Kanban or Gantt with uppercase UUID): 100% cache hit!
        const bundle2 = await engine.LoadProjectSubtree(ROOT_TASK_ID.toUpperCase(), { provider: provider1 });
        expect(bundle2).toBe(bundle1);
        expect(taskQueries).toBe(1);
        expect(batchQueries).toBe(1);

        // BaseEntity save event on a Task Assignment in this subtree invalidates ONLY this subtree
        const assignmentEvent: BaseEntityEvent = {
            type: 'save',
            baseEntity: {
                EntityInfo: { Name: TASKS_ENGINE_ENTITIES.TaskAssignments },
                TaskID: CHILD_TASK_ID,
            } as unknown as BaseEntity,
        };
        await (engine as unknown as { HandleIndividualBaseEntityEvent: (e: BaseEntityEvent) => Promise<boolean> })
            .HandleIndividualBaseEntityEvent(assignmentEvent);

        const bundle3 = await engine.LoadProjectSubtree(ROOT_TASK_ID, { provider: provider1 });
        expect(bundle3).not.toBe(bundle1);
        expect(taskQueries).toBe(2);
        expect(batchQueries).toBe(2);

        // Explicit InvalidateProjectSubtree drops the cache
        engine.InvalidateProjectSubtree(ROOT_TASK_ID);
        await engine.LoadProjectSubtree(ROOT_TASK_ID, { provider: provider1 });
        expect(taskQueries).toBe(3);

        // Switching user clears the cache automatically
        const provider2 = makeSubtreeProvider(USER_2_ID);
        await engine.LoadProjectSubtree(ROOT_TASK_ID, { provider: provider2 });
        expect(taskQueries).toBe(4);
    });

    it('rejects non-UUID rootTaskId in LoadProjectSubtree to prevent SQL injection', async () => {
        const provider = makeMockProvider({ userId: USER_1_ID });
        await expect(
            TasksEngineBase.Instance.LoadProjectSubtree("'; DROP TABLE Tasks; --", { provider }),
        ).rejects.toThrow(/not a valid ID/i);
    });

    it('rebuilds O(1) taxonomy indexes when a taxonomy BaseEntity save event fires', async () => {
        const engine = TasksEngineBase.Instance;
        const internal = engine as unknown as {
            _taskTags: Array<{ ID: string; Name: string }>;
            HandleIndividualBaseEntityEvent: (e: BaseEntityEvent) => Promise<boolean>;
        };
        internal._taskTags = [{ ID: TAG_URGENT_ID, Name: 'Urgent' }];
        expect(engine.TaskTagByName('urgent')?.ID).toBe(TAG_URGENT_ID);

        // Mutate backing array + dispatch BaseEntity save event (simulating BaseEngine immediate mutation)
        internal._taskTags.push({ ID: OTHER_TASK_ID, Name: 'Backend' });
        await internal.HandleIndividualBaseEntityEvent({
            type: 'save',
            baseEntity: {
                EntityInfo: { Name: TASKS_ENGINE_ENTITIES.TaskTags },
            } as unknown as BaseEntity,
        });

        expect(engine.TaskTagByName('backend')?.ID).toBe(OTHER_TASK_ID);
    });
});
