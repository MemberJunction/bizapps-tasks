-- =============================================================================
-- BizAppsTasks: TaskType.ExtensionEntity + WorkReport & WorkReportItem Tables
-- 1. Adds ExtensionEntity to TaskType so extension Open Apps (e.g. GitHub,
--    Align, Jira) register disjoint IS-A Task child entities resolved
--    declaratively by Task's SubtypeSelector (TypeID.ExtensionEntity).
-- 2. Adds WorkReport and WorkReportItem tables for daily 15Five work reports
--    drafted by each person's Chief of Staff and reviewed by their supervisor's
--    Chief of Staff.
-- =============================================================================

---------------------------------------------------------------------------
-- 1. TaskType: Add ExtensionEntity Column
---------------------------------------------------------------------------
ALTER TABLE [${flyway:defaultSchema}].[TaskType]
    ADD [ExtensionEntity] NVARCHAR(255) NULL;
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional MemberJunction Entity name (e.g. MJ_BizApps_Tasks_GitHub: GitHub Issue Tasks) of the disjoint IS-A child of MJ_BizApps_Tasks: Tasks provisioned for tasks of this type. Read declaratively by Task SubtypeSelector (TypeID.ExtensionEntity).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskType',
    @level2type = N'COLUMN', @level2name = N'ExtensionEntity';
GO

---------------------------------------------------------------------------
-- 2. WorkReport: Daily / periodic 15Five reports drafted & reviewed via CoS
---------------------------------------------------------------------------
CREATE TABLE [${flyway:defaultSchema}].[WorkReport] (
    [ID] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_WorkReport_ID] DEFAULT (NEWSEQUENTIALID()),
    [PersonID] UNIQUEIDENTIFIER NOT NULL,
    [PeriodStart] DATE NOT NULL,
    [PeriodEnd] DATE NOT NULL,
    [Title] NVARCHAR(255) NULL,
    [Body] NVARCHAR(MAX) NOT NULL,
    [Status] NVARCHAR(20) NOT NULL CONSTRAINT [DF_WorkReport_Status] DEFAULT ('Draft'),
    [AuthoredByAgentRunID] UNIQUEIDENTIFIER NULL,
    [SupervisorFeedback] NVARCHAR(MAX) NULL,
    [ReviewedByPersonID] UNIQUEIDENTIFIER NULL,
    [ReviewedAt] DATETIMEOFFSET NULL,
    CONSTRAINT [PK_WorkReport] PRIMARY KEY ([ID]),
    CONSTRAINT [FK_WorkReport_Person] FOREIGN KEY ([PersonID]) REFERENCES [__mj_BizAppsCommon].[Person]([ID]),
    CONSTRAINT [FK_WorkReport_AuthoredByAgentRun] FOREIGN KEY ([AuthoredByAgentRunID]) REFERENCES [${mjSchema}].[AIAgentRun]([ID]),
    CONSTRAINT [FK_WorkReport_ReviewedByPerson] FOREIGN KEY ([ReviewedByPersonID]) REFERENCES [__mj_BizAppsCommon].[Person]([ID]),
    CONSTRAINT [UQ_WorkReport_Person_Period] UNIQUE ([PersonID], [PeriodStart], [PeriodEnd]),
    CONSTRAINT [CK_WorkReport_Status] CHECK ([Status] IN ('Draft', 'Submitted', 'Reviewed')),
    CONSTRAINT [CK_WorkReport_PeriodOrder] CHECK ([PeriodEnd] >= [PeriodStart])
);
GO

CREATE INDEX [IX_WorkReport_Person_PeriodEnd]
    ON [${flyway:defaultSchema}].[WorkReport] ([PersonID], [PeriodEnd] DESC);
GO

CREATE INDEX [IX_WorkReport_ReviewedByPerson_Status]
    ON [${flyway:defaultSchema}].[WorkReport] ([ReviewedByPersonID], [Status]);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Daily or periodic 15Five work reports summarizing what got done, what is next, blockers, and at-risk objectives for a person, drafted by their Chief of Staff and reviewed with supervisor feedback.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReport';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The Person record whose work is summarized in this report.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReport',
    @level2type = N'COLUMN', @level2name = N'PersonID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Inclusive start date of the reporting window.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReport',
    @level2type = N'COLUMN', @level2name = N'PeriodStart';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Inclusive end date of the reporting window.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReport',
    @level2type = N'COLUMN', @level2name = N'PeriodEnd';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional concise headline for the report (e.g., Daily 15Five — 2026-11-09).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReport',
    @level2type = N'COLUMN', @level2name = N'Title';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Markdown body of the work report covering accomplishments, next priorities, blockers, and at-risk objectives.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReport',
    @level2type = N'COLUMN', @level2name = N'Body';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Lifecycle status of the report: Draft (awaiting author approval), Submitted (approved by author, awaiting supervisor review), or Reviewed (supervisor feedback recorded).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReport',
    @level2type = N'COLUMN', @level2name = N'Status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional AI Agent Run that drafted this work report.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReport',
    @level2type = N'COLUMN', @level2name = N'AuthoredByAgentRunID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Feedback drafted by the supervisor Chief of Staff and approved/edited by the supervisor.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReport',
    @level2type = N'COLUMN', @level2name = N'SupervisorFeedback';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The supervisor Person record who reviewed and approved feedback on this report.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReport',
    @level2type = N'COLUMN', @level2name = N'ReviewedByPersonID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when supervisor feedback was approved and recorded on this report.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReport',
    @level2type = N'COLUMN', @level2name = N'ReviewedAt';
GO

---------------------------------------------------------------------------
-- 3. WorkReportItem: Line items linking each report entry to its Task
---------------------------------------------------------------------------
CREATE TABLE [${flyway:defaultSchema}].[WorkReportItem] (
    [ID] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_WorkReportItem_ID] DEFAULT (NEWSEQUENTIALID()),
    [WorkReportID] UNIQUEIDENTIFIER NOT NULL,
    [TaskID] UNIQUEIDENTIFIER NULL,
    [Section] NVARCHAR(50) NOT NULL CONSTRAINT [DF_WorkReportItem_Section] DEFAULT ('Completed'),
    [Summary] NVARCHAR(MAX) NOT NULL,
    [Sequence] INT NOT NULL CONSTRAINT [DF_WorkReportItem_Sequence] DEFAULT (0),
    CONSTRAINT [PK_WorkReportItem] PRIMARY KEY ([ID]),
    CONSTRAINT [FK_WorkReportItem_WorkReport] FOREIGN KEY ([WorkReportID]) REFERENCES [${flyway:defaultSchema}].[WorkReport]([ID]),
    CONSTRAINT [FK_WorkReportItem_Task] FOREIGN KEY ([TaskID]) REFERENCES [${flyway:defaultSchema}].[Task]([ID]),
    CONSTRAINT [CK_WorkReportItem_Section] CHECK ([Section] IN ('Completed', 'InProgress', 'Next', 'Blockers', 'AtRisk'))
);
GO

CREATE INDEX [IX_WorkReportItem_WorkReport_Sequence]
    ON [${flyway:defaultSchema}].[WorkReportItem] ([WorkReportID], [Sequence]);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Individual line items in a WorkReport linking each accomplishment, next step, blocker, or at-risk item to its originating Task.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReportItem';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Parent WorkReport that owns this line item.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReportItem',
    @level2type = N'COLUMN', @level2name = N'WorkReportID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional Task referenced by this report item.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReportItem',
    @level2type = N'COLUMN', @level2name = N'TaskID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Report section this line belongs to: Completed, InProgress, Next, Blockers, or AtRisk.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReportItem',
    @level2type = N'COLUMN', @level2name = N'Section';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Concise description of the progress, next step, blocker, or risk for this line item.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReportItem',
    @level2type = N'COLUMN', @level2name = N'Summary';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Display order within the parent WorkReport (ascending).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'WorkReportItem',
    @level2type = N'COLUMN', @level2name = N'Sequence';
GO
























































-- =============================================================================
-- GENERATED BY MemberJunction CodeGen — DO NOT EDIT BY HAND
-- =============================================================================

