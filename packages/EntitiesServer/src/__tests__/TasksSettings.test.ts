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
const settingsModule = await import('../TasksSettings.js');
const { TasksSettings } = settingsModule;
const provider = Metadata.Provider;

describe('TasksSettings', () => {
    beforeEach(() => settings.clear());

    it('reads PreventSelfApproval from the Tasks application setting, off by default', () => {
        expect(TasksSettings.PreventSelfApproval(provider)).toBe(false);
        settings.set('PreventSelfApproval', 'true');
        expect(TasksSettings.PreventSelfApproval(provider)).toBe(true);
        settings.set('PreventSelfApproval', 'garbage');
        expect(TasksSettings.PreventSelfApproval(provider)).toBe(false);
    });

    it('reads SelfApprovalExemptRole as a list: one name (the original format) or comma-separated names', () => {
        expect(TasksSettings.SelfApprovalExemptRoles(provider)).toEqual([]);
        settings.set('SelfApprovalExemptRole', ' CEO Approver ');
        expect(TasksSettings.SelfApprovalExemptRoles(provider)).toEqual(['CEO Approver']);
        settings.set('SelfApprovalExemptRole', 'CEO Approver, ,CFO');
        expect(TasksSettings.SelfApprovalExemptRoles(provider)).toEqual(['CEO Approver', 'CFO']);
        settings.set('SelfApprovalExemptRole', '  ');
        expect(TasksSettings.SelfApprovalExemptRoles(provider)).toEqual([]);
    });

    it('reads ApprovalReassignRoles as a comma-separated list, empty by default', () => {
        expect(TasksSettings.ApprovalReassignRoles(provider)).toEqual([]);
        settings.set('ApprovalReassignRoles', ' Finance Admin , ,Integration ');
        expect(TasksSettings.ApprovalReassignRoles(provider)).toEqual(['Finance Admin', 'Integration']);
    });

    it('reads DefaultCalendarProviderName and SharedCalendarMailbox, null when unset or blank', () => {
        expect(TasksSettings.DefaultCalendarProviderName(provider)).toBeNull();
        expect(TasksSettings.SharedCalendarMailbox(provider)).toBeNull();
        settings.set('DefaultCalendarProviderName', ' Microsoft Graph ');
        settings.set('SharedCalendarMailbox', ' calendar@example.com ');
        expect(TasksSettings.DefaultCalendarProviderName(provider)).toBe('Microsoft Graph');
        expect(TasksSettings.SharedCalendarMailbox(provider)).toBe('calendar@example.com');
    });

    it('offers no in-process way to override a setting (the guard has no kill switch)', () => {
        const members = Object.getOwnPropertyNames(TasksSettings);
        expect(members).not.toContain('SetOverride');
        expect(members).not.toContain('ClearOverrides');
        expect(members.filter((m) => /override/i.test(m))).toEqual([]);
        expect(Object.keys(settingsModule).filter((k) => /override/i.test(k))).toEqual([]);
    });
});
