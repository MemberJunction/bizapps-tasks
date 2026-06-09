/* SQL generated to create new entity MJ_BizApps_Tasks: Task Roles */

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
         '559054c2-8f03-4a66-b4fd-70de5948ace2',
         'MJ_BizApps_Tasks: Task Roles',
         'Task Roles',
         NULL,
         NULL,
         'TaskRole',
         'vwTaskRoles',
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

/* SQL generated to create new application ${flyway:defaultSchema} */
INSERT INTO [${mjSchema}].[Application] (ID, Name, Description, SchemaAutoAddNewEntities, Path, AutoUpdatePath)
                       VALUES ('22541055-8ed4-4850-8acd-e5ee1887b15b', '${flyway:defaultSchema}', 'Generated for schema', '${flyway:defaultSchema}', 'mjbizappstasks', 1);

/* Adding role UI to application ${flyway:defaultSchema} */
INSERT INTO [${mjSchema}].[ApplicationRole]
                                 ([ApplicationID], [RoleID], [CanAccess], [CanAdmin]) VALUES
                                 ('22541055-8ed4-4850-8acd-e5ee1887b15b', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0);

/* Adding role Developer to application ${flyway:defaultSchema} */
INSERT INTO [${mjSchema}].[ApplicationRole]
                                 ([ApplicationID], [RoleID], [CanAccess], [CanAdmin]) VALUES
                                 ('22541055-8ed4-4850-8acd-e5ee1887b15b', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1);

