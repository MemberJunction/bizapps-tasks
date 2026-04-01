/* SQL generated to create new entity Task Tag Links */

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
         '5fd9d0c5-a8f6-46a4-bd3c-35284b9757dd',
         'Task Tag Links',
         NULL,
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
   

/* SQL generated to create new application ${flyway:defaultSchema}_BizAppsTasks */
INSERT INTO [${flyway:defaultSchema}].[Application] (ID, Name, Description, SchemaAutoAddNewEntities, Path, AutoUpdatePath)
                       VALUES ('05aefe9d-4ea7-426f-a00a-7dffcaea3f95', '${flyway:defaultSchema}_BizAppsTasks', 'Generated for schema', '${flyway:defaultSchema}_BizAppsTasks', 'mjbizappstasks', 1)

/* SQL generated to add new entity Task Tag Links to application ID: '05aefe9d-4ea7-426f-a00a-7dffcaea3f95' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('05aefe9d-4ea7-426f-a00a-7dffcaea3f95', '5fd9d0c5-a8f6-46a4-bd3c-35284b9757dd', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '05aefe9d-4ea7-426f-a00a-7dffcaea3f95'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Tag Links for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('5fd9d0c5-a8f6-46a4-bd3c-35284b9757dd', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Tag Links for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('5fd9d0c5-a8f6-46a4-bd3c-35284b9757dd', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Tag Links for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('5fd9d0c5-a8f6-46a4-bd3c-35284b9757dd', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity Task Comments */

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
         '6f128578-52cb-4beb-b433-e2e92e68c7e0',
         'Task Comments',
         NULL,
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
   

/* SQL generated to add new entity Task Comments to application ID: '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95', '6f128578-52cb-4beb-b433-e2e92e68c7e0', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Comments for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('6f128578-52cb-4beb-b433-e2e92e68c7e0', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Comments for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('6f128578-52cb-4beb-b433-e2e92e68c7e0', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Comments for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('6f128578-52cb-4beb-b433-e2e92e68c7e0', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity Task Templates */

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
         '76ad5dcb-1637-4e9d-86cb-076cc831426d',
         'Task Templates',
         NULL,
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
   

/* SQL generated to add new entity Task Templates to application ID: '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95', '76ad5dcb-1637-4e9d-86cb-076cc831426d', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Templates for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('76ad5dcb-1637-4e9d-86cb-076cc831426d', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Templates for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('76ad5dcb-1637-4e9d-86cb-076cc831426d', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Templates for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('76ad5dcb-1637-4e9d-86cb-076cc831426d', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity Task Template Items */

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
         '7467a8ce-0f48-4c34-aa00-720357dcadd8',
         'Task Template Items',
         NULL,
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
   

/* SQL generated to add new entity Task Template Items to application ID: '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95', '7467a8ce-0f48-4c34-aa00-720357dcadd8', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Template Items for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('7467a8ce-0f48-4c34-aa00-720357dcadd8', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Template Items for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('7467a8ce-0f48-4c34-aa00-720357dcadd8', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Template Items for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('7467a8ce-0f48-4c34-aa00-720357dcadd8', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity Task Template Item Dependencies */

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
         'c8c707bb-35e8-4161-95db-9fadfb114014',
         'Task Template Item Dependencies',
         NULL,
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
   

/* SQL generated to add new entity Task Template Item Dependencies to application ID: '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95', 'c8c707bb-35e8-4161-95db-9fadfb114014', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Template Item Dependencies for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('c8c707bb-35e8-4161-95db-9fadfb114014', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Template Item Dependencies for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('c8c707bb-35e8-4161-95db-9fadfb114014', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Template Item Dependencies for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('c8c707bb-35e8-4161-95db-9fadfb114014', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity Task Template Item Roles */

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
         '42cc66f2-213d-4111-8d34-76cca2e31ee4',
         'Task Template Item Roles',
         NULL,
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
   

/* SQL generated to add new entity Task Template Item Roles to application ID: '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95', '42cc66f2-213d-4111-8d34-76cca2e31ee4', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Template Item Roles for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('42cc66f2-213d-4111-8d34-76cca2e31ee4', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Template Item Roles for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('42cc66f2-213d-4111-8d34-76cca2e31ee4', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Template Item Roles for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('42cc66f2-213d-4111-8d34-76cca2e31ee4', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity Task Types */

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
         '32db6788-4de2-4dc2-a058-b9a6baf30270',
         'Task Types',
         NULL,
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
   

/* SQL generated to add new entity Task Types to application ID: '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95', '32db6788-4de2-4dc2-a058-b9a6baf30270', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Types for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('32db6788-4de2-4dc2-a058-b9a6baf30270', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Types for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('32db6788-4de2-4dc2-a058-b9a6baf30270', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Types for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('32db6788-4de2-4dc2-a058-b9a6baf30270', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity Task Activities */

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
         '6ab1f963-429d-4a9e-ad4f-fb525041c356',
         'Task Activities',
         NULL,
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
   

/* SQL generated to add new entity Task Activities to application ID: '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95', '6ab1f963-429d-4a9e-ad4f-fb525041c356', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Activities for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('6ab1f963-429d-4a9e-ad4f-fb525041c356', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Activities for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('6ab1f963-429d-4a9e-ad4f-fb525041c356', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Activities for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('6ab1f963-429d-4a9e-ad4f-fb525041c356', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity Task Categories */

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
         '1cf2a425-d7ac-4d63-a27b-b69065fe9a4a',
         'Task Categories',
         NULL,
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
   

/* SQL generated to add new entity Task Categories to application ID: '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95', '1cf2a425-d7ac-4d63-a27b-b69065fe9a4a', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Categories for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('1cf2a425-d7ac-4d63-a27b-b69065fe9a4a', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Categories for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('1cf2a425-d7ac-4d63-a27b-b69065fe9a4a', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Categories for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('1cf2a425-d7ac-4d63-a27b-b69065fe9a4a', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity Tasks */

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
         '00a658f4-3884-4b70-a009-fb8a27617a95',
         'Tasks',
         NULL,
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
   

/* SQL generated to add new entity Tasks to application ID: '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95', '00a658f4-3884-4b70-a009-fb8a27617a95', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Tasks for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('00a658f4-3884-4b70-a009-fb8a27617a95', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Tasks for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('00a658f4-3884-4b70-a009-fb8a27617a95', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Tasks for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('00a658f4-3884-4b70-a009-fb8a27617a95', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity Task Roles */

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
         'b5187e17-08f0-4491-86cf-a87eeccedd79',
         'Task Roles',
         NULL,
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
   

/* SQL generated to add new entity Task Roles to application ID: '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95', 'b5187e17-08f0-4491-86cf-a87eeccedd79', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Roles for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('b5187e17-08f0-4491-86cf-a87eeccedd79', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Roles for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('b5187e17-08f0-4491-86cf-a87eeccedd79', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Roles for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('b5187e17-08f0-4491-86cf-a87eeccedd79', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity Task Assignments */

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
         'c878b295-7259-4407-9251-b63721eea41c',
         'Task Assignments',
         NULL,
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
   

/* SQL generated to add new entity Task Assignments to application ID: '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95', 'c878b295-7259-4407-9251-b63721eea41c', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Assignments for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('c878b295-7259-4407-9251-b63721eea41c', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Assignments for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('c878b295-7259-4407-9251-b63721eea41c', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Assignments for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('c878b295-7259-4407-9251-b63721eea41c', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity Task Links */

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
         'f108563e-3a8f-4aa3-a3ec-c14dd05a0ad8',
         'Task Links',
         NULL,
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
   

/* SQL generated to add new entity Task Links to application ID: '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95', 'f108563e-3a8f-4aa3-a3ec-c14dd05a0ad8', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Links for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('f108563e-3a8f-4aa3-a3ec-c14dd05a0ad8', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Links for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('f108563e-3a8f-4aa3-a3ec-c14dd05a0ad8', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Links for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('f108563e-3a8f-4aa3-a3ec-c14dd05a0ad8', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity Task Dependencies */

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
         'eabe2ed5-f60b-40cf-a6c3-997337031c13',
         'Task Dependencies',
         NULL,
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
   

/* SQL generated to add new entity Task Dependencies to application ID: '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95', 'eabe2ed5-f60b-40cf-a6c3-997337031c13', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Dependencies for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('eabe2ed5-f60b-40cf-a6c3-997337031c13', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Dependencies for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('eabe2ed5-f60b-40cf-a6c3-997337031c13', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Dependencies for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('eabe2ed5-f60b-40cf-a6c3-997337031c13', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL generated to create new entity Task Tags */

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
         '2201fa6f-98f2-4d33-8813-04304095148b',
         'Task Tags',
         NULL,
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
   

