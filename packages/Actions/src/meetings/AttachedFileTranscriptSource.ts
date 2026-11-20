import { Metadata, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import type { MJFileEntity } from '@memberjunction/core-entities';
import { FileStorageEngine } from '@memberjunction/storage';
import { RegisterClass } from '@memberjunction/global';
import {
    FILES_ENTITY,
    normalizeTranscriptText,
    readMeetingTranscriptFile,
    TranscriptSourceBase,
    type FetchedTranscript,
    type TranscriptMeetingContext,
    type TranscriptReference,
    type TranscriptSourceContext,
} from '@mj-biz-apps/tasks-core';

interface AttachedFileSourceConfig {
    /** Optional inline raw transcript text override (useful for webhook payloads or tests). */
    inlineContent?: string;
}

/**
 * Transcript source plugin (`TranscriptSourceBase`) that reads transcripts already attached to
 * `Meeting.TranscriptFileID` (`MJ: Files`), falling back from the registered core file reader
 * (`readMeetingTranscriptFile`) to `FileStorageEngine.Instance` (`ResolveFileObject` / `GetDriver`),
 * and normalizes WebVTT, SRT, JSON segments, or plain text into speaker-labeled lines.
 */
@RegisterClass(TranscriptSourceBase, 'AttachedFileTranscriptSource')
export class AttachedFileTranscriptSource extends TranscriptSourceBase {
    private inlineContent: string | null = null;
    private readonly provider: IMetadataProvider;

    constructor(provider: IMetadataProvider = Metadata.Provider) {
        super();
        this.provider = provider;
    }

    public async Initialize(context: TranscriptSourceContext, _contextUser: UserInfo): Promise<void> {
        this.inlineContent = null;
        if (context.Configuration?.trim()) {
            try {
                const parsed = JSON.parse(context.Configuration) as AttachedFileSourceConfig;
                if (typeof parsed.inlineContent === 'string' && parsed.inlineContent.trim()) {
                    this.inlineContent = parsed.inlineContent;
                }
            } catch {
                // Non-JSON configuration ignored
            }
        }
    }

    public get IsConfigured(): boolean {
        return true;
    }

    public async FindTranscript(
        meeting: TranscriptMeetingContext,
        _contextUser: UserInfo,
    ): Promise<TranscriptReference | null> {
        const fileId = meeting.TranscriptFileID?.trim();
        if (!fileId && !this.inlineContent) {
            return null;
        }
        return {
            SourceKey: 'AttachedFileTranscriptSource',
            ExternalTranscriptID: fileId || `inline:${meeting.MeetingID ?? 'meeting'}`,
            Title: meeting.Title,
        };
    }

    public async FetchTranscript(
        reference: TranscriptReference,
        contextUser: UserInfo,
    ): Promise<FetchedTranscript> {
        let rawText: string | null = this.inlineContent;
        let contentType = 'text/plain';

        if (!rawText && reference.ExternalTranscriptID && !reference.ExternalTranscriptID.startsWith('inline:')) {
            rawText = await readMeetingTranscriptFile(this.provider, reference.ExternalTranscriptID, contextUser);

            if (!rawText) {
                const loaded = await this.readFromFileStorageEngine(reference.ExternalTranscriptID, contextUser);
                rawText = loaded.text;
                if (loaded.contentType) {
                    contentType = loaded.contentType;
                }
            }
        }

        if (!rawText || !rawText.trim()) {
            throw new Error(
                `Attached transcript file '${reference.ExternalTranscriptID}' could not be read or is empty.`,
            );
        }

        const parsed = normalizeTranscriptText(rawText, reference.Format);
        return {
            Reference: {
                ...reference,
                Format: parsed.Format,
            },
            PlainText: parsed.PlainText,
            RawContent: rawText,
            ContentType: parsed.Format === 'vtt' ? 'text/vtt' : contentType,
            Speakers: parsed.Speakers,
        };
    }

    private async readFromFileStorageEngine(
        fileId: string,
        contextUser: UserInfo,
    ): Promise<{ text: string | null; contentType: string | null }> {
        const fileEntity = await this.provider.GetEntityObject<MJFileEntity>(FILES_ENTITY, contextUser);
        if (!(await fileEntity.Load(fileId))) {
            return { text: null, contentType: null };
        }

        const contentType = fileEntity.ContentType ?? null;
        await FileStorageEngine.Instance.Config(false, contextUser, this.provider);

        const resolved = await FileStorageEngine.Instance.ResolveFileObject(
            {
                ProviderID: fileEntity.ProviderID,
                ProviderKey: fileEntity.ProviderKey ?? null,
                Name: fileEntity.Name,
            },
            contextUser,
            'Read',
            this.provider,
        );
        if (resolved) {
            const bytes = await resolved.Driver.GetObject({ fullPath: resolved.ObjectKey });
            if (bytes && bytes.byteLength > 0) {
                return { text: new TextDecoder('utf-8').decode(bytes), contentType };
            }
        }

        if (fileEntity.ProviderKey) {
            const accounts = FileStorageEngine.Instance.GetAccountsByProviderID(fileEntity.ProviderID);
            const accountId = accounts[0]?.ID ?? FileStorageEngine.Instance.ResolveStorageAccount()?.account.ID;
            if (accountId) {
                const driver = await FileStorageEngine.Instance.GetDriver(accountId, contextUser);
                const bytes = await driver.GetObject({ fullPath: fileEntity.ProviderKey });
                if (bytes && bytes.byteLength > 0) {
                    return { text: new TextDecoder('utf-8').decode(bytes), contentType };
                }
            }
        }

        return { text: null, contentType };
    }
}