/* Adding role Integration to application ${flyway:defaultSchema} */
INSERT INTO [${mjSchema}].[ApplicationRole]
                                 ([ApplicationID], [RoleID], [CanAccess], [CanAdmin]) VALUES
                                 ('22541055-8ed4-4850-8acd-e5ee1887b15b', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0);

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Roles to application ID: '22541055-8ed4-4850-8acd-e5ee1887b15b' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ed4-4850-8acd-e5ee1887b15b', '559054c2-8f03-4a66-b4fd-70de5948ace2', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ed4-4850-8acd-e5ee1887b15b'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Roles for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('559054c2-8f03-4a66-b4fd-70de5948ace2', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Roles for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('559054c2-8f03-4a66-b4fd-70de5948ace2', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Roles for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('559054c2-8f03-4a66-b4fd-70de5948ace2', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Assignments */

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
         'df98e700-1992-442b-b93e-e47379f2ca52',
         'MJ_BizApps_Tasks: Task Assignments',
         'Task Assignments',
         NULL,
         NULL,
         'TaskAssignment',
         'vwTaskAssignments',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Assignments to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'df98e700-1992-442b-b93e-e47379f2ca52', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Assignments for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('df98e700-1992-442b-b93e-e47379f2ca52', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Assignments for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('df98e700-1992-442b-b93e-e47379f2ca52', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Assignments for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('df98e700-1992-442b-b93e-e47379f2ca52', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Links */

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
         'b92e802c-5c1b-486d-b021-03e47069502c',
         'MJ_BizApps_Tasks: Task Links',
         'Task Links',
         NULL,
         NULL,
         'TaskLink',
         'vwTaskLinks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Links to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'b92e802c-5c1b-486d-b021-03e47069502c', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Links for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('b92e802c-5c1b-486d-b021-03e47069502c', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Links for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('b92e802c-5c1b-486d-b021-03e47069502c', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Links for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('b92e802c-5c1b-486d-b021-03e47069502c', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Dependencies */

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
         '0662fc0f-3f2b-49c9-9be8-5b59e036044a',
         'MJ_BizApps_Tasks: Task Dependencies',
         'Task Dependencies',
         NULL,
         NULL,
         'TaskDependency',
         'vwTaskDependencies',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Dependencies to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '0662fc0f-3f2b-49c9-9be8-5b59e036044a', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Dependencies for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('0662fc0f-3f2b-49c9-9be8-5b59e036044a', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Dependencies for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('0662fc0f-3f2b-49c9-9be8-5b59e036044a', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Dependencies for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('0662fc0f-3f2b-49c9-9be8-5b59e036044a', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Tags */

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
         '5db17493-cd0a-4633-80d4-d4a499662c76',
         'MJ_BizApps_Tasks: Task Tags',
         'Task Tags',
         NULL,
         NULL,
         'TaskTag',
         'vwTaskTags',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Tags to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '5db17493-cd0a-4633-80d4-d4a499662c76', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Tags for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('5db17493-cd0a-4633-80d4-d4a499662c76', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Tags for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('5db17493-cd0a-4633-80d4-d4a499662c76', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Tags for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('5db17493-cd0a-4633-80d4-d4a499662c76', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Tag Links */

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
         'ea953d6b-524e-4a09-a842-9a0b0f1f850c',
         'MJ_BizApps_Tasks: Task Tag Links',
         'Task Tag Links',
         NULL,
         NULL,
         'TaskTagLink',
         'vwTaskTagLinks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Tag Links to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'ea953d6b-524e-4a09-a842-9a0b0f1f850c', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Tag Links for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('ea953d6b-524e-4a09-a842-9a0b0f1f850c', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Tag Links for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('ea953d6b-524e-4a09-a842-9a0b0f1f850c', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Tag Links for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('ea953d6b-524e-4a09-a842-9a0b0f1f850c', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Comments */

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
         'b8b2c72f-44fb-4c6e-9e4f-d42aee1c1865',
         'MJ_BizApps_Tasks: Task Comments',
         'Task Comments',
         NULL,
         NULL,
         'TaskComment',
         'vwTaskComments',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Comments to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'b8b2c72f-44fb-4c6e-9e4f-d42aee1c1865', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Comments for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('b8b2c72f-44fb-4c6e-9e4f-d42aee1c1865', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Comments for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('b8b2c72f-44fb-4c6e-9e4f-d42aee1c1865', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Comments for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('b8b2c72f-44fb-4c6e-9e4f-d42aee1c1865', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Templates */

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
         '802aef11-bfe2-4b46-98b2-5febd4e35923',
         'MJ_BizApps_Tasks: Task Templates',
         'Task Templates',
         NULL,
         NULL,
         'TaskTemplate',
         'vwTaskTemplates',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Templates to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '802aef11-bfe2-4b46-98b2-5febd4e35923', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Templates for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('802aef11-bfe2-4b46-98b2-5febd4e35923', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Templates for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('802aef11-bfe2-4b46-98b2-5febd4e35923', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Templates for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('802aef11-bfe2-4b46-98b2-5febd4e35923', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Template Items */

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
         'a28fdd91-d380-427e-b374-bcec56ed75b7',
         'MJ_BizApps_Tasks: Task Template Items',
         'Task Template Items',
         NULL,
         NULL,
         'TaskTemplateItem',
         'vwTaskTemplateItems',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Template Items to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'a28fdd91-d380-427e-b374-bcec56ed75b7', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Items for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('a28fdd91-d380-427e-b374-bcec56ed75b7', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Items for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('a28fdd91-d380-427e-b374-bcec56ed75b7', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Items for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('a28fdd91-d380-427e-b374-bcec56ed75b7', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Template Item Dependencies */

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
         '8a30f14c-26ff-476e-8ca1-b10ead29a428',
         'MJ_BizApps_Tasks: Task Template Item Dependencies',
         'Task Template Item Dependencies',
         NULL,
         NULL,
         'TaskTemplateItemDependency',
         'vwTaskTemplateItemDependencies',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Template Item Dependencies to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '8a30f14c-26ff-476e-8ca1-b10ead29a428', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Item Dependencies for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('8a30f14c-26ff-476e-8ca1-b10ead29a428', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Item Dependencies for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('8a30f14c-26ff-476e-8ca1-b10ead29a428', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Item Dependencies for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('8a30f14c-26ff-476e-8ca1-b10ead29a428', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Template Item Roles */

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
         'abfcfe68-f3aa-4401-a547-0fc01f27e3f3',
         'MJ_BizApps_Tasks: Task Template Item Roles',
         'Task Template Item Roles',
         NULL,
         NULL,
         'TaskTemplateItemRole',
         'vwTaskTemplateItemRoles',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Template Item Roles to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'abfcfe68-f3aa-4401-a547-0fc01f27e3f3', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Item Roles for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('abfcfe68-f3aa-4401-a547-0fc01f27e3f3', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Item Roles for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('abfcfe68-f3aa-4401-a547-0fc01f27e3f3', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Item Roles for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('abfcfe68-f3aa-4401-a547-0fc01f27e3f3', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Activities */

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
         '6615ef77-83f1-49f1-b717-80ec31f77486',
         'MJ_BizApps_Tasks: Task Activities',
         'Task Activities',
         NULL,
         NULL,
         'TaskActivity',
         'vwTaskActivities',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Activities to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '6615ef77-83f1-49f1-b717-80ec31f77486', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Activities for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('6615ef77-83f1-49f1-b717-80ec31f77486', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Activities for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('6615ef77-83f1-49f1-b717-80ec31f77486', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Activities for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('6615ef77-83f1-49f1-b717-80ec31f77486', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Notification Configs */

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
         'a210af26-629a-4e0a-a90a-1cce33f5d095',
         'MJ_BizApps_Tasks: Task Notification Configs',
         'Task Notification Configs',
         NULL,
         NULL,
         'TaskNotificationConfig',
         'vwTaskNotificationConfigs',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Notification Configs to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'a210af26-629a-4e0a-a90a-1cce33f5d095', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Notification Configs for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('a210af26-629a-4e0a-a90a-1cce33f5d095', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Notification Configs for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('a210af26-629a-4e0a-a90a-1cce33f5d095', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Notification Configs for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('a210af26-629a-4e0a-a90a-1cce33f5d095', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Notification Logs */

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
         'dd0c62ed-7960-4d0a-a1fc-c0e0754de1d4',
         'MJ_BizApps_Tasks: Task Notification Logs',
         'Task Notification Logs',
         NULL,
         NULL,
         'TaskNotificationLog',
         'vwTaskNotificationLogs',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Notification Logs to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'dd0c62ed-7960-4d0a-a1fc-c0e0754de1d4', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Notification Logs for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('dd0c62ed-7960-4d0a-a1fc-c0e0754de1d4', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Notification Logs for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('dd0c62ed-7960-4d0a-a1fc-c0e0754de1d4', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Notification Logs for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('dd0c62ed-7960-4d0a-a1fc-c0e0754de1d4', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Types */

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
         '1e30141a-826f-4278-baa9-bbe14d29e606',
         'MJ_BizApps_Tasks: Task Types',
         'Task Types',
         NULL,
         NULL,
         'TaskType',
         'vwTaskTypes',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Types to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '1e30141a-826f-4278-baa9-bbe14d29e606', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Types for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('1e30141a-826f-4278-baa9-bbe14d29e606', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Types for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('1e30141a-826f-4278-baa9-bbe14d29e606', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Types for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('1e30141a-826f-4278-baa9-bbe14d29e606', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Categories */

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
         '06303fa3-48f0-45b7-bc6a-f3ebdfee5cb6',
         'MJ_BizApps_Tasks: Task Categories',
         'Task Categories',
         NULL,
         NULL,
         'TaskCategory',
         'vwTaskCategories',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Categories to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '06303fa3-48f0-45b7-bc6a-f3ebdfee5cb6', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Categories for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('06303fa3-48f0-45b7-bc6a-f3ebdfee5cb6', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Categories for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('06303fa3-48f0-45b7-bc6a-f3ebdfee5cb6', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Categories for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('06303fa3-48f0-45b7-bc6a-f3ebdfee5cb6', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity MJ_BizApps_Tasks: Tasks */

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
         'b348ffa2-b1a7-4ac2-b6fd-f4e0c0697466',
         'MJ_BizApps_Tasks: Tasks',
         'Tasks',
         NULL,
         NULL,
         'Task',
         'vwTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Tasks to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'b348ffa2-b1a7-4ac2-b6fd-f4e0c0697466', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Tasks for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('b348ffa2-b1a7-4ac2-b6fd-f4e0c0697466', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Tasks for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('b348ffa2-b1a7-4ac2-b6fd-f4e0c0697466', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Tasks for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('b348ffa2-b1a7-4ac2-b6fd-f4e0c0697466', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL text to update existing entities from schema */
EXEC [${mjSchema}].[spUpdateExistingEntitiesFromSchema] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon';

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskLink] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskLink */
UPDATE [${flyway:defaultSchema}].[TaskLink] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskLink] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskLink] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskLink___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskLink] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskLink */
UPDATE [${flyway:defaultSchema}].[TaskLink] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskLink] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskLink] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskLink___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemRole */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItemRole] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemRole */
UPDATE [${flyway:defaultSchema}].[TaskTemplateItemRole] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemRole */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItemRole] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemRole */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItemRole] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTemplateItemRole___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemRole */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItemRole] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemRole */
UPDATE [${flyway:defaultSchema}].[TaskTemplateItemRole] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemRole */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItemRole] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemRole */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItemRole] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTemplateItemRole___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskNotificationConfig */
ALTER TABLE [${flyway:defaultSchema}].[TaskNotificationConfig] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskNotificationConfig */
UPDATE [${flyway:defaultSchema}].[TaskNotificationConfig] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskNotificationConfig */
ALTER TABLE [${flyway:defaultSchema}].[TaskNotificationConfig] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskNotificationConfig */
ALTER TABLE [${flyway:defaultSchema}].[TaskNotificationConfig] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskNotificationConfig___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskNotificationConfig */
ALTER TABLE [${flyway:defaultSchema}].[TaskNotificationConfig] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskNotificationConfig */
UPDATE [${flyway:defaultSchema}].[TaskNotificationConfig] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskNotificationConfig */
ALTER TABLE [${flyway:defaultSchema}].[TaskNotificationConfig] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskNotificationConfig */
ALTER TABLE [${flyway:defaultSchema}].[TaskNotificationConfig] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskNotificationConfig___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskDependency */
ALTER TABLE [${flyway:defaultSchema}].[TaskDependency] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskDependency */
UPDATE [${flyway:defaultSchema}].[TaskDependency] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskDependency */
ALTER TABLE [${flyway:defaultSchema}].[TaskDependency] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskDependency */
ALTER TABLE [${flyway:defaultSchema}].[TaskDependency] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskDependency___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskDependency */
ALTER TABLE [${flyway:defaultSchema}].[TaskDependency] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskDependency */
UPDATE [${flyway:defaultSchema}].[TaskDependency] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskDependency */
ALTER TABLE [${flyway:defaultSchema}].[TaskDependency] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskDependency */
ALTER TABLE [${flyway:defaultSchema}].[TaskDependency] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskDependency___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplate */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplate] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplate */
UPDATE [${flyway:defaultSchema}].[TaskTemplate] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplate */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplate] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplate */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplate] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTemplate___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplate */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplate] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplate */
UPDATE [${flyway:defaultSchema}].[TaskTemplate] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplate */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplate] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplate */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplate] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTemplate___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskRole */
ALTER TABLE [${flyway:defaultSchema}].[TaskRole] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskRole */
UPDATE [${flyway:defaultSchema}].[TaskRole] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskRole */
ALTER TABLE [${flyway:defaultSchema}].[TaskRole] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskRole */
ALTER TABLE [${flyway:defaultSchema}].[TaskRole] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskRole___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskRole */
ALTER TABLE [${flyway:defaultSchema}].[TaskRole] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskRole */
UPDATE [${flyway:defaultSchema}].[TaskRole] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskRole */
ALTER TABLE [${flyway:defaultSchema}].[TaskRole] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskRole */
ALTER TABLE [${flyway:defaultSchema}].[TaskRole] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskRole___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskActivity */
ALTER TABLE [${flyway:defaultSchema}].[TaskActivity] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskActivity */
UPDATE [${flyway:defaultSchema}].[TaskActivity] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskActivity */
ALTER TABLE [${flyway:defaultSchema}].[TaskActivity] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskActivity */
ALTER TABLE [${flyway:defaultSchema}].[TaskActivity] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskActivity___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskActivity */
ALTER TABLE [${flyway:defaultSchema}].[TaskActivity] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskActivity */
UPDATE [${flyway:defaultSchema}].[TaskActivity] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskActivity */
ALTER TABLE [${flyway:defaultSchema}].[TaskActivity] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskActivity */
ALTER TABLE [${flyway:defaultSchema}].[TaskActivity] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskActivity___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTagLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskTagLink] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTagLink */
UPDATE [${flyway:defaultSchema}].[TaskTagLink] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTagLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskTagLink] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTagLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskTagLink] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTagLink___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTagLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskTagLink] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTagLink */
UPDATE [${flyway:defaultSchema}].[TaskTagLink] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTagLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskTagLink] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTagLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskTagLink] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTagLink___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemDependency */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItemDependency] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemDependency */
UPDATE [${flyway:defaultSchema}].[TaskTemplateItemDependency] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemDependency */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItemDependency] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemDependency */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItemDependency] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTemplateItemDependency___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemDependency */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItemDependency] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemDependency */
UPDATE [${flyway:defaultSchema}].[TaskTemplateItemDependency] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemDependency */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItemDependency] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplateItemDependency */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItemDependency] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTemplateItemDependency___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskType */
ALTER TABLE [${flyway:defaultSchema}].[TaskType] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskType */
UPDATE [${flyway:defaultSchema}].[TaskType] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskType */
ALTER TABLE [${flyway:defaultSchema}].[TaskType] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskType */
ALTER TABLE [${flyway:defaultSchema}].[TaskType] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskType___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskType */
ALTER TABLE [${flyway:defaultSchema}].[TaskType] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskType */
UPDATE [${flyway:defaultSchema}].[TaskType] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskType */
ALTER TABLE [${flyway:defaultSchema}].[TaskType] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskType */
ALTER TABLE [${flyway:defaultSchema}].[TaskType] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskType___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplateItem */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItem] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplateItem */
UPDATE [${flyway:defaultSchema}].[TaskTemplateItem] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplateItem */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItem] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTemplateItem */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItem] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTemplateItem___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplateItem */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItem] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplateItem */
UPDATE [${flyway:defaultSchema}].[TaskTemplateItem] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplateItem */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItem] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTemplateItem */
ALTER TABLE [${flyway:defaultSchema}].[TaskTemplateItem] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTemplateItem___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskNotificationLog */
ALTER TABLE [${flyway:defaultSchema}].[TaskNotificationLog] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskNotificationLog */
UPDATE [${flyway:defaultSchema}].[TaskNotificationLog] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskNotificationLog */
ALTER TABLE [${flyway:defaultSchema}].[TaskNotificationLog] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskNotificationLog */
ALTER TABLE [${flyway:defaultSchema}].[TaskNotificationLog] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskNotificationLog___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskNotificationLog */
ALTER TABLE [${flyway:defaultSchema}].[TaskNotificationLog] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskNotificationLog */
UPDATE [${flyway:defaultSchema}].[TaskNotificationLog] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskNotificationLog */
ALTER TABLE [${flyway:defaultSchema}].[TaskNotificationLog] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskNotificationLog */
ALTER TABLE [${flyway:defaultSchema}].[TaskNotificationLog] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskNotificationLog___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskComment */
ALTER TABLE [${flyway:defaultSchema}].[TaskComment] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskComment */
UPDATE [${flyway:defaultSchema}].[TaskComment] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskComment */
ALTER TABLE [${flyway:defaultSchema}].[TaskComment] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskComment */
ALTER TABLE [${flyway:defaultSchema}].[TaskComment] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskComment___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskComment */
ALTER TABLE [${flyway:defaultSchema}].[TaskComment] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskComment */
UPDATE [${flyway:defaultSchema}].[TaskComment] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskComment */
ALTER TABLE [${flyway:defaultSchema}].[TaskComment] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskComment */
ALTER TABLE [${flyway:defaultSchema}].[TaskComment] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskComment___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTag */
ALTER TABLE [${flyway:defaultSchema}].[TaskTag] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTag */
UPDATE [${flyway:defaultSchema}].[TaskTag] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTag */
ALTER TABLE [${flyway:defaultSchema}].[TaskTag] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTag */
ALTER TABLE [${flyway:defaultSchema}].[TaskTag] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTag___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTag */
ALTER TABLE [${flyway:defaultSchema}].[TaskTag] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTag */
UPDATE [${flyway:defaultSchema}].[TaskTag] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTag */
ALTER TABLE [${flyway:defaultSchema}].[TaskTag] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTag */
ALTER TABLE [${flyway:defaultSchema}].[TaskTag] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTag___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskAssignment */
ALTER TABLE [${flyway:defaultSchema}].[TaskAssignment] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskAssignment */
UPDATE [${flyway:defaultSchema}].[TaskAssignment] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskAssignment */
ALTER TABLE [${flyway:defaultSchema}].[TaskAssignment] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskAssignment */
ALTER TABLE [${flyway:defaultSchema}].[TaskAssignment] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskAssignment___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskAssignment */
ALTER TABLE [${flyway:defaultSchema}].[TaskAssignment] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskAssignment */
UPDATE [${flyway:defaultSchema}].[TaskAssignment] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskAssignment */
ALTER TABLE [${flyway:defaultSchema}].[TaskAssignment] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskAssignment */
ALTER TABLE [${flyway:defaultSchema}].[TaskAssignment] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskAssignment___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskCategory */
ALTER TABLE [${flyway:defaultSchema}].[TaskCategory] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskCategory */
UPDATE [${flyway:defaultSchema}].[TaskCategory] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskCategory */
ALTER TABLE [${flyway:defaultSchema}].[TaskCategory] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskCategory */
ALTER TABLE [${flyway:defaultSchema}].[TaskCategory] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskCategory___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskCategory */
ALTER TABLE [${flyway:defaultSchema}].[TaskCategory] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskCategory */
UPDATE [${flyway:defaultSchema}].[TaskCategory] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskCategory */
ALTER TABLE [${flyway:defaultSchema}].[TaskCategory] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskCategory */
ALTER TABLE [${flyway:defaultSchema}].[TaskCategory] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskCategory___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.Task */
ALTER TABLE [${flyway:defaultSchema}].[Task] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.Task */
UPDATE [${flyway:defaultSchema}].[Task] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.Task */
ALTER TABLE [${flyway:defaultSchema}].[Task] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.Task */
ALTER TABLE [${flyway:defaultSchema}].[Task] ADD CONSTRAINT [DF___mj_BizAppsTasks_Task___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.Task */
ALTER TABLE [${flyway:defaultSchema}].[Task] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.Task */
UPDATE [${flyway:defaultSchema}].[Task] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.Task */
ALTER TABLE [${flyway:defaultSchema}].[Task] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.Task */
ALTER TABLE [${flyway:defaultSchema}].[Task] ADD CONSTRAINT [DF___mj_BizAppsTasks_Task___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '99b41590-910a-448b-ad24-1e0f5585da26' OR (EntityID = 'B92E802C-5C1B-486D-B021-03E47069502C' AND Name = 'ID')) BEGIN
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
            '99b41590-910a-448b-ad24-1e0f5585da26',
            'B92E802C-5C1B-486D-B021-03E47069502C', -- Entity: MJ_BizApps_Tasks: Task Links
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c6e39edf-d1b0-4571-9a35-22a4d7fd595e' OR (EntityID = 'B92E802C-5C1B-486D-B021-03E47069502C' AND Name = 'TaskID')) BEGIN
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
            'c6e39edf-d1b0-4571-9a35-22a4d7fd595e',
            'B92E802C-5C1B-486D-B021-03E47069502C', -- Entity: MJ_BizApps_Tasks: Task Links
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
            0,
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2dee15ab-8820-448f-b3ce-ae79a8b82b6f' OR (EntityID = 'B92E802C-5C1B-486D-B021-03E47069502C' AND Name = 'EntityID')) BEGIN
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
            '2dee15ab-8820-448f-b3ce-ae79a8b82b6f',
            'B92E802C-5C1B-486D-B021-03E47069502C', -- Entity: MJ_BizApps_Tasks: Task Links
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
      END;

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '820857f0-cb09-4ebe-ac47-145b55f61814' OR (EntityID = 'B92E802C-5C1B-486D-B021-03E47069502C' AND Name = 'RecordID')) BEGIN
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
            '820857f0-cb09-4ebe-ac47-145b55f61814',
            'B92E802C-5C1B-486D-B021-03E47069502C', -- Entity: MJ_BizApps_Tasks: Task Links
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4a24d901-943f-44f6-9476-d86bc1d65c01' OR (EntityID = 'B92E802C-5C1B-486D-B021-03E47069502C' AND Name = 'Description')) BEGIN
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
            '4a24d901-943f-44f6-9476-d86bc1d65c01',
            'B92E802C-5C1B-486D-B021-03E47069502C', -- Entity: MJ_BizApps_Tasks: Task Links
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '07c7da46-0821-4bf1-a3af-007dc980c481' OR (EntityID = 'B92E802C-5C1B-486D-B021-03E47069502C' AND Name = '__mj_CreatedAt')) BEGIN
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
            '07c7da46-0821-4bf1-a3af-007dc980c481',
            'B92E802C-5C1B-486D-B021-03E47069502C', -- Entity: MJ_BizApps_Tasks: Task Links
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '98aeae08-c9ec-4136-819a-7919625f4bba' OR (EntityID = 'B92E802C-5C1B-486D-B021-03E47069502C' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '98aeae08-c9ec-4136-819a-7919625f4bba',
            'B92E802C-5C1B-486D-B021-03E47069502C', -- Entity: MJ_BizApps_Tasks: Task Links
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '36aa7f8f-44bf-4d37-a1c7-e446d7e95094' OR (EntityID = 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3' AND Name = 'ID')) BEGIN
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
            '36aa7f8f-44bf-4d37-a1c7-e446d7e95094',
            'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', -- Entity: MJ_BizApps_Tasks: Task Template Item Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '64a2358a-484a-4c2a-989b-2687daa39fad' OR (EntityID = 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3' AND Name = 'ItemID')) BEGIN
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
            '64a2358a-484a-4c2a-989b-2687daa39fad',
            'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', -- Entity: MJ_BizApps_Tasks: Task Template Item Roles
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
            0,
            'A28FDD91-D380-427E-B374-BCEC56ED75B7',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fc504621-f102-43fa-b6af-820e0fd0c366' OR (EntityID = 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3' AND Name = 'RoleID')) BEGIN
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
            'fc504621-f102-43fa-b6af-820e0fd0c366',
            'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', -- Entity: MJ_BizApps_Tasks: Task Template Item Roles
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
            0,
            '559054C2-8F03-4A66-B4FD-70DE5948ACE2',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'accdd736-3097-4d1b-beab-9348e293caee' OR (EntityID = 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3' AND Name = '__mj_CreatedAt')) BEGIN
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
            'accdd736-3097-4d1b-beab-9348e293caee',
            'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', -- Entity: MJ_BizApps_Tasks: Task Template Item Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '997bf65f-dc1a-43a7-80c1-1dc1548e76dc' OR (EntityID = 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '997bf65f-dc1a-43a7-80c1-1dc1548e76dc',
            'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', -- Entity: MJ_BizApps_Tasks: Task Template Item Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9a5d15d2-bf9c-4566-9cb3-127c036a2297' OR (EntityID = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND Name = 'ID')) BEGIN
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
            '9a5d15d2-bf9c-4566-9cb3-127c036a2297',
            'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- Entity: MJ_BizApps_Tasks: Task Notification Configs
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3a3dc1ee-3b5d-4ecb-9e63-fb061c37951f' OR (EntityID = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND Name = 'TaskTypeID')) BEGIN
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
            '3a3dc1ee-3b5d-4ecb-9e63-fb061c37951f',
            'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- Entity: MJ_BizApps_Tasks: Task Notification Configs
            100002,
            'TaskTypeID',
            'Task Type ID',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8e391113-9ab6-47c7-8942-29d0f50feb3b' OR (EntityID = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND Name = 'OverdueNotificationsEnabled')) BEGIN
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
            '8e391113-9ab6-47c7-8942-29d0f50feb3b',
            'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- Entity: MJ_BizApps_Tasks: Task Notification Configs
            100003,
            'OverdueNotificationsEnabled',
            'Overdue Notifications Enabled',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a2b0dc2d-3097-4e98-9aa8-6ebbedbe84c3' OR (EntityID = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND Name = 'OverdueGracePeriodHours')) BEGIN
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
            'a2b0dc2d-3097-4e98-9aa8-6ebbedbe84c3',
            'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- Entity: MJ_BizApps_Tasks: Task Notification Configs
            100004,
            'OverdueGracePeriodHours',
            'Overdue Grace Period Hours',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ac16d98b-855e-44a7-adb3-fbc3dc9e055e' OR (EntityID = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND Name = 'OverdueRepeatIntervalHours')) BEGIN
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
            'ac16d98b-855e-44a7-adb3-fbc3dc9e055e',
            'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- Entity: MJ_BizApps_Tasks: Task Notification Configs
            100005,
            'OverdueRepeatIntervalHours',
            'Overdue Repeat Interval Hours',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a48474ec-3009-4c5b-aee6-e79b58089a2a' OR (EntityID = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND Name = 'NotifyAssignees')) BEGIN
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
            'a48474ec-3009-4c5b-aee6-e79b58089a2a',
            'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- Entity: MJ_BizApps_Tasks: Task Notification Configs
            100006,
            'NotifyAssignees',
            'Notify Assignees',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fc7e46c0-0d22-4c5d-b4c3-261829abd120' OR (EntityID = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND Name = 'NotifyCreator')) BEGIN
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
            'fc7e46c0-0d22-4c5d-b4c3-261829abd120',
            'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- Entity: MJ_BizApps_Tasks: Task Notification Configs
            100007,
            'NotifyCreator',
            'Notify Creator',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '62e69520-b969-41da-88e0-58ec3afa0783' OR (EntityID = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND Name = 'OverdueActionID')) BEGIN
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
            '62e69520-b969-41da-88e0-58ec3afa0783',
            'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- Entity: MJ_BizApps_Tasks: Task Notification Configs
            100008,
            'OverdueActionID',
            'Overdue Action ID',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'dd3728e2-e5c6-42a8-92d6-e71fe878dbc0' OR (EntityID = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND Name = '__mj_CreatedAt')) BEGIN
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
            'dd3728e2-e5c6-42a8-92d6-e71fe878dbc0',
            'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- Entity: MJ_BizApps_Tasks: Task Notification Configs
            100009,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'bb8f8616-03dc-46f6-adb9-7d9e7be99b16' OR (EntityID = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'bb8f8616-03dc-46f6-adb9-7d9e7be99b16',
            'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- Entity: MJ_BizApps_Tasks: Task Notification Configs
            100010,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6c4a40da-0866-4ca0-9f7d-12ec6064aef1' OR (EntityID = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND Name = 'ID')) BEGIN
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
            '6c4a40da-0866-4ca0-9f7d-12ec6064aef1',
            '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- Entity: MJ_BizApps_Tasks: Task Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9ccc0485-5b84-4120-9e9b-4d1a89999973' OR (EntityID = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND Name = 'TaskID')) BEGIN
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
            '9ccc0485-5b84-4120-9e9b-4d1a89999973',
            '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- Entity: MJ_BizApps_Tasks: Task Dependencies
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
            0,
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0704ad59-838f-49d6-9891-c5930c890258' OR (EntityID = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND Name = 'DependsOnTaskID')) BEGIN
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
            '0704ad59-838f-49d6-9891-c5930c890258',
            '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- Entity: MJ_BizApps_Tasks: Task Dependencies
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
            0,
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2dd6db6e-82f2-439d-a15f-81bbe36286df' OR (EntityID = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND Name = 'DependencyType')) BEGIN
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
            '2dd6db6e-82f2-439d-a15f-81bbe36286df',
            '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- Entity: MJ_BizApps_Tasks: Task Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0ab7cb59-83f6-4fd4-a8c8-38ecac388bce' OR (EntityID = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND Name = '__mj_CreatedAt')) BEGIN
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
            '0ab7cb59-83f6-4fd4-a8c8-38ecac388bce',
            '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- Entity: MJ_BizApps_Tasks: Task Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5b121d65-da07-4ea6-a988-31b38d23b528' OR (EntityID = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '5b121d65-da07-4ea6-a988-31b38d23b528',
            '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- Entity: MJ_BizApps_Tasks: Task Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '94fceabf-a622-4502-820a-9e1f1533567d' OR (EntityID = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND Name = 'ID')) BEGIN
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
            '94fceabf-a622-4502-820a-9e1f1533567d',
            '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- Entity: MJ_BizApps_Tasks: Task Templates
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1b80a51f-be02-411f-b960-63ea442c9172' OR (EntityID = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND Name = 'Name')) BEGIN
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
            '1b80a51f-be02-411f-b960-63ea442c9172',
            '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- Entity: MJ_BizApps_Tasks: Task Templates
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
      END;

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '83b87f55-e9e5-4ed9-a561-5cc2a77a22ed' OR (EntityID = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND Name = 'Description')) BEGIN
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
            '83b87f55-e9e5-4ed9-a561-5cc2a77a22ed',
            '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- Entity: MJ_BizApps_Tasks: Task Templates
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9b39d77b-acec-40f7-b933-456760238d14' OR (EntityID = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND Name = 'CategoryID')) BEGIN
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
            '9b39d77b-acec-40f7-b933-456760238d14',
            '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- Entity: MJ_BizApps_Tasks: Task Templates
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
            0,
            '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f3908c0c-6c75-4a8d-8c7f-38c9535bffc2' OR (EntityID = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND Name = 'TypeID')) BEGIN
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
            'f3908c0c-6c75-4a8d-8c7f-38c9535bffc2',
            '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- Entity: MJ_BizApps_Tasks: Task Templates
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
            0,
            '1E30141A-826F-4278-BAA9-BBE14D29E606',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'cb57cbf3-7b0e-4887-a963-a8137cde2ecc' OR (EntityID = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND Name = 'IsActive')) BEGIN
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
            'cb57cbf3-7b0e-4887-a963-a8137cde2ecc',
            '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- Entity: MJ_BizApps_Tasks: Task Templates
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f8ec6d02-e1c2-433f-a96d-9095eaac35c3' OR (EntityID = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND Name = '__mj_CreatedAt')) BEGIN
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
            'f8ec6d02-e1c2-433f-a96d-9095eaac35c3',
            '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- Entity: MJ_BizApps_Tasks: Task Templates
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a772e9ac-7673-49f4-99cd-38d4a5b14f30' OR (EntityID = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'a772e9ac-7673-49f4-99cd-38d4a5b14f30',
            '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- Entity: MJ_BizApps_Tasks: Task Templates
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '39289af3-6bb0-4697-981b-8f39c47feed1' OR (EntityID = '559054C2-8F03-4A66-B4FD-70DE5948ACE2' AND Name = 'ID')) BEGIN
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
            '39289af3-6bb0-4697-981b-8f39c47feed1',
            '559054C2-8F03-4A66-B4FD-70DE5948ACE2', -- Entity: MJ_BizApps_Tasks: Task Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '23a93766-7d80-4b7c-bc0b-ef716e8e97aa' OR (EntityID = '559054C2-8F03-4A66-B4FD-70DE5948ACE2' AND Name = 'Name')) BEGIN
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
            '23a93766-7d80-4b7c-bc0b-ef716e8e97aa',
            '559054C2-8F03-4A66-B4FD-70DE5948ACE2', -- Entity: MJ_BizApps_Tasks: Task Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '604eaaa7-7911-48d9-8ac4-079affa9f901' OR (EntityID = '559054C2-8F03-4A66-B4FD-70DE5948ACE2' AND Name = 'Description')) BEGIN
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
            '604eaaa7-7911-48d9-8ac4-079affa9f901',
            '559054C2-8F03-4A66-B4FD-70DE5948ACE2', -- Entity: MJ_BizApps_Tasks: Task Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '896f23e5-bd84-4cd9-86ae-cf527c34e772' OR (EntityID = '559054C2-8F03-4A66-B4FD-70DE5948ACE2' AND Name = 'Sequence')) BEGIN
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
            '896f23e5-bd84-4cd9-86ae-cf527c34e772',
            '559054C2-8F03-4A66-B4FD-70DE5948ACE2', -- Entity: MJ_BizApps_Tasks: Task Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f5cbafd5-b5a2-4bc5-9f6a-a932d86a75fb' OR (EntityID = '559054C2-8F03-4A66-B4FD-70DE5948ACE2' AND Name = '__mj_CreatedAt')) BEGIN
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
            'f5cbafd5-b5a2-4bc5-9f6a-a932d86a75fb',
            '559054C2-8F03-4A66-B4FD-70DE5948ACE2', -- Entity: MJ_BizApps_Tasks: Task Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '45ab032f-dbe5-4191-9635-f20bf7d9c7ef' OR (EntityID = '559054C2-8F03-4A66-B4FD-70DE5948ACE2' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '45ab032f-dbe5-4191-9635-f20bf7d9c7ef',
            '559054C2-8F03-4A66-B4FD-70DE5948ACE2', -- Entity: MJ_BizApps_Tasks: Task Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e5f115d0-a541-463b-87d1-224fb396e4cf' OR (EntityID = '6615EF77-83F1-49F1-B717-80EC31F77486' AND Name = 'ID')) BEGIN
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
            'e5f115d0-a541-463b-87d1-224fb396e4cf',
            '6615EF77-83F1-49F1-B717-80EC31F77486', -- Entity: MJ_BizApps_Tasks: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4e49c2fd-9527-484d-97ed-2afe4ee0e3e6' OR (EntityID = '6615EF77-83F1-49F1-B717-80EC31F77486' AND Name = 'TaskID')) BEGIN
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
            '4e49c2fd-9527-484d-97ed-2afe4ee0e3e6',
            '6615EF77-83F1-49F1-B717-80EC31F77486', -- Entity: MJ_BizApps_Tasks: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c885176b-bccd-4d0a-bdfc-b624394404b4' OR (EntityID = '6615EF77-83F1-49F1-B717-80EC31F77486' AND Name = 'PersonID')) BEGIN
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
            'c885176b-bccd-4d0a-bdfc-b624394404b4',
            '6615EF77-83F1-49F1-B717-80EC31F77486', -- Entity: MJ_BizApps_Tasks: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7b955fc4-a91e-4cc7-8768-e6945a895df9' OR (EntityID = '6615EF77-83F1-49F1-B717-80EC31F77486' AND Name = 'ActivityType')) BEGIN
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
            '7b955fc4-a91e-4cc7-8768-e6945a895df9',
            '6615EF77-83F1-49F1-B717-80EC31F77486', -- Entity: MJ_BizApps_Tasks: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '58a3f43c-3f2c-48ee-867a-8ef9f243bb63' OR (EntityID = '6615EF77-83F1-49F1-B717-80EC31F77486' AND Name = 'PreviousValue')) BEGIN
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
            '58a3f43c-3f2c-48ee-867a-8ef9f243bb63',
            '6615EF77-83F1-49F1-B717-80EC31F77486', -- Entity: MJ_BizApps_Tasks: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ee81848c-d188-4c1d-95cc-3b618fabf1ec' OR (EntityID = '6615EF77-83F1-49F1-B717-80EC31F77486' AND Name = 'NewValue')) BEGIN
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
            'ee81848c-d188-4c1d-95cc-3b618fabf1ec',
            '6615EF77-83F1-49F1-B717-80EC31F77486', -- Entity: MJ_BizApps_Tasks: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8d1c4682-5e91-4512-9f3c-e6e87ef6f303' OR (EntityID = '6615EF77-83F1-49F1-B717-80EC31F77486' AND Name = 'Description')) BEGIN
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
            '8d1c4682-5e91-4512-9f3c-e6e87ef6f303',
            '6615EF77-83F1-49F1-B717-80EC31F77486', -- Entity: MJ_BizApps_Tasks: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a9f7291b-c6b9-4832-8cad-154a7fc34071' OR (EntityID = '6615EF77-83F1-49F1-B717-80EC31F77486' AND Name = '__mj_CreatedAt')) BEGIN
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
            'a9f7291b-c6b9-4832-8cad-154a7fc34071',
            '6615EF77-83F1-49F1-B717-80EC31F77486', -- Entity: MJ_BizApps_Tasks: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e8f50401-7746-40c1-a4f9-2d21e486d611' OR (EntityID = '6615EF77-83F1-49F1-B717-80EC31F77486' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'e8f50401-7746-40c1-a4f9-2d21e486d611',
            '6615EF77-83F1-49F1-B717-80EC31F77486', -- Entity: MJ_BizApps_Tasks: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b0210863-91b0-4b0b-a277-f5b2f85fac80' OR (EntityID = 'EA953D6B-524E-4A09-A842-9A0B0F1F850C' AND Name = 'ID')) BEGIN
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
            'b0210863-91b0-4b0b-a277-f5b2f85fac80',
            'EA953D6B-524E-4A09-A842-9A0B0F1F850C', -- Entity: MJ_BizApps_Tasks: Task Tag Links
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '34a075ff-ea19-4045-89bb-8fe767ecdbf6' OR (EntityID = 'EA953D6B-524E-4A09-A842-9A0B0F1F850C' AND Name = 'TaskID')) BEGIN
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
            '34a075ff-ea19-4045-89bb-8fe767ecdbf6',
            'EA953D6B-524E-4A09-A842-9A0B0F1F850C', -- Entity: MJ_BizApps_Tasks: Task Tag Links
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
            0,
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e2740c12-01c0-4f86-ada4-f0cea1180dac' OR (EntityID = 'EA953D6B-524E-4A09-A842-9A0B0F1F850C' AND Name = 'TagID')) BEGIN
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
            'e2740c12-01c0-4f86-ada4-f0cea1180dac',
            'EA953D6B-524E-4A09-A842-9A0B0F1F850C', -- Entity: MJ_BizApps_Tasks: Task Tag Links
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
            0,
            '5DB17493-CD0A-4633-80D4-D4A499662C76',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7f95d5bb-dd93-4ce0-aed7-efc073c716e0' OR (EntityID = 'EA953D6B-524E-4A09-A842-9A0B0F1F850C' AND Name = '__mj_CreatedAt')) BEGIN
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
            '7f95d5bb-dd93-4ce0-aed7-efc073c716e0',
            'EA953D6B-524E-4A09-A842-9A0B0F1F850C', -- Entity: MJ_BizApps_Tasks: Task Tag Links
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0a81c770-5ca1-43f2-8db0-285000a6ea96' OR (EntityID = 'EA953D6B-524E-4A09-A842-9A0B0F1F850C' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '0a81c770-5ca1-43f2-8db0-285000a6ea96',
            'EA953D6B-524E-4A09-A842-9A0B0F1F850C', -- Entity: MJ_BizApps_Tasks: Task Tag Links
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6fac4bfe-77ae-4f46-902b-467acffdc4f5' OR (EntityID = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND Name = 'ID')) BEGIN
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
            '6fac4bfe-77ae-4f46-902b-467acffdc4f5',
            '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '910121c9-19bf-4a58-b76a-491cce751333' OR (EntityID = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND Name = 'ItemID')) BEGIN
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
            '910121c9-19bf-4a58-b76a-491cce751333',
            '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
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
            0,
            'A28FDD91-D380-427E-B374-BCEC56ED75B7',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f3ec22f4-d9cd-4c05-a31d-84efdc3d30de' OR (EntityID = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND Name = 'DependsOnItemID')) BEGIN
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
            'f3ec22f4-d9cd-4c05-a31d-84efdc3d30de',
            '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
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
            0,
            'A28FDD91-D380-427E-B374-BCEC56ED75B7',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '659f9a5c-bd9c-4ef7-88be-b731541d2345' OR (EntityID = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND Name = 'DependencyType')) BEGIN
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
            '659f9a5c-bd9c-4ef7-88be-b731541d2345',
            '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0e9937e4-7665-409f-bdb1-9d048f24f518' OR (EntityID = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND Name = '__mj_CreatedAt')) BEGIN
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
            '0e9937e4-7665-409f-bdb1-9d048f24f518',
            '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9eea87de-003e-4834-ae9b-07f26f79d8a8' OR (EntityID = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '9eea87de-003e-4834-ae9b-07f26f79d8a8',
            '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b5d4a231-3f9f-45f8-b1e5-3b0fccabfe8b' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'ID')) BEGIN
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
            'b5d4a231-3f9f-45f8-b1e5-3b0fccabfe8b',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '00619351-6557-42b0-b412-1fc4283cb682' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'Name')) BEGIN
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
            '00619351-6557-42b0-b412-1fc4283cb682',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '231b2378-3454-4a1e-a002-412fd7c8ad75' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'Description')) BEGIN
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
            '231b2378-3454-4a1e-a002-412fd7c8ad75',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '756bd750-22b9-40af-b38a-c59a7b93fffe' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'IconClass')) BEGIN
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
            '756bd750-22b9-40af-b38a-c59a7b93fffe',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '55d2a288-00c8-425f-8e69-06bced11d706' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'DefaultPriority')) BEGIN
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
            '55d2a288-00c8-425f-8e69-06bced11d706',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2352e1f5-18ca-4495-85da-516fefc20463' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnAssignActionID')) BEGIN
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
            '2352e1f5-18ca-4495-85da-516fefc20463',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '31f3f7cc-c0d0-4dd9-84f1-255bdb54dfae' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnCompleteActionID')) BEGIN
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
            '31f3f7cc-c0d0-4dd9-84f1-255bdb54dfae',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '86e954fa-9304-49f6-ad53-7ea09875fd87' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnOverdueActionID')) BEGIN
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
            '86e954fa-9304-49f6-ad53-7ea09875fd87',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd6d015d3-c9d9-4eac-b17c-4ead902b6322' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnPercentChangeActionID')) BEGIN
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
            'd6d015d3-c9d9-4eac-b17c-4ead902b6322',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4383f518-7ae7-4c9e-b105-d9090fc545f1' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'IsActive')) BEGIN
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
            '4383f518-7ae7-4c9e-b105-d9090fc545f1',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3b6a900c-646f-4a98-8f4b-bc7ae54a9c7a' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = '__mj_CreatedAt')) BEGIN
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
            '3b6a900c-646f-4a98-8f4b-bc7ae54a9c7a',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a4cc3d1e-96ac-4ec7-98cf-f83862215617' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'a4cc3d1e-96ac-4ec7-98cf-f83862215617',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '45ca153f-265a-4ac1-82f3-2ee0f76a0c91' OR (EntityID = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND Name = 'ID')) BEGIN
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
            '45ca153f-265a-4ac1-82f3-2ee0f76a0c91',
            'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- Entity: MJ_BizApps_Tasks: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2e782cec-cbdf-4ff0-ad79-254e2e2a6c62' OR (EntityID = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND Name = 'TemplateID')) BEGIN
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
            '2e782cec-cbdf-4ff0-ad79-254e2e2a6c62',
            'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- Entity: MJ_BizApps_Tasks: Task Template Items
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
            0,
            '802AEF11-BFE2-4B46-98B2-5FEBD4E35923',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e0060603-e9ff-4829-a4a8-a9b2abdb6bfa' OR (EntityID = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND Name = 'Name')) BEGIN
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
            'e0060603-e9ff-4829-a4a8-a9b2abdb6bfa',
            'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- Entity: MJ_BizApps_Tasks: Task Template Items
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
      END;

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fbcdc553-91ed-4844-b062-192358d1acd2' OR (EntityID = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND Name = 'Description')) BEGIN
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
            'fbcdc553-91ed-4844-b062-192358d1acd2',
            'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- Entity: MJ_BizApps_Tasks: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '97d8e900-6af3-4a75-92da-1eaa66984aae' OR (EntityID = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND Name = 'ParentItemID')) BEGIN
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
            '97d8e900-6af3-4a75-92da-1eaa66984aae',
            'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- Entity: MJ_BizApps_Tasks: Task Template Items
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
            0,
            'A28FDD91-D380-427E-B374-BCEC56ED75B7',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '69c1abe5-3db5-4f9c-a55a-6381d46c1cd4' OR (EntityID = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND Name = 'Priority')) BEGIN
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
            '69c1abe5-3db5-4f9c-a55a-6381d46c1cd4',
            'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- Entity: MJ_BizApps_Tasks: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7d855b57-90ec-47e2-85c7-0ef700036905' OR (EntityID = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND Name = 'DaysFromStart')) BEGIN
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
            '7d855b57-90ec-47e2-85c7-0ef700036905',
            'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- Entity: MJ_BizApps_Tasks: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c666f314-2fe0-4c7e-8cf0-33ff278cedf8' OR (EntityID = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND Name = 'HoursEstimated')) BEGIN
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
            'c666f314-2fe0-4c7e-8cf0-33ff278cedf8',
            'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- Entity: MJ_BizApps_Tasks: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ee42dc30-d767-46e2-9921-db1c2b423734' OR (EntityID = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND Name = 'Sequence')) BEGIN
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
            'ee42dc30-d767-46e2-9921-db1c2b423734',
            'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- Entity: MJ_BizApps_Tasks: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fb020b7b-8d60-47e2-8324-240939f0c6bb' OR (EntityID = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND Name = '__mj_CreatedAt')) BEGIN
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
            'fb020b7b-8d60-47e2-8324-240939f0c6bb',
            'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- Entity: MJ_BizApps_Tasks: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5557c90b-7a7d-4fa6-910d-001917ed428c' OR (EntityID = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '5557c90b-7a7d-4fa6-910d-001917ed428c',
            'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- Entity: MJ_BizApps_Tasks: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e59d0690-163e-433c-b408-df6ae4ec4747' OR (EntityID = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND Name = 'ID')) BEGIN
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
            'e59d0690-163e-433c-b408-df6ae4ec4747',
            'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- Entity: MJ_BizApps_Tasks: Task Notification Logs
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e1e634a8-e437-4cf7-9c01-9272a0fd5c35' OR (EntityID = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND Name = 'TaskID')) BEGIN
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
            'e1e634a8-e437-4cf7-9c01-9272a0fd5c35',
            'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- Entity: MJ_BizApps_Tasks: Task Notification Logs
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9f629abd-ec18-4fa9-9bde-c8e47938903c' OR (EntityID = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND Name = 'NotificationType')) BEGIN
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
            '9f629abd-ec18-4fa9-9bde-c8e47938903c',
            'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- Entity: MJ_BizApps_Tasks: Task Notification Logs
            100003,
            'NotificationType',
            'Notification Type',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '66bd853f-28ca-4592-8409-c114efb477a2' OR (EntityID = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND Name = 'NotifiedUserID')) BEGIN
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
            '66bd853f-28ca-4592-8409-c114efb477a2',
            'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- Entity: MJ_BizApps_Tasks: Task Notification Logs
            100004,
            'NotifiedUserID',
            'Notified User ID',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'bc607c2b-d677-41b8-b2ce-4c515e49adc0' OR (EntityID = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND Name = 'NotifiedAt')) BEGIN
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
            'bc607c2b-d677-41b8-b2ce-4c515e49adc0',
            'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- Entity: MJ_BizApps_Tasks: Task Notification Logs
            100005,
            'NotifiedAt',
            'Notified At',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7ae19b3a-b0bd-4642-89bd-f1218ce0a962' OR (EntityID = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND Name = '__mj_CreatedAt')) BEGIN
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
            '7ae19b3a-b0bd-4642-89bd-f1218ce0a962',
            'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- Entity: MJ_BizApps_Tasks: Task Notification Logs
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '202fc839-4893-468d-ae6b-faab8192c75c' OR (EntityID = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '202fc839-4893-468d-ae6b-faab8192c75c',
            'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- Entity: MJ_BizApps_Tasks: Task Notification Logs
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1d9ba99a-0cb9-4a1b-a1a9-3d4de2324cde' OR (EntityID = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND Name = 'ID')) BEGIN
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
            '1d9ba99a-0cb9-4a1b-a1a9-3d4de2324cde',
            'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- Entity: MJ_BizApps_Tasks: Task Comments
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1b0590eb-d333-46e2-ba4c-2328430fd472' OR (EntityID = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND Name = 'TaskID')) BEGIN
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
            '1b0590eb-d333-46e2-ba4c-2328430fd472',
            'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- Entity: MJ_BizApps_Tasks: Task Comments
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '926de279-27ff-43d5-9f02-cb5c8cb25ed5' OR (EntityID = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND Name = 'ParentID')) BEGIN
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
            '926de279-27ff-43d5-9f02-cb5c8cb25ed5',
            'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- Entity: MJ_BizApps_Tasks: Task Comments
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
            0,
            'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'bff49ce0-1e51-4f11-9d1d-cb1c1d014ad5' OR (EntityID = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND Name = 'PersonID')) BEGIN
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
            'bff49ce0-1e51-4f11-9d1d-cb1c1d014ad5',
            'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- Entity: MJ_BizApps_Tasks: Task Comments
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8e9c502b-d745-47f1-98aa-ad6ffe691d65' OR (EntityID = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND Name = 'Content')) BEGIN
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
            '8e9c502b-d745-47f1-98aa-ad6ffe691d65',
            'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- Entity: MJ_BizApps_Tasks: Task Comments
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '92aee8dc-ed9d-4785-a6e1-c5d98884ed67' OR (EntityID = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND Name = 'IsEdited')) BEGIN
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
            '92aee8dc-ed9d-4785-a6e1-c5d98884ed67',
            'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- Entity: MJ_BizApps_Tasks: Task Comments
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2436ad22-ecce-48c0-87a7-f6f7f16fd12b' OR (EntityID = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND Name = '__mj_CreatedAt')) BEGIN
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
            '2436ad22-ecce-48c0-87a7-f6f7f16fd12b',
            'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- Entity: MJ_BizApps_Tasks: Task Comments
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fdb6e33e-431f-4097-9119-657eaca7fe5b' OR (EntityID = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'fdb6e33e-431f-4097-9119-657eaca7fe5b',
            'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- Entity: MJ_BizApps_Tasks: Task Comments
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '133050ee-20cf-45b3-a567-2aa95c0019f2' OR (EntityID = '5DB17493-CD0A-4633-80D4-D4A499662C76' AND Name = 'ID')) BEGIN
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
            '133050ee-20cf-45b3-a567-2aa95c0019f2',
            '5DB17493-CD0A-4633-80D4-D4A499662C76', -- Entity: MJ_BizApps_Tasks: Task Tags
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c7699d28-7075-435b-8a6f-1912b09a3469' OR (EntityID = '5DB17493-CD0A-4633-80D4-D4A499662C76' AND Name = 'Name')) BEGIN
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
            'c7699d28-7075-435b-8a6f-1912b09a3469',
            '5DB17493-CD0A-4633-80D4-D4A499662C76', -- Entity: MJ_BizApps_Tasks: Task Tags
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3ea0a461-dd7e-43b9-9349-702376f83663' OR (EntityID = '5DB17493-CD0A-4633-80D4-D4A499662C76' AND Name = 'ColorCode')) BEGIN
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
            '3ea0a461-dd7e-43b9-9349-702376f83663',
            '5DB17493-CD0A-4633-80D4-D4A499662C76', -- Entity: MJ_BizApps_Tasks: Task Tags
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '73221c4b-0f32-4bb2-a075-6637905a8fab' OR (EntityID = '5DB17493-CD0A-4633-80D4-D4A499662C76' AND Name = 'Description')) BEGIN
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
            '73221c4b-0f32-4bb2-a075-6637905a8fab',
            '5DB17493-CD0A-4633-80D4-D4A499662C76', -- Entity: MJ_BizApps_Tasks: Task Tags
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f34358ef-69fa-43a8-b8df-dd57791fc52c' OR (EntityID = '5DB17493-CD0A-4633-80D4-D4A499662C76' AND Name = '__mj_CreatedAt')) BEGIN
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
            'f34358ef-69fa-43a8-b8df-dd57791fc52c',
            '5DB17493-CD0A-4633-80D4-D4A499662C76', -- Entity: MJ_BizApps_Tasks: Task Tags
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e4a5d9df-1767-4c10-bd52-04b8a4c8bce2' OR (EntityID = '5DB17493-CD0A-4633-80D4-D4A499662C76' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'e4a5d9df-1767-4c10-bd52-04b8a4c8bce2',
            '5DB17493-CD0A-4633-80D4-D4A499662C76', -- Entity: MJ_BizApps_Tasks: Task Tags
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7ffa1073-b7a2-46df-a943-d10da3673c9b' OR (EntityID = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND Name = 'ID')) BEGIN
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
            '7ffa1073-b7a2-46df-a943-d10da3673c9b',
            'DF98E700-1992-442B-B93E-E47379F2CA52', -- Entity: MJ_BizApps_Tasks: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8d982a22-f541-479b-ad71-e30667f21e32' OR (EntityID = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND Name = 'TaskID')) BEGIN
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
            '8d982a22-f541-479b-ad71-e30667f21e32',
            'DF98E700-1992-442B-B93E-E47379F2CA52', -- Entity: MJ_BizApps_Tasks: Task Assignments
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
            0,
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '01494276-140c-474d-a810-56c05f06b47e' OR (EntityID = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND Name = 'AssigneeEntityID')) BEGIN
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
            '01494276-140c-474d-a810-56c05f06b47e',
            'DF98E700-1992-442B-B93E-E47379F2CA52', -- Entity: MJ_BizApps_Tasks: Task Assignments
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
      END;

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a88cb22d-56cf-4506-9ac0-22dd89c7481c' OR (EntityID = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND Name = 'AssigneeRecordID')) BEGIN
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
            'a88cb22d-56cf-4506-9ac0-22dd89c7481c',
            'DF98E700-1992-442B-B93E-E47379F2CA52', -- Entity: MJ_BizApps_Tasks: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0b8e91bf-8429-46c3-acae-d930b6c032e8' OR (EntityID = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND Name = 'RoleID')) BEGIN
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
            '0b8e91bf-8429-46c3-acae-d930b6c032e8',
            'DF98E700-1992-442B-B93E-E47379F2CA52', -- Entity: MJ_BizApps_Tasks: Task Assignments
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
            0,
            '559054C2-8F03-4A66-B4FD-70DE5948ACE2',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '79f7ae2e-7760-467f-9147-02edfcd730ca' OR (EntityID = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND Name = 'RoleNotes')) BEGIN
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
            '79f7ae2e-7760-467f-9147-02edfcd730ca',
            'DF98E700-1992-442B-B93E-E47379F2CA52', -- Entity: MJ_BizApps_Tasks: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4e823e84-05b4-43b4-a651-693798d589a8' OR (EntityID = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND Name = 'Status')) BEGIN
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
            '4e823e84-05b4-43b4-a651-693798d589a8',
            'DF98E700-1992-442B-B93E-E47379F2CA52', -- Entity: MJ_BizApps_Tasks: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd472964e-4aaf-44e6-a01a-e2a92aaa44da' OR (EntityID = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND Name = 'AssignedByPersonID')) BEGIN
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
            'd472964e-4aaf-44e6-a01a-e2a92aaa44da',
            'DF98E700-1992-442B-B93E-E47379F2CA52', -- Entity: MJ_BizApps_Tasks: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5b7c8acc-6fd6-4f9b-84b6-f76fdc4d90fc' OR (EntityID = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND Name = 'AssignedAt')) BEGIN
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
            '5b7c8acc-6fd6-4f9b-84b6-f76fdc4d90fc',
            'DF98E700-1992-442B-B93E-E47379F2CA52', -- Entity: MJ_BizApps_Tasks: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '27f4d591-4acd-4bfe-9ab4-c372cb0533ea' OR (EntityID = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND Name = '__mj_CreatedAt')) BEGIN
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
            '27f4d591-4acd-4bfe-9ab4-c372cb0533ea',
            'DF98E700-1992-442B-B93E-E47379F2CA52', -- Entity: MJ_BizApps_Tasks: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2f422608-152f-4983-83a5-3fd9fe5ce6fb' OR (EntityID = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '2f422608-152f-4983-83a5-3fd9fe5ce6fb',
            'DF98E700-1992-442B-B93E-E47379F2CA52', -- Entity: MJ_BizApps_Tasks: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c2856d8e-31d8-4f13-a94a-2254c7427c69' OR (EntityID = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND Name = 'ID')) BEGIN
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
            'c2856d8e-31d8-4f13-a94a-2254c7427c69',
            '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- Entity: MJ_BizApps_Tasks: Task Categories
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5965f6a3-f788-40df-b248-b02a5834db01' OR (EntityID = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND Name = 'Name')) BEGIN
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
            '5965f6a3-f788-40df-b248-b02a5834db01',
            '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- Entity: MJ_BizApps_Tasks: Task Categories
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
      END;

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7b6a7e70-677d-4e51-a845-d70bca699dc2' OR (EntityID = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND Name = 'Description')) BEGIN
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
            '7b6a7e70-677d-4e51-a845-d70bca699dc2',
            '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- Entity: MJ_BizApps_Tasks: Task Categories
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4da0eec6-3dc7-404c-9694-a65e1b58093c' OR (EntityID = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND Name = 'ParentID')) BEGIN
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
            '4da0eec6-3dc7-404c-9694-a65e1b58093c',
            '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- Entity: MJ_BizApps_Tasks: Task Categories
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
            0,
            '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '90a50ded-1f30-4429-87f0-0e2669260594' OR (EntityID = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND Name = 'ColorCode')) BEGIN
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
            '90a50ded-1f30-4429-87f0-0e2669260594',
            '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- Entity: MJ_BizApps_Tasks: Task Categories
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3c853dc6-fa48-4948-96c3-1dc2aad4f43b' OR (EntityID = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND Name = 'Sequence')) BEGIN
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
            '3c853dc6-fa48-4948-96c3-1dc2aad4f43b',
            '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- Entity: MJ_BizApps_Tasks: Task Categories
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f1e5f57f-ba65-427e-b888-eee83e1b030b' OR (EntityID = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND Name = 'IsActive')) BEGIN
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
            'f1e5f57f-ba65-427e-b888-eee83e1b030b',
            '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- Entity: MJ_BizApps_Tasks: Task Categories
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a1b66759-19aa-4c40-9d3a-1ada99277416' OR (EntityID = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND Name = '__mj_CreatedAt')) BEGIN
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
            'a1b66759-19aa-4c40-9d3a-1ada99277416',
            '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- Entity: MJ_BizApps_Tasks: Task Categories
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '87fa3f50-65d0-4b21-968d-31120657030c' OR (EntityID = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '87fa3f50-65d0-4b21-968d-31120657030c',
            '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- Entity: MJ_BizApps_Tasks: Task Categories
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b8ad1f96-886c-4903-8d8d-fbebb27bb506' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'ID')) BEGIN
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
            'b8ad1f96-886c-4903-8d8d-fbebb27bb506',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4c041cc2-d419-485c-9896-790003f638b9' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'Name')) BEGIN
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
            '4c041cc2-d419-485c-9896-790003f638b9',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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
      END;

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '53f5b3e8-7220-48bd-a8e7-aea68a83cb82' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'Description')) BEGIN
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
            '53f5b3e8-7220-48bd-a8e7-aea68a83cb82',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7ea597ed-da32-4cbc-a774-ad5e1986586a' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'TypeID')) BEGIN
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
            '7ea597ed-da32-4cbc-a774-ad5e1986586a',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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
            0,
            '1E30141A-826F-4278-BAA9-BBE14D29E606',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4e328156-a0ff-4d3f-8c01-c75b89f235a6' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'CategoryID')) BEGIN
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
            '4e328156-a0ff-4d3f-8c01-c75b89f235a6',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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
            0,
            '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd419fc58-9802-454e-8d34-1dfaebee7df4' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'ParentID')) BEGIN
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
            'd419fc58-9802-454e-8d34-1dfaebee7df4',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '832e90ca-b150-4b19-aace-f5385db15e64' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'Status')) BEGIN
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
            '832e90ca-b150-4b19-aace-f5385db15e64',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'bb921c78-2bad-4b36-b7cb-e4a471372340' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'Priority')) BEGIN
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
            'bb921c78-2bad-4b36-b7cb-e4a471372340',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3c7731ea-d59c-4db0-9a48-d2c40f7eff04' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'StartedAt')) BEGIN
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
            '3c7731ea-d59c-4db0-9a48-d2c40f7eff04',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e50c83fb-bb14-4dab-b1a5-9bc108988d7b' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'DueAt')) BEGIN
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
            'e50c83fb-bb14-4dab-b1a5-9bc108988d7b',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3b2893b6-9e68-4563-b25b-feb90feff201' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'CompletedAt')) BEGIN
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
            '3b2893b6-9e68-4563-b25b-feb90feff201',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0cf37cc9-7b64-4e9c-a79a-b7cf5be85244' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'HoursEstimated')) BEGIN
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
            '0cf37cc9-7b64-4e9c-a79a-b7cf5be85244',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7dc18266-ae9a-42f2-bf47-b406842712b8' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'HoursActual')) BEGIN
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
            '7dc18266-ae9a-42f2-bf47-b406842712b8',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5812f201-256c-47ac-aeeb-3402fd1e9846' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'PercentComplete')) BEGIN
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
            '5812f201-256c-47ac-aeeb-3402fd1e9846',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '34c579d6-1fb8-4353-8f38-e75764139826' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'Sequence')) BEGIN
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
            '34c579d6-1fb8-4353-8f38-e75764139826',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '72888bfb-a442-414a-96c5-6d8b3a3aa67f' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'BlockedReason')) BEGIN
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
            '72888bfb-a442-414a-96c5-6d8b3a3aa67f',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0a2f1be2-d205-47e7-a804-679c04348efc' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'CompletionNotes')) BEGIN
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
            '0a2f1be2-d205-47e7-a804-679c04348efc',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0259c564-2dfe-480b-9075-3fd4c71fa46c' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'CreatedByPersonID')) BEGIN
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
            '0259c564-2dfe-480b-9075-3fd4c71fa46c',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '65cb1110-12e0-4e48-bed3-6bf1b2926807' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'OverdueNotifiedAt')) BEGIN
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
            '65cb1110-12e0-4e48-bed3-6bf1b2926807',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            100019,
            'OverdueNotifiedAt',
            'Overdue Notified At',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'da16a787-212a-43bd-87e4-4d239f3eb12c' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = '__mj_CreatedAt')) BEGIN
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
            'da16a787-212a-43bd-87e4-4d239f3eb12c',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            100020,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8711f2ad-0bdc-4398-819f-f87f1d11f34a' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '8711f2ad-0bdc-4398-819f-f87f1d11f34a',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            100021,
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