/* SQL generated to create new entity MJ_BizApps_Tasks: Work Reports */

      INSERT INTO [${mjSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching],
         [TrackRecordChanges],
         [AuditRecordAccess],
         [AuditViewRuns],
         [AllowAllRowsAPI],
         [AllowCreateAPI],
         [AllowUpdateAPI],
         [AllowDeleteAPI],
         [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         'a9038030-2dbd-48e1-9075-03ed5373b85a',
         'MJ_BizApps_Tasks: Work Reports',
         'Work Reports',
         'Daily or periodic 15Five work reports summarizing what got done, what is next, blockers, and at-risk objectives for a person, drafted by their Chief of Staff and reviewed with supervisor feedback.',
         NULL,
         'WorkReport',
         'vwWorkReports',
         '${flyway:defaultSchema}',
         1,
         1,
         0,
         1,
         0,
         0,
         0,
         1,
         1,
         1,
         1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add entity MJ_BizApps_Tasks: Work Reports to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                    ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'a9038030-2dbd-48e1-9075-03ed5373b85a', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Work Reports for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('a9038030-2dbd-48e1-9075-03ed5373b85a' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('a9038030-2dbd-48e1-9075-03ed5373b85a' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Work Reports for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('a9038030-2dbd-48e1-9075-03ed5373b85a' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('a9038030-2dbd-48e1-9075-03ed5373b85a' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Work Reports for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('a9038030-2dbd-48e1-9075-03ed5373b85a' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('a9038030-2dbd-48e1-9075-03ed5373b85a' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Work Report Items */

      INSERT INTO [${mjSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching],
         [TrackRecordChanges],
         [AuditRecordAccess],
         [AuditViewRuns],
         [AllowAllRowsAPI],
         [AllowCreateAPI],
         [AllowUpdateAPI],
         [AllowDeleteAPI],
         [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         'd9e9ee62-78ce-4e89-8ed0-35378358e321',
         'MJ_BizApps_Tasks: Work Report Items',
         'Work Report Items',
         'Individual line items in a WorkReport linking each accomplishment, next step, blocker, or at-risk item to its originating Task.',
         NULL,
         'WorkReportItem',
         'vwWorkReportItems',
         '${flyway:defaultSchema}',
         1,
         1,
         0,
         1,
         0,
         0,
         0,
         1,
         1,
         1,
         1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add entity MJ_BizApps_Tasks: Work Report Items to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                    ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'd9e9ee62-78ce-4e89-8ed0-35378358e321', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Work Report Items for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('d9e9ee62-78ce-4e89-8ed0-35378358e321' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('d9e9ee62-78ce-4e89-8ed0-35378358e321' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Work Report Items for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('d9e9ee62-78ce-4e89-8ed0-35378358e321' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('d9e9ee62-78ce-4e89-8ed0-35378358e321' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Work Report Items for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('d9e9ee62-78ce-4e89-8ed0-35378358e321' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('d9e9ee62-78ce-4e89-8ed0-35378358e321' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL text to update existing entities from schema */
EXEC [${mjSchema}].[spUpdateExistingEntitiesFromSchema] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.WorkReport */
ALTER TABLE [${flyway:defaultSchema}].[WorkReport] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.WorkReport */
UPDATE [${flyway:defaultSchema}].[WorkReport] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.WorkReport */
ALTER TABLE [${flyway:defaultSchema}].[WorkReport] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.WorkReport */
ALTER TABLE [${flyway:defaultSchema}].[WorkReport] ADD CONSTRAINT [DF___mj_BizAppsTasks_WorkReport___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.WorkReport */
ALTER TABLE [${flyway:defaultSchema}].[WorkReport] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.WorkReport */
UPDATE [${flyway:defaultSchema}].[WorkReport] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.WorkReport */
ALTER TABLE [${flyway:defaultSchema}].[WorkReport] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.WorkReport */
ALTER TABLE [${flyway:defaultSchema}].[WorkReport] ADD CONSTRAINT [DF___mj_BizAppsTasks_WorkReport___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.WorkReportItem */
ALTER TABLE [${flyway:defaultSchema}].[WorkReportItem] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.WorkReportItem */
UPDATE [${flyway:defaultSchema}].[WorkReportItem] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.WorkReportItem */
ALTER TABLE [${flyway:defaultSchema}].[WorkReportItem] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.WorkReportItem */
ALTER TABLE [${flyway:defaultSchema}].[WorkReportItem] ADD CONSTRAINT [DF___mj_BizAppsTasks_WorkReportItem___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.WorkReportItem */
ALTER TABLE [${flyway:defaultSchema}].[WorkReportItem] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.WorkReportItem */
UPDATE [${flyway:defaultSchema}].[WorkReportItem] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.WorkReportItem */
ALTER TABLE [${flyway:defaultSchema}].[WorkReportItem] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.WorkReportItem */
ALTER TABLE [${flyway:defaultSchema}].[WorkReportItem] ADD CONSTRAINT [DF___mj_BizAppsTasks_WorkReportItem___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to insert 22 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd6b740e7-dfa0-4fd7-9c9c-96bdf9182b0a' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd6b740e7-dfa0-4fd7-9c9c-96bdf9182b0a',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            'ID',
            'ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'eb682468-bfe5-402f-9560-f97a34282275' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = 'PersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'eb682468-bfe5-402f-9560-f97a34282275',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            'PersonID',
            'Person ID',
            'The Person record whose work is summarized in this report.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'bbb95bb8-04ad-4f28-9408-3c8e9773305d' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = 'PeriodStart')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'bbb95bb8-04ad-4f28-9408-3c8e9773305d',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            'PeriodStart',
            'Period Start',
            'Inclusive start date of the reporting window.',
            'date',
            3,
            10,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f8887bd2-78f6-429a-b7bd-f814d4f7a37c' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = 'PeriodEnd')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f8887bd2-78f6-429a-b7bd-f814d4f7a37c',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            'PeriodEnd',
            'Period End',
            'Inclusive end date of the reporting window.',
            'date',
            3,
            10,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9d56d5c4-7a96-4465-ba13-01b78557dbd2' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = 'Title')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9d56d5c4-7a96-4465-ba13-01b78557dbd2',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            'Title',
            'Title',
            'Optional concise headline for the report (e.g., Daily 15Five — 2026-11-09).',
            'nvarchar',
            510,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f9618412-4e0b-4940-9207-a8134099948e' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = 'Body')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f9618412-4e0b-4940-9207-a8134099948e',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            'Body',
            'Body',
            'Markdown body of the work report covering accomplishments, next priorities, blockers, and at-risk objectives.',
            'nvarchar',
            -1,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5c7fc965-777e-4b95-8c42-d7372122849b' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = 'Status')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5c7fc965-777e-4b95-8c42-d7372122849b',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            'Status',
            'Status',
            'Lifecycle status of the report: Draft (awaiting author approval), Submitted (approved by author, awaiting supervisor review), or Reviewed (supervisor feedback recorded).',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Draft',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0e7a4d77-5ad4-408a-8331-ee2d6cf84149' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = 'AuthoredByAgentRunID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0e7a4d77-5ad4-408a-8331-ee2d6cf84149',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            'AuthoredByAgentRunID',
            'Authored By Agent Run ID',
            'Optional AI Agent Run that drafted this work report.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            '5190AF93-4C39-4429-BDAA-0AEB492A0256',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9705c6bf-1b9b-4849-8c18-02c29e208015' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = 'SupervisorFeedback')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9705c6bf-1b9b-4849-8c18-02c29e208015',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            'SupervisorFeedback',
            'Supervisor Feedback',
            'Feedback drafted by the supervisor Chief of Staff and approved/edited by the supervisor.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '884afceb-89e4-4deb-91cf-7334ab075cb2' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = 'ReviewedByPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '884afceb-89e4-4deb-91cf-7334ab075cb2',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            'ReviewedByPersonID',
            'Reviewed By Person ID',
            'The supervisor Person record who reviewed and approved feedback on this report.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0a8e806d-3a65-4b1a-9b67-340298e7015c' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = 'ReviewedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0a8e806d-3a65-4b1a-9b67-340298e7015c',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            'ReviewedAt',
            'Reviewed At',
            'Timestamp when supervisor feedback was approved and recorded on this report.',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b09e0770-76d8-4f44-8da7-884217ed2b6e' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b09e0770-76d8-4f44-8da7-884217ed2b6e',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3d99c7ca-bc59-4c0c-acf8-b3d9051fb2b1' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3d99c7ca-bc59-4c0c-acf8-b3d9051fb2b1',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '273826b0-2b87-4a25-a69c-4fb46312b01f' OR (EntityID = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '273826b0-2b87-4a25-a69c-4fb46312b01f',
            'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- Entity: MJ_BizApps_Tasks: Work Report Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
            'ID',
            'ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '74c73051-9dc1-42d9-add4-95469fe48087' OR (EntityID = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND Name = 'WorkReportID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '74c73051-9dc1-42d9-add4-95469fe48087',
            'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- Entity: MJ_BizApps_Tasks: Work Report Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
            'WorkReportID',
            'Work Report ID',
            'Parent WorkReport that owns this line item.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            'A9038030-2DBD-48E1-9075-03ED5373B85A',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd7c0eea5-0ab9-429c-a21e-b3b9d8e7161e' OR (EntityID = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND Name = 'TaskID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd7c0eea5-0ab9-429c-a21e-b3b9d8e7161e',
            'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- Entity: MJ_BizApps_Tasks: Work Report Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
            'TaskID',
            'Task ID',
            'Optional Task referenced by this report item.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'eaf8cc4f-cd1e-4d53-95db-325d1584929f' OR (EntityID = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND Name = 'Section')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'eaf8cc4f-cd1e-4d53-95db-325d1584929f',
            'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- Entity: MJ_BizApps_Tasks: Work Report Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
            'Section',
            'Section',
            'Report section this line belongs to: Completed, InProgress, Next, Blockers, or AtRisk.',
            'nvarchar',
            100,
            0,
            0,
            0,
            'Completed',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '11458626-d4d5-4304-b8fe-ccf68542869a' OR (EntityID = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND Name = 'Summary')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '11458626-d4d5-4304-b8fe-ccf68542869a',
            'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- Entity: MJ_BizApps_Tasks: Work Report Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
            'Summary',
            'Summary',
            'Concise description of the progress, next step, blocker, or risk for this line item.',
            'nvarchar',
            -1,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '60ce469e-cc17-49b0-9c68-4c53887f0b86' OR (EntityID = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND Name = 'Sequence')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '60ce469e-cc17-49b0-9c68-4c53887f0b86',
            'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- Entity: MJ_BizApps_Tasks: Work Report Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
            'Sequence',
            'Sequence',
            'Display order within the parent WorkReport (ascending).',
            'int',
            4,
            10,
            0,
            0,
            '(0)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fcb6c423-fbec-48a8-bc9b-8dc6a1ea28f9' OR (EntityID = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'fcb6c423-fbec-48a8-bc9b-8dc6a1ea28f9',
            'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- Entity: MJ_BizApps_Tasks: Work Report Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b02253a9-a98b-4223-9e00-b0da95ec4eeb' OR (EntityID = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b02253a9-a98b-4223-9e00-b0da95ec4eeb',
            'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- Entity: MJ_BizApps_Tasks: Work Report Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5684d61d-47a2-410e-bcc3-4373142de0f3' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'ExtensionEntity')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5684d61d-47a2-410e-bcc3-4373142de0f3',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '1E30141A-826F-4278-BAA9-BBE14D29E606'),
            'ExtensionEntity',
            'Extension Entity',
            'Optional MemberJunction Entity name (e.g. MJ_BizApps_Tasks_GitHub: GitHub Issue Tasks) of the disjoint IS-A child of MJ_BizApps_Tasks: Tasks provisioned for tasks of this type. Read declaratively by Task SubtypeSelector (TypeID.ExtensionEntity).',
            'nvarchar',
            510,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

/* SQL text to update existing entity fields from schema */
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='635846E8-E8F9-4BE2-9E6B-AD783BAE05CF';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='C95BF1FD-38AA-476A-86C4-CCE1DAA7AB65';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='B6C11250-D2DB-4B0F-9594-BCD9271DBB8B';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='3A40307F-EF27-4079-8FB3-D9C0403A1199';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='9E75F106-9F72-4F58-9181-4A08E8BB577C';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='26D52813-85CA-44A2-A09C-BA320EE6AA40';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='BC167D9F-E496-4FC3-BFDE-13A7CFB9DA2A';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='653E807F-F0DD-40EE-8E35-DD04B64231DC';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='DD2E1A2D-4EEB-4ECC-AA52-A6A79D339C88';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='A325C453-D9B9-4B5F-9DBE-549E27243C40';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='0E2761D2-AD6B-4E31-B4E8-885BF5B34B68';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='DFC7A14D-DA67-403E-A80D-C84390EA33BC';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='CEDC7F50-5CB2-4311-B0D4-737303E70A60';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='8AEEE5EF-4A5E-418A-BE44-325D7A5A68D9';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='A8D56409-368D-46E1-A251-91DFCC3DF4C8';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='D067FAB6-3C26-4846-966A-44C2F03EAF6E';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='641DC25E-83F6-410D-84D4-2BD3190094FF';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='5544F182-AA03-4855-8232-A8D3C4CCECA4';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='047AA982-23F2-4BD6-B2AB-6C4E6B314E00';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='FB2E3A35-BCA9-40E9-8001-860BE1445992';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='5D642C95-B90D-497E-BC37-A1924FFD9F28';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='B063068F-8B10-4A2D-B9E6-0D24C52EE804';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='0122031C-E04A-4782-9F96-11E014325A3A';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='7369BFD9-A4A7-4B57-A06B-14F2F58ECE68';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='2D1DA61D-CAAE-490A-B3C5-9B9EEEA3E98B';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='0E381E48-B41D-49DC-8C77-2A3E2412F240';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='A35BD3A6-B328-4B8B-87A4-1D7B2F68588D';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='78BD5BE3-62E9-4254-8119-D5BDF1025CF3';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='F3B28978-4D13-43B7-92CF-9C50CDB97C82';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='71809B6D-BFFF-494A-A139-BF7569CFFBE6';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='F3E5AD4A-7F3A-40BC-86E8-EB996023D911';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='EF71A1BC-8503-4807-85C6-4236A4DD4935';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='E73100EA-6879-482C-9C65-8E395393E188';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='98AA8D90-4FA6-4C4D-9B8E-89D51989AB37';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='A48F70E4-69BA-4206-B424-9DEE180A251E';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='E092392B-F130-4856-ABE2-3D060E590282';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='0E6A25C1-3213-4DAE-9686-F8D688AF2102';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='50D54B01-1DF3-4D74-BD73-438708EF0548';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='7826FB29-771D-46B1-96B3-05499A302D17';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='CA573315-A0A0-471E-92DF-D504D37DC9EB';

/* SQL text to insert entity field value with ID d4fe7213-fdfd-47b3-867f-9b5e8a564d49 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [Source], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d4fe7213-fdfd-47b3-867f-9b5e8a564d49', '5C7FC965-777E-4B95-8C42-D7372122849B', 1, 'Draft', 'Draft', 'Check', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 2cf8b583-d07b-454a-ba2c-ba60b8758851 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [Source], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('2cf8b583-d07b-454a-ba2c-ba60b8758851', '5C7FC965-777E-4B95-8C42-D7372122849B', 2, 'Reviewed', 'Reviewed', 'Check', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 1f579f9f-99d0-4cda-b4a1-cba567399c6b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [Source], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1f579f9f-99d0-4cda-b4a1-cba567399c6b', '5C7FC965-777E-4B95-8C42-D7372122849B', 3, 'Submitted', 'Submitted', 'Check', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 5C7FC965-777E-4B95-8C42-D7372122849B */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='5C7FC965-777E-4B95-8C42-D7372122849B';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='0509C923-75C4-422C-A0B0-A45C5977D773';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='3634DD1F-E2B1-4D25-AA82-5EDDF33FB266';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='F0595906-74AA-4EFD-83E9-C7297878277B';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='71DA79A8-C0ED-4FC5-B9B1-1166A4A038C9';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='7EC8681C-C3C2-468D-925E-27293A06A4BD';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='B4FBA07D-5070-427E-A751-236B0A8FFE51';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='2AFC33BF-FB39-445D-8610-0867D4997923';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='7A9742F5-DE77-4A89-9A95-413B357FC6E4';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='8491ECCC-82E1-4449-A675-BC8036D461D1';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='8AE2A9C0-E952-4271-A1C2-3853347BF37B';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='3B04B519-5C74-45B1-BA4B-94372125B7E5';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='F0EC7C9E-9646-491F-929E-165449D8929E';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='F86D7D4F-2042-4A2B-A984-6C6C073D1CB1';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='40B53F38-2CE5-41B1-8116-D2340BF0B78B';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='DD9E09D4-FF5D-44DC-8AC4-7554FEEE32FB';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='20257078-873D-4C95-9DD9-078E4E856FCB';

/* SQL text to insert entity field value with ID 7d6b0ea8-61bc-449d-9d66-933ec097f08f */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [Source], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7d6b0ea8-61bc-449d-9d66-933ec097f08f', 'EAF8CC4F-CD1E-4D53-95DB-325D1584929F', 1, 'AtRisk', 'AtRisk', 'Check', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c33b4665-bfde-42f2-b45d-863ec4a03057 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [Source], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c33b4665-bfde-42f2-b45d-863ec4a03057', 'EAF8CC4F-CD1E-4D53-95DB-325D1584929F', 2, 'Blockers', 'Blockers', 'Check', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 8abe5288-4591-4bb3-94c2-aefe5ef9f2de */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [Source], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('8abe5288-4591-4bb3-94c2-aefe5ef9f2de', 'EAF8CC4F-CD1E-4D53-95DB-325D1584929F', 3, 'Completed', 'Completed', 'Check', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 76211948-6f13-414f-a2fa-7b7563bd292e */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [Source], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('76211948-6f13-414f-a2fa-7b7563bd292e', 'EAF8CC4F-CD1E-4D53-95DB-325D1584929F', 4, 'InProgress', 'InProgress', 'Check', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 979b9c63-5900-472a-a015-7a7da1db7d74 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [Source], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('979b9c63-5900-472a-a015-7a7da1db7d74', 'EAF8CC4F-CD1E-4D53-95DB-325D1584929F', 5, 'Next', 'Next', 'Check', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID EAF8CC4F-CD1E-4D53-95DB-325D1584929F */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='EAF8CC4F-CD1E-4D53-95DB-325D1584929F';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='A94D176F-BD81-4959-8D4D-2EEDBF74DD0F';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='5E16D4B6-4F90-46BD-BDA7-0650BCADBFAC';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='33EB2FB9-CF45-4958-8C5A-7703E4C3D33B';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='C101D7BC-C32D-4521-9B6A-567E5ADD230B';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='14F84226-72F3-48D0-B3CA-F9DE97F016AF';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='D250809F-E070-4321-BBA9-4ADAD00F6766';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='19A8398A-E441-459E-9A81-F02E6EFF6778';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='83614E4E-617C-4AAC-8A72-48C8BCA3E243';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='5409B332-98F9-404E-98FE-A3351B7C168C';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='4D30381D-494D-4522-9888-C6AD0C7F6B55';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='05D117F8-7CB2-401E-80F3-28023880E81B';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='BA7566D8-67DB-49AA-BF82-D68E54551D29';

/* SQL text to update entity field value sequence and source */
UPDATE [${mjSchema}].[EntityFieldValue] SET [Source]='Check' WHERE ID='5DF92809-95D3-45A6-934E-730F6A38E5FF';

/* Deterministic search-flag hygiene — seed name fields */

         UPDATE [${mjSchema}].[EntityField]
         SET [IncludeInUserSearchAPI] = 1,
             [UserSearchPredicateAPI] = 'BeginsWith'
         WHERE [ID] IN (
            SELECT ranked.[ID] FROM (
               SELECT f.[ID],
                      ROW_NUMBER() OVER (
                         PARTITION BY f.[EntityID]
                         ORDER BY f.[Sequence], f.[Name]
                      ) AS rn
               FROM [${mjSchema}].[EntityField] f
               INNER JOIN [${mjSchema}].[Entity] e ON e.[ID] = f.[EntityID]
               WHERE LOWER(f.[Name]) IN ('name','title','firstname','lastname','middlename','displayname','fullname','label')
                 AND f.[AutoUpdateIncludeInUserSearchAPI] = 1
                 AND f.[IncludeInUserSearchAPI] = 0
                 AND ISNULL(f.[IsPrimaryKey], 0) = 0
                 AND ISNULL(f.[IsVirtual], 0) = 0
                 AND LOWER(f.[Type]) IN ('nvarchar','varchar','char','nchar')
                 AND ISNULL(f.[Length], 0) <> -1
                 AND e.[VirtualEntity] = 0
                 AND e.[AllowUserSearchAPI] = 1
                 AND ISNULL(e.[FullTextSearchEnabled], 0) = 0
                 AND NOT ((e.[Name] = 'Logs' OR e.[Name] LIKE '% Logs') OR (e.[Name] = 'Log' OR e.[Name] LIKE '% Log') OR (e.[Name] = 'Runs' OR e.[Name] LIKE '% Runs') OR (e.[Name] = 'Run' OR e.[Name] LIKE '% Run') OR (e.[Name] = 'Run History' OR e.[Name] LIKE '% Run History') OR (e.[Name] = 'Run Steps' OR e.[Name] LIKE '% Run Steps') OR (e.[Name] = 'Run Messages' OR e.[Name] LIKE '% Run Messages') OR (e.[Name] = 'Execution Logs' OR e.[Name] LIKE '% Execution Logs') OR (e.[Name] = 'Details' OR e.[Name] LIKE '% Details') OR (e.[Name] = 'Detail' OR e.[Name] LIKE '% Detail') OR (e.[Name] = 'Lines' OR e.[Name] LIKE '% Lines') OR (e.[Name] = 'Line' OR e.[Name] LIKE '% Line') OR (e.[Name] = 'Items' OR e.[Name] LIKE '% Items') OR (e.[Name] = 'Item' OR e.[Name] LIKE '% Item') OR (e.[Name] = 'Steps' OR e.[Name] LIKE '% Steps') OR (e.[Name] = 'Step' OR e.[Name] LIKE '% Step') OR (e.[Name] = 'Params' OR e.[Name] LIKE '% Params') OR (e.[Name] = 'Param' OR e.[Name] LIKE '% Param') OR (e.[Name] = 'Mappings' OR e.[Name] LIKE '% Mappings') OR (e.[Name] = 'Mapping' OR e.[Name] LIKE '% Mapping') OR (e.[Name] = 'Audit' OR e.[Name] LIKE 'Audit %' OR e.[Name] LIKE '% Audit' OR e.[Name] LIKE '% Audit %') OR (e.[Name] = 'Record Change' OR e.[Name] LIKE 'Record Change %' OR e.[Name] LIKE '% Record Change' OR e.[Name] LIKE '% Record Change %'))
                 AND e.[SchemaName] NOT IN ('${mjSchema}','__mj_BizAppsAccounting','__mj_BizAppsCommon','__mj_BizAppsOrders','sys')
                 AND NOT EXISTS (
               SELECT 1 FROM [${mjSchema}].[EntityField] f2
               WHERE f2.[EntityID] = e.[ID]
                 AND f2.[IncludeInUserSearchAPI] = 1
            )
            ) ranked
            WHERE ranked.rn <= 3
         );

/* Deterministic search-flag hygiene — clear AllowUserSearchAPI */

         UPDATE [${mjSchema}].[Entity]
         SET [AllowUserSearchAPI] = 0
         WHERE [ID] IN (
            SELECT e.[ID]
            FROM [${mjSchema}].[Entity] e
            WHERE e.[AllowUserSearchAPI] = 1
              AND e.[AutoUpdateAllowUserSearchAPI] = 1
              AND e.[VirtualEntity] = 0
              AND ISNULL(e.[FullTextSearchEnabled], 0) = 0
              AND e.[SchemaName] NOT IN ('${mjSchema}','__mj_BizAppsAccounting','__mj_BizAppsCommon','__mj_BizAppsOrders','sys')
              AND NOT EXISTS (
               SELECT 1 FROM [${mjSchema}].[EntityField] f2
               WHERE f2.[EntityID] = e.[ID]
                 AND f2.[IncludeInUserSearchAPI] = 1
            )
         );


/* Create Entity Relationship: MJ_BizApps_Tasks: Work Reports -> MJ_BizApps_Tasks: Work Report Items (One To Many via WorkReportID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '122ad9d9-cc06-44d8-aa10-308f670325fa' OR ([EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND [RelatedEntityID] = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND [RelatedEntityJoinField] = 'WorkReportID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('122ad9d9-cc06-44d8-aa10-308f670325fa', 'A9038030-2DBD-48E1-9075-03ED5373B85A', 'D9E9EE62-78CE-4E89-8ED0-35378358E321', 'WorkReportID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: AI Agent Runs -> MJ_BizApps_Tasks: Work Reports (One To Many via AuthoredByAgentRunID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'a9a7b014-4185-44b3-87de-3e47e006332a' OR ([EntityID] = '5190AF93-4C39-4429-BDAA-0AEB492A0256' AND [RelatedEntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND [RelatedEntityJoinField] = 'AuthoredByAgentRunID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a9a7b014-4185-44b3-87de-3e47e006332a', '5190AF93-4C39-4429-BDAA-0AEB492A0256', 'A9038030-2DBD-48E1-9075-03ED5373B85A', 'AuthoredByAgentRunID', 'One To Many', 1, 1, 17, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Work Reports (One To Many via PersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '405bc61c-ff42-4457-a9ae-28c033179a23' OR ([EntityID] = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND [RelatedEntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND [RelatedEntityJoinField] = 'PersonID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('405bc61c-ff42-4457-a9ae-28c033179a23', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'A9038030-2DBD-48E1-9075-03ED5373B85A', 'PersonID', 'One To Many', 1, 1, 27, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Work Reports (One To Many via ReviewedByPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'd42d05fc-9c68-4158-9168-2e42676de7ed' OR ([EntityID] = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND [RelatedEntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND [RelatedEntityJoinField] = 'ReviewedByPersonID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('d42d05fc-9c68-4158-9168-2e42676de7ed', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'A9038030-2DBD-48E1-9075-03ED5373B85A', 'ReviewedByPersonID', 'One To Many', 1, 1, 28, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Work Report Items (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '1a8268ea-646a-432b-9caa-922594236752' OR ([EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND [RelatedEntityID] = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND [RelatedEntityJoinField] = 'TaskID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('1a8268ea-646a-432b-9caa-922594236752', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'D9E9EE62-78CE-4E89-8ED0-35378358E321', 'TaskID', 'One To Many', 1, 1, 16, GETUTCDATE(), GETUTCDATE())
   END;

/* SQL text to sync schema info from database schemas */
EXEC [${mjSchema}].[spUpdateSchemaInfoFromDatabase] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* Base View SQL for MJ_BizApps_Tasks: Task Assignments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Assignments
-- Item: vwTaskAssignments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Assignments
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskAssignment
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskAssignments]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskAssignments];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskAssignments]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    MJEntity_AssigneeEntityID.[Name] AS [AssigneeEntity],
    mjBizAppsTasksTaskRole_RoleID.[Name] AS [Role],
    mjBizAppsCommonPerson_AssignedByPersonID.[DisplayName] AS [AssignedByPerson]
FROM
    [${flyway:defaultSchema}].[TaskAssignment] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Entity] AS MJEntity_AssigneeEntityID
  ON
    [t].[AssigneeEntityID] = MJEntity_AssigneeEntityID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskRole] AS mjBizAppsTasksTaskRole_RoleID
  ON
    [t].[RoleID] = mjBizAppsTasksTaskRole_RoleID.[ID]
LEFT OUTER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_AssignedByPersonID
  ON
    [t].[AssignedByPersonID] = mjBizAppsCommonPerson_AssignedByPersonID.[ID]
GO
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskAssignments] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskAssignments] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskAssignments] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskAssignments] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Assignments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Assignments
-- Item: Permissions for vwTaskAssignments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskAssignments] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskAssignments] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskAssignments] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskAssignments] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Assignments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Assignments
-- Item: spCreateTaskAssignment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskAssignment
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskAssignment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskAssignment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskAssignment]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @AssigneeEntityID uniqueidentifier,
    @AssigneeRecordID nvarchar(450),
    @RoleID_Clear bit = 0,
    @RoleID uniqueidentifier = NULL,
    @RoleNotes_Clear bit = 0,
    @RoleNotes nvarchar(255) = NULL,
    @Status nvarchar(50) = NULL,
    @AssignedByPersonID_Clear bit = 0,
    @AssignedByPersonID uniqueidentifier = NULL,
    @AssignedAt datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskAssignment]
            (
                [ID],
                [TaskID],
                [AssigneeEntityID],
                [AssigneeRecordID],
                [RoleID],
                [RoleNotes],
                [Status],
                [AssignedByPersonID],
                [AssignedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaskID,
                @AssigneeEntityID,
                @AssigneeRecordID,
                CASE WHEN @RoleID_Clear = 1 THEN NULL ELSE ISNULL(@RoleID, NULL) END,
                CASE WHEN @RoleNotes_Clear = 1 THEN NULL ELSE ISNULL(@RoleNotes, NULL) END,
                ISNULL(@Status, 'Pending'),
                CASE WHEN @AssignedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@AssignedByPersonID, NULL) END,
                ISNULL(@AssignedAt, getutcdate())
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskAssignment]
            (
                [TaskID],
                [AssigneeEntityID],
                [AssigneeRecordID],
                [RoleID],
                [RoleNotes],
                [Status],
                [AssignedByPersonID],
                [AssignedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaskID,
                @AssigneeEntityID,
                @AssigneeRecordID,
                CASE WHEN @RoleID_Clear = 1 THEN NULL ELSE ISNULL(@RoleID, NULL) END,
                CASE WHEN @RoleNotes_Clear = 1 THEN NULL ELSE ISNULL(@RoleNotes, NULL) END,
                ISNULL(@Status, 'Pending'),
                CASE WHEN @AssignedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@AssignedByPersonID, NULL) END,
                ISNULL(@AssignedAt, getutcdate())
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskAssignments] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskAssignment] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskAssignment] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskAssignment] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Assignments */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskAssignment] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskAssignment] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskAssignment] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Assignments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Assignments
-- Item: spUpdateTaskAssignment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskAssignment
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskAssignment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskAssignment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskAssignment]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier = NULL,
    @AssigneeEntityID uniqueidentifier = NULL,
    @AssigneeRecordID nvarchar(450) = NULL,
    @RoleID_Clear bit = 0,
    @RoleID uniqueidentifier = NULL,
    @RoleNotes_Clear bit = 0,
    @RoleNotes nvarchar(255) = NULL,
    @Status nvarchar(50) = NULL,
    @AssignedByPersonID_Clear bit = 0,
    @AssignedByPersonID uniqueidentifier = NULL,
    @AssignedAt datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskAssignment]
    SET
        [TaskID] = ISNULL(@TaskID, [TaskID]),
        [AssigneeEntityID] = ISNULL(@AssigneeEntityID, [AssigneeEntityID]),
        [AssigneeRecordID] = ISNULL(@AssigneeRecordID, [AssigneeRecordID]),
        [RoleID] = CASE WHEN @RoleID_Clear = 1 THEN NULL ELSE ISNULL(@RoleID, [RoleID]) END,
        [RoleNotes] = CASE WHEN @RoleNotes_Clear = 1 THEN NULL ELSE ISNULL(@RoleNotes, [RoleNotes]) END,
        [Status] = ISNULL(@Status, [Status]),
        [AssignedByPersonID] = CASE WHEN @AssignedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@AssignedByPersonID, [AssignedByPersonID]) END,
        [AssignedAt] = ISNULL(@AssignedAt, [AssignedAt])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskAssignments] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskAssignments]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskAssignment] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskAssignment] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskAssignment] TO [cdp_UI], [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskAssignment table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskAssignment]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskAssignment];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskAssignment
ON [${flyway:defaultSchema}].[TaskAssignment]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskAssignment]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskAssignment] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Assignments */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskAssignment] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskAssignment] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskAssignment] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Assignments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Assignments
-- Item: spDeleteTaskAssignment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskAssignment
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskAssignment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskAssignment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskAssignment]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskAssignment]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskAssignment] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskAssignment] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskAssignment] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Assignments */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskAssignment] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskAssignment] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskAssignment] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Activities
-- Item: vwTaskActivities
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Activities
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskActivity
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskActivities]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskActivities];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskActivities]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    mjBizAppsCommonPerson_PersonID.[DisplayName] AS [Person]
FROM
    [${flyway:defaultSchema}].[TaskActivity] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
LEFT OUTER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_PersonID
  ON
    [t].[PersonID] = mjBizAppsCommonPerson_PersonID.[ID]
GO
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskActivities] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskActivities] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskActivities] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskActivities] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Activities
-- Item: Permissions for vwTaskActivities
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskActivities] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskActivities] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskActivities] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskActivities] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Activities
-- Item: spCreateTaskActivity
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskActivity
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskActivity]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskActivity];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskActivity]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @PersonID_Clear bit = 0,
    @PersonID uniqueidentifier = NULL,
    @ActivityType nvarchar(50),
    @PreviousValue_Clear bit = 0,
    @PreviousValue nvarchar(500) = NULL,
    @NewValue_Clear bit = 0,
    @NewValue nvarchar(500) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskActivity]
            (
                [ID],
                [TaskID],
                [PersonID],
                [ActivityType],
                [PreviousValue],
                [NewValue],
                [Description]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaskID,
                CASE WHEN @PersonID_Clear = 1 THEN NULL ELSE ISNULL(@PersonID, NULL) END,
                @ActivityType,
                CASE WHEN @PreviousValue_Clear = 1 THEN NULL ELSE ISNULL(@PreviousValue, NULL) END,
                CASE WHEN @NewValue_Clear = 1 THEN NULL ELSE ISNULL(@NewValue, NULL) END,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskActivity]
            (
                [TaskID],
                [PersonID],
                [ActivityType],
                [PreviousValue],
                [NewValue],
                [Description]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaskID,
                CASE WHEN @PersonID_Clear = 1 THEN NULL ELSE ISNULL(@PersonID, NULL) END,
                @ActivityType,
                CASE WHEN @PreviousValue_Clear = 1 THEN NULL ELSE ISNULL(@PreviousValue, NULL) END,
                CASE WHEN @NewValue_Clear = 1 THEN NULL ELSE ISNULL(@NewValue, NULL) END,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskActivities] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskActivity] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskActivity] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskActivity] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Activities */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskActivity] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskActivity] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskActivity] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Activities
-- Item: spUpdateTaskActivity
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskActivity
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskActivity]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskActivity];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskActivity]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier = NULL,
    @PersonID_Clear bit = 0,
    @PersonID uniqueidentifier = NULL,
    @ActivityType nvarchar(50) = NULL,
    @PreviousValue_Clear bit = 0,
    @PreviousValue nvarchar(500) = NULL,
    @NewValue_Clear bit = 0,
    @NewValue nvarchar(500) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskActivity]
    SET
        [TaskID] = ISNULL(@TaskID, [TaskID]),
        [PersonID] = CASE WHEN @PersonID_Clear = 1 THEN NULL ELSE ISNULL(@PersonID, [PersonID]) END,
        [ActivityType] = ISNULL(@ActivityType, [ActivityType]),
        [PreviousValue] = CASE WHEN @PreviousValue_Clear = 1 THEN NULL ELSE ISNULL(@PreviousValue, [PreviousValue]) END,
        [NewValue] = CASE WHEN @NewValue_Clear = 1 THEN NULL ELSE ISNULL(@NewValue, [NewValue]) END,
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskActivities] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskActivities]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskActivity] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskActivity] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskActivity] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskActivity table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskActivity]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskActivity];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskActivity
ON [${flyway:defaultSchema}].[TaskActivity]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskActivity]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskActivity] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Activities */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskActivity] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskActivity] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskActivity] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Activities
-- Item: spDeleteTaskActivity
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskActivity
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskActivity]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskActivity];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskActivity]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskActivity]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskActivity] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskActivity] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskActivity] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Activities */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskActivity] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskActivity] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskActivity] TO [cdp_Developer], [cdp_Integration];

/* Hierarchy Metadata Function SQL for MJ_BizApps_Tasks: Task Comments.ParentID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: fnTaskCommentParentID_GetHierarchyMeta
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- HIERARCHY METADATA FUNCTION FOR: [TaskComment].[ParentID]
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[fnTaskCommentParentID_GetHierarchyMeta]', 'IF') IS NOT NULL
    DROP FUNCTION [${flyway:defaultSchema}].[fnTaskCommentParentID_GetHierarchyMeta];
GO

CREATE FUNCTION [${flyway:defaultSchema}].[fnTaskCommentParentID_GetHierarchyMeta]
(
    @RecordID uniqueidentifier,
    @ParentID uniqueidentifier
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE_Ancestors AS (
        SELECT
            [ID],
            [ParentID],
            0 AS [Depth],
            CAST('/' + CAST([ID] AS NVARCHAR(36)) + '/' AS NVARCHAR(MAX)) AS [Path]
        FROM
            [${flyway:defaultSchema}].[TaskComment]
        WHERE
            [ID] = @RecordID

        UNION ALL

        SELECT
            p.[ID],
            p.[ParentID],
            c.[Depth] + 1 AS [Depth],
            CAST('/' + CAST(p.[ID] AS NVARCHAR(36)) + c.[Path] AS NVARCHAR(MAX)) AS [Path]
        FROM
            [${flyway:defaultSchema}].[TaskComment] p
        INNER JOIN
            CTE_Ancestors c ON p.[ID] = c.[ParentID]
        WHERE
            c.[Depth] < 100
    )
    SELECT TOP 1
        a.[ID] AS [RootID],
        (SELECT MAX([Depth]) FROM CTE_Ancestors) AS [Depth],
        (SELECT TOP 1 [Path] FROM CTE_Ancestors ORDER BY [Depth] DESC) AS [Path],
        CAST(CASE WHEN EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[TaskComment] WHERE [ParentID] = @RecordID) THEN 0 ELSE 1 END AS BIT) AS [IsLeaf],
        (SELECT COUNT(1) FROM [${flyway:defaultSchema}].[TaskComment] WHERE [ParentID] = @RecordID) AS [ChildCount]
    FROM
        CTE_Ancestors a
    WHERE
        a.[ParentID] IS NULL OR @ParentID IS NULL
    ORDER BY
        a.[Depth] DESC
);
GO

/* Descendants Traversal Function SQL for MJ_BizApps_Tasks: Task Comments.ParentID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: fnTaskCommentParentID_GetDescendants
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- DESCENDANTS FUNCTION FOR: [TaskComment].[ParentID]
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[fnTaskCommentParentID_GetDescendants]', 'IF') IS NOT NULL
    DROP FUNCTION [${flyway:defaultSchema}].[fnTaskCommentParentID_GetDescendants];
GO

CREATE FUNCTION [${flyway:defaultSchema}].[fnTaskCommentParentID_GetDescendants]
(
    @RootID uniqueidentifier,
    @MaxDepth INT = NULL
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE_Descendants AS (
        SELECT
            [ID],
            [ParentID],
            0 AS [RelativeDepth],
            CAST('/' + CAST([ID] AS NVARCHAR(36)) + '/' AS NVARCHAR(MAX)) AS [Path]
        FROM
            [${flyway:defaultSchema}].[TaskComment]
        WHERE
            [ID] = @RootID

        UNION ALL

        SELECT
            c.[ID],
            c.[ParentID],
            p.[RelativeDepth] + 1 AS [RelativeDepth],
            CAST(p.[Path] + CAST(c.[ID] AS NVARCHAR(36)) + '/' AS NVARCHAR(MAX)) AS [Path]
        FROM
            [${flyway:defaultSchema}].[TaskComment] c
        INNER JOIN
            CTE_Descendants p ON c.[ParentID] = p.[ID]
        WHERE
            (@MaxDepth IS NULL OR p.[RelativeDepth] < @MaxDepth)
            AND p.[RelativeDepth] < 100
    )
    SELECT
        d.[ID] AS [ID],
        d.[RelativeDepth] AS [Depth],
        d.[Path],
        CAST(CASE WHEN EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[TaskComment] WHERE [ParentID] = d.[ID]) THEN 0 ELSE 1 END AS BIT) AS [IsLeaf],
        (SELECT COUNT(1) FROM [${flyway:defaultSchema}].[TaskComment] WHERE [ParentID] = d.[ID]) AS [ChildCount]
    FROM
        CTE_Descendants d
);
GO

/* Ancestors Traversal Function SQL for MJ_BizApps_Tasks: Task Comments.ParentID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: fnTaskCommentParentID_GetAncestors
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- ANCESTORS FUNCTION FOR: [TaskComment].[ParentID]
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[fnTaskCommentParentID_GetAncestors]', 'IF') IS NOT NULL
    DROP FUNCTION [${flyway:defaultSchema}].[fnTaskCommentParentID_GetAncestors];
GO

CREATE FUNCTION [${flyway:defaultSchema}].[fnTaskCommentParentID_GetAncestors]
(
    @RecordID uniqueidentifier
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE_Ancestors AS (
        SELECT
            [ID],
            [ParentID],
            0 AS [LevelUp],
            CAST('/' + CAST([ID] AS NVARCHAR(36)) + '/' AS NVARCHAR(MAX)) AS [Path]
        FROM
            [${flyway:defaultSchema}].[TaskComment]
        WHERE
            [ID] = @RecordID

        UNION ALL

        SELECT
            p.[ID],
            p.[ParentID],
            c.[LevelUp] + 1 AS [LevelUp],
            CAST('/' + CAST(p.[ID] AS NVARCHAR(36)) + c.[Path] AS NVARCHAR(MAX)) AS [Path]
        FROM
            [${flyway:defaultSchema}].[TaskComment] p
        INNER JOIN
            CTE_Ancestors c ON p.[ID] = c.[ParentID]
        WHERE
            c.[LevelUp] < 100
    )
    SELECT
        a.[ID] AS [ID],
        a.[LevelUp],
        a.[Path]
    FROM
        CTE_Ancestors a
);
GO

/* Root ID Function SQL for MJ_BizApps_Tasks: Task Comments.ParentID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: fnTaskCommentParentID_GetRootID
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- ROOT ID FUNCTION FOR: [TaskComment].[ParentID]
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[fnTaskCommentParentID_GetRootID]', 'IF') IS NOT NULL
    DROP FUNCTION [${flyway:defaultSchema}].[fnTaskCommentParentID_GetRootID];
GO

CREATE FUNCTION [${flyway:defaultSchema}].[fnTaskCommentParentID_GetRootID]
(
    @RecordID uniqueidentifier,
    @ParentID uniqueidentifier
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE_RootParent AS (
        SELECT
            [ID],
            [ParentID],
            [ID] AS [RootParentID],
            0 AS [Depth]
        FROM
            [${flyway:defaultSchema}].[TaskComment]
        WHERE
            [ID] = COALESCE(@ParentID, @RecordID)

        UNION ALL

        SELECT
            c.[ID],
            c.[ParentID],
            c.[ID] AS [RootParentID],
            p.[Depth] + 1 AS [Depth]
        FROM
            [${flyway:defaultSchema}].[TaskComment] c
        INNER JOIN
            CTE_RootParent p ON c.[ID] = p.[ParentID]
        WHERE
            p.[Depth] < 100
    )
    SELECT TOP 1
        [RootParentID] AS RootID
    FROM
        CTE_RootParent
    WHERE
        [ParentID] IS NULL
    ORDER BY
        [RootParentID]
);
GO

/* Base View SQL for MJ_BizApps_Tasks: Task Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: vwTaskComments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Comments
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskComment
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskComments]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskComments];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskComments]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    mjBizAppsCommonPerson_PersonID.[DisplayName] AS [Person],
    hier_ParentID.RootID AS [RootParentID],
    hier_ParentID.Depth AS [ParentIDDepth],
    hier_ParentID.Path AS [ParentIDPath],
    hier_ParentID.IsLeaf AS [ParentIDIsLeaf],
    hier_ParentID.ChildCount AS [ParentIDChildCount]
FROM
    [${flyway:defaultSchema}].[TaskComment] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
LEFT OUTER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_PersonID
  ON
    [t].[PersonID] = mjBizAppsCommonPerson_PersonID.[ID]
OUTER APPLY
    [${flyway:defaultSchema}].[fnTaskCommentParentID_GetHierarchyMeta]([t].[ID], [t].[ParentID]) AS hier_ParentID
GO
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskComments] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskComments] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskComments] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskComments] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: Permissions for vwTaskComments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskComments] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskComments] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskComments] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskComments] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: spCreateTaskComment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskComment
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskComment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskComment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskComment]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @ParentID_Clear bit = 0,
    @ParentID uniqueidentifier = NULL,
    @PersonID uniqueidentifier,
    @Content nvarchar(MAX),
    @IsEdited bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskComment]
            (
                [ID],
                [TaskID],
                [ParentID],
                [PersonID],
                [Content],
                [IsEdited]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaskID,
                CASE WHEN @ParentID_Clear = 1 THEN NULL ELSE ISNULL(@ParentID, NULL) END,
                @PersonID,
                @Content,
                ISNULL(@IsEdited, 0)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskComment]
            (
                [TaskID],
                [ParentID],
                [PersonID],
                [Content],
                [IsEdited]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaskID,
                CASE WHEN @ParentID_Clear = 1 THEN NULL ELSE ISNULL(@ParentID, NULL) END,
                @PersonID,
                @Content,
                ISNULL(@IsEdited, 0)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskComments] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskComment] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskComment] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskComment] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Comments */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskComment] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskComment] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskComment] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: spUpdateTaskComment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskComment
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskComment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskComment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskComment]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier = NULL,
    @ParentID_Clear bit = 0,
    @ParentID uniqueidentifier = NULL,
    @PersonID uniqueidentifier = NULL,
    @Content nvarchar(MAX) = NULL,
    @IsEdited bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskComment]
    SET
        [TaskID] = ISNULL(@TaskID, [TaskID]),
        [ParentID] = CASE WHEN @ParentID_Clear = 1 THEN NULL ELSE ISNULL(@ParentID, [ParentID]) END,
        [PersonID] = ISNULL(@PersonID, [PersonID]),
        [Content] = ISNULL(@Content, [Content]),
        [IsEdited] = ISNULL(@IsEdited, [IsEdited])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskComments] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskComments]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskComment] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskComment] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskComment] TO [cdp_UI], [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskComment table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskComment]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskComment];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskComment
ON [${flyway:defaultSchema}].[TaskComment]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskComment]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskComment] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Comments */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskComment] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskComment] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskComment] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: spDeleteTaskComment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskComment
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskComment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskComment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskComment]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskComment]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskComment] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskComment] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskComment] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Comments */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskComment] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskComment] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskComment] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Dependencies
-- Item: vwTaskDependencies
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Dependencies
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskDependency
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskDependencies]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskDependencies];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskDependencies]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    mjBizAppsTasksTask_DependsOnTaskID.[Name] AS [DependsOnTask]
FROM
    [${flyway:defaultSchema}].[TaskDependency] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_DependsOnTaskID
  ON
    [t].[DependsOnTaskID] = mjBizAppsTasksTask_DependsOnTaskID.[ID]
GO
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskDependencies] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskDependencies] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskDependencies] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskDependencies] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Dependencies
-- Item: Permissions for vwTaskDependencies
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskDependencies] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskDependencies] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskDependencies] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskDependencies] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Dependencies
-- Item: spCreateTaskDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskDependency
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskDependency]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskDependency];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskDependency]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @DependsOnTaskID uniqueidentifier,
    @DependencyType nvarchar(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskDependency]
            (
                [ID],
                [TaskID],
                [DependsOnTaskID],
                [DependencyType]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaskID,
                @DependsOnTaskID,
                ISNULL(@DependencyType, 'FinishToStart')
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskDependency]
            (
                [TaskID],
                [DependsOnTaskID],
                [DependencyType]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaskID,
                @DependsOnTaskID,
                ISNULL(@DependencyType, 'FinishToStart')
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskDependencies] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDependency] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDependency] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDependency] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Dependencies */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDependency] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDependency] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDependency] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Dependencies
-- Item: spUpdateTaskDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskDependency
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskDependency]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskDependency];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskDependency]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier = NULL,
    @DependsOnTaskID uniqueidentifier = NULL,
    @DependencyType nvarchar(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskDependency]
    SET
        [TaskID] = ISNULL(@TaskID, [TaskID]),
        [DependsOnTaskID] = ISNULL(@DependsOnTaskID, [DependsOnTaskID]),
        [DependencyType] = ISNULL(@DependencyType, [DependencyType])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskDependencies] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskDependencies]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskDependency] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskDependency] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskDependency] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskDependency table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskDependency]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskDependency];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskDependency
ON [${flyway:defaultSchema}].[TaskDependency]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskDependency]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskDependency] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Dependencies */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskDependency] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskDependency] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskDependency] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Dependencies
-- Item: spDeleteTaskDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskDependency
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskDependency]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskDependency];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskDependency]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskDependency]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDependency] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDependency] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDependency] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Dependencies */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDependency] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDependency] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDependency] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Task Check Ins */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: vwTaskCheckIns
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Check Ins
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskCheckIn
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskCheckIns]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskCheckIns];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskCheckIns]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    mjBizAppsCommonPerson_AuthorPersonID.[DisplayName] AS [AuthorPerson],
    MJUser_AuthorUserID.[Name] AS [AuthorUser],
    MJAIAgent_ReportedByAIAgentID.[Name] AS [ReportedByAIAgent]
FROM
    [${flyway:defaultSchema}].[TaskCheckIn] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
LEFT OUTER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_AuthorPersonID
  ON
    [t].[AuthorPersonID] = mjBizAppsCommonPerson_AuthorPersonID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[User] AS MJUser_AuthorUserID
  ON
    [t].[AuthorUserID] = MJUser_AuthorUserID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[AIAgent] AS MJAIAgent_ReportedByAIAgentID
  ON
    [t].[ReportedByAIAgentID] = MJAIAgent_ReportedByAIAgentID.[ID]
