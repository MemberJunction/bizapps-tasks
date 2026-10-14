/* SQL generated to create new entity MJ_BizApps_Tasks: Meeting Notes */

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
         '2b15a5d4-9e91-4322-9b82-d58f6e08399e',
         'MJ_BizApps_Tasks: Meeting Notes',
         'Meeting Notes',
         'The record of what happened in a meeting, or on one of its agenda items: written by a person, or drafted by AI from a transcript with the tasks it proposes.',
         NULL,
         'MeetingNote',
         'vwMeetingNotes',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Meeting Notes to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '2b15a5d4-9e91-4322-9b82-d58f6e08399e', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Notes for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('2b15a5d4-9e91-4322-9b82-d58f6e08399e' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('2b15a5d4-9e91-4322-9b82-d58f6e08399e' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Notes for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('2b15a5d4-9e91-4322-9b82-d58f6e08399e' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('2b15a5d4-9e91-4322-9b82-d58f6e08399e' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Notes for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('2b15a5d4-9e91-4322-9b82-d58f6e08399e' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('2b15a5d4-9e91-4322-9b82-d58f6e08399e' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Meeting Links */

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
         '11db0b1f-a42f-4df2-8540-6eb46d7618fb',
         'MJ_BizApps_Tasks: Meeting Links',
         'Meeting Links',
         'What a meeting or a series belongs to: any record of any entity, the way TaskLink ties a task to a record. Each new occurrence of a series copies the series'' links.',
         NULL,
         'MeetingLink',
         'vwMeetingLinks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Meeting Links to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '11db0b1f-a42f-4df2-8540-6eb46d7618fb', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Links for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('11db0b1f-a42f-4df2-8540-6eb46d7618fb' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('11db0b1f-a42f-4df2-8540-6eb46d7618fb' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Links for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('11db0b1f-a42f-4df2-8540-6eb46d7618fb' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('11db0b1f-a42f-4df2-8540-6eb46d7618fb' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Links for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('11db0b1f-a42f-4df2-8540-6eb46d7618fb' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('11db0b1f-a42f-4df2-8540-6eb46d7618fb' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Video Providers */

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
         '6751908a-d102-49b0-ae57-a987496ca8e7',
         'MJ_BizApps_Tasks: Video Providers',
         'Video Providers',
         'A video-conferencing provider a meeting can be hosted on: Zoom, Teams or Google Meet. Its secrets live in MemberJunction''s credential store; the row holds only the driver and non-secret settings. Ships inactive until a host configures it.',
         NULL,
         'VideoProvider',
         'vwVideoProviders',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Video Providers to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '6751908a-d102-49b0-ae57-a987496ca8e7', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Video Providers for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('6751908a-d102-49b0-ae57-a987496ca8e7' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('6751908a-d102-49b0-ae57-a987496ca8e7' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Video Providers for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('6751908a-d102-49b0-ae57-a987496ca8e7' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('6751908a-d102-49b0-ae57-a987496ca8e7' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Video Providers for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('6751908a-d102-49b0-ae57-a987496ca8e7' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('6751908a-d102-49b0-ae57-a987496ca8e7' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Meeting Types */

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
         '7967eb2a-b969-41dc-a71d-0591c1e57353',
         'MJ_BizApps_Tasks: Meeting Types',
         'Meeting Types',
         'A kind of meeting: General, One-on-one, Team, Client, Review, or one an app adds. Carries the defaults a new meeting of the type starts with and its agenda template.',
         NULL,
         'MeetingType',
         'vwMeetingTypes',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Meeting Types to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '7967eb2a-b969-41dc-a71d-0591c1e57353', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Types for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('7967eb2a-b969-41dc-a71d-0591c1e57353' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('7967eb2a-b969-41dc-a71d-0591c1e57353' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Types for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('7967eb2a-b969-41dc-a71d-0591c1e57353' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('7967eb2a-b969-41dc-a71d-0591c1e57353' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Types for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('7967eb2a-b969-41dc-a71d-0591c1e57353' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('7967eb2a-b969-41dc-a71d-0591c1e57353' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Meeting Agenda Item Types */

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
         'd0563da6-bf5b-45ea-93c9-a9678cb303da',
         'MJ_BizApps_Tasks: Meeting Agenda Item Types',
         'Meeting Agenda Item Types',
         'A kind of agenda item: Information, Discussion, Decision, Report, Presentation, Action review, Break, or one an app adds, such as Committees'' Vote. A lookup rather than a fixed list, so apps extend it.',
         NULL,
         'MeetingAgendaItemType',
         'vwMeetingAgendaItemTypes',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Meeting Agenda Item Types to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'd0563da6-bf5b-45ea-93c9-a9678cb303da', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Agenda Item Types for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('d0563da6-bf5b-45ea-93c9-a9678cb303da' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('d0563da6-bf5b-45ea-93c9-a9678cb303da' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Agenda Item Types for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('d0563da6-bf5b-45ea-93c9-a9678cb303da' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('d0563da6-bf5b-45ea-93c9-a9678cb303da' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Agenda Item Types for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('d0563da6-bf5b-45ea-93c9-a9678cb303da' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('d0563da6-bf5b-45ea-93c9-a9678cb303da' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Meeting Series */

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
         '9ecac4df-039c-4b96-84d4-0be2bd481269',
         'MJ_BizApps_Tasks: Meeting Series',
         'Meeting Series',
         'A recurring meeting. Its occurrences are real Meeting rows, made ahead of time up to a horizon; each keeps its own agenda and attendance, and one can move or be cancelled without touching the rest.',
         NULL,
         'MeetingSeries',
         'vwMeetingSeries',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Meeting Series to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '9ecac4df-039c-4b96-84d4-0be2bd481269', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Series for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('9ecac4df-039c-4b96-84d4-0be2bd481269' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('9ecac4df-039c-4b96-84d4-0be2bd481269' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Series for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('9ecac4df-039c-4b96-84d4-0be2bd481269' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('9ecac4df-039c-4b96-84d4-0be2bd481269' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Series for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('9ecac4df-039c-4b96-84d4-0be2bd481269' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('9ecac4df-039c-4b96-84d4-0be2bd481269' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Meetings */

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
         '83bb5923-29c9-4cbb-94c4-35601da29ddd',
         'MJ_BizApps_Tasks: Meetings',
         'Meetings',
         'One meeting: a single occurrence with its own time, place, attendees, agenda, notes and follow-ups. An occurrence of a series points at its series and keeps the series'' original slot as its name.',
         NULL,
         'Meeting',
         'vwMeetings',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Meetings to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '83bb5923-29c9-4cbb-94c4-35601da29ddd', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meetings for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('83bb5923-29c9-4cbb-94c4-35601da29ddd' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('83bb5923-29c9-4cbb-94c4-35601da29ddd' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meetings for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('83bb5923-29c9-4cbb-94c4-35601da29ddd' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('83bb5923-29c9-4cbb-94c4-35601da29ddd' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meetings for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('83bb5923-29c9-4cbb-94c4-35601da29ddd' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('83bb5923-29c9-4cbb-94c4-35601da29ddd' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Meeting Series Attendees */

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
         'cf246e72-7bc1-4285-8f37-7c8d89e7a23c',
         'MJ_BizApps_Tasks: Meeting Series Attendees',
         'Meeting Series Attendees',
         'Who each new occurrence of a series invites: a person, or a guest by email address. The organizer comes from the series itself.',
         NULL,
         'MeetingSeriesAttendee',
         'vwMeetingSeriesAttendees',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Meeting Series Attendees to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'cf246e72-7bc1-4285-8f37-7c8d89e7a23c', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Series Attendees for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('cf246e72-7bc1-4285-8f37-7c8d89e7a23c' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('cf246e72-7bc1-4285-8f37-7c8d89e7a23c' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Series Attendees for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('cf246e72-7bc1-4285-8f37-7c8d89e7a23c' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('cf246e72-7bc1-4285-8f37-7c8d89e7a23c' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Series Attendees for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('cf246e72-7bc1-4285-8f37-7c8d89e7a23c' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('cf246e72-7bc1-4285-8f37-7c8d89e7a23c' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Meeting Attendees */

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
         '69a03d0b-f654-40b6-9b90-94dec8948aa2',
         'MJ_BizApps_Tasks: Meeting Attendees',
         'Meeting Attendees',
         'Someone invited to a meeting: a person, or a guest by email address; their answer to the invitation; and whether they came. A meeting has exactly one Organizer row.',
         NULL,
         'MeetingAttendee',
         'vwMeetingAttendees',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Meeting Attendees to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '69a03d0b-f654-40b6-9b90-94dec8948aa2', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Attendees for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('69a03d0b-f654-40b6-9b90-94dec8948aa2' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('69a03d0b-f654-40b6-9b90-94dec8948aa2' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Attendees for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('69a03d0b-f654-40b6-9b90-94dec8948aa2' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('69a03d0b-f654-40b6-9b90-94dec8948aa2' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Attendees for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('69a03d0b-f654-40b6-9b90-94dec8948aa2' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('69a03d0b-f654-40b6-9b90-94dec8948aa2' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Meeting Agenda Items */

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
         'e089fa02-a8aa-485f-a002-870f5c248e38',
         'MJ_BizApps_Tasks: Meeting Agenda Items',
         'Meeting Agenda Items',
         'One item on a meeting''s agenda, nestable under a parent item of the same meeting, with its type, presenter, planned duration, what happened to it and what was agreed.',
         NULL,
         'MeetingAgendaItem',
         'vwMeetingAgendaItems',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Meeting Agenda Items to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'e089fa02-a8aa-485f-a002-870f5c248e38', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Agenda Items for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('e089fa02-a8aa-485f-a002-870f5c248e38' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('e089fa02-a8aa-485f-a002-870f5c248e38' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Agenda Items for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('e089fa02-a8aa-485f-a002-870f5c248e38' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('e089fa02-a8aa-485f-a002-870f5c248e38' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Agenda Items for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('e089fa02-a8aa-485f-a002-870f5c248e38' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('e089fa02-a8aa-485f-a002-870f5c248e38' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL text to update existing entities from schema */
EXEC [${mjSchema}].[spUpdateExistingEntitiesFromSchema] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingType */
ALTER TABLE [${flyway:defaultSchema}].[MeetingType] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingType */
UPDATE [${flyway:defaultSchema}].[MeetingType] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingType */
ALTER TABLE [${flyway:defaultSchema}].[MeetingType] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingType */
ALTER TABLE [${flyway:defaultSchema}].[MeetingType] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingType___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingType */
ALTER TABLE [${flyway:defaultSchema}].[MeetingType] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingType */
UPDATE [${flyway:defaultSchema}].[MeetingType] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingType */
ALTER TABLE [${flyway:defaultSchema}].[MeetingType] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingType */
ALTER TABLE [${flyway:defaultSchema}].[MeetingType] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingType___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingSeries */
ALTER TABLE [${flyway:defaultSchema}].[MeetingSeries] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingSeries */
UPDATE [${flyway:defaultSchema}].[MeetingSeries] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingSeries */
ALTER TABLE [${flyway:defaultSchema}].[MeetingSeries] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingSeries */
ALTER TABLE [${flyway:defaultSchema}].[MeetingSeries] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingSeries___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingSeries */
ALTER TABLE [${flyway:defaultSchema}].[MeetingSeries] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingSeries */
UPDATE [${flyway:defaultSchema}].[MeetingSeries] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingSeries */
ALTER TABLE [${flyway:defaultSchema}].[MeetingSeries] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingSeries */
ALTER TABLE [${flyway:defaultSchema}].[MeetingSeries] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingSeries___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.Meeting */
ALTER TABLE [${flyway:defaultSchema}].[Meeting] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.Meeting */
UPDATE [${flyway:defaultSchema}].[Meeting] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.Meeting */
ALTER TABLE [${flyway:defaultSchema}].[Meeting] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.Meeting */
ALTER TABLE [${flyway:defaultSchema}].[Meeting] ADD CONSTRAINT [DF___mj_BizAppsTasks_Meeting___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.Meeting */
ALTER TABLE [${flyway:defaultSchema}].[Meeting] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.Meeting */
UPDATE [${flyway:defaultSchema}].[Meeting] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.Meeting */
ALTER TABLE [${flyway:defaultSchema}].[Meeting] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.Meeting */
ALTER TABLE [${flyway:defaultSchema}].[Meeting] ADD CONSTRAINT [DF___mj_BizAppsTasks_Meeting___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingLink */
ALTER TABLE [${flyway:defaultSchema}].[MeetingLink] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingLink */
UPDATE [${flyway:defaultSchema}].[MeetingLink] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingLink */
ALTER TABLE [${flyway:defaultSchema}].[MeetingLink] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingLink */
ALTER TABLE [${flyway:defaultSchema}].[MeetingLink] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingLink___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingLink */
ALTER TABLE [${flyway:defaultSchema}].[MeetingLink] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingLink */
UPDATE [${flyway:defaultSchema}].[MeetingLink] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingLink */
ALTER TABLE [${flyway:defaultSchema}].[MeetingLink] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingLink */
ALTER TABLE [${flyway:defaultSchema}].[MeetingLink] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingLink___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingSeriesAttendee */
ALTER TABLE [${flyway:defaultSchema}].[MeetingSeriesAttendee] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingSeriesAttendee */
UPDATE [${flyway:defaultSchema}].[MeetingSeriesAttendee] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingSeriesAttendee */
ALTER TABLE [${flyway:defaultSchema}].[MeetingSeriesAttendee] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingSeriesAttendee */
ALTER TABLE [${flyway:defaultSchema}].[MeetingSeriesAttendee] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingSeriesAttendee___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingSeriesAttendee */
ALTER TABLE [${flyway:defaultSchema}].[MeetingSeriesAttendee] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingSeriesAttendee */
UPDATE [${flyway:defaultSchema}].[MeetingSeriesAttendee] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingSeriesAttendee */
ALTER TABLE [${flyway:defaultSchema}].[MeetingSeriesAttendee] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingSeriesAttendee */
ALTER TABLE [${flyway:defaultSchema}].[MeetingSeriesAttendee] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingSeriesAttendee___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItem */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAgendaItem] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItem */
UPDATE [${flyway:defaultSchema}].[MeetingAgendaItem] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItem */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAgendaItem] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItem */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAgendaItem] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingAgendaItem___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItem */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAgendaItem] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItem */
UPDATE [${flyway:defaultSchema}].[MeetingAgendaItem] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItem */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAgendaItem] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItem */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAgendaItem] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingAgendaItem___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingAttendee */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAttendee] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingAttendee */
UPDATE [${flyway:defaultSchema}].[MeetingAttendee] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingAttendee */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAttendee] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingAttendee */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAttendee] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingAttendee___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingAttendee */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAttendee] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingAttendee */
UPDATE [${flyway:defaultSchema}].[MeetingAttendee] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingAttendee */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAttendee] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingAttendee */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAttendee] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingAttendee___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItemType */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAgendaItemType] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItemType */
UPDATE [${flyway:defaultSchema}].[MeetingAgendaItemType] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItemType */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAgendaItemType] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItemType */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAgendaItemType] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingAgendaItemType___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItemType */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAgendaItemType] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItemType */
UPDATE [${flyway:defaultSchema}].[MeetingAgendaItemType] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItemType */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAgendaItemType] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingAgendaItemType */
ALTER TABLE [${flyway:defaultSchema}].[MeetingAgendaItemType] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingAgendaItemType___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.VideoProvider */
ALTER TABLE [${flyway:defaultSchema}].[VideoProvider] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.VideoProvider */
UPDATE [${flyway:defaultSchema}].[VideoProvider] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.VideoProvider */
ALTER TABLE [${flyway:defaultSchema}].[VideoProvider] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.VideoProvider */
ALTER TABLE [${flyway:defaultSchema}].[VideoProvider] ADD CONSTRAINT [DF___mj_BizAppsTasks_VideoProvider___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.VideoProvider */
ALTER TABLE [${flyway:defaultSchema}].[VideoProvider] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.VideoProvider */
UPDATE [${flyway:defaultSchema}].[VideoProvider] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.VideoProvider */
ALTER TABLE [${flyway:defaultSchema}].[VideoProvider] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.VideoProvider */
ALTER TABLE [${flyway:defaultSchema}].[VideoProvider] ADD CONSTRAINT [DF___mj_BizAppsTasks_VideoProvider___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingNote */
ALTER TABLE [${flyway:defaultSchema}].[MeetingNote] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingNote */
UPDATE [${flyway:defaultSchema}].[MeetingNote] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingNote */
ALTER TABLE [${flyway:defaultSchema}].[MeetingNote] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.MeetingNote */
ALTER TABLE [${flyway:defaultSchema}].[MeetingNote] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingNote___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingNote */
ALTER TABLE [${flyway:defaultSchema}].[MeetingNote] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingNote */
UPDATE [${flyway:defaultSchema}].[MeetingNote] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingNote */
ALTER TABLE [${flyway:defaultSchema}].[MeetingNote] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.MeetingNote */
ALTER TABLE [${flyway:defaultSchema}].[MeetingNote] ADD CONSTRAINT [DF___mj_BizAppsTasks_MeetingNote___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to insert 144 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c1c3311b-42f2-46bc-9cc2-1d6fbfd94c91' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c1c3311b-42f2-46bc-9cc2-1d6fbfd94c91',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '54665294-5ffd-42e1-8e16-0c13c2d897e6' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = 'Name')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '54665294-5ffd-42e1-8e16-0c13c2d897e6',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
            'Name',
            'Name',
            'The type''s display name. Unique.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f1993bb9-daae-44a8-a462-2cd4d842bce7' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = 'Code')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f1993bb9-daae-44a8-a462-2cd4d842bce7',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
            'Code',
            'Code',
            'A stable code apps refer to, as TaskType.Code. Unique.',
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
            1,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '517da901-866b-4333-87bd-c5ca81309ba2' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = 'Description')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '517da901-866b-4333-87bd-c5ca81309ba2',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
            'Description',
            'Description',
            'What meetings of this type are for.',
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
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'cb3249c3-3ff5-410e-95dc-09f4bfa10d1a' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = 'IconClass')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'cb3249c3-3ff5-410e-95dc-09f4bfa10d1a',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
            'IconClass',
            'Icon Class',
            'Font Awesome icon class shown beside the type.',
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
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'adb2bad7-156c-4856-bef9-f2c8d8d60f64' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = 'DefaultDurationMinutes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'adb2bad7-156c-4856-bef9-f2c8d8d60f64',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
            'DefaultDurationMinutes',
            'Default Duration Minutes',
            'How long a new meeting of this type lasts unless the organizer says otherwise. More than 0.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '644bd683-920d-4b14-8cd3-691e46292dc7' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = 'DefaultLocationType')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '644bd683-920d-4b14-8cd3-691e46292dc7',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
            'DefaultLocationType',
            'Default Location Type',
            'The location a new meeting of this type starts with: Virtual, InPerson, Hybrid or Phone.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '86ab2716-8a34-43f6-bdf0-881ac39981d3' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = 'DefaultVideoProviderID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '86ab2716-8a34-43f6-bdf0-881ac39981d3',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
            'DefaultVideoProviderID',
            'Default Video Provider ID',
            'The video provider a new virtual meeting of this type is hosted on.',
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
            '6751908A-D102-49B0-AE57-A987496CA8E7',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2be312a6-8e78-42a5-8cb0-3a3d1db65b4f' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = 'DefaultVisibility')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2be312a6-8e78-42a5-8cb0-3a3d1db65b4f',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
            'DefaultVisibility',
            'Default Visibility',
            'The visibility a new meeting of this type starts with: Standard or Private.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ffc5d903-c882-4a4a-b905-eb01f5aa5ae8' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = 'AgendaTemplate')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ffc5d903-c882-4a4a-b905-eb01f5aa5ae8',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
            'AgendaTemplate',
            'Agenda Template',
            'JSON: the agenda a new meeting of this type starts with, as items with a title, an agenda item type code, a duration in minutes and sub-items.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '73d48712-5706-4222-95c5-43efcbca1a8c' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = 'NotesPromptID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '73d48712-5706-4222-95c5-43efcbca1a8c',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
            'NotesPromptID',
            'Notes Prompt ID',
            'The MJ: AI Prompts record that drafts notes from a transcript for this type, instead of the shipped prompt.',
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
            '73AD0238-8B56-EF11-991A-6045BDEBA539',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6482e23f-94ab-4692-8b9a-e79ba373206e' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = 'IsActive')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6482e23f-94ab-4692-8b9a-e79ba373206e',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
            'IsActive',
            'Is Active',
            'When false, the type is kept for existing meetings but not offered for new ones.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'cadedc29-cada-46a0-9e68-caf777a2f1a8' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = 'Sequence')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'cadedc29-cada-46a0-9e68-caf777a2f1a8',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
            'Sequence',
            'Sequence',
            'Display order among types.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '84b99f38-e980-4cc4-932b-5ecef135666b' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '84b99f38-e980-4cc4-932b-5ecef135666b',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1e3cc4b6-fb14-46ce-983f-bc607b78f72e' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1e3cc4b6-fb14-46ce-983f-bc607b78f72e',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'eb18db1f-0383-413d-ab11-7fa47d22f744' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'eb18db1f-0383-413d-ab11-7fa47d22f744',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8004b7d1-bf55-44ca-8990-91b93343e162' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'Name')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8004b7d1-bf55-44ca-8990-91b93343e162',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'Name',
            'Name',
            'The series'' title. Each new occurrence starts with it.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '65508a56-4dd4-41e4-9111-ee503bbfd323' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'Description')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '65508a56-4dd4-41e4-9111-ee503bbfd323',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'Description',
            'Description',
            'The series'' purpose, in Markdown. Each new occurrence starts with it.',
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
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fbb88c84-bfea-4fcb-b6d0-c40970fb7227' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'TypeID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'fbb88c84-bfea-4fcb-b6d0-c40970fb7227',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'TypeID',
            'Type ID',
            'The meeting type each occurrence is made from.',
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
            '7967EB2A-B969-41DC-A71D-0591C1E57353',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '00bb9f84-29e8-4c39-9b3e-44ae52b87c42' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'OrganizerPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '00bb9f84-29e8-4c39-9b3e-44ae52b87c42',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'OrganizerPersonID',
            'Organizer Person ID',
            'The person who organizes the series. Each occurrence starts with them as its organizer.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5583b7e8-4624-4778-8c9b-ee15dec2275d' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'RecurrenceRule')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5583b7e8-4624-4778-8c9b-ee15dec2275d',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'RecurrenceRule',
            'Recurrence Rule',
            'An RFC 5545 RRULE value, such as FREQ=WEEKLY;BYDAY=TU. Its UNTIL or COUNT ends the series.',
            'nvarchar',
            1000,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6eeaf90e-6c8d-46c1-935f-13bc15f5a395' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'TimeZone')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6eeaf90e-6c8d-46c1-935f-13bc15f5a395',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'TimeZone',
            'Time Zone',
            'The IANA time zone the rule is expanded in, such as America/Chicago, so a 9:00 meeting stays at 9:00 across daylight-saving changes.',
            'nvarchar',
            128,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6daecf3e-748c-4b51-9b42-8f095d513a6e' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'FirstStartsAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6daecf3e-748c-4b51-9b42-8f095d513a6e',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'FirstStartsAt',
            'First Starts At',
            'The rule''s DTSTART: when the first occurrence starts.',
            'datetimeoffset',
            10,
            34,
            7,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e92cd564-063f-4b1d-afc2-66ffd2f6f4f9' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'DurationMinutes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e92cd564-063f-4b1d-afc2-66ffd2f6f4f9',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'DurationMinutes',
            'Duration Minutes',
            'How long each occurrence lasts. More than 0.',
            'int',
            4,
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
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f0be87eb-6629-4b07-a288-84b373c44102' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'LocationType')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f0be87eb-6629-4b07-a288-84b373c44102',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'LocationType',
            'Location Type',
            'The location each new occurrence starts with: Virtual, InPerson, Hybrid or Phone.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Virtual',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'bcaaf8d4-4e2d-4e7c-a880-1922a589b019' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'Location')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'bcaaf8d4-4e2d-4e7c-a880-1922a589b019',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'Location',
            'Location',
            'The room or address each new occurrence starts with.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6e4c25e9-380e-42b3-925d-61ba97760279' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'VideoProviderID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6e4c25e9-380e-42b3-925d-61ba97760279',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'VideoProviderID',
            'Video Provider ID',
            'The video provider each new virtual occurrence is hosted on.',
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
            '6751908A-D102-49B0-AE57-A987496CA8E7',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'df21c626-8de5-4d74-89db-572ea93c1c9c' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'Visibility')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'df21c626-8de5-4d74-89db-572ea93c1c9c',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'Visibility',
            'Visibility',
            'The visibility each new occurrence starts with: Standard, or Private for its attendees only.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Standard',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '222fc8e1-118e-47ae-8d44-140185534ee4' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'Status')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '222fc8e1-118e-47ae-8d44-140185534ee4',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'Status',
            'Status',
            'Active while occurrences are still made; Ended once the rule has run out; Cancelled when the series was stopped.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Active',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0b168d0a-7e23-4400-a043-467dee21ec20' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'MaterializedThrough')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0b168d0a-7e23-4400-a043-467dee21ec20',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'MaterializedThrough',
            'Materialized Through',
            'Occurrences exist up to this point in time. The scheduled job and a save extend it.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ef848a75-8da4-4772-8870-b606bbaa1c42' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'CreatedByPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ef848a75-8da4-4772-8870-b606bbaa1c42',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'CreatedByPersonID',
            'Created By Person ID',
            'The person who created the series, as Task.CreatedByPersonID.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '618d3fe1-dd26-4004-9de1-16f4cb261462' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '618d3fe1-dd26-4004-9de1-16f4cb261462',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7ee5b8ef-e535-49b1-953a-94e1fa99db74' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7ee5b8ef-e535-49b1-953a-94e1fa99db74',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b82cd373-b034-4613-88e7-6207c075c3bb' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b82cd373-b034-4613-88e7-6207c075c3bb',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '14777148-7099-4a9e-90ee-171e1c3a246b' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'Name')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '14777148-7099-4a9e-90ee-171e1c3a246b',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'Name',
            'Name',
            'The meeting''s title, as Task.Name is a task''s.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5d23e84d-4b86-48df-bbf5-db616d2e2d2d' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'Description')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5d23e84d-4b86-48df-bbf5-db616d2e2d2d',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'Description',
            'Description',
            'The meeting''s purpose, in Markdown.',
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
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b0bb59cb-cc1f-474a-94b4-00efd53282d8' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'TypeID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b0bb59cb-cc1f-474a-94b4-00efd53282d8',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'TypeID',
            'Type ID',
            'The meeting type it was made from, which gave its defaults and agenda template.',
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
            '7967EB2A-B969-41DC-A71D-0591C1E57353',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '766c5b07-2435-43f7-afb9-b52379a05fe5' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'SeriesID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '766c5b07-2435-43f7-afb9-b52379a05fe5',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'SeriesID',
            'Series ID',
            'The series this meeting is an occurrence of, when it is one.',
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
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '338e7f5d-3d29-4b2d-a647-ada73ac1576d' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'OccurrenceStartsAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '338e7f5d-3d29-4b2d-a647-ada73ac1576d',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'OccurrenceStartsAt',
            'Occurrence Starts At',
            'The series'' original slot for this occurrence. It names the occurrence after it moves, so the series does not make it again. Set with SeriesID, empty without it.',
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8506e396-ccf3-4f7f-adec-9113641a1759' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'Status')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8506e396-ccf3-4f7f-adec-9113641a1759',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'Status',
            'Status',
            'Draft, Scheduled, Postponed, InProgress, Completed or Cancelled. The server moves it forward: Draft to Scheduled to InProgress to Completed; Scheduled and Postponed either way; anything but Completed may be Cancelled.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Scheduled',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8310b0af-b0a7-4c4a-af2b-c13d77ffa2b7' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'StartsAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8310b0af-b0a7-4c4a-af2b-c13d77ffa2b7',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'StartsAt',
            'Starts At',
            'When the meeting is planned to start.',
            'datetimeoffset',
            10,
            34,
            7,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6abc9840-ab83-4c42-9fd7-f1c9e5e33c66' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'EndsAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6abc9840-ab83-4c42-9fd7-f1c9e5e33c66',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'EndsAt',
            'Ends At',
            'When the meeting is planned to end. Later than StartsAt.',
            'datetimeoffset',
            10,
            34,
            7,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '58fee423-76b8-403e-ad6b-ae0a48c22d67' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'TimeZone')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '58fee423-76b8-403e-ad6b-ae0a48c22d67',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'TimeZone',
            'Time Zone',
            'The IANA time zone the meeting is planned in, such as America/Chicago. Display and recurrence use it. Defaults from the organizer''s setting, else the business time zone.',
            'nvarchar',
            128,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c1451e38-09d5-41da-9373-a62bbc5071cf' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'LocationType')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c1451e38-09d5-41da-9373-a62bbc5071cf',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'LocationType',
            'Location Type',
            'Virtual, InPerson, Hybrid or Phone.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Virtual',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c1873111-dea8-40f5-9cb5-18638762b2cd' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'Location')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c1873111-dea8-40f5-9cb5-18638762b2cd',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'Location',
            'Location',
            'A room or an address, for an in-person or hybrid meeting.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a3b820b7-9fa2-43f3-b5f6-05eb8145aeb7' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'VideoProviderID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a3b820b7-9fa2-43f3-b5f6-05eb8145aeb7',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'VideoProviderID',
            'Video Provider ID',
            'The video provider the meeting is hosted on, for a virtual or hybrid meeting.',
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
            '6751908A-D102-49B0-AE57-A987496CA8E7',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd4c0abf1-db2e-4df6-a319-8cf2c6e97dce' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'VideoMeetingID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd4c0abf1-db2e-4df6-a319-8cf2c6e97dce',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'VideoMeetingID',
            'Video Meeting ID',
            'The provider''s own ID for the meeting, kept to update or delete it there.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '67027709-e3b0-4a3a-907d-a029a3193c84' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'VideoJoinURL')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '67027709-e3b0-4a3a-907d-a029a3193c84',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'VideoJoinURL',
            'Video Join URL',
            'The link attendees join by, from the provider or typed in.',
            'nvarchar',
            2000,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '069079f4-0390-4188-82b9-49778e6ae60a' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'DialInDetails')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '069079f4-0390-4188-82b9-49778e6ae60a',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'DialInDetails',
            'Dial In Details',
            'Phone numbers and access codes for joining by phone.',
            'nvarchar',
            2000,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3e551302-f355-4db0-867a-2bc81441ebb7' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'OrganizerPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3e551302-f355-4db0-867a-2bc81441ebb7',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'OrganizerPersonID',
            'Organizer Person ID',
            'The person who organizes the meeting. Their calendar holds its event, and the meeting always has their attendee row.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '392e3392-8e5a-4090-8118-86b4cd6045bd' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'Visibility')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '392e3392-8e5a-4090-8118-86b4cd6045bd',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'Visibility',
            'Visibility',
            'Standard: readable by anyone who reads meetings. Private: readable only by its attendees, the organizer included.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Standard',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b0684687-20cb-4717-b3dd-eef0c3e74b81' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'ActualStartedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b0684687-20cb-4717-b3dd-eef0c3e74b81',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'ActualStartedAt',
            'Actual Started At',
            'When the live meeting was started.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a33b4e11-7522-49b7-aa9b-90d55020253d' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'ActualEndedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a33b4e11-7522-49b7-aa9b-90d55020253d',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'ActualEndedAt',
            'Actual Ended At',
            'When the live meeting was ended.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '53ad32e5-7db7-4909-a405-7a79670a9615' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'CancelledAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '53ad32e5-7db7-4909-a405-7a79670a9615',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'CancelledAt',
            'Cancelled At',
            'When the meeting was cancelled. Stamped by the server with the status.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3ebcd61d-e7d2-4929-9aaf-586df17855c0' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'CancellationReason')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3ebcd61d-e7d2-4929-9aaf-586df17855c0',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'CancellationReason',
            'Cancellation Reason',
            'Why the meeting was cancelled, for its attendees.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '06cf0403-a889-4156-8ca9-f71cbd8871c9' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'VideoRecordingURL')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '06cf0403-a889-4156-8ca9-f71cbd8871c9',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'VideoRecordingURL',
            'Video Recording URL',
            'Where the provider''s recording can be watched.',
            'nvarchar',
            2000,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9cda5909-4be3-42e1-a29d-f1e1768e7da9' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'TranscriptFileID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9cda5909-4be3-42e1-a29d-f1e1768e7da9',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'TranscriptFileID',
            'Transcript File ID',
            'The MJ: Files record holding the transcript, uploaded by a person or saved there by the provider''s driver. A transcript is a file in MemberJunction''s storage, never a URL a user typed.',
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
            '29248F34-2837-EF11-86D4-6045BDEE16E6',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'bf1d9416-b0e0-4737-ada7-41793f2ad8cf' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'CreatedByPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'bf1d9416-b0e0-4737-ada7-41793f2ad8cf',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'CreatedByPersonID',
            'Created By Person ID',
            'The person who created the meeting, as Task.CreatedByPersonID.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c7faffa9-9ecd-438e-8569-920ab6ab6960' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c7faffa9-9ecd-438e-8569-920ab6ab6960',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8d27d959-3e50-455e-9150-b1c530b979ca' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8d27d959-3e50-455e-9150-b1c530b979ca',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '116cf30c-710f-47e2-9c1e-fc8c0bf753ac' OR (EntityID = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '116cf30c-710f-47e2-9c1e-fc8c0bf753ac',
            '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB'),
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7ea119ce-ffcc-44b5-a0ef-a6b6dcd23dee' OR (EntityID = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB' AND Name = 'MeetingID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7ea119ce-ffcc-44b5-a0ef-a6b6dcd23dee',
            '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB'),
            'MeetingID',
            'Meeting ID',
            'The meeting that belongs to the record. Either this or SeriesID is set.',
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
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a9db3840-f16f-4423-963f-43ce244a05bb' OR (EntityID = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB' AND Name = 'SeriesID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a9db3840-f16f-4423-963f-43ce244a05bb',
            '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB'),
            'SeriesID',
            'Series ID',
            'The series that belongs to the record. Either this or MeetingID is set.',
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
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '656110df-c022-4769-90ce-94f1e84f1d07' OR (EntityID = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB' AND Name = 'EntityID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '656110df-c022-4769-90ce-94f1e84f1d07',
            '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB'),
            'EntityID',
            'Entity ID',
            'The entity of the record the meeting belongs to.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2dcce0c0-75ac-478a-b5dd-b4a270a58a5f' OR (EntityID = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB' AND Name = 'RecordID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2dcce0c0-75ac-478a-b5dd-b4a270a58a5f',
            '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB'),
            'RecordID',
            'Record ID',
            'The record''s primary key, as on TaskLink.',
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
            1,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5720194c-2814-4a4e-a0cf-9705cb888096' OR (EntityID = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB' AND Name = 'Description')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5720194c-2814-4a4e-a0cf-9705cb888096',
            '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB'),
            'Description',
            'Description',
            'Why the meeting belongs to the record.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '172e8690-a6b4-4e87-94ca-ab6687743b57' OR (EntityID = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '172e8690-a6b4-4e87-94ca-ab6687743b57',
            '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4913d9c0-2fd6-4cdb-b281-8e31a92686b7' OR (EntityID = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4913d9c0-2fd6-4cdb-b281-8e31a92686b7',
            '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'eac49adb-fdc6-40bf-85c1-2555546d627b' OR (EntityID = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'eac49adb-fdc6-40bf-85c1-2555546d627b',
            'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C'),
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '55594095-477d-4dbf-a456-f2ea486e2fb4' OR (EntityID = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C' AND Name = 'SeriesID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '55594095-477d-4dbf-a456-f2ea486e2fb4',
            'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C'),
            'SeriesID',
            'Series ID',
            'The series each new occurrence of which invites this attendee.',
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
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0d65faea-e5d9-4da7-83f1-2ee1efc53557' OR (EntityID = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C' AND Name = 'PersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0d65faea-e5d9-4da7-83f1-2ee1efc53557',
            'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C'),
            'PersonID',
            'Person ID',
            'The person invited, when they are a Person. Either this or Email is set.',
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '69cf2484-e8e5-4a9e-bebc-e2ae15755866' OR (EntityID = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C' AND Name = 'UserID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '69cf2484-e8e5-4a9e-bebc-e2ae15755866',
            'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C'),
            'UserID',
            'User ID',
            'The person''s MemberJunction user, when they have one, filled from the person''s account.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '81cad5e0-0c8a-43c6-895a-e71628607ced' OR (EntityID = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C' AND Name = 'Email')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '81cad5e0-0c8a-43c6-895a-e71628607ced',
            'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C'),
            'Email',
            'Email',
            'A guest''s address, or the address a person''s invitation goes to.',
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7a740a83-a5ea-47ad-977f-9b1a12a78c24' OR (EntityID = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C' AND Name = 'DisplayName')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7a740a83-a5ea-47ad-977f-9b1a12a78c24',
            'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C'),
            'DisplayName',
            'Display Name',
            'A guest''s name.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '403ab65c-c56d-4514-987b-e26bab64226e' OR (EntityID = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C' AND Name = 'Role')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '403ab65c-c56d-4514-987b-e26bab64226e',
            'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C'),
            'Role',
            'Role',
            'Required or Optional. The organizer is the series'' own.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Required',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '37aa822a-7bee-4616-9905-5a2dc154739d' OR (EntityID = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '37aa822a-7bee-4616-9905-5a2dc154739d',
            'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f0e2048e-4138-4832-aef6-cb67b3d0f79e' OR (EntityID = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f0e2048e-4138-4832-aef6-cb67b3d0f79e',
            'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ad995bff-b1b6-4a09-9b36-0f26d3ebac8b' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ad995bff-b1b6-4a09-9b36-0f26d3ebac8b',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '92b77569-07d4-437b-98a4-b5d16dfec3e7' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'MeetingID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '92b77569-07d4-437b-98a4-b5d16dfec3e7',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'MeetingID',
            'Meeting ID',
            'The meeting the item is on the agenda of.',
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
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f522109a-03c2-445a-9295-01294b0eabf3' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'ParentID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f522109a-03c2-445a-9295-01294b0eabf3',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'ParentID',
            'Parent ID',
            'The item this one sits under, for a sub-item. Same meeting, no cycle.',
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
            'E089FA02-A8AA-485F-A002-870F5C248E38',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '24ac79e7-a97b-4f3f-b8e8-9fa09fe9194b' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'Sequence')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '24ac79e7-a97b-4f3f-b8e8-9fa09fe9194b',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'Sequence',
            'Sequence',
            'Order among its siblings.',
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
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a3ac7c01-deed-48f8-b2f5-1141f51aee79' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'Name')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a3ac7c01-deed-48f8-b2f5-1141f51aee79',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'Name',
            'Name',
            'The item''s title.',
            'nvarchar',
            1000,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '045b1181-019c-42d3-8111-10d6dc14fdf1' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'Description')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '045b1181-019c-42d3-8111-10d6dc14fdf1',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'Description',
            'Description',
            'What the item covers, in Markdown.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '223db792-c426-4a68-9600-c8f1b3368dd9' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'TypeID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '223db792-c426-4a68-9600-c8f1b3368dd9',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'TypeID',
            'Type ID',
            'The agenda item type: Information, Discussion, Decision, and so on.',
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
            'D0563DA6-BF5B-45EA-93C9-A9678CB303DA',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd7067566-f10a-4864-bc47-e54e02c88bd0' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'PresenterPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd7067566-f10a-4864-bc47-e54e02c88bd0',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'PresenterPersonID',
            'Presenter Person ID',
            'The person who presents the item.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'dd7fde48-5804-4e6e-8a03-771e8d84a263' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'DurationMinutes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'dd7fde48-5804-4e6e-8a03-771e8d84a263',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'DurationMinutes',
            'Duration Minutes',
            'How long the item is planned to take. 0 or more.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '64493942-192e-41a9-9bf8-2afd2f2a5caf' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'Status')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '64493942-192e-41a9-9bf8-2afd2f2a5caf',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'Status',
            'Status',
            'Planned, InProgress, Done, Deferred or Skipped.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Planned',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'dcf05d2a-9fe6-4a3c-92dc-9ba6e32ecf5d' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'StartedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'dcf05d2a-9fe6-4a3c-92dc-9ba6e32ecf5d',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'StartedAt',
            'Started At',
            'When the item was started, from the live meeting.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ad430fc5-d2c1-4e7f-a847-4e1461bd3113' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'EndedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ad430fc5-d2c1-4e7f-a847-4e1461bd3113',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'EndedAt',
            'Ended At',
            'When the item was ended.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e3f9f26e-2bf5-4ac9-af03-882bb1c2ce3c' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'Outcome')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e3f9f26e-2bf5-4ac9-af03-882bb1c2ce3c',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'Outcome',
            'Outcome',
            'What was agreed, in a sentence or two.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '89f24e04-00b7-410c-a6fc-8ec39550e3f1' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'DeferredToMeetingID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '89f24e04-00b7-410c-a6fc-8ec39550e3f1',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'DeferredToMeetingID',
            'Deferred To Meeting ID',
            'The later meeting a deferred item moved to.',
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
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'aa78c968-aca2-4f0b-97fc-8aea8714c9f3' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'aa78c968-aca2-4f0b-97fc-8aea8714c9f3',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '87266bd0-cbff-43b8-9d05-159472a480c0' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '87266bd0-cbff-43b8-9d05-159472a480c0',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a8a3696d-82d1-44ce-aedb-a4446298a72f' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a8a3696d-82d1-44ce-aedb-a4446298a72f',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '515575e9-a142-44b1-bd41-0eedd98902b2' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'MeetingID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '515575e9-a142-44b1-bd41-0eedd98902b2',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
            'MeetingID',
            'Meeting ID',
            'The meeting the attendee is invited to.',
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
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'db6f2ca4-e7c9-48c6-a128-525a9cf1588a' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'PersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'db6f2ca4-e7c9-48c6-a128-525a9cf1588a',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
            'PersonID',
            'Person ID',
            'The person invited, when they are a Person. Either this or Email is set.',
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'df1645d3-f3db-410d-8cbc-87cf854dba10' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'UserID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'df1645d3-f3db-410d-8cbc-87cf854dba10',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
            'UserID',
            'User ID',
            'The person''s MemberJunction user, when they have one, filled from the person''s account. My meetings and the private-meeting filter use it.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '57e09a60-2352-4a10-8d3b-65e28b18b029' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'Email')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '57e09a60-2352-4a10-8d3b-65e28b18b029',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
            'Email',
            'Email',
            'A guest''s address, or the address a person''s invitation goes to.',
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '606e05d2-d64c-4afd-af99-56f086a056bf' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'DisplayName')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '606e05d2-d64c-4afd-af99-56f086a056bf',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
            'DisplayName',
            'Display Name',
            'A guest''s name.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '749719db-782c-4cf1-9abb-fb4800cf01f0' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'Role')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '749719db-782c-4cf1-9abb-fb4800cf01f0',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
            'Role',
            'Role',
            'Organizer, Required or Optional. One Organizer row per meeting, kept in step with Meeting.OrganizerPersonID.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Required',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e278c1ae-95e7-4164-987f-d8b22bb9a181' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'ResponseStatus')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e278c1ae-95e7-4164-987f-d8b22bb9a181',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
            'ResponseStatus',
            'Response Status',
            'The answer to the invitation: None, Accepted, Tentative or Declined.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'None',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '65f3d11d-de58-4f99-816d-2f72d9681a04' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'RespondedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '65f3d11d-de58-4f99-816d-2f72d9681a04',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
            'RespondedAt',
            'Responded At',
            'When the invitation was answered.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ae7ad788-2d1e-4646-8fc1-7a27e0df0dbe' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'AttendanceStatus')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ae7ad788-2d1e-4646-8fc1-7a27e0df0dbe',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
            'AttendanceStatus',
            'Attendance Status',
            'Whether they came: Unknown, Present, Late, LeftEarly, Absent or Excused.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Unknown',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c82c54e3-77a2-476a-a8b0-0e7a87d34bef' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'JoinedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c82c54e3-77a2-476a-a8b0-0e7a87d34bef',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
            'JoinedAt',
            'Joined At',
            'When they joined, from the live meeting or the video provider.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '326f4f7c-bc3f-4b28-9f30-c9b4c87433a9' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'LeftAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '326f4f7c-bc3f-4b28-9f30-c9b4c87433a9',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
            'LeftAt',
            'Left At',
            'When they left.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd9253965-0eb8-494f-93aa-76cfb1775f3e' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'Notes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd9253965-0eb8-494f-93aa-76cfb1775f3e',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
            'Notes',
            'Notes',
            'A note on their attendance, such as why someone is excused.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'dcd4b220-20b9-420c-8847-933a27166887' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'dcd4b220-20b9-420c-8847-933a27166887',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c06f2d50-8139-4853-bb6a-576b67da623e' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c06f2d50-8139-4853-bb6a-576b67da623e',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1814cb17-e4b3-430e-a3cb-d733f5b78c01' OR (EntityID = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1814cb17-e4b3-430e-a3cb-d733f5b78c01',
            'D0563DA6-BF5B-45EA-93C9-A9678CB303DA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA'),
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '01fc2078-15ba-4001-a850-5ca9bee325d7' OR (EntityID = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA' AND Name = 'Name')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '01fc2078-15ba-4001-a850-5ca9bee325d7',
            'D0563DA6-BF5B-45EA-93C9-A9678CB303DA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA'),
            'Name',
            'Name',
            'The type''s display name. Unique.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '10031c74-f48c-47dc-a0a3-65545c152395' OR (EntityID = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA' AND Name = 'Code')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '10031c74-f48c-47dc-a0a3-65545c152395',
            'D0563DA6-BF5B-45EA-93C9-A9678CB303DA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA'),
            'Code',
            'Code',
            'A stable code apps and agenda templates refer to. Unique.',
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
            1,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'dbd50c35-ba15-45ec-a61f-c84e44075994' OR (EntityID = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA' AND Name = 'Description')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'dbd50c35-ba15-45ec-a61f-c84e44075994',
            'D0563DA6-BF5B-45EA-93C9-A9678CB303DA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA'),
            'Description',
            'Description',
            'What items of this type are for.',
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
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fa2aace2-c3f7-4c7c-8dae-2103ae71831b' OR (EntityID = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA' AND Name = 'IconClass')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'fa2aace2-c3f7-4c7c-8dae-2103ae71831b',
            'D0563DA6-BF5B-45EA-93C9-A9678CB303DA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA'),
            'IconClass',
            'Icon Class',
            'Font Awesome icon class shown beside the item.',
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
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9be359f0-aae2-4025-a535-769b6334ba4a' OR (EntityID = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA' AND Name = 'DefaultDurationMinutes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9be359f0-aae2-4025-a535-769b6334ba4a',
            'D0563DA6-BF5B-45EA-93C9-A9678CB303DA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA'),
            'DefaultDurationMinutes',
            'Default Duration Minutes',
            'How long an item of this type takes unless the agenda says otherwise. More than 0.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b085037a-ca6f-4c44-8229-6e963d7605cf' OR (EntityID = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA' AND Name = 'IsActive')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b085037a-ca6f-4c44-8229-6e963d7605cf',
            'D0563DA6-BF5B-45EA-93C9-A9678CB303DA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA'),
            'IsActive',
            'Is Active',
            'When false, the type is kept for existing items but not offered for new ones.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd668212f-ae18-450f-ab81-7fdcf765e33a' OR (EntityID = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA' AND Name = 'Sequence')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd668212f-ae18-450f-ab81-7fdcf765e33a',
            'D0563DA6-BF5B-45EA-93C9-A9678CB303DA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA'),
            'Sequence',
            'Sequence',
            'Display order among types.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c1f77741-abcb-4de1-9d4b-32b14093d84f' OR (EntityID = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c1f77741-abcb-4de1-9d4b-32b14093d84f',
            'D0563DA6-BF5B-45EA-93C9-A9678CB303DA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '02baa432-d3f4-480a-8242-1520db7bc94b' OR (EntityID = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '02baa432-d3f4-480a-8242-1520db7bc94b',
            'D0563DA6-BF5B-45EA-93C9-A9678CB303DA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f87cd02a-b040-429a-b15f-2afbaf868306' OR (EntityID = '6751908A-D102-49B0-AE57-A987496CA8E7' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f87cd02a-b040-429a-b15f-2afbaf868306',
            '6751908A-D102-49B0-AE57-A987496CA8E7', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7'),
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '50ebdc4e-5757-4a55-96a5-90a99d11509c' OR (EntityID = '6751908A-D102-49B0-AE57-A987496CA8E7' AND Name = 'Name')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '50ebdc4e-5757-4a55-96a5-90a99d11509c',
            '6751908A-D102-49B0-AE57-A987496CA8E7', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7'),
            'Name',
            'Name',
            'The provider''s display name. Unique.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3ececba5-e49a-49b8-8098-9270b9f8f40e' OR (EntityID = '6751908A-D102-49B0-AE57-A987496CA8E7' AND Name = 'Code')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3ececba5-e49a-49b8-8098-9270b9f8f40e',
            '6751908A-D102-49B0-AE57-A987496CA8E7', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7'),
            'Code',
            'Code',
            'A stable code apps refer to: ZOOM, TEAMS or GOOGLE_MEET. Unique.',
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
            1,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f0256582-a104-4a75-b9dd-41e41399d208' OR (EntityID = '6751908A-D102-49B0-AE57-A987496CA8E7' AND Name = 'DriverClass')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f0256582-a104-4a75-b9dd-41e41399d208',
            '6751908A-D102-49B0-AE57-A987496CA8E7', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7'),
            'DriverClass',
            'Driver Class',
            'The class the driver registers with MemberJunction''s class factory under VideoProviderBase.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f2a4081a-90d4-4ec3-abdb-2b2937a1c528' OR (EntityID = '6751908A-D102-49B0-AE57-A987496CA8E7' AND Name = 'Description')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f2a4081a-90d4-4ec3-abdb-2b2937a1c528',
            '6751908A-D102-49B0-AE57-A987496CA8E7', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7'),
            'Description',
            'Description',
            'What this provider is and when to use it.',
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
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'dfc6cf9a-c7f0-4dff-8365-1d932fb51248' OR (EntityID = '6751908A-D102-49B0-AE57-A987496CA8E7' AND Name = 'IconClass')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'dfc6cf9a-c7f0-4dff-8365-1d932fb51248',
            '6751908A-D102-49B0-AE57-A987496CA8E7', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7'),
            'IconClass',
            'Icon Class',
            'Font Awesome icon class shown beside the provider.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9f2a603f-b1a9-4182-9130-619def48e395' OR (EntityID = '6751908A-D102-49B0-AE57-A987496CA8E7' AND Name = 'CredentialID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9f2a603f-b1a9-4182-9130-619def48e395',
            '6751908A-D102-49B0-AE57-A987496CA8E7', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7'),
            'CredentialID',
            'Credential ID',
            'The MJ: Credentials record holding the provider''s secrets, decrypted through CredentialEngine. Never stored here.',
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
            '7E023DDF-82C6-4B0C-9650-8D35699B9FD0',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '633caa06-b6c0-4f3c-843f-305daf1359f8' OR (EntityID = '6751908A-D102-49B0-AE57-A987496CA8E7' AND Name = 'Configuration')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '633caa06-b6c0-4f3c-843f-305daf1359f8',
            '6751908A-D102-49B0-AE57-A987496CA8E7', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7'),
            'Configuration',
            'Configuration',
            'JSON: settings that are not secret, such as the organizer account or default meeting options.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6f7b4cc5-710f-423b-8ed7-afeac06d182b' OR (EntityID = '6751908A-D102-49B0-AE57-A987496CA8E7' AND Name = 'SupportsTranscripts')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6f7b4cc5-710f-423b-8ed7-afeac06d182b',
            '6751908A-D102-49B0-AE57-A987496CA8E7', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7'),
            'SupportsTranscripts',
            'Supports Transcripts',
            'When true, the driver can fetch a transcript of a recorded meeting.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '591e2257-54a4-4f57-8c9b-41ff28f9cf71' OR (EntityID = '6751908A-D102-49B0-AE57-A987496CA8E7' AND Name = 'IsDefault')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '591e2257-54a4-4f57-8c9b-41ff28f9cf71',
            '6751908A-D102-49B0-AE57-A987496CA8E7', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7'),
            'IsDefault',
            'Is Default',
            'When true, this is the provider a new virtual meeting uses unless its type says otherwise. One provider at most.',
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4a0e0628-05dd-4c43-ad71-105246eca628' OR (EntityID = '6751908A-D102-49B0-AE57-A987496CA8E7' AND Name = 'IsActive')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4a0e0628-05dd-4c43-ad71-105246eca628',
            '6751908A-D102-49B0-AE57-A987496CA8E7', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7'),
            'IsActive',
            'Is Active',
            'When true, the provider is configured and offered. Ships as 0.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '20e51b94-efd8-48a6-ad03-7f9825ef72e0' OR (EntityID = '6751908A-D102-49B0-AE57-A987496CA8E7' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '20e51b94-efd8-48a6-ad03-7f9825ef72e0',
            '6751908A-D102-49B0-AE57-A987496CA8E7', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '83ee1fa7-04bf-4ffc-9603-edc5377ad9eb' OR (EntityID = '6751908A-D102-49B0-AE57-A987496CA8E7' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '83ee1fa7-04bf-4ffc-9603-edc5377ad9eb',
            '6751908A-D102-49B0-AE57-A987496CA8E7', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'dbcc482b-a963-4da8-8afe-7cf95f1585a7' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'dbcc482b-a963-4da8-8afe-7cf95f1585a7',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'caaacdce-963a-43ee-ba6a-ba137657141d' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = 'MeetingID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'caaacdce-963a-43ee-ba6a-ba137657141d',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
            'MeetingID',
            'Meeting ID',
            'The meeting the note is about.',
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
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7c0572f4-3bfd-436d-a687-5236f735fb85' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = 'AgendaItemID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7c0572f4-3bfd-436d-a687-5236f735fb85',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
            'AgendaItemID',
            'Agenda Item ID',
            'The agenda item the note is about, for a note on one item.',
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
            'E089FA02-A8AA-485F-A002-870F5C248E38',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd786bd21-bfee-4caa-95ad-edd105705f13' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = 'Kind')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd786bd21-bfee-4caa-95ad-edd105705f13',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
            'Kind',
            'Kind',
            'Notes, Summary or Decision.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Notes',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '13910370-f103-4f3b-bbe5-25e7616c4e1e' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = 'Title')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '13910370-f103-4f3b-bbe5-25e7616c4e1e',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
            'Title',
            'Title',
            'The note''s title.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3dd9b702-06f2-45c2-b4f0-e09d9cfdb5dd' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = 'Body')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3dd9b702-06f2-45c2-b4f0-e09d9cfdb5dd',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
            'Body',
            'Body',
            'The note, in Markdown.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4702ba09-f341-4f12-a270-755e1510f51a' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = 'Source')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4702ba09-f341-4f12-a270-755e1510f51a',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
            'Source',
            'Source',
            'Manual for a person''s note; AI for a draft from a transcript.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Manual',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '445f98cd-8e8a-48e8-b670-dee27d496e01' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = 'Status')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '445f98cd-8e8a-48e8-b670-dee27d496e01',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
            'Status',
            'Status',
            'Draft or Final. Approving minutes is governance and stays with the app that owns it.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '50f0f9ad-3e5f-44ce-b52c-204119f86006' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = 'AuthorPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '50f0f9ad-3e5f-44ce-b52c-204119f86006',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
            'AuthorPersonID',
            'Author Person ID',
            'The person who wrote the note, for a person''s note.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '83550206-c6a8-41ab-99a6-05c5e38eb795' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = 'AIPromptRunID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '83550206-c6a8-41ab-99a6-05c5e38eb795',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
            'AIPromptRunID',
            'AI Prompt Run ID',
            'The MJ: AI Prompt Runs record the draft came from, for an AI note.',
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
            '7C1C98D0-3978-4CE8-8E3F-C90301E59767',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a9b69100-0260-40a1-aab2-3dfc86feb88c' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = 'ProposedTasks')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a9b69100-0260-40a1-aab2-3dfc86feb88c',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
            'ProposedTasks',
            'Proposed Tasks',
            'JSON: the action items the notes propose, each with a title, an assignee, a due date, its agenda item, and the task''s ID once a person accepted it. Nothing is filed without that approval.',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1d9f6670-8ebd-4e35-aca7-e9b69ba9ac93' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1d9f6670-8ebd-4e35-aca7-e9b69ba9ac93',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '99bece8b-036a-455c-b804-6b960290cf28' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '99bece8b-036a-455c-b804-6b960290cf28',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
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
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to insert entity field value with ID 1053f31a-d184-426f-8337-c9f6fd49594e */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1053f31a-d184-426f-8337-c9f6fd49594e', '64493942-192E-41A9-9BF8-2AFD2F2A5CAF', 1, 'Deferred', 'Deferred', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID ed8f064c-ac36-4e7e-b536-c1237b4ee5fb */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ed8f064c-ac36-4e7e-b536-c1237b4ee5fb', '64493942-192E-41A9-9BF8-2AFD2F2A5CAF', 2, 'Done', 'Done', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 51eb03fe-f163-4b80-b093-b91c430afa38 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('51eb03fe-f163-4b80-b093-b91c430afa38', '64493942-192E-41A9-9BF8-2AFD2F2A5CAF', 3, 'InProgress', 'InProgress', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 9090961a-9527-4311-b545-da4823cd4a96 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9090961a-9527-4311-b545-da4823cd4a96', '64493942-192E-41A9-9BF8-2AFD2F2A5CAF', 4, 'Planned', 'Planned', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID cfdfa425-3553-432d-b773-86d3f64bf166 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('cfdfa425-3553-432d-b773-86d3f64bf166', '64493942-192E-41A9-9BF8-2AFD2F2A5CAF', 5, 'Skipped', 'Skipped', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 64493942-192E-41A9-9BF8-2AFD2F2A5CAF */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='64493942-192E-41A9-9BF8-2AFD2F2A5CAF';

/* SQL text to insert entity field value with ID 72ee63b7-87ca-4143-ad12-ed7d2a2493d8 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('72ee63b7-87ca-4143-ad12-ed7d2a2493d8', 'D786BD21-BFEE-4CAA-95AD-EDD105705F13', 1, 'Decision', 'Decision', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 4f5b9aff-7e02-47a7-9d7d-fe2ec721355c */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('4f5b9aff-7e02-47a7-9d7d-fe2ec721355c', 'D786BD21-BFEE-4CAA-95AD-EDD105705F13', 2, 'Notes', 'Notes', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID a7b7afe4-6f62-47af-94b7-afd80df14b19 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a7b7afe4-6f62-47af-94b7-afd80df14b19', 'D786BD21-BFEE-4CAA-95AD-EDD105705F13', 3, 'Summary', 'Summary', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID D786BD21-BFEE-4CAA-95AD-EDD105705F13 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='D786BD21-BFEE-4CAA-95AD-EDD105705F13';

/* SQL text to insert entity field value with ID 58230c89-70c8-4b1f-b234-31dfd0769939 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('58230c89-70c8-4b1f-b234-31dfd0769939', '4702BA09-F341-4F12-A270-755E1510F51A', 1, 'AI', 'AI', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID eced37ea-5eb8-4771-a8e1-22cace1989e7 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('eced37ea-5eb8-4771-a8e1-22cace1989e7', '4702BA09-F341-4F12-A270-755E1510F51A', 2, 'Manual', 'Manual', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 4702BA09-F341-4F12-A270-755E1510F51A */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='4702BA09-F341-4F12-A270-755E1510F51A';

/* SQL text to insert entity field value with ID 92b298fc-172d-4b3d-b1c9-e92e0e072f8a */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('92b298fc-172d-4b3d-b1c9-e92e0e072f8a', '445F98CD-8E8A-48E8-B670-DEE27D496E01', 1, 'Draft', 'Draft', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 7afc665d-40ad-4b80-a0f4-fd06082127e0 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7afc665d-40ad-4b80-a0f4-fd06082127e0', '445F98CD-8E8A-48E8-B670-DEE27D496E01', 2, 'Final', 'Final', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 445F98CD-8E8A-48E8-B670-DEE27D496E01 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='445F98CD-8E8A-48E8-B670-DEE27D496E01';

/* SQL text to insert entity field value with ID 694dea01-aa1e-4d7e-af92-d0ad504ab702 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('694dea01-aa1e-4d7e-af92-d0ad504ab702', '644BD683-920D-4B14-8CD3-691E46292DC7', 1, 'Hybrid', 'Hybrid', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f3924f55-bce1-432a-bc21-3213daa77f16 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f3924f55-bce1-432a-bc21-3213daa77f16', '644BD683-920D-4B14-8CD3-691E46292DC7', 2, 'InPerson', 'InPerson', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 82ab6c49-56d6-4bc7-a90c-7bc7b2a5c514 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('82ab6c49-56d6-4bc7-a90c-7bc7b2a5c514', '644BD683-920D-4B14-8CD3-691E46292DC7', 3, 'Phone', 'Phone', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID bf7ea5b5-93ac-4418-a53f-030e544dbf0a */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('bf7ea5b5-93ac-4418-a53f-030e544dbf0a', '644BD683-920D-4B14-8CD3-691E46292DC7', 4, 'Virtual', 'Virtual', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 644BD683-920D-4B14-8CD3-691E46292DC7 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='644BD683-920D-4B14-8CD3-691E46292DC7';

/* SQL text to insert entity field value with ID a5cda977-ea90-40a4-b13d-c35080ee653c */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a5cda977-ea90-40a4-b13d-c35080ee653c', '2BE312A6-8E78-42A5-8CB0-3A3D1DB65B4F', 1, 'Private', 'Private', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 4d0ec40c-9d8d-4e5b-919b-f9f71e2d3157 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('4d0ec40c-9d8d-4e5b-919b-f9f71e2d3157', '2BE312A6-8E78-42A5-8CB0-3A3D1DB65B4F', 2, 'Standard', 'Standard', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 2BE312A6-8E78-42A5-8CB0-3A3D1DB65B4F */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='2BE312A6-8E78-42A5-8CB0-3A3D1DB65B4F';

/* SQL text to insert entity field value with ID c6725e3f-b038-4d7f-b870-b14ac749014b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c6725e3f-b038-4d7f-b870-b14ac749014b', 'F0BE87EB-6629-4B07-A288-84B373C44102', 1, 'Hybrid', 'Hybrid', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 87277d65-69c2-4488-899c-d11c7876dee7 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('87277d65-69c2-4488-899c-d11c7876dee7', 'F0BE87EB-6629-4B07-A288-84B373C44102', 2, 'InPerson', 'InPerson', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID d564bc24-b286-4c0f-b0a4-78e059ed73a1 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d564bc24-b286-4c0f-b0a4-78e059ed73a1', 'F0BE87EB-6629-4B07-A288-84B373C44102', 3, 'Phone', 'Phone', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 6d4c5a25-fa2e-49d3-85ef-00420b483724 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6d4c5a25-fa2e-49d3-85ef-00420b483724', 'F0BE87EB-6629-4B07-A288-84B373C44102', 4, 'Virtual', 'Virtual', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID F0BE87EB-6629-4B07-A288-84B373C44102 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='F0BE87EB-6629-4B07-A288-84B373C44102';

/* SQL text to insert entity field value with ID 666dbb0c-a980-424f-b77c-f36da36d0842 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('666dbb0c-a980-424f-b77c-f36da36d0842', 'DF21C626-8DE5-4D74-89DB-572EA93C1C9C', 1, 'Private', 'Private', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 28173eca-ad24-4907-8074-117b2241ef0c */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('28173eca-ad24-4907-8074-117b2241ef0c', 'DF21C626-8DE5-4D74-89DB-572EA93C1C9C', 2, 'Standard', 'Standard', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID DF21C626-8DE5-4D74-89DB-572EA93C1C9C */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='DF21C626-8DE5-4D74-89DB-572EA93C1C9C';

/* SQL text to insert entity field value with ID 9fc1c29d-c918-4ed1-b895-60e3fc8bad59 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9fc1c29d-c918-4ed1-b895-60e3fc8bad59', '222FC8E1-118E-47AE-8D44-140185534EE4', 1, 'Active', 'Active', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 3f31b564-34dc-4dbf-b5d0-18248c52d353 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('3f31b564-34dc-4dbf-b5d0-18248c52d353', '222FC8E1-118E-47AE-8D44-140185534EE4', 2, 'Cancelled', 'Cancelled', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 289e59af-ca94-4bac-a3f1-acf2fc8b3cd9 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('289e59af-ca94-4bac-a3f1-acf2fc8b3cd9', '222FC8E1-118E-47AE-8D44-140185534EE4', 3, 'Ended', 'Ended', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 222FC8E1-118E-47AE-8D44-140185534EE4 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='222FC8E1-118E-47AE-8D44-140185534EE4';

/* SQL text to insert entity field value with ID 01b876e2-68db-4df0-896a-86ac45478816 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('01b876e2-68db-4df0-896a-86ac45478816', '8506E396-CCF3-4F7F-ADEC-9113641A1759', 1, 'Cancelled', 'Cancelled', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 1301fd62-fdd8-488a-a8d2-b04f9cbe0763 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1301fd62-fdd8-488a-a8d2-b04f9cbe0763', '8506E396-CCF3-4F7F-ADEC-9113641A1759', 2, 'Completed', 'Completed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID bf1dac5a-a708-45d2-abab-5b006ac68039 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('bf1dac5a-a708-45d2-abab-5b006ac68039', '8506E396-CCF3-4F7F-ADEC-9113641A1759', 3, 'Draft', 'Draft', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c8acedaf-14ba-4859-b245-657d6fe981b7 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c8acedaf-14ba-4859-b245-657d6fe981b7', '8506E396-CCF3-4F7F-ADEC-9113641A1759', 4, 'InProgress', 'InProgress', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID af90e49f-92ea-4bc7-b7a6-56d6129226cd */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('af90e49f-92ea-4bc7-b7a6-56d6129226cd', '8506E396-CCF3-4F7F-ADEC-9113641A1759', 5, 'Postponed', 'Postponed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 17d4b35c-1c50-40c1-8cff-b10703fe066b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('17d4b35c-1c50-40c1-8cff-b10703fe066b', '8506E396-CCF3-4F7F-ADEC-9113641A1759', 6, 'Scheduled', 'Scheduled', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 8506E396-CCF3-4F7F-ADEC-9113641A1759 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='8506E396-CCF3-4F7F-ADEC-9113641A1759';

/* SQL text to insert entity field value with ID d3b76cc4-22fe-4b95-9c3c-19f515a9338d */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d3b76cc4-22fe-4b95-9c3c-19f515a9338d', 'C1451E38-09D5-41DA-9373-A62BBC5071CF', 1, 'Hybrid', 'Hybrid', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 6f1f4658-c782-424c-9202-da7cce810350 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6f1f4658-c782-424c-9202-da7cce810350', 'C1451E38-09D5-41DA-9373-A62BBC5071CF', 2, 'InPerson', 'InPerson', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 0d948ae0-01f5-4ffe-9aee-01076be2e407 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0d948ae0-01f5-4ffe-9aee-01076be2e407', 'C1451E38-09D5-41DA-9373-A62BBC5071CF', 3, 'Phone', 'Phone', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 42f8dc59-3ec8-4f1b-95ce-84a1707f056c */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('42f8dc59-3ec8-4f1b-95ce-84a1707f056c', 'C1451E38-09D5-41DA-9373-A62BBC5071CF', 4, 'Virtual', 'Virtual', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID C1451E38-09D5-41DA-9373-A62BBC5071CF */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='C1451E38-09D5-41DA-9373-A62BBC5071CF';

/* SQL text to insert entity field value with ID 81bdcad0-5831-4d53-ac4f-ea92c8a1ca42 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('81bdcad0-5831-4d53-ac4f-ea92c8a1ca42', '392E3392-8E5A-4090-8118-86B4CD6045BD', 1, 'Private', 'Private', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 4d333b2a-893a-4de5-b27c-68fd6f842a73 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('4d333b2a-893a-4de5-b27c-68fd6f842a73', '392E3392-8E5A-4090-8118-86B4CD6045BD', 2, 'Standard', 'Standard', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 392E3392-8E5A-4090-8118-86B4CD6045BD */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='392E3392-8E5A-4090-8118-86B4CD6045BD';

/* SQL text to insert entity field value with ID 0828916c-3197-474b-90f5-5320bcee63fa */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0828916c-3197-474b-90f5-5320bcee63fa', '403AB65C-C56D-4514-987B-E26BAB64226E', 1, 'Optional', 'Optional', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID bb2793bd-6361-466e-bb1d-94d9399ec351 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('bb2793bd-6361-466e-bb1d-94d9399ec351', '403AB65C-C56D-4514-987B-E26BAB64226E', 2, 'Required', 'Required', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 403AB65C-C56D-4514-987B-E26BAB64226E */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='403AB65C-C56D-4514-987B-E26BAB64226E';

/* SQL text to insert entity field value with ID f163e338-f252-4413-b6bf-914441303092 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f163e338-f252-4413-b6bf-914441303092', '749719DB-782C-4CF1-9ABB-FB4800CF01F0', 1, 'Optional', 'Optional', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 4756cd9b-a5cf-487d-9774-3dd1db30f84b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('4756cd9b-a5cf-487d-9774-3dd1db30f84b', '749719DB-782C-4CF1-9ABB-FB4800CF01F0', 2, 'Organizer', 'Organizer', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 0c53969c-4418-4053-b080-d2e9272593ed */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0c53969c-4418-4053-b080-d2e9272593ed', '749719DB-782C-4CF1-9ABB-FB4800CF01F0', 3, 'Required', 'Required', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 749719DB-782C-4CF1-9ABB-FB4800CF01F0 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='749719DB-782C-4CF1-9ABB-FB4800CF01F0';

/* SQL text to insert entity field value with ID db1241e2-41ac-4006-876c-0c584bb90cce */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('db1241e2-41ac-4006-876c-0c584bb90cce', 'E278C1AE-95E7-4164-987F-D8B22BB9A181', 1, 'Accepted', 'Accepted', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID eb7cc343-80bc-4cd2-b7c5-4f01b0889887 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('eb7cc343-80bc-4cd2-b7c5-4f01b0889887', 'E278C1AE-95E7-4164-987F-D8B22BB9A181', 2, 'Declined', 'Declined', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 98e76260-da94-4fbf-8af9-9aba872e90eb */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('98e76260-da94-4fbf-8af9-9aba872e90eb', 'E278C1AE-95E7-4164-987F-D8B22BB9A181', 3, 'None', 'None', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID efdff1d6-0ea2-4009-9857-5859ab6483a5 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('efdff1d6-0ea2-4009-9857-5859ab6483a5', 'E278C1AE-95E7-4164-987F-D8B22BB9A181', 4, 'Tentative', 'Tentative', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID E278C1AE-95E7-4164-987F-D8B22BB9A181 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='E278C1AE-95E7-4164-987F-D8B22BB9A181';

/* SQL text to insert entity field value with ID 75be9ecd-b531-420a-8645-81d988ca18ae */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('75be9ecd-b531-420a-8645-81d988ca18ae', 'AE7AD788-2D1E-4646-8FC1-7A27E0DF0DBE', 1, 'Absent', 'Absent', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 035ae8d6-cf75-46e7-9350-c0ac2061cbf5 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('035ae8d6-cf75-46e7-9350-c0ac2061cbf5', 'AE7AD788-2D1E-4646-8FC1-7A27E0DF0DBE', 2, 'Excused', 'Excused', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID e500d998-4dcf-465f-bd37-5210ddcd1937 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('e500d998-4dcf-465f-bd37-5210ddcd1937', 'AE7AD788-2D1E-4646-8FC1-7A27E0DF0DBE', 3, 'Late', 'Late', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID ef524d4d-7d6a-4c48-92b0-17b2092a911d */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ef524d4d-7d6a-4c48-92b0-17b2092a911d', 'AE7AD788-2D1E-4646-8FC1-7A27E0DF0DBE', 4, 'LeftEarly', 'LeftEarly', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 960a9f77-4727-454c-96d0-969d14871121 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('960a9f77-4727-454c-96d0-969d14871121', 'AE7AD788-2D1E-4646-8FC1-7A27E0DF0DBE', 5, 'Present', 'Present', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 472c8e40-dfdd-4d42-bddf-2b765a8e8e85 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('472c8e40-dfdd-4d42-bddf-2b765a8e8e85', 'AE7AD788-2D1E-4646-8FC1-7A27E0DF0DBE', 6, 'Unknown', 'Unknown', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID AE7AD788-2D1E-4646-8FC1-7A27E0DF0DBE */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='AE7AD788-2D1E-4646-8FC1-7A27E0DF0DBE';

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
                 AND e.[SchemaName] NOT IN ('${mjSchema}','${mjSchema}_BizAppsCollaboration','${mjSchema}_BizAppsCollabExamples','${mjSchema}_BizAppsCommon','sys')
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
              AND e.[SchemaName] NOT IN ('${mjSchema}','${mjSchema}_BizAppsCollaboration','${mjSchema}_BizAppsCollabExamples','${mjSchema}_BizAppsCommon','sys')
              AND NOT EXISTS (
               SELECT 1 FROM [${mjSchema}].[EntityField] f2
               WHERE f2.[EntityID] = e.[ID]
                 AND f2.[IncludeInUserSearchAPI] = 1
            )
         );


/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Types -> MJ_BizApps_Tasks: Meeting Series (One To Many via TypeID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '9066128f-70fd-45b4-99de-d5855b37350c'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('9066128f-70fd-45b4-99de-d5855b37350c', '7967EB2A-B969-41DC-A71D-0591C1E57353', '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', 'TypeID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Types -> MJ_BizApps_Tasks: Meetings (One To Many via TypeID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '5e3e2db3-d64c-4611-8d6c-32f3f9769943'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('5e3e2db3-d64c-4611-8d6c-32f3f9769943', '7967EB2A-B969-41DC-A71D-0591C1E57353', '83BB5923-29C9-4CBB-94C4-35601DA29DDD', 'TypeID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Series -> MJ_BizApps_Tasks: Meetings (One To Many via SeriesID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '94ac9ef0-6780-4fc2-b340-c5b2d3bae2b7'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('94ac9ef0-6780-4fc2-b340-c5b2d3bae2b7', '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', '83BB5923-29C9-4CBB-94C4-35601DA29DDD', 'SeriesID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Series -> MJ_BizApps_Tasks: Meeting Links (One To Many via SeriesID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '6d22342e-788f-4164-9e5f-16b1486b8fde'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('6d22342e-788f-4164-9e5f-16b1486b8fde', '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', 'SeriesID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Series -> MJ_BizApps_Tasks: Meeting Series Attendees (One To Many via SeriesID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '4cec8a76-32a3-4834-bca6-f5ac7d2f36a6'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('4cec8a76-32a3-4834-bca6-f5ac7d2f36a6', '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', 'SeriesID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Meetings -> MJ_BizApps_Tasks: Meeting Links (One To Many via MeetingID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '2d9d78bb-1870-48a2-a781-76f071eaf485'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('2d9d78bb-1870-48a2-a781-76f071eaf485', '83BB5923-29C9-4CBB-94C4-35601DA29DDD', '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', 'MeetingID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meetings -> MJ_BizApps_Tasks: Meeting Agenda Items (One To Many via MeetingID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '733aaa31-6e14-4c82-a05e-3665ecc13dab'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('733aaa31-6e14-4c82-a05e-3665ecc13dab', '83BB5923-29C9-4CBB-94C4-35601DA29DDD', 'E089FA02-A8AA-485F-A002-870F5C248E38', 'MeetingID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meetings -> MJ_BizApps_Tasks: Meeting Agenda Items (One To Many via DeferredToMeetingID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'c2605fb2-8fc3-4937-bb87-a63fb8607e1e'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('c2605fb2-8fc3-4937-bb87-a63fb8607e1e', '83BB5923-29C9-4CBB-94C4-35601DA29DDD', 'E089FA02-A8AA-485F-A002-870F5C248E38', 'DeferredToMeetingID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meetings -> MJ_BizApps_Tasks: Meeting Attendees (One To Many via MeetingID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '3bcff830-0e0d-4e87-a4df-5c67e5db4416'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('3bcff830-0e0d-4e87-a4df-5c67e5db4416', '83BB5923-29C9-4CBB-94C4-35601DA29DDD', '69A03D0B-F654-40B6-9B90-94DEC8948AA2', 'MeetingID', 'One To Many', 1, 1, 4, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meetings -> MJ_BizApps_Tasks: Meeting Notes (One To Many via MeetingID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '4c089a0c-3399-41bd-aa89-c3f2960b21db'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('4c089a0c-3399-41bd-aa89-c3f2960b21db', '83BB5923-29C9-4CBB-94C4-35601DA29DDD', '2B15A5D4-9E91-4322-9B82-D58F6E08399E', 'MeetingID', 'One To Many', 1, 1, 5, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ: AI Prompts -> MJ_BizApps_Tasks: Meeting Types (One To Many via NotesPromptID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'b6576ae3-f266-4f35-8782-64252eadab1a'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('b6576ae3-f266-4f35-8782-64252eadab1a', '73AD0238-8B56-EF11-991A-6045BDEBA539', '7967EB2A-B969-41DC-A71D-0591C1E57353', 'NotesPromptID', 'One To Many', 1, 1, 25, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Entities -> MJ_BizApps_Tasks: Meeting Links (One To Many via EntityID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '3c393ccc-ef28-4d94-9895-3fc35dc36df6'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('3c393ccc-ef28-4d94-9895-3fc35dc36df6', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', 'EntityID', 'One To Many', 1, 1, 92, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ: Users -> MJ_BizApps_Tasks: Meeting Series Attendees (One To Many via UserID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '562d235b-a74f-41a9-a7b8-5c54dc0f4e5b'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('562d235b-a74f-41a9-a7b8-5c54dc0f4e5b', 'E1238F34-2837-EF11-86D4-6045BDEE16E6', 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', 'UserID', 'One To Many', 1, 1, 122, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Users -> MJ_BizApps_Tasks: Meeting Attendees (One To Many via UserID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '75805a08-c63c-4b00-a069-ff4341c1c275'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('75805a08-c63c-4b00-a069-ff4341c1c275', 'E1238F34-2837-EF11-86D4-6045BDEE16E6', '69A03D0B-F654-40B6-9B90-94DEC8948AA2', 'UserID', 'One To Many', 1, 1, 123, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Files -> MJ_BizApps_Tasks: Meetings (One To Many via TranscriptFileID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '7046cb95-140b-473d-8acf-8454dd4ead28'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('7046cb95-140b-473d-8acf-8454dd4ead28', '29248F34-2837-EF11-86D4-6045BDEE16E6', '83BB5923-29C9-4CBB-94C4-35601DA29DDD', 'TranscriptFileID', 'One To Many', 1, 1, 10, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Agenda Items -> MJ_BizApps_Tasks: Meeting Agenda Items (One To Many via ParentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '36ca9f13-5ebe-4e32-a45d-c894e56726de'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('36ca9f13-5ebe-4e32-a45d-c894e56726de', 'E089FA02-A8AA-485F-A002-870F5C248E38', 'E089FA02-A8AA-485F-A002-870F5C248E38', 'ParentID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Agenda Items -> MJ_BizApps_Tasks: Meeting Notes (One To Many via AgendaItemID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '5c060e54-393b-460f-8d82-d33ea39a23da'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('5c060e54-393b-460f-8d82-d33ea39a23da', 'E089FA02-A8AA-485F-A002-870F5C248E38', '2B15A5D4-9E91-4322-9B82-D58F6E08399E', 'AgendaItemID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Credentials -> MJ_BizApps_Tasks: Video Providers (One To Many via CredentialID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '48461f16-692d-4e1b-9173-92da044d62c2'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('48461f16-692d-4e1b-9173-92da044d62c2', '7E023DDF-82C6-4B0C-9650-8D35699B9FD0', '6751908A-D102-49B0-AE57-A987496CA8E7', 'CredentialID', 'One To Many', 1, 1, 13, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Agenda Item Types -> MJ_BizApps_Tasks: Meeting Agenda Items (One To Many via TypeID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'c800b94a-f47c-4d88-9aad-855727a0a56a'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('c800b94a-f47c-4d88-9aad-855727a0a56a', 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA', 'E089FA02-A8AA-485F-A002-870F5C248E38', 'TypeID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Video Providers -> MJ_BizApps_Tasks: Meeting Types (One To Many via DefaultVideoProviderID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'c8ca6bda-0f58-4e6a-babb-222a5fa77e20'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('c8ca6bda-0f58-4e6a-babb-222a5fa77e20', '6751908A-D102-49B0-AE57-A987496CA8E7', '7967EB2A-B969-41DC-A71D-0591C1E57353', 'DefaultVideoProviderID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Video Providers -> MJ_BizApps_Tasks: Meeting Series (One To Many via VideoProviderID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '8e539583-1880-491f-892f-1ec834bc4032'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('8e539583-1880-491f-892f-1ec834bc4032', '6751908A-D102-49B0-AE57-A987496CA8E7', '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', 'VideoProviderID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Video Providers -> MJ_BizApps_Tasks: Meetings (One To Many via VideoProviderID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '7134ee77-1edb-42b3-b560-48e288d70b44'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('7134ee77-1edb-42b3-b560-48e288d70b44', '6751908A-D102-49B0-AE57-A987496CA8E7', '83BB5923-29C9-4CBB-94C4-35601DA29DDD', 'VideoProviderID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ: AI Prompt Runs -> MJ_BizApps_Tasks: Meeting Notes (One To Many via AIPromptRunID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '6a245fa5-5cd6-4052-8295-41226dadbd13'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('6a245fa5-5cd6-4052-8295-41226dadbd13', '7C1C98D0-3978-4CE8-8E3F-C90301E59767', '2B15A5D4-9E91-4322-9B82-D58F6E08399E', 'AIPromptRunID', 'One To Many', 1, 1, 11, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meeting Series (One To Many via OrganizerPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '4f49c312-8ca6-4f05-9d41-8aa3275a2589'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('4f49c312-8ca6-4f05-9d41-8aa3275a2589', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', 'OrganizerPersonID', 'One To Many', 1, 1, 12, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meeting Series (One To Many via CreatedByPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'a24f71a2-770c-4741-bdf3-38ab44d89462'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a24f71a2-770c-4741-bdf3-38ab44d89462', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', 'CreatedByPersonID', 'One To Many', 1, 1, 13, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meetings (One To Many via OrganizerPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '563dd3e1-ee61-443f-9004-f68bae3f19a1'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('563dd3e1-ee61-443f-9004-f68bae3f19a1', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '83BB5923-29C9-4CBB-94C4-35601DA29DDD', 'OrganizerPersonID', 'One To Many', 1, 1, 14, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meetings (One To Many via CreatedByPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '890179c6-e65a-47f0-abaa-6f89943b9267'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('890179c6-e65a-47f0-abaa-6f89943b9267', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '83BB5923-29C9-4CBB-94C4-35601DA29DDD', 'CreatedByPersonID', 'One To Many', 1, 1, 15, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meeting Series Attendees (One To Many via PersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '5c581118-292b-4bf4-b902-eed0b3a8af8e'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('5c581118-292b-4bf4-b902-eed0b3a8af8e', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', 'PersonID', 'One To Many', 1, 1, 16, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meeting Agenda Items (One To Many via PresenterPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '01d89543-e44b-495e-8036-6b4075f6b546'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('01d89543-e44b-495e-8036-6b4075f6b546', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'E089FA02-A8AA-485F-A002-870F5C248E38', 'PresenterPersonID', 'One To Many', 1, 1, 17, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meeting Attendees (One To Many via PersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '64dff129-5a9d-4c18-940d-d7e7ab40382c'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('64dff129-5a9d-4c18-940d-d7e7ab40382c', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '69A03D0B-F654-40B6-9B90-94DEC8948AA2', 'PersonID', 'One To Many', 1, 1, 18, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meeting Notes (One To Many via AuthorPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '767f9777-976d-4fa7-ab8d-1057a3710b18'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('767f9777-976d-4fa7-ab8d-1057a3710b18', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '2B15A5D4-9E91-4322-9B82-D58F6E08399E', 'AuthorPersonID', 'One To Many', 1, 1, 19, GETUTCDATE(), GETUTCDATE())
   END;

/* SQL text to sync schema info from database schemas */
EXEC [${mjSchema}].[spUpdateSchemaInfoFromDatabase] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* Index for Foreign Keys for MeetingAgendaItemType */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

/* Index for Foreign Keys for MeetingAgendaItem */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key MeetingID in table MeetingAgendaItem
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingAgendaItem_MeetingID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingAgendaItem]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingAgendaItem_MeetingID ON [${flyway:defaultSchema}].[MeetingAgendaItem] ([MeetingID]);

-- Index for foreign key ParentID in table MeetingAgendaItem
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingAgendaItem_ParentID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingAgendaItem]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingAgendaItem_ParentID ON [${flyway:defaultSchema}].[MeetingAgendaItem] ([ParentID]);

-- Index for foreign key TypeID in table MeetingAgendaItem
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingAgendaItem_TypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingAgendaItem]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingAgendaItem_TypeID ON [${flyway:defaultSchema}].[MeetingAgendaItem] ([TypeID]);

-- Index for foreign key PresenterPersonID in table MeetingAgendaItem
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingAgendaItem_PresenterPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingAgendaItem]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingAgendaItem_PresenterPersonID ON [${flyway:defaultSchema}].[MeetingAgendaItem] ([PresenterPersonID]);

-- Index for foreign key DeferredToMeetingID in table MeetingAgendaItem
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingAgendaItem_DeferredToMeetingID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingAgendaItem]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingAgendaItem_DeferredToMeetingID ON [${flyway:defaultSchema}].[MeetingAgendaItem] ([DeferredToMeetingID]);

/* SQL text to update entity field related entity name field map for entity field ID 92B77569-07D4-437B-98A4-B5D16DFEC3E7 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='92B77569-07D4-437B-98A4-B5D16DFEC3E7', @RelatedEntityNameFieldMap='Meeting';

/* Index for Foreign Keys for MeetingAttendee */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Attendees
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key MeetingID in table MeetingAttendee
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingAttendee_MeetingID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingAttendee]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingAttendee_MeetingID ON [${flyway:defaultSchema}].[MeetingAttendee] ([MeetingID]);

-- Index for foreign key PersonID in table MeetingAttendee
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingAttendee_PersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingAttendee]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingAttendee_PersonID ON [${flyway:defaultSchema}].[MeetingAttendee] ([PersonID]);

-- Index for foreign key UserID in table MeetingAttendee
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingAttendee_UserID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingAttendee]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingAttendee_UserID ON [${flyway:defaultSchema}].[MeetingAttendee] ([UserID]);

/* SQL text to update entity field related entity name field map for entity field ID 515575E9-A142-44B1-BD41-0EEDD98902B2 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='515575E9-A142-44B1-BD41-0EEDD98902B2', @RelatedEntityNameFieldMap='Meeting';

/* Index for Foreign Keys for MeetingLink */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Links
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key MeetingID in table MeetingLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingLink_MeetingID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingLink_MeetingID ON [${flyway:defaultSchema}].[MeetingLink] ([MeetingID]);

-- Index for foreign key SeriesID in table MeetingLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingLink_SeriesID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingLink_SeriesID ON [${flyway:defaultSchema}].[MeetingLink] ([SeriesID]);

-- Index for foreign key EntityID in table MeetingLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingLink_EntityID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingLink_EntityID ON [${flyway:defaultSchema}].[MeetingLink] ([EntityID]);

/* SQL text to update entity field related entity name field map for entity field ID 7EA119CE-FFCC-44B5-A0EF-A6B6DCD23DEE */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='7EA119CE-FFCC-44B5-A0EF-A6B6DCD23DEE', @RelatedEntityNameFieldMap='Meeting';

/* Index for Foreign Keys for MeetingNote */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Notes
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key MeetingID in table MeetingNote
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingNote_MeetingID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingNote]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingNote_MeetingID ON [${flyway:defaultSchema}].[MeetingNote] ([MeetingID]);

-- Index for foreign key AgendaItemID in table MeetingNote
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingNote_AgendaItemID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingNote]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingNote_AgendaItemID ON [${flyway:defaultSchema}].[MeetingNote] ([AgendaItemID]);

-- Index for foreign key AuthorPersonID in table MeetingNote
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingNote_AuthorPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingNote]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingNote_AuthorPersonID ON [${flyway:defaultSchema}].[MeetingNote] ([AuthorPersonID]);

-- Index for foreign key AIPromptRunID in table MeetingNote
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingNote_AIPromptRunID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingNote]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingNote_AIPromptRunID ON [${flyway:defaultSchema}].[MeetingNote] ([AIPromptRunID]);

/* SQL text to update entity field related entity name field map for entity field ID CAAACDCE-963A-43EE-BA6A-BA137657141D */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='CAAACDCE-963A-43EE-BA6A-BA137657141D', @RelatedEntityNameFieldMap='Meeting';

/* Index for Foreign Keys for MeetingSeries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TypeID in table MeetingSeries
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingSeries_TypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingSeries]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingSeries_TypeID ON [${flyway:defaultSchema}].[MeetingSeries] ([TypeID]);

-- Index for foreign key OrganizerPersonID in table MeetingSeries
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingSeries_OrganizerPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingSeries]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingSeries_OrganizerPersonID ON [${flyway:defaultSchema}].[MeetingSeries] ([OrganizerPersonID]);

-- Index for foreign key VideoProviderID in table MeetingSeries
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingSeries_VideoProviderID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingSeries]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingSeries_VideoProviderID ON [${flyway:defaultSchema}].[MeetingSeries] ([VideoProviderID]);

-- Index for foreign key CreatedByPersonID in table MeetingSeries
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingSeries_CreatedByPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingSeries]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingSeries_CreatedByPersonID ON [${flyway:defaultSchema}].[MeetingSeries] ([CreatedByPersonID]);

/* SQL text to update entity field related entity name field map for entity field ID FBB88C84-BFEA-4FCB-B6D0-C40970FB7227 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='FBB88C84-BFEA-4FCB-B6D0-C40970FB7227', @RelatedEntityNameFieldMap='Type';

/* Index for Foreign Keys for MeetingSeriesAttendee */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key SeriesID in table MeetingSeriesAttendee
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingSeriesAttendee_SeriesID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingSeriesAttendee]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingSeriesAttendee_SeriesID ON [${flyway:defaultSchema}].[MeetingSeriesAttendee] ([SeriesID]);

-- Index for foreign key PersonID in table MeetingSeriesAttendee
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingSeriesAttendee_PersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingSeriesAttendee]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingSeriesAttendee_PersonID ON [${flyway:defaultSchema}].[MeetingSeriesAttendee] ([PersonID]);

-- Index for foreign key UserID in table MeetingSeriesAttendee
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingSeriesAttendee_UserID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingSeriesAttendee]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingSeriesAttendee_UserID ON [${flyway:defaultSchema}].[MeetingSeriesAttendee] ([UserID]);

/* SQL text to update entity field related entity name field map for entity field ID 55594095-477D-4DBF-A456-F2EA486E2FB4 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='55594095-477D-4DBF-A456-F2EA486E2FB4', @RelatedEntityNameFieldMap='Series';

/* Index for Foreign Keys for MeetingType */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Types
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key DefaultVideoProviderID in table MeetingType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingType_DefaultVideoProviderID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingType_DefaultVideoProviderID ON [${flyway:defaultSchema}].[MeetingType] ([DefaultVideoProviderID]);

-- Index for foreign key NotesPromptID in table MeetingType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingType_NotesPromptID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingType_NotesPromptID ON [${flyway:defaultSchema}].[MeetingType] ([NotesPromptID]);

/* SQL text to update entity field related entity name field map for entity field ID 86AB2716-8A34-43F6-BDF0-881AC39981D3 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='86AB2716-8A34-43F6-BDF0-881AC39981D3', @RelatedEntityNameFieldMap='DefaultVideoProvider';

/* Base View SQL for MJ_BizApps_Tasks: Meeting Agenda Item Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
-- Item: vwMeetingAgendaItemTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Meeting Agenda Item Types
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  MeetingAgendaItemType
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwMeetingAgendaItemTypes]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwMeetingAgendaItemTypes];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwMeetingAgendaItemTypes]
AS
SELECT
    m.*
FROM
    [${flyway:defaultSchema}].[MeetingAgendaItemType] AS m
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingAgendaItemTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Meeting Agenda Item Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
-- Item: Permissions for vwMeetingAgendaItemTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingAgendaItemTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Meeting Agenda Item Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
-- Item: spCreateMeetingAgendaItemType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR MeetingAgendaItemType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateMeetingAgendaItemType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingAgendaItemType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingAgendaItemType]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(100),
    @Code nvarchar(50),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @IconClass_Clear bit = 0,
    @IconClass nvarchar(100) = NULL,
    @DefaultDurationMinutes_Clear bit = 0,
    @DefaultDurationMinutes int = NULL,
    @IsActive bit = NULL,
    @Sequence int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[MeetingAgendaItemType]
            (
                [ID],
                [Name],
                [Code],
                [Description],
                [IconClass],
                [DefaultDurationMinutes],
                [IsActive],
                [Sequence]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                @Code,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, NULL) END,
                CASE WHEN @DefaultDurationMinutes_Clear = 1 THEN NULL ELSE ISNULL(@DefaultDurationMinutes, NULL) END,
                ISNULL(@IsActive, 1),
                ISNULL(@Sequence, 100)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[MeetingAgendaItemType]
            (
                [Name],
                [Code],
                [Description],
                [IconClass],
                [DefaultDurationMinutes],
                [IsActive],
                [Sequence]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                @Code,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, NULL) END,
                CASE WHEN @DefaultDurationMinutes_Clear = 1 THEN NULL ELSE ISNULL(@DefaultDurationMinutes, NULL) END,
                ISNULL(@IsActive, 1),
                ISNULL(@Sequence, 100)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwMeetingAgendaItemTypes] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingAgendaItemType] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Meeting Agenda Item Types */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingAgendaItemType] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Meeting Agenda Item Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
-- Item: spUpdateMeetingAgendaItemType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR MeetingAgendaItemType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateMeetingAgendaItemType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingAgendaItemType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingAgendaItemType]
    @ID uniqueidentifier,
    @Name nvarchar(100) = NULL,
    @Code nvarchar(50) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @IconClass_Clear bit = 0,
    @IconClass nvarchar(100) = NULL,
    @DefaultDurationMinutes_Clear bit = 0,
    @DefaultDurationMinutes int = NULL,
    @IsActive bit = NULL,
    @Sequence int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingAgendaItemType]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [Code] = ISNULL(@Code, [Code]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [IconClass] = CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, [IconClass]) END,
        [DefaultDurationMinutes] = CASE WHEN @DefaultDurationMinutes_Clear = 1 THEN NULL ELSE ISNULL(@DefaultDurationMinutes, [DefaultDurationMinutes]) END,
        [IsActive] = ISNULL(@IsActive, [IsActive]),
        [Sequence] = ISNULL(@Sequence, [Sequence])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwMeetingAgendaItemTypes] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwMeetingAgendaItemTypes]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingAgendaItemType] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the MeetingAgendaItemType table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateMeetingAgendaItemType]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateMeetingAgendaItemType];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateMeetingAgendaItemType
ON [${flyway:defaultSchema}].[MeetingAgendaItemType]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingAgendaItemType]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[MeetingAgendaItemType] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Meeting Agenda Item Types */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingAgendaItemType] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Meeting Agenda Item Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
-- Item: spDeleteMeetingAgendaItemType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR MeetingAgendaItemType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteMeetingAgendaItemType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingAgendaItemType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingAgendaItemType]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[MeetingAgendaItemType]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingAgendaItemType] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Meeting Agenda Item Types */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingAgendaItemType] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID DB6F2CA4-E7C9-48C6-A128-525A9CF1588A */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='DB6F2CA4-E7C9-48C6-A128-525A9CF1588A', @RelatedEntityNameFieldMap='Person';

/* SQL text to update entity field related entity name field map for entity field ID F522109A-03C2-445A-9295-01294B0EABF3 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='F522109A-03C2-445A-9295-01294B0EABF3', @RelatedEntityNameFieldMap='Parent';

/* SQL text to update entity field related entity name field map for entity field ID 7C0572F4-3BFD-436D-A687-5236F735FB85 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='7C0572F4-3BFD-436D-A687-5236F735FB85', @RelatedEntityNameFieldMap='AgendaItem';

/* SQL text to update entity field related entity name field map for entity field ID A9DB3840-F16F-4423-963F-43CE244A05BB */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='A9DB3840-F16F-4423-963F-43CE244A05BB', @RelatedEntityNameFieldMap='Series';

/* SQL text to update entity field related entity name field map for entity field ID 73D48712-5706-4222-95C5-43EFCBCA1A8C */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='73D48712-5706-4222-95C5-43EFCBCA1A8C', @RelatedEntityNameFieldMap='NotesPrompt';

/* SQL text to update entity field related entity name field map for entity field ID 0D65FAEA-E5D9-4DA7-83F1-2EE1EFC53557 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='0D65FAEA-E5D9-4DA7-83F1-2EE1EFC53557', @RelatedEntityNameFieldMap='Person';

/* SQL text to update entity field related entity name field map for entity field ID 00BB9F84-29E8-4C39-9B3E-44AE52B87C42 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='00BB9F84-29E8-4C39-9B3E-44AE52B87C42', @RelatedEntityNameFieldMap='OrganizerPerson';

/* SQL text to update entity field related entity name field map for entity field ID 223DB792-C426-4A68-9600-C8F1B3368DD9 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='223DB792-C426-4A68-9600-C8F1B3368DD9', @RelatedEntityNameFieldMap='Type';

/* SQL text to update entity field related entity name field map for entity field ID DF1645D3-F3DB-410D-8CBC-87CF854DBA10 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='DF1645D3-F3DB-410D-8CBC-87CF854DBA10', @RelatedEntityNameFieldMap='User';

/* SQL text to update entity field related entity name field map for entity field ID 50F0F9AD-3E5F-44CE-B52C-204119F86006 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='50F0F9AD-3E5F-44CE-B52C-204119F86006', @RelatedEntityNameFieldMap='AuthorPerson';

/* SQL text to update entity field related entity name field map for entity field ID 656110DF-C022-4769-90CE-94F1E84F1D07 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='656110DF-C022-4769-90CE-94F1E84F1D07', @RelatedEntityNameFieldMap='Entity';

/* Base View SQL for MJ_BizApps_Tasks: Meeting Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Types
-- Item: vwMeetingTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Meeting Types
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  MeetingType
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwMeetingTypes]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwMeetingTypes];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwMeetingTypes]
AS
SELECT
    m.*,
    mjBizAppsTasksVideoProvider_DefaultVideoProviderID.[Name] AS [DefaultVideoProvider],
    MJAIPrompt_NotesPromptID.[Name] AS [NotesPrompt]
FROM
    [${flyway:defaultSchema}].[MeetingType] AS m
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[VideoProvider] AS mjBizAppsTasksVideoProvider_DefaultVideoProviderID
  ON
    [m].[DefaultVideoProviderID] = mjBizAppsTasksVideoProvider_DefaultVideoProviderID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[AIPrompt] AS MJAIPrompt_NotesPromptID
  ON
    [m].[NotesPromptID] = MJAIPrompt_NotesPromptID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Meeting Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Types
-- Item: Permissions for vwMeetingTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Meeting Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Types
-- Item: spCreateMeetingType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR MeetingType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateMeetingType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingType]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(100),
    @Code nvarchar(50),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @IconClass_Clear bit = 0,
    @IconClass nvarchar(100) = NULL,
    @DefaultDurationMinutes_Clear bit = 0,
    @DefaultDurationMinutes int = NULL,
    @DefaultLocationType_Clear bit = 0,
    @DefaultLocationType nvarchar(20) = NULL,
    @DefaultVideoProviderID_Clear bit = 0,
    @DefaultVideoProviderID uniqueidentifier = NULL,
    @DefaultVisibility_Clear bit = 0,
    @DefaultVisibility nvarchar(20) = NULL,
    @AgendaTemplate_Clear bit = 0,
    @AgendaTemplate nvarchar(MAX) = NULL,
    @NotesPromptID_Clear bit = 0,
    @NotesPromptID uniqueidentifier = NULL,
    @IsActive bit = NULL,
    @Sequence int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[MeetingType]
            (
                [ID],
                [Name],
                [Code],
                [Description],
                [IconClass],
                [DefaultDurationMinutes],
                [DefaultLocationType],
                [DefaultVideoProviderID],
                [DefaultVisibility],
                [AgendaTemplate],
                [NotesPromptID],
                [IsActive],
                [Sequence]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                @Code,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, NULL) END,
                CASE WHEN @DefaultDurationMinutes_Clear = 1 THEN NULL ELSE ISNULL(@DefaultDurationMinutes, NULL) END,
                CASE WHEN @DefaultLocationType_Clear = 1 THEN NULL ELSE ISNULL(@DefaultLocationType, NULL) END,
                CASE WHEN @DefaultVideoProviderID_Clear = 1 THEN NULL ELSE ISNULL(@DefaultVideoProviderID, NULL) END,
                CASE WHEN @DefaultVisibility_Clear = 1 THEN NULL ELSE ISNULL(@DefaultVisibility, NULL) END,
                CASE WHEN @AgendaTemplate_Clear = 1 THEN NULL ELSE ISNULL(@AgendaTemplate, NULL) END,
                CASE WHEN @NotesPromptID_Clear = 1 THEN NULL ELSE ISNULL(@NotesPromptID, NULL) END,
                ISNULL(@IsActive, 1),
                ISNULL(@Sequence, 100)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[MeetingType]
            (
                [Name],
                [Code],
                [Description],
                [IconClass],
                [DefaultDurationMinutes],
                [DefaultLocationType],
                [DefaultVideoProviderID],
                [DefaultVisibility],
                [AgendaTemplate],
                [NotesPromptID],
                [IsActive],
                [Sequence]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                @Code,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, NULL) END,
                CASE WHEN @DefaultDurationMinutes_Clear = 1 THEN NULL ELSE ISNULL(@DefaultDurationMinutes, NULL) END,
                CASE WHEN @DefaultLocationType_Clear = 1 THEN NULL ELSE ISNULL(@DefaultLocationType, NULL) END,
                CASE WHEN @DefaultVideoProviderID_Clear = 1 THEN NULL ELSE ISNULL(@DefaultVideoProviderID, NULL) END,
                CASE WHEN @DefaultVisibility_Clear = 1 THEN NULL ELSE ISNULL(@DefaultVisibility, NULL) END,
                CASE WHEN @AgendaTemplate_Clear = 1 THEN NULL ELSE ISNULL(@AgendaTemplate, NULL) END,
                CASE WHEN @NotesPromptID_Clear = 1 THEN NULL ELSE ISNULL(@NotesPromptID, NULL) END,
                ISNULL(@IsActive, 1),
                ISNULL(@Sequence, 100)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwMeetingTypes] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingType] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Meeting Types */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingType] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Meeting Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Types
-- Item: spUpdateMeetingType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR MeetingType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateMeetingType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingType]
    @ID uniqueidentifier,
    @Name nvarchar(100) = NULL,
    @Code nvarchar(50) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @IconClass_Clear bit = 0,
    @IconClass nvarchar(100) = NULL,
    @DefaultDurationMinutes_Clear bit = 0,
    @DefaultDurationMinutes int = NULL,
    @DefaultLocationType_Clear bit = 0,
    @DefaultLocationType nvarchar(20) = NULL,
    @DefaultVideoProviderID_Clear bit = 0,
    @DefaultVideoProviderID uniqueidentifier = NULL,
    @DefaultVisibility_Clear bit = 0,
    @DefaultVisibility nvarchar(20) = NULL,
    @AgendaTemplate_Clear bit = 0,
    @AgendaTemplate nvarchar(MAX) = NULL,
    @NotesPromptID_Clear bit = 0,
    @NotesPromptID uniqueidentifier = NULL,
    @IsActive bit = NULL,
    @Sequence int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingType]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [Code] = ISNULL(@Code, [Code]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [IconClass] = CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, [IconClass]) END,
        [DefaultDurationMinutes] = CASE WHEN @DefaultDurationMinutes_Clear = 1 THEN NULL ELSE ISNULL(@DefaultDurationMinutes, [DefaultDurationMinutes]) END,
        [DefaultLocationType] = CASE WHEN @DefaultLocationType_Clear = 1 THEN NULL ELSE ISNULL(@DefaultLocationType, [DefaultLocationType]) END,
        [DefaultVideoProviderID] = CASE WHEN @DefaultVideoProviderID_Clear = 1 THEN NULL ELSE ISNULL(@DefaultVideoProviderID, [DefaultVideoProviderID]) END,
        [DefaultVisibility] = CASE WHEN @DefaultVisibility_Clear = 1 THEN NULL ELSE ISNULL(@DefaultVisibility, [DefaultVisibility]) END,
        [AgendaTemplate] = CASE WHEN @AgendaTemplate_Clear = 1 THEN NULL ELSE ISNULL(@AgendaTemplate, [AgendaTemplate]) END,
        [NotesPromptID] = CASE WHEN @NotesPromptID_Clear = 1 THEN NULL ELSE ISNULL(@NotesPromptID, [NotesPromptID]) END,
        [IsActive] = ISNULL(@IsActive, [IsActive]),
        [Sequence] = ISNULL(@Sequence, [Sequence])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwMeetingTypes] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwMeetingTypes]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingType] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the MeetingType table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateMeetingType]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateMeetingType];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateMeetingType
ON [${flyway:defaultSchema}].[MeetingType]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingType]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[MeetingType] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Meeting Types */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingType] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Meeting Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Types
-- Item: spDeleteMeetingType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR MeetingType
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteMeetingType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingType]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[MeetingType]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingType] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Meeting Types */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingType] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID 69CF2484-E8E5-4A9E-BEBC-E2AE15755866 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='69CF2484-E8E5-4A9E-BEBC-E2AE15755866', @RelatedEntityNameFieldMap='User';

/* SQL text to update entity field related entity name field map for entity field ID 6E4C25E9-380E-42B3-925D-61BA97760279 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='6E4C25E9-380E-42B3-925D-61BA97760279', @RelatedEntityNameFieldMap='VideoProvider';

/* SQL text to update entity field related entity name field map for entity field ID 83550206-C6A8-41AB-99A6-05C5E38EB795 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='83550206-C6A8-41AB-99A6-05C5E38EB795', @RelatedEntityNameFieldMap='AIPromptRun';

/* SQL text to update entity field related entity name field map for entity field ID EF848A75-8DA4-4772-8870-B606BBAA1C42 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='EF848A75-8DA4-4772-8870-B606BBAA1C42', @RelatedEntityNameFieldMap='CreatedByPerson';

/* Base View SQL for MJ_BizApps_Tasks: Meeting Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Links
-- Item: vwMeetingLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Meeting Links
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  MeetingLink
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwMeetingLinks]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwMeetingLinks];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwMeetingLinks]
AS
SELECT
    m.*,
    mjBizAppsTasksMeeting_MeetingID.[Name] AS [Meeting],
    mjBizAppsTasksMeetingSeries_SeriesID.[Name] AS [Series],
    MJEntity_EntityID.[Name] AS [Entity]
FROM
    [${flyway:defaultSchema}].[MeetingLink] AS m
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Meeting] AS mjBizAppsTasksMeeting_MeetingID
  ON
    [m].[MeetingID] = mjBizAppsTasksMeeting_MeetingID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[MeetingSeries] AS mjBizAppsTasksMeetingSeries_SeriesID
  ON
    [m].[SeriesID] = mjBizAppsTasksMeetingSeries_SeriesID.[ID]
INNER JOIN
    [${mjSchema}].[Entity] AS MJEntity_EntityID
  ON
    [m].[EntityID] = MJEntity_EntityID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Meeting Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Links
-- Item: Permissions for vwMeetingLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Meeting Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Links
-- Item: spCreateMeetingLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR MeetingLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateMeetingLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingLink]
    @ID uniqueidentifier = NULL,
    @MeetingID_Clear bit = 0,
    @MeetingID uniqueidentifier = NULL,
    @SeriesID_Clear bit = 0,
    @SeriesID uniqueidentifier = NULL,
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
        INSERT INTO [${flyway:defaultSchema}].[MeetingLink]
            (
                [ID],
                [MeetingID],
                [SeriesID],
                [EntityID],
                [RecordID],
                [Description]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                CASE WHEN @MeetingID_Clear = 1 THEN NULL ELSE ISNULL(@MeetingID, NULL) END,
                CASE WHEN @SeriesID_Clear = 1 THEN NULL ELSE ISNULL(@SeriesID, NULL) END,
                @EntityID,
                @RecordID,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[MeetingLink]
            (
                [MeetingID],
                [SeriesID],
                [EntityID],
                [RecordID],
                [Description]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                CASE WHEN @MeetingID_Clear = 1 THEN NULL ELSE ISNULL(@MeetingID, NULL) END,
                CASE WHEN @SeriesID_Clear = 1 THEN NULL ELSE ISNULL(@SeriesID, NULL) END,
                @EntityID,
                @RecordID,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwMeetingLinks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingLink] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Meeting Links */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingLink] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Meeting Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Links
-- Item: spUpdateMeetingLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR MeetingLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateMeetingLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingLink]
    @ID uniqueidentifier,
    @MeetingID_Clear bit = 0,
    @MeetingID uniqueidentifier = NULL,
    @SeriesID_Clear bit = 0,
    @SeriesID uniqueidentifier = NULL,
    @EntityID uniqueidentifier = NULL,
    @RecordID nvarchar(450) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingLink]
    SET
        [MeetingID] = CASE WHEN @MeetingID_Clear = 1 THEN NULL ELSE ISNULL(@MeetingID, [MeetingID]) END,
        [SeriesID] = CASE WHEN @SeriesID_Clear = 1 THEN NULL ELSE ISNULL(@SeriesID, [SeriesID]) END,
        [EntityID] = ISNULL(@EntityID, [EntityID]),
        [RecordID] = ISNULL(@RecordID, [RecordID]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwMeetingLinks] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwMeetingLinks]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingLink] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the MeetingLink table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateMeetingLink]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateMeetingLink];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateMeetingLink
ON [${flyway:defaultSchema}].[MeetingLink]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingLink]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[MeetingLink] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Meeting Links */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingLink] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Meeting Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Links
-- Item: spDeleteMeetingLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR MeetingLink
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteMeetingLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingLink]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[MeetingLink]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingLink] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Meeting Links */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingLink] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Meeting Series Attendees */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
-- Item: vwMeetingSeriesAttendees
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Meeting Series Attendees
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  MeetingSeriesAttendee
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwMeetingSeriesAttendees]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwMeetingSeriesAttendees];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwMeetingSeriesAttendees]
AS
SELECT
    m.*,
    mjBizAppsTasksMeetingSeries_SeriesID.[Name] AS [Series],
    mjBizAppsCommonPerson_PersonID.[DisplayName] AS [Person],
    MJUser_UserID.[Name] AS [User]
FROM
    [${flyway:defaultSchema}].[MeetingSeriesAttendee] AS m
INNER JOIN
    [${flyway:defaultSchema}].[MeetingSeries] AS mjBizAppsTasksMeetingSeries_SeriesID
  ON
    [m].[SeriesID] = mjBizAppsTasksMeetingSeries_SeriesID.[ID]
LEFT OUTER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_PersonID
  ON
    [m].[PersonID] = mjBizAppsCommonPerson_PersonID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[User] AS MJUser_UserID
  ON
    [m].[UserID] = MJUser_UserID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingSeriesAttendees] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Meeting Series Attendees */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
