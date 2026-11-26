import {
    BaseEngine,
    type BaseEnginePropertyConfig,
    type BaseEntityEvent,
    type IMetadataProvider,
    type IRunViewProvider,
    Metadata,
    RegisterForStartup,
    RunView,
    type RunViewParams,
    type RunViewResult,
    type UserInfo,
} from '@memberjunction/core';
import { IsValidUUID, UUIDsEqual } from '@memberjunction/global';
import type {
    mjBizAppsTasksTaskAssignmentEntity,
    mjBizAppsTasksTaskCategoryEntity,
    mjBizAppsTasksTaskDependencyEntity,
    mjBizAppsTasksTaskEntity,
    mjBizAppsTasksTaskRoleEntity,
    mjBizAppsTasksTaskTagEntity,
    mjBizAppsTasksTaskTypeEntity,
    mjBizAppsTasksTaskTypeStatusEntity,
} from '@mj-biz-apps/tasks-entities';
import { TasksLimitsResolver } from '../config/TasksLimits.js';
import { GuidLiteral } from '../services/sql-guards.js';

/** Canonical entity names managed or read by {@link TasksEngineBase}. */
export const TASKS_ENGINE_ENTITIES = {
    TaskTypes: 'MJ_BizApps_Tasks: Task Types',
    TaskTypeStatus: 'MJ_BizApps_Tasks: Task Type Status',
    TaskCategories: 'MJ_BizApps_Tasks: Task Categories',
    TaskRoles: 'MJ_BizApps_Tasks: Task Roles',
    TaskTags: 'MJ_BizApps_Tasks: Task Tags',
    Tasks: 'MJ_BizApps_Tasks: Tasks',
    TaskAssignments: 'MJ_BizApps_Tasks: Task Assignments',
    TaskDependencies: 'MJ_BizApps_Tasks: Task Dependencies',
    People: 'MJ_BizApps_Common: People',
    Organizations: 'MJ_BizApps_Common: Organizations',
} as const;

const TAXONOMY_ENTITY_NAMES_LOWER: ReadonlySet<string> = new Set([
    TASKS_ENGINE_ENTITIES.TaskTypes.toLowerCase(),
    TASKS_ENGINE_ENTITIES.TaskTypeStatus.toLowerCase(),
    TASKS_ENGINE_ENTITIES.TaskCategories.toLowerCase(),
    TASKS_ENGINE_ENTITIES.TaskRoles.toLowerCase(),
    TASKS_ENGINE_ENTITIES.TaskTags.toLowerCase(),
]);

/** Lightweight cached Person projection returned by {@link TasksEngineBase.GetOrLoadPeopleByIds}. */
export interface TasksDirectoryPerson {
    ID: string;
    FirstName: string;
    LastName: string;
    FullName: string;
}

/** Lightweight cached Organization projection returned by {@link TasksEngineBase.GetOrLoadActiveOrganizations}. */
export interface TasksDirectoryOrganization {
    ID: string;
    Name: string;
    LinkedCompanyID: string | null;
}

/** Lightweight task row stored in a cached {@link ProjectSubtreeBundle}. */
export interface ProjectSubtreeTaskRow {
    ID: string;
    Name: string;
    Description: string | null;
    Status: mjBizAppsTasksTaskEntity['Status'];
    Priority: mjBizAppsTasksTaskEntity['Priority'];
    StartedAt: string | null;
    DueAt: string | null;
    PercentComplete: number;
    HoursEstimated: number | null;
    LoggedMinutes?: number | null;
    ParentID: string | null;
    RootParentID?: string | null;
    TypeID: string;
    Type?: string | null;
    TaskTypeStatusID?: string | null;
    TaskTypeStatus?: string | null;
    CategoryID?: string | null;
    Category?: string | null;
    OrganizationID?: string | null;
    Organization?: string | null;
    Sequence: number;
}

/** Lightweight assignment row stored in a cached {@link ProjectSubtreeBundle}. */
export interface ProjectSubtreeAssignmentRow {
    ID: string;
    TaskID: string;
    AssigneeEntityID: string;
    AssigneeRecordID: string;
    RoleID: string | null;
    Status: mjBizAppsTasksTaskAssignmentEntity['Status'];
}

/** Lightweight dependency row stored in a cached {@link ProjectSubtreeBundle}. */
export interface ProjectSubtreeDependencyRow {
    ID: string;
    TaskID: string;
    DependsOnTaskID: string;
    DependencyType: mjBizAppsTasksTaskDependencyEntity['DependencyType'];
}

/**
 * Bounded container bundle for a project root task and all of its descendants,
 * assignments, and dependencies (modeled on MJ's `ConversationEngine` container cache).
 */
export interface ProjectSubtreeBundle {
    RootTaskID: string;
    LoadedAt: number;
    Tasks: readonly ProjectSubtreeTaskRow[];
    Assignments: readonly ProjectSubtreeAssignmentRow[];
    Dependencies: readonly ProjectSubtreeDependencyRow[];
}

/** Options accepted by {@link TasksEngineBase.LoadProjectSubtree}. */
export interface LoadProjectSubtreeOptions {
    /** Bypass any cached subtree bundle and re-fetch from the provider. */
    forceRefresh?: boolean;
    /** Include `Status = 'Cancelled'` tasks in the subtree bundle (default `false`). */
    includeCancelled?: boolean;
    /** Optional explicit metadata/RunView provider (defaults to {@link TasksEngineBase.ProviderToUse}). */
    provider?: IMetadataProvider | null;
    /** Optional acting user for server-side / impersonated calls. */
    contextUser?: UserInfo;
}

interface PeopleQueryRow {
    ID: string;
    FirstName: string | null;
    LastName: string | null;
}

interface OrganizationQueryRow {
    ID: string;
    Name: string;
    LinkedCompanyID: string | null;
}

interface SubtreeTaskEventShape {
    ID?: string | null;
    ParentID?: string | null;
    RootParentID?: string | null;
}

interface SubtreeChildEventShape {
    TaskID?: string | null;
    DependsOnTaskID?: string | null;
}