/* SQL text to update existing entity fields from schema */
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon';

/* SQL text to insert entity field value with ID 4d30381d-494d-4522-9888-c6ad0c7f6b55 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('4d30381d-494d-4522-9888-c6ad0c7f6b55', 'BB921C78-2BAD-4B36-B7CB-E4A471372340', 1, 'Critical', 'Critical', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 05d117f8-7cb2-401e-80f3-28023880e81b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('05d117f8-7cb2-401e-80f3-28023880e81b', 'BB921C78-2BAD-4B36-B7CB-E4A471372340', 2, 'High', 'High', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID ba7566d8-67db-49aa-bf82-d68e54551d29 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ba7566d8-67db-49aa-bf82-d68e54551d29', 'BB921C78-2BAD-4B36-B7CB-E4A471372340', 3, 'Low', 'Low', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 5df92809-95d3-45a6-934e-730f6a38e5ff */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('5df92809-95d3-45a6-934e-730f6a38e5ff', 'BB921C78-2BAD-4B36-B7CB-E4A471372340', 4, 'Medium', 'Medium', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID BB921C78-2BAD-4B36-B7CB-E4A471372340 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='BB921C78-2BAD-4B36-B7CB-E4A471372340';

/* SQL text to insert entity field value with ID 26d52813-85ca-44a2-a09c-ba320ee6aa40 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('26d52813-85ca-44a2-a09c-ba320ee6aa40', '4E823E84-05B4-43B4-A651-693798D589A8', 1, 'Completed', 'Completed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID bc167d9f-e496-4fc3-bfde-13a7cfb9da2a */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('bc167d9f-e496-4fc3-bfde-13a7cfb9da2a', '4E823E84-05B4-43B4-A651-693798D589A8', 2, 'InProgress', 'InProgress', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 653e807f-f0dd-40ee-8e35-dd04b64231dc */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('653e807f-f0dd-40ee-8e35-dd04b64231dc', '4E823E84-05B4-43B4-A651-693798D589A8', 3, 'Pending', 'Pending', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 4E823E84-05B4-43B4-A651-693798D589A8 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='4E823E84-05B4-43B4-A651-693798D589A8';

/* SQL text to insert entity field value with ID dd2e1a2d-4eeb-4ecc-aa52-a6a79d339c88 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('dd2e1a2d-4eeb-4ecc-aa52-a6a79d339c88', '2DD6DB6E-82F2-439D-A15F-81BBE36286DF', 1, 'FinishToFinish', 'FinishToFinish', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID a325c453-d9b9-4b5f-9dbe-549e27243c40 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a325c453-d9b9-4b5f-9dbe-549e27243c40', '2DD6DB6E-82F2-439D-A15F-81BBE36286DF', 2, 'FinishToStart', 'FinishToStart', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 0e2761d2-ad6b-4e31-b4e8-885bf5b34b68 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0e2761d2-ad6b-4e31-b4e8-885bf5b34b68', '2DD6DB6E-82F2-439D-A15F-81BBE36286DF', 3, 'StartToFinish', 'StartToFinish', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID dfc7a14d-da67-403e-a80d-c84390ea33bc */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('dfc7a14d-da67-403e-a80d-c84390ea33bc', '2DD6DB6E-82F2-439D-A15F-81BBE36286DF', 4, 'StartToStart', 'StartToStart', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 2DD6DB6E-82F2-439D-A15F-81BBE36286DF */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='2DD6DB6E-82F2-439D-A15F-81BBE36286DF';

/* SQL text to insert entity field value with ID cedc7f50-5cb2-4311-b0d4-737303e70a60 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('cedc7f50-5cb2-4311-b0d4-737303e70a60', '69C1ABE5-3DB5-4F9C-A55A-6381D46C1CD4', 1, 'Critical', 'Critical', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 8aeee5ef-4a5e-418a-be44-325d7a5a68d9 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('8aeee5ef-4a5e-418a-be44-325d7a5a68d9', '69C1ABE5-3DB5-4F9C-A55A-6381D46C1CD4', 2, 'High', 'High', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID a8d56409-368d-46e1-a251-91dfcc3df4c8 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a8d56409-368d-46e1-a251-91dfcc3df4c8', '69C1ABE5-3DB5-4F9C-A55A-6381D46C1CD4', 3, 'Low', 'Low', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID d067fab6-3c26-4846-966a-44c2f03eaf6e */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d067fab6-3c26-4846-966a-44c2f03eaf6e', '69C1ABE5-3DB5-4F9C-A55A-6381D46C1CD4', 4, 'Medium', 'Medium', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 69C1ABE5-3DB5-4F9C-A55A-6381D46C1CD4 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='69C1ABE5-3DB5-4F9C-A55A-6381D46C1CD4';

/* SQL text to insert entity field value with ID 641dc25e-83f6-410d-84d4-2bd3190094ff */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('641dc25e-83f6-410d-84d4-2bd3190094ff', '659F9A5C-BD9C-4EF7-88BE-B731541D2345', 1, 'FinishToFinish', 'FinishToFinish', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 5544f182-aa03-4855-8232-a8d3c4cceca4 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('5544f182-aa03-4855-8232-a8d3c4cceca4', '659F9A5C-BD9C-4EF7-88BE-B731541D2345', 2, 'FinishToStart', 'FinishToStart', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 047aa982-23f2-4bd6-b2ab-6c4e6b314e00 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('047aa982-23f2-4bd6-b2ab-6c4e6b314e00', '659F9A5C-BD9C-4EF7-88BE-B731541D2345', 3, 'StartToFinish', 'StartToFinish', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID fb2e3a35-bca9-40e9-8001-860be1445992 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('fb2e3a35-bca9-40e9-8001-860be1445992', '659F9A5C-BD9C-4EF7-88BE-B731541D2345', 4, 'StartToStart', 'StartToStart', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 659F9A5C-BD9C-4EF7-88BE-B731541D2345 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='659F9A5C-BD9C-4EF7-88BE-B731541D2345';

/* SQL text to insert entity field value with ID b4fba07d-5070-427e-a751-236b0a8ffe51 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b4fba07d-5070-427e-a751-236b0a8ffe51', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 1, 'AssignmentAdded', 'AssignmentAdded', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 2afc33bf-fb39-445d-8610-0867d4997923 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('2afc33bf-fb39-445d-8610-0867d4997923', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 2, 'AssignmentRemoved', 'AssignmentRemoved', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 7a9742f5-de77-4a89-9a95-413b357fc6e4 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7a9742f5-de77-4a89-9a95-413b357fc6e4', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 3, 'Completed', 'Completed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 8491eccc-82e1-4449-a675-bc8036d461d1 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('8491eccc-82e1-4449-a675-bc8036d461d1', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 4, 'Created', 'Created', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 3b04b519-5c74-45b1-ba4b-94372125b7e5 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('3b04b519-5c74-45b1-ba4b-94372125b7e5', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 5, 'DependencyAdded', 'DependencyAdded', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f0ec7c9e-9646-491f-929e-165449d8929e */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f0ec7c9e-9646-491f-929e-165449d8929e', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 6, 'DependencyRemoved', 'DependencyRemoved', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f86d7d4f-2042-4a2b-a984-6c6c073d1cb1 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f86d7d4f-2042-4a2b-a984-6c6c073d1cb1', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 7, 'DueDateChanged', 'DueDateChanged', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 40b53f38-2ce5-41b1-8116-d2340bf0b78b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('40b53f38-2ce5-41b1-8116-d2340bf0b78b', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 8, 'PercentCompleteChanged', 'PercentCompleteChanged', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID dd9e09d4-ff5d-44dc-8ac4-7554feee32fb */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('dd9e09d4-ff5d-44dc-8ac4-7554feee32fb', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 9, 'PriorityChanged', 'PriorityChanged', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 20257078-873d-4c95-9dd9-078e4e856fcb */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('20257078-873d-4c95-9dd9-078e4e856fcb', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 10, 'StatusChange', 'StatusChange', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 7B955FC4-A91E-4CC7-8768-E6945A895DF9 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='7B955FC4-A91E-4CC7-8768-E6945A895DF9';

/* SQL text to insert entity field value with ID 7826fb29-771d-46b1-96b3-05499a302d17 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7826fb29-771d-46b1-96b3-05499a302d17', '9F629ABD-EC18-4FA9-9BDE-C8E47938903C', 1, 'Overdue', 'Overdue', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID ca573315-a0a0-471e-92df-d504d37dc9eb */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ca573315-a0a0-471e-92df-d504d37dc9eb', '9F629ABD-EC18-4FA9-9BDE-C8E47938903C', 2, 'OverdueReminder', 'OverdueReminder', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 9F629ABD-EC18-4FA9-9BDE-C8E47938903C */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='9F629ABD-EC18-4FA9-9BDE-C8E47938903C';

/* SQL text to insert entity field value with ID a94d176f-bd81-4959-8d4d-2eedbf74dd0f */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a94d176f-bd81-4959-8d4d-2eedbf74dd0f', '55D2A288-00C8-425F-8E69-06BCED11D706', 1, 'Critical', 'Critical', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 5e16d4b6-4f90-46bd-bda7-0650bcadbfac */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('5e16d4b6-4f90-46bd-bda7-0650bcadbfac', '55D2A288-00C8-425F-8E69-06BCED11D706', 2, 'High', 'High', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 33eb2fb9-cf45-4958-8c5a-7703e4c3d33b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('33eb2fb9-cf45-4958-8c5a-7703e4c3d33b', '55D2A288-00C8-425F-8E69-06BCED11D706', 3, 'Low', 'Low', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c101d7bc-c32d-4521-9b6a-567e5add230b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c101d7bc-c32d-4521-9b6a-567e5add230b', '55D2A288-00C8-425F-8E69-06BCED11D706', 4, 'Medium', 'Medium', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 55D2A288-00C8-425F-8E69-06BCED11D706 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='55D2A288-00C8-425F-8E69-06BCED11D706';

/* SQL text to insert entity field value with ID 14f84226-72f3-48d0-b3ca-f9de97f016af */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('14f84226-72f3-48d0-b3ca-f9de97f016af', '832E90CA-B150-4B19-AACE-F5385DB15E64', 1, 'Blocked', 'Blocked', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID d250809f-e070-4321-bba9-4adad00f6766 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d250809f-e070-4321-bba9-4adad00f6766', '832E90CA-B150-4B19-AACE-F5385DB15E64', 2, 'Cancelled', 'Cancelled', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 19a8398a-e441-459e-9a81-f02e6eff6778 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('19a8398a-e441-459e-9a81-f02e6eff6778', '832E90CA-B150-4B19-AACE-F5385DB15E64', 3, 'Completed', 'Completed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 83614e4e-617c-4aac-8a72-48c8bca3e243 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('83614e4e-617c-4aac-8a72-48c8bca3e243', '832E90CA-B150-4B19-AACE-F5385DB15E64', 4, 'InProgress', 'InProgress', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 5409b332-98f9-404e-98fe-a3351b7c168c */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('5409b332-98f9-404e-98fe-a3351b7c168c', '832E90CA-B150-4B19-AACE-F5385DB15E64', 5, 'Open', 'Open', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 832E90CA-B150-4B19-AACE-F5385DB15E64 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='832E90CA-B150-4B19-AACE-F5385DB15E64';


/* Create Entity Relationship: MJ_BizApps_Tasks: Task Templates -> MJ_BizApps_Tasks: Task Template Items (One To Many via TemplateID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'b12474ed-dd3b-427f-82d5-be993d42ba21'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('b12474ed-dd3b-427f-82d5-be993d42ba21', '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', 'A28FDD91-D380-427E-B374-BCEC56ED75B7', 'TemplateID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Entities -> MJ_BizApps_Tasks: Task Assignments (One To Many via AssigneeEntityID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '56ec035d-e9dc-49ce-a25a-7f470bff31bd'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('56ec035d-e9dc-49ce-a25a-7f470bff31bd', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'DF98E700-1992-442B-B93E-E47379F2CA52', 'AssigneeEntityID', 'One To Many', 1, 1, 64, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Entities -> MJ_BizApps_Tasks: Task Links (One To Many via EntityID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '8cdcee4b-449f-480c-a36b-1ec930cd9ba6'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('8cdcee4b-449f-480c-a36b-1ec930cd9ba6', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'B92E802C-5C1B-486D-B021-03E47069502C', 'EntityID', 'One To Many', 1, 1, 65, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Users -> MJ_BizApps_Tasks: Task Notification Logs (One To Many via NotifiedUserID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '12cd9353-cf0b-46df-9d50-4ce4abc2b18a'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('12cd9353-cf0b-46df-9d50-4ce4abc2b18a', 'E1238F34-2837-EF11-86D4-6045BDEE16E6', 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', 'NotifiedUserID', 'One To Many', 1, 1, 103, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Actions -> MJ_BizApps_Tasks: Task Notification Configs (One To Many via OverdueActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'e4e392d9-5299-4f9b-88d9-192f37544bbb'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('e4e392d9-5299-4f9b-88d9-192f37544bbb', '38248F34-2837-EF11-86D4-6045BDEE16E6', 'A210AF26-629A-4E0A-A90A-1CCE33F5D095', 'OverdueActionID', 'One To Many', 1, 1, 13, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ: Actions -> MJ_BizApps_Tasks: Task Types (One To Many via OnOverdueActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '243502d4-5636-4caf-af54-be18bf0aa720'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('243502d4-5636-4caf-af54-be18bf0aa720', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnOverdueActionID', 'One To Many', 1, 1, 14, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Actions -> MJ_BizApps_Tasks: Task Types (One To Many via OnPercentChangeActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '17f82e18-5d9f-4ff8-b129-4d95366da36c'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('17f82e18-5d9f-4ff8-b129-4d95366da36c', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnPercentChangeActionID', 'One To Many', 1, 1, 15, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Actions -> MJ_BizApps_Tasks: Task Types (One To Many via OnAssignActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '22a88991-05f6-41f6-8172-69681019e858'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('22a88991-05f6-41f6-8172-69681019e858', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnAssignActionID', 'One To Many', 1, 1, 16, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Actions -> MJ_BizApps_Tasks: Task Types (One To Many via OnCompleteActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '2520bbdc-fd62-468d-9f5e-7a731e2cdb84'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('2520bbdc-fd62-468d-9f5e-7a731e2cdb84', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnCompleteActionID', 'One To Many', 1, 1, 17, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Task Roles -> MJ_BizApps_Tasks: Task Template Item Roles (One To Many via RoleID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'b625a1b5-5989-444d-aabd-0bb5dd31ad48'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('b625a1b5-5989-444d-aabd-0bb5dd31ad48', '559054C2-8F03-4A66-B4FD-70DE5948ACE2', 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', 'RoleID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Task Roles -> MJ_BizApps_Tasks: Task Assignments (One To Many via RoleID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '00e5298b-bdd4-4832-9c29-12021e58d16e'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('00e5298b-bdd4-4832-9c29-12021e58d16e', '559054C2-8F03-4A66-B4FD-70DE5948ACE2', 'DF98E700-1992-442B-B93E-E47379F2CA52', 'RoleID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Task Types -> MJ_BizApps_Tasks: Task Notification Configs (One To Many via TaskTypeID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '64de3230-a6bf-4d22-9c32-fe92c7c0d771'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('64de3230-a6bf-4d22-9c32-fe92c7c0d771', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'A210AF26-629A-4E0A-A90A-1CCE33F5D095', 'TaskTypeID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Task Types -> MJ_BizApps_Tasks: Tasks (One To Many via TypeID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'e75e7a70-9034-4969-b83c-23e73111259a'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('e75e7a70-9034-4969-b83c-23e73111259a', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'TypeID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Task Types -> MJ_BizApps_Tasks: Task Templates (One To Many via TypeID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '8593e41c-e3c6-486c-a41e-5f645f5c6eed'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('8593e41c-e3c6-486c-a41e-5f645f5c6eed', '1E30141A-826F-4278-BAA9-BBE14D29E606', '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', 'TypeID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Task Template Items -> MJ_BizApps_Tasks: Task Template Items (One To Many via ParentItemID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '27b4d4f2-24fb-4dfa-8c91-1698fcd76acf'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('27b4d4f2-24fb-4dfa-8c91-1698fcd76acf', 'A28FDD91-D380-427E-B374-BCEC56ED75B7', 'A28FDD91-D380-427E-B374-BCEC56ED75B7', 'ParentItemID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Task Template Items -> MJ_BizApps_Tasks: Task Template Item Roles (One To Many via ItemID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'abc1839c-6bdb-402e-9cfc-b2c2c46a62b8'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('abc1839c-6bdb-402e-9cfc-b2c2c46a62b8', 'A28FDD91-D380-427E-B374-BCEC56ED75B7', 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', 'ItemID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Task Template Items -> MJ_BizApps_Tasks: Task Template Item Dependencies (One To Many via DependsOnItemID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '1f8ce426-dba4-4370-872f-6c53af4438d0'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('1f8ce426-dba4-4370-872f-6c53af4438d0', 'A28FDD91-D380-427E-B374-BCEC56ED75B7', '8A30F14C-26FF-476E-8CA1-B10EAD29A428', 'DependsOnItemID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Task Template Items -> MJ_BizApps_Tasks: Task Template Item Dependencies (One To Many via ItemID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'bc838a5c-de5f-4ace-b32d-7b6955d654ea'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('bc838a5c-de5f-4ace-b32d-7b6955d654ea', 'A28FDD91-D380-427E-B374-BCEC56ED75B7', '8A30F14C-26FF-476E-8CA1-B10EAD29A428', 'ItemID', 'One To Many', 1, 1, 4, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Task Comments -> MJ_BizApps_Tasks: Task Comments (One To Many via ParentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '2c314e79-a643-443d-bb0c-1c74d4f9c9ac'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('2c314e79-a643-443d-bb0c-1c74d4f9c9ac', 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', 'ParentID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Task Tags -> MJ_BizApps_Tasks: Task Tag Links (One To Many via TagID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '91de82af-9114-4e3a-9d3a-2a669e3d1a56'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('91de82af-9114-4e3a-9d3a-2a669e3d1a56', '5DB17493-CD0A-4633-80D4-D4A499662C76', 'EA953D6B-524E-4A09-A842-9A0B0F1F850C', 'TagID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Task Comments (One To Many via PersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '8d492c02-54cf-44d6-b540-9a37ea146459'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('8d492c02-54cf-44d6-b540-9a37ea146459', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', 'PersonID', 'One To Many', 1, 1, 4, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Task Assignments (One To Many via AssignedByPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '4e9fcaa1-19e6-437d-a968-bfee4587e482'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('4e9fcaa1-19e6-437d-a968-bfee4587e482', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'DF98E700-1992-442B-B93E-E47379F2CA52', 'AssignedByPersonID', 'One To Many', 1, 1, 5, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Task Activities (One To Many via PersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'a2985da3-5b3b-4d9c-b89a-514ae8c0bd17'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a2985da3-5b3b-4d9c-b89a-514ae8c0bd17', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '6615EF77-83F1-49F1-B717-80EC31F77486', 'PersonID', 'One To Many', 1, 1, 6, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Tasks (One To Many via CreatedByPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '8c5a53ec-ca02-4b51-b8c1-9ba625af6044'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('8c5a53ec-ca02-4b51-b8c1-9ba625af6044', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'CreatedByPersonID', 'One To Many', 1, 1, 7, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Task Categories -> MJ_BizApps_Tasks: Task Templates (One To Many via CategoryID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '13e6795f-ed8e-4864-bbd6-0014fc2a40df'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('13e6795f-ed8e-4864-bbd6-0014fc2a40df', '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', 'CategoryID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Task Categories -> MJ_BizApps_Tasks: Task Categories (One To Many via ParentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'db864c7c-8f44-4ff7-85d0-ee414a46cafd'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('db864c7c-8f44-4ff7-85d0-ee414a46cafd', '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', 'ParentID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Task Categories -> MJ_BizApps_Tasks: Tasks (One To Many via CategoryID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '8bc71ac8-d006-4c28-b5a7-269c53c64a0e'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('8bc71ac8-d006-4c28-b5a7-269c53c64a0e', '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'CategoryID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Task Dependencies (One To Many via DependsOnTaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'c8e7abbb-8c96-4f7b-b5da-9cf872a26f61'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('c8e7abbb-8c96-4f7b-b5da-9cf872a26f61', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', 'DependsOnTaskID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Task Dependencies (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'b41f9981-030b-4eff-92c2-9ff0460efcfa'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('b41f9981-030b-4eff-92c2-9ff0460efcfa', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', 'TaskID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Tasks (One To Many via ParentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'd792c155-f9e6-4583-af2e-2c58286b4d16'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('d792c155-f9e6-4583-af2e-2c58286b4d16', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'ParentID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Task Assignments (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'b62e328d-a310-4d6f-8480-ac997074b4a3'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('b62e328d-a310-4d6f-8480-ac997074b4a3', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'DF98E700-1992-442B-B93E-E47379F2CA52', 'TaskID', 'One To Many', 1, 1, 4, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Task Links (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'bc39430a-8236-4d71-9ca8-bf48f5f5b3c8'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('bc39430a-8236-4d71-9ca8-bf48f5f5b3c8', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'B92E802C-5C1B-486D-B021-03E47069502C', 'TaskID', 'One To Many', 1, 1, 5, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Task Comments (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '1c165e6f-0ddf-441b-83b5-63f37c308558'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('1c165e6f-0ddf-441b-83b5-63f37c308558', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', 'TaskID', 'One To Many', 1, 1, 6, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Task Activities (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'f8c5be61-c2db-4cd3-ab00-e9ef094c0a94'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('f8c5be61-c2db-4cd3-ab00-e9ef094c0a94', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '6615EF77-83F1-49F1-B717-80EC31F77486', 'TaskID', 'One To Many', 1, 1, 7, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Task Tag Links (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '7b5c6c40-ee9b-41fe-9b56-f641b5ed2704'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('7b5c6c40-ee9b-41fe-9b56-f641b5ed2704', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'EA953D6B-524E-4A09-A842-9A0B0F1F850C', 'TaskID', 'One To Many', 1, 1, 8, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Task Notification Logs (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '40fd17ae-a6d3-49ec-acad-58a68f6cb2f6'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('40fd17ae-a6d3-49ec-acad-58a68f6cb2f6', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', 'TaskID', 'One To Many', 1, 1, 9, GETUTCDATE(), GETUTCDATE())
   END;

/* SQL text to sync schema info from database schemas */
EXEC [${mjSchema}].[spUpdateSchemaInfoFromDatabase] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon';

/* Index for Foreign Keys for TaskActivity */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Activities
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskID in table TaskActivity
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskActivity_TaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskActivity]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskActivity_TaskID ON [${flyway:defaultSchema}].[TaskActivity] ([TaskID]);

-- Index for foreign key PersonID in table TaskActivity
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskActivity_PersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskActivity]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskActivity_PersonID ON [${flyway:defaultSchema}].[TaskActivity] ([PersonID]);

/* SQL text to update entity field related entity name field map for entity field ID 4E49C2FD-9527-484D-97ED-2AFE4EE0E3E6 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='4E49C2FD-9527-484D-97ED-2AFE4EE0E3E6', @RelatedEntityNameFieldMap='Task';

/* Index for Foreign Keys for TaskAssignment */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Assignments
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskID in table TaskAssignment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskAssignment_TaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskAssignment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskAssignment_TaskID ON [${flyway:defaultSchema}].[TaskAssignment] ([TaskID]);

-- Index for foreign key AssigneeEntityID in table TaskAssignment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskAssignment_AssigneeEntityID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskAssignment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskAssignment_AssigneeEntityID ON [${flyway:defaultSchema}].[TaskAssignment] ([AssigneeEntityID]);

-- Index for foreign key RoleID in table TaskAssignment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskAssignment_RoleID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskAssignment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskAssignment_RoleID ON [${flyway:defaultSchema}].[TaskAssignment] ([RoleID]);

-- Index for foreign key AssignedByPersonID in table TaskAssignment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskAssignment_AssignedByPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskAssignment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskAssignment_AssignedByPersonID ON [${flyway:defaultSchema}].[TaskAssignment] ([AssignedByPersonID]);

/* SQL text to update entity field related entity name field map for entity field ID 8D982A22-F541-479B-AD71-E30667F21E32 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='8D982A22-F541-479B-AD71-E30667F21E32', @RelatedEntityNameFieldMap='Task';

/* Index for Foreign Keys for TaskCategory */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Categories
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key ParentID in table TaskCategory
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskCategory_ParentID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskCategory]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskCategory_ParentID ON [${flyway:defaultSchema}].[TaskCategory] ([ParentID]);

/* SQL text to update entity field related entity name field map for entity field ID 4DA0EEC6-3DC7-404C-9694-A65E1B58093C */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='4DA0EEC6-3DC7-404C-9694-A65E1B58093C', @RelatedEntityNameFieldMap='Parent';

/* Index for Foreign Keys for TaskComment */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskID in table TaskComment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskComment_TaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskComment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskComment_TaskID ON [${flyway:defaultSchema}].[TaskComment] ([TaskID]);

-- Index for foreign key ParentID in table TaskComment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskComment_ParentID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskComment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskComment_ParentID ON [${flyway:defaultSchema}].[TaskComment] ([ParentID]);

-- Index for foreign key PersonID in table TaskComment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskComment_PersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskComment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskComment_PersonID ON [${flyway:defaultSchema}].[TaskComment] ([PersonID]);

/* SQL text to update entity field related entity name field map for entity field ID 1B0590EB-D333-46E2-BA4C-2328430FD472 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='1B0590EB-D333-46E2-BA4C-2328430FD472', @RelatedEntityNameFieldMap='Task';

/* Index for Foreign Keys for TaskDependency */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Dependencies
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskID in table TaskDependency
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskDependency_TaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskDependency]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskDependency_TaskID ON [${flyway:defaultSchema}].[TaskDependency] ([TaskID]);

-- Index for foreign key DependsOnTaskID in table TaskDependency
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskDependency_DependsOnTaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskDependency]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskDependency_DependsOnTaskID ON [${flyway:defaultSchema}].[TaskDependency] ([DependsOnTaskID]);

/* SQL text to update entity field related entity name field map for entity field ID 9CCC0485-5B84-4120-9E9B-4D1A89999973 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='9CCC0485-5B84-4120-9E9B-4D1A89999973', @RelatedEntityNameFieldMap='Task';

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

/* SQL text to update entity field related entity name field map for entity field ID C885176B-BCCD-4D0A-BDFC-B624394404B4 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='C885176B-BCCD-4D0A-BDFC-B624394404B4', @RelatedEntityNameFieldMap='Person';

/* SQL text to update entity field related entity name field map for entity field ID 01494276-140C-474D-A810-56C05F06B47E */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='01494276-140C-474D-A810-56C05F06B47E', @RelatedEntityNameFieldMap='AssigneeEntity';

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
INNER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
LEFT OUTER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_PersonID
  ON
    [t].[PersonID] = mjBizAppsCommonPerson_PersonID.[ID]
GO
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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskActivity] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Activities */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskActivity] TO [cdp_Developer], [cdp_Integration];

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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskActivity] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Activities */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskActivity] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID BFF49CE0-1E51-4F11-9D1D-CB1C1D014AD5 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='BFF49CE0-1E51-4F11-9D1D-CB1C1D014AD5', @RelatedEntityNameFieldMap='Person';

/* SQL text to update entity field related entity name field map for entity field ID 0704AD59-838F-49D6-9891-C5930C890258 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='0704AD59-838F-49D6-9891-C5930C890258', @RelatedEntityNameFieldMap='DependsOnTask';

/* SQL text to update entity field related entity name field map for entity field ID 0B8E91BF-8429-46C3-ACAE-D930B6C032E8 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='0B8E91BF-8429-46C3-ACAE-D930B6C032E8', @RelatedEntityNameFieldMap='Role';

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
INNER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
INNER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_DependsOnTaskID
  ON
    [t].[DependsOnTaskID] = mjBizAppsTasksTask_DependsOnTaskID.[ID]
GO
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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskDependency] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Dependencies */

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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDependency] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Dependencies */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskDependency] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID D472964E-4AAF-44E6-A01A-E2A92AAA44DA */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='D472964E-4AAF-44E6-A01A-E2A92AAA44DA', @RelatedEntityNameFieldMap='AssignedByPerson';

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
INNER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
INNER JOIN
    [${mjSchema}].[Entity] AS MJEntity_AssigneeEntityID
  ON
    [t].[AssigneeEntityID] = MJEntity_AssigneeEntityID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskRole] AS mjBizAppsTasksTaskRole_RoleID
  ON
    [t].[RoleID] = mjBizAppsTasksTaskRole_RoleID.[ID]
LEFT OUTER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_AssignedByPersonID
  ON
    [t].[AssignedByPersonID] = mjBizAppsCommonPerson_AssignedByPersonID.[ID]
GO
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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskAssignment] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Assignments */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskAssignment] TO [cdp_Developer], [cdp_Integration];

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

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskAssignment] TO [cdp_Developer], [cdp_Integration]
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

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskAssignment] TO [cdp_Developer], [cdp_Integration];

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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskAssignment] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Assignments */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskAssignment] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for TaskLink */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Links
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskID in table TaskLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskLink_TaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskLink_TaskID ON [${flyway:defaultSchema}].[TaskLink] ([TaskID]);