-- Item: Permissions for vwMeetingSeriesAttendees
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingSeriesAttendees] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Meeting Series Attendees */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
-- Item: spCreateMeetingSeriesAttendee
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR MeetingSeriesAttendee
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateMeetingSeriesAttendee]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingSeriesAttendee];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingSeriesAttendee]
    @ID uniqueidentifier = NULL,
    @SeriesID uniqueidentifier,
    @PersonID_Clear bit = 0,
    @PersonID uniqueidentifier = NULL,
    @UserID_Clear bit = 0,
    @UserID uniqueidentifier = NULL,
    @Email_Clear bit = 0,
    @Email nvarchar(255) = NULL,
    @DisplayName_Clear bit = 0,
    @DisplayName nvarchar(255) = NULL,
    @Role nvarchar(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[MeetingSeriesAttendee]
            (
                [ID],
                [SeriesID],
                [PersonID],
                [UserID],
                [Email],
                [DisplayName],
                [Role]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @SeriesID,
                CASE WHEN @PersonID_Clear = 1 THEN NULL ELSE ISNULL(@PersonID, NULL) END,
                CASE WHEN @UserID_Clear = 1 THEN NULL ELSE ISNULL(@UserID, NULL) END,
                CASE WHEN @Email_Clear = 1 THEN NULL ELSE ISNULL(@Email, NULL) END,
                CASE WHEN @DisplayName_Clear = 1 THEN NULL ELSE ISNULL(@DisplayName, NULL) END,
                ISNULL(@Role, 'Required')
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[MeetingSeriesAttendee]
            (
                [SeriesID],
                [PersonID],
                [UserID],
                [Email],
                [DisplayName],
                [Role]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @SeriesID,
                CASE WHEN @PersonID_Clear = 1 THEN NULL ELSE ISNULL(@PersonID, NULL) END,
                CASE WHEN @UserID_Clear = 1 THEN NULL ELSE ISNULL(@UserID, NULL) END,
                CASE WHEN @Email_Clear = 1 THEN NULL ELSE ISNULL(@Email, NULL) END,
                CASE WHEN @DisplayName_Clear = 1 THEN NULL ELSE ISNULL(@DisplayName, NULL) END,
                ISNULL(@Role, 'Required')
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwMeetingSeriesAttendees] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingSeriesAttendee] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Meeting Series Attendees */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingSeriesAttendee] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Meeting Series Attendees */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
-- Item: spUpdateMeetingSeriesAttendee
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR MeetingSeriesAttendee
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateMeetingSeriesAttendee]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingSeriesAttendee];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingSeriesAttendee]
    @ID uniqueidentifier,
    @SeriesID uniqueidentifier = NULL,
    @PersonID_Clear bit = 0,
    @PersonID uniqueidentifier = NULL,
    @UserID_Clear bit = 0,
    @UserID uniqueidentifier = NULL,
    @Email_Clear bit = 0,
    @Email nvarchar(255) = NULL,
    @DisplayName_Clear bit = 0,
    @DisplayName nvarchar(255) = NULL,
    @Role nvarchar(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingSeriesAttendee]
    SET
        [SeriesID] = ISNULL(@SeriesID, [SeriesID]),
        [PersonID] = CASE WHEN @PersonID_Clear = 1 THEN NULL ELSE ISNULL(@PersonID, [PersonID]) END,
        [UserID] = CASE WHEN @UserID_Clear = 1 THEN NULL ELSE ISNULL(@UserID, [UserID]) END,
        [Email] = CASE WHEN @Email_Clear = 1 THEN NULL ELSE ISNULL(@Email, [Email]) END,
        [DisplayName] = CASE WHEN @DisplayName_Clear = 1 THEN NULL ELSE ISNULL(@DisplayName, [DisplayName]) END,
        [Role] = ISNULL(@Role, [Role])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwMeetingSeriesAttendees] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwMeetingSeriesAttendees]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingSeriesAttendee] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the MeetingSeriesAttendee table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateMeetingSeriesAttendee]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateMeetingSeriesAttendee];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateMeetingSeriesAttendee
