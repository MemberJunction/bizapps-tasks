/* SQL generated to create new entity MJ_BizApps_Tasks: Task Decision Outcomes */

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
         [AllowCaching]
         , [TrackRecordChanges]
         , [AuditRecordAccess]
         , [AuditViewRuns]
         , [AllowAllRowsAPI]
         , [AllowCreateAPI]
         , [AllowUpdateAPI]
         , [AllowDeleteAPI]
         , [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         'd3868906-e957-4061-a79d-6ce7a96dc0ed',
         'MJ_BizApps_Tasks: Task Decision Outcomes',
         'Task Decision Outcomes',
         NULL,
         NULL,
         'TaskDecisionOutcome',
         'vwTaskDecisionOutcomes',
         '${flyway:defaultSchema}',
         1,
         1,
         0
         , 1
         , 0
         , 0
         , 0
         , 1
         , 1
         , 1
         , 1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Decision Outcomes to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'd3868906-e957-4061-a79d-6ce7a96dc0ed', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Decision Outcomes for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('d3868906-e957-4061-a79d-6ce7a96dc0ed', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Decision Outcomes for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('d3868906-e957-4061-a79d-6ce7a96dc0ed', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Decision Outcomes for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('d3868906-e957-4061-a79d-6ce7a96dc0ed', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Decisions */

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
         [AllowCaching]
         , [TrackRecordChanges]
         , [AuditRecordAccess]
         , [AuditViewRuns]
         , [AllowAllRowsAPI]
         , [AllowCreateAPI]
         , [AllowUpdateAPI]
         , [AllowDeleteAPI]
         , [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         '78ef0be0-1a0b-48d3-be06-8524e3cd7fdf',
         'MJ_BizApps_Tasks: Task Decisions',
         'Task Decisions',
         NULL,
         NULL,
         'TaskDecision',
         'vwTaskDecisions',
         '${flyway:defaultSchema}',
         1,
         1,
         0
         , 1
         , 0
         , 0
         , 0
         , 1
         , 1
         , 1
         , 1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Decisions to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '78ef0be0-1a0b-48d3-be06-8524e3cd7fdf', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Decisions for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('78ef0be0-1a0b-48d3-be06-8524e3cd7fdf', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Decisions for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('78ef0be0-1a0b-48d3-be06-8524e3cd7fdf', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Decisions for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('78ef0be0-1a0b-48d3-be06-8524e3cd7fdf', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL text to update existing entities from schema */
EXEC [${mjSchema}].[spUpdateExistingEntitiesFromSchema] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon';

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskDecisionOutcome */
ALTER TABLE [${flyway:defaultSchema}].[TaskDecisionOutcome] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskDecisionOutcome */
UPDATE [${flyway:defaultSchema}].[TaskDecisionOutcome] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskDecisionOutcome */
ALTER TABLE [${flyway:defaultSchema}].[TaskDecisionOutcome] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskDecisionOutcome */
ALTER TABLE [${flyway:defaultSchema}].[TaskDecisionOutcome] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskDecisionOutcome___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskDecisionOutcome */
ALTER TABLE [${flyway:defaultSchema}].[TaskDecisionOutcome] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskDecisionOutcome */
UPDATE [${flyway:defaultSchema}].[TaskDecisionOutcome] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskDecisionOutcome */
ALTER TABLE [${flyway:defaultSchema}].[TaskDecisionOutcome] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskDecisionOutcome */
ALTER TABLE [${flyway:defaultSchema}].[TaskDecisionOutcome] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskDecisionOutcome___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskDecision */
ALTER TABLE [${flyway:defaultSchema}].[TaskDecision] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskDecision */
UPDATE [${flyway:defaultSchema}].[TaskDecision] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskDecision */
ALTER TABLE [${flyway:defaultSchema}].[TaskDecision] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskDecision */
ALTER TABLE [${flyway:defaultSchema}].[TaskDecision] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskDecision___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskDecision */
ALTER TABLE [${flyway:defaultSchema}].[TaskDecision] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskDecision */
UPDATE [${flyway:defaultSchema}].[TaskDecision] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskDecision */
ALTER TABLE [${flyway:defaultSchema}].[TaskDecision] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskDecision */
ALTER TABLE [${flyway:defaultSchema}].[TaskDecision] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskDecision___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '062009d5-6662-48ce-8db6-ee9b68ef38c2' OR (EntityID = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND Name = 'ID')) BEGIN
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
            '062009d5-6662-48ce-8db6-ee9b68ef38c2',
            'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
            100001,
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
            1,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '13307cb7-4c4c-49b1-9ddd-bc6bf31d5aa2' OR (EntityID = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND Name = 'Name')) BEGIN
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
            '13307cb7-4c4c-49b1-9ddd-bc6bf31d5aa2',
            'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
            100002,
            'Name',
            'Name',
            'Human-readable outcome label (e.g. Approved, Rejected, Approved With Conditions).',
            'nvarchar',
            200,
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
            1,
            1,
            0,
            1,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1ccf7e45-4e05-4621-ade8-dec702a85f30' OR (EntityID = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND Name = 'Code')) BEGIN
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
            '1ccf7e45-4e05-4621-ade8-dec702a85f30',
            'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
            100003,
            'Code',
            'Code',
            'Stable machine code for the outcome, used by orchestration code to map outcome to task status (e.g. Approved, Rejected, ApprovedWithConditions).',
            'nvarchar',
            100,
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '72a08d0c-73c9-4de6-b8bd-98b6dc25b95b' OR (EntityID = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND Name = 'Description')) BEGIN
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
            '72a08d0c-73c9-4de6-b8bd-98b6dc25b95b',
            'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
            100004,
            'Description',
            'Description',
            NULL,
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '61499937-ee87-4b0e-94f0-b3abe411dcd9' OR (EntityID = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND Name = 'Sequence')) BEGIN
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
            '61499937-ee87-4b0e-94f0-b3abe411dcd9',
            'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
            100005,
            'Sequence',
            'Sequence',
            'Display ordering for the outcome in decision pickers.',
            'int',
            4,
            10,
            0,
            0,
            '(100)',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6ea8984b-1218-49d5-874d-2a39bec98316' OR (EntityID = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND Name = 'IsTerminal')) BEGIN
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
            '6ea8984b-1218-49d5-874d-2a39bec98316',
            'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
            100006,
            'IsTerminal',
            'Is Terminal',
            'When 1, recording this outcome closes the approval (terminal). When 0, the decision is interim and the task remains open.',
            'bit',
            1,
            1,
            0,
            0,
            '(1)',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'bfa5d2b0-3d60-4acd-9478-e8fe5d02a820' OR (EntityID = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND Name = 'IsActive')) BEGIN
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
            'bfa5d2b0-3d60-4acd-9478-e8fe5d02a820',
            'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
            100007,
            'IsActive',
            'Is Active',
            'When 0, the outcome is hidden from new decision pickers but preserved on historical decisions.',
            'bit',
            1,
            1,
            0,
            0,
            '(1)',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7c4cdb23-ab35-488d-84aa-3a54f8c4112f' OR (EntityID = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND Name = '__mj_CreatedAt')) BEGIN
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
            '7c4cdb23-ab35-488d-84aa-3a54f8c4112f',
            'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
            100008,
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9cdef81f-e064-48fb-ac86-0ea86123a499' OR (EntityID = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '9cdef81f-e064-48fb-ac86-0ea86123a499',
            'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
            100009,
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9e1a5e43-07a2-4f96-bca6-0c47444ecff9' OR (EntityID = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND Name = 'ID')) BEGIN
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
            '9e1a5e43-07a2-4f96-bca6-0c47444ecff9',
            '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- Entity: MJ_BizApps_Tasks: Task Decisions
            100001,
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
            1,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '16b9251a-bcb9-454b-99bc-29cb6c39d590' OR (EntityID = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND Name = 'TaskID')) BEGIN
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
            '16b9251a-bcb9-454b-99bc-29cb6c39d590',
            '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- Entity: MJ_BizApps_Tasks: Task Decisions
            100002,
            'TaskID',
            'Task ID',
            'The task this decision was recorded against.',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1f74f328-548c-418d-ac2b-ade7cd40907c' OR (EntityID = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND Name = 'OutcomeID')) BEGIN
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
            '1f74f328-548c-418d-ac2b-ade7cd40907c',
            '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- Entity: MJ_BizApps_Tasks: Task Decisions
            100003,
            'OutcomeID',
            'Outcome ID',
            'The decision outcome (FK to TaskDecisionOutcome).',
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
            'D3868906-E957-4061-A79D-6CE7A96DC0ED',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'de230ab6-50c3-47ee-9bd8-761caac10a01' OR (EntityID = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND Name = 'DecidedByPersonID')) BEGIN
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
            'de230ab6-50c3-47ee-9bd8-761caac10a01',
            '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- Entity: MJ_BizApps_Tasks: Task Decisions
            100004,
            'DecidedByPersonID',
            'Decided By Person ID',
            'The Person who made the decision.',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd00f04d1-2af0-439a-806a-eae9e4321fb8' OR (EntityID = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND Name = 'DecidedAt')) BEGIN
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
            'd00f04d1-2af0-439a-806a-eae9e4321fb8',
            '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- Entity: MJ_BizApps_Tasks: Task Decisions
            100005,
            'DecidedAt',
            'Decided At',
            'When the decision was recorded.',
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '97659d3f-72d7-4e58-9af4-e6deeea7fa50' OR (EntityID = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND Name = 'DecisionNotes')) BEGIN
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
            '97659d3f-72d7-4e58-9af4-e6deeea7fa50',
            '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- Entity: MJ_BizApps_Tasks: Task Decisions
            100006,
            'DecisionNotes',
            'Decision Notes',
            'Free-text rationale or conditions attached to the decision.',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b075c87d-5e21-4b94-b77a-cc5d2e59d909' OR (EntityID = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND Name = 'TaskAssignmentID')) BEGIN
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
            'b075c87d-5e21-4b94-b77a-cc5d2e59d909',
            '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- Entity: MJ_BizApps_Tasks: Task Decisions
            100007,
            'TaskAssignmentID',
            'Task Assignment ID',
            'Optional link to the specific TaskAssignment this decision belongs to, for per-assignee decisions in multi-approver flows. Null for a task-level decision.',
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
            'DF98E700-1992-442B-B93E-E47379F2CA52',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'da3abe83-4369-46e2-ac33-811e32a57ff2' OR (EntityID = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND Name = '__mj_CreatedAt')) BEGIN
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
            'da3abe83-4369-46e2-ac33-811e32a57ff2',
            '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- Entity: MJ_BizApps_Tasks: Task Decisions
            100008,
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e16ec915-fde1-452e-bf76-77ffb6f2f6c9' OR (EntityID = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'e16ec915-fde1-452e-bf76-77ffb6f2f6c9',
            '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- Entity: MJ_BizApps_Tasks: Task Decisions
            100009,
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '04b4f98d-f79d-4a84-9f63-fb5ffac014d5' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnRejectActionID')) BEGIN
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
            '04b4f98d-f79d-4a84-9f63-fb5ffac014d5',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
            100029,
            'OnRejectActionID',
            'On Reject Action ID',
            'Action invoked when a task of this type transitions to a rejected decision (post-commit, non-blocking). Used by approval workflows.',
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
            '38248F34-2837-EF11-86D4-6045BDEE16E6',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a86f3057-5e26-450f-a958-2c1f63dd2a88' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnCancelActionID')) BEGIN
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
            'a86f3057-5e26-450f-a958-2c1f63dd2a88',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
            100030,
            'OnCancelActionID',
            'On Cancel Action ID',
            'Action invoked when a task of this type transitions to Cancelled (post-commit, non-blocking).',
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
            '38248F34-2837-EF11-86D4-6045BDEE16E6',
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

