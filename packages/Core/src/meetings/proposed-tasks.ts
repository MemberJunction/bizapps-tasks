import { TasksLimitsResolver } from '../config/TasksLimits.js';

/**
 * The action items an AI note proposes from a meeting's transcript (the meetings plan, § 2.6 and § 8): kept as JSON on
 * `MeetingNote.ProposedTasks` until a person accepts or dismisses each one. Accepting files an `ACTION_ITEM` task and
 * records its `taskId` on the proposal; dismissing marks it `Dismissed` so it is never filed.
 */
export type ProposedTaskStatus = 'Pending' | 'Accepted' | 'Dismissed';

export interface ProposedTask {
    id: string;
    title: string;
    description: string | null;
    assigneePersonId: string | null;
    assigneeName: string | null;
    dueAt: string | null;
    agendaItemId: string | null;
    status: ProposedTaskStatus;
    taskId: string | null;
}

const VALID_STATUSES: ReadonlySet<string> = new Set<ProposedTaskStatus>(['Pending', 'Accepted', 'Dismissed']);

function isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function cleanString(value: unknown): string | null {
    if (value == null) return null;
    const trimmed = String(value).trim();
    return trimmed.length ? trimmed : null;
}

function readProposedTask(value: unknown, index: number): ProposedTask {
    if (!isRecord(value)) throw new Error(`Proposed task [${index}] is not an object.`);
    const title = cleanString(value.title);
    if (!title) throw new Error(`Proposed task [${index}] has no title.`);
    const id = cleanString(value.id) ?? `proposal-${index + 1}`;
    const rawStatus = cleanString(value.status) ?? 'Pending';
    if (!VALID_STATUSES.has(rawStatus)) {
        throw new Error(`Proposed task "${title}" has an invalid status "${rawStatus}".`);
    }
    const status = rawStatus as ProposedTaskStatus;
    const taskId = cleanString(value.taskId);
    if (status === 'Accepted' && !taskId) {
        throw new Error(`Proposed task "${title}" is marked Accepted without a taskId.`);
    }
    return {
        id,
        title,
        description: cleanString(value.description),
        assigneePersonId: cleanString(value.assigneePersonId),
        assigneeName: cleanString(value.assigneeName),
        dueAt: cleanString(value.dueAt),
        agendaItemId: cleanString(value.agendaItemId),
        status,
        taskId: status === 'Accepted' ? taskId : null,
    };
}

/**
 * Reads a note's proposed tasks from its JSON text, or an empty list when none are stored.
 * Accepts either a JSON array `[...]` or an object `{ items: [...] }` / `{ tasks: [...] }`.
 */
export function parseProposedTasks(json: string | null | undefined): ProposedTask[] {
    if (!json || !json.trim()) return [];
    let parsed: unknown;
    try {
        parsed = JSON.parse(json);
    } catch {
        throw new Error('The proposed tasks are not valid JSON.');
    }
    const list = Array.isArray(parsed)
        ? parsed
        : isRecord(parsed)
          ? (parsed.items ?? parsed.tasks ?? parsed.proposedTasks)
          : undefined;
    if (!Array.isArray(list)) {
        throw new Error('The proposed tasks must be a JSON array or an object with an "items" or "tasks" list.');
    }
    return list.map((entry, idx) => readProposedTask(entry, idx));
}

/** Serializes the proposed tasks back to JSON text for `MeetingNote.ProposedTasks`. */
export function serializeProposedTasks(tasks: readonly ProposedTask[]): string {
    return JSON.stringify(tasks);
}

/**
 * Marks one proposed task Accepted with the created task's ID (or an expiring `in-flight:<epochMs>` claim).
 * Refuses when the proposal is missing, already Dismissed, or already Accepted with a finalized task ID.
 */
export const PROPOSED_TASK_CLAIM_TTL_MS: number = TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.ProposedTaskClaimTtlMs;

