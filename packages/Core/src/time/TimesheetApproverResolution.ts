/**
 * Pure timesheet approver resolution, part grouping, deterministic SHA-256 snapshot hashing, and
 * status aggregation (§5.6, §6.5, §6.6, §11).
 *
 * Kept free of database and Node-only modules so it runs identically in Node.js and browser bundles
 * and can be unit-tested exhaustively without mocks.
 */
import { CompareDays, ToCalendarDay, type CalendarDay } from '@mj-biz-apps/common-entities';
import type {
    mjBizAppsTasksTimesheetApprovalEntity,
    mjBizAppsTasksTimesheetEntity,
} from '@mj-biz-apps/tasks-entities';
import type { TimesheetApprovalRoutingMode } from '../config/TasksSettings.js';

/** Status union for a `TimesheetApproval` part. */
export type TimesheetPartStatus = mjBizAppsTasksTimesheetApprovalEntity['Status'];

/** Status union for a `Timesheet` header. */
export type TimesheetHeaderStatus = mjBizAppsTasksTimesheetEntity['Status'];

/** One task node in a task hierarchy used to build an entry's ancestor chain. */
export interface TaskHierarchyNode {
    ID: string;
    Name: string;
    ParentID: string | null;
    RootParentID?: string | null;
}

/** One external scope record supplied by a `BaseTimeApproverResolver` or `TaskLink`. */
export interface ExternalScopeRecordFact {
    ScopeEntityID: string;
    ScopeRecordID: string;
    ScopeLabel: string;
    /** Resolver priority (lower number = higher priority / nearer in chain). Default `100`. */
    Priority?: number;
}

/** One `TimeApprover` directory rule. */
export interface TimeApproverRuleFact {
    ID?: string;
    ApproverPersonID: string;
    WorkerPersonID?: string | null;
    ScopeTaskID?: string | null;
    IncludeDescendants?: boolean;
    ScopeEntityID?: string | null;
    ScopeRecordID?: string | null;
    EffectiveFrom?: CalendarDay | Date | null;
    EffectiveTo?: CalendarDay | Date | null;
    IsActive?: boolean;
}

/** One `TaskTimeEntry` row to be grouped into a timesheet approval part. */
export interface TimesheetEntryFact {
    ID: string;
    TaskID: string;
    TaskName?: string;
    WorkDate: CalendarDay | Date;
    Minutes: number;
    IsBillable: boolean;
    Notes?: string | null;
}

/** Complete batch of facts gathered by the server before calling {@link ResolveApprovers} / {@link GroupIntoParts}. */
export interface ApproverResolutionContext {
    /** The person submitting the timesheet (`Timesheet.PersonID`). */
    SubmitterPersonID: string;
    /** Display name of the submitter (used for fallback scope labels). */
    SubmitterPersonName?: string | null;
    /** Reference date (`YYYY-MM-DD`, typically `PeriodEnd`) used when checking rule effective dates if an entry has no date. */
    ReferenceDate?: CalendarDay | Date | null;
    /** Entity ID of `MJ_BizApps_Tasks: Tasks` (optional, for matching polymorphic `TimeApprover` rows scoped to Tasks). */
    TasksEntityID?: string | null;
    /** Entity ID of `MJ_BizApps_Common: People` (optional, for matching polymorphic `TimeApprover` rows scoped to People). */
    PeopleEntityID?: string | null;
    /** Map or list of tasks covering the entries' tasks and their ancestors up to each root task. */
    Tasks: ReadonlyMap<string, TaskHierarchyNode> | readonly TaskHierarchyNode[];
    /**
     * Optional map of `RootTaskID` (lowercased) -> ordered external scope records returned by
     * registered `BaseTimeApproverResolver` subclasses or `TaskLink`s.
     */
    ResolverScopesByRootTaskID?: ReadonlyMap<string, readonly ExternalScopeRecordFact[]>;
    /** Active `TimeApprover` rows. */
    ApproverRules: readonly TimeApproverRuleFact[];
    /** Active fallback approver `PersonID`s from `TimesheetApproverRelationshipType` (`FromPersonID = SubmitterPersonID`). */
    FallbackRelationshipApproverPersonIDs?: readonly string[];
    /** Active fallback approver `PersonID`s from `TimesheetApproverRole`. */
    FallbackRoleApproverPersonIDs?: readonly string[];
}

