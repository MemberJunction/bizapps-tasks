import { TasksLimitsResolver } from '../config/TasksLimits.js';
import type {
    AssigneeFreeBusySummary,
    ProjectFreeBusyAvailability,
    SanitizedBusyInterval,
    SanitizedBusyStatus,
} from './project-risk-types.js';

const MS_PER_MINUTE = 60_000;
const AVAILABILITY_PRECISION_FACTOR = 10_000;

/**
 * Lowercase field names strictly forbidden inside any calendar free/busy payload
 * entering Project Risk Analyst prompt context or persisted risk assessments.
 */
export const FORBIDDEN_CALENDAR_SENSITIVE_FIELDS: readonly string[] = [
    'subject',
    'body',
    'bodypreview',
    'title',
    'summary',
    'description',
    'location',
    'locations',
    'attendees',
    'organizer',
    'notes',
    'content',
    'snippet',
    'categories',
    'weblink',
    'onlinemeetingurl',
] as const;

const FORBIDDEN_CALENDAR_FIELD_SET = new Set<string>(FORBIDDEN_CALENDAR_SENSITIVE_FIELDS);

/** Error thrown when sensitive calendar fields attempt to cross the free/busy privacy boundary. */
export class FreeBusyPrivacyViolationError extends Error {
    public readonly OffendingFields: readonly string[];

    constructor(offendingFields: readonly string[], message?: string) {
        const unique = [...new Set(offendingFields)];
        super(
            message ??
                `Calendar free/busy privacy boundary violation: forbidden field(s) detected [${unique.join(', ')}].`,
        );
        this.name = 'FreeBusyPrivacyViolationError';
        this.OffendingFields = unique;
    }
}

/**
 * Strongly-typed raw calendar slot input accepted by the privacy guard.
 * Sensitive fields are typed explicitly so the sanitizer can detect and strip or reject them
 * with zero `any` or `unknown` casts.
 */
export interface RawFreeBusySlotInput {
    StartTime: Date | string;
    EndTime: Date | string;
    Status?: string | null;
    Subject?: string | null;
    subject?: string | null;
    Body?: string | object | null;
    body?: string | object | null;
    BodyPreview?: string | null;
    bodyPreview?: string | null;
    Title?: string | null;
    title?: string | null;
    Summary?: string | null;
    summary?: string | null;
    Description?: string | null;
    description?: string | null;
    Location?: string | object | null;
    location?: string | object | null;
    Locations?: readonly object[] | readonly string[] | null;
    locations?: readonly object[] | readonly string[] | null;
    Attendees?: readonly object[] | readonly string[] | null;
    attendees?: readonly object[] | readonly string[] | null;
    Organizer?: string | object | null;
    organizer?: string | object | null;
    Notes?: string | null;
    notes?: string | null;
    Content?: string | null;
    content?: string | null;
}

/** Options governing how {@link SanitizeFreeBusySlots} handles forbidden calendar properties. */
export interface SanitizeFreeBusyOptions {
    /**
     * - `'strip'` (default): removes all non-free/busy fields and emits strictly `{ StartISO, EndISO, BusyMinutes, Status }`.
     * - `'reject'`: throws {@link FreeBusyPrivacyViolationError} if any forbidden calendar field is present.
     */
    mode?: 'strip' | 'reject';
}

export interface BuildAssigneeFreeBusyInput {
    personId: string | null;
    userId: string | null;
    availabilityKey?: string;
    windowStart: Date;
    windowEnd: Date;
    slots: readonly RawFreeBusySlotInput[];
    mode?: 'strip' | 'reject';
}

/** Value union accepted while recursively inspecting objects for forbidden calendar keys. */
export type InspectableCalendarNode =
    | object
    | string
    | number
    | boolean
    | Date
    | null
    | undefined;

function toValidDate(value: Date | string | null | undefined): Date | null {
    if (value == null) return null;
    const d = value instanceof Date ? value : new Date(value);
    return Number.isNaN(d.getTime()) ? null : d;
}

function normalizeBusyStatus(raw: string | null | undefined): SanitizedBusyStatus | null {
    if (!raw) return 'Busy';
    const norm = raw.trim().toLowerCase().replace(/[\s_-]+/g, '');
    switch (norm) {
        case 'busy':
            return 'Busy';
        case 'tentative':
            return 'Tentative';
        case 'oof':
        case 'outofoffice':
            return 'OutOfOffice';
        case 'workingelsewhere':
            return 'WorkingElsewhere';
        case 'free':
        case 'unknown':
            return null;
        default:
            return 'Busy';
    }
}

