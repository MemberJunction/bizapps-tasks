import { describe, expect, it, vi, beforeEach } from 'vitest';
import type { IMetadataProvider, IRunViewProvider, RunViewParams, UserInfo } from '@memberjunction/core';
import {
    ArtifactDualReadResolver,
    BuildArtifactIdInFilter,
    ChunkArtifactIDs,
    GetResolvedArtifactContent,
    MJ_ARTIFACT_VERSIONS_ENTITY_NAME,
    MJ_ARTIFACTS_ENTITY_NAME,
    TasksLimitsResolver,
    ValidateAndDeduplicateArtifactIDs,
    type ArtifactBackableRecord,
} from '../index.js';

const USER_CONTEXT = {
    ID: 'aaaa1111-1111-4111-8111-111111111111',
    Email: 'lead@example.com',
    Name: 'Engineering Lead',
} as UserInfo;

const ART_1 = '11111111-1111-4111-8111-111111111111';
const ART_2 = '22222222-2222-4222-8222-222222222222';
const ART_NO_VER = '33333333-3333-4333-8333-333333333333';
const ART_DENIED = '44444444-4444-4444-8444-444444444444';
const VER_1A = 'a1111111-1111-4111-8111-111111111111';
const VER_1B = 'b1111111-1111-4111-8111-111111111111';
const VER_2A = 'c2222222-2222-4222-8222-222222222222';

interface MockRunViewCall {
    params: RunViewParams;
    contextUser: UserInfo | undefined;
}

function createMockProvider(
    handler: (params: RunViewParams, contextUser?: UserInfo) => { Success: boolean; Results: object[]; ErrorMessage?: string },
): {
    provider: IMetadataProvider & IRunViewProvider;
    calls: MockRunViewCall[];
} {
    const calls: MockRunViewCall[] = [];
    const runViewFn = vi.fn(async (params: RunViewParams, contextUser?: UserInfo) => {
        calls.push({ params, contextUser });
        return handler(params, contextUser);
    });
    const provider = {
        RunView: runViewFn,
        RunViews: vi.fn(),
        Entities: [],
    } as Partial<IMetadataProvider & IRunViewProvider> as IMetadataProvider & IRunViewProvider;
    return { provider, calls };
}