/** Result of resolving approvers for a single time entry or task (§6.6). */
export interface ResolvedEntryApprovers {
    /** Unique Key identifying the winning part scope. */
    PartKey: string;
    /** Winning `ScopeTaskID` when the scope is a task in the task hierarchy (or `null` for resolver/person fallback scopes). */
    ScopeTaskID: string | null;
    /** Winning polymorphic `ScopeEntityID` when known. */
    ScopeEntityID: string | null;
    /** Winning polymorphic `ScopeRecordID` when known. */
    ScopeRecordID: string | null;
    /** Display label of the winning scope (e.g. root project task name, space name, or `"{Person}'s approver"`). */
    ScopeLabel: string;
    /** Deduplicated, sorted list of approver `PersonID`s (excluding the submitter). */
    ApproverPersonIDs: string[];
    /** Which tier of the scope chain produced the approvers. */
    ResolutionSource: 'TaskChain' | 'ResolverScope' | 'PersonRule' | 'RelationshipFallback' | 'RoleFallback' | 'AutoApprove' | 'Unresolved';
    /** Refusal message when `ApproverPersonIDs` is empty and routing is not `'AutoApprove'`. */
    RefusalMessage: string | null;
}

/** One grouped approval part produced by {@link GroupIntoParts}. */
export interface GroupedTimesheetPart {
    PartKey: string;
    ScopeTaskID: string | null;
    ScopeEntityID: string | null;
    ScopeRecordID: string | null;
    ScopeLabel: string;
    ApproverPersonIDs: string[];
    Entries: TimesheetEntryFact[];
    Minutes: number;
    BillableMinutes: number;
    EntryCount: number;
    SnapshotHash: string;
}

/** Result of {@link GroupIntoParts}. */
export interface GroupIntoPartsResult {
    Parts: GroupedTimesheetPart[];
    UnresolvedTaskNames: string[];
    RefusalMessage: string | null;
}

const norm = (id: string | null | undefined): string => (id ?? '').trim().toLowerCase();
const sameId = (a: string | null | undefined, b: string | null | undefined): boolean =>
    !!a && !!b && norm(a) === norm(b);

function toTaskMap(tasks: ReadonlyMap<string, TaskHierarchyNode> | readonly TaskHierarchyNode[]): Map<string, TaskHierarchyNode> {
    const map = new Map<string, TaskHierarchyNode>();
    if (Array.isArray(tasks)) {
        for (const t of tasks) {
            map.set(norm(t.ID), t);
        }
    } else {
        for (const [k, v] of (tasks as ReadonlyMap<string, TaskHierarchyNode>).entries()) {
            map.set(norm(k), v);
            map.set(norm(v.ID), v);
        }
    }
    return map;
}

/**
 * Builds the task ancestor chain `[entryTask, parentTask, ..., rootTask]` (nearest first).
 */
export function BuildTaskAncestorChain(
    taskID: string,
    taskMap: ReadonlyMap<string, TaskHierarchyNode>,
): TaskHierarchyNode[] {
    const chain: TaskHierarchyNode[] = [];
    const visited = new Set<string>();
    let cursor = norm(taskID);

    while (cursor && !visited.has(cursor)) {
        visited.add(cursor);
        const node = taskMap.get(cursor);
        if (!node) break;
        chain.push(node);
        cursor = norm(node.ParentID);
    }

    if (chain.length === 0) {
        chain.push({ ID: taskID, Name: taskID, ParentID: null, RootParentID: taskID });
    }
    return chain;
}