function hasNonEmptyValue(value: InspectableCalendarNode): boolean {
    if (value == null) return false;
    if (typeof value === 'string') return value.trim().length > 0;
    if (Array.isArray(value)) return value.length > 0;
    return true;
}

function collectSensitivePaths(
    node: InspectableCalendarNode,
    path: string,
    depth: number,
    maxDepth: number,
    out: string[],
): void {
    if (node == null || typeof node !== 'object' || node instanceof Date) {
        return;
    }
    if (depth >= maxDepth) {
        return;
    }
    if (Array.isArray(node)) {
        for (let i = 0; i < node.length; i++) {
            collectSensitivePaths(node[i] as InspectableCalendarNode, `${path}[${i}]`, depth + 1, maxDepth, out);
        }
        return;
    }

    for (const [key, val] of Object.entries(node)) {
        const nextPath = path ? `${path}.${key}` : key;
        if (FORBIDDEN_CALENDAR_FIELD_SET.has(key.toLowerCase()) && hasNonEmptyValue(val as InspectableCalendarNode)) {
            out.push(nextPath);
            continue;
        }
        if (val != null && typeof val === 'object') {
            collectSensitivePaths(val as InspectableCalendarNode, nextPath, depth + 1, maxDepth, out);
        }
    }
}

/**
 * Recursively inspects a calendar payload or slot list and returns any forbidden sensitive
 * calendar field paths (`subject`, `body`, `title`, `description`, `location`, `attendees`, etc.).
 */
export function FindSensitiveCalendarFields(input: object | readonly object[], prefix = ''): string[] {
    const maxDepth = TasksLimitsResolver.Instance.GetCurrentLimits().RunawayGuards.MaxHierarchyDepth;
    const found: string[] = [];
    collectSensitivePaths(input, prefix, 0, maxDepth, found);
    return found;
}

/**
 * Deterministic calendar free/busy sanitizer & guard.
 *
 * Emits ONLY `[StartISO, EndISO, BusyMinutes, Status]` for non-free intervals clamped to
 * `[windowStart, windowEnd]`. When `mode === 'reject'`, rejects any input carrying forbidden
 * sensitive calendar fields (`subject`, `body`, `title`, `description`, `location`, `attendees`).
 */
export function SanitizeFreeBusySlots(
    slots: readonly RawFreeBusySlotInput[],
    windowStart: Date,
    windowEnd: Date,
    options: SanitizeFreeBusyOptions = {},
): SanitizedBusyInterval[] {
    const startMs = windowStart.getTime();
    const endMs = windowEnd.getTime();
    if (!Number.isFinite(startMs) || !Number.isFinite(endMs) || endMs <= startMs) {
        return [];
    }

    if (options.mode === 'reject') {
        const offending = FindSensitiveCalendarFields(slots, 'slots');
        if (offending.length > 0) {
            throw new FreeBusyPrivacyViolationError(offending);
        }
    }

    const sanitized: SanitizedBusyInterval[] = [];
    for (const slot of slots) {
        if (!slot || typeof slot !== 'object') continue;
        const status = normalizeBusyStatus(slot.Status);
        if (!status) continue;

        const slotStart = toValidDate(slot.StartTime);
        const slotEnd = toValidDate(slot.EndTime);
        if (!slotStart || !slotEnd) continue;

        const clampedStart = Math.max(startMs, slotStart.getTime());
        const clampedEnd = Math.min(endMs, slotEnd.getTime());
        if (clampedEnd <= clampedStart) continue;

        const busyMinutes = Math.round((clampedEnd - clampedStart) / MS_PER_MINUTE);
        if (busyMinutes <= 0) continue;

        sanitized.push({
            StartISO: new Date(clampedStart).toISOString(),
            EndISO: new Date(clampedEnd).toISOString(),
            BusyMinutes: busyMinutes,
            Status: status,
        });
    }

    return sanitized.sort((a, b) => a.StartISO.localeCompare(b.StartISO));
}

/**
 * Merges overlapping busy intervals so aggregate busy time is never double-counted.
 */
