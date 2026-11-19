/**
 * What a workflow's Human step asks bizapps-tasks to raise, read from the step's
 * `providerConfiguration`. Pure: no database, so every rule here is unit-tested directly.
 *
 * Authoring keys (all optional except that the step must end up with someone to ask):
 *
 * | Key | Meaning |
 * |---|---|
 * | `taskType` | Task type `Code` or `Name`. Default `APPROVAL_REQUEST`. |
 * | `title` | Task name. Default: the step's name. |
 * | `priority` | `Low` / `Medium` / `High` / `Critical`. Default `High`. |
 * | `approverPersonIDs` | People to assign: an ID, a list, or `payload.<path>` holding either. |
 * | `assignees` | `[{ entity, recordID }]` for any assignee entity (People, `MJ: Users`, `MJ: Roles`); `recordID` may be `payload.<path>`. |
 * | `linkedRecord` | `{ entity, recordID }`: the record the decision is about, shown on the task. |
 * | `outputKey` | Payload key the decision is written under. Default `approval`. |
 *
 * Values use the workflow's mapping dialect: a string is a literal unless it starts with `payload.`.
 * When nothing names an assignee, the step's own `assignToUserID` is used.
 *
 * @module @mj-biz-apps/tasks-server
 */
import { ResolveMappedInput } from '@memberjunction/ai-core-plus';

/** The ClassFactory key the provider registers under; a Human step names it as `provider`. */
export const BIZAPPS_TASKS_PROVIDER_KEY = 'BizAppsTasks';
export const DEFAULT_WORKFLOW_TASK_TYPE = 'APPROVAL_REQUEST';
export const DEFAULT_WORKFLOW_OUTPUT_KEY = 'approval';
export const WORKFLOW_ASSIGNEE_PEOPLE_ENTITY = 'MJ_BizApps_Common: People';
export const WORKFLOW_ASSIGNEE_USERS_ENTITY = 'MJ: Users';

export type WorkflowTaskPriority = 'Low' | 'Medium' | 'High' | 'Critical';
const PRIORITIES: readonly WorkflowTaskPriority[] = ['Low', 'Medium', 'High', 'Critical'];

/** One record by entity name. */
export type WorkflowRecordRef = { EntityName: string; RecordID: string };

/** Everything needed to raise the task, with every `payload.` reference already resolved. */
export type WorkflowTaskRequest = {
    TaskType: string;
    Title: string;
    Description: string | null;
    Priority: WorkflowTaskPriority;
    DueAt: Date | null;
    Assignees: WorkflowRecordRef[];
    LinkedRecord: WorkflowRecordRef | null;
};

/** The parts of the provider's raise context this module reads. */
export type WorkflowTaskRequestInput = {
    Name: string;
    Instructions: string | null;
    DueAt: Date | null;
    AssignedUserID: string | null;
    ProviderConfiguration: Record<string, unknown>;
    Payload: Record<string, unknown>;
};

export type WorkflowTaskRequestResult = { Request: WorkflowTaskRequest } | { Error: string };

/** Builds the task request, or says which setting is wrong — in words the workflow's author can act on. */
export function ResolveWorkflowTaskRequest(input: WorkflowTaskRequestInput): WorkflowTaskRequestResult {
    const config = input.ProviderConfiguration ?? {};
    const payload = input.Payload ?? {};

    const priority = resolvePriority(config['priority']);
    if ('Error' in priority) return priority;
    const assignees = resolveAssignees(config, payload, input.AssignedUserID);
    if ('Error' in assignees) return assignees;
    const linked = resolveLinkedRecord(config['linkedRecord'], payload);
    if ('Error' in linked) return linked;

    const title = asText(resolve(config['title'], payload)) ?? input.Name;
    return {
        Request: {
            TaskType: asText(config['taskType']) ?? DEFAULT_WORKFLOW_TASK_TYPE,
            Title: title.trim() || input.Name,
            Description: input.Instructions,
            Priority: priority.Value,
            DueAt: input.DueAt,
            Assignees: assignees.Value,
            LinkedRecord: linked.Value,
        },
    };
}

/** The payload key a step's decision is written under. */
export function WorkflowOutputKey(providerConfiguration: Record<string, unknown> | undefined): string {
    return asText(providerConfiguration?.['outputKey']) ?? DEFAULT_WORKFLOW_OUTPUT_KEY;
}

