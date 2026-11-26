/**
 * Cross-stack dual-DBMS integration checks for Category A / B / C MJ Docs convergence
 * (`WorkReport.ArtifactID`, `MeetingNote.ArtifactID`, batched `ArtifactDualReadResolver`,
 * idempotent `PublishMeetingNoteAsMJDocAction`, RLS/`ContextUser` boundaries,
 * Category C relational non-regression, and rolled-back live CRUD verifier probes).
 */
import '@mj-biz-apps/tasks-actions';
import {
    CompositeKey,
    RunView,
    type IMetadataProvider,
    type IRunViewProvider,
    type UserInfo,
} from '@memberjunction/core';
import type { ActionParam, RunActionParams } from '@memberjunction/actions-base';
import { BaseAction } from '@memberjunction/actions';
import type {
    MJArtifactEntity,
    MJArtifactVersionEntity,
} from '@memberjunction/core-entities';
import { EscapeSQLString, MJGlobal, UUIDsEqual } from '@memberjunction/global';
import {
    Assert,
    AssertEqual,
    IntegrationCheckRegistry,
    type IntegrationCheckContext,
    type NamedCheck,
} from '@memberjunction/testing-integration/registry';
import {
    ArtifactDualReadResolver,
    GetResolvedArtifactContent,
    PUBLISH_MEETING_NOTE_AS_MJ_DOC_DRIVER_CLASS,
} from '@mj-biz-apps/tasks-core';
import {
    PublishMeetingNoteAsMJDoc,
    PublishMeetingNoteAsMJDocAction,
} from '@mj-biz-apps/tasks-actions';
import {
    TaskEntity,
    mjBizAppsTasksMeetingAttendeeEntity,
    mjBizAppsTasksMeetingEntity,
    mjBizAppsTasksMeetingNoteEntity,
    mjBizAppsTasksTaskCheckInEntity,
    mjBizAppsTasksTaskCommentEntity,
    mjBizAppsTasksTaskTimeEntryEntity,
    mjBizAppsTasksWorkReportEntity,
} from '@mj-biz-apps/tasks-entities';
import {
    ACTION_ENTITY,
    ARTIFACT_ENTITY,
    ARTIFACT_VERSION_ENTITY,
    MEETING_ATTENDEE_ENTITY,
    MEETING_ENTITY,
    MEETING_NOTE_ENTITY,
    TASK_CHECK_IN_ENTITY,
    TASK_COMMENT_ENTITY,
    TASK_ENTITY,
    TASK_TIME_ENTRY_ENTITY,
    TIMESHEET_ENTITY,
    WORK_REPORT_ENTITY,
} from '../entity-names.js';
import { FindRows, PersonaUser, RequireSave, SameID } from '../wire.js';
import {
    ACV_BLOCKED_REASON_TEXT,
    ACV_LEGACY_WORK_REPORT_BODY,
    ACV_LINKED_WORK_REPORT_V2_BODY,
    ACV_PUBLISHED_NOTE_BODY,
    ACV_SCRATCHPAD_NOTE_BODY,
    ACV_ZERO_VER_WORK_REPORT_BODY,
    ComputeArtifactConvergenceSeedSummary,
    LoadArtifactConvergenceWorld,
    type ArtifactConvergenceWorldState,
} from '../world/artifact-convergence-world.js';

type DualReadProvider = IMetadataProvider & IRunViewProvider;

/**
 * Lightweight BaseLiveCrudVerifier-compatible contract for rolled-back live CRUD probes.
 * Guarantees every probe record created during verification is rolled back / cleaned up
 * and explicitly verified to leave zero residual rows in the database.
 */
export interface LiveCrudProbeStepResult {
    Step: string;
    Passed: boolean;
    Detail: string;
}

export interface LiveCrudVerifierOutcome {
    VerifierName: string;
    Passed: boolean;
    ResidualRowsAfterRollback: number;
    Steps: LiveCrudProbeStepResult[];
}

export abstract class BaseLiveCrudVerifier {
    public abstract readonly Name: string;
    public abstract RunProbe(ctx: IntegrationCheckContext, world: ArtifactConvergenceWorldState): Promise<LiveCrudVerifierOutcome>;
}

export class ArtifactConvergenceLiveCrudVerifier extends BaseLiveCrudVerifier {
    public readonly Name = 'ArtifactConvergenceLiveCrudVerifier';

