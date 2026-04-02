/* SQL generated to create new entity MJ.BizApps.Tasks:Task Dependencies */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI]
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
         '82b3253e-8e72-4bf6-8f94-82ebd13084d9',
         'MJ.BizApps.Tasks:Task Dependencies',
         'Task Dependencies',
         NULL,
         NULL,
         'TaskDependency',
         'vwTaskDependencies',
         '${flyway:defaultSchema}_BizAppsTasks',
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
      )
   

/* SQL generated to create new application ${flyway:defaultSchema}_BizAppsTasks */
INSERT INTO [${flyway:defaultSchema}].[Application] (ID, Name, Description, SchemaAutoAddNewEntities, Path, AutoUpdatePath)
                       VALUES ('6befbf3b-bf01-4d4a-b5d0-a04c0fa4343f', '${flyway:defaultSchema}_BizAppsTasks', 'Generated for schema', '${flyway:defaultSchema}_BizAppsTasks', 'mjbizappstasks', 1)

/* SQL generated to add new entity MJ.BizApps.Tasks:Task Dependencies to application ID: '6befbf3b-bf01-4d4a-b5d0-a04c0fa4343f' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('6befbf3b-bf01-4d4a-b5d0-a04c0fa4343f', '82b3253e-8e72-4bf6-8f94-82ebd13084d9', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '6befbf3b-bf01-4d4a-b5d0-a04c0fa4343f'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Dependencies for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('82b3253e-8e72-4bf6-8f94-82ebd13084d9', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Dependencies for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('82b3253e-8e72-4bf6-8f94-82ebd13084d9', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Dependencies for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('82b3253e-8e72-4bf6-8f94-82ebd13084d9', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity MJ.BizApps.Tasks:Task Tags */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI]
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
         '554020dd-176b-44f6-8265-1aba0a430beb',
         'MJ.BizApps.Tasks:Task Tags',
         'Task Tags',
         NULL,
         NULL,
         'TaskTag',
         'vwTaskTags',
         '${flyway:defaultSchema}_BizAppsTasks',
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
      )
   

/* SQL generated to add new entity MJ.BizApps.Tasks:Task Tags to application ID: '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F', '554020dd-176b-44f6-8265-1aba0a430beb', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Tags for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('554020dd-176b-44f6-8265-1aba0a430beb', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Tags for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('554020dd-176b-44f6-8265-1aba0a430beb', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Tags for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('554020dd-176b-44f6-8265-1aba0a430beb', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity MJ.BizApps.Tasks:Task Tag Links */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI]
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
         '06695129-6af1-4d16-8209-9d0e9984845a',
         'MJ.BizApps.Tasks:Task Tag Links',
         'Task Tag Links',
         NULL,
         NULL,
         'TaskTagLink',
         'vwTaskTagLinks',
         '${flyway:defaultSchema}_BizAppsTasks',
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
      )
   

/* SQL generated to add new entity MJ.BizApps.Tasks:Task Tag Links to application ID: '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F', '06695129-6af1-4d16-8209-9d0e9984845a', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Tag Links for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('06695129-6af1-4d16-8209-9d0e9984845a', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Tag Links for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('06695129-6af1-4d16-8209-9d0e9984845a', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Tag Links for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('06695129-6af1-4d16-8209-9d0e9984845a', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity MJ.BizApps.Tasks:Task Comments */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI]
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
         '9584fd7a-99a4-41b0-9057-d2ac30655da9',
         'MJ.BizApps.Tasks:Task Comments',
         'Task Comments',
         NULL,
         NULL,
         'TaskComment',
         'vwTaskComments',
         '${flyway:defaultSchema}_BizAppsTasks',
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
      )
   

/* SQL generated to add new entity MJ.BizApps.Tasks:Task Comments to application ID: '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F', '9584fd7a-99a4-41b0-9057-d2ac30655da9', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Comments for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('9584fd7a-99a4-41b0-9057-d2ac30655da9', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Comments for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('9584fd7a-99a4-41b0-9057-d2ac30655da9', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Comments for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('9584fd7a-99a4-41b0-9057-d2ac30655da9', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity MJ.BizApps.Tasks:Task Templates */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI]
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
         '345a453c-3461-4cd8-abcc-005828c574c6',
         'MJ.BizApps.Tasks:Task Templates',
         'Task Templates',
         NULL,
         NULL,
         'TaskTemplate',
         'vwTaskTemplates',
         '${flyway:defaultSchema}_BizAppsTasks',
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
      )
   

/* SQL generated to add new entity MJ.BizApps.Tasks:Task Templates to application ID: '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F', '345a453c-3461-4cd8-abcc-005828c574c6', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Templates for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('345a453c-3461-4cd8-abcc-005828c574c6', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Templates for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('345a453c-3461-4cd8-abcc-005828c574c6', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Templates for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('345a453c-3461-4cd8-abcc-005828c574c6', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity MJ.BizApps.Tasks:Task Template Items */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI]
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
         'f037786e-f201-4552-844a-1e53f15c00c0',
         'MJ.BizApps.Tasks:Task Template Items',
         'Task Template Items',
         NULL,
         NULL,
         'TaskTemplateItem',
         'vwTaskTemplateItems',
         '${flyway:defaultSchema}_BizAppsTasks',
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
      )
   

/* SQL generated to add new entity MJ.BizApps.Tasks:Task Template Items to application ID: '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F', 'f037786e-f201-4552-844a-1e53f15c00c0', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Template Items for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('f037786e-f201-4552-844a-1e53f15c00c0', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Template Items for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('f037786e-f201-4552-844a-1e53f15c00c0', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Template Items for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('f037786e-f201-4552-844a-1e53f15c00c0', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity MJ.BizApps.Tasks:Task Template Item Dependencies */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI]
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
         '19cd22d9-4e20-499c-b9d2-2390271cdc0e',
         'MJ.BizApps.Tasks:Task Template Item Dependencies',
         'Task Template Item Dependencies',
         NULL,
         NULL,
         'TaskTemplateItemDependency',
         'vwTaskTemplateItemDependencies',
         '${flyway:defaultSchema}_BizAppsTasks',
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
      )
   

/* SQL generated to add new entity MJ.BizApps.Tasks:Task Template Item Dependencies to application ID: '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F', '19cd22d9-4e20-499c-b9d2-2390271cdc0e', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Template Item Dependencies for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('19cd22d9-4e20-499c-b9d2-2390271cdc0e', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Template Item Dependencies for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('19cd22d9-4e20-499c-b9d2-2390271cdc0e', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Template Item Dependencies for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('19cd22d9-4e20-499c-b9d2-2390271cdc0e', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity MJ.BizApps.Tasks:Task Template Item Roles */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI]
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
         'c14bdc39-5b0d-4159-8e11-5e48ecd746c4',
         'MJ.BizApps.Tasks:Task Template Item Roles',
         'Task Template Item Roles',
         NULL,
         NULL,
         'TaskTemplateItemRole',
         'vwTaskTemplateItemRoles',
         '${flyway:defaultSchema}_BizAppsTasks',
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
      )
   

/* SQL generated to add new entity MJ.BizApps.Tasks:Task Template Item Roles to application ID: '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F', 'c14bdc39-5b0d-4159-8e11-5e48ecd746c4', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Template Item Roles for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('c14bdc39-5b0d-4159-8e11-5e48ecd746c4', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Template Item Roles for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('c14bdc39-5b0d-4159-8e11-5e48ecd746c4', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Template Item Roles for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('c14bdc39-5b0d-4159-8e11-5e48ecd746c4', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity MJ.BizApps.Tasks:Task Types */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI]
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
         'a60593bc-e4ee-42d9-9a28-6a1e90f41ee5',
         'MJ.BizApps.Tasks:Task Types',
         'Task Types',
         NULL,
         NULL,
         'TaskType',
         'vwTaskTypes',
         '${flyway:defaultSchema}_BizAppsTasks',
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
      )
   

/* SQL generated to add new entity MJ.BizApps.Tasks:Task Types to application ID: '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F', 'a60593bc-e4ee-42d9-9a28-6a1e90f41ee5', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Types for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('a60593bc-e4ee-42d9-9a28-6a1e90f41ee5', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Types for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('a60593bc-e4ee-42d9-9a28-6a1e90f41ee5', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Types for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('a60593bc-e4ee-42d9-9a28-6a1e90f41ee5', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity MJ.BizApps.Tasks:Task Activities */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI]
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
         '95a39dd9-54d6-4839-9ba8-d746fcb90115',
         'MJ.BizApps.Tasks:Task Activities',
         'Task Activities',
         NULL,
         NULL,
         'TaskActivity',
         'vwTaskActivities',
         '${flyway:defaultSchema}_BizAppsTasks',
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
      )
   

/* SQL generated to add new entity MJ.BizApps.Tasks:Task Activities to application ID: '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F', '95a39dd9-54d6-4839-9ba8-d746fcb90115', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Activities for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('95a39dd9-54d6-4839-9ba8-d746fcb90115', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Activities for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('95a39dd9-54d6-4839-9ba8-d746fcb90115', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Activities for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('95a39dd9-54d6-4839-9ba8-d746fcb90115', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity MJ.BizApps.Tasks:Task Categories */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI]
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
         'cdf7f284-93bb-4055-9b1a-3fa253ccfeab',
         'MJ.BizApps.Tasks:Task Categories',
         'Task Categories',
         NULL,
         NULL,
         'TaskCategory',
         'vwTaskCategories',
         '${flyway:defaultSchema}_BizAppsTasks',
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
      )
   

/* SQL generated to add new entity MJ.BizApps.Tasks:Task Categories to application ID: '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F', 'cdf7f284-93bb-4055-9b1a-3fa253ccfeab', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Categories for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('cdf7f284-93bb-4055-9b1a-3fa253ccfeab', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Categories for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('cdf7f284-93bb-4055-9b1a-3fa253ccfeab', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Categories for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('cdf7f284-93bb-4055-9b1a-3fa253ccfeab', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity MJ.BizApps.Tasks:Tasks */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI]
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
         'e58f681e-e956-4fd9-87c9-7197bc631641',
         'MJ.BizApps.Tasks:Tasks',
         'Tasks',
         NULL,
         NULL,
         'Task',
         'vwTasks',
         '${flyway:defaultSchema}_BizAppsTasks',
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
      )
   

/* SQL generated to add new entity MJ.BizApps.Tasks:Tasks to application ID: '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F', 'e58f681e-e956-4fd9-87c9-7197bc631641', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Tasks for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('e58f681e-e956-4fd9-87c9-7197bc631641', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Tasks for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('e58f681e-e956-4fd9-87c9-7197bc631641', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Tasks for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('e58f681e-e956-4fd9-87c9-7197bc631641', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity MJ.BizApps.Tasks:Task Roles */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI]
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
         '9cf47e3c-32c3-426a-9412-af9355f875eb',
         'MJ.BizApps.Tasks:Task Roles',
         'Task Roles',
         NULL,
         NULL,
         'TaskRole',
         'vwTaskRoles',
         '${flyway:defaultSchema}_BizAppsTasks',
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
      )
   

/* SQL generated to add new entity MJ.BizApps.Tasks:Task Roles to application ID: '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F', '9cf47e3c-32c3-426a-9412-af9355f875eb', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Roles for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('9cf47e3c-32c3-426a-9412-af9355f875eb', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Roles for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('9cf47e3c-32c3-426a-9412-af9355f875eb', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Roles for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('9cf47e3c-32c3-426a-9412-af9355f875eb', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity MJ.BizApps.Tasks:Task Assignments */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI]
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
         '62694f71-8e1a-4b41-9b54-0fcc7ee0fd21',
         'MJ.BizApps.Tasks:Task Assignments',
         'Task Assignments',
         NULL,
         NULL,
         'TaskAssignment',
         'vwTaskAssignments',
         '${flyway:defaultSchema}_BizAppsTasks',
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
      )
   

/* SQL generated to add new entity MJ.BizApps.Tasks:Task Assignments to application ID: '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F', '62694f71-8e1a-4b41-9b54-0fcc7ee0fd21', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Assignments for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('62694f71-8e1a-4b41-9b54-0fcc7ee0fd21', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Assignments for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('62694f71-8e1a-4b41-9b54-0fcc7ee0fd21', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Assignments for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('62694f71-8e1a-4b41-9b54-0fcc7ee0fd21', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity MJ.BizApps.Tasks:Task Links */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI]
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
         'f586669b-055f-4f7e-82f2-64caff7ac92e',
         'MJ.BizApps.Tasks:Task Links',
         'Task Links',
         NULL,
         NULL,
         'TaskLink',
         'vwTaskLinks',
         '${flyway:defaultSchema}_BizAppsTasks',
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
      )
   

