/**
 * Priorities and to-dos for the Chief of Staff, built from BizApps Tasks.
 *
 * MJ core's Chief of Staff knows nothing about Tasks. This app extends it: the "Priorities & To-dos"
 * page it adds to the Chief of Staff application (through a `NavItem.*` application setting) and the
 * Chief of Staff skill it grants both read tasks through these pure helpers.
 *
 * Who sees what: a person's scope is the tasks they created or are assigned to, plus the whole tree
 * of every root objective they own, plus the objective above any milestone they are assigned to.
 * On a card, the objective is shared context; its milestone list is the viewer's own unless they own
 * the objective.
 */
import type { RunViewParams, UserInfo } from '@memberjunction/core';
import { EscapeSQLString, UUIDsEqual } from '@memberjunction/global';

/**
 * A map keyed by record ID that ignores case: SQL Server returns upper-case UUIDs and PostgreSQL
 * lower-case, so the same ID can arrive in either spelling. (MJ 6.2 ships `UUIDMap` in
 * @memberjunction/global; this app still builds against 6.1.x, which does not have it.)
 */
export class TaskIDMap<T> {
    private readonly entries = new Map<string, T>();

    public Get(id: string | null | undefined): T | undefined {
        return id ? this.entries.get(id.toLowerCase()) : undefined;
    }

    public Set(id: string, value: T): void {
        this.entries.set(id.toLowerCase(), value);
    }

    public Has(id: string | null | undefined): boolean {
        return !!id && this.entries.has(id.toLowerCase());
    }

    public Delete(id: string | null | undefined): void {
        if (id) {
            this.entries.delete(id.toLowerCase());
        }
    }
}

/** A set of record IDs that ignores case (see {@link TaskIDMap}). */
export class TaskIDSet {
    private readonly ids = new TaskIDMap<true>();

    public Has(id: string | null | undefined): boolean {
        return this.ids.Has(id);
    }

    public Add(id: string): void {
        this.ids.Set(id, true);
    }

    public Delete(id: string | null | undefined): void {
        this.ids.Delete(id);
    }
}

/** Entity holding the people tasks are created by and assigned to. */
export const PEOPLE_ENTITY_NAME = 'MJ_BizApps_Common: People';
/** Entity linking tasks to their assignees (polymorphic `AssigneeEntityID` + `AssigneeRecordID`). */
export const TASK_ASSIGNMENTS_ENTITY_NAME = 'MJ_BizApps_Tasks: Task Assignments';
/** Entity holding objectives, milestones and to-dos. */
export const TASKS_ENTITY_NAME = 'MJ_BizApps_Tasks: Tasks';

export type TaskHealthStatus = 'OnTrack' | 'AtRisk' | 'OffTrack' | 'Completed' | 'Paused';
export type HealthFilter = 'all' | TaskHealthStatus;
export const HEALTH_FILTERS: readonly HealthFilter[] = ['all', 'OnTrack', 'AtRisk', 'OffTrack', 'Completed', 'Paused'];

/** The `MJ_BizApps_Tasks: Tasks` view columns these helpers read. */
export interface PriorityTaskRow {
    ID: string;
    ParentID: string | null;
    Name: string;
    Description: string | null;
    Status: string;
    Priority: string | null;
    /** Not a column on the Tasks view today; set by callers that know it. */
    IsPriority?: boolean | number | null;
    HealthStatus: TaskHealthStatus | null;
    ConfidenceScore: number | null;
    PercentComplete: number | null;
    CheckInCadence: string | null;
    PlanningPeriod: string | null;
    BaselineValue: number | null;
    TargetValue: number | null;
    CurrentValue: number | null;
    UnitOfMeasure: string | null;
    MetricDirection: string | null;
    DueAt: Date | string | null;
    LastCheckInAt: Date | string | null;
    NextCheckInDueAt: Date | string | null;
    TypeID?: string | null;
    Type?: string | null;
    TaskType?: string | null;
    /** The person who created the task; with the objective's assignees, decides who owns it. */
    CreatedByPersonID?: string | null;
    /** The creator's name, denormalized on the Tasks view. */
    CreatedByPerson?: string | null;
}

