/**
 * Typed access to the Tasks app's settings (`__mj.ApplicationSetting` rows scoped to the `Tasks` Application).
 *
 * Shared between `@mj-biz-apps/tasks-core`, `@mj-biz-apps/tasks-entities-server`, `@mj-biz-apps/tasks-server`,
 * and `@mj-biz-apps/tasks-ng` so client and server code read the same setting keys, defaults, and coercions.
 *
 * CONNECTS TO:
 *   ENGINE: ApplicationSettingEngine (@memberjunction/core-entities)
 *   TABLE:  __mj.ApplicationSetting, scoped to the 'Tasks' Application row
 *   ROWS:   metadata/application-settings/.tasks-settings.json
 */
import { ApplicationSettingEngine } from '@memberjunction/core-entities';
import type { IMetadataProvider, UserInfo } from '@memberjunction/core';
import type { mjBizAppsTasksTimesheetScheduleEntity } from '@mj-biz-apps/tasks-entities';

/** The `MJ: Applications` row this app's settings hang off. */
export const TASKS_APPLICATION_NAME = 'Tasks';

/** Valid timesheet approval routing modes. */
export type TimesheetApprovalRoutingMode = 'ProjectApproval' | 'SingleApproval' | 'AutoApprove';

/** Setting keys, in one place so a typo is a compile error rather than a silent default. */
export const TASKS_SETTING = {
    /**
     * Whether a decision on an approval task must come from one of its assignees, attributed to that
     * assignee, and not from the person who created the task (bc-aidp-next-golive#320 §3). Off by
     * default, which leaves every decision accepted as before.
     */
    PreventSelfApproval: 'PreventSelfApproval',
    /**
     * The NAME of the MJ role whose holders may decide an approval task they created themselves while
     * `PreventSelfApproval` is on. They must still be an assignee. Empty exempts nobody.
     */
    SelfApprovalExemptRole: 'SelfApprovalExemptRole',
    /**
     * Turns on the time tracking UI and the timer operations (`Tasks.StartTimer`, `Tasks.StopTimer`).
     */
    TimeTrackingEnabled: 'TimeTrackingEnabled',
    /**
     * Turns on the My Time nav item, timesheet submission, withdrawal, reopen, and approval routing.
     */
    TimesheetsEnabled: 'TimesheetsEnabled',
    /**
     * Alias for `TimesheetsEnabled` used by hosts configuring timesheet approval explicitly.
     */
    TimesheetApprovalEnabled: 'TimesheetApprovalEnabled',
    /**
     * Default timesheet period cadence when no `TimesheetSchedule` row applies:
     * `'Weekly' | 'BiWeekly' | 'SemiMonthly' | 'Monthly'`.
     */
    TimesheetCadence: 'TimesheetCadence',
    /**
     * Alias for `TimesheetCadence`.
     */
    TimesheetPeriodType: 'TimesheetPeriodType',
    /**
     * Default first day of the week for `Weekly` and `BiWeekly` timesheet periods and the My Time weekly grid:
     * `'Monday' | 'Sunday' | 'Saturday'`.
     */
    TimesheetWeekStartDay: 'TimesheetWeekStartDay',
    /**
     * Anchor date (`YYYY-MM-DD`) defining the 14-day period boundary for `BiWeekly` timesheets.
     */
    TimesheetBiWeeklyAnchorDate: 'TimesheetBiWeeklyAnchorDate',
    /**
     * Timesheet approval routing mode: `'ProjectApproval' | 'SingleApproval' | 'AutoApprove'`.
     */
    TimesheetApprovalRouting: 'TimesheetApprovalRouting',
    /**
     * When true, `TaskTimeEntry` rows cannot be created, modified, or deleted on `Submitted` or `Approved`
     * timesheets, or on dates within a `Submitted` or `Approved` timesheet period.
     */
    LockApprovedTimeEntries: 'LockApprovedTimeEntries',
    /**
     * Soft warning threshold (in minutes) for a person's total logged time on a single `WorkDate` in the
     * My Time UI (default 720 = 12 hours; hard DB cap is 1440 per entry).
     */
    MaxDailyLoggedMinutes: 'MaxDailyLoggedMinutes',
    /**
     * Optional minute rounding increment applied when stopping a timer (0 = exact 1-minute rounding,
     * 5, 6, 15, or 30 = round up to nearest N minutes).
     */
    TimeEntryRoundingMinutes: 'TimeEntryRoundingMinutes',
    /**
     * When true, people may configure their own `TimesheetSchedule` row. Otherwise only holders of
     * `Manage Timesheets` may create or modify `TimesheetSchedule` rows.
     */
    TimesheetSchedulesSelfService: 'TimesheetSchedulesSelfService',
    /**
     * When true, a resubmitted timesheet requests re-approval on every part even if an `Approved` part's
     * `SnapshotHash` did not change.
     */
    TimesheetResubmitReapprovesAll: 'TimesheetResubmitReapprovesAll',
    /**
     * Optional name of a person-to-person `MJ_BizApps_Common: Relationship Types` row used as a fallback
     * when no `TimeApprover` rule matches (`FromPersonID` = worker, `ToPersonID` = approver).
     */
    TimesheetApproverRelationshipType: 'TimesheetApproverRelationshipType',
    /**
     * Optional name of an `MJ: Roles` row whose linked People act as fallback time approvers when no
     * `TimeApprover` rule or relationship matches.
     */
    TimesheetApproverRole: 'TimesheetApproverRole',
} as const;