/* SQL generated to add new entity MJ.BizApps.Tasks:Task Links to application ID: '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F', 'f586669b-055f-4f7e-82f2-64caff7ac92e', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '6BEFBF3B-BF01-4D4A-B5D0-A04C0FA4343F'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Links for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('f586669b-055f-4f7e-82f2-64caff7ac92e', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Links for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('f586669b-055f-4f7e-82f2-64caff7ac92e', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity MJ.BizApps.Tasks:Task Links for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('f586669b-055f-4f7e-82f2-64caff7ac92e', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '41611394-0670-43ac-94e1-4ef56bc6ae1f' OR (EntityID = '345A453C-3461-4CD8-ABCC-005828C574C6' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '41611394-0670-43ac-94e1-4ef56bc6ae1f',
            '345A453C-3461-4CD8-ABCC-005828C574C6', -- Entity: MJ.BizApps.Tasks:Task Templates
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd4a3ba32-6dee-4f6d-8173-d3218a424b72' OR (EntityID = '345A453C-3461-4CD8-ABCC-005828C574C6' AND Name = 'Name')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'd4a3ba32-6dee-4f6d-8173-d3218a424b72',
            '345A453C-3461-4CD8-ABCC-005828C574C6', -- Entity: MJ.BizApps.Tasks:Task Templates
            100002,
            'Name',
            'Name',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            NULL,
            NULL,
            1,
            1,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '842c355e-d5fe-4b5e-a17f-56bf656a3925' OR (EntityID = '345A453C-3461-4CD8-ABCC-005828C574C6' AND Name = 'Description')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '842c355e-d5fe-4b5e-a17f-56bf656a3925',
            '345A453C-3461-4CD8-ABCC-005828C574C6', -- Entity: MJ.BizApps.Tasks:Task Templates
            100003,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '176db599-ed36-4d7b-a990-4e56e0cf5760' OR (EntityID = '345A453C-3461-4CD8-ABCC-005828C574C6' AND Name = 'CategoryID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '176db599-ed36-4d7b-a990-4e56e0cf5760',
            '345A453C-3461-4CD8-ABCC-005828C574C6', -- Entity: MJ.BizApps.Tasks:Task Templates
            100004,
            'CategoryID',
            'Category ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '20607527-8550-462c-b785-4c6dbd383f0b' OR (EntityID = '345A453C-3461-4CD8-ABCC-005828C574C6' AND Name = 'TypeID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '20607527-8550-462c-b785-4c6dbd383f0b',
            '345A453C-3461-4CD8-ABCC-005828C574C6', -- Entity: MJ.BizApps.Tasks:Task Templates
            100005,
            'TypeID',
            'Type ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a1f0fc43-14bc-4f50-aeef-e25b50a94a30' OR (EntityID = '345A453C-3461-4CD8-ABCC-005828C574C6' AND Name = 'IsActive')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'a1f0fc43-14bc-4f50-aeef-e25b50a94a30',
            '345A453C-3461-4CD8-ABCC-005828C574C6', -- Entity: MJ.BizApps.Tasks:Task Templates
            100006,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'fe673c18-3199-4ee4-85f6-598b84f4a0de' OR (EntityID = '345A453C-3461-4CD8-ABCC-005828C574C6' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'fe673c18-3199-4ee4-85f6-598b84f4a0de',
            '345A453C-3461-4CD8-ABCC-005828C574C6', -- Entity: MJ.BizApps.Tasks:Task Templates
            100007,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'fc28e876-f87f-4e79-9a0f-61d5dc624351' OR (EntityID = '345A453C-3461-4CD8-ABCC-005828C574C6' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'fc28e876-f87f-4e79-9a0f-61d5dc624351',
            '345A453C-3461-4CD8-ABCC-005828C574C6', -- Entity: MJ.BizApps.Tasks:Task Templates
            100008,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9ce54921-a7db-4a69-8427-7ea45d2feb09' OR (EntityID = '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '9ce54921-a7db-4a69-8427-7ea45d2feb09',
            '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21', -- Entity: MJ.BizApps.Tasks:Task Assignments
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3f72d53c-5594-4d99-be09-455c68f42376' OR (EntityID = '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21' AND Name = 'TaskID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '3f72d53c-5594-4d99-be09-455c68f42376',
            '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21', -- Entity: MJ.BizApps.Tasks:Task Assignments
            100002,
            'TaskID',
            'Task ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            'E58F681E-E956-4FD9-87C9-7197BC631641',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3cd24b65-61a3-4e9c-9de0-e2cef16dcb9b' OR (EntityID = '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21' AND Name = 'AssigneeEntityID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '3cd24b65-61a3-4e9c-9de0-e2cef16dcb9b',
            '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21', -- Entity: MJ.BizApps.Tasks:Task Assignments
            100003,
            'AssigneeEntityID',
            'Assignee Entity ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            'E0238F34-2837-EF11-86D4-6045BDEE16E6',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c6fd1772-cdd6-4c6f-95b9-df9fc5659bf2' OR (EntityID = '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21' AND Name = 'AssigneeRecordID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'c6fd1772-cdd6-4c6f-95b9-df9fc5659bf2',
            '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21', -- Entity: MJ.BizApps.Tasks:Task Assignments
            100004,
            'AssigneeRecordID',
            'Assignee Record ID',
            NULL,
            'nvarchar',
            900,
            0,
            0,
            0,
            NULL,
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '877c35a9-143b-47cc-8299-767406ef3b4c' OR (EntityID = '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21' AND Name = 'RoleID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '877c35a9-143b-47cc-8299-767406ef3b4c',
            '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21', -- Entity: MJ.BizApps.Tasks:Task Assignments
            100005,
            'RoleID',
            'Role ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            '9CF47E3C-32C3-426A-9412-AF9355F875EB',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e31b5c77-7a07-480c-982f-8bbd05e05230' OR (EntityID = '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21' AND Name = 'RoleNotes')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'e31b5c77-7a07-480c-982f-8bbd05e05230',
            '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21', -- Entity: MJ.BizApps.Tasks:Task Assignments
            100006,
            'RoleNotes',
            'Role Notes',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            1,
            NULL,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c5fab46f-0dfb-4809-b16f-cedb0fcf1edf' OR (EntityID = '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21' AND Name = 'Status')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'c5fab46f-0dfb-4809-b16f-cedb0fcf1edf',
            '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21', -- Entity: MJ.BizApps.Tasks:Task Assignments
            100007,
            'Status',
            'Status',
            NULL,
            'nvarchar',
            100,
            0,
            0,
            0,
            'Pending',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0371506f-cb6e-44aa-a808-80347c340778' OR (EntityID = '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21' AND Name = 'AssignedByPersonID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '0371506f-cb6e-44aa-a808-80347c340778',
            '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21', -- Entity: MJ.BizApps.Tasks:Task Assignments
            100008,
            'AssignedByPersonID',
            'Assigned By Person ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '94c51c91-cdc3-4b1a-9faf-8b27dfa62893' OR (EntityID = '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21' AND Name = 'AssignedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '94c51c91-cdc3-4b1a-9faf-8b27dfa62893',
            '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21', -- Entity: MJ.BizApps.Tasks:Task Assignments
            100009,
            'AssignedAt',
            'Assigned At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '419b61f9-92d3-4275-9a3e-2083b041b9ef' OR (EntityID = '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '419b61f9-92d3-4275-9a3e-2083b041b9ef',
            '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21', -- Entity: MJ.BizApps.Tasks:Task Assignments
            100010,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '50038cbe-da5a-4d3c-962c-b25638faf323' OR (EntityID = '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '50038cbe-da5a-4d3c-962c-b25638faf323',
            '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21', -- Entity: MJ.BizApps.Tasks:Task Assignments
            100011,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3933f718-8a69-426c-b8e9-e46cf6c1b3be' OR (EntityID = '554020DD-176B-44F6-8265-1ABA0A430BEB' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '3933f718-8a69-426c-b8e9-e46cf6c1b3be',
            '554020DD-176B-44F6-8265-1ABA0A430BEB', -- Entity: MJ.BizApps.Tasks:Task Tags
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f264386c-1092-4e7a-b665-418cf4499f37' OR (EntityID = '554020DD-176B-44F6-8265-1ABA0A430BEB' AND Name = 'Name')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'f264386c-1092-4e7a-b665-418cf4499f37',
            '554020DD-176B-44F6-8265-1ABA0A430BEB', -- Entity: MJ.BizApps.Tasks:Task Tags
            100002,
            'Name',
            'Name',
            NULL,
            'nvarchar',
            200,
            0,
            0,
            0,
            NULL,
            0,
            1,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1aaa1f59-4598-463e-b776-89a240853f4e' OR (EntityID = '554020DD-176B-44F6-8265-1ABA0A430BEB' AND Name = 'ColorCode')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '1aaa1f59-4598-463e-b776-89a240853f4e',
            '554020DD-176B-44F6-8265-1ABA0A430BEB', -- Entity: MJ.BizApps.Tasks:Task Tags
            100003,
            'ColorCode',
            'Color Code',
            NULL,
            'nvarchar',
            40,
            0,
            0,
            1,
            NULL,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f82a7dc1-d69e-4c25-bd61-74066e798f44' OR (EntityID = '554020DD-176B-44F6-8265-1ABA0A430BEB' AND Name = 'Description')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'f82a7dc1-d69e-4c25-bd61-74066e798f44',
            '554020DD-176B-44F6-8265-1ABA0A430BEB', -- Entity: MJ.BizApps.Tasks:Task Tags
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0f6ddf05-7c0f-4f61-bd99-4fa11592060b' OR (EntityID = '554020DD-176B-44F6-8265-1ABA0A430BEB' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '0f6ddf05-7c0f-4f61-bd99-4fa11592060b',
            '554020DD-176B-44F6-8265-1ABA0A430BEB', -- Entity: MJ.BizApps.Tasks:Task Tags
            100005,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bffac597-924a-4e5c-8284-8f8352057c8e' OR (EntityID = '554020DD-176B-44F6-8265-1ABA0A430BEB' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'bffac597-924a-4e5c-8284-8f8352057c8e',
            '554020DD-176B-44F6-8265-1ABA0A430BEB', -- Entity: MJ.BizApps.Tasks:Task Tags
            100006,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8a459033-9275-4778-aaab-7410cd7d78e8' OR (EntityID = 'F037786E-F201-4552-844A-1E53F15C00C0' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '8a459033-9275-4778-aaab-7410cd7d78e8',
            'F037786E-F201-4552-844A-1E53F15C00C0', -- Entity: MJ.BizApps.Tasks:Task Template Items
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '762e933b-9d02-46c2-8f43-4049837dfed5' OR (EntityID = 'F037786E-F201-4552-844A-1E53F15C00C0' AND Name = 'TemplateID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '762e933b-9d02-46c2-8f43-4049837dfed5',
            'F037786E-F201-4552-844A-1E53F15C00C0', -- Entity: MJ.BizApps.Tasks:Task Template Items
            100002,
            'TemplateID',
            'Template ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            '345A453C-3461-4CD8-ABCC-005828C574C6',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6c6a8ef4-eb48-4f7a-94d2-61a360ae4319' OR (EntityID = 'F037786E-F201-4552-844A-1E53F15C00C0' AND Name = 'Name')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '6c6a8ef4-eb48-4f7a-94d2-61a360ae4319',
            'F037786E-F201-4552-844A-1E53F15C00C0', -- Entity: MJ.BizApps.Tasks:Task Template Items
            100003,
            'Name',
            'Name',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            NULL,
            NULL,
            1,
            1,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '808d9148-69d1-4890-b430-a615dcd205f7' OR (EntityID = 'F037786E-F201-4552-844A-1E53F15C00C0' AND Name = 'Description')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '808d9148-69d1-4890-b430-a615dcd205f7',
            'F037786E-F201-4552-844A-1E53F15C00C0', -- Entity: MJ.BizApps.Tasks:Task Template Items
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b754dbb6-b7b9-4f6f-8a87-9d055fa4e47d' OR (EntityID = 'F037786E-F201-4552-844A-1E53F15C00C0' AND Name = 'ParentItemID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'b754dbb6-b7b9-4f6f-8a87-9d055fa4e47d',
            'F037786E-F201-4552-844A-1E53F15C00C0', -- Entity: MJ.BizApps.Tasks:Task Template Items
            100005,
            'ParentItemID',
            'Parent Item ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            'F037786E-F201-4552-844A-1E53F15C00C0',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9d635ab2-8cda-4463-9585-a8b64b631c80' OR (EntityID = 'F037786E-F201-4552-844A-1E53F15C00C0' AND Name = 'Priority')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '9d635ab2-8cda-4463-9585-a8b64b631c80',
            'F037786E-F201-4552-844A-1E53F15C00C0', -- Entity: MJ.BizApps.Tasks:Task Template Items
            100006,
            'Priority',
            'Priority',
            NULL,
            'nvarchar',
            40,
            0,
            0,
            0,
            'Medium',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0a403766-1da5-4e6e-98d6-4dee70ad8d32' OR (EntityID = 'F037786E-F201-4552-844A-1E53F15C00C0' AND Name = 'DaysFromStart')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '0a403766-1da5-4e6e-98d6-4dee70ad8d32',
            'F037786E-F201-4552-844A-1E53F15C00C0', -- Entity: MJ.BizApps.Tasks:Task Template Items
            100007,
            'DaysFromStart',
            'Days From Start',
            NULL,
            'int',
            4,
            10,
            0,
            1,
            NULL,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1c19f474-956e-461f-afa4-946b8b8c8dfd' OR (EntityID = 'F037786E-F201-4552-844A-1E53F15C00C0' AND Name = 'HoursEstimated')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '1c19f474-956e-461f-afa4-946b8b8c8dfd',
            'F037786E-F201-4552-844A-1E53F15C00C0', -- Entity: MJ.BizApps.Tasks:Task Template Items
            100008,
            'HoursEstimated',
            'Hours Estimated',
            NULL,
            'decimal',
            5,
            8,
            2,
            1,
            NULL,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0498cdd6-3e68-4cda-b400-9939f0f3b4b3' OR (EntityID = 'F037786E-F201-4552-844A-1E53F15C00C0' AND Name = 'Sequence')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '0498cdd6-3e68-4cda-b400-9939f0f3b4b3',
            'F037786E-F201-4552-844A-1E53F15C00C0', -- Entity: MJ.BizApps.Tasks:Task Template Items
            100009,
            'Sequence',
            'Sequence',
            NULL,
            'int',
            4,
            10,
            0,
            0,
            '(100)',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '71de6e25-cd97-4397-a619-760f629408ca' OR (EntityID = 'F037786E-F201-4552-844A-1E53F15C00C0' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '71de6e25-cd97-4397-a619-760f629408ca',
            'F037786E-F201-4552-844A-1E53F15C00C0', -- Entity: MJ.BizApps.Tasks:Task Template Items
            100010,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '40f85d6e-b374-4740-856f-628131bee1d7' OR (EntityID = 'F037786E-F201-4552-844A-1E53F15C00C0' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '40f85d6e-b374-4740-856f-628131bee1d7',
            'F037786E-F201-4552-844A-1E53F15C00C0', -- Entity: MJ.BizApps.Tasks:Task Template Items
            100011,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7639a7ee-95ca-499b-823e-fc16958ce7b4' OR (EntityID = '19CD22D9-4E20-499C-B9D2-2390271CDC0E' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '7639a7ee-95ca-499b-823e-fc16958ce7b4',
            '19CD22D9-4E20-499C-B9D2-2390271CDC0E', -- Entity: MJ.BizApps.Tasks:Task Template Item Dependencies
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a79d4d91-8aee-48c2-aff7-baae129918bd' OR (EntityID = '19CD22D9-4E20-499C-B9D2-2390271CDC0E' AND Name = 'ItemID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'a79d4d91-8aee-48c2-aff7-baae129918bd',
            '19CD22D9-4E20-499C-B9D2-2390271CDC0E', -- Entity: MJ.BizApps.Tasks:Task Template Item Dependencies
            100002,
            'ItemID',
            'Item ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            'F037786E-F201-4552-844A-1E53F15C00C0',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '999d58b3-4935-43df-ad55-d6f0a17f3a25' OR (EntityID = '19CD22D9-4E20-499C-B9D2-2390271CDC0E' AND Name = 'DependsOnItemID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '999d58b3-4935-43df-ad55-d6f0a17f3a25',
            '19CD22D9-4E20-499C-B9D2-2390271CDC0E', -- Entity: MJ.BizApps.Tasks:Task Template Item Dependencies
            100003,
            'DependsOnItemID',
            'Depends On Item ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            'F037786E-F201-4552-844A-1E53F15C00C0',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e09fa353-a52c-4ed4-b6e2-8683e3349e48' OR (EntityID = '19CD22D9-4E20-499C-B9D2-2390271CDC0E' AND Name = 'DependencyType')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'e09fa353-a52c-4ed4-b6e2-8683e3349e48',
            '19CD22D9-4E20-499C-B9D2-2390271CDC0E', -- Entity: MJ.BizApps.Tasks:Task Template Item Dependencies
            100004,
            'DependencyType',
            'Dependency Type',
            NULL,
            'nvarchar',
            100,
            0,
            0,
            0,
            'FinishToStart',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '68ee76a1-bb35-45f6-afae-19aeb5324053' OR (EntityID = '19CD22D9-4E20-499C-B9D2-2390271CDC0E' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '68ee76a1-bb35-45f6-afae-19aeb5324053',
            '19CD22D9-4E20-499C-B9D2-2390271CDC0E', -- Entity: MJ.BizApps.Tasks:Task Template Item Dependencies
            100005,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a609291f-99bd-473d-a7cb-ef067bd02e32' OR (EntityID = '19CD22D9-4E20-499C-B9D2-2390271CDC0E' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'a609291f-99bd-473d-a7cb-ef067bd02e32',
            '19CD22D9-4E20-499C-B9D2-2390271CDC0E', -- Entity: MJ.BizApps.Tasks:Task Template Item Dependencies
            100006,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'dac90e64-a126-425e-ab9f-201e69ecbd43' OR (EntityID = 'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'dac90e64-a126-425e-ab9f-201e69ecbd43',
            'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB', -- Entity: MJ.BizApps.Tasks:Task Categories
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4eac6b08-cfde-4fb3-8d41-008d1dd44a2e' OR (EntityID = 'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB' AND Name = 'Name')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '4eac6b08-cfde-4fb3-8d41-008d1dd44a2e',
            'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB', -- Entity: MJ.BizApps.Tasks:Task Categories
            100002,
            'Name',
            'Name',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            NULL,
            NULL,
            1,
            1,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ab345d89-27dd-4bb0-9a32-a2baa3a60b39' OR (EntityID = 'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB' AND Name = 'Description')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'ab345d89-27dd-4bb0-9a32-a2baa3a60b39',
            'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB', -- Entity: MJ.BizApps.Tasks:Task Categories
            100003,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '91092390-ec1a-48ea-92db-185b7c8b879e' OR (EntityID = 'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB' AND Name = 'ParentID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '91092390-ec1a-48ea-92db-185b7c8b879e',
            'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB', -- Entity: MJ.BizApps.Tasks:Task Categories
            100004,
            'ParentID',
            'Parent ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b5937af2-f9f2-4e8a-b02a-4418ee6d5fba' OR (EntityID = 'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB' AND Name = 'ColorCode')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'b5937af2-f9f2-4e8a-b02a-4418ee6d5fba',
            'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB', -- Entity: MJ.BizApps.Tasks:Task Categories
            100005,
            'ColorCode',
            'Color Code',
            NULL,
            'nvarchar',
            40,
            0,
            0,
            1,
            NULL,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ff8ab12d-72ca-47a2-861c-26f3ae974a9a' OR (EntityID = 'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB' AND Name = 'Sequence')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'ff8ab12d-72ca-47a2-861c-26f3ae974a9a',
            'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB', -- Entity: MJ.BizApps.Tasks:Task Categories
            100006,
            'Sequence',
            'Sequence',
            NULL,
            'int',
            4,
            10,
            0,
            0,
            '(100)',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '43d20322-89f1-43fb-8c3c-88ccc5958615' OR (EntityID = 'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB' AND Name = 'IsActive')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '43d20322-89f1-43fb-8c3c-88ccc5958615',
            'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB', -- Entity: MJ.BizApps.Tasks:Task Categories
            100007,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a65a776f-c5c3-4279-b764-00c53c1602e1' OR (EntityID = 'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'a65a776f-c5c3-4279-b764-00c53c1602e1',
            'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB', -- Entity: MJ.BizApps.Tasks:Task Categories
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0c45e82b-6906-49b7-9ec4-f6155f3ebd36' OR (EntityID = 'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '0c45e82b-6906-49b7-9ec4-f6155f3ebd36',
            'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB', -- Entity: MJ.BizApps.Tasks:Task Categories
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd69f448c-d33a-4438-a85b-c7f427583d13' OR (EntityID = 'C14BDC39-5B0D-4159-8E11-5E48ECD746C4' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'd69f448c-d33a-4438-a85b-c7f427583d13',
            'C14BDC39-5B0D-4159-8E11-5E48ECD746C4', -- Entity: MJ.BizApps.Tasks:Task Template Item Roles
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd424c524-4270-4e5e-9460-14bfbc2a02cc' OR (EntityID = 'C14BDC39-5B0D-4159-8E11-5E48ECD746C4' AND Name = 'ItemID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'd424c524-4270-4e5e-9460-14bfbc2a02cc',
            'C14BDC39-5B0D-4159-8E11-5E48ECD746C4', -- Entity: MJ.BizApps.Tasks:Task Template Item Roles
            100002,
            'ItemID',
            'Item ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            'F037786E-F201-4552-844A-1E53F15C00C0',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'fc178350-1abe-4594-8a2d-10457761ed47' OR (EntityID = 'C14BDC39-5B0D-4159-8E11-5E48ECD746C4' AND Name = 'RoleID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'fc178350-1abe-4594-8a2d-10457761ed47',
            'C14BDC39-5B0D-4159-8E11-5E48ECD746C4', -- Entity: MJ.BizApps.Tasks:Task Template Item Roles
            100003,
            'RoleID',
            'Role ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            '9CF47E3C-32C3-426A-9412-AF9355F875EB',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c570fa1e-b7e6-4c31-982f-6ebb58e62627' OR (EntityID = 'C14BDC39-5B0D-4159-8E11-5E48ECD746C4' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'c570fa1e-b7e6-4c31-982f-6ebb58e62627',
            'C14BDC39-5B0D-4159-8E11-5E48ECD746C4', -- Entity: MJ.BizApps.Tasks:Task Template Item Roles
            100004,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '096c8252-69e5-4fda-aec5-f6d1cea6b4b3' OR (EntityID = 'C14BDC39-5B0D-4159-8E11-5E48ECD746C4' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '096c8252-69e5-4fda-aec5-f6d1cea6b4b3',
            'C14BDC39-5B0D-4159-8E11-5E48ECD746C4', -- Entity: MJ.BizApps.Tasks:Task Template Item Roles
            100005,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '01ca1c9f-8daf-4542-9977-da5c21a3a53f' OR (EntityID = 'DC523BBE-93DC-49FC-B066-621D3C8162E2' AND Name = 'TaskID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '01ca1c9f-8daf-4542-9977-da5c21a3a53f',
            'DC523BBE-93DC-49FC-B066-621D3C8162E2', -- Entity: Artifacts
            100039,
            'TaskID',
            'Task ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            'E58F681E-E956-4FD9-87C9-7197BC631641',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd9240226-5912-4453-ae99-3cfb90d4e3cf' OR (EntityID = 'F586669B-055F-4F7E-82F2-64CAFF7AC92E' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'd9240226-5912-4453-ae99-3cfb90d4e3cf',
            'F586669B-055F-4F7E-82F2-64CAFF7AC92E', -- Entity: MJ.BizApps.Tasks:Task Links
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '13aad655-95ab-4313-80cd-95a662523c40' OR (EntityID = 'F586669B-055F-4F7E-82F2-64CAFF7AC92E' AND Name = 'TaskID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '13aad655-95ab-4313-80cd-95a662523c40',
            'F586669B-055F-4F7E-82F2-64CAFF7AC92E', -- Entity: MJ.BizApps.Tasks:Task Links
            100002,
            'TaskID',
            'Task ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            'E58F681E-E956-4FD9-87C9-7197BC631641',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4f5093db-0513-4bbf-a565-01c6e8eb8c96' OR (EntityID = 'F586669B-055F-4F7E-82F2-64CAFF7AC92E' AND Name = 'EntityID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '4f5093db-0513-4bbf-a565-01c6e8eb8c96',
            'F586669B-055F-4F7E-82F2-64CAFF7AC92E', -- Entity: MJ.BizApps.Tasks:Task Links
            100003,
            'EntityID',
            'Entity ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            'E0238F34-2837-EF11-86D4-6045BDEE16E6',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '71c41339-74a8-4f79-b302-0ddbad45d4d5' OR (EntityID = 'F586669B-055F-4F7E-82F2-64CAFF7AC92E' AND Name = 'RecordID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '71c41339-74a8-4f79-b302-0ddbad45d4d5',
            'F586669B-055F-4F7E-82F2-64CAFF7AC92E', -- Entity: MJ.BizApps.Tasks:Task Links
            100004,
            'RecordID',
            'Record ID',
            NULL,
            'nvarchar',
            900,
            0,
            0,
            0,
            NULL,
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '61a29f0e-d7d1-4705-b22e-d18fb8dd83fb' OR (EntityID = 'F586669B-055F-4F7E-82F2-64CAFF7AC92E' AND Name = 'Description')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '61a29f0e-d7d1-4705-b22e-d18fb8dd83fb',
            'F586669B-055F-4F7E-82F2-64CAFF7AC92E', -- Entity: MJ.BizApps.Tasks:Task Links
            100005,
            'Description',
            'Description',
            NULL,
            'nvarchar',
            1000,
            0,
            0,
            1,
            NULL,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '943a02ea-1ff2-4d97-91fd-bd43e9f0db00' OR (EntityID = 'F586669B-055F-4F7E-82F2-64CAFF7AC92E' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '943a02ea-1ff2-4d97-91fd-bd43e9f0db00',
            'F586669B-055F-4F7E-82F2-64CAFF7AC92E', -- Entity: MJ.BizApps.Tasks:Task Links
            100006,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ce48814b-44ea-44c1-a4ef-31ab26f30b45' OR (EntityID = 'F586669B-055F-4F7E-82F2-64CAFF7AC92E' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'ce48814b-44ea-44c1-a4ef-31ab26f30b45',
            'F586669B-055F-4F7E-82F2-64CAFF7AC92E', -- Entity: MJ.BizApps.Tasks:Task Links
            100007,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '086f9032-7e5f-47d7-800b-1b90bf03ab77' OR (EntityID = 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '086f9032-7e5f-47d7-800b-1b90bf03ab77',
            'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', -- Entity: MJ.BizApps.Tasks:Task Types
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c5e56e13-a66e-4b58-abf7-0c171393d4fd' OR (EntityID = 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5' AND Name = 'Name')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'c5e56e13-a66e-4b58-abf7-0c171393d4fd',
            'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', -- Entity: MJ.BizApps.Tasks:Task Types
            100002,
            'Name',
            'Name',
            NULL,
            'nvarchar',
            200,
            0,
            0,
            0,
            NULL,
            0,
            1,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6e5838d0-405b-40e9-b8ab-84352662b180' OR (EntityID = 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5' AND Name = 'Description')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '6e5838d0-405b-40e9-b8ab-84352662b180',
            'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', -- Entity: MJ.BizApps.Tasks:Task Types
            100003,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1021409d-f432-4a1a-8a41-45d845d0d7f1' OR (EntityID = 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5' AND Name = 'IconClass')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '1021409d-f432-4a1a-8a41-45d845d0d7f1',
            'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', -- Entity: MJ.BizApps.Tasks:Task Types
            100004,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a62d29ae-4c11-4fa7-b524-7212a6455791' OR (EntityID = 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5' AND Name = 'DefaultPriority')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'a62d29ae-4c11-4fa7-b524-7212a6455791',
            'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', -- Entity: MJ.BizApps.Tasks:Task Types
            100005,
            'DefaultPriority',
            'Default Priority',
            NULL,
            'nvarchar',
            40,
            0,
            0,
            0,
            'Medium',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2865a06a-4f47-430c-aca7-c4c4751bfd44' OR (EntityID = 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5' AND Name = 'OnAssignActionID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '2865a06a-4f47-430c-aca7-c4c4751bfd44',
            'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', -- Entity: MJ.BizApps.Tasks:Task Types
            100006,
            'OnAssignActionID',
            'On Assign Action ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd7ccbf3b-821c-4012-9736-ee9a87e9ce6d' OR (EntityID = 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5' AND Name = 'OnCompleteActionID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'd7ccbf3b-821c-4012-9736-ee9a87e9ce6d',
            'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', -- Entity: MJ.BizApps.Tasks:Task Types
            100007,
            'OnCompleteActionID',
            'On Complete Action ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ec083675-e422-4f02-8514-258db5b1597d' OR (EntityID = 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5' AND Name = 'OnOverdueActionID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'ec083675-e422-4f02-8514-258db5b1597d',
            'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', -- Entity: MJ.BizApps.Tasks:Task Types
            100008,
            'OnOverdueActionID',
            'On Overdue Action ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9ae8464c-2f52-4bc7-9953-8ada2d191bd5' OR (EntityID = 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5' AND Name = 'OnPercentChangeActionID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '9ae8464c-2f52-4bc7-9953-8ada2d191bd5',
            'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', -- Entity: MJ.BizApps.Tasks:Task Types
            100009,
            'OnPercentChangeActionID',
            'On Percent Change Action ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ed61ebfa-736d-4660-93fe-3b4d0ef21906' OR (EntityID = 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5' AND Name = 'IsActive')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'ed61ebfa-736d-4660-93fe-3b4d0ef21906',
            'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', -- Entity: MJ.BizApps.Tasks:Task Types
            100010,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c7a02bc8-5e2a-4aa7-abc3-c1150cb177c8' OR (EntityID = 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'c7a02bc8-5e2a-4aa7-abc3-c1150cb177c8',
            'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', -- Entity: MJ.BizApps.Tasks:Task Types
            100011,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b691331f-e3ed-41b5-97df-ead42d3d3c89' OR (EntityID = 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'b691331f-e3ed-41b5-97df-ead42d3d3c89',
            'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', -- Entity: MJ.BizApps.Tasks:Task Types
            100012,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6b293aac-5fad-45a5-bae1-4c063626a7b2' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '6b293aac-5fad-45a5-bae1-4c063626a7b2',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2cdfa8d8-88b6-4f60-aa42-db5594dbcaeb' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'Name')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '2cdfa8d8-88b6-4f60-aa42-db5594dbcaeb',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100002,
            'Name',
            'Name',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            NULL,
            NULL,
            1,
            1,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e95ffc75-8760-48ec-b676-81de93336085' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'Description')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'e95ffc75-8760-48ec-b676-81de93336085',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100003,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7d9ec738-a055-4d10-ab62-6fe89eecca17' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'TypeID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '7d9ec738-a055-4d10-ab62-6fe89eecca17',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100004,
            'TypeID',
            'Type ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '69ddc60b-4261-49a4-8bc3-c5eae697f19c' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'CategoryID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '69ddc60b-4261-49a4-8bc3-c5eae697f19c',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100005,
            'CategoryID',
            'Category ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '73438a18-2ba1-4c20-b370-b7e2185bf5c6' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'ParentID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '73438a18-2ba1-4c20-b370-b7e2185bf5c6',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100006,
            'ParentID',
            'Parent ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            'E58F681E-E956-4FD9-87C9-7197BC631641',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bd66b261-f76d-4fef-8991-a5ddac18e671' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'Status')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'bd66b261-f76d-4fef-8991-a5ddac18e671',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100007,
            'Status',
            'Status',
            NULL,
            'nvarchar',
            100,
            0,
            0,
            0,
            'Open',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '572ff0a1-e335-4bee-97f9-61040a937656' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'Priority')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '572ff0a1-e335-4bee-97f9-61040a937656',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100008,
            'Priority',
            'Priority',
            NULL,
            'nvarchar',
            40,
            0,
            0,
            0,
            'Medium',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'af95d4c5-7af6-46a6-a7f1-682a45cfccf9' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'StartedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'af95d4c5-7af6-46a6-a7f1-682a45cfccf9',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100009,
            'StartedAt',
            'Started At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e4cb25d5-cafe-4453-84ca-3f05919a6769' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'DueAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'e4cb25d5-cafe-4453-84ca-3f05919a6769',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100010,
            'DueAt',
            'Due At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '83baf11b-cf79-41ea-bdc4-4c2d7d8ebdfa' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'CompletedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '83baf11b-cf79-41ea-bdc4-4c2d7d8ebdfa',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100011,
            'CompletedAt',
            'Completed At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'aa7872b4-92d1-46af-bd56-3e5985a03cb9' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'HoursEstimated')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'aa7872b4-92d1-46af-bd56-3e5985a03cb9',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100012,
            'HoursEstimated',
            'Hours Estimated',
            NULL,
            'decimal',
            5,
            8,
            2,
            1,
            NULL,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '437c7bdd-7dba-474f-9633-e7a1e861881e' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'HoursActual')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '437c7bdd-7dba-474f-9633-e7a1e861881e',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100013,
            'HoursActual',
            'Hours Actual',
            NULL,
            'decimal',
            5,
            8,
            2,
            1,
            NULL,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4f8293b3-b230-4669-843e-8059f114bb77' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'PercentComplete')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '4f8293b3-b230-4669-843e-8059f114bb77',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100014,
            'PercentComplete',
            'Percent Complete',
            NULL,
            'int',
            4,
            10,
            0,
            0,
            '(0)',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '681223e9-08be-4a13-b01e-943fee8805ba' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'Sequence')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '681223e9-08be-4a13-b01e-943fee8805ba',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100015,
            'Sequence',
            'Sequence',
            NULL,
            'int',
            4,
            10,
            0,
            0,
            '(100)',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ab1f3c64-5735-41aa-a87c-fbdcbc9cb606' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'BlockedReason')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'ab1f3c64-5735-41aa-a87c-fbdcbc9cb606',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100016,
            'BlockedReason',
            'Blocked Reason',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7239512a-5917-485c-8bbe-da14230a8e6c' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'CompletionNotes')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '7239512a-5917-485c-8bbe-da14230a8e6c',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100017,
            'CompletionNotes',
            'Completion Notes',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c074126f-4ebb-44c2-af9e-605f0dc1e57c' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = 'CreatedByPersonID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'c074126f-4ebb-44c2-af9e-605f0dc1e57c',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100018,
            'CreatedByPersonID',
            'Created By Person ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c86dc71b-f034-41b0-b333-573ee332822d' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'c86dc71b-f034-41b0-b333-573ee332822d',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100019,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3cdb0ee6-236e-425b-9952-cc857f76040d' OR (EntityID = 'E58F681E-E956-4FD9-87C9-7197BC631641' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '3cdb0ee6-236e-425b-9952-cc857f76040d',
            'E58F681E-E956-4FD9-87C9-7197BC631641', -- Entity: MJ.BizApps.Tasks:Tasks
            100020,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd04fc612-7cc7-41b6-8333-15b2b351b2ae' OR (EntityID = '82B3253E-8E72-4BF6-8F94-82EBD13084D9' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'd04fc612-7cc7-41b6-8333-15b2b351b2ae',
            '82B3253E-8E72-4BF6-8F94-82EBD13084D9', -- Entity: MJ.BizApps.Tasks:Task Dependencies
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '50215e2f-2f93-4926-9254-0b3458fcf7d8' OR (EntityID = '82B3253E-8E72-4BF6-8F94-82EBD13084D9' AND Name = 'TaskID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '50215e2f-2f93-4926-9254-0b3458fcf7d8',
            '82B3253E-8E72-4BF6-8F94-82EBD13084D9', -- Entity: MJ.BizApps.Tasks:Task Dependencies
            100002,
            'TaskID',
            'Task ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            'E58F681E-E956-4FD9-87C9-7197BC631641',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'df2db78f-e385-46fb-a99e-eee095c74bbb' OR (EntityID = '82B3253E-8E72-4BF6-8F94-82EBD13084D9' AND Name = 'DependsOnTaskID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'df2db78f-e385-46fb-a99e-eee095c74bbb',
            '82B3253E-8E72-4BF6-8F94-82EBD13084D9', -- Entity: MJ.BizApps.Tasks:Task Dependencies
            100003,
            'DependsOnTaskID',
            'Depends On Task ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            'E58F681E-E956-4FD9-87C9-7197BC631641',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '32bfa080-5069-48d5-87e0-b46019eaa839' OR (EntityID = '82B3253E-8E72-4BF6-8F94-82EBD13084D9' AND Name = 'DependencyType')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '32bfa080-5069-48d5-87e0-b46019eaa839',
            '82B3253E-8E72-4BF6-8F94-82EBD13084D9', -- Entity: MJ.BizApps.Tasks:Task Dependencies
            100004,
            'DependencyType',
            'Dependency Type',
            NULL,
            'nvarchar',
            100,
            0,
            0,
            0,
            'FinishToStart',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7dd325a8-db48-46e3-bf6c-854edad6c2d9' OR (EntityID = '82B3253E-8E72-4BF6-8F94-82EBD13084D9' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '7dd325a8-db48-46e3-bf6c-854edad6c2d9',
            '82B3253E-8E72-4BF6-8F94-82EBD13084D9', -- Entity: MJ.BizApps.Tasks:Task Dependencies
            100005,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0bf532b7-a419-4126-aa44-ac5cf9201850' OR (EntityID = '82B3253E-8E72-4BF6-8F94-82EBD13084D9' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '0bf532b7-a419-4126-aa44-ac5cf9201850',
            '82B3253E-8E72-4BF6-8F94-82EBD13084D9', -- Entity: MJ.BizApps.Tasks:Task Dependencies
            100006,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'dcb329f9-e2d6-40b5-8d31-01df92b03441' OR (EntityID = '06695129-6AF1-4D16-8209-9D0E9984845A' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'dcb329f9-e2d6-40b5-8d31-01df92b03441',
            '06695129-6AF1-4D16-8209-9D0E9984845A', -- Entity: MJ.BizApps.Tasks:Task Tag Links
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '448f41ac-8e4b-401b-bbef-8ba83d137c6d' OR (EntityID = '06695129-6AF1-4D16-8209-9D0E9984845A' AND Name = 'TaskID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '448f41ac-8e4b-401b-bbef-8ba83d137c6d',
            '06695129-6AF1-4D16-8209-9D0E9984845A', -- Entity: MJ.BizApps.Tasks:Task Tag Links
            100002,
            'TaskID',
            'Task ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            'E58F681E-E956-4FD9-87C9-7197BC631641',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5284aa87-5696-4efe-a480-e5360383a5c6' OR (EntityID = '06695129-6AF1-4D16-8209-9D0E9984845A' AND Name = 'TagID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '5284aa87-5696-4efe-a480-e5360383a5c6',
            '06695129-6AF1-4D16-8209-9D0E9984845A', -- Entity: MJ.BizApps.Tasks:Task Tag Links
            100003,
            'TagID',
            'Tag ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            '554020DD-176B-44F6-8265-1ABA0A430BEB',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '412f82c8-3170-46bf-a624-75e2a2568762' OR (EntityID = '06695129-6AF1-4D16-8209-9D0E9984845A' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '412f82c8-3170-46bf-a624-75e2a2568762',
            '06695129-6AF1-4D16-8209-9D0E9984845A', -- Entity: MJ.BizApps.Tasks:Task Tag Links
            100004,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4132de62-2da1-4a6d-85f2-f7948f3a1f84' OR (EntityID = '06695129-6AF1-4D16-8209-9D0E9984845A' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '4132de62-2da1-4a6d-85f2-f7948f3a1f84',
            '06695129-6AF1-4D16-8209-9D0E9984845A', -- Entity: MJ.BizApps.Tasks:Task Tag Links
            100005,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0f4abc14-3877-448f-9858-e8b7fc352e13' OR (EntityID = '9DC1631E-F623-44FB-A796-A70BE70923D1' AND Name = 'TaskID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '0f4abc14-3877-448f-9858-e8b7fc352e13',
            '9DC1631E-F623-44FB-A796-A70BE70923D1', -- Entity: Comments
            100035,
            'TaskID',
            'Task ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            'E58F681E-E956-4FD9-87C9-7197BC631641',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '15bc030d-7796-4836-ab58-31b4551d5d08' OR (EntityID = '9CF47E3C-32C3-426A-9412-AF9355F875EB' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '15bc030d-7796-4836-ab58-31b4551d5d08',
            '9CF47E3C-32C3-426A-9412-AF9355F875EB', -- Entity: MJ.BizApps.Tasks:Task Roles
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4d00fb1d-6fa9-4ed1-9db9-95de9cef8e5f' OR (EntityID = '9CF47E3C-32C3-426A-9412-AF9355F875EB' AND Name = 'Name')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '4d00fb1d-6fa9-4ed1-9db9-95de9cef8e5f',
            '9CF47E3C-32C3-426A-9412-AF9355F875EB', -- Entity: MJ.BizApps.Tasks:Task Roles
            100002,
            'Name',
            'Name',
            NULL,
            'nvarchar',
            200,
            0,
            0,
            0,
            NULL,
            0,
            1,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0ed00c4d-0dff-42b4-b63e-d3c0efd32b22' OR (EntityID = '9CF47E3C-32C3-426A-9412-AF9355F875EB' AND Name = 'Description')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '0ed00c4d-0dff-42b4-b63e-d3c0efd32b22',
            '9CF47E3C-32C3-426A-9412-AF9355F875EB', -- Entity: MJ.BizApps.Tasks:Task Roles
            100003,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a9656efa-684d-418a-9370-31804dd9d8a4' OR (EntityID = '9CF47E3C-32C3-426A-9412-AF9355F875EB' AND Name = 'Sequence')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'a9656efa-684d-418a-9370-31804dd9d8a4',
            '9CF47E3C-32C3-426A-9412-AF9355F875EB', -- Entity: MJ.BizApps.Tasks:Task Roles
            100004,
            'Sequence',
            'Sequence',
            NULL,
            'int',
            4,
            10,
            0,
            0,
            '(100)',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3eb42253-c9eb-43dd-a712-b7cdda024996' OR (EntityID = '9CF47E3C-32C3-426A-9412-AF9355F875EB' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '3eb42253-c9eb-43dd-a712-b7cdda024996',
            '9CF47E3C-32C3-426A-9412-AF9355F875EB', -- Entity: MJ.BizApps.Tasks:Task Roles
            100005,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '19fd872a-e26d-4dbb-b731-09d80ecc7b1a' OR (EntityID = '9CF47E3C-32C3-426A-9412-AF9355F875EB' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '19fd872a-e26d-4dbb-b731-09d80ecc7b1a',
            '9CF47E3C-32C3-426A-9412-AF9355F875EB', -- Entity: MJ.BizApps.Tasks:Task Roles
            100006,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '18a2cfdf-b290-4351-ab46-f8ef4f8a52f4' OR (EntityID = '9584FD7A-99A4-41B0-9057-D2AC30655DA9' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '18a2cfdf-b290-4351-ab46-f8ef4f8a52f4',
            '9584FD7A-99A4-41B0-9057-D2AC30655DA9', -- Entity: MJ.BizApps.Tasks:Task Comments
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f335bb3c-c91c-4863-a6db-17939d545d0d' OR (EntityID = '9584FD7A-99A4-41B0-9057-D2AC30655DA9' AND Name = 'TaskID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'f335bb3c-c91c-4863-a6db-17939d545d0d',
            '9584FD7A-99A4-41B0-9057-D2AC30655DA9', -- Entity: MJ.BizApps.Tasks:Task Comments
            100002,
            'TaskID',
            'Task ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            'E58F681E-E956-4FD9-87C9-7197BC631641',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '89247e3d-8870-40d5-b364-027ff907bcdd' OR (EntityID = '9584FD7A-99A4-41B0-9057-D2AC30655DA9' AND Name = 'ParentID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '89247e3d-8870-40d5-b364-027ff907bcdd',
            '9584FD7A-99A4-41B0-9057-D2AC30655DA9', -- Entity: MJ.BizApps.Tasks:Task Comments
            100003,
            'ParentID',
            'Parent ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            '9584FD7A-99A4-41B0-9057-D2AC30655DA9',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '476de17b-fda2-45fa-b00c-6b223e80cd72' OR (EntityID = '9584FD7A-99A4-41B0-9057-D2AC30655DA9' AND Name = 'PersonID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '476de17b-fda2-45fa-b00c-6b223e80cd72',
            '9584FD7A-99A4-41B0-9057-D2AC30655DA9', -- Entity: MJ.BizApps.Tasks:Task Comments
            100004,
            'PersonID',
            'Person ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'da757fc6-9267-45fd-a4b4-7aeab90f75b8' OR (EntityID = '9584FD7A-99A4-41B0-9057-D2AC30655DA9' AND Name = 'Content')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'da757fc6-9267-45fd-a4b4-7aeab90f75b8',
            '9584FD7A-99A4-41B0-9057-D2AC30655DA9', -- Entity: MJ.BizApps.Tasks:Task Comments
            100005,
            'Content',
            'Content',
            NULL,
            'nvarchar',
            -1,
            0,
            0,
            0,
            NULL,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '050696bc-397a-4597-a205-e1d13244a369' OR (EntityID = '9584FD7A-99A4-41B0-9057-D2AC30655DA9' AND Name = 'IsEdited')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '050696bc-397a-4597-a205-e1d13244a369',
            '9584FD7A-99A4-41B0-9057-D2AC30655DA9', -- Entity: MJ.BizApps.Tasks:Task Comments
            100006,
            'IsEdited',
            'Is Edited',
            NULL,
            'bit',
            1,
            1,
            0,
            0,
            '(0)',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5aa71314-4aae-4a4a-a157-4e84fd37abd0' OR (EntityID = '9584FD7A-99A4-41B0-9057-D2AC30655DA9' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '5aa71314-4aae-4a4a-a157-4e84fd37abd0',
            '9584FD7A-99A4-41B0-9057-D2AC30655DA9', -- Entity: MJ.BizApps.Tasks:Task Comments
            100007,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '056ee5ee-96cb-4e3f-9cb9-ab7c5ab43616' OR (EntityID = '9584FD7A-99A4-41B0-9057-D2AC30655DA9' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '056ee5ee-96cb-4e3f-9cb9-ab7c5ab43616',
            '9584FD7A-99A4-41B0-9057-D2AC30655DA9', -- Entity: MJ.BizApps.Tasks:Task Comments
            100008,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '241aa1a7-2618-481e-be94-b0a81644752c' OR (EntityID = '95A39DD9-54D6-4839-9BA8-D746FCB90115' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '241aa1a7-2618-481e-be94-b0a81644752c',
            '95A39DD9-54D6-4839-9BA8-D746FCB90115', -- Entity: MJ.BizApps.Tasks:Task Activities
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '26dc71df-c158-4588-a2c2-0c5bec1e9e2a' OR (EntityID = '95A39DD9-54D6-4839-9BA8-D746FCB90115' AND Name = 'TaskID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '26dc71df-c158-4588-a2c2-0c5bec1e9e2a',
            '95A39DD9-54D6-4839-9BA8-D746FCB90115', -- Entity: MJ.BizApps.Tasks:Task Activities
            100002,
            'TaskID',
            'Task ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            'E58F681E-E956-4FD9-87C9-7197BC631641',
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ce80a13b-82b6-4bfd-902f-4dad7b534139' OR (EntityID = '95A39DD9-54D6-4839-9BA8-D746FCB90115' AND Name = 'PersonID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'ce80a13b-82b6-4bfd-902f-4dad7b534139',
            '95A39DD9-54D6-4839-9BA8-D746FCB90115', -- Entity: MJ.BizApps.Tasks:Task Activities
            100003,
            'PersonID',
            'Person ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a01ab680-7864-45f8-b38a-f2642b9f94bc' OR (EntityID = '95A39DD9-54D6-4839-9BA8-D746FCB90115' AND Name = 'ActivityType')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'a01ab680-7864-45f8-b38a-f2642b9f94bc',
            '95A39DD9-54D6-4839-9BA8-D746FCB90115', -- Entity: MJ.BizApps.Tasks:Task Activities
            100004,
            'ActivityType',
            'Activity Type',
            NULL,
            'nvarchar',
            100,
            0,
            0,
            0,
            NULL,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '484db1ea-e87f-4b7b-a228-040d835f7214' OR (EntityID = '95A39DD9-54D6-4839-9BA8-D746FCB90115' AND Name = 'PreviousValue')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '484db1ea-e87f-4b7b-a228-040d835f7214',
            '95A39DD9-54D6-4839-9BA8-D746FCB90115', -- Entity: MJ.BizApps.Tasks:Task Activities
            100005,
            'PreviousValue',
            'Previous Value',
            NULL,
            'nvarchar',
            1000,
            0,
            0,
            1,
            NULL,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '133c17e1-6762-4fd3-bca3-c43cf6650a9a' OR (EntityID = '95A39DD9-54D6-4839-9BA8-D746FCB90115' AND Name = 'NewValue')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '133c17e1-6762-4fd3-bca3-c43cf6650a9a',
            '95A39DD9-54D6-4839-9BA8-D746FCB90115', -- Entity: MJ.BizApps.Tasks:Task Activities
            100006,
            'NewValue',
            'New Value',
            NULL,
            'nvarchar',
            1000,
            0,
            0,
            1,
            NULL,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0c347714-9db5-418c-b226-bfc8eb9a9776' OR (EntityID = '95A39DD9-54D6-4839-9BA8-D746FCB90115' AND Name = 'Description')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '0c347714-9db5-418c-b226-bfc8eb9a9776',
            '95A39DD9-54D6-4839-9BA8-D746FCB90115', -- Entity: MJ.BizApps.Tasks:Task Activities
            100007,
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '82f81291-f3de-4566-a9e3-d51fc3b50b2d' OR (EntityID = '95A39DD9-54D6-4839-9BA8-D746FCB90115' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            '82f81291-f3de-4566-a9e3-d51fc3b50b2d',
            '95A39DD9-54D6-4839-9BA8-D746FCB90115', -- Entity: MJ.BizApps.Tasks:Task Activities
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
      END

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ebda64a4-df77-44d1-861c-5fc3fdd425f5' OR (EntityID = '95A39DD9-54D6-4839-9BA8-D746FCB90115' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
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
            'ebda64a4-df77-44d1-861c-5fc3fdd425f5',
            '95A39DD9-54D6-4839-9BA8-D746FCB90115', -- Entity: MJ.BizApps.Tasks:Task Activities
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
      END

/* SQL text to insert entity field value with ID 081e927e-7e8b-41bd-b70c-b0bb1ea8cde4 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('081e927e-7e8b-41bd-b70c-b0bb1ea8cde4', '32BFA080-5069-48D5-87E0-B46019EAA839', 1, 'FinishToFinish', 'FinishToFinish', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID d952bf85-10f5-4af7-b762-a214078dca73 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d952bf85-10f5-4af7-b762-a214078dca73', '32BFA080-5069-48D5-87E0-B46019EAA839', 2, 'FinishToStart', 'FinishToStart', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 9d158bac-d86e-4b1a-b92e-472153f65655 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9d158bac-d86e-4b1a-b92e-472153f65655', '32BFA080-5069-48D5-87E0-B46019EAA839', 3, 'StartToFinish', 'StartToFinish', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID c58dde76-03a6-47a1-96dd-321deeed69bf */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c58dde76-03a6-47a1-96dd-321deeed69bf', '32BFA080-5069-48D5-87E0-B46019EAA839', 4, 'StartToStart', 'StartToStart', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID 32BFA080-5069-48D5-87E0-B46019EAA839 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='32BFA080-5069-48D5-87E0-B46019EAA839'