ON [${flyway:defaultSchema}].[MeetingSeriesAttendee]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingSeriesAttendee]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[MeetingSeriesAttendee] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Meeting Series Attendees */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingSeriesAttendee] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Meeting Series Attendees */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
-- Item: spDeleteMeetingSeriesAttendee
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR MeetingSeriesAttendee
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteMeetingSeriesAttendee]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingSeriesAttendee];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingSeriesAttendee]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[MeetingSeriesAttendee]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingSeriesAttendee] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Meeting Series Attendees */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingSeriesAttendee] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID D7067566-F10A-4864-BC47-E54E02C88BD0 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='D7067566-F10A-4864-BC47-E54E02C88BD0', @RelatedEntityNameFieldMap='PresenterPerson';

/* Base View SQL for MJ_BizApps_Tasks: Meeting Attendees */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Attendees
-- Item: vwMeetingAttendees
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Meeting Attendees
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  MeetingAttendee
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwMeetingAttendees]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwMeetingAttendees];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwMeetingAttendees]
AS
SELECT
    m.*,
    mjBizAppsTasksMeeting_MeetingID.[Name] AS [Meeting],
    mjBizAppsCommonPerson_PersonID.[DisplayName] AS [Person],
    MJUser_UserID.[Name] AS [User]
