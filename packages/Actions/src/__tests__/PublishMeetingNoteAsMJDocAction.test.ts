import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { ActionParam, ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import type { UserInfo } from '@memberjunction/core';
import {
    DEFAULT_MARKDOWN_ARTIFACT_TYPE_ID,
    MJ_ARTIFACT_TYPES_ENTITY_NAME,
    MJ_ARTIFACT_VERSIONS_ENTITY_NAME,
    MJ_ARTIFACTS_ENTITY_NAME,
    PUBLISH_MEETING_NOTE_AS_MJ_DOC_ACTION_ID,
} from '@mj-biz-apps/tasks-core';

interface MockEntityState {
    entityName: string;
    contextUser?: UserInfo;
    ID: string;
    Body?: string;
    Title?: string | null;
    Kind?: string;
    ProposedTasks?: string | null;
    ArtifactID?: string | null;
    EnvironmentID?: string;
    Name?: string | null;
    Description?: string | null;
    TypeID?: string;
    UserID?: string;
    Visibility?: string;
    Comments?: string | null;
    VersionNumber?: number;
    Content?: string | null;
    ContentMode?: string;
    MimeType?: string | null;
    ContentSizeBytes?: number | null;
    deleted: boolean;
    saved: boolean;
    Load: ReturnType<typeof vi.fn>;
    NewRecord: ReturnType<typeof vi.fn>;
    Save: ReturnType<typeof vi.fn>;
    Delete: ReturnType<typeof vi.fn>;
}

const {
    checkEntityAccessMock,
    runViewMock,
    getEntityObjectMock,
    createdEntities,
} = vi.hoisted(() => ({
    checkEntityAccessMock: vi.fn(),
    runViewMock: vi.fn(),
    getEntityObjectMock: vi.fn(),
    createdEntities: [] as MockEntityState[],
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
vi.mock('@memberjunction/ai-core-plus', () => ({
    TypedActionPolicyGuard: {
        CheckEntityAccess: checkEntityAccessMock,
        MaskRecord: <T>(r: T) => r,
        MaskRows: <T>(r: T[]) => r,
    },
    AgentUserPolicyEngine: {
        Instance: {
            GetEffectivePolicyAgentChain: () => [],
        },
    },
}));
vi.mock('@memberjunction/ai-agents', () => ({
    AgentWakeTriggerService: { Instance: { TriggerWakeForWorkstream: vi.fn() } },
}));
vi.mock('@memberjunction/generic-database-provider', () => ({
    UserCache: { Instance: { GetSystemUser: vi.fn() } },
}));
vi.mock('@mj-biz-apps/common-entities', () => ({
    ResolveUserIDForPerson: vi.fn(),
}));
vi.mock('@memberjunction/core', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@memberjunction/core')>();
    return {
        ...actual,
        LogError: vi.fn(),
        LogStatus: vi.fn(),
        Metadata: class {
            public static Provider = { Entities: [] };
            public GetEntityObject = getEntityObjectMock;
        },
        RunView: class {
            public static FromMetadataProvider = () => ({ RunView: runViewMock });
            public RunView = runViewMock;
        },
    };
});

import {
    PublishMeetingNoteAsMJDocAction,
} from '../custom/PublishMeetingNoteAsMJDocAction.js';

interface InvokableAction {
    InternalRunAction(params: RunActionParams): Promise<ActionResultSimple>;
}

function createInvokableAction(): InvokableAction {
    return new PublishMeetingNoteAsMJDocAction() as Partial<InvokableAction> as InvokableAction;
}

const USER_FACILITATOR = {
    ID: 'aaaa1111-1111-4111-8111-111111111111',
    Email: 'facilitator@example.com',
    Name: 'Meeting Facilitator',
} as UserInfo;

const NOTE_ID = '11111111-1111-4111-8111-111111111111';
const EXISTING_ARTIFACT_ID = '22222222-2222-4222-8222-222222222222';
const NEW_ARTIFACT_ID = '33333333-3333-4333-8333-333333333333';
const VERSION_1_ID = '44444444-4444-4444-8444-444444444444';
const VERSION_2_ID = '55555555-5555-4555-8555-555555555555';

const SAMPLE_PROPOSED_TASKS = JSON.stringify([
    { id: 'proposal-1', title: 'Finalize Q4 Architecture Sign-off', status: 'Pending', taskId: null },
]);

function makeActionParams(input: Record<string, string | null>, contextUser?: UserInfo): RunActionParams {
    const paramsList: ActionParam[] = Object.entries(input).map(([Name, Value]) => ({
        Name,
        Value,
        Type: 'Input',
    }));
    return {
        Action: { ID: PUBLISH_MEETING_NOTE_AS_MJ_DOC_ACTION_ID, Name: 'Publish Meeting Note as MJ Doc' },
        ContextUser: contextUser,
        Params: paramsList,
    } as Partial<RunActionParams> as RunActionParams;
}

function getOutput(res: ActionResultSimple, name: string): unknown {
    return res.Params?.find((p) => p.Name.toLowerCase() === name.toLowerCase() && p.Type === 'Output')?.Value;
}

function makeEntityStub(
    entityName: string,
    id: string,
    initial: Partial<MockEntityState> = {},
    contextUser?: UserInfo,
): MockEntityState {
    const stub: MockEntityState = {
        entityName,
        contextUser,
        ID: id,
        deleted: false,
        saved: false,
        ...initial,
        Load: vi.fn(async () => true),
        NewRecord: vi.fn(() => {
            stub.ID = id;
        }),
        Save: vi.fn(async () => {
            stub.saved = true;
            return true;
        }),
        Delete: vi.fn(async () => {
            stub.deleted = true;
            return true;
        }),
    };
    createdEntities.push(stub);
    return stub;
}

describe('PublishMeetingNoteAsMJDocAction', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        createdEntities.length = 0;
        checkEntityAccessMock.mockResolvedValue({ Allowed: true, DeniedFieldPatterns: [] });
    });

    it('rejects missing ContextUser and invalid MeetingNoteID', async () => {
        const action = createInvokableAction();

        const noUser = await action.InternalRunAction(makeActionParams({ MeetingNoteID: NOTE_ID }, undefined));
        expect(noUser.Success).toBe(false);
        expect(noUser.ResultCode).toBe('PERMISSION_DENIED');

        const badId = await action.InternalRunAction(makeActionParams({ MeetingNoteID: 'not-a-uuid' }, USER_FACILITATOR));
        expect(badId.Success).toBe(false);
        expect(badId.ResultCode).toBe('VALIDATION_ERROR');
    });

    it('rejects blank or whitespace-only MeetingNote.Body before creating any artifact', async () => {
        const noteStub = makeEntityStub('MJ_BizApps_Tasks: Meeting Notes', NOTE_ID, {
            Title: 'Standup Notes',
            Kind: 'Notes',
            Body: '   \n\t  ',
            ProposedTasks: SAMPLE_PROPOSED_TASKS,
            ArtifactID: null,
        });
        getEntityObjectMock.mockImplementation(async (entityName: string, ctxUser?: UserInfo) => {
            noteStub.contextUser = ctxUser;
            return noteStub;
        });

        const action = createInvokableAction();
        const res = await action.InternalRunAction(makeActionParams({ MeetingNoteID: NOTE_ID }, USER_FACILITATOR));

        expect(res.Success).toBe(false);
        expect(res.ResultCode).toBe('VALIDATION_ERROR');
        expect(res.Message).toContain('cannot be empty');
        expect(getEntityObjectMock).toHaveBeenCalledTimes(1);
        expect(getEntityObjectMock).toHaveBeenCalledWith('MJ_BizApps_Tasks: Meeting Notes', USER_FACILITATOR);
        expect(noteStub.Save).not.toHaveBeenCalled();
    });

    it('creates MJ: Artifact + Version 1 and links MeetingNote.ArtifactID while strictly preserving Body and ProposedTasks', async () => {
        const noteBody = '## Weekly Sync Minutes\n- Confirmed milestone delivery schedule.\n- Approved rollout plan.';
        const noteStub = makeEntityStub('MJ_BizApps_Tasks: Meeting Notes', NOTE_ID, {
            Title: 'Weekly Sync Minutes',
            Kind: 'Summary',
            Body: noteBody,
            ProposedTasks: SAMPLE_PROPOSED_TASKS,
            ArtifactID: null,
        });
        const artifactStub = makeEntityStub(MJ_ARTIFACTS_ENTITY_NAME, NEW_ARTIFACT_ID);
        const versionStub = makeEntityStub(MJ_ARTIFACT_VERSIONS_ENTITY_NAME, VERSION_1_ID);

        getEntityObjectMock.mockImplementation(async (entityName: string, ctxUser?: UserInfo) => {
            if (entityName === 'MJ_BizApps_Tasks: Meeting Notes') {
                noteStub.contextUser = ctxUser;
                return noteStub;
            }
            if (entityName === MJ_ARTIFACTS_ENTITY_NAME) {
                artifactStub.contextUser = ctxUser;
                return artifactStub;
            }
            if (entityName === MJ_ARTIFACT_VERSIONS_ENTITY_NAME) {
                versionStub.contextUser = ctxUser;
                return versionStub;
            }
            throw new Error(`Unexpected entity ${entityName}`);
        });

        runViewMock.mockImplementation(async (params: { EntityName: string }) => {
            if (params.EntityName === MJ_ARTIFACT_TYPES_ENTITY_NAME) {
                return {
                    Success: true,
                    Results: [{ ID: DEFAULT_MARKDOWN_ARTIFACT_TYPE_ID, Name: 'Markdown Document', ContentType: 'text/markdown' }],
                };
            }
            return { Success: true, Results: [] };
        });

        const action = createInvokableAction();
        const res = await action.InternalRunAction(makeActionParams({ MeetingNoteID: NOTE_ID }, USER_FACILITATOR));

        expect(res.Success).toBe(true);
        expect(res.ResultCode).toBe('SUCCESS');
        expect(getOutput(res, 'ArtifactID')).toBe(NEW_ARTIFACT_ID);
        expect(getOutput(res, 'ArtifactVersionID')).toBe(VERSION_1_ID);
        expect(getOutput(res, 'VersionNumber')).toBe(1);
        expect(getOutput(res, 'CreatedNewArtifact')).toBe(true);

        // Verify ContextUser propagated to every RunView and GetEntityObject call
        expect(noteStub.contextUser).toBe(USER_FACILITATOR);
        expect(artifactStub.contextUser).toBe(USER_FACILITATOR);
        expect(versionStub.contextUser).toBe(USER_FACILITATOR);
        expect(runViewMock).toHaveBeenCalledWith(expect.objectContaining({ EntityName: MJ_ARTIFACT_TYPES_ENTITY_NAME }), USER_FACILITATOR);

        // Verify Artifact + Version 1 fields
        expect(artifactStub.Name).toBe('Weekly Sync Minutes');
        expect(artifactStub.TypeID).toBe(DEFAULT_MARKDOWN_ARTIFACT_TYPE_ID);
        expect(artifactStub.UserID).toBe(USER_FACILITATOR.ID);
        expect(versionStub.ArtifactID).toBe(NEW_ARTIFACT_ID);
        expect(versionStub.VersionNumber).toBe(1);
        expect(versionStub.Content).toBe(noteBody);
        expect(versionStub.ContentMode).toBe('Text');
        expect(versionStub.MimeType).toBe('text/markdown');

        // Verify MeetingNote.ArtifactID linked AND Body + ProposedTasks strictly untouched
        expect(noteStub.ArtifactID).toBe(NEW_ARTIFACT_ID);
        expect(noteStub.Body).toBe(noteBody);
        expect(noteStub.ProposedTasks).toBe(SAMPLE_PROPOSED_TASKS);
        expect(noteStub.Save).toHaveBeenCalledTimes(1);
    });

    it('appends Version 2+ idempotently on repeat publish without creating a duplicate MJ: Artifact', async () => {
        const updatedBody = '## Weekly Sync Minutes (Updated)\n- Added post-meeting follow-up notes.';
        const noteStub = makeEntityStub('MJ_BizApps_Tasks: Meeting Notes', NOTE_ID, {
            Title: 'Weekly Sync Minutes',
            Kind: 'Summary',
            Body: updatedBody,
            ProposedTasks: SAMPLE_PROPOSED_TASKS,
            ArtifactID: EXISTING_ARTIFACT_ID,
        });
        const existingArtifactStub = makeEntityStub(MJ_ARTIFACTS_ENTITY_NAME, EXISTING_ARTIFACT_ID, {
            Name: 'Weekly Sync Minutes',
        });
        const version2Stub = makeEntityStub(MJ_ARTIFACT_VERSIONS_ENTITY_NAME, VERSION_2_ID);

        getEntityObjectMock.mockImplementation(async (entityName: string, ctxUser?: UserInfo) => {
            if (entityName === 'MJ_BizApps_Tasks: Meeting Notes') {
                noteStub.contextUser = ctxUser;
                return noteStub;
            }
            if (entityName === MJ_ARTIFACTS_ENTITY_NAME) {
                existingArtifactStub.contextUser = ctxUser;
                return existingArtifactStub;
            }
            if (entityName === MJ_ARTIFACT_VERSIONS_ENTITY_NAME) {
                version2Stub.contextUser = ctxUser;
                return version2Stub;
            }
            throw new Error(`Unexpected entity ${entityName}`);
        });

        runViewMock.mockResolvedValue({
            Success: true,
            Results: [{ ID: VERSION_1_ID, VersionNumber: 1 }],
        });

        const action = createInvokableAction();
        const res = await action.InternalRunAction(makeActionParams({ MeetingNoteID: NOTE_ID }, USER_FACILITATOR));

        expect(res.Success).toBe(true);
        expect(getOutput(res, 'ArtifactID')).toBe(EXISTING_ARTIFACT_ID);
        expect(getOutput(res, 'ArtifactVersionID')).toBe(VERSION_2_ID);
        expect(getOutput(res, 'VersionNumber')).toBe(2);
        expect(getOutput(res, 'CreatedNewArtifact')).toBe(false);

        // Must NEVER create/save a duplicate MJ: Artifact or re-mutate MeetingNote
        expect(existingArtifactStub.Load).toHaveBeenCalledWith(EXISTING_ARTIFACT_ID);
        expect(existingArtifactStub.NewRecord).not.toHaveBeenCalled();
        expect(existingArtifactStub.Save).not.toHaveBeenCalled();
        expect(version2Stub.ArtifactID).toBe(EXISTING_ARTIFACT_ID);
        expect(version2Stub.VersionNumber).toBe(2);
        expect(version2Stub.Content).toBe(updatedBody);
        expect(version2Stub.Save).toHaveBeenCalledTimes(1);
        expect(noteStub.Save).not.toHaveBeenCalled();
        expect(noteStub.Body).toBe(updatedBody);
        expect(noteStub.ProposedTasks).toBe(SAMPLE_PROPOSED_TASKS);
    });

    it('cleans up orphaned artifact and version if linking MeetingNote.ArtifactID fails', async () => {
        const noteStub = makeEntityStub('MJ_BizApps_Tasks: Meeting Notes', NOTE_ID, {
            Title: 'Sync Note',
            Kind: 'Notes',
            Body: 'Concrete notes content',
            ProposedTasks: SAMPLE_PROPOSED_TASKS,
            ArtifactID: null,
        });
        noteStub.Save.mockResolvedValue(false);

        const artifactStub = makeEntityStub(MJ_ARTIFACTS_ENTITY_NAME, NEW_ARTIFACT_ID);
        const versionStub = makeEntityStub(MJ_ARTIFACT_VERSIONS_ENTITY_NAME, VERSION_1_ID);

        getEntityObjectMock.mockImplementation(async (entityName: string) => {
            if (entityName === 'MJ_BizApps_Tasks: Meeting Notes') return noteStub;
            if (entityName === MJ_ARTIFACTS_ENTITY_NAME) return artifactStub;
            if (entityName === MJ_ARTIFACT_VERSIONS_ENTITY_NAME) return versionStub;
            throw new Error(`Unexpected entity ${entityName}`);
        });
        runViewMock.mockResolvedValue({
            Success: true,
            Results: [{ ID: DEFAULT_MARKDOWN_ARTIFACT_TYPE_ID, Name: 'Markdown Document', ContentType: 'text/markdown' }],
        });

        const action = createInvokableAction();
        const res = await action.InternalRunAction(makeActionParams({ MeetingNoteID: NOTE_ID }, USER_FACILITATOR));

        expect(res.Success).toBe(false);
        expect(versionStub.Delete).toHaveBeenCalledTimes(1);
        expect(artifactStub.Delete).toHaveBeenCalledTimes(1);
    });
});
