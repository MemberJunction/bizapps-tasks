-- =============================================================================
-- Seed Script: scripts/seed-artifact-convergence.sql
-- Purpose:
--   Idempotent multi-domain SQL Server seed fixtures for Category A / B / C
--   MJ Docs (ArtifactID) convergence in MemberJunction/bizapps-tasks.
--   Mirrors the domain data in:
--     packages/IntegrationTests/src/world/artifact-convergence-world.ts
--
--   Seeds 34 explicit domain rows across 11 tables and multiple statuses:
--     - [__mj].[Artifact] (3) & [__mj].[ArtifactVersion] (3)
--     - [__mj_BizAppsTasks].[Task] (5: Open, InProgress, Blocked, Completed)
--     - [__mj_BizAppsTasks].[WorkReport] (4: Draft, Submitted, Reviewed;
--       Category A ArtifactID-linked, legacy Body-only, and zero-version fallback)
--     - [__mj_BizAppsTasks].[WorkReportItem] (4: Completed, Blockers, Next, InProgress)
--     - [__mj_BizAppsTasks].[Meeting] (2: Scheduled, Completed)
--     - [__mj_BizAppsTasks].[MeetingAttendee] (3: Organizer, Required, Optional)
--     - [__mj_BizAppsTasks].[MeetingAgendaItem] (2: Done, InProgress)
--     - [__mj_BizAppsTasks].[MeetingNote] (3: Draft scratchpad with ProposedTasks JSON
--       and ArtifactID = NULL; Final published MJ Doc with ArtifactID preserving Body
--       & ProposedTasks; Final governance Decision note)
--     - [__mj_BizAppsTasks].[TaskComment] (3: Category C relational parent + reply + note)
--     - [__mj_BizAppsTasks].[TaskCheckIn] (2: Category C relational OnTrack & AtRisk)
--
--   Safe to run repeatedly: every INSERT is guarded by IF NOT EXISTS.
-- =============================================================================

SET NOCOUNT ON;
SET XACT_ABORT ON;

-- ---------------------------------------------------------------------------
-- 1. Resolve Existing Baseline Foreign Keys (Environment, ArtifactType,
--    User, Organizations, People, TaskTypes, TaskCategories)
-- ---------------------------------------------------------------------------
DECLARE @EnvID UNIQUEIDENTIFIER = (
    SELECT TOP 1 [ID] FROM [__mj].[Environment] ORDER BY [__mj_CreatedAt] ASC
);
DECLARE @MarkdownTypeID UNIQUEIDENTIFIER = (
    SELECT TOP 1 [ID]
    FROM [__mj].[ArtifactType]
    WHERE [IsEnabled] = 1
      AND (LOWER([Name]) = 'markdown document' OR LOWER([ContentType]) = 'text/markdown')
    ORDER BY [Priority] ASC
);
IF @MarkdownTypeID IS NULL
    SELECT TOP 1 @MarkdownTypeID = [ID] FROM [__mj].[ArtifactType] WHERE [IsEnabled] = 1;

DECLARE @SarahUserID UNIQUEIDENTIFIER = (
    SELECT TOP 1 [ID] FROM [__mj].[User] WHERE LOWER([Email]) = 'sarah.connor@task-world.test'
);
IF @SarahUserID IS NULL
    SELECT TOP 1 @SarahUserID = [ID] FROM [__mj].[User] WHERE [IsActive] = 1 ORDER BY [__mj_CreatedAt] ASC;

DECLARE @AlexUserID UNIQUEIDENTIFIER = (
    SELECT TOP 1 [ID] FROM [__mj].[User] WHERE LOWER([Email]) = 'alex.chen@task-world.test'
);
IF @AlexUserID IS NULL
    SET @AlexUserID = @SarahUserID;

DECLARE @ApexOrgID UNIQUEIDENTIFIER = (
    SELECT TOP 1 [ID] FROM [__mj_BizAppsCommon].[Organization] WHERE [Name] = N'Apex Cloud Systems'
);
IF @ApexOrgID IS NULL
    SELECT TOP 1 @ApexOrgID = [ID] FROM [__mj_BizAppsCommon].[Organization] ORDER BY [__mj_CreatedAt] ASC;

DECLARE @AcmeOrgID UNIQUEIDENTIFIER = (
    SELECT TOP 1 [ID] FROM [__mj_BizAppsCommon].[Organization] WHERE [Name] = N'Acme Enterprise Corp'
);
IF @AcmeOrgID IS NULL
    SET @AcmeOrgID = @ApexOrgID;

