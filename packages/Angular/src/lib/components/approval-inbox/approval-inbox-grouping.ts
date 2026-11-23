/**
 * Pure helper utilities for Organization-grouped Approval Inbox views,
 * approval wait-latency badges, raw-Markdown-free excerpts, literal search
 * matching, and UserInfoEngine preference persistence.
 */

export const APPROVAL_INBOX_PREFS_SETTING = 'mj.tasks.approvalInbox.prefs.v1';
export const NO_ORGANIZATION_KEY = '__no_org__';
export const NO_ORGANIZATION_LABEL = 'No Organization';

export type ApprovalInboxSortMode = 'due' | 'latency' | 'priority';
export type ApprovalLatencyTier = 'normal' | 'elevated' | 'overdue';

export interface ApprovalInboxPreferences {
    groupByOrganization: boolean;
    collapsedOrgKeys: string[];
    sortBy: ApprovalInboxSortMode;
}

export interface ApprovalLatencyIndicator {
    WaitMs: number;
    Label: string;
    Tier: ApprovalLatencyTier;
}

export interface OrganizationApprovalItemBase {
    ID: string;
    Name: string;
    Description?: string | null;
    Priority: string;
    DueAt?: Date | string | null;
    OrganizationID?: string | null;
    Organization?: string | null;
    CreatedAt?: Date | string | null;
    __mj_CreatedAt?: Date | string | null;
}

export interface OrganizationApprovalGroup<T extends OrganizationApprovalItemBase> {
    OrganizationKey: string;
    OrganizationID: string | null;
    OrganizationName: string;
    Items: T[];
    Count: number;
    AvgWaitMs: number;
    MaxWaitMs: number;
    AvgWaitFormatted: string;
    MaxWaitFormatted: string;
    HighestTier: ApprovalLatencyTier;
}

const PRIORITY_RANK: Record<string, number> = {
    critical: 0,
    high: 1,
    medium: 2,
    low: 3,
};

const TIER_RANK: Record<ApprovalLatencyTier, number> = {
    normal: 0,
    elevated: 1,
    overdue: 2,
};

const MS_PER_MINUTE = 60_000;
const MS_PER_HOUR = 60 * MS_PER_MINUTE;
const MS_PER_DAY = 24 * MS_PER_HOUR;
const ELEVATED_WAIT_THRESHOLD_MS = 24 * MS_PER_HOUR;

export function DefaultApprovalInboxPreferences(): ApprovalInboxPreferences {
    return {
        groupByOrganization: true,
        collapsedOrgKeys: [],
        sortBy: 'due',
    };
}

export function ParseApprovalInboxPreferences(raw: string | undefined | null): ApprovalInboxPreferences {
    const defaults = DefaultApprovalInboxPreferences();
    if (!raw || typeof raw !== 'string') {
        return defaults;
    }
    try {
        const parsed = JSON.parse(raw) as Partial<ApprovalInboxPreferences>;
        const sortBy: ApprovalInboxSortMode =
            parsed.sortBy === 'latency' || parsed.sortBy === 'priority' || parsed.sortBy === 'due'
                ? parsed.sortBy
                : defaults.sortBy;
        const collapsedOrgKeys = Array.isArray(parsed.collapsedOrgKeys)
            ? [...new Set(parsed.collapsedOrgKeys.filter((k): k is string => typeof k === 'string' && k.trim().length > 0).map((k) => k.trim().toLowerCase()))]
            : [];
        return {
            groupByOrganization: typeof parsed.groupByOrganization === 'boolean' ? parsed.groupByOrganization : defaults.groupByOrganization,
            collapsedOrgKeys,
            sortBy,
        };
    } catch {
        return defaults;
    }
}

export function SerializeApprovalInboxPreferences(prefs: ApprovalInboxPreferences): string {
    return JSON.stringify({
        groupByOrganization: Boolean(prefs.groupByOrganization),
        collapsedOrgKeys: [...new Set(prefs.collapsedOrgKeys.map((k) => k.trim().toLowerCase()).filter(Boolean))],
        sortBy: prefs.sortBy === 'latency' || prefs.sortBy === 'priority' ? prefs.sortBy : 'due',
    });
}

function toTimestampMs(value: Date | string | null | undefined): number | null {
    if (value == null) return null;
    const ms = value instanceof Date ? value.getTime() : Date.parse(String(value));
    return Number.isFinite(ms) ? ms : null;
}