FROM
    [${flyway:defaultSchema}].[MeetingAttendee] AS m
INNER JOIN
    [${flyway:defaultSchema}].[Meeting] AS mjBizAppsTasksMeeting_MeetingID
  ON
    [m].[MeetingID] = mjBizAppsTasksMeeting_MeetingID.[ID]
LEFT OUTER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_PersonID
  ON
    [m].[PersonID] = mjBizAppsCommonPerson_PersonID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[User] AS MJUser_UserID
  ON
    [m].[UserID] = MJUser_UserID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingAttendees] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Meeting Attendees */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Attendees
-- Item: Permissions for vwMeetingAttendees
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingAttendees] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Meeting Attendees */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Attendees
-- Item: spCreateMeetingAttendee
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR MeetingAttendee
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateMeetingAttendee]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingAttendee];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingAttendee]
    @ID uniqueidentifier = NULL,
    @MeetingID uniqueidentifier,
    @PersonID_Clear bit = 0,
    @PersonID uniqueidentifier = NULL,
    @UserID_Clear bit = 0,
    @UserID uniqueidentifier = NULL,
    @Email_Clear bit = 0,
    @Email nvarchar(255) = NULL,
    @DisplayName_Clear bit = 0,
    @DisplayName nvarchar(255) = NULL,
    @Role nvarchar(20) = NULL,
    @ResponseStatus nvarchar(20) = NULL,
    @RespondedAt_Clear bit = 0,
    @RespondedAt datetimeoffset = NULL,
    @AttendanceStatus nvarchar(20) = NULL,
    @JoinedAt_Clear bit = 0,
    @JoinedAt datetimeoffset = NULL,
    @LeftAt_Clear bit = 0,
    @LeftAt datetimeoffset = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[MeetingAttendee]
            (
                [ID],
                [MeetingID],
                [PersonID],
                [UserID],
                [Email],
                [DisplayName],
                [Role],
                [ResponseStatus],
                [RespondedAt],
                [AttendanceStatus],
                [JoinedAt],
                [LeftAt],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @MeetingID,
                CASE WHEN @PersonID_Clear = 1 THEN NULL ELSE ISNULL(@PersonID, NULL) END,
                CASE WHEN @UserID_Clear = 1 THEN NULL ELSE ISNULL(@UserID, NULL) END,
                CASE WHEN @Email_Clear = 1 THEN NULL ELSE ISNULL(@Email, NULL) END,
                CASE WHEN @DisplayName_Clear = 1 THEN NULL ELSE ISNULL(@DisplayName, NULL) END,
                ISNULL(@Role, 'Required'),
                ISNULL(@ResponseStatus, 'None'),
                CASE WHEN @RespondedAt_Clear = 1 THEN NULL ELSE ISNULL(@RespondedAt, NULL) END,
                ISNULL(@AttendanceStatus, 'Unknown'),
                CASE WHEN @JoinedAt_Clear = 1 THEN NULL ELSE ISNULL(@JoinedAt, NULL) END,
                CASE WHEN @LeftAt_Clear = 1 THEN NULL ELSE ISNULL(@LeftAt, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[MeetingAttendee]
            (
                [MeetingID],
                [PersonID],
                [UserID],
                [Email],
                [DisplayName],
                [Role],
                [ResponseStatus],
                [RespondedAt],
                [AttendanceStatus],
                [JoinedAt],
                [LeftAt],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @MeetingID,
                CASE WHEN @PersonID_Clear = 1 THEN NULL ELSE ISNULL(@PersonID, NULL) END,
                CASE WHEN @UserID_Clear = 1 THEN NULL ELSE ISNULL(@UserID, NULL) END,
                CASE WHEN @Email_Clear = 1 THEN NULL ELSE ISNULL(@Email, NULL) END,
                CASE WHEN @DisplayName_Clear = 1 THEN NULL ELSE ISNULL(@DisplayName, NULL) END,
                ISNULL(@Role, 'Required'),
                ISNULL(@ResponseStatus, 'None'),
                CASE WHEN @RespondedAt_Clear = 1 THEN NULL ELSE ISNULL(@RespondedAt, NULL) END,
                ISNULL(@AttendanceStatus, 'Unknown'),
                CASE WHEN @JoinedAt_Clear = 1 THEN NULL ELSE ISNULL(@JoinedAt, NULL) END,
                CASE WHEN @LeftAt_Clear = 1 THEN NULL ELSE ISNULL(@LeftAt, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwMeetingAttendees] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingAttendee] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Meeting Attendees */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingAttendee] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Meeting Attendees */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Attendees
-- Item: spUpdateMeetingAttendee
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR MeetingAttendee
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateMeetingAttendee]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingAttendee];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingAttendee]
    @ID uniqueidentifier,
    @MeetingID uniqueidentifier = NULL,
    @PersonID_Clear bit = 0,
    @PersonID uniqueidentifier = NULL,
    @UserID_Clear bit = 0,
    @UserID uniqueidentifier = NULL,
    @Email_Clear bit = 0,
    @Email nvarchar(255) = NULL,
    @DisplayName_Clear bit = 0,
    @DisplayName nvarchar(255) = NULL,
    @Role nvarchar(20) = NULL,
    @ResponseStatus nvarchar(20) = NULL,
    @RespondedAt_Clear bit = 0,
    @RespondedAt datetimeoffset = NULL,
    @AttendanceStatus nvarchar(20) = NULL,
    @JoinedAt_Clear bit = 0,
    @JoinedAt datetimeoffset = NULL,
    @LeftAt_Clear bit = 0,
    @LeftAt datetimeoffset = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingAttendee]
    SET
        [MeetingID] = ISNULL(@MeetingID, [MeetingID]),
        [PersonID] = CASE WHEN @PersonID_Clear = 1 THEN NULL ELSE ISNULL(@PersonID, [PersonID]) END,
        [UserID] = CASE WHEN @UserID_Clear = 1 THEN NULL ELSE ISNULL(@UserID, [UserID]) END,
        [Email] = CASE WHEN @Email_Clear = 1 THEN NULL ELSE ISNULL(@Email, [Email]) END,
        [DisplayName] = CASE WHEN @DisplayName_Clear = 1 THEN NULL ELSE ISNULL(@DisplayName, [DisplayName]) END,
        [Role] = ISNULL(@Role, [Role]),
        [ResponseStatus] = ISNULL(@ResponseStatus, [ResponseStatus]),
        [RespondedAt] = CASE WHEN @RespondedAt_Clear = 1 THEN NULL ELSE ISNULL(@RespondedAt, [RespondedAt]) END,
        [AttendanceStatus] = ISNULL(@AttendanceStatus, [AttendanceStatus]),
        [JoinedAt] = CASE WHEN @JoinedAt_Clear = 1 THEN NULL ELSE ISNULL(@JoinedAt, [JoinedAt]) END,
        [LeftAt] = CASE WHEN @LeftAt_Clear = 1 THEN NULL ELSE ISNULL(@LeftAt, [LeftAt]) END,
        [Notes] = CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, [Notes]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwMeetingAttendees] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwMeetingAttendees]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingAttendee] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the MeetingAttendee table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateMeetingAttendee]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateMeetingAttendee];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateMeetingAttendee
ON [${flyway:defaultSchema}].[MeetingAttendee]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingAttendee]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[MeetingAttendee] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Meeting Attendees */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingAttendee] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Meeting Attendees */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Attendees
-- Item: spDeleteMeetingAttendee
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR MeetingAttendee
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteMeetingAttendee]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingAttendee];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingAttendee]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[MeetingAttendee]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingAttendee] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Meeting Attendees */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingAttendee] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Meeting Notes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Notes
-- Item: vwMeetingNotes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Meeting Notes
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  MeetingNote
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwMeetingNotes]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwMeetingNotes];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwMeetingNotes]
AS
SELECT
    m.*,
    mjBizAppsTasksMeeting_MeetingID.[Name] AS [Meeting],
    mjBizAppsTasksMeetingAgendaItem_AgendaItemID.[Name] AS [AgendaItem],
    mjBizAppsCommonPerson_AuthorPersonID.[DisplayName] AS [AuthorPerson],
    MJAIPromptRun_AIPromptRunID.[RunName] AS [AIPromptRun]
FROM
    [${flyway:defaultSchema}].[MeetingNote] AS m
INNER JOIN
    [${flyway:defaultSchema}].[Meeting] AS mjBizAppsTasksMeeting_MeetingID
  ON
    [m].[MeetingID] = mjBizAppsTasksMeeting_MeetingID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[MeetingAgendaItem] AS mjBizAppsTasksMeetingAgendaItem_AgendaItemID
  ON
    [m].[AgendaItemID] = mjBizAppsTasksMeetingAgendaItem_AgendaItemID.[ID]
LEFT OUTER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_AuthorPersonID
  ON
    [m].[AuthorPersonID] = mjBizAppsCommonPerson_AuthorPersonID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[AIPromptRun] AS MJAIPromptRun_AIPromptRunID
  ON
    [m].[AIPromptRunID] = MJAIPromptRun_AIPromptRunID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingNotes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Meeting Notes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Notes
-- Item: Permissions for vwMeetingNotes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingNotes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Meeting Notes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Notes
-- Item: spCreateMeetingNote
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR MeetingNote
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateMeetingNote]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingNote];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingNote]
    @ID uniqueidentifier = NULL,
    @MeetingID uniqueidentifier,
    @AgendaItemID_Clear bit = 0,
    @AgendaItemID uniqueidentifier = NULL,
    @Kind nvarchar(20) = NULL,
    @Title_Clear bit = 0,
    @Title nvarchar(255) = NULL,
    @Body nvarchar(MAX),
    @Source nvarchar(20) = NULL,
    @Status nvarchar(20) = NULL,
    @AuthorPersonID_Clear bit = 0,
    @AuthorPersonID uniqueidentifier = NULL,
    @AIPromptRunID_Clear bit = 0,
    @AIPromptRunID uniqueidentifier = NULL,
    @ProposedTasks_Clear bit = 0,
    @ProposedTasks nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[MeetingNote]
            (
                [ID],
                [MeetingID],
                [AgendaItemID],
                [Kind],
                [Title],
                [Body],
                [Source],
                [Status],
                [AuthorPersonID],
                [AIPromptRunID],
                [ProposedTasks]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @MeetingID,
                CASE WHEN @AgendaItemID_Clear = 1 THEN NULL ELSE ISNULL(@AgendaItemID, NULL) END,
                ISNULL(@Kind, 'Notes'),
                CASE WHEN @Title_Clear = 1 THEN NULL ELSE ISNULL(@Title, NULL) END,
                @Body,
                ISNULL(@Source, 'Manual'),
                ISNULL(@Status, 'Draft'),
                CASE WHEN @AuthorPersonID_Clear = 1 THEN NULL ELSE ISNULL(@AuthorPersonID, NULL) END,
                CASE WHEN @AIPromptRunID_Clear = 1 THEN NULL ELSE ISNULL(@AIPromptRunID, NULL) END,
                CASE WHEN @ProposedTasks_Clear = 1 THEN NULL ELSE ISNULL(@ProposedTasks, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[MeetingNote]
            (
                [MeetingID],
                [AgendaItemID],
                [Kind],
                [Title],
                [Body],
                [Source],
                [Status],
                [AuthorPersonID],
                [AIPromptRunID],
                [ProposedTasks]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @MeetingID,
                CASE WHEN @AgendaItemID_Clear = 1 THEN NULL ELSE ISNULL(@AgendaItemID, NULL) END,
                ISNULL(@Kind, 'Notes'),
                CASE WHEN @Title_Clear = 1 THEN NULL ELSE ISNULL(@Title, NULL) END,
                @Body,
                ISNULL(@Source, 'Manual'),
                ISNULL(@Status, 'Draft'),
                CASE WHEN @AuthorPersonID_Clear = 1 THEN NULL ELSE ISNULL(@AuthorPersonID, NULL) END,
                CASE WHEN @AIPromptRunID_Clear = 1 THEN NULL ELSE ISNULL(@AIPromptRunID, NULL) END,
                CASE WHEN @ProposedTasks_Clear = 1 THEN NULL ELSE ISNULL(@ProposedTasks, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwMeetingNotes] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingNote] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Meeting Notes */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingNote] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Meeting Notes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Notes
-- Item: spUpdateMeetingNote
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR MeetingNote
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateMeetingNote]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingNote];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingNote]
    @ID uniqueidentifier,
    @MeetingID uniqueidentifier = NULL,
    @AgendaItemID_Clear bit = 0,
    @AgendaItemID uniqueidentifier = NULL,
    @Kind nvarchar(20) = NULL,
    @Title_Clear bit = 0,
    @Title nvarchar(255) = NULL,
    @Body nvarchar(MAX) = NULL,
    @Source nvarchar(20) = NULL,
    @Status nvarchar(20) = NULL,
    @AuthorPersonID_Clear bit = 0,
    @AuthorPersonID uniqueidentifier = NULL,
    @AIPromptRunID_Clear bit = 0,
    @AIPromptRunID uniqueidentifier = NULL,
    @ProposedTasks_Clear bit = 0,
    @ProposedTasks nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingNote]
    SET
        [MeetingID] = ISNULL(@MeetingID, [MeetingID]),
        [AgendaItemID] = CASE WHEN @AgendaItemID_Clear = 1 THEN NULL ELSE ISNULL(@AgendaItemID, [AgendaItemID]) END,
        [Kind] = ISNULL(@Kind, [Kind]),
        [Title] = CASE WHEN @Title_Clear = 1 THEN NULL ELSE ISNULL(@Title, [Title]) END,
        [Body] = ISNULL(@Body, [Body]),
        [Source] = ISNULL(@Source, [Source]),
        [Status] = ISNULL(@Status, [Status]),
        [AuthorPersonID] = CASE WHEN @AuthorPersonID_Clear = 1 THEN NULL ELSE ISNULL(@AuthorPersonID, [AuthorPersonID]) END,
        [AIPromptRunID] = CASE WHEN @AIPromptRunID_Clear = 1 THEN NULL ELSE ISNULL(@AIPromptRunID, [AIPromptRunID]) END,
        [ProposedTasks] = CASE WHEN @ProposedTasks_Clear = 1 THEN NULL ELSE ISNULL(@ProposedTasks, [ProposedTasks]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwMeetingNotes] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwMeetingNotes]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingNote] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the MeetingNote table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateMeetingNote]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateMeetingNote];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateMeetingNote
ON [${flyway:defaultSchema}].[MeetingNote]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingNote]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[MeetingNote] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Meeting Notes */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingNote] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Meeting Notes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Notes
-- Item: spDeleteMeetingNote
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR MeetingNote
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteMeetingNote]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingNote];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingNote]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[MeetingNote]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingNote] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Meeting Notes */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingNote] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID 89F24E04-00B7-410C-A6FC-8EC39550E3F1 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='89F24E04-00B7-410C-A6FC-8EC39550E3F1', @RelatedEntityNameFieldMap='DeferredToMeeting';

/* Base View SQL for MJ_BizApps_Tasks: Meeting Series */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series
-- Item: vwMeetingSeries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Meeting Series
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  MeetingSeries
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwMeetingSeries]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwMeetingSeries];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwMeetingSeries]
AS
SELECT
    m.*,
    mjBizAppsTasksMeetingType_TypeID.[Name] AS [Type],
    mjBizAppsCommonPerson_OrganizerPersonID.[DisplayName] AS [OrganizerPerson],
    mjBizAppsTasksVideoProvider_VideoProviderID.[Name] AS [VideoProvider],
    mjBizAppsCommonPerson_CreatedByPersonID.[DisplayName] AS [CreatedByPerson]
FROM
    [${flyway:defaultSchema}].[MeetingSeries] AS m
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[MeetingType] AS mjBizAppsTasksMeetingType_TypeID
  ON
    [m].[TypeID] = mjBizAppsTasksMeetingType_TypeID.[ID]
INNER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_OrganizerPersonID
  ON
    [m].[OrganizerPersonID] = mjBizAppsCommonPerson_OrganizerPersonID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[VideoProvider] AS mjBizAppsTasksVideoProvider_VideoProviderID
  ON
    [m].[VideoProviderID] = mjBizAppsTasksVideoProvider_VideoProviderID.[ID]
LEFT OUTER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_CreatedByPersonID
  ON
    [m].[CreatedByPersonID] = mjBizAppsCommonPerson_CreatedByPersonID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingSeries] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Meeting Series */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series
