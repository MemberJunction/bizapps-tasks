import { LogError, RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import type { MJAIAgentUserPolicyEntity } from '@memberjunction/core-entities';
import { EscapeSQLString } from '@memberjunction/global';
import * as aiCorePlus from '@memberjunction/ai-core-plus';
import type {
    ActionPolicyEvaluationResult,
    AgentEntityCrudOperation,
    AgentPolicyVerdict,
    EntityAccessEvaluationResult,
    EvaluateActionExecutionInput,
    EvaluateEntityAccessInput,
} from '@memberjunction/ai-core-plus';
import { AgentWakeTriggerService } from '@memberjunction/ai-agents';

export type TypedActionPolicyResultCode = 'POLICY_DENIED' | 'POLICY_DEFERRED' | 'APPROVAL_REQUIRED';

export interface ExecutingAgentFrameCompat {
    agentId: string;
    policyCeilingAgentIds: readonly string[];
}

export interface ResolvePolicyLookupOptionsCompat {
    forceRefresh?: boolean;
    provider?: IMetadataProvider;
}

export type PolicyLookupResultCompat =
    | { status: 'found'; policy: MJAIAgentUserPolicyEntity }
    | { status: 'none'; policy: null }
    | { status: 'error'; policy: null; errorMessage: string };

export interface ActionContextWithAgentId {
    AgentID?: string | null;
}

export interface TypedActionEntityGuardInputCompat {
    entityName: string;
    operation: AgentEntityCrudOperation;
    contextUser: UserInfo | undefined;
    actionContext?: ActionContextWithAgentId | object | string | number | boolean | null;
    provider?: IMetadataProvider;
    writeFields?: readonly string[];
    record?: Record<string, string | number | boolean | null | undefined>;
    now?: Date;
}

export interface TypedActionEntityGuardOutcomeCompat {
    Allowed: boolean;
    Active: boolean;
    DeniedFieldPatterns: string[];
    ResultCode?: TypedActionPolicyResultCode;
    Message?: string;
}

export interface TypedActionPolicyGuardCompat {
    CheckEntityAccess(input: TypedActionEntityGuardInputCompat): Promise<TypedActionEntityGuardOutcomeCompat>;
    MaskRecord<T extends Record<string, string | number | boolean | object | null | undefined>>(
        record: T,
        deniedFieldPatterns: readonly string[],
    ): Partial<T>;
    MaskRows<T extends Record<string, string | number | boolean | object | null | undefined>>(
        rows: readonly T[],
        deniedFieldPatterns: readonly string[],
    ): Partial<T>[];
}

export interface AgentUserPolicyEngineCompat {
    SetCachedPolicy(policy: MJAIAgentUserPolicyEntity, provider?: IMetadataProvider | null): void;
    GetCachedPolicy(agentId: string, userId: string, provider?: IMetadataProvider | null): MJAIAgentUserPolicyEntity | null;
    ClearCache(agentId?: string, userId?: string, provider?: IMetadataProvider | null): void;
    EvaluateEntityAccess(input: EvaluateEntityAccessInput): EntityAccessEvaluationResult;
    EvaluateActionExecution(input: EvaluateActionExecutionInput): ActionPolicyEvaluationResult;
    MaskRecordFields<T extends Record<string, string | number | boolean | object | null | undefined>>(
        record: T,
        deniedFieldPatterns: string[],
    ): Partial<T>;
    GetActiveExecutingAgentID?: () => string | null;
    GetActivePolicyCeilingAgentIDs?: () => readonly string[];
    GetEffectivePolicyAgentChain?: (explicitAgentId?: string | null) => string[];
    ResolvePolicyForAgentAndUser?: (
        agentId: string,
        userId: string,
        contextUser: UserInfo,
        options?: ResolvePolicyLookupOptionsCompat,
    ) => Promise<PolicyLookupResultCompat>;
    RunWithExecutingAgentContext?: <T>(
        agentIdOrFrame: string | ExecutingAgentFrameCompat,
        callback: () => Promise<T>,
    ) => Promise<T>;
}

interface AiCorePlusCompatNamespace {
    AgentUserPolicyEngine?: {
        readonly Instance: AgentUserPolicyEngineCompat;
        prototype?: AgentUserPolicyEngineCompat;
    };
    TypedActionPolicyGuard?: TypedActionPolicyGuardCompat;
}

export interface TriggerWorkstreamWakeInputCompat {
    targetUserID: string;
    targetAgentID?: string;
    targetAgentName?: string;
    workstreamKey: string;
    wakeReason: string;
    resumeState?: Record<string, string | number | boolean | object | null | undefined>;
    contextUser: UserInfo;
    metadataProvider?: IMetadataProvider;
    now?: Date;
}

export interface AgentWakeTriggerResultCompat {
    triggered: boolean;
    resultCode?: string;
    reason?: string;
}

type AgentWakeTriggerServiceCompat = AgentWakeTriggerService & {
    TriggerWakeForWorkstream?: (input: TriggerWorkstreamWakeInputCompat) => Promise<AgentWakeTriggerResultCompat>;
};

interface ExecutingAgentContextStoreCompat {
    getStore(): string | ExecutingAgentFrameCompat | undefined;
    run<T>(store: string | ExecutingAgentFrameCompat, callback: () => Promise<T>): Promise<T>;
}

interface NodeProcessCompat {
    getBuiltinModule?: (id: string) => { AsyncLocalStorage?: new () => ExecutingAgentContextStoreCompat } | undefined;
}

declare const process: NodeProcessCompat | undefined;

declare module '@memberjunction/ai-core-plus' {
    interface AgentUserPolicyEngine {
        SetCachedPolicy(policy: MJAIAgentUserPolicyEntity, provider?: IMetadataProvider | null): void;
        GetCachedPolicy(agentId: string, userId: string, provider?: IMetadataProvider | null): MJAIAgentUserPolicyEntity | null;
        ClearCache(agentId?: string, userId?: string, provider?: IMetadataProvider | null): void;
        GetActiveExecutingAgentID(): string | null;
        GetActivePolicyCeilingAgentIDs(): readonly string[];
        GetEffectivePolicyAgentChain(explicitAgentId?: string | null): string[];
        ResolvePolicyForAgentAndUser(
            agentId: string,
            userId: string,
            contextUser: UserInfo,
            options?: ResolvePolicyLookupOptionsCompat,
        ): Promise<PolicyLookupResultCompat>;
        RunWithExecutingAgentContext<T>(
            agentIdOrFrame: string | ExecutingAgentFrameCompat,
            callback: () => Promise<T>,
        ): Promise<T>;
    }
}

const aiCorePlusNs: AiCorePlusCompatNamespace = aiCorePlus;

function hasOwnExport(mod: object, key: string): boolean {
    return Object.prototype.hasOwnProperty.call(mod, key);
}

const VERDICT_RANK: Record<AgentPolicyVerdict, number> = {
    Allow: 0,
    RequireApproval: 1,
    DeferUntilNextWindow: 2,
    Deny: 3,
};

function verdictToResultCode(verdict: Exclude<AgentPolicyVerdict, 'Allow'>): TypedActionPolicyResultCode {
    if (verdict === 'Deny') return 'POLICY_DENIED';
    if (verdict === 'DeferUntilNextWindow') return 'POLICY_DEFERRED';
    return 'APPROVAL_REQUIRED';
}

function createExecutingAgentStore(): ExecutingAgentContextStoreCompat {
    try {
        const asyncHooks = process?.getBuiltinModule?.('node:async_hooks');
        if (asyncHooks?.AsyncLocalStorage) {
            return new asyncHooks.AsyncLocalStorage();
        }
    } catch {
        // Fallback to synchronous frame stack when node:async_hooks is unavailable
    }
    let current: string | ExecutingAgentFrameCompat | undefined;
    return {
        getStore(): string | ExecutingAgentFrameCompat | undefined {
            return current;
        },
        async run<T>(store: string | ExecutingAgentFrameCompat, callback: () => Promise<T>): Promise<T> {
            const prev = current;
            current = store;
            try {
                return await callback();
            } finally {
                current = prev;
            }
        },
    };
}

function extractCallingAgentID(actionContext: TypedActionEntityGuardInputCompat['actionContext']): string | null {
    if (!actionContext || typeof actionContext !== 'object' || !('AgentID' in actionContext)) {
        return null;
    }
    const raw = (actionContext as ActionContextWithAgentId).AgentID;
    if (typeof raw !== 'string') {
        return null;
    }
    const trimmed = raw.trim();
    return trimmed.length > 0 ? trimmed : null;
}

/**
 * Installs MJ `next` compatibility methods onto `AgentUserPolicyEngine.prototype`
 * when running against `@memberjunction/ai-core-plus@6.2.x`.
 */
export function EnsureAgentUserPolicyEngineCompat(): void {
    if (!hasOwnExport(aiCorePlus, 'AgentUserPolicyEngine')) {
        return;
    }
    const proto = aiCorePlusNs.AgentUserPolicyEngine?.prototype;
    if (!proto) {
        return;
    }
    const store = createExecutingAgentStore();

    if (typeof proto.GetActiveExecutingAgentID !== 'function') {
        proto.GetActiveExecutingAgentID = function GetActiveExecutingAgentID(): string | null {
            const stored = store.getStore();
            if (!stored) return null;
            return typeof stored === 'string' ? stored : stored.agentId;
        };
    }

    if (typeof proto.GetActivePolicyCeilingAgentIDs !== 'function') {
        proto.GetActivePolicyCeilingAgentIDs = function GetActivePolicyCeilingAgentIDs(): readonly string[] {
            const stored = store.getStore();
            if (!stored || typeof stored === 'string') return [];
            return stored.policyCeilingAgentIds;
        };
    }

    if (typeof proto.GetEffectivePolicyAgentChain !== 'function') {
        proto.GetEffectivePolicyAgentChain = function GetEffectivePolicyAgentChain(
            this: AgentUserPolicyEngineCompat,
            explicitAgentId?: string | null,
        ): string[] {
            const seen = new Set<string>();
            const chain: string[] = [];
            const add = (id: string | null | undefined): void => {
                const trimmed = id?.trim();
                if (!trimmed) return;
                const lower = trimmed.toLowerCase();
                if (!seen.has(lower)) {
                    seen.add(lower);
                    chain.push(trimmed);
                }
            };
            add(explicitAgentId);
            add(this.GetActiveExecutingAgentID?.());
            for (const ceilingId of this.GetActivePolicyCeilingAgentIDs?.() ?? []) {
                add(ceilingId);
            }
            return chain;
        };
    }

    if (typeof proto.RunWithExecutingAgentContext !== 'function') {
        proto.RunWithExecutingAgentContext = async function RunWithExecutingAgentContext<T>(
            agentIdOrFrame: string | ExecutingAgentFrameCompat,
            callback: () => Promise<T>,
        ): Promise<T> {
            return store.run(agentIdOrFrame, callback);
        };
    }

    if (typeof proto.ResolvePolicyForAgentAndUser !== 'function') {
        proto.ResolvePolicyForAgentAndUser = async function ResolvePolicyForAgentAndUser(
            this: AgentUserPolicyEngineCompat,
            agentId: string,
            userId: string,
            contextUser: UserInfo,
            options?: ResolvePolicyLookupOptionsCompat,
        ): Promise<PolicyLookupResultCompat> {
            const forceRefresh = options?.forceRefresh === true;
            if (!forceRefresh) {
                const cached = this.GetCachedPolicy(agentId, userId, options?.provider);
                if (cached) {
                    return { status: 'found', policy: cached };
                }
            }
            try {
                const rv = options?.provider ? RunView.FromMetadataProvider(options.provider) : new RunView();
                const safeAgentId = EscapeSQLString(agentId);
                const safeUserId = EscapeSQLString(userId);
                const result = await rv.RunView<MJAIAgentUserPolicyEntity>(
                    {
                        EntityName: 'MJ: AI Agent User Policies',
                        ExtraFilter: `AgentID='${safeAgentId}' AND UserID='${safeUserId}'`,
                        MaxRows: 1,
                        SkipTotalRowCount: true,
                        ResultType: 'entity_object',
                    },
                    contextUser,
                );
                if (!result.Success) {
                    return {
                        status: 'error',
                        policy: null,
                        errorMessage: result.ErrorMessage || 'RunView returned Success=false loading MJ: AI Agent User Policies',
                    };
                }
                if (result.Results.length > 0) {
                    const policy = result.Results[0];
                    this.SetCachedPolicy(policy, options?.provider);
                    return { status: 'found', policy };
                }
                return { status: 'none', policy: null };
            } catch (error) {
                return {
                    status: 'error',
                    policy: null,
                    errorMessage: error instanceof Error ? error.message : String(error),
                };
            }
        };
    }
}

EnsureAgentUserPolicyEngineCompat();

export function GetAgentUserPolicyEngineCompat(): AgentUserPolicyEngineCompat {
    EnsureAgentUserPolicyEngineCompat();
    const engine = hasOwnExport(aiCorePlus, 'AgentUserPolicyEngine')
        ? aiCorePlusNs.AgentUserPolicyEngine?.Instance
        : undefined;
    if (!engine) {
        throw new Error('AgentUserPolicyEngine.Instance is not available.');
    }
    return engine;
}

export function GetEffectivePolicyAgentChainCompat(
    engine: AgentUserPolicyEngineCompat,
    explicitAgentId?: string | null,
): string[] {
    if (typeof engine.GetEffectivePolicyAgentChain === 'function') {
        return engine.GetEffectivePolicyAgentChain(explicitAgentId);
    }
    const trimmed = explicitAgentId?.trim();
    return trimmed ? [trimmed] : [];
}

export async function ResolvePolicyForAgentAndUserCompat(
    engine: AgentUserPolicyEngineCompat,
    agentId: string,
    userId: string,
    contextUser: UserInfo,
    options?: ResolvePolicyLookupOptionsCompat,
): Promise<PolicyLookupResultCompat> {
    if (typeof engine.ResolvePolicyForAgentAndUser === 'function') {
        return engine.ResolvePolicyForAgentAndUser(agentId, userId, contextUser, options);
    }
    const cached = engine.GetCachedPolicy(agentId, userId, options?.provider);
    return cached ? { status: 'found', policy: cached } : { status: 'none', policy: null };
}

export async function TriggerWakeForWorkstreamCompat(
    input: TriggerWorkstreamWakeInputCompat,
): Promise<AgentWakeTriggerResultCompat> {
    const instance: AgentWakeTriggerServiceCompat | undefined = AgentWakeTriggerService.Instance;
    const triggerFn = instance && hasOwnExport(instance, 'TriggerWakeForWorkstream')
        ? instance.TriggerWakeForWorkstream
        : typeof instance?.TriggerWakeForWorkstream === 'function'
            ? instance.TriggerWakeForWorkstream
            : undefined;
    if (typeof triggerFn === 'function') {
        return triggerFn.call(instance, input);
    }
    LogError(
        `[BizAppsTasks] AgentWakeTriggerService.TriggerWakeForWorkstream is not available in installed @memberjunction/ai-agents; skipping wake for '${input.workstreamKey}'.`,
    );
    return {
        triggered: false,
        resultCode: 'NOT_AVAILABLE',
        reason: 'TriggerWakeForWorkstream is not available in installed @memberjunction/ai-agents.',
    };
}

function getNativeTypedActionPolicyGuard(): TypedActionPolicyGuardCompat | undefined {
    return hasOwnExport(aiCorePlus, 'TypedActionPolicyGuard') ? aiCorePlusNs.TypedActionPolicyGuard : undefined;
}

export const TypedActionPolicyGuard: TypedActionPolicyGuardCompat = {
    async CheckEntityAccess(input: TypedActionEntityGuardInputCompat): Promise<TypedActionEntityGuardOutcomeCompat> {
        const nativeGuard = getNativeTypedActionPolicyGuard();
        if (nativeGuard) {
            return nativeGuard.CheckEntityAccess(input);
        }

        const engine = GetAgentUserPolicyEngineCompat();
        const explicitAgentId = extractCallingAgentID(input.actionContext);
        const agentChain = GetEffectivePolicyAgentChainCompat(engine, explicitAgentId);

        if (agentChain.length === 0) {
            return { Allowed: true, Active: false, DeniedFieldPatterns: [] };
        }
        if (!input.contextUser?.ID) {
            return {
                Allowed: false,
                Active: false,
                DeniedFieldPatterns: [],
                ResultCode: 'POLICY_DENIED',
                Message: `Typed action on "${input.entityName}" requires a valid ContextUser.`,
            };
        }

        let anyPolicyActive = false;
        const deniedPatterns = new Set<string>();
        let strictestVerdict: AgentPolicyVerdict = 'Allow';
        let strictestReason = '';

        for (const agentId of agentChain) {
            let policy = engine.GetCachedPolicy(agentId, input.contextUser.ID, input.provider);
            if (!policy) {
                const lookup = await ResolvePolicyForAgentAndUserCompat(
                    engine,
                    agentId,
                    input.contextUser.ID,
                    input.contextUser,
                    { provider: input.provider },
                );
                if (lookup.status === 'error') {
                    return {
                        Allowed: false,
                        Active: anyPolicyActive,
                        DeniedFieldPatterns: Array.from(deniedPatterns),
                        ResultCode: 'POLICY_DENIED',
                        Message: `Policy check failed closed for "${input.entityName}": ${lookup.errorMessage}`,
                    };
                }
                policy = lookup.policy;
            }
            if (!policy) {
                continue;
            }
            anyPolicyActive = true;

            const evalResult = engine.EvaluateEntityAccess({
                entityName: input.entityName,
                operation: input.operation,
                mutatedFields: input.writeFields ? [...input.writeFields] : undefined,
                record: input.record,
                contextUser: input.contextUser,
                policy,
                provider: input.provider,
                now: input.now,
            });
            for (const pattern of evalResult.deniedFieldPatterns) {
                deniedPatterns.add(pattern);
            }
            if (VERDICT_RANK[evalResult.verdict] > VERDICT_RANK[strictestVerdict]) {
                strictestVerdict = evalResult.verdict;
                strictestReason = evalResult.reason;
            }
        }

        if (strictestVerdict !== 'Allow') {
            return {
                Allowed: false,
                Active: anyPolicyActive,
                DeniedFieldPatterns: Array.from(deniedPatterns),
                ResultCode: verdictToResultCode(strictestVerdict),
                Message: strictestReason || `Action on "${input.entityName}" (${input.operation}) blocked by agent user policy.`,
            };
        }

        return {
            Allowed: true,
            Active: anyPolicyActive,
            DeniedFieldPatterns: Array.from(deniedPatterns),
        };
    },

    MaskRecord<T extends Record<string, string | number | boolean | object | null | undefined>>(
        record: T,
        deniedFieldPatterns: readonly string[],
    ): Partial<T> {
        const nativeGuard = getNativeTypedActionPolicyGuard();
        if (nativeGuard) {
            return nativeGuard.MaskRecord(record, deniedFieldPatterns);
        }
        if (!deniedFieldPatterns || deniedFieldPatterns.length === 0) {
            return record;
        }
        return GetAgentUserPolicyEngineCompat().MaskRecordFields(record, [...deniedFieldPatterns]);
    },

    MaskRows<T extends Record<string, string | number | boolean | object | null | undefined>>(
        rows: readonly T[],
        deniedFieldPatterns: readonly string[],
    ): Partial<T>[] {
        const nativeGuard = getNativeTypedActionPolicyGuard();
        if (nativeGuard) {
            return nativeGuard.MaskRows(rows, deniedFieldPatterns);
        }
        if (!deniedFieldPatterns || deniedFieldPatterns.length === 0) {
            return [...rows];
        }
        return rows.map((row) => TypedActionPolicyGuard.MaskRecord(row, deniedFieldPatterns));
    },
};