/* SQL generated to add new entity Task Tags to application ID: '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95', '2201fa6f-98f2-4d33-8813-04304095148b', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '05AEFE9D-4EA7-426F-A00A-7DFFCAEA3F95'), GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Tags for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('2201fa6f-98f2-4d33-8813-04304095148b', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Tags for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('2201fa6f-98f2-4d33-8813-04304095148b', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 0, GETUTCDATE(), GETUTCDATE())

/* SQL generated to add new permission for entity Task Tags for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('2201fa6f-98f2-4d33-8813-04304095148b', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE())

/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ab44775a-efc3-4dad-9518-a67e4c94732a' OR (EntityID = '2201FA6F-98F2-4D33-8813-04304095148B' AND Name = 'ID')) BEGIN
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
            'ab44775a-efc3-4dad-9518-a67e4c94732a',
            '2201FA6F-98F2-4D33-8813-04304095148B', -- Entity: Task Tags
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c6c26299-4efa-4984-aa17-5a3a3ab400e5' OR (EntityID = '2201FA6F-98F2-4D33-8813-04304095148B' AND Name = 'Name')) BEGIN
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
            'c6c26299-4efa-4984-aa17-5a3a3ab400e5',
            '2201FA6F-98F2-4D33-8813-04304095148B', -- Entity: Task Tags
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2f64deb7-04fc-4dff-bdc8-b3faf7e466e9' OR (EntityID = '2201FA6F-98F2-4D33-8813-04304095148B' AND Name = 'ColorCode')) BEGIN
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
            '2f64deb7-04fc-4dff-bdc8-b3faf7e466e9',
            '2201FA6F-98F2-4D33-8813-04304095148B', -- Entity: Task Tags
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b966bac6-53bd-48b2-863e-839b96cc78fa' OR (EntityID = '2201FA6F-98F2-4D33-8813-04304095148B' AND Name = 'Description')) BEGIN
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
            'b966bac6-53bd-48b2-863e-839b96cc78fa',
            '2201FA6F-98F2-4D33-8813-04304095148B', -- Entity: Task Tags
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e32a5b87-96db-484e-a5ba-076966e79afe' OR (EntityID = '2201FA6F-98F2-4D33-8813-04304095148B' AND Name = '__mj_CreatedAt')) BEGIN
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
            'e32a5b87-96db-484e-a5ba-076966e79afe',
            '2201FA6F-98F2-4D33-8813-04304095148B', -- Entity: Task Tags
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f6f6d754-45f5-4a8e-83d9-3ce4737b3035' OR (EntityID = '2201FA6F-98F2-4D33-8813-04304095148B' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'f6f6d754-45f5-4a8e-83d9-3ce4737b3035',
            '2201FA6F-98F2-4D33-8813-04304095148B', -- Entity: Task Tags
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '410ad64c-4816-4982-b81d-f1a1f72824fb' OR (EntityID = '76AD5DCB-1637-4E9D-86CB-076CC831426D' AND Name = 'ID')) BEGIN
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
            '410ad64c-4816-4982-b81d-f1a1f72824fb',
            '76AD5DCB-1637-4E9D-86CB-076CC831426D', -- Entity: Task Templates
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bee11d9c-63c4-41e5-80b6-6b3f4e9e506f' OR (EntityID = '76AD5DCB-1637-4E9D-86CB-076CC831426D' AND Name = 'Name')) BEGIN
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
            'bee11d9c-63c4-41e5-80b6-6b3f4e9e506f',
            '76AD5DCB-1637-4E9D-86CB-076CC831426D', -- Entity: Task Templates
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4ebb1080-a49e-4688-83fc-2246b5632dc3' OR (EntityID = '76AD5DCB-1637-4E9D-86CB-076CC831426D' AND Name = 'Description')) BEGIN
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
            '4ebb1080-a49e-4688-83fc-2246b5632dc3',
            '76AD5DCB-1637-4E9D-86CB-076CC831426D', -- Entity: Task Templates
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4e3f3c17-ea3d-474e-aadd-a4b7ca2f4a7e' OR (EntityID = '76AD5DCB-1637-4E9D-86CB-076CC831426D' AND Name = 'CategoryID')) BEGIN
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
            '4e3f3c17-ea3d-474e-aadd-a4b7ca2f4a7e',
            '76AD5DCB-1637-4E9D-86CB-076CC831426D', -- Entity: Task Templates
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
            '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'fab985b5-03c5-43af-a7ce-cceaeb02ed82' OR (EntityID = '76AD5DCB-1637-4E9D-86CB-076CC831426D' AND Name = 'TypeID')) BEGIN
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
            'fab985b5-03c5-43af-a7ce-cceaeb02ed82',
            '76AD5DCB-1637-4E9D-86CB-076CC831426D', -- Entity: Task Templates
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
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '38be714a-0f53-4284-91d1-ef987de7d622' OR (EntityID = '76AD5DCB-1637-4E9D-86CB-076CC831426D' AND Name = 'IsActive')) BEGIN
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
            '38be714a-0f53-4284-91d1-ef987de7d622',
            '76AD5DCB-1637-4E9D-86CB-076CC831426D', -- Entity: Task Templates
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '78356956-ec69-4d16-bb3d-accb75ef4993' OR (EntityID = '76AD5DCB-1637-4E9D-86CB-076CC831426D' AND Name = '__mj_CreatedAt')) BEGIN
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
            '78356956-ec69-4d16-bb3d-accb75ef4993',
            '76AD5DCB-1637-4E9D-86CB-076CC831426D', -- Entity: Task Templates
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e7789998-791f-4515-8a21-88676a787d1d' OR (EntityID = '76AD5DCB-1637-4E9D-86CB-076CC831426D' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'e7789998-791f-4515-8a21-88676a787d1d',
            '76AD5DCB-1637-4E9D-86CB-076CC831426D', -- Entity: Task Templates
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '993801cb-a207-472c-b22c-8c601c093c98' OR (EntityID = '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD' AND Name = 'ID')) BEGIN
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
            '993801cb-a207-472c-b22c-8c601c093c98',
            '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD', -- Entity: Task Tag Links
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5a9282d5-395d-457e-81fc-bda9acce5431' OR (EntityID = '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD' AND Name = 'TaskID')) BEGIN
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
            '5a9282d5-395d-457e-81fc-bda9acce5431',
            '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD', -- Entity: Task Tag Links
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
            '00A658F4-3884-4B70-A009-FB8A27617A95',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1d40c317-6680-4446-a87d-51e4eb65bd6c' OR (EntityID = '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD' AND Name = 'TagID')) BEGIN
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
            '1d40c317-6680-4446-a87d-51e4eb65bd6c',
            '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD', -- Entity: Task Tag Links
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
            '2201FA6F-98F2-4D33-8813-04304095148B',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6869aea0-cdd6-4928-9505-a18319a7a709' OR (EntityID = '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD' AND Name = '__mj_CreatedAt')) BEGIN
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
            '6869aea0-cdd6-4928-9505-a18319a7a709',
            '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD', -- Entity: Task Tag Links
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '892c9dde-a167-488a-b172-5a2802e78783' OR (EntityID = '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '892c9dde-a167-488a-b172-5a2802e78783',
            '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD', -- Entity: Task Tag Links
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8cd21c6e-65c7-4478-a088-7f0fbed6afe0' OR (EntityID = '7467A8CE-0F48-4C34-AA00-720357DCADD8' AND Name = 'ID')) BEGIN
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
            '8cd21c6e-65c7-4478-a088-7f0fbed6afe0',
            '7467A8CE-0F48-4C34-AA00-720357DCADD8', -- Entity: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '53a0637e-130c-44ef-ab25-0a6db2a2fba7' OR (EntityID = '7467A8CE-0F48-4C34-AA00-720357DCADD8' AND Name = 'TemplateID')) BEGIN
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
            '53a0637e-130c-44ef-ab25-0a6db2a2fba7',
            '7467A8CE-0F48-4C34-AA00-720357DCADD8', -- Entity: Task Template Items
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
            '76AD5DCB-1637-4E9D-86CB-076CC831426D',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f48db2b2-3d7b-4810-bbdd-17f241785bc1' OR (EntityID = '7467A8CE-0F48-4C34-AA00-720357DCADD8' AND Name = 'Name')) BEGIN
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
            'f48db2b2-3d7b-4810-bbdd-17f241785bc1',
            '7467A8CE-0F48-4C34-AA00-720357DCADD8', -- Entity: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b07378f4-457d-41bc-a4b2-6f79825a4428' OR (EntityID = '7467A8CE-0F48-4C34-AA00-720357DCADD8' AND Name = 'Description')) BEGIN
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
            'b07378f4-457d-41bc-a4b2-6f79825a4428',
            '7467A8CE-0F48-4C34-AA00-720357DCADD8', -- Entity: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5cb8cbe5-b4c0-4204-a7ad-079b0b2b9439' OR (EntityID = '7467A8CE-0F48-4C34-AA00-720357DCADD8' AND Name = 'ParentItemID')) BEGIN
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
            '5cb8cbe5-b4c0-4204-a7ad-079b0b2b9439',
            '7467A8CE-0F48-4C34-AA00-720357DCADD8', -- Entity: Task Template Items
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
            '7467A8CE-0F48-4C34-AA00-720357DCADD8',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8f8b98d4-a99a-4e78-ba98-a961b7386004' OR (EntityID = '7467A8CE-0F48-4C34-AA00-720357DCADD8' AND Name = 'Priority')) BEGIN
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
            '8f8b98d4-a99a-4e78-ba98-a961b7386004',
            '7467A8CE-0F48-4C34-AA00-720357DCADD8', -- Entity: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ff760ed1-9f8a-40c7-be4f-c2be1780a236' OR (EntityID = '7467A8CE-0F48-4C34-AA00-720357DCADD8' AND Name = 'DaysFromStart')) BEGIN
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
            'ff760ed1-9f8a-40c7-be4f-c2be1780a236',
            '7467A8CE-0F48-4C34-AA00-720357DCADD8', -- Entity: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7f002506-82ed-4f8a-bf39-e554cdc7e370' OR (EntityID = '7467A8CE-0F48-4C34-AA00-720357DCADD8' AND Name = 'HoursEstimated')) BEGIN
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
            '7f002506-82ed-4f8a-bf39-e554cdc7e370',
            '7467A8CE-0F48-4C34-AA00-720357DCADD8', -- Entity: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '72e97f67-acf9-4b95-bbc1-d4e813ff955c' OR (EntityID = '7467A8CE-0F48-4C34-AA00-720357DCADD8' AND Name = 'Sequence')) BEGIN
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
            '72e97f67-acf9-4b95-bbc1-d4e813ff955c',
            '7467A8CE-0F48-4C34-AA00-720357DCADD8', -- Entity: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bef470c3-147d-4cdf-9c9f-7ed1a022891c' OR (EntityID = '7467A8CE-0F48-4C34-AA00-720357DCADD8' AND Name = '__mj_CreatedAt')) BEGIN
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
            'bef470c3-147d-4cdf-9c9f-7ed1a022891c',
            '7467A8CE-0F48-4C34-AA00-720357DCADD8', -- Entity: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2568fa98-c78e-4178-912a-19844e89fa3c' OR (EntityID = '7467A8CE-0F48-4C34-AA00-720357DCADD8' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '2568fa98-c78e-4178-912a-19844e89fa3c',
            '7467A8CE-0F48-4C34-AA00-720357DCADD8', -- Entity: Task Template Items
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '55fe673a-7626-4d41-9b9a-af82bfb25ed4' OR (EntityID = '42CC66F2-213D-4111-8D34-76CCA2E31EE4' AND Name = 'ID')) BEGIN
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
            '55fe673a-7626-4d41-9b9a-af82bfb25ed4',
            '42CC66F2-213D-4111-8D34-76CCA2E31EE4', -- Entity: Task Template Item Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '166d3ec8-de6f-4884-850d-50895c75ee75' OR (EntityID = '42CC66F2-213D-4111-8D34-76CCA2E31EE4' AND Name = 'ItemID')) BEGIN
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
            '166d3ec8-de6f-4884-850d-50895c75ee75',
            '42CC66F2-213D-4111-8D34-76CCA2E31EE4', -- Entity: Task Template Item Roles
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
            '7467A8CE-0F48-4C34-AA00-720357DCADD8',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3a8e540e-0b8a-45e8-a8f9-b5e55e0917c8' OR (EntityID = '42CC66F2-213D-4111-8D34-76CCA2E31EE4' AND Name = 'RoleID')) BEGIN
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
            '3a8e540e-0b8a-45e8-a8f9-b5e55e0917c8',
            '42CC66F2-213D-4111-8D34-76CCA2E31EE4', -- Entity: Task Template Item Roles
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
            'B5187E17-08F0-4491-86CF-A87EECCEDD79',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'da863583-5b76-40e2-bca1-3b98b4bd26d6' OR (EntityID = '42CC66F2-213D-4111-8D34-76CCA2E31EE4' AND Name = '__mj_CreatedAt')) BEGIN
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
            'da863583-5b76-40e2-bca1-3b98b4bd26d6',
            '42CC66F2-213D-4111-8D34-76CCA2E31EE4', -- Entity: Task Template Item Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd155a04f-8f2a-4607-9b00-8bba0580a10c' OR (EntityID = '42CC66F2-213D-4111-8D34-76CCA2E31EE4' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'd155a04f-8f2a-4607-9b00-8bba0580a10c',
            '42CC66F2-213D-4111-8D34-76CCA2E31EE4', -- Entity: Task Template Item Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8f4aa548-401a-400a-bda0-6db1950d8ee3' OR (EntityID = 'EABE2ED5-F60B-40CF-A6C3-997337031C13' AND Name = 'ID')) BEGIN
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
            '8f4aa548-401a-400a-bda0-6db1950d8ee3',
            'EABE2ED5-F60B-40CF-A6C3-997337031C13', -- Entity: Task Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '972cf331-dbf8-4780-8fc8-75b27d85452c' OR (EntityID = 'EABE2ED5-F60B-40CF-A6C3-997337031C13' AND Name = 'TaskID')) BEGIN
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
            '972cf331-dbf8-4780-8fc8-75b27d85452c',
            'EABE2ED5-F60B-40CF-A6C3-997337031C13', -- Entity: Task Dependencies
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
            '00A658F4-3884-4B70-A009-FB8A27617A95',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '00410344-351e-4da9-a6e3-6f788e907dd5' OR (EntityID = 'EABE2ED5-F60B-40CF-A6C3-997337031C13' AND Name = 'DependsOnTaskID')) BEGIN
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
            '00410344-351e-4da9-a6e3-6f788e907dd5',
            'EABE2ED5-F60B-40CF-A6C3-997337031C13', -- Entity: Task Dependencies
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
            '00A658F4-3884-4B70-A009-FB8A27617A95',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0501e69c-03fc-4233-97d5-ac36393ac8ba' OR (EntityID = 'EABE2ED5-F60B-40CF-A6C3-997337031C13' AND Name = 'DependencyType')) BEGIN
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
            '0501e69c-03fc-4233-97d5-ac36393ac8ba',
            'EABE2ED5-F60B-40CF-A6C3-997337031C13', -- Entity: Task Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c40861da-5c79-4098-9f18-86ffe8613846' OR (EntityID = 'EABE2ED5-F60B-40CF-A6C3-997337031C13' AND Name = '__mj_CreatedAt')) BEGIN
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
            'c40861da-5c79-4098-9f18-86ffe8613846',
            'EABE2ED5-F60B-40CF-A6C3-997337031C13', -- Entity: Task Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '118928c0-4ed1-4cfc-8e72-b5829d8dfe44' OR (EntityID = 'EABE2ED5-F60B-40CF-A6C3-997337031C13' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '118928c0-4ed1-4cfc-8e72-b5829d8dfe44',
            'EABE2ED5-F60B-40CF-A6C3-997337031C13', -- Entity: Task Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '52000886-794a-44da-b5c1-dbf95f84f8bf' OR (EntityID = 'C8C707BB-35E8-4161-95DB-9FADFB114014' AND Name = 'ID')) BEGIN
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
            '52000886-794a-44da-b5c1-dbf95f84f8bf',
            'C8C707BB-35E8-4161-95DB-9FADFB114014', -- Entity: Task Template Item Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5e58c246-d73c-495c-be9b-01dddb62317b' OR (EntityID = 'C8C707BB-35E8-4161-95DB-9FADFB114014' AND Name = 'ItemID')) BEGIN
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
            '5e58c246-d73c-495c-be9b-01dddb62317b',
            'C8C707BB-35E8-4161-95DB-9FADFB114014', -- Entity: Task Template Item Dependencies
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
            '7467A8CE-0F48-4C34-AA00-720357DCADD8',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '039a33b5-e6bb-4fac-b8c3-fa2353267d4c' OR (EntityID = 'C8C707BB-35E8-4161-95DB-9FADFB114014' AND Name = 'DependsOnItemID')) BEGIN
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
            '039a33b5-e6bb-4fac-b8c3-fa2353267d4c',
            'C8C707BB-35E8-4161-95DB-9FADFB114014', -- Entity: Task Template Item Dependencies
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
            '7467A8CE-0F48-4C34-AA00-720357DCADD8',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5f278987-16fb-4b2d-80f5-e0c7f996c19d' OR (EntityID = 'C8C707BB-35E8-4161-95DB-9FADFB114014' AND Name = 'DependencyType')) BEGIN
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
            '5f278987-16fb-4b2d-80f5-e0c7f996c19d',
            'C8C707BB-35E8-4161-95DB-9FADFB114014', -- Entity: Task Template Item Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7cfd2808-7945-449f-9cfe-e7e6d29d7cf8' OR (EntityID = 'C8C707BB-35E8-4161-95DB-9FADFB114014' AND Name = '__mj_CreatedAt')) BEGIN
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
            '7cfd2808-7945-449f-9cfe-e7e6d29d7cf8',
            'C8C707BB-35E8-4161-95DB-9FADFB114014', -- Entity: Task Template Item Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd9be038e-9e1b-4d92-ab31-ee431c7fe69e' OR (EntityID = 'C8C707BB-35E8-4161-95DB-9FADFB114014' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'd9be038e-9e1b-4d92-ab31-ee431c7fe69e',
            'C8C707BB-35E8-4161-95DB-9FADFB114014', -- Entity: Task Template Item Dependencies
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ee281c51-1652-40de-a796-60177a3bd071' OR (EntityID = 'B5187E17-08F0-4491-86CF-A87EECCEDD79' AND Name = 'ID')) BEGIN
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
            'ee281c51-1652-40de-a796-60177a3bd071',
            'B5187E17-08F0-4491-86CF-A87EECCEDD79', -- Entity: Task Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f529f815-aa75-4d1d-8496-04a41b54d6dd' OR (EntityID = 'B5187E17-08F0-4491-86CF-A87EECCEDD79' AND Name = 'Name')) BEGIN
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
            'f529f815-aa75-4d1d-8496-04a41b54d6dd',
            'B5187E17-08F0-4491-86CF-A87EECCEDD79', -- Entity: Task Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8b8a0616-a4e3-447b-9472-f1b3836026e0' OR (EntityID = 'B5187E17-08F0-4491-86CF-A87EECCEDD79' AND Name = 'Description')) BEGIN
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
            '8b8a0616-a4e3-447b-9472-f1b3836026e0',
            'B5187E17-08F0-4491-86CF-A87EECCEDD79', -- Entity: Task Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b12cc903-e021-41b8-9f22-cbff9e8f7dbd' OR (EntityID = 'B5187E17-08F0-4491-86CF-A87EECCEDD79' AND Name = 'Sequence')) BEGIN
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
            'b12cc903-e021-41b8-9f22-cbff9e8f7dbd',
            'B5187E17-08F0-4491-86CF-A87EECCEDD79', -- Entity: Task Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '588eea3e-f48b-4483-8b93-4be663d0c126' OR (EntityID = 'B5187E17-08F0-4491-86CF-A87EECCEDD79' AND Name = '__mj_CreatedAt')) BEGIN
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
            '588eea3e-f48b-4483-8b93-4be663d0c126',
            'B5187E17-08F0-4491-86CF-A87EECCEDD79', -- Entity: Task Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '58db8e73-3904-485d-b806-27f59c806bde' OR (EntityID = 'B5187E17-08F0-4491-86CF-A87EECCEDD79' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '58db8e73-3904-485d-b806-27f59c806bde',
            'B5187E17-08F0-4491-86CF-A87EECCEDD79', -- Entity: Task Roles
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e613205c-7548-4458-9627-7c86a0b73879' OR (EntityID = 'C878B295-7259-4407-9251-B63721EEA41C' AND Name = 'ID')) BEGIN
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
            'e613205c-7548-4458-9627-7c86a0b73879',
            'C878B295-7259-4407-9251-B63721EEA41C', -- Entity: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '26eddb1f-9e94-4cc0-95fc-f8ab1154ddb1' OR (EntityID = 'C878B295-7259-4407-9251-B63721EEA41C' AND Name = 'TaskID')) BEGIN
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
            '26eddb1f-9e94-4cc0-95fc-f8ab1154ddb1',
            'C878B295-7259-4407-9251-B63721EEA41C', -- Entity: Task Assignments
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
            '00A658F4-3884-4B70-A009-FB8A27617A95',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '914c389b-2a69-4de8-88bf-23d1b8d6004c' OR (EntityID = 'C878B295-7259-4407-9251-B63721EEA41C' AND Name = 'AssigneeEntityID')) BEGIN
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
            '914c389b-2a69-4de8-88bf-23d1b8d6004c',
            'C878B295-7259-4407-9251-B63721EEA41C', -- Entity: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9e9eb0ab-6610-4720-a672-1ddc981c41ec' OR (EntityID = 'C878B295-7259-4407-9251-B63721EEA41C' AND Name = 'AssigneeRecordID')) BEGIN
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
            '9e9eb0ab-6610-4720-a672-1ddc981c41ec',
            'C878B295-7259-4407-9251-B63721EEA41C', -- Entity: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ac0ebcee-2fb2-43eb-bfbc-cf999948fa9a' OR (EntityID = 'C878B295-7259-4407-9251-B63721EEA41C' AND Name = 'RoleID')) BEGIN
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
            'ac0ebcee-2fb2-43eb-bfbc-cf999948fa9a',
            'C878B295-7259-4407-9251-B63721EEA41C', -- Entity: Task Assignments
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
            'B5187E17-08F0-4491-86CF-A87EECCEDD79',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a692bc51-747e-4383-b1c6-59f833a6e4c9' OR (EntityID = 'C878B295-7259-4407-9251-B63721EEA41C' AND Name = 'RoleNotes')) BEGIN
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
            'a692bc51-747e-4383-b1c6-59f833a6e4c9',
            'C878B295-7259-4407-9251-B63721EEA41C', -- Entity: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3a7114da-3781-4dab-9a49-54eb3800b13a' OR (EntityID = 'C878B295-7259-4407-9251-B63721EEA41C' AND Name = 'Status')) BEGIN
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
            '3a7114da-3781-4dab-9a49-54eb3800b13a',
            'C878B295-7259-4407-9251-B63721EEA41C', -- Entity: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '16aeaa2f-9d60-47e3-919c-4f57a0d74498' OR (EntityID = 'C878B295-7259-4407-9251-B63721EEA41C' AND Name = 'AssignedByPersonID')) BEGIN
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
            '16aeaa2f-9d60-47e3-919c-4f57a0d74498',
            'C878B295-7259-4407-9251-B63721EEA41C', -- Entity: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ae73658f-ab82-4f9b-bd7c-0912d1fa6de0' OR (EntityID = 'C878B295-7259-4407-9251-B63721EEA41C' AND Name = 'AssignedAt')) BEGIN
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
            'ae73658f-ab82-4f9b-bd7c-0912d1fa6de0',
            'C878B295-7259-4407-9251-B63721EEA41C', -- Entity: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'efed6320-c76e-40d6-89be-e8db4a3273fd' OR (EntityID = 'C878B295-7259-4407-9251-B63721EEA41C' AND Name = '__mj_CreatedAt')) BEGIN
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
            'efed6320-c76e-40d6-89be-e8db4a3273fd',
            'C878B295-7259-4407-9251-B63721EEA41C', -- Entity: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'de2d1f55-7188-4d1b-af89-34b75c219c30' OR (EntityID = 'C878B295-7259-4407-9251-B63721EEA41C' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'de2d1f55-7188-4d1b-af89-34b75c219c30',
            'C878B295-7259-4407-9251-B63721EEA41C', -- Entity: Task Assignments
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bea40089-d2a7-4374-8ae1-74d8494934d1' OR (EntityID = '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A' AND Name = 'ID')) BEGIN
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
            'bea40089-d2a7-4374-8ae1-74d8494934d1',
            '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A', -- Entity: Task Categories
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ebc2b3c3-c799-4334-9ad7-68177c013e1c' OR (EntityID = '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A' AND Name = 'Name')) BEGIN
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
            'ebc2b3c3-c799-4334-9ad7-68177c013e1c',
            '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A', -- Entity: Task Categories
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '88f4d54b-142c-4d6d-b157-73c54d674899' OR (EntityID = '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A' AND Name = 'Description')) BEGIN
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
            '88f4d54b-142c-4d6d-b157-73c54d674899',
            '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A', -- Entity: Task Categories
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'cc847652-a1d2-4e43-a4da-4f86045484a5' OR (EntityID = '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A' AND Name = 'ParentID')) BEGIN
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
            'cc847652-a1d2-4e43-a4da-4f86045484a5',
            '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A', -- Entity: Task Categories
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
            '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '25cb822d-38d1-43c1-b5b0-ecf7a11cb238' OR (EntityID = '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A' AND Name = 'ColorCode')) BEGIN
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
            '25cb822d-38d1-43c1-b5b0-ecf7a11cb238',
            '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A', -- Entity: Task Categories
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3bb58aa2-46bb-4b72-9c04-e62d3ac5504c' OR (EntityID = '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A' AND Name = 'Sequence')) BEGIN
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
            '3bb58aa2-46bb-4b72-9c04-e62d3ac5504c',
            '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A', -- Entity: Task Categories
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '47b6d033-f73b-47e1-af66-fd6f9c27ef53' OR (EntityID = '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A' AND Name = 'IsActive')) BEGIN
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
            '47b6d033-f73b-47e1-af66-fd6f9c27ef53',
            '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A', -- Entity: Task Categories
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a654d406-99ca-4366-80e6-7659fb21b8b8' OR (EntityID = '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A' AND Name = '__mj_CreatedAt')) BEGIN
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
            'a654d406-99ca-4366-80e6-7659fb21b8b8',
            '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A', -- Entity: Task Categories
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '30e41057-73ba-4b4f-9cc2-be12157ef1dd' OR (EntityID = '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '30e41057-73ba-4b4f-9cc2-be12157ef1dd',
            '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A', -- Entity: Task Categories
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e4c14e2b-8016-4c56-b1c0-02e25e0a434c' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = 'ID')) BEGIN
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
            'e4c14e2b-8016-4c56-b1c0-02e25e0a434c',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '447ac2b7-0d1c-42a1-9f42-b2786d3de00f' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = 'Name')) BEGIN
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
            '447ac2b7-0d1c-42a1-9f42-b2786d3de00f',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '421911df-88af-4933-ae2c-1aedfe9a53d3' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = 'Description')) BEGIN
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
            '421911df-88af-4933-ae2c-1aedfe9a53d3',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9339c881-6887-4a85-b35e-5a4bd6cbcc95' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = 'IconClass')) BEGIN
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
            '9339c881-6887-4a85-b35e-5a4bd6cbcc95',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ff1a5f7c-6a07-45c3-a369-465ac5097d2d' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = 'DefaultPriority')) BEGIN
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
            'ff1a5f7c-6a07-45c3-a369-465ac5097d2d',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7bc2015b-8a82-4a4b-a6c7-d00e20075c2d' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = 'OnAssignActionID')) BEGIN
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
            '7bc2015b-8a82-4a4b-a6c7-d00e20075c2d',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '109e5e1a-ca5d-4936-b1e8-a5d22940449b' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = 'OnCompleteActionID')) BEGIN
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
            '109e5e1a-ca5d-4936-b1e8-a5d22940449b',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7145e8d1-1d33-4c45-bab6-f4f0a2f4333b' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = 'OnOverdueActionID')) BEGIN
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
            '7145e8d1-1d33-4c45-bab6-f4f0a2f4333b',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0bb44728-6647-47de-850c-192e44bcd8a0' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = 'OnPercentChangeActionID')) BEGIN
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
            '0bb44728-6647-47de-850c-192e44bcd8a0',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bd93fabf-3dda-4f4b-939e-7ce9600b98c1' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = 'IsActive')) BEGIN
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
            'bd93fabf-3dda-4f4b-939e-7ce9600b98c1',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c6f779e2-0eb2-4700-b2f6-95f6fbab56ff' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = '__mj_CreatedAt')) BEGIN
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
            'c6f779e2-0eb2-4700-b2f6-95f6fbab56ff',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '88d97057-c407-4ca3-84fe-0c2b9920980f' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '88d97057-c407-4ca3-84fe-0c2b9920980f',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a50783e7-ae13-4836-8e0b-a6fdda5e68f2' OR (EntityID = 'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8' AND Name = 'ID')) BEGIN
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
            'a50783e7-ae13-4836-8e0b-a6fdda5e68f2',
            'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8', -- Entity: Task Links
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'cb802a22-f9ac-4465-aa7a-2a12025eed04' OR (EntityID = 'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8' AND Name = 'TaskID')) BEGIN
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
            'cb802a22-f9ac-4465-aa7a-2a12025eed04',
            'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8', -- Entity: Task Links
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
            '00A658F4-3884-4B70-A009-FB8A27617A95',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '97069112-53a9-4fbf-b1ec-c9876d85ad9f' OR (EntityID = 'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8' AND Name = 'EntityID')) BEGIN
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
            '97069112-53a9-4fbf-b1ec-c9876d85ad9f',
            'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8', -- Entity: Task Links
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ac8f9d4e-f855-4a18-8809-30282d45f464' OR (EntityID = 'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8' AND Name = 'RecordID')) BEGIN
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
            'ac8f9d4e-f855-4a18-8809-30282d45f464',
            'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8', -- Entity: Task Links
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '779a032c-4c3f-4170-91c1-58c531edc858' OR (EntityID = 'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8' AND Name = 'Description')) BEGIN
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
            '779a032c-4c3f-4170-91c1-58c531edc858',
            'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8', -- Entity: Task Links
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e89c9a6d-8bfe-4ea1-8d05-1f138fa3485d' OR (EntityID = 'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8' AND Name = '__mj_CreatedAt')) BEGIN
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
            'e89c9a6d-8bfe-4ea1-8d05-1f138fa3485d',
            'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8', -- Entity: Task Links
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1889563d-20dc-44d4-b49b-3290ad3bc871' OR (EntityID = 'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '1889563d-20dc-44d4-b49b-3290ad3bc871',
            'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8', -- Entity: Task Links
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a27a7516-04bc-48fb-8d5f-f18b40108f49' OR (EntityID = '6F128578-52CB-4BEB-B433-E2E92E68C7E0' AND Name = 'ID')) BEGIN
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
            'a27a7516-04bc-48fb-8d5f-f18b40108f49',
            '6F128578-52CB-4BEB-B433-E2E92E68C7E0', -- Entity: Task Comments
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7fdbb1d8-9aa2-4274-941f-109959c341f0' OR (EntityID = '6F128578-52CB-4BEB-B433-E2E92E68C7E0' AND Name = 'TaskID')) BEGIN
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
            '7fdbb1d8-9aa2-4274-941f-109959c341f0',
            '6F128578-52CB-4BEB-B433-E2E92E68C7E0', -- Entity: Task Comments
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
            '00A658F4-3884-4B70-A009-FB8A27617A95',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6c7a0fe0-e0aa-439b-b62b-8fd7aad583e0' OR (EntityID = '6F128578-52CB-4BEB-B433-E2E92E68C7E0' AND Name = 'ParentID')) BEGIN
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
            '6c7a0fe0-e0aa-439b-b62b-8fd7aad583e0',
            '6F128578-52CB-4BEB-B433-E2E92E68C7E0', -- Entity: Task Comments
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
            '6F128578-52CB-4BEB-B433-E2E92E68C7E0',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2270e77a-23f4-4020-ba93-f52d57c74499' OR (EntityID = '6F128578-52CB-4BEB-B433-E2E92E68C7E0' AND Name = 'PersonID')) BEGIN
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
            '2270e77a-23f4-4020-ba93-f52d57c74499',
            '6F128578-52CB-4BEB-B433-E2E92E68C7E0', -- Entity: Task Comments
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5a2f8514-f554-43bf-ba6e-4758bf0cb977' OR (EntityID = '6F128578-52CB-4BEB-B433-E2E92E68C7E0' AND Name = 'Content')) BEGIN
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
            '5a2f8514-f554-43bf-ba6e-4758bf0cb977',
            '6F128578-52CB-4BEB-B433-E2E92E68C7E0', -- Entity: Task Comments
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5802fee0-2410-4572-ae33-8d02c477347d' OR (EntityID = '6F128578-52CB-4BEB-B433-E2E92E68C7E0' AND Name = 'IsEdited')) BEGIN
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
            '5802fee0-2410-4572-ae33-8d02c477347d',
            '6F128578-52CB-4BEB-B433-E2E92E68C7E0', -- Entity: Task Comments
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7dd4b261-7af7-4c9e-ac48-8297c58f3b15' OR (EntityID = '6F128578-52CB-4BEB-B433-E2E92E68C7E0' AND Name = '__mj_CreatedAt')) BEGIN
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
            '7dd4b261-7af7-4c9e-ac48-8297c58f3b15',
            '6F128578-52CB-4BEB-B433-E2E92E68C7E0', -- Entity: Task Comments
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'de636e1a-7d5c-46c6-9c76-95e54d1ab51a' OR (EntityID = '6F128578-52CB-4BEB-B433-E2E92E68C7E0' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'de636e1a-7d5c-46c6-9c76-95e54d1ab51a',
            '6F128578-52CB-4BEB-B433-E2E92E68C7E0', -- Entity: Task Comments
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4b71c0a8-7c4f-4d7c-83b0-b60b1fd5d7db' OR (EntityID = '6AB1F963-429D-4A9E-AD4F-FB525041C356' AND Name = 'ID')) BEGIN
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
            '4b71c0a8-7c4f-4d7c-83b0-b60b1fd5d7db',
            '6AB1F963-429D-4A9E-AD4F-FB525041C356', -- Entity: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b777000b-f5ca-4aec-b71f-2c9f87c4273c' OR (EntityID = '6AB1F963-429D-4A9E-AD4F-FB525041C356' AND Name = 'TaskID')) BEGIN
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
            'b777000b-f5ca-4aec-b71f-2c9f87c4273c',
            '6AB1F963-429D-4A9E-AD4F-FB525041C356', -- Entity: Task Activities
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
            '00A658F4-3884-4B70-A009-FB8A27617A95',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e8d0bdb5-9967-482b-8491-2cdb12716c61' OR (EntityID = '6AB1F963-429D-4A9E-AD4F-FB525041C356' AND Name = 'PersonID')) BEGIN
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
            'e8d0bdb5-9967-482b-8491-2cdb12716c61',
            '6AB1F963-429D-4A9E-AD4F-FB525041C356', -- Entity: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b1a13d7f-8c7d-4531-97ce-a093e5737420' OR (EntityID = '6AB1F963-429D-4A9E-AD4F-FB525041C356' AND Name = 'ActivityType')) BEGIN
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
            'b1a13d7f-8c7d-4531-97ce-a093e5737420',
            '6AB1F963-429D-4A9E-AD4F-FB525041C356', -- Entity: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '22f1a6d5-a850-4223-b441-33ed6acda27a' OR (EntityID = '6AB1F963-429D-4A9E-AD4F-FB525041C356' AND Name = 'PreviousValue')) BEGIN
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
            '22f1a6d5-a850-4223-b441-33ed6acda27a',
            '6AB1F963-429D-4A9E-AD4F-FB525041C356', -- Entity: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '68fff162-a26b-42e8-8950-1ecca94119f6' OR (EntityID = '6AB1F963-429D-4A9E-AD4F-FB525041C356' AND Name = 'NewValue')) BEGIN
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
            '68fff162-a26b-42e8-8950-1ecca94119f6',
            '6AB1F963-429D-4A9E-AD4F-FB525041C356', -- Entity: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '353fb3fb-def7-4489-b0cd-b228685449f4' OR (EntityID = '6AB1F963-429D-4A9E-AD4F-FB525041C356' AND Name = 'Description')) BEGIN
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
            '353fb3fb-def7-4489-b0cd-b228685449f4',
            '6AB1F963-429D-4A9E-AD4F-FB525041C356', -- Entity: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '291a1616-3b40-4ca1-8239-dae1a5f6cc09' OR (EntityID = '6AB1F963-429D-4A9E-AD4F-FB525041C356' AND Name = '__mj_CreatedAt')) BEGIN
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
            '291a1616-3b40-4ca1-8239-dae1a5f6cc09',
            '6AB1F963-429D-4A9E-AD4F-FB525041C356', -- Entity: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7838f461-9c0f-4eaa-a8fc-cc60db41d42e' OR (EntityID = '6AB1F963-429D-4A9E-AD4F-FB525041C356' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '7838f461-9c0f-4eaa-a8fc-cc60db41d42e',
            '6AB1F963-429D-4A9E-AD4F-FB525041C356', -- Entity: Task Activities
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4549088a-30c5-421a-b912-0ac1b949e128' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'ID')) BEGIN
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
            '4549088a-30c5-421a-b912-0ac1b949e128',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '067c231e-7edb-4f87-ba98-f60ac09a215a' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'Name')) BEGIN
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
            '067c231e-7edb-4f87-ba98-f60ac09a215a',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2fa3ec54-7f40-4aae-8935-e8ef9817fb24' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'Description')) BEGIN
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
            '2fa3ec54-7f40-4aae-8935-e8ef9817fb24',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '535ea6f9-3ff5-491c-83d6-c6817baf32bb' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'TypeID')) BEGIN
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
            '535ea6f9-3ff5-491c-83d6-c6817baf32bb',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '627935ac-b1d8-423b-b37c-1a6a17bce9c4' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'CategoryID')) BEGIN
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
            '627935ac-b1d8-423b-b37c-1a6a17bce9c4',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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
            '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2389144e-f4ca-43b4-9c77-a2baaadae266' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'ParentID')) BEGIN
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
            '2389144e-f4ca-43b4-9c77-a2baaadae266',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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
            '00A658F4-3884-4B70-A009-FB8A27617A95',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '39338b59-89c2-4a8f-8714-a69e1cd0c548' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'Status')) BEGIN
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
            '39338b59-89c2-4a8f-8714-a69e1cd0c548',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '99bbf0d4-ca48-41de-9007-36bf726bc761' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'Priority')) BEGIN
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
            '99bbf0d4-ca48-41de-9007-36bf726bc761',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '247391c5-2800-40f3-b548-059924172d4a' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'StartedAt')) BEGIN
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
            '247391c5-2800-40f3-b548-059924172d4a',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '577b190a-44f6-4345-8856-f51205de33ff' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'DueAt')) BEGIN
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
            '577b190a-44f6-4345-8856-f51205de33ff',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '78b4c249-3e32-47ba-8191-fd79122453a8' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'CompletedAt')) BEGIN
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
            '78b4c249-3e32-47ba-8191-fd79122453a8',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7412ac8c-299c-4b8a-a532-cb1983d8de7f' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'HoursEstimated')) BEGIN
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
            '7412ac8c-299c-4b8a-a532-cb1983d8de7f',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd7b6dd54-a81d-4f2d-8946-4a7a6f801e87' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'HoursActual')) BEGIN
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
            'd7b6dd54-a81d-4f2d-8946-4a7a6f801e87',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5c6c09b5-a5c0-4f7c-9ed2-f9719a07da4d' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'PercentComplete')) BEGIN
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
            '5c6c09b5-a5c0-4f7c-9ed2-f9719a07da4d',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f0fd94d3-4bae-45bc-8142-9ced1b89b193' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'Sequence')) BEGIN
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
            'f0fd94d3-4bae-45bc-8142-9ced1b89b193',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ec766bb1-24e5-4675-8446-629e2126d8bf' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'BlockedReason')) BEGIN
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
            'ec766bb1-24e5-4675-8446-629e2126d8bf',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b17fc163-cc62-4c3e-a079-902d453a9c10' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'CompletionNotes')) BEGIN
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
            'b17fc163-cc62-4c3e-a079-902d453a9c10',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e1c5eafc-d826-487a-8a46-0079d2a6669d' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'CreatedByPersonID')) BEGIN
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
            'e1c5eafc-d826-487a-8a46-0079d2a6669d',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '81a0df91-6ad7-4de8-89ec-4109efdd4e3a' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = '__mj_CreatedAt')) BEGIN
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
            '81a0df91-6ad7-4de8-89ec-4109efdd4e3a',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e9c83924-39f6-4fdd-a8e5-835133f23518' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'e9c83924-39f6-4fdd-a8e5-835133f23518',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
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

/* SQL text to insert entity field value with ID fc323b87-5802-4e25-acc2-72ed998337a4 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('fc323b87-5802-4e25-acc2-72ed998337a4', '8F8B98D4-A99A-4E78-BA98-A961B7386004', 1, 'Critical', 'Critical', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID b7a4a41c-3ea4-4a0f-8d15-91414ca71518 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b7a4a41c-3ea4-4a0f-8d15-91414ca71518', '8F8B98D4-A99A-4E78-BA98-A961B7386004', 2, 'High', 'High', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 532dcfcd-d333-4eb9-9a34-b191d166f70a */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('532dcfcd-d333-4eb9-9a34-b191d166f70a', '8F8B98D4-A99A-4E78-BA98-A961B7386004', 3, 'Low', 'Low', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 2b522895-9c8f-4799-a579-34efa4406b84 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('2b522895-9c8f-4799-a579-34efa4406b84', '8F8B98D4-A99A-4E78-BA98-A961B7386004', 4, 'Medium', 'Medium', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID 8F8B98D4-A99A-4E78-BA98-A961B7386004 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='8F8B98D4-A99A-4E78-BA98-A961B7386004'

/* SQL text to insert entity field value with ID dc08b8c5-6863-4a99-8c24-26713b02b119 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('dc08b8c5-6863-4a99-8c24-26713b02b119', '5F278987-16FB-4B2D-80F5-E0C7F996C19D', 1, 'FinishToFinish', 'FinishToFinish', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 70b9c284-2ab1-4210-b987-955ce64ceee3 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('70b9c284-2ab1-4210-b987-955ce64ceee3', '5F278987-16FB-4B2D-80F5-E0C7F996C19D', 2, 'FinishToStart', 'FinishToStart', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 6c2ab25d-f658-4a33-9cc6-e12a15a44fc2 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6c2ab25d-f658-4a33-9cc6-e12a15a44fc2', '5F278987-16FB-4B2D-80F5-E0C7F996C19D', 3, 'StartToFinish', 'StartToFinish', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 40d7e0b7-e928-4136-adb4-66df96e75857 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('40d7e0b7-e928-4136-adb4-66df96e75857', '5F278987-16FB-4B2D-80F5-E0C7F996C19D', 4, 'StartToStart', 'StartToStart', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID 5F278987-16FB-4B2D-80F5-E0C7F996C19D */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='5F278987-16FB-4B2D-80F5-E0C7F996C19D'

/* SQL text to insert entity field value with ID 5e945e90-d814-4515-a692-8dd422fa280c */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('5e945e90-d814-4515-a692-8dd422fa280c', 'FF1A5F7C-6A07-45C3-A369-465AC5097D2D', 1, 'Critical', 'Critical', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 72796a68-64a6-449d-b566-53299e279a35 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('72796a68-64a6-449d-b566-53299e279a35', 'FF1A5F7C-6A07-45C3-A369-465AC5097D2D', 2, 'High', 'High', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 195c42a3-0953-414d-8ae8-1858809cd174 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('195c42a3-0953-414d-8ae8-1858809cd174', 'FF1A5F7C-6A07-45C3-A369-465AC5097D2D', 3, 'Low', 'Low', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 37ecdbb4-96f5-4d44-bd62-6208d5dfaf51 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('37ecdbb4-96f5-4d44-bd62-6208d5dfaf51', 'FF1A5F7C-6A07-45C3-A369-465AC5097D2D', 4, 'Medium', 'Medium', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID FF1A5F7C-6A07-45C3-A369-465AC5097D2D */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='FF1A5F7C-6A07-45C3-A369-465AC5097D2D'

/* SQL text to insert entity field value with ID 8f658f38-fa0b-48fc-9a47-a67bdf78930b */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('8f658f38-fa0b-48fc-9a47-a67bdf78930b', 'B1A13D7F-8C7D-4531-97CE-A093E5737420', 1, 'AssignmentAdded', 'AssignmentAdded', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 01236978-f037-43af-b971-f9f51263ea92 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('01236978-f037-43af-b971-f9f51263ea92', 'B1A13D7F-8C7D-4531-97CE-A093E5737420', 2, 'AssignmentRemoved', 'AssignmentRemoved', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID ae783c5a-7933-489e-896a-1a547494638a */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ae783c5a-7933-489e-896a-1a547494638a', 'B1A13D7F-8C7D-4531-97CE-A093E5737420', 3, 'Completed', 'Completed', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 8d4e06cc-733d-48a9-a9e4-b0dc173609d0 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('8d4e06cc-733d-48a9-a9e4-b0dc173609d0', 'B1A13D7F-8C7D-4531-97CE-A093E5737420', 4, 'Created', 'Created', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 288e35db-efca-47ae-bbee-34e203e90223 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('288e35db-efca-47ae-bbee-34e203e90223', 'B1A13D7F-8C7D-4531-97CE-A093E5737420', 5, 'DependencyAdded', 'DependencyAdded', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 023a738f-eec6-4e6a-8412-009e94ff384a */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('023a738f-eec6-4e6a-8412-009e94ff384a', 'B1A13D7F-8C7D-4531-97CE-A093E5737420', 6, 'DependencyRemoved', 'DependencyRemoved', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID a41cbae6-7bd6-43fc-ad8e-49fd80fe053e */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a41cbae6-7bd6-43fc-ad8e-49fd80fe053e', 'B1A13D7F-8C7D-4531-97CE-A093E5737420', 7, 'DueDateChanged', 'DueDateChanged', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 4336f449-ffde-449e-983e-f1ab806a931a */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('4336f449-ffde-449e-983e-f1ab806a931a', 'B1A13D7F-8C7D-4531-97CE-A093E5737420', 8, 'PercentCompleteChanged', 'PercentCompleteChanged', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 6c73f8f5-92c2-488e-927e-0b09af3a9c04 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6c73f8f5-92c2-488e-927e-0b09af3a9c04', 'B1A13D7F-8C7D-4531-97CE-A093E5737420', 9, 'PriorityChanged', 'PriorityChanged', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID c991c484-e71e-48df-8ad5-a7cb1bda04f4 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c991c484-e71e-48df-8ad5-a7cb1bda04f4', 'B1A13D7F-8C7D-4531-97CE-A093E5737420', 10, 'StatusChange', 'StatusChange', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID B1A13D7F-8C7D-4531-97CE-A093E5737420 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='B1A13D7F-8C7D-4531-97CE-A093E5737420'

/* SQL text to insert entity field value with ID 31531a02-1df3-46cb-9626-2b92642f034f */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('31531a02-1df3-46cb-9626-2b92642f034f', '39338B59-89C2-4A8F-8714-A69E1CD0C548', 1, 'Blocked', 'Blocked', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 05ae707f-5a36-4cee-8a75-2033e0a0dd8f */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('05ae707f-5a36-4cee-8a75-2033e0a0dd8f', '39338B59-89C2-4A8F-8714-A69E1CD0C548', 2, 'Cancelled', 'Cancelled', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 51293754-9ee8-42f9-94e2-b9ea44ceeeee */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('51293754-9ee8-42f9-94e2-b9ea44ceeeee', '39338B59-89C2-4A8F-8714-A69E1CD0C548', 3, 'Completed', 'Completed', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID d87190b2-3a77-41e5-826c-3a3cfd3285ce */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d87190b2-3a77-41e5-826c-3a3cfd3285ce', '39338B59-89C2-4A8F-8714-A69E1CD0C548', 4, 'InProgress', 'InProgress', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID d7954448-b5b3-4e6e-81d2-22d599cb44cd */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d7954448-b5b3-4e6e-81d2-22d599cb44cd', '39338B59-89C2-4A8F-8714-A69E1CD0C548', 5, 'Open', 'Open', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID 39338B59-89C2-4A8F-8714-A69E1CD0C548 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='39338B59-89C2-4A8F-8714-A69E1CD0C548'

/* SQL text to insert entity field value with ID 42cd92f8-c21e-4a0b-81fd-fb69765c80ef */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('42cd92f8-c21e-4a0b-81fd-fb69765c80ef', '99BBF0D4-CA48-41DE-9007-36BF726BC761', 1, 'Critical', 'Critical', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 01406782-f511-429d-a3b2-af15285b6dec */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('01406782-f511-429d-a3b2-af15285b6dec', '99BBF0D4-CA48-41DE-9007-36BF726BC761', 2, 'High', 'High', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 44174827-77b2-4298-9d6b-104c48000058 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('44174827-77b2-4298-9d6b-104c48000058', '99BBF0D4-CA48-41DE-9007-36BF726BC761', 3, 'Low', 'Low', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 7bb73980-56b1-4b6c-8985-3f133d9be590 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7bb73980-56b1-4b6c-8985-3f133d9be590', '99BBF0D4-CA48-41DE-9007-36BF726BC761', 4, 'Medium', 'Medium', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID 99BBF0D4-CA48-41DE-9007-36BF726BC761 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='99BBF0D4-CA48-41DE-9007-36BF726BC761'

/* SQL text to insert entity field value with ID cbf2df7f-92e5-44a0-900b-feec8b637bec */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('cbf2df7f-92e5-44a0-900b-feec8b637bec', '3A7114DA-3781-4DAB-9A49-54EB3800B13A', 1, 'Completed', 'Completed', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 2b18deff-0603-4397-a992-2894741572b7 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('2b18deff-0603-4397-a992-2894741572b7', '3A7114DA-3781-4DAB-9A49-54EB3800B13A', 2, 'InProgress', 'InProgress', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID d46d0cbf-2e70-43ae-be82-4d362a0fa15f */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d46d0cbf-2e70-43ae-be82-4d362a0fa15f', '3A7114DA-3781-4DAB-9A49-54EB3800B13A', 3, 'Pending', 'Pending', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID 3A7114DA-3781-4DAB-9A49-54EB3800B13A */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='3A7114DA-3781-4DAB-9A49-54EB3800B13A'

/* SQL text to insert entity field value with ID 984896cc-33ac-4843-b743-ee19588e395a */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('984896cc-33ac-4843-b743-ee19588e395a', '0501E69C-03FC-4233-97D5-AC36393AC8BA', 1, 'FinishToFinish', 'FinishToFinish', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 467120d4-3161-440d-8870-92b1c9bdaa50 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('467120d4-3161-440d-8870-92b1c9bdaa50', '0501E69C-03FC-4233-97D5-AC36393AC8BA', 2, 'FinishToStart', 'FinishToStart', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 9a3fae9e-ca6a-4e3c-a485-89a8d17ff1c3 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9a3fae9e-ca6a-4e3c-a485-89a8d17ff1c3', '0501E69C-03FC-4233-97D5-AC36393AC8BA', 3, 'StartToFinish', 'StartToFinish', GETUTCDATE(), GETUTCDATE())

/* SQL text to insert entity field value with ID 7bf8baaf-c47b-48e7-99d7-62fc0a942562 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7bf8baaf-c47b-48e7-99d7-62fc0a942562', '0501E69C-03FC-4233-97D5-AC36393AC8BA', 4, 'StartToStart', 'StartToStart', GETUTCDATE(), GETUTCDATE())

/* SQL text to update ValueListType for entity field ID 0501E69C-03FC-4233-97D5-AC36393AC8BA */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='0501E69C-03FC-4233-97D5-AC36393AC8BA'


/* Create Entity Relationship: Task Tags -> Task Tag Links (One To Many via TagID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'c712c6a8-6957-468d-9020-1ba36693080c'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('c712c6a8-6957-468d-9020-1ba36693080c', '2201FA6F-98F2-4D33-8813-04304095148B', '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD', 'TagID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Task Templates -> Task Template Items (One To Many via TemplateID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'b5615e04-d139-468c-a868-8fd47286d02b'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('b5615e04-d139-468c-a868-8fd47286d02b', '76AD5DCB-1637-4E9D-86CB-076CC831426D', '7467A8CE-0F48-4C34-AA00-720357DCADD8', 'TemplateID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Entities -> Task Assignments (One To Many via AssigneeEntityID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '613bd4aa-64d7-4957-a95f-606873dc8099'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('613bd4aa-64d7-4957-a95f-606873dc8099', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'C878B295-7259-4407-9251-B63721EEA41C', 'AssigneeEntityID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ: Entities -> Task Links (One To Many via EntityID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '03b9265e-180a-4035-b9d6-47b043f3c761'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('03b9265e-180a-4035-b9d6-47b043f3c761', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8', 'EntityID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Actions -> Task Types (One To Many via OnCompleteActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '1b8d820a-8bb5-4454-bdd4-99274dc3325b'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('1b8d820a-8bb5-4454-bdd4-99274dc3325b', '38248F34-2837-EF11-86D4-6045BDEE16E6', '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', 'OnCompleteActionID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Actions -> Task Types (One To Many via OnPercentChangeActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'aa77ee41-2748-40db-b145-785b1d8a1078'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('aa77ee41-2748-40db-b145-785b1d8a1078', '38248F34-2837-EF11-86D4-6045BDEE16E6', '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', 'OnPercentChangeActionID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Actions -> Task Types (One To Many via OnAssignActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'a8630d7e-8f74-4aca-8eb8-2ac08fb5150e'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a8630d7e-8f74-4aca-8eb8-2ac08fb5150e', '38248F34-2837-EF11-86D4-6045BDEE16E6', '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', 'OnAssignActionID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Actions -> Task Types (One To Many via OnOverdueActionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'f6a8d9a4-9ffe-457a-a0df-0dad58e983c2'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('f6a8d9a4-9ffe-457a-a0df-0dad58e983c2', '38248F34-2837-EF11-86D4-6045BDEE16E6', '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', 'OnOverdueActionID', 'One To Many', 1, 1, 4, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Task Template Items -> Task Template Item Dependencies (One To Many via DependsOnItemID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '95e87e86-df89-4078-82bc-7861fa5627d8'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('95e87e86-df89-4078-82bc-7861fa5627d8', '7467A8CE-0F48-4C34-AA00-720357DCADD8', 'C8C707BB-35E8-4161-95DB-9FADFB114014', 'DependsOnItemID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Task Template Items -> Task Template Item Dependencies (One To Many via ItemID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '6aa5751b-f608-4c97-8600-8164ba8c29d9'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('6aa5751b-f608-4c97-8600-8164ba8c29d9', '7467A8CE-0F48-4C34-AA00-720357DCADD8', 'C8C707BB-35E8-4161-95DB-9FADFB114014', 'ItemID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Task Template Items -> Task Template Items (One To Many via ParentItemID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'b0ea1276-97ca-4f1b-a3ac-c63dc72cdfd8'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('b0ea1276-97ca-4f1b-a3ac-c63dc72cdfd8', '7467A8CE-0F48-4C34-AA00-720357DCADD8', '7467A8CE-0F48-4C34-AA00-720357DCADD8', 'ParentItemID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: Task Template Items -> Task Template Item Roles (One To Many via ItemID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'c52defc9-aeda-4666-9ab3-e7f3c14b5a17'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('c52defc9-aeda-4666-9ab3-e7f3c14b5a17', '7467A8CE-0F48-4C34-AA00-720357DCADD8', '42CC66F2-213D-4111-8D34-76CCA2E31EE4', 'ItemID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: Task Roles -> Task Template Item Roles (One To Many via RoleID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '69020b34-fedb-40ef-9de6-18a8234abeaa'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('69020b34-fedb-40ef-9de6-18a8234abeaa', 'B5187E17-08F0-4491-86CF-A87EECCEDD79', '42CC66F2-213D-4111-8D34-76CCA2E31EE4', 'RoleID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Task Roles -> Task Assignments (One To Many via RoleID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'da5aae00-426b-4c4b-a4b8-bec21ea07709'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('da5aae00-426b-4c4b-a4b8-bec21ea07709', 'B5187E17-08F0-4491-86CF-A87EECCEDD79', 'C878B295-7259-4407-9251-B63721EEA41C', 'RoleID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Task Categories -> Task Templates (One To Many via CategoryID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '178d4df9-45a9-495f-bd48-a53b543e2b33'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('178d4df9-45a9-495f-bd48-a53b543e2b33', '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A', '76AD5DCB-1637-4E9D-86CB-076CC831426D', 'CategoryID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Task Categories -> Task Categories (One To Many via ParentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'a5eb8404-a7e0-4e9e-b692-17c53da1492d'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a5eb8404-a7e0-4e9e-b692-17c53da1492d', '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A', '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A', 'ParentID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: Task Categories -> Tasks (One To Many via CategoryID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '637d78ba-fecb-49e7-affb-3565a4d6b62c'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('637d78ba-fecb-49e7-affb-3565a4d6b62c', '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A', '00A658F4-3884-4B70-A009-FB8A27617A95', 'CategoryID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Task Types -> Tasks (One To Many via TypeID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'e0561b09-6d83-4c05-9a44-7812e680ef7d'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('e0561b09-6d83-4c05-9a44-7812e680ef7d', '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', '00A658F4-3884-4B70-A009-FB8A27617A95', 'TypeID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Task Types -> Task Templates (One To Many via TypeID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'b9b00681-2f64-4931-ab41-44da53cd384e'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('b9b00681-2f64-4931-ab41-44da53cd384e', '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', '76AD5DCB-1637-4E9D-86CB-076CC831426D', 'TypeID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Common: People -> Task Comments (One To Many via PersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '4fbb1d2a-27ee-4895-b375-989ada20d353'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('4fbb1d2a-27ee-4895-b375-989ada20d353', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '6F128578-52CB-4BEB-B433-E2E92E68C7E0', 'PersonID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Common: People -> Task Activities (One To Many via PersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'b34d970f-35b6-48ef-8965-b0070644b3be'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('b34d970f-35b6-48ef-8965-b0070644b3be', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '6AB1F963-429D-4A9E-AD4F-FB525041C356', 'PersonID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: MJ.BizApps.Common: People -> Task Assignments (One To Many via AssignedByPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'ed6bb953-e497-4d0f-830c-20954216a86a'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('ed6bb953-e497-4d0f-830c-20954216a86a', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'C878B295-7259-4407-9251-B63721EEA41C', 'AssignedByPersonID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ.BizApps.Common: People -> Tasks (One To Many via CreatedByPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '20b47878-3401-413d-8e07-bea93e6442f4'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('20b47878-3401-413d-8e07-bea93e6442f4', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '00A658F4-3884-4B70-A009-FB8A27617A95', 'CreatedByPersonID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Task Comments -> Task Comments (One To Many via ParentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '6a950b58-c4f5-47df-a924-a13eb2d8d8a0'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('6a950b58-c4f5-47df-a924-a13eb2d8d8a0', '6F128578-52CB-4BEB-B433-E2E92E68C7E0', '6F128578-52CB-4BEB-B433-E2E92E68C7E0', 'ParentID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: Tasks -> Tasks (One To Many via ParentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'a1a90d82-5b83-478d-a21d-e30560d668c2'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a1a90d82-5b83-478d-a21d-e30560d668c2', '00A658F4-3884-4B70-A009-FB8A27617A95', '00A658F4-3884-4B70-A009-FB8A27617A95', 'ParentID', 'One To Many', 1, 1, 4, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Tasks -> Task Tag Links (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'f2f7f4dc-baca-445d-9598-5e41bcee3018'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('f2f7f4dc-baca-445d-9598-5e41bcee3018', '00A658F4-3884-4B70-A009-FB8A27617A95', '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD', 'TaskID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Tasks -> Task Dependencies (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '57111e74-4ef6-4625-879e-d8295f7c59d1'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('57111e74-4ef6-4625-879e-d8295f7c59d1', '00A658F4-3884-4B70-A009-FB8A27617A95', 'EABE2ED5-F60B-40CF-A6C3-997337031C13', 'TaskID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Tasks -> Task Dependencies (One To Many via DependsOnTaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '4581e66a-22a4-4592-a373-0e2aff50fe8c'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('4581e66a-22a4-4592-a373-0e2aff50fe8c', '00A658F4-3884-4B70-A009-FB8A27617A95', 'EABE2ED5-F60B-40CF-A6C3-997337031C13', 'DependsOnTaskID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    


/* Create Entity Relationship: Tasks -> Task Comments (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '2af5e6a8-b244-4bcc-8ffa-b3cfa0c12c9f'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('2af5e6a8-b244-4bcc-8ffa-b3cfa0c12c9f', '00A658F4-3884-4B70-A009-FB8A27617A95', '6F128578-52CB-4BEB-B433-E2E92E68C7E0', 'TaskID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Tasks -> Task Links (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'a9c06a13-ae3b-49cb-989d-d84d1f26a0da'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a9c06a13-ae3b-49cb-989d-d84d1f26a0da', '00A658F4-3884-4B70-A009-FB8A27617A95', 'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8', 'TaskID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Tasks -> Task Activities (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'acd8ce00-96f2-4d69-a053-59e682b55ef6'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('acd8ce00-96f2-4d69-a053-59e682b55ef6', '00A658F4-3884-4B70-A009-FB8A27617A95', '6AB1F963-429D-4A9E-AD4F-FB525041C356', 'TaskID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Tasks -> Task Assignments (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'd4b4092c-9bfe-4734-a61e-98a54f7d8f4c'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('d4b4092c-9bfe-4734-a61e-98a54f7d8f4c', '00A658F4-3884-4B70-A009-FB8A27617A95', 'C878B295-7259-4407-9251-B63721EEA41C', 'TaskID', 'One To Many', 1, 1, 4, GETUTCDATE(), GETUTCDATE())
   END;
                    

/* Index for Foreign Keys for AddressLink */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Address Links
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key AddressID in table AddressLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_AddressLink_AddressID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[AddressLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_AddressLink_AddressID ON [${flyway:defaultSchema}_BizAppsCommon].[AddressLink] ([AddressID]);

-- Index for foreign key EntityID in table AddressLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_AddressLink_EntityID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[AddressLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_AddressLink_EntityID ON [${flyway:defaultSchema}_BizAppsCommon].[AddressLink] ([EntityID]);

-- Index for foreign key AddressTypeID in table AddressLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_AddressLink_AddressTypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[AddressLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_AddressLink_AddressTypeID ON [${flyway:defaultSchema}_BizAppsCommon].[AddressLink] ([AddressTypeID]);

/* Index for Foreign Keys for AddressType */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Address Types
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------


/* Index for Foreign Keys for Address */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Addresses
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------


/* Index for Foreign Keys for ContactMethod */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Contact Methods
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key PersonID in table ContactMethod
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_ContactMethod_PersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[ContactMethod]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_ContactMethod_PersonID ON [${flyway:defaultSchema}_BizAppsCommon].[ContactMethod] ([PersonID]);

-- Index for foreign key OrganizationID in table ContactMethod
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_ContactMethod_OrganizationID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[ContactMethod]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_ContactMethod_OrganizationID ON [${flyway:defaultSchema}_BizAppsCommon].[ContactMethod] ([OrganizationID]);

-- Index for foreign key ContactTypeID in table ContactMethod
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_ContactMethod_ContactTypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[ContactMethod]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_ContactMethod_ContactTypeID ON [${flyway:defaultSchema}_BizAppsCommon].[ContactMethod] ([ContactTypeID]);

/* Index for Foreign Keys for ContactType */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Contact Types
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------


/* Base View SQL for MJ.BizApps.Common: Address Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Address Links
-- Item: vwAddressLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ.BizApps.Common: Address Links
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsCommon
-----               BASE TABLE:  AddressLink
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[vwAddressLinks]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwAddressLinks];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwAddressLinks]
AS
SELECT
    a.*,
    mjBizAppsCommonAddress_AddressID.[Line1] AS [Address],
    MJEntity_EntityID.[Name] AS [Entity],
    mjBizAppsCommonAddressType_AddressTypeID.[Name] AS [AddressType]
FROM
    [${flyway:defaultSchema}_BizAppsCommon].[AddressLink] AS a
INNER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[Address] AS mjBizAppsCommonAddress_AddressID
  ON
    [a].[AddressID] = mjBizAppsCommonAddress_AddressID.[ID]
INNER JOIN
    [${flyway:defaultSchema}].[Entity] AS MJEntity_EntityID
  ON
    [a].[EntityID] = MJEntity_EntityID.[ID]
INNER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[AddressType] AS mjBizAppsCommonAddressType_AddressTypeID
  ON
    [a].[AddressTypeID] = mjBizAppsCommonAddressType_AddressTypeID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwAddressLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for MJ.BizApps.Common: Address Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Address Links
-- Item: Permissions for vwAddressLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwAddressLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for MJ.BizApps.Common: Address Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Address Links
-- Item: spCreateAddressLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR AddressLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spCreateAddressLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateAddressLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateAddressLink]
    @ID uniqueidentifier = NULL,
    @AddressID uniqueidentifier,
    @EntityID uniqueidentifier,
    @RecordID nvarchar(700),
    @AddressTypeID uniqueidentifier,
    @IsPrimary bit = NULL,
    @Rank int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[AddressLink]
            (
                [ID],
                [AddressID],
                [EntityID],
                [RecordID],
                [AddressTypeID],
                [IsPrimary],
                [Rank]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @AddressID,
                @EntityID,
                @RecordID,
                @AddressTypeID,
                ISNULL(@IsPrimary, 0),
                @Rank
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[AddressLink]
            (
                [AddressID],
                [EntityID],
                [RecordID],
                [AddressTypeID],
                [IsPrimary],
                [Rank]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @AddressID,
                @EntityID,
                @RecordID,
                @AddressTypeID,
                ISNULL(@IsPrimary, 0),
                @Rank
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwAddressLinks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateAddressLink] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for MJ.BizApps.Common: Address Links */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateAddressLink] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for MJ.BizApps.Common: Address Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Address Links
-- Item: spUpdateAddressLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR AddressLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spUpdateAddressLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateAddressLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateAddressLink]
    @ID uniqueidentifier,
    @AddressID uniqueidentifier,
    @EntityID uniqueidentifier,
    @RecordID nvarchar(700),
    @AddressTypeID uniqueidentifier,
    @IsPrimary bit,
    @Rank int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[AddressLink]
    SET
        [AddressID] = @AddressID,
        [EntityID] = @EntityID,
        [RecordID] = @RecordID,
        [AddressTypeID] = @AddressTypeID,
        [IsPrimary] = @IsPrimary,
        [Rank] = @Rank
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwAddressLinks] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsCommon].[vwAddressLinks]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateAddressLink] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the AddressLink table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[trgUpdateAddressLink]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsCommon].[trgUpdateAddressLink];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsCommon].trgUpdateAddressLink
ON [${flyway:defaultSchema}_BizAppsCommon].[AddressLink]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[AddressLink]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsCommon].[AddressLink] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for MJ.BizApps.Common: Address Links */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateAddressLink] TO [cdp_Developer], [cdp_Integration]



/* Base View SQL for MJ.BizApps.Common: Address Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Address Types
-- Item: vwAddressTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ.BizApps.Common: Address Types
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsCommon
-----               BASE TABLE:  AddressType
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[vwAddressTypes]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwAddressTypes];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwAddressTypes]
AS
SELECT
    a.*
FROM
    [${flyway:defaultSchema}_BizAppsCommon].[AddressType] AS a
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwAddressTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for MJ.BizApps.Common: Address Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Address Types
-- Item: Permissions for vwAddressTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwAddressTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for MJ.BizApps.Common: Address Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Address Types
-- Item: spCreateAddressType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR AddressType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spCreateAddressType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateAddressType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateAddressType]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(100),
    @Description nvarchar(MAX),
    @IconClass nvarchar(100),
    @DefaultRank int = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[AddressType]
            (
                [ID],
                [Name],
                [Description],
                [IconClass],
                [DefaultRank],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                @Description,
                @IconClass,
                ISNULL(@DefaultRank, 100),
                ISNULL(@IsActive, 1)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[AddressType]
            (
                [Name],
                [Description],
                [IconClass],
                [DefaultRank],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                @Description,
                @IconClass,
                ISNULL(@DefaultRank, 100),
                ISNULL(@IsActive, 1)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwAddressTypes] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateAddressType] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for MJ.BizApps.Common: Address Types */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateAddressType] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for MJ.BizApps.Common: Address Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Address Types
-- Item: spUpdateAddressType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR AddressType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spUpdateAddressType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateAddressType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateAddressType]
    @ID uniqueidentifier,
    @Name nvarchar(100),
    @Description nvarchar(MAX),
    @IconClass nvarchar(100),
    @DefaultRank int,
    @IsActive bit
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[AddressType]
    SET
        [Name] = @Name,
        [Description] = @Description,
        [IconClass] = @IconClass,
        [DefaultRank] = @DefaultRank,
        [IsActive] = @IsActive
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwAddressTypes] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsCommon].[vwAddressTypes]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateAddressType] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the AddressType table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[trgUpdateAddressType]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsCommon].[trgUpdateAddressType];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsCommon].trgUpdateAddressType
ON [${flyway:defaultSchema}_BizAppsCommon].[AddressType]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[AddressType]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsCommon].[AddressType] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for MJ.BizApps.Common: Address Types */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateAddressType] TO [cdp_Developer], [cdp_Integration]



/* Base View SQL for MJ.BizApps.Common: Addresses */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Addresses
-- Item: vwAddresses
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ.BizApps.Common: Addresses
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsCommon
-----               BASE TABLE:  Address
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[vwAddresses]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwAddresses];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwAddresses]
AS
SELECT
    a.*
FROM
    [${flyway:defaultSchema}_BizAppsCommon].[Address] AS a
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwAddresses] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for MJ.BizApps.Common: Addresses */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Addresses
-- Item: Permissions for vwAddresses
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwAddresses] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for MJ.BizApps.Common: Addresses */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Addresses
-- Item: spCreateAddress
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Address
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spCreateAddress]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateAddress];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateAddress]
    @ID uniqueidentifier = NULL,
    @Line1 nvarchar(255),
    @Line2 nvarchar(255),
    @Line3 nvarchar(255),
    @City nvarchar(100),
    @StateProvince nvarchar(100),
    @PostalCode nvarchar(20),
    @Country nvarchar(100) = NULL,
    @Latitude decimal(9, 6),
    @Longitude decimal(9, 6)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[Address]
            (
                [ID],
                [Line1],
                [Line2],
                [Line3],
                [City],
                [StateProvince],
                [PostalCode],
                [Country],
                [Latitude],
                [Longitude]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Line1,
                @Line2,
                @Line3,
                @City,
                @StateProvince,
                @PostalCode,
                ISNULL(@Country, 'US'),
                @Latitude,
                @Longitude
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[Address]
            (
                [Line1],
                [Line2],
                [Line3],
                [City],
                [StateProvince],
                [PostalCode],
                [Country],
                [Latitude],
                [Longitude]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Line1,
                @Line2,
                @Line3,
                @City,
                @StateProvince,
                @PostalCode,
                ISNULL(@Country, 'US'),
                @Latitude,
                @Longitude
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwAddresses] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateAddress] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for MJ.BizApps.Common: Addresses */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateAddress] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for MJ.BizApps.Common: Addresses */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Addresses
-- Item: spUpdateAddress
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Address
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spUpdateAddress]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateAddress];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateAddress]
    @ID uniqueidentifier,
    @Line1 nvarchar(255),
    @Line2 nvarchar(255),
    @Line3 nvarchar(255),
    @City nvarchar(100),
    @StateProvince nvarchar(100),
    @PostalCode nvarchar(20),
    @Country nvarchar(100),
    @Latitude decimal(9, 6),
    @Longitude decimal(9, 6)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[Address]
    SET
        [Line1] = @Line1,
        [Line2] = @Line2,
        [Line3] = @Line3,
        [City] = @City,
        [StateProvince] = @StateProvince,
        [PostalCode] = @PostalCode,
        [Country] = @Country,
        [Latitude] = @Latitude,
        [Longitude] = @Longitude
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwAddresses] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsCommon].[vwAddresses]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateAddress] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Address table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[trgUpdateAddress]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsCommon].[trgUpdateAddress];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsCommon].trgUpdateAddress
ON [${flyway:defaultSchema}_BizAppsCommon].[Address]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[Address]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsCommon].[Address] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for MJ.BizApps.Common: Addresses */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateAddress] TO [cdp_Developer], [cdp_Integration]