/** A person assigned to a task through `MJ_BizApps_Tasks: Task Assignments`. */
export interface TaskAssignee {
    PersonID: string;
    Name: string;
}

/** Assignees keyed by task ID (case-insensitive: SQL Server returns upper-case IDs, PostgreSQL lower-case). */
export type TaskAssigneeMap = TaskIDMap<TaskAssignee[]>;

/** A milestone row under an objective card, with who holds it. */
export interface MilestoneRowViewModel {
    Task: PriorityTaskRow;
    Assignees: TaskAssignee[];
    /** True when the current person is among the assignees. */
    AssignedToMe: boolean;
    /**
     * Who holds the milestone: its assignees when it has any; otherwise the person who created it, or
     * failing that the objective's owner. An unassigned milestone is the owner's own work, not a gap.
     */
    Holders: TaskAssignee[];
    /** True when `Holders` came from the creator or owner rather than an assignment row. */
    IsImplicitlyHeld: boolean;
    /** True when the current person is among `Holders`. */
    HeldByMe: boolean;
}

export interface PriorityObjectiveCardViewModel {
    Task: PriorityTaskRow;
    /** Every child task; progress counts them all. */
    Subtasks: PriorityTaskRow[];
    /** The milestone rows to render: every subtask for the objective's owner, only the ones the current person holds otherwise. */
    Milestones: MilestoneRowViewModel[];
    /** People assigned to the objective itself. */
    Assignees: TaskAssignee[];
    AssignedToMe: boolean;
    /** True when the current person created the objective or is assigned to it. */
    IsOwner: boolean;
    /** The objective's creator; null when the task carries none. */
    Owner: TaskAssignee | null;
    OwnedByMe: boolean;
    CompletedSubtaskCount: number;
    EffectivePercentComplete: number;
    EffectiveHealth: TaskHealthStatus;
    MetricProgressLabel: string | null;
    IsOverdue: boolean;
}

/** A personal to-do or reminder: a root task of a to-do type that is not an objective. */
export interface TodoItemViewModel {
    Task: PriorityTaskRow;
    IsOverdue: boolean;
    IsDueToday: boolean;
}

export interface PrioritySummary {
    TotalTaskCount: number;
    PriorityObjectiveCount: number;
    MilestoneCount: number;
    OnTrackCount: number;
    AtRiskCount: number;
    OffTrackCount: number;
    CompletedCount: number;
    /** Mean `ConfidenceScore` of the objectives that carry one, one decimal; null when none do. */
    AverageConfidenceScore: number | null;
    /** Mean effective progress across objectives, 0 when there are none. */
    AverageProgress: number;
    Cards: PriorityObjectiveCardViewModel[];
    /** Open to-dos and reminders, soonest due first. */
    TodoItems: TodoItemViewModel[];
    OpenTodoCount: number;
}

/** Assignment data for {@link BuildPrioritySummary}. */
export interface PrioritySummaryOptions {
    Assignees?: TaskAssigneeMap;
    /** The signed-in user's People ID; null shows every milestone and marks nobody as owner. */
    CurrentPersonID?: string | null;
}

/** Task type names (lower-case) that make a root task a personal to-do or reminder rather than an objective. */
const TODO_TYPE_LABELS: ReadonlySet<string> = new Set(['general', 'action item', 'follow-up', 'followup', 'follow up', 'to-do', 'todo', 'reminder']);
const CLOSED_TASK_STATUSES: ReadonlySet<string> = new Set(['completed', 'done', 'cancelled', 'canceled']);

export function ParseOptionalDate(val: Date | string | null | undefined): Date | null {
    if (!val) {
        return null;
    }
    const parsed = val instanceof Date ? val : new Date(val);
    return isNaN(parsed.getTime()) ? null : parsed;
}

export function IsTaskPriorityObjective(task: PriorityTaskRow): boolean {
    if (task.IsPriority === true || task.IsPriority === 1) {
        return true;
    }
    const typeLabel = (task.Type ?? task.TaskType ?? '').toLowerCase();
    if (typeLabel.includes('priority') || typeLabel.includes('objective') || typeLabel.includes('okr')) {
        return true;
    }
    return task.ParentID == null && (task.HealthStatus != null || task.PlanningPeriod != null);
}

