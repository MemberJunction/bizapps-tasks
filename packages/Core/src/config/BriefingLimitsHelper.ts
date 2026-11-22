/**
 * @fileoverview Shared briefing contributor bounds, timeout wrapper, and character-cap
 * serialization helpers backed by {@link TasksLimitsResolver}.
 *
 * @module @mj-biz-apps/tasks-core
 */

import { TasksLimitsResolver } from './TasksLimits.js';

/** Input options for {@link ResolveBriefingContributorBounds}. */
export interface BriefingContributorBoundsInput {
    HorizonDays?: number | null;
    LookbackDays?: number | null;
    MaxItems?: number | null;
    LookbackKind?: 'meetings' | 'workReports';
}

/** Resolved runtime bounds for a briefing contributor action. */
export interface BriefingContributorBounds {
    HorizonDays: number;
    LookbackDays: number;
    MaxItems: number;
    ContributorTimeoutMs: number;
    MaxContributorChars: number;
}

/** Result returned by {@link SerializeBriefingPayloadWithLimit}. */
export interface BoundedBriefingSerialization {
    Json: string;
    Truncated: boolean;
}

/**
 * Resolves `HorizonDays`, `LookbackDays`, `MaxItems`, `ContributorTimeoutMs`, and
 * `MaxContributorChars` for a briefing contributor from {@link TasksLimitsResolver}.
 */
export function ResolveBriefingContributorBounds(
    input: BriefingContributorBoundsInput = {},
): BriefingContributorBounds {
    const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
    const defaultLookback =
        input.LookbackKind === 'workReports'
            ? limits.Briefing.DefaultWorkReportsBriefingLookbackDays
            : limits.Briefing.DefaultMeetingsBriefingLookbackDays;
    const maxLookback =
        input.LookbackKind === 'workReports'
            ? limits.RunawayGuards.BriefingWorkReportsMaxLookbackDays
            : limits.RunawayGuards.BriefingMaxLookbackDays;

    const rawHorizon = input.HorizonDays ?? limits.Briefing.DefaultBriefingHorizonDays;
    const rawLookback = input.LookbackDays ?? defaultLookback;
    const rawMaxItems = input.MaxItems ?? limits.Briefing.DefaultBriefingMaxItems;

    return {
        HorizonDays: Math.max(1, Math.min(limits.RunawayGuards.BriefingMaxHorizonDays, Math.round(rawHorizon))),
        LookbackDays: Math.max(1, Math.min(maxLookback, Math.round(rawLookback))),
        MaxItems: Math.max(1, Math.min(limits.RunawayGuards.BriefingMaxItemsCeiling, Math.round(rawMaxItems))),
        ContributorTimeoutMs: limits.Briefing.ContributorTimeoutMs,
        MaxContributorChars: limits.Briefing.MaxContributorChars,
    };
}

/**
 * Executes an async briefing contributor query/assembly step bounded by
 * `Briefing.ContributorTimeoutMs` from {@link TasksLimitsResolver}.
 */
export async function RunWithBriefingContributorTimeout<T>(
    operation: () => Promise<T>,
    timeoutMs: number = TasksLimitsResolver.Instance.GetCurrentLimits().Briefing.ContributorTimeoutMs,
    label: string = 'Briefing contributor',
): Promise<T> {
    const effectiveTimeout = Math.max(1, Math.round(timeoutMs));
    let timerHandle: ReturnType<typeof setTimeout> | undefined;
    try {
        return await Promise.race([
            operation(),
            new Promise<never>((_, reject) => {
                timerHandle = setTimeout(() => {
                    reject(new Error(`${label} timed out after ${effectiveTimeout}ms.`));
                }, effectiveTimeout);
            }),
        ]);
    } finally {
        if (timerHandle !== undefined) {
            clearTimeout(timerHandle);
        }
    }
}

/**
 * Serializes a briefing contributor payload to JSON while respecting `Briefing.MaxContributorChars`.
 * When the serialized payload exceeds `maxChars`, trims items from the supplied array sections
 * round-robin from the tail until it fits within the character ceiling.
 */
export function SerializeBriefingPayloadWithLimit<T extends object>(
    payload: T,
    arrayKeys: readonly (keyof T)[],
    maxChars: number = TasksLimitsResolver.Instance.GetCurrentLimits().Briefing.MaxContributorChars,
): BoundedBriefingSerialization {
    const ceiling = Math.max(1, Math.round(maxChars));
    const working: T = { ...payload };
    for (const key of arrayKeys) {
        const val = working[key];
        if (Array.isArray(val)) {
            working[key] = [...val] as T[keyof T];
        }
    }

    let json = JSON.stringify(working);
    if (json.length <= ceiling) {
        return { Json: json, Truncated: false };
    }

    let trimmedAny = true;
    while (json.length > ceiling && trimmedAny) {
        trimmedAny = false;
        let longestKey: keyof T | null = null;
        let longestLen = 0;
        for (const key of arrayKeys) {
            const val = working[key];
            if (Array.isArray(val) && val.length > longestLen) {
                longestLen = val.length;
                longestKey = key;
            }
        }
        if (longestKey !== null && longestLen > 0) {
            const arr = working[longestKey] as Array<object | string | number | boolean | null>;
            arr.pop();
            trimmedAny = true;
            json = JSON.stringify(working);
        }
    }

    return {
        Json: json.length <= ceiling ? json : json.slice(0, ceiling),
        Truncated: true,
    };
}
