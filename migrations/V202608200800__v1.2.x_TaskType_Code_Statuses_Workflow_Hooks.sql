-- BizAppsTasks: TaskType Code, Dynamic Task Type Statuses, and Workflow Event Hooks
-- Additive migration: adds Code and action hooks to TaskType, creates TaskTypeStatus,
-- and adds TaskTypeStatusID to Task.

GO

---------------------------------------------------------------------------
-- 1. TaskType: add Code (unique machine identifier) and new event action hooks
---------------------------------------------------------------------------
ALTER TABLE ${flyway:defaultSchema}.TaskType ADD Code NVARCHAR(50) NULL;
GO

-- Backfill existing seeded task types using stable IDs
UPDATE ${flyway:defaultSchema}.TaskType SET Code = 'GENERAL' WHERE ID = 'F7C1E8DE-8DAC-4BF8-943E-3D5A1210BE82' AND Code IS NULL;
UPDATE ${flyway:defaultSchema}.TaskType SET Code = 'ACTION_ITEM' WHERE ID = 'EA525DE3-B4A9-471C-AD13-1881E2055121' AND Code IS NULL;
UPDATE ${flyway:defaultSchema}.TaskType SET Code = 'FOLLOW_UP' WHERE ID = 'EE1A6B5A-A5AD-4A62-89DB-D16FFD2A415C' AND Code IS NULL;
UPDATE ${flyway:defaultSchema}.TaskType SET Code = 'DELIVERABLE' WHERE ID = '3F002EBA-0F6A-4433-BD98-83BC5982E916' AND Code IS NULL;
UPDATE ${flyway:defaultSchema}.TaskType SET Code = 'APPROVAL_REQUEST' WHERE ID = '5961EDE5-B996-4083-BE48-64634B4D8D1C' AND Code IS NULL;
-- Fallback for any custom/legacy rows
UPDATE ${flyway:defaultSchema}.TaskType SET Code = UPPER(REPLACE(Name, ' ', '_')) WHERE Code IS NULL;
GO

ALTER TABLE ${flyway:defaultSchema}.TaskType ALTER COLUMN Code NVARCHAR(50) NOT NULL;
GO

ALTER TABLE ${flyway:defaultSchema}.TaskType ADD
    OnCreateActionID UNIQUEIDENTIFIER NULL,
    OnStatusChangeActionID UNIQUEIDENTIFIER NULL,
    CONSTRAINT UQ_TaskType_Code UNIQUE (Code),
    CONSTRAINT FK_TaskType_OnCreateAction FOREIGN KEY (OnCreateActionID) REFERENCES ${mjSchema}.[Action](ID),
    CONSTRAINT FK_TaskType_OnStatusChangeAction FOREIGN KEY (OnStatusChangeActionID) REFERENCES ${mjSchema}.[Action](ID);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Stable unique machine code for programmatic lookups and cross-app metadata references.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskType',
    @level2type = N'COLUMN', @level2name = N'Code';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Action invoked when a task of this type is first created (e.g. kicks off a task graph workflow, initialization agent, or subtask template generator).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskType',
    @level2type = N'COLUMN', @level2name = N'OnCreateActionID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Action invoked whenever a task of this type changes status.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskType',
    @level2type = N'COLUMN', @level2name = N'OnStatusChangeActionID';
GO

---------------------------------------------------------------------------
-- 2. TaskTypeStatus: dynamic domain-specific lifecycle statuses per TaskType
---------------------------------------------------------------------------
CREATE TABLE ${flyway:defaultSchema}.TaskTypeStatus (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    TaskTypeID UNIQUEIDENTIFIER NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    Code NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX),
    MacroStatus NVARCHAR(20) NOT NULL DEFAULT 'Open',
    Sequence INT NOT NULL DEFAULT 100,
    IsDefault BIT NOT NULL DEFAULT 0,
    IsTerminal BIT NOT NULL DEFAULT 0,
    Color NVARCHAR(50),
    IconClass NVARCHAR(100),
    OnEnterActionID UNIQUEIDENTIFIER,
    OnExitActionID UNIQUEIDENTIFIER,
    IsActive BIT NOT NULL DEFAULT 1,
    __mj_CreatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_TaskTypeStatus PRIMARY KEY (ID),
    CONSTRAINT FK_TaskTypeStatus_TaskType FOREIGN KEY (TaskTypeID) REFERENCES ${flyway:defaultSchema}.TaskType(ID) ON DELETE CASCADE,
    CONSTRAINT UQ_TaskTypeStatus_TaskType_Code UNIQUE (TaskTypeID, Code),
    CONSTRAINT UQ_TaskTypeStatus_TaskType_Name UNIQUE (TaskTypeID, Name),
    CONSTRAINT CK_TaskTypeStatus_MacroStatus CHECK (MacroStatus IN ('Open', 'InProgress', 'Blocked', 'Completed', 'Cancelled')),
    CONSTRAINT FK_TaskTypeStatus_OnEnterAction FOREIGN KEY (OnEnterActionID) REFERENCES ${mjSchema}.[Action](ID),
    CONSTRAINT FK_TaskTypeStatus_OnExitAction FOREIGN KEY (OnExitActionID) REFERENCES ${mjSchema}.[Action](ID)
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Dynamic domain statuses and lifecycle stages configured per Task Type.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTypeStatus';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The Task Type this status belongs to.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTypeStatus',
    @level2type = N'COLUMN', @level2name = N'TaskTypeID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Display name of the status (e.g. Legal Review, Redlining, Pending Signature).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTypeStatus',
    @level2type = N'COLUMN', @level2name = N'Name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Stable machine code for this status within its Task Type (e.g. LEGAL_REVIEW, REDLINING).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTypeStatus',
    @level2type = N'COLUMN', @level2name = N'Code';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The standard macro-lifecycle state this domain status maps to (Open, InProgress, Blocked, Completed, Cancelled). Ensures progress rollup and Gantt calculations remain consistent.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTypeStatus',
    @level2type = N'COLUMN', @level2name = N'MacroStatus';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Ordering sequence for pickers, stage progression bars, and Kanban columns.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTypeStatus',
    @level2type = N'COLUMN', @level2name = N'Sequence';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether this is the initial default status when a task of this type is created.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTypeStatus',
    @level2type = N'COLUMN', @level2name = N'IsDefault';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether this status represents a closed terminal state for the task.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTypeStatus',
    @level2type = N'COLUMN', @level2name = N'IsTerminal';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Action invoked when a task enters this specific status.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTypeStatus',
    @level2type = N'COLUMN', @level2name = N'OnEnterActionID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Action invoked when a task leaves this specific status.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTypeStatus',
    @level2type = N'COLUMN', @level2name = N'OnExitActionID';
