import { Directive, Input, Type } from '@angular/core';
import type { IMetadataProvider } from '@memberjunction/core';
import { MJGlobal, type ClassRegistration } from '@memberjunction/global';
import { BaseFormPanel } from '@memberjunction/ng-base-forms';
import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';

/**
 * Metadata `surface` discriminator for downstream Task Detail Inspector contributions.
 *
 * Downstream Open Apps register components against `BaseFormPanel` (or
 * {@link BaseTaskDetailContribution}) via `@RegisterClassEx` with
 * `metadata: { surface: 'bizapps-tasks:detail-panel', ... }` and WITHOUT `metadata.entity`
 * so `<mj-form-panel-slot>` and `<bizapps-task-detail-contributions>` stay cleanly separated.
 */
export const TASK_DETAIL_CONTRIBUTION_SURFACE = 'bizapps-tasks:detail-panel' as const;

/** Recommended registration key prefix for Task Detail Inspector contributions. */
export const TASK_DETAIL_CONTRIBUTION_KEY_PREFIX = 'BizAppsTasks:TaskDetailContribution:' as const;

/** Normalized representation of a `MJ_BizApps_Tasks: Task Links` row passed to contributions. */
export interface TaskDetailContributionLink {
    EntityName: string;
    EntityID?: string;
    RecordID: string;
    DisplayName: string;
    IconClass?: string;
}

/** Snapshot passed to mounted Task Detail Inspector contributions whenever the task or links change. */
export interface TaskDetailContributionContext {
    TaskID: string;
    TaskEntity: mjBizAppsTasksTaskEntity | null;
    TaskLinks: readonly TaskDetailContributionLink[];
    MatchedTaskLinks: readonly TaskDetailContributionLink[];
    Provider: IMetadataProvider;
    ReadOnly: boolean;
    OpenEntityRecord: (entityName: string, recordId: string) => void;
}

/** Metadata attached via `@RegisterClassEx(..., { metadata })` for a Task Detail Inspector contribution. */
export interface TaskDetailContributionMetadata {
    surface: typeof TASK_DETAIL_CONTRIBUTION_SURFACE;
    /** Exact MJ Entity names (case-insensitive) that match against the task's `TaskLinks`. */
    linkedEntities?: readonly string[];
    /** MJ Entity name prefixes (case-insensitive, e.g. `'MJ_BizApps_MyApp:'`) matched against `TaskLinks`. */
    linkedEntityPrefixes?: readonly string[];
    /**
     * When `true`, mounts for every inspected task so the contribution can inspect parent/IS-A
     * or reverse-FK relationships in addition to `TaskLinks`, self-hiding when irrelevant.
     */
    matchAll?: boolean;
    /** Higher `sortKey` renders first. Defaults to `0`. */
    sortKey?: number;
    /** Optional identity for priority-based winner collapse when multiple apps claim the same slot. */
    contributionKey?: string;
}

/** Structural contract implemented by dynamically mounted Task Detail Inspector contribution components. */
export interface TaskDetailContributionInstance {
    Record?: mjBizAppsTasksTaskEntity;
    TaskID?: string | null;
    TaskEntity?: mjBizAppsTasksTaskEntity | null;
    TaskLinks?: readonly TaskDetailContributionLink[];
    MatchedTaskLinks?: readonly TaskDetailContributionLink[];
    Provider?: IMetadataProvider | null;
    ReadOnly?: boolean;
    OpenEntityRecord?: (entityName: string, recordId: string) => void;
    OnTaskContextChanged?: (context: TaskDetailContributionContext) => void;
}

/** Resolved contribution ready to be mounted inside `<bizapps-task-detail-contributions>`. */
export interface ResolvedTaskDetailContribution {
    Registration: ClassRegistration;
    ComponentType: Type<TaskDetailContributionInstance>;
    Metadata: TaskDetailContributionMetadata;
    MatchedTaskLinks: TaskDetailContributionLink[];
}

/**
 * Typed base class for downstream Task Detail Inspector contributions.
 *
 * Extends `BaseFormPanel<mjBizAppsTasksTaskEntity>` so downstream apps can register against
 * either `BaseTaskDetailContribution` or `BaseFormPanel` directly (requiring zero compile-time
 * dependency on `@mj-biz-apps/tasks-ng`).
 */
@Directive()
export abstract class BaseTaskDetailContribution
    extends BaseFormPanel<mjBizAppsTasksTaskEntity>
    implements TaskDetailContributionInstance
{
    @Input() TaskID: string | null = null;
    @Input() TaskEntity: mjBizAppsTasksTaskEntity | null = null;
    @Input() TaskLinks: readonly TaskDetailContributionLink[] = [];
    @Input() MatchedTaskLinks: readonly TaskDetailContributionLink[] = [];
    @Input() Provider: IMetadataProvider | null = null;
    @Input() ReadOnly = false;
    @Input() OpenEntityRecord?: (entityName: string, recordId: string) => void;

    public OnTaskContextChanged(_context: TaskDetailContributionContext): void {
        // Subclasses override to refresh state when task or links change.
    }
}

function readStringArray(value: ClassRegistration['Metadata'] extends Record<string, infer V> | undefined ? V : never): string[] | undefined {
    if (!Array.isArray(value)) {
        return undefined;
    }
    const items: string[] = [];
    for (const entry of value) {
        if (typeof entry === 'string' && entry.trim().length > 0) {
            items.push(entry.trim());
        }
    }
    return items.length > 0 ? items : undefined;
}