function isRuleEffectiveOn(rule: TimeApproverRuleFact, dateDay: CalendarDay | null): boolean {
    if (rule.IsActive === false) return false;
    if (!dateDay) return true;
    if (rule.EffectiveFrom != null) {
        const from = ToCalendarDay(rule.EffectiveFrom);
        if (from && CompareDays(from, dateDay) > 0) return false;
    }
    if (rule.EffectiveTo != null) {
        const to = ToCalendarDay(rule.EffectiveTo);
        if (to && CompareDays(to, dateDay) < 0) return false;
    }
    return true;
}

function ruleMatchesWorker(rule: TimeApproverRuleFact, submitterPersonID: string): boolean {
    if (!rule.WorkerPersonID) return true;
    return sameId(rule.WorkerPersonID, submitterPersonID);
}

/**
 * Filters a candidate list of approver `PersonID`s by removing the submitter and deduplicating case-insensitively.
 */
export function ExcludeSubmitterAndDedupe(
    candidatePersonIDs: readonly string[],
    submitterPersonID: string,
): string[] {
    const seen = new Set<string>();
    const result: string[] = [];
    const subNorm = norm(submitterPersonID);

    for (const rawId of candidatePersonIDs) {
        const trimmed = rawId?.trim();
        if (!trimmed) continue;
        const n = trimmed.toLowerCase();
        if (n === subNorm || seen.has(n)) continue;
        seen.add(n);
        result.push(trimmed);
    }

    return result.sort((a, b) => a.toLowerCase().localeCompare(b.toLowerCase()));
}

/**
 * Resolves the winning scope and approver `PersonID`s for a single task/date under `context` (§6.6).
 *
 * Scope chain order (nearest first):
 * 1. Task chain from `taskID` up to its root task (`ScopeTaskID` or `ScopeEntityID = TasksEntityID`).
 * 2. Registered `BaseTimeApproverResolver` scope records for the root task (in priority order).
 * 3. Submitter's People record / worker-scoped `TimeApprover` rules.
 * 4. Fallback `TimesheetApproverRelationshipType` (`FromPersonID = SubmitterPersonID`).
 * 5. Fallback `TimesheetApproverRole`.
 *
 * At every step, `SubmitterPersonID` is removed so nobody can ever be assigned to approve their own time.
 */