DECLARE @SarahPersonID UNIQUEIDENTIFIER = (
    SELECT TOP 1 [ID] FROM [__mj_BizAppsCommon].[Person] WHERE LOWER([Email]) = 'sarah.connor@task-world.test'
);
IF @SarahPersonID IS NULL
    SELECT TOP 1 @SarahPersonID = [ID] FROM [__mj_BizAppsCommon].[Person] ORDER BY [__mj_CreatedAt] ASC;

DECLARE @AlexPersonID UNIQUEIDENTIFIER = (
    SELECT TOP 1 [ID] FROM [__mj_BizAppsCommon].[Person] WHERE LOWER([Email]) = 'alex.chen@task-world.test'
);
IF @AlexPersonID IS NULL
    SET @AlexPersonID = @SarahPersonID;

DECLARE @ElenaPersonID UNIQUEIDENTIFIER = (
    SELECT TOP 1 [ID] FROM [__mj_BizAppsCommon].[Person] WHERE LOWER([Email]) = 'elena.rostova@task-world.test'
);
IF @ElenaPersonID IS NULL
    SET @ElenaPersonID = @AlexPersonID;

DECLARE @DeliverableTypeID UNIQUEIDENTIFIER = (
    SELECT TOP 1 [ID] FROM [__mj_BizAppsTasks].[TaskType] WHERE [Code] = N'DELIVERABLE' OR [Name] = N'Deliverable'
);
IF @DeliverableTypeID IS NULL
    SELECT TOP 1 @DeliverableTypeID = [ID] FROM [__mj_BizAppsTasks].[TaskType] ORDER BY [__mj_CreatedAt] ASC;

DECLARE @GeneralTypeID UNIQUEIDENTIFIER = (
    SELECT TOP 1 [ID] FROM [__mj_BizAppsTasks].[TaskType] WHERE [Code] = N'GENERAL' OR [Name] = N'General'
);
IF @GeneralTypeID IS NULL
    SET @GeneralTypeID = @DeliverableTypeID;

DECLARE @ActionItemTypeID UNIQUEIDENTIFIER = (
    SELECT TOP 1 [ID] FROM [__mj_BizAppsTasks].[TaskType] WHERE [Code] = N'ACTION_ITEM' OR [Name] = N'Action Item'
);
IF @ActionItemTypeID IS NULL
    SET @ActionItemTypeID = @GeneralTypeID;

DECLARE @EngCategoryID UNIQUEIDENTIFIER = (
    SELECT TOP 1 [ID] FROM [__mj_BizAppsTasks].[TaskCategory] WHERE [Name] = N'Engineering & Development'
);
IF @EngCategoryID IS NULL
    SELECT TOP 1 @EngCategoryID = [ID] FROM [__mj_BizAppsTasks].[TaskCategory] ORDER BY [__mj_CreatedAt] ASC;

-- Deterministic IDs for idempotent convergence fixtures
DECLARE @ArtLinkedReportID UNIQUEIDENTIFIER = 'A1000001-AC01-4E10-9B01-000000000001';
DECLARE @ArtZeroVersionID  UNIQUEIDENTIFIER = 'A1000001-AC01-4E10-9B01-000000000002';
DECLARE @ArtPublishedNoteID UNIQUEIDENTIFIER = 'A1000001-AC01-4E10-9B01-000000000003';

DECLARE @ArtVerReportV1ID UNIQUEIDENTIFIER = 'A1000002-AC01-4E10-9B01-000000000001';
DECLARE @ArtVerReportV2ID UNIQUEIDENTIFIER = 'A1000002-AC01-4E10-9B01-000000000002';
DECLARE @ArtVerNoteV1ID   UNIQUEIDENTIFIER = 'A1000002-AC01-4E10-9B01-000000000003';

DECLARE @TaskRootID        UNIQUEIDENTIFIER = 'A1000003-AC01-4E10-9B01-000000000001';
DECLARE @TaskDeliverableID UNIQUEIDENTIFIER = 'A1000003-AC01-4E10-9B01-000000000002';
DECLARE @TaskBlockedID     UNIQUEIDENTIFIER = 'A1000003-AC01-4E10-9B01-000000000003';
DECLARE @TaskFollowUpID    UNIQUEIDENTIFIER = 'A1000003-AC01-4E10-9B01-000000000004';
DECLARE @TaskCompletedID   UNIQUEIDENTIFIER = 'A1000003-AC01-4E10-9B01-000000000005';

DECLARE @ReportLinkedID    UNIQUEIDENTIFIER = 'A1000004-AC01-4E10-9B01-000000000001';
DECLARE @ReportLegacyID    UNIQUEIDENTIFIER = 'A1000004-AC01-4E10-9B01-000000000002';
DECLARE @ReportZeroVerID   UNIQUEIDENTIFIER = 'A1000004-AC01-4E10-9B01-000000000003';
DECLARE @ReportOpsReviewID UNIQUEIDENTIFIER = 'A1000004-AC01-4E10-9B01-000000000004';

