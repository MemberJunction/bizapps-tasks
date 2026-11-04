import { type UserInfo } from '@memberjunction/core';
import { CredentialEngine } from '@memberjunction/credentials';
import { RegisterClass } from '@memberjunction/global';
import {
    VideoProviderBase,
    type VideoMeetingInput,
    type VideoMeetingResult,
    type VideoProviderContext,
} from './VideoProviderBase.js';

interface ZoomTokenResponse {
    access_token: string;
    token_type: string;
    expires_in: number;
}

interface ZoomCreateMeetingResponse {
    id: number | string;
    join_url: string;
    start_url?: string;
    settings?: {
        global_dial_in_numbers?: Array<{ country_name?: string; number?: string; type?: string }>;
    };
}

interface ZoomCredentialValues {
    client_id?: string;
    clientId?: string;
    client_secret?: string;
    clientSecret?: string;
    account_id?: string;
    accountId?: string;
    host_user?: string;
    hostUser?: string;
}

/**
 * Zoom Server-to-Server OAuth video provider driver (the meetings plan, § 7).
 *
 * Reads `client_id`, `client_secret`, and `account_id` from `MJ: Credentials` via `CredentialEngine`
 * (never directly from `process.env`), checks the HTTP status of every Zoom call, and implements
 * `CreateMeeting`, `UpdateMeeting`, and `DeleteMeeting`.
 *
 * Teams and Google Meet are intentionally NOT implemented as `VideoProviderBase` drivers here —
 * their online meeting links come from the calendar event created by `CalendarEventLinks` (T2)
 * when `IsOnlineMeeting: true` is set on the Microsoft Graph or Google Calendar event.
 */
@RegisterClass(VideoProviderBase, 'ZoomVideoProvider')
export class ZoomVideoProvider extends VideoProviderBase {
    private clientId = '';
    private clientSecret = '';
    private accountId = '';
    private hostUser = 'me';
    private configured = false;

    async Initialize(context: VideoProviderContext, contextUser: UserInfo): Promise<void> {
        this.clientId = '';
        this.clientSecret = '';
        this.accountId = '';
        this.hostUser = 'me';
        this.configured = false;

        const configValues = this.parseConfiguration(context.Configuration);
        let credValues: ZoomCredentialValues = {};

        if (context.CredentialID) {
            await CredentialEngine.Instance.Config(false, contextUser);
            const resolved = await CredentialEngine.Instance.GetCredential('', {
                credentialId: context.CredentialID,
                contextUser,
                subsystem: 'VideoProvider',
            });
            credValues = (resolved?.values ?? {}) as ZoomCredentialValues;
        }

        const merged: ZoomCredentialValues = { ...configValues, ...credValues };
        this.clientId = (merged.client_id ?? merged.clientId ?? '').trim();
        this.clientSecret = (merged.client_secret ?? merged.clientSecret ?? '').trim();
        this.accountId = (merged.account_id ?? merged.accountId ?? '').trim();
        this.hostUser = (merged.host_user ?? merged.hostUser ?? 'me').trim() || 'me';
        this.configured = Boolean(this.clientId && this.clientSecret && this.accountId);
    }

    get IsConfigured(): boolean {
        return this.configured;
    }

    async CreateMeeting(input: VideoMeetingInput, _contextUser: UserInfo): Promise<VideoMeetingResult> {
        const accessToken = await this.fetchAccessToken();
        const durationMinutes = Math.max(1, Math.round((input.EndsAt.getTime() - input.StartsAt.getTime()) / 60000));

        const body = {
            topic: input.Title,
            type: 2,
            start_time: input.StartsAt.toISOString(),
            duration: durationMinutes,
            timezone: input.TimeZone || 'UTC',
            agenda: input.Description ?? '',
            settings: {
                join_before_host: true,
                waiting_room: false,
            },
        };

        const response = await fetch(`https://api.zoom.us/v2/users/${encodeURIComponent(this.hostUser)}/meetings`, {
            method: 'POST',
            headers: {
                Authorization: `Bearer ${accessToken}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(body),
        });

        if (!response.ok) {
            const errorBody = await response.text();
            throw new Error(`Zoom create meeting failed (${response.status}): ${errorBody}`);
        }

        const data = (await response.json()) as ZoomCreateMeetingResponse;
        const dialNumbers = data.settings?.global_dial_in_numbers
            ?.map((n) => [n.country_name, n.number].filter(Boolean).join(': '))
            .filter(Boolean);
        return {
            JoinURL: data.join_url,
            ProviderMeetingID: String(data.id),
            DialInDetails: dialNumbers && dialNumbers.length ? dialNumbers.join('\n') : null,
        };
    }

    async UpdateMeeting(providerMeetingId: string, input: VideoMeetingInput, _contextUser: UserInfo): Promise<void> {
        const accessToken = await this.fetchAccessToken();
        const durationMinutes = Math.max(1, Math.round((input.EndsAt.getTime() - input.StartsAt.getTime()) / 60000));

        const body = {
            topic: input.Title,
            type: 2,
            start_time: input.StartsAt.toISOString(),
            duration: durationMinutes,
            timezone: input.TimeZone || 'UTC',
            agenda: input.Description ?? '',
        };

        const response = await fetch(`https://api.zoom.us/v2/meetings/${encodeURIComponent(providerMeetingId)}`, {
            method: 'PATCH',
            headers: {
                Authorization: `Bearer ${accessToken}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(body),
        });

        if (!response.ok) {
            const errorBody = await response.text();
            throw new Error(`Zoom update meeting failed (${response.status}): ${errorBody}`);
        }
    }

    async DeleteMeeting(providerMeetingId: string, _contextUser: UserInfo): Promise<void> {
        const accessToken = await this.fetchAccessToken();
        const response = await fetch(`https://api.zoom.us/v2/meetings/${encodeURIComponent(providerMeetingId)}`, {
            method: 'DELETE',
            headers: {
                Authorization: `Bearer ${accessToken}`,
            },
        });

        if (!response.ok && response.status !== 404) {
            const errorBody = await response.text();
            throw new Error(`Zoom delete meeting failed (${response.status}): ${errorBody}`);
        }
    }

    private async fetchAccessToken(): Promise<string> {
        if (!this.configured) {
            throw new Error('ZoomVideoProvider is not configured.');
        }
        const basic = btoa(`${this.clientId}:${this.clientSecret}`);
        const url = `https://zoom.us/oauth/token?grant_type=account_credentials&account_id=${encodeURIComponent(this.accountId)}`;
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                Authorization: `Basic ${basic}`,
                'Content-Type': 'application/x-www-form-urlencoded',
            },
        });

        if (!response.ok) {
            const body = await response.text();
            throw new Error(`Zoom token request failed (${response.status}): ${body}`);
        }

        const data = (await response.json()) as ZoomTokenResponse;
        if (!data.access_token) {
            throw new Error('Zoom token response contained no access_token.');
        }
        return data.access_token;
    }

    private parseConfiguration(raw: string | null): ZoomCredentialValues {
        if (!raw || !raw.trim()) return {};
        try {
            const parsed = JSON.parse(raw) as unknown;
            if (typeof parsed === 'object' && parsed !== null && !Array.isArray(parsed)) {
                return parsed as ZoomCredentialValues;
            }
            return {};
        } catch {
            return {};
        }
    }
}
