-- =============================================================================
-- Migration: V202611222000__v1.16.x__Task_Risk_Assessments.sql
-- Description:
--   1. Add ForecastCompletionDate additively to [__mj_BizAppsTasks].[Task]
--      (HealthStatus and ConfidenceScore already exist from v1.9.x).
--   2. Create [__mj_BizAppsTasks].[TaskRiskAssessment] linked to the project
--      root Task and optional MJ AIAgentRun, capturing risk forecast, ML breach
--      probability, typed Risks JSON array, and LLM token/cost telemetry.
-- =============================================================================

---------------------------------------------------------------------------
-- 1. Task: Add ForecastCompletionDate additively
---------------------------------------------------------------------------
IF COL_LENGTH(N'${flyway:defaultSchema}.Task', N'ForecastCompletionDate') IS NULL
BEGIN
    ALTER TABLE [${flyway:defaultSchema}].[Task]
        ADD [ForecastCompletionDate] DATETIMEOFFSET NULL;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.extended_properties ep
    JOIN sys.columns c ON ep.major_id = c.object_id AND ep.minor_id = c.column_id
    WHERE ep.major_id = OBJECT_ID(N'[${flyway:defaultSchema}].[Task]')
      AND c.name = N'ForecastCompletionDate'
      AND ep.name = N'MS_Description'
)
BEGIN
    EXEC sp_addextendedproperty
        @name = N'MS_Description',
        @value = N'AI-forecasted completion date synced from the latest Task Risk Assessment for project health rollups and Chief of Staff briefings.',
        @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
        @level1type = N'TABLE',  @level1name = N'Task',
        @level2type = N'COLUMN', @level2name = N'ForecastCompletionDate';
END;
GO

---------------------------------------------------------------------------
-- 2. TaskRiskAssessment: AI Project Risk & Completion Forecast Assessments
---------------------------------------------------------------------------
CREATE TABLE [${flyway:defaultSchema}].[TaskRiskAssessment] (
    [ID]                     UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_TaskRiskAssessment_ID] DEFAULT (NEWSEQUENTIALID()),
    [TaskID]                 UNIQUEIDENTIFIER NOT NULL,
    [AssessedAt]             DATETIMEOFFSET   NOT NULL CONSTRAINT [DF_TaskRiskAssessment_AssessedAt] DEFAULT (SYSDATETIMEOFFSET()),
    [ForecastCompletionDate] DATETIMEOFFSET   NULL,
    [ForecastConfidence]     INT              NULL,
    [HealthStatus]           NVARCHAR(20)     NOT NULL CONSTRAINT [DF_TaskRiskAssessment_HealthStatus] DEFAULT ('OnTrack'),
    [MLBreachProbability]    DECIMAL(5, 4)    NULL,
    [Risks]                  NVARCHAR(MAX)    NOT NULL CONSTRAINT [DF_TaskRiskAssessment_Risks] DEFAULT (N'[]'),
    [AgentRunID]             UNIQUEIDENTIFIER NULL,
    [PromptTokens]           INT              NULL,
    [CompletionTokens]       INT              NULL,
    [TotalCostUSD]           DECIMAL(19, 8)   NULL,
    [__mj_CreatedAt]         DATETIMEOFFSET   NOT NULL CONSTRAINT [DF_TaskRiskAssessment___mj_CreatedAt] DEFAULT (GETUTCDATE()),
    [__mj_UpdatedAt]         DATETIMEOFFSET   NOT NULL CONSTRAINT [DF_TaskRiskAssessment___mj_UpdatedAt] DEFAULT (GETUTCDATE()),

    CONSTRAINT [PK_TaskRiskAssessment] PRIMARY KEY ([ID]),
    CONSTRAINT [FK_TaskRiskAssessment_Task]
        FOREIGN KEY ([TaskID]) REFERENCES [${flyway:defaultSchema}].[Task]([ID]),
    CONSTRAINT [FK_TaskRiskAssessment_AIAgentRun]
        FOREIGN KEY ([AgentRunID]) REFERENCES [${mjSchema}].[AIAgentRun]([ID]),
    CONSTRAINT [CK_TaskRiskAssessment_ForecastConfidence]
        CHECK ([ForecastConfidence] IS NULL OR ([ForecastConfidence] >= 0 AND [ForecastConfidence] <= 100)),
    CONSTRAINT [CK_TaskRiskAssessment_HealthStatus]
        CHECK ([HealthStatus] IN ('OnTrack', 'AtRisk', 'OffTrack', 'Completed', 'Paused')),
    CONSTRAINT [CK_TaskRiskAssessment_MLBreachProbability]
        CHECK ([MLBreachProbability] IS NULL OR ([MLBreachProbability] >= 0 AND [MLBreachProbability] <= 1)),
    CONSTRAINT [CK_TaskRiskAssessment_Risks_JSON]
        CHECK (ISJSON([Risks]) = 1),
    CONSTRAINT [CK_TaskRiskAssessment_PromptTokens]
        CHECK ([PromptTokens] IS NULL OR [PromptTokens] >= 0),
    CONSTRAINT [CK_TaskRiskAssessment_CompletionTokens]
        CHECK ([CompletionTokens] IS NULL OR [CompletionTokens] >= 0),
    CONSTRAINT [CK_TaskRiskAssessment_TotalCostUSD]
        CHECK ([TotalCostUSD] IS NULL OR [TotalCostUSD] >= 0)
);
GO

