-- =============================================================================
-- BizAppsTasks: Priority / OKR Tracking Columns on Task & TaskCheckIn Table
-- Extends Task to support Objectives & Key Results (OKRs) and structured
-- periodic check-ins (manual or Chief of Staff AI-authored).
-- =============================================================================

---------------------------------------------------------------------------
-- 1. Task: Add Priority / OKR & Check-In Rhythm Columns
---------------------------------------------------------------------------
ALTER TABLE [${flyway:defaultSchema}].[Task]
    ADD [HealthStatus] NVARCHAR(20) NULL,
        [ConfidenceScore] INT NULL,
        [BaselineValue] DECIMAL(18, 4) NULL,
        [TargetValue] DECIMAL(18, 4) NULL,
        [CurrentValue] DECIMAL(18, 4) NULL,
        [UnitOfMeasure] NVARCHAR(50) NULL,
        [MetricDirection] NVARCHAR(20) NULL,
        [RollupWeight] DECIMAL(8, 2) NOT NULL CONSTRAINT [DF_Task_RollupWeight] DEFAULT (1.00),
        [PlanningPeriod] NVARCHAR(50) NULL,
        [CheckInCadence] NVARCHAR(20) NULL,
        [LastCheckInAt] DATETIMEOFFSET NULL,
        [NextCheckInDueAt] DATETIMEOFFSET NULL;
GO

ALTER TABLE [${flyway:defaultSchema}].[Task]
    ADD CONSTRAINT [CK_Task_HealthStatus]
        CHECK ([HealthStatus] IS NULL OR [HealthStatus] IN ('OnTrack', 'AtRisk', 'OffTrack', 'Completed', 'Paused')),
        CONSTRAINT [CK_Task_ConfidenceScore]
        CHECK ([ConfidenceScore] IS NULL OR ([ConfidenceScore] >= 0 AND [ConfidenceScore] <= 100)),
        CONSTRAINT [CK_Task_MetricDirection]
        CHECK ([MetricDirection] IS NULL OR [MetricDirection] IN ('Increase', 'Decrease', 'Maintain')),
        CONSTRAINT [CK_Task_CheckInCadence]
        CHECK ([CheckInCadence] IS NULL OR [CheckInCadence] IN ('Daily', 'Weekly', 'BiWeekly', 'Monthly', 'Quarterly', 'None'));
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Qualitative health status for priority/OKR tracking: OnTrack, AtRisk, OffTrack, Completed, or Paused.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Task',
    @level2type = N'COLUMN', @level2name = N'HealthStatus';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Owner confidence score (0-100) that this task, key result, or objective will hit its target on time.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Task',
    @level2type = N'COLUMN', @level2name = N'ConfidenceScore';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Starting baseline value for measurable key results or quantitative deliverables.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Task',
    @level2type = N'COLUMN', @level2name = N'BaselineValue';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Target goal value for measurable key results or quantitative deliverables.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Task',
    @level2type = N'COLUMN', @level2name = N'TargetValue';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Latest actual measured value for this key result or deliverable, updated automatically by TaskCheckIn records.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Task',
    @level2type = N'COLUMN', @level2name = N'CurrentValue';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unit of measure for BaselineValue, TargetValue, and CurrentValue (e.g., %, USD, Days, Customers, NPS).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Task',
    @level2type = N'COLUMN', @level2name = N'UnitOfMeasure';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Direction of improvement for quantitative metrics: Increase, Decrease, or Maintain.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Task',
    @level2type = N'COLUMN', @level2name = N'MetricDirection';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Relative weight (default 1.00) when rolling up child task or key result progress into a parent objective.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Task',
    @level2type = N'COLUMN', @level2name = N'RollupWeight';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Planning horizon or OKR cycle identifier (e.g., 2026-Q4, FY2027, H1-2026).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Task',
    @level2type = N'COLUMN', @level2name = N'PlanningPeriod';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Expected progress check-in frequency: Daily, Weekly, BiWeekly, Monthly, Quarterly, or None.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Task',
    @level2type = N'COLUMN', @level2name = N'CheckInCadence';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the most recent TaskCheckIn was recorded for this task.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Task',
    @level2type = N'COLUMN', @level2name = N'LastCheckInAt';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the next progress check-in is due based on CheckInCadence; used by Chief of Staff to nudge owners.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Task',
    @level2type = N'COLUMN', @level2name = N'NextCheckInDueAt';
GO