interface ProviderUserScopedCache {
    epoch: number;
    userId: string;
    peopleById: Map<string, TasksDirectoryPerson>;
    missingPersonIds: Set<string>;
    allPeopleLoaded: boolean;
    allPeopleList: TasksDirectoryPerson[];
    organizationsById: Map<string, TasksDirectoryOrganization>;
    missingOrganizationIds: Set<string>;
    activeOrganizationsLoaded: boolean;
    activeOrganizationsList: TasksDirectoryOrganization[];
    subtreesByKey: Map<string, ProjectSubtreeBundle>;
    inFlightSubtrees: Map<string, Promise<ProjectSubtreeBundle>>;
}

function normalizeId(value: string | null | undefined): string {
    return (value ?? '').trim().toLowerCase();
}

function normalizeCode(value: string | null | undefined): string {
    return (value ?? '').trim().toUpperCase();
}

function sortOrganizations(rows: readonly OrganizationQueryRow[]): TasksDirectoryOrganization[] {
    return [...rows]
        .map((row) => ({
            ID: row.ID,
            Name: row.Name,
            LinkedCompanyID: row.LinkedCompanyID ?? null,
        }))
        .sort((a, b) => {
            if (Boolean(a.LinkedCompanyID) !== Boolean(b.LinkedCompanyID)) {
                return a.LinkedCompanyID ? -1 : 1;
            }
            return a.Name.localeCompare(b.Name);
        });
}

function toDirectoryPerson(row: PeopleQueryRow): TasksDirectoryPerson {
    const first = (row.FirstName ?? '').trim();
    const last = (row.LastName ?? '').trim();
    return {
        ID: row.ID,
        FirstName: first,
        LastName: last,
        FullName: `${first} ${last}`.trim(),
    };
}

function chunkIds(ids: readonly string[], chunkSize: number): string[][] {
    if (ids.length === 0) return [];
    const step = Math.max(1, chunkSize);
    const chunks: string[][] = [];
    for (let i = 0; i < ids.length; i += step) {
        chunks.push(ids.slice(i, i + step));
    }
    return chunks;
}

function buildGuidInClause(columnName: string, ids: readonly string[]): string {
    const literals = ids.map((id) => GuidLiteral(id, columnName));
    return `${columnName} IN (${literals.join(',')})`;
}

/**
 * Browser-safe metadata and bounded subtree engine for BizApps Tasks.
 *
 * Follows the 5-Rule BizApps Performance & Caching Standard:
 * 1. **Tier 1 Taxonomy Caching** (`BaseEngine` + `BaseSingleton`, `AutoRefresh: true`, `CacheLocal: true`
 *    on global non-RLS tables): caches `Task Types`, `Task Type Status`, `Task Categories`, `Task Roles`,
 *    and `Task Tags` with O(1) lookup helpers rebuilt on reload and auto-refresh.
 * 2. **Impersonation & Multi-Provider Safety**: overrides {@link ProviderToUse} so the engine follows
 *    the active provider passed to {@link Config} or live `Metadata.Provider` instead of latching
 *    permanently to a bootstrap provider, gates every entity load on `CanRead`, and automatically clears
 *    user-scoped caches when the active user ID changes.
 * 3. **Incremental Directory Helpers**: {@link GetOrLoadPeopleByIds}, {@link GetOrLoadAllPeople}, and
 *    {@link GetOrLoadActiveOrganizations} cache resolved rows per provider/user and query only unseen IDs.
 * 4. **Tier 3 Bounded Project Subtree Cache**: {@link LoadProjectSubtree} caches `[Tasks, Task Assignments,
 *    Task Dependencies]` keyed strictly by normalized `rootTaskId` (never arbitrary `ExtraFilter` SQL lists)
 *    with `BaseEntity` event invalidation, explicit {@link InvalidateProjectSubtree}, and user-switch reset,
 *    using two-step RLS-safe entity `RunView` / batched `rv.RunViews([...])` calls with zero raw SQL subqueries.
 */
@RegisterForStartup()
export class TasksEngineBase extends BaseEngine<TasksEngineBase> {
    private _taskTypes: mjBizAppsTasksTaskTypeEntity[] = [];
    private _taskTypeStatuses: mjBizAppsTasksTaskTypeStatusEntity[] = [];
    private _taskCategories: mjBizAppsTasksTaskCategoryEntity[] = [];
    private _taskRoles: mjBizAppsTasksTaskRoleEntity[] = [];
    private _taskTags: mjBizAppsTasksTaskTagEntity[] = [];

    // O(1) memoized taxonomy indexes — cleared on reload and BaseEntity auto-refresh mutations
    private _taskTypesById: Map<string, mjBizAppsTasksTaskTypeEntity> | null = null;
    private _taskTypesByCode: Map<string, mjBizAppsTasksTaskTypeEntity> | null = null;
    private _statusesById: Map<string, mjBizAppsTasksTaskTypeStatusEntity> | null = null;
    private _statusesByTypeAll: Map<string, mjBizAppsTasksTaskTypeStatusEntity[]> | null = null;
    private _statusesByTypeActive: Map<string, mjBizAppsTasksTaskTypeStatusEntity[]> | null = null;
    private _categoriesById: Map<string, mjBizAppsTasksTaskCategoryEntity> | null = null;
    private _rolesById: Map<string, mjBizAppsTasksTaskRoleEntity> | null = null;
    private _tagsById: Map<string, mjBizAppsTasksTaskTagEntity> | null = null;
    private _tagsByName: Map<string, mjBizAppsTasksTaskTagEntity> | null = null;

    // Multi-provider / impersonation state
    private _explicitProvider: IMetadataProvider | null = null;
    private _lastLoadedProvider: IMetadataProvider | null = null;
    private _lastActiveUserId = '';

    // Per-provider, per-user scoped caches (People, Organizations, Project Subtrees)
    private _providerUserCaches = new WeakMap<IMetadataProvider, ProviderUserScopedCache>();
    private _lastActiveCache: ProviderUserScopedCache | null = null;
    private _userCacheEpoch = 0;

    protected constructor() {
        super();
    }

    public static get Instance(): TasksEngineBase {
        return super.getInstance<TasksEngineBase>();
    }

    /**
     * Follows the explicit provider passed to the latest {@link Config} call, or falls back
     * dynamically to the live `Metadata.Provider` so persona switches / impersonation never
     * stay pinned to a stale bootstrap provider.
     */
    public override get ProviderToUse(): IMetadataProvider {
        return this._explicitProvider ?? Metadata.Provider ?? super.ProviderToUse;
    }