CREATE INDEX [IX_TaskRiskAssessment_Task_AssessedAt]
    ON [${flyway:defaultSchema}].[TaskRiskAssessment] ([TaskID], [AssessedAt] DESC);
GO

CREATE INDEX [IDX_AUTO_MJ_FKEY_TaskRiskAssessment_AgentRunID]
    ON [${flyway:defaultSchema}].[TaskRiskAssessment] ([AgentRunID]);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'AI-generated project risk assessments and completion date forecasts linked to a root project Task, syncing latest health, confidence, and forecast completion date onto the Task.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskRiskAssessment';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary key for the task risk assessment.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskRiskAssessment',
    @level2type = N'COLUMN', @level2name = N'ID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The project root task (or tracked task) evaluated by this risk assessment.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskRiskAssessment',
    @level2type = N'COLUMN', @level2name = N'TaskID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when this risk assessment was produced.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskRiskAssessment',
    @level2type = N'COLUMN', @level2name = N'AssessedAt';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Forecasted completion timestamp estimated by the Project Risk Analyst.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskRiskAssessment',
    @level2type = N'COLUMN', @level2name = N'ForecastCompletionDate';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Confidence score (0-100) in the forecasted completion date and health status, synced onto Task.ConfidenceScore.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskRiskAssessment',
    @level2type = N'COLUMN', @level2name = N'ForecastConfidence';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Assessed project health status: OnTrack, AtRisk, OffTrack, Completed, or Paused.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskRiskAssessment',
    @level2type = N'COLUMN', @level2name = N'HealthStatus';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'ML model breach probability (0.0000 - 1.0000) consumed as one input to the risk assessment.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskRiskAssessment',
    @level2type = N'COLUMN', @level2name = N'MLBreachProbability';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'JSON array of structured risk items ({ kind, severity, evidenceLinks, suggestedMitigation }).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskRiskAssessment',
    @level2type = N'COLUMN', @level2name = N'Risks';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional MemberJunction AI Agent Run that generated this assessment.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskRiskAssessment',
    @level2type = N'COLUMN', @level2name = N'AgentRunID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Input prompt token count consumed while generating this risk assessment.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskRiskAssessment',
    @level2type = N'COLUMN', @level2name = N'PromptTokens';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Output completion token count generated for this risk assessment.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskRiskAssessment',
    @level2type = N'COLUMN', @level2name = N'CompletionTokens';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total LLM inference cost in USD attributed to this risk assessment.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskRiskAssessment',
    @level2type = N'COLUMN', @level2name = N'TotalCostUSD';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Record creation timestamp in UTC.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskRiskAssessment',
    @level2type = N'COLUMN', @level2name = N'__mj_CreatedAt';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Record last-updated timestamp in UTC.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskRiskAssessment',
    @level2type = N'COLUMN', @level2name = N'__mj_UpdatedAt';
GO























































-- =============================================================================
-- GENERATED BY MemberJunction CodeGen — DO NOT EDIT BY HAND
-- Contains Entity registration, EntityField/EntityFieldValue inserts,
-- EntityRelationship rows, FK index checks, vwTasksGenerated/vwTasks refresh,
-- spCreateTask/spUpdateTask/spDeleteTask/trgUpdateTask, and
-- vwTaskRiskAssessments/spCreateTaskRiskAssessment/spUpdateTaskRiskAssessment/
-- spDeleteTaskRiskAssessment/trgUpdateTaskRiskAssessment.
-- =============================================================================

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Risk Assessments */
IF NOT EXISTS (
    SELECT 1 FROM [${mjSchema}].[Entity]
    WHERE [ID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'
       OR [Name] = 'MJ_BizApps_Tasks: Task Risk Assessments'
)
BEGIN
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
        [UserViewMaxRows],
        [__mj_CreatedAt],
        [__mj_UpdatedAt]
    )
    VALUES (
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        'MJ_BizApps_Tasks: Task Risk Assessments',
        'Task Risk Assessments',
        'AI-generated project risk assessments and completion date forecasts linked to a root project Task, syncing latest health, confidence, and forecast completion date onto the Task.',
        NULL,
        'TaskRiskAssessment',
        'vwTaskRiskAssessments',
        '${flyway:defaultSchema}',
        1,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        1,
        1,
        1000,
        GETUTCDATE(),
        GETUTCDATE()
    );
END;