/* Base View SQL for MJ.BizApps.Common: Contact Methods */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Contact Methods
-- Item: vwContactMethods
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ.BizApps.Common: Contact Methods
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsCommon
-----               BASE TABLE:  ContactMethod
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[vwContactMethods]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwContactMethods];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwContactMethods]
AS
SELECT
    c.*,
    mjBizAppsCommonPerson_PersonID.[DisplayName] AS [Person],
    mjBizAppsCommonOrganization_OrganizationID.[Name] AS [Organization],
    mjBizAppsCommonContactType_ContactTypeID.[Name] AS [ContactType]
FROM
    [${flyway:defaultSchema}_BizAppsCommon].[ContactMethod] AS c
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[vwPeopleExtended] AS mjBizAppsCommonPerson_PersonID
  ON
    [c].[PersonID] = mjBizAppsCommonPerson_PersonID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[Organization] AS mjBizAppsCommonOrganization_OrganizationID
  ON
    [c].[OrganizationID] = mjBizAppsCommonOrganization_OrganizationID.[ID]
INNER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[ContactType] AS mjBizAppsCommonContactType_ContactTypeID
  ON
    [c].[ContactTypeID] = mjBizAppsCommonContactType_ContactTypeID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwContactMethods] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for MJ.BizApps.Common: Contact Methods */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Contact Methods