GO
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskCheckIns] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskCheckIns] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskCheckIns] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskCheckIns] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Check Ins */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: Permissions for vwTaskCheckIns
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskCheckIns] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskCheckIns] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskCheckIns] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskCheckIns] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Check Ins */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: spCreateTaskCheckIn
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskCheckIn
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskCheckIn]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskCheckIn];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskCheckIn]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @AuthorPersonID_Clear bit = 0,
    @AuthorPersonID uniqueidentifier = NULL,
    @AuthorUserID_Clear bit = 0,
    @AuthorUserID uniqueidentifier = NULL,
    @ReportedByAIAgentID_Clear bit = 0,
    @ReportedByAIAgentID uniqueidentifier = NULL,
    @CheckInAt datetimeoffset = NULL,
    @HealthStatus nvarchar(20) = NULL,
    @ConfidenceScore_Clear bit = 0,
    @ConfidenceScore int = NULL,
    @PreviousValue_Clear bit = 0,
    @PreviousValue decimal(18, 4) = NULL,
    @NewValue_Clear bit = 0,
    @NewValue decimal(18, 4) = NULL,
    @PercentComplete_Clear bit = 0,
    @PercentComplete int = NULL,
    @Summary nvarchar(MAX),
    @Blockers_Clear bit = 0,
    @Blockers nvarchar(MAX) = NULL,
    @NextSteps_Clear bit = 0,
    @NextSteps nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskCheckIn]
            (
                [ID],
                [TaskID],
                [AuthorPersonID],
                [AuthorUserID],
                [ReportedByAIAgentID],
                [CheckInAt],
                [HealthStatus],
                [ConfidenceScore],
                [PreviousValue],
                [NewValue],
                [PercentComplete],
                [Summary],
                [Blockers],
                [NextSteps]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaskID,
                CASE WHEN @AuthorPersonID_Clear = 1 THEN NULL ELSE ISNULL(@AuthorPersonID, NULL) END,
                CASE WHEN @AuthorUserID_Clear = 1 THEN NULL ELSE ISNULL(@AuthorUserID, NULL) END,
                CASE WHEN @ReportedByAIAgentID_Clear = 1 THEN NULL ELSE ISNULL(@ReportedByAIAgentID, NULL) END,
                ISNULL(@CheckInAt, sysdatetimeoffset()),
                ISNULL(@HealthStatus, 'OnTrack'),
                CASE WHEN @ConfidenceScore_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceScore, NULL) END,
                CASE WHEN @PreviousValue_Clear = 1 THEN NULL ELSE ISNULL(@PreviousValue, NULL) END,
                CASE WHEN @NewValue_Clear = 1 THEN NULL ELSE ISNULL(@NewValue, NULL) END,
                CASE WHEN @PercentComplete_Clear = 1 THEN NULL ELSE ISNULL(@PercentComplete, NULL) END,
                @Summary,
                CASE WHEN @Blockers_Clear = 1 THEN NULL ELSE ISNULL(@Blockers, NULL) END,
                CASE WHEN @NextSteps_Clear = 1 THEN NULL ELSE ISNULL(@NextSteps, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskCheckIn]
            (
                [TaskID],
                [AuthorPersonID],
                [AuthorUserID],
                [ReportedByAIAgentID],
                [CheckInAt],
                [HealthStatus],
                [ConfidenceScore],
                [PreviousValue],
                [NewValue],
                [PercentComplete],
                [Summary],
                [Blockers],
                [NextSteps]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaskID,
                CASE WHEN @AuthorPersonID_Clear = 1 THEN NULL ELSE ISNULL(@AuthorPersonID, NULL) END,
                CASE WHEN @AuthorUserID_Clear = 1 THEN NULL ELSE ISNULL(@AuthorUserID, NULL) END,
                CASE WHEN @ReportedByAIAgentID_Clear = 1 THEN NULL ELSE ISNULL(@ReportedByAIAgentID, NULL) END,
                ISNULL(@CheckInAt, sysdatetimeoffset()),
                ISNULL(@HealthStatus, 'OnTrack'),
                CASE WHEN @ConfidenceScore_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceScore, NULL) END,
                CASE WHEN @PreviousValue_Clear = 1 THEN NULL ELSE ISNULL(@PreviousValue, NULL) END,
                CASE WHEN @NewValue_Clear = 1 THEN NULL ELSE ISNULL(@NewValue, NULL) END,
                CASE WHEN @PercentComplete_Clear = 1 THEN NULL ELSE ISNULL(@PercentComplete, NULL) END,
                @Summary,
                CASE WHEN @Blockers_Clear = 1 THEN NULL ELSE ISNULL(@Blockers, NULL) END,
                CASE WHEN @NextSteps_Clear = 1 THEN NULL ELSE ISNULL(@NextSteps, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskCheckIns] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskCheckIn] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskCheckIn] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskCheckIn] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Check Ins */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskCheckIn] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskCheckIn] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskCheckIn] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Check Ins */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: spUpdateTaskCheckIn
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskCheckIn
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskCheckIn]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskCheckIn];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskCheckIn]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier = NULL,
    @AuthorPersonID_Clear bit = 0,
    @AuthorPersonID uniqueidentifier = NULL,
    @AuthorUserID_Clear bit = 0,
    @AuthorUserID uniqueidentifier = NULL,
    @ReportedByAIAgentID_Clear bit = 0,
    @ReportedByAIAgentID uniqueidentifier = NULL,
    @CheckInAt datetimeoffset = NULL,
    @HealthStatus nvarchar(20) = NULL,
    @ConfidenceScore_Clear bit = 0,
    @ConfidenceScore int = NULL,
    @PreviousValue_Clear bit = 0,
    @PreviousValue decimal(18, 4) = NULL,
    @NewValue_Clear bit = 0,
    @NewValue decimal(18, 4) = NULL,
    @PercentComplete_Clear bit = 0,
    @PercentComplete int = NULL,
    @Summary nvarchar(MAX) = NULL,
    @Blockers_Clear bit = 0,
    @Blockers nvarchar(MAX) = NULL,
    @NextSteps_Clear bit = 0,
    @NextSteps nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskCheckIn]
    SET
        [TaskID] = ISNULL(@TaskID, [TaskID]),
        [AuthorPersonID] = CASE WHEN @AuthorPersonID_Clear = 1 THEN NULL ELSE ISNULL(@AuthorPersonID, [AuthorPersonID]) END,
        [AuthorUserID] = CASE WHEN @AuthorUserID_Clear = 1 THEN NULL ELSE ISNULL(@AuthorUserID, [AuthorUserID]) END,
        [ReportedByAIAgentID] = CASE WHEN @ReportedByAIAgentID_Clear = 1 THEN NULL ELSE ISNULL(@ReportedByAIAgentID, [ReportedByAIAgentID]) END,
        [CheckInAt] = ISNULL(@CheckInAt, [CheckInAt]),
        [HealthStatus] = ISNULL(@HealthStatus, [HealthStatus]),
        [ConfidenceScore] = CASE WHEN @ConfidenceScore_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceScore, [ConfidenceScore]) END,
        [PreviousValue] = CASE WHEN @PreviousValue_Clear = 1 THEN NULL ELSE ISNULL(@PreviousValue, [PreviousValue]) END,
        [NewValue] = CASE WHEN @NewValue_Clear = 1 THEN NULL ELSE ISNULL(@NewValue, [NewValue]) END,
        [PercentComplete] = CASE WHEN @PercentComplete_Clear = 1 THEN NULL ELSE ISNULL(@PercentComplete, [PercentComplete]) END,
        [Summary] = ISNULL(@Summary, [Summary]),
        [Blockers] = CASE WHEN @Blockers_Clear = 1 THEN NULL ELSE ISNULL(@Blockers, [Blockers]) END,
        [NextSteps] = CASE WHEN @NextSteps_Clear = 1 THEN NULL ELSE ISNULL(@NextSteps, [NextSteps]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskCheckIns] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskCheckIns]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskCheckIn] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskCheckIn] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskCheckIn] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskCheckIn table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskCheckIn]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskCheckIn];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskCheckIn
ON [${flyway:defaultSchema}].[TaskCheckIn]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskCheckIn]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskCheckIn] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Check Ins */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskCheckIn] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskCheckIn] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskCheckIn] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Check Ins */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: spDeleteTaskCheckIn
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskCheckIn
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskCheckIn]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskCheckIn];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskCheckIn]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskCheckIn]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskCheckIn] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskCheckIn] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskCheckIn] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Check Ins */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskCheckIn] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskCheckIn] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskCheckIn] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Task Decisions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decisions
-- Item: vwTaskDecisions
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Decisions
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskDecision
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskDecisions]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskDecisions];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskDecisions]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    mjBizAppsTasksTaskDecisionOutcome_OutcomeID.[Name] AS [Outcome],
    mjBizAppsCommonPerson_DecidedByPersonID.[DisplayName] AS [DecidedByPerson]
FROM
    [${flyway:defaultSchema}].[TaskDecision] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskDecisionOutcome] AS mjBizAppsTasksTaskDecisionOutcome_OutcomeID
  ON
    [t].[OutcomeID] = mjBizAppsTasksTaskDecisionOutcome_OutcomeID.[ID]
LEFT OUTER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_DecidedByPersonID
  ON
    [t].[DecidedByPersonID] = mjBizAppsCommonPerson_DecidedByPersonID.[ID]
GO
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskDecisions] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskDecisions] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskDecisions] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskDecisions] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Decisions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decisions
-- Item: Permissions for vwTaskDecisions
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskDecisions] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskDecisions] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskDecisions] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskDecisions] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Decisions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decisions
-- Item: spCreateTaskDecision
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskDecision
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskDecision]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskDecision];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskDecision]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @OutcomeID uniqueidentifier,
    @DecidedByPersonID_Clear bit = 0,
    @DecidedByPersonID uniqueidentifier = NULL,
    @DecidedAt datetimeoffset = NULL,
    @DecisionNotes_Clear bit = 0,
    @DecisionNotes nvarchar(MAX) = NULL,
    @TaskAssignmentID_Clear bit = 0,
    @TaskAssignmentID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskDecision]
            (
                [ID],
                [TaskID],
                [OutcomeID],
                [DecidedByPersonID],
                [DecidedAt],
                [DecisionNotes],
                [TaskAssignmentID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaskID,
                @OutcomeID,
                CASE WHEN @DecidedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@DecidedByPersonID, NULL) END,
                ISNULL(@DecidedAt, getutcdate()),
                CASE WHEN @DecisionNotes_Clear = 1 THEN NULL ELSE ISNULL(@DecisionNotes, NULL) END,
                CASE WHEN @TaskAssignmentID_Clear = 1 THEN NULL ELSE ISNULL(@TaskAssignmentID, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskDecision]
            (
                [TaskID],
                [OutcomeID],
                [DecidedByPersonID],
                [DecidedAt],
                [DecisionNotes],
                [TaskAssignmentID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaskID,
                @OutcomeID,
                CASE WHEN @DecidedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@DecidedByPersonID, NULL) END,
                ISNULL(@DecidedAt, getutcdate()),
                CASE WHEN @DecisionNotes_Clear = 1 THEN NULL ELSE ISNULL(@DecisionNotes, NULL) END,
                CASE WHEN @TaskAssignmentID_Clear = 1 THEN NULL ELSE ISNULL(@TaskAssignmentID, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskDecisions] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDecision] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDecision] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDecision] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Decisions */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDecision] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDecision] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDecision] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Decisions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decisions
-- Item: spUpdateTaskDecision
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskDecision
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskDecision]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskDecision];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskDecision]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier = NULL,
    @OutcomeID uniqueidentifier = NULL,
    @DecidedByPersonID_Clear bit = 0,
    @DecidedByPersonID uniqueidentifier = NULL,
    @DecidedAt datetimeoffset = NULL,
    @DecisionNotes_Clear bit = 0,
    @DecisionNotes nvarchar(MAX) = NULL,
    @TaskAssignmentID_Clear bit = 0,
    @TaskAssignmentID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskDecision]
    SET
        [TaskID] = ISNULL(@TaskID, [TaskID]),
        [OutcomeID] = ISNULL(@OutcomeID, [OutcomeID]),
        [DecidedByPersonID] = CASE WHEN @DecidedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@DecidedByPersonID, [DecidedByPersonID]) END,
        [DecidedAt] = ISNULL(@DecidedAt, [DecidedAt]),
        [DecisionNotes] = CASE WHEN @DecisionNotes_Clear = 1 THEN NULL ELSE ISNULL(@DecisionNotes, [DecisionNotes]) END,
        [TaskAssignmentID] = CASE WHEN @TaskAssignmentID_Clear = 1 THEN NULL ELSE ISNULL(@TaskAssignmentID, [TaskAssignmentID]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskDecisions] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskDecisions]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskDecision] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskDecision] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskDecision] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskDecision table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskDecision]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskDecision];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskDecision
ON [${flyway:defaultSchema}].[TaskDecision]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskDecision]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskDecision] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Decisions */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskDecision] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskDecision] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskDecision] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Decisions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decisions
-- Item: spDeleteTaskDecision
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskDecision
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskDecision]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskDecision];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskDecision]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskDecision]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDecision] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDecision] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDecision] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Decisions */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDecision] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDecision] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDecision] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
-- Item: vwTaskTemplateItemDependencies
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Template Item Dependencies
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskTemplateItemDependency
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskTemplateItemDependencies]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskTemplateItemDependencies];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskTemplateItemDependencies]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskTemplateItem_ItemID.[Name] AS [Item],
    mjBizAppsTasksTaskTemplateItem_DependsOnItemID.[Name] AS [DependsOnItem]
FROM
    [${flyway:defaultSchema}].[TaskTemplateItemDependency] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskTemplateItem] AS mjBizAppsTasksTaskTemplateItem_ItemID
  ON
    [t].[ItemID] = mjBizAppsTasksTaskTemplateItem_ItemID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskTemplateItem] AS mjBizAppsTasksTaskTemplateItem_DependsOnItemID
  ON
    [t].[DependsOnItemID] = mjBizAppsTasksTaskTemplateItem_DependsOnItemID.[ID]
GO
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemDependencies] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemDependencies] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemDependencies] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemDependencies] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
-- Item: Permissions for vwTaskTemplateItemDependencies
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemDependencies] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemDependencies] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemDependencies] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemDependencies] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
-- Item: spCreateTaskTemplateItemDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTemplateItemDependency
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskTemplateItemDependency]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTemplateItemDependency];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTemplateItemDependency]
    @ID uniqueidentifier = NULL,
    @ItemID uniqueidentifier,
    @DependsOnItemID uniqueidentifier,
    @DependencyType nvarchar(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskTemplateItemDependency]
            (
                [ID],
                [ItemID],
                [DependsOnItemID],
                [DependencyType]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @ItemID,
                @DependsOnItemID,
                ISNULL(@DependencyType, 'FinishToStart')
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskTemplateItemDependency]
            (
                [ItemID],
                [DependsOnItemID],
                [DependencyType]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ItemID,
                @DependsOnItemID,
                ISNULL(@DependencyType, 'FinishToStart')
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskTemplateItemDependencies] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItemDependency] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItemDependency] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItemDependency] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Template Item Dependencies */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItemDependency] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItemDependency] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItemDependency] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
-- Item: spUpdateTaskTemplateItemDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTemplateItemDependency
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskTemplateItemDependency]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTemplateItemDependency];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTemplateItemDependency]
    @ID uniqueidentifier,
    @ItemID uniqueidentifier = NULL,
    @DependsOnItemID uniqueidentifier = NULL,
    @DependencyType nvarchar(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTemplateItemDependency]
    SET
        [ItemID] = ISNULL(@ItemID, [ItemID]),
        [DependsOnItemID] = ISNULL(@DependsOnItemID, [DependsOnItemID]),
        [DependencyType] = ISNULL(@DependencyType, [DependencyType])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskTemplateItemDependencies] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskTemplateItemDependencies]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItemDependency] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItemDependency] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItemDependency] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTemplateItemDependency table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskTemplateItemDependency]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskTemplateItemDependency];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskTemplateItemDependency
ON [${flyway:defaultSchema}].[TaskTemplateItemDependency]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTemplateItemDependency]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskTemplateItemDependency] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Template Item Dependencies */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItemDependency] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItemDependency] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItemDependency] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
-- Item: spDeleteTaskTemplateItemDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTemplateItemDependency
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskTemplateItemDependency]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTemplateItemDependency];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTemplateItemDependency]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskTemplateItemDependency]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItemDependency] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItemDependency] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItemDependency] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Template Item Dependencies */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItemDependency] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItemDependency] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItemDependency] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Task Notification Logs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Logs
-- Item: vwTaskNotificationLogs
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Notification Logs
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskNotificationLog
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskNotificationLogs]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskNotificationLogs];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskNotificationLogs]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    MJUser_NotifiedUserID.[Name] AS [NotifiedUser]
FROM
    [${flyway:defaultSchema}].[TaskNotificationLog] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[User] AS MJUser_NotifiedUserID
  ON
    [t].[NotifiedUserID] = MJUser_NotifiedUserID.[ID]
GO
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskNotificationLogs] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskNotificationLogs] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskNotificationLogs] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskNotificationLogs] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Notification Logs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Logs
-- Item: Permissions for vwTaskNotificationLogs
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskNotificationLogs] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskNotificationLogs] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskNotificationLogs] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskNotificationLogs] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Notification Logs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Logs
-- Item: spCreateTaskNotificationLog
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskNotificationLog
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskNotificationLog]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskNotificationLog];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskNotificationLog]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @NotificationType nvarchar(50),
    @NotifiedUserID uniqueidentifier,
    @NotifiedAt datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskNotificationLog]
            (
                [ID],
                [TaskID],
                [NotificationType],
                [NotifiedUserID],
                [NotifiedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaskID,
                @NotificationType,
                @NotifiedUserID,
                ISNULL(@NotifiedAt, getutcdate())
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskNotificationLog]
            (
                [TaskID],
                [NotificationType],
                [NotifiedUserID],
                [NotifiedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaskID,
                @NotificationType,
                @NotifiedUserID,
                ISNULL(@NotifiedAt, getutcdate())
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskNotificationLogs] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskNotificationLog] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskNotificationLog] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskNotificationLog] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Notification Logs */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskNotificationLog] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskNotificationLog] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskNotificationLog] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Notification Logs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Logs
-- Item: spUpdateTaskNotificationLog
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskNotificationLog
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskNotificationLog]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskNotificationLog];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskNotificationLog]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier = NULL,
    @NotificationType nvarchar(50) = NULL,
    @NotifiedUserID uniqueidentifier = NULL,
    @NotifiedAt datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskNotificationLog]
    SET
        [TaskID] = ISNULL(@TaskID, [TaskID]),
        [NotificationType] = ISNULL(@NotificationType, [NotificationType]),
        [NotifiedUserID] = ISNULL(@NotifiedUserID, [NotifiedUserID]),
        [NotifiedAt] = ISNULL(@NotifiedAt, [NotifiedAt])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskNotificationLogs] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskNotificationLogs]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskNotificationLog] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskNotificationLog] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskNotificationLog] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskNotificationLog table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskNotificationLog]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskNotificationLog];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskNotificationLog
ON [${flyway:defaultSchema}].[TaskNotificationLog]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskNotificationLog]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskNotificationLog] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Notification Logs */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskNotificationLog] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskNotificationLog] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskNotificationLog] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Notification Logs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Logs
-- Item: spDeleteTaskNotificationLog
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskNotificationLog
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskNotificationLog]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskNotificationLog];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskNotificationLog]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskNotificationLog]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskNotificationLog] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskNotificationLog] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskNotificationLog] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Notification Logs */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskNotificationLog] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskNotificationLog] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskNotificationLog] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Links
-- Item: vwTaskLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Links
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskLink
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskLinks]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskLinks];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskLinks]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    MJEntity_EntityID.[Name] AS [Entity]
FROM
    [${flyway:defaultSchema}].[TaskLink] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Entity] AS MJEntity_EntityID
  ON
    [t].[EntityID] = MJEntity_EntityID.[ID]
GO
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskLinks] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskLinks] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskLinks] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Links
-- Item: Permissions for vwTaskLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskLinks] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskLinks] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskLinks] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Links
-- Item: spCreateTaskLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskLink]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @EntityID uniqueidentifier,
    @RecordID nvarchar(450),
    @Description_Clear bit = 0,
    @Description nvarchar(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskLink]
            (
                [ID],
                [TaskID],
                [EntityID],
                [RecordID],
                [Description]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaskID,
                @EntityID,
                @RecordID,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskLink]
            (
                [TaskID],
                [EntityID],
                [RecordID],
                [Description]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaskID,
                @EntityID,
                @RecordID,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskLinks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskLink] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskLink] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskLink] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Links */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskLink] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskLink] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskLink] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Links
-- Item: spUpdateTaskLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskLink]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier = NULL,
    @EntityID uniqueidentifier = NULL,
    @RecordID nvarchar(450) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskLink]
    SET
        [TaskID] = ISNULL(@TaskID, [TaskID]),
        [EntityID] = ISNULL(@EntityID, [EntityID]),
        [RecordID] = ISNULL(@RecordID, [RecordID]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskLinks] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskLinks]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskLink] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskLink] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskLink] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskLink table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskLink]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskLink];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskLink
ON [${flyway:defaultSchema}].[TaskLink]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskLink]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskLink] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Links */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskLink] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskLink] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskLink] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Links
-- Item: spDeleteTaskLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskLink]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskLink]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskLink] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskLink] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskLink] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Links */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskLink] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskLink] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskLink] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tag Links
-- Item: vwTaskTagLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Tag Links
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskTagLink
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskTagLinks]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskTagLinks];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskTagLinks]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    mjBizAppsTasksTaskTag_TagID.[Name] AS [Tag]
FROM
    [${flyway:defaultSchema}].[TaskTagLink] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskTag] AS mjBizAppsTasksTaskTag_TagID
  ON
    [t].[TagID] = mjBizAppsTasksTaskTag_TagID.[ID]
GO
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTagLinks] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTagLinks] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTagLinks] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTagLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tag Links
-- Item: Permissions for vwTaskTagLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTagLinks] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTagLinks] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTagLinks] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTagLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tag Links
-- Item: spCreateTaskTagLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTagLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskTagLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTagLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTagLink]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @TagID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskTagLink]
            (
                [ID],
                [TaskID],
                [TagID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaskID,
                @TagID
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskTagLink]
            (
                [TaskID],
                [TagID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaskID,
                @TagID
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskTagLinks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTagLink] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTagLink] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTagLink] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Tag Links */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTagLink] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTagLink] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTagLink] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tag Links
-- Item: spUpdateTaskTagLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTagLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskTagLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTagLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTagLink]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier = NULL,
    @TagID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTagLink]
    SET
        [TaskID] = ISNULL(@TaskID, [TaskID]),
        [TagID] = ISNULL(@TagID, [TagID])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskTagLinks] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskTagLinks]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTagLink] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTagLink] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTagLink] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTagLink table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskTagLink]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskTagLink];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskTagLink
ON [${flyway:defaultSchema}].[TaskTagLink]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTagLink]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskTagLink] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Tag Links */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTagLink] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTagLink] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTagLink] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tag Links
-- Item: spDeleteTaskTagLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTagLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskTagLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTagLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTagLink]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskTagLink]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTagLink] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTagLink] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTagLink] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Tag Links */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTagLink] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTagLink] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTagLink] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Roles
-- Item: vwTaskTemplateItemRoles
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Template Item Roles
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskTemplateItemRole
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskTemplateItemRoles]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskTemplateItemRoles];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskTemplateItemRoles]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskTemplateItem_ItemID.[Name] AS [Item],
    mjBizAppsTasksTaskRole_RoleID.[Name] AS [Role]
FROM
    [${flyway:defaultSchema}].[TaskTemplateItemRole] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskTemplateItem] AS mjBizAppsTasksTaskTemplateItem_ItemID
  ON
    [t].[ItemID] = mjBizAppsTasksTaskTemplateItem_ItemID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskRole] AS mjBizAppsTasksTaskRole_RoleID
  ON
    [t].[RoleID] = mjBizAppsTasksTaskRole_RoleID.[ID]
GO
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemRoles] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemRoles] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemRoles] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemRoles] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Roles
-- Item: Permissions for vwTaskTemplateItemRoles
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemRoles] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemRoles] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemRoles] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItemRoles] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Roles
-- Item: spCreateTaskTemplateItemRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTemplateItemRole
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskTemplateItemRole]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTemplateItemRole];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTemplateItemRole]
    @ID uniqueidentifier = NULL,
    @ItemID uniqueidentifier,
    @RoleID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskTemplateItemRole]
            (
                [ID],
                [ItemID],
                [RoleID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @ItemID,
                @RoleID
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskTemplateItemRole]
            (
                [ItemID],
                [RoleID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ItemID,
                @RoleID
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskTemplateItemRoles] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItemRole] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItemRole] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItemRole] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Template Item Roles */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItemRole] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItemRole] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItemRole] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Roles
-- Item: spUpdateTaskTemplateItemRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTemplateItemRole
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskTemplateItemRole]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTemplateItemRole];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTemplateItemRole]
    @ID uniqueidentifier,
    @ItemID uniqueidentifier = NULL,
    @RoleID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTemplateItemRole]
    SET
        [ItemID] = ISNULL(@ItemID, [ItemID]),
        [RoleID] = ISNULL(@RoleID, [RoleID])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskTemplateItemRoles] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskTemplateItemRoles]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItemRole] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItemRole] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItemRole] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTemplateItemRole table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskTemplateItemRole]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskTemplateItemRole];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskTemplateItemRole
ON [${flyway:defaultSchema}].[TaskTemplateItemRole]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTemplateItemRole]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskTemplateItemRole] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Template Item Roles */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItemRole] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItemRole] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItemRole] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Roles
-- Item: spDeleteTaskTemplateItemRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTemplateItemRole
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskTemplateItemRole]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTemplateItemRole];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTemplateItemRole]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskTemplateItemRole]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItemRole] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItemRole] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItemRole] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Template Item Roles */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItemRole] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItemRole] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItemRole] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for TaskType */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key OnAssignActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnAssignActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnAssignActionID ON [${flyway:defaultSchema}].[TaskType] ([OnAssignActionID]);

-- Index for foreign key OnCompleteActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnCompleteActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnCompleteActionID ON [${flyway:defaultSchema}].[TaskType] ([OnCompleteActionID]);

-- Index for foreign key OnOverdueActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnOverdueActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnOverdueActionID ON [${flyway:defaultSchema}].[TaskType] ([OnOverdueActionID]);

-- Index for foreign key OnPercentChangeActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnPercentChangeActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnPercentChangeActionID ON [${flyway:defaultSchema}].[TaskType] ([OnPercentChangeActionID]);

-- Index for foreign key OnRejectActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnRejectActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnRejectActionID ON [${flyway:defaultSchema}].[TaskType] ([OnRejectActionID]);

-- Index for foreign key OnCancelActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnCancelActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnCancelActionID ON [${flyway:defaultSchema}].[TaskType] ([OnCancelActionID]);

-- Index for foreign key OnCreateActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnCreateActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnCreateActionID ON [${flyway:defaultSchema}].[TaskType] ([OnCreateActionID]);

-- Index for foreign key OnStatusChangeActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnStatusChangeActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnStatusChangeActionID ON [${flyway:defaultSchema}].[TaskType] ([OnStatusChangeActionID]);

/* Index for Foreign Keys for WorkReportItem */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Report Items
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key WorkReportID in table WorkReportItem
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_WorkReportItem_WorkReportID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[WorkReportItem]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_WorkReportItem_WorkReportID ON [${flyway:defaultSchema}].[WorkReportItem] ([WorkReportID]);

-- Index for foreign key TaskID in table WorkReportItem
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_WorkReportItem_TaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[WorkReportItem]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_WorkReportItem_TaskID ON [${flyway:defaultSchema}].[WorkReportItem] ([TaskID]);

/* SQL text to update entity field related entity name field map for entity field ID D7C0EEA5-0AB9-429C-A21E-B3B9D8E7161E */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='D7C0EEA5-0AB9-429C-A21E-B3B9D8E7161E', @RelatedEntityNameFieldMap='Task';

/* Index for Foreign Keys for WorkReport */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Reports
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key PersonID in table WorkReport
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_WorkReport_PersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[WorkReport]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_WorkReport_PersonID ON [${flyway:defaultSchema}].[WorkReport] ([PersonID]);

-- Index for foreign key AuthoredByAgentRunID in table WorkReport
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_WorkReport_AuthoredByAgentRunID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[WorkReport]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_WorkReport_AuthoredByAgentRunID ON [${flyway:defaultSchema}].[WorkReport] ([AuthoredByAgentRunID]);

-- Index for foreign key ReviewedByPersonID in table WorkReport
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_WorkReport_ReviewedByPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[WorkReport]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_WorkReport_ReviewedByPersonID ON [${flyway:defaultSchema}].[WorkReport] ([ReviewedByPersonID]);

/* SQL text to update entity field related entity name field map for entity field ID EB682468-BFE5-402F-9560-F97A34282275 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='EB682468-BFE5-402F-9560-F97A34282275', @RelatedEntityNameFieldMap='Person';

/* Base View SQL for MJ_BizApps_Tasks: Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: vwTaskTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Types
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskType
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskTypes]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskTypes];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskTypes]
AS
SELECT
    t.*,
    MJAction_OnAssignActionID.[Name] AS [OnAssignAction],
    MJAction_OnCompleteActionID.[Name] AS [OnCompleteAction],
    MJAction_OnOverdueActionID.[Name] AS [OnOverdueAction],
    MJAction_OnPercentChangeActionID.[Name] AS [OnPercentChangeAction],
    MJAction_OnRejectActionID.[Name] AS [OnRejectAction],
    MJAction_OnCancelActionID.[Name] AS [OnCancelAction],
    MJAction_OnCreateActionID.[Name] AS [OnCreateAction],
    MJAction_OnStatusChangeActionID.[Name] AS [OnStatusChangeAction]
FROM
    [${flyway:defaultSchema}].[TaskType] AS t
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnAssignActionID
  ON
    [t].[OnAssignActionID] = MJAction_OnAssignActionID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnCompleteActionID
  ON
    [t].[OnCompleteActionID] = MJAction_OnCompleteActionID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnOverdueActionID
  ON
    [t].[OnOverdueActionID] = MJAction_OnOverdueActionID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnPercentChangeActionID
  ON
    [t].[OnPercentChangeActionID] = MJAction_OnPercentChangeActionID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnRejectActionID
  ON
    [t].[OnRejectActionID] = MJAction_OnRejectActionID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnCancelActionID
  ON
    [t].[OnCancelActionID] = MJAction_OnCancelActionID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnCreateActionID
  ON
    [t].[OnCreateActionID] = MJAction_OnCreateActionID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnStatusChangeActionID
  ON
    [t].[OnStatusChangeActionID] = MJAction_OnStatusChangeActionID.[ID]
GO
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: Permissions for vwTaskTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: spCreateTaskType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskType]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(100),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @IconClass_Clear bit = 0,
    @IconClass nvarchar(100) = NULL,
    @DefaultPriority nvarchar(20) = NULL,
    @OnAssignActionID_Clear bit = 0,
    @OnAssignActionID uniqueidentifier = NULL,
    @OnCompleteActionID_Clear bit = 0,
    @OnCompleteActionID uniqueidentifier = NULL,
    @OnOverdueActionID_Clear bit = 0,
    @OnOverdueActionID uniqueidentifier = NULL,
    @OnPercentChangeActionID_Clear bit = 0,
    @OnPercentChangeActionID uniqueidentifier = NULL,
    @IsActive bit = NULL,
    @OnRejectActionID_Clear bit = 0,
    @OnRejectActionID uniqueidentifier = NULL,
    @OnCancelActionID_Clear bit = 0,
    @OnCancelActionID uniqueidentifier = NULL,
    @Code nvarchar(50),
    @OnCreateActionID_Clear bit = 0,
    @OnCreateActionID uniqueidentifier = NULL,
    @OnStatusChangeActionID_Clear bit = 0,
    @OnStatusChangeActionID uniqueidentifier = NULL,
    @IsApproval bit = NULL,
    @ExtensionEntity_Clear bit = 0,
    @ExtensionEntity nvarchar(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskType]
            (
                [ID],
                [Name],
                [Description],
                [IconClass],
                [DefaultPriority],
                [OnAssignActionID],
                [OnCompleteActionID],
                [OnOverdueActionID],
                [OnPercentChangeActionID],
                [IsActive],
                [OnRejectActionID],
                [OnCancelActionID],
                [Code],
                [OnCreateActionID],
                [OnStatusChangeActionID],
                [IsApproval],
                [ExtensionEntity]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, NULL) END,
                ISNULL(@DefaultPriority, 'Medium'),
                CASE WHEN @OnAssignActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnAssignActionID, NULL) END,
                CASE WHEN @OnCompleteActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCompleteActionID, NULL) END,
                CASE WHEN @OnOverdueActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnOverdueActionID, NULL) END,
                CASE WHEN @OnPercentChangeActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnPercentChangeActionID, NULL) END,
                ISNULL(@IsActive, 1),
                CASE WHEN @OnRejectActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnRejectActionID, NULL) END,
                CASE WHEN @OnCancelActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCancelActionID, NULL) END,
                @Code,
                CASE WHEN @OnCreateActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCreateActionID, NULL) END,
                CASE WHEN @OnStatusChangeActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnStatusChangeActionID, NULL) END,
                ISNULL(@IsApproval, 0),
                CASE WHEN @ExtensionEntity_Clear = 1 THEN NULL ELSE ISNULL(@ExtensionEntity, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskType]
            (
                [Name],
                [Description],
                [IconClass],
                [DefaultPriority],
                [OnAssignActionID],
                [OnCompleteActionID],
                [OnOverdueActionID],
                [OnPercentChangeActionID],
                [IsActive],
                [OnRejectActionID],
                [OnCancelActionID],
                [Code],
                [OnCreateActionID],
                [OnStatusChangeActionID],
                [IsApproval],
                [ExtensionEntity]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, NULL) END,
                ISNULL(@DefaultPriority, 'Medium'),
                CASE WHEN @OnAssignActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnAssignActionID, NULL) END,
                CASE WHEN @OnCompleteActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCompleteActionID, NULL) END,
                CASE WHEN @OnOverdueActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnOverdueActionID, NULL) END,
                CASE WHEN @OnPercentChangeActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnPercentChangeActionID, NULL) END,
                ISNULL(@IsActive, 1),
                CASE WHEN @OnRejectActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnRejectActionID, NULL) END,
                CASE WHEN @OnCancelActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCancelActionID, NULL) END,
                @Code,
                CASE WHEN @OnCreateActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCreateActionID, NULL) END,
                CASE WHEN @OnStatusChangeActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnStatusChangeActionID, NULL) END,
                ISNULL(@IsApproval, 0),
                CASE WHEN @ExtensionEntity_Clear = 1 THEN NULL ELSE ISNULL(@ExtensionEntity, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskTypes] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskType] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskType] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskType] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Types */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskType] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskType] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskType] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: spUpdateTaskType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskType]
    @ID uniqueidentifier,
    @Name nvarchar(100) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @IconClass_Clear bit = 0,
    @IconClass nvarchar(100) = NULL,
    @DefaultPriority nvarchar(20) = NULL,
    @OnAssignActionID_Clear bit = 0,
    @OnAssignActionID uniqueidentifier = NULL,
    @OnCompleteActionID_Clear bit = 0,
    @OnCompleteActionID uniqueidentifier = NULL,
    @OnOverdueActionID_Clear bit = 0,
    @OnOverdueActionID uniqueidentifier = NULL,
    @OnPercentChangeActionID_Clear bit = 0,
    @OnPercentChangeActionID uniqueidentifier = NULL,
    @IsActive bit = NULL,
    @OnRejectActionID_Clear bit = 0,
    @OnRejectActionID uniqueidentifier = NULL,
    @OnCancelActionID_Clear bit = 0,
    @OnCancelActionID uniqueidentifier = NULL,
    @Code nvarchar(50) = NULL,
    @OnCreateActionID_Clear bit = 0,
    @OnCreateActionID uniqueidentifier = NULL,
    @OnStatusChangeActionID_Clear bit = 0,
    @OnStatusChangeActionID uniqueidentifier = NULL,
    @IsApproval bit = NULL,
    @ExtensionEntity_Clear bit = 0,
    @ExtensionEntity nvarchar(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskType]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [IconClass] = CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, [IconClass]) END,
        [DefaultPriority] = ISNULL(@DefaultPriority, [DefaultPriority]),
        [OnAssignActionID] = CASE WHEN @OnAssignActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnAssignActionID, [OnAssignActionID]) END,
        [OnCompleteActionID] = CASE WHEN @OnCompleteActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCompleteActionID, [OnCompleteActionID]) END,
        [OnOverdueActionID] = CASE WHEN @OnOverdueActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnOverdueActionID, [OnOverdueActionID]) END,
        [OnPercentChangeActionID] = CASE WHEN @OnPercentChangeActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnPercentChangeActionID, [OnPercentChangeActionID]) END,
        [IsActive] = ISNULL(@IsActive, [IsActive]),
        [OnRejectActionID] = CASE WHEN @OnRejectActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnRejectActionID, [OnRejectActionID]) END,
        [OnCancelActionID] = CASE WHEN @OnCancelActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCancelActionID, [OnCancelActionID]) END,
        [Code] = ISNULL(@Code, [Code]),
        [OnCreateActionID] = CASE WHEN @OnCreateActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCreateActionID, [OnCreateActionID]) END,
        [OnStatusChangeActionID] = CASE WHEN @OnStatusChangeActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnStatusChangeActionID, [OnStatusChangeActionID]) END,
        [IsApproval] = ISNULL(@IsApproval, [IsApproval]),
        [ExtensionEntity] = CASE WHEN @ExtensionEntity_Clear = 1 THEN NULL ELSE ISNULL(@ExtensionEntity, [ExtensionEntity]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskTypes] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskTypes]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskType] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskType] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskType] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskType table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskType]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskType];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskType
ON [${flyway:defaultSchema}].[TaskType]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskType]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskType] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Types */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskType] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskType] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskType] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: spDeleteTaskType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskType]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskType]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskType] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskType] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskType] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Types */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskType] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskType] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskType] TO [cdp_Developer], [cdp_Integration];