-- Index for foreign key EntityID in table TaskLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskLink_EntityID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskLink_EntityID ON [${flyway:defaultSchema}].[TaskLink] ([EntityID]);

/* SQL text to update entity field related entity name field map for entity field ID C6E39EDF-D1B0-4571-9A35-22A4D7FD595E */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='C6E39EDF-D1B0-4571-9A35-22A4D7FD595E', @RelatedEntityNameFieldMap='Task';

/* Index for Foreign Keys for TaskNotificationConfig */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Configs
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskTypeID in table TaskNotificationConfig
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskNotificationConfig_TaskTypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskNotificationConfig]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskNotificationConfig_TaskTypeID ON [${flyway:defaultSchema}].[TaskNotificationConfig] ([TaskTypeID]);

-- Index for foreign key OverdueActionID in table TaskNotificationConfig
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskNotificationConfig_OverdueActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskNotificationConfig]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskNotificationConfig_OverdueActionID ON [${flyway:defaultSchema}].[TaskNotificationConfig] ([OverdueActionID]);

/* SQL text to update entity field related entity name field map for entity field ID 3A3DC1EE-3B5D-4ECB-9E63-FB061C37951F */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='3A3DC1EE-3B5D-4ECB-9E63-FB061C37951F', @RelatedEntityNameFieldMap='TaskType';

