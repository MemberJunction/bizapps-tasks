/**
 * @fileoverview Batched dual-read resolver for `ArtifactID`-backed records
 * (`MJ_BizApps_Tasks: Work Reports` and `MJ_BizApps_Tasks: Meeting Notes`).
 *
 * Resolves linked `MJ: Artifacts` and latest `MJ: Artifact Versions` records using
 * chunked `RunView.RunView(..., { ResultType: 'simple' })` `IN (...)` queries (zero N+1
 * queries, zero full-history content bloat on list views) and falls back deterministically
 * to legacy `Body` whenever `ArtifactID` is null, invalid, or inaccessible under RLS.
 *
 * @module @mj-biz-apps/tasks-core
 */

import {
    LogError,
    RunView,
    type IMetadataProvider,
    type IRunViewProvider,
    type UserInfo,
} from '@memberjunction/core';
import {
    BaseSingleton,
    GetGlobalObjectStore,
    IsValidUUID,
    NormalizeUUID,
} from '@memberjunction/global';
import { TasksLimitsResolver } from '../config/TasksLimits.js';
import { GuidLiteral } from './sql-guards.js';

export const MJ_ARTIFACTS_ENTITY_NAME = 'MJ: Artifacts';
export const MJ_ARTIFACT_VERSIONS_ENTITY_NAME = 'MJ: Artifact Versions';
export const MJ_ARTIFACT_TYPES_ENTITY_NAME = 'MJ: Artifact Types';
export const MJ_ENVIRONMENTS_ENTITY_NAME = 'MJ: Environments';

/** Default MemberJunction Environment ID (matches MJ core schema default). */
export const DEFAULT_MJ_ENVIRONMENT_ID = 'F51358F3-9447-4176-B313-BF8025FD8D09';

/** Seeded MemberJunction `Markdown Document` Artifact Type ID. */
export const DEFAULT_MARKDOWN_ARTIFACT_TYPE_ID = '5E5883C2-0185-4E1E-8A1C-F514DBF52DB7';

/** Action ID for `Publish Meeting Note as MJ Doc` (`Tasks.PublishMeetingNoteAsMJDoc`). */
export const PUBLISH_MEETING_NOTE_AS_MJ_DOC_ACTION_ID = 'C7D4E891-4B2A-4F65-9E13-7A82D5C1B4E9';

/** Registered driver class key for `PublishMeetingNoteAsMJDocAction`. */
export const PUBLISH_MEETING_NOTE_AS_MJ_DOC_DRIVER_CLASS = 'Tasks.PublishMeetingNoteAsMJDoc';

/** Provider surface required by {@link ArtifactDualReadResolver}. */
export type ArtifactResolverProvider = IMetadataProvider & IRunViewProvider;

/** Minimal structural shape shared by `WorkReport` and `MeetingNote` records/view models. */
export interface ArtifactBackableRecord {
    ID: string;
    ArtifactID?: string | null;
    Body: string;
    Title?: string | null;
}

/** Reason why dual-read resolution fell back to legacy `Body` instead of linked artifact content. */
export type ArtifactFallbackReason =
    | 'no_artifact_id'
    | 'invalid_artifact_id'
    | 'artifact_not_accessible'
    | 'version_not_accessible'
    | 'empty_artifact_content';

/** Strongly-typed dual-read resolution result for a single `WorkReport` or `MeetingNote`. */
export interface ResolvedArtifactContent {
    RecordID: string;
    Source: 'artifact' | 'body';
    FallbackReason: ArtifactFallbackReason | null;
    Content: string;
    LegacyBody: string;
    ArtifactID: string | null;
    ArtifactName: string | null;
    ArtifactDescription: string | null;
    ArtifactTypeID: string | null;
    ArtifactTypeName: string | null;
    VersionID: string | null;
    VersionNumber: number | null;
    VersionName: string | null;
    MimeType: string | null;
    ContentMode: 'File' | 'Text' | null;
    UpdatedAt: string | null;
}