DECLARE @ReportItem1ID UNIQUEIDENTIFIER = 'A1000005-AC01-4E10-9B01-000000000001';
DECLARE @ReportItem2ID UNIQUEIDENTIFIER = 'A1000005-AC01-4E10-9B01-000000000002';
DECLARE @ReportItem3ID UNIQUEIDENTIFIER = 'A1000005-AC01-4E10-9B01-000000000003';
DECLARE @ReportItem4ID UNIQUEIDENTIFIER = 'A1000005-AC01-4E10-9B01-000000000004';

DECLARE @MeetingArchID       UNIQUEIDENTIFIER = 'A1000006-AC01-4E10-9B01-000000000001';
DECLARE @MeetingComplianceID UNIQUEIDENTIFIER = 'A1000006-AC01-4E10-9B01-000000000002';

DECLARE @AttendeeAlexID  UNIQUEIDENTIFIER = 'A1000007-AC01-4E10-9B01-000000000001';
DECLARE @AttendeeSarahID UNIQUEIDENTIFIER = 'A1000007-AC01-4E10-9B01-000000000002';
DECLARE @AttendeeElenaID UNIQUEIDENTIFIER = 'A1000007-AC01-4E10-9B01-000000000003';

DECLARE @AgendaItem1ID UNIQUEIDENTIFIER = 'A1000008-AC01-4E10-9B01-000000000001';
DECLARE @AgendaItem2ID UNIQUEIDENTIFIER = 'A1000008-AC01-4E10-9B01-000000000002';

DECLARE @NoteScratchpadID UNIQUEIDENTIFIER = 'A1000009-AC01-4E10-9B01-000000000001';
DECLARE @NotePublishedID  UNIQUEIDENTIFIER = 'A1000009-AC01-4E10-9B01-000000000002';
DECLARE @NoteDecisionID   UNIQUEIDENTIFIER = 'A1000009-AC01-4E10-9B01-000000000003';

DECLARE @CommentParentID  UNIQUEIDENTIFIER = 'A1000010-AC01-4E10-9B01-000000000001';
DECLARE @CommentReplyID   UNIQUEIDENTIFIER = 'A1000010-AC01-4E10-9B01-000000000002';
DECLARE @CommentBlockedID UNIQUEIDENTIFIER = 'A1000010-AC01-4E10-9B01-000000000003';

DECLARE @CheckInOnTrackID UNIQUEIDENTIFIER = 'A1000011-AC01-4E10-9B01-000000000001';
DECLARE @CheckInAtRiskID  UNIQUEIDENTIFIER = 'A1000011-AC01-4E10-9B01-000000000002';

-- ---------------------------------------------------------------------------
-- 2. MJ Docs: [__mj].[Artifact] (3 rows) & [__mj].[ArtifactVersion] (3 rows)
-- ---------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [__mj].[Artifact] WHERE [ID] = @ArtLinkedReportID)
INSERT INTO [__mj].[Artifact] ([ID], [EnvironmentID], [Name], [Description], [TypeID], [UserID], [Visibility])
VALUES (
    @ArtLinkedReportID,
    @EnvID,
    N'ACV Executive Work Report MJ Doc',
    N'Canonical MJ Doc backing for Category A executive work report',
    @MarkdownTypeID,
    @SarahUserID,
    N'Always'
);

IF NOT EXISTS (SELECT 1 FROM [__mj].[Artifact] WHERE [ID] = @ArtZeroVersionID)
INSERT INTO [__mj].[Artifact] ([ID], [EnvironmentID], [Name], [Description], [TypeID], [UserID], [Visibility])
VALUES (
    @ArtZeroVersionID,
    @EnvID,
    N'ACV Zero-Version Artifact Stub',
    N'Artifact header intentionally created without any MJ: Artifact Versions rows for fallback testing',
    @MarkdownTypeID,
    @SarahUserID,
    N'Always'
);

IF NOT EXISTS (SELECT 1 FROM [__mj].[Artifact] WHERE [ID] = @ArtPublishedNoteID)
INSERT INTO [__mj].[Artifact] ([ID], [EnvironmentID], [Name], [Description], [TypeID], [UserID], [Visibility])
VALUES (
    @ArtPublishedNoteID,
    @EnvID,
    N'ACV Published Architecture Minutes MJ Doc',
    N'Published MJ Doc for ACV Architecture & Minutes Review',
    @MarkdownTypeID,
    @AlexUserID,
    N'Always'
);