    /**
     * Loads and caches all readable BizApps Tasks taxonomy tables in a single batched `BaseEngine` pass.
     *
     * Each of the 5 global non-RLS taxonomy entities (`Task Types`, `Task Type Status`,
     * `Task Categories`, `Task Roles`, `Task Tags`) is gated individually on `CanRead` so
     * restricted roles still benefit from caching the entities they are permitted to read
     * without triggering permission errors on denied entities.
     */
    public async Config(
        forceRefresh?: boolean,
        contextUser?: UserInfo,
        provider?: IMetadataProvider,
    ): Promise<void> {
        this._explicitProvider = provider ?? null;
        const activeProvider = provider ?? Metadata.Provider;
        const effectiveUser = contextUser ?? activeProvider?.CurrentUser;
        const nextUserId = normalizeId(effectiveUser?.ID);

        const userChanged = this._lastActiveUserId !== '' && nextUserId !== this._lastActiveUserId;
        const providerChanged = this._lastLoadedProvider !== null && activeProvider !== this._lastLoadedProvider;

        if (userChanged) {
            this.ClearUserScopedCaches();
        }
        this._lastActiveUserId = nextUserId;
        this._lastLoadedProvider = activeProvider ?? null;

        const candidateConfigs: ReadonlyArray<{
            entityName: string;
            reset: () => void;
            config: Partial<BaseEnginePropertyConfig>;
        }> = [
            {
                entityName: TASKS_ENGINE_ENTITIES.TaskTypes,
                reset: () => {
                    this._taskTypes = [];
                },
                config: {
                    PropertyName: '_taskTypes',
                    EntityName: TASKS_ENGINE_ENTITIES.TaskTypes,
                    AutoRefresh: true,
                    CacheLocal: true,
                    OrderBy: 'Name ASC',
                },
            },
            {
                entityName: TASKS_ENGINE_ENTITIES.TaskTypeStatus,
                reset: () => {
                    this._taskTypeStatuses = [];
                },
                config: {
                    PropertyName: '_taskTypeStatuses',
                    EntityName: TASKS_ENGINE_ENTITIES.TaskTypeStatus,
                    AutoRefresh: true,
                    CacheLocal: true,
                    OrderBy: 'Sequence ASC',
                },
            },
            {
                entityName: TASKS_ENGINE_ENTITIES.TaskCategories,
                reset: () => {
                    this._taskCategories = [];
                },
                config: {
                    PropertyName: '_taskCategories',
                    EntityName: TASKS_ENGINE_ENTITIES.TaskCategories,
                    AutoRefresh: true,
                    CacheLocal: true,
                    OrderBy: 'Sequence ASC, Name ASC',
                },
            },
            {
                entityName: TASKS_ENGINE_ENTITIES.TaskRoles,
                reset: () => {
                    this._taskRoles = [];
                },
                config: {
                    PropertyName: '_taskRoles',
                    EntityName: TASKS_ENGINE_ENTITIES.TaskRoles,
                    AutoRefresh: true,
                    CacheLocal: true,
                    OrderBy: 'Sequence ASC',
                },
            },
            {
                entityName: TASKS_ENGINE_ENTITIES.TaskTags,
                reset: () => {
                    this._taskTags = [];
                },
                config: {
                    PropertyName: '_taskTags',
                    EntityName: TASKS_ENGINE_ENTITIES.TaskTags,
                    AutoRefresh: true,
                    CacheLocal: true,
                    OrderBy: 'Name ASC',
                },
            },
        ];

        const readableConfigs: Partial<BaseEnginePropertyConfig>[] = [];
        for (const item of candidateConfigs) {
            if (this.CanReadEntity(item.entityName, activeProvider, effectiveUser)) {
                readableConfigs.push(item.config);
            } else {
                item.reset();
            }
        }

        const effectiveForceRefresh = Boolean(forceRefresh) || (this.Loaded && (userChanged || providerChanged));
        await this.Load(readableConfigs, activeProvider, effectiveForceRefresh, contextUser);
    }

    protected override async AdditionalLoading(_contextUser?: UserInfo): Promise<void> {
        this.resetTaxonomyIndexes();
    }

    protected override async HandleIndividualBaseEntityEvent(event: BaseEntityEvent): Promise<boolean> {
        const entityNameLower = (event.baseEntity?.EntityInfo?.Name ?? '').trim().toLowerCase();

        if (entityNameLower && TAXONOMY_ENTITY_NAMES_LOWER.has(entityNameLower)) {
            this.resetTaxonomyIndexes();
            const handled = await super.HandleIndividualBaseEntityEvent(event);
            this.resetTaxonomyIndexes();
            return handled;
        }

        if (
            event.type === 'save' ||
            event.type === 'delete' ||
            event.type === 'remote-invalidate'
        ) {
            if (entityNameLower === TASKS_ENGINE_ENTITIES.Tasks.toLowerCase()) {
                this.invalidateSubtreesForTaskEvent(event);
            } else if (
                entityNameLower === TASKS_ENGINE_ENTITIES.TaskAssignments.toLowerCase() ||
                entityNameLower === TASKS_ENGINE_ENTITIES.TaskDependencies.toLowerCase()
            ) {
                this.invalidateSubtreesForTaskChildEvent(event);
            } else if (entityNameLower === TASKS_ENGINE_ENTITIES.People.toLowerCase()) {
                this.InvalidatePeopleCache();
            } else if (entityNameLower === TASKS_ENGINE_ENTITIES.Organizations.toLowerCase()) {
                this.InvalidateOrganizationsCache();
            }
        }

        return await super.HandleIndividualBaseEntityEvent(event);
    }

    // ─── Permission Helper ────────────────────────────────────────────────────

    /**
     * Checks `EntityInfo.GetUserPermisions(user).CanRead` for `entityName` against the active provider.
     * Returns `true` when no user context is attached yet (unit tests / bootstrap without CurrentUser)
     * and `false` when the entity is not registered on the provider or read access is denied.
     */
    public CanReadEntity(
        entityName: string,
        provider?: IMetadataProvider | null,
        contextUser?: UserInfo,
    ): boolean {
        const effectiveProvider = provider ?? this.ProviderToUse;
        const user = contextUser ?? effectiveProvider?.CurrentUser;
        if (!user) return true;
        const entity = effectiveProvider?.EntityByName?.(entityName);
        if (!entity) return false;
        return Boolean(entity.GetUserPermisions?.(user)?.CanRead);
    }

