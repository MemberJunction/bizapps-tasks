import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import type { ActionParam, ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import type { IMetadataProvider, UserInfo } from '@memberjunction/core';
import type { TranscriptSourceBase } from '@mj-biz-apps/tasks-core';

const {
    checkEntityAccessMock,
    maskRecordMock,
    maskRowsMock,
    resolvePersonForUserMock,
    runViewMock,
    getEntityObjectMock,
    getCredentialMock,
    credentialConfigMock,
    resolveFileObjectMock,
    fileStorageConfigMock,
    readMeetingTranscriptFileMock,
    draftFromTranscriptMock,
    acceptProposedTaskMock,
    resolveTranscriptSourceMock,
    entitiesList,
} = vi.hoisted(() => ({
    checkEntityAccessMock: vi.fn(),
    maskRecordMock: vi.fn(<T extends object>(rec: T): T => rec),
    maskRowsMock: vi.fn(<T extends object>(rows: readonly T[]): T[] => [...rows]),
    resolvePersonForUserMock: vi.fn(),
    runViewMock: vi.fn(),
    getEntityObjectMock: vi.fn(),
    getCredentialMock: vi.fn(),
    credentialConfigMock: vi.fn(),
    resolveFileObjectMock: vi.fn(),
    fileStorageConfigMock: vi.fn(),
    readMeetingTranscriptFileMock: vi.fn(),
    draftFromTranscriptMock: vi.fn(),
    acceptProposedTaskMock: vi.fn(),
    resolveTranscriptSourceMock: vi.fn(),
    entitiesList: [
        { ID: 'e0000010-0000-4000-8000-000000000010', Name: 'MJ_BizApps_Tasks: Meetings' },
        { ID: 'e0000011-0000-4000-8000-000000000011', Name: 'MJ_BizApps_Tasks: Tasks' },
    ],
}));

vi.mock('@memberjunction/actions-base', () => ({}));
vi.mock('@memberjunction/actions', () => ({ BaseAction: class {} }));
vi.mock('@memberjunction/global', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/global')>();
    return {
        ...actual,
        RegisterClass: () => () => {},
    };
});
vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    const providerObj = {
        Entities: entitiesList,
        GetEntityObject: getEntityObjectMock,
        RunView: runViewMock,
    };
    return {
        ...actual,
        LogError: vi.fn(),
        LogStatus: vi.fn(),
        Metadata: class {
            public static Provider = providerObj;
            public Entities = entitiesList;
            public GetEntityObject = getEntityObjectMock;
        },
        RunView: class {
            public static FromMetadataProvider = () => ({ RunView: runViewMock });
            public RunView = runViewMock;
        },
    };
});
vi.mock('@memberjunction/ai-core-plus', () => ({
    TypedActionPolicyGuard: {
        CheckEntityAccess: checkEntityAccessMock,
        MaskRecord: maskRecordMock,
        MaskRows: maskRowsMock,
    },
}));
vi.mock('@memberjunction/ai-agents', () => ({
    AgentWakeTriggerService: { Instance: { TriggerWakeForWorkstream: vi.fn() } },
}));
vi.mock('@memberjunction/generic-database-provider', () => ({
    UserCache: { Instance: { GetSystemUser: vi.fn() } },
}));
vi.mock('@memberjunction/credentials', () => ({
    CredentialEngine: {
        Instance: {
            Config: credentialConfigMock,
            GetCredential: getCredentialMock,
        },
    },
}));
vi.mock('@memberjunction/storage', () => ({
    FileStorageEngine: {
        Instance: {
            Config: fileStorageConfigMock,
            ResolveFileObject: resolveFileObjectMock,
            GetAccountsByProviderID: vi.fn(() => []),
            ResolveStorageAccount: vi.fn(() => null),
        },
    },
}));
vi.mock('@mj-biz-apps/common-entities', () => ({
    ResolveUserIDForPerson: vi.fn(),
}));
vi.mock('@mj-biz-apps/tasks-core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@mj-biz-apps/tasks-core')>();
    return {
        ...actual,
        ResolveTranscriptSource: resolveTranscriptSourceMock,
        readMeetingTranscriptFile: readMeetingTranscriptFileMock,
        WorkReportService: {
            Instance: {
                ResolvePersonForUser: resolvePersonForUserMock,
            },
        },
        MeetingNotesService: class {
            public draftFromTranscript = draftFromTranscriptMock;
            public acceptProposedTask = acceptProposedTaskMock;
        },
    };
});