-- Item: Permissions for vwContactMethods
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwContactMethods] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for MJ.BizApps.Common: Contact Methods */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Contact Methods
-- Item: spCreateContactMethod
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR ContactMethod
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spCreateContactMethod]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateContactMethod];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateContactMethod]
    @ID uniqueidentifier = NULL,
    @PersonID uniqueidentifier,
    @OrganizationID uniqueidentifier,
    @ContactTypeID uniqueidentifier,
    @Value nvarchar(500),
    @Label nvarchar(100),
    @IsPrimary bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[ContactMethod]
            (
                [ID],
                [PersonID],
                [OrganizationID],
                [ContactTypeID],
                [Value],
                [Label],
                [IsPrimary]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @PersonID,
                @OrganizationID,
                @ContactTypeID,
                @Value,
                @Label,
                ISNULL(@IsPrimary, 0)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[ContactMethod]
            (
                [PersonID],
                [OrganizationID],
                [ContactTypeID],
                [Value],
                [Label],
                [IsPrimary]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @PersonID,
                @OrganizationID,
                @ContactTypeID,
                @Value,
                @Label,
                ISNULL(@IsPrimary, 0)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwContactMethods] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateContactMethod] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for MJ.BizApps.Common: Contact Methods */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateContactMethod] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for MJ.BizApps.Common: Contact Methods */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Contact Methods
-- Item: spUpdateContactMethod
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR ContactMethod
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spUpdateContactMethod]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateContactMethod];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateContactMethod]
    @ID uniqueidentifier,
    @PersonID uniqueidentifier,
    @OrganizationID uniqueidentifier,
    @ContactTypeID uniqueidentifier,
    @Value nvarchar(500),
    @Label nvarchar(100),
    @IsPrimary bit
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[ContactMethod]
    SET
        [PersonID] = @PersonID,
        [OrganizationID] = @OrganizationID,
        [ContactTypeID] = @ContactTypeID,
        [Value] = @Value,
        [Label] = @Label,
        [IsPrimary] = @IsPrimary
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwContactMethods] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsCommon].[vwContactMethods]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateContactMethod] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the ContactMethod table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[trgUpdateContactMethod]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsCommon].[trgUpdateContactMethod];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsCommon].trgUpdateContactMethod
ON [${flyway:defaultSchema}_BizAppsCommon].[ContactMethod]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[ContactMethod]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsCommon].[ContactMethod] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for MJ.BizApps.Common: Contact Methods */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateContactMethod] TO [cdp_Developer], [cdp_Integration]



/* Base View SQL for MJ.BizApps.Common: Contact Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Contact Types
-- Item: vwContactTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ.BizApps.Common: Contact Types
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsCommon
-----               BASE TABLE:  ContactType
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[vwContactTypes]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwContactTypes];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwContactTypes]
AS
SELECT
    c.*
FROM
    [${flyway:defaultSchema}_BizAppsCommon].[ContactType] AS c
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwContactTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for MJ.BizApps.Common: Contact Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Contact Types
-- Item: Permissions for vwContactTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwContactTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for MJ.BizApps.Common: Contact Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Contact Types
-- Item: spCreateContactType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR ContactType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spCreateContactType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateContactType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateContactType]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(100),
    @Description nvarchar(MAX),
    @IconClass nvarchar(100),
    @DisplayRank int = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[ContactType]
            (
                [ID],
                [Name],
                [Description],
                [IconClass],
                [DisplayRank],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                @Description,
                @IconClass,
                ISNULL(@DisplayRank, 100),
                ISNULL(@IsActive, 1)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[ContactType]
            (
                [Name],
                [Description],
                [IconClass],
                [DisplayRank],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                @Description,
                @IconClass,
                ISNULL(@DisplayRank, 100),
                ISNULL(@IsActive, 1)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwContactTypes] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateContactType] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for MJ.BizApps.Common: Contact Types */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateContactType] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for MJ.BizApps.Common: Contact Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Contact Types
-- Item: spUpdateContactType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR ContactType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spUpdateContactType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateContactType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateContactType]
    @ID uniqueidentifier,
    @Name nvarchar(100),
    @Description nvarchar(MAX),
    @IconClass nvarchar(100),
    @DisplayRank int,
    @IsActive bit
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[ContactType]
    SET
        [Name] = @Name,
        [Description] = @Description,
        [IconClass] = @IconClass,
        [DisplayRank] = @DisplayRank,
        [IsActive] = @IsActive
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwContactTypes] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsCommon].[vwContactTypes]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateContactType] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the ContactType table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[trgUpdateContactType]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsCommon].[trgUpdateContactType];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsCommon].trgUpdateContactType
ON [${flyway:defaultSchema}_BizAppsCommon].[ContactType]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[ContactType]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsCommon].[ContactType] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for MJ.BizApps.Common: Contact Types */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateContactType] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for MJ.BizApps.Common: Address Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Address Links
-- Item: spDeleteAddressLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR AddressLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spDeleteAddressLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteAddressLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteAddressLink]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsCommon].[AddressLink]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteAddressLink] TO [cdp_Integration]
    

/* spDelete Permissions for MJ.BizApps.Common: Address Links */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteAddressLink] TO [cdp_Integration]



/* spDelete SQL for MJ.BizApps.Common: Address Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Address Types
-- Item: spDeleteAddressType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR AddressType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spDeleteAddressType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteAddressType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteAddressType]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsCommon].[AddressType]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteAddressType] TO [cdp_Integration]
    

/* spDelete Permissions for MJ.BizApps.Common: Address Types */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteAddressType] TO [cdp_Integration]



/* spDelete SQL for MJ.BizApps.Common: Addresses */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Addresses
-- Item: spDeleteAddress
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Address
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spDeleteAddress]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteAddress];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteAddress]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsCommon].[Address]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteAddress] TO [cdp_Integration]
    

/* spDelete Permissions for MJ.BizApps.Common: Addresses */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteAddress] TO [cdp_Integration]



/* spDelete SQL for MJ.BizApps.Common: Contact Methods */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Contact Methods
-- Item: spDeleteContactMethod
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR ContactMethod
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spDeleteContactMethod]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteContactMethod];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteContactMethod]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsCommon].[ContactMethod]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteContactMethod] TO [cdp_Integration]
    

/* spDelete Permissions for MJ.BizApps.Common: Contact Methods */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteContactMethod] TO [cdp_Integration]



/* spDelete SQL for MJ.BizApps.Common: Contact Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Contact Types
-- Item: spDeleteContactType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR ContactType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spDeleteContactType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteContactType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteContactType]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsCommon].[ContactType]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteContactType] TO [cdp_Integration]
    

/* spDelete Permissions for MJ.BizApps.Common: Contact Types */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteContactType] TO [cdp_Integration]



/* Index for Foreign Keys for OrganizationType */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Organization Types
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------


/* Index for Foreign Keys for Organization */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Organizations
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key OrganizationTypeID in table Organization
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Organization_OrganizationTypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[Organization]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Organization_OrganizationTypeID ON [${flyway:defaultSchema}_BizAppsCommon].[Organization] ([OrganizationTypeID]);

-- Index for foreign key ParentID in table Organization
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Organization_ParentID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[Organization]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Organization_ParentID ON [${flyway:defaultSchema}_BizAppsCommon].[Organization] ([ParentID]);

