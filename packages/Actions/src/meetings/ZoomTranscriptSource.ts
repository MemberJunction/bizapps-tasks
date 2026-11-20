import type { UserInfo } from '@memberjunction/core';
import { CredentialEngine } from '@memberjunction/credentials';
import { RegisterClass } from '@memberjunction/global';
import {
    parseWebVttTranscript,
    TranscriptSourceBase,
    type FetchedTranscript,
    type TranscriptMeetingContext,
    type TranscriptReference,
    type TranscriptSourceContext,
} from '@mj-biz-apps/tasks-core';

interface ZoomTokenResponse {
    access_token: string;
    token_type?: string;
    expires_in?: number;
}

interface ZoomRecordingFile {
    id?: string;
    file_type?: string;
    recording_type?: string;
    status?: string;
    download_url?: string;
    recording_start?: string;
    recording_end?: string;
}

interface ZoomRecordingsResponse {
    id?: number | string;
    topic?: string;
    duration?: number;
    recording_files?: ZoomRecordingFile[];
}

interface ZoomTranscriptConfigValues {
    client_id?: string;
    clientId?: string;
    client_secret?: string;
    clientSecret?: string;
    account_id?: string;
    accountId?: string;
}

const ZOOM_TIMEOUT_MS = 15_000;
const TOKEN_SAFETY_MARGIN_MS = 60_000;
const zoomTranscriptTokenCache = new Map<string, { accessToken: string; expiresAtMs: number }>();

/** Clears the in-process Zoom transcript OAuth token cache (useful in unit tests). */
export function clearZoomTranscriptTokenCache(): void {
    zoomTranscriptTokenCache.clear();
}

/**
 * Extracts a numeric Zoom meeting ID from a Zoom join URL (e.g. `https://us02web.zoom.us/j/12345678901?pwd=...`).
 */
export function extractZoomMeetingIdFromUrl(joinUrl: string | null | undefined): string | null {
    if (!joinUrl) return null;
    const match = /zoom\.us\/(?:j|w|wc\/join|s)\/(\d{9,12})/i.exec(joinUrl.trim());
    return match ? match[1] : null;
}

/**
 * Zoom Cloud Recording transcript source plugin (`TranscriptSourceBase`).
 *
 * Queries Zoom's `GET /v2/meetings/{meetingId}/recordings` endpoint using Server-to-Server OAuth
 * credentials resolved via `CredentialEngine`, locates the `audio_transcript` / `TRANSCRIPT` VTT
 * file, returns `null` when the recording or transcript is not ready yet, and normalizes the
 * downloaded WebVTT into speaker-labeled plain text.
 */
@RegisterClass(TranscriptSourceBase, 'ZoomTranscriptSource')
export class ZoomTranscriptSource extends TranscriptSourceBase {
    private clientId = '';
    private clientSecret = '';
    private accountId = '';
    private configured = false;
    private readonly downloadUrlsByRef = new Map<string, string>();

    public async Initialize(context: TranscriptSourceContext, contextUser: UserInfo): Promise<void> {
        this.clientId = '';
        this.clientSecret = '';
        this.accountId = '';
        this.configured = false;

        const configValues = this.parseConfiguration(context.Configuration);
        let credValues: ZoomTranscriptConfigValues = {};

        if (context.CredentialID) {
            await CredentialEngine.Instance.Config(false, contextUser);
            const resolved = await CredentialEngine.Instance.GetCredential<Record<string, string>>('', {
                credentialId: context.CredentialID,
                contextUser,
                subsystem: 'TranscriptSource',
            });
            credValues = (resolved?.values ?? {}) as ZoomTranscriptConfigValues;
        }

        this.clientId = (credValues.client_id ?? credValues.clientId ?? configValues.client_id ?? configValues.clientId ?? '').trim();
        this.clientSecret = (credValues.client_secret ?? credValues.clientSecret ?? configValues.client_secret ?? configValues.clientSecret ?? '').trim();
        this.accountId = (credValues.account_id ?? credValues.accountId ?? configValues.account_id ?? configValues.accountId ?? '').trim();
        this.configured = Boolean(this.clientId && this.clientSecret && this.accountId);
    }

    public get IsConfigured(): boolean {
        return this.configured;
    }