GO

---------------------------------------------------------------------------
-- 3. Task: link to dynamic TaskTypeStatus
---------------------------------------------------------------------------
ALTER TABLE ${flyway:defaultSchema}.Task ADD
    TaskTypeStatusID UNIQUEIDENTIFIER NULL,
    CONSTRAINT FK_Task_TaskTypeStatus FOREIGN KEY (TaskTypeStatusID) REFERENCES ${flyway:defaultSchema}.TaskTypeStatus(ID);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional reference to the dynamic TaskTypeStatus definition for tasks with type-specific lifecycles.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Task',
    @level2type = N'COLUMN', @level2name = N'TaskTypeStatusID';
GO



















































-- =============================================================================
-- GENERATED BY MemberJunction CodeGen — DO NOT EDIT BY HAND
-- =============================================================================

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Type Status */

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
         '6c8516b0-d87c-4b57-87f8-474d7ff6cdd9',
         'MJ_BizApps_Tasks: Task Type Status',
         'Task Type Status',
         'Dynamic domain statuses and lifecycle stages configured per Task Type.',
         NULL,
         'TaskTypeStatus',
         'vwTaskTypeStatus',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Type Status to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '6c8516b0-d87c-4b57-87f8-474d7ff6cdd9', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Type Status for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('6c8516b0-d87c-4b57-87f8-474d7ff6cdd9', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Type Status for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('6c8516b0-d87c-4b57-87f8-474d7ff6cdd9', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Type Status for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('6c8516b0-d87c-4b57-87f8-474d7ff6cdd9', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL text to update existing entities from schema */
EXEC [${mjSchema}].[spUpdateExistingEntitiesFromSchema] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon,${mjSchema}_BizAppsOrders,${mjSchema}_BizAppsAccounting,${mjSchema}_BizAppsIssues,${mjSchema}_BizAppsMarketing,${mjSchema}_BizAppsATS,${mjSchema}_BizAppsCommittees,${mjSchema}_BizAppsCaliber,${mjSchema}_BizAppsForms';

/* SQL text to insert 20 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '164adeb0-e6aa-4ca4-bdd2-09532549a425' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'ID')) BEGIN
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
            '164adeb0-e6aa-4ca4-bdd2-09532549a425',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '79a984fe-76f4-4c83-b03f-360369c18898' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'TaskTypeID')) BEGIN
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
            '79a984fe-76f4-4c83-b03f-360369c18898',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100002,
            'TaskTypeID',
            'Task Type ID',
            'The Task Type this status belongs to.',
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
            '1E30141A-826F-4278-BAA9-BBE14D29E606',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '824e1d6b-5a3a-4211-8a05-0da2e15499c2' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'Name')) BEGIN
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
            '824e1d6b-5a3a-4211-8a05-0da2e15499c2',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100003,
            'Name',
            'Name',
            'Display name of the status (e.g. Legal Review, Redlining, Pending Signature).',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6f02ddca-2018-4f9a-b39e-3f5068d9401d' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'Code')) BEGIN
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
            '6f02ddca-2018-4f9a-b39e-3f5068d9401d',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100004,
            'Code',
            'Code',
            'Stable machine code for this status within its Task Type (e.g. LEGAL_REVIEW, REDLINING).',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '119b6137-4212-4e45-b83b-98d61ffc0c48' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'Description')) BEGIN
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
            '119b6137-4212-4e45-b83b-98d61ffc0c48',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100005,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '34b18848-c2ba-406a-858f-1a074788cc07' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'MacroStatus')) BEGIN
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
            '34b18848-c2ba-406a-858f-1a074788cc07',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100006,
            'MacroStatus',
            'Macro Status',
            'The standard macro-lifecycle state this domain status maps to (Open, InProgress, Blocked, Completed, Cancelled). Ensures progress rollup and Gantt calculations remain consistent.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Open',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9499a61f-7eb5-40c1-8f6b-9f30d92eeb28' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'Sequence')) BEGIN
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
            '9499a61f-7eb5-40c1-8f6b-9f30d92eeb28',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100007,
            'Sequence',
            'Sequence',
            'Ordering sequence for pickers, stage progression bars, and Kanban columns.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '25da14ee-06db-48dd-8f63-647aa0df52c3' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'IsDefault')) BEGIN
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
            '25da14ee-06db-48dd-8f63-647aa0df52c3',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100008,
            'IsDefault',
            'Is Default',
            'Whether this is the initial default status when a task of this type is created.',
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c4af1535-3578-4c8b-844a-f13bfdf1cc54' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'IsTerminal')) BEGIN
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
            'c4af1535-3578-4c8b-844a-f13bfdf1cc54',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100009,
            'IsTerminal',
            'Is Terminal',
            'Whether this status represents a closed terminal state for the task.',
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6bc13897-9336-4f24-a670-46afbba71c19' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'Color')) BEGIN
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
            '6bc13897-9336-4f24-a670-46afbba71c19',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100010,
            'Color',
            'Color',
            NULL,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b2c3c6f7-306e-430f-84c2-9e0ab464797a' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'IconClass')) BEGIN
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
            'b2c3c6f7-306e-430f-84c2-9e0ab464797a',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100011,
            'IconClass',
            'Icon Class',
            NULL,
            'nvarchar',
            200,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '910020ac-5d20-486c-97ff-846504f38e63' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'OnEnterActionID')) BEGIN
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
            '910020ac-5d20-486c-97ff-846504f38e63',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100012,
            'OnEnterActionID',
            'On Enter Action ID',
            'Action invoked when a task enters this specific status.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '182bf4c0-6850-4641-83a9-c97b8abd16e8' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'OnExitActionID')) BEGIN
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
            '182bf4c0-6850-4641-83a9-c97b8abd16e8',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100013,
            'OnExitActionID',
            'On Exit Action ID',
            'Action invoked when a task leaves this specific status.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '94184deb-01e0-4824-9d66-65519a9b5585' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'IsActive')) BEGIN
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
            '94184deb-01e0-4824-9d66-65519a9b5585',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100014,
            'IsActive',
            'Is Active',
            NULL,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ff5798a2-620d-4c3d-84a7-c146fc84a0dd' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = '__mj_CreatedAt')) BEGIN
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
            'ff5798a2-620d-4c3d-84a7-c146fc84a0dd',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100015,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c12fcae1-e043-4b77-be64-9a81485d6a31' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'c12fcae1-e043-4b77-be64-9a81485d6a31',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100016,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd010dcc4-5e0c-4fe2-bff4-c35328bf48b0' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'Code')) BEGIN
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
            'd010dcc4-5e0c-4fe2-bff4-c35328bf48b0',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
            100035,
            'Code',
            'Code',
            'Stable unique machine code for programmatic lookups and cross-app metadata references.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '555144f5-34ae-40a7-8c06-de892de859b7' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnCreateActionID')) BEGIN
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
            '555144f5-34ae-40a7-8c06-de892de859b7',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
            100036,
            'OnCreateActionID',
            'On Create Action ID',
            'Action invoked when a task of this type is first created (e.g. kicks off a task graph workflow, initialization agent, or subtask template generator).',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '31c5fb7d-2fd4-4d32-85ed-2e3771a083e0' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnStatusChangeActionID')) BEGIN
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
            '31c5fb7d-2fd4-4d32-85ed-2e3771a083e0',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
            100037,
            'OnStatusChangeActionID',
            'On Status Change Action ID',
            'Action invoked whenever a task of this type changes status.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '70558cbd-0d69-41fb-a453-526878cd83d0' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'TaskTypeStatusID')) BEGIN
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
            '70558cbd-0d69-41fb-a453-526878cd83d0',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            100052,
            'TaskTypeStatusID',
            'Task Type Status ID',
            'Optional reference to the dynamic TaskTypeStatus definition for tasks with type-specific lifecycles.',
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
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9',
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
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon,${mjSchema}_BizAppsOrders,${mjSchema}_BizAppsAccounting,${mjSchema}_BizAppsIssues,${mjSchema}_BizAppsMarketing,${mjSchema}_BizAppsATS,${mjSchema}_BizAppsCommittees,${mjSchema}_BizAppsCaliber,${mjSchema}_BizAppsForms';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon,${mjSchema}_BizAppsOrders,${mjSchema}_BizAppsAccounting,${mjSchema}_BizAppsIssues,${mjSchema}_BizAppsMarketing,${mjSchema}_BizAppsATS,${mjSchema}_BizAppsCommittees,${mjSchema}_BizAppsCaliber,${mjSchema}_BizAppsForms';

/* SQL text to insert entity field value with ID 635846e8-e8f9-4be2-9e6b-ad783bae05cf */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('635846e8-e8f9-4be2-9e6b-ad783bae05cf', '34B18848-C2BA-406A-858F-1A074788CC07', 1, 'Blocked', 'Blocked', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c95bf1fd-38aa-476a-86c4-cce1daa7ab65 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c95bf1fd-38aa-476a-86c4-cce1daa7ab65', '34B18848-C2BA-406A-858F-1A074788CC07', 2, 'Cancelled', 'Cancelled', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b6c11250-d2db-4b0f-9594-bcd9271dbb8b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b6c11250-d2db-4b0f-9594-bcd9271dbb8b', '34B18848-C2BA-406A-858F-1A074788CC07', 3, 'Completed', 'Completed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 3a40307f-ef27-4079-8fb3-d9c0403a1199 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('3a40307f-ef27-4079-8fb3-d9c0403a1199', '34B18848-C2BA-406A-858F-1A074788CC07', 4, 'InProgress', 'InProgress', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 9e75f106-9f72-4f58-9181-4a08e8bb577c */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9e75f106-9f72-4f58-9181-4a08e8bb577c', '34B18848-C2BA-406A-858F-1A074788CC07', 5, 'Open', 'Open', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 34B18848-C2BA-406A-858F-1A074788CC07 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='34B18848-C2BA-406A-858F-1A074788CC07';


/* Create Entity Relationship: MJ_BizApps_Tasks: Task Type Status -> MJ_BizApps_Tasks: Tasks (One To Many via TaskTypeStatusID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '504d4e57-e414-41d8-b688-1284c93ec983'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('504d4e57-e414-41d8-b688-1284c93ec983', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'TaskTypeStatusID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ: Actions -> MJ_BizApps_Tasks: Task Types (One To Many via OnStatusChangeActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '13b8d337-7e91-4e15-b230-bac55d14a8e7'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('13b8d337-7e91-4e15-b230-bac55d14a8e7', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnStatusChangeActionID', 'One To Many', 1, 1, 26, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Actions -> MJ_BizApps_Tasks: Task Types (One To Many via OnCreateActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '556a1e00-4e4e-4723-9b62-bcdf0c3014d4'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('556a1e00-4e4e-4723-9b62-bcdf0c3014d4', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnCreateActionID', 'One To Many', 1, 1, 27, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Actions -> MJ_BizApps_Tasks: Task Type Status (One To Many via OnExitActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '8bb50b47-c4eb-47d7-b84a-3953ad2b201f'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('8bb50b47-c4eb-47d7-b84a-3953ad2b201f', '38248F34-2837-EF11-86D4-6045BDEE16E6', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', 'OnExitActionID', 'One To Many', 1, 1, 28, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Actions -> MJ_BizApps_Tasks: Task Type Status (One To Many via OnEnterActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '156a3349-422d-4e84-b3b7-e21d04b18b98'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('156a3349-422d-4e84-b3b7-e21d04b18b98', '38248F34-2837-EF11-86D4-6045BDEE16E6', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', 'OnEnterActionID', 'One To Many', 1, 1, 29, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Task Types -> MJ_BizApps_Tasks: Task Type Status (One To Many via TaskTypeID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '16f8a22c-c68a-4ade-b3c9-a4fb8bb8cb84'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('16f8a22c-c68a-4ade-b3c9-a4fb8bb8cb84', '1E30141A-826F-4278-BAA9-BBE14D29E606', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', 'TaskTypeID', 'One To Many', 1, 1, 5, GETUTCDATE(), GETUTCDATE())
   END;

/* SQL text to sync schema info from database schemas */
EXEC [${mjSchema}].[spUpdateSchemaInfoFromDatabase] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon,${mjSchema}_BizAppsOrders,${mjSchema}_BizAppsAccounting,${mjSchema}_BizAppsIssues,${mjSchema}_BizAppsMarketing,${mjSchema}_BizAppsATS,${mjSchema}_BizAppsCommittees,${mjSchema}_BizAppsCaliber,${mjSchema}_BizAppsForms';

/* Root ID Function SQL for MJ_BizApps_Tasks: Task Categories.ParentID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Categories
-- Item: fnTaskCategoryParentID_GetRootID
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- ROOT ID FUNCTION FOR: [TaskCategory].[ParentID]
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[fnTaskCategoryParentID_GetRootID]', 'IF') IS NOT NULL
    DROP FUNCTION [${flyway:defaultSchema}].[fnTaskCategoryParentID_GetRootID];
GO

CREATE FUNCTION [${flyway:defaultSchema}].[fnTaskCategoryParentID_GetRootID]
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
            [${flyway:defaultSchema}].[TaskCategory]
        WHERE
            [ID] = COALESCE(@ParentID, @RecordID)

        UNION ALL

        SELECT
            c.[ID],
            c.[ParentID],
            c.[ID] AS [RootParentID],
            p.[Depth] + 1 AS [Depth]
        FROM
            [${flyway:defaultSchema}].[TaskCategory] c
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

/* Base View SQL for MJ_BizApps_Tasks: Task Categories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Categories
-- Item: vwTaskCategories
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Categories
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskCategory
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskCategories]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskCategories];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskCategories]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskCategory_ParentID.[Name] AS [Parent],
    root_ParentID.RootID AS [RootParentID]
FROM
    [${flyway:defaultSchema}].[TaskCategory] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskCategory] AS mjBizAppsTasksTaskCategory_ParentID
  ON
    [t].[ParentID] = mjBizAppsTasksTaskCategory_ParentID.[ID]
OUTER APPLY
    [${flyway:defaultSchema}].[fnTaskCategoryParentID_GetRootID]([t].[ID], [t].[ParentID]) AS root_ParentID
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskCategories] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Categories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Categories
-- Item: Permissions for vwTaskCategories
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskCategories] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Categories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Categories
-- Item: spCreateTaskCategory
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskCategory
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskCategory]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskCategory];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskCategory]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(255),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @ParentID_Clear bit = 0,
    @ParentID uniqueidentifier = NULL,
    @ColorCode_Clear bit = 0,
    @ColorCode nvarchar(20) = NULL,
    @Sequence int = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskCategory]
            (
                [ID],
                [Name],
                [Description],
                [ParentID],
                [ColorCode],
                [Sequence],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @ParentID_Clear = 1 THEN NULL ELSE ISNULL(@ParentID, NULL) END,
                CASE WHEN @ColorCode_Clear = 1 THEN NULL ELSE ISNULL(@ColorCode, NULL) END,
                ISNULL(@Sequence, 100),
                ISNULL(@IsActive, 1)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskCategory]
            (
                [Name],
                [Description],
                [ParentID],
                [ColorCode],
                [Sequence],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @ParentID_Clear = 1 THEN NULL ELSE ISNULL(@ParentID, NULL) END,
                CASE WHEN @ColorCode_Clear = 1 THEN NULL ELSE ISNULL(@ColorCode, NULL) END,
                ISNULL(@Sequence, 100),
                ISNULL(@IsActive, 1)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskCategories] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskCategory] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Categories */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskCategory] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Categories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Categories
-- Item: spUpdateTaskCategory
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskCategory
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskCategory]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskCategory];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskCategory]
    @ID uniqueidentifier,
    @Name nvarchar(255) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @ParentID_Clear bit = 0,
    @ParentID uniqueidentifier = NULL,
    @ColorCode_Clear bit = 0,
    @ColorCode nvarchar(20) = NULL,
    @Sequence int = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskCategory]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [ParentID] = CASE WHEN @ParentID_Clear = 1 THEN NULL ELSE ISNULL(@ParentID, [ParentID]) END,
        [ColorCode] = CASE WHEN @ColorCode_Clear = 1 THEN NULL ELSE ISNULL(@ColorCode, [ColorCode]) END,
        [Sequence] = ISNULL(@Sequence, [Sequence]),
        [IsActive] = ISNULL(@IsActive, [IsActive])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskCategories] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskCategories]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskCategory] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskCategory table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskCategory]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskCategory];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskCategory
ON [${flyway:defaultSchema}].[TaskCategory]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskCategory]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskCategory] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Categories */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskCategory] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Categories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Categories
-- Item: spDeleteTaskCategory
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskCategory
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskCategory]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskCategory];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskCategory]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskCategory]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskCategory] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Categories */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskCategory] TO [cdp_Developer], [cdp_Integration];

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
    root_ParentID.RootID AS [RootParentID]
FROM
    [${flyway:defaultSchema}].[TaskComment] AS t
INNER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
INNER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_PersonID
  ON
    [t].[PersonID] = mjBizAppsCommonPerson_PersonID.[ID]
OUTER APPLY
    [${flyway:defaultSchema}].[fnTaskCommentParentID_GetRootID]([t].[ID], [t].[ParentID]) AS root_ParentID
GO
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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskComment] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Comments */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskComment] TO [cdp_Developer], [cdp_Integration];

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

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskComment] TO [cdp_Developer], [cdp_Integration]
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

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskComment] TO [cdp_Developer], [cdp_Integration];

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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskComment] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Comments */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskComment] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for TaskTypeStatus */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskTypeID in table TaskTypeStatus
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTypeStatus_TaskTypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTypeStatus]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTypeStatus_TaskTypeID ON [${flyway:defaultSchema}].[TaskTypeStatus] ([TaskTypeID]);

