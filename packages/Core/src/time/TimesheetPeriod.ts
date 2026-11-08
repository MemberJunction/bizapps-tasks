/**
 * Pure timesheet period boundary calculation and schedule resolution (§6.5, §8.4, §11).
 *
 * Uses `@mj-biz-apps/common-entities` calendar-day primitives so all calculations operate on
 * pure `YYYY-MM-DD` calendar dates without host timezone drift.
 */
import {
    AddDays,
    CompareDays,
    FirstDayOfMonth,
    FromCalendarDay,
    IsCalendarDay,
    ToCalendarDay,
    type CalendarDay,
} from '@mj-biz-apps/common-entities';
import type { mjBizAppsTasksTimesheetScheduleEntity } from '@mj-biz-apps/tasks-entities';

/** Cadence union derived from the generated `TimesheetSchedule` entity. */
export type TimesheetCadence = mjBizAppsTasksTimesheetScheduleEntity['Cadence'];

/** Extended period type union including `'OpenEnded'` for contiguous custom-end periods. */
export type TimesheetPeriodType = TimesheetCadence | 'OpenEnded';

/** Week start day name union derived from `TimesheetSchedule`, plus all 7 weekday names or JS day index `0..6`. */
export type WeekdayName =
    | mjBizAppsTasksTimesheetScheduleEntity['WeekStartDay']
    | 'Tuesday'
    | 'Wednesday'
    | 'Thursday'
    | 'Friday';

export type WeekStartDayInput = WeekdayName | number;

const WEEKDAY_NAME_TO_INDEX: Readonly<Record<WeekdayName, number>> = {
    Sunday: 0,
    Monday: 1,
    Tuesday: 2,
    Wednesday: 3,
    Thursday: 4,
    Friday: 5,
    Saturday: 6,
};

const INDEX_TO_WEEKDAY_NAME: readonly WeekdayName[] = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
];

/** Schedule parameters consumed by {@link PeriodFor}. */
export interface PeriodScheduleSpec {
    /** Period cadence (`'Weekly' | 'BiWeekly' | 'SemiMonthly' | 'Monthly' | 'OpenEnded'`). */
    Cadence: TimesheetPeriodType;
    /** First day of the week (`'Monday'`, `'Sunday'`, `'Saturday'`, etc., or `0..6`). Default `'Monday'`. */
    WeekStartDay?: WeekStartDayInput | null;
    /** Anchor date (`YYYY-MM-DD` or `Date`) for `'BiWeekly'` periods, or start anchor for `'OpenEnded'`. */
    BiWeeklyAnchorDate?: CalendarDay | Date | null;
    /**
     * Optional inclusive end date (`YYYY-MM-DD` or `Date`) of the person's most recently submitted
     * timesheet immediately preceding `workDate`. Used to clamp transition periods so a cadence or
     * start-day change never overlaps an already-submitted period, and to start `'OpenEnded'` periods
     * on `AddDays(LastSubmittedPeriodEnd, 1)`.
     */
    LastSubmittedPeriodEnd?: CalendarDay | Date | null;
    /**
     * Explicit end date (`YYYY-MM-DD` or `Date`) when `Cadence === 'OpenEnded'`. Defaults to `workDate`.
     */
    OpenEndedPeriodEnd?: CalendarDay | Date | null;
}

/** Computed inclusive `[PeriodStart, PeriodEnd]` bounds and enumerations of days in the period. */
export interface TimesheetPeriodBounds {
    PeriodStart: CalendarDay;
    PeriodEnd: CalendarDay;
    Cadence: TimesheetPeriodType;
    /** Every calendar day from `PeriodStart` through `PeriodEnd` inclusive, in chronological order. */
    Days: CalendarDay[];
    /** True when `PeriodStart` was clamped forward to avoid overlapping `LastSubmittedPeriodEnd`. */
    IsTransition: boolean;
}

/** Candidate schedule row for {@link ResolveScheduleForDate}. */
export interface EffectiveScheduleCandidate {
    ID?: string;
    PersonID?: string | null;
    ScopeEntityID?: string | null;
    ScopeRecordID?: string | null;
    Cadence: TimesheetCadence;
    WeekStartDay: mjBizAppsTasksTimesheetScheduleEntity['WeekStartDay'];
    BiWeeklyAnchorDate: CalendarDay | Date;
    EffectiveFrom: CalendarDay | Date;
    EffectiveTo?: CalendarDay | Date | null;
}

/**
 * Normalizes a `WeekStartDayInput` (`'Monday'`, `1`, etc.) to a UTC weekday index `0` (Sunday) .. `6` (Saturday).
 */
export function WeekdayIndexFromInput(input?: WeekStartDayInput | null): number {
    if (typeof input === 'number' && Number.isInteger(input) && input >= 0 && input <= 6) {
        return input;
    }
    if (typeof input === 'string') {
        const trimmed = input.trim();
        const match = (Object.keys(WEEKDAY_NAME_TO_INDEX) as WeekdayName[]).find(
            (k) => k.toLowerCase() === trimmed.toLowerCase(),
        );
        if (match) {
            return WEEKDAY_NAME_TO_INDEX[match];
        }
    }
    return 1; // Monday default
}