/* SQL text to update existing entity fields from schema */
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon';

/* SQL text to insert entity field value with ID 8ae2a9c0-e952-4271-a1c2-3853347bf37b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('8ae2a9c0-e952-4271-a1c2-3853347bf37b', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 5, 'DecisionRecorded', 'DecisionRecorded', GETUTCDATE(), GETUTCDATE());

/* SQL text to update entity field value sequence */
UPDATE [${mjSchema}].[EntityFieldValue] SET Sequence=6 WHERE ID='3B04B519-5C74-45B1-BA4B-94372125B7E5';

/* SQL text to update entity field value sequence */
UPDATE [${mjSchema}].[EntityFieldValue] SET Sequence=7 WHERE ID='F0EC7C9E-9646-491F-929E-165449D8929E';

/* SQL text to update entity field value sequence */
UPDATE [${mjSchema}].[EntityFieldValue] SET Sequence=8 WHERE ID='F86D7D4F-2042-4A2B-A984-6C6C073D1CB1';

/* SQL text to update entity field value sequence */
UPDATE [${mjSchema}].[EntityFieldValue] SET Sequence=9 WHERE ID='40B53F38-2CE5-41B1-8116-D2340BF0B78B';

/* SQL text to update entity field value sequence */
UPDATE [${mjSchema}].[EntityFieldValue] SET Sequence=10 WHERE ID='DD9E09D4-FF5D-44DC-8AC4-7554FEEE32FB';