---------------------------------------------------------------------------
-- 2. TaskCheckIn: Structured periodic progress updates for Tasks / OKRs
---------------------------------------------------------------------------
CREATE TABLE [${flyway:defaultSchema}].[TaskCheckIn] (
    [ID] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_TaskCheckIn_ID] DEFAULT (NEWSEQUENTIALID()),
    [TaskID] UNIQUEIDENTIFIER NOT NULL,
    [AuthorPersonID] UNIQUEIDENTIFIER NULL,
    [AuthorUserID] UNIQUEIDENTIFIER NULL,
    [ReportedByAIAgentID] UNIQUEIDENTIFIER NULL,
    [CheckInAt] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_TaskCheckIn_CheckInAt] DEFAULT (SYSDATETIMEOFFSET()),
    [HealthStatus] NVARCHAR(20) NOT NULL CONSTRAINT [DF_TaskCheckIn_HealthStatus] DEFAULT ('OnTrack'),
    [ConfidenceScore] INT NULL,
    [PreviousValue] DECIMAL(18, 4) NULL,
    [NewValue] DECIMAL(18, 4) NULL,
    [PercentComplete] INT NULL,
    [Summary] NVARCHAR(MAX) NOT NULL,
    [Blockers] NVARCHAR(MAX) NULL,
    [NextSteps] NVARCHAR(MAX) NULL,
    CONSTRAINT [PK_TaskCheckIn] PRIMARY KEY ([ID]),
    CONSTRAINT [FK_TaskCheckIn_Task] FOREIGN KEY ([TaskID]) REFERENCES [${flyway:defaultSchema}].[Task]([ID]),
    CONSTRAINT [FK_TaskCheckIn_AuthorPerson] FOREIGN KEY ([AuthorPersonID]) REFERENCES [__mj_BizAppsCommon].[Person]([ID]),
    CONSTRAINT [FK_TaskCheckIn_AuthorUser] FOREIGN KEY ([AuthorUserID]) REFERENCES [${mjSchema}].[User]([ID]),
    CONSTRAINT [FK_TaskCheckIn_AIAgent] FOREIGN KEY ([ReportedByAIAgentID]) REFERENCES [${mjSchema}].[AIAgent]([ID]),
    CONSTRAINT [CK_TaskCheckIn_HealthStatus] CHECK ([HealthStatus] IN ('OnTrack', 'AtRisk', 'OffTrack', 'Completed', 'Paused')),
    CONSTRAINT [CK_TaskCheckIn_ConfidenceScore] CHECK ([ConfidenceScore] IS NULL OR ([ConfidenceScore] >= 0 AND [ConfidenceScore] <= 100)),
    CONSTRAINT [CK_TaskCheckIn_PercentComplete] CHECK ([PercentComplete] IS NULL OR ([PercentComplete] >= 0 AND [PercentComplete] <= 100))
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Structured periodic progress check-ins for tasks, priorities, and OKRs, authored by users or AI agents such as Chief of Staff.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskCheckIn';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The task, priority objective, or key result this check-in updates.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskCheckIn',
    @level2type = N'COLUMN', @level2name = N'TaskID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional Person record who authored or approved the check-in.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskCheckIn',
    @level2type = N'COLUMN', @level2name = N'AuthorPersonID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional MemberJunction User who authored or submitted the check-in.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskCheckIn',
    @level2type = N'COLUMN', @level2name = N'AuthorUserID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional AI Agent (e.g., Chief of Staff) that synthesized and recorded this check-in.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskCheckIn',
    @level2type = N'COLUMN', @level2name = N'ReportedByAIAgentID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the check-in occurred.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskCheckIn',
    @level2type = N'COLUMN', @level2name = N'CheckInAt';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Health status reported at check-in: OnTrack, AtRisk, OffTrack, Completed, or Paused.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskCheckIn',
    @level2type = N'COLUMN', @level2name = N'HealthStatus';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Confidence score (0-100) reported at the time of check-in.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskCheckIn',
    @level2type = N'COLUMN', @level2name = N'ConfidenceScore';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Metric value prior to this check-in.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskCheckIn',
    @level2type = N'COLUMN', @level2name = N'PreviousValue';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Updated metric value reported in this check-in.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskCheckIn',
    @level2type = N'COLUMN', @level2name = N'NewValue';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Percent complete (0-100) reported or computed in this check-in.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskCheckIn',
    @level2type = N'COLUMN', @level2name = N'PercentComplete';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Narrative summary of accomplishments and status since the last check-in.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskCheckIn',
    @level2type = N'COLUMN', @level2name = N'Summary';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Risks, impediments, or cross-team blockers surfaced during the check-in.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskCheckIn',
    @level2type = N'COLUMN', @level2name = N'Blockers';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Planned next steps and commitments before the next check-in.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskCheckIn',
    @level2type = N'COLUMN', @level2name = N'NextSteps';
GO

---------------------------------------------------------------------------
-- 3. Refresh Layered Base Views (vwTasksGenerated & vwTasks)
---------------------------------------------------------------------------
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
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_CreatedByPersonID
  ON
    [t].[CreatedByPersonID] = mjBizAppsCommonPerson_CreatedByPersonID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskTypeStatus] AS mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID
  ON
    [t].[TaskTypeStatusID] = mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID.[ID];
GO