/* SQL text to insert entity field value with ID ab34fe36-2cb2-4dca-a377-cb69f7a0bbf9 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ab34fe36-2cb2-4dca-a377-cb69f7a0bbf9', '9D635AB2-8CDA-4463-9585-A8B64B631C80', 1, 'Critical', 'Critical', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 2e221ea5-d66c-4115-8500-f7b88f9c2f33 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('2e221ea5-d66c-4115-8500-f7b88f9c2f33', '9D635AB2-8CDA-4463-9585-A8B64B631C80', 2, 'High', 'High', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 6b0b60e8-3fa6-48f6-adeb-d7099893f45c */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6b0b60e8-3fa6-48f6-adeb-d7099893f45c', '9D635AB2-8CDA-4463-9585-A8B64B631C80', 3, 'Low', 'Low', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 58f53c85-45e8-44e6-8def-66fb62325211 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('58f53c85-45e8-44e6-8def-66fb62325211', '9D635AB2-8CDA-4463-9585-A8B64B631C80', 4, 'Medium', 'Medium', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID 9D635AB2-8CDA-4463-9585-A8B64B631C80 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='9D635AB2-8CDA-4463-9585-A8B64B631C80'

/* SQL text to insert entity field value with ID 0eb23e15-75e5-4803-8e3a-2ae4a100bb19 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0eb23e15-75e5-4803-8e3a-2ae4a100bb19', 'E09FA353-A52C-4ED4-B6E2-8683E3349E48', 1, 'FinishToFinish', 'FinishToFinish', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 537d5b4c-6099-4893-a779-dd7d938590f8 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('537d5b4c-6099-4893-a779-dd7d938590f8', 'E09FA353-A52C-4ED4-B6E2-8683E3349E48', 2, 'FinishToStart', 'FinishToStart', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 55c90112-34a3-4961-a47f-f2c9fa619fc4 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('55c90112-34a3-4961-a47f-f2c9fa619fc4', 'E09FA353-A52C-4ED4-B6E2-8683E3349E48', 3, 'StartToFinish', 'StartToFinish', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 7fcf441f-835d-424c-8156-a71fb814a9d5 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7fcf441f-835d-424c-8156-a71fb814a9d5', 'E09FA353-A52C-4ED4-B6E2-8683E3349E48', 4, 'StartToStart', 'StartToStart', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID E09FA353-A52C-4ED4-B6E2-8683E3349E48 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='E09FA353-A52C-4ED4-B6E2-8683E3349E48'

/* SQL text to insert entity field value with ID 42bb9b11-fdcb-4221-9fa0-8332c0f81cfe */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('42bb9b11-fdcb-4221-9fa0-8332c0f81cfe', 'A62D29AE-4C11-4FA7-B524-7212A6455791', 1, 'Critical', 'Critical', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID f3a00a1b-9881-48c1-a91d-c53467197e88 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f3a00a1b-9881-48c1-a91d-c53467197e88', 'A62D29AE-4C11-4FA7-B524-7212A6455791', 2, 'High', 'High', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 75d45b2a-e576-497e-8915-a51fc4c803fa */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('75d45b2a-e576-497e-8915-a51fc4c803fa', 'A62D29AE-4C11-4FA7-B524-7212A6455791', 3, 'Low', 'Low', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 8c93102c-987f-4432-9031-77fd459e1943 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('8c93102c-987f-4432-9031-77fd459e1943', 'A62D29AE-4C11-4FA7-B524-7212A6455791', 4, 'Medium', 'Medium', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID A62D29AE-4C11-4FA7-B524-7212A6455791 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='A62D29AE-4C11-4FA7-B524-7212A6455791'

/* SQL text to insert entity field value with ID 3f2763e7-c4c2-4742-a3eb-94b3f52ce122 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('3f2763e7-c4c2-4742-a3eb-94b3f52ce122', 'A01AB680-7864-45F8-B38A-F2642B9F94BC', 1, 'AssignmentAdded', 'AssignmentAdded', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID b3ade944-bfad-4410-b567-f66fd9576185 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b3ade944-bfad-4410-b567-f66fd9576185', 'A01AB680-7864-45F8-B38A-F2642B9F94BC', 2, 'AssignmentRemoved', 'AssignmentRemoved', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 15d9e45c-bf2c-43af-a05c-8e70b70443b2 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('15d9e45c-bf2c-43af-a05c-8e70b70443b2', 'A01AB680-7864-45F8-B38A-F2642B9F94BC', 3, 'Completed', 'Completed', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 5b2dfac7-dc73-477f-b514-557a359b85c4 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('5b2dfac7-dc73-477f-b514-557a359b85c4', 'A01AB680-7864-45F8-B38A-F2642B9F94BC', 4, 'Created', 'Created', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID be4b2bae-49d1-44b1-a2f6-fdb4068672d4 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('be4b2bae-49d1-44b1-a2f6-fdb4068672d4', 'A01AB680-7864-45F8-B38A-F2642B9F94BC', 5, 'DependencyAdded', 'DependencyAdded', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 2f1a0b66-995b-46e4-b634-97769849fec6 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('2f1a0b66-995b-46e4-b634-97769849fec6', 'A01AB680-7864-45F8-B38A-F2642B9F94BC', 6, 'DependencyRemoved', 'DependencyRemoved', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 1389f0e9-635b-4228-9b59-8be47f985465 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1389f0e9-635b-4228-9b59-8be47f985465', 'A01AB680-7864-45F8-B38A-F2642B9F94BC', 7, 'DueDateChanged', 'DueDateChanged', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID e88a2cb6-77cc-4fd1-bc8d-30835f806f62 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('e88a2cb6-77cc-4fd1-bc8d-30835f806f62', 'A01AB680-7864-45F8-B38A-F2642B9F94BC', 8, 'PercentCompleteChanged', 'PercentCompleteChanged', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID f5b00dd2-be23-4cf2-929f-7e85cdd42490 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f5b00dd2-be23-4cf2-929f-7e85cdd42490', 'A01AB680-7864-45F8-B38A-F2642B9F94BC', 9, 'PriorityChanged', 'PriorityChanged', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 83238ca4-4f70-45a4-9639-624b5a6f9c4b */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('83238ca4-4f70-45a4-9639-624b5a6f9c4b', 'A01AB680-7864-45F8-B38A-F2642B9F94BC', 10, 'StatusChange', 'StatusChange', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID A01AB680-7864-45F8-B38A-F2642B9F94BC */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='A01AB680-7864-45F8-B38A-F2642B9F94BC'

/* SQL text to insert entity field value with ID cad29e93-75eb-4de1-b30a-12110f81f979 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('cad29e93-75eb-4de1-b30a-12110f81f979', 'BD66B261-F76D-4FEF-8991-A5DDAC18E671', 1, 'Blocked', 'Blocked', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 55b0da76-c20c-448c-a0e3-d166e248e800 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('55b0da76-c20c-448c-a0e3-d166e248e800', 'BD66B261-F76D-4FEF-8991-A5DDAC18E671', 2, 'Cancelled', 'Cancelled', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID ab3a387f-a24e-4b98-a3b7-d83eb187c21d */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ab3a387f-a24e-4b98-a3b7-d83eb187c21d', 'BD66B261-F76D-4FEF-8991-A5DDAC18E671', 3, 'Completed', 'Completed', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID d4e7e249-900e-41f2-bf52-51e2e52ca2d1 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d4e7e249-900e-41f2-bf52-51e2e52ca2d1', 'BD66B261-F76D-4FEF-8991-A5DDAC18E671', 4, 'InProgress', 'InProgress', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 959dd7f7-ea60-449c-99ef-d385d2fd1fa7 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('959dd7f7-ea60-449c-99ef-d385d2fd1fa7', 'BD66B261-F76D-4FEF-8991-A5DDAC18E671', 5, 'Open', 'Open', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID BD66B261-F76D-4FEF-8991-A5DDAC18E671 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='BD66B261-F76D-4FEF-8991-A5DDAC18E671'

/* SQL text to insert entity field value with ID 2eb2491e-875f-4f59-8112-a172de8787e0 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('2eb2491e-875f-4f59-8112-a172de8787e0', '572FF0A1-E335-4BEE-97F9-61040A937656', 1, 'Critical', 'Critical', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 48878953-46f1-4b7a-bfe7-477126ee013c */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('48878953-46f1-4b7a-bfe7-477126ee013c', '572FF0A1-E335-4BEE-97F9-61040A937656', 2, 'High', 'High', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 7baf6654-b295-41c7-9bee-366e33ad4044 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7baf6654-b295-41c7-9bee-366e33ad4044', '572FF0A1-E335-4BEE-97F9-61040A937656', 3, 'Low', 'Low', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 0cf942a1-9e97-4f11-bc7d-d21ce37aee65 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0cf942a1-9e97-4f11-bc7d-d21ce37aee65', '572FF0A1-E335-4BEE-97F9-61040A937656', 4, 'Medium', 'Medium', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID 572FF0A1-E335-4BEE-97F9-61040A937656 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='572FF0A1-E335-4BEE-97F9-61040A937656'

/* SQL text to insert entity field value with ID 1c49e88e-8c05-4022-b8b6-a3a377e5dc57 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1c49e88e-8c05-4022-b8b6-a3a377e5dc57', 'C5FAB46F-0DFB-4809-B16F-CEDB0FCF1EDF', 1, 'Completed', 'Completed', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID ccee7fda-4b9f-420f-8d47-a100401e7ffc */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ccee7fda-4b9f-420f-8d47-a100401e7ffc', 'C5FAB46F-0DFB-4809-B16F-CEDB0FCF1EDF', 2, 'InProgress', 'InProgress', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 9fb17c31-b708-49b8-8cc1-aa496bfab9b5 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9fb17c31-b708-49b8-8cc1-aa496bfab9b5', 'C5FAB46F-0DFB-4809-B16F-CEDB0FCF1EDF', 3, 'Pending', 'Pending', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID C5FAB46F-0DFB-4809-B16F-CEDB0FCF1EDF */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='C5FAB46F-0DFB-4809-B16F-CEDB0FCF1EDF'


/* Create Entity Relationship: MJ.BizApps.Tasks:Task Templates -> MJ.BizApps.Tasks:Task Template Items (One To Many via TemplateID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '107b0098-79de-4fb9-97b4-abe029448413'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('107b0098-79de-4fb9-97b4-abe029448413', '345A453C-3461-4CD8-ABCC-005828C574C6', 'F037786E-F201-4552-844A-1E53F15C00C0', 'TemplateID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ.BizApps.Tasks:Task Tags -> MJ.BizApps.Tasks:Task Tag Links (One To Many via TagID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'b3c98adb-7ebc-4230-a2a9-dea1940f6001'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('b3c98adb-7ebc-4230-a2a9-dea1940f6001', '554020DD-176B-44F6-8265-1ABA0A430BEB', '06695129-6AF1-4D16-8209-9D0E9984845A', 'TagID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Tasks:Task Template Items -> MJ.BizApps.Tasks:Task Template Item Roles (One To Many via ItemID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'f1d9487e-8a49-4f91-83c3-9dcb27504e4d'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('f1d9487e-8a49-4f91-83c3-9dcb27504e4d', 'F037786E-F201-4552-844A-1E53F15C00C0', 'C14BDC39-5B0D-4159-8E11-5E48ECD746C4', 'ItemID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ.BizApps.Tasks:Task Template Items -> MJ.BizApps.Tasks:Task Template Items (One To Many via ParentItemID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '8865b97a-185e-4fdb-a4e8-aebe59abc00d'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('8865b97a-185e-4fdb-a4e8-aebe59abc00d', 'F037786E-F201-4552-844A-1E53F15C00C0', 'F037786E-F201-4552-844A-1E53F15C00C0', 'ParentItemID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Tasks:Task Template Items -> MJ.BizApps.Tasks:Task Template Item Dependencies (One To Many via DependsOnItemID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '1427eed3-8f97-4118-acbc-e7b91996d8cf'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('1427eed3-8f97-4118-acbc-e7b91996d8cf', 'F037786E-F201-4552-844A-1E53F15C00C0', '19CD22D9-4E20-499C-B9D2-2390271CDC0E', 'DependsOnItemID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Tasks:Task Template Items -> MJ.BizApps.Tasks:Task Template Item Dependencies (One To Many via ItemID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '11eeeb16-9c3b-4110-8c44-be774e8e0966'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('11eeeb16-9c3b-4110-8c44-be774e8e0966', 'F037786E-F201-4552-844A-1E53F15C00C0', '19CD22D9-4E20-499C-B9D2-2390271CDC0E', 'ItemID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ.BizApps.Tasks:Task Categories -> MJ.BizApps.Tasks:Tasks (One To Many via CategoryID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '6a65ab69-6150-40a0-a63a-983a1541f59c'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('6a65ab69-6150-40a0-a63a-983a1541f59c', 'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB', 'E58F681E-E956-4FD9-87C9-7197BC631641', 'CategoryID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Tasks:Task Categories -> MJ.BizApps.Tasks:Task Categories (One To Many via ParentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'a3ba66ff-651b-48ae-8748-e2e2ca8236e6'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a3ba66ff-651b-48ae-8748-e2e2ca8236e6', 'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB', 'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB', 'ParentID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Tasks:Task Categories -> MJ.BizApps.Tasks:Task Templates (One To Many via CategoryID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '7c322aa3-9216-492b-b63a-c3cfba7075f6'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('7c322aa3-9216-492b-b63a-c3cfba7075f6', 'CDF7F284-93BB-4055-9B1A-3FA253CCFEAB', '345A453C-3461-4CD8-ABCC-005828C574C6', 'CategoryID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ: Entities -> MJ.BizApps.Tasks:Task Assignments (One To Many via AssigneeEntityID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '968e2346-a201-498f-b1e0-cf7a56ac1cfa'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('968e2346-a201-498f-b1e0-cf7a56ac1cfa', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21', 'AssigneeEntityID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ: Entities -> MJ.BizApps.Tasks:Task Links (One To Many via EntityID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'a1c0433f-a29c-4c0c-a4c9-027f8a487ed1'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a1c0433f-a29c-4c0c-a4c9-027f8a487ed1', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'F586669B-055F-4F7E-82F2-64CAFF7AC92E', 'EntityID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ: Actions -> MJ.BizApps.Tasks:Task Types (One To Many via OnCompleteActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '9f36ab1f-daa3-43f3-b299-2598f5b5a2ca'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('9f36ab1f-daa3-43f3-b299-2598f5b5a2ca', '38248F34-2837-EF11-86D4-6045BDEE16E6', 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', 'OnCompleteActionID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Actions -> MJ.BizApps.Tasks:Task Types (One To Many via OnOverdueActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'b9b2b3bd-5356-41da-baec-8fa3cd9635c2'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('b9b2b3bd-5356-41da-baec-8fa3cd9635c2', '38248F34-2837-EF11-86D4-6045BDEE16E6', 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', 'OnOverdueActionID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Actions -> MJ.BizApps.Tasks:Task Types (One To Many via OnAssignActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '33d4ec6e-bb44-4eae-9f12-2a846cb167a6'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('33d4ec6e-bb44-4eae-9f12-2a846cb167a6', '38248F34-2837-EF11-86D4-6045BDEE16E6', 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', 'OnAssignActionID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Actions -> MJ.BizApps.Tasks:Task Types (One To Many via OnPercentChangeActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'ef4e47ec-3076-41ef-85ff-f73863e22ba8'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('ef4e47ec-3076-41ef-85ff-f73863e22ba8', '38248F34-2837-EF11-86D4-6045BDEE16E6', 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', 'OnPercentChangeActionID', 'One To Many', 1, 1, 4, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ.BizApps.Tasks:Task Types -> MJ.BizApps.Tasks:Tasks (One To Many via TypeID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '7f4b2435-09fd-475b-a13e-edb4d67163cc'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('7f4b2435-09fd-475b-a13e-edb4d67163cc', 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', 'E58F681E-E956-4FD9-87C9-7197BC631641', 'TypeID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Tasks:Task Types -> MJ.BizApps.Tasks:Task Templates (One To Many via TypeID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'a418fcbf-49b8-47bb-a6c7-14a8ed094994'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a418fcbf-49b8-47bb-a6c7-14a8ed094994', 'A60593BC-E4EE-42D9-9A28-6A1E90F41EE5', '345A453C-3461-4CD8-ABCC-005828C574C6', 'TypeID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ.BizApps.Tasks:Tasks -> MJ.BizApps.Tasks:Task Assignments (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'f3cdbf77-1c91-4d06-a187-9daf250d7f2a'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('f3cdbf77-1c91-4d06-a187-9daf250d7f2a', 'E58F681E-E956-4FD9-87C9-7197BC631641', '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21', 'TaskID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Tasks:Tasks -> MJ.BizApps.Tasks:Task Links (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'f5dd38fb-2c4e-401d-996e-fc3e632991e3'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('f5dd38fb-2c4e-401d-996e-fc3e632991e3', 'E58F681E-E956-4FD9-87C9-7197BC631641', 'F586669B-055F-4F7E-82F2-64CAFF7AC92E', 'TaskID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ.BizApps.Tasks:Tasks -> Artifacts (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'aef43e56-154a-4fb2-8b46-4426e75eed99'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('aef43e56-154a-4fb2-8b46-4426e75eed99', 'E58F681E-E956-4FD9-87C9-7197BC631641', 'DC523BBE-93DC-49FC-B066-621D3C8162E2', 'TaskID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Tasks:Tasks -> MJ.BizApps.Tasks:Task Dependencies (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '932d7dfe-30a4-45c7-8706-30b450e12841'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('932d7dfe-30a4-45c7-8706-30b450e12841', 'E58F681E-E956-4FD9-87C9-7197BC631641', '82B3253E-8E72-4BF6-8F94-82EBD13084D9', 'TaskID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Tasks:Tasks -> MJ.BizApps.Tasks:Task Dependencies (One To Many via DependsOnTaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'ec13f4f7-f4cc-47e3-a681-7ad98e17eee0'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('ec13f4f7-f4cc-47e3-a681-7ad98e17eee0', 'E58F681E-E956-4FD9-87C9-7197BC631641', '82B3253E-8E72-4BF6-8F94-82EBD13084D9', 'DependsOnTaskID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Tasks:Tasks -> MJ.BizApps.Tasks:Tasks (One To Many via ParentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '773a1a83-5bcd-46c8-af1f-d531926552a1'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('773a1a83-5bcd-46c8-af1f-d531926552a1', 'E58F681E-E956-4FD9-87C9-7197BC631641', 'E58F681E-E956-4FD9-87C9-7197BC631641', 'ParentID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Tasks:Tasks -> MJ.BizApps.Tasks:Task Comments (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '176fae2f-8fc7-4e1f-9c92-0f4a65439ef4'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('176fae2f-8fc7-4e1f-9c92-0f4a65439ef4', 'E58F681E-E956-4FD9-87C9-7197BC631641', '9584FD7A-99A4-41B0-9057-D2AC30655DA9', 'TaskID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Tasks:Tasks -> MJ.BizApps.Tasks:Task Activities (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '9404b4d4-e31e-4043-aaef-6b0f6a11e23c'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('9404b4d4-e31e-4043-aaef-6b0f6a11e23c', 'E58F681E-E956-4FD9-87C9-7197BC631641', '95A39DD9-54D6-4839-9BA8-D746FCB90115', 'TaskID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ.BizApps.Tasks:Tasks -> Comments (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'f253be0d-968c-4107-8ce4-0aa48b89e6a0'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('f253be0d-968c-4107-8ce4-0aa48b89e6a0', 'E58F681E-E956-4FD9-87C9-7197BC631641', '9DC1631E-F623-44FB-A796-A70BE70923D1', 'TaskID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Tasks:Tasks -> MJ.BizApps.Tasks:Task Tag Links (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '65cbc10f-2d6f-4fc4-9c01-4e21d52a06e8'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('65cbc10f-2d6f-4fc4-9c01-4e21d52a06e8', 'E58F681E-E956-4FD9-87C9-7197BC631641', '06695129-6AF1-4D16-8209-9D0E9984845A', 'TaskID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ.BizApps.Tasks:Task Roles -> MJ.BizApps.Tasks:Task Assignments (One To Many via RoleID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '060acf48-aba5-4f05-9dd3-a2c704d07c8a'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('060acf48-aba5-4f05-9dd3-a2c704d07c8a', '9CF47E3C-32C3-426A-9412-AF9355F875EB', '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21', 'RoleID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Tasks:Task Roles -> MJ.BizApps.Tasks:Task Template Item Roles (One To Many via RoleID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '0ca884d2-7fa8-4650-84e9-3c61bafe74be'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('0ca884d2-7fa8-4650-84e9-3c61bafe74be', '9CF47E3C-32C3-426A-9412-AF9355F875EB', 'C14BDC39-5B0D-4159-8E11-5E48ECD746C4', 'RoleID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ.BizApps.Tasks:Task Comments -> MJ.BizApps.Tasks:Task Comments (One To Many via ParentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '5e10950b-ca9b-4002-8128-e38befec90c9'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('5e10950b-ca9b-4002-8128-e38befec90c9', '9584FD7A-99A4-41B0-9057-D2AC30655DA9', '9584FD7A-99A4-41B0-9057-D2AC30655DA9', 'ParentID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ.BizApps.Common: People -> MJ.BizApps.Tasks:Task Assignments (One To Many via AssignedByPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '5df44f41-5164-48eb-a594-ae1e965cf93b'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('5df44f41-5164-48eb-a594-ae1e965cf93b', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '62694F71-8E1A-4B41-9B54-0FCC7EE0FD21', 'AssignedByPersonID', 'One To Many', 1, 1, 4, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ.BizApps.Common: People -> MJ.BizApps.Tasks:Task Activities (One To Many via PersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '3396856d-df2d-44db-8c10-1e4719dcd6ca'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('3396856d-df2d-44db-8c10-1e4719dcd6ca', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '95A39DD9-54D6-4839-9BA8-D746FCB90115', 'PersonID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Common: People -> MJ.BizApps.Tasks:Task Comments (One To Many via PersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '1e51750e-492c-4e52-98b0-4e59262b4486'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('1e51750e-492c-4e52-98b0-4e59262b4486', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '9584FD7A-99A4-41B0-9057-D2AC30655DA9', 'PersonID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Common: People -> MJ.BizApps.Tasks:Tasks (One To Many via CreatedByPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'e95ff111-e7bb-400d-b614-fd97ce749547'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('e95ff111-e7bb-400d-b614-fd97ce749547', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'E58F681E-E956-4FD9-87C9-7197BC631641', 'CreatedByPersonID', 'One To Many', 1, 1, 4, GETUTCDATE(), GETUTCDATE())
   END;
                    

/* Index for Foreign Keys for Artifact */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Artifacts
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key CommitteeID in table Artifact
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Artifact_CommitteeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_Committees].[Artifact]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Artifact_CommitteeID ON [${flyway:defaultSchema}_Committees].[Artifact] ([CommitteeID]);

-- Index for foreign key MeetingID in table Artifact
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Artifact_MeetingID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_Committees].[Artifact]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Artifact_MeetingID ON [${flyway:defaultSchema}_Committees].[Artifact] ([MeetingID]);

-- Index for foreign key AgendaItemID in table Artifact
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Artifact_AgendaItemID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_Committees].[Artifact]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Artifact_AgendaItemID ON [${flyway:defaultSchema}_Committees].[Artifact] ([AgendaItemID]);

-- Index for foreign key ActionItemID in table Artifact
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Artifact_ActionItemID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_Committees].[Artifact]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Artifact_ActionItemID ON [${flyway:defaultSchema}_Committees].[Artifact] ([ActionItemID]);