/* SQL text to update entity field value sequence */
UPDATE [${mjSchema}].[EntityFieldValue] SET Sequence=11 WHERE ID='20257078-873D-4C95-9DD9-078E4E856FCB';


/* Create Entity Relationship: MJ: Actions -> MJ_BizApps_Tasks: Task Types (One To Many via OnCancelActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '06b9d0ba-ab58-43bb-84f9-20632810000c'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('06b9d0ba-ab58-43bb-84f9-20632810000c', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnCancelActionID', 'One To Many', 1, 1, 18, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Actions -> MJ_BizApps_Tasks: Task Types (One To Many via OnRejectActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '54960c7c-5267-4ddd-bd5a-7e9f3cc486ee'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('54960c7c-5267-4ddd-bd5a-7e9f3cc486ee', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnRejectActionID', 'One To Many', 1, 1, 19, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Task Decision Outcomes -> MJ_BizApps_Tasks: Task Decisions (One To Many via OutcomeID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'a608e0d6-054c-4924-9fd8-e627918068dd'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a608e0d6-054c-4924-9fd8-e627918068dd', 'D3868906-E957-4061-A79D-6CE7A96DC0ED', '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', 'OutcomeID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Task Decisions (One To Many via DecidedByPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'e3400892-1304-4518-bf7a-cfd0eee4659e'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('e3400892-1304-4518-bf7a-cfd0eee4659e', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', 'DecidedByPersonID', 'One To Many', 1, 1, 8, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Task Assignments -> MJ_BizApps_Tasks: Task Decisions (One To Many via TaskAssignmentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '26002101-79fe-4882-87a9-42ceea625ce3'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('26002101-79fe-4882-87a9-42ceea625ce3', 'DF98E700-1992-442B-B93E-E47379F2CA52', '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', 'TaskAssignmentID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Task Decisions (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '533c0196-2fc5-4895-929e-a42be9dcac75'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('533c0196-2fc5-4895-929e-a42be9dcac75', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', 'TaskID', 'One To Many', 1, 1, 10, GETUTCDATE(), GETUTCDATE())
   END;

/* SQL text to sync schema info from database schemas */
EXEC [${mjSchema}].[spUpdateSchemaInfoFromDatabase] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon';

