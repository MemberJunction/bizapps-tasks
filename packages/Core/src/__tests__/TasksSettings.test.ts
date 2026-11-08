import { beforeEach, describe, expect, it, vi } from 'vitest';

const APP_ID = 'A0000000-0000-0000-0000-0000000000AA';
const settings = new Map<string, string>();

vi.mock('@memberjunction/core-entities', () => ({
    ApplicationSettingEngine: {
        Instance: {
            Config: vi.fn(async () => undefined),
            GetSetting: (name: string, appID?: string) => (appID === APP_ID ? settings.get(name) : undefined),
        },
    },
}));

vi.mock('@memberjunction/core', () => ({
    Metadata: { Provider: { Applications: [{ Name: 'Tasks', ID: APP_ID }] } },
}));

const { Metadata } = await import('@memberjunction/core');
const settingsModule = await import('../config/TasksSettings.js');
const { TasksSettings } = settingsModule;
const provider = Metadata.Provider;

describe('TasksSettings (@mj-biz-apps/tasks-core)', () => {
    beforeEach(() => settings.clear());

    it('reads PreventSelfApproval and SelfApprovalExemptRole with safe defaults', () => {
        expect(TasksSettings.PreventSelfApproval(provider)).toBe(false);
        expect(TasksSettings.SelfApprovalExemptRole(provider)).toBeNull();

        settings.set('PreventSelfApproval', 'true');
        settings.set('SelfApprovalExemptRole', ' Finance Admin ');
        expect(TasksSettings.PreventSelfApproval(provider)).toBe(true);
        expect(TasksSettings.SelfApprovalExemptRole(provider)).toBe('Finance Admin');

        settings.set('PreventSelfApproval', 'garbage');
        expect(TasksSettings.PreventSelfApproval(provider)).toBe(false);
    });

    it('reads TimeTrackingEnabled and TimesheetsEnabled / TimesheetApprovalEnabled', () => {
        expect(TasksSettings.TimeTrackingEnabled(provider)).toBe(true);
        expect(TasksSettings.TimesheetsEnabled(provider)).toBe(true);
        expect(TasksSettings.TimesheetApprovalEnabled(provider)).toBe(true);

        settings.set('TimeTrackingEnabled', 'false');
        settings.set('TimesheetsEnabled', '0');
        expect(TasksSettings.TimeTrackingEnabled(provider)).toBe(false);
        expect(TasksSettings.TimesheetsEnabled(provider)).toBe(false);

        settings.set('TimesheetApprovalEnabled', 'yes');
        expect(TasksSettings.TimesheetApprovalEnabled(provider)).toBe(true);
    });

    it('reads cadence, week start day, bi-weekly anchor date, and routing mode with validation', () => {
        expect(TasksSettings.TimesheetCadence(provider)).toBe('Weekly');
        expect(TasksSettings.TimesheetWeekStartDay(provider)).toBe('Monday');
        expect(TasksSettings.TimesheetBiWeeklyAnchorDate(provider)).toBe('2026-01-05');
        expect(TasksSettings.TimesheetApprovalRouting(provider)).toBe('ProjectApproval');

        settings.set('TimesheetCadence', 'SemiMonthly');
        settings.set('TimesheetWeekStartDay', 'Sunday');
        settings.set('TimesheetBiWeeklyAnchorDate', '2026-02-01');
        settings.set('TimesheetApprovalRouting', 'SingleApproval');

        expect(TasksSettings.TimesheetCadence(provider)).toBe('SemiMonthly');
        expect(TasksSettings.TimesheetWeekStartDay(provider)).toBe('Sunday');
        expect(TasksSettings.TimesheetBiWeeklyAnchorDate(provider)).toBe('2026-02-01');
        expect(TasksSettings.TimesheetApprovalRouting(provider)).toBe('SingleApproval');

        settings.set('TimesheetCadence', 'InvalidCadence');
        settings.set('TimesheetWeekStartDay', 'Wednesday');
        settings.set('TimesheetBiWeeklyAnchorDate', 'not-a-date');
        settings.set('TimesheetApprovalRouting', 'UnknownMode');

        expect(TasksSettings.TimesheetCadence(provider)).toBe('Weekly');
        expect(TasksSettings.TimesheetWeekStartDay(provider)).toBe('Monday');
        expect(TasksSettings.TimesheetBiWeeklyAnchorDate(provider)).toBe('2026-01-05');
        expect(TasksSettings.TimesheetApprovalRouting(provider)).toBe('ProjectApproval');
    });

    it('reads numeric and boolean timesheet/rounding/fallback settings', () => {
        expect(TasksSettings.LockApprovedTimeEntries(provider)).toBe(true);
        expect(TasksSettings.MaxDailyLoggedMinutes(provider)).toBe(720);
        expect(TasksSettings.TimeEntryRoundingMinutes(provider)).toBe(0);
        expect(TasksSettings.TimesheetSchedulesSelfService(provider)).toBe(false);
        expect(TasksSettings.TimesheetResubmitReapprovesAll(provider)).toBe(false);
        expect(TasksSettings.TimesheetApproverRelationshipType(provider)).toBeNull();
        expect(TasksSettings.TimesheetApproverRole(provider)).toBeNull();

        settings.set('LockApprovedTimeEntries', 'false');
        settings.set('MaxDailyLoggedMinutes', '600');
        settings.set('TimeEntryRoundingMinutes', '15');
        settings.set('TimesheetSchedulesSelfService', 'true');
        settings.set('TimesheetResubmitReapprovesAll', '1');
        settings.set('TimesheetApproverRelationshipType', 'Reports To');
        settings.set('TimesheetApproverRole', 'Timesheet Approver');

        expect(TasksSettings.LockApprovedTimeEntries(provider)).toBe(false);
        expect(TasksSettings.MaxDailyLoggedMinutes(provider)).toBe(600);
        expect(TasksSettings.TimeEntryRoundingMinutes(provider)).toBe(15);
        expect(TasksSettings.TimesheetSchedulesSelfService(provider)).toBe(true);
        expect(TasksSettings.TimesheetResubmitReapprovesAll(provider)).toBe(true);
        expect(TasksSettings.TimesheetApproverRelationshipType(provider)).toBe('Reports To');
        expect(TasksSettings.TimesheetApproverRole(provider)).toBe('Timesheet Approver');

        settings.set('TimeEntryRoundingMinutes', '7'); // unsupported increment falls back to 0
        expect(TasksSettings.TimeEntryRoundingMinutes(provider)).toBe(0);
    });

    it('offers no in-process way to override a setting', () => {
        const members = Object.getOwnPropertyNames(TasksSettings);
        expect(members).not.toContain('SetOverride');
        expect(members).not.toContain('ClearOverrides');
        expect(members.filter((m) => /override/i.test(m))).toEqual([]);
        expect(Object.keys(settingsModule).filter((k) => /override/i.test(k))).toEqual([]);
    });
});