IF OBJECT_ID('[${flyway:defaultSchema}].[vwTasks]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTasks];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTasks]
AS
SELECT
    g.*,
    root_ParentID.RootID AS [RootParentID],
    CASE 
        WHEN g.[CompletedAt] IS NOT NULL AND g.[DueAt] IS NOT NULL THEN 
            CASE WHEN g.[CompletedAt] > g.[DueAt] THEN 'Breached' ELSE 'Met' END
        ELSE NULL 
    END AS [IsSLABreached],
    CASE 
        WHEN g.[StartedAt] IS NOT NULL AND g.[DueAt] IS NOT NULL THEN 
            DATEDIFF(day, g.[StartedAt], g.[DueAt]) 
        WHEN g.[__mj_CreatedAt] IS NOT NULL AND g.[DueAt] IS NOT NULL THEN 
            DATEDIFF(day, g.[__mj_CreatedAt], g.[DueAt]) 
        ELSE NULL 
    END AS [LeadDays],
    ISNULL(a.[AssignmentsCount], 0) AS [AssignmentsCount],
    ISNULL(c.[CommentsCount], 0) AS [CommentsCount]
FROM
    [${flyway:defaultSchema}].[vwTasksGenerated] AS g
OUTER APPLY
    [${flyway:defaultSchema}].[fnTaskParentID_GetRootID]([g].[ID], [g].[ParentID]) AS root_ParentID
LEFT OUTER JOIN (
    SELECT [TaskID], COUNT(*) AS [AssignmentsCount]
    FROM [${flyway:defaultSchema}].[TaskAssignment]
    GROUP BY [TaskID]
) AS a ON a.[TaskID] = g.[ID]
LEFT OUTER JOIN (
    SELECT [TaskID], COUNT(*) AS [CommentsCount]
    FROM [${flyway:defaultSchema}].[TaskComment]
    GROUP BY [TaskID]
) AS c ON c.[TaskID] = g.[ID];
GO

IF DATABASE_PRINCIPAL_ID('cdp_UI') IS NOT NULL
    EXEC('GRANT SELECT ON [${flyway:defaultSchema}].[vwTasks] TO [cdp_UI]');
IF DATABASE_PRINCIPAL_ID('cdp_Developer') IS NOT NULL
    EXEC('GRANT SELECT ON [${flyway:defaultSchema}].[vwTasks] TO [cdp_Developer]');
IF DATABASE_PRINCIPAL_ID('cdp_Integration') IS NOT NULL
    EXEC('GRANT SELECT ON [${flyway:defaultSchema}].[vwTasks] TO [cdp_Integration]');
GO























































-- =============================================================================
-- GENERATED BY MemberJunction CodeGen — DO NOT EDIT BY HAND
-- =============================================================================

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Check Ins */

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
         '360ce0db-7207-4d3c-a35f-2f45c22a5399',
         'MJ_BizApps_Tasks: Task Check Ins',
         'Task Check Ins',
         'Structured periodic progress check-ins for tasks, priorities, and OKRs, authored by users or AI agents such as Chief of Staff.',
         NULL,
         'TaskCheckIn',
         'vwTaskCheckIns',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Check Ins to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '360ce0db-7207-4d3c-a35f-2f45c22a5399', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Check Ins for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Check Ins for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Check Ins for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL text to update existing entities from schema */
EXEC [${mjSchema}].[spUpdateExistingEntitiesFromSchema] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskCheckIn */
ALTER TABLE [${flyway:defaultSchema}].[TaskCheckIn] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskCheckIn */
UPDATE [${flyway:defaultSchema}].[TaskCheckIn] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskCheckIn */
ALTER TABLE [${flyway:defaultSchema}].[TaskCheckIn] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskCheckIn */
ALTER TABLE [${flyway:defaultSchema}].[TaskCheckIn] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskCheckIn___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskCheckIn */
ALTER TABLE [${flyway:defaultSchema}].[TaskCheckIn] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskCheckIn */
UPDATE [${flyway:defaultSchema}].[TaskCheckIn] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskCheckIn */
ALTER TABLE [${flyway:defaultSchema}].[TaskCheckIn] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskCheckIn */
ALTER TABLE [${flyway:defaultSchema}].[TaskCheckIn] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskCheckIn___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to insert 28 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b4b892af-baa4-4ecd-a99b-1a34bbb21723' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'ID')) BEGIN
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
            'b4b892af-baa4-4ecd-a99b-1a34bbb21723',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '228c3ad3-a70a-44ab-8d35-49acd8450741' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'TaskID')) BEGIN
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
            '228c3ad3-a70a-44ab-8d35-49acd8450741',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'TaskID',
            'Task ID',
            'The task, priority objective, or key result this check-in updates.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c7db972b-3cb3-48ab-81ef-ac4f4d9801a1' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'AuthorPersonID')) BEGIN
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
            'c7db972b-3cb3-48ab-81ef-ac4f4d9801a1',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'AuthorPersonID',
            'Author Person ID',
            'Optional Person record who authored or approved the check-in.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8b69c4d1-c536-4063-b775-fbee891cca7a' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'AuthorUserID')) BEGIN
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
            '8b69c4d1-c536-4063-b775-fbee891cca7a',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'AuthorUserID',
            'Author User ID',
            'Optional MemberJunction User who authored or submitted the check-in.',
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
            'E1238F34-2837-EF11-86D4-6045BDEE16E6',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8d0d30ae-8449-4921-b155-3eb275e824d1' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'ReportedByAIAgentID')) BEGIN
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
            '8d0d30ae-8449-4921-b155-3eb275e824d1',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'ReportedByAIAgentID',
            'Reported By AI Agent ID',
            'Optional AI Agent (e.g., Chief of Staff) that synthesized and recorded this check-in.',
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
            'CDB135CC-6D3C-480B-90AE-25B7805F82C1',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9637e429-90e1-4016-9be7-635b0c446dfc' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'CheckInAt')) BEGIN
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
            '9637e429-90e1-4016-9be7-635b0c446dfc',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'CheckInAt',
            'Check In At',
            'Timestamp when the check-in occurred.',
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
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7da8b600-d924-4822-b80b-b273cb41feab' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'HealthStatus')) BEGIN
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
            '7da8b600-d924-4822-b80b-b273cb41feab',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'HealthStatus',
            'Health Status',
            'Health status reported at check-in: OnTrack, AtRisk, OffTrack, Completed, or Paused.',
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
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9fc7a284-c3df-4b94-910d-c2460dbde8ab' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'ConfidenceScore')) BEGIN
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
            '9fc7a284-c3df-4b94-910d-c2460dbde8ab',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'ConfidenceScore',
            'Confidence Score',
            'Confidence score (0-100) reported at the time of check-in.',
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
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6df3ec7b-6920-4a83-a2f0-afc43a64a91b' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'PreviousValue')) BEGIN
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
            '6df3ec7b-6920-4a83-a2f0-afc43a64a91b',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'PreviousValue',
            'Previous Value',
            'Metric value prior to this check-in.',
            'decimal',
            9,
            18,
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
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3db75504-f5f0-4f85-8bbf-5e8ff7e6932b' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'NewValue')) BEGIN
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
            '3db75504-f5f0-4f85-8bbf-5e8ff7e6932b',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'NewValue',
            'New Value',
            'Updated metric value reported in this check-in.',
            'decimal',
            9,
            18,
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
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd4261555-e5e9-4b47-9c76-c212559758de' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'PercentComplete')) BEGIN
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
            'd4261555-e5e9-4b47-9c76-c212559758de',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'PercentComplete',
            'Percent Complete',
            'Percent complete (0-100) reported or computed in this check-in.',
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
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5bd1ecac-1336-4545-82b7-54f7d773c10c' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'Summary')) BEGIN
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
            '5bd1ecac-1336-4545-82b7-54f7d773c10c',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'Summary',
            'Summary',
            'Narrative summary of accomplishments and status since the last check-in.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '05563452-fab1-4bbc-81c1-4c0949f62e87' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'Blockers')) BEGIN
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
            '05563452-fab1-4bbc-81c1-4c0949f62e87',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'Blockers',
            'Blockers',
            'Risks, impediments, or cross-team blockers surfaced during the check-in.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '393f9b09-36a3-4bc2-9b79-8dd6218d265d' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'NextSteps')) BEGIN
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
            '393f9b09-36a3-4bc2-9b79-8dd6218d265d',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'NextSteps',
            'Next Steps',
            'Planned next steps and commitments before the next check-in.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '515acc10-2c6a-4cc7-a720-0fc2d8427ef0' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = '__mj_CreatedAt')) BEGIN
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
            '515acc10-2c6a-4cc7-a720-0fc2d8427ef0',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd6ec2e84-5bf9-495a-a614-6221af56e9ba' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'd6ec2e84-5bf9-495a-a614-6221af56e9ba',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7532fdf8-d979-441e-9dad-8d3f9e55a84e' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'HealthStatus')) BEGIN
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
            '7532fdf8-d979-441e-9dad-8d3f9e55a84e',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'HealthStatus',
            'Health Status',
            'Qualitative health status for priority/OKR tracking: OnTrack, AtRisk, OffTrack, Completed, or Paused.',
            'nvarchar',
            40,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a5ca80f8-1ab4-43df-98ec-926d88c95da0' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'ConfidenceScore')) BEGIN
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
            'a5ca80f8-1ab4-43df-98ec-926d88c95da0',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'ConfidenceScore',
            'Confidence Score',
            'Owner confidence score (0-100) that this task, key result, or objective will hit its target on time.',
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
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '07437566-1823-4882-b196-b4473a824190' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'BaselineValue')) BEGIN
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
            '07437566-1823-4882-b196-b4473a824190',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'BaselineValue',
            'Baseline Value',
            'Starting baseline value for measurable key results or quantitative deliverables.',
            'decimal',
            9,
            18,
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
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '346dcca6-8dd6-40f4-ad44-0adae04afa36' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'TargetValue')) BEGIN
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
            '346dcca6-8dd6-40f4-ad44-0adae04afa36',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'TargetValue',
            'Target Value',
            'Target goal value for measurable key results or quantitative deliverables.',
            'decimal',
            9,
            18,
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
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'eeeb991a-70c8-4ae1-a1bc-859047d74135' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'CurrentValue')) BEGIN
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
            'eeeb991a-70c8-4ae1-a1bc-859047d74135',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'CurrentValue',
            'Current Value',
            'Latest actual measured value for this key result or deliverable, updated automatically by TaskCheckIn records.',
            'decimal',
            9,
            18,
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
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'af223c6d-6f70-4c13-8bf6-c61aa27173f8' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'UnitOfMeasure')) BEGIN
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
            'af223c6d-6f70-4c13-8bf6-c61aa27173f8',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'UnitOfMeasure',
            'Unit Of Measure',
            'Unit of measure for BaselineValue, TargetValue, and CurrentValue (e.g., %, USD, Days, Customers, NPS).',
            'nvarchar',
            100,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'defbd4e1-c3c0-48d4-b297-b4c1ebe75a56' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'MetricDirection')) BEGIN
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
            'defbd4e1-c3c0-48d4-b297-b4c1ebe75a56',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'MetricDirection',
            'Metric Direction',
            'Direction of improvement for quantitative metrics: Increase, Decrease, or Maintain.',
            'nvarchar',
            40,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '65e2f993-2fe6-4889-9d58-e57ecfbfc82a' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'RollupWeight')) BEGIN
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
            '65e2f993-2fe6-4889-9d58-e57ecfbfc82a',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'RollupWeight',
            'Rollup Weight',
            'Relative weight (default 1.00) when rolling up child task or key result progress into a parent objective.',
            'decimal',
            5,
            8,
            2,
            0,
            '(1.00)',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ab060b49-73e6-4925-a734-772a6e615a1e' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'PlanningPeriod')) BEGIN
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
            'ab060b49-73e6-4925-a734-772a6e615a1e',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'PlanningPeriod',
            'Planning Period',
            'Planning horizon or OKR cycle identifier (e.g., 2026-Q4, FY2027, H1-2026).',
            'nvarchar',
            100,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'cbbe3a1d-b115-4906-af54-42adce9a5973' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'CheckInCadence')) BEGIN
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
            'cbbe3a1d-b115-4906-af54-42adce9a5973',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'CheckInCadence',
            'Check In Cadence',
            'Expected progress check-in frequency: Daily, Weekly, BiWeekly, Monthly, Quarterly, or None.',
            'nvarchar',
            40,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'df95636f-e402-40e1-a53c-7abb34996f9e' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'LastCheckInAt')) BEGIN
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
            'df95636f-e402-40e1-a53c-7abb34996f9e',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'LastCheckInAt',
            'Last Check In At',
            'Timestamp when the most recent TaskCheckIn was recorded for this task.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3828d96c-44e3-40c8-a907-b7a916a829d6' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'NextCheckInDueAt')) BEGIN
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
            '3828d96c-44e3-40c8-a907-b7a916a829d6',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'NextCheckInDueAt',
            'Next Check In Due At',
            'Timestamp when the next progress check-in is due based on CheckInCadence; used by Chief of Staff to nudge owners.',
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

