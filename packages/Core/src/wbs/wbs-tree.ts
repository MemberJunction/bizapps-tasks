/**
 * Pure Work Breakdown Structure (WBS) tree algorithms and types for BizApps Tasks.
 *
 * Zero DOM, Angular, or runtime data-provider dependencies — safe to import in
 * L1/L2 widget packages, Explorer surfaces, backend services, and unit tests.
 */

/** Visual tone for declarative task badges rendered on rows, cards, or headers. */
export type TaskBadgeTone = 'neutral' | 'info' | 'success' | 'warning' | 'error';

/** Declarative badge descriptor returned by host badge resolvers. */
export interface TaskBadgeDescriptor {
    Label: string;
    Icon?: string;
    Tone: TaskBadgeTone;
    Tooltip?: string;
}

/** Minimal task fields required to build, number, filter, and summarize a WBS tree. */
export interface TaskWbsNodeInput {
    ID: string;
    ParentID?: string | null;
    Name: string;
    Status: string;
    PercentComplete?: number | null;
    DueAt?: Date | string | null;
    DueDate?: Date | string | null;
    Sequence?: number | null;
    TypeCode?: string | null;
}

/** Hierarchical WBS tree node wrapping the original task item. */
export interface TaskWbsNode<T extends TaskWbsNodeInput = TaskWbsNodeInput> {
    Item: T;
    WbsCode: string;
    Depth: number;
    Children: TaskWbsNode<T>[];
    /** Effective 0-100 progress (rolls up child average when item's own PercentComplete is null/undefined). */
    EffectivePercentComplete: number;
    TotalDescendantCount: number;
    CompletedDescendantCount: number;
}

/** Aggregate KPI metrics computed across a WBS forest. */
export interface TaskWbsSummaryMetrics {
    TotalCount: number;
    CompletedCount: number;
    InProgressCount: number;
    BlockedCount: number;
    OpenCount: number;
    OverdueCount: number;
    OverallCompletionPercent: number;
}

/** Flattened visible display row produced by {@link FlattenVisibleWbsNodes}. */
export interface TaskWbsFlatRow<T extends TaskWbsNodeInput = TaskWbsNodeInput> {
    Node: TaskWbsNode<T>;
    Item: T;
    WbsCode: string;
    Depth: number;
    HasChildren: boolean;
    Expanded: boolean;
    AncestorIds: string[];
}

function normalizeId(id: string | null | undefined): string {
    return (id ?? '').trim().toLowerCase();
}

function parseDate(value: Date | string | null | undefined): Date | null {
    if (!value) return null;
    const d = value instanceof Date ? value : new Date(value);
    return Number.isNaN(d.getTime()) ? null : d;
}

function clampPercent(value: number): number {
    if (!Number.isFinite(value)) return 0;
    const rounded = Math.round(value);
    if (rounded < 0) return 0;
    if (rounded > 100) return 100;
    return rounded;
}

function isCompletedStatus(status: string): boolean {
    return status === 'Completed';
}

function isCancelledStatus(status: string): boolean {
    return status === 'Cancelled';
}

function isInProgressStatus(status: string): boolean {
    return status === 'InProgress' || status === 'In Progress';
}

function isBlockedStatus(status: string): boolean {
    return status === 'Blocked';
}

function compareTasks<T extends TaskWbsNodeInput>(a: T, b: T): number {
    const seqA = a.Sequence != null && Number.isFinite(a.Sequence) ? a.Sequence : Number.MAX_SAFE_INTEGER;
    const seqB = b.Sequence != null && Number.isFinite(b.Sequence) ? b.Sequence : Number.MAX_SAFE_INTEGER;
    if (seqA !== seqB) {
        return seqA - seqB;
    }
    const nameCmp = (a.Name ?? '').localeCompare(b.Name ?? '', undefined, { sensitivity: 'base' });
    if (nameCmp !== 0) {
        return nameCmp;
    }
    return a.ID.localeCompare(b.ID);
}

/**
 * Builds a deterministic hierarchical WBS forest from a flat task array.
 *
 * - Orphaned tasks (whose `ParentID` does not exist in `flatTasks`) become top-level roots.
 * - Self-references and parent cycles are broken safely so every unique task appears once.
 * - Siblings at every level are sorted deterministically by `Sequence ASC, Name ASC`.
 * - Assigns `WbsCode` (`"1"`, `"1.1"`, `"1.1.1"`), `Depth` (`0..N`), and rolled-up progress.
 */