/* Index for Foreign Keys for TaskDecisionOutcome */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

/* Base View SQL for MJ_BizApps_Tasks: Task Decision Outcomes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
-- Item: vwTaskDecisionOutcomes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Decision Outcomes
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskDecisionOutcome
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskDecisionOutcomes]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskDecisionOutcomes];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskDecisionOutcomes]
AS
SELECT
    t.*
FROM
    [${flyway:defaultSchema}].[TaskDecisionOutcome] AS t
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskDecisionOutcomes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Decision Outcomes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
-- Item: Permissions for vwTaskDecisionOutcomes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskDecisionOutcomes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Decision Outcomes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
-- Item: spCreateTaskDecisionOutcome
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskDecisionOutcome
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskDecisionOutcome]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskDecisionOutcome];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskDecisionOutcome]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(100),
    @Code nvarchar(50),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @Sequence int = NULL,
    @IsTerminal bit = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskDecisionOutcome]
            (
                [ID],
                [Name],
                [Code],
                [Description],
                [Sequence],
                [IsTerminal],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                @Code,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                ISNULL(@Sequence, 100),
                ISNULL(@IsTerminal, 1),
                ISNULL(@IsActive, 1)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskDecisionOutcome]
            (
                [Name],
                [Code],
                [Description],
                [Sequence],
                [IsTerminal],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                @Code,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                ISNULL(@Sequence, 100),
                ISNULL(@IsTerminal, 1),
                ISNULL(@IsActive, 1)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskDecisionOutcomes] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDecisionOutcome] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Decision Outcomes */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDecisionOutcome] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Decision Outcomes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