/**
 * True for a root task whose type says to-do (General, Action Item, Follow-up, Reminder) and that is
 * not a priority objective. Milestones, key results and typeless tasks are not to-dos.
 */
export function IsTodoTask(task: PriorityTaskRow): boolean {
    if (task.ParentID != null || IsTaskPriorityObjective(task)) {
        return false;
    }
    return TODO_TYPE_LABELS.has((task.Type ?? task.TaskType ?? '').trim().toLowerCase());
}

/** The open to-dos among `tasks`, soonest due first and undated last, flagged overdue or due today (local time). */
export function BuildTodoItems(tasks: readonly PriorityTaskRow[], now: Date = new Date()): TodoItemViewModel[] {
    const open = tasks.filter((t) => IsTodoTask(t) && !CLOSED_TASK_STATUSES.has((t.Status ?? '').trim().toLowerCase()));
    return open
        .map((task) => {
            const due = ParseOptionalDate(task.DueAt);
            return {
                Task: task,
                IsOverdue: due !== null && due.getTime() < now.getTime(),
                IsDueToday: due !== null && isSameLocalDay(due, now),
            };
        })
        .sort((a, b) => {
            const da = ParseOptionalDate(a.Task.DueAt);
            const db = ParseOptionalDate(b.Task.DueAt);
            if (da && db) return da.getTime() - db.getTime();
            if (da) return -1;
            if (db) return 1;
            return a.Task.Name.localeCompare(b.Task.Name);
        });
}

function isSameLocalDay(a: Date, b: Date): boolean {
    return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
}

export function NormalizeTaskHealth(task: PriorityTaskRow): TaskHealthStatus {
    if (task.Status === 'Completed' || task.Status === 'Done' || task.HealthStatus === 'Completed') {
        return 'Completed';
    }
    if (task.HealthStatus === 'AtRisk' || task.HealthStatus === 'OffTrack' || task.HealthStatus === 'Paused') {
        return task.HealthStatus;
    }
    return 'OnTrack';
}

/**
 * Percent progress from `BaselineValue` toward `TargetValue`, clamped to 0-100. A Down target
 * (target below baseline) measures reduction. Null when there is no target or no span.
 */
export function ComputeTaskMetricPercent(task: PriorityTaskRow): number | null {
    if (task.TargetValue == null) {
        return null;
    }
    const baseline = task.BaselineValue ?? 0;
    const span = task.TargetValue - baseline;
    if (span === 0) {
        return null;
    }
    const current = task.CurrentValue ?? baseline;
    return Math.max(0, Math.min(100, Math.round(((current - baseline) / span) * 100)));
}

export function FormatTaskMetricProgress(task: PriorityTaskRow): string | null {
    if (task.TargetValue == null && task.CurrentValue == null) {
        return null;
    }
    const unit = task.UnitOfMeasure ? ` ${task.UnitOfMeasure}` : '';
    const current = task.CurrentValue ?? task.BaselineValue ?? 0;
    return task.TargetValue != null ? `${current}${unit} / ${task.TargetValue}${unit}` : `${current}${unit}`;
}

/** CSS modifier for a task priority badge, keyed by the Tasks `Priority` value list (Critical/High/Medium/Low). */
export function GetTaskPriorityClass(priority: string | null): string {
    switch ((priority ?? '').toLowerCase()) {
        case 'critical':
            return 'priority-critical';
        case 'high':
            return 'priority-high';
        case 'low':
            return 'priority-low';
        default:
            return 'priority-normal';
    }
}