-- Item: Permissions for vwMeetingSeries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingSeries] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Meeting Series */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series
-- Item: spCreateMeetingSeries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR MeetingSeries
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateMeetingSeries]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingSeries];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingSeries]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(255),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @TypeID_Clear bit = 0,
    @TypeID uniqueidentifier = NULL,
    @OrganizerPersonID uniqueidentifier,
    @RecurrenceRule nvarchar(500),
    @TimeZone nvarchar(64),
    @FirstStartsAt datetimeoffset,
    @DurationMinutes int,
    @LocationType nvarchar(20) = NULL,
    @Location_Clear bit = 0,
    @Location nvarchar(500) = NULL,
    @VideoProviderID_Clear bit = 0,
    @VideoProviderID uniqueidentifier = NULL,
    @Visibility nvarchar(20) = NULL,
    @Status nvarchar(20) = NULL,
    @MaterializedThrough_Clear bit = 0,
    @MaterializedThrough datetimeoffset = NULL,
    @CreatedByPersonID_Clear bit = 0,
    @CreatedByPersonID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[MeetingSeries]
            (
                [ID],
                [Name],
                [Description],
                [TypeID],
                [OrganizerPersonID],
                [RecurrenceRule],
                [TimeZone],
                [FirstStartsAt],
                [DurationMinutes],
                [LocationType],
                [Location],
                [VideoProviderID],
                [Visibility],
                [Status],
                [MaterializedThrough],
                [CreatedByPersonID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, NULL) END,
                @OrganizerPersonID,
                @RecurrenceRule,
                @TimeZone,
                @FirstStartsAt,
                @DurationMinutes,
                ISNULL(@LocationType, 'Virtual'),
                CASE WHEN @Location_Clear = 1 THEN NULL ELSE ISNULL(@Location, NULL) END,
                CASE WHEN @VideoProviderID_Clear = 1 THEN NULL ELSE ISNULL(@VideoProviderID, NULL) END,
                ISNULL(@Visibility, 'Standard'),
                ISNULL(@Status, 'Active'),
                CASE WHEN @MaterializedThrough_Clear = 1 THEN NULL ELSE ISNULL(@MaterializedThrough, NULL) END,
                CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[MeetingSeries]
            (
                [Name],
                [Description],
                [TypeID],
                [OrganizerPersonID],
                [RecurrenceRule],
                [TimeZone],
                [FirstStartsAt],
                [DurationMinutes],
                [LocationType],
                [Location],
                [VideoProviderID],
                [Visibility],
                [Status],
                [MaterializedThrough],
                [CreatedByPersonID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, NULL) END,
                @OrganizerPersonID,
                @RecurrenceRule,
                @TimeZone,
                @FirstStartsAt,
                @DurationMinutes,
                ISNULL(@LocationType, 'Virtual'),
                CASE WHEN @Location_Clear = 1 THEN NULL ELSE ISNULL(@Location, NULL) END,
                CASE WHEN @VideoProviderID_Clear = 1 THEN NULL ELSE ISNULL(@VideoProviderID, NULL) END,
                ISNULL(@Visibility, 'Standard'),
                ISNULL(@Status, 'Active'),
                CASE WHEN @MaterializedThrough_Clear = 1 THEN NULL ELSE ISNULL(@MaterializedThrough, NULL) END,
                CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwMeetingSeries] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingSeries] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Meeting Series */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingSeries] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Meeting Series */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series
-- Item: spUpdateMeetingSeries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR MeetingSeries
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateMeetingSeries]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingSeries];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingSeries]
    @ID uniqueidentifier,
    @Name nvarchar(255) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @TypeID_Clear bit = 0,
    @TypeID uniqueidentifier = NULL,
    @OrganizerPersonID uniqueidentifier = NULL,
    @RecurrenceRule nvarchar(500) = NULL,
    @TimeZone nvarchar(64) = NULL,
    @FirstStartsAt datetimeoffset = NULL,
    @DurationMinutes int = NULL,
    @LocationType nvarchar(20) = NULL,
    @Location_Clear bit = 0,
    @Location nvarchar(500) = NULL,
    @VideoProviderID_Clear bit = 0,
    @VideoProviderID uniqueidentifier = NULL,
    @Visibility nvarchar(20) = NULL,
    @Status nvarchar(20) = NULL,
    @MaterializedThrough_Clear bit = 0,
    @MaterializedThrough datetimeoffset = NULL,
    @CreatedByPersonID_Clear bit = 0,
    @CreatedByPersonID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingSeries]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [TypeID] = CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, [TypeID]) END,
        [OrganizerPersonID] = ISNULL(@OrganizerPersonID, [OrganizerPersonID]),
        [RecurrenceRule] = ISNULL(@RecurrenceRule, [RecurrenceRule]),
        [TimeZone] = ISNULL(@TimeZone, [TimeZone]),
        [FirstStartsAt] = ISNULL(@FirstStartsAt, [FirstStartsAt]),
        [DurationMinutes] = ISNULL(@DurationMinutes, [DurationMinutes]),
        [LocationType] = ISNULL(@LocationType, [LocationType]),
        [Location] = CASE WHEN @Location_Clear = 1 THEN NULL ELSE ISNULL(@Location, [Location]) END,
        [VideoProviderID] = CASE WHEN @VideoProviderID_Clear = 1 THEN NULL ELSE ISNULL(@VideoProviderID, [VideoProviderID]) END,
        [Visibility] = ISNULL(@Visibility, [Visibility]),
        [Status] = ISNULL(@Status, [Status]),
        [MaterializedThrough] = CASE WHEN @MaterializedThrough_Clear = 1 THEN NULL ELSE ISNULL(@MaterializedThrough, [MaterializedThrough]) END,
        [CreatedByPersonID] = CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, [CreatedByPersonID]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwMeetingSeries] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwMeetingSeries]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingSeries] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the MeetingSeries table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateMeetingSeries]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateMeetingSeries];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateMeetingSeries
ON [${flyway:defaultSchema}].[MeetingSeries]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingSeries]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[MeetingSeries] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Meeting Series */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingSeries] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Meeting Series */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series
-- Item: spDeleteMeetingSeries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR MeetingSeries
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteMeetingSeries]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingSeries];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingSeries]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[MeetingSeries]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingSeries] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Meeting Series */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingSeries] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Meeting Agenda Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
-- Item: vwMeetingAgendaItems
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Meeting Agenda Items
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  MeetingAgendaItem
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwMeetingAgendaItems]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwMeetingAgendaItems];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwMeetingAgendaItems]
AS
SELECT
    m.*,
    mjBizAppsTasksMeeting_MeetingID.[Name] AS [Meeting],
    mjBizAppsTasksMeetingAgendaItem_ParentID.[Name] AS [Parent],
    mjBizAppsTasksMeetingAgendaItemType_TypeID.[Name] AS [Type],
    mjBizAppsCommonPerson_PresenterPersonID.[DisplayName] AS [PresenterPerson],
    mjBizAppsTasksMeeting_DeferredToMeetingID.[Name] AS [DeferredToMeeting]
FROM
    [${flyway:defaultSchema}].[MeetingAgendaItem] AS m
INNER JOIN
    [${flyway:defaultSchema}].[Meeting] AS mjBizAppsTasksMeeting_MeetingID
  ON
    [m].[MeetingID] = mjBizAppsTasksMeeting_MeetingID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[MeetingAgendaItem] AS mjBizAppsTasksMeetingAgendaItem_ParentID
  ON
    [m].[ParentID] = mjBizAppsTasksMeetingAgendaItem_ParentID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[MeetingAgendaItemType] AS mjBizAppsTasksMeetingAgendaItemType_TypeID
  ON
    [m].[TypeID] = mjBizAppsTasksMeetingAgendaItemType_TypeID.[ID]
LEFT OUTER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_PresenterPersonID
  ON
    [m].[PresenterPersonID] = mjBizAppsCommonPerson_PresenterPersonID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Meeting] AS mjBizAppsTasksMeeting_DeferredToMeetingID
  ON
    [m].[DeferredToMeetingID] = mjBizAppsTasksMeeting_DeferredToMeetingID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingAgendaItems] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Meeting Agenda Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
-- Item: Permissions for vwMeetingAgendaItems
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingAgendaItems] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Meeting Agenda Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
-- Item: spCreateMeetingAgendaItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR MeetingAgendaItem
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateMeetingAgendaItem]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingAgendaItem];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingAgendaItem]
    @ID uniqueidentifier = NULL,
    @MeetingID uniqueidentifier,
    @ParentID_Clear bit = 0,
    @ParentID uniqueidentifier = NULL,
    @Sequence int = NULL,
    @Name nvarchar(500),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @TypeID_Clear bit = 0,
    @TypeID uniqueidentifier = NULL,
    @PresenterPersonID_Clear bit = 0,
    @PresenterPersonID uniqueidentifier = NULL,
    @DurationMinutes_Clear bit = 0,
    @DurationMinutes int = NULL,
    @Status nvarchar(20) = NULL,
    @StartedAt_Clear bit = 0,
    @StartedAt datetimeoffset = NULL,
    @EndedAt_Clear bit = 0,
    @EndedAt datetimeoffset = NULL,
    @Outcome_Clear bit = 0,
    @Outcome nvarchar(MAX) = NULL,
    @DeferredToMeetingID_Clear bit = 0,
    @DeferredToMeetingID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[MeetingAgendaItem]
            (
                [ID],
                [MeetingID],
                [ParentID],
                [Sequence],
                [Name],
                [Description],
                [TypeID],
                [PresenterPersonID],
                [DurationMinutes],
                [Status],
                [StartedAt],
                [EndedAt],
                [Outcome],
                [DeferredToMeetingID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @MeetingID,
                CASE WHEN @ParentID_Clear = 1 THEN NULL ELSE ISNULL(@ParentID, NULL) END,
                ISNULL(@Sequence, 100),
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, NULL) END,
                CASE WHEN @PresenterPersonID_Clear = 1 THEN NULL ELSE ISNULL(@PresenterPersonID, NULL) END,
                CASE WHEN @DurationMinutes_Clear = 1 THEN NULL ELSE ISNULL(@DurationMinutes, NULL) END,
                ISNULL(@Status, 'Planned'),
                CASE WHEN @StartedAt_Clear = 1 THEN NULL ELSE ISNULL(@StartedAt, NULL) END,
                CASE WHEN @EndedAt_Clear = 1 THEN NULL ELSE ISNULL(@EndedAt, NULL) END,
                CASE WHEN @Outcome_Clear = 1 THEN NULL ELSE ISNULL(@Outcome, NULL) END,
                CASE WHEN @DeferredToMeetingID_Clear = 1 THEN NULL ELSE ISNULL(@DeferredToMeetingID, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[MeetingAgendaItem]
            (
                [MeetingID],
                [ParentID],
                [Sequence],
                [Name],
                [Description],
                [TypeID],
                [PresenterPersonID],
                [DurationMinutes],
                [Status],
                [StartedAt],
                [EndedAt],
                [Outcome],
                [DeferredToMeetingID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @MeetingID,
                CASE WHEN @ParentID_Clear = 1 THEN NULL ELSE ISNULL(@ParentID, NULL) END,
                ISNULL(@Sequence, 100),
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, NULL) END,
                CASE WHEN @PresenterPersonID_Clear = 1 THEN NULL ELSE ISNULL(@PresenterPersonID, NULL) END,
                CASE WHEN @DurationMinutes_Clear = 1 THEN NULL ELSE ISNULL(@DurationMinutes, NULL) END,
                ISNULL(@Status, 'Planned'),
                CASE WHEN @StartedAt_Clear = 1 THEN NULL ELSE ISNULL(@StartedAt, NULL) END,
                CASE WHEN @EndedAt_Clear = 1 THEN NULL ELSE ISNULL(@EndedAt, NULL) END,
                CASE WHEN @Outcome_Clear = 1 THEN NULL ELSE ISNULL(@Outcome, NULL) END,
                CASE WHEN @DeferredToMeetingID_Clear = 1 THEN NULL ELSE ISNULL(@DeferredToMeetingID, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwMeetingAgendaItems] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingAgendaItem] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Meeting Agenda Items */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingAgendaItem] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Meeting Agenda Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
-- Item: spUpdateMeetingAgendaItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR MeetingAgendaItem
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateMeetingAgendaItem]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingAgendaItem];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingAgendaItem]
    @ID uniqueidentifier,
    @MeetingID uniqueidentifier = NULL,
    @ParentID_Clear bit = 0,
    @ParentID uniqueidentifier = NULL,
    @Sequence int = NULL,
    @Name nvarchar(500) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @TypeID_Clear bit = 0,
    @TypeID uniqueidentifier = NULL,
    @PresenterPersonID_Clear bit = 0,
    @PresenterPersonID uniqueidentifier = NULL,
    @DurationMinutes_Clear bit = 0,
    @DurationMinutes int = NULL,
    @Status nvarchar(20) = NULL,
    @StartedAt_Clear bit = 0,
    @StartedAt datetimeoffset = NULL,
    @EndedAt_Clear bit = 0,
    @EndedAt datetimeoffset = NULL,
    @Outcome_Clear bit = 0,
    @Outcome nvarchar(MAX) = NULL,
    @DeferredToMeetingID_Clear bit = 0,
    @DeferredToMeetingID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingAgendaItem]
    SET
        [MeetingID] = ISNULL(@MeetingID, [MeetingID]),
        [ParentID] = CASE WHEN @ParentID_Clear = 1 THEN NULL ELSE ISNULL(@ParentID, [ParentID]) END,
        [Sequence] = ISNULL(@Sequence, [Sequence]),
        [Name] = ISNULL(@Name, [Name]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [TypeID] = CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, [TypeID]) END,
        [PresenterPersonID] = CASE WHEN @PresenterPersonID_Clear = 1 THEN NULL ELSE ISNULL(@PresenterPersonID, [PresenterPersonID]) END,
        [DurationMinutes] = CASE WHEN @DurationMinutes_Clear = 1 THEN NULL ELSE ISNULL(@DurationMinutes, [DurationMinutes]) END,
        [Status] = ISNULL(@Status, [Status]),
        [StartedAt] = CASE WHEN @StartedAt_Clear = 1 THEN NULL ELSE ISNULL(@StartedAt, [StartedAt]) END,
        [EndedAt] = CASE WHEN @EndedAt_Clear = 1 THEN NULL ELSE ISNULL(@EndedAt, [EndedAt]) END,
        [Outcome] = CASE WHEN @Outcome_Clear = 1 THEN NULL ELSE ISNULL(@Outcome, [Outcome]) END,
        [DeferredToMeetingID] = CASE WHEN @DeferredToMeetingID_Clear = 1 THEN NULL ELSE ISNULL(@DeferredToMeetingID, [DeferredToMeetingID]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwMeetingAgendaItems] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwMeetingAgendaItems]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingAgendaItem] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the MeetingAgendaItem table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateMeetingAgendaItem]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateMeetingAgendaItem];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateMeetingAgendaItem
ON [${flyway:defaultSchema}].[MeetingAgendaItem]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingAgendaItem]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[MeetingAgendaItem] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Meeting Agenda Items */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingAgendaItem] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Meeting Agenda Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
-- Item: spDeleteMeetingAgendaItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR MeetingAgendaItem
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteMeetingAgendaItem]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingAgendaItem];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingAgendaItem]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[MeetingAgendaItem]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingAgendaItem] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Meeting Agenda Items */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingAgendaItem] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for Meeting */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meetings
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TypeID in table Meeting
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Meeting_TypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Meeting]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Meeting_TypeID ON [${flyway:defaultSchema}].[Meeting] ([TypeID]);

-- Index for foreign key SeriesID in table Meeting
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Meeting_SeriesID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Meeting]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Meeting_SeriesID ON [${flyway:defaultSchema}].[Meeting] ([SeriesID]);

-- Index for foreign key VideoProviderID in table Meeting
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Meeting_VideoProviderID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Meeting]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Meeting_VideoProviderID ON [${flyway:defaultSchema}].[Meeting] ([VideoProviderID]);

-- Index for foreign key OrganizerPersonID in table Meeting
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Meeting_OrganizerPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Meeting]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Meeting_OrganizerPersonID ON [${flyway:defaultSchema}].[Meeting] ([OrganizerPersonID]);

-- Index for foreign key TranscriptFileID in table Meeting
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Meeting_TranscriptFileID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Meeting]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Meeting_TranscriptFileID ON [${flyway:defaultSchema}].[Meeting] ([TranscriptFileID]);

-- Index for foreign key CreatedByPersonID in table Meeting
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Meeting_CreatedByPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Meeting]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Meeting_CreatedByPersonID ON [${flyway:defaultSchema}].[Meeting] ([CreatedByPersonID]);

/* SQL text to update entity field related entity name field map for entity field ID B0BB59CB-CC1F-474A-94B4-00EFD53282D8 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='B0BB59CB-CC1F-474A-94B4-00EFD53282D8', @RelatedEntityNameFieldMap='Type';

/* SQL text to update entity field related entity name field map for entity field ID 766C5B07-2435-43F7-AFB9-B52379A05FE5 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='766C5B07-2435-43F7-AFB9-B52379A05FE5', @RelatedEntityNameFieldMap='Series';

/* SQL text to update entity field related entity name field map for entity field ID A3B820B7-9FA2-43F3-B5F6-05EB8145AEB7 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='A3B820B7-9FA2-43F3-B5F6-05EB8145AEB7', @RelatedEntityNameFieldMap='VideoProvider';

/* SQL text to update entity field related entity name field map for entity field ID 3E551302-F355-4DB0-867A-2BC81441EBB7 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='3E551302-F355-4DB0-867A-2BC81441EBB7', @RelatedEntityNameFieldMap='OrganizerPerson';

/* SQL text to update entity field related entity name field map for entity field ID 9CDA5909-4BE3-42E1-A29D-F1E1768E7DA9 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='9CDA5909-4BE3-42E1-A29D-F1E1768E7DA9', @RelatedEntityNameFieldMap='TranscriptFile';

/* SQL text to update entity field related entity name field map for entity field ID BF1D9416-B0E0-4737-ADA7-41793F2AD8CF */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='BF1D9416-B0E0-4737-ADA7-41793F2AD8CF', @RelatedEntityNameFieldMap='CreatedByPerson';

/* Base View SQL for MJ_BizApps_Tasks: Meetings */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meetings
-- Item: vwMeetings
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Meetings
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  Meeting
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwMeetings]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwMeetings];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwMeetings]
AS
SELECT
    m.*,
    mjBizAppsTasksMeetingType_TypeID.[Name] AS [Type],
    mjBizAppsTasksMeetingSeries_SeriesID.[Name] AS [Series],
    mjBizAppsTasksVideoProvider_VideoProviderID.[Name] AS [VideoProvider],
    mjBizAppsCommonPerson_OrganizerPersonID.[DisplayName] AS [OrganizerPerson],
    MJFile_TranscriptFileID.[Name] AS [TranscriptFile],
    mjBizAppsCommonPerson_CreatedByPersonID.[DisplayName] AS [CreatedByPerson]
FROM
    [${flyway:defaultSchema}].[Meeting] AS m
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[MeetingType] AS mjBizAppsTasksMeetingType_TypeID
  ON
    [m].[TypeID] = mjBizAppsTasksMeetingType_TypeID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[MeetingSeries] AS mjBizAppsTasksMeetingSeries_SeriesID
  ON
    [m].[SeriesID] = mjBizAppsTasksMeetingSeries_SeriesID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[VideoProvider] AS mjBizAppsTasksVideoProvider_VideoProviderID
  ON
    [m].[VideoProviderID] = mjBizAppsTasksVideoProvider_VideoProviderID.[ID]
INNER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_OrganizerPersonID
  ON
    [m].[OrganizerPersonID] = mjBizAppsCommonPerson_OrganizerPersonID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[File] AS MJFile_TranscriptFileID
  ON
    [m].[TranscriptFileID] = MJFile_TranscriptFileID.[ID]
LEFT OUTER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_CreatedByPersonID
  ON
    [m].[CreatedByPersonID] = mjBizAppsCommonPerson_CreatedByPersonID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetings] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Meetings */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meetings
-- Item: Permissions for vwMeetings
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetings] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Meetings */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meetings
-- Item: spCreateMeeting
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Meeting
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateMeeting]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateMeeting];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateMeeting]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(255),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @TypeID_Clear bit = 0,
    @TypeID uniqueidentifier = NULL,
    @SeriesID_Clear bit = 0,
    @SeriesID uniqueidentifier = NULL,
    @OccurrenceStartsAt_Clear bit = 0,
    @OccurrenceStartsAt datetimeoffset = NULL,
    @Status nvarchar(20) = NULL,
    @StartsAt datetimeoffset,
    @EndsAt datetimeoffset,
    @TimeZone nvarchar(64),
    @LocationType nvarchar(20) = NULL,
    @Location_Clear bit = 0,
    @Location nvarchar(500) = NULL,
    @VideoProviderID_Clear bit = 0,
    @VideoProviderID uniqueidentifier = NULL,
    @VideoMeetingID_Clear bit = 0,
    @VideoMeetingID nvarchar(255) = NULL,
    @VideoJoinURL_Clear bit = 0,
    @VideoJoinURL nvarchar(1000) = NULL,
    @DialInDetails_Clear bit = 0,
    @DialInDetails nvarchar(1000) = NULL,
    @OrganizerPersonID uniqueidentifier,
    @Visibility nvarchar(20) = NULL,
    @ActualStartedAt_Clear bit = 0,
    @ActualStartedAt datetimeoffset = NULL,
    @ActualEndedAt_Clear bit = 0,
    @ActualEndedAt datetimeoffset = NULL,
    @CancelledAt_Clear bit = 0,
    @CancelledAt datetimeoffset = NULL,
    @CancellationReason_Clear bit = 0,
    @CancellationReason nvarchar(500) = NULL,
    @VideoRecordingURL_Clear bit = 0,
    @VideoRecordingURL nvarchar(1000) = NULL,
    @TranscriptFileID_Clear bit = 0,
    @TranscriptFileID uniqueidentifier = NULL,
    @CreatedByPersonID_Clear bit = 0,
    @CreatedByPersonID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[Meeting]
            (
                [ID],
                [Name],
                [Description],
                [TypeID],
                [SeriesID],
                [OccurrenceStartsAt],
                [Status],
                [StartsAt],
                [EndsAt],
                [TimeZone],
                [LocationType],
                [Location],
                [VideoProviderID],
                [VideoMeetingID],
                [VideoJoinURL],
                [DialInDetails],
                [OrganizerPersonID],
                [Visibility],
                [ActualStartedAt],
                [ActualEndedAt],
                [CancelledAt],
                [CancellationReason],
                [VideoRecordingURL],
                [TranscriptFileID],
                [CreatedByPersonID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, NULL) END,
                CASE WHEN @SeriesID_Clear = 1 THEN NULL ELSE ISNULL(@SeriesID, NULL) END,
                CASE WHEN @OccurrenceStartsAt_Clear = 1 THEN NULL ELSE ISNULL(@OccurrenceStartsAt, NULL) END,
                ISNULL(@Status, 'Scheduled'),
                @StartsAt,
                @EndsAt,
                @TimeZone,
                ISNULL(@LocationType, 'Virtual'),
                CASE WHEN @Location_Clear = 1 THEN NULL ELSE ISNULL(@Location, NULL) END,
                CASE WHEN @VideoProviderID_Clear = 1 THEN NULL ELSE ISNULL(@VideoProviderID, NULL) END,
                CASE WHEN @VideoMeetingID_Clear = 1 THEN NULL ELSE ISNULL(@VideoMeetingID, NULL) END,
                CASE WHEN @VideoJoinURL_Clear = 1 THEN NULL ELSE ISNULL(@VideoJoinURL, NULL) END,
                CASE WHEN @DialInDetails_Clear = 1 THEN NULL ELSE ISNULL(@DialInDetails, NULL) END,
                @OrganizerPersonID,
                ISNULL(@Visibility, 'Standard'),
                CASE WHEN @ActualStartedAt_Clear = 1 THEN NULL ELSE ISNULL(@ActualStartedAt, NULL) END,
                CASE WHEN @ActualEndedAt_Clear = 1 THEN NULL ELSE ISNULL(@ActualEndedAt, NULL) END,
                CASE WHEN @CancelledAt_Clear = 1 THEN NULL ELSE ISNULL(@CancelledAt, NULL) END,
                CASE WHEN @CancellationReason_Clear = 1 THEN NULL ELSE ISNULL(@CancellationReason, NULL) END,
                CASE WHEN @VideoRecordingURL_Clear = 1 THEN NULL ELSE ISNULL(@VideoRecordingURL, NULL) END,
                CASE WHEN @TranscriptFileID_Clear = 1 THEN NULL ELSE ISNULL(@TranscriptFileID, NULL) END,
                CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[Meeting]
            (
                [Name],
                [Description],
                [TypeID],
                [SeriesID],
                [OccurrenceStartsAt],
                [Status],
                [StartsAt],
                [EndsAt],
                [TimeZone],
                [LocationType],
                [Location],
                [VideoProviderID],
                [VideoMeetingID],
                [VideoJoinURL],
                [DialInDetails],
                [OrganizerPersonID],
                [Visibility],
                [ActualStartedAt],
                [ActualEndedAt],
                [CancelledAt],
                [CancellationReason],
                [VideoRecordingURL],
                [TranscriptFileID],
                [CreatedByPersonID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, NULL) END,
                CASE WHEN @SeriesID_Clear = 1 THEN NULL ELSE ISNULL(@SeriesID, NULL) END,
                CASE WHEN @OccurrenceStartsAt_Clear = 1 THEN NULL ELSE ISNULL(@OccurrenceStartsAt, NULL) END,
                ISNULL(@Status, 'Scheduled'),
                @StartsAt,
                @EndsAt,
                @TimeZone,
                ISNULL(@LocationType, 'Virtual'),
                CASE WHEN @Location_Clear = 1 THEN NULL ELSE ISNULL(@Location, NULL) END,
                CASE WHEN @VideoProviderID_Clear = 1 THEN NULL ELSE ISNULL(@VideoProviderID, NULL) END,
                CASE WHEN @VideoMeetingID_Clear = 1 THEN NULL ELSE ISNULL(@VideoMeetingID, NULL) END,
                CASE WHEN @VideoJoinURL_Clear = 1 THEN NULL ELSE ISNULL(@VideoJoinURL, NULL) END,
                CASE WHEN @DialInDetails_Clear = 1 THEN NULL ELSE ISNULL(@DialInDetails, NULL) END,
                @OrganizerPersonID,
                ISNULL(@Visibility, 'Standard'),
                CASE WHEN @ActualStartedAt_Clear = 1 THEN NULL ELSE ISNULL(@ActualStartedAt, NULL) END,
                CASE WHEN @ActualEndedAt_Clear = 1 THEN NULL ELSE ISNULL(@ActualEndedAt, NULL) END,
                CASE WHEN @CancelledAt_Clear = 1 THEN NULL ELSE ISNULL(@CancelledAt, NULL) END,
                CASE WHEN @CancellationReason_Clear = 1 THEN NULL ELSE ISNULL(@CancellationReason, NULL) END,
                CASE WHEN @VideoRecordingURL_Clear = 1 THEN NULL ELSE ISNULL(@VideoRecordingURL, NULL) END,
                CASE WHEN @TranscriptFileID_Clear = 1 THEN NULL ELSE ISNULL(@TranscriptFileID, NULL) END,
                CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwMeetings] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeeting] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Meetings */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeeting] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Meetings */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meetings
-- Item: spUpdateMeeting
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Meeting
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateMeeting]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateMeeting];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateMeeting]
    @ID uniqueidentifier,
    @Name nvarchar(255) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @TypeID_Clear bit = 0,
    @TypeID uniqueidentifier = NULL,
    @SeriesID_Clear bit = 0,
    @SeriesID uniqueidentifier = NULL,
    @OccurrenceStartsAt_Clear bit = 0,
    @OccurrenceStartsAt datetimeoffset = NULL,
    @Status nvarchar(20) = NULL,
    @StartsAt datetimeoffset = NULL,
    @EndsAt datetimeoffset = NULL,
    @TimeZone nvarchar(64) = NULL,
    @LocationType nvarchar(20) = NULL,
    @Location_Clear bit = 0,
    @Location nvarchar(500) = NULL,
    @VideoProviderID_Clear bit = 0,
    @VideoProviderID uniqueidentifier = NULL,
    @VideoMeetingID_Clear bit = 0,
    @VideoMeetingID nvarchar(255) = NULL,
    @VideoJoinURL_Clear bit = 0,
    @VideoJoinURL nvarchar(1000) = NULL,
    @DialInDetails_Clear bit = 0,
    @DialInDetails nvarchar(1000) = NULL,
    @OrganizerPersonID uniqueidentifier = NULL,
    @Visibility nvarchar(20) = NULL,
    @ActualStartedAt_Clear bit = 0,
    @ActualStartedAt datetimeoffset = NULL,
    @ActualEndedAt_Clear bit = 0,
    @ActualEndedAt datetimeoffset = NULL,
    @CancelledAt_Clear bit = 0,
    @CancelledAt datetimeoffset = NULL,
    @CancellationReason_Clear bit = 0,
    @CancellationReason nvarchar(500) = NULL,
    @VideoRecordingURL_Clear bit = 0,
    @VideoRecordingURL nvarchar(1000) = NULL,
    @TranscriptFileID_Clear bit = 0,
    @TranscriptFileID uniqueidentifier = NULL,
    @CreatedByPersonID_Clear bit = 0,
    @CreatedByPersonID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[Meeting]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [TypeID] = CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, [TypeID]) END,
        [SeriesID] = CASE WHEN @SeriesID_Clear = 1 THEN NULL ELSE ISNULL(@SeriesID, [SeriesID]) END,
        [OccurrenceStartsAt] = CASE WHEN @OccurrenceStartsAt_Clear = 1 THEN NULL ELSE ISNULL(@OccurrenceStartsAt, [OccurrenceStartsAt]) END,
        [Status] = ISNULL(@Status, [Status]),
        [StartsAt] = ISNULL(@StartsAt, [StartsAt]),
        [EndsAt] = ISNULL(@EndsAt, [EndsAt]),
        [TimeZone] = ISNULL(@TimeZone, [TimeZone]),
        [LocationType] = ISNULL(@LocationType, [LocationType]),
        [Location] = CASE WHEN @Location_Clear = 1 THEN NULL ELSE ISNULL(@Location, [Location]) END,
        [VideoProviderID] = CASE WHEN @VideoProviderID_Clear = 1 THEN NULL ELSE ISNULL(@VideoProviderID, [VideoProviderID]) END,
        [VideoMeetingID] = CASE WHEN @VideoMeetingID_Clear = 1 THEN NULL ELSE ISNULL(@VideoMeetingID, [VideoMeetingID]) END,
        [VideoJoinURL] = CASE WHEN @VideoJoinURL_Clear = 1 THEN NULL ELSE ISNULL(@VideoJoinURL, [VideoJoinURL]) END,
        [DialInDetails] = CASE WHEN @DialInDetails_Clear = 1 THEN NULL ELSE ISNULL(@DialInDetails, [DialInDetails]) END,
        [OrganizerPersonID] = ISNULL(@OrganizerPersonID, [OrganizerPersonID]),
        [Visibility] = ISNULL(@Visibility, [Visibility]),
        [ActualStartedAt] = CASE WHEN @ActualStartedAt_Clear = 1 THEN NULL ELSE ISNULL(@ActualStartedAt, [ActualStartedAt]) END,
        [ActualEndedAt] = CASE WHEN @ActualEndedAt_Clear = 1 THEN NULL ELSE ISNULL(@ActualEndedAt, [ActualEndedAt]) END,
        [CancelledAt] = CASE WHEN @CancelledAt_Clear = 1 THEN NULL ELSE ISNULL(@CancelledAt, [CancelledAt]) END,
        [CancellationReason] = CASE WHEN @CancellationReason_Clear = 1 THEN NULL ELSE ISNULL(@CancellationReason, [CancellationReason]) END,
        [VideoRecordingURL] = CASE WHEN @VideoRecordingURL_Clear = 1 THEN NULL ELSE ISNULL(@VideoRecordingURL, [VideoRecordingURL]) END,
        [TranscriptFileID] = CASE WHEN @TranscriptFileID_Clear = 1 THEN NULL ELSE ISNULL(@TranscriptFileID, [TranscriptFileID]) END,
        [CreatedByPersonID] = CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, [CreatedByPersonID]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwMeetings] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwMeetings]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeeting] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Meeting table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateMeeting]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateMeeting];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateMeeting
ON [${flyway:defaultSchema}].[Meeting]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[Meeting]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[Meeting] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Meetings */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeeting] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Meetings */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meetings
-- Item: spDeleteMeeting
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Meeting
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteMeeting]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteMeeting];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteMeeting]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[Meeting]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeeting] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Meetings */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeeting] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for VideoProvider */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Video Providers
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key CredentialID in table VideoProvider
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_VideoProvider_CredentialID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[VideoProvider]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_VideoProvider_CredentialID ON [${flyway:defaultSchema}].[VideoProvider] ([CredentialID]);