IF NOT EXISTS (SELECT 1 FROM [__mj].[ArtifactVersion] WHERE [ID] = @ArtVerReportV1ID)
INSERT INTO [__mj].[ArtifactVersion] (
    [ID], [ArtifactID], [VersionNumber], [Name], [Content], [UserID],
    [ContentMode], [MimeType], [ContentSizeBytes], [ForceToolsOnly]
)
VALUES (
    @ArtVerReportV1ID,
    @ArtLinkedReportID,
    1,
    N'ACV Executive Work Report MJ Doc v1',
    N'# Q4 Executive Work Report (Draft v1)' + CHAR(10) + CHAR(10) + N'- Initial dual-read rollout metrics collected across engineering teams.',
    @SarahUserID,
    N'Text',
    N'text/markdown',
    108,
    0
);

IF NOT EXISTS (SELECT 1 FROM [__mj].[ArtifactVersion] WHERE [ID] = @ArtVerReportV2ID)
INSERT INTO [__mj].[ArtifactVersion] (
    [ID], [ArtifactID], [VersionNumber], [Name], [Content], [UserID],
    [ContentMode], [MimeType], [ContentSizeBytes], [ForceToolsOnly]
)
VALUES (
    @ArtVerReportV2ID,
    @ArtLinkedReportID,
    2,
    N'ACV Executive Work Report MJ Doc v2',
    N'# Q4 Executive Work Report (Canonical v2)' + CHAR(10) + CHAR(10) + N'## Key Accomplishments' + CHAR(10) + N'- Deployed nullable ArtifactID foreign keys across SQL Server and PostgreSQL.' + CHAR(10) + N'- Verified batched dual-read resolution with zero N+1 query regressions.',
    @SarahUserID,
    N'Text',
    N'text/markdown',
    218,
    0
);

IF NOT EXISTS (SELECT 1 FROM [__mj].[ArtifactVersion] WHERE [ID] = @ArtVerNoteV1ID)
INSERT INTO [__mj].[ArtifactVersion] (
    [ID], [ArtifactID], [VersionNumber], [Name], [Content], [UserID],
    [ContentMode], [MimeType], [ContentSizeBytes], [ForceToolsOnly]
)
VALUES (
    @ArtVerNoteV1ID,
    @ArtPublishedNoteID,
    1,
    N'ACV Published Architecture Minutes MJ Doc v1',
    N'## Published Architecture Minutes' + CHAR(10) + N'- Approved dual-read batching via ArtifactDualReadResolver.' + CHAR(10) + N'- Approved idempotent Publish Meeting Note as MJ Doc action.',
    @AlexUserID,
    N'Text',
    N'text/markdown',
    154,
    0
);

