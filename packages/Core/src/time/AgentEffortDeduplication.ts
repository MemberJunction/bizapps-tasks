/**
 * Pure AI agent run lineage deduplication and rollup calculation (§5.5, §6.3, §6.4, §11).
 *
 * MemberJunction's `vwAIAgentRuns` provides `TotalTokensUsedRollup` and `TotalCostRollup`, which
 * include all descendant sub-agent runs under an ancestor run. When both an ancestor run and one of
 * its descendant runs are linked in the same rollup scope (a single task, or a root task's subtree),
 * counting both would double-count the descendant's tokens and cost. Similarly, if the same run is
 * linked to two tasks in the same subtree, a subtree rollup must count that run once.
 */

/** Minimal lineage fields needed to decide whether an agent run is counted in a scope. */
export interface AgentRunLineageFact {
    /** The `MJ: AI Agent Runs` primary key (`AIAgentRun.ID`). */
    AIAgentRunID: string;
    /** Optional immediate parent run ID (`AIAgentRun.ParentRunID`). */
    ParentRunID?: string | null;
    /**
     * Optional slash-delimited hierarchy path from `vwAIAgentRuns.ParentRunIDPath`
     * (e.g. `"/root-guid/parent-guid/self-guid/"`).
     */
    ParentRunIDPath?: string | null;
    /** Optional `TaskID` when deduplicating per-task rather than across a whole subtree. */
    TaskID?: string;
}

/** Effort metrics on a linked agent run consumed by {@link SummarizeAgentRuns}. */
export interface AgentRunEffortFact extends AgentRunLineageFact {
    StartedAt?: Date | string | null;
    CompletedAt?: Date | string | null;
    DurationSeconds?: number | null;
    TotalTokensUsed?: number | null;
    TotalTokensUsedRollup?: number | null;
    TotalCost?: number | null;
    TotalCostRollup?: number | null;
}

/** Aggregated AI agent effort metrics for a task or task subtree. */
export interface AgentEffortRollup {
    AgentRunCount: number;
    AgentWallClockSeconds: number;
    AgentTotalTokens: number;
    AgentTotalCost: number;
}

/** Options for {@link CountedAgentRuns}. */
export interface CountedAgentRunsOptions {
    /**
     * When `true`, deduplicates runs within each `TaskID` independently (matching `vwTasks` per-task columns).
     * When `false` (the default), deduplicates across the entire `runs` collection as one scope (matching
     * `vwTaskRootAgentEffort` and `Tasks.GetTaskEffort` subtree rollups, including when the same run is
     * linked to multiple tasks in a tree).
     */
    PerTask?: boolean;
    /**
     * Optional extra lineage nodes (e.g. unlinked intermediate runs between a linked grandparent and a
     * linked grandchild) used when walking `ParentRunID` chains without `ParentRunIDPath`.
     */
    AncestryNodes?: readonly Pick<AgentRunLineageFact, 'AIAgentRunID' | 'ParentRunID' | 'ParentRunIDPath'>[];
}

const norm = (id: string | null | undefined): string => (id ?? '').trim().toLowerCase();

/**
 * Extracts normalized ancestor run IDs (excluding `selfRunID`) from a `ParentRunIDPath` string
 * (`"/<root>/<parent>/<self>/"`) and/or by walking `parentMap`.
 */
export function AncestorRunIDsFor(
    run: Pick<AgentRunLineageFact, 'AIAgentRunID' | 'ParentRunID' | 'ParentRunIDPath'>,
    parentMap: ReadonlyMap<string, string>,
): Set<string> {
    const selfId = norm(run.AIAgentRunID);
    const ancestors = new Set<string>();

    // 1. Parse slash-delimited ParentRunIDPath if present
    if (run.ParentRunIDPath) {
        const segments = run.ParentRunIDPath
            .split('/')
            .map((s) => norm(s))
            .filter((s) => s.length > 0 && s !== selfId);
        for (const seg of segments) {
            ancestors.add(seg);
        }
    }

    // 2. Walk ParentRunID chain with cycle protection
    let cursor = norm(run.ParentRunID);
    const visited = new Set<string>([selfId]);
    while (cursor && !visited.has(cursor)) {
        visited.add(cursor);
        ancestors.add(cursor);
        cursor = parentMap.get(cursor) ?? '';
    }

    return ancestors;
}

/**
 * Filters `runs` to the subset of runs that should be counted in totals (D7, §6.3, §6.4):
 * - Excludes any run whose ancestor (`ParentRunID` chain or `ParentRunIDPath`) is also present in the same scope.
 * - Deduplicates multiple links to the exact same `AIAgentRunID` within the same scope (keeping the first).
 */
