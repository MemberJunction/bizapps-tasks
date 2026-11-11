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

    it('reads ApprovalReassignRoles as a comma-separated list, empty by default', () => {
        expect(TasksSettings.ApprovalReassignRoles(provider)).toEqual([]);
        settings.set('ApprovalReassignRoles', ' Finance Admin , ,Integration ');
        expect(TasksSettings.ApprovalReassignRoles(provider)).toEqual(['Finance Admin', 'Integration']);
    });

    it('offers no in-process way to override a setting (the guard has no kill switch)', () => {
        const members = Object.getOwnPropertyNames(TasksSettings);
        expect(members).not.toContain('SetOverride');
        expect(members).not.toContain('ClearOverrides');
        expect(members.filter((m) => /override/i.test(m))).toEqual([]);
        expect(Object.keys(settingsModule).filter((k) => /override/i.test(k))).toEqual([]);
    });
});
