import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

const configMock = vi.fn();
const getCredentialMock = vi.fn();

vi.mock('@memberjunction/global', () => ({
    RegisterClass: () => () => {},
    MJGlobal: { Instance: { ClassFactory: { CreateInstance: () => null } } },
}));

vi.mock('@memberjunction/core', () => ({
    LogError: vi.fn(),
}));

vi.mock('@memberjunction/credentials', () => ({
    CredentialEngine: {
        Instance: {
            Config: (...args: unknown[]) => configMock(...args),
            GetCredential: (...args: unknown[]) => getCredentialMock(...args),
        },
    },
}));

import { ZoomVideoProvider } from '../video/ZoomVideoProvider.js';
import type { UserInfo } from '@memberjunction/core';

const USER = { ID: 'user-1' } as unknown as UserInfo;

describe('ZoomVideoProvider', () => {
    const fetchMock = vi.fn();

    beforeEach(() => {
        configMock.mockReset();
        getCredentialMock.mockReset();
        fetchMock.mockReset();
        vi.stubGlobal('fetch', fetchMock);
    });

    afterEach(() => {
        vi.unstubAllGlobals();
    });

    it('resolves credentials through CredentialEngine and reports IsConfigured', async () => {
        getCredentialMock.mockResolvedValueOnce({
            values: {
                client_id: 'zoom-client-id',
                client_secret: 'zoom-client-secret',
                account_id: 'zoom-account-id',
            },
        });

        const driver = new ZoomVideoProvider();
        await driver.Initialize(
            {
                ProviderID: 'vp-zoom',
                CredentialID: 'cred-zoom-1',
                Configuration: JSON.stringify({ host_user: 'meetings@example.org' }),
            },
            USER,
        );

        expect(driver.IsConfigured).toBe(true);
        expect(configMock).toHaveBeenCalledWith(false, USER);
        expect(getCredentialMock).toHaveBeenCalledWith('', {
            credentialId: 'cred-zoom-1',
            contextUser: USER,
            subsystem: 'VideoProvider',
        });
    });

    it('creates, updates, and deletes a Zoom meeting and checks HTTP status on every call', async () => {
        getCredentialMock.mockResolvedValue({
            values: {
                client_id: 'cid',
                client_secret: 'csec',
                account_id: 'acc-1',
            },
        });

        const driver = new ZoomVideoProvider();
        await driver.Initialize({ ProviderID: 'vp-zoom', CredentialID: 'cred-1', Configuration: null }, USER);

        // 1. CreateMeeting: token + POST /users/me/meetings
        fetchMock
            .mockResolvedValueOnce({
                ok: true,
                status: 200,
                json: async () => ({ access_token: 'tok-1', token_type: 'bearer', expires_in: 3600 }),
            })
            .mockResolvedValueOnce({
                ok: true,
                status: 201,
                json: async () => ({
                    id: 987654321,
                    join_url: 'https://zoom.us/j/987654321',
                    settings: {
                        global_dial_in_numbers: [{ country_name: 'US', number: '+1 312 626 6799' }],
                    },
                }),
            });

        const created = await driver.CreateMeeting(
            {
                Title: 'Quarterly Planning',
                StartsAt: new Date('2026-11-15T15:00:00Z'),
                EndsAt: new Date('2026-11-15T16:30:00Z'),
                TimeZone: 'America/Chicago',
                Description: 'Review Q1 roadmap',
            },
            USER,
        );

        expect(created).toEqual({
            JoinURL: 'https://zoom.us/j/987654321',
            ProviderMeetingID: '987654321',
            DialInDetails: 'US: +1 312 626 6799',
        });

        // 2. UpdateMeeting: token + PATCH /meetings/987654321
        fetchMock
            .mockResolvedValueOnce({
                ok: true,
                status: 200,
                json: async () => ({ access_token: 'tok-2', token_type: 'bearer', expires_in: 3600 }),
            })
            .mockResolvedValueOnce({
                ok: true,
                status: 204,
                text: async () => '',
            });

        await driver.UpdateMeeting(
            '987654321',
            {
                Title: 'Quarterly Planning (Moved)',
                StartsAt: new Date('2026-11-15T17:00:00Z'),
                EndsAt: new Date('2026-11-15T18:00:00Z'),
                TimeZone: 'America/Chicago',
            },
            USER,
        );

        expect(fetchMock.mock.calls[3][0]).toBe('https://api.zoom.us/v2/meetings/987654321');
        expect(fetchMock.mock.calls[3][1]).toMatchObject({ method: 'PATCH' });

        // 3. DeleteMeeting: token + DELETE /meetings/987654321
        fetchMock
            .mockResolvedValueOnce({
                ok: true,
                status: 200,
                json: async () => ({ access_token: 'tok-3', token_type: 'bearer', expires_in: 3600 }),
            })
            .mockResolvedValueOnce({
                ok: true,
                status: 204,
                text: async () => '',
            });

        await driver.DeleteMeeting('987654321', USER);
        expect(fetchMock.mock.calls[5][0]).toBe('https://api.zoom.us/v2/meetings/987654321');
        expect(fetchMock.mock.calls[5][1]).toMatchObject({ method: 'DELETE' });
    });

    it('throws when Zoom returns a non-2xx status', async () => {
        getCredentialMock.mockResolvedValue({
            values: { client_id: 'cid', client_secret: 'csec', account_id: 'acc-1' },
        });
        const driver = new ZoomVideoProvider();
        await driver.Initialize({ ProviderID: 'vp-zoom', CredentialID: 'cred-1', Configuration: null }, USER);

        fetchMock
            .mockResolvedValueOnce({
                ok: true,
                status: 200,
                json: async () => ({ access_token: 'tok-1', token_type: 'bearer', expires_in: 3600 }),
            })
            .mockResolvedValueOnce({
                ok: false,
                status: 400,
                text: async () => 'Invalid start_time',
            });

        await expect(
            driver.CreateMeeting(
                {
                    Title: 'Bad Meeting',
                    StartsAt: new Date('2026-11-15T15:00:00Z'),
                    EndsAt: new Date('2026-11-15T16:00:00Z'),
                    TimeZone: 'UTC',
                },
                USER,
            ),
        ).rejects.toThrow(/Zoom create meeting failed \(400\): Invalid start_time/);
    });
});