/* SQL generated to add entity MJ_BizApps_Tasks: Task Risk Assessments to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
IF NOT EXISTS (
    SELECT 1 FROM [${mjSchema}].[ApplicationEntity]
    WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'
      AND [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'
)
BEGIN
    INSERT INTO [${mjSchema}].[ApplicationEntity]
        ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
    VALUES
        (
            '22541055-8ED4-4850-8ACD-E5EE1887B15B',
            '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'),
            GETUTCDATE(),
            GETUTCDATE()
        );
END;

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Risk Assessments for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
    ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
SELECT CAST('4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE()
WHERE NOT EXISTS (
    SELECT 1 FROM [${mjSchema}].[EntityPermission]
    WHERE [EntityID] = CAST('4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AS uniqueidentifier)
      AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier)
      AND [Type] = 'Allow'
);

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Risk Assessments for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
    ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
SELECT CAST('4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
WHERE NOT EXISTS (
    SELECT 1 FROM [${mjSchema}].[EntityPermission]
    WHERE [EntityID] = CAST('4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AS uniqueidentifier)
      AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier)
      AND [Type] = 'Allow'
);

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Risk Assessments for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
    ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
SELECT CAST('4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
WHERE NOT EXISTS (
    SELECT 1 FROM [${mjSchema}].[EntityPermission]
    WHERE [EntityID] = CAST('4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AS uniqueidentifier)
      AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier)
      AND [Type] = 'Allow'
);

/* SQL text to update existing entities from schema */
EXEC [${mjSchema}].[spUpdateExistingEntitiesFromSchema] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to insert new entity field(s) for Task and TaskRiskAssessment */
IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c7578da9-3615-4787-a509-b9d2d5ae8eb1' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'ForecastCompletionDate')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        'c7578da9-3615-4787-a509-b9d2d5ae8eb1',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'ForecastCompletionDate',
        'Forecast Completion Date',
        'AI-forecasted completion date synced from the latest Task Risk Assessment for project health rollups and Chief of Staff briefings.',
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
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1bc39b54-2a9c-41ff-b4ac-c213ae224465' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = 'ID')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        '1bc39b54-2a9c-41ff-b4ac-c213ae224465',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        'ID',
        'ID',
        'Primary key for the task risk assessment.',
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
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd5514b62-2d3e-4552-a46b-1fdf38e80353' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = 'TaskID')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        'd5514b62-2d3e-4552-a46b-1fdf38e80353',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        'TaskID',
        'Task',
        'The project root task (or tracked task) evaluated by this risk assessment.',
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
        1,
        0,
        0,
        'Search',
        GETUTCDATE(),
        GETUTCDATE()
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ff6995c4-122e-4146-bb29-05ea29fe0d54' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = 'AssessedAt')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        'ff6995c4-122e-4146-bb29-05ea29fe0d54',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        'AssessedAt',
        'Assessed At',
        'Timestamp when this risk assessment was produced.',
        'datetimeoffset',
        10,
        34,
        7,
        0,
        'sysdatetimeoffset()',
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
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '72389c68-539b-4e97-91fc-958fe3079dc9' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = 'ForecastCompletionDate')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        '72389c68-539b-4e97-91fc-958fe3079dc9',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        'ForecastCompletionDate',
        'Forecast Completion Date',
        'Forecasted completion timestamp estimated by the Project Risk Analyst.',
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
        1,
        0,
        0,
        'Search',
        GETUTCDATE(),
        GETUTCDATE()
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0ac7d448-708b-41fd-85f2-fd769f894889' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = 'ForecastConfidence')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        '0ac7d448-708b-41fd-85f2-fd769f894889',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        'ForecastConfidence',
        'Forecast Confidence',
        'Confidence score (0-100) in the forecasted completion date and health status, synced onto Task.ConfidenceScore.',
        'int',
        4,
        10,
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
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '37decbda-0bda-43aa-8778-4ca6f270d5b5' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = 'HealthStatus')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        '37decbda-0bda-43aa-8778-4ca6f270d5b5',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        'HealthStatus',
        'Health Status',
        'Assessed project health status: OnTrack, AtRisk, OffTrack, Completed, or Paused.',
        'nvarchar',
        40,
        0,
        0,
        0,
        'OnTrack',
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
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b8d32f3d-9329-4b50-87f8-20c9ed6ecb24' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = 'MLBreachProbability')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        'b8d32f3d-9329-4b50-87f8-20c9ed6ecb24',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        'MLBreachProbability',
        'ML Breach Probability',
        'ML model breach probability (0.0000 - 1.0000) consumed as one input to the risk assessment.',
        'decimal',
        5,
        5,
        4,
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
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c20d9c0f-46f8-412a-84f3-ffcdfe66454c' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = 'Risks')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        'c20d9c0f-46f8-412a-84f3-ffcdfe66454c',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        'Risks',
        'Risks',
        'JSON array of structured risk items ({ kind, severity, evidenceLinks, suggestedMitigation }).',
        'nvarchar',
        -1,
        0,
        0,
        0,
        '[]',
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
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '18d0d5bf-d2bf-4647-b0f1-4fb477d4753f' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = 'AgentRunID')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        '18d0d5bf-d2bf-4647-b0f1-4fb477d4753f',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        'AgentRunID',
        'Agent Run',
        'Optional MemberJunction AI Agent Run that generated this assessment.',
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
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ab3afa26-5936-4c81-9e63-a8c15955bd08' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = 'PromptTokens')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        'ab3afa26-5936-4c81-9e63-a8c15955bd08',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        'PromptTokens',
        'Prompt Tokens',
        'Input prompt token count consumed while generating this risk assessment.',
        'int',
        4,
        10,
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
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '18a15160-8342-4646-88c7-27f79bf053f9' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = 'CompletionTokens')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        '18a15160-8342-4646-88c7-27f79bf053f9',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        'CompletionTokens',
        'Completion Tokens',
        'Output completion token count generated for this risk assessment.',
        'int',
        4,
        10,
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
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'dd012ae3-3117-47d8-8acf-675bf4fca4ff' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = 'TotalCostUSD')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        'dd012ae3-3117-47d8-8acf-675bf4fca4ff',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        'TotalCostUSD',
        'Total Cost USD',
        'Total LLM inference cost in USD attributed to this risk assessment.',
        'decimal',
        9,
        19,
        8,
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
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0023b612-a08a-4780-8617-17b68dc1b025' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = '__mj_CreatedAt')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        '0023b612-a08a-4780-8617-17b68dc1b025',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        '__mj_CreatedAt',
        'Created At',
        'Record creation timestamp in UTC.',
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
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd9f0e762-536e-4d91-9e81-e67e8a4a57b5' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = '__mj_UpdatedAt')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        'd9f0e762-536e-4d91-9e81-e67e8a4a57b5',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        '__mj_UpdatedAt',
        'Updated At',
        'Record last-updated timestamp in UTC.',
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
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c9acc059-bfa8-4145-9276-786e7a1690a8' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = 'Task')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        'c9acc059-bfa8-4145-9276-786e7a1690a8',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        'Task',
        'Task Name',
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
    );