/* Hierarchy Metadata Function SQL for MJ_BizApps_Tasks: Task Template Items.ParentItemID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: fnTaskTemplateItemParentItemID_GetHierarchyMeta
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- HIERARCHY METADATA FUNCTION FOR: [TaskTemplateItem].[ParentItemID]
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[fnTaskTemplateItemParentItemID_GetHierarchyMeta]', 'IF') IS NOT NULL
    DROP FUNCTION [${flyway:defaultSchema}].[fnTaskTemplateItemParentItemID_GetHierarchyMeta];
GO

CREATE FUNCTION [${flyway:defaultSchema}].[fnTaskTemplateItemParentItemID_GetHierarchyMeta]
(
    @RecordID uniqueidentifier,
    @ParentID uniqueidentifier
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE_Ancestors AS (
        SELECT
            [ID],
            [ParentItemID],
            0 AS [Depth],
            CAST('/' + CAST([ID] AS NVARCHAR(36)) + '/' AS NVARCHAR(MAX)) AS [Path]
        FROM
            [${flyway:defaultSchema}].[TaskTemplateItem]
        WHERE
            [ID] = @RecordID

        UNION ALL

        SELECT
            p.[ID],
            p.[ParentItemID],
            c.[Depth] + 1 AS [Depth],
            CAST('/' + CAST(p.[ID] AS NVARCHAR(36)) + c.[Path] AS NVARCHAR(MAX)) AS [Path]
        FROM
            [${flyway:defaultSchema}].[TaskTemplateItem] p
        INNER JOIN
            CTE_Ancestors c ON p.[ID] = c.[ParentItemID]
        WHERE
            c.[Depth] < 100
    )
    SELECT TOP 1
        a.[ID] AS [RootID],
        (SELECT MAX([Depth]) FROM CTE_Ancestors) AS [Depth],
        (SELECT TOP 1 [Path] FROM CTE_Ancestors ORDER BY [Depth] DESC) AS [Path],
        CAST(CASE WHEN EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[TaskTemplateItem] WHERE [ParentItemID] = @RecordID) THEN 0 ELSE 1 END AS BIT) AS [IsLeaf],
        (SELECT COUNT(1) FROM [${flyway:defaultSchema}].[TaskTemplateItem] WHERE [ParentItemID] = @RecordID) AS [ChildCount]
    FROM
        CTE_Ancestors a
    WHERE
        a.[ParentItemID] IS NULL OR @ParentID IS NULL
    ORDER BY
        a.[Depth] DESC
);
GO

/* Descendants Traversal Function SQL for MJ_BizApps_Tasks: Task Template Items.ParentItemID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: fnTaskTemplateItemParentItemID_GetDescendants
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- DESCENDANTS FUNCTION FOR: [TaskTemplateItem].[ParentItemID]
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[fnTaskTemplateItemParentItemID_GetDescendants]', 'IF') IS NOT NULL
    DROP FUNCTION [${flyway:defaultSchema}].[fnTaskTemplateItemParentItemID_GetDescendants];
GO

CREATE FUNCTION [${flyway:defaultSchema}].[fnTaskTemplateItemParentItemID_GetDescendants]
(
    @RootID uniqueidentifier,
    @MaxDepth INT = NULL
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE_Descendants AS (
        SELECT
            [ID],
            [ParentItemID],
            0 AS [RelativeDepth],
            CAST('/' + CAST([ID] AS NVARCHAR(36)) + '/' AS NVARCHAR(MAX)) AS [Path]
        FROM
            [${flyway:defaultSchema}].[TaskTemplateItem]
        WHERE
            [ID] = @RootID

        UNION ALL

        SELECT
            c.[ID],
            c.[ParentItemID],
            p.[RelativeDepth] + 1 AS [RelativeDepth],
            CAST(p.[Path] + CAST(c.[ID] AS NVARCHAR(36)) + '/' AS NVARCHAR(MAX)) AS [Path]
        FROM
            [${flyway:defaultSchema}].[TaskTemplateItem] c
        INNER JOIN
            CTE_Descendants p ON c.[ParentItemID] = p.[ID]
        WHERE
            (@MaxDepth IS NULL OR p.[RelativeDepth] < @MaxDepth)
            AND p.[RelativeDepth] < 100
    )
    SELECT
        d.[ID] AS [ID],
        d.[RelativeDepth] AS [Depth],
        d.[Path],
        CAST(CASE WHEN EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[TaskTemplateItem] WHERE [ParentItemID] = d.[ID]) THEN 0 ELSE 1 END AS BIT) AS [IsLeaf],
        (SELECT COUNT(1) FROM [${flyway:defaultSchema}].[TaskTemplateItem] WHERE [ParentItemID] = d.[ID]) AS [ChildCount]
    FROM
        CTE_Descendants d
);
GO

/* Ancestors Traversal Function SQL for MJ_BizApps_Tasks: Task Template Items.ParentItemID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: fnTaskTemplateItemParentItemID_GetAncestors
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- ANCESTORS FUNCTION FOR: [TaskTemplateItem].[ParentItemID]
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[fnTaskTemplateItemParentItemID_GetAncestors]', 'IF') IS NOT NULL
    DROP FUNCTION [${flyway:defaultSchema}].[fnTaskTemplateItemParentItemID_GetAncestors];
GO

CREATE FUNCTION [${flyway:defaultSchema}].[fnTaskTemplateItemParentItemID_GetAncestors]
(
    @RecordID uniqueidentifier
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE_Ancestors AS (
        SELECT
            [ID],
            [ParentItemID],
            0 AS [LevelUp],
            CAST('/' + CAST([ID] AS NVARCHAR(36)) + '/' AS NVARCHAR(MAX)) AS [Path]
        FROM
            [${flyway:defaultSchema}].[TaskTemplateItem]
        WHERE
            [ID] = @RecordID

        UNION ALL

        SELECT
            p.[ID],
            p.[ParentItemID],
            c.[LevelUp] + 1 AS [LevelUp],
            CAST('/' + CAST(p.[ID] AS NVARCHAR(36)) + c.[Path] AS NVARCHAR(MAX)) AS [Path]
        FROM
            [${flyway:defaultSchema}].[TaskTemplateItem] p
        INNER JOIN
            CTE_Ancestors c ON p.[ID] = c.[ParentItemID]
        WHERE
            c.[LevelUp] < 100
    )
    SELECT
        a.[ID] AS [ID],
        a.[LevelUp],
        a.[Path]
    FROM
        CTE_Ancestors a
);
GO

/* Root ID Function SQL for MJ_BizApps_Tasks: Task Template Items.ParentItemID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: fnTaskTemplateItemParentItemID_GetRootID
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- ROOT ID FUNCTION FOR: [TaskTemplateItem].[ParentItemID]
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[fnTaskTemplateItemParentItemID_GetRootID]', 'IF') IS NOT NULL
    DROP FUNCTION [${flyway:defaultSchema}].[fnTaskTemplateItemParentItemID_GetRootID];
GO

CREATE FUNCTION [${flyway:defaultSchema}].[fnTaskTemplateItemParentItemID_GetRootID]
(
    @RecordID uniqueidentifier,
    @ParentID uniqueidentifier
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE_RootParent AS (
        SELECT
            [ID],
            [ParentItemID],
            [ID] AS [RootParentID],
            0 AS [Depth]
        FROM
            [${flyway:defaultSchema}].[TaskTemplateItem]
        WHERE
            [ID] = COALESCE(@ParentID, @RecordID)

        UNION ALL

        SELECT
            c.[ID],
            c.[ParentItemID],
            c.[ID] AS [RootParentID],
            p.[Depth] + 1 AS [Depth]
        FROM
            [${flyway:defaultSchema}].[TaskTemplateItem] c
        INNER JOIN
            CTE_RootParent p ON c.[ID] = p.[ParentItemID]
        WHERE
            p.[Depth] < 100
    )
    SELECT TOP 1
        [RootParentID] AS RootID
    FROM
        CTE_RootParent
    WHERE
        [ParentItemID] IS NULL
    ORDER BY
        [RootParentID]
);
GO

/* Base View SQL for MJ_BizApps_Tasks: Task Template Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: vwTaskTemplateItems
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Template Items
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskTemplateItem
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskTemplateItems]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskTemplateItems];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskTemplateItems]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskTemplate_TemplateID.[Name] AS [Template],
    mjBizAppsTasksTaskTemplateItem_ParentItemID.[Name] AS [ParentItem],
    hier_ParentItemID.RootID AS [RootParentItemID],
    hier_ParentItemID.Depth AS [ParentItemIDDepth],
    hier_ParentItemID.Path AS [ParentItemIDPath],
    hier_ParentItemID.IsLeaf AS [ParentItemIDIsLeaf],
    hier_ParentItemID.ChildCount AS [ParentItemIDChildCount]
FROM
    [${flyway:defaultSchema}].[TaskTemplateItem] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskTemplate] AS mjBizAppsTasksTaskTemplate_TemplateID
  ON
    [t].[TemplateID] = mjBizAppsTasksTaskTemplate_TemplateID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskTemplateItem] AS mjBizAppsTasksTaskTemplateItem_ParentItemID
  ON
    [t].[ParentItemID] = mjBizAppsTasksTaskTemplateItem_ParentItemID.[ID]
OUTER APPLY
    [${flyway:defaultSchema}].[fnTaskTemplateItemParentItemID_GetHierarchyMeta]([t].[ID], [t].[ParentItemID]) AS hier_ParentItemID
GO
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItems] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItems] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItems] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItems] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Template Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: Permissions for vwTaskTemplateItems
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItems] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItems] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItems] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTemplateItems] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Template Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: spCreateTaskTemplateItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTemplateItem
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskTemplateItem]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTemplateItem];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTemplateItem]
    @ID uniqueidentifier = NULL,
    @TemplateID uniqueidentifier,
    @Name nvarchar(255),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @ParentItemID_Clear bit = 0,
    @ParentItemID uniqueidentifier = NULL,
    @Priority nvarchar(20) = NULL,
    @DaysFromStart_Clear bit = 0,
    @DaysFromStart int = NULL,
    @HoursEstimated_Clear bit = 0,
    @HoursEstimated decimal(8, 2) = NULL,
    @Sequence int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskTemplateItem]
            (
                [ID],
                [TemplateID],
                [Name],
                [Description],
                [ParentItemID],
                [Priority],
                [DaysFromStart],
                [HoursEstimated],
                [Sequence]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TemplateID,
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @ParentItemID_Clear = 1 THEN NULL ELSE ISNULL(@ParentItemID, NULL) END,
                ISNULL(@Priority, 'Medium'),
                CASE WHEN @DaysFromStart_Clear = 1 THEN NULL ELSE ISNULL(@DaysFromStart, NULL) END,
                CASE WHEN @HoursEstimated_Clear = 1 THEN NULL ELSE ISNULL(@HoursEstimated, NULL) END,
                ISNULL(@Sequence, 100)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskTemplateItem]
            (
                [TemplateID],
                [Name],
                [Description],
                [ParentItemID],
                [Priority],
                [DaysFromStart],
                [HoursEstimated],
                [Sequence]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TemplateID,
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @ParentItemID_Clear = 1 THEN NULL ELSE ISNULL(@ParentItemID, NULL) END,
                ISNULL(@Priority, 'Medium'),
                CASE WHEN @DaysFromStart_Clear = 1 THEN NULL ELSE ISNULL(@DaysFromStart, NULL) END,
                CASE WHEN @HoursEstimated_Clear = 1 THEN NULL ELSE ISNULL(@HoursEstimated, NULL) END,
                ISNULL(@Sequence, 100)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskTemplateItems] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItem] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItem] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItem] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Template Items */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItem] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItem] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItem] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Template Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: spUpdateTaskTemplateItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTemplateItem
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskTemplateItem]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTemplateItem];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTemplateItem]
    @ID uniqueidentifier,
    @TemplateID uniqueidentifier = NULL,
    @Name nvarchar(255) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @ParentItemID_Clear bit = 0,
    @ParentItemID uniqueidentifier = NULL,
    @Priority nvarchar(20) = NULL,
    @DaysFromStart_Clear bit = 0,
    @DaysFromStart int = NULL,
    @HoursEstimated_Clear bit = 0,
    @HoursEstimated decimal(8, 2) = NULL,
    @Sequence int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTemplateItem]
    SET
        [TemplateID] = ISNULL(@TemplateID, [TemplateID]),
        [Name] = ISNULL(@Name, [Name]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [ParentItemID] = CASE WHEN @ParentItemID_Clear = 1 THEN NULL ELSE ISNULL(@ParentItemID, [ParentItemID]) END,
        [Priority] = ISNULL(@Priority, [Priority]),
        [DaysFromStart] = CASE WHEN @DaysFromStart_Clear = 1 THEN NULL ELSE ISNULL(@DaysFromStart, [DaysFromStart]) END,
        [HoursEstimated] = CASE WHEN @HoursEstimated_Clear = 1 THEN NULL ELSE ISNULL(@HoursEstimated, [HoursEstimated]) END,
        [Sequence] = ISNULL(@Sequence, [Sequence])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskTemplateItems] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskTemplateItems]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItem] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItem] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItem] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTemplateItem table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskTemplateItem]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskTemplateItem];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskTemplateItem
ON [${flyway:defaultSchema}].[TaskTemplateItem]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTemplateItem]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskTemplateItem] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Template Items */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItem] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItem] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplateItem] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Template Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: spDeleteTaskTemplateItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTemplateItem
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskTemplateItem]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTemplateItem];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTemplateItem]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskTemplateItem]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItem] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItem] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItem] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Template Items */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItem] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItem] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItem] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: vwTasksGenerated
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Tasks
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  Task
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTasksGenerated]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTasksGenerated];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTasksGenerated]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskType_TypeID.[Name] AS [Type],
    mjBizAppsTasksTaskCategory_CategoryID.[Name] AS [Category],
    mjBizAppsTasksTask_ParentID.[Name] AS [Parent],
    mjBizAppsCommonPerson_CreatedByPersonID.[DisplayName] AS [CreatedByPerson],
    mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID.[Name] AS [TaskTypeStatus]
FROM
    [${flyway:defaultSchema}].[Task] AS t
INNER JOIN
    [${flyway:defaultSchema}].[TaskType] AS mjBizAppsTasksTaskType_TypeID
  ON
    [t].[TypeID] = mjBizAppsTasksTaskType_TypeID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskCategory] AS mjBizAppsTasksTaskCategory_CategoryID
  ON
    [t].[CategoryID] = mjBizAppsTasksTaskCategory_CategoryID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_ParentID
  ON
    [t].[ParentID] = mjBizAppsTasksTask_ParentID.[ID]
LEFT OUTER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_CreatedByPersonID
  ON
    [t].[CreatedByPersonID] = mjBizAppsCommonPerson_CreatedByPersonID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskTypeStatus] AS mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID
  ON
    [t].[TaskTypeStatusID] = mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID.[ID]
GO
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTasks]', 'V') IS NOT NULL
BEGIN
    EXEC sp_executesql N'REVOKE SELECT ON [${flyway:defaultSchema}].[vwTasks] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTasks] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTasks] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTasks] TO [cdp_UI], [cdp_Developer], [cdp_Integration]';
END;

/* Refresh layered base view for MJ_BizApps_Tasks: Tasks after its inner view changed */
EXEC sp_refreshview '${flyway:defaultSchema}.vwTasksGenerated';
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTasks]', 'V') IS NOT NULL
BEGIN
    EXEC sp_executesql N'EXEC sp_refreshview ''${flyway:defaultSchema}.vwTasks'';';
END

GO