-- Index for foreign key OnEnterActionID in table TaskTypeStatus
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTypeStatus_OnEnterActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTypeStatus]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTypeStatus_OnEnterActionID ON [${flyway:defaultSchema}].[TaskTypeStatus] ([OnEnterActionID]);

-- Index for foreign key OnExitActionID in table TaskTypeStatus
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTypeStatus_OnExitActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTypeStatus]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTypeStatus_OnExitActionID ON [${flyway:defaultSchema}].[TaskTypeStatus] ([OnExitActionID]);

/* SQL text to update entity field related entity name field map for entity field ID 79A984FE-76F4-4C83-B03F-360369C18898 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='79A984FE-76F4-4C83-B03F-360369C18898', @RelatedEntityNameFieldMap='TaskType';

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

/* SQL text to update entity field related entity name field map for entity field ID 555144F5-34AE-40A7-8C06-DE892DE859B7 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='555144F5-34AE-40A7-8C06-DE892DE859B7', @RelatedEntityNameFieldMap='OnCreateAction';

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

/* SQL text to update entity field related entity name field map for entity field ID 70558CBD-0D69-41FB-A453-526878CD83D0 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='70558CBD-0D69-41FB-A453-526878CD83D0', @RelatedEntityNameFieldMap='TaskTypeStatus';

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
    root_ParentItemID.RootID AS [RootParentItemID]
FROM
    [${flyway:defaultSchema}].[TaskTemplateItem] AS t
INNER JOIN
    [${flyway:defaultSchema}].[TaskTemplate] AS mjBizAppsTasksTaskTemplate_TemplateID
  ON
    [t].[TemplateID] = mjBizAppsTasksTaskTemplate_TemplateID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskTemplateItem] AS mjBizAppsTasksTaskTemplateItem_ParentItemID
  ON
    [t].[ParentItemID] = mjBizAppsTasksTaskTemplateItem_ParentItemID.[ID]
OUTER APPLY
    [${flyway:defaultSchema}].[fnTaskTemplateItemParentItemID_GetRootID]([t].[ID], [t].[ParentItemID]) AS root_ParentItemID
GO
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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItem] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Template Items */

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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItem] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Template Items */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItem] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID 31C5FB7D-2FD4-4D32-85ED-2E3771A083E0 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='31C5FB7D-2FD4-4D32-85ED-2E3771A083E0', @RelatedEntityNameFieldMap='OnStatusChangeAction';