export function isActiveProposedTaskClaim(taskId: string | null | undefined, nowMs: number = Date.now()): boolean {
    if (!taskId) return false;
    const trimmed = taskId.trim();
    if (trimmed === 'in-flight') return true;
    if (!trimmed.startsWith('in-flight:')) return false;
    const rest = trimmed.slice('in-flight:'.length);
    const colon = rest.indexOf(':');
    const claimedAtMs = Number(colon >= 0 ? rest.slice(0, colon) : rest);
    const claimTtlMs = TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.ProposedTaskClaimTtlMs;
    return Number.isFinite(claimedAtMs) && nowMs - claimedAtMs < claimTtlMs;
}

export function extractClaimedProposedTaskId(taskId: string | null | undefined): string | null {
    if (!taskId) return null;
    const trimmed = taskId.trim();
    if (!trimmed.startsWith('in-flight:')) return null;
    const rest = trimmed.slice('in-flight:'.length);
    const colon = rest.indexOf(':');
    if (colon < 0) return null;
    const candidate = rest.slice(colon + 1).trim();
    return candidate.length > 0 ? candidate : null;
}

/**
 * Parses a proposed or follow-up task due date.
 * Date-only strings (`YYYY-MM-DD`) are interpreted as 17:00 UTC on that calendar date
 * (matching `MeetingFollowUpsComponent`) so users in the Americas do not see the date shift a day early.
 */
export function parseDueDate(raw: Date | string | null | undefined): Date | null {
    if (!raw) return null;
    if (raw instanceof Date) return Number.isNaN(raw.getTime()) ? null : raw;
    const trimmed = raw.trim();
    if (!trimmed) return null;
    const dateOnly = /^(\d{4})-(\d{2})-(\d{2})$/.exec(trimmed);
    if (dateOnly) {
        return new Date(Date.UTC(Number(dateOnly[1]), Number(dateOnly[2]) - 1, Number(dateOnly[3]), 17, 0, 0));
    }
    const parsed = new Date(trimmed);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
}

export function isFinalizedProposedTaskId(taskId: string | null | undefined): boolean {
    if (!taskId) return false;
    const trimmed = taskId.trim();
    return trimmed.length > 0 && trimmed !== 'in-flight' && !trimmed.startsWith('in-flight:');
}

export function markProposedTaskAccepted(
    tasks: readonly ProposedTask[],
    proposalId: string,
    taskId: string,
): ProposedTask[] {
    const cleanTaskId = cleanString(taskId);
    if (!cleanTaskId) throw new Error('An accepted proposed task requires the created task ID.');
    const target = tasks.find((t) => t.id.toLowerCase() === proposalId.trim().toLowerCase());
    if (!target) throw new Error(`Proposed task "${proposalId}" was not found on this note.`);
    if (target.status === 'Dismissed') {
        throw new Error(`Proposed task "${target.title}" was already dismissed.`);
    }
    if (target.status === 'Accepted') {
        if (target.taskId?.toLowerCase() === cleanTaskId.toLowerCase()) return [...tasks];
        if (!isFinalizedProposedTaskId(target.taskId)) {
            return tasks.map((item) =>
                item.id.toLowerCase() === proposalId.trim().toLowerCase()
                    ? { ...item, status: 'Accepted', taskId: cleanTaskId }
                    : item,
            );
        }
        throw new Error(`Proposed task "${target.title}" was already accepted as task ${target.taskId}.`);
    }
    return tasks.map((item) =>
        item.id.toLowerCase() === proposalId.trim().toLowerCase()
            ? { ...item, status: 'Accepted', taskId: cleanTaskId }
            : item,
    );
}

/**
 * Marks one proposed task Dismissed.
 * Refuses when the proposal is missing or was already Accepted.
 */
export function markProposedTaskDismissed(tasks: readonly ProposedTask[], proposalId: string): ProposedTask[] {
    const target = tasks.find((t) => t.id.toLowerCase() === proposalId.trim().toLowerCase());
    if (!target) throw new Error(`Proposed task "${proposalId}" was not found on this note.`);
    if (target.status === 'Accepted') {
        throw new Error(`Proposed task "${target.title}" was already accepted as task ${target.taskId} and cannot be dismissed.`);
    }
    if (target.status === 'Dismissed') return [...tasks];
    return tasks.map((item) =>
        item.id.toLowerCase() === proposalId.trim().toLowerCase()
            ? { ...item, status: 'Dismissed', taskId: null }
            : item,
    );
}