export function ResolveApprovers(
    entry: { TaskID: string; TaskName?: string; WorkDate?: CalendarDay | Date | null },
    context: ApproverResolutionContext,
): ResolvedEntryApprovers {
    const taskMap = toTaskMap(context.Tasks);
    const chain = BuildTaskAncestorChain(entry.TaskID, taskMap);
    const entryTask = chain[0];
    const rootTask = chain[chain.length - 1];
    const taskDisplayName = entry.TaskName?.trim() || entryTask?.Name || entry.TaskID;
    const submitterLabel = context.SubmitterPersonName?.trim()
        ? `${context.SubmitterPersonName.trim()}'s approver`
        : 'Personal time approver';

    const workDay =
        (entry.WorkDate ? ToCalendarDay(entry.WorkDate) : null) ??
        (context.ReferenceDate ? ToCalendarDay(context.ReferenceDate) : null);

    const activeRules = context.ApproverRules.filter(
        (r) => isRuleEffectiveOn(r, workDay) && ruleMatchesWorker(r, context.SubmitterPersonID),
    );

    // 1. Walk the task chain from the entry's task up to the root task (nearest first)
    for (let depth = 0; depth < chain.length; depth++) {
        const node = chain[depth];
        const matchingTaskRules = activeRules.filter((r) => {
            const matchesScopeTask = sameId(r.ScopeTaskID, node.ID);
            const matchesPolyTask =
                !r.ScopeTaskID &&
                context.TasksEntityID != null &&
                sameId(r.ScopeEntityID, context.TasksEntityID) &&
                sameId(r.ScopeRecordID, node.ID);
            if (!matchesScopeTask && !matchesPolyTask) return false;
            if (depth > 0 && r.IncludeDescendants === false) return false;
            return true;
        });

        // If worker-specific rules exist on this task node, prefer them over generic task rules;
        // if all worker-specific rules self-exclude, fall back to generic rules on the same node.
        const workerSpecificOnTask = matchingTaskRules.filter((r) => sameId(r.WorkerPersonID, context.SubmitterPersonID));
        const specificApprovers = ExcludeSubmitterAndDedupe(
            workerSpecificOnTask.map((r) => r.ApproverPersonID),
            context.SubmitterPersonID,
        );
        const allNodeApprovers =
            specificApprovers.length > 0
                ? specificApprovers
                : ExcludeSubmitterAndDedupe(
                      matchingTaskRules.map((r) => r.ApproverPersonID),
                      context.SubmitterPersonID,
                  );

        if (allNodeApprovers.length > 0) {
            return {
                PartKey: `task:${norm(node.ID)}`,
                ScopeTaskID: node.ID,
                ScopeEntityID: context.TasksEntityID ?? null,
                ScopeRecordID: node.ID,
                ScopeLabel: node.Name || taskDisplayName,
                ApproverPersonIDs: allNodeApprovers,
                ResolutionSource: 'TaskChain',
                RefusalMessage: null,
            };
        }
    }

    // 2. Walk external resolver scope records for the root task (ordered by Priority ASC, then array order)
    const resolverScopes =
        context.ResolverScopesByRootTaskID?.get(norm(rootTask.ID)) ??
        context.ResolverScopesByRootTaskID?.get(rootTask.ID) ??
        [];
    const orderedScopes = [...resolverScopes].sort((a, b) => (a.Priority ?? 100) - (b.Priority ?? 100));

    for (const scope of orderedScopes) {
        const scopeRules = activeRules.filter(
            (r) => sameId(r.ScopeEntityID, scope.ScopeEntityID) && sameId(r.ScopeRecordID, scope.ScopeRecordID),
        );
        const approvers = ExcludeSubmitterAndDedupe(
            scopeRules.map((r) => r.ApproverPersonID),
            context.SubmitterPersonID,
        );
        if (approvers.length > 0) {
            return {
                PartKey: `scope:${norm(scope.ScopeEntityID)}:${norm(scope.ScopeRecordID)}`,
                ScopeTaskID: rootTask.ID,
                ScopeEntityID: scope.ScopeEntityID,
                ScopeRecordID: scope.ScopeRecordID,
                ScopeLabel: scope.ScopeLabel,
                ApproverPersonIDs: approvers,
                ResolutionSource: 'ResolverScope',
                RefusalMessage: null,
            };
        }
    }

    // 3. Submitter's People record / worker-level TimeApprover rules (and global catch-all rules)
    const workerRules = activeRules.filter((r) => {
        const isExplicitWorkerRule =
            !r.ScopeTaskID &&
            !r.ScopeEntityID &&
            sameId(r.WorkerPersonID, context.SubmitterPersonID);
        const isPolyPeopleRule =
            !r.ScopeTaskID &&
            context.PeopleEntityID != null &&
            sameId(r.ScopeEntityID, context.PeopleEntityID) &&
            sameId(r.ScopeRecordID, context.SubmitterPersonID);
        return isExplicitWorkerRule || isPolyPeopleRule;
    });
    const workerApprovers = ExcludeSubmitterAndDedupe(
        workerRules.map((r) => r.ApproverPersonID),
        context.SubmitterPersonID,
    );
    if (workerApprovers.length > 0) {
        return {
            PartKey: `person:${norm(context.SubmitterPersonID)}`,
            ScopeTaskID: null,
            ScopeEntityID: context.PeopleEntityID ?? null,
            ScopeRecordID: context.SubmitterPersonID,
            ScopeLabel: submitterLabel,
            ApproverPersonIDs: workerApprovers,
            ResolutionSource: 'PersonRule',
            RefusalMessage: null,
        };
    }

    // Global catch-all TimeApprover rules (WorkerPersonID IS NULL, ScopeTaskID IS NULL, ScopeEntityID IS NULL)
    const globalRules = activeRules.filter((r) => !r.WorkerPersonID && !r.ScopeTaskID && !r.ScopeEntityID);
    const globalApprovers = ExcludeSubmitterAndDedupe(
        globalRules.map((r) => r.ApproverPersonID),
        context.SubmitterPersonID,
    );
    if (globalApprovers.length > 0) {
        return {
            PartKey: `person:${norm(context.SubmitterPersonID)}`,
            ScopeTaskID: null,
            ScopeEntityID: context.PeopleEntityID ?? null,
            ScopeRecordID: context.SubmitterPersonID,
            ScopeLabel: submitterLabel,
            ApproverPersonIDs: globalApprovers,
            ResolutionSource: 'PersonRule',
            RefusalMessage: null,
        };
    }

    // 4. Fallback 1: TimesheetApproverRelationshipType
    const relApprovers = ExcludeSubmitterAndDedupe(
        context.FallbackRelationshipApproverPersonIDs ?? [],
        context.SubmitterPersonID,
    );
    if (relApprovers.length > 0) {
        return {
            PartKey: `person:${norm(context.SubmitterPersonID)}`,
            ScopeTaskID: null,
            ScopeEntityID: context.PeopleEntityID ?? null,
            ScopeRecordID: context.SubmitterPersonID,
            ScopeLabel: submitterLabel,
            ApproverPersonIDs: relApprovers,
            ResolutionSource: 'RelationshipFallback',
            RefusalMessage: null,
        };
    }

    // 5. Fallback 2: TimesheetApproverRole
    const roleApprovers = ExcludeSubmitterAndDedupe(
        context.FallbackRoleApproverPersonIDs ?? [],
        context.SubmitterPersonID,
    );
    if (roleApprovers.length > 0) {
        return {
            PartKey: `person:${norm(context.SubmitterPersonID)}`,
            ScopeTaskID: null,
            ScopeEntityID: context.PeopleEntityID ?? null,
            ScopeRecordID: context.SubmitterPersonID,
            ScopeLabel: submitterLabel,
            ApproverPersonIDs: roleApprovers,
            ResolutionSource: 'RoleFallback',
            RefusalMessage: null,
        };
    }

    // 6. None found -> refuse naming the task (§6.6)
    return {
        PartKey: `unresolved:${norm(entry.TaskID)}`,
        ScopeTaskID: rootTask.ID,
        ScopeEntityID: context.TasksEntityID ?? null,
        ScopeRecordID: rootTask.ID,
        ScopeLabel: taskDisplayName,
        ApproverPersonIDs: [],
        ResolutionSource: 'Unresolved',
        RefusalMessage: `No approver for time on ${taskDisplayName}. Name approvers on its project, or set TimesheetApproverRelationshipType or TimesheetApproverRole for the Tasks app.`,
    };
}

