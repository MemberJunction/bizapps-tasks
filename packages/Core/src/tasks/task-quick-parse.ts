import type { mjBizAppsTasksTaskEntity } from '@mj-biz-apps/tasks-entities';

/**
 * Structured output from {@link ParseQuickTaskInput}.
 * All fields are strongly typed against the generated Task entity.
 */
export interface ParsedQuickTask {
    /** Cleaned task title with recognized metadata tokens stripped. */
    Title: string;
    /** Parsed priority if an explicit `!priority` token was supplied, otherwise null. */
    Priority: mjBizAppsTasksTaskEntity['Priority'] | null;
    /** Parsed due date (local end-of-business 17:00) if a date token was supplied, otherwise null. */
    DueAt: Date | null;
    /** Human-readable label for the parsed due date token (e.g. "Tomorrow", "Nov 22"). */
    DueLabel: string | null;
    /** First `@mention` assignee query (without `@`), if present. */
    AssigneeQuery: string | null;
    /** All `@mention` assignee queries (without `@`) in order. */
    AssigneeQueries: string[];
    /** All `#Tag` tokens (without `#`) deduplicated case-insensitively. */
    TagNames: string[];
    /** Parsed estimated effort in hours from `~2h` / `~1.5h` / `~30m`, if present. */
    HoursEstimated: number | null;
}

const PRIORITY_ALIASES: Record<string, mjBizAppsTasksTaskEntity['Priority']> = {
    critical: 'Critical',
    crit: 'Critical',
    urgent: 'Critical',
    p0: 'Critical',
    p1: 'Critical',
    high: 'High',
    hi: 'High',
    p2: 'High',
    medium: 'Medium',
    med: 'Medium',
    normal: 'Medium',
    p3: 'Medium',
    low: 'Low',
    lo: 'Low',
    p4: 'Low',
};

const WEEKDAY_MAP: Record<string, number> = {
    sun: 0, sunday: 0,
    mon: 1, monday: 1,
    tue: 2, tues: 2, tuesday: 2,
    wed: 3, wednesday: 3,
    thu: 4, thur: 4, thurs: 4, thursday: 4,
    fri: 5, friday: 5,
    sat: 6, saturday: 6,
};

const MONTH_MAP: Record<string, number> = {
    jan: 0, january: 0,
    feb: 1, february: 1,
    mar: 2, march: 2,
    apr: 3, april: 3,
    may: 4,
    jun: 5, june: 5,
    jul: 6, july: 6,
    aug: 7, august: 7,
    sep: 8, sept: 8, september: 8,
    oct: 9, october: 9,
    nov: 10, november: 10,
    dec: 11, december: 11,
};

function makeLocalDueDate(year: number, monthIndex: number, day: number): Date {
    return new Date(year, monthIndex, day, 17, 0, 0, 0);
}

function addDays(base: Date, days: number): Date {
    return makeLocalDueDate(base.getFullYear(), base.getMonth(), base.getDate() + days);
}

function nextWeekday(base: Date, targetDow: number): Date {
    const currentDow = base.getDay();
    let delta = (targetDow - currentDow + 7) % 7;
    if (delta === 0) {
        delta = 7;
    }
    return addDays(base, delta);
}

function formatShortDate(d: Date): string {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return `${months[d.getMonth()]} ${d.getDate()}`;
}

/**
 * Parses a natural-language quick-capture string into structured task fields.
 *
 * Supported tokens (all optional, order-independent):
 * - `@Name` or `@First.Last` — assignee query
 * - `#Tag` — tag name (multiple allowed)
 * - `!critical` | `!urgent` | `!high` | `!medium` | `!low` | `!p1..p4` — priority
 * - `~2h` | `~1.5h` | `~45m` — estimated effort in hours
 * - `today` | `tomorrow` | `tmrw` | `next week` | `in 3d` | `fri`/`monday` | `Nov 22` | `2026-11-25` — due date
 *
 * Pure function — deterministic when `referenceDate` is provided.
 */