export function FormatApprovalWaitDuration(waitMs: number): string {
    if (!Number.isFinite(waitMs) || waitMs <= 0) {
        return '< 1m';
    }
    const totalMinutes = Math.floor(waitMs / MS_PER_MINUTE);
    if (totalMinutes < 1) {
        return '< 1m';
    }
    if (totalMinutes < 60) {
        return `${totalMinutes}m`;
    }
    const totalHours = Math.floor(waitMs / MS_PER_HOUR);
    const remMinutes = totalMinutes % 60;
    if (totalHours < 24) {
        return remMinutes > 0 ? `${totalHours}h ${remMinutes}m` : `${totalHours}h`;
    }
    const days = Math.floor(waitMs / MS_PER_DAY);
    const remHours = totalHours % 24;
    return remHours > 0 ? `${days}d ${remHours}h` : `${days}d`;
}

export function ComputeApprovalLatencyIndicator(
    createdAt: Date | string | null | undefined,
    dueAt?: Date | string | null | undefined,
    nowMs: number = Date.now(),
): ApprovalLatencyIndicator {
    const createdMs = toTimestampMs(createdAt);
    const dueMs = toTimestampMs(dueAt);
    const waitMs = createdMs != null ? Math.max(0, nowMs - createdMs) : 0;

    let tier: ApprovalLatencyTier = 'normal';
    if (dueMs != null && nowMs > dueMs) {
        tier = 'overdue';
    } else if (waitMs >= ELEVATED_WAIT_THRESHOLD_MS) {
        tier = 'elevated';
    }

    return {
        WaitMs: waitMs,
        Label: createdMs != null ? `Wait ${FormatApprovalWaitDuration(waitMs)}` : 'Wait —',
        Tier: tier,
    };
}

export function OrganizationKeyForItem(item: Pick<OrganizationApprovalItemBase, 'OrganizationID'>): string {
    const orgId = item.OrganizationID?.trim();
    return orgId ? orgId.toLowerCase() : NO_ORGANIZATION_KEY;
}

export function SortApprovalItems<T extends OrganizationApprovalItemBase>(
    items: readonly T[],
    sortBy: ApprovalInboxSortMode,
    nowMs: number = Date.now(),
): T[] {
    return [...items].sort((a, b) => {
        if (sortBy === 'priority') {
            const pa = PRIORITY_RANK[(a.Priority || '').toLowerCase()] ?? 99;
            const pb = PRIORITY_RANK[(b.Priority || '').toLowerCase()] ?? 99;
            if (pa !== pb) return pa - pb;
        } else if (sortBy === 'latency') {
            const wa = ComputeApprovalLatencyIndicator(a.CreatedAt ?? a.__mj_CreatedAt, a.DueAt, nowMs).WaitMs;
            const wb = ComputeApprovalLatencyIndicator(b.CreatedAt ?? b.__mj_CreatedAt, b.DueAt, nowMs).WaitMs;
            if (wa !== wb) return wb - wa;
        }

        const da = toTimestampMs(a.DueAt);
        const db = toTimestampMs(b.DueAt);
        if (da != null && db != null && da !== db) return da - db;
        if (da != null && db == null) return -1;
        if (da == null && db != null) return 1;
        return a.Name.localeCompare(b.Name);
    });
}

