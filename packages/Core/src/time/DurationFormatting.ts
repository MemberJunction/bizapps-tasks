/**
 * Pure duration parsing, formatting, and rounding helpers for Tasks time tracking.
 *
 * Kept free of MemberJunction runtime state so they can be imported anywhere (browser or server)
 * and unit-tested deterministically.
 */

/** Elapsed minutes threshold (12 hours) above which the UI warns about a long-running timer (§6.2). */
export const LONG_RUNNING_TIMER_WARNING_MINUTES = 12 * 60;

/** Maximum minutes allowed on a single `TaskTimeEntry` row (24 hours). */
export const MAX_ENTRY_MINUTES = 1440;

/**
 * Parses a human duration input into positive whole minutes (`1..1440`), or returns `null` when invalid.
 *
 * Supported formats:
 * - Positive numbers: `90` -> `90`, `1.5` (when passed as a number, treated as minutes rounded to nearest int)
 * - Hours and minutes: `"1h 30m"`, `"1 hr 30 min"`, `"2h"`, `"45m"`
 * - Colon `H:MM` / `HH:MM`: `"1:30"` -> `90`, `"0:15"` -> `15`
 * - Decimal hours with unit or decimal point: `"1.5h"`, `"1.5 hrs"`, `"1.5"` -> `90`, `"0.25"` -> `15`
 * - Plain integer string (minutes): `"90"` -> `90`
 *
 * @param input Raw duration string or number.
 * @returns Positive integer minutes (`>= 1`), or `null` if empty, zero, negative, or unparseable.
 */
export function ParseDurationMinutes(input: string | number | null | undefined): number | null {
    if (input == null) return null;
    if (typeof input === 'number') {
        if (!Number.isFinite(input) || input <= 0) return null;
        const rounded = Math.round(input);
        return rounded >= 1 ? rounded : null;
    }

    const trimmed = input.trim().toLowerCase();
    if (!trimmed) return null;

    // 1. Colon format: H:MM or HH:MM
    const colonMatch = /^(\d+):([0-5]\d)$/.exec(trimmed);
    if (colonMatch) {
        const hours = Number.parseInt(colonMatch[1], 10);
        const mins = Number.parseInt(colonMatch[2], 10);
        const total = hours * 60 + mins;
        return total >= 1 ? total : null;
    }

    // 2. Explicit hours + optional minutes: e.g. "1h 30m", "1.5h", "2 hrs 15 mins", "2h15m"
    const hmMatch = /^(\d+(?:\.\d+)?)\s*(?:h|hr|hrs|hour|hours)(?:\s*(\d+(?:\.\d+)?)\s*(?:m|min|mins|minute|minutes)?)?$/.exec(
        trimmed,
    );
    if (hmMatch) {
        const hours = Number.parseFloat(hmMatch[1]);
        const mins = hmMatch[2] != null ? Number.parseFloat(hmMatch[2]) : 0;
        const total = Math.round(hours * 60 + mins);
        return total >= 1 ? total : null;
    }

    // 3. Explicit minutes only: e.g. "90m", "45 mins", "15 minutes"
    const mOnlyMatch = /^(\d+(?:\.\d+)?)\s*(?:m|min|mins|minute|minutes)$/.exec(trimmed);
    if (mOnlyMatch) {
        const total = Math.round(Number.parseFloat(mOnlyMatch[1]));
        return total >= 1 ? total : null;
    }

    // 4. Plain decimal with a decimal point (e.g. "1.5", "0.25", "2.0") -> hours per §8.2 ("1h 30m, 1.5, or 90m")
    if (/^\d+\.\d+$/.test(trimmed)) {
        const hours = Number.parseFloat(trimmed);
        const total = Math.round(hours * 60);
        return total >= 1 ? total : null;
    }

    // 5. Plain integer string -> minutes (e.g. "90", "15")
    if (/^\d+$/.test(trimmed)) {
        const total = Number.parseInt(trimmed, 10);
        return total >= 1 ? total : null;
    }

    return null;
}

/**
 * Formats a minute total as a compact human-readable label (e.g. `90` -> `"1h 30m"`, `45` -> `"45m"`, `120` -> `"2h"`).
 *
 * @param minutes Whole minutes (negative or null/undefined returns `"0m"`).
 */
export function FormatDurationMinutes(minutes: number | null | undefined): string {
    if (minutes == null || !Number.isFinite(minutes) || minutes <= 0) {
        return '0m';
    }
    const whole = Math.round(minutes);
    const hrs = Math.floor(whole / 60);
    const mins = whole % 60;
    if (hrs > 0 && mins > 0) {
        return `${hrs}h ${mins}m`;
    }
    if (hrs > 0) {
        return `${hrs}h`;
    }
    return `${mins}m`;
}

/**
 * Formats a minute total as `H:MM` clock notation for compact weekly/period grid cells (e.g. `90` -> `"1:30"`, `30` -> `"0:30"`).
 * Returns `""` when `minutes` is null, undefined, or `<= 0`.
 */
export function FormatDurationClock(minutes: number | null | undefined): string {
    if (minutes == null || !Number.isFinite(minutes) || minutes <= 0) {
        return '';
    }
    const whole = Math.round(minutes);
    const hrs = Math.floor(whole / 60);
    const mins = whole % 60;
    return `${hrs}:${String(mins).padStart(2, '0')}`;
}

/**
 * Applies an optional upward minute-rounding increment (`0`, `1`, `5`, `6`, `15`, `30`) to a positive minute count,
 * clamping to `[1, 1440]`.
 */
export function ApplyMinuteRounding(rawMinutes: number, roundingMinutes: number = 0): number {
    const base = Math.max(1, Math.round(rawMinutes));
    if (roundingMinutes <= 1) {
        return Math.min(MAX_ENTRY_MINUTES, base);
    }
    const rounded = Math.ceil(base / roundingMinutes) * roundingMinutes;
    return Math.min(MAX_ENTRY_MINUTES, Math.max(1, rounded));
}