/* SQL text to update existing entity fields from schema */
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to insert entity field value with ID 2d1da61d-caae-490a-b3c5-9b9eeea3e98b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('2d1da61d-caae-490a-b3c5-9b9eeea3e98b', '7532FDF8-D979-441E-9DAD-8D3F9E55A84E', 1, 'AtRisk', 'AtRisk', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 0e381e48-b41d-49dc-8c77-2a3e2412f240 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0e381e48-b41d-49dc-8c77-2a3e2412f240', '7532FDF8-D979-441E-9DAD-8D3F9E55A84E', 2, 'Completed', 'Completed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID a35bd3a6-b328-4b8b-87a4-1d7b2f68588d */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a35bd3a6-b328-4b8b-87a4-1d7b2f68588d', '7532FDF8-D979-441E-9DAD-8D3F9E55A84E', 3, 'OffTrack', 'OffTrack', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 78bd5be3-62e9-4254-8119-d5bdf1025cf3 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('78bd5be3-62e9-4254-8119-d5bdf1025cf3', '7532FDF8-D979-441E-9DAD-8D3F9E55A84E', 4, 'OnTrack', 'OnTrack', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f3b28978-4d13-43b7-92cf-9c50cdb97c82 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f3b28978-4d13-43b7-92cf-9c50cdb97c82', '7532FDF8-D979-441E-9DAD-8D3F9E55A84E', 5, 'Paused', 'Paused', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 7532FDF8-D979-441E-9DAD-8D3F9E55A84E */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='7532FDF8-D979-441E-9DAD-8D3F9E55A84E';

/* SQL text to insert entity field value with ID 71809b6d-bfff-494a-a139-bf7569cffbe6 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('71809b6d-bfff-494a-a139-bf7569cffbe6', 'DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56', 1, 'Decrease', 'Decrease', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f3e5ad4a-7f3a-40bc-86e8-eb996023d911 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f3e5ad4a-7f3a-40bc-86e8-eb996023d911', 'DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56', 2, 'Increase', 'Increase', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID ef71a1bc-8503-4807-85c6-4236a4dd4935 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ef71a1bc-8503-4807-85c6-4236a4dd4935', 'DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56', 3, 'Maintain', 'Maintain', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56';

/* SQL text to insert entity field value with ID e73100ea-6879-482c-9c65-8e395393e188 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('e73100ea-6879-482c-9c65-8e395393e188', 'CBBE3A1D-B115-4906-AF54-42ADCE9A5973', 1, 'BiWeekly', 'BiWeekly', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 98aa8d90-4fa6-4c4d-9b8e-89d51989ab37 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('98aa8d90-4fa6-4c4d-9b8e-89d51989ab37', 'CBBE3A1D-B115-4906-AF54-42ADCE9A5973', 2, 'Daily', 'Daily', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID a48f70e4-69ba-4206-b424-9dee180a251e */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a48f70e4-69ba-4206-b424-9dee180a251e', 'CBBE3A1D-B115-4906-AF54-42ADCE9A5973', 3, 'Monthly', 'Monthly', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID e092392b-f130-4856-abe2-3d060e590282 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('e092392b-f130-4856-abe2-3d060e590282', 'CBBE3A1D-B115-4906-AF54-42ADCE9A5973', 4, 'None', 'None', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 0e6a25c1-3213-4dae-9686-f8d688af2102 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0e6a25c1-3213-4dae-9686-f8d688af2102', 'CBBE3A1D-B115-4906-AF54-42ADCE9A5973', 5, 'Quarterly', 'Quarterly', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 50d54b01-1df3-4d74-bd73-438708ef0548 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('50d54b01-1df3-4d74-bd73-438708ef0548', 'CBBE3A1D-B115-4906-AF54-42ADCE9A5973', 6, 'Weekly', 'Weekly', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID CBBE3A1D-B115-4906-AF54-42ADCE9A5973 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='CBBE3A1D-B115-4906-AF54-42ADCE9A5973';

/* SQL text to insert entity field value with ID 0509c923-75c4-422c-a0b0-a45c5977d773 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0509c923-75c4-422c-a0b0-a45c5977d773', '7DA8B600-D924-4822-B80B-B273CB41FEAB', 1, 'AtRisk', 'AtRisk', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 3634dd1f-e2b1-4d25-aa82-5eddf33fb266 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('3634dd1f-e2b1-4d25-aa82-5eddf33fb266', '7DA8B600-D924-4822-B80B-B273CB41FEAB', 2, 'Completed', 'Completed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f0595906-74aa-4efd-83e9-c7297878277b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f0595906-74aa-4efd-83e9-c7297878277b', '7DA8B600-D924-4822-B80B-B273CB41FEAB', 3, 'OffTrack', 'OffTrack', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 71da79a8-c0ed-4fc5-b9b1-1166a4a038c9 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('71da79a8-c0ed-4fc5-b9b1-1166a4a038c9', '7DA8B600-D924-4822-B80B-B273CB41FEAB', 4, 'OnTrack', 'OnTrack', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 7ec8681c-c3c2-468d-925e-27293a06a4bd */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7ec8681c-c3c2-468d-925e-27293a06a4bd', '7DA8B600-D924-4822-B80B-B273CB41FEAB', 5, 'Paused', 'Paused', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 7DA8B600-D924-4822-B80B-B273CB41FEAB */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='7DA8B600-D924-4822-B80B-B273CB41FEAB';

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
              AND e.[SchemaName] NOT IN ('${mjSchema}','${mjSchema}_BizAppsCommon','${mjSchema}_BizAppsContactCenter','${mjSchema}_BizAppsIssues','sys')
              AND NOT EXISTS (
               SELECT 1 FROM [${mjSchema}].[EntityField] f2
               WHERE f2.[EntityID] = e.[ID]
                 AND f2.[IncludeInUserSearchAPI] = 1
            )
         );


/* Create Entity Relationship: MJ: AI Agents -> MJ_BizApps_Tasks: Task Check Ins (One To Many via ReportedByAIAgentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '973f7e5e-ab65-4858-b1f3-fc2c612dc1c7'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('973f7e5e-ab65-4858-b1f3-fc2c612dc1c7', 'CDB135CC-6D3C-480B-90AE-25B7805F82C1', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'ReportedByAIAgentID', 'One To Many', 1, 1, 47, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ: Users -> MJ_BizApps_Tasks: Task Check Ins (One To Many via AuthorUserID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '4d8b4b49-872a-4806-a86d-ba9c6eb69b86'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('4d8b4b49-872a-4806-a86d-ba9c6eb69b86', 'E1238F34-2837-EF11-86D4-6045BDEE16E6', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'AuthorUserID', 'One To Many', 1, 1, 128, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Task Check Ins (One To Many via AuthorPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'e58a89a6-4df2-4216-bfe3-f52b32f7c381'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('e58a89a6-4df2-4216-bfe3-f52b32f7c381', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'AuthorPersonID', 'One To Many', 1, 1, 16, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Task Check Ins (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '703bbb06-9361-4b9b-bda7-5bb908f8415f'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('703bbb06-9361-4b9b-bda7-5bb908f8415f', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'TaskID', 'One To Many', 1, 1, 11, GETUTCDATE(), GETUTCDATE())
   END;

/* SQL text to sync schema info from database schemas */
EXEC [${mjSchema}].[spUpdateSchemaInfoFromDatabase] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* Index for Foreign Keys for TaskCheckIn */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskID in table TaskCheckIn
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskCheckIn_TaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskCheckIn]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskCheckIn_TaskID ON [${flyway:defaultSchema}].[TaskCheckIn] ([TaskID]);