/* Base View Permissions SQL for MJ.BizApps.Common: Organizations */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Organizations
-- Item: Permissions for vwOrganizationsExtended
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwOrganizationsExtended] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for MJ.BizApps.Common: Organizations */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Organizations
-- Item: spCreateOrganization
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Organization
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spCreateOrganization]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateOrganization];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateOrganization]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(255),
    @LegalName nvarchar(255),
    @OrganizationTypeID uniqueidentifier,
    @ParentID uniqueidentifier,
    @Website nvarchar(1000),
    @LogoURL nvarchar(1000),
    @Description nvarchar(MAX),
    @Email nvarchar(255),
    @Phone nvarchar(50),
    @FoundedDate date,
    @TaxID nvarchar(50),
    @Status nvarchar(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[Organization]
            (
                [ID],
                [Name],
                [LegalName],
                [OrganizationTypeID],
                [ParentID],
                [Website],
                [LogoURL],
                [Description],
                [Email],
                [Phone],
                [FoundedDate],
                [TaxID],
                [Status]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                @LegalName,
                @OrganizationTypeID,
                @ParentID,
                @Website,
                @LogoURL,
                @Description,
                @Email,
                @Phone,
                @FoundedDate,
                @TaxID,
                ISNULL(@Status, 'Active')
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[Organization]
            (
                [Name],
                [LegalName],
                [OrganizationTypeID],
                [ParentID],
                [Website],
                [LogoURL],
                [Description],
                [Email],
                [Phone],
                [FoundedDate],
                [TaxID],
                [Status]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                @LegalName,
                @OrganizationTypeID,
                @ParentID,
                @Website,
                @LogoURL,
                @Description,
                @Email,
                @Phone,
                @FoundedDate,
                @TaxID,
                ISNULL(@Status, 'Active')
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwOrganizationsExtended] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateOrganization] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for MJ.BizApps.Common: Organizations */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateOrganization] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for MJ.BizApps.Common: Organizations */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Organizations
-- Item: spUpdateOrganization
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Organization
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spUpdateOrganization]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateOrganization];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateOrganization]
    @ID uniqueidentifier,
    @Name nvarchar(255),
    @LegalName nvarchar(255),
    @OrganizationTypeID uniqueidentifier,
    @ParentID uniqueidentifier,
    @Website nvarchar(1000),
    @LogoURL nvarchar(1000),
    @Description nvarchar(MAX),
    @Email nvarchar(255),
    @Phone nvarchar(50),
    @FoundedDate date,
    @TaxID nvarchar(50),
    @Status nvarchar(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[Organization]
    SET
        [Name] = @Name,
        [LegalName] = @LegalName,
        [OrganizationTypeID] = @OrganizationTypeID,
        [ParentID] = @ParentID,
        [Website] = @Website,
        [LogoURL] = @LogoURL,
        [Description] = @Description,
        [Email] = @Email,
        [Phone] = @Phone,
        [FoundedDate] = @FoundedDate,
        [TaxID] = @TaxID,
        [Status] = @Status
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwOrganizationsExtended] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsCommon].[vwOrganizationsExtended]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateOrganization] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Organization table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[trgUpdateOrganization]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsCommon].[trgUpdateOrganization];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsCommon].trgUpdateOrganization
ON [${flyway:defaultSchema}_BizAppsCommon].[Organization]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[Organization]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsCommon].[Organization] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for MJ.BizApps.Common: Organizations */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateOrganization] TO [cdp_Developer], [cdp_Integration]



/* Index for Foreign Keys for Person */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: People
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key LinkedUserID in table Person
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Person_LinkedUserID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[Person]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Person_LinkedUserID ON [${flyway:defaultSchema}_BizAppsCommon].[Person] ([LinkedUserID]);

/* Base View Permissions SQL for MJ.BizApps.Common: People */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: People
-- Item: Permissions for vwPeopleExtended
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwPeopleExtended] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for MJ.BizApps.Common: People */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: People
-- Item: spCreatePerson
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Person
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spCreatePerson]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreatePerson];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreatePerson]
    @ID uniqueidentifier = NULL,
    @FirstName nvarchar(100),
    @LastName nvarchar(100),
    @MiddleName nvarchar(100),
    @Prefix nvarchar(20),
    @Suffix nvarchar(20),
    @PreferredName nvarchar(100),
    @Title nvarchar(200),
    @Email nvarchar(255),
    @Phone nvarchar(50),
    @DateOfBirth date,
    @Gender nvarchar(50),
    @PhotoURL nvarchar(1000),
    @Bio nvarchar(MAX),
    @LinkedUserID uniqueidentifier,
    @Status nvarchar(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[Person]
            (
                [ID],
                [FirstName],
                [LastName],
                [MiddleName],
                [Prefix],
                [Suffix],
                [PreferredName],
                [Title],
                [Email],
                [Phone],
                [DateOfBirth],
                [Gender],
                [PhotoURL],
                [Bio],
                [LinkedUserID],
                [Status]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @FirstName,
                @LastName,
                @MiddleName,
                @Prefix,
                @Suffix,
                @PreferredName,
                @Title,
                @Email,
                @Phone,
                @DateOfBirth,
                @Gender,
                @PhotoURL,
                @Bio,
                @LinkedUserID,
                ISNULL(@Status, 'Active')
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[Person]
            (
                [FirstName],
                [LastName],
                [MiddleName],
                [Prefix],
                [Suffix],
                [PreferredName],
                [Title],
                [Email],
                [Phone],
                [DateOfBirth],
                [Gender],
                [PhotoURL],
                [Bio],
                [LinkedUserID],
                [Status]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @FirstName,
                @LastName,
                @MiddleName,
                @Prefix,
                @Suffix,
                @PreferredName,
                @Title,
                @Email,
                @Phone,
                @DateOfBirth,
                @Gender,
                @PhotoURL,
                @Bio,
                @LinkedUserID,
                ISNULL(@Status, 'Active')
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwPeopleExtended] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreatePerson] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for MJ.BizApps.Common: People */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreatePerson] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for MJ.BizApps.Common: People */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: People
-- Item: spUpdatePerson
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Person
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spUpdatePerson]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdatePerson];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdatePerson]
    @ID uniqueidentifier,
    @FirstName nvarchar(100),
    @LastName nvarchar(100),
    @MiddleName nvarchar(100),
    @Prefix nvarchar(20),
    @Suffix nvarchar(20),
    @PreferredName nvarchar(100),
    @Title nvarchar(200),
    @Email nvarchar(255),
    @Phone nvarchar(50),
    @DateOfBirth date,
    @Gender nvarchar(50),
    @PhotoURL nvarchar(1000),
    @Bio nvarchar(MAX),
    @LinkedUserID uniqueidentifier,
    @Status nvarchar(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[Person]
    SET
        [FirstName] = @FirstName,
        [LastName] = @LastName,
        [MiddleName] = @MiddleName,
        [Prefix] = @Prefix,
        [Suffix] = @Suffix,
        [PreferredName] = @PreferredName,
        [Title] = @Title,
        [Email] = @Email,
        [Phone] = @Phone,
        [DateOfBirth] = @DateOfBirth,
        [Gender] = @Gender,
        [PhotoURL] = @PhotoURL,
        [Bio] = @Bio,
        [LinkedUserID] = @LinkedUserID,
        [Status] = @Status
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwPeopleExtended] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsCommon].[vwPeopleExtended]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdatePerson] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Person table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[trgUpdatePerson]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsCommon].[trgUpdatePerson];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsCommon].trgUpdatePerson
ON [${flyway:defaultSchema}_BizAppsCommon].[Person]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[Person]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsCommon].[Person] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for MJ.BizApps.Common: People */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdatePerson] TO [cdp_Developer], [cdp_Integration]



/* Index for Foreign Keys for RelationshipType */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Relationship Types
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------


/* Index for Foreign Keys for Relationship */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Relationships
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key RelationshipTypeID in table Relationship
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Relationship_RelationshipTypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[Relationship]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Relationship_RelationshipTypeID ON [${flyway:defaultSchema}_BizAppsCommon].[Relationship] ([RelationshipTypeID]);

-- Index for foreign key FromPersonID in table Relationship
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Relationship_FromPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[Relationship]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Relationship_FromPersonID ON [${flyway:defaultSchema}_BizAppsCommon].[Relationship] ([FromPersonID]);

-- Index for foreign key FromOrganizationID in table Relationship
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Relationship_FromOrganizationID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[Relationship]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Relationship_FromOrganizationID ON [${flyway:defaultSchema}_BizAppsCommon].[Relationship] ([FromOrganizationID]);

-- Index for foreign key ToPersonID in table Relationship
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Relationship_ToPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[Relationship]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Relationship_ToPersonID ON [${flyway:defaultSchema}_BizAppsCommon].[Relationship] ([ToPersonID]);

-- Index for foreign key ToOrganizationID in table Relationship
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Relationship_ToOrganizationID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[Relationship]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Relationship_ToOrganizationID ON [${flyway:defaultSchema}_BizAppsCommon].[Relationship] ([ToOrganizationID]);

/* spDelete SQL for MJ.BizApps.Common: Organizations */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Organizations
-- Item: spDeleteOrganization
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Organization
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spDeleteOrganization]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteOrganization];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteOrganization]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsCommon].[Organization]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteOrganization] TO [cdp_Integration]
    

/* spDelete Permissions for MJ.BizApps.Common: Organizations */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteOrganization] TO [cdp_Integration]



/* spDelete SQL for MJ.BizApps.Common: People */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: People
-- Item: spDeletePerson
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Person
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spDeletePerson]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeletePerson];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeletePerson]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsCommon].[Person]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeletePerson] TO [cdp_Integration]
    

/* spDelete Permissions for MJ.BizApps.Common: People */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeletePerson] TO [cdp_Integration]



/* Base View SQL for MJ.BizApps.Common: Organization Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Organization Types
-- Item: vwOrganizationTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ.BizApps.Common: Organization Types
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsCommon
-----               BASE TABLE:  OrganizationType
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[vwOrganizationTypes]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwOrganizationTypes];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwOrganizationTypes]
AS
SELECT
    o.*
FROM
    [${flyway:defaultSchema}_BizAppsCommon].[OrganizationType] AS o
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwOrganizationTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for MJ.BizApps.Common: Organization Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Organization Types
-- Item: Permissions for vwOrganizationTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwOrganizationTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for MJ.BizApps.Common: Organization Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Organization Types
-- Item: spCreateOrganizationType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR OrganizationType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spCreateOrganizationType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateOrganizationType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateOrganizationType]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(100),
    @Description nvarchar(MAX),
    @IconClass nvarchar(100),
    @DisplayRank int = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[OrganizationType]
            (
                [ID],
                [Name],
                [Description],
                [IconClass],
                [DisplayRank],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                @Description,
                @IconClass,
                ISNULL(@DisplayRank, 100),
                ISNULL(@IsActive, 1)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[OrganizationType]
            (
                [Name],
                [Description],
                [IconClass],
                [DisplayRank],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                @Description,
                @IconClass,
                ISNULL(@DisplayRank, 100),
                ISNULL(@IsActive, 1)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwOrganizationTypes] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateOrganizationType] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for MJ.BizApps.Common: Organization Types */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateOrganizationType] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for MJ.BizApps.Common: Organization Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Organization Types
-- Item: spUpdateOrganizationType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR OrganizationType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spUpdateOrganizationType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateOrganizationType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateOrganizationType]
    @ID uniqueidentifier,
    @Name nvarchar(100),
    @Description nvarchar(MAX),
    @IconClass nvarchar(100),
    @DisplayRank int,
    @IsActive bit
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[OrganizationType]
    SET
        [Name] = @Name,
        [Description] = @Description,
        [IconClass] = @IconClass,
        [DisplayRank] = @DisplayRank,
        [IsActive] = @IsActive
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwOrganizationTypes] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsCommon].[vwOrganizationTypes]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateOrganizationType] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the OrganizationType table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[trgUpdateOrganizationType]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsCommon].[trgUpdateOrganizationType];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsCommon].trgUpdateOrganizationType
ON [${flyway:defaultSchema}_BizAppsCommon].[OrganizationType]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[OrganizationType]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsCommon].[OrganizationType] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for MJ.BizApps.Common: Organization Types */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateOrganizationType] TO [cdp_Developer], [cdp_Integration]



/* Base View SQL for MJ.BizApps.Common: Relationship Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Relationship Types
-- Item: vwRelationshipTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ.BizApps.Common: Relationship Types
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsCommon
-----               BASE TABLE:  RelationshipType
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[vwRelationshipTypes]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwRelationshipTypes];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwRelationshipTypes]
AS
SELECT
    r.*
FROM
    [${flyway:defaultSchema}_BizAppsCommon].[RelationshipType] AS r
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwRelationshipTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for MJ.BizApps.Common: Relationship Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Relationship Types
-- Item: Permissions for vwRelationshipTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwRelationshipTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for MJ.BizApps.Common: Relationship Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Relationship Types
-- Item: spCreateRelationshipType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR RelationshipType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spCreateRelationshipType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateRelationshipType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateRelationshipType]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(100),
    @Description nvarchar(MAX),
    @Category nvarchar(50),
    @IsDirectional bit = NULL,
    @ForwardLabel nvarchar(100),
    @ReverseLabel nvarchar(100),
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[RelationshipType]
            (
                [ID],
                [Name],
                [Description],
                [Category],
                [IsDirectional],
                [ForwardLabel],
                [ReverseLabel],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                @Description,
                @Category,
                ISNULL(@IsDirectional, 1),
                @ForwardLabel,
                @ReverseLabel,
                ISNULL(@IsActive, 1)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[RelationshipType]
            (
                [Name],
                [Description],
                [Category],
                [IsDirectional],
                [ForwardLabel],
                [ReverseLabel],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                @Description,
                @Category,
                ISNULL(@IsDirectional, 1),
                @ForwardLabel,
                @ReverseLabel,
                ISNULL(@IsActive, 1)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwRelationshipTypes] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateRelationshipType] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for MJ.BizApps.Common: Relationship Types */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateRelationshipType] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for MJ.BizApps.Common: Relationship Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Relationship Types
-- Item: spUpdateRelationshipType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR RelationshipType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spUpdateRelationshipType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateRelationshipType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateRelationshipType]
    @ID uniqueidentifier,
    @Name nvarchar(100),
    @Description nvarchar(MAX),
    @Category nvarchar(50),
    @IsDirectional bit,
    @ForwardLabel nvarchar(100),
    @ReverseLabel nvarchar(100),
    @IsActive bit
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[RelationshipType]
    SET
        [Name] = @Name,
        [Description] = @Description,
        [Category] = @Category,
        [IsDirectional] = @IsDirectional,
        [ForwardLabel] = @ForwardLabel,
        [ReverseLabel] = @ReverseLabel,
        [IsActive] = @IsActive
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwRelationshipTypes] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsCommon].[vwRelationshipTypes]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateRelationshipType] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the RelationshipType table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[trgUpdateRelationshipType]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsCommon].[trgUpdateRelationshipType];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsCommon].trgUpdateRelationshipType
ON [${flyway:defaultSchema}_BizAppsCommon].[RelationshipType]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[RelationshipType]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsCommon].[RelationshipType] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for MJ.BizApps.Common: Relationship Types */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateRelationshipType] TO [cdp_Developer], [cdp_Integration]



/* Base View SQL for MJ.BizApps.Common: Relationships */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Relationships
-- Item: vwRelationships
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ.BizApps.Common: Relationships
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsCommon
-----               BASE TABLE:  Relationship
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[vwRelationships]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwRelationships];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsCommon].[vwRelationships]
AS
SELECT
    r.*,
    mjBizAppsCommonRelationshipType_RelationshipTypeID.[Name] AS [RelationshipType],
    mjBizAppsCommonPerson_FromPersonID.[DisplayName] AS [FromPerson],
    mjBizAppsCommonOrganization_FromOrganizationID.[Name] AS [FromOrganization],
    mjBizAppsCommonPerson_ToPersonID.[DisplayName] AS [ToPerson],
    mjBizAppsCommonOrganization_ToOrganizationID.[Name] AS [ToOrganization]
FROM
    [${flyway:defaultSchema}_BizAppsCommon].[Relationship] AS r
INNER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[RelationshipType] AS mjBizAppsCommonRelationshipType_RelationshipTypeID
  ON
    [r].[RelationshipTypeID] = mjBizAppsCommonRelationshipType_RelationshipTypeID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[vwPeopleExtended] AS mjBizAppsCommonPerson_FromPersonID
  ON
    [r].[FromPersonID] = mjBizAppsCommonPerson_FromPersonID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[Organization] AS mjBizAppsCommonOrganization_FromOrganizationID
  ON
    [r].[FromOrganizationID] = mjBizAppsCommonOrganization_FromOrganizationID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[vwPeopleExtended] AS mjBizAppsCommonPerson_ToPersonID
  ON
    [r].[ToPersonID] = mjBizAppsCommonPerson_ToPersonID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[Organization] AS mjBizAppsCommonOrganization_ToOrganizationID
  ON
    [r].[ToOrganizationID] = mjBizAppsCommonOrganization_ToOrganizationID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwRelationships] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for MJ.BizApps.Common: Relationships */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Relationships
-- Item: Permissions for vwRelationships
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsCommon].[vwRelationships] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for MJ.BizApps.Common: Relationships */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Relationships
-- Item: spCreateRelationship
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Relationship
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spCreateRelationship]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateRelationship];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spCreateRelationship]
    @ID uniqueidentifier = NULL,
    @RelationshipTypeID uniqueidentifier,
    @FromPersonID uniqueidentifier,
    @FromOrganizationID uniqueidentifier,
    @ToPersonID uniqueidentifier,
    @ToOrganizationID uniqueidentifier,
    @Title nvarchar(255),
    @StartDate date,
    @EndDate date,
    @Status nvarchar(50) = NULL,
    @Notes nvarchar(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[Relationship]
            (
                [ID],
                [RelationshipTypeID],
                [FromPersonID],
                [FromOrganizationID],
                [ToPersonID],
                [ToOrganizationID],
                [Title],
                [StartDate],
                [EndDate],
                [Status],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @RelationshipTypeID,
                @FromPersonID,
                @FromOrganizationID,
                @ToPersonID,
                @ToOrganizationID,
                @Title,
                @StartDate,
                @EndDate,
                ISNULL(@Status, 'Active'),
                @Notes
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsCommon].[Relationship]
            (
                [RelationshipTypeID],
                [FromPersonID],
                [FromOrganizationID],
                [ToPersonID],
                [ToOrganizationID],
                [Title],
                [StartDate],
                [EndDate],
                [Status],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @RelationshipTypeID,
                @FromPersonID,
                @FromOrganizationID,
                @ToPersonID,
                @ToOrganizationID,
                @Title,
                @StartDate,
                @EndDate,
                ISNULL(@Status, 'Active'),
                @Notes
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwRelationships] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateRelationship] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for MJ.BizApps.Common: Relationships */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spCreateRelationship] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for MJ.BizApps.Common: Relationships */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Relationships
-- Item: spUpdateRelationship
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Relationship
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spUpdateRelationship]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateRelationship];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spUpdateRelationship]
    @ID uniqueidentifier,
    @RelationshipTypeID uniqueidentifier,
    @FromPersonID uniqueidentifier,
    @FromOrganizationID uniqueidentifier,
    @ToPersonID uniqueidentifier,
    @ToOrganizationID uniqueidentifier,
    @Title nvarchar(255),
    @StartDate date,
    @EndDate date,
    @Status nvarchar(50),
    @Notes nvarchar(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[Relationship]
    SET
        [RelationshipTypeID] = @RelationshipTypeID,
        [FromPersonID] = @FromPersonID,
        [FromOrganizationID] = @FromOrganizationID,
        [ToPersonID] = @ToPersonID,
        [ToOrganizationID] = @ToOrganizationID,
        [Title] = @Title,
        [StartDate] = @StartDate,
        [EndDate] = @EndDate,
        [Status] = @Status,
        [Notes] = @Notes
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsCommon].[vwRelationships] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsCommon].[vwRelationships]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateRelationship] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Relationship table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[trgUpdateRelationship]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsCommon].[trgUpdateRelationship];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsCommon].trgUpdateRelationship
ON [${flyway:defaultSchema}_BizAppsCommon].[Relationship]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsCommon].[Relationship]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsCommon].[Relationship] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for MJ.BizApps.Common: Relationships */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spUpdateRelationship] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for MJ.BizApps.Common: Organization Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Organization Types
-- Item: spDeleteOrganizationType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR OrganizationType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spDeleteOrganizationType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteOrganizationType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteOrganizationType]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsCommon].[OrganizationType]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteOrganizationType] TO [cdp_Integration]
    

/* spDelete Permissions for MJ.BizApps.Common: Organization Types */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteOrganizationType] TO [cdp_Integration]



/* spDelete SQL for MJ.BizApps.Common: Relationship Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Relationship Types
-- Item: spDeleteRelationshipType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR RelationshipType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spDeleteRelationshipType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteRelationshipType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteRelationshipType]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsCommon].[RelationshipType]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteRelationshipType] TO [cdp_Integration]
    

/* spDelete Permissions for MJ.BizApps.Common: Relationship Types */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteRelationshipType] TO [cdp_Integration]



/* spDelete SQL for MJ.BizApps.Common: Relationships */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ.BizApps.Common: Relationships
-- Item: spDeleteRelationship
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Relationship
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsCommon].[spDeleteRelationship]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteRelationship];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsCommon].[spDeleteRelationship]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsCommon].[Relationship]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteRelationship] TO [cdp_Integration]
    

/* spDelete Permissions for MJ.BizApps.Common: Relationships */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsCommon].[spDeleteRelationship] TO [cdp_Integration]



/* Index for Foreign Keys for TaskActivity */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Activities
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
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskActivity]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskActivity_TaskID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskActivity] ([TaskID]);

-- Index for foreign key PersonID in table TaskActivity
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskActivity_PersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskActivity]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskActivity_PersonID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskActivity] ([PersonID]);

/* SQL text to update entity field related entity name field map for entity field ID B777000B-F5CA-4AEC-B71F-2C9F87C4273C */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='B777000B-F5CA-4AEC-B71F-2C9F87C4273C', @RelatedEntityNameFieldMap='Task'

/* Index for Foreign Keys for TaskAssignment */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Assignments
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
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskAssignment_TaskID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment] ([TaskID]);

-- Index for foreign key AssigneeEntityID in table TaskAssignment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskAssignment_AssigneeEntityID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskAssignment_AssigneeEntityID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment] ([AssigneeEntityID]);

