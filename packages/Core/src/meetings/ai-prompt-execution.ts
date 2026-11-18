import { RunView, type IMetadataProvider, type UserInfo } from '@memberjunction/core';

export const AI_PROMPTS_ENTITY = 'MJ: AI Prompts';
export const FILES_ENTITY = 'MJ: Files';

export interface ExecutedMeetingPromptResult<T = unknown> {
    parsed: T;
    promptRunId: string | null;
}

export type MeetingAIPromptExecutor = (
    provider: IMetadataProvider,
    promptId: string,
    data: Record<string, unknown>,
    contextUser: UserInfo,
) => Promise<ExecutedMeetingPromptResult | null>;

export type MeetingTranscriptFileReader = (
    provider: IMetadataProvider,
    transcriptFileId: string,
    contextUser: UserInfo,
) => Promise<string | null>;

let registeredPromptExecutor: MeetingAIPromptExecutor | null = null;
let registeredTranscriptFileReader: MeetingTranscriptFileReader | null = null;

/** Registers a server-side AI prompt executor (used when running directly on the server without GraphQLDataProvider). */
export function registerMeetingAIPromptExecutor(executor: MeetingAIPromptExecutor | null): void {
    registeredPromptExecutor = executor;
}

/** Registers a server-side transcript file reader for `Meeting.TranscriptFileID` (`MJ: Files`). */
export function registerMeetingTranscriptFileReader(reader: MeetingTranscriptFileReader | null): void {
    registeredTranscriptFileReader = reader;
}

/**
 * Resolves a meeting AI prompt ID: uses `explicitPromptId` when set (for example `MeetingType.NotesPromptID`),
 * otherwise looks up the active `MJ: AI Prompts` record by `promptName`.
 */
export async function resolveMeetingPromptId(
    provider: IMetadataProvider,
    explicitPromptId: string | null | undefined,
    promptName: string,
    contextUser: UserInfo,
): Promise<string | null> {
    if (explicitPromptId?.trim()) return explicitPromptId.trim();
    try {
        const res = await RunView.FromMetadataProvider(provider).RunView<{ ID: string }>(
            {
                EntityName: AI_PROMPTS_ENTITY,
                ExtraFilter: `Name = '${promptName.replace(/'/g, "''")}' AND Status = 'Active'`,
                Fields: ['ID'],
                ResultType: 'simple',
                MaxRows: 1,
            },
            contextUser,
        );
        return res.Success ? (res.Results[0]?.ID ?? null) : null;
    } catch {
        return null;
    }
}

interface GraphQLExecutableProvider {
    ExecuteGQL?: (query: string, variables?: Record<string, unknown>) => Promise<Record<string, unknown>>;
}

const RUN_AI_PROMPT_MUTATION = `
    mutation RunAIPrompt($promptId: String!, $data: String, $responseFormat: String) {
        RunAIPrompt(promptId: $promptId, data: $data, responseFormat: $responseFormat) {
            success
            output
            parsedResult
            promptRunId
            error
        }
    }
`;

const GET_FILE_CONTENTS_QUERY = `
    query GetFileContents($fileId: String!) {
        GetFileContents(fileId: $fileId) {
            Success
            Base64
            ErrorMessage
        }
    }
`;

export function parseJsonFenceOrObject<T = unknown>(raw: unknown): T | null {
    if (!raw) return null;
    if (typeof raw === 'object') return raw as T;
    if (typeof raw !== 'string') return null;
    const trimmed = raw.trim();
    if (!trimmed) return null;
    const unfenced = trimmed
        .replace(/^```(?:json)?\s*/i, '')
        .replace(/\s*```$/i, '')
        .trim();
    try {
        return JSON.parse(unfenced) as T;
    } catch {
        const firstBrace = unfenced.indexOf('{');
        const lastBrace = unfenced.lastIndexOf('}');
        if (firstBrace >= 0 && lastBrace > firstBrace) {
            try {
                return JSON.parse(unfenced.slice(firstBrace, lastBrace + 1)) as T;
            } catch {
                return null;
            }
        }
        return null;
    }
}