END;

IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '22ddab28-fd8e-4777-823f-822537ca17fa' OR (EntityID = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND Name = 'AgentRun')) BEGIN
    INSERT INTO [${mjSchema}].[EntityField]
    (
        [ID], [EntityID], [Sequence], [Name], [DisplayName], [Description],
        [Type], [Length], [Precision], [Scale], [AllowsNull], [DefaultValue],
        [AutoIncrement], [AllowUpdateAPI], [IsVirtual], [IsComputed],
        [RelatedEntityID], [RelatedEntityFieldName], [IsNameField],
        [IncludeInUserSearchAPI], [IncludeRelatedEntityNameFieldInBaseView],
        [DefaultInView], [IsPrimaryKey], [IsUnique], [RelatedEntityDisplayType],
        [__mj_CreatedAt], [__mj_UpdatedAt]
    )
    VALUES
    (
        '22ddab28-fd8e-4777-823f-822537ca17fa',
        '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
        (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'),
        'AgentRun',
        'Agent Run Name',
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
    );
END;

/* SQL text to sync 5 entity field value row(s) for TaskRiskAssessment.HealthStatus */
IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityFieldValue] WHERE [ID] = '39385cfd-df4a-4afe-b4aa-5c5d268ab137')
    INSERT INTO [${mjSchema}].[EntityFieldValue] ([ID], [EntityFieldID], [Sequence], [Value], [Code], [Source], [__mj_CreatedAt], [__mj_UpdatedAt])
    VALUES ('39385cfd-df4a-4afe-b4aa-5c5d268ab137', '37decbda-0bda-43aa-8778-4ca6f270d5b5', 1, 'AtRisk', 'AtRisk', 'Check', GETUTCDATE(), GETUTCDATE());
IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityFieldValue] WHERE [ID] = '37676547-e226-40b5-8009-935a285f8cff')
    INSERT INTO [${mjSchema}].[EntityFieldValue] ([ID], [EntityFieldID], [Sequence], [Value], [Code], [Source], [__mj_CreatedAt], [__mj_UpdatedAt])
    VALUES ('37676547-e226-40b5-8009-935a285f8cff', '37decbda-0bda-43aa-8778-4ca6f270d5b5', 2, 'Completed', 'Completed', 'Check', GETUTCDATE(), GETUTCDATE());
IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityFieldValue] WHERE [ID] = '2265f1f8-b6b1-4ac1-aa7b-9d71b91d960f')
    INSERT INTO [${mjSchema}].[EntityFieldValue] ([ID], [EntityFieldID], [Sequence], [Value], [Code], [Source], [__mj_CreatedAt], [__mj_UpdatedAt])
    VALUES ('2265f1f8-b6b1-4ac1-aa7b-9d71b91d960f', '37decbda-0bda-43aa-8778-4ca6f270d5b5', 3, 'OffTrack', 'OffTrack', 'Check', GETUTCDATE(), GETUTCDATE());
IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityFieldValue] WHERE [ID] = '253899ef-c0ec-47b0-b806-83b777479e0c')
    INSERT INTO [${mjSchema}].[EntityFieldValue] ([ID], [EntityFieldID], [Sequence], [Value], [Code], [Source], [__mj_CreatedAt], [__mj_UpdatedAt])
    VALUES ('253899ef-c0ec-47b0-b806-83b777479e0c', '37decbda-0bda-43aa-8778-4ca6f270d5b5', 4, 'OnTrack', 'OnTrack', 'Check', GETUTCDATE(), GETUTCDATE());
IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityFieldValue] WHERE [ID] = '7ca36f99-df06-4952-9a19-6d0841d1f441')
    INSERT INTO [${mjSchema}].[EntityFieldValue] ([ID], [EntityFieldID], [Sequence], [Value], [Code], [Source], [__mj_CreatedAt], [__mj_UpdatedAt])
    VALUES ('7ca36f99-df06-4952-9a19-6d0841d1f441', '37decbda-0bda-43aa-8778-4ca6f270d5b5', 5, 'Paused', 'Paused', 'Check', GETUTCDATE(), GETUTCDATE());

UPDATE [${mjSchema}].[EntityField] SET [ValueListType] = 'List' WHERE [ID] = '37decbda-0bda-43aa-8778-4ca6f270d5b5';

/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Task Risk Assessments (One To Many via TaskID) */
IF NOT EXISTS (
    SELECT 1 FROM [${mjSchema}].[EntityRelationship]
    WHERE [ID] = 'ed909e5b-eaf3-4913-ba4d-9ada74fa9a24'
       OR ([EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND [RelatedEntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND [RelatedEntityJoinField] = 'TaskID')
)
BEGIN
    INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
    VALUES ('ed909e5b-eaf3-4913-ba4d-9ada74fa9a24', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', 'TaskID', 'One To Many', 1, 1, 17, GETUTCDATE(), GETUTCDATE());
END;

/* Create Entity Relationship: MJ: AI Agent Runs -> MJ_BizApps_Tasks: Task Risk Assessments (One To Many via AgentRunID) */
IF NOT EXISTS (
    SELECT 1 FROM [${mjSchema}].[EntityRelationship]
    WHERE [ID] = '62c35b69-40fa-488a-a8ed-7def326e62f2'
       OR ([EntityID] = '5190AF93-4C39-4429-BDAA-0AEB492A0256' AND [RelatedEntityID] = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND [RelatedEntityJoinField] = 'AgentRunID')
)
BEGIN
    INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
    VALUES ('62c35b69-40fa-488a-a8ed-7def326e62f2', '5190AF93-4C39-4429-BDAA-0AEB492A0256', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', 'AgentRunID', 'One To Many', 1, 1, 18, GETUTCDATE(), GETUTCDATE());
END;

/* SQL text to sync schema info from database schemas */
EXEC [${mjSchema}].[spUpdateSchemaInfoFromDatabase] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to update existing entity fields from schema */
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* Index for Foreign Keys for TaskRiskAssessment */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskRiskAssessment_TaskID'
      AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskRiskAssessment]')
)
CREATE INDEX [IDX_AUTO_MJ_FKEY_TaskRiskAssessment_TaskID] ON [${flyway:defaultSchema}].[TaskRiskAssessment] ([TaskID]);
GO

/* Base View SQL for MJ_BizApps_Tasks: Task Risk Assessments */
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskRiskAssessments]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskRiskAssessments];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskRiskAssessments]
AS
SELECT
    tra.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    MJAIAgentRun_AgentRunID.[RunName] AS [AgentRun]
FROM
    [${flyway:defaultSchema}].[TaskRiskAssessment] AS tra
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [tra].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[AIAgentRun] AS MJAIAgentRun_AgentRunID
  ON
    [tra].[AgentRunID] = MJAIAgentRun_AgentRunID.[ID];
GO

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskRiskAssessments] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskRiskAssessments] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskRiskAssessments] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskRiskAssessments] TO [cdp_UI], [cdp_Developer], [cdp_Integration];
GO