export function GroupApprovalsByOrganization<T extends OrganizationApprovalItemBase>(
    items: readonly T[],
    options: { sortBy?: ApprovalInboxSortMode; nowMs?: number } = {},
): OrganizationApprovalGroup<T>[] {
    const nowMs = options.nowMs ?? Date.now();
    const sortBy = options.sortBy ?? 'due';
    const sortedItems = SortApprovalItems(items, sortBy, nowMs);

    const groupsMap = new Map<
        string,
        {
            OrganizationID: string | null;
            OrganizationName: string;
            Items: T[];
            WaitValues: number[];
            HighestTier: ApprovalLatencyTier;
        }
    >();

    for (const item of sortedItems) {
        const orgID = item.OrganizationID?.trim() || null;
        const orgKey = orgID ? orgID.toLowerCase() : NO_ORGANIZATION_KEY;
        const orgName = orgID ? (item.Organization?.trim() || 'Organization') : NO_ORGANIZATION_LABEL;
        const indicator = ComputeApprovalLatencyIndicator(item.CreatedAt ?? item.__mj_CreatedAt, item.DueAt, nowMs);

        const existing = groupsMap.get(orgKey);
        if (existing) {
            existing.Items.push(item);
            if (toTimestampMs(item.CreatedAt ?? item.__mj_CreatedAt) != null) {
                existing.WaitValues.push(indicator.WaitMs);
            }
            if (TIER_RANK[indicator.Tier] > TIER_RANK[existing.HighestTier]) {
                existing.HighestTier = indicator.Tier;
            }
        } else {
            groupsMap.set(orgKey, {
                OrganizationID: orgID,
                OrganizationName: orgName,
                Items: [item],
                WaitValues: toTimestampMs(item.CreatedAt ?? item.__mj_CreatedAt) != null ? [indicator.WaitMs] : [],
                HighestTier: indicator.Tier,
            });
        }
    }

    return Array.from(groupsMap.entries())
        .map(([orgKey, data]) => {
            const hasWaits = data.WaitValues.length > 0;
            const totalWait = data.WaitValues.reduce((sum, v) => sum + v, 0);
            const avgWaitMs = hasWaits ? Math.round(totalWait / data.WaitValues.length) : 0;
            const maxWaitMs = hasWaits ? Math.max(...data.WaitValues) : 0;
            return {
                OrganizationKey: orgKey,
                OrganizationID: data.OrganizationID,
                OrganizationName: data.OrganizationName,
                Items: data.Items,
                Count: data.Items.length,
                AvgWaitMs: avgWaitMs,
                MaxWaitMs: maxWaitMs,
                AvgWaitFormatted: hasWaits ? FormatApprovalWaitDuration(avgWaitMs) : '—',
                MaxWaitFormatted: hasWaits ? FormatApprovalWaitDuration(maxWaitMs) : '—',
                HighestTier: data.HighestTier,
            };
        })
        .sort((a, b) => {
            if (a.OrganizationKey === NO_ORGANIZATION_KEY && b.OrganizationKey !== NO_ORGANIZATION_KEY) return 1;
            if (b.OrganizationKey === NO_ORGANIZATION_KEY && a.OrganizationKey !== NO_ORGANIZATION_KEY) return -1;
            const byName = a.OrganizationName.localeCompare(b.OrganizationName);
            return byName !== 0 ? byName : a.OrganizationKey.localeCompare(b.OrganizationKey);
        });
}

/**
 * Strips raw Markdown syntax (`###`, `**`, `__`, inline backticks, code fences, links)
 * so rendered approval summaries and card previews never leak unformatted Markdown tokens.
 */
export function StripRawMarkdownForExcerpt(raw: string | null | undefined): string {
    if (!raw) return '';
    return raw
        .replace(/```[\s\S]*?```/g, (block) => block.replace(/```[^\n]*\n?/g, '').replace(/```/g, ' '))
        .replace(/`([^`]*)`/g, '$1')
        .replace(/!\[([^\]]*)\]\([^)]*\)/g, '$1')
        .replace(/\[([^\]]+)\]\([^)]*\)/g, '$1')
        .replace(/^\s{0,3}#{1,6}\s+/gm, '')
        .replace(/^\s*[-*+]\s+/gm, '')
        .replace(/^\s*>\s?/gm, '')
        .replace(/\*\*([^*]+)\*\*/g, '$1')
        .replace(/__([^_]+)__/g, '$1')
        .replace(/\*([^*\n]+)\*/g, '$1')
        .replace(/_([^_\n]+)_/g, '$1')
        .replace(/~~([^~]+)~~/g, '$1')
        .replace(/\s+/g, ' ')
        .trim();
}

/**
 * Literal case-insensitive substring matcher for approval inbox search inputs.
 * LIKE metacharacters (`%`, `_`, `[`, `]`, `\`) are matched literally, never as wildcards.
 */
export function MatchesApprovalSearchQuery(
    item: Pick<OrganizationApprovalItemBase, 'Name' | 'Description' | 'Organization'>,
    query: string,
): boolean {
    const q = query.trim().toLowerCase();
    if (!q) return true;
    const nameMatch = item.Name.toLowerCase().includes(q);
    const descMatch = StripRawMarkdownForExcerpt(item.Description).toLowerCase().includes(q);
    const orgMatch = (item.Organization ?? '').toLowerCase().includes(q);
    return nameMatch || descMatch || orgMatch;
}