/* Base View Permissions SQL for MJ_BizApps_Tasks: Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: Permissions for vwTasks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

IF OBJECT_ID('[${flyway:defaultSchema}].[vwTasks]', 'V') IS NOT NULL
BEGIN
    EXEC sp_executesql N'REVOKE SELECT ON [${flyway:defaultSchema}].[vwTasks] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTasks] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTasks] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTasks] TO [cdp_UI], [cdp_Developer], [cdp_Integration]';
END;

/* spCreate SQL for MJ_BizApps_Tasks: Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: spCreateTask
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Task
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTask]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTask];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTask]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(255),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @TypeID uniqueidentifier,
    @CategoryID_Clear bit = 0,
    @CategoryID uniqueidentifier = NULL,
    @ParentID_Clear bit = 0,
    @ParentID uniqueidentifier = NULL,
    @Status nvarchar(50) = NULL,
    @Priority nvarchar(20) = NULL,
    @StartedAt_Clear bit = 0,
    @StartedAt datetimeoffset = NULL,
    @DueAt_Clear bit = 0,
    @DueAt datetimeoffset = NULL,
    @CompletedAt_Clear bit = 0,
    @CompletedAt datetimeoffset = NULL,
    @HoursEstimated_Clear bit = 0,
    @HoursEstimated decimal(8, 2) = NULL,
    @HoursActual_Clear bit = 0,
    @HoursActual decimal(8, 2) = NULL,
    @PercentComplete int = NULL,
    @Sequence int = NULL,
    @BlockedReason_Clear bit = 0,
    @BlockedReason nvarchar(MAX) = NULL,
    @CompletionNotes_Clear bit = 0,
    @CompletionNotes nvarchar(MAX) = NULL,
    @CreatedByPersonID_Clear bit = 0,
    @CreatedByPersonID uniqueidentifier = NULL,
    @OverdueNotifiedAt_Clear bit = 0,
    @OverdueNotifiedAt datetimeoffset = NULL,
    @TaskTypeStatusID_Clear bit = 0,
    @TaskTypeStatusID uniqueidentifier = NULL,
    @PredictedSLABreachProbability_Clear bit = 0,
    @PredictedSLABreachProbability decimal(5, 4) = NULL,
    @PredictedSLARiskBand_Clear bit = 0,
    @PredictedSLARiskBand nvarchar(20) = NULL,
    @PredictedSLAScoredAt_Clear bit = 0,
    @PredictedSLAScoredAt datetimeoffset = NULL,
    @HealthStatus_Clear bit = 0,
    @HealthStatus nvarchar(20) = NULL,
    @ConfidenceScore_Clear bit = 0,
    @ConfidenceScore int = NULL,
    @BaselineValue_Clear bit = 0,
    @BaselineValue decimal(18, 4) = NULL,
    @TargetValue_Clear bit = 0,
    @TargetValue decimal(18, 4) = NULL,
    @CurrentValue_Clear bit = 0,
    @CurrentValue decimal(18, 4) = NULL,
    @UnitOfMeasure_Clear bit = 0,
    @UnitOfMeasure nvarchar(50) = NULL,
    @MetricDirection_Clear bit = 0,
    @MetricDirection nvarchar(20) = NULL,
    @RollupWeight decimal(8, 2) = NULL,
    @PlanningPeriod_Clear bit = 0,
    @PlanningPeriod nvarchar(50) = NULL,
    @CheckInCadence_Clear bit = 0,
    @CheckInCadence nvarchar(20) = NULL,
    @LastCheckInAt_Clear bit = 0,
    @LastCheckInAt datetimeoffset = NULL,
    @NextCheckInDueAt_Clear bit = 0,
    @NextCheckInDueAt datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[Task]
            (
                [ID],
                [Name],
                [Description],
                [TypeID],
                [CategoryID],
                [ParentID],
                [Status],
                [Priority],
                [StartedAt],
                [DueAt],
                [CompletedAt],
                [HoursEstimated],
                [HoursActual],
                [PercentComplete],
                [Sequence],
                [BlockedReason],
                [CompletionNotes],
                [CreatedByPersonID],
                [OverdueNotifiedAt],
                [TaskTypeStatusID],
                [PredictedSLABreachProbability],
                [PredictedSLARiskBand],
                [PredictedSLAScoredAt],
                [HealthStatus],
                [ConfidenceScore],
                [BaselineValue],
                [TargetValue],
                [CurrentValue],
                [UnitOfMeasure],
                [MetricDirection],
                [RollupWeight],
                [PlanningPeriod],
                [CheckInCadence],
                [LastCheckInAt],
                [NextCheckInDueAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                @TypeID,
                CASE WHEN @CategoryID_Clear = 1 THEN NULL ELSE ISNULL(@CategoryID, NULL) END,
                CASE WHEN @ParentID_Clear = 1 THEN NULL ELSE ISNULL(@ParentID, NULL) END,
                ISNULL(@Status, 'Open'),
                ISNULL(@Priority, 'Medium'),
                CASE WHEN @StartedAt_Clear = 1 THEN NULL ELSE ISNULL(@StartedAt, NULL) END,
                CASE WHEN @DueAt_Clear = 1 THEN NULL ELSE ISNULL(@DueAt, NULL) END,
                CASE WHEN @CompletedAt_Clear = 1 THEN NULL ELSE ISNULL(@CompletedAt, NULL) END,
                CASE WHEN @HoursEstimated_Clear = 1 THEN NULL ELSE ISNULL(@HoursEstimated, NULL) END,
                CASE WHEN @HoursActual_Clear = 1 THEN NULL ELSE ISNULL(@HoursActual, NULL) END,
                ISNULL(@PercentComplete, 0),
                ISNULL(@Sequence, 100),
                CASE WHEN @BlockedReason_Clear = 1 THEN NULL ELSE ISNULL(@BlockedReason, NULL) END,
                CASE WHEN @CompletionNotes_Clear = 1 THEN NULL ELSE ISNULL(@CompletionNotes, NULL) END,
                CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, NULL) END,
                CASE WHEN @OverdueNotifiedAt_Clear = 1 THEN NULL ELSE ISNULL(@OverdueNotifiedAt, NULL) END,
                CASE WHEN @TaskTypeStatusID_Clear = 1 THEN NULL ELSE ISNULL(@TaskTypeStatusID, NULL) END,
                CASE WHEN @PredictedSLABreachProbability_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLABreachProbability, NULL) END,
                CASE WHEN @PredictedSLARiskBand_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLARiskBand, NULL) END,
                CASE WHEN @PredictedSLAScoredAt_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLAScoredAt, NULL) END,
                CASE WHEN @HealthStatus_Clear = 1 THEN NULL ELSE ISNULL(@HealthStatus, NULL) END,
                CASE WHEN @ConfidenceScore_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceScore, NULL) END,
                CASE WHEN @BaselineValue_Clear = 1 THEN NULL ELSE ISNULL(@BaselineValue, NULL) END,
                CASE WHEN @TargetValue_Clear = 1 THEN NULL ELSE ISNULL(@TargetValue, NULL) END,
                CASE WHEN @CurrentValue_Clear = 1 THEN NULL ELSE ISNULL(@CurrentValue, NULL) END,
                CASE WHEN @UnitOfMeasure_Clear = 1 THEN NULL ELSE ISNULL(@UnitOfMeasure, NULL) END,
                CASE WHEN @MetricDirection_Clear = 1 THEN NULL ELSE ISNULL(@MetricDirection, NULL) END,
                ISNULL(@RollupWeight, 1.00),
                CASE WHEN @PlanningPeriod_Clear = 1 THEN NULL ELSE ISNULL(@PlanningPeriod, NULL) END,
                CASE WHEN @CheckInCadence_Clear = 1 THEN NULL ELSE ISNULL(@CheckInCadence, NULL) END,
                CASE WHEN @LastCheckInAt_Clear = 1 THEN NULL ELSE ISNULL(@LastCheckInAt, NULL) END,
                CASE WHEN @NextCheckInDueAt_Clear = 1 THEN NULL ELSE ISNULL(@NextCheckInDueAt, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[Task]
            (
                [Name],
                [Description],
                [TypeID],
                [CategoryID],
                [ParentID],
                [Status],
                [Priority],
                [StartedAt],
                [DueAt],
                [CompletedAt],
                [HoursEstimated],
                [HoursActual],
                [PercentComplete],
                [Sequence],
                [BlockedReason],
                [CompletionNotes],
                [CreatedByPersonID],
                [OverdueNotifiedAt],
                [TaskTypeStatusID],
                [PredictedSLABreachProbability],
                [PredictedSLARiskBand],
                [PredictedSLAScoredAt],
                [HealthStatus],
                [ConfidenceScore],
                [BaselineValue],
                [TargetValue],
                [CurrentValue],
                [UnitOfMeasure],
                [MetricDirection],
                [RollupWeight],
                [PlanningPeriod],
                [CheckInCadence],
                [LastCheckInAt],
                [NextCheckInDueAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                @TypeID,
                CASE WHEN @CategoryID_Clear = 1 THEN NULL ELSE ISNULL(@CategoryID, NULL) END,
                CASE WHEN @ParentID_Clear = 1 THEN NULL ELSE ISNULL(@ParentID, NULL) END,
                ISNULL(@Status, 'Open'),
                ISNULL(@Priority, 'Medium'),
                CASE WHEN @StartedAt_Clear = 1 THEN NULL ELSE ISNULL(@StartedAt, NULL) END,
                CASE WHEN @DueAt_Clear = 1 THEN NULL ELSE ISNULL(@DueAt, NULL) END,
                CASE WHEN @CompletedAt_Clear = 1 THEN NULL ELSE ISNULL(@CompletedAt, NULL) END,
                CASE WHEN @HoursEstimated_Clear = 1 THEN NULL ELSE ISNULL(@HoursEstimated, NULL) END,
                CASE WHEN @HoursActual_Clear = 1 THEN NULL ELSE ISNULL(@HoursActual, NULL) END,
                ISNULL(@PercentComplete, 0),
                ISNULL(@Sequence, 100),
                CASE WHEN @BlockedReason_Clear = 1 THEN NULL ELSE ISNULL(@BlockedReason, NULL) END,
                CASE WHEN @CompletionNotes_Clear = 1 THEN NULL ELSE ISNULL(@CompletionNotes, NULL) END,
                CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, NULL) END,
                CASE WHEN @OverdueNotifiedAt_Clear = 1 THEN NULL ELSE ISNULL(@OverdueNotifiedAt, NULL) END,
                CASE WHEN @TaskTypeStatusID_Clear = 1 THEN NULL ELSE ISNULL(@TaskTypeStatusID, NULL) END,
                CASE WHEN @PredictedSLABreachProbability_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLABreachProbability, NULL) END,
                CASE WHEN @PredictedSLARiskBand_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLARiskBand, NULL) END,
                CASE WHEN @PredictedSLAScoredAt_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLAScoredAt, NULL) END,
                CASE WHEN @HealthStatus_Clear = 1 THEN NULL ELSE ISNULL(@HealthStatus, NULL) END,
                CASE WHEN @ConfidenceScore_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceScore, NULL) END,
                CASE WHEN @BaselineValue_Clear = 1 THEN NULL ELSE ISNULL(@BaselineValue, NULL) END,
                CASE WHEN @TargetValue_Clear = 1 THEN NULL ELSE ISNULL(@TargetValue, NULL) END,
                CASE WHEN @CurrentValue_Clear = 1 THEN NULL ELSE ISNULL(@CurrentValue, NULL) END,
                CASE WHEN @UnitOfMeasure_Clear = 1 THEN NULL ELSE ISNULL(@UnitOfMeasure, NULL) END,
                CASE WHEN @MetricDirection_Clear = 1 THEN NULL ELSE ISNULL(@MetricDirection, NULL) END,
                ISNULL(@RollupWeight, 1.00),
                CASE WHEN @PlanningPeriod_Clear = 1 THEN NULL ELSE ISNULL(@PlanningPeriod, NULL) END,
                CASE WHEN @CheckInCadence_Clear = 1 THEN NULL ELSE ISNULL(@CheckInCadence, NULL) END,
                CASE WHEN @LastCheckInAt_Clear = 1 THEN NULL ELSE ISNULL(@LastCheckInAt, NULL) END,
                CASE WHEN @NextCheckInDueAt_Clear = 1 THEN NULL ELSE ISNULL(@NextCheckInDueAt, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTasks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Integration]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_UI]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Tasks */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Integration]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_UI]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: spUpdateTask
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Task
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTask]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTask];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTask]
    @ID uniqueidentifier,
    @Name nvarchar(255) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @TypeID uniqueidentifier = NULL,
    @CategoryID_Clear bit = 0,
    @CategoryID uniqueidentifier = NULL,
    @ParentID_Clear bit = 0,
    @ParentID uniqueidentifier = NULL,
    @Status nvarchar(50) = NULL,
    @Priority nvarchar(20) = NULL,
    @StartedAt_Clear bit = 0,
    @StartedAt datetimeoffset = NULL,
    @DueAt_Clear bit = 0,
    @DueAt datetimeoffset = NULL,
    @CompletedAt_Clear bit = 0,
    @CompletedAt datetimeoffset = NULL,
    @HoursEstimated_Clear bit = 0,
    @HoursEstimated decimal(8, 2) = NULL,
    @HoursActual_Clear bit = 0,
    @HoursActual decimal(8, 2) = NULL,
    @PercentComplete int = NULL,
    @Sequence int = NULL,
    @BlockedReason_Clear bit = 0,
    @BlockedReason nvarchar(MAX) = NULL,
    @CompletionNotes_Clear bit = 0,
    @CompletionNotes nvarchar(MAX) = NULL,
    @CreatedByPersonID_Clear bit = 0,
    @CreatedByPersonID uniqueidentifier = NULL,
    @OverdueNotifiedAt_Clear bit = 0,
    @OverdueNotifiedAt datetimeoffset = NULL,
    @TaskTypeStatusID_Clear bit = 0,
    @TaskTypeStatusID uniqueidentifier = NULL,
    @PredictedSLABreachProbability_Clear bit = 0,
    @PredictedSLABreachProbability decimal(5, 4) = NULL,
    @PredictedSLARiskBand_Clear bit = 0,
    @PredictedSLARiskBand nvarchar(20) = NULL,
    @PredictedSLAScoredAt_Clear bit = 0,
    @PredictedSLAScoredAt datetimeoffset = NULL,
    @HealthStatus_Clear bit = 0,
    @HealthStatus nvarchar(20) = NULL,
    @ConfidenceScore_Clear bit = 0,
    @ConfidenceScore int = NULL,
    @BaselineValue_Clear bit = 0,
    @BaselineValue decimal(18, 4) = NULL,
    @TargetValue_Clear bit = 0,
    @TargetValue decimal(18, 4) = NULL,
    @CurrentValue_Clear bit = 0,
    @CurrentValue decimal(18, 4) = NULL,
    @UnitOfMeasure_Clear bit = 0,
    @UnitOfMeasure nvarchar(50) = NULL,
    @MetricDirection_Clear bit = 0,
    @MetricDirection nvarchar(20) = NULL,
    @RollupWeight decimal(8, 2) = NULL,
    @PlanningPeriod_Clear bit = 0,
    @PlanningPeriod nvarchar(50) = NULL,
    @CheckInCadence_Clear bit = 0,
    @CheckInCadence nvarchar(20) = NULL,
    @LastCheckInAt_Clear bit = 0,
    @LastCheckInAt datetimeoffset = NULL,
    @NextCheckInDueAt_Clear bit = 0,
    @NextCheckInDueAt datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[Task]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [TypeID] = ISNULL(@TypeID, [TypeID]),
        [CategoryID] = CASE WHEN @CategoryID_Clear = 1 THEN NULL ELSE ISNULL(@CategoryID, [CategoryID]) END,
        [ParentID] = CASE WHEN @ParentID_Clear = 1 THEN NULL ELSE ISNULL(@ParentID, [ParentID]) END,
        [Status] = ISNULL(@Status, [Status]),
        [Priority] = ISNULL(@Priority, [Priority]),
        [StartedAt] = CASE WHEN @StartedAt_Clear = 1 THEN NULL ELSE ISNULL(@StartedAt, [StartedAt]) END,
        [DueAt] = CASE WHEN @DueAt_Clear = 1 THEN NULL ELSE ISNULL(@DueAt, [DueAt]) END,
        [CompletedAt] = CASE WHEN @CompletedAt_Clear = 1 THEN NULL ELSE ISNULL(@CompletedAt, [CompletedAt]) END,
        [HoursEstimated] = CASE WHEN @HoursEstimated_Clear = 1 THEN NULL ELSE ISNULL(@HoursEstimated, [HoursEstimated]) END,
        [HoursActual] = CASE WHEN @HoursActual_Clear = 1 THEN NULL ELSE ISNULL(@HoursActual, [HoursActual]) END,
        [PercentComplete] = ISNULL(@PercentComplete, [PercentComplete]),
        [Sequence] = ISNULL(@Sequence, [Sequence]),
        [BlockedReason] = CASE WHEN @BlockedReason_Clear = 1 THEN NULL ELSE ISNULL(@BlockedReason, [BlockedReason]) END,
        [CompletionNotes] = CASE WHEN @CompletionNotes_Clear = 1 THEN NULL ELSE ISNULL(@CompletionNotes, [CompletionNotes]) END,
        [CreatedByPersonID] = CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, [CreatedByPersonID]) END,
        [OverdueNotifiedAt] = CASE WHEN @OverdueNotifiedAt_Clear = 1 THEN NULL ELSE ISNULL(@OverdueNotifiedAt, [OverdueNotifiedAt]) END,
        [TaskTypeStatusID] = CASE WHEN @TaskTypeStatusID_Clear = 1 THEN NULL ELSE ISNULL(@TaskTypeStatusID, [TaskTypeStatusID]) END,
        [PredictedSLABreachProbability] = CASE WHEN @PredictedSLABreachProbability_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLABreachProbability, [PredictedSLABreachProbability]) END,
        [PredictedSLARiskBand] = CASE WHEN @PredictedSLARiskBand_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLARiskBand, [PredictedSLARiskBand]) END,
        [PredictedSLAScoredAt] = CASE WHEN @PredictedSLAScoredAt_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLAScoredAt, [PredictedSLAScoredAt]) END,
        [HealthStatus] = CASE WHEN @HealthStatus_Clear = 1 THEN NULL ELSE ISNULL(@HealthStatus, [HealthStatus]) END,
        [ConfidenceScore] = CASE WHEN @ConfidenceScore_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceScore, [ConfidenceScore]) END,
        [BaselineValue] = CASE WHEN @BaselineValue_Clear = 1 THEN NULL ELSE ISNULL(@BaselineValue, [BaselineValue]) END,
        [TargetValue] = CASE WHEN @TargetValue_Clear = 1 THEN NULL ELSE ISNULL(@TargetValue, [TargetValue]) END,
        [CurrentValue] = CASE WHEN @CurrentValue_Clear = 1 THEN NULL ELSE ISNULL(@CurrentValue, [CurrentValue]) END,
        [UnitOfMeasure] = CASE WHEN @UnitOfMeasure_Clear = 1 THEN NULL ELSE ISNULL(@UnitOfMeasure, [UnitOfMeasure]) END,
        [MetricDirection] = CASE WHEN @MetricDirection_Clear = 1 THEN NULL ELSE ISNULL(@MetricDirection, [MetricDirection]) END,
        [RollupWeight] = ISNULL(@RollupWeight, [RollupWeight]),
        [PlanningPeriod] = CASE WHEN @PlanningPeriod_Clear = 1 THEN NULL ELSE ISNULL(@PlanningPeriod, [PlanningPeriod]) END,
        [CheckInCadence] = CASE WHEN @CheckInCadence_Clear = 1 THEN NULL ELSE ISNULL(@CheckInCadence, [CheckInCadence]) END,
        [LastCheckInAt] = CASE WHEN @LastCheckInAt_Clear = 1 THEN NULL ELSE ISNULL(@LastCheckInAt, [LastCheckInAt]) END,
        [NextCheckInDueAt] = CASE WHEN @NextCheckInDueAt_Clear = 1 THEN NULL ELSE ISNULL(@NextCheckInDueAt, [NextCheckInDueAt]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTasks] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTasks]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_Integration]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_UI]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] TO [cdp_UI], [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Task table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTask]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTask];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTask
ON [${flyway:defaultSchema}].[Task]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[Task]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[Task] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Tasks */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_Integration]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_UI]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: spDeleteTask
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Task
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTask]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTask];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTask]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[Task]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Tasks */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Task Type Status */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: vwTaskTypeStatus
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Type Status
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskTypeStatus
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskTypeStatus]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskTypeStatus];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskTypeStatus]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskType_TaskTypeID.[Name] AS [TaskType],
    MJAction_OnEnterActionID.[Name] AS [OnEnterAction],
    MJAction_OnExitActionID.[Name] AS [OnExitAction]
FROM
    [${flyway:defaultSchema}].[TaskTypeStatus] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskType] AS mjBizAppsTasksTaskType_TaskTypeID
  ON
    [t].[TaskTypeID] = mjBizAppsTasksTaskType_TaskTypeID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnEnterActionID
  ON
    [t].[OnEnterActionID] = MJAction_OnEnterActionID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnExitActionID
  ON
    [t].[OnExitActionID] = MJAction_OnExitActionID.[ID]
GO
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypeStatus] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypeStatus] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypeStatus] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTypeStatus] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Type Status */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: Permissions for vwTaskTypeStatus
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypeStatus] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypeStatus] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypeStatus] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTypeStatus] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Type Status */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: spCreateTaskTypeStatus
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTypeStatus
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskTypeStatus]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTypeStatus];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTypeStatus]
    @ID uniqueidentifier = NULL,
    @TaskTypeID uniqueidentifier,
    @Name nvarchar(100),
    @Code nvarchar(50),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @MacroStatus nvarchar(20) = NULL,
    @Sequence int = NULL,
    @IsDefault bit = NULL,
    @IsTerminal bit = NULL,
    @Color_Clear bit = 0,
    @Color nvarchar(50) = NULL,
    @IconClass_Clear bit = 0,
    @IconClass nvarchar(100) = NULL,
    @OnEnterActionID_Clear bit = 0,
    @OnEnterActionID uniqueidentifier = NULL,
    @OnExitActionID_Clear bit = 0,
    @OnExitActionID uniqueidentifier = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskTypeStatus]
            (
                [ID],
                [TaskTypeID],
                [Name],
                [Code],
                [Description],
                [MacroStatus],
                [Sequence],
                [IsDefault],
                [IsTerminal],
                [Color],
                [IconClass],
                [OnEnterActionID],
                [OnExitActionID],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaskTypeID,
                @Name,
                @Code,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                ISNULL(@MacroStatus, 'Open'),
                ISNULL(@Sequence, 100),
                ISNULL(@IsDefault, 0),
                ISNULL(@IsTerminal, 0),
                CASE WHEN @Color_Clear = 1 THEN NULL ELSE ISNULL(@Color, NULL) END,
                CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, NULL) END,
                CASE WHEN @OnEnterActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnEnterActionID, NULL) END,
                CASE WHEN @OnExitActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnExitActionID, NULL) END,
                ISNULL(@IsActive, 1)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskTypeStatus]
            (
                [TaskTypeID],
                [Name],
                [Code],
                [Description],
                [MacroStatus],
                [Sequence],
                [IsDefault],
                [IsTerminal],
                [Color],
                [IconClass],
                [OnEnterActionID],
                [OnExitActionID],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaskTypeID,
                @Name,
                @Code,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                ISNULL(@MacroStatus, 'Open'),
                ISNULL(@Sequence, 100),
                ISNULL(@IsDefault, 0),
                ISNULL(@IsTerminal, 0),
                CASE WHEN @Color_Clear = 1 THEN NULL ELSE ISNULL(@Color, NULL) END,
                CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, NULL) END,
                CASE WHEN @OnEnterActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnEnterActionID, NULL) END,
                CASE WHEN @OnExitActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnExitActionID, NULL) END,
                ISNULL(@IsActive, 1)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskTypeStatus] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTypeStatus] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTypeStatus] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTypeStatus] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Type Status */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTypeStatus] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTypeStatus] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTypeStatus] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Type Status */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: spUpdateTaskTypeStatus
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTypeStatus
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskTypeStatus]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTypeStatus];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTypeStatus]
    @ID uniqueidentifier,
    @TaskTypeID uniqueidentifier = NULL,
    @Name nvarchar(100) = NULL,
    @Code nvarchar(50) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @MacroStatus nvarchar(20) = NULL,
    @Sequence int = NULL,
    @IsDefault bit = NULL,
    @IsTerminal bit = NULL,
    @Color_Clear bit = 0,
    @Color nvarchar(50) = NULL,
    @IconClass_Clear bit = 0,
    @IconClass nvarchar(100) = NULL,
    @OnEnterActionID_Clear bit = 0,
    @OnEnterActionID uniqueidentifier = NULL,
    @OnExitActionID_Clear bit = 0,
    @OnExitActionID uniqueidentifier = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTypeStatus]
    SET
        [TaskTypeID] = ISNULL(@TaskTypeID, [TaskTypeID]),
        [Name] = ISNULL(@Name, [Name]),
        [Code] = ISNULL(@Code, [Code]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [MacroStatus] = ISNULL(@MacroStatus, [MacroStatus]),
        [Sequence] = ISNULL(@Sequence, [Sequence]),
        [IsDefault] = ISNULL(@IsDefault, [IsDefault]),
        [IsTerminal] = ISNULL(@IsTerminal, [IsTerminal]),
        [Color] = CASE WHEN @Color_Clear = 1 THEN NULL ELSE ISNULL(@Color, [Color]) END,
        [IconClass] = CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, [IconClass]) END,
        [OnEnterActionID] = CASE WHEN @OnEnterActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnEnterActionID, [OnEnterActionID]) END,
        [OnExitActionID] = CASE WHEN @OnExitActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnExitActionID, [OnExitActionID]) END,
        [IsActive] = ISNULL(@IsActive, [IsActive])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskTypeStatus] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskTypeStatus]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTypeStatus] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTypeStatus] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTypeStatus] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTypeStatus table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskTypeStatus]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskTypeStatus];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskTypeStatus
ON [${flyway:defaultSchema}].[TaskTypeStatus]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTypeStatus]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskTypeStatus] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Type Status */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTypeStatus] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTypeStatus] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTypeStatus] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Type Status */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: spDeleteTaskTypeStatus
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTypeStatus
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskTypeStatus]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTypeStatus];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTypeStatus]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskTypeStatus]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTypeStatus] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTypeStatus] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTypeStatus] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Type Status */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTypeStatus] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTypeStatus] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTypeStatus] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Work Report Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Report Items
-- Item: vwWorkReportItems
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Work Report Items
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  WorkReportItem
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwWorkReportItems]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwWorkReportItems];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwWorkReportItems]
AS
SELECT
    w.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task]