/* Index for Foreign Keys for TaskNotificationLog */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Logs
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskID in table TaskNotificationLog
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskNotificationLog_TaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskNotificationLog]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskNotificationLog_TaskID ON [${flyway:defaultSchema}].[TaskNotificationLog] ([TaskID]);

-- Index for foreign key NotifiedUserID in table TaskNotificationLog
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskNotificationLog_NotifiedUserID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskNotificationLog]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskNotificationLog_NotifiedUserID ON [${flyway:defaultSchema}].[TaskNotificationLog] ([NotifiedUserID]);

/* SQL text to update entity field related entity name field map for entity field ID E1E634A8-E437-4CF7-9C01-9272A0FD5C35 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='E1E634A8-E437-4CF7-9C01-9272A0FD5C35', @RelatedEntityNameFieldMap='Task';

/* Index for Foreign Keys for TaskRole */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Roles
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

/* Index for Foreign Keys for TaskTagLink */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tag Links
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskID in table TaskTagLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTagLink_TaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTagLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTagLink_TaskID ON [${flyway:defaultSchema}].[TaskTagLink] ([TaskID]);

-- Index for foreign key TagID in table TaskTagLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTagLink_TagID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTagLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTagLink_TagID ON [${flyway:defaultSchema}].[TaskTagLink] ([TagID]);