-- Index for foreign key RoleID in table TaskAssignment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskAssignment_RoleID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskAssignment_RoleID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment] ([RoleID]);

-- Index for foreign key AssignedByPersonID in table TaskAssignment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskAssignment_AssignedByPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskAssignment_AssignedByPersonID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment] ([AssignedByPersonID]);

/* SQL text to update entity field related entity name field map for entity field ID 26EDDB1F-9E94-4CC0-95FC-F8AB1154DDB1 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='26EDDB1F-9E94-4CC0-95FC-F8AB1154DDB1', @RelatedEntityNameFieldMap='Task'

/* Index for Foreign Keys for TaskCategory */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Categories
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
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskCategory]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskCategory_ParentID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskCategory] ([ParentID]);

/* SQL text to update entity field related entity name field map for entity field ID CC847652-A1D2-4E43-A4DA-4F86045484A5 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='CC847652-A1D2-4E43-A4DA-4F86045484A5', @RelatedEntityNameFieldMap='Parent'

/* Index for Foreign Keys for TaskComment */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Comments
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
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskComment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskComment_TaskID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskComment] ([TaskID]);

-- Index for foreign key ParentID in table TaskComment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskComment_ParentID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskComment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskComment_ParentID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskComment] ([ParentID]);

-- Index for foreign key PersonID in table TaskComment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskComment_PersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskComment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskComment_PersonID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskComment] ([PersonID]);

/* SQL text to update entity field related entity name field map for entity field ID 7FDBB1D8-9AA2-4274-941F-109959C341F0 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='7FDBB1D8-9AA2-4274-941F-109959C341F0', @RelatedEntityNameFieldMap='Task'

/* Index for Foreign Keys for TaskDependency */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Dependencies
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
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskDependency]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskDependency_TaskID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskDependency] ([TaskID]);

-- Index for foreign key DependsOnTaskID in table TaskDependency
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskDependency_DependsOnTaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskDependency]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskDependency_DependsOnTaskID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskDependency] ([DependsOnTaskID]);

/* SQL text to update entity field related entity name field map for entity field ID 972CF331-DBF8-4780-8FC8-75B27D85452C */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='972CF331-DBF8-4780-8FC8-75B27D85452C', @RelatedEntityNameFieldMap='Task'

/* SQL text to update entity field related entity name field map for entity field ID E8D0BDB5-9967-482B-8491-2CDB12716C61 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='E8D0BDB5-9967-482B-8491-2CDB12716C61', @RelatedEntityNameFieldMap='Person'

/* SQL text to update entity field related entity name field map for entity field ID 914C389B-2A69-4DE8-88BF-23D1B8D6004C */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='914C389B-2A69-4DE8-88BF-23D1B8D6004C', @RelatedEntityNameFieldMap='AssigneeEntity'

/* Root ID Function SQL for Task Categories.ParentID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Categories
-- Item: fnTaskCategoryParentID_GetRootID
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- ROOT ID FUNCTION FOR: [TaskCategory].[ParentID]
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[fnTaskCategoryParentID_GetRootID]', 'IF') IS NOT NULL
    DROP FUNCTION [${flyway:defaultSchema}_BizAppsTasks].[fnTaskCategoryParentID_GetRootID];
GO

CREATE FUNCTION [${flyway:defaultSchema}_BizAppsTasks].[fnTaskCategoryParentID_GetRootID]
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
            [${flyway:defaultSchema}_BizAppsTasks].[TaskCategory]
        WHERE
            [ID] = COALESCE(@ParentID, @RecordID)

        UNION ALL

        SELECT
            c.[ID],
            c.[ParentID],
            c.[ID] AS [RootParentID],
            p.[Depth] + 1 AS [Depth]
        FROM
            [${flyway:defaultSchema}_BizAppsTasks].[TaskCategory] c
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


/* Base View SQL for Task Categories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Categories
-- Item: vwTaskCategories
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Task Categories
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsTasks
-----               BASE TABLE:  TaskCategory
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[vwTaskCategories]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskCategories];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskCategories]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskCategory_ParentID.[Name] AS [Parent],
    root_ParentID.RootID AS [RootParentID]
FROM
    [${flyway:defaultSchema}_BizAppsTasks].[TaskCategory] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[TaskCategory] AS mjBizAppsTasksTaskCategory_ParentID
  ON
    [t].[ParentID] = mjBizAppsTasksTaskCategory_ParentID.[ID]
OUTER APPLY
    [${flyway:defaultSchema}_BizAppsTasks].[fnTaskCategoryParentID_GetRootID]([t].[ID], [t].[ParentID]) AS root_ParentID
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskCategories] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Task Categories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Categories
-- Item: Permissions for vwTaskCategories
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskCategories] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Task Categories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Categories
-- Item: spCreateTaskCategory
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskCategory
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskCategory]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskCategory];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskCategory]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(255),
    @Description nvarchar(MAX),
    @ParentID uniqueidentifier,
    @ColorCode nvarchar(20),
    @Sequence int = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskCategory]
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
                @Description,
                @ParentID,
                @ColorCode,
                ISNULL(@Sequence, 100),
                ISNULL(@IsActive, 1)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskCategory]
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
                @Description,
                @ParentID,
                @ColorCode,
                ISNULL(@Sequence, 100),
                ISNULL(@IsActive, 1)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskCategories] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskCategory] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Task Categories */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskCategory] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Task Categories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Categories
-- Item: spUpdateTaskCategory
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskCategory
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskCategory]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskCategory];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskCategory]
    @ID uniqueidentifier,
    @Name nvarchar(255),
    @Description nvarchar(MAX),
    @ParentID uniqueidentifier,
    @ColorCode nvarchar(20),
    @Sequence int,
    @IsActive bit
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskCategory]
    SET
        [Name] = @Name,
        [Description] = @Description,
        [ParentID] = @ParentID,
        [ColorCode] = @ColorCode,
        [Sequence] = @Sequence,
        [IsActive] = @IsActive
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskCategories] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsTasks].[vwTaskCategories]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskCategory] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskCategory table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskCategory]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskCategory];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsTasks].trgUpdateTaskCategory
ON [${flyway:defaultSchema}_BizAppsTasks].[TaskCategory]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskCategory]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskCategory] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Task Categories */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskCategory] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Task Categories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Categories
-- Item: spDeleteTaskCategory
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskCategory
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskCategory]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskCategory];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskCategory]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskCategory]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskCategory] TO [cdp_Integration]
    

/* spDelete Permissions for Task Categories */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskCategory] TO [cdp_Integration]



/* Base View SQL for Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Activities
-- Item: vwTaskActivities
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Task Activities
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsTasks
-----               BASE TABLE:  TaskActivity
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[vwTaskActivities]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskActivities];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskActivities]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    mjBizAppsCommonPerson_PersonID.[DisplayName] AS [Person]
FROM
    [${flyway:defaultSchema}_BizAppsTasks].[TaskActivity] AS t
INNER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[vwPeopleExtended] AS mjBizAppsCommonPerson_PersonID
  ON
    [t].[PersonID] = mjBizAppsCommonPerson_PersonID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskActivities] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Activities
-- Item: Permissions for vwTaskActivities
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskActivities] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Activities
-- Item: spCreateTaskActivity
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskActivity
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskActivity]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskActivity];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskActivity]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @PersonID uniqueidentifier,
    @ActivityType nvarchar(50),
    @PreviousValue nvarchar(500),
    @NewValue nvarchar(500),
    @Description nvarchar(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskActivity]
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
                @PersonID,
                @ActivityType,
                @PreviousValue,
                @NewValue,
                @Description
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskActivity]
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
                @PersonID,
                @ActivityType,
                @PreviousValue,
                @NewValue,
                @Description
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskActivities] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskActivity] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Task Activities */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskActivity] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Activities
-- Item: spUpdateTaskActivity
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskActivity
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskActivity]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskActivity];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskActivity]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier,
    @PersonID uniqueidentifier,
    @ActivityType nvarchar(50),
    @PreviousValue nvarchar(500),
    @NewValue nvarchar(500),
    @Description nvarchar(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskActivity]
    SET
        [TaskID] = @TaskID,
        [PersonID] = @PersonID,
        [ActivityType] = @ActivityType,
        [PreviousValue] = @PreviousValue,
        [NewValue] = @NewValue,
        [Description] = @Description
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskActivities] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsTasks].[vwTaskActivities]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskActivity] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskActivity table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskActivity]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskActivity];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsTasks].trgUpdateTaskActivity
ON [${flyway:defaultSchema}_BizAppsTasks].[TaskActivity]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskActivity]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskActivity] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Task Activities */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskActivity] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Activities
-- Item: spDeleteTaskActivity
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskActivity
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskActivity]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskActivity];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskActivity]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskActivity]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskActivity] TO [cdp_Integration]
    

/* spDelete Permissions for Task Activities */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskActivity] TO [cdp_Integration]



/* SQL text to update entity field related entity name field map for entity field ID 2270E77A-23F4-4020-BA93-F52D57C74499 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='2270E77A-23F4-4020-BA93-F52D57C74499', @RelatedEntityNameFieldMap='Person'

/* SQL text to update entity field related entity name field map for entity field ID 00410344-351E-4DA9-A6E3-6F788E907DD5 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='00410344-351E-4DA9-A6E3-6F788E907DD5', @RelatedEntityNameFieldMap='DependsOnTask'

/* SQL text to update entity field related entity name field map for entity field ID AC0EBCEE-2FB2-43EB-BFBC-CF999948FA9A */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='AC0EBCEE-2FB2-43EB-BFBC-CF999948FA9A', @RelatedEntityNameFieldMap='Role'

/* Root ID Function SQL for Task Comments.ParentID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Comments
-- Item: fnTaskCommentParentID_GetRootID
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- ROOT ID FUNCTION FOR: [TaskComment].[ParentID]
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[fnTaskCommentParentID_GetRootID]', 'IF') IS NOT NULL
    DROP FUNCTION [${flyway:defaultSchema}_BizAppsTasks].[fnTaskCommentParentID_GetRootID];
GO

CREATE FUNCTION [${flyway:defaultSchema}_BizAppsTasks].[fnTaskCommentParentID_GetRootID]
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
            [${flyway:defaultSchema}_BizAppsTasks].[TaskComment]
        WHERE
            [ID] = COALESCE(@ParentID, @RecordID)

        UNION ALL

        SELECT
            c.[ID],
            c.[ParentID],
            c.[ID] AS [RootParentID],
            p.[Depth] + 1 AS [Depth]
        FROM
            [${flyway:defaultSchema}_BizAppsTasks].[TaskComment] c
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


/* Base View SQL for Task Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Comments
-- Item: vwTaskComments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Task Comments
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsTasks
-----               BASE TABLE:  TaskComment
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[vwTaskComments]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskComments];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskComments]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    mjBizAppsCommonPerson_PersonID.[DisplayName] AS [Person],
    root_ParentID.RootID AS [RootParentID]
FROM
    [${flyway:defaultSchema}_BizAppsTasks].[TaskComment] AS t
INNER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
INNER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[vwPeopleExtended] AS mjBizAppsCommonPerson_PersonID
  ON
    [t].[PersonID] = mjBizAppsCommonPerson_PersonID.[ID]
OUTER APPLY
    [${flyway:defaultSchema}_BizAppsTasks].[fnTaskCommentParentID_GetRootID]([t].[ID], [t].[ParentID]) AS root_ParentID
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskComments] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Task Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Comments
-- Item: Permissions for vwTaskComments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskComments] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Task Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Comments
-- Item: spCreateTaskComment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskComment
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskComment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskComment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskComment]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @ParentID uniqueidentifier,
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
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskComment]
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
                @ParentID,
                @PersonID,
                @Content,
                ISNULL(@IsEdited, 0)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskComment]
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
                @ParentID,
                @PersonID,
                @Content,
                ISNULL(@IsEdited, 0)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskComments] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskComment] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Task Comments */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskComment] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Task Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Comments
-- Item: spUpdateTaskComment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskComment
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskComment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskComment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskComment]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier,
    @ParentID uniqueidentifier,
    @PersonID uniqueidentifier,
    @Content nvarchar(MAX),
    @IsEdited bit
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskComment]
    SET
        [TaskID] = @TaskID,
        [ParentID] = @ParentID,
        [PersonID] = @PersonID,
        [Content] = @Content,
        [IsEdited] = @IsEdited
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskComments] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsTasks].[vwTaskComments]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskComment] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskComment table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskComment]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskComment];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsTasks].trgUpdateTaskComment
ON [${flyway:defaultSchema}_BizAppsTasks].[TaskComment]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskComment]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskComment] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Task Comments */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskComment] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Task Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Comments
-- Item: spDeleteTaskComment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskComment
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskComment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskComment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskComment]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskComment]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskComment] TO [cdp_Integration]
    

/* spDelete Permissions for Task Comments */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskComment] TO [cdp_Integration]



/* Base View SQL for Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Dependencies
-- Item: vwTaskDependencies
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Task Dependencies
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsTasks
-----               BASE TABLE:  TaskDependency
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[vwTaskDependencies]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskDependencies];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskDependencies]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    mjBizAppsTasksTask_DependsOnTaskID.[Name] AS [DependsOnTask]
FROM
    [${flyway:defaultSchema}_BizAppsTasks].[TaskDependency] AS t
INNER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
INNER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[Task] AS mjBizAppsTasksTask_DependsOnTaskID
  ON
    [t].[DependsOnTaskID] = mjBizAppsTasksTask_DependsOnTaskID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskDependencies] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Dependencies
-- Item: Permissions for vwTaskDependencies
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskDependencies] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Dependencies
-- Item: spCreateTaskDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskDependency
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskDependency]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskDependency];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskDependency]
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
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskDependency]
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
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskDependency]
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
    SELECT * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskDependencies] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskDependency] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Task Dependencies */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskDependency] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Dependencies
-- Item: spUpdateTaskDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskDependency
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskDependency]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskDependency];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskDependency]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier,
    @DependsOnTaskID uniqueidentifier,
    @DependencyType nvarchar(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskDependency]
    SET
        [TaskID] = @TaskID,
        [DependsOnTaskID] = @DependsOnTaskID,
        [DependencyType] = @DependencyType
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskDependencies] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsTasks].[vwTaskDependencies]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskDependency] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskDependency table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskDependency]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskDependency];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsTasks].trgUpdateTaskDependency
ON [${flyway:defaultSchema}_BizAppsTasks].[TaskDependency]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskDependency]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskDependency] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Task Dependencies */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskDependency] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Dependencies
-- Item: spDeleteTaskDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskDependency
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskDependency]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskDependency];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskDependency]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskDependency]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskDependency] TO [cdp_Integration]
    

/* spDelete Permissions for Task Dependencies */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskDependency] TO [cdp_Integration]



/* SQL text to update entity field related entity name field map for entity field ID 16AEAA2F-9D60-47E3-919C-4F57A0D74498 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='16AEAA2F-9D60-47E3-919C-4F57A0D74498', @RelatedEntityNameFieldMap='AssignedByPerson'

/* Base View SQL for Task Assignments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Assignments
-- Item: vwTaskAssignments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Task Assignments
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsTasks
-----               BASE TABLE:  TaskAssignment
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[vwTaskAssignments]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskAssignments];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskAssignments]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    MJEntity_AssigneeEntityID.[Name] AS [AssigneeEntity],
    mjBizAppsTasksTaskRole_RoleID.[Name] AS [Role],
    mjBizAppsCommonPerson_AssignedByPersonID.[DisplayName] AS [AssignedByPerson]
FROM
    [${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment] AS t
INNER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
INNER JOIN
    [${flyway:defaultSchema}].[Entity] AS MJEntity_AssigneeEntityID
  ON
    [t].[AssigneeEntityID] = MJEntity_AssigneeEntityID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[TaskRole] AS mjBizAppsTasksTaskRole_RoleID
  ON
    [t].[RoleID] = mjBizAppsTasksTaskRole_RoleID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[vwPeopleExtended] AS mjBizAppsCommonPerson_AssignedByPersonID
  ON
    [t].[AssignedByPersonID] = mjBizAppsCommonPerson_AssignedByPersonID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskAssignments] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Task Assignments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Assignments
-- Item: Permissions for vwTaskAssignments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskAssignments] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Task Assignments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Assignments
-- Item: spCreateTaskAssignment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskAssignment
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskAssignment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskAssignment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskAssignment]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @AssigneeEntityID uniqueidentifier,
    @AssigneeRecordID nvarchar(450),
    @RoleID uniqueidentifier,
    @RoleNotes nvarchar(255),
    @Status nvarchar(50) = NULL,
    @AssignedByPersonID uniqueidentifier,
    @AssignedAt datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment]
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
                @RoleID,
                @RoleNotes,
                ISNULL(@Status, 'Pending'),
                @AssignedByPersonID,
                ISNULL(@AssignedAt, getutcdate())
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment]
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
                @RoleID,
                @RoleNotes,
                ISNULL(@Status, 'Pending'),
                @AssignedByPersonID,
                ISNULL(@AssignedAt, getutcdate())
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskAssignments] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskAssignment] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Task Assignments */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskAssignment] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Task Assignments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Assignments
-- Item: spUpdateTaskAssignment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskAssignment
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskAssignment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskAssignment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskAssignment]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier,
    @AssigneeEntityID uniqueidentifier,
    @AssigneeRecordID nvarchar(450),
    @RoleID uniqueidentifier,
    @RoleNotes nvarchar(255),
    @Status nvarchar(50),
    @AssignedByPersonID uniqueidentifier,
    @AssignedAt datetimeoffset
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment]
    SET
        [TaskID] = @TaskID,
        [AssigneeEntityID] = @AssigneeEntityID,
        [AssigneeRecordID] = @AssigneeRecordID,
        [RoleID] = @RoleID,
        [RoleNotes] = @RoleNotes,
        [Status] = @Status,
        [AssignedByPersonID] = @AssignedByPersonID,
        [AssignedAt] = @AssignedAt
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskAssignments] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsTasks].[vwTaskAssignments]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskAssignment] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskAssignment table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskAssignment]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskAssignment];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsTasks].trgUpdateTaskAssignment
ON [${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Task Assignments */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskAssignment] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Task Assignments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Assignments
-- Item: spDeleteTaskAssignment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskAssignment
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskAssignment]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskAssignment];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskAssignment]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskAssignment]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskAssignment] TO [cdp_Integration]
    

/* spDelete Permissions for Task Assignments */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskAssignment] TO [cdp_Integration]



/* Index for Foreign Keys for TaskLink */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Links
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
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskLink_TaskID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskLink] ([TaskID]);

-- Index for foreign key EntityID in table TaskLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskLink_EntityID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskLink_EntityID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskLink] ([EntityID]);

/* SQL text to update entity field related entity name field map for entity field ID CB802A22-F9AC-4465-AA7A-2A12025EED04 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='CB802A22-F9AC-4465-AA7A-2A12025EED04', @RelatedEntityNameFieldMap='Task'

/* Index for Foreign Keys for TaskRole */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Roles
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------


/* Index for Foreign Keys for TaskTagLink */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Tag Links
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
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskTagLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTagLink_TaskID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTagLink] ([TaskID]);

-- Index for foreign key TagID in table TaskTagLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTagLink_TagID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskTagLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTagLink_TagID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTagLink] ([TagID]);

/* SQL text to update entity field related entity name field map for entity field ID 5A9282D5-395D-457E-81FC-BDA9ACCE5431 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='5A9282D5-395D-457E-81FC-BDA9ACCE5431', @RelatedEntityNameFieldMap='Task'

/* Index for Foreign Keys for TaskTag */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Tags
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------


/* Index for Foreign Keys for TaskTemplateItemDependency */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Item Dependencies
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
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemDependency]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplateItemDependency_ItemID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemDependency] ([ItemID]);

-- Index for foreign key DependsOnItemID in table TaskTemplateItemDependency
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTemplateItemDependency_DependsOnItemID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemDependency]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplateItemDependency_DependsOnItemID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemDependency] ([DependsOnItemID]);

/* SQL text to update entity field related entity name field map for entity field ID 5E58C246-D73C-495C-BE9B-01DDDB62317B */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='5E58C246-D73C-495C-BE9B-01DDDB62317B', @RelatedEntityNameFieldMap='Item'

/* Base View SQL for Task Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Roles
-- Item: vwTaskRoles
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Task Roles
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsTasks
-----               BASE TABLE:  TaskRole
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[vwTaskRoles]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskRoles];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskRoles]
AS
SELECT
    t.*
FROM
    [${flyway:defaultSchema}_BizAppsTasks].[TaskRole] AS t
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskRoles] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Task Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Roles
-- Item: Permissions for vwTaskRoles
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskRoles] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Task Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Roles
-- Item: spCreateTaskRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskRole
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskRole]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskRole];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskRole]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(100),
    @Description nvarchar(MAX),
    @Sequence int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskRole]
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
                @Description,
                ISNULL(@Sequence, 100)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskRole]
            (
                [Name],
                [Description],
                [Sequence]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                @Description,
                ISNULL(@Sequence, 100)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskRoles] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskRole] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Task Roles */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskRole] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Task Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Roles
-- Item: spUpdateTaskRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskRole
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskRole]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskRole];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskRole]
    @ID uniqueidentifier,
    @Name nvarchar(100),
    @Description nvarchar(MAX),
    @Sequence int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskRole]
    SET
        [Name] = @Name,
        [Description] = @Description,
        [Sequence] = @Sequence
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskRoles] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsTasks].[vwTaskRoles]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskRole] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskRole table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskRole]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskRole];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsTasks].trgUpdateTaskRole
ON [${flyway:defaultSchema}_BizAppsTasks].[TaskRole]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskRole]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskRole] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Task Roles */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskRole] TO [cdp_Developer], [cdp_Integration]



/* Base View SQL for Task Tags */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Tags
-- Item: vwTaskTags
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Task Tags
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsTasks
-----               BASE TABLE:  TaskTag
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[vwTaskTags]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTags];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTags]
AS
SELECT
    t.*
FROM
    [${flyway:defaultSchema}_BizAppsTasks].[TaskTag] AS t
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTags] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Task Tags */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Tags
-- Item: Permissions for vwTaskTags
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTags] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Task Tags */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Tags
-- Item: spCreateTaskTag
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTag
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTag]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTag];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTag]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(100),
    @ColorCode nvarchar(20),
    @Description nvarchar(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskTag]
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
                @ColorCode,
                @Description
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskTag]
            (
                [Name],
                [ColorCode],
                [Description]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                @ColorCode,
                @Description
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTags] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTag] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Task Tags */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTag] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Task Tags */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Tags
-- Item: spUpdateTaskTag
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTag
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTag]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTag];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTag]
    @ID uniqueidentifier,
    @Name nvarchar(100),
    @ColorCode nvarchar(20),
    @Description nvarchar(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTag]
    SET
        [Name] = @Name,
        [ColorCode] = @ColorCode,
        [Description] = @Description
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTags] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTags]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTag] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTag table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskTag]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskTag];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsTasks].trgUpdateTaskTag
ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTag]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTag]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTag] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Task Tags */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTag] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Task Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Roles
-- Item: spDeleteTaskRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskRole
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskRole]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskRole];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskRole]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskRole]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskRole] TO [cdp_Integration]
    