/* spCreate SQL for MJ_BizApps_Tasks: Task Risk Assessments */
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskRiskAssessment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskRiskAssessment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskRiskAssessment]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @AssessedAt datetimeoffset = NULL,
    @ForecastCompletionDate_Clear bit = 0,
    @ForecastCompletionDate datetimeoffset = NULL,
    @ForecastConfidence_Clear bit = 0,
    @ForecastConfidence int = NULL,
    @HealthStatus nvarchar(20) = NULL,
    @MLBreachProbability_Clear bit = 0,
    @MLBreachProbability decimal(5, 4) = NULL,
    @Risks nvarchar(MAX) = NULL,
    @AgentRunID_Clear bit = 0,
    @AgentRunID uniqueidentifier = NULL,
    @PromptTokens_Clear bit = 0,
    @PromptTokens int = NULL,
    @CompletionTokens_Clear bit = 0,
    @CompletionTokens int = NULL,
    @TotalCostUSD_Clear bit = 0,
    @TotalCostUSD decimal(19, 8) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER);

    IF @ID IS NOT NULL
    BEGIN
        INSERT INTO [${flyway:defaultSchema}].[TaskRiskAssessment]
            (
                [ID],
                [TaskID],
                [AssessedAt],
                [ForecastCompletionDate],
                [ForecastConfidence],
                [HealthStatus],
                [MLBreachProbability],
                [Risks],
                [AgentRunID],
                [PromptTokens],
                [CompletionTokens],
                [TotalCostUSD]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaskID,
                ISNULL(@AssessedAt, SYSDATETIMEOFFSET()),
                CASE WHEN @ForecastCompletionDate_Clear = 1 THEN NULL ELSE ISNULL(@ForecastCompletionDate, NULL) END,
                CASE WHEN @ForecastConfidence_Clear = 1 THEN NULL ELSE ISNULL(@ForecastConfidence, NULL) END,
                ISNULL(@HealthStatus, 'OnTrack'),
                CASE WHEN @MLBreachProbability_Clear = 1 THEN NULL ELSE ISNULL(@MLBreachProbability, NULL) END,
                ISNULL(@Risks, N'[]'),
                CASE WHEN @AgentRunID_Clear = 1 THEN NULL ELSE ISNULL(@AgentRunID, NULL) END,
                CASE WHEN @PromptTokens_Clear = 1 THEN NULL ELSE ISNULL(@PromptTokens, NULL) END,
                CASE WHEN @CompletionTokens_Clear = 1 THEN NULL ELSE ISNULL(@CompletionTokens, NULL) END,
                CASE WHEN @TotalCostUSD_Clear = 1 THEN NULL ELSE ISNULL(@TotalCostUSD, NULL) END
            );
    END
    ELSE
    BEGIN
        INSERT INTO [${flyway:defaultSchema}].[TaskRiskAssessment]
            (
                [TaskID],
                [AssessedAt],
                [ForecastCompletionDate],
                [ForecastConfidence],
                [HealthStatus],
                [MLBreachProbability],
                [Risks],
                [AgentRunID],
                [PromptTokens],
                [CompletionTokens],
                [TotalCostUSD]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaskID,
                ISNULL(@AssessedAt, SYSDATETIMEOFFSET()),
                CASE WHEN @ForecastCompletionDate_Clear = 1 THEN NULL ELSE ISNULL(@ForecastCompletionDate, NULL) END,
                CASE WHEN @ForecastConfidence_Clear = 1 THEN NULL ELSE ISNULL(@ForecastConfidence, NULL) END,
                ISNULL(@HealthStatus, 'OnTrack'),
                CASE WHEN @MLBreachProbability_Clear = 1 THEN NULL ELSE ISNULL(@MLBreachProbability, NULL) END,
                ISNULL(@Risks, N'[]'),
                CASE WHEN @AgentRunID_Clear = 1 THEN NULL ELSE ISNULL(@AgentRunID, NULL) END,
                CASE WHEN @PromptTokens_Clear = 1 THEN NULL ELSE ISNULL(@PromptTokens, NULL) END,
                CASE WHEN @CompletionTokens_Clear = 1 THEN NULL ELSE ISNULL(@CompletionTokens, NULL) END,
                CASE WHEN @TotalCostUSD_Clear = 1 THEN NULL ELSE ISNULL(@TotalCostUSD, NULL) END
            );
    END

    SELECT * FROM [${flyway:defaultSchema}].[vwTaskRiskAssessments] WHERE [ID] = (SELECT [ID] FROM @InsertedRow);
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskRiskAssessment] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskRiskAssessment] FROM [cdp_Integration]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskRiskAssessment] FROM [cdp_UI]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskRiskAssessment] TO [cdp_UI], [cdp_Developer], [cdp_Integration];
GO