export function BuildWbsTree<T extends TaskWbsNodeInput>(flatTasks: readonly T[]): TaskWbsNode<T>[] {
    if (!flatTasks || flatTasks.length === 0) {
        return [];
    }

    // Deduplicate by normalized ID (preserving first occurrence)
    const itemById = new Map<string, T>();
    for (const task of flatTasks) {
        const key = normalizeId(task.ID);
        if (!key || itemById.has(key)) continue;
        itemById.set(key, task);
    }

    // Detect cycles by walking parent chains from each node; break cycles cleanly at root
    const validParentKeyById = new Map<string, string | null>();
    for (const [key, item] of itemById) {
        const rawParentKey = normalizeId(item.ParentID);
        if (!rawParentKey || rawParentKey === key || !itemById.has(rawParentKey)) {
            validParentKeyById.set(key, null);
            continue;
        }
        // Walk up to ensure rawParentKey does not lead back to key
        const visited = new Set<string>([key]);
        let cur: string | null = rawParentKey;
        let hasCycle = false;
        while (cur) {
            if (visited.has(cur)) {
                hasCycle = true;
                break;
            }
            visited.add(cur);
            const parentItem = itemById.get(cur);
            const nextParent = normalizeId(parentItem?.ParentID);
            cur = nextParent && itemById.has(nextParent) ? nextParent : null;
        }
        validParentKeyById.set(key, hasCycle ? null : rawParentKey);
    }

    const childrenByParent = new Map<string, T[]>();
    const rootItems: T[] = [];

    for (const [key, item] of itemById) {
        const parentKey = validParentKeyById.get(key) ?? null;
        if (parentKey) {
            const list = childrenByParent.get(parentKey) ?? [];
            list.push(item);
            childrenByParent.set(parentKey, list);
        } else {
            rootItems.push(item);
        }
    }

    const buildNode = (item: T): TaskWbsNode<T> => {
        const key = normalizeId(item.ID);
        const childItems = [...(childrenByParent.get(key) ?? [])].sort(compareTasks);
        return {
            Item: item,
            WbsCode: '',
            Depth: 0,
            Children: childItems.map(buildNode),
            EffectivePercentComplete: 0,
            TotalDescendantCount: 0,
            CompletedDescendantCount: 0,
        };
    };

    const sortedRoots = [...rootItems].sort(compareTasks).map(buildNode);
    return AssignWbsCodes(sortedRoots);
}

/**
 * Assigns hierarchical `WbsCode` (`"1"`, `"1.1"`, `"1.1.1"`), `Depth` (`0..N`),
 * descendant counts, and rolled-up `EffectivePercentComplete` across a WBS forest.
 *
 * Pure function — returns a new tree without mutating the caller's nodes.
 * When a parent node's own `Item.PercentComplete` is `null` or `undefined` and it has
 * children, `EffectivePercentComplete` rolls up to the rounded average of its children's
 * `EffectivePercentComplete`.
 */
export function AssignWbsCodes<T extends TaskWbsNodeInput>(roots: readonly TaskWbsNode<T>[]): TaskWbsNode<T>[] {
    const assign = (nodes: readonly TaskWbsNode<T>[], prefix: string, depth: number): TaskWbsNode<T>[] => {
        return nodes.map((node, index) => {
            const code = prefix ? `${prefix}.${index + 1}` : `${index + 1}`;
            const assignedChildren = assign(node.Children ?? [], code, depth + 1);

            let totalDescendants = 0;
            let completedDescendants = 0;
            for (const child of assignedChildren) {
                totalDescendants += 1 + child.TotalDescendantCount;
                completedDescendants += (isCompletedStatus(child.Item.Status) ? 1 : 0) + child.CompletedDescendantCount;
            }

            let effectivePct: number;
            if (node.Item.PercentComplete != null) {
                effectivePct = clampPercent(node.Item.PercentComplete);
            } else if (assignedChildren.length > 0) {
                const sum = assignedChildren.reduce((acc, child) => acc + child.EffectivePercentComplete, 0);
                effectivePct = clampPercent(sum / assignedChildren.length);
            } else {
                effectivePct = isCompletedStatus(node.Item.Status) ? 100 : 0;
            }

            return {
                Item: node.Item,
                WbsCode: code,
                Depth: depth,
                Children: assignedChildren,
                EffectivePercentComplete: effectivePct,
                TotalDescendantCount: totalDescendants,
                CompletedDescendantCount: completedDescendants,
            };
        });
    };

    return assign(roots ?? [], '', 0);
}

/**
 * Computes aggregate KPI summary metrics across all nodes in a WBS forest.
 */