/**
 * Normalizes a `WeekStartDayInput` to its canonical weekday name (`'Monday'`, `'Sunday'`, etc.).
 */
export function WeekdayNameFromInput(input?: WeekStartDayInput | null): WeekdayName {
    return INDEX_TO_WEEKDAY_NAME[WeekdayIndexFromInput(input)];
}

/**
 * Coerces a `CalendarDay` string or `Date` to a validated `CalendarDay` (`YYYY-MM-DD`), throwing a
 * `RangeError` if invalid.
 */
export function RequireCalendarDay(value: CalendarDay | Date, label: string = 'date'): CalendarDay {
    const day = ToCalendarDay(value);
    if (!day || !IsCalendarDay(day)) {
        throw new RangeError(`Invalid ${label}: ${String(value)}`);
    }
    return day;
}

/**
 * Enumerates every `CalendarDay` in `[startDay, endDay]` inclusive.
 */
export function EnumerateDays(startDay: CalendarDay, endDay: CalendarDay): CalendarDay[] {
    if (CompareDays(endDay, startDay) < 0) {
        return [];
    }
    const days: CalendarDay[] = [];
    let cursor = startDay;
    while (CompareDays(cursor, endDay) <= 0) {
        days.push(cursor);
        cursor = AddDays(cursor, 1);
    }
    return days;
}

/**
 * Returns the last calendar day of the month containing `day` (handling leap-year Februaries).
 */
export function LastDayOfMonth(day: CalendarDay): CalendarDay {
    const d = FromCalendarDay(day);
    const year = d.getUTCFullYear();
    const month = d.getUTCMonth(); // 0-based
    const firstOfNextMonth = new Date(Date.UTC(year, month + 1, 1));
    const firstNextDay = ToCalendarDay(firstOfNextMonth)!;
    return AddDays(firstNextDay, -1);
}

/**
 * Computes the 7-day week bounds `[PeriodStart, PeriodEnd]` containing `workDate` for a given `weekStartDay`.
 */
export function WeekBoundsFor(
    workDate: CalendarDay | Date,
    weekStartDay: WeekStartDayInput = 'Monday',
): { WeekStart: CalendarDay; WeekEnd: CalendarDay; Days: CalendarDay[] } {
    const targetDay = RequireCalendarDay(workDate, 'workDate');
    const startDow = WeekdayIndexFromInput(weekStartDay);
    const d = FromCalendarDay(targetDay);
    const currentDow = d.getUTCDay();
    const offsetBack = (currentDow - startDow + 7) % 7;
    const weekStart = AddDays(targetDay, -offsetBack);
    const weekEnd = AddDays(weekStart, 6);
    return {
        WeekStart: weekStart,
        WeekEnd: weekEnd,
        Days: EnumerateDays(weekStart, weekEnd),
    };
}

/**
 * Computes the inclusive timesheet period `[PeriodStart, PeriodEnd]` containing `workDate` under `schedule` (§6.5, §11).
 *
 * - `'Weekly'`: 7-day period starting on `WeekStartDay`.
 * - `'BiWeekly'`: 14-day period aligned to `BiWeeklyAnchorDate` (default `'2026-01-05'`). Works for dates
 *   before and after the anchor.
 * - `'SemiMonthly'`: `1st..15th` and `16th..end-of-month` (28th/29th in Feb, 30th, or 31st).
 * - `'Monthly'`: `1st..end-of-month`.
 * - `'OpenEnded'`: starts on `AddDays(LastSubmittedPeriodEnd, 1)` (or `BiWeeklyAnchorDate` / `workDate` when
 *   no prior submission exists) and ends on `OpenEndedPeriodEnd ?? workDate`.
 *
 * When `LastSubmittedPeriodEnd` is supplied and precedes or equals `workDate`, any computed `PeriodStart`
 * that would overlap (`<= LastSubmittedPeriodEnd`) is clamped forward to `AddDays(LastSubmittedPeriodEnd, 1)`
 * and marked with `IsTransition: true`.
 */
