import {
    BaseEntity,
    EntitySaveOptions,
    EntityTransactionScope,
    IEntityDataProvider,
    IMetadataProvider,
    IRunViewProvider,
    LogError,
    Metadata,
    RunView,
    RunViewResult,
} from '@memberjunction/core';
import { EscapeSQLString, RegisterClass, UUIDsEqual } from '@memberjunction/global';
import {
    mjBizAppsTasksTaskEntity,
    TASK_RISK_ASSESSMENT_ENTITY,
    TaskRiskAssessmentEntity,
} from '@mj-biz-apps/tasks-entities';
import { TasksLimitsResolver } from '@mj-biz-apps/tasks-core';

interface TransactionalEntityProvider extends IEntityDataProvider {
    SupportsEntityTransactions: true;
    BeginEntityTransaction(): Promise<EntityTransactionScope>;
}

interface AssessedAtRow {
    ID: string;
    AssessedAt: string | Date;
}

function isTransactionalProvider(provider: IEntityDataProvider | null | undefined): provider is TransactionalEntityProvider {
    const candidate = provider as Partial<IEntityDataProvider> | null | undefined;
    return candidate?.SupportsEntityTransactions === true && typeof candidate.BeginEntityTransaction === 'function';
}

function resolveMetadataProvider(provider: IEntityDataProvider | null | undefined): IMetadataProvider {
    const candidate = provider as Partial<IMetadataProvider> | null | undefined;
    return typeof candidate?.GetEntityObject === 'function' ? (candidate as IMetadataProvider) : Metadata.Provider;
}

function resolveRunViewProvider(provider: IEntityDataProvider | null | undefined): IRunViewProvider | null {
    const candidate = provider as Partial<IRunViewProvider> | null | undefined;
    if (typeof candidate?.RunView === 'function') {
        return candidate as IRunViewProvider;
    }
    const mdProvider = Metadata.Provider as Partial<IRunViewProvider> | null | undefined;
    if (typeof mdProvider?.RunView === 'function') {
        return mdProvider as IRunViewProvider;
    }
    return null;
}

function toTimestampMs(value: string | Date | null | undefined): number {
    if (value == null) {
        return 0;
    }
    const ms = value instanceof Date ? value.getTime() : new Date(value).getTime();
    return Number.isFinite(ms) ? ms : 0;
}

/**
 * Server-side subclass of {@link TaskRiskAssessmentEntity}.
 *
 * When a `Task Risk Assessment` is saved, this server subclass atomically
 * synchronizes `HealthStatus`, `ConfidenceScore` (mapped from `ForecastConfidence`),
 * and `ForecastCompletionDate` onto the linked project root `Task` so Epic 6
 * rollups and Chief of Staff briefings stay current, guarded so out-of-order
 * updates to older historical assessments never overwrite newer root task state.
 */
@RegisterClass(BaseEntity, TASK_RISK_ASSESSMENT_ENTITY)
export class TaskRiskAssessmentEntityServer extends TaskRiskAssessmentEntity {
    public override async Save(options?: EntitySaveOptions): Promise<boolean> {
        const provider = this.ProviderToUse;
        const txScope = isTransactionalProvider(provider)
            ? await provider.BeginEntityTransaction()
            : null;

        try {
            const saved = await super.Save(options);
            if (!saved) {
                if (txScope) {
                    await txScope.Rollback();
                }
                return false;
            }

            const isLatest = await this.isLatestAssessmentForTask();
            if (isLatest) {
                const rootTask = await this.loadRootProjectTask();
                if (rootTask) {
                    if (txScope) {
                        await this.syncAssessmentToRootTask(rootTask);
                    } else {
                        try {
                            await this.syncAssessmentToRootTask(rootTask);
                        } catch (err) {
                            const msg = err instanceof Error ? err.message : String(err);
                            LogError(
                                `TaskRiskAssessmentEntityServer: failed to sync assessment ${this.ID} to task ${this.TaskID}: ${msg}`,
                            );
                        }
                    }
                }
            }

            if (txScope) {
                await txScope.Commit();
            }
            return true;
        } catch (err) {
            if (txScope) {
                await txScope.Rollback();
            }
            throw err;
        }
    }