/** Options controlling {@link ArtifactDualReadResolver.ResolveBatch}. */
export interface ResolveArtifactBatchOptions {
    /** Acting user propagated into every server-side `RunView` call. */
    ContextUser?: UserInfo;
    /** Optional metadata/RunView provider (defaults to global `Metadata.Provider`). */
    Provider?: ArtifactResolverProvider;
    /**
     * Optional override for `ID IN (...)` chunk size. Always clamped to
     * `[1, TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.SqlInClauseChunkSize]`.
     */
    ChunkSize?: number;
    /**
     * When `true` (default), fetches `Content` strictly for the single latest accessible
     * `MJ: Artifact Versions` row per artifact. When `false`, resolves latest version metadata
     * only (zero content payload transfer for list views).
     */
    IncludeContent?: boolean;
}

interface RawArtifactHeaderRow {
    ID: string;
    Name: string;
    Description?: string | null;
    TypeID?: string | null;
    Type?: string | null;
    __mj_UpdatedAt?: string | Date | null;
}

interface RawArtifactVersionHeaderRow {
    ID: string;
    ArtifactID: string;
    VersionNumber: number;
    Name?: string | null;
    Description?: string | null;
    MimeType?: string | null;
    ContentMode?: 'File' | 'Text' | null;
    __mj_UpdatedAt?: string | Date | null;
}

interface RawArtifactVersionContentRow {
    ID: string;
    ArtifactID: string;
    VersionNumber: number;
    Content?: string | null;
}

function toIsoStringOrNull(value: string | Date | null | undefined): string | null {
    if (!value) return null;
    const d = value instanceof Date ? value : new Date(value);
    return Number.isNaN(d.getTime()) ? null : d.toISOString();
}

function normalizeRecordKey(recordId: string): string {
    return recordId.trim().toLowerCase();
}

/**
 * Validates and deduplicates candidate `ArtifactID` UUIDs in deterministic first-seen order.
 * Rejects blank strings, nulls, and non-UUID values before any SQL `IN (...)` clause is built.
 */
export function ValidateAndDeduplicateArtifactIDs(
    rawIds: ReadonlyArray<string | null | undefined>,
): string[] {
    const seen = new Set<string>();
    const valid: string[] = [];
    for (const raw of rawIds) {
        if (typeof raw !== 'string') continue;
        const trimmed = raw.trim();
        if (!trimmed || !IsValidUUID(trimmed)) continue;
        const norm = NormalizeUUID(trimmed);
        if (seen.has(norm)) continue;
        seen.add(norm);
        valid.push(trimmed);
    }
    return valid;
}

/**
 * Splits a validated list of UUIDs into bounded chunks for SQL `IN (...)` filters.
 * Defaults to `TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.SqlInClauseChunkSize`
 * and never exceeds that configured ceiling.
 */
export function ChunkArtifactIDs(ids: readonly string[], requestedChunkSize?: number): string[][] {
    if (ids.length === 0) return [];
    const maxChunkSize = TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.SqlInClauseChunkSize;
    const effectiveSize =
        typeof requestedChunkSize === 'number' && Number.isFinite(requestedChunkSize) && requestedChunkSize >= 1
            ? Math.min(Math.floor(requestedChunkSize), maxChunkSize)
            : maxChunkSize;

    const chunks: string[][] = [];
    for (let i = 0; i < ids.length; i += effectiveSize) {
        chunks.push(ids.slice(i, i + effectiveSize));
    }
    return chunks;
}

/**
 * Constructs a SQL-injection-safe `<columnName> IN ('<uuid>', ...)` clause after validating
 * every UUID via {@link GuidLiteral}.
 */
export function BuildArtifactIdInFilter(columnName: string, ids: readonly string[]): string {
    if (ids.length === 0) {
        throw new Error(`BuildArtifactIdInFilter(${columnName}) requires at least one valid UUID.`);
    }
    const literals = ids.map((id) => GuidLiteral(id, columnName));
    return `${columnName} IN (${literals.join(', ')})`;
}

/**
 * Looks up a resolved dual-read entry from a batch result map regardless of UUID casing.
 */
export function GetResolvedArtifactContent(
    resolvedMap: ReadonlyMap<string, ResolvedArtifactContent>,
    recordId: string,
): ResolvedArtifactContent | undefined {
    return resolvedMap.get(normalizeRecordKey(recordId));
}

