import { BaseEntity, LogError, type IMetadataProvider, type UserInfo } from '@memberjunction/core';
import type { MJFileEntity } from '@memberjunction/core-entities';
import {
    AI_PROMPTS_ENTITY,
    FILES_ENTITY,
    parseJsonFenceOrObject,
    registerMeetingAIPromptExecutor,
    registerMeetingTranscriptFileReader,
    type ExecutedMeetingPromptResult,
} from '@mj-biz-apps/tasks-core';

const dynamicImport = (specifier: string): Promise<Record<string, unknown>> =>
    import(/* webpackIgnore: true */ specifier) as Promise<Record<string, unknown>>;

/**
 * Server-side AI prompt executor for `MeetingNotesService` and `MeetingAgendaService`:
 * loads the `MJ: AI Prompts` entity for `promptId`, configures `AIEngine`, and runs `AIPromptRunner.ExecutePrompt`.
 * Throws when the prompt is inactive or execution fails so callers never silently save un-run AI results.
 */
export async function executeServerMeetingAIPrompt(
    provider: IMetadataProvider,
    promptId: string,
    data: Record<string, unknown>,
    contextUser: UserInfo,
): Promise<ExecutedMeetingPromptResult> {
    const promptEntity = await provider.GetEntityObject<
        BaseEntity & {
            ID: string;
            Name: string;
            Status: string;
            Load: (id: string) => Promise<boolean>;
        }
    >(AI_PROMPTS_ENTITY, contextUser);
    if (!(await promptEntity.Load(promptId)) || promptEntity.Status !== 'Active') {
        throw new Error(`AI prompt ${promptId} was not found or is not Active.`);
    }

    const [aiEngineMod, aiPromptsMod, aiCorePlusMod] = await Promise.all([
        dynamicImport('@memberjunction/aiengine'),
        dynamicImport('@memberjunction/ai-prompts'),
        dynamicImport('@memberjunction/ai-core-plus'),
    ]);

    const AIEngine = aiEngineMod.AIEngine as {
        Instance: { Config: (forceRefresh?: boolean, contextUser?: UserInfo, provider?: IMetadataProvider) => Promise<void> };
    };
    const AIPromptRunner = aiPromptsMod.AIPromptRunner as new () => {
        ExecutePrompt: (params: Record<string, unknown>) => Promise<{
            success?: boolean;
            errorMessage?: string | null;
            result?: unknown;
            rawResult?: string | null;
            promptRun?: { ID?: string | null } | null;
        }>;
    };
    const AIPromptParams = aiCorePlusMod.AIPromptParams as new () => Record<string, unknown>;

    await AIEngine.Instance.Config(false, contextUser, provider);
    const params = new AIPromptParams();
    params.prompt = promptEntity;
    params.data = data;
    params.contextUser = contextUser;

    const runner = new AIPromptRunner();
    const runResult = await runner.ExecutePrompt(params);
    if (!runResult?.success) {
        const reason = runResult?.errorMessage ?? `AI prompt execution failed for "${promptEntity.Name}".`;
        LogError(`MeetingAI: ${reason}`);
        throw new Error(reason);
    }

    const parsed = parseJsonFenceOrObject(runResult.result ?? runResult.rawResult);
    if (!parsed) {
        throw new Error(`AI prompt "${promptEntity.Name}" did not return valid JSON output.`);
    }

    return {
        parsed,
        promptRunId: runResult.promptRun?.ID ?? null,
    };
}

/**
 * Server-side transcript file reader for `Meeting.TranscriptFileID` (`MJ: Files`):
 * loads the `MJ: Files` row as `contextUser`, resolves the storage driver via `FileStorageEngine`,
 * reads the object bytes with `GetObject`, and returns UTF-8 text.
 */
export async function readServerMeetingTranscriptFile(
    provider: IMetadataProvider,
    transcriptFileId: string,
    contextUser: UserInfo,
): Promise<string | null> {
    const fileEntity = await provider.GetEntityObject<MJFileEntity>(FILES_ENTITY, contextUser);
    if (!(await fileEntity.Load(transcriptFileId))) {
        return null;
    }

    const storageMod = await dynamicImport('@memberjunction/storage');
    const FileStorageEngine = storageMod.FileStorageEngine as {
        Instance: {
            Config: (forceRefresh?: boolean, contextUser?: UserInfo, provider?: IMetadataProvider) => Promise<void>;
            ResolveFileObject?: (
                file: { ProviderID: string; ProviderKey: string | null; Name: string },
                user: UserInfo,
                access: string,
                provider: IMetadataProvider,
            ) => Promise<{ Driver: { GetObject: (params: { fullPath: string }) => Promise<Uint8Array> }; ObjectKey: string } | null>;
            GetAccountsByProviderID: (providerId: string) => Array<{ ID: string }>;
            ResolveStorageAccount: () => { account: { ID: string } } | null;
            GetDriver: (accountId: string, user: UserInfo) => Promise<{ GetObject: (params: { fullPath: string }) => Promise<Uint8Array> }>;
        };
    };

    await FileStorageEngine.Instance.Config(false, contextUser, provider);
    if (typeof FileStorageEngine.Instance.ResolveFileObject === 'function') {
        const resolved = await FileStorageEngine.Instance.ResolveFileObject(
            { ProviderID: fileEntity.ProviderID, ProviderKey: fileEntity.ProviderKey ?? null, Name: fileEntity.Name },
            contextUser,
            'Read',
            provider,
        );
        if (resolved) {
            const bytes = await resolved.Driver.GetObject({ fullPath: resolved.ObjectKey });
            if (bytes?.byteLength) return new TextDecoder('utf-8').decode(bytes);
        }
    } else if (fileEntity.ProviderKey) {
        const accounts = FileStorageEngine.Instance.GetAccountsByProviderID(fileEntity.ProviderID);
        const accountId = accounts[0]?.ID ?? FileStorageEngine.Instance.ResolveStorageAccount()?.account.ID;
        if (accountId) {
            const driver = await FileStorageEngine.Instance.GetDriver(accountId, contextUser);
            const bytes = await driver.GetObject({ fullPath: fileEntity.ProviderKey });
            if (bytes?.byteLength) return new TextDecoder('utf-8').decode(bytes);
        }
    }

    return null;
}

/** Registers the server-side AI prompt executor and transcript file reader for `MeetingNotesService` and `MeetingAgendaService`. */
export function registerMeetingServerAIRuntime(): void {
    registerMeetingAIPromptExecutor(executeServerMeetingAIPrompt);
    registerMeetingTranscriptFileReader(readServerMeetingTranscriptFile);
}