// ============================================================================
// Pure TypeScript SHA-256 implementation (portable across Node & Browser)
// ============================================================================

const SHA256_K = new Uint32Array([
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
]);

function rotr(n: number, x: number): number {
    return (x >>> n) | (x << (32 - n));
}

function sha256Hex(asciiOrUtf8: string): string {
    const utf8 = new TextEncoder().encode(asciiOrUtf8);
    const bitLen = utf8.length * 8;
    const totalLen = Math.ceil((utf8.length + 9) / 64) * 64;
    const padded = new Uint8Array(totalLen);
    padded.set(utf8);
    padded[utf8.length] = 0x80;

    const view = new DataView(padded.buffer);
    const highBits = Math.floor(bitLen / 0x100000000);
    const lowBits = bitLen >>> 0;
    view.setUint32(totalLen - 8, highBits, false);
    view.setUint32(totalLen - 4, lowBits, false);

    let h0 = 0x6a09e667;
    let h1 = 0xbb67ae85;
    let h2 = 0x3c6ef372;
    let h3 = 0xa54ff53a;
    let h4 = 0x510e527f;
    let h5 = 0x9b05688c;
    let h6 = 0x1f83d9ab;
    let h7 = 0x5be0cd19;

    const w = new Uint32Array(64);

    for (let offset = 0; offset < totalLen; offset += 64) {
        for (let i = 0; i < 16; i++) {
            w[i] = view.getUint32(offset + i * 4, false);
        }
        for (let i = 16; i < 64; i++) {
            const s0 = rotr(7, w[i - 15]) ^ rotr(18, w[i - 15]) ^ (w[i - 15] >>> 3);
            const s1 = rotr(17, w[i - 2]) ^ rotr(19, w[i - 2]) ^ (w[i - 2] >>> 10);
            w[i] = (w[i - 16] + s0 + w[i - 7] + s1) >>> 0;
        }

        let a = h0;
        let b = h1;
        let c = h2;
        let d = h3;
        let e = h4;
        let f = h5;
        let g = h6;
        let h = h7;

        for (let i = 0; i < 64; i++) {
            const S1 = rotr(6, e) ^ rotr(11, e) ^ rotr(25, e);
            const ch = (e & f) ^ (~e & g);
            const temp1 = (h + S1 + ch + SHA256_K[i] + w[i]) >>> 0;
            const S0 = rotr(2, a) ^ rotr(13, a) ^ rotr(22, a);
            const maj = (a & b) ^ (a & c) ^ (b & c);
            const temp2 = (S0 + maj) >>> 0;

            h = g;
            g = f;
            f = e;
            e = (d + temp1) >>> 0;
            d = c;
            c = b;
            b = a;
            a = (temp1 + temp2) >>> 0;
        }

        h0 = (h0 + a) >>> 0;
        h1 = (h1 + b) >>> 0;
        h2 = (h2 + c) >>> 0;
        h3 = (h3 + d) >>> 0;
        h4 = (h4 + e) >>> 0;
        h5 = (h5 + f) >>> 0;
        h6 = (h6 + g) >>> 0;
        h7 = (h7 + h) >>> 0;
    }

    return [h0, h1, h2, h3, h4, h5, h6, h7].map((v) => v.toString(16).padStart(8, '0')).join('');
}

