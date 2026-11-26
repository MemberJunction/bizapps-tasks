import { BaseEntity, Metadata, RunView, type IMetadataProvider, type IRunViewProvider, type UserInfo } from '@memberjunction/core';
import type { MJArtifactEntity, MJArtifactVersionEntity } from '@memberjunction/core-entities';
import type { ActionResultSimple, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import { EscapeSQLString, IsValidUUID, RegisterClass } from '@memberjunction/global';
import {
    DEFAULT_MARKDOWN_ARTIFACT_TYPE_ID,
    DEFAULT_MJ_ENVIRONMENT_ID,
    entityFailure,
    GuidLiteral,
    MJ_ARTIFACT_TYPES_ENTITY_NAME,
    MJ_ARTIFACT_VERSIONS_ENTITY_NAME,
    MJ_ARTIFACTS_ENTITY_NAME,
    PUBLISH_MEETING_NOTE_AS_MJ_DOC_DRIVER_CLASS,
    TasksLimitsResolver,
} from '@mj-biz-apps/tasks-core';
import type { mjBizAppsTasksMeetingNoteEntity } from '@mj-biz-apps/tasks-entities';
import {
    checkTypedPolicyGuard,
    failResult,
    getStringParam,
    MEETING_NOTES_ENTITY,
    setOutputParam,
    successResult,
} from './action-helpers.js';

export type PublishMeetingNoteProvider = IMetadataProvider & IRunViewProvider;

export interface PublishMeetingNoteAsMJDocInput {
    MeetingNoteID: string;
    Title?: string | null;
    Description?: string | null;
    Comments?: string | null;
    ArtifactTypeID?: string | null;
    ArtifactTypeName?: string | null;
    EnvironmentID?: string | null;
}

export interface PublishMeetingNoteAsMJDocOutcome {
    MeetingNoteID: string;
    ArtifactID: string;
    ArtifactVersionID: string;
    VersionNumber: number;
    CreatedNewArtifact: boolean;
    Title: string;
    PreservedBody: string;
    PreservedProposedTasks: string | null;
}

interface RawArtifactTypeRow {
    ID: string;
    Name: string;
    ContentType?: string | null;
}

interface RawArtifactVersionNumberRow {
    ID: string;
    VersionNumber: number;
}

function utf8ByteLength(text: string): number {
    return new TextEncoder().encode(text).byteLength;
}

function createRunView(provider?: PublishMeetingNoteProvider): RunView {
    return provider ? RunView.FromMetadataProvider(provider) : new RunView();
}

async function getEntityObject<T extends BaseEntity>(
    entityName: string,
    contextUser: UserInfo,
    provider?: PublishMeetingNoteProvider,
): Promise<T> {
    if (provider) {
        return provider.GetEntityObject<T>(entityName, contextUser);
    }
    const md = new Metadata();
    return md.GetEntityObject<T>(entityName, contextUser);
}

async function resolveArtifactTypeId(
    input: { ArtifactTypeID?: string | null; ArtifactTypeName?: string | null },
    contextUser: UserInfo,
    provider?: PublishMeetingNoteProvider,
): Promise<string> {
    if (input.ArtifactTypeID) {
        const trimmed = input.ArtifactTypeID.trim();
        if (!IsValidUUID(trimmed)) {
            throw new Error(`ArtifactTypeID '${trimmed}' is not a valid UUID.`);
        }
        return trimmed;
    }

    const rv = createRunView(provider);
    const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
    const requestedName = input.ArtifactTypeName?.trim();

    if (requestedName) {
        const byName = await rv.RunView<RawArtifactTypeRow>(
            {
                EntityName: MJ_ARTIFACT_TYPES_ENTITY_NAME,
                ExtraFilter: `LOWER(Name) = LOWER('${EscapeSQLString(requestedName)}') AND IsEnabled = 1`,
                Fields: ['ID', 'Name', 'ContentType'],
                MaxRows: limits.ResourceGuards.DefaultLookupSingleRow,
                ResultType: 'simple',
            },
            contextUser,
        );
        const match = byName?.Success ? byName.Results?.[0] : undefined;
        if (!match?.ID) {
            throw new Error(`No enabled MJ: Artifact Type matched '${requestedName}'.`);
        }
        return match.ID;
    }

    const mdTypes = await rv.RunView<RawArtifactTypeRow>(
        {
            EntityName: MJ_ARTIFACT_TYPES_ENTITY_NAME,
            ExtraFilter:
                `IsEnabled = 1 AND (ContentType = 'text/markdown' OR LOWER(Name) IN ('markdown document', 'markdown'))`,
            Fields: ['ID', 'Name', 'ContentType'],
            OrderBy: 'Name ASC',
            MaxRows: limits.ResourceGuards.CandidateLookupMaxRows,
            ResultType: 'simple',
        },
        contextUser,
    );
    const preferred =
        mdTypes?.Success && mdTypes.Results?.length
            ? (mdTypes.Results.find((r) => r.Name.trim().toLowerCase() === 'markdown document') ?? mdTypes.Results[0])
            : undefined;

    return preferred?.ID ?? DEFAULT_MARKDOWN_ARTIFACT_TYPE_ID;
}

/**
 * Purely deterministic server helper that publishes a `MeetingNote` as a canonical `MJ: Artifact`
 * (MJ Doc) or appends the next monotonic `MJ: Artifact Versions` record if already linked.
 *
 * Guarantees:
 * - Strictly propagates `contextUser` to every `GetEntityObject` and `RunView` call.
 * - Rejects blank/whitespace-only `MeetingNote.Body` before writing any records.
 * - Creates `MJ: Artifacts` + `VersionNumber = 1` + links `MeetingNote.ArtifactID` cleanly when unlinked,
 *   cleaning up created records if a downstream save fails so no orphaned artifacts remain.
 * - Appends `maxVersionNumber + 1` on repeat publishes without ever creating a duplicate `MJ: Artifacts`.
 * - Strictly preserves `MeetingNote.Body` and `MeetingNote.ProposedTasks` untouched.
 */
export async function PublishMeetingNoteAsMJDoc(
    input: PublishMeetingNoteAsMJDocInput,
    contextUser: UserInfo,
    provider?: PublishMeetingNoteProvider,
): Promise<PublishMeetingNoteAsMJDocOutcome> {
    if (!input.MeetingNoteID || !IsValidUUID(input.MeetingNoteID)) {
        throw new Error('A valid MeetingNoteID UUID is required.');
    }

    const note = await getEntityObject<mjBizAppsTasksMeetingNoteEntity>(
        MEETING_NOTES_ENTITY,
        contextUser,
        provider,
    );
    if (!(await note.Load(input.MeetingNoteID))) {
        throw new Error(`MeetingNote '${input.MeetingNoteID}' was not found or is not accessible.`);
    }

    const originalBody = typeof note.Body === 'string' ? note.Body : '';
    const originalProposedTasks = note.ProposedTasks ?? null;
    if (originalBody.trim().length === 0) {
        throw new Error('Meeting note body cannot be empty when publishing as an MJ Doc.');
    }

    const resolvedTitle =
        input.Title?.trim() ||
        (typeof note.Title === 'string' && note.Title.trim().length > 0 ? note.Title.trim() : null) ||
        'Meeting Notes';
    const resolvedDescription =
        input.Description !== undefined
            ? (input.Description?.trim() || null)
            : `Published from ${note.Kind} meeting note`;
    const resolvedComments = input.Comments?.trim() || null;

    const existingArtifactId =
        typeof note.ArtifactID === 'string' && note.ArtifactID.trim().length > 0
            ? note.ArtifactID.trim()
            : null;

    if (existingArtifactId) {
        if (!IsValidUUID(existingArtifactId)) {
            throw new Error(`MeetingNote '${note.ID}' has an invalid ArtifactID '${existingArtifactId}'.`);
        }

        const existingArtifact = await getEntityObject<MJArtifactEntity>(
            MJ_ARTIFACTS_ENTITY_NAME,
            contextUser,
            provider,
        );
        if (!(await existingArtifact.Load(existingArtifactId))) {
            throw new Error(
                `Linked MJ: Artifact '${existingArtifactId}' was not found or is not accessible.`,
            );
        }

        const rv = createRunView(provider);
        const limits = TasksLimitsResolver.Instance.GetCurrentLimits();
        const latestVersionRes = await rv.RunView<RawArtifactVersionNumberRow>(
            {
                EntityName: MJ_ARTIFACT_VERSIONS_ENTITY_NAME,
                ExtraFilter: `ArtifactID = ${GuidLiteral(existingArtifactId, 'ArtifactID')}`,
                Fields: ['ID', 'VersionNumber'],
                OrderBy: 'VersionNumber DESC',
                MaxRows: limits.ResourceGuards.DefaultLookupSingleRow,
                ResultType: 'simple',
            },
            contextUser,
        );

        if (!latestVersionRes?.Success) {
            throw new Error(
                `Failed to inspect existing artifact versions: ${latestVersionRes?.ErrorMessage ?? 'RunView failed'}`,
            );
        }

        const highestVersion = latestVersionRes.Results?.[0]?.VersionNumber ?? 0;
        const nextVersionNumber = highestVersion + 1;

        const nextVersion = await getEntityObject<MJArtifactVersionEntity>(
            MJ_ARTIFACT_VERSIONS_ENTITY_NAME,
            contextUser,
            provider,
        );
        nextVersion.NewRecord();
        nextVersion.ArtifactID = existingArtifactId;
        nextVersion.VersionNumber = nextVersionNumber;
        nextVersion.Content = originalBody;
        nextVersion.Name = resolvedTitle;
        nextVersion.Description = resolvedDescription;
        nextVersion.Comments =
            resolvedComments ?? `Published version ${nextVersionNumber} from meeting note ${note.ID}`;
        nextVersion.UserID = contextUser.ID;
        nextVersion.ContentMode = 'Text';
        nextVersion.MimeType = 'text/markdown';
        nextVersion.ContentSizeBytes = utf8ByteLength(originalBody);

        if (!(await nextVersion.Save())) {
            throw new Error(`Failed to save MJ: Artifact Version: ${entityFailure(nextVersion)}`);
        }

        return {
            MeetingNoteID: note.ID,
            ArtifactID: existingArtifactId,
            ArtifactVersionID: nextVersion.ID,
            VersionNumber: nextVersionNumber,
            CreatedNewArtifact: false,
            Title: resolvedTitle,
            PreservedBody: originalBody,
            PreservedProposedTasks: originalProposedTasks,
        };
    }

    // Initial publication: create MJ: Artifacts + Version 1 + link MeetingNote.ArtifactID
    const environmentId = input.EnvironmentID?.trim() || DEFAULT_MJ_ENVIRONMENT_ID;
    if (!IsValidUUID(environmentId)) {
        throw new Error(`EnvironmentID '${environmentId}' is not a valid UUID.`);
    }
    const artifactTypeId = await resolveArtifactTypeId(
        {
            ArtifactTypeID: input.ArtifactTypeID,
            ArtifactTypeName: input.ArtifactTypeName,
        },
        contextUser,
        provider,
    );

    const artifact = await getEntityObject<MJArtifactEntity>(
        MJ_ARTIFACTS_ENTITY_NAME,
        contextUser,
        provider,
    );
    artifact.NewRecord();
    artifact.EnvironmentID = environmentId;
    artifact.Name = resolvedTitle;
    artifact.Description = resolvedDescription;
    artifact.TypeID = artifactTypeId;
    artifact.UserID = contextUser.ID;
    artifact.Visibility = 'Always';
    artifact.Comments = resolvedComments ?? `Published from meeting note ${note.ID}`;

    if (!(await artifact.Save())) {
        throw new Error(`Failed to create MJ: Artifact: ${entityFailure(artifact)}`);
    }

    const initialVersion = await getEntityObject<MJArtifactVersionEntity>(
        MJ_ARTIFACT_VERSIONS_ENTITY_NAME,
        contextUser,
        provider,
    );
    initialVersion.NewRecord();
    initialVersion.ArtifactID = artifact.ID;
    initialVersion.VersionNumber = 1;
    initialVersion.Content = originalBody;
    initialVersion.Name = resolvedTitle;
    initialVersion.Description = resolvedDescription;
    initialVersion.Comments = resolvedComments ?? `Initial publication from meeting note ${note.ID}`;
    initialVersion.UserID = contextUser.ID;
    initialVersion.ContentMode = 'Text';
    initialVersion.MimeType = 'text/markdown';
    initialVersion.ContentSizeBytes = utf8ByteLength(originalBody);

    try {
        if (!(await initialVersion.Save())) {
            throw new Error(`Failed to create initial MJ: Artifact Version: ${entityFailure(initialVersion)}`);
        }
    } catch (versionErr) {
        // Compensate so partial save never leaves an orphaned MJ: Artifact
        try {
            await artifact.Delete();
        } catch {
            // Best-effort cleanup
        }
        throw versionErr;
    }

    // Link ONLY ArtifactID on MeetingNote — strictly preserve Body and ProposedTasks untouched
    note.ArtifactID = artifact.ID;
    try {
        if (!(await note.Save())) {
            throw new Error(`Failed to link ArtifactID on MeetingNote: ${entityFailure(note)}`);
        }
    } catch (linkErr) {
        // Compensate so partial save never leaves orphaned Artifact Version or Artifact
        try {
            await initialVersion.Delete();
        } catch {
            // Best-effort cleanup
        }
        try {
            await artifact.Delete();
        } catch {
            // Best-effort cleanup
        }
        throw linkErr;
    }

    return {
        MeetingNoteID: note.ID,
        ArtifactID: artifact.ID,
        ArtifactVersionID: initialVersion.ID,
        VersionNumber: 1,
        CreatedNewArtifact: true,
        Title: resolvedTitle,
        PreservedBody: originalBody,
        PreservedProposedTasks: originalProposedTasks,
    };
}

function mapPublishError(message: string): { code: string; message: string } {
    if (/not found|not accessible/i.test(message)) {
        return { code: 'NOT_FOUND', message };
    }
    if (/valid .*UUID|cannot be empty|invalid ArtifactID|No enabled MJ: Artifact Type/i.test(message)) {
        return { code: 'VALIDATION_ERROR', message };
    }
    return { code: 'ERROR', message };
}

/**
 * Action: `Publish Meeting Note as MJ Doc` (`Tasks.PublishMeetingNoteAsMJDoc`)
 *
 * Deterministically publishes a Category B `MJ_BizApps_Tasks: Meeting Notes` record to
 * `MJ: Artifacts` + `MJ: Artifact Versions`, linking `MeetingNote.ArtifactID` on first publish
 * and appending monotonic versions (`VersionNumber = max + 1`) idempotently on subsequent publishes
 * while strictly preserving `MeetingNote.Body` and `MeetingNote.ProposedTasks`.
 */
@RegisterClass(BaseAction, PUBLISH_MEETING_NOTE_AS_MJ_DOC_DRIVER_CLASS)
export class PublishMeetingNoteAsMJDocAction extends BaseAction {
    public static override readonly AuthorizesCaller = true;

    protected override async InternalRunAction(params: RunActionParams): Promise<ActionResultSimple> {
        const user = params.ContextUser;
        if (!user) {
            return failResult('PERMISSION_DENIED', 'ContextUser is required.', params);
        }

        const meetingNoteID = getStringParam(params, 'MeetingNoteID', 'NoteID');
        if (!meetingNoteID || !IsValidUUID(meetingNoteID)) {
            return failResult('VALIDATION_ERROR', 'A valid MeetingNoteID UUID is required.', params);
        }

        const noteGuard = await checkTypedPolicyGuard({
            params,
            entityName: MEETING_NOTES_ENTITY,
            operation: 'Update',
            writeFields: ['ArtifactID'],
            actionName: PUBLISH_MEETING_NOTE_AS_MJ_DOC_DRIVER_CLASS,
        });
        if (!noteGuard.Allowed) return noteGuard.Failure;

        const artifactGuard = await checkTypedPolicyGuard({
            params,
            entityName: MJ_ARTIFACTS_ENTITY_NAME,
            operation: 'Create',
        });
        if (!artifactGuard.Allowed) return artifactGuard.Failure;

        const versionGuard = await checkTypedPolicyGuard({
            params,
            entityName: MJ_ARTIFACT_VERSIONS_ENTITY_NAME,
            operation: 'Create',
        });
        if (!versionGuard.Allowed) return versionGuard.Failure;

        try {
            const outcome = await PublishMeetingNoteAsMJDoc(
                {
                    MeetingNoteID: meetingNoteID,
                    Title: getStringParam(params, 'Title'),
                    Description: getStringParam(params, 'Description'),
                    Comments: getStringParam(params, 'Comments'),
                    ArtifactTypeID: getStringParam(params, 'ArtifactTypeID'),
                    ArtifactTypeName: getStringParam(params, 'ArtifactTypeName'),
                    EnvironmentID: getStringParam(params, 'EnvironmentID'),
                },
                user,
            );

            const summary = outcome.CreatedNewArtifact
                ? `Published meeting note "${outcome.Title}" as new MJ Doc ${outcome.ArtifactID} (v${outcome.VersionNumber}).`
                : `Published new MJ Doc version v${outcome.VersionNumber} on artifact ${outcome.ArtifactID} for "${outcome.Title}".`;

            setOutputParam(params, 'MeetingNoteID', outcome.MeetingNoteID);
            setOutputParam(params, 'ArtifactID', outcome.ArtifactID);
            setOutputParam(params, 'ArtifactVersionID', outcome.ArtifactVersionID);
            setOutputParam(params, 'VersionNumber', outcome.VersionNumber);
            setOutputParam(params, 'CreatedNewArtifact', outcome.CreatedNewArtifact);
            setOutputParam(params, 'Summary', summary);
            return successResult(summary, params);
        } catch (err) {
            const mapped = mapPublishError(err instanceof Error ? err.message : String(err));
            return failResult(mapped.code, mapped.message, params);
        }
    }
}
