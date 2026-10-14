import { describe, it, expect } from 'vitest';
import { callerAdministersMeetings, callerIsOrganizer } from '../meeting-access.js';
import type { IMetadataProvider, UserInfo } from '@memberjunction/core';

const UI = 'R0000000-0000-4000-8000-000000000001';
const DEV = 'R0000000-0000-4000-8000-000000000002';
const READER = 'R0000000-0000-4000-8000-000000000003';
const provider = {
    Roles: [
        { ID: UI, Name: 'UI' },
        { ID: DEV, Name: 'Developer' },
        { ID: READER, Name: 'Reader' },
    ],
    Entities: [
        {
            Name: 'MJ_BizApps_Tasks: Meetings',
            Permissions: [
                { RoleID: UI, CanUpdate: true },
                { RoleID: DEV, CanUpdate: true },
                { RoleID: READER, CanUpdate: false },
            ],
        },
    ],
} as unknown as IMetadataProvider;
const withRoles = (...roleIds: string[]): UserInfo => ({ ID: 'U', UserRoles: roleIds.map((RoleID) => ({ RoleID })) }) as unknown as UserInfo;

describe('who may change every meeting', () => {
    it('is someone with a role above UI that updates Meetings', () => {
        expect(callerAdministersMeetings(provider, withRoles(UI, DEV))).toBe(true);
    });

    it('is not a UI-only person, nor a role that only reads', () => {
        expect(callerAdministersMeetings(provider, withRoles(UI))).toBe(false);
        expect(callerAdministersMeetings(provider, withRoles(UI, READER))).toBe(false);
        expect(callerAdministersMeetings(provider, withRoles())).toBe(false);
    });

    it('compares ids without regard to case', () => {
        expect(callerAdministersMeetings(provider, withRoles(DEV.toLowerCase()))).toBe(true);
    });
});

describe('the organizer', () => {
    it('is the caller whose Person is the organizer\'s', () => {
        expect(callerIsOrganizer('p1', 'P1')).toBe(true);
        expect(callerIsOrganizer('p1', 'p2')).toBe(false);
        expect(callerIsOrganizer(null, 'p2')).toBe(false);
    });
});