FROM
    [${flyway:defaultSchema}].[WorkReportItem] AS w
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [w].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwWorkReportItems] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Work Report Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Report Items
-- Item: Permissions for vwWorkReportItems
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwWorkReportItems] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Work Report Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Report Items
-- Item: spCreateWorkReportItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR WorkReportItem
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateWorkReportItem]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateWorkReportItem];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateWorkReportItem]
    @ID uniqueidentifier = NULL,
    @WorkReportID uniqueidentifier,
    @TaskID_Clear bit = 0,
    @TaskID uniqueidentifier = NULL,
    @Section nvarchar(50) = NULL,
    @Summary nvarchar(MAX),
    @Sequence int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[WorkReportItem]
            (
                [ID],
                [WorkReportID],
                [TaskID],
                [Section],
                [Summary],
                [Sequence]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @WorkReportID,
                CASE WHEN @TaskID_Clear = 1 THEN NULL ELSE ISNULL(@TaskID, NULL) END,
                ISNULL(@Section, 'Completed'),
                @Summary,
                ISNULL(@Sequence, 0)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[WorkReportItem]
            (
                [WorkReportID],
                [TaskID],
                [Section],
                [Summary],
                [Sequence]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @WorkReportID,
                CASE WHEN @TaskID_Clear = 1 THEN NULL ELSE ISNULL(@TaskID, NULL) END,
                ISNULL(@Section, 'Completed'),
                @Summary,
                ISNULL(@Sequence, 0)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwWorkReportItems] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateWorkReportItem] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Work Report Items */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateWorkReportItem] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Work Report Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Report Items
-- Item: spUpdateWorkReportItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR WorkReportItem
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateWorkReportItem]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateWorkReportItem];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateWorkReportItem]
    @ID uniqueidentifier,
    @WorkReportID uniqueidentifier = NULL,
    @TaskID_Clear bit = 0,
    @TaskID uniqueidentifier = NULL,
    @Section nvarchar(50) = NULL,
    @Summary nvarchar(MAX) = NULL,
    @Sequence int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[WorkReportItem]
    SET
        [WorkReportID] = ISNULL(@WorkReportID, [WorkReportID]),
        [TaskID] = CASE WHEN @TaskID_Clear = 1 THEN NULL ELSE ISNULL(@TaskID, [TaskID]) END,
        [Section] = ISNULL(@Section, [Section]),
        [Summary] = ISNULL(@Summary, [Summary]),
        [Sequence] = ISNULL(@Sequence, [Sequence])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwWorkReportItems] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwWorkReportItems]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateWorkReportItem] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the WorkReportItem table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateWorkReportItem]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateWorkReportItem];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateWorkReportItem
ON [${flyway:defaultSchema}].[WorkReportItem]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[WorkReportItem]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[WorkReportItem] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Work Report Items */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateWorkReportItem] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Work Report Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Report Items
-- Item: spDeleteWorkReportItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR WorkReportItem
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteWorkReportItem]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteWorkReportItem];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteWorkReportItem]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[WorkReportItem]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteWorkReportItem] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Work Report Items */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteWorkReportItem] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID 0E7A4D77-5AD4-408A-8331-EE2D6CF84149 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='0E7A4D77-5AD4-408A-8331-EE2D6CF84149', @RelatedEntityNameFieldMap='AuthoredByAgentRun';

/* SQL text to update entity field related entity name field map for entity field ID 884AFCEB-89E4-4DEB-91CF-7334AB075CB2 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='884AFCEB-89E4-4DEB-91CF-7334AB075CB2', @RelatedEntityNameFieldMap='ReviewedByPerson';

/* Base View SQL for MJ_BizApps_Tasks: Work Reports */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Reports
-- Item: vwWorkReports
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Work Reports
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  WorkReport
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwWorkReports]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwWorkReports];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwWorkReports]
AS
SELECT
    w.*,
    mjBizAppsCommonPerson_PersonID.[DisplayName] AS [Person],
    MJAIAgentRun_AuthoredByAgentRunID.[RunName] AS [AuthoredByAgentRun],
    mjBizAppsCommonPerson_ReviewedByPersonID.[DisplayName] AS [ReviewedByPerson]
FROM
    [${flyway:defaultSchema}].[WorkReport] AS w
LEFT OUTER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_PersonID
  ON
    [w].[PersonID] = mjBizAppsCommonPerson_PersonID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[AIAgentRun] AS MJAIAgentRun_AuthoredByAgentRunID
  ON
    [w].[AuthoredByAgentRunID] = MJAIAgentRun_AuthoredByAgentRunID.[ID]
LEFT OUTER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_ReviewedByPersonID
  ON
    [w].[ReviewedByPersonID] = mjBizAppsCommonPerson_ReviewedByPersonID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwWorkReports] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Work Reports */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Reports
-- Item: Permissions for vwWorkReports
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwWorkReports] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Work Reports */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Reports
-- Item: spCreateWorkReport
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR WorkReport
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateWorkReport]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateWorkReport];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateWorkReport]
    @ID uniqueidentifier = NULL,
    @PersonID uniqueidentifier,
    @PeriodStart date,
    @PeriodEnd date,
    @Title_Clear bit = 0,
    @Title nvarchar(255) = NULL,
    @Body nvarchar(MAX),
    @Status nvarchar(20) = NULL,
    @AuthoredByAgentRunID_Clear bit = 0,
    @AuthoredByAgentRunID uniqueidentifier = NULL,
    @SupervisorFeedback_Clear bit = 0,
    @SupervisorFeedback nvarchar(MAX) = NULL,
    @ReviewedByPersonID_Clear bit = 0,
    @ReviewedByPersonID uniqueidentifier = NULL,
    @ReviewedAt_Clear bit = 0,
    @ReviewedAt datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[WorkReport]
            (
                [ID],
                [PersonID],
                [PeriodStart],
                [PeriodEnd],
                [Title],
                [Body],
                [Status],
                [AuthoredByAgentRunID],
                [SupervisorFeedback],
                [ReviewedByPersonID],
                [ReviewedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @PersonID,
                @PeriodStart,
                @PeriodEnd,
                CASE WHEN @Title_Clear = 1 THEN NULL ELSE ISNULL(@Title, NULL) END,
                @Body,
                ISNULL(@Status, 'Draft'),
                CASE WHEN @AuthoredByAgentRunID_Clear = 1 THEN NULL ELSE ISNULL(@AuthoredByAgentRunID, NULL) END,
                CASE WHEN @SupervisorFeedback_Clear = 1 THEN NULL ELSE ISNULL(@SupervisorFeedback, NULL) END,
                CASE WHEN @ReviewedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@ReviewedByPersonID, NULL) END,
                CASE WHEN @ReviewedAt_Clear = 1 THEN NULL ELSE ISNULL(@ReviewedAt, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[WorkReport]
            (
                [PersonID],
                [PeriodStart],
                [PeriodEnd],
                [Title],
                [Body],
                [Status],
                [AuthoredByAgentRunID],
                [SupervisorFeedback],
                [ReviewedByPersonID],
                [ReviewedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @PersonID,
                @PeriodStart,
                @PeriodEnd,
                CASE WHEN @Title_Clear = 1 THEN NULL ELSE ISNULL(@Title, NULL) END,
                @Body,
                ISNULL(@Status, 'Draft'),
                CASE WHEN @AuthoredByAgentRunID_Clear = 1 THEN NULL ELSE ISNULL(@AuthoredByAgentRunID, NULL) END,
                CASE WHEN @SupervisorFeedback_Clear = 1 THEN NULL ELSE ISNULL(@SupervisorFeedback, NULL) END,
                CASE WHEN @ReviewedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@ReviewedByPersonID, NULL) END,
                CASE WHEN @ReviewedAt_Clear = 1 THEN NULL ELSE ISNULL(@ReviewedAt, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwWorkReports] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateWorkReport] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Work Reports */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateWorkReport] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Work Reports */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Reports
-- Item: spUpdateWorkReport
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR WorkReport
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateWorkReport]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateWorkReport];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateWorkReport]
    @ID uniqueidentifier,
    @PersonID uniqueidentifier = NULL,
    @PeriodStart date = NULL,
    @PeriodEnd date = NULL,
    @Title_Clear bit = 0,
    @Title nvarchar(255) = NULL,
    @Body nvarchar(MAX) = NULL,
    @Status nvarchar(20) = NULL,
    @AuthoredByAgentRunID_Clear bit = 0,
    @AuthoredByAgentRunID uniqueidentifier = NULL,
    @SupervisorFeedback_Clear bit = 0,
    @SupervisorFeedback nvarchar(MAX) = NULL,
    @ReviewedByPersonID_Clear bit = 0,
    @ReviewedByPersonID uniqueidentifier = NULL,
    @ReviewedAt_Clear bit = 0,
    @ReviewedAt datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[WorkReport]
    SET
        [PersonID] = ISNULL(@PersonID, [PersonID]),
        [PeriodStart] = ISNULL(@PeriodStart, [PeriodStart]),
        [PeriodEnd] = ISNULL(@PeriodEnd, [PeriodEnd]),
        [Title] = CASE WHEN @Title_Clear = 1 THEN NULL ELSE ISNULL(@Title, [Title]) END,
        [Body] = ISNULL(@Body, [Body]),
        [Status] = ISNULL(@Status, [Status]),
        [AuthoredByAgentRunID] = CASE WHEN @AuthoredByAgentRunID_Clear = 1 THEN NULL ELSE ISNULL(@AuthoredByAgentRunID, [AuthoredByAgentRunID]) END,
        [SupervisorFeedback] = CASE WHEN @SupervisorFeedback_Clear = 1 THEN NULL ELSE ISNULL(@SupervisorFeedback, [SupervisorFeedback]) END,
        [ReviewedByPersonID] = CASE WHEN @ReviewedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@ReviewedByPersonID, [ReviewedByPersonID]) END,
        [ReviewedAt] = CASE WHEN @ReviewedAt_Clear = 1 THEN NULL ELSE ISNULL(@ReviewedAt, [ReviewedAt]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwWorkReports] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwWorkReports]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateWorkReport] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the WorkReport table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateWorkReport]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateWorkReport];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateWorkReport
ON [${flyway:defaultSchema}].[WorkReport]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[WorkReport]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[WorkReport] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Work Reports */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateWorkReport] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Work Reports */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Reports
-- Item: spDeleteWorkReport
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR WorkReport
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteWorkReport]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteWorkReport];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteWorkReport]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[WorkReport]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteWorkReport] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Work Reports */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteWorkReport] TO [cdp_Developer], [cdp_Integration];

/* SQL text to insert 4 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a56e1676-e40d-4b9e-b998-dc9fc98229a1' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = 'Person')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a56e1676-e40d-4b9e-b998-dc9fc98229a1',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            'Person',
            'Person',
            NULL,
            'nvarchar',
            500,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3b336478-7069-495d-9f88-942494410d3f' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = 'AuthoredByAgentRun')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3b336478-7069-495d-9f88-942494410d3f',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            'AuthoredByAgentRun',
            'Authored By Agent Run',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '44fc4c0b-3516-4635-ba44-def7dc8dbe86' OR (EntityID = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND Name = 'ReviewedByPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '44fc4c0b-3516-4635-ba44-def7dc8dbe86',
            'A9038030-2DBD-48E1-9075-03ED5373B85A', -- Entity: MJ_BizApps_Tasks: Work Reports
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
            'ReviewedByPerson',
            'Reviewed By Person',
            NULL,
            'nvarchar',
            500,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'aa32c6b9-6428-4bc4-b6e0-339f6de9650d' OR (EntityID = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND Name = 'Task')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'aa32c6b9-6428-4bc4-b6e0-339f6de9650d',
            'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- Entity: MJ_BizApps_Tasks: Work Report Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
            'Task',
            'Task',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

/* SQL text to update existing entity fields from schema (4 scoped entities) */
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='', @EntityIDs='A9038030-2DBD-48E1-9075-03ED5373B85A,D9E9EE62-78CE-4E89-8ED0-35378358E321,1E30141A-826F-4278-BAA9-BBE14D29E606,B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '60CE469E-CC17-49B0-9C68-4C53887F0B86'
               AND AutoUpdateDefaultInView = 1;

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '9D56D5C4-7A96-4465-BA13-01B78557DBD2'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '5C7FC965-777E-4B95-8C42-D7372122849B'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'A56E1676-E40D-4B9E-B998-DC9FC98229A1'
               AND AutoUpdateDefaultInView = 1;

/* Set categories for 2 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.IsApproval 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Task Type Definition',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '0AA2AA72-7CED-4302-86CE-41A1C06B810B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.ExtensionEntity 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Task Type Definition',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '5684D61D-47A2-410E-BCC3-4373142DE0F3';

/* Set categories for 16 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.ID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'D6B740E7-DFA0-4FD7-9C9C-96BDF9182B0A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.PersonID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Report Information',
   GeneratedFormSection = 'Category',
   DisplayName = 'Person'
WHERE 
   ID = 'EB682468-BFE5-402F-9560-F97A34282275';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.PeriodStart 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Report Information',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'BBB95BB8-04AD-4F28-9408-3C8E9773305D';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.PeriodEnd 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Report Information',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'F8887BD2-78F6-429A-B7BD-F814D4F7A37C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.Title 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Report Information',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '9D56D5C4-7A96-4465-BA13-01B78557DBD2';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.Status 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Report Information',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '5C7FC965-777E-4B95-8C42-D7372122849B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.Body 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Report Content',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Markdown'
WHERE 
   ID = 'F9618412-4E0B-4940-9207-A8134099948E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.AuthoredByAgentRunID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Automation & Review',
   GeneratedFormSection = 'Category',
   DisplayName = 'Authored By Agent Run'
WHERE 
   ID = '0E7A4D77-5AD4-408A-8331-EE2D6CF84149';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.SupervisorFeedback 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Automation & Review',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '9705C6BF-1B9B-4849-8C18-02C29E208015';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.ReviewedByPersonID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Automation & Review',
   GeneratedFormSection = 'Category',
   DisplayName = 'Reviewed By Person'
WHERE 
   ID = '884AFCEB-89E4-4DEB-91CF-7334AB075CB2';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.ReviewedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Automation & Review',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '0A8E806D-3A65-4B1A-9B67-340298E7015C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.Person 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Report Information',
   GeneratedFormSection = 'Category',
   DisplayName = 'Person Name'
WHERE 
   ID = 'A56E1676-E40D-4B9E-B998-DC9FC98229A1';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.AuthoredByAgentRun 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Automation & Review',
   GeneratedFormSection = 'Category',
   DisplayName = 'Authored By Agent Run Name'
WHERE 
   ID = '3B336478-7069-495D-9F88-942494410D3F';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.ReviewedByPerson 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Automation & Review',
   GeneratedFormSection = 'Category',
   DisplayName = 'Reviewed By Person Name'
WHERE 
   ID = '44FC4C0B-3516-4635-BA44-DEF7DC8DBE86';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'B09E0770-76D8-4F44-8DA7-884217ED2B6E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '3D99C7CA-BC59-4C0C-ACF8-B3D9051FB2B1';

/* Set entity icon to fa fa-clipboard-list */

               UPDATE [${mjSchema}].[Entity]
               SET [Icon] = 'fa fa-clipboard-list', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A';

/* Insert FieldCategoryInfo setting for entity */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND [Name] = 'FieldCategoryInfo'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('1027c8f3-fede-585a-bbbf-fe0b248ae23b', 'A9038030-2DBD-48E1-9075-03ED5373B85A', 'FieldCategoryInfo', '{
  "Automation & Review": {
    "description": "AI generation details, supervisor feedback, and review workflow",
    "icon": "fa fa-user-check"
  },
  "Report Content": {
    "description": "Detailed markdown contents summarizing work and progress",
    "icon": "fa fa-align-left"
  },
  "Report Information": {
    "description": "Core metadata and timeline information for the work report",
    "icon": "fa fa-file-alt"
  },
  "System Metadata": {
    "description": "System-managed audit and tracking fields",
    "icon": "fa fa-cog"
  }
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Insert FieldCategoryIcons setting (legacy) */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND [Name] = 'FieldCategoryIcons'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('160a47f5-5f0e-5dfe-b253-2bfe692afa76', 'A9038030-2DBD-48E1-9075-03ED5373B85A', 'FieldCategoryIcons', '{
  "Automation & Review": "fa fa-user-check",
  "Report Content": "fa fa-align-left",
  "Report Information": "fa fa-file-alt",
  "System Metadata": "fa fa-cog"
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${mjSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = 'A9038030-2DBD-48E1-9075-03ED5373B85A';

/* Set categories for 9 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.ID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '273826B0-2B87-4A25-A69C-4FB46312B01F';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.WorkReportID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Relationships',
   GeneratedFormSection = 'Category',
   DisplayName = 'Work Report'
WHERE 
   ID = '74C73051-9DC1-42D9-ADD4-95469FE48087';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.TaskID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Relationships',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'D7C0EEA5-0AB9-429C-A21E-B3B9D8E7161E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.Section 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Report Item Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'EAF8CC4F-CD1E-4D53-95DB-325D1584929F';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.Summary 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Report Item Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '11458626-D4D5-4304-B8FE-CCF68542869A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.Sequence 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Report Item Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '60CE469E-CC17-49B0-9C68-4C53887F0B86';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.Task 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Report Item Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Task Description'
WHERE 
   ID = 'AA32C6B9-6428-4BC4-B6E0-339F6DE9650D';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'FCB6C423-FBEC-48A8-BC9B-8DC6A1EA28F9';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'B02253A9-A98B-4223-9E00-B0DA95EC4EEB';

/* Set entity icon to fa fa-tasks */

               UPDATE [${mjSchema}].[Entity]
               SET [Icon] = 'fa fa-tasks', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = 'D9E9EE62-78CE-4E89-8ED0-35378358E321';

/* Insert FieldCategoryInfo setting for entity */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND [Name] = 'FieldCategoryInfo'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('18f75737-6df7-5837-b517-c2686daa9b03', 'D9E9EE62-78CE-4E89-8ED0-35378358E321', 'FieldCategoryInfo', '{
  "Relationships": {
    "description": "Foreign key relationships to parent work reports and tasks",
    "icon": "fa fa-link"
  },
  "Report Item Details": {
    "description": "Content, section classification, and ordering of the report item",
    "icon": "fa fa-align-left"
  },
  "System Metadata": {
    "description": "System-managed audit and tracking fields",
    "icon": "fa fa-cog"
  }
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Insert FieldCategoryIcons setting (legacy) */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND [Name] = 'FieldCategoryIcons'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('8480e57d-4fe8-58da-95db-fd3e4b01d6a2', 'D9E9EE62-78CE-4E89-8ED0-35378358E321', 'FieldCategoryIcons', '{
  "Relationships": "fa fa-link",
  "Report Item Details": "fa fa-align-left",
  "System Metadata": "fa fa-cog"
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Set DefaultForNewUser=false for NEW entity (category: supporting, confidence: high) */

         UPDATE [${mjSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 0, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = 'D9E9EE62-78CE-4E89-8ED0-35378358E321';

/* Refresh custom base views for modified entities so schema changes are picked up */
EXEC sp_refreshview '${flyway:defaultSchema}.vwTasksGenerated';
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTasks]', 'V') IS NOT NULL
BEGIN
    EXEC sp_executesql N'EXEC sp_refreshview ''${flyway:defaultSchema}.vwTasks'';';
END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Work Reports */
-- CHECK constraint for MJ_BizApps_Tasks: Work Reports @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND [Name] = 'ValidatePeriodEndOnOrAfterPeriodStart'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('fa16a21b-3dc7-4b64-9ba1-3a16c166643a', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([PeriodEnd]>=[PeriodStart])', '	public ValidatePeriodEndOnOrAfterPeriodStart(result: ValidationResult) {
		if (this.PeriodStart != null && this.PeriodEnd != null && new Date(this.PeriodEnd).getTime() < new Date(this.PeriodStart).getTime()) {
			result.Errors.push(new ValidationErrorInfo(
				"PeriodEnd",
				"Period end date must be on or after the period start date.",
				this.PeriodEnd,
				ValidationErrorType.Failure
			));
		}
	}', 'The period end date must be on or after the period start date.', 'ValidatePeriodEndOnOrAfterPeriodStart', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'A9038030-2DBD-48E1-9075-03ED5373B85A')
   END;