function parseTaskDetailContributionMetadata(
    raw: ClassRegistration['Metadata'],
): TaskDetailContributionMetadata | null {
    if (!raw || raw['surface'] !== TASK_DETAIL_CONTRIBUTION_SURFACE) {
        return null;
    }
    const linkedEntities = readStringArray(raw['linkedEntities']);
    const linkedEntityPrefixes = readStringArray(raw['linkedEntityPrefixes']);
    const matchAll = raw['matchAll'] === true;
    const sortKey = typeof raw['sortKey'] === 'number' && Number.isFinite(raw['sortKey']) ? raw['sortKey'] : 0;
    const contributionKey =
        typeof raw['contributionKey'] === 'string' && raw['contributionKey'].trim().length > 0
            ? raw['contributionKey'].trim()
            : undefined;

    if (!matchAll && !linkedEntities && !linkedEntityPrefixes) {
        return null;
    }

    return {
        surface: TASK_DETAIL_CONTRIBUTION_SURFACE,
        linkedEntities,
        linkedEntityPrefixes,
        matchAll,
        sortKey,
        contributionKey,
    };
}

/**
 * Returns the subset of `taskLinks` that match a contribution's `linkedEntities` or
 * `linkedEntityPrefixes` rules (case-insensitive).
 */
export function MatchesTaskDetailContributionLinks(
    metadata: TaskDetailContributionMetadata,
    taskLinks: readonly TaskDetailContributionLink[],
): TaskDetailContributionLink[] {
    if (taskLinks.length === 0) {
        return [];
    }
    const exactSet = metadata.linkedEntities
        ? new Set(metadata.linkedEntities.map((name) => name.toLowerCase()))
        : null;
    const prefixes = metadata.linkedEntityPrefixes
        ? metadata.linkedEntityPrefixes.map((prefix) => prefix.toLowerCase())
        : null;

    if (!exactSet && !prefixes) {
        return [];
    }

    return taskLinks.filter((link) => {
        const entityLower = link.EntityName.trim().toLowerCase();
        if (!entityLower) {
            return false;
        }
        if (exactSet?.has(entityLower)) {
            return true;
        }
        if (prefixes?.some((prefix) => entityLower.startsWith(prefix))) {
            return true;
        }
        return false;
    });
}

/**
 * Discovers all Task Detail Inspector contributions registered in `MJGlobal.Instance.ClassFactory`
 * that apply to the supplied `taskLinks`, collapsing competing `contributionKey` winners by
 * highest `Priority` and sorting by `sortKey` descending then `Priority` descending.
 */
export function DiscoverTaskDetailContributions(
    taskLinks: readonly TaskDetailContributionLink[],
): ResolvedTaskDetailContribution[] {
    const cf = MJGlobal.Instance.ClassFactory;

    const rawRegs: ClassRegistration[] = [
        ...cf.GetAllRegistrationsByMetadata(
            BaseFormPanel,
            (metadata) => metadata?.['surface'] === TASK_DETAIL_CONTRIBUTION_SURFACE,
        ),
        ...cf.GetAllRegistrationsByMetadata(
            BaseTaskDetailContribution,
            (metadata) => metadata?.['surface'] === TASK_DETAIL_CONTRIBUTION_SURFACE,
        ),
    ];

    const seenSubClasses = new Set<object>();
    const candidates: ResolvedTaskDetailContribution[] = [];

    for (const reg of rawRegs) {
        if (!reg.SubClass || typeof reg.SubClass !== 'function') {
            continue;
        }
        if (seenSubClasses.has(reg.SubClass)) {
            continue;
        }
        seenSubClasses.add(reg.SubClass);

        const parsed = parseTaskDetailContributionMetadata(reg.Metadata);
        if (!parsed) {
            continue;
        }

        const matchedLinks = MatchesTaskDetailContributionLinks(parsed, taskLinks);
        if (!parsed.matchAll && matchedLinks.length === 0) {
            continue;
        }

        const componentType: Type<TaskDetailContributionInstance> = reg.SubClass;
        candidates.push({
            Registration: reg,
            ComponentType: componentType,
            Metadata: parsed,
            MatchedTaskLinks: matchedLinks,
        });
    }

    // Collapse competing registrations sharing the same contributionKey (highest Priority wins).
    const winnersByKey = new Map<string, ResolvedTaskDetailContribution>();
    const unkeyed: ResolvedTaskDetailContribution[] = [];

    for (const candidate of candidates) {
        const key = candidate.Metadata.contributionKey;
        if (!key) {
            unkeyed.push(candidate);
            continue;
        }
        const existing = winnersByKey.get(key);
        if (!existing || candidate.Registration.Priority >= existing.Registration.Priority) {
            winnersByKey.set(key, candidate);
        }
    }

    const winners = [...unkeyed, ...winnersByKey.values()];
    winners.sort((a, b) => {
        const sortDiff = (b.Metadata.sortKey ?? 0) - (a.Metadata.sortKey ?? 0);
        if (sortDiff !== 0) {
            return sortDiff;
        }
        return (b.Registration.Priority ?? 0) - (a.Registration.Priority ?? 0);
    });

    return winners;
}
