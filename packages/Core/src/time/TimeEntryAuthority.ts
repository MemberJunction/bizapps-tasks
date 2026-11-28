/**
 * Pure authorization and business-rule checks for `TaskTimeEntry` create, update, and delete (§6.1 R1–R8).
 *
 * Kept free of MemberJunction database access so every rule can be unit-tested in isolation;
 * `TaskTimeEntryEntityServer` gathers the facts on the server and calls {@link TimeEntryRefusal}.
 */
import { AddDays, CompareDays, IsCalendarDay, ToCalendarDay, type CalendarDay } from '@mj-biz-apps/common-entities';
import type { mjBizAppsTasksTimesheetEntity } from '@mj-biz-apps/tasks-entities';
import { MAX_ENTRY_MINUTES } from './DurationFormatting.js';

/** Timesheet status union derived from the generated `Timesheet` entity. */
export type TimesheetLifecycleStatus = mjBizAppsTasksTimesheetEntity['Status'];

/** Summary of a timesheet that covers the entry's old or new `WorkDate` (or `TimesheetID`). */
export interface CoveringTimesheetFact {
    ID: string;
    PeriodStart: CalendarDay;
    PeriodEnd: CalendarDay;
    Status: TimesheetLifecycleStatus;
}

/** Facts required by {@link TimeEntryRefusal} to decide whether a create, update, or delete is allowed. */
export interface TimeEntryFacts {
    /** Operation being performed on the time entry. */
    Operation: 'create' | 'update' | 'delete';
    /** Every `Person.ID` bound to the signed-in user (`PeopleFilterForUser`). */
    CallerPersonIDs: readonly string[];
    /** Whether the signed-in user holds the `Tasks / Manage Time Entries` authorization. */
    CallerCanManageTimeEntries: boolean;
    /** Target `PersonID` on the time entry (after defaulting to caller's primary Person on create). */
    EntryPersonID: string | null;
    /** Prior `PersonID` when `Operation === 'update'`. */
    OriginalPersonID?: string | null;
    /** Optional display name of the entry's person for human-friendly refusal messages. */
    EntryPersonName?: string | null;
    /** Whether the target `TaskID` exists and is readable by the caller (checked on create or `TaskID` change). */
    TaskExists: boolean;
    /** Target `WorkDate` (`YYYY-MM-DD`). */
    WorkDate: CalendarDay | null;
    /** Prior `WorkDate` (`YYYY-MM-DD`) when `Operation === 'update'`. */
    OriginalWorkDate?: CalendarDay | null;
    /** Today's calendar day (`YYYY-MM-DD`) in the business timezone, for rule R5 (future-date guard). */
    TodayInBusinessZone?: CalendarDay | null;
    /** Whole minutes (`1..1440`) on the entry. */
    Minutes: number;
    /** Optional interval start timestamp. */
    StartedAt?: Date | string | null;
    /** Optional interval end timestamp. */
    EndedAt?: Date | string | null;
    /** Whether `LockApprovedTimeEntries` is enabled (defaults to `true`). */
    LockApprovedTimeEntries?: boolean;
    /** Timesheets belonging to the entry's person (and prior person, if changed) that cover the old or new `WorkDate` or `TimesheetID`. */
    CoveringTimesheets: readonly CoveringTimesheetFact[];
    /** Descriptions/labels of any `TaskTimeEntryLink` records pointing at this entry (checked on update/delete for rule R8). */
    LinkedRecordDescriptions?: readonly string[];
}

const sameId = (a: string | null | undefined, b: string | null | undefined): boolean =>
    !!a && !!b && a.trim().toLowerCase() === b.trim().toLowerCase();

/** Statuses that lock a timesheet period against time entry edits (D14, R6). */
export const LOCKED_TIMESHEET_STATUSES: readonly TimesheetLifecycleStatus[] = ['Submitted', 'Approved'];

/**
 * Computes `Minutes` from `[startedAt, endedAt]` rounded to the nearest minute with a minimum of `1` (§6.1 R4).
 * Returns `null` if either endpoint is missing or invalid, or if `endedAt < startedAt`.
 */
export function DeriveIntervalMinutes(
    startedAt: Date | string | null | undefined,
    endedAt: Date | string | null | undefined,
): number | null {
    if (startedAt == null || endedAt == null) return null;
    const startMs = startedAt instanceof Date ? startedAt.getTime() : new Date(startedAt).getTime();
    const endMs = endedAt instanceof Date ? endedAt.getTime() : new Date(endedAt).getTime();
    if (Number.isNaN(startMs) || Number.isNaN(endMs) || endMs < startMs) {
        return null;
    }
    const raw = Math.round((endMs - startMs) / 60_000);
    return Math.min(MAX_ENTRY_MINUTES, Math.max(1, raw));
}