/** The objective cards, to-dos and counts for a person's scoped tasks. */
export function BuildPrioritySummary(
    tasks: readonly PriorityTaskRow[],
    now: Date = new Date(),
    options: PrioritySummaryOptions = {},
): PrioritySummary {
    const currentPersonID = options.CurrentPersonID ?? null;
    const assigneesOf = (taskID: string): TaskAssignee[] => options.Assignees?.Get(taskID) ?? [];
    const heldByMe = (people: readonly TaskAssignee[]): boolean =>
        !!currentPersonID && people.some((a) => UUIDsEqual(a.PersonID, currentPersonID));
    const creatorOf = (task: PriorityTaskRow): TaskAssignee | null =>
        task.CreatedByPersonID ? { PersonID: task.CreatedByPersonID, Name: task.CreatedByPerson?.trim() || task.CreatedByPersonID } : null;

    const childTasks = tasks.filter((t) => !!t.ParentID);
    const subtasksByParent = new TaskIDMap<PriorityTaskRow[]>();
    for (const child of childTasks) {
        const siblings = subtasksByParent.Get(child.ParentID) ?? [];
        siblings.push(child);
        subtasksByParent.Set(child.ParentID as string, siblings);
    }
    const roots = tasks.filter((t) => !t.ParentID && (IsTaskPriorityObjective(t) || subtasksByParent.Has(t.ID)));

    let onTrack = 0;
    let atRisk = 0;
    let offTrack = 0;
    let completed = 0;
    let confidenceSum = 0;
    let confidenceCount = 0;
    let progressSum = 0;

    const cards = roots.map((root): PriorityObjectiveCardViewModel => {
        const children = subtasksByParent.Get(root.ID) ?? [];
        const completedChildren = children.filter((c) => c.Status === 'Completed' || c.Status === 'Done' || (c.PercentComplete ?? 0) >= 100).length;
        const percent = effectivePercent(root, children.length, completedChildren);
        const health = NormalizeTaskHealth(root);
        if (health === 'OnTrack') onTrack++;
        else if (health === 'AtRisk') atRisk++;
        else if (health === 'OffTrack') offTrack++;
        else if (health === 'Completed') completed++;
        if (typeof root.ConfidenceScore === 'number' && Number.isFinite(root.ConfidenceScore)) {
            confidenceSum += root.ConfidenceScore;
            confidenceCount++;
        }
        progressSum += percent;

        const due = ParseOptionalDate(root.DueAt);
        const rootAssignees = assigneesOf(root.ID);
        const assignedToMe = heldByMe(rootAssignees);
        const owner = creatorOf(root);
        const ownedByMe = !!owner && !!currentPersonID && UUIDsEqual(owner.PersonID, currentPersonID);
        const isOwner = assignedToMe || ownedByMe;
        const rows = children.map((child): MilestoneRowViewModel => {
            const assignees = assigneesOf(child.ID);
            const implicitHolder = creatorOf(child) ?? owner;
            const holders = assignees.length > 0 ? assignees : implicitHolder ? [implicitHolder] : [];
            return {
                Task: child,
                Assignees: assignees,
                AssignedToMe: heldByMe(assignees),
                Holders: holders,
                IsImplicitlyHeld: assignees.length === 0 && holders.length > 0,
                HeldByMe: heldByMe(holders),
            };
        });
        return {
            Task: root,
            Subtasks: children,
            // The objective is shared context; the milestone list is the person's own unless they own it.
            Milestones: isOwner || !currentPersonID ? rows : rows.filter((m) => m.HeldByMe),
            Assignees: rootAssignees,
            AssignedToMe: assignedToMe,
            IsOwner: isOwner,
            Owner: owner,
            OwnedByMe: ownedByMe,
            CompletedSubtaskCount: completedChildren,
            EffectivePercentComplete: percent,
            EffectiveHealth: health,
            MetricProgressLabel: FormatTaskMetricProgress(root),
            IsOverdue: due !== null && due.getTime() < now.getTime() && health !== 'Completed',
        };
    });

    const todoItems = BuildTodoItems(tasks, now);
    return {
        TotalTaskCount: tasks.length,
        PriorityObjectiveCount: cards.length,
        MilestoneCount: childTasks.length,
        OnTrackCount: onTrack,
        AtRiskCount: atRisk,
        OffTrackCount: offTrack,
        CompletedCount: completed,
        AverageConfidenceScore: confidenceCount > 0 ? Math.round((confidenceSum / confidenceCount) * 10) / 10 : null,
        AverageProgress: cards.length > 0 ? Math.round(progressSum / cards.length) : 0,
        Cards: cards,
        TodoItems: todoItems,
        OpenTodoCount: todoItems.length,
    };
}