/* spDelete Permissions for Task Roles */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskRole] TO [cdp_Integration]



/* spDelete SQL for Task Tags */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Tags
-- Item: spDeleteTaskTag
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTag
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTag]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTag];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTag]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTag]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTag] TO [cdp_Integration]
    

/* spDelete Permissions for Task Tags */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTag] TO [cdp_Integration]



/* SQL text to update entity field related entity name field map for entity field ID 039A33B5-E6BB-4FAC-B8C3-FA2353267D4C */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='039A33B5-E6BB-4FAC-B8C3-FA2353267D4C', @RelatedEntityNameFieldMap='DependsOnItem'

/* SQL text to update entity field related entity name field map for entity field ID 1D40C317-6680-4446-A87D-51E4EB65BD6C */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='1D40C317-6680-4446-A87D-51E4EB65BD6C', @RelatedEntityNameFieldMap='Tag'

/* SQL text to update entity field related entity name field map for entity field ID 97069112-53A9-4FBF-B1EC-C9876D85AD9F */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='97069112-53A9-4FBF-B1EC-C9876D85AD9F', @RelatedEntityNameFieldMap='Entity'

/* Base View SQL for Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Tag Links
-- Item: vwTaskTagLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Task Tag Links
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsTasks
-----               BASE TABLE:  TaskTagLink
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[vwTaskTagLinks]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTagLinks];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTagLinks]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    mjBizAppsTasksTaskTag_TagID.[Name] AS [Tag]
FROM
    [${flyway:defaultSchema}_BizAppsTasks].[TaskTagLink] AS t
INNER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
INNER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[TaskTag] AS mjBizAppsTasksTaskTag_TagID
  ON
    [t].[TagID] = mjBizAppsTasksTaskTag_TagID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTagLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Tag Links
-- Item: Permissions for vwTaskTagLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTagLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Tag Links
-- Item: spCreateTaskTagLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTagLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTagLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTagLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTagLink]
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
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskTagLink]
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
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskTagLink]
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
    SELECT * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTagLinks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTagLink] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Task Tag Links */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTagLink] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Tag Links
-- Item: spUpdateTaskTagLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTagLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTagLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTagLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTagLink]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier,
    @TagID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTagLink]
    SET
        [TaskID] = @TaskID,
        [TagID] = @TagID
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTagLinks] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTagLinks]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTagLink] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTagLink table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskTagLink]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskTagLink];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsTasks].trgUpdateTaskTagLink
ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTagLink]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTagLink]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTagLink] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Task Tag Links */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTagLink] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Tag Links
-- Item: spDeleteTaskTagLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTagLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTagLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTagLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTagLink]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTagLink]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTagLink] TO [cdp_Integration]
    

/* spDelete Permissions for Task Tag Links */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTagLink] TO [cdp_Integration]



/* Base View SQL for Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Links
-- Item: vwTaskLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Task Links
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsTasks
-----               BASE TABLE:  TaskLink
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[vwTaskLinks]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskLinks];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskLinks]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    MJEntity_EntityID.[Name] AS [Entity]
FROM
    [${flyway:defaultSchema}_BizAppsTasks].[TaskLink] AS t
INNER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
INNER JOIN
    [${flyway:defaultSchema}].[Entity] AS MJEntity_EntityID
  ON
    [t].[EntityID] = MJEntity_EntityID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Links
-- Item: Permissions for vwTaskLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Links
-- Item: spCreateTaskLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskLink]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @EntityID uniqueidentifier,
    @RecordID nvarchar(450),
    @Description nvarchar(500)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskLink]
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
                @Description
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskLink]
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
                @Description
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskLinks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskLink] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Task Links */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskLink] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Links
-- Item: spUpdateTaskLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskLink]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier,
    @EntityID uniqueidentifier,
    @RecordID nvarchar(450),
    @Description nvarchar(500)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskLink]
    SET
        [TaskID] = @TaskID,
        [EntityID] = @EntityID,
        [RecordID] = @RecordID,
        [Description] = @Description
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskLinks] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsTasks].[vwTaskLinks]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskLink] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskLink table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskLink]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskLink];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsTasks].trgUpdateTaskLink
ON [${flyway:defaultSchema}_BizAppsTasks].[TaskLink]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskLink]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskLink] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Task Links */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskLink] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Links
-- Item: spDeleteTaskLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskLink]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskLink]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskLink] TO [cdp_Integration]
    

/* spDelete Permissions for Task Links */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskLink] TO [cdp_Integration]



/* Base View SQL for Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Item Dependencies
-- Item: vwTaskTemplateItemDependencies
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Task Template Item Dependencies
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsTasks
-----               BASE TABLE:  TaskTemplateItemDependency
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemDependencies]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemDependencies];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemDependencies]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskTemplateItem_ItemID.[Name] AS [Item],
    mjBizAppsTasksTaskTemplateItem_DependsOnItemID.[Name] AS [DependsOnItem]
FROM
    [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemDependency] AS t
INNER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem] AS mjBizAppsTasksTaskTemplateItem_ItemID
  ON
    [t].[ItemID] = mjBizAppsTasksTaskTemplateItem_ItemID.[ID]
INNER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem] AS mjBizAppsTasksTaskTemplateItem_DependsOnItemID
  ON
    [t].[DependsOnItemID] = mjBizAppsTasksTaskTemplateItem_DependsOnItemID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemDependencies] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Item Dependencies
-- Item: Permissions for vwTaskTemplateItemDependencies
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemDependencies] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Item Dependencies
-- Item: spCreateTaskTemplateItemDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTemplateItemDependency
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplateItemDependency]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplateItemDependency];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplateItemDependency]
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
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemDependency]
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
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemDependency]
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
    SELECT * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemDependencies] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplateItemDependency] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Task Template Item Dependencies */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplateItemDependency] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Item Dependencies
-- Item: spUpdateTaskTemplateItemDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTemplateItemDependency
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplateItemDependency]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplateItemDependency];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplateItemDependency]
    @ID uniqueidentifier,
    @ItemID uniqueidentifier,
    @DependsOnItemID uniqueidentifier,
    @DependencyType nvarchar(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemDependency]
    SET
        [ItemID] = @ItemID,
        [DependsOnItemID] = @DependsOnItemID,
        [DependencyType] = @DependencyType
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemDependencies] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemDependencies]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplateItemDependency] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTemplateItemDependency table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskTemplateItemDependency]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskTemplateItemDependency];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsTasks].trgUpdateTaskTemplateItemDependency
ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemDependency]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemDependency]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemDependency] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Task Template Item Dependencies */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplateItemDependency] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Item Dependencies
-- Item: spDeleteTaskTemplateItemDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTemplateItemDependency
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplateItemDependency]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplateItemDependency];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplateItemDependency]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemDependency]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplateItemDependency] TO [cdp_Integration]
    

/* spDelete Permissions for Task Template Item Dependencies */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplateItemDependency] TO [cdp_Integration]



/* Index for Foreign Keys for TaskTemplateItemRole */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Item Roles
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
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemRole]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplateItemRole_ItemID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemRole] ([ItemID]);

-- Index for foreign key RoleID in table TaskTemplateItemRole
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTemplateItemRole_RoleID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemRole]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplateItemRole_RoleID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemRole] ([RoleID]);

/* SQL text to update entity field related entity name field map for entity field ID 166D3EC8-DE6F-4884-850D-50895C75EE75 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='166D3EC8-DE6F-4884-850D-50895C75EE75', @RelatedEntityNameFieldMap='Item'

/* Index for Foreign Keys for TaskTemplateItem */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Items
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
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplateItem_TemplateID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem] ([TemplateID]);

-- Index for foreign key ParentItemID in table TaskTemplateItem
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTemplateItem_ParentItemID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplateItem_ParentItemID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem] ([ParentItemID]);

/* SQL text to update entity field related entity name field map for entity field ID 53A0637E-130C-44EF-AB25-0A6DB2A2FBA7 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='53A0637E-130C-44EF-AB25-0A6DB2A2FBA7', @RelatedEntityNameFieldMap='Template'

/* Index for Foreign Keys for TaskTemplate */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Templates
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
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskTemplate]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplate_CategoryID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplate] ([CategoryID]);

-- Index for foreign key TypeID in table TaskTemplate
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTemplate_TypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskTemplate]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTemplate_TypeID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplate] ([TypeID]);

/* SQL text to update entity field related entity name field map for entity field ID 4E3F3C17-EA3D-474E-AADD-A4B7CA2F4A7E */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='4E3F3C17-EA3D-474E-AADD-A4B7CA2F4A7E', @RelatedEntityNameFieldMap='Category'

/* Index for Foreign Keys for TaskType */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Types
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
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnAssignActionID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskType] ([OnAssignActionID]);

-- Index for foreign key OnCompleteActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnCompleteActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnCompleteActionID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskType] ([OnCompleteActionID]);

-- Index for foreign key OnOverdueActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnOverdueActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnOverdueActionID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskType] ([OnOverdueActionID]);

-- Index for foreign key OnPercentChangeActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnPercentChangeActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnPercentChangeActionID ON [${flyway:defaultSchema}_BizAppsTasks].[TaskType] ([OnPercentChangeActionID]);

/* SQL text to update entity field related entity name field map for entity field ID 7BC2015B-8A82-4A4B-A6C7-D00E20075C2D */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='7BC2015B-8A82-4A4B-A6C7-D00E20075C2D', @RelatedEntityNameFieldMap='OnAssignAction'

/* Index for Foreign Keys for Task */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tasks
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
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[Task]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Task_TypeID ON [${flyway:defaultSchema}_BizAppsTasks].[Task] ([TypeID]);

-- Index for foreign key CategoryID in table Task
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Task_CategoryID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[Task]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Task_CategoryID ON [${flyway:defaultSchema}_BizAppsTasks].[Task] ([CategoryID]);

-- Index for foreign key ParentID in table Task
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Task_ParentID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[Task]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Task_ParentID ON [${flyway:defaultSchema}_BizAppsTasks].[Task] ([ParentID]);

-- Index for foreign key CreatedByPersonID in table Task
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Task_CreatedByPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[Task]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Task_CreatedByPersonID ON [${flyway:defaultSchema}_BizAppsTasks].[Task] ([CreatedByPersonID]);

/* SQL text to update entity field related entity name field map for entity field ID 535EA6F9-3FF5-491C-83D6-C6817BAF32BB */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='535EA6F9-3FF5-491C-83D6-C6817BAF32BB', @RelatedEntityNameFieldMap='Type'

/* SQL text to update entity field related entity name field map for entity field ID FAB985B5-03C5-43AF-A7CE-CCEAEB02ED82 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='FAB985B5-03C5-43AF-A7CE-CCEAEB02ED82', @RelatedEntityNameFieldMap='Type'

/* SQL text to update entity field related entity name field map for entity field ID 3A8E540E-0B8A-45E8-A8F9-B5E55E0917C8 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='3A8E540E-0B8A-45E8-A8F9-B5E55E0917C8', @RelatedEntityNameFieldMap='Role'

/* SQL text to update entity field related entity name field map for entity field ID 5CB8CBE5-B4C0-4204-A7AD-079B0B2B9439 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='5CB8CBE5-B4C0-4204-A7AD-079B0B2B9439', @RelatedEntityNameFieldMap='ParentItem'

/* SQL text to update entity field related entity name field map for entity field ID 627935AC-B1D8-423B-B37C-1A6A17BCE9C4 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='627935AC-B1D8-423B-B37C-1A6A17BCE9C4', @RelatedEntityNameFieldMap='Category'

/* SQL text to update entity field related entity name field map for entity field ID 109E5E1A-CA5D-4936-B1E8-A5D22940449B */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='109E5E1A-CA5D-4936-B1E8-A5D22940449B', @RelatedEntityNameFieldMap='OnCompleteAction'

/* Base View SQL for Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Item Roles
-- Item: vwTaskTemplateItemRoles
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Task Template Item Roles
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsTasks
-----               BASE TABLE:  TaskTemplateItemRole
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemRoles]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemRoles];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemRoles]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskTemplateItem_ItemID.[Name] AS [Item],
    mjBizAppsTasksTaskRole_RoleID.[Name] AS [Role]
FROM
    [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemRole] AS t
INNER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem] AS mjBizAppsTasksTaskTemplateItem_ItemID
  ON
    [t].[ItemID] = mjBizAppsTasksTaskTemplateItem_ItemID.[ID]
INNER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[TaskRole] AS mjBizAppsTasksTaskRole_RoleID
  ON
    [t].[RoleID] = mjBizAppsTasksTaskRole_RoleID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemRoles] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Item Roles
-- Item: Permissions for vwTaskTemplateItemRoles
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemRoles] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Item Roles
-- Item: spCreateTaskTemplateItemRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTemplateItemRole
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplateItemRole]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplateItemRole];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplateItemRole]
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
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemRole]
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
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemRole]
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
    SELECT * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemRoles] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplateItemRole] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Task Template Item Roles */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplateItemRole] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Item Roles
-- Item: spUpdateTaskTemplateItemRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTemplateItemRole
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplateItemRole]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplateItemRole];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplateItemRole]
    @ID uniqueidentifier,
    @ItemID uniqueidentifier,
    @RoleID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemRole]
    SET
        [ItemID] = @ItemID,
        [RoleID] = @RoleID
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemRoles] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItemRoles]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplateItemRole] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTemplateItemRole table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskTemplateItemRole]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskTemplateItemRole];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsTasks].trgUpdateTaskTemplateItemRole
ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemRole]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemRole]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemRole] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Task Template Item Roles */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplateItemRole] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Item Roles
-- Item: spDeleteTaskTemplateItemRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTemplateItemRole
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplateItemRole]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplateItemRole];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplateItemRole]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItemRole]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplateItemRole] TO [cdp_Integration]
    

/* spDelete Permissions for Task Template Item Roles */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplateItemRole] TO [cdp_Integration]



/* Base View SQL for Task Templates */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Templates
-- Item: vwTaskTemplates
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Task Templates
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsTasks
-----               BASE TABLE:  TaskTemplate
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplates]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplates];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplates]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskCategory_CategoryID.[Name] AS [Category],
    mjBizAppsTasksTaskType_TypeID.[Name] AS [Type]
FROM
    [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplate] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[TaskCategory] AS mjBizAppsTasksTaskCategory_CategoryID
  ON
    [t].[CategoryID] = mjBizAppsTasksTaskCategory_CategoryID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[TaskType] AS mjBizAppsTasksTaskType_TypeID
  ON
    [t].[TypeID] = mjBizAppsTasksTaskType_TypeID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplates] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Task Templates */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Templates
-- Item: Permissions for vwTaskTemplates
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplates] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Task Templates */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Templates
-- Item: spCreateTaskTemplate
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTemplate
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplate]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplate];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplate]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(255),
    @Description nvarchar(MAX),
    @CategoryID uniqueidentifier,
    @TypeID uniqueidentifier,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplate]
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
                @Description,
                @CategoryID,
                @TypeID,
                ISNULL(@IsActive, 1)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplate]
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
                @Description,
                @CategoryID,
                @TypeID,
                ISNULL(@IsActive, 1)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplates] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplate] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Task Templates */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplate] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Task Templates */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Templates
-- Item: spUpdateTaskTemplate
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTemplate
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplate]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplate];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplate]
    @ID uniqueidentifier,
    @Name nvarchar(255),
    @Description nvarchar(MAX),
    @CategoryID uniqueidentifier,
    @TypeID uniqueidentifier,
    @IsActive bit
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplate]
    SET
        [Name] = @Name,
        [Description] = @Description,
        [CategoryID] = @CategoryID,
        [TypeID] = @TypeID,
        [IsActive] = @IsActive
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplates] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplates]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplate] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTemplate table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskTemplate]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskTemplate];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsTasks].trgUpdateTaskTemplate
ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplate]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplate]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplate] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Task Templates */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplate] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Task Templates */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Templates
-- Item: spDeleteTaskTemplate
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTemplate
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplate]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplate];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplate]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplate]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplate] TO [cdp_Integration]
    

/* spDelete Permissions for Task Templates */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplate] TO [cdp_Integration]



/* Root ID Function SQL for Task Template Items.ParentItemID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Items
-- Item: fnTaskTemplateItemParentItemID_GetRootID
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- ROOT ID FUNCTION FOR: [TaskTemplateItem].[ParentItemID]
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[fnTaskTemplateItemParentItemID_GetRootID]', 'IF') IS NOT NULL
    DROP FUNCTION [${flyway:defaultSchema}_BizAppsTasks].[fnTaskTemplateItemParentItemID_GetRootID];
GO

CREATE FUNCTION [${flyway:defaultSchema}_BizAppsTasks].[fnTaskTemplateItemParentItemID_GetRootID]
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
            [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem]
        WHERE
            [ID] = COALESCE(@ParentID, @RecordID)

        UNION ALL

        SELECT
            c.[ID],
            c.[ParentItemID],
            c.[ID] AS [RootParentID],
            p.[Depth] + 1 AS [Depth]
        FROM
            [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem] c
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


/* Base View SQL for Task Template Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Items
-- Item: vwTaskTemplateItems
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Task Template Items
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsTasks
-----               BASE TABLE:  TaskTemplateItem
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItems]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItems];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItems]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskTemplate_TemplateID.[Name] AS [Template],
    mjBizAppsTasksTaskTemplateItem_ParentItemID.[Name] AS [ParentItem],
    root_ParentItemID.RootID AS [RootParentItemID]
FROM
    [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem] AS t
INNER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplate] AS mjBizAppsTasksTaskTemplate_TemplateID
  ON
    [t].[TemplateID] = mjBizAppsTasksTaskTemplate_TemplateID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem] AS mjBizAppsTasksTaskTemplateItem_ParentItemID
  ON
    [t].[ParentItemID] = mjBizAppsTasksTaskTemplateItem_ParentItemID.[ID]
OUTER APPLY
    [${flyway:defaultSchema}_BizAppsTasks].[fnTaskTemplateItemParentItemID_GetRootID]([t].[ID], [t].[ParentItemID]) AS root_ParentItemID
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItems] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Task Template Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Items
-- Item: Permissions for vwTaskTemplateItems
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItems] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Task Template Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Items
-- Item: spCreateTaskTemplateItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTemplateItem
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplateItem]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplateItem];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplateItem]
    @ID uniqueidentifier = NULL,
    @TemplateID uniqueidentifier,
    @Name nvarchar(255),
    @Description nvarchar(MAX),
    @ParentItemID uniqueidentifier,
    @Priority nvarchar(20) = NULL,
    @DaysFromStart int,
    @HoursEstimated decimal(8, 2),
    @Sequence int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem]
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
                @Description,
                @ParentItemID,
                ISNULL(@Priority, 'Medium'),
                @DaysFromStart,
                @HoursEstimated,
                ISNULL(@Sequence, 100)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem]
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
                @Description,
                @ParentItemID,
                ISNULL(@Priority, 'Medium'),
                @DaysFromStart,
                @HoursEstimated,
                ISNULL(@Sequence, 100)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItems] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplateItem] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Task Template Items */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskTemplateItem] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Task Template Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Items
-- Item: spUpdateTaskTemplateItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTemplateItem
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplateItem]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplateItem];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplateItem]
    @ID uniqueidentifier,
    @TemplateID uniqueidentifier,
    @Name nvarchar(255),
    @Description nvarchar(MAX),
    @ParentItemID uniqueidentifier,
    @Priority nvarchar(20),
    @DaysFromStart int,
    @HoursEstimated decimal(8, 2),
    @Sequence int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem]
    SET
        [TemplateID] = @TemplateID,
        [Name] = @Name,
        [Description] = @Description,
        [ParentItemID] = @ParentItemID,
        [Priority] = @Priority,
        [DaysFromStart] = @DaysFromStart,
        [HoursEstimated] = @HoursEstimated,
        [Sequence] = @Sequence
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItems] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTemplateItems]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplateItem] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTemplateItem table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskTemplateItem]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskTemplateItem];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsTasks].trgUpdateTaskTemplateItem
ON [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Task Template Items */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskTemplateItem] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Task Template Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Template Items
-- Item: spDeleteTaskTemplateItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTemplateItem
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplateItem]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplateItem];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplateItem]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskTemplateItem]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplateItem] TO [cdp_Integration]
    

/* spDelete Permissions for Task Template Items */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskTemplateItem] TO [cdp_Integration]



/* SQL text to update entity field related entity name field map for entity field ID 7145E8D1-1D33-4C45-BAB6-F4F0A2F4333B */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='7145E8D1-1D33-4C45-BAB6-F4F0A2F4333B', @RelatedEntityNameFieldMap='OnOverdueAction'

/* SQL text to update entity field related entity name field map for entity field ID 2389144E-F4CA-43B4-9C77-A2BAAADAE266 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='2389144E-F4CA-43B4-9C77-A2BAAADAE266', @RelatedEntityNameFieldMap='Parent'

/* SQL text to update entity field related entity name field map for entity field ID 0BB44728-6647-47DE-850C-192E44BCD8A0 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='0BB44728-6647-47DE-850C-192E44BCD8A0', @RelatedEntityNameFieldMap='OnPercentChangeAction'

/* SQL text to update entity field related entity name field map for entity field ID E1C5EAFC-D826-487A-8A46-0079D2A6669D */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='E1C5EAFC-D826-487A-8A46-0079D2A6669D', @RelatedEntityNameFieldMap='CreatedByPerson'