/* spUpdate SQL for MJ_BizApps_Tasks: Task Risk Assessments */
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskRiskAssessment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskRiskAssessment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskRiskAssessment]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier = NULL,
    @AssessedAt datetimeoffset = NULL,
    @ForecastCompletionDate_Clear bit = 0,
    @ForecastCompletionDate datetimeoffset = NULL,
    @ForecastConfidence_Clear bit = 0,
    @ForecastConfidence int = NULL,
    @HealthStatus nvarchar(20) = NULL,
    @MLBreachProbability_Clear bit = 0,
    @MLBreachProbability decimal(5, 4) = NULL,
    @Risks nvarchar(MAX) = NULL,
    @AgentRunID_Clear bit = 0,
    @AgentRunID uniqueidentifier = NULL,
    @PromptTokens_Clear bit = 0,
    @PromptTokens int = NULL,
    @CompletionTokens_Clear bit = 0,
    @CompletionTokens int = NULL,
    @TotalCostUSD_Clear bit = 0,
    @TotalCostUSD decimal(19, 8) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskRiskAssessment]
    SET
        [TaskID] = ISNULL(@TaskID, [TaskID]),
        [AssessedAt] = ISNULL(@AssessedAt, [AssessedAt]),
        [ForecastCompletionDate] = CASE WHEN @ForecastCompletionDate_Clear = 1 THEN NULL ELSE ISNULL(@ForecastCompletionDate, [ForecastCompletionDate]) END,
        [ForecastConfidence] = CASE WHEN @ForecastConfidence_Clear = 1 THEN NULL ELSE ISNULL(@ForecastConfidence, [ForecastConfidence]) END,
        [HealthStatus] = ISNULL(@HealthStatus, [HealthStatus]),
        [MLBreachProbability] = CASE WHEN @MLBreachProbability_Clear = 1 THEN NULL ELSE ISNULL(@MLBreachProbability, [MLBreachProbability]) END,
        [Risks] = ISNULL(@Risks, [Risks]),
        [AgentRunID] = CASE WHEN @AgentRunID_Clear = 1 THEN NULL ELSE ISNULL(@AgentRunID, [AgentRunID]) END,
        [PromptTokens] = CASE WHEN @PromptTokens_Clear = 1 THEN NULL ELSE ISNULL(@PromptTokens, [PromptTokens]) END,
        [CompletionTokens] = CASE WHEN @CompletionTokens_Clear = 1 THEN NULL ELSE ISNULL(@CompletionTokens, [CompletionTokens]) END,
        [TotalCostUSD] = CASE WHEN @TotalCostUSD_Clear = 1 THEN NULL ELSE ISNULL(@TotalCostUSD, [TotalCostUSD]) END,
        [__mj_UpdatedAt] = GETUTCDATE()
    WHERE
        [ID] = @ID;

    IF @@ROWCOUNT = 0
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskRiskAssessments] WHERE 1=0;
    ELSE
        SELECT * FROM [${flyway:defaultSchema}].[vwTaskRiskAssessments] WHERE [ID] = @ID;
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskRiskAssessment] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskRiskAssessment] FROM [cdp_Integration]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskRiskAssessment] FROM [cdp_UI]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskRiskAssessment] TO [cdp_UI], [cdp_Developer], [cdp_Integration];
GO

IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskRiskAssessment]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskRiskAssessment];
GO
CREATE TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskRiskAssessment]
ON [${flyway:defaultSchema}].[TaskRiskAssessment]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE([__mj_UpdatedAt])
    BEGIN
        UPDATE [${flyway:defaultSchema}].[TaskRiskAssessment]
        SET [__mj_UpdatedAt] = GETUTCDATE()
        FROM [${flyway:defaultSchema}].[TaskRiskAssessment] AS _organicTable
        INNER JOIN INSERTED AS I ON _organicTable.[ID] = I.[ID];
    END
END;
GO

/* spDelete SQL for MJ_BizApps_Tasks: Task Risk Assessments */
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskRiskAssessment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskRiskAssessment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskRiskAssessment]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [${flyway:defaultSchema}].[TaskRiskAssessment]
    WHERE [ID] = @ID;

    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID];
    ELSE
        SELECT @ID AS [ID];
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskRiskAssessment] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskRiskAssessment] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskRiskAssessment] TO [cdp_Developer], [cdp_Integration];
GO

/* Refresh Task views & CRUD procedures to include ForecastCompletionDate */
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
    mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID.[Name] AS [TaskTypeStatus],
    mjBizAppsCommonOrganization_OrganizationID.[Name] AS [Organization]
FROM
    [${flyway:defaultSchema}].[Task] AS t
LEFT OUTER JOIN
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
LEFT OUTER JOIN
    [__mj_BizAppsCommon].[Organization] AS mjBizAppsCommonOrganization_OrganizationID
  ON
    [t].[OrganizationID] = mjBizAppsCommonOrganization_OrganizationID.[ID];
GO

EXEC sp_refreshview '${flyway:defaultSchema}.vwTasksGenerated';
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTasks]', 'V') IS NOT NULL
BEGIN
    EXEC sp_executesql N'EXEC sp_refreshview ''${flyway:defaultSchema}.vwTasks'';';
    EXEC sp_executesql N'REVOKE SELECT ON [${flyway:defaultSchema}].[vwTasks] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTasks] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTasks] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTasks] TO [cdp_UI], [cdp_Developer], [cdp_Integration]';