import {
    clearZoomTranscriptTokenCache,
    extractZoomMeetingIdFromUrl,
    ZoomTranscriptSource,
} from '../meetings/ZoomTranscriptSource.js';
import { AttachedFileTranscriptSource } from '../meetings/AttachedFileTranscriptSource.js';
import { MeetingTranscriptService } from '../meetings/MeetingTranscriptService.js';
import {
    AcceptMeetingCommitmentsAction,
    GetMeetingNotesAction,
    GetMyUpcomingMeetingsAction,
    PrepareMeetingBriefAction,
    ProcessMeetingTranscriptAction,
} from '../custom/MeetingTypedActions.js';

interface Invokable {
    InternalRunAction(params: RunActionParams): Promise<ActionResultSimple>;
}

const USER_ALICE = 'aaaa1111-1111-4111-8111-111111111111';
const PERSON_ALICE = '11111111-1111-4111-8111-111111111111';
const MEETING_1 = '22222222-2222-4222-8222-222222222201';
const NOTE_1 = '33333333-3333-4333-8333-333333333301';
const TASK_EXISTING = '44444444-4444-4444-8444-444444444401';
const TASK_NEW = '44444444-4444-4444-8444-444444444402';
const FILE_1 = '55555555-5555-4555-8555-555555555501';

const aliceUser = {
    ID: USER_ALICE,
    Name: 'Alice Ng',
    Email: 'alice@example.com',
} as Partial<UserInfo> as UserInfo;

function makeParams(inputs: Record<string, string | number | boolean | null | undefined>): ActionParam[] {
    return Object.entries(inputs).map(([Name, Value]) => ({ Name, Value, Type: 'Input' as const }));
}

function makeRunParams(params: ActionParam[]): RunActionParams {
    return { ContextUser: aliceUser, Params: params } as Partial<RunActionParams> as RunActionParams;
}

function run(action: object, params: RunActionParams): Promise<ActionResultSimple> {
    return (action as Invokable).InternalRunAction(params);
}

const originalFetch = globalThis.fetch;

beforeEach(() => {
    vi.clearAllMocks();
    clearZoomTranscriptTokenCache();
    checkEntityAccessMock.mockResolvedValue({ Allowed: true, Active: true, DeniedFieldPatterns: [] });
    resolvePersonForUserMock.mockResolvedValue({ ID: PERSON_ALICE, Email: 'alice@example.com' });
});

afterEach(() => {
    globalThis.fetch = originalFetch;
});