/**
 * Evaluates rules R1–R8 (§6.1) for a `TaskTimeEntry` create, update, or delete.
 *
 * @returns A human-readable refusal sentence when the operation must be rejected, or `null` when allowed.
 */
export function TimeEntryRefusal(facts: TimeEntryFacts): string | null {
    // R1: PersonID must resolve on create
    if (!facts.EntryPersonID || facts.EntryPersonID.trim() === '') {
        return "You can't log time: your user has no person record.";
    }

    // R2: Owner or Manage Time Entries authorization
    const isTargetMine = facts.CallerPersonIDs.some((p) => sameId(p, facts.EntryPersonID));
    const isOriginalMine =
        facts.OriginalPersonID == null || facts.CallerPersonIDs.some((p) => sameId(p, facts.OriginalPersonID));

    if (!facts.CallerCanManageTimeEntries && (!isTargetMine || !isOriginalMine)) {
        const who = facts.EntryPersonName?.trim() || 'the entry owner';
        return `Only ${who} or a time-entry manager can change this entry.`;
    }

    // R8: Linked entry lock (checked on update and delete)
    if (
        (facts.Operation === 'update' || facts.Operation === 'delete') &&
        facts.LinkedRecordDescriptions &&
        facts.LinkedRecordDescriptions.length > 0
    ) {
        const firstLink = facts.LinkedRecordDescriptions[0] || 'a linked record';
        return `This entry is used by ${firstLink}. Remove that link to change it.`;
    }

    // R6: Locked timesheet period check (applies to create, update, and delete)
    const lockEnabled = facts.LockApprovedTimeEntries !== false;
    if (lockEnabled && facts.CoveringTimesheets.length > 0) {
        const workDay = facts.WorkDate ? ToCalendarDay(facts.WorkDate) : null;
        const origDay = facts.OriginalWorkDate ? ToCalendarDay(facts.OriginalWorkDate) : null;

        for (const ts of facts.CoveringTimesheets) {
            if (!LOCKED_TIMESHEET_STATUSES.includes(ts.Status)) continue;
            const coversCurrent =
                workDay != null &&
                CompareDays(workDay, ts.PeriodStart) >= 0 &&
                CompareDays(workDay, ts.PeriodEnd) <= 0;
            const coversOriginal =
                origDay != null &&
                CompareDays(origDay, ts.PeriodStart) >= 0 &&
                CompareDays(origDay, ts.PeriodEnd) <= 0;
            if (coversCurrent || coversOriginal) {
                return `The period ${ts.PeriodStart} to ${ts.PeriodEnd} is ${ts.Status}. Reopen it to change its time.`;
            }
        }
    }

    if (facts.Operation === 'delete') {
        return null;
    }

    // R3: Task must exist and be readable by caller
    if (!facts.TaskExists) {
        return 'The task was not found.';
    }

    // Validate WorkDate
    const workDay = facts.WorkDate ? ToCalendarDay(facts.WorkDate) : null;
    if (!workDay || !IsCalendarDay(workDay)) {
        return 'WorkDate must be a valid calendar date (YYYY-MM-DD).';
    }

    // R5: WorkDate may not be more than 1 day after today in the business timezone
    if (facts.TodayInBusinessZone && IsCalendarDay(facts.TodayInBusinessZone)) {
        const maxAllowedDay = AddDays(facts.TodayInBusinessZone, 1);
        if (CompareDays(workDay, maxAllowedDay) > 0) {
            return "Time can't be logged for a future day.";
        }
    }

    // Validate interval if provided
    const hasStart = facts.StartedAt != null;
    const hasEnd = facts.EndedAt != null;
    if (hasStart !== hasEnd) {
        return 'StartedAt and EndedAt must either both be provided or both be omitted.';
    }
    if (hasStart && hasEnd) {
        const startMs = facts.StartedAt instanceof Date ? facts.StartedAt.getTime() : new Date(facts.StartedAt!).getTime();
        const endMs = facts.EndedAt instanceof Date ? facts.EndedAt.getTime() : new Date(facts.EndedAt!).getTime();
        if (Number.isNaN(startMs) || Number.isNaN(endMs) || endMs < startMs) {
            return 'End time must be on or after the start time.';
        }
    }

    // Validate Minutes range (1..1440)
    if (!Number.isInteger(facts.Minutes) || facts.Minutes < 1 || facts.Minutes > MAX_ENTRY_MINUTES) {
        return `Minutes worked must be a whole number between 1 and ${MAX_ENTRY_MINUTES}.`;
    }

    return null;
}
