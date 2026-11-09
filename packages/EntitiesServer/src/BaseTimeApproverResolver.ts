/**
 * Extension point for supplying external scope records (e.g. Collaboration Spaces, Accounts, or
 * `TaskLink` targets) into the timesheet approver resolution chain (D12, §6.6, §12.2).
 *
 * Other apps (such as `@mj-biz-apps/collaboration`) register subclasses via
 * `@RegisterClass(BaseTimeApproverResolver, '<UniqueKey>')`. During `Tasks.SubmitTimesheet`,
 * {@link BaseTimeApproverResolver.ResolveAllForRootTasks} invokes every registered resolver in
 * ascending {@link BaseTimeApproverResolver.Priority} order and feeds the resulting scope records
 * into `ResolveApprovers` in `@mj-biz-apps/tasks-core`.
 */
import { RunView, type IMetadataProvider, type IRunViewProvider, type UserInfo } from '@memberjunction/core';
import { MJGlobal, RegisterClass } from '@memberjunction/global';
import type { ExternalScopeRecordFact } from '@mj-biz-apps/tasks-core';
import { GuidLiteral } from './UserPeople.js';

/**
 * Abstract base class for ClassFactory-registered time approver scope resolvers.
 */
export abstract class BaseTimeApproverResolver {
    /**
     * Ordering priority among registered resolvers (lower numbers run earlier / closer to the root task).
     * Default `100`.
     */
    public readonly Priority: number = 100;

    /**
     * Given a batch of root task IDs, returns a map from `rootTaskID` (case-insensitive) to an ordered
     * list of external scope records (nearest first) whose `TimeApprover` rows should be consulted.
     */
    public abstract ResolveScopesForRootTasks(
        rootTaskIDs: readonly string[],
        provider: IMetadataProvider,
        runViewProvider: IRunViewProvider | undefined,
        contextUser: UserInfo,
    ): Promise<Map<string, ExternalScopeRecordFact[]>>;

    /**
     * Discovers all ClassFactory-registered {@link BaseTimeApproverResolver} subclasses, executes them in
     * ascending {@link Priority} order, and merges their scope chains per root task ID.
     */
    public static async ResolveAllForRootTasks(
        rootTaskIDs: readonly string[],
        provider: IMetadataProvider,
        runViewProvider: IRunViewProvider | undefined,
        contextUser: UserInfo,
    ): Promise<Map<string, ExternalScopeRecordFact[]>> {
        const result = new Map<string, ExternalScopeRecordFact[]>();
        const uniqueRootIds = [...new Set(rootTaskIDs.map((id) => id.trim()).filter(Boolean))];
        if (uniqueRootIds.length === 0) {
            return result;
        }

        const registrations = MJGlobal.Instance.ClassFactory.GetAllRegistrations(BaseTimeApproverResolver);
        const instances: BaseTimeApproverResolver[] = [];
        const seenKeys = new Set<string>();

        for (let i = registrations.length - 1; i >= 0; i--) {
            const reg = registrations[i];
            const key = reg.Key ?? `__anon_${i}`;
            if (seenKeys.has(key)) continue;
            seenKeys.add(key);
            const inst = MJGlobal.Instance.ClassFactory.CreateInstance<BaseTimeApproverResolver>(
                BaseTimeApproverResolver,
                reg.Key ?? undefined,
            );
            if (inst) {
                instances.push(inst);
            }
        }

        instances.sort((a, b) => a.Priority - b.Priority);

        for (const resolver of instances) {
            const map = await resolver.ResolveScopesForRootTasks(uniqueRootIds, provider, runViewProvider, contextUser);
            for (const [rawTaskId, scopes] of map.entries()) {
                const normTaskId = rawTaskId.trim().toLowerCase();
                const existing = result.get(normTaskId) ?? [];
                for (const s of scopes) {
                    existing.push({
                        ...s,
                        Priority: s.Priority ?? resolver.Priority,
                    });
                }
                result.set(normTaskId, existing);
            }
        }

        return result;
    }
}

/**
 * Built-in resolver that surfaces external records linked to a root task via `MJ_BizApps_Tasks: Task Links`
 * (`TaskLink`) so `TimeApprover` rows scoped to `(ScopeEntityID, ScopeRecordID)` are automatically matched.
 */
@RegisterClass(BaseTimeApproverResolver, 'TaskLinkScopeApproverResolver')
export class TaskLinkScopeApproverResolver extends BaseTimeApproverResolver {
    public override readonly Priority = 200;

    public override async ResolveScopesForRootTasks(
        rootTaskIDs: readonly string[],
        _provider: IMetadataProvider,
        runViewProvider: IRunViewProvider | undefined,
        contextUser: UserInfo,
    ): Promise<Map<string, ExternalScopeRecordFact[]>> {
        const map = new Map<string, ExternalScopeRecordFact[]>();
        const validLiterals: string[] = [];
        for (const id of rootTaskIDs) {
            try {
                validLiterals.push(GuidLiteral(id, 'RootTaskID'));
            } catch {
                // Skip non-UUIDs in test fixtures
            }
        }
        if (validLiterals.length === 0) {
            return map;
        }

        const rv = new RunView(runViewProvider);
        const res = await rv.RunView<{
            TaskID: string;
            EntityID: string;
            Entity: string | null;
            RecordID: string;
            Description: string | null;
        }>(
            {
                EntityName: 'MJ_BizApps_Tasks: Task Links',
                ExtraFilter: `TaskID IN (${validLiterals.join(', ')})`,
                Fields: ['TaskID', 'EntityID', 'Entity', 'RecordID', 'Description'],
                ResultType: 'simple',
                BypassCache: true,
            },
            contextUser,
        );
        if (!res?.Success) {
            return map;
        }

        for (const row of res.Results ?? []) {
            const key = row.TaskID.trim().toLowerCase();
            const list = map.get(key) ?? [];
            const label =
                row.Description?.trim() ||
                (row.Entity ? `${row.Entity} (${row.RecordID})` : row.RecordID);
            list.push({
                ScopeEntityID: row.EntityID,
                ScopeRecordID: row.RecordID,
                ScopeLabel: label,
                Priority: this.Priority,
            });
            map.set(key, list);
        }

        return map;
    }
}