export type TasksSettingKey = (typeof TASKS_SETTING)[keyof typeof TASKS_SETTING];

const VALID_CADENCES: ReadonlySet<mjBizAppsTasksTimesheetScheduleEntity['Cadence']> = new Set([
    'Weekly',
    'BiWeekly',
    'SemiMonthly',
    'Monthly',
]);

const VALID_WEEK_START_DAYS: ReadonlySet<mjBizAppsTasksTimesheetScheduleEntity['WeekStartDay']> = new Set([
    'Monday',
    'Saturday',
    'Sunday',
]);

const VALID_ROUTING_MODES: ReadonlySet<TimesheetApprovalRoutingMode> = new Set([
    'ProjectApproval',
    'SingleApproval',
    'AutoApprove',
]);

/** Coerces a raw setting string to boolean, falling back when absent or unrecognised. */
function asBoolean(raw: string | undefined, fallback: boolean): boolean {
    if (raw == null) return fallback;
    const v = raw.trim().toLowerCase();
    if (['true', '1', 'yes', 'on'].includes(v)) return true;
    if (['false', '0', 'no', 'off', ''].includes(v)) return false;
    return fallback;
}

/** Coerces a raw setting string to an integer within `[min, max]`, falling back when invalid. */
function asInt(raw: string | undefined, fallback: number, min: number, max: number): number {
    if (raw == null || raw.trim() === '') return fallback;
    const parsed = Number.parseInt(raw.trim(), 10);
    if (!Number.isFinite(parsed) || parsed < min || parsed > max) return fallback;
    return parsed;
}

/**
 * Deliberately read-only façade over `ApplicationSettingEngine` for the `Tasks` application.
 */
export class TasksSettings {
    /** Load the settings cache. Idempotent and cheap after the first call. */
    public static async Load(provider: IMetadataProvider, user?: UserInfo): Promise<void> {
        await ApplicationSettingEngine.Instance.Config(false, user ?? provider?.CurrentUser, provider);
    }

    private static raw(key: TasksSettingKey, provider: IMetadataProvider): string | undefined {
        const appID = provider.Applications?.find((a) => a.Name === TASKS_APPLICATION_NAME)?.ID;
        if (!appID) return undefined;
        return ApplicationSettingEngine.Instance.GetSetting(key, appID);
    }

    /** Whether approval decisions are limited to assignees other than the requester. Default `false`. */
    public static PreventSelfApproval(provider: IMetadataProvider): boolean {
        return asBoolean(this.raw(TASKS_SETTING.PreventSelfApproval, provider), false);
    }

    /** The role exempt from the self-approval refusal, or `null` when none is configured. */
    public static SelfApprovalExemptRole(provider: IMetadataProvider): string | null {
        const value = this.raw(TASKS_SETTING.SelfApprovalExemptRole, provider)?.trim();
        return value ? value : null;
    }

    /** Whether time tracking UI and timer operations are enabled. Default `true`. */
    public static TimeTrackingEnabled(provider: IMetadataProvider): boolean {
        return asBoolean(this.raw(TASKS_SETTING.TimeTrackingEnabled, provider), true);
    }

    /** Whether timesheet submission and approval are enabled. Default `true`. */
    public static TimesheetsEnabled(provider: IMetadataProvider): boolean {
        const explicitApproval = this.raw(TASKS_SETTING.TimesheetApprovalEnabled, provider);
        if (explicitApproval != null && explicitApproval.trim() !== '') {
            return asBoolean(explicitApproval, true);
        }
        return asBoolean(this.raw(TASKS_SETTING.TimesheetsEnabled, provider), true);
    }

    /** Alias for {@link TimesheetsEnabled}. */
    public static TimesheetApprovalEnabled(provider: IMetadataProvider): boolean {
        return this.TimesheetsEnabled(provider);
    }