/* Root ID Function SQL for MJ_BizApps_Tasks: Tasks.ParentID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: fnTaskParentID_GetRootID
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- ROOT ID FUNCTION FOR: [Task].[ParentID]
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[fnTaskParentID_GetRootID]', 'IF') IS NOT NULL
    DROP FUNCTION [${flyway:defaultSchema}].[fnTaskParentID_GetRootID];
GO

CREATE FUNCTION [${flyway:defaultSchema}].[fnTaskParentID_GetRootID]
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
            [${flyway:defaultSchema}].[Task]
        WHERE
            [ID] = COALESCE(@ParentID, @RecordID)

        UNION ALL

        SELECT
            c.[ID],
            c.[ParentID],
            c.[ID] AS [RootParentID],
            p.[Depth] + 1 AS [Depth]
        FROM
            [${flyway:defaultSchema}].[Task] c
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

/* Base View SQL for MJ_BizApps_Tasks: Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: vwTasks
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
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTasks]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTasks];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTasks]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskType_TypeID.[Name] AS [Type],
    mjBizAppsTasksTaskCategory_CategoryID.[Name] AS [Category],
    mjBizAppsTasksTask_ParentID.[Name] AS [Parent],
    mjBizAppsCommonPerson_CreatedByPersonID.[DisplayName] AS [CreatedByPerson],
    mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID.[Name] AS [TaskTypeStatus],
    root_ParentID.RootID AS [RootParentID]
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
OUTER APPLY
    [${flyway:defaultSchema}].[fnTaskParentID_GetRootID]([t].[ID], [t].[ParentID]) AS root_ParentID
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTasks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: Permissions for vwTasks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTasks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

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
    @TaskTypeStatusID uniqueidentifier = NULL
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
                [TaskTypeStatusID]
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
                CASE WHEN @TaskTypeStatusID_Clear = 1 THEN NULL ELSE ISNULL(@TaskTypeStatusID, NULL) END
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
                [TaskTypeStatusID]
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
                CASE WHEN @TaskTypeStatusID_Clear = 1 THEN NULL ELSE ISNULL(@TaskTypeStatusID, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTasks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Tasks */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] TO [cdp_Developer], [cdp_Integration];

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
    @TaskTypeStatusID uniqueidentifier = NULL
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
        [TaskTypeStatusID] = CASE WHEN @TaskTypeStatusID_Clear = 1 THEN NULL ELSE ISNULL(@TaskTypeStatusID, [TaskTypeStatusID]) END
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

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] TO [cdp_Developer], [cdp_Integration]
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

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] TO [cdp_Developer], [cdp_Integration];

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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Tasks */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID 910020AC-5D20-486C-97FF-846504F38E63 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='910020AC-5D20-486C-97FF-846504F38E63', @RelatedEntityNameFieldMap='OnEnterAction';

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
    @OnCancelActionID uniqueidentifier = NULL,
    @Code nvarchar(50),
    @OnCreateActionID_Clear bit = 0,
    @OnCreateActionID uniqueidentifier = NULL,
    @OnStatusChangeActionID_Clear bit = 0,
    @OnStatusChangeActionID uniqueidentifier = NULL
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
                [OnStatusChangeActionID]
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
                CASE WHEN @OnStatusChangeActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnStatusChangeActionID, NULL) END
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
                [OnStatusChangeActionID]
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
                CASE WHEN @OnStatusChangeActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnStatusChangeActionID, NULL) END
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
    @OnCancelActionID uniqueidentifier = NULL,
    @Code nvarchar(50) = NULL,
    @OnCreateActionID_Clear bit = 0,
    @OnCreateActionID uniqueidentifier = NULL,
    @OnStatusChangeActionID_Clear bit = 0,
    @OnStatusChangeActionID uniqueidentifier = NULL
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
        [OnStatusChangeActionID] = CASE WHEN @OnStatusChangeActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnStatusChangeActionID, [OnStatusChangeActionID]) END
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