    // ─── Tier 1: Taxonomy Getters & O(1) Lookups ─────────────────────────────

    public get TaskTypes(): readonly mjBizAppsTasksTaskTypeEntity[] {
        return this._taskTypes;
    }

    public get ActiveTaskTypes(): readonly mjBizAppsTasksTaskTypeEntity[] {
        return this._taskTypes.filter((t) => Boolean(t.IsActive));
    }

    public TaskTypeById(id: string | null | undefined): mjBizAppsTasksTaskTypeEntity | undefined {
        const key = normalizeId(id);
        if (!key) return undefined;
        if (!this._taskTypesById) {
            this._taskTypesById = new Map<string, mjBizAppsTasksTaskTypeEntity>();
            for (const row of this._taskTypes) {
                if (row.ID) {
                    this._taskTypesById.set(normalizeId(row.ID), row);
                }
            }
        }
        return this._taskTypesById.get(key);
    }

    public TaskTypeByCode(code: string | null | undefined): mjBizAppsTasksTaskTypeEntity | undefined {
        const key = normalizeCode(code);
        if (!key) return undefined;
        if (!this._taskTypesByCode) {
            this._taskTypesByCode = new Map<string, mjBizAppsTasksTaskTypeEntity>();
            for (const row of this._taskTypes) {
                if (row.Code) {
                    this._taskTypesByCode.set(normalizeCode(row.Code), row);
                }
            }
        }
        return this._taskTypesByCode.get(key);
    }

    public get TaskTypeStatuses(): readonly mjBizAppsTasksTaskTypeStatusEntity[] {
        return this._taskTypeStatuses;
    }

    public get ActiveTypeStatuses(): readonly mjBizAppsTasksTaskTypeStatusEntity[] {
        return this._taskTypeStatuses
            .filter((s) => Boolean(s.IsActive))
            .sort((a, b) => (a.Sequence ?? 0) - (b.Sequence ?? 0));
    }

    public TaskTypeStatusById(id: string | null | undefined): mjBizAppsTasksTaskTypeStatusEntity | undefined {
        const key = normalizeId(id);
        if (!key) return undefined;
        if (!this._statusesById) {
            this._statusesById = new Map<string, mjBizAppsTasksTaskTypeStatusEntity>();
            for (const row of this._taskTypeStatuses) {
                if (row.ID) {
                    this._statusesById.set(normalizeId(row.ID), row);
                }
            }
        }
        return this._statusesById.get(key);
    }

    public StatusesForType(
        taskTypeId: string | null | undefined,
        activeOnly = true,
    ): readonly mjBizAppsTasksTaskTypeStatusEntity[] {
        const key = normalizeId(taskTypeId);
        if (!key) return [];
        if (activeOnly) {
            if (!this._statusesByTypeActive) {
                this._statusesByTypeActive = this.buildStatusesByTypeMap(true);
            }
            return this._statusesByTypeActive.get(key) ?? [];
        }
        if (!this._statusesByTypeAll) {
            this._statusesByTypeAll = this.buildStatusesByTypeMap(false);
        }
        return this._statusesByTypeAll.get(key) ?? [];
    }

    public get TaskCategories(): readonly mjBizAppsTasksTaskCategoryEntity[] {
        return this._taskCategories;
    }

    public get ActiveCategories(): readonly mjBizAppsTasksTaskCategoryEntity[] {
        return this._taskCategories
            .filter((c) => Boolean(c.IsActive))
            .sort((a, b) => {
                const seqDiff = (a.Sequence ?? 0) - (b.Sequence ?? 0);
                return seqDiff !== 0 ? seqDiff : (a.Name ?? '').localeCompare(b.Name ?? '');
            });
    }

    public CategoryById(id: string | null | undefined): mjBizAppsTasksTaskCategoryEntity | undefined {
        const key = normalizeId(id);
        if (!key) return undefined;
        if (!this._categoriesById) {
            this._categoriesById = new Map<string, mjBizAppsTasksTaskCategoryEntity>();
            for (const row of this._taskCategories) {
                if (row.ID) {
                    this._categoriesById.set(normalizeId(row.ID), row);
                }
            }
        }
        return this._categoriesById.get(key);
    }

    public get TaskRoles(): readonly mjBizAppsTasksTaskRoleEntity[] {
        return this._taskRoles;
    }

    public TaskRoleById(id: string | null | undefined): mjBizAppsTasksTaskRoleEntity | undefined {
        const key = normalizeId(id);
        if (!key) return undefined;
        if (!this._rolesById) {
            this._rolesById = new Map<string, mjBizAppsTasksTaskRoleEntity>();
            for (const row of this._taskRoles) {
                if (row.ID) {
                    this._rolesById.set(normalizeId(row.ID), row);
                }
            }
        }
        return this._rolesById.get(key);
    }

    public get TaskTags(): readonly mjBizAppsTasksTaskTagEntity[] {
        return this._taskTags;
    }

    public TaskTagById(id: string | null | undefined): mjBizAppsTasksTaskTagEntity | undefined {
        const key = normalizeId(id);
        if (!key) return undefined;
        if (!this._tagsById) {
            this._tagsById = new Map<string, mjBizAppsTasksTaskTagEntity>();
            for (const row of this._taskTags) {
                if (row.ID) {
                    this._tagsById.set(normalizeId(row.ID), row);
                }
            }
        }
        return this._tagsById.get(key);
    }

    public TaskTagByName(name: string | null | undefined): mjBizAppsTasksTaskTagEntity | undefined {
        const key = normalizeId(name);
        if (!key) return undefined;
        if (!this._tagsByName) {
            this._tagsByName = new Map<string, mjBizAppsTasksTaskTagEntity>();
            for (const row of this._taskTags) {
                if (row.Name) {
                    this._tagsByName.set(normalizeId(row.Name), row);
                }
            }
        }
        return this._tagsByName.get(key);
    }

    // ─── Incremental People & Organizations Directory Helpers ────────────────