/**
 * Executes an `MJ: AI Prompts` record by `promptId`:
 * 1. If a server-side prompt executor is registered (`registerMeetingAIPromptExecutor`), invokes it.
 * 2. Otherwise, if `provider` is a `GraphQLDataProvider` with `ExecuteGQL`, calls the `RunAIPrompt` mutation.
 * 3. Throws when the prompt ID is missing, no AI prompt runtime is reachable, or the model call fails.
 */
export async function executeMeetingAIPrompt<T = unknown>(
    provider: IMetadataProvider,
    promptId: string | null,
    data: Record<string, unknown>,
    contextUser: UserInfo,
): Promise<ExecutedMeetingPromptResult<T>> {
    if (!promptId) {
        throw new Error('The meeting AI prompt is not configured or active on this host.');
    }

    if (registeredPromptExecutor) {
        const res = await registeredPromptExecutor(provider, promptId, data, contextUser);
        if (!res?.parsed) {
            throw new Error(`AI prompt ${promptId} did not return a parsed result.`);
        }
        return res as ExecutedMeetingPromptResult<T>;
    }

    const gqlProvider = provider as unknown as GraphQLExecutableProvider;
    if (typeof gqlProvider.ExecuteGQL === 'function') {
        const result = await gqlProvider.ExecuteGQL(RUN_AI_PROMPT_MUTATION, {
            promptId,
            data: JSON.stringify(data),
            responseFormat: 'JSON',
        });
        const payload = result?.RunAIPrompt as
            | {
                  success?: boolean;
                  output?: string | null;
                  parsedResult?: unknown;
                  promptRunId?: string | null;
                  error?: string | null;
              }
            | undefined;
        if (!payload?.success) {
            throw new Error(payload?.error || `RunAIPrompt failed for prompt ${promptId}.`);
        }
        const parsed = parseJsonFenceOrObject<T>(payload.parsedResult ?? payload.output);
        if (!parsed) {
            throw new Error(`RunAIPrompt for prompt ${promptId} did not return valid JSON output.`);
        }
        return {
            parsed,
            promptRunId: payload.promptRunId ?? null,
        };
    }

    throw new Error('No AI prompt runtime is available on the current provider.');
}

function decodeBase64Utf8(base64: string): string {
    const binary = globalThis.atob(base64);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) {
        bytes[i] = binary.charCodeAt(i);
    }
    return new TextDecoder('utf-8').decode(bytes);
}

/**
 * Reads the UTF-8 text of a meeting's `TranscriptFileID` (`MJ: Files` record):
 * 1. Uses the registered server-side transcript file reader (`FileStorageEngine.GetObject`) when on the server.
 * 2. Uses the `GetFileContents` GraphQL query when `provider` is a `GraphQLDataProvider` on the client.
 */
export async function readMeetingTranscriptFile(
    provider: IMetadataProvider,
    transcriptFileId: string | null | undefined,
    contextUser: UserInfo,
): Promise<string | null> {
    const cleanId = transcriptFileId?.trim();
    if (!cleanId) return null;

    if (registeredTranscriptFileReader) {
        const content = await registeredTranscriptFileReader(provider, cleanId, contextUser);
        if (content?.trim()) return content.trim();
        return null;
    }

    const gqlProvider = provider as unknown as GraphQLExecutableProvider;
    if (typeof gqlProvider.ExecuteGQL === 'function') {
        const result = await gqlProvider.ExecuteGQL(GET_FILE_CONTENTS_QUERY, { fileId: cleanId });
        const payload = result?.GetFileContents as
            | {
                  Success?: boolean;
                  Base64?: string | null;
              }
            | undefined;
        if (payload?.Success && payload.Base64) {
            const decoded = decodeBase64Utf8(payload.Base64).trim();
            if (decoded) return decoded;
        }
    }

    return null;
}