/** The objective's metric when it has one, else its own percent, else the share of finished milestones. */
function effectivePercent(root: PriorityTaskRow, childCount: number, completedChildren: number): number {
    const metric = ComputeTaskMetricPercent(root);
    const raw = metric !== null
        ? metric
        : typeof root.PercentComplete === 'number' && root.PercentComplete > 0
            ? root.PercentComplete
            : childCount > 0
                ? Math.round((completedChildren / childCount) * 100)
                : root.Status === 'Completed' || root.Status === 'Done' ? 100 : 0;
    return Math.max(0, Math.min(100, raw));
}

/** The cards matching a health filter and search text (name or description, case-insensitive). */
export function FilterPriorityCards(
    cards: readonly PriorityObjectiveCardViewModel[],
    health: HealthFilter,
    searchText: string,
): PriorityObjectiveCardViewModel[] {
    const search = searchText.trim().toLowerCase();
    return cards.filter((c) => {
        if (health !== 'all' && c.EffectiveHealth !== health) {
            return false;
        }
        return !search || c.Task.Name.toLowerCase().includes(search) || (c.Task.Description ?? '').toLowerCase().includes(search);
    });
}

export function IsHealthFilter(value: unknown): value is HealthFilter {
    return typeof value === 'string' && (HEALTH_FILTERS as readonly string[]).includes(value);
}

/** Cap on the names published in the agent context. */
export const PRIORITY_CONTEXT_NAME_CAP = 25;

/** Finds one objective card by ID, exact name, or unambiguous partial name. */
export function ResolvePriorityObjectiveByIDOrName(
    cards: readonly PriorityObjectiveCardViewModel[],
    rawRef: unknown,
): { ok: true; value: PriorityObjectiveCardViewModel } | { ok: false; error: string } {
    if (typeof rawRef !== 'string' || rawRef.trim().length === 0) {
        return { ok: false, error: `Provide a priority objective ID or name. ${availableObjectiveNames(cards)}` };
    }
    const ref = rawRef.trim();
    const exact = cards.find((c) => UUIDsEqual(c.Task.ID, ref)) ?? cards.find((c) => c.Task.Name.trim().toLowerCase() === ref.toLowerCase());
    if (exact) {
        return { ok: true, value: exact };
    }
    const partial = cards.filter((c) => c.Task.Name.toLowerCase().includes(ref.toLowerCase()));
    if (partial.length === 1) {
        return { ok: true, value: partial[0] };
    }
    if (partial.length > 1) {
        const names = partial.slice(0, PRIORITY_CONTEXT_NAME_CAP).map((c) => c.Task.Name).join(', ');
        return { ok: false, error: `'${ref}' matches multiple priority objectives: ${names}. Be more specific.` };
    }
    return { ok: false, error: `No priority objective matches '${ref}'. ${availableObjectiveNames(cards)}` };
}

function availableObjectiveNames(cards: readonly PriorityObjectiveCardViewModel[]): string {
    if (cards.length === 0) {
        return 'There are no priority objectives loaded.';
    }
    const suffix = cards.length > PRIORITY_CONTEXT_NAME_CAP ? ', …' : '';
    return `Available priority objectives: ${cards.slice(0, PRIORITY_CONTEXT_NAME_CAP).map((c) => c.Task.Name).join(', ')}${suffix}`;
}

export type PriorityContextValue = string | number | boolean | null | string[];

/**
 * What the Priorities page tells the co-agent: counts, the filter state and bounded objective and
 * to-do names. Never descriptions or other free text.
 */
export function BuildPrioritiesAgentContext(summary: PrioritySummary, health: HealthFilter, searchText: string): Record<string, PriorityContextValue> {
    const names = summary.Cards.map((c) => c.Task.Name).filter((n) => !!n);
    const context: Record<string, PriorityContextValue> = {
        Surface: 'ChiefOfStaff.TasksPriorities',
        HealthFilter: health,
        SearchText: searchText,
        PriorityObjectiveCount: summary.PriorityObjectiveCount,
        MilestoneCount: summary.MilestoneCount,
        OnTrackCount: summary.OnTrackCount,
        AtRiskCount: summary.AtRiskCount,
        OffTrackCount: summary.OffTrackCount,
        CompletedPriorityCount: summary.CompletedCount,
        AveragePriorityProgressPercent: summary.AverageProgress,
        OpenTodoCount: summary.OpenTodoCount,
        VisiblePriorityObjectiveNames: names.slice(0, PRIORITY_CONTEXT_NAME_CAP),
        VisibleTodoNames: summary.TodoItems.slice(0, PRIORITY_CONTEXT_NAME_CAP).map((t) => t.Task.Name),
    };
    if (names.length > PRIORITY_CONTEXT_NAME_CAP) {
        context['VisiblePriorityObjectiveNamesTruncated'] = true;
        context['VisiblePriorityObjectiveNamesTotal'] = names.length;
    }
    return context;
}