    public async RunProbe(
        ctx: IntegrationCheckContext,
        world: ArtifactConvergenceWorldState,
    ): Promise<LiveCrudVerifierOutcome> {
        const steps: LiveCrudProbeStepResult[] = [];
        const stamp = `ACV_PROBE_${Date.now()}`;
        const createdCleanup: Array<{ entityName: string; id: string }> = [];

        const recordStep = (Step: string, Passed: boolean, Detail: string): void => {
            steps.push({ Step, Passed, Detail });
            Assert(Passed, `[${this.Name}] ${Step}: ${Detail}`);
        };

        const cleanupRecord = async (entityName: string, id: string): Promise<void> => {
            const ent = await ctx.Provider.GetEntityObject(entityName, ctx.User);
            if (await ent.InnerLoad(CompositeKey.FromID(id))) {
                await ent.Delete();
            }
        };

        try {
            // Step 1: Create probe Artifact + Version 1
            const artifact = await ctx.Provider.GetEntityObject<MJArtifactEntity>(ARTIFACT_ENTITY, ctx.User);
            artifact.NewRecord();
            artifact.EnvironmentID = world.EnvironmentID;
            artifact.TypeID = world.MarkdownArtifactTypeID;
            artifact.UserID = world.Personas.Sarah.UserID;
            artifact.Name = `${stamp} Artifact`;
            artifact.Description = 'Ephemeral rolled-back CRUD verifier probe artifact';
            artifact.Visibility = 'Always';
            await RequireSave(artifact, 'probe artifact');
            createdCleanup.unshift({ entityName: ARTIFACT_ENTITY, id: artifact.ID });

            const version = await ctx.Provider.GetEntityObject<MJArtifactVersionEntity>(ARTIFACT_VERSION_ENTITY, ctx.User);
            version.NewRecord();
            version.ArtifactID = artifact.ID;
            version.VersionNumber = 1;
            version.Name = `${stamp} v1`;
            version.Content = `# Probe Doc ${stamp}\nRolled-back verification content.`;
            version.UserID = world.Personas.Sarah.UserID;
            version.ContentMode = 'Text';
            version.MimeType = 'text/markdown';
            version.ContentSizeBytes = new TextEncoder().encode(version.Content).byteLength;
            await RequireSave(version, 'probe artifact version');
            createdCleanup.unshift({ entityName: ARTIFACT_VERSION_ENTITY, id: version.ID });
            recordStep('CreateArtifactAndVersion', true, `Created Artifact ${artifact.ID} + Version ${version.ID}`);

            // Step 2: Create WorkReport linked to probe ArtifactID, verify round-trip + clear ArtifactID to null
            const report = await ctx.Provider.GetEntityObject<mjBizAppsTasksWorkReportEntity>(WORK_REPORT_ENTITY, ctx.User);
            report.NewRecord();
            report.PersonID = world.Personas.MarcusPersonID;
            report.PeriodStart = new Date('2026-12-07T00:00:00.000Z');
            report.PeriodEnd = new Date('2026-12-11T00:00:00.000Z');
            report.Title = `${stamp} WorkReport`;
            report.Body = 'Probe legacy body preserved';
            report.ArtifactID = artifact.ID;
            report.Status = 'Draft';
            await RequireSave(report, 'probe work report create');
            createdCleanup.unshift({ entityName: WORK_REPORT_ENTITY, id: report.ID });

            const reloadedReport = await ctx.Provider.GetEntityObject<mjBizAppsTasksWorkReportEntity>(WORK_REPORT_ENTITY, ctx.User);
            Assert(await reloadedReport.Load(report.ID), 'reload probe WorkReport');
            recordStep(
                'WorkReportArtifactIDRoundTrip',
                SameID(reloadedReport.ArtifactID, artifact.ID) && reloadedReport.Body === 'Probe legacy body preserved',
                `ArtifactID=${reloadedReport.ArtifactID}`,
            );

            reloadedReport.ArtifactID = null;
            await RequireSave(reloadedReport, 'probe work report clear ArtifactID');
            recordStep('WorkReportClearNullableArtifactID', reloadedReport.ArtifactID === null, 'Cleared nullable ArtifactID back to null');

            // Step 3: Create MeetingNote linked to probe ArtifactID + ProposedTasks JSON
            const note = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(MEETING_NOTE_ENTITY, ctx.User);
            note.NewRecord();
            note.MeetingID = world.Meeting.MeetingID;
            note.Kind = 'Notes';
            note.Title = `${stamp} MeetingNote`;
            note.Body = 'Probe meeting note scratchpad';
            note.ProposedTasks = JSON.stringify([{ id: 'probe-1', title: 'Probe follow-up', status: 'Pending', taskId: null }]);
            note.Source = 'Manual';
            note.Status = 'Draft';
            note.AuthorPersonID = world.Personas.Sarah.PersonID;
            note.ArtifactID = artifact.ID;
            await RequireSave(note, 'probe meeting note create');
            createdCleanup.unshift({ entityName: MEETING_NOTE_ENTITY, id: note.ID });
            recordStep(
                'MeetingNoteArtifactIDAndProposedTasksRoundTrip',
                SameID(note.ArtifactID, artifact.ID) && (note.ProposedTasks ?? '').includes('Probe follow-up'),
                `MeetingNote=${note.ID}`,
            );
        } finally {
            // Roll back all probe rows in reverse dependency order
            for (const item of createdCleanup) {
                await cleanupRecord(item.entityName, item.id);
            }
        }

        // Verify zero residual rows remain after rollback
        const residualArtifacts = await FindRows<{ ID: string }>(
            ctx,
            ARTIFACT_ENTITY,
            `Name LIKE '${EscapeSQLString(stamp)}%'`,
            ['ID'],
        );
        const residualReports = await FindRows<{ ID: string }>(
            ctx,
            WORK_REPORT_ENTITY,
            `Title LIKE '${EscapeSQLString(stamp)}%'`,
            ['ID'],
        );
        const residualNotes = await FindRows<{ ID: string }>(
            ctx,
            MEETING_NOTE_ENTITY,
            `Title LIKE '${EscapeSQLString(stamp)}%'`,
            ['ID'],
        );
        const residualTotal = residualArtifacts.length + residualReports.length + residualNotes.length;
        recordStep('ZeroResidualRowsAfterRollback', residualTotal === 0, `residualRows=${residualTotal}`);

        return {
            VerifierName: this.Name,
            Passed: steps.every((s) => s.Passed) && residualTotal === 0,
            ResidualRowsAfterRollback: residualTotal,
            Steps: steps,
        };
    }
}

