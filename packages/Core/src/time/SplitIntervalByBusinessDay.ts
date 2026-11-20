/**
 * Splits a UTC `[startedAt, endedAt]` timer interval across calendar day boundaries in a business
 * IANA timezone (§6.2).
 *
 * Uses `@mj-biz-apps/common-entities` calendar-day primitives (`CalendarDayIn`, `AddDays`, `CompareDays`,
 * `DayStartUtc`, `IsKnownTimeZone`, `UTC_ZONE`) so midnight boundaries and DST transitions (23-hour
 * spring-forward and 25-hour fall-back days) are computed identically on browser and server.
 */
import {
    AddDays,
    CalendarDayIn,
    CompareDays,
    DayStartUtc,
    IsKnownTimeZone,
    UTC_ZONE,
    type CalendarDay,
} from '@mj-biz-apps/common-entities';
import { ApplyMinuteRounding, MAX_ENTRY_MINUTES } from './DurationFormatting.js';

/** One business-day slice produced by {@link SplitIntervalByBusinessDay}. */
export interface TimerDaySegment {
    /** Calendar day (`YYYY-MM-DD`) in the resolved business timezone. */
    WorkDate: CalendarDay;
    /** Segment start instant (UTC). */
    StartedAt: Date;
    /** Segment end instant (UTC). */
    EndedAt: Date;
    /** Unrounded whole minutes (`Math.round(seconds / 60)`), at least `1`. */
    RawMinutes: number;
    /** Rounded whole minutes (`1..1440`) after applying `roundingMinutes`. */
    Minutes: number;
}

/**
 * Resolves a candidate IANA timezone string, falling back to `'UTC'` when blank or unknown.
 */
export function ResolveTimeZoneOrUtc(timeZone?: string | null): string {
    const trimmed = (timeZone ?? '').trim();
    return trimmed && IsKnownTimeZone(trimmed) ? trimmed : UTC_ZONE;
}

/**
 * Cuts `[startedAt, endedAt]` at each local midnight in `timeZone`, rounds each piece to the nearest
 * minute (`Math.round(seconds / 60)`), drops zero-minute pieces, and returns at least one 1-minute
 * piece on the start day if every piece rounded to zero (§6.2).
 *
 * @param startedAt Timer start instant.
 * @param endedAt Timer stop instant.
 * @param timeZone IANA business timezone (defaults to `'UTC'` if omitted or invalid).
 * @param roundingMinutes Optional upward minute rounding increment (`0 | 1 | 5 | 6 | 15 | 30`).
 */
export function SplitIntervalByBusinessDay(
    startedAt: Date,
    endedAt: Date,
    timeZone?: string | null,
    roundingMinutes: number = 0,
): TimerDaySegment[] {
    const zone = ResolveTimeZoneOrUtc(timeZone);
    const startMs = startedAt.getTime();
    const endMs = endedAt.getTime();
    const startDay = CalendarDayIn(startedAt, zone);

    if (endMs <= startMs) {
        const safeEnd = new Date(Math.max(endMs, startMs + 1000));
        return [
            {
                WorkDate: startDay,
                StartedAt: new Date(startMs),
                EndedAt: safeEnd,
                RawMinutes: 1,
                Minutes: ApplyMinuteRounding(1, roundingMinutes),
            },
        ];
    }

    const endDay = CalendarDayIn(endedAt, zone);
    const rawSegments: Array<{ WorkDate: CalendarDay; StartedAt: Date; EndedAt: Date; RawMinutes: number }> = [];

    let currentDay = startDay;
    let cursorMs = startMs;

    while (CompareDays(currentDay, endDay) <= 0 && cursorMs < endMs) {
        const nextDay = AddDays(currentDay, 1);
        const nextMidnightMs = DayStartUtc(nextDay, zone).getTime();
        const segmentEndMs = CompareDays(currentDay, endDay) < 0 ? Math.min(endMs, nextMidnightMs) : endMs;

        if (segmentEndMs > cursorMs) {
            const elapsedSeconds = (segmentEndMs - cursorMs) / 1000;
            const roundedMinutes = Math.min(MAX_ENTRY_MINUTES, Math.round(elapsedSeconds / 60));
            if (roundedMinutes > 0) {
                rawSegments.push({
                    WorkDate: currentDay,
                    StartedAt: new Date(cursorMs),
                    EndedAt: new Date(segmentEndMs),
                    RawMinutes: roundedMinutes,
                });
            }
            cursorMs = segmentEndMs;
        } else {
            // Guard against non-advancing midnight in unusual historical zones
            cursorMs = Math.min(endMs, cursorMs + 60000);
        }

        currentDay = nextDay;
    }

    if (rawSegments.length === 0) {
        return [
            {
                WorkDate: startDay,
                StartedAt: new Date(startMs),
                EndedAt: new Date(endMs),
                RawMinutes: 1,
                Minutes: ApplyMinuteRounding(1, roundingMinutes),
            },
        ];
    }

    return rawSegments.map((seg) => ({
        WorkDate: seg.WorkDate,
        StartedAt: seg.StartedAt,
        EndedAt: seg.EndedAt,
        RawMinutes: seg.RawMinutes,
        Minutes: ApplyMinuteRounding(seg.RawMinutes, roundingMinutes),
    }));
}