/** The RunView surface the scope resolver needs; `RunView` from @memberjunction/core satisfies it. */
export interface TaskScopeQueryRunner {
    RunView<T>(params: RunViewParams, contextUser?: UserInfo): Promise<{ Success: boolean; Results: T[]; ErrorMessage?: string }>;
}

export interface PersonTaskScope {
    PersonID: string;
    /** ExtraFilter for `MJ_BizApps_Tasks: Tasks` selecting everything in the person's scope. */
    Filter: string;
}

/**
 * The Tasks filter for a person: tasks they created or are assigned to, plus the whole tree of every
 * root objective they own or hold a milestone under. `peopleEntityId` is the `MJ: Entities` ID of
 * {@link PEOPLE_ENTITY_NAME}, the assignee entity on Task Assignments. Server-side callers pass
 * `contextUser`, which every query runs as. Throws when a lookup fails.
 */
export async function ResolvePersonTaskScope(
    runner: TaskScopeQueryRunner,
    personID: string,
    peopleEntityId: string,
    contextUser?: UserInfo,
): Promise<PersonTaskScope> {
    const assignedTaskIDs = await loadAssignedTaskIDs(runner, peopleEntityId, personID, contextUser);
    const scopeRootIDs = await loadScopeRootTaskIDs(runner, personID, assignedTaskIDs, contextUser);
    return { PersonID: personID, Filter: BuildPersonScopedTaskFilter(personID, assignedTaskIDs, scopeRootIDs) };
}

async function loadAssignedTaskIDs(runner: TaskScopeQueryRunner, peopleEntityId: string, personID: string, contextUser?: UserInfo): Promise<string[]> {
    const assignments = await runner.RunView<{ TaskID: string }>({
        EntityName: TASK_ASSIGNMENTS_ENTITY_NAME,
        ExtraFilter: `AssigneeEntityID = '${EscapeSQLString(peopleEntityId)}' AND AssigneeRecordID = '${EscapeSQLString(personID)}'`,
        Fields: ['TaskID'],
        ResultType: 'simple',
    }, contextUser);
    if (!assignments.Success) {
        throw new Error(assignments.ErrorMessage ?? 'Failed to load task assignments.');
    }
    return assignments.Results.map((a) => a.TaskID).filter((id) => !!id);
}

/**
 * Roots whose whole tree is in scope: the roots the person created or is assigned to, plus the root
 * above every task they are assigned to (its `RootParentID`, which on a root is its own ID).
 */
async function loadScopeRootTaskIDs(runner: TaskScopeQueryRunner, personID: string, assignedTaskIDs: readonly string[], contextUser?: UserInfo): Promise<string[]> {
    const rows = await runner.RunView<{ ID: string; RootParentID: string | null }>({
        EntityName: TASKS_ENTITY_NAME,
        ExtraFilter: BuildScopeRootTasksFilter(personID, assignedTaskIDs),
        Fields: ['ID', 'RootParentID'],
        ResultType: 'simple',
    }, contextUser);
    if (!rows.Success) {
        throw new Error(rows.ErrorMessage ?? 'Failed to load the scope root objectives.');
    }
    return distinctUUIDs(rows.Results.map((r) => r.RootParentID || r.ID));
}

/** Root tasks (no parent) the person created or is assigned to. */
export function BuildOwnedRootTasksFilter(personID: string, assignedTaskIDs: readonly string[]): string {
    return `ParentID IS NULL AND (${createdOrAssignedClause(personID, assignedTaskIDs)})`;
}