describe('ZoomTranscriptSource', () => {
    it('extracts Zoom meeting IDs from Zoom join URLs', () => {
        expect(extractZoomMeetingIdFromUrl('https://us02web.zoom.us/j/98765432101?pwd=abc')).toBe('98765432101');
        expect(extractZoomMeetingIdFromUrl('https://teams.microsoft.com/l/meetup-join/xyz')).toBeNull();
    });

    it('returns null when Zoom recordings endpoint returns 404 (not ready yet)', async () => {
        getCredentialMock.mockResolvedValueOnce({
            values: { client_id: 'cid', client_secret: 'csec', account_id: 'acct1' },
        });
        const fetchMock = vi
            .fn()
            .mockResolvedValueOnce({
                ok: true,
                status: 200,
                json: async () => ({ access_token: 'tok-1', expires_in: 3600 }),
            })
            .mockResolvedValueOnce({
                ok: false,
                status: 404,
                text: async () => 'Not Found',
            });
        globalThis.fetch = fetchMock as typeof globalThis.fetch;

        const source = new ZoomTranscriptSource();
        await source.Initialize({ CredentialID: 'cred-1' }, aliceUser);
        expect(source.IsConfigured).toBe(true);

        const ref = await source.FindTranscript(
            {
                Title: 'Weekly Sync',
                StartsAt: new Date('2026-11-20T15:00:00Z'),
                EndsAt: new Date('2026-11-20T15:30:00Z'),
                ProviderMeetingID: '98765432101',
            },
            aliceUser,
        );
        expect(ref).toBeNull();
    });

    it('finds a completed Zoom audio_transcript and parses WebVTT into speaker-labeled PlainText', async () => {
        getCredentialMock.mockResolvedValueOnce({
            values: { client_id: 'cid', client_secret: 'csec', account_id: 'acct2' },
        });
        const sampleVtt = `WEBVTT\n\n1\n00:00:01.000 --> 00:00:04.000\n<v Alice>ACTION: Send Q4 board deck to Amith</v>\n`;
        const fetchMock = vi
            .fn()
            .mockResolvedValueOnce({
                ok: true,
                status: 200,
                json: async () => ({ access_token: 'tok-2', expires_in: 3600 }),
            })
            .mockResolvedValueOnce({
                ok: true,
                status: 200,
                json: async () => ({
                    topic: 'Leadership Sync',
                    duration: 30,
                    recording_files: [
                        {
                            id: 'rf-1',
                            file_type: 'TRANSCRIPT',
                            recording_type: 'audio_transcript',
                            status: 'completed',
                            download_url: 'https://zoom.us/rec/download/vtt-1',
                        },
                    ],
                }),
            })
            .mockResolvedValueOnce({
                ok: true,
                status: 200,
                text: async () => sampleVtt,
            });
        globalThis.fetch = fetchMock as typeof globalThis.fetch;

        const source = new ZoomTranscriptSource();
        await source.Initialize({ CredentialID: 'cred-2' }, aliceUser);

        const ref = await source.FindTranscript(
            {
                Title: 'Leadership Sync',
                StartsAt: new Date('2026-11-20T15:00:00Z'),
                EndsAt: new Date('2026-11-20T15:30:00Z'),
                VideoJoinURL: 'https://us02web.zoom.us/j/98765432101',
            },
            aliceUser,
        );
        expect(ref).not.toBeNull();
        expect(ref?.SourceKey).toBe('ZoomTranscriptSource');

        const fetched = await source.FetchTranscript(ref!, aliceUser);
        expect(fetched.Speakers).toEqual(['Alice']);
        expect(fetched.PlainText).toBe('Alice: ACTION: Send Q4 board deck to Amith');
    });
});

describe('AttachedFileTranscriptSource', () => {
    it('reads attached TranscriptFileID via FileStorageEngine fallback and normalizes WebVTT', async () => {
        readMeetingTranscriptFileMock.mockResolvedValueOnce(null);
        getEntityObjectMock.mockResolvedValueOnce({
            Load: vi.fn().mockResolvedValue(true),
            ProviderID: 'prov-1',
            ProviderKey: 'transcripts/m1.vtt',
            Name: 'm1.vtt',
            ContentType: 'text/vtt',
        });
        resolveFileObjectMock.mockResolvedValueOnce({
            ObjectKey: 'transcripts/m1.vtt',
            Driver: {
                GetObject: vi.fn().mockResolvedValue(
                    new TextEncoder().encode('WEBVTT\n\n00:00:01.000 --> 00:00:03.000\nBob: DECISION: Ship Friday.\n'),
                ),
            },
        });

        const source = new AttachedFileTranscriptSource({
            Entities: entitiesList,
            GetEntityObject: getEntityObjectMock,
        } as Partial<IMetadataProvider> as IMetadataProvider);
        await source.Initialize({}, aliceUser);

        const ref = await source.FindTranscript(
            {
                MeetingID: MEETING_1,
                Title: 'Sync',
                StartsAt: new Date(),
                EndsAt: new Date(),
                TranscriptFileID: FILE_1,
            },
            aliceUser,
        );
        expect(ref?.ExternalTranscriptID).toBe(FILE_1);

        const fetched = await source.FetchTranscript(ref!, aliceUser);
        expect(fetched.PlainText).toBe('Bob: DECISION: Ship Friday.');
        expect(fetched.Speakers).toEqual(['Bob']);
    });
});