/* SQL text to update entity field related entity name field map for entity field ID 182BF4C0-6850-4641-83A9-C97B8ABD16E8 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='182BF4C0-6850-4641-83A9-C97B8ABD16E8', @RelatedEntityNameFieldMap='OnExitAction';

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
INNER JOIN
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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTypeStatus] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Type Status */

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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTypeStatus] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Type Status */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTypeStatus] TO [cdp_Developer], [cdp_Integration];

/* SQL text to delete unneeded entity fields (3 scoped entities) */
EXEC [${mjSchema}].[spDeleteUnneededEntityFields] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon,${mjSchema}_BizAppsOrders,${mjSchema}_BizAppsAccounting,${mjSchema}_BizAppsIssues,${mjSchema}_BizAppsMarketing,${mjSchema}_BizAppsATS,${mjSchema}_BizAppsCommittees,${mjSchema}_BizAppsCaliber,${mjSchema}_BizAppsForms', @EntityIDs='6C8516B0-D87C-4B57-87F8-474D7FF6CDD9,1E30141A-826F-4278-BAA9-BBE14D29E606,B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466';

/* SQL text to insert 6 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fad67d4d-89bf-4b5c-b593-556b56d1b68c' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'TaskType')) BEGIN
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
            'fad67d4d-89bf-4b5c-b593-556b56d1b68c',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100033,
            'TaskType',
            'Task Type',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f299e44e-7c52-44ef-ad98-59d68fa154f5' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'OnEnterAction')) BEGIN
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
            'f299e44e-7c52-44ef-ad98-59d68fa154f5',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100034,
            'OnEnterAction',
            'On Enter Action',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7d89b146-90e4-4681-89f9-d89ffd21fc57' OR (EntityID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND Name = 'OnExitAction')) BEGIN
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
            '7d89b146-90e4-4681-89f9-d89ffd21fc57',
            '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', -- Entity: MJ_BizApps_Tasks: Task Type Status
            100035,
            'OnExitAction',
            'On Exit Action',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd2a2d5fb-e3ba-4965-86ce-50a4856e1169' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnCreateAction')) BEGIN
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
            'd2a2d5fb-e3ba-4965-86ce-50a4856e1169',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
            100047,
            'OnCreateAction',
            'On Create Action',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '091a787f-6a51-45ae-9ca4-e5fe0d2b2c7e' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnStatusChangeAction')) BEGIN
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
            '091a787f-6a51-45ae-9ca4-e5fe0d2b2c7e',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
            100048,
            'OnStatusChangeAction',
            'On Status Change Action',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0e437172-663e-481f-a1be-8f3f90c55383' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'TaskTypeStatus')) BEGIN
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
            '0e437172-663e-481f-a1be-8f3f90c55383',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            100054,
            'TaskTypeStatus',
            'Task Type Status',
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

/* SQL text to update existing entity fields from schema (3 scoped entities) */
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon,${mjSchema}_BizAppsOrders,${mjSchema}_BizAppsAccounting,${mjSchema}_BizAppsIssues,${mjSchema}_BizAppsMarketing,${mjSchema}_BizAppsATS,${mjSchema}_BizAppsCommittees,${mjSchema}_BizAppsCaliber,${mjSchema}_BizAppsForms', @EntityIDs='6C8516B0-D87C-4B57-87F8-474D7FF6CDD9,1E30141A-826F-4278-BAA9-BBE14D29E606,B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon,${mjSchema}_BizAppsOrders,${mjSchema}_BizAppsAccounting,${mjSchema}_BizAppsIssues,${mjSchema}_BizAppsMarketing,${mjSchema}_BizAppsATS,${mjSchema}_BizAppsCommittees,${mjSchema}_BizAppsCaliber,${mjSchema}_BizAppsForms';

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '6F02DDCA-2018-4F9A-B39E-3F5068D9401D'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '34B18848-C2BA-406A-858F-1A074788CC07'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '9499A61F-7EB5-40C1-8F6B-9F30D92EEB28'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '25DA14EE-06DB-48DD-8F63-647AA0DF52C3'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'C4AF1535-3578-4C8B-844A-F13BFDF1CC54'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '6F02DDCA-2018-4F9A-B39E-3F5068D9401D'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '824E1D6B-5A3A-4211-8A05-0DA2E15499C2'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = '6F02DDCA-2018-4F9A-B39E-3F5068D9401D'
               AND AutoUpdateUserSearchPredicate = 1;

            UPDATE [${mjSchema}].[Entity]
            SET AllowUserSearchAPI = 0
            WHERE ID = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9'
            AND AutoUpdateAllowUserSearchAPI = 1;

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '55D2A288-00C8-425F-8E69-06BCED11D706'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '4383F518-7AE7-4C9E-B105-D9090FC545F1'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'D010DCC4-5E0C-4FE2-BFF4-C35328BF48B0'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'D010DCC4-5E0C-4FE2-BFF4-C35328BF48B0'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '00619351-6557-42B0-B412-1FC4283CB682'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = 'D010DCC4-5E0C-4FE2-BFF4-C35328BF48B0'
               AND AutoUpdateUserSearchPredicate = 1;

            UPDATE [${mjSchema}].[Entity]
            SET AllowUserSearchAPI = 0
            WHERE ID = '1E30141A-826F-4278-BAA9-BBE14D29E606'
            AND AutoUpdateAllowUserSearchAPI = 1;