-- Index for foreign key ArtifactTypeID in table Artifact
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Artifact_ArtifactTypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_Committees].[Artifact]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Artifact_ArtifactTypeID ON [${flyway:defaultSchema}_Committees].[Artifact] ([ArtifactTypeID]);

-- Index for foreign key UploadedByPersonID in table Artifact
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Artifact_UploadedByPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_Committees].[Artifact]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Artifact_UploadedByPersonID ON [${flyway:defaultSchema}_Committees].[Artifact] ([UploadedByPersonID]);

/* Base View SQL for Artifacts */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Artifacts
-- Item: vwArtifacts
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Artifacts
-----               SCHEMA:      ${flyway:defaultSchema}_Committees
-----               BASE TABLE:  Artifact
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_Committees].[vwArtifacts]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_Committees].[vwArtifacts];
GO

CREATE VIEW [${flyway:defaultSchema}_Committees].[vwArtifacts]
AS
SELECT
    a.*,
    mjCommitteesCommittee_CommitteeID.[Name] AS [Committee],
    mjCommitteesMeeting_MeetingID.[Title] AS [Meeting],
    mjCommitteesAgendaItem_AgendaItemID.[Title] AS [AgendaItem],
    mjCommitteesActionItem_ActionItemID.[Title] AS [ActionItem],
    mjCommitteesArtifactType_ArtifactTypeID.[Name] AS [ArtifactType],
    mjBizAppsCommonPerson_UploadedByPersonID.[DisplayName] AS [UploadedByPerson]