/* SQL text to update entity field related entity name field map for entity field ID 9F2A603F-B1A9-4182-9130-619DEF48E395 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='9F2A603F-B1A9-4182-9130-619DEF48E395', @RelatedEntityNameFieldMap='Credential';

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
    @PredictedSLAScoredAt datetimeoffset = NULL
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
                [PredictedSLAScoredAt]
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
                CASE WHEN @PredictedSLAScoredAt_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLAScoredAt, NULL) END
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
                [PredictedSLAScoredAt]
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
                CASE WHEN @PredictedSLAScoredAt_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLAScoredAt, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTasks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Tasks */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Integration]
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
    @TaskTypeStatusID uniqueidentifier = NULL,
    @PredictedSLABreachProbability_Clear bit = 0,
    @PredictedSLABreachProbability decimal(5, 4) = NULL,
    @PredictedSLARiskBand_Clear bit = 0,
    @PredictedSLARiskBand nvarchar(20) = NULL,
    @PredictedSLAScoredAt_Clear bit = 0,
    @PredictedSLAScoredAt datetimeoffset = NULL
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
        [PredictedSLAScoredAt] = CASE WHEN @PredictedSLAScoredAt_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLAScoredAt, [PredictedSLAScoredAt]) END
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

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_Integration]
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
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Tasks */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for MJ_BizApps_Tasks: Video Providers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Video Providers
-- Item: vwVideoProviders
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Video Providers
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  VideoProvider
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwVideoProviders]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwVideoProviders];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwVideoProviders]
AS
SELECT
    v.*,
    MJCredential_CredentialID.[Name] AS [Credential]
FROM
    [${flyway:defaultSchema}].[VideoProvider] AS v
LEFT OUTER JOIN
    [${mjSchema}].[Credential] AS MJCredential_CredentialID
  ON
    [v].[CredentialID] = MJCredential_CredentialID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwVideoProviders] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Video Providers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Video Providers
-- Item: Permissions for vwVideoProviders
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwVideoProviders] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Video Providers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Video Providers
-- Item: spCreateVideoProvider
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR VideoProvider
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateVideoProvider]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateVideoProvider];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateVideoProvider]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(100),
    @Code nvarchar(50),
    @DriverClass nvarchar(255),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @IconClass_Clear bit = 0,
    @IconClass nvarchar(100) = NULL,
    @CredentialID_Clear bit = 0,
    @CredentialID uniqueidentifier = NULL,
    @Configuration_Clear bit = 0,
    @Configuration nvarchar(MAX) = NULL,
    @SupportsTranscripts bit = NULL,
    @IsDefault bit = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[VideoProvider]
            (
                [ID],
                [Name],
                [Code],
                [DriverClass],
                [Description],
                [IconClass],
                [CredentialID],
                [Configuration],
                [SupportsTranscripts],
                [IsDefault],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                @Code,
                @DriverClass,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, NULL) END,
                CASE WHEN @CredentialID_Clear = 1 THEN NULL ELSE ISNULL(@CredentialID, NULL) END,
                CASE WHEN @Configuration_Clear = 1 THEN NULL ELSE ISNULL(@Configuration, NULL) END,
                ISNULL(@SupportsTranscripts, 0),
                ISNULL(@IsDefault, 0),
                ISNULL(@IsActive, 0)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[VideoProvider]
            (
                [Name],
                [Code],
                [DriverClass],
                [Description],
                [IconClass],
                [CredentialID],
                [Configuration],
                [SupportsTranscripts],
                [IsDefault],
                [IsActive]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                @Code,
                @DriverClass,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, NULL) END,
                CASE WHEN @CredentialID_Clear = 1 THEN NULL ELSE ISNULL(@CredentialID, NULL) END,
                CASE WHEN @Configuration_Clear = 1 THEN NULL ELSE ISNULL(@Configuration, NULL) END,
                ISNULL(@SupportsTranscripts, 0),
                ISNULL(@IsDefault, 0),
                ISNULL(@IsActive, 0)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwVideoProviders] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateVideoProvider] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Video Providers */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateVideoProvider] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Video Providers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Video Providers
-- Item: spUpdateVideoProvider
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR VideoProvider
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateVideoProvider]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateVideoProvider];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateVideoProvider]
    @ID uniqueidentifier,
    @Name nvarchar(100) = NULL,
    @Code nvarchar(50) = NULL,
    @DriverClass nvarchar(255) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @IconClass_Clear bit = 0,
    @IconClass nvarchar(100) = NULL,
    @CredentialID_Clear bit = 0,
    @CredentialID uniqueidentifier = NULL,
    @Configuration_Clear bit = 0,
    @Configuration nvarchar(MAX) = NULL,
    @SupportsTranscripts bit = NULL,
    @IsDefault bit = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[VideoProvider]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [Code] = ISNULL(@Code, [Code]),
        [DriverClass] = ISNULL(@DriverClass, [DriverClass]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [IconClass] = CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, [IconClass]) END,
        [CredentialID] = CASE WHEN @CredentialID_Clear = 1 THEN NULL ELSE ISNULL(@CredentialID, [CredentialID]) END,
        [Configuration] = CASE WHEN @Configuration_Clear = 1 THEN NULL ELSE ISNULL(@Configuration, [Configuration]) END,
        [SupportsTranscripts] = ISNULL(@SupportsTranscripts, [SupportsTranscripts]),
        [IsDefault] = ISNULL(@IsDefault, [IsDefault]),
        [IsActive] = ISNULL(@IsActive, [IsActive])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwVideoProviders] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwVideoProviders]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateVideoProvider] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the VideoProvider table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateVideoProvider]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateVideoProvider];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateVideoProvider
ON [${flyway:defaultSchema}].[VideoProvider]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[VideoProvider]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[VideoProvider] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Video Providers */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateVideoProvider] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Video Providers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Video Providers
-- Item: spDeleteVideoProvider
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR VideoProvider
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteVideoProvider]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteVideoProvider];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteVideoProvider]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[VideoProvider]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteVideoProvider] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Video Providers */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteVideoProvider] TO [cdp_Developer], [cdp_Integration];

/* SQL text to delete unneeded entity fields (10 scoped entities) */
EXEC [${mjSchema}].[spDeleteUnneededEntityFields] @ExcludedSchemaNames='', @EntityIDs='2B15A5D4-9E91-4322-9B82-D58F6E08399E,11DB0B1F-A42F-4DF2-8540-6EB46D7618FB,6751908A-D102-49B0-AE57-A987496CA8E7,7967EB2A-B969-41DC-A71D-0591C1E57353,D0563DA6-BF5B-45EA-93C9-A9678CB303DA,9ECAC4DF-039C-4B96-84D4-0BE2BD481269,83BB5923-29C9-4CBB-94C4-35601DA29DDD,CF246E72-7BC1-4285-8F37-7C8D89E7A23C,69A03D0B-F654-40B6-9B90-94DEC8948AA2,E089FA02-A8AA-485F-A002-870F5C248E38', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to insert 31 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '111e70eb-adea-4b44-9a7b-2942cebdbae6' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = 'DefaultVideoProvider')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '111e70eb-adea-4b44-9a7b-2942cebdbae6',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
            'DefaultVideoProvider',
            'Default Video Provider',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4dd8dc5f-4112-4d6a-8723-81ff93451aec' OR (EntityID = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND Name = 'NotesPrompt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4dd8dc5f-4112-4d6a-8723-81ff93451aec',
            '7967EB2A-B969-41DC-A71D-0591C1E57353', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353'),
            'NotesPrompt',
            'Notes Prompt',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b3691140-fe5e-4372-9701-5de54dd38149' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'Type')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b3691140-fe5e-4372-9701-5de54dd38149',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '30460581-b7b3-4f45-b3aa-a8df8af6c03c' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'OrganizerPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '30460581-b7b3-4f45-b3aa-a8df8af6c03c',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'OrganizerPerson',
            'Organizer Person',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '68692c71-1e3f-4f8e-9264-ab8bf7209f3d' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'VideoProvider')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '68692c71-1e3f-4f8e-9264-ab8bf7209f3d',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            'VideoProvider',
            'Video Provider',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6c4923e2-cef8-4ec4-90b2-ca533c860b2b' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = 'CreatedByPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6c4923e2-cef8-4ec4-90b2-ca533c860b2b',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd2f3fe65-bdfa-4232-b3c2-8e38cefbd8e1' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'Type')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd2f3fe65-bdfa-4232-b3c2-8e38cefbd8e1',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c3a9e1b1-7e40-49cf-8d10-aef72cdb4344' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'Series')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c3a9e1b1-7e40-49cf-8d10-aef72cdb4344',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'Series',
            'Series',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fa403cd1-9327-43f7-ae8c-417d3c0ff599' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'VideoProvider')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'fa403cd1-9327-43f7-ae8c-417d3c0ff599',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'VideoProvider',
            'Video Provider',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '55feeba4-4769-4a20-91bf-43fd17b0b2ac' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'OrganizerPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '55feeba4-4769-4a20-91bf-43fd17b0b2ac',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'OrganizerPerson',
            'Organizer Person',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '49f6b04d-c761-4c1e-96a8-b789cc519978' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'TranscriptFile')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '49f6b04d-c761-4c1e-96a8-b789cc519978',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            'TranscriptFile',
            'Transcript File',
            NULL,
            'nvarchar',
            1000,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3dd708be-f881-4079-b933-caaeeba08697' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = 'CreatedByPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3dd708be-f881-4079-b933-caaeeba08697',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '919cfde4-6644-4a08-88ff-cce5707d015e' OR (EntityID = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB' AND Name = 'Meeting')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '919cfde4-6644-4a08-88ff-cce5707d015e',
            '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB'),
            'Meeting',
            'Meeting',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '48758129-505e-4743-bdd8-c5811743a696' OR (EntityID = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB' AND Name = 'Series')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '48758129-505e-4743-bdd8-c5811743a696',
            '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB'),
            'Series',
            'Series',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ff2e0325-d7c9-4054-a2e5-3c2fe067d805' OR (EntityID = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB' AND Name = 'Entity')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ff2e0325-d7c9-4054-a2e5-3c2fe067d805',
            '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5442675f-67ea-46cc-a2c7-677b872b3ad4' OR (EntityID = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C' AND Name = 'Series')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5442675f-67ea-46cc-a2c7-677b872b3ad4',
            'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C'),
            'Series',
            'Series',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f9a38c5f-54bc-4cd8-a195-fa0c6fd71316' OR (EntityID = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C' AND Name = 'Person')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f9a38c5f-54bc-4cd8-a195-fa0c6fd71316',
            'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4e093f61-4a97-465b-a20d-1af0fd39a83a' OR (EntityID = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C' AND Name = 'User')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4e093f61-4a97-465b-a20d-1af0fd39a83a',
            'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C'),
            'User',
            'User',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c40f476f-b076-488d-9076-87039141d754' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'Meeting')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c40f476f-b076-488d-9076-87039141d754',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'Meeting',
            'Meeting',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a9bb34e3-94a8-4dcb-bb7e-c875168a71e2' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'Parent')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a9bb34e3-94a8-4dcb-bb7e-c875168a71e2',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'Parent',
            'Parent',
            NULL,
            'nvarchar',
            1000,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4e519cf0-2341-4f1c-9e33-9e88b91a2ce1' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'Type')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4e519cf0-2341-4f1c-9e33-9e88b91a2ce1',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7d2052e4-3992-4675-a287-9acf99650f5d' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'PresenterPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7d2052e4-3992-4675-a287-9acf99650f5d',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'PresenterPerson',
            'Presenter Person',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '552bb884-1deb-46fc-8790-d61451530551' OR (EntityID = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND Name = 'DeferredToMeeting')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '552bb884-1deb-46fc-8790-d61451530551',
            'E089FA02-A8AA-485F-A002-870F5C248E38', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38'),
            'DeferredToMeeting',
            'Deferred To Meeting',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '74614ba2-d550-4a56-84b0-b81594f2dc7e' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'Meeting')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '74614ba2-d550-4a56-84b0-b81594f2dc7e',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
            'Meeting',
            'Meeting',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '76bd8fbe-3a2b-4ba9-a200-3a76f24f3505' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'Person')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '76bd8fbe-3a2b-4ba9-a200-3a76f24f3505',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b0a5e3c4-0b7a-4a5c-b5b0-959b30502cde' OR (EntityID = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND Name = 'User')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b0a5e3c4-0b7a-4a5c-b5b0-959b30502cde',
            '69A03D0B-F654-40B6-9B90-94DEC8948AA2', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2'),
            'User',
            'User',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5a47c067-0e9a-42bf-ae22-496da527adb2' OR (EntityID = '6751908A-D102-49B0-AE57-A987496CA8E7' AND Name = 'Credential')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5a47c067-0e9a-42bf-ae22-496da527adb2',
            '6751908A-D102-49B0-AE57-A987496CA8E7', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7'),
            'Credential',
            'Credential',
            NULL,
            'nvarchar',
            400,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c732e45b-d1b2-4072-baca-fb65eb28931e' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = 'Meeting')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c732e45b-d1b2-4072-baca-fb65eb28931e',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
            'Meeting',
            'Meeting',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8e6334af-aa90-436b-8ccc-f8e248fc838e' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = 'AgendaItem')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8e6334af-aa90-436b-8ccc-f8e248fc838e',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
            'AgendaItem',
            'Agenda Item',
            NULL,
            'nvarchar',
            1000,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2fcb433d-8be6-4c94-b9d9-f90c61990dbb' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = 'AuthorPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2fcb433d-8be6-4c94-b9d9-f90c61990dbb',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
            'AuthorPerson',
            'Author Person',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e3f875f5-b1c6-4a3d-8ea5-e19c5d2922bf' OR (EntityID = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND Name = 'AIPromptRun')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e3f875f5-b1c6-4a3d-8ea5-e19c5d2922bf',
            '2B15A5D4-9E91-4322-9B82-D58F6E08399E', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E'),
            'AIPromptRun',
            'AI Prompt Run',
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

/* SQL text to update existing entity fields from schema (10 scoped entities) */
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='', @EntityIDs='2B15A5D4-9E91-4322-9B82-D58F6E08399E,11DB0B1F-A42F-4DF2-8540-6EB46D7618FB,6751908A-D102-49B0-AE57-A987496CA8E7,7967EB2A-B969-41DC-A71D-0591C1E57353,D0563DA6-BF5B-45EA-93C9-A9678CB303DA,9ECAC4DF-039C-4B96-84D4-0BE2BD481269,83BB5923-29C9-4CBB-94C4-35601DA29DDD,CF246E72-7BC1-4285-8F37-7C8D89E7A23C,69A03D0B-F654-40B6-9B90-94DEC8948AA2,E089FA02-A8AA-485F-A002-870F5C248E38', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'DD7FDE48-5804-4E6E-8A03-771E8D84A263'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '64493942-192E-41A9-9BF8-2AFD2F2A5CAF'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '4E519CF0-2341-4F1C-9E33-9E88B91A2CE1'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '7D2052E4-3992-4675-A287-9ACF99650F5D'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'A3AC7C01-DEED-48F8-B2F5-1141F51AEE79'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '13910370-F103-4F3B-BBE5-25E7616C4E1E'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '4702BA09-F341-4F12-A270-755E1510F51A'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '445F98CD-8E8A-48E8-B670-DEE27D496E01'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '1D9F6670-8EBD-4E35-ACA7-E9B69BA9AC93'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'C732E45B-D1B2-4072-BACA-FB65EB28931E'
               AND AutoUpdateDefaultInView = 1;

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '2DCCE0C0-75AC-478A-B5DD-B4A270A58A5F'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '5720194C-2814-4A4E-A0CF-9705CB888096'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '919CFDE4-6644-4A08-88FF-CCE5707D015E'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '48758129-505E-4743-BDD8-C5811743A696'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'FF2E0325-D7C9-4054-A2E5-3C2FE067D805'
               AND AutoUpdateDefaultInView = 1;

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '9BE359F0-AAE2-4025-A535-769B6334BA4A'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'B085037A-CA6F-4C44-8229-6E963D7605CF'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'D668212F-AE18-450F-AB81-7FDCF765E33A'
               AND AutoUpdateDefaultInView = 1;

            UPDATE [${mjSchema}].[Entity]
            SET AllowUserSearchAPI = 0
            WHERE ID = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA'
            AND AutoUpdateAllowUserSearchAPI = 1;

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '606E05D2-D64C-4AFD-AF99-56F086A056BF'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '606E05D2-D64C-4AFD-AF99-56F086A056BF'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '749719DB-782C-4CF1-9ABB-FB4800CF01F0'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'E278C1AE-95E7-4164-987F-D8B22BB9A181'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'AE7AD788-2D1E-4646-8FC1-7A27E0DF0DBE'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '74614BA2-D550-4A56-84B0-B81594F2DC7E'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '57E09A60-2352-4A10-8D3B-65E28B18B029'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = '57E09A60-2352-4A10-8D3B-65E28B18B029'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set categories for 10 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Links.MeetingID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Association',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '7EA119CE-FFCC-44B5-A0EF-A6B6DCD23DEE';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Links.SeriesID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Association',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'A9DB3840-F16F-4423-963F-43CE244A05BB';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Links.Meeting 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Association',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '919CFDE4-6644-4A08-88FF-CCE5707D015E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Links.Series 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Association',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '48758129-505E-4743-BDD8-C5811743A696';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Links.EntityID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Target Record',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '656110DF-C022-4769-90CE-94F1E84F1D07';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Links.RecordID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Target Record',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '2DCCE0C0-75AC-478A-B5DD-B4A270A58A5F';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Links.Entity 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Target Record',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'FF2E0325-D7C9-4054-A2E5-3C2FE067D805';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Links.Description 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Target Record',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '5720194C-2814-4A4E-A0CF-9705CB888096';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Links.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '172E8690-A6B4-4E87-94CA-AB6687743B57';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Links.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '4913D9C0-2FD6-4CDB-B281-8E31A92686B7';

/* Set entity icon to fa fa-link */

               UPDATE [${mjSchema}].[Entity]
               SET [Icon] = 'fa fa-link', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB';