export function ParseQuickTaskInput(rawInput: string, referenceDate: Date = new Date()): ParsedQuickTask {
    let working = rawInput ?? '';
    let priority: mjBizAppsTasksTaskEntity['Priority'] | null = null;
    let dueAt: Date | null = null;
    let dueLabel: string | null = null;
    let hoursEstimated: number | null = null;
    const assignees: string[] = [];
    const seenAssignees = new Set<string>();
    const tags: string[] = [];
    const seenTags = new Set<string>();

    // 1. Priority tokens (!high, !critical, !p1, etc.)
    working = working.replace(/(^|\s)!([a-z0-9]+)\b/gi, (match, lead: string, token: string) => {
        const mapped = PRIORITY_ALIASES[token.toLowerCase()];
        if (mapped) {
            priority = mapped;
            return lead;
        }
        return match;
    });

    // 2. Effort tokens (~2h, ~1.5h, ~30m)
    working = working.replace(/(^|\s)~(\d+(?:\.\d+)?)(h|hr|hrs|m|min)\b/gi, (match, lead: string, qty: string, unit: string) => {
        const num = parseFloat(qty);
        if (!Number.isFinite(num) || num <= 0) {
            return match;
        }
        hoursEstimated = unit.toLowerCase().startsWith('m')
            ? Math.round((num / 60) * 100) / 100
            : num;
        return lead;
    });

    // 3. @Assignee tokens
    working = working.replace(/(^|\s)@([a-zA-Z][a-zA-Z0-9._-]*)/g, (_match, lead: string, name: string) => {
        const key = name.toLowerCase();
        if (!seenAssignees.has(key)) {
            seenAssignees.add(key);
            assignees.push(name.replace(/[._]/g, ' '));
        }
        return lead;
    });

    // 4. #Tag tokens
    working = working.replace(/(^|\s)#([a-zA-Z][a-zA-Z0-9_-]*)/g, (_match, lead: string, tag: string) => {
        const key = tag.toLowerCase();
        if (!seenTags.has(key)) {
            seenTags.add(key);
            tags.push(tag.replace(/[_-]/g, ' '));
        }
        return lead;
    });

    // 5. Explicit ISO date (YYYY-MM-DD)
    if (!dueAt) {
        working = working.replace(/(^|\s)(\d{4})-(\d{2})-(\d{2})\b/, (_match, lead: string, y: string, m: string, d: string) => {
            const parsed = makeLocalDueDate(Number(y), Number(m) - 1, Number(d));
            if (!Number.isNaN(parsed.getTime())) {
                dueAt = parsed;
                dueLabel = formatShortDate(parsed);
                return lead;
            }
            return _match;
        });
    }

    // 6. Relative "in Nd" / "in Nw"
    if (!dueAt) {
        working = working.replace(/(^|\s)in\s+(\d+)\s*(d|day|days|w|wk|week|weeks)\b/i, (_match, lead: string, qty: string, unit: string) => {
            const mult = unit.toLowerCase().startsWith('w') ? 7 : 1;
            const days = Number(qty) * mult;
            dueAt = addDays(referenceDate, days);
            dueLabel = formatShortDate(dueAt);
            return lead;
        });
    }

    // 7. "next week"
    if (!dueAt) {
        working = working.replace(/(^|\s)next\s+week\b/i, (_match, lead: string) => {
            dueAt = addDays(referenceDate, 7);
            dueLabel = `Next week (${formatShortDate(dueAt)})`;
            return lead;
        });
    }

    // 8. "today" / "tomorrow" / "tmrw"
    if (!dueAt) {
        working = working.replace(/(^|\s)(today|tomorrow|tmrw)\b/i, (_match, lead: string, word: string) => {
            const lower = word.toLowerCase();
            if (lower === 'today') {
                dueAt = addDays(referenceDate, 0);
                dueLabel = 'Today';
            } else {
                dueAt = addDays(referenceDate, 1);
                dueLabel = 'Tomorrow';
            }
            return lead;
        });
    }

    // 9. Month + day (e.g. "Nov 22", "by Dec 5")
    if (!dueAt) {
        working = working.replace(
            /(^|\s)(?:by\s+)?(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:t|tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\s+(\d{1,2})\b/i,
            (match, lead: string, monthWord: string, dayStr: string) => {
                const monthIdx = MONTH_MAP[monthWord.toLowerCase()];
                const day = Number(dayStr);
                if (monthIdx === undefined || day < 1 || day > 31) {
                    return match;
                }
                let year = referenceDate.getFullYear();
                const candidate = makeLocalDueDate(year, monthIdx, day);
                const todayStart = makeLocalDueDate(referenceDate.getFullYear(), referenceDate.getMonth(), referenceDate.getDate());
                if (candidate.getTime() < todayStart.getTime() - 86400000) {
                    year += 1;
                }
                dueAt = makeLocalDueDate(year, monthIdx, day);
                dueLabel = formatShortDate(dueAt);
                return lead;
            }
        );
    }

    // 10. Weekday ("by fri", "next monday", "friday")
    if (!dueAt) {
        working = working.replace(
            /(^|\s)(?:by\s+|next\s+)?(sun(?:day)?|mon(?:day)?|tue(?:s|sday)?|wed(?:nesday)?|thu(?:r|rs|rsday)?|fri(?:day)?|sat(?:urday)?)\b/i,
            (match, lead: string, dayWord: string) => {
                const dow = WEEKDAY_MAP[dayWord.toLowerCase()];
                if (dow === undefined) {
                    return match;
                }
                dueAt = nextWeekday(referenceDate, dow);
                dueLabel = formatShortDate(dueAt);
                return lead;
            }
        );
    }

    const title = working.replace(/\s+/g, ' ').trim();

    return {
        Title: title,
        Priority: priority,
        DueAt: dueAt,
        DueLabel: dueLabel,
        AssigneeQuery: assignees[0] ?? null,
        AssigneeQueries: assignees,
        TagNames: tags,
        HoursEstimated: hoursEstimated,
    };
}