FROM
    [${flyway:defaultSchema}_Committees].[Artifact] AS a
LEFT OUTER JOIN
    [${flyway:defaultSchema}_Committees].[Committee] AS mjCommitteesCommittee_CommitteeID
  ON
    [a].[CommitteeID] = mjCommitteesCommittee_CommitteeID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_Committees].[Meeting] AS mjCommitteesMeeting_MeetingID
  ON
    [a].[MeetingID] = mjCommitteesMeeting_MeetingID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_Committees].[AgendaItem] AS mjCommitteesAgendaItem_AgendaItemID
  ON
    [a].[AgendaItemID] = mjCommitteesAgendaItem_AgendaItemID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_Committees].[ActionItem] AS mjCommitteesActionItem_ActionItemID
  ON
    [a].[ActionItemID] = mjCommitteesActionItem_ActionItemID.[ID]
INNER JOIN
    [${flyway:defaultSchema}_Committees].[ArtifactType] AS mjCommitteesArtifactType_ArtifactTypeID
  ON
    [a].[ArtifactTypeID] = mjCommitteesArtifactType_ArtifactTypeID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[vwPeopleExtended] AS mjBizAppsCommonPerson_UploadedByPersonID
  ON
    [a].[UploadedByPersonID] = mjBizAppsCommonPerson_UploadedByPersonID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}_Committees].[vwArtifacts] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Artifacts */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Artifacts