export function MergeBusyIntervals(intervals: readonly SanitizedBusyInterval[]): SanitizedBusyInterval[] {
    if (intervals.length === 0) return [];
    const sorted = [...intervals].sort((a, b) => a.StartISO.localeCompare(b.StartISO));
    const merged: SanitizedBusyInterval[] = [{ ...sorted[0] }];

    for (let i = 1; i < sorted.length; i++) {
        const current = sorted[i];
        const last = merged[merged.length - 1];
        const currentStartMs = new Date(current.StartISO).getTime();
        const currentEndMs = new Date(current.EndISO).getTime();
        const lastStartMs = new Date(last.StartISO).getTime();
        const lastEndMs = new Date(last.EndISO).getTime();

        if (currentStartMs <= lastEndMs) {
            const combinedEndMs = Math.max(lastEndMs, currentEndMs);
            last.EndISO = new Date(combinedEndMs).toISOString();
            last.BusyMinutes = Math.max(1, Math.round((combinedEndMs - lastStartMs) / MS_PER_MINUTE));
            if (last.Status !== 'Busy' && current.Status === 'Busy') {
                last.Status = 'Busy';
            }
        } else {
            merged.push({ ...current });
        }
    }

    return merged;
}

/**
 * Builds an anonymized, privacy-safe free/busy availability summary for one project assignee.
 */
export function BuildAssigneeFreeBusySummary(input: BuildAssigneeFreeBusyInput): AssigneeFreeBusySummary {
    const startMs = input.windowStart.getTime();
    const endMs = input.windowEnd.getTime();
    const totalWindowMinutes =
        Number.isFinite(startMs) && Number.isFinite(endMs) && endMs > startMs
            ? Math.round((endMs - startMs) / MS_PER_MINUTE)
            : 0;

    const sanitized = SanitizeFreeBusySlots(input.slots, input.windowStart, input.windowEnd, {
        mode: input.mode ?? 'strip',
    });
    const merged = MergeBusyIntervals(sanitized);
    const busyMinutes = Math.min(
        totalWindowMinutes,
        merged.reduce((sum, interval) => sum + interval.BusyMinutes, 0),
    );
    const freeMinutes = Math.max(0, totalWindowMinutes - busyMinutes);
    const availabilityRatio =
        totalWindowMinutes > 0
            ? Math.round((freeMinutes / totalWindowMinutes) * AVAILABILITY_PRECISION_FACTOR) /
              AVAILABILITY_PRECISION_FACTOR
            : 1;

    const fallbackKey = input.personId
        ? `person:${input.personId}`
        : input.userId
          ? `user:${input.userId}`
          : 'assignee';

    return {
        PersonID: input.personId,
        UserID: input.userId,
        AvailabilityKey: input.availabilityKey?.trim() || fallbackKey,
        WindowStartISO: input.windowStart.toISOString(),
        WindowEndISO: input.windowEnd.toISOString(),
        TotalWindowMinutes: totalWindowMinutes,
        BusyMinutes: busyMinutes,
        FreeMinutes: freeMinutes,
        AvailabilityRatio: availabilityRatio,
        BusyIntervals: merged,
    };
}

/**
 * Aggregates assignee free/busy summaries into a project-level availability snapshot.
 */
export function AggregateProjectFreeBusy(input: {
    windowStart: Date;
    windowEnd: Date;
    assignees: readonly AssigneeFreeBusySummary[];
}): ProjectFreeBusyAvailability {
    const assignees = [...input.assignees];
    const totalBusyMinutes = assignees.reduce((sum, a) => sum + a.BusyMinutes, 0);
    const totalFreeMinutes = assignees.reduce((sum, a) => sum + a.FreeMinutes, 0);
    const averageAvailabilityRatio =
        assignees.length > 0
            ? Math.round(
                  (assignees.reduce((sum, a) => sum + a.AvailabilityRatio, 0) / assignees.length) *
                      AVAILABILITY_PRECISION_FACTOR,
              ) / AVAILABILITY_PRECISION_FACTOR
            : 1;

    return {
        WindowStartISO: input.windowStart.toISOString(),
        WindowEndISO: input.windowEnd.toISOString(),
        AssigneeCount: assignees.length,
        AverageAvailabilityRatio: averageAvailabilityRatio,
        TotalBusyMinutes: totalBusyMinutes,
        TotalFreeMinutes: totalFreeMinutes,
        Assignees: assignees,
    };
}

/**
 * Final pre-LLM privacy firewall verifying that a free/busy availability payload contains
 * zero sensitive calendar fields before any prompt execution occurs.
 */
export function AssertFreeBusyPromptPayloadIsClean(freeBusy: ProjectFreeBusyAvailability): void {
    const offending = FindSensitiveCalendarFields(freeBusy, 'freeBusy');
    if (offending.length > 0) {
        throw new FreeBusyPrivacyViolationError(offending);
    }
}