export function CountedAgentRuns<T extends AgentRunLineageFact>(
    runs: readonly T[],
    options: CountedAgentRunsOptions = {},
): T[] {
    if (runs.length === 0) return [];

    // Build parent lookup from runs + optional intermediate ancestry nodes
    const parentMap = new Map<string, string>();
    const pathMap = new Map<string, string>();
    for (const node of options.AncestryNodes ?? []) {
        const id = norm(node.AIAgentRunID);
        const parentId = norm(node.ParentRunID);
        if (id && parentId) parentMap.set(id, parentId);
        if (id && node.ParentRunIDPath) pathMap.set(id, node.ParentRunIDPath);
    }
    for (const run of runs) {
        const id = norm(run.AIAgentRunID);
        const parentId = norm(run.ParentRunID);
        if (id && parentId) parentMap.set(id, parentId);
        if (id && run.ParentRunIDPath) pathMap.set(id, run.ParentRunIDPath);
    }

    // Group linked run IDs by scope key
    const scopeRunIds = new Map<string, Set<string>>();
    for (const run of runs) {
        const scopeKey = options.PerTask ? norm(run.TaskID) : '__all__';
        const runId = norm(run.AIAgentRunID);
        if (!runId) continue;
        let set = scopeRunIds.get(scopeKey);
        if (!set) {
            set = new Set<string>();
            scopeRunIds.set(scopeKey, set);
        }
        set.add(runId);
    }

    const seenInScope = new Map<string, Set<string>>();
    const counted: T[] = [];

    for (const run of runs) {
        const scopeKey = options.PerTask ? norm(run.TaskID) : '__all__';
        const runId = norm(run.AIAgentRunID);
        if (!runId) continue;

        let seen = seenInScope.get(scopeKey);
        if (!seen) {
            seen = new Set<string>();
            seenInScope.set(scopeKey, seen);
        }
        // If this exact AIAgentRunID was already counted in this scope, skip duplicate link
        if (seen.has(runId)) {
            continue;
        }

        const effectiveRun: Pick<AgentRunLineageFact, 'AIAgentRunID' | 'ParentRunID' | 'ParentRunIDPath'> = {
            AIAgentRunID: run.AIAgentRunID,
            ParentRunID: run.ParentRunID ?? parentMap.get(runId) ?? null,
            ParentRunIDPath: run.ParentRunIDPath ?? pathMap.get(runId) ?? null,
        };
        const ancestors = AncestorRunIDsFor(effectiveRun, parentMap);
        const linkedInScope = scopeRunIds.get(scopeKey) ?? new Set<string>();

        let hasLinkedAncestor = false;
        for (const anc of ancestors) {
            if (linkedInScope.has(anc)) {
                hasLinkedAncestor = true;
                break;
            }
        }

        if (!hasLinkedAncestor) {
            seen.add(runId);
            counted.push(run);
        }
    }

    return counted;
}

/**
 * Computes the wall-clock duration in whole seconds for a completed agent run, or `0` if incomplete/invalid.
 */
export function AgentRunDurationSeconds(run: Pick<AgentRunEffortFact, 'StartedAt' | 'CompletedAt' | 'DurationSeconds'>): number {
    if (typeof run.DurationSeconds === 'number' && Number.isFinite(run.DurationSeconds) && run.DurationSeconds >= 0) {
        return Math.round(run.DurationSeconds);
    }
    if (!run.StartedAt || !run.CompletedAt) return 0;
    const startMs = run.StartedAt instanceof Date ? run.StartedAt.getTime() : new Date(run.StartedAt).getTime();
    const endMs = run.CompletedAt instanceof Date ? run.CompletedAt.getTime() : new Date(run.CompletedAt).getTime();
    if (Number.isNaN(startMs) || Number.isNaN(endMs) || endMs < startMs) return 0;
    return Math.round((endMs - startMs) / 1000);
}

/**
 * Deduplicates `runs` via {@link CountedAgentRuns} and sums run count, wall-clock seconds, tokens, and cost
 * using `COALESCE(TotalCostRollup, TotalCost, 0)` and `COALESCE(TotalTokensUsedRollup, TotalTokensUsed, 0)`.
 */
export function SummarizeAgentRuns<T extends AgentRunEffortFact>(
    runs: readonly T[],
    options: CountedAgentRunsOptions = {},
): AgentEffortRollup {
    const counted = CountedAgentRuns(runs, options);
    let wallClockSeconds = 0;
    let totalTokens = 0;
    let totalCost = 0;

    for (const run of counted) {
        wallClockSeconds += AgentRunDurationSeconds(run);
        const tokens = run.TotalTokensUsedRollup ?? run.TotalTokensUsed ?? 0;
        const cost = run.TotalCostRollup ?? run.TotalCost ?? 0;
        totalTokens += Number.isFinite(tokens) ? Number(tokens) : 0;
        totalCost += Number.isFinite(cost) ? Number(cost) : 0;
    }

    return {
        AgentRunCount: counted.length,
        AgentWallClockSeconds: wallClockSeconds,
        AgentTotalTokens: Math.round(totalTokens),
        AgentTotalCost: Number(totalCost.toFixed(8)),
    };
}