type Resolved<T> = { Value: T } | { Error: string };

function resolve(value: unknown, payload: Record<string, unknown>): unknown {
    return ResolveMappedInput(value, { payload });
}

function asText(value: unknown): string | null {
    return typeof value === 'string' && value.trim() ? value.trim() : null;
}

function resolvePriority(raw: unknown): Resolved<WorkflowTaskPriority> {
    if (raw === undefined || raw === null || raw === '') return { Value: 'High' };
    const match = PRIORITIES.find((p) => typeof raw === 'string' && p.toLowerCase() === raw.trim().toLowerCase());
    return match ? { Value: match } : { Error: `priority must be one of ${PRIORITIES.join(', ')}, not "${String(raw)}".` };
}

/** Every assignee the step names, de-duplicated; the step's own assignee only when it names none. */
function resolveAssignees(
    config: Record<string, unknown>,
    payload: Record<string, unknown>,
    assignedUserID: string | null,
): Resolved<WorkflowRecordRef[]> {
    const fromPeople = idsFrom(resolve(config['approverPersonIDs'], payload), 'approverPersonIDs');
    if ('Error' in fromPeople) return fromPeople;
    const explicit = explicitAssignees(config['assignees'], payload);
    if ('Error' in explicit) return explicit;

    const all = [
        ...fromPeople.Value.map((id) => ({ EntityName: WORKFLOW_ASSIGNEE_PEOPLE_ENTITY, RecordID: id })),
        ...explicit.Value,
    ];
    if (all.length === 0 && assignedUserID) {
        all.push({ EntityName: WORKFLOW_ASSIGNEE_USERS_ENTITY, RecordID: assignedUserID });
    }
    if (all.length === 0) {
        return { Error: 'The step names no one to ask: set approverPersonIDs or assignees, or assign the step to a user.' };
    }
    return { Value: dedupe(all) };
}

function explicitAssignees(raw: unknown, payload: Record<string, unknown>): Resolved<WorkflowRecordRef[]> {
    if (raw === undefined || raw === null) return { Value: [] };
    if (!Array.isArray(raw)) return { Error: 'assignees must be a list of { entity, recordID }.' };
    const out: WorkflowRecordRef[] = [];
    for (const [index, item] of raw.entries()) {
        const entity = isRecord(item) ? asText(item['entity']) : null;
        if (!entity || !isRecord(item)) return { Error: `assignees[${index}] needs an entity and a recordID.` };
        const ids = idsFrom(resolve(item['recordID'], payload), `assignees[${index}].recordID`);
        if ('Error' in ids) return ids;
        if (ids.Value.length === 0) return { Error: `assignees[${index}].recordID resolved to nothing.` };
        out.push(...ids.Value.map((id) => ({ EntityName: entity, RecordID: id })));
    }
    return { Value: out };
}

function resolveLinkedRecord(raw: unknown, payload: Record<string, unknown>): Resolved<WorkflowRecordRef | null> {
    if (raw === undefined || raw === null) return { Value: null };
    const entity = isRecord(raw) ? asText(raw['entity']) : null;
    if (!entity || !isRecord(raw)) return { Error: 'linkedRecord needs an entity and a recordID.' };
    const id = resolve(raw['recordID'], payload);
    const recordID = typeof id === 'number' ? String(id) : asText(id);
    if (!recordID) return { Error: 'linkedRecord.recordID resolved to nothing.' };
    return { Value: { EntityName: entity, RecordID: recordID } };
}

/** An ID or a list of IDs; nothing at all resolves to an empty list. */
function idsFrom(value: unknown, label: string): Resolved<string[]> {
    if (value === undefined || value === null) return { Value: [] };
    const items = Array.isArray(value) ? value : [value];
    const ids: string[] = [];
    for (const item of items) {
        const id = typeof item === 'number' ? String(item) : asText(item);
        if (!id) return { Error: `${label} must hold IDs; found ${JSON.stringify(item)}.` };
        ids.push(id);
    }
    return { Value: ids };
}

function dedupe(refs: WorkflowRecordRef[]): WorkflowRecordRef[] {
    const seen = new Set<string>();
    return refs.filter((r) => {
        const key = `${r.EntityName.toLowerCase()}|${r.RecordID.toLowerCase()}`;
        if (seen.has(key)) return false;
        seen.add(key);
        return true;
    });
}

function isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === 'object' && value !== null && !Array.isArray(value);
}