    public async FindTranscript(
        meeting: TranscriptMeetingContext,
        _contextUser: UserInfo,
    ): Promise<TranscriptReference | null> {
        if (!this.configured) {
            return null;
        }

        const zoomMeetingId =
            meeting.ProviderMeetingID?.trim() || extractZoomMeetingIdFromUrl(meeting.VideoJoinURL);
        if (!zoomMeetingId) {
            return null;
        }

        const accessToken = await this.fetchAccessToken();
        const url = `https://api.zoom.us/v2/meetings/${encodeURIComponent(zoomMeetingId)}/recordings`;
        const response = await fetch(url, {
            method: 'GET',
            headers: {
                Authorization: `Bearer ${accessToken}`,
                Accept: 'application/json',
            },
            signal: AbortSignal.timeout(ZOOM_TIMEOUT_MS),
        });

        // 404 or 400 (code 3301: recording does not exist yet) means transcript isn't ready yet
        if (response.status === 404) {
            return null;
        }
        if (!response.ok) {
            const detail = await response.text();
            if (response.status === 400 && detail.includes('3301')) {
                return null;
            }
            throw new Error(`Zoom recordings lookup failed (${response.status}): ${detail.slice(0, 300)}`);
        }

        const data = (await response.json()) as ZoomRecordingsResponse;
        const files = data.recording_files ?? [];
        const transcriptFile = files.find((file) => {
            const fileType = (file.file_type ?? '').toUpperCase();
            const recordingType = (file.recording_type ?? '').toLowerCase();
            const isTranscript = fileType === 'TRANSCRIPT' || recordingType === 'audio_transcript';
            if (!isTranscript) return false;
            const status = (file.status ?? 'completed').toLowerCase();
            return status === 'completed' && Boolean(file.download_url);
        });

        if (!transcriptFile?.download_url) {
            return null;
        }

        const refId = transcriptFile.id
            ? `zoom:${zoomMeetingId}:${transcriptFile.id}`
            : transcriptFile.download_url;
        this.downloadUrlsByRef.set(refId, transcriptFile.download_url);

        return {
            SourceKey: 'ZoomTranscriptSource',
            ExternalTranscriptID: refId,
            Title: data.topic ?? meeting.Title,
            Format: 'vtt',
            DurationSeconds: typeof data.duration === 'number' ? data.duration * 60 : null,
            RecordedAtISO: transcriptFile.recording_end ?? transcriptFile.recording_start ?? null,
        };
    }

    public async FetchTranscript(
        reference: TranscriptReference,
        _contextUser: UserInfo,
    ): Promise<FetchedTranscript> {
        if (!this.configured) {
            throw new Error('ZoomTranscriptSource is not configured.');
        }

        const downloadUrl =
            this.downloadUrlsByRef.get(reference.ExternalTranscriptID) ??
            (reference.ExternalTranscriptID.startsWith('https://') ? reference.ExternalTranscriptID : null);
        if (!downloadUrl) {
            throw new Error(
                `No Zoom transcript download URL is cached for reference '${reference.ExternalTranscriptID}'. Call FindTranscript first.`,
            );
        }

        const accessToken = await this.fetchAccessToken();
        const response = await fetch(downloadUrl, {
            method: 'GET',
            headers: {
                Authorization: `Bearer ${accessToken}`,
                Accept: 'text/vtt, text/plain, */*',
            },
            signal: AbortSignal.timeout(ZOOM_TIMEOUT_MS),
        });

        if (!response.ok) {
            const detail = await response.text();
            throw new Error(`Zoom transcript download failed (${response.status}): ${detail.slice(0, 300)}`);
        }

        const rawVtt = await response.text();
        const parsed = parseWebVttTranscript(rawVtt);

        return {
            Reference: reference,
            PlainText: parsed.PlainText,
            RawContent: rawVtt,
            ContentType: 'text/vtt',
            Speakers: parsed.Speakers,
        };
    }

    private async fetchAccessToken(): Promise<string> {
        const cacheKey = `${this.accountId}:${this.clientId}`;
        const cached = zoomTranscriptTokenCache.get(cacheKey);
        if (cached && cached.expiresAtMs > Date.now()) {
            return cached.accessToken;
        }

        const basic = btoa(`${this.clientId}:${this.clientSecret}`);
        const tokenUrl = `https://zoom.us/oauth/token?grant_type=account_credentials&account_id=${encodeURIComponent(this.accountId)}`;
        const response = await fetch(tokenUrl, {
            method: 'POST',
            headers: {
                Authorization: `Basic ${basic}`,
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            signal: AbortSignal.timeout(ZOOM_TIMEOUT_MS),
        });

        if (!response.ok) {
            const detail = await response.text();
            throw new Error(`Zoom OAuth token request failed (${response.status}): ${detail.slice(0, 300)}`);
        }

        const data = (await response.json()) as ZoomTokenResponse;
        if (!data.access_token) {
            throw new Error('Zoom OAuth token response did not contain an access_token.');
        }

        const ttlMs = Math.max(0, (Number(data.expires_in) || 3600) * 1000 - TOKEN_SAFETY_MARGIN_MS);
        zoomTranscriptTokenCache.set(cacheKey, {
            accessToken: data.access_token,
            expiresAtMs: Date.now() + ttlMs,
        });
        return data.access_token;
    }

    private parseConfiguration(raw: string | null | undefined): ZoomTranscriptConfigValues {
        if (!raw || !raw.trim()) return {};
        try {
            const parsed = JSON.parse(raw) as ZoomTranscriptConfigValues;
            if (typeof parsed === 'object' && parsed !== null && !Array.isArray(parsed)) {
                return parsed;
            }
            return {};
        } catch {
            return {};
        }
    }
}