/** {@link BuildOwnedRootTasksFilter} plus every assigned task, so an assigned milestone's root can be read off it. */
export function BuildScopeRootTasksFilter(personID: string, assignedTaskIDs: readonly string[]): string {
    const owned = BuildOwnedRootTasksFilter(personID, assignedTaskIDs);
    return assignedTaskIDs.length === 0 ? owned : `(${owned}) OR ID IN (${quoteIDList(assignedTaskIDs)})`;
}

/** Tasks the person created or is assigned to, plus every task under one of `ownedRootIDs`. */
export function BuildPersonScopedTaskFilter(personID: string, assignedTaskIDs: readonly string[], ownedRootIDs: readonly string[] = []): string {
    const createdOrAssigned = createdOrAssignedClause(personID, assignedTaskIDs);
    return ownedRootIDs.length === 0 ? createdOrAssigned : `${createdOrAssigned} OR RootParentID IN (${quoteIDList(ownedRootIDs)})`;
}

/** Who is assigned to each of `taskIDs`, by name. Two queries (as `contextUser` when given); none for an empty list. */
export async function LoadTaskAssignees(
    runner: TaskScopeQueryRunner,
    peopleEntityId: string,
    taskIDs: readonly string[],
    contextUser?: UserInfo,
): Promise<TaskAssigneeMap> {
    const map: TaskAssigneeMap = new TaskIDMap<TaskAssignee[]>();
    if (taskIDs.length === 0) {
        return map;
    }
    const assignments = await runner.RunView<{ TaskID: string; AssigneeRecordID: string }>({
        EntityName: TASK_ASSIGNMENTS_ENTITY_NAME,
        ExtraFilter: `AssigneeEntityID = '${EscapeSQLString(peopleEntityId)}' AND TaskID IN (${quoteIDList(taskIDs)})`,
        Fields: ['TaskID', 'AssigneeRecordID'],
        ResultType: 'simple',
    }, contextUser);
    if (!assignments.Success) {
        throw new Error(assignments.ErrorMessage ?? 'Failed to load task assignees.');
    }
    const personIDs = distinctUUIDs(assignments.Results.map((a) => a.AssigneeRecordID));
    if (personIDs.length === 0) {
        return map;
    }
    const people = await runner.RunView<{ ID: string; FirstName: string | null; LastName: string | null }>({
        EntityName: PEOPLE_ENTITY_NAME,
        ExtraFilter: `ID IN (${quoteIDList(personIDs)})`,
        Fields: ['ID', 'FirstName', 'LastName'],
        ResultType: 'simple',
    }, contextUser);
    if (!people.Success) {
        throw new Error(people.ErrorMessage ?? 'Failed to load assignee names.');
    }
    const nameByPerson = new TaskIDMap<string>();
    for (const person of people.Results) {
        nameByPerson.Set(person.ID, [person.FirstName, person.LastName].filter((n) => !!n).join(' ').trim() || person.ID);
    }
    for (const a of assignments.Results) {
        if (!a.TaskID || !a.AssigneeRecordID) {
            continue;
        }
        const list = map.Get(a.TaskID) ?? [];
        list.push({ PersonID: a.AssigneeRecordID, Name: nameByPerson.Get(a.AssigneeRecordID) ?? a.AssigneeRecordID });
        map.Set(a.TaskID, list);
    }
    return map;
}

function createdOrAssignedClause(personID: string, assignedTaskIDs: readonly string[]): string {
    const created = `CreatedByPersonID = '${EscapeSQLString(personID)}'`;
    return assignedTaskIDs.length === 0 ? created : `${created} OR ID IN (${quoteIDList(assignedTaskIDs)})`;
}

function quoteIDList(ids: readonly string[]): string {
    return ids.map((id) => `'${EscapeSQLString(id)}'`).join(', ');
}

/** The distinct, non-empty IDs, first spelling kept, compared case-insensitively. */
function distinctUUIDs(ids: readonly (string | null | undefined)[]): string[] {
    const seen = new TaskIDSet();
    const out: string[] = [];
    for (const id of ids) {
        if (id && !seen.Has(id)) {
            seen.Add(id);
            out.push(id);
        }
    }
    return out;
}