/* Insert FieldCategoryInfo setting for entity */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB' AND [Name] = 'FieldCategoryInfo'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('b0341ce8-113e-5852-a4a5-a91ed0a77ff8', '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', 'FieldCategoryInfo', '{
  "Meeting Association": {
    "description": "Details connecting the link to a specific meeting or series",
    "icon": "fa fa-calendar-alt"
  },
  "System Metadata": {
    "description": "System-managed audit and tracking fields",
    "icon": "fa fa-cog"
  },
  "Target Record": {
    "description": "Information about the business record the meeting is tied to",
    "icon": "fa fa-bullseye"
  }
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Insert FieldCategoryIcons setting (legacy) */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB' AND [Name] = 'FieldCategoryIcons'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('664ffb7d-66e3-5ecc-919a-1169f70a75d6', '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB', 'FieldCategoryIcons', '{
  "Meeting Association": "fa fa-calendar-alt",
  "System Metadata": "fa fa-cog",
  "Target Record": "fa fa-bullseye"
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Set DefaultForNewUser=false for NEW entity (category: junction, confidence: high) */

         UPDATE [${mjSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 0, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB';

/* Set categories for 10 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Item Types.ID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '1814CB17-E4B3-430E-A3CB-D733F5B78C01';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Item Types.Name 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Item Type Configuration',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '01FC2078-15BA-4001-A850-5CA9BEE325D7';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Item Types.Code 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Item Type Configuration',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '10031C74-F48C-47DC-A0A3-65545C152395';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Item Types.Description 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Item Type Configuration',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'DBD50C35-BA15-45EC-A61F-C84E44075994';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Item Types.IconClass 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Display and Behavior',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Icon'
WHERE 
   ID = 'FA2AACE2-C3F7-4C7C-8DAE-2103AE71831B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Item Types.DefaultDurationMinutes 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Display and Behavior',
   GeneratedFormSection = 'Category',
   DisplayName = 'Default Duration (Minutes)'
WHERE 
   ID = '9BE359F0-AAE2-4025-A535-769B6334BA4A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Item Types.IsActive 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Display and Behavior',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'B085037A-CA6F-4C44-8229-6E963D7605CF';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Item Types.Sequence 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Display and Behavior',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'D668212F-AE18-450F-AB81-7FDCF765E33A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Item Types.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'C1F77741-ABCB-4DE1-9D4B-32B14093D84F';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Item Types.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '02BAA432-D3F4-480A-8242-1520DB7BC94B';

/* Set entity icon to fa fa-tasks */

               UPDATE [${mjSchema}].[Entity]
               SET [Icon] = 'fa fa-tasks', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA';

/* Insert FieldCategoryInfo setting for entity */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA' AND [Name] = 'FieldCategoryInfo'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('8e5fa8ff-3e20-5b4d-841e-4ad7d78be50d', 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA', 'FieldCategoryInfo', '{
  "Display and Behavior": {
    "description": "Visual styling, duration defaults, sequence, and active status options",
    "icon": "fa fa-sliders-h"
  },
  "Item Type Configuration": {
    "description": "Core identifying details such as name, stable code, and description",
    "icon": "fa fa-tag"
  },
  "System Metadata": {
    "description": "System-managed audit and tracking fields",
    "icon": "fa fa-cog"
  }
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Insert FieldCategoryIcons setting (legacy) */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA' AND [Name] = 'FieldCategoryIcons'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('b3496d0e-6583-5e53-a5e5-d21953c1063b', 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA', 'FieldCategoryIcons', '{
  "Display and Behavior": "fa fa-sliders-h",
  "Item Type Configuration": "fa fa-tag",
  "System Metadata": "fa fa-cog"
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Set DefaultForNewUser=false for NEW entity (category: reference, confidence: high) */

         UPDATE [${mjSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 0, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = 'D0563DA6-BF5B-45EA-93C9-A9678CB303DA';

/* Set categories for 17 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.ID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'DBCC482B-A963-4DA8-8AFE-7CF95F1585A7';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.MeetingID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Context',
   GeneratedFormSection = 'Category',
   DisplayName = 'Meeting'
WHERE 
   ID = 'CAAACDCE-963A-43EE-BA6A-BA137657141D';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.AgendaItemID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Context',
   GeneratedFormSection = 'Category',
   DisplayName = 'Agenda Item'
WHERE 
   ID = '7C0572F4-3BFD-436D-A687-5236F735FB85';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.Kind 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Note Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'D786BD21-BFEE-4CAA-95AD-EDD105705F13';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.Title 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Note Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '13910370-F103-4F3B-BBE5-25E7616C4E1E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.Body 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Note Details',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Markdown'
WHERE 
   ID = '3DD9B702-06F2-45C2-B4F0-E09D9CFDB5DD';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.Source 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Note Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '4702BA09-F341-4F12-A270-755E1510F51A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.Status 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Note Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '445F98CD-8E8A-48E8-B670-DEE27D496E01';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.AuthorPersonID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Authorship and Origin',
   GeneratedFormSection = 'Category',
   DisplayName = 'Author Person'
WHERE 
   ID = '50F0F9AD-3E5F-44CE-B52C-204119F86006';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.AIPromptRunID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Authorship and Origin',
   GeneratedFormSection = 'Category',
   DisplayName = 'AI Prompt Run'
WHERE 
   ID = '83550206-C6A8-41AB-99A6-05C5E38EB795';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.ProposedTasks 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Action Items and Tasks',
   GeneratedFormSection = 'Category',
   ExtendedType = 'JSON'
WHERE 
   ID = 'A9B69100-0260-40A1-AAB2-3DFC86FEB88C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '1D9F6670-8EBD-4E35-ACA7-E9B69BA9AC93';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '99BECE8B-036A-455C-B804-6B960290CF28';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.Meeting 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Context',
   GeneratedFormSection = 'Category',
   DisplayName = 'Meeting Name'
WHERE 
   ID = 'C732E45B-D1B2-4072-BACA-FB65EB28931E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.AgendaItem 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Context',
   GeneratedFormSection = 'Category',
   DisplayName = 'Agenda Item Name'
WHERE 
   ID = '8E6334AF-AA90-436B-8CCC-F8E248FC838E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.AuthorPerson 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Authorship and Origin',
   GeneratedFormSection = 'Category',
   DisplayName = 'Author Person Name'
WHERE 
   ID = '2FCB433D-8BE6-4C94-B9D9-F90C61990DBB';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Notes.AIPromptRun 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Authorship and Origin',
   GeneratedFormSection = 'Category',
   DisplayName = 'AI Prompt Run Details'
WHERE 
   ID = 'E3F875F5-B1C6-4A3D-8EA5-E19C5D2922BF';

/* Set entity icon to fa fa-file-alt */

               UPDATE [${mjSchema}].[Entity]
               SET [Icon] = 'fa fa-file-alt', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E';

/* Insert FieldCategoryInfo setting for entity */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND [Name] = 'FieldCategoryInfo'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('113b6baf-a842-58dc-8452-40c7e4238a1e', '2B15A5D4-9E91-4322-9B82-D58F6E08399E', 'FieldCategoryInfo', '{
  "Action Items and Tasks": {
    "description": "Proposed tasks and action items derived from the meeting note",
    "icon": "fa fa-tasks"
  },
  "Authorship and Origin": {
    "description": "Information regarding who authored the note or which AI process generated it",
    "icon": "fa fa-user-edit"
  },
  "Meeting Context": {
    "description": "Links and references connecting the note to meetings and agenda items",
    "icon": "fa fa-calendar"
  },
  "Note Details": {
    "description": "Core content, categorization, source, and status of the meeting note",
    "icon": "fa fa-file-alt"
  }
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Insert FieldCategoryIcons setting (legacy) */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E' AND [Name] = 'FieldCategoryIcons'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('5307fdf3-6a07-57d3-bd48-0ef68a518648', '2B15A5D4-9E91-4322-9B82-D58F6E08399E', 'FieldCategoryIcons', '{
  "Action Items and Tasks": "fa fa-tasks",
  "Authorship and Origin": "fa fa-user-edit",
  "Meeting Context": "fa fa-calendar",
  "Note Details": "fa fa-file-alt"
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Set DefaultForNewUser=true for NEW entity (category: supporting, confidence: high) */

         UPDATE [${mjSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '2B15A5D4-9E91-4322-9B82-D58F6E08399E';

/* Set categories for 18 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.ID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'A8A3696D-82D1-44CE-AEDB-A4446298A72F';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.MeetingID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting and Attendee Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Meeting'
WHERE 
   ID = '515575E9-A142-44B1-BD41-0EEDD98902B2';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.PersonID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Attendee Information',
   GeneratedFormSection = 'Category',
   DisplayName = 'Person'
WHERE 
   ID = 'DB6F2CA4-E7C9-48C6-A128-525A9CF1588A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.UserID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Attendee Information',
   GeneratedFormSection = 'Category',
   DisplayName = 'User'
WHERE 
   ID = 'DF1645D3-F3DB-410D-8CBC-87CF854DBA10';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.Email 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Attendee Information',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Email'
WHERE 
   ID = '57E09A60-2352-4A10-8D3B-65E28B18B029';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.DisplayName 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Attendee Information',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '606E05D2-D64C-4AFD-AF99-56F086A056BF';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.Role 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting and Attendee Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '749719DB-782C-4CF1-9ABB-FB4800CF01F0';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.ResponseStatus 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Response and Attendance',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'E278C1AE-95E7-4164-987F-D8B22BB9A181';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.RespondedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Response and Attendance',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '65F3D11D-DE58-4F99-816D-2F72D9681A04';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.AttendanceStatus 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Response and Attendance',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'AE7AD788-2D1E-4646-8FC1-7A27E0DF0DBE';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.JoinedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Response and Attendance',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'C82C54E3-77A2-476A-A8B0-0E7A87D34BEF';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.LeftAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Response and Attendance',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '326F4F7C-BC3F-4B28-9F30-C9B4C87433A9';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.Notes 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting and Attendee Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'D9253965-0EB8-494F-93AA-76CFB1775F3E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'DCD4B220-20B9-420C-8847-933A27166887';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'C06F2D50-8139-4853-BB6A-576B67DA623E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.Meeting 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting and Attendee Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '74614BA2-D550-4A56-84B0-B81594F2DC7E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.Person 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Attendee Information',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '76BD8FBE-3A2B-4BA9-A200-3A76F24F3505';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Attendees.User 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Attendee Information',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'B0A5E3C4-0B7A-4A5C-B5B0-959B30502CDE';

/* Set categories for 21 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.ID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'AD995BFF-B1B6-4A09-9B36-0F26D3EBAC8B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.MeetingID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Context',
   GeneratedFormSection = 'Category',
   DisplayName = 'Meeting'
WHERE 
   ID = '92B77569-07D4-437B-98A4-B5D16DFEC3E7';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.Meeting 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Context',
   GeneratedFormSection = 'Category',
   DisplayName = 'Meeting Name'
WHERE 
   ID = 'C40F476F-B076-488D-9076-87039141D754';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.ParentID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Hierarchy and Ordering',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parent Item'
WHERE 
   ID = 'F522109A-03C2-445A-9295-01294B0EABF3';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.Parent 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Hierarchy and Ordering',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parent Name'
WHERE 
   ID = 'A9BB34E3-94A8-4DCB-BB7E-C875168A71E2';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.Sequence 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Hierarchy and Ordering',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '24AC79E7-A97B-4F3F-B8E8-9FA09FE9194B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.Name 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Agenda Item Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'A3AC7C01-DEED-48F8-B2F5-1141F51AEE79';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.Description 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Agenda Item Details',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Markdown'
WHERE 
   ID = '045B1181-019C-42D3-8111-10D6DC14FDF1';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.TypeID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Agenda Item Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Type'
WHERE 
   ID = '223DB792-C426-4A68-9600-C8F1B3368DD9';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.Type 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Agenda Item Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Type Name'
WHERE 
   ID = '4E519CF0-2341-4F1C-9E33-9E88B91A2CE1';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.PresenterPersonID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Presenter and Timing',
   GeneratedFormSection = 'Category',
   DisplayName = 'Presenter'
WHERE 
   ID = 'D7067566-F10A-4864-BC47-E54E02C88BD0';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.PresenterPerson 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Presenter and Timing',
   GeneratedFormSection = 'Category',
   DisplayName = 'Presenter Name'
WHERE 
   ID = '7D2052E4-3992-4675-A287-9ACF99650F5D';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.DurationMinutes 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Presenter and Timing',
   GeneratedFormSection = 'Category',
   DisplayName = 'Duration (Minutes)'
WHERE 
   ID = 'DD7FDE48-5804-4E6E-8A03-771E8D84A263';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.Status 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Execution and Outcome',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '64493942-192E-41A9-9BF8-2AFD2F2A5CAF';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.StartedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Execution and Outcome',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'DCF05D2A-9FE6-4A3C-92DC-9BA6E32ECF5D';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.EndedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Execution and Outcome',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'AD430FC5-D2C1-4E7F-A847-4E1461BD3113';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.Outcome 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Execution and Outcome',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'E3F9F26E-2BF5-4AC9-AF03-882BB1C2CE3C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.DeferredToMeetingID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Execution and Outcome',
   GeneratedFormSection = 'Category',
   DisplayName = 'Deferred To Meeting'
WHERE 
   ID = '89F24E04-00B7-410C-A6FC-8EC39550E3F1';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.DeferredToMeeting 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Execution and Outcome',
   GeneratedFormSection = 'Category',
   DisplayName = 'Deferred To Meeting Name'
WHERE 
   ID = '552BB884-1DEB-46FC-8790-D61451530551';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'AA78C968-ACA2-4F0B-97FC-8AEA8714C9F3';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Agenda Items.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '87266BD0-CBFF-43B8-9D05-159472A480C0';

/* Set entity icon to fa fa-users */

               UPDATE [${mjSchema}].[Entity]
               SET [Icon] = 'fa fa-users', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2';

/* Insert FieldCategoryInfo setting for entity */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND [Name] = 'FieldCategoryInfo'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('2ab11e00-416b-5232-9326-179ddc559d90', '69A03D0B-F654-40B6-9B90-94DEC8948AA2', 'FieldCategoryInfo', '{
  "Attendee Information": {
    "description": "Details identifying the person or guest invited to the meeting",
    "icon": "fa fa-id-card"
  },
  "Meeting and Attendee Details": {
    "description": "Core meeting association, roles, and related notes",
    "icon": "fa fa-briefcase"
  },
  "Response and Attendance": {
    "description": "Invitation response status and actual meeting attendance timeline",
    "icon": "fa fa-clock"
  }
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Insert FieldCategoryIcons setting (legacy) */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND [Name] = 'FieldCategoryIcons'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('8529382e-31cd-57a0-a605-3bb4f0f84bc6', '69A03D0B-F654-40B6-9B90-94DEC8948AA2', 'FieldCategoryIcons', '{
  "Attendee Information": "fa fa-id-card",
  "Meeting and Attendee Details": "fa fa-briefcase",
  "Response and Attendance": "fa fa-clock"
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Set entity icon to fa fa-tasks */

               UPDATE [${mjSchema}].[Entity]
               SET [Icon] = 'fa fa-tasks', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = 'E089FA02-A8AA-485F-A002-870F5C248E38';

/* Set DefaultForNewUser=true for NEW entity (category: supporting, confidence: high) */

         UPDATE [${mjSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2';

/* Insert FieldCategoryInfo setting for entity */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND [Name] = 'FieldCategoryInfo'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('c2fe4cdc-5d90-5ae0-b99e-77db7203af4d', 'E089FA02-A8AA-485F-A002-870F5C248E38', 'FieldCategoryInfo', '{
  "Agenda Item Details": {
    "description": "Core descriptive content, title, and type categorization of the agenda item",
    "icon": "fa fa-file-alt"
  },
  "Hierarchy and Ordering": {
    "description": "Nesting relationships and sequence ordering among agenda items",
    "icon": "fa fa-sitemap"
  },
  "Meeting Context": {
    "description": "Association and context linking the agenda item to its parent meeting",
    "icon": "fa fa-calendar-alt"
  },
  "Meeting Execution and Outcome": {
    "description": "Live meeting execution progress, timing timestamps, outcomes, and deferrals",
    "icon": "fa fa-check-square"
  },
  "Presenter and Timing": {
    "description": "Assignment of presenters and planned duration for the item",
    "icon": "fa fa-clock"
  },
  "System Metadata": {
    "description": "System-managed audit and tracking fields",
    "icon": "fa fa-cog"
  }
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Insert FieldCategoryIcons setting (legacy) */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38' AND [Name] = 'FieldCategoryIcons'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('de526cf8-2cce-5161-9525-06455d9fb70b', 'E089FA02-A8AA-485F-A002-870F5C248E38', 'FieldCategoryIcons', '{
  "Agenda Item Details": "fa fa-file-alt",
  "Hierarchy and Ordering": "fa fa-sitemap",
  "Meeting Context": "fa fa-calendar-alt",
  "Meeting Execution and Outcome": "fa fa-check-square",
  "Presenter and Timing": "fa fa-clock",
  "System Metadata": "fa fa-cog"
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${mjSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = 'E089FA02-A8AA-485F-A002-870F5C248E38';

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '6F7B4CC5-710F-423B-8ED7-AFEAC06D182B'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '591E2257-54A4-4F57-8C9B-41FF28F9CF71'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '4A0E0628-05DD-4C43-AD71-105246ECA628'
               AND AutoUpdateDefaultInView = 1;

            UPDATE [${mjSchema}].[Entity]
            SET AllowUserSearchAPI = 0
            WHERE ID = '6751908A-D102-49B0-AE57-A987496CA8E7'
            AND AutoUpdateAllowUserSearchAPI = 1;

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '6DAECF3E-748C-4B51-9B42-8F095D513A6E'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'E92CD564-063F-4B1D-AFC2-66FFD2F6F4F9'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'F0BE87EB-6629-4B07-A288-84B373C44102'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '222FC8E1-118E-47AE-8D44-140185534EE4'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '30460581-B7B3-4F45-B3AA-A8DF8AF6C03C'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '8004B7D1-BF55-44CA-8990-91B93343E162'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '8506E396-CCF3-4F7F-ADEC-9113641A1759'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '8310B0AF-B0A7-4C4A-AF2B-C13D77FFA2B7'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '6ABC9840-AB83-4C42-9FD7-F1C9E5E33C66'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'C1451E38-09D5-41DA-9373-A62BBC5071CF'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '55FEEBA4-4769-4A20-91BF-43FD17B0B2AC'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'C1873111-DEA8-40F5-9CB5-18638762B2CD'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '3EBCD61D-E7D2-4929-9AAF-586DF17855C0'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '14777148-7099-4A9E-90EE-171E1C3A246B'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'C1873111-DEA8-40F5-9CB5-18638762B2CD'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '3EBCD61D-E7D2-4929-9AAF-586DF17855C0'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '7A740A83-A5EA-47AD-977F-9B1A12A78C24'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '7A740A83-A5EA-47AD-977F-9B1A12A78C24'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '403AB65C-C56D-4514-987B-E26BAB64226E'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '5442675F-67EA-46CC-A2C7-677B872B3AD4'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'F9A38C5F-54BC-4CD8-A195-FA0C6FD71316'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '4E093F61-4A97-465B-A20D-1AF0FD39A83A'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '81CAD5E0-0C8A-43C6-895A-E71628607CED'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = '81CAD5E0-0C8A-43C6-895A-E71628607CED'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'ADB2BAD7-156C-4856-BEF9-F2C8D8D60F64'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '644BD683-920D-4B14-8CD3-691E46292DC7'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '6482E23F-94AB-4692-8B9A-E79BA373206E'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'CADEDC29-CADA-46A0-9E68-CAF777A2F1A8'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'F1993BB9-DAAE-44A8-A462-2CD4D842BCE7'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '54665294-5FFD-42E1-8E16-0C13C2D897E6'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${mjSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = 'F1993BB9-DAAE-44A8-A462-2CD4D842BCE7'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set categories for 12 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series Attendees.ID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'EAC49ADB-FDC6-40BF-85C1-2555546D627B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series Attendees.SeriesID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Attendee Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '55594095-477D-4DBF-A456-F2EA486E2FB4';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series Attendees.PersonID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Attendee Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Person'
WHERE 
   ID = '0D65FAEA-E5D9-4DA7-83F1-2EE1EFC53557';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series Attendees.UserID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Attendee Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'User'
WHERE 
   ID = '69CF2484-E8E5-4A9E-BEBC-E2AE15755866';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series Attendees.Email 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Contact Information',
   GeneratedFormSection = 'Category',
   DisplayName = 'Email Address',
   ExtendedType = 'Email'
WHERE 
   ID = '81CAD5E0-0C8A-43C6-895A-E71628607CED';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series Attendees.DisplayName 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Contact Information',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '7A740A83-A5EA-47AD-977F-9B1A12A78C24';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series Attendees.Role 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Attendee Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '403AB65C-C56D-4514-987B-E26BAB64226E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series Attendees.Series 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Attendee Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '5442675F-67EA-46CC-A2C7-677B872B3AD4';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series Attendees.Person 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Attendee Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Person Name'
WHERE 
   ID = 'F9A38C5F-54BC-4CD8-A195-FA0C6FD71316';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series Attendees.User 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Attendee Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'User Name'
WHERE 
   ID = '4E093F61-4A97-465B-A20D-1AF0FD39A83A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series Attendees.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '37AA822A-7BEE-4616-9905-5A2DC154739D';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series Attendees.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'F0E2048E-4138-4832-AEF6-CB67B3D0F79E';

/* Set entity icon to fa fa-users */

               UPDATE [${mjSchema}].[Entity]
               SET [Icon] = 'fa fa-users', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C';

/* Insert FieldCategoryInfo setting for entity */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C' AND [Name] = 'FieldCategoryInfo'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('2e0258a2-8019-58d3-ab9f-bd0d8eb41c37', 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', 'FieldCategoryInfo', '{
  "Attendee Details": {
    "description": "Core information linking series, persons, users, and roles for meeting attendees",
    "icon": "fa fa-user-friends"
  },
  "Contact Information": {
    "description": "Email address and display name for meeting invitations",
    "icon": "fa fa-address-card"
  },
  "System Metadata": {
    "description": "System-managed audit and tracking fields",
    "icon": "fa fa-cog"
  }
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Insert FieldCategoryIcons setting (legacy) */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C' AND [Name] = 'FieldCategoryIcons'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('ad2674e4-36b9-5b5e-b4df-6f09d64833cb', 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C', 'FieldCategoryIcons', '{
  "Attendee Details": "fa fa-user-friends",
  "Contact Information": "fa fa-address-card",
  "System Metadata": "fa fa-cog"
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Set DefaultForNewUser=true for NEW entity (category: supporting, confidence: high) */

         UPDATE [${mjSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C';

/* Set categories for 14 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Video Providers.ID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'F87CD02A-B040-429A-B15F-2AFBAF868306';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Video Providers.Name 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Provider Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '50EBDC4E-5757-4A55-96A5-90A99D11509C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Video Providers.Code 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Provider Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '3ECECBA5-E49A-49B8-8098-9270B9F8F40E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Video Providers.DriverClass 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Provider Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'F0256582-A104-4A75-B9DD-41E41399D208';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Video Providers.Description 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Provider Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'F2A4081A-90D4-4EC3-ABDB-2B2937A1C528';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Video Providers.IconClass 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Provider Details',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Icon'
WHERE 
   ID = 'DFC6CF9A-C7F0-4DFF-8365-1D932FB51248';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Video Providers.CredentialID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Configuration and Secrets',
   GeneratedFormSection = 'Category',
   DisplayName = 'Credential'
WHERE 
   ID = '9F2A603F-B1A9-4182-9130-619DEF48E395';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Video Providers.Configuration 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Configuration and Secrets',
   GeneratedFormSection = 'Category',
   ExtendedType = 'JSON'
WHERE 
   ID = '633CAA06-B6C0-4F3C-843F-305DAF1359F8';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Video Providers.SupportsTranscripts 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Capabilities and Status',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '6F7B4CC5-710F-423B-8ED7-AFEAC06D182B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Video Providers.IsDefault 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Capabilities and Status',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '591E2257-54A4-4F57-8C9B-41FF28F9CF71';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Video Providers.IsActive 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Capabilities and Status',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '4A0E0628-05DD-4C43-AD71-105246ECA628';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Video Providers.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '20E51B94-EFD8-48A6-AD03-7F9825EF72E0';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Video Providers.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '83EE1FA7-04BF-4FFC-9603-EDC5377AD9EB';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Video Providers.Credential 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Configuration and Secrets',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '5A47C067-0E9A-42BF-AE22-496DA527ADB2';

/* Set entity icon to fa fa-video */

               UPDATE [${mjSchema}].[Entity]
               SET [Icon] = 'fa fa-video', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '6751908A-D102-49B0-AE57-A987496CA8E7';

/* Insert FieldCategoryInfo setting for entity */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7' AND [Name] = 'FieldCategoryInfo'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('9318c370-7860-5c4e-bfb0-7c9872ad7633', '6751908A-D102-49B0-AE57-A987496CA8E7', 'FieldCategoryInfo', '{
  "Capabilities and Status": {
    "description": "Provider capabilities, default status, and active state",
    "icon": "fa fa-sliders-h"
  },
  "Configuration and Secrets": {
    "description": "Credential references and non-secret JSON settings",
    "icon": "fa fa-key"
  },
  "Provider Details": {
    "description": "General identification and display attributes for the video provider",
    "icon": "fa fa-info-circle"
  },
  "System Metadata": {
    "description": "System-managed audit and tracking fields",
    "icon": "fa fa-cog"
  }
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Insert FieldCategoryIcons setting (legacy) */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7' AND [Name] = 'FieldCategoryIcons'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('9ed4f37d-48f2-54bd-b3bb-81691be60c6d', '6751908A-D102-49B0-AE57-A987496CA8E7', 'FieldCategoryIcons', '{
  "Capabilities and Status": "fa fa-sliders-h",
  "Configuration and Secrets": "fa fa-key",
  "Provider Details": "fa fa-info-circle",
  "System Metadata": "fa fa-cog"
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Set DefaultForNewUser=false for NEW entity (category: reference, confidence: high) */

         UPDATE [${mjSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 0, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '6751908A-D102-49B0-AE57-A987496CA8E7';

/* Set categories for 17 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.ID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'C1C3311B-42F2-46BC-9CC2-1D6FBFD94C91';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.Name 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Type Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '54665294-5FFD-42E1-8E16-0C13C2D897E6';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.Code 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Type Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'F1993BB9-DAAE-44A8-A462-2CD4D842BCE7';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.Description 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Type Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '517DA901-866B-4333-87BD-C5CA81309BA2';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.IconClass 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Type Details',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Icon'
WHERE 
   ID = 'CB3249C3-3FF5-410E-95DC-09F4BFA10D1A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.Sequence 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Type Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'CADEDC29-CADA-46A0-9E68-CAF777A2F1A8';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.IsActive 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Type Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Active'
WHERE 
   ID = '6482E23F-94AB-4692-8B9A-E79BA373206E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.DefaultDurationMinutes 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Default Meeting Settings',
   GeneratedFormSection = 'Category',
   DisplayName = 'Default Duration (Minutes)'
WHERE 
   ID = 'ADB2BAD7-156C-4856-BEF9-F2C8D8D60F64';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.DefaultLocationType 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Default Meeting Settings',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '644BD683-920D-4B14-8CD3-691E46292DC7';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.DefaultVideoProviderID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Default Meeting Settings',
   GeneratedFormSection = 'Category',
   DisplayName = 'Default Video Provider'
WHERE 
   ID = '86AB2716-8A34-43F6-BDF0-881AC39981D3';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.DefaultVideoProvider 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Default Meeting Settings',
   GeneratedFormSection = 'Category',
   DisplayName = 'Default Video Provider Name'
WHERE 
   ID = '111E70EB-ADEA-4B44-9A7B-2942CEBDBAE6';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.DefaultVisibility 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Default Meeting Settings',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '2BE312A6-8E78-42A5-8CB0-3A3D1DB65B4F';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.AgendaTemplate 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Templates and Prompts',
   GeneratedFormSection = 'Category',
   ExtendedType = 'JSON'
WHERE 
   ID = 'FFC5D903-C882-4A4A-B905-EB01F5AA5AE8';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.NotesPromptID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Templates and Prompts',
   GeneratedFormSection = 'Category',
   DisplayName = 'Notes Prompt'
WHERE 
   ID = '73D48712-5706-4222-95C5-43EFCBCA1A8C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.NotesPrompt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Templates and Prompts',
   GeneratedFormSection = 'Category',
   DisplayName = 'Notes Prompt Name'
WHERE 
   ID = '4DD8DC5F-4112-4D6A-8723-81FF93451AEC';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '84B99F38-E980-4CC4-932B-5ECEF135666B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Types.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '1E3CC4B6-FB14-46CE-983F-BC607B78F72E';

/* Set entity icon to fa fa-calendar-alt */

               UPDATE [${mjSchema}].[Entity]
               SET [Icon] = 'fa fa-calendar-alt', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '7967EB2A-B969-41DC-A71D-0591C1E57353';

/* Insert FieldCategoryInfo setting for entity */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND [Name] = 'FieldCategoryInfo'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('2a9192af-4914-5051-a023-3450db200861', '7967EB2A-B969-41DC-A71D-0591C1E57353', 'FieldCategoryInfo', '{
  "Default Meeting Settings": {
    "description": "Default configuration values applied when creating a new meeting of this type",
    "icon": "fa fa-sliders-h"
  },
  "Meeting Type Details": {
    "description": "Core identifying information and display properties for the meeting type",
    "icon": "fa fa-info-circle"
  },
  "System Metadata": {
    "description": "System-managed audit and tracking fields",
    "icon": "fa fa-cog"
  },
  "Templates and Prompts": {
    "description": "Agenda templates and AI note-taking configurations associated with this meeting type",
    "icon": "fa fa-file-alt"
  }
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Insert FieldCategoryIcons setting (legacy) */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353' AND [Name] = 'FieldCategoryIcons'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('04b44299-1815-5124-b432-c972b2f3ccbc', '7967EB2A-B969-41DC-A71D-0591C1E57353', 'FieldCategoryIcons', '{
  "Default Meeting Settings": "fa fa-sliders-h",
  "Meeting Type Details": "fa fa-info-circle",
  "System Metadata": "fa fa-cog",
  "Templates and Prompts": "fa fa-file-alt"
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Set DefaultForNewUser=false for NEW entity (category: reference, confidence: high) */

         UPDATE [${mjSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 0, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '7967EB2A-B969-41DC-A71D-0591C1E57353';

/* Set categories for 22 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.ID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'EB18DB1F-0383-413D-AB11-7FA47D22F744';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.Name 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Series Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '8004B7D1-BF55-44CA-8990-91B93343E162';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.Description 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Series Details',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Markdown'
WHERE 
   ID = '65508A56-4DD4-41E4-9111-EE503BBFD323';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.TypeID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Series Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Type'
WHERE 
   ID = 'FBB88C84-BFEA-4FCB-B6D0-C40970FB7227';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.Type 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Series Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Type Name'
WHERE 
   ID = 'B3691140-FE5E-4372-9701-5DE54DD38149';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.OrganizerPersonID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Series Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Organizer'
WHERE 
   ID = '00BB9F84-29E8-4C39-9B3E-44AE52B87C42';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.OrganizerPerson 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Series Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '30460581-B7B3-4F45-B3AA-A8DF8AF6C03C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.RecurrenceRule 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Schedule and Recurrence',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '5583B7E8-4624-4778-8C9B-EE15DEC2275D';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.TimeZone 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Schedule and Recurrence',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '6EEAF90E-6C8D-46C1-935F-13BC15F5A395';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.FirstStartsAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Schedule and Recurrence',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '6DAECF3E-748C-4B51-9B42-8F095D513A6E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.DurationMinutes 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Schedule and Recurrence',
   GeneratedFormSection = 'Category',
   DisplayName = 'Duration (Minutes)'
WHERE 
   ID = 'E92CD564-063F-4B1D-AFC2-66FFD2F6F4F9';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.MaterializedThrough 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Schedule and Recurrence',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '0B168D0A-7E23-4400-A043-467DEE21EC20';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.LocationType 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Location and Logistics',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'F0BE87EB-6629-4B07-A288-84B373C44102';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.Location 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Location and Logistics',
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoAddress'
WHERE 
   ID = 'BCAAF8D4-4E2D-4E7C-A880-1922A589B019';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.VideoProviderID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Location and Logistics',
   GeneratedFormSection = 'Category',
   DisplayName = 'Video Provider'
WHERE 
   ID = '6E4C25E9-380E-42B3-925D-61BA97760279';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.VideoProvider 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Location and Logistics',
   GeneratedFormSection = 'Category',
   DisplayName = 'Video Provider Name'
WHERE 
   ID = '68692C71-1E3F-4F8E-9264-AB8BF7209F3D';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.Visibility 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Settings and Status',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'DF21C626-8DE5-4D74-89DB-572EA93C1C9C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.Status 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Settings and Status',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '222FC8E1-118E-47AE-8D44-140185534EE4';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.CreatedByPersonID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   DisplayName = 'Created By Person'
WHERE 
   ID = 'EF848A75-8DA4-4772-8870-B606BBAA1C42';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.CreatedByPerson 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   DisplayName = 'Created By Person Name'
WHERE 
   ID = '6C4923E2-CEF8-4EC4-90B2-CA533C860B2B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '618D3FE1-DD26-4004-9DE1-16F4CB261462';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meeting Series.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '7EE5B8EF-E535-49B1-953A-94E1FA99DB74';

/* Set SupportsGeoCoding = true for MJ_BizApps_Tasks: Meeting Series */

            UPDATE [${mjSchema}].[Entity]
            SET [SupportsGeoCoding] = 1
            WHERE [ID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND [AutoUpdateSupportsGeoCoding] = 1;

/* Set entity icon to fa fa-calendar-alt */

               UPDATE [${mjSchema}].[Entity]
               SET [Icon] = 'fa fa-calendar-alt', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269';

/* Insert FieldCategoryInfo setting for entity */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND [Name] = 'FieldCategoryInfo'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('4a016429-8c77-5df2-b904-6352640e11b1', '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', 'FieldCategoryInfo', '{
  "Location and Logistics": {
    "description": "Physical location types, addresses, and virtual video conference providers",
    "icon": "fa fa-map-marker-alt"
  },
  "Meeting Series Details": {
    "description": "Core title, description, organizer, and type information for the recurring meeting series",
    "icon": "fa fa-info-circle"
  },
  "Schedule and Recurrence": {
    "description": "Recurrence rules, time zones, timing, duration, and scheduling horizons",
    "icon": "fa fa-clock"
  },
  "Settings and Status": {
    "description": "Series visibility, lifecycle status, and configuration options",
    "icon": "fa fa-sliders-h"
  },
  "System Metadata": {
    "description": "System-managed audit and tracking fields",
    "icon": "fa fa-cog"
  }
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Insert FieldCategoryIcons setting (legacy) */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND [Name] = 'FieldCategoryIcons'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('9df0847e-8fe0-5200-8a93-90ccc406cbde', '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', 'FieldCategoryIcons', '{
  "Location and Logistics": "fa fa-map-marker-alt",
  "Meeting Series Details": "fa fa-info-circle",
  "Schedule and Recurrence": "fa fa-clock",
  "Settings and Status": "fa fa-sliders-h",
  "System Metadata": "fa fa-cog"
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${mjSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269';

/* Set categories for 33 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.ID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'B82CD373-B034-4613-88E7-6207C075C3BB';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.Name 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '14777148-7099-4A9E-90EE-171E1C3A246B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.Description 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Details',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Markdown'
WHERE 
   ID = '5D23E84D-4B86-48DF-BBF5-DB616D2E2D2D';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.TypeID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Type'
WHERE 
   ID = 'B0BB59CB-CC1F-474A-94B4-00EFD53282D8';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.Type 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'D2F3FE65-BDFA-4232-B3C2-8E38CEFBD8E1';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.Visibility 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Meeting Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '392E3392-8E5A-4090-8118-86B4CD6045BD';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.SeriesID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Recurrence and Series',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '766C5B07-2435-43F7-AFB9-B52379A05FE5';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.Series 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Recurrence and Series',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'C3A9E1B1-7E40-49CF-8D10-AEF72CDB4344';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.OccurrenceStartsAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Recurrence and Series',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '338E7F5D-3D29-4B2D-A647-ADA73AC1576D';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.Status 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Schedule and Timeline',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '8506E396-CCF3-4F7F-ADEC-9113641A1759';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.StartsAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Schedule and Timeline',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '8310B0AF-B0A7-4C4A-AF2B-C13D77FFA2B7';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.EndsAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Schedule and Timeline',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '6ABC9840-AB83-4C42-9FD7-F1C9E5E33C66';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.TimeZone 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Schedule and Timeline',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '58FEE423-76B8-403E-AD6B-AE0A48C22D67';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.ActualStartedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Schedule and Timeline',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'B0684687-20CB-4717-B3DD-EEF0C3E74B81';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.ActualEndedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Schedule and Timeline',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'A33B4E11-7522-49B7-AA9B-90D55020253D';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.CancelledAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Cancellation Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '53AD32E5-7DB7-4909-A405-7A79670A9615';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.CancellationReason 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Cancellation Details',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '3EBCD61D-E7D2-4929-9AAF-586DF17855C0';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.LocationType 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Location and Virtual Access',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'C1451E38-09D5-41DA-9373-A62BBC5071CF';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.Location 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Location and Virtual Access',
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoAddress'
WHERE 
   ID = 'C1873111-DEA8-40F5-9CB5-18638762B2CD';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.VideoProviderID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Location and Virtual Access',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'A3B820B7-9FA2-43F3-B5F6-05EB8145AEB7';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.VideoProvider 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Location and Virtual Access',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'FA403CD1-9327-43F7-AE8C-417D3C0FF599';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.VideoMeetingID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Location and Virtual Access',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'D4C0ABF1-DB2E-4DF6-A319-8CF2C6E97DCE';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.VideoJoinURL 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Location and Virtual Access',
   GeneratedFormSection = 'Category',
   ExtendedType = 'URL'
WHERE 
   ID = '67027709-E3B0-4A3A-907D-A029A3193C84';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.DialInDetails 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Location and Virtual Access',
   GeneratedFormSection = 'Category',
   DisplayName = 'Dial-In Details'
WHERE 
   ID = '069079F4-0390-4188-82B9-49778E6AE60A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.OrganizerPersonID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Participants and Ownership',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '3E551302-F355-4DB0-867A-2BC81441EBB7';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.OrganizerPerson 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Participants and Ownership',
   GeneratedFormSection = 'Category',
   DisplayName = 'Organizer'
WHERE 
   ID = '55FEEBA4-4769-4A20-91BF-43FD17B0B2AC';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.CreatedByPersonID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Participants and Ownership',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'BF1D9416-B0E0-4737-ADA7-41793F2AD8CF';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.CreatedByPerson 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Participants and Ownership',
   GeneratedFormSection = 'Category',
   DisplayName = 'Created By'
WHERE 
   ID = '3DD708BE-F881-4079-B933-CAAEEBA08697';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.VideoRecordingURL 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Recording and Transcript',
   GeneratedFormSection = 'Category',
   ExtendedType = 'URL'
WHERE 
   ID = '06CF0403-A889-4156-8CA9-F71CBD8871C9';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.TranscriptFileID 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Recording and Transcript',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '9CDA5909-4BE3-42E1-A29D-F1E1768E7DA9';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.TranscriptFile 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'Recording and Transcript',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '49F6B04D-C761-4C1E-96A8-B789CC519978';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.__mj_CreatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = 'C7FAFFA9-9ECD-438E-8569-920AB6AB6960';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Meetings.__mj_UpdatedAt 
UPDATE [${mjSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category'
WHERE 
   ID = '8D27D959-3E50-455E-9150-B1C530B979CA';

/* Set SupportsGeoCoding = true for MJ_BizApps_Tasks: Meetings */

            UPDATE [${mjSchema}].[Entity]
            SET [SupportsGeoCoding] = 1
            WHERE [ID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND [AutoUpdateSupportsGeoCoding] = 1;

/* Set entity icon to fa fa-calendar-alt */

               UPDATE [${mjSchema}].[Entity]
               SET [Icon] = 'fa fa-calendar-alt', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD';

/* Insert FieldCategoryInfo setting for entity */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND [Name] = 'FieldCategoryInfo'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('ad9ea4d2-abc3-53f4-9fa0-a594dc210824', '83BB5923-29C9-4CBB-94C4-35601DA29DDD', 'FieldCategoryInfo', '{
  "Cancellation Details": {
    "description": "Information regarding when and why the meeting was cancelled",
    "icon": "fa fa-ban"
  },
  "Location and Virtual Access": {
    "description": "Physical room/address and virtual meeting provider details",
    "icon": "fa fa-map-marker-alt"
  },
  "Meeting Details": {
    "description": "Core descriptive information about the meeting such as title, purpose, and visibility",
    "icon": "fa fa-info-circle"
  },
  "Participants and Ownership": {
    "description": "People responsible for organizing and creating the meeting",
    "icon": "fa fa-users"
  },
  "Recording and Transcript": {
    "description": "Recorded video links and stored text transcripts of the meeting",
    "icon": "fa file-alt"
  },
  "Recurrence and Series": {
    "description": "Information linking the meeting to a repeating series and its original time slot",
    "icon": "fa fa-redo"
  },
  "Schedule and Timeline": {
    "description": "Planned and actual timing, status, and time zone information",
    "icon": "fa fa-clock"
  }
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Insert FieldCategoryIcons setting (legacy) */
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntitySetting] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND [Name] = 'FieldCategoryIcons'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('7865c912-c125-5fb9-9b7d-2ae28c9fa838', '83BB5923-29C9-4CBB-94C4-35601DA29DDD', 'FieldCategoryIcons', '{
  "Cancellation Details": "fa fa-ban",
  "Location and Virtual Access": "fa fa-map-marker-alt",
  "Meeting Details": "fa fa-info-circle",
  "Participants and Ownership": "fa fa-users",
  "Recording and Transcript": "fa file-alt",
  "Recurrence and Series": "fa fa-redo",
  "Schedule and Timeline": "fa fa-clock"
}', GETUTCDATE(), GETUTCDATE())
   END;

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${mjSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD';

/* Index for Foreign Keys for MeetingSeries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TypeID in table MeetingSeries
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingSeries_TypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingSeries]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingSeries_TypeID ON [${flyway:defaultSchema}].[MeetingSeries] ([TypeID]);

-- Index for foreign key OrganizerPersonID in table MeetingSeries
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingSeries_OrganizerPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingSeries]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingSeries_OrganizerPersonID ON [${flyway:defaultSchema}].[MeetingSeries] ([OrganizerPersonID]);

-- Index for foreign key VideoProviderID in table MeetingSeries
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingSeries_VideoProviderID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingSeries]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingSeries_VideoProviderID ON [${flyway:defaultSchema}].[MeetingSeries] ([VideoProviderID]);

-- Index for foreign key CreatedByPersonID in table MeetingSeries
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_MeetingSeries_CreatedByPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[MeetingSeries]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_MeetingSeries_CreatedByPersonID ON [${flyway:defaultSchema}].[MeetingSeries] ([CreatedByPersonID]);

/* Base View SQL for MJ_BizApps_Tasks: Meeting Series */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series
-- Item: vwMeetingSeries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Meeting Series
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  MeetingSeries
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwMeetingSeries]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwMeetingSeries];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwMeetingSeries]
AS
SELECT
    m.*,
    mjBizAppsTasksMeetingType_TypeID.[Name] AS [Type],
    mjBizAppsCommonPerson_OrganizerPersonID.[DisplayName] AS [OrganizerPerson],
    mjBizAppsTasksVideoProvider_VideoProviderID.[Name] AS [VideoProvider],
    mjBizAppsCommonPerson_CreatedByPersonID.[DisplayName] AS [CreatedByPerson],
    ${mjSchema}_rgc.[Latitude] AS [${mjSchema}_Latitude],
    ${mjSchema}_rgc.[Longitude] AS [${mjSchema}_Longitude]
FROM
    [${flyway:defaultSchema}].[MeetingSeries] AS m
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[MeetingType] AS mjBizAppsTasksMeetingType_TypeID
  ON
    [m].[TypeID] = mjBizAppsTasksMeetingType_TypeID.[ID]
INNER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_OrganizerPersonID
  ON
    [m].[OrganizerPersonID] = mjBizAppsCommonPerson_OrganizerPersonID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[VideoProvider] AS mjBizAppsTasksVideoProvider_VideoProviderID
  ON
    [m].[VideoProviderID] = mjBizAppsTasksVideoProvider_VideoProviderID.[ID]
LEFT OUTER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_CreatedByPersonID
  ON
    [m].[CreatedByPersonID] = mjBizAppsCommonPerson_CreatedByPersonID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[vwRecordGeoCodes] AS ${mjSchema}_rgc
  ON
    ${mjSchema}_rgc.[EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'
    AND ${mjSchema}_rgc.[RecordID] = CAST([m].[ID] AS NVARCHAR(450))
    AND ${mjSchema}_rgc.[LocationType] = 'Primary'
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingSeries] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Meeting Series */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series
-- Item: Permissions for vwMeetingSeries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetingSeries] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Meeting Series */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series
-- Item: spCreateMeetingSeries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR MeetingSeries
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateMeetingSeries]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingSeries];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateMeetingSeries]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(255),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @TypeID_Clear bit = 0,
    @TypeID uniqueidentifier = NULL,
    @OrganizerPersonID uniqueidentifier,
    @RecurrenceRule nvarchar(500),
    @TimeZone nvarchar(64),
    @FirstStartsAt datetimeoffset,
    @DurationMinutes int,
    @LocationType nvarchar(20) = NULL,
    @Location_Clear bit = 0,
    @Location nvarchar(500) = NULL,
    @VideoProviderID_Clear bit = 0,
    @VideoProviderID uniqueidentifier = NULL,
    @Visibility nvarchar(20) = NULL,
    @Status nvarchar(20) = NULL,
    @MaterializedThrough_Clear bit = 0,
    @MaterializedThrough datetimeoffset = NULL,
    @CreatedByPersonID_Clear bit = 0,
    @CreatedByPersonID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[MeetingSeries]
            (
                [ID],
                [Name],
                [Description],
                [TypeID],
                [OrganizerPersonID],
                [RecurrenceRule],
                [TimeZone],
                [FirstStartsAt],
                [DurationMinutes],
                [LocationType],
                [Location],
                [VideoProviderID],
                [Visibility],
                [Status],
                [MaterializedThrough],
                [CreatedByPersonID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, NULL) END,
                @OrganizerPersonID,
                @RecurrenceRule,
                @TimeZone,
                @FirstStartsAt,
                @DurationMinutes,
                ISNULL(@LocationType, 'Virtual'),
                CASE WHEN @Location_Clear = 1 THEN NULL ELSE ISNULL(@Location, NULL) END,
                CASE WHEN @VideoProviderID_Clear = 1 THEN NULL ELSE ISNULL(@VideoProviderID, NULL) END,
                ISNULL(@Visibility, 'Standard'),
                ISNULL(@Status, 'Active'),
                CASE WHEN @MaterializedThrough_Clear = 1 THEN NULL ELSE ISNULL(@MaterializedThrough, NULL) END,
                CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[MeetingSeries]
            (
                [Name],
                [Description],
                [TypeID],
                [OrganizerPersonID],
                [RecurrenceRule],
                [TimeZone],
                [FirstStartsAt],
                [DurationMinutes],
                [LocationType],
                [Location],
                [VideoProviderID],
                [Visibility],
                [Status],
                [MaterializedThrough],
                [CreatedByPersonID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, NULL) END,
                @OrganizerPersonID,
                @RecurrenceRule,
                @TimeZone,
                @FirstStartsAt,
                @DurationMinutes,
                ISNULL(@LocationType, 'Virtual'),
                CASE WHEN @Location_Clear = 1 THEN NULL ELSE ISNULL(@Location, NULL) END,
                CASE WHEN @VideoProviderID_Clear = 1 THEN NULL ELSE ISNULL(@VideoProviderID, NULL) END,
                ISNULL(@Visibility, 'Standard'),
                ISNULL(@Status, 'Active'),
                CASE WHEN @MaterializedThrough_Clear = 1 THEN NULL ELSE ISNULL(@MaterializedThrough, NULL) END,
                CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwMeetingSeries] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingSeries] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Meeting Series */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeetingSeries] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Meeting Series */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series
-- Item: spUpdateMeetingSeries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR MeetingSeries
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateMeetingSeries]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingSeries];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateMeetingSeries]
    @ID uniqueidentifier,
    @Name nvarchar(255) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @TypeID_Clear bit = 0,
    @TypeID uniqueidentifier = NULL,
    @OrganizerPersonID uniqueidentifier = NULL,
    @RecurrenceRule nvarchar(500) = NULL,
    @TimeZone nvarchar(64) = NULL,
    @FirstStartsAt datetimeoffset = NULL,
    @DurationMinutes int = NULL,
    @LocationType nvarchar(20) = NULL,
    @Location_Clear bit = 0,
    @Location nvarchar(500) = NULL,
    @VideoProviderID_Clear bit = 0,
    @VideoProviderID uniqueidentifier = NULL,
    @Visibility nvarchar(20) = NULL,
    @Status nvarchar(20) = NULL,
    @MaterializedThrough_Clear bit = 0,
    @MaterializedThrough datetimeoffset = NULL,
    @CreatedByPersonID_Clear bit = 0,
    @CreatedByPersonID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingSeries]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [TypeID] = CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, [TypeID]) END,
        [OrganizerPersonID] = ISNULL(@OrganizerPersonID, [OrganizerPersonID]),
        [RecurrenceRule] = ISNULL(@RecurrenceRule, [RecurrenceRule]),
        [TimeZone] = ISNULL(@TimeZone, [TimeZone]),
        [FirstStartsAt] = ISNULL(@FirstStartsAt, [FirstStartsAt]),
        [DurationMinutes] = ISNULL(@DurationMinutes, [DurationMinutes]),
        [LocationType] = ISNULL(@LocationType, [LocationType]),
        [Location] = CASE WHEN @Location_Clear = 1 THEN NULL ELSE ISNULL(@Location, [Location]) END,
        [VideoProviderID] = CASE WHEN @VideoProviderID_Clear = 1 THEN NULL ELSE ISNULL(@VideoProviderID, [VideoProviderID]) END,
        [Visibility] = ISNULL(@Visibility, [Visibility]),
        [Status] = ISNULL(@Status, [Status]),
        [MaterializedThrough] = CASE WHEN @MaterializedThrough_Clear = 1 THEN NULL ELSE ISNULL(@MaterializedThrough, [MaterializedThrough]) END,
        [CreatedByPersonID] = CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, [CreatedByPersonID]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwMeetingSeries] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwMeetingSeries]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingSeries] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the MeetingSeries table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateMeetingSeries]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateMeetingSeries];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateMeetingSeries
ON [${flyway:defaultSchema}].[MeetingSeries]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[MeetingSeries]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[MeetingSeries] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Meeting Series */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeetingSeries] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Meeting Series */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meeting Series
-- Item: spDeleteMeetingSeries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR MeetingSeries
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteMeetingSeries]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingSeries];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteMeetingSeries]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[MeetingSeries]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingSeries] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Meeting Series */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeetingSeries] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for Meeting */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meetings
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TypeID in table Meeting
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Meeting_TypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Meeting]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Meeting_TypeID ON [${flyway:defaultSchema}].[Meeting] ([TypeID]);

-- Index for foreign key SeriesID in table Meeting
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Meeting_SeriesID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Meeting]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Meeting_SeriesID ON [${flyway:defaultSchema}].[Meeting] ([SeriesID]);

-- Index for foreign key VideoProviderID in table Meeting
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Meeting_VideoProviderID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Meeting]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Meeting_VideoProviderID ON [${flyway:defaultSchema}].[Meeting] ([VideoProviderID]);

-- Index for foreign key OrganizerPersonID in table Meeting
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Meeting_OrganizerPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Meeting]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Meeting_OrganizerPersonID ON [${flyway:defaultSchema}].[Meeting] ([OrganizerPersonID]);

-- Index for foreign key TranscriptFileID in table Meeting
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Meeting_TranscriptFileID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Meeting]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Meeting_TranscriptFileID ON [${flyway:defaultSchema}].[Meeting] ([TranscriptFileID]);

-- Index for foreign key CreatedByPersonID in table Meeting
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Meeting_CreatedByPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Meeting]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Meeting_CreatedByPersonID ON [${flyway:defaultSchema}].[Meeting] ([CreatedByPersonID]);

/* Base View SQL for MJ_BizApps_Tasks: Meetings */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meetings
-- Item: vwMeetings
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Meetings
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  Meeting
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwMeetings]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwMeetings];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwMeetings]
AS
SELECT
    m.*,
    mjBizAppsTasksMeetingType_TypeID.[Name] AS [Type],
    mjBizAppsTasksMeetingSeries_SeriesID.[Name] AS [Series],
    mjBizAppsTasksVideoProvider_VideoProviderID.[Name] AS [VideoProvider],
    mjBizAppsCommonPerson_OrganizerPersonID.[DisplayName] AS [OrganizerPerson],
    MJFile_TranscriptFileID.[Name] AS [TranscriptFile],
    mjBizAppsCommonPerson_CreatedByPersonID.[DisplayName] AS [CreatedByPerson],
    ${mjSchema}_rgc.[Latitude] AS [${mjSchema}_Latitude],
    ${mjSchema}_rgc.[Longitude] AS [${mjSchema}_Longitude]
FROM
    [${flyway:defaultSchema}].[Meeting] AS m
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[MeetingType] AS mjBizAppsTasksMeetingType_TypeID
  ON
    [m].[TypeID] = mjBizAppsTasksMeetingType_TypeID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[MeetingSeries] AS mjBizAppsTasksMeetingSeries_SeriesID
  ON
    [m].[SeriesID] = mjBizAppsTasksMeetingSeries_SeriesID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[VideoProvider] AS mjBizAppsTasksVideoProvider_VideoProviderID
  ON
    [m].[VideoProviderID] = mjBizAppsTasksVideoProvider_VideoProviderID.[ID]
INNER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_OrganizerPersonID
  ON
    [m].[OrganizerPersonID] = mjBizAppsCommonPerson_OrganizerPersonID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[File] AS MJFile_TranscriptFileID
  ON
    [m].[TranscriptFileID] = MJFile_TranscriptFileID.[ID]
LEFT OUTER JOIN
    [${mjSchema}_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_CreatedByPersonID
  ON
    [m].[CreatedByPersonID] = mjBizAppsCommonPerson_CreatedByPersonID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[vwRecordGeoCodes] AS ${mjSchema}_rgc
  ON
    ${mjSchema}_rgc.[EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'
    AND ${mjSchema}_rgc.[RecordID] = CAST([m].[ID] AS NVARCHAR(450))
    AND ${mjSchema}_rgc.[LocationType] = 'Primary'
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetings] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Meetings */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meetings
-- Item: Permissions for vwMeetings
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwMeetings] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for MJ_BizApps_Tasks: Meetings */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meetings
-- Item: spCreateMeeting
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Meeting
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateMeeting]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateMeeting];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateMeeting]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(255),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @TypeID_Clear bit = 0,
    @TypeID uniqueidentifier = NULL,
    @SeriesID_Clear bit = 0,
    @SeriesID uniqueidentifier = NULL,
    @OccurrenceStartsAt_Clear bit = 0,
    @OccurrenceStartsAt datetimeoffset = NULL,
    @Status nvarchar(20) = NULL,
    @StartsAt datetimeoffset,
    @EndsAt datetimeoffset,
    @TimeZone nvarchar(64),
    @LocationType nvarchar(20) = NULL,
    @Location_Clear bit = 0,
    @Location nvarchar(500) = NULL,
    @VideoProviderID_Clear bit = 0,
    @VideoProviderID uniqueidentifier = NULL,
    @VideoMeetingID_Clear bit = 0,
    @VideoMeetingID nvarchar(255) = NULL,
    @VideoJoinURL_Clear bit = 0,
    @VideoJoinURL nvarchar(1000) = NULL,
    @DialInDetails_Clear bit = 0,
    @DialInDetails nvarchar(1000) = NULL,
    @OrganizerPersonID uniqueidentifier,
    @Visibility nvarchar(20) = NULL,
    @ActualStartedAt_Clear bit = 0,
    @ActualStartedAt datetimeoffset = NULL,
    @ActualEndedAt_Clear bit = 0,
    @ActualEndedAt datetimeoffset = NULL,
    @CancelledAt_Clear bit = 0,
    @CancelledAt datetimeoffset = NULL,
    @CancellationReason_Clear bit = 0,
    @CancellationReason nvarchar(500) = NULL,
    @VideoRecordingURL_Clear bit = 0,
    @VideoRecordingURL nvarchar(1000) = NULL,
    @TranscriptFileID_Clear bit = 0,
    @TranscriptFileID uniqueidentifier = NULL,
    @CreatedByPersonID_Clear bit = 0,
    @CreatedByPersonID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[Meeting]
            (
                [ID],
                [Name],
                [Description],
                [TypeID],
                [SeriesID],
                [OccurrenceStartsAt],
                [Status],
                [StartsAt],
                [EndsAt],
                [TimeZone],
                [LocationType],
                [Location],
                [VideoProviderID],
                [VideoMeetingID],
                [VideoJoinURL],
                [DialInDetails],
                [OrganizerPersonID],
                [Visibility],
                [ActualStartedAt],
                [ActualEndedAt],
                [CancelledAt],
                [CancellationReason],
                [VideoRecordingURL],
                [TranscriptFileID],
                [CreatedByPersonID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, NULL) END,
                CASE WHEN @SeriesID_Clear = 1 THEN NULL ELSE ISNULL(@SeriesID, NULL) END,
                CASE WHEN @OccurrenceStartsAt_Clear = 1 THEN NULL ELSE ISNULL(@OccurrenceStartsAt, NULL) END,
                ISNULL(@Status, 'Scheduled'),
                @StartsAt,
                @EndsAt,
                @TimeZone,
                ISNULL(@LocationType, 'Virtual'),
                CASE WHEN @Location_Clear = 1 THEN NULL ELSE ISNULL(@Location, NULL) END,
                CASE WHEN @VideoProviderID_Clear = 1 THEN NULL ELSE ISNULL(@VideoProviderID, NULL) END,
                CASE WHEN @VideoMeetingID_Clear = 1 THEN NULL ELSE ISNULL(@VideoMeetingID, NULL) END,
                CASE WHEN @VideoJoinURL_Clear = 1 THEN NULL ELSE ISNULL(@VideoJoinURL, NULL) END,
                CASE WHEN @DialInDetails_Clear = 1 THEN NULL ELSE ISNULL(@DialInDetails, NULL) END,
                @OrganizerPersonID,
                ISNULL(@Visibility, 'Standard'),
                CASE WHEN @ActualStartedAt_Clear = 1 THEN NULL ELSE ISNULL(@ActualStartedAt, NULL) END,
                CASE WHEN @ActualEndedAt_Clear = 1 THEN NULL ELSE ISNULL(@ActualEndedAt, NULL) END,
                CASE WHEN @CancelledAt_Clear = 1 THEN NULL ELSE ISNULL(@CancelledAt, NULL) END,
                CASE WHEN @CancellationReason_Clear = 1 THEN NULL ELSE ISNULL(@CancellationReason, NULL) END,
                CASE WHEN @VideoRecordingURL_Clear = 1 THEN NULL ELSE ISNULL(@VideoRecordingURL, NULL) END,
                CASE WHEN @TranscriptFileID_Clear = 1 THEN NULL ELSE ISNULL(@TranscriptFileID, NULL) END,
                CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[Meeting]
            (
                [Name],
                [Description],
                [TypeID],
                [SeriesID],
                [OccurrenceStartsAt],
                [Status],
                [StartsAt],
                [EndsAt],
                [TimeZone],
                [LocationType],
                [Location],
                [VideoProviderID],
                [VideoMeetingID],
                [VideoJoinURL],
                [DialInDetails],
                [OrganizerPersonID],
                [Visibility],
                [ActualStartedAt],
                [ActualEndedAt],
                [CancelledAt],
                [CancellationReason],
                [VideoRecordingURL],
                [TranscriptFileID],
                [CreatedByPersonID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, NULL) END,
                CASE WHEN @SeriesID_Clear = 1 THEN NULL ELSE ISNULL(@SeriesID, NULL) END,
                CASE WHEN @OccurrenceStartsAt_Clear = 1 THEN NULL ELSE ISNULL(@OccurrenceStartsAt, NULL) END,
                ISNULL(@Status, 'Scheduled'),
                @StartsAt,
                @EndsAt,
                @TimeZone,
                ISNULL(@LocationType, 'Virtual'),
                CASE WHEN @Location_Clear = 1 THEN NULL ELSE ISNULL(@Location, NULL) END,
                CASE WHEN @VideoProviderID_Clear = 1 THEN NULL ELSE ISNULL(@VideoProviderID, NULL) END,
                CASE WHEN @VideoMeetingID_Clear = 1 THEN NULL ELSE ISNULL(@VideoMeetingID, NULL) END,
                CASE WHEN @VideoJoinURL_Clear = 1 THEN NULL ELSE ISNULL(@VideoJoinURL, NULL) END,
                CASE WHEN @DialInDetails_Clear = 1 THEN NULL ELSE ISNULL(@DialInDetails, NULL) END,
                @OrganizerPersonID,
                ISNULL(@Visibility, 'Standard'),
                CASE WHEN @ActualStartedAt_Clear = 1 THEN NULL ELSE ISNULL(@ActualStartedAt, NULL) END,
                CASE WHEN @ActualEndedAt_Clear = 1 THEN NULL ELSE ISNULL(@ActualEndedAt, NULL) END,
                CASE WHEN @CancelledAt_Clear = 1 THEN NULL ELSE ISNULL(@CancelledAt, NULL) END,
                CASE WHEN @CancellationReason_Clear = 1 THEN NULL ELSE ISNULL(@CancellationReason, NULL) END,
                CASE WHEN @VideoRecordingURL_Clear = 1 THEN NULL ELSE ISNULL(@VideoRecordingURL, NULL) END,
                CASE WHEN @TranscriptFileID_Clear = 1 THEN NULL ELSE ISNULL(@TranscriptFileID, NULL) END,
                CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwMeetings] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeeting] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Meetings */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateMeeting] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for MJ_BizApps_Tasks: Meetings */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meetings