/* Set categories for 19 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.ID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '164ADEB0-E6AA-4CA4-BDD2-09532549A425' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.TaskTypeID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Status Configuration',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '79A984FE-76F4-4C83-B03F-360369C18898' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.TaskType 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Status Configuration',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FAD67D4D-89BF-4B5C-B593-556B56D1B68C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.Name 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Status Configuration',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '824E1D6B-5A3A-4211-8A05-0DA2E15499C2' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.Code 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Status Configuration',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6F02DDCA-2018-4F9A-B39E-3F5068D9401D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.Description 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Status Configuration',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '119B6137-4212-4E45-B83B-98D61FFC0C48' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.MacroStatus 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Lifecycle Settings',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '34B18848-C2BA-406A-858F-1A074788CC07' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.Sequence 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Lifecycle Settings',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9499A61F-7EB5-40C1-8F6B-9F30D92EEB28' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.IsDefault 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Lifecycle Settings',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '25DA14EE-06DB-48DD-8F63-647AA0DF52C3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.IsTerminal 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Lifecycle Settings',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C4AF1535-3578-4C8B-844A-F13BFDF1CC54' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.IsActive 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Lifecycle Settings',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '94184DEB-01E0-4824-9D66-65519A9B5585' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.Color 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'UI Presentation',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6BC13897-9336-4F24-A670-46AFBBA71C19' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.IconClass 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'UI Presentation',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B2C3C6F7-306E-430F-84C2-9E0AB464797A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.OnEnterActionID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Automation Hooks',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '910020AC-5D20-486C-97FF-846504F38E63' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.OnEnterAction 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Automation Hooks',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F299E44E-7C52-44EF-AD98-59D68FA154F5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.OnExitActionID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Automation Hooks',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '182BF4C0-6850-4641-83A9-C97B8ABD16E8' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.OnExitAction 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Automation Hooks',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7D89B146-90E4-4681-89F9-D89FFD21FC57' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FF5798A2-620D-4C3D-84A7-C146FC84A0DD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C12FCAE1-E043-4B77-BE64-9A81485D6A31' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-tasks */

               UPDATE [${mjSchema}].[Entity]
               SET [Icon] = 'fa fa-tasks', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('db34f261-4f4e-4d65-be6b-e9a287b8404d', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', 'FieldCategoryInfo', '{"Status Configuration":{"icon":"fa fa-info-circle","description":"Basic identification and descriptive information for the task status"},"Lifecycle Settings":{"icon":"fa fa-random","description":"Configuration for status behavior, sequence, and lifecycle progression"},"UI Presentation":{"icon":"fa fa-palette","description":"Visual styling settings including colors and icons"},"Automation Hooks":{"icon":"fa fa-bolt","description":"Automated actions executed when entering or exiting this status"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('7cda7d3f-7b35-4cea-aaf2-62b434884480', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', 'FieldCategoryIcons', '{"Status Configuration":"fa fa-info-circle","Lifecycle Settings":"fa fa-random","UI Presentation":"fa fa-palette","Automation Hooks":"fa fa-bolt","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=false for NEW entity (category: reference, confidence: high) */

         UPDATE [${mjSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 0, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9';

/* Set categories for 28 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.ID 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B8AD1F96-886C-4903-8D8D-FBEBB27BB506' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Name 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4C041CC2-D419-485C-9896-790003F638B9' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Description 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '53F5B3E8-7220-48BD-A8E7-AEA68A83CB82' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.TypeID 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7EA597ED-DA32-4CBC-A774-AD5E1986586A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CategoryID 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4E328156-A0FF-4D3F-8C01-C75B89F235A6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.ParentID 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D419FC58-9802-454E-8D34-1DFAEBEE7DF4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Status 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '832E90CA-B150-4B19-AACE-F5385DB15E64' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Priority 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BB921C78-2BAD-4B36-B7CB-E4A471372340' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.StartedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3C7731EA-D59C-4DB0-9A48-D2C40F7EFF04' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.DueAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Due Date',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E50C83FB-BB14-4DAB-B1A5-9BC108988D7B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CompletedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3B2893B6-9E68-4563-B25B-FEB90FEFF201' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.HoursEstimated 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0CF37CC9-7B64-4E9C-A79A-B7CF5BE85244' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.HoursActual 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7DC18266-AE9A-42F2-BF47-B406842712B8' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.PercentComplete 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5812F201-256C-47AC-AEEB-3402FD1E9846' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Sequence 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '34C579D6-1FB8-4353-8F38-E75764139826' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.BlockedReason 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '72888BFB-A442-414A-96C5-6D8B3A3AA67F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CompletionNotes 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0A2F1BE2-D205-47E7-A804-679C04348EFC' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CreatedByPersonID 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0259C564-2DFE-480B-9075-3FD4C71FA46C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.OverdueNotifiedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '65CB1110-12E0-4E48-BED3-6BF1B2926807' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DA16A787-212A-43BD-87E4-4D239F3EB12C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8711F2AD-0BDC-4398-819F-F87F1D11F34A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.TaskTypeStatusID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Status and Priority',
   GeneratedFormSection = 'Category',
   DisplayName = 'Task Type Status',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '70558CBD-0D69-41FB-A453-526878CD83D0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Type 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5E003CC8-55FC-4401-A7D9-7687BE6BD753' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Category 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '411B26C4-2AEC-41EB-96C1-897C92770598' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Parent 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '16BEA5BD-358F-4E40-AB62-09BE3478345F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CreatedByPerson 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4EE84219-D7CB-408F-8EAD-410973B487AF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.TaskTypeStatus 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Status and Priority',
   GeneratedFormSection = 'Category',
   DisplayName = 'Task Type Status Name',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0E437172-663E-481F-A1BE-8F3F90C55383' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.RootParentID 
UPDATE [${mjSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3205C212-1737-4748-B232-3A64ABD3C93C' AND AutoUpdateCategory = 1;

/* Set categories for 25 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.ID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B5D4A231-3F9F-45F8-B1E5-3B0FCCABFE8B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.Name 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Task Type Definition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '00619351-6557-42B0-B412-1FC4283CB682' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.Description 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Task Type Definition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '231B2378-3454-4A1E-A002-412FD7C8AD75' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.Code 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Task Type Definition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D010DCC4-5E0C-4FE2-BFF4-C35328BF48B0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.IconClass 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Task Type Definition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '756BD750-22B9-40AF-B38A-C59A7B93FFFE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.DefaultPriority 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Task Type Definition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '55D2A288-00C8-425F-8E69-06BCED11D706' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.IsActive 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Task Type Definition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4383F518-7AE7-4C9E-B105-D9090FC545F1' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnCreateActionID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '555144F5-34AE-40A7-8C06-DE892DE859B7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnCreateAction 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D2A2D5FB-E3BA-4965-86CE-50A4856E1169' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnAssignActionID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2352E1F5-18CA-4495-85DA-516FEFC20463' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnAssignAction 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4391ECE2-8780-413A-8605-4569F84CFF03' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnStatusChangeActionID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '31C5FB7D-2FD4-4D32-85ED-2E3771A083E0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnStatusChangeAction 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '091A787F-6A51-45AE-9CA4-E5FE0D2B2C7E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnPercentChangeActionID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D6D015D3-C9D9-4EAC-B17C-4EAD902B6322' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnPercentChangeAction 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F91576C2-90C5-407D-820F-7FAEB246CFBD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnCompleteActionID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '31F3F7CC-C0D0-4DD9-84F1-255BDB54DFAE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnCompleteAction 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '028BBCC5-6694-4B9F-81E8-F2B99EF72FBE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnOverdueActionID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '86E954FA-9304-49F6-AD53-7EA09875FD87' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnOverdueAction 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '39770061-F6E2-4E20-9D1A-8A9343E0F041' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnRejectActionID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '04B4F98D-F79D-4A84-9F63-FB5FFAC014D5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnRejectAction 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4485192E-6DBC-4A4E-9A65-F4BC21A91DAA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnCancelActionID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A86F3057-5E26-450F-A958-2C1F63DD2A88' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnCancelAction 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Workflow Actions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DA3EA9E6-160B-48C7-940E-567DCBF04D7A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3B6A900C-646F-4A98-8F4B-BC7AE54A9C7A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A4CC3D1E-96AC-4EC7-98CF-F83862215617' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-tasks */

               UPDATE [${mjSchema}].[Entity]
               SET [Icon] = 'fa fa-tasks', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '1E30141A-826F-4278-BAA9-BBE14D29E606';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('bffbf6f5-c5bb-430f-be8e-fc082bfee682', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'FieldCategoryInfo', '{"Task Type Definition":{"icon":"fa fa-info-circle","description":"General configuration and identification for the task type"},"Workflow Actions":{"icon":"fa fa-bolt","description":"Configurable automated actions triggered by task lifecycle events"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('8b1b7927-6d4e-4a61-8fce-b48427f7ed27', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'FieldCategoryIcons', '{"Task Type Definition":"fa fa-info-circle","Workflow Actions":"fa fa-bolt","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