-- Index for foreign key AuthorPersonID in table TaskCheckIn
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskCheckIn_AuthorPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskCheckIn]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskCheckIn_AuthorPersonID ON [${flyway:defaultSchema}].[TaskCheckIn] ([AuthorPersonID]);

-- Index for foreign key AuthorUserID in table TaskCheckIn
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskCheckIn_AuthorUserID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskCheckIn]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskCheckIn_AuthorUserID ON [${flyway:defaultSchema}].[TaskCheckIn] ([AuthorUserID]);

-- Index for foreign key ReportedByAIAgentID in table TaskCheckIn
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskCheckIn_ReportedByAIAgentID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskCheckIn]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskCheckIn_ReportedByAIAgentID ON [${flyway:defaultSchema}].[TaskCheckIn] ([ReportedByAIAgentID]);

/* SQL text to update entity field related entity name field map for entity field ID 228C3AD3-A70A-44AB-8D35-49ACD8450741 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='228C3AD3-A70A-44AB-8D35-49ACD8450741', @RelatedEntityNameFieldMap='Task';

/* SQL text to update entity field related entity name field map for entity field ID C7DB972B-3CB3-48AB-81EF-AC4F4D9801A1 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='C7DB972B-3CB3-48AB-81EF-AC4F4D9801A1', @RelatedEntityNameFieldMap='AuthorPerson';

/* SQL text to update entity field related entity name field map for entity field ID 8B69C4D1-C536-4063-B775-FBEE891CCA7A */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='8B69C4D1-C536-4063-B775-FBEE891CCA7A', @RelatedEntityNameFieldMap='AuthorUser';