-- Item: Permissions for vwArtifacts
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_Committees].[vwArtifacts] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Artifacts */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Artifacts
-- Item: spCreateArtifact
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Artifact
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_Committees].[spCreateArtifact]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_Committees].[spCreateArtifact];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_Committees].[spCreateArtifact]
    @ID uniqueidentifier = NULL,
    @CommitteeID uniqueidentifier,
    @MeetingID uniqueidentifier,
    @AgendaItemID uniqueidentifier,
    @ActionItemID uniqueidentifier,
    @Title nvarchar(255),
    @Description nvarchar(MAX),
    @ArtifactTypeID uniqueidentifier,
    @Provider nvarchar(50),
    @ExternalID nvarchar(500),
    @URL nvarchar(2000),
    @MimeType nvarchar(100),
    @FileSize bigint,
    @UploadedByPersonID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_Committees].[Artifact]
            (
                [ID],
                [CommitteeID],
                [MeetingID],
                [AgendaItemID],
                [ActionItemID],
                [Title],
                [Description],
                [ArtifactTypeID],
                [Provider],
                [ExternalID],
                [URL],
                [MimeType],
                [FileSize],
                [UploadedByPersonID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @CommitteeID,
                @MeetingID,
                @AgendaItemID,
                @ActionItemID,
                @Title,
                @Description,
                @ArtifactTypeID,
                @Provider,
                @ExternalID,
                @URL,
                @MimeType,
                @FileSize,
                @UploadedByPersonID
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_Committees].[Artifact]
            (
                [CommitteeID],
                [MeetingID],
                [AgendaItemID],
                [ActionItemID],
                [Title],
                [Description],
                [ArtifactTypeID],
                [Provider],
                [ExternalID],
                [URL],
                [MimeType],
                [FileSize],
                [UploadedByPersonID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @CommitteeID,
                @MeetingID,
                @AgendaItemID,
                @ActionItemID,
                @Title,
                @Description,
                @ArtifactTypeID,
                @Provider,
                @ExternalID,
                @URL,
                @MimeType,
                @FileSize,
                @UploadedByPersonID
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_Committees].[vwArtifacts] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_Committees].[spCreateArtifact] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Artifacts */

GRANT EXECUTE ON [${flyway:defaultSchema}_Committees].[spCreateArtifact] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Artifacts */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Artifacts
-- Item: spUpdateArtifact
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Artifact
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_Committees].[spUpdateArtifact]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_Committees].[spUpdateArtifact];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_Committees].[spUpdateArtifact]
    @ID uniqueidentifier,
    @CommitteeID uniqueidentifier,
    @MeetingID uniqueidentifier,
    @AgendaItemID uniqueidentifier,
    @ActionItemID uniqueidentifier,
    @Title nvarchar(255),
    @Description nvarchar(MAX),
    @ArtifactTypeID uniqueidentifier,
    @Provider nvarchar(50),
    @ExternalID nvarchar(500),
    @URL nvarchar(2000),
    @MimeType nvarchar(100),
    @FileSize bigint,
    @UploadedByPersonID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_Committees].[Artifact]
    SET
        [CommitteeID] = @CommitteeID,
        [MeetingID] = @MeetingID,
        [AgendaItemID] = @AgendaItemID,
        [ActionItemID] = @ActionItemID,
        [Title] = @Title,
        [Description] = @Description,
        [ArtifactTypeID] = @ArtifactTypeID,
        [Provider] = @Provider,
        [ExternalID] = @ExternalID,
        [URL] = @URL,
        [MimeType] = @MimeType,
        [FileSize] = @FileSize,
        [UploadedByPersonID] = @UploadedByPersonID
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_Committees].[vwArtifacts] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_Committees].[vwArtifacts]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_Committees].[spUpdateArtifact] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Artifact table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_Committees].[trgUpdateArtifact]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_Committees].[trgUpdateArtifact];
GO
CREATE TRIGGER [${flyway:defaultSchema}_Committees].trgUpdateArtifact
ON [${flyway:defaultSchema}_Committees].[Artifact]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_Committees].[Artifact]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_Committees].[Artifact] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Artifacts */