-- ---------------------------------------------------------------------------
-- 3. Hierarchical Tasks: [__mj_BizAppsTasks].[Task] (5 rows: InProgress,
--    Blocked with BlockedReason, Open, Completed)
-- ---------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[Task] WHERE [ID] = @TaskRootID)
INSERT INTO [__mj_BizAppsTasks].[Task] (
    [ID], [Name], [Description], [TypeID], [CategoryID], [ParentID],
    [Status], [Priority], [PercentComplete], [Sequence], [RollupWeight],
    [CreatedByPersonID], [OrganizationID], [Visibility]
)
VALUES (
    @TaskRootID,
    N'ACV Initiative — Q4 MJ Docs Convergence Rollout',
    N'Roll out additive nullable ArtifactID FKs on WorkReport and MeetingNote across SQL Server and PostgreSQL.',
    @DeliverableTypeID,
    @EngCategoryID,
    NULL,
    N'InProgress',
    N'High',
    55,
    10,
    1.0,
    @AlexPersonID,
    @ApexOrgID,
    N'Organization'
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[Task] WHERE [ID] = @TaskDeliverableID)
INSERT INTO [__mj_BizAppsTasks].[Task] (
    [ID], [Name], [Description], [TypeID], [CategoryID], [ParentID],
    [Status], [Priority], [PercentComplete], [Sequence], [RollupWeight],
    [CreatedByPersonID], [OrganizationID], [Visibility]
)
VALUES (
    @TaskDeliverableID,
    N'ACV Deliverable — WorkReport Dual-Read Rollout',
    N'Implement batched ArtifactDualReadResolver and WorkReportArtifactPanel.',
    @DeliverableTypeID,
    @EngCategoryID,
    @TaskRootID,
    N'InProgress',
    N'High',
    80,
    20,
    1.0,
    @SarahPersonID,
    @ApexOrgID,
    N'Team'
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[Task] WHERE [ID] = @TaskBlockedID)
INSERT INTO [__mj_BizAppsTasks].[Task] (
    [ID], [Name], [Description], [TypeID], [CategoryID], [ParentID],
    [Status], [Priority], [PercentComplete], [Sequence], [RollupWeight],
    [BlockedReason], [CreatedByPersonID], [OrganizationID], [Visibility]
)
VALUES (
    @TaskBlockedID,
    N'ACV Blocked Task — Pending External Security Sign-Off',
    N'Validate compliance sign-off before releasing customer-facing convergence pack.',
    @GeneralTypeID,
    @EngCategoryID,
    @TaskRootID,
    N'Blocked',
    N'Critical',
    20,
    30,
    1.0,
    N'Awaiting third-party SOC2 penetration test attestation before production cutover.',
    @SarahPersonID,
    @AcmeOrgID,
    N'Team'
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[Task] WHERE [ID] = @TaskFollowUpID)
INSERT INTO [__mj_BizAppsTasks].[Task] (
    [ID], [Name], [Description], [TypeID], [CategoryID], [ParentID],
    [Status], [Priority], [PercentComplete], [Sequence], [RollupWeight],
    [CreatedByPersonID], [OrganizationID], [Visibility]
)
VALUES (
    @TaskFollowUpID,
    N'ACV Follow-Up — Finalize Meeting Minutes Promotion Guide',
    N'Finalize developer rubric comparing MJ Docs, MJ Comments, and Category C relational notes.',
    @ActionItemTypeID,
    @EngCategoryID,
    @TaskRootID,
    N'Open',
    N'Medium',
    10,
    40,
    1.0,
    @AlexPersonID,
    @ApexOrgID,
    N'Team'
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[Task] WHERE [ID] = @TaskCompletedID)
INSERT INTO [__mj_BizAppsTasks].[Task] (
    [ID], [Name], [Description], [TypeID], [CategoryID], [ParentID],
    [Status], [Priority], [PercentComplete], [Sequence], [RollupWeight],
    [CompletionNotes], [CompletedAt], [CreatedByPersonID], [OrganizationID], [Visibility]
)
VALUES (
    @TaskCompletedID,
    N'ACV Milestone — Dual-Dialect Migration Parity Verified',
    N'Verify additive nullable ArtifactID foreign keys and filtered indexes across SQL Server and PostgreSQL.',
    @DeliverableTypeID,
    @EngCategoryID,
    @TaskRootID,
    N'Completed',
    N'High',
    100,
    50,
    1.0,
    N'Verified 6-category schema-delta equivalence with split-bake provenance header.',
    SYSDATETIMEOFFSET(),
    @AlexPersonID,
    @ApexOrgID,
    N'Organization'
);