/* SQL text to update entity field related entity name field map for entity field ID 34A075FF-EA19-4045-89BB-8FE767ECDBF6 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='34A075FF-EA19-4045-89BB-8FE767ECDBF6', @RelatedEntityNameFieldMap='Task';

/* Base View SQL for MJ_BizApps_Tasks: Task Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Roles
-- Item: vwTaskRoles
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Roles
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskRole
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskRoles]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskRoles];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskRoles]
AS
SELECT
    t.*
FROM
    [${flyway:defaultSchema}].[TaskRole] AS t
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskRoles] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Roles
-- Item: Permissions for vwTaskRoles
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskRoles] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Roles
-- Item: spCreateTaskRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskRole
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskRole]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskRole];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskRole]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(100),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @Sequence int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskRole]
            (
                [ID],
                [Name],
                [Description],
                [Sequence]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                ISNULL(@Sequence, 100)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskRole]
            (
                [Name],
                [Description],
                [Sequence]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                ISNULL(@Sequence, 100)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskRoles] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskRole] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Roles */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskRole] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Roles
-- Item: spUpdateTaskRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskRole
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskRole]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskRole];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskRole]
    @ID uniqueidentifier,
    @Name nvarchar(100) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @Sequence int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskRole]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [Sequence] = ISNULL(@Sequence, [Sequence])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskRoles] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskRoles]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskRole] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskRole table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskRole]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskRole];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskRole
ON [${flyway:defaultSchema}].[TaskRole]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskRole]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskRole] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Roles */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskRole] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Roles
-- Item: spDeleteTaskRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskRole
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskRole]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskRole];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskRole]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskRole]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskRole] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Roles */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskRole] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID 66BD853F-28CA-4592-8409-C114EFB477A2 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='66BD853F-28CA-4592-8409-C114EFB477A2', @RelatedEntityNameFieldMap='NotifiedUser';

/* SQL text to update entity field related entity name field map for entity field ID E2740C12-01C0-4F86-ADA4-F0CEA1180DAC */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='E2740C12-01C0-4F86-ADA4-F0CEA1180DAC', @RelatedEntityNameFieldMap='Tag';

/* SQL text to update entity field related entity name field map for entity field ID 62E69520-B969-41DA-88E0-58EC3AFA0783 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='62E69520-B969-41DA-88E0-58EC3AFA0783', @RelatedEntityNameFieldMap='OverdueAction';

/* SQL text to update entity field related entity name field map for entity field ID 2DEE15AB-8820-448F-B3CE-AE79A8B82B6F */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='2DEE15AB-8820-448F-B3CE-AE79A8B82B6F', @RelatedEntityNameFieldMap='Entity';