describe('ArtifactDualReadResolver', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        TasksLimitsResolver.Instance.ClearConfigOverrides();
    });

    it('validates and deduplicates UUIDs case-insensitively while rejecting malformed values', () => {
        const result = ValidateAndDeduplicateArtifactIDs([
            null,
            undefined,
            '',
            '   ',
            "'; DROP TABLE Tasks; --",
            'not-a-uuid',
            `  ${ART_1.toUpperCase()}  `,
            ART_1.toLowerCase(),
            ART_2,
        ]);

        expect(result).toEqual([ART_1.toUpperCase(), ART_2]);
    });

    it('builds safe IN (...) filters and rejects invalid UUIDs', () => {
        expect(BuildArtifactIdInFilter('ID', [ART_1, ART_2])).toBe(`ID IN ('${ART_1}', '${ART_2}')`);
        expect(() => BuildArtifactIdInFilter('ID', [])).toThrow(/at least one valid UUID/);
        expect(() => BuildArtifactIdInFilter('ID', ["1111' OR '1'='1"])).toThrow(/not a valid ID/);
    });

    it('short-circuits empty or null-ArtifactID batches with zero RunView calls', async () => {
        const { provider, calls } = createMockProvider(() => ({ Success: true, Results: [] }));

        const emptyMap = await ArtifactDualReadResolver.Instance.ResolveBatch([], {
            ContextUser: USER_CONTEXT,
            Provider: provider,
        });
        expect(emptyMap.size).toBe(0);

        const records: ArtifactBackableRecord[] = [
            { ID: 'rec-null', ArtifactID: null, Body: 'Legacy report body' },
            { ID: 'rec-bad', ArtifactID: 'invalid-uuid', Body: 'Fallback for invalid ID' },
        ];
        const map = await ArtifactDualReadResolver.Instance.ResolveBatch(records, {
            ContextUser: USER_CONTEXT,
            Provider: provider,
        });

        expect(calls).toHaveLength(0);
        const nullResolved = GetResolvedArtifactContent(map, 'rec-null');
        expect(nullResolved?.Source).toBe('body');
        expect(nullResolved?.FallbackReason).toBe('no_artifact_id');
        expect(nullResolved?.Content).toBe('Legacy report body');

        const badResolved = GetResolvedArtifactContent(map, 'rec-bad');
        expect(badResolved?.Source).toBe('body');
        expect(badResolved?.FallbackReason).toBe('invalid_artifact_id');
        expect(badResolved?.Content).toBe('Fallback for invalid ID');
    });

    it('resolves latest MJ: Artifact Versions via batched ResultType=simple ID IN (...) queries and propagates contextUser', async () => {
        const { provider, calls } = createMockProvider((params) => {
            if (params.EntityName === MJ_ARTIFACTS_ENTITY_NAME) {
                return {
                    Success: true,
                    Results: [
                        {
                            ID: ART_1,
                            Name: 'Q4 Executive Work Report',
                            Description: 'Weekly leadership digest',
                            TypeID: '5E5883C2-0185-4E1E-8A1C-F514DBF52DB7',
                            Type: 'Markdown Document',
                            __mj_UpdatedAt: '2026-11-26T12:00:00.000Z',
                        },
                        {
                            ID: ART_NO_VER,
                            Name: 'Unpublished Artifact Header',
                            Description: null,
                            TypeID: '5E5883C2-0185-4E1E-8A1C-F514DBF52DB7',
                            Type: 'Markdown Document',
                            __mj_UpdatedAt: '2026-11-26T12:00:00.000Z',
                        },
                    ],
                };
            }
            if (params.EntityName === MJ_ARTIFACT_VERSIONS_ENTITY_NAME && !params.Fields?.includes('Content')) {
                // Version headers only (no Content pulled for superseded v1!)
                return {
                    Success: true,
                    Results: [
                        {
                            ID: VER_1A,
                            ArtifactID: ART_1,
                            VersionNumber: 1,
                            Name: 'Q4 Executive Work Report',
                            MimeType: 'text/markdown',
                            ContentMode: 'Text',
                            __mj_UpdatedAt: '2026-11-25T12:00:00.000Z',
                        },
                        {
                            ID: VER_1B,
                            ArtifactID: ART_1,
                            VersionNumber: 2,
                            Name: 'Q4 Executive Work Report (Revised)',
                            MimeType: 'text/markdown',
                            ContentMode: 'Text',
                            __mj_UpdatedAt: '2026-11-26T12:30:00.000Z',
                        },
                    ],
                };
            }
            if (params.EntityName === MJ_ARTIFACT_VERSIONS_ENTITY_NAME && params.Fields?.includes('Content')) {
                return {
                    Success: true,
                    Results: [
                        {
                            ID: VER_1B,
                            ArtifactID: ART_1,
                            VersionNumber: 2,
                            Content: '# Q4 Executive Work Report\n\nAll platform milestones are on track.',
                        },
                    ],
                };
            }
            return { Success: true, Results: [] };
        });

        const records: ArtifactBackableRecord[] = [
            { ID: 'wr-linked', ArtifactID: ART_1, Body: 'Legacy draft body' },
            { ID: 'wr-legacy', ArtifactID: null, Body: 'Legacy-only work report' },
            { ID: 'mn-no-ver', ArtifactID: ART_NO_VER, Body: 'Scratchpad fallback when version missing' },
            { ID: 'mn-rls-denied', ArtifactID: ART_DENIED, Body: 'Scratchpad fallback when artifact denied' },
        ];

        const map = await ArtifactDualReadResolver.Instance.ResolveBatch(records, {
            ContextUser: USER_CONTEXT,
            Provider: provider,
        });

        // Exactly 3 batched RunView calls (Artifacts IN, Version Headers IN, Latest Version Content IN) — never N+1!
        expect(calls).toHaveLength(3);
        for (const call of calls) {
            expect(call.params.ResultType).toBe('simple');
            expect(call.contextUser).toBe(USER_CONTEXT);
        }
        expect(calls[0].params.EntityName).toBe(MJ_ARTIFACTS_ENTITY_NAME);
        expect(calls[0].params.ExtraFilter).toContain('ID IN (');
        expect(calls[1].params.Fields).not.toContain('Content');
        // Latest version content fetch targets strictly VER_1B (never superseded VER_1A!)
        expect(calls[2].params.ExtraFilter).toBe(`ID IN ('${VER_1B}')`);

        const linked = GetResolvedArtifactContent(map, 'wr-linked');
        expect(linked?.Source).toBe('artifact');
        expect(linked?.FallbackReason).toBeNull();
        expect(linked?.VersionNumber).toBe(2);
        expect(linked?.VersionID).toBe(VER_1B);
        expect(linked?.ArtifactName).toBe('Q4 Executive Work Report');
        expect(linked?.Content).toContain('All platform milestones are on track.');
        expect(linked?.LegacyBody).toBe('Legacy draft body');

        const legacy = GetResolvedArtifactContent(map, 'wr-legacy');
        expect(legacy?.Source).toBe('body');
        expect(legacy?.FallbackReason).toBe('no_artifact_id');
        expect(legacy?.Content).toBe('Legacy-only work report');

        const noVer = GetResolvedArtifactContent(map, 'mn-no-ver');
        expect(noVer?.Source).toBe('body');
        expect(noVer?.FallbackReason).toBe('version_not_accessible');
        expect(noVer?.ArtifactName).toBe('Unpublished Artifact Header');
        expect(noVer?.Content).toBe('Scratchpad fallback when version missing');

        const denied = GetResolvedArtifactContent(map, 'mn-rls-denied');
        expect(denied?.Source).toBe('body');
        expect(denied?.FallbackReason).toBe('artifact_not_accessible');
        expect(denied?.Content).toBe('Scratchpad fallback when artifact denied');
    });

    it('chunks large ArtifactID sets into <= SqlInClauseChunkSize batches and respects IncludeContent=false for list views', async () => {
        // Generate 105 unique valid UUIDs
        const ids = Array.from({ length: 105 }, (_, i) => {
            const hex = (i + 1).toString(16).padStart(12, '0');
            return `00000000-0000-4000-8000-${hex}`;
        });

        const defaultChunks = ChunkArtifactIDs(ids);
        expect(defaultChunks).toHaveLength(2);
        expect(defaultChunks[0]).toHaveLength(100);
        expect(defaultChunks[1]).toHaveLength(5);

        // Requesting > SqlInClauseChunkSize is clamped to the safety ceiling
        const clampedChunks = ChunkArtifactIDs(ids, 5000);
        expect(clampedChunks).toHaveLength(2);
        expect(clampedChunks[0]).toHaveLength(100);

        const { provider, calls } = createMockProvider((params) => {
            if (params.EntityName === MJ_ARTIFACTS_ENTITY_NAME) {
                const filter = params.ExtraFilter ?? '';
                const allArtifacts = [
                    { ID: ART_1, Name: 'Doc 1' },
                    { ID: ART_2, Name: 'Doc 2' },
                ];
                return {
                    Success: true,
                    Results: allArtifacts.filter((a) => filter.includes(a.ID)),
                };
            }
            const filter = params.ExtraFilter ?? '';
            const allVersions = [
                { ID: VER_1B, ArtifactID: ART_1, VersionNumber: 3, MimeType: 'text/markdown', ContentMode: 'Text' },
                { ID: VER_2A, ArtifactID: ART_2, VersionNumber: 1, MimeType: 'text/markdown', ContentMode: 'Text' },
            ];
            return {
                Success: true,
                Results: allVersions.filter((v) => filter.includes(v.ArtifactID)),
            };
        });

        const records: ArtifactBackableRecord[] = [
            { ID: 'r1', ArtifactID: ART_1, Body: 'Body 1' },
            { ID: 'r2', ArtifactID: ART_2, Body: 'Body 2' },
        ];

        const map = await ArtifactDualReadResolver.Instance.ResolveBatch(records, {
            ContextUser: USER_CONTEXT,
            Provider: provider,
            ChunkSize: 1,
            IncludeContent: false,
        });

        // 2 chunks * (Artifacts query + Version header query) = 4 calls, ZERO Content queries
        expect(calls).toHaveLength(4);
        expect(calls.every((c) => !c.params.Fields?.includes('Content'))).toBe(true);
        expect(GetResolvedArtifactContent(map, 'r1')?.Source).toBe('artifact');
        expect(GetResolvedArtifactContent(map, 'r1')?.VersionNumber).toBe(3);
        expect(GetResolvedArtifactContent(map, 'r2')?.Source).toBe('artifact');
        expect(GetResolvedArtifactContent(map, 'r2')?.VersionNumber).toBe(1);
    });
});