    /**
     * Resolves `MJ_BizApps_Common: People` rows by ID with per-provider, per-user incremental caching.
     *
     * Only `PersonID`s not yet present in the active user's cache are queried from the database.
     * Automatically resets whenever the acting user ID changes, and returns an empty map when the
     * user lacks `CanRead` on `MJ_BizApps_Common: People`.
     */
    public async GetOrLoadPeopleByIds(
        ids: ReadonlyArray<string | null | undefined>,
        provider?: IMetadataProvider | null,
        contextUser?: UserInfo,
    ): Promise<Map<string, TasksDirectoryPerson>> {
        const result = new Map<string, TasksDirectoryPerson>();
        const { activeProvider, effectiveUser, cache } = this.resolveScopedCache(provider, contextUser);

        if (!this.CanReadEntity(TASKS_ENGINE_ENTITIES.People, activeProvider, effectiveUser)) {
            return result;
        }

        const uniqueRequestedIds: string[] = [];
        const seen = new Set<string>();
        for (const rawId of ids) {
            if (!rawId || !IsValidUUID(rawId)) continue;
            const norm = normalizeId(rawId);
            if (!seen.has(norm)) {
                seen.add(norm);
                uniqueRequestedIds.push(rawId.trim());
            }
        }
        if (uniqueRequestedIds.length === 0) {
            return result;
        }

        const unseenIds: string[] = [];
        for (const id of uniqueRequestedIds) {
            const norm = normalizeId(id);
            if (!cache.peopleById.has(norm) && !cache.missingPersonIds.has(norm)) {
                unseenIds.push(id);
            }
        }

        if (unseenIds.length > 0) {
            const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
            const chunks = chunkIds(unseenIds, limits.ResourceGuards.SqlInClauseChunkSize);
            const rv = this.createRunView(activeProvider);
            const paramsList: RunViewParams[] = chunks.map((chunk) => ({
                EntityName: TASKS_ENGINE_ENTITIES.People,
                ExtraFilter: buildGuidInClause('ID', chunk),
                Fields: ['ID', 'FirstName', 'LastName'],
                ResultType: 'simple',
            }));

            const responses = await this.executeRunViewBatch<PeopleQueryRow>(rv, paramsList, effectiveUser);
            const foundKeys = new Set<string>();
            for (const res of responses) {
                if (!res?.Success) continue;
                for (const row of res.Results ?? []) {
                    if (!row?.ID) continue;
                    const person = toDirectoryPerson(row);
                    const norm = normalizeId(person.ID);
                    cache.peopleById.set(norm, person);
                    cache.missingPersonIds.delete(norm);
                    foundKeys.add(norm);
                }
            }
            const allSucceeded = responses.every((r) => Boolean(r?.Success));
            if (allSucceeded) {
                for (const id of unseenIds) {
                    const norm = normalizeId(id);
                    if (!foundKeys.has(norm)) {
                        cache.missingPersonIds.add(norm);
                    }
                }
            }
        }

        for (const id of uniqueRequestedIds) {
            const cached = cache.peopleById.get(normalizeId(id));
            if (cached) {
                result.set(normalizeId(cached.ID), cached);
            }
        }
        return result;
    }

    /**
     * Loads and caches the full `MJ_BizApps_Common: People` directory per provider/user for picker dropdowns,
     * also seeding the incremental {@link GetOrLoadPeopleByIds} map.
     */
    public async GetOrLoadAllPeople(
        provider?: IMetadataProvider | null,
        contextUser?: UserInfo,
        forceRefresh = false,
    ): Promise<readonly TasksDirectoryPerson[]> {
        const { activeProvider, effectiveUser, cache } = this.resolveScopedCache(provider, contextUser);

        if (!this.CanReadEntity(TASKS_ENGINE_ENTITIES.People, activeProvider, effectiveUser)) {
            return [];
        }

        if (cache.allPeopleLoaded && !forceRefresh) {
            return cache.allPeopleList;
        }

        const rv = this.createRunView(activeProvider);
        const res = await rv.RunView<PeopleQueryRow>(
            {
                EntityName: TASKS_ENGINE_ENTITIES.People,
                Fields: ['ID', 'FirstName', 'LastName'],
                OrderBy: 'FirstName ASC, LastName ASC',
                ResultType: 'simple',
                BypassCache: forceRefresh,
            },
            effectiveUser,
        );

        if (!res?.Success) {
            return cache.allPeopleLoaded ? cache.allPeopleList : [];
        }

        const people = (res.Results ?? []).map(toDirectoryPerson);
        cache.allPeopleList = people;
        cache.allPeopleLoaded = true;
        cache.missingPersonIds.clear();
        for (const person of people) {
            cache.peopleById.set(normalizeId(person.ID), person);
        }
        return cache.allPeopleList;
    }

    /**
     * Loads and caches active `MJ_BizApps_Common: Organizations` (`Status = 'Active'`) per provider/user,
     * sorted with company-linked organizations first then alphabetically by `Name`.
     */
    public async GetOrLoadActiveOrganizations(
        provider?: IMetadataProvider | null,
        contextUser?: UserInfo,
        forceRefresh = false,
    ): Promise<readonly TasksDirectoryOrganization[]> {
        const { activeProvider, effectiveUser, cache } = this.resolveScopedCache(provider, contextUser);

        if (!this.CanReadEntity(TASKS_ENGINE_ENTITIES.Organizations, activeProvider, effectiveUser)) {
            return [];
        }

        if (cache.activeOrganizationsLoaded && !forceRefresh) {
            return cache.activeOrganizationsList;
        }

        const rv = this.createRunView(activeProvider);
        const res = await rv.RunView<OrganizationQueryRow>(
            {
                EntityName: TASKS_ENGINE_ENTITIES.Organizations,
                ExtraFilter: "Status = 'Active'",
                Fields: ['ID', 'Name', 'LinkedCompanyID'],
                OrderBy: 'Name ASC',
                ResultType: 'simple',
                BypassCache: forceRefresh,
            },
            effectiveUser,
        );

        if (!res?.Success) {
            return cache.activeOrganizationsLoaded ? cache.activeOrganizationsList : [];
        }

        const sorted = sortOrganizations(res.Results ?? []);
        cache.activeOrganizationsList = sorted;
        cache.activeOrganizationsLoaded = true;
        cache.missingOrganizationIds.clear();
        for (const org of sorted) {
            cache.organizationsById.set(normalizeId(org.ID), org);
        }
        return cache.activeOrganizationsList;
    }