-- Item: spUpdateMeeting
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Meeting
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateMeeting]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateMeeting];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateMeeting]
    @ID uniqueidentifier,
    @Name nvarchar(255) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @TypeID_Clear bit = 0,
    @TypeID uniqueidentifier = NULL,
    @SeriesID_Clear bit = 0,
    @SeriesID uniqueidentifier = NULL,
    @OccurrenceStartsAt_Clear bit = 0,
    @OccurrenceStartsAt datetimeoffset = NULL,
    @Status nvarchar(20) = NULL,
    @StartsAt datetimeoffset = NULL,
    @EndsAt datetimeoffset = NULL,
    @TimeZone nvarchar(64) = NULL,
    @LocationType nvarchar(20) = NULL,
    @Location_Clear bit = 0,
    @Location nvarchar(500) = NULL,
    @VideoProviderID_Clear bit = 0,
    @VideoProviderID uniqueidentifier = NULL,
    @VideoMeetingID_Clear bit = 0,
    @VideoMeetingID nvarchar(255) = NULL,
    @VideoJoinURL_Clear bit = 0,
    @VideoJoinURL nvarchar(1000) = NULL,
    @DialInDetails_Clear bit = 0,
    @DialInDetails nvarchar(1000) = NULL,
    @OrganizerPersonID uniqueidentifier = NULL,
    @Visibility nvarchar(20) = NULL,
    @ActualStartedAt_Clear bit = 0,
    @ActualStartedAt datetimeoffset = NULL,
    @ActualEndedAt_Clear bit = 0,
    @ActualEndedAt datetimeoffset = NULL,
    @CancelledAt_Clear bit = 0,
    @CancelledAt datetimeoffset = NULL,
    @CancellationReason_Clear bit = 0,
    @CancellationReason nvarchar(500) = NULL,
    @VideoRecordingURL_Clear bit = 0,
    @VideoRecordingURL nvarchar(1000) = NULL,
    @TranscriptFileID_Clear bit = 0,
    @TranscriptFileID uniqueidentifier = NULL,
    @CreatedByPersonID_Clear bit = 0,
    @CreatedByPersonID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[Meeting]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [TypeID] = CASE WHEN @TypeID_Clear = 1 THEN NULL ELSE ISNULL(@TypeID, [TypeID]) END,
        [SeriesID] = CASE WHEN @SeriesID_Clear = 1 THEN NULL ELSE ISNULL(@SeriesID, [SeriesID]) END,
        [OccurrenceStartsAt] = CASE WHEN @OccurrenceStartsAt_Clear = 1 THEN NULL ELSE ISNULL(@OccurrenceStartsAt, [OccurrenceStartsAt]) END,
        [Status] = ISNULL(@Status, [Status]),
        [StartsAt] = ISNULL(@StartsAt, [StartsAt]),
        [EndsAt] = ISNULL(@EndsAt, [EndsAt]),
        [TimeZone] = ISNULL(@TimeZone, [TimeZone]),
        [LocationType] = ISNULL(@LocationType, [LocationType]),
        [Location] = CASE WHEN @Location_Clear = 1 THEN NULL ELSE ISNULL(@Location, [Location]) END,
        [VideoProviderID] = CASE WHEN @VideoProviderID_Clear = 1 THEN NULL ELSE ISNULL(@VideoProviderID, [VideoProviderID]) END,
        [VideoMeetingID] = CASE WHEN @VideoMeetingID_Clear = 1 THEN NULL ELSE ISNULL(@VideoMeetingID, [VideoMeetingID]) END,
        [VideoJoinURL] = CASE WHEN @VideoJoinURL_Clear = 1 THEN NULL ELSE ISNULL(@VideoJoinURL, [VideoJoinURL]) END,
        [DialInDetails] = CASE WHEN @DialInDetails_Clear = 1 THEN NULL ELSE ISNULL(@DialInDetails, [DialInDetails]) END,
        [OrganizerPersonID] = ISNULL(@OrganizerPersonID, [OrganizerPersonID]),
        [Visibility] = ISNULL(@Visibility, [Visibility]),
        [ActualStartedAt] = CASE WHEN @ActualStartedAt_Clear = 1 THEN NULL ELSE ISNULL(@ActualStartedAt, [ActualStartedAt]) END,
        [ActualEndedAt] = CASE WHEN @ActualEndedAt_Clear = 1 THEN NULL ELSE ISNULL(@ActualEndedAt, [ActualEndedAt]) END,
        [CancelledAt] = CASE WHEN @CancelledAt_Clear = 1 THEN NULL ELSE ISNULL(@CancelledAt, [CancelledAt]) END,
        [CancellationReason] = CASE WHEN @CancellationReason_Clear = 1 THEN NULL ELSE ISNULL(@CancellationReason, [CancellationReason]) END,
        [VideoRecordingURL] = CASE WHEN @VideoRecordingURL_Clear = 1 THEN NULL ELSE ISNULL(@VideoRecordingURL, [VideoRecordingURL]) END,
        [TranscriptFileID] = CASE WHEN @TranscriptFileID_Clear = 1 THEN NULL ELSE ISNULL(@TranscriptFileID, [TranscriptFileID]) END,
        [CreatedByPersonID] = CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, [CreatedByPersonID]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwMeetings] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwMeetings]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeeting] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Meeting table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateMeeting]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateMeeting];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateMeeting
ON [${flyway:defaultSchema}].[Meeting]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[Meeting]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[Meeting] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Meetings */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateMeeting] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for MJ_BizApps_Tasks: Meetings */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Meetings
-- Item: spDeleteMeeting
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Meeting
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteMeeting]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteMeeting];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteMeeting]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[Meeting]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeeting] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Meetings */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteMeeting] TO [cdp_Developer], [cdp_Integration];

/* SQL text to delete unneeded entity fields (2 scoped entities) */
EXEC [${mjSchema}].[spDeleteUnneededEntityFields] @ExcludedSchemaNames='', @EntityIDs='9ECAC4DF-039C-4B96-84D4-0BE2BD481269,83BB5923-29C9-4CBB-94C4-35601DA29DDD', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to insert 4 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5f23bfed-47b3-468b-aafa-100f712ce6c6' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = '${mjSchema}_Latitude')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5f23bfed-47b3-468b-aafa-100f712ce6c6',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            '${mjSchema}_Latitude',
            'Mj Latitude',
            NULL,
            'decimal',
            9,
            10,
            6,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '788ce10b-d12c-4778-81ed-911fb5b28488' OR (EntityID = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269' AND Name = '${mjSchema}_Longitude')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '788ce10b-d12c-4778-81ed-911fb5b28488',
            '9ECAC4DF-039C-4B96-84D4-0BE2BD481269', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9ECAC4DF-039C-4B96-84D4-0BE2BD481269'),
            '${mjSchema}_Longitude',
            'Mj Longitude',
            NULL,
            'decimal',
            9,
            10,
            6,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9ff60a0f-1200-46ba-82fc-44225ddc84f6' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = '${mjSchema}_Latitude')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9ff60a0f-1200-46ba-82fc-44225ddc84f6',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            '${mjSchema}_Latitude',
            'Mj Latitude',
            NULL,
            'decimal',
            9,
            10,
            6,
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f743cb12-4fe5-4c20-a1ab-a812b599e41f' OR (EntityID = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND Name = '${mjSchema}_Longitude')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f743cb12-4fe5-4c20-a1ab-a812b599e41f',
            '83BB5923-29C9-4CBB-94C4-35601DA29DDD', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD'),
            '${mjSchema}_Longitude',
            'Mj Longitude',
            NULL,
            'decimal',
            9,
            10,
            6,
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
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='', @EntityIDs='9ECAC4DF-039C-4B96-84D4-0BE2BD481269,83BB5923-29C9-4CBB-94C4-35601DA29DDD', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* Set ExtendedType=GeoLatitude on virtual geo fields */
UPDATE [${mjSchema}].[EntityField] SET [ExtendedType] = 'GeoLatitude' WHERE [Name] = '${mjSchema}_Latitude' AND [ExtendedType] IS NULL AND [EntityID] IN ('9ECAC4DF-039C-4B96-84D4-0BE2BD481269','83BB5923-29C9-4CBB-94C4-35601DA29DDD');

/* Set ExtendedType=GeoLongitude on virtual geo fields */
UPDATE [${mjSchema}].[EntityField] SET [ExtendedType] = 'GeoLongitude' WHERE [Name] = '${mjSchema}_Longitude' AND [ExtendedType] IS NULL AND [EntityID] IN ('9ECAC4DF-039C-4B96-84D4-0BE2BD481269','83BB5923-29C9-4CBB-94C4-35601DA29DDD');

/* Generated Validation Functions for MJ_BizApps_Tasks: Meeting Agenda Item Types */
-- CHECK constraint for MJ_BizApps_Tasks: Meeting Agenda Item Types: Field: DefaultDurationMinutes was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '9BE359F0-AAE2-4025-A535-769B6334BA4A'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('df775d95-8270-4e73-b8bb-03ece1adc25e', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([DefaultDurationMinutes] IS NULL OR [DefaultDurationMinutes]>(0))', 'public ValidateDefaultDurationMinutesGreaterThanZero(result: ValidationResult) {
	if (this.DefaultDurationMinutes != null && this.DefaultDurationMinutes <= 0) {
		result.Errors.push(new ValidationErrorInfo(
			"DefaultDurationMinutes",
			"Default duration minutes must be greater than 0.",
			this.DefaultDurationMinutes,
			ValidationErrorType.Failure
		));
	}
}', 'Default duration minutes must be greater than zero when specified.', 'ValidateDefaultDurationMinutesGreaterThanZero', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', '9BE359F0-AAE2-4025-A535-769B6334BA4A')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Meeting Agenda Items */
-- CHECK constraint for MJ_BizApps_Tasks: Meeting Agenda Items: Field: DurationMinutes was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = 'DD7FDE48-5804-4E6E-8A03-771E8D84A263'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('6f984d4c-85a0-401d-bb46-1d2d055a1928', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([DurationMinutes] IS NULL OR [DurationMinutes]>=(0))', 'public ValidateDurationMinutesNonNegative(result: ValidationResult) {
	if (this.DurationMinutes != null && this.DurationMinutes < 0) {
		result.Errors.push(new ValidationErrorInfo(
			"DurationMinutes",
			"Duration in minutes must be zero or greater.",
			this.DurationMinutes,
			ValidationErrorType.Failure
		));
	}
}', 'Duration in minutes must be zero or greater if specified.', 'ValidateDurationMinutesNonNegative', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', 'DD7FDE48-5804-4E6E-8A03-771E8D84A263')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Meeting Attendees */
-- CHECK constraint for MJ_BizApps_Tasks: Meeting Attendees @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '69A03D0B-F654-40B6-9B90-94DEC8948AA2' AND [Name] = 'ValidatePersonIDOrEmailRequired'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('7f23b858-24d3-4aa1-92d9-6464bf88d229', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([PersonID] IS NOT NULL OR [Email] IS NOT NULL)', 'public ValidatePersonIDOrEmailRequired(result: ValidationResult) {
	if (this.PersonID == null && (this.Email == null || this.Email.trim() === "")) {
		result.Errors.push(new ValidationErrorInfo(
			"PersonID",
			"Either a Person or an Email address must be provided.",
			this.PersonID,
			ValidationErrorType.Failure
		));
	}
}', 'Either a Person or an Email address must be provided to identify the attendee.', 'ValidatePersonIDOrEmailRequired', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '69A03D0B-F654-40B6-9B90-94DEC8948AA2')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Meeting Links */
-- CHECK constraint for MJ_BizApps_Tasks: Meeting Links @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB' AND [Name] = 'ValidateMeetingIDComparedToSeriesID'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('094596fa-33f9-47f1-ad9e-d77588b8ba49', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([MeetingID] IS NOT NULL AND [SeriesID] IS NULL OR [MeetingID] IS NULL AND [SeriesID] IS NOT NULL)', 'public ValidateMeetingIDComparedToSeriesID(result: ValidationResult) {
	const hasMeeting = this.MeetingID != null;
	const hasSeries = this.SeriesID != null;

	if ((hasMeeting && hasSeries) || (!hasMeeting && !hasSeries)) {
		result.Errors.push(new ValidationErrorInfo(
			"MeetingID",
			"A record must be associated with either a meeting or a series, but not both.",
			this.MeetingID,
			ValidationErrorType.Failure
		));
	}
}', 'A record must be associated with either a meeting or a series, but cannot be linked to both or neither.', 'ValidateMeetingIDComparedToSeriesID', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '11DB0B1F-A42F-4DF2-8540-6EB46D7618FB')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Meeting Series */
-- CHECK constraint for MJ_BizApps_Tasks: Meeting Series: Field: DurationMinutes was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = 'E92CD564-063F-4B1D-AFC2-66FFD2F6F4F9'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('552c2c95-152f-4212-bdc4-7243feb64459', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([DurationMinutes]>(0))', 'public ValidateDurationMinutesGreaterThanZero(result: ValidationResult) {
	if (this.DurationMinutes != null && this.DurationMinutes <= 0) {
		result.Errors.push(new ValidationErrorInfo(
			"DurationMinutes",
			"Duration must be greater than 0 minutes.",
			this.DurationMinutes,
			ValidationErrorType.Failure
		));
	}
}', 'Event duration must be greater than zero minutes to ensure scheduled events have a valid timeframe.', 'ValidateDurationMinutesGreaterThanZero', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', 'E92CD564-063F-4B1D-AFC2-66FFD2F6F4F9')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Meeting Series Attendees */
-- CHECK constraint for MJ_BizApps_Tasks: Meeting Series Attendees @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C' AND [Name] = 'ValidatePersonIDOrEmailRequired'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('f857a2f4-fcf3-40e0-8cf7-dbd81531d50c', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([PersonID] IS NOT NULL OR [Email] IS NOT NULL)', 'public ValidatePersonIDOrEmailRequired(result: ValidationResult) {
	if (this.PersonID == null && (this.Email == null || this.Email.trim() === "")) {
		result.Errors.push(new ValidationErrorInfo(
			"PersonID",
			"Either a Person or an Email address must be provided.",
			this.PersonID,
			ValidationErrorType.Failure
		));
	}
}', 'At least one contact identifier (either a Person or an Email address) must be provided.', 'ValidatePersonIDOrEmailRequired', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'CF246E72-7BC1-4285-8F37-7C8D89E7A23C')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Meeting Types */
-- CHECK constraint for MJ_BizApps_Tasks: Meeting Types: Field: DefaultDurationMinutes was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = 'ADB2BAD7-156C-4856-BEF9-F2C8D8D60F64'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('11b4cbe7-acfe-4b05-8916-ae92f26ef6e1', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([DefaultDurationMinutes] IS NULL OR [DefaultDurationMinutes]>(0))', 'public ValidateDefaultDurationMinutesGreaterThanZero(result: ValidationResult) {
	if (this.DefaultDurationMinutes != null && this.DefaultDurationMinutes <= 0) {
		result.Errors.push(new ValidationErrorInfo(
			"DefaultDurationMinutes",
			"Default duration must be greater than 0 minutes.",
			this.DefaultDurationMinutes,
			ValidationErrorType.Failure
		));
	}
}', 'Default duration minutes must be greater than zero when specified.', 'ValidateDefaultDurationMinutesGreaterThanZero', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', 'ADB2BAD7-156C-4856-BEF9-F2C8D8D60F64')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Meetings */
-- CHECK constraint for MJ_BizApps_Tasks: Meetings @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND [Name] = 'ValidateEndsAtAfterStartsAt'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('89e4d220-b471-4934-bb78-78f5a46ef902', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([EndsAt]>[StartsAt])', 'public ValidateEndsAtAfterStartsAt(result: ValidationResult) {
	if (this.StartsAt != null && this.EndsAt != null) {
		const startTime = new Date(this.StartsAt).getTime();
		const endTime = new Date(this.EndsAt).getTime();
		if (endTime <= startTime) {
			result.Errors.push(new ValidationErrorInfo(
				"EndsAt",
				"End time must be after the start time.",
				this.EndsAt,
				ValidationErrorType.Failure
			));
		}
	}
}', 'The scheduled end time must be after the start time.', 'ValidateEndsAtAfterStartsAt', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '83BB5923-29C9-4CBB-94C4-35601DA29DDD')
   END;

-- CHECK constraint for MJ_BizApps_Tasks: Meetings @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '83BB5923-29C9-4CBB-94C4-35601DA29DDD' AND [Name] = 'ValidateSeriesIDAndOccurrenceStartsAt'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('6329a378-7732-4e4c-8195-4a08245c4305', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([SeriesID] IS NULL AND [OccurrenceStartsAt] IS NULL OR [SeriesID] IS NOT NULL AND [OccurrenceStartsAt] IS NOT NULL)', 'public ValidateSeriesIDAndOccurrenceStartsAt(result: ValidationResult) {
	const hasSeriesID = this.SeriesID != null;
	const hasOccurrenceStartsAt = this.OccurrenceStartsAt != null;

	if (hasSeriesID !== hasOccurrenceStartsAt) {
		result.Errors.push(new ValidationErrorInfo(
			"SeriesID",
			"Series and occurrence start time must either both be provided or both be empty.",
			this.SeriesID,
			ValidationErrorType.Failure
		));
	}
}', 'Series ID and Occurrence Start Time must either both be specified or both be omitted. An event belonging to a series requires an occurrence start time, while standalone events cannot have one.', 'ValidateSeriesIDAndOccurrenceStartsAt', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '83BB5923-29C9-4CBB-94C4-35601DA29DDD')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Task Dependencies */
-- CHECK constraint for MJ_BizApps_Tasks: Task Dependencies @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND [Name] = 'ValidateTaskIDNotEqualToDependsOnTaskID'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('1abc92cf-02e1-462c-9142-a7960e32fe93', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([TaskID]<>[DependsOnTaskID])', 'public ValidateTaskIDNotEqualToDependsOnTaskID(result: ValidationResult) {
	if (this.TaskID && this.DependsOnTaskID && this.TaskID === this.DependsOnTaskID) {
		result.Errors.push(new ValidationErrorInfo(
			"DependsOnTaskID",
			"A task cannot depend on itself. Please select a different task for the dependency.",
			this.DependsOnTaskID,
			ValidationErrorType.Failure
		));
	}
}', 'A task cannot depend on itself; the dependent task must be different from the main task.', 'ValidateTaskIDNotEqualToDependsOnTaskID', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '0662FC0F-3F2B-49C9-9BE8-5B59E036044A')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Task Template Item Dependencies */
-- CHECK constraint for MJ_BizApps_Tasks: Task Template Item Dependencies @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND [Name] = 'ValidateItemIDNotEqualToDependsOnItemID'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('febe3fcf-513b-4513-9127-bbea1868d463', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([ItemID]<>[DependsOnItemID])', 'public ValidateItemIDNotEqualToDependsOnItemID(result: ValidationResult) {
	if (this.ItemID != null && this.DependsOnItemID != null && this.ItemID === this.DependsOnItemID) {
		result.Errors.push(new ValidationErrorInfo(
			"DependsOnItemID",
			"An item cannot depend on itself. Item and DependsOnItem must be different.",
			this.DependsOnItemID,
			ValidationErrorType.Failure
		));
	}
}', 'An item cannot depend on itself; the item and the item it depends on must be different.', 'ValidateItemIDNotEqualToDependsOnItemID', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '8A30F14C-26FF-476E-8CA1-B10EAD29A428')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Tasks */
-- CHECK constraint for MJ_BizApps_Tasks: Tasks: Field: PercentComplete was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '5812F201-256C-47AC-AEEB-3402FD1E9846'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('8cddcd5d-f214-435a-afc1-120044e62e5d', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([PercentComplete]>=(0) AND [PercentComplete]<=(100))', 'public ValidatePercentCompleteRange(result: ValidationResult) {
	if (this.PercentComplete != null && (this.PercentComplete < 0 || this.PercentComplete > 100)) {
		result.Errors.push(new ValidationErrorInfo(
			"PercentComplete",
			"Percent complete must be between 0 and 100.",
			this.PercentComplete,
			ValidationErrorType.Failure
		));
	}
}', 'Percent complete must be between 0 and 100 percent.', 'ValidatePercentCompleteRange', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', '5812F201-256C-47AC-AEEB-3402FD1E9846')
   END;