/* SQL text to update entity field related entity name field map for entity field ID 8D0D30AE-8449-4921-B155-3EB275E824D1 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='8D0D30AE-8449-4921-B155-3EB275E824D1', @RelatedEntityNameFieldMap='ReportedByAIAgent';

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
INNER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
LEFT OUTER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_AuthorPersonID
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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskCheckIn] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Check Ins */

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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskCheckIn] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Check Ins */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskCheckIn] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for Task */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TypeID in table Task
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Task_TypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Task]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Task_TypeID ON [${flyway:defaultSchema}].[Task] ([TypeID]);

-- Index for foreign key CategoryID in table Task
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Task_CategoryID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Task]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Task_CategoryID ON [${flyway:defaultSchema}].[Task] ([CategoryID]);

-- Index for foreign key ParentID in table Task
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Task_ParentID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Task]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Task_ParentID ON [${flyway:defaultSchema}].[Task] ([ParentID]);

-- Index for foreign key CreatedByPersonID in table Task
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Task_CreatedByPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Task]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Task_CreatedByPersonID ON [${flyway:defaultSchema}].[Task] ([CreatedByPersonID]);

-- Index for foreign key TaskTypeStatusID in table Task
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Task_TaskTypeStatusID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Task]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Task_TaskTypeStatusID ON [${flyway:defaultSchema}].[Task] ([TaskTypeStatusID]);

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
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_CreatedByPersonID
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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Tasks */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Integration]
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

/* SQL text to delete unneeded entity fields (2 scoped entities) */
EXEC [${mjSchema}].[spDeleteUnneededEntityFields] @ExcludedSchemaNames='', @EntityIDs='360CE0DB-7207-4D3C-A35F-2F45C22A5399,B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to insert 4 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f063969d-25e5-4e0d-95a6-94a16b756582' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'Task')) BEGIN
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
            'f063969d-25e5-4e0d-95a6-94a16b756582',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f5f32716-4215-46f5-a128-cb8b9353656a' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'AuthorPerson')) BEGIN
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
            'f5f32716-4215-46f5-a128-cb8b9353656a',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'AuthorPerson',
            'Author Person',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a0c840e8-ff54-430c-b3ed-8224e9517af5' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'AuthorUser')) BEGIN
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
            'a0c840e8-ff54-430c-b3ed-8224e9517af5',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'AuthorUser',
            'Author User',
            NULL,
            'nvarchar',
            200,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '25f2a091-b01c-49a0-a5e2-b2f4036b27e6' OR (EntityID = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND Name = 'ReportedByAIAgent')) BEGIN
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
            '25f2a091-b01c-49a0-a5e2-b2f4036b27e6',
            '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- Entity: MJ_BizApps_Tasks: Task Check Ins
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
            'ReportedByAIAgent',
            'Reported By AI Agent',
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

/* SQL text to update existing entity fields from schema (2 scoped entities) */
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='', @EntityIDs='360CE0DB-7207-4D3C-A35F-2F45C22A5399,B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '9637E429-90E1-4016-9BE7-635B0C446DFC'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '7DA8B600-D924-4822-B80B-B273CB41FEAB'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'D4261555-E5E9-4B47-9C76-C212559758DE'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'F063969D-25E5-4E0D-95A6-94A16B756582'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'A0C840E8-FF54-430C-B3ED-8224E9517AF5'
               AND AutoUpdateDefaultInView = 1;

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '7532FDF8-D979-441E-9DAD-8D3F9E55A84E'
               AND AutoUpdateDefaultInView = 1;