export function ComputeWbsSummary<T extends TaskWbsNodeInput>(
    roots: readonly TaskWbsNode<T>[],
    now: Date = new Date(),
): TaskWbsSummaryMetrics {
    let totalCount = 0;
    let completedCount = 0;
    let inProgressCount = 0;
    let blockedCount = 0;
    let openCount = 0;
    let overdueCount = 0;
    let percentSum = 0;

    const nowMs = now.getTime();
    const visited = new Set<string>();

    const walk = (nodes: readonly TaskWbsNode<T>[]): void => {
        for (const node of nodes) {
            const key = normalizeId(node.Item.ID);
            if (key && visited.has(key)) continue;
            if (key) visited.add(key);

            totalCount++;
            const status = node.Item.Status;
            const isCompleted = isCompletedStatus(status);
            const isCancelled = isCancelledStatus(status);
            const isActive = !isCompleted && !isCancelled;

            if (isCompleted) {
                completedCount++;
            } else if (isBlockedStatus(status)) {
                blockedCount++;
            } else if (isInProgressStatus(status)) {
                inProgressCount++;
            } else if (!isCancelled) {
                openCount++;
            }

            if (isActive) {
                const due = parseDate(node.Item.DueAt ?? node.Item.DueDate);
                if (due != null && due.getTime() < nowMs) {
                    overdueCount++;
                }
            }

            const pct =
                node.EffectivePercentComplete != null && Number.isFinite(node.EffectivePercentComplete)
                    ? clampPercent(node.EffectivePercentComplete)
                    : node.Item.PercentComplete != null
                      ? clampPercent(node.Item.PercentComplete)
                      : isCompleted
                        ? 100
                        : 0;
            percentSum += pct;

            if (node.Children && node.Children.length > 0) {
                walk(node.Children);
            }
        }
    };

    walk(roots ?? []);

    return {
        TotalCount: totalCount,
        CompletedCount: completedCount,
        InProgressCount: inProgressCount,
        BlockedCount: blockedCount,
        OpenCount: openCount,
        OverdueCount: overdueCount,
        OverallCompletionPercent: totalCount === 0 ? 0 : clampPercent(percentSum / totalCount),
    };
}

/**
 * Filters a WBS forest while preserving the entire ancestor chain of every matching node.
 *
 * Preserves each retained node's original `WbsCode` and `Depth` so filtered views keep
 * stable hierarchical references. Pure function — never mutates caller nodes.
 */
export function FilterWbsTreePreservingAncestors<T extends TaskWbsNodeInput>(
    roots: readonly TaskWbsNode<T>[],
    predicate: (item: T, node: TaskWbsNode<T>) => boolean,
): TaskWbsNode<T>[] {
    const filterList = (nodes: readonly TaskWbsNode<T>[]): TaskWbsNode<T>[] => {
        const result: TaskWbsNode<T>[] = [];
        for (const node of nodes) {
            const filteredChildren = filterList(node.Children ?? []);
            const selfMatches = predicate(node.Item, node);
            if (selfMatches || filteredChildren.length > 0) {
                result.push({
                    ...node,
                    Children: filteredChildren,
                });
            }
        }
        return result;
    };

    return filterList(roots ?? []);
}

/**
 * Flattens a WBS forest into visible display rows respecting `collapsedIds`.
 *
 * Collapsing ANY ancestor hides ALL of its descendants (preventing orphaned grandchildren).
 * Matching against `collapsedIds` is case-insensitive so mixed-case UUIDs behave consistently.
 */
export function FlattenVisibleWbsNodes<T extends TaskWbsNodeInput>(
    roots: readonly TaskWbsNode<T>[],
    collapsedIds: ReadonlySet<string> = new Set<string>(),
    forceExpandAll = false,
): TaskWbsFlatRow<T>[] {
    const normalizedCollapsed = new Set<string>();
    if (!forceExpandAll && collapsedIds) {
        for (const id of collapsedIds) {
            const norm = normalizeId(id);
            if (norm) normalizedCollapsed.add(norm);
        }
    }

    const rows: TaskWbsFlatRow<T>[] = [];
    const walk = (nodes: readonly TaskWbsNode<T>[], ancestors: readonly string[]): void => {
        for (const node of nodes) {
            const hasChildren = (node.Children?.length ?? 0) > 0;
            const isCollapsed = hasChildren && !forceExpandAll && normalizedCollapsed.has(normalizeId(node.Item.ID));
            rows.push({
                Node: node,
                Item: node.Item,
                WbsCode: node.WbsCode,
                Depth: node.Depth,
                HasChildren: hasChildren,
                Expanded: !isCollapsed,
                AncestorIds: [...ancestors],
            });
            if (hasChildren && !isCollapsed) {
                walk(node.Children, [...ancestors, node.Item.ID]);
            }
        }
    };

    walk(roots ?? [], []);
    return rows;
}