    /**
     * Incrementally resolves `MJ_BizApps_Common: Organizations` by ID per provider/user,
     * querying only unseen IDs.
     */
    public async GetOrLoadOrganizationsByIds(
        ids: ReadonlyArray<string | null | undefined>,
        provider?: IMetadataProvider | null,
        contextUser?: UserInfo,
    ): Promise<Map<string, TasksDirectoryOrganization>> {
        const result = new Map<string, TasksDirectoryOrganization>();
        const { activeProvider, effectiveUser, cache } = this.resolveScopedCache(provider, contextUser);

        if (!this.CanReadEntity(TASKS_ENGINE_ENTITIES.Organizations, activeProvider, effectiveUser)) {
            return result;
        }

        const uniqueRequestedIds: string[] = [];
        const seen = new Set<string>();
        for (const rawId of ids) {
            if (!rawId || !IsValidUUID(rawId)) continue;
            const norm = normalizeId(rawId);
            if (!seen.has(norm)) {
                seen.add(norm);
                uniqueRequestedIds.push(rawId.trim());
            }
        }
        if (uniqueRequestedIds.length === 0) {
            return result;
        }

        const unseenIds = uniqueRequestedIds.filter((id) => {
            const norm = normalizeId(id);
            return !cache.organizationsById.has(norm) && !cache.missingOrganizationIds.has(norm);
        });

        if (unseenIds.length > 0) {
            const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
            const chunks = chunkIds(unseenIds, limits.ResourceGuards.SqlInClauseChunkSize);
            const rv = this.createRunView(activeProvider);
            const paramsList: RunViewParams[] = chunks.map((chunk) => ({
                EntityName: TASKS_ENGINE_ENTITIES.Organizations,
                ExtraFilter: buildGuidInClause('ID', chunk),
                Fields: ['ID', 'Name', 'LinkedCompanyID'],
                ResultType: 'simple',
            }));

            const responses = await this.executeRunViewBatch<OrganizationQueryRow>(rv, paramsList, effectiveUser);
            const foundKeys = new Set<string>();
            for (const res of responses) {
                if (!res?.Success) continue;
                for (const row of res.Results ?? []) {
                    if (!row?.ID) continue;
                    const org: TasksDirectoryOrganization = {
                        ID: row.ID,
                        Name: row.Name,
                        LinkedCompanyID: row.LinkedCompanyID ?? null,
                    };
                    const norm = normalizeId(org.ID);
                    cache.organizationsById.set(norm, org);
                    cache.missingOrganizationIds.delete(norm);
                    foundKeys.add(norm);
                }
            }
            const allSucceeded = responses.every((r) => Boolean(r?.Success));
            if (allSucceeded) {
                for (const id of unseenIds) {
                    const norm = normalizeId(id);
                    if (!foundKeys.has(norm)) {
                        cache.missingOrganizationIds.add(norm);
                    }
                }
            }
        }

        for (const id of uniqueRequestedIds) {
            const cached = cache.organizationsById.get(normalizeId(id));
            if (cached) {
                result.set(normalizeId(cached.ID), cached);
            }
        }
        return result;
    }

    // ─── Tier 3: Bounded Project Subtree Cache (ConversationEngine-style) ────

    /**
     * Loads and caches a bounded project subtree bundle (`[Tasks, Task Assignments, Task Dependencies]`)
     * keyed strictly by normalized `rootTaskId` (never caching arbitrary `ExtraFilter` SQL task lists).
     *
     * Implementation notes (5-Rule Standard):
     * - **RLS-safe two-step read (Rule 5)**: `Task Assignments` and `Task Dependencies` are RLS-filtered
     *   entities without a `RootParentID` column, so raw SQL subqueries against `vwTasks` are forbidden.
     *   Step 1 loads the subtree `Tasks` (`ID = root OR ParentID = root OR RootParentID = root`);
     *   Step 2 batches `[Task Assignments, Task Dependencies]` for the resolved `TaskID`s in a **single**
     *   `rv.RunViews([...])` GraphQL request.
     * - **Never `CacheLocal`** (Rule 2): cached exclusively in-memory per `(provider, userId)` and evicted
     *   automatically on user switch, `BaseEntity` save/delete events, or {@link InvalidateProjectSubtree}.
     * - **Shared across WBS / Kanban / Gantt**: concurrent callers share in-flight promises, and view switches
     *   within the same project hit memory with 0 network round-trips.
     */
    public async LoadProjectSubtree(
        rootTaskId: string,
        options: LoadProjectSubtreeOptions = {},
    ): Promise<ProjectSubtreeBundle> {
        const rootLiteral = GuidLiteral(rootTaskId, 'rootTaskId');
        const normalizedRoot = normalizeId(rootTaskId);
        const includeCancelled = Boolean(options.includeCancelled);
        const cacheKey = `${normalizedRoot}|${includeCancelled ? 'all' : 'active'}`;

        const { activeProvider, effectiveUser, cache } = this.resolveScopedCache(
            options.provider,
            options.contextUser,
        );

        if (!options.forceRefresh) {
            const existing = cache.subtreesByKey.get(cacheKey);
            if (existing) {
                return existing;
            }
            const pending = cache.inFlightSubtrees.get(cacheKey);
            if (pending) {
                return pending;
            }
        }

        const loadPromise = this.fetchProjectSubtreeBundle({
            rootTaskId: rootTaskId.trim(),
            rootLiteral,
            includeCancelled,
            bypassCache: Boolean(options.forceRefresh),
            activeProvider,
            effectiveUser,
        }).then((bundle) => {
            if (cache.epoch === this._userCacheEpoch) {
                const maxEntries = TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.StandardListMaxRows;
                if (!cache.subtreesByKey.has(cacheKey) && cache.subtreesByKey.size >= maxEntries) {
                    const oldestKey = cache.subtreesByKey.keys().next().value;
                    if (oldestKey !== undefined) {
                        cache.subtreesByKey.delete(oldestKey);
                    }
                }
                cache.subtreesByKey.set(cacheKey, bundle);
            }
            return bundle;
        }).finally(() => {
            if (cache.inFlightSubtrees.get(cacheKey) === loadPromise) {
                cache.inFlightSubtrees.delete(cacheKey);
            }
        });

        cache.inFlightSubtrees.set(cacheKey, loadPromise);
        return loadPromise;
    }