function buildFallbackResult(
    record: ArtifactBackableRecord,
    reason: ArtifactFallbackReason,
    artifact?: RawArtifactHeaderRow,
    version?: RawArtifactVersionHeaderRow,
): ResolvedArtifactContent {
    const trimmedArtifactId =
        typeof record.ArtifactID === 'string' && record.ArtifactID.trim().length > 0
            ? record.ArtifactID.trim()
            : null;
    return {
        RecordID: record.ID,
        Source: 'body',
        FallbackReason: reason,
        Content: record.Body,
        LegacyBody: record.Body,
        ArtifactID: artifact?.ID ?? (trimmedArtifactId && IsValidUUID(trimmedArtifactId) ? trimmedArtifactId : null),
        ArtifactName: artifact?.Name ?? null,
        ArtifactDescription: artifact?.Description ?? null,
        ArtifactTypeID: artifact?.TypeID ?? null,
        ArtifactTypeName: artifact?.Type ?? null,
        VersionID: version?.ID ?? null,
        VersionNumber: typeof version?.VersionNumber === 'number' ? version.VersionNumber : null,
        VersionName: version?.Name ?? null,
        MimeType: version?.MimeType ?? null,
        ContentMode: version?.ContentMode ?? null,
        UpdatedAt: toIsoStringOrNull(version?.__mj_UpdatedAt ?? artifact?.__mj_UpdatedAt),
    };
}

/**
 * Singleton batched dual-read resolver for `WorkReport` and `MeetingNote` records carrying
 * nullable `ArtifactID` foreign keys to `[__mj].[Artifact]([ID])`.
 */
export class ArtifactDualReadResolver extends BaseSingleton<ArtifactDualReadResolver> {
    protected constructor() {
        super();
    }

    public static get Instance(): ArtifactDualReadResolver {
        const g = GetGlobalObjectStore();
        const key = '___SINGLETON__ArtifactDualReadResolver';
        if (g && g[key]) {
            return g[key] as ArtifactDualReadResolver;
        }
        return new ArtifactDualReadResolver();
    }

    private createRunView(provider?: ArtifactResolverProvider): RunView {
        if (provider) {
            return RunView.FromMetadataProvider(provider);
        }
        return new RunView();
    }