-- ---------------------------------------------------------------------------
-- 4. Category A: [__mj_BizAppsTasks].[WorkReport] (4 rows across Draft,
--    Submitted, Reviewed) & [__mj_BizAppsTasks].[WorkReportItem] (4 rows)
-- ---------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[WorkReport] WHERE [ID] = @ReportLinkedID)
INSERT INTO [__mj_BizAppsTasks].[WorkReport] (
    [ID], [PersonID], [PeriodStart], [PeriodEnd], [Title], [Body], [Status], [ArtifactID]
)
VALUES (
    @ReportLinkedID,
    @SarahPersonID,
    '2026-11-16',
    '2026-11-20',
    N'ACV Executive Work Report — Artifact-Backed (Category A)',
    N'Legacy preview snapshot preserved alongside canonical MJ Doc.',
    N'Submitted',
    @ArtLinkedReportID
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[WorkReport] WHERE [ID] = @ReportLegacyID)
INSERT INTO [__mj_BizAppsTasks].[WorkReport] (
    [ID], [PersonID], [PeriodStart], [PeriodEnd], [Title], [Body],
    [Status], [ArtifactID], [ReviewedByPersonID], [ReviewedAt], [SupervisorFeedback]
)
VALUES (
    @ReportLegacyID,
    @SarahPersonID,
    '2026-11-09',
    '2026-11-13',
    N'ACV Historical Work Report — Legacy Body-Only (Category A)',
    N'### Historical Summary' + CHAR(10) + N'- Completed baseline migration verification prior to MJ Docs backing.' + CHAR(10) + N'- Retained full legacy Markdown Body readability without breaking changes.',
    N'Reviewed',
    NULL,
    @AlexPersonID,
    SYSDATETIMEOFFSET(),
    N'Verified seamless legacy Body fallback continuity.'
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[WorkReport] WHERE [ID] = @ReportZeroVerID)
INSERT INTO [__mj_BizAppsTasks].[WorkReport] (
    [ID], [PersonID], [PeriodStart], [PeriodEnd], [Title], [Body], [Status], [ArtifactID]
)
VALUES (
    @ReportZeroVerID,
    @SarahPersonID,
    '2026-11-23',
    '2026-11-27',
    N'ACV Restricted Work Report — Zero-Version Artifact Fallback',
    N'### Fallback Executive Summary' + CHAR(10) + N'- Artifact metadata exists without a readable version; legacy Body remains authoritative.',
    N'Draft',
    @ArtZeroVersionID
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[WorkReport] WHERE [ID] = @ReportOpsReviewID)
INSERT INTO [__mj_BizAppsTasks].[WorkReport] (
    [ID], [PersonID], [PeriodStart], [PeriodEnd], [Title], [Body],
    [Status], [ArtifactID], [ReviewedByPersonID], [ReviewedAt], [SupervisorFeedback]
)
VALUES (
    @ReportOpsReviewID,
    @AlexPersonID,
    '2026-11-02',
    '2026-11-06',
    N'ACV Operations Readiness Work Report — Q4 Summary (Category A)',
    N'### Operations Summary' + CHAR(10) + N'- Confirmed SQL Server and PostgreSQL integration pipelines pass cleanly.',
    N'Reviewed',
    NULL,
    @SarahPersonID,
    SYSDATETIMEOFFSET(),
    N'Approved for release readiness archive.'
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[WorkReportItem] WHERE [ID] = @ReportItem1ID)
INSERT INTO [__mj_BizAppsTasks].[WorkReportItem] ([ID], [WorkReportID], [TaskID], [Section], [Summary], [Sequence])
VALUES (
    @ReportItem1ID,
    @ReportLinkedID,
    @TaskDeliverableID,
    N'Completed',
    N'Delivered batched ArtifactDualReadResolver with SQL IN chunking.',
    1
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[WorkReportItem] WHERE [ID] = @ReportItem2ID)
INSERT INTO [__mj_BizAppsTasks].[WorkReportItem] ([ID], [WorkReportID], [TaskID], [Section], [Summary], [Sequence])
VALUES (
    @ReportItem2ID,
    @ReportLinkedID,
    @TaskBlockedID,
    N'Blockers',
    N'External SOC2 penetration test attestation still pending.',
    2
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[WorkReportItem] WHERE [ID] = @ReportItem3ID)
INSERT INTO [__mj_BizAppsTasks].[WorkReportItem] ([ID], [WorkReportID], [TaskID], [Section], [Summary], [Sequence])
VALUES (
    @ReportItem3ID,
    @ReportLegacyID,
    @TaskFollowUpID,
    N'Next',
    N'Publish MJ Docs vs MJ Comments rubric across developer guides.',
    1
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[WorkReportItem] WHERE [ID] = @ReportItem4ID)
INSERT INTO [__mj_BizAppsTasks].[WorkReportItem] ([ID], [WorkReportID], [TaskID], [Section], [Summary], [Sequence])
VALUES (
    @ReportItem4ID,
    @ReportZeroVerID,
    @TaskRootID,
    N'InProgress',
    N'Validate graceful fallback to Body when Artifact has zero readable versions.',
    1
);