/**
 * Computes a deterministic 64-character SHA-256 hex digest over a part's time entries (§5.6, §11).
 *
 * The canonical payload includes each entry's normalized `ID`, `TaskID`, `WorkDate`, `Minutes`,
 * `IsBillable`, and trimmed `Notes`, sorted deterministically so insertion order never alters the hash.
 */
export function PartSnapshotHash(entries: readonly TimesheetEntryFact[]): string {
    if (entries.length === 0) {
        return sha256Hex('empty');
    }
    const canonicalRows = entries
        .map((e) => {
            const id = norm(e.ID);
            const taskId = norm(e.TaskID);
            const workDate = ToCalendarDay(e.WorkDate) ?? String(e.WorkDate);
            const mins = Math.round(e.Minutes);
            const billable = e.IsBillable ? '1' : '0';
            const notes = (e.Notes ?? '').trim();
            return `${id}|${taskId}|${workDate}|${mins}|${billable}|${notes}`;
        })
        .sort();

    return sha256Hex(canonicalRows.join('\n'));
}

/**
 * Groups a timesheet period's entries into approval parts according to `routingMode` and resolves
 * each part's approvers (§6.5, §6.6).
 */
export function GroupIntoParts(
    entries: readonly TimesheetEntryFact[],
    context: ApproverResolutionContext,
    routingMode: TimesheetApprovalRoutingMode = 'ProjectApproval',
): GroupIntoPartsResult {
    if (routingMode === 'AutoApprove') {
        const totalMinutes = entries.reduce((sum, e) => sum + e.Minutes, 0);
        const billableMinutes = entries.reduce((sum, e) => sum + (e.IsBillable ? e.Minutes : 0), 0);
        return {
            Parts:
                entries.length === 0
                    ? []
                    : [
                          {
                              PartKey: `auto:${norm(context.SubmitterPersonID)}`,
                              ScopeTaskID: null,
                              ScopeEntityID: context.PeopleEntityID ?? null,
                              ScopeRecordID: context.SubmitterPersonID,
                              ScopeLabel: context.SubmitterPersonName?.trim() || 'Auto-approved timesheet',
                              ApproverPersonIDs: [],
                              Entries: [...entries],
                              Minutes: totalMinutes,
                              BillableMinutes: billableMinutes,
                              EntryCount: entries.length,
                              SnapshotHash: PartSnapshotHash(entries),
                          },
                      ],
            UnresolvedTaskNames: [],
            RefusalMessage: null,
        };
    }

    // Handle zero-entry period submission (Q6: confirms no time was worked)
    if (entries.length === 0) {
        const zeroEntryResolution = ResolveApprovers(
            {
                TaskID: context.SubmitterPersonID,
                TaskName: context.SubmitterPersonName?.trim() || 'Timesheet',
                WorkDate: context.ReferenceDate ?? null,
            },
            context,
        );
        if (zeroEntryResolution.ApproverPersonIDs.length === 0) {
            return {
                Parts: [],
                UnresolvedTaskNames: [context.SubmitterPersonName?.trim() || 'Timesheet'],
                RefusalMessage: zeroEntryResolution.RefusalMessage,
            };
        }
        return {
            Parts: [
                {
                    PartKey: zeroEntryResolution.PartKey,
                    ScopeTaskID: null,
                    ScopeEntityID: zeroEntryResolution.ScopeEntityID,
                    ScopeRecordID: zeroEntryResolution.ScopeRecordID,
                    ScopeLabel: zeroEntryResolution.ScopeLabel,
                    ApproverPersonIDs: zeroEntryResolution.ApproverPersonIDs,
                    Entries: [],
                    Minutes: 0,
                    BillableMinutes: 0,
                    EntryCount: 0,
                    SnapshotHash: PartSnapshotHash([]),
                },
            ],
            UnresolvedTaskNames: [],
            RefusalMessage: null,
        };
    }

    if (routingMode === 'SingleApproval') {
        const allApprovers = new Set<string>();
        const unresolvedTasks: string[] = [];
        let firstRefusal: string | null = null;

        for (const entry of entries) {
            const resolved = ResolveApprovers(entry, context);
            if (resolved.ApproverPersonIDs.length === 0) {
                const name = entry.TaskName?.trim() || resolved.ScopeLabel;
                if (!unresolvedTasks.includes(name)) unresolvedTasks.push(name);
                if (!firstRefusal) firstRefusal = resolved.RefusalMessage;
            } else {
                for (const a of resolved.ApproverPersonIDs) {
                    allApprovers.add(a);
                }
            }
        }

        if (unresolvedTasks.length > 0) {
            return {
                Parts: [],
                UnresolvedTaskNames: unresolvedTasks,
                RefusalMessage: firstRefusal,
            };
        }

        const dedupedApprovers = ExcludeSubmitterAndDedupe([...allApprovers], context.SubmitterPersonID);
        const totalMinutes = entries.reduce((sum, e) => sum + e.Minutes, 0);
        const billableMinutes = entries.reduce((sum, e) => sum + (e.IsBillable ? e.Minutes : 0), 0);
        const label = context.SubmitterPersonName?.trim()
            ? `${context.SubmitterPersonName.trim()}'s timesheet`
            : 'Whole timesheet';

        return {
            Parts: [
                {
                    PartKey: `person:${norm(context.SubmitterPersonID)}`,
                    ScopeTaskID: null,
                    ScopeEntityID: context.PeopleEntityID ?? null,
                    ScopeRecordID: context.SubmitterPersonID,
                    ScopeLabel: label,
                    ApproverPersonIDs: dedupedApprovers,
                    Entries: [...entries],
                    Minutes: totalMinutes,
                    BillableMinutes: billableMinutes,
                    EntryCount: entries.length,
                    SnapshotHash: PartSnapshotHash(entries),
                },
            ],
            UnresolvedTaskNames: [],
            RefusalMessage: null,
        };
    }

    // ProjectApproval: group entries by their resolved part scope
    const partMap = new Map<
        string,
        {
            ScopeTaskID: string | null;
            ScopeEntityID: string | null;
            ScopeRecordID: string | null;
            ScopeLabel: string;
            Approvers: Set<string>;
            Entries: TimesheetEntryFact[];
        }
    >();
    const unresolvedTasks: string[] = [];
    let firstRefusal: string | null = null;

    for (const entry of entries) {
        const resolved = ResolveApprovers(entry, context);
        if (resolved.ApproverPersonIDs.length === 0) {
            const name = entry.TaskName?.trim() || resolved.ScopeLabel;
            if (!unresolvedTasks.includes(name)) unresolvedTasks.push(name);
            if (!firstRefusal) firstRefusal = resolved.RefusalMessage;
            continue;
        }

        let bucket = partMap.get(resolved.PartKey);
        if (!bucket) {
            bucket = {
                ScopeTaskID: resolved.ScopeTaskID,
                ScopeEntityID: resolved.ScopeEntityID,
                ScopeRecordID: resolved.ScopeRecordID,
                ScopeLabel: resolved.ScopeLabel,
                Approvers: new Set<string>(),
                Entries: [],
            };
            partMap.set(resolved.PartKey, bucket);
        }
        for (const a of resolved.ApproverPersonIDs) {
            bucket.Approvers.add(a);
        }
        bucket.Entries.push(entry);
    }

    if (unresolvedTasks.length > 0) {
        return {
            Parts: [],
            UnresolvedTaskNames: unresolvedTasks,
            RefusalMessage: firstRefusal,
        };
    }

    const parts: GroupedTimesheetPart[] = [];
    for (const [partKey, bucket] of partMap.entries()) {
        const mins = bucket.Entries.reduce((sum, e) => sum + e.Minutes, 0);
        const billable = bucket.Entries.reduce((sum, e) => sum + (e.IsBillable ? e.Minutes : 0), 0);
        parts.push({
            PartKey: partKey,
            ScopeTaskID: bucket.ScopeTaskID,
            ScopeEntityID: bucket.ScopeEntityID,
            ScopeRecordID: bucket.ScopeRecordID,
            ScopeLabel: bucket.ScopeLabel,
            ApproverPersonIDs: ExcludeSubmitterAndDedupe([...bucket.Approvers], context.SubmitterPersonID),
            Entries: bucket.Entries,
            Minutes: mins,
            BillableMinutes: billable,
            EntryCount: bucket.Entries.length,
            SnapshotHash: PartSnapshotHash(bucket.Entries),
        });
    }

    parts.sort((a, b) => a.PartKey.localeCompare(b.PartKey));
    return {
        Parts: parts,
        UnresolvedTaskNames: [],
        RefusalMessage: null,
    };
}

/**
 * Computes the overall `Timesheet.Status` from its latest-round `TimesheetApproval` part statuses (§6.5).
 *
 * - Ignores `'Canceled'` parts unless every part is `'Canceled'` (in which case `'Draft'` is returned).
 * - If any active part is `'Rejected'`, the timesheet is `'Rejected'`.
 * - If all active parts are `'Approved'`, the timesheet is `'Approved'`.
 * - Otherwise (at least one part is `'Pending'`), the timesheet stays `'Submitted'`.
 */
export function TimesheetStatusFromParts(partStatuses: readonly TimesheetPartStatus[]): TimesheetHeaderStatus {
    const active = partStatuses.filter((s) => s !== 'Canceled');
    if (active.length === 0) {
        return 'Draft';
    }
    if (active.some((s) => s === 'Rejected')) {
        return 'Rejected';
    }
    if (active.every((s) => s === 'Approved')) {
        return 'Approved';
    }
    return 'Submitted';
}