    /**
     * Resolves a batch of `WorkReport` or `MeetingNote` records using chunked `RunView`
     * `IN (...)` queries (`ResultType: 'simple'`).
     *
     * - Short-circuits with zero `RunView` calls when no valid `ArtifactID` values are present.
     * - Fetches version headers first without `Content`, then fetches `Content` strictly for the
     *   single latest version per artifact (`ID IN (...)`) when `IncludeContent !== false`.
     * - Propagates `options.ContextUser` into every `RunView` call.
     * - Falls back cleanly and deterministically to `record.Body` when `ArtifactID` is null,
     *   invalid, inaccessible, or has no readable version content.
     */
    public async ResolveBatch<T extends ArtifactBackableRecord>(
        records: readonly T[],
        options: ResolveArtifactBatchOptions = {},
    ): Promise<Map<string, ResolvedArtifactContent>> {
        const result = new Map<string, ResolvedArtifactContent>();
        if (records.length === 0) {
            return result;
        }

        const includeContent = options.IncludeContent !== false;
        const validArtifactIds = ValidateAndDeduplicateArtifactIDs(records.map((r) => r.ArtifactID));

        // Short-circuit empty batches without calling RunView
        if (validArtifactIds.length === 0) {
            for (const record of records) {
                const hasRawId = typeof record.ArtifactID === 'string' && record.ArtifactID.trim().length > 0;
                const reason: ArtifactFallbackReason = hasRawId ? 'invalid_artifact_id' : 'no_artifact_id';
                result.set(normalizeRecordKey(record.ID), buildFallbackResult(record, reason));
            }
            return result;
        }

        const rv = this.createRunView(options.Provider);
        const contextUser = options.ContextUser;
        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        const chunks = ChunkArtifactIDs(validArtifactIds, options.ChunkSize);

        const artifactByNormId = new Map<string, RawArtifactHeaderRow>();
        const latestVersionByNormArtifactId = new Map<string, RawArtifactVersionHeaderRow>();
        const contentByNormVersionId = new Map<string, string | null>();

        for (const chunk of chunks) {
            // 1. Batched MJ: Artifacts lookup with ID IN (...)
            const artifactRes = await rv.RunView<RawArtifactHeaderRow>(
                {
                    EntityName: MJ_ARTIFACTS_ENTITY_NAME,
                    ExtraFilter: BuildArtifactIdInFilter('ID', chunk),
                    Fields: ['ID', 'Name', 'Description', 'TypeID', 'Type', '__mj_UpdatedAt'],
                    MaxRows: chunk.length,
                    ResultType: 'simple',
                },
                contextUser,
            );

            if (!artifactRes?.Success) {
                LogError(
                    `ArtifactDualReadResolver: failed to query ${MJ_ARTIFACTS_ENTITY_NAME}: ${artifactRes?.ErrorMessage ?? 'RunView failed'}`,
                );
                continue;
            }

            const accessibleArtifactIds: string[] = [];
            for (const row of artifactRes.Results ?? []) {
                if (!row?.ID || !IsValidUUID(row.ID)) continue;
                const normId = NormalizeUUID(row.ID);
                if (!artifactByNormId.has(normId)) {
                    artifactByNormId.set(normId, row);
                    accessibleArtifactIds.push(row.ID.trim());
                }
            }

            if (accessibleArtifactIds.length === 0) {
                continue;
            }

            // 2. Batched MJ: Artifact Versions header lookup (no Content payload) to locate latest version per artifact
            const versionsRes = await rv.RunView<RawArtifactVersionHeaderRow>(
                {
                    EntityName: MJ_ARTIFACT_VERSIONS_ENTITY_NAME,
                    ExtraFilter: BuildArtifactIdInFilter('ArtifactID', accessibleArtifactIds),
                    Fields: [
                        'ID',
                        'ArtifactID',
                        'VersionNumber',
                        'Name',
                        'Description',
                        'MimeType',
                        'ContentMode',
                        '__mj_UpdatedAt',
                    ],
                    OrderBy: 'VersionNumber DESC',
                    MaxRows: limits.ResourceGuards.LargeTreeQueryMaxRows,
                    ResultType: 'simple',
                },
                contextUser,
            );

            if (!versionsRes?.Success) {
                LogError(
                    `ArtifactDualReadResolver: failed to query ${MJ_ARTIFACT_VERSIONS_ENTITY_NAME} headers: ${versionsRes?.ErrorMessage ?? 'RunView failed'}`,
                );
                continue;
            }

            const latestVersionsInChunk: RawArtifactVersionHeaderRow[] = [];
            for (const row of versionsRes.Results ?? []) {
                if (!row?.ID || !row.ArtifactID || !IsValidUUID(row.ID) || !IsValidUUID(row.ArtifactID)) continue;
                const normArtId = NormalizeUUID(row.ArtifactID);
                const existing = latestVersionByNormArtifactId.get(normArtId);
                if (!existing || row.VersionNumber > existing.VersionNumber) {
                    latestVersionByNormArtifactId.set(normArtId, row);
                }
            }

            for (const artId of accessibleArtifactIds) {
                const latest = latestVersionByNormArtifactId.get(NormalizeUUID(artId));
                if (latest) {
                    latestVersionsInChunk.push(latest);
                }
            }

            // 3. When content is requested, fetch Content strictly for the single latest version IDs via ID IN (...)
            if (includeContent && latestVersionsInChunk.length > 0) {
                const latestVersionIds = ValidateAndDeduplicateArtifactIDs(latestVersionsInChunk.map((v) => v.ID));
                if (latestVersionIds.length > 0) {
                    const contentRes = await rv.RunView<RawArtifactVersionContentRow>(
                        {
                            EntityName: MJ_ARTIFACT_VERSIONS_ENTITY_NAME,
                            ExtraFilter: BuildArtifactIdInFilter('ID', latestVersionIds),
                            Fields: ['ID', 'ArtifactID', 'VersionNumber', 'Content'],
                            MaxRows: latestVersionIds.length,
                            ResultType: 'simple',
                        },
                        contextUser,
                    );

                    if (!contentRes?.Success) {
                        LogError(
                            `ArtifactDualReadResolver: failed to query ${MJ_ARTIFACT_VERSIONS_ENTITY_NAME} content: ${contentRes?.ErrorMessage ?? 'RunView failed'}`,
                        );
                    } else {
                        for (const row of contentRes.Results ?? []) {
                            if (!row?.ID || !IsValidUUID(row.ID)) continue;
                            contentByNormVersionId.set(NormalizeUUID(row.ID), row.Content ?? null);
                        }
                    }
                }
            }
        }

        // Assemble deterministic per-record dual-read results
        for (const record of records) {
            const key = normalizeRecordKey(record.ID);
            const rawArtifactId = typeof record.ArtifactID === 'string' ? record.ArtifactID.trim() : '';
            if (!rawArtifactId) {
                result.set(key, buildFallbackResult(record, 'no_artifact_id'));
                continue;
            }
            if (!IsValidUUID(rawArtifactId)) {
                result.set(key, buildFallbackResult(record, 'invalid_artifact_id'));
                continue;
            }

            const normArtId = NormalizeUUID(rawArtifactId);
            const artifact = artifactByNormId.get(normArtId);
            if (!artifact) {
                result.set(key, buildFallbackResult(record, 'artifact_not_accessible'));
                continue;
            }

            const latestVersion = latestVersionByNormArtifactId.get(normArtId);
            if (!latestVersion) {
                result.set(key, buildFallbackResult(record, 'version_not_accessible', artifact));
                continue;
            }

            if (includeContent) {
                const normVerId = NormalizeUUID(latestVersion.ID);
                const content = contentByNormVersionId.get(normVerId);
                if (typeof content !== 'string' || content.trim().length === 0) {
                    result.set(key, buildFallbackResult(record, 'empty_artifact_content', artifact, latestVersion));
                    continue;
                }
                result.set(key, {
                    RecordID: record.ID,
                    Source: 'artifact',
                    FallbackReason: null,
                    Content: content,
                    LegacyBody: record.Body,
                    ArtifactID: artifact.ID,
                    ArtifactName: artifact.Name,
                    ArtifactDescription: artifact.Description ?? null,
                    ArtifactTypeID: artifact.TypeID ?? null,
                    ArtifactTypeName: artifact.Type ?? null,
                    VersionID: latestVersion.ID,
                    VersionNumber: latestVersion.VersionNumber,
                    VersionName: latestVersion.Name ?? null,
                    MimeType: latestVersion.MimeType ?? null,
                    ContentMode: latestVersion.ContentMode ?? null,
                    UpdatedAt: toIsoStringOrNull(latestVersion.__mj_UpdatedAt ?? artifact.__mj_UpdatedAt),
                });
            } else {
                result.set(key, {
                    RecordID: record.ID,
                    Source: 'artifact',
                    FallbackReason: null,
                    Content: record.Body,
                    LegacyBody: record.Body,
                    ArtifactID: artifact.ID,
                    ArtifactName: artifact.Name,
                    ArtifactDescription: artifact.Description ?? null,
                    ArtifactTypeID: artifact.TypeID ?? null,
                    ArtifactTypeName: artifact.Type ?? null,
                    VersionID: latestVersion.ID,
                    VersionNumber: latestVersion.VersionNumber,
                    VersionName: latestVersion.Name ?? null,
                    MimeType: latestVersion.MimeType ?? null,
                    ContentMode: latestVersion.ContentMode ?? null,
                    UpdatedAt: toIsoStringOrNull(latestVersion.__mj_UpdatedAt ?? artifact.__mj_UpdatedAt),
                });
            }
        }

        return result;
    }

    /**
     * Convenience wrapper resolving a single `WorkReport` or `MeetingNote` record.
     */
    public async ResolveSingle<T extends ArtifactBackableRecord>(
        record: T,
        options: ResolveArtifactBatchOptions = {},
    ): Promise<ResolvedArtifactContent> {
        const batch = await this.ResolveBatch([record], options);
        return (
            GetResolvedArtifactContent(batch, record.ID) ??
            buildFallbackResult(record, record.ArtifactID ? 'artifact_not_accessible' : 'no_artifact_id')
        );
    }
}