/* Set categories for 20 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.ID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'B4B892AF-BAA4-4ECD-A99B-1A34BBB21723';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.TaskID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Check-In Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Task'
WHERE 
   ID = '228C3AD3-A70A-44AB-8D35-49ACD8450741';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.Task 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Check-In Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Task Name'
WHERE 
   ID = 'F063969D-25E5-4E0D-95A6-94A16B756582';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.CheckInAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Check-In Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Check-In At'
WHERE 
   ID = '9637E429-90E1-4016-9BE7-635B0C446DFC';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.HealthStatus 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Status and Metrics',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '7DA8B600-D924-4822-B80B-B273CB41FEAB';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.ConfidenceScore 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Status and Metrics',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '9FC7A284-C3DF-4B94-910D-C2460DBDE8AB';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.PreviousValue 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Status and Metrics',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '6DF3EC7B-6920-4A83-A2F0-AFC43A64A91B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.NewValue 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Status and Metrics',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '3DB75504-F5F0-4F85-8BBF-5E8FF7E6932B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.PercentComplete 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Status and Metrics',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'D4261555-E5E9-4B47-9C76-C212559758DE';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.Summary 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Progress Narrative',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '5BD1ECAC-1336-4545-82B7-54F7D773C10C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.Blockers 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Progress Narrative',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '05563452-FAB1-4BBC-81C1-4C0949F62E87';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.NextSteps 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Progress Narrative',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '393F9B09-36A3-4BC2-9B79-8DD6218D265D';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.AuthorPersonID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Authorship and Agents',
   GeneratedFormSection = 'Category',
   DisplayName = 'Author Person'
WHERE 
   ID = 'C7DB972B-3CB3-48AB-81EF-AC4F4D9801A1';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.AuthorPerson 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Authorship and Agents',
   GeneratedFormSection = 'Category',
   DisplayName = 'Author Person Name'
WHERE 
   ID = 'F5F32716-4215-46F5-A128-CB8B9353656A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.AuthorUserID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Authorship and Agents',
   GeneratedFormSection = 'Category',
   DisplayName = 'Author User'
WHERE 
   ID = '8B69C4D1-C536-4063-B775-FBEE891CCA7A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.AuthorUser 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Authorship and Agents',
   GeneratedFormSection = 'Category',
   DisplayName = 'Author User Name'
WHERE 
   ID = 'A0C840E8-FF54-430C-B3ED-8224E9517AF5';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.ReportedByAIAgentID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Authorship and Agents',
   GeneratedFormSection = 'Category',
   DisplayName = 'Reported By AI Agent'
WHERE 
   ID = '8D0D30AE-8449-4921-B155-3EB275E824D1';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.ReportedByAIAgent 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Authorship and Agents',
   GeneratedFormSection = 'Category',
   DisplayName = 'Reported By AI Agent Name'
WHERE 
   ID = '25F2A091-B01C-49A0-A5E2-B2F4036B27E6';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '515ACC10-2C6A-4CC7-A720-0FC2D8427EF0';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'D6EC2E84-5BF9-495A-A614-6221AF56E9BA';

/* Set entity icon to fa fa-tasks */

               UPDATE [${mjSchema}].[Entity]
               SET [Icon] = 'fa fa-tasks', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399';

/* Insert FieldCategoryInfo setting for entity */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND [Name] = 'FieldCategoryInfo'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('202ee568-9da4-5430-8ab5-d84859643fd9', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'FieldCategoryInfo', '{
  "Authorship and Agents": {
    "description": "Persons, users, or AI agents responsible for the check-in",
    "icon": "fa fa-user-shield"
  },
  "Check-In Details": {
    "description": "Core check-in scheduling and task association details",
    "icon": "fa fa-calendar-check"
  },
  "Progress Narrative": {
    "description": "Narrative summaries, blockers, and planned next steps",
    "icon": "fa fa-align-left"
  },
  "Status and Metrics": {
    "description": "Health status, metrics, scores, and completion percentage",
    "icon": "fa fa-chart-line"
  },
  "System Metadata": {
    "description": "System-managed audit and tracking fields",
    "icon": "fa fa-cog"
  }
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Insert FieldCategoryIcons setting (legacy) */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND [Name] = 'FieldCategoryIcons'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('8028c881-e7c6-5b67-bb21-7ae6ed9e5390', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'FieldCategoryIcons', '{
  "Authorship and Agents": "fa fa-user-shield",
  "Check-In Details": "fa fa-calendar-check",
  "Progress Narrative": "fa fa-align-left",
  "Status and Metrics": "fa fa-chart-line",
  "System Metadata": "fa fa-cog"
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${mjSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '360CE0DB-7207-4D3C-A35F-2F45C22A5399';

/* Set categories for 17 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.HealthStatus 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Performance and Metrics',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '7532FDF8-D979-441E-9DAD-8D3F9E55A84E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.ConfidenceScore 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Performance and Metrics',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'A5CA80F8-1AB4-43DF-98EC-926D88C95DA0';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.BaselineValue 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Performance and Metrics',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '07437566-1823-4882-B196-B4473A824190';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.TargetValue 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Performance and Metrics',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '346DCCA6-8DD6-40F4-AD44-0ADAE04AFA36';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CurrentValue 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Performance and Metrics',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'EEEB991A-70C8-4AE1-A1BC-859047D74135';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.UnitOfMeasure 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Performance and Metrics',
   GeneratedFormSection = 'Category',
   DisplayName = 'Unit of Measure'
WHERE 
   ID = 'AF223C6D-6F70-4C13-8BF6-C61AA27173F8';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.MetricDirection 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Performance and Metrics',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.RollupWeight 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Performance and Metrics',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '65E2F993-2FE6-4889-9D58-E57ECFBFC82A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.PlanningPeriod 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Performance and Metrics',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'AB060B49-73E6-4925-A734-772A6E615A1E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CheckInCadence 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Performance and Metrics',
   GeneratedFormSection = 'Category',
   DisplayName = 'Check-In Cadence'
WHERE 
   ID = 'CBBE3A1D-B115-4906-AF54-42ADCE9A5973';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.LastCheckInAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Performance and Metrics',
   GeneratedFormSection = 'Category',
   DisplayName = 'Last Check-In At'
WHERE 
   ID = 'DF95636F-E402-40E1-A53C-7ABB34996F9E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.NextCheckInDueAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Performance and Metrics',
   GeneratedFormSection = 'Category',
   DisplayName = 'Next Check-In Due At'
WHERE 
   ID = '3828D96C-44E3-40C8-A907-B7A916A829D6';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.RootParentID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Task Details'
WHERE 
   ID = '3205C212-1737-4748-B232-3A64ABD3C93C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.IsSLABreached 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Predictive SLA Metrics',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'E7737A78-1C54-4766-929C-BFE8DDF0555C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.LeadDays 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Timeline and Progress',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '35141732-5D6A-459A-A2FA-76808F95160B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.AssignmentsCount 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Task Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'AAD50345-DB1B-4BC8-8515-979137C33382';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CommentsCount 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Task Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '45355317-A1AB-468F-8901-4564B03CCC4B';

/* Update FieldCategoryInfo setting for entity */

                  UPDATE [${mjSchema}].[EntitySetting]
                  SET [Value] = '{
  "Performance and Metrics": {
    "description": "Metrics, OKR tracking values, check-in schedules, and performance indicators",
    "icon": "fa fa-chart-line"
  }
}', [__mj_UpdatedAt] = GETUTCDATE()
                  WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND [Name] = 'FieldCategoryInfo';

/* Update FieldCategoryIcons setting (legacy) */

                  UPDATE [${mjSchema}].[EntitySetting]
                  SET [Value] = '{
  "Performance and Metrics": "fa fa-chart-line"
}', [__mj_UpdatedAt] = GETUTCDATE()
                  WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND [Name] = 'FieldCategoryIcons';

/* Refresh custom base views for modified entities so schema changes are picked up */
EXEC sp_refreshview '${flyway:defaultSchema}.vwTasksGenerated';
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTasks]', 'V') IS NOT NULL
BEGIN
    EXEC sp_executesql N'EXEC sp_refreshview ''${flyway:defaultSchema}.vwTasks'';';