/* Base View SQL for MJ_BizApps_Tasks: Task Notification Configs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Configs
-- Item: vwTaskNotificationConfigs
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Notification Configs
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskNotificationConfig
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskNotificationConfigs]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskNotificationConfigs];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskNotificationConfigs]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskType_TaskTypeID.[Name] AS [TaskType],
    MJAction_OverdueActionID.[Name] AS [OverdueAction]
FROM
    [${flyway:defaultSchema}].[TaskNotificationConfig] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskType] AS mjBizAppsTasksTaskType_TaskTypeID
  ON
    [t].[TaskTypeID] = mjBizAppsTasksTaskType_TaskTypeID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OverdueActionID
  ON
    [t].[OverdueActionID] = MJAction_OverdueActionID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskNotificationConfigs] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Notification Configs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Configs
-- Item: Permissions for vwTaskNotificationConfigs
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskNotificationConfigs] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Notification Configs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Configs
-- Item: spCreateTaskNotificationConfig
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskNotificationConfig
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskNotificationConfig]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskNotificationConfig];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskNotificationConfig]
    @ID uniqueidentifier = NULL,
    @TaskTypeID_Clear bit = 0,
    @TaskTypeID uniqueidentifier = NULL,
    @OverdueNotificationsEnabled bit = NULL,
    @OverdueGracePeriodHours int = NULL,
    @OverdueRepeatIntervalHours_Clear bit = 0,
    @OverdueRepeatIntervalHours int = NULL,
    @NotifyAssignees bit = NULL,
    @NotifyCreator bit = NULL,
    @OverdueActionID_Clear bit = 0,
    @OverdueActionID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskNotificationConfig]
            (
                [ID],
                [TaskTypeID],
                [OverdueNotificationsEnabled],
                [OverdueGracePeriodHours],
                [OverdueRepeatIntervalHours],
                [NotifyAssignees],
                [NotifyCreator],
                [OverdueActionID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                CASE WHEN @TaskTypeID_Clear = 1 THEN NULL ELSE ISNULL(@TaskTypeID, NULL) END,
                ISNULL(@OverdueNotificationsEnabled, 1),
                ISNULL(@OverdueGracePeriodHours, 0),
                CASE WHEN @OverdueRepeatIntervalHours_Clear = 1 THEN NULL ELSE ISNULL(@OverdueRepeatIntervalHours, NULL) END,
                ISNULL(@NotifyAssignees, 1),
                ISNULL(@NotifyCreator, 1),
                CASE WHEN @OverdueActionID_Clear = 1 THEN NULL ELSE ISNULL(@OverdueActionID, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskNotificationConfig]
            (
                [TaskTypeID],
                [OverdueNotificationsEnabled],
                [OverdueGracePeriodHours],
                [OverdueRepeatIntervalHours],
                [NotifyAssignees],
                [NotifyCreator],
                [OverdueActionID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                CASE WHEN @TaskTypeID_Clear = 1 THEN NULL ELSE ISNULL(@TaskTypeID, NULL) END,
                ISNULL(@OverdueNotificationsEnabled, 1),
                ISNULL(@OverdueGracePeriodHours, 0),
                CASE WHEN @OverdueRepeatIntervalHours_Clear = 1 THEN NULL ELSE ISNULL(@OverdueRepeatIntervalHours, NULL) END,
                ISNULL(@NotifyAssignees, 1),
                ISNULL(@NotifyCreator, 1),
                CASE WHEN @OverdueActionID_Clear = 1 THEN NULL ELSE ISNULL(@OverdueActionID, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskNotificationConfigs] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskNotificationConfig] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Notification Configs */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskNotificationConfig] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Notification Configs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Configs
-- Item: spUpdateTaskNotificationConfig
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskNotificationConfig
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskNotificationConfig]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskNotificationConfig];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskNotificationConfig]
    @ID uniqueidentifier,
    @TaskTypeID_Clear bit = 0,
    @TaskTypeID uniqueidentifier = NULL,
    @OverdueNotificationsEnabled bit = NULL,
    @OverdueGracePeriodHours int = NULL,
    @OverdueRepeatIntervalHours_Clear bit = 0,
    @OverdueRepeatIntervalHours int = NULL,
    @NotifyAssignees bit = NULL,
    @NotifyCreator bit = NULL,
    @OverdueActionID_Clear bit = 0,
    @OverdueActionID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskNotificationConfig]
    SET
        [TaskTypeID] = CASE WHEN @TaskTypeID_Clear = 1 THEN NULL ELSE ISNULL(@TaskTypeID, [TaskTypeID]) END,
        [OverdueNotificationsEnabled] = ISNULL(@OverdueNotificationsEnabled, [OverdueNotificationsEnabled]),
        [OverdueGracePeriodHours] = ISNULL(@OverdueGracePeriodHours, [OverdueGracePeriodHours]),
        [OverdueRepeatIntervalHours] = CASE WHEN @OverdueRepeatIntervalHours_Clear = 1 THEN NULL ELSE ISNULL(@OverdueRepeatIntervalHours, [OverdueRepeatIntervalHours]) END,
        [NotifyAssignees] = ISNULL(@NotifyAssignees, [NotifyAssignees]),
        [NotifyCreator] = ISNULL(@NotifyCreator, [NotifyCreator]),
        [OverdueActionID] = CASE WHEN @OverdueActionID_Clear = 1 THEN NULL ELSE ISNULL(@OverdueActionID, [OverdueActionID]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskNotificationConfigs] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskNotificationConfigs]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskNotificationConfig] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskNotificationConfig table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskNotificationConfig]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskNotificationConfig];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskNotificationConfig
ON [${flyway:defaultSchema}].[TaskNotificationConfig]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskNotificationConfig]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskNotificationConfig] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Notification Configs */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskNotificationConfig] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Notification Configs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Configs
-- Item: spDeleteTaskNotificationConfig
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskNotificationConfig
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskNotificationConfig]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskNotificationConfig];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskNotificationConfig]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskNotificationConfig]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskNotificationConfig] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Notification Configs */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskNotificationConfig] TO [cdp_Developer], [cdp_Integration];

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
INNER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
INNER JOIN
    [${mjSchema}].[User] AS MJUser_NotifiedUserID
  ON
    [t].[NotifiedUserID] = MJUser_NotifiedUserID.[ID]
GO
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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskNotificationLog] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Notification Logs */

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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskNotificationLog] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Notification Logs */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskNotificationLog] TO [cdp_Developer], [cdp_Integration];

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
INNER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
INNER JOIN
    [${flyway:defaultSchema}].[TaskTag] AS mjBizAppsTasksTaskTag_TagID
  ON
    [t].[TagID] = mjBizAppsTasksTaskTag_TagID.[ID]
GO
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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTagLink] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Tag Links */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTagLink] TO [cdp_Developer], [cdp_Integration];

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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTagLink] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Tag Links */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTagLink] TO [cdp_Developer], [cdp_Integration];

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
INNER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
INNER JOIN
    [${mjSchema}].[Entity] AS MJEntity_EntityID
  ON
    [t].[EntityID] = MJEntity_EntityID.[ID]
GO
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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskLink] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Links */

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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskLink] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Links */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskLink] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for TaskTag */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tags
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

/* Index for Foreign Keys for TaskTemplateItemDependency */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key ItemID in table TaskTemplateItemDependency
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTemplateItemDependency_ItemID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTemplateItemDependency]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplateItemDependency_ItemID ON [${flyway:defaultSchema}].[TaskTemplateItemDependency] ([ItemID]);

-- Index for foreign key DependsOnItemID in table TaskTemplateItemDependency
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTemplateItemDependency_DependsOnItemID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTemplateItemDependency]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplateItemDependency_DependsOnItemID ON [${flyway:defaultSchema}].[TaskTemplateItemDependency] ([DependsOnItemID]);

/* SQL text to update entity field related entity name field map for entity field ID 910121C9-19BF-4A58-B76A-491CCE751333 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='910121C9-19BF-4A58-B76A-491CCE751333', @RelatedEntityNameFieldMap='Item';

/* Index for Foreign Keys for TaskTemplateItemRole */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Roles
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key ItemID in table TaskTemplateItemRole
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTemplateItemRole_ItemID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTemplateItemRole]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplateItemRole_ItemID ON [${flyway:defaultSchema}].[TaskTemplateItemRole] ([ItemID]);

-- Index for foreign key RoleID in table TaskTemplateItemRole
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTemplateItemRole_RoleID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTemplateItemRole]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplateItemRole_RoleID ON [${flyway:defaultSchema}].[TaskTemplateItemRole] ([RoleID]);

/* SQL text to update entity field related entity name field map for entity field ID 64A2358A-484A-4C2A-989B-2687DAA39FAD */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='64A2358A-484A-4C2A-989B-2687DAA39FAD', @RelatedEntityNameFieldMap='Item';

/* Index for Foreign Keys for TaskTemplateItem */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TemplateID in table TaskTemplateItem
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTemplateItem_TemplateID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTemplateItem]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplateItem_TemplateID ON [${flyway:defaultSchema}].[TaskTemplateItem] ([TemplateID]);

-- Index for foreign key ParentItemID in table TaskTemplateItem
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTemplateItem_ParentItemID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTemplateItem]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplateItem_ParentItemID ON [${flyway:defaultSchema}].[TaskTemplateItem] ([ParentItemID]);

/* SQL text to update entity field related entity name field map for entity field ID 2E782CEC-CBDF-4FF0-AD79-254E2E2A6C62 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='2E782CEC-CBDF-4FF0-AD79-254E2E2A6C62', @RelatedEntityNameFieldMap='Template';

/* Index for Foreign Keys for TaskTemplate */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Templates
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key CategoryID in table TaskTemplate
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTemplate_CategoryID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTemplate]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplate_CategoryID ON [${flyway:defaultSchema}].[TaskTemplate] ([CategoryID]);

-- Index for foreign key TypeID in table TaskTemplate
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTemplate_TypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTemplate]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplate_TypeID ON [${flyway:defaultSchema}].[TaskTemplate] ([TypeID]);

/* SQL text to update entity field related entity name field map for entity field ID 9B39D77B-ACEC-40F7-B933-456760238D14 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='9B39D77B-ACEC-40F7-B933-456760238D14', @RelatedEntityNameFieldMap='Category';

/* Base View SQL for MJ_BizApps_Tasks: Task Tags */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tags
-- Item: vwTaskTags
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Tags
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskTag
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskTags]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskTags];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskTags]
AS
SELECT
    t.*
FROM
    [${flyway:defaultSchema}].[TaskTag] AS t
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTags] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Tags */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tags
-- Item: Permissions for vwTaskTags
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTags] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Tags */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tags
-- Item: spCreateTaskTag
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTag
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskTag]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTag];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTag]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(100),
    @ColorCode_Clear bit = 0,
    @ColorCode nvarchar(20) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskTag]
            (
                [ID],
                [Name],
                [ColorCode],
                [Description]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                CASE WHEN @ColorCode_Clear = 1 THEN NULL ELSE ISNULL(@ColorCode, NULL) END,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskTag]
            (
                [Name],
                [ColorCode],
                [Description]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                CASE WHEN @ColorCode_Clear = 1 THEN NULL ELSE ISNULL(@ColorCode, NULL) END,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskTags] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTag] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Tags */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTag] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Tags */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tags
-- Item: spUpdateTaskTag
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTag
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskTag]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTag];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTag]
    @ID uniqueidentifier,
    @Name nvarchar(100) = NULL,
    @ColorCode_Clear bit = 0,
    @ColorCode nvarchar(20) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTag]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [ColorCode] = CASE WHEN @ColorCode_Clear = 1 THEN NULL ELSE ISNULL(@ColorCode, [ColorCode]) END,
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskTags] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskTags]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTag] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTag table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskTag]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskTag];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskTag
ON [${flyway:defaultSchema}].[TaskTag]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTag]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskTag] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Tags */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTag] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Tags */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tags
-- Item: spDeleteTaskTag
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTag
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskTag]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTag];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTag]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskTag]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTag] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Tags */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTag] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID 97D8E900-6AF3-4A75-92DA-1EAA66984AAE */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='97D8E900-6AF3-4A75-92DA-1EAA66984AAE', @RelatedEntityNameFieldMap='ParentItem';

/* SQL text to update entity field related entity name field map for entity field ID F3908C0C-6C75-4A8D-8C7F-38C9535BFFC2 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='F3908C0C-6C75-4A8D-8C7F-38C9535BFFC2', @RelatedEntityNameFieldMap='Type';

/* SQL text to update entity field related entity name field map for entity field ID FC504621-F102-43FA-B6AF-820E0FD0C366 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='FC504621-F102-43FA-B6AF-820E0FD0C366', @RelatedEntityNameFieldMap='Role';

/* SQL text to update entity field related entity name field map for entity field ID F3EC22F4-D9CD-4C05-A31D-84EFDC3D30DE */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='F3EC22F4-D9CD-4C05-A31D-84EFDC3D30DE', @RelatedEntityNameFieldMap='DependsOnItem';

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
INNER JOIN
    [${flyway:defaultSchema}].[TaskTemplateItem] AS mjBizAppsTasksTaskTemplateItem_ItemID
  ON
    [t].[ItemID] = mjBizAppsTasksTaskTemplateItem_ItemID.[ID]
INNER JOIN
    [${flyway:defaultSchema}].[TaskTemplateItem] AS mjBizAppsTasksTaskTemplateItem_DependsOnItemID
  ON
    [t].[DependsOnItemID] = mjBizAppsTasksTaskTemplateItem_DependsOnItemID.[ID]
GO
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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItemDependency] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Template Item Dependencies */

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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItemDependency] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Template Item Dependencies */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItemDependency] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Task Templates */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Templates
-- Item: vwTaskTemplates
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Templates
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskTemplate
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskTemplates]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskTemplates];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskTemplates]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskCategory_CategoryID.[Name] AS [Category],
    mjBizAppsTasksTaskType_TypeID.[Name] AS [Type]
FROM
    [${flyway:defaultSchema}].[TaskTemplate] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskCategory] AS mjBizAppsTasksTaskCategory_CategoryID
  ON
    [t].[CategoryID] = mjBizAppsTasksTaskCategory_CategoryID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskType] AS mjBizAppsTasksTaskType_TypeID
  ON
    [t].[TypeID] = mjBizAppsTasksTaskType_TypeID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTemplates] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Templates */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Templates
-- Item: Permissions for vwTaskTemplates
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTemplates] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Task Templates */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Templates
-- Item: spCreateTaskTemplate
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTemplate
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskTemplate]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTemplate];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTemplate]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(255),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @CategoryID_Clear bit = 0,
    @CategoryID uniqueidentifier = NULL,
    @TypeID_Clear bit = 0,
    @TypeID uniqueidentifier = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskTemplate]
            (
                [ID],
                [Name],
                [Description],
                [CategoryID],
                [TypeID],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @CategoryID_Clear = 1 THEN NULL ELSE ISNULL(@CategoryID, NULL) END,
                CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, NULL) END,
                ISNULL(@IsActive, 1)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskTemplate]
            (
                [Name],
                [Description],
                [CategoryID],
                [TypeID],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @CategoryID_Clear = 1 THEN NULL ELSE ISNULL(@CategoryID, NULL) END,
                CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, NULL) END,
                ISNULL(@IsActive, 1)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskTemplates] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplate] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Templates */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplate] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Task Templates */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Templates
-- Item: spUpdateTaskTemplate
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTemplate
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskTemplate]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTemplate];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTemplate]
    @ID uniqueidentifier,
    @Name nvarchar(255) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @CategoryID_Clear bit = 0,
    @CategoryID uniqueidentifier = NULL,
    @TypeID_Clear bit = 0,
    @TypeID uniqueidentifier = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTemplate]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [CategoryID] = CASE WHEN @CategoryID_Clear = 1 THEN NULL ELSE ISNULL(@CategoryID, [CategoryID]) END,
        [TypeID] = CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, [TypeID]) END,
        [IsActive] = ISNULL(@IsActive, [IsActive])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskTemplates] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskTemplates]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplate] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTemplate table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskTemplate]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskTemplate];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskTemplate
ON [${flyway:defaultSchema}].[TaskTemplate]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTemplate]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskTemplate] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Templates */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTemplate] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Task Templates */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Templates
-- Item: spDeleteTaskTemplate
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTemplate
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskTemplate]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTemplate];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTemplate]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskTemplate]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplate] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Templates */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplate] TO [cdp_Developer], [cdp_Integration];

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
INNER JOIN
    [${flyway:defaultSchema}].[TaskTemplateItem] AS mjBizAppsTasksTaskTemplateItem_ItemID
  ON
    [t].[ItemID] = mjBizAppsTasksTaskTemplateItem_ItemID.[ID]
INNER JOIN
    [${flyway:defaultSchema}].[TaskRole] AS mjBizAppsTasksTaskRole_RoleID
  ON
    [t].[RoleID] = mjBizAppsTasksTaskRole_RoleID.[ID]
GO
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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTemplateItemRole] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Template Item Roles */

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
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTemplateItemRole] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Template Item Roles */

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

/* SQL text to update entity field related entity name field map for entity field ID 2352E1F5-18CA-4495-85DA-516FEFC20463 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='2352E1F5-18CA-4495-85DA-516FEFC20463', @RelatedEntityNameFieldMap='OnAssignAction';

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

/* SQL text to update entity field related entity name field map for entity field ID 7EA597ED-DA32-4CBC-A774-AD5E1986586A */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='7EA597ED-DA32-4CBC-A774-AD5E1986586A', @RelatedEntityNameFieldMap='Type';

/* SQL text to update entity field related entity name field map for entity field ID 4E328156-A0FF-4D3F-8C01-C75B89F235A6 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='4E328156-A0FF-4D3F-8C01-C75B89F235A6', @RelatedEntityNameFieldMap='Category';

/* SQL text to update entity field related entity name field map for entity field ID 31F3F7CC-C0D0-4DD9-84F1-255BDB54DFAE */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='31F3F7CC-C0D0-4DD9-84F1-255BDB54DFAE', @RelatedEntityNameFieldMap='OnCompleteAction';