export function PeriodFor(workDate: CalendarDay | Date, schedule: PeriodScheduleSpec): TimesheetPeriodBounds {
    const day = RequireCalendarDay(workDate, 'workDate');
    const lastSubEnd =
        schedule.LastSubmittedPeriodEnd != null ? RequireCalendarDay(schedule.LastSubmittedPeriodEnd, 'LastSubmittedPeriodEnd') : null;

    let periodStart: CalendarDay;
    let periodEnd: CalendarDay;

    switch (schedule.Cadence) {
        case 'Weekly': {
            const bounds = WeekBoundsFor(day, schedule.WeekStartDay ?? 'Monday');
            periodStart = bounds.WeekStart;
            periodEnd = bounds.WeekEnd;
            break;
        }
        case 'BiWeekly': {
            const rawAnchor = schedule.BiWeeklyAnchorDate ? ToCalendarDay(schedule.BiWeeklyAnchorDate) : '2026-01-05';
            const anchorDay = rawAnchor && IsCalendarDay(rawAnchor) ? rawAnchor : '2026-01-05';
            const anchorMs = FromCalendarDay(anchorDay).getTime();
            const targetMs = FromCalendarDay(day).getTime();
            const diffDays = Math.round((targetMs - anchorMs) / 86_400_000);
            const periodIndex = Math.floor(diffDays / 14);
            periodStart = AddDays(anchorDay, periodIndex * 14);
            periodEnd = AddDays(periodStart, 13);
            break;
        }
        case 'SemiMonthly': {
            const dom = Number.parseInt(day.slice(8, 10), 10);
            const ym = day.slice(0, 7);
            if (dom <= 15) {
                periodStart = `${ym}-01`;
                periodEnd = `${ym}-15`;
            } else {
                periodStart = `${ym}-16`;
                periodEnd = LastDayOfMonth(day);
            }
            break;
        }
        case 'Monthly': {
            periodStart = FirstDayOfMonth(day);
            periodEnd = LastDayOfMonth(day);
            break;
        }
        case 'OpenEnded': {
            const explicitEnd = schedule.OpenEndedPeriodEnd ? RequireCalendarDay(schedule.OpenEndedPeriodEnd, 'OpenEndedPeriodEnd') : day;
            if (lastSubEnd) {
                periodStart = AddDays(lastSubEnd, 1);
            } else if (schedule.BiWeeklyAnchorDate) {
                periodStart = RequireCalendarDay(schedule.BiWeeklyAnchorDate, 'BiWeeklyAnchorDate');
            } else {
                periodStart = day;
            }
            periodEnd = CompareDays(explicitEnd, periodStart) >= 0 ? explicitEnd : periodStart;
            return {
                PeriodStart: periodStart,
                PeriodEnd: periodEnd,
                Cadence: 'OpenEnded',
                Days: EnumerateDays(periodStart, periodEnd),
                IsTransition: false,
            };
        }
        default: {
            const bounds = WeekBoundsFor(day, schedule.WeekStartDay ?? 'Monday');
            periodStart = bounds.WeekStart;
            periodEnd = bounds.WeekEnd;
            break;
        }
    }

    let isTransition = false;
    if (lastSubEnd && CompareDays(lastSubEnd, day) < 0 && CompareDays(periodStart, lastSubEnd) <= 0 && CompareDays(lastSubEnd, periodEnd) < 0) {
        periodStart = AddDays(lastSubEnd, 1);
        isTransition = true;
    }

    return {
        PeriodStart: periodStart,
        PeriodEnd: periodEnd,
        Cadence: schedule.Cadence,
        Days: EnumerateDays(periodStart, periodEnd),
        IsTransition: isTransition,
    };
}

/**
 * Resolves the effective `TimesheetSchedule` row for `workDate` from a list of candidate rows.
 *
 * Precedence among active schedules covering `workDate` (`EffectiveFrom <= workDate <= EffectiveTo`):
 * 1. Person-specific schedule (`PersonID` matches `personID`)
 * 2. Entity-scoped schedule (`ScopeEntityID` & `ScopeRecordID` set)
 * 3. Global schedule (`PersonID == null && ScopeEntityID == null`)
 * Within the same specificity tier, the most recent `EffectiveFrom` wins.
 */
export function ResolveScheduleForDate<T extends EffectiveScheduleCandidate>(
    workDate: CalendarDay | Date,
    schedules: readonly T[],
    personID?: string | null,
): T | null {
    const day = RequireCalendarDay(workDate, 'workDate');
    const normPerson = personID?.trim().toLowerCase() ?? null;

    const matching = schedules.filter((s) => {
        const from = ToCalendarDay(s.EffectiveFrom);
        if (!from || CompareDays(from, day) > 0) return false;
        if (s.EffectiveTo != null) {
            const to = ToCalendarDay(s.EffectiveTo);
            if (to && CompareDays(to, day) < 0) return false;
        }
        if (s.PersonID) {
            return normPerson != null && s.PersonID.trim().toLowerCase() === normPerson;
        }
        return true;
    });

    if (matching.length === 0) return null;

    const tierOf = (s: T): number => {
        if (s.PersonID && normPerson && s.PersonID.trim().toLowerCase() === normPerson) return 3;
        if (s.ScopeEntityID && s.ScopeRecordID) return 2;
        return 1;
    };

    const sorted = [...matching].sort((a, b) => {
        const tierDiff = tierOf(b) - tierOf(a);
        if (tierDiff !== 0) return tierDiff;
        const fromA = ToCalendarDay(a.EffectiveFrom) ?? '';
        const fromB = ToCalendarDay(b.EffectiveFrom) ?? '';
        return CompareDays(fromB, fromA);
    });

    return sorted[0] ?? null;
}