describe('MeetingTranscriptService', () => {
    it('returns TRANSCRIPT_NOT_READY when a configured source has no transcript yet', async () => {
        const provider = {
            Entities: entitiesList,
            GetEntityObject: vi.fn().mockResolvedValue({
                ID: MEETING_1,
                Name: 'Zoom Sync',
                StartsAt: new Date('2026-11-20T15:00:00Z'),
                EndsAt: new Date('2026-11-20T15:30:00Z'),
                VideoJoinURL: 'https://us02web.zoom.us/j/12345678901',
                TranscriptFileID: null,
                VideoProviderID: null,
                Load: vi.fn().mockResolvedValue(true),
            }),
        } as Partial<IMetadataProvider> as IMetadataProvider;

        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [] }) // attendees
            .mockResolvedValueOnce({ Success: true, Results: [{ CredentialID: 'c1', Configuration: null }] }); // ZOOM provider

        const fakeSource = {
            Initialize: vi.fn().mockResolvedValue(undefined),
            IsConfigured: true,
            FindTranscript: vi.fn().mockResolvedValue(null),
            FetchTranscript: vi.fn(),
        } as Partial<TranscriptSourceBase> as TranscriptSourceBase;

        const service = new MeetingTranscriptService(provider, () => fakeSource);
        const result = await service.ProcessMeetingTranscript({ MeetingID: MEETING_1 }, aliceUser);
        expect(result.Status).toBe('TRANSCRIPT_NOT_READY');
        expect(draftFromTranscriptMock).not.toHaveBeenCalled();
    });

    it('processes attached transcript first, extracts decisions, and deduplicates commitments against 30-day tasks', async () => {
        const provider = {
            Entities: entitiesList,
            GetEntityObject: vi.fn().mockResolvedValue({
                ID: MEETING_1,
                Name: 'Exec Sync',
                StartsAt: new Date('2026-11-20T15:00:00Z'),
                EndsAt: new Date('2026-11-20T15:30:00Z'),
                TranscriptFileID: FILE_1,
                Load: vi.fn().mockResolvedValue(true),
            }),
        } as Partial<IMetadataProvider> as IMetadataProvider;

        const attachedSource = {
            Initialize: vi.fn().mockResolvedValue(undefined),
            IsConfigured: true,
            FindTranscript: vi.fn().mockResolvedValue({
                SourceKey: 'AttachedFileTranscriptSource',
                ExternalTranscriptID: FILE_1,
                Format: 'text',
            }),
            FetchTranscript: vi.fn().mockResolvedValue({
                Reference: { SourceKey: 'AttachedFileTranscriptSource', ExternalTranscriptID: FILE_1 },
                PlainText: 'Alice: DECISION: Approve Q4 rollout.\nAlice: ACTION: Send Q4 board deck to Amith\nBob: ACTION: Book customer advisory call',
                Speakers: ['Alice', 'Bob'],
            }),
        } as Partial<TranscriptSourceBase> as TranscriptSourceBase;

        draftFromTranscriptMock.mockResolvedValueOnce({
            ID: NOTE_1,
            Body: '## Exec Sync — Summary',
            ProposedTasks: JSON.stringify([
                { id: 'proposal-1', title: 'Send Q4 board deck to Amith', status: 'Pending', taskId: null },
                { id: 'proposal-2', title: 'Book customer advisory call', status: 'Pending', taskId: null },
            ]),
        });

        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [] }) // attendees
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    { ID: TASK_EXISTING, Name: 'Send Q4 board deck to Amith', Description: null, Status: 'Open', Priority: 'High' },
                ],
            }) // recent tasks
            .mockResolvedValueOnce({ Success: true, Results: [] }); // task assignments

        const service = new MeetingTranscriptService(provider, () => attachedSource);
        const result = await service.ProcessMeetingTranscript({ MeetingID: MEETING_1 }, aliceUser);

        expect(result.Status).toBe('PROCESSED');
        expect(result.SourceKey).toBe('AttachedFileTranscriptSource');
        expect(result.Decisions).toEqual(['Approve Q4 rollout.']);
        expect(result.MatchedExistingTasks).toHaveLength(1);
        expect(result.MatchedExistingTasks[0].MatchedTask.TaskID).toBe(TASK_EXISTING);
        expect(result.ProposedNewCommitments).toHaveLength(1);
        expect(result.ProposedNewCommitments[0].ProposalID).toBe('proposal-2');
    });
});