/* SQL text to update entity field related entity name field map for entity field ID D419FC58-9802-454E-8D34-1DFAEBEE7DF4 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='D419FC58-9802-454E-8D34-1DFAEBEE7DF4', @RelatedEntityNameFieldMap='Parent';

/* SQL text to update entity field related entity name field map for entity field ID 86E954FA-9304-49F6-AD53-7EA09875FD87 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='86E954FA-9304-49F6-AD53-7EA09875FD87', @RelatedEntityNameFieldMap='OnOverdueAction';

/* SQL text to update entity field related entity name field map for entity field ID 0259C564-2DFE-480B-9075-3FD4C71FA46C */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='0259C564-2DFE-480B-9075-3FD4C71FA46C', @RelatedEntityNameFieldMap='CreatedByPerson';

/* SQL text to update entity field related entity name field map for entity field ID D6D015D3-C9D9-4EAC-B17C-4EAD902B6322 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='D6D015D3-C9D9-4EAC-B17C-4EAD902B6322', @RelatedEntityNameFieldMap='OnPercentChangeAction';

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
    @OverdueNotifiedAt datetimeoffset = NULL
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
                [OverdueNotifiedAt]
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
                CASE WHEN @OverdueNotifiedAt_Clear = 1 THEN NULL ELSE ISNULL(@OverdueNotifiedAt, NULL) END
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
                [OverdueNotifiedAt]
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
                CASE WHEN @OverdueNotifiedAt_Clear = 1 THEN NULL ELSE ISNULL(@OverdueNotifiedAt, NULL) END
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
    @OverdueNotifiedAt datetimeoffset = NULL
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
        [OverdueNotifiedAt] = CASE WHEN @OverdueNotifiedAt_Clear = 1 THEN NULL ELSE ISNULL(@OverdueNotifiedAt, [OverdueNotifiedAt]) END
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
    MJAction_OnPercentChangeActionID.[Name] AS [OnPercentChangeAction]
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
    @IsActive bit = NULL
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
                [IsActive]
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
                ISNULL(@IsActive, 1)
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
                [IsActive]
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
                ISNULL(@IsActive, 1)
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
    @IsActive bit = NULL
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
        [IsActive] = ISNULL(@IsActive, [IsActive])
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

/* SQL text to delete unneeded entity fields (17 scoped entities) */
EXEC [${mjSchema}].[spDeleteUnneededEntityFields] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon', @EntityIDs='559054C2-8F03-4A66-B4FD-70DE5948ACE2,DF98E700-1992-442B-B93E-E47379F2CA52,B92E802C-5C1B-486D-B021-03E47069502C,0662FC0F-3F2B-49C9-9BE8-5B59E036044A,5DB17493-CD0A-4633-80D4-D4A499662C76,EA953D6B-524E-4A09-A842-9A0B0F1F850C,B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865,802AEF11-BFE2-4B46-98B2-5FEBD4E35923,A28FDD91-D380-427E-B374-BCEC56ED75B7,8A30F14C-26FF-476E-8CA1-B10EAD29A428,ABFCFE68-F3AA-4401-A547-0FC01F27E3F3,6615EF77-83F1-49F1-B717-80EC31F77486,A210AF26-629A-4E0A-A90A-1CCE33F5D095,DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4,1E30141A-826F-4278-BAA9-BBE14D29E606,06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6,B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466';

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b705b24c-14e9-44df-ad99-5aded1b3d054' OR (EntityID = 'B92E802C-5C1B-486D-B021-03E47069502C' AND Name = 'Task')) BEGIN
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
            'b705b24c-14e9-44df-ad99-5aded1b3d054',
            'B92E802C-5C1B-486D-B021-03E47069502C', -- Entity: MJ_BizApps_Tasks: Task Links
            100015,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0f4c45b2-8d5e-40ca-8ee1-7915db3f885e' OR (EntityID = 'B92E802C-5C1B-486D-B021-03E47069502C' AND Name = 'Entity')) BEGIN
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
            '0f4c45b2-8d5e-40ca-8ee1-7915db3f885e',
            'B92E802C-5C1B-486D-B021-03E47069502C', -- Entity: MJ_BizApps_Tasks: Task Links
            100016,
            'Entity',
            'Entity',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '65dd9bd7-ac80-4b9a-8e08-b92bc37a8d37' OR (EntityID = 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3' AND Name = 'Item')) BEGIN
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
            '65dd9bd7-ac80-4b9a-8e08-b92bc37a8d37',
            'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', -- Entity: MJ_BizApps_Tasks: Task Template Item Roles
            100011,
            'Item',
            'Item',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '258256a5-3b70-4392-b4fc-f13e1892b4ca' OR (EntityID = 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3' AND Name = 'Role')) BEGIN
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
            '258256a5-3b70-4392-b4fc-f13e1892b4ca',
            'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', -- Entity: MJ_BizApps_Tasks: Task Template Item Roles
            100012,
            'Role',
            'Role',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1e0b0b58-eeb0-483f-baa9-2c84b701562b' OR (EntityID = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND Name = 'TaskType')) BEGIN
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
            '1e0b0b58-eeb0-483f-baa9-2c84b701562b',
            'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- Entity: MJ_BizApps_Tasks: Task Notification Configs
            100021,
            'TaskType',
            'Task Type',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c2e46071-908d-4452-9f75-d659d0ee9f21' OR (EntityID = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND Name = 'OverdueAction')) BEGIN
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
            'c2e46071-908d-4452-9f75-d659d0ee9f21',
            'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- Entity: MJ_BizApps_Tasks: Task Notification Configs
            100022,
            'OverdueAction',
            'Overdue Action',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1c054f41-3fd6-44ae-abde-0ae1ffb7407f' OR (EntityID = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND Name = 'Task')) BEGIN
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
            '1c054f41-3fd6-44ae-abde-0ae1ffb7407f',
            '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- Entity: MJ_BizApps_Tasks: Task Dependencies
            100013,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f25c9bb2-2bc9-4893-aee3-665b2dce198c' OR (EntityID = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND Name = 'DependsOnTask')) BEGIN
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
            'f25c9bb2-2bc9-4893-aee3-665b2dce198c',
            '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- Entity: MJ_BizApps_Tasks: Task Dependencies
            100014,
            'DependsOnTask',
            'Depends On Task',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '39e1d13f-7f84-402d-a9e1-ec03dd2d2fd0' OR (EntityID = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND Name = 'Category')) BEGIN
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
            '39e1d13f-7f84-402d-a9e1-ec03dd2d2fd0',
            '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- Entity: MJ_BizApps_Tasks: Task Templates
            100017,
            'Category',
            'Category',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4a27ab78-cb50-4895-a3c1-c04293754fe0' OR (EntityID = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND Name = 'Type')) BEGIN
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
            '4a27ab78-cb50-4895-a3c1-c04293754fe0',
            '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- Entity: MJ_BizApps_Tasks: Task Templates
            100018,
            'Type',
            'Type',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '430ede8e-381e-41b8-a306-2fad2b44a526' OR (EntityID = '6615EF77-83F1-49F1-B717-80EC31F77486' AND Name = 'Task')) BEGIN
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
            '430ede8e-381e-41b8-a306-2fad2b44a526',
            '6615EF77-83F1-49F1-B717-80EC31F77486', -- Entity: MJ_BizApps_Tasks: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fca512c5-ab75-4fbb-bbc2-4499a4439826' OR (EntityID = '6615EF77-83F1-49F1-B717-80EC31F77486' AND Name = 'Person')) BEGIN
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
            'fca512c5-ab75-4fbb-bbc2-4499a4439826',
            '6615EF77-83F1-49F1-B717-80EC31F77486', -- Entity: MJ_BizApps_Tasks: Task Activities
            100020,
            'Person',
            'Person',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2ee80d0d-703c-44c0-843b-54a5cef8e9dd' OR (EntityID = 'EA953D6B-524E-4A09-A842-9A0B0F1F850C' AND Name = 'Task')) BEGIN
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
            '2ee80d0d-703c-44c0-843b-54a5cef8e9dd',
            'EA953D6B-524E-4A09-A842-9A0B0F1F850C', -- Entity: MJ_BizApps_Tasks: Task Tag Links
            100011,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c2df8047-dca7-4404-a067-f679862af2d1' OR (EntityID = 'EA953D6B-524E-4A09-A842-9A0B0F1F850C' AND Name = 'Tag')) BEGIN
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
            'c2df8047-dca7-4404-a067-f679862af2d1',
            'EA953D6B-524E-4A09-A842-9A0B0F1F850C', -- Entity: MJ_BizApps_Tasks: Task Tag Links
            100012,
            'Tag',
            'Tag',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'cf0321d6-9218-4f3e-8f19-359cde794bc9' OR (EntityID = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND Name = 'Item')) BEGIN
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
            'cf0321d6-9218-4f3e-8f19-359cde794bc9',
            '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
            100013,
            'Item',
            'Item',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b3b55837-7701-424a-b681-535aac28dfdb' OR (EntityID = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND Name = 'DependsOnItem')) BEGIN
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
            'b3b55837-7701-424a-b681-535aac28dfdb',
            '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
            100014,
            'DependsOnItem',
            'Depends On Item',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4391ece2-8780-413a-8605-4569f84cff03' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnAssignAction')) BEGIN
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
            '4391ece2-8780-413a-8605-4569f84cff03',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
            100025,
            'OnAssignAction',
            'On Assign Action',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '028bbcc5-6694-4b9f-81e8-f2b99ef72fbe' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnCompleteAction')) BEGIN
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
            '028bbcc5-6694-4b9f-81e8-f2b99ef72fbe',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
            100026,
            'OnCompleteAction',
            'On Complete Action',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '39770061-f6e2-4e20-9d1a-8a9343e0f041' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnOverdueAction')) BEGIN
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
            '39770061-f6e2-4e20-9d1a-8a9343e0f041',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
            100027,
            'OnOverdueAction',
            'On Overdue Action',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f91576c2-90c5-407d-820f-7faeb246cfbd' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'OnPercentChangeAction')) BEGIN
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
            'f91576c2-90c5-407d-820f-7faeb246cfbd',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
            100028,
            'OnPercentChangeAction',
            'On Percent Change Action',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1b04cbb9-c18a-4bb2-956c-16f26aa85d48' OR (EntityID = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND Name = 'Template')) BEGIN
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
            '1b04cbb9-c18a-4bb2-956c-16f26aa85d48',
            'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- Entity: MJ_BizApps_Tasks: Task Template Items
            100023,
            'Template',
            'Template',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '158e5bd6-2fcf-4863-a09b-65f796dd26a5' OR (EntityID = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND Name = 'ParentItem')) BEGIN
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
            '158e5bd6-2fcf-4863-a09b-65f796dd26a5',
            'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- Entity: MJ_BizApps_Tasks: Task Template Items
            100024,
            'ParentItem',
            'Parent Item',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '19fcbb42-f0c7-4b08-87f0-0a2127e0f665' OR (EntityID = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND Name = 'RootParentItemID')) BEGIN
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
            '19fcbb42-f0c7-4b08-87f0-0a2127e0f665',
            'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- Entity: MJ_BizApps_Tasks: Task Template Items
            100025,
            'RootParentItemID',
            'Root Parent Item ID',
            NULL,
            'uniqueidentifier',
            16,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '95d43787-3e4a-4626-be10-1fc07ad2d772' OR (EntityID = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND Name = 'Task')) BEGIN
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
            '95d43787-3e4a-4626-be10-1fc07ad2d772',
            'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- Entity: MJ_BizApps_Tasks: Task Notification Logs
            100015,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '333468ec-8d96-490f-80dd-c90f9aa4025c' OR (EntityID = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND Name = 'NotifiedUser')) BEGIN
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
            '333468ec-8d96-490f-80dd-c90f9aa4025c',
            'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- Entity: MJ_BizApps_Tasks: Task Notification Logs
            100016,
            'NotifiedUser',
            'Notified User',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9adda9ab-8118-4897-95f2-c42a767f5b60' OR (EntityID = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND Name = 'Task')) BEGIN
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
            '9adda9ab-8118-4897-95f2-c42a767f5b60',
            'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- Entity: MJ_BizApps_Tasks: Task Comments
            100017,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2f6fc89c-bb94-4778-83be-d232731db780' OR (EntityID = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND Name = 'Person')) BEGIN
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
            '2f6fc89c-bb94-4778-83be-d232731db780',
            'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- Entity: MJ_BizApps_Tasks: Task Comments
            100018,
            'Person',
            'Person',
            NULL,
            'nvarchar',
            402,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e7a58455-30f8-4ac9-8d33-3abd1b91cbdc' OR (EntityID = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND Name = 'RootParentID')) BEGIN
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
            'e7a58455-30f8-4ac9-8d33-3abd1b91cbdc',
            'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- Entity: MJ_BizApps_Tasks: Task Comments
            100019,
            'RootParentID',
            'Root Parent ID',
            NULL,
            'uniqueidentifier',
            16,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fd3035a9-13ab-40d2-941a-8e1178b4a797' OR (EntityID = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND Name = 'Task')) BEGIN
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
            'fd3035a9-13ab-40d2-941a-8e1178b4a797',
            'DF98E700-1992-442B-B93E-E47379F2CA52', -- Entity: MJ_BizApps_Tasks: Task Assignments
            100023,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3edfbafc-eada-4557-bb45-81127ea36254' OR (EntityID = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND Name = 'AssigneeEntity')) BEGIN
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
            '3edfbafc-eada-4557-bb45-81127ea36254',
            'DF98E700-1992-442B-B93E-E47379F2CA52', -- Entity: MJ_BizApps_Tasks: Task Assignments
            100024,
            'AssigneeEntity',
            'Assignee Entity',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '64c83f45-894f-43a0-aab1-5aa13f615813' OR (EntityID = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND Name = 'Role')) BEGIN
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
            '64c83f45-894f-43a0-aab1-5aa13f615813',
            'DF98E700-1992-442B-B93E-E47379F2CA52', -- Entity: MJ_BizApps_Tasks: Task Assignments
            100025,
            'Role',
            'Role',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1fd8bfab-20de-4ef1-8743-fca5eb95e28e' OR (EntityID = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND Name = 'AssignedByPerson')) BEGIN
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
            '1fd8bfab-20de-4ef1-8743-fca5eb95e28e',
            'DF98E700-1992-442B-B93E-E47379F2CA52', -- Entity: MJ_BizApps_Tasks: Task Assignments
            100026,
            'AssignedByPerson',
            'Assigned By Person',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a058e354-34aa-40ac-938f-80350d35bd96' OR (EntityID = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND Name = 'Parent')) BEGIN
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
            'a058e354-34aa-40ac-938f-80350d35bd96',
            '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- Entity: MJ_BizApps_Tasks: Task Categories
            100019,
            'Parent',
            'Parent',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '75a44757-69a9-4333-8e3e-5f4708bb0ce8' OR (EntityID = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND Name = 'RootParentID')) BEGIN
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
            '75a44757-69a9-4333-8e3e-5f4708bb0ce8',
            '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- Entity: MJ_BizApps_Tasks: Task Categories
            100020,
            'RootParentID',
            'Root Parent ID',
            NULL,
            'uniqueidentifier',
            16,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5e003cc8-55fc-4401-a7d9-7687be6bd753' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'Type')) BEGIN
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
            '5e003cc8-55fc-4401-a7d9-7687be6bd753',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            100043,
            'Type',
            'Type',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '411b26c4-2aec-41eb-96c1-897c92770598' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'Category')) BEGIN
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
            '411b26c4-2aec-41eb-96c1-897c92770598',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            100044,
            'Category',
            'Category',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '16bea5bd-358f-4e40-ab62-09be3478345f' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'Parent')) BEGIN
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
            '16bea5bd-358f-4e40-ab62-09be3478345f',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            100045,
            'Parent',
            'Parent',
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

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4ee84219-d7cb-408f-8ead-410973b487af' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'CreatedByPerson')) BEGIN
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
            '4ee84219-d7cb-408f-8ead-410973b487af',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            100046,
            'CreatedByPerson',
            'Created By Person',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3205c212-1737-4748-b232-3a64abd3c93c' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'RootParentID')) BEGIN
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
            '3205c212-1737-4748-b232-3a64abd3c93c',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            100047,
            'RootParentID',
            'Root Parent ID',
            NULL,
            'uniqueidentifier',
            16,
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

/* SQL text to update existing entity fields from schema (17 scoped entities) */
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon', @EntityIDs='559054C2-8F03-4A66-B4FD-70DE5948ACE2,DF98E700-1992-442B-B93E-E47379F2CA52,B92E802C-5C1B-486D-B021-03E47069502C,0662FC0F-3F2B-49C9-9BE8-5B59E036044A,5DB17493-CD0A-4633-80D4-D4A499662C76,EA953D6B-524E-4A09-A842-9A0B0F1F850C,B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865,802AEF11-BFE2-4B46-98B2-5FEBD4E35923,A28FDD91-D380-427E-B374-BCEC56ED75B7,8A30F14C-26FF-476E-8CA1-B10EAD29A428,ABFCFE68-F3AA-4401-A547-0FC01F27E3F3,6615EF77-83F1-49F1-B717-80EC31F77486,A210AF26-629A-4E0A-A90A-1CCE33F5D095,DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4,1E30141A-826F-4278-BAA9-BBE14D29E606,06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6,B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='sys,staging,dbo,${mjSchema},${mjSchema}_BizAppsCommon';