-- Item: spUpdateTaskDecisionOutcome
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskDecisionOutcome
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskDecisionOutcome]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskDecisionOutcome];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskDecisionOutcome]
    @ID uniqueidentifier,
    @Name nvarchar(100) = NULL,
    @Code nvarchar(50) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @Sequence int = NULL,
    @IsTerminal bit = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskDecisionOutcome]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [Code] = ISNULL(@Code, [Code]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [Sequence] = ISNULL(@Sequence, [Sequence]),
        [IsTerminal] = ISNULL(@IsTerminal, [IsTerminal]),
        [IsActive] = ISNULL(@IsActive, [IsActive])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskDecisionOutcomes] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskDecisionOutcomes]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskDecisionOutcome] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskDecisionOutcome table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskDecisionOutcome]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskDecisionOutcome];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskDecisionOutcome
ON [${flyway:defaultSchema}].[TaskDecisionOutcome]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskDecisionOutcome]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskDecisionOutcome] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Decision Outcomes */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskDecisionOutcome] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Decision Outcomes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
-- Item: spDeleteTaskDecisionOutcome
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskDecisionOutcome
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskDecisionOutcome]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskDecisionOutcome];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskDecisionOutcome]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskDecisionOutcome]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDecisionOutcome] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Decision Outcomes */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDecisionOutcome] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for TaskDecision */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decisions
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskID in table TaskDecision
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskDecision_TaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskDecision]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskDecision_TaskID ON [${flyway:defaultSchema}].[TaskDecision] ([TaskID]);

-- Index for foreign key OutcomeID in table TaskDecision
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskDecision_OutcomeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskDecision]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskDecision_OutcomeID ON [${flyway:defaultSchema}].[TaskDecision] ([OutcomeID]);

-- Index for foreign key DecidedByPersonID in table TaskDecision
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskDecision_DecidedByPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskDecision]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskDecision_DecidedByPersonID ON [${flyway:defaultSchema}].[TaskDecision] ([DecidedByPersonID]);

-- Index for foreign key TaskAssignmentID in table TaskDecision
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskDecision_TaskAssignmentID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskDecision]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskDecision_TaskAssignmentID ON [${flyway:defaultSchema}].[TaskDecision] ([TaskAssignmentID]);

/* SQL text to update entity field related entity name field map for entity field ID 16B9251A-BCB9-454B-99BC-29CB6C39D590 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='16B9251A-BCB9-454B-99BC-29CB6C39D590', @RelatedEntityNameFieldMap='Task';

/* SQL text to update entity field related entity name field map for entity field ID 1F74F328-548C-418D-AC2B-ADE7CD40907C */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='1F74F328-548C-418D-AC2B-ADE7CD40907C', @RelatedEntityNameFieldMap='Outcome';