    /** Default timesheet period cadence (`'Weekly' | 'BiWeekly' | 'SemiMonthly' | 'Monthly'`). Default `'Weekly'`. */
    public static TimesheetCadence(provider: IMetadataProvider): mjBizAppsTasksTimesheetScheduleEntity['Cadence'] {
        const raw = (
            this.raw(TASKS_SETTING.TimesheetCadence, provider) ??
            this.raw(TASKS_SETTING.TimesheetPeriodType, provider)
        )?.trim() as mjBizAppsTasksTimesheetScheduleEntity['Cadence'] | undefined;
        if (raw && VALID_CADENCES.has(raw)) {
            return raw;
        }
        return 'Weekly';
    }

    /** Default first day of the work week (`'Monday' | 'Saturday' | 'Sunday'`). Default `'Monday'`. */
    public static TimesheetWeekStartDay(provider: IMetadataProvider): mjBizAppsTasksTimesheetScheduleEntity['WeekStartDay'] {
        const raw = this.raw(TASKS_SETTING.TimesheetWeekStartDay, provider)?.trim() as
            | mjBizAppsTasksTimesheetScheduleEntity['WeekStartDay']
            | undefined;
        if (raw && VALID_WEEK_START_DAYS.has(raw)) {
            return raw;
        }
        return 'Monday';
    }

    /** Default anchor date (`YYYY-MM-DD`) for `BiWeekly` timesheets. Default `'2026-01-05'`. */
    public static TimesheetBiWeeklyAnchorDate(provider: IMetadataProvider): string {
        const raw = this.raw(TASKS_SETTING.TimesheetBiWeeklyAnchorDate, provider)?.trim();
        if (raw && /^\d{4}-\d{2}-\d{2}$/.test(raw)) {
            return raw;
        }
        return '2026-01-05';
    }

    /** Timesheet approval routing mode. Default `'ProjectApproval'`. */
    public static TimesheetApprovalRouting(provider: IMetadataProvider): TimesheetApprovalRoutingMode {
        const raw = this.raw(TASKS_SETTING.TimesheetApprovalRouting, provider)?.trim() as
            | TimesheetApprovalRoutingMode
            | undefined;
        if (raw && VALID_ROUTING_MODES.has(raw)) {
            return raw;
        }
        return 'ProjectApproval';
    }

    /** Whether `Submitted` and `Approved` timesheets lock their time entries. Default `true`. */
    public static LockApprovedTimeEntries(provider: IMetadataProvider): boolean {
        return asBoolean(this.raw(TASKS_SETTING.LockApprovedTimeEntries, provider), true);
    }

    /** Soft daily warning threshold in minutes. Default `720` (12 hours). */
    public static MaxDailyLoggedMinutes(provider: IMetadataProvider): number {
        return asInt(this.raw(TASKS_SETTING.MaxDailyLoggedMinutes, provider), 720, 1, 1440);
    }

    /** Timer stop rounding increment in minutes (`0`, `1`, `5`, `6`, `15`, or `30`). Default `0`. */
    public static TimeEntryRoundingMinutes(provider: IMetadataProvider): number {
        const val = asInt(this.raw(TASKS_SETTING.TimeEntryRoundingMinutes, provider), 0, 0, 60);
        return [0, 1, 5, 6, 15, 30].includes(val) ? val : 0;
    }

    /** Whether workers may edit their own `TimesheetSchedule` without `Manage Timesheets`. Default `false`. */
    public static TimesheetSchedulesSelfService(provider: IMetadataProvider): boolean {
        return asBoolean(this.raw(TASKS_SETTING.TimesheetSchedulesSelfService, provider), false);
    }

    /** Whether resubmitting a timesheet forces re-approval of unchanged `Approved` parts. Default `false`. */
    public static TimesheetResubmitReapprovesAll(provider: IMetadataProvider): boolean {
        return asBoolean(this.raw(TASKS_SETTING.TimesheetResubmitReapprovesAll, provider), false);
    }

    /** Fallback Common relationship type name for resolving a worker's time approver, or `null`. */
    public static TimesheetApproverRelationshipType(provider: IMetadataProvider): string | null {
        const val = this.raw(TASKS_SETTING.TimesheetApproverRelationshipType, provider)?.trim();
        return val ? val : null;
    }

    /** Fallback MJ role name whose holders can approve time when no rule or relationship matches, or `null`. */
    public static TimesheetApproverRole(provider: IMetadataProvider): string | null {
        const val = this.raw(TASKS_SETTING.TimesheetApproverRole, provider)?.trim();
        return val ? val : null;
    }
}