    /**
     * Drops cached subtree bundle(s) for `rootTaskId`, or all cached project subtrees when omitted.
     */
    public InvalidateProjectSubtree(rootTaskId?: string | null): void {
        const active = this._lastActiveCache;
        if (!active || active.epoch !== this._userCacheEpoch) {
            return;
        }
        if (!rootTaskId) {
            active.subtreesByKey.clear();
            active.inFlightSubtrees.clear();
            return;
        }
        const norm = normalizeId(rootTaskId);
        if (!norm) {
            active.subtreesByKey.clear();
            active.inFlightSubtrees.clear();
            return;
        }
        for (const key of [...active.subtreesByKey.keys()]) {
            if (key.startsWith(`${norm}|`)) {
                active.subtreesByKey.delete(key);
            }
        }
        for (const key of [...active.inFlightSubtrees.keys()]) {
            if (key.startsWith(`${norm}|`)) {
                active.inFlightSubtrees.delete(key);
            }
        }
    }

    /** Clears cached People directory rows for the active provider/user. */
    public InvalidatePeopleCache(): void {
        const active = this._lastActiveCache;
        if (active && active.epoch === this._userCacheEpoch) {
            active.peopleById.clear();
            active.missingPersonIds.clear();
            active.allPeopleLoaded = false;
            active.allPeopleList = [];
        }
    }

    /** Clears cached Organizations directory rows for the active provider/user. */
    public InvalidateOrganizationsCache(): void {
        const active = this._lastActiveCache;
        if (active && active.epoch === this._userCacheEpoch) {
            active.organizationsById.clear();
            active.missingOrganizationIds.clear();
            active.activeOrganizationsLoaded = false;
            active.activeOrganizationsList = [];
        }
    }

    /**
     * Clears ALL user-scoped caches (People directory, Organizations directory, Project Subtrees)
     * across every provider. Called automatically on user switch / impersonation and available
     * for explicit sign-out cleanup.
     */
    public ClearUserScopedCaches(): void {
        this._userCacheEpoch += 1;
        this._lastActiveCache = null;
    }

    // ─── Internal Helpers ─────────────────────────────────────────────────────

    private resetTaxonomyIndexes(): void {
        this._taskTypesById = null;
        this._taskTypesByCode = null;
        this._statusesById = null;
        this._statusesByTypeAll = null;
        this._statusesByTypeActive = null;
        this._categoriesById = null;
        this._rolesById = null;
        this._tagsById = null;
        this._tagsByName = null;
    }

    private buildStatusesByTypeMap(activeOnly: boolean): Map<string, mjBizAppsTasksTaskTypeStatusEntity[]> {
        const map = new Map<string, mjBizAppsTasksTaskTypeStatusEntity[]>();
        for (const status of this._taskTypeStatuses) {
            if (activeOnly && !status.IsActive) continue;
            const typeKey = normalizeId(status.TaskTypeID);
            if (!typeKey) continue;
            const list = map.get(typeKey) ?? [];
            list.push(status);
            map.set(typeKey, list);
        }
        for (const list of map.values()) {
            list.sort((a, b) => (a.Sequence ?? 0) - (b.Sequence ?? 0));
        }
        return map;
    }

    private resolveScopedCache(
        provider?: IMetadataProvider | null,
        contextUser?: UserInfo,
    ): {
        activeProvider: IMetadataProvider;
        effectiveUser: UserInfo | undefined;
        cache: ProviderUserScopedCache;
    } {
        const activeProvider = provider ?? this.ProviderToUse;
        const effectiveUser = contextUser ?? activeProvider?.CurrentUser;
        const userId = normalizeId(effectiveUser?.ID);

        if (this._lastActiveUserId !== '' && userId !== this._lastActiveUserId) {
            this.ClearUserScopedCaches();
        }
        this._lastActiveUserId = userId;

        let cache = this._providerUserCaches.get(activeProvider);
        if (!cache || cache.epoch !== this._userCacheEpoch || cache.userId !== userId) {
            cache = {
                epoch: this._userCacheEpoch,
                userId,
                peopleById: new Map<string, TasksDirectoryPerson>(),
                missingPersonIds: new Set<string>(),
                allPeopleLoaded: false,
                allPeopleList: [],
                organizationsById: new Map<string, TasksDirectoryOrganization>(),
                missingOrganizationIds: new Set<string>(),
                activeOrganizationsLoaded: false,
                activeOrganizationsList: [],
                subtreesByKey: new Map<string, ProjectSubtreeBundle>(),
                inFlightSubtrees: new Map<string, Promise<ProjectSubtreeBundle>>(),
            };
            this._providerUserCaches.set(activeProvider, cache);
        }
        this._lastActiveCache = cache;
        return { activeProvider, effectiveUser, cache };
    }

    private createRunView(provider: IMetadataProvider | null | undefined): RunView {
        if (provider && typeof (provider as Partial<IRunViewProvider>).RunView === 'function') {
            return RunView.FromMetadataProvider(provider);
        }
        return new RunView();
    }

    private async executeRunViewBatch<T>(
        rv: RunView,
        paramsList: RunViewParams[],
        contextUser?: UserInfo,
    ): Promise<RunViewResult<T>[]> {
        if (paramsList.length === 0) return [];
        if (paramsList.length === 1) {
            const single = await rv.RunView<T>(paramsList[0], contextUser);
            return single ? [single] : [];
        }
        const batched = await rv.RunViews(paramsList, contextUser);
        return (batched ?? []) as RunViewResult<T>[];
    }