/* Base View SQL for Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Types
-- Item: vwTaskTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Task Types
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsTasks
-----               BASE TABLE:  TaskType
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[vwTaskTypes]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTypes];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTypes]
AS
SELECT
    t.*,
    MJAction_OnAssignActionID.[Name] AS [OnAssignAction],
    MJAction_OnCompleteActionID.[Name] AS [OnCompleteAction],
    MJAction_OnOverdueActionID.[Name] AS [OnOverdueAction],
    MJAction_OnPercentChangeActionID.[Name] AS [OnPercentChangeAction]
FROM
    [${flyway:defaultSchema}_BizAppsTasks].[TaskType] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Action] AS MJAction_OnAssignActionID
  ON
    [t].[OnAssignActionID] = MJAction_OnAssignActionID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Action] AS MJAction_OnCompleteActionID
  ON
    [t].[OnCompleteActionID] = MJAction_OnCompleteActionID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Action] AS MJAction_OnOverdueActionID
  ON
    [t].[OnOverdueActionID] = MJAction_OnOverdueActionID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Action] AS MJAction_OnPercentChangeActionID
  ON
    [t].[OnPercentChangeActionID] = MJAction_OnPercentChangeActionID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Types
-- Item: Permissions for vwTaskTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Types
-- Item: spCreateTaskType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskType]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(100),
    @Description nvarchar(MAX),
    @IconClass nvarchar(100),
    @DefaultPriority nvarchar(20) = NULL,
    @OnAssignActionID uniqueidentifier,
    @OnCompleteActionID uniqueidentifier,
    @OnOverdueActionID uniqueidentifier,
    @OnPercentChangeActionID uniqueidentifier,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskType]
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
                @Description,
                @IconClass,
                ISNULL(@DefaultPriority, 'Medium'),
                @OnAssignActionID,
                @OnCompleteActionID,
                @OnOverdueActionID,
                @OnPercentChangeActionID,
                ISNULL(@IsActive, 1)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[TaskType]
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
                @Description,
                @IconClass,
                ISNULL(@DefaultPriority, 'Medium'),
                @OnAssignActionID,
                @OnCompleteActionID,
                @OnOverdueActionID,
                @OnPercentChangeActionID,
                ISNULL(@IsActive, 1)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTypes] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskType] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Task Types */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTaskType] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Types
-- Item: spUpdateTaskType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskType]
    @ID uniqueidentifier,
    @Name nvarchar(100),
    @Description nvarchar(MAX),
    @IconClass nvarchar(100),
    @DefaultPriority nvarchar(20),
    @OnAssignActionID uniqueidentifier,
    @OnCompleteActionID uniqueidentifier,
    @OnOverdueActionID uniqueidentifier,
    @OnPercentChangeActionID uniqueidentifier,
    @IsActive bit
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskType]
    SET
        [Name] = @Name,
        [Description] = @Description,
        [IconClass] = @IconClass,
        [DefaultPriority] = @DefaultPriority,
        [OnAssignActionID] = @OnAssignActionID,
        [OnCompleteActionID] = @OnCompleteActionID,
        [OnOverdueActionID] = @OnOverdueActionID,
        [OnPercentChangeActionID] = @OnPercentChangeActionID,
        [IsActive] = @IsActive
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTypes] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsTasks].[vwTaskTypes]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskType] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskType table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskType]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTaskType];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsTasks].trgUpdateTaskType
ON [${flyway:defaultSchema}_BizAppsTasks].[TaskType]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[TaskType]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskType] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Task Types */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTaskType] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Task Types
-- Item: spDeleteTaskType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskType]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsTasks].[TaskType]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskType] TO [cdp_Integration]
    

/* spDelete Permissions for Task Types */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTaskType] TO [cdp_Integration]



/* Root ID Function SQL for Tasks.ParentID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tasks
-- Item: fnTaskParentID_GetRootID
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- ROOT ID FUNCTION FOR: [Task].[ParentID]
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[fnTaskParentID_GetRootID]', 'IF') IS NOT NULL
    DROP FUNCTION [${flyway:defaultSchema}_BizAppsTasks].[fnTaskParentID_GetRootID];
GO

CREATE FUNCTION [${flyway:defaultSchema}_BizAppsTasks].[fnTaskParentID_GetRootID]
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
            [${flyway:defaultSchema}_BizAppsTasks].[Task]
        WHERE
            [ID] = COALESCE(@ParentID, @RecordID)

        UNION ALL

        SELECT
            c.[ID],
            c.[ParentID],
            c.[ID] AS [RootParentID],
            p.[Depth] + 1 AS [Depth]
        FROM
            [${flyway:defaultSchema}_BizAppsTasks].[Task] c
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


/* Base View SQL for Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tasks
-- Item: vwTasks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Tasks
-----               SCHEMA:      ${flyway:defaultSchema}_BizAppsTasks
-----               BASE TABLE:  Task
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[vwTasks]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTasks];
GO

CREATE VIEW [${flyway:defaultSchema}_BizAppsTasks].[vwTasks]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskType_TypeID.[Name] AS [Type],
    mjBizAppsTasksTaskCategory_CategoryID.[Name] AS [Category],
    mjBizAppsTasksTask_ParentID.[Name] AS [Parent],
    mjBizAppsCommonPerson_CreatedByPersonID.[DisplayName] AS [CreatedByPerson],
    root_ParentID.RootID AS [RootParentID]
FROM
    [${flyway:defaultSchema}_BizAppsTasks].[Task] AS t
INNER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[TaskType] AS mjBizAppsTasksTaskType_TypeID
  ON
    [t].[TypeID] = mjBizAppsTasksTaskType_TypeID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[TaskCategory] AS mjBizAppsTasksTaskCategory_CategoryID
  ON
    [t].[CategoryID] = mjBizAppsTasksTaskCategory_CategoryID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsTasks].[Task] AS mjBizAppsTasksTask_ParentID
  ON
    [t].[ParentID] = mjBizAppsTasksTask_ParentID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}_BizAppsCommon].[vwPeopleExtended] AS mjBizAppsCommonPerson_CreatedByPersonID
  ON
    [t].[CreatedByPersonID] = mjBizAppsCommonPerson_CreatedByPersonID.[ID]
OUTER APPLY
    [${flyway:defaultSchema}_BizAppsTasks].[fnTaskParentID_GetRootID]([t].[ID], [t].[ParentID]) AS root_ParentID
GO
GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTasks] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* Base View Permissions SQL for Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tasks
-- Item: Permissions for vwTasks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}_BizAppsTasks].[vwTasks] TO [cdp_UI], [cdp_Developer], [cdp_Integration]

/* spCreate SQL for Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tasks
-- Item: spCreateTask
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Task
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spCreateTask]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTask];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spCreateTask]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(255),
    @Description nvarchar(MAX),
    @TypeID uniqueidentifier,
    @CategoryID uniqueidentifier,
    @ParentID uniqueidentifier,
    @Status nvarchar(50) = NULL,
    @Priority nvarchar(20) = NULL,
    @StartedAt datetimeoffset,
    @DueAt datetimeoffset,
    @CompletedAt datetimeoffset,
    @HoursEstimated decimal(8, 2),
    @HoursActual decimal(8, 2),
    @PercentComplete int = NULL,
    @Sequence int = NULL,
    @BlockedReason nvarchar(MAX),
    @CompletionNotes nvarchar(MAX),
    @CreatedByPersonID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)
    
    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[Task]
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
                [CreatedByPersonID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                @Description,
                @TypeID,
                @CategoryID,
                @ParentID,
                ISNULL(@Status, 'Open'),
                ISNULL(@Priority, 'Medium'),
                @StartedAt,
                @DueAt,
                @CompletedAt,
                @HoursEstimated,
                @HoursActual,
                ISNULL(@PercentComplete, 0),
                ISNULL(@Sequence, 100),
                @BlockedReason,
                @CompletionNotes,
                @CreatedByPersonID
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}_BizAppsTasks].[Task]
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
                [CreatedByPersonID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                @Description,
                @TypeID,
                @CategoryID,
                @ParentID,
                ISNULL(@Status, 'Open'),
                ISNULL(@Priority, 'Medium'),
                @StartedAt,
                @DueAt,
                @CompletedAt,
                @HoursEstimated,
                @HoursActual,
                ISNULL(@PercentComplete, 0),
                ISNULL(@Sequence, 100),
                @BlockedReason,
                @CompletionNotes,
                @CreatedByPersonID
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTasks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTask] TO [cdp_Developer], [cdp_Integration]
    

/* spCreate Permissions for Tasks */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spCreateTask] TO [cdp_Developer], [cdp_Integration]



/* spUpdate SQL for Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tasks
-- Item: spUpdateTask
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Task
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spUpdateTask]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTask];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTask]
    @ID uniqueidentifier,
    @Name nvarchar(255),
    @Description nvarchar(MAX),
    @TypeID uniqueidentifier,
    @CategoryID uniqueidentifier,
    @ParentID uniqueidentifier,
    @Status nvarchar(50),
    @Priority nvarchar(20),
    @StartedAt datetimeoffset,
    @DueAt datetimeoffset,
    @CompletedAt datetimeoffset,
    @HoursEstimated decimal(8, 2),
    @HoursActual decimal(8, 2),
    @PercentComplete int,
    @Sequence int,
    @BlockedReason nvarchar(MAX),
    @CompletionNotes nvarchar(MAX),
    @CreatedByPersonID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[Task]
    SET
        [Name] = @Name,
        [Description] = @Description,
        [TypeID] = @TypeID,
        [CategoryID] = @CategoryID,
        [ParentID] = @ParentID,
        [Status] = @Status,
        [Priority] = @Priority,
        [StartedAt] = @StartedAt,
        [DueAt] = @DueAt,
        [CompletedAt] = @CompletedAt,
        [HoursEstimated] = @HoursEstimated,
        [HoursActual] = @HoursActual,
        [PercentComplete] = @PercentComplete,
        [Sequence] = @Sequence,
        [BlockedReason] = @BlockedReason,
        [CompletionNotes] = @CompletionNotes,
        [CreatedByPersonID] = @CreatedByPersonID
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}_BizAppsTasks].[vwTasks] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}_BizAppsTasks].[vwTasks]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTask] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Task table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTask]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}_BizAppsTasks].[trgUpdateTask];
GO
CREATE TRIGGER [${flyway:defaultSchema}_BizAppsTasks].trgUpdateTask
ON [${flyway:defaultSchema}_BizAppsTasks].[Task]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}_BizAppsTasks].[Task]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}_BizAppsTasks].[Task] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO
        

/* spUpdate Permissions for Tasks */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spUpdateTask] TO [cdp_Developer], [cdp_Integration]



/* spDelete SQL for Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tasks
-- Item: spDeleteTask
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Task
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}_BizAppsTasks].[spDeleteTask]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTask];
GO

CREATE PROCEDURE [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTask]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}_BizAppsTasks].[Task]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTask] TO [cdp_Integration]
    

/* spDelete Permissions for Tasks */

GRANT EXECUTE ON [${flyway:defaultSchema}_BizAppsTasks].[spDeleteTask] TO [cdp_Integration]



/* SQL text to insert new entity field */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ca53a4ae-1983-49ec-9830-12112af6fc89' OR (EntityID = '76AD5DCB-1637-4E9D-86CB-076CC831426D' AND Name = 'Category')) BEGIN
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
            'ca53a4ae-1983-49ec-9830-12112af6fc89',
            '76AD5DCB-1637-4E9D-86CB-076CC831426D', -- Entity: Task Templates
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1defb859-7810-41eb-bfc5-f2d9fd9dbe62' OR (EntityID = '76AD5DCB-1637-4E9D-86CB-076CC831426D' AND Name = 'Type')) BEGIN
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
            '1defb859-7810-41eb-bfc5-f2d9fd9dbe62',
            '76AD5DCB-1637-4E9D-86CB-076CC831426D', -- Entity: Task Templates
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7dc12aed-82e9-4870-8ad6-249a3306179d' OR (EntityID = '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD' AND Name = 'Task')) BEGIN
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
            '7dc12aed-82e9-4870-8ad6-249a3306179d',
            '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD', -- Entity: Task Tag Links
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a9731443-057f-42a7-b4e3-e6f263fd21a3' OR (EntityID = '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD' AND Name = 'Tag')) BEGIN
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
            'a9731443-057f-42a7-b4e3-e6f263fd21a3',
            '5FD9D0C5-A8F6-46A4-BD3C-35284B9757DD', -- Entity: Task Tag Links
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '744121a9-afe4-45d2-9557-c563a2169c16' OR (EntityID = '7467A8CE-0F48-4C34-AA00-720357DCADD8' AND Name = 'Template')) BEGIN
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
            '744121a9-afe4-45d2-9557-c563a2169c16',
            '7467A8CE-0F48-4C34-AA00-720357DCADD8', -- Entity: Task Template Items
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9d2c5387-ac41-4428-a48b-78c87e70bff4' OR (EntityID = '7467A8CE-0F48-4C34-AA00-720357DCADD8' AND Name = 'ParentItem')) BEGIN
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
            '9d2c5387-ac41-4428-a48b-78c87e70bff4',
            '7467A8CE-0F48-4C34-AA00-720357DCADD8', -- Entity: Task Template Items
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '349556dc-7ac4-4654-995d-1a186df3f7d3' OR (EntityID = '7467A8CE-0F48-4C34-AA00-720357DCADD8' AND Name = 'RootParentItemID')) BEGIN
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
            '349556dc-7ac4-4654-995d-1a186df3f7d3',
            '7467A8CE-0F48-4C34-AA00-720357DCADD8', -- Entity: Task Template Items
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '87f7fe9e-650b-46db-9bde-63df2a3b9224' OR (EntityID = '42CC66F2-213D-4111-8D34-76CCA2E31EE4' AND Name = 'Item')) BEGIN
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
            '87f7fe9e-650b-46db-9bde-63df2a3b9224',
            '42CC66F2-213D-4111-8D34-76CCA2E31EE4', -- Entity: Task Template Item Roles
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1490e8c4-4baf-49e6-a5b2-f1f89211793f' OR (EntityID = '42CC66F2-213D-4111-8D34-76CCA2E31EE4' AND Name = 'Role')) BEGIN
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
            '1490e8c4-4baf-49e6-a5b2-f1f89211793f',
            '42CC66F2-213D-4111-8D34-76CCA2E31EE4', -- Entity: Task Template Item Roles
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7dca22c1-7529-40e6-826b-2799bb80eb18' OR (EntityID = 'EABE2ED5-F60B-40CF-A6C3-997337031C13' AND Name = 'Task')) BEGIN
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
            '7dca22c1-7529-40e6-826b-2799bb80eb18',
            'EABE2ED5-F60B-40CF-A6C3-997337031C13', -- Entity: Task Dependencies
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2ca3ca31-4ad9-4741-bfe4-3b4131443612' OR (EntityID = 'EABE2ED5-F60B-40CF-A6C3-997337031C13' AND Name = 'DependsOnTask')) BEGIN
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
            '2ca3ca31-4ad9-4741-bfe4-3b4131443612',
            'EABE2ED5-F60B-40CF-A6C3-997337031C13', -- Entity: Task Dependencies
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bb2407d9-57c2-462f-ba57-056f341e6d3e' OR (EntityID = 'C8C707BB-35E8-4161-95DB-9FADFB114014' AND Name = 'Item')) BEGIN
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
            'bb2407d9-57c2-462f-ba57-056f341e6d3e',
            'C8C707BB-35E8-4161-95DB-9FADFB114014', -- Entity: Task Template Item Dependencies
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9786e144-907b-48c7-968b-13f8650ca85d' OR (EntityID = 'C8C707BB-35E8-4161-95DB-9FADFB114014' AND Name = 'DependsOnItem')) BEGIN
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
            '9786e144-907b-48c7-968b-13f8650ca85d',
            'C8C707BB-35E8-4161-95DB-9FADFB114014', -- Entity: Task Template Item Dependencies
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'fa19e7ec-9acc-4c0b-bc60-e5cae4c8aa9c' OR (EntityID = 'C878B295-7259-4407-9251-B63721EEA41C' AND Name = 'Task')) BEGIN
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
            'fa19e7ec-9acc-4c0b-bc60-e5cae4c8aa9c',
            'C878B295-7259-4407-9251-B63721EEA41C', -- Entity: Task Assignments
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a8d8b54e-e29f-4faf-80d0-9e7116c8671f' OR (EntityID = 'C878B295-7259-4407-9251-B63721EEA41C' AND Name = 'AssigneeEntity')) BEGIN
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
            'a8d8b54e-e29f-4faf-80d0-9e7116c8671f',
            'C878B295-7259-4407-9251-B63721EEA41C', -- Entity: Task Assignments
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd884bb8f-1f9a-4168-aecb-e000f0a68232' OR (EntityID = 'C878B295-7259-4407-9251-B63721EEA41C' AND Name = 'Role')) BEGIN
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
            'd884bb8f-1f9a-4168-aecb-e000f0a68232',
            'C878B295-7259-4407-9251-B63721EEA41C', -- Entity: Task Assignments
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '01e0094c-b9bd-478e-aedb-49658aa30319' OR (EntityID = 'C878B295-7259-4407-9251-B63721EEA41C' AND Name = 'AssignedByPerson')) BEGIN
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
            '01e0094c-b9bd-478e-aedb-49658aa30319',
            'C878B295-7259-4407-9251-B63721EEA41C', -- Entity: Task Assignments
            100026,
            'AssignedByPerson',
            'Assigned By Person',
            NULL,
            'nvarchar',
            488,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9ea96e3e-47a8-4c17-b8b7-c412c164f4f8' OR (EntityID = '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A' AND Name = 'Parent')) BEGIN
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
            '9ea96e3e-47a8-4c17-b8b7-c412c164f4f8',
            '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A', -- Entity: Task Categories
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '14ad12d9-5dee-4acd-95c1-5c528aad80d0' OR (EntityID = '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A' AND Name = 'RootParentID')) BEGIN
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
            '14ad12d9-5dee-4acd-95c1-5c528aad80d0',
            '1CF2A425-D7AC-4D63-A27B-B69065FE9A4A', -- Entity: Task Categories
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e9c62a7b-86b1-44a4-9a1e-81a78d3e6718' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = 'OnAssignAction')) BEGIN
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
            'e9c62a7b-86b1-44a4-9a1e-81a78d3e6718',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c19e4f28-b561-4fbf-876e-d0d7a1bb1070' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = 'OnCompleteAction')) BEGIN
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
            'c19e4f28-b561-4fbf-876e-d0d7a1bb1070',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4fb996be-88d8-4c29-b06c-9934f3d4c028' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = 'OnOverdueAction')) BEGIN
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
            '4fb996be-88d8-4c29-b06c-9934f3d4c028',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '69996a96-afcf-4aa2-a0e3-37a332ca30ee' OR (EntityID = '32DB6788-4DE2-4DC2-A058-B9A6BAF30270' AND Name = 'OnPercentChangeAction')) BEGIN
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
            '69996a96-afcf-4aa2-a0e3-37a332ca30ee',
            '32DB6788-4DE2-4DC2-A058-B9A6BAF30270', -- Entity: Task Types
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8760a794-1b10-4e98-aa0e-39247159e74d' OR (EntityID = 'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8' AND Name = 'Task')) BEGIN
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
            '8760a794-1b10-4e98-aa0e-39247159e74d',
            'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8', -- Entity: Task Links
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3c7df79e-2f0b-4aee-bbe5-c76d6aed5524' OR (EntityID = 'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8' AND Name = 'Entity')) BEGIN
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
            '3c7df79e-2f0b-4aee-bbe5-c76d6aed5524',
            'F108563E-3A8F-4AA3-A3EC-C14DD05A0AD8', -- Entity: Task Links
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '430520d2-e6c1-44e2-b89e-b5d0772902b1' OR (EntityID = '6F128578-52CB-4BEB-B433-E2E92E68C7E0' AND Name = 'Task')) BEGIN
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
            '430520d2-e6c1-44e2-b89e-b5d0772902b1',
            '6F128578-52CB-4BEB-B433-E2E92E68C7E0', -- Entity: Task Comments
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '58cbc557-6a20-4e65-940b-17fb28ae7bdf' OR (EntityID = '6F128578-52CB-4BEB-B433-E2E92E68C7E0' AND Name = 'Person')) BEGIN
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
            '58cbc557-6a20-4e65-940b-17fb28ae7bdf',
            '6F128578-52CB-4BEB-B433-E2E92E68C7E0', -- Entity: Task Comments
            100018,
            'Person',
            'Person',
            NULL,
            'nvarchar',
            488,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ec18c75a-653d-4f44-899e-8651009d27e0' OR (EntityID = '6F128578-52CB-4BEB-B433-E2E92E68C7E0' AND Name = 'RootParentID')) BEGIN
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
            'ec18c75a-653d-4f44-899e-8651009d27e0',
            '6F128578-52CB-4BEB-B433-E2E92E68C7E0', -- Entity: Task Comments
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '40713f55-d40a-4527-8dd5-8e3f233fe8f4' OR (EntityID = '6AB1F963-429D-4A9E-AD4F-FB525041C356' AND Name = 'Task')) BEGIN
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
            '40713f55-d40a-4527-8dd5-8e3f233fe8f4',
            '6AB1F963-429D-4A9E-AD4F-FB525041C356', -- Entity: Task Activities
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '64e2bd24-566f-4345-9c7e-721c47f1d8ae' OR (EntityID = '6AB1F963-429D-4A9E-AD4F-FB525041C356' AND Name = 'Person')) BEGIN
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
            '64e2bd24-566f-4345-9c7e-721c47f1d8ae',
            '6AB1F963-429D-4A9E-AD4F-FB525041C356', -- Entity: Task Activities
            100020,
            'Person',
            'Person',
            NULL,
            'nvarchar',
            488,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '20546a15-a723-4ef8-a256-a24a5ba40d91' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'Type')) BEGIN
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
            '20546a15-a723-4ef8-a256-a24a5ba40d91',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
            100041,
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7230f754-1916-49f2-b8e0-5ec1847ee1b5' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'Category')) BEGIN
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
            '7230f754-1916-49f2-b8e0-5ec1847ee1b5',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
            100042,
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd44a7eae-686e-477c-998f-847d8fc3dd1c' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'Parent')) BEGIN
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
            'd44a7eae-686e-477c-998f-847d8fc3dd1c',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
            100043,
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
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f5639fd3-1cf8-4479-ab56-2e0660e9e305' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'CreatedByPerson')) BEGIN
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
            'f5639fd3-1cf8-4479-ab56-2e0660e9e305',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
            100044,
            'CreatedByPerson',
            'Created By Person',
            NULL,
            'nvarchar',
            488,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            NULL,
            NULL,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '05da60b0-0470-4888-be38-da281834f9e5' OR (EntityID = '00A658F4-3884-4B70-A009-FB8A27617A95' AND Name = 'RootParentID')) BEGIN
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
            '05da60b0-0470-4888-be38-da281834f9e5',
            '00A658F4-3884-4B70-A009-FB8A27617A95', -- Entity: Tasks
            100045,
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
            NULL,
            NULL,
            0,
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

/* Refresh custom base views for modified entities so schema changes are picked up */
EXEC sp_refreshview '${flyway:defaultSchema}_BizAppsCommon.vwOrganizationsExtended';
EXEC sp_refreshview '${flyway:defaultSchema}_BizAppsCommon.vwPeopleExtended';