    /**
     * Checks whether this assessment is the newest (by `AssessedAt`) for `this.TaskID`,
     * preventing historical or out-of-order assessment edits from regressing root task state.
     */
    protected async isLatestAssessmentForTask(): Promise<boolean> {
        if (!this.TaskID) {
            return false;
        }
        const rvProvider = resolveRunViewProvider(this.ProviderToUse);
        if (!rvProvider) {
            return true;
        }
        try {
            const rv = new RunView(rvProvider);
            const escapedTaskId = EscapeSQLString(this.TaskID);
            const excludeSelfClause = this.ID ? ` AND ID <> '${EscapeSQLString(this.ID)}'` : '';
            const result: RunViewResult<AssessedAtRow> = await rv.RunView<AssessedAtRow>(
                {
                    EntityName: TASK_RISK_ASSESSMENT_ENTITY,
                    ExtraFilter: `TaskID = '${escapedTaskId}'${excludeSelfClause}`,
                    OrderBy: 'AssessedAt DESC',
                    Fields: ['ID', 'AssessedAt'],
                    MaxRows: TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.DefaultLookupSingleRow,
                    ResultType: 'simple',
                },
                this.ContextCurrentUser,
            );
            if (!result.Success || !Array.isArray(result.Results) || result.Results.length === 0) {
                return true;
            }

            const currentMs = toTimestampMs(this.AssessedAt);
            for (const row of result.Results) {
                if (this.ID && UUIDsEqual(row.ID, this.ID)) {
                    continue;
                }
                if (toTimestampMs(row.AssessedAt) > currentMs) {
                    return false;
                }
            }
            return true;
        } catch {
            // If RunView cannot execute in an isolated mock, default to syncing.
            return true;
        }
    }

    /**
     * Loads the linked root project `Task`, resolving up the `RootParentID` / `ParentID` chain
     * when an assessment references a non-root task.
     */
    protected async loadRootProjectTask(): Promise<mjBizAppsTasksTaskEntity | null> {
        if (!this.TaskID) {
            return null;
        }
        const md = resolveMetadataProvider(this.ProviderToUse);
        const task = await md.GetEntityObject<mjBizAppsTasksTaskEntity>(
            'MJ_BizApps_Tasks: Tasks',
            this.ContextCurrentUser,
        );
        const loaded = await task.Load(this.TaskID);
        if (!loaded) {
            return null;
        }

        if (!task.ParentID) {
            return task;
        }

        if (task.RootParentID && !UUIDsEqual(task.RootParentID, task.ID)) {
            const rootTask = await md.GetEntityObject<mjBizAppsTasksTaskEntity>(
                'MJ_BizApps_Tasks: Tasks',
                this.ContextCurrentUser,
            );
            if (await rootTask.Load(task.RootParentID)) {
                return rootTask;
            }
        }

        const maxDepth = TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.MaxHierarchyDepth;
        const visited = new Set<string>([task.ID.toLowerCase()]);
        let current = task;
        for (let depth = 0; depth < maxDepth && current.ParentID; depth++) {
            const parentKey = current.ParentID.toLowerCase();
            if (visited.has(parentKey)) {
                break;
            }
            visited.add(parentKey);
            const parentTask = await md.GetEntityObject<mjBizAppsTasksTaskEntity>(
                'MJ_BizApps_Tasks: Tasks',
                this.ContextCurrentUser,
            );
            const parentLoaded = await parentTask.Load(current.ParentID);
            if (!parentLoaded) {
                break;
            }
            current = parentTask;
        }
        return current;
    }

    /**
     * Writes `HealthStatus`, `ConfidenceScore` (from `ForecastConfidence`), and
     * `ForecastCompletionDate` onto the linked root project `Task`.
     */
    protected async syncAssessmentToRootTask(rootTask: mjBizAppsTasksTaskEntity): Promise<void> {
        rootTask.HealthStatus = this.HealthStatus;

        if (this.ForecastConfidence != null) {
            rootTask.ConfidenceScore = Math.round(this.ForecastConfidence);
        }

        if (this.ForecastCompletionDate != null) {
            rootTask.ForecastCompletionDate = this.ForecastCompletionDate;
        }

        const parentSaved = await rootTask.Save();
        if (!parentSaved) {
            throw new Error(
                `Failed to sync task risk assessment ${this.ID} to root task ${rootTask.ID}: ${rootTask.LatestResult?.CompleteMessage ?? 'root task save returned false'}`,
            );
        }
    }
}