-- ---------------------------------------------------------------------------
-- 5. Category B: [__mj_BizAppsTasks].[Meeting] (2 rows),
--    [__mj_BizAppsTasks].[MeetingAttendee] (3 rows),
--    [__mj_BizAppsTasks].[MeetingAgendaItem] (2 rows),
--    [__mj_BizAppsTasks].[MeetingNote] (3 rows)
-- ---------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[Meeting] WHERE [ID] = @MeetingArchID)
INSERT INTO [__mj_BizAppsTasks].[Meeting] (
    [ID], [Name], [Description], [Status], [StartsAt], [EndsAt], [TimeZone],
    [LocationType], [OrganizerPersonID], [Visibility], [CreatedByPersonID]
)
VALUES (
    @MeetingArchID,
    N'ACV Architecture & Minutes Review',
    N'Cross-stack review of WorkReport & MeetingNote ArtifactID convergence.',
    N'Scheduled',
    '2026-11-26T14:00:00-06:00',
    '2026-11-26T15:00:00-06:00',
    N'America/Chicago',
    N'Virtual',
    @AlexPersonID,
    N'Standard',
    @AlexPersonID
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[Meeting] WHERE [ID] = @MeetingComplianceID)
INSERT INTO [__mj_BizAppsTasks].[Meeting] (
    [ID], [Name], [Description], [Status], [StartsAt], [EndsAt], [TimeZone],
    [LocationType], [OrganizerPersonID], [Visibility], [CreatedByPersonID]
)
VALUES (
    @MeetingComplianceID,
    N'ACV Compliance & Dual-DBMS Sign-Off Review',
    N'Review RLS authorization boundaries and PostgreSQL parity checks for convergence release.',
    N'Completed',
    '2026-11-24T10:00:00-06:00',
    '2026-11-24T11:00:00-06:00',
    N'America/Chicago',
    N'Hybrid',
    @SarahPersonID,
    N'Standard',
    @SarahPersonID
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[MeetingAttendee] WHERE [ID] = @AttendeeAlexID)
INSERT INTO [__mj_BizAppsTasks].[MeetingAttendee] (
    [ID], [MeetingID], [PersonID], [Email], [DisplayName],
    [Role], [ResponseStatus], [AttendanceStatus]
)
VALUES (
    @AttendeeAlexID,
    @MeetingArchID,
    @AlexPersonID,
    N'alex.chen@task-world.test',
    N'Alex Chen',
    N'Organizer',
    N'Accepted',
    N'Present'
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[MeetingAttendee] WHERE [ID] = @AttendeeSarahID)
INSERT INTO [__mj_BizAppsTasks].[MeetingAttendee] (
    [ID], [MeetingID], [PersonID], [Email], [DisplayName],
    [Role], [ResponseStatus], [AttendanceStatus]
)
VALUES (
    @AttendeeSarahID,
    @MeetingArchID,
    @SarahPersonID,
    N'sarah.connor@task-world.test',
    N'Sarah Connor',
    N'Required',
    N'Accepted',
    N'Present'
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[MeetingAttendee] WHERE [ID] = @AttendeeElenaID)
INSERT INTO [__mj_BizAppsTasks].[MeetingAttendee] (
    [ID], [MeetingID], [PersonID], [Email], [DisplayName],
    [Role], [ResponseStatus], [AttendanceStatus]
)
VALUES (
    @AttendeeElenaID,
    @MeetingComplianceID,
    @ElenaPersonID,
    N'elena.rostova@task-world.test',
    N'Elena Rostova',
    N'Optional',
    N'Accepted',
    N'Present'
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[MeetingAgendaItem] WHERE [ID] = @AgendaItem1ID)
INSERT INTO [__mj_BizAppsTasks].[MeetingAgendaItem] (
    [ID], [MeetingID], [Sequence], [Name], [Description], [PresenterPersonID], [DurationMinutes], [Status]
)
VALUES (
    @AgendaItem1ID,
    @MeetingArchID,
    10,
    N'Category A/B MJ Docs Review',
    N'Review WorkReport and MeetingNote ArtifactID schema and UI panel behavior.',
    @AlexPersonID,
    25,
    N'Done'
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[MeetingAgendaItem] WHERE [ID] = @AgendaItem2ID)
INSERT INTO [__mj_BizAppsTasks].[MeetingAgendaItem] (
    [ID], [MeetingID], [Sequence], [Name], [Description], [PresenterPersonID], [DurationMinutes], [Status]
)
VALUES (
    @AgendaItem2ID,
    @MeetingComplianceID,
    20,
    N'Category C Relational Boundary Verification',
    N'Confirm TaskComment, TaskCheckIn, BlockedReason, and TaskTimeEntry remain relational without ArtifactID.',
    @SarahPersonID,
    15,
    N'InProgress'
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[MeetingNote] WHERE [ID] = @NoteScratchpadID)
INSERT INTO [__mj_BizAppsTasks].[MeetingNote] (
    [ID], [MeetingID], [AgendaItemID], [Kind], [Title], [Body],
    [Source], [Status], [AuthorPersonID], [ProposedTasks], [ArtifactID]
)
VALUES (
    @NoteScratchpadID,
    @MeetingArchID,
    @AgendaItem1ID,
    N'Notes',
    N'ACV Live Scratchpad — Unlinked Notes & Proposed Tasks',
    N'## Live Architecture Scratchpad' + CHAR(10) + N'- Reviewed Category A/B/C boundaries for BizApps Tasks.' + CHAR(10) + N'- Confirmed TaskComment, TaskCheckIn, BlockedReason, and TaskTimeEntry stay relational.',
    N'Manual',
    N'Draft',
    @SarahPersonID,
    N'[{"id":"acv-prop-1","title":"Verify PostgreSQL split-bake provenance header in CI","priority":"High","status":"Pending","taskId":null},{"id":"acv-prop-2","title":"Document MJ Docs vs MJ Comments rubric in CLAUDE.md and AGENTS.md","priority":"Medium","status":"Pending","taskId":null}]',
    NULL
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[MeetingNote] WHERE [ID] = @NotePublishedID)
INSERT INTO [__mj_BizAppsTasks].[MeetingNote] (
    [ID], [MeetingID], [AgendaItemID], [Kind], [Title], [Body],
    [Source], [Status], [AuthorPersonID], [ProposedTasks], [ArtifactID]
)
VALUES (
    @NotePublishedID,
    @MeetingArchID,
    @AgendaItem1ID,
    N'Summary',
    N'ACV Published Minutes — Linked MJ Doc',
    N'## Published Architecture Minutes' + CHAR(10) + N'- Approved dual-read batching via ArtifactDualReadResolver.' + CHAR(10) + N'- Approved idempotent Publish Meeting Note as MJ Doc action.',
    N'Manual',
    N'Final',
    @AlexPersonID,
    N'[{"id":"acv-pub-prop-1","title":"Roll out WorkReportArtifactPanel and MeetingNoteArtifactPanel","priority":"High","status":"Accepted","taskId":null}]',
    @ArtPublishedNoteID
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[MeetingNote] WHERE [ID] = @NoteDecisionID)
INSERT INTO [__mj_BizAppsTasks].[MeetingNote] (
    [ID], [MeetingID], [AgendaItemID], [Kind], [Title], [Body],
    [Source], [Status], [AuthorPersonID], [ProposedTasks], [ArtifactID]
)
VALUES (
    @NoteDecisionID,
    @MeetingComplianceID,
    @AgendaItem2ID,
    N'Decision',
    N'ACV Governance Decision Record — Category C Boundary',
    N'## Decision' + CHAR(10) + N'- Keep TaskComment, TaskCheckIn, BlockedReason, Timesheet, and TaskTimeEntry strictly relational with zero ArtifactID columns.',
    N'Manual',
    N'Final',
    @SarahPersonID,
    NULL,
    NULL
);