    private async fetchProjectSubtreeBundle(args: {
        rootTaskId: string;
        rootLiteral: string;
        includeCancelled: boolean;
        bypassCache: boolean;
        activeProvider: IMetadataProvider;
        effectiveUser: UserInfo | undefined;
    }): Promise<ProjectSubtreeBundle> {
        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        const rv = this.createRunView(args.activeProvider);

        if (!this.CanReadEntity(TASKS_ENGINE_ENTITIES.Tasks, args.activeProvider, args.effectiveUser)) {
            return {
                RootTaskID: args.rootTaskId,
                LoadedAt: Date.now(),
                Tasks: [],
                Assignments: [],
                Dependencies: [],
            };
        }

        const taskFilters: string[] = [
            `(ID = ${args.rootLiteral} OR ParentID = ${args.rootLiteral} OR RootParentID = ${args.rootLiteral})`,
        ];
        if (!args.includeCancelled) {
            taskFilters.push("Status <> 'Cancelled'");
        }

        const tasksRes = await rv.RunView<ProjectSubtreeTaskRow>(
            {
                EntityName: TASKS_ENGINE_ENTITIES.Tasks,
                ExtraFilter: taskFilters.join(' AND '),
                OrderBy: 'Sequence ASC',
                ResultType: 'simple',
                MaxRows: limits.ResourceGuards.LargeTreeQueryMaxRows,
                BypassCache: args.bypassCache,
            },
            args.effectiveUser,
        );

        const tasks = tasksRes?.Success ? (tasksRes.Results ?? []) : [];
        const validTaskIds = tasks
            .map((t) => t.ID)
            .filter((id): id is string => Boolean(id && IsValidUUID(id)));

        if (validTaskIds.length === 0) {
            return {
                RootTaskID: args.rootTaskId,
                LoadedAt: Date.now(),
                Tasks: tasks,
                Assignments: [],
                Dependencies: [],
            };
        }

        const canReadAssignments = this.CanReadEntity(
            TASKS_ENGINE_ENTITIES.TaskAssignments,
            args.activeProvider,
            args.effectiveUser,
        );
        const canReadDependencies = this.CanReadEntity(
            TASKS_ENGINE_ENTITIES.TaskDependencies,
            args.activeProvider,
            args.effectiveUser,
        );

        const idChunks = chunkIds(validTaskIds, limits.ResourceGuards.SqlInClauseChunkSize);
        const batchParams: RunViewParams[] = [];
        const batchKinds: Array<'assignments' | 'dependencies'> = [];

        if (canReadAssignments) {
            for (const chunk of idChunks) {
                batchParams.push({
                    EntityName: TASKS_ENGINE_ENTITIES.TaskAssignments,
                    ExtraFilter: buildGuidInClause('TaskID', chunk),
                    Fields: ['ID', 'TaskID', 'AssigneeEntityID', 'AssigneeRecordID', 'RoleID', 'Status'],
                    ResultType: 'simple',
                    MaxRows: limits.ResourceGuards.LargeTreeQueryMaxRows,
                    BypassCache: args.bypassCache,
                });
                batchKinds.push('assignments');
            }
        }

        if (canReadDependencies) {
            for (const chunk of idChunks) {
                const taskClause = buildGuidInClause('TaskID', chunk);
                const dependsClause = buildGuidInClause('DependsOnTaskID', chunk);
                batchParams.push({
                    EntityName: TASKS_ENGINE_ENTITIES.TaskDependencies,
                    ExtraFilter: `${taskClause} OR ${dependsClause}`,
                    Fields: ['ID', 'TaskID', 'DependsOnTaskID', 'DependencyType'],
                    ResultType: 'simple',
                    MaxRows: limits.ResourceGuards.LargeTreeQueryMaxRows,
                    BypassCache: args.bypassCache,
                });
                batchKinds.push('dependencies');
            }
        }

        const assignments: ProjectSubtreeAssignmentRow[] = [];
        const dependencies: ProjectSubtreeDependencyRow[] = [];
        const seenAssignIds = new Set<string>();
        const seenDepIds = new Set<string>();

        if (batchParams.length > 0) {
            const batchResults = await rv.RunViews(batchParams, args.effectiveUser);
            for (let i = 0; i < batchKinds.length; i++) {
                const res = batchResults?.[i];
                if (!res?.Success) continue;
                if (batchKinds[i] === 'assignments') {
                    for (const row of (res.Results ?? []) as ProjectSubtreeAssignmentRow[]) {
                        const key = normalizeId(row.ID) || `${normalizeId(row.TaskID)}|${normalizeId(row.AssigneeRecordID)}`;
                        if (!seenAssignIds.has(key)) {
                            seenAssignIds.add(key);
                            assignments.push(row);
                        }
                    }
                } else {
                    for (const row of (res.Results ?? []) as ProjectSubtreeDependencyRow[]) {
                        const key = normalizeId(row.ID) || `${normalizeId(row.TaskID)}|${normalizeId(row.DependsOnTaskID)}`;
                        if (!seenDepIds.has(key)) {
                            seenDepIds.add(key);
                            dependencies.push(row);
                        }
                    }
                }
            }
        }

        return {
            RootTaskID: args.rootTaskId,
            LoadedAt: Date.now(),
            Tasks: tasks,
            Assignments: assignments,
            Dependencies: dependencies,
        };
    }

    private invalidateSubtreesForTaskEvent(event: BaseEntityEvent): void {
        const active = this._lastActiveCache;
        if (!active || active.epoch !== this._userCacheEpoch || active.subtreesByKey.size === 0) {
            return;
        }
        const task = event.baseEntity as SubtreeTaskEventShape | undefined;
        const candidateIds = [task?.RootParentID, task?.ID, task?.ParentID]
            .map(normalizeId)
            .filter(Boolean);

        if (candidateIds.length === 0) {
            this.InvalidateProjectSubtree();
            return;
        }

        let matchedAny = false;
        for (const [key, bundle] of [...active.subtreesByKey.entries()]) {
            const rootKey = normalizeId(bundle.RootTaskID);
            const hitsRoot = candidateIds.includes(rootKey);
            const hitsTask =
                hitsRoot ||
                bundle.Tasks.some((row) =>
                    candidateIds.some((cid) => UUIDsEqual(row.ID, cid) || UUIDsEqual(row.RootParentID, cid)),
                );
            if (hitsTask) {
                active.subtreesByKey.delete(key);
                matchedAny = true;
            }
        }

        // If a task was reparented into/out of a cached tree whose old RootParentID is no longer on the entity,
        // err on the side of consistency and drop all cached subtrees.
        if (!matchedAny && event.type === 'save') {
            this.InvalidateProjectSubtree();
        }
    }

    private invalidateSubtreesForTaskChildEvent(event: BaseEntityEvent): void {
        const active = this._lastActiveCache;
        if (!active || active.epoch !== this._userCacheEpoch || active.subtreesByKey.size === 0) {
            return;
        }
        const child = event.baseEntity as SubtreeChildEventShape | undefined;
        const taskIds = [child?.TaskID, child?.DependsOnTaskID].map(normalizeId).filter(Boolean);

        if (taskIds.length === 0) {
            this.InvalidateProjectSubtree();
            return;
        }

        for (const [key, bundle] of [...active.subtreesByKey.entries()]) {
            const matches = bundle.Tasks.some((row) => taskIds.some((tid) => UUIDsEqual(row.ID, tid)));
            if (matches) {
                active.subtreesByKey.delete(key);
            }
        }
    }
}