GRANT EXECUTE ON [${flyway:defaultSchema}_Committees].[spUpdateArtifact] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Artifacts */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Artifacts
-- Item: spDeleteArtifact
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Artifact
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_Committees].[spDeleteArtifact]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_Committees].[spDeleteArtifact];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_Committees].[spDeleteArtifact]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_Committees].[Artifact]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_Committees].[spDeleteArtifact] TO [cdp_Developer], [cdp_Integration]
    

/* spDelete Permissions for Artifacts */

GRANT EXECUTE ON [${flyway:defaultSchema}_Committees].[spDeleteArtifact] TO [cdp_Developer], [cdp_Integration]



/* Index for Foreign Keys for Comment */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Comments
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key CommitteeID in table Comment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Comment_CommitteeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_Committees].[Comment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Comment_CommitteeID ON [${flyway:defaultSchema}_Committees].[Comment] ([CommitteeID]);

-- Index for foreign key MeetingID in table Comment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Comment_MeetingID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_Committees].[Comment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Comment_MeetingID ON [${flyway:defaultSchema}_Committees].[Comment] ([MeetingID]);

-- Index for foreign key AgendaItemID in table Comment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Comment_AgendaItemID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_Committees].[Comment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Comment_AgendaItemID ON [${flyway:defaultSchema}_Committees].[Comment] ([AgendaItemID]);

-- Index for foreign key ActionItemID in table Comment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Comment_ActionItemID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_Committees].[Comment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Comment_ActionItemID ON [${flyway:defaultSchema}_Committees].[Comment] ([ActionItemID]);

-- Index for foreign key ArtifactID in table Comment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Comment_ArtifactID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_Committees].[Comment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Comment_ArtifactID ON [${flyway:defaultSchema}_Committees].[Comment] ([ArtifactID]);

-- Index for foreign key ParentCommentID in table Comment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Comment_ParentCommentID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_Committees].[Comment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Comment_ParentCommentID ON [${flyway:defaultSchema}_Committees].[Comment] ([ParentCommentID]);

-- Index for foreign key PersonID in table Comment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Comment_PersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_Committees].[Comment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Comment_PersonID ON [${flyway:defaultSchema}_Committees].[Comment] ([PersonID]);

/* Root ID Function SQL for Comments.ParentCommentID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Comments
-- Item: fnCommentParentCommentID_GetRootID
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- ROOT ID FUNCTION FOR: [Comment].[ParentCommentID]
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_Committees].[fnCommentParentCommentID_GetRootID]', 'IF') IS NOT NULL
    DROP FUNCTION [${flyway:defaultSchema}_Committees].[fnCommentParentCommentID_GetRootID];
GO

CREATE FUNCTION [${flyway:defaultSchema}_Committees].[fnCommentParentCommentID_GetRootID]
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
            [ParentCommentID],
            [ID] AS [RootParentID],
            0 AS [Depth]
        FROM
            [${flyway:defaultSchema}_Committees].[Comment]
        WHERE
            [ID] = COALESCE(@ParentID, @RecordID)

        UNION ALL

        SELECT
            c.[ID],
            c.[ParentCommentID],
            c.[ID] AS [RootParentID],
            p.[Depth] + 1 AS [Depth]
        FROM
            [${flyway:defaultSchema}_Committees].[Comment] c
        INNER JOIN
            CTE_RootParent p ON c.[ID] = p.[ParentCommentID]
        WHERE
            p.[Depth] < 100
    )
    SELECT TOP 1
        [RootParentID] AS RootID
    FROM
        CTE_RootParent
    WHERE
        [ParentCommentID] IS NULL
    ORDER BY
        [RootParentID]
);
GO


/* Base View SQL for Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Comments
-- Item: vwComments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Comments
-----               SCHEMA:      ${flyway:defaultSchema}_Committees
-----               BASE TABLE:  Comment
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_Committees].[vwComments]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_Committees].[vwComments];
GO

CREATE VIEW [${flyway:defaultSchema}_Committees].[vwComments]
AS
SELECT
    c.*,
    mjCommitteesCommittee_CommitteeID.[Name] AS [Committee],
    mjCommitteesMeeting_MeetingID.[Title] AS [Meeting],
    mjCommitteesAgendaItem_AgendaItemID.[Title] AS [AgendaItem],
    mjCommitteesActionItem_ActionItemID.[Title] AS [ActionItem],
    mjCommitteesArtifact_ArtifactID.[Title] AS [Artifact],
    mjCommitteesComment_ParentCommentID.[CommentText] AS [ParentComment],
    mjBizAppsCommonPerson_PersonID.[DisplayName] AS [Person],
    root_ParentCommentID.RootID AS [RootParentCommentID]
FROM
    [${flyway:defaultSchema}_Committees].[Comment] AS c
INNER JOIN
    [${flyway:defaultSchema}_Committees].[Committee] AS mjCommitteesCommittee_CommitteeID
  ON
    [c].[CommitteeID] = mjCommitteesCommittee_CommitteeID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_Committees].[Meeting] AS mjCommitteesMeeting_MeetingID
  ON
    [c].[MeetingID] = mjCommitteesMeeting_MeetingID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_Committees].[AgendaItem] AS mjCommitteesAgendaItem_AgendaItemID
  ON
    [c].[AgendaItemID] = mjCommitteesAgendaItem_AgendaItemID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_Committees].[ActionItem] AS mjCommitteesActionItem_ActionItemID
  ON
    [c].[ActionItemID] = mjCommitteesActionItem_ActionItemID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_Committees].[Artifact] AS mjCommitteesArtifact_ArtifactID
  ON
    [c].[ArtifactID] = mjCommitteesArtifact_ArtifactID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_Committees].[Comment] AS mjCommitteesComment_ParentCommentID
  ON
    [c].[ParentCommentID] = mjCommitteesComment_ParentCommentID.[ID]
INNER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[vwPeopleExtended] AS mjBizAppsCommonPerson_PersonID
  ON
    [c].[PersonID] = mjBizAppsCommonPerson_PersonID.[ID]
OUTER APPLY
    [${flyway:defaultSchema}_Committees].[fnCommentParentCommentID_GetRootID]([c].[ID], [c].[ParentCommentID]) AS root_ParentCommentID
GO
GRANT SELECT ON [${flyway:defaultSchema}_Committees].[vwComments] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Comments
-- Item: Permissions for vwComments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_Committees].[vwComments] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Comments
-- Item: spCreateComment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Comment
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_Committees].[spCreateComment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_Committees].[spCreateComment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_Committees].[spCreateComment]
    @ID uniqueidentifier = NULL,
    @CommitteeID uniqueidentifier,
    @MeetingID uniqueidentifier,
    @AgendaItemID uniqueidentifier,
    @ActionItemID uniqueidentifier,
    @ArtifactID uniqueidentifier,
    @ParentCommentID uniqueidentifier,
    @PersonID uniqueidentifier,
    @CommentText nvarchar(MAX),
    @MentionedPersonIDs nvarchar(MAX),
    @IsResolved bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_Committees].[Comment]
            (
                [ID],
                [CommitteeID],
                [MeetingID],
                [AgendaItemID],
                [ActionItemID],
                [ArtifactID],
                [ParentCommentID],
                [PersonID],
                [CommentText],
                [MentionedPersonIDs],
                [IsResolved]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @CommitteeID,
                @MeetingID,
                @AgendaItemID,
                @ActionItemID,
                @ArtifactID,
                @ParentCommentID,
                @PersonID,
                @CommentText,
                @MentionedPersonIDs,
                ISNULL(@IsResolved, 0)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_Committees].[Comment]
            (
                [CommitteeID],
                [MeetingID],
                [AgendaItemID],
                [ActionItemID],
                [ArtifactID],
                [ParentCommentID],
                [PersonID],
                [CommentText],
                [MentionedPersonIDs],
                [IsResolved]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @CommitteeID,
                @MeetingID,
                @AgendaItemID,
                @ActionItemID,
                @ArtifactID,
                @ParentCommentID,
                @PersonID,
                @CommentText,
                @MentionedPersonIDs,
                ISNULL(@IsResolved, 0)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_Committees].[vwComments] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_Committees].[spCreateComment] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Comments */

GRANT EXECUTE ON [${flyway:defaultSchema}_Committees].[spCreateComment] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Comments
-- Item: spUpdateComment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Comment
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_Committees].[spUpdateComment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_Committees].[spUpdateComment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_Committees].[spUpdateComment]
    @ID uniqueidentifier,
    @CommitteeID uniqueidentifier,
    @MeetingID uniqueidentifier,
    @AgendaItemID uniqueidentifier,
    @ActionItemID uniqueidentifier,
    @ArtifactID uniqueidentifier,
    @ParentCommentID uniqueidentifier,
    @PersonID uniqueidentifier,
    @CommentText nvarchar(MAX),
    @MentionedPersonIDs nvarchar(MAX),
    @IsResolved bit
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_Committees].[Comment]
    SET
        [CommitteeID] = @CommitteeID,
        [MeetingID] = @MeetingID,
        [AgendaItemID] = @AgendaItemID,
        [ActionItemID] = @ActionItemID,
        [ArtifactID] = @ArtifactID,
        [ParentCommentID] = @ParentCommentID,
        [PersonID] = @PersonID,
        [CommentText] = @CommentText,
        [MentionedPersonIDs] = @MentionedPersonIDs,
        [IsResolved] = @IsResolved
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_Committees].[vwComments] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_Committees].[vwComments]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_Committees].[spUpdateComment] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Comment table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_Committees].[trgUpdateComment]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_Committees].[trgUpdateComment];
GO
CREATE TRIGGER [${flyway:defaultSchema}_Committees].trgUpdateComment
ON [${flyway:defaultSchema}_Committees].[Comment]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_Committees].[Comment]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_Committees].[Comment] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Comments */

GRANT EXECUTE ON [${flyway:defaultSchema}_Committees].[spUpdateComment] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Comments
-- Item: spDeleteComment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Comment
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_Committees].[spDeleteComment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_Committees].[spDeleteComment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_Committees].[spDeleteComment]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_Committees].[Comment]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_Committees].[spDeleteComment] TO [cdp_Developer], [cdp_Integration]
    

/* spDelete Permissions for Comments */

GRANT EXECUTE ON [${flyway:defaultSchema}_Committees].[spDeleteComment] TO [cdp_Developer], [cdp_Integration]