-- ---------------------------------------------------------------------------
-- 6. Category C Lightweight Relational Notes:
--    [__mj_BizAppsTasks].[TaskComment] (3 rows) &
--    [__mj_BizAppsTasks].[TaskCheckIn] (2 rows)
-- ---------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[TaskComment] WHERE [ID] = @CommentParentID)
INSERT INTO [__mj_BizAppsTasks].[TaskComment] (
    [ID], [TaskID], [ParentID], [PersonID], [Content], [IsEdited]
)
VALUES (
    @CommentParentID,
    @TaskDeliverableID,
    NULL,
    @SarahPersonID,
    N'ACV Category C Comment: Confirmed lightweight relational TaskComment needs no ArtifactID.',
    0
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[TaskComment] WHERE [ID] = @CommentReplyID)
INSERT INTO [__mj_BizAppsTasks].[TaskComment] (
    [ID], [TaskID], [ParentID], [PersonID], [Content], [IsEdited]
)
VALUES (
    @CommentReplyID,
    @TaskDeliverableID,
    @CommentParentID,
    @AlexPersonID,
    N'ACV Category C Reply: Verified threaded reply stays fast and relational.',
    0
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[TaskComment] WHERE [ID] = @CommentBlockedID)
INSERT INTO [__mj_BizAppsTasks].[TaskComment] (
    [ID], [TaskID], [ParentID], [PersonID], [Content], [IsEdited]
)
VALUES (
    @CommentBlockedID,
    @TaskBlockedID,
    NULL,
    @ElenaPersonID,
    N'ACV Category C Compliance Note: Penetration test attestation scheduled for next review window.',
    0
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[TaskCheckIn] WHERE [ID] = @CheckInOnTrackID)
INSERT INTO [__mj_BizAppsTasks].[TaskCheckIn] (
    [ID], [TaskID], [AuthorPersonID], [AuthorUserID], [CheckInAt],
    [HealthStatus], [ConfidenceScore], [PercentComplete], [Summary], [Blockers], [NextSteps]
)
VALUES (
    @CheckInOnTrackID,
    @TaskDeliverableID,
    @SarahPersonID,
    @SarahUserID,
    '2026-11-24T15:00:00Z',
    N'OnTrack',
    85,
    80,
    N'ACV Category C CheckIn: Dual-read batch resolver green across SQL Server and PostgreSQL.',
    NULL,
    N'Complete dual-DBMS integration verification and publish living documentation.'
);

IF NOT EXISTS (SELECT 1 FROM [__mj_BizAppsTasks].[TaskCheckIn] WHERE [ID] = @CheckInAtRiskID)
INSERT INTO [__mj_BizAppsTasks].[TaskCheckIn] (
    [ID], [TaskID], [AuthorPersonID], [AuthorUserID], [CheckInAt],
    [HealthStatus], [ConfidenceScore], [PercentComplete], [Summary], [Blockers], [NextSteps]
)
VALUES (
    @CheckInAtRiskID,
    @TaskBlockedID,
    @SarahPersonID,
    @SarahUserID,
    '2026-11-25T16:30:00Z',
    N'AtRisk',
    40,
    20,
    N'ACV Category C CheckIn: Waiting on external security attestation sign-off.',
    N'Awaiting third-party SOC2 penetration test attestation before production cutover.',
    N'Follow up with security assessor and confirm release window.'
);
GO