describe('5 Typed Meetings Actions', () => {
    it('all 5 actions declare AuthorizesCaller = true', () => {
        expect(GetMyUpcomingMeetingsAction.AuthorizesCaller).toBe(true);
        expect(PrepareMeetingBriefAction.AuthorizesCaller).toBe(true);
        expect(ProcessMeetingTranscriptAction.AuthorizesCaller).toBe(true);
        expect(AcceptMeetingCommitmentsAction.AuthorizesCaller).toBe(true);
        expect(GetMeetingNotesAction.AuthorizesCaller).toBe(true);
    });

    it('GetMyUpcomingMeetingsAction lists upcoming meetings with prep flags', async () => {
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ MeetingID: MEETING_1 }] })
            .mockResolvedValueOnce({
                Success: true,
                Results: [
                    {
                        ID: MEETING_1,
                        Name: 'Product Review',
                        Status: 'Scheduled',
                        StartsAt: '2026-11-21T16:00:00Z',
                        EndsAt: '2026-11-21T17:00:00Z',
                        TimeZone: 'America/Chicago',
                        LocationType: 'Virtual',
                        Visibility: 'Standard',
                        TranscriptFileID: null,
                    },
                ],
            })
            .mockResolvedValueOnce({ Success: true, Results: [{ MeetingID: MEETING_1 }] }) // agenda
            .mockResolvedValueOnce({ Success: true, Results: [{ MeetingID: MEETING_1 }, { MeetingID: MEETING_1 }] }) // attendees
            .mockResolvedValueOnce({ Success: true, Results: [] }); // notes

        const params = makeParams({ DaysAhead: 7 });
        const res = await run(new GetMyUpcomingMeetingsAction(), makeRunParams(params));
        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        const meetings = JSON.parse(String(params.find((p) => p.Name === 'Meetings')?.Value));
        expect(meetings).toHaveLength(1);
        expect(meetings[0]).toMatchObject({ HasAgenda: true, AttendeeCount: 2, HasNotes: false });
    });

    it('PrepareMeetingBriefAction returns live-calendar recheck metadata, attendees, and open tasks', async () => {
        runViewMock
            .mockResolvedValueOnce({
                Success: true,
                Results: [{ ID: MEETING_1, Name: '1:1 Sync', Status: 'Scheduled', StartsAt: '2026-11-21T16:00:00Z', EndsAt: '2026-11-21T16:30:00Z', TimeZone: 'UTC', LocationType: 'Virtual', Visibility: 'Private', SeriesID: null }],
            })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: 'att-1', PersonID: PERSON_ALICE, DisplayName: 'Alice', Role: 'Organizer', ResponseStatus: 'Accepted' }] })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: 'ag-1', Sequence: 1, Name: 'Q4 priorities', Status: 'Planned' }] })
            .mockResolvedValueOnce({ Success: true, Results: [] }) // current notes
            .mockResolvedValueOnce({ Success: true, Results: [] }) // task links
            .mockResolvedValueOnce({ Success: true, Results: [{ TaskID: TASK_EXISTING }] }) // attendee assignments
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TASK_EXISTING, Name: 'Finish hiring plan', Status: 'Open', Priority: 'High', PercentComplete: 10 }] });

        const params = makeParams({ MeetingID: MEETING_1 });
        const res = await run(new PrepareMeetingBriefAction(), makeRunParams(params));
        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        const brief = JSON.parse(String(params.find((p) => p.Name === 'Brief')?.Value));
        expect(brief.LiveCalendarRecheck.Recommended).toBe(true);
        expect(brief.RelatedOpenTasks).toHaveLength(1);
    });

    it('ProcessMeetingTranscriptAction never auto-creates tasks unless AutoCreateCommitments is true', async () => {
        getEntityObjectMock.mockResolvedValueOnce({
            ID: MEETING_1,
            Name: 'Design Review',
            StartsAt: new Date('2026-11-20T15:00:00Z'),
            EndsAt: new Date('2026-11-20T15:30:00Z'),
            Load: vi.fn().mockResolvedValue(true),
        });
        draftFromTranscriptMock.mockResolvedValueOnce({
            ID: NOTE_1,
            Body: 'Summary',
            ProposedTasks: JSON.stringify([{ id: 'proposal-1', title: 'Update Figma spec', status: 'Pending', taskId: null }]),
        });
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [] })
            .mockResolvedValueOnce({ Success: true, Results: [] });

        const params = makeParams({
            MeetingID: MEETING_1,
            TranscriptText: 'Alice: ACTION: Update Figma spec',
        });
        const res = await run(new ProcessMeetingTranscriptAction(), makeRunParams(params));
        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(acceptProposedTaskMock).not.toHaveBeenCalled();
    });

    it('AcceptMeetingCommitmentsAction links existing duplicate matches and accepts new proposals', async () => {
        const noteEntity = {
            ID: NOTE_1,
            MeetingID: MEETING_1,
            ProposedTasks: JSON.stringify([
                { id: 'proposal-1', title: 'Send Q4 deck', status: 'Pending', taskId: null },
                { id: 'proposal-2', title: 'Schedule vendor call', status: 'Pending', taskId: null },
            ]),
            Load: vi.fn().mockResolvedValue(true),
            Save: vi.fn().mockResolvedValue(true),
        };
        const linkEntity = {
            NewRecord: vi.fn(),
            Save: vi.fn().mockResolvedValue(true),
        };
        getEntityObjectMock
            .mockResolvedValueOnce(noteEntity)
            .mockResolvedValueOnce(linkEntity);
        runViewMock.mockResolvedValueOnce({ Success: true, Results: [] }); // no existing link
        acceptProposedTaskMock.mockResolvedValueOnce({
            task: { ID: TASK_NEW, Name: 'Schedule vendor call' },
            proposal: { id: 'proposal-2', title: 'Schedule vendor call' },
        });

        const params = makeParams({
            MeetingNoteID: NOTE_1,
            LinkExistingMatches: JSON.stringify([{ ProposalID: 'proposal-1', ExistingTaskID: TASK_EXISTING }]),
        });
        const res = await run(new AcceptMeetingCommitmentsAction(), makeRunParams(params));
        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        expect(JSON.parse(String(params.find((p) => p.Name === 'LinkedTasks')?.Value))).toHaveLength(1);
        expect(JSON.parse(String(params.find((p) => p.Name === 'AcceptedTasks')?.Value))).toHaveLength(1);
    });

    it('GetMeetingNotesAction returns saved notes, decisions, and linked tasks', async () => {
        runViewMock
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: MEETING_1, Name: 'Board Prep', Status: 'Completed', StartsAt: '2026-11-20T15:00:00Z', EndsAt: '2026-11-20T16:00:00Z' }] })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: NOTE_1, Kind: 'Summary', Title: 'Notes', Body: 'DECISION: Approve Q4 budget.', Source: 'AI', Status: 'Draft', ProposedTasks: null }] })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: 'ag-1', Sequence: 1, Name: 'Budget', Status: 'Done', Outcome: 'Approved unanimously' }] })
            .mockResolvedValueOnce({ Success: true, Results: [{ TaskID: TASK_EXISTING }] })
            .mockResolvedValueOnce({ Success: true, Results: [{ ID: TASK_EXISTING, Name: 'Publish budget', Status: 'Open', DueAt: null }] });

        const params = makeParams({ MeetingID: MEETING_1 });
        const res = await run(new GetMeetingNotesAction(), makeRunParams(params));
        expect(res).toMatchObject({ Success: true, ResultCode: 'SUCCESS' });
        const payload = JSON.parse(String(params.find((p) => p.Name === 'MeetingNotes')?.Value));
        expect(payload.Notes).toHaveLength(1);
        expect(payload.Decisions).toContain('Approve Q4 budget.');
        expect(payload.Decisions).toContain('Budget: Approved unanimously');
        expect(payload.LinkedTasks).toHaveLength(1);
    });
});