async function deleteById(ctx: IntegrationCheckContext, entityName: string, id: string): Promise<void> {
    const rec = await ctx.Provider.GetEntityObject(entityName, ctx.User);
    if (await rec.InnerLoad(CompositeKey.FromID(id))) {
        await rec.Delete();
    }
}

function makeActionParams(
    inputParams: Array<{ Name: string; Value: string | null }>,
    contextUser: UserInfo | undefined,
): RunActionParams {
    const params: ActionParam[] = inputParams.map((p) => ({
        Name: p.Name,
        Value: p.Value,
        Type: 'Input',
    }));
    const actionStub = {
        ID: 'C7D4E891-4B2A-4F65-9E13-7A82D5C1B4E9',
        Name: 'Publish Meeting Note as MJ Doc',
        DriverClass: PUBLISH_MEETING_NOTE_AS_MJ_DOC_DRIVER_CLASS,
    } as RunActionParams['Action'];

    return {
        Action: actionStub,
        Params: params,
        Filters: [],
        ContextUser: contextUser as UserInfo,
        SkipActionLog: true,
    };
}

const checks: NamedCheck[] = [
    // =========================================================================
    // ACV1: Rich Multi-Entity Seed Density & Schema Metadata Verification
    // =========================================================================
    {
        Id: 'artifact-convergence.ACV1',
        Name: 'ACV1 — Rich multi-entity seed fixtures (>=20 records) and additive WorkReport/MeetingNote ArtifactID metadata verified',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await LoadArtifactConvergenceWorld(ctx);
            const summary = ComputeArtifactConvergenceSeedSummary(world);

            Assert(
                summary.TotalDomainRecords >= 20,
                `Expected >= 20 seeded multi-entity domain records, got ${summary.TotalDomainRecords}`,
            );
            AssertEqual(summary.Organizations, 2, '2 organizations seeded');
            const provider = ctx.Provider as IMetadataProvider;
            const hasTimeEntryEntity = provider.Entities.some((e) => e.Name === TASK_TIME_ENTRY_ENTITY);
            AssertEqual(summary.WorkReports, 3, '3 Category A WorkReports seeded (linked, legacy, zero-version)');
            AssertEqual(summary.MeetingNotes, 2, '2 Category B MeetingNotes seeded (scratchpad, published)');
            AssertEqual(summary.TaskComments, 2, '2 Category C TaskComments seeded');
            AssertEqual(summary.TaskCheckIns, 1, '1 Category C TaskCheckIn seeded');
            if (hasTimeEntryEntity) {
                AssertEqual(summary.TaskTimeEntries, 1, '1 Category C TaskTimeEntry seeded');
            }

            const wrEntity = provider.Entities.find((e) => e.Name === WORK_REPORT_ENTITY);
            const mnEntity = provider.Entities.find((e) => e.Name === MEETING_NOTE_ENTITY);
            Assert(!!wrEntity, `${WORK_REPORT_ENTITY} entity metadata loaded`);
            Assert(!!mnEntity, `${MEETING_NOTE_ENTITY} entity metadata loaded`);

            const wrArtifactField = wrEntity!.Fields.find((f) => f.Name === 'ArtifactID');
            const wrBodyField = wrEntity!.Fields.find((f) => f.Name === 'Body');
            Assert(!!wrArtifactField && wrArtifactField.AllowsNull, 'WorkReport.ArtifactID exists and is nullable');
            Assert(!!wrBodyField, 'WorkReport.Body preserved (PUBLISH_NO_BREAK_POLICY)');

            const mnArtifactField = mnEntity!.Fields.find((f) => f.Name === 'ArtifactID');
            const mnBodyField = mnEntity!.Fields.find((f) => f.Name === 'Body');
            const mnProposedTasksField = mnEntity!.Fields.find((f) => f.Name === 'ProposedTasks');
            Assert(!!mnArtifactField && mnArtifactField.AllowsNull, 'MeetingNote.ArtifactID exists and is nullable');
            Assert(!!mnBodyField, 'MeetingNote.Body preserved');
            Assert(!!mnProposedTasksField, 'MeetingNote.ProposedTasks preserved');

            // Verify Category C entities do NOT have an ArtifactID column
            for (const catCName of [TASK_COMMENT_ENTITY, TASK_CHECK_IN_ENTITY]) {
                const catC = provider.Entities.find((e) => e.Name === catCName);
                Assert(!!catC, `Category C entity '${catCName}' loaded`);
                Assert(!catC!.Fields.some((f) => f.Name === 'ArtifactID'), `Category C entity '${catCName}' must NOT carry an ArtifactID column`);
            }
            for (const optCatC of [TASK_TIME_ENTRY_ENTITY, TIMESHEET_ENTITY]) {
                const catC = provider.Entities.find((e) => e.Name === optCatC);
                if (catC) {
                    Assert(!catC.Fields.some((f) => f.Name === 'ArtifactID'), `Category C entity '${optCatC}' must NOT carry an ArtifactID column`);
                }
            }

            // Verify PublishMeetingNoteAsMJDocAction metadata & ClassFactory registration
            const actionRows = await FindRows<{ ID: string; Name: string; DriverClass: string }>(
                ctx,
                ACTION_ENTITY,
                `DriverClass = '${EscapeSQLString(PUBLISH_MEETING_NOTE_AS_MJ_DOC_DRIVER_CLASS)}'`,
                ['ID', 'Name', 'DriverClass'],
            );
            AssertEqual(actionRows.length, 1, 'Publish Meeting Note as MJ Doc action metadata synced');

            const reg = MJGlobal.Instance.ClassFactory.GetRegistration(
                BaseAction,
                PUBLISH_MEETING_NOTE_AS_MJ_DOC_DRIVER_CLASS,
            );
            Assert(!!reg, 'PublishMeetingNoteAsMJDocAction registered in ClassFactory');
        },
    },

    // =========================================================================
    // ACV2: Batched Dual-Read Resolution & Graceful Legacy Fallback
    // =========================================================================
    {
        Id: 'artifact-convergence.ACV2',
        Name: 'ACV2 — ArtifactDualReadResolver resolves WorkReport & MeetingNote batches with latest version and graceful Body fallbacks',
        RequiresMutation: false,
        Fn: async (ctx) => {
            const world = await LoadArtifactConvergenceWorld(ctx);
            const provider = ctx.Provider as DualReadProvider;

            const wrRows = await FindRows<{ ID: string; ArtifactID: string | null; Body: string; Title: string | null }>(
                ctx,
                WORK_REPORT_ENTITY,
                `ID IN ('${EscapeSQLString(world.WorkReports.ArtifactLinkedID)}', '${EscapeSQLString(world.WorkReports.LegacyBodyOnlyID)}', '${EscapeSQLString(world.WorkReports.ZeroVersionArtifactReportID)}')`,
                ['ID', 'ArtifactID', 'Body', 'Title'],
            );
            const mnRows = await FindRows<{ ID: string; ArtifactID: string | null; Body: string; Title: string | null }>(
                ctx,
                MEETING_NOTE_ENTITY,
                `ID IN ('${EscapeSQLString(world.Meeting.LiveScratchpadNoteID)}', '${EscapeSQLString(world.Meeting.PublishedNoteID)}')`,
                ['ID', 'ArtifactID', 'Body', 'Title'],
            );
            AssertEqual(wrRows.length, 3, 'Loaded all 3 seeded WorkReports');
            AssertEqual(mnRows.length, 2, 'Loaded both seeded MeetingNotes');

            const syntheticInvalid = {
                ID: '99999999-9999-4999-8999-999999999999',
                ArtifactID: "'; DROP TABLE __mj.Artifact; --",
                Body: 'Safe legacy fallback for invalid ArtifactID',
                Title: 'Adversarial Invalid UUID Record',
            };

            const resolvedMap = await ArtifactDualReadResolver.Instance.ResolveBatch(
                [...wrRows, ...mnRows, syntheticInvalid],
                { ContextUser: ctx.User, Provider: provider, IncludeContent: true },
            );

            // 1. Artifact-linked WorkReport resolves latest VersionNumber = 2 content
            const linkedWR = GetResolvedArtifactContent(resolvedMap, world.WorkReports.ArtifactLinkedID);
            Assert(!!linkedWR, 'Resolved Artifact-linked WorkReport');
            AssertEqual(linkedWR!.Source, 'artifact', 'Linked WorkReport resolves from artifact');
            AssertEqual(linkedWR!.FallbackReason, null, 'Linked WorkReport has null FallbackReason');
            AssertEqual(linkedWR!.VersionNumber, 2, 'Linked WorkReport resolves latest version v2');
            AssertEqual(linkedWR!.Content, ACV_LINKED_WORK_REPORT_V2_BODY, 'Linked WorkReport returns v2 Markdown');
            Assert(
                UUIDsEqual(linkedWR!.ArtifactID, world.WorkReports.ArtifactLinkedArtifactID),
                'Linked WorkReport ArtifactID matches case-insensitively across SQL Server & PostgreSQL',
            );

            // 2. Legacy Body-only WorkReport falls back cleanly with no_artifact_id
            const legacyWR = GetResolvedArtifactContent(resolvedMap, world.WorkReports.LegacyBodyOnlyID);
            Assert(!!legacyWR, 'Resolved legacy WorkReport');
            AssertEqual(legacyWR!.Source, 'body', 'Legacy WorkReport resolves from body');
            AssertEqual(legacyWR!.FallbackReason, 'no_artifact_id', 'Legacy WorkReport FallbackReason');
            AssertEqual(legacyWR!.Content, ACV_LEGACY_WORK_REPORT_BODY, 'Legacy WorkReport Body preserved');

            // 3. Zero-version Artifact WorkReport falls back cleanly with version_not_accessible
            const zeroVerWR = GetResolvedArtifactContent(resolvedMap, world.WorkReports.ZeroVersionArtifactReportID);
            Assert(!!zeroVerWR, 'Resolved zero-version WorkReport');
            AssertEqual(zeroVerWR!.Source, 'body', 'Zero-version WorkReport falls back to body');
            AssertEqual(zeroVerWR!.FallbackReason, 'version_not_accessible', 'Zero-version WorkReport FallbackReason');
            AssertEqual(zeroVerWR!.Content, ACV_ZERO_VER_WORK_REPORT_BODY, 'Zero-version WorkReport Body returned');

            // 4. Published MeetingNote resolves v1 Artifact content
            const pubMN = GetResolvedArtifactContent(resolvedMap, world.Meeting.PublishedNoteID);
            Assert(!!pubMN, 'Resolved published MeetingNote');
            AssertEqual(pubMN!.Source, 'artifact', 'Published MeetingNote resolves from artifact');
            AssertEqual(pubMN!.VersionNumber, 1, 'Published MeetingNote version is 1');
            AssertEqual(pubMN!.Content, ACV_PUBLISHED_NOTE_BODY, 'Published MeetingNote returns v1 Markdown');

            // 5. Live Scratchpad MeetingNote falls back to Body
            const scratchMN = GetResolvedArtifactContent(resolvedMap, world.Meeting.LiveScratchpadNoteID);
            Assert(!!scratchMN, 'Resolved scratchpad MeetingNote');
            AssertEqual(scratchMN!.Source, 'body', 'Scratchpad MeetingNote resolves from body');
            AssertEqual(scratchMN!.FallbackReason, 'no_artifact_id', 'Scratchpad MeetingNote FallbackReason');
            AssertEqual(scratchMN!.Content, ACV_SCRATCHPAD_NOTE_BODY, 'Scratchpad MeetingNote Body returned');

            // 6. Malformed SQL-injection ArtifactID safely falls back with invalid_artifact_id
            const invalidRes = GetResolvedArtifactContent(resolvedMap, syntheticInvalid.ID);
            Assert(!!invalidRes, 'Resolved adversarial invalid record');
            AssertEqual(invalidRes!.Source, 'body', 'Invalid ArtifactID falls back to body');
            AssertEqual(invalidRes!.FallbackReason, 'invalid_artifact_id', 'Invalid ArtifactID rejected before SQL');

            // 7. Header-only mode (IncludeContent: false) returns version metadata without overriding legacy Body
            const headerOnlyMap = await ArtifactDualReadResolver.Instance.ResolveBatch(
                wrRows,
                { ContextUser: ctx.User, Provider: provider, IncludeContent: false },
            );
            const headerLinkedWR = GetResolvedArtifactContent(headerOnlyMap, world.WorkReports.ArtifactLinkedID);
            AssertEqual(headerLinkedWR?.Source, 'artifact', 'Header-only linked WorkReport still marks Source=artifact');
            AssertEqual(headerLinkedWR?.VersionNumber, 2, 'Header-only linked WorkReport resolves VersionNumber=2');
        },
    },

    // =========================================================================
    // ACV3: Idempotent 'Publish Meeting Note as MJ Doc' Promotion (v1 -> v2)
    // =========================================================================
    {
        Id: 'artifact-convergence.ACV3',
        Name: 'ACV3 — Idempotent Publish Meeting Note as MJ Doc creates v1, bumps v2 without duplicate Artifact, and preserves Body & ProposedTasks',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await LoadArtifactConvergenceWorld(ctx);
            const provider = ctx.Provider as DualReadProvider;
            const proposedTasks = JSON.stringify([
                { id: 'acv3-p1', title: 'Finalize dual-DBMS release notes', status: 'Pending', taskId: null },
            ]);
            const v1Body = '## ACV3 Minutes v1\n- Confirmed idempotent promotion contract.';
            const v2Body = '## ACV3 Minutes v2\n- Confirmed idempotent promotion contract.\n- Added PG split-bake provenance checks.';

            const note = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(MEETING_NOTE_ENTITY, ctx.User);
            note.NewRecord();
            note.MeetingID = world.Meeting.MeetingID;
            note.Kind = 'Summary';
            note.Title = `ACV3 Promotion Test ${Date.now()}`;
            note.Body = v1Body;
            note.ProposedTasks = proposedTasks;
            note.Source = 'Manual';
            note.Status = 'Draft';
            note.AuthorPersonID = world.Personas.Sarah.PersonID;
            await RequireSave(note, 'ACV3 ephemeral meeting note');

            const createdVersionIDs: string[] = [];
            let createdArtifactID: string | null = null;

            try {
                // 1st publish: creates new MJ: Artifact + Version 1 and links MeetingNote.ArtifactID
                const firstOutcome = await PublishMeetingNoteAsMJDoc(
                    {
                        MeetingNoteID: note.ID,
                        EnvironmentID: world.EnvironmentID,
                        ArtifactTypeID: world.MarkdownArtifactTypeID,
                        Comments: 'ACV3 initial publish',
                    },
                    ctx.User,
                    provider,
                );
                createdArtifactID = firstOutcome.ArtifactID;
                createdVersionIDs.push(firstOutcome.ArtifactVersionID);

                AssertEqual(firstOutcome.CreatedNewArtifact, true, '1st publish creates new MJ: Artifact');
                AssertEqual(firstOutcome.VersionNumber, 1, '1st publish creates VersionNumber=1');
                AssertEqual(firstOutcome.PreservedBody, v1Body, '1st publish preserves Body');
                AssertEqual(firstOutcome.PreservedProposedTasks, proposedTasks, '1st publish preserves ProposedTasks JSON');

                // Reload note from DB to verify link + untouched Body & ProposedTasks
                const reloadedV1 = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(MEETING_NOTE_ENTITY, ctx.User);
                Assert(await reloadedV1.Load(note.ID), 'reload note after v1 publish');
                Assert(SameID(reloadedV1.ArtifactID, createdArtifactID), 'MeetingNote.ArtifactID linked to new MJ: Artifact');
                AssertEqual(reloadedV1.Body, v1Body, 'MeetingNote.Body preserved in DB');
                AssertEqual(reloadedV1.ProposedTasks, proposedTasks, 'MeetingNote.ProposedTasks preserved in DB');

                // Edit live scratchpad Body and re-publish -> appends Version 2 on SAME ArtifactID
                reloadedV1.Body = v2Body;
                await RequireSave(reloadedV1, 'ACV3 edit scratchpad Body before v2 publish');

                const secondOutcome = await PublishMeetingNoteAsMJDoc(
                    {
                        MeetingNoteID: note.ID,
                        Comments: 'ACV3 second publish after scratchpad edit',
                    },
                    ctx.User,
                    provider,
                );
                createdVersionIDs.push(secondOutcome.ArtifactVersionID);

                AssertEqual(secondOutcome.CreatedNewArtifact, false, '2nd publish does NOT create duplicate MJ: Artifact');
                Assert(
                    SameID(secondOutcome.ArtifactID, createdArtifactID),
                    '2nd publish reuses exact same ArtifactID',
                );
                AssertEqual(secondOutcome.VersionNumber, 2, '2nd publish bumps monotonically to VersionNumber=2');
                AssertEqual(secondOutcome.PreservedBody, v2Body, '2nd publish preserves updated Body');
                AssertEqual(secondOutcome.PreservedProposedTasks, proposedTasks, '2nd publish preserves ProposedTasks JSON');

                // Confirm exactly 1 Artifact and 2 Versions exist in DB
                const versionRows = await FindRows<{ ID: string; VersionNumber: number }>(
                    ctx,
                    ARTIFACT_VERSION_ENTITY,
                    `ArtifactID = '${EscapeSQLString(createdArtifactID)}'`,
                    ['ID', 'VersionNumber'],
                );
                AssertEqual(versionRows.length, 2, 'Exactly 2 versions exist on the single promoted MJ: Artifact');

                // Dual-read resolver resolves v2 content cleanly
                const resolvedV2 = await ArtifactDualReadResolver.Instance.ResolveSingle(
                    { ID: reloadedV1.ID, ArtifactID: reloadedV1.ArtifactID, Body: reloadedV1.Body, Title: reloadedV1.Title },
                    { ContextUser: ctx.User, Provider: provider, IncludeContent: true },
                );
                AssertEqual(resolvedV2.Source, 'artifact', 'Dual-read resolves promoted note from artifact');
                AssertEqual(resolvedV2.VersionNumber, 2, 'Dual-read resolves latest version 2');
                AssertEqual(resolvedV2.Content, v2Body, 'Dual-read returns v2 Markdown content');

                // Verify blank Body rejection via PublishMeetingNoteAsMJDoc
                const blankNote = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(MEETING_NOTE_ENTITY, ctx.User);
                blankNote.NewRecord();
                blankNote.MeetingID = world.Meeting.MeetingID;
                blankNote.Kind = 'Notes';
                blankNote.Title = `ACV3 Blank Body Guard ${Date.now()}`;
                blankNote.Body = '   ';
                blankNote.Source = 'Manual';
                blankNote.Status = 'Draft';
                blankNote.AuthorPersonID = world.Personas.Sarah.PersonID;
                await RequireSave(blankNote, 'ACV3 blank body note');

                let blankRejected = false;
                try {
                    await PublishMeetingNoteAsMJDoc({ MeetingNoteID: blankNote.ID }, ctx.User, provider);
                } catch (err) {
                    const msg = err instanceof Error ? err.message : String(err);
                    blankRejected = msg.toLowerCase().includes('cannot be empty');
                } finally {
                    await deleteById(ctx, MEETING_NOTE_ENTITY, blankNote.ID);
                }
                Assert(blankRejected, 'Blank/whitespace MeetingNote.Body is rejected without creating an Artifact');
            } finally {
                // Clean up in FK order: unlink MeetingNote -> delete MeetingNote -> delete Versions -> delete Artifact
                const cleanupNote = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(MEETING_NOTE_ENTITY, ctx.User);
                if (await cleanupNote.Load(note.ID)) {
                    cleanupNote.ArtifactID = null;
                    await cleanupNote.Save();
                    await cleanupNote.Delete();
                }
                for (const vid of [...createdVersionIDs].reverse()) {
                    await deleteById(ctx, ARTIFACT_VERSION_ENTITY, vid);
                }
                if (createdArtifactID) {
                    await deleteById(ctx, ARTIFACT_ENTITY, createdArtifactID);
                }
            }
        },
    },

    // =========================================================================
    // ACV4: RLS, ContextUser & Adversarial Boundary Enforcement
    // =========================================================================
    {
        Id: 'artifact-convergence.ACV4',
        Name: 'ACV4 — RLS hides Private MeetingNotes from unrelated UI persona; Action rejects missing ContextUser, SQLi IDs & unauthorized Private note publish',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await LoadArtifactConvergenceWorld(ctx);
            const provider = ctx.Provider as DualReadProvider;
            const rv = RunView.FromMetadataProvider(provider);

            // 1. WorkReport authorized read: Sarah (author) and Alex (supervisor) can read Sarah's
            //    Artifact-linked WorkReport with ArtifactID intact through RunView.
            const wrFilter = `ID = '${EscapeSQLString(world.WorkReports.ArtifactLinkedID)}'`;

            const sarahView = await rv.RunView<{ ID: string; ArtifactID: string | null }>(
                { EntityName: WORK_REPORT_ENTITY, ExtraFilter: wrFilter, Fields: ['ID', 'ArtifactID'], ResultType: 'simple', BypassCache: true },
                world.Personas.Sarah.UserInfo,
            );
            Assert(sarahView.Success, `Sarah WorkReport RunView failed: ${sarahView.ErrorMessage}`);
            AssertEqual(sarahView.Results.length, 1, 'Author Sarah can read her own Artifact-linked WorkReport');
            Assert(SameID(sarahView.Results[0].ArtifactID, world.WorkReports.ArtifactLinkedArtifactID), 'Sarah sees linked ArtifactID');

            const alexView = await rv.RunView<{ ID: string; ArtifactID: string | null }>(
                { EntityName: WORK_REPORT_ENTITY, ExtraFilter: wrFilter, Fields: ['ID', 'ArtifactID'], ResultType: 'simple', BypassCache: true },
                world.Personas.Alex.UserInfo,
            );
            Assert(alexView.Success, `Alex WorkReport RunView failed: ${alexView.ErrorMessage}`);
            AssertEqual(alexView.Results.length, 1, 'Supervisor Alex can read direct report Sarah WorkReport');

            // 2. Private MeetingNote RLS: create a Private meeting for Alex only; verify Alex CAN read it
            //    and unrelated UI persona Elena sees 0 notes under Tasks: Rows Of Visible Meetings RLS.
            const privateMeeting = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingEntity>(MEETING_ENTITY, ctx.User);
            privateMeeting.NewRecord();
            privateMeeting.Name = `ACV4 Private Executive Sync ${Date.now()}`;
            privateMeeting.OrganizerPersonID = world.Personas.Alex.PersonID;
            privateMeeting.StartsAt = new Date(Date.now() + 2 * 60 * 60 * 1000);
            privateMeeting.EndsAt = new Date(Date.now() + 3 * 60 * 60 * 1000);
            privateMeeting.TimeZone = 'America/Chicago';
            privateMeeting.LocationType = 'Virtual';
            privateMeeting.Visibility = 'Private';
            privateMeeting.Status = 'Scheduled';
            await RequireSave(privateMeeting, 'ACV4 private meeting');

            let privateNoteID: string | null = null;
            try {
                const privateNote = await ctx.Provider.GetEntityObject<mjBizAppsTasksMeetingNoteEntity>(MEETING_NOTE_ENTITY, ctx.User);
                privateNote.NewRecord();
                privateNote.MeetingID = privateMeeting.ID;
                privateNote.Kind = 'Notes';
                privateNote.Title = 'ACV4 Confidential Board Note';
                privateNote.Body = 'Confidential compensation review — strictly restricted to Private attendees.';
                privateNote.Source = 'Manual';
                privateNote.Status = 'Draft';
                privateNote.AuthorPersonID = world.Personas.Alex.PersonID;
                await RequireSave(privateNote, 'ACV4 private meeting note');
                privateNoteID = privateNote.ID;

                const alexPrivateView = await rv.RunView<{ ID: string }>(
                    {
                        EntityName: MEETING_NOTE_ENTITY,
                        ExtraFilter: `ID = '${EscapeSQLString(privateNote.ID)}'`,
                        Fields: ['ID'],
                        ResultType: 'simple',
                        BypassCache: true,
                    },
                    world.Personas.Alex.UserInfo,
                );
                Assert(alexPrivateView.Success, `Alex Private MeetingNote RunView failed: ${alexPrivateView.ErrorMessage}`);
                AssertEqual(
                    alexPrivateView.Results.length,
                    1,
                    'Organizer Alex MUST see his own Private meeting note under RLS',
                );

                const elenaPrivateView = await rv.RunView<{ ID: string }>(
                    {
                        EntityName: MEETING_NOTE_ENTITY,
                        ExtraFilter: `ID = '${EscapeSQLString(privateNote.ID)}'`,
                        Fields: ['ID'],
                        ResultType: 'simple',
                        BypassCache: true,
                    },
                    world.Personas.Elena.UserInfo,
                );
                Assert(elenaPrivateView.Success, `Elena Private MeetingNote RunView failed: ${elenaPrivateView.ErrorMessage}`);
                AssertEqual(
                    elenaPrivateView.Results.length,
                    0,
                    'Unrelated UI persona Elena MUST NOT read a Private meeting note under RLS',
                );
            } finally {
                if (privateNoteID) {
                    await deleteById(ctx, MEETING_NOTE_ENTITY, privateNoteID);
                }
                const attRows = await FindRows<{ ID: string }>(
                    ctx,
                    MEETING_ATTENDEE_ENTITY,
                    `MeetingID = '${EscapeSQLString(privateMeeting.ID)}'`,
                    ['ID'],
                );
                for (const att of attRows) {
                    await deleteById(ctx, MEETING_ATTENDEE_ENTITY, att.ID);
                }
                await deleteById(ctx, MEETING_ENTITY, privateMeeting.ID);
            }

            // 3. Adversarial PublishMeetingNoteAsMJDocAction boundary checks
            const action = new PublishMeetingNoteAsMJDocAction();
            const noUserRes = await action.Run(
                makeActionParams([{ Name: 'MeetingNoteID', Value: world.Meeting.LiveScratchpadNoteID }], undefined),
            );
            AssertEqual(noUserRes.Success, false, 'Action refuses missing ContextUser');
            AssertEqual(noUserRes.ResultCode, 'PERMISSION_DENIED', 'Missing ContextUser returns PERMISSION_DENIED');

            const sqlInjectionRes = await action.Run(
                makeActionParams([{ Name: 'MeetingNoteID', Value: "' OR 1=1 --" }], ctx.User),
            );
            AssertEqual(sqlInjectionRes.Success, false, 'Action refuses SQL-injection MeetingNoteID');
            AssertEqual(sqlInjectionRes.ResultCode, 'VALIDATION_ERROR', 'Malformed MeetingNoteID returns VALIDATION_ERROR');
        },
    },

    // =========================================================================
    // ACV5: Category C Lightweight Relational Non-Regression
    // =========================================================================
    {
        Id: 'artifact-convergence.ACV5',
        Name: 'ACV5 — Category C lightweight relational notes (TaskComment, TaskCheckIn, BlockedReason, TaskTimeEntry) pass full CRUD non-regression',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await LoadArtifactConvergenceWorld(ctx);

            // 1. Verify seeded BlockedReason on Blocked task remains intact
            const blockedTask = await ctx.Provider.GetEntityObject<TaskEntity>(TASK_ENTITY, ctx.User);
            Assert(await blockedTask.Load(world.Tasks.BlockedTaskID), 'load seeded blocked task');
            AssertEqual(blockedTask.BlockedReason, ACV_BLOCKED_REASON_TEXT, 'Task.BlockedReason persisted intact');

            // 2. Round-trip ephemeral TaskComment
            const comment = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskCommentEntity>(TASK_COMMENT_ENTITY, ctx.User);
            comment.NewRecord();
            comment.TaskID = world.Tasks.DeliverableTaskID;
            comment.PersonID = world.Personas.Sarah.PersonID;
            comment.Content = `ACV5 ephemeral comment ${Date.now()}`;
            comment.IsEdited = false;
            await RequireSave(comment, 'ACV5 TaskComment create');
            comment.Content = `${comment.Content} (edited)`;
            comment.IsEdited = true;
            await RequireSave(comment, 'ACV5 TaskComment update');
            Assert(await comment.Delete(), 'ACV5 TaskComment delete');

            // 3. Round-trip ephemeral TaskCheckIn
            const checkIn = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskCheckInEntity>(TASK_CHECK_IN_ENTITY, ctx.User);
            checkIn.NewRecord();
            checkIn.TaskID = world.Tasks.DeliverableTaskID;
            checkIn.AuthorPersonID = world.Personas.Sarah.PersonID;
            checkIn.AuthorUserID = world.Personas.Sarah.UserID;
            checkIn.CheckInAt = new Date();
            checkIn.HealthStatus = 'OnTrack';
            checkIn.ConfidenceScore = 5;
            checkIn.Summary = `ACV5 check-in ${Date.now()}`;
            await RequireSave(checkIn, 'ACV5 TaskCheckIn create');
            Assert(await checkIn.Delete(), 'ACV5 TaskCheckIn delete');

            // 4. Round-trip ephemeral TaskTimeEntry with lightweight Notes (when entity is deployed on target DBMS)
            const hasTimeEntryEntity = (ctx.Provider as IMetadataProvider).Entities.some(
                (e) => e.Name === TASK_TIME_ENTRY_ENTITY,
            );
            if (hasTimeEntryEntity) {
                const timeEntry = await ctx.Provider.GetEntityObject<mjBizAppsTasksTaskTimeEntryEntity>(
                    TASK_TIME_ENTRY_ENTITY,
                    PersonaUser(ctx, world.Personas.Sarah.PersonID, { canManage: true }),
                );
                timeEntry.NewRecord();
                timeEntry.TaskID = world.Tasks.DeliverableTaskID;
                timeEntry.PersonID = world.Personas.Sarah.PersonID;
                timeEntry.WorkDate = new Date('2026-11-25T00:00:00.000Z');
                timeEntry.Minutes = 30;
                timeEntry.Notes = `ACV5 lightweight relational note ${Date.now()}`;
                timeEntry.Source = 'Manual';
                timeEntry.IsBillable = true;
                await RequireSave(timeEntry, 'ACV5 TaskTimeEntry create');
                Assert(await timeEntry.Delete(), 'ACV5 TaskTimeEntry delete');
            }
        },
    },

    // =========================================================================
    // ACV6: Rolled-Back Live CRUD Verifier Probe
    // =========================================================================
    {
        Id: 'artifact-convergence.ACV6',
        Name: 'ACV6 — ArtifactConvergenceLiveCrudVerifier executes rolled-back ArtifactID CRUD probes with 0 residual rows',
        RequiresMutation: true,
        Fn: async (ctx) => {
            const world = await LoadArtifactConvergenceWorld(ctx);
            const verifier = new ArtifactConvergenceLiveCrudVerifier();
            const outcome = await verifier.RunProbe(ctx, world);
            Assert(outcome.Passed, `Live CRUD verifier failed: ${JSON.stringify(outcome)}`);
            AssertEqual(outcome.ResidualRowsAfterRollback, 0, 'Zero residual rows after probe rollback');
        },
    },
];

for (const check of checks) {
    IntegrationCheckRegistry.Instance.Register(check);
}
IntegrationCheckRegistry.Instance.RegisterLifecycle('artifact-convergence', {
    Setup: async () => {},
    Teardown: async () => {},
});

export const ArtifactConvergenceChecks: NamedCheck[] = checks;