END;
GO

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
    @NextCheckInDueAt datetimeoffset = NULL,
    @OrganizationID_Clear bit = 0,
    @OrganizationID uniqueidentifier = NULL,
    @Visibility nvarchar(20) = NULL,
    @ForecastCompletionDate_Clear bit = 0,
    @ForecastCompletionDate datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        INSERT INTO [${flyway:defaultSchema}].[Task]
            (
                [ID], [Name], [Description], [TypeID], [CategoryID], [ParentID],
                [Status], [Priority], [StartedAt], [DueAt], [CompletedAt],
                [HoursEstimated], [HoursActual], [PercentComplete], [Sequence],
                [BlockedReason], [CompletionNotes], [CreatedByPersonID],
                [OverdueNotifiedAt], [TaskTypeStatusID],
                [PredictedSLABreachProbability], [PredictedSLARiskBand], [PredictedSLAScoredAt],
                [HealthStatus], [ConfidenceScore], [BaselineValue], [TargetValue], [CurrentValue],
                [UnitOfMeasure], [MetricDirection], [RollupWeight], [PlanningPeriod],
                [CheckInCadence], [LastCheckInAt], [NextCheckInDueAt],
                [OrganizationID], [Visibility], [ForecastCompletionDate]
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
                CASE WHEN @NextCheckInDueAt_Clear = 1 THEN NULL ELSE ISNULL(@NextCheckInDueAt, NULL) END,
                CASE WHEN @OrganizationID_Clear = 1 THEN NULL ELSE ISNULL(@OrganizationID, NULL) END,
                ISNULL(@Visibility, 'Standard'),
                CASE WHEN @ForecastCompletionDate_Clear = 1 THEN NULL ELSE ISNULL(@ForecastCompletionDate, NULL) END
            )
    END
    ELSE
    BEGIN
        INSERT INTO [${flyway:defaultSchema}].[Task]
            (
                [Name], [Description], [TypeID], [CategoryID], [ParentID],
                [Status], [Priority], [StartedAt], [DueAt], [CompletedAt],
                [HoursEstimated], [HoursActual], [PercentComplete], [Sequence],
                [BlockedReason], [CompletionNotes], [CreatedByPersonID],
                [OverdueNotifiedAt], [TaskTypeStatusID],
                [PredictedSLABreachProbability], [PredictedSLARiskBand], [PredictedSLAScoredAt],
                [HealthStatus], [ConfidenceScore], [BaselineValue], [TargetValue], [CurrentValue],
                [UnitOfMeasure], [MetricDirection], [RollupWeight], [PlanningPeriod],
                [CheckInCadence], [LastCheckInAt], [NextCheckInDueAt],
                [OrganizationID], [Visibility], [ForecastCompletionDate]
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
                CASE WHEN @NextCheckInDueAt_Clear = 1 THEN NULL ELSE ISNULL(@NextCheckInDueAt, NULL) END,
                CASE WHEN @OrganizationID_Clear = 1 THEN NULL ELSE ISNULL(@OrganizationID, NULL) END,
                ISNULL(@Visibility, 'Standard'),
                CASE WHEN @ForecastCompletionDate_Clear = 1 THEN NULL ELSE ISNULL(@ForecastCompletionDate, NULL) END
            )
    END
    SELECT * FROM [${flyway:defaultSchema}].[vwTasks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Integration]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_UI]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] TO [cdp_UI], [cdp_Developer], [cdp_Integration];
GO

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
    @NextCheckInDueAt datetimeoffset = NULL,
    @OrganizationID_Clear bit = 0,
    @OrganizationID uniqueidentifier = NULL,
    @Visibility nvarchar(20) = NULL,
    @ForecastCompletionDate_Clear bit = 0,
    @ForecastCompletionDate datetimeoffset = NULL
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
        [NextCheckInDueAt] = CASE WHEN @NextCheckInDueAt_Clear = 1 THEN NULL ELSE ISNULL(@NextCheckInDueAt, [NextCheckInDueAt]) END,
        [OrganizationID] = CASE WHEN @OrganizationID_Clear = 1 THEN NULL ELSE ISNULL(@OrganizationID, [OrganizationID]) END,
        [Visibility] = ISNULL(@Visibility, [Visibility]),
        [ForecastCompletionDate] = CASE WHEN @ForecastCompletionDate_Clear = 1 THEN NULL ELSE ISNULL(@ForecastCompletionDate, [ForecastCompletionDate]) END,
        [__mj_UpdatedAt] = GETUTCDATE()
    WHERE
        [ID] = @ID

    IF @@ROWCOUNT = 0
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTasks] WHERE 1=0
    ELSE
        SELECT * FROM [${flyway:defaultSchema}].[vwTasks] WHERE [ID] = @ID
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_Integration]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_UI]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] TO [cdp_UI], [cdp_Developer], [cdp_Integration];
GO

EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='', @EntityIDs='B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466,4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', @IncludedSchemaNames='${flyway:defaultSchema}';
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';
GO