/* SQL text to update entity field related entity name field map for entity field ID DE230AB6-50C3-47EE-9BD8-761CAAC10A01 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='DE230AB6-50C3-47EE-9BD8-761CAAC10A01', @RelatedEntityNameFieldMap='DecidedByPerson';

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
INNER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
INNER JOIN
    [${flyway:defaultSchema}].[TaskDecisionOutcome] AS mjBizAppsTasksTaskDecisionOutcome_OutcomeID
  ON
    [t].[OutcomeID] = mjBizAppsTasksTaskDecisionOutcome_OutcomeID.[ID]
LEFT OUTER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_DecidedByPersonID
  ON
    [t].[DecidedByPersonID] = mjBizAppsCommonPerson_DecidedByPersonID.[ID]
GO
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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDecision] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Decisions */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDecision] TO [cdp_Developer], [cdp_Integration];

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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDecision] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Decisions */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDecision] TO [cdp_Developer], [cdp_Integration];

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

/* SQL text to update entity field related entity name field map for entity field ID 04B4F98D-F79D-4A84-9F63-FB5FFAC014D5 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='04B4F98D-F79D-4A84-9F63-FB5FFAC014D5', @RelatedEntityNameFieldMap='OnRejectAction';

/* SQL text to update entity field related entity name field map for entity field ID A86F3057-5E26-450F-A958-2C1F63DD2A88 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='A86F3057-5E26-450F-A958-2C1F63DD2A88', @RelatedEntityNameFieldMap='OnCancelAction';

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
    MJAction_OnCancelActionID.[Name] AS [OnCancelAction]
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
GO
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
    @OnCancelActionID uniqueidentifier = NULL
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
                [OnCancelActionID]
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
                CASE WHEN @OnCancelActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCancelActionID, NULL) END
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
                [OnCancelActionID]
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
                CASE WHEN @OnCancelActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCancelActionID, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskTypes] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskType] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Types */

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
    @OnCancelActionID uniqueidentifier = NULL
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
        [OnCancelActionID] = CASE WHEN @OnCancelActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCancelActionID, [OnCancelActionID]) END
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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskType] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Types */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskType] TO [cdp_Developer], [cdp_Integration];

/* SQL text to delete unneeded entity fields (3 scoped entities) */
EXEC [${mjSchema}].[spDeleteUnneededEntityFields] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon', @EntityIDs='D3868906-E957-4061-A79D-6CE7A96DC0ED,78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF,1E30141A-826F-4278-BAA9-BBE14D29E606';

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '29dac57c-41b1-4159-ad13-3dcc45a48d87' OR (EntityID = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND Name = 'Task')) BEGIN
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
            '29dac57c-41b1-4159-ad13-3dcc45a48d87',
            '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- Entity: MJ_BizApps_Tasks: Task Decisions
            100019,
            'Task',
            'Task',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            0,
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2ede228d-162d-4a86-858e-6ab3606a4096' OR (EntityID = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND Name = 'Outcome')) BEGIN
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
            '2ede228d-162d-4a86-858e-6ab3606a4096',
            '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- Entity: MJ_BizApps_Tasks: Task Decisions
            100020,
            'Outcome',
            'Outcome',
            NULL,
            'nvarchar',
            200,
            0,
            0,
            0,
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '51c078ed-a99e-4472-8f05-f38fd92262fe' OR (EntityID = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND Name = 'DecidedByPerson')) BEGIN
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
            '51c078ed-a99e-4472-8f05-f38fd92262fe',
            '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- Entity: MJ_BizApps_Tasks: Task Decisions
            100021,
            'DecidedByPerson',
            'Decided By Person',
            NULL,
            'nvarchar',
            402,
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4485192e-6dbc-4a4e-9a65-f4bc21a91daa' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnRejectAction')) BEGIN
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
            '4485192e-6dbc-4a4e-9a65-f4bc21a91daa',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
            100037,
            'OnRejectAction',
            'On Reject Action',
            NULL,
            'nvarchar',
            850,
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'da3ea9e6-160b-48c7-940e-567dcbf04d7a' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnCancelAction')) BEGIN
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
            'da3ea9e6-160b-48c7-940e-567dcbf04d7a',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
            100038,
            'OnCancelAction',
            'On Cancel Action',
            NULL,
            'nvarchar',
            850,
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

/* SQL text to update existing entity fields from schema (3 scoped entities) */
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon', @EntityIDs='D3868906-E957-4061-A79D-6CE7A96DC0ED,78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF,1E30141A-826F-4278-BAA9-BBE14D29E606';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon';