END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Task Check Ins */
-- CHECK constraint for MJ_BizApps_Tasks: Task Check Ins: Field: ConfidenceScore was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '9FC7A284-C3DF-4B94-910D-C2460DBDE8AB'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('6e37cf69-0268-4f97-9f4a-823f07a2fc16', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([ConfidenceScore] IS NULL OR [ConfidenceScore]>=(0) AND [ConfidenceScore]<=(100))', 'public ValidateConfidenceScoreRange(result: ValidationResult) {
	if (this.ConfidenceScore != null && (this.ConfidenceScore < 0 || this.ConfidenceScore > 100)) {
		result.Errors.push(new ValidationErrorInfo(
			"ConfidenceScore",
			"Confidence score must be between 0 and 100.",
			this.ConfidenceScore,
			ValidationErrorType.Failure
		));
	}
}', 'Confidence score must be between 0 and 100 if specified.', 'ValidateConfidenceScoreRange', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', '9FC7A284-C3DF-4B94-910D-C2460DBDE8AB')
   END;

-- CHECK constraint for MJ_BizApps_Tasks: Task Check Ins: Field: PercentComplete was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = 'D4261555-E5E9-4B47-9C76-C212559758DE'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('864fe187-2b76-44ef-b2e4-15260da0057c', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([PercentComplete] IS NULL OR [PercentComplete]>=(0) AND [PercentComplete]<=(100))', 'public ValidatePercentCompleteRange(result: ValidationResult) {
	if (this.PercentComplete != null && (this.PercentComplete < 0 || this.PercentComplete > 100)) {
		result.Errors.push(new ValidationErrorInfo(
			"PercentComplete",
			"Percent complete must be between 0 and 100.",
			this.PercentComplete,
			ValidationErrorType.Failure
		));
	}
}', 'Percent complete must be between 0 and 100 when provided.', 'ValidatePercentCompleteRange', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', 'D4261555-E5E9-4B47-9C76-C212559758DE')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Task Dependencies */
-- CHECK constraint for MJ_BizApps_Tasks: Task Dependencies @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND [Name] = 'ValidateTaskIDNotEqualToDependsOnTaskID'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('39c20a7a-d4bd-4ce7-ba0b-741e9f9d06d0', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([TaskID]<>[DependsOnTaskID])', 'public ValidateTaskIDNotEqualToDependsOnTaskID(result: ValidationResult) {
	if (this.TaskID != null && this.DependsOnTaskID != null && this.TaskID === this.DependsOnTaskID) {
		result.Errors.push(new ValidationErrorInfo(
			"DependsOnTaskID",
			"A task cannot depend on itself. TaskID and DependsOnTaskID must be different.",
			this.DependsOnTaskID,
			ValidationErrorType.Failure
		));
	}
}', 'A task cannot depend on itself.', 'ValidateTaskIDNotEqualToDependsOnTaskID', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '0662FC0F-3F2B-49C9-9BE8-5B59E036044A')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Task Template Item Dependencies */
-- CHECK constraint for MJ_BizApps_Tasks: Task Template Item Dependencies @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND [Name] = 'ValidateItemIDNotEqualToDependsOnItemID'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('f4fb8e09-705e-4390-837f-bfe1b2e7706a', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([ItemID]<>[DependsOnItemID])', 'public ValidateItemIDNotEqualToDependsOnItemID(result: ValidationResult) {
	if (this.ItemID != null && this.DependsOnItemID != null && this.ItemID === this.DependsOnItemID) {
		result.Errors.push(new ValidationErrorInfo(
			"DependsOnItemID",
			"An item cannot depend on itself. ItemID and DependsOnItemID must be different.",
			this.DependsOnItemID,
			ValidationErrorType.Failure
		));
	}
}', 'An item cannot depend on itself, preventing circular self-dependencies.', 'ValidateItemIDNotEqualToDependsOnItemID', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '8A30F14C-26FF-476E-8CA1-B10EAD29A428')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Tasks */
-- CHECK constraint for MJ_BizApps_Tasks: Tasks: Field: ConfidenceScore was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = 'A5CA80F8-1AB4-43DF-98EC-926D88C95DA0'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('daff3ce5-14fe-40d1-89b0-5caed136e3eb', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([ConfidenceScore] IS NULL OR [ConfidenceScore]>=(0) AND [ConfidenceScore]<=(100))', 'public ValidateConfidenceScoreRange(result: ValidationResult) {
	if (this.ConfidenceScore != null && (this.ConfidenceScore < 0 || this.ConfidenceScore > 100)) {
		result.Errors.push(new ValidationErrorInfo(
			"ConfidenceScore",
			"Confidence score must be between 0 and 100.",
			this.ConfidenceScore,
			ValidationErrorType.Failure
		));
	}
}', 'Confidence score must be between 0 and 100 if specified.', 'ValidateConfidenceScoreRange', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', 'A5CA80F8-1AB4-43DF-98EC-926D88C95DA0')
   END;

-- CHECK constraint for MJ_BizApps_Tasks: Tasks: Field: PercentComplete was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '5812F201-256C-47AC-AEEB-3402FD1E9846'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('d0b312be-954c-4fe0-8fb9-490cf1f02ebd', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([PercentComplete]>=(0) AND [PercentComplete]<=(100))', 'public ValidatePercentCompleteRange(result: ValidationResult) {
	if (this.PercentComplete < 0 || this.PercentComplete > 100) {
		result.Errors.push(new ValidationErrorInfo(
			"PercentComplete",
			"Percent complete must be between 0 and 100.",
			this.PercentComplete,
			ValidationErrorType.Failure
		));
	}
}', 'Percent complete must be a valid percentage between 0 and 100', 'ValidatePercentCompleteRange', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', '5812F201-256C-47AC-AEEB-3402FD1E9846')
   END;
